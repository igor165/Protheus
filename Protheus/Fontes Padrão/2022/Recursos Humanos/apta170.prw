#INCLUDE "protheus.ch"      
#INCLUDE "apta170.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �apta170   � Autor � TANIA BRONZERI     � Data �  11/10/2004 ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Postos de Protocolo                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Postos de Protocolo                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�04/08/14�TQEQ39�Incluido o fonte da 11 para a 12 e efetua-���  
���            �        �      �da a limpeza.                             ��� 
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function apta170
LOCAL cFiltraREE							//Variavel para filtro
LOCAL aIndexREE	:= {}						//Variavel Para Filtro

Private cCadastro	:= OemToAnsi(STR0001)	//"Cadastro de Postos de Protocolo" 
Private bFiltraBrw := {|| Nil}				//Variavel para Filtro

//����������������������������������������������������������Ŀ
//� Monta um aRotina                                         �
//������������������������������������������������������������

Private aRotina := { 	{ STR0002 ,"AxPesqui",	0	,1 } ,;
             			{ STR0003 ,"AxVisual",	0	,2 } ,;
            			{ STR0004 ,"AxInclui",	0	,3 } ,;
             			{ STR0005 ,"AxAltera",	0	,4 } ,;
             			{ STR0006 ,"Aptx170Del",	0	,5 } }


Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
cFiltraRh := CHKRH("apta170","REE","1")
bFiltraBrw 	:= {|| FilBrowse("REE",@aIndexREE,@cFiltraRH) }
Eval(bFiltraBrw)


dbSelectArea("REE")
dbSetOrder(1)

//dbSelectArea("REE")
mBrowse( 6,1,22,75,"REE")

EndFilBrw("REE",aIndexREE)

Return Nil
         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Aptx170Del�Autor  �Tania Bronzeri      � Data �  11/10/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina para Exclusao                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Postos de Protocolo                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Aptx170Del ()

Local uRet 
Local cAlias 	:= "REE"  
Local nReg		:= 0

dbSelectArea("REE")
dbSetOrder(1)
nReg			:= ( cAlias )->( Recno() )
                      
If (ChkDelRegs(cAlias))
	RecLock(cAlias,.F.)
	uRet := AxDeleta( cAlias , nReg , 5 , NIL , NIL , NIL , NIL , NIL , .T. )
	MSUnlock()
Endif

Return Nil

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �19/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA170                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()
 Local aRotina := { 	{ STR0002 ,"AxPesqui",	0	,1,,.F.} ,;
             			{ STR0003 ,"AxVisual",	0	,2 } ,;
            			{ STR0004 ,"AxInclui",	0	,3 } ,;
             			{ STR0005 ,"AxAltera",	0	,4 } ,;
             			{ STR0006 ,"Aptx170Del",	0	,5 } }
					 
Return aRotina

