#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TMSAF05.CH'

#DEFINE ITEAGE    1
#DEFINE SEQUEN    2
#DEFINE TIPOAGE   3
#DEFINE DIST      4
#DEFINE NOME      5
#DEFINE ENDER     6
#DEFINE BAIRRO    7
#DEFINE MUN       8
#DEFINE EST       9
#DEFINE CEP      10
#DEFINE CDRDES   11
#DEFINE REGDES   12
#DEFINE TIPTRA   13
#DEFINE CLIDEV   14
#DEFINE LOJDEV   15
#DEFINE NOMDEV   16

#DEFINE DADOSCOT  1
#DEFINE PRODCOT   2
#DEFINE VALINFCOT 3
#DEFINE CUBCOT    4
#DEFINE TIPVEICOT 5
#DEFINE FRTINFCOT 6
#DEFINE FRTCMPCOT 7

Static lTMF05LOk := ExistBlock("TMF05LOK")
Static lTMF05CPO := ExistBlock("TMF05CPO")
Static lTMF05Ite := ExistBlock("TMF05ITE")
Static lTMF05Cot := ExistBlock("TMF05COT")
Static lTMF05Mod := ExistBlock("TMF05MOD")
Static lTMF05NREP:= ExistBlock("TMF05NREP")
Static lTMF05NPRD:= ExistBlock("TMF05NPRD")
Static cCdrOri   := ''
Static cCliAnt   := ''
Static cLojAnt   := ''
Static lNovoItem := .F.
Static aPrdData  := {}
Static lTmsa029   := FindFunction("TMSA029USE") //.And. Tmsa029Use("TMSAF05")
Static cMV_TMSINCO:= SuperGetMv("MV_TMSINCO",.F.,"")
Static lTM05VLD  := ExistBlock('TM05VLESP')
Static lTMF05PRV := ExistBlock('TMF05PRV')	//-- Ponto de entrada para validar pré abertura 'Produtos por Agendamento'
Static lTM05VPRD := ExistBlock('TM05VPRD')
Static lTMF05COP := ExistBlock("TMF05COP")

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAF05  ³ Autor ³ Eduardo de Souza      ³ Data ³ 08/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Agendamento - Carga Fechada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05()
Local aCores      := {}
Local aSetKey     := {}
Local lPainel := .F.
Private cCadastro := STR0001 // 'Agendamento'
Private aRotina   := MenuDef()
If Type("aPanAgeTMS") == "U"
	aPanAgeTMS := Array(6)
EndIf

lPainel := IsInCallStack("TMSAF76") .And. !Empty(aPanAgeTMS)

If !TmsCFec()
	Help("",1,"TMSAF0518") //-- O parametro MV_TMSCFEC nao esta habilitado para utilizacao da Carga Fechada.
	Return( .F. )
EndIf

AAdd(aSetKey, { VK_F12 , { || Pergunte("TMAF05",.T.) } } )

aCores := TMSAF05Cor()

DbSelectArea('DF0')
DbSetOrder(1)

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

If !lPainel
	mBrowse(6,1,22,75,'DF0',,,,,,aCores)
Else
	If (at("(",aPanAgeTMS[6])>0)
		&(aPanAgeTMS[6])
	Else
		&(aPanAgeTMS[6] + "('" + aPanAgeTMS[1] + "'," + StrZero(aPanAgeTMS[2],10) + "," + StrZero(aPanAgeTMS[3],2) + ")")
	Endif
EndIf

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSF05Mnt ³ Autor ³ Eduardo de Souza      ³ Data ³ 08/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao - Agendamento                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF05Mnt(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSF05Mnt(cAlias,nReg,nOpcx,lTela,lAtuRat, aAutDF0, aAutDF1, aAutDF2, lValFlds, lRet )

Local oRemet
Local oRepCont
Local oFolder
Local aSize        := {}
Local aInfo        := {}
Local aObjects     := {}
Local aPosObj      := {}
Local aVisual      := {}
Local cNoFields    := ''
Local nOpca        := 0
Local aAlter       := Nil
Local aNoFields    := {}
Local aYesFields   := {}
Local aTitulos     := {}
Local aPaginas     := {}
Local nControl     := 0
Local aButtons     := {}
Local aRetPE       := {}
Local nCnt         := 0
Local aSomaButtons := {}
Local nCntFor      := 0
Local cNumAge      := ''
Local cMay         := ''
Local aAreaDF0     := {}
Local lCopia       := (nOpcx == 7)
Local aRotBkp      := Iif(Type('aRotina') == 'A',Aclone(aRotina),{})
Local aColsBkp     := Iif(Type('aCols')   == 'A',Aclone(aCols)  ,{})
Local aHeaderBkp		:= Iif(Type('aHeader') == 'A',Aclone(aHeader),{})
Local nMax				:= 999 //--No. Maximo de linhas - MsGetDados
Local nCount	 := 0
Local nPosicao	 := 0
Local nContador	 := 0
Local aColsDF1   := {}
Local aHeadDF1   := {}
Local nDF1STACOL		:= 0

Local nLinConf   := 0
Local nDF1ITEAGE := 0

Local nPosVolum  := 0
Local nPosPeso   := 0
Local nPosPesoM  := 0  
Local nPosMetro3 := 0
Local nPosVlrMer := 0
Local nVolume    := 0
Local nPeso      := 0
Local nPesoM     := 0
Local nMETRO3    := 0
Local nVlrMerc   := 0
Local aFldDF0	 := {}
Local nI		 := 0
Local cFldDF0	 := ""

Private oDlg
Private oEnch
Private oGetDAge
Private oTValPas
Private oTValImp
Private oTValTot
Private nTValPas     := 0
Private nTValImp     := 0
Private nTValTot     := 0
Private aColsPrd     := {}
Private aColsCtn     := {}
Private aColsTip     := {}
Private aColsVInf    := {}
Private aColsPM3     := {}
Private aHeadPrd     := {}
Private aHeader      := {}
Private aCols        := {}
Private aAltGetD     := Nil
Private n            := 1
Private lSugRemet    := .F.
Private lRepCont     := .F.
Private aSetKey      := {}
Private aNoDelCot    := {}
Private lAtuCot      := .F.
Private cGrpVen      := PadR(GetMv("MV_CDRORI"),Len(DUY->DUY_GRPVEN))
Private lConfirma    := .F.
Private lCancela     := .F.
Private lAltSeq      := .F.
Private cIniDis      := ''
Private cTipDis      := ''
Private lAtuSeqAgend := .F.
Private lDDMF05		 := .F. 	
Private aTELA[0][0]
Private aGETS[0]
Private aColsAnt     := ""
Private lAlter       := .F.
Private cAntAge      := ""
Private aRotina		 := Iif(Type('aRotina') == 'A',aClone(aRotina),MenuDef()) //-- Proteção De Erro Para Execução Direta Pelo TMSA019
Private aModified    := {} //| Historico de alteracoes das grids do agendamento, a principio utilizado para validar alteracoes nos Produtos do Agendamento. formato: {'ITEM DF1','ALIAS','linha'}  

Default aAutDF0	:= {}
Default aAutDF1	:= {}
Default aAutDF2	:= {}
Default lValFlds	:= .f. //-- Se .t. Não Gera Agendamento, Somente Valida Os Vetores aAutDF0, aAutDF1 e aAutDF2. 
Default lRet		:= .t. //-- Variável De Retorno De Validação Da Rotina TMSAF74.  

cCadastro	:= STR0001 // 'Agendamento'

//-- Iniciliza pergunta novamente
Pergunte("TMAF05",.F.)

If ValType(lTela) == 'A' .Or. lTela == Nil
	lTela := .T.
	If IsInCallStack("TMSAF76") .And. IsInCallStack("TMSA050") .And. nOpcx == 6
		lTela := .F.
	EndIf
EndIf

If ValType(lAtuRat) == 'A' .Or. lAtuRat == Nil
	lAtuRat := .F.
EndIf

If lAtuRat 
	If Type('aRotina') == 'A'
	   aRotina := MenuDef()
	EndIf
EndIf

If IsInCallStack("TMSAF05")
	nOpcx := aRotina[nOpcx][4]
EndIf	

If nOpcx <> 2 .And. nOpcx <> 3
	//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
	If !TMSAVerAge("4",,,,,,,,,,,DF0->DF0_NUMAGE,"2",.T.,.T.,,)
		Return .F.
	EndIf
EndIf

If nOpcx <> 2
	//-- Alteracao
	If nOpcx == 4 
		If DF0->DF0_STATUS == StrZero(9,Len(DF0->DF0_STATUS)) // Cancelamento
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help(" ",1,"TMSAF0502") // O Agendamento encontra-se cancelado.
			Return( .F. )
		EndIf
		If DF0->DF0_STATUS == StrZero(4,Len(DF0->DF0_STATUS)) // Encerrado
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help(" ",1,"TMSAF0536") // O Agendamento encontra-se encerrado.
			Return( .F. )
		EndIf
		If 	( DF0->DF0_STATUS == StrZero(1,Len(DF0->DF0_STATUS)) .Or. ; // A Confirmar
			  DF0->DF0_STATUS == StrZero(2,Len(DF0->DF0_STATUS)) .Or. ; // Confirmado
			  DF0->DF0_STATUS == StrZero(3,Len(DF0->DF0_STATUS)) ) // Em Processo
			aAlter := {"DF0_INIDIS","DF0_TIPDIS"}
		Else
			aAlter := {}
		EndIf
		//-- Campos liberados para alteracao
		If ExistBlock("TMF05ALC")
			aRetPE := ExecBlock("TMF05ALC",.F.,.F.)
			If ValType(aRetPE) == "A"
				aEval(aRetPE,{ |x| aAdd(aAlter,x ) })
			EndIf
		EndIf
	EndIf
	//-- Confirmacao
	If nOpcx == 6
		If	DF0->DF0_STATUS <> StrZero(1,Len(DF0->DF0_STATUS)) .And. ; // A Confirmar
			DF0->DF0_STATUS <> StrZero(2,Len(DF0->DF0_STATUS)) .And. ; // Confirmado
			DF0->DF0_STATUS <> StrZero(3,Len(DF0->DF0_STATUS)) // Em Processo
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help(" ",1,"TMSAF0501") // Manutencao permitida somente para o status 'A Confirmar', 'Confirmado' ou 'Em Processo'.
			Return( .F. )
		EndIf
		If DF0->DF0_STATUS == StrZero(3,Len(DF0->DF0_STATUS)) // Em Processo
			aAlter := {}
		Else
			aAlter := {"DF0_STATUS"}
		EndIf
		lConfirma := .T.
	EndIf

	//-- Cancelamento
	If nOpcx == 5
		If DF0->DF0_STATUS == StrZero(9,Len(DF0->DF0_STATUS)) // Cancelamento
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help(" ",1,"TMSAF0502") // O Agendamento encontra-se cancelado.
			Return( .F. )
		EndIf
		If	DF0->DF0_STATUS <> StrZero(1,Len(DF0->DF0_STATUS)) .And. ;	// A Confirmar
			DF0->DF0_STATUS <> StrZero(2,Len(DF0->DF0_STATUS))			// Confirmado
			//-- Limpa marcas dos agendamentos
			//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
			If !IsInCallStack("TMSAF76")
				TMSALimAge(StrZero(ThreadId(),20))
			EndIf
			Help(" ",1,"TMSAF0521") // Manutencao permitida somente para o status 'A Confirmar' ou 'Confirmado'.
			Return( .F. )
		EndIf
		aAlter   := {'DF0_STATUS'} // Campos que poderao ser Alterados
		lCancela := .T.
	Else
		cNoFields += 'DF0_DATCAN;DF0_OBSCAN'
	EndIf
EndIf

aFldDF0 := ApBuildHeader("DF0", Strtokarr2( cNoFields, ";"))
For nI := 1 To Len(aFldDF0)
	cFldDF0 := aFldDF0[nI][2]
	AAdd( aVisual, cFldDF0)

	If( aFldDF0[nI][10] == 'V' .Or. Inclui )
		If ( (Len(aAutDF0) == 0) .And. (Len(aAutDF1) == 0) )
			M->&(cFldDF0) := CriaVar(cFldDF0)
		Else
			nCnt := Ascan( aAutDF0, { |x| x[1] == AllTrim( cFldDF0) } )

			If nCnt > 0
				M->&(cFldDF0) := aAutDF0[nCnt][ 2 ]
			Else
				M->&(cFldDF0) := CriaVar(cFldDF0)
			EndIf
		EndIf
	Else
		M->&( cFldDF0) := DF0->(FieldGet(FieldPos(cFldDF0)))
	EndIf
Next

aSize(aFldDF0, 0)
aFldDF0 := Nil

// Ajusta SXE e SXF caso estejam corrompidos.
If (nOpcx == 3 .Or. nOpcx == 7) .And. !(lValFlds) //-- Não Utiliza Numeração Se For Somente Validação
	aAreaDF0:= DF0->(GetArea())
	cNumAge := M->DF0_NUMAGE
	cMay    := AllTrim(xFilial('DF0'))+cNumAge
	FreeUsedCode()
	DF0->(DbSetOrder(1))
	While DF0->(MsSeek(xFilial('DF0')+cNumAge)) .Or. !MayIUseCode(cMay)
		ConfirmSx8()
		cNumAge := CriaVar("DF0_NUMAGE")
		FreeUsedCode()
		cMay := AllTrim(xFilial('DF0'))+cNumAge
	EndDo
	If nOPcx == 3
		M->DF0_NUMAGE := cNumAge
	Else
		cNewAge := cNumAge
	EndIf
	RestArea(aAreaDF0)
EndIf

//-- Armazena as variaveis para validacao da distancia
cIniDis   := M->DF0_INIDIS
cTipDis   := M->DF0_TIPDIS

AAdd(aSetKey  ,{ VK_F4    ,{ || TMSAF05Prd(TMSAF05Whn(.F.)) } } )
AAdd(aButtons ,{'SDUPROP' ,{ || TMSAF05Prd(TMSAF05Whn(.F.)) }, STR0031, STR0061 }) // 'Produtos - <F4>'
AAdd(aSetKey  ,{ VK_F5    ,{ || TMSAF05Cot(TMSAF05Whn(.F.) .Or. nOpcx == 4) } } )
AAdd(aButtons ,{'BUDGET'  ,{ || TMSAF05Cot(TMSAF05Whn(.F.) .Or. nOpcx == 4) }, STR0032, STR0062 }) // 'Cotacao - <F5>'
AAdd(aSetKey  ,{ VK_F6    ,{ || TMSAF05Tip(TMSAF05Whn(.F.)) } } )
AAdd(aButtons ,{'RPMNEW'  ,{ || TMSAF05Tip(TMSAF05Whn(.F.)) }, STR0044, STR0063 }) // 'Tipos de Veiculos - <F6>'

AAdd(aSetKey  ,{ VK_F7     ,{|| TmsAF05SQE(nOpcx) } } )
AAdd(aButtons ,{'CARGASEQ' ,{|| TmsAF05SQE(nOpcx) }, STR0045, STR0064  }) //-- 'Sequencia Agendamento - < F7>'

AAdd(aSetKey  ,{ VK_F8     ,{ || TMF05CDoc() } } )
AAdd(aButtons ,{'DESTINOS' ,{ || TMF05CDoc() }, STR0060, STR0054 }) // 'Mais detalhes... - <F8>'

// -- P.E. para Adicionar Botoes na Enchoice do Agendamento
If ExistBlock('TMSAFBUT')
	aSomaButtons:=ExecBlock('TMSAFBUT',.F.,.F.,{nOpcx})
	// Caso o retorno nao seja em array zera o retorno com array vazio
	If ValType(aSomaButtons) # 'A'
		aSomaButtons := {}
	Else
		For nCntFor := 1 To Len(aSomaButtons)
			AAdd(aButtons,aSomaButtons[nCntFor])
		Next
	EndIf
Endif

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 040, .T., .T. } )
AAdd( aObjects, { 100, 005, .T., .T. } )
AAdd( aObjects, { 100, 040, .T., .T. } )
AAdd( aObjects, { 100, 015, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

//-- Itens do Agendamento
AAdd(aNoFields,"DF1_NUMAGE")
AAdd(aNoFields,"DF1_MRKPAN")

If nOpcx == 5 .Or. nOpcx == 2
	AAdd(aYesFields,"DF1_DATCAN")
	AAdd(aYesFields,"DF1_OBSCAN")
Else
	AAdd(aNoFields,"DF1_DATCAN")
	AAdd(aNoFields,"DF1_OBSCAN")
EndIf

TMSFillGetDados(nOpcx, "DF1", 1, xFilial("DF1") + M->DF0_NUMAGE, Iif(nOpcx <> 3,{ || DF1->DF1_FILIAL + DF1->DF1_NUMAGE }, {|| ''}), { || .T. }, aNoFields, aYesFields)

//-- Preenche o Item do Agendamento
If Empty(GDFieldGet("DF1_ITEAGE",1))
	GDFieldPut("DF1_ITEAGE",StrZero(1,Len(DF1->DF1_ITEAGE)),1)
EndIf

//-------------------------------------------------------------
// Autor: Adalberto
// Compatibilização: Eduardo Alberti
// Tratamento Para Execução Automática Dos Agendamentos
// Nov/2015
// Version P12
//-------------------------------------------------------------
If ( (Len(aAutDF0) > 0) .And. (Len(aAutDF1) > 0) ) 

	//--------------------------------------------------------
	// Copiar O Item / Linha Em Branco Adicionada Ao Acols    
	// Pela Quantidade De Itens Previstos A Serem Inseridos   
	// No Proprio Acols. A Quantidade Eh Definida Pela        
	// Quantidade De Itens Existentes No Vetor Aautdf1        
	//--------------------------------------------------------
	For nCnt := 1 To ( Len( aAutDF1 ) - Len( aCols ) )
		Aadd( aCols,  Aclone( aCols[ 1 ] ) )
	Next nCnt

	//-------------------------------------------------------------
	// Inserido Ao Acols O Conteudo De Cada Item Do Vetor aAutDF1
	//-------------------------------------------------------------
	For nCnt := 1 To Len( aAutDF1 )
		For nCount := 1 To Len( aAutDF1[ nCnt ] )
			nPosicao := 0
			nPosicao := Ascan( aHeader, { |x| x[2] == AllTrim( aAutDF1[ nCnt ] [ nCount ] [ 1 ] ) } )
			
			If nPosicao > 0
				aCols[ nCnt ] [ nPosicao ] := aAutDF1[ nCnt ] [ nCount ] [ 2 ]
			EndIf
		Next nCount
		
		//-------------------------------------------------------------
		// Manutenção Do Número Do Item
		//-------------------------------------------------------------
		nPosicao := 0
		nPosicao := Ascan( aHeader, { |x| x[2] == "DF1_ITEAGE" } )
		
		If nPosicao > 0
			aCols[ nCnt ] [ nPosicao ] := StrZero(nCnt, Len(DF1->DF1_ITEAGE) )
		EndIf
	Next nCnt

	//-------------------------------------------------------------
	// Inserido Produtos Por Item Do aCols (DF1)
	//-------------------------------------------------------------
	If (Len(aAutDF2) > 0)
		SaveInter() //-- Salva aCols
	
		aColsPrd := {}
		aColsDF1 := AClone(aCols)
		aHeadDF1 := AClone(aHeader)

		For nCnt := 1 To Len( aAutDF1 )
			aCols    := {}
			aHeader  := {}
			TMSFillGetDados(nOpcx, "DF2", 1, xFilial("DF2") + M->DF0_NUMAGE + StrZero(nCnt, Len(DF1->DF1_ITEAGE) ), { || DF2->DF2_FILIAL + DF2->DF2_NUMAGE + DF2->DF2_ITEAGE }, { || .T. } )

			//-------------------------------------------------------------
			// Copiar O Item / Linha Em Branco Adicionada Ao aCols  
			// Pela Quantidade De Itens Previstos A Serem Inseridos 
			// No Proprio aCols. A Quantidade Eh Definida Pela      
			// Quantidade De Itens Existentes No Vetor aAutDF2[nCnt]
			//-------------------------------------------------------------
			For nCount := 1 To ( Len( aAutDF2[ nCnt ] ) - Len( aCols ) )
				Aadd( aCols,  Aclone( aCols[ 1 ] ) )
			Next nCount

			//-------------------------------------------------------------
			// Inserido Produtos Por Item Do aCols (DF1)
			//-------------------------------------------------------------
			For nCount := 1 To Len( aAutDF2[ nCnt ] )
				For nContador := 1 To Len( aAutDF2[ nCnt ] [ nCount ] )
					nPosicao := 0
					nPosicao := Ascan( aHeader, { |x| x[2] == AllTrim( aAutDF2[ nCnt ] [ nCount ] [ nContador ] [ 1 ] ) } )
				
					If nPosicao > 0
						aCols[ nCount ] [ nPosicao ] := aAutDF2[ nCnt ] [ nCount ] [ nContador ] [ 2 ]
					EndIf
				Next nContador
			Next nCount

			AAdd(aColsPrd,{ StrZero(nCnt, Len(DF1->DF1_ITEAGE) ), AClone(aCols), AClone(aHeader) } )
		Next nCnt

		aCols    := {}
		aHeader  := {}
		aCols    := AClone(aColsDF1)
		aHeader  := AClone(aHeadDF1)
	EndIf
EndIf

//-- Inicializa Totalizadores da Cotacao
For nCnt := 1 To Len(aCols)
	If !GDDeleted(nCnt) .And. Iif(lAtuRat,.T.,GDFieldGet("DF1_STACOL",nCnt) <> Strzero(9,Len(GDFieldGet("DF1_STACOL",nCnt))))
		nTValPas += GDFieldGet("DF1_VALFRE",nCnt)
		nTValImp += GDFieldGet("DF1_VALIMP",nCnt)
		nTValTot += GDFieldGet("DF1_VALTOT",nCnt)
	EndIf
Next nCnt

//-- Copia de Agendamento
If nOpcx == 7
	TMSAF05Cop(@nOpcx,cNewAge)

     //-- Atualiza Volume,Peso,Metro 3,Peso 3 e Valor Mercadoria do DF1
     For nCnt := 1 To Len(aCols)
         
         nPosicao := AScan( aColsPrd , { |x| x[1] == aCols[nCnt,GDFieldPos("DF1_ITEAGE")] } )
         
         //-- Atualiza os itens do Agendamento
         nVolume    := 0
         nPeso      := 0
         nPesoM     := 0
         nMETRO3    := 0
         nVlrMerc   := 0
         
         nPosVolum  := GDFieldPos("DF2_QTDVOL",aColsPrd[nPosicao,3])
         nPosPeso   := GDFieldPos("DF2_PESO"  ,aColsPrd[nPosicao,3])
         nPosPesoM  := GDFieldPos("DF2_PESOM3",aColsPrd[nPosicao,3])
         nPosMetro3 := GDFieldPos("DF2_METRO3",aColsPrd[nPosicao,3])
         nPosVlrMer := GDFieldPos("DF2_VALMER",aColsPrd[nPosicao,3])

         For nCount := 1 To Len(aColsPrd[nPosicao][2])
              
              nVolume   += aColsPrd[nPosicao, 2, nCount,nPosVolum ]
              nPeso     += aColsPrd[nPosicao, 2, nCount,nPosPeso  ]
              nPesoM    += aColsPrd[nPosicao, 2, nCount,nPosPesoM ]
              nMETRO3   += aColsPrd[nPosicao, 2, nCount,nPosMetro3]
              nVlrMerc  += aColsPrd[nPosicao, 2, nCount,nPosVlrMer]
              
         Next nCount

         GDFieldPut("DF1_QTDVOL", nVolume , nCnt)
         GDFieldPut("DF1_PESO"  , nPeso   , nCnt)
         GDFieldPut("DF1_PESOM3", nPesoM  , nCnt)
         GDFieldPut("DF1_METRO3", nMETRO3 , nCnt)
         GDFieldPut("DF1_VALMER", nVlrMerc, nCnt)

     Next nCnt

EndIf

//--Ponto de entrada para definir o 
//--No. maximo de linhas da MsGetDados:
If lTMF05Ite
	nMax := ExecBlock("TMF05ITE",.F.,.F.)
	If ValType(nMax) <> "N"
		nMax := 999
	EndIf
EndIf

//-- Painel De Agendamento
/*
If IsInCallStack("TMSAF76")
	If nOpcx == 4
		If DF1->(DF1_FILIAL+DF1_NUMAGE) != DF0->(DF0_FILIAL+DF0_NUMAGE)
			DF1->( dbSetOrder(1) )
			DF1->( dbSeek(xFilial("DF1") + DF0->DF0_NUMAGE + StrZero(1 , Len(DF1->DF1_ITEAGE) ) ) )
		EndIf
		DT5->(DbSetOrder(1))
		
		If DT5->(DbSeek(xFilial("DT5") + DF1->(DF1_FILDOC+DF1_DOC) )) .And. DT5->DT5_STATUS != "1"
			Aviso("Atenção","Solicitação de coleta não está em aberto...",{"Ok"})
			Return(.F.)
		EndIf
	EndIf
EndIf
*/

If lTela
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

	oEnch := MsMGet():New(cAlias,nReg,Iif(nOpcx==5 .Or. nOpcx == 6 .Or. nOpcx == 7,4,nOpcx),,,,aVisual,aPosObj[1],aAlter,3,,,,,,.T.)

	//-- 'Sugerir solicitante como remetente'
	@ aPosObj[2,1],aPosObj[2,2] CHECKBOX oRemet VAR lSugRemet PROMPT STR0010 SIZE 100,010 ;
		ON CLICK( If(nOpcx == 3 .Or. nOpcx == 4,( TMSAF05Sug(3),lRepCont := .F., oRepCont:Refresh() ),.T.) ) OF oDlg PIXEL
	oRemet:lReadOnly:= !( nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx == 7 )

	//-- Repetir conteudo no proximo item
	@ aPosObj[2,1],aPosObj[2,2]+100 CHECKBOX oRepCont VAR lRepCont PROMPT STR0033 SIZE 100,010 ;
		ON CLICK ( lSugRemet := .F., oRemet:Refresh() ) OF oDlg PIXEL
	oRepCont:lReadOnly:= !( nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx == 7 )

	oGetDAge:=MSGetDados():New(aPosObj[3,1], aPosObj[3,2], aPosObj[3,3], aPosObj[3,4], If(nOpcx==5,4,nOpcx), 'TMSAF05LOk(1)','TMSAF05TOk()','+DF1_ITEAGE', nOpcx<>2,,,,nMax,,,,'TMSAF05Del')
	oGetDAge:oBrowse:bChange := { || TMSAF05Chg() }

	//-- Bloqueia a digitacao/delecao dos campos
	If !Inclui .And. !Altera
		oGetDAge:oBrowse:bAdd    := { || .f. } 	// Nao Permite a inclusao de Linhas.
		oGetDAge:oBrowse:bDelete := { || .f. } 	// Nao Permite a deletar Linhas.    
		
		If !lConfirma .And. !lCancela
			oGetDAge:oBrowse:AAlter  := {}     // Nao Permite a alteracao de campo
		EndIf
		
		aAltGetD := {}
	ElseIf Altera .And. M->DF0_STATUS == StrZero(4,Len(DF0->DF0_STATUS)) //-- Encerrado
		oGetDAge:oBrowse:bAdd    := { || .f. } // Nao Permite a inclusao de Linhas
	EndIf

	//-- Monta os vetores com as opcoes no Folder
	AAdd(aTitulos,STR0018) // 'Total do Frete'
	AAdd(aPaginas,Upper(STR0018))
	nControl++

	//-- Montagem do Folder
	oFolder := TFolder():New(aPosObj[4,1],aPosObj[4,2],aTitulos,aPaginas,oDlg,,,,.T.,.F.,aPosObj[4,4]-aPosObj[4,2],aPosObj[4,3]-aPosObj[4,1]+5)
	oFolder:aPrompts[1] := STR0018 // 'Total do Frete'

	@ 5,010 SAY STR0019 SIZE 20,9 OF oFolder:aDialogs[1] PIXEL // 'Frete'
	@ 5,030 MSGET oTValPas VAR nTValPas Picture PesqPict('DT8','DT8_VALPAS') WHEN .F. SIZE 70,9 OF oFolder:aDialogs[1] PIXEL

	@ 5,130 SAY STR0020 SIZE 20,9 OF oFolder:aDialogs[1] PIXEL // 'Imposto'
	@ 5,160 MSGET oTValImp VAR nTValImp Picture PesqPict('DT8','DT8_VALIMP') WHEN .F. SIZE 70,9 OF oFolder:aDialogs[1] PIXEL

	@ 5,260 SAY STR0021 SIZE 50,9 OF oFolder:aDialogs[1] PIXEL // 'Frete + Imposto'
	@ 5,310 MSGET oTValTot VAR nTValTot Picture PesqPict('DT8','DT8_VALTOT') WHEN .F. SIZE 70,9 OF oFolder:aDialogs[1] PIXEL

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .And. oGetDAge:TudoOk() .And. TmsAF05Obr(nOpcx,lCopia),(nOpca:=1,TMSAF05Grv(nOpcx,cNoFields),oDlg:End()),.F.) }, ;
																{|| oDlg:End() },, aButtons ) CENTERED
Else
	If TmsAF05Obr(nOpcx,lCopia,lAtuRat,lValFlds)
		nOpca := 1

		If ( (Len(aAutDF0) > 0) .And. (Len(aAutDF1) > 0) ) 
			//-------------------------------------------------------------
			// Forcar Para Que Nao Seja Impressa As Solicitacoes De Coleta,
			// Quando A Rotina Estiver Sendo Executada Sem Apresentar Tela 
			// E Vindo Do Edi - Agendamento Automatico.                    
			//-------------------------------------------------------------
			mv_par01 := 2
		EndIf

		//-- Grava Se Não For Somente Validação
		If !(lValFlds)
			TMSAF05Qtd( lTela )
		    If ( (Len(aAutDF0) == 0) .And. (Len(aAutDF1) == 0) ) 
		        nDF1STACOL := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_STACOL"}) // Posicao do campo "DF1_STACOL"
				If IsInCallStack("AF76CofAgd")
					nDF1ITEAGE := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_ITEAGE"})
					nLinConf := Ascan(aCols,{|x| x[nDF1ITEAGE] == DF1->DF1_ITEAGE})
					If nLinConf == 0
						nLinConf := 1
					EndIf
				Else
					nLinConf := 1
				EndIf
		        aCols[nLinConf][nDF1STACOL] := StrZero(2,Len(DF1->DF1_STACOL)) //Confirmado
		    EndIf    
			TMSAF05Grv(nOpcx,cNoFields)
		EndIf
	Else
		lRet := .f.
	EndIf
EndIf
If nOpcx <> 2 .And. !(lValFlds)
	If nOpca == 1
		//-- Confirma numero do agendamento
		If __lSX8
			ConfirmSX8()
		EndIf
	Else
		//-- Volta numero do agendamento
		If	__lSX8
			RollBackSX8()
		EndIf
		//-- Exclui cotacao quando nao estiver relacionada ao agendamento
		DF1->(DbSetOrder(2))
		For nCnt := 1 To Len(aCols)
			If !Empty(GDFieldGet("DF1_NUMCOT",nCnt)) .And. Ascan( aNoDelCot, { |x| x == GDFieldGet("DF1_NUMCOT",nCnt) } ) == 0
				If !DF1->(MsSeek(xFilial("DF1")+GDFieldGet("DF1_FILORI",nCnt)+GDFieldGet("DF1_NUMCOT",nCnt)))
					TMSAF05DCot(GDFieldGet("DF1_FILORI",nCnt),GDFieldGet("DF1_NUMCOT",nCnt)) //-- Exclusao da Cotacao
				EndIf
			EndIf
		Next nCnt
	EndIf
EndIf

If Len(aColsBkp) > 0
	aCols   := AClone(aColsBkp)
	aHeader := AClone(aHeaderBkp)
EndIf
If Len(aRotBkp) > 0
	aRotina := AClone(aRotBkp)
EndIf

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05Grv³ Autor ³ Eduardo de Souza      ³ Data ³ 08/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao do Agendamento                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Grv(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Grv(nOpcx,cNoFields,lCotacao)

Local bCampo    := { |nCpo| Field(nCpo) }
Local nI        := 0
Local nCnt      := 0
Local nCnt1     := 0
Local nCnt2     := 0
Local nPasso    := 0
Local aDelItem  := {}
Local aDelPrd   := {}
Local cFilDoc   := ''
Local cDocto    := ''
Local cSerie    := ''
Local cProduto  := ''
Local cEmb		:= ""
Local cQtdVol	:= ""
Local cQtdUni	:= ""
Local cPeso	:= ""
Local cPesoM3	:= ""
Local cValMer	:= ""
Local cBasSeg	:= ""
Local lEmb		:= .F. 
Local lQtdVol := .F.
Local lQtdUni := .F.
Local lPeso	:= .F.
Local lPesoM3 := .F.
Local lValMer := .F.
Local lBasSeg := .F.
Local lExcCot   := .F.
Local lExcSol   := .F.
Local nQtdConf  := 0
Local cItemAge  := ''
Local nQtdCanc  := 0
Local lEncAgd   := Iif(M->DF0_STATUS == StrZero(3,Len(DF0->DF0_STATUS)), .T., .F.) //-- Indica se deve encerrar o agendamento
//-- Pergunta exclusão de cotação/solicitação de coleta
Local lPergExc  := (mv_par02 == 1) 

//-- Pontos de Entrada
Local lTMF05GR1 := ExistBlock('TMF05GR1')
Local lTMF05GR2 := ExistBlock('TMF05GR2')
Local lTMF05GR3 := ExistBlock('TMF05GR3')
Local lTMF05GR4 := ExistBlock('TMF05GR4')
Local lTM05APRD := ExistBlock('TM05APRD')

Local lAtPrdUsr := .f.
Local nQtdOk    := 0
Local nTotCan   := 0
Local lAltProd  := .F.
Local nPosDELET  := 0 //Posicao da coluna da GetDados que indica se o item estah deletado
Local nDF1FILDOC := 0
Local nDF1DOC 	 := 0
Local nDF1SERIE  := 0
Local nDF1ITEAGE := 0
Local nDF1STACOL := 0
Local nDF1STAENT := 0
Local nDF1DATCON := 0
Local nDF1DATCAN := 0
Local nDF1OBSCAN := 0
Local nDF1NUMCOT := 0
Local nDF1FILORI := 0
Local nDF1CODNEG := 0
Local nDF2CODPRO := 0
Local nDF3CODPAS := 0
Local nDF3VALOR  := 0
Local nDF4ITEM 	 := 0
Local nDF5TIPVEI := 0
Local nDF5ITEM 	 := 0

Local cNumAge    := ""
Local lGerNum    := .F.

Default cNoFields := ''
Default lCotacao  := .F.
Default lPergExc  := .T.

Private aColsDVT   := {}
Private aHeaderDVT := {}
Private lColeta    := .T. //-- Utilizado para gerar coleta

If nOpcx <> 2 // Se nao for visualizacao

	Begin Transaction

		//--Calcula a Distancia entre regioes, agora no inicio pois gravamos este valor
		//--So na inclusao, na alteracao na pode calcular novamente pois sera alterado o km
		If nOpcx <> 5 //Cancelado
			TMSAF05SQE(nOpcx,.T.)
		EndIf

		If nOpcx == 3 .Or. nOpcx == 7
			cNumAge := TmsVldChav("DF0","DF0_NUMAGE",,M->DF0_NUMAGE,,1)
			If cNumAge != M->DF0_NUMAGE
				lGerNum := .T. 
				M->DF0_NUMAGE := cNumAge
			EndIf
		EndIf

		nPosDELET  := Len(aHeader)+1 //Posicao da coluna da GetDados que indica se o item estah deletado
		nDF1FILDOC := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_FILDOC"}) // Posicao do campo "DF1_FILDOC"
		nDF1DOC    := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_DOC"   }) // Posicao do campo "DF1_DOC"
		nDF1SERIE  := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_SERIE" }) // Posicao do campo "DF1_SERIE"
		nDF1ITEAGE := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_ITEAGE"}) // Posicao do campo "DF1_ITEAGE"
		nDF1STACOL := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_STACOL"}) // Posicao do campo "DF1_STACOL"
		nDF1STAENT := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_STAENT"}) // Posicao do campo "DF1_STAENT"
		nDF1DATCON := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_DATCON"}) // Posicao do campo "DF1_DATCON"
		nDF1DATCAN := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_DATCAN"}) // Posicao do campo "DF1_DATCAN"
		nDF1OBSCAN := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_OBSCAN"}) // Posicao do campo "DF1_OBSCAN"
		nDF1NUMCOT := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_NUMCOT"}) // Posicao do campo "DF1_NUMCOT"
		nDF1FILORI := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_FILORI"}) // Posicao do campo "DF1_FILORI"
		nDF1CODNEG := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_CODNEG"}) // Posicao do campo "DF1_CODNEG"
		
		//-- Itens do Agendamento
		For nCnt := 1 To Len(aCols)
			If !aCols[nCnt][nPosDELET]
				cFilDoc  := aCols[nCnt][nDF1FILDOC]
				cDocto   := aCols[nCnt][nDF1DOC]
				cSerie   := aCols[nCnt][nDF1SERIE]
				cItemAge := aCols[nCnt][nDF1ITEAGE]

				If aCols[nCnt][nDF1STACOL]== StrZero(2,Len(DF1->DF1_STACOL)) // Confirmado
					nQtdOk ++
				ElseIf aCols[nCnt][nDF1STACOL]== StrZero(9,Len(DF1->DF1_STACOL)) // Cancelado
					nTotCan ++
				EndIf

				If lEncAgd
					lEncAgd := Iif(aCols[nCnt][nDF1STACOL] == "5", .T., .F.)
					If lEncAgd 
						lEncAgd := Iif(aCols[nCnt][nDF1STAENT] == "5", .T., .F.)
					EndIf
				EndIf//-- Incluida a condição de itens com status 3 "EM PROCESSO" também entrem na contagem da variável "nQtdConf".
				If (( nOpcx == 6 .Or. nOpcx == 3 ) .And. M->DF0_STATUS == StrZero(2,Len(DF1->DF1_STACOL))   .Or. ; //-- Confirmado
					( nOpcx == 6 .Or. nOpcx == 3 ) .And. M->DF0_STATUS == StrZero(4,Len(DF1->DF1_STACOL)) ) .Or. ; //-- Em Processo
					( nOpcx == 6 .Or. nOpcx == 4 ) .And. aCols[nCnt][nDF1STACOL] == StrZero(2,Len(DF1->DF1_STACOL)) .Or. ;//-- Confirmado
					( nOpcx == 6 .Or. nOpcx == 4 ) .And. aCols[nCnt][nDF1STACOL] == StrZero(4,Len(DF1->DF1_STACOL)) //-- Em Processo
					If aCols[nCnt][nDF1STACOL] <> StrZero(9,Len(DF1->DF1_STACOL))	//Cancelado
						nQtdConf ++
					EndIf

					//-- Atualiza o Status do Agendamento
					If M->DF0_STATUS == StrZero(2,Len(DF0->DF0_STATUS)) //-- Confirmado
						If	aCols[nCnt][nDF1STACOL] == StrZero(1,Len(DF1->DF1_STACOL)) //-- A Confirmar
							aCols[nCnt][nDF1STACOL] := StrZero(2,Len(DF1->DF1_STACOL))
							aCols[nCnt][nDF1STAENT] := StrZero(2,Len(DF1->DF1_STACOL))
							If Empty(aCols[nCnt][nDF1DATCON])
								aCols[nCnt][nDF1DATCON] := dDataBase
							EndIf
						EndIf
					EndIf
					//-- Atualiza Solicitacao de Coleta
					If !lCotacao .And. ( aCols[nCnt][nDF1STACOL] == StrZero(2,Len(DF1->DF1_STACOL))) .And. !IsInCallStack('Tmsa460Grava') //-- Confirmado
						TMSAF05Col(nCnt,@cFilDoc,@cDocto,@cSerie)
					EndIf
				EndIf

				DF1->(DbSetOrder(1))				
				If !DF1->(MsSeek(xFilial("DF1")+IIf(IsInCallStack('af76cofagd'),DF0->DF0_NUMAGE,M->DF0_NUMAGE)+cItemAge))					
					RecLock("DF1",.T.)
					DF1->DF1_FILIAL := xFilial("DF1")
					DF1->DF1_NUMAGE := M->DF0_NUMAGE
					If IsInCallStack("TMSAF76")
						DF1->DF1_MRKPAN := cNumThread
					EndIf
				Else
					RecLock("DF1",.F.)
					If IsInCallStack('af76cofagd')
						M->DF0_NUMAGE := DF0->DF0_NUMAGE
					EndIf
				EndIf

				If nOpcx == 3 .Or. nOpcx == 4
					For nCnt1 := 1 To Len(aHeader)
						If aHeader[nCnt1,10] != 'V'
							DF1->(FieldPut(FieldPos(aHeader[nCnt1,2]),GDFieldGet(aHeader[nCnt1,2],nCnt)))
						EndIf
					Next
					//-- Atualiza dados da coleta
					If aCols[nCnt][nDF1STACOL] == StrZero(2,Len(DF1->DF1_STACOL)) // Confirmado
						If !lCotacao
							DF1->DF1_FILDOC := cFilDoc
							DF1->DF1_DOC    := cDocto
							DF1->DF1_SERIE  := cSerie
						EndIf
						DF1->DF1_STAENT := aCols[nCnt][nDF1STACOL]
					EndIf
				EndIf

				If nOpcx == 5 // Cancelamento
					If ( aCols[nCnt][nDF1STACOL] == StrZero(1,Len(DF1->DF1_STACOL)) .Or. aCols[nCnt][nDF1STACOL] == StrZero(2,Len(DF1->DF1_STACOL))) .Or. ; //-- A Confirmar ### Confirmado
						aCols[nCnt][nDF1STACOL] == StrZero(9,Len(DF1->DF1_STACOL))
						nQtdCanc ++
						DF1->DF1_DATCAN := aCols[nCnt][nDF1DATCAN]
						If !Empty(aCols[nCnt][nDF1OBSCAN])
							MSMM(,,,aCols[nCnt][nDF1OBSCAN],1,,,"DF1","DF1_CODOBC")
						EndIf
						DF1->DF1_STACOL := StrZero(9,Len(DF0->DF0_STATUS)) //-- Cancelado
						DF1->DF1_STAENT := StrZero(9,Len(DF0->DF0_STATUS)) //-- Cancelado
						RecLock("DF0",.F.)
						DF0->DF0_STATUS := TMSF05Stat(DF0->DF0_FILIAL, DF0->DF0_NUMAGE)  //-- Atualiza status do cancelamento
						DF0->(MsUnlock())
						//-- Cancela Cotacao
						If !Empty(aCols[nCnt][nDF1NUMCOT])
							DT4->(DbSetOrder(1))
							If DT4->(MsSeek(xFilial("DT4")+aCols[nCnt][nDF1FILORI]+aCols[nCnt][nDF1NUMCOT]))
								RecLock("DT4",.F.)
								DT4->DT4_STATUS := StrZero(9,Len(DT4->DT4_STATUS)) //-- Cancelado
								DT4->DT4_DATCAN := aCols[nCnt][nDF1DATCAN]
								//-- Grava campos memo.
								If !Empty(aCols[nCnt][nDF1OBSCAN])
									MSMM(,,,aCols[nCnt][nDF1OBSCAN],1,,,"DT4","DT4_CODOBC")
								EndIf
								MsUnLock()
							EndIf
						EndIf
						//-- Cancela Solicitacao
						If !Empty(aCols[nCnt][nDF1FILDOC]) .And. !Empty(aCols[nCnt][nDF1DOC]) .And. !Empty(aCols[nCnt][nDF1SERIE])
							DT5->(DbSetOrder(4))
							If DT5->(MsSeek(xFilial("DT5")+aCols[nCnt][nDF1FILDOC]+aCols[nCnt][nDF1DOC]+aCols[nCnt][nDF1SERIE]))
								RegToMemory('DT5',.F.)
								M->DT5_DATCAN := aCols[nCnt][nDF1DATCAN]
								M->DT5_OBSCAN := aCols[nCnt][nDF1OBSCAN]
								MsUnLock()

								//-- Armazena Tipos de Veiculo do array, utilizada na rotina de cancelamento da Solicitacao.
								SaveInter() //-- Salva aCols
								aColsDVT   := {}
								aHeaderDVT := {}
								aCols      := {}
								aHeader    := {}
								TMSFillGetDados(2, "DF5", 1, xFilial("DF5") + M->DF0_NUMAGE + cItemAge , { || DF5->DF5_FILIAL + DF5->DF5_NUMAGE + DF5->DF5_ITEAGE }, { || .T. } )
								aColsDVT   := AClone(aCols)
								aHeaderDVT := AClone(aHeader)
								RestInter() //-- Restaura aCols

								//-- Rotina de cancelamento da solicitacao de coleta.
								TmsA460Grava( 5 ,,,,, .f. ) //-- .f. No Parametro 6 Para Não Imprimir Cancelamentos
							EndIf
						EndIf
					EndIf
				ElseIf nOpcx == 6 // Confirmacao
					DF1->DF1_STACOL := aCols[nCnt][nDF1STACOL] //-- Confirmado
					If DF1->DF1_STACOL <> StrZero(5,Len(DF1->DF1_STACOL)).And. DF1->DF1_STAENT <> StrZero(2,Len(DF1->DF1_STAENT))//-- Encerrado e Confirmado //-- Encerrado
						DF1->DF1_STAENT := aCols[nCnt][nDF1STACOL] //-- Confirmado
					EndIf
					If ( Empty(aCols[nCnt][nDF1DATCON]) .And. aCols[nCnt][nDF1STACOL] == StrZero(2,Len(DF1->DF1_STACOL))) .Or. ( M->DF0_STATUS == StrZero(2,Len(DF0->DF0_STATUS)) .and. Empty(DF1->DF1_DATCON) ) 
						DF1->DF1_DATCON := dDataBase
					EndIf
					//-- Atualiza dados da coleta
					DF1->DF1_FILDOC := cFilDoc
					DF1->DF1_DOC    := cDocto
					DF1->DF1_SERIE  := cSerie
				EndIf
				DF1->(MsUnLock())

				If lTMF05GR1
					ExecBlock("TMF05GR1",.F.,.F.,nOpcx)
				EndIf
				
				If lTMF05GR4
					ExecBlock("TMF05GR4",.F.,.F.,{nOpcx,nCnt})
				EndIf
			Else
				If !lCotacao
					//-- Exclui Item do agendamento
					DF1->(DbSetOrder(1))
					If DF1->(MsSeek(xFilial("DF1")+M->DF0_NUMAGE+aCols[nCnt][nDF1ITEAGE]))
						RecLock("DF1",.F.)
						DF1->(DbDelete())
						MsUnLock()
					EndIf
					//-- Exclui Produtos por Agendamento
					DF2->(DbSetOrder(1))
					If DF2->(MsSeek(xFilial("DF2")+M->DF0_NUMAGE+aCols[nCnt][nDF1ITEAGE]))
						While DF2->(!Eof()) .And. DF2->DF2_FILIAL + DF2->DF2_NUMAGE + DF2->DF2_ITEAGE == ;
							xFilial("DF2") + M->DF0_NUMAGE + aCols[nCnt][nDF1ITEAGE]
							RecLock("DF2",.F.)
							DF2->(DbDelete())
							MsUnLock()
							DF2->(DbSkip())
						EndDo
					EndIf
					//-- Exclui Valor Informado por produto
					DF3->(DbSetOrder(1))
					If DF3->(MsSeek(xFilial("DF3")+M->DF0_NUMAGE+aCols[nCnt][nDF1ITEAGE]))
						While DF3->(!Eof()) .And. DF3->DF3_FILIAL + DF3->DF3_NUMAGE + DF3->DF3_ITEAGE == ;
							xFilial("DF3") + M->DF0_NUMAGE + aCols[nCnt][nDF1ITEAGE]
							RecLock("DF3",.F.)
							DF3->(DbDelete())
							MsUnLock()
							DF3->(DbSkip())
						EndDo
					EndIf
					//-- Exclui Cubagem por Produto
					DF4->(DbSetOrder(1))
					If DF4->(MsSeek(xFilial("DF4")+M->DF0_NUMAGE+aCols[nCnt][nDF1ITEAGE]))
						While DF4->(!Eof()) .And. DF4->DF4_FILIAL + DF4->DF4_NUMAGE + DF4->DF4_ITEAGE == ;
							xFilial("DF4") + M->DF0_NUMAGE + aCols[nCnt][nDF1ITEAGE]
							RecLock("DF4",.F.)
							DF4->(DbDelete())
							MsUnLock()
							DF4->(DbSkip())
						EndDo
					EndIf
					//-- Exclui Tipos de Veiculo por Agendamento
					DF5->(DbSetOrder(1))
					If DF5->(MsSeek(xFilial("DF2")+M->DF0_NUMAGE+aCols[nCnt][nDF1ITEAGE]))
						While DF5->(!Eof()) .And. DF5->DF5_FILIAL + DF5->DF5_NUMAGE + DF5->DF5_ITEAGE == ;
							xFilial("DF5") + M->DF0_NUMAGE + aCols[nCnt][nDF1ITEAGE]
							RecLock("DF5",.F.)
							DF5->(DbDelete())
							MsUnLock()
							DF5->(DbSkip())
						EndDo
					EndIf
					//-- Exclui Solicitacao
					If !Empty(aCols[nCnt][nDF1FILDOC]) .And. !Empty(aCols[nCnt][nDF1DOC]) .And. !Empty(aCols[nCnt][nDF1SERIE])
						//-- Pergunta ao usuario se a solicitacao devera ser excluida
						If lExcSol .Or. Iif(lPergExc,( lExcSol := Aviso( STR0036, STR0042 ,{STR0038,STR0039}, 2, '' ) == 1 ),.T.) //'Atencao'###'Deseja excluir a solicitacao relacionada ao agendamento ?'###'Sim'###'Nao'
							TMSAF05DSol(aCols[nCnt][nDF1FILDOC],aCols[nCnt][nDF1DOC],aCols[nCnt][nDF1SERIE])
						EndIf
					EndIf
					//-- Exclui cotacao
					If !Empty(aCols[nCnt][nDF1NUMCOT]) .And. Ascan( aNoDelCot, { |x| x == aCols[nCnt][nDF1NUMCOT] } ) == 0
						//-- Pergunta ao usuario se a cotacao devera ser excluida
						If lExcCot .Or. Iif(lPergExc,( lExcCot := Aviso( STR0036, STR0040 ,{STR0038,STR0039}, 2, '' ) == 1 ),.T.) //'Atencao'###'Deseja excluir a cotacao relacionada ao agendamento ?'###'Sim'###'Nao'
							TMSAF05DCot(aCols[nCnt][nDF1FILORI],aCols[nCnt][nDF1NUMCOT]) //-- Exclusao da Cotacao
						EndIf
					EndIf
					AAdd( aDelItem, aCols[nCnt][nDF1ITEAGE] )
				EndIf
			EndIf
		Next nCnt

		If nOpcx == 3 .Or. nOpcx == 4 // Incluir ou Alterar

			//-- Produtos por Agendamento
			For nCnt := 1 To Len(aColsPrd)
				aHeader := AClone(aColsPrd[nCnt,3])
				aCols   := AClone(aColsPrd[nCnt,2])
				nPosDELET  	:= Len(aHeader)+1 //Posicao da coluna da GetDados que indica se o item estah deletado
				nDF2CODPRO 	:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF2_CODPRO" 	}) // Posicao do campo "DF2_CODPRO"
				nDF2CODEMB		:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF2_CODEMB" 	}) // Posicao do campo "DF2_CODEMB"
				nDF2QTDVOL		:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF2_QTDVOL" 	}) // Posicao do campo "DF2_QTDVOL"
				nDF2QTDUNI		:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF2_QTDUNI" 	}) // Posicao do campo "DF2_QTDUNI"
				nDF2PESO		:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF2_PESO"		}) // Posicao do campo "DF2_QTDUNI"
				nDF2PESOM3		:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF2_PESOM3" 	}) // Posicao do campo "DF2_PESOM3"
				nDF2VALMER		:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF2_VALMER" 	}) // Posicao do campo "DF2_VALMER"
				nDF2BASSEG		:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF2_BASSEG" 	}) // Posicao do campo "DF2_BASSEG"
				For nCnt1 := 1 To Len(aCols)
					cProduto	:= aCols[nCnt1][nDF2CODPRO]
					cEmb		:= aCols[nCnt1][nDF2CODEMB]
					cQtdVol	:= aCols[nCnt1][nDF2QTDVOL]
					cQtdUni	:= aCols[nCnt1][nDF2QTDUNI]
					cPeso		:= aCols[nCnt1][nDF2PESO]
					cPesoM3	:= aCols[nCnt1][nDF2PESOM3]
					cValMer	:= aCols[nCnt1][nDF2VALMER]
					cBasSeg	:= aCols[nCnt1][nDF2BASSEG] 
					//-- 1a vez exclui deletados, 2a vez grava itens incluidos ou alterados.
					For nPasso := 1 To 2
						//-- Verifica se o Item do Agendamento nao foi marcado como deletado
						If !aCols[nCnt1][nPosDELET] .And. Ascan( aDelItem, { |x| x == aColsPrd[nCnt,1] } ) == 0
							If nPasso == 2
								If !Empty(cProduto)
								//--Informar .F. para as Variáveis do laço.
									lAltProd:= .F.
									lEmb    := .F.
									lQtdVol := .F.
									lQtdUni := .F.
									lPeso   := .F.
									lPesoM3 := .F.
									lValMer := .F.
									lBasSeg := .F.

									//-- Verifica se o Produto do Item do Agendamento foi alterado, para não gerar uma novo registro
									If nOpcx == 4 .And. nCnt1 <= Len(aColsAnt)
										DF2->(DbSetOrder(1)) //DF2_FILIAL+DF2_NUMAGE+DF2_ITEAGE+DF2_CODPRO
										If DF2->(MsSeek(xFilial("DF2")+M->DF0_NUMAGE+aColsPrd[nCnt,1]+aColsAnt[nCnt1,1]))
											
											If aColsAnt[nCnt1,1] <> cProduto
													lAltProd:= .T.
											ElseIf aColsAnt[nCnt1,nDF2CODEMB] <> cEmb
												lEmb := .T.
											ElseIf aColsAnt[nCnt1,nDF2QTDVOL] <> cQtdVol
												lQtdVol := .T.
											ElseIf aColsAnt[nCnt1,nDF2QTDUNI] <> cQtdUni
												lQtdUni := .T.								
											ElseIf aColsAnt[nCnt1,nDF2PESO] <> cPeso
												lPeso := .T.	
											ElseIf aColsAnt[nCnt1,nDF2PESOM3] <> cPesoM3
												lPesoM3 := .T.
											ElseIf aColsAnt[nCnt1,nDF2VALMER] <> cValMer
												lValMer := .T.
											ElseIf aColsAnt[nCnt1,nDF2BASSEG] <> cBasSeg
												lBasSeg := .T.																																																		
											EndIf
											
										EndIf											
									EndIf
									//Ponto de entrada para não alterar os produtos,
									//caso esteja sendo enviado da tela de EDI. 
									If lTM05APRD
										lAtPrdUsr := ExecBlock("TM05APRD",.F.,.F., aColsPrd[nCnt] )
										If Valtype(lAtPrdUsr) != "L"
											lAtPrdUsr := .T.
										EndIf
									EndIf
									If lAltProd .Or. lAtPrdUsr .Or. lEmb .Or. lQtdVol .Or. lQtdUni .Or. lPeso .Or. lPesoM3 .Or. lValMer .Or. lBasSeg  
										RecLock("DF2",.F.)
									Else
										DF2->(DbSetOrder(1)) //DF2_FILIAL+DF2_NUMAGE+DF2_ITEAGE+DF2_CODPRO
										If !DF2->(MsSeek(xFilial("DF2")+M->DF0_NUMAGE+aColsPrd[nCnt,1]+cProduto)) .Or. (lTM05APRD .And. !lAtPrdUsr)
											RecLock("DF2",.T.)
											DF2->DF2_FILIAL := xFilial("DF2")
											DF2->DF2_NUMAGE := M->DF0_NUMAGE
											DF2->DF2_ITEAGE := aColsPrd[nCnt,1]
										Else
											RecLock("DF2",.F.)
										EndIf
									EndIf

									For nCnt2 := 1 To Len(aHeader)
										If aHeader[nCnt2,10] != 'V'
											DF2->(FieldPut(FieldPos(aHeader[nCnt2,2]),GDFieldGet(aHeader[nCnt2,2],nCnt1)))
										EndIf
									Next nCnt2
									DF2->(MsUnLock())

									If lTMF05GR2
										ExecBlock("TMF05GR2",.F.,.F.,nOpcx)
									EndIf

								EndIf
							EndIf
						Else
							If nPasso == 1
								If !lCotacao
									//-- Verifica se o Produto do Item do Agendamento foi alterado, para excluir registro correto.
									If nOpcx == 4 .And. nCnt1 <= Len(aColsAnt)
										If aColsAnt[nCnt1,1] <> aCols[nCnt1][nDF2CODPRO]
											cProduto := aColsAnt[nCnt1,1]
										EndIf
									EndIf
									//-- Exclui produtos por agendamento
									DF2->(DbSetOrder(1)) //DF2_FILIAL+DF2_NUMAGE+DF2_ITEAGE+DF2_CODPRO
									If	DF2->(MsSeek(xFilial("DF2")+M->DF0_NUMAGE+aColsPrd[nCnt,1]+cProduto))
										RecLock("DF2",.F.)
										DF2->(DbDelete())
										MsUnLock()
									EndIf
									//-- Exclui Valor Informado por produto
									DF3->(DbSetOrder(1))
									If	DF3->(MsSeek(xFilial("DF3")+M->DF0_NUMAGE+aColsPrd[nCnt,1]+cProduto))
										While DF3->(!Eof()) .And. DF3->DF3_FILIAL + DF3->DF3_NUMAGE + DF3->DF3_ITEAGE + DF3->DF3_CODPRO == ;
											xFilial("DF3") + M->DF0_NUMAGE + aColsPrd[nCnt,1] + cProduto
											RecLock("DF3",.F.)
											DF3->(DbDelete())
											MsUnLock()
											DF3->(DbSkip())
										EndDo
									EndIf
									//-- Exclui Cubagem por Produto
									DF4->(DbSetOrder(1))
									If	DF4->(MsSeek(xFilial("DF4")+M->DF0_NUMAGE+aColsPrd[nCnt,1]+cProduto))
										While DF4->(!Eof()) .And. DF4->DF4_FILIAL + DF4->DF4_NUMAGE + DF4->DF4_ITEAGE + DF4->DF4_CODPRO == ;
											xFilial("DF4") + M->DF0_NUMAGE + aColsPrd[nCnt,1] + cProduto
											RecLock("DF4",.F.)
											DF4->(DbDelete())
											MsUnLock()
											DF4->(DbSkip())
										EndDo
									EndIf
									AAdd( aDelPrd, aColsPrd[nCnt,1]+cProduto )
								EndIf
							EndIf
						EndIf
					Next nPasso
				Next nCnt1
			Next nCnt

			//-- Valor Informado por Agendamento
			For nCnt := 1 To Len(aColsVInf)
				aHeader := AClone(aColsVInf[nCnt,4])
				aCols   := AClone(aColsVInf[nCnt,3])
				nPosDELET  	:= Len(aHeader)+1 //Posicao da coluna da GetDados que indica se o item estah deletado
				nDF3CODPAS 	:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF3_CODPAS" 	}) // Posicao do campo "DF3_CODPAS"
				nDF3VALOR 	:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF3_VALOR" 	}) // Posicao do campo "DF3_VALOR"
				ASort( aCols,,, { | x, y | x[Len(aHeader)+1] > y[Len(aHeader)+1] } )
				For nCnt1 := 1 To Len(aCols)
					//-- Verifica se o Item do Agendamento ou o Produto nao foi marcado como deletado
					If !aCols[nCnt1][nPosDELET] .And. Ascan( aDelItem, { |x| x == aColsVInf[nCnt,1] } ) == 0 .And. ;
						Ascan( aDelPrd, { |x| x == aColsVInf[nCnt,1]+aColsVInf[nCnt,2] } ) == 0
						If !Empty(aCols[nCnt1][nDF3CODPAS]) .And. !Empty(aCols[nCnt1][nDF3VALOR])
							DF3->(DbSetOrder(1))
							If !DF3->(MsSeek(xFilial("DF3")+M->DF0_NUMAGE+aColsVInf[nCnt,1]+aColsVInf[nCnt,2]+aCols[nCnt1][nDF3CODPAS]))
								RecLock("DF3",.T.)
								DF3->DF3_FILIAL := xFilial("DF3")
								DF3->DF3_NUMAGE := M->DF0_NUMAGE
								DF3->DF3_ITEAGE := aColsVInf[nCnt,1]
								DF3->DF3_CODPRO := aColsVInf[nCnt,2]
							Else
								RecLock("DF3",.F.)
							EndIf
							For nCnt2 := 1 To Len(aHeader)
								If aHeader[nCnt2,10] != 'V'
									DF3->(FieldPut(FieldPos(aHeader[nCnt2,2]),GDFieldGet(aHeader[nCnt2,2],nCnt1)))
								EndIf
							Next nCnt2
							DF3->(MsUnLock())
						EndIf
					Else
						If !lCotacao
							//-- Apaga valor informado por agendamento
							DF3->(DbSetOrder(1))
							If DF3->(MsSeek(xFilial("DF3")+M->DF0_NUMAGE+aColsVInf[nCnt,1]+aColsVInf[nCnt,2]+aCols[nCnt1][nDF3CODPAS]))
								RecLock("DF3",.F.)
								DF3->(DbDelete())
								MsUnLock()
							EndIf
						EndIf
					EndIf
				Next nCnt1
			Next nCnt

			//-- Cubagem por Agendamento
			For nCnt := 1 To Len(aColsPM3)
				aHeader := AClone(aColsPM3[nCnt,4])
				aCols   := AClone(aColsPM3[nCnt,3])
				nPosDELET  	:= Len(aHeader)+1 //Posicao da coluna da GetDados que indica se o item estah deletado
				nDF4ITEM 	:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF4_ITEM" 	}) // Posicao do campo "DF4_ITEM"
				For nCnt1 := 1 To Len(aCols)
					//-- Verifica se o Item do Agendamento ou o Produto nao foi marcado como deletado
					If !aCols[nCnt1][nPosDELET] .And. Ascan( aDelItem, { |x| x == aColsPM3[nCnt,1] } ) == 0 .And. ;
						Ascan( aDelPrd, { |x| x == aColsPM3[nCnt,1]+aColsPM3[nCnt,2] } ) == 0
						If !Empty(aCols[nCnt1][nDF4ITEM])
							DF4->(DbSetOrder(1))
							If !DF4->(MsSeek(xFilial("DF4")+M->DF0_NUMAGE+aColsPM3[nCnt,1]+aColsPM3[nCnt,2]+aCols[nCnt1][nDF4ITEM]))
								RecLock("DF4",.T.)
								DF4->DF4_FILIAL := xFilial("DF4")
								DF4->DF4_NUMAGE := M->DF0_NUMAGE
								DF4->DF4_ITEAGE := aColsPM3[nCnt,1]
								DF4->DF4_CODPRO := aColsPM3[nCnt,2]
							Else
								RecLock("DF4",.F.)
							EndIf
							For nCnt2 := 1 To Len(aHeader)
								If aHeader[nCnt2,10] != 'V'
									DF4->(FieldPut(FieldPos(aHeader[nCnt2,2]),GDFieldGet(aHeader[nCnt2,2],nCnt1)))
								EndIf
							Next nCnt2
							DF4->(MsUnLock())
						EndIf
					Else
						If !lCotacao
							//-- Apaga cubagem por agendamento
							DF4->(DbSetOrder(1))
							If DF4->(MsSeek(xFilial("DF4")+M->DF0_NUMAGE+aColsPM3[nCnt,1]+aColsPM3[nCnt,2]+aCols[nCnt1][nDF4ITEM]))
								RecLock("DF4",.F.)
								DF4->(DbDelete())
								MsUnLock()
							EndIf
						EndIf
					EndIf
				Next nCnt1
			Next nCnt

			//-- Tipos de Veiculos por Agendamento
			For nCnt := 1 To Len(aColsTip)
				aHeader := AClone(aColsTip[nCnt,3])
				aCols   := AClone(aColsTip[nCnt,2])
				nPosDELET  	:= Len(aHeader)+1 //Posicao da coluna da GetDados que indica se o item estah deletado
				nDF5TIPVEI 	:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF5_TIPVEI" 	}) // Posicao do campo "DF5_TIPVEI"
				nDF5ITEM 	:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF5_ITEM" 	}) // Posicao do campo "DF5_ITEM"
				ASort( aCols,,, { | x, y | x[Len(aHeader)+1] > y[Len(aHeader)+1] } )
				For nCnt1 := 1 To Len(aCols)
					//-- Verifica se o Item do Agendamento nao foi marcado como deletado
					If !aCols[nCnt1][nPosDELET] .And. Ascan( aDelItem, { |x| x == aColsTip[nCnt,1] } ) == 0
						If !Empty(aCols[nCnt1][nDF5TIPVEI])
							DF5->(DbSetOrder(1))
							If !DF5->(MsSeek(xFilial("DF5")+M->DF0_NUMAGE+aColsTip[nCnt,1]+aCols[nCnt1][nDF5ITEM]))
								RecLock("DF5",.T.)
								DF5->DF5_FILIAL := xFilial("DF5")
								DF5->DF5_NUMAGE := M->DF0_NUMAGE
								DF5->DF5_ITEAGE := aColsTip[nCnt,1]
							Else
								RecLock("DF5",.F.)
							EndIf
							For nCnt2 := 1 To Len(aHeader)
								If aHeader[nCnt2,10] != 'V'
									DF5->(FieldPut(FieldPos(aHeader[nCnt2,2]),GDFieldGet(aHeader[nCnt2,2],nCnt1)))
								EndIf
							Next nCnt2
							DF5->(MsUnLock())
						EndIf
					Else
						If !lCotacao
							//-- Exclui tipos de veiculos por agendamento
							DF5->(DbSetOrder(1))
							If DF5->(MsSeek(xFilial("DF5")+M->DF0_NUMAGE+aColsTip[nCnt,1]+aCols[nCnt1][nDF5ITEM]))
								RecLock("DF5",.F.)
								DF5->(DbDelete())
								MsUnLock()
							EndIf
						EndIf
					EndIf
				Next nCnt1
			Next nCnt
		EndIf
		
		DF0->(DbSetOrder(1))
		If nOpcx == 4 .OR. (nOpcx == 3 .AND. !DF0->(MsSeek(xFilial("DF0")+M->DF0_NUMAGE))) // Incluir ou Alterar
			RecLock('DF0',nOpcx==3)
			For nI := 1 TO FCount()
				If !( FieldName(nI) $ cNoFields )
					If FieldName(nI) == 'DF0_FILIAL'
						FieldPut(nI,xFilial("DF0"))
					Else
						If Type('M->'+FieldName(nI)) <> 'U'
							FieldPut(nI,M->&(Eval(bCampo,nI)))
						EndIf
					EndIf
				EndIf
			Next nI
			If lEncAgd // -- Encerra o agendamento
				DF0->DF0_STATUS := StrZero(4,Len(DF0->DF0_STATUS)) //-- Encerrado
			Else
				DF0->DF0_QTDCON := nQtdConf
				If (nQtdConf + nTotCan) < M->DF0_QTDITE .And. M->DF0_STATUS == StrZero(2,Len(DF0->DF0_STATUS)) //-- Confirmado
					DF0->DF0_STATUS := StrZero(1,Len(DF0->DF0_STATUS)) //-- A Confirmar
				ElseIf (nQtdConf + nTotCan) == M->DF0_QTDITE .And. M->DF0_STATUS == StrZero(1,Len(DF0->DF0_STATUS)) //-- A Confirmar
					DF0->DF0_STATUS := StrZero(2,Len(DF0->DF0_STATUS)) //-- Confirmado
				ElseIf Len(aDelItem) > 0 // Caso algun(s) iten(s) tenha(m) sido excluido(s)
					DF0->DF0_STATUS := TMSF05Stat(DF0->DF0_FILIAL, DF0->DF0_NUMAGE)  //-- Atualiza status
				EndIf
			EndIf
			If Type('M->DF0_OBS') != 'U' //--Nao chamo MSMM se o campo estiver fora de uso
				If !Empty(M->DF0_OBS)
					MSMM(DF0->DF0_CODOBS,,,M->DF0_OBS,1,,,"DF0","DF0_CODOBS")
				EndIf
			EndIf
			MsUnLock()

			If lTMF05GR3
				ExecBlock("TMF05GR3",.F.,.F.,nOpcx)
			EndIf

		ElseIf nOpcx == 5 // Cancelamento
			If nQtdCanc > 0
				RecLock('DF0',.F.)
				If nQtdCanc == M->DF0_QTDITE
					DF0->DF0_STATUS := StrZero(9,Len(DF0->DF0_STATUS)) //-- Cancelado
					DF0->DF0_QTDCON := 0 // Cancelou todos os Agendamentos
				Else
					If nQtdOk > 0
						DF0->DF0_QTDCON := nQtdOk // Gravou a Qtde de Agendamentos Validos
					EndIf
				EndIf
				MsUnLock()
			EndIf
		ElseIf nOpcx == 6 //-- Confirmacao
			RecLock('DF0',.F.)
			DF0->DF0_STATUS := M->DF0_STATUS
			DF0->DF0_QTDCON := nQtdConf
			If (nQtdConf + nTotCan) == M->DF0_QTDITE .And. M->DF0_STATUS == StrZero(1,Len(DF0->DF0_STATUS)) //-- A Confirmar
				DF0->DF0_STATUS := StrZero(2,Len(DF0->DF0_STATUS)) //-- Confirmado
			EndIf
			MsUnLock()
		EndIf
	End Transaction

EndIf

// Se gerou um novo numero para o agendamento
If (nOpcx == 3 .Or. nOpcx == 7) .And. lGerNum
	Help('',1,'TMSAF0523',, STR0073 + cNumAge,5,1)	//-- "O novo código do agendamento será : "
EndIf

If lTMF05GR4
	ExecBlock("TMF05GR4",.F.,.F.,nOpcx)
EndIf


Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05Ver³ Autor ³ Eduardo de Souza      ³ Data ³ 18/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao colocada no X3_RELACAO dos campos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Ver(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Nome do Campo                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Ver(cCampo)

Local cRet     := ''
Default cCampo := ''

//-- Inicializador padrao qdo nao for inclusao de uma nova linha.
If !Inclui .And. ( n <= DF0->DF0_QTDITE )
	If cCampo == 'DF0_END'
		If !Empty(DF0->DF0_SEQEND)
			cRet := Posicione("DUL",3,xFilial("DUL")+DF0->DF0_CODSOL+DF0->DF0_SEQEND,"DUL_END")
		Else
			cRet := Posicione("DUE",1,xFilial("DUE")+DF0->DF0_CODSOL,"DUE_END")
		EndIf

	ElseIf cCampo == 'DF0_BAIRRO'
		If !Empty(DF0->DF0_SEQEND)
			cRet := Posicione("DUL",3,xFilial("DUL")+DF0->DF0_CODSOL+DF0->DF0_SEQEND,"DUL_BAIRRO")
		Else
			cRet := Posicione("DUE",1,xFilial("DUE")+DF0->DF0_CODSOL,"DUE_BAIRRO")
		EndIf

	ElseIf cCampo == 'DF0_MUN'
		If !Empty(DF0->DF0_SEQEND)
			cRet := Posicione("DUL",3,xFilial("DUL")+DF0->DF0_CODSOL+DF0->DF0_SEQEND,"DUL_MUN")
		Else
			cRet := Posicione("DUE",1,xFilial("DUE")+DF0->DF0_CODSOL,"DUE_MUN")
		EndIf

	ElseIf cCampo == 'DF0_EST'
		If !Empty(DF0->DF0_SEQEND)
			cRet := Posicione("DUL",3,xFilial("DUL")+DF0->DF0_CODSOL+DF0->DF0_SEQEND,"DUL_EST")
		Else
			cRet := Posicione("DUE",1,xFilial("DUE")+DF0->DF0_CODSOL,"DUE_EST")
		EndIf

	ElseIf cCampo == 'DF0_CEP'
		If !Empty(DF0->DF0_SEQEND)
			cRet := Posicione("DUL",3,xFilial("DUL")+DF0->DF0_CODSOL+DF0->DF0_SEQEND,"DUL_CEP")
		Else
			cRet := Posicione("DUE",1,xFilial("DUE")+DF0->DF0_CODSOL,"DUE_CEP")
		EndIf

	//-- Itens do Agendamento
	ElseIf cCampo == 'DF1_END'
		If !Empty(DF1->DF1_SQEREM)
			cRet := Posicione("DUL",2,xFilial("DUL")+DF1->DF1_CLIREM+DF1->DF1_LOJREM+DF1->DF1_SQEREM,"DUL_END")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1")+DF1->DF1_CLIREM+DF1->DF1_LOJREM,"A1_END")
		EndIf

	ElseIf cCampo == 'DF1_BAIRRO'
		If !Empty(DF1->DF1_SQEREM)
			cRet := Posicione("DUL",2,xFilial("DUL")+DF1->DF1_CLIREM+DF1->DF1_LOJREM+DF1->DF1_SQEREM,"DUL_BAIRRO")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1")+DF1->DF1_CLIREM+DF1->DF1_LOJREM,"A1_BAIRRO")
		EndIf

	ElseIf cCampo == 'DF1_MUN'
		If !Empty(DF1->DF1_SQEREM)
			cRet := Posicione("DUL",2,xFilial("DUL")+DF1->DF1_CLIREM+DF1->DF1_LOJREM+DF1->DF1_SQEREM,"DUL_MUN")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1")+DF1->DF1_CLIREM+DF1->DF1_LOJREM,"A1_MUN")
		EndIf

	ElseIf cCampo == 'DF1_EST'
		If !Empty(DF1->DF1_SQEREM)
			cRet := Posicione("DUL",2,xFilial("DUL")+DF1->DF1_CLIREM+DF1->DF1_LOJREM+DF1->DF1_SQEREM,"DUL_EST")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1")+DF1->DF1_CLIREM+DF1->DF1_LOJREM,"A1_EST")
		EndIf

	ElseIf cCampo == 'DF1_CEP'
		If !Empty(DF1->DF1_SQEREM)
			cRet := Posicione("DUL",2,xFilial("DUL")+DF1->DF1_CLIREM+DF1->DF1_LOJREM+DF1->DF1_SQEREM,"DUL_CEP")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1")+DF1->DF1_CLIREM+DF1->DF1_LOJREM,"A1_CEP")
		EndIf

	ElseIf cCampo == 'DF1_DESTPT'
		If !Empty(GDFieldGet("DF1_TIPTRA",n))
			cRet := TMSValField("DF1_TIPTRA",.F.,"DC5_DESTPT")
		EndIf

	ElseIf cCampo == 'DF1_ENDDES'
		If !Empty(DF1->DF1_SQEDES)
			cRet := Posicione("DUL",2,xFilial("DUL")+DF1->DF1_CLIDES+DF1->DF1_LOJDES+DF1->DF1_SQEDES,"DUL_END")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1")+DF1->DF1_CLIDES+DF1->DF1_LOJDES,"A1_END")
		EndIf

	ElseIf cCampo == 'DF1_BAIDES'
		If !Empty(DF1->DF1_SQEDES)
			cRet := Posicione("DUL",2,xFilial("DUL")+DF1->DF1_CLIDES+DF1->DF1_LOJDES+DF1->DF1_SQEDES,"DUL_BAIRRO")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1")+DF1->DF1_CLIDES+DF1->DF1_LOJDES,"A1_BAIRRO")
		EndIf

	ElseIf cCampo == 'DF1_MUNDES'
		If !Empty(DF1->DF1_SQEDES)
			cRet := Posicione("DUL",2,xFilial("DUL")+DF1->DF1_CLIDES+DF1->DF1_LOJDES+DF1->DF1_SQEDES,"DUL_MUN")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1")+DF1->DF1_CLIDES+DF1->DF1_LOJDES,"A1_MUN")
		EndIf

	ElseIf cCampo == 'DF1_ESTDES'
		If !Empty(DF1->DF1_SQEDES)
			cRet := Posicione("DUL",2,xFilial("DUL")+DF1->DF1_CLIDES+DF1->DF1_LOJDES+DF1->DF1_SQEDES,"DUL_EST")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1")+DF1->DF1_CLIDES+DF1->DF1_LOJDES,"A1_EST")
		EndIf

	ElseIf cCampo == 'DF1_CEPDES'
		If !Empty(DF1->DF1_SQEDES)
			cRet := Posicione("DUL",2,xFilial("DUL")+DF1->DF1_CLIDES+DF1->DF1_LOJDES+DF1->DF1_SQEDES,"DUL_CEP")
		Else
			cRet := Posicione("SA1",1,xFilial("SA1")+DF1->DF1_CLIDES+DF1->DF1_LOJDES,"A1_CEP")
		EndIf

	ElseIf cCampo == 'DF1_REGORI'
		cRet := Posicione("DUY",1,xFilial("DUY")+DF1->DF1_CDRORI,"DUY_DESCRI")	
	
	ElseIf cCampo == 'DF1_DESDOC'
		If !Empty(GDFieldGet("DF1_DOCTMS",n))
			cRet := TMSValField("DF1_DOCTMS",.F.,"DF1_DESDOC")
		EndIf
	EndIf
Else
	If cCampo == 'DF1_REGORI'
		cRet := Posicione("DUY",1,xFilial("DUY")+cGrpVen,"DUY_DESCRI")
	EndIf
EndIf

//-- Tipo de Retorno
If Empty(cRet)
	cRet := CriaVar(cCampo,.F.)
EndIf

Return( cRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsAF05Obr³ Autor ³ Eduardo de Souza      ³ Data ³ 21/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica dados obrigatorios                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Obr(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±³          ³ lValFlds - Somente Validação De Campos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsAF05Obr(nOpcx,lCopia,lAtuRat,lValFlds)

Local lRet       := .F.
Local cObs       := ''
Local nCnt       := 0
Local lTMF05TOK  := ExistBlock('TMF05TOK')
Local nRatAnt    := 0
Local nRateio    := 0
Local aAreaDC5   := DC5->(GetArea())
Local nTotPeso   := 0
Local nQtdItem   := 0
Local nTotValMer := 0
Local nTotQtdVol := 0
Local nTotPesoM3 := 0
Local lCalcula   := .F.
Local lStatEnc   := .F.
Local nPosDELET  := Len(aHeader)+1 //Posicao da coluna da GetDados que indica se o item estah deletado
Local nDF1STACOL := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_STACOL" }) // Posicao do campo DF1_STACOL
Local nDF1PESO 	 := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_PESO" 	}) // Posicao do campo DF1_PESO
Local nDF1VALMER := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_VALMER" }) // Posicao do campo DF1_VALMER
Local nDF1QTDVOL := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_QTDVOL" }) // Posicao do campo DF1_QTDVOL
Local nDF1PesoM3 := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_PESOM3" }) // Posicao do campo DF1_PESOM3
Local nDF1SRVCOL := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_SRVCOL" }) // Posicao do campo DF1_SRVCOL
Local nDF1TIPTRA := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_TIPTRA" }) // Posicao do campo DF1_TIPTRA
Local nDF1DATCAN := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_DATCAN" }) // Posicao do campo DF1_DATCAN
Local nDF1FILORI := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_FILORI" }) // Posicao do campo DF1_FILORI
Local nDF1NUMCOT := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_NUMCOT" }) // Posicao do campo DF1_NUMCOT
Local nDF1OBSCAN := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_OBSCAN" }) // Posicao do campo DF1_OBSCAN
Local nDF1CLIDEV := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_CLIDEV" }) // Posicao do campo DF1_CLIDEV
Local nDF1LOJDEV := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_LOJDEV" }) // Posicao do campo DF1_LOJDEV
Local nDF1TIPFRE := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_TIPFRE" }) // Posicao do campo DF1_TIPFRE
Local nDF1CODNEG := aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF1_CODNEG" }) // Posicao do campo DF1_CODNEG

Default lCopia   := .F.
Default lAtuRat  := .F.
Default lValFlds := .F.

//-- Ponto de Entrada utilizado para validar o botao(OK).
If lTMF05TOK 
	lRet := ExecBlock("TMF05TOK",.F.,.F.,{nOpcx})
	If ValType(lRet) <> 'L'
		lRet := .F.
	EndIf
	If !lRet
		Return( .F. )
	EndIf
EndIf

//-- Verifica se os servicos sao rateados.
If ( nOpcx == 3 .Or. nOpcx == 4 )
	DbSelectArea("DC5")
	DC5->( DbSetOrder(1) )
	For nCnt := 1 To Len(aCols)
		If !aCols[nCnt][nPosDELET]
			DC5->( MsSeek(xFilial("DC5")+aCols[nCnt][nDF1SRVCOL]) )
			nRateio := Val(DC5->DC5_TIPRAT)
			If aCols[nCnt][nDF1STACOL] <> StrZero(9,Len(aCols[nCnt][nDF1STACOL]))
				nTotPeso   += aCols[nCnt][nDF1PESO]
				nTotValMer += aCols[nCnt][nDF1VALMER]
				nTotQtdVol += aCols[nCnt][nDF1QTDVOL]
				nTotPesoM3 += aCols[nCnt][nDF1PesoM3]
				
				nQtdItem   += 1
				If ( nCnt <> 1 ) .And. ( nRatAnt <> nRateio )
					Help(' ', 1, 'TMSAF0528') //"Todos os serviços deverão ser preenchindos com o mesmo tipo de rateio !"
					Return( .F. )
				EndIf
			EndIf
			If lAtuRat
				//--Se for rateio apos o cancelamento,
				//--se um item estiver encerrado nao faco rateio novamente
				If nRateio <> 0 .And. aCols[nCnt][nDF1STACOL] == StrZero(5,Len(aCols[nCnt][nDF1STACOL])) //--Encerrado
					lStatEnc := .T.
				EndIf
			EndIf
			nRatAnt := nRateio
			
			//-- valida se os campos DF2_QTDVOL,DF2_VOLUME,DF2_PESO,DF2_VALMER,DF2_PESOM3 foram digitados para quando 
            //-- o campo DF1_SRVCOL estiver preenchido e for coleta automática ou herda valor para não ocorrer 
            //-- problemas no calculo de frete devido  a ausência destes campos.	
	        If !Empty(GDFieldGet("DF1_SRVCOL",nCnt))
        		If aCols[nCnt][nDF1PESO  ] == 0 .Or.;
        		   aCols[nCnt][nDF1VALMER] == 0 .Or.;
        		   aCols[nCnt][nDF1QTDVOL] == 0        		   
                   
                   //Help(' ', 1, 'TMSAF0540','','O campo ' + aHeader[GDFieldPos('DF1_SRVCOL')][1] + ' foi preenchido na linha do item ' + GDFieldGet('DF1_ITEAGE',nCnt)   + ' e por isso e obrigatorio informar os campos Peso,Peso M3,Volume e Valor na tela de Produtos do Agendamento.')
                   AVISO('TMSAF0540',;
                         'O campo ' + aHeader[GDFieldPos('DF1_SRVCOL')][1] + ' foi preenchido na linha do item ' + GDFieldGet('DF1_ITEAGE',nCnt)   + ' e por isso e obrigatorio informar os campos Peso,Peso M3,Volume e Valor na tela de Produtos do Agendamento.',;
                         {"VOLTAR"},2)
                   Return( .F. )
                   
		        EndIf 
		    EndIf 
		EndIf // fecha o If !aCols[nCnt][nPosDELET]
	Next nCnt 
	If nRateio <> 0
		If lAtuRat //--Se for novo rateio apos o cancelamento de itens
			If !lStatEnc //--Se nao tiver itens encerrados pode ratear novamente
				lCalcula := .T.
			Else
				//--Se um item estiver encerrado nao pode mais ratear
				lCalcula := .F.
				For nCnt := 1 To Len(aCols)
					If !aCols[nCnt][nPosDELET] .And. aCols[nCnt][nDF1STACOL] == StrZero(9,Len(aCols[nCnt][nDF1STACOL]))
						TmsA040Can(aCols[nCnt][nDF1FILORI],aCols[nCnt][nDF1NUMCOT],dDataBase)
						GdFieldPut("DF1_VLRINF",0,nCnt)
						GdFieldPut("DF1_NUMCOT",CriaVar("DF1_NUMCOT",.F.),nCnt)
						GdFieldPut("DF1_VALFRE",0,nCnt)
						GdFieldPut("DF1_VALIMP",0,nCnt)
						GdFieldPut("DF1_VALTOT",0,nCnt)
					EndIf
				Next nCnt
				Help(' ', 1, 'TMSAF0534') //"Existem itens encerrados no Agendamento, o rateio nao sera realizado"
			EndIf
		ElseIf DF0->DF0_STATUS <> StrZero(3,Len(DF0->DF0_STATUS))
			//--No primeiro calculo, de acordo com o servico sempre rateia
			lCalcula := .T.
		EndIf
	EndIf
EndIf

//-- Verifica se existe todos itens estao deletados.
For nCnt := 1 To Len(aCols)
	If !aCols[nCnt][nPosDELET]
		lRet := .T.
		Exit
	EndIf
Next nCnt

If lRet
	If nOpcx == 5 // Cancelamento

		For nCnt := 1 To Len(aCols)
			If aCols[nCnt][nDF1STACOL] == StrZero(9,Len(DF1->DF1_STACOL)) .And. ;
				!aCols[nCnt][nPosDELET] .And. Empty( aCols[nCnt][nDF1DATCAN] ) //data de cancelamento em branco
				Help('',1,'OBRIGAT2',,RetTitle('DF0_DATCAN'),04,01) //"Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
				lRet := .F.
				Exit
			EndIf
			cObs := aCols[nCnt][nDF1OBSCAN]
			If aCols[nCnt][nDF1STACOL] == StrZero(9,Len(DF1->DF1_STACOL)) .And. ;
				!aCols[nCnt][nPosDELET] .And. Empty(StrTran(cObs,CHR(13)+CHR(10),''))
				Help('',1,'OBRIGAT2',,RetTitle('DF0_OBSCAN'),04,01) //"Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
				lRet := .F.
				Exit
			EndIf

		Next nCnt

	ElseIf nOpcx == 6 // Confirmacao
		For nCnt := 1 To Len(aCols)
			If !aCols[nCnt][nPosDELET] .And. aCols[nCnt][nDF1STACOL] == StrZero(2,Len(DF0->DF0_STATUS)) //-- Confirmado
				//-- Verifica se o Tipo de Transporte foi informado
				If Empty(aCols[nCnt][nDF1TIPTRA])
					Help('',1,'OBRIGAT2',,RetTitle('DF1_TIPTRA'),04,01) //"Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nCnt
	ElseIf nOpcx == 3
		If M->DF0_STATUS == StrZero(2,Len(DF0->DF0_STATUS)) //-- Confirmado
			For nCnt := 1 To Len(aCols)
				If !aCols[nCnt][nPosDELET]
					//-- Verifica se o Tipo de Transporte foi informado
					If Empty(aCols[nCnt][nDF1TIPTRA])
						Help('',1,'OBRIGAT2',,RetTitle('DF1_TIPTRA'),04,01) //"Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
						lRet := .F.
						Exit
					EndIf
					//-- Verifica se o Codigo da Negociacao foi informado
/*					If Empty(aCols[nCnt][nDF1CODNEG])
						Help('',1,'OBRIGAT2',,RetTitle('DF1_CODNEG'),04,01) //"Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
						lRet := .F.
						Exit
					EndIf*/
				EndIf
			Next nCnt
		EndIf
	EndIf
	If lCopia .Or. nOpcx == 3 .Or. nOpcx == 4
		//-- Verificando se o Servico ainda esta valido-Copiando um Agendamento
		For nCnt := 1 To Len(aCols)
			If !Empty(aCols[nCnt][nDF1CLIDEV])
				aContrt := TMSContrat( aCols[nCnt][nDF1CLIDEV],aCols[nCnt][nDF1LOJDEV],,aCols[nCnt][nDF1SRVCOL],.F.,aCols[nCnt][nDF1TIPFRE],,,,,,,,,,,,,,,,aCols[nCnt][nDF1CODNEG])
				If Empty(aContrt)
					Help('',1,'TMSAF0533') //-- Cliente com contrato de vigencia vencida","Verifique !!!
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nCnt
	EndIf
Else
	//-- Para inclusao/alteracao, devera ter pelo menos um item nao deletado.
	Help('',1,'OBRIGAT2') //"Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
EndIf

//-- Verifica se devera atualizar a sequencia do agendamento.
If lRet .And. lAtuSeqAgend
	If ValType(MV_PAR03) == "N" .And. MV_PAR03 == 1
		TMSAF05SQE(nOpcx,.T.)
	Else
		Help(' ', 1, 'TMSAF0524') //"Foi alterado o tipo da distancia ou o tipo do inicio da distancia do agendamento, favor atualizar a sequencia atraves da tecla <F7>"
		lRet := .F.
	EndIf
EndIf

If lRet .And. !(lValFlds)
	//-- Geracao de cotacao de frete com rateio.
	If lCalcula
		MsgRun( STR0065 , STR0066 ,{|| TmAF05GCot(nTotPeso,nTotValMer,nTotQtdVol,nQtdItem,lAtuRat) } ) // "Gerando cotacão de frete..." ### "Aguarde..."
	EndIf
EndIf

RestArea(aAreaDC5)

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05Leg³ Autor ³ Eduardo de Souza      ³ Data ³ 21/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a Legenda do Agendamento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Leg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSF05Leg( aStatus, cTitulo )

If ValType( cTitulo ) <> 'C'
	cTitulo := STR0001 // 'Agendamento'
EndIf

If	ValType( aStatus ) <> 'A'
	aStatus := {}
	AAdd( aStatus, {'BR_LARANJA' , STR0012 } ) // 'A Confirmar'
	AAdd( aStatus, {'BR_VERDE'   , STR0013 } ) // 'Confirmado'
	AAdd( aStatus, {'BR_VERMELHO', STR0014 } ) // 'Em Processo'
	AAdd( aStatus, {'BR_AZUL'    , STR0015 } ) // 'Encerrado'
	AAdd( aStatus, {'BR_AMARELO' , STR0067 } ) // 'Planejado'
	AAdd( aStatus, {'BR_PRETO'   , STR0016 } ) // 'Cancelado'
EndIf

BrwLegenda( cTitulo, STR0017, aStatus ) //'Status'

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05Vld³ Autor ³ Eduardo de Souza      ³ Data ³ 08/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes do Agendamento                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Controle da Exbicao das Observacoes do cliente.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Vld(lExibe)
Local cCampo     := ReadVar()
Local lRet       := .T.
Local nSeek      := 0
Local aItContrat := {}
Local nCnt       := 0
Local cCodCli    := ''
Local cLojCli    := ''
Local aArea      := {}
Local aContrat   := {}
Local nFatCubado := 0
Local nValMetro3 := 0
Local cOptPesCub := ""
Local nPos       := 0
Local lAgeCotSol := SuperGetMV("MV_AGECOTS",.F.,.F.) //-- Define se a cotacao devera ser realizada sempre para o solicitante.
Local nPosDistIV := Iif( Type("aHeader") <> "U", GDFieldPos("DF1_DISTIV"), 0 )
Local aAreaSA1   := {}
Local lIdentDoc  := DF1->(ColumnPos("DF1_DOCTMS")) > 0

Local cArqSrvCol := ""
Local cArqCliDev := ""
Local cArqTipTra := ""
Local cArqTipFre := ""
Local cArqCdrOri := ""
Local cArqCdrDes := ""
Local cArqCodNeg := ""
Local lAtuDist   := .F.

Default lExibe   := .T.
If valtype("cNumCot") == "U"
   Default cNumCot  := ""									//-- Compatibilização TMSAF74
EndIf
If valtype("cStaCol") == "N"
   Default cStaCol  := StrZero(1,Len(DF1->DF1_STACOL))	    //-- Compatibilização TMSAF74
EndIf 
If valtype("lAtuCot") == "L"
   Default lAtuCot  := .F.									//-- Compatibilização TMSAF74
EndIf

Private cDocTms := ""

//Agendamento
If  cCampo $ 'M->DF0_CODSOL'
	//-- Exibe as observacoes do cliente.
	If !Empty(M->DF0_CODSOL)
		DUE->(DbSetOrder(1))
		If	DUE->(MsSeek(xFilial("DUE")+M->DF0_CODSOL))
			cCodCli := DUE->DUE_CODCLI
			cLojCli := DUE->DUE_LOJCLI

			SA1->(DbSetOrder(1))
			lRet := SA1->(MsSeek(xFilial('SA1')+cCodCli+If(!Empty(cLojCli), cLojCli, "")))
			If lRet .And. SA1->A1_MSBLQL == "1"
            	lRet:= .F.          
            	ApMsgInfo(STR0074) //"Cliente selecionado está inativo"
        	Endif
			If lRet .And. !Empty(cCodCli) .And. !Empty(cLojCli)
				TMSA050ObsCli(cCodCli, cLojCli)
				TMSAF05Sug(3)
			EndIf
		EndIf
	EndIf

ElseIf	cCampo $ 'M->DF0_STATUS'
	If	Inclui .Or. lConfirma
		If !( M->DF0_STATUS $ "1;2" )
			Help(" ",1,"TMSAF0505") // Somente podera ser informado o status 'A Confirmar' ou 'Confirmado'.
			lRet := .F.
		EndIf
	ElseIf	lCancela
		If !( M->DF0_STATUS $ "9" )
			Help(" ",1,"TMSAF0522") // Somente podera ser informado o status 'Cancelado'.
			lRet := .F.
		EndIf
	EndIf

//-- Inicio do calculo da distancia
ElseIf	cCampo == "M->DF0_INIDIS"
	If cIniDis <> M->DF0_INIDIS
		cIniDis := M->DF0_INIDIS
		lAtuSeqAgend := .T.
	EndIf

//-- Tipo de calculo da distancia
ElseIf	cCampo == "M->DF0_TIPDIS"
	If	cTipDis <> M->DF0_TIPDIS
		cTipDis := M->DF0_TIPDIS
		lAtuSeqAgend := .T.
	EndIf

	//-- Ajuste dos campos referente ao calculo da Distancia Ida/Volta
	If	nPosDistIV <> 0
		If M->DF0_TIPDIS == '1'
			For nCnt := 1 To Len(aCols)
				aCols[nCnt,nPosDistIV] := '3'
			Next
			M->DF0_DISTIV := '2'

		ElseIf M->DF0_TIPDIS == '2'
			For nCnt := 1 To Len(aCols)
				aCols[nCnt,nPosDistIV] := '2'
			Next
			M->DF0_DISTIV := '3'
		EndIf
		oGetDAge:Refresh()
	EndIf

//-- Itens do Agendamento
//-- Local de Coleta
ElseIf	cCampo $ 'M->DF1_LOCCOL'


	If	lRet .And. !lAgeCotSol
		//-- Zera o Servico para digitacao
		GDFieldPut("DF1_SERVIC",CriaVar("DF1_SERVIC",.F.),n)
		If	GDFieldPos("DF1_DESSER") > 0
			GDFieldPut("DF1_DESSER",CriaVar("DF1_DESSER",.F.),n)
		EndIf
		//-- Verifica se devera ser atualizada a cotacao
		If !lAtuCot .And. !Empty(GDFieldGet("DF1_NUMCOT",n)) .And. M->DF1_LOCCOL <> GDFieldGet("DF1_LOCCOL",n)
			lAtuCot := .T.
		EndIf
	EndIf

	If lRet
		If	GDFieldGet("DF1_SELORI",n) == StrZero(3, Len(DF1->DF1_SELORI)) //-- Local Coleta
			GDFieldPut("DF1_CDRORI",TMF05OriC(GDFieldGet("DF1_CLIREM",n),GDFieldGet("DF1_LOJREM",n),GDFieldGet("DF1_SQEREM",n),M->DF1_LOCCOL),n)
			GDFieldPut("DF1_REGORI",Posicione("DUY",1,xFilial("DUY")+GDFieldGet("DF1_CDRORI",n),"DUY_DESCRI"),n)
		EndIf
	EndIf

//-- Status da Coleta
ElseIf cCampo $ 'M->DF1_STACOL'
	If lConfirma
		If !( M->DF1_STACOL $ "1;2" )
			Help(" ",1,"TMSAF0505") // Somente podera ser informado o status 'A Confirmar' ou 'Confirmado'.
			lRet := .F.
		EndIf
	ElseIf lCancela
		If !( M->DF1_STACOL $ "9" )
			Help(" ",1,"TMSAF0522") // Somente podera ser informado o status 'Cancelado'.
			lRet := .F.
		EndIf
	EndIf

//-- Filial Origem
ElseIf	cCampo $ 'M->DF1_FILORI'
	If	GDFieldGet("DF1_SELORI",n) == StrZero(1, Len(DF1->DF1_SELORI)) //-- Transportadora
		GDFieldPut("DF1_CDRORI",Posicione("SX6",1,M->DF1_FILORI+"MV_CDRORI","X6_CONTEUD"),n)
		GDFieldPut("DF1_REGORI",Posicione("DUY",1,xFilial("DUY")+GDFieldGet("DF1_CDRORI",n),"DUY_DESCRI"),n)
	EndIf
	//-- Verifica se devera ser atualizada a cotacao
	If !lAtuCot .And. !Empty(GDFieldGet("DF1_NUMCOT",n)) .And. M->DF1_FILORI <> GDFieldGet("DF1_FILORI",n)
		lAtuCot := .T.
	EndIf

//-- Remetente/Destinatario/Devedor
ElseIf	cCampo $ 'M->DF1_CLIREM|M->DF1_LOJREM|M->DF1_CLIDES|M->DF1_LOJDES|M->DF1_CLIDEV|M->DF1_LOJDEV'
	If	cCampo $ 'M->DF1_CLIREM|M->DF1_CLIDES|M->DF1_CLIDEV'
		lExibe := .T. //-- Volta o valor para true para mostrar apenas uma vez a Observacao do cliente somente na validacao do Codigo do Cliente
		cCodCli := &cCampo
		If	cCampo == "M->DF1_CLIREM" 
			cLojCli := GdFieldGet('DF1_LOJREM')
		ElseIf	cCampo == "M->DF1_CLIDES"
			cLojCli := GdFieldGet('DF1_LOJDES')
		ElseIf	cCampo == "M->DF1_CLIDEV"
			cLojCli := GdFieldGet('DF1_LOJDEV')
		EndIf
	ElseIf	cCampo $ 'M->DF1_LOJREM|M->DF1_LOJDES|M->DF1_LOJDEV'
		cLojCli := &cCampo
		If	cCampo == "M->DF1_LOJREM"
			cCodCli := GdFieldGet('DF1_CLIREM')
		ElseIf	cCampo == "M->DF1_LOJDES"
			cCodCli := GdFieldGet('DF1_CLIDES')
		Else
			cCodCli := GdFieldGet('DF1_CLIDEV')
		EndIf
	EndIf

	//--Posiciona no cadastro do cliente:
	SA1->(DbSetOrder(1))
	lRet := SA1->(MsSeek(xFilial('SA1')+cCodCli+If(!Empty(cLojCli), cLojCli, "")))
	If lRet
		If	cCampo $ "M->DF1_CLIREM|M->DF1_CLIDES|M->DF1_CLIDEV" .And. Empty(cLojCli)
			cLojCli := SA1->A1_LOJA
			If	cCampo == "M->DF1_CLIREM"
				GdFieldPut('DF1_LOJREM', cLojCli)
			ElseIf	cCampo == "M->DF1_CLIDES"
				GdFieldPut('DF1_LOJDES', cLojCli)
			Else
				GdFieldPut('DF1_LOJDEV', cLojCli)
			EndIf
		EndIf

		lRet := TMSVldCli(cCodCli, cLojCli)
		
		If lRet .And. SA1->A1_MSBLQL == "1"
            lRet:= .F.          
            ApMsgInfo(STR0074) //"Cliente selecionado está inativo"
        Endif
	Else
		HELP(" ",1,"REGNOIS")
	EndIf

	If	lRet
		//--Atualizacoes apos a validacao:
		aAreaSA1 := SA1->(GetArea())

		If	cCampo $ "M->DF1_CLIREM|M->DF1_LOJREM|M->DF1_CLIDES|M->DF1_LOJDES"
			If	cCampo $ "M->DF1_CLIREM|M->DF1_LOJREM"
				//--Atualiza Regiao Origem do Cliente Rementente
				If	GDFieldGet("DF1_SELORI") == StrZero(2, Len(DF1->DF1_SELORI)) //--Cliente Rementente
					GDFieldPut("DF1_CDRORI",SA1->A1_CDRDES,n)
					GDFieldPut("DF1_REGORI",Posicione("DUY",1,xFilial("DUY")+GDFieldGet("DF1_CDRORI",n),"DUY_DESCRI"),n)
				ElseIf	GDFieldGet("DF1_SELORI",n) == StrZero(3, Len(DF1->DF1_SELORI)) //-- Local Coleta
					GDFieldPut("DF1_CDRORI",TMF05OriC(GDFieldGet("DF1_CLIREM",n),GDFieldGet("DF1_LOJREM",n)),n)
					GDFieldPut("DF1_REGORI",Posicione("DUY",1,xFilial("DUY")+GDFieldGet("DF1_CDRORI",n),"DUY_DESCRI"),n)
				EndIf
			EndIf

			//--Atualiza o cliente devedor do frete:
			If	GDFieldGet("DF1_TIPFRE") == StrZero(1,Len(DF1->DF1_TIPFRE)) //--CIF
				GDFieldPut("DF1_CLIDEV", If(cCampo == "M->DF1_CLIREM", M->DF1_CLIREM, GdFieldGet("DF1_CLIREM")))
				GDFieldPut("DF1_LOJDEV", If(cCampo == "M->DF1_LOJREM", M->DF1_LOJREM, GdFieldGet("DF1_LOJREM")))
			ElseIf	GDFieldGet("DF1_TIPFRE") == StrZero(2,Len(DF1->DF1_TIPFRE)) //--FOB
				GDFieldPut("DF1_CLIDEV", If(cCampo == "M->DF1_CLIDES", M->DF1_CLIDES, GdFieldGet("DF1_CLIDES")))
				GDFieldPut("DF1_LOJDEV", If(cCampo == "M->DF1_LOJDES", M->DF1_LOJDES, GdFieldGet("DF1_LOJDES")))
			EndIf
			SA1->(DbSeek(xFilial('SA1')+GDFieldGet('DF1_CLIDEV')+GdFieldGet('DF1_LOJDEV')))
			GDFieldPut("DF1_NOMDEV", SA1->A1_NOME)

			//--Atualiza a Regiao Destino
			If	GdFieldPos("DF1_REGDES") > 0 .And. cCampo $ "M->DF1_CLIDES|M->DF1_LOJDES"
				If	cCampo == "M->DF1_CLIDES"
					SA1->(MsSeek(xFilial('SA1')+M->DF1_CLIDES+GdFieldGet('DF1_LOJDES')))
				Else
					SA1->(MsSeek(xFilial('SA1')+GdFieldGet('DF1_CLIDES')+M->DF1_LOJDES))
				EndIf
				GDFieldPut("DF1_CDRDES",SA1->A1_CDRDES,n)
				GDFieldPut("DF1_REGDES", Posicione("DUY",1,xFilial("DUY")+SA1->A1_CDRDES,"DUY_DESCRI"))
			EndIf
		EndIf

		
		aContrat := TMSContrat(Iif(cCampo == "M->DF1_CLIDEV",M->DF1_CLIDEV,GdFieldGet("DF1_CLIDEV")),;
							   Iif(cCampo == "M->DF1_LOJDEV",M->DF1_LOJDEV,GdFieldGet("DF1_LOJDEV")),;
							   ,GdFieldGet("DF1_SERVIC"),.F.,GdFieldGet("DF1_TIPFRE"),,,,,,,,,,,,,,,,GdFieldGet("DF1_CODNEG"))
		If !Empty(aContrat)
			GDFieldPut("DF1_NCONTR", aContrat[1,1])
		EndIf		
		RestArea(aAreaSA1)
	EndIf

	If lRet
		//-- Verifica se devera ser atualizada a cotacao
		If !lAtuCot .And. !Empty(GDFieldGet("DF1_NUMCOT",n))
			lAtuCot :=	(cCampo == 'M->DF1_CLIREM' .And. M->DF1_CLIREM <> GdFieldGet("DF1_CLIREM")) .Or.;
						(cCampo == 'M->DF1_LOJREM' .And. M->DF1_LOJREM <> GdFieldGet("DF1_LOJREM")) .Or.;
						(cCampo == 'M->DF1_CLIDES' .And. M->DF1_CLIDES <> GdFieldGet("DF1_CLIDES")) .Or.;
						(cCampo == 'M->DF1_LOJDES' .And. M->DF1_LOJDES <> GdFieldGet("DF1_LOJDES")) .Or.;
						(cCampo == 'M->DF1_CLIDEV' .And. M->DF1_CLIDEV <> GdFieldGet("DF1_CLIDEV")) .Or.;
						(cCampo == 'M->DF1_LOJDEV' .And. M->DF1_LOJDEV <> GdFieldGet("DF1_LOJDEV"))
		EndIf
		//-- Verifica se devera ser zerado o campo distancia (DF1_DISTAN)
		If !Empty(GDFieldGet("DF1_DISTAN",n))
			lAtuDist := (cCampo == 'M->DF1_CLIREM' .And. M->DF1_CLIREM <> GdFieldGet("DF1_CLIREM")) .Or.;
			            (cCampo == 'M->DF1_LOJREM' .And. M->DF1_LOJREM <> GdFieldGet("DF1_LOJREM")) .Or.;
			            (cCampo == 'M->DF1_CLIDES' .And. M->DF1_CLIDES <> GdFieldGet("DF1_CLIDES")) .Or.;
			            (cCampo == 'M->DF1_LOJDES' .And. M->DF1_LOJDES <> GdFieldGet("DF1_LOJDES"))
		EndIf
	EndIf
	
	//-- Zera o campo distancia (DF1_DISTAN)
	If lAtuDist
		GDFieldPut("DF1_DISTAN", CriaVar("DF1_DISTAN"), n)
	EndIf

	//--Exibe as observacoes do cliente.
	If lExibe .And. !Empty(cCodCli) .And. !Empty(cLojCli)
		TMSA050ObsCli(cCodCli, cLojCli)
	EndIf

	//-- Valida tipo de documento
	If lIdentDoc .And. !Empty(cCodCli) .And. !Empty(cLojCli) .And. !Empty(GDFieldGet("DF1_CDRDES",n)).And. !Empty(GdFieldGet("DF1_CDRORI",n)) .AND. !Empty(GDFieldGet("DF1_SERVIC",n))
		DC5->(dbSetOrder(1)) //DC5_FILIAL+DC5_SERVIC
		DC5->(MsSeek(xFilial("DC5")+ GDFieldGet("DF1_SERVIC",n)))
		If	Empty(DC5->DC5_DOCTMS) 
			cDocTms := TMSTipDoc(GDFieldGet("DF1_CDRORI",n),GDFieldGet("DF1_CDRDES",n))
		Else
			cDocTms := DC5->DC5_DOCTMS
		EndIf
				
		DUI->( DbSetOrder( 1 ) )
		If	DUI->( ! MsSeek( xFilial('DUI') + cDocTms ) )
			Help( ' ', 1, 'TMSA20009',, STR0056 + cDocTms,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
			lRet := .F.
		Else
			GDFieldPut('DF1_DOCTMS',	cDocTms,n)
			GDFieldPut( 'DF1_DESDOC', TMSValField('cDocTms',.F.,"DF1_DESDOC",.F.,.F.),n)
		EndIf
	ElseIf lIdentDoc .AND. Empty(GDFieldGet("DF1_SERVIC",n))
		GDFieldPut('DF1_DOCTMS', CriaVar("DF1_DOCTMS",.F.),n)
		GDFieldPut('DF1_DESDOC', CriaVar("DF1_DESDOC",.F.),n)
	EndIf 
//-- Sequencia do Remetente
ElseIf cCampo $ 'M->DF1_SQEREM'

	If !Empty(M->DF1_SQEREM)
		aArea := DUE->(GetArea())
		DUE->(DbSetOrder(3))
		If !DUE->(MsSeek(xFilial("DUE")+GDFieldGet("DF1_CLIREM",n)+GDFieldGet("DF1_LOJREM",n)))
			Help(" ",1,"TMSAF0503") //-- Cliente nao esta cadastrado como Solicitante.
			lRet := .F.
		Else
			DUL->(DbSetOrder(2))
			If !DUL->(MsSeek(xFilial("DUL")+DUE->DUE_CODCLI+DUE->DUE_LOJCLI+M->DF1_SQEREM))
				Help(" ",1,"TMSAF0504") //-- Sequencia de endereco nao encontrada para o Cliente.
				lRet := .F.
			Else
				If GDFieldGet("DF1_SELORI",n) == StrZero(2, Len(DF1->DF1_SELORI)) //-- Remetente
					GDFieldPut("DF1_CDRORI",DUL->DUL_CDRDES,n)
					GDFieldPut("DF1_REGORI",Posicione("DUY",1,xFilial("DUY")+DUL->DUL_CDRDES,"DUY_DESCRI"),n)
				ElseIf GDFieldGet("DF1_SELORI",n) == StrZero(3, Len(DF1->DF1_SELORI)) //-- Local Coleta
					GDFieldPut("DF1_CDRORI",TMF05OriC(GDFieldGet("DF1_CLIREM",n),GDFieldGet("DF1_LOJREM",n),M->DF1_SQEREM),n)
					GDFieldPut("DF1_REGORI",Posicione("DUY",1,xFilial("DUY")+GDFieldGet("DF1_CDRORI",n),"DUY_DESCRI"),n)
				EndIf
			EndIf
		EndIf
		RestArea( aArea )
	Else
		RunTrigger(2,n,,oGetDAge,"DF1_CLIREM")
		//-- Atualiza Regiao Origem do Cliente Rementente
		If GDFieldGet("DF1_SELORI",n) == StrZero(2, Len(DF1->DF1_SELORI)) //-- Cliente Rementente
			SA1->(DbSetOrder(1))
			SA1->(MsSeek(xFilial("SA1")+GDFieldGet("DF1_CLIREM",n)+GDFieldGet("DF1_LOJREM",n)))
			GDFieldPut("DF1_CDRORI",SA1->A1_CDRDES,n)
			GDFieldPut("DF1_REGORI",Posicione("DUY",1,xFilial("DUY")+GDFieldGet("DF1_CDRORI",n),"DUY_DESCRI"),n)
		ElseIf GDFieldGet("DF1_SELORI",n) == StrZero(3, Len(DF1->DF1_SELORI)) //-- Local Coleta
			GDFieldPut("DF1_CDRORI",TMF05OriC(GDFieldGet("DF1_CLIREM",n),GDFieldGet("DF1_LOJREM",n),M->DF1_SQEREM),n)
			GDFieldPut("DF1_REGORI",Posicione("DUY",1,xFilial("DUY")+GDFieldGet("DF1_CDRORI",n),"DUY_DESCRI"),n)
		EndIf
	EndIf

	//-- Atualiza o Tipo de Documento do cliente caso seja incluso uma seq. end. para o Remetente
	If lIdentDoc .And. !Empty(GDFieldGet("DF1_CDRORI",n)) .And. !Empty(GDFieldGet("DF1_CDRDES",n)) .AND. !Empty(GDFieldGet("DF1_SERVIC",n))
		DC5->(dbSetOrder(1)) //DC5_FILIAL+DC5_SERVIC
		DC5->(MsSeek(xFilial("DC5")+ GDFieldGet("DF1_SERVIC",n)))
		If	Empty(DC5->DC5_DOCTMS) 
			cDocTms := TMSTipDoc(GDFieldGet("DF1_CDRORI",n),GDFieldGet("DF1_CDRDES",n))
		Else
			cDocTms := DC5->DC5_DOCTMS
		EndIf
		
		DUI->( DbSetOrder( 1 ) )
		If	DUI->( ! MsSeek( xFilial('DUI') + cDocTms ) )
			Help( ' ', 1, 'TMSA20009',, STR0056 + cDocTms ,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
			lRet := .F.
		Else
			GDFieldPut('DF1_DOCTMS',	cDocTms,n)
			GDFieldPut( 'DF1_DESDOC', TMSValField('cDocTms',.F.,"DF1_DESDOC",.F.,.F.),n)	
		EndIf
		
	ElseIf lIdentDoc .AND. Empty(GDFieldGet("DF1_SERVIC",n))
		GDFieldPut('DF1_DOCTMS', CriaVar("DF1_DOCTMS",.F.),n)
		GDFieldPut('DF1_DESDOC', CriaVar("DF1_DESDOC",.F.),n)	
	EndIf
//-- Tipo de Transporte
ElseIf cCampo $ 'M->DF1_TIPTRA'

	If GDFieldPos('DF1_DESTPT') > 0
		GDFieldPut( 'DF1_DESTPT', TMSValField("M->DF1_TIPTRA",.F.,"DC5_DESTPT"),n)
	EndIf

	//-- Verifica se devera ser atualizada a cotacao
	If !lAtuCot .And. !Empty(GDFieldGet("DF1_NUMCOT",n)) .And. M->DF1_TIPTRA <> GDFieldGet("DF1_TIPTRA",n)
		lAtuCot := .T.
	EndIf

//-- Seleciona Origem
ElseIf cCampo $ 'M->DF1_SELORI'
	If M->DF1_SELORI == StrZero(3, Len(DF1->DF1_SELORI)) .Or. ; //-- Local Coleta
		( lRet := Pertence("12") .And. TMSSelOri( "DF1", M->DF1_SELORI, aCols[n,GDFieldPos('DF1_CLIREM')], aCols[n,GDFieldPos('DF1_LOJREM')], aCols[n,GDFieldPos('DF1_SQEREM')]) )
		If M->DF1_SELORI == StrZero(1, Len(DF1->DF1_SELORI)) //-- Transportadora
			GDFieldPut("DF1_CDRORI",PadR(Posicione("SX6",1,GDFieldGet("DF1_FILORI",n)+"MV_CDRORI","X6_CONTEUD"),Len(DUY->DUY_GRPVEN)),n)
			GDFieldPut("DF1_REGORI",Posicione("DUY",1,xFilial("DUY")+GDFieldGet("DF1_CDRORI",n),"DUY_DESCRI"),n)
		ElseIf M->DF1_SELORI == StrZero(3, Len(DF1->DF1_SELORI)) //-- Local Coleta
			GDFieldPut("DF1_CDRORI",TMF05OriC(GDFieldGet("DF1_CLIREM",n),GDFieldGet("DF1_LOJREM",n),GDFieldGet("DF1_SQEREM",n)),n)
			GDFieldPut("DF1_REGORI",Posicione("DUY",1,xFilial("DUY")+GDFieldGet("DF1_CDRORI",n),"DUY_DESCRI"),n)
			lRet := !Empty(GDFieldGet("DF1_CDRORI",n))
		EndIf
		//-- Verifica se devera ser atualizada a cotacao
		If !lAtuCot .And. !Empty(GDFieldGet("DF1_NUMCOT",n)) .And. M->DF1_SELORI <> GDFieldGet("DF1_SELORI",n)
			lAtuCot := .T.
		EndIf
	EndIf

	 	//-- Atualiza o tipo de documento caso seja alterado a seleção da região
	 	If lIdentDoc .And. !Empty(GdFieldGet("DF1_CDRORI",n)) .And. !Empty(GDFieldGet("DF1_CDRDES",n)) .AND. !Empty(GDFieldGet("DF1_SERVIC",n))
		 	DC5->(dbSetOrder(1)) //DC5_FILIAL+DC5_SERVIC
			DC5->(MsSeek(xFilial("DC5")+ GDFieldGet("DF1_SERVIC",n)))
			If	Empty(DC5->DC5_DOCTMS) 
				cDocTms := TMSTipDoc(GDFieldGet("DF1_CDRORI",n),GDFieldGet("DF1_CDRDES",n))
			Else
				cDocTms := DC5->DC5_DOCTMS
			EndIf

			DUI->( DbSetOrder( 1 ) )
			If	DUI->( ! MsSeek( xFilial('DUI') + cDocTms ) )
				Help( ' ', 1, 'TMSA20009',, STR0056 + cDocTms ,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
				lRet := .F.
			Else
				GDFieldPut('DF1_DOCTMS',  cDocTms,n)
				GDFieldPut( 'DF1_DESDOC', TMSValField('cDocTms',.F.,"DF1_DESDOC",.F.,.F.),n)
			EndIf
			
		ElseIf lIdentDoc .AND. Empty(GDFieldGet("DF1_SERVIC",n))
			GDFieldPut('DF1_DOCTMS', CriaVar("DF1_DOCTMS",.F.),n)
			GDFieldPut('DF1_DESDOC', CriaVar("DF1_DESDOC",.F.),n)
		EndIf
//-- Hora Previsao da Coleta
ElseIf cCampo $ 'M->DF1_DATPRC;M->DF1_HORPRC'

	If !Vazio()
		If lRet .And. GdFieldGet("DF1_STACOL",n) == StrZero(5,Len(DF1->DF1_STACOL)) //-- Encerrado
			Help(" ",1,"TMSAF0536") // O Agendamento encontra-se encerrado.
			lRet := .F.
		EndIf

		If lRet
			If cCampo $ 'M->DF1_DATPRC'
				If M->DF1_DATPRC < dDataBase
					lRet := .F.
				EndIf

				If !Empty(GDFieldGet("DF1_HORPRC",n))
					If lRet := ValDatHor(M->DF1_DATPRC,GDFieldGet("DF1_HORPRC",n),dDataBase,StrTran(Left(Time(),5),':',''),,,,.F.)
						If !Empty(GDFieldGet("DF1_DATPRE",n)) .And. !Empty(GDFieldGet("DF1_HORPRE",n))
							lRet := ValDatHor(GDFieldGet("DF1_DATPRE",n),GDFieldGet("DF1_HORPRE",n),M->DF1_DATPRC,GDFieldGet("DF1_HORPRC",n),,,,.F.)
						EndIf
					EndIf
				EndIf
			Else
				If lRet := AtVldHora(M->DF1_HORPRC)
					If lRet := ValDatHor(GDFieldGet("DF1_DATPRC",n),M->DF1_HORPRC,dDataBase,StrTran(Left(Time(),5),':',''),,,,.F.)
						If !Empty(GDFieldGet("DF1_DATPRE",n)) .And. !Empty(GDFieldGet("DF1_HORPRE",n))
							lRet := ValDatHor(GDFieldGet("DF1_DATPRE",n),GDFieldGet("DF1_HORPRE",n),GDFieldGet("DF1_DATPRC",n),M->DF1_HORPRC,,,,.F.)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf !INCLUI .And. GdFieldGet("DF1_STACOL",n) == StrZero(5,Len(DF1->DF1_STACOL)) //-- Encerrado
		Help(" ",1,"TMSAF0536") // O Agendamento encontra-se encerrado.
		lRet := .F.
	EndIf

//-- Hora Previsao da Coleta
ElseIf cCampo $ 'M->DF1_DATPRE,M->DF1_HORPRE'

	If !Vazio()
		If lRet .And. GdFieldGet("DF1_STAENT",n) == StrZero(5,Len(DF1->DF1_STAENT)) //-- Encerrado
			Help(" ",1,"TMSAF0536") // O Agendamento encontra-se encerrado.
			lRet := .F.
		EndIf

		If lRet
			If cCampo $ 'M->DF1_DATPRE'
				If M->DF1_DATPRE < dDataBase
					lRet := .F.
				EndIf
					
				If !Empty(GDFieldGet("DF1_HORPRE",n))
					If lRet := ValDatHor(M->DF1_DATPRE,GDFieldGet("DF1_HORPRE",n),dDataBase,StrTran(Left(Time(),5),':',''),,,,.F.)
						lRet := ValDatHor(M->DF1_DATPRE,GDFieldGet("DF1_HORPRE",n),GDFieldGet("DF1_DATPRC",n),GDFieldGet("DF1_HORPRC",n),,,,.F.)
					EndIf
				EndIf
			Else
				If lRet := ValDatHor(GDFieldGet("DF1_DATPRE",n),M->DF1_HORPRE,dDataBase,StrTran(Left(Time(),5),':',''),,,,.F.)
					lRet := AtVldHora(M->DF1_HORPRE) .And. ValDatHor(GDFieldGet("DF1_DATPRE",n),M->DF1_HORPRE,GDFieldGet("DF1_DATPRC",n),GDFieldGet("DF1_HORPRC",n),,,,.F.)	
				EndIf
			EndIf
		EndIf
	EndIf

//-- Sequencia Destinatario
ElseIf cCampo $ 'M->DF1_SQEDES'

	If !Empty(M->DF1_SQEDES)
		aArea := DUL->(GetArea())
		DUL->(DbSetOrder(2))
		If !DUL->(MsSeek(xFilial("DUL")+GDFieldGet("DF1_CLIDES",n)+GDFieldGet("DF1_LOJDES",n)+M->DF1_SQEDES))
			Help(" ",1,"TMSAF0504") //-- Sequencia de endereco nao encontrada para o Cliente.
			lRet := .F.
		Else
			GDFieldPut("DF1_CDRDES",DUL->DUL_CDRDES,n)
			GDFieldPut("DF1_REGDES",Posicione("DUY",1,xFilial("DUY")+DUL->DUL_CDRDES,"DUY_DESCRI"),n)
		EndIf
		RestArea( aArea )
	Else
		RunTrigger(2,n,,oGetDAge,"DF1_CLIDES")
		GDFieldPut("DF1_REGDES",Posicione("DUY",1,xFilial("DUY")+GDFieldGet("DF1_CDRDES",n),"DUY_DESCRI"),n)
	EndIf

	//-- Atualiza o Tipo de Documento do cliente com Seq. End. para o Destinatário
	If lIdentDoc .And. !Empty(GDFieldGet("DF1_CDRORI",n)) .And. !Empty(GDFieldGet("DF1_CDRDES",n)) .AND. !Empty(GDFieldGet("DF1_SERVIC",n))
		DC5->(dbSetOrder(1)) //DC5_FILIAL+DC5_SERVIC
		DC5->(MsSeek(xFilial("DC5")+ GDFieldGet("DF1_SERVIC",n)))
		If	Empty(DC5->DC5_DOCTMS) 
			cDocTms := TMSTipDoc(GDFieldGet("DF1_CDRORI",n),GDFieldGet("DF1_CDRDES",n))
		Else
			cDocTms := DC5->DC5_DOCTMS
		EndIf
				
		DUI->( DbSetOrder( 1 ) )
		If	DUI->( ! MsSeek( xFilial('DUI') + cDocTms ) )
			Help( ' ', 1, 'TMSA20009',, STR0056 + cDocTms ,5,1)	//-- Documento nao encontrado na configuracao de documentos (DUI) ### "Documento"
			lRet := .F.
		Else
			GDFieldPut('DF1_DOCTMS',	cDocTms,n)
			GDFieldPut( 'DF1_DESDOC', TMSValField('cDocTms',.F.,"DF1_DESDOC",.F.,.F.),n)	
		EndIf
		
	ElseIf lIdentDoc .AND. Empty(GDFieldGet("DF1_SERVIC",n))
		GDFieldPut('DF1_DOCTMS', CriaVar("DF1_DOCTMS",.F.),n)
		GDFieldPut('DF1_DESDOC', CriaVar("DF1_DESDOC",.F.),n)
	EndIf
//-- Tipo do Frete
ElseIf cCampo $ 'M->DF1_TIPFRE'
	If M->DF1_TIPFRE == StrZero(1,Len(DF1->DF1_TIPFRE)) //-- CIF
		GDFieldPut("DF1_CLIDEV",GDFieldGet("DF1_CLIREM",n),n)
		GDFieldPut("DF1_LOJDEV",GDFieldGet("DF1_LOJREM",n),n)
		GDFieldPut("DF1_NOMDEV",GDFieldGet("DF1_NOMREM",n),n)
	ElseIf M->DF1_TIPFRE == StrZero(2,Len(DF1->DF1_TIPFRE)) //-- FOB
		GDFieldPut("DF1_CLIDEV",GDFieldGet("DF1_CLIDES",n),n)
		GDFieldPut("DF1_LOJDEV",GDFieldGet("DF1_LOJDES",n),n)
		GDFieldPut("DF1_NOMDEV",GDFieldGet("DF1_NOMDES",n),n)
	EndIf
	If Empty(GDFieldGet("DF1_TIPFRE",n)) .And. !Empty(M->DF1_TIPFRE)
		GDFieldPut("DF1_TIPFRE",M->DF1_TIPFRE,n)
	Endif
	If !Empty(GDFieldGet("DF1_CODNEG",n)) .And. (M->DF1_TIPFRE != GDFieldGet("DF1_TIPFRE",n)) //| Valida se o campo DF1_TIPFRE foi alterado / corrige invalidação do serviço ao chamar cotação na tela de agendamento.
		GDFieldPut('DF1_SERVIC', CriaVar("DF1_SERVIC",.F.),n)
		GDFieldPut('DF1_DESSER', CriaVar("DF1_DESSER",.F.),n)
		GDFieldPut('DF1_CODNEG', CriaVar("DF1_CODNEG",.F.),n)
		GDFieldPut('DF1_DESNEG', CriaVar("DF1_DESNEG",.F.),n)
		GDFieldPut('DF1_SRVCOL', CriaVar("DF1_SRVCOL",.F.),n)
		GDFieldPut('DF1_DESCOL', CriaVar("DF1_DESCOL",.F.),n)
	EndIf
	//-- Verifica se devera ser atualizada a cotacao
	If !lAtuCot .And. !Empty(GDFieldGet("DF1_NUMCOT",n)) .And. M->DF1_TIPFRE <> GDFieldGet("DF1_TIPFRE",n)
		lAtuCot := .T.
	EndIf

	
	aContrat := TMSContrat(GdFieldGet("DF1_CLIDEV"),GdFieldGet("DF1_LOJDEV"),,GdFieldGet("DF1_SERVIC"),.F.,GdFieldGet("DF1_TIPFRE"),,,,,,,,,,,,,,,,GdFieldGet("DF1_CODNEG"))
	If !Empty(aContrat)
		GDFieldPut("DF1_NCONTR", aContrat[1,1])
	EndIf
	

ElseIf cCampo == 'M->DF1_SERVIC'
	If !Empty(M->DF1_SERVIC)
		//-- Valida o codigo do servico digitado.
		DC5->( DbSetOrder( 1 ) )
		If DC5->( ! MsSeek( xFilial('DC5') + M->DF1_SERVIC, .F. ) )
			Help(' ', 1, 'TMSA04013', , STR0011 + M->DF1_SERVIC , 4, 1 )	//-- Codigo do servico nao encontrado (DC5).  //'Servico: '
			lRet := .F.  
		ElseIf DC5->DC5_DOCTMS == '7' .Or. DC5->DC5_DOCTMS == '8' //Não permite a digitação dos serviços com complemento tipo "7=CTRC Reentrega" e "8=CTRC Complemento".		
			Help("",1,"TMSA05040") // Servico Invalido ...
			lRet := .F.
		ElseIf lIdentDoc .And. Empty(DC5->DC5_DOCTMS) .And. !Empty(GDFieldGet("DF1_CDRDES",n)) .AND. !Empty(M->DF1_SERVIC)
			cDocTms := TMSTipDoc(GDFieldGet("DF1_CDRORI",n),GDFieldGet("DF1_CDRDES",n))
		ElseIf lIdentDoc .And. !Empty(DC5->DC5_DOCTMS)
			cDocTms := DC5->DC5_DOCTMS
		ElseIf lIdentDoc .AND. Empty(M->DF1_SERVIC)
			cDocTms := CriaVar("DF1_DOCTMS",.F.)
		EndIf
		GDFieldPut('DF1_DOCTMS',	cDocTms,n)
		GDFieldPut( 'DF1_DESDOC', TMSValField('cDocTms',.F.,"DF1_DESDOC",.F.,.F.),n)
	
		If lRet 
			TMSPesqServ('DF1', GDFieldGet("DF1_CLIDEV",n), GDFieldGet("DF1_LOJDEV",n), StrZero(3,Len(DC5->DC5_SERTMS)),;
							GDFieldGet("DF1_TIPTRA",n), @aItContrat, .F., GDFieldGet("DF1_TIPFRE",n),,,,,,,,;
							GDFieldGet("DF1_CDRORI",n),GDFieldGet("DF1_CDRDES",n),,,,,,,,GDFieldGet("DF1_CODNEG",n))
	
			nSeek := Ascan(aItContrat, { |x| x[3] == &(ReadVar()) })
			If nSeek == 0
				Help('',1,"TMSA05040") // Servico Invalido ...
				Return( .F. )
			Else
				//-- Qdo mudar o servico, zera valor informado.
				If Inclui .And. ( nPos := Ascan( aColsVInf, { |x| x[1] == GDFieldGet("DF1_ITEAGE",n) } )) > 0
					If !Empty(aColsVInf[nPos,3]) .And. MsgYesNo(STR0049) //'Existe valor informado para a nota fiscal, deseja limpar o valor informado na mudanca do servico ?'
						aColsVInf[nPos,3] := {}
					EndIf
				EndIf
			EndIf
		EndIf
	
		//-- Posiciona configuracao de documentos para obter a Serie do Documento
		DUI->( DbSetOrder( 1 ) )
		If lIdentDoc
			If lRet .And. DUI->( ! MsSeek( xFilial('DUI') + GDFieldGet("DF1_DOCTMS",n) ) )
				Help( ' ', 1, 'TMSA20009',,STR0056 + ': ' + GDFieldGet("DF1_DOCTMS",n),5,1)	//"Documento nao encontrado na configuracao de documentos (DUI)"###"Documento: "
				lRet := .F.
				GDFieldPut('DF1_DOCTMS', CriaVar("DF1_DOCTMS",.F.),n)
				GDFieldPut('DF1_DESDOC', CriaVar("DF1_DESDOC",.F.),n)
			EndIf
		Else
			If lRet .And. DUI->( ! MsSeek( xFilial('DUI') + DC5->DC5_DOCTMS ) )
				Help( ' ', 1, 'TMSA20009',,STR0056 + ': ' + DC5->DC5_DOCTMS,5,1)	//"Documento nao encontrado na configuracao de documentos (DUI)"###"Documento: "
				lRet := .F.
			EndIf
		EndIf
	
		//-- Verifica se devera ser atualizada a cotacao
		If lRet .And. !lAtuCot .And. !Empty(GDFieldGet("DF1_NUMCOT",n)) .And. M->DF1_SERVIC <> GDFieldGet("DF1_SERVIC",n)
			lAtuCot := .T.
		EndIf

	ElseIf lIdentDoc 
		GDFieldPut('DF1_DOCTMS', CriaVar("DF1_DOCTMS",.F.),n)
		GDFieldPut('DF1_DESDOC', CriaVar("DF1_DESDOC",.F.),n)
	EndIf
	
ElseIf cCampo == "M->DF1_SRVCOL"
	
	If !Empty(M->DF1_SRVCOL)
		//-- Valida o codigo do servico digitado.
		DC5->( DbSetOrder( 1 ) )
		If DC5->( ! MsSeek( xFilial('DC5') + M->DF1_SRVCOL, .F. ) )
			Help(' ', 1, 'TMSA04013', , STR0011 + M->DF1_SRVCOL , 4, 1 )	//-- Codigo do servico nao encontrado (DC5).  //'Servico: '
			lRet := .F.
		EndIf
		If !Empty(M->DF1_SRVCOL)
			DC5->(DbSetOrder(1))
			If DC5->(DbSeek(xFilial('DC5')+M->DF1_SRVCOL)) 
				If DC5->DC5_SERTMS <> StrZero(1,Len(DC5->DC5_SERTMS)) .Or. DC5->DC5_CATSER <> '1'
					Help("",1,"TMSAF0539") //-- O Serviço selecionado não é de coleta. 
					lRet := .F.
				Endif	
			EndIf
		EndIf
		If lRet 
			TMSPesqServ('DF1', GDFieldGet("DF1_CLIDEV",n), GDFieldGet("DF1_LOJDEV",n), StrZero(1,Len(DC5->DC5_SERTMS)),;
							GDFieldGet("DF1_TIPTRA",n), @aItContrat, .F., GDFieldGet("DF1_TIPFRE",n),,,,,,,,;
							GDFieldGet("DF1_CDRORI",n),GDFieldGet("DF1_CDRDES",n),,,,,,,,GDFieldGet("DF1_CODNEG",n), cCampo )
	
			nSeek := Ascan(aItContrat, { |x| x[3] == &(ReadVar()) })
			If nSeek == 0
				Help('',1,"TMSA05040") // Servico Invalido ...
				Return( .F. )
			Else
				//-- Qdo mudar o servico, zera valor informado.
				If Inclui .And. ( nPos := Ascan( aColsVInf, { |x| x[1] == GDFieldGet("DF1_ITEAGE",n) } )) > 0
					If !Empty(aColsVInf[nPos,3]) .And. MsgYesNo(STR0049) //'Existe valor informado para a nota fiscal, deseja limpar o valor informado na mudanca do servico ?'
						aColsVInf[nPos,3] := {}
					EndIf
				EndIf
			EndIf
		EndIf
		If lRet
			GDFieldPut('DF1_DESCOL', Tabela("L4",M->DF1_SRVCOL,.F.),n)
		EndIf
	Else
		If !Empty(M->DT5_CODNEG)
			Help("",1,"TMSA46027") //-- Não é permitido que o serviço fique em branco.
			lRet := .F.
		EndIf
	EndIf
	
	
ElseIf cCampo == "M->DDD_SRVCOL"

	cArqSrvCol := M->DDD_SRVCOL
	cArqCliDev := M->DDD_CLIDEV
	cArqLojDev := M->DDD_LOJDEV
	cArqTipTra := M->DDD_TIPTRA
	cArqTipFre := M->DDD_TIPFRE
	cArqCdrOri := M->DDD_CDRORI
	cArqCdrDes := M->DDD_CDRDES
	cArqCodNeg := M->DDD_CODNEG

	If !Empty(cArqSrvCol)

		//-- Valida o codigo do servico digitado.
		DC5->( DbSetOrder( 1 ) )
		If DC5->( ! MsSeek( xFilial('DC5') + cArqSrvCol, .F. ) )
			Help(' ', 1, 'TMSA04013', , STR0011 + cArqSrvCol , 4, 1 )	//-- Codigo do servico nao encontrado (DC5).  //'Servico: '
			lRet := .F.
		Else
			If DC5->DC5_SERTMS <> StrZero(1,Len(DC5->DC5_SERTMS)) .Or. DC5->DC5_CATSER <> '1'
				Help("",1,"TMSAF0539") //-- O Serviço selecionado não é de coleta. 
				lRet := .F.
			Endif	
		EndIf

		If lRet 

			TMSPesqServ(	'DF1',;
							cArqCliDev,;
							cArqLojDev,;
							StrZero(1,Len(DC5->DC5_SERTMS)),;
							cArqTipTra,;
							@aItContrat,;
							.F.,;
							cArqTipFre,,,,,,,,;
							cArqCdrOri,;
							cArqCdrDes,,,,,,,,;
							cArqCodNeg,;
							cCampo )
	
			nSeek := Ascan(aItContrat, { |x| x[3] == &(ReadVar()) })

			If nSeek == 0
				Help('',1,"TMSA05040") // Servico Invalido ...
				Return( .F. )
			EndIf
		EndIf
	EndIf		

//-- Valor informado da cotacao
ElseIf cCampo == "M->DF1_VLRINF"
	lRet := TMSAF05Cot(.T.,M->DF1_VLRINF)

//-- Produtos por Agendamento
ElseIf cCampo == 'M->DF2_CODPRO'
	If !Inclui .And. !Empty(GDFieldGet('DF2_CODPRO',n)) .And. !lNovoItem
		If !Empty(cNumCot) .Or. cStaCol <> StrZero(1,Len(DF1->DF1_STACOL)) 
			lRet := .F.
			Help(" ",1,"TMSAF0517") //-- Codigo do produto nao podera ser alterado.
		EndIf
	EndIf

//-- Valor Informado
//-- Componente
ElseIf cCampo == 'M->DF3_CODPAS'

	If !Inclui .And. !Empty(GDFieldGet('DF3_CODPAS',n))
		lRet := .F.
		Help(" ",1,"TMSAF0520") //-- Codigo do componente nao podera ser alterado.
	EndIf

	If lRet
		aAreaDT3:=DT3->(GetArea())
		DT3->(DbSetOrder(1))
		If	DT3->(MsSeek(xFilial('DT3')+M->DF3_CODPAS))
			If	DT3->DT3_TIPFAI != StrZero(7,Len(DT3->DT3_TIPFAI))
				Help('',1,'TMSA04045')		//-- O campo 'Calcula Sobre' deste componente esta diferente de 'Valor Informado'
				RestArea(aAreaDT3)
				Return( .F. )
			EndIf
		Else
			Help('',1,'REGNOIS') //"Nao existe registro relacionado a este codigo"
			RestArea(aAreaDT3)
			Return( .F. )
		EndIf
		RestArea(aAreaDT3)
	EndIf

ElseIf cCampo== 'M->DF2_PESOM3'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o campo B5_PERCUB esteja preenchido, calcular o percentual a partir   ³
	//³do peso digitado e armazenar o valor obtido no campo DTC_PESOM3.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cOptPesCub := TmsPesCub(cCliCalC,cLojCalC)
	If Empty(cOptPesCub) .Or. cOptPesCub == '4'  // Peso cubado por M3
		Return( .F. )
	EndIf
	If cOptPesCub == '2'
		If !Empty(cCliCalC) // Peso Cubado == Nao
			Help("",1,'TMSA05036') // O Peso Cubado Nao podera ser Informado ... Esta Regra Foi definida no Perfil do Cliente de Calculo Informado
		EndIf
		Return( .F. )
	EndIf

ElseIf cCampo== 'M->DF2_METRO3'
	//-- Apos o preenchimento do campo DT4_METRO3, multiplicar o valor informado pelo fator de cubagem
	//-- do servico e gatilhar o resultado no campo DT4_PESOM3.
	If !Empty(cCliCalC) .And. !Empty(cLojCalC) .And. !Empty(cServic) .And. !Empty(cTipFre)
		aContrat   := TMSContrat(cCliCalC, cLojCalC,,cServic,,cTipFre,,,,,,,,,,,,,,,,cCodNeg)
		nFatCubado := If(Len(aContrat)>0,aContrat[1][2],0)
		If nFatCubado > 0
			nValMetro3 :=  M->DF2_METRO3 * nFatCubado
			GdFieldPut('DF2_PESOM3', nValMetro3, n)
		EndIf
	EndIf

ElseIf cCampo == "M->DF1_DATCAN"
	If M->DF1_DATCAN < dDataBase .Or. GdFieldGet("DF1_STACOL",n) <> StrZero(9,Len(DF1->DF1_STACOL)) //-- Cancelada
		lRet := .F.
	EndIf

ElseIf cCampo == "M->DF1_CODNEG"
	
	If !Empty(M->DF1_CODNEG)
		aContrat := TMSContrat(GDFieldGet("DF1_CLIDEV"),GDFieldGet("DF1_LOJDEV"),,,.F.,GDFieldGet("DF1_TIPFRE"),,,,,,,,,,,,,,,,M->DF1_CODNEG)
		If Empty(aContrat)
			Help("",1,'TMSAF0538') //-- Código da negociação e serviçoo não existem no contrato do cliente.
			lRet := .F.
		Else
			GdFieldPut('DF1_NCONTR', aContrat[1,1])
			If Empty(GDFieldGet("DF1_NUMCOT",n)) //| Quando há cotação os campos abaixo são atualizados pela rotina de seleção da cotação.
				GdFieldPut('DF1_SRVCOL',Space(TamSx3("DF1_SRVCOL")[1]))
				GdFieldPut('DF1_DESCOL',Space(TamSx3("DF1_DESCOL")[1]))
				GdFieldPut('DF1_SERVIC',Space(TamSx3("DF1_SERVIC")[1]))
				GdFieldPut('DF1_DESSER',Space(TamSx3("DF1_DESSER")[1]))
			EndIf
		Endif
	Else
		GdFieldPut('DF1_SRVCOL',Space(TamSx3("DF1_SRVCOL")[1]))
		GdFieldPut('DF1_DESCOL',Space(TamSx3("DF1_DESCOL")[1]))
		GdFieldPut('DF1_SERVIC',Space(TamSx3("DF1_SERVIC")[1]))
		GdFieldPut('DF1_DESSER',Space(TamSx3("DF1_DESSER")[1]))
	EndIf
	
EndIf

oDlg:Refresh()

If lTM05VLD
	lRet := ExecBlock("TM05VLD",.F.,.F.,{lRet,cCampo})
	If ValType(lRet) <> "L"
		lRet := .F.
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05Seq³ Autor ³ Eduardo de Souza      ³ Data ³ 08/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Sequencia de Enderecos (Remetente/Destinatario)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Seq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05  / TMSA050                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Seq()

Local cCampo   := ReadVar()
Local aAreaDUE := DUE->(GetArea())
Local cCodSol  := Replicate("Z",Len(DUE->DUE_CODSOL))
Local cCliente := Space(Len(SA1->A1_COD))
Local cLoja    := Space(Len(SA1->A1_LOJA))
Local lRet     := .T.
Local oView     := NIL	// Recebe a View Ativa
Local oModel	  := NIL
Local oViewObj  := NIL
Local aCurrSel  := {}
Local nLinha    := 0
Local cAliastab := "DT5"

If cCampo == "M->DF1_SQEREM" // Remetente
	cCliente := GDFieldGet("DF1_CLIREM",n)
	cLoja    := GDFieldGet("DF1_LOJREM",n)
ElseIf cCampo == "M->DF1_SQEDES" // Destinatario
	cCliente := GDFieldGet("DF1_CLIDES",n)
	cLoja    := GDFieldGet("DF1_LOJDES",n)
ElseIf cCampo == "M->DTC_SQEDES" // Destinatario
	cCliente := M->DTC_CLIDES
	cLoja    := M->DTC_LOJDES
ElseIf cCampo == "M->DE5_SEQEND" //Destinatario
	cCliente := Posicione("SA1",3,xFilial("SA1")+M->DE5_CGCDES,"A1_COD")
	cLoja    := SA1->A1_LOJA
ElseIf cCampo == "M->DDO_SEQDE" //Destinatario
	cCliente := M->DDO_CLIDE 
	cLoja	  := M->DDO_LOJDE	
ElseIf cCampo == "M->DF0_SEQEND"
	cAliastab:= "DF0"
	cCodSol  := M->DF0_CODSOL	
ElseIf cCampo == "M->DDO_SEQATE" //Destinatario
	cCliente := M->DDO_CLIATE 
	cLoja	  := M->DDO_LOJATE
ElseIf cCampo == "M->DDJ_SEQEND" .OR.  cCampo == "M->DJF_SEQEND" //Destinatario
	oView		 := FwViewActive()
	oModel		 := FwModelActive()
	aCurrSel 	 := oView:GetCurrentSelect()
	oViewObj 	 := oView:GetViewObj(aCurrSel[1])
	oModelGrid	 := oModel:GetModel( oViewObj[6] ) //grid do folder
	nLinha		 := oModelGrid:GetLine() 
	
	If cCampo == "M->DDJ_SEQEND"
		cCliente	 := oModelGrid:GetValue("DDJ_CLIENT",nLinha)
		cLoja		 := oModelGrid:GetValue("DDJ_LOJA",nLinha)
	ElseIf  cCampo == "M->DJF_SEQEND"
		cCliente	 := oModelGrid:GetValue("DJF_CLIENT",nLinha)
		cLoja		 := oModelGrid:GetValue("DJF_LOJA",nLinha)
	EndIf
	
EndIf                
lRet := TmsEndSol(cAliastab,cCodSol,cCliente,cLoja)

RestArea( aAreaDUE )

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05LOk³ Autor ³ Eduardo de Souza      ³ Data ³ 23/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da Linha GetDados                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05LOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05LOk(nOpcao)

Local lRet     := .T.
Local nCnt     := 0
Local nPosDist := 0
Local aCpoSkip := {}

If !GdDeleted(n)
	If lTMF05LOk
		lRet := ExecBlock("TMF05LOK",.F.,.F.,{nOpcao})
		If ValType(lRet) <> "L"
			lRet := .F.
		EndIf
	EndIf
	If lRet
		If nOpcao == 1 //-- Itens do Agendamento
			If lAtuCot .And. Val(Posicione("DC5",1,xFilial("DC5")+GdFieldGet("DF1_SERVIC"),"DC5_TIPRAT")) == 0
				Help(" ",1,"TMSAF0514") // Informacoes referente a cotacao foram alteradas, execute a cotacao para continuar.
				lRet := .F.
			EndIf			
			nPosDist := GDFieldPos("DF1_DISTAN")
			//--Alimenta a variavel de memoria, caso seja adicionado uma linha pelo copia de itens
			M->DF0_TOTDIS := 0
			For nCnt := 1 To Len(aCols)
				M->DF0_TOTDIS += aCols[nCnt][nPosDist]
			Next nCnt
			If Empty(GdFieldGet('DF1_TIPTRA',n))
				Help('',1,'TMSAF0535') // "Favor efetuar o preenchimento","do Tipo de Tranporte."
				lRet := .F.
			EndIf
		EndIf

		//Se opcao selecionada = Cancelamento e status da coleta ou status de entrega diferente de cancelado, nao obriga preencher os campos abaixo.
		If lCancela .And. (GdFieldGet("DF1_STACOL",n) <> StrZero(9,Len(DF1->DF1_STACOL)) .And. ;
			GdFieldGet("DF1_STAENT",n) <> StrZero(9,Len(DF1->DF1_STAENT)) ) //-- Cancelado
			AAdd(aCpoSkip,"DF1_DATCAN")
			AAdd(aCpoSkip,"DF1_OBSCAN")
		EndIf

		If lRet .And. ( lRet := MaCheckCols(aHeader,aCols,n,aCpoSkip) )
			If nOpcao == 2 //-- Produtos por Agendamento
				//Vefica se possui o ponto de entrada para deixar as validações por conta de funções de usuario
				If lTM05VPRD
					lRet := ExecBlock("TM05VPRD",.F.,.F.,{ aHeader , aCols})
					If ValType(lRet) != "L"
						lRet := GDCheckKey( { "DF2_CODPRO" }, 4 ) //-- Analisa se ha itens duplicados na GetDados.
					EndIf
				Else
					lRet := GDCheckKey( { "DF2_CODPRO" }, 4 ) //-- Analisa se ha itens duplicados na GetDados.
				EndIf
			ElseIf nOpcao == 3 //-- Valor Informado por Agendamento
				lRet := GDCheckKey( { "DF3_CODPAS" }, 4 ) //-- Analisa se ha itens duplicados na GetDados.
			ElseIf nOpcao == 4 //-- Cubagem por Agendamento
				lRet := GDCheckKey( { "DF4_ITEM" }, 4 ) //-- Analisa se ha itens duplicados na GetDados.
			ElseIf nOpcao == 5 //-- Tipos de Veiculos por Agendamento
				lRet := GDCheckKey( { "DF5_TIPVEI" }, 4 ) //-- Analisa se ha itens duplicados na GetDados.
			EndIf
		EndIf
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05TOk³ Autor ³ Vitor Raspa           ³ Data ³10.MAR.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da Tela de Agendamento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05TOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05TOk()

Local lRet       := .T. 
Local nCnt       := 0
Local nPosDistIV := GDFieldPos("DF1_DISTIV")
Local nPosDatCan := GDFieldPos("DF1_DATCAN")
Local cItem		:= ""
Local cDatPrc		:= ""
Local cHorPrc		:= ""
Local nPos 		:= 0
Local nCnt1		:= 0
Local nCnt2		:= 0
Local aHeadTmp	:= {}
Local aColsTmp	:= {}
Local aProds		:= {}
Local aProds2		:= {}
Local cChave		:= ""
Local nDF2CODPRO	:= 0
Local nTotReg		:= 0
Local cAliasTmp	:= GetNextAlias()
Local bQuery		:= {|| Iif(Select(cAliasTmp) > 0, TMP1->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTmp,.F.,.T.), dbSelectArea(cAliasTmp), (cAliasTmp)->(dbEval({|| nTotReg++ })), (cAliasTmp)->(dbGoTop())  }

If M->DF0_TIPDIS == '1'
	For nCnt := 1 To Len(aCols)
		If !GdDeleted(nCnt)
			If aCols[nCnt,nPosDistIV] == '1'
				Help("",1,"TMSAF0531") //-- ""Quando o Tipo de Distancia for 'CONSOLIDADA', nao podem existir Itens, que consideram Distancia Ida/Volta"
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next
ElseIf M->DF0_TIPDIS == '2'
	If M->DF0_DISTIV == '1'
		Help("",1,"TMSAF0532") //-- Quando o Tipo de Distancia for 'PONTO-A-PONTO', deve-se definir nos ITENS o calculo da distancia Ida/Volta. '
		lRet := .F.
	EndIf
EndIf

If lRet .And. nPosDatCan > 0
	If M->DF0_STATUS == StrZero(9, Len(DF0->DF0_STATUS))
		If AScan(aCols, {|x| Empty(x[nPosDatCan])}) > 0
			Help('',1,'OBRIGAT2',,RetTitle("DF1_DATCAN"),04,01) //"Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
			lRet := .F.
		EndIf
	EndIf
EndIf

//Validacao para nao incluir registros duplicados na tabela DUE
For nCnt := 1 To Len(aCols)
	If !GdDeleted(nCnt)
		SA1->(DbSetOrder(1))
		If ( SA1->(MsSeek(xFilial("SA1")+GDFieldGet("DF1_CLIREM",nCnt)+GDFieldGet("DF1_LOJREM",nCnt))) )
			DUE->(DbSetOrder(1))
			DUE->(DbGotop())
			If DUE->(MsSeek(xFilial("DUE")+SA1->A1_COD+SA1->A1_LOJA))
				DUE->(DbSetOrder(3))
				DUE->(DbGotop())
				If ! ( DUE->(MsSeek(xFilial("DUE")+GDFieldGet("DF1_CLIREM",nCnt)+GDFieldGet("DF1_LOJREM",nCnt))) )
					Help(" ",1,"TMSAF0515")      	
					lRet := .F.
				EndIf
			EndIf	
		EndIf
		
		//-- Valida se o codigo da negociacao + servico existem
		If lRet  
			If !Empty(GDFieldGet("DF1_CODNEG",nCnt)) .And. !Empty(GDFieldGet("DF1_NCONTR",nCnt)) .And. !Empty(GDFieldGet("DF1_SERVIC",nCnt)) 
				DDA->(DbSetOrder(2))
				If !DDA->(DbSeek(xFilial("DDA") + GDFieldGet("DF1_NCONTR",nCnt) + GDFieldGet("DF1_CODNEG",nCnt) + GDFieldGet("DF1_SERVIC",nCnt)))
					Help("",1,'TMSAF0538') //-- Código da negociação e serviçoo não existem no contrato do cliente.
					lRet := .F.
				EndIf
			EndIf	
		EndIf
		
		//-- Valida se o codigo da negociacao + servico existem
		If lRet  
			If !Empty(GDFieldGet("DF1_CODNEG",nCnt)) .And. !Empty(GDFieldGet("DF1_SRVCOL",nCnt))
				DDA->(DbSetOrder(2))
				If !DDA->(DbSeek(xFilial("DDA") + GDFieldGet("DF1_NCONTR",nCnt) + GDFieldGet("DF1_CODNEG",nCnt) + GDFieldGet("DF1_SRVCOL",nCnt)))
					Help("",1,'TMSAF0538') //-- Código da negociação e serviçoo não existem no contrato do cliente.
					lRet := .F.
				EndIf
			EndIf	
		EndIf
	EndIf
Next nCnt

//------------------------------------------------//
//-- Verifica Se Informa Divergencia De Produtos--//
//------------------------------------------------//
If FindFunction("TMSA029USE") .And. Tmsa029Use("TMSAF05")

	aPrdData := {}
	For nCnt := 1 To Len(aCols)

		If !GdDeleted(nCnt) //-- Elimina Linhas Deletadas

			//-- Vetor Com Os Dados Alterados/Acessados
			If Type("aColsPrd["+cValToChar(nCnt)+"]") <> 'U' .And. Len(aColsPrd[nCnt]) > 0

				cItem	:= GDFieldGet("DF1_ITEAGE",nCnt)
				cDatPrc:= DtoS(GDFieldGet("DF1_DATPRC",nCnt))
				cHorPrc:= GDFieldGet("DF1_HORPRC",nCnt)
				nPos 	:= aScan(aColsPrd,{|x| Alltrim( Upper( x[1] ) ) == cItem 	})

				If nPos > 0

					aHeadTmp 		:= AClone(aColsPrd[nCnt,3])
					aColsTmp 		:= AClone(aColsPrd[nCnt,2])
					nDF2CODPRO 	:= aScan(aHeadTmp,{|x| Alltrim( Upper( x[2] ) ) == "DF2_CODPRO" 	}) // Posicao do campo "DF2_CODPRO"

					For nCnt1 := 1 To Len(aColsTmp)
						If !aColsTmp[nCnt1,Len(aHeadTmp)+1] // Elimina Linhas Deletadas
							If aScan(aPrdData,{|aX|aX[1]+aX[2]+aX[3] == cDatPrc + cHorPrc + aColsTmp[nCnt1,nDF2CODPRO] }) == 0
								aAdd(aPrdData,{cDatPrc, cHorPrc, aColsTmp[nCnt1,nDF2CODPRO]})
							EndIf
						EndIf
					Next nCnt1
				Else

					// Se For Alteração Do Agendamento Sem Acols de Produto Para o Item, Pesquisa na Tabela
					cQuery := " SELECT	DISTINCT DF2.DF2_CODPRO "
					cQuery += " FROM		" + RetSqlName("DF2") + " DF2 "
					cQuery += " WHERE		DF2.DF2_FILIAL	=	'" + xFilial("DF2") + "' "
					cQuery += " AND		DF2.DF2_NUMAGE	=	'" + M->DF0_NUMAGE  + "' "
					cQuery += " AND		DF2.DF2_ITEAGE	=	'" + cItem          + "' "
					cQuery += " AND		DF2.D_E_L_E_T_	=	' ' "

					Eval(bQuery)

					DbSelectArea(cAliasTmp)
					While !(cAliasTmp)->(Eof())
						If aScan(aPrdData,{|aX|aX[1]+aX[2]+aX[3] == cDatPrc + cHorPrc + (cAliasTmp)->DF2_CODPRO }) == 0
							aAdd(aPrdData,{ cDatPrc, cHorPrc, (cAliasTmp)->DF2_CODPRO })
						EndIf
						(cAliasTmp)->(DbSkip())
					EndDo
					(cAliasTmp)->(DbCloseArea())
				EndIf
			EndIf
		EndIf
	Next nCnt

	If Len(aPrdData) > 1

		//-- Ordena Produtos Por Data e Hora
		aSort( aPrdData,,, { |x, y| (x[1]+x[2]+x[3]) < (y[1]+y[2]+y[3]) })

		//-- Calcula Divergencias
		aProds := {}
		aProds2:= {}
		cChave := ""
		nCnt 	:= 1

		While .t.

			cChave := aPrdData[nCnt,1] + aPrdData[nCnt,2]

			If lTmsa029 .And. Tmsa029Use("TMSAF05") .And. ("A" $ cMV_TMSINCO .Or. "E" $ cMV_TMSINCO)
				While (nCnt <= Len(aPrdData)) .And. ((aPrdData[nCnt,1] + aPrdData[nCnt,2] ) == cChave)
					aAdd(aProds,aPrdData[nCnt,3])
					nCnt ++
				EndDo
			EndIf

			If Len(aProds) > 1

				aProds  := TmsRtDvP(aProds) //-- Calcula Divergencias

				For nCnt2 := 1 To Len(aProds)
					//-----------(    Data Agendamento     ) (               Hora Agendamento                ) (Produto Agend )(Produtos Diverg)
					aAdd(aProds2,{StoD(Substr(cChave,01,08)),Substr(cChave,09,02) + ":" + Substr(cChave,11,02),aProds[nCnt2,1],aProds[nCnt2,2]})
				Next nCnt2
				aProds := {} // Limpa Variavel
			EndIf

			If nCnt >= Len(aPrdData)
				Exit
			EndIf
		EndDo

		// Proteção De Erro Caso o Vetor Não Esteja Carregado
		If Len(aProds2) > 1
			SaveInter()
			lRet := TmsaF05Div(aProds2) //-- Monta Dialog Com Divergencias De Produtos
			RestInter()
		EndIf

	EndIf
EndIf

Return( lRet )
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsaF05Div
@autor		: Eduardo Alberti
@descricao	: Monta Dialog Com Divergencias De Produtos
@since		: Feb./2015
@using		: Atualização De Bloqueios TMS .
@review	:

Argumentos	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function TmsaF05Div(aDiverg)

Local aArea         := GetArea()
Local oDlgDiverg    := Nil
Local oDiverg       := Nil
Local aCoordenadas  := MsAdvSize(.T.)
Local lOpcClick     := .f.
Local aButtons      := {}
Local cTitulo       := STR0068 //-- "Verifique os Agendamentos Com Divergências."
Local aCab          := { STR0069 , STR0070 , STR0071 , STR0072 } //--{"Data Agendamento","Hora Agendamento","Produto Agendado","Produto(s) Divergente(s)"}

oDlgDiverg          := TDialog():New(000,000,aCoordenadas[6]/1.5,aCoordenadas[5]/1.5,OemToAnsi(cTitulo ),,,,,,,,oMainWnd,.T.) 	// Tela Menor
oDiverg             := TWBrowse():New(031,003,oDlgDiverg:nClientWidth/2-5,oDlgDiverg:nClientHeight/2-45,,aCab,,oDlgDiverg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

oDiverg:SetArray(aDiverg)

oDiverg:bLine := {||{;
DtoC(aDiverg[oDiverg:nAt][01]),;
aDiverg[oDiverg:nAt][02],;
aDiverg[oDiverg:nAt][03],;
aDiverg[oDiverg:nAt][04] }}

Activate MsDialog oDlgDiverg On Init EnchoiceBar(oDlgDiverg,{|| lOpcClick := .t., oDlgDiverg:End()},{|| oDlgDiverg:End() },,aButtons)

RestArea(aArea)

Return(lOpcClick)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05Sug³ Autor ³ Eduardo de Souza      ³ Data ³ 23/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Sugere Cliente Remetente                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Sug(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - (1=Cliente/2=Loja)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Sug(nOpcao)

Local cRet := ''
Local nPos := 0

DUE->(DbSetOrder(1))
If DUE->(MsSeek(xFilial("DUE")+M->DF0_CODSOL))
	If nOpcao == 1 //-- Cliente (Inicializador Padrao)
		cRet := DUE->DUE_CODCLI
	ElseIf nOpcao == 2 //-- Loja (Inicializador Padrao)
		cRet := DUE->DUE_LOJCLI
	ElseIf nOpcao == 3 //-- Cliente + Loja (Check Sugestao do Remetente)
		If lSugRemet
			
			nPos := aScan( aHeader, { |x| Alltrim( Upper( x[2] ) ) == "DF1_SRVCOL" } )

			If nPos > 13
				GDFieldPut("DF1_CLIREM",DUE->DUE_CODCLI,n)
				GDFieldPut("DF1_LOJREM",DUE->DUE_LOJCLI,n)
				GDFieldPut("DF1_SQEREM",M->DF0_SEQEND,n)
				//-- Executa Gatilhos
				If !Empty(M->DF0_SEQEND)
					M->DF1_SQEREM := M->DF0_SEQEND
					RunTrigger(2,n,,oGetDAge,"DF1_SQEREM")
				Else
					RunTrigger(2,n,,oGetDAge,"DF1_CLIREM")
					RunTrigger(2,n,,oGetDAge,"DF1_LOJREM")
				EndIf
				__ReadVar := "M->DF1_TIPFRE"
				CheckSX3("DF1_TIPFRE",GDFieldGet("DF1_TIPFRE",n))
				__ReadVar := "M->DF1_SELORI"
				If Type("M->DF1_SELORI") == "U"
					M->DF1_SELORI := DF1->DF1_SELORI
				EndIf
				CheckSX3("DF1_SELORI",GDFieldGet("DF1_SELORI",n))
				oGetDAge:Refresh()
			EndIf
		EndIf
	EndIf
EndIf

Return( cRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05Chg³ Autor ³ Eduardo de Souza      ³ Data ³ 24/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa Gatilhos na troca de linha                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Chg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Chg()

Local nCnt        := 0
Local nI          := 0
Local cCampo      := ''
Local nPos        := 0
Local nPosPrd     := 0
Local nOpcx       := 2
Local cItemAtu    := ''
Local cItemAnt    := ''
Local lAtuTot     := .T.
Local nTQtdVol    := 0
Local nTPeso      := 0
Local nTPesoM3    := 0
Local nTM3        := 0
Local nTValMer    := 0
Local nPosRep     := 0
Local cNoFieldRep := If(lTMF05NREP,ExecBlock("TMF05NREP",.F.,.F.),'' )
Local cNoFieldPrd := If(lTMF05NPRD,ExecBlock("TMF05NPRD",.F.,.F.),.F.)
Local nPosDELET   := 0
Local aFldDF1	  := {}
Local cNoFldDF1	  := ""

Private cCliCalC  := ''
Private cLojCalC  := ''
Private cServic   := ''
Private cTipFre   := ''
Private cCodNeg   := ""

If ValType(cNoFieldRep) != "C"
	cNoFieldRep := ''
EndIf	

If ValType(cNoFieldPrd) != "C"
	cNoFieldPrd := ''
EndIf

lNovoItem := .F.

//-- Alimenta a quantidade do agendamento
TMSAF05Qtd()

//-- Sugerir Cliente Remetente
If lSugRemet
	If n > 1 .And. n == Len(aCols) //.And. Empty(GDFieldGet("DF1_CLIREM",n)) //Comentado o trecho para alterar o cliente remetente, caso seja alterado o Solcitante.
		TMSAF05Sug(3)
	EndIf
EndIf

//-- Repetir conteudo no proximo item
If lRepCont
	If n = Len(aCols) .And. Empty(GDFieldGet("DF1_CLIREM",n))
		//-- Retorna a posicao que devera repetir os dados
		nPosDELET := Len(aHeader)+1 //Posicao da coluna da GetDados que indica se o item estah deletado
		For nI:=n-1 to 1 Step -1
			If !aCols[nI][nPosDELET]
				nPosRep := nI
				Exit
			EndIf
		Next nI

		lNovoItem := .T.

		If nPosRep > 0
			cTipFre := GDFieldGet("DF1_TIPFRE",nPosRep)
			cServic := GDFieldGet("DF1_SERVIC",nPosRep)
			cCodNeg := GDFieldGet("DF1_CODNEG",nPosRep)
			GDFieldPut("DF1_CODNEG",cCodNeg,n)
			
			//-- Cliente de calculo da cotacao
			TMSAF05Cli(@cCliCalC,@cLojCalC,nPosRep)
			
			cNoFldDF1 := 'DF1_SEQUEN,DF1_SEQENT,DF1_STACOL,DF1_STAENT,DF1_ITEAGE,DF1_NUMCOT,DF1_VALFRE,DF1_VALIMP,DF1_VALTOT,DF1_FILDOC,DF1_DOC,DF1_SERIE,DF1_DATCON'
			aFldDF1 := ApBuildHeader("DF1", Strtokarr2( cNoFldDF1+cNoFieldRep, ","))
			For nI := 1 To Len(aFldDF1)
				cCampo:= aFldDF1[nI][2]

				If aFldDF1[nI][10] <> "V"
					M->&(cCampo) := GDFieldGet(cCampo,nPosRep)
					__Readvar := 'M->'+(cCampo)
					If !Empty(M->&(cCampo)) 
						If TMSAF05Vld(.F.) //-- Validacao dos dados
							GDFieldPut( cCampo,GDFieldGet(cCampo,nPosRep), n )
							If ExistTrigger(cCampo)
								RunTrigger(2,n,,,cCampo)
							EndIf
						EndIf
					EndIf
				EndIf
			Next

			aSize(aFldDF1, 0)
			aFldDF1 := Nil

			cItemAtu := GDFieldGet("DF1_ITEAGE",n)
			cItemAnt := GDFieldGet("DF1_ITEAGE",nPosRep)

			// Tratamento para preenchimento dos campos de serviço, devido a ordenação do campo, o preenchimento anterior falhava, desta forma os mesmos deverão ser preenchidos no final.
			If !Empty(GDFieldGet("DF1_SERVIC",nPosRep)) .AND. Empty(GDFieldGet("DF1_SERVIC",n)) .AND. !("DF1_SERVIC" $ cNoFieldRep )
				GDFieldPut("DF1_SERVIC",GDFieldGet("DF1_SERVIC",nPosRep), n )
				If ExistTrigger("DF1_SERVIC")
					RunTrigger(2,n,,,"DF1_SERVIC")
				EndIf
			EndIf
			If !Empty(GDFieldGet("DF1_SRVCOL",nPosRep)) .AND. Empty(GDFieldGet("DF1_SRVCOL",n)) .AND. !("DF1_SRVCOL" $ cNoFieldRep )
				GDFieldPut("DF1_SRVCOL",GDFieldGet("DF1_SRVCOL",nPosRep), n )
				If ExistTrigger("DF1_SRVCOL")
					RunTrigger(2,n,,,"DF1_SRVCOL")
				EndIf
			EndIf
			
			//--Zera a Distancia na copia de linha
			GDFieldPut("DF1_DISTAN",0,n)

			SaveInter() //-- Salva aCols Atual

			//-- Repete Produtos
			aCols   := {}
			aHeader := {}
			lAtuTot := .F.
			If (nPosPrd := Ascan( aColsPrd, { |x| x[1] == cItemAnt } ) ) == 0
				TMSFillGetDados(nOpcx, "DF2", 1, xFilial("DF2") + M->DF0_NUMAGE + cItemAnt , Iif(nOpcx <> 3,{ || DF2->DF2_FILIAL + DF2->DF2_NUMAGE + DF2->DF2_ITEAGE }, {|| ''}), { || .T. } )
				nPosPrd := 1
			Else
				aCols   := AClone(aColsPrd[nPosPrd,2])
				aHeader := AClone(aColsPrd[nPosPrd,3])
			EndIf
			AAdd(aColsPrd,{ cItemAtu, aCols, aHeader } )
			nPosAtuPrd := GDFieldPos("DF2_CODPRO")

			//-- Limpa os campos definidos pelo usuario atraves do ponto de entrada (TMF05NPRD)
			If !Empty(cNoFieldPrd)
				For nCnt := 1 To Len(aCols)
					DbSelectArea("DF2")
					For nI := 1 TO FCount()
						cCampo := FieldName(nI)
						If !( cCampo $ 'DF2_FILIAL,DF2_NUMAGE,DF2_ITEAGE,DF2_CODPRO' ) .And. ;
							( cCampo $ cNoFieldPrd )
							GDFieldPut(cCampo,CriaVar(cCampo,.F.),nCnt)
						EndIf
					Next nI
				Next nCnt
			EndIf

			nLenAcols 	:= Len(aCols)
			If nLenAcols > 0
				nPosDELET 	:= Len(aHeader)+1 //Posicao da coluna da GetDados que indica se o item estah deletado
				nDF2QTDVOL 	:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF2_QTDVOL" }) 	// Posicao do campo "DF2_QTDVOL"
				nDF2PESO 	:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF2_PESO" }) 	// Posicao do campo "DF2_PESO"
				nDF2PESOM3 	:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF2_PESOM3" }) 	// Posicao do campo "DF2_PESOM3"
				nDF2VALMER 	:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF2_VALMER" }) 	// Posicao do campo "DF2_VALMER"
				nDF2METRO3 	:= aScan(aHeader,{|x| Alltrim( Upper( x[2] ) ) == "DF2_METRO3" }) 	// Posicao do campo "DF2_METRO3"
				lAtuTot := .T.
				
				//-- Armazena Totalizadores
				For nCnt := 1 To nLenAcols
					If !aCols[nCnt][nPosDELET]
						nTQtdVol += aCols[nCnt][nDF2QTDVOL]
						nTPeso   += aCols[nCnt][nDF2PESO]
						nTPesoM3 += aCols[nCnt][nDF2PESOM3]
						nTValMer += aCols[nCnt][nDF2VALMER]
						If nDF2METRO3 > 0
							nTM3 += aCols[nCnt][nDF2METRO3]
						EndIf
					EndIf
				Next nCnt
			EndIf

			//-- Repete Valor Informado e Cubagem por Produto
			For nCnt := 1 To Len(aColsPrd[nPosPrd,2])
				aCols    := {}
				aHeader  := {}
				cProduto := aColsPrd[nPosPrd,2,nCnt,nPosAtuPrd] //-- Produto

				//-- Repete Valor Informado por Produto
				If (nPos := Ascan( aColsVInf, { |x| x[1]+x[2] == cItemAnt + cProduto } ) ) == 0
					TMSFillGetDados(nOpcx, "DF3", 1, xFilial("DF3") + M->DF0_NUMAGE + cItemAnt + cProduto , Iif(nOpcx <> 3,{ || DF3->DF3_FILIAL + DF3->DF3_NUMAGE + DF3->DF3_ITEAGE + DF3->DF3_CODPRO }, {|| ''}), { || .T. } )
				Else
					aCols    := AClone(aColsVInf[nPos,3])
					aHeader  := AClone(aColsVInf[nPos,4])
				EndIf
				AAdd(aColsVInf,{ cItemAtu, cProduto, aCols, aHeader } )

				//-- Repete Cubagem por Produto
				aCols    := {}
				aHeader  := {}
				If (nPos:= Ascan( aColsPM3, { |x| x[1]+x[2] == cItemAnt + cProduto } ) ) == 0
					TMSFillGetDados(nOpcx, "DF4", 1, xFilial("DF4") + M->DF0_NUMAGE + cItemAnt + cProduto , Iif(nOpcx <> 3,{ || DF4->DF4_FILIAL + DF4->DF4_NUMAGE + DF4->DF4_ITEAGE + DF4->DF4_CODPRO }, {|| ''}), { || .T. } )
				Else
					aCols    := AClone(aColsPM3[nPos,3])
					aHeader  := AClone(aColsPM3[nPos,4])
				EndIf
				AAdd(aColsPM3,{ cItemAtu, cProduto, aCols, aHeader } )
			Next nCnt

			//-- Repete Tipos de Veiculo
			aCols   := {}
			aHeader := {}
			If (nPos := Ascan( aColsTip, { |x| x[1] == cItemAnt } ) ) == 0
				TMSFillGetDados(nOpcx, "DF5", 1, xFilial("DF5") + M->DF0_NUMAGE + cItemAnt , Iif(nOpcx <> 3,{ || DF5->DF5_FILIAL + DF5->DF5_NUMAGE + DF5->DF5_ITEAGE }, {|| ''}), { || .T. } )
			Else
				aCols   := AClone(aColsTip[nPos,2])
				aHeader := AClone(aColsTip[nPos,3])
			EndIf
			AAdd(aColsTip,{ cItemAtu, aCols, aHeader } )

			RestInter() //-- Restaura aCols Atual

			//-- Atualiza Totalizadores
			If lAtuTot
				GDFieldPut("DF1_QTDVOL",nTQtdVol,n)
				GDFieldPut("DF1_PESO"  ,nTPeso  ,n)
				GDFieldPut("DF1_PESOM3",nTPesoM3,n)
				GDFieldPut("DF1_METRO3",nTM3    ,n)
				GDFieldPut("DF1_VALMER",nTValMer,n)

				//-- Ponto De Entrada na Atualização DF1
				If ExistBlock("TMF05ATU")
					ExecBlock("TMF05ATU",.F.,.F.,{aColsPrd})
				EndIf
			EndIf
			oGetDAge:Refresh()
		EndIf
	EndIf
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05Prd³ Autor ³ Eduardo de Souza      ³ Data ³ 24/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Produtos por Agendamento                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Prd(ExpL1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Verifica se altera produto                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Prd(lAltPrd)

Local oDlgEsp
Local oGetPrd
Local aSize     := {}
Local aInfo     := {}
Local aObjects  := {}
Local aPosObj   := {}
Local cTitulo   := STR0022 // 'Produtos por Agendamento'
Local nOpcx     := 2
Local nPos      := 0
Local nOpcao    := 0
Local lAchou    := .F.
Local nCnt      := 0
Local aButtons  := {}
Local cCliente  := ''
Local cLoja     := ''
Local aSetKeyA  := AClone(aSetKey)
Local nTQtdVol  := 0
Local nTPeso    := 0
Local nTPesoM3  := 0
Local nTM3      := 0
Local nTValMer  := 0
Local lAtuTot   := .F.
Local aAlterAux := AClone(aAltGetD)
Local lHelp     := .T.
Local cCpoRep   := "" //String cujo conteudo sera retornado pelo ponto de entrada TMF05REP, que contera os campos que serao repetidos na proxima linha da GetDados dos produtos.
Local lTMF05Rep := ExistBlock('TMF05REP') //Ponto de entrada para receber uma string com os campos que deverão ser repetidos na próxima linha da GetDados dos produtos.
Local cServCol  := GDFieldGet("DF1_SRVCOL")
Local cAliasQry := GetNextAlias()
Local lIncDF2   := .F.
Local lRet      := .T.

Default lAltPrd := .T.

Private cItemAge := GDFieldGet("DF1_ITEAGE",n)
Private cServic  := GDFieldGet("DF1_SERVIC",n)
Private cTipFre  := GDFieldGet("DF1_TIPFRE",n)
Private cStaCol  := GDFieldGet("DF1_STACOL",n)
Private cNumCot  := GDFieldGet("DF1_NUMCOT",n)
Private cCliCalC := ""
Private cLojCalC := ""
Private cCodNeg  := ""

If Type( "aColsAnt" ) <> "A"
	aColsAnt:= {}
EndIf

cCodNeg := GDFieldGet("DF1_CODNEG",n)

If lTMF05PRV
	lRet := ExecBlock("TMF05PRV",.F.,.F.)
	If ValType(lRet) == "L" .And. !lRet
		Return
	EndIf
EndIf

//-- Permite o alterar dados do produto com status "Confirmado" ou "Planejado" e "Em Processo".
If	GDFieldGet("DF1_STAENT",n) == StrZero(2,Len(DF1->DF1_STACOL)) .Or. ;
	GDFieldGet("DF1_STAENT",n) == StrZero(3,Len(DF1->DF1_STACOL)) .Or. ;
	GDFieldGet("DF1_STAENT",n) == StrZero(4,Len(DF1->DF1_STACOL))
	aAltGetD := {}
	aAltGetD := If(ExistBlock("TMF05ALTP"),ExecBlock("TMF05ALTP",.F.,.F.),Nil)
	If ValType(aAltGetD) != "A"
		aAltGetD := AClone(aAlterAux)
	Else
		//-- Verifica se o usuario tem permissao para alterar o agendamento com cotacao
		If	Altera .And. !(!Empty(GDFieldGet("DF1_NUMCOT",n)) .And. !TmsAcesso(,'TMSA040',,,lHelp))
			lAltPrd   := .T.
		EndIf
	EndIf
	If !lAltPrd
		aAltGetD := AClone(aAlterAux)
	EndIf
EndIf

//-- Cliente de calculo da cotacao
TMSAF05Cli(@cCliente,@cLoja)
cCliCalC := cCliente
cLojCalC := cLoja

//-- Finaliza Teclas de Atalhos
aSetKey := {}
TmsKeyOff(aSetKey)

SaveInter() //-- Salva Area

aCols   := {}
aHeader := {}

//-- Verifica se podera alterar o produto
If lAltPrd
	If Inclui
		nOpcx := 3
	ElseIf Altera
		nOpcx := 4
	EndIf
EndIf

If (nPos:= Ascan( aColsPrd, { |x| x[1] == cItemAge } ) ) == 0
	TMSFillGetDados(nOpcx, "DF2", 1, xFilial("DF2") + M->DF0_NUMAGE + cItemAge , Iif(nOpcx <> 3,{ || DF2->DF2_FILIAL + DF2->DF2_NUMAGE + DF2->DF2_ITEAGE }, {|| ''}), { || .T. } )
Else
	lAchou   := .T.
	aCols    := AClone(aColsPrd[nPos,2]	)
	aHeader  := AClone(aColsPrd[nPos,3])
	//-- Inicializa todas as linhas do aCols como nao deletado, devido a falha na GetDados
	For nCnt := 1 To Len(aCols)
		aCols[nCnt,Len(aHeader)+1] := .F.
	Next nCnt
EndIf

//--- Guarda aCols inicial para tratamento na alteracao do produto 
If nOpcx == 4 
	If Empty(aColsAnt)
		aColsAnt:= AClone(aCols)
	EndIf
	//--- Na alteração quando nao encontrar o item do agendamento, deve-se inserir o produto vinculado ao cadastro do solicitante
	DF2->(DbSetOrder(1))
	If !DF2->(MsSeek(xFilial("DF2")+M->DF0_NUMAGE+cItemAge))
		lIncDF2:= .T.
	EndIf
EndIf

// Painel de Agendamento: Insere o produto vinculado ao cadastro do solicitante na tela de produto.
If !lAchou
	If (nOpcx == 3  .Or. lIncDF2) 
		cQuery := " SELECT DVJ_CODPRO, DVJ_CODEMB "
		cQuery += "   FROM " + RetSqlName("DVJ")
		cQuery += "   WHERE DVJ_FILIAL = '" + xFilial("DVJ") + "' "
		cQuery += "     AND DVJ_CODSOL    = '" + M->DF0_CODSOL + "' "
		cQuery += "     AND D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .T.)
		nCnt := 1
		aCols := {}
		While (cAliasQry)->(!Eof())		
			Tmsa210Cols()
			aCols[nCnt][1] := (cAliasQry)->DVJ_CODPRO
			If ExistTrigger("DF2_CODPRO")
				RunTrigger(2,nCnt,,Nil,"DF2_CODPRO")
			EndIf
			aCols[nCnt][3] := (cAliasQry)->DVJ_CODEMB
			If ExistTrigger("DF2_CODEMB")
				RunTrigger(2,nCnt,,Nil,"DF2_CODEMB")
			EndIf
			nCnt++	
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf
EndIf
//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 015, .T., .T. } )
AAdd( aObjects, { 100, 085, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

AAdd(aSetKey  , { VK_F4    , { || TMSAF05VInf(cCliCalc,cLojCalc,cServic,cTipFre,cCodNeg) } } )
AAdd(aButtons , {'COMPTITL', { || TMSAF05VInf(cCliCalc,cLojCalc,cServic,cTipFre,cCodNeg) }, STR0026, STR0053 }) // 'Valor Informado - <F4>'
AAdd(aSetKey  , { VK_F5    , { || TMSAF05PM3(cCliente,cLoja,cServCol) } } )
AAdd(aButtons , {'BALANCA' , { || TMSAF05PM3(cCliente,cLoja,cServCol) } , STR0025, STR0052 }) //'Peso Cubado - <F5>'

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

If lTMF05Rep	//-- Retorna uma string com os campos que terão os valores repetidos na proxima linha da GetDados.
	cCpoRep := ExecBlock('TMF05REP',.F.,.F.)
	If ValType(cCpoRep) != "C"
		cCpoRep := ''
	EndIf
EndIf

DEFINE MSDIALOG oDlgEsp TITLE cTitulo FROM aSize[7]/2,00 TO aSize[6]/2,aSize[5]/2+100 PIXEL

@ aPosObj[1,1],010 SAY STR0023 COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 40 ,9  //'Agendamento:'
@ aPosObj[1,1],050 SAY M->DF0_NUMAGE Of oDlgEsp PIXEL SIZE 29 ,9

@ aPosObj[1,1],130 SAY STR0024 COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 40 ,9  //'Item Agend.:'
@ aPosObj[1,1],170 SAY cItemAge Of oDlgEsp PIXEL SIZE 29 ,9

oGetPrd:=MSGetDados():New((aPosObj[2,1]/2)+(15), aPosObj[2,2]/2, aPosObj[2,3]/2, aPosObj[2,4]/2+50, nOpcx, 'TMSAF05LOk(2)','AllWaysTrue',cCpoRep,nOpcx<>2,aAltGetD,,,Iif(GetMV('MV_PRDDIV'),,1))
//-- Atualiza aCols corrigindo a falha na GetDados
oGetPrd:Refresh(.T.)

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| If(oGetPrd:TudoOk(),(nOpcao:= 1,oDlgEsp:End()),.F.) }, {|| oDlgEsp:End() },, aButtons ) CENTERED

//-- Atualiza array de aCols do produto
If nOpcx <> 2 .And. nOpcao == 1
	If (nPos:= Ascan( aColsPrd, { |x| x[1] == cItemAge } ) ) == 0
		AAdd(aColsPrd,{ cItemAge, aCols, aHeader } )
	Else
		aColsPrd[nPos,2] := AClone(aCols)
	EndIf
	For nCnt := 1 To Len(aCols)
		lAtuTot := .T.
		If !GdDeleted(nCnt)
			nTQtdVol += GDFieldGet("DF2_QTDVOL",nCnt)
			nTPeso   += GDFieldGet("DF2_PESO"  ,nCnt)
			nTPesoM3 += GDFieldGet("DF2_PESOM3",nCnt)
			nTValMer += GDFieldGet("DF2_VALMER",nCnt)
			nTM3     += GDFieldGet("DF2_METRO3",nCnt)
		EndIf
		//
		//| validacao para habilitar reimpressão da S.C.
		//
		If nOpcx == 4
            If oGetPrd:lmodified == .T. //houve alteração na grid
                 //oGetPrd:aLastEdit[1] //linhas que foram editadas
                 If AScan(aModified,{|k| (k[1] == cItemAge) .And. (k[3] == nCnt) }) == 0 		   
		              AAdd(aModified,{cItemAge,"DF2",nCnt})
		         EndIf
	        EndIf
		EndIf
	Next nCnt
EndIf

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

RestInter() //-- Restaura Area

//-- Atualiza Totalizadores
If lAtuTot
	//-- Qdo alterar o produto, obriga atualizar a cotacao
	If !Empty(GDFieldGet("DF1_NUMCOT",n))
		If lAltPrd
			lAtuCot := .T.
		EndIf
	EndIf
	GDFieldPut("DF1_QTDVOL",nTQtdVol,n)
	GDFieldPut("DF1_PESO"  ,nTPeso  ,n)
	GDFieldPut("DF1_PESOM3",nTPesoM3,n)
	GDFieldPut("DF1_METRO3",nTM3    ,n)
	GDFieldPut("DF1_VALMER",nTValMer,n)

	//-- Ponto De Entrada na Atualização DF1 
	If ExistBlock("TMF05ATU")
		ExecBlock("TMF05ATU",.F.,.F.,{aColsPrd})
	EndIf
EndIf

aAltGetD := AClone(aAlterAux)
aSetKey  := AClone(aSetKeyA)
TmsKeyOn(aSetKey) //-- Restaura SetKey

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05VInf³ Autor ³ Eduardo de Souza     ³ Data ³ 25/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valor Informado por Agendamento                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05VInf()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05VInf(cCliente,cLoja,cServic,cTipFre,cCodNeg)

Local oDlgEsp
Local oGetVInf
Local aSize     := {}
Local aInfo     := {}
Local aObjects  := {}
Local aPosObj   := {}
Local cTitulo   := STR0027 // 'Valor Informado por Agendamento'
Local nOpcx     := 2
Local cProduto  := GDFieldGet("DF2_CODPRO",n)
Local nPos      := 0
Local nOpcao    := 0
Local lAchou    := .F.
Local nCnt      := 0
Local aCmpInf   := {}
Local aTabFre   := {}
Local cTabFre   := ''
Local cTipTab   := ''
Local lContinua := .F.

Local aNoFields := {}

DEFAULT cCodNeg := ""

If Empty(cProduto)
	Help(' ', 1, 'TMSA04010') //-- Informe o produto
	Return( .F. )
EndIf

SaveInter() //-- Salva Area

aCols   := {}
aHeader := {}

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

If Inclui
	nOpcx := 3
ElseIf Altera
	nOpcx := 4
EndIf

AAdd(aNoFields,"DF3_NUMAGE")

If (nPos:= Ascan( aColsVInf, { |x| x[1]+x[2] == cItemAge+cProduto } ) ) == 0 .Or. Empty(aColsVInf[nPos,3])
	TMSFillGetDados(nOpcx, "DF3", 1, xFilial("DF3") + M->DF0_NUMAGE + cItemAge + cProduto , Iif(nOpcx <> 3,{ || DF3->DF3_FILIAL + DF3->DF3_NUMAGE + DF3->DF3_ITEAGE + DF3->DF3_CODPRO }, {|| ''}), { || .T. },aNoFields)
	If nOpcx <> 2
		If Len(aCols) == 1 .And. Empty(GDFieldGet('DF3_CODPAS',1))
			//-- Pesquisa a tabela de frete do cliente
			aTabFre := TmsTabFre(cCliente,cLoja,cServic,cTipFre,cCodNeg)
			If !Empty(aTabFre)
				cTabFre := aTabFre[1]
				cTipTab := aTabFre[2]
			EndIf
			If !Empty(cTabFre) .And. !Empty(cTipTab) .Or. ;
				MsgYesNo(STR0048) //'Tabela de Frete nao localizada, deseja apresentar todos componentes do tipo valor informado ?'
				lContinua := .T.
			EndIf
			//-- Obtem todos os componentes do tipo valor informado
			If lContinua
				aCols   := {}
				aCmpInf := TmsCompFre(StrZero(7,Len(DT3->DT3_TIPFAI)),cTabFre,cTipTab)
				If !Empty(aCmpInf)
					For nCnt := 1 To Len(aCmpInf)
						//-- Monta uma linha em branco
						AAdd( aCols, Array( Len( aHeader ) + 1 ) )
						nItem := Len(aCols)
						GDFieldPut('DF3_CODPAS',aCmpInf[nCnt,1],nItem)
						GDFieldPut('DF3_DESPAS',aCmpInf[nCnt,2],nItem)
						GDFieldPut('DF3_VALOR' ,0,nItem)
						aCols[ nItem, Len( aHeader ) + 1 ] := .F.
					Next
				EndIf
			EndIf
		EndIf
	EndIf
Else
	lAchou   := .T.
	aCols    := AClone(aColsVInf[nPos,3])
	aHeader  := AClone(aColsVInf[nPos,4])
	//-- Inicializa todas as linhas do aCols como nao deletado, devido a falha na GetDados
	For nCnt := 1 To Len(aCols)
		aCols[nCnt,Len(aHeader)+1] := .F.
	Next nCnt
EndIf

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 015, .T., .T. } )
AAdd( aObjects, { 100, 085, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgEsp TITLE cTitulo FROM aSize[7]/2,00 TO aSize[6]/2,aSize[5]/2+100 PIXEL

@ aPosObj[1,1],010 SAY STR0023 COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 40 ,9  //'Agendamento:'
@ aPosObj[1,1],050 SAY M->DF0_NUMAGE Of oDlgEsp PIXEL SIZE 29 ,9

@ aPosObj[1,1],110 SAY STR0024 COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 40 ,9  //'Item Agend.:'
@ aPosObj[1,1],145 SAY cItemAge Of oDlgEsp PIXEL SIZE 29 ,9

@ aPosObj[1,1],170 SAY STR0028 COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 40 ,9  //'Produto:'
@ aPosObj[1,1],195 SAY cProduto Of oDlgEsp PIXEL SIZE 100 ,9

oGetVInf:=MSGetDados():New((aPosObj[2,1]/2)+10, aPosObj[2,2]/2, aPosObj[2,3]/2, aPosObj[2,4]/2+50, nOpcx, 'TMSAF05LOk(3)','AllWaysTrue',,nOpcx<>2,aAltGetD)
//-- Atualiza aCols corrigindo a falha na GetDados
If(lAchou,aCols := AClone(aColsVInf[nPos,3]),.T.)
oGetVInf:Refresh(.T.)

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| If(oGetVInf:TudoOk(),(nOpcao:= 1,oDlgEsp:End()),.F.) }, {|| oDlgEsp:End() }) CENTERED

//-- Atualiza array de aCols do produto
If nOpcao == 1
	If (nPos:= Ascan( aColsVInf, { |x| x[1]+x[2] == cItemAge+cProduto } ) ) == 0
		AAdd(aColsVInf,{ cItemAge, cProduto, aCols, aHeader } )
	Else
		aColsVInf[nPos,3] := AClone(aCols)
	EndIf
EndIf

RestInter() //-- Restaura Area

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05PM3 ³ Autor ³ Eduardo de Souza     ³ Data ³ 25/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cubagem por Agendamento                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05PM3(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Cliente                                            ³±±
±±³          ³ ExpC2 - Loja                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05PM3(cCliente,cLoja,cServCol) 

Local oDlgEsp
Local oGetPM3
Local aSize      := {}
Local aInfo      := {}
Local aObjects   := {}
Local aPosObj    := {}
Local cTitulo    := STR0029 // 'Cubagem por Agendamento'
Local nOpcx      := 2
Local cProduto   := GDFieldGet("DF2_CODPRO",n)
Local nTQtdVol   := GDFieldGet("DF2_QTDVOL",n)
Local nPos       := 0
Local nOpcao     := 0
Local lAchou     := .F.
Local nCnt       := 0
Local nPerCub    := TmsPerCub(cProduto,cCliente,cLoja)
Local cOptPesCub := ""

Local aNoFields := {}

Default cServCol := ""

Private nFatCub	 := 0

If Empty(cProduto)
	Help(' ', 1, 'TMSA04010') //-- Informe o produto
	Return( .F. )
EndIf

If !Empty(nPerCub)
	Help(' ', 1, 'TMSA04032',,STR0028 + cProduto, 4, 1 ) //-- O peso cubado sera calculado pelo percentual de cubagem informado no complemento do produto (SB5).  //'Produto: '
	Return( .F. )
EndIf

If Empty(nTQtdVol)
	Help(' ', 1, 'TMSA04031') //-- Informe o volume
	Return( .F. )
EndIf

If Empty(cServic) .And. Empty(cServCol)
	Help(' ', 1, 'TMSAF0508') //-- Informe o codigo do servico no Item do Agendamento
	Return( .F. )
EndIf

cOptPesCub := TmsPesCub(cCliente,cLoja)
If Empty(cOptPesCub)
	Return( .F. )
EndIf

//-- Peso Cubado == Nao   OU   Peso Cubado == M3
If cOptPesCub == '2' .Or. cOptPesCub == '4'
	If !Empty(cCliente)
		Help("",1,'TMSA05036') // O Peso Cubado Nao podera ser Informado ... Esta Regra Foi definida no Perfil do Cliente de Calculo Informado
	EndIf
	Return( .F. )
EndIf

//-- Obtem o fator de cubagem do cliente devedor
aContrt := TMSContrat( cCliente, cLoja,,cServic,,cTipFre,,,,,,,,,,,,,,,,cCodNeg)
If !Empty(aContrt)
	nFatCub := aContrt[1,2]
EndIf

SaveInter() //-- Salva Area

aCols   := {}
aHeader := {}

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

If Inclui
	nOpcx := 3
ElseIf Altera
	nOpcx := 4
EndIf

AAdd(aNoFields,"DF4_NUMAGE")

If (nPos:= Ascan( aColsPM3, { |x| x[1]+x[2] == cItemAge+cProduto } ) ) == 0
	TMSFillGetDados(nOpcx, "DF4", 1, xFilial("DF4") + M->DF0_NUMAGE + cItemAge + cProduto , Iif(nOpcx <> 3,{ || DF4->DF4_FILIAL + DF4->DF4_NUMAGE + DF4->DF4_ITEAGE + DF4->DF4_CODPRO }, {|| ''}), { || .T. },aNoFields)
	If Empty(GDFieldGet("DF4_ITEM",1))
		aCols[1,GDFieldPos("DF4_ITEM")]:= StrZero(1,Len(DF4->DF4_ITEM))
	EndIf
Else
	lAchou   := .T.
	aCols    := AClone(aColsPM3[nPos,3])
	aHeader  := AClone(aColsPM3[nPos,4])
	If Empty(GDFieldGet("DF4_ITEM",1))
		aColsPM3[nPos,3,1,GDFieldPos("DF4_ITEM")] := StrZero(1,Len(DF4->DF4_ITEM))
	EndIf
	//-- Inicializa todas as linhas do aCols como nao deletado, devido a falha na GetDados
	For nCnt := 1 To Len(aCols)
		aCols[nCnt,Len(aHeader)+1] := .F.
	Next nCnt
EndIf

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 015, .T., .T. } )
AAdd( aObjects, { 100, 085, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgEsp TITLE cTitulo FROM aSize[7]/2,00 TO aSize[6]/2,aSize[5]/2+100 PIXEL

@ aPosObj[1,1],010 SAY STR0023 COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 40 ,9  //'Agendamento:'
@ aPosObj[1,1],050 SAY M->DF0_NUMAGE Of oDlgEsp PIXEL SIZE 29 ,9

@ aPosObj[1,1],120 SAY STR0024 COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 40 ,9  //'Item Agend.:'
@ aPosObj[1,1],155 SAY cItemAge Of oDlgEsp PIXEL SIZE 29 ,9

@ aPosObj[1,1],180 SAY STR0028 COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 40 ,9  //'Produto:'
@ aPosObj[1,1],205 SAY cProduto Of oDlgEsp PIXEL SIZE 100 ,9

oGetPM3:=MSGetDados():New((aPosObj[2,1]/2)+10, aPosObj[2,2]/2, aPosObj[2,3]/2, aPosObj[2,4]/2+50, nOpcx, 'TMSAF05LOk(4)','AllWaysTrue','+DF4_ITEM',nOpcx<>2,aAltGetD)
//-- Atualiza aCols corrigindo a falha na GetDados
If(lAchou,aCols := AClone(aColsPM3[nPos,3]),.T.)
oGetPM3:Refresh(.T.)

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| If(oGetPM3:TudoOk() .And. TMSAF05TM3(nTQtdVol),(nOpcao:= 1,oDlgEsp:End()),.F.) }, {|| oDlgEsp:End() }) CENTERED

//-- Atualiza array de aCols do produto
If nOpcao == 1
	If (nPos:= Ascan( aColsPM3, { |x| x[1]+x[2] == cItemAge+cProduto } ) ) == 0
		AAdd(aColsPM3,{ cItemAge, cProduto, aCols, aHeader } )
	Else
		aColsPM3[nPos,3] := AClone(aCols)
	EndIf
EndIf

RestInter() //-- Restaura Area

//-- Atualiza Campo DF2_PESOM3, depois de restaurar a area.
If nOpcao == 1
	TMSAF05AtuM3()
EndIf

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05TM3 ³ Autor ³ Eduardo de Souza     ³ Data ³ 25/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a digitacao do peso cubado.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05TM3(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Qtde Volumes                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05TM3(nTQtdVol)

Local nCntFor	:= 0
Local nQtdVol	:= 0

For nCntFor := 1 To Len( aCols )
	//-- Nao avalia linhas deletadas.
	If	! GDDeleted( nCntFor )
		nQtdVol += GDFieldGet( 'DF4_QTDVOL', nCntFor )
	EndIf
Next

If nQtdVol > 0 .And. nQtdVol != nTQtdVol
	Help('',1,'TMSAF0507') //-- A soma da qtde de volumes esta diferente da qtde de volumes informado no produto por agendamento.
	Return( .F. )
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05AtuM3³ Autor ³ Eduardo de Souza    ³ Data ³ 25/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o campo DF2_PESOM3                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05AtuM3                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05AtuM3()

Local nPerCub  := 0
Local nPeso    := 0
Local nPesoM3  := 0
Local nPos     := 0
Local nCnt     := 0
Local aColsAux := {}
Local aHeadAux := {}

//-- Cliente de calculo da cotacao
TMSAF05Cli(@cCliCalC,@cLojCalC)
nPerCub := TmsPerCub(GdFieldGet('DF2_CODPRO',n),cCliCalc,cLojCalc)

If !Empty(nPerCub)
	nPeso := GdFieldGet('DF2_PESO',n)
	GdFieldPut('DF2_PESOM3',nPeso + ( nPeso * ( nPerCub / 100 ) ),n)
	//-- Calcula o peso cubado pelo fator de cubagem informado no contrato do cliente
ElseIf !Empty(nFatCub)
	If (nPos:= Ascan( aColsPM3, { |x| x[1]+x[2] == cItemAge+GdFieldGet('DF2_CODPRO',n) } ) ) > 0
		aColsAux := AClone(aColsPM3[nPos,3])
		aHeadAux := AClone(aColsPM3[nPos,4])
		nPesoM3 := 0
		For nCnt := 1 To Len(aColsAux)
			If !GdDeleted(nCnt,aHeadAux,aColsAux)
				nPesoM3 += GDFieldGet('DF4_QTDVOL',nCnt,,aHeadAux,aColsAux) * ;
				           GDFieldGet('DF4_ALTURA',nCnt,,aHeadAux,aColsAux) * ;
				           GDFieldGet('DF4_COMPRI',nCnt,,aHeadAux,aColsAux) * ;
				           GDFieldGet('DF4_LARGUR',nCnt,,aHeadAux,aColsAux)
			EndIf
		Next nCnt
		GdFieldPut('DF2_PESOM3',nPesoM3 * nFatCub,n)
	EndIf
EndIf

//-- Ponto De Entrada Ao Final Da Atualização Do DF2
If ExistBlock("TMF05M3")
	ExecBlock("TMF05M3",.F.,.F.)
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAF05Cli ³ Autor ³ Eduardo de Souza    ³ Data ³ 25/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o cliente para calculo da cotacao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Cli(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Cliente                                            ³±±
±±³          ³ ExpC2 - Loja                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Cli(cCliente,cLoja, nAt)

Local cLocCol    := ""
Local lAgeCotSol := SuperGetMV("MV_AGECOTS",.F.,.F.) //-- Define se a cotacao devera ser realizada sempre para o solicitante.
Local lLeDev     := .F.

Default nAt := n
cLocCol     := GDFieldGet("DF1_LOCCOL",nAt)

If DF1->(ColumnPos("DF1_CLIDEV")) > 0 .And. !Empty(GDFieldGet("DF1_CLIDEV",nAt))
	lLeDev := .T.
EndIf

//-- Utilizar a tabela do cliente generico
If !SuperGetMV("MV_CLICOT",Nil,.F.)
	cCliente := GetMV('MV_CLIGEN')
ElseIf !lLeDev
	If lAgeCotSol .Or. cLocCol == StrZero(1,Len(DF1->DF1_LOCCOL)) //-- Solicitante
		DUE->( DbSetOrder( 1 ) )		
		If DUE->( MsSeek( xFilial('DUE') + M->DF0_CODSOL, .F. ) )
			If Empty (DUE->DUE_CODCLI) .And. Empty (DUE->DUE_LOJCLI)
				cCliente := GetMV('MV_CLIGEN')
			Else
				cCliente := DUE->DUE_CODCLI+DUE->DUE_LOJCLI
			Endif
		Else
			cCliente := GetMV('MV_CLIGEN')
		EndIf
	ElseIf cLocCol == StrZero(2,Len(DF1->DF1_LOCCOL)) //-- Remetente
		cCliente := GDFieldGet("DF1_CLIREM",nAt) + GDFieldGet("DF1_LOJREM",nAt)
	EndIf
ElseIf lLeDev
	cCliente := GDFieldGet("DF1_CLIDEV",nAt) + GDFieldGet("DF1_LOJDEV",nAt)
EndIf
SA1->( DbSetOrder( 1 ) )
If SA1->( !MsSeek( xFilial('SA1') + cCliente, .F. ) )
	Help('',1,'TMSA04005',,STR0030 + cCliente,4,1)	//"Cliente generico nao encontrado (SA1)"###"Cliente / Contrato : "
	Return( .F. )
EndIf
cCliente := SA1->A1_COD
cLoja    := SA1->A1_LOJA

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAF05Cot ³ Autor ³ Eduardo de Souza    ³ Data ³ 28/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cotacao de Frete por Agendamento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Cot(ExpL1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Verifica se altera cotacao                         ³±±
±±³Parametros³ ExpN1 - Valor informado desejado para gerar cotacao        ³±±
±±³Parametros³ ExpL2 - Exibe tela da cotação gerada                       ³±±
±±³Parametros³ ExpL3 - Pergunta se deseja gravar agendamento ou não       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Cot(lAltCot,nVlrInf,lMostraTela,nElem,lAviso,lTudoOk)

Local nAt        := n
Local nCnt       := 0
Local nCnt1      := 0
Local aCotacao   := { {}, {}, {}, {}, {}, {} }
Local aDados     := {}
Local aProdutos  := {}
Local aCubagem   := {}
Local aPesoCub   := {}
Local aTipVei    := {}
Local nPos       := 0
Local nOpcx      := 2
Local cCodsol    := M->DF0_CODSOL
Local cLocCol    := ''
Local cStatus    := ''
Local cItemAge   := ''
Local cFilOri    := ''
Local cTipFre    := ''
Local cSelOri    := ''
Local cCdrOri    := ''
Local cCdrDes    := ''
Local cTipTra    := ''
Local cServic    := ''
Local cCliRem    := ''
Local cLojRem    := ''
Local cCliDes    := ''
Local cLojDes    := ''
Local cCliDev    := ''
Local cLojDev    := ''
Local cFilDoc    := ''
Local cDocto     := ''
Local cSerie     := ''
Local cDistIV    := ''
Local cTipNFc	 := ''
Local aValInf    := {}
Local aValorInf  := {}
Local nOpca      := 0
Local lAchouPrd  := .F.
Local aSetKeyA   := AClone(aSetKey)
Local lAtuCotAux := lAtuCot
Local aTelSol    := {}
Local cNumSol    := CriaVar("DT5_NUMSOL",.F.)
Local aColsAux   := {}
Local aHeadAux   := {}
Local nItem      := 0
Local lRet       := .T.
Local lAgeCotSol := SuperGetMV("MV_AGECOTS",.F.,.F.) //-- Define se a cotacao devera ser realizada sempre para o solicitante.
Local nTotDis    := 0
Local cCliCalC   := ''
Local cLojCalC   := ''
Local lIdentDoc  := DF1->(ColumnPos("DF1_DOCTMS")) > 0
Local nI         := 0
Local aCposUser  := {}
Local aNewCotac  := {}
Local cCodNeg    := ""
Local cObsAgd    := M->DF0_OBS 
Local aHeaderBkp := {}
Local aColsBkp   := {}

Default nVlrInf     := 0
Default lMostraTela := .T.
Default nElem       := n
Default lAviso      := .T.
Default lTudoOk     := .F.

Private l040Auto    := .T.
Private aAutoItens  := {}
Private aAutoCab    := {}
Private cNumCot     := GDFieldGet("DF1_NUMCOT",nElem)

If lTMF05CPO
	aCposUser := ExecBlock("TMF05CPO",.F.,.F.)
EndIf
oEnch:SetFocus()
oEnch:Refresh()

cLocCol  := GDFieldGet("DF1_LOCCOL",nElem)
cStatus  := GDFieldGet("DF1_STACOL",nElem)
cItemAge := GDFieldGet("DF1_ITEAGE",nElem)
cFilOri  := GDFieldGet("DF1_FILORI",nElem)
cTipFre  := GDFieldGet("DF1_TIPFRE",nElem)
cSelOri  := GDFieldGet("DF1_SELORI",nElem)
cCdrOri  := GDFieldGet("DF1_CDRORI",nElem)
cCdrDes  := GDFieldGet("DF1_CDRDES",nElem)
cTipTra  := GDFieldGet("DF1_TIPTRA",nElem)
cServic  := GDFieldGet("DF1_SERVIC",nElem)
cCliRem  := GDFieldGet("DF1_CLIREM",nElem)
cLojRem  := GDFieldGet("DF1_LOJREM",nElem)
cCliDes  := GDFieldGet("DF1_CLIDES",nElem)
cLojDes  := GDFieldGet("DF1_LOJDES",nElem)
cCliDev  := GDFieldGet("DF1_CLIDEV",nElem)
cLojDev  := GDFieldGet("DF1_LOJDEV",nElem)
cFilDoc  := GDFieldGet("DF1_FILDOC",nElem)
cDocto   := GDFieldGet("DF1_DOC"   ,nElem)
cSerie   := GDFieldGet("DF1_SERIE" ,nElem)
cDistIV  := GDFieldGet("DF1_DISTIV",nElem)
cTipNFc  := GDFieldGet("DF1_TIPNFC",nElem)
cCodNeg  := GDFieldGet("DF1_CODNEG",nElem)

If lIdentDoc
	cDocTms := GDFieldGet("DF1_DOCTMS",nElem)
EndIf

If lTMF05Cot
	lRet := ExecBlock("TMF05COT",.F.,.F.)
	If ValType(lRet) <> "L"
		lRet := .F.
	EndIf
	If !lRet
		Return( .F. )
	EndIf
EndIf

//-- Verifica se o valor do frete sera rateado.
If !lTudoOk
	For nCnt := 1 To Len(aCols)
		If !GdDeleted(nCnt)
			If !Empty(GdFieldGet("DF1_SERVIC",nCnt)) .And. Posicione("DC5",1,xFilial("DC5")+GdFieldGet("DF1_SERVIC",nCnt),"DC5_TIPRAT") <> StrZero(0,Len(DC5->DC5_TIPRAT)) //-- Nao Tem
				Help(' ', 1, 'TMSAF0529') //"Existe servico configurado para rateio de frete, o cálculo será efetuado pelo sistema!"
				Return( .F. )
			EndIf
		EndIf
	Next nCnt
EndIf

If nVlrInf == 0
	nVlrInf := GDFieldGet("DF1_VLRINF",nElem) //-- Frete informado da cotacao de frete.
EndIf

//-- Verifica se o usuario tem permissao para executar a Cotacao.
If !TMSAcesso(,'TMSA040')
	Return( .F. )
EndIf

If GDDeleted(nElem)
	Help(" ",1,"TMSAF0516") //-- Para executar a cotacao o agendamento nao podera estar deletado.
	Return( .F. )
EndIf

If 	Empty(cCodSol) .Or.;
	Empty(cFilOri) .Or. Empty(cTipFre) .Or. Empty(cCdrOri) .Or. ;
	Empty(cCdrDes) .Or. Empty(cTipTra) .Or. Empty(cServic) .Or. ;
	Empty(cCliRem) .Or. Empty(cLojRem) .Or. Empty(cCliDes) .Or. ;
	Empty(cLojDes) .Or. Empty(cCliDev) .Or. Empty(cLojDev)
	Help(" ",1,"TMSAF0509") //-- Para executar a cotacao, todos os campos deverao ser preenchidos.
	Return( .F. )
EndIf

//-- Inclui o remetente como solicitante, caso a Coleta seja no remetente.	
//-- Verifica se a cotacao devera ser realizada sempre para o solicitante.
If !lAgeCotSol .And. cLocCol == StrZero(2,Len(DF1->DF1_LOCCOL)) //-- Remetente
	aTelSol := TMSAF05DUE(cCliRem,cLojRem,cTipTra)
	cCodSol := aTelSol[1]
EndIf

//-- Cliente de calculo da cotacao
TMSAF05Cli(@cCliCalC,@cLojCalC)

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

SaveInter() //-- Salva aCols
cCadastro := STR0035 // 'Cotacao de Frete'
n := nAt

If lAltCot .And. ( Inclui .Or. Altera ) .And. ;
	( cStatus == StrZero(1,Len(DF1->DF1_STACOL)) .Or. ; //-- A Confirmar
	  cStatus == StrZero(2,Len(DF1->DF1_STACOL)) .Or. ; //-- Confirmado
	  cStatus == StrZero(3,Len(DF1->DF1_STACOL)) .Or. ; //-- Planejado
	  cStatus == StrZero(4,Len(DF1->DF1_STACOL)) ) //-- Em Processo

	//-- Apresentam as cotacoes aprovadas
	If nVlrInf == 0 .And. SeleItCF(cCliRem,cLojRem,cCliDes,cLojDes)
		cNumCot := GDFieldGet("DF1_NUMCOT",nElem)
	EndIf

	//-- Grava o Agendamento antes de executar a cotacao
	If Inclui .Or. Iif(lAviso,Aviso( STR0036, STR0041 ,{STR0038,STR0039}, 2, '' ) == 1,.T.) //'Atencao'###'Para atualizar a Cotacao de Frete o Agendamento sera gravado, Deseja continuar ?'###'Sim'###'Nao'
		lAtuCot := .F.

		//-- Valida campos obrigatorios
		If Obrigatorio(aGets,aTela) .And. oGetDAge:TudoOk()
			If !Inclui
				If lTMF05CPO
					aColsBkp    := AClone(aCols)
					aHeaderBkp  := AClone(aHeader)
				EndIf
				TMSAF05Grv(If(Inclui,3,4),,.T.)
				If lTMF05CPO
					aCols    := AClone(aColsBkp)
					aHeader  := AClone(aHeaderBkp)
				EndIf
			EndIf
			lAtuCot := lAtuCotAux

			//-- Posiciona na Solicitacao de Coleta
			DT5->(DbSetOrder(4))
			If DT5->(MsSeek(xFilial("DT5")+cFilDoc+cDocto+cSerie))
				cNumSol := DT5->DT5_NUMSOL
			EndIf

			//-- Armazena o total da distancia.
			If M->DF0_TOTDIS > 0
				nTotDis := M->DF0_TOTDIS
			Else
				//-- Retorna a distancia por cliente / regiao.
				nTotDis := TMSDistRot(,.F.,cCdrOri,cCdrDes,cTipTra,cCliCalC,cLojCalC, cDistIV == '1')
			EndIf

			If !Empty(cNumCot)
				If (nTotDis = 0) 
					nTotDis := DT4->DT4_KM
				EndIf
			EndIf

			//-- Cabecalho da Cotacao
			AAdd( aDados, cFilOri ) // Filial Origem
			AAdd( aDados, cCodSol ) // CodSol
			AAdd( aDados, cTipFre ) // Tipo Frete
			AAdd( aDados, cSelOri ) // Seleciona Regiao
			AAdd( aDados, cCdrOri ) // Regiao Origem
			AAdd( aDados, cCdrDes ) // Regiao Destino
			AAdd( aDados, StrZero(3,Len(DT4->DT4_SERTMS))) // Entrega
			AAdd( aDados, cTipTra ) // Tipo Transporte
			AAdd( aDados, cServic ) // Servico
			AAdd( aDados, cCliRem ) // Remetente
			AAdd( aDados, cLojRem ) // Loja Remetente
			AAdd( aDados, cCLiDes ) // Destinatario
			AAdd( aDados, cLojDes ) // Loja Destinatario
			AAdd( aDados, cCliDev ) // Devedor
			AAdd( aDados, cLojDev ) // Loja Devedor
			AAdd( aDados, cNumSol ) // Solicitacao
			AAdd( aDados, nTotDis ) // Total da Distancia
			If M->DF0_TOTDIS > 0
				AAdd( aDados, '2' ) // Distancia Ida/Volta
			Else
				AAdd( aDados, If(M->DF0_TIPDIS == '1',M->DF0_DISTIV,cDistIV)) // Distancia Ida/Volta
			EndIf			
			AAdd( aDados, cTipNFc ) // Tipo de NFC
			If lIdentDoc
				AAdd( aDados, cDocTms) //Tipo Docto Transporte
			EndIf

			AAdd( aDados, StrZero(0,Len(DT4->DT4_CONTRI))) // Contribuinte
			AAdd( aDados, cObsAgd ) // Observação

			AAdd( aDados, cCodNeg ) // Codigo Negociacao

			// Adiciona os campos de ORIGEM (DF1_XXX), informados atraves do PE TMF05CPO()
			// Neste caso soh os campos com origem DF1 e destino DT4 serao adicionados
			For nI := 1 To Len(aCposUser)
				IF SubStr(aCposUser[nI,1],1,3) == "DF1" .AND. SubStr(aCposUser[nI,2],1,3) == "DT4"
					AAdd( aDados, GDFieldGet(aCposUser[nI,1],nElem) )
				EndIF
			Next nI
	
			aCotacao[DADOSCOT] := AClone(aDados)

			//-- Produtos da Cotacao
			If !Empty(cNumCot)
				aCols   := {}
				aHeader := {}
				TMSFillGetDados( 2, "DVF", , xFilial( "DVF" ) + cFilOri + cNumCot , { || DVF->DVF_FILIAL + DVF->DVF_FILORI + DVF->DVF_NUMCOT } )
				aColsAux := AClone(aCols)
				aHeadAux := AClone(aHeader)
			EndIf

			aCols    := {}
			aHeader  := {}
			If (nPos := Ascan( aColsPrd, { |x| x[1] == cItemAge } ) ) == 0
				TMSFillGetDados(nOpcx, "DF2", 1, xFilial("DF2") + M->DF0_NUMAGE + cItemAge , Iif(nOpcx <> 3,{ || DF2->DF2_FILIAL + DF2->DF2_NUMAGE + DF2->DF2_ITEAGE }, {|| ''}), { || .T. } )
			Else
				aCols   := AClone(aColsPrd[nPos,2])
				aHeader := AClone(aColsPrd[nPos,3])
			EndIf

			For nCnt := 1 To Len(aCols)
				//-- Armazena item da cotacao
				If nCnt > Len(aColsAux)
					nItem ++
				Else
					nItem := Val(GDFieldGet("DVF_ITEM",nCnt,,aHeadAux,aColsAux))
					If nItem == 0
						nItem ++
					EndIf
				EndIf
				aDados := {}
				AAdd( aDados, StrZero(nItem,Len(DVF->DVF_ITEM)))	// Item
				AAdd( aDados, GDFieldGet("DF2_CODPRO",nCnt))		// Produto
				AAdd( aDados, GDFieldGet("DF2_CODEMB",nCnt))		// Embalagem
				AAdd( aDados, GDFieldGet("DF2_QTDVOL",nCnt))		// Volumes
				AAdd( aDados, GDFieldGet("DF2_QTDUNI",nCnt))		// Unitizadores
				AAdd( aDados, GDFieldGet("DF2_PESO"  ,nCnt))		// Peso Real
				AAdd( aDados, GDFieldGet("DF2_PESOM3",nCnt))		// Peso Cubado
				AAdd( aDados, GDFieldGet("DF2_METRO3",nCnt))		// Metro Cubico
				AAdd( aDados, GDFieldGet("DF2_VALMER",nCnt))		// Valor da Mercadoria

				// Adiciona os campos de ORIGEM (DF2_XXX), informados atraves do PE TMF05CPO()
				// Neste caso soh os campos com origem DF2 e destino DVF serao adicionados
				For nI := 1 To Len(aCposUser)
					IF SubStr(aCposUser[nI,1],1,3) == "DF2" .and. SubStr(aCposUser[nI,2],1,3) == "DVF"
						AAdd( aDados, GDFieldGet(aCposUser[nI,1],nCnt) )
					EndIF
				Next nI 
				AAdd( aDados, GDDeleted(nCnt) ) // Deletado (T/F)
				AAdd( aProdutos, AClone(aDados) )
				If !Empty(aDados[2])
					lAchouPrd := .T.
				EndIf
			Next nCnt
			aCotacao[PRODCOT] := AClone(aProdutos)

			If lAchouPrd
				//-- Valor Informado por Produto
				For nCnt := 1 To Len(aProdutos)
					aCols    := {}
					aHeader  := {}
					aValInf  := {}
					If (nPos:= Ascan( aColsVInf, { |x| x[1]+x[2] == cItemAge + aProdutos[nCnt,2] } ) ) == 0
						TMSFillGetDados(nOpcx, "DF3", 1, xFilial("DF3") + M->DF0_NUMAGE + cItemAge + aProdutos[nCnt,2] , Iif(nOpcx <> 3,{ || DF3->DF3_FILIAL + DF3->DF3_NUMAGE + DF3->DF3_ITEAGE + DF3->DF3_CODPRO }, {|| ''}), { || .T. } )
					Else
						aCols    := AClone(aColsVInf[nPos,3])
						aHeader  := AClone(aColsVInf[nPos,4])
					EndIf
					For nCnt1 := 1 To Len(aCols)
						aDados := {}
						AAdd( aDados, GDFieldGet("DF3_CODPAS",nCnt1)) // Componente
						AAdd( aDados, GDFieldGet("DF3_VALOR" ,nCnt1)) // Quantidade
						AAdd( aDados, GDDeleted(nCnt1) ) // Deletado (T/F)
						AAdd( aValInf, AClone(aDados) )
					Next nCnt1
					AAdd( aValorInf, { aProdutos[nCnt,2], AClone(aValInf) } )
				Next nCnt
				aCotacao[VALINFCOT] := AClone(aValorInf)

				//-- Cubagem por Produto
				For nCnt := 1 To Len(aProdutos)
					aCols    := {}
					aHeader  := {}
					aPesoCub := {}
					If (nPos:= Ascan( aColsPM3, { |x| x[1]+x[2] == cItemAge + aProdutos[nCnt,2] } ) ) == 0
						TMSFillGetDados(nOpcx, "DF4", 1, xFilial("DF4") + M->DF0_NUMAGE + cItemAge + aProdutos[nCnt,2] , Iif(nOpcx <> 3,{ || DF4->DF4_FILIAL + DF4->DF4_NUMAGE + DF4->DF4_ITEAGE + DF4->DF4_CODPRO }, {|| ''}), { || .T. } )
					Else
						aCols    := AClone(aColsPM3[nPos,3])
						aHeader  := AClone(aColsPM3[nPos,4])
					EndIf
					For nCnt1 := 1 To Len(aCols)
						aDados := {}
						AAdd( aDados, GDFieldGet("DF4_QTDVOL",nCnt1)) // Volumes
						AAdd( aDados, GDFieldGet("DF4_ALTURA",nCnt1)) // Altura
						AAdd( aDados, GDFieldGet("DF4_LARGUR",nCnt1)) // Largura
						AAdd( aDados, GDFieldGet("DF4_COMPRI",nCnt1)) // Comprimento
						AAdd( aDados, GDDeleted(nCnt1) ) // Deletado (T/F)
						AAdd( aPesoCub, AClone(aDados) )
					Next nCnt1
					AAdd( aCubagem, { aProdutos[nCnt,2], AClone(aPesoCub) } )
				Next nCnt
				aCotacao[CUBCOT] := AClone(aCubagem)

				//-- Tipos de Veiculo da Cotacao
				aCols    := {}
				aHeader  := {}
				If (nPos := Ascan( aColsTip, { |x| x[1] == cItemAge } ) ) == 0
					TMSFillGetDados(nOpcx, "DF5", 1, xFilial("DF5") + M->DF0_NUMAGE + cItemAge , { || DF5->DF5_FILIAL + DF5->DF5_NUMAGE + DF5->DF5_ITEAGE }, { || .T. } )
				Else
					aCols   := AClone(aColsTip[nPos,2])
					aHeader := AClone(aColsTip[nPos,3])
				EndIf
				For nCnt := 1 To Len(aCols)
					aDados := {}
					AAdd( aDados, GDFieldGet("DF5_ITEM"  ,nCnt)) // Item
					AAdd( aDados, GDFieldGet("DF5_TIPVEI",nCnt)) // Tipo Veiculo
					AAdd( aDados, GDFieldGet("DF5_QTDVEI",nCnt)) // Qtde Veiculo
					AAdd( aDados, GDDeleted(nCnt) ) // Deletado (T/F)
					AAdd( aTipVei, AClone(aDados) )
				Next nCnt
				aCotacao[TIPVEICOT] := AClone(aTipVei)

				//-- Valor Informado de frete [1] Vlr Total [2] Saldo Para evitar sobra
				If nVlrInf > 0
					aCotacao[FRTINFCOT] := {nVlrInf,nVlrInf}
					lMostraTela := .F.
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³PONTO DE ENTRADA QUE PERMITE MANIPULAR OS³
				//³DADOSDA COTACAO A SER GERADA/ALTERADA    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lTMF05Mod
					aNewCotac := ExecBlock('TMF05MOD',.F.,.F.,{aCotacao})
					If ValType(aNewCotac) == 'A' .And.;
						ValType(aNewCotac[DADOSCOT]) == 'A' .And.;
						ValType(aNewCotac[PRODCOT]) == 'A' .And.;
						ValType(aNewCotac[VALINFCOT]) == 'A' .And.;
						ValType(aNewCotac[CUBCOT]) == 'A' .And.;
						ValType(aNewCotac[TIPVEICOT]) == 'A' .And.;
						ValType(aNewCotac[FRTINFCOT]) == 'A'

						aCotacao := aClone(aNewCotac)
					EndIf
				EndIf

				If !Empty(cNumCot)
					DT4->(DbSetOrder(1))
					DT4->(MsSeek(xFilial("DT4")+cFilOri+cNumCot))
					nOpca := TMSA040Mnt( "DT4", 0, 4 , , aCotacao, cNumSol, cNumCot, lMostraTela )
				Else
					nOpca := TMSA040Mnt( "DT4", 0, 3 , , aCotacao, cNumSol, CriaVar("DT4_NUMCOT",.F.), lMostraTela)
				EndIf
			Else
				Help(" ",1,"TMSAF0510") //-- Para executar a cotacao, os produtos deverao ser preenchidos.	
				lRet := .F.
			EndIf
		EndIf
	EndIf

	RestInter() //-- Retaura aCols

	If nOpca == 1
		//-- Atualiza Campos da Cotacao
		GDFieldPut("DF1_NUMCOT",cNumCot,nElem)
		If (nTotDis <> 0)
			GDFieldPut("DF1_DISTAN",nTotDis,nElem)
		EndIf
		TMSAF05TCot(cFilOri,cNumCot,nElem)
		lAtuCot := .F.
	Else
		lRet    := .F.
	EndIf
Else
	//-- Visualiza cotacao
	If !Empty(cNumCot)
		n := 1
		l040Auto := .F.
		DT4->(DbSetOrder(1))
		DT4->(MsSeek(xFilial("DT4")+cFilOri+cNumCot))
		TMSA040Mnt("DT4",0,2,,,,,lMostraTela)
	EndIf
	RestInter() //-- Retaura aCols
EndIf

aSetKey   := AClone(aSetKeyA)
TmsKeyOn(aSetKey) //-- Restaura SetKey

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAF05Ini ³ Autor ³ Eduardo de Souza    ³ Data ³ 28/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa dados da cotacao por Agendamento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Ini(ExpA1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array contendo informacoes da cotacao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Ini(aCotacao, nOpcx, lMntBase)

Local aCposCab   := {}
Local aCposPrd   := {}
Local aCposPM3   := {}
Local aCposVInf  := {}
Local aCposTip   := {}
Local nCnt       := {}
Local nCnt1      := {}
Local nCnt2      := {}
Local nValProdut := 0 //-- Valor informado dividido por produto
Local aColsDTE   := {}
Local aHeadDVQ   := {}
Local aColsDVQ   := {}
Local lDeletado  := .F.
Local lRet       := .T.
Local lAtuPM3    := .T.
Local lSrvRateio := .F.
Local nI         := 0
Local aCposUser  := {}
Local lAssumeFrt := (!Empty(aCotacao) .And. Len(aCotacao) >= 7 .And. !Empty(aCotacao[FRTCMPCOT]))
Local nPosCodneg := 0
Local nPosdoctms := 0
Local lIdentDoc  := DT4->(ColumnPos("DT4_DOCTMS")) > 0
Local lFechado   := GetMv("MV_COTVFEC",,.F.)  //-- Permite a digitacao de Valor Fechado por componente
Local aFldDVQ	 := {}
Local aFldDTE	 := {}
Local aFldDVT 	 := {}

Default lMntBase := .F.

If lTMF05CPO
	aCposUser := ExecBlock("TMF05CPO",.F.,.F.)
EndIf

cNumCot := M->DT4_NUMCOT

// ATENÇÃO!!!!!!!!!!
// Se alterar a posição dos campos deste array deve ordernar 
// o array aDadosDT4 da função TMSAE75Pre
AAdd(aCposCab, "DT4_FILORI") // Filial Origem
AAdd(aCposCab, "DT4_CODSOL") // Cod.Solicitante
AAdd(aCposCab, "DT4_TIPFRE") // Tipo Frete
AAdd(aCposCab, "DT4_SELORI") // Seleciona Regiao
AAdd(aCposCab, "DT4_CDRORI") // Regiao Origem
AAdd(aCposCab, "DT4_CDRDES") // Regiao Destino
AAdd(aCposCab, "DT4_SERTMS") // Servico de Transporte
AAdd(aCposCab, "DT4_TIPTRA") // Tipo Transporte
AAdd(aCposCab, "DT4_SERVIC") // Servico
AAdd(aCposCab, "DT4_CLIREM") // Remetente
AAdd(aCposCab, "DT4_LOJREM") // Loja Remetente
AAdd(aCposCab, "DT4_CLIDES") // Destinatario
AAdd(aCposCab, "DT4_LOJDES") // Loja Destinatario
AAdd(aCposCab, "DT4_CLIDEV") // Devedor
AAdd(aCposCab, "DT4_LOJDEV") // Loja Devedor
AAdd(aCposCab, "DT4_NUMSOL") // Solicitacao
AAdd(aCposCab, "DT4_KM"    ) // Total da Distancia
AAdd(aCposCab, "DT4_DISTIV") // Distancia Ida/Volta
AAdd(aCposCab, "DT4_TIPNFC") // Tipo de NFC

If lIdentDoc
	AAdd(aCposCab, "DT4_DOCTMS") // Tipo Documento
	nPosdoctms := Ascan(aCposCab, { |x| x == "DT4_DOCTMS" } )
EndIf 

AAdd(aCposCab, "DT4_CONTRI") // Contribuinte
AAdd(aCposCab, "DT4_OBS")    // Observação
AAdd(aCposCab, "DT4_CODNEG") // Codigo Negocicacao
nPosCodneg := Ascan(aCposCab, { |x| x == "DT4_CODNEG" } )

// Adiciona os campos de DESTINO (DT4_XXX), informados atraves do PE TMF05CPO()
// Neste caso soh os campos com origem DF1 e destino DT4 serao adicionados
For nI := 1 To Len(aCposUser)
	If SubStr(aCposUser[nI,1],1,3) == "DF1" .and. SubStr(aCposUser[nI,2],1,3) == "DT4"
		AAdd(aCposCab, aCposUser[nI,2])
	EndIf
Next nI

//-- Inicializa o cabecalho da cotacao
For nCnt := 1 To Len(aCposCab)
	If nCnt <= Len(aCotacao[DADOSCOT])
		M->&(aCposCab[nCnt]) := aCotacao[DADOSCOT,nCnt]
		__Readvar := "M->"+aCposCab[nCnt]
		//-- Validacao da Cotacao
		If !Empty(M->&(aCposCab[nCnt])) .And. !IsInCallStack('TMSA050')
			If TMSA040Vld(aCotacao)
				//-- Executa Gatilhos
				If ExistTrigger(aCposCab[nCnt])
					RunTrigger(1,,,,aCposCab[nCnt])
				EndIf
			EndIf
		EndIf
	EndIf
	//-- Atualiza o campo referente ao ISS no preco
	If nCnt == Len(aCposCab)
		M->DT4_PESSOA := If(Posicione("SA1",1,xFilial("SA1")+M->DT4_CLIDEV+M->DT4_LOJDEV,"A1_TIPO")=="F","1","2")
		M->DT4_INCISS := If(SA1->A1_INCISS=="S","1","2")
	EndIf
Next nCnt

If nPosCodneg > 0 .And. Empty(M->DT4_CODNEG)
	M->DT4_CODNEG :=  M->DTC_CODNEG	
Endif

If Empty(M->DT4_SERVIC) .And. !Empty(M->DTC_SERVIC) .And. IsInCallStack('TMSA040Mnt')
	M->DT4_SERVIC :=  M->DTC_SERVIC
EndIf

If nPosdoctms > 0 .And. Empty(M->DT4_DOCTMS) .And. IsInCallStack('TMSAF05')
	M->DT4_DOCTMS := aCotacao[1][20]
	M->DT4_CONTRI := StrZero(0,Len(DT4->DT4_CONTRI))
ElseIf nPosdoctms > 0 .And. Empty(M->DT4_DOCTMS) .And. IsInCallStack('TMSA050')
	M->DT4_DOCTMS := aCotacao[1][18]
	M->DT4_TIPNFC := aCotacao[1][19]
EndIf 

//-- Produtos da Cotacao
AAdd(aCposPrd, "DVF_ITEM"  ) // Item
AAdd(aCposPrd, "DVF_CODPRO") // Produto
AAdd(aCposPrd, "DVF_CODEMB") // Embalagem
AAdd(aCposPrd, "DVF_QTDVOL") // Qtde Volumes
AAdd(aCposPrd, "DVF_QTDUNI") // Qtde Unitizadores
AAdd(aCposPrd, "DVF_PESO"  ) // Peso
AAdd(aCposPrd, "DVF_PESOM3") // Peso M3
AAdd(aCposPrd, "DVF_METRO3") // Metro Cubico
AAdd(aCposPrd, "DVF_VALMER") // Valor da Mercadoria

// Adiciona os campos de DESTINO (DVF_XXX), informados atraves do PE TMF05CPO()
// Neste caso soh os campos com origem DF2 e destino DVF serao adicionados
For nI := 1 To Len(aCposUser)
	IF SubStr(aCposUser[nI,1],1,3) == "DF2" .and. SubStr(aCposUser[nI,2],1,3) == "DVF"
		AAdd(aCposPrd, aCposUser[nI,2])
	EndIf
Next nI
aCols := {}
For nCnt := 1 To Len(aCotacao[PRODCOT]) // aCols Produtos por Agendamento
	n := nCnt
	//-- Cria uma nova linha para o aCols
	TMSAF05New(@aCols,@aHeader)
	For nCnt1 := 1 To Len(aCposPrd)
		M->&(aCposPrd[nCnt1]) := aCotacao[PRODCOT,nCnt,nCnt1]
		__Readvar := "M->"+aCposPrd[nCnt1]
		//-- Validacao da Cotacao
		If !Empty(M->&(aCposPrd[nCnt1]))
			If TMSA040Vld()
				GDFieldPut(aCposPrd[nCnt1],M->&(aCposPrd[nCnt1]),nCnt)
				//-- Executa Gatilhos
				If ExistTrigger(aCposPrd[nCnt1])
					RunTrigger(2,nCnt,,,aCposPrd[nCnt1])
				EndIf
			EndIf
		EndIf
	Next nCnt1
	aCols[nCnt,Len(aHeader)+1] := aCotacao[PRODCOT,nCnt,Len(aCotacao[PRODCOT,nCnt])] //-- Verifica se o item esta deletado
Next nCnt

//-- Valor Informado por Agendamento
AAdd(aCposVInf, "DVQ_CODPAS" ) //-- Componente
AAdd(aCposVInf, "DVQ_VALOR"  ) //-- Quantidade

If Empty(aHeadDVQ)
	aFldDVQ := ApBuildHeader("DVQ")
	For nI := 1 To Len(aFldDVQ)
		aAdd(aHeadDVQ, aFldDVQ[nI])
	Next
EndIf

aSize(aFldDVQ, 0)
aFldDVQ := Nil

aValInf := {}
For nCnt := 1 To Len(aCotacao[VALINFCOT])
	aColsDVQ := {}
	For nCnt1 := 1 To Len(aCotacao[VALINFCOT,nCnt,2]) // aCols (Valor Informado)
		n := nCnt1
		//-- Cria uma nova linha para o aCols
		TMSAF05New(@aColsDVQ,@aHeadDVQ)
		For nCnt2 := 1 To Len(aCposVInf)
			M->&(aCposVInf[nCnt2]) := aCotacao[VALINFCOT,nCnt,2,nCnt1,nCnt2]
			__Readvar := "M->"+aCposVInf[nCnt2]
			//-- Validacao da Cotacao
			If !Empty(M->&(aCposVInf[nCnt2])) 
				If TMSA040Vld()
					GDFieldPut(aCposVInf[nCnt2],M->&(aCposVInf[nCnt2]),nCnt1,aHeadDVQ,aColsDVQ)
					//-- Executa Gatilhos
					If ExistTrigger(aCposVInf[nCnt2])
						RunTrigger(2,nCnt,,,aCposVInf[nCnt2])
					EndIf
				EndIf
			EndIf
		Next nCnt2
		lDeletado := .F.
		If aCotacao[VALINFCOT,nCnt,2,nCnt1,Len(aCotacao[VALINFCOT,nCnt,2,nCnt1])] //-- Verifica se o item esta deletado
			lDeletado := .T.
		EndIf
		AAdd(aValInf,{GdFieldGet('DVQ_CODPAS',nCnt1,,aHeadDVQ,aColsDVQ),GdFieldGet('DVQ_VALOR',nCnt1,,aHeadDVQ,aColsDVQ),lDeletado,M->DT4_NUMCOT,'',aCotacao[VALINFCOT,nCnt,1]})
	Next nCnt1
Next nCnt

//-- Se nso encontrar nenhum componente preenchido, zera o vetor.
If Len(aValInf) == 1 .And. Empty(aValInf[1,1])
	aValInf := {}
EndIf

//-- Cubagem por Agendamento
AAdd(aCposPM3, "DTE_QTDVOL" ) //-- Volumes
AAdd(aCposPM3, "DTE_ALTURA" ) //-- Altura
AAdd(aCposPM3, "DTE_LARGUR" ) //-- Largura
AAdd(aCposPM3, "DTE_COMPRI" ) //-- Comprimento

//-- Variavel aHeadDTE utilizada do programa de Cotacao
If Empty(aHeadDTE)
	aFldDTE := ApBuildHeader("DTE")
	For nI := 1 To Len(aFldDTE)
		aAdd(aHeadDTE, aFldDTE[nI])
	Next
EndIf

aSize(aFldDTE, 0)
aFldDTE := Nil

aCubagem := {}
For nCnt := 1 To Len(aCotacao[CUBCOT])
	aColsDTE := {}
	For nCnt1 := 1 To Len(aCotacao[CUBCOT,nCnt,2]) // aCols (Cubagem)
		n       := nCnt1
		lAtuPM3 := .F.
		//-- Cria uma nova linha para o aCols
		TMSAF05New(@aColsDTE,@aHeadDTE)
		For nCnt2 := 1 To Len(aCposPM3)
			M->&(aCposPM3[nCnt2]) := aCotacao[CUBCOT,nCnt,2,nCnt1,nCnt2]
			__Readvar := "M->"+aCposPM3[nCnt2]
			//-- Validacao da Cotacao
			If !Empty(M->&(aCposPM3[nCnt2]))
				lAtuPM3 := .T.
				If TMSA040Vld()
					GDFieldPut(aCposPM3[nCnt2],M->&(aCposPM3[nCnt2]),nCnt1,aHeadDTE,aColsDTE)
					//-- Executa Gatilhos
					If ExistTrigger(aCposPM3[nCnt2])
						RunTrigger(2,nCnt,,,aCposPM3[nCnt2])
					EndIf
				EndIf
			EndIf
		Next nCnt2
		aColsDTE[nCnt1,Len(aHeadDTE)+1] := aCotacao[CUBCOT,nCnt,2,nCnt1,Len(aCotacao[CUBCOT,nCnt,2,nCnt1])] //-- Verifica se o item esta deletado
		If !lAtuPM3
			aColsDTE := {}
		EndIf
	Next nCnt1
	If !Empty(aColsDTE)
		AAdd(aCubagem,{aCotacao[CUBCOT,nCnt,1],AClone(aColsDTE)})
	EndIf
Next nCnt

//-- Tipos de Veiculo por Agendamento
AAdd(aCposTip, "DVT_ITEM"  ) // Item
AAdd(aCposTip, "DVT_TIPVEI") // Tipo Veiculo
AAdd(aCposTip, "DVT_QTDVEI") // Qtde Veiculo

aHeaderDVT:={}
aFldDVT := ApBuildHeader("DVT")
For nI := 1 To Len(aFldDVT)
	aAdd(aHeaderDVT, aFldDVT[nI])
Next

aSize(aFldDVT, 0)
aFldDVT := Nil

SaveInter() //-- Salva aCols

aHeader := AClone(aHeaderDVT)
aCols   := {}
For nCnt := 1 To Len(aCotacao[TIPVEICOT])
	n := nCnt
	//-- Cria uma nova linha para o aCols
	TMSAF05New(@aCols,@aHeader)
	For nCnt1 := 1 To Len(aCposTip)
		M->&(aCposTip[nCnt1]) := aCotacao[TIPVEICOT,nCnt,nCnt1]
		__Readvar := "M->"+aCposTip[nCnt1]
		//-- Validacao da Cotacao
		If !Empty(M->&(aCposTip[nCnt1])) 
			If TMSA040Vld()
				GDFieldPut(aCposTip[nCnt1],M->&(aCposTip[nCnt1]),nCnt)
				//-- Executa Gatilhos
				If ExistTrigger(aCposTip[nCnt1])
					RunTrigger(2,nCnt,,,aCposTip[nCnt1])
				EndIf
			EndIf
		EndIf
	Next nCnt1
	aCols[nCnt,Len(aHeader)+1] := aCotacao[TIPVEICOT,nCnt,Len(aCotacao[TIPVEICOT,nCnt])] //-- Verifica se o item esta deletado
Next nCnt
aColsDVT := AClone(aCols)

RestInter() //-- Restaura aCols
n := 1      //-- Reset 'n'
//-- Verifica se o servico utiliza rateio de frete.
lSrvRateio := Posicione("DC5",1,xFilial("DC5")+aCotacao[DADOSCOT,9],"DC5_TIPRAT") <> StrZero(0,Len(DC5->DC5_TIPRAT))

//-- Calcula a composicao do frete
If ( nOpcx == 3 .Or. nOpcx == 4 )
	If Left(FunName(),7) == "TMSAE75"
		If !Empty(aCotacao[FRTINFCOT]) 
			l040Auto   := .T.		
			lRet := TMSA040Dsc(nValProdut,lSrvRateio,aCotacao,lMntBase)
		ElseIf lAssumeFrt
			l040Auto   := .T.
			lRet := TMSA040Dsc(,lSrvRateio,aCotacao,lMntBase)
		Else
			lRet := TmsA040Atz(aCotacao, , , lMntBase)
		EndIf
	Else
		If !Empty(aCotacao[FRTINFCOT]) .And. !lFechado  //-- Valor informado
			nValProdut := aCotacao[FRTINFCOT,2]
			l040Auto   := .T.		
			lRet := TMSA040Dsc(nValProdut,lSrvRateio,aCotacao,lMntBase)
		ElseIf lAssumeFrt .And. !lFechado
			l040Auto   := .T.
			lRet := TMSA040Dsc(,lSrvRateio,aCotacao,lMntBase)
		Else
			lRet := TmsA040Atz(aCotacao, , ,lMntBase)
		EndIf
	EndIf
EndIf

//-- Verifica se o servico utiliza rateio de frete.
If lSrvRateio
	lRet := .T.
EndIf

If !lRet
	Help(' ',1,'TMSAF0530')
	cNumCot := Space(Len(DT4->DT4_NUMCOT))
	If __lSX8
		RollBackSX8()
	EndIf
EndIf

l040Auto := .F.

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAF05New ³ Autor ³ Eduardo de Souza    ³ Data ³ 29/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria uma nova linha para o aCols                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05New(ExpA1,ExpA2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - aCols                                              ³±±
±±³          ³ ExpA2 - aHeader                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05New(aColsNew,aHeadNew)

Local nI := 0

//-- Cria uma nova linha para o aCols
AAdd(aColsNew,Array(Len(aHeadNew)+1))
For nI = 1 To Len(aHeadNew)
	If aHeadNew[nI,8] == "C"
		aColsNew[Len(aColsNew),nI] := Space(aHeadNew[nI,4])
	ElseIf aHeadNew[nI,8] == "N"
		aColsNew[Len(aColsNew),nI] := 0
	ElseIf aHeadNew[nI,8] == "D"
		aColsNew[Len(aColsNew),nI] := CtoD("  /  /  ")
	ElseIf aHeadNew[nI,8] == "M"
		aColsNew[Len(aColsNew),nI] := ""
	Else
		aColsNew[Len(aColsNew),nI] := .F.
	EndIf
Next nI
aColsNew[Len(aColsNew),Len(aHeadNew)+1] := .F.

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ SeleItCF   ³ Autor ³ Eduardo de Souza    ³ Data ³ 30/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seleciona Cotacao Aprovadas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SeleItCF(ExpC1,ExpC2,ExpC3,ExpC4)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Remetente                                          ³±±
±±³          ³ ExpC2 - Loja Remetente                                     ³±±
±±³          ³ ExpC3 - Destinatario                                       ³±±
±±³          ³ ExpC4 - Loja Destinatario                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SeleItCF(cCliRem,cLojRem,cCliDes,cLojDes)

Local cSertms   := ""
Local cItemAge  := GDFieldGet("DF1_ITEAGE",n)
Local cNumCot   := GDFieldGet("DF1_NUMCOT",n)
Local cFilOri   := GDFieldGet("DF1_FILORI",n)
Local aCposCab  := {}
Local aCposPrd  := {}
Local aCposVInf := {}
Local aCposPM3  := {}
Local aCotacao  := {}
Local aColsDVF  := {}
Local aHeadDVF  := {}
Local aColsDVQ  := {}
Local aHeadDVQ  := {}
Local aColsDTE  := {}
Local aHeadDTE  := {}
Local nCnt      := 0
Local nCnt1     := 0
Local nCnt2     := 0
Local aAreaDF1  := DF1->(GetArea())
Local aAreaDT5  := DT5->(GetArea())
Local lAtuTot   := .F.
Local nTQtdVol  := 0
Local nTPeso    := 0
Local nTPesoM3  := 0
Local nTM3      := 0
Local nTValMer  := 0
Local lAltPrd   := .T.
Local nPos      := 0
Local lRet      := .F.
Local lIdentDoc := DF1->(ColumnPos("DF1_DOCTMS")) > 0
//-- Ponto de entrada para cotacoes de frete aprovadas!
Local lTMF05CFA:= ExistBlock('TMF05CFA')
Local aFldDF2	:= {}
Local nI		:= 0
Local aFldDF3	:= {}
Local aFldDF4	:= {}
Local cSeek     := ""

Private cCliCalC := ""
Private cLojCalC := ""
Private cServic := GDFieldGet("DF1_SERVIC",n)
Private cTipFre := GDFieldGet("DF1_TIPFRE",n)

Default cCliRem := GDFieldGet("DF1_CLIREM",n)
Default cLojRem := GDFieldGet("DF1_LOJREM",n)
Default cCliDes := GDFieldGet("DF1_CLIDES",n)
Default cLojDes := GDFieldGet("DF1_LOJDES",n)

If !Empty(cNumCot) .Or. Empty(cCliRem) .Or. Empty(cLojRem) .Or.  Empty(cCliDes) .Or. Empty(cLojDes)
	Return( .T. )
EndIf

//-- Cliente de calculo da cotacao
TMSAF05Cli(@cCliCalC,@cLojCalC)

//-- Apresenta Tela contendo as Cotacao de Frete Aprovadas
If TMSAF05CApr(cFilOri,cCliRem,cLojRem,cCliDes,cLojDes)
	lRet    := .T.
	cSertms := Posicione('DC5',1,xFilial('DC5') + DT4->DT4_SERVIC,'DC5_SERTMS')
	If cSertms <> StrZero( 3, Len(DC5->DC5_SERTMS) )
		Help("",1,"TMSAF0511") // A Cotacao de Frete informada nao possue servico de Entrega.
		Return( .F. )
	Else

		//-- Verifica se a cotacao esta sendo utilizado por outro agendamento
		DF1->(DbSetOrder(2))
		If DF1->(MsSeek(xFilial("DF1")+cFilOri+DT4->DT4_NUMCOT)) .Or. ;
			Ascan(aCols, { |x| x[GDFieldPos("DF1_FILORI")]+x[GDFieldPos("DF1_NUMCOT")] == cFilOri+DT4->DT4_NUMCOT } ) > 0
			Help(" ",1,"TMSAF0512") // Cotacao esta sendo utilizado por outro agendamento.
			RestArea( aAreaDF1 )
			Return( .F. )
		EndIf
		RestArea( aAreaDF1 )

		DT5->(dbSetOrder(5))
		If DT5->(MsSeek(cSeek:=xFilial('DT5')+cFilOri+DT4->DT4_NUMCOT))
			Do While DT5->(!Eof()) .And. DT5->DT5_FILIAL+DT5->DT5_FILORI+DT5->DT5_NUMCOT == cSeek
				If !Empty(DT5->DT5_NUMSOL) .And. DT5->DT5_STATUS <> StrZero(9, Len(DT5->DT5_STATUS)) // Cancelada
					Help('',1,'TMSA46015',,DT5->DT5_NUMSOL,3,1) //-- Esta Cotacao ja esta sendo utilizada na Solicitacao de Coleta No. :
					RestArea( aAreaDT5 )
					Return( .F. )
				EndIf
				DT5->(dbSkip())
			EndDo
		EndIf
		RestArea( aAreaDT5 )
		
		//-- Verifica se existem produtos informados no item do agendamento
		If Ascan( aColsPrd, { |x| x[1] == cItemAge } ) > 0
			lAltPrd := Aviso( STR0036, STR0037 ,{STR0038,STR0039}, 2, '' ) == 1 //'Atencao'###'Existem Produtos informados para o item, deseja sobrescrever com os produtos da cotacao ?'###'Sim'###'Nao'
		EndIf

		//-- Armazena as cotacoes que nao foram incluidas pelo agendamento
		//-- Utilizada para nao excluir as cotacoes que nao foram incluidas atraves do agendamento
		AAdd( aNoDelCot, DT4->DT4_NUMCOT )

		//-- Item do Agendamento
		AAdd(aCposCab, "DF1_NUMCOT" ) //-- Numero da Cotacao
		AAdd(aCotacao, DT4->DT4_NUMCOT )
		AAdd(aCposCab, "DF1_TIPTRA" ) //-- Tipo Transporte
		AAdd(aCotacao, DT4->DT4_TIPTRA )
		AAdd(aCposCab, "DF1_TIPFRE" ) //-- Tipo Frete
		AAdd(aCotacao, DT4->DT4_TIPFRE )
		AAdd(aCposCab, "DF1_SELORI" ) //-- Seleciona Origem
		AAdd(aCotacao, DT4->DT4_SELORI )
		AAdd(aCposCab, "DF1_CDRORI" ) //-- Regiao Origem
		AAdd(aCotacao, DT4->DT4_CDRORI )
		AAdd(aCposCab, "DF1_CDRDES" ) //-- Regiao Destino
		AAdd(aCotacao, DT4->DT4_CDRDES )
		AAdd(aCposCab, "DF1_SERTMS" ) //-- Servico de Transporte
		AAdd(aCotacao, DT4->DT4_SERTMS )
		AAdd(aCposCab, "DF1_CLIDEV" ) //-- Cliente Devedor
		AAdd(aCotacao, DT4->DT4_CLIDEV )
		AAdd(aCposCab, "DF1_LOJDEV" ) //-- Loja Devedor
		AAdd(aCotacao, DT4->DT4_LOJDEV )
		AAdd(aCposCab, "DF1_SERVIC" ) //-- Servico
		AAdd(aCotacao, DT4->DT4_SERVIC )
		AAdd(aCposCab, "DF1_CODNEG" ) //-- Codigo NegociaçãoServico
		AAdd(aCotacao, DT4->DT4_CODNEG )
		
		If lIdentDoc
			AAdd(aCposCab, "DF1_DOCTMS" ) //-- Tipo Documento
			AAdd(aCotacao, DT4->DT4_DOCTMS )
		EndIf
		
		//-- Inicializa o cabecalho da cotacao
		For nCnt := 1 To Len(aCposCab)
			M->&(aCposCab[nCnt]) := aCotacao[nCnt]
			__Readvar := "M->"+aCposCab[nCnt]
			//-- Validacao da Cotacao
			If !Empty(M->&(aCposCab[nCnt])) 
				If TMSAF05Vld()
					GDFieldPut(aCposCab[nCnt],M->&(aCposCab[nCnt]),n)
					//-- Executa Gatilhos
					If ExistTrigger(aCposCab[nCnt])
						RunTrigger(2,n,,oGetDAge,aCposCab[nCnt])
					EndIf
				EndIf
			EndIf
		Next nCnt

		//-- Verifica se sobrescrevem os produtos informados no item do agendamento
		If lAltPrd
			SaveInter() //-- Salva aCols
			//-- Produtos da Cotacao
			aCols   := {}
			aHeader := {}
			TMSFillGetDados( 2,'DVF', 1, xFilial('DVF') + cFilOri + DT4->DT4_NUMCOT, { || DVF->DVF_FILIAL + DVF->DVF_FILORI + DVF->DVF_NUMCOT } )
			aColsDVF := AClone(aCols)
			aHeadDVF := AClone(aHeader)

			AAdd(aCposPrd, "DF2_ITEM"  ) // Item
			AAdd(aCposPrd, "DF2_CODPRO") // Produto
			AAdd(aCposPrd, "DF2_CODEMB") // Embalagem
			AAdd(aCposPrd, "DF2_QTDVOL") // Qtde Volumes
			AAdd(aCposPrd, "DF2_QTDUNI") // Qtde Unitizadores
			AAdd(aCposPrd, "DF2_PESO"  ) // Peso
			AAdd(aCposPrd, "DF2_PESOM3") // Peso M3
			AAdd(aCposPrd, "DF2_METRO3") // Peso M3
			AAdd(aCposPrd, "DF2_VALMER") // Valor da Mercadoria

			aCols    := {}
			aHeader  := {}
			
			aFldDF2 := ApBuildHeader("DF2")
			For nI := 1 To Len(aFldDF2)
				aAdd(aHeader, aFldDF2[nI])
			Next

			aSize(aFldDF2, 0)
			aFldDF2 := Nil

			For nCnt := 1 To Len(aColsDVF)
				n := nCnt
				//-- Cria uma nova linha para o aCols
				TMSAF05New(@aCols,@aHeader)
				For nCnt1 := 1 To Len(aCposPrd)
					M->&(aCposPrd[nCnt1]) := aColsDVF[nCnt,GDFieldPos(StrTran(aCposPrd[nCnt1],"DF2_","DVF_"),aHeadDVF,aColsDVF)]
					__Readvar := "M->"+aCposPrd[nCnt1]
					//-- Validacao da Cotacao
					If !Empty(M->&(aCposPrd[nCnt1])) 
						If TMSAF05Vld()
							GDFieldPut(aCposPrd[nCnt1],M->&(aCposPrd[nCnt1]),nCnt)
							//-- Executa Gatilhos
							If ExistTrigger(aCposPrd[nCnt1])
								RunTrigger(2,nCnt,,,aCposPrd[nCnt1])
							EndIf
						EndIf
					EndIf
				Next nCnt1
			Next nCnt

			If ( nPos := Ascan( aColsPrd, { |x| x[1] == cItemAge } ) ) == 0
				AAdd(aColsPrd, { cItemAge , AClone(aCols), AClone(aHeader) } )
			Else
				aColsPrd[nPos,2] := AClone(aCols)
				aColsPrd[nPos,3] := AClone(aHeader)
			EndIf

			//-- Armazena Totalizadores
			For nCnt := 1 To Len(aCols)
				lAtuTot := .T.
				If !GdDeleted(nCnt)
					nTQtdVol += GDFieldGet("DF2_QTDVOL",nCnt)
					nTPeso   += GDFieldGet("DF2_PESO"  ,nCnt)
					nTPesoM3 += GDFieldGet("DF2_PESOM3",nCnt)
					nTValMer += GDFieldGet("DF2_VALMER",nCnt)
					nTM3     += GDFieldGet("DF2_METRO3",nCnt)
				EndIf
			Next nCnt

			//-- Valor Informado por Agendamento
			AAdd(aCposVInf, "DF3_CODPAS" ) //-- Componente
			AAdd(aCposVInf, "DF3_VALOR"  ) //-- Quantidade

			For nCnt := 1 To Len(aColsDVF)
				aCols    := {}
				aHeader  := {}
				cProduto := aColsDVF[nCnt,GDFieldPos("DVF_CODPRO",aHeadDVF,aColsDVF)]
				TMSFillGetDados( 2,'DVQ', 1, xFilial('DVQ') + cFilOri + DT4->DT4_NUMCOT + cProduto , { || DVQ->DVQ_FILIAL + DVQ->DVQ_FILORI + DVQ->DVQ_NUMCOT + DVQ->DVQ_CODPRO } )
				aColsDVQ := AClone(aCols)
				aHeadDVQ := AClone(aHeader)

				aCols    := {}
				aHeader  := {}
				aFldDF3 := ApBuildHeader("DF3")
				For nI := 1 To Len(aFldDF3)
					aAdd(aHeader, aFldDF3[nI])
				Next

				aSize(aFldDF3, 0)
				aFldDF3 := Nil

				For nCnt1 := 1 To Len(aColsDVQ)
					n := nCnt1
					//-- Cria uma nova linha para o aCols
					TMSAF05New(@aCols,@aHeader)
					For nCnt2 := 1 To Len(aCposVInf)
						M->&(aCposVInf[nCnt2]) := aColsDVQ[nCnt1,GDFieldPos(StrTran(aCposVInf[nCnt2],"DF3_","DVQ_"),aHeadDVQ,aColsDVQ)]
						__Readvar := "M->"+aCposVInf[nCnt2]
						//-- Validacao da Cotacao
						If !Empty(M->&(aCposVInf[nCnt2])) 
							If TMSAF05Vld()
								GDFieldPut(aCposVInf[nCnt2],M->&(aCposVInf[nCnt2]),nCnt1)
								//-- Executa Gatilhos
								If ExistTrigger(aCposVInf[nCnt2])
									RunTrigger(2,nCnt1,,,aCposVInf[nCnt2])
								EndIf
							EndIf
						EndIf
					Next nCnt2
				Next nCnt1
				If ( nPos := Ascan( aColsVInf, { |x| x[1]+x[2] == cItemAge+cProduto } ) ) == 0
					AAdd(aColsVInf,{ cItemAge , cProduto, AClone(aCols), AClone(aHeader) } )
				Else
					aColsVInf[nPos,3] := AClone(aCols)
					aColsVInf[nPos,4] := AClone(aHeader)
				EndIf
			Next nCnt

			//-- Cubagem por Agendamento
			AAdd(aCposPM3, "DF4_QTDVOL" ) //-- Volumes
			AAdd(aCposPM3, "DF4_ALTURA" ) //-- Altura
			AAdd(aCposPM3, "DF4_LARGUR" ) //-- Largura
			AAdd(aCposPM3, "DF4_COMPRI" ) //-- Comprimento

			For nCnt := 1 To Len(aColsDVF)
				aCols    := {}
				aHeader  := {}
				cProduto := aColsDVF[nCnt,GDFieldPos("DVF_CODPRO",aHeadDVF,aColsDVF)]
				TMSFillGetDados( 2,'DTE', 2, xFilial('DTE') + cFilOri + DT4->DT4_NUMCOT + cProduto , { || DTE->DTE_FILIAL + DTE->DTE_FILORI + DTE->DTE_NUMCOT + DTE->DTE_CODPRO } )
				aColsDTE := AClone(aCols)
				aHeadDTE := AClone(aHeader)

				aCols    := {}
				aHeader  := {}
				aFldDF4 := ApBuildHeader("DF4")
				For nI := 1 To Len(aFldDF4)
					aAdd(aHeader, aFldDF4[nI])
				Next

				aSize(aFldDF4, 0)
				aFldDF4 := Nil

				For nCnt1 := 1 To Len(aColsDTE)
					n := nCnt1
					//-- Cria uma nova linha para o aCols
					TMSAF05New(@aCols,@aHeader)
					For nCnt2 := 1 To Len(aCposPM3)
						M->&(aCposPM3[nCnt2]) := aColsDTE[nCnt1,GDFieldPos(StrTran(aCposPM3[nCnt2],"DF4_","DTE_"),aHeadDTE,aColsDTE)]
						__Readvar := "M->"+aCposPM3[nCnt2]
						//-- Validacao da Cotacao
						If !Empty(M->&(aCposPM3[nCnt2])) 
							If TMSAF05Vld()
								GDFieldPut(aCposPM3[nCnt2],M->&(aCposPM3[nCnt2]),nCnt1)
								//-- Executa Gatilhos
								If ExistTrigger(aCposPM3[nCnt2])
									RunTrigger(2,nCnt1,,,aCposPM3[nCnt2])
								EndIf
							EndIf
						EndIf
					Next nCnt2
					GDFieldPut("DF4_ITEM",StrZero(nCnt1,Len(DF4->DF4_ITEM)),nCnt1)
				Next nCnt1
				If ( nPos := Ascan( aColsPM3, { |x| x[1]+x[2] == cItemAge+cProduto } ) ) == 0
					AAdd(aColsPM3,{ cItemAge , cProduto, AClone(aCols), AClone(aHeader) } )
				Else
					aColsPM3[nPos,3] := AClone(aCols)
					aColsPM3[nPos,4] := AClone(aHeader)
				EndIf
			Next nCnt

			RestInter() //-- Restaura aCols

			//-- Atualiza Totalizadores
			If lAtuTot
				GDFieldPut("DF1_QTDVOL",nTQtdVol,n)
				GDFieldPut("DF1_PESO"  ,nTPeso  ,n)
				GDFieldPut("DF1_PESOM3",nTPesoM3,n)
				GDFieldPut("DF1_METRO3",nTM3    ,n)
				GDFieldPut("DF1_VALMER",nTValMer,n)
			EndIf
			lAtuCot := .F. //-- Qdo selecionada a cotacao, nao ha necessidade de atualizar a cotacao.
		EndIf
	EndIf
Else
	If lTMF05CFA
		ExecBlock("TMF05CFA",.F.,.F.)	//-- Ponto de entrada para cotacoes de frete aprovadas!
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05CApr³ Autor ³ Eduardo de Souza     ³ Data ³ 30/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Apresenta Tela contendo as Cotacoes de Frete Aprovadas para ³±±
±±³          ³o Remetente/Destinatario informados.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSAF05CApr(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Origem                                      ³±±
±±³          ³ ExpC2 - Remetente                                          ³±±
±±³          ³ ExpC3 - Loja Remetente                                     ³±±
±±³          ³ ExpC4 - Destinatario                                       ³±±
±±³          ³ ExpC5 - Loja Destinatario                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAF05()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05CApr(cFilOri,cCliRem,cLojRem,cCliDes,cLojDes)

Local cTitulo    := STR0034 // "Cotacoes de Frete Aprovadas"
Local aRotOld    := aClone(aRotina)
Local cFiltro1   := ""
Local aRotina    := {}

Private nOpcSel  := 0
Private l040Auto := .F. //-- Variavel utilizada pelo TMSA040 na Visualizacao da Cotacao

SaveInter()

aRotina	:= {	{STR0003,"TMSA040Mnt", 0, 2},;   		// "Visualizar"
				{STR0007,"TMSConfSel", 0, 2,,,.T.} } 	// "Confirmar"

DT4->(dbSetOrder(3))
If DT4->(MsSeek(xFilial("DT4")+'3'+cFilOri+cCliRem+cLojRem+cCliDes+cLojDes))
	cFiltro1 := '"'+xFilial("DT4")+'3'+cFilOri+cCliRem+cLojRem+cCliDes+cLojDes+'"'
	MaWndBrowse(0,0,300,600,cTitulo,"DT4",,aRotina,,cFiltro1,cFiltro1,.T.)
EndIf

RestInter()

aRotina := aClone(aRotOld)

Return( nOpcSel == 1 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05TCot³ Autor ³ Eduardo de Souza     ³ Data ³ 30/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o Total da cotacao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05TCot(ExpC1,ExpC2)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXpC1 - Filial Origem                                      ³±±
±±³          ³ EXpC2 - Numero da Cotacao                                  ³±±
±±³          ³ EXpN1 - Elemento do aCols                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAF05()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05TCot(cFilOri,cNumCot,nElem)

Local   nValPas := 0
Local   nValImp := 0
Local   nValTot := 0
Local   nCnt    := 0
Default nElem   := n

DT8->(DbSetOrder(1))
If DT8->(MsSeek(xFilial("DT8")+cFilOri+cNumCot))
	While DT8->(!Eof()) .And. DT8->DT8_FILIAL + DT8->DT8_FILORI + DT8->DT8_NUMCOT == xFilial("DT8") + cFilOri + cNumCot
		If DT8->DT8_CODPAS == "TF"
			nValPas += DT8->DT8_VALPAS
			nValImp += DT8->DT8_VALIMP
			nValTot += DT8->DT8_VALTOT
		EndIf
		DT8->(DbSkip())
	EndDo
	GDFieldPut("DF1_VALFRE",nValPas,nElem)
	GDFieldPut("DF1_VALIMP",nValImp,nElem)
	GDFieldPut("DF1_VALTOT",nValTot,nElem)
	//-- Verifica se o valor informado esta igual ao total do frete.
	If ReadVar() == "M->DF1_VLRINF"
		If nValTot <> M->DF1_VLRINF
			&(ReadVar()) := 0
		EndIf
	ElseIf !Empty(GDFieldGet("DF1_VLRINF",nElem))
		GDFieldPut("DF1_VLRINF",nValTot,nElem)
	EndIf
EndIf

//-- Atualiza Totalizadores da Cotacao
nTValPas := 0
nTValImp := 0
nTValTot := 0
For nCnt := 1 To Len(aCols)
	If !GDDeleted(nCnt)
		nTValPas += GDFieldGet("DF1_VALFRE",nCnt)
		nTValImp += GDFieldGet("DF1_VALIMP",nCnt)
		nTValTot += GDFieldGet("DF1_VALTOT",nCnt)
	EndIf
Next nCnt
oTValPas:Refresh()
oTValImp:Refresh()
oTValTot:Refresh()

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05Whn³ Autor ³ Eduardo de Souza      ³ Data ³ 01/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se os campos poderao ser alterados                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Whn()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Whn(lHelp)

Local lRet       := .T.
Local cCampo     := ReadVar()
Local cOptPesCub := ""

Default lHelp    := .T.

If cCampo == 'M->DF0_STATUS'
	If lCancela
		lRet := .F.
	EndIf
ElseIf cCampo == 'M->DF1_STACOL'
	lRet := .F.
	If lConfirma
		lRet := GDFieldGet("DF1_STAENT",n) == StrZero(1,Len(DF1->DF1_STACOL)) //-- A Confirmar
	ElseIf lCancela
		lRet := GDFieldGet("DF1_STACOL",n) == StrZero(1,Len(DF1->DF1_STACOL)) .Or. GDFieldGet("DF1_STACOL",n) == StrZero(2,Len(DF1->DF1_STACOL)) //-- A Confirmar ### Confirmado
	EndIf

ElseIf cCampo == "M->DF2_PESOM3"
	//-- Este campo somente sera' editavel quando o campo B5_PERCUB for branco.
	If Empty(GdFieldGet('DF2_CODPRO',n))
		Help("",1,"TMSA05025") //-- Informe o Produto ...
		lRet :=.F.
	Else
		//-- O Cliente devedor devera estar preenchido.
		If Empty(cCliCalC)
			Return( .F. )
		EndIf
		cOptPesCub := TmsPesCub(cCliCalC,cLojCalC)
		//-- Caso o perfil do cliente de calculo esteja configurado com a opcao "4 - M3"
		//-- habilitar o campo DF2_METRO3 e desabilitar o campo DF2_PESOM3
		If Empty(cOptPesCub) .Or. cOptPesCub == '4'  // Peso Cubado M3
			Return( .F. )
		EndIf
		If cOptPesCub == '2'
			If !Empty(cCliCalC)   // Peso Cubado == Nao
				Help("",1,'TMSA05036') // O Peso Cubado Nao podera ser Informado ... Esta Regra Foi definida no Perfil do Cliente de Calculo Informado
			EndIf
			Return( .F. )
		EndIf
		lRet := Empty(TmsPerCub(GdFieldGet('DF2_CODPRO',n),cCliCalc,cLojCalc))
	EndIf
	
ElseIf cCampo == 'M->DF2_METRO3'
	cOptPesCub := TmsPesCub(cCliCalC,cLojCalC)
	//-- Caso o perfil do cliente de calculo esteja configurado com a opcao "4 - M3"
	//-- habilitar o campo DF2_METRO3 e desabilitar o campo DF2_PESOM3
	If Empty(cCliCalC) .Or. cOptPesCub <> '4'  // Peso Cubado M3
		Return( .F. )
	EndIf

ElseIf cCampo $ 'M->DF1_DATPRC/M->DF1_HORPRC/M->DF1_DATPRE/M->DF1_HORPRE'
	lRet := .T.

ElseIf cCampo == 'M->DF1_SERVIC'
	lRet := !Empty(GDFieldGet("DF1_CODNEG",n)) .And. !Empty(GDFieldGet("DF1_CLIDEV",n)) .And. !Empty(GDFieldGet("DF1_LOJDEV",n)) .And. ;
			!Empty(GDFieldGet("DF1_CLIDES",n)) .And. !Empty(GDFieldGet("DF1_LOJDES",n))
	
ElseIf lConfirma .Or. ;
	( cCampo == "M->DF1_FILORI" .And. !Empty(GDFieldGet("DF1_NUMCOT",n)) ) .Or. ;
	( GDFieldGet("DF1_STACOL",n) <> StrZero(1,Len(DF1->DF1_STACOL)) .And. GDFieldGet("DF1_STACOL",n) <> StrZero(2,Len(DF1->DF1_STACOL)) ) .Or. ; //-- A Confirmar ### Confirmado
	( !Empty(GDFieldGet("DF1_NUMCOT",n)) .And. !TmsAcesso(,'TMSA040',,,lHelp) )
	lRet := .F.

EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05RelC³ Autor ³ Eduardo de Souza     ³ Data ³ 02/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui o Relacionamento Cotacao X Agendamento              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05RelC(ExC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Origem                                      ³±±
±±³          ³ ExpC2 - Numero da Cotacao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05RelC(cFilOri,cNumCot)

Local aAreaDF1 := DF1->(GetArea())

//-- No cancelamento da cotacao, exclui o relacionamento cotacao x agendamento
DF1->(DbSetOrder(2))
If DF1->(dbSeek(xFilial("DF1")+cFilOri+cNumCot))
	RecLock("DF1",.F.)
	DF1->DF1_VLRINF := CriaVar("DF1_VLRINF",.F.)
	DF1->DF1_NUMCOT := CriaVar("DF1_NUMCOT",.F.)
	DF1->DF1_VALFRE := CriaVar("DF1_VALFRE",.F.)
	DF1->DF1_VALIMP := CriaVar("DF1_VALIMP",.F.)
	DF1->DF1_VALTOT := CriaVar("DF1_VALTOT",.F.)
	MsUnlock()
EndIf

RestArea( aAreaDF1 )

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05Cop ³ Autor ³ Eduardo de Souza     ³ Data ³ 02/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Copia Agendamento                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Cop(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paametros ³ ExpN1 - Opcao do Browse                                    ³±±
±±³          ³ Expc1 - Novo numero para o agendamento                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Cop(nOpcx,cNewAge)

Local nCnt       := 0
Local nCnt1      := 0
Local aColsDF1   := {}
Local aHeadDF1   := {}
Local cItemAge   := ''
Local nPosAtuPrd := 0

For nCnt := 1 To Len(aCols)
	GDFieldPut("DF1_STACOL",StrZero(1,Len(DF1->DF1_STACOL)),nCnt)
	GDFieldPut("DF1_STAENT",StrZero(1,Len(DF1->DF1_STAENT)),nCnt)
	GDFieldPut("DF1_DATPRC",CriaVar("DF1_DATPRC",.F.),nCnt)
	GDFieldPut("DF1_HORPRC",CriaVar("DF1_HORPRC",.F.),nCnt)
	GDFieldPut("DF1_DATPRE",CriaVar("DF1_DATPRE",.F.),nCnt)
	GDFieldPut("DF1_HORPRE",CriaVar("DF1_HORPRE",.F.),nCnt)
	GDFieldPut("DF1_NUMCOT",CriaVar("DF1_NUMCOT",.F.),nCnt)
	GDFieldPut("DF1_VALFRE",CriaVar("DF1_VALFRE",.F.),nCnt)
	GDFieldPut("DF1_VALIMP",CriaVar("DF1_VALIMP",.F.),nCnt)
	GDFieldPut("DF1_VALTOT",CriaVar("DF1_VALTOT",.F.),nCnt)
	GDFieldPut("DF1_FILDOC",CriaVar("DF1_FILDOC",.F.),nCnt)
	GDFieldPut("DF1_DOC"   ,CriaVar("DF1_DOC",.F.)   ,nCnt)
	GDFieldPut("DF1_SERIE" ,CriaVar("DF1_SERIE",.F.) ,nCnt)
	GDFieldPut("DF1_DATCON" ,CriaVar("DF1_DATCON",.F.) ,nCnt)

	//-- Ponto de entrada para manutenção dos campos que seram copiados
	If lTMF05COP
		ExecBlock("TMF05COP",.F.,.F.,{nCnt})
	EndIf

Next nCnt

SaveInter() //-- Salva aCols
aColsDF1 := AClone(aCols)
aHeadDF1 := AClone(aHeader)

For nCnt := 1 To Len(aColsDF1)
	cItemAge := GDFieldGet("DF1_ITEAGE",nCnt,,aHeadDF1,aColsDF1)
	//-- Copia Produtos por Agendamento
	aCols    := {}
	aHeader  := {}
	TMSFillGetDados(nOpcx, "DF2", 1, xFilial("DF2") + M->DF0_NUMAGE + cItemAge , { || DF2->DF2_FILIAL + DF2->DF2_NUMAGE + DF2->DF2_ITEAGE }, { || .T. } )
	AAdd(aColsPrd,{ cItemAge, AClone(aCols), AClone(aHeader) } )
	nPosAtuPrd := GDFieldPos("DF2_CODPRO")

	For nCnt1 := 1 To Len(aColsPrd[Len(aColsPrd),2])
		cProduto := aColsPrd[Len(aColsPrd),2,nCnt1,nPosAtuPrd] //-- Produto

		//-- Copia Valor Informado por Produto
		aCols    := {}
		aHeader  := {}
		TMSFillGetDados(nOpcx, "DF3", 1, xFilial("DF3") + M->DF0_NUMAGE + cItemAge + cProduto , { || DF3->DF3_FILIAL + DF3->DF3_NUMAGE + DF3->DF3_ITEAGE + DF3->DF3_CODPRO }, { || .T. } )
		AAdd(aColsVInf,{ cItemAge, cProduto, AClone(aCols), AClone(aHeader) } )
		//-- Copia Cubagem por Produto
		aCols    := {}
		aHeader  := {}
		TMSFillGetDados(nOpcx, "DF4", 1, xFilial("DF4") + M->DF0_NUMAGE + cItemAge + cProduto , { || DF4->DF4_FILIAL + DF4->DF4_NUMAGE + DF4->DF4_ITEAGE + DF4->DF4_CODPRO }, { || .T. } )
		AAdd(aColsPM3,{ cItemAge, cProduto, AClone(aCols), AClone(aHeader) } )
		//-- Copia Tipo Veiculo
		aCols    := {}
		aHeader  := {}
		TMSFillGetDados(nOpcx, "DF5", 1, xFilial("DF5") + M->DF0_NUMAGE + cItemAge , { || DF5->DF5_FILIAL + DF5->DF5_NUMAGE + DF5->DF5_ITEAGE }, { || .T. } )
		AAdd(aColsTip,{ cItemAge, AClone(aCols), AClone(aHeader) } )
	Next nCnt1

Next nCnt

RestInter() //-- Restaura aCols

M->DF0_NUMAGE := cNewAge
M->DF0_DATCAD := dDataBase
M->DF0_STATUS := StrZero(1,Len(DF0->DF0_STATUS))
nOpcx  := 3
Inclui := .T.
nTValPas := 0
nTValImp := 0
nTValTot := 0

//-- Ponto de entrada antes de abrir a copia
If ExistBlock("TM05ACOP")
	ExecBlock("TM05ACOP",.F.,.F.)
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05Col ³ Autor ³ Eduardo de Souza     ³ Data ³ 06/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Geracao de Coleta                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Col(ExpN1,ExpC1,ExpC2,ExpC3)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Posicao atual da GetDados                          ³±±
±±³          ³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Serie do Documento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Col(nItem,cFilDoc,cDocto,cSerie)

Local nCnt      := 0
Local nCnt1     := 0
Local nCnt2     := 0
Local nCnt3     := 0
Local aColsAux  := {}
Local aHeadAux  := {}
Local aColsDUM  := {}
Local aHeadDUM  := {}
Local aProdutos := {}
Local cCodSol   := M->DF0_CODSOL
Local cSeqEnd   := M->DF0_SEQEND
Local cItemAge  := GDFieldGet("DF1_ITEAGE",nItem)
Local cCdrDes   := GDFieldGet("DF1_CDRDES",nItem)
Local cFilOri   := GDFieldGet("DF1_FILORI",nItem)
Local cNumCot   := GDFieldGet("DF1_NUMCOT",nItem)
Local cCliDev   := GDFieldGet("DF1_CLIDEV",nItem)
Local cLojDev   := GDFieldGet("DF1_LOJDEV",nItem)
Local cFilOld   := CriaVar("DT5_FILORI",.F.)
Local cNumSol   := CriaVar("DT5_NUMSOL",.F.)
Local nPosPrd   := 0
Local nPos      := 0
Local aTelSol   := {}
Local nItemSol  := 1
Local lCamposDUM:= DUM->(ColumnPos("DUM_QTDUNI")) > 0
Local cAliasQry := GetNextAlias()
Local aFldDTE	:= {}
Local nI		:= 0
Local aColsDF1  := {}
Local aHeaderDF1 := {}

Private aRatPesM3  := {}
Private aHeaderDTE := {}
Private aHeaderDVT := {}
Private aColsDVT   := {}

//-- Verifica a sequencia do endereco e Inclui o remetente como solicitante, caso a Coleta seja no remetente.
If GDFieldGet("DF1_LOCCOL",nItem) == StrZero(2,Len(DF1->DF1_LOCCOL)) //-- Remetente
	aTelSol := TMSAF05DUE(GDFieldGet("DF1_CLIREM",nItem),GDFieldGet("DF1_LOJREM",nItem),GDFieldGet("DF1_TIPTRA",nItem))
	cCodSol := aTelSol[1]
	cSeqEnd := GDFieldGet("DF1_SQEREM",nItem)
EndIf

//-- Posiciona na Solicitacao de Coleta
DT5->(DbSetOrder(4))
If DT5->(MsSeek(xFilial("DT5")+cFilDoc+cDocto+cSerie))
	RegToMemory('DT5',.F.)
	cFilOld := DT5->DT5_FILORI
	cNumSol := DT5->DT5_NUMSOL
Else
	RegToMemory('DT5',.T.)
	M->DT5_STATUS := StrZero( 1, Len( DT5->DT5_STATUS ) )
EndIf

//-- Posiciona o servico.
DC5->( DbSetOrder( 1 ) )
DC5->( MsSeek( xFilial('DC5') + GDFieldGet("DF1_SERVIC",nItem), .F. ) )
//-- Posiciona o solicitante.
DUE->( DbSetOrder( 1 ) )
DUE->( MsSeek( xFilial('DUE') + cCodsol , .F. ) )

M->DT5_FILORI := cFilOri
M->DT5_NUMCOT := cNumCot
M->DT5_TIPCOL := StrZero( 1, Len( DT5->DT5_TIPCOL ) )
M->DT5_CODSOL := cCodSol
M->DT5_SEQEND := cSeqEnd
M->DT5_CDRORI := GDFieldGet("DF1_CDRORI",nItem)
M->DT5_TIPTRA := GDFieldGet("DF1_TIPTRA",nItem)
M->DT5_DATPRV := GDFieldGet("DF1_DATPRC",nItem)
M->DT5_HORPRV := GDFieldGet("DF1_HORPRC",nItem)
M->DT5_CLIDES := GDFieldGet("DF1_CLIDES",nItem)
M->DT5_LOJDES := GDFieldGet("DF1_LOJDES",nItem)
M->DT5_SQEDES := GDFieldGet("DF1_SQEDES",nItem)
M->DT5_DATENT := GDFieldGet("DF1_DATPRE",nItem)
M->DT5_HORENT := GDFieldGet("DF1_HORPRE",nItem)
M->DT5_CDRDCA := cCdrDes
M->DT5_CLIDEV := GDFieldGet("DF1_CLIDEV",nItem)
M->DT5_LOJDEV := GDFieldGet("DF1_LOJDEV",nItem)
M->DT5_CLIREM := GDFieldGet("DF1_CLIREM",nItem)
M->DT5_LOJREM := GDFieldGet("DF1_LOJREM",nItem)
M->DT5_SQEREM := GDFieldGet("DF1_SQEREM",nItem)

If DT5->(ColumnPos("DT5_KM")) > 0
	If M->DF0_TIPDIS == StrZero( 1, Len( DF0->DF0_TIPDIS ) )   //Distancia Consolidada
		M->DT5_KM := M->DF0_TOTDIS
	Else	
		M->DT5_KM := GDFieldGet("DF1_DISTAN",nItem)
	EndIf	
EndIf

If Type('M->DF0_OBS') != 'U' //--Nao atribui valor se o campo estiver fora de uso
	M->DT5_OBS := M->DF0_OBS
EndIf

M->DT5_NCONTR := GDFieldGet("DF1_NCONTR",nItem)
M->DT5_CODNEG := GDFieldGet("DF1_CODNEG",nItem)
M->DT5_SERVIC := GDFieldGet("DF1_SRVCOL",nItem)
M->DT5_SRVENT	:= GDFieldGet("DF1_SERVIC",nItem)
M->DT5_TIPFRE := GDFieldGet("DF1_TIPFRE",nItem)
M->DT5_LOCCOL	:= GDFieldGet("DF1_LOCCOL",nItem)

aColsDF1   := aClone(aCols)
aHeaderDF1 := aClone(aHeader)

SaveInter() //-- Salva aCols

//-- Tipos de Veiculos
aCols   := {}
aHeader := {}
If (nPos := Ascan( aColsTip, { |x| x[1] == cItemAge } ) ) == 0
	TMSFillGetDados(2, "DF5", 1, xFilial("DF5") + M->DF0_NUMAGE + cItemAge , { || DF5->DF5_FILIAL + DF5->DF5_NUMAGE + DF5->DF5_ITEAGE }, { || .T. } )
	aColsAux := AClone(aCols)
	aHeadAux := AClone(aHeader)
Else
	aColsAux := AClone(aColsTip[nPos,2])
	aHeadAux := AClone(aColsTip[nPos,3])
EndIf

aCols   := {}
aHeader := {}
TMSFillGetDados( 2, "DVT", , xFilial( "DVT" ) + cFilOri + cNumSol + cNumCot + "1" , { || DVT->(DVT_FILIAL+DVT_FILORI+DVT_NUMSOL+DVT_NUMCOT+DVT_ORIGEM) } )
For nCnt := 1 To Len(aColsAux)
	//-- Cria uma nova linha para o aCols
	If nCnt > Len(aCols)
		TMSAF05New(@aCols,@aHeader)
	EndIf
	GDFieldPut( 'DVT_ITEM'  , GDFieldGet("DF5_ITEM"  ,nCnt,,aHeadAux,aColsAux), nCnt )
	GDFieldPut( 'DVT_TIPVEI', GDFieldGet("DF5_TIPVEI",nCnt,,aHeadAux,aColsAux), nCnt )
	GDFieldPut( 'DVT_QTDVEI', GDFieldGet("DF5_QTDVEI",nCnt,,aHeadAux,aColsAux), nCnt )
	GDFieldPut( 'DVT_ORIGEM', '1', nCnt )
	ACols[nCnt,Len(aHeader)+1] := GDDeleted(nCnt,aHeadAux,aColsAux)
Next nCnt
aHeaderDVT := AClone(aHeader)
aColsDVT   := AClone(aCols)

//-- Produtos
aCols   := {}
aHeader := {}
If (nPosPrd := Ascan( aColsPrd, { |x| x[1] == cItemAge } ) ) == 0
	TMSFillGetDados(2, "DF2", 1, xFilial("DF2") + M->DF0_NUMAGE + cItemAge , { || DF2->DF2_FILIAL + DF2->DF2_NUMAGE + DF2->DF2_ITEAGE }, { || .T. } )
	aColsAux := AClone(aCols)
	aHeadAux := AClone(aHeader)
Else
	aColsAux := AClone(aColsPrd[nPosPrd,2])
	aHeadAux := AClone(aColsPrd[nPosPrd,3])
EndIf

aCols   := {}
aHeader := {}
TMSFillGetDados( 2, "DUM", , xFilial( "DUM" ) + cFilOri + cNumSol , { || DUM->DUM_FILIAL+DUM->DUM_FILORI+DUM->DUM_NUMSOL } )

For nCnt := 1 To Len(aColsAux)
	//-- Cria uma nova linha para o aCols
	If nCnt > Len(aCols)
		TMSAF05New(@aCols,@aHeader)
		nItemSol ++
	Else
		nItemSol := Val(GDFieldGet("DUM_ITEM",nCnt))
		If nItemSol == 0
			nItemSol ++
		EndIf
	EndIf
	GDFieldPut( 'DUM_ITEM'  , StrZero(nItemSol, Len(DUM->DUM_ITEM)) , nCnt )
	GDFieldPut( 'DUM_CODPRO', GDFieldGet("DF2_CODPRO",nCnt,,aHeadAux,aColsAux), nCnt )
	GDFieldPut( 'DUM_CODEMB', GDFieldGet("DF2_CODEMB",nCnt,,aHeadAux,aColsAux), nCnt )
	GDFieldPut( 'DUM_QTDVOL', GDFieldGet("DF2_QTDVOL",nCnt,,aHeadAux,aColsAux), nCnt )
	GDFieldPut( 'DUM_PESO'  , GDFieldGet("DF2_PESO"  ,nCnt,,aHeadAux,aColsAux), nCnt )
	GDFieldPut( 'DUM_PESOM3', GDFieldGet("DF2_PESOM3",nCnt,,aHeadAux,aColsAux), nCnt )
	GDFieldPut( 'DUM_VALMER', GDFieldGet("DF2_VALMER",nCnt,,aHeadAux,aColsAux), nCnt )
	GDFieldPut( 'DUM_METRO3', GDFieldGet("DF2_METRO3",nCnt,,aHeadAux,aColsAux), nCnt )
	If lCamposDUM
		GDFieldPut( 'DUM_QTDUNI', GDFieldGet("DF2_QTDUNI",nCnt,,aHeadAux,aColsAux), nCnt )
		GDFieldPut( 'DUM_BASSEG', GDFieldGet("DF2_BASSEG",nCnt,,aHeadAux,aColsAux), nCnt )
	EndIf	
	ACols[nCnt,Len(aHeader)+1] := GDDeleted(nCnt,aHeadAux,aColsAux)
	AAdd( aProdutos, { StrZero(nItemSol, Len(DUM->DUM_ITEM)) , GDFieldGet("DF2_CODPRO",nCnt,,aHeadAux,aColsAux) } )
Next nCnt

If Empty(cNumCot)
	aColsDUM := AClone(aCols)
	aHeadDUM := AClone(aHeader)

	If Len(aColsDUM) == 1 	// Painel de Agendamento: Insere o produto vinculado ao cadastro do solicitante na tela de produto.
		For nCnt2 := 1 To Len(aColsDUM)	
			If Empty(aColsDUM[nCnt2][2]) .And. lSugRemet
				cQuery := " SELECT DVJ_CODPRO, DVJ_CODEMB "
				cQuery += "   FROM " + RetSqlName("DVJ")
				cQuery += "   WHERE DVJ_FILIAL = '" + xFilial("DVJ") + "' "
				cQuery += "     AND DVJ_CODSOL    = '" + M->DF0_CODSOL + "' "
				cQuery += "     AND D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .T.)
				While (cAliasQry)->(!Eof())
					For nCnt3 := 1 To Len(aColsDUM)
						aColsDUM[nCnt3][2] := (cAliasQry)->DVJ_CODPRO
						aColsDUM[nCnt3][4] := (cAliasQry)->DVJ_CODEMB
					Next nCnt3
				(cAliasQry)->(DbSkip())
				EndDo
			Endif
		Next nCnt2
	Endif
	For nCnt := 1 To Len(aProdutos)
		aCols    := {}
		aHeader  := {}
		If (nPos:= Ascan( aColsPM3, { |x| x[1]+x[2] == cItemAge + aProdutos[nCnt,2] } ) ) == 0
			TMSFillGetDados(2, "DF4", 1, xFilial("DF4") + M->DF0_NUMAGE + cItemAge + aProdutos[nCnt,2] , { || DF4->DF4_FILIAL + DF4->DF4_NUMAGE + DF4->DF4_ITEAGE + DF4->DF4_CODPRO }, { || .T. } )
			aColsAux := AClone(aCols)
			aHeadAux := AClone(aHeader)
		Else
			aColsAux := AClone(aColsPM3[nPos,3])
			aHeadAux := AClone(aColsPM3[nPos,4])
		EndIf

		aCols    := {}
		If Empty(aHeaderDTE)
			aHeader  := {}
			aFldDTE := ApBuildHeader("DTE")
			For nI := 1 To Len(aFldDTE)
				aAdd(aHeader, aFldDTE[nI])
			Next

			aSize(aFldDTE, 0)
			aFldDTE := Nil

			aHeaderDTE := AClone(aHeader)
		Else
			aHeader := AClone(aHeaderDTE)
		EndIf

		For nCnt1 := 1 To Len(aColsAux)
			If !GDDeleted(nCnt1,aHeadAux,aColsAux) .And. GDFieldGet("DF4_QTDVOL",nCnt1,,aHeadAux,aColsAux) > 0
				//-- Cria uma nova linha para o aCols
				TMSAF05New(@aCols,@aHeader)
				GDFieldPut( 'DTE_QTDVOL', GDFieldGet("DF4_QTDVOL",nCnt1,,aHeadAux,aColsAux), Len(aCols) )
				GDFieldPut( 'DTE_ALTURA', GDFieldGet("DF4_ALTURA",nCnt1,,aHeadAux,aColsAux), Len(aCols) )
				GDFieldPut( 'DTE_LARGUR', GDFieldGet("DF4_LARGUR",nCnt1,,aHeadAux,aColsAux), Len(aCols) )
				GDFieldPut( 'DTE_COMPRI', GDFieldGet("DF4_COMPRI",nCnt1,,aHeadAux,aColsAux), Len(aCols) )
			EndIf
		Next nCnt1
		AAdd(aRatPesM3,{ aProdutos[nCnt,1], aClone(aCols) })
	Next nCnt
	aCols      := AClone(aColsDUM)
	aHeader    := AClone(aHeadDUM)
EndIf

//-- Rotina de gravacao da solicitacao de coleta
If Empty(cFilDoc) .Or. Empty(cDocto) .Or. Empty(cSerie)
	If !Empty(cNumCot)
		TMSA460Grava(3,,,CriaVar("DT5_NUMSOL",.F.),cNumCot,(mv_par01 == 1))
	Else
		TMSA460Grava(3,,,,,(mv_par01 == 1))
	EndIf
	cFilDoc := cFilOri
	cDocto  := M->DT5_NUMSOL
	cSerie  := 'COL'
Else

    //| Muda status do campo DT6_FIMP para habilitar a impressão da SC alterada
    If AScan(aModified,{|y| y[1] == cItemAge}) > 0
        If DT6->(MsSeek(xFilial("DT6") + cFilDoc + cDocto + cSerie))
           DT6->(RecLock("DT6",.F.))
           DT6->DT6_FIMP := "0" //0=não impresso;1=Impresso
           DT6->(MsUnLock())
        EndiF
    EndIf
	TMSA460Grava(4,,,cNumSol,cNumCot,(mv_par01 == 1))
EndIf

aCols   := aClone(aColsDF1)
aHeader := aClone(aHeaderDF1)

//-- Atualiza o Cliente Devedor da Coleta
DT6->(DbSetOrder(1))
If !Empty(cCliDev+cLojDev) .And. DT6->(MsSeek(xFilial("DT6")+cFilDoc+cDocto+cSerie))
	RecLock("DT6",.F.)
	DT6->DT6_CLIDEV := cCliDev
	DT6->DT6_LOJDEV := cLojDev
	MsUnlock()
EndIf

//-- Atualiza o numero da solicitacao na cotacao
If !Empty(cNumCot)
	DT5->(DbSetOrder(4))
	If DT5->(MsSeek(xFilial("DT5")+cFilDoc+cDocto+cSerie))
		DT4->(DbSetOrder(1))
		If DT4->(MsSeek(xFilial("DT4")+cFilOri+cNumCot))
			RecLock("DT4",.F.)
			DT4->DT4_NUMSOL := DT5->DT5_NUMSOL
			MsUnLock()
		EndIf
	EndIf
EndIf

RestInter() //-- Restaura aCols

FwFreeArray(aColsDF1)
FwFreeArray(aHeaderDF1)
FwFreeArray(aColsAux)
FwFreeArray(aHeadAux)
FwFreeArray(aColsDUM)
FwFreeArray(aHeadDUM)
FwFreeArray(aProdutos)
FwFreeArray(aTelSol)
FwFreeArray(aFldDTE)
FwFreeArray(aRatPesM3)
FwFreeArray(aHeaderDTE)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05VPrd³ Autor ³ Eduardo de Souza     ³ Data ³ 12/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida preenchimento dos produtos com status confirmado.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05VPrd(ExpN1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Posicao atual da GetDados                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05VPrd(nCnt)

Local nPosPrd := Ascan( aColsPrd, { |x| x[1] == GDFieldGet("DF1_ITEAGE",nCnt) } )
Local nCont   := 0
Local lRet    := .T.
Local nPos01  := 0

DF2->(DbSetOrder(1))
If nPosPrd == 0 .And. !DF2->(MsSeek(xFilial("DF2")+M->DF0_NUMAGE+GDFieldGet("DF1_ITEAGE",nCnt)))
	lRet := .F.
ElseIf nPosPrd > 0
	//-- Verifica se todos produtos estao deletados
	nPos01 := GDFieldPos("DF2_CODPRO",aColsPrd[nPosPrd,3])
	Aeval( aColsPrd[nPosPrd,2], { |X| If( !Empty(X[nPos01]) .And. X[Len(aColsPrd[nPosPrd,3])+1] == .F., nCont ++ , nCont ) } )
	If nCont == 0
		lRet := .F.
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05Qtd³ Autor ³ Eduardo de Souza      ³ Data ³ 16/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta a quantidade do agendamento                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Qtd()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Qtd( lTela )

Local nCnt    := 0
Local nQtdIte := 0
Local nLenAcols := 0
Local nPosDELET := 0

Default lTela := .T.

//-- Alimenta a quantidade do agendamento
If Inclui .Or. Altera
	nLenAcols := Len(aCols)
	nPosDELET := Len(aHeader)+1 //Posicao da coluna da GetDados que indica se o item estah deletado
	For nCnt:= 1 To nLenAcols
		If !aCols[nCnt][nPosDELET]
			nQtdIte ++
		EndIf
	Next nCnt
	M->DF0_QTDITE := nQtdIte
	
	If lTela
		oEnch:Refresh()
	EndIf
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05DUE³ Autor ³ Eduardo de Souza      ³ Data ³ 16/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Codigo do Solicitante                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05DUE(ExpC1,ExpC2,ExpC3,ExpL1)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Remetente                                          ³±±
±±³          ³ ExpC2 - Loja Remetente                                     ³±±
±±³          ³ ExpC3 - Tipo de transporte para inclusao se necessario     ³±±
±±³          ³ ExpL1 - Indica se utiliza o telefone do cliente generico   ³±±
±±³          ³         caso o telefone do remetente esteja em branco.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05DUE(cCliRem,cLojRem,cTipTra,lTelGen)

Local   aAreaDUE := DUE->(GetArea())
Local   cCodSol     := ""
Local   cCliGen  := ""
Local   cCodProd := GetMv("MV_PROGEN",,'')

Default lTelGen  := .F.

SA1->(DbSetOrder(1))
If SA1->(MsSeek(xFilial("SA1")+cCliRem+cLojRem))
	If lTelGen 
		cCliGen := GetMv("MV_CLIGEN",,'')
		cCliRem := Left(cCliGen,Len(SA1->A1_COD))
		cLojRem := Right(cCliGen,Len(SA1->A1_LOJA))
		SA1->(MsSeek(xFilial("SA1")+cCliRem+cLojRem))
	EndIf
	DUE->(DbSetOrder(3))
	If DUE->(MsSeek(xFilial("DUE")+cCliRem+cLojRem))
		cCodSol := DUE->DUE_CODSOL
	Else
		Begin Transaction
			RecLock("DUE",.T.)
			DUE->DUE_FILIAL := xFilial("DUE")
			DUE->DUE_CODSOL := GETSXENUM("DUE","DUE_CODSOL")	
			DUE->DUE_DDD    := SA1->A1_DDD
			DUE->DUE_TEL    := SA1->A1_TEL
			DUE->DUE_CODCLI := SA1->A1_COD
			DUE->DUE_LOJCLI := SA1->A1_LOJA
			DUE->DUE_NOME   := SA1->A1_NOME
			DUE->DUE_NREDUZ := SA1->A1_NREDUZ
			DUE->DUE_END    := SA1->A1_END
			DUE->DUE_MUN    := SA1->A1_MUN
			DUE->DUE_EST    := SA1->A1_EST
			DUE->DUE_BAIRRO := SA1->A1_BAIRRO
			DUE->DUE_CEP    := SA1->A1_CEP
			DUE->DUE_TIPTRA := cTipTra
			DUE->DUE_CGC    := SA1->A1_CGC
			DUE->DUE_INSCR  := SA1->A1_INSCR
			DUE->DUE_EMAIL	:= SA1->A1_EMAIL
			DUE->DUE_CONTATO:= SA1->A1_CONTATO
			DUE->DUE_CODMUN := SA1->A1_COD_MUN
			MsUnLock()
			cCodSol 		:= DUE->DUE_CODSOL
			//-- Itens do Solicitante
			RecLock("DVJ",.T.)
			DVJ->DVJ_FILIAL := xFilial("DVJ")
			DVJ->DVJ_DDD    := DUE->DUE_DDD
			DVJ->DVJ_TEL    := DUE->DUE_TEL
			DVJ->DVJ_CODPRO := cCodProd
			DVJ->DVJ_CODEMB := CriaVar("DVJ_CODEMB")
			DVJ->DVJ_CODSOL := DUE->DUE_CODSOL
			DVJ->(MsUnlock())
		End Transaction
	EndIf
EndIf

RestArea( aAreaDUE )

Return { cCodSol }

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05Tip³ Autor ³ Eduardo de Souza      ³ Data ³ 19/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tipos de Veiculo por Agendamento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Tip(ExpL1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - Verifica se altera tipo de veiculo                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Tip(lAltTip)

Local oDlgEsp
Local oGetTip
Local aSize     := {}
Local aInfo     := {}
Local aObjects  := {}
Local aPosObj   := {}
Local cTitulo   := STR0043 // 'Tipos de Veiculos por Agendamento'
Local nOpcx     := 2
Local nPos      := 0
Local nOpcao    := 0
Local lAchou    := .F.
Local nCnt      := 0
Default lAltTip := .T.

Private cItemAge := GDFieldGet("DF1_ITEAGE",n)

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey)

SaveInter() //-- Salva Area

aCols   := {}
aHeader := {}

//-- Verifica se podera alterar o tipo de veiculo
If lAltTip
	If Inclui
		nOpcx := 3
	ElseIf Altera
		nOpcx := 4
	EndIf
EndIf

If (nPos:= Ascan( aColsTip, { |x| x[1] == cItemAge } ) ) == 0
	TMSFillGetDados(nOpcx, "DF5", 1, xFilial("DF5") + M->DF0_NUMAGE + cItemAge , Iif(nOpcx <> 3,{ || DF5->DF5_FILIAL + DF5->DF5_NUMAGE + DF5->DF5_ITEAGE }, {|| ''}), { || .T. } )
Else
	lAchou   := .T.
	aCols    := AClone(aColsTip[nPos,2]	)
	aHeader  := AClone(aColsTip[nPos,3])
	//-- Inicializa todas as linhas do aCols como nao deletado, devido a falha na GetDados
	For nCnt := 1 To Len(aCols)
		aCols[nCnt,Len(aHeader)+1] := .F.
	Next nCnt
EndIf

//-- Preenche o Item do Agendamento
If Empty(GDFieldGet("DF5_ITEM",1))
	GDFieldPut("DF5_ITEM",StrZero(1,Len(DF5->DF5_ITEM)),1)
EndIf

//-- Dimensoes padroes
aSize   := MsAdvSize()
AAdd( aObjects, { 100, 015, .T., .T. } )
AAdd( aObjects, { 100, 085, .T., .T. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlgEsp TITLE cTitulo FROM aSize[7]/2,00 TO aSize[6]/2,aSize[5]/2+100 PIXEL

@ aPosObj[1,1],010 SAY STR0023 COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 40 ,9  //'Agendamento:'
@ aPosObj[1,1],050 SAY M->DF0_NUMAGE Of oDlgEsp PIXEL SIZE 29 ,9

@ aPosObj[1,1],130 SAY STR0024 COLOR CLR_HBLUE,CLR_WHITE Of oDlgEsp PIXEL SIZE 40 ,9  //'Item Agend.:'
@ aPosObj[1,1],170 SAY cItemAge Of oDlgEsp PIXEL SIZE 29 ,9

oGetTip:=MSGetDados():New(aPosObj[2,1]/2+15, aPosObj[2,2]/2, aPosObj[2,3]/2, aPosObj[2,4]/2+50, nOpcx, 'TMSAF05LOk(5)','AllWaysTrue','+DF5_ITEM',nOpcx<>2,aAltGetD)
//-- Atualiza aCols corrigindo a falha na GetDados

oGetTip:Refresh(.T.)

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| If(oGetTip:TudoOk(),(nOpcao:= 1,oDlgEsp:End()),.F.) }, {|| oDlgEsp:End() }) CENTERED

//-- Atualiza array de aCols do produto
If nOpcx <> 2 .And. nOpcao == 1
	If (nPos:= Ascan( aColsTip, { |x| x[1] == cItemAge } ) ) == 0
		AAdd(aColsTip,{ cItemAge, aCols, aHeader } )
	Else
		aColsTip[nPos,2] := AClone(aCols)
	EndIf
EndIf

RestInter() //-- Restaura Area

//-- Qdo alterar o tipo de veiculo, obriga atualizar a cotacao
If nOpcx <> 2 .And. nOpcao == 1
	If !Empty(GDFieldGet("DF1_NUMCOT",n))
		If lAltTip
			lAtuCot := .T.
		EndIf
	EndIf
EndIf

TmsKeyOn(aSetKey) //-- Restaura SetKey

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05Del³ Autor ³ Eduardo de Souza      ³ Data ³ 27/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida delecao do item do agendamento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Del()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Del()

Local lRet     := .T.
Local nCnt     := 0
Local nPosDist := 0

//-- Valida delecao
If	GDFieldGet("DF1_STACOL",n) <> StrZero(1,Len(DF1->DF1_STACOL)) .And. ; //-- 'A Confirmar'
	GDFieldGet("DF1_STACOL",n) <> StrZero(2,Len(DF1->DF1_STACOL)) //-- 'Confirmado'
	lRet := .F.
EndIf

nPosDist := GDFieldPos("DF1_DISTAN")
//--Alimenta a variavel de memoria, caso seja adicionado uma linha pelo copia de itens
M->DF0_TOTDIS := 0
For nCnt := 1 To Len(aCols)
	If !GDDeleted(nCnt)
		M->DF0_TOTDIS += aCols[nCnt][nPosDist]
	EndIf
Next nCnt

//-- Atualiza a quantidade de itens
If lRet
	TMSAF05Qtd()
	//-- Zera a ordem de coleta/entrega
	If GDFieldPos("DF1_SEQUEN") > 0
		GDFieldPut( "DF1_SEQUEN", Replicate('x',Len(DF1->DF1_SEQUEN)) ,n)	
	EndIf
	If GDFieldPos("DF1_SEQENT") > 0
		GDFieldPut( "DF1_SEQENT", Replicate('x',Len(DF1->DF1_SEQENT)) ,n)
	EndIf
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05DCot³ Autor ³ Eduardo de Souza     ³ Data ³ 28/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclusao da Cotacao de Frete                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05DCot(ExpC1,ExpC2)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Origem                                      ³±±
±±³          ³ ExpC2 - Numero da Cotacao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05DCot(cFilOri,cNumCot)

Local cNumSol := ''

//-- Exclui cotacao
DT4->(DbSetOrder(1))
If DT4->(MsSeek(xFilial('DT4')+cFilOri+cNumCot))
	cNumSol := DT4->DT4_NUMSOL
	RecLock('DT4',.F.)
	DT4->(DbDelete())
	MsUnLock()
	DT4->(DbSkip())
EndIf

//-- Exclui a composicao do frete
DT8->(DbSetOrder(1))
If DT8->(MsSeek(xFilial('DT8')+cFilOri+cNumCot))
	While DT8->(!Eof()) .And. DT8->DT8_FILIAL + DT8->DT8_FILORI + DT8->DT8_NUMCOT == xFilial('DT8') + cFilOri + cNumCot
		RecLock('DT8',.F.)
		DT8->( DbDelete() )
		MsUnLock()
		DT8->(DbSkip())
	EndDo
EndIf
	
//-- Exclui cubagem de mercadorias
DTE->(DbSetOrder(2)) //DTE_FILIAL+DTE_FILORI+DTE_NUMCOT+DTE_CODPRO
If DTE->(MsSeek(xFilial('DTE')+cFilOri+cNumCot))
	While DTE->(!Eof()) .And. DTE->DTE_FILIAL + DTE->DTE_FILORI + DTE->DTE_NUMCOT == xFilial('DTE') + cFilOri + cNumCot
		RecLock('DTE',.F.)
		DTE->( DbDelete() )
		MsUnLock()
		DTE->(DbSkip())
	EndDo
EndIf

//-- Exclui valor informado de mercadorias
DVQ->(DbSetOrder(1))
If DVQ->(MsSeek(xFilial('DVQ')+cFilOri+cNumCot))
	While DVQ->(!Eof()) .And. DVQ->DVQ_FILIAL + DVQ->DVQ_FILORI + DVQ->DVQ_NUMCOT == xFilial('DVQ') + cFilOri + cNumCot
		RecLock('DVQ',.F.)
		DVQ->( DbDelete() )
		MsUnLock()
		DVQ->(DbSkip())
	EndDo
EndIf

//-- Exclui produtos da cotacao
DVF->(DbSetOrder(1))
If DVF->(MsSeek(xFilial('DVF')+cFilOri+cNumCot))
	While DVF->(!Eof()) .And. DVF->DVF_FILIAL + DVF->DVF_FILORI + DVF->DVF_NUMCOT == xFilial('DVF') + cFilOri + cNumCot
		RecLock('DVF',.F.)
		DVF->( DbDelete() )
		MsUnLock()
		DVF->(DbSkip())
	EndDo
EndIf

//-- Exclui tipos de veiculos da cotacao
DVT->(DbSetOrder(1))
If DVT->(MsSeek(xFilial('DVT')+cFilOri+cNumSol+cNumCot))
	While DVT->(!Eof()) .And. DVT->DVT_FILIAL + DVT->DVT_FILORI + DVT->DVT_NUMSOL + DVT->DVT_NUMCOT == xFilial('DVT') + cFilOri + cNumSol + cNumCot
		RecLock('DVT',.F.)
		DVT->( DbDelete() )
		MsUnLock()
		DVT->(DbSkip())
	EndDo
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05DSol³ Autor ³ Eduardo de Souza     ³ Data ³ 28/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclusao da Solicitacao de Frete                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05DSol(ExpC1,ExpC2,ExpC3)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Documento                                   ³±±
±±³          ³ ExpC2 - Documento                                          ³±±
±±³          ³ ExpC3 - Serie do Documento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05DSol(cFilDoc,cDocto,cSerie)

Local cFilOri := ''
Local cNumSol := ''

//-- Exclui Solicitacao de coleta
DT5->(DbSetOrder(4))
If DT5->(MsSeek(xFilial("DT5")+cFilDoc+cDocto+cSerie))
	cFilOri := DT5->DT5_FILORI
	cNumSol := DT5->DT5_NUMSOL
	RecLock("DT5",.F.)
	DT5->(DbDelete())
	MsUnLock()
EndIf

//-- Exclui Documento de Transporte
DT6->(DbSetOrder(1))
If DT6->(MsSeek(xFilial('DT6')+cFilDoc+cDocto+cSerie))
	RecLock('DT6',.F.)
	DT6->(dbDelete())
	MsUnLock()
EndIf

//-- Exclui Movimento de Viagem
DUD->(DbSetOrder(1))
If DUD->(MsSeek(xFilial('DUD')+cFilDoc+cDocto+cSerie))
	RecLock('DUD',.F.)
	DUD->(dbDelete())
	MsUnLock()
EndIf

//-- Exclui produtos da solicitacao
DUM->(DbSetOrder(1))
If DUM->(MsSeek(xFilial('DUM')+cFilOri+cNumSol))
	While DUM->(!Eof()) .And. DUM->DUM_FILIAL + DUM->DUM_FILORI + DUM->DUM_NUMSOL == xFilial('DUM') + cFilOri + cNumSol
		RecLock("DUM",.F.)
		DUM->(dbDelete())
		MsUnLock()
		DUM->(DbSkip())
	EndDo
EndIf

//-- Exclui cubagem de mercadorias
DTE->(DbSetOrder(3)) //DTE_FILIAL+DTE_FILORI+DTE_NUMCOT+DTE_CODPRO
If DTE->(MsSeek(xFilial('DTE')+cFilOri+cNumSol))
	While DTE->(!Eof()) .And. DTE->DTE_FILIAL + DTE->DTE_FILORI + DTE->DTE_NUMSOL == xFilial('DTE') + cFilOri + cNumSol
		RecLock('DTE',.F.)
		DTE->( DbDelete() )
		MsUnLock()
		DTE->(DbSkip())
	EndDo
EndIf

//-- Exclui tipos de veiculos da solicitacao
DVT->(DbSetOrder(1))
If DVT->(MsSeek(xFilial('DVT')+cFilOri+cNumSol))
	While DVT->(!Eof()) .And. DVT->DVT_FILIAL + DVT->DVT_FILORI + DVT->DVT_NUMSOL == xFilial('DVT') + cFilOri + cNumSol
		RecLock('DVT',.F.)
		DVT->( DbDelete() )
		MsUnLock()
		DVT->(DbSkip())
	EndDo
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMSAF05Srv³ Autor ³ Eduardo de Souza      ³ Data ³ 31/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Consulta SXB do campo DTC_SERVIC (XXX)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Srv()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Srv()

Local lMVC		    := IsInCallStack("TMSAF74") //-- Define Se Está Sendo Executado Pela Rotina TMSAF74 Em MVC
Local oModel	    := Nil

	//-- Compatibilizado Para Funcionamento TMSA019 / TMSA019A
	If "DDD_" $ ReadVar() 

		TMSPesqServ('DDD',	M->DDD_CLIDEV,                                      ;
								M->DDD_LOJDEV,                                      ;
								StrZero(3,TamSx3("DTC_SERTMS")[1]),                 ;
								M->DDD_TIPTRA	,,,                                   ;
								M->DDD_TIPFRE	,,,,,,,,                              ;
								M->DDD_CDRORI,                                      ;
								M->DDD_CDRDES ,,,,,,,,                              ;
								M->DDD_CODNEG)
	Else
		If lMVC	//-- Compatibilização TMSAF74
		
			oModel := FWModelActive() //-- Carrega Model Ativa
			
			TMSPesqServ('DF1',	oModel:GetValue( 'MdGridDF1', 'DF1_CLIDEV' ),         ;
									oModel:GetValue( 'MdGridDF1', 'DF1_LOJDEV' ),         ;
									StrZero(3,Len(DTC->DTC_SERTMS)),                      ;
									oModel:GetValue( 'MdGridDF1', 'DF1_TIPTRA' ),,,       ;
									oModel:GetValue( 'MdGridDF1', 'DF1_TIPFRE' ),,,,,,,,  ;
									oModel:GetValue( 'MdGridDF1', 'DF1_CDRORI' ),         ;
									oModel:GetValue( 'MdGridDF1', 'DF1_CDRDES' ),,,,,,,,  ;
									oModel:GetValue( 'MdGridDF1', 'DF1_CODNEG' ),Nil)
		Else

			TMSPesqServ('DF1',	GDFieldGet("DF1_CLIDEV",n),                           ;
									GDFieldGet("DF1_LOJDEV",n),                           ;
									StrZero(3,Len(DTC->DTC_SERTMS)),                      ;
									GDFieldGet("DF1_TIPTRA",n),,,                         ;
									GDFieldGet("DF1_TIPFRE",n),,,,,,,,                    ;
									GDFieldGet("DF1_CDRORI",n),                           ;
									GDFieldGet("DF1_CDRDES",n),,,,,,,,                    ;
									GDFieldGet("DF1_CODNEG",n))
		EndIf						
	EndIf
Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05SQE³ Autor ³ Eduardo de Souza      ³ Data ³ 07/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Sequencia Agendamento                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05SQE()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05SQE(nOpcx,lTmaf05Auto)

Local oGetDSeq
Local oDlgEsp
Local nOpcSeq    := Iif( nOpcx == 3 .Or. nOpcx == 4, 6, 2 )
Local nSequen    := 0
Local n1Cnt      := 0
Local n2Cnt      := 0
Local nOpca      := 0
Local cTmsTit    := cCadastro
Local aInfo      := {}
Local aObjects   := {}
Local aPosObj    := {}
Local aSize      := {}
Local aAltera    := {}
Local aVisual    := {'DF0_NUMAGE'}
Local cAlias     := 'DF0'
Local nReg       := DF0->(Recno())
Local aAltGetD   := {'DF1_SEQUEN','DF1_DISTAN'}
Local aYesFields := {}
Local nLin       := 0
Local aColsAux   := AClone(aCols)
Local nPIteAge   := GDFieldPos("DF1_ITEAGE")
Local nPSequen   := GDFieldPos("DF1_SEQUEN")
Local nPSeqEnt   := GDFieldPos("DF1_SEQENT")
Local nPDest     := GDFieldPos("DF1_CLIDES")
Local nPNomCol   := GDFieldPos("DF1_NOMREM")
Local nPEndCol   := GDFieldPos("DF1_END"   )
Local nPBaiCol   := GDFieldPos("DF1_BAIRRO")
Local nPMunCol   := GDFieldPos("DF1_MUN"   )
Local nPEstCol   := GDFieldPos("DF1_EST"   )
Local nPCepCol   := GDFieldPos("DF1_CEP"   )
Local nPRDesCol  := GDFieldPos("DF1_CDRORI")
Local nPRegCol   := GDFieldPos("DF1_REGORI")
Local nPNomEnt   := GDFieldPos("DF1_NOMDES")
Local nPEndEnt   := GDFieldPos("DF1_ENDDES")
Local nPBaiEnt   := GDFieldPos("DF1_BAIDES")
Local nPMunEnt   := GDFieldPos("DF1_MUNDES")
Local nPEstEnt   := GDFieldPos("DF1_ESTDES")
Local nPCepEnt   := GDFieldPos("DF1_CEPDES")
Local nPRDesEnt  := GDFieldPos("DF1_CDRDES")
Local nPRegEnt   := GDFieldPos("DF1_REGDES")
Local nPTipTra   := GDFieldPos("DF1_TIPTRA")
Local nPCliDev   := GDFieldPos("DF1_CLIDEV")
Local nPLojDev   := GDFieldPos("DF1_LOJDEV")
Local nPNomDev   := GDFieldPos("DF1_NOMDEV")
Local nPDistan   := GDFieldPos("DF1_DISTAN")
Local nPDistIV   := 0
Local cDistIV    := ''
Local nPDelet    := Len(aHeader)+1
Local nColEnt    := 1
Local nTotDisOld := M->DF0_TOTDIS
Local cCliente   := ""
Local cLoja      := ""
Local aFldAux	 := {}
Local aFldAll	 := {}
Local nPos		 := 0

Private oEnchSeq
Default lTmaf05Auto := .F.

//-- Obtendo a escolha do usuario qto. ao calculo da distancia
nPDistIV := GDFieldPos("DF1_DISTIV")
cDistIV  := GDFieldGet("DF1_DISTIV")

//-- Cliente de calculo da cotacao
TMSAF05Cli(@cCliente,@cLoja)

SaveInter()
aHeader   := {}
aCols     := {}
cCadastro := STR0050 // 'Sequencia Agendamento'

//-- Permite alterar a sequencia somente com o status do agendamento a confirmar.
If Inclui .Or. ;
	M->DF0_STATUS == StrZero(1,Len(DF0->DF0_STATUS)) .Or. ; // A Confirmar
	M->DF0_STATUS == StrZero(2,Len(DF0->DF0_STATUS)) .Or. ; // Confirmado
	M->DF0_STATUS == StrZero(3,Len(DF0->DF0_STATUS)) // Em Processo
	lAltSeq   := .T.
EndIf

//-- Ordena por sequencia + item do agendamento
ASort( aColsAux,,, {|x,y| x[nPSequen] + x[nPIteAge] < y[nPSequen] + y[nPIteAge]} )

//-- Configura vetor aHeader
AAdd( aYesFields, 'DF1_ITEAGE' ) //-- Item Agendamento
AAdd( aYesFields, 'DF1_SEQUEN' ) //-- Sequencia
AAdd( aYesFields, 'TIPOAGE'    )	//-- Tipo Agend. (Coleta/Entrega)
AAdd( aYesFields, 'DF1_DISTAN')	//-- Distancia
AAdd( aYesFields, 'DF1_DISTIV' ) //-- Distancia Ida/Volta
AAdd( aYesFields, 'A1_NOME'    )	//-- Solicitante
AAdd( aYesFields, 'A1_END'     )	//-- Endereco
AAdd( aYesFields, 'A1_BAIRRO'  )	//-- Bairro
AAdd( aYesFields, 'A1_MUN'     )	//-- Municipio
AAdd( aYesFields, 'A1_EST'     )	//-- Estado
AAdd( aYesFields, 'A1_CEP'     )	//-- Cep
AAdd( aYesFields, 'A1_CDRDES'  )	//-- Regiao
AAdd( aYesFields, 'A1_REGDES'  )	//-- Regiao
AAdd( aYesFields, 'DF1_TIPTRA' )	//-- Tipo Transporte
AAdd( aYesFields, 'DF1_CLIDEV' )	//-- Cliente Devedor
AAdd( aYesFields, 'DF1_LOJDEV' )	//-- Loja Devedor
AAdd( aYesFields, 'DF1_NOMDEV' )	//-- Nome Devedor

aFldAux := ApBuildHeader("DF1")
For n1Cnt := 1 To Len(aFldAux)
	aAdd(aFldAll, aFldAux[n1Cnt])
Next

aFldAux := ApBuildHeader("SA1")
For n1Cnt := 1 To Len(aFldAux)
	aAdd(aFldAll, aFldAux[n1Cnt])
Next

For n1Cnt := 1 To Len(aYesFields)
	If aYesFields[n1Cnt] == 'TIPOAGE'  //-- Tipo Agendamento
		AAdd(aHeader, {STR0047, 'TIPOAGE', '' , 7, 0, '', 'S', 'C', '', 'V'}) //"Tipo Agend."
	ElseIf (nPos := AScan(aFldAll, {|x| Alltrim(x[2]) == aYesFields[n1Cnt]})) > 0
		AAdd(aHeader, aFldAll[nPos])
	EndIf
Next

aSize(aFldAux, 0)
aFldAux := Nil

aSize(aFldAll, 0)
aFldAll := Nil

For n1Cnt := 1 To Len(aColsAux)

	If !aColsAux[n1Cnt,nPDelet]

		//-- Tipo de Agendamento (Coleta/Entrega).
		nColEnt := 1
		If !Empty(aColsAux[n1Cnt,nPDest])
			nColEnt := 2
		EndIf

		//-- Alimenta aCols com os dados do agendamento.
		For n2Cnt := 1 To nColEnt
			AAdd( aCols, Array( Len( aHeader ) + 1 ) )
			nLin    := Len( aCols )
			GDFieldPut('DF1_ITEAGE',aColsAux[n1Cnt,nPIteAge],nLin)

			//-- Verifica se a sequencia esta preenchida.
			If aColsAux[n1Cnt,nPSequen] <> Replicate('x',Len(DF1->DF1_SEQUEN)) .And. n2Cnt == 1 //-- Coleta
				GDFieldPut('DF1_SEQUEN',aColsAux[n1Cnt,nPSequen],nLin)
				//-- Armazena a maior sequencia do agendamento
				If	nSequen <  Val(aColsAux[n1Cnt,nPSequen])
					nSequen := Val(aColsAux[n1Cnt,nPSequen])
				EndIf
			ElseIf aColsAux[n1Cnt,nPSeqEnt] <> Replicate('x',Len(DF1->DF1_SEQUEN)) .And. n2Cnt == 2 //-- Entrega
				GDFieldPut('DF1_SEQUEN',aColsAux[n1Cnt,nPSeqEnt],nLin)
				//-- Armazena a maior sequencia do agendamento
				If nSequen < Val(aColsAux[n1Cnt,nPSeqEnt])
					nSequen := Val(aColsAux[n1Cnt,nPSeqEnt])
				EndIf
			Else
				nSequen += 1
				GDFieldPut('DF1_SEQUEN',StrZero(nSequen,Len(DF1->DF1_SEQUEN)),nLin)
			EndIf

			//-- Tipo Agendamento (Coleta/Entrega)
			If n2Cnt == 1
				GDFieldPut('TIPOAGE', STR0058, nLin) //"Coleta "
				If nPNomCol > 0
					GDFieldPut('A1_NOME',	aColsAux[n1Cnt,nPNomCol],	nLin)
				EndIf
				If nPEndCol > 0
					GDFieldPut('A1_END',	aColsAux[n1Cnt,nPEndCol],	nLin)
				EndIf
				If nPBaiCol > 0
					GDFieldPut('A1_BAIRRO',	aColsAux[n1Cnt,nPBaiCol],	nLin)
				EndIf
				If nPMunCol > 0
					GDFieldPut('A1_MUN',	aColsAux[n1Cnt,nPMunCol],	nLin)
				EndIf
				If nPEstCol > 0
					GDFieldPut('A1_EST',	aColsAux[n1Cnt,nPEstCol],	nLin)
				EndIf
				If nPCepCol > 0
					GDFieldPut('A1_CEP',	aColsAux[n1Cnt,nPCepCol],	nLin)
				EndIf
				If nPRDesCol > 0
					GDFieldPut('A1_CDRDES',	aColsAux[n1Cnt,nPRDesCol],	nLin)
				EndIf
				If nPRegCol > 0
					GDFieldPut('A1_REGDES',	aColsAux[n1Cnt,nPRegCol],	nLin)
				EndIf
				If nPDistan > 0
					GDFieldPut('DF1_DISTAN'  , 0 , nLin)
				EndIf
			Else
				GDFieldPut('TIPOAGE', STR0059, nLin) //"Entrega"
				If nPNomEnt > 0
					GDFieldPut('A1_NOME',	aColsAux[n1Cnt,nPNomEnt],	nLin)
				EndIf
				If nPEndEnt	> 0
					GDFieldPut('A1_END',	aColsAux[n1Cnt,nPEndEnt],	nLin)
				EndIf
				If nPBaiEnt > 0
					GDFieldPut('A1_BAIRRO',	aColsAux[n1Cnt,nPBaiEnt],	nLin)
				EndIf
				If nPMunEnt > 0
					GDFieldPut('A1_MUN',	aColsAux[n1Cnt,nPMunEnt],	nLin)
				EndIf
				If nPEstEnt > 0
					GDFieldPut('A1_EST',	aColsAux[n1Cnt,nPEstEnt],	nLin)
				EndIf
				If nPCepEnt > 0
					GDFieldPut('A1_CEP',	aColsAux[n1Cnt,nPCepEnt],	nLin)
				EndIf
				If nPRDesEnt > 0
					GDFieldPut('A1_CDRDES',	aColsAux[n1Cnt,nPRDesEnt],	nLin)
				EndIf
				If nPRegEnt > 0
					GDFieldPut('A1_REGDES',	aColsAux[n1Cnt,nPRegEnt],	nLin)
				EndIf
				If nPDistan > 0
					GDFieldPut('DF1_DISTAN',aColsAux[n1Cnt,nPDistan],	nLin)
				EndIf
			EndIf
			If nPTipTra > 0
				GDFieldPut('DF1_TIPTRA',	aColsAux[n1Cnt,nPTipTra],	nLin)
			EndIf
			If nPCliDev > 0
				GDFieldPut('DF1_CLIDEV',	aColsAux[n1Cnt,nPCliDev],	nLin)
			EndIf
			If nPLojDev > 0
				GDFieldPut('DF1_LOJDEV',	aColsAux[n1Cnt,nPLojDev],	nLin)
			EndIf
			If nPNomDev > 0
				GDFieldPut('DF1_NOMDEV',	aColsAux[n1Cnt,nPNomDev],	nLin)
			EndIf
			If nPDistIV > 0
				GDFieldPut('DF1_DISTIV',If(M->DF0_TIPDIS == '2', aColsAux[n1Cnt,nPDistIV], M->DF0_DISTIV),nLin)
			EndIf

			aCols[ nLin, Len( aHeader ) + 1 ] := .F.
		Next n2Cnt
	EndIf
Next n1Cnt

If !Empty(aCols)

	//-- Ordena por sequencia + item do agendamento
	ASort( aCols,,, {|x,y| x[SEQUEN] + x[ITEAGE] < y[SEQUEN] + y[ITEAGE]} )

	//-- Atualiza a distancia entre as regioes.
	F05TotDist(cCliente,cLoja)

	If !lTmaf05Auto
	//-- Dimensoes padroes
	aSize := MsAdvSize()
	AAdd( aObjects, { 100, 45, .T., .T. } )
	AAdd( aObjects, { 100, 55, .T., .T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	DEFINE MSDIALOG oDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
		oEnchSeq	:= MsMGet():New( cAlias, nReg, nOpcSeq,,,, aVisual, aPosObj[1], aAltera, 3, , , , , ,.T. )
		oGetDSeq	:= MSGetDados():New(aPosObj[ 2, 1 ], aPosObj[ 2, 2 ],aPosObj[ 2, 3 ], aPosObj[ 2, 4 ], nOpcSeq,'AllWaysTrue','AllWaysTrue',        ,    .T., aAltGetD,1      ,      ,nLin,        ,         ,       ,'!AllWaysTrue()',    )
	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp, {|| If(F05VldDist(),(nOpca:=1,oDlgEsp:End()),.F.)},;
																			 {|| oDlgEsp:End() } ) CENTERED
	Else
		nOpca := 1
	EndIf
	cCadastro := cTmsTit
	lAltSeq   := .F.

	If nOpcSeq <> 2 .And. nOpca == 1
		//-- Ordena o vetor de trabalho pela sequencia.
		M->DF0_TOTDIS := 0
		For n1Cnt := 1 To Len(aCols)
			nPos := Ascan( aColsAux, { |x| x[nPIteAge] == aCols[n1Cnt,ITEAGE] } )
			aColsAux[nPos,nPDistan] := 0
			If !Empty( nPos )
				If SubStr(aCols[n1Cnt,TIPOAGE],1,1) == 'C' //-- Coleta
					aColsAux[nPos,nPSequen] := aCols[n1Cnt,SEQUEN]
				Else //-- Entrega
					aColsAux[nPos,nPSeqEnt] := aCols[n1Cnt,SEQUEN]
				EndIf
			EndIf	
			//--Soma as novas distancias, o usuario pode mudar a distancia padrao do cadastro
			//--Alimenta o cabecalho com a nova distancia
			aColsAux[nPos,nPDistan] += aCols[n1Cnt,DIST]
			M->DF0_TOTDIS += aCols[n1Cnt,DIST]
		Next n1Cnt
		//-- Ordena o vetor de trabalho pela sequencia.
		ASort( aColsAux,,,{|x,y| x[SEQUEN] < y[SEQUEN] } )
		lAtuSeqAgend := .F.
	Else
		M->DF0_TOTDIS := nTotDisOld
	EndIf
EndIf

RestInter()
aCols := AClone(aColsAux)

//-- Ordena por item do agendamento
ASort( aCols,,, {|x,y| x[nPIteAge] < y[nPIteAge]} )

If !lTmaf05Auto
	oGetDAge:Refresh()
EndIf

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05Ord³ Autor ³ Eduardo de Souza      ³ Data ³ 07/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Troca a ordem dos itens agendados ao digitar a sequencia.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Ord()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsAF05Ord()

Local nSeek      := 0
Local nCntFor    := 0
Local aColsAux   := AClone(aCols)
Local nNewSequen := 0
Local cSequencia := &(ReadVar())
Local cIteAge    := ""
Local cTipoAge   := ""
Local lBaixo     := .F.
Local cCliente   := ""
Local cLoja      := ""

//-- Cliente de calculo da cotacao
TMSAF05Cli(@cCliente,@cLoja)

//-- Teclou enter sem alterar a sequencia.
If cSequencia == GDFieldGet('DF1_SEQUEN',n)
	Return( .T. )
EndIf

//-- Procura a sequencia digitada no aCols.
nSeek := Ascan( aCols, { |X| X[SEQUEN] == cSequencia } )
If Empty( nSeek )
	//-- Nao permite informar sequencia que nao exista.	
	Help(' ', 1, 'TMSAF0523') //"Sequencia nao encontrada"
	Return( .F. )
EndIf

cIteAge  := aColsAux[n,ITEAGE ]
cTipoAge := aColsAux[n,TIPOAGE]

//-- Ordena o vetor de trabalho pela sequencia.
ASort( aColsAux,,,{|x,y| x[SEQUEN] < y[SEQUEN] } )

//-- Mover a linha atual para baixo.
lBaixo := cSequencia > aColsAux[n,SEQUEN]

//-- Grava no vetor de trabalho a sequencia digitada.
aColsAux[n,SEQUEN] := cSequencia
ASort( aColsAux,,,{|x,y| x[SEQUEN] < y[SEQUEN] } )

//-- Altera a sequencia.
For nCntFor := 1 To Len( aColsAux )
	//-- Desconsidera Item atual
	If aColsAux[nCntFor,ITEAGE]+aColsAux[nCntFor,TIPOAGE] <> cIteAge + cTipoAge
		If	aColsAux[nCntFor,SEQUEN] == cSequencia
			If lBaixo
				aColsAux[nCntFor,SEQUEN] := StrZero(nCntFor,Len(DF1->DF1_SEQUEN))
				Exit
			Else
				nNewSequen := Val(cSequencia) + 1
				aColsAux[nCntFor,SEQUEN] := StrZero(nNewSequen,Len(DF1->DF1_SEQUEN))
			EndIf
		Else
			aColsAux[nCntFor,SEQUEN] := StrZero(nNewSequen += 1,Len(DF1->DF1_SEQUEN))
		EndIf
	EndIf
Next nCntFor

//-- Ordena o vetor de trabalho pela sequencia.
ASort( aColsAux,,,{|x,y| x[SEQUEN] < y[SEQUEN] } )

&(ReadVar()):= aColsAux[n,SEQUEN]

aCols := AClone(aColsAux)

//-- Atualiza a distancia entre as regioes.
F05TotDist(cCliente,cLoja)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSF05CDist³ Autor ³ Eduardo de Souza     ³ Data ³ 08/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula a distancia entre as regioes.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSF05CDist(ExpC1,ExpC2,ExpC3,ExpC4,ExpN1,ExpL1)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Cliente                                            ³±±
±±³          ³ ExpC2 - Loja                                               ³±±
±±³          ³ ExpC3 - Tipo Transporte                                    ³±±
±±³          ³ ExpC4 - Regiao                                             ³±±
±±³          ³ ExpN1 - Posicao atual                                      ³±±
±±³          ³ ExpL1 - Calcula Ida/Volta?                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSF05CDist(cCliente,cLoja,cTipTra,cRegiao,nAt,lDistIV)

Local nTotDist  := 0

	//-- Caso seja a primeira sequencia, zera as variaves.
	If nAt == 1
		cCdrOri := ''
		cCliAnt := ''
		cLojAnt := ''
	EndIf

If M->DF0_INIDIS == StrZero(1,Len(DF0->DF0_INIDIS)) //-- Transportadora
		//-- Calcula a distancia a partir da transportadora
		If nAt == 1
			nTotDist += TMSDistRot(,.F.,cGrpVen,cRegiao,cTipTra,cCliente,cLoja,lDistIV)
		Else
			nTotDist += TMSDistRot(,.F.,cCdrOri,cRegiao,cTipTra,cCliAnt,cLojAnt,lDistIV)
		EndIf
	ElseIf M->DF0_INIDIS == StrZero(2,Len(DF0->DF0_INIDIS)) //-- 1o.Coleta
		//-- Calcula a distancia a partir da primeira coleta
		If nAt <> 1
			nTotDist += TMSDistRot(,.F.,cCdrOri,cRegiao,cTipTra,cCliAnt,cLojAnt,lDistIV)
		EndIf
	EndIf
	//-- Armazena Origem e devedor utilizada na verificacao do proximo item.
	cCliAnt := cCliente
	cLojAnt := cLoja
	cCdrOri := cRegiao

Return( nTotDist )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³F05TotDist ³ Autor ³ Eduardo de Souza     ³ Data ³ 08/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza a distancia total entre as regioes.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ F05TotDist(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function F05TotDist(cCliente,cLoja)

Local nDist    := 0
Local cTipTra  := ""
Local cRegiao  := ""
Local n1Cnt    := 0
Local nAt      := 0
Local lDistIV  := .F.

//-- Atualiza a distancia entre as regioes.
M->DF0_TOTDIS := 0
For n1Cnt := 1 To Len(aCols)
	//-- Caso endereco da sequencia anterior for igual, nao calcula a distancia.
	nDist   := 0
	nAt     := n1Cnt
	lDistIV := GDFieldGet("DF1_DISTIV",n1Cnt) == '1'
	If n1Cnt == 1 .Or. aCols[n1Cnt,ENDER] <> aCols[n1Cnt-1,ENDER] .Or. M->DF0_TIPDIS == StrZero(2,Len(DF0->DF0_TIPDIS)) //-- Ponto a Ponto
		//-- Rota ponto a ponto, o calculo sera efetuado a cadas dois itens.
		If M->DF0_TIPDIS == StrZero(2,Len(DF0->DF0_TIPDIS)) //-- Ponto a Ponto
			nAt := Mod(n1Cnt,2)
		EndIf
		cTipTra := GDFieldGet("DF1_TIPTRA",n1Cnt)
		cRegiao := GDFieldGet("A1_CDRDES" ,n1Cnt)
		If Empty(cRegiao)
			cRegiao := GDFieldGet("DF1_CDRDES" ,n1Cnt)
		EndIf
		nDist := TMSF05CDist(cCliente,cLoja,cTipTra,cRegiao,nAt,lDistIV)
	Endif
	//--So recalcula se ainda nao tem valores
	If SubStr(aCols[n1Cnt,TIPOAGE],1,1) == 'E' .And. aCols[n1Cnt,DIST] == 0 //--Entrega e ja foi calculado
		GDFieldPut('DF1_DISTAN', nDist, n1Cnt)
	EndIf
	M->DF0_TOTDIS += GDFieldGet("DF1_DISTAN",n1Cnt)
Next n1Cnt

//-- Atualiza a Enchoice da tela de sequencia.
If Type('oEnchSeq') == 'O'
	oEnchSeq:Refresh()
EndIf

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³F05VldDist ³ Autor ³ Eduardo de Souza     ³ Data ³ 13/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a distancia ponto a ponto                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ F05VldDist()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function F05VldDist()

Local lRet     := .T.
Local n1Cnt    := 0
Local cOldTipo := ""

If M->DF0_TIPDIS == StrZero(2,Len(DF0->DF0_TIPDIS)) //-- Ponto a Ponto
	For n1Cnt := 1 To Len(aCols)
		//-- Atualiza o tipo do agendamento quando o item for um numero par.
		//-- Utilizada para validar itens de dois em dois para rota ponto a ponto.
		cOldItem := ""
		cOldTipo := ""
		If Mod(n1Cnt,2) == 0
			cOldTipo := SubStr(aCols[n1Cnt-1,TIPOAGE],1,1) //-- Coleta / Entrega (Anterior)
			cOldItem := aCols[n1Cnt-1,ITEAGE ] //-- Item (Anterior)
			//-- O primeiro agendamento do item devera ser "Coleta"
			If cOldTipo <> "C" //-- Coleta
				Help(' ', 1, 'TMSAF0527') //"Quando o tipo da distancia for ponto a ponto, o 1o. agendamento do item devera ser 'Coleta'"
				lRet := .F.
				Exit
			EndIf
			//-- Sempre devera existir coleta/entrega para ponto a ponto.
			If lRet .And. cOldItem <> aCols[n1Cnt,ITEAGE]
				Help(' ', 1, 'TMSAF0526') //"Quando o tipo da distancia for ponto a ponto, a sequencia relacionada ao item, devera ser Coleta/Entrega"
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next n1Cnt
EndIf

Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMF05CDoc ³ Autor ³ Eduardo de Souza     ³ Data ³ 19/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta viagens / documento do agendamento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMF05CDoc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMF05CDoc()
Local oDlgEsp
Local oLbxViag
Local oLbxDoc
Local cQuery     := ''
Local aArea      := GetArea()
Local cAliasQry  := GetNextAlias()
Local aViagens   := {}
Local aDocumento := {}
Local aButtons   := {}
Local cLbx       := ''

cQuery := " SELECT DUD1.DUD_FILORI FILORI_C, DUD1.DUD_VIAGEM VIAGEM_C, DTC_FILDOC FILDOC, "
cQuery += "		DTC_DOC DOC, DTC_SERIE SERIE, DUD2.DUD_FILORI FILORI_E, DUD2.DUD_VIAGEM VIAGEM_E "
cQuery += "		FROM " + RetSqlName("DT5") + " DT5 "
cQuery += "		JOIN " + RetSqlName("DUD") + " DUD1 "
cQuery += "		  ON  DUD1.DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "		  AND DUD1.DUD_FILDOC = DT5_FILDOC "
cQuery += "		  AND DUD1.DUD_DOC    = DT5_DOC "
cQuery += "		  AND DUD1.DUD_SERIE  = DT5_SERIE "
cQuery += "		  AND DUD1.DUD_VIAGEM <> ' ' "
cQuery += "		  AND DUD1.D_E_L_E_T_ = ' ' "
cQuery += "		LEFT JOIN " + RetSqlName("DTC") + " DTC "
cQuery += "		  ON  DTC_FILIAL = '" + xFilial("DTC") + "' "
cQuery += "		  AND DTC_FILORI = DT5_FILORI "
cQuery += "		  AND DTC_NUMSOL = DT5_NUMSOL "
cQuery += "		  AND DTC.D_E_L_E_T_ = ' ' "
cQuery += "		LEFT JOIN " + RetSqlName("DUD") + " DUD2 "
cQuery += "		  ON  DUD2.DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "		  AND DUD2.DUD_FILDOC = DTC_FILDOC "
cQuery += "		  AND DUD2.DUD_DOC    = DTC_DOC "
cQuery += "		  AND DUD2.DUD_SERIE  = DTC_SERIE "
cQuery += "		  AND DUD2.DUD_STATUS <> '" + StrZero(1,Len(DUD->DUD_STATUS)) + "' "
cQuery += "		  AND DUD2.D_E_L_E_T_ = ' ' "
cQuery += "		WHERE DT5_FILIAL = '" + xFilial("DT5") + "' "
cQuery += "		  AND DT5_FILDOC = '" + GdFieldGet('DF1_FILDOC',n) + "' "
cQuery += "		  AND DT5_DOC    = '" + GdFieldGet('DF1_DOC',n)    + "' "
cQuery += "		  AND DT5_SERIE  = '" + GdFieldGet('DF1_SERIE',n)  + "' "
cQuery += "		  AND DT5.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())
	//-- Armazena viagens de coleta
	If Ascan( aViagens, { |x| x[1] + x[2] == (cAliasQry)->FILORI_C + (cAliasQry)->VIAGEM_C } ) == 0
		AAdd( aViagens, { (cAliasQry)->FILORI_C, (cAliasQry)->VIAGEM_C, STR0058 } ) // 'Coleta'
	EndIf
	//-- Armazena viagens de entrega
	If !Empty((cAliasQry)->VIAGEM_E)
		If Ascan( aViagens, { |x| x[1] + x[2] == (cAliasQry)->FILORI_E + (cAliasQry)->VIAGEM_E } ) == 0
			AAdd( aViagens, { (cAliasQry)->FILORI_E, (cAliasQry)->VIAGEM_E, STR0059 } ) // 'Entrega'
		EndIf
	EndIf
	//-- Armazena o documento de transporte gerado apartir da solicitacao de coleta
	If Ascan( aDocumento, { |x| x[1] + x[2] + x[3] == (cAliasQry)->FILDOC + (cAliasQry)->DOC + (cAliasQry)->SERIE } ) == 0
		AAdd( aDocumento, { (cAliasQry)->FILDOC, (cAliasQry)->DOC, (cAliasQry)->SERIE } )
	EndIf
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

RestArea( aArea )
If !Empty(aViagens) .Or. !Empty(aDocumento)

	//-- Ordena o array por tipo de viagem
	ASort( aViagens,,, { | x, y | x[3]+x[2] < y[3]+y[2] } )

	AAdd(aButtons, {'CARGA'    , {||TmsVisViag(aViagens[oLbxViag:nAT,1],aViagens[oLbxViag:nAT,2])}, STR0055 }) // 'Viagem'
	AAdd(aButtons, {'RELATORIO', {||TMSViewDoc(aDocumento[oLbxDoc:nAT,1],aDocumento[oLbxDoc:nAT,2],aDocumento[oLbxDoc:nAT,3])}, STR0056, STR0051 } ) // 'Documento'

	DEFINE MSDIALOG oDlgEsp TITLE STR0057 FROM 00,00 TO 350,769 PIXEL //-- Viagens do agendamento

		//-- Viagem
		@ 32,01 LISTBOX oLbxViag VAR cLbx FIELDS HEADER RetTitle('DTQ_FILORI'), RetTitle('DTQ_VIAGEM'), RetTitle('DTQ_SERTMS')	SIZE 383,68 OF oDlgEsp PIXEL
		oLbxViag:SetArray( aViagens )
		oLbxViag:bLine := { || { aViagens[ oLbxViag:nAT, 1 ], aViagens[ oLbxViag:nAT, 2 ], aViagens[ oLbxViag:nAT, 3 ] } }

		//-- Documento
		@ 100,01 LISTBOX oLbxDoc VAR cLbx FIELDS HEADER RetTitle('DT6_FILDOC'), RetTitle('DT6_DOC'), RetTitle('DT6_SERIE') SIZE 383,70 OF oDlgEsp PIXEL
		oLbxDoc:SetArray( aDocumento )
		oLbxDoc:bLine := { || { aDocumento[ oLbxDoc:nAT, 1 ], aDocumento[ oLbxDoc:nAT, 2 ], aDocumento[ oLbxDoc:nAT, 3 ] } }

	ACTIVATE MSDIALOG oDlgEsp CENTERED ON INIT EnchoiceBar( oDlgEsp, {|| oDlgEsp:End() },{|| oDlgEsp:End() },, aButtons )
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmAF05GCot³ Autor ³ Eduardo de Souza     ³ Data ³ 11/11/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera cotacao de frete com rateio                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMAF05GCot(ExpN1,ExpN2,ExpN3,ExpN4)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Total do Peso                                      ³±±
±±³          ³ ExpN2 - Total do Valor de Mercadoria                       ³±±
±±³          ³ ExpN3 - Total dos Volumes                                  ³±±
±±³          ³ ExpN4 - Total de itens                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmAF05GCot(nTotPeso,nTotValMer,nTotQtdVol,nQtdItem,lAtuRat)

Local lRet    := .F.
Local nCnt    := 0
Local nValTot := 0
Local lTela   := .F. //-- Nao exibe a tela de cotacao
Local lAviso  := .F. //-- Nao exibe a tela de confirmacao de gravacao do agendamento
Local cTipRat := ''
Local nVlrInf := 0
Local nTotAux := 0
Local nPeso   := 0

Default lAtuRat := .F.

For nCnt := 1 To Len(aCols)
	If !GdDeleted(nCnt)
		If GdFieldGet("DF1_STACOL",nCnt) <> StrZero(9,Len(GdFieldGet("DF1_STACOL",nCnt)))
			If nValTot == 0
				If !lAtuRat
					//-- Zera frete informado, para forcar novo calculo
					GdFieldPut("DF1_VLRINF",0,nCnt)
					lRet := TMSAF05Cot(.T.,,lTela,nCnt,lAviso,.T.)
					If !lRet
						Exit
					EndIf
					nValTot := GdFieldGet("DF1_VALFRE",nCnt)
				Else
					nValTot := nTValTot
				EndIf
				nTotAux := nValTot
				nPeso   += GdFieldGet("DF1_PESO",nCnt)
				//-- Se houver somente um item, nao existe rateio
				If nQtdItem == 1
					Exit
				EndIf
				//-- Processa o rateio de acordo com o tipo
				If ( cTipRat := Posicione("DC5",1,xFilial("DC5")+GdFieldGet("DF1_SERVIC",nCnt),"DC5_TIPRAT") ) == StrZero(1,Len(DC5->DC5_TIPRAT)) //-- Peso Mercadoria
					nVlrInf := (nValTot * GdFieldGet("DF1_PESO",nCnt)) / nTotPeso
				ElseIf cTipRat == StrZero(2,Len(DC5->DC5_TIPRAT)) //-- Valor Mercadoria
					nVlrInf := (nValTot * GdFieldGet("DF1_VALMER",nCnt)) / nTotValMer
				ElseIf cTipRat == StrZero(3,Len(DC5->DC5_TIPRAT)) //-- Volume
					nVlrInf := (nValTot * GdFieldGet("DF1_QTDVOL",nCnt)) / nTotQtdVol
				ElseIf cTipRat == StrZero(4,Len(DC5->DC5_TIPRAT)) //-- Qtde Doctos
					nVlrInf := nValTot / nQtdItem
				EndIf
				nTotAux -= nVlrInf
				GdFieldPut("DF1_VLRINF",nVlrInf,nCnt)
				lRet := TMSAF05Cot(.T.,,lTela,nCnt,lAviso,.T.)
				If !lRet
					Exit
				EndIf
			Else
				nPeso += GdFieldGet("DF1_PESO",nCnt)
				If nPeso == nTotPeso //-- Ultimo Item nao faz rateio para não ocorrer diferenca de centavos
					nVlrInf := nTotAux
				Else
					//-- Processa o rateio de acordo com o tipo
					If ( cTipRat := Posicione("DC5",1,xFilial("DC5")+GdFieldGet("DF1_SERVIC",nCnt),"DC5_TIPRAT") ) == StrZero(1,Len(DC5->DC5_TIPRAT)) //-- Peso Mercadoria
						nVlrInf := (nValTot * GdFieldGet("DF1_PESO",nCnt)) / nTotPeso
					ElseIf cTipRat == StrZero(2,Len(DC5->DC5_TIPRAT)) //-- Valor Mercadoria
						nVlrInf := (nValTot * GdFieldGet("DF1_VALMER",nCnt)) / nTotValMer
					ElseIf cTipRat == StrZero(3,Len(DC5->DC5_TIPRAT)) //-- Volume
						nVlrInf := (nValTot * GdFieldGet("DF1_QTDVOL",nCnt)) / nTotQtdVol
					ElseIf cTipRat == StrZero(4,Len(DC5->DC5_TIPRAT)) //-- Qtde Doctos
						nVlrInf := nValTot / nQtdItem
					EndIf
					nVlrInf := Round(nVlrInf,2)
					nTotAux -= nVlrInf
				EndIf
				GdFieldPut("DF1_VLRINF",nVlrInf,nCnt)
				lRet := TMSAF05Cot(.T.,,lTela,nCnt,lAviso,.T.)
				If !lRet
					Exit
				EndIf
			EndIf
		ElseIf lAtuRat
			TmsA040Can(GdFieldGet("DF1_FILORI",nCnt),GdFieldGet("DF1_NUMCOT",nCnt),dDataBase)
			GdFieldPut("DF1_VLRINF",0,nCnt)
			GdFieldPut("DF1_NUMCOT",CriaVar("DF1_NUMCOT",.F.),nCnt)
			GdFieldPut("DF1_VALFRE",0,nCnt)
			GdFieldPut("DF1_VALIMP",0,nCnt)
			GdFieldPut("DF1_VALTOT",0,nCnt)
		EndIf
	EndIf
Next nCnt

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMF05OriC ³ Autor ³ Eduardo de Souza     ³ Data ³ 02/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a origem utilizada na solicitacao de coleta        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMF05OriC(ExpC1,ExpC2,ExpC3,ExpC4)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Remetente                                          ³±±
±±³          ³ ExpC2 - Loja Remetente                                     ³±±
±±³          ³ ExpC3 - Seq. Endereco Remetente                            ³±±
±±³          ³ ExpC4 - Local Coleta                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF05                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMF05OriC(cCliRem,cLojRem,cSeqEnd,cLocCol)

Local cCdrOri   := Space(Len(DF1->DF1_CDRORI))
Default cSeqEnd := GDFieldGet("DF1_SQEREM",n)
Default cLocCol := GDFieldGet("DF1_LOCCOL",n)

If cLocCol == StrZero(2,Len(DF1->DF1_LOCCOL)) // Remetente
	If !Empty(cSeqEnd)
		cCdrOri := Posicione("DUL",2,xFilial("DUL")+GDFieldGet("DF1_CLIREM",n)+GDFieldGet("DF1_LOJREM",n)+cSeqEnd,"DUL_CDRDES")
	Else
		cCdrOri :=Posicione("SA1",1,xFilial("SA1")+GDFieldGet("DF1_CLIREM",n)+GDFieldGet("DF1_LOJREM",n),"A1_CDRDES")
	EndIf
Else
	If !Empty(M->DF0_SEQEND)
		cCdrOri := Posicione("DUL",3,xFilial("DUL")+M->DF0_CODSOL+M->DF0_SEQEND,"DUL_CDRDES")
	Else
		cCdrOri := Posicione("DUE",1,xFilial("DUE")+M->DF0_CODSOL,"DUE_CDRSOL")
	EndIf
EndIf

Return( cCdrOri )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
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
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Private aRotina   := {	{STR0002,'AxPesqui' ,0, 1,0,.F.},; // 'Pesquisar'
						{STR0003,'TMSF05Mnt',0, 2,0,NIL},; // 'Visualizar'
						{STR0004,'TMSF05Mnt',0, 3,0,NIL},; // 'Incluir'
						{STR0005,'TMSF05Mnt',0, 4,0,NIL},; // 'Alterar'
						{STR0006,'TMSF05Mnt',0, 5,0,NIL},; // 'Cancelar'
						{STR0007,'TMSF05Mnt',0, 6,0,NIL},; // 'Confirmar'
						{STR0008,'TMSF05Mnt',0, 7,0,NIL},; // 'Copiar'
						{STR0009,'TMSF05Leg',0, 8,0,.F.}}  // 'Legenda'

If ExistBlock("TMF05MNU")
	ExecBlock("TMF05MNU",.F.,.F.)
EndIf

Return( aRotina )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TMSF05Stat ³Autor  ³ N3-DL            ³ Data ³  14/04/09   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ajusta Status do cabecalho do agendamento.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial Agendamento                                 ³±±
±±³          ³ ExpC2 - Numero Agendamento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³ DF1_STATUS         DF0_STACOL/DF0_STAENT    Legenda        ³±±
±±³          ³ 1 - A Confirmar -> 1 - A Confirmar          BR_LARANJA     ³±±
±±³          ³ 2 - Confirmado  -> 2 - Confirmado           BR_VERDE       ³±±
±±³          ³ 3 - Em processo -> 4 - Em processo          BR_VERMELHO    ³±±
±±³          ³ 4 - Encerrado   -> 5 - Encerrado            BR_AZUL        ³±±
±±³          ³ 5 - Planejado   -> 3 - Planejado            BR_AMARELO     ³±±
±±³          ³ 9 - Cancelado   -> 9 - Cancelado            BR_PRETO       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSF05Stat(cFilAge,cNrAge)
Local cStaCol   := StrZero( 1, Len(DF1->DF1_STACOL)) // 1 = A Confirmar
Local cStaEnt   := StrZero( 1, Len(DF1->DF1_STAENT)) // 1 = A Confirmar
Local cStatus   := ""
Local cStaRet   := ""
Local cQuery    := ""
Local lEmProc   := .F.
Local lEncerr   := .F.
Local lConfir   := .F.
Local lAConfi   := .F.
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()

Default cFilAge := ""
Default cNrAge  := ""

cQuery := " SELECT DF1.DF1_STACOL, DF1.DF1_STAENT "
cQuery += " FROM " + RetSqlName("DF1") + " DF1 "
cQuery += " WHERE DF1.DF1_FILIAL = '" + cFilAge + "'"
cQuery += "   AND DF1.DF1_NUMAGE = '" + cNrAge  + "'"
cQuery += "   AND DF1.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
While (cAliasQry)->(!Eof())
	//-- Status Coleta.
	If	cStaCol < (cAliasQry)->DF1_STACOL
		cStaCol := (cAliasQry)->DF1_STACOL
	EndIf
	//-- Status Entrega.
	If	 cStaEnt < (cAliasQry)->DF1_STAENT 
		cStaEnt := (cAliasQry)->DF1_STAENT
	EndIf
	// Caso Status Coleta = Cancelado (9) e Status Entrega = Confirmado (2) 
	If	(cAliasQry)->DF1_STACOL == StrZero( 9, Len(DF1->DF1_STAENT)) .And. ;	// 9 = Cancelado
		(cAliasQry)->DF1_STAENT == StrZero( 2, Len(DF1->DF1_STAENT))			// 2 = Confirmado
		lEmProc := .T.
		Exit
	EndIf		
	//-- Verifica se existe itens com status 4 = Em Processo
	If	(cAliasQry)->DF1_STACOL == StrZero( 4, Len(DF1->DF1_STAENT)) .Or. ;	// 4 = Em Processo
		(cAliasQry)->DF1_STAENT == StrZero( 4, Len(DF1->DF1_STAENT))			// 4 = Em Processo
		lEmProc := .T.
		Exit
	EndIf
	//-- Verifica se existe itens com status 5 = Encerrado
	If	(cAliasQry)->DF1_STACOL == StrZero( 5, Len(DF1->DF1_STAENT)) .Or. ;	// 5 = Encerrado
		(cAliasQry)->DF1_STAENT == StrZero( 5, Len(DF1->DF1_STAENT))			// 5 = Encerrado
		lEncerr := .T.
	EndIf
	//-- Verifica se existe itens com status 1 = A Confirmar
	If	(cAliasQry)->DF1_STACOL == StrZero( 1, Len(DF1->DF1_STACOL)) 			// 1 = A confirmar
		lAConfi := .T.
	EndIf
	
	//-- Verifica se existe itens com status 2 = Confirmado
	If	(cAliasQry)->DF1_STACOL == StrZero( 2, Len(DF1->DF1_STACOL)) 			// 1 = Confirmado
		lConfir := .T.
	EndIf
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())
RestArea( aArea )
If	lEmProc //-- Se existe itens com status 4 = Em Processo
	cStatus := StrZero( 4, Len(DF1->DF1_STACOL))	// 4 = Em Processo
ElseIf	cStaCol < cStaEnt //-- Compara do Status Coleta e Status Entrega.
	cStatus := cStaCol
Else
	cStatus := cStaEnt
EndIf
//-- Se existe itens com status 5 = Encerrado e encontrou Status 1 = A Confirmar ou 2 = Confirmado
If lEncerr .And. (lConfir .Or. lAConfi)
	cStatus := StrZero( 4, Len(DF1->DF1_STACOL))	// 4 = Em Processo
EndIf
//-- Configura do Status do Agendamento
If		cStatus == StrZero( 1, Len(DF0->DF0_STATUS))	// 1 = A Confirmar
		cStaRet := StrZero( 1, Len(DF0->DF0_STATUS))	// 1 = A Confirmar
ElseIf	cStatus == StrZero( 2, Len(DF0->DF0_STATUS))	// 2 = Confirmado
		cStaRet := StrZero( 2, Len(DF0->DF0_STATUS))	// 2 = Confirmado
ElseIf	cStatus == StrZero( 3, Len(DF0->DF0_STATUS))	// 3 = Planejado
		cStaRet := StrZero( 5, Len(DF0->DF0_STATUS))	// 5 = Planejado
ElseIf	cStatus == StrZero( 4, Len(DF0->DF0_STATUS))	// 4 = Em Processo
		cStaRet := StrZero( 3, Len(DF0->DF0_STATUS))	// 3 = Em Processo
ElseIf	cStatus == StrZero( 5, Len(DF0->DF0_STATUS))	// 5 = Encerrado
		cStaRet := StrZero( 4, Len(DF0->DF0_STATUS))	// 4 = Encerrado
ElseIf	cStatus == StrZero( 9, Len(DF0->DF0_STATUS))	// 9 = Cancelado
		cStaRet := StrZero( 9, Len(DF0->DF0_STATUS))	// 9 = Cancelado
EndIf
Return( cStaRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsaF05Cor³ Autor ³ Leandro Paulino       ³ Data ³30/10/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Legenda do Browser                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TmsaF05Cor()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAF05	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF05Cor()

Local aCores := {}
	AAdd( aCores, {"DF0_STATUS=='1'", 'BR_LARANJA'	}) // A Confirmar
	AAdd( aCores, {"DF0_STATUS=='2'", 'BR_VERDE'	}) // Confirmado
	AAdd( aCores, {"DF0_STATUS=='3'", 'BR_VERMELHO'	}) // Em Processo
	AAdd( aCores, {"DF0_STATUS=='4'", 'BR_AZUL'		}) // Encerrado
	AAdd( aCores, {"DF0_STATUS=='5'", 'BR_AMARELO'	}) // Planejado
	AAdd( aCores, {"DF0_STATUS=='9'", 'BR_PRETO'	}) // Cancelado
Return ACores

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF05Whe   ³ Autor ³Valdemar Roberto       ³ Data ³09.02.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Muda o When dos Campos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Whe()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±      
±±³Retorno   ³ Logico                                                        ³±±      
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±      
±±³ Uso      ³ TMSAF05                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function TMSAF05Whe(cCampo)
Local lRet := .T.

DEFAULT cCampo := ReadVar()

If cCampo $ 'M->DF1_CODNEG'
	lRet := !Empty(GDFieldGet("DF1_CLIDEV",n)) .And. !Empty(GDFieldGet("DF1_LOJDEV",n)) .And. ;
			!Empty(GDFieldGet("DF1_CLIDES",n)) .And. !Empty(GDFieldGet("DF1_LOJDES",n))

ElseIf cCampo $ 'M->DF1_SRVCOL'
	lRet := !Empty(GDFieldGet("DF1_CODNEG",n)) .And. !Empty(GDFieldGet("DF1_CLIDEV",n)) .And. !Empty(GDFieldGet("DF1_LOJDEV",n)) .And. ;
			!Empty(GDFieldGet("DF1_CLIDES",n)) .And. !Empty(GDFieldGet("DF1_LOJDES",n))
	
EndIf

Return lRet

/*
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAF05Agd³ Autor ³ Rafael Souza     ³ Data ³ 28/06/16     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualização do Agendamento     							    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF05Agd()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Sigatms                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TMSAF05Agd()

Local cTitulo  := STR0001 //-- "Agendamento"
Local aCampos  := {}
Local aRotina  := {}
Local oStructTmp	:= Nil
Local aFldsTmp		:= {}
Local nI			:= 0

Private nOpcSel := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campos do Browse.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructTmp := FWFormStruct(1, "DF0")
aFldsTmp := oStructTmp:aFields

For nI := 1 To Len(aFldsTmp)
	If GetSX3Cache(aFldsTmp[nI][3], "X3_BROWSE") == "S"
		AAdd( aCampos, aFldsTmp[nI][3] )
	EndIf
Next

FreeObj(oStructTmp)

aSize(aFldsTmp, 0)
aFldsTmp := Nil

SaveInter()

aRotina := {	{ STR0003,"TMSF05Mnt",0,2},;		// "Visualizar"
				{ STR0007,"TMSConfSel",0,2,,,.T.}}	// "Confirmar"

MaWndBrowse(0,0,300,600,cTitulo,"DF0",aCampos,aRotina,,,,.T.)

RestInter()

Return( nOpcSel == 1 )
