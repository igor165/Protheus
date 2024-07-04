#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLSMPA012()
Relacao Produtos X Caract. Fisico-Quimicas (laudo de qualidade)
Adaptação da função TSMPA012
@author Itamar Oliveira
@since 19/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------
Function DCLSMPA012()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina 	:= 	{ 	{ "Pesquisar", "AxPesqui"  		, 0, 1},; 		 //"Pesquisar"
						  	{ "Visualizar", "DclSm018Vis"		, 0, 2},;	 	 //"Visualizar"
					  	  	{ "Incluir", "DclSm018Inc"		, 0, 3},; 		 //"Incluir"
					  	  	{ "Alterar", "DclSm018Alt"		, 0, 4},; 		 //"Alterar"
					  	  	{ "Excluir", "DclSm018Exc"		, 0, 5}} 		 //"Excluir"

Private cCadastro := "Laudo de Qualidade"
Private aSize	  := MsAdvSize(,.F.,430)
Private aObjects  := {}
Private aPosObj   := {}
Private aSizeAut  := MsAdvSize() // devolve o tamanho da tela atualmente no micro do usuario

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

AAdd( aObjects, { 315,  70, .T., .t. } )
AAdd( aObjects, { 100, 100, .t., .t. } )

aInfo   := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

//Endereca a funcao de BROWSE
dbSelectArea("DHE") // Tabela: Grupo de Documentos
dbSetOrder(1)   	// Ordem : Codigo Grupo + Codigo do Documento

mBrowse(6, 1, 22, 75, "DHE")


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SMP018INC()
Rotina de inclusao de Grupo de Documentos
Adaptação da função TSMPA012
@author Marco Aurelio
@param calias
@param nReg
@param nOpc
@since 14/10/2001
@version 1.0
/*/
//-------------------------------------------------------------------
Function DclSm018Inc(cAlias,nReg,nOpc)
Local oDlg 		                        			// Janela de dados
Local aAreaAnt:= GetArea()							// Salva ambiente
Local cCpoQry 	:= ''
Local nInd		:= 0
Local cIniCpos	:= 'DHE_ITECAR'
//Local cCampos 	:= "DHE_ITECAR|DHE_CODCAR|DHE_CARACT|DHE_UNMEDI|DHE_MAFER|DHE_VALOR|DHE_MASSA|" // Campos a serem exibidos na GetDados
Local aCampos 	:= {"DHE_ITECAR","DHE_CODCAR","DHE_CARACT","DHE_UNMEDI","DHE_MAFER","DHE_VALOR","DHE_MASSA"} // Campos a serem exibidos na GetDados
Local cCpoVar 	:= "DHE_LAUDO|DHE_CODPRO|DHE_PRODES"		// Campos para criacao de variaveis de memoria
Local aExibe  	:= {"DHE_LAUDO", "DHE_CODPRO", "DHE_PRODES"}	// Campos exibidos na Enchoice()
Local aAltera 	:= {"DHE_LAUDO", "DHE_CODPRO", "DHE_PRODES"}	// Campo editavel da Enchoice()
Local nOpca   	:= 0  								// Recebe o valor de saida da DIALOG - Quando "1"
Local lTSMP12LD	:= ExistTemplate("TSMP12LD")
Local ncount 	:=0
Local nOpcx	 	:= IIf( INCLUI, 3, IIf( ALTERA, 4, 5 ) )
Local cSeek  	:= Nil
Local cWhile	:= Nil
Local cQuery 	:= Nil
Local aAux		:= {}
Local aYesFields:= {}
Local aNoFields := {}
Local lOnlyYes	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de variaveis Privates   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private nUsado := 0
Private nCnt   := 0
Private aTela[0][0]
Private aGets[0]
Private oGetd
Private aHeader	:= {}
Private aCols	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama rotina para geracao de variaveis de memoria  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory(cAlias,INCLUI)

aHeader 	:= {}
aCols  		:= {}
cSeek  		:= FWxFilial( 'DHE' ) + DHE->DHE_LAUDO + DHE->DHE_CODPRO
cWhile 		:= "DHE_FILIAL + DHE_LAUDO + DHE_CODPRO"
aYesFields	:= { "DHE_ITECAR","DHE_CODCAR","DHE_CARACT","DHE_UNMEDI","DHE_MAFER","DHE_VALOR","DHE_MASSA" }
aNoFields 	:= {}

FillGetDados( nOpcx, cAlias, 1, cSeek, {|| &cWhile }, {||.T.}, aNoFields, aYesFields, lOnlyYes , /*cQuery*/ ,/*bMontCols*/, .F. )

