#include "Protheus.ch"
#include "RSPA210.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � RSPA210  � Autor � Emerson Grassi Rocha  � Data � 30/11/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de tipo de Cursos                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSPA210                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Avoid                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RSPA210                                                    ���
��������������������������������������������������������������������������ٱ�
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS   �  Motivo da Alteracao                   ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�29/07/14�TQENN4  �Incluido o fonte da 11 para a 12 e efetu���
���            �        �        �ada a limpeza.                          ���
���Christiane V�25/09/14�TQPLR8  �Valida��es p/inlcus�o de novos registros���
��������������������������������������������������������������������������ٱ� 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function RSPA210

LOCAL cFiltra	:= ""				//Variavel para filtro
LOCAL aIndFil	:= {}				//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

Private	aAC := {STR0001,STR0002}		//"Abandona"###"Confirma"

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemtoAnsi(STR0008)	//"Cadastro de Tipos de Cursos"

//��������������������������������������������������������������Ŀ
//� Inicializa a tabela com registros obrigatorios para Portal.  �
//����������������������������������������������������������������
Rs210Carga()

//������������������������������������������������������������������������Ŀ
//� Inicializa o filtro utilizando a funcao FilBrowse                      �
//��������������������������������������������������������������������������
dbSelectArea("SQX")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"SQX","1")
bFiltraBrw 	:= {|| FilBrowse("SQX",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("SQX")
dbGoTop()

mBrowse(6, 1, 22, 75, "SQX")

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("SQX",aIndFil)

dbSelectArea("SQX")
dbSetOrder(1)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Rs210Alt � Autor � Emerson Grassi Rocha  � Data � 05/04/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Trata a alteracao de Tipos de Cursos   					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Rs210Alt(cExpC1,nExpN1,nExpN2)                             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RSPA210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Rs210Alt(cAlias,nReg,nOpc)

// Verifica se registro foi criado pelo sistema
If Val(SQX->QX_CODIGO) < 5
	Aviso(STR0010, STR0017, {"Ok"}) // "Atencao"###"Verifique realmente a necessidade desta altera��o, pois este � um registro criado pelo sistema."
EndIf
AxAltera( cAlias,nReg,nOpc )

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Rs210Del � Autor � Emerson Grassi Rocha  � Data � 30/11/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Trata a delecao de Tipos de Cursos   					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Rs210Del(cExpC1,nExpN1,nExpN2)                             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RSPA210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Rs210Del(cAlias,nReg,nOpc)
Local bCampo
Local oDlg
Local nOpca		:= 0
Local cIndCond	:= 0
Local cArqNtx	:= "" 

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aTELA[0][0],aGETS[0]
bCampo 	:= {|nCPO| Field(nCPO) }

nOpcA	:= 0
dbSelectArea(cAlias)

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize		:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 1 , 1 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords ) 

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
  	nOpcA:=EnChoice( cAlias, nReg, nOpc, aAC,"AC",OemToAnsi(STR0009),,aObjSize[1],,,,,,,,,)	//"Quanto a exclus�o?"
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nOpca:=2,oDlg:End()},{|| nOpca:=1,oDlg:End()})

dbSelectArea(cAlias)

If nOpcA == 2 

	// Verifica se registro foi criado pelo sistema
	If Val(SQX->QX_CODIGO) < 5
		Aviso(STR0010, STR0016, {"Ok"}) // "Atencao"###"Este Tipo nao pode ser deletado, pois � utilizado no Portal."

		dbSelectArea(cAlias)
		Return .F.
	EndIf
	
	// Verifica se o Tipo esta sendo usado no cadastro de Cursos
	dbSelectArea("SQT")
	dbSetOrder(3)
	If dbSeek(xFilial("SQT")+SQX->QX_CODIGO)
		Aviso(STR0010, STR0011, {"Ok"}) // "Atencao"###"Este Tipo nao pode ser deletado, pois existem cursos cadastrados para ele."

		dbSelectArea(cAlias)
		Return .F.
	EndIf

	Begin Transaction	
		dbSelectArea(cAlias)
		RecLock(cAlias,.F.)
			dbDelete()
		MsUnlock()		
	End Transaction
