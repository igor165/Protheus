#INCLUDE "mdta550.ch"
#Include "Protheus.ch"
#DEFINE _nVERSAO 2 //Versao do fonte
/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDTA550      � Autor � Andre E. Perez Alvarez� Data �23/10/06  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Geracao do Plano de Inspecao dos Conjuntos Hidr�ulicos         ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   � Booleano                                                       ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � SIGAMDT - Medicina e Seguranca do Trabalho                     ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������/*/
Function MDTA550()
//�����������������������������������������������������������������������Ŀ
//� Armazena variaveis p/ devolucao (NGRIGHTCLICK) 						  �
//�������������������������������������������������������������������������
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
Private lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Private aCHKDEL   := {}, bNGGRAVA  := {}
Private aRotina := MenuDef()//Define aRotina
Private lUpd := NGCADICBASE("TLC_CATEGO","A","TLC",.F.)
Private aTROCAF3 := {}
Private cCateg   := ""

If !NGCADICBASE("TK6_EVENTO","D","TK6",.F.)
	If !NGINCOMPDIC("UPDMDT04","000000173022010")
		Return .F.
	Endif
Endif

//��������������������������������������������������������������Ŀ
//� Define variaveis de centro de custo                          �
//����������������������������������������������������������������
nSizeSI3 := If((TAMSX3("I3_CUSTO")[1]) < 1,9,(TAMSX3("I3_CUSTO")[1]))
cAliasCC := "SI3"
cDescr   := "SI3->I3_DESC"
If Alltrim(GETMV("MV_MCONTAB")) == "CTB"
	cAliasCC := "CTT"
	cDescr   := "CTT->CTT_DESC01"
	nSizeSI3 := If((TAMSX3("CTT_CUSTO")[1]) < 1,9,(TAMSX3("CTT_CUSTO")[1]))
Endif

If lSigaMdtps
	//��������������������������������������������������������������Ŀ
	//� Define o cabecalho da tela de atualizacoes                   �
	//����������������������������������������������������������������
	cCadastro := OemtoAnsi(STR0011)  //"Clientes"

	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	DbSelectArea("SA1")
	DbSetOrder(1)
	mBrowse( 6, 1,22,75,"SA1")

Else
	//��������������������������������������������������������������Ŀ
	//� Define o cabecalho da tela de atualizacoes                   �
	//����������������������������������������������������������������
	cCadastro := OemtoAnsi(STR0004) //"Plano de Inspe��o"

	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	DbSelectArea("TLC")
	DbSetOrder(1)
	mBrowse( 6, 1,22,75,"TLC")

Endif

//�����������������������������������������������������������������������Ŀ
//� Devolve variaveis armazenadas (NGRIGHTCLICK) 							  	  �
//�������������������������������������������������������������������������
NGRETURNPRM(aNGBEGINPRM)

Return .T.
/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT550TIP  � Autor � Andre E. Perez Alvarez  � Data �23/11/2006���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o campo Ate Tipo de Inspecao                            ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � MDTA550                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������/*/
Function MDT550TIP(nTipoVld)
Local lPrest := .F.
Default nTipoVld := 2

If Type("cCliMdtPs") == "C"
	If !Empty(cCliMdtPs)
		lPrest := .T.
	Endif
Endif

If nTipoVld == 1
	If lPrest
		Return If(Vazio(),.T.,ExistCPO("TLB",cCliMdtps+M->TLC_TIPINI,3))
	Else
		Return If(Vazio(),.T.,ExistCPO("TLB",M->TLC_TIPINI,1))
	Endif
Else
	If lPrest
		Return ValAte3(M->TLC_TIPINI,M->TLC_TIPFIM,"TLB","TLC_TIPFIM",cCliMdtps,3)
	Else
		Return ValAte2(M->TLC_TIPINI,M->TLC_TIPFIM,"TLB","TLC_TIPFIM",1)
	Endif
Endif

Return .t.

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT550EXT  � Autor � Andre E. Perez Alvarez  � Data �23/11/2006���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o campo Ate Extintor                                    ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � MDTA550                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������/*/
Function MDT550EXT(nTipoVld)
Local lPrest := .F.
Default nTipoVld := 2

If Type("cCliMdtPs") == "C"
	If !Empty(cCliMdtPs)
		lPrest := .T.
	Endif
Endif

If nTipoVld == 1
	If lPrest
		Return If(Vazio(),.T.,ExistCPO("TLA",cCliMdtps+M->TLC_EXTINI,7))
	Else
		Return If(Vazio(),.T.,ExistCPO("TLA",M->TLC_EXTINI,1))
	Endif
Else
	If lPrest
		Return ValAte3(M->TLC_EXTINI,M->TLC_EXTFIM,"TLA","TLC_EXTFIM",cCliMdtps,7)
	Else
		Return ValAte2(M->TLC_EXTINI,M->TLC_EXTFIM,"TLA","TLC_EXTFIM",1)
	Endif
Endif

Return .t.

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT550CC   � Autor � Andre E. Perez Alvarez  � Data �23/11/2006���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o campo Ate Centro de Custo                             ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � MDTA550                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������/*/
Function MDT550CC()