aAux := {}
aCols:= {}
For nInd := 1 To Len( aHeader )
		Do Case
		Case !( AllTrim( aHeader[ nInd , 2 ] ) $ 'DHE_ALI_WT|DHE_REC_WT|DHE_ITECAR' )
			Aadd( aAux, CriaVar( aHeader[ nInd , 2 ], .F. ) )
		Case AllTrim( aHeader[ nInd , 2 ] ) $ 'DHE_ITECAR'
			Aadd( aAux, StrZero( 1, TamSx3( 'DHE_ITECAR' )[ 1 ] ) )
		Case AllTrim( aHeader[ nInd , 2 ] ) $ 'DHE_ALI_WT'
			Aadd( aAux, 'DHE' )
		Case AllTrim( aHeader[ nInd , 2 ] ) $ 'DHE_REC_WT'
			Aadd( aAux, 0 )
		EndCase
Next nInd

Aadd( aAux, .F. )
Aadd( aCols, AClone( aAux ) )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	EnChoice( cAlias, nReg, nOpc,,,,aExibe, aPosObj[1], aAltera, , , , , , ,.T. )
	nCnt	:= Len(aCols)
			   //MSGetDados():New( aCGD[1]     ,aCGD[2]     ,aCGD[3]     ,aCGD[4]     ,nOpcX,"__MOD2LineOK()","AllwaysTrue()",cIniCpos ,lDelGetD,aGetsGD, , ,nMax ,"__FieldOk()")
	oGetd	:= MsGetDados():New( aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],3 ,"DclSm018LOk"   ,"DclSm018TOk"  , '+DHE_ITECAR', .T.    ,       , , ,999 )
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .And. oGetd:TudoOk(),(nOpca:=1,oDlg:End()),nOpca := 0)},{||oDlg:End()})

IF nOpcA == 1 // Operacao de inclusao confirmada
	Begin Transaction
		DclSm018Grava(nOpc)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada 											 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTSMP12LD
			ExecTemplate("TSMP12LD")
		EndIf
	End Transaction
Else
	RollBackSX8()
Endif
RestArea(aAreaAnt)
Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} SMP018LOk()
Valida Linha da Getdados
@author Itamar Oliveira
@since 24/02/2005
@return lRet
@version 1.0
/*/
//-------------------------------------------------------------------
Function DclSm018LOk()
Local lRet := .T.  // Conteudo de retorno
Local nPosCodDoc := aScan( aHeader, { |x| Alltrim(x[2])=="DHE_CODCAR" } )

If  !aCols[n][Len(aHeader)+1] .and. Empty( aCols[n][nPosCodDoc])
	Alert("Informe o codigo da caracteristica Fis-Quim.")
	lRet := .F.
EndIf

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} SMP018TOk()
Valida Linhas da Getdados
@author Itamar Oliveira
@since 24/02/2005
@return _lRet
@version 1.0
/*/
//-------------------------------------------------------------------
Function DclSm018TOk()
Local _lRet := .T. // Conteudo de retorno
Local _nInd := 0	// Indexador de laco For/Next
Local nPosCodDoc := aScan( aHeader, { |x| Alltrim(x[2])=="DHE_CODCAR" } )

