#INCLUDE "mdta545.ch"
#Include "Protheus.ch"

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDTA545      � Autor � Ricardo Dal Ponte     � Data �13/10/06  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Cadastro de Tipos de Inspecao                      ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � SIGAMDT - Medicina e Seguranca do Trabalho                     ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������/*/
Function MDTA545()

	//Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	Local aNGBEGINPRM := NGBEGINPRM()
	Private lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
	Private aCHKDEL   := {}, bNGGRAVA  := {}
	Private aRotina
	Private lUpd := .F.

	// Variaveis parametro NGCAD02
	Private aCHOICE   := {}
	Private aVARNAO   := {}
	Private aGETNAO   := {}
	Private cGETMAKE  := ""
	Private cGETKEY   := ""
	Private cGETWHILE := ""
	Private cGETALIAS := ""
	Private cTUDOOK   := ""
	Private cLINOK    := ""

	If !NGCADICBASE("TK6_EVENTO","D","TK6",.F.)
		If !NGINCOMPDIC("UPDMDT04","000000173022010")
			Return .F.
		Endif
	Endif

	If NGCADICBASE("TKT_FAMILI","D","TKT",.F.)
		lUpd := .T.
	Endif

	If lUpd
		aRotina := MenuDef()
	Else
		// Define as condicoes do NGCAD02
		MDTA545DEF()
		aRotina := oldMenuDef()
	Endif
	If lSigaMdtps

		// Define o cabecalho da tela de atualizacoes
		cCadastro := OemtoAnsi(STR0007)  //"Clientes"
		aCHKDEL := { {'TLB->TLB_CLIENT+TLB->TLB_LOJA+TLB->TLB_CODIGO' , "TLD", 10} }

		//Endereca a funcao de BROWSE
		DbSelectArea("SA1")
		DbSetOrder(1)
		mBrowse( 6, 1,22,75,"SA1")

	Else

		//Define o cabecalho da tela de atualizacoes
		cCadastro := OemtoAnsi(STR0006) //"Tipos de Inspe��o"
		aCHKDEL := { {'TLB->TLB_CODIGO' , "TLD", 3} }

		// Endereca a funcao de BROWSE
		DbSelectArea("TLB")
		DbSetOrder(1)
		mBrowse( 6, 1,22,75,"TLB")

	Endif

	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM(aNGBEGINPRM)

Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Andre Perez Alvarez   � Data �05/01/2008���
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
Static Function oldMenuDef()

	Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
	Local aRotina

	If lSigaMdtps
		aRotina :={ { STR0001,   "AxPesqui"  , 0 , 1},; //"Pesquisar"
					{ STR0002,   "NGCAD02"   , 0 , 2},; //"Visualizar"
					{ STR0006,   "MDT545TLB" , 0 , 4} } //"Tipos de Inspe��o"
	Else
		aRotina :={ {  STR0001, "AxPesqui"		, 0 , 1},; 		//"Pesquisar"
					{  STR0002, "NGCAD02"  		, 0 , 2},; 		//"Visualizar"
					{  STR0003, "NGCAD02"  		, 0 , 3},; 		//"Incluir"
					{  STR0004, "MDTA545EXI" 	, 0 , 4},; 		//"Alterar"
					{  STR0005, "NGCAD02" 		, 0 , 5, 3} } 	//"Excluir"
	Endif

Return aRotina
/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT545TLB  � Autor �Andre E. Perez Alvarez   � Data �04/02/08  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Mostra os extintores do cliente                                ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � MDTA545                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������/*/
Function MDT545TLB(cAlias,nReg,nOpcx)

Local aArea	:= GetArea()
Local oldROTINA := aCLONE(aROTINA)
Local oldCad := cCadastro
cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA

aRotina :=	{ { STR0001 , "AxPesqui", 0 , 1},; //"Pesquisar"
              {  STR0002, "NGCAD02" , 0 , 2},; //"Visualizar"
              {  STR0003, "NGCAD02" , 0 , 3},; //"Incluir"
              {  STR0004, "MDTA545EXI" , 0 , 4},; //"Alterar"
              {  STR0005, "NGCAD02" , 0 , 5, 3} } //"Excluir"

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
cCadastro := OemtoAnsi(STR0006) //"Tipos de Inspe��o"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
DbSelectArea("TLB")
Set Filter To TLB->(TLB_CLIENT+TLB_LOJA) == cCliMdtps
DbSetOrder(3)  //TLB_FILIAL+TLB_CLIENT+TLB_LOJA+TLB_CODIGO
mBrowse( 6, 1,22,75,"TLB")

DbSelectArea("TLB")
Set Filter To

aROTINA := aCLONE(oldROTINA)
RestArea(aArea)
cCadastro := oldCad

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �MDTA545DEF�Autor  �Wagner S. de Lacerda� Data �  08/06/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � Define as variaveis utilizadas para montar o NGCAD02 e a   ���
���          � GetDados.                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � MDTA555                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MDTA545DEF()

