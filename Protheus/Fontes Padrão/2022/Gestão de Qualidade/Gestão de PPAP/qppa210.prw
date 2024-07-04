#INCLUDE "QPPA210.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QPPA210  � Autor � Robson Ramiro A. Olive� Data � 10.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Aprovacao de Aparencia                                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPA210(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPPAP                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��� Robson Ramiro�25.06.02� META � Inclusao de Campo memo e melhorias     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  , 	0, 1,,.F.},;//"Pesquisar"
					{ OemToAnsi(STR0002), "PPA210Visu", 	0, 2},; 	 //"Visualizar"
					{ OemToAnsi(STR0003), "PPA210Incl", 	0, 3},; 	 //"Incluir"
					{ OemToAnsi(STR0004), "PPA210Alte", 	0, 4},; 	 //"Alterar"
					{ OemToAnsi(STR0005), "PPA210Excl", 	0, 5},; 	 //"Excluir"
					{ OemToAnsi(STR0009), "QPPR210(.T.)", 	0, 6,,.T.} }//"Imprimir"

Return aRotina

Function QPPA210
//���������������������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                                �
//�����������������������������������������������������������������������������
Private cCadastro 	:= OemToAnsi(STR0006) //"Aprovacao de Aparencia"
Private cEspecie	:= "QPPA210 "
Private nTamLin		:= 75
Private cAVAP1		:= ""
Private nEdicao     := Val(GetMv("MV_QPPAPED",.T.,"3"))// Indica a Edicao do PPAP default 3 Edicao
Private aRotina := MenuDef()

DbSelectArea("QK3")    
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"QK3",,,,,,)

