#INCLUDE "PROTHEUS.CH"
#INCLUDE "QMTUPDAT.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QMTUPDAT  � Autor � Denis Martins         � Data �02/02/2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Compatibiliza a versao 8.11								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQMT                                                    ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���            �        �      � 										  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QMTUPDAT()  

Local cTexto := ""
Local nCto    := 1
Local cChvQA3 := ""
Local cChvEsp := ""
Local cSequ	  := "001"	

cTexto := STR0001 // "Atualizando arquivo de Padroes Secundarios...QMS"

If Type("_Upd101")<>"U" .And. !_Upd101 //-- Executa apenas se estiver vindo da vers�o 811 
	
	DbSelectArea("QMS")
	UPdSet01(RecCount())
	DbSetOrder(0)
	DbGotop()
	While !Eof()     
		UpdInc01(cTexto+" QMS",.T.)
		RecLock("QMS",.F.)
		QMS->QMS_REVINV   := INVERTE(QMS->QMS_REVINS)   //Revisao Invertida
		MsUnlock()
		DbSkip()
	EndDo
	
	cTexto := STR0002 //"Atualizando arquivo de Instrumentos Utilizados...QMI"
	
	DbSelectArea("QMI")
	UPdSet01(RecCount())
	DbSetOrder(0)
	DbGotop()
	While !Eof()     
		UpdInc01(cTexto+" QMI",.T.)
		RecLock("QMI",.F.)
		QMI->QMI_REVINV   := INVERTE(QMI->QMI_REVINS)   //Revisao Invertida
		MsUnlock()
		DbSkip()
	EndDo
	
	dbSelectArea("QA3")
	UPdSet01(RecCount())
	DbSetOrder(0)
	DbGotop()
	nCto  	:= 1
	cChvQA3 := QA3->QA3_CHAVE
	cChvEsp := QA3->QA3_ESPEC
	While !Eof()
		If cChvQA3+cChvEsp == QA3->QA3_CHAVE+QA3->QA3_ESPEC .and. nCto > 1		
		   cSequ := StrZero(Val(cSequ)+1,3)
		Else
			cSequ  := "001"			
		Endif	
		RecLock("QA3",.F.)
		Replace QA3->QA3_SEQ With cSequ
		MsUnLock()
		dbSelectArea("QA3")
		nCto++
		cChvQA3 := QA3->QA3_CHAVE
		cChvEsp := QA3->QA3_ESPEC
		dbSkip()
	EndDo
EndIf

Return
