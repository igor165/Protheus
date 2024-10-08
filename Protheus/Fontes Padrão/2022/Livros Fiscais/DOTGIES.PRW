#INCLUDE "DotGiES.ch"
#INCLUDE "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DOTGIES   �Autor  �Mary C. Hergert     � Data � 26/01/2005  ���
�������������������������������������������������������������������������͹��
���Desc.     �Gera as informacoes necessarias a geracao do meio magnetico ���
���          �DOT-GI/ICMS - Espirito Santo                                ���
�������������������������������������������������������������������������͹��
���Uso       �SigaFis                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function DOTGIES(dDtInicial,dDtFinal)

	Local aTRBs  := DOTGIESTemp()
	Local aMunic := ListaMunES()

	If DotGiEsWiz()
		DOTGIESProc(dDtInicial,dDtFinal,aTRBs, aMunic)
	Else
		lAbtMT950 := .T.
	Endif

Return aTRBs

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �DOTGIESWiz  �Autor  �Mary C. Hergert     � Data � 26/01/2005  ���
���������������������������������������������������������������������������͹��
���Desc.     �Monta a wizard com as perguntas necessarias                   ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       �DOTGIES                                                       ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function DOTGIESWiz()

	Local aTxtPre		:= {}
	Local aPaineis		:= {}
	/*{"1 - Normal, no prazo","2 - Normal, fora do prazo","3 - Substituicao","4 - Baixa","5 - Tranferencia Municipio"}*/
	Local aApresenta	:= {STR0001,STR0002,STR0003,STR0004,STR0005}
	Local aYesNo		:= {STR0007,STR0006}
	Local cTitObj1		:= ""
	Local cMask			:= Replicate("X",245)
	Local nPos			:= 0
	Local lRet			:= 0

	/*Monta wizard com as perguntas necessarias*/
	aAdd(aTxtPre,STR0008) /*"DOT-GI/ICMS"*/
	aAdd(aTxtPre,STR0009) /*"Aten��o"*/
	aAdd(aTxtPre,STR0010) /*"Preencha corretamente as informa��es solicitadas*/

	/*
	Esta rotina ira gerar as informacoes referentes a DOT-GI/ICMS
	DOT: Declaracao de Operacoes Tributaveis
	Guia de Informacao das Operacoes e Prestacoes Interestaduais - Espirito Santo*/
	aAdd(aTxtPre,STR0011+chr(10)+chr(13)+STR0012+chr(10)+chr(13)+STR0013)

	/*Painel 1 - Informacoes Gerais*/

	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0014) /*"Assistente de parametriza��o"*/ 
	aAdd(aPaineis[nPos],{})
	aAdd(aPaineis[nPos],{})

	/*"Forma de Apresentacao: "*/
	cTitObj1 := STR0015
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{3,,,3,,aApresenta,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	/*"Processar valores em estoque? "*/
	cTitObj1 := STR0016
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{3,,,1,,aYesNo,,3})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	/*""*/
	cTitObj1 := STR0040 //"Realiza Opera��es com Gera��o e Distribui��o"
	cTitObj2 := STR0041 //"de energia el�trica, Presta��o de Servi�os de "
	cTitObj3 := STR0042 //"Transporte,Servi�os de Comunica��o, "
	cTitObj4 := STR0043 //"Extra��o de petr�leo ou Servi�o de tratamento e "
	cTitObj5 := STR0044 //"distribui��o de �gua canalizada?"
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{3,,,1,,aYesNo,,3})
	aAdd(aPaineis[nPos][3],{1,cTitObj2,,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj3,,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj4,,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{1,cTitObj5,,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	/*Painel 2 - CFOPs*/
	aAdd(aPaineis,{})
	nPos :=	Len(aPaineis)
	aAdd(aPaineis[nPos],STR0017) /*"Assistente de parametriza��o"*/
	aAdd(aPaineis[nPos],STR0018) /*"Configura��o dos CFOPs: "*/
	aAdd(aPaineis[nPos],{})

	/*"Energia El�trica/Gera��o:"*/
	cTitObj1 := STR0019
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	/*"Energia El�trica/Distribui��o:"*/
	cTitObj1 := STR0020
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	/*"Servi�os de Transporte:"*/
	cTitObj1 := STR0021
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	/*"Servi�os de Comunica��o:"*/
	cTitObj1 := STR0022
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	/*"Extra��o de Petr�leo:"*/
	cTitObj1 := STR0023
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	/*"�gua Canalizada:"*/
	cTitObj1 := STR0024
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	/*"Outras Atividades*/
	cTitObj1 := STR0025
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	/*"Outras Atividades Transporte:"*/
	cTitObj1 := STR0026
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	/*"Informa��es Complementares:"*/
	cTitObj1 := STR0027
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	cTitObj1 := STR0047 //"Nao processar nas entradas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	cTitObj1 := STR0048 //"Nao processar nas saidas: "
	aAdd(aPaineis[nPos][3],{1,cTitObj1,,,,,,})
	aAdd(aPaineis[nPos][3],{2,,cMask,1,,,,245})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})
	aAdd(aPaineis[nPos][3],{0,"",,,,,,})

	lRet := xMagWizard(aTxtPre,aPaineis,"DOTGIES")	
Return(lRet)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �DOTGIESProc �Autor  �Mary C. Hergert     � Data � 26/01/2005  ���
���������������������������������������������������������������������������͹��
���Desc.     �Processa os movimentos                                        ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       �DOTGIES                                                       ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function DOTGIESProc(dDtInicial,dDtFinal,aTRBs,aMunic)

Local aWizard		:= {}
Local lRet			:= !xMagLeWiz("DOTGIES",@aWizard,.T.)
Local cMunA1		:= GetNewPar("MV_DOTMNA1","")
Local cMunA2		:= GetNewPar("MV_DOTMNA2","")
Local cMvEstado		:= GetNewPar("MV_ESTADO","")
Local cMunPar		:= GetNewPar("MV_DOTMNEM","")
Local cMunEmp		:= Alltrim(SM0->M0_CODMUN)
Local cMunic		:= ""
Local cMensagem		:= ""
Local cTitulo		:= ""
Local cHelp			:= ""
Local cCodDet		:= ""
Local nValEnegGr	:= 0
Local nValEnegDs	:= 0
Local nValServTr	:= 0
Local nValServCo	:= 0
Local nValExPet		:= 0
Local nValAgua		:= 0
Local nValOut		:= 0
Local nValPdPr		:= 0
Local nValPFNC		:= 0
Local cAliasSF3		:= "SF3"
Local cAliasSB9		:= "SB9"
Local lEstoque		:= Iif(SubStr(Alltrim(aWizard[01][02]),1,1) == "1",.T.,.F.)
Local lGera			:= Iif(SubStr(Alltrim(aWizard[01][03]),1,1) == "1",.T.,.F.)
Local cApresenta	:= Alltrim(aWizard[01][01])
Local nMunA1		:= Iif(!Empty(cMunA1),SA1->(FieldPos((&cMunA1))),0)
Local nMunA2		:= Iif(!Empty(cMunA2),SA2->(FieldPos((&cMunA2))),0)
Local cEnergGer		:= Alltrim(aWizard[02][01]) /*Energia El�trica/Gera��o*/
Local cEnergDis		:= Alltrim(aWizard[02][02]) /*Energia El�trica/Distribui��o*/
Local cSevTransp	:= Alltrim(aWizard[02][03]) /*Servi�os de Transporte*/
Local cSevComuni	:= Alltrim(aWizard[02][04]) /*Servi�os de Comunica��o*/
Local cExtPetr		:= Alltrim(aWizard[02][05]) /*Extra��o de Petr�leo*/
Local cAguaCan		:= Alltrim(aWizard[02][06]) /*�gua Canalizada*/
Local cOutAtiv		:= Alltrim(aWizard[02][07]) /*Outras Atividades*/
Local cOutSerTrp	:= Alltrim(aWizard[02][08]) /*Outras Atividades Transporte*/
Local cInfCompl		:= Alltrim(aWizard[02][09]) /*Informa��es Complementares*/
Local cEntradas		:= Alltrim(aWizard[02][10]) /*Nao processar nas entradas*/
Local cSaidas		:= Alltrim(aWizard[02][11]) /*Nao processar nas saidas*/
Local nY			:= 0
Local nX			:= 0
Local aTipos		:= {{"1","Energia El�trica",.F.},{"2", "Transporte",.F.},{"3", "Comunica��o",.F.},{"4", "Produ��o Rural Pr�pria",.F.},{"5", "�gua",.F.},{"6", "Extra��o Petr�leo",.F.},{"7", "Pessoa F�sica",.F.},{"8", "Outros",.F.}}

DEFAULT	aMunic		:= {}

If lRet
	Return
Endif

If Empty(cMunA1) .Or. nMunA1 == 0
	cTitulo		:= STR0028 /*"Par�metro n�o existe"*/
	cMensagem	:= STR0029 /*"O par�metro MV_DOTMNA1 nao est� definido no dicion�rio de dados ou o seu conte�do � inv�lido. "*/
	cMensagem	+= STR0030 /*"Para que a rotina continue corretamente, "*/
	cMensagem	+= STR0031 /*"ser� necess�rio respeitar a solu��o proposta abaixo."*/
	cHelp		:= STR0032 /*"Incluir o par�metro MV_DOTMNA1 na tabela SX6."*/
	cHelp		+= STR0033 /*"Para maiores refer�ncias, consultar a documenta��o que acompanha a rotina."*/
	xMagHelpFis(cTitulo,cMensagem,cHelp)
Endif

If Empty(cMunA2) .Or. nMunA2 == 0
	cTitulo		:= STR0028 /*"Par�metro n�o existe"*/
	cMensagem	:= STR0049 /*"O par�metro MV_DOTMNA2 nao est� definido no dicion�rio de dados ou o seu conte�do � inv�lido. "*/
	cMensagem	+= STR0030 /*"Para que a rotina continue corretamente, "*/
	cMensagem	+= STR0031 /*"ser� necess�rio respeitar a solu��o proposta abaixo."*/
	cHelp		:= STR0050 /*"Incluir o par�metro MV_DOTMNA2 na tabela SX6 com a seguinte estrutura: "*/
	cHelp		+= STR0033 /*" Para maiores refer�ncias, consultar a documenta��o que acompanha a rotina."*/
	xMagHelpFis(cTitulo,cMensagem,cHelp)
Endif

If Empty(cMunEmp) .And. Empty(cMunPar)
	cTitulo		:= STR0034 /*"Par�metro/Campo Inconsistente"*/
	cMensagem	:= STR0035 /*"Para determinar o c�digo do munic�pio do contribuinte, � necess�rio que o "*/
	cMensagem	+= STR0036 /*"campo M0_CODMUN esteja preenchido ou exista o par�metro MV_DOTMNEM com "*/
	cMensagem	+= STR0037 /*"conte�do v�lido. Para solucionar o problema, sera necessario respeitar a solu��o abaixo:"*/
	cHelp		:= STR0038 /*"Preencha o campo M0_CODMUN ou crie o parametro MV_DOTMNEM na tabela SX6"*/
	cHelp		+= STR0039 /*" Para maiores refer�ncias, consultar a documenta��o que acompanha a rotina."*/
	xMagHelpFis(cTitulo,cMensagem,cHelp)
Endif

If !Empty(cMunPar)
	cMunEmp := Alltrim(cMunPar)
Endif

RecLock("R02",.T.)
R02->TIPO		:= "2"
R02->MUNIC		:= Val(Substr(cMunEmp,1,5))
R02->IE			:= Val(SubStr((ARETDIG(SM0->M0_INSC,.T.,SM0->M0_ESTENT)),1,9))
R02->APRESENTA	:= Val(SubStr(cApresenta,1,1))
R02->ESTINIC	:= 0
R02->ENTREST	:= 0
R02->ENTRPRO	:= 0
R02->ENTRPF		:= 0
R02->ENTRINTER	:= 0
R02->ENTREXT	:= 0
R02->SAIEST		:= 0
R02->SAIINTER	:= 0
R02->SAIEXT		:= 0
R02->ESTFINAL	:= 0
R02->RECEITA	:= 0
R02->ENEELETR	:= 0
R02->TRANSP		:= 0
R02->COMUNIC	:= 0
R02->EXTPETR	:= 0
R02->AGUA		:= 0
R02->OUTATIV	:= 0
R02->OUTRO		:= 0
R02->MEMOOBS	:= ""
R02->(MsUnlock())

/*Processamento dos Documentos Fiscais*/
dbSelectArea("SF3")
SF3->(DbSetOrder(1))
ProcRegua(LastRec())
#IFDEF TOP
	If (TcSrvType ()<>"AS/400")
		lTop := .T.
		cAliasSF3 := GetNextAlias()
		
		BeginSql Alias cAliasSF3
			
			COLUMN F3_ENTRADA AS DATE
			
			SELECT SF3.F3_FILIAL,
					SF3.F3_NFISCAL,
					SF3.F3_SERIE,
					SF3.F3_ENTRADA,
					SF3.F3_TIPO,
					SF3.F3_DTCANC,
					SF3.F3_OBSERV,
					SF3.F3_CFO,
					SF3.F3_CLIEFOR,
					SF3.F3_LOJA,
					SF3.F3_VALCONT,
					SF3.F3_ESTADO,
					SF3.F3_CLIENT,
					SF3.F3_LOJENT
			FROM
			%TABLE:SF3% SF3
			WHERE SF3.F3_FILIAL=%XFILIAL:SF3%
			AND SF3.F3_ENTRADA >= %EXP:DTOS(dDtInicial)%
			AND SF3.F3_ENTRADA <= %EXP:DTOS(dDtFinal)%
			AND SF3.F3_TIPO <> 'S'
			AND SF3.F3_DTCANC = %Exp:Dtos(Ctod(''))%
			AND SF3.%NOTDEL%
			ORDER BY SF3.F3_FILIAL,
					SF3.F3_ENTRADA,
					SF3.F3_NFISCAL,
					SF3.F3_SERIE,
					SF3.F3_CLIEFOR,
					SF3.F3_LOJA,
					SF3.F3_CFO,
					SF3.F3_ALIQICM
		EndSql
		DbSelectArea(cAliasSF3)
		(cAliasSF3)->(DbGoTop())
	Else
	#ENDIF
	cIndex  := CriaTrab(NIL,.F.)
	cFiltro := 'F3_FILIAL == "' + xFilial("SF3") + '" .And. '
	cFiltro += 'DTOS(F3_ENTRADA) >= "' + DTOS(dDtInicial) + '" '
	cFiltro += '.And. DTOS(F3_ENTRADA) <= "' + DTOS(dDtFinal) + '"'
	IndRegua (cAliasSF3, cIndex, SF2->(IndexKey ()),, cFiltro)
	nIndex := RetIndex(cAliasSF3)
	#IFNDEF TOP
		DbSetIndex (cIndex+OrdBagExt ())
	#ENDIF
	DbSelectArea (cAliasSF3)
	DbSetOrder (nIndex+1)
	#IFDEF TOP
	Endif
#ENDIF

Do While !(cAliasSF3)->(Eof())
	nValEnegGr	:= 0
	nValEnegDs	:= 0
	nValServTr	:= 0
	nValServCo	:= 0
	nValExPet	:= 0
	nValAgua	:= 0
	nValOut	:= 0
	nValPdPr	:= 0
	nValPFNC	:= 0
	cCodDet	:= ""
	cMunic		:= ""
	cContrib	:= .T.
	//lGera		:= .F.
	//-- Verifica se os CFOPs devem ser processados nas entradas
	If SubStr((cAliasSF3)->F3_CFO,1,1) < "5"
		If Alltrim((cAliasSF3)->F3_CFO)$ cEntradas
			(cAliasSF3)->(dbSkip())
			Loop
		Endif
	Endif
	//-- Verifica se os CFOPs devem ser processados nas saidas
	If SubStr((cAliasSF3)->F3_CFO,1,1) >= "5"
		If Alltrim((cAliasSF3)->F3_CFO)$ cSaidas
			(cAliasSF3)->(dbSkip())
			Loop
		Endif
	Endif
	/*Cliente e Fornecedor*/
	If SubStr((cAliasSF3)->F3_CFO,1,1) >= "5"
		If (cAliasSF3)->F3_TIPO$"DB"
			If !SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				(cAliasSF3)->(dbSkip())
				Loop
			Else
				If nMunA2 > 0
					cMunic := SA2->(FieldGet(nMunA2))
				Endif
			Endif
		Else
			If ! SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				(cAliasSF3)->(dbSkip())
				Loop
			ElseIf ! Empty((cAliasSF3)->F3_CLIENT) .and. ! Empty((cAliasSF3)->F3_LOJENT)   
				SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIENT+(cAliasSF3)->F3_LOJENT))
				If nMunA1 > 0
					cMunic := SA1->(FieldGet(nMunA1))
				Endif
			Else
				If nMunA1 > 0
					cMunic := SA1->(FieldGet(nMunA1))
				Endif
			Endif
		Endif
	Else
		If (cAliasSF3)->F3_TIPO$"DB"
			If ! SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				(cAliasSF3)->(dbSkip())
				Loop
			Else
				If nMunA1 > 0
					cMunic := SA1->(FieldGet(nMunA1))
				Endif
			Endif
		Else
			If ! SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				(cAliasSF3)->(dbSkip())
				Loop
			ElseIf ! Empty((cAliasSF3)->F3_CLIENT) .and. ! Empty((cAliasSF3)->F3_LOJENT)   
				SA2->(dbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIENT+(cAliasSF3)->F3_LOJENT))
				If nMunA1 > 0
					cMunic := SA2->(FieldGet(nMunA1))
				Endif
			Else
				If nMunA2 > 0
					cMunic := SA2->(FieldGet(nMunA2))
				Endif
			Endif
		Endif
	Endif
	R02->(dbGoTop())
	RecLock("R02",.F.)
	
	IF lGera
		/*Montagem do Quadro B Destina-se � informa��o do valor total das opera��es de gera��o e distribui��o de energia el�trica,
		presta��o de servi�os de transporte, presta��o de servi�os de comunica��o, extra��o de petr�leo, servi�o de tratamento e
		distribui��o de �gua canalizada, e outras atividades realizadas, no ano base, por empresas que atuam nos setores econ�micos
		espec�ficos constantes nos campos 14 a 19 deste quadro*/

		/*Energia Eletrica*/
		If Alltrim((cAliasSF3)->F3_CFO)$cEnergGer .Or. Alltrim((cAliasSF3)->F3_CFO)$cEnergDis
			R02->ENEELETR += (cAliasSF3)->F3_VALCONT
			cCodDet := "1"
			IF Alltrim((cAliasSF3)->F3_CFO)$cEnergGer
				nValEnegGr := (cAliasSF3)->F3_VALCONT
			ElseIf Alltrim((cAliasSF3)->F3_CFO)$cEnergDis
				nValEnegDs := (cAliasSF3)->F3_VALCONT
			EndIf

			IF R02->ENEELETR > 0
				aTipos[1][3] := .T.
			EndIf
		EndIf

		/*Servi�os de Transporte */
		If Alltrim((cAliasSF3)->F3_CFO)$cSevTransp
			nValServTr := (cAliasSF3)->F3_VALCONT
			cCodDet := "2"
			R02->TRANSP += (cAliasSF3)->F3_VALCONT

			IF R02->TRANSP > 0
				aTipos[2][3] := .T.
			EndIf
		EndIf

		/*Servi�os de Comunica��o */
		If Alltrim((cAliasSF3)->F3_CFO)$cSevComuni
			nValServCo  := (cAliasSF3)->F3_VALCONT
			cCodDet := "3"
			R02->COMUNIC += (cAliasSF3)->F3_VALCONT

			IF R02->COMUNIC > 0
				aTipos[3][3] := .T.
			EndIf
		Endif

		/*Extra��o do Petroleo*/
		If Alltrim((cAliasSF3)->F3_CFO)$cExtPetr
			nValExPet	:= (cAliasSF3)->F3_VALCONT
			cCodDet := "6"
			R02->EXTPETR += (cAliasSF3)->F3_VALCONT

			IF R02->EXTPETR > 0
				aTipos[6][3] := .T.
			EndIf
		EndIf

		/*Agua Canalizada*/
		If Alltrim((cAliasSF3)->F3_CFO)$cAguaCan
			nValAgua    := (cAliasSF3)->F3_VALCONT
			cCodDet 	:= "5"
			R02->AGUA += (cAliasSF3)->F3_VALCONT

			IF R02->AGUA > 0
				aTipos[5][3] := .T.
			EndIf
		EndIf

		/*Outras Atividades*/
		If Alltrim((cAliasSF3)->F3_CFO)$cOutAtiv 
			nValOut    := (cAliasSF3)->F3_VALCONT
			cCodDet 	:= "8"
			R02->OUTATIV += (cAliasSF3)->F3_VALCONT

			IF R02->OUTATIV > 0
				aTipos[8][3] := .T.
			EndIf
		EndIf

	Else
		/*
		QUADRO A: Destina-se � apura��o do valor adicionado obedecendo ao crit�rio �Resultado com Mercadorias�.
		N�o poder�o preencher este quadro os contribuintes que realizam opera��es com energia el�trica, servi�os de transporte,
		distribui��o de �gua canalizada e presta��o de servi�os exclusivamente de comunica��o, cujas informa��es ser�o prestadas
		e detalhadas no Quadro B. Tratando-se de empresa cuja atividade seja presta��o de servi�os de comunica��o consorciada
		com venda de aparelhos de telefonia, o resultado das vendas dever� ser apurado no Quadro A, separadamente das receitas
		de presta��o de servi�os.
		*/
		IF !Alltrim((cAliasSF3)->F3_CFO)$cEnergGer .And. !Alltrim((cAliasSF3)->F3_CFO)$cEnergDis .And. !Alltrim((cAliasSF3)->F3_CFO)$cSevTransp .And. !Alltrim((cAliasSF3)->F3_CFO)$cSevComuni .And. !Alltrim((cAliasSF3)->F3_CFO)$cExtPetr .And. !Alltrim((cAliasSF3)->F3_CFO)$cAguaCan .And. !Alltrim((cAliasSF3)->F3_CFO)$cOutAtiv

			/*Campo 02: Compras, transfer�ncias e devolu��es do Estado
			Informar o valor cont�bil correspondente ao somat�rio das compras, transfer�ncias e devolu��es de
			vendas nas opera��es internas
			*/
			If cMvEstado ==(cAliasSF3)->F3_ESTADO .And. SubStr((cAliasSF3)->F3_CFO,1,1) == "1"  .And. Empty(SA2->A2_TIPORUR) .And. !Alltrim((cAliasSF3)->F3_CFO)$cOutSerTrp .And. !(SA2->A2_TIPO == "F" .Or. Empty(SA2->A2_INSCR) .Or. Upper(Alltrim(SA2->A2_INSCR)) == "ISENTO")
				R02->ENTREST += (cAliasSF3)->F3_VALCONT
			Endif

			/*
			Campo 03: Entrada de produ��o Rural pr�pria.
			Informar o valor cont�bil total das entradas para comercializa��o ou industrializa��o, de produtos
			agropecu�rios produzidos em propriedade rural do pr�prio contribuinte ou arrendada de terceiros e n�o
			inscrito como empresa agropecu�ria..
			*/
			If cMvEstado ==(cAliasSF3)->F3_ESTADO .And. SubStr((cAliasSF3)->F3_CFO,1,1) == "1"  .And. !Empty(SA2->A2_TIPORUR) .And. !Alltrim((cAliasSF3)->F3_CFO)$cOutSerTrp
				nValPdPr	 := (cAliasSF3)->F3_VALCONT
				cCodDet 	 := "4"
				R02->ENTRPRO += (cAliasSF3)->F3_VALCONT
				IF R02->ENTRPRO > 0
					aTipos[4][3] := .T.
				EndIf
			Endif

			/*Compras de pessoa f�sica ou n�o contribuinte de ICMS*/
			If cMvEstado ==(cAliasSF3)->F3_ESTADO .And. SubStr((cAliasSF3)->F3_CFO,1,1) == "1" .And. Empty(SA2->A2_TIPORUR).And. !Alltrim((cAliasSF3)->F3_CFO)$cOutSerTrp
				If SA2->A2_TIPO == "F" .Or. Empty(SA2->A2_INSCR) .Or. Upper(Alltrim(SA2->A2_INSCR)) == "ISENTO"
					nValPFNC	:= (cAliasSF3)->F3_VALCONT
					cCodDet := "7"
					R02->ENTRPF	+= (cAliasSF3)->F3_VALCONT
					IF R02->ENTRPRO > 0
						aTipos[7][3] := .T.
					EndIf
				Endif
			Endif

			/*Campo 05: Compras, Transfer�ncias e devolu��es de outros Estados.*/
			If cMvEstado <>(cAliasSF3)->F3_ESTADO .And. SubStr((cAliasSF3)->F3_CFO,1,1) == "2" .And. !Alltrim((cAliasSF3)->F3_CFO)$cOutSerTrp
				R02->ENTRINTER += (cAliasSF3)->F3_VALCONT
			Endif

			/*Campo 06: Compras, Transfer�ncias e devolu��es do exterior*/
			If cMvEstado <> (cAliasSF3)->F3_ESTADO .And. SubStr((cAliasSF3)->F3_CFO,1,1) == "3" .And. (cAliasSF3)->F3_ESTADO == 'EX' .And. !Alltrim((cAliasSF3)->F3_CFO)$cOutSerTrp
				R02->ENTREXT += (cAliasSF3)->F3_VALCONT
			Endif

			/*Campo 08: Vendas, transfer�ncias e devolu��es internas*/
			If cMvEstado ==(cAliasSF3)->F3_ESTADO .And. SubStr((cAliasSF3)->F3_CFO,1,1) == "5" .And. !Alltrim((cAliasSF3)->F3_CFO)$cOutSerTrp
				R02->SAIEST += (cAliasSF3)->F3_VALCONT
			Endif

			/*Campo 09: Vendas, transfer�ncias e devolu��es para outros estados*/
			If cMvEstado <>(cAliasSF3)->F3_ESTADO .And. SubStr((cAliasSF3)->F3_CFO,1,1) == "6" .And. !Alltrim((cAliasSF3)->F3_CFO)$cOutSerTrp
				R02->SAIINTER += (cAliasSF3)->F3_VALCONT
			Endif

			/*Campo 10: Vendas para o exterior*/
			If cMvEstado <>(cAliasSF3)->F3_ESTADO .And. SubStr((cAliasSF3)->F3_CFO,1,1) == "7" .And. (cAliasSF3)->F3_ESTADO == 'EX' .And. !Alltrim((cAliasSF3)->F3_CFO)$cOutSerTrp
				R02->SAIEXT += (cAliasSF3)->F3_VALCONT
			Endif

			/*Quadro C � Outros */
			/*Campo 20: Outros - Destina-se � informa��o do valor correspondente aos servi�os de transporte contratados
			de pessoas f�sicas (transportadores aut�nomos) ou de empresas de transportes estabelecidas em outras unidades
			da federa��o, nos quais o contribuinte contratante assume a responsabilidade pelo recolhimento do imposto devido.*/
			If Alltrim((cAliasSF3)->F3_CFO)$cOutSerTrp .And. !Alltrim((cAliasSF3)->F3_CFO)$cOutAtiv
				R02->OUTRO += (cAliasSF3)->F3_VALCONT
			Endif
		EndIf
	EndIf

	/*Quadro D Quadro D � Observa��es. Destina-se � presta��o de informa��es complementares, nos casos em que as
	informa��es prestadas nos campos anteriores n�o sejam suficientes.*/
	If !Empty(cInfCompl)
		R02->MEMOOBS := cInfCompl
	EndIf

	/*Quadro de Detalhamentos*/
	If !Empty(cCodDet) .And. !(Empty(cMunic))
		R06->(dbSetOrder(1))
		IF !R06->(dbSeek(cMunic+cCodDet))
			RecLock("R06",.T.)
			R06->MUNIC1 	:= cMunic
			R06->CODDET 	:= cCodDet
			R06->VALDET1	:= 0
			R06->VALDET2	:= 0
		Else
			RecLock("R06",.F.)
		EndIF
		Do Case
		Case cCodDet == "1"
			R06->VALDET1		+= nValEnegDs
			R06->VALDET2		+= nValEnegGr
		Case cCodDet == "2"
			R06->VALDET1		+= nValServTr
		Case cCodDet == "3"
			R06->VALDET1		+= nValServCo
		Case cCodDet == "4"
			R06->VALDET1		+= nValPdPr
		Case cCodDet == "5"
			R06->VALDET1		+= nValAgua
		Case cCodDet == "6"
			R06->VALDET1		+= nValExPet
		Case cCodDet == "7"
			R06->VALDET1		+= nValPFNC
		Case cCodDet == "8"
			R06->VALDET1		+= nValOut
		EndCase
		R06->(MsUnLock())
		cCodDet := ""
	EndIf
	(cAliasSF3)->(dbSkip())
