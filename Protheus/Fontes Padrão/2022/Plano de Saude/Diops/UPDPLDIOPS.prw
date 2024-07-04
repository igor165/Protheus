#Include "PROTHEUS.CH"
#Include "UPDGHPAD.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} UPDPLDIRC
Compatibilizador para o DIOPS

@author TOTVS
@since 14/07/2016
@version P12
/*/
//-------------------------------------------------------------------
USER Function UPDPLDIRC()
Local nOpca       := 0
Local aSays       := {}, aButtons := {}
Local aRecnoSM0   := {}
Local lOpen       := .F.

Private nModulo   := 33 // modulo SIGAPLS
Private cMessage  := ""
Private aArqUpd	  := {}
Private aREOPEN	  := {}
Private oMainWnd
Private cCadastro := STR0001 //"Compatibilizador de Dicionários x Banco de dados"
Private cCompat   := "UPDPLDIOPS"
Private cFNC      := "MSAU-14429"   
Private cRef      := "DIOPS"

Set Dele On

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta texto para janela de processamento                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aSays,STR0002)				//"Esta rotina irá efetuar a compatibilização dos dicionários e banco de dados,"
aadd(aSays,STR0003)				//"e demais ajustes referentes a FNC abaixo:"
aadd(aSays,"ISSUE: " + cFnc)
aadd(aSays,STR0004 + cRef)		//"   Referência: "
aadd(aSays," ")
aadd(aSays,STR0005)   			//"Atenção: efetuar backup dos dicionários e do banco de dados previamente "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botoes para janela de processamento                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aButtons, { 1,.T.,{|| nOpca := 1, FechaBatch() }} )
aadd(aButtons, { 2,.T.,{|| nOpca := 0, FechaBatch() }} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe janela de processamento                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FormBatch( cCadastro , aSays , aButtons ,, 230 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa                                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nOpca == 1
	If  aviso(STR0006, STR0007, {"Sim","Não"}) == 1
		Processa( {|| UpdEmp( aRecnoSM0 , lOpen ) } , STR0008 , STR0009 , .F. ) //"Processando", "Aguarde , processando preparação dos arquivos"
	Endif
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PLSProc  ³ Autor ³ Microsiga				³ Data ³ 11/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao dos arquivos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao PLS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PLSProc( lEnd , aRecnoSM0 , lOpen )

Local cTexto    := ''
Local cFile     := ""
Local cMask     := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno    := 0
Local nI        := 0
Local nX        := 0
Local lSel      := .T.
Local cCodigo:= ""

ProcRegua(1)
IncProc("Verificando integridade dos dicionários....")
ProcessMessage()

If lOpen
	
	lSel:=.F.
	
	For nI := 1 To Len(aRecnoSM0)
		
		DbSelectArea("SM0")
		DbGotop()
		SM0->(dbGoto(aRecnoSM0[nI,9]))
		
		If !aRecnoSM0[nI,1] .OR. SM0->M0_CODIGO == cCodigo   // Se for o mesmo Grupo Empresa nao e necessario rodar novamente
			loop
		Endif
		lSel:=.T.
		
		RpcSetType(2)
		RpcSetEnv(  SM0->M0_CODIGO, FWGETCODFILIAL)
		cCodigo := SM0->M0_CODIGO
		nModulo := 33 // modulo SIGAPLS
		lMsFinalAuto := .F.
		cTexto += Replicate("-",128)+CHR(13)+CHR(10)
		cTexto += "Grupo Empresa: " + aRecnoSM0[nI][2] + CHR(13) + CHR(10)
		
		ProcRegua(8)
		
		IncProc("Analisando Arquivo de Indice...")
		ProcessMessage()
		cTexto += PLSAtuSIX()
		
		IncProc("Analisando Arquivo de Perguntas...")
		ProcessMessage()
		cTexto += PLSAtuSX1()

		IncProc("Analisando Arquivo de Tabelas...")
		ProcessMessage()
		cTexto += PLSAtuSX2()
		
		IncProc("Analisando Arquivo de Campos...")
		ProcessMessage()
		cTexto += PLSAtuSX3()
		
		IncProc("Analisando Arquivo de Gatilhos...")
		ProcessMessage()
		cTexto += PLSAtuSX7()
		
		cCodigo := SM0->M0_CODIGO
		__SetX31Mode(.F.)
		
		For nX := 1 To Len(aArqUpd)
			
			IncProc("Atualizando estruturas. Aguarde... ["+aArqUpd[nx]+"]")
			
			ProcessMessage()
			
			If Select(aArqUpd[nx])>0
				dbSelecTArea(aArqUpd[nx])
				dbCloseArea()
			EndIf
			
			X31UpdTable(aArqUpd[nx])
			
			If __GetX31Error()
				Alert(__GetX31Trace())
				Aviso("Atenção!", "Ocorreu um erro desconhecido durante a atualização da tabela: "+ aArqUpd[nx] + ". Verifique a integridade do dicionário e da tabela.",{"Continuar"},2)
				cTexto += "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela: "+aArqUpd[nx] +CHR(13)+CHR(10)
			EndIf
			
			dbSelectArea(aArqUpd[nx])
			
		Next nX
		
		RpcClearEnv()
		
		If !( lOpen := MyOpenSm0Ex() )
			Exit
		EndIf
		
	Next nI
	
	If lOpen
		
		cTexto := "Log da atualização "+CHR(13)+CHR(10)+cTexto
		
		if !lSel
			cTexto+= "Não foram selecionadas nenhuma empresa para Atualização"
		Endif
		
		__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)
		
		DEFINE FONT oFont NAME "Mono AS" SIZE 5,12   //6,15
		
		DEFINE MSDIALOG oDlg TITLE "Atualização concluída." From 3,0 to 340,417 PIXEL
		
		@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
		
		oMemo:bRClicked := {||AllwaysTrue() }
		
		oMemo:oFont:=oFont
		
		DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
		
		DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
		
		ACTIVATE MSDIALOG oDlg CENTER
		
	EndIf
	
EndIf

Return(.T.)     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PlsAtuSIX ³ Autor ³ Microsiga      ³ Data ³ 02/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza SIX                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Compatibilizador PLS                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PlsAtuSIX()

Local cTexto    := ''
Local lSix      := .F.
Local aSix      := {}
Local aEstrut   := {}
Local i         := 0
Local j         := 0
Local cAlias    := ''
Local lDelInd   := .F.

aEstrut:= {"INDICE","ORDEM","CHAVE","DESCRICAO","DESCSPA","DESCENG","PROPRI","F3","NICKNAME","SHOWPESQ"}

aAdd(aSIX,{	"B8U",; //INDICE
	      '1',; //ORDEM
	      'B8U_FILIAL+B8U_CODIGO',; //CHAVE
	      'Cód.Fluxo ANS',; //DESCRICAO 
	      '',; //DESCSPA
	      '',; //DESCENG
	      'S',; //PROPRI
	      '',; //F3
	      '',; //NICKNAME
	      ''}) //SHOWPESQ

aAdd(aSIX,{	"B8V",; //INDICE
	      '1',; //ORDEM
	      'B8V_FILIAL+B8V_CODOPE+B8V_CODIGO+B8V_CODNAT',; //CHAVE
	      'Cód.Operadora + Cód.Fluxo ANS + Cód.Natureza Financ.',; //DESCRICAO 
	      '',; //DESCSPA
	      '',; //DESCENG
	      'S',; //PROPRI
	      '',; //F3
	      '',; //NICKNAME
	      ''}) //SHOWPESQ

/*
aAdd(aSIX,{	"",; //INDICE
	      '',; //ORDEM
	      '',; //CHAVE
	      '',; //DESCRICAO 
	      '',; //DESCSPA
	      '',; //DESCENG
	      'S',; //PROPRI
	      '',; //F3
	      '',; //NICKNAME
	      ''}) //SHOWPESQ

*/

