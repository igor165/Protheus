#INCLUDE "TmsC020.ch"
#Include 'Protheus.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSC020  � Autor � Henry Fila            � Data �19.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tracking                                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMSC020(cCliRem,cLojRem)
Local lTMC020BRW := ExistBlock('TMC020BRW')
Local cQuery     := ''
Local cFiltro    := ''
Local aCores     := {}
Local aIndex     := {}
Local bFiltraBrw := {}
Local aSetKey    := {}
Local nMvTFILTRK := 0 //-- Quantidade de dias para filtro dos registros de Tracking
Local dDatFim    := dDataBase
Local dDatIni    := (dDatFim-nMvTFILTRK)

//-- Define variaveis
Private cCadastro := STR0001 //"Tracking"
Private aRotina   := MenuDef()

//-- Default p/ variaveis
Default cCliRem := ""
Default cLojRem := ""

If lTMC020BRW //-- PE - Permite ao usuario filtrar a mbrowse
	cFiltro := ExecBlock("TMC020BRW",.F.,.F.)
EndIf

Aadd(aSetKey, { VK_F12 , { || Pergunte("TMA500",.T.) } } )

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

//-- Legenda dos documentos de transporte
AAdd( aCores ,{"DTC_NFENTR=='1'" ,'BR_MARROM'	})	// Entregue
AAdd( aCores ,{"DTC_NFENTR=='2'" ,'BR_AMARELO'	})	// N�o Entregue
AAdd( aCores ,{"DTC_NFENTR=='3'" ,'BR_PRETO'	})	// Bloqueada

//-- Filtro do Browse
If !Empty(cCliRem) .And. !Empty(cLojRem)
	//-- Par�metro para quantidade de dias para filtro.
	nMvTFILTRK := SuperGetMv('MV_TFILTRK',,120) //-- Quantidade de dias para filtro dos registros de Tracking
	dDatIni    := (dDatFim-Iif(nMvTFILTRK>0,nMvTFILTRK,120))
	If !Empty(cFiltro)
		cFiltro += ".And."
	EndIf
	cFiltro += "DTC_CLIREM=='"+cCliRem+"'.And."
	cFiltro += "DTC_LOJREM=='"+cLojRem+"'.And."
	cFiltro += "Dtos(DTC_EMINFC)>='"+Dtos(dDatIni)+"'.And."
	cFiltro += "Dtos(DTC_EMINFC)<='"+Dtos(dDatFim)+"'.And."
	cFiltro += "!Empty(DTC_FILDOC)"
EndIf

//-- Endereca a funcao de BROWSE
mBrowse(6,1,22,75,'DTC',,,,,,aCores,,,,,,,,/*cQuery*/,,,,Iif(!Empty(cFiltro),cFiltro,''))

//-- Finaliza Teclas de Atalhos
TmsKeyOff(aSetKey) //-- Restaura SetKey

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSC020Vis� Autor � Henry Fila            � Data �19.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tracking                                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tmsc020Vis( cAlias, nReg, nOpcx )

Local aArea    := GetArea()
Local aAreaDT6 := DT6->(GetArea())

DT6->(dbSetOrder(1))
If DT6->(MsSeek(xFilial("DT6")+DTC->DTC_FILORI+DTC->DTC_DOC+DTC->DTC_SERIE))
	TMSA500Mnt('DT6',DT6->(Recno()),2)
Else
	TmsA050Mnt('DTC',DTC->(Recno()),2)
EndIf

RestArea(aAreaDT6)
RestArea(aArea)

Return

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �    6 - Alteracao sem inclusao de registro                  ���
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

Private aRotina	:= {	{ STR0002  ,'AxPesqui'  ,0,1,0,.F.},; //"Pesquisar"
						{ STR0003  ,'TMSC020Vis',0,2,0,NIL},; //"Visualizar"
						{ 'Legenda','TMSC020Leg',0,3,0,NIL} } //"Legenda"


If ExistBlock("TMC020MNU")
	ExecBlock("TMC020MNU",.F.,.F.)
EndIf

Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSC020Leg� Autor � Marcelo Coutinho      � Data �11.04.2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Tracking                                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tmsc020Leg( cAlias, nReg, nOpcx )

BrwLegenda( cCadastro		,'Status Doc. do Cliente', {; //'Status'
        	{ 'BR_MARROM'	,'Entregue'		},; //'Entregue'
			{ 'BR_AMARELO'	,'N�o Entregue'	},; //'N�o Entregue'
			{ 'BR_PRETO'	,'Bloqueada'	}}) //'Bloqueada'

Return( Nil )