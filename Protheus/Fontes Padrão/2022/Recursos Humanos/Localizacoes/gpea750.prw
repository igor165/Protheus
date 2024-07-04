#INCLUDE "PROTHEUS.CH"      
#INCLUDE "GPEA750.CH"        

/*/
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������Ŀ��
���Fun��o    � GPEA750  � Autor � Alceu Pereira                   � Data � 28/07/08 ���
�����������������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastramento de Convenios                                           ��� 
�����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPEA750()                                                            ���
�����������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                             ���
�����������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                       ���
�����������������������������������������������������������������������������������Ĵ��
���Programador � Data   � FNC/CHAMADO    �  Motivo da Alteracao                     ���
�����������������������������������������������������������������������������������Ĵ��
���Glaucia M.  �22/05/12�00000010444/2012�Com novo dicionario de dados ARG Modelo 2,���
���            �        �          TEWMBN�houve a necessidade de trocar de chave de ���
���            �        �                �relacionamento na exclus�o.				���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������*/

Function GPEA750()    

LOCAL cFiltraRh				//Variavel para filtro    
LOCAL aIndexRGM	:= {}		//Variavel Para Filtro    

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
Private cCadastro := OemToAnsi( STR0001 )  //"Cadastro de Sindicatos"
                             
//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
cFiltraRh := CHKRH("GPEA750","RGM","1")
bFiltraBrw 	:= {|| FilBrowse("RGM",@aIndexRGM,@cFiltraRh)}
Eval(bFiltraBrw)   

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea( "RGM" )
dbGoTop()

mBrowse( 6, 1,22,75,"RGM",,,,,,)    

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("RGM",aIndexRGM)

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPEA750   �Autor  �Alceu Pereira       � Data �  29/007/08  ���
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
Function  f750Exclu(cBrowseAlias, nReg, nBrowseOpcx )

Local aArea			:= GetArea()           
Local cKeyDel		:= RGM_CODCON  
Local nAreasCpo		:= 3.00
Local nAreas		:= 0.00
Local lChkDelOk		:= .F.
Local aAreas 		:= {} 
Local cAlias		:= Alias() 
Local cMsgNoDelOk

//������������������������������������������������������������������������Ŀ
//� Tabelas onde deverao se verificadas a existencia do codigo p/ delecao  �
//��������������������������������������������������������������������������
//-- SRA 
aAdd( aAreas , Array( 03 ) )   
nAreas := Len( aAreas )
aAreas[nAreas,01] := SRA->( GetArea() )
aAreas[nAreas,02] := Array( 2 )
aAreas[nAreas,02,01] := "RA_FILIAL"
aAreas[nAreas,02,02] := "RA_CODCONV"
aAreas[nAreas,03] := RetOrdem( "SRA"  , "RA_FILIAL+RA_CODCONV" , .T. )

//RCE
aAdd( aAreas , Array( 03 ) )
nAreas := Len( aAreas )
aAreas[nAreas,01] := RCE->( GetArea() )
aAreas[nAreas,02] := Array( 2 )
				aAreas[nAreas,02,01] := "RCE_FILIAL"
				aAreas[nAreas,02,02] := "RCE_CODCON"
aAreas[nAreas,03] := RetOrdem( "RCE" , "RCE_FILIAL+RCE_CODCON" , .T. )


//������������������������������������������������������������������������Ŀ
//� Verifica se o Registro esta sendo utilizado                            �
//��������������������������������������������������������������������������
( cAlias )->( MsGoto( nReg ) )
lChkDelOk	:= ChkDelRegs(	cAlias						,;	//01 -> Alias do Arquivo Principal
									nReg				,;	//02 -> Registro do Arquivo Principal
									nBrowseOpcx			,;	//03 -> Opcao para a AxDeleta
									xFilial( cAlias )	,;	//04 -> Filial do Arquivo principal para Delecao
									cKeyDel				,;	//05 -> Chave do Arquivo Principal para Delecao
									aAreas				,;	//06 -> Array contendo informacoes dos arquivos a serem pesquisados
									NIL					,;	//07 -> Mensagem para MsgYesNo
									NIL					,;	//08 -> Titulo do Log de Delecao
									NIL					,;	//09 -> Mensagem para o corpo do Log
									.F. 		 		,;	//10 -> Se executa AxDeleta
									.T.					,;	//11 -> Se deve Mostrar o Log
									NIL					,;	//12 -> Array com o Log de Exclusao
									NIL		 			,;	//13 -> Array com o Titulo do Log
									NIL					,;	//14 -> Bloco para Posicionamento no Arquivo
									NIL					,;	//15 -> Bloco para a Condicao While
									NIL					,;	//16 -> Bloco para Skip/Loop no While
									.F.					,;	//17 -> Verifica os Relacionamentos no SX9
									NIL					 ;	//18 -> Alias que nao deverao ser Verificados no SX9
								 )


if lChkDelOk
	AxDeleta(cAlias,nReg,nBrowseOpcx)		
Endif

RestArea(aArea)

Return( lChkDelOk )

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Alceu Pereira    � Data �29/07/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      |GPEA750                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()    

 Local aRotina := { { STR0002,"PesqBrw", 0 , 1,,.F.},; //"Pesquisar"
					 { STR0003,"AxVisual", 0 , 2},; 	//"Visualizar"
					 { STR0004,"AxInclui", 0 , 3},; 	//"Incluir"
					 { STR0005,"AxAltera", 0 , 4},; 	//"Alterar"
					 { STR0006,"f750Exclu", 0 , 5}} 	//"Excluir"
Return aRotina