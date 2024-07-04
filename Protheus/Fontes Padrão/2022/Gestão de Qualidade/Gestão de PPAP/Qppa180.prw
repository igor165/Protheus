#INCLUDE "QPPA180.CH"
#INCLUDE "PROTHEUS.CH"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QPPA180  � Autor � Robson Ramiro A. Olive� Data � 30.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Ensaios Dimensionais                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPA180(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPPAP                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��� Robson Ramiro�25.07.02�XMeta � Inclusao de Filtro na mBrowse          ���
���              �        �      � Troca da CvKey por GetSXENum()         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := {	{OemToAnsi(STR0001), "AxPesqui", 		0, 1,,.F.},;  	//"Pesquisa"
					{OemToAnsi(STR0002), "PPA180Visu",		0, 2},;			//"Visualiza"
					{OemToAnsi(STR0003), "PPA180Incl",		0, 3},; 		//"Inclui"
					{OemToAnsi(STR0004), "PPA180Alte",		0, 4},; 		//"Altera"
					{OemToAnsi(STR0005), "PPA180Excl",		0, 5},;			//"Exclui"
					{OemToAnsi(STR0012), "QPPR180(.T.)",	0, 6,,.T.},;	//"Imprimir"
					{OemToAnsi(STR0013), "QPPR180V(.T.)", 	0, 7,,.T.}} 	//"Imprimir VDA"

Return aRotina



Function QPPA180


//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Private cFiltro

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������

Private cCadastro 	:= OemToAnsi(STR0006) //"Ensaios Dimensionais"
Private cCondW, cCondS

Private aRotina := MenuDef()

cCondW := "QKB->QKB_PECA+QKB->QKB_REV+QKB->QKB_SEQ == M->QKB_PECA+M->QKB_REV+M->QKB_SEQ"
cCondS := "M->QKB_PECA+M->QKB_REV+M->QKB_SEQ"

DbSelectArea("QKB")
DbSetOrder(1)

cFiltro := "QKB_ITEM == '"+StrZero(1,Len(QKB_ITEM))+"'"

Set Filter To &cFiltro
mBrowse(6,1,22,75,"QKB",,,,,,)
Set Filter To

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA180Visu� Autor � Robson Ramiro A. Olive� Data � 30/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Programa de Visualizacao dos Ensaios Dimensionais          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA180Visu()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA180Visu(cAlias, nReg, nOpc)

Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3	:= NIL
Local oGet_4	:= NIL
Local oGet_5	:= NIL
Local oGet_6	:= NIL
Local aButtons	:= {}

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos

RegToMemory("QKB")

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������

A180Ahead("QKB")
DbSelectArea("QKB")
Set Filter To

nUsado	:= Len(aHeader)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Ensaios Dimensionais"
						FROM 120,000 TO 536,665 OF oMainWnd PIXEL	