For _nInd:=1 To Len(aCols)

	If  !aCols[_nInd][Len(aHeader)+1] .and. Empty( aCols[_nInd][nPosCodDoc])
		Alert("Existem linhas sem preenchimento do codigo da caracteristica")
		_lRet := .F.
		Exit
	EndIf

Next

Return ( _lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} SMP018Grava()
Efetua gravacao dos dados na tabela LHW(Grupo de Car.Fis-Qui)
@author Itamar Oliveira
@since 26/01/2005
@return lRet
@version 1.0
/*/
//-------------------------------------------------------------------
Function DclSm018Grava(nOpc)
Local lRet			:= .T.	// Conteudo de retorno
Local lAchou		:= .F.
Local nInd			:= 0	// Indexador de laco For/Next
Local nPosCodCar	:= aScan( aHeader, { |x| Alltrim(x[2])=="DHE_CODCAR" } )
Local nPosMafer	:= aScan( aHeader, { |x| Alltrim(x[2])=="DHE_MAFER" } )
Local nPosValor	:= aScan( aHeader, { |x| Alltrim(x[2])=="DHE_VALOR" } )
Local nPosMassa	:= aScan( aHeader, { |x| Alltrim(x[2])=="DHE_MASSA" } )
Local nPosItem	:= aScan( aHeader, { |x| Alltrim(x[2])=="DHE_ITECAR" } )
Local cMens 		:= ""
Local aArea 		:= GetArea()
Local aAreaDH3	:= DH3->(GetArea())
Local aAreaSD2	:= SD2->(GetArea())

If (nOpc == 5) // Exclusao

	dbSelectArea("DH3") // NF Saida
	DH3->(dbSetOrder(3)) // DH3_FILIAL+DH3_LAUDO
	If DH3->(dbSeek(xFilial("DH3") + M->DHE_LAUDO))
		DbSelectArea("SD2")
		SD2->(DbSetOrder(3))
		If SD2->(DbSeek(DH3->(DH3_FILIAL+DH3_DOCD2+DH3_SERIE)))
			While DH3->(DH3_FILIAL+DH3_DOCD2+DH3_SERIE) == SD2->(D2_FILIAL+D2_DOC+D2_SERIE)
				If DH3->DH3_ITEM == SD2->D2_ITEM .And. SD2->D2_COD == M->DHE_CODPRO
					lAchou := .T.
					lRet := .F.
					cMens:="Este laudo de qualidade nao podera ser excluido por estar relacionado a notas fiscais de saida."
					Alert(cMens)
					Exit
				EndIf
				SD2->(DbSkip())
			EndDo
		EndIf
	EndIf
	If !lAchou
		dbSelectArea("DHE") // Tabela: Grupo de Carac. Fis-Quim
		DHE->(DbSetOrder(1)) // FILIAL + LAUDO + CODPRO

		//Exclui os registros do Arquivo DHE
		If MsSeek(xFilial("DHE")+M->DHE_LAUDO+M->DHE_CODPRO)
			While DHE_FILIAL+DHE->DHE_LAUDO+DHE->DHE_CODPRO == xFilial("DHE")+M->DHE_LAUDO+M->DHE_CODPRO
				RecLock("DHE", .F.)
				dbDelete()
				MsUnLock()

				dbSelectArea("DHE")
				dbSkip()
			EndDo
		EnDif
	EndIf
EndIf

If (nOpc == 3) .or. (nOpc == 4) // Inclusao ou Alteracao

	dbSelectArea("DHE") // Tabela: Grupo de Caracteristicas Fis-Quim.
	DHE->(DbSetOrder(1)) // FILIAL + LAUDO + CODPRO

	If MsSeek(xFilial("DHE")+M->DHE_LAUDO+M->DHE_CODPRO)
		If nOpc == 3
			Alert("Este Laudo já está cadastrado para este produto")
			lRet:=.F.
			Return(lRet)
		Else
			Do While !EOF() .And. DHE->(DHE_LAUDO+DHE_CODPRO) == M->DHE_LAUDO+M->DHE_CODPRO
				RecLock("DHE",.F.)
				dbDelete()
				MsUnLock()
				DbSkip()
			EndDo
		EndIf
	EndIf

	For nInd:=1 To Len(aCols)
		If aCols[nInd][Len(aHeader)+1] == .F. // Nao esta deletado, portanto grava
			RecLock("DHE",.T.)
				DHE->DHE_FILIAL	:=	xFilial("DHE")
				DHE->DHE_LAUDO 	:=	M->DHE_LAUDO
				DHE->DHE_CODPRO	:= 	M->DHE_CODPRO
				DHE->DHE_ITECAR	:= aCols[nInd][nPosItem] // Item
				DHE->DHE_CODCAR	:= aCols[nInd][nPosCodCar] // Cod. da Caracteristica
   				DHE->DHE_MAFER	:= aCols[nInd][nPosMafer] // Metodo de Afericao da Caract.
   				DHE->DHE_VALOR	:= aCols[nInd][nPosValor] // Valor da Caract.
   				DHE->DHE_MASSA	:= aCols[nInd][nPosMassa] // Massa especifica
			MsUnLock()
		EndIf
	Next

	If nOpc == 3
		If  __lSX8
			ConfirmSX8()
		Else
			RollBackSX8()
		Endif
   	EndIf

EndIf

RestArea(aArea)
RestArea(aAreaDH3)
RestArea(aAreaSD2)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} SMP018Exc()
Rotina de exclusao de Grupo de Car. Fis-Quim. do Produto
@author Itamar Oliveira
@since 26/01/2005
@return lRet
@version 1.0
/*/
//-------------------------------------------------------------------
Function DclSm018Exc(cAlias,nReg,nOpc)
Local oDlg 		                        			// Janela de dados
Local aAreaAnt:= GetArea()							// Salva ambiente
Local cCpoQry 	:= ''
Local nInd		:= 0
Local cIniCpos	:= 'DHE_ITECAR'
Local aCampos 	:= {"DHE_ITECAR","DHE_CODCAR","DHE_CARACT","DHE_UNMEDI","DHE_MAFER","DHE_VALOR","DHE_MASSA"} // Campos a serem exibidos na GetDados
Local cCpoVar 	:= "DHE_LAUDO|DHE_CODPRO|DHE_PRODES"		// Campos para criacao de variaveis de memoria
Local aExibe  	:= {"DHE_LAUDO", "DHE_CODPRO", "DHE_PRODES"}	// Campos exibidos na Enchoice()
Local aAltera 	:= {"DHE_LAUDO", "DHE_CODPRO", "DHE_PRODES"}	// Campo editavel da Enchoice()
Local nOpca   	:= 0  								// Recebe o valor de saida da DIALOG - Quando "1"
Local lTSMP12LD	:= ExistTemplate("TSMP12LD")
Local ncount 	:=0
Local nOpcx	 	:= IIf( INCLUI, 3, IIf( ALTERA, 4, 5 ) )
Local cSeek  	:= Nil
Local cWhile	:= Nil
Local cQuery 	:= Nil
Local aAux		:= {}
Local aYesFields:= {}
Local aNoFields := {}
Local lOnlyYes	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de variaveis Privates   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private nUsado := 0
Private nCnt   := 0
Private aTela[0][0]
Private aGets[0]
Private oGetd
Private aHeader	:= {}
Private aCols	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama rotina para geracao de variaveis de memoria  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory(cAlias,INCLUI)

