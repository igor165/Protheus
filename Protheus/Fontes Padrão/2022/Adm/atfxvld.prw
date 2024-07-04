#Include "Protheus.Ch"
#Include "AtfxVld.Ch"

Static __lStruPrj // Verifica se existe a estrutura de projetos no ambiente
Static __lBpiAtf	:= NIL
Static __lMargem	:= NIL
Static __lProvis	:= NIL
Static __lATF012SAL
STATIC lMultMoed := FindFunction("AtfMoedas")

STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ATFVISUAL  � Autor � Vinicius Barreira     � Data � 27/12/95 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Posiciona o SN1 em fun��o do SN3 para visualiza��o           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe e � ATFVISUAL                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Uso       � AtivoFixo                                                    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function ATFVISUAL(cAlias,nReg,nOpc)
Return ATFXVISUAL(cAlias,nReg,nOpc)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ATFXVISUAL � Autor � Vinicius Barreira     � Data � 27/12/95 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Posiciona o SN1 em fun��o do SN3 para visualiza��o           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe e � ATFVISUAL                                                    ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Uso       � AtivoFixo                                                    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function ATFXVISUAL(cAlias,nReg,nOpc)
	
	Local nSavRec := 0
	Local nOrdem  := 0
	Local cChave

	dbSelectArea("SN3")

	nSavRec := Recno()
	nOrdem  := IndexOrd()

	//����������������������������������Ŀ
	//� Posiciona o SN1 em fun��o do SN3.�
	//������������������������������������
	dbSelectArea("SN1")
	dbSetOrder(1)
	cChave := SN3->N3_CBASE + SN3->N3_ITEM
	If Alltrim(FunName()) == "ATFA030" .And. Trim(GetMv("MV_ATFCONT"))="N"
		cChave := SN4->N4_CBASE + SN4->N4_ITEM
	Endif
	dbSeek( xFilial("SN1") + cChave )

	//����������������������������������Ŀ
	//� Executa fun��o de visualiza��o.  �
	//������������������������������������
	FWExecView("","ATFA012",/*Por padr? a opera?o ?Veiw*/, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/)

	//����������������������������Ŀ
	//� Restaura posi��o do SN3.   �
	//������������������������������
	dbSelectArea("SN3")
	dbSetOrder( nOrdem )
	dbGoTo( nSavRec )

