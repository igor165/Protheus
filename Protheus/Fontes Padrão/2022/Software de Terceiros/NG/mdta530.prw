#INCLUDE "mdta530.ch"
#Include "Protheus.ch"

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDTA530      � Autor � Andre E. Perez Alvarez� Data �23/10/06  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Cadastro de Vacinas do Funcionario                 ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � MDTA530()                                                      ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�                                                                ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   � Booleano                                                       ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � SIGAMDT - Medicina e Seguranca do Trabalho                     ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Function MDTA530()

//��������������������������������������������Ŀ
//�Guarda conteudo e declara variaveis padroes �
//����������������������������������������������
Local aNGBEGINPRM := NGBEGINPRM()

Private lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )

Private aRotina := MenuDef()
Private cCadastro
Private aCHKDEL := {}, bNGGRAVA
Private asMenu

If FindFunction("MDTRESTRI") .AND. !MDTRESTRI(cPrograma)
	//�����������������������������������������������������������������������Ŀ
	//� Devolve variaveis armazenadas (NGRIGHTCLICK) 			 			  �
	//�������������������������������������������������������������������������
	NGRETURNPRM(aNGBEGINPRM)
	Return .F.
Endif

If lSigaMdtPS
	//��������������������������������������������������������������Ŀ
	//� Define o cabecalho da tela de atualizacoes                   �
	//����������������������������������������������������������������
	cCadastro := OemtoAnsi(STR0009) //"Clientes"

	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	DbSelectArea( "SA1" )
	DbSetOrder( 1 )
	mBrowse( 6, 1, 22, 75, "SA1" )
Else

	asMenu := NGRIGHTCLICK("MDTA005")
	//��������������������������������������������������������������Ŀ
	//� Define o cabecalho da tela de atualizacoes                   �
	//����������������������������������������������������������������
	cCadastro := OemtoAnsi(STR0006) //"Vacinas do Funcion�rio"

	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	DbSelectArea( "TM0" )
	DbSetOrder( 1 )
	SetBrwChgAll( .F. )
	mBrowse( 6, 1, 22, 75, "TM0",,,,,,fFichaCor() )
Endif

//��������������������������������������������Ŀ
//�Retorna conteudo de variaveis padroes       �
//����������������������������������������������
NGRETURNPRM(aNGBEGINPRM)
Return .T.

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MdtValDose   � Autor �Denis Hyroshi de Souza � Data �23/10/2006���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o campo Dose da Vacina                                  ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � MdtValDose(M->TL9_NUMFIC,M->TL9_VACINA,M->TL9_DOSE)            ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�                                                                ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                            ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � MDTA530                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Function MdtValDose(cTL9_NUMFIC,cTL9_VACINA,cTL9_DOSE)
Local lRet := .f.
Local aArea := GetArea()

If Vazio(cTL9_DOSE)
	Return .t.
Endif

dbSelectArea("TM0")
dbSetOrder(1)
dbSeek(xFilial("TM0")+cTL9_NUMFIC)

nIdadeFun := Year(dDataBase) - Year(TM0->TM0_DTNASC) // Idade do Funcionario
If SubStr(DTOS(dDataBase),5,4) < SubStr(DTOS(TM0->TM0_DTNASC),5,4)
	nIdadeFun := nIdadeFun - 1 // Dimunui 1 ano se ainda nao fez aniversario no ano corrente
Endif

If lSigaMdtps
	dbSelectArea("TL7")
	dbSetOrder(4)  //TL7_FILIAL+TL7_CLIENT+TL7_LOJA+TL7_VACINA+TL7_IDADEI
	dbSeek(xFilial("TL7")+cCliMdtps+cTL9_VACINA)
	While !eof() .and. xFilial("TL7")+cCliMdtps+cTL9_VACINA == TL7->TL7_FILIAL+TL7->TL7_CLIENT+TL7->TL7_LOJA+TL7->TL7_VACINA .and. !lRet
		If nIdadeFun >= Val(TL7->TL7_IDADEI) .and. nIdadeFun <= Val(TL7->TL7_IDADEF)
			dbSelectArea("TL8")
			dbSetOrder(4)  //TL8_FILIAL+TL8_CLIENT+TL8_LOJA+TL8_VACINA+TL8_IDADEI+TL8_DOSEID
			If dbSeek(xFilial("TL8")+cCliMdtps+cTL9_VACINA+TL7->TL7_IDADEI+cTL9_DOSE)
				lRet := .t.
			Endif
		Endif
		dbSelectArea("TL7")
		dbSkip()
	End
Else
	dbSelectArea("TL7")
	dbSetOrder(1)
	dbSeek(xFilial("TL7")+cTL9_VACINA)
	While !eof() .and. xFilial("TL7")+cTL9_VACINA == TL7->TL7_FILIAL+TL7->TL7_VACINA .and. !lRet
		If nIdadeFun >= Val(TL7->TL7_IDADEI) .and. nIdadeFun <= Val(TL7->TL7_IDADEF)
			dbSelectArea("TL8")
			dbSetOrder(1)
			If dbSeek(xFilial("TL8")+cTL9_VACINA+TL7->TL7_IDADEI+cTL9_DOSE)
				lRet := .t.
			Endif
		Endif
		dbSelectArea("TL7")
		dbSkip()
	End
