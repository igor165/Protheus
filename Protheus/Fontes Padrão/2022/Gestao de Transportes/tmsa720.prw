#INCLUDE "Protheus.ch"
#INCLUDE "TMSA720.ch" 

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA720  � Autor � Eduardo de Souza      � Data � 20/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Geracao Tabelas de Carreteiro                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA720()                            					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATMS                                                    ���
�������������������������������������������������������������������������Ĵ��
���                  ATUALIZACOES - VIDE SOURCE SAFE                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSA720()

Local cPerg     := "TMA720"

//��������������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                                 �
//����������������������������������������������������������������������
//��������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                               �
//� mv_par01	// Tab. Carret. Antiga                                 �
//� mv_par02	// Nova Tab. Carret.                                   �
//� mv_par03	// Inicio Vigencia                                     �
//� mv_par04	// Perc. Reajuste                                      �
//����������������������������������������������������������������������
If Pergunte(cPerg,.T.)

	DbSelectArea("DUS")
	DbSetOrder(1)
	
	If mv_par01 == mv_par02
		Help("", 1, "TMSA72001") // Nao pode copiar para a mesma tabela
		Return
	Else
		If MsSeek(xFilial("DUS")+mv_par02)
			Help("", 1, "TMSA72002") // Tabela destino ja existe
			Return
		EndIf
	EndIf
	
	If Empty(mv_par02)
		Help("", 1, "TMSA72004") //"Informe qual sera a Nova Tabela de Carreteiro"
		Return .F.
	EndIf
	
	Processa({|lEnd| Tms720Proc(@lEnd)},,STR0001,.T.) //"Selecionando Registros ... "

EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Tms720Proc� Autor � Eduardo de Souza      � Data � 20/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Seleciona os Registros da Tabela DUS, para processamento	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Tms720Proc()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA720  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function Tms720Proc(lEnd)

Local cNewTab    := mv_par02
Local dDatIniVig := mv_par03
Local dDatFimAtu := (dDatIniVig - 1)

DbSelectArea("DUS")
DbSetOrder(1)
If MsSeek(xFilial("DUS")+mv_par01)

	IncProc()

	If !Empty(DUS->DUS_DATATE)
		If dDatIniVig <= DUS->DUS_DATATE
			Help("", 1, "TMSA72003") //-- Data de Inicio da nova tabela nao pode ser menor ou igual a tabela atual.
			Return .F.
		EndIf
	EndIf

	//-- Atualiza Vigencia da Tabela Atual
	RecLock("DUS",.F.)
	If DUS->DUS_DATDE >= dDatFimAtu
		DUS->DUS_DATDE := dDatFimAtu
	EndIf
	DUS->DUS_DATATE := dDatFimAtu
	MsUnLock()

	//-- Gera Nova Tabela de Carreteiro
	A720GerTab(cNewTab,dDatIniVig)

EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A720GerTab� Autor � Eduardo de Souza      � Data � 20/08/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gera nova Tabela de Carreteiro a partir de uma Tabela ja    ���
���          �existente podendo aplicar um reajuste                       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A720GerTab(ExpC1,ExpD1)                    				  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Nova Tabela                        				  ���
���          � ExpD1 - Inicio da Vigencia                 				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSA720   												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function A720GerTab(cNewTab,dDatIniVig)   

Local lTMS720GRV := ExistBlock("TMS720GRV")
Local aArea      := {}
Local aCposDUS   := {}
Local aCposDTS   := {}
Local aCposDTM   := {}
Local aCposDTT   := {}  
Local aCpos      := {}  
Local dFimVigAtu := CtoD("  /  /  ")
Local nFor       := 0 

//����������������������������������������������������Ŀ
//� Copia Tabela de Carreteiros              		   �
//������������������������������������������������������
//-- Campos alterados na Copia
Aadd( aCposDUS, { "DUS_TABCAR", cNewTab    } )
Aadd( aCposDUS, { "DUS_DATDE" , dDatIniVig } )
Aadd( aCposDUS, { "DUS_DATATE", dFimVigAtu } )

aArea := DUS->(GetArea())
DUS->(TmsCopyReg(aCposDUS)) //-- Copia Tabela de Carreteiro
RestArea( aArea )

//����������������������������������������������������Ŀ
//� Copia Tabela de Carreteiros por Rota     		   �
//������������������������������������������������������
DbSelectArea("DTS")
DbSetOrder(1)
If MsSeek(xFilial("DTS")+DUS->DUS_TABCAR)

	//-- Campos alterados na Copia da Tabela de Carreteiros por Rota
	Aadd( aCposDTS, { "DTS_TABCAR", cNewTab } )

	While DTS->(!Eof()) .And. DTS->DTS_FILIAL + DTS->DTS_TABCAR == xFilial("DTS") + DUS->DUS_TABCAR
	
		aArea := DTS->(GetArea())
		DTS->(TmsCopyReg(aCposDTS)) //-- Copia nova Tabela de Carreteiros por Rota.
		RestArea( aArea )

		//����������������������������������������������������Ŀ
		//� Copia Premio do Carreteiro						   �
		//������������������������������������������������������
		DbSelectArea("DTM")
		DbSetOrder(1)
		If MsSeek(xFilial("DTM")+DTS->DTS_TABCAR+DTS->DTS_ROTA)

			//-- Campos alterados na Copia
			Aadd( aCposDTM, { "DTM_TABCAR", cNewTab } )

			While DTM->(!Eof()) .And. DTM->DTM_FILIAL + DTM->DTM_TABCAR + DTM->DTM_ROTA == xFilial("DTM") + DTS->DTS_TABCAR + DTS->DTS_ROTA
				aArea := DTM->(GetArea())
				DTM->(TmsCopyReg(aCposDTM)) // Copia Premio do Carreteiro
				RestArea( aArea )
				DTM->(DbSKip())
			EndDo
		EndIf

		DTS->(DbSkip())
	EndDo
EndIf

//����������������������������������������������������Ŀ
//� Copia Itens da Tabela de Carreteiros por Rota      �
//� Reajustando seu Valor                              �
//������������������������������������������������������
DbSelectArea("DTT")
DbSetOrder(1)
If MsSeek(xFilial("DTT")+DUS->DUS_TABCAR)	
	While DTT->(!Eof()) .And. DTT->DTT_FILIAL + DTT->DTT_TABCAR == xFilial("DTT") + DUS->DUS_TABCAR
	
		// Calcula o Reajuste para a nova tabela
		If mv_par04 <> 0
			nValor := DTT->DTT_VALOR + ( DTT->DTT_VALOR * (mv_par04 / 100) )
		Else
			nValor := DTT->DTT_VALOR
		EndIf
	
		//-- Campos alterados na Copia do Item da Tabela de Carreteiros por Rota
		aCposDTT := {}
		Aadd( aCposDTT, { "DTT_TABCAR", cNewTab } )
		Aadd( aCposDTT, { "DTT_VALOR" , nValor  } )
                           
		If lTMS720GRV  				
			aCpos := ExecBlock('TMS720GRV',.F.,.F.)
			If Valtype(aCpos) = 'A'                         
				For nFor := 1 To Len(aCpos[2])
					 Aadd( aCposDTT,{aCpos[1,nFor],aCpos[2,nFor]} )   
				Next nFor																                        
			EndIf	
		EndIf         
		
		aArea := DTT->(GetArea())
		DTT->(TmsCopyReg(aCposDTT)) // Copia Itens da Tabela de Carreteiros por Rota 
		RestArea( aArea )

		DTT->(DbSKip())
	EndDo
EndIf

Return