@ 35,003 SAY TitSX3("QKB_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ 32,061 MSGET oGet_1 VAR M->QKB_PECA PICTURE PesqPict("QKB","QKB_PECA") ;
						ReadOnly F3 "QPP" SIZE 66,10 OF oDlg PIXEL  

@ 35,131 SAY TitSX3("QKB_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 32,189 MSGET oGet_2 VAR M->QKB_REV PICTURE PesqPict("QKB","QKB_REV") ;
                        WHEN .F.;
					   	SIZE 15,10 OF oDlg PIXEL

@ 35,220 SAY TitSX3("QKB_SEQ")[1] SIZE 56, 7 OF oDlg PIXEL
@ 32,258 MSGET oGet_6 VAR M->QKB_SEQ PICTURE PesqPict("QKB","QKB_SEQ") ;
					WHEN .F.;
					SIZE 15,10 OF oDlg PIXEL

@ 50,003 SAY TitSX3("QKB_LINSP")[1] SIZE 56, 7 OF oDlg PIXEL
@ 48,061 MSGET oGet_3 VAR M->QKB_LINSP PICTURE PesqPict("QKB","QKB_LINSP") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL
					   	
@ 50,131 SAY TitSX3("QKB_ASSFOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ 48,189 MSGET oGet_4 VAR M->QKB_ASSFOR PICTURE PesqPict("QKB","QKB_ASSFOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL					   		

@ 48,258 MSGET oGet_5 VAR M->QKB_DTAPR PICTURE PesqPict("QKB","QKB_DTAPR") ;
						WHEN .F.;
					   	SIZE 33,10 OF oDlg PIXEL					   		
					   	
@ 65,003 SAY TitSX3("QKB_OBSERV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 63,061 MSGET oGet_3 VAR M->QKB_OBSERV PICTURE PesqPict("QKB","QKB_OBSERV") ;
						WHEN .F.;
					   	SIZE 200,10 OF oDlg PIXEL

A180Acols(nOpc)

oGet := MSGetDados():New(80,02,198,333, nOpc,"AllwaysTrue","AllwaysTrue","+QKB_ITEM",.T.)

aButtons := {	{"RELATORIO", 	{ || QPP180RESU(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0014)},;		//"Resultados das Medicoes"###"Result"
				{"BMPVISUAL",  	{ || QPPR180()},			OemToAnsi(STR0011), OemToAnsi(STR0016)} }		//"Visualizar/Imprimir"###"Vis/Prn"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

DbSelectArea("QKB")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.
          

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA180Incl� Autor � Robson Ramiro A. Olive� Data � 30/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Programa de Inclusao dos Ensaios Dimensionais              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPPA180Incl()                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA180Incl(cAlias, nReg, nOpc)

Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3	:= NIL
Local oGet_4	:= NIL
Local oGet_5	:= NIL
Local oGet_6	:= NIL
Local lOk 		:= .F.   
Local aButtons	:= {}
Local nTamGet 	:= QPPTAMGET("QKB_ITEM",1)

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos

RegToMemory("QKB",.T.)

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
A180Ahead("QKB")
DbSelectArea("QKB")
Set Filter To

nUsado	:= Len(aHeader)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Ensaios Dimensionais"
						FROM 120,000 TO 536,665 OF oMainWnd PIXEL	


@ 35,003 SAY TitSX3("QKB_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ 32,061 MSGET oGet_1 VAR M->QKB_PECA PICTURE PesqPict("QKB","QKB_PECA") ;
						Valid NaoVazio().and.QPPA180Valid();
						F3 "QPP" SIZE 66,10 OF oDlg PIXEL  

@ 35,131 SAY TitSX3("QKB_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 32,189 MSGET oGet_2 VAR M->QKB_REV PICTURE PesqPict("QKB","QKB_REV") ;
                        VALID CheckSx3("QKB_REV",M->QKB_REV);
					   	SIZE 15,10 OF oDlg PIXEL

@ 35,220 SAY TitSX3("QKB_SEQ")[1] SIZE 56, 7 OF oDlg PIXEL
@ 32,258 MSGET oGet_6 VAR M->QKB_SEQ PICTURE PesqPict("QKB","QKB_SEQ") ;
 						VALID CheckSx3("QKB_SEQ",M->QKB_SEQ);
					SIZE 15,10 OF oDlg PIXEL


@ 50,003 SAY TitSX3("QKB_LINSP")[1] SIZE 56, 7 OF oDlg PIXEL
@ 48,061 MSGET oGet_3 VAR M->QKB_LINSP PICTURE PesqPict("QKB","QKB_LINSP") ;
					   	SIZE 66,10 OF oDlg PIXEL

					   	
@ 50,131 SAY TitSX3("QKB_ASSFOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ 48,189 MSGET oGet_4 VAR M->QKB_ASSFOR PICTURE PesqPict("QKB","QKB_ASSFOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL					   		

@ 48,258 MSGET oGet_5 VAR M->QKB_DTAPR PICTURE PesqPict("QKB","QKB_DTAPR") ;
						WHEN .F.;
					   	SIZE 33,10 OF oDlg PIXEL					   		

@ 65,003 SAY TitSX3("QKB_OBSERV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 63,061 MSGET oGet_3 VAR M->QKB_OBSERV PICTURE PesqPict("QKB","QKB_OBSERV") ;
					   	SIZE 200,10 OF oDlg PIXEL

A180Acols(nOpc)

oGet := MSGetDados():New(80,02,198,333, nOpc,"PP80LinOk" ,"PP80TudOk","+QKB_ITEM",.T.,,1,,nTamGet)

aButtons := {	{"RELATORIO", 	{ || QPP180RESU(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0014)},;		//"Resultados das Medicoes"###/"Result"
				{"EDIT",  		{ || QPP180APRO(nOpc) },	OemToAnsi(STR0010), OemToAnsi(STR0015) }}		//"Aprovar/Desaprovar"###"Apr/Des"

If ExistBlock("QPA180BT")              
	aButtons := ExecBlock("QPA180BT",.F., .F., {nOpc,aButtons})
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP80TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
    PPA180Grav(nOpc)
Endif

DbSelectArea("QKB")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA180Alte� Autor � Robson Ramiro A. Olive� Data � 30/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Programa de Alteracao dos Ensaios Dimensionais             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA180Alte()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA180Alte(cAlias, nReg, nOpc)

Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3	:= NIL
Local oGet_4	:= NIL
Local oGet_5	:= NIL
Local oGet_6	:= NIL
Local lOk 		:= .F.   
Local aButtons	:= {}
Local nTamGet 	:= QPPTAMGET("QKB_ITEM",1)

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos

If !QPPVldAlt(QKB->QKB_PECA,QKB->QKB_REV,QKB->QKB_ASSFOR)
	Return
Endif


RegToMemory("QKB")

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
A180Ahead("QKB")
DbSelectArea("QKB")
Set Filter To

nUsado	:= Len(aHeader)      

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Ensaios Dimensionais"
						FROM 120,000 TO 516,665 OF oMainWnd PIXEL	

@ 35,003 SAY TitSX3("QKB_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ 32,061 MSGET oGet_1 VAR M->QKB_PECA PICTURE PesqPict("QKB","QKB_PECA") ;
						ReadOnly F3 "QPP" SIZE 66,10 OF oDlg PIXEL

@ 35,131 SAY TitSX3("QKB_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 32,189 MSGET oGet_2 VAR M->QKB_REV PICTURE PesqPict("QKB","QKB_REV") ;
						WHEN .F. ;
					   	SIZE 15,10 OF oDlg PIXEL

@ 35,220 SAY TitSX3("QKB_SEQ")[1] SIZE 56, 7 OF oDlg PIXEL
@ 32,258 MSGET oGet_6 VAR M->QKB_SEQ PICTURE PesqPict("QKB","QKB_SEQ") ;
					WHEN .F.;
					SIZE 15,10 OF oDlg PIXEL

@ 50,003 SAY TitSX3("QKB_LINSP")[1] SIZE 56, 7 OF oDlg PIXEL
@ 48,061 MSGET oGet_3 VAR M->QKB_LINSP PICTURE PesqPict("QKB","QKB_LINSP") ;
					   	SIZE 66,10 OF oDlg PIXEL
					   	
@ 50,131 SAY TitSX3("QKB_ASSFOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ 48,189 MSGET oGet_4 VAR M->QKB_ASSFOR PICTURE PesqPict("QKB","QKB_ASSFOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL

@ 48,258 MSGET oGet_5 VAR M->QKB_DTAPR PICTURE PesqPict("QKB","QKB_DTAPR") ;
						WHEN .F.;
					   	SIZE 33,10 OF oDlg PIXEL

@ 65,003 SAY TitSX3("QKB_OBSERV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 63,061 MSGET oGet_3 VAR M->QKB_OBSERV PICTURE PesqPict("QKB","QKB_OBSERV") ;
					   	SIZE 200,10 OF oDlg PIXEL

A180Acols(nOpc)

oGet := MSGetDados():New(80,02,198,333, nOpc,"PP80LinOk" ,"PP80TudOk","+QKB_ITEM",.T.,,1,,nTamGet)

aButtons := {	{"RELATORIO", 	{ || QPP180RESU(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0014)},;		//"Resultados das Medicoes"###"Result"
				{"EDIT",  		{ || QPP180APRO(nOpc) },	OemToAnsi(STR0010), OemToAnsi(STR0015) }}		//"Aprovar/Desaprovar"###"Apr/Des"

If ExistBlock("QPA180BT")              
	aButtons := ExecBlock("QPA180BT",.F., .F., {nOpc,aButtons})
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP80TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
    PPA180Grav(nOpc)
Endif

DbSelectArea("QKB")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA180Excl� Autor � Robson Ramiro A. Olive� Data � 30/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Exclusao dos Ensaios Dimensionais              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA180Excl()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA180Excl(cAlias, nReg, nOpc)

Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3	:= NIL
Local oGet_4	:= NIL
Local oGet_5	:= NIL
Local oGet_6	:= NIL
Local aButtons	:= {}

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos        

If !QPPVldExc(QKB->QKB_REV,QKB->QKB_ASSFOR)
	Return
Endif


RegToMemory("QKB")

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������

A180Ahead("QKB")
DbSelectArea("QKB")
Set Filter To

nUsado	:= Len(aHeader)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Ensaios Dimensionais"
						FROM 120,000 TO 516,665 OF oMainWnd PIXEL	
				
@ 35,003 SAY TitSX3("QKB_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ 32,061 MSGET oGet_1 VAR M->QKB_PECA PICTURE PesqPict("QKB","QKB_PECA") ;
						ReadOnly F3 "QPP" SIZE 66,10 OF oDlg PIXEL

@ 35,131 SAY TitSX3("QKB_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 32,189 MSGET oGet_2 VAR M->QKB_REV PICTURE PesqPict("QKB","QKB_REV") ;
						WHEN .F. ;
					   	SIZE 15,10 OF oDlg PIXEL

@ 35,220 SAY TitSX3("QKB_SEQ")[1] SIZE 56, 7 OF oDlg PIXEL
@ 32,258 MSGET oGet_6 VAR M->QKB_SEQ PICTURE PesqPict("QKB","QKB_SEQ") ;
					WHEN .F.;
					SIZE 15,10 OF oDlg PIXEL

@ 50,003 SAY TitSX3("QKB_LINSP")[1] SIZE 56, 7 OF oDlg PIXEL
@ 48,061 MSGET oGet_3 VAR M->QKB_LINSP PICTURE PesqPict("QKB","QKB_LINSP") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL
					   	
@ 50,131 SAY TitSX3("QKB_ASSFOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ 48,189 MSGET oGet_4 VAR M->QKB_ASSFOR PICTURE PesqPict("QKB","QKB_ASSFOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL					   		

@ 48,258 MSGET oGet_5 VAR M->QKB_DTAPR PICTURE PesqPict("QKB","QKB_DTAPR") ;
						WHEN .F.;
					   	SIZE 33,10 OF oDlg PIXEL					   		

@ 65,003 SAY TitSX3("QKB_OBSERV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 63,061 MSGET oGet_3 VAR M->QKB_OBSERV PICTURE PesqPict("QKB","QKB_OBSERV") ;
						WHEN .F.;
					   	SIZE 200,10 OF oDlg PIXEL

A180Acols(nOpc)

oGet := MSGetDados():New(80,02,198,333, nOpc,"AllwaysTrue","AllwaysTrue","+QKB_ITEM",.T.)

aButtons := {	{"RELATORIO", 	{ || QPP180RESU(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0014)},;		//"Resultados das Medicoes"###"Result"
				{"BMPVISUAL",  	{ || QPPR180()},			OemToAnsi(STR0011), OemToAnsi(STR0016)} }		//"Visualizar/Imprimir"###"Vis/Prn"

If ExistBlock("QPA180BT")              
	aButtons := ExecBlock("QPA180BT",.F., .F., {nOpc,aButtons})
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| A180Dele(),oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

DbSelectArea("QKB")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A180Acols� Autor � Robson Ramiro A. Olive� Data � 30/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Carrega vetor aCols para a GetDados                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A180Acols()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A180Acols(nOpc)
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
			aCols[1,nI] := dDataBase
		ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
		Else
			aCols[1,nI] := .F.
		EndIf
	Next nI

    nPos            := aScan(aHeader,{ |x| AllTrim(x[2])== "QKB_ITEM" })
	aCols[1,nPos]	:= StrZero(1,Len(aCols[1,nPos]))
	
	aCols[1,nUsado+1] := .F.	

Else
	
    DbSelectArea("QKB")
	DbSetOrder(1)
	DbSeek(xFilial("QKB") + &cCondS)
	aArea := QKB->(GetArea())
	
	Do While QKB->(!Eof()) .and. xFilial("QKB") == QKB->QKB_FILIAL .and. &cCondW
			 	
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
���Funcao    � A180Ahead� Autor � Robson Ramiro A. Olive� Data � 30/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Monta Ahead para aCols                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A180Ahead()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A180Ahead(cAlias)

Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nX

Private nEdicao := Val(GetMv("MV_QPPAPED",.T.,"3"))// Indica a Edicao do PPAP default 3 Edicao

aHeader := {}
nUsado 	:= 0

For nX := 1 To Len(aStruAlias)
	//��������������������������������������������������
	//�Ignora campos que nao devem aparecer na getdados�
	//��������������������������������������������������
	If  Upper(AllTrim(aStruAlias[nX,1])) == "QKB_PECA" 	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKB_REV" 	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKB_REVINV".or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKB_LINSP" .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKB_ASSFOR".or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKB_DTAPR" .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKB_SEQ" 	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKB_OBSERV"
		Loop
	Endif
	
	If nEdicao == 3
		If cNivel >= GetSX3Cache(aStruAlias[nX,1],"X3_NIVEL") .And. Alltrim(aStruAlias[nX,1]) <> "QKB_DTENSA"
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
	Else
		If cNivel >= GetSX3Cache(aStruAlias[nX,1],"X3_NIVEL") .And. Alltrim(aStruAlias[nX,1]) <> "QKB_FTESTE"
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
	Endif	
Next nX 

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A180Dele � Autor � Robson Ramiro A Olivei� Data � 30/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Fucao para exclusao dos Ensaios Dimensionais               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A180Dele()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function A180Dele()

Local cEspecie  := "QPPA180 "

DbSelectArea("QKB")
DbSetOrder(1)
DbSeek(xFilial("QKB") + &cCondS)

Begin Transaction

Do While QKB->(!Eof()) .and. xFilial("QKB") == QKB->QKB_FILIAL .and. &cCondW
		 
    If !Empty(QKB->QKB_CHAVE)
        QO_DelTxt(QKB->QKB_CHAVE,cEspecie)    //QPPXFUN
	EndIf		 

	RecLock("QKB",.F.)
	DbDelete()
	MsUnLock()
		
	DbSkip()
		
Enddo
FKCOMMIT()

End Transaction

Return


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA180Grav� Autor � Robson Ramiro A Olivei� Data � 30/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Gravacao dos Ensaios Dimensionais - Incl./Alter���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA180Grav(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Exp1N = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA180Grav(nOpc)

Local nIt
Local nNumItem
Local nPosDel		:= Len(aHeader) + 1
Local lGraOk		:= .T.
Local cEspecie  	:= "QPPA180 "  
Local cAtividade	:= "08 " // Definido no ID - QKZ
Local nCpo

DbSelectArea("QKB")
DbSetOrder(1)
	
Begin Transaction

nNumItem := 1  // Contador para os Itens
	
For nIt := 1 To Len(aCols)
	
	If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

		If ALTERA
			If DbSeek(xFilial("QKB") + &cCondS + StrZero(nIt,Len(QKB->QKB_ITEM)))
				RecLock("QKB",.F.)
			Else
				RecLock("QKB",.T.)
			Endif
		Else	                   
			RecLock("QKB",.T.)
		Endif
			
		For nCpo := 1 To Len(aHeader)
			If aHeader[nCpo, 10] <> "V"
  				QKB->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
			EndIf
		Next nCpo
                                                                              
		//��������������������������������������������������������������Ŀ
		//� Controle de itens do acols / Chave invertida                 �
		//����������������������������������������������������������������
        QKB->QKB_ITEM   := StrZero(nNumItem,Len(QKB->QKB_ITEM))
        QKB->QKB_REVINV := Inverte(M->QKB_REV)


		//��������������������������������������������������������������Ŀ
		//� Dados da Enchoice                                            �
		//����������������������������������������������������������������
		QKB->QKB_FILIAL	:= xFilial("QKB")
		QKB->QKB_PECA  	:= M->QKB_PECA
		QKB->QKB_REV   	:= M->QKB_REV
		QKB->QKB_ASSFOR	:= M->QKB_ASSFOR
		QKB->QKB_DTAPR 	:= M->QKB_DTAPR
		QKB->QKB_LINSP 	:= M->QKB_LINSP
		QKB->QKB_OBSERV	:= M->QKB_OBSERV
		QKB->QKB_SEQ		:= M->QKB_SEQ
        
		nNumItem++			
	
		MsUnLock()							
	Else
		If DbSeek(xFilial("QKB") + &cCondS + StrZero(nIt,Len(QKB->QKB_ITEM)))
	
			If !Empty(QKB->QKB_CHAVE)
				QO_DelTxt(QKB->QKB_CHAVE,cEspecie)    //QPPXFUN
			EndIf		 

			RecLock("QKB",.F.)
			QKB->(DbDelete())
			MsUnLock()
		Endif
	Endif
	
Next nIt
FKCOMMIT()

End Transaction

If !Empty(QKB->QKB_DTAPR) .and. !Empty(QKB->QKB_ASSFOR)
	QPP_CRONO(QKB->QKB_PECA,QKB->QKB_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
Endif

DbSelectArea("QKB")
DbSetOrder(1)

Return lGraOk


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QPP180RESU� Autor � Robson Ramiro A.Olivei� Data � 30.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cadastra Observacoes                        				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPP180RESU(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao do mBrowse									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPP180RESU(nOpc)

Local cChave  	:= "", cCabec := ""
Local cTitulo 	:= OemToAnsi(STR0007) //"Ensaios Dimensionais"
Local nTamLin 	:= 49
Local nPosChave := aScan(aHeader,{ |x| AllTrim(x[2]) == "QKB_CHAVE"  } )
Local cEspecie  := "QPPA180 "   //Para gravacao de textos
Local lEdit		:= .F.
Local cInf		:= ""
Local nSaveSX8	:= GetSX8Len()

If nOpc == 3 .or. nOpc == 4
	lEdit := .T.
Endif

axTextos	:= {} 	//Vetor que contem os textos dos Produtos
cCabec		:= OemToAnsi(STR0008) //"Resultados das Medicoes"

//����������������������������������������������������������Ŀ
//� Gera/obtem a chave de ligacao com o texto da Peca/Rv     �
//������������������������������������������������������������

If Empty(aCols[n,nPosChave])
	cChave := GetSXENum("QKB", "QKB_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

	aCols[n,nPosChave] := cChave
Else
	cChave := aCols[n,nPosChave]
EndIf
                                              
cInf := AllTrim(M->QKB_PECA) + " " + M->QKB_REV + STR0009 + StrZero(n,Len(QKB->QKB_ITEM)) //" Item - "

//����������������������������������������������������������Ŀ
//� Digita os resultados das medicoes					     �
//������������������������������������������������������������
If QO_TEXTO(cChave,cEspecie,nTamlin,cTitulo,cInf, @axtextos,1,cCabec,lEdit)
	//����������������������������������������������������������Ŀ
	//� Grava Texto da Peca no QKO							     �
	//������������������������������������������������������������
	QO_GrvTxt(cChave,cEspecie,1,@axTextos) 	//QPPXFUN
Endif

DbSelectArea("QKB")
DbSetOrder(1)

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PP80LinOk � Autor � Robson Ramiro A. Olive� Data � 30.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para mudanca/inclusao de linhas               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP80LinOk                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QPPA180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/                     
Function PP80LinOk

Local nPosDel  := Len(aHeader) + 1                      
Local nPosDesc := aScan(aHeader, { |x| AllTrim(x[2]) == "QKB_DESC" })
Local lRetorno := .T.

//������������������������������������������������������Ŀ
//� verifica se a caracteristica foi preenchida          �
//��������������������������������������������������������

If Empty(aCols[n,nPosDesc]) .and. !aCols[n, nPosDel]
	lRetorno := .F.
EndIf
Return lRetorno

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PP80TudOk � Autor � Robson Ramiro A. Olive� Data � 30.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para inclusao/alteracao geral                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP80TudOk                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QPPA180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/

Function PP80TudOk

Local lRetorno	:= .T.
Local nIt 		:= 0
Local nTot		:= 0
Local nPosDel  	:= Len(aHeader) + 1                      
Local nPosDesc  := aScan(aHeader, { |x| AllTrim(x[2]) == "QKB_DESC" })


/*��������������������������������������������������������������������Ŀ
//�Ponto de entrada para consistir obrigatoriedade de campos (enchoice)�
//����������������������������������������������������������������������*/
IF ExistBlock( "PP180CST" )
	lRetorno := ExecBlock( "PP180CST", .F., .F., {M->QKB_LINSP,M->QKB_ASSFOR,M->QKB_DTAPR,M->QKB_OBSERV} )
Endif

For nIt := 1 To Len(aCols)
	If aCols[nIt, nPosDel] .or. Empty(aCols[nIt,nPosDesc])
		nTot ++
	Endif
Next nIt

If Empty(M->QKB_PECA) .or. Empty(M->QKB_REV) .or. nTot == Len(aCols)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
EndIf


Return lRetorno

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QPP180APRO� Autor � Robson Ramiro A.Olivei� Data � 30.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Aprova Medicoes                             				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPP180APRO(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao do mBrowse									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPP180APRO(nOpc)

If nOpc == 3 .or. nOpc == 4 
	DbSelectArea("QAA")
	DbSetOrder(6)
	If Dbseek(Upper(cUserName))
		M->QKB_DTAPR 	:= Iif(Empty(M->QKB_DTAPR) ,dDataBase			 ,CtoD(" / / "))
		M->QKB_ASSFOR 	:= Iif(Empty(M->QKB_ASSFOR),cUserName,Space(40))  
	Else
		messagedlg(STR0017) //"O usu�rio logado n�o est� cadastrado no cadastro de usu�rios do m�dulo, portanto n�o poder� ser o aprovador
	Endif	

Endif

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 �PPA180VLD � Autor � Robson Ramiro A Olivei� Data � 18/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Valida o sequencial para o ensaio                		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � PPA180VLD                               					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QPPA180	  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PPA180Vld

If INCLUI
	M->QKB_SEQ := PPAPSEQ("QKB",M->QKB_SEQ,M->QKB_PECA+M->QKB_REV,1)
	PPAPVld("QKB",M->QKB_PECA+M->QKB_REV+M->QKB_SEQ,1,"QK1",2,2)
Endif

Return .T.   

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �QPPA180Valid �Autor  �Microsiga           � Data �  03/08/05   ���
����������������������������������������������������������������������������͹��
���Desc.     � Chama o VALID do campo, prevendo uma funcao que carregue no   ���
���          � acols. 														 ���
����������������������������������������������������������������������������͹��
���Uso       � QPPA180                                                       ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function QPPA180Valid()
CheckSx3("QKB_REV",M->QKB_REV)
oGet:ForceRefresh()
Return .T.

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �QPA180VTIP   �Autor  �Microsiga           � Data �  03/08/05   ���
����������������������������������������������������������������������������͹��
���Desc.     � Verifica se o tipo da caracteristica � dimensional.           ���
���          �        														 ���
����������������������������������������������������������������������������͹��
���Uso       � QPPA180                                                       ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function QPA180VTIP()

Local lret := .T.   

dbSelectArea("QK2")
dbSetOrder(2)
dbSeek(xFilial("QKB")+M->QKB_PECA+M->QKB_REV+M->QKB_CARAC)
If QK2_TPCAR <> "1"	
	MsgAlert("Esta caracteristica n�o � do tipo dimensional","Aviso")
	lRet := .F.
EndIf  

Return (lRet)
  

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �TextoQPC()   �Autor  �Rafael Duram Santos � Data �  11/06/12   ���
����������������������������������������������������������������������������͹��
���Desc.     � Monta texto da peca de forma dinamica aproveitando o maximo   ���
���		     � do tamanho disponivel no campo de descricao do ensaio         ���
����������������������������������������������������������������������������͹��
���Uso       � QPPA180                                                       ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function TextoQPC()

Local nTamDescE	:= TamSx3("QKB_DESC")[1]
Local nTamDescP := Len(Alltrim(QK2->QK2_DESC))
Local nTamEspec := Len(Alltrim(QK2->QK2_ESPE))
Local nTamUnMed := Len(Alltrim(QK2->QK2_UM))
Local cRetorno	:= ""
Local cDiv		:= " - "
Local nUsoDescP := nTamDescP
Local nUsoEspec := nTamEspec
Local nDivisao	:= 0

If (nTamDescP+nTamEspec+nTamUnMed+2*(Len(cDiv))) > nTamDescE
	nDivisao := Noround(((nTamDescE - (nTamUnMed+(2*Len(cDiv)))) / 2),0 )
	If nTamDescP > nDivisao .And. nTamEspec > nDivisao
		nUsoDescP := nDivisao
		nUsoEspec := nDivisao + ((nTamDescE - (nTamUnMed+(2*Len(cDiv)))) % 2) 
	Elseif nTamDescP > nDivisao
		nUsoDescP := nTamDescE - (nTamEspec+nTamUnMed+2*(Len(cDiv)))
	Elseif	nTamEspec > nDivisao
		nUsoEspec := nTamDescE - (nTamDescP+nTamUnMed+2*(Len(cDiv)))
	Endif	
Endif

cRetorno := ALLTRIM(SUBS(QK2->QK2_DESC,1,nUsoDescP))+" - "
cRetorno += ALLTRIM(SUBS(QK2->QK2_ESPE,1,nUsoEspec))+" - "+QK2->QK2_UM
  
Return cRetorno