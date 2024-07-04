#INCLUDE "Mdta670.ch"
#Include "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MDTA670  � Autor � Thiago Olis Machado   � Data � 03/05/01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Cadastro do Plano de Acao por Mandato          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDTA670

//�����������������������������������������������������������������������Ŀ
//� Armazena variaveis p/ devolucao (NGRIGHTCLICK) 							  �
//�������������������������������������������������������������������������
Local aNGBEGINPRM := NGBEGINPRM()

Private cCliMdtPs := Space(Len(SA1->A1_COD+SA1->A1_LOJA))

lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro

If lSigaMdtps
	cCadastro := OemtoAnsi(STR0007)  //"Clientes"

	DbSelectArea("SA1")
	DbSetOrder(1)

	mBrowse( 6, 1,22,75,"SA1")
Else

	//��������������������������������������������������������������Ŀ
	//� Define o cabecalho da tela de atualizacoes                   �
	//����������������������������������������������������������������
	PRIVATE aCHKDEL := {}, bNGGRAVA
	cCadastro := OemtoAnsi(STR0006) //"Plano de Acao X Mandato"

	//��������������������������������������������������������������Ŀ
	//�aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-�
	//�s�o do registro.                                              �
	//�                                                              �
	//�1 - Chave de pesquisa                                         �
	//�2 - Alias de pesquisa                                         �
	//�3 - ordem de pesquisa                                         �
	//��������������������������������������������������������������
	//aCHKDEL :={ {'TNS->TNS_MANDAT'    , "TNR", 1}}

	//��������������������������������������������������������������Ŀ
	//� Endereca a funcaO de BRoWSE                                  �
	//����������������������������������������������������������������
	DbSelectArea("TNV")
	DbSetorder(1)
	mBrowse( 6, 1,22,75,"TNV")

Endif

//�����������������������������������������������������������������������Ŀ
//� Devolve variaveis armazenadas (NGRIGHTCLICK) 							  	  �
//�������������������������������������������������������������������������
NGRETURNPRM(aNGBEGINPRM)

Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MD670EXC � Autor � An�nimo               � Data � ?        ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MD670EXC(cAli,nRecno,nOpcx)

Local aOld := aClone(aRotina)
Local nIndTNV
Local cSeekTNV

Private aRotina := { { STR0001, "AxPesqui"  , 0 , 1},; //"Pesquisar"
                     { STR0002, "AxPesqui"  , 0 , 1},; //"Visualizar"
                     { STR0003, "AxPesqui"  , 0 , 1},; //"Incluir"
                     { STR0005, "AxPesqui"  , 0 , 1},; //"Alterar"
                     { STR0003, "AxPesqui"  , 0 , 1}}  //"Excluir"

Private aTela[0][0],aGets[0],aHeader[0],nUsado:=0
nOpc := 5

If lSigaMdtps
	nIndTNV := 2
	cSeekTNV := xFilial("TNV")+cCliMdtps+TNV->TNV_MANDAT+TNV->TNV_CODPLA
Else
	nIndTNV := 1
	cSeekTNV := xFilial("TNV")+TNV->TNV_MANDAT+TNV->TNV_CODPLA
Endif

DbSelectArea("TNV")
DbSetOrder(nIndTNV)
If DbSeek(cSeekTNV)
	lRet := NGCAD01("TNV",RECNO(),5)
EndIf

aRotina := aClone(aOLD)

lRefresh := .T.

DbSelectArea("TNV")
DbGoTop()

Return Nil
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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
Static Function MenuDef()

Local lPyme      := If(Type("__lPyme") <> "U",__lPyme,.F.)
Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Local aRotina

If lSigaMdtps
	aRotina := { { STR0001, "AxPesqui"  , 0 , 1},; //"Pesquisar"
	             { STR0002, "NGCAD01"   , 0 , 2},; //"Visualizar"
	             { STR0008, "MDT670TNV" , 0 , 4} } //"Planos de A��o"
Else
	aRotina :=	{ { STR0001, "AxPesqui" , 0 , 1},; //"Pesquisar"
                  { STR0002, "NGCAD01"  , 0 , 2},; //"Visualizar"
                  { STR0003, "NGCAD01"  , 0 , 3},; //"Incluir"
                  { STR0005, "MD670EXC" , 0 , 5, 3}}  //"Excluir"

	If !lPyme
		aAdd(aRotina, { STR0009, "MsDocument", 0, 4 } )  //"Conhecimento"
	EndIf
Endif