Enddo

For nX := 1 To Len(aMunic) // Municipios
	For nY := 1 To Len(aTipos) // Tipos Detalhamento
		IF aTipos[nY][03] //Verifica se tem valor para o Tipo Posicionado
			IF !R06->(dbSeek(aMunic[nX][2]+aTipos[nY][1]))
				RecLock("R06",.T.)
				R06->MUNIC1 	:= aMunic[nX][2]
				R06->CODDET 	:= aTipos[nY][1]
				R06->VALDET1	:= 0
				R06->VALDET2	:= 0
				R06->(MsUnLock())
			EndIf
		EndIf
	Next nY
Next nX

/*Calcula estoque Inicial e Final*/
If lEstoque
	#IFDEF TOP
		If (TcSrvType ()<>"AS/400")
			cAliasSB9 := GetNextAlias()

			BeginSql Alias cAliasSB9

				COLUMN B9_DATA AS DATE

				SELECT SB9.B9_FILIAL,
						SB9.B9_DATA,
						SB9.B9_VINI1
				FROM
				%TABLE:SB9% SB9
				WHERE SB9.B9_FILIAL=%XFILIAL:SB9%
				AND SB9.%NOTDEL%
				AND (SB9.B9_DATA = %EXP:DTOS(dDtInicial)%
				OR SB9.B9_DATA = %EXP:DTOS(dDtFinal)%)
				ORDER BY %Order:SB9%
			EndSql
			DbSelectArea(cAliasSB9)
			(cAliasSB9)->(DbGoTop())
		Else
		#ENDIF
			cIndex  := CriaTrab(NIL,.F.)
			cFiltro := 'B9_FILIAL == "' + xFilial("SB9") + '" .And. '
			cFiltro += 'DTOS(B9_DATA) = "' + DTOS(dDtInicial) + '" '
			cFiltro += '.Or. DTOS(B9_DATA) <= "' + DTOS(dDtFinal) + '"'
			IndRegua (SB9, cIndex, SB9->(IndexKey ()),, cFiltro)
			nIndex := RetIndex(SB9)
			#IFNDEF TOP
				DbSetIndex (cIndex+OrdBagExt ())
			#ENDIF
			DbSelectArea (SB9)
			DbSetOrder (nIndex+1)
		#IFDEF TOP
		Endif
	#ENDIF

	(cAliasSB9)->(dbGoTop())
	R02->(dbGoTop())
	RecLock("R02",.F.)
	While !(cAliasSB9)->(Eof()) .And. (cAliasSB9)->B9_FILIAL == xFilial("SB9")
		If (cAliasSB9)->B9_DATA == dDtInicial
			R02->ESTINIC	+= (cAliasSB9)->B9_VINI1
		Else
			R02->ESTFINAL	+= (cAliasSB9)->B9_VINI1
		Endif
		(cAliasSB9)->(dbSkip())
	Enddo
	R02->(MsUnLock())