cSeek  		:= FWxFilial( 'DHE' ) + DHE->DHE_LAUDO + DHE->DHE_CODPRO
cWhile 		:= "DHE_FILIAL + DHE_LAUDO + DHE_CODPRO"
aYesFields	:= { "DHE_ITECAR","DHE_CODCAR","DHE_CARACT","DHE_UNMEDI","DHE_MAFER","DHE_VALOR","DHE_MASSA" }
aNoFields 	:= {}

AEval( aYesFields, { | x | IIf( DHE->( FieldPos( x ) ) > 0, cCpoQry += ', ' + AllTrim( x ), Nil ) } )
cQuery := " SELECT "+ SubStr( cCpoQry, 2 ) +", DHE.R_E_C_N_O_ "+CRLF
cQuery += " FROM "+ RetSQLName( 'DHE' ) +" DHE "+CRLF
cQuery += " WHERE DHE.DHE_FILIAL = '"+ FWxFilial( 'DHE' ) +"' "+CRLF
cQuery += "  AND  DHE.DHE_LAUDO = '"+ DHE->DHE_LAUDO +"' "+CRLF
cQuery += "  AND  DHE.DHE_CODPRO = '"+ DHE->DHE_CODPRO +"' "+CRLF
cQuery += "  AND  DHE.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " ORDER BY "+ SQLOrder( DHE->( IndexKey( 1 ) ) ) +" "+CRLF

