#INCLUDE "QIEA100.CH" 
#INCLUDE "PROTHEUS.CH"
#DEFINE  K_F4    VK_F4

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIEA100  ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 09/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de funcoes da amarracao Produto X Fornecedor e    ³±±
±±³          ³ Cadastro de Fornecedores                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ STR      ³ Ultimo utilizado -> 0011                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paulo Emidio³15/09/00³META  ³Implementacao do Plano de Amostragem por  ³±±
±±³            ³        ³      ³Ensaios                                   ³±±
±±³Paulo Emidio³12/02/01³008009³Retirada da chamada da funcao Qea330aCol()³±±
±±³            ³        ³      ³na aA100WhSi(), para que o aCols nao seja ³±±
±±³            ³        ³      ³remontado, quando alterada a situacao do  ³±±
±±³            ³        ³      ³Fornecedor. 							  ³±±
±±³Paulo Emidio³08/05/01³META  ³Implementacao do parametro MV_UTSK25, que ³±±
±±³            ³        ³      ³indica se o Skip-Lote de 25% sera aplicado³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIEA100


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A100VlSi ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 09/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Situacao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A100VlSi()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Cad. Prod X Fornecedor X3_VALID do A5_SITU                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A100VlSi()
Local lRetu      := .t.
Local cVar  	 := &(ReadVar())
Local lVerIQSQua := .F.
Local nMvIQSQua  := GetMv("MV_QIQSQUA")
Local nRecQEG                                                               
Local nMvIQSAss  := GetMv("MV_QIQSASS") //IQS minimo para Situacao Assegurado
Local lSkpLteAss := If(GetMv("MV_QASSIQS")=="S",.T.,.F.) 
Local oModel	 := FWModelActive()
Local oField	 := NIL
Local oGrid		 := NIL
Local l060MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "MATA061"

If l060MVC
	oField := oModel:GetModel("MdFieldSA5")
	oGrid  := oModel:GetModel("MdGridSA5")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Situacao est  cadastrada                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cVar := UPPER(cVar)
If ! ExistCpo("QEG",cVar)
	lRetu := .f.
EndIf

If lRetu

	// Identifica a Categoria da Situacao
	QEG->(dbSetOrder(1))
	QEG->(dbSeek(xFilial("QEG")+cVar))

	// Localiza o Fornecedor
	SA2->(dbSetOrder(1))
	If l060MVC
		SA2->(dbSeek(xFilial("SA2")+oGrid:GetValue("A5_FORNECE")+oGrid:GetValue("A5_LOJA")))
	Else
		SA2->(dbSeek(xFilial("SA2")+M->A5_FORNECE+M->A5_LOJA))
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Situacao pode ser Skip-Lote Total              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QEG->QEG_CATEG == "1" .And. (SA2->A2_FATAVA == 0 .Or. Empty(SA2->A2_DTAVA))
		If !lSkpLteAss					// "Fornecedor pode ser Skip-Lote Total sem IQS"
			Help(" ",1,"A100ASSIQS")	// "Situacao nao permitida: Fornecedor nao possui IQS"
			lRetu := .f.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Situacao pode ser Skip-Lote 25%                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetu
		// Verifica se existe Situacao c/ Categoria "3" - Sem Skip-Lote
		nRecQEG := QEG->(Recno())
		QEG->(dbSetOrder(1))
		QEG->(dbSeek(xFilial("QEG")))
		While QEG->QEG_FILIAL == xFilial("QEG") .And. !QEG->(Eof())
			If QEG->QEG_CATEG == "3"
				lVerIQSQua := .T.
				Exit
			EndIf
			QEG->(dbSkip())
		EndDo
		QEG->(dbGoTo(nRecQEG))

		If QEG->QEG_CATEG == "1" .And. nMvIQSAss > 0	// "IQS minimo p/ Assegurado"
			If (SA2->A2_FATAVA < nMvIQSAss) .And. !lSkpLteAss
				Help(" ",1,"A100IQSASS") // "Nota IQS menor que a minima para esta Situacao"
				lRetu := .f.
			EndIf
		EndIf
		If lVerIQSQua .And. ;
				QEG->QEG_CATEG == "2" .And. nMvIQSQua > 0	// "IQS minimo p/ Qualificado"
			If ( Empty(SA2->A2_FATAVA) .And. Empty(SA2->A2_DTAVA) ) .Or. ;
				( !Empty(SA2->A2_FATAVA) .And. SA2->A2_FATAVA < nMvIQSQua )
				Help(" ",1,"A100IQSQUA")	// "Nota IQS menor que a minima para esta Situacao"
				lRetu := .f.
			EndIf
		EndIf
	EndIf