Return AteCodigo(cAliasCC,M->TLC_CCINI,M->TLC_CCFIM,Len(M->TLC_CCFIM))
/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT550Dia  � Autor � Andre E. Perez Alvarez  � Data �23/11/2006���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o campo Ate Data                                        ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � MDTA550                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������/*/
Function MDT550Dia()

If M->TLC_DTFIM < M->TLC_DTINI
	Help(" ",1,"NGATENCAO",,STR0006,3,1)  // "A data final deve ser maior ou igual � data inicial."
	Return .F.
Endif

Return .T.
/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT550Inc  � Autor � Andre E. Perez Alvarez  � Data �23/11/2006���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Inclui um novo plano.                                          ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � MDTA550                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������/*/
Function MDT550Inc(cAlias,nReg,nOpcx)
Local aArea := GetArea()
Local nOpca := 0, cPlano
Local aOldRot:= aClone(aRotina)
Local nInd := 4, cSeek := "", cCond := "TLD->TLD_FILIAL+TLD->TLD_PLANO"//Variaveis de Indice

Private aRelac := {}
Private aOrdens:= {}//Array com as ordens de servi�o
If nOpcx == 4
	aRotina :=	{ 	{ STR0001, "AxPesqui" , 0 , 1},; //"Pesquisar"
					{ STR0002, "NGCAD01"  , 0 , 2},; //"Visualizar"
					{ STR0003, "MDT550Inc", 0 , 3},; //"Incluir"
					{ STR0005, "MDT550Inc", 0 , 4},; //"Excluir"
					{ STR0005, "MDT550Inc", 0 , 5, 3} } //"Excluir"
	nOpcx := 5
	Inclui:= .F.
	Altera:= .F.
Endif
If nOpcx == 3
	aAdd(aRelac,{"TLC_TIPFIM"	, "Replicate('Z', TAMSX3('TLC_TIPFIM')[1])"	})
	aAdd(aRelac,{"TLC_EXTFIM"	, "Replicate('Z', TAMSX3('TLC_EXTFIM')[1])"	})
	aAdd(aRelac,{"TLC_CCFIM"	, "Replicate('Z', TAMSX3('TLC_CCFIM')[1])"	})
ElseIf nOpcx == 5
	cPlano := TLC->TLC_PLANO
	cSeek  := cPlano
	bNGGRAVA := {|| CHKEXC550()}
Endif

nOpca := NGCAD01(cAlias, nReg, nOpcx)

If nOpca == 1
	If nOpcx == 3
		Processa( {|lEND| MDT550Calc()}, STR0007, STR0008 ) //"Aguarde" ## "Calculando as ordens de inspe��o..."
		//Se tiver ordens grava
		If Len(aOrdens) > 0
			Begin Transaction
				lGravaOk := Processa( {|lEND| MDT550Grav()}, STR0007, STR0009 ) //"Aguarde" ## "Gravando as ordens de inspe��o..."
				MsgAlert(STR0014+Str(Len(aOrdens))+STR0015)  //"Foram geradas "###" Ordens de Simula��o."
			 	If lGravaOk
			  		EvalTrigger() //Processa Gatilhos
				EndIf
			End Transaction
		Else
			ShowHelpDlg(STR0012,{STR0013},2) //"Aten��o"###"N�o foi gerada nenhuma Ordem de Inspe��o para este Plano."
			dbSelectArea("TLC")
			RecLock("TLC",.F.)
			dbDelete()
			MsUnlock("TLC")
		Endif
	Elseif nOpcx == 5
		If lSigaMdtps
			nInd := 11
			cSeek := TLC->TLC_CLIENT+TLC->TLC_LOJA+cPlano
			cCond := "TLD->TLD_FILIAL+TLD->TLD_CLIENT+TLD->TLD_LOJA+TLD->TLD_PLANO"
		Endif
		dbSelectArea("TLD")
		dbSetOrder(nInd)
		dbSeek(xFilial("TLD")+cSeek)
		While !Eof() .and. xFilial("TLD")+cSeek == &(cCond)
			RecLock("TLD",.F.)
			dbDelete()
			MsUnlock("TLD")
			dbSelectArea("TLD")
			dbSkip()
		End
	Endif
