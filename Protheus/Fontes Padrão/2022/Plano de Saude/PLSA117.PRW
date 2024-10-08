#Include "Protheus.Ch"
#Include "PLSA117.Ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSA117   �Autor  �Diogo Ximenes       � Data � 10/02/2010  ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza o estorno do status de parcelamento do usuario.	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PLSA117()	
Private cPerg	:= "PLSA117"


If Pergunte(cPerg,.T.)
	//������������������������������������������Ŀ
	//�Chama a rotina para estorno d status...   �
	//��������������������������������������������
	MsAguarde({|| EstUsr() }, STR0001, "", .T.) //"Mudar Regra"
Else
	Return(.T.)
Endif

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EstUsr    �Autor  �Diogo Ximenes       � Data � 10/12/2010  ���
�������������������������������������������������������������������������͹��
���Descri��o � Realiza a mudaca da regra do usuario.					  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function EstUsr()
Local cChaveBA1	:= "BA1->BA1_CODINT+BA1->BA1_CODEMP"
Local cChave 	:= MV_PAR01+MV_PAR02
Local nVal 		:= 0
Local nTotal	:= 0
Local lChaveBA1	:= .T.

//����������������������������������������Ŀ
//�Verifico qual a composi��o das chaves...�
//������������������������������������������
If !Empty(MV_PAR03)
	cChaveBA1	+= "+BA1->BA1_CONEMP"
	cChave		+= MV_PAR03
Else
	lChaveBA1	:= .F.
EndIf

If !Empty(MV_PAR04)
	cChaveBA1	+= "+BA1->BA1_VERCON"
	cChave		+= MV_PAR04
Else
	lChaveBA1	:= .F.
EndIf

If !Empty(MV_PAR05) .And. lChaveBA1
	cChaveBA1	+= "+BA1->BA1_SUBCON"
	cChave		+= MV_PAR05
Else
	lChaveBA1	:= .F.
EndIf

If !Empty(MV_PAR06)
	cChaveBA1	+= "+BA1->BA1_VERSUB"
	cChave		+= MV_PAR06
Else
	lChaveBA1	:= .F.
EndIf

If !Empty(MV_PAR07) .And. lChaveBA1
	cChaveBA1	+= "+BA1->BA1_MATRIC"
	cChave		+= MV_PAR07
Else
	lChaveBA1	:= .F.
EndIf

If !Empty(MV_PAR08) .And. lChaveBA1
	cChaveBA1	+= "+BA1->BA1_TIPREG"
	cChave		+= MV_PAR08
Else
	lChaveBA1	:= .F.
EndIf

DBSelectArea("BA1")
BA1->(DbSetOrder(13)) //BA1_FILIAL, BA1_CODINT, BA1_CODEMP, BA1_CONEMP, BA1_VERCON, BA1_SUBCON, BA1_VERSUB, BA1_MATRIC, BA1_TIPREG
If BA1->(MsSeek(xFilial("BA1")+cChave))
	While !BA1->(Eof()) .And. &cChaveBA1 == cChave
		//�����������������������������������������������������������������������������������������������Ŀ
		//�Somente verifico o usuario se ele estiver com o tipo de regra diferente do subcontrato...	  �
		//�������������������������������������������������������������������������������������������������
		If BA1->BA1_TREGRA != "0"
			//����������������������������Ŀ
			//�Limpo o contador de saldo...�
			//������������������������������
			nVal := 0
			
			//��������������������Ŀ
			//�Verifico o saldo... �
			//����������������������
			DBSelectArea("BK2")
			BK2->(DbSetOrder(1))// BK2_FILIAL, BK2_CODINT, BK2_CODEMP, BK2_MATRIC, BK2_TIPREG, BK2_DIGITO, BK2_TIPLAN, BK2_CODLAN, BK2_ANO, BK2_MES
			If 	BK2->(MsSeek(xFilial("BK2")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)))
				While ! BK2->(Eof()) .And. BK2->(BK2_FILIAL+BK2_CODINT+BK2_CODEMP+BK2_MATRIC+BK2_TIPREG) ==;
				xFilial("BK2")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)

					If Empty(BK2->BK2_PLNUCO)
						nVal += BK2->BK2_SALDO
					EndIf
					BK2->(DbSkip())
				Enddo
			EndIf
			If nVal == 0
				BA1->(RecLock("BA1",.F.))
				BA1->BA1_TREGRA := "0"
				BA1->(MsUnLock())
				nTotal ++
			EndIf
		EndIf
		BA1->(DbSkip())
	EndDo
EndIf

//����������������������������������Ŀ
//�Exibe a mensagem para o usuario...�
//������������������������������������
If nTotal <= 0
	MsgAlert(STR0002) //"Nenhum Usu�rio foi Alterado!"
ElseIf nTotal == 1
	MsgAlert(STR0003) //"Foi Alterado um Usu�rio!"
ElseIf nTotal > 1
	MsgAlert(STR0004+AllTrim(str(nTotal))+STR0005 )//"Foram alterados " ###" Usu�rios!"
EndIf

Return(.T.)