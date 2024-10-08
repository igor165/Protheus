#INCLUDE "OFIOA190.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIOA190 � Autor � Fernando Joly         � Data � 09/10/95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Funcoes                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � OFIOA190()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico ( windows )                                       ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Aldo        �23/06/96�XXXXXX�Alteracao da cor na exclusao.             ���
���Mauro	    	�20/05/98�------� Criado Str00n nas Strings (.CH)          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIOA190

Private cCadastro := OemToAnsi(STR0001) // //'Cadastro de Fun��es'
Private aMemos  := {{"RJ_DESCREQ","RJ_MEMOREQ"}}

axCadastro("SRJ", cCadastro,"OFIOA190EX()")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �OFIOA190EX�Autor  �Eduardo Motta       � Data �  19/10/00   ���
�������������������������������������������������������������������������͹��
���Desc.     � Excluir                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Oficina                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIOA190EX()
Local aArquivos := {}
aadd(aArquivos,{"VAI","VAI_FUNCAO", SRJ->RJ_FUNCAO,   })
aadd(aArquivos,{"QD8","QD8_CARGO ", SRJ->RJ_FUNCAO,   })
aadd(aArquivos,{"QDD","QDD_CARGOA", SRJ->RJ_FUNCAO,   })
aadd(aArquivos,{"QDM","QDM_CARGO ", SRJ->RJ_FUNCAO,   })
aadd(aArquivos,{"RB2","RB2_FUNCAO", SRJ->RJ_FUNCAO,   })
aadd(aArquivos,{"RB5","RB5_FUNCAO", SRJ->RJ_FUNCAO,   })
aadd(aArquivos,{"SQS","QS_FUNCAO ", SRJ->RJ_FUNCAO,   })
aadd(aArquivos,{"SR2","R2_CBO    ", SRJ->RJ_FUNCAO,   })
aadd(aArquivos,{"SR7","R7_FUNCAO ", SRJ->RJ_FUNCAO,   })
aadd(aArquivos,{"SRA",7           , SRJ->RJ_FUNCAO,   })
aadd(aArquivos,{"SRA","RA_CBO    ", SRJ->RJ_FUNCAO,   })
aadd(aArquivos,{"TM5","TM5_CBO   ", SRJ->RJ_FUNCAO,   })
aadd(aArquivos,{"TMV","TMV_CODFUN", SRJ->RJ_FUNCAO,   })
aadd(aArquivos,{"TN0","TN0_CODFUN", SRJ->RJ_FUNCAO,   })
aadd(aArquivos,{"TNB",2           , SRJ->RJ_FUNCAO,   })
aadd(aArquivos,{"TNC","TNC_CODFUN", SRJ->RJ_FUNCAO,   })
aadd(aArquivos,{"TNF",4           , SRJ->RJ_FUNCAO,   })
Return FG_DELETA( aArquivos )

Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)