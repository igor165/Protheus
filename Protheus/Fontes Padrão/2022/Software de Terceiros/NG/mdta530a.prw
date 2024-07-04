#INCLUDE "mdta530.ch"
#Include "Protheus.ch"
/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �MDTA350A     � Autor �Andre E. Perez Alvarez � Data �23/10/2006���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Monta browse com as vacinas do funcionario selecionado.        ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � MDTA350A( )                                                   ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�                                                                ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                            ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � MDTA530                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������/*/
Function MDTA350A()

	Local aNGBEGINPRM := NGBEGINPRM()
	Local cFunCall    := FunName()
	asMenu := {}
	aNGButton := {}

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
	PRIVATE aRotina :=	MenuDef()

	Private bNgGrava := {|| MDT530INDV("N->TL9_DTREAL")}
	Private asMenu := NGRIGHTCLICK("MDTA530")

	If !(IsInCallStack( "MDTA110" ) .Or. IsInCallStack( "MDTA530" )) .And. !IsBlind()
		ShowHelpDlg( STR0013,;           //"ATEN��O"
					{ STR0021 }, 1,;     //"Execu��o n�o permitida."
					{ STR0022, "" }, 1 ) //"Rotina somente pode ser executada pelo menu de Ocorr�ncias Ficha (MDTA110) ou Vacinas (MDTA530)."
		Return .F.
	EndIf

	SetFunName("MDTA530A")
	dbSelectArea( "TL9" )
	SetBrwChgAll( .F. )
	mBrowse( 6, 1, 22, 75, "TL9" , ;
			/*aFixe*/ , /*cCpo*/ , /*nPar08*/ , /*cFun*/ , ;
			/*nClickDef*/ , /*aColors*/ , /*cTopFun*/ , ;
			/*cBotFun*/ , /*nPar14*/ , /*bInitBloc*/ , ;
			/*lNoMnuFilter*/ , /*lSeeAll*/ , /*lChgAll*/ , ;
			"TL9_FILIAL = " + ValToSQL( xFilial( "TL9" , TM0->TM0_FILIAL ) ) + " AND TL9_NUMFIC = " + ValToSQL( TM0->TM0_NUMFIC ) )

	Set Filter To

	NGRETURNPRM(aNGBEGINPRM)
	SetFunName(cFunCall)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de Menu Funcional
@type static function
@author Rafael Diogo Richter
@since 11/01/2007
@return array, op��es do menu com o seguinte layout:
				Parametros do array a Rotina:
				1. Nome a aparecer no cabecalho
				2. Nome da Rotina associada
				3. Reservado
				4. Tipo de Transa��o a ser efetuada:
					1 - Pesquisa e Posiciona em um Banco de Dados
					2 - Simplesmente Mostra os Campos
					3 - Inclui registros no Bancos de Dados
					4 - Altera o registro corrente
					5 - Remove o registro corrente do Banco de Dados
				5. Nivel de acesso
				6. Habilita Menu Funcional

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
	Local aRotina :=	{ { STR0001, "AxPesqui", 0 , 1},; //"Pesquisar"
						{ STR0002, "NGCAD01" , 0 , 2},; //"Visualizar"
						{ STR0003, "NGCAD01" , 0 , 3},; //"Incluir"
						{ STR0004, "MDT530ALT" , 0 , 4},; //"Alterar"
						{ STR0005, "MDT530ALT" , 0 , 5} } //"Excluir"
	If !lSigaMdtPs .AND. SuperGetMv("MV_NG2AUDI",.F.,"2") == "1"
		aAdd( aRotina , { STR0019 ,"MDTA991('TL9',{'TL9_NUMFIC','TL9_USERGI'},{'"+TM0->TM0_NUMFIC+"',STOD('"+DTOS(TM0->TM0_DTIMPL)+"')})" , 0 , 3 } )//"Hist. Exc."
	EndIf

Return aRotina