#INCLUDE "QPPA020.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QPPA020  � Autor � Robson Ramiro A. Olive� Data � 25.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Cadastro de Operacoes                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPA020(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPPAP                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��� Robson Ramiro�19/02/02�VERSAO� Ajustes 609 x 710                      ���
�������������������������������������������������������������������������Ĵ��
��� Robson Ramiro�18/03/02�META  � Alt. para cadastrar +99 operacoes e    ���
���              �        �      � reorganizacao por ordem de operacao    ���
��� Robson Ramiro�09/08/02�xMETA � Inclusao de Filtro na mBrowse          ���
���              �        �      � Validacoes para inclusao               ���
���              �        �      � Troca da QA_CVKEY por GetSXENum        ���
��� Robson Ramiro�09/05/03�64398 � Tratamento dinamico da qtde de itens da���
���              �        �      � getdados caso necessite customizacao   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { 	{OemToAnsi(STR0001)	,"AxPesqui"   , 0 , 1,,.F.},;//"Pesquisa"
				  	{OemToAnsi(STR0002)	,"PPA020Visu" , 0 , 2},;  	  //"Visualiza"
					{OemToAnsi(STR0003)	,"PPA020Incl" , 0 , 3},;	  //"Inclui"
					{OemToAnsi(STR0004)	,"PPA020Alte" , 0 , 4},;  	  //"Altera"
					{OemToAnsi(STR0005)	,"PPA020Excl" , 0 , 5}}   	  //"Exclui"

Return aRotina

Function QPPA020

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������

Private cFiltro

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������

Private cCadastro 	:= OemToAnsi(STR0006) //"Cadastro de Operacoes"
Private nTamGet		:= QPPTAMGET("QKK_ITEM",1)
Private nTamItem	:= QPPTAMGET("QKK_ITEM",2)

Private aRotina := MenuDef()

DbSelectArea("QKK")
DbSetOrder(1)

cFiltro := "QKK_ITEM <> '"+StrZero(0,nTamItem)+"'"

Set Filter To &cFiltro
mBrowse(6,1,22,75,"QKK",,,,,,)
Set Filter To

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA020Visu� Autor � Robson Ramiro A. Olive� Data � 26/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Programa de Visualizacao do Cadastro de Operacoes          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA020Visu()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA020Visu(cAlias, nReg, nOpc)

Local oDlg			:= NIL
Local oGet_1		:= NIL
Local oGet_2		:= NIL
Local aButtons		:= {}
Local aPosObj		:= {}
Local oSize			:= NIL

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos

RegToMemory("QKK")

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
oSize := FwDefSize():New()                
oSize:AddObject( "CABECALHO",  100, 30, .T.,.F.)
oSize:AddObject( "GETDADOS" ,  100, 60, .T.,.T.)         
oSize:aMargins := { 3, 3, 3, 3 }
oSize:Process() // Dispara os calculos 

A020Ahead("QKK")
DbSelectArea("QKK")
Set Filter To

nUsado	:= Len(aHeader)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Cadastro de Operacoes"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

aAdd(aPosObj,{oSize:GetDimension('CABECALHO', 'LININI'),oSize:GetDimension('CABECALHO', 'COLINI'),oSize:GetDimension('CABECALHO', 'LINEND'),oSize:GetDimension('CABECALHO', 'COLEND')})
aAdd(aPosObj,{oSize:GetDimension('GETDADOS' , 'LININI'),oSize:GetDimension('GETDADOS' , 'COLINI'),oSize:GetDimension('GETDADOS' , 'LINEND'),oSize:GetDimension('GETDADOS' , 'COLEND')})

@ 32,03 SAY  TitSX3("QKK_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ 33,59 MSGET oGet_1 VAR M->QKK_PECA PICTURE PesqPict("QKK","QKK_PECA") ;
						ReadOnly F3 ConSX3("QKK_PECA");
						SIZE 66,10 OF oDlg PIXEL;

@ 32,131 SAY TitSX3("QKK_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 33,187 MSGET oGet_2 VAR M->QKK_REV PICTURE PesqPict("QKK","QKK_REV") ;
						WHEN .F. ;
					   	SIZE 15,10 OF oDlg PIXEL
A020Acols(nOpc)

oGet := MSGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4], nOpc,"AllwaysTrue","AllwaysTrue","+QKK_ITEM",.T.)

aButtons := { {"RELATORIO", { || QPP020OBSE(nOpc) }, OemToAnsi(STR0007),OemToAnsi(STR0010) } } //"Observacoes"###"Obs"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

