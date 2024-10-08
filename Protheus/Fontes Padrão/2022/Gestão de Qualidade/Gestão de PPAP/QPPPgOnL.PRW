#Include "PanelOnLine.ch"
#include "PPAPPGOnl.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QPPPGOnl � Autor � Rafael S. Bernardi    � Data �22/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descricao � Painel de Gestao On-line - Modulo SIGAPPAP                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QPPPGOnl(ExpO1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = obj do proces.                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAPPAP                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function PPAPPGOnl(oPGOnline)
Local aToolBar := {}
Local cHelp    := ""
         
cHelp := STR0001//"O sistema ira listar as pecas de acordo com o intervalo definido pelo usuario. "
cHelp += STR0002//"Ira considerar um PPAP completo, se existerem todos os documentos selecionados "
cHelp += STR0003//"no primeiro parametro pelo usuario para aquela peca. Caso contrario, ira considerar "
cHelp += STR0004//"o PPAP da peca como incompleto."

Aadd( aToolBar, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp+'")) }') } )

//--Painel 1 - PPAPs Completos / Incompletos
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0005 ; //"PPAPs Completos / Incompletos" - Esta descricao aparece na lista de paineis disponiveis, superior esquerdo
	DESCR STR0005 ; //"PPAPs Completos / Incompletos" - Descricao na Barra Superior
	TYPE 5 ; //-- Tipo do Painel
	PARAMETERS "QPPP10" ; //--Grupo de Perguntas
	ONLOAD "QPPP010" ; //--Funcao para montagem do Painel
	REFRESH 600 ; //--Tempo para Refresh do Painel em segundos
	TOOLBAR aToolBar ;//--Help que sera apresentado ao usu�rio sobre o resultado do painel
	DEFAULT 5	 ; //-- Default do Combo
	NAME "1"; //--Ordem de Exibicao
	
Return