#include "Protheus.ch"
#include "rspxfun.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ĵ��
���ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                      ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � FNC  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�06/08/14�TQENRX�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � RSPLoadExec	�Autor�  Igor Franzoi     � Data �29/06/2009�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao executada a cada rotina (menu) chamado pelo RSP		�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �RSPLoadExec													�
�����������������������������������������������������������������������Ĵ
� Uso      �Generico													�
�����������������������������������������������������������������������Ĵ
� Retorno  �															�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/
Function RSPLoadExec()

If FindFunction("SPFLoadExec()")
	SPFLoadExec()
EndIf

Return (Nil)


/*/
��������������������������������������������������������������������������Ŀ
�Fun��o    �ValidArqRsp   � Autor �Gustavo M.            � Data �20/04/2012�
��������������������������������������������������������������������������Ĵ
�Descri��o �Valida o Relacionamentos dos Arquivos do SIGARSP               �
��������������������������������������������������������������������������Ĵ
�Sintaxe   �ValidArqRsp( lShowHelp )                           			   �
��������������������������������������������������������������������������Ĵ
�Parametros�                                         					   �
��������������������������������������������������������������������������Ĵ
�Retorno   �lRet -> Se todos os Arquivos Estao com o Relacionamento Correto�
��������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	       �
��������������������������������������������������������������������������Ĵ
�Uso       �Generica                                                       �
����������������������������������������������������������������������������/*/
Function ValidArqRsp( lShowHelp )
Return( RspRelationFile( lShowHelp ) )

/*/
��������������������������������������������������������������������������Ŀ
�Fun��o    �PonRelationFile� Autor �Gustavo M.           � Data �20/04/2012�
��������������������������������������������������������������������������Ĵ
�Descri��o �Valida o Relacionamentos dos Arquivos do SIGARSP     		   �
��������������������������������������������������������������������������Ĵ
�Sintaxe   �RspRelationFile( void )                            			   �
��������������������������������������������������������������������������Ĵ
�Parametros�                                         					   �
��������������������������������������������������������������������������Ĵ
�Retorno   �lRet -> Se todos os Arquivos Estao com o Relacionamento Correto�
��������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	       �
��������������������������������������������������������������������������Ĵ
�Uso       �Generica                                                       �
����������������������������������������������������������������������������/*/
Function RspRelationFile( )

Local lRetModo		:= .F.
Local cTabela		:= ""
/*/
��������������������������������������������������������������Ŀ
� Coloca o Ponteiro do Mouse em Estado de Espera               �
����������������������������������������������������������������/*/
CursorWait()

/*/
��������������������������������������������������������������Ŀ
� Consiste o Modo de Acesso dos Arquivos                       �
����������������������������������������������������������������/*/
Begin Sequence    
	IF ( lRetModo := IF (xFilial("SQG")<>xFilial("SQL"),.T.,.F.))
		cTabela:="SQL" 
		Help(,,"RSPACESSO",,STR0001,1,0,,,,,,{STR0002}) //O compartilhamento entre as tabelas SQG, SQL, SQM, SQI e SQR deve ser igual.
		Break
	EndIF
	IF ( lRetModo := IF (xFilial("SQG")<>xFilial("SQM"),.T.,.F.)) 
		cTabela:="SQM"  
		Help(,,"RSPACESSO",,STR0001,1,0,,,,,,{STR0002}) //O compartilhamento entre as tabelas SQG, SQL, SQM, SQI e SQR deve ser igual.
		Break
	EndIF  
	IF ( lRetModo := IF (xFilial("SQG")<>xFilial("SQI"),.T.,.F.))  
		cTabela:="SQI" 
		Help(,,"RSPACESSO",,STR0001,1,0,,,,,,{STR0002}) //O compartilhamento entre as tabelas SQG, SQL, SQM, SQI e SQR deve ser igual.
		Break
	EndIF
	IF ( lRetModo := IF (xFilial("SQG")<>xFilial("SQR"),.T.,.F.))  
   		cTabela:="SQR"    
   		Help(,,"RSPACESSO",,STR0001,1,0,,,,,,{STR0002}) //O compartilhamento entre as tabelas SQG, SQL, SQM, SQI e SQR deve ser igual.
		Break
	EndIF
End Sequence

/*/
��������������������������������������������������������������Ŀ
� Restaura o Ponteiro do Mouse                                 �
�������������������������������������������������������������/*/
	
CursorArrow()


Return( lRetModo )