Endif

If !lRet
	Help(" ",1,"REGNOIS")
Endif

RestArea(aArea)
Return lRet
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Rafael Diogo Richter  � Data �29/11/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Utilizacao de Menu Funcional.                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaMDT                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef( lMdtPs )

Local aRotina

Default lMdtPs := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
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
If lMdtPs
	aRotina := { { STR0001,   "AxPesqui"  , 0 , 1},; //"Pesquisar"
	             { STR0002,   "NGCAD01"   , 0 , 2},; //"Visualizar"
	             { STR0010,   "MDT530FU" , 0 , 4} }  //"Funcion�rios"
Else
	aRotina :=	{ { STR0001, "AxPesqui" , 0 , 1},; //"Pesquisar"
                  { STR0002, "NGCAD01"  , 0 , 2},; //"Visualizar"
                  { STR0007, "MDTA350A", 0 , 3},; //"Vacinas"
				  { STR0015, "GpLegend" , 0 , 6, 0, .F.} }  //"Legenda"
Endif

Return aRotina
/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT530FU   � Autor � Andre Perez Alvarez     � Data �21/09/07  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Monta um browse com os funcionarios do cliente.                ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � MDT530FU()                                                     ���
�����������������������������������������������������������������������������Ĵ��
���Parametros�                                                                ���
���          �                                                                ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �                                                                ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � SIGAMDT                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������/*/
Function MDT530FU()

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0006) //"Vacinas do Funcion�rio"
PRIVATE aCHKDEL := {}, bNGGRAVA
Private asMenu  := NGRIGHTCLICK("MDTA005")

cCliMDTPS := SA1->(A1_COD+A1_LOJA)

aRotina :=	MenuDef( .F. )

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
DbSelectArea( "TM0" )
Set Filter To TM0->(TM0_CLIENT+TM0_LOJA) == cCliMDTPS
DbSetOrder( 1 )
mBrowse( 6, 1, 22, 75, "TM0",,,,,,fFichaCor() )

DbSelectArea( "TM0" )
Set Filter To

Return

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT530INDV  � Autor �Vitor Emanuel Batista    � Data �17/03/2010���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo TL9_INDVAC                                        ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   �                                                                ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � MDTA530                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������/*/
Function MDT530INDV(cReadVar)

Default cReadVar := ReadVar()

If NGCADICBASE("TL9_INDVAC","A","TL9",.F.)
	If cReadVar == "M->TL9_INDVAC"
		If M->TL9_INDVAC != "1"
			M->TL9_DTREAL := CTOD("  /  /  ")
		EndIf
	Else
		If M->TL9_INDVAC == "1"
			If Empty(M->TL9_DTREAL)
				ShowHelpDlg(STR0013,	{STR0011},1,; //"ATEN��O"##"Data realizada da vacina��o n�o poder� estar vazia quando campo 'Vacinado' estiver como 'Sim'."
				 				{STR0014},1) //"Preencha a data ou altere o campo 'Vacinado'."
				Return .F.
			EndIf
			If !Empty(M->TL9_DTREAL) .And. (M->TL9_DTREAL > dDataBase)
				ShowHelpDlg(STR0016,{STR0017},1,{STR0018},1)
				Return .F.
		    Endif
		ElseIf !Empty(M->TL9_DTREAL)
			ShowHelpDlg(STR0013,	{STR0012},1,; //"ATEN��O"##"Data realizada da vacina��o dever� estar vazia quando campo 'Vacinado' estiver diferente de 'Sim'."
			 				{STR0014},1) //"Preencha a data ou altere o campo 'Vacinado'."
			Return .F.
		EndIf
	EndIf
EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} MDT530ALT
Define funcao de alteracao/exclusao para validacao do usuario (SBIS)
Uso MDTA530

@return Nil

@sample
MDT503ALT()

@author Jackson Machado
@since 21/08/2012
/*/
//---------------------------------------------------------------------
Function MDT530ALT(cAlias,nReg,nOpcx)
Local cCpsTst := If( NGCADICBASE("TL9_USERGA","A","TL9",.F.) .And. !Empty(TL9->TL9_USERGA),"TL9->TL9_USERGA" ,"TL9->TL9_USERGI" )

If FindFunction("MDTRESTRI") .AND. NGCADICBASE("TMK_USUARI","A","TMK",.F.) .AND. !Empty(TL9->TL9_DTREAL) .AND. ;
		!MDTRESTUS(MDTDATALO(cCpsTst,.F.))
	Return .F.
ElseIf nOpcx == 5 .AND. FindFunction("MDTEXCSBI") .AND. NGCADICBASE("TMK_USUARI","A","TMK",.F.) .AND. ;
		!Empty(TL9->TL9_DTREAL) .AND. !MDTEXCSBI(MDTDATALO("TL9->TL9_USERGI"))
	Return .F.
Endif
NGCAD01(cAlias,nReg,nOpcx)
Return .T.