Endif

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �DOTGIESTemp �Autor  �Mary C. Hergert     � Data � 26/01/2005  ���
���������������������������������������������������������������������������͹��
���Desc.     �Cria os arquivos temporarios                                  ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       �DOTGIES                                                       ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function DOTGIESTemp()

	Local aTrbs		:= {}
	Local aStruR02	:= {}
	Local aStruR06	:= {}
	Local cArqR02	:= ""
	Local cArqR03	:= ""
	Local cArqR04	:= ""
	Local cArqR05	:= ""

	AADD(aStruR02,{"TIPO"		,"C",001,0})
	AADD(aStruR02,{"IE"			,"N",009,0})
	AADD(aStruR02,{"MUNIC"		,"N",005,0})
	AADD(aStruR02,{"APRESENTA"	,"N",001,0})
	AADD(aStruR02,{"ESTINIC"	,"N",014,2})
	AADD(aStruR02,{"ENTREST"	,"N",014,2})
	AADD(aStruR02,{"ENTRPRO"	,"N",014,2})
	AADD(aStruR02,{"ENTRPF"		,"N",014,2})
	AADD(aStruR02,{"ENTRINTER"	,"N",014,2})
	AADD(aStruR02,{"ENTREXT"	,"N",014,2})
	AADD(aStruR02,{"SAIEST"		,"N",014,2})
	AADD(aStruR02,{"SAIINTER"	,"N",014,2})
	AADD(aStruR02,{"SAIEXT"		,"N",014,2})
	AADD(aStruR02,{"ESTFINAL"	,"N",014,2})
	AADD(aStruR02,{"RECEITA"	,"N",014,4})
	AADD(aStruR02,{"ENEELETR"	,"N",014,4})
	AADD(aStruR02,{"TRANSP"		,"N",014,4})
	AADD(aStruR02,{"COMUNIC"	,"N",014,4})
	AADD(aStruR02,{"EXTPETR"	,"N",014,4})
	AADD(aStruR02,{"AGUA"		,"N",014,4})
	AADD(aStruR02,{"OUTATIV"	,"N",014,4})
	AADD(aStruR02,{"OUTRO"		,"N",014,4})
	AADD(aStruR02,{"MEMOOBS"	,"C",200,0})
	//
	cArqR02	:=	CriaTrab(aStruR02)
	dbUseArea(.T.,__LocalDriver,cArqR02,"R02")
	IndRegua("R02",cArqR02,"TIPO")
	//
	AADD(aStruR06,{"MUNIC1"		,"C",005,0})
	AADD(aStruR06,{"CODDET"		,"C",001,0})
	AADD(aStruR06,{"VALDET1"	,"N",014,2})
	AADD(aStruR06,{"VALDET2"	,"N",014,2})
	//
	cArqR06	:=	CriaTrab(aStruR06)
	dbUseArea(.T.,__LocalDriver,cArqR06,"R06")
	IndRegua("R06",cArqR06,"MUNIC1+CODDET")
	aTrbs := {{cArqr02,"R02"},{cArqr03,"R03"},{cArqr04,"R04"},{cArqr05,"R05"},{cArqr06,"R06"}}

