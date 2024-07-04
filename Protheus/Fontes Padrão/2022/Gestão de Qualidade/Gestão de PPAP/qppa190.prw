#INCLUDE "QPPA190.CH"
#INCLUDE "PROTHEUS.CH"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QPPA190  � Autor � Robson Ramiro A. Olive� Data � 31.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Ensaios de Materiais                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPA190(void)                                              ���
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

Local aRotina := {	{OemToAnsi(STR0001), "AxPesqui", 		0, 1,,.F.},;	//"Pesquisa"
					{OemToAnsi(STR0002), "PPA190Visu", 		0, 2},;			//"Visualiza"
					{OemToAnsi(STR0003), "PPA190Incl",		0, 3},;			//"Inclui"
					{OemToAnsi(STR0004), "PPA190Alte",		0, 4},; 		//"Altera"
					{OemToAnsi(STR0005), "PPA190Excl",		0, 5},; 		//"Exclui"
					{OemToAnsi(STR0012), "QPPR190(.T.)",	0, 6,,.T.},;	//"Imprimir"
					{OemToAnsi(STR0013), "QPPR190V(.T.)", 	0, 7,,.T.}}		//"Imprimir VDA"
					
Return aRotina

Function QPPA190

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Private cFiltro

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������

Private cCadastro 	:= OemToAnsi(STR0006) //"Ensaios de Materiais"
Private cCondW, cCondS

Private aRotina := MenuDef()

cCondW := "QKD->QKD_PECA+QKD->QKD_REV+QKD->QKD_SEQ == M->QKD_PECA+M->QKD_REV+M->QKD_SEQ"
cCondS := "M->QKD_PECA+M->QKD_REV+M->QKD_SEQ"

DbSelectArea("QKD")
DbSetOrder(1)

cFiltro := "QKD_ITEM == '"+StrZero(1,Len(QKD_ITEM))+"'"

Set Filter To &cFiltro
mBrowse(6,1,22,75,"QKD",,,,,,)
Set Filter To

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA190Visu� Autor � Robson Ramiro A. Olive� Data � 31/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Programa de Visualizacao dos Ensaios de Materiais          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA190Visu()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA190                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA190Visu(cAlias, nReg, nOpc)

Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3	:= NIL
Local oGet_4	:= NIL
Local oGet_5	:= NIL
Local oGet_6	:= NIL
Local aButtons	:= {}
Local aPosObj	:= {}
Local oSize		:= NIL

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos

RegToMemory("QKD")

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
oSize := FwDefSize():New()                
oSize:AddObject( "CABECALHO",  100, 40, .T.,.F.)
oSize:AddObject( "GETDADOS" ,  100, 60, .T.,.T.)         
oSize:aMargins := { 3, 3, 3, 3 }
oSize:Process() // Dispara os calculos 

A190Ahead("QKD")
DbSelectArea("QKD")
Set Filter To

nUsado	:= Len(aHeader)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Ensaios de Materiais"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

aAdd(aPosObj,{oSize:GetDimension('CABECALHO', 'LININI'),oSize:GetDimension('CABECALHO', 'COLINI'),oSize:GetDimension('CABECALHO', 'LINEND'),oSize:GetDimension('CABECALHO', 'COLEND')})
aAdd(aPosObj,{oSize:GetDimension('GETDADOS' , 'LININI'),oSize:GetDimension('GETDADOS' , 'COLINI'),oSize:GetDimension('GETDADOS' , 'LINEND'),oSize:GetDimension('GETDADOS' , 'COLEND')})