Endif

aRotina := aClone(aOldRot)
bNGGRAVA := Nil
aRelac := {}
RestArea(aArea)

Return .T.
/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT550Calc � Autor � Andre E. Perez Alvarez  � Data �23/11/2006���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Gera as ordens de inspecao na memoria de acordo com os         ���
���          � parametros.                                                    ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � MDT550Inc                                                      ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������/*/
Static Function MDT550Calc()
Private dDataIns := STOD(""), dDateNext:= STOD("")
Private lSoma := .T.
//Variaveis de Indice
Private nIndexTLA := 1, nIndexTLB := 1
Private cSeekTLA := TLC->TLC_EXTINI, cCondTLA := "TLA->TLA_CODEXT", cCond2TLA := TLC->TLC_EXTFIM
Private cSeekTLB := TLC->TLC_TIPINI, cCondTLB := "TLB->TLB_CODIGO", cCond2TLB := TLC->TLC_TIPFIM
Private cSeekTKS := "", cCondTKS := "", cCond2TKS := ""
//Se prestador altera indices
If lSigaMdtps
	nIndexTLA := 7
	cSeekTLA  := cCliMdtps+TLC->TLC_EXTINI
	cCondTLA  := "TLA->(TLA_CLIENT+TLA_LOJA+TLA_CODEXT)"
	cCond2TLA := cCliMdtps+TLC->TLC_EXTFIM
	nIndexTLB := 3
	cSeekTLB  := cCliMdtps+TLC->TLC_TIPINI
	cCondTLB  := "TLB->(TLB_CLIENT+TLB_LOJA+TLB_CODIGO)"
	cCond2TLB := cCliMdtps+TLC->TLC_TIPFIM
Endif

If !lUpd .or. TLC->TLC_CATEGO == "1"
	f550EXT()
ElseIf lUpd .And. TLC->TLC_CATEGO == "2"
	f550CJN()
Elseif lUpd .And. TLC->TLC_CATEGO == "3"
	f550EXT()
	f550CJN()
Endif

Return .T.
/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT550Grav � Autor � Andre E. Perez Alvarez  � Data �23/11/2006���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Gera o Plano e as Ordens de inspecao                           ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � MDT550Inc                                                      ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������/*/
Static Function MDT550Grav()
Local nX, cOrdem := ""

//��������������������������Ŀ
//�Gera as Ordens de Inspecao�
//����������������������������
dbSelectArea( "TLD" )
ProcRegua( Len(aOrdens) )

For nX := 1 To Len(aOrdens)
	IncProc()
	cOrdem := GETSXENUM( "TLD", "TLD_ORDEM" )
	ConfirmSX8()
	RecLock( "TLD", .T. )
	TLD->TLD_FILIAL := xFilial( "TLD" )
	TLD->TLD_ORDEM  := cOrdem
	TLD->TLD_PLANO  := TLC->TLC_PLANO
	TLD->TLD_CODEXT := aOrdens[nX][1]
	TLD->TLD_CODTIP := aOrdens[nX][2]
	TLD->TLD_DTPREV := aOrdens[nX][3]
	TLD->TLD_SITUAC := "1"  //Pendente
	TLD->TLD_DTINCL := dDataBase
	If lSigaMdtps
		TLD->TLD_CLIENT := SA1->A1_COD
		TLD->TLD_LOJA   := SA1->A1_LOJA
	Endif
	If lUpd
   		TLD->TLD_CATEGO := aOrdens[nX][4]
 	Endif
	MsUnlock("TLD")

	MDTA555GRA(TLD->TLD_ORDEM, TLD->TLD_CODTIP)
Next nX

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CHKEXC550
Integridade referencial no momento da exclus�o
@type function
@author Roger Rodrigues
@since 01/06/2010
@return boolean, retorna verdadeiro ou falso de
					acordo com as valida��es
