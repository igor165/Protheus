#INCLUDE "PROTHEUS.CH"
#INCLUDE "COMA034.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � COMA034  � Autor �Alexandre Inacio Lemes � Data �06/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Cadastro de Despachantes - SIGACOM Intenacional             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGACOM Internacional                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function COMA034()                         

Local lImportOk  := SuperGetMv("MV_COMPINT") == .T. .And. SuperGetMv("MV_EASY") == "N" .And. cPaisLoc <> "BRA"

Private aRotina  := MenuDef()
Private cCadastro:= STR0001 //"Despachantes"

//��������������������������������������������������������������Ŀ
//� Se as condicoes de uso das funcionalidades de importacao     �
//� estiverem ok endereca a funcao de BROWSE.                    �
//����������������������������������������������������������������
If lImportOk
	mBrowse(006,001,022,075,"DB9")  
Else
	Help(" ",1,"COMPINT") 
EndIf

Return .T.     
                
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C034Visual� Autor �Alexandre Inacio Lemes � Data �06/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Despachantes                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � C034Visual(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � COMA034                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function C034Visual(cAlias,nReg,nOpc)

Local aArea	   := GetArea()
Local nOpcA    := 0      
Local aButtons := {}
Local aUsrBut  := {}

//��������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo        �
//����������������������������������������������
Private aTELA[0][0],aGETS[0]

If ExistBlock( "CA034BUT" ) 
	If Valtype( aUsrBut := Execblock( "CA034BUT", .F., .F., {nOpc} ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } ) 
	EndIF 
EndIf 		

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
nOpcA := AxVisual("DB9",nReg,nOpc,,,,,aButtons)

RestArea(aArea)

Return Nil
      
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C034Inclui� Autor �Alexandre Inacio Lemes � Data �06/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Despachantes                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � C034Inclui(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � COMA034                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function C034Inclui(cAlias,nReg,nOpc)

Local aArea	   := GetArea()
Local aButtons := {}
Local aUsrBut  := {}
Local nOpcA    := 0
Local lAutomato	:= isBlind()
Local aAuto 	:= {} 

//��������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo        �
//����������������������������������������������
Private aTELA[0][0],aGETS[0]

If ExistBlock( "CA034BUT" )
	If Valtype( aUsrBut := Execblock( "CA034BUT", .F., .F., {nOpc} ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } )
	EndIF
EndIf

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
If lAutomato
	If FindFunction("GetParAuto")
		aRetAuto	:= GetParAuto("COMA034TESTCASE")
		aAuto 		:= aRetAuto[1]
	Endif
	nOpcA := AxInclui("DB9",nReg,nOpc,,,,,,,aButtons,,aAuto )
Else
	nOpcA := AxInclui("DB9",nReg,nOpc,,,,,,,aButtons )
Endif

If nOpcA == 1
	If ExistBlock( "CA034INC" )
		Execblock( "CA034INC", .F., .F.)
	EndIf
EndIf

RestArea(aArea)

Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C034Altera� Autor �Alexandre Inacio Lemes � Data �06/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Despachantes                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � C034Altera(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � COMA034                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function C034Altera(cAlias,nReg,nOpc)

Local aArea	   := GetArea()
Local aButtons := {}
Local aUsrBut  := {}
Local nOpcA:=0
Local lAutomato	:= isBlind()
Local aAuto 	:= {} 

//��������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo        �
//����������������������������������������������
Private aTELA[0][0],aGETS[0]
                                        
If ExistBlock( "CA034BUT" )
	If Valtype( aUsrBut := Execblock( "CA034BUT", .F., .F., {nOpc} ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } )
	EndIF
EndIf

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
If lAutomato
	If FindFunction("GetParAuto")
		aRetAuto	:= GetParAuto("COMA034TESTCASE")
		aAuto 		:= aRetAuto[1]
	Endif
	nOpcA := AxAltera( "DB9", nReg, nOpc, , , , ,,,,aButtons,,aAuto)
Else
	nOpcA := AxAltera( "DB9", nReg, nOpc, , , , ,,,,aButtons)
Endif

If nOpcA == 1
	If ExistBlock( "CA034ALT" )
		Execblock( "CA034ALT", .F., .F. )
	EndIf
EndIf

RestArea(aArea)

Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �C034Deleta� Autor �Alexandre Inacio Lemes � Data �06/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Despachantes                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � C034Deleta(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � COMA034                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function C034Deleta(cAlias,nReg,nOpc)

Local aArea	   := GetArea()
Local aButtons := {}
Local aUsrBut  := {}
Local nOpcA    := 0  
Local oDlg 
Local aSize    := {} 
Local aInfo    := {}
Local aObjects := {}
Local lAutomato	:= isBlind()

//��������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo        �
//����������������������������������������������
Private aTELA[0][0],aGETS[0]

If ExistBlock( "CA034BUT" ) 
	If Valtype( aUsrBut := Execblock( "CA034BUT", .F., .F., {nOpc} ) ) == "A"
		AEval( aUsrBut, { |x| AAdd( aButtons, x ) } ) 
	EndIF 
EndIf 		

If SoftLock("DB9") 
	//�������������������������������������������������Ŀ
	//� Ajusta a largura para o tamanho padrao Protheus �
	//���������������������������������������������������
	aSize := MsAdvSize()       
	aSize[5] := 1155      
	aSize[3] := 318
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo    := { aSize[1], aSize[2], aSize[3], aSize[4], 2, 2 } 
	aPosObj := MsObjSize( aInfo, aObjects ) 
	If !lAutomato	
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
		nOpcA:=Enchoice( "DB9", nReg, nOpc,,,,,aPosObj[1])
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 0,oDlg:End()},,aButtons)
	Else 
		nOpca := 1
	EndIf
	
	If nOpcA == 1  
		//��������������������������������������������������������������Ŀ
		//� Apos passar por todas as verificacoes , deleta o registro    �
		//����������������������������������������������������������������
		If COMA034Ex()   // Se for necessario desenvolver funcao para validacao de exclusao                         
			Begin Transaction          
			dbSelectArea("DB9") 
			RecLock("DB9",.F.)
			dbDelete()
			End Transaction
		EndIf
	EndIf

	MsUnLockAll()
	
EndIf

RestArea(aArea)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �COMA034EX � Autor �Alexandre Inacio Lemes � Data �06/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida se pode ser feita a exclusao                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function COMA034Ex()

Local aArea	:= GetArea()
Local lRet	:= .T.

//��������������������������������������������������������������������Ŀ
//� Se necessario desenvolver validacao para excluir ou nao o registro.�
//� Help(" ",1,"C034DELE")                                             �
//����������������������������������������������������������������������

If lRet
	If (ExistBlock("CA034EXC"))
		lRet := ExecBlock("CA034EXC",.F.,.F.)
		If Valtype( lRet ) <> "L"
			lRet := .T.
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet  

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor �Alexandre Inacio Lemes � Data �06/03/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()     

Private aRotina	:= { 	{STR0005,"AxPesqui"  , 0 , 1, 0, .F.},;    // "Pesquisar"
						{STR0006,"C034Visual", 0 , 2, 0, nil},;    // "Visualizar"
						{STR0007,"C034Inclui", 0 , 3, 0, nil},;    // "Incluir"
						{STR0008,"C034Altera", 0 , 4, 0, nil},;    // "Alterar"
						{STR0009,"C034Deleta", 0 , 5, 3, nil}}     // "Excluir"	

//������������������������������������������������������������������������Ŀ
//� Ponto de entrada utilizado para inserir novas opcoes no array aRotina  �
//��������������������������������������������������������������������������
If ExistBlock("CMA034MNU")
	ExecBlock("CMA034MNU",.F.,.F.)
EndIf

Return(aRotina) 