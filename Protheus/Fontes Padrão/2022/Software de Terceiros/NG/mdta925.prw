#include "Mdta925.ch"
#include "Protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MDTA925  � Autor �Denis Hyroshi de Souza � Data � 20/08/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Cadastro de Encaminhamento ao Especialista     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDTA925()
//�����������������������������������������������������������������������Ŀ
//� Armazena variaveis p/ devolucao (NGRIGHTCLICK) 					      �
//�������������������������������������������������������������������������
Local lCall := ( Type("cPrograma") == "C" .and. cPrograma $ "MDTA155/MDTA160/MDTA005")
Local aNGBEGINPRM := NGBEGINPRM( )

Private lCall155   := lCall
Private lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Private bNGGRAVA
Private nSizeCli   := If((TAMSX3("A1_COD")[1]) < 1,6,(TAMSX3("A1_COD")[1]))
Private nSizeLoj   := If((TAMSX3("A1_LOJA")[1]) < 1,2,(TAMSX3("A1_LOJA")[1]))
Private nSizeSI3   := If((TAMSX3("I3_CUSTO")[1]) < 1,9,(TAMSX3("I3_CUSTO")[1]))  //Usado no X3_RELACAO
Private aRotina    := MenuDef()
Private cCadastro  := OemtoAnsi(STR0001) //"Encaminhamento ao Especialista"

If FindFunction("MDTRESTRI") .AND. !MDTRESTRI(cPrograma)
	//�����������������������������������������������������������������������Ŀ
	//� Devolve variaveis armazenadas (NGRIGHTCLICK) 			 			  �
	//�������������������������������������������������������������������������
	NGRETURNPRM(aNGBEGINPRM)
	Return .F.
Endif

If lCall155
	If Empty(M->TMT_NUMFIC)
		Help(" ",1,"OBRIGAT")
		Return .f.
	Endif
Endif
If lCall155 .or. !lSigaMdtPS
	MDTA925d_()
Else
	dbSelectArea("SA1")
	dbSetOrder(1)
	mBrowse( 6, 1,22,75,"SA1")
Endif

//�����������������������������������������������������������������������Ŀ
//� Devolve variaveis armazenadas (NGRIGHTCLICK) 						  �
//�������������������������������������������������������������������������
NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MDTA925d_� Autor � Denis                 � Data �20/08/2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Registrar os Encaminhamento ao Especialista                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDTA925d_()
Local aArea			:= GetArea()
Local aIndexTK7	:= {}
Local aIndexTM0	:= {}
Local oldROTINA   := aCLONE(aROTINA)
Local aAreaTK7, uRet

If !NGIFDICIONA("SX3","TK7",1,.F.)
	If !NGINCOMPDIC("UPDMDT10","00000022584/2010")
   	Return .F.
 	Endif
EndIf

Private cCliMdtPs := Space( Len( SA1->A1_COD+SA1->A1_LOJA ) )
Private cAlias    := "TK7"
Private cNUMFIC   := Space(09)
Private bFiltra925:= { || NIL }

aAreaTK7		:= TK7->(GetArea())

If lSigaMdtPS
	cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA
Endif

Begin Sequence

	aRotina :=	MenuDef( .F. )

	If lCall155
		/*
		������������������������������������������������������������������������Ŀ
		� Inicializa o filtro da tabela TK7 - Licencas                           �
		��������������������������������������������������������������������������*/
		cFiltra925 := 'TK7_NUMFIC == "'+M->TMT_NUMFIC+'"'
		bFiltra925 := { || FilBrowse("TK7",@aIndexTK7,@cFiltra925) }
		Eval( bFiltra925 )
	ElseIf lSigaMdtPS
		cCadastro	:= OemToAnsi(cCadastro+STR0008+Alltrim(SA1->A1_NOME)) //" - Cliente: "
		/*
		������������������������������������������������������������������������Ŀ
		� Inicializa o filtro da tabela TK7 - Licencas                           �
		��������������������������������������������������������������������������*/
		cFiltra925 := 'TK7_CLIENT == "'+SA1->A1_COD+'" .And. TK7_LOJA == "'+SA1->A1_LOJA+'"'
		bFiltra925 := { || FilBrowse("TK7",@aIndexTK7,@cFiltra925) }
		Eval( bFiltra925 )
	Endif

	dbSelectArea("TM0")
	dbSetOrder(1)

	dbSelectArea("TK7")
	dbSetOrder(1)
	mBrowse( 6, 1,22,75,"TK7")

	/*
	������������������������������������������������������������������������Ŀ
	� Deleta o filtro utilizando a funcao FilBrowse                     	 �
	��������������������������������������������������������������������������*/
	If lSigaMdtPS .or. lCall155
		EndFilBrw( "TK7" , aIndexTK7 )
	Endif