DbSelectArea("QKK")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.
          

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA020Incl� Autor � Robson Ramiro A. Olive� Data � 26/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Programa de Inclusao do Cadastro de Operacoes              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPPA020Incl()                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA020Incl(cAlias, nReg, nOpc)

Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local lOk 		:= .F.   
Local aButtons	:= {}
Local aPosObj	:= {}
Local oSize		:= NIL

Private aHeader := {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL
Private axTextos

RegToMemory("QKK",.T.)

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
oSize := FwDefSize():New()                
oSize:AddObject( "CABECALHO",  100, 30, .T.,.F.)
oSize:AddObject( "GETDADOS" ,  100, 60, .T.,.T.)         
oSize:aMargins := { 3, 3, 3, 3 }
oSize:Process() // Dispara os calculos 

A020Ahead("QKK")
DbSelectArea("QKK")
Set Filter To

nUsado	:= Len(aHeader)      

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Cadastro de Operacoes"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

aAdd(aPosObj,{oSize:GetDimension('CABECALHO', 'LININI'),oSize:GetDimension('CABECALHO', 'COLINI'),oSize:GetDimension('CABECALHO', 'LINEND'),oSize:GetDimension('CABECALHO', 'COLEND')})
aAdd(aPosObj,{oSize:GetDimension('GETDADOS' , 'LININI'),oSize:GetDimension('GETDADOS' , 'COLINI'),oSize:GetDimension('GETDADOS' , 'LINEND'),oSize:GetDimension('GETDADOS' , 'COLEND')})

@ 32,03 SAY TitSX3("QKK_PECA")[1] SIZE 56,07 OF oDlg PIXEL  
@ 33,59 MSGET oGet_1 VAR M->QKK_PECA PICTURE PesqPict("QKK","QKK_PECA") ;
						Valid CheckSx3("QKK_PECA");
						F3 "QPP" SIZE 66,10 OF oDlg PIXEL  


@ 32,131 SAY TitSX3("QKK_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 33,187 MSGET oGet_2 VAR M->QKK_REV PICTURE PesqPict("QKK","QKK_REV") ;
						VALID CheckSx3("QKK_REV") ;
					   	SIZE 15,10 OF oDlg PIXEL
   		
A020Acols(nOpc)
																						 
oGet := MSGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4], nOpc,"PP20LinOk" ,"PP20TudOk","+QKK_ITEM",.T.,,,,nTamGet)

aButtons := { {"RELATORIO", { || QPP020OBSE(nOpc) }, OemToAnsi(STR0007),OemToAnsi(STR0010) } } //"Observacoes"###"Obs"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP20TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

	If lOk
	PPA020Grav(nOpc)
	Endif

DbSelectArea("QKK")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA020Alte� Autor � Robson Ramiro A. Olive� Data � 26/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Programa de Alteracao do Cadastro de Operacoes             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA020Alte()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA020Alte(cAlias, nReg, nOpc)

Local oDlg			:= NIL
Local oGet_1		:= NIL
Local oGet_2		:= NIL
Local lOk 			:= .F.   
Local aButtons		:= {}
Local aPosObj		:= {}
Local oSize			:= NIL

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos

	If !QPPVldAlt(QKK->QKK_PECA,QKK->QKK_REV)
	Return
	Endif

RegToMemory("QKK")

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
oSize := FwDefSize():New()                
oSize:AddObject( "CABECALHO",  100, 30, .T.,.F.)
oSize:AddObject( "GETDADOS" ,  100, 60, .T.,.T.)         
oSize:aMargins := { 3, 3, 3, 3 }
oSize:Process() // Dispara os calculos 

A020Ahead("QKK")
DbSelectArea("QKK")
Set Filter To

nUsado	:= Len(aHeader)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Cadastro de Operacoes"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

aAdd(aPosObj,{oSize:GetDimension('CABECALHO', 'LININI'),oSize:GetDimension('CABECALHO', 'COLINI'),oSize:GetDimension('CABECALHO', 'LINEND'),oSize:GetDimension('CABECALHO', 'COLEND')})
aAdd(aPosObj,{oSize:GetDimension('GETDADOS' , 'LININI'),oSize:GetDimension('GETDADOS' , 'COLINI'),oSize:GetDimension('GETDADOS' , 'LINEND'),oSize:GetDimension('GETDADOS' , 'COLEND')})