ProcRegua(Len(aSIX))

// Elimina indices da tabela B8U e B8V se existirem
dbSelectArea("SIX")
SIX->(dbSetOrder(1))
SIX->(dbSeek('B8U'))
While !SIX->(eof()) .and. SIX->INDICE <= 'B8V'	
	SIX->(RecLock("SIX",.f.))
	SIX->(dbDelete())
	SIX->(MsUnlock())
	SIX->(DbSkip())		
EndDo

dbSelectArea("SIX")
SIX->(DbSetOrder(1))	
For i:= 1 To Len(aSIX)
	If !Empty(aSIX[i,1])
		If !MsSeek(aSIX[i,1]+aSIX[i,2])
			RecLock("SIX",.T.)
			lDelInd := .F.
		Else
			RecLock("SIX",.F.)
			lDelInd := .T. //Se for alteracao precisa apagar o indice do banco
		EndIf
		
		If PadR(UPPER(AllTrim(CHAVE)),160) != PadR(UPPER(Alltrim(aSIX[i,3])),160)
			aAdd(aArqUpd,aSIX[i,1])
			lSix := .T.
			If !(aSIX[i,1]$cAlias)
				cAlias += aSIX[i,1]+CHR(13)+CHR(10)
			EndIf
			For j:=1 To Len(aSIX[i])
				If FieldPos(aEstrut[j])>0
					FieldPut(FieldPos(aEstrut[j]),aSIX[i,j])
				EndIf
			Next j
			dbCommit()        
			MsUnLock()
			cTexto  += ("Índice " + aSix[i][2] + ": " + aSix[i][1] + " - " + aSix[i][3] + Chr(13) + Chr(10))
			If lDelInd
				TcInternal(60,RetSqlName(aSix[i,1]) + "|" + RetSqlName(aSix[i,1]) + aSix[i,2]) //Exclui sem precisar baixar o TOP
			Endif	
		Else
			MsUnLock()
		Endif
		IncProc("Atualizando índices...")
	EndIf
Next i

If lSix
	cTexto += "Índices atualizados  : " +CHR(13)+CHR(10)+cAlias+CHR(13)+CHR(10)
EndIf