Return

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �PPA210Visu  � Autor � Robson Ramiro A.Olivei� Data �10.08.01  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para Visualizacao                                     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void PPA210Visu(ExpC1,ExpN1,ExpN2)                           ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                     ���
���          � ExpN1 = Numero do registro                                   ���
���          � ExpN2 = Numero da opcao                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PPA210Visu(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local aButtons	:= {}
Local oPanel1
Local oPanel2
Local oSize
Local oEnch

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL
Private aRazao  := {}
Private cOutros := ""

DbSelectArea(cAlias)

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize := FwDefSize():New( .F. )

oSize:AddObject( "CIMA"  ,  100,  40, .T., .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "BAIXO",  100, 60, .T., .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  
//��������������������������������������������������������������Ŀ
//� Monta Dialog                                                 �
//����������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ;  //"Aprovacao de Aparencia"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
				
RegToMemory("QK3")						

If !Empty(M->QK3_CHAVE)
	M->QK3_AVAP1 	:= QO_Rectxt(M->QK3_CHAVE,cEspecie,1, nTamLin,"QKO")
	M->QK3_AVAP1 	:= AllTrim(M->QK3_AVAP1)
	cAVAP1			:= M->QK3_AVAP1
Endif

//��������������������������������������������������������������Ŀ
//� Adiciona Panel                                               �
//����������������������������������������������������������������
oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[2,3])

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

//��������������������������������������������������������������Ŀ
//� Monta Enchoice                                               �
//����������������������������������������������������������������
oEnch:=MsMGet():New("QK3",nReg,nOpc,,,,,oSize:aPosObj[1],,,,,,oPanel1,,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
PP210Ahead("QK4")

nUsado	:= Len(aHeader)

PP210Acols(nOpc)

aButtons := { {"BMPVISUAL", { || QPPR210() }, OemToAnsi(STR0008), OemToAnsi(STR0010) }} //"Visualizar/Imprimir"###"Vis/Prn"
If nEdicao == 4
	aAdd(aButtons ,{"AUTOM", { || QPP210RAZA(cAlias,nReg,nOpc,@cOutros)}, STR0013, STR0012})//"Razao p/submissao"###"Razao"                                         
Endif

//��������������������������������������������������������������Ŀ
//� Monta GetDados                                               �
//����������������������������������������������������������������
oGet := MSGetDados():New(90,03,190,332, nOpc,"AllwaysTrue","AllwaysTrue","+QK4_ITEM",.T.,,,,,,,,,oPanel2)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

Return


/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �PPA210Incl  � Autor � Robson Ramiro A.Olivei� Data �23.07.01  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para Inclusao                                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void PPA210Incl(ExpC1,ExpN1,ExpN2)                           ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                     ���
���          � ExpN1 = Numero do registro                                   ���
���          � ExpN2 = Numero da opcao                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PPA210Incl(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local lOk 		:= .F.
Local aButtons	:= {}
Local oPanel1
Local oPanel2
Local oSize
Local oEnch

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL
Private aRazao  := {}
Private cOutros := ""                                    
Private aCpos   := {}

DbSelectArea(cAlias)

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize := FwDefSize():New( .F. )

oSize:AddObject( "CIMA"  ,  100,  40, .T., .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "BAIXO",  100, 60, .T., .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  
//��������������������������������������������������������������Ŀ
//� Monta Dialog                                                 �
//����������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ;  //"Aprovacao de Aparencia"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
					
RegToMemory("QK3",.T.)						

//��������������������������������������������������������������Ŀ
//� Adiciona Panel                                               �
//����������������������������������������������������������������
oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[2,3])

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

//��������������������������������������������������������������Ŀ
//� Monta Enchoice                                               �
//����������������������������������������������������������������
oEnch:=MsMGet():New("QK3",nReg,nOpc, , , ,,oSize:aPosObj[1],,,,,,oPanel1,,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
PP210Ahead("QK4")

nUsado	:= Len(aHeader)

PP210Acols(nOpc)

aButtons := { {"EDIT", { || QPP210APRO(nOpc) }, OemToAnsi(STR0007), OemToAnsi(STR0011)}} //"Aprovar/Limpar"###"Apro/Lim"
If nEdicao == 4
	aAdd(aButtons ,{"AUTOM", { || QPP210RAZA(cAlias,nReg,nOpc,@cOutros)}, STR0013, STR0012})//"Razao p/submissao"###"Razao"                                         
Endif

DbSelectArea("QK4")						

//��������������������������������������������������������������Ŀ
//� Monta GetDados                                               �
//����������������������������������������������������������������
oGet := MSGetDados():New(90,03,190,332, nOpc,"PP210LinOk","PP210TudOk","+QK4_ITEM",.T.,,,,,,,,,oPanel2)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP210TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
	A210Grav(nOpc)
Endif

Return


/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �PPA210Alte  � Autor � Robson Ramiro A.Olivei� Data �10.08.01  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para Alteracao                                        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void PPA210Alte(ExpC1,ExpN1,ExpN2)                           ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                     ���
���          � ExpN1 = Numero do registro                                   ���
���          � ExpN2 = Numero da opcao                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PPA210Alte(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local lOk 		:= .F.
Local aCposAlt	:= {}
Local aButtons	:= {}
Local oPanel1
Local oPanel2
Local oSize
Local oEnch

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL
Private aRazao  := {}
Private cOutros := "" 

If !QPPVldAlt(QK3->QK3_PECA,QK3->QK3_REV,QK3->QK3_ASSFOR)
	Return
Endif

DbSelectArea(cAlias)

aCposAlt := {	"QK3_NIVALT", "QK3_NDESEN"	, "QK3_DTALTE"	,;
				"QK3_LOCALI", "QK3_COMPRA"	, "QK3_ASSFOR"	,;
				"QK3_TELFOR", "QK3_DTAFOR"	, "QK3_ASSCLI"	,;
				"QK3_DTACLI", "QK3_COMENT" 	, "QK3_RAZAO"	,;
				"QK3_AVAP1" }

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize := FwDefSize():New( .F. )

oSize:AddObject( "CIMA"  ,  100,  40, .T., .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "BAIXO",  100, 60, .T., .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  
//��������������������������������������������������������������Ŀ
//� Monta Dialog                                                 �
//����������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ;  //"Aprovacao de Aparencia"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
				
RegToMemory("QK3",.F.)

If !Empty(M->QK3_CHAVE)
	M->QK3_AVAP1 	:= QO_Rectxt(M->QK3_CHAVE,cEspecie,1, nTamLin,"QKO")
	M->QK3_AVAP1 	:= AllTrim(M->QK3_AVAP1)
	cAVAP1			:= M->QK3_AVAP1
Endif

//��������������������������������������������������������������Ŀ
//� Adiciona Panel                                               �
//����������������������������������������������������������������
oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[2,3])

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

//��������������������������������������������������������������Ŀ
//� Monta Enchoice                                               �
//����������������������������������������������������������������
oEnch:=MsMGet():New("QK3",nReg,nOpc,,,,,oSize:aPosObj[1],aCposAlt,,,,,oPanel1,,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
PP210Ahead("QK4")

nUsado	:= Len(aHeader)

PP210Acols(nOpc)

DbSelectArea("QK4")						

aAdd(aButtons ,{"EDIT", { || QPP210APRO(nOpc)}, STR0007, STR0011}) //"Aprovar/Limpar"###"Apro/Lim"
If nEdicao == 4
	aAdd(aButtons ,{"AUTOM", { || QPP210RAZA(cAlias,nReg,nOpc,@cOutros)}, STR0013, STR0012})//"Razao p/submissao"###"Razao"                                         
Endif
    
//��������������������������������������������������������������Ŀ
//� Monta GetDados                                               �
//����������������������������������������������������������������
oGet := MSGetDados():New(90,03,190,332, nOpc,"PP210LinOk","PP210TudOk","+QK4_ITEM",.T.,,,,,,,,,oPanel2)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP210TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
	A210Grav(nOpc)
Endif

Return

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �PPA210Excl  � Autor � Robson Ramiro A.Olivei� Data �10.08.01  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para Exclusao                                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA210Excl(ExpC1,ExpN1,ExpN2)                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                     ���
���          � ExpN1 = Numero do registro                                   ���
���          � ExpN2 = Numero da opcao                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PPA210Excl(cAlias,nReg,nOpc)

Local oDlg		:= NIL
Local aButtons	:= {}
Local oPanel1
Local oPanel2
Local oSize
Local oEnch

Private aHeader	:= {}
Private aCols	:= {}
Private nUsado	:=	0
Private oGet	:= NIL
Private aRazao  := {}
Private cOutros := ""  

If !QPPVldExc(QK3->QK3_REV,QK3->QK3_ASSFOR)
	Return
Endif


DbSelectArea(cAlias)

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize := FwDefSize():New( .F. )

oSize:AddObject( "CIMA"  ,  100,  40, .T., .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "BAIXO",  100, 60, .T., .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  
//��������������������������������������������������������������Ŀ
//� Monta Dialog                                                 �
//����������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ;  //"Aprovacao de Aparencia"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
				
RegToMemory("QK3")						

If !Empty(M->QK3_CHAVE)
	M->QK3_AVAP1 	:= QO_Rectxt(M->QK3_CHAVE,cEspecie,1, nTamLin,"QKO")
	M->QK3_AVAP1 	:= AllTrim(M->QK3_AVAP1)
	cAVAP1			:= M->QK3_AVAP1
Endif

//��������������������������������������������������������������Ŀ
//� Adiciona Panel                                               �
//����������������������������������������������������������������
oPanel1:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[1,3])
oPanel2:= tPanel():New(000,000,,oDlg,,,,,,100,oSize:aPosObj[2,3])

oPanel1:Align := CONTROL_ALIGN_TOP
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT

//��������������������������������������������������������������Ŀ
//� Monta Enchoice                                               �
//����������������������������������������������������������������
oEnch:=MsMGet():New("QK3",nReg,nOpc,,,,,oSize:aPosObj[1],,,,,,oPanel1,,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
PP210Ahead("QK4")

nUsado	:= Len(aHeader)

PP210Acols(nOpc)

aButtons := { {"BMPVISUAL", { || QPPR210() }, OemToAnsi(STR0008), OemToAnsi(STR0010) }} //"Visualizar/Imprimir"###"Vis/Prn"
If nEdicao == 4
	aAdd(aButtons ,{"AUTOM", { || QPP210RAZA(cAlias,nReg,nOpc,@cOutros)}, STR0013, STR0012})//"Razao p/submissao"###"Razao"                                         
Endif

//��������������������������������������������������������������Ŀ
//� Monta GetDados                                               �
//����������������������������������������������������������������
oGet := MSGetDados():New(90,03,190,332, nOpc,"AllwaysTrue","AllwaysTrue","+QK4_ITEM",.T.,,,,,,,,,oPanel2)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| A210Dele(),oDlg:End()},{||oDlg:End()}, , aButtons)CENTERED

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �PP210Acols� Autor � Robson Ramiro A. Olive� Data � 10.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Carrega vetor aCols para a GetDados                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Q010Acols()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PP210Acols(nOpc)
Local nI, nPos
Local aArea := {}

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
			aCols[1,nI] := CtoD(" / / ")
		ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
		Else
			aCols[1,nI] := .F.
		EndIf
	Next nI

	nPos			:= aScan(aHeader,{ |x| AllTrim(x[2])== "QK4_ITEM" })
	aCols[1,nPos]	:= StrZero(1,Len(aCols[1,nPos]))
	
	aCols[1,nUsado+1] := .F.	

Else
	
	DbSelectArea("QK4")    
	DbSetOrder(1)
	DbSeek(xFilial()+QK3->QK3_PECA+QK3->QK3_REV)
	aArea := QK4->(GetArea())

	Do While QK4->(!Eof()) .and. xFilial() == QK3->QK3_FILIAL .and.;
	         QK4->QK4_PECA+QK4->QK4_REV == QK3->QK3_PECA+QK3->QK3_REV

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
	RestArea(aArea)	
Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PP210Ahead� Autor � Robson Ramiro A. Olive� Data � 10.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Monta Ahead para aCols                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP210Ahead()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PP210Ahead(cAlias)

Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nX

aHeader := {}
nUsado 	:= 0

For nX := 1 To Len(aStruAlias)
	//��������������������������������������������������
	//�Ignora campos que nao devem aparecer na getdados�
	//��������������������������������������������������
	If  nEdicao == 4
		If Upper(AllTrim(aStruAlias[nX,1])) == "QK4_PECA" 	.or. ;
			Upper(AllTrim(aStruAlias[nX,1])) == "QK4_REV"
		Loop
		EndIf
	Else
		If  Upper(AllTrim(aStruAlias[nX,1])) == "QK4_PECA" 	.or. ;
			Upper(AllTrim(aStruAlias[nX,1])) == "QK4_BMBAIX".or. ;
			Upper(AllTrim(aStruAlias[nX,1])) == "QK4_BMALTO".or. ;
			Upper(AllTrim(aStruAlias[nX,1])) == "QK4_REV"
			Loop
		Endif
	Endif
	
	If cNivel >= GetSX3Cache(aStruAlias[nX,1],"X3_NIVEL") .And. Alltrim(aStruAlias[nX,1]) <> "QKC_DTENSA"
		nUsado++
 		aAdd(aHeader,{ Trim(QAGetX3Tit(aStruAlias[nX,1])),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_CAMPO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_PICTURE'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_TAMANHO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_DECIMAL'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_VALID'),;              
		              GetSx3Cache(aStruAlias[nX,1],'X3_USADO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_TIPO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_ARQUIVO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_CONTEXT')})
	Endif
Next nX   

Return



/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A210Grav � Autor � Robson Ramiro A Olivei� Data � 10.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Gravacao - Incl./Alter.                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A210Grav(ExpC1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Exp1N = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A210Grav(nOpc)

Local nIt     
Local nCont
Local nNumItem
Local nPosDel 		:= Len(aHeader) + 1
Local nCpo
Local bCampo		:= { |nCPO| Field(nCPO) }
Local lGraOk 		:= .T.   	// Indica se todas as gravacoes obtiveram sucesso
Local cAtividade	:= "11 " 	// Definido no ID - QKZ
Local aAVAP1		:= {}  		// Array para converter o texto
Local nSaveSX8		:= GetSX8Len()

Begin Transaction

// Verifica se existe texto antes de criar chave
If Empty(M->QK3_CHAVE) .and. !Empty(M->QK3_AVAP1)
	M->QK3_CHAVE := GetSXENum("QK3", "QK3_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

Endif

DbSelectArea("QK3")
DbSetOrder(1)

If INCLUI
	RecLock("QK3",.T.)
Else
	RecLock("QK3",.F.)
Endif

For nCont := 1 To FCount()

	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QK3"))
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif

Next nCont

//��������������������������������������������������������������Ŀ
//� Campos nao informados                                        �
//����������������������������������������������������������������
QK3->QK3_REVINV := Inverte(QK3->QK3_REV)

If !Empty(M->QK3_CHAVE)
	aAVAP1 := GeraText(nTamLin, AllTrim(M->QK3_AVAP1))
	QO_GrvTxt(M->QK3_CHAVE,cEspecie,1,@aAVAP1)
Endif

If !Empty(QK3->QK3_DTAFOR) .and. !Empty(QK3->QK3_ASSFOR)
	QPP_CRONO(QK3->QK3_PECA,QK3->QK3_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
Endif

MsUnLock()
FKCOMMIT()

DbSelectArea("QK4")
DbSetOrder(1)

nNumItem := 1  // Contador para os Itens
	
For nIt := 1 To Len(aCols)

	If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

		If ALTERA
		
			If DbSeek(xFilial("QK4")+ M->QK3_PECA + M->QK3_REV + StrZero(nIt,2))
				RecLock("QK4",.F.)
			Else
				RecLock("QK4",.T.)
			Endif
		Else	                   
			RecLock("QK4",.T.)
		Endif
			
		For nCpo := 1 To Len(aHeader)
			If aHeader[nCpo, 10] <> "V"
				QK4->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
			EndIf
		Next nCpo

		//��������������������������������������������������������������Ŀ
		//� Campos Chave nao informados                                  �
		//����������������������������������������������������������������
		QK4->QK4_FILIAL	 := xFilial("QK4")
		QK4->QK4_PECA 	 := M->QK3_PECA
		QK4->QK4_REV 	 := M->QK3_REV
		QK4->QK4_REVINV	 := Inverte(QK3->QK3_REV)
                                                                              
		//��������������������������������������������������������������Ŀ
		//� Controle de itens do acols                                   �
		//����������������������������������������������������������������
		QK4->QK4_ITEM := StrZero(nNumItem,2)

		nNumItem++

		MsUnlock()
		FKCOMMIT()
    Else
   		If DbSeek(xFilial("QK4")+ M->QK3_PECA + M->QK3_REV + StrZero(nIt,2))
			RecLock("QK4",.F.)
			DbDelete()
			MsUnlock()
			FKCOMMIT()
		Endif
	Endif

Next nIt

End Transaction
				
Return lGraOk


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A210Dele � Autor � Robson Ramiro A Olivei� Data � 10.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Exclusao                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A210Dele(ExpC1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Exp1N = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A210Dele()

DbSelectArea("QK4")
DbSetOrder(1)
	
If DbSeek(xFilial("QK4")+ QK3->QK3_PECA + QK3->QK3_REV)

	Do While !Eof() .and. ;
		QK3->QK3_PECA + QK3->QK3_REV == QK4_PECA + QK4_REV
		
		RecLock("QK4",.F.)
		DbDelete()
		MsUnLock()    
		FKCOMMIT()
		
		DbSkip()
		
	Enddo

Endif

DbSelectArea("QK3")

If !Empty(M->QK3_CHAVE)
	QO_DelTxt(M->QK3_CHAVE,cEspecie) //QPPXFUN
Endif

RecLock("QK3",.F.)
DbDelete()
MsUnLock()
FKCOMMIT()
				
Return


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PP210TudOk� Autor � Robson Ramiro A. Olive� Data � 10.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para inclusao/alteracao geral                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP210TudOk                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/

Function PP210TudOk

Local lRetorno	:= .T.
Local nIt 		:= 0
Local nTot		:= 0
Local nPosDel  	:= Len(aHeader) + 1

For nIt := 1 To Len(aCols)
	If aCols[nIt, nPosDel]
		nTot ++
	Endif
Next nIt

If Empty(M->QK3_PECA) .or. Empty(M->QK3_REV) .or. nTot == Len(aCols)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
EndIf

If INCLUI
	If !ExistChav("QK3",M->QK3_PECA+M->QK3_REV)
		lRetorno := .F.
		Help(" ",1,"JAGRAVADO")  // Campo ja Existe
	Endif
	If !ExistCpo("QK1",M->QK3_PECA+M->QK3_REV)
		lRetorno := .F.
		Help(" ",1,"REGNOIS")  // Nao existe amarracao
	Endif
Endif

Return lRetorno

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PP210LinOk� Autor � Robson Ramiro A. Olive� Data � 10.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para linha                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP210LinOk                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/

Function PP210LinOk

Local lRetorno 	:= .F.
Local nPosDel 	:= Len(aHeader) + 1
Local nCpo

If !aCols[n, nPosDel]  // Verifica se o item foi deletado
	For nCpo := 2 To Len(aHeader) // Ignora o Item
		If !Empty(aCols[n, nCpo]) .and. ValType(aCols[n, nCpo]) <> "D"
			lRetorno := .T.
		Endif
	Next nCpo
Else
	lRetorno := .T.
Endif

If !lRetorno
	Help(" ",1,"QPPA210AO1")  // Ao menos 1 campo deve ser preenchido !
Endif

Return lRetorno

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QPP210APRO� Autor � Robson Ramiro A.Olivei� Data � 07.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Aprova                                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPP210APRO(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao do mBrowse									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPP210APRO(nOpc)
                                        
If nOpc == 3 .or. nOpc == 4
	DbSelectArea("QAA")
	DbSetOrder(6)
	If Dbseek(Upper(cUserName))
		M->QK3_DTAFOR  	:= Iif(Empty(M->QK3_DTAFOR), dDataBase, CtoD(" / / "))
		M->QK3_ASSFOR  	:= Iif(Empty(M->QK3_ASSFOR), cUserName, Space(40))
	Else
   		messagedlg(STR0034) //O usu�rio logado n�o est� cadastrado no cadastro de usu�rios do m�dulo, portanto n�o poder� ser o aprovador
	Endif
Endif

Return .T.

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �QPP210Raza  � Autor � Adalberto Mendes Neto � Data �20/04/07  ���
���������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para Selecionar as Razoes de Submissao                ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void PPA210Raza(ExpC1,ExpN1,ExpN2)                           ���
���������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                     ���
���          � ExpN1 = Numero do registro                                   ���
���          � ExpN2 = Numero da opcao                                      ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QPP210Raza(cAlias,nReg,nOpc,cOutros)

Local oDlg
Local oNumPc
Local oOutros
Local oRev
Local oDescrPc
Local oCliente
Local oScrollBox
Local oChk01
Local oChk02
Local oChk03
Local oChk04
Local oChk05
Local oChk06
Local oChk07
Local oChk08
Local oChk09
Local oChk10
Local oChk11
Local oChk12
Local oChk13
Local oChk14
Local oPanel1   
Local nOpca := 2
Local lOk			:= .F.
Local nLin 			:= 0
Local cChave		:= ""       
Local nI := 0                                                      
Local cRaz := ""

Private cK3NumPc   := CriaVar("QK3_PECA")   
Private cK3Rev	   := CriaVar("QK3_REV")
Private aObjetos := {}  
Private lChk01	 := .F.
Private lChk02   := .F.
Private lChk03	 := .F.
Private lChk04   := .F.
Private lChk05	 := .F.
Private lChk06   := .F.
Private lChk07	 := .F.
Private lChk08	 := .F.
Private lChk09	 := .F.
Private lChk10	 := .F.
Private lChk11	 := .F.
Private lChk12	 := .F.
Private lChk13	 := .F.
Private lChk14	 := .F.
Private cMensagem  := "Para marcar a op��o de Raz�o para Submiss�o OUTROS, � obrigat�rio informar qual esta raz�o."
Private cMensagem2 := "Quando � desmarcada a op��o de Raz�o para Submiss�o OUTROS, o texto da raz�o deve ser apagado."
Private cTitulo    := "Raz�o para Submiss�o"
Private lRetorno   := .T.

DbSelectArea("QK3")    
DbSetOrder(1)

If DbSeek(xFilial("QK3")+M->QK3_PECA+M->QK3_REV)
	cK3NumPc   	:= QK3->QK3_PECA
	cK3Rev		:= QK3->QK3_REV               
	Else
	cK3NumPc   	:= M->QK3_PECA
	cK3Rev		:= M->QK3_REV               
Endif

cChave := xFilial("QK3") + cK3NumPc + cK3Rev

//��������������������������������������������������������������Ŀ
//� Inicio da Tela	    										 �
//����������������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM 000,000 TO 345,625 OF oMainWnd PIXEL

SetDlg(oDlg)

RegToMemory("QK3",(nOpc == 3))

DEFINE FONT oFnt NAME "Arial" SIZE 5,15 

@ 018,003 SAY OemToAnsi( STR0023 ) SIZE 040,010 COLOR CLR_HBLUE OF oDlg PIXEL      //Num. Peca
@ 018,035 MSGET oNumPc VAR cK3NumPc ReadOnly SIZE 130,005 OF oDlg PIXEL

If nOpc == 3
	oNumpc:lReadOnly := .T.
	cOutros  := CriaVar("QK3_OUTROS")
Endif

@ 018,173 SAY OemToAnsi( STR0024 ) SIZE 040,010 COLOR CLR_HBLUE OF oDlg PIXEL		  //Revisao
@ 018,199 MSGET oRev VAR cK3Rev SIZE 003,005 OF oDlg PIXEL

@ 038,003 MSPANEL oPanel1 PROMPT "" COLOR CLR_WHITE,CLR_BLACK SIZE 307,010 OF oDlg
@ 001,004 SAY OemToAnsi( STR0021 ) COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL		  //Sim
@ 001,015 SAY OemToAnsi( STR0022 ) COLOR CLR_WHITE SIZE 020,010 OF oPanel1 PIXEL		  //Nao
@ 001,130 SAY OemToAnsi( STR0013 ) COLOR CLR_WHITE SIZE 085,010 OF oPanel1 PIXEL		  //Razoes

oScrollBox := TScrollBox():new(oDlg,053,003, 095,308,.T.,.T.,.T.)


@ 007,006 CHECKBOX oChk01 VAR lChk01	SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk01,( lChk02:=.F.,oChk02:Refresh()), )
@ 007,015 CHECKBOX oChk02 VAR lChk02	SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk02,( lChk01:=.F.,oChk01:Refresh()), )		
@ 007,026 SAY OemToAnsi( STR0014 ) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt
@ 010,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL


@ 019,006 CHECKBOX oChk03 VAR lChk03 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk03,( lChk04:=.F.,oChk04:Refresh()), )
@ 019,015 CHECKBOX oChk04 VAR lChk04 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk04,( lChk03:=.F.,oChk03:Refresh()), )
@ 019,026 SAY OemToAnsi(STR0015) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt
@ 021,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL


@ 030,006 CHECKBOX oChk05 VAR lChk05 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk05,( lChk06:=.F.,oChk06:Refresh()), )
@ 030,015 CHECKBOX oChk06 VAR lChk06 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk06,( lChk05:=.F.,oChk05:Refresh()), )
@ 030,026 SAY OemToAnsi(STR0016) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt
@ 033,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL


@ 042,006 CHECKBOX oChk07 VAR lChk07 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk07,( lChk08:=.F.,oChk08:Refresh()), )                                                                                
@ 042,015 CHECKBOX oChk08 VAR lChk08 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk08,( lChk07:=.F.,oChk07:Refresh()), )   
@ 042,026 SAY OemToAnsi(STR0017) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt
@ 045,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL


@ 054,006 CHECKBOX oChk09 VAR lChk09 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk09,( lChk10:=.F.,oChk10:Refresh()), )
@ 054,015 CHECKBOX oChk10 VAR lChk10 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk10,( lChk09:=.F.,oChk09:Refresh()), )	
@ 054,026 SAY OemToAnsi(STR0018) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt 
@ 057,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL


