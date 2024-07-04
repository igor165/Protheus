#include "FINA015.CH"
#include "PROTHEUS.CH"
#define CRLF	CHR(13)+CHR(10)


// 17/08/2009 - Compilacao para o campo filial de 4 posicoes
// 18/08/2009 - Compilacao para o campo filial de 4 posicoes

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � FINA015  � Autor � Bruno Sobieski Chavez � Data �12/06/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Tipo de documentos.             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void FINA015(void)                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU��O INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FINA015(nOpc)
Private aRotina := MenuDef()

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemtoAnsi(STR0006)         //"Atualiza��o des Tipos de Titulos"

PRIVATE INCLUI    := .F.
PRIVATE ALTERA    := .F.
//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"SES")

Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FA015Inclui� Autor � Bruno Sobieski Chavez� Data �12/06/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Inclusao de Tipos de titulos                   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void Fa015Inclui(ExpC1,ExpN1)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA015()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FA015INCLUI(cAlias,nReg,nOpc)

//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
INCLUI := .T.
ALTERA := .F.
While .T.
	nOpcA:=0
	nOpcA:=AxInclui( cAlias, nReg, nOpc)
	dbSelectArea("SX5")
	If !(dbSeek(cFilial+"05"+SES->ES_TIPO))
		RecLock("SX5",.T.)
		X5_FILIAL 	:=	xFilial("SX5")
		X5_TABELA	:=	"05"
		X5_CHAVE	:=	SES->ES_TIPO
		X5_DESCRI	:=	SES->ES_DESC
		X5_DESCSPA	:=	SES->ES_DESC
		X5_DESCENG	:=	SES->ES_DESC
		MsUnlock()
	Endif
	DbSelectArea(cAlias)
	CriaTipos()
	Exit
Enddo

Return .T.



/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FA015Altera� Autor � Bruno Sobieski Chavez� Data �12/06/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Modificacao de  Tipos de titulos               ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void Fa015Inclui(ExpC1,ExpN1)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA010()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FA015Altera(cAlias,nReg,nOpc)
Local nOpca
//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������
Private aTELA[0][0],aGETS[0],nRegSES
INCLUI := .F.
ALTERA := .T.
nRegSES:=nReg
While .T.
	nOpcA:=0
	nOpcA:=AxAltera( cAlias, nReg, nOpc)

	CriaTipos()

	dbSelectArea(cAlias)
	Exit
End

Return .T.                                

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FA015Deleta� Autor � Bruno Sobieski Chavez� Data �12/06/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Delecao de Tipos de titulos.                   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void Fa015Inclui(ExpC1,ExpN1)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA010()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FA015Deleta(cAlias,nReg,nOpc)
Local nOpcA	:= Nil
Local oDlg	:= Nil
Local oSize	:= Nil
Local aPos	:= {}

Private aTELA[0][0],aGETS[0]

oSize := FWDefSize():New(.T.)
oSize:AddObject( "ENCHOICE", 100,100, .T., .T. ) // Adiciona enchoice
oSize:Process()
aPos := {oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI"),oSize:GetDimension("ENCHOICE","LINEND"),oSize:GetDimension("ENCHOICE","COLEND")}

//��������������������������������������������Ŀ
//� Envia para processamento dos Gets          �
//����������������������������������������������
nOpcA:=0
IF SoftLock(cAlias)
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
		EnChoice(cAlias,nReg,nOpc,,"AC",OemToAnsi(STR0007),,aPos)              //"Quanto � exclus�o?"
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})
	
	DbSelectArea(cAlias)
	IF nOpcA == 2
		Begin Transaction
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.T.)
			dbDelete()
			MSUNLOCK()
		
			dbSelectArea("SX5")
			If dbSeek(cFilial+"05"+SES->ES_TIPO)
				RecLock("SX5",.F.,.T.)
				dbDelete()
				MsUnlock()
			Endif
		End Transaction
	Endif
Endif
dbSelectArea(cAlias)
Return .T.


/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FA015Vld   � Autor � Bruno Sobieski Chavez� Data �12/06/2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de validacao da inclusao e da alteracao           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void Fa015Inclui(ExpC1)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Campo modificado                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA010()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fa015Vld()
Local cCampo	:=	Alltrim(ReadVar())
Local cConteudo
Local lRet	:=	.T.

cConteudo	:=	&cCampo.
DbSelectArea("SES")

//1=Receber
//2=PAgar
//3=Banco
//4=Todas
Do Case
	Case 	cCampo	==	"M->ES_TIPORIG"
		DbSetOrder(2)
		If DbSeek(xFilial()+cConteudo)
			If (ALTERA .And. Recno()<>nRegSES) .Or. INCLUI
				MsgAlert(STR0016+CRLF+STR0017)
				lRet:=.F.
			Endif
		Endif
	Case 	cCampo	==	"M->ES_TIPO" .And. !Empty(M->ES_CARTEIR)
		DbSetOrder(1)
		If DbSeek(xFilial()+cConteudo)
			While !EOF().And. cConteudo == ES_TIPO.And. xFilial() == ES_FILIAL
				If M->ES_CARTEIR == ES_CARTEIRA .Or. ES_CARTEIR=="3" .Or. M->ES_CARTEIR == "3"
					Help(1,"", "ExistChav")
					lRet	:=	.F.
					Exit
				Endif
				DbSkip()
			Enddo
		Endif
	Case cCampo	==	"M->ES_CARTEIR" 
		If !Empty(M->ES_TIPO)
			DbSetOrder(1)
			If DbSeek(xFilial()+M->ES_TIPO)
				While !EOF().And. M->ES_TIPO == ES_TIPO.And. xFilial() == ES_FILIAL
					If (cConteudo == ES_CARTEIRA .Or. ES_CARTEIR=="3" .Or. cConteudo == "3")
						Help(1,"", "ExistChav")
						lRet	:=	.F.
						Exit
					Endif
					DbSkip()
				Enddo
			Endif
		ElseIf Type("M->ES_TIPORIG") <> "U" .And. !Empty(M->ES_TIPORIG)
			DbSetOrder(2)
			If DbSeek(xFilial()+M->ES_TIPORIG)
				While !EOF().And. M->ES_TIPORIG == ES_TIPORIG.And. xFilial() == ES_FILIAL
					If (cConteudo == ES_CARTEIRA .Or. ES_CARTEIR=="3" .Or. cConteudo == "3")
						Help(1,"", "ExistChav")
						lRet	:=	.F.
						Exit
					Endif
					DbSkip()
				Enddo
			Endif		
		Endif
	Case cCampo	==	"M->ES_ABATIM"
		M->ES_SINAL	:=		IIf(cConteudo == 	"1","-",M->ES_SINAL)
	Case cCampo == "M->ES_SINAL"
		M->ES_ABATIM:=		IIf(cConteudo ==	"+","2",M->ES_ABATIM)
EndCase

Return lret

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �17/11/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {	{ STR0001	,"AxPesqui"		, 0 , 1,,.F.},;      //"Pesquisar"
{ STR0002  	,"AxVisual"		, 0 , 2},;      //"Visualizar"
{ STR0003   ,"FA015Inclui"	, 0 , 3},;      //"Incluir"
{ STR0004   ,"FA015Altera"	, 0 , 4, 2},;   //"Alterar"
{ STR0005   ,"Fa015Deleta"	, 0 , 5, 1} }   //"Excluir"

Return(aRotina)