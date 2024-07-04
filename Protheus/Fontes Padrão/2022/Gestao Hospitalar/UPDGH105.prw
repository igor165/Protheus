#Include "PROTHEUS.CH"
#Include "UPDGHPAD.CH"

#DEFINE RESERV Chr(128) + Chr(128)

#DEFINE USADO  Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � UPDGH105  � Autor � TOTVS PLS             � Data � 18/12/13 ���
��������������������������������������������������������������������������Ĵ��
���Descri�ao � 															   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � SigaHSP                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function UPDGH105()

Local nOpca       := 0
Local aSays       := {}, aButtons := {}
Local aRecnoSM0   := {}
Local lOpen       := .F.

Private nModulo   := 51 // modulo SIGAHSP
Private cMessage  := ""
Private aArqUpd	  := {}
Private aREOPEN	  := {}
Private oMainWnd
Private cCadastro := STR0001 //"Compatibilizador de Dicion�rios x Banco de dados"
Private lAtuMsg	  := .F.
Private cFNC      := "THVOGA"
Private cRef      := "Altera��o de campo referente ao cadastro de CBO"

Set Dele On

//����������������������������������������������������������������������������Ŀ
//� Monta texto para janela de processamento                                   �
//������������������������������������������������������������������������������
aadd(aSays,STR0002)				//"Esta rotina ir� efetuar a compatibiliza��o dos dicion�rios e banco de dados,"
aadd(aSays,STR0003)				//"e demais ajustes referentes a FNC abaixo:"
aadd(aSays,"   Chamado: " + cFnc)
aadd(aSays,STR0004 + cRef)		//"   Refer�ncia: "
aadd(aSays," ")
aadd(aSays,STR0005)   			//"Aten��o: efetuar backup dos dicion�rios e do banco de dados previamente "

//����������������������������������������������������������������������������Ŀ
//� Monta botoes para janela de processamento                                  �
//������������������������������������������������������������������������������
aadd(aButtons, { 1,.T.,{|| nOpca := 1, FechaBatch() }} )
aadd(aButtons, { 2,.T.,{|| nOpca := 0, FechaBatch() }} )

//����������������������������������������������������������������������������Ŀ
//� Exibe janela de processamento                                              �
//������������������������������������������������������������������������������
FormBatch( cCadastro , aSays , aButtons ,, 240 )

//����������������������������������������������������������������������������Ŀ
//� Processa                                                                   �
//������������������������������������������������������������������������������
If  nOpca == 1
	If  Aviso(STR0006, STR0007, {"Sim","N�o"}) == 1
          Processa( {|| UpdEmp( aRecnoSM0 , lOpen ) } , STR0008 , STR0009 , .F. ) //"Processando", "Aguarde , processando prepara��o dos arquivos"
    Endif
Endif

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PLSProc  � Autor � Microsiga	            � Data � 07/03/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de processamento da gravacao dos arquivos           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Atualizacao PLS/HSP                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function PLSProc( lEnd , aRecnoSM0 , lOpen )

Local cTexto    := ''
Local cFile     := ""
Local cMask     := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno    := 0
Local nI        := 0
Local nX        := 0
Local lSel      := .T.
Local cCodigo	:= ""