FillGetDados( nOpcx, cAlias, 1, cSeek, {|| &cWhile }, {||.T.}, aNoFields, aYesFields, lOnlyYes , cQuery ,/*bMontCols*/, .F. )

nLimite := len(aCols)
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	EnChoice( cAlias, nReg, nOpc,,,,aExibe, aPosObj[1], aAltera, , , , , , ,.T. )
	nCnt	:= Len(aCols)
			   //MSGetDados():New( aCGD[1]     ,aCGD[2]     ,aCGD[3]     ,aCGD[4]     ,nOpcX,"__MOD2LineOK()","AllwaysTrue()",cIniCpos ,lDelGetD,aGetsGD, , ,nMax ,"__FieldOk()")
	oGetd	:= MsGetDados():New( aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],5 ,"DclSm018LOk"   ,"DclSm018TOk"  , '+DHE_ITECAR', .T.    ,       , , , nLimite )
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(DclSm018VerExc(.T., nLimite),(nOpca:=1,oDlg:End()),nOpca := 0)},{||oDlg:End()})

IF nOpcA == 1  // Operacao de exclusao confirmada
	Begin Transaction
		DclSm018Grava(nOpc)
	End Transaction
Endif

RestArea(aAreaAnt)

Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} SMP018VerExc()
Valida se o registro pode ser excluido
considerando o relacionamento deste com as tabelas abaixo:
SD1 - Nota Fiscal de Entrada
@author Itamar Oliveira
@since 26/01/2005
@param lExc
@param nLimite
@return lRet
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DclSm018VerExc(lExc, nLimite)
Local lRet     := .T. 			// Valor de retorno
Local aAreaAnt := GetArea()	// Salva ambiente para posterior restauracao
Local nInd 	   := ""			// Contador de laco For/Next

For nInd:=1 To nLimite

	If lExc .or. GDDeleted(nInd)
	Endif

Next nInd