EndIf

If l060MVC
	oGrid:LoadValue("A5_SITU",cVar)
Else
	M->A5_SITU := cVar
EndIf

Return(lRetu)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A100VlSL ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 13/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Skip-Lote                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A100VlSL()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Cad. Prod X Fornecedor X3_VALID do A5_SKPLOT               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A100VlSL()
Local lRetu := .t.
Local cVar := &(ReadVar())	// Campo Skip-Lote   
Local cMvUtSk25 := GetMv("MV_QUTSK25")// Define se sera utilizado o Skip-Lote de 25%
Local oModel	 := FWModelActive()
Local oField	 := NIL
Local oGrid		 := NIL
Local l060MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "MATA061"

If l060MVC
	oField := oModel:GetModel("MdFieldSA5")
	oGrid  := oModel:GetModel("MdGridSA5")
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Skip-Lote est  cadastrado                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cVar)
	If ! ExistCpo("QEF",cVar)
		lRetu := .f.
	EndIf
EndIf	

If lRetu
	// Identifica a Categoria da Situacao
	QEG->(dbSetOrder(1))
	If l060MVC		
		QEG->(dbSeek(xFilial("QEG")+oGrid:GetValue("A5_SITU")))
	Else	
		QEG->(dbSeek(xFilial("QEG")+M->A5_SITU))
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a categoria Situacao ‚ Skip-Lote 25%             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QEG->QEG_CATEG == "2"
		QEF->(dbSetOrder(1))
		QEF->(dbSeek(xFilial("QEF")+cVar))
		If QEF->QEF_UNSKLT == "E"	// Skip-Lote por Entradas
			If cMvUtSk25 == "S"
			If QEF->QEF_QTDE > 4
				Help(" ",1,"A100SKLINV")	// "Skip-Lote n„o permitido para a Situa‡„o"
				lRetu := .f.
				EndIf              
			EndIf
		ElseIf QEF->QEF_UNSKLT <> "L"	// Skip-Lote por Documento Entrada
			Help(" ",1,"A100SKLINV")	// "Skip-Lote n„o permitido para a Situa‡„o"
			lRetu := .f.
		EndIf
	EndIf
EndIf

Return(lRetu)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A100VlTL ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 14/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida campo Tempo Limite                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A100VlTL()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Cad. Prod X Fornecedor X3_VALID do A5_TEMPLIM              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A100VlTL()
Local lRetu := .t., nPosTL,;
		cVar := &(ReadVar())	// Campo Tempo Limite
Local oModel	 := FWModelActive()
Local oField	 := NIL
Local oGrid		 := NIL
Local l060MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "MATA061"

If l060MVC
	oModel	  := FWModelActive()
	oField 	  := oModel:GetModel("MdFieldSA5")
	oGrid	  := oModel:GetModel("MdGridSA5")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o Skip-Lote definido e se o fonte MATA060 está em MVC  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l060MVC
	If !Empty(oGrid:GetValue("A5_SKPLOT"))
		QEF->(dbSetOrder(1))
		QEF->(dbSeek(xFilial("QEF")+oGrid:GetValue("A5_SKPLOT")))
		If QEF->QEF_UNSKLT == "D"	// Skip-Lote por Dia
			If oGrid:GetValue("A5_TEMPLIM") <= (QEF->QEF_QTDE / 30)	// Tempo Lim. ‚ em meses e skip-lote em dias
				// Somente avisa
				Help(" ",1,"A100TLMAIO")	// "Tempo limite deveria ser maior que o Skip-Lote"
			EndIf
		EndIf
	Endif

	If Type("aGets")=="A"
		// Atualiza M e aTela pq. o Help exibe na tela o valor anterior
		oGrid:LoadValue("A5_TEMPLIM",cVar)
		nPosTL := Ascan(aGets,{ |x| Subs(x,9,10) == "A5_TEMPLIM" } )
		If nPosTL > 0
			aTela[Val(Subs(aGets[nPosTL],1,2))][Val(Subs(aGets[nPosTL],3,1))*2] := oGrid:GetValue("A5_TEMPLIM")
		EndIf
	EndIf
