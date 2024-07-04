#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"

Static cMessage := 'AssetDepreciation' //Nome da Mensagem �nica

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA051   �Autor  �Wilson P. Godoi      � Data� 13/11/2013  ���
�������������������������������������������������������������������������͹��
���Descri��o �Regra da Msg de Calculo Mensal Integra��o PIMS X Protheus   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Fonte criado para portar a IntegDef de Calculo Mensal       ���
���          �Integra��o Protheus X PIMS                                  ���
���          �                                                            ���
���          �                                                            ��� 
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
//Funcao criara o processo de Mensagem Unica do Calculo Mensal de Deprecia��o
Function ATFA051()
	Local lRet          := .T. //Controle de Processamento
	Local nCount		:= 0
	Local dDataIni		:= FirstDay(dDataBase)
	Local dDataFim		:= 	LastDay(dDataBase)
	Local cDataIni 		:= Substr(DtoS(dDataIni),1,4) + '-' + Substr(DtoS(dDataIni),5,2) + '-' +  Substr(DtoS(dDataIni),7,2)
	Local cDataFim      := Substr(DtoS(dDataFim),1,4) + '-' + Substr(DtoS(dDataFim),5,2) + '-' +  Substr(DtoS(dDataFim),7,2)
	Local cAliasQry 	:= ""
	Local nMax			:= 100
	Local aDados		:= {}
	Local nY			:= 0
	Local aEntCtb       := CarrEntCtb() //array de verifica��o das entidades contabeis adicionais, com 5 posicoes

	// Select do Calculo Mensal de Deprecia��o com Ocorr�ncia = 06 e Tipo = 3
	DBSelectArea("SN4")
	SN4->(DbSetOrder(1))

	cAliasQry := GetNextAlias()
	cQry :=	" SELECT " + CRLF
	cQry +=		" SN4.N4_CBASE, SN4.N4_ITEM, SN4.N4_CONTA, SN4.N4_CCUSTO, SN4. N4_SUBCTA, SN4.N4_CLVL, SN4.N4_VLROC1 " + CRLF
	//Percorrendo Entidades Adicionais
	For nY := 01 To Len(aEntCtb)
		//Adicionando Campos
		If (aEntCtb[nY, 01])
			cQry += ", SN3." + aEntCtb[nY, 02] + ", SN3." + aEntCtb[nY, 03] + CRLF
		EndIf
	Next nY
	cQry +=	" FROM " + CRLF
	cQry +=		RetSQLName("SN4") + " SN4 " + CRLF
	cQry +=		" INNER JOIN " + RetSQLName("SN3") + " SN3 ON " + CRLF
	cQry +=		" SN3.N3_FILIAL			= '" + FWXFilial("SN3") + "' " + CRLF
	cQry +=		" AND SN3.N3_CBASE		= SN4.N4_CBASE " + CRLF
	cQry +=		" AND SN3.N3_ITEM		= SN4.N4_ITEM " + CRLF
	cQry +=		" AND SN3.N3_TIPO		= SN4.N4_TIPO " + CRLF
	cQry +=		" AND SN3.N3_TPSALDO	= SN4.N4_TPSALDO " + CRLF
	cQry +=		" AND SN3.N3_SEQ		= SN4.N4_SEQ " + CRLF
	cQry +=		" AND SN3.N3_SEQREAV	= SN4.N4_SEQREAV " + CRLF
	cQry +=		" AND SN3.N3_INTP		= '1' " + CRLF
	cQry +=		" AND SN3.D_E_L_E_T_	= ' ' " + CRLF
	cQry +=	" WHERE " + CRLF
	cQry +=		" SN4.N4_FILIAL			= '" + FWxFilial("SN4") + "' " + CRLF
	cQry +=		" AND SN4.N4_DATA		Between '" + DToS(dDataIni) + "' AND '" + DToS(dDataFim) + "' " + CRLF
	cQry +=		" AND SN4.N4_OCORR		= '06' " + CRLF
	cQry +=		" AND SN4.N4_TIPOCNT	= '3' " + CRLF
	cQry +=		" AND SN4.D_E_L_E_T_	= ' ' " + CRLF
	cQry +=	" GROUP BY SN4.N4_CBASE,SN4.N4_ITEM,SN4.N4_TIPO,SN4.N4_TPSALDO,SN4.N4_SEQ,SN4.N4_SEQREAV,SN4.N4_CONTA, SN4.N4_CCUSTO, SN4. N4_SUBCTA, SN4.N4_CLVL, SN4.N4_VLROC1 " + CRLF
	//Percorrendo Entidades Adicionais
	For nY := 01 To Len(aEntCtb)
		//Adicionando Campos
		If (aEntCtb[nY, 01])
			cQry += ", SN3." + aEntCtb[nY, 02] + ", SN3." + aEntCtb[nY, 03] + CRLF
		EndIf
	Next nY
	cQry +=	" ORDER BY SN4.N4_CBASE,SN4.N4_ITEM,SN4.N4_TIPO,SN4.N4_TPSALDO,SN4.N4_SEQ,SN4.N4_SEQREAV " + CRLF
	//Gerando a Tempor�ria a partir da Consulta SQL
	cQry := ChangeQuery( cQry )
	PlsQuery(cQry, cAliasQry)
	(cAliasQry)->( dbGoTop() )
	//Percorrendo Tempor�ria
	While (cAliasQry)->( !EOF() )
		//Adicionando no Array
		AAdd(aDados, {(cAliasQry)->N4_CBASE, (cAliasQry)->N4_ITEM, (cAliasQry)->N4_CONTA, (cAliasQry)->N4_CCUSTO, (cAliasQry)-> N4_SUBCTA, (cAliasQry)->N4_CLVL, (cAliasQry)->N4_VLROC1})
		/**Entidades Cont�beis Adicionais**/
		For nY := 01 To Len(aEntCtb)
			If (aEntCtb[nY, 01])
				//Verifica se h� conte�do
				If !(Empty((cAliasQry)->&(aEntCtb[nY, 02])))
					AAdd(aDados[Len(aDados)], (cAliasQry)->&(aEntCtb[nY, 02]))
				ElseIf !(Empty((cAliasQry)->&(aEntCtb[nY, 03])))
					AAdd(aDados[Len(aDados)], (cAliasQry)->&(aEntCtb[nY, 03]))
				Else
					AAdd(aDados[Len(aDados)], "")
				EndIf
			Else
				AAdd(aDados[Len(aDados)], "")
			EndIf
		Next nY
		//Incrementando contador
		nCount++
		//Pulando registro
		(cAliasQry)->( DbSkip() )

		//Chamada de Adapter ao atingir limite m�ximo ou chegar ao fim do arquivo
		If nCount >= nMax .OR. ( (cAliasQry)->(EOF()) )
			nCount 	:= 0

			//Setando o Array de Controle
			ATFI051Dad(aDados)
			//Chamando  Adapter
			//FwIntegDef( 'ATFA051',,,cXMLRET )
			FwIntegDef( 'ATFA051', , , , 'ATFA051' )
			//Zerando Arrray
			aDados := {}
		Endif
	EndDo

