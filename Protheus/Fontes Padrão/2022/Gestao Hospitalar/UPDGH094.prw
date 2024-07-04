#INCLUDE "protheus.ch"
#INCLUDE "UPDGHPAD.ch"
                      
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    � UPDGH094	 � Autor � Saude                 � Data � 08/02/12 ���
��������������������������������������������������������������������������Ĵ��
���Descri�ao � Atualizacao das tabelas do GH               				   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Gestao Hospitalar                                           ���
��������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                      ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function UPDGH094()
//����������������������������������������������������������������������������Ŀ
//� Inicializa variaveis                                                       |
//������������������������������������������������������������������������������
Local nOpca		  := 0
Local aSays		  := {}, aButtons := {}   
Local aRecnoSM0	  := {}  
Local lOpen		  := .F.  
Private nModulo	  := 51 // modulo SIGAHSP
Private cMessage
Private aArqUpd	  := {}
Private aREOPEN	  := {} 
Private oMainWnd 
Private cCadastro := STR0001 // "Compatibilizador de Dicion�rios x Banco de dados"
Private cCompat	  := "UPDGH094"
Private cChamado  := "TEIHW9"
Private cRef	  := "Bloqueio de solicita��o de APAC."
//Private cRefB   := "na Agenda Ambulatorial"
Set Dele On      
//����������������������������������������������������������������������������Ŀ
//� Monta texto para janela de processamento                                   �
//������������������������������������������������������������������������������
AADD(aSays,STR0002)  //"Esta rotina ir� efetuar a compatibiliza��o dos dicion�rios e banco de dados,"
AADD(aSays,STR0003)//"e demais ajustes referentes a CHAMADO abaixo:"
AADD(aSays,"   CHAMADO: " + cChamado)
AADD(aSays,STR0004 + cRef)  //"   Refer�ncia: "
//AADD(aSays,"               " + cRefb)  //"   Refer�ncia: "

AADD(aSays, STR0005)   //"Aten��o: efetuar backup dos dicion�rios e do banco de dados previamente "
//����������������������������������������������������������������������������Ŀ
//� Monta botoes para janela de processamento                                  �
//������������������������������������������������������������������������������
AADD(aButtons, { 1,.T.,{|| nOpca := 1, FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|| nOpca := 0, FechaBatch() }} )
//����������������������������������������������������������������������������Ŀ
//� Exibe janela de processamento                                              �
//������������������������������������������������������������������������������
FormBatch( cCadastro, aSays, aButtons,, 230 )
//����������������������������������������������������������������������������Ŀ
//� Processa calculo                                                           �
//������������������������������������������������������������������������������
If  nOpca == 1
	If  Aviso(STR0006, STR0007, {STR0041,STR0042}) == 1
          Processa({||UpdEmp(aRecnoSM0,lOpen)},STR0008,STR0009,.F.)
    Endif
Endif
//����������������������������������������������������������������������������Ŀ
//� Fim do programa                                                            |
//������������������������������������������������������������������������������
Return()
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ProcATU   � Autor �                       � Data �  /  /    ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao de processamento da gravacao dos arquivos           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Baseado na funcao criada por Eduardo Riera em 01/02/2002   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ProcATU(lEnd,aRecnoSM0,lOpen)       

Local cTexto  := ""
Local cFile   := ""
Local cMask   := "Arquivos Texto (*.TXT) |*.txt|"
Local nRecno  := 0
Local nI      := 0
Local nX      := 0
Local cCodigo := ""

