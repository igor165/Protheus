/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 � M100PFI	� Autor � RENATO NAGIB         � Data � 27.08.2010 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � PERCEPCION FIJA SOBRE IRAE  (URUGUAY)                       ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Generico 												   ���
��������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                    ���
��������������������������������������������������������������������������Ĵ��
���              �        �      �                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
FUNCTION M100PFR(cCalculo,nItem,aInfo)

	Local xRet
	Local nBase:=0,nAliq:=0,nAliqI:=0
	local cImpIncid:=""
	
	dbSelectArea('SFC')
	SFC->(DbSetOrder(2))
	If SFC->(DbSeek(xFilial("SFC")+Avkey(MaFisRet(nItem,"IT_TES"),'FC_TES')+AvKey(aInfo[1],'FC_IMPOSTO')))
		cImpIncid:=Alltrim(SFC->FC_INCIMP)
	Endif
	
	dbSelectArea('SFB')
	SFB->(DbSetOrder(1))
	If SFB->(DbSeek(xFilial("SFB")+Alltrim(cImpIncid)))
		nAliqI+=SFB->FB_ALIQ
	Endif
	dbSelectArea('SFF')
	SFF->(dbSetOrder(9))
	If SFF->(dbSeek(xFilial('SFF')+Alltrim(cImpIncid)))
		nAliqI:=SFF->FF_ALIQ			
	EndIf


	If SFB->(DbSeek(xfilial("SFB")+Alltrim(aInfo[1])))
		nAliq:=SFB->FB_ALIQ
	endif
	If SFF->(dbSeek(xFilial('SFF')+Alltrim(aInfo[1])))
		nAliq:=SFF->FF_ALIQ			
	EndIf

	Do Case
		Case cCalculo=="B"
			nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")- MaFisRet(nItem,"IT_DESCONTO")
			xRet:=nBase
		Case cCalculo=="A"
			xRet:=nALiq
		Case cCalculo=="V"
			nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[2])
			nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])
			xRet:=(nAliq * nBase)/100
	EndCase
Return(xRet)