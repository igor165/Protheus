#INCLUDE "sgaa500.ch"
#include "protheus.ch"
#Define _nVERSAO 2
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SGAA500   �Autor  �Roger Rodrigues     � Data �  17/03/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para cadastro e reabertura de FMR - Fichas de		  ���
���          �Movimenta��o de Residuos									  ���
�������������������������������������������������������������������������͹��
���Uso       �SIGASGA                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SGAA500(aFiltroFmr)

	Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)
	Local cParStat := SuperGetMv("MV_NGSGASF",.F.,"2")
	Local cFilter500 := "(TDC->TDC_STATUS == '1' .Or. TDC->TDC_STATUS == '4')"
	Private aRotina := MenuDef()
	Private cCadastro := OemToAnsi(STR0001) //"Cadastro de FMRs - Ficha de Movimenta��o de Res�duos"

	If cParStat == "1"
		MsgStop(STR0009)//"O par�metro MV_NGSGASF est� habilitado, portanto, a inclus�o de FMR deve ser feita pela rotina de Log�stica de Retirada."
		Return .T.
	EndIf

	//Verifica se o Update de FMR esta aplicado
	If !SGAUPDFMR()
		Return .F.
	Endif

	dbSelectArea("TDC")

	If !Empty(aFiltroFmr)
		cFilter500 += " .And. " + BuildFilter(aFiltroFmr)
	EndIf

	Set Filter to &(cFilter500)

	mBrowse( 6, 1,22,75,"TDC",,,,,,SG510SEMAF())

	dbSelectArea("TDC")
	Set Filter To//Retorna Filtro

	NGRETURNPRM(aNGBEGINPRM)

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Roger Rodrigues       � Data �27/10/2009���
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
Local aRotina :=	{	{ STR0002	, "AxPesqui" , 0 , 1},; //"Pesquisar"
                 	{ STR0003	, "SG510ALT" , 0 , 2},; //"Visualizar"
                 	{ STR0004	, "SG510ALT" , 0 , 3},; //"Incluir"
                 	{ STR0005	, "SG510ALT" , 0 , 4},; //"Conformidade"
                 	{ STR0006	, "SG500LEG" , 0 , 3}} //"Legenda"

Return aRotina
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SG500LEG  �Autor  �Roger Rodrigues     � Data �  17/03/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta Browse com legenda                           	      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �SGAA500                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function SG500LEG()
BrwLegenda(cCadastro,STR0006,{	{"BR_VERMELHO", STR0007 },; //"Legenda"###"Ponto de Coleta"
									{"BR_PRETO", STR0008}}) //"N�o Conforme"

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} BuildFilter
Fun��o utilizada pelo TNGPG, para planta gr�fica no m�dulo de SGA.
Verifica o campo passado por param�tro

@author Gabriel Augusto Werlich
@since 03/07/2014
@version MP11
@return cFiltro, retorna a String a ser passada para o Set Filter.
/*/
//---------------------------------------------------------------------
Static Function BuildFilter(aFiltroFmr)

	Local cFiltro := ""
	Local i

	For i := 1 to Len(aFiltroFmr)
		cFiltro += If(i > 1," .And. ", "")
		cFiltro += aFiltroFmr[i][1] + " == '" + aFiltroFmr[i][2] + "'"
	Next

Return cFiltro