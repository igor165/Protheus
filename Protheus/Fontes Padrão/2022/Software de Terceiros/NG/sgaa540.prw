#INCLUDE "SGAA540.ch"
#include "protheus.ch"
#Define _nVERSAO 3
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGAA540   �Autor  �Roger Rodrigues     � Data �  17/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para cadastro de informacoes complementares de trans ���
���          �portadoras            	       							  ���
�������������������������������������������������������������������������͹��
���Uso       �SIGASGA                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGAA540()
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
Private lAleat := .F.//Variavel de Filtro
Private aRotina   := MenuDef()
Private aNGButton := {}
Private aChkSql   := NGRETSX9("TDL")//Tabelas a serem verificadas na exclusao
Private cCadastro := OemToAnsi(STR0001) //"Complemento Transportadoras"

//Verifica se o Update de FMR esta aplicado
If !SGAUPDFMR("TDL")
	Return .F.
Endif
Aadd(aNgButton,{"PARAMETROS" ,{||Sg540QDO()},STR0002,STR0003}) //"Relacionar documento"###"Rel.Doc."

dbSelectArea("TDL")
mBrowse( 6, 1,22,75,"TDL",,,,,,SG540SEMAF(),,,,,.F.)

dbSelectArea("TDL")
Set Filter To//Retorna Filtro

NGRETURNPRM(aNGBEGINPRM)
Return .T.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SG540SEMAF�Autor  �Roger Rodrigues     � Data �  17/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Define as cores de semaforo para as Transportadoras         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SGAA540                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SG540SEMAF()
Local aCores :={{"NGSEMAFARO('TDL->TDL_STATUS == "+'"1"'+"')" , "BR_VERDE" },;
				{"NGSEMAFARO('TDL->TDL_STATUS == "+'"2"'+"')" , "BR_VERMELHO"}}

Return aCores
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SG540LEG  �Autor  �Roger Rodrigues     � Data �  17/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta Browse com legenda                           	      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA540                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SG540LEG()
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
Local aRotina :=	{ { STR0007	, "AxPesqui", 0 , 1},; //"Pesquisar"
                      { STR0008	, "NGCAD01"	, 0 , 2},; //"Visualizar"
                      { STR0009	, "NGCAD01"	, 0 , 3},; //"Incluir"
                      { STR0010	, "NGCAD01"	, 0 , 4},; //"Alterar"
                      { STR0011	, "NGCAD01"	, 0 , 5, 3},; //"Excluir"
						 { STR0022 , "MsDocument", 0 , 4},;//Co&nhecimento                      
                      { STR0004	, "SG540LEG", 0 , 3}} //"Legenda"

Return aRotina
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SG540QDO  �Autor  �Roger Rodrigues     � Data �  12/04/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta tela para relacionamento de documento                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA540                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SG540QDO()
Local oDlgQdo, oRadio
Local nRadio := 1,nOpc := 1
Local lRet := .t.
Local lGrava := .F.

Define MsDialog oDlgQdo From 03.5,6 To 150,320 Title STR0021 Pixel //"Aten��o"

Define FONT oBold NAME "Courier New" SIZE 0, -13 BOLD
@ 0, 0 BITMAP oBmp RESNAME "PROJETOAP" oF oDlgQdo SIZE 35,250 NOBORDER WHEN .F. PIXEL

@ 05,040 Say OemToAnsi(STR0015) Size 117,7 Of oDlgQdo Pixel Font oBold //"O que deseja fazer ?"

@ 20,048 Radio oRadio Var nRadio Items STR0016,STR0017,; //"Relacionar um documento"###"Visualizar documento relacionado"
															STR0018 3d Size 105,10 Of oDlgQdo Pixel //"Apagar um Documento Relacionamento"

Define sButton From 055,090 Type 1 Enable Of oDlgQdo Action (lGrava := .t.,oDlgQdo:End())
Define sButton From 055,120 Type 2 Enable Of oDlgQdo Action (lGrava := .f.,oDlgQdo:End())

Activate MsDialog oDlgQdo Centered 

If !lGrava
	lRet := .f.
Else
	If nRadio == 1
		If !Sg540RelQdo()
			lRet := .f.
		EndIf
	ElseIf nRadio == 2
		If !Sg540VieQdo()
			lRet := .f.
		EndIf
	Else
		M->TDL_DOCTO  := " "
		M->TDL_DOCFIL := " "
	EndIf
EndIf

Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Sg540RelQdo �Autor  �Roger Rodrigues   � Data �  12/04/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Relaciona um documento                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA540                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Sg540RelQdo()
Local lRet := .F.

lRet := ConPad1( , , , "QDT1",,,.f.)
If lRet
	M->TDL_DOCTO  := QDH->QDH_DOCTO
	M->TDL_DOCFIL := QDH->QDH_FILIAL
EndIf

Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Sg540VieQdo �Autor  �Roger Rodrigues   � Data �  12/04/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Visualiza um documento                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA540                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Sg540VieQdo()
Local _lRet := .F.

If !Empty(M->TDL_DOCTO)
	If QDOVIEW( , M->TDL_DOCTO )//Visualiza documento Word
		_lRet := .t.
	EndIf
Else
	MsgInfo(STR0019) //"N�o existe documento associado a esta Transportadora."
Endif

Return _lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SG540LAM  �Autor  �Roger Rodrigues     � Data �  12/04/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida lincen�a da transportadora                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA540                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SG540LAM()
dbSelectArea("TA0")
dbSetOrder(1)
If dbSeek(xFilial("TA0")+M->TDL_CODLAM)
	If TA0->TA0_DTVENC < dDatabase
		If !MsgYesNo(STR0020,STR0021) //"A licen�a ambiental est� vencida. Deseja continuar?"###"Aten��o"
			Return .F.
		Endif
	Endif
Endif
Return .T.