// �����������������ͻ
// � Versao � 6      �
// �����������������ͼ

#include "PROTHEUS.CH" 
#include "OFIXA019.CH"

/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    � OFIXA019 � Autor � Luis Delorme                      � Data � 28/09/13 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Liberacao de Credito do Oficina                                        ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Function OFIXA019()
//
Local cFilTop     := ""
Local cConcat     := ""
Local cFunc       := ""
Private cCadastro := STR0001
Private cMotivo   := "000012"  // Filtro da consulta do motivo
Private aRotina   := MenuDef()
Private aCores    := {	{'LEFT(VSW->VSW_NUMORC,2)<>"OS"','BR_PRETO'},; // Solicitacao de Orcamento
						{'LEFT(VSW->VSW_NUMORC,2)=="OS".and.VSW->VSW_LIBVOO=="OS_TOTAL"','BR_AZUL'},; // Solicitacao de OS Total
						{'LEFT(VSW->VSW_NUMORC,2)=="OS".and.VSW->VSW_LIBVOO<>"OS_TOTAL"','BR_VERDE'}} // Solicitacao de OS + Tipo de Tempo
Private oSqlHelp:= DMS_SqlHelper():New()

cFunc   := oSqlHelp:CompatFunc("SUBSTR")
cConcat := oSqlHelp:Concat({cFunc+'(VSW_DATHOR,7,2)', cFunc+'(VSW_DATHOR,4,2)', cFunc+'(VSW_DATHOR,1,2)'})
cFilTop := cFunc+"(VSW_NUMORC,1,2) = 'OS' AND "+cConcat+" > '"+Right(dtos(ddatabase - GetNewPar("MV_MIL0017",15)),6)+"' AND VSW_DTHLIB = '" + Space(TamSX3("VSW_DTHLIB")[1]) + "' "
mBrowse( 6, 1,22,75,"VSW",,,,,,aCores,,,,,,,,cFilTop)

return .t.
/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    � OXA019V  � Autor � Luis Delorme                      � Data � 26/01/09 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Montagem da Janela de Orcamento de Oficina                             ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Function OXA019V(cAlias,nReg,nOpc)

Return .t.

/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    � OXA019M  � Autor � Luis Delorme                      � Data � 05/08/10 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Mostra Posicao do Cliente e motivo do Pedido de Liberacao              ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Function OXA019M()
//

PutMv("MV_CKCLIXX","")
DBSelectArea("VS1")
FG_CKCLINI(VSW->VSW_CODCLI+VSW->VSW_LOJA,.t.,.t.)

Return

/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    � OXA019V  � Autor � Luis Delorme                      � Data � 26/01/09 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Montagem da Janela de Orcamento de Oficina                             ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Function OXA019L(cAlias,nReg,nOpc)
//
if ExistBlock("OXA019LB")
	if !ExecBlock("OXA019LB",.f.,.f.)
		Return(.f.)
	Endif
Endif
DBSelectArea("VSW")
if !MsgYesNo(STR0008,STR0006)
	return .f.
endif
if !MsgYesNo(STR0009,STR0006)
	return .f.
endif
// dbClearFilter()           // CLAUDIA

if VAI->(FieldPos("VAI_ALLBCR")) > 0  
	DbSelectArea("VAI")
	Dbsetorder(4)
	DbSeek(xFilial("VAI")+__cUserID)
	if VAI->VAI_ALLBCR > 0 
		if VAI->VAI_ALLBCR < VSW->VSW_VALCRE
			MsgStop(STR0022,STR0006)		
			Return(.f.)
		Endif
	Endif
Endif

                              
cMotivo := space(TamSX3("VSW_MOTIVO")[1])
nOpca := 1
DEFINE MSDIALOG oDlgMot TITLE OemtoAnsi(STR0015) FROM  01,11 TO 08,76 OF oMainWnd

oTPanelLib := TPanel():New(0,0,"",oDlgMot,NIL,.T.,.F.,NIL,NIL,0,08,.T.,.F.)
oTPanelLib:Align := CONTROL_ALIGN_ALLCLIENT

@ 005,003 SAY STR0014 SIZE 170,40  Of oTPanelLib PIXEL 
@ 005,030 MSGET oMotivo VAR cMotivo PICTURE "@!" SIZE 200,4 OF oTPanelLib PIXEL COLOR CLR_BLUE 


ACTIVATE MSDIALOG oDlgMot ON INIT EnchoiceBar(oDlgMot,{||nOpca := 1,oDlgMot:End()},{||nOpca := 0,oDlgMot:End()}) CENTER

DBSelectArea("VAI")
DBSetOrder(6)
DBSeek(xFilial("VAI")+VS1->VS1_CODVEN)

DBSelectArea("SA1")
DBSetOrder(1)
DBSeek(xFIlial("SA1")+VS1->VS1_CLIFAT + VS1->VS1_LOJA)

if nOpca == 1
	DBSelectArea("VSW")
	RecLock("VSW",.f.)
	VSW_USULIB := Subs(cUsuario,7,15)
	VSW_DTHLIB := Left(Dtoc(dDataBase),6)+Right(STR(Year(dDataBase)),2)+"-"+Left(Time(),5)
	VSW_MOTIVO := cMotivo
	msunlock()
endif

Return .t.

/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    � OXA019P  � Autor � Thiago		                    � Data � 04/09/14 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Posicao do cliente.						                              ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Function OXA019P(cAlias,nReg,nOpc)

DBSelectArea("SA1")
DBSetOrder(1)
DBSeek(xFilial("SA1")+VSW->VSW_CODCLI + VSW->VSW_LOJA)  
FC010CON() // Tela de Consulta -> Posicao do Cliente

Return .t.

/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    � OXA019LG � Autor � Andre Luis Almeida                � Data � 23/02/16 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Legenda - Solicitacoes de Liberacao                                    ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Function OXA019LG()
Local aLegenda := {	{'BR_PRETO', STR0019 },; // Solicitacao de Orcamento
					{'BR_AZUL' , STR0020 },; // Solicitacao de OS Total
					{'BR_VERDE', STR0021 }}  // Solicitacao de OS + Tipo de Tempo
BrwLegenda(cCadastro,STR0018,aLegenda) // Legenda
Return

/*
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Luis Delorme                      � Data � 26/01/09 ���
�������������������������������������������������������������������������������������Ĵ��
���Descricao � Menu (AROTINA) - Orcamento de Oficina                                  ���
�������������������������������������������������������������������������������������Ĵ��
���Uso       � Veiculos                                                               ���
��������������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina := {	{ STR0002, "axPesqui" , 0, 1 },; // "Pesquisar"
					{ STR0014, "OXA019M"  , 0, 2 },; // "Verificar Motivo"
					{ STR0004, "OXA019L"  , 0, 4 },; // "Liberar"
					{ STR0016, "OFIXC007(.t.)" , 0, 2 },; // Consulta
					{ STR0017, "OXA019P"  , 0, 4 },; // Posicao do cliente
					{ STR0018, "OXA019LG" , 0, 4, 2, .f.}} // Legenda
Return aRotina