@ 066,006 CHECKBOX oChk11 VAR lChk11 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk11,( lChk12:=.F.,oChk12:Refresh()), )
@ 066,015 CHECKBOX oChk12 VAR lChk12 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk12,( lChk11:=.F.,oChk11:Refresh()), )
@ 066,026 SAY OemToAnsi(STR0019) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt 
@ 069,003 SAY REPLICATE(OemToAnsi("_"),100) SIZE 292.5,007 OF oScrollBox PIXEL


@ 078,006 CHECKBOX oChk13 VAR lChk13 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk13,( lChk14:=.F.,oChk14:Refresh()), )
@ 078,015 CHECKBOX oChk14 VAR lChk14 SIZE 006,006 OF oScrollBox PIXEL;
			 	 ON CLICK If( lChk14,( lChk13:=.F.,oChk13:Refresh()), )
@ 078,026 SAY OemToAnsi(STR0020) SIZE 260,010 OF oScrollBox PIXEL FONT oFnt   

@ 095,015 MSGET oOutros VAR cOutros  SIZE 280, 010 OF oScrollBox PIXEL

nLin := 95   

@ 002,003 TO nLin,025    	OF oScrollBox PIXEL // Coluna 1
@ 002,003 TO nLin,014.5  	OF oScrollBox PIXEL // Coluna 2
@ 002,003 TO nLin,296		OF oScrollBox PIXEL // Coluna 3