Return(cTexto)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PLSAtuSX1 ³ Autor ³ Geraldo Felix Junior  ³ Data ³ 12/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SX2 - Tabelas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao PLS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLSAtuSX1()
Local aSX1           := {}
Local aEstrut        := {}
Local i              := 0
Local j              := 0
Local lSX1	         := .F.
Local cTexto         := ''
Local cAlias         := ''

 
aEstrut :=  { "X1_GRUPO"	,;
			"X1_ORDEM"  	,;
			"X1_PERGUNT",;
			"X1_PERSPA"   ,;
			"X1_PERENG",;
			"X1_VARIAVL",;
			"X1_TIPO"	,;
			"X1_TAMANHO"	,;
			"X1_DECIMAL"	,;
			"X1_PRESEL"	,;
			"X1_GSC"	,;
			"X1_VALID"	,;
			"X1_VAR01"	,;
			"X1_DEF01"	,;
			"X1_DEFSPA1"	,;
			"X1_DEFENG1"	,;
			"X1_CNT01"	,;
			"X1_VAR02"	,;
			"X1_DEF02"	,;
			"X1_DEFSPA2"	,;
			"X1_DEFENG2"	,;
			"X1_CNT02"	,;
			"X1_VAR03"	,;
			"X1_DEF03"	,;
			"X1_DEFSPA3"	,;
			"X1_DEFENG3"	,;
			"X1_CNT03"	,;
			"X1_VAR04"	,;
			"X1_DEF04"	,;
			"X1_DEFSPA4"	,;
			"X1_DEFENG4"	,;
			"X1_CNT04"	,;
			"X1_VAR05"	,;
			"X1_DEF05"	,;
			"X1_DEFSPA5"	,;
			"X1_DEFENG5"	,;
			"X1_CNT05"	,;
			"X1_F3"	,;
			"X1_PYME"	,;
			"X1_GRPSXG"	,;
			"X1_HELP"	,;
			"X1_PICTURE"	,;
			"X1_IDFIL"} 


aAdd( aSX1, { "PLSDFLCXTR"	,;
			"01"  	,;
			"Trimestre?",;
			"Trimestre?"   ,;
			"Trimestre?",;
			"MV_CH1",;
			"C"	,;
			1	,;
			0	,;
			0	,;
			"G"	,;
			"NaoVazio() .and. Pertence('1234')"	,;
			"MV_PAR01"	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			".PLSDFLCXTR01."	,;
			""	,;
			""} )

aAdd( aSX1, { "PLSDFLCXTR"	,;
			"02"  	,;
			"Ano?",;
			"Ano?"   ,;
			"Ano?",;
			"MV_CH2",;
			"C"	,;
			4	,;
			0	,;
			0	,;
			"G"	,;
			""	,;
			"MV_PAR02"	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			".PLSDFLCXTR02."	,;
			""	,;
			""} )

aAdd( aSX1, { "PLSDAGCNT"	,;
			"01"  	,;
			"Data Referencia?",;
			"Data Referencia?"   ,;
			"Data Referencia?",;
			"MV_CH1",;
			"D"	,;
			8	,;
			0	,;
			0	,;
			"G"	,;
			""	,;
			"MV_PAR01"	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			""	,;
			".PLSDAGCNT01."	,;
			""	,;
			""} )
	
                   
dbSelectArea("SX1")
SX1->(dbSetOrder(1))

If SX1->(dbSeek('PLSDFLCXTR'))
	While !SX1->(Eof()) .and. SX1->X1_GRUPO = 'PLSDFLCXTR'
		SX1->(RecLock("SX1",.f.))
		SX1->(dbDelete())
		SX1->(MsUnlock())
		SX1->(dbSkip())
	EndDo
EndIf	


If SX1->(dbSeek('PLSDAGCNT'))
	While !SX1->(Eof()) .and. SX1->X1_GRUPO = 'PLSDAGCNT'
		SX1->(RecLock("SX1",.f.))
		SX1->(dbDelete())
		SX1->(MsUnlock())
		SX1->(dbSkip())
	EndDo
EndIf	


// Exclusão da segunda pergunta do PlsDInter
If SX1->(dbSeek('PLSDINTER'+Space(len(SX1->X1_GRUPO)-9)+'02',.F.))
	SX1->(RecLock("SX1",.f.))
	SX1->(dbDelete())
	SX1->(MsUnlock())
EndIf

ProcRegua(Len(aSX1))
dbSelectarea("SX1")
SX1->(DbSetOrder(1))
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1])
		If !dbSeek(aSX1[i,3])
			RecLock("SX1",.T.)
		Else
			RecLock("SX1",.F.)
		EndIf
		lSX1	:= .T.
		If !(aSX1[i,1]$cAlias)
			cAlias += aSX1[i,1]+"/"
//			aAdd(aArqUpd,aSX1[i,1])
		EndIf
		For j:=1 To Len(aSX1[i])
			If FieldPos(aEstrut[j])>0 .And. aSX1[i,j] != NIL
				FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
			EndIf
		Next j
		dbCommit()
		MsUnLock()
	EndIf
Next i

If lSX1
	cTexto := 'Foram incluidas as seguintes perguntas: '+cAlias+CHR(13)+CHR(10)
EndIf

Return(cTexto)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PLSAtuSX2 ³ Autor ³ Geraldo Felix Junior  ³ Data ³ 12/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SX2 - Tabelas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao PLS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLSAtuSX2()
Local aSX2           := {}
Local aEstrut        := {}
Local i              := 0
Local j              := 0
Local lSX2	         := .F.
Local cTexto         := ''
Local cAlias         := ''

aEstrut:= { "X2_CHAVE"	,;
			"X2_PATH"  	,;
			"X2_ARQUIVO",;
			"X2_NOME"   ,;
			"X2_NOMESPA",;
			"X2_NOMEENG",;
			"X2_ROTINA"	,;
			"X2_MODO"	,;
			"X2_MODOUN"	,;
			"X2_MODOEMP",;
			"X2_DELET"	,;
			"X2_TTS"	,;
			"X2_UNICO"	,;
			"X2_PYME"}

