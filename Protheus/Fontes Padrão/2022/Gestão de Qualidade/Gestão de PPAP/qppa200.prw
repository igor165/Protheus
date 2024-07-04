#INCLUDE "QPPA200.CH"
#INCLUDE "PROTHEUS.CH"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QPPA200  � Autor � Robson Ramiro A. Olive� Data � 01.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Ensaios de Desempenho                                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPA200(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPPAP                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��� Robson Ramiro�26.07.02�XMeta � Inclusao de Filtro na mBrowse          ���
���              �        �      � Troca da CvKey por GetSXENum()         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local aRotina := {	{OemToAnsi(STR0001), "AxPesqui"   , 	0, 1,,.F.},;//"Pesquisa"
					{OemToAnsi(STR0002), "PPA200Visu" , 	0, 2},;		 //"Visualiza"
					{OemToAnsi(STR0003), "PPA200Incl" , 	0, 3},;		 //"Inclui"
					{OemToAnsi(STR0004), "PPA200Alte" , 	0, 4},; 	 //"Altera"
					{OemToAnsi(STR0005), "PPA200Excl" , 	0, 5},;		 //"Exclui"
					{OemToAnsi(STR0012), "QPPR200(.T.)", 	0, 6,,.T.},;//"Imprimir"
					{OemToAnsi(STR0013), "QPPR200V(.T.)", 	0, 7,,.T.} }//"Imprimir VDA"

Return aRotina

Function QPPA200

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Private cFiltro

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������

Private cCadastro 	:= OemToAnsi(STR0006) //"Ensaios de Desempenho"
Private cCondW, cCondS
Private aRotina := MenuDef()

cCondW := "QKC->QKC_PECA+QKC->QKC_REV+QKC->QKC_SEQ == M->QKC_PECA+M->QKC_REV+M->QKC_SEQ"
cCondS := "M->QKC_PECA+M->QKC_REV+M->QKC_SEQ"

DbSelectArea("QKC")
DbSetOrder(1)

cFiltro := "QKC_ITEM == '"+StrZero(1,Len(QKC_ITEM))+"'"

Set Filter To &cFiltro
mBrowse(6,1,22,75,"QKC",,,,,,)
Set Filter To

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA200Visu� Autor � Robson Ramiro A. Olive� Data � 01/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Programa de Visualizacao dos Ensaios de Desempenho         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA200Visu()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA200Visu(cAlias, nReg, nOpc)

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

RegToMemory("QKC")

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������

A200Ahead("QKC")
DbSelectArea("QKC")
Set Filter To

nUsado	:= Len(aHeader)

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"     ,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "FORMULARIO"   ,  100, 70, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 5, 5, 5, 5 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Ensaios de Desempenho"
												FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL


@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_1 VAR M->QKC_PECA PICTURE PesqPict("QKC","QKC_PECA") ;
                        WHEN .F.;
						F3 "QPP" SIZE 66,10 OF oDlg PIXEL  

@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI")+125 SAY TitSX3("QKC_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+178 MSGET oGet_2 VAR M->QKC_REV PICTURE PesqPict("QKC","QKC_REV") ;
					WHEN .F.;
					SIZE 15,10 OF oDlg PIXEL
					   	
@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI")+220 SAY TitSX3("QKC_SEQ")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+255 MSGET oGet_6 VAR M->QKC_SEQ PICTURE PesqPict("QKC","QKC_SEQ") ;
						WHEN .F.;
						SIZE 15,10 OF oDlg PIXEL
					   	