ProcRegua(1)
IncProc(STR0010)//"VerIficando integridade dos dicion�rios...."

	If lOpen   
		lSel:=.F.
		For nI := 1 To Len(aRecnoSM0)
			DbSelectArea("SM0")
   			DbGotop()
			SM0->(dbGoto(aRecnoSM0[nI,9]))
					
			If !aRecnoSM0[nI,1] .OR. SM0->M0_CODIGO == cCodigo   // Se for o mesmo Grupo Empresa nao e necessario rodar novamente
				Loop
			EndIf  
			
			lSel:=.T.			
			RpcSetType(2)
			RpcSetEnv(  SM0->M0_CODIGO, FWGETCODFILIAL)
			cCodigo := SM0->M0_CODIGO
 		    nModulo := 51 // modulo SIGAHSP
			lMsFinalAuto := .F.
			cTexto += Replicate("-",128)+CHR(13)+CHR(10)
			cTexto += STR0025 + aRecnoSM0[nI][2]//"Grupo Empresa: "

			ProcRegua(8)
			
			conout( "Fun��es descontinuadas pelo SGBD: GeraSX6()" )
	
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
					Aviso(STR0017,STR0019 + aArqUpd[nx] + STR0018 ,{STR0030},2) //"Atencao!","Ocorreu um erro desconhecido durante a atualizacao da tabela : " //". VerIfique a integridade do dicionario e da tabela."  // "Continuar"
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
			cTexto 	:= STR0020 + CHR(13) + CHR(10) + cTexto //"Log da atualizacao "			
				If !lSel 
					cTexto+= STR0026//"N�o foram selecionadas nenhuma empresa para Atualiza��o"
				EndIf
			__cFileLog := MemoWrite(Criatrab(,.f.) + ".LOG", cTexto)
			
			DEFINE FONT oFont NAME "Mono AS" SIZE 5,12
			DEFINE MSDIALOG oDlg TITLE STR0021+" ["+cChamado+"]"+ STR0022  From 3,0 to 340,417 PIXEL  //"Atualizador   Atualizacao concluida."
				@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
				oMemo:bRClicked := {||AllwaysTrue()}
				oMemo:oFont:=oFont
				DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
				DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
			ACTIVATE MSDIALOG oDlg CENTER
	
		EndIf		
	EndIf		

Return(Nil)


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MyOpenSM0Ex� Autor �Sergio Silveira       � Data �07/01/2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Efetua a abertura do SM0 exclusivo                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Atualizacao FIS                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
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
	Aviso( STR0017, STR0023, { "Ok" }, 2 ) //Aten��o , "Nao foi possivel a abertura da tabela de empresas de forma exclusiva !"
EndIf

Return( lOpen )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � UpdEmp   � Autor � Luciano Aparecido     � Data � 15.05.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Trata Empresa. VerIfica as Empresas para Atualizar         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Atualizacao PLS                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function  UpdEmp(aRecnoSM0,lOpen) 
		
Local cVar    := Nil
Local oDlg    := Nil
Local cTitulo := STR0027  //"Escolha a(s) Empresa(s) que ser�(�o) Atualizada(s)"
Local lMark   := .F.
Local oOk     := LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo     := LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local oChk    := Nil                                
Local bCode   := {||oDlg:End(),Processa({|lEnd| ProcATU(@lEnd,aRecnoSM0,lOpen)},STR0008,STR0009,.F.)} //"Processando","Aguarde, processando prepara��o dos arquivos"
Local nI      :=0
Local aRecSM0 :={}
Private lChk  := .F.
Private oLbx  := Nil

If ( lOpen := MyOpenSm0Ex() )
	dbSelectArea("SM0")
		
    //////////////////////////////////////////
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
    EndIf

    DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,700 PIXEL
   
    @ 10,10 LISTBOX oLbx VAR cVar FIELDS HEADER ;
    " ","Grupo Emp","Descricao", "Codigo","Empresa","Unidade","Filial","Descricao","Recno" ;
    SIZE 430,095 OF oDlg PIXEL ON dblClick(aRecnoSM0[oLbx:nAt,1] := !aRecnoSM0[oLbx:nAt,1],oLbx:Refresh())

    oLbx:SetArray( aRecnoSM0)
    oLbx:bLine := {|| {IIf(aRecnoSM0[oLbx:nAt,1],oOk,oNo),;
                            aRecnoSM0[oLbx:nAt,2],;
                            aRecnoSM0[oLbx:nAt,3],;
                            aRecnoSM0[oLbx:nAt,4],;
                            aRecnoSM0[oLbx:nAt,5],;
                            aRecnoSM0[oLbx:nAt,6],;
                            aRecnoSM0[oLbx:nAt,7],;
                            aRecnoSM0[oLbx:nAt,8],;
                            Alltrim(Str(aRecnoSM0[oLbx:nAt,9]))}} 
     
    ///////////////////////////////////////////////////////////////////
    //| Para marcar e desmarcar todos existem duas op�oes, acompanhe...
    ///////////////////////////////////////////////////////////////////

    @ 110,10 CHECKBOX oChk VAR lChk PROMPT  STR0029 SIZE 60,007 PIXEL OF oDlg ; //"Marca/Desmarca"
             ON CLICK(aEval(aRecnoSM0,{|x| x[1]:=lChk}),oLbx:Refresh())
 
    DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION Eval(bCode) ENABLE OF oDlg
    ACTIVATE MSDIALOG oDlg CENTER
EndIf

Return