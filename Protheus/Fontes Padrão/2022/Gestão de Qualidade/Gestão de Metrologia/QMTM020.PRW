#INCLUDE "QMTM020.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QMTM020	� Autor � Wanderley Goncalves Jr� Data � 24/06/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Revalidacao de Datas de vencimento de medicoes			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTM020

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas 						     �
//����������������������������������������������������������������
If Pergunte("QMM020",.t.)
	Processa( { || QMTM020Fx() } )
EndIf

Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QMTM020Fx� Autor � Wanderley Goncalves Jr� Data � 24/06/98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Revalidacao de Datas de vencimento de medicoes - Funcao	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QMTM020Fx()

//��������������������������������������������������������������Ŀ
//� Define Variaveis 										     �
//����������������������������������������������������������������
Local dData
Local dDataFim
Local lTemMed := .f.
Local cInstr
Local nTotal

DbSelectArea("QM2")
DbSetOrder(1)
QM6->(DbSetOrder(2))
                   
nTotal := Reccount()
if empty(mv_par01)
	dbSeek(cFilial)
Else
	//��������������������������������������������������������������Ŀ
	//� Nao reavalia para instrumentos que pertencem a uma Malha     �
	//����������������������������������������������������������������
	If DbSeek(xFilial("QM2")+mv_par01)
		If QM2->QM2_STATUS = "0"
		 	Return(Nil)
		EndIf
	EndIf
EndIf

ProcRegua(nTotal)

Do While !QM2->(Eof()) .and. xFilial("QM2") == QM2->QM2_FILIAL
    
	lTemMed := .F.	
	IncProc(STR0001) // "Processando..."
	
	//��������������������������������������������������������������Ŀ
	//� Nao reavalia para instrumentos que pertencem a uma Malha     �
	//����������������������������������������������������������������
	If ( QM2->QM2_STATUS = "0" )	
		QM2->(DbSkip())
		Loop		
	EndIf
	
	QM6->(DbSeek(xFilial("QM6")+QM2->QM2_INSTR+QM2->QM2_REVINS))
	
	If !QM6->(Eof())
		dData := QM6->QM6_DATA
		lTemMed := .t.
	EndIf
	
	If lTemMed
		dDatafim := QM010ValAf(dData, QM2->QM2_FREQAF)
	Else
		dDatafim := QM010ValAf(QM2->QM2_VALDAF, 0)
	EndIf
	
	If QM2->QM2_VALDAF <> dDataFim
		dbSelectArea("QMD")
		If dbSeek(xFilial("QMD")+QM2->QM2_INSTR+QM2->QM2_REVINS+DTOS(QM2->QM2_VALDAF)+DTOS(dDataBase)+DTOS(dDataFim))
			MSGALERT(STR0002)
		Else
			RecLock("QMD",.t.)
			Replace QMD->QMD_FILIAL with xFilial("QMD")
			Replace QMD->QMD_INSTR	with QM2->QM2_INSTR
			Replace QMD->QMD_REVINS with QM2->QM2_REVINS
			Replace QMD->QMD_VALDAF with QM2->QM2_VALDAF
			Replace QMD->QMD_VALREP with dDataFim
			Replace QMD->QMD_DATA	with dDataBase
			Replace QMD->QMD_JUSTIF with mv_par02
			MsUnLock()
		
			RecLock("QM2",.f.)
			QM2->QM2_VALDAF := dDataFim
			//����������������������������������������������������������������������Ŀ
			//�Altera tambem a frequencia anterior, para evitar erros no Schumacher  �
			//������������������������������������������������������������������������
			QM2->QM2_VALDAN := dDataFim
			MsUnLock()

			//������������������������������������������������������������������������Ŀ
			//� Verifica se e instrumento malha e se for, altera a validade dos filhos �
			//��������������������������������������������������������������������������
			QMTM020IM(QM2->QM2_INSTR,dDataFim)
		
			If lTemMed
				RecLock("QM6",.f.)
				QM6->QM6_VALDAF := dDataFim
				MsUnLock()
			EndIf
		Endif
	EndIf
	
	If Empty(mv_par01)
		//��������������������������������������������������������������Ŀ
		//� Procura a �ltima revisao do pr�ximo instrumento.				  �
		//����������������������������������������������������������������
		cInstr := QM2->QM2_INSTR
		dbSkip()
		While QM2->QM2_INSTR == cInstr .And. ! QM2->(Eof()) .and. QM2->QM2_FILIAL == xFilial("QM2")
			QM2->(dbSkip())
		EndDo
	Else
		Exit
	EndIf
EndDo

Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QMTM020IM� Autora� Iuri Seto             � Data � 19/05/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se e instrumento malha e atualiza a validade dos  ���
���          � filhos.                                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QMTM020IM(ExpC1,ExpD1)                     				  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo do Instrumento     						  ���
���			 � ExpD1 = Data de Validade  								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QMTM020  																  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTM020IM(cInstr,dDataFim)
Local cOldAlias := Select()
Local nRec		:= Recno()

DbSelectArea("QM2")    
DBSetOrder(7)
If QM2->(DbSeek(xFilial("QM2")+"0"+cInstr))
	Do While xFilial("QM2")+"0"+cInstr == QM2->QM2_FILIAL+"0"+QM2->QM2_LOCAL .and. !QM2->(Eof())
		RecLock("QM2",.f.)
		QM2->QM2_VALDAF := dDataFim
		//����������������������������������������������������������������������Ŀ
		//�Altera tambem a frequencia anterior, para evitar erros no Schumacher  �
		//������������������������������������������������������������������������
		QM2->QM2_VALDAN := dDataFim
		QM2->(DbSkip())
		MsUnLock()
	EndDo
EndIf

DbSelectArea(cOldAlias)
DbGoto(nRec)

Return(Nil)
