#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM877.CH"                                                                            

/*/
�����������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEM877  � Autor � L.Trombini                  � Data � 20/10/10 ���
�������������������������������������������������������������������������������Ĵ��
���Descri��o � Visualizacao REGISTRO DEL D.R.E.P.      		                    ���
�������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEM877()    		                                            ���
�������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico  		                                                ���
�������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.    		        ���
�������������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS	   �  Motivo da Alteracao                       ���
�������������������������������������������������������������������������������Ĵ��
���            � 		� 		   �											���
���            �        � 		   �											���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
Function GPEM877() 

LOCAL cFiltraRH6			//Variavel para filtro
LOCAL aIndexRH6	:= {}		//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro


//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina


//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemToAnsi( STR0001 )  //"Manuten��o do Registro do D.R.E.P."
//--Altera o Set Epch para 1920 
nEpoca := SET( 5,1920)

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
cFiltraRh := CHKRH("GPEM877","RH6","2")
bFiltraBrw 	:= {|| FilBrowse("RH6",@aIndexRH6,@cFiltraRH) }
Eval(bFiltraBrw)

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea( "RH6" )
dbGoTop()

mBrowse( 6, 1,22,75,"RH6",,,,,,)

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("RH6",aIndexRH6)           

DbCloseArea("RH6")

//--Retornar Set Epoch Padrao
SET(5,nEpoca)

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F877EXCLU �Autor  �Microsiga           � Data �  20/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica codigo esta sendo utilizado em  outra tabela geran-���
���          �do arquivo de Log. Se confirmar a existencia do codigo numa ���
���          �outra tabela, abre cadastro no modo Visualizacao            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function  f877Exclu(cBrowseAlias, nReg, nBrowseOpcx )

Local cKeyDel		:= RH6_MAT
Local nAreasCpo		:= 2.00
Local nAreas		:= 0.00
Local lChkDelOk		:= .F.
Local aAreas 		:= {} 
Local aLog			:= {}
Local aLogTitle		:= {}  

//������������������������������������������������������������������������Ŀ
//� Tabelas onde deverao se verificadas a existencia do codigo p/ delecao  �
//��������������������������������������������������������������������������
//-- SRA 
aAdd( aAreas , Array( 03 ) )
nAreas := Len( aAreas )
aAreas[nAreas,01] := SRA->( GetArea() )
aAreas[nAreas,02] := Array( nAreasCpo )
				aAreas[nAreas,02,01] := "RA_FILIAL"
				aAreas[nAreas,02,02] := "RA_MAT"
aAreas[nAreas,03] := RetOrdem( "SRA"  , "RA_FILIAL+RA_MAT" , .T. )



//������������������������������������������������������������������������Ŀ
//� Verifica se o Registro esta sendo utilizado                            �
//��������������������������������������������������������������������������
lChkDelOk  := ChkDelRegs(	cBrowseAlias		,;	//Alias do Arquivo Principal
							nReg				,;	//Registro do Arquivo Principal
							nBrowseOpcx			,;	//Opcao para a AxDeleta
							xFilial( cBrowseAlias)	,;	//Filial do Arquivo principal para Delecao
							cKeyDel				,;	//Chave do Arquivo Principal para Delecao
							aAreas				,;	//Array contendo informacoes dos arquivos a serem pesquisados
							NIL					,;	//Mensagem para MsgYesNo
							NIL					,;	//Titulo do Log de Delecao
							NIL					,;	//Mensagem para o corpo do Log
							.T.				 	,;	//Se executa AxDeleta
							.T.     			,;	//Se deve Mostrar o Log
							@aLog				,;	//Array com o Log de Exclusao
							@aLogTitle		 	 ;	//Array com o Titulo do Log
						)

//������������������������������������������������������Ŀ
//� Se !lChkDelOk , entra em  Modo Visualizacao          �
//��������������������������������������������������������
If  !lChkDelOk 
	nBrowseOpcx := 	2 
	AxVisual(cBrowseAlias,nReg,nBrowseOpcx ,/*aAcho*/,/*cFunc*/,/*aCpos*/,/*TudoOk*/,/*lF3*/,/*cTransact*/,/*aButtons*/,/*aParam*/,/*aRotAuto*/,/*lVirtual*/)
Endif

Return
/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �07/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �GPEM877                                                 �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()

 Local aRotina := { { STR0002,"PesqBrw", 0 , 1,,.F.},;  	//"Pesquisar"
					 { STR0003,"AxVisual", 0 , 2} } //,; 	//"Visualizar"
//					 { STR0004,"AxInclui", 0 , 3},; 	//"Incluir"
//					 { STR0005,"AxAltera", 0 , 4},; 	//"Alterar"
//					 { STR0006,"f340Exclu",0 , 5} } 	//"Excluir"
Return aRotina                                 



              
                            