#Include "PROTHEUS.CH"
#INCLUDE "QNCA170.CH"
#INCLUDE "FiveWin.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QNCA170  � Autor � Leandro 				� Data � 27/02/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Permissoes Entre Etapas  					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQNC                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function MenuDef()

Local aRotina := {{STR0001, "AxPesqui"	, 0, 1,,.F.},;	//"Pesquisar"
				 {STR0002, "QNCA170ATU"	, 0, 2 },;	    //"Visualizar"
				 {STR0003, "QNCA170ATU"	, 0, 3 },;	    //"Incluir"
				 {STR0004, "QNCA170ATU"	, 0, 4, 82 },;	//"Alterar"
				 {STR0005, "QNCA170ATU"	, 0, 5, 3 }} 	//"Excluir"

Return aRotina

Function QNCA170()
PRIVATE cCadastro := STR0006//"Cadastro de Permissoes entre Etapas"
PRIVATE aRotina   := MenuDef()

If !QNCHECK()
	Return(NIL)
Endif	

DbSelectArea("QUS")
DbSetOrder(1)

mBrowse( 6, 1,22,75,"QUS")

DbSelectArea("QUS")
Set Filter To
DbSetOrder(1)

Return(NIL)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QNCA170ATU� Autor � Leandro				� Data �27/02/08  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Manutencao do cadastro de Tipos de Documentos			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QNCA170ATU(cAlias,nReg,nOpc)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QNCA170ATU                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QNCA170ATU(cAlias,nReg,nOpc)
Local oDlg
Local bCampo 	:= { |nCPO| Field(nCPO) }
Local nI     	:= 0
Local aTela  	:= {}
Local aGets  	:= {}
Local lOk    	:= .F.
Local cChv   	:= 0

DbSelectArea("QUS")
DbSetOrder(1)

If nOpc == 3 
   For nI := 1 To FCount()
       cCampo := Eval( bCampo, nI )
       lInit  := .F.
        	
       If ExistIni( cCampo )
          lInit := .T.
          M->&( cCampo ) := InitPad( GetSx3Cache(cCampo,"X3_RELACAO") )
          If ValType( M->&( cCampo ) ) = "C"
             M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo,"X3_TAMANHO") )
          EndIf
          If M->&(cCampo) == Nil
             lInit := .F.
          EndIf
       EndIf
       If !lInit
          M->&( cCampo ) := FieldGet( nI )
          If ValType( M->&( cCampo ) ) = "C"
             M->&( cCampo ) := Space( Len( M->&(cCampo) ) )
          ElseIf ValType( M->&( cCampo ) ) = "N"
             M->&( cCampo ) := 0
          ElseIf ValType( M->&( cCampo ) ) = "D"
             M->&( cCampo ) := CtoD( "  /  /  " )
          ElseIf ValType( M->&( cCampo ) ) = "L"
             M->&( cCampo ) := .f.
          EndIf   

   	      If "QUS_ETPSEQ" $ (Eval(bCampo,nI))
		    cChv := GetSx8Num("QUS","QUS_ETPSEQ")
		    While MsSeek(xFilial("QUS")+cChv,.F.) .and. cChv < REPLICATE("z",Len(QUS->QUS_ETPSEQ))
			    cChv:= GetSx8Num("QUS","QUS_ETPSEQ")			    
		    EndDo
			M->&(cCampo) := cChv
		   Endif                                                                    
       EndIf
   Next nI
	M->QUS_FILIAL:= xFilial("QUS") 
Else
   For nI := 1 To FCount()
       M->&(Eval(bCampo,nI)) := FieldGet( nI )
   Next nI
EndIf

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro)	FROM 030,000 TO 220,610 OF oMainWnd PIXEL
EnChoice("QUS",nReg,nOpc,,,,,{15,2,090,300},,)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := If(Obrigatorio(aGets,aTela),oDlg:End(),.F.)},	{||lOk := .F.,oDlg:End()})CENTERED

If (!lOk) .Or. nOpc == 2
	If nOpc == 3
		RollBackSX8()
	EndIF
	Return NIL
Endif
	
If nOpc == 5
	RecLock("QUS", .F.)
	dbDelete()
	MsUnLock()
	dbSkip()
Else
	If nOpc == 3
		If QNC170Valid()
			RecLock( "QUS", .T. )
		Else
			Return NIL
		Endif	
	Else
		RecLock( "QUS", .F. )
	EndIf
	For nI := 1 TO FCount()
		FieldPut(nI,M->&(Eval(bCampo,nI)))
	Next nI
	MsUnlock()                  
	FKCOMMIT()
	ConfirmSX8()
Endif	

Return NIL

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �QNC170Valid � Autor � Leandro              � Data �27/02/08  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica a existencia da etapa ja cadastradas.              ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe   � A170Valid                                            	   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function QNC170Valid()
Local lRetorno  := .T.
Local aArea 	:= GetArea()

dbSelectArea("QUS")
dbSetOrder(1)
dbSeek( xFilial("QUS")+M->QUS_ETPSEQ+M->QUS_ETPATU)

If Empty(M->QUS_ETPSEQ)
	MSGAlert(STR0007)//"Sequencia nao foi preenchida."
	lRetorno := .F.
Else	
	If Empty(M->QUS_ETPATU) 
		MSGAlert(STR0008)//"Campo Etapa Atual nao foi preenchido."
		lRetorno := .F.
	Else
		If M->QUS_REJPL == "2"                              
			If Empty(M->QUS_ETPPRX)
				MSGAlert(STR0010)//"Campo Etapa Back nao foi preenchido."
				lRetorno := .F.    	
            Endif
        Else
        	If Found() 
				MSGAlert(STR0009)//"Tipo de Acao ja cadastrado."
				lRetorno := .F.
			EndIf
		Endif
	Endif	
Endif

RestaRea(aArea)

Return(lRetorno)