/*/
//-------------------------------------------------------------------
Function CHKEXC550()

	Local aArea := GetArea()
	Local cError:= ""
	Local lRet  := .T.
	Local nInd := 4, cSeek := TLC->TLC_PLANO, cCond := "TLD->TLD_FILIAL+TLD->TLD_PLANO"

	If lSigaMdtps
		nInd := 11
		cSeek := TLC->TLC_CLIENT+TLC->TLC_LOJA+TLC->TLC_PLANO
		cCond := "TLD->TLD_FILIAL+TLD->TLD_CLIENT+TLD->TLD_LOJA+TLD->TLD_PLANO"
	Endif

	dbSelectArea("TLD")
	dbSetOrder(nInd)
	dbSeek(xFilial("TLD")+cSeek)
	While !Eof() .and. xFilial("TLD")+cSeek == &(cCond)
		If TLD->TLD_SITUAC == "2"
			lRet := .F.
			cError := AllTrim( FwX2Nome('TLD') ) + " (TLD)"
			Help(" ",1, "MA10SC",, cError, 5, 1)
			Exit
		Endif
		dbSelectArea("TLD")
		dbSkip()
	End

	RestArea(aArea)
Return lRet

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT550PL   � Autor � Andre E. Perez Alvarez  � Data �12/02/2008���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Browse dos planos do cliente.                                  ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������/*/
Function MDT550PL()
Local aArea	:= GetArea()
Local oldROTINA := aCLONE(aROTINA)
Local oldCad := cCadastro
cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA

aRotina :=	{ 	{ STR0001, "AxPesqui" , 0 , 1},; //"Pesquisar"
				{ STR0002, "NGCAD01"  , 0 , 2},; //"Visualizar"
				{ STR0003, "MDT550Inc", 0 , 3},; //"Incluir"
				{ STR0005, "MDT550Inc", 0 , 5, 3} } //"Excluir"

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
cCadastro := OemtoAnsi(STR0004) //"Plano de Inspe��o em Extintores"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
DbSelectArea("TLC")
Set Filter To TLC->(TLC_CLIENT+TLC_LOJA) = cCliMdtps
DbSetOrder(5)  //TLC_FILIAL+TLC_CLIENT+TLC_LOJA+TLC_PLANO
mBrowse( 6, 1,22,75,"TLC")

DbSelectArea("TLC")
Set Filter To

aROTINA := aCLONE(oldROTINA)
RestArea(aArea)
cCadastro := oldCad

Return
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
Static Function MenuDef()
Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Local aRotina

If lSigaMdtPS
	aRotina := { 	{ STR0001, "AxPesqui" , 0 , 1},; //"Pesquisar"
					{ STR0002, "NGCAD01"  , 0 , 2},; //"Visualizar"
					{ STR0010, "MDT550PL" , 0 , 4} } //"Planos de Inspe��o"
Else
	aRotina :=	{ 	{ STR0001, "AxPesqui" , 0 , 1},; //"Pesquisar"
					{ STR0002, "NGCAD01"  , 0 , 2},; //"Visualizar"
					{ STR0003, "MDT550Inc", 0 , 3},; //"Incluir"
					{ STR0005, "MDT550Inc", 0 , 5, 3} } //"Excluir"
Endif
Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �f550ULTINS�Autor  �Roger Rodrigues     � Data �  01/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a data da ultima inspecao do extintor pelo tipo     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �MDTA550 e MDTR690                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function f550ULTINS(lTodas)
Local aArea := GetArea()
Local dUltMan := STOD("")
Local cSeek := TLA->TLA_CODEXT, cCond := "TLD->TLD_FILIAL+TLD->TLD_CODEXT", nInd := 2

Default lTodas := .t.

If lSigaMdtps
	cSeek := cCliMdtps+TLA->TLA_CODEXT
	cCond := "TLD->TLD_FILIAL+TLD->TLD_CLIENT+TLD->TLD_LOJA+TLD->TLD_CODEXT"
	nInd  := 9
Endif
#IFNDEF TOP
	dbSelectArea("TLD")
	dbSetOrder(nInd)
	dbSeek(xFilial("TLD")+cSeek)
	While !eof() .and. xFilial("TLD")+cSeek == &(cCond)
		If TLD->TLD_CODTIP <> TLB->TLB_CODIGO
			dbSelectArea("TLD")
			dbSkip()
			Loop
		End
		If TLD->TLD_DTREAL > dUltMan .And. !Empty(TLD->TLD_DTREAL)
			dUltMan := TLD->TLD_DTREAL
		Endif
		dbSelectArea("TLD")
		dbSkip()
	End
