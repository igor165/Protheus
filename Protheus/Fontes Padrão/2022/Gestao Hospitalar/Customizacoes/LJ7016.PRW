#INCLUDE "RWMAKE.CH"                       

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � HSHFIN05 � Autor � Keller             � Data �  24/09/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao que chama o relatorio "Conta Descritiva"            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico para clientes de Gestao Hospitalar              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function HSHFIN05
Local aArea		:= GetArea()
Local aGuias	:= {}

GCZ->( DbSetOrder( 14 ) )

If GCZ->( DbSeek( xFilial( "GCZ" ) + SL1->L1_NUM ) )

	While GCZ->GCZ_NUMORC == SL1->L1_NUM
		aAdd(aGuias, {GCZ->GCZ_NRSEQG, GCZ->GCZ_REGATE})
		GCZ->( DbSkip() )
		Loop
	Enddo

	HSPAHRC6("LOJA701", aGuias)  // Rotina do GH 
Else
	MsgStop("Nao encontrado lancamentos para este Orcamento - Verifique com pessoal de Faturamento !!!")
Endif

RestArea(aArea)

Return