Else
	If !Empty(M->A5_SKPLOT)
		QEF->(dbSetOrder(1))
		QEF->(dbSeek(xFilial("QEF")+M->A5_SKPLOT))
		If QEF->QEF_UNSKLT == "D"	// Skip-Lote por Dia
			If M->A5_TEMPLIM <= (QEF->QEF_QTDE / 30)	// Tempo Lim. ‚ em meses e skip-lote em dias
				// Somente avisa
				Help(" ",1,"A100TLMAIO")	// "Tempo limite deveria ser maior que o Skip-Lote"
			EndIf
		EndIf
	EndIf

	If Type("aGets")=="A"
		// Atualiza M e aTela pq. o Help exibe na tela o valor anterior
		M->A5_TEMPLIM := cVar
		nPosTL := Ascan(aGets,{ |x| Subs(x,9,10) == "A5_TEMPLIM" } )
		If nPosTL > 0
			aTela[Val(Subs(aGets[nPosTL],1,2))][Val(Subs(aGets[nPosTL],3,1))*2] := M->A5_TEMPLIM
		EndIf
	EndIf
EndIf

Return(lRetu)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A100WhSi ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 09/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Def. a clausula WHEN para o campo Situacao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A100WhSi()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Cad. Prod X Fornecedor X3_WHEN do A5_SITU                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A100WhSi()
Local lRetu := .T.
Local oModel	 := FWModelActive()
Local oField	 := NIL
Local oGrid		 := NIL
Local l060MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "MATA061"

If l060MVC
	oModel		  := FWModelActive()
	oField  	  := oModel:GetModel("MdFieldSA5")
	oGrid		  := oModel:GetModel("MdGridSA5")
Endif

If ReadVar() == "M->A5_SITU"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se digitou o Produto e o Fornecedor                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l060MVC
		If Empty(oGrid:GetValue("A5_FORNECE")) .Or. Empty(oField:GetValue("A5_PRODUTO")) .Or. Empty(oGrid:GetValue("A5_LOJA"))
			Help(" ",1,"A100VAZPRF")	// "Informe primeiramente o Produto e o Fornecedor"
			lRetu := .F.
		EndIf
	Else
		If Empty(M->A5_FORNECE) .Or. Empty(M->A5_PRODUTO) .Or. Empty(M->A5_LOJA)
			Help(" ",1,"A100VAZPRF")	// "Informe primeiramente o Produto e o Fornecedor"
			lRetu := .F.
		EndIf
	Endif
	If lRetu
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ativa tecla F4 para visualizar o Historico               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SetKey(K_F4, {|a,b,c| A100Choi(a,b,c) } )
	EndIf
EndIf

Return(lRetu)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A100WhSL ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 09/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Def. a clausula WHEN para o campo Skip-Lote                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A100WhSL()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Cad. Prod X Fornecedor X3_WHEN do A5_SKPLOT                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A100WhSL()
Local lRetu	  := .T. 
Local oModel	 := FWModelActive()
Local oField	 := NIL
Local oGrid		 := NIL
Local l060MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "MATA061"

If l060MVC
	oModel		  := FWModelActive()
	oField  	  := oModel:GetModel("MdFieldSA5")
	oGrid		  := oModel:GetModel("MdGridSA5")
Endif

