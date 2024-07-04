
#Include "MATA942.CH"
#Include "FIVEWIN.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MATA942  � Autor � William P. Alves      � Data � 22.11.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cadastro de Vinculo Empresas x Zonas Fiscais (SFH)         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � MATA942(ExpA1,ExpN1)                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 - Array da Rotina Automatica                         ���
���          � ExpN1 - Numero da Opcao                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL              ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA942(aRotAuto,nOpc)

nOpc := If (nOpc == Nil,3,nOpc)

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Private aAC  := { STR0001, STR0002 }			//"Abandona"###"Confirma"

Private aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0008)         // "Atualizacao do Cadastro de Provincias"

//��������������������������������������������������������������Ŀ
//� Definicao de variaveis utilizadas na rotina automatica       �
//����������������������������������������������������������������
Private Inclui := .F.
Private Altera := .F.

//��������������������������������������������������������������Ŀ
//� Definicao de variaveis para rotina de inclusao automatica    �
//����������������������������������������������������������������
Private l942Auto := ( aRotAuto <> NIL )

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������

If Empty(SM0->M0_ESTENT)
	MSGALERT(OemToAnsi(STR0015),OemToAnsi(STR0010))                        
    Return()
EndIf

    
If l942Auto
	dbSelectArea("CCO")
	MsRotAuto(nOpc,aRotAuto,"CCO")
Else
	dbSelectArea("CCO")
	mBrowse( 6, 1,22,75,"CCO")
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A942Inclui� Autor � William P. Alves      � Data � 22.11.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Inclusao                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � A942Inclui(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA942()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A942Inclui(cAlias,nReg,nOpc)

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas na rotina automatica                    �
//����������������������������������������������������������������
Inclui := .T.
Altera := .F.

	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA:=0
	
	If ( l942Auto )
		nOpcA := AxIncluiAuto(cAlias,"A942TudoOk()")
	Else
		nOpcA:=AxInclui(cAlias,nReg,nOpc,,,,"A942TudoOk()")
	EndIf
	
	IF nOpcA == 1
		//����������������������������������������������������������������������Ŀ
		//�Ponto de entrada depois da confirmacao                                �
		//������������������������������������������������������������������������
	Endif
	
	dbSelectArea(cAlias)

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A942Altera� Autor � William P. Alves      � Data � 30.11.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Alteracao                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � A942Altera(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA942()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A942Altera(cAlias,nReg,nOpc)

Local nOpcA

l942Auto := If(Type("l942Auto") == "U", .F.,l942Auto)

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas na rotina automatica                    �
//����������������������������������������������������������������
Inclui := .F.
Altera := .T.

	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA:=0
	
	If ( l942Auto )
		nOpcA := AxIncluiAuto(cAlias,,,nOpc,CCO->(RecNo()))
	Else
		nOpcA:=AxAltera(cAlias,nReg,nOpc,,,,,"A942TudoOk()")
	EndIf
	
	IF nOpcA == 1
		//����������������������������������������������������������������������Ŀ
		//�Ponto de entrada depois da confirmacao                                �
		//������������������������������������������������������������������������
	Endif

dbSelectArea(cAlias)

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A942TudoOk� Autor � William P. Alves      � Data � 22.11.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Consistencia do registro                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �A942TudoOk()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA942()                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A942TudoOk()

Local lRet :=.T.

	if !Empty(M->CCO_CODPRO) 
		lRet := ExistChav("CCO",M->CCO_CODPRO)
	Endif

	IF M->CCO_AGPER =="1" .And. Empty(M->CCO_TPPERC)  .And. lRet
		MsgAlert(OemtoAnsi(STR0012),OemToAnsi(STR0010))	
		lRet := .F.          
	EndIf		

	IF M->CCO_AGRET =="1" .And. Empty(M->CCO_TPRET)  .And. lRet
		MsgAlert(OemtoAnsi(STR0016),OemToAnsi(STR0010))	
		lRet := .F.          
	EndIf
	
	IF M->CCO_AGRET =="2" .And. !Empty(M->CCO_TPRET)  .And. lRet
		MsgAlert(OemtoAnsi(STR0017),OemToAnsi(STR0010))	
		lRet := .F.          
	EndIf 
	
	IF M->CCO_AGPER =="1" .And. !(M->CCO_TIPO $ "IVXN")
		MsgAlert(OemToAnsi(STR0014),OemToAnsi(STR0010))	
		lRet := .F.          
	EndIf		
	
Return( lRet )

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A942Deleta� Autor � William P. Alves      � Data � 22.11.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de exclusao                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � A942Deleta(ExpC1,ExpN1,ExpN2)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA942()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A942Deleta(cAlias,nReg,nOpc)

Local nOpcA

l942Auto  := If (Type("l942Auto") =="U",.F.,l942Auto)

//��������������������������������������������������������������Ŀ
//� Monta tela de exclusao de dados do arquivo                   �
//����������������������������������������������������������������
Private aTELA[0][0], aGETS[0]

	//��������������������������������������������Ŀ
	//� Envia para processamento dos Gets          �
	//����������������������������������������������
	nOpcA:=0
	
	IF !SoftLock(cAlias)
		Return
	Endif
	
	If !( l942Auto )
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
		nOpcA:=EnChoice( cAlias, nReg, nOpc, aAC,"AC",OemToAnsi(STR0009) )//"Quanto a exclusao?"
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})
	Else
		nOpcA := 2
	EndIf

	IF nOpcA == 2  

		//��������������������������������������������������������������Ŀ
		//� Exclusao do registro                                         �
		//����������������������������������������������������������������
		dbSelectArea(cAlias)
		RecLock(cAlias,.F.,.T.)
		dbDelete()

		//��������������������������������������������������������������Ŀ
		//� Ponto de entrada apos a confirmacao                          �
		//����������������������������������������������������������������

   ENDIF

   MsUnlock()
   DbSkip()
   
   dbSelectArea(cAlias)

