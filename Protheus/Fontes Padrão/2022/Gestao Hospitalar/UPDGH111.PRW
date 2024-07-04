#INCLUDE "protheus.ch"                                                                                    
#INCLUDE "UPDGHPAD.ch"
#INCLUDE "TOPCONN.CH"
         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ UPDGH111  ³ Autor ³ Saude                 ³ Data ³ 24/07/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualizacao das tabelas do PLS   				           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Plano de Saude, RDC                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function UPDGH111()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nOpca			:= 0
Local aSays			:= {}, aButtons := {}
Local aRecnoSM0		:= {}
Local lOpen     	:= .F.
Private nModulo 	:= 51 // modulo SIGAPLS
Private cMessage
Private aArqUpd		:= {}
Private aREOPEN		:= {}
Private oMainWnd
Private cCadastro	:= STR0001 // "Compatibilizador de Dicionários x Banco de dados"
Private cCompat		:= "UPDGH111"
Private cFnc		:= ""
Private cRef		:= "Controle de Visualização de Anamnese e Procedimento da Promoção "
Set Dele On
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta texto para janela de processamento                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aSays,STR0002)  //"Esta rotina irá efetuar a compatibilização dos dicionários e banco de dados,"
aadd(aSays,STR0003)//"e demais ajustes referentes a FNC abaixo:"
aadd(aSays,"   Requisito: " + cFnc)
aadd(aSays,STR0004 + cRef)  //"   Referência: "
aadd(aSays," ")
aadd(aSays, STR0005)   //"Atenção: efetuar backup dos dicionários e do banco de dados previamente "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botoes para janela de processamento                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aButtons, { 1,.T.,{|| nOpca := 1, FechaBatch() }} )
aadd(aButtons, { 2,.T.,{|| nOpca := 0, FechaBatch() }} )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe janela de processamento                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FormBatch( cCadastro, aSays, aButtons,, 230 )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa calculo                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nOpca == 1
	If  Aviso(STR0006, STR0007, {STR0041,STR0042}) == 1 // "Sim" ### "Não"
		Processa({||UpdEmp(aRecnoSM0,lOpen)},STR0008,STR0009,.F.)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do programa                                                            |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o    ³ProcATU   ³ Autor ³                       ³ Data ³  /  /    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Funcao de processamento da gravacao dos arquivos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Baseado na funcao criada por Eduardo Riera em 01/02/2002   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ProcATU(lEnd,aRecnoSM0,lOpen)
Local cTexto    	:= ""
Local cFile     	:= ""
Local cMask     	:= STR0043 + " (*.TXT) |*.txt|" // "Arquivos Texto"
Local nRecno    	:= 0
Local nI        	:= 0
Local nX        	:= 0
Local cCodigo		:= ""


ProcRegua(1)
IncProc(STR0010)//"Verificando integridade dos dicionários...."

If lOpen

	lSel:=.F.
	For nI := 1 To Len(aRecnoSM0)
		DbSelectArea("SM0")
		DbGotop()
		SM0->(dbGoto(aRecnoSM0[nI,9]))

		If !aRecnoSM0[nI,1]
			loop
		Endif
		lSel:=.T.

		RpcSetType(2)
		RpcSetEnv(  SM0->M0_CODIGO, SM0->M0_CODFIL)

		nModulo := 51 // modulo SIGAHSP
		lMsFinalAuto := .F.
		cTexto += Replicate("-",128)+CHR(13)+CHR(10)
		cTexto += STR0025 + aRecnoSM0[nI][2]//"Grupo Empresa: "

		ProcRegua(8)


		If  SM0->M0_CODIGO <> cCodigo   //Só irá executar manutenção no SX se For Grupo Empresas Diferentes
			
			conout( "Funções descontinuadas pelo SGBD: GeraSX3()" )


			cCodigo := SM0->M0_CODIGO
		Endif

		__SetX31Mode(.F.)
		For nX := 1 To Len(aArqUpd)
			IncProc(STR0016 +"["+aArqUpd[nx]+"]")
			If Select(aArqUpd[nx])>0
				dbSelecTArea(aArqUpd[nx])
				dbCloseArea()
			EndIf
			X31UpdTable(aArqUpd[nx])
			If __GetX31Error()
				Alert(__GetX31Trace())
				Aviso(STR0017,STR0019 + aArqUpd[nx] + STR0018 ,{STR0030},2) //"Atencao!","Ocorreu um erro desconhecido durante a atualizacao da tabela : " //". Verifique a integridade do dicionario e da tabela."  // "Continuar"
				cTexto += STR0019 +aArqUpd[nx] +CHR(13)+CHR(10) //"Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : "
			EndIf
			dbSelectArea(aArqUpd[nx])
		Next nX

		RpcClearEnv()
		If !( lOpen := MyOpenSm0Ex() )
			Exit
		EndIf
	Next nI

	If lOpen

		cTexto 				:= STR0020 + CHR(13) + CHR(10) + cTexto //"Log da atualizacao "

		If !lSel
			cTexto+= STR0026//"Não foram selecionadas nenhuma empresa para Atualização"
		Endif
		__cFileLog := MemoWrite(Criatrab(,.f.) + ".LOG", cTexto)

		DEFINE FONT oFont NAME "Mono AS" SIZE 5,12
		DEFINE MSDIALOG oDlg TITLE STR0021+" ["+cFnc+"]"+ STR0022  From 3,0 to 340,417 PIXEL  //"Atualizador   Atualizacao concluida."
		@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont
		DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
		DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
		ACTIVATE MSDIALOG oDlg CENTER

	EndIf