@ 32,03 SAY TitSX3("QKK_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ 33,59 MSGET oGet_1 VAR M->QKK_PECA PICTURE PesqPict("QKK","QKK_PECA") ;
						ReadOnly F3 ConSX3("QKK_PECA");
						SIZE 66,10 OF oDlg PIXEL

@ 32,131 SAY TitSX3("QKK_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 33,187 MSGET oGet_2 VAR M->QKK_REV PICTURE PesqPict("QKK","QKK_REV") ;
						WHEN .F. ;			
					   	SIZE 15,10 OF oDlg PIXEL
		   		
A020Acols(nOpc)

oGet := MSGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4], nOpc,"PP20LinOk" ,"PP20TudOk","+QKK_ITEM",.T.,,,,nTamGet)

aButtons := { {"RELATORIO", { || QPP020OBSE(nOpc) }, OemToAnsi(STR0007),OemToAnsi(STR0010) } } //"Observacoes"###"Obs"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP20TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

	If lOk
	PPA020Grav(nOpc)
	Endif

DbSelectArea("QKK")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA020Excl� Autor � Robson Ramiro A. Olive� Data � 26/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Exclusao de Operacoes                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA020Excl()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA020Excl(cAlias, nReg, nOpc)

Local oDlg			:= NIL
Local oGet_1		:= NIL
Local oGet_2		:= NIL
Local aButtons		:= {}
Local aPosObj		:= {}
Local oSize			:= NIL

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos

RegToMemory("QKK")

dbSelectArea("QKM")
dbSetOrder(1)

If dbSeek(FwXFilial("QKM")+QKK->QKK_PECA+QKK->QKK_REV)
	Alert (STR0011)//Exclus�o n�o permitida! Esta opera��o j� est� vinculada a um Plano de Controle. Para excluir esta opera��o, ser� necess�rio excluir o plano de controle vinculado.
	return
EndIf

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
oSize := FwDefSize():New()                
oSize:AddObject( "CABECALHO",  100, 30, .T.,.F.)
oSize:AddObject( "GETDADOS" ,  100, 60, .T.,.T.)         
oSize:aMargins := { 3, 3, 3, 3 }
oSize:Process() // Dispara os calculos 

A020Ahead("QKK")
DbSelectArea("QKK")
Set Filter To

nUsado	:= Len(aHeader)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Cadastro de Operacoes"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

aAdd(aPosObj,{oSize:GetDimension('CABECALHO', 'LININI'),oSize:GetDimension('CABECALHO', 'COLINI'),oSize:GetDimension('CABECALHO', 'LINEND'),oSize:GetDimension('CABECALHO', 'COLEND')})
aAdd(aPosObj,{oSize:GetDimension('GETDADOS' , 'LININI'),oSize:GetDimension('GETDADOS' , 'COLINI'),oSize:GetDimension('GETDADOS' , 'LINEND'),oSize:GetDimension('GETDADOS' , 'COLEND')})
		
@ 32,03 SAY TitSX3("QKK_PECA")[1] SIZE 56,07 OF oDlg PIXEL  
@ 33,59 MSGET oGet_1 VAR M->QKK_PECA PICTURE PesqPict("QKK","QKK_PECA") ;
						ReadOnly F3 ConSX3("QKK_PECA");
						SIZE 66,10 OF oDlg PIXEL  

@ 32,131 SAY TitSX3("QKK_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 33,187 MSGET oGet_2 VAR M->QKK_REV PICTURE PesqPict("QKK","QKK_REV") ;
						WHEN .F. ;
					   	SIZE 15,10 OF oDlg PIXEL
					   	
A020Acols(nOpc)

oGet := MSGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4], nOpc,"AllwaysTrue","AllwaysTrue","+QKK_ITEM",.T.)

aButtons := { {"RELATORIO", { || QPP020OBSE(nOpc) }, OemToAnsi(STR0007),OemToAnsi(STR0010) } } //"Observacoes"###"Obs"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| A020Dele(),oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

DbSelectArea("QKK")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � A020Acols� Autor � Robson Ramiro A. Olive� Data � 25/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega vetor aCols para a GetDados                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A020Acols()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A020Acols(nOpc)
Local nI, nPos
Local lQorgplc := GetNewPar("MV_QORGPLC",1)		//Metodo de ordenacao 1-Item / 2-Operacao

