#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCFA011.CH"
/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � TCFA011  � Autor � Marinaldo de Jesus    � Data �19/12/2001�
�����������������������������������������������������������������������Ĵ
�Descri��o � Cadastrar mensagens para o funcionario                     �
�����������������������������������������������������������������������Ĵ
�Sintaxe   � TCFA011()                                                  �
�����������������������������������������������������������������������Ĵ
�         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             �
�����������������������������������������������������������������������Ĵ
�Programador � Data   � BOPS �  Motivo da Alteracao                     �
�����������������������������������������������������������������������Ĵ
�Cecilia Car.�24/07/14�TQEA22�Incluido o fonte da 11 para a 12 e efetua-�
�            �        �      �da a limpeza.                             �
�������������������������������������������������������������������������*/
Function TCFA011()

Local aArea			:= GetArea()
Local aAreaSRA		:= {}
Local aIndexSRA		:= {}
Local cFiltraSRA	:= ""
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= {"RA_NOME", "RA_RACACOR"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )
//Tratamento de acesso a Dados Sens�veis
If lBlqAcesso
	//"Dados Protegidos- Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Saiba mais em {link documenta��o centralizadora}"
	Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
	Return
EndIf

IF ChkVazio("SRA")

	Private bFiltraBrw	:= {|| NIL }
	Private cCadastro	:= OemToAnsi( STR0001 ) //"Mensagem Para o Funcion�rio"

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
	������������������������������������������������������������������������Ŀ
	� Inicializa o filtro utilizando a funcao FilBrowse                      �
	��������������������������������������������������������������������������*/
	cFiltraRh := CHKRH("GPEA120","SRA","1")
	bFiltraBrw 	:= {|| FilBrowse("SRA",@aIndexSRA,@cFiltraRH) }
	Eval(bFiltraBrw)

	/*
	��������������������������������������������������������������Ŀ
	� Endereca a funcao de BROWSE                                  �
	����������������������������������������������������������������*/
	aAreaSRA := SRA->( GetArea() )
	dbSelectArea("SRA")
	mBrowse( 6, 1,22,75,"SRA",,,,"SRA->RA_SITFOLH #'D'",,fCriaCor())

	/*
	������������������������������������������������������������������������Ŀ
	� Deleta o filtro utilizando a funcao FilBrowse                     	 �
	��������������������������������������������������������������������������*/
	EndFilBrw("SRA",aIndexSra)

	RestArea( aAreaSRA )

EndIF

RestArea( aArea )

Return( NIL )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TCFA011Msg� Autor �Marinaldo de Jesus     � Data �19/12/2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de cadastramento das mensagens ao funcionario        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �TCFA011Msg(cAlias,nReg,nOpc)								  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �TCFA011                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function TCFA011Msg(cAlias,nReg,nOpc)

Local cMsg				:= ""
Local nOk				:= 0.00
Local oDlg
Local oMemo
Local oFont
Local lTCFA0111Block  	:= ExistBlock( "TCFA0111" )//variavel ponto entrada

Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjCoords 	:= {}
Local aObjSize		:= {}

Local aAdv1Size		:= {}
Local aInfo1AdvSize	:= {}
Local aObj1Coords 	:= {}
Local aObj1Size		:= {}

IF Empty(SRA->RA_TCFMSG)
	cMsg := Space( 01 )
Else
	cMsg := APDMSMM(SRA->RA_TCFMSG)
EndIF

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

/*
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������*/
aAdvSize	:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 000 , 025 , .T. , .F. } )				//1-Cabecalho
aAdd( aObjCoords , { 000 , 000 , .T. , .T. , .T. } )		//2-TMultiGet
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )

//Divisao em colunas Linha 1-Cabecalho Dados Funcionario
aAdv1Size		:= aClone(aObjSize[1])
aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 1 , 1 }
aAdd( aObj1Coords , { 050 , 000 , .F. , .T. } )			//1-Matricula
aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			//2-Nome
aAdd( aObj1Coords , { 040 , 000 , .F. , .T. } )			//3-Admissao
aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords,,.T. )


DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5]  PIXEL		//"Mensagem Para o Funcion�rio"

  	@ aObj1Size[1,1], aObj1Size[1,2] GROUP oGroup TO aObj1Size[1,3], aObj1Size[1,4] LABEL OemToAnsi(STR0002) OF oDlg PIXEL				// "Matricula:"
	oGroup:oFont:= oFont
	@ aObj1Size[2,1], aObj1Size[2,2] GROUP oGroup TO aObj1Size[2,3], aObj1Size[2,4] LABEL OemToAnsi(STR0003) OF oDlg PIXEL				// "Nome:"
	oGroup:oFont:= oFont
	@ aObj1Size[3,1], aObj1Size[3,2] GROUP oGroup TO aObj1Size[3,3], aObj1Size[3,4] LABEL OemToAnsi(STR0004) OF oDlg PIXEL				// "Admiss�o:"
	oGroup:oFont:= oFont

	@ aObj1Size[1,1]+10, aObj1Size[1,2]+5	SAY StrZero(Val(SRA->RA_MAT),TamSx3("RA_MAT    ")[1]) 	SIZE 050,10 OF oDlg PIXEL FONT oFont
	@ aObj1Size[2,1]+10, aObj1Size[2,2]+5	SAY OemToAnsi(SRA->RA_NOME) 							SIZE 146,10 OF oDlg PIXEL FONT oFont
	@ aObj1Size[3,1]+10, aObj1Size[3,2]+5	SAY Dtoc(SRA->RA_ADMISSA)								SIZE 040,10 OF oDlg PIXEL FONT oFont

   	oMemo := TMultiget():New(aObjSize[2,1],aObjSize[2,2],{|u|if(Pcount()>0,cMsg:=u,cMsg)},;
                          oDlg,aObjSize[2,3],aObjSize[2,4],oFont,,,,,.T.,,,,,,.F.,,,,.T.)
	oMemo:lWordWrap:=.T.

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOk:=1,oDlg:End()},{||oDlg:End()}) CENTERED

//Gravando a mensagem
IF nOk == 1
	/*
	��������������������������������������������������������������Ŀ
	� Ponto de Entrada Antes da Gravacao Mensagem				   �
	����������������������������������������������������������������*/
	IF ( lTCFA0111Block )
		ExecBlock("TCFA0111",.F.,.F.)
	EndIf
	dbSelectArea("SRA")
	RecLock("SRA",.F.)
	APDMSMM(RA_TCFMSG,,,cMsg,1,,,"SRA","RA_TCFMSG")
	SRA->( MsUnlock() )
EndIF

Return( NIL )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    � MenuDef		�Autor�  Luiz Gustavo     � Data �28/12/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Isola opcoes de menu para que as opcoes da rotina possam    �
�          �ser lidas pelas bibliotecas Framework da Versao 9.12 .      �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �< Vide Parametros Formais >									�
�����������������������������������������������������������������������Ĵ
� Uso      �TCFA011                                                     �
�����������������������������������������������������������������������Ĵ
� Retorno  �aRotina														�
�����������������������������������������������������������������������Ĵ
�Parametros�< Vide Parametros Formais >									�
�������������������������������������������������������������������������*/

Static Function MenuDef()

 Local aRotina :=  { 	{ "Pesquisar"    	,"PesqBrw"	  , 0 , 1,,.F. } ,;
						{ "Cad Mensagem" 	,"TCFA011Msg" , 0 , 5 } ,;
						{ "Legenda" 	  	,"GpLegend"	  , 0 , 2, , .F.}  ;
						}

Return aRotina