/* Define os campos que aparecerao na tela */
aCHOICE := {}

/* Define os campos que nao serao mostrados em tela, mas serao gravados */
aVARNAO := {}

/* Define os campos que nao devem ser chamados na GetDados */
aGETNAO := { {"TK6_INSPEC" , "TLB->TLB_CODIGO"} }

/* Define a variavel de pesquisa (sem filial) da GetDados */
cGETMAKE  := "TLB->TLB_CODIGO"

/* Define a chave de pesquisa (sem filial) da GetDados */
cGETKEY := "M->TLB_CODIGO + M->TK6_EVENTO"

/* Define a expressao while da chave de pesquisa da GetDados */
cGETWHILE := "TK6->TK6_FILIAL == xFilial('TK6') .And. TK6->TK6_INSPEC == M->TLB_CODIGO"

/* Define o nome do alias  da GetDados */
cGETALIAS := "TK6"

/* Define a validacao geral da GetDados */
cTUDOOK := "AllwaysTrue()"

/* Define a validacao da linha atual  da GetDados */
cLINOK := "AllwaysTrue()"

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �MDTA545VLE�Autor  �Wagner S. de Lacerda� Data �  09/06/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida se existe o evento na TK4 e se nao esta' duplicado  ���
���          � na aCols.                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � MDTA555                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MDTA545VLE()

Local nCont := 0 // Contador do 'For'
Local nPos  := aScan(aHeader, {|x| AllTrim(Upper(X[2])) == "TK6_EVENTO" }) // Coluna do campo

If !ExistCpo("TK4",M->TK6_EVENTO)
	Return .F.
Else
	For nCont := 1 To Len(aCols)
		If aCols[nCont] <> aCols[n] .And. !aCols[nCont][Len(aHeader)+1]
			If AllTrim(aCols[nCont][nPos]) == AllTrim(M->TK6_EVENTO)
				MsgInfo(STR0008,STR0009) //"Este evento j� est� sendo utilizado!"###"ATEN��O"
				Return .F.
			EndIf
		EndIf
	Next cCont
EndIf

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �MDTA545REL�Autor  �Wagner S. de Lacerda� Data �  09/06/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � Carrega o inicializador padrao do campo TK6_DESCRI.        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Retorno   � cRel -> Descricao do Evento.                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MDTA555                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MDTA545REL()

Local cRel   := "" // conteudo do X3_RELACAO
Local nCont  := 0  // contador do 'For'
Local cEvent := "" // recebe o evento da aCols
Local nPos   := aScan(aHeader, {|x| AllTrim(Upper(X[2])) == "TK6_EVENTO" }) // Coluna do campo

If Len(aCols) > 0
	For nCont := 1 To Len(aCols)
		cEvent := aCols[nCont][nPos]
		cRel   := NGSEEK("TK4",cEvent,1,"TK4->TK4_DESCRI")
	Next nCont
EndIf

Return cRel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �MDTA545EXI�Autor  �Wagner S. de Lacerda� Data �  10/06/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se ja' existe uma Ordem de Inspecao aberta com    ���
���          � este Tipo de Inspecao.                                     ���
�������������������������������������������������������������������������͹��
���Retorno   � .T. -> Nao ha' O.I. aberta, pode alterar.                  ���
���          � .F. -> Ja' existe uma O.I. aberta, nao pode alterar.       ���
�������������������������������������������������������������������������͹��
���Uso       � MDTA555                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MDTA545EXI(cAlias, nReg, nOpcx)

Local lRet  := .T.
Local aAreaTLB := TLB->( GetArea() )

//dbSelectArea("TLD")
//dbSetOrder(3)
//If dbSeek(xFilial("TLB")+TLB->TLB_CODIGO)
//	MsgInfo("J� foi aberta uma Ordem de Inspe��o contendo"+Chr(13)+;
//			  "este Tipo de Inspe��o!"+Chr(13)+Chr(13)+;
//			  "Altera��o n�o permitida.","ATEN��O")
//	lRet := .F.
//EndIf

If lRet
	// Define as condicoes do NGCAD02
	MDTA545DEF()

	NGCAD02(cAlias, nReg, nOpcx)

EndIf

RestArea(aAreaTLB)

Return lRet

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT545VTIP � Autor � Denis                   � Data �21/06/10  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Valida codigo TLB_CODIGO                                       ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � MDTA545                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Function MDT545VTIP()
Local lPrest := .F.

If Type("cCliMdtPs") == "C"
	If !Empty(cCliMdtPs)
		lPrest := .T.
	Endif
Endif

If lPrest
	Return (EXISTCHAV("TLB",cCliMdtps+M->TLB_CODIGO,3))