//������������������������������������������������������Ŀ
//� Montagem do aCols               					 �
//��������������������������������������������������������

	If nOpc == 3

	aCols := Array(1,nUsado+1)

		For nI = 1 To Len(aHeader)
			If aHeader[nI,8] == "C"
			aCols[1,nI] := Space(aHeader[nI,4])
			ElseIf aHeader[nI,8] == "N"
			aCols[1,nI] := 0
			ElseIf aHeader[nI,8] == "D"
			aCols[1,nI] := dDataBase
			ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
			Else
			aCols[1,nI] := .F.
			EndIf
		Next nI

	nPos			:= aScan(aHeader,{ |x| AllTrim(x[2])== "QKK_ITEM" })
	aCols[1,nPos]	:= StrZero(1,Len(aCols[1,nPos]))
	
	aCols[1,nUsado+1] := .F.	

	Else
	
	DbSelectArea("QKK")
		If lQorgplc == '2'
		DbSetOrder(2)
		Else
		DbSetOrder(1)
		Endif
	DbSeek(xFilial()+M->QKK_PECA+M->QKK_REV)

		Do While QKK->(!Eof()) .and. xFilial() == QKK->QKK_FILIAL .and.;
			 QKK->QKK_PECA+QKK->QKK_REV == M->QKK_PECA+M->QKK_REV
			 	
		aAdd(aCols,Array(nUsado+1))
	
				For nI := 1 to nUsado
   	
				If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
				aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
				Else										// Campo Virtual
				cCpo := AllTrim(Upper(aHeader[nI,2]))
				aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
				Endif
 			
			Next nI
  			
		aCols[Len(aCols),nUsado+1] := .F.
    	
		DbSkip()

		Enddo
		
	Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A020Ahead� Autor � Robson Ramiro A. Olive� Data � 25/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Monta Ahead para aCols                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A020Ahead()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A020Ahead(cAlias)
Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nX