If ReadVar() == "M->A5_SKPLOT"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se digitou a Situacao                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l060MVC
		If Empty(oGrid:GetValue("A5_SITU"))
			Help(" ",1,"A100VAZSIT")	// "Informe primeiramente a Situacao"
			lRetu := .f.
		EndIf
	Else
		If Empty(M->A5_SITU)
			Help(" ",1,"A100VAZSIT")	// "Informe primeiramente a Situacao"
			lRetu := .f.
		EndIf
	Endif	
	If lRetu
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Categoria da Situacao Sem Skip-Lote/Nao Recebe: nao digita   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Identifica a Categoria da Situacao
		If l060MVC
			QEG->(dbSetOrder(1))
			QEG->(dbSeek(xFilial("QEG")+oGrid:GetValue("A5_SITU")))
		Else
			QEG->(dbSetOrder(1))
			QEG->(dbSeek(xFilial("QEG")+M->A5_SITU))
		Endif

		If l060MVC
			If QEG->QEG_CATEG $ "3.4"
				oGrid:LoadValue("A5_SKPLOT",Space(TamSx3("A5_SKPLOT")[1]))
				lRetu := .f.
			EndIf
		Else
			If QEG->QEG_CATEG $ "3.4"
				M->A5_SKPLOT:= Space(TamSx3("A5_SKPLOT")[1])
				lRetu := .f.
			EndIf
		Endif
	EndIf
	If lRetu
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ativa tecla F4 para visualizar o Historico               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SetKey(K_F4, {|a,b,c| A100Choi(a,b,c) } )
	EndIf
EndIf
Return(lRetu)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A100WhTL ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 02/02/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Def. a clausula WHEN p/ Tempo Limite s/ Entradas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A100WhTL()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Cad. Prod X Fornecedor X3_WHEN do A5_TEMPLIM               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A100WhTL()
Local lRetu := .T.
Return(lRetu)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A100Choi ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³11/18/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta opcao para escolha do Historico/Consulta de Ensaios  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA100 (Utilizado na Amarr. ProdutoXFornecedor)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Str       ³ Ultimo Utilizado -> 0010                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A100Choi( cAlias, nReg, nOpcX )

A100Hist(cAlias,nReg,nOpcX)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A100Hist ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 13/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra o Historico da Situacao do Produto/Fornecedor       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A100Hist()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIEA100 - Acionada a partir de F4 nos cpos Situacao, Skip- ³±±
±±³          ³           Lote e Planos de Amostragem                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A100Hist()
Local cChvHis  := ""
Local cVar     := ReadVar()
Local cTit     := ""
Local cEspecie := ""
Local oDlg 
Local oListBox
Local aHist := {}
Local cAnt	:= ""

// Define a Especie e o Titulo do Historico
If cVar == "M->A5_SITU"	// Situacao
	cEspecie := "MATA060T"
	cTit		:= OemToAnsi(STR0002)	// "   Hist¢rico Situa‡„o    	"
ElseIf cVar == "M->A5_SKPLOT"	// Skip-Lote
	cEspecie := "MATA060L"
	cTit		:= OemToAnsi(STR0003)	// "   Hist¢rico Skip-Lote   "

EndIf

