/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � VEIVC020 � Autor �  Manoel               � Data � 19/01/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta Vendas de Veiculos no Periodo                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico  - (Veiculos)                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

FUNCTION VEIVC020

if !Pergunte("VDAPER",.t.)
   Return
endif

CallCrys("VDAPER",Dtoc(mv_par01,"dd/mm/yy")+";"+Dtoc(mv_par02,"dd/mm/yy")+";"+str(mv_par03,1)+";"+Str(mv_par04,1))

//CallCrys("VDAPER")
Return