aAdd( aSX2, { "B8U"	,;
			"\DATA\"  	,;
			"B8U"+cEmpAnt+"0",;
			"DIOPS - FLUXO DE CAIXA        "   ,;
			"DIOPS - FLUXO DE CAIXA        ",;
			"DIOPS - FLUXO DE CAIXA        ",;
			""	,;
			"C"	,;
			"C"	,;
			"C"	,;
			0	,;
			""	,;
			"B8U_FILIAL+B8U_CODIGO"	,;
			"N"} )
     
aAdd( aSX2, { "B8V"	,;
			"\DATA\"  	,;
			"B8V"+cEmpAnt+"0",;
			"DIOPS FLUXO DE CX X NATUREZA  "   ,;
			"DIOPS FLUXO DE CX X NATUREZA  ",;
			"DIOPS FLUXO DE CX X NATUREZA  ",;
			""	,;
			"C"	,;
			"C"	,;
			"C"	,;
			0	,;
			""	,;
			"B8V_FILIAL+B8V_CODOPE+B8V_CODIGO+B8V_CODNAT"	,;
			"N"} )

                         
dbSelectArea("SX2")
SX2->(dbSetOrder(1))

If SX2->(dbSeek('B8U'))
	SX2->(RecLock("SX2",.f.))
	SX2->( dbDelete())
	SX2->(MsUnlock())
EndIf	
If SX2->(dbSeek('B8V'))
	SX2->(RecLock("SX2",.f.))
	SX2->( dbDelete())
	SX2->(MsUnlock())
EndIf	

ProcRegua(Len(aSX2))

dbSelectarea("SX2")
SX2->(DbSetOrder(1))
For i:= 1 To Len(aSX2)
	If !Empty(aSX2[i][1])
		If !dbSeek(aSX2[i,3])
			RecLock("SX2",.T.)
		Else
			RecLock("SX2",.F.)
		EndIf
		lSX2	:= .T.
		If !(aSX2[i,1]$cAlias)
			cAlias += aSX2[i,1]+"/"
			aAdd(aArqUpd,aSX2[i,1])
		EndIf
		For j:=1 To Len(aSX2[i])
			If FieldPos(aEstrut[j])>0 .And. aSX2[i,j] != NIL
				FieldPut(FieldPos(aEstrut[j]),aSX2[i,j])
			EndIf
		Next j
		dbCommit()
		MsUnLock()
	EndIf
Next i

If lSX2
	cTexto := 'Foi includa a seguintes tabela : '+cAlias+CHR(13)+CHR(10)
EndIf

Return(cTexto)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PlsAtuSX3 ³ Autor ³ Microsiga		        ³ Data ³ 11/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza SX3                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Compatibilizador PLS                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PlsAtuSX3()  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSX3          := {}
Local ni            := 0
Local nj            := 0
Local lSX3	        := .F.
Local cTexto        := ""
Local cAlias        := ""
local cField		:= ""
Local cOrdem		:= "00"
Local cUsado		:= ""
Local cReserv		:= "" 
Local nNivel		:= 0