aHeader := {}
nUsado 	:= 0

	For nX := 1 To Len(aStruAlias)
	//��������������������������������������������������
	//�Ignora campos que nao devem aparecer na getdados�
	//��������������������������������������������������
		If 	Upper(AllTrim(aStruAlias[nX,1])) == "QKK_PECA" .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKK_REV"  .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKK_REVINV"
		Loop
			Endif

		If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL")
		nUsado++
 		aAdd(aHeader,{ Trim(QAGetX3Tit(aStruAlias[nX,1])), ;
 						GetSx3Cache(aStruAlias[nX,1], "X3_CAMPO"),   ;
 						GetSx3Cache(aStruAlias[nX,1], "X3_PICTURE"), ;
						GetSx3Cache(aStruAlias[nX,1], "X3_TAMANHO"), ;
						GetSx3Cache(aStruAlias[nX,1], "X3_DECIMAL"), ;
						GetSx3Cache(aStruAlias[nX,1], "X3_VALID"),   ;
						GetSx3Cache(aStruAlias[nX,1], "X3_USADO"),   ;
						GetSx3Cache(aStruAlias[nX,1], "X3_TIPO"),    ;
						GetSx3Cache(aStruAlias[nX,1], "X3_ARQUIVO"), ;
						GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT") })
		Endif
	Next nX

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A020Dele � Autor � Robson Ramiro A Olivei� Data � 25/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Fucao para exclusao de Operacoes                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A020Dele()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function A020Dele()

Local cEspecie 	:= "QPPA020 "  

DbSelectArea("QKK")    
DbSetOrder(1)
DbSeek(xFilial() + M->QKK_PECA + M->QKK_REV)

	Begin Transaction

		Do While QKK->(!Eof()) .and. xFilial() == QKK->QKK_FILIAL	.and.;
		 QKK->QKK_PECA + QKK->QKK_REV == M->QKK_PECA + M->QKK_REV
		 
				If !Empty(QKK->QKK_CHAVE)
		QO_DelTxt(QKK->QKK_CHAVE,cEspecie)    //QPPXFUN
			EndIf

	RecLock("QKK",.F.)
	DbDelete()
	MsUnLock()
	FKCOMMIT()	
	DbSkip()
		
		Enddo

	End Transaction

Return


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA020Grav� Autor � Robson Ramiro A Olivei� Data � 25/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Gravacao das Operacoes - Incl./Alter.          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA020Grav(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Exp1N = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA020Grav(nOpc)

Local nIt
Local nPosDel	:= Len(aHeader) + 1
Local lGraOk	:= .T.
Local nPosNope 	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKK_NOPE" })
Local nPosItem	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKK_ITEM" })
Local cEspecie 	:= "QPPA020 "  
Local lClasNum	:= GetNewPar("MV_QCLASNR",.T.)		//T-Classificao Numerica ou F-Alfanumerica
Local nCpo

DbSelectArea("QKK")
	

	If lClasNum
	aCols := Asort(aCols,,,{|x,y| Val(x[nPosNope]) < Val(y[nPosNope])})	// Ordenacao Numerica do aCols pela Operacao
	Else
	aCols := Asort(aCols,,,{|x,y| x[nPosNope] < y[nPosNope]}) 				// Ordenacao Alfanumerica do aCols pela Operacao
	Endif

	Begin Transaction
		For nIt := 1 To Len(aCols)

			If aCols[nIt, nPosDel]
		DbSetOrder(2)
				If DbSeek(xFilial("QKK")+ M->QKK_PECA + M->QKK_REV + aCols[nIt, nPosNope])
	
					If !Empty(QKK->QKK_CHAVE)
				QO_DelTxt(QKK->QKK_CHAVE,cEspecie)    //QPPXFUN
					EndIf

			RecLock("QKK",.F.)
			QKK->(DbDelete())
			MsUnLock()
				Endif
		DbSetOrder(1)
			Endif
		Next nIt
QKK->(FKCOMMIT())	

		For nIt := 1 To Len(aCols)
	
			If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

				If ALTERA
			DbSetOrder(2)
					If DbSeek(xFilial("QKK")+ M->QKK_PECA + M->QKK_REV + aCols[nIt, nPosNope] )
				RecLock("QKK",.F.)
					Else
				RecLock("QKK",.T.)
					Endif
			DbSetOrder(1)
				Else
			RecLock("QKK",.T.)
				Endif
			
				For nCpo := 1 To Len(aHeader)
					If aHeader[nCpo, 10] <> "V"
				QKK->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
					EndIf
				Next nCpo
                                                                              
		//��������������������������������������������������������������Ŀ
		//� Controle de itens do acols / Chave invertida                 �
		//����������������������������������������������������������������
		QKK->QKK_ITEM   := aCols[nIt, nPosItem]
		QKK->QKK_REVINV := Inverte(M->QKK_REV)


		//��������������������������������������������������������������Ŀ
		//� Dados da Enchoice                                            �
		//����������������������������������������������������������������
		QKK->QKK_FILIAL	:= xFilial("QKK")
		QKK->QKK_PECA	:= M->QKK_PECA
		QKK->QKK_REV 	:= M->QKK_REV
	
		MsUnLock()
			EndIf
		Next nIt
QKK->(FKCOMMIT())
	End Transaction


				
DbSelectArea("QKK")
DbSetOrder(1)

Return lGraOk


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 �QPP020OBSE� Autor � Robson Ramiro A.Olivei� Data � 26.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cadastra Observacoes                        				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QPP020OBSE(ExpN1)                               			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao do mBrowse									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QPPA020													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPP020OBSE(nOpc)

Local cChave  	:= "", cCabec := ""
Local cTitulo 	:= OemToAnsi(STR0007) //"Observacoes"
Local nTamLin 	:= TamSX3("QKO_TEXTO")[1]
Local nPosChave := aScan(aHeader,{ |x| AllTrim(x[2]) == "QKK_CHAVE"  } )
Local cEspecie 	:= "QPPA020 "   //Para gravacao de textos
Local lEdit		:= .F.
Local cInf		:= ""
Local nSaveSX8	:= GetSX8Len()

	If nOpc == 3 .or. nOpc == 4
	lEdit := .T.
	Endif

axTextos	:= {} 	//Vetor que contem os textos dos Produtos
cCabec		:= OemToAnsi(STR0008) //"Texto da Observacao"

//����������������������������������������������������������Ŀ
//� Gera/obtem a chave de ligacao com o texto da Peca/Rv     �
//������������������������������������������������������������

	If Empty(aCols[n,nPosChave])
	cChave := GetSXENum("QKK", "QKK_CHAVE",,4)

		While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
		End

	aCols[n,nPosChave] := cChave
	Else
	cChave := aCols[n,nPosChave]
	EndIf
                                              
cInf := AllTrim(M->QKK_PECA) + " " + M->QKK_REV + STR0009 + StrZero(n,nTamItem) //" Item - "

//����������������������������������������������������������Ŀ
//� Digita a Observacao da Peca    							 �
//������������������������������������������������������������
	If QO_TEXTO(cChave,cEspecie,nTamlin,cTitulo,cInf, @axtextos,1,cCabec,lEdit)
	//����������������������������������������������������������Ŀ
	//� Grava Texto da Peca no QKO							     �
	//������������������������������������������������������������
	QO_GrvTxt(cChave,cEspecie,1,@axTextos) 	//QPPXFUN
	Endif

DbSelectArea("QKK")
DbSetOrder(1)

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PP20LinOk � Autor � Robson Ramiro A. Olive� Data � 26.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para mudanca/inclusao de linhas               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP20LinOk                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QPPA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/                     
Function PP20LinOk

Local nIt
Local nPosDel  := Len(aHeader) + 1                      
Local nPosNope := aScan(aHeader, { |x| AllTrim(x[2]) == "QKK_NOPE" })
Local lRetorno := .T.

//������������������������������������������������������Ŀ
//� verifica se a caracteristica foi preenchida          �
//��������������������������������������������������������

	If Empty(aCols[n,nPosNope]) .and. !aCols[n, nPosDel]
	lRetorno := .F.
	EndIf

	For nIt := 1 To Len(aCols)
		If !aCols[nIt, nPosDel]
			If aCols[nIt, nPosNope] == aCols[n,nPosNope] .and. nIt != n ;
							 .and. !aCols[n, nPosDel]
			lRetorno := .F.
			Help(" ",1,"QPPAOPEXIS")  // Operacao ja existe
				Endif
		Endif
	Next nIt

Return lRetorno

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PP20TudOk � Autor � Robson Ramiro A. Olive� Data � 26.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para inclusao/alteracao geral                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP20TudOk                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QPPA020                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/

Function PP20TudOk

Local lRetorno	:= .T.
Local nIt 		:= 0
Local nTot		:= 0
Local nPosDel  	:= Len(aHeader) + 1                      
Local nPosNope 	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKK_NOPE" })

	For nIt := 1 To Len(aCols)
		If aCols[nIt, nPosDel] .or. Empty(aCols[nIt,nPosNope])
		nTot ++
		Endif

		If !aCols[nIt, nPosDel]
			If aCols[nIt, nPosNope] == aCols[n,nPosNope] .and. nIt != n ;
							 .and. !aCols[n, nPosDel]
			lRetorno := .F.
				Endif
		Endif
	Next nIt

	If !lRetorno
	Help(" ",1,"QPPAOPEXIS")  // Operacao ja existe
	Endif
		
	If Empty(M->QKK_PECA) .or. Empty(M->QKK_REV) .or. nTot == Len(aCols)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
	EndIf

Return lRetorno


/*/
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Funcao    �QPPA020WhNope � Autor � Robson Ramiro A. Olive� Data � 27.07.01 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � When do Campo QKK_NOPE                                         ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPA020WhNope()                                                ���
�����������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                           ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � QPPA020                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
/*/

Function QPPA020WhNope

Local lRetorno	:= .T.
Local nPosChave	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKK_CHAVE" })
Local nPosDESC	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKK_DESC" 	})

	If ALTERA .and. (!Empty(aCols[n, nPosChave]) .or. !Empty(aCols[n, nPosDESC]))
	lRetorno := .F.
	EndIf

Return lRetorno

/*/
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Funcao    �QPPA020SB     � Autor � Robson Ramiro A. Olive� Data � 23.10.01 ���
�����������������������������������������������������������������������������Ĵ��
���Descricao � Atualiza o Simbolo de acordo com a operacao escolhida          ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPA020SB()                                                    ���
�����������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                           ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � QPPA020                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
/*/

Function QPPA020SB

Local lRetorno	:= .T.
Local nPosSBOPE	:= aScan(aHeader, { |x| AllTrim(x[2]) == "QKK_SBOPE" })
Local cCond		:= M->QKK_TPOPE
Local lQP020SIM	:= ExistBlock("QP020SIM")

	Do Case
	Case cCond == "1" ; aCols[n, nPosSBOPE] := "A3"
	Case cCond == "2" ; aCols[n, nPosSBOPE] := "F1"
	Case cCond == "3" ; aCols[n, nPosSBOPE] := "B4"
	Case cCond == "4" ; aCols[n, nPosSBOPE] := "C7"
	Case cCond == "5" ; aCols[n, nPosSBOPE] := "E8"
	Case cCond == "6" ; aCols[n, nPosSBOPE] := "D9"

	Otherwise
		aCols[n, nPosSBOPE] := "  "
	Endcase

	If lQP020SIM
	aCols[n, nPosSBOPE] := ExecBlock("QP020SIM", .F., .F.,{cCond,aCols[n, nPosSBOPE]})
	EndIf

oGet:oBrowse:Refresh()

Return lRetorno