#ELSE
	cAliasQry := GetNextAlias()
	cQuery := "SELECT MAX(TLD.TLD_DTREAL) DTREAL FROM "+RetSqlName("TLD")+" TLD "
	cQuery += "WHERE TLD.D_E_L_E_T_ <> '*' AND TLD.TLD_FILIAL = '"+xFilial("TLD")+"' AND "
	cQuery += "TLD.TLD_CODEXT = '"+TLA->TLA_CODEXT+"' AND TLD.TLD_CODTIP = '"+TLB->TLB_CODIGO+"' "
	If lSigaMdtps
		cQuery += "AND TLD.TLD_CLIENT||TLD.TLD_LOJA = '"+cCliMdtps+"' "
	Endif
	If !lTodas
		cQuery += "AND TLD.TLD_DTREAL <> '' "
	Endif
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery( cQuery , cAliasQry )
	dbSelectArea(cAliasQry)
	dbGoTop()
	While !Eof()
		If STOD((cAliasQry)->DTREAL) > dUltMan
			dUltMan := STOD((cAliasQry)->DTREAL)
		Endif
		dbSelectArea(cAliasQry)
		dbSkip()
	End
	(cAliasQry)->(dbCloseArea())
#ENDIF
RestArea(aArea)
Return dUltMan

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �f550PRXPEN�Autor  �Denis               � Data �  01/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a data da proxima inspecao extintor pendente        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �MDTA550 e MDTR690                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function f550PRXPEN()
Local aArea := GetArea()
Local dUltMan := STOD("")
Local cSeek := TLA->TLA_CODEXT, cCond := "TLD->TLD_FILIAL+TLD->TLD_CODEXT", nInd := 2

If lSigaMdtps
	cSeek := cCliMdtps+TLA->TLA_CODEXT
	cCond := "TLD->TLD_FILIAL+TLD->TLD_CLIENT+TLD->TLD_LOJA+TLD->TLD_CODEXT"
	nInd  := 9
Endif
#IFNDEF TOP
	dbSelectArea("TLD")
	dbSetOrder(nInd)
	dbSeek(xFilial("TLD")+cSeek)
	While !eof() .and. xFilial("TLD")+cSeek == &(cCond)
		If TLD->TLD_CODTIP <> TLB->TLB_CODIGO
			dbSelectArea("TLD")
			dbSkip()
			Loop
		End
		If Empty(TLD->TLD_DTREAL) .and. TLD->TLD_DTPREV >= dDataBase
			If Empty(dUltMan) .or. TLD->TLD_DTPREV < dUltMan
				dUltMan := TLD->TLD_DTPREV
			Endif
		Endif
		dbSelectArea("TLD")
		dbSkip()
	End
#ELSE
	cAliasQry := GetNextAlias()
	cQuery := "SELECT MIN(TLD.TLD_DTPREV) DTPREV FROM "+RetSqlName("TLD")+" TLD "
	cQuery += "WHERE TLD.D_E_L_E_T_ <> '*' AND TLD.TLD_FILIAL = '"+xFilial("TLD")+"' AND "
	cQuery += "TLD.TLD_CODEXT = '"+TLA->TLA_CODEXT+"' AND TLD.TLD_CODTIP = '"+TLB->TLB_CODIGO+"' "
	If lSigaMdtps
		cQuery += "AND TLD.TLD_CLIENT||TLD.TLD_LOJA = '"+cCliMdtps+"' "
	Endif
	cQuery += "AND TLD.TLD_DTREAL = '' AND TLD.TLD_DTPREV >= '"+DtoS(dDataBase)+"' "
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery( cQuery , cAliasQry )
	dbSelectArea(cAliasQry)
	dbGoTop()
	While !Eof()
		If STOD((cAliasQry)->DTPREV) > dUltMan
			dUltMan := STOD((cAliasQry)->DTPREV)
		Endif
		dbSelectArea(cAliasQry)
		dbSkip()
	End
	(cAliasQry)->(dbCloseArea())