If nOpc == 2 .Or. nOpc == 5
	oNumPc:lReadOnly:= .T.
	oRev:lReadOnly:= .T.
	oChk01:lReadOnly:= .T.
	oChk02:lReadOnly:= .T.
	oChk03:lReadOnly:= .T.
	oChk04:lReadOnly:= .T.
	oChk05:lReadOnly:= .T.
	oChk06:lReadOnly:= .T.
	oChk07:lReadOnly:= .T.
	oChk08:lReadOnly:= .T.
	oChk09:lReadOnly:= .T.
	oChk10:lReadOnly:= .T.
	oChk11:lReadOnly:= .T.
	oChk12:lReadOnly:= .T.
	oChk13:lReadOnly:= .T.
	oChk14:lReadOnly:= .T.	
	oOutros:lReadOnly:= .T.
	SysRefresh()
ElseIf nOpc == 4
	oNumPc:lReadOnly:= .T.
	oRev:lReadOnly:= .T.
	SysRefresh()
EndIf


ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca := 1,cOutros := Alltrim(oOutros:cText),oDlg:End()},{|| nOpca := 2,oDlg:End()}) CENTERED

If nOpca == 1
	If !lChk01
		aAdd(aRazao,"N")
	Else
	    aAdd(aRazao,"S")
	Endif
	
	If !lChk03
		aAdd(aRazao,"N")
	Else
	    aAdd(aRazao,"S")
	Endif

	If !lChk05
		aAdd(aRazao,"N")
	Else
	    aAdd(aRazao,"S")
	Endif
	
	If !lChk07
		aAdd(aRazao,"N")
	Else
	    aAdd(aRazao,"S")
	Endif
	
	If !lChk09
		aAdd(aRazao,"N")
	Else
	    aAdd(aRazao,"S")
	Endif    
	
	If !lChk11
		aAdd(aRazao,"N")
	Else
	    aAdd(aRazao,"S")
	Endif
	
	If !lChk13
		aAdd(aRazao,"N")
	Else
	    aAdd(aRazao,"S")
	Endif                                                              
	
	If !lChk13 	.And. !Empty(cOUTROS)
		MsgInfo(cMensagem2,cTitulo)
		lRetorno:= .F.		
	Endif
	
	If lChk13 	.And. Empty(cOutros) 
	    MsgInfo(cMensagem,cTitulo)
		lRetorno:= .F.		
	Endif
		
Endif

Return (lRetorno)
