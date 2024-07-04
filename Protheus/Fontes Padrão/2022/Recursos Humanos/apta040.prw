#INCLUDE "protheus.ch"
#INCLUDE "apta040.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �APTA040   � Autor � TANIA BRONZERI     � Data �  23/03/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Regioes                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Regioes                                        ���
�������������������������������������������������������������������������͹��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĺ��
���Programador � Data     � BOPS �  Motivo da Alteracao                   ��� 
�������������������������������������������������������������������������Ĺ��
���Cecilia Car.�04/08/2014�TQEQ39�Incluido o fonte da 11 para a 12 e efe- ���  
���            �          �      �tuada a limpeza.                        ��� 
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function APTA040

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
LOCAL cFiltraRER							//Variavel para filtro
LOCAL aIndexRER	:= {}						//Variavel Para Filtro
Local lGestPubl := if(ExistFunc("fUsaGFP"),fUsaGFP(),.f.) //Verifica se utiliza o modulo de Gestao de Folha Publica - SIGAGFP

Private cCadastro	:= Iif(lGestPubl,OemToAnsi(STR0007),OemToAnsi(STR0001))	//"Cadastro de Regioes" 
Private bFiltraBrw := {|| Nil}				//Variavel para Filtro

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
cFiltraRh := CHKRH("APTA040","RER","1")
bFiltraBrw 	:= {|| FilBrowse("RER",@aIndexRER,@cFiltraRH) }
Eval(bFiltraBrw)

dbSelectArea("RER")
dbSetOrder(1)

//���������������������������������������������������������������������Ŀ
//� Executa a funcao MBROWSE. Sintaxe:                                  �
//�                                                                     �
//� mBrowse(<nLin1,nCol1,nLin2,nCol2,Alias,aCampos,cCampo)              �
//� Onde: nLin1,...nCol2 - Coordenadas dos cantos aonde o browse sera   �
//�                        exibido. Para seguir o padrao da AXCADASTRO  �
//�                        use sempre 6,1,22,75 (o que nao impede de    �
//�                        criar o browse no lugar desejado da tela).   �
//�                        Obs.: Na versao Windows, o browse sera exibi-�
//�                        do sempre na janela ativa. Caso nenhuma este-�
//�                        ja ativa no momento, o browse sera exibido na�
//�                        janela do proprio SIGAADV.                   �
//� Alias                - Alias do arquivo a ser "Browseado".          �
//� aCampos              - Array multidimensional com os campos a serem �
//�                        exibidos no browse. Se nao informado, os cam-�
//�                        pos serao obtidos do dicionario de dados.    �
//�                        E util para o uso com arquivos de trabalho.  �
//�                        Segue o padrao:                              �
//�                        aCampos := { {<CAMPO>,<DESCRICAO>},;         �
//�                                     {<CAMPO>,<DESCRICAO>},;         �
//�                                     . . .                           �
//�                                     {<CAMPO>,<DESCRICAO>} }         �
//�                        Como por exemplo:                            �
//�                        aCampos := { {"TRB_DATA","Data  "},;         �
//�                                     {"TRB_COD" ,"Codigo"} }         �
//� cCampo               - Nome de um campo (entre aspas) que sera usado�
//�                        como "flag". Se o campo estiver vazio, o re- �
//�                        gistro ficara de uma cor no browse, senao fi-�
//�                        cara de outra cor.                           �
//�����������������������������������������������������������������������

dbSelectArea("RER")
mBrowse( 6,1,22,75,"RER")
                                       
//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("RER",aIndexRER)

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Aptx040Del�Autor  �Tania Bronzeri      � Data �  17/05/2004 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina para Exclusao                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Regioes                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function Aptx040Del ()

Local uRet 
Local cAlias 	:= "RER"  
Local nReg		:= 0

dbSelectArea(cAlias)
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
� Uso      �APTA040                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()

 Local aRotina :={ 	{ STR0002 ,"AxPesqui",	0	,1,,.F.} ,;
             			{ STR0003 ,"AxVisual",	0	,2 } ,;
            			{ STR0004 ,"AxInclui",	0	,3 } ,;
             			{ STR0005 ,"AxAltera",	0	,4 } ,;
             			{ STR0006 ,"Aptx040Del",	0	,5 } }
Return aRotina