RestArea(aAreaAnt)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SMP018Alt()
Rotina de alteracao de Grupo de Caracteristicas Fis-Quim
@author Itamar Oliveira
@since 26/01/2005
@param cAlias
@param nReg
@param nOpc
@version 1.0
/*/
//-------------------------------------------------------------------
Function DclSm018Alt(cAlias,nReg,nOpc)
Local oDlg 		                        			// Janela de dados
Local aAreaAnt:= GetArea()							// Salva ambiente
Local cCpoQry 	:= ''
Local nInd		:= 0
Local cIniCpos	:= 'DHE_ITECAR'
Local aCampos 	:= {"DHE_ITECAR","DHE_CODCAR","DHE_CARACT","DHE_UNMEDI","DHE_MAFER","DHE_VALOR","DHE_MASSA"} // Campos a serem exibidos na GetDados
Local cCpoVar 	:= "DHE_LAUDO|DHE_CODPRO|DHE_PRODES"		// Campos para criacao de variaveis de memoria
Local aExibe  	:= {"DHE_LAUDO", "DHE_CODPRO", "DHE_PRODES"}	// Campos exibidos na Enchoice()
Local aAltera 	:= {"DHE_LAUDO", "DHE_CODPRO", "DHE_PRODES"}	// Campo editavel da Enchoice()
Local nOpca   	:= 0  								// Recebe o valor de saida da DIALOG - Quando "1"
Local lTSMP12LD	:= ExistTemplate("TSMP12LD")
Local ncount 	:=0
Local nOpcx	 	:= IIf( INCLUI, 3, IIf( ALTERA, 4, 5 ) )
Local cSeek  	:= Nil
Local cWhile	:= Nil
Local cQuery 	:= Nil
Local aAux		:= {}
Local aYesFields:= {}
Local aNoFields := {}
Local lOnlyYes	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de variaveis Privates   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private nUsado := 0
Private nCnt   := 0
Private aTela[0][0]
Private aGets[0]
Private oGetd
Private aHeader	:= {}
Private aCols	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama rotina para geracao de variaveis de memoria  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory(cAlias,INCLUI)

cSeek  		:= FWxFilial( 'DHE' ) + DHE->DHE_LAUDO + DHE->DHE_CODPRO
cWhile 		:= "DHE_FILIAL + DHE_LAUDO + DHE_CODPRO"
aYesFields	:= { "DHE_ITECAR","DHE_CODCAR","DHE_CARACT","DHE_UNMEDI","DHE_MAFER","DHE_VALOR","DHE_MASSA" }
aNoFields 	:= {}

AEval( aYesFields, { | x | IIf( DHE->( FieldPos( x ) ) > 0, cCpoQry += ', ' + AllTrim( x ), Nil ) } )
cQuery := " SELECT "+ SubStr( cCpoQry, 2 ) +", DHE.R_E_C_N_O_ "+CRLF
cQuery += " FROM "+ RetSQLName( 'DHE' ) +" DHE "+CRLF
cQuery += " WHERE DHE.DHE_FILIAL = '"+ FWxFilial( 'DHE' ) +"' "+CRLF
cQuery += "  AND  DHE.DHE_LAUDO = '"+ DHE->DHE_LAUDO +"' "+CRLF
cQuery += "  AND  DHE.DHE_CODPRO = '"+ DHE->DHE_CODPRO +"' "+CRLF
cQuery += "  AND  DHE.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " ORDER BY "+ SQLOrder( DHE->( IndexKey( 1 ) ) ) +" "+CRLF

FillGetDados( nOpcx, cAlias, 1, cSeek, {|| &cWhile }, {||.T.}, aNoFields, aYesFields, lOnlyYes , cQuery ,/*bMontCols*/, .F. )

nLimite := len(aCols)
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	EnChoice( cAlias, nReg, nOpc,,,,aExibe, aPosObj[1], aAltera, , , , , , ,.T. )
	nCnt	:= Len(aCols)
			   //MSGetDados():New( aCGD[1]     ,aCGD[2]     ,aCGD[3]     ,aCGD[4]     ,nOpcX,"__MOD2LineOK()","AllwaysTrue()",cIniCpos ,lDelGetD,aGetsGD, , ,nMax ,"__FieldOk()")
	oGetd	:= MsGetDados():New( aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],4 ,"DclSm018LOk"   ,"DclSm018TOk"  , '+DHE_ITECAR', .T.    ,       , , , 9999 )
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .And. oGetd:TudoOk() .and. DclSm018VerExc(.F., nLimite ),(nOpca:=1,oDlg:End()),nOpca := 0)},{||oDlg:End()})

If nOpcA == 1 // Operacao de alteracao confirmada
	Begin Transaction
		DclSm018Grava(nOpc)
	End Transaction
Endif


