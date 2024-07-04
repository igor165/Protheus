#include "VEIXA011.CH"
#include "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    � VEIXA021 � Autor � Andre Luis Almeida / Luis Delorme � Data � 27/01/11 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Pedido de Venda de Ve�culos                                            ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Function VEIXA021()
Private cCadastro := STR0001 // Saida de Veiculos por Venda
Private aRotina   := MenuDef()
Private aCores    := 	{	{'VPN->VPN_STATUS == "A"','BR_VERDE' },;		// Valida
							{'VPN->VPN_STATUS == "P"','BR_AMARELO' },;	// Cancelada
							{'VPN->VPN_STATUS == "F"','BR_PRETO' },;// Devolvida
							{'VPN->VPN_STATUS == "C"','BR_VERMELHO' }}
Private cSitVei := "0" // <-- COMPATIBILIDADE COM O SXB - Cons. V11
Private cBrwCond := 'VPN->VPN_OPEMOV=="0"' // Condicao do Browse, validar ao Incluir/Alterar/Excluir
//
If ( ExistBlock("VA021LEG") )			
	aCoresUsr := ExecBlock("VA021LEG",.F.,.F.,{aCores,"C"})
	If ( ValType(aCoresUsr) == "A" )
		aCores := aClone(aCoresUsr)
	EndIf
EndIf
//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
dbSelectArea("VPN")
dbSetOrder(1)
//
FilBrowse('VPN',{},'VPN->VPN_OPEMOV=="0"')
mBrowse( 6, 1,22,75,"VPN",,,,,,aCores)
dbClearFilter()
//
Return
/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    � VXA011   � Autor � Andre Luis Almeida / Luis Delorme � Data � 26/01/09 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Montagem da Janela de Saida de Veiculos por Venda                      ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Function VXA021(cAlias,nReg,nOpc)
Local lRet
//
If &cBrwCond .or. nOpc == 3// Condicao do Browse, validar ao Incluir/Alterar/Excluir
	if VPN->VPN_STATUS != "A" .and. nOpc == 4
		MsgStop(STR0011,STR0012)
		return .f.
	endif
	if VPN->VPN_STATUS $ "FC" .and. nOpc == 6
		MsgStop(STR0013,STR0012)
		return .f.
	endif
	if VPN->VPN_STATUS $ "FC" .and. nOpc == 5
		MsgStop(STR0014,STR0012)
		return .f.
	endif
	DBSelectArea("VPN")
	DBClearFilter()
	lRet = VEIXX021(NIL,NIL,NIL,nOpc,"0")
	FilBrowse('VPN',{},'VPN->VPN_OPEMOV=="0"')
EndIf
//
Return .t.
/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Andre Luis Almeida / Luis Delorme � Data � 26/01/09 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Menu (AROTINA) - Saida de Veiculos por Venda                           ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina := {	{ OemtoAnsi(STR0002) ,"AxPesqui" 		, 0 , 1},;				// Pesquisar
							{ OemtoAnsi(STR0003) ,"VXA021"    		, 0 , 2},;		// Visualizar
							{ OemtoAnsi(STR0004) ,"VXA021"    		, 0 , 3},;		// Incluir
							{ OemtoAnsi(STR0015) ,"VXA021"     	, 0 , 4},;		// Faturar							
							{ OemtoAnsi(STR0005) ,"VXA021"     		, 0 , 5},;		// Cancelar
							{ OemtoAnsi(STR0016) ,"VXA021"     	, 0 , 6},;		// Faturar
							{ OemtoAnsi(STR0006) ,"VXA021LEG"		, 0 , 7}}	// Pesquisa Avancada ( S-Saida por 0-Venda )
//
Return aRotina
/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    �VXA011LEG � Autor � Andre Luis Almeida / Luis Delorme � Data � 26/01/09 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Legenda - Saida de Veiculos por Venda                                  ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Function VXA021LEG()
Local aLegenda := {	{'BR_VERDE',STR0017},;			// Valida
					{'BR_VERMELHO',STR0018},;	// Cancelada
					{'BR_AMARELO',STR0019},;		// Pendente
					{'BR_PRETO',STR0020}}			// Devolvida
//
If ( ExistBlock("VA021LEG") )			
	aRecebe := ExecBlock("VA021LEG",.F.,.F.,{aLegenda,"L"})
	If ( ValType(aRecebe) == "A" )
		aLegenda := aClone(aRecebe)
	EndIf
EndIf
//
BrwLegenda(cCadastro,STR0006,aLegenda)
//
Return

/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    �VXA011LEG � Autor � Andre Luis Almeida / Luis Delorme � Data � 26/01/09 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Legenda - Saida de Veiculos por Venda                                  ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Function VXA021IBRW(nTipo)
Default nTipo = 0
DBSelectArea("VV1")
DBSetOrder(1)
DBSeek(xFilial("VV1")+VPO->VPO_CHAINT)
//          

DBSelectArea("VE1")
DBSeek(xFilial("VE1")+VV1->VV1_CODMAR)

FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)

DBSelectArea("VVC")
DBSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI)
//   
if nTipo == 1
	return VE1->VE1_DESMAR
endif
if nTipo == 2
	return VVC->VVC_DESCRI
endif
if nTipo == 3
	return VV2->VV2_DESMOD
endif
if nTipo == 4
	return VV1->VV1_PLAVEI
endif
//
Return