End Sequence

RestArea( aAreaTK7 )
RestArea( aArea )
aROTINA := aCLONE(oldROTINA)

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT925FIC� Autor �Denis Hyroshi de Souza � Data � 20/08/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Ficha Medica                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT925FIC(cFichaMed)
Return ExistCpo("TM0",cFichaMed)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT925ESP� Autor �Denis Hyroshi de Souza � Data � 20/08/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida campo Especialidade                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT925ESP(cCodEsp)
Return ExistCpo("TOG",cCodEsp)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MDT925IMP� Autor �Denis Hyroshi de Souza � Data � 20/08/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o atestado para licenca maternidade                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MDT925IMP()

//Local oFont10  := TFont():New("Arial",10,10,,.F.,,,,.F.,.F.)
//Local oFont12  := TFont():New("Arial",12,12,,.T.,,,,.F.,.F.)
//Local oFont20  := TFont():New("Arial",20,20,,.T.,,,,.F.,.F.)
//Local oFont21  := TFont():New("Arial",21,21,,.F.,,,,.F.,.F.)
Local nLinTmp
Local oFont10p := TFont():New("Arial",10,10,,.T.,,,,.F.,.F.)
Local oFont13  := TFont():New("Arial",12,12,,.F.,,,,.F.,.F.)
Local oFont14  := TFont():New("Arial",13,13,,.F.,,,,.F.,.F.)
Local oFont16  := TFont():New("Arial",14,14,,.F.,,,,.F.,.F.)
Local cSMCOD   := If(FindFunction("FWGrpCompany"),FWGrpCompany(),SM0->M0_CODIGO)
Local cSMFIL   := If(FindFunction("FWCodFil"),FWCodFil(),SM0->M0_CODFIL)
Local cPerg    := Padr( "MDTA925", 10 )
Local aPerg    := {}

If lSigaMdtPS
	cPerg := Padr( "MDTA925PS", 10 )
Endif

If !Pergunte(cPerg,.T.)
	Return
Endif

oPrint	:= TMSPrinter():New(Capital(STR0001)) //"ENCAMINHAMENTO AO ESPECIALISTA"
oPrint:Setup()

lin := 450

oPrint:StartPage()

dbSelectArea("SM0")
dbSeek(cSMCOD+cSMFIL)
dbSelectArea("TM0")
dbSetOrder(01)
dbSeek(xFilial("TM0")+TK7->TK7_NUMFIC)
dbSelectArea("SRA")
dbSetOrder(01)
dbSeek(xFilial("SRA")+Mv_par01)
dbSelectArea("TMK")
dbSetOrder(01)
dbSeek(xFilial("TMK")+Mv_par02)
dbSelectArea("TOG")
dbSetOrder(01)
dbSeek(xFilial("TOG")+TK7->TK7_CODESP)

cLogo := ""
If FindFunction("NGLocLogo")
	cLogo := NGLocLogo()
Endif
If !Empty(cLogo)
	oPrint:SayBitMap(210,210,cLogo,335,185)
Endif
lin := 200
oPrint:Box(lin,200,lin+200,550)
oPrint:Box(lin,570,lin+200,1520)
oPrint:Say(lin+65,1045,Upper(STR0001),oFont16,,,,2) //"ENCAMINHAMENTO AO ESPECIALISTA"
oPrint:Box(lin,1540,lin+200,2200)
oPrint:Say(lin+5,1550,STR0011,oFont10p) //"Unidade Administrativa"
If !lSigaMdtPS
	oPrint:Say(lin+100,1560,SubStr(If(!Empty(SM0->M0_NOMECOM),SM0->M0_NOMECOM,SM0->M0_NOME),1,22),oFont13)
Else
	oPrint:Say(lin+100,1560,SubStr(SA1->A1_NOME,1,22),oFont13)
Endif
lin += 350

If !lSigaMdtPS
	cData := Capital(Alltrim(SM0->M0_CIDCOB)) + ", " + StrZero(Day(dDataBase),2) + STR0012 + ; //" de "
			 MesExtenso(dDataBase) + STR0012 + StrZero(Year(dDataBase),4) //" de "
Else
	cData := Capital(Alltrim(SA1->A1_MUN)) + ", " + StrZero(Day(dDataBase),2) + STR0012 + ; //" de "
			 MesExtenso(dDataBase) + STR0012 + StrZero(Year(dDataBase),4) //" de "