Return aRotina
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT670TNV� Autor � Andre Perez Alvarez   � Data � 25/10/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Cadastro do Plano de Acao por Mandato          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT670TNV()

	Local aArea	    := GetArea()
	Local oldROTINA := aCLONE(aROTINA)
	Local oldCad    := cCadastro
	Local lPyme     := If(Type("__lPyme") <> "U",__lPyme,.F.)
	Local aNao      := { 'TNV_CLIENT', 'TNV_LOJA', 'TNV_FILIAL'}

	cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA

	aRotina :=	{ { STR0001, "AxPesqui" , 0 , 1},; //"Pesquisar"
				{ STR0002, "NGCAD01"  , 0 , 2},; //"Visualizar"
				{ STR0003, "NGCAD01"  , 0 , 3},; //"Incluir"
				{ STR0005, "MD670EXC" , 0 , 5, 3}}  //"Excluir"

	If !lPyme
		aAdd(aRotina, { STR0009, "MsDocument", 0, 4 } )  //"Conhecimento"
	EndIf

	//��������������������������������������������������������������Ŀ
	//� Define o cabecalho da tela de atualizacoes                   �
	//����������������������������������������������������������������
	Private cCadastro := OemtoAnsi(STR0006) //"Plano de Acao X Mandato"
	Private aCHKDEL := {}, bNGGRAVA

	aCHOICE := {}

	aCHOICE := NGCAMPNSX3( 'TNV' , aNao )

	//��������������������������������������������������������������Ŀ
	//�aCHKDEL array que verifica a INTEGRIDADE REFERENCIAL na exclu-�
	//�s�o do registro.                                              �
	//�                                                              �
	//�1 - Chave de pesquisa                                         �
	//�2 - Alias de pesquisa                                         �
	//�3 - ordem de pesquisa                                         �
	//��������������������������������������������������������������
	//aCHKDEL :={ {'TNS->TNS_MANDAT'    , "TNR", 1}}

	//��������������������������������������������������������������Ŀ
	//� Endereca a funcaO de BRoWSE                                  �
	//����������������������������������������������������������������
	DbSelectArea("TNV")
	Set Filter To TNV->(TNV_CLIENT+TNV_LOJA) == cCliMdtps
	DbSetorder(2)  //TNV_FILIAL+TNV_CLIENT+TNV_LOJA+TNV_MANDAT+TNV_CODPLA
	mBrowse( 6, 1,22,75,"TNV")

	DbSelectArea("TNV")
	Set Filter To

	aROTINA := aCLONE(oldROTINA)
	RestArea(aArea)
	cCadastro := oldCad

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT615NOM� Autor � Andre Perez Alvarez   � Data � 25/10/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializa o campo TNV_NOMPLA                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT615NOM(lIniBrw)

Local cDesc
Local aArea := GetArea()
Local cCodPla:=If(lIniBrw,TNV->TNV_CODPLA,M->TNV_CODPLA)

SG90PLACAO()//Adequa��o do Plano de A��o.

cDesc := Posicione( cAliasPA, nIndexPA, xFilial( cAliasPA ) + cCliMdtps + cCodPla, aFieldPA[3])

RestArea(aArea)
Return cDesc

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT670VCIP� Autor � Denis                 � Data � 25/10/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo TNV_MANDAT                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT670VCIP()
Local lPrest := .F.

If Type("cCliMdtPs") == "C"
	If !Empty(cCliMdtPs)
		lPrest := .T.
	Endif
Endif

If lPrest
	Return EXISTCPO("TNN",M->TNV_CLIENT+M->TNV_LOJA+M->TNV_MANDAT,3)
Else
	Return EXISTCPO("TNN",M->TNV_MANDAT)
Endif

Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT670VPLA� Autor � Denis                 � Data � 25/10/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo TNV_CODPLA                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT670VPLA()
Local lPrest := .F.

SG90PLACAO()//Adequa��o do Plano de A��o.

If Type("cCliMdtPs") == "C"
	If !Empty(cCliMdtPs)
		lPrest := .T.
	Endif
Endif

lRetPA := .T.
If lPrest
	lRetPA := (EXISTCPO(cAliasPA,cCliMdtps+M->TNV_CODPLA,5) .AND. EXISTCHAV("TNV",cCliMdtps+M->TNV_MANDAT+M->TNV_CODPLA,4))
Else
	lRetPA := (EXISTCPO(cAliasPA,AllTrim(M->TNV_CODPLA)) .AND. EXISTCHAV("TNV",AllTrim(M->TNV_MANDAT+M->TNV_CODPLA)))
Endif

If lRetPA .And. NGCADICBASE(aFieldPA[29],"A",cAliasPA,.F.)
	dbSelectArea( cAliasPA )
	dbSetOrder(nIndexPA)
	dbSeek(cSeekPA+AllTrim(M->TNV_CODPLA))
	If !((cAliasPA)->&(aFieldPA[29]) $ "1/3")
		lRetPA := .F.
		Help(" ",1,"REGNOIS")
	Endif
Endif

Return lRetPA