Local aEstrut := { 	"X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL",;
					"X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,"X3_DESCRIC","X3_DESCSPA","X3_DESCENG",;
					"X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
					"X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER","X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,;
					"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER","X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG",;
					"X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,"X3_GRPSXG" ,"X3_FOLDER" , "X3_PYME"}

DbSelectarea("SX3")
SX3->(DbSetOrder(2))
// Pesquisa um campo existente para gravar o Reserv e o Usado
If SX3->(MsSeek("BA1_CODEMP")) // Este campo nao eh obrigatorio e permite alterar
	For nI := 1 To SX3->(FCount())
		If "X3_RESERV" $ SX3->(FieldName(nI))
			cReserv := "þA"//SX3->(FieldGet(FieldPos(FieldName(nI))))
		EndIf
		If "X3_USADO"  $ SX3->(FieldName(nI))
			cUsado  := SX3->(FieldGet(FieldPos(FieldName(nI))))
		EndIf
		If "X3_NIVEL"  $ SX3->(FieldName(nI))
			nNivel  := SX3->(FieldGet(FieldPos(FieldName(nI))))
		EndIf
	Next
EndIf    

SX3->(DbSetOrder(1))
If SX3->(dbSeek('B8U',.F.))
	While !SX3->(Eof()) .and. SX3->X3_ARQUIVO <= 'B8V'
		SX3->(RecLock("SX3",.f.))
		SX3->(dbDelete())
		SX3->(MsUnlock())
		SX3->(dbSkip())
	EndDo
EndIf	

cOrdem := Soma1(cOrdem)
aAdd(aSX3,{	"B8U",;								// Arquivo
			cOrdem,;							// Ordem
			"B8U_FILIAL",;						// Campo
			"C",;								// Tipo
			2,;			// Tamanho
			0,;									// Decimal
			"Filial",;			     	// Titulo
			"Sucursal",;    				   			// Titulo SPA
			"Branch",;    			  				// Titulo ENG
			"Filial do Sistema",;	   	// Descricao
			"Sucursal",;        						// Descricao SPA
			"Branch",;	        					// Descricao ENG
			"@!",;								// Picture
			"",;                    			// Valid
			cUsado,;							// Usado
			"",;                                // Relacao
			"",;    					  		// F3
			nNivel,;		 				   	// Nivel
			cReserv,;	   	 					// Reserv
			"",;								// Check
			"",;								// Trigger
			"S",;								// Propri
			"N",;								// Browse
			"V",;								// Visual
			"R",;								// Context
			"",;								// Obrigat
			"",;								// VldUser
			"",;						// CBox
			"",;								// CBox SPA
			"",;								// CBox ENG
			"",;							    // PictVar
			"",;								// When
			"",;								// IniBrw
			"033",;								// SXG
			"",;				   				// Folder
			"N",;                        		// PYME
			{""}})   	// HELP

cOrdem := Soma1(cOrdem)
aAdd(aSX3,{	"B8U",;							// Arquivo
			cOrdem,;							// Ordem
			"B8U_CODIGO",;						// Campo
			"C",;								// Tipo
			3,;							// Tamanho
			0,;								// Decimal
			"Código ANS",;			     	// Titulo
			" ",;    				   			// Titulo SPA
			"",;    			  				// Titulo ENG
			"Código ANS",;	   	// Descricao
			"",;        						// Descricao SPA
			"",;	        					// Descricao ENG
			"@!",;								// Picture
			"ExistChav('B8U',M->B8U_CODIGO,1)",;                    			// Valid
			cUsado,;							// Usado
			"",;                                // Relacao
			"",;    					  		// F3
			nNivel,;		 				   	// Nivel
			cReserv,;	   	 					// Reserv
			"",;								// Check
			"",;								// Trigger
			"S",;								// Propri
			"S",;								// Browse
			"A",;								// Visual
			"R",;								// Context
			"",;								// Obrigat
			"",;								// VldUser
			"",;						// CBox
			"",;								// CBox SPA
			"",;								// CBox ENG
			"",;							    // PictVar
			"",;								// When
			"",;								// IniBrw
			"",;								// SXG
			"",;				   				// Folder
			"N",;                        		// PYME
			{""}})   	// HELP

cOrdem := Soma1(cOrdem)
aAdd(aSX3,{	"B8U",;							// Arquivo
			cOrdem,;							// Ordem
			"B8U_DESC",;						// Campo
			"C",;								// Tipo
			80,;							// Tamanho
			0,;								// Decimal
			"Descrição",;			     	// Titulo
			" ",;    				   			// Titulo SPA
			"",;    			  				// Titulo ENG
			"Descrição",;	   	// Descricao
			"",;        						// Descricao SPA
			"",;	        					// Descricao ENG
			"@!",;								// Picture
			"",;                    			// Valid
			cUsado,;							// Usado
			"",;                                // Relacao
			"",;    					  		// F3
			nNivel,;		 				   	// Nivel
			cReserv,;	   	 					// Reserv
			"",;								// Check
			"",;								// Trigger
			"S",;								// Propri
			"S",;								// Browse
			"A",;								// Visual
			"R",;								// Context
			"",;								// Obrigat
			"",;								// VldUser
			"",;						// CBox
			"",;								// CBox SPA
			"",;								// CBox ENG
			"",;							    // PictVar
			"",;								// When
			"",;								// IniBrw
			"",;								// SXG
			"",;				   				// Folder
			"N",;                        		// PYME
			{""}})   	// HELP

cOrdem := "01"
aAdd(aSX3,{	"B8V",;							// Arquivo
			cOrdem,;							// Ordem
			"B8V_FILIAL",;						// Campo
			"C",;								// Tipo
			2,;			// Tamanho
			0,;									// Decimal
			"Filial",;			     	// Titulo
			"Sucursal",;    				   			// Titulo SPA
			"Branch",;    			  				// Titulo ENG
			"Filial do Sistema",;	   	// Descricao
			"Sucursal",;        						// Descricao SPA
			"Branch",;	        					// Descricao ENG
			"@!",;								// Picture
			"",;                    			// Valid
			cUsado,;							// Usado
			"",;                                // Relacao
			"",;    					  		// F3
			nNivel,;		 				   	// Nivel
			cReserv,;	   	 					// Reserv
			"",;								// Check
			"",;								// Trigger
			"S",;								// Propri
			"N",;								// Browse
			"V",;								// Visual
			"R",;								// Context
			"",;								// Obrigat
			"",;								// VldUser
			"",;						// CBox
			"",;								// CBox SPA
			"",;								// CBox ENG
			"",;							    // PictVar
			"",;								// When
			"",;								// IniBrw
			"033",;								// SXG
			"",;				   				// Folder
			"N",;                        		// PYME
			{""}})   	// HELP

cOrdem := Soma1(cOrdem)
aAdd(aSX3,{	"B8V",;							// Arquivo
			cOrdem,;							// Ordem
			"B8V_CODOPE",;						// Campo
			"C",;								// Tipo
			4,;							// Tamanho
			0,;								// Decimal
			"Operadora",;			     	// Titulo
			" ",;    				   			// Titulo SPA
			"",;    			  				// Titulo ENG
			"Operadora",;	   	// Descricao
			"",;        						// Descricao SPA
			"",;	        					// Descricao ENG
			"@!",;								// Picture
			"",;                    			// Valid
			cUsado,;							// Usado
			"PlsIntPad()",;                                // Relacao
			"BA0",;    					  		// F3
			nNivel,;		 				   	// Nivel
			cReserv,;	   	 					// Reserv
			"",;								// Check
			"",;								// Trigger
			"S",;								// Propri
			"S",;								// Browse
			"V",;								// Visual
			"R",;								// Context
			"",;								// Obrigat
			"",;								// VldUser
			"",;						// CBox
			"",;								// CBox SPA
			"",;								// CBox ENG
			"",;							    // PictVar
			"",;								// When
			"",;								// IniBrw
			"",;								// SXG
			"",;				   				// Folder
			"N",;                        		// PYME
			{""}})   	// HELP

cOrdem := Soma1(cOrdem)
aAdd(aSX3,{	"B8V",;							// Arquivo
			cOrdem,;							// Ordem
			"B8V_CODIGO",;						// Campo
			"C",;								// Tipo
			3,;							// Tamanho
			0,;								// Decimal
			"Código ANS",;			     	// Titulo
			" ",;    				   			// Titulo SPA
			"",;    			  				// Titulo ENG
			"Código ANS",;	   	// Descricao
			"",;        						// Descricao SPA
			"",;	        					// Descricao ENG
			"@!",;								// Picture
			"",;                    			// Valid
			cUsado,;							// Usado
			"B8U->B8U_CODIGO",;                                // Relacao
			"",;    					  		// F3
			nNivel,;		 				   	// Nivel
			cReserv,;	   	 					// Reserv
			"",;								// Check
			"",;								// Trigger
			"S",;								// Propri
			"S",;								// Browse
			"V",;								// Visual
			"R",;								// Context
			"",;								// Obrigat
			"",;								// VldUser
			"",;						// CBox
			"",;								// CBox SPA
			"",;								// CBox ENG
			"",;							    // PictVar
			"",;								// When
			"",;								// IniBrw
			"",;								// SXG
			"",;				   				// Folder
			"N",;                        		// PYME
			{""}})   	// HELP

cOrdem := Soma1(cOrdem)
aAdd(aSX3,{	"B8V",;							// Arquivo
			cOrdem,;							// Ordem
			"B8V_DESC",;						// Campo
			"C",;								// Tipo
			80,;							// Tamanho
			0,;								// Decimal
			"Descrição",;			     	// Titulo
			" ",;    				   			// Titulo SPA
			"",;    			  				// Titulo ENG
			"Descrição",;	   	// Descricao
			"",;        						// Descricao SPA
			"",;	        					// Descricao ENG
			"@!",;								// Picture
			"",;                    			// Valid
			cUsado,;							// Usado
			"B8U->B8U_DESC",;                                // Relacao
			"",;    					  		// F3
			nNivel,;		 				   	// Nivel
			cReserv,;	   	 					// Reserv
			"",;								// Check
			"",;								// Trigger
			"S",;								// Propri
			"S",;								// Browse
			"A",;								// Visual
			"V",;								// Context
			"",;								// Obrigat
			"",;								// VldUser
			"",;						// CBox
			"",;								// CBox SPA
			"",;								// CBox ENG
			"",;							    // PictVar
			"",;								// When
			"",;								// IniBrw
			"",;								// SXG
			"",;				   				// Folder
			"N",;                        		// PYME
			{""}})   	// HELP


cOrdem := Soma1(cOrdem)
aAdd(aSX3,{	"B8V",;							// Arquivo
			cOrdem,;							// Ordem
			"B8V_CODNAT",;						// Campo
			"C",;								// Tipo
			10,;							// Tamanho
			0,;								// Decimal
			"Cód.Natureza",;			     	// Titulo
			" ",;    				   			// Titulo SPA
			"",;    			  				// Titulo ENG
			"Cód.Natureza",;	   	// Descricao
			"",;        						// Descricao SPA
			"",;	        					// Descricao ENG
			"@!",;								// Picture
			"ExistChav('B8V',B8U->B8U_CODIGO+M->B8V_CODNAT,1) .and. ExistCpo('SED',M->B8V_CODNAT,1)",;                    			// Valid
			cUsado,;							// Usado
			"",;                                // Relacao
			"SED",;    					  		// F3
			nNivel,;		 				   	// Nivel
			cReserv,;	   	 					// Reserv
			"",;								// Check
			"S",;								// Trigger
			"S",;								// Propri
			"S",;								// Browse
			"A",;								// Visual
			"R",;								// Context
			"",;								// Obrigat
			"",;								// VldUser
			"",;						// CBox
			"",;								// CBox SPA
			"",;								// CBox ENG
			"",;							    // PictVar
			"",;								// When
			"",;								// IniBrw
			"",;								// SXG
			"",;				   				// Folder
			"N",;                        		// PYME
			{""} })   	// HELP
			
cOrdem := Soma1(cOrdem)
aAdd(aSX3,{	"B8V",;							// Arquivo
			cOrdem,;							// Ordem
			"B8V_DESCNT",;						// Campo
			"C",;								// Tipo
			30,;							// Tamanho
			0,;								// Decimal
			"Desc.Naturez",;			     	// Titulo
			" ",;    				   			// Titulo SPA
			"",;    			  				// Titulo ENG
			"Desc.Naturez",;	   	// Descricao
			"",;        						// Descricao SPA
			"",;	        					// Descricao ENG
			"@!",;								// Picture
			"",;                    			// Valid
			cUsado,;							// Usado
			"IIF(INCLUI,'',POSICIONE('SED',1,XFILIAL('SED')+B8V->B8V_CODNAT, 'ED_DESCRIC'))",;                                // Relacao
			"",;    					  		// F3
			nNivel,;		 				   	// Nivel
			cReserv,;	   	 					// Reserv
			"",;								// Check
			"",;								// Trigger
			"S",;								// Propri
			"S",;								// Browse
			"V",;								// Visual
			"V",;								// Context
			"",;								// Obrigat
			"",;								// VldUser
			"",;						// CBox
			"",;								// CBox SPA
			"",;								// CBox ENG
			"",;							    // PictVar
			"",;								// When
			"",;								// IniBrw
			"",;								// SXG
			"",;				   				// Folder
			"N",;                        		// PYME
			{""}})   	// HELP

SX3->(DbSetOrder(1))
cOrdem := '01'
If SX3->(dbSeek('BT5'+cOrdem,.F.))
	While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == 'BT5'
		cOrdem := SX3->X3_ORDEM
		SX3->(dbSkip())
	EndDo
EndIf	

cOrdem := Soma1(cOrdem)
aAdd(aSX3,{	"BT5",;								// Arquivo
			cOrdem,;							// Ordem
			"BT5_SUSEP",;						// Campo
			"C",;								// Tipo
			6,;			// Tamanho
			0,;									// Decimal
			"Num Reg ANS ",;			     	// Titulo
			"Num Reg ANS ",;    				   			// Titulo SPA
			"Num Reg ANS ",;    			  				// Titulo ENG
			"Numero Registro ANS      ",;	   	// Descricao
			"Numero Registro ANS      ",;        						// Descricao SPA
			"Numero Registro ANS      ",;	        					// Descricao ENG
			"999999",;								// Picture
			"",;                    			// Valid
			cUsado,;							// Usado
			"",;                                // Relacao
			"",;    					  		// F3
			nNivel,;		 				   	// Nivel
			cReserv,;	   	 					// Reserv
			"",;								// Check
			"",;								// Trigger
			"S",;								// Propri
			"N",;								// Browse
			"A",;								// Visual
			"R",;								// Context
			"",;								// Obrigat
			"",;								// VldUser
			"",;								// CBox
			"",;								// CBox SPA
			"",;								// CBox ENG
			"",;							    // PictVar
			"(Inclui.or.Altera).and. M->BT5_ALLOPE=='1'",;			// When
			"",;								// IniBrw
			"",;								// SXG
			"3",;				   				// Folder
			"N",;                        		// PYME
			{""}})   	// HELP

cOrdem := Soma1(cOrdem)
aAdd(aSX3,{	"BT5",;								// Arquivo
			cOrdem,;							// Ordem
			"BT5_AGR309",;						// Campo
			"C",;								// Tipo
			1,;			// Tamanho
			0,;									// Decimal
			"Agr.Pool Risco?",;			     	// Titulo
			"Agr.Pool Risco?",;    				   			// Titulo SPA
			"Agr.Pool Risco?",;    			  				// Titulo ENG
			"Agregado ao Pool de Risco",;	   	// Descricao
			"Agregado ao Pool de Risco",;        						// Descricao SPA
			"Agregado ao Pool de Risco",;	        					// Descricao ENG
			"9",;								// Picture
			"Pertence('01')",;                    			// Valid
			cUsado,;							// Usado
			"",;                                // Relacao
			"",;    					  		// F3
			nNivel,;		 				   	// Nivel
			cReserv,;	   	 					// Reserv
			"",;								// Check
			"",;								// Trigger
			"S",;								// Propri
			"N",;								// Browse
			"A",;								// Visual
			"R",;								// Context
			"",;								// Obrigat
			"",;								// VldUser
			"0=Não;1=Sim",;								// CBox
			"",;								// CBox SPA
			"",;								// CBox ENG
			"",;							    // PictVar
			"M->BT5_INFANS=='1'",;			// When
			"",;								// IniBrw
			"",;								// SXG
			"1",;				   				// Folder
			"N",;                        		// PYME
			{""}})   	// HELP

			
cTexto += 'Foram incluídos campos na tabela B8U com sucesso' + CHR(13) + CHR(10)

cTexto += 'Foram incluídos campos na tabela B8V com sucesso' + CHR(13) + CHR(10)

cTexto += 'Foram incluídos campos na tabela BT5 com sucesso' + CHR(13) + CHR(10)


ProcRegua(Len(aSX3))
SX3->(DbSetOrder(2))
dBSelectArea("SX3")
For nI:= 1 To Len(aSX3)
		
	If !Empty(aSX3[nI][1])
		If !dbSeek(aSX3[nI,3])
			recLock("SX3",.T.)
		Else
			recLock("SX3",.F.)
		EndIf
		lSX3	:= .T.
		If !(aSX3[nI,1]$cAlias)
			cAlias += CHR(13)+CHR(10)+aSX3[nI,1]+CHR(13)+CHR(10)
			aAdd(aArqUpd,aSX3[nI,1])
		EndIf
		For nJ:=1 To Len(aSX3[nI])
			If nJ < 37
				If FieldPos(aEstrut[nJ])>0 .And. aSX3[nI,nJ] != Nil
					FieldPut(FieldPos(aEstrut[nJ]),aSX3[nI,nJ])
				EndIf
				If aEstrut[nJ] == "L_DELETED"
					If Len(aSX3[nI]) == nJ .and. aSX3[nI,nJ] != Nil .and. aSX3[nI,nJ] == .T.
						DbDelete()
					Endif
				Endif
			Else
				PutHelp("P"+aSX3[nI,3],aSX3[nI,37],aSX3[nI,37],aSX3[nI,37],.T.)
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
		IncProc("Atualizando Dicionário de Dados...")
	EndIf
next nI

Return(cTexto)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PlsAtuSX7 ³ Autor ³ Microsiga      ³ Data ³ 02/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza SX7                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Compatibilizador PLS                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PlsAtuSX7()

Local cTexto    := ''
Local lSX7      := .F.
Local aSX7      := {}
Local aEstrut   := {}
Local i         := 0
Local j         := 0
Local cAlias    := ''
Local lDelInd   := .F.

aEstrut:= {"X7_CAMPO","X7_SEQUENC","X7_REGRA","X7_CDOMIN","X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_CONDIC","X7_PROPRI"}

aAdd(aSX7,{ "B8V_CODNAT",;
			"001",;
			"SED->ED_DESCRIC",;
			"B8V_DESCNT",;
			"P",;
			"S",;
			"SED",;
			1,;
			"xFilial('SED')+M->B8V_CODNAT",;
			"",;
			"S" } )

ProcRegua(Len(aSX7))

// Elimina registro se existir
dbSelectArea("SX7")
SX7->(dbSetOrder(1))
If SX7->(dbSeek('B8V_CODNAT001'))
	SX7->(RecLock("SX7",.f.))
	SX7->(dbDelete())
	SX7->(MsUnlock())
	SX7->(DbSkip())		
EndIf

dbSelectArea("SX7")
SX7->(DbSetOrder(1))	
For i:= 1 To Len(aSX7)
	If !Empty(aSX7[i,1])
		RecLock('SX7', .T.)
		For j:=1 To Len(aSX7[i])
			If FieldPos(aEstrut[j])>0
				FieldPut(FieldPos(aEstrut[j]),aSX7[i,j])
			EndIf
		Next j
		MsUnLock()
		cTexto  += ("Gatilho criado " + aSX7[i][2] + ": " + aSX7[i][1] + " - " + aSX7[i][3] + Chr(13) + Chr(10))
	Endif
	IncProc("Atualizando Gatilhos...")
Next i

If lSX7
	cTexto += "Gatilhos atualizados: " +CHR(13)+CHR(10)+cAlias+CHR(13)+CHR(10)
EndIf

Return(cTexto)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MyOpenSM0Ex³ Autor ³Sergio Silveira       ³ Data ³07/01/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a abertura do SM0 exclusivo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao PLS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MyOpenSM0Ex()
LOCAL lOpen 	:= .F.
LOCAL nLoop 	:= 0

For nLoop := 1 To 20
	dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .F., .F. )
	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex("SIGAMAT.IND")
		Exit
	EndIf
	Sleep( 500 )