#ENDIF
RestArea(aArea)
Return dUltMan

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � f550EXT  �Autor  �Jackson Machado     � Data �  26/05/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��o apra verifica��o dos tipos de inspe��o de extintores ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �MDTA550 					                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function f550EXT()
	//���������������������������������������������������Ŀ
	//�Seleciona os Extintores de acordo com os parametros�
	//�����������������������������������������������������
	dbSelectArea( "TLA" )
	dbSetOrder(nIndexTLA)
	dbSeek(xFilial("TLA")+cSeekTLA, .T.)
	ProcRegua( RecCount() - Recno() )
	While !Eof() .AND. xFilial("TLA") == TLA->TLA_FILIAL .AND. &(cCondTLA) <= cCond2TLA
		IncProc()
		//Filtra por Extintor
		If (TLA->TLA_CODEXT < TLC->TLC_EXTINI) .OR. (TLA->TLA_CODEXT > TLC->TLC_EXTFIM)
			dbSelectArea("TLA")
			dbSkip()
			Loop
		Endif
		//Filtra por Centro de Custo
		If (TLA->TLA_CC < TLC->TLC_CCINI) .OR. (TLA->TLA_CC > TLC->TLC_CCFIM)
			dbSelectArea("TLA")
			dbSkip()
			Loop
		Endif
		//Se o extintor nao estiver Ativo
		If TLA->TLA_SITUAC != "1"
			dbSelectArea("TLA")
			dbSkip()
			Loop
		Endif

		//����������������������������������������������������������Ŀ
		//�Seleciona os Tipos de Inspecao de acordo com os parametros�
		//������������������������������������������������������������
		dbSelectArea("TLB")
		dbSetOrder(nIndexTLB)
		dbSeek(xFilial("TLB")+cSeekTLB, .T.)
		While !Eof() .AND. xFilial("TLB") == TLB->TLB_FILIAL .AND. &(cCondTLB) <= cCond2TLB
			//Filtra por tipo
			If (TLB->TLB_CODIGO < TLC->TLC_TIPINI) .OR. (TLB->TLB_CODIGO > TLC->TLC_TIPFIM)
				dbSelectArea("TLA")
				dbSkip()
				Loop
			Endif
			If Empty(TLB->TLB_UNIDAD) .or. TLB->TLB_PERIOD <= 0
				dbSelectArea("TLB")
				dbSkip()
				Loop
			Endif
			If lUpd
				If TLB->TLB_CATEGO == "2"
					dbSelectArea("TLB")
					dbSkip()
					Loop
				Endif
			Endif
			//�������������������������������������������������������������������������������������Ŀ
			//�Verifica a Ultima Inspecao deste Tipo para o extintor selecionado e calcula a proxima�
			//���������������������������������������������������������������������������������������
			lSoma := .T.
			dDataIns := f550ULTINS(.T.)

			//Caso n�o exista pega data da ultima manuten��o informada
			If Empty(dDataIns) .and. !Empty(TLA->TLA_DTMANU)
				dDataIns := TLA->TLA_DTMANU
			ElseIf Empty(dDataIns)//Se tudo estiver em branco pega o inicio do plano
				dDataIns := TLC->TLC_DTINI
				lSoma := .F.
			Endif

			//Atribui a ultima data a variavel
			dDateNext := dDataIns

			//Gera ordens de inspecao de acordo com a periodicidade
			While dDateNext <= TLC->TLC_DTFIM
				//Verifica se deve somar a periodicidade
				If lSoma
					If TLB->TLB_UNIDAD == "1"  //Dia
						dDateNext += TLB->TLB_PERIOD
					Elseif TLB->TLB_UNIDAD == "2"  //Semana
						dDateNext += (TLB->TLB_PERIOD * 7)
					Elseif TLB->TLB_UNIDAD == "3"  //Mes
						dDateNext := NGSomaMes( dDateNext, TLB->TLB_PERIOD )
					Elseif TLB->TLB_UNIDAD == "4"  //Ano
						dDateNext := NGSomaAno( dDateNext, TLB->TLB_PERIOD )
					Endif
				Else
					lSoma := .T.
				Endif
				If dDateNext >= TLC->TLC_DTINI .and. dDateNext <= TLC->TLC_DTFIM
					//Cod Extintor,Tipo Inspecao,Data Prevista
					AADD( aOrdens, { TLA->TLA_CODEXT, TLB->TLB_CODIGO, dDateNext, "1" } )
				Endif
			End
			dbSelectArea( "TLB" )
			dbSkip()
		End
		dbSelectArea( "TLA" )
		dbSkip()
	End
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � f550CJN  �Autor  �Jackson Machado     � Data �  26/05/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��o apra verifica��o dos tipos de inspe��o de cjn. hidr. ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �MDTA550 					                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function f550CJN()
nIndexTKS := NGRETORDEM("TKS","TKS_FILIAL+TKS_CODCJN")
cSeekTKS := TLC->TLC_CJNINI
cCondTKS := "TKS->TKS_CODCJN"
cCond2TKS := TLC->TLC_CJNFIM
If lSigaMdtPs
	nIndexTKS := NGRETORDEM("TKS","TKS_FILIAL+TKS_CLIENT+TKS_LOJA+TKS_CODCJN")
	cSeekTLA  := cCliMdtps+TLC->TLC_CJNINI
	cCondTLA  := "TKS->(TKS_CLIENT+TKS_LOJA+TKS_CODCJN)"
	cCond2TLA := cCliMdtps+TLC->TLC_CJNFIM