EndIf
Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o    ³MyOpenSM0Ex³ Autor ³Sergio Silveira       ³ Data ³07/01/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Efetua a abertura do SM0 exclusivo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao FIS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MyOpenSM0Ex()

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	openSM0( cNumEmp,.F. )
	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex("SIGAMAT.IND")
		Exit
	EndIf
	Sleep( 500 )
Next nLoop

If !lOpen
	Aviso( STR0017, STR0023, { "Ok" }, 2 ) //Atenção , "Nao foi possivel a abertura da tabela de empresas de forma exclusiva !"
EndIf

Return( lOpen )




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o    ³ UpdEmp   ³ Autor ³ Luciano Aparecido     ³ Data ³ 15.05.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Trata Empresa. Verifica as Empresas para Atualizar         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao PLS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

static function  UpdEmp(aRecnoSM0,lOpen)

	Local cVar     := Nil
	Local oDlg     := Nil
	Local cTitulo  := STR0027  //"Escolha a(s) Empresa(s) que será(ão) Atualizada(s)"
	Local lMark    := .F.
	Local oOk      := LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
	Local oNo      := LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
	Local oChk     := Nil
	Local bCode := {||oDlg:End(),Processa({|lEnd| ProcATU(@lEnd,aRecnoSM0,lOpen)},STR0008,STR0009,.F.)} //"Processando","Aguarde, processando preparação dos arquivos"
	Local nI :=0
	Local aRecSM0 :={}

	Private lChk     := .F.
	Private oLbx := Nil


	If ( lOpen := MyOpenSm0Ex() )
		dbSelectArea("SM0")


/////////////////////////////////////////
//| Carrega o vetor conforme a condicao |/
//////////////////////////////////////////
		dbGotop()

		aRecSM0:=FWLoadSM0()


		For nI := 1 to  len(aRecSM0)
			Aadd(aRecnoSM0,{lMark,aRecSM0[nI][1],aRecSM0[nI][6],aRecSM0[nI][2],aRecSM0[nI][3],aRecSM0[nI][4],aRecSM0[nI][5],aRecSM0[nI][7],aRecSM0[nI][12]})
		Next nI

///////////////////////////////////////////////////
//| Monta a tela para usuario visualizar consulta |
///////////////////////////////////////////////////
		If Len( aRecnoSM0 ) == 0
			Aviso( cTitulo, STR0028, {"Ok"} ) //"Nao existe bancos a consultar"
			Return
		Endif

		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,700 PIXEL

		@ 10,10 LISTBOX oLbx VAR cVar FIELDS HEADER ;
			" ","Grupo Emp","Descricao", "Codigo","Empresa","Unidade","Filial","Descricao","Recno" ;
			SIZE 335,095 OF oDlg PIXEL ON dblClick(aRecnoSM0[oLbx:nAt,1] := !aRecnoSM0[oLbx:nAt,1],oLbx:Refresh())

		oLbx:SetArray( aRecnoSM0)
		oLbx:bLine := {|| {Iif(aRecnoSM0[oLbx:nAt,1],oOk,oNo),;
			aRecnoSM0[oLbx:nAt,2],;
			aRecnoSM0[oLbx:nAt,3],;
			aRecnoSM0[oLbx:nAt,4],;
			aRecnoSM0[oLbx:nAt,5],;
			aRecnoSM0[oLbx:nAt,6],;
			aRecnoSM0[oLbx:nAt,7],;
			aRecnoSM0[oLbx:nAt,8],;
			Alltrim(Str(aRecnoSM0[oLbx:nAt,9]))}}

////////////////////////////////////////////////////////////////////
//| Para marcar e desmarcar todos existem duas opçoes, acompanhe...
////////////////////////////////////////////////////////////////////


		@ 110,10 CHECKBOX oChk VAR lChk PROMPT  STR0029 SIZE 60,007 PIXEL OF oDlg ; //"Marca/Desmarca"
		ON CLICK(aEval(aRecnoSM0,{|x| x[1]:=lChk}),oLbx:Refresh())

		DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION Eval(bCode) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTER
	Endif

	Return