Next nLoop

If !lOpen
	Aviso("Atenção !", "Não foi possível a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 )
EndIf

Return( lOpen )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ UpdEmp   ³ Autor ³ Luciano Aparecido     ³ Data ³ 15.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Trata Empresa. Verifica as Empresas para Atualizar         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao PLS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function UpdEmp( aRecnoSM0 , lOpen )

Local cVar		:= Nil
Local oDlg		:= Nil
Local cTitulo	:= "Escolha a(s) Empresa(s) que será(ão) Atualizada(s)"
Local lMark		:= .F.
Local oOk		:= LoadBitmap( GetResources() , "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources() , "UNCHECKED" ) //UNCHECKED  //LBNO
Local oChk		:= Nil
Local bCode		:= {|| oDlg:End() , Processa( {|lEnd| PLSProc( @lEnd , aRecnoSM0 , lOpen ) } , STR0008 , STR0009 , .F. ) }
Local nI		:=0
Local aRecSM0	:={}

Private lChk	:= .F.
Private oLbx	:= Nil


If ( lOpen := MyOpenSm0Ex() )
	
	dbSelectArea("SM0")
	dbGotop()
	
	aRecSM0:=FWLoadSM0()
	
	For nI := 1 to  len(aRecSM0)
		Aadd(aRecnoSM0,{lMark,aRecSM0[nI][1],aRecSM0[nI][6],aRecSM0[nI][2],aRecSM0[nI][3],aRecSM0[nI][4],aRecSM0[nI][5],aRecSM0[nI][7],aRecSM0[nI][12]})
	Next nI
	
	If Len( aRecnoSM0 ) == 0
		Aviso( cTitulo, "Não existem bancos a consultar...", {"Ok"} )
		Return()
	Endif
	
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,700 PIXEL
	
	@ 10,10	LISTBOX oLbx VAR cVar FIELDS HEADER " ","Grupo Emp","Descricao", "Codigo","Empresa","Unidade","Filial","Descricao","Recno" SIZE 430,095 OF oDlg PIXEL ;
	ON dblClick( aRecnoSM0[oLbx:nAt,1] := !aRecnoSM0[oLbx:nAt,1] , oLbx:Refresh() )
	
	oLbx:SetArray( aRecnoSM0 )
	oLbx:bLine := {|| {Iif(	aRecnoSM0[oLbx:nAt,1],oOk,oNo)			,;
	aRecnoSM0[oLbx:nAt,2]					,;
	aRecnoSM0[oLbx:nAt,3]					,;
	aRecnoSM0[oLbx:nAt,4]					,;
	aRecnoSM0[oLbx:nAt,5]					,;
	aRecnoSM0[oLbx:nAt,6]					,;
	aRecnoSM0[oLbx:nAt,7]					,;
	aRecnoSM0[oLbx:nAt,8]					,;
	Alltrim(Str(aRecnoSM0[oLbx:nAt,9]))	}}
	
	@ 110,10 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 60,007 PIXEL OF oDlg ON CLICK( aEval( aRecnoSM0 , {|x| x[1] := lChk } ) , oLbx:Refresh() )
	
	DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION Eval(bCode) ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTER
	
Endif

Return()