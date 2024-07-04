#INCLUDE "protheus.ch"
#INCLUDE "apta020.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �APTA020   � Autor � TANIA BRONZERI     � Data �  19/02/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Escritorios de Advocacia                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Escritorios de Advocacia                       ���
�������������������������������������������������������������������������ͼ��
���Programador � Data     � BOPS �  Motivo da Alteracao                   ��� 
�������������������������������������������������������������������������Ĺ��
���Cecilia Car.�04/08/2014�TQEQ39�Incluido o fonte da 11 para a 12 e efe- ���  
���            �          �      �tuada a limpeza.                        ��� 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function APTA020
LOCAL cFiltraRE3							//Variavel para filtro
LOCAL aIndexRE3	:= {}						//Variavel Para Filtro

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
       
Private cCadastro	:= OemToAnsi(STR0001)	//"Cadastro de Escritorios de Advocacia" 
Private bFiltraBrw := {|| Nil}				//Variavel para Filtro


Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina


Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

cFiltraRh := CHKRH("APTA020","RE3","1")
bFiltraBrw 	:= {|| FilBrowse("RE3",@aIndexRE3,@cFiltraRH) }
Eval(bFiltraBrw)

dbSelectArea("RE3")
mBrowse( 6,1,22,75,"RE3")

EndFilBrw("RE3",aIndexRE3)
       	
Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Aptx020Del�Autor  �Tania Bronzeri      � Data �  17/05/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina para Exclusao                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Escritorios de Advocacia                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Aptx020Del ()

Local uRet 
Local cAlias 	:= "RE3"  
Local nReg		:= 0

dbSelectArea("RE3")
dbSetOrder(1)
nReg			:= ( cAlias )->( Recno() )
                      
If (ChkDelRegs("RE3"))
	RecLock("RE3",.F.)
	uRet := AxDeleta( cAlias , nReg , 5 , NIL , NIL , NIL , NIL , NIL , .T. )
	MSUnlock()
Endif

Return Nil

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �18/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �APTA020                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()

 Local aRotina :={ 	{ STR0002 ,"AxPesqui",		0	,1,,.F. } ,;
             			{ STR0003 ,"AxVisual",		0	,2 } ,;
            			{ STR0004 ,"AxInclui",		0	,3 } ,;
             			{ STR0005 ,"AxAltera",		0	,4 } ,;
             			{ STR0006 ,"Aptx020Del",	0	,5 } }
		 
Return aRotina