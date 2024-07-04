#Include "PROTHEUS.Ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QMTM910  �Autora � Iuri Seto             � Data � 03/07/00 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Conversao da Tabela QMU da versao 5.07/4.07 para 5.08.     ���
���          � Na versao 5.08 o campo QMU_TIPO foi excluido e com isso    ���
���          � os registros podem ficar com a chave duplicada, este con-  ���
���          � versor elimina os registros duplicados.                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaQmt                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QMTM910()
Local	cChave 	:= ""
Local 	cText	:= ""

dbSelectArea("QMU")
QMU->(dbSetOrder(1))
QMU->(dbGoTop())

UpdSet01(LastRec())

cChave := QMU->QMU_FILIAL+QMU->QMU_INSTR+QMU->QMU_REVINS+DTOS(QMU->QMU_DATA)+QMU->QMU_REFER+QMU->QMU_ITEM
QMU->(dbSkip())

While !QMU->(Eof())                                        
    If cChave == QMU->QMU_FILIAL+QMU->QMU_INSTR+QMU->QMU_REVINS+DTOS(QMU->QMU_DATA)+QMU->QMU_REFER+QMU->QMU_ITEM
		RecLock("QMU",.F.)
		dbDelete()
		MsUnLock()
	Else		
		cChave := QMU->QMU_FILIAL+QMU->QMU_INSTR+QMU->QMU_REVINS+DTOS(QMU->QMU_DATA)+QMU->QMU_REFER+QMU->QMU_ITEM
	EndIf		
	QMU->(dbSkip())
	
 	cText := 'Arquivo  : QMU ' + CRLF
 	cText += 'Operacao : Otimizando os ensaios de M.S.A.'
 	UpdInc01( cText,  .T. )

EndDo  

DbCommitAll()

Return
 