Return lRet

/**
	Carrega Array com informa��es dos Campos de Entidades Cont�beis
**/
Static Function CarrEntCtb()
	Local aRetEnt := {} //Array de Retorno
	Local nQtdEnt := 05 //Quantidade de Entidades Adicionais
	Local nE      := 0 //Controle de FOR
	Local cCpoDeb := '' //Campo Entidade D�bito
	Local cCpoCrd := '' //Campo Entidade Cr�dito

	//Verificando se campos existem
	DBSelectArea('SN3')
	For nE := 01 To nQtdEnt
		//Compondo Campos
		cCpoDeb := 'N3_EC' + StrZero(nE + 04, 02) + 'DB' //D�bito
		cCpoCrd := 'N3_EC' + StrZero(nE + 04, 02) + 'CR' //Cr�dito
		If (FieldPos(cCpoDeb) > 0 .AND. FieldPos(cCpoCrd) > 0)
			AAdd(aRetEnt, {.T., cCpoDeb, cCpoCrd})
		Else
			AAdd(aRetEnt, {.F., "", ""})
		EndIf
	Next nE

Return aRetEnt

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IntegDef  �Autor  �Wilson P. Godoi     � Data � 13/11/2013  ���
�������������������������������������������������������������������������͹��
���Descri��o � Calculo Mensal Deprec- PIMS X PROTHEUS    		          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)   ���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Fun��o para a intera��o com EAI                             ���
���          �recebimento da mensagem de financiamento da integra��o      ���
���          �Protheus X PIMS                                             ���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION IntegDef( cXml, cTypeTrans, cTypeMsg, cVersion, cTransac )
	Local aRet := {}
	aRet:= ATFI051( cXml, cTypeTrans, cTypeMsg, cVersion, cTransac )
Return aRet