EndIf

dbSelectArea(cAlias)

Return .T.  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Rs210Carga� Autor � Emerson Grassi Rocha  � Data � 05/04/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializa Tabela de Tipos de Cursos quando esta vazia.	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Rs210Carga()   					                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � RSPA210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Rs210Carga()

Local aSaveArea := GetArea()
Local aDados	:= {}
Local nx		:= 0

dbSelectArea("SQX")
dbSetOrder(1) 
IF !dbSeek(xFilial("SQX")+"001")

	Aadd(aDados,{"001",STR0012	,"",""})	//"Formacao Academica"
	Aadd(aDados,{"002",STR0013	,"",""})	//"Certificacao"
	Aadd(aDados,{"003",STR0014	,"",""})	//"Idioma"	
	Aadd(aDados,{"004",STR0015	,"",""})  	//"Curso Relevante"

	Begin Transaction	
		For nx := 1 To Len(aDados)
			RecLock("SQX",.T.)
				SQX->QX_FILIAL 	:= xFilial("SQX")
				SQX->QX_CODIGO 	:= aDados[nx][1]
				SQX->QX_DESC 	:= aDados[nx][2]
				SQX->QX_NIVEL 	:= aDados[nx][3]
				SQX->QX_STATUS 	:= aDados[nx][4]
			MsUnlock()		  
		Next nx
	End Transaction
	
EndIf
RestArea(aSaveArea)

Return Nil   

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RSP210Tok � Autor � Inova��o RH           � Data � 25.09.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Incluisao de Tipos de Cursos                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSP210Tok()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RSPA210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function RSP210Tok()
Local lRet := .T.

//Verifica se o c�digo que est� sendo inclu�do � c�digo de sistema
IF Val(M->QX_CODIGO) < 5
	Aviso(STR0010, STR0018, {"Ok"}) // "Atencao"###"Verifique realmente a necessidade desta altera��o, pois este � um registro criado pelo sistema."
	lRet := .F.
Endif

Return lRet


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RSP210Inc � Autor � Inova��o RH           � Data � 25.09.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Incluisao de Tipos de Cursos                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSP120Inc(ExpC1,ExpN1,ExpN2)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RSPA210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Rs210Inc(cAlias,nReg,nOpc,xRotAuto)
Local nOpca			:=	0
Local aRotAuto
Local aCampos 		:= {}

RSP210Uso(@aCampos)
	
If xRotAuto <> NIL
	aRotAuto := aClone(xRotAuto)
Endif
	
nOpca := AxInclui(cAlias,nReg,nOpc,aCampos, , ,"RSP210Tok()",,,,,aRotAuto)

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RSP100Uso � Autor � IP Rh Inovacao        � Data � 08.03.12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega os campos a serem apresentados na Enchoice         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RSP100Uso(ExpC1) 			                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Array com os campos a serem apresentados Enchoice  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RSPA100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function RSP210Uso(aCampos)
Local aArea 	:= GetArea()
aCampos := {}

SX3->(dbSetOrder(1))
If SX3->( dbSeek( "SQX" ) )
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SQX"
		If (X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL )
			aAdd( aCampos , AllTrim(SX3->X3_CAMPO) )
		Endif
		SX3->(dbSkip())
    Enddo
Endif
RestArea(aArea)

Return

/*                                	
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �27/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �RSPA210                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/   

Static Function MenuDef()
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
 Local aRotina := { 	{ STR0003, 'PesqBrw'	, 0, 1,,.F.}, ;	//'Pesquisar'
						{ STR0004, 'AxVisual'	, 0, 2}, ;		//'Visualizar'
						{ STR0005, 'Rs210Inc'	, 0, 3}, ;		//'Incluir'
						{ STR0006, 'Rs210Alt'	, 0, 4}, ;		//'Alterar'
						{ STR0007, 'Rs210Del'	, 0, 5,3} }		//'Excluir'

Return aRotina