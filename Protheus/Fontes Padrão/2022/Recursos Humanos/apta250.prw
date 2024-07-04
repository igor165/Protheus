#INCLUDE "protheus.ch"
#INCLUDE "apta250.ch"

Static cIdiom := FWRetIdiom()

/*/
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������ͻ��
���Programa  �APTA250   � Autor � TANIA BRONZERI                 � Data �  01/04/2004 ���
�������������������������������������������������������������������������������������͹��
���Descricao � Cadastro de Categorias de Tipos                                        ���
���          �                                                                        ���
�������������������������������������������������������������������������������������͹��
���Uso       � Cadastro de Categorias de Tipos                                        ���
�������������������������������������������������������������������������������������͹��
���        ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                          ���
�������������������������������������������������������������������������������������Ķ��
���Programador � Data     � BOPS �  Motivo da Alteracao                               ���
�������������������������������������������������������������������������������������Ķ��
���Cecilia Car.�12/08/2014�TQEQCC     �Incluido o fonte da 11 para a 12 e efetuada a  ���
���            �          �           �limpeza.                                       ���
���Tiago Malta �24/08/2015�PCREQ-4824 �Ajustes no controle de altera��es e consultas  ���
���			   �		  �	   		  �de dicionarios para utiliza��o na vers�o 12.   ���
���		       �		  �	   		  �Changeset 247252 Data 18/08/2014               ���
�������������������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
/*/

Function APTA250(nOpcAuto,bFiltro080,lTp080)
Local aAreaREK	:= REK->( GetArea() )
LOCAL cFiltraREK		  						//Variavel para filtro
LOCAL aIndexREK	:= {}						//Variavel Para Filtro
Local cFiltro           
Default lTp080	:=	.F.

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
       
Private cCadastro	:= "Categorias de Tipos" 
Private bFiltraBrw := {|| Nil}				//Variavel para Filtro

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
cFiltraRh 	:= CHKRH("APTA250","REK","1") 
cFiltro		:= Iif(Empty(cFiltraRh),"",cFiltraRh + ' .And. ')
cFiltro		+= 'REK->REK_MODULO == nModulo .And. Substr(REK->REK_TABELA,1,1) == "U"'

bFiltraBrw 	:= {|| FilBrowse("REK",@aIndexREK,@cFiltro) }
dbSelectArea("REK")
dbSetOrder(2)

Eval(bFiltraBrw)

mBrowse( 6,1,22,75,"REK")

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������

IF lTp080	//Ve se foi chamado pelo APTA080, restaura o filtro anterior
	Default bFiltro080	:=	bFiltraBrw
	Eval(bFiltro080)
Else
	EndFilBrw("REK",aIndexREK)
EndIF
RestArea (aAreaREK)	
       	
Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �APTA250Inc� Autor � TANIA BRONZERI     � Data � 03/10/2005  ���
�������������������������������������������������������������������������͹��
���Descricao �Manutencao de Categorias de Tipos - Inclusao                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Categorias de Tipos                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Apta250Inc( cAlias , nReg , nOpc )
                           
nOpc	:=	3

Return Apta250Mnt( cAlias , nReg , nOpc )


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �APTA250Alt� Autor � TANIA BRONZERI     � Data � 03/10/2005  ���
�������������������������������������������������������������������������͹��
���Descricao �Manutencao de Categorias de Tipos - Alteracao               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Categorias de Tipos                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Apta250Alt( cAlias , nReg , nOpc )

nOpc	:=	4
       
Apta250Mnt( cAlias , nReg , nOpc )
        
Eval(bFiltraBrw)

Return Nil


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �APTA250Exc� Autor � TANIA BRONZERI     � Data � 03/10/2005  ���
�������������������������������������������������������������������������͹��
���Descricao �Manutencao de Categorias de Tipos - Exclusao                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Categorias de Tipos                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Apta250Exc( cAlias , nReg , nOpc )

nOpc	:=	5

Return Apta250Mnt( cAlias , nReg , nOpc )


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �APTA250Mnt� Autor � TANIA BRONZERI     � Data � 29/09/2005  ���
�������������������������������������������������������������������������͹��
���Descricao �Manutencao de Categorias de Tipos                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de Categorias de Tipos                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Apta250Mnt( cAlias , nReg , nOpc )

Local aArea 		:= {}
Local uRet
Local nOpca
Local nCont			:= 0
Local cCampo		:= ""
Local bCampo
Local aCposIdioma	:= {}
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aPos			:= {}
Private aTELA[0][0],aGETS[0]

cAlias				:= "REK"
bCampo := {|nCPO| Field(nCPO) }

DEFAULT nReg		:= ( cAlias )->( Recno() )
DEFAULT nOpc 		:= 2

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize( )
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
aPos := {aObjSize[1,1],aObjSize[1,2],aObjSize[1,3],aObjSize[1,4]}
     