Else
	Return (EXISTCHAV("TLB",M->TLB_CODIGO,1))
Endif

Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor �Jackson Machado	     � Data �16/05/11  ���
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

Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Local aRotina

If lSigaMdtps
	aRotina := { { STR0001,   "AxPesqui"  , 0 , 1},; //"Pesquisar"
	             { STR0002,   "MDTA545IN"   , 0 , 2},; //"Visualizar"
	             { STR0006,   "MDT545MD" , 0 , 4} } //"Tipos de Inspe��o"
Else
	aRotina :=	{ { STR0001 , "AxPesqui", 0 , 1},; //"Pesquisar"
                  {  STR0002, "MDTA545IN" , 0 , 2},; //"Visualizar"
                  {  STR0003, "MDTA545IN" , 0 , 3},; //"Incluir"
                  {  STR0004, "MDTA545IN" , 0 , 4},; //"Alterar"
                  {  STR0005, "MDTA545IN" , 0 , 5, 3} } //"Excluir"
Endif

Return aRotina
/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT545MD   � Autor �Jackson Machado	         � Data �16/05/11  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Mostra os extintores do cliente                                ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � MDTA545                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������/*/
Function MDT545MD(cAlias,nReg,nOpcx)

Local aArea	:= GetArea()
Local oldROTINA := aCLONE(aROTINA)
Local oldCad := cCadastro
cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA

aRotina :=	{ { STR0001 , "AxPesqui", 0 , 1},; //"Pesquisar"
              {  STR0002, "MDTA545IN" , 0 , 2},; //"Visualizar"
              {  STR0003, "MDTA545IN" , 0 , 3},; //"Incluir"
              {  STR0004, "MDTA545IN" , 0 , 4},; //"Alterar"
              {  STR0005, "MDTA545IN" , 0 , 5, 3} } //"Excluir"

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
cCadastro := OemtoAnsi(STR0006) //"Tipos de Inspe��o"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
DbSelectArea("TLB")
Set Filter To TLB->(TLB_CLIENT+TLB_LOJA) == cCliMdtps
DbSetOrder(3)  //TLB_FILIAL+TLB_CLIENT+TLB_LOJA+TLB_CODIGO
mBrowse( 6, 1,22,75,"TLB")

DbSelectArea("TLB")
Set Filter To

aROTINA := aCLONE(oldROTINA)
RestArea(aArea)
cCadastro := oldCad

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDTA545IN | Autor � Jackson Machado		  � Data �13/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tela de manutencao da Brigada                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDTA545IN(cAlias, nRecno, nOpcx)
	Local oFont,oGet,oDlg,nX2
	Local nControl := 0
	Local aPages   := {}
	Local aTitles  := {}
	Local cCadOpt  := ""
	Local nBRIGADA := 0
	Local nCODCC:= 0
	Local nX
	Local lAltProg := .T.

	Private aCols
	Private aCoBrwA := {}
	Private aHoBrwA := {}
	Private aCoBrwB := {}
	Private aHoBrwB := {}
	Private oBrwA
	Private lAltInd  := .t.
	Private cCodExp  := 0
	Private cMemoFor := ''
	Private aSvATela := {}, aSvAGets := {}, aTela := {}, aGets := {}, aNao := {}
	Private oMemoFor, oCodVar, oCodExp
	Private oBtn01, oBtn02, oBtn03, oBtn04, oBtn05, oBtn06, oBtnAdd, oBtnLim, oBtnDes, aNoFields
	Private nLenA := 0, nLenB := 0
	Private aColsScr := {}

	dbSelectArea("TLB")
	RegToMemory("TLB",(nOpcx == 3))

	aCols:={}
	aHeader:={}
	aNoFields:={}

	aAdd(aNoFields,"TK6_INSPEC")
	aAdd(aNoFields,"TK6_FILIAL")

	If lSigaMdtps
		aAdd(aNoFields, "TK6_CLIENT")
		aAdd(aNoFields, "TK6_LOJA")
	Endif
	nInd		:= 1
	cKeyTPY	:="TLB->TLB_CODIGO"
	cGETWHTPB:= "TK6->TK6_FILIAL == '"+xFilial("TK6")+"' .AND. TK6->TK6_INSPEC == '"+TLB->TLB_CODIGO+"'"

	dbSelectArea("TK6")
	dbSetOrder(nInd)
	FillGetDados( nOpcx, "TK6", nInd, cKeyTPY, {|| }, {|| .T.},aNoFields,,,,;
				{|| NGMontaAcols("TK6",&cKeyTPY,cGETWHTPB)})

	If Empty(aCols) .Or. nOpcx == 3
		aCols :=BLANKGETD(aHeader)
	Endif
	aCoBrwA := ACLONE(aCols)
	aHoBrwA := ACLONE(aHeader)
	nLenA   := Len(aCoBrwA)

	aCols:={}
	aHeader:={}
	aNoFields:={}

	aAdd(aNoFields,"TKT_INSPEC")
	aAdd(aNoFields,"TKT_FILIAL")

	If lSigaMdtps
		aAdd(aNoFields, "TKT_CLIENT")
		aAdd(aNoFields, "TKT_LOJA")
	Endif
	nInd		:= 1
	cKeyTPY	:="TLB->TLB_CODIGO"
	cGETWHTPB:= "TKT->TKT_FILIAL == '"+xFilial("TKT")+"' .AND. TKT->TKT_INSPEC == '"+TLB->TLB_CODIGO+"'"

	dbSelectArea("TKT")
	dbSetOrder(nInd)
	FillGetDados( nOpcx, "TKT", nInd, cKeyTPY, {|| }, {|| .T.},aNoFields,,,,;
				{|| NGMontaAcols("TKT",&cKeyTPY,cGETWHTPB)})
	If Empty(aCols) .Or. nOpcx == 3
		aCols :=BLANKGETD(aHeader)
	Endif
	aCoBrwB := ACLONE(aCols)
	aHoBrwB := ACLONE(aHeader)
	nLenB   := Len(aCoBrwB)

	If nOpcx == 2 .or. nOpcx == 5
		lAltProg := .f.
	Endif

	// Inicializa variaveis para campos Memos Virtuais
	If Type("aMemos") == "A"
		For nX2 := 1 To Len(aMemos)
			cMemo := "M->" + aMemos[nX2][2]
			If ExistIni(aMemos[nX2][2])
				&cMemo := InitPad( GetSx3Cache( aMemos[ nX2 , 2 ]  , 'X3_RELACAO' ) )
			Else
				&cMemo := ""
			EndIf
		Next nX2
	EndIf

	If nOpcx == 3
		cCadOpt  := " - "+STR0003 //"Incluir"
	ElseIf nOpcx == 2
		cCadOpt  := " - "+STR0002 //"Visualizar"
		lAltInd := .f.
	ElseIf nOpcx == 5
		cCadOpt  := " - "+STR0005 //"Excluir"
		lAltInd := .f.
	ElseIf nOpcx == 4
		cCadOpt  := " - "+STR0004 //"Alterar"
	EndIf

	//aChoice recebe os campos que serao apresentados na tela
	aNao    := {}
	aChoice := NGCAMPNSX3("TLB",aNao)
	aTela   := {}
	aGets   := {}

	//Tamanho da tela
	Private aAC := {STR0010,STR0011},aCRA:= {STR0011,STR0012,STR0010} //"Abandona"###"Confirma"###"Confirma"###"Redigita"###"Abandona"
	Private aHeader[0],Continua,nUsado:=0
	Private aSize := MsAdvSize(,.f.,430), aObjects := {}
	Aadd(aObjects,{200,200,.t.,.f.})
	aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
	aPosObj := MsObjSize(aInfo, aObjects,.t.)

	//Criando Folders
	Aadd(aTitles,OemToAnsi(STR0013)) //"Eventos"
	Aadd(aTitles,OemToAnsi(STR0014)) //"Fam�lia"
	Aadd(aPages,"Header 1")
	Aadd(aPages,"Header 2")
	nControl := 4

	nOpca:=0
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7],0 To aSize[6],aSize[5] COLOR CLR_BLACK,CLR_WHITE OF oMainWnd PIXEL

		oPnlPai := TPanel():New( , , , oDlg , , , , , , , , .F. , .F. )
			oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

			//Enchoice tabela TLB
			@ 000,000 MSPANEL oPanel SIZE 0,0 OF oPnlPai
			oPanel:Align := CONTROL_ALIGN_TOP
			oPanel:nHeight := 150
			If aSize[6] > 600
				oPanel:nHeight := 200
			Endif

			oEnc01:= MsMGet():New("TLB",nRecno,nOpcx,,,,aChoice,{13,0,89,aPosObj[1,4]},,,,,,oPanel,,,.f.,"aSvATela")
			oEnc01:oBox:Align := CONTROL_ALIGN_ALLCLIENT
			oEnc01:oBox:bGotFocus := {|| NgEntraEnc("TLB")}
			aSvATela := aClone(aTela)
			aSvAGets := aClone(aGets)
			@ 062,010 BUTTON STR0014 SIZE 49,12 ACTION(MDT545FAM(nOpcx)) OF oPnlPai WHEN M->TLB_CATEGO == "2" PIXEL //Fam�lia

			//Folders
			oFolder := TFolder():New(7,0,aTitles,aPages,oPnlPai,,,,.f.,.f.,aPosObj[1,4],aPosObj[1,3],)
			oFolder:Align := CONTROL_ALIGN_ALLCLIENT

			//Folder 1 - Eventos
			oFolder:aDialogs[1]:oFont := oDlg:oFont
			nTelaX := ( aSize[6]/2.02 ) - 108

			dbSelectArea("TK6")
			PutFileInEof("TK6")
			oBrwA   := MsNewGetDados():New(20,1,nTelaX,220,IIF(!lAltProg,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
										{|| MDT545LIOK("TK6") },{|| .T. },,,,9999,,,,oFolder:aDialogs[1],aHoBrwA,aCoBrwA)
			oBrwA:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oBrwA:oBrowse:Refresh()
			oBrwA:oBrowse:bLostFocus := {|| MDT545LIOK("TK6")}

			//Folder 2 - Familia
			oFolder:aDialogs[2]:oFont := oDlg:oFont
			nTelaX := ( aSize[6]/2.02 ) - 108

			dbSelectArea("TKT")
			PutFileInEof("TKT")
			oBrwB   := MsNewGetDados():New(20,1,nTelaX,220,IIF(!lAltProg,0,GD_INSERT+GD_UPDATE+GD_DELETE),;
										{|| MDT545LIOK("TKT") },{|| .T. },,,,9999,,,,oFolder:aDialogs[2],aHoBrwB,aCoBrwB)
			oBrwB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oBrwB:oBrowse:bLostFocus := {|| MDT545LIOK("TKT")}
			oBrwB:oBrowse:Default()
			oBrwB:oBrowse:Disable()
			If AllTrim(TLB->TLB_CATEGO) == "2" .AND. !INCLUI
				oBrwB:oBrowse:Enable()
			Endif
			oBrwB:oBrowse:Refresh()

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{||nOpca:=1,If(!A545Ok(nOpcx),nOpca := 0,oDlg:End())},{||oDlg:End()}) CENTERED

	If nOpca == 1
	A545GRAVA(cAlias,nRecno,nOpcx)
	Endif

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    | A545Ok   � Autor � Jackson Machado       � Data �22/02/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Checa se est� tudo ok para grava��o dos dados			     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A545Ok(nOpcx)
aCoBrwA := aClone(oBrwA:aCols)
aCoBrwB := aClone(oBrwB:aCols)
If nOpcx != 2 .and. nOpcx != 5
	//Verifica Enchoice
	If !Obrigatorio(aGets,aTela)
		Return .F.
	Endif
	//Verifica GetDados de Eventos
	If !MDT545LIOK("TK6",.T.)
		Return .F.
	Endif
	//Verifica GetDados de Fam�lia
	If !MDT545LIOK("TKT",.T.)
		Return .F.
	Endif
Elseif nOpcx == 5
	If !NGVALSX9("TLB",,.T.)

	Endif
Endif
Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A545GRAVA � Autor � NG INFORMATICA        � Data �01/10/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao chamada para gravacao                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A545GRAVA(cAliasX,nRecnoX,nOpcx)
Local i, j, ny
Local aArea := GetArea()
Local nOrd, cKey, cWhile, cVac, cKey2
//���������������������Ŀ
//�Manipula a tabela TLB�
//�����������������������
DbSelectArea("TLB")
If nOpcx == 3
	ConfirmSX8()
Endif

If lSigaMdtPS
	nOrd := 3
	cVac := xFilial("TLB")+SA1->A1_COD+SA1->A1_LOJA+M->TLB_CODIGO
Else
	nOrd := 1
	cVac := xFilial("TLB")+M->TLB_CODIGO
Endif

DbSetOrder(nOrd)
If DbSeek(cVac)
	RecLock("TLB",.F.)
Else
	RecLock("TLB",.T.)
EndIf

If nOpcx <> 5
	TLB->TLB_FILIAL 	:= xFilial("TLB")
	If lSigaMdtPS
	TLB->TLB_CLIENT 	:= SA1->A1_COD
	TLB->TLB_LOJA		:= SA1->A1_LOJA
	Endif

	dbSelectArea("TLB")
	dbSetOrder(nOrd)
	For i := 1 To FCount()
		If Alltrim(FieldName(i)) $ "TLB_FILIAL"
			Loop
		EndIf
		x  := "m->" + FieldName(i)
		y  := "TLB->" + FieldName(i)
		&y := &x
	Next i
Else
	DbDelete()
EndIf

MsUnLock("TLB")

//���������������������Ŀ
//�Manipula a tabela TK6�
//�����������������������
nPosCod := aScan( aHoBrwA,{|x| Trim(Upper(x[2])) == "TK6_EVENTO"})
nOrd 	:= 1
cKey 	:= xFilial("TK6")+M->TLB_CODIGO
cWhile:= "xFilial('TK6')+M->TLB_CODIGO == TK6->TK6_FILIAL+TK6->TK6_INSPEC"
If nOpcx == 5
	dbSelectArea("TK6")
	dbSetOrder(nOrd)
	dbSeek(cKey)
	While !Eof() .and. &(cWhile)
		RecLock("TK6",.f.)
		DbDelete()
		MsUnLock("TK6")
		dbSelectArea("TK6")
		dbSkip()
	End
Else
	If Len(aCoBrwA) > 0
		aSORT(aCoBrwA,,, { |x, y| x[Len(aCoBrwA[1])] .and. !y[Len(aCoBrwA[1])] } )

		For i:=1 to Len(aCoBrwA)
			If !aCoBrwA[i][Len(aCoBrwA[i])] .and. !Empty(aCoBrwA[i][nPosCod])
				dbSelectArea("TK6")
				dbSetOrder(nOrd)
				cKey2 := xFilial("TK6")+M->TLB_CODIGO+aCoBrwA[i][nPosCod]
				If dbSeek(cKey2)
					RecLock("TK6",.F.)
				Else
					RecLock("TK6",.T.)
				Endif
				For j:=1 to FCount()
					If "_FILIAL"$Upper(FieldName(j))
						FieldPut(j, xFilial("TK6"))
					ElseIf "_INSPEC"$Upper(FieldName(j))
						FieldPut(j, M->TLB_CODIGO)
					ElseIf (nPos := aScan(aHoBrwA, {|x| Trim(Upper(x[2])) == Trim(Upper(FieldName(j))) }) ) > 0
						FieldPut(j, aCoBrwA[i][nPos])
					Endif
				Next j
				MsUnlock("TK6")
			Elseif !Empty(aCoBrwA[i][nPosCod])
				dbSelectArea("TK6")
				dbSetOrder(nOrd)
				If lSigaMdtPs
					cKey2 := xFilial("TK6")+SA1->A1_COD+SA1->A1_LOJA+M->TLB_CODIGO+aCoBrwA[i][nPosCod]
				Else
					cKey2 := xFilial("TK6")+M->TLB_CODIGO+aCoBrwA[i][nPosCod]
				Endif
				If dbSeek(cKey2)
					RecLock("TK6",.F.)
					dbDelete()
					MsUnlock("TK6")
				Endif
			Endif
		Next i
	Endif
	dbSelectArea("TK6")
	dbSetOrder(nOrd)
	dbSeek(cKey)
	While !Eof() .and. &(cWhile) //  xFilial("TK6")+M->TLB_CODIGO == TK6->TK6_FILIAL+TK6->TK6_INSPEC
		If aScan( aCoBrwA,{|x| x[nPosCod] == TK6->TK6_EVENTO .AND. !x[Len(x)]}) == 0
			RecLock("TK6",.f.)
			DbDelete()
			MsUnLock("TK6")
		Endif
		dbSelectArea("TK6")
		dbSkip()
	End

Endif

//���������������������Ŀ
//�Manipula a tabela TKT�
//�����������������������
nPosCod := aScan( aHoBrwB,{|x| Trim(Upper(x[2])) == "TKT_FAMILI"})
nOrd 	:= 1
cKey 	:= xFilial("TKT")+M->TLB_CODIGO
cWhile:= "xFilial('TKT')+M->TLB_CODIGO == TKT->TKT_FILIAL+TKT->TKT_INSPEC"
If nOpcx == 5
	dbSelectArea("TKT")
	dbSetOrder(nOrd)
	dbSeek(cKey)
	While !Eof() .and. &(cWhile)
		RecLock("TKT",.f.)
		DbDelete()
		MsUnLock("TKT")
		dbSelectArea("TKT")
		dbSkip()
	End
Else
	If Len(aCoBrwB) > 0
		aSORT(aCoBrwB,,, { |x, y| x[Len(aCoBrwB[1])] .and. !y[Len(aCoBrwB[1])] } )

		For i:=1 to Len(aCoBrwB)
			If !aCoBrwB[i][Len(aCoBrwB[i])] .and. !Empty(aCoBrwB[i][nPosCod])
				dbSelectArea("TKT")
				dbSetOrder(nOrd)
				cKey2 := xFilial("TKT")+M->TLB_CODIGO+aCoBrwB[i][nPosCod]
				If dbSeek(cKey2)
					RecLock("TKT",.F.)
				Else
					RecLock("TKT",.T.)
				Endif
				For j:=1 to FCount()
					If "_FILIAL"$Upper(FieldName(j))
						FieldPut(j, xFilial("TKT"))
					ElseIf "_INSPEC"$Upper(FieldName(j))
						FieldPut(j, M->TLB_CODIGO)
					ElseIf (nPos := aScan(aHoBrwB, {|x| Trim(Upper(x[2])) == Trim(Upper(FieldName(j))) }) ) > 0
						FieldPut(j, aCoBrwB[i][nPos])
					Endif
				Next j
				MsUnlock("TKT")
			Elseif !Empty(aCoBrwB[i][nPosCod])
				dbSelectArea("TKT")
				dbSetOrder(nOrd)
				If lSigaMdtPs
					cKey2 := xFilial("TKT")+SA1->A1_COD+SA1->A1_LOJA+M->TLB_CODIGO+aCoBrwB[i][nPosCod]
				Else
					cKey2 := xFilial("TKT")+M->TLB_CODIGO+aCoBrwB[i][nPosCod]
				Endif
				If dbSeek(cKey2)
					RecLock("TKT",.F.)
					dbDelete()
					MsUnlock("TKT")
				Endif
			Endif
		Next i
		For i:=1 to Len(aColsScr)
			dbSelectArea("TKT")
			dbSetOrder(nOrd)
			If lSigaMdtPs
				cKey2 := xFilial("TKT")+SA1->A1_COD+SA1->A1_LOJA+M->TLB_CODIGO+aColsScr[i][nPosCod]
			Else
				cKey2 := xFilial("TKT")+M->TLB_CODIGO+aColsScr[i][nPosCod]
			Endif
			If dbSeek(cKey2)
				RecLock("TKT",.F.)
				dbDelete()
				MsUnlock("TKT")
			Endif
		Next i
	Endif
	dbSelectArea("TKT")
	dbSetOrder(nOrd)
	dbSeek(cKey)
	While !Eof() .and. &(cWhile)
		If aScan( aCoBrwB,{|x| x[nPosCod] == TKT->TKT_FAMILI .AND. !x[Len(x)]}) == 0
			RecLock("TKT",.f.)
			DbDelete()
			MsUnLock("TKT")
		Endif
		dbSelectArea("TKT")
		dbSkip()
	End
Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MDT545LIOK| Autor � Jackson Machado       � Data �13/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica linha da getdados		                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT545LIOK(cAlias,lFim)
Local f, nQtd := 0
Local aColsOk := {}, aHeadOk := {}
Local nPosCod := 1, nPosFai := 0, nAt := 1
Default lFim := .F.

If cAlias == "TKT" .and. M->TLB_CATEGO <> "2"
	Return .T.
Endif

If cAlias == "TK6"
	aColsOk := aClone(oBrwA:aCols)
	aHeadOk := aClone(aHoBrwA)
	nAt := oBrwA:nAt
	nPosCod := aScan( aHoBrwA,{|x| Trim(Upper(x[2])) == "TK6_EVENTO"})
ElseIf cAlias == "TKT
	aColsOk := aClone(oBrwB:aCols)
	aHeadOk := aClone(aHoBrwB)
	nAt := oBrwB:nAt
	nPosCod := aScan( aHoBrwB,{|x| Trim(Upper(x[2])) == "TKT_FAMILI"})
Endif

//Percorre aCols
For f:= 1 to Len(aColsOk)
	If !aColsOk[f][Len(aColsOk[f])] .and. !Empty(aColsOk[f][nPosCod])
		nQtd ++
		//Verifica se � somente LinhaOk
		If f <> nAt .and. !aColsOk[nAt][Len(aColsOk[nAt])]
			If aColsOk[f][nPosCod] == aColsOk[nAt][nPosCod]
				Help(" ",1,"JAEXISTINF",,aHeadOk[nPosCod][1])
				Return .F.
			Endif
		Endif
	Endif
Next f

If nQtd == 0 .AND. lFim .and. cAlias == "TKT"
	Help(1," ","OBRIGAT2",,aHeadOk[nPosCod][1],3,0)
	Return .F.
Endif

PutFileInEof("TK6")
PutFileInEof("TKT")
Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    | VLDFA545 � Autor � Jackson Machado       � Data �17/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Fun��o para abilita��o/desabilita��o da Fam�lia			     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function VLDFA545()
   If M->TLB_CATEGO == "2"
  		oBrwB:oBrowse:Enable()
	Else
		oBrwB:oBrowse:Disable()
		oBrwB:aCols := BlankGetD(aHoBrwA)
		oBrwB:oBrowse:Refresh()
	Endif
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MDT545FAM � Autor � Jackson Machado       � Data �17/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � MarkBrowse com as Fam�lias			   							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function MDT545FAM(nOpc)
Local aDBF := {}, aTRB := {}
Local aArea := GetArea()
Local oDlg3, oMenu3
Local oMARK, oTempTRB
Local nOpca := 2
Local nLen := 0, nScan := 0
Local aColsX := {}

Private lInverte:= .f.
Private lQuery := .t.
Private cMARCA   := GetMark()

AADD(aDBF,{ "OK"      , "C" ,02, 0 })
AADD(aDBF,{ "CODFAM"  , "C" ,06, 0 })
AADD(aDBF,{ "NOMFAM"  , "C" ,40, 0 })

oTempTRB := FWTemporaryTable():New( "TRB", aDBF )
oTempTRB:AddIndex( "1", {"CODFAM"} )
oTempTRB:Create()

aTRB := {}
AADD(aTRB, {"OK"     , NIL, " "         , } )
AADD(aTRB, {"CODFAM" , NIL, "C�digo"    , } )
AADD(aTRB, {"NOMFAM" , NIL, "Nome"      , } )

Dbselectarea("ST6")
DbSetOrder(1)
DbGoTop()
dbSeek(xFilial("ST6"))
While !eof() .and. xFilial("ST6") == ST6->T6_FILIAL
   nScan := aScan(aCoBrwB, {|x| x[1] == ST6->T6_CODFAMI})
	TRB->(DbAppend())
	If nScan > 0
		TRB->OK     := cMarca
	Else
		TRB->OK     := ""
	Endif
	TRB->CODFAM := ST6->T6_CODFAMI
	TRB->NOMFAM := ST6->T6_NOME

	Dbselectarea("ST6")
	Dbskip()
End


Dbselectarea("TRB")
Dbgotop()
If RecCount() == 0
	MsgStop(STR0015,STR0016)//"Nao foi encontrado nenhuma fam�lia de conjuntos hidr�ulicos."###"AVISO"
	RestArea(aArea)
	Dbselectarea("TRB")
	Use
	Return
Endif

nOpca := 2

DEFINE MSDIALOG oDlg3 TITLE OemToAnsi(STR0014) From 11,10 To 35,94.5 OF oMainWnd//"Fam�lia"

oMARK := MsSelect():NEW("TRB","OK",,aTRB,@lINVERTE,@cMARCA,{33,5,178,330},,,oDlg3)
oMARK:oBROWSE:lHASMARK := .T.
If nOpc == 2 .OR. nOpc == 5
	oMARK:bMARK := {| | MDTA545MK(cMarca,lInverte)}
Else
	oMARK:oBROWSE:lCANALLMARK := .T.
	oMARK:oBROWSE:bALLMARK := {|| MDTA545MAQ(cMarca,lInverte,.T.) .AND. oMARK:oBROWSE:REFRESH(.T.)}
Endif
oMARK:oBROWSE:Align := CONTROL_ALIGN_ALLCLIENT

NgPopUp(asMenu,@oMenu3)
oDlg3:bRClicked:= { |o,x,y| oMenu3:Activate(x,y,oDlg3)}
ACTIVATE MSDIALOG oDlg3 ON INIT EnchoiceBar(oDlg3,{|| nOpca := 1,oDlg3:End()},{||oDlg3:End()})

If nOpca == 1
	aColsX := aClone(aCoBrwB)
	aCoBrwB := {}
	DbSelectArea("TRB")
	Dbgotop()
	While !eof()
		nPos1 := aScan( aHoBrwB, {|x| AllTrim(Upper(x[2])) == "TKT_FAMILI"})
		nPos2 := aScan( aHoBrwB, {|x| AllTrim(Upper(x[2])) == "TKT_NOMFAM"})
		nLen  := Len(aColsX[1])
		nScan := aScan(aColsX, {|x| x[2] == TRB->CODFAM})
		If Empty(TRB->OK)
			If nScan > 0
			aAdd(aColsScr,aColsX[nScan])
			Else
				aAdd(aColsScr,BLANKGETD(aHoBrwB)[1])
				aColsScr[Len(aColsScr)][nPos1] := TRB->CODFAM
				aColsScr[Len(aColsScr)][nPos2] := TRB->NOMFAM
			Endif
		Else
			If nScan > 0
				aAdd(aCoBrwB,aColsX[nScan])
			Else
				aAdd(aCoBrwB,BLANKGETD(aHoBrwB)[1])
				aCoBrwB[Len(aCoBrwB)][nPos1] := TRB->CODFAM
				aCoBrwB[Len(aCoBrwB)][nPos2] := TRB->NOMFAM
			Endif
		Endif
		DbSelectArea("TRB")
		Dbskip()
	End
Endif

oTempTRB:Delete()

RestArea(aArea)
lRefresh    := .t.
oBrwB:aCols := aClone(aCoBrwB)
oBrwB:nAt   := 1
oBrwB:oBrowse:Refresh()
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    |MDT545MAQ � Autor � Jackson Machado       � Data �17/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inverte marcacoes 					   							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDTA545MAQ(cMarca,lInverte,lAll)
Local aArea := GetArea()

If lAll
	Dbselectarea("TRB")
	Dbgotop()
	While !eof()
		TRB->OK := IF(OK == Space(2),cMARCA,Space(2))
		Dbskip()
	End
Endif

RestArea(aArea)
Return .t.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDTA545MK � Autor � Jackson Machado       � Data �17/05/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Inverte marcacoes 				                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MDTA545	                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MDTA545MK()

DbselectArea("TRB")
If Empty(TRB->OK)
   TRB->OK := cMarca
Else
	TRB->OK := Space(2)
EndIf

Return .T.