Endif
oPrint:Say(lin,2200,cData,oFont14,,,,1)

lin += 100
cTipResp := Tabela("P1",TMK->TMK_INDFUN,.F.)

cLin1 := STR0013 + DtoC(TK7->TK7_DATAEX) + STR0014 //"Informamos que segundo os exames realizados no dia "###", atrav�s do Programa de "
cLin1 += STR0015 + Alltrim(TMK->TMK_NOMUSU) + ", " + cTipResp //"Controle M�dico de Sa�de Ocupacional coordenado pelo Dr(a). "
If !Empty(TMK->TMK_NUMENT)
	cLin1 += ", "
	If Empty(TMK->TMK_ENTCLA)
		cLin1 += STR0016 //"CRM"
	Else
	   	cLin1 += Alltrim(TMK->TMK_ENTCLA)
	Endif
	cLin1 += " " + Alltrim(TMK->TMK_NUMENT)
Endif
If !Empty(TMK->TMK_REGMTB)
   	cLin1 += ", " + STR0017 + " " + Alltrim(TMK->TMK_REGMTB) //"Registro MTB N�"
Endif
cLin1 += ", " + STR0018 //"foram constatadas algumas anormalidades atrav�s do m�todo adotado."

cLin2 := STR0019 + Alltrim(TOG->TOG_NOME) + STR0020 //"Solicitamos que procure um "###" para fazer o devido tratamento e ap�s conclu�do solicitar "
cLin2 += STR0021 //"junto ao m�dico uma declara��o constatando o final do tratamento."

oPrint:Say(lin,200,STR0022,oFont14) //"Sr(a)"
lin += 80
oPrint:Say(lin,200,Alltrim(TM0->TM0_NOMFIC),oFont14)
lin += 160
oPrint:Say(lin,280,MemoLine(cLin1,87,1),oFont14)
lin += 80
oPrint:Say(lin,200,MemoLine(cLin1,87,2),oFont14)
lin += 80
oPrint:Say(lin,200,MemoLine(cLin1,87,3),oFont14)
lin += 80
oPrint:Say(lin,200,MemoLine(cLin1,87,4),oFont14)
lin += 100
oPrint:Say(lin,280,MemoLine(cLin2,87,1),oFont14)
lin += 80
oPrint:Say(lin,200,MemoLine(cLin2,87,2),oFont14)
lin += 80
oPrint:Say(lin,200,MemoLine(cLin2,87,3),oFont14)

If ExistBlock("MDTA9251")
	nLinTmp := ExecBlock( "MDTA9251" , .F. , .F. , { oPrint , lin } )
	If ValType( nLinTmp ) == "N"
		lin := nLinTmp
	EndIf
Endif

lin += 200
oPrint:Say(lin,200,STR0023,oFont14) //"Atenciosamente,"

lin += 250
oPrint:line(lin,200,lin,1300)
If !lSigaMdtPS
	oPrint:Say(lin+25,200,If(!Empty(SM0->M0_NOMECOM),SM0->M0_NOMECOM,SM0->M0_NOME),oFont14)
Else
	oPrint:Say(lin+25,200,SA1->A1_NOME,oFont14)
Endif

lin += 250
oPrint:line(lin,200,lin,1300)
oPrint:Say(lin+25,200,SRA->RA_NOME,oFont14)

oPrint:EndPage()
oPrint:Preview()

Return .t.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor �Denis Hyroshi de Souza � Data � 20/08/10 ���
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
Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Local aRotina

Default lMdtPs := lSigaMdtPS

If lMdtPs
	aRotina := { 	{ STR0002 , "AxPesqui"	, 0 , 1},; //"Pesquisar"
					{ STR0003 , "NGCAD01"	, 0 , 2},; //"Visualizar"
					{ STR0024 , "MDTA925d_"	, 0 , 4}} //"Encaminhamentos"
Else
	aRotina :=	{ 	{ STR0002, "AxPesqui"	, 0 , 1},; //"Pesquisar"
					{ STR0003, "NGCAD01"	, 0 , 2},; //"Visualizar"
					{ STR0004, "MDT925INC"	, 0 , 3},; //"Incluir"
					{ STR0005, "MDT925INC"	, 0 , 4},; //"Alterar"
					{ STR0006, "MDT925INC"	, 0 , 5, 3},; //"Excluir"
					{ STR0007, "MDT925IMP"	, 0 , 2}} //"Imprimir"
	If !lSigaMdtPS .AND. SuperGetMv("MV_NG2AUDI",.F.,"2") == "1"
		aAdd( aRotina , { STR0029,"MDTA991('TK7')" , 0 , 3 } )//"Hist. Exc."
	Endif
