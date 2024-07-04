#INCLUDE "SGAA550.ch"
#include "protheus.ch"
#Define _nVERSAO 3
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGAA550   �Autor  �Roger Rodrigues     � Data �  17/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para cadastro de informacoes veiculos transportadores���
���          �de residuos            	       							  ���
�������������������������������������������������������������������������͹��
���Uso       �SIGASGA                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGAA550()
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

Private lAleat := .F.//Variavel de Filtro
Private aRotina   := MenuDef()
Private aNGButton := {}
Private aChkSql   := NGRETSX9("TDM")//Tabelas a serem verificadas na exclusao
Private cCadastro := OemToAnsi(STR0001) //"Ve�culos Transportadores de Res�duos"

//Verifica se o Update de FMR esta aplicado
If !SGAUPDFMR("TDM")
	Return .F.
Endif
Aadd(aNgButton,{"PARAMETROS" ,{||Sg550QDO()},STR0002,STR0003}) //"Relacionar documento"###"Rel.Doc."

dbSelectArea("TDM")
mBrowse( 6, 1,22,75,"TDM",,,,,,SG550SEMAF(),,,,,.F.)

dbSelectArea("TDM")
Set Filter To//Retorna Filtro

NGRETURNPRM(aNGBEGINPRM)
Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SG550SEMAF�Autor  �Roger Rodrigues     � Data �  17/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Define as cores de semaforo para as Transportadoras         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SGAA550                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SG550SEMAF()
Local aCores :={{"NGSEMAFARO('TDM->TDM_STATUS == "+'"1"'+"')" , "BR_VERDE" },;
				{"NGSEMAFARO('TDM->TDM_STATUS == "+'"2"'+"')" , "BR_VERMELHO"}}

Return aCores
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SG550LEG  �Autor  �Roger Rodrigues     � Data �  17/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta Browse com legenda                           	      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA550                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SG550LEG()
BrwLegenda(cCadastro,STR0004,{	{"BR_VERMELHO"	, STR0005 },; //"Legenda"###"Inativo"
									{"BR_VERDE"		, STR0006}}) //"Ativo"
Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Roger Rodrigues       � Data �17/03/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Utilizacao de Menu Funcional.                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaSGA                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina :=	{ {	   STR0007	, "AxPesqui"  , 0 , 1},; //"Pesquisar"
                      { STR0008	, "NGCAD01"	, 0 , 2},; //"Visualizar"
                      { STR0009	, "NGCAD01"	, 0 , 3},; //"Incluir"
                      { STR0010	, "NGCAD01"	, 0 , 4},; //"Alterar"
                      { STR0011	, "NGCAD01"	, 0 , 5, 3},; //"Excluir"
						 { STR0027 , "MsDocument", 0 , 4},;//Co&nhecimento	                 
                      { STR0004	, "SG550LEG"  , 0 , 3}} //"Legenda"

Return aRotina
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SG550QDO  �Autor  �Roger Rodrigues     � Data �  12/04/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta tela para relacionamento de documento                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA550                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SG550QDO()
Local oDlgQdo, oRadio
Local nRadio := 1,nOpc := 1
Local lRet := .t.
Local lGrava := .F.

Define MsDialog oDlgQdo From 03.5,6 To 150,320 Title STR0015 Pixel //"Aten��o"

Define FONT oBold NAME "Courier New" SIZE 0, -13 BOLD
@ 0, 0 BITMAP oBmp RESNAME "PROJETOAP" oF oDlgQdo SIZE 35,250 NOBORDER WHEN .F. PIXEL

@ 05,040 Say OemToAnsi(STR0016) Size 117,7 Of oDlgQdo Pixel Font oBold //"O que deseja fazer ?"

@ 20,048 Radio oRadio Var nRadio Items STR0017,STR0018,; //"Relacionar um documento"###"Visualizar documento relacionado"
															STR0019 3d Size 105,10 Of oDlgQdo Pixel //"Apagar um Documento Relacionamento"

Define sButton From 055,090 Type 1 Enable Of oDlgQdo Action (lGrava := .t.,oDlgQdo:End())
Define sButton From 055,120 Type 2 Enable Of oDlgQdo Action (lGrava := .f.,oDlgQdo:End())

Activate MsDialog oDlgQdo Centered 

If !lGrava
	lRet := .f.
Else
	If nRadio == 1
		If !Sg550RelQdo()
			lRet := .f.
		EndIf
	ElseIf nRadio == 2
		If !Sg550VieQdo()
			lRet := .f.
		EndIf
	Else
		M->TDM_DOCTO  := " "
		M->TDM_DOCFIL := " "
	EndIf
EndIf

Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Sg550RelQdo �Autor  �Roger Rodrigues   � Data �  12/04/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Relaciona um documento                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA550                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Sg550RelQdo()
Local lRet := .F.

lRet := ConPad1( , , , "QDT1",,,.f.)
If lRet
	M->TDM_DOCTO  := QDH->QDH_DOCTO
	M->TDM_DOCFIL := QDH->QDH_FILIAL
EndIf

Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Sg550VieQdo �Autor  �Roger Rodrigues   � Data �  12/04/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Visualiza um documento                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA550                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Sg550VieQdo()
Local _lRet := .F.

If !Empty(M->TDM_DOCTO)
	If QDOVIEW( , M->TDM_DOCTO )//Visualiza documento Word
		_lRet := .t.
	EndIf