RestArea(aAreaAnt)
Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} SMP018Vis()
Rotina de visualização de Grupo de Caracteristicas Fis-Quim
@author Itamar Oliveira
@since 26/01/2005
@param cAlias
@param nReg
@param nOpc
@version 1.0
/*/
//-------------------------------------------------------------------
Function DclSm018Vis(cAlias,nReg,nOpc)
Local oDlg 		                        			// Janela de dados
Local aAreaAnt:= GetArea()							// Salva ambiente
Local cCpoQry 	:= ''
Local nInd		:= 0
Local cIniCpos	:= 'DHE_ITECAR'
Local aCampos 	:= {"DHE_ITECAR","DHE_CODCAR","DHE_CARACT","DHE_UNMEDI","DHE_MAFER","DHE_VALOR","DHE_MASSA"} // Campos a serem exibidos na GetDados
Local cCpoVar 	:= "DHE_LAUDO|DHE_CODPRO|DHE_PRODES"		// Campos para criacao de variaveis de memoria
Local aExibe  	:= {"DHE_LAUDO", "DHE_CODPRO", "DHE_PRODES"}	// Campos exibidos na Enchoice()
Local aAltera 	:= {"DHE_LAUDO", "DHE_CODPRO", "DHE_PRODES"}	// Campo editavel da Enchoice()
Local nOpca   	:= 0  								// Recebe o valor de saida da DIALOG - Quando "1"
Local lTSMP12LD	:= ExistTemplate("TSMP12LD")
Local ncount 	:=0
Local nOpcx	 	:= IIf( INCLUI, 3, IIf( ALTERA, 4, 5 ) )
Local cSeek  	:= Nil
Local cWhile	:= Nil
Local cQuery 	:= Nil
Local aAux		:= {}
Local aYesFields:= {}
Local aNoFields := {}
Local lOnlyYes	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de variaveis Privates   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private nUsado := 0
Private nCnt   := 0
Private aTela[0][0]
Private aGets[0]
Private oGetd
Private aHeader	:= {}
Private aCols	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama rotina para geracao de variaveis de memoria  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory(cAlias,INCLUI)

cSeek  		:= FWxFilial( 'DHE' ) + DHE->DHE_LAUDO + DHE->DHE_CODPRO
cWhile 		:= "DHE_FILIAL + DHE_LAUDO + DHE_CODPRO"
aYesFields	:= { "DHE_ITECAR","DHE_CODCAR","DHE_CARACT","DHE_UNMEDI","DHE_MAFER","DHE_VALOR","DHE_MASSA" }
aNoFields 	:= {}

AEval( aYesFields, { | x | IIf( DHE->( FieldPos( x ) ) > 0, cCpoQry += ', ' + AllTrim( x ), Nil ) } )
cQuery := " SELECT "+ SubStr( cCpoQry, 2 ) +", DHE.R_E_C_N_O_ "+CRLF
cQuery += " FROM "+ RetSQLName( 'DHE' ) +" DHE "+CRLF
cQuery += " WHERE DHE.DHE_FILIAL = '"+ FWxFilial( 'DHE' ) +"' "+CRLF
cQuery += "  AND  DHE.DHE_LAUDO = '"+ DHE->DHE_LAUDO +"' "+CRLF
cQuery += "  AND  DHE.DHE_CODPRO = '"+ DHE->DHE_CODPRO +"' "+CRLF
cQuery += "  AND  DHE.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " ORDER BY "+ SQLOrder( DHE->( IndexKey( 1 ) ) ) +" "+CRLF

FillGetDados( nOpcx, cAlias, 1, cSeek, {|| &cWhile }, {||.T.}, aNoFields, aYesFields, lOnlyYes , cQuery ,/*bMontCols*/, .F. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	EnChoice( cAlias, nReg, nOpc,,,,aExibe, aPosObj[1], aAltera, , , , , , ,.T. )
	nCnt	:= Len(aCols)
			   //MSGetDados():New( aCGD[1]     ,aCGD[2]     ,aCGD[3]     ,aCGD[4]     ,nOpcX,"__MOD2LineOK()","AllwaysTrue()",cIniCpos ,lDelGetD,aGetsGD, , ,nMax ,"__FieldOk()")
	oGetd	:= MsGetDados():New( aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],2 ,"DclSm018LOk"   ,"DclSm018TOk"  , '+DHE_ITECAR', .T.    ,       , , , Len( aCols ) )
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .And. oGetd:TudoOk(),(nOpca:=1,oDlg:End()),nOpca := 0)},{||oDlg:End()})