Endif

//����������������������������������������������������Ŀ
//�Seleciona os Conj. Hidr. de acordo com os parametros�
//������������������������������������������������������
dbSelectArea( "TKS" )
dbSetOrder(nIndexTKS)
dbSeek(xFilial("TKS")+cSeekTKS, .T.)
ProcRegua( RecCount() - Recno() )
While !Eof() .AND. xFilial("TKS") == TKS->TKS_FILIAL .AND. &(cCondTKS) <= cCond2TKS
	IncProc()
	//Filtra por Extintor
	If (TKS->TKS_CODCJN < TLC->TLC_CJNINI) .OR. (TKS->TKS_CODCJN > TLC->TLC_CJNFIM)
		dbSelectArea("TKS")
		dbSkip()
		Loop
	Endif
	//Filtra por Centro de Custo
	If (TKS->TKS_CCCJN < TLC->TLC_CCINI) .OR. (TKS->TKS_CCCJN > TLC->TLC_CCFIM)
		dbSelectArea("TKS")
		dbSkip()
		Loop
	Endif

	If TKS->TKS_SITUAC <> "1"
		dbSelectArea("TKS")
		dbSkip()
		Loop
	Endif
	//����������������������������������������������������������Ŀ
	//�Seleciona os Tipos de Inspecao de acordo com os parametros�
	//������������������������������������������������������������
	dbSelectArea("TLB")
	dbSetOrder(nIndexTLB)
	dbSeek(xFilial("TLB")+cSeekTLB, .T.)
	While !Eof() .AND. xFilial("TLB") == TLB->TLB_FILIAL .AND. &(cCondTLB) <= cCond2TLB
		//Filtra por tipo
		If (TLB->TLB_CODIGO < TLC->TLC_TIPINI) .OR. (TLB->TLB_CODIGO > TLC->TLC_TIPFIM)
			dbSelectArea("TKS")
			dbSkip()
			Loop
		Endif
		If Empty(TLB->TLB_UNIDAD) .or. TLB->TLB_PERIOD <= 0
			dbSelectArea("TLB")
			dbSkip()
			Loop
		Endif
		If lUpd
			If TLB->TLB_CATEGO == "1"
				dbSelectArea("TLB")
				dbSkip()
				Loop
			Endif
		Endif
		dbSelectArea("TKT")
		dbSetOrder(1)
		If !dbSeek(xFilial("TKT")+TLB->TLB_CODIGO+TKS->TKS_FAMCJN)
			dbSelectArea("TLB")
			dbSkip()
			Loop
		Endif
		dbSelectArea("TLB")
		//�������������������������������������������������������������������������������������Ŀ
		//�Verifica a Ultima Inspecao deste Tipo para o extintor selecionado e calcula a proxima�
		//���������������������������������������������������������������������������������������
		lSoma := .T.
		dDataIns := f550ULTINS(.T.)

		If Empty(dDataIns) .and. !Empty(TKS->TKS_DTMANU)
			dDataIns := TKS->TKS_DTMANU
		Elseif Empty(dDataIns)
			dDataIns := TLC->TLC_DTINI
			lSoma := .F.
		Endif

		//Atribui a ultima data a variavel
		dDateNext := dDataIns

		//Gera ordens de inspecao de acordo com a periodicidade
		While dDateNext <= TLC->TLC_DTFIM
			//Verifica se deve somar a periodicidade
			If lSoma
				If TLB->TLB_UNIDAD == "1"  //Dia
					dDateNext += TLB->TLB_PERIOD
				Elseif TLB->TLB_UNIDAD == "2"  //Semana
					dDateNext += (TLB->TLB_PERIOD * 7)
				Elseif TLB->TLB_UNIDAD == "3"  //Mes
					dDateNext := NGSomaMes( dDateNext, TLB->TLB_PERIOD )
				Elseif TLB->TLB_UNIDAD == "4"  //Ano
					dDateNext := NGSomaAno( dDateNext, TLB->TLB_PERIOD )
				Endif
			Else
				lSoma := .T.
			Endif
			If dDateNext >= TLC->TLC_DTINI .and. dDateNext <= TLC->TLC_DTFIM
				//Cod Extintor,Tipo Inspecao,Data Prevista
				AADD( aOrdens, { TKS->TKS_CODCJN, TLB->TLB_CODIGO, dDateNext, "2" } )
			Endif
		End
		dbSelectArea( "TLB" )
		dbSkip()
	End
	dbSelectArea( "TKS" )
	dbSkip()
