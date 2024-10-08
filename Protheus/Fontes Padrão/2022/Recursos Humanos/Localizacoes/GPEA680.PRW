#Include "Protheus.ch"
#Include "Inkey.Ch"
#INCLUDE "GPEA680.CH"                         

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEA680  � Autor � Abel Ribeiro          � Data � 15/04/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Mnautencao Cadastro de IRCT                                 ��
�������������������������������������������������������������������������Ĵ��              
���Sintaxe   � GPEA680()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAGPE - RH - PORTUGAL                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Emerson     �22/05/08� BOPS � Alteracao nas strigs                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function GPEA680()

Local aIndexRGD	:= {}		       //Variavel Para Filtro

Local cFiltraRGD			       //Variavel para filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

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
����������������������������������������������������������������*/

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
cFiltraRh := CHKRH("GPEA680","RGD","1")
bFiltraBrw 	:= {|| FilBrowse("RGD",@aIndexRGD,@cFiltraRH) }
Eval(bFiltraBrw)

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
DbSelectArea('RGD')
DbGoTop()
mBrowse(06,01,22,75,'RGD')
//mBrowse(06,01,22,75,"RGD",,,,,,fCriaCor() )

/*
������������������������������������������������������������������������Ŀ
� Deleta o filtro utilizando a funcao FilBrowse                     	 �
��������������������������������������������������������������������������*/
EndFilBrw("RGD",aIndexRGD)

Return( Nil )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Gpea680Del 	�Autor�ABEL RIBEIRO       � Data �15/04/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Deletar Registro do 680                                    �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Firmais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEA680                                                    �
�����������������������������������������������������������������������Ĵ
� Retorno  �NIL															�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Function Gpe680Del( cAlias , nReg , nOpcx )

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
�Fun��o    �Gpe680Mnt� Autor �Abel Ribeiro           � Data �15/04/08  �
�����������������������������������������������������������������������Ĵ
�Descri��o �Rotina de Manutencao nas opcoes Do Menu                     �
�          �                                                            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �Gpe680Mnt( cAlias , nReg , nOpc )							�
�����������������������������������������������������������������������Ĵ
�Parametros�cAlias = Alias do arquivo                                   �
�          �nReg   = Numero do registro                                 �
�          �nOpc   = Numero da opcao selecionada                        �
�����������������������������������������������������������������������Ĵ
� Uso      �Gpe680()	                                                �
�������������������������������������������������������������������������*/
Function Gpe680Mnt( cAlias , nReg , nOpc )
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
� Uso      �GPEA680                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   
Static Function MenuDef()

 Local aRotina := {;
						{ STR0001 , "PESQBRW"		, 0 , 1 , , .F.} ,;	//"Pesquisar"
						{ STR0002 , "Gpe680Mnt"	, 0 , 2 } ,;	//"Visualizar"
						{ STR0003 , "Gpe680Mnt"	, 0 , 3 } ,;	//"Incluir"  
						{ STR0004 , "Gpe680Mnt"	, 0 , 4 } ,;	//"Alterar"  
						{ STR0005 , "Gpe680Del"	, 0 , 5 }  ;	//"Excluir"  
					 }	
Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �fDescFalta�Autor  �Abel Ribeiro        � Data �  24/04/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Mostrar opcoes de Desconto de Subsidio de Faltas           ���
�������������������������������������������������������������������������͹��
���Uso       � RH - Portugal                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
  
Function fDescFalta()

Local cTitulo	:=	""
Local MvParDef	:=	""
Local l1Elem 	:= .F.  //Seleciona v�rios Elementos por Vez
Local MvPar		:= ""
Local oWnd
Local cTipoAu

Private aResul	:={}

cTipoAu :=	MV_PAR27

oWnd := GetWndDefault()
MvPar	:=	&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet	:=	Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

cTitulo := STR0010                      //"Desconta Faltas"
aResul  := {STR0007,STR0008,STR0009}   //"Subsidio Ferias" ## "Subsidio Natal" ## "Aviso Previo"

MvParDef	:=	"123"

f_Opcoes(@MvPar,cTitulo,aResul,MvParDef,12,49,l1Elem,,3,.T.)		// Chama funcao f_Opcoes
&MvRet := If("*" $ mvpar,space(1),mvpar) 					   	    // Devolve Resultado
Return