@ oSize:GetDimension("ENCHOICE","LININI")+15,oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_LABOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_3 VAR M->QKC_LABOR PICTURE PesqPict("QKC","QKC_LABOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL					   		

@ oSize:GetDimension("ENCHOICE","LININI")+15,oSize:GetDimension("ENCHOICE","COLINI")+127 SAY TitSX3("QKC_ASSFOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+178 MSGET oGet_4 VAR M->QKC_ASSFOR PICTURE PesqPict("QKC","QKC_ASSFOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL					   		

@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+256 MSGET oGet_5 VAR M->QKC_DTAPR PICTURE PesqPict("QKC","QKC_DTAPR") ;
						WHEN .F.;
					   	SIZE 33,10 OF oDlg PIXEL					   		

@ oSize:GetDimension("ENCHOICE","LININI")+30,oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_OBSERV")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+28,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_3 VAR M->QKC_OBSERV PICTURE PesqPict("QKC","QKC_OBSERV") ;
						WHEN .F.;
					   	SIZE 200,10 OF oDlg PIXEL
					   	
A200Acols(nOpc)

oGet := MSGetDados():New(oSize:GetDimension("FORMULARIO","LININI"),;
							oSize:GetDimension("FORMULARIO","COLINI"),;
							oSize:GetDimension("FORMULARIO","LINEND"),;
							oSize:GetDimension("FORMULARIO","COLEND"),;
							nOpc,"AllwaysTrue","AllwaysTrue","+QKC_ITEM",.T.)

aButtons := {	{"RELATORIO", 	{ || QPP200RESU(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0014)},;		//"Resultados das Medicoes"###"Result"
				{"BMPVISUAL",  	{ || QPPR200()},			OemToAnsi(STR0011), OemToAnsi(STR0016)} }		//"Visualizar/Imprimir"###"Vis/Prn"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

DbSelectArea("QKC")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.
          

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA200Incl� Autor � Robson Ramiro A. Olive� Data � 01/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Programa de Inclusao dos Ensaios de Desempenho             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPPA200Incl()                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA200Incl(cAlias, nReg, nOpc)

Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3	:= NIL
Local oGet_4	:= NIL
Local oGet_5	:= NIL
Local oGet_6	:= NIL
Local lOk 		:= .F.   
Local aButtons	:= {}
Local nTamGet 	:= QPPTAMGET("QKC_ITEM",1)

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos

RegToMemory("QKC",.T.)

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"     ,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "FORMULARIO"   ,  100, 70, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 5, 5, 5, 5 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
A200Ahead("QKC")
DbSelectArea("QKC")
Set Filter To 

nUsado	:= Len(aHeader)      

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Ensaios de Desempenho"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL


@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_1 VAR M->QKC_PECA PICTURE PesqPict("QKC","QKC_PECA") ;
						Valid NaoVazio() .AND. QPPA200Valid() ;
						F3 "QPP" SIZE 66,10 OF oDlg PIXEL  

@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI")+125 SAY TitSX3("QKC_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+178 MSGET oGet_2 VAR M->QKC_REV PICTURE PesqPict("QKC","QKC_REV") ;
                        VALID CheckSx3("QKC_REV",M->QKC_REV);
					   	SIZE 15,10 OF oDlg PIXEL

@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI")+220 SAY TitSX3("QKC_SEQ")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+255 MSGET oGet_6 VAR M->QKC_SEQ PICTURE PesqPict("QKC","QKC_SEQ") ;
 						VALID CheckSx3("QKC_SEQ",M->QKC_SEQ);
					SIZE 15,10 OF oDlg PIXEL
					   	
@ oSize:GetDimension("ENCHOICE","LININI")+15,oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_LABOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_3 VAR M->QKC_LABOR PICTURE PesqPict("QKC","QKC_LABOR") ;
					   	SIZE 66,10 OF oDlg PIXEL
					   	
@ oSize:GetDimension("ENCHOICE","LININI")+15,oSize:GetDimension("ENCHOICE","COLINI")+127 SAY TitSX3("QKC_ASSFOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+178 MSGET oGet_4 VAR M->QKC_ASSFOR PICTURE PesqPict("QKC","QKC_ASSFOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL					   		

@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+256 MSGET oGet_5 VAR M->QKC_DTAPR PICTURE PesqPict("QKC","QKC_DTAPR") ;
						WHEN .F.;
					   	SIZE 33,10 OF oDlg PIXEL					   		

@ oSize:GetDimension("ENCHOICE","LININI")+30,oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_OBSERV")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+28,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_3 VAR M->QKC_OBSERV PICTURE PesqPict("QKC","QKC_OBSERV") ;
					   	SIZE 200,10 OF oDlg PIXEL


A200Acols(nOpc)

oGet := MSGetDados():New(oSize:GetDimension("FORMULARIO","LININI"),;
							oSize:GetDimension("FORMULARIO","COLINI"),;
							oSize:GetDimension("FORMULARIO","LINEND"),;
							oSize:GetDimension("FORMULARIO","COLEND"),;
							nOpc,"PP200LinOk" ,"PP200TudOk","+QKC_ITEM",.T.,,1,,nTamGet)

aButtons := {	{"RELATORIO", 	{ || QPP200RESU(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0014)},;		//"Resultados das Medicoes"###/"Result"
				{"EDIT",  		{ || QPP200APRO(nOpc) },	OemToAnsi(STR0010), OemToAnsi(STR0015) }}		//"Aprovar/Desaprovar"###"Apr/Des"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP200TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
	PPA200Grav(nOpc)
Endif

DbSelectArea("QKC")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA200Alte� Autor � Robson Ramiro A. Olive� Data � 01/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Programa de Alteracao dos Ensaios de Desempenho            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA200Alte()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA200Alte(cAlias, nReg, nOpc)

Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3	:= NIL
Local oGet_4	:= NIL
Local oGet_5	:= NIL
Local oGet_6	:= NIL
Local lOk 		:= .F.   
Local aButtons	:= {}
Local nTamGet 	:= QPPTAMGET("QKC_ITEM",1)

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos

If !QPPVldAlt(QKC->QKC_PECA,QKC->QKC_REV,QKC->QKC_ASSFOR)
	Return
Endif

RegToMemory("QKC")

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"     ,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "FORMULARIO"   ,  100, 70, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 5, 5, 5, 5 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
A200Ahead("QKC")
DbSelectArea("QKC")
Set Filter To

nUsado	:= Len(aHeader)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Ensaios de Desempenho"
				FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL


@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_1 VAR M->QKC_PECA PICTURE PesqPict("QKC","QKC_PECA") ;
						Valid NaoVazio() .AND. QPPA200Valid() WHEN .F. ;
						F3 "QPP" SIZE 66,10 OF oDlg PIXEL  

@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI")+125 SAY TitSX3("QKC_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+178 MSGET oGet_2 VAR M->QKC_REV PICTURE PesqPict("QKC","QKC_REV") ;
                        VALID CheckSx3("QKC_REV",M->QKC_REV) WHEN .F.;
					   	SIZE 15,10 OF oDlg PIXEL

@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI")+220 SAY TitSX3("QKC_SEQ")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+255 MSGET oGet_6 VAR M->QKC_SEQ PICTURE PesqPict("QKC","QKC_SEQ") ;
 						VALID CheckSx3("QKC_SEQ",M->QKC_SEQ) WHEN .F.;
					SIZE 15,10 OF oDlg PIXEL

@ oSize:GetDimension("ENCHOICE","LININI")+15,oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_LABOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_3 VAR M->QKC_LABOR PICTURE PesqPict("QKC","QKC_LABOR") ;
					   	SIZE 66,10 OF oDlg PIXEL
					   	
@ oSize:GetDimension("ENCHOICE","LININI")+15,oSize:GetDimension("ENCHOICE","COLINI")+127 SAY TitSX3("QKC_ASSFOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+178 MSGET oGet_4 VAR M->QKC_ASSFOR PICTURE PesqPict("QKC","QKC_ASSFOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL

@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+256 MSGET oGet_5 VAR M->QKC_DTAPR PICTURE PesqPict("QKC","QKC_DTAPR") ;
						WHEN .F.;
					   	SIZE 33,10 OF oDlg PIXEL

@ oSize:GetDimension("ENCHOICE","LININI")+30,oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_OBSERV")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+28,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_3 VAR M->QKC_OBSERV PICTURE PesqPict("QKC","QKC_OBSERV") ;
					   	SIZE 200,10 OF oDlg PIXEL
		   		
A200Acols(nOpc)

oGet := MSGetDados():New(oSize:GetDimension("FORMULARIO","LININI"),;
							oSize:GetDimension("FORMULARIO","COLINI"),;
							oSize:GetDimension("FORMULARIO","LINEND"),;
							oSize:GetDimension("FORMULARIO","COLEND"),;
							nOpc,"PP200LinOk" ,"PP200TudOk","+QKC_ITEM",.T.,,1,,nTamGet)

aButtons := {	{"RELATORIO", 	{ || QPP200RESU(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0014)},;		//"Resultados das Medicoes"###"Result"
				{"EDIT",  		{ || QPP200APRO(nOpc) },	OemToAnsi(STR0010), OemToAnsi(STR0015) }}		//"Aprovar/Desaprovar"###"Apr/Des"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP200TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
	PPA200Grav(nOpc)
Endif

DbSelectArea("QKC")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA200Excl� Autor � Robson Ramiro A. Olive� Data � 01/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Exclusao dos Ensaios de Desempenho             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA200Excl()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA200Excl(cAlias, nReg, nOpc)

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

If !QPPVldExc(QKC->QKC_REV,QKC->QKC_ASSFOR)
	Return
Endif


RegToMemory("QKC")

//��������������������������������������������������������������Ŀ
//� Calcula dimens�es                                            �
//����������������������������������������������������������������
oSize := FwDefSize():New()

oSize:AddObject( "ENCHOICE"     ,  100, 30, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "FORMULARIO"   ,  100, 70, .T., .T. ) // Totalmente dimensionavel

oSize:lProp := .T. // Proporcional             
oSize:aMargins := { 5, 5, 5, 5 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos  

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
A200Ahead("QKC")
DbSelectArea("QKC")
Set Filter To

nUsado	:= Len(aHeader)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Ensaios de Desempenho"
												FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL


@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_1 VAR M->QKC_PECA PICTURE PesqPict("QKC","QKC_PECA") ;
						Valid NaoVazio() .AND. QPPA200Valid() WHEN .F.;
						F3 "QPP" SIZE 66,10 OF oDlg PIXEL  

@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI")+125 SAY TitSX3("QKC_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+178 MSGET oGet_2 VAR M->QKC_REV PICTURE PesqPict("QKC","QKC_REV") ;
                        VALID CheckSx3("QKC_REV",M->QKC_REV) WHEN .F.;
					   	SIZE 15,10 OF oDlg PIXEL

@ oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI")+220 SAY TitSX3("QKC_SEQ")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")-2,oSize:GetDimension("ENCHOICE","COLINI")+255 MSGET oGet_6 VAR M->QKC_SEQ PICTURE PesqPict("QKC","QKC_SEQ") ;
 						VALID CheckSx3("QKC_SEQ",M->QKC_SEQ) WHEN .F.;
					SIZE 15,10 OF oDlg PIXEL

@ oSize:GetDimension("ENCHOICE","LININI")+15,oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_LABOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_3 VAR M->QKC_LABOR PICTURE PesqPict("QKC","QKC_LABOR") ;
					   	SIZE 66,10 WHEN .F. OF oDlg PIXEL
					   	
@ oSize:GetDimension("ENCHOICE","LININI")+15,oSize:GetDimension("ENCHOICE","COLINI")+127 SAY TitSX3("QKC_ASSFOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+178 MSGET oGet_4 VAR M->QKC_ASSFOR PICTURE PesqPict("QKC","QKC_ASSFOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL
					   	
@ oSize:GetDimension("ENCHOICE","LININI")+12,oSize:GetDimension("ENCHOICE","COLINI")+256 MSGET oGet_5 VAR M->QKC_DTAPR PICTURE PesqPict("QKC","QKC_DTAPR") ;
						WHEN .F.;
					   	SIZE 33,10 OF oDlg PIXEL					   		

@ oSize:GetDimension("ENCHOICE","LININI")+30,oSize:GetDimension("ENCHOICE","COLINI") SAY TitSX3("QKC_OBSERV")[1] SIZE 56, 7 OF oDlg PIXEL
@ oSize:GetDimension("ENCHOICE","LININI")+28,oSize:GetDimension("ENCHOICE","COLINI")+50 MSGET oGet_3 VAR M->QKC_OBSERV PICTURE PesqPict("QKC","QKC_OBSERV") ;
					   	WHEN .F. SIZE 200,10 OF oDlg PIXEL
					   	
A200Acols(nOpc)

oGet := MSGetDados():New(oSize:GetDimension("FORMULARIO","LININI"),;
							oSize:GetDimension("FORMULARIO","COLINI"),;
							oSize:GetDimension("FORMULARIO","LINEND"),;
							oSize:GetDimension("FORMULARIO","COLEND"),;
							nOpc,"AllwaysTrue","AllwaysTrue","+QKC_ITEM",.T.)

aButtons := {	{"RELATORIO", 	{ || QPP200RESU(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0014)},;		//"Resultados das Medicoes"###"Result"
				{"BMPVISUAL",  	{ || QPPR200()},			OemToAnsi(STR0011), OemToAnsi(STR0016)} }		//"Visualizar/Imprimir"###"Vis/Prn"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| A200Dele(),oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

DbSelectArea("QKC")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A200Acols� Autor � Robson Ramiro A. Olive� Data � 01/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Carrega vetor aCols para a GetDados                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A200Acols()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A200Acols(nOpc)
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

    nPos            := aScan(aHeader,{ |x| AllTrim(x[2])== "QKC_ITEM" })
	aCols[1,nPos]	:= StrZero(1,Len(aCols[1,nPos]))
	
	aCols[1,nUsado+1] := .F.	

Else
	
    DbSelectArea("QKC")
	DbSetOrder(1)
	DbSeek(xFilial("QKC") + &cCondS)
	aArea := QKC->(GetArea())
	
	Do While QKC->(!Eof()) .and. xFilial("QKC") == QKC->QKC_FILIAL .and. &cCondW
			 	
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
���Funcao    � A200Ahead� Autor � Robson Ramiro A. Olive� Data � 01/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Monta Ahead para aCols                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A200Ahead()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A200Ahead(cAlias)

Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nX

Private nEdicao := Val(GetMv("MV_QPPAPED",.T.,"3"))// Indica a Edicao do PPAP default 3 Edicao

aHeader := {}
nUsado 	:= 0

For nX := 1 To Len(aStruAlias)
	//��������������������������������������������������
	//�Ignora campos que nao devem aparecer na getdados�
	//��������������������������������������������������
	If  Upper(AllTrim(aStruAlias[nX,1])) == "QKC_PECA" 	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKC_REV" 	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKC_REVINV".or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKC_LABOR" .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKC_ASSFOR".or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKC_DTAPR" .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKC_OBSERV".or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKC_SEQ"
		Loop
	Endif
	
	If nEdicao == 3
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
	Else
		If cNivel >= GetSX3Cache(aStruAlias[nX,1],"X3_NIVEL") .And. Alltrim(aStruAlias[nX,1]) <> "QKC_FTESTE"
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
���Funcao    � A200Dele � Autor � Robson Ramiro A Olivei� Data � 01/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Fucao para exclusao dos Ensaios de Desempenho              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A200Dele()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function A200Dele()

Local cEspecie  := "QPPA200 "

DbSelectArea("QKC")
DbSetOrder(1)
DbSeek(xFilial("QKC") + &cCondS)

Begin Transaction

Do While QKC->(!Eof()) .and. xFilial("QKC") == QKC->QKC_FILIAL .and. &cCondW

		 
    If !Empty(QKC->QKC_CHAVE)
        QO_DelTxt(QKC->QKC_CHAVE,cEspecie)    //QPPXFUN
	EndIf		 

    RecLock("QKC",.F.)
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
���Funcao    �PPA200Grav� Autor � Robson Ramiro A Olivei� Data � 01/08/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Gravacao dos Ensaios de Desempenho - Incl/Alter���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA200Grav(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Exp1N = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA200Grav(nOpc)

Local nIt
Local nNumItem
Local nPosDel		:= Len(aHeader) + 1
Local lGraOk		:= .T.
Local cEspecie  	:= "QPPA200 "
Local cAtividade	:= "10 " // Definido no ID - QKZ
Local nCpo

DbSelectArea("QKC")
DbSetOrder(1)
	
Begin Transaction

nNumItem := 1  // Contador para os Itens
	
For nIt := 1 To Len(aCols)
	
	If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

		If ALTERA
			If DbSeek(xFilial("QKC") + &cCondS + StrZero(nIt,Len(QKC->QKC_ITEM)))
                RecLock("QKC",.F.)
			Else
                RecLock("QKC",.T.)
			Endif
		Else	                   
            RecLock("QKC",.T.)
		Endif
			
		For nCpo := 1 To Len(aHeader)
			If aHeader[nCpo, 10] <> "V"
                QKC->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
			EndIf
		Next nCpo
                                                                              
		//��������������������������������������������������������������Ŀ
		//� Controle de itens do acols / Chave invertida                 �
		//����������������������������������������������������������������
        QKC->QKC_ITEM   := StrZero(nNumItem,Len(QKC->QKC_ITEM))
        QKC->QKC_REVINV := Inverte(M->QKC_REV)


		//��������������������������������������������������������������Ŀ
		//� Dados da Enchoice                                            �
		//����������������������������������������������������������������
        QKC->QKC_FILIAL	:= xFilial("QKC")
        QKC->QKC_PECA  	:= M->QKC_PECA
        QKC->QKC_REV   	:= M->QKC_REV
        QKC->QKC_ASSFOR	:= M->QKC_ASSFOR
        QKC->QKC_DTAPR 	:= M->QKC_DTAPR
        QKC->QKC_LABOR 	:= M->QKC_LABOR
		QKC->QKC_OBSERV	:= M->QKC_OBSERV
		QKC->QKC_SEQ		:= M->QKC_SEQ
		        
		nNumItem++			
	
		MsUnLock()					
	Else
		If DbSeek(xFilial("QKC") + &cCondS + StrZero(nIt,Len(QKC->QKC_ITEM)))
	
            If !Empty(QKC->QKC_CHAVE)
                QO_DelTxt(QKC->QKC_CHAVE,cEspecie)    //QPPXFUN
			EndIf		 

            RecLock("QKC",.F.)
            QKC->(DbDelete())
		Endif
	Endif
	
Next nIt
FKCOMMIT()
End Transaction

If !Empty(QKC->QKC_DTAPR) .and. !Empty(QKC->QKC_ASSFOR)
	QPP_CRONO(QKC->QKC_PECA,QKC->QKC_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
Endif
				
DbSelectArea("QKC")
DbSetOrder(1)

Return lGraOk


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QPP200RESU� Autor � Robson Ramiro A.Olivei� Data � 01.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cadastra Observacoes                        				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPP200RESU(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao do mBrowse									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPP200RESU(nOpc)

Local cChave  	:= "", cCabec := ""
Local cTitulo   := OemToAnsi(STR0007) //"Ensaios de Desempenho"
Local nTamLin 	:= 43
Local nPosChave := aScan(aHeader,{ |x| AllTrim(x[2]) == "QKC_CHAVE"  } )
Local cEspecie  := "QPPA200 "   //Para gravacao de textos
Local lEdit		:= .F.
Local cInf		:= ""
Local nSaveSX8	:= GetSX8Len()

If nOpc == 3 .or. nOpc == 4
	lEdit := .T.
Endif

axTextos	:= {} 	//Vetor que contem os textos dos Produtos
cCabec      := OemToAnsi(STR0008) //"Resultados dos Ensaios"

//����������������������������������������������������������Ŀ
//� Gera/obtem a chave de ligacao com o texto da Peca/Rv     �
//������������������������������������������������������������

If Empty(aCols[n,nPosChave])
	cChave := GetSXENum("QKC", "QKC_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

	aCols[n,nPosChave] := cChave
Else
	cChave := aCols[n,nPosChave]
EndIf
                                              
cInf := AllTrim(M->QKC_PECA) + " " + M->QKC_REV + STR0009 + StrZero(n,Len(QKC->QKC_ITEM)) //" Item - "

//����������������������������������������������������������Ŀ
//� Digita os resultados dos Ensaios                         �
//������������������������������������������������������������
If QO_TEXTO(cChave,cEspecie,nTamlin,cTitulo,cInf, @axtextos,1,cCabec,lEdit)
	//����������������������������������������������������������Ŀ
	//� Grava Texto dos ensaios no QKO						     �
	//������������������������������������������������������������
	QO_GrvTxt(cChave,cEspecie,1,@axTextos) 	//QPPXFUN
Endif

DbSelectArea("QKC")
DbSetOrder(1)

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PP200LinOk� Autor � Robson Ramiro A. Olive� Data � 01.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para mudanca/inclusao de linhas               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP200LinOk                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QPPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/                     
Function PP200LinOk

Local nPosDel  := Len(aHeader) + 1
Local nPosDesc := aScan(aHeader, { |x| AllTrim(x[2]) == "QKC_DESC" })
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
���Fun��o    �PP200TudOk� Autor � Robson Ramiro A. Olive� Data � 01.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para inclusao/alteracao geral                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP200TudOk                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QPPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/

Function PP200TudOk

Local lRetorno	:= .T.
Local nIt 		:= 0
Local nTot		:= 0
Local nPosDel  	:= Len(aHeader) + 1                      
Local nPosDesc  := aScan(aHeader, { |x| AllTrim(x[2]) == "QKC_DESC" })

/*��������������������������������������������������������������������Ŀ
//�Ponto de entrada para consistir obrigatoriedade de campos (enchoice)�
//����������������������������������������������������������������������*/
IF ExistBlock( "PP200CST" )
	lRetorno := ExecBlock( "PP200CST", .F., .F., {M->QKC_LABOR,M->QKC_ASSFOR,	M->QKC_DTAPR,M->QKC_OBSERV } )
Endif

For nIt := 1 To Len(aCols)
	If aCols[nIt, nPosDel] .or. Empty(aCols[nIt,nPosDesc])
		nTot ++
	Endif
Next nIt

If Empty(M->QKC_PECA) .or. Empty(M->QKC_REV) .or. nTot == Len(aCols)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
EndIf

Return lRetorno

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QPP200APRO� Autor � Robson Ramiro A.Olivei� Data � 01.08.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Aprova Ensaios                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPP200APRO(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao do mBrowse									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA200                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPP200APRO(nOpc)

If nOpc == 3 .or. nOpc == 4
	DbSelectArea("QAA")
	DbSetOrder(6)
	If Dbseek(Upper(cUserName))
		M->QKC_DTAPR    := Iif(Empty(M->QKC_DTAPR) ,dDataBase     		 ,CtoD(" / / "))
		M->QKC_ASSFOR   := Iif(Empty(M->QKC_ASSFOR),cUserName,Space(40))
	Else
		messagedlg(STR0017) //"O usu�rio logado n�o est� cadastrado no cadastro de usu�rios do m�dulo, portanto n�o poder� ser o aprovador"
	Endif
Endif

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 �PPA200VLD � Autor � Robson Ramiro A Olivei� Data � 20/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Valida o sequencial para o ensaio                		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � PPA200VLD                               					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QPPA200	  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PPA200Vld

If INCLUI
	M->QKC_SEQ := PPAPSEQ("QKC",M->QKC_SEQ,M->QKC_PECA+M->QKC_REV,1)
	PPAPVld("QKC",M->QKC_PECA+M->QKC_REV+M->QKC_SEQ,1,"QK1",2,2)
Endif

Return .T.

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �QPPA200Valid �Autor  �Microsiga           � Data �  03/08/05   ���
����������������������������������������������������������������������������͹��
���Desc.     � Chama o VALID do campo, prevendo uma funcao que carregue no   ���
���          � acols. 														 ���
����������������������������������������������������������������������������͹��
���Uso       � QPPA200                                                       ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function QPPA200Valid()
CheckSx3("QKC_REV",M->QKC_REV)
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
Function QPA200VTIP()

Local lret := .T.   

dbSelectArea("QK2")
dbSetOrder(2)
dbSeek(xFilial("QKC")+M->QKC_PECA+M->QKC_REV+M->QKC_CARAC)
If QK2_TPCAR <> "3"	
	MsgAlert("Esta caracteristica n�o � do tipo desempenho","Aviso")
	lRet := .F.
EndIf  

Return (lRet)
