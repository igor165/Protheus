#INCLUDE "ofipa940.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIPA940 � Autor �  Fabio                � Data � 13/07/99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grupo de Itens                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � (Pecas)                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION OFIPA940

PRIVATE aCampos := {}
PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0005) //"Grupo de Itens"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"SBM")

Return


********************************
Function PC000V(cAlias,nReg,nOpc)

PegaCpos()
AxVisual(cAlias,nReg,nOpc,aCampos)

Return


********************************
Function PC000I(cAlias,nReg,nOpc)

PegaCpos()
AxInclui(cAlias,nReg,nOpc,aCampos)

Return

********************************
Function PC000A(cAlias,nReg,nOpc)

PegaCpos()
AxAltera(cAlias,nReg,nOpc,aCampos)

Return
                                                          
/*
********************************
Function PC000E(cAlias,nReg,nOpc)

PegaCpos()
AxDeleta(cAlias,nReg,nOpc,aCampos)

Return
*/

Static Function PEGACPOS()
***************************

DbSelectArea("SX3")
dbseek("SBM02")
aCampos := {}

do While !eof() .and. x3_arquivo == "SBM"
    if x3_nivel # 0
       aadd(aCampos,x3_campo)
    Endif
    dbskip()
Enddo
DbSelectArea("SBM")

Return

Static Function MenuDef()
Local aRotina := { { STR0001 ,"AxPesqui", 0 , 1},; 		//Pesquisar
                     { STR0002,"PC000V", 0 , 2},; 		//Visualizar
                     { STR0003   ,"PC000I", 0 , 3},; 	//Incluir
                     { STR0004   ,"PC000A", 0 , 4} } 	//Alterar
Return aRotina