Begin Sequence
dbSelectArea("REK")
	FOR nCont := 1 TO FCount()
		cCampo := EVAL(bCampo,nCont)
		M->&(cCampo) := FieldGet(nCont)
		If ValType(M->&(cCampo)) = "C" 
			M->&(cCampo) := SPACE(LEN(M->&(cCampo)))
		ElseIf ValType(M->&(cCampo)) = "N"
			M->&(cCampo) := 000
		ElseIf ValType(M->&(cCampo)) = "D"
			M->&(cCampo) := CtoD("  /  /  ")
		ElseIf ValType(M->&(cCampo)) = "L"
			M->&(cCampo) := .F.
		EndIf           
	Next nCont
	
	IF cIdiom == "es" 
		aCposIdioma	:=	{ "REK_TABELA" , "REK_DSCSPA" , "NOUSER    " }
	ELSEIF cIdiom == "en"             
		aCposIdioma	:=	{ "REK_TABELA" , "REK_DSCENG" , "NOUSER    " }
	ELSE                                          
		aCposIdioma	:=	{ "REK_TABELA" , "REK_DESCR"  , "NOUSER    " }
	ENDIF

	IF ( nOpc == 3 )
		PutFileInEof( "REK" )
		DEFINE MSDIALOG oDlg TITLE cCadastro From aAdvSize[7],0 to aAdvSize[6],aAdvSize[5] of oMainWnd PIXEL
		nOpcA := EnChoice( cAlias, nReg, nOpc, , , , aCposIdioma, aPos, , , , , , , , , , , , .F. )	
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| if(Obrigatorio(aGets,aTela) ,(nOpca := 1,oDlg:End()),.f.)},{|| nOpca := 2,oDlg:End() }) CENTERED
		uRet	:= Iif (nOpca == 1,	Apt250Grava(3),.F.)
	ElseIF ( nOpc == 4 )
		REK->( DbSetOrder(1))
		uRet := AxAltera( cAlias , nReg	, nOpc	, aCposIdioma )
	ElseIF ( nOpc == 5 )   
		Begin Transaction
			aArea := GetArea()
			RE5->( dbSetOrder(1))
			IF !(RE5->( dbSeek(xFilial("REK")+REK->REK_TABELA) )) .And. (Left(REK->REK_TABELA,1)#"S") 
				dbSelectArea(cAlias)
				dbSetOrder(1)
				nReg	:= ( cAlias )->( Recno() )
				If (ChkDelRegs(cAlias))
					RecLock(cAlias,.F.)
					uRet := AxDeleta( cAlias , nReg , 5 , NIL , aCposIdioma , NIL , NIL , NIL , .T. )
					MSUnlock()
				Endif
			ElseIF (Left(REK->REK_TABELA,1)=="S")
				Aviso( STR0006, STR0008, { "OK" } )		// "Atencao!"###"As Categorias Microsiga nao podem ser alteradas ou excluidas."
			ElseIF (RE5->( dbSeek(xFilial("REK")+REK->REK_TABELA) ))
				Aviso( STR0006, STR0007, { "OK" } )		// "Atencao!"###"Ha tipo cadastrado para esta categoria. A mesma nao pode ser excluida."
			EndIf		
			RestArea( aArea )
		End Transaction
 	EndIF

End Sequence
	
Return( uRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fRekPict  � Autor � Tania Bronzeri        � Data �03/10/2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Altera Picture para inclusao de Cateborias - X3_Pictvar     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fPict                                                      ���
�������������������������������������������������������������������������Ĵ��
���Par�metros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � Gen�rico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function fRekPict()
Local cPicture	:= "@!R XXXX" +"%C"
Local bCampo 	:= {|nCPO| Field(nCPO) }
Local cCampo 	:= EVAL(bCampo,2)

IF ( Inclui )
	/*
	�����������������������������������������������������Ŀ
	� Altera a Marca do Campo REK_TABELA carregando o "U" �
	�������������������������������������������������������*/
    IF ( cCampo ="REK_TABELA" )
		IF ( Left( M->REK_TABELA , 1 ) # "U" )		//--Verificar se ja esta com  a picture para nao aplica-la novamente
			cPicture := ( "@!R UXXX"  + "%C" )		//--"U" no inicio do nome da categoria para que apareca
		EndIF											//--na digitacao do campo
	EndIF
EndIF

Return( cPicture )


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �Apt250Grava� Autor � Tania Bronzeri        � Data �03/10/2005���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Grava os dados da Categoria          	 	 	 	 	   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � APTA250                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������/*/
Static Function Apt250Grava(nTipOp)

dbSelectArea( "REK" )
If nTipOp = 3 
	REK->(RecLock("REK",.T.,.T.) )			//Inclusao
Else
	REK->(RecLock("REK",.F.,.T.) )			//Alteracao
Endif
REK->REK_FILIAL 	:= xFilial()
If Left(M->REK_TABELA,1) #"U" .and. nTipOp == 3 
	REK->REK_TABELA	:= Upper( "U" + StrTran(M->REK_TABELA," ","") )  //-- nao permite espacos no nome da categoria
Else
	REK->REK_TABELA	:= Upper( StrTran(M->REK_TABELA," ","") )
Endif

IF cIdiom == "es" 
	REK->REK_DSCSPA		:= Upper( AllTrim(M->REK_DSCSPA) )
ELSEIF cIdiom == "en"               
	REK->REK_DSCENG		:= Upper( AllTrim(M->REK_DSCENG) )
ELSE                                          
	REK->REK_DESCR 		:= Upper( AllTrim(M->REK_DESCR) )
ENDIF
REK->REK_MODULO		:= nModulo
REK->( MsUnLock() )

Return

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �15/01/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �APTA250                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()

//���������������������������������������������������������������������Ŀ
//� Monta um aRotina proprio                                            �
//�����������������������������������������������������������������������

Private aRotina := { 	{ STR0004 ,"AxPesqui"	,	0	,1,,.F.} ,;		//Pesquisar
             			{ STR0005 ,"AxVisual"	,	0	,2 } ,;		//Visualizar
						{ STR0001 ,"Apta250Inc"	,	0	,3 } ,;		//Inclui
             			{ STR0002 ,"Apta250Alt"	,	0	,4 } ,;		//Altera
             			{ STR0003 ,"Apta250Exc"	,	0	,5 } }		//Exclui

Return aRotina