End
Return .T.
/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � A550TROF3    � Autor �Jackson Machado 		   � Data �25/05/11  ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para Troca do F3						                        ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � MDT555TF3()     		                                          ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   � .T.				                                                ���
�����������������������������������������������������������������������������Ĵ��
���Uso       � MDTA555                                                        ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������/*/
Function A550TROF3()
aTROCAF3 := {}

If M->TLC_CATEGO == "3"
	AADD(aTROCAF3,{"TLC_TIPINI","TLB"})
   AADD(aTROCAF3,{"TLC_TIPFIM","TLB"})
Else
 	AADD(aTROCAF3,{"TLC_TIPINI","TLCCAT"})
   AADD(aTROCAF3,{"TLC_TIPFIM","TLCCAT"})
EndIf

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A555DEATE �Autor  �Jackson Machado	 � Data �  23/11/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida campos de/at�                                        ���
�������������������������������������������������������������������������͹��
���Uso       � MDTA550                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A555DEATE(cTab,nVer)

If nVer == 1
	If cTab == cAliasCC
		If !Empty(M->TLC_CCINI)
	   		If !ExistCPO(cAliasCC,M->TLC_CCINI)
	   			Return .F.
	   		Endif
	   		If M->TLC_CCINI > M->TLC_CCFIM
	   			HELP("",1,"DEATEINVAL")
				Return .F.
			Endif
		Endif
	Elseif cTab == "TLA"
		If !Empty(M->TLC_EXTINI)
	   		If !ExistCPO("TLA",M->TLC_EXTINI)
	   			Return .F.
	   		Endif
	   		If M->TLC_EXTINI > M->TLC_EXTFIM
	   			HELP("",1,"DEATEINVAL")
				Return .F.
			Endif
		Endif
	Elseif cTab == "TLB"
		If !Empty(M->TLC_TIPINI)
			If !ExistCPO("TLB",M->TLC_TIPINI)
				Return .F.
			Endif
			If M->TLC_TIPINI > M->TLC_TIPFIM
				HELP("",1,"DEATEINVAL")
				Return .F.
			Endif
		Endif
	Elseif cTab == "TKS"
		If !Empty(M->TLC_CJNINI)
	   		If !ExistCPO("TKS",M->TLC_CJNINI)
	   			Return .F.
	   		Endif
	   		If M->TLC_CJNINI > M->TLC_CJNFIM
	   			HELP("",1,"DEATEINVAL")
				Return .F.
			Endif
		Endif
	Endif
Elseif nVer == 2
	If cTab == cAliasCC
    	Return NaoVazio() .AND. MDT550CC()
	Elseif cTab == "TLA"
   		Return NaoVazio() .AND. MDT550EXT()
	Elseif cTab == "TLB"
    	Return NaoVazio() .AND. MDT550TIP()
	Elseif cTab == "TKS"
    	Return NaoVazio() .AND. ValAte2(M->TLC_CJNINI,M->TLC_CJNFIM,"TKS","TLC_CJNFIM",1)
	Endif
Endif
Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A550LIMPA � Autor �Jackson Machado		� Data � 23/11/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Limpa os campos em tela									  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function A550LIMPA()

If M->TLC_CATEGO <> cCateg .and. INCLUI
	If !Empty(cCateg) .and. M->TLC_CATEGO == "1"
		M->TLC_TIPINI := SPACE(10)
		M->TLC_TIPFIM := REPLICATE("Z",10)
		M->TLC_CJNINI := SPACE(10)
		M->TLC_CJNFIM := REPLICATE("Z",10)
	Elseif !Empty(cCateg) .and. M->TLC_CATEGO == "2"
		M->TLC_TIPINI := SPACE(10)
		M->TLC_TIPFIM := REPLICATE("Z",10)
		M->TLC_EXTINI := SPACE(10)
		M->TLC_EXTFIM := REPLICATE("Z",10)
	Endif
	cCateg := M->TLC_CATEGO
	If Type("oEnchoice") == "O"
		oEnchoice:Refresh()
	Endif
Endif

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA550FIN
V�lida o campo campo, n�o permitindo que sejam maior que a data atual
e menor que a data Inicio.

@author Guilherme Freudenburg
@since 27/09/2013
@return .T.
/*/
//---------------------------------------------------------------------
Function MDTA550FIN()

Local lRet := .T.

If Empty(M->TLC_DTFIM) .or. (M->TLC_DTFIM < M->TLC_DTINI)
	lRet := .F.
	ShowHelpDlg(STR0016,{STR0018},1,{STR0019},2)
	Return lRet
Endif