If !Empty(cEspecie)
	// Obtem chave para o Historico/Justificativa
	cChvHis := SA5->A5_CHAVE

  	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta vetor com o Historico ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QA3")
	QA3->(dbSetOrder(1))
	dbSeek(xFilial("QA3")+cEspecie+cChvHis)

	While ( !QA3->(Eof()) .And. xFilial("QA3") == QA3->QA3_FILIAL .And.;
				QA3->QA3_ESPEC == cEspecie .And. ;
				QA3->QA3_CHAVE == cChvHis )

		// Se for Situacao ou Skip-Lote, mostra a descricao
		If cVar == "M->A5_SITU"	// Situacao
			QEG->(dbSetOrder(1))
			QEG->(dbSeek(xFilial("QEG")+Left(QA3->QA3_ANT,TamSX3("QEG_SITU")[1])))
			cAnt := QEG->QEG_NIVEL
		Elseif  cVar == "M->A5_SKPLOT"	// Skip-Lote
			QEF->(dbSetOrder(1))
			QEF->(dbSeek(xFilial("QEF")+Left(QA3->QA3_ANT,TamSX3("QEF_SKPLOT")[1])))
			cAnt := QEF->QEF_DESCRI
		Else
			cAnt := QA3->QA3_ANT
		EndIf

		Aadd(aHist, { cAnt, QA3->QA3_TEXTO, QA3->QA3_DATA })
      QA3->(dbSkip())
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se h  historico a ser exibido                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aHist)
		Help(" ",1,"A100NAOHIS")	// "Nao h  Historico registrado"
	Else
		DEFINE MSDIALOG oDlg FROM  18,16 TO 246,561 TITLE cTit PIXEL

		@ 0.3,0.3 LISTBOX oListBox FIELDS HEADER TitSX3("QA3_ANT")[1] ,;
														 TitSX3("QA3_TEXTO")[1],;
														 TitSX3("QA3_DATA")[1];
														 SIZE 240,100 OF oDlg
		oListBox:SetArray( aHist )
		oListBox:bLine := { || {aHist[oListBox:nAT,1],aHist[oListBox:nAT,2],Dtoc(aHist[oListBox:nAT,3])}}

		DEFINE SBUTTON FROM 05, 243 TYPE 1 ENABLE OF oDlg Action (oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTERED
	Endif
EndIf
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A100CoEn ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³11/18/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta os ensaios do Produto com seus respectivos Planos ³±±
±±³          ³ de Amostragem.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QIEA100 - A100Choi - Acionada pelo F4 nos campos Plano Amo.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A100CoEn( )
Local oDlg 
local oListBox
Local cRevi
Local aEnsa	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica a revisao do Produto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cRevi := QA_UltRevEsp(M->A5_PRODUTO,dDataBase,.T.,,"QIE")

If Empty(cRevi)	// Nao ha revisao disponivel
	Return(NIL)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta vetor com os ensaios do Produto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE7->(dbSetOrder(1))
QE7->(dbSeek(xFilial("QE7")+M->A5_PRODUTO+cRevi))
While !QE7->(Eof()) .And. QE7->QE7_FILIAL+QE7->QE7_PRODUT+QE7->QE7_REVI == ;
		xFilial("QE7")+M->A5_PRODUTO+cRevi
	If !Empty(QE7->QE7_PLAMO)
		// Busca a descricao do Ensaio
		QE1->(dbSetOrder(1))
		QE1->(dbSeek(xFilial("QE1")+QE7->QE7_ENSAIO))

		Aadd(aEnsa, { QE7->QE7_LABOR,QE7->QE7_ENSAIO,QE1->QE1_DESCPO,QE7->QE7_PLAMO })
	EndIf
	QE7->(dbSkip())
EndDo

QE8->(dbSetOrder(1))
QE8->(dbSeek(xFilial("QE8")+M->A5_PRODUTO+cRevi))
While !QE8->(Eof()) .And. QE8->QE8_FILIAL+QE8->QE8_PRODUT+QE8->QE8_REVI == ;
		xFilial("QE8")+M->A5_PRODUTO+cRevi
	If !Empty(QE8->QE8_PLAMO)
		// Busca a descricao do Ensaio
		QE1->(dbSetOrder(1))
		QE1->(dbSeek(xFilial("QE1")+QE8->QE8_ENSAIO))

		Aadd(aEnsa, { QE8->QE8_LABOR,QE8->QE8_ENSAIO,QE1->QE1_DESCPO,QE8->QE8_PLAMO })
	EndIf
	QE8->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ordena ensaios de acordo com o plano de amostragem ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEnsa := aSort( aEnsa,,, {|x,y| x[4]+x[1] < y[4]+y[1] } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se h  ensaios a apresentar ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(aEnsa)
	MessageDlg(OemToAnsi(STR0011),,1)	// "N„o há ensaios com Plano de Amostragem associado."
Else
	DEFINE MSDIALOG oDlg FROM  18,16 TO 246,561 TITLE STR0010 PIXEL	// "Consulta Ensaios"

	@ 0.3,0.3 LISTBOX oListBox FIELDS HEADER TitSX3("QE7_LABOR")[1] ,;
													 TitSX3("QE7_ENSAIO")[1],;
													 TitSX3("QE1_DESCPO")[1],;
													 TitSX3("QE7_PLAMO")[1];
													 SIZE 240,100 OF oDlg
	oListBox:SetArray( aEnsa )
	oListBox:bLine := { || {aEnsa[oListBox:nAT,1],aEnsa[oListBox:nAT,2],;
								aEnsa[oListBox:nAT,3],aEnsa[oListBox:nAT,4] }}

	DEFINE SBUTTON FROM 05, 243 TYPE 1 ENABLE OF oDlg Action (oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED
Endif
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A060F3SL  ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³12/08/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta consulta de Skip-Lote via SXB especifica              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Consulta especifica                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³QIEA100.PRX                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A060F3SL()
Local lSitQua	:= .F.
Local lRet		:= .T.
Local cMvUtSk25 := GetMv("MV_QUTSK25") //Define se sera utiliza o Skip-Lote de 25%
Local oModel	 := FWModelActive()
Local oField	 := NIL
Local oGrid		 := NIL
Local l060MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "MATA061"

If l060MVC
	oModel		  := FWModelActive()
	oField  	  := oModel:GetModel("MdFieldSA5")
	oGrid		  := oModel:GetModel("MdGridSA5")
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica a categoria da Situacao  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QEG->(dbSetOrder(1))
QEG->(dbSeek(xFilial("QEG")+If(l060MVC,oGrid:GetValue("A5_SITU"),M->A5_SITU)))
If QEG->QEG_CATEG == "2"
	lSitQua := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ De acordo com os dados encontrados dispara uma consulta F3 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cMvUtSk25 == "S"
	If lSitQua
		lRet := ConPad1(,,,"QS1",,,.F.)	// Consulta dos Skip-Lotes p/ Qualif (25%)
	Else
		lRet := ConPad1(,,,"QEF",,,.F.)	// Consulta de todos os Skip-Lotes
	EndIf
Else
	lRet := ConPad1(,,,"QEF",,,.F.)	// Consulta de todos os Skip-Lotes
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A100WhDA  ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³18/08/1998³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Sugere Data Sistema na Data da Avaliacao do Fornecedor      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA020.PRX ( Cad. Fornecedores) - SX3(X3_WHEN) A2_DTAVA    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A100WhDA()
If ReadVar() == "M->A2_DTAVA" .And. !Empty(M->A2_FATAVA)
	M->A2_DTAVA := Iif(Empty(M->A2_DTAVA),dDataBase,M->A2_DTAVA)
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³QE100GaDA ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³26/10/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Sugere Data Validade a partir da Data da Avaliacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Gatilho do A2_DTAVA (SX7)                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QE100GaDA()
Local lRet := .F.
If !Empty(M->A2_DTAVA) .And. Empty(M->A2_DTVAL)
	lRet := .T.
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QIEA100_V  ³ Autor ³ Cleber Maldonado     ³ Data ³ 25/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para verificar a ultima versao do fonte   ³±±
±±³			 ³ QIEA100.PRW aplicado no rpo do cliente, assim verificando  ³±±
±±³			 ³ a necessidade de uma atualizacao neste fonte.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EST/PCP/FAT/COM	                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QIEA100_V()
Local nRet := 20130327 // 27 de Março de 2013
Return nRet 

/*/{Protheus.doc} QE100DtAva
Gatilho do campo A2_FATAVA para preencher o campo A2_DTAVA
@author carlos capeli
@since 27/06/2018
@version 1.0
@return Date

@type function
/*/
Function QE100DtAva()

Local oModel     := FWModelActive()
Local oField     := Nil
Local l020MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "CUSTOMERVENDOR"
Local dtRet      := cToD("")

If l020MVC
	oField := oModel:GetModel("SA2MASTER")
	If !Empty(oField:GetValue("A2_FATAVA"))
		dtRet := Iif(Empty(oField:GetValue("A2_DTAVA")),dDataBase,oField:GetValue("A2_DTAVA"))
	EndIf
Else
	If !Empty(M->A2_FATAVA)
		dtRet := Iif(Empty(M->A2_DTAVA),dDataBase,M->A2_DTAVA)
	EndIf
EndIf

Return dtRet

/*/{Protheus.doc} QE100DtVal
Gatilho do campo A2_FATAVA para preencher o campo A2_DTVAL
@author carlos capeli
@since 27/06/2018
@version 1.0
@return Date

@type function
/*/
Function QE100DtVal()

Local oModel     := FWModelActive()
Local oField     := Nil
Local l020MVC    := ValType(oModel) <> "U" .And. oModel:GetId() == "CUSTOMERVENDOR"
Local dtRet      := cToD("")

If l020MVC
	oField := oModel:GetModel("SA2MASTER")
	If !Empty(oField:GetValue("A2_DTAVA"))
		dtRet := oField:GetValue("A2_DTAVA") + 365
	EndIf
Else
	If !Empty(M->A2_DTAVA)
		dtRet := M->A2_DTAVA + 365
	EndIf
EndIf

Return dtRet
