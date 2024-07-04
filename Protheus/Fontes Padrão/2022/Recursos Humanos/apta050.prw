#INCLUDE "protheus.ch"
#INCLUDE "apta050.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �APTA050   � Autor � TANIA BRONZERI     � Data �  24/03/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Comarca / Forum                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Comarca / Forum                                ���
�������������������������������������������������������������������������͹��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĺ��
���Programador � Data     � BOPS �  Motivo da Alteracao                   ��� 
�������������������������������������������������������������������������Ĺ��
���Cecilia Car.�04/08/2014�TQEQ39�Incluido o fonte da 11 para a 12 e efetu���  
���            �          �      �ada a limpeza.                          ��� 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function APTA050( cAlias , nReg , nOpc , lExecAuto , lMaximized )

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local aArea			:= GetArea()
LOCAL cFiltraREC	:= ""					
LOCAL aIndexREC		:= {}					
Local lExistOpc		:= ( ValType( nOpc ) == "N" )
Local uRet

Private cCadastro	:= OemToAnsi(STR0001)	//"Cadastro de Comarcas / Foruns" 
Private bFiltraBrw 	:= {|| Nil}				


//���������������������������������������������������������������������Ŀ
//� Monta um aRotina proprio                                            �
//�����������������������������������������������������������������������

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina


cAlias				:= "REC"
dbSelectArea("REC")      
Private cDelFunc 	:= ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

IF ( lExistOpc )      
/*	��������������������������������������������������������������Ŀ
	�Garante o Posicinamento do Recno                              �
	����������������������������������������������������������������*/
	DEFAULT nReg	:= ( cAlias )->( Recno() )
	IF !Empty( nReg )
		( cAlias )->( MsGoto( nReg ) )
	EndIF

	DEFAULT lExecAuto := .F.

	IF ( lExecAuto )
		nPos := aScan( aRotina , { |x| x[4] == nOpc } )
		IF ( nPos == 0 )
			Break
		EndIF
		bBlock := &( "{ |a,b,c,d| " + aRotina[ nPos , 2 ] + "(a,b,c,d) }" )
		uRet := Eval( bBlock , cAlias , nReg , nPos )
	Else
		DEFAULT lMaximized := .F.
		uRet := Apta050Mnt( cAlias , nReg , nOpc , lMaximized )
	EndIF
Else             
	//������������������������������������������������������������������������Ŀ
	//� Inicializa o filtro utilizando a funcao FilBrowse                      �
	//��������������������������������������������������������������������������
	cFiltraRh := CHKRH("APTA050","REC","1")
	bFiltraBrw 	:= {|| FilBrowse("REC",@aIndexREC,@cFiltraRH) }
	Eval(bFiltraBrw)

	dbSelectArea("REC")
	dbSetOrder(1)
	mBrowse( 6,1,22,75,"REC")

	//������������������������������������������������������������������������Ŀ
	//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
	//��������������������������������������������������������������������������
	EndFilBrw("REC",aIndexREC)
EndIf

RestArea( aArea )

Return( uRet )


/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �Apta050Mnt�Autor�Tania Bronzeri           � Data �14/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Comarcas e F�runs ( Manutencao )	        	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>          							�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>          							�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico  	                                                �
�������������������������������������������������������������������������*/
Function Apta050Mnt( cAlias , nReg , nOpc , lMaximized )

Local uRet
cAlias				:= "REC"
DEFAULT nReg		:= ( cAlias )->( Recno() )
DEFAULT nOpc 		:= 2
DEFAULT lMaximized	:= .T.
     
Begin Sequence

	IF ( nOpc == 1 )
		uRet := PesqBrw( cAlias , nReg )
	ElseIF ( nOpc == 2 )
		uRet := AxVisual( cAlias , nReg , nOpc , NIL , NIL , NIL , NIL , NIL , lMaximized )
	ElseIF ( nOpc == 3 )
		uRet := AxInclui( cAlias , nReg , nOpc , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , lMaximized )
	ElseIF ( nOpc == 4 )
		uRet := AxAltera( cAlias , nReg , nOpc , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL , lMaximized )
	ElseIF ( nOpc == 5 )   
		If (ChkDelRegs("REC"))
			RecLock("REC",.F.)
			uRet := AxDeleta( cAlias , nReg , nOpc , NIL , NIL , NIL , NIL , NIL , lMaximized )
			MSUnlock()
		Endif
	EndIF

End Sequence
	
Return( uRet )


                 
/*/ Material para c�pia

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �APTA120Vis�Autor�Tania Bronzeri           � Data �07/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Registros de Classe ( Visualizar )	        	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>          							�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>          							�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico  	                                                �
�������������������������������������������������������������������������/
Function APTA120Vis ( cAlias , nReg )
Return( Apta120Mnt( cAlias , nReg , 2 , .F. ) )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �APTA120Inc�Autor�Tania Bronzeri           � Data �07/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cadastro de Registros de Classe ( Incluir )		        	�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<vide parametros formais>          							�
�����������������������������������������������������������������������Ĵ
�Parametros�<vide parametros formais>          							�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico  	                                                �
�������������������������������������������������������������������������/
Function APTA120Inc( cAlias , nReg )
Return( Apta120Mnt( cAlias , nReg , 3 , .F. ) )

/*

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �ReuSxbFilter�Autor�Marinaldo de Jesus       �Data�08/04/2004�
�����������������������������������������������������������������������Ĵ
�Descri��o �Filtro de Consulta Padrao para o REU						�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									�
�����������������������������������������������������������������������Ĵ
�Uso       �Consulta Padrao (SXB)				                  	   	�
�������������������������������������������������������������������������/
Function ReuSxbFilter()
         
Local cReadVar	:= Upper( AllTrim( ReadVar() ) )
Local cRet		:= ""

//RE2 = Advogados
IF ( "RE2_TP_REG" $ cReadVar )
	IF ( IsInGetDados( { "RE2_CODPES" , "RE2_TP_REG" } ) )
		cRet := "@#REU->REU_CODPES=='"+GdFieldGet("RE2_CODPES")+"'@#"
	ElseIF ( IsMemVar( "RE2_CODPES" ) .and. IsMemVar( "RE2_TP_REG" )  )
		cRet := "@#REU->REU_CODPES=='"+GetMemVar("RE2_CODPES")+"'@#"
	EndIF
Else
//...codigo semelhante ao acima...
EndIF

Return( cRet )


/*/

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �19/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �APTA050                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()

Local aRotina :=	{ 	{ STR0002 ,"AxPesqui"	,	0	,1,,.F. } ,;
             			{ STR0003 ,"AxVisual"	,	0	,2 } ,;
            			{ STR0004 ,"AxInclui"	,	0	,3 } ,;
             			{ STR0005 ,"AxAltera"	,	0	,4 } ,;
             			{ STR0006 ,"Apta050Mnt"	,	0	,5 } }
Return aRotina