Else
	MsgInfo(STR0020) //"N�o existe documento associado a este Ve�culo."
Endif

Return _lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SG550VAL  �Autor  �Roger Rodrigues     � Data �  12/04/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza validacao dos campos da tela                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA550                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SG550VAL(cCampo)
Default cCampo := ReadVar()

If cCampo == "M->TDM_CODVEI"
	If ExistCpo("DA3",M->TDM_CODVEI) .and. ExistChav("TDM",M->TDM_CODVEI)
		dbSelectArea("DA3")
		dbSetOrder(1)
		If dbSeek(xFilial("DA3")+M->TDM_CODVEI)
			If Empty(DA3->DA3_PLACA)
				ShowHelpDlg(STR0015,{STR0021},1,{STR0022}) //"Aten��o"###"O ve�culo informado n�o possui placa."###"Favor informar um ve�culo com placa."
				Return .F.
			Else
				dbSelectArea("DUT")
				dbSetOrder(1)
				If dbSeek(xFilial("DUT")+DA3->DA3_TIPVEI)
					M->TDM_TPVEIC := DUT->DUT_CATVEI
				Endif
			Endif
		Endif
	Else
		Return .F.
	Endif
ElseIf cCampo == "M->TDM_CRLV"
	If ExistCpo("TA0",M->TDM_CRLV)
		dbSelectArea("TA0")
		dbSetOrder(1)
		If dbSeek(xFilial("TA0")+M->TDM_CRLV) .and. TA0->TA0_DTVENC < dDatabase .and. !Empty(TA0->TA0_DTVENC)
			If !MsgYesNo(STR0023,STR0015) //"O CRLV est� vencido. Deseja continuar?"###"Aten��o"
				Return .F.
			Endif
		Endif
	Else
		Return .F.
	Endif
ElseIf cCampo == "M->TDM_CIV"
	If ExistCpo("TA0",M->TDM_CIV)
		dbSelectArea("TA0")
		dbSetOrder(1)
		If dbSeek(xFilial("TA0")+M->TDM_CIV) .and. TA0->TA0_DTVENC < dDatabase .and. !Empty(TA0->TA0_DTVENC)
			If !MsgYesNo(STR0024,STR0015) //"O CIV est� vencido. Deseja continuar?"###"Aten��o"
				Return .F.
			Endif
		Endif
	Else
		Return .F.
	Endif
ElseIf cCampo == "M->TDM_CIPP"
	If ExistCpo("TA0",M->TDM_CIPP)
		dbSelectArea("TA0")
		dbSetOrder(1)
		If dbSeek(xFilial("TA0")+M->TDM_CIPP) .and. TA0->TA0_DTVENC < dDatabase .and. !Empty(TA0->TA0_DTVENC)
			If !MsgYesNo(STR0025,STR0015) //"O CIPP est� vencido. Deseja continuar?"###"Aten��o"
				Return .F.
			Endif
		Endif
	Else
		Return .F.
	Endif
ElseIf cCampo == "M->TDM_CODTRA"
	If ExistCpo("TDL",M->TDM_CODTRA)
		dbSelectArea("TDL")
		dbSetOrder(1)
		If dbSeek(xFilial("TDL")+M->TDM_CODTRA) .and. TDL->TDL_STATUS == "2"
			If !MsgYesNo(STR0026,STR0015) //"A Transportadora est� inativa. Deseja relacionar mesmo relacionar o ve�culo?"###"Aten��o"
				Return .F.
			Endif
		Endif
	Else
		Return .F.
	Endif
Endif

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SG550WHEN �Autor  �Roger Rodrigues     � Data �  12/04/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Executa o When dos campos                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA550                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SG550WHEN(cCampo)
If cCampo == "TDM_CODTRA"
	dbSelectArea("DA3")
	dbSetOrder(1)
	If dbSeek(xFilial("DA3")+M->TDM_CODVEI)
		If DA3->DA3_FROVEI == "2"//Terceiros
			Return .T.
		Else
			M->TDM_CODTRA := Space(TAMSX3("TDM_CODTRA")[1])
			M->TDM_DESTRA := Space(TAMSX3("TDM_DESTRA")[1])
			Return .F.
		Endif
	Else
		M->TDM_CODTRA := Space(TAMSX3("TDM_CODTRA")[1])
		M->TDM_DESTRA := Space(TAMSX3("TDM_DESTRA")[1])
		Return .F.
	Endif
Endif
Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SG550REL  �Autor  �Roger Rodrigues     � Data �  06/05/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Relacao dos campos da tela                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA550                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SG550REL(cCampo,lIniBrw)
Local cRetorno := ""
Default lIniBrw := .F.

If cCampo == "M->TDM_TPVEIC" .and. !Inclui
	dbSelectArea("DA3")
	dbSetOrder(1)
	If dbSeek(xFilial("DA3")+TDM->TDM_CODVEI)
		dbSelectArea("DUT")
		dbSetOrder(1)
		If dbSeek(xFilial("DUT")+DA3->DA3_TIPVEI)
			If lIniBrw
				cRetorno := NGRETSX3BOX("TDM_TPVEIC",DUT->DUT_CATVEI)
			Else
				cRetorno := DUT->DUT_CATVEI
			Endif
		Endif
	Endif
Endif

Return cRetorno