ProcRegua(1)
IncProc("Verificando integridade dos dicion�rios....")
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
 		nModulo := 51 // modulo SIGAHSP
		lMsFinalAuto := .F.
		cTexto += Replicate("-",128)+CHR(13)+CHR(10)
		cTexto += "Grupo Empresa: " + aRecnoSM0[nI][2] + CHR(13) + CHR(10)

		ProcRegua(8)

		IncProc("Analisando Arquivo de Campos...")
		ProcessMessage()

		If lAtuMsg
			PLSAtuMsg()
		Endif

		IncProc("Desabilitando os antigos campos 'MSG'...")
		
		ProcessMessage()
		
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',  "Fun��es descontinuadas pelo SGBD: PLSAtuSX3()"  , 0, 0, {})

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
				Aviso("Aten��o!", "Ocorreu um erro desconhecido durante a atualiza��o da tabela: "+ aArqUpd[nx] + ". Verifique a integridade do dicion�rio e da tabela.",{"Continuar"},2)
				cTexto += "Ocorreu um erro desconhecido durante a atualiza��o da estrutura da tabela: "+aArqUpd[nx] +CHR(13)+CHR(10)
			EndIf

			dbSelectArea(aArqUpd[nx])

		Next nX

		RpcClearEnv()

		If !( lOpen := MyOpenSm0Ex() )
			Exit
		EndIf

	Next nI

	If lOpen

		cTexto := "Log da atualiza��o "+CHR(13)+CHR(10)+cTexto

		if !lSel
			cTexto+= "N�o foram selecionadas nenhuma empresa para Atualiza��o"
		Endif

		__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)

		DEFINE FONT oFont NAME "Mono AS" SIZE 5,12   //6,15

		DEFINE MSDIALOG oDlg TITLE "Atualiza��o conclu�da." From 3,0 to 340,417 PIXEL

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MyOpenSM0Ex� Autor � Microsiga            � Data � 07/03/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua a abertura do SM0 exclusivo                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Atualizacao PLS                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MyOpenSM0Ex()
LOCAL lOpen 	:= .F.
LOCAL nLoop 	:= 0

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
	Aviso("Aten��o !", "N�o foi poss�vel a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 )
EndIf

Return( lOpen )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � UpdEmp   � Autor � Microsiga		        � Data � 07/03/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Trata Empresa. Verifica as Empresas para Atualizar         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Atualizacao PLS                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function UpdEmp( aRecnoSM0 , lOpen )

Local cVar		:= Nil
Local oDlg		:= Nil
Local cTitulo	:= "Escolha a(s) Empresa(s) que ser�(�o) Atualizada(s)"
Local lMark		:= .F.
Local oOk		:= LoadBitmap( GetResources() , "CHECKED" )
Local oNo		:= LoadBitmap( GetResources() , "UNCHECKED" )
Local oChk		:= Nil
Local bCode		:= {|| oDlg:End() , Processa( {|lEnd| PLSProc( @lEnd , aRecnoSM0 , lOpen ) } , STR0008 , STR0009 , .F. ) }
Local nI			:=0
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
   		Aviso( cTitulo, "N�o existem bancos a consultar...", {"Ok"} )
	   	Return()
	Endif

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,700 PIXEL

	@ 10,10	LISTBOX oLbx VAR cVar FIELDS HEADER " ","Grupo Emp","Descricao", "Codigo","Empresa","Unidade","Filial","Descricao","Recno" SIZE 430,095 OF oDlg PIXEL ;
			ON dblClick( aRecnoSM0[oLbx:nAt,1] := !aRecnoSM0[oLbx:nAt,1] , oLbx:Refresh() )

	oLbx:SetArray( aRecnoSM0 )
	oLbx:bLine := {|| {Iif(	aRecnoSM0[oLbx:nAt,1],oOk,oNo)      ,;
                           aRecnoSM0[oLbx:nAt,2]               ,;
                           aRecnoSM0[oLbx:nAt,3]               ,;
                           aRecnoSM0[oLbx:nAt,4]               ,;
                           aRecnoSM0[oLbx:nAt,5]               ,;
                           aRecnoSM0[oLbx:nAt,6]               ,;
                           aRecnoSM0[oLbx:nAt,7]               ,;
                           aRecnoSM0[oLbx:nAt,8]               ,;
                           Alltrim(Str(aRecnoSM0[oLbx:nAt,9])) }}

	@ 110,10 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 60,007 PIXEL OF oDlg ON CLICK( aEval( aRecnoSM0 , {|x| x[1] := lChk } ) , oLbx:Refresh() )

	DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION Eval(bCode) ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTER

Endif

Return()

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Funcao   � CalcOrd   � Autor � TOTVS                 � Data �03/05/2013���
��������������������������������������������������������������������������Ĵ��
��� Descricao� Reordena os campos da tabela para melhor apresentacao       ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Compatibilizador PLS                                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
/*Static Function CalcOrd(cAlias,cOrdem)

SX3->(dbSetOrder(1))

SX3->(MsSeek(cAlias+cOrdem,.T.))

While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
   	SX3->(Reclock("SX3",.F.))
	SX3->X3_ORDEM := Soma1(SX3->X3_ORDEM)
	SX3->(MsUnlock())
	SX3->(DbSkip())
Enddo

Return
*/
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa �PLSAtuMsg � Autor � TOTVS 			 � Data �  18/12/2012 ���
�������������������������������������������������������������������������͹��
��� Descricao� Realiza a c�pia das mensagens j� digitadas para o novo     ���
���          � campo                                                      ���
�������������������������������������������������������������������������͹��
��� Uso      �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function PLSAtuMsg()

Local aSalvAmb := GetArea()


dbSelectArea("BVX")
dbSetOrder(1)

If BVX->(MSSeek(xFilial("BVX")))
	Do While !BVX->(EOF())
		RecLock( "BVX" , .F. )
		if alltrim(BVX->BVX_MSG) == ""
			BVX->BVX_MSG := BVX->BVX_MSG01 + chr(13) + chr(10) +;
							  BVX->BVX_MSG02 + chr(13) + chr(10) +;
							  BVX->BVX_MSG03 + chr(13) + chr(10) +;
							  BVX->BVX_MSG04 + chr(13) + chr(10) +;
							  BVX->BVX_MSG05
		EndIf
		MsUnLock()
		BVX->(dbSkip())
	EndDO
EndIf

RestArea(aSalvAmb)

Return