@ 35,003 SAY TitSX3("QKD_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ 32,061 MSGET oGet_1 VAR M->QKD_PECA PICTURE PesqPict("QKD","QKD_PECA") ;
						ReadOnly F3 "QPP" SIZE 66,10 OF oDlg PIXEL  

@ 35,131 SAY TitSX3("QKD_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 32,189 MSGET oGet_2 VAR M->QKD_REV PICTURE PesqPict("QKD","QKD_REV") ;
                        WHEN .F.;
					   	SIZE 15,10 OF oDlg PIXEL

@ 35,220 SAY TitSX3("QKD_SEQ")[1] SIZE 56, 7 OF oDlg PIXEL
@ 32,258 MSGET oGet_6 VAR M->QKD_SEQ PICTURE PesqPict("QKD","QKD_SEQ") ;
					WHEN .F.;
					SIZE 15,10 OF oDlg PIXEL

@ 50,003 SAY TitSX3("QKD_LABOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ 48,061 MSGET oGet_3 VAR M->QKD_LABOR PICTURE PesqPict("QKD","QKD_LABOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL
					   	
@ 50,131 SAY TitSX3("QKD_ASSFOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ 48,189 MSGET oGet_4 VAR M->QKD_ASSFOR PICTURE PesqPict("QKD","QKD_ASSFOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL					   		

@ 48,258 MSGET oGet_5 VAR M->QKD_DTAPR PICTURE PesqPict("QKD","QKD_DTAPR") ;
						WHEN .F.;
					   	SIZE 33,10 OF oDlg PIXEL					   		

@ 65,003 SAY TitSX3("QKD_OBSERV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 63,061 MSGET oGet_3 VAR M->QKD_OBSERV PICTURE PesqPict("QKD","QKD_OBSERV") ;
						WHEN .F.;
					   	SIZE 200,10 OF oDlg PIXEL
					   						   	
A190Acols(nOpc)

oGet := MSGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4], nOpc,"AllwaysTrue","AllwaysTrue","+QKD_ITEM",.T.)

aButtons := {	{"RELATORIO", 	{ || QPP190RESU(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0014)},;		//"Resultados das Medicoes"###"Result"
				{"BMPVISUAL",  	{ || QPPR190()},			OemToAnsi(STR0011), OemToAnsi(STR0016)} }		//"Visualizar/Imprimir"###"Vis/Prn"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons) centered

DbSelectArea("QKD")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.
          

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA190Incl� Autor � Robson Ramiro A. Olive� Data � 31/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Programa de Inclusao dos Ensaios de Materiais              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPPA190Incl()                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA190                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA190Incl(cAlias, nReg, nOpc)

Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3	:= NIL
Local oGet_4	:= NIL
Local oGet_5	:= NIL
Local oGet_6	:= NIL
Local lOk 		:= .F.   
Local aButtons	:= {}
Local nTamGet 	:= QPPTAMGET("QKD_ITEM",1)
Local aPosObj	:= {}
Local oSize		:= NIL

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos

RegToMemory("QKD",.T.)

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
A190Ahead("QKD")
DbSelectArea("QKD")
Set Filter To

nUsado	:= Len(aHeader)

oSize := FwDefSize():New()                
oSize:AddObject( "CABECALHO",  100, 40, .T.,.F.)
oSize:AddObject( "GETDADOS" ,  100, 60, .T.,.T.)         
oSize:aMargins := { 3, 3, 3, 3 }
oSize:Process() // Dispara os calculos 

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Ensaios de Materiais"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

aAdd(aPosObj,{oSize:GetDimension('CABECALHO', 'LININI'),oSize:GetDimension('CABECALHO', 'COLINI'),oSize:GetDimension('CABECALHO', 'LINEND'),oSize:GetDimension('CABECALHO', 'COLEND')})
aAdd(aPosObj,{oSize:GetDimension('GETDADOS' , 'LININI'),oSize:GetDimension('GETDADOS' , 'COLINI'),oSize:GetDimension('GETDADOS' , 'LINEND'),oSize:GetDimension('GETDADOS' , 'COLEND')})

@ 35,003 SAY TitSX3("QKD_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ 32,061 MSGET oGet_1 VAR M->QKD_PECA PICTURE PesqPict("QKD","QKD_PECA") ;
						Valid NaoVazio().and.QPPA190Valid();
						F3 "QPP" SIZE 66,10 OF oDlg PIXEL  

@ 35,131 SAY TitSX3("QKD_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 32,189 MSGET oGet_2 VAR M->QKD_REV PICTURE PesqPict("QKD","QKD_REV") ;
                        VALID CheckSx3("QKD_REV",M->QKD_REV).And.QPPA190Vld2();
					   	SIZE 15,10 OF oDlg PIXEL

@ 35,220 SAY TitSX3("QKD_SEQ")[1] SIZE 56, 7 OF oDlg PIXEL
@ 32,258 MSGET oGet_6 VAR M->QKD_SEQ PICTURE PesqPict("QKD","QKD_SEQ") ;
 						VALID CheckSx3("QKD_SEQ",M->QKD_SEQ);
					SIZE 15,10 OF oDlg PIXEL

@ 50,003 SAY TitSX3("QKD_LABOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ 48,061 MSGET oGet_3 VAR M->QKD_LABOR PICTURE PesqPict("QKD","QKD_LABOR") ;
					   	SIZE 66,10 OF oDlg PIXEL
					   	
@ 50,131 SAY TitSX3("QKD_ASSFOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ 48,189 MSGET oGet_4 VAR M->QKD_ASSFOR PICTURE PesqPict("QKD","QKD_ASSFOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL					   		

@ 48,258 MSGET oGet_5 VAR M->QKD_DTAPR PICTURE PesqPict("QKD","QKD_DTAPR") ;
						WHEN .F.;
					   	SIZE 33,10 OF oDlg PIXEL					   		

@ 65,003 SAY TitSX3("QKD_OBSERV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 63,061 MSGET oGet_3 VAR M->QKD_OBSERV PICTURE PesqPict("QKD","QKD_OBSERV") ;
					   	SIZE 200,10 OF oDlg PIXEL
					   						   	
A190Acols(nOpc)

oGet := MSGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4], nOpc,"PP90LinOk" ,"PP90TudOk","+QKD_ITEM",.T.,,1,,nTamGet)

aButtons := {	{"RELATORIO", 	{ || QPP190RESU(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0014)},;		//"Resultados das Medicoes"###/"Result"
				{"EDIT",  		{ || QPP190APRO(nOpc) },	OemToAnsi(STR0010), OemToAnsi(STR0015) }}		//"Aprovar/Desaprovar"###"Apr/Des"

If ExistBlock("QPA190BT")
	aButtons := ExecBlock("QPA190BT",.F.,.F.,{nOpc,aButtons})
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP90TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) centered

If lOk
	PPA190Grav(nOpc)
Endif

DbSelectArea("QKD")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA190Alte� Autor � Robson Ramiro A. Olive� Data � 31/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Programa de Alteracao dos Ensaios de Materiais             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA190Alte()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA190                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA190Alte(cAlias, nReg, nOpc)

Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3	:= NIL
Local oGet_4	:= NIL
Local oGet_5	:= NIL
Local lOk 		:= .F.   
Local aButtons	:= {}
Local nTamGet 	:= QPPTAMGET("QKD_ITEM",1)
Local aPosObj	:= {}
Local oSize		:= NIL

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos

If !QPPVldAlt(QKD->QKD_PECA,QKD->QKD_REV,QKD->QKD_ASSFOR)
	Return
Endif

RegToMemory("QKD")

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������
A190Ahead("QKD")
DbSelectArea("QKD")
Set Filter To

nUsado	:= Len(aHeader)      

oSize := FwDefSize():New()                
oSize:AddObject( "CABECALHO",  100, 40, .T.,.F.)
oSize:AddObject( "GETDADOS" ,  100, 60, .T.,.T.)         
oSize:aMargins := { 3, 3, 3, 3 }
oSize:Process() // Dispara os calculos 

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Ensaios de Materiais"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

aAdd(aPosObj,{oSize:GetDimension('CABECALHO', 'LININI'),oSize:GetDimension('CABECALHO', 'COLINI'),oSize:GetDimension('CABECALHO', 'LINEND'),oSize:GetDimension('CABECALHO', 'COLEND')})
aAdd(aPosObj,{oSize:GetDimension('GETDADOS' , 'LININI'),oSize:GetDimension('GETDADOS' , 'COLINI'),oSize:GetDimension('GETDADOS' , 'LINEND'),oSize:GetDimension('GETDADOS' , 'COLEND')})

@ 20,03 SAY TitSX3("QKD_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ 18,61 MSGET oGet_1 VAR M->QKD_PECA PICTURE PesqPict("QKD","QKD_PECA") ;
						ReadOnly F3 "QPP" SIZE 66,10 OF oDlg PIXEL  

@ 35,131 SAY TitSX3("QKD_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 32,189 MSGET oGet_2 VAR M->QKD_REV PICTURE PesqPict("QKD","QKD_REV") ;
						WHEN .F. ;			
					   	SIZE 15,10 OF oDlg PIXEL

@ 35,220 SAY TitSX3("QKD_SEQ")[1] SIZE 56, 7 OF oDlg PIXEL
@ 32,258 MSGET oGet_6 VAR M->QKD_SEQ PICTURE PesqPict("QKD","QKD_SEQ") ;
					WHEN .F.;
					SIZE 15,10 OF oDlg PIXEL

@ 50,003  SAY TitSX3("QKD_LABOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ 48,061 MSGET oGet_3 VAR M->QKD_LABOR PICTURE PesqPict("QKD","QKD_LABOR") ;
					   	SIZE 66,10 OF oDlg PIXEL
					   	
@ 50,131 SAY TitSX3("QKD_ASSFOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ 48,189 MSGET oGet_4 VAR M->QKD_ASSFOR PICTURE PesqPict("QKD","QKD_ASSFOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL

@ 48,258 MSGET oGet_5 VAR M->QKD_DTAPR PICTURE PesqPict("QKD","QKD_DTAPR") ;
						WHEN .F.;
					   	SIZE 33,10 OF oDlg PIXEL

@ 65,003 SAY TitSX3("QKD_OBSERV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 63,061 MSGET oGet_3 VAR M->QKD_OBSERV PICTURE PesqPict("QKD","QKD_OBSERV") ;
					   	SIZE 200,10 OF oDlg PIXEL
		   		
A190Acols(nOpc)

oGet := MSGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4], nOpc,"PP90LinOk" ,"PP90TudOk","+QKD_ITEM",.T.,,1,,nTamGet)

aButtons := {	{"RELATORIO", 	{ || QPP190RESU(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0014)},;		//"Resultados das Medicoes"###"Result"
				{"EDIT",  		{ || QPP190APRO(nOpc) },	OemToAnsi(STR0010), OemToAnsi(STR0015) }}		//"Aprovar/Desaprovar"###"Apr/Des"


If ExistBlock("QPA190BT")
	aButtons := ExecBlock("QPA190BT",.F.,.F.,{nOpc,aButtons})
EndIf


ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP90TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) centered

If lOk
    PPA190Grav(nOpc)
Endif

DbSelectArea("QKD")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PPA190Excl� Autor � Robson Ramiro A. Olive� Data � 31/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Exclusao dos Ensaios de Materiais              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA190Excl()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Opcao selecionada                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA190                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA190Excl(cAlias, nReg, nOpc)

Local oDlg		:= NIL
Local oGet_1	:= NIL
Local oGet_2	:= NIL
Local oGet_3	:= NIL
Local oGet_4	:= NIL
Local oGet_5	:= NIL
Local oGet_6	:= NIL
Local aButtons	:= {}
Local aPosObj	:= {}
Local oSize		:= NIL

Private aHeader   	:= {}
Private aCols		:= {}
Private nUsado		:=	0
Private oGet		:= NIL
Private axTextos      

If !QPPVldExc(QKD->QKD_REV,QKD->QKD_ASSFOR)
	Return
Endif


RegToMemory("QKD")

//��������������������������������������������������������������Ŀ
//� Monta vetor aHeader a ser utilizado na getdados              �
//����������������������������������������������������������������

A190Ahead("QKD")
DbSelectArea("QKD")
Set Filter To

nUsado	:= Len(aHeader)

oSize := FwDefSize():New()                
oSize:AddObject( "CABECALHO",  100, 40, .T.,.F.)
oSize:AddObject( "GETDADOS" ,  100, 60, .T.,.T.)         
oSize:aMargins := { 3, 3, 3, 3 }
oSize:Process() // Dispara os calculos 

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) ; //"Ensaios de Materiais"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

aAdd(aPosObj,{oSize:GetDimension('CABECALHO', 'LININI'),oSize:GetDimension('CABECALHO', 'COLINI'),oSize:GetDimension('CABECALHO', 'LINEND'),oSize:GetDimension('CABECALHO', 'COLEND')})
aAdd(aPosObj,{oSize:GetDimension('GETDADOS' , 'LININI'),oSize:GetDimension('GETDADOS' , 'COLINI'),oSize:GetDimension('GETDADOS' , 'LINEND'),oSize:GetDimension('GETDADOS' , 'COLEND')})

@ 20,03 SAY TitSX3("QKD_PECA")[1] SIZE 56,07 OF oDlg PIXEL
@ 18,61 MSGET oGet_1 VAR M->QKD_PECA PICTURE PesqPict("QKD","QKD_PECA") ;
						ReadOnly F3 "QPP" SIZE 66,10 OF oDlg PIXEL

@ 35,131 SAY TitSX3("QKD_REV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 32,189 MSGET oGet_2 VAR M->QKD_REV PICTURE PesqPict("QKD","QKD_REV") ;
						WHEN .F. ;
					   	SIZE 15,10 OF oDlg PIXEL

@ 35,220 SAY TitSX3("QKD_SEQ")[1] SIZE 56, 7 OF oDlg PIXEL
@ 32,258 MSGET oGet_6 VAR M->QKD_SEQ PICTURE PesqPict("QKD","QKD_SEQ") ;
					WHEN .F.;
					SIZE 15,10 OF oDlg PIXEL

@ 50,003 SAY TitSX3("QKD_LABOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ 48,061 MSGET oGet_3 VAR M->QKD_LABOR PICTURE PesqPict("QKD","QKD_LABOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL
					   	
@ 50,131 SAY TitSX3("QKD_ASSFOR")[1] SIZE 56, 7 OF oDlg PIXEL
@ 48,189 MSGET oGet_4 VAR M->QKD_ASSFOR PICTURE PesqPict("QKD","QKD_ASSFOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oDlg PIXEL					   		

@ 48,258 MSGET oGet_5 VAR M->QKD_DTAPR PICTURE PesqPict("QKD","QKD_DTAPR") ;
						WHEN .F.;
					   	SIZE 33,10 OF oDlg PIXEL					   		

@ 65,003 SAY TitSX3("QKD_OBSERV")[1] SIZE 56, 7 OF oDlg PIXEL
@ 63,061 MSGET oGet_3 VAR M->QKD_OBSERV PICTURE PesqPict("QKD","QKD_OBSERV") ;
						WHEN .F.;
					   	SIZE 200,10 OF oDlg PIXEL
					   	
A190Acols(nOpc)

oGet := MSGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4], nOpc,"AllwaysTrue","AllwaysTrue","+QKD_ITEM",.T.)

aButtons := {	{"RELATORIO", 	{ || QPP190RESU(nOpc) },	OemToAnsi(STR0007), OemToAnsi(STR0014)},;		//"Resultados das Medicoes"###"Result"
				{"BMPVISUAL",  	{ || QPPR190()},			OemToAnsi(STR0011), OemToAnsi(STR0016)} }		//"Visualizar/Imprimir"###"Vis/Prn"

If ExistBlock("QPA190BT")
	aButtons := ExecBlock("QPA190BT",.F.,.F.,{nOpc,aButtons})
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| A190Dele(),oDlg:End()},{||oDlg:End()}, , aButtons) centered

DbSelectArea("QKD")
DbSetOrder(1)
Set Filter To &cFiltro

Return .T.


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A190Acols� Autor � Robson Ramiro A. Olive� Data � 31/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Carrega vetor aCols para a GetDados                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A190Acols()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA190                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A190Acols(nOpc)
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

    nPos            := aScan(aHeader,{ |x| AllTrim(x[2])== "QKD_ITEM" })
	aCols[1,nPos]	:= StrZero(1,Len(aCols[1,nPos]))
	
	aCols[1,nUsado+1] := .F.	

Else
	
    DbSelectArea("QKD")
	DbSetOrder(1)
	DbSeek(xFilial("QKD") + &cCondS)
	aArea := QKD->(GetArea())
	
	Do While QKD->(!Eof()) .and. xFilial("QKD") == QKD->QKD_FILIAL .and. &cCondW
			 	
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
���Funcao    � A190Ahead� Autor � Robson Ramiro A. Olive� Data � 31/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Monta Ahead para aCols                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A190Ahead()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 : Alias                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA190                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A190Ahead(cAlias)

Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nX

Private nEdicao := Val(GetMv("MV_QPPAPED",.T.,"3"))// Indica a Edicao do PPAP default 3 Edicao

aHeader := {}
nUsado 	:= 0

For nX := 1 To Len(aStruAlias)
	//��������������������������������������������������
	//�Ignora campos que nao devem aparecer na getdados�
	//��������������������������������������������������
	If  Upper(AllTrim(aStruAlias[nX,1])) == "QKD_PECA" 	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKD_REV" 	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKD_REVINV".or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKD_LABOR" .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKD_ASSFOR".or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKD_DTAPR" .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKD_OBSERV".or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKD_SEQ"
		Loop
	Endif
	
	If nEdicao == 3
		If cNivel >= GetSX3Cache(aStruAlias[nX,1],"X3_NIVEL") .And. Alltrim(aStruAlias[nX,1]) <> "QKD_DTENSA"
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
		If cNivel >= GetSX3Cache(aStruAlias[nX,1],"X3_NIVEL") .And. Alltrim(aStruAlias[nX,1]) <> "QKD_FTESTE"
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
���Funcao    � A190Dele � Autor � Robson Ramiro A Olivei� Data � 31/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Fucao para exclusao dos Ensaios de Materiais               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A190Dele()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA190                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function A190Dele()

Local cEspecie  := "QPPA190 "

DbSelectArea("QKD")
DbSetOrder(1)
DbSeek(xFilial("QKD") + &cCondS)

Begin Transaction

Do While QKD->(!Eof()) .and. xFilial("QKD") == QKD->QKD_FILIAL .and. &cCondW
		 
    If !Empty(QKD->QKD_CHAVE)
        QO_DelTxt(QKD->QKD_CHAVE,cEspecie)    //QPPXFUN
	EndIf		 

    RecLock("QKD",.F.)
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
���Funcao    �PPA190Grav� Autor � Robson Ramiro A Olivei� Data � 31/07/01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa de Gravacao dos Ensaios de Materiais - Incl./Alter���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PPA190Grav(ExpC1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Exp1N = Opcao                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA190                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PPA190Grav(nOpc)

Local nIt
Local nNumItem
Local nPosDel		:= Len(aHeader) + 1
Local lGraOk		:= .T.
Local cEspecie  	:= "QPPA190 "
Local cAtividade	:= "09 " // Definido no ID - QKZ
Local nCpo

DbSelectArea("QKD")
DbSetOrder(1)
	
Begin Transaction

nNumItem := 1  // Contador para os Itens
	
For nIt := 1 To Len(aCols)
	
	If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

		If ALTERA
			If DbSeek(xFilial("QKD")+ &cCondS + StrZero(nIt,Len(QKD->QKD_ITEM)))
                RecLock("QKD",.F.)
			Else
                RecLock("QKD",.T.)
			Endif
		Else	                   
            RecLock("QKD",.T.)
		Endif
			
		For nCpo := 1 To Len(aHeader)
			If aHeader[nCpo, 10] <> "V"
                QKD->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
			EndIf
		Next nCpo
                                                                              
		//��������������������������������������������������������������Ŀ
		//� Controle de itens do acols / Chave invertida                 �
		//����������������������������������������������������������������
        QKD->QKD_ITEM   := StrZero(nNumItem,Len(QKD->QKD_ITEM))
        QKD->QKD_REVINV := Inverte(M->QKD_REV)


		//��������������������������������������������������������������Ŀ
		//� Dados da Enchoice                                            �
		//����������������������������������������������������������������
        QKD->QKD_FILIAL	:= xFilial("QKD")
        QKD->QKD_PECA  	:= M->QKD_PECA
        QKD->QKD_REV  	:= M->QKD_REV
        QKD->QKD_ASSFOR	:= M->QKD_ASSFOR
        QKD->QKD_DTAPR	:= M->QKD_DTAPR
        QKD->QKD_LABOR 	:= M->QKD_LABOR
		QKD->QKD_OBSERV	:= M->QKD_OBSERV
		QKD->QKD_SEQ 		:= M->QKD_SEQ

		nNumItem++			
	
		MsUnLock()					
	Else
		If DbSeek(xFilial("QKD") + &cCondS + StrZero(nIt,Len(QKD->QKD_ITEM)))
	
            If !Empty(QKD->QKD_CHAVE)
                QO_DelTxt(QKD->QKD_CHAVE,cEspecie)    //QPPXFUN
			EndIf		 

            RecLock("QKD",.F.)
            QKD->(DbDelete())
		Endif
	Endif
	
Next nIt
FKCOMMIT()
End Transaction

If !Empty(QKD->QKD_DTAPR) .and. !Empty(QKD->QKD_ASSFOR)
	QPP_CRONO(QKD->QKD_PECA,QKD->QKD_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
Endif
				
DbSelectArea("QKD")
DbSetOrder(1)

Return lGraOk


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QPP190RESU� Autor � Robson Ramiro A.Olivei� Data � 31.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cadastra Observacoes                        				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPP190RESU(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao do mBrowse									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA190                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPP190RESU(nOpc)

Local cChave  	:= "", cCabec := ""
Local cTitulo   := OemToAnsi(STR0007) //"Ensaios de Materiais"
Local nTamLin 	:= 46
Local nPosChave := aScan(aHeader,{ |x| AllTrim(x[2]) == "QKD_CHAVE"  } )
Local cEspecie  := "QPPA190 "   //Para gravacao de textos
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
	cChave := GetSXENum("QKD", "QKD_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

	aCols[n,nPosChave] := cChave
Else
	cChave := aCols[n,nPosChave]
EndIf
                                              
cInf := AllTrim(M->QKD_PECA) + " " + M->QKD_REV + STR0009 + StrZero(n,Len(QKD->QKD_ITEM)) //" Item - "

//����������������������������������������������������������Ŀ
//� Digita os resultados dos Ensaios                         �
//������������������������������������������������������������
If QO_TEXTO(cChave,cEspecie,nTamlin,cTitulo,cInf, @axtextos,1,cCabec,lEdit)
	//����������������������������������������������������������Ŀ
	//� Grava Texto dos ensaios no QKO						     �
	//������������������������������������������������������������
	QO_GrvTxt(cChave,cEspecie,1,@axTextos) 	//QPPXFUN
Endif

DbSelectArea("QKD")
DbSetOrder(1)

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PP90LinOk � Autor � Robson Ramiro A. Olive� Data � 31.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para mudanca/inclusao de linhas               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP90LinOk                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QPPA190                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/                     
Function PP90LinOk

Local nPosDel  := Len(aHeader) + 1
Local nPosDesc := aScan(aHeader, { |x| AllTrim(x[2]) == "QKD_DESC" })
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
���Fun��o    �PP90TudOk � Autor � Robson Ramiro A. Olive� Data � 31.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consistencia para inclusao/alteracao geral                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PP90TudOk                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Void                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QPPA190                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/

Function PP90TudOk

Local lRetorno	:= .T.
Local nIt 		:= 0
Local nTot		:= 0
Local nPosDel  	:= Len(aHeader) + 1                      
Local nPosDesc  := aScan(aHeader, { |x| AllTrim(x[2]) == "QKD_DESC" })

/*��������������������������������������������������������������������Ŀ
//�Ponto de entrada para consistir obrigatoriedade de campos (enchoice)�
//����������������������������������������������������������������������*/
IF ExistBlock( "PP190CST" )
	lRetorno := ExecBlock( "PP190CST", .F., .F., {M->QKD_LABOR,M->QKD_ASSFOR,M->QKD_DTAPR,M->QKD_OBSERV } )
Endif

For nIt := 1 To Len(aCols)
	If aCols[nIt, nPosDel] .or. Empty(aCols[nIt,nPosDesc])
		nTot ++
	Endif
Next nIt

If Empty(M->QKD_PECA) .or. Empty(M->QKD_REV) .or. nTot == Len(aCols)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
EndIf

Return lRetorno

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �QPP190APRO� Autor � Robson Ramiro A.Olivei� Data � 31.07.01 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Aprova Ensaios                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPP190APRO(ExpN1)                                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Opcao do mBrowse									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QPPA190                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QPP190APRO(nOpc)

If nOpc == 3 .or. nOpc == 4           
	DbSelectArea("QAA")
	DbSetOrder(6)
	If Dbseek(Upper(cUserName))
		M->QKD_DTAPR    := Iif(Empty(M->QKD_DTAPR) ,dDataBase            ,CtoD(" / / "))
		M->QKD_ASSFOR   := Iif(Empty(M->QKD_ASSFOR),cUserName,Space(40))
	Else
		messagedlg(STR0017) //"O usu�rio logado n�o est� cadastrado no cadastro de usu�rios do m�dulo, portanto n�o poder� ser o aprovador"
	Endif
Endif

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 �PPA190VLD � Autor � Robson Ramiro A Olivei� Data � 19/05/04 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Valida o sequencial para o ensaio                		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � PPA190VLD                               					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QPPA190	  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PPA190Vld

If INCLUI
	M->QKD_SEQ := PPAPSEQ("QKD",M->QKD_SEQ,M->QKD_PECA+M->QKD_REV,1)
	PPAPVld("QKD",M->QKD_PECA+M->QKD_REV+M->QKD_SEQ,1,"QK1",2,2)
Endif

Return .T.

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �QPPA190Valid �Autor  �Microsiga           � Data �  03/08/05   ���
����������������������������������������������������������������������������͹��
���Desc.     � Chama o VALID do campo, prevendo uma funcao que carregue no   ���
���          � acols. 														 ���
����������������������������������������������������������������������������͹��
���Uso       � QPPA190                                                       ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function QPPA190Valid()
Local lRetorno := .T.
//��������������������������������������������������������������Ŀ
//� Verifica se existe a Peca                                    �
//����������������������������������������������������������������             
If !ExistCpo("QK1",M->QKD_PECA)
	lRetorno := .F.
EndIf
CheckSx3("QKD_REV",M->QKD_REV)
oGet:ForceRefresh()

Return lRetorno
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �QPPA190Vld2  �Autor  �Adalberto M. Neto   � Data �  06/08/07   ���
����������������������������������������������������������������������������͹��
���Desc.     � Chama o VALID do campo, prevendo uma funcao que carregue no   ���
���          � acols. 														 ���
����������������������������������������������������������������������������͹��
���Uso       � QPPA190                                                       ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function QPPA190Vld2()
Local lRetorno := .T.
//��������������������������������������������������������������Ŀ
//� Verifica se existe a Peca e a Revisao existem                �
//����������������������������������������������������������������             
DbSelectArea("QK1")
DbSetOrder(1)	 
If !DbSeek(xFilial("QK1")+ M->QKD_PECA+M->QKD_REV)
	MsgAlert(OemtoAnsi(STR0018),"Peca: " +Alltrim(M->QKD_PECA)+"  / Revis�o: "+Alltrim(M->QKD_REV))
	lRetorno := .F.
Endif
                 
DbSelectArea("QKD")       
DbSetOrder(1)	 

Return lRetorno

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �QPPA190DESC  Data 09/01/09  										���
���Uso       � QPPA190                                                       ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function QPPA190DESC()
Local cDesc 		:= ""
Local nTamQK2Desc	:= TamSX3("QK2_DESC")[1] 
Local nTamQK2Espe	:= TamSX3("QK2_ESPE")[1]  //-- Leva em considera��o ' - '
Local nTamUM		:= TamSX3("QK2_UM"  )[1]  //-- Leva em considera��o ' - '

Local nTamQKD		:= TamSX3("QKD_DESC")[1] - 6

Local nTamTot		:= nTamQK2Desc+nTamQK2Espe+nTamUM
Local nTamDesc		:= NoRound((nTamQK2Desc/nTamTot)* nTamQKD,0)
Local nTamEspe		:= NoRound((nTamQK2Espe/nTamTot)* nTamQKD,0)

If !Empty(QK2->QK2_DESC)
	cDesc := ALLTRIM(SUBS(QK2->QK2_DESC,1,nTamDesc))+' - '+ALLTRIM(SUBS(QK2->QK2_ESPE,1,nTamEspe))+' - '+QK2->QK2_UM
Else
	cDesc := Space(Len(QK2->QK2_DESC)) 
Endif                                   

Return cDesc

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �QPA190VTIP   �Autor  � Sergio S. Fuzinaka � Data �  09/01/09   ���
����������������������������������������������������������������������������͹��
���Desc.     � Verifica se o tipo da caracteristica e material.              ���
���          �        														 ���
����������������������������������������������������������������������������͹��
���Uso       � QPPA190                                                       ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Function QPA190VTIP()

Local lRet		:= .T.   
Local aArea		:= GetArea()
Local aAreaQK2	:= QK2->(GetArea())

dbSelectArea("QK2")
dbSetOrder(2)
If dbSeek(xFilial("QK2")+M->QKD_PECA+M->QKD_REV+M->QKD_CARAC)
	If QK2_TPCAR <> "2"	
		MsgAlert(OemToAnsi(STR0019),OemToAnsi(STR0020))	//"Esta caracteristica n�o � do tipo material"#"Aviso"
		lRet := .F.
	EndIf  
Endif

RestArea(aAreaQK2)
RestArea(aArea)

Return (lRet)