Return()
                     
/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � William P. Alves      � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()
     
Private aRotina := {	{ STR0003, "AxPesqui"  , 0 , 1 , 0 , .F.},;	//"Pesquisar"
							{ STR0004, "AxVisual"  , 0 , 2 , 0 , NIL},;	//"Visualizar"
							{ STR0005, "A942Inclui", 0 , 3 , 0 , NIL},;	//"Incluir"
							{ STR0006, "A942Altera", 0 , 4 , 0 , NIL},;	//"Alterar"
							{ STR0007, "A942Deleta", 0 , 5 , 0 , NIL}}	//"Excluir"

Return(aRotina)


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A942CODPRV� Autor � Paulo Augusto         � Data � 11.02.10 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Valida codigo Provincia e traz descricao                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � A942CODPRV(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Cod. Estado                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA942()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function A942CODPRV(cCampo)

Local cProv:=""
Local cDesc:= ""
Local lRet:=.F.
Default cCampo:=""

cProv:= cCampo

If ExistCpo("SX5","12"+cProv)

	lRet:=.T.
	SX5->(DbSeek(xFilial()+"12"+cProv))
	cDesc:=X5Descri()
	
	If cProv=="CF"
		cProv:="01"
	ElseIf cProv=="BA"
		cProv:="02"
	ElseIf cProv=="CA"
		cProv:="03"
	ElseIf cProv=="CO"
		cProv:="04"
	ElseIf cProv=="CR"
		cProv:="05"
	ElseIf cProv=="CH"
		cProv:="06"
	ElseIf cProv=="CB"
		cProv:="07"
	ElseIf cProv=="ER"
		cProv:="08"
	ElseIf cProv=="FO"
		cProv:="09"
	ElseIf cProv=="JU"
		cProv:="10"
	ElseIf cProv=="LP"
		cProv:="11"
	ElseIf cProv=="LR"
		cProv:="12"
	ElseIf cProv=="ME"
		cProv:="13"
	ElseIf cProv=="MI"
		cProv:="14"
	ElseIf cProv=="NE"
		cProv:="15"
	ElseIf cProv=="RN"
		cProv:="16"
	ElseIf cProv=="SA"
		cProv:="17"
	ElseIf cProv=="SJ"
		cProv:="18"
	ElseIf cProv=="SL"
		cProv:="19"
	ElseIf cProv=="SC"
		cProv:="20"
	ElseIf cProv=="SF"
		cProv:="21"
	ElseIf cProv=="SE"
		cProv:="22"
	ElseIf cProv=="TF"
		cProv:="23"
	ElseIf cProv=="TU"
		cProv:="24"
	EndIf
	
	M->CCO_CODJUR:=cProv
	M->CCO_DESCPR:=cDesc
EndIf

Return(lRet)


/*/
���Programa  � fBoxCPERNC  �Autor  � Raul Ortiz         � Data �  11/01/16   ���
����������������������������������������������������������������������������͹��
���Desc.     � Retorna Combo para Perc. FC/NC de Estado vs Ing. Brutos       ���
/*/
Function fBoxCPERNC()
Local cOpcBox := ""

	cOpcBox += ( OemtoAnsi(STR0018) ) //"1=Siempre;"								
	cOpcBox += ( OemtoAnsi(STR0019) ) //"2=Dev. Total;"							
	cOpcBox += ( OemtoAnsi(STR0020) ) //"3=FC/NC Mismo Periodo;"					
	cOpcBox += ( OemtoAnsi(STR0021) ) //"4= Dev. Total y FC/NC Mismo Per.;"		
	cOpcBox += ( OemtoAnsi(STR0022) ) //"5=No Calcula;"							
	cOpcBox += ( OemtoAnsi(STR0023) ) //"6=Importe M�ximo;"						
	cOpcBox += ( OemtoAnsi(STR0024) ) //"7=FC/NC Misma Quincena;"					
	cOpcBox += ( OemtoAnsi(STR0025) ) //"8=FC/NC Misma Quincena Dev. Total;"		
	cOpcBox += ( OemtoAnsi(STR0026) ) //"9=FC/NC Dentro 3 meses;"					
	cOpcBox += ( OemtoAnsi(STR0027) ) //"0=FC/NC Dentro 3 meses Dev. Total;"		
	cOpcBox += ( OemtoAnsi(STR0028) ) //"A=FC/NC Dentro 2 meses;"                  
	cOpcBox += ( OemtoAnsi(STR0029) ) //"B=FC/NC Dentro 2 meses - Dev total"       

Return( cOpcBox )
