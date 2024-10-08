#Include "Protheus.ch"
#Include "Inkey.Ch"
#INCLUDE "GPEA670.CH"                         

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEA670  � Autor � Abel Ribeiro          � Data � 15/04/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Categorias Profissionais                       ���
�������������������������������������������������������������������������Ĵ��              
���Sintaxe   � GPEA670()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPE - RH - PORTUGAL                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Aldo Marini �06/09/11�23137/�Retirada da legenda do browse             ���
���            �TDQII2  �2011  �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function GPEA670()

Local aIndexRGG	:= {}		       //Variavel Para Filtro

Local cFiltraRGG		       //Variavel para filtro

Private bFiltraBrw := {|| Nil}	       //Variavel para Filtro

/*
��������������������������������������������������������������Ŀ
� Define Array contendo as Rotinas a executar do programa      �
� ----------- Elementos contidos por dimensao ------------     �
� 1. Nome a aparecer no cabecalho                              �
� 2. Nome da Rotina associada                                  �
� 3. Usado pela rotina                                         �
� 4. Tipo de Transa��o a ser efetuada                          �
�    1 - Pesquisa e Posiciona em um Banco de Dados             �
�    2 - Simplesmente Mostra os Campos                         �
�    3 - Inclui registros no Bancos de Dados                   �
�    4 - Altera o registro corrente                            �
�    5 - Remove o registro corrente do Banco de Dados          �
����������������������������������������������������������������
*/
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

/*
��������������������������������������������������������������Ŀ
� Define o cabecalho da tela de atualizacoes                   �
����������������������������������������������������������������*/
Private cCadastro := OemToAnsi(STR0006)  //"Cadastro de IRCT"

/*
������������������������������������������������������������������������Ŀ
� Inicializa o filtro utilizando a funcao FilBrowse                      �
��������������������������������������������������������������������������*/
cFiltraRh := CHKRH("GPEA670","RGG","1")
bFiltraBrw 	:= {|| FilBrowse("RGG",@aIndexRGG,@cFiltraRH) }
Eval(bFiltraBrw)

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
DbSelectArea('RGG')
DbGoTop()
mBrowse(06,01,22,75,'RGG')

/*
������������������������������������������������������������������������Ŀ
� Deleta o filtro utilizando a funcao FilBrowse                     	 �
��������������������������������������������������������������������������*/
EndFilBrw("RGG",aIndexRGG)

Return( Nil )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gpea670Del   	�Autor�ABEL RIBEIRO       � Data �15/04/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Deletar Registro                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Firmais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA670                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �NIL															�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������
*/
Function Gpe670Del( cAlias , nReg , nOpcx )

Local aArea		:= GetArea()
Local uRet		:= NIL

Private cFilAux	:= ""
/*
�������������������������������������������������������������Ŀ
� Executa a Delecao   										  �
���������������������������������������������������������������*/
//uRet := AxDeleta( cAlias , nReg , nOpcx,,,,,,,MV_MODFOL )
uRet := AxDeleta( cAlias , nReg , nOpcx,,,,,,,, )

RestArea( aArea )

Return( uRet )
/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gpe670Mnt� Autor �Abel Ribeiro           � Data �15/04/08  �
�����������������������������������������������������������������������Ĵ
�Descri��o �Rotina de Manutencao nas opcoes Do Menu                     �
�          �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �Gpe670Mnt( cAlias , nReg , nOpc )							�
�����������������������������������������������������������������������Ĵ
�Parametros�cAlias = Alias do arquivo                                   �
�          �nReg   = Numero do registro                                 �
�          �nOpc   = Numero da opcao selecionada                        �
�����������������������������������������������������������������������Ĵ
� Uso      �GpeA670()	                                                �
�������������������������������������������������������������������������*/
Function Gpe670Mnt( cAlias , nReg , nOpc )
Local aAlter  := {}
Local aHeader := {}


// Preencho os arrays de campos do SRV para mostrar na enchoice    
aHeader	:= ( cAlias )->( GdMontaHeader( cAlias ) )
aEval(aHeader,{|cCpo| aAdd(aAlter, cCpo[2])})

// Preencho os arrays de campos do RGD para mostrar na enchoice    

If nOpc == 2 // Visualizar
	AxVisual(cAlias,nReg,2,,,,,,,,)
ElseIf nOpc == 4 // Alterar
	AxAltera(cAlias,nReg,4,aAlter,aAlter,,,,,,,,,,,,,)
ElseIf nOpc == 3 // Incluir   
	AxInclui(cAlias,nReg,3,aAlter,,aAlter,,,,,,,,,,,)
EndIf

Return(NIL)

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor� Abel Ribeiro      � Data �15/04/08  �
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA670                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   
Static Function MenuDef()

Local aRotina := {;
						{ STR0001 , "PESQBRW"	, 0 , 1 , , .F.} ,;	//"Pesquisar"
						{ STR0002 , "Gpe670Mnt"	, 0 , 2 } ,;	//"Visualizar"
						{ STR0003 , "Gpe670Mnt"	, 0 , 3 } ,;	//"Incluir"  
						{ STR0004 , "Gpe670Mnt"	, 0 , 4 } ,;	//"Alterar"  
						{ STR0005 , "Gpe670Del"	, 0 , 5 }  ;	//"Excluir"  
					 }	
Return aRotina