Return aTrbs

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �DOTGIESDel  �Autor  �Mary C. Hergert     � Data � 26/01/2005  ���
���������������������������������������������������������������������������͹��
���Desc.     �Deleta os arquivos temporarios processados                    ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       �DOTGIES                                                       ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function DOTGIESDel(aDelArqs)

	Local aAreaDel := GetArea()
	Local nI := 0

	For nI:= 1 To Len(aDelArqs)
		If File(aDelArqs[nI,1]+GetDBExtension())
			dbSelectArea(aDelArqs[ni,2])
			dbCloseArea()
			Ferase(aDelArqs[nI,1]+GetDBExtension())
			Ferase(aDelArqs[nI,1]+OrdBagExt())
		Endif
	Next

	RestArea(aAreaDel)

Return

FUNCTION ListaMunES()

Local aMunic:= {}

aMunic := {;
{"�gua Doce do Norte"		,"50210",0,.F.},;
{"�guia Branca"				,"50212",0,.F.},;
{"Alegre"					,"50701",0,.F.},;
{"Alfredo Chaves"			,"50402",0,.F.},;
{"Alto Rio Novo"			,"50211",0,.F.},;
{"Anchieta"					,"50801",0,.F.},;
{"Apiac�"					,"50702",0,.F.},;
{"Aracruz"					,"50301",0,.F.},;
{"At�lio Viv�cqua"			,"50703",0,.F.},;
{"Baixo Guandu"				,"50201",0,.F.},;
{"Barra de Sao Francisco"	,"50202",0,.F.},;
{"Boa Esperanca"			,"50203",0,.F.},;
{"Bom Jesus do Norte"		,"50704",0,.F.},;
{"Brejetuba"				,"50310",0,.F.},;
{"Cachoeiro de Itapemirim"	,"50705",0,.F.},;
{"Cariacica"				,"50501",0,.F.},;
{"Castelo"					,"50601",0,.F.},;
{"Colatina"					,"50204",0,.F.},;
{"Conceicao da Barra"		,"50302",0,.F.},;
{"Conceicao do Castelo"		,"50602",0,.F.},;
{"Divino S�o Louren�o"		,"50706",0,.F.},;
{"Domingos Martins"			,"50403",0,.F.},;
{"Dores do Rio Preto"		,"50707",0,.F.},;
{"Ecoporanga"				,"50101",0,.F.},;
{"Fund�o"					,"50303",0,.F.},;
{"Governador Lindenberg"	,"50216",0,.F.},;
{"Guarapari"				,"50802",0,.F.},;
{"Guacui"					,"50708",0,.F.},;
{"Ibatiba"					,"50605",0,.F.},;
{"Ibira�u"					,"50404",0,.F.},;
{"Ibitirama"				,"50714",0,.F.},;
{"Iconha"					,"50803",0,.F.},;
{"Irupi"					,"50607",0,.F.},;
{"Itagua�u"					,"50405",0,.F.},;
{"Itapemirim"				,"50804",0,.F.},;
{"Itarana"					,"50406",0,.F.},;
{"I�na"						,"50603",0,.F.},;
{"Jaguar�"					,"50308",0,.F.},;
{"Jer�nimo Monteiro"		,"50709",0,.F.},;
{"Jo�o Neiva"				,"50410",0,.F.},;
{"Laranja da Terra"			,"50409",0,.F.},;
{"Linhares"					,"50304",0,.F.},;
{"Manten�polis"				,"50205",0,.F.},;
{"Marataizes"				,"50715",0,.F.},;
{"Marechal Floriano"		,"50412",0,.F.},;
{"Maril�ndia"				,"50209",0,.F.},;
{"Mimoso do Sul"			,"50710",0,.F.},;
{"Montanha"					,"50102",0,.F.},;
{"Mucurici"					,"50103",0,.F.},;
{"Muniz Freire"				,"50604",0,.F.},;
{"Muqui"					,"50711",0,.F.},;
{"Nova Ven�cia"				,"50206",0,.F.},;
{"Pancas"					,"50207",0,.F.},;
{"Pedro Can�rio"			,"50309",0,.F.},;
{"Pinheiros"				,"50305",0,.F.},;
{"Pi�ma"					,"50805",0,.F.},;
{"Ponto Belo"				,"50104",0,.F.},;
{"Presidente Kennedy"		,"50806",0,.F.},;
{"Rio Bananal"				,"50307",0,.F.},;
{"Rio Novo do Sul"			,"50807",0,.F.},;
{"Santa Leopoldina"			,"50407",0,.F.},;
{"Santa Maria de Jetib�"	,"50411",0,.F.},;
{"Santa Teresa"				,"50408",0,.F.},;
{"Serra"					,"50502",0,.F.},;
{"Sooretama"				,"50311",0,.F.},;
{"S�o Domingos do Norte"	,"50213",0,.F.},;
{"S�o Gabriel da Palha"		,"50208",0,.F.},;
{"S�o Jos� do Cal�ado"		,"50712",0,.F.},;
{"S�o Mateus"				,"50306",0,.F.},;
{"S�o Roque do Cana�"		,"50413",0,.F.},;
{"Vargem Alta"				,"50713",0,.F.},;
{"Venda Nova do Imigrante"	,"50606",0,.F.},;
{"Viana"					,"50503",0,.F.},;
{"Vila Pavao"				,"50214",0,.F.},;
{"Vila Val�rio"				,"50215",0,.F.},;
{"Vila Velha"				,"50504",0,.F.},;
{"Vit�ria"					,"50505",0,.F.}}

Return aMunic