Return Nil

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � AtfJaCalc  � Autor � Wagner Mobile Costa   � Data � 04.09.02 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna se o Bem/Item/Tipo ja efetuou algum Calc. Depreciacao���
���������������������������������������������������������������������������Ĵ��
���Uso       � SigaAtf                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function AtfJaCalc()
Return ATFXJACALC()

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ATFXJACALC � Autor � TOTVS SA              � Data � 10.08.10 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna se o Bem/Item/Tipo ja efetuou algum Calc. Depreciacao���
���������������������������������������������������������������������������Ĵ��
���Uso       � SigaAtf                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function ATFXJACALC()

	Local lRet := .T., nPosTipo	:= Ascan(aHeader, {|x| x[2] == "N3_TIPO"})

	If ALTERA .And. nPosTipo > 0
		SN4->(DbSeek(	xFilial() + M->N1_CBASE + M->N1_ITEM + aCols[n][nPosTipo], .T.))
		While 	SN4->N4_FILIAL = xFilial("SN4") .And. SN4->N4_CBASE = M->N1_CBASE .And.;
		SN4->N4_ITEM = M->N1_ITEM .And. SN4->N4_TIPO = aCols[n][nPosTipo] .And.;
		!	SN4->(Eof())
			If SN4->N4_OCORR <> "05"
				lRet := .F.
				Exit
			Endif
			SN4->(DbSkip())
		EndDo
	Endif

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AFXVlBxN1 �Autor  �Alvaro Camillo Neto � Data �  08/03/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se existe algum SN3 Ativo para o bem e caso        ���
���          �n�o tenha, marca o SN1 como baixado                         ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AFXVlBxN1(cBase,cItem,dBaixa)
	Local aArea    := GetArea()
	Local aAreaSN3 := SN3->(GetArea())
	Local aAreaSN1 := SN1->(GetArea())
	Local lRet	   := .T.
	Local lBaixa   := .F.

	SN1->(dbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
	SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

	If SN1->(dbSeek(xFilial("SN1") + cBase + cItem )) 
		If SN3->(dbSeek(xFilial("SN3") + cBase + cItem ))
			lBaixa := .T.
			While SN3->(!EOF()) .And. SN3->(N3_FILIAL+N3_CBASE+N3_ITEM) == xFilial("SN3") + cBase + cItem
				If SN3->N3_BAIXA == "0" .Or. Empty(SN3->N3_BAIXA) // Bem Ativo
					lBaixa := .F.
					Exit 
				EndIf
				SN3->(dbSkip())
			EndDo
			If lBaixa
				RecLock("SN1",.F.)
				SN1->N1_BAIXA	:= dBaixa
				MsUnLock()
			EndIf
		EndIf 
	EndIf                 

	RestArea(aAreaSN1)
	RestArea(aAreaSN3)
	RestArea(aArea)
Return lRet

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � AtfBloqueio� Autor � Wagner Mobile Costa   � Data � 16/04/02 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica o bloqueio do bem ou do grupo                        ���
���������������������������������������������������������������������������Ĵ��
���Utilizacao� AtfBloqueio(cChave)                                          ���
���������������������������������������������������������������������������Ĵ��
���Parametros� cChave  - > Chave de busca no grupo de bens                  ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function AtfBloqueio(cChave, dRetorno)

	Local cAlias := Alias(), lRet := .T.

	DbSelectArea("SN1")
	If N1_CBASE+N1_ITEM <> cChave
		MsSeek(xFilial() + cChave)
	Endif

	If !Empty(SN1->N1_DTBLOQ) .And. Dtos(SN1->N1_DTBLOQ)>= Dtos(dDataBase)
		lRet := .F.
	Endif

	If lRet .And. ! Empty(SN1->N1_GRUPO) .And. SNG->NG_GRUPO <> SN1->N1_GRUPO
		DbSelectArea("SNG")
		MsSeek(xFilial() + SN1->N1_GRUPO)
	Endif

	If 	lRet .And. ! Empty(SN1->N1_GRUPO) .And. ! Empty(SNG->NG_DTBLOQ) .And.;
	Dtos(SNG->NG_DTBLOQ)>= Dtos(dDataBase)
		lRet := .F.
	Endif

	If ! Empty(SN1->N1_DTBLOQ) .And. dRetorno # Nil
		dRetorno := SN1->N1_DTBLOQ
	ElseIf ! Empty(SN1->N1_GRUPO) .And. SNG->NG_GRUPO = SN1->N1_GRUPO .And. ! Empty(SNG->NG_DTBLOQ)
		dRetorno := SNG->NG_DTBLOQ
	Endif

	DbSelectArea(cAlias)

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFCanCalc�Autor  � Marcelo Akama      � Data �  28/07/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se pode efetuar o calculo da depreciacao          ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFCanCalc(dUltProc, cAuxMes, cAuxDia)

	Local aArea		:= GetArea()
	Local lRet     	:= .T.
	Local nYear		:= 0
	Local cCalcDep	:= GetNewPar("MV_CALCDEP",'0')

	Default dUltProc := GetNewPar("MV_ULTDEPR", STOD("19800101"))
	Default cAuxMes  := "12"
	Default cAuxDia  := "31"

	If cCalcDep == '1'
		nYear 	:= Year(dUltProc)
		lRet 	:= dUltProc == Stod( cValtoChar(nYear)+cAuxMes+cAuxDia )  
	EndIf

	If !lRet
		Help(" ",1,"ATFHIBRER"+cCalcDep)
	EndIf

	RestArea(aArea)
	
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtfVldMoed�Autor  � ------------------ � Data �  ---------- ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida o conteudo do SX6 quando preenchido com moeda       ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AtfVldMoed(cMoeda)

	Local aGetArea	:= GetArea()	// Salva ambiente
	Local nQuantas	:= 5			// Valor Default
	Local lRet	:= .T.
	Local nMoeda	:= Val(cMoeda)

	//********************************
	// Controle de multiplas moedas  *
	//********************************
	nQuantas	:= CtbMoedas()
	nQuantas	:= If( nQuantas < 5, 5, nQuantas )

	DbSelectArea("SX3")
	dbsetOrder(2)
	If !dbSeek("N3_VORIG"+Alltrim(Str(nQuantas)))
		nQuantas	:= 5 // Caso n�o encontre o campo da maior moeda trata o padrao
	EndIf

	IF ValType(nMoeda) != "N"
		lRet:= .F.
	ELSEIF ValType(nMoeda) == "N" .AND. nMoeda <= 0
		lRet := .F.
	ELSEIF ValType(nMoeda) == "N" .AND. SX3->(!dbSeek("N3_VORIG"+Alltrim(cMoeda)))
		lRet := .F.
	ENDIF

	RestArea( aGetArea )
	
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �VldDeprec � Autor � Jair RIbeiro          � Data � 27/04/11 ���
�������������������������������������������������������������������������Ĵ��
���Desc.     � Valida criterio de depreciacao				              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAATF                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Sintaxe  � VldDeprec()								                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VldDeprec()

	Local cVar 			:= ReadVar()
	Local cConteudo		:= &(ReadVar())
	Local lRet			:= .T.
	Local nPosN3Tipo	:= aScan(aHeader,{|x| Alltrim(x[2]) == "N3_TIPO"})
	Local nPosN3TpDp	:= aScan(aHeader,{|x| Alltrim(x[2]) == "N3_CRIDEPR"})
	Local nPosN3ClDp	:= aScan(aHeader,{|x| Alltrim(x[2]) == "N3_CALDEPR"})
	Local nPosFNGTip	:= aScan(aHeader,{|x| Alltrim(x[2]) == "FNG_TIPO"})
	Local nPosFNGTpD	:= aScan(aHeader,{|x| Alltrim(x[2]) == "FNG_CRIDEP"})
	Local nPosFNGClD	:= aScan(aHeader,{|x| Alltrim(x[2]) == "FNG_CALDEP"})
	Local nLin			:= n
	Local cTypesNM		:= IIF(lIsRussia,"|" + AtfNValMod({1,2}, "|"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - main and recoverable models

	If "TIPO" $ cVar
		If "FNG" $ cVar .and. nPosFNGTip != 0 .and. nPosFNGTpD != 0
			If Alltrim(aCols[nLin,nPosFNGTpD]) $ "03|04"
				If !(Alltrim(cConteudo) $ "10|12"+cTypesNM)
					Help(" ",1,"VldDeprec",,STR0001,1,0)  //"Crit�rio de deprecia��o n�o � valido para o tipo de ativo em quest�o"
					lRet:= .F.
				EndIf
			EndIf
		EndIf
	ElseIf "CRIDEP" $ cVar
		If "N3" $ cVar .and. nPosN3Tipo != 0 .and. nPosN3TpDp != 0 .and. nPosN3ClDp != 0
			If !(Alltrim(aCols[nLin,nPosN3Tipo]) $ "10|12"+cTypesNM) .and. !Empty(aCols[nLin,nPosN3Tipo])
				If Alltrim(cConteudo) $ "03|04"
					Help(" ",1,"VldDeprec",,STR0001,1,0)  //"Crit�rio de deprecia��o n�o � valido para o tipo de ativo em quest�o"
					lRet:= .F.
				EndIf
			EndIf
			If !(Alltrim(cConteudo) $ "03|04")
				aCols[nLin,nPosN3ClDp] := space(TamSx3("N3_CALDEPR")[1])
			EndIf
		ElseIf "FNG" $ cVar .and. nPosFNGTip != 0 .and. nPosFNGTpD != 0
		If !(Alltrim(aCols[nLin,nPosFNGTip]) $ "10|12"+cTypesNM) .and. !Empty(aCols[nLin,nPosFNGTip])
				If Alltrim(cConteudo) $ "03|04"
					Help(" ",1,"VldDeprec",,STR0001,1,0)  //"Crit�rio de deprecia��o n�o � valido para o tipo de ativo em quest�o"
					lRet:= .F.
				EndIf
			EndIf
			If !(Alltrim(cConteudo) $ "03|04")
				aCols[nLin,nPosFNGClD] := space(TamSx3("N3_CALDEPR")[1])
			EndIf
		EndIf
	EndIf
	
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �VldTipDepr� Autor � Jair RIbeiro          � Data � 27/04/11 ���
�������������������������������������������������������������������������Ĵ��
���Desc.     � When para campos de criterio e calendario de depreciacao   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAATF                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Sintaxe  � VldTipDepr(cDescCpoCr,cDescCpoCl)		                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cDescCpoCr: Campo criterio N3_CRIDEPR,NG_CRIDEPR,FNG_TIDEP ���
���          � cDescCpoCl: Campo Calendario N3_CALDEPR,NG_CALDEPR,        ���
���          � FNG_CALDEP		                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VldTipDepr(cDescCpoCr,cDescCpoCl)

	/*
	Premissa 01: Caso nao seja definido um conteudo para o parametro da funcao - cCampo o retorno da fun��o sera .F.

	Premissa 02: Como a fun��o poder� ser chamada de um cadastro simples (Enchoice) ou de uma Grid (MsGetDados) o conteudo
	do campo dever� ser recuperado com &(ReadVar())
	
	Premissa 03: No tratamento do campo _CALDEPR, dever� ser avaliado se a valida��o est� em um Grid ou em uma Enchoice para que o
	conte�do do campo _TIPDEPR seja recuperado adequadamente, pois para este campo nesta situacao nao podera ser usado o &(ReadVar()),
	pois ele n�o � o campo posicionado no momento.
	
	1.	Se o campo a ser validado for _TIPDEPR:
	1.1.	Verificar se o conteudo do par�metro MV_TIPDEPR � diferente de "9" - Ficha do Ativo, aonde:
	1.1.1.	MV_TIPDEPR == 9 ' Retorno .T.
	1.1.2.	MV_TIPDEPR != 9 ' Retorno .F.
	
	2.	Se o campo a ser validado for _CALDEPR:
	2.1.	Verificar se o conte�do do par�metro MV_TIPDEPR � diferente de "9" - Ficha do Ativo, aonde:
	2.1.1.	MV_TIPDEPR == 9 ' Testa pr�xima situa��o
	2.1.2.	MV_TIPDEPR != 9 ' Retorno .F.
	
	2.2.	Verificar se o conte�do do campo _TIPDEPR cont�m "03" - Exerc�cio Completo ou "04" - Pr�ximo Trimestre.
	2.2.1.	_TIPDEPR $ ("03|04") ' Retorno .T.
	2.2.2.	!(_TIPDEPR $ ("03|04")) ' Retorno .F.
	*/
	
	Local lRet			:= (Alltrim(SuperGetMv("MV_TIPDEPR",.F.,"")) == "9")
	Local aAreaSx3		:= SX3->(GetArea())
	Local nPos			:= If(Type('aHeader')== "A",Ascan(aHeader,{|x| Alltrim(x[2]) == cDescCpoCr}),0)
	Local nPosTp		:= If(Type('aHeader')== "A",Ascan(aHeader,{|x| Alltrim(x[2]) == "N3_TIPO"}),0)
	Default cDescCpoCr	:= ""
	Default cDescCpoCl	:= ""

	//Tipo 11 deve ter o mesmo calendario do tipo 01 e nao pode ser alterado
	If nPosTp > 0
		If (Alltrim(aCols[n,nPosTp]) $ "|11")
			lRet := .F.
		EndIf
	EndIf

	SX3->(DbSetOrder(2))
	If SX3->(DbSeek(cDescCpoCr))
		If Empty(cDescCpoCr)
			lRet:=.F.
		EndIf
	Else
		lRet:=.F.
	EndIf
	If "_CALDEP" $ cDescCpoCl .and. lRet
		If SX3->(DbSeek(cDescCpoCl))
			If nPos > 0
				If Type('aCols') == "A"
					If !(Alltrim(aCols[n,nPos]) $ "03|04")
						lRet := .F.
					EndIf
				Else
					lRet := .F.
				EndIf
			ElseIf !(ALLTRIM(M->&(cDescCpoCr)) $ "03|04")
				lRet := .F.
				M->&(cDescCpoCr) := Space(TamSx3("NG_CRIDEPR")[1])
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf
	SX3->(RestArea(aAreaSx3))
	
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |VldCriDepr�Autor  �Jair Ribeiro	     � Data �  06/24/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida campo N3_CRIDEPR                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function VldCriDepr()
	
	Local lRet	:= .T.

	lRet := VldDeprec()

	If lRet
		lRet := AF012VLAEC()
	EndIf
	
Return lRet

/*/
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Funcao    � AtfVlTpSal  � Autor � Totvs                   � Data � 15/09/08 ���
������������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o tipo de saldo informado                                ���
������������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                        ���
������������������������������������������������������������������������������Ĵ��
���Parametros� cTpSaldo - tipo do saldo a ser validado.                        ���
���          � cCharEsp - se permite o caracter * ou nao.                      ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
Function AtfVlTpSal( cTpSaldo, lCharEsp, lHelp )
	
	Local lret			:= .F.
	Default lCharEsp	:= .F.
	Default lHelp   	:= .T.


	If cTpSaldo == "*" .AND. lCharEsp
		lret := .T.
	Else
		lret := !Empty( Tabela( "SL", cTpSaldo, .F. ) )
	EndIf

	If !lRet .And. lHelp
		Help(" ",1,"ATFSLDINV")
	EndIf

Return lret

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFSALDEPR�Autor  �Microsiga           � Data �  10/21/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida o tipo de saldo e tipo depreciacao no linha ok      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�cTipo: Tipo do Ativo                                        ���
���          �cTpSald: Tipo de Saldo                                      ���
���          �cTpDepr: Metodo de depreciacao                              ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAATF                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFSALDEPR(cTipo,cTpSald,cTpDepr)
	
	Local aConfig	:= {}
	Local aArea		:= {}
	Local aAreaGen	:= {}
	Local nPosConfig:= 0
	Local lRet		:= .T.

	Local cAllTipos	:= ""

	Default cTipo	:= ""
	Default cTpSald	:= ""
	Default cTpDepr	:= ""

	If __lATF012SAL == NIL
		__lATF012SAL := ExistBlock("ATF012SAL")  //verifica se existe PE
	EndIf

	If !Empty(cTipo)

		// Para todos os paise os tipos gerenciais podem ter todos os m�todos de deprecia��o dispon�veis

		AAdd(aConfig,	{"10|12|13|14|15|16|17"					,"*"		,"*"		})

		Do Case
			Case cPaisLoc == "ANG"
			//			  			|Tipo Ativo						|Tipo Saldo	|Metodo Depreciacao
			aAdd(aConfig,	{"01|02|03|04|05|06|07|11"	,"1|"		,"1|7"		})
			aAdd(aConfig,	{"09|08"						,"1|"		,"1|"		})
			aAdd(aConfig,	{"41|42|43"						,"1|"		,"1|"		})

			Case cPaisLoc == "ARG"
			//			  			|Tipo Ativo						|Tipo Saldo	|Metodo Depreciacao
			aAdd(aConfig,	{"01|02|03|04|05|06|07|11"	,"1|"		,"1|7|8|9"	})
			aAdd(aConfig,	{"09|08"						,"1|"		,"1|"		})
			aAdd(aConfig,	{"10|12|14|15|13"					,"*"		,"*"		})

			Case cPaisLoc == "BOL"
			fvldTipAct(@aConfig)

			Case cPaisLoc == "COL"
			//			  			|Tipo Ativo						|Tipo Saldo	|Metodo Depreciacao
			aAdd(aConfig,	{"01|02|03|04|05|06|07|11"	,"1|"		,"1|7"		})
			aAdd(aConfig,	{"09|08"						,"1|"		,"1|"		})
			aAdd(aConfig,	{"50|51|52|53|54"				,"1|"		,"1|"		})

			Case cPaisLoc == "COS"
			//			  			|Tipo Ativo						|Tipo Saldo	|Metodo Depreciacao
			aAdd(aConfig,	{"01|02|03|04|05|06|07|11"	,"1|"		,"1|3|6|7"	})
			aAdd(aConfig,	{"09|08"						,"1|"		,"1|"		})

			Case cPaisLoc == "PTG"
			//			  			|Tipo Ativo						|Tipo Saldo	|Metodo Depreciacao
			aAdd(aConfig,	{"01|02|03|04|05|06|07|11"	,"1|"		,"1|7|B"	})
			aAdd(aConfig,	{"09|08"						,"1|"		,"1|"		})
			aAdd(aConfig,	{"33"							,"1|"		,"1|7|B"	})

			Case cPaisLoc == "BRA"
			//			  			|Tipo Ativo						|Tipo Saldo	|Metodo Depreciacao
			aAdd(aConfig,	{"01|02|03|04|05|06|07|11"	,"1|"		,"1|7|8"	})
			aAdd(aConfig,	{"09|08"						,"1|"		,"1|"		})

			Case cPaisLoc == "RUS"
			// CAZARINI - 10/03/2017 - add new valuations type
			aConfig[1][1] 	:= aConfig[1][1] + '|' + AtfNValMod({1,2,3,4},'|')  

	//			  			|Tipo Ativo						|Tipo Saldo	|Metodo Depreciacao
			aAdd(aConfig,	{"01|02|03|04|05|06|07|11"		,"*"		,"1|2|N|F"	})
			aAdd(aConfig,	{"09|08"						,"1|"		,"1|"		})
			OtherWise
			//			  			|Tipo Ativo						|Tipo Saldo	|Metodo Depreciacao
			aAdd(aConfig,	{"01|02|03|04|05|06|07|11"	,"1|"		,"1|7"		})
			aAdd(aConfig,	{"09|08"						,"1|"		,"1|"		})

		EndCase

		If __lATF012SAL      //se existe PE ATF012SAL
			aAux := ExecBlock("ATF012SAL",.F.,.F.,{aConfig})
			If ValType(aAux) == "A" .And. Len(aAux) > 0
				aConfig := aClone(aAux)
			EndIf
		EndIf

		nPosConfig := aSCan(aConfig,{|aX| AllTrim(cTipo) $ aX[1]})

		If nPosConfig != 0

			//����������������������Ŀ
			//�Valida Tipo de Saldo	 �
			//������������������������
			
			If !Empty(cTpSald) .and. aConfig[nPosConfig,2] != "*" // * = Todos Permitidos
				If !(cTpSald $ aConfig[nPosConfig,2])
					lRet := .F.
					Help(" ",1,"ATFNOTPSALDO",,STR0002,1,0)    //"Tipo de saldo invalido para o tipo de ativo em questao"
				EndIf

			ElseIf !Empty(cTpSald)
				aArea 	:= GetArea()
				aAreaGen := SX5->(GetArea())
				DbSelectArea("SX5")
				SX5->(dbSetOrder(1))
				SX5->(MsSeek(xFilial("SX5")+"SL"))
				Do While !SX5->(EOF()) .and. xFilial("SX5")+"SL" == SX5->X5_FILIAL+SX5->X5_TABELA
					cAllTipos += IiF(Empty(cAllTipos),'','|')+ALLTRIM(SX5->X5_CHAVE)
					SX5->(DbSkip())
				EndDo
				SX5->(RestArea(aAreaGen))
				RestArea(aArea)
				If !(cTpSald $ cAllTipos)
					lRet := .F.
					Help(" ",1,"ATFNOTPSALDO",,STR0002,1,0)    //"Tipo de saldo invalido para o tipo de ativo em questao"
				EndIf
			EndIf

			//������������������������������Ŀ
			//�Valida Metodo de depreciacao	 �
			//��������������������������������
			If  !Empty(cTpDepr) .and. aConfig[nPosConfig,3] !=	 "*" .and. lRet
				If !(cTpDepr $ aConfig[nPosConfig,3])
					lRet := .F.
					Help(" ",1,"ATFNOTPDEPR",,STR0003,1,0) //"Metodo de depreciacao invalido para o tipo de ativo em questao"
				EndIf
			ElseIf !Empty(cTpDepr)
				aAreaGen	:= {}
				cAllTipos	:= ""
				aArea 		:= GetArea()
				aAreaGen 	:= SN0->(GetArea())

				DbSelectArea("SN0")
				SN0->(dbSetOrder(1))
				SN0->(MsSeek(xFilial("SN0")+"04"))
				Do While !SN0->(EOF()) .and. xFilial("SN0")+"04" == SN0->N0_FILIAL+SN0->N0_TABELA
					cAllTipos += IiF(Empty(cAllTipos),'','|')+ALLTRIM(SN0->N0_CHAVE)
					SN0->(DbSkip())
				EndDo
				SN0->(RestArea(aAreaGen))
				RestArea(aArea)
				If !(cTpDepr $ cAllTipos)
					lRet := .F.
					Help(" ",1,"ATFNOTPDEPR",,STR0003,1,0) //"Metodo de depreciacao invalido para o tipo de ativo em questao"
				EndIf
			EndIf
		Else
			lRet := .F.
			Help(" ",1,"ATFNOTIPOATF",,STR0004,1,0)     //"Tipo de ativo informado inv�lido"
		EndIf
	EndIf
	
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFXVerPrj�Autor  �Alvaro Camillo Neto � Data �  10/27/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se o ativo est� relacionado com um projeto do     ���
���          � imobilizado                                                ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFXVerPrj(cBase,cItem, lHelp)
	
	Local lRet 		:= .F.
	Local aArea	 	:= GetArea()
	Local aAreaSN1	:= SN1->(GetArea())
	Local aAreaFND	:= {}
	Local aAreaFNJ	:= {}
	Local cCodProj	:= ""
	Local cCodRev	:= ""

	Default lHelp := .F.

	If __lStruPrj == Nil
		__lStruPrj := ATFXStruPrj()
	EndIf

	If __lStruPrj .And. !( Alltrim(FunName()) $ "ATFA430/ATFA004/ATFA460" )

		SN1->(DBSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
		If SN1->(MsSeek( xFilial("SN1") + cBase + cItem))

			aAreaFND := FND->(GetArea())

			FND->(DBSetOrder(1)) //FND_FILIAL+FND_CODPRJ+FND_REVIS+FND_ETAPA+FND_ITEM

			If FND->(MsSeek( xFilial("FND") + SN1->(N1_PROJETO + N1_PROJREV + N1_PROJETP + N1_PROJITE) ))
				lRet		:= .T.
				cCodProj	:= SN1->N1_PROJETO
				cCodRev		:= SN1->N1_PROJREV
			EndIf

			RestArea(aAreaFND)

			//-----------------------------------------------------------------------
			// Valida se o ativo esta relacionado ao projeto como Ativos de Execucao
			//-----------------------------------------------------------------------
			aAreaFNJ := FNJ->(GetArea())

			FNJ->(DbSetOrder(3)) //FNJ_FILIAL+FNJ_CBAEXE+FNJ_ITEXE+FNJ_TAFEXE+FNJ_SLDEXE+FNJ_CODPRJ+FNJ_REVIS+FNJ_ETAPA+FNJ_ITEM+FNJ_LINHA+FNJ_TAFPRJ+FNJ_SLDPRJ
			If FNJ->(DbSeek( XFilial("FNJ") + SN1->(N1_CBASE+N1_ITEM)))
				lRet		:= .T.
				cCodProj	:= FNJ->FNJ_CODPRJ
				cCodRev		:= FNJ->FNJ_REVIS
			EndIf

			RestArea(aAreaFNJ)

		EndIf

	EndIf

	If lRet .And. lHelp
		Help(" ",1,"ATFPROJ",,STR0005 + cCodProj  + STR0006 + cCodRev + STR0007 ,1,0) //"Esse ativo est� relacionado com o projeto : "##"  revis�o:"##", por favor utilizar a rotina de Projeto Imobilizado para a manuten��o "
	EndIf

	RestArea(aAreaSN1)
	RestArea(aArea)
	
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFXStruPrj�Autor  �Alvaro Camillo Neto � Data �  25/07/12  ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica se o ativo est� relacionado com um projeto do     ���
���          � imobilizado                                                ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFXStruPrj()

	Local lRet := .T.

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFValInd   �Autor  �Renan Guedes      � Data �  11/04/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida a exist�ncia de uma taxa para o �ndice do bem        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFValInd(lBlind)

	Local lRet			:= .F.
	Local aTxDepr		:= {0,0,0,0,0}
	Local nX			:= 0

	Default lBlind		:= .F.

	If ValType(lBlind) != "L"
		lBlind := .F.
	EndIf

	ATFCalcIn(@aTxDepr)

	For nX := 1 To Len(aTxDepr)
		If aTxDepr[nX] > 0
			lRet := .T.
		EndIf
	Next nX

	If !lRet
		If !lBlind
			Help("",1,"ATFNOTAXIN")		//"N�o existe(m) taxa(s) v�lida(s) para o �ndice e per�odo da deprecia��o."##"Cadastre a(s) taxa(s) para o �ndice e per�odo a depreciar."
		EndIf
	EndIf

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AtClssVer� Autor � Marylly A. Silva   � Data �  29/05/2012 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que avalia o conte�do do campo "Classifica��o" do   ���
���          � ativo e verifica��o se a classifica��o � do tipo que sofre ���
���          � deprecia��o ou n�o						                  ���
�������������������������������������������������������������������������͹��
���Uso       � Ativo Fixo                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function AtClssVer(cClassif)

	Local lRet		:= .F.
	Local cTpDepr	:= " |N|D|I|O|T|E"
	Local cTpNDepr	:= "S|A|C|P|R"
	Local lAtClssVer

	/*
	* cClassif
	* "N" -> Ativo Imobilizado
	* "S" -> Patrim�nio L�quido
	* "A" -> Amortiza��o
	* "C" -> Capital Social
	* "P" -> Patrim�nio (Preju�zo)
	* "I" -> Ativo Intang�vel
	* "D" -> Ativo Diferido
	* "O" -> Or�amento
	* "V" -> Provis�o
	* "T" -> Custos de Transa��o
	*/
	If cClassif != Nil
		// Ponto de entrada exclusivo para relat�rio ATFR110
		If FunName() == "ATFR110"
			If ExistBlock("AFCLDEPR")
				lAtClssVer := ExecBlock("AFCLDEPR",.F.,.F.,{cClassif})
			EndIf
		EndIf
		// Se n�o passar pelo PE, executa tratamento padr�o
		If lAtClssVer == Nil
			// Classifica��es de Bens que sofrem o processo de deprecia��o
			If cClassif $ cTpDepr
				lRet := .T. // Sim, deprecia
				// Classifica��o de Bens que N�O sofrem o processo de deprecia��o
			ElseIf cClassif $ cTpNDepr
				lRet := .F. // N�o, N�O deprecia
			EndIf
		Else
			lRet := lAtClssVer
		EndIf
	EndIf

Return (lRet)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � AFVldBpi   �Autor  �Mauricio Pequim Jr     � Data � 24/07/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a implementacao da Baixa de Provisao de Imobilizados  ���
���������������������������������������������������������������������������Ĵ��
���Uso       � ATFA010                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
//BPI
Function AFVldBpi()

	If __lBpiAtf == NIL
		__lBpiAtf := ATFXStruPrj()
	Endif

Return __lBpiAtf

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � FaVRelPrj  �Autor  �Mauricio Pequim Jr     � Data � 24/07/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica o relacionamento do imobilizado a um processo de    ���
���          � execucao de provisao de projeto                              ���
���������������������������������������������������������������������������Ĵ��
���Uso       � ATFA010                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
//BPI
Function FaVRelPrj(nIndice,cChave)

	Local lRet := .F.
	Local aAreaFNJ := FNJ->(GetArea())

	DEFAULT nIndice := 1
	DEFAULT cChave := ""

	FNJ->(dbSetOrder(nIndice))
	If FNJ->(MsSeek(cChave))
		lRet := .T.
	Endif

	RestArea(aAreaFNJ)

Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � AFMrgAtf   � Autor � Mauricio Pequim Jr    � Data � 10/09/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida existencia das informacoes necessarias para Margem    ���
���          � Gerencial na base Ativo Fixo 			 	                ���
���������������������������������������������������������������������������Ĵ��
���Utilizacao� AFMrgAtf ()						                            ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
//MRG
Function AFMrgAtf()

	Local lDefTop 	:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)

	If __lMargem == NIL

		If lDefTop
			__lMargem := .T.
		Else
			__lMargem := .F.
		Endif
	Endif

Return __lMargem

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �AFVerTp15 � Autor � Mauricio Pequim Jr.   � Data � 11/09/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se existe tipo 15 ativo                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AFVerTp15(cCBase,cItem,cTpSaldo)							  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC01= Codigo base do bem                                 ���
���          � ExpC02= Item do bem              			              ���
���          � ExpC03= Tipo do saldo do tipo de bem                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
//MRG
*/
Function AFVerTp15(cCBase,cItem,cTpSaldo)

	Local aArea		:= GetArea()
	Local aAreaSN3	:= SN3->(GetArea())
	Local nRecSN3	:= SN3->(RECNO())
	Local lRet		:= .F.

	DEFAULT cCbase := ""
	DEFAULT cItem	:= ""
	DEFAULT cTpSaldo := ""

	dbSelectArea("SN3")
	SN3->(DBSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO
	If SN3->(MsSeek( xFilial("SN3")+cCBase+cItem+"15"+"0"+cTpSaldo ))
		lRet := .T.
	Endif

	RestArea(aAreaSN3)
	RestArea(aArea)

	SN3->(dbGoTo(nRecSN3))

Return lRet

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � AfVerTp10   � Autor � Mauricio Pequim Jr. � Data � 04/09/12 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Verifica a existencia de um tipo 10 baixado junto com um    ���
���          � tipo 15 na mesma data e processo de baixa                   ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � ATFA030/035                                                 ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cBase     = Codigo base do bem					           ���
���          � cItem     = Item do bem			                           ���
���          � cTipoSld  = Tipo de saldo do bem tipo 15      		       ���
���          � dDataBx   = data da baixa do bem tipo 15                    ���
���          � cIdMovSN4 = Id do movimento do SN4            		       ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
//MRG
Function AfVerTp10(cBase,cItem,cTipoSld,dDataBx,cIdMovSN4)

	Local lRet 		:= .F.
	Local cQuery 	:= ""
	Local aArea		:= GetArea()
	Local cAliasQry := "CHKTP1015"
	Local cTypes10	:= IIF(lIsRussia,"|" + AtfNValMod({1}, "|"),"") // CAZARINI - 30/03/2017 - If is Russia, add new valuations models - main models
	Local cTypes	:= "10|13" + cTypes10

	cQuery := " SELECT COUNT(*) SN4MARGEM "
	cQuery += " FROM " + RetSqlName("SN4") + " SN4 "
	cQuery += " WHERE SN4.N4_FILIAL  = '" + xFilial("SN4") + "' AND "
	cQuery += "       SN4.N4_CBASE   = '" + cBase          + "' AND "
	cQuery += "       SN4.N4_ITEM    = '" + cItem          + "' AND "
	cQuery += "       SN4.N4_TPSALDO = '" + cTipoSld       + "' AND "
	cQuery += "       SN4.N4_DATA    = '" + DTOS(dDataBx)  + "' AND "
	cQuery += "       SN4.N4_TIPO IN ('10','13') AND "
	cQuery += "       SN4.N4_OCORR   = '01' AND "
	cQuery += "       SN4.N4_IDMOV   = '" + cIdMovSN4      + "' AND "
	cQuery += "       SN4.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	If (cAliasQry)->SN4MARGEM > 0
		Help(" ",1,"AFVERTP10",, STR0008+CHR(10)+STR0009 ,1,0) //"Este registro de Tipo 15 foi baixado atrav�s de um Tipo 10. Somente ser� possivel cancelar sua baixa atrav�s do Tipo 10."###"Selecione o Tipo 10 e o Tipo 15 ser� selecionado automaticamente para o processo."

		lRet := .T.
	EndIf

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return lRet

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � AFVCustEmp  � Autor � Alvaro Camillo Neto � Data � 04/09/12 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Verifica se o ativo foi gerado a partir de um custo de      ���
���          � emprestimo.                                                 ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Ativo                                                       ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function AFVCustEmp(cBase,cItem,lHelp)
	
	Local lRet    := .F.
	Local aArea   := GetArea()
	Local aAreaSN1:= SN1->(GetArea())

	Default lHelp := .F.


	If !IsInCallStack("ATFA480")
		SN1->(dbSetOrder(1)) // N1_FILIAL + N1_CBASE + N1_ITEM
		If SN1->(MsSeek(xFilial("SN1") + cBase + cItem))
			If SN1->N1_PATRIM == "E" .And. !Empty(SN1->N1_BASESUP) .And. !Empty(SN1->N1_ITEMSUP)
				lRet := .T.
			EndIf

			If lRet .And. lHelp
				Help(" ",1,"AFVCustEmp",, STR0010 ,1,0) //"Ficha Gerada pelo Assistente de Custo de Empr�stimo (ATFA480). Por favor utilizar a op��o Estornar da rotina"
			EndIf

		EndIf
	EndIf

	RestArea(aAreaSN1)
	RestArea(aArea)

Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � AFPrvAtf   � Autor � Mauricio Pequim Jr    � Data � 03/10/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida existencia das informacoes necessarias para Controle  ���
���          � de Provisao na base Ativo Fixo 			 	                ���
���������������������������������������������������������������������������Ĵ��
���Utilizacao� AFPrvAtf ()						                            ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function AFPrvAtf()

	Local lDefTop 	:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)

	If __lProvis == NIL

		If lDefTop
			__lProvis := .T.
		Else
			__lProvis := .F.
		Endif
	Endif

Return __lProvis

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � ATFXPerDepr� Autor � Luis Arturo           � Data � 01/11/16 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Valida el Periodo de Depreciacion.                           ���
���������������������������������������������������������������������������Ĵ��
���Params.   � cPriDiaMes = Primer dia de cada mes					        ���
���          � cUltDiaMes = Ultimo dia de cada mes						    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � A050Calc(), A070CALC() y ATFA080()                           ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function ATFXPerDepr(cPriDiaMes, cUltDiaMes)
	
	Local lRet := .F.
	Local lAuxTipDep := (Alltrim(SuperGetMv("MV_TIPDEPR",.F.,"")) == "4")
	Local lAuxCalDep := (Alltrim(SuperGetMv("MV_CALCDEP",.F.,"")) == "1")
	Local cAuxCalDep := (Alltrim(SuperGetMv("MV_PERDEPR",.F.,"")))
	Local lAuxPerDep := !(Empty(cAuxCalDep))
	Local nPosPipe   := 0

	Default cPriDiaMes := ""
	Default cUltDiaMes := ""

	If lAuxTipDep .And. lAuxCalDep .And. lAuxPerDep
		lRet        := .T.
		nPosPipe    := At( "|" , cAuxCalDep )
		cPriDiaMes  := Replace(Substr( cAuxCalDep, 1, nPosPipe - 1 ), "/", "")
		cUltDiaMes  := Replace(Substr( cAuxCalDep, nPosPipe + 1, Len(cAuxCalDep) ), "/", "")
	EndIf

Return (lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AF010AVTIP�Autor  �Alvaro Camillo Neto � Data �  31/01/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida��o do campo When do campo N3_TIPDEPR                 ���
���          � Movida a partir do ATFA010A em 22/08/2017                  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AF010AVTIP(cTpDepr,nLinha)
Local lRet 			:= .F.
Local nPosN3Tipo 	:= Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TIPO" } )
Local nPosN3TpDp 	:= Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TPDEPR" } )
Local aPosN3TxDp	:= If(lMultMoed, AtfMultPos(aHeader,"N3_TXDEPR")				,;
{	Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TXDEPR1" } )	,;
Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TXDEPR2" } )	,;
Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TXDEPR3" } )	,;
Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TXDEPR4" } )	,;
Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TXDEPR5" } ) 	})
Local cTipoGer   	:= ''
Local aArea			:= {}
Local aAreaSN0		:= {}
Local nPosTp01		:= 0
Local nI			:= 0
Local cTypes10		:= IIF(lIsRussia,"/" + AtfNValMod({1}, "/"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - main models
Local cTypes12		:= IIF(lIsRussia,"/" + AtfNValMod({2}, "/"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - recoverable models

DEFAULT cTpDepr := IIf(nPosN3TpDp>0, aCols[n][nPosN3TpDp], '')
DEFAULT nLinha := n

If nPosN3Tipo>0 .And. nPosN3TpDp>0
	If FindFunction("ATFSALDEPR") .and. !(aCols[nLinha][nPosN3Tipo] $ '|11')
		lRet := ATFSALDEPR(aCols[nLinha][nPosN3Tipo],,IiF("N3_TPDEPR" $ ReadVar(),&(ReadVar()),aCols[nLinha][nPosN3TpDp]))
	Else
		If aCols[nLinha][nPosN3Tipo] $ '01,02'
			cTipoGer := '1,7,8,9'
			If !(cPaisLoc $ "ARG|BRA|COS")
				If nLinha == 1
					aCols[nLinha][nPosN3TpDp] := '1'
					cTpDepr := '1'
				Endif
			EndIf
		ElseIf aCols[nLinha][nPosN3Tipo] $ ('10/12' + cTypes10 + cTypes12)
			aArea := GetArea()
			aAreaSN0 := SN0->(GetArea())
			
			dbSelectArea("SN0")
			
			SN0->(dbSetOrder(1))
			SN0->( MsSeek( xFilial("SN0") + '04' ) )
			
			Do While !SN0->(Eof()) .And. xFilial("SN0") + '04' == SN0->N0_FILIAL + SN0->N0_TABELA
				cTipoGer += IIf(empty(cTipoGer),'',',') + SN0->N0_CHAVE
				SN0->(dbSkip())
			EndDo
			
			RestArea(aAreaSN0)
			RestArea(aArea)
		ElseIf aCols[nLinha][nPosN3Tipo] $ '|11'
			nPosTp01	:= aScan(aCols,{|aX| aX[nPosN3Tipo] $ "01"})
			If nPosTp01 > 0
				cTipoGer	:= aCols[nPosTp01][nPosN3TpDp]
			EndIf
		Else
			cTipoGer := '1'
		EndIf
		lRet := cTpDepr $ cTipoGer
		If !lRet
			If aCols[nLinha][nPosN3Tipo] == '11'
				Help(" ",1,"AF010AVTIP",,I18N(STR0011,{AllTrim(RetTitle("N3_TPDEPR"))}),1,0) //'A altera��o do campo "#1[Tipo deprec.]#" da amplia��o deve ocorrer por meio do tipo de ativo "Deprecia��o Fiscal".'
			Else
				Help( " ", 1, "AF010TIPDEP",, STR0012, 1, 0 ) // "Esse m�todo de deprecia��o n�o � v�lido para esse tipo de ativo."
			EndIf
		EndIf
	EndIf
EndIf

If lRet .and. aCols[nLinha][nPosN3Tipo] == '01'
	For nI := 1 To Len(aCols)
		If aCols[nI,nPosN3Tipo] == "11"
			aCols[nI,nPosN3TpDp]	:= cTpDepr
		EndIf
	Next nI
	If (Type('lAtfAuto') == "U" .Or. ! lAtfAuto) .And. Type("__oGet") == "O"
		__oGet:Refresh()
	EndIf
EndIf

If lRet .And. (aCols[nLinha][nPosN3Tipo] $ ('10' + cTypes10) ) .And. (cTpDepr == 'A')
	For nI := 1 To Len(aPosN3TxDp)
		aCols[nLinha,aPosN3TxDp[nI]] := 0
	Next nI
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}ATFAdjFil

Ajusta express�o de filtro dos relat�rios customiz�veis (TReport) 
para efetuar a macro execu��o na varredura do arquivo que se deseja
filtrar

Example:	ATFAdjFilExp( @cFilterUser )	
			
@param		cFilterUser	= caractere, express�o que ser� ajustada para filtro
@return		nil
@author		Fernando Radu Muscalu
@since		09/08/2018
@version	12
/*/
//-------------------------------------------------------------------
Function ATFAdjFil(cFilterUser,lQuery)

Local cExp 	:= cFilterUser
Local cAux	:= ""

Local nI	:= 0

Default lQuery := .f.

cExp := StrTran(cFilterUser,"#","")

If ( At("FWMNTFIL",Upper(cExp)) > 0 )
	cExp := &(cExp)
EndIf

cExp := StrTran(cExp,chr(34),chr(39))

If ( lQuery )
	
	cExp := StrTran(cExp,"=="," = ")
	cExp := StrTran(Lower(cExp),".or."," OR ")
	cExp := StrTran(Lower(cExp),".and."," AND ")
	cExp := StrTran(Upper(cExp),"DTOS(", space(1))
	cExp := StrTran(cExp,")", space(1))
	cExp := StrTran(Upper(cExp),".T.", "T")
	cExp := StrTran(Upper(cExp),".F.", "F")

EndIf

cFilterUser := cExp


Return()
//-------------------------------------------------------------------
/*/{Protheus.doc}ATFNValMod
	Function used only for location Russia
	Function Moved to source code RU01XFUN_GENFUN 
	This call should be removed in next release./*/
//-------------------------------------------------------------------
Function ATFNValMod(aType, cSep)
Return _ATFNValMod(aType,cSep)


//-------------------------------------------------------------------
/*/{Protheus.doc}ATFNValNM
	Function used only for location Russia
	Function Moved to source code RU01XFUN_GENFUN 
	This call should be removed in next release./*/
//-------------------------------------------------------------------
Function ATFNValNM(cType10)
Return 	_ATFNValNM(cType10)