Endif
Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MDT925INC � Autor �Denis Hyroshi de Souza � Data � 20/08/10 ���
�������������������������������������������������������������������������͹��
���Desc.     �Tela de inclus�o de licenca maternidade                     ���
�������������������������������������������������������������������������͹��
���Uso       �MDTA925                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MDT925INC(cAlias, nRecno, nOpcx)

aRELAC   := {}
bNGGRAVA := {|| MDT925GRV() }

If cValToChar(nOpcx) $ "4/5" .AND. FindFunction("MDTRESTRI") .AND. NGCADICBASE("TMK_USUARI","A","TMK",.F.) .AND. !MDTRESTUS(MDTDATALO("TK7->TK7_USERGI",.F.))
	bNGGRAVA  := {||}
	Return .F.
ElseIf nOpcx == 5 .AND. SuperGetMV("MV_NG2SEG",.F.,"2") == "1" .AND. !(SuperGetMV("MV_MDTPS",.F.,"N") == "S") .AND. ;
		FindFunction("MDTEXCSBI") .AND. !MDTEXCSBI(MDTDATALO("TK7->TK7_USERGI"))
 	bNGGRAVA  := {||}
	Return .F.
Endif

If lCall155 .and. nOpcx == 3
	aAdd( aRELAC , { "TK7_NUMFIC" , "M->TMT_NUMFIC"	} )
	aAdd( aRELAC , { "TK7_NOMFIC" , "cNOMFIC160"	} )
	aAdd( aRELAC , { "TK7_DATAEX" , "If(Empty(M->TMT_DTATEN),M->TMT_DTCONS,M->TMT_DTATEN)"	} )
	dbSelectArea("TM0")
	dbSetOrder(1)
	dbSeek(xFilial("TM0")+M->TMT_NUMFIC)
	cNOMFIC160 := TM0->TM0_NOMFIC
Endif
NGCAD01("TK7", nRecno, nOpcx) //Abre tela de cadastro

aRELAC := {}
bNGGRAVA  := {||}

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MDT925GRV � Autor �Denis Hyroshi de Souza � Data � 20/08/10 ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida se grava o registro ou nao                           ���
�������������������������������������������������������������������������͹��
���Uso       �MDTA925                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MDT925GRV()

If Inclui
	If !ExistChav("TK7",M->TK7_NUMFIC+M->TK7_CODESP+DTOS(M->TK7_DATAEN))
		Return .f.
	Endif
ElseIf Altera
	If M->TK7_NUMFIC+M->TK7_CODESP+DTOS(M->TK7_DATAEN) <> TK7->(TK7_NUMFIC+TK7_CODESP+DTOS(TK7_DATAEN))
		If !ExistChav("TK7",M->TK7_NUMFIC+M->TK7_CODESP+DTOS(M->TK7_DATAEN))
			Return .f.
		Endif
	Endif
Endif

Return .t.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MDT925WHEN� Autor �Denis Hyroshi de Souza � Data � 20/08/10 ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se habilita ou nao o campo TK7_NUMFIC             ���
�������������������������������������������������������������������������͹��
���Uso       �MDTA925                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MDT925WHEN()
If Type("lCall155") == "L" .And. lCall155
	Return .f.
Endif
Return Inclui

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA925EN
N�o permite a data do Encaminhamento ser maior que a data de realiza��o
do exame.

@author Guilherme Freudenburg
@since 07/10/2013
/*/
//---------------------------------------------------------------------
Function MDTA925EN()

Local lRet:= .T.

If Empty(M->TK7_DATAEN) .or. !Empty(M->TK7_DATAEX) .and. (M->TK7_DATAEN > M->TK7_DATAEX)
	ShowHelpDlg(STR0025,{STR0026},2,{STR0027},2)
	lRet:= .F.
Endif

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTA925EX
N�o permite incluir uma data para o exame inferior a data do
encaminhamento.

@author Guilherme Freudenburg
@since 07/10/2013
/*/
//---------------------------------------------------------------------
Function MDTA925EX()

Local lRet:= .T.

If Empty(M->TK7_DATAEX) .or. !Empty(M->TK7_DATAEN) .and. (M->TK7_DATAEX < M->TK7_DATAEN)
	ShowHelpDlg(STR0025,{STR0026},2,{STR0028},2)
	lRet:= .F.
Endif

Return lRet