RestArea(aAreaAnt)
Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} SMP012Chk()
Validacao do numero do laudo e codigo do produto
@author Itamar Oliveira
@since 26/01/2005
@param cLaudo
@param cCodProd
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function DclSm012Chk(cLaudo, cCodProd)
Local aAreas     := { GetArea(), DHE->(GetArea()) }
Local lRet       := .T.
Default cLaudo   := Space(TamSX3("DHE_LAUDO" )[1])
Default cCodProd := Space(TamSX3("DHE_CODPRO")[1])

If !Empty(cLaudo) .And. !Empty(cCodProd)
	DHE->(DbSetOrder(1)) // FILIAL + LAUDO + CODPRO
	If DHE->(MsSeek(xFilial("DHE")+cLaudo+cCodProd))
		Alert("Este Laudo já esta cadastrado para este produto")
		lRet := .F.
	EndIf
EndIf

RestArea(aAreas[2])
RestArea(aAreas[1])
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DclSm012Car()
Gatilho do campo DHE_CARACT
@author jose.eulalio
@since 06/04/2017
@version 1.0
@return CRet
/*/
//-------------------------------------------------------------------
Function DclSm012Car()
Local aArea	:= DHD->(GetArea())
Local cRet		:= ""
//IIF(!Empty(M->DHD_CODCAR),DHD->DHD_CARACT,"")
DHD->(DbSetOrder(1))
If DHD->(DbSeek(xFilial("DHD")+M->DHE_CODCAR))
	cRet	:= DHD->DHD_CARACT
EndIf
RestArea(aArea)
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DclSm012UnMed()
Gatilho do campo DHE_UNMEDI
@author jose.eulalio
@since 06/04/2017
@version 1.0
@return CRet
/*/
//-------------------------------------------------------------------
Function DclSm012UnMed()
Local aArea	:= DHD->(GetArea())
Local cRet		:= ""
//IIF(!Empty(M->DHD_CODCAR),DHD->DHD_UNMEDI,"")
DHD->(DbSetOrder(1))
If DHD->(DbSeek(xFilial("DHD")+M->DHE_CODCAR))
	cRet	:= DHD->DHD_UNMEDI
EndIf
RestArea(aArea)
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DclSm012UnMed()
Inicializador do campo DHE_UNMEDI
@author jose.eulalio
@since 06/04/2017
@version 1.0
@return CRet
/*/
//-------------------------------------------------------------------
Function Dcl012UnMd()
Return IIf(!INCLUI .Or. Empty(M->DHE_CODCAR),Posicione("DHD",1,xFilial("DHD")+(IIf(Type("aCols[n][1]") == "C",aCols[n][1],DHE->DHE_CODCAR)),"DHD_UNMEDI"),"")

//-------------------------------------------------------------------
/*/{Protheus.doc} DclSm012UnMed()
Inicializador do campo DHE_CARACT
@author jose.eulalio
@since 06/04/2017
@version 1.0
@return CRet
/*/
//-------------------------------------------------------------------
Function Dcl012InCa()
Local cRet := ""

If !INCLUI .And. !Empty(DHE->DHE_CODCAR)
	cRet:= Posicione("DHD",1,xFilial("DHD")+DHE->DHE_CODCAR,"DHD_CARACT")
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Dcl012ItCa()
Retorna o próximo numero de controle do campo DHD_ITECAR
@author jose.eulalio
@since 06/04/2017
@version P12
/*/
//-------------------------------------------------------------------
Function Dcl012ItCa()
Local cRet := ""

If INCLUI .And. (Empty(M->DHE_ITECAR) .Or. Empty(DHE->DHE_ITECAR))
	cRet:= StrZero(1,TamSX3("DHE_ITECAR")[1])
Else
	cRet:= StrZero(n,TamSX3("DHE_ITECAR")[1])
EndIf

Return cRet
