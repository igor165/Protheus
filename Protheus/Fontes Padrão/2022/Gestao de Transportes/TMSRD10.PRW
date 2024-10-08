#INCLUDE "TMSRD10.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSRD10  � Autor �Vitor Raspa            � Data � 11.Set.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao de Documentos Exigidos X Fornecedores            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSRD10                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Gestao de Transporte                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMSRD10()

Local titulo   		:= STR0001 //-- "Documentos Exigidos X Fornecedores"
Local cString  		:= 'DD1'
Local wnrel    		:= 'TMSRD10'
Local cDesc1   		:= STR0002 //-- "Este programa ira listar os Documentos Exigidos X Fornecedores"
Local cDesc2   		:= ''
Local cDesc3   		:= ''
Local tamanho  		:= 'M'
Local nLimite  		:= 132
Local aCposProtg	:= {}
Local aCpoAccess	:= {'A2_NOME'}

Private NomeProg := 'TMSRD10'
Private aReturn  := {STR0003,1,STR0004,2, 2, 1, '',1 } //"Zebrado"###"Administracao"
Private cPerg    := 'TMRD10'
Private nLastKey := 0
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas                                        �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� MV_PAR01        	// Tipo de Pessoa                        �
//� MV_PAR02        	// Periodo Inicial    	                 �
//� MV_PAR03        	// Periodo Final                         �
//� MV_PAR04        	// Do Fornecedor      	                 �
//� MV_PAR05        	// Da Loja            	                 �
//� MV_PAR06        	// Ate o Fornecedor   	                 �
//� MV_PAR07        	// Ate a Loja         	                 �
//� MV_PAR08        	// Situacao dos Documentos               �
//����������������������������������������������������������������

If ExistFunc('TMLGPDCpPr')
	aCposProtg := TMLGPDCpPr(aCpoAccess, "SA2")
	If ExistFunc('FWPDCanUse') .And. FWPDCanUse() .And. !Empty(aCposProtg)
		If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, aCposProtg )) < Len(aCposProtg)
			Help(" ",1,STR0006,,,,) //"LGPD - Acesso Restrito: Este usu�rio n�o possui permiss�o de acesso aos dados dessa rotina. Para mais informa��es contate o Administrador do sistema !!"
			Return
		EndIf	
	EndIf
EndIf

pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,'',,Tamanho)

If nLastKey = 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| TMSRD10Imp(@lEnd,wnRel,titulo,tamanho,nLimite)},titulo)

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSRD10Imp� Autor �Vitor Raspa            � Data � 11.Set.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relat�rio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSRD10			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function TMSRD10Imp(lEnd,wnRel,cTitulo,nTamanho,nLimite)
Local nLin      := 80
Local cDesc1    := ''
Local cDesc2    := ''
Local aSx3Box   := {}
Local cPessoa   := IF(MV_PAR01 == 1, 'J', 'F')
Local cStatus   := IF(MV_PAR08 == 1, '1', '2/4')
Private M_Pag   := 1	

DD1->(DbSetOrder(1)) //--DD1_FILIAL+DD1_CODFOR+DD1_LOJFOR
DD1->(MsSeek(xFilial('DD1') + MV_PAR04 + MV_PAR05, .T.))
While !DD1->(EoF()) .And. DD1->(DD1_CODFOR+DD1_LOJFOR) <= MV_PAR06 + MV_PAR07

	If Interrupcao(@lEnd)
		Exit
	Endif
	
	SA2->(DbsetOrder(1))
	If SA2->(MsSeek(xFilial('SA2') + DD1->(DD1_CODFOR+DD1_LOJFOR)))
		If SA2->A2_TIPO == cPessoa .Or. MV_PAR01 == 3
			//-- Impressao do Cabecalho
			If nLin > 60
				nLin := Cabec( cTitulo, cDesc1, cDesc2, NomeProg, nTamanho ) + 1
			EndIf

			VerLin(@nLin,1)
			@ nLin, 000 Psay __PrtThinLine()
			VerLin(@nLin,1)
	
			@ nLin, 000 PSay RetTitle('DD1_CODFOR')
			@ nLin, 060 PSay RetTitle('DD1_PESSOA')
			VerLin(@nLin,1)	
		
			@ nLin,000 PSay DD1->(DD1_CODFOR + '/' + DD1_LOJFOR)	
			@ nLin,015 PSay ' - ' + SA2->A2_NOME
			aSx3Box := RetSx3Box( Posicione("SX3", 2, "A2_TIPO", "X3CBox()" ),,, 1 )	
			@ nLin,060 PSay AllTrim( aSx3Box[Ascan( aSx3Box, { |aBox| aBox[2] = SA2->A2_TIPO } )][3] )
	
			VerLin(@nLin,1)
			@ nLin, 000 PSay __PrtThinLine()
			VerLin(@nLin,1)
		
			@ nLin, 000 PSay RetTitle('DD3_CODDOC') + Space(02) + RetTitle('DD3_DESDOC') + Space(23) + RetTitle('DD3_PRXAPR')
		
			VerLin(@nLin,1)
			@ nLin, 000 PSay __PrtThinLine()
			VerLin(@nLin,1)
		
			DD3->(DbSetOrder(1)) //--DD3_FILIAL+DD3_CODFOR+DD3_LOJFOR+DD3_ITEM
			If !DD3->(MsSeek(xFilial('DD3') + DD1->(DD1_CODFOR + DD1_LOJFOR)))
				@ nLin, 000 PSay STR0005 //-- "Nao existem documentos para este fornecedor conforme definicao dos Parametros"
				VerLin(@nLin,1)
			Else
				While !DD3->(EoF()) .And. DD3->(DD3_FILIAL+DD3_CODFOR+DD3_LOJFOR) == xFilial('DD3') + DD1->(DD1_CODFOR+DD1_LOJFOR)
					If 	DD3->DD3_PRXAPR >= MV_PAR02 .And. DD3->DD3_PRXAPR <= MV_PAR03 .And.;
						(DD1->DD1_STATUS $ cStatus .Or. MV_PAR08 == 3)
											
						@ nLin, 000 PSay DD3->DD3_CODDOC
						@ nLin, 011 PSay Posicione('DD0',1,xFilial('DD0')+DD3->DD3_CODDOC,'DD0_DESDOC')
						@ nLin, 047 PSay DD3->DD3_PRXAPR
						VerLin(@nLin,1)
						
					EndIf
				
					DD3->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf
	DD1->(DbSkip())
EndDo

//��������������������������������������������������������������Ŀ
//� Se em disco, desvia para Spool                               �
//����������������������������������������������������������������
If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �VerLin    � Autor �Patricia A. Salomao    � Data �27.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Soma Linha                                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � VerLin(ExpN1,ExpN2)                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametro � ExpN1 - No. da Linha atual                                 ���
���          � ExpN2 - No. de Linhas que devera ser somado                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSRD10			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function VerLin(Li,nSoma)
Li+=nSoma
If Li > 70
	Li:=1
EndIf
Return
