#INCLUDE 'JURA206.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMBROWSE.CH'

Static _lSX1Jr206   := .F.
Static _cMotCanc    := ""
Static lTransaction := .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA206
Operação de Documentos Fiscais

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA206()
Local lMark     := .T.
Local cPerg     := "JURA206"

Private oBrw206 := Nil

_lSX1Jr206 := FindFunction("JurvldSx1") .And. JurVldSx1(cPerg)

If _lSX1Jr206
	Pergunte(cPerg, .F.)
	SetKey(VK_F12, { || Pergunte(cPerg, .T.)})
EndIf

oBrw206 := FWMarkBrowse():New()
oBrw206:SetDescription( STR0001 ) //"Operação de Documentos Fiscais"
oBrw206:SetAlias( 'NXA' )
oBrw206:SetMenuDef( 'JURA206' )
oBrw206:SetFilterDefault("NXA_NFGER == '1' .AND. NXA_TIPO == 'FT' .AND. NXA_SITUAC == '1'")
oBrw206:SetFieldMark( 'NXA_OK' )
oBrw206:SetAllMark( { || JA206All(oBrw206, @lMark)} )
JurSetLeg( oBrw206, 'NXA' )
JurSetBSize( oBrw206 )
oBrw206:Activate()

If _lSX1Jr206
	SetKey(VK_F12, NIL)
EndIf

_lSX1Jr206  := .F.

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "VIEWDEF.JURA204"     , 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0009, "J206VerNF()"         , 0, 2, 0, NIL } ) //"Ver Doc. Fiscal"
aAdd( aRotina, { STR0003, "JA206PROC( oBrw206 )", 0, 6, 0, NIL } ) //"Cancelar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} JA206PROC
Confirma os cancelamentos dos Documentos Fiscais

@param oBrw206  , FWMarkBrowse com os docuementos selecionados
@param lAutomato, Se está sendo executado pela automação
@param cTestCase, Qual caso de teste está sendo executado

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA206PROC(oBrw206, lAutomato, cTestCase)
Local cMarca       := Iif(Type("oBrw206") == "U", "", oBrw206:Mark())
Local aCbAction    := {STR0019, STR0020, STR0021, STR0022} //"Selecione uma opção"###"Remover vínculos"###"Perguntar antes de remover"###"Não remover"
Local lRet         := .F.
Local lYes         := .F.
Local lNo          := .F.
Local cCbAction    := aCbAction[1]
Local nTipoMsg     := 0
Local cTmp         := ""
Local cQuery       := ""
Local nCount       := 0
Local oBorderLeft  := Nil
Local oBorderRight := Nil
Local oBorderTop   := Nil
Local oBtNo        := Nil
Local oBtYes       := Nil
Local oCbAction    := Nil
Local oGpAction    := Nil
Local oPnlAction   := Nil
Local oPnlButtons  := Nil
Local oSDetail     := Nil
Local oSPerg       := Nil
Local lMostraCtb   := .F.
Local lAglutCtb    := .F.
Local lCtbOnLine   := .F.
Local lMotCan      := SuperGetMV('MV_JMOTCAN',, '2' ) == '1' // É obrigatório informar o motivo de cancelamento das faturas? 1- Sim; 2- Não.
Local lCancFat     := SuperGetMV("MV_JCFATNF",, .F.)         // Indica se a fatura vinculada a NF de Saída deve ser cancelada quando ocorrer a exclusão da NF. (.T. / .F.).
Local cPerg        := "JURA206"

Default lAutomato  := .F.
Default cTestCase  := "JURA206TestCase"

Static oDlgPerg    := Nil

If lAutomato .And. FindFunction("GetParAuto")
	aRetAuto  := GetParAuto(cTestCase)
	cMarca    := aRetAuto[1]
	cCbAction := aCbAction[aRetAuto[2]]
	lYes      := .T.
	If _lSX1Jr206 := FindFunction("JurvldSx1") .And. JurVldSx1(cPerg)
		Pergunte(cPerg, .F.)
	EndIf
EndIf

If _lSX1Jr206
	lMostraCtb  := MV_PAR01 == 1
	lAglutCtb   := MV_PAR02 == 1
	lCtbOnLine  := MV_PAR03 == 1
EndIf

cTmp  := GetNextAlias()

cQuery := " SELECT COUNT(*) as NXA_QTDREC "
cQuery += " FROM " + RetSqlName( "NXA" )
cQuery += " WHERE NXA_FILIAL = '" + xFilial( "NXA" ) + "' "
cQuery +=   " AND NXA_NFGER = '1' "
cQuery +=   " AND NXA_TIPO = 'FT' "
cQuery +=   " AND NXA_OK = '" + cMarca + "' "
cQuery +=   " AND D_E_L_E_T_ = ' '"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTmp, .T., .F. )

If !(cTmp)->(Eof())
	nCount := (cTmp)->NXA_QTDREC
EndIf

(cTmp)->(DbCloseArea())

If nCount == 0
	ApMsgAlert(STR0043) //"Selecione pelos menos uma Fatura para cancelamento do Doc. Fiscal"

Else

	While .T.
		If !lAutomato
			//STYLE DS_MODALFRAME -> Omite o botao fechar (X) na barra de titulo da janela
			DEFINE MSDIALOG oDlgPerg TITLE STR0023 FROM 000, 000 TO 200, 350 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME //"Cancelamento de Documentos Fiscais"
	
			@ 080, 000 MSPANEL oPnlButtons SIZE 175, 020 OF oDlgPerg COLORS 0, 16777215
			@ 003, 091 BUTTON oBtYes PROMPT STR0024 SIZE 037, 012 OF oPnlButtons ACTION (lYes := .T., oDlgPerg:End()) PIXEL //"Sim"
			@ 003, 134 BUTTON oBtNo  PROMPT STR0025 SIZE 037, 012 OF oPnlButtons ACTION (lNo  := .T., oDlgPerg:End()) PIXEL //"Não"
			@ 000, 000 MSPANEL oBorderTop   SIZE 175, 002 OF oDlgPerg COLORS 0, 16777215
			@ 002, 000 MSPANEL oBorderLeft  SIZE 002, 077 OF oDlgPerg COLORS 0, 16777215
			@ 002, 002 MSPANEL oPnlAction   SIZE 172, 077 OF oDlgPerg COLORS 0, 16777215
			@ 000, 170 MSPANEL oBorderRight SIZE 002, 077 OF oDlgPerg COLORS 0, 16777215
			@ 000, 000 GROUP oGpAction TO 077, 170 PROMPT STR0026 OF oPnlAction COLOR 0, 16777215 PIXEL //"Selecione uma ação"
			@ 020, 007 MSCOMBOBOX oCbAction VAR cCbAction ITEMS aCbAction SIZE 150, 020 OF oPnlAction COLORS 0, 16777215 ON CHANGE J206ChgSay(aScan(aCbAction,cCbAction),@oSDetail) PIXEL
			@ 010, 007 SAY oSPerg PROMPT STR0027 SIZE 150, 007 OF oPnlAction COLORS 0, 16777215 PIXEL //"Ao encontrar referências incorretas a Documentos Fiscais:"
			@ 040, 007 SAY oSDetail PROMPT "" SIZE 150, 035 OF oPnlAction COLORS 0, 16777215 PIXEL

			// Don't change the Align Order
			oPnlButtons:Align  := CONTROL_ALIGN_BOTTOM
			oBorderTop:Align   := CONTROL_ALIGN_TOP
			oBorderLeft:Align  := CONTROL_ALIGN_LEFT
			oPnlAction:Align   := CONTROL_ALIGN_ALLCLIENT
			oBorderRight:Align := CONTROL_ALIGN_RIGHT
			oGpAction:Align    := CONTROL_ALIGN_ALLCLIENT
	
			ACTIVATE MSDIALOG oDlgPerg CENTERED
		EndIf

		//Condicoes de saida da tela
		If (lYes .And. aScan(aCbAction, cCbAction) <= 1)
			ApMsgAlert(STR0019) //"Selecione uma opção"
			lYes := .F.
		Else
			Exit
		EndIf

	EndDo

	lRet     := lYes .And. !lNo
	nTipoMsg := aScan(aCbAction, cCbAction)

	If lRet
		If lCancFat .And. lMotCan .And. !lAutomato
			_cMotCanc := JA204MotCan()
		EndIf
		Processa( { || JA206CANC(cMarca, nTipoMsg, nCount, lAutomato, ;
								   lMostraCtb, lAglutCtb, lCtbOnLine) }, STR0005, STR0006, .F. ) //"Aguarde"###"Cancelando Doc. Fiscal..."
	EndIf

EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J206ChgSay
Muda a mensagem de ajuda na tela da JA206PROC

@author Daniel Magalhaes
@since 10/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J206ChgSay(nCbAction, oSay)

Do Case
	Case nCbAction == 1
		oSay:cCaption := ""
	Case nCbAction == 2
		oSay:cCaption := STR0028 //"Removerá os vículos de todas as faturas marcadas (exceto se o Documento Fiscal existir e não seja possível efetuar o cancelamento)"
	Case nCbAction == 3
		oSay:cCaption := STR0029 //"Ao encontrar um vínculo incorreto, será apresentada uma tela com a chave de busca do Documento Fiscal e a opção de remover o vínculo será individual por Fatura"
	Case nCbAction == 4
		oSay:cCaption := STR0030 //"Não efetuará alterações nas Faturas cujos vínculos estão incorretos, um resumo será apresentado ao final do processamento."
	Otherwise
		oSay:cCaption := ""
EndCase

oSay:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA206CANC
Processa os cancelamentos dos Documentos Fiscais

@param cMarca   , Marca utilizada para selecionar os documentos
@param nTipoMsg , Opção selecionada: "1 - Remover vínculos" "2 - Perguntar antes de remover" "3 - Não remover"
@param nCount   , Total de documentos selecionados
@param lAutomato, Se está sendo executado pela automação

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA206CANC(cMarca, nTipoMsg, nCount, lAutomato, lMostraCtb, lAglutCtb, lCtbOnLine)
Local cMarcaF2     := ""
Local aArea        := GetArea()
Local aAreaNS7     := NS7->( GetArea() )
Local aMsgPages    := {}
Local cFilAtu      := cFilAnt
Local cQuery       := ""
Local cTmp         := ""
Local cMsg         := ""
Local cAux1        := ""
Local cAux2        := ""
Local cCab1        := ""
Local cCab2        := ""
Local lErro        := .F.
Local lRemLink     := .F.
Local lMostraErro  := .F.
Local cPaisLoc     := SuperGetMV("MV_PAISLOC",, "BRA")
Local aCab         := {}
Local aItem        := {}
Local aItens       := {}

Default nCount     := 0
Default nTipoMsg   := 4
Default lAutomato  := .F.
Default lMostraCtb := .F.
Default lAglutCtb  := .F.
Default lCtbOnLine := .F.

// Variaveris private utilizadas no MATA520
lSD2520  := ExistBlock("MSD2520")
lA520EXC := ExistBlock("A520EXC")
lSD2520T := ExistTemplate("MSD2520")

cTmp  := GetNextAlias()

cQuery := " SELECT R_E_C_N_O_ NXARECNO "
cQuery += " FROM " + RetSqlName( "NXA" )
cQuery += " WHERE NXA_FILIAL = '" + xFilial( "NXA" ) + "' "
cQuery +=   " AND NXA_NFGER  = '1' "
cQuery +=   " AND NXA_TIPO   = 'FT' "
cQuery +=   " AND NXA_OK     = '" + cMarca + "' "
cQuery +=   " AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY NXA_FILIAL, NXA_COD"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cTmp, .T., .F. )

(cTmp)->( DbGoTop() )

SA1->( dbSetOrder( 1 ) )
NS7->( dbSetOrder( 1 ) )
SF2->( dbSetOrder( 1 ) )

ProcRegua( nCount )

While !(cTmp)->( EOF() )

	IncProc()

	NXA->( dbGoTo( (cTmp)->( NXARECNO ) ) )

	NS7->( dbSeek( xFilial( "NS7" ) + NXA->NXA_CESCR ) )
	
	If !J206Baixas(NS7->NS7_CFILIA) // Efetiva o cancelamento somente de faturas pendentes ou com baixa compensação do PFS
		cFilAnt := NS7->NS7_CFILIA

		If SF2->( dbSeek( xFilial( "SF2" ) + NXA->NXA_DOC + NXA->NXA_SERIE + NXA->NXA_CLIPG + NXA->NXA_LOJPG ) )
			
			If cPaisLoc == "BRA"
				
				SA1->( dbSeek( xFilial( "SA1" ) + NXA->NXA_CLIPG + NXA->NXA_LOJPG ) )
		
				lMsErroAuto := .F.
		
				aRegSD2 := {}
				aRegSE1 := {}
				aRegSE2 := {}
				
				Begin Transaction
				
					If MaCanDelF2( "SF2", SF2->(RecNo()), @aRegSD2, @aRegSE1, @aRegSE2 )
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Estorna o documento de saida                                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						// Variaveris private utilizadas no MATA520
						cMarcaF2 := GetMark(, "SF2", "F2_OK")
						l520Auto := .T.
						cFilter  := ""
			
						RecLock("SF2", .F.)
						SF2->F2_OK := cMarcaF2
						SF2->( MsUnlock() )
			
						cFilter := "@F2_OK = '" + cMarcaF2 + "' "
						SF2->( dbSetFilter( { || &cFilter }, cFilter ) )
						cFilter := ""
						MaDelNfs(aRegSD2, aRegSE1, aRegSE2, lMostraCtb, lAglutCtb, lCtbOnLine)
						SF2->( dbClearFilter() )

						// Limpa vínculo da Nota com a Fatura - Mantido por compatibilidade
						If !lTransaction .Or. (!Empty(NXA->NXA_DOC) .And. !J206FatNF(.F.)) // .Or. (!Empty(NXA->NXA_DOC) .And. !J206FatNF(.F.)) - retirar quando for release 33
							DisarmTransaction()
						EndIf

					Else
			
						If __lSX8
							RollBackSX8()
						EndIf
			
						lErro := .T.
			
						MostraErro()
						DisarmTransaction()
			
					EndIf
		
				End Transaction

			Else
			
				Begin Transaction
					
					lMSErroAuto := .F.
					
					aCab := {}
					AADD(aCab, {"F2_DOC"    , SF2->F2_DOC    , Nil})
					AADD(aCab, {"F2_SERIE"  , SF2->F2_SERIE  , Nil})
					AADD(aCab, {"F2_CLIENTE", SF2->F2_CLIENTE, Nil})
					AADD(aCab, {"F2_LOJA"   , SF2->F2_LOJA   , Nil})
					AADD(aCab, {"F2_TIPODOC", SF2->F2_TIPODOC, Nil})
					
					SD2->(dbSetOrder(1))
					SD2->(dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
					While SD2->(!Eof()) .And. SD2->D2_FILIAL == xFilial("SD2") .And. ;
							SD2->D2_DOC == SF2->F2_DOC .And. SD2->D2_SERIE == SF2->F2_SERIE .And. ;
							SD2->D2_CLIENTE == SF2->F2_CLIENTE .And. SD2->D2_LOJA == SF2->F2_LOJA
						aItem :={}
						AADD(aItem, {"D2_DOC"    , SD2->D2_DOC    , Nil})
						AADD(aItem, {"D2_SERIE"  , SD2->D2_SERIE  , Nil})
						AADD(aItem, {"D2_CLIENTE", SD2->D2_FORNECE, Nil})
						AADD(aItem, {"D2_LOJA"   , SD2->D2_LOJA   , Nil})
						AADD(aItens, aClone(aItem))
						SD2->(dbSkip())
					EndDo
					
					MSExecAuto({ |x, y, z| MATA467N(x, y, z)}, aCab, aItens, 5)
					
					If lMSErroAuto
						If __lSX8
							RollBackSX8()
						EndIf
						
						lErro := .T.
						DisarmTransaction()
					Else
						// Limpa vínculo da Nota com a Fatura
						If !lTransaction .Or. (!Empty(NXA->NXA_DOC) .And. !J206FatNF(.F.))
							DisarmTransaction()
						EndIf

					EndIf
					
				End Transaction

			EndIf

		Else

			If nTipoMsg == 2 //Remover todos
				lMostraErro := .T.
				If Empty(cCab1)
					cCab1 += STR0033 + CRLF // "Os seguintes vínculos estavam incorretos e foram removidos:"
				EndIf
				cAux1 := Replicate('-',65) + CRLF
				cAux1 += STR0038 + Alltrim(NS7->NS7_CFILIA) + CRLF       // "Filial: "
				cAux1 += STR0035 + " " + Alltrim(NXA->NXA_CESCR) + " / " // "Escritório / No. Fatura:"
				cAux1 += + Alltrim(NXA->NXA_COD) + CRLF
				cAux1 += STR0039 + " " + Alltrim(NXA->NXA_DOC) + " / "   // "No. Doc. / Série Doc.:"
				cAux1 += + Alltrim(NXA->NXA_SERIE) + CRLF
				cAux1 += STR0041 + " " + Alltrim(NXA->NXA_CLIPG) + " / " // "Cód. Cliente / Loja:"
				cAux1 += + Alltrim(NXA->NXA_LOJPG) + CRLF

				cCab1 += cAux1

				lRemLink := .T.

			ElseIf nTipoMsg == 3 //Perguntar antes
				cMsg := STR0010 + CRLF                                  // "Documento Fiscal não encontrado."
				cMsg += STR0011 + CRLF + CRLF                           // "Verifique se a configuração de filial do escritório está correta, ou se o documento fiscal foi excluído através dos Livros Fiscais."
				cMsg += STR0013 + Alltrim(NS7->NS7_CFILIA) + CRLF       // "Filial (NS7_CFILIA) - "
				cMsg += STR0014 + Alltrim(xFilial("SF2"))  + CRLF       // "Filial (F2_FILIAL) - "
				cMsg += STR0039 + " " + Alltrim(NXA->NXA_DOC) + " / "   // "No. Doc. / Série Doc.:"
				cMsg += + Alltrim(NXA->NXA_SERIE) + CRLF
				cMsg += STR0041 + " " + Alltrim(NXA->NXA_CLIPG) + " / " // "Cód. Cliente / Loja:"
				cMsg += + Alltrim(NXA->NXA_LOJPG) + CRLF

				JurMsgErro(cMsg)
				lRemLink := ApMsgYesNo(STR0031) // "Deseja remover da Fatura esta referência incorreta ao Documento Fiscal?"
			Else
				lMostraErro := .T.
				//Add Msg para Historico
				If Empty(cCab1)
					cCab1 += STR0034 + CRLF // "As seguintes Faturas possuem vínculos incorretos com os Documentos Fiscais:"
				EndIf
				cAux1 := Replicate('-',65)  + CRLF
				cAux1 += STR0038 + Alltrim(NS7->NS7_CFILIA) + CRLF       // "Filial:"
				cAux1 += STR0035 + " " + Alltrim(NXA->NXA_CESCR) + " / " // "Escritório / No. Fatura:"
				cAux1 += + Alltrim(NXA->NXA_COD) + CRLF
				cAux1 += STR0039 + " " + Alltrim(NXA->NXA_DOC) + " / "   // "No. Doc. / Série Doc.:"
				cAux1 += + Alltrim(NXA->NXA_SERIE) + CRLF
				cAux1 += STR0041 + " " + Alltrim(NXA->NXA_CLIPG) + " / " // "Cód. Cliente / Loja:"
				cAux1 += + Alltrim(NXA->NXA_LOJPG) + CRLF

				cCab1 += cAux1
				lRemLink := .F.
			EndIf
			
			If lRemLink
				J206FatNF(.F.)
				lRemLink := .F.
			EndIf

		EndIf

	Else
		lMostraErro := .T.
		If Empty(cCab2)
			cCab2 := STR0046 + CRLF // "O(s) documento(s) fiscal(is) não pode(m) ser cancelado(s) pois existe(m) título(s) baixado(s)."
		EndIf

		cAux2 := Replicate('-',65) + CRLF
		cAux2 += STR0038 + Alltrim(NS7->NS7_CFILIA) + CRLF       // "Filial: "
		cAux2 += STR0035 + " " + Alltrim(NXA->NXA_CESCR) + " / " // "Escritório / No. Fatura:"
		cAux2 += + Alltrim(NXA->NXA_COD) + CRLF
		cAux2 += STR0039 + " " + Alltrim(NXA->NXA_DOC) + " / "   // "No. Doc. / Série Doc.:"
		cAux2 += + Alltrim(NXA->NXA_SERIE) + CRLF
		cAux2 += STR0041 + " " + Alltrim(NXA->NXA_CLIPG) + " / " // "Cód. Cliente / Loja:"
		cAux2 += + Alltrim(NXA->NXA_LOJPG) + CRLF

		cCab2 += cAux2

	EndIf
	(cTmp)->( dbSkip() )

EndDo

If lErro
	MostraErro()
EndIf

If lMostraErro .And. !lAutomato
	If !Empty(cCab1)
		AAdd(aMsgPages, cCab1)
	EndIf
	If !Empty(cCab2)
		AAdd(aMsgPages, cCab2)
	EndIf
	J206MsgDlg(STR0023, aMsgPages) // "Cancelamento de Documentos Fiscais"
EndIf

cFilAnt := cFilAtu

(cTmp)->(DbCloseArea())

RestArea(aAreaNS7)
RestArea(aArea)

Return (!lErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} J206VerNF
Visualiza o Documento Fiscal

@author Daniel Magalhaes
@since 09/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J206VerNF()
Local aArea    := GetArea()
Local aAreaSF2 := SF2->( GetArea() )
Local aAreaSD2 := SD2->( GetArea() )
Local cFatDoc  := AvKey(NXA->NXA_DOC  , "F2_DOC")
Local cFatSer  := AvKey(NXA->NXA_SERIE, "F2_SERIE")
Local cFatCli  := AvKey(NXA->NXA_CLIPG, "F2_CLIENTE")
Local cFatLoj  := AvKey(NXA->NXA_LOJPG, "F2_LOJA")
Local cFatEsc  := NXA->NXA_CESCR
Local cFatFil  := ""
Local cFilBkp  := cFilAnt
Local cChave   := ""
Local cMsg     := ""
Local lRet     := .F.

//Privates necessarias na MATA920
Private aRotina   := MenuDef()
Private cCalcImpV := GetMV("MV_GERIMPV")

NS7->( DbSetOrder(1) )
If lRet := NS7->( dbSeek( xFilial( "NS7" ) + cFatEsc ) )
	//Configura a filial do escritorio
	cFatFil := NS7->NS7_CFILIA
	cFilAnt := cFatFil

	cChave := xFilial("SF2")
	cChave += cFatDoc
	cChave += cFatSer
	cChave += cFatCli
	cChave += cFatLoj

	SF2->( DbSetOrder(1) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
	If lRet := SF2->( DbSeek( cChave ) )

		dbSelectArea("SD2")
		SD2->( dbSetOrder(3) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		SD2->( dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA) )

		INCLUI := .F.
		A920NfSai("SD2", SD2->(Recno()), 2)

	EndIf

EndIf

If !lRet

	cMsg := STR0010 + CRLF								// "Documento Fiscal não encontrado."
	cMsg += STR0011 + CRLF + CRLF						// "Verifique se a configuração de filial do escritório está correta, ou se o documento fiscal foi excluído através dos Livros Fiscais."
	cMsg += STR0012 + CRLF								// "Chave de pesquisa utilizada:"
	cMsg += STR0013 + "[" + cFatFil + "]" + CRLF		// "Filial (NS7_CFILIA) - "
	cMsg += STR0014 + "[" + xFilial("SF2") + "]" + CRLF	// "Filial (F2_FILIAL) - "
	cMsg += STR0015 + "[" + cFatDoc + "]" + CRLF		// "No. Doc. (F2_DOC) - "
	cMsg += STR0016 + "[" + cFatSer + "]" + CRLF		// "Série Doc. (F2_SERIE) - "
	cMsg += STR0017 + "[" + cFatCli + "]" + CRLF		// "Cód. Cliente (F2_CLIENTE) - "
	cMsg += STR0018 + "[" + cFatLoj + "]" + CRLF		// "Loja Cliente (F2_LOJA) - "

	JurMsgErro(cMsg)
EndIf

//Retorna a Filial Corrente
cFilAnt := cFilBkp

SD2->( RestArea(aAreaSD2) )
SF2->( RestArea(aAreaSF2) )
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J206MsgDlg
Dialogo para exibicao do historico do processamento

@author Daniel Magalhaes
@since 10/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function J206MsgDlg(cTitulo, aMsgPages)
Local oDlgResumo  := Nil
Local oFont1      := Nil
Local cMsgDisplay := ""
Local cNoPage     := ""
Local cLastPage   := ""
Local nPage       := 1
Local nLastPage   := 0

cMsgDisplay := aMsgPages[nPage]
nLastPage   := Len(aMsgPages)
cLastPage   := AllTrim(Str(nLastPage))
cNoPage     := PadL( AllTrim(Str(nPage)), Len(cLastPage) )

Define MsDialog oDlgResumo Title cTitulo From 7,2 To 26,78 Of oMainWnd

Define FONT oFont1 NAME "Courier New" Bold Size 0,14

oDlgResumo:SetFont(oFont1)

@ 06.5,03 Get cMsgDisplay MEMO HSCROLL READONLY SIZE 295,120 OF oDlgResumo Pixel

Define SButton From 130,140 Type 1 Action (oDlgResumo:End()) Enable Of oDlgResumo Pixel

@ 130,260 Get cNoPage Picture "@9" SIZE 15,10 ON CHANGE (nPage := J206VldPag(cNoPage, nLastPage), J206RfrshMsg(@cMsgDisplay,@cNoPage,aMsgPages[nPage],nPage)) WHEN {|| nLastPage > 1} OF oDlgResumo Pixel
@ 132,274 Say "/"+cLastPage OF oDlgResumo Pixel

@ 130,175 BUTTON "<<" SIZE 40 ,11 ACTION (nPage-=1,J206RfrshMsg(@cMsgDisplay,@cNoPage,aMsgPages[nPage],nPage) ) WHEN {|| nPage > 1 } OF oDlgResumo PIXEL
@ 130,215 BUTTON ">>" SIZE 40 ,11 ACTION (nPage+=1,J206RfrshMsg(@cMsgDisplay,@cNoPage,aMsgPages[nPage],nPage) ) WHEN {|| nPage < nLastPage } OF oDlgResumo PIXEL

Activate MSdialog oDlgResumo Centered

oFont1:End()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J206MsgDlg
Funcao para atualizar o conteudo campo Memo conforme a pagina
selecionada

@author Daniel Magalhaes
@since 10/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J206RfrshMsg(cCpoMemo, cCpoPage, cNewMsg, nNewPage)

cCpoMemo := ""
cCpoMemo := cNewMsg

cCpoPage := ""
cCpoPage := AllTrim(Str(nNewPage))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J206VldPag
Funcao para validar a pagina recebida por digitacao direta no campo

@author Daniel Magalhaes
@since 10/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J206VldPag(cNoPage, nLastPage)
Local nNewPage   := 1
Local nPageInput := Val(cNoPage)

If nPageInput < 1
	nNewPage:= 1
ElseIf nPageInput > nLastPage
	nNewPage:= nLastPage
Else
	nNewPage:= nPageInput
EndIf

Return nNewPage

//-------------------------------------------------------------------
/*/{Protheus.doc} JA206All
Chamada da rotina que avalia a acao de marcar todos

@author Daniel Magalhaes
@since 19/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA206All(oBrowse, lMark)

MsgRun( STR0044, STR0045, { || J206MarkAll(oBrowse, @lMark) } ) //"Aguarde... Marcando Registros"###"Marcar Todos"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J205MarkAll
Funcao para marcar efetivamente os registros ao utilizar o recurso
de marcar todos (duplo clique na header da marcacao)

@author Luciano Pereira dos Santos
@since 07/12/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J206MarkAll(oBrowse, lMark)
Local aArea := GetArea()

JurMarkALL(oBrowse, 'NXA', 'NXA_OK', lMark,, .F.)
lMark := !lMark
oBrowse:Refresh()
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J206FatNF
Limpa vínculo da Nota com a fatura

@param  lPosiciona, Se veradeiro faz o posicionamento na fatura se falso já está posicionado
@param  cDocumento, Numero da Nota Fiscal
@param  cSerie    , Série da Nota Fiscal
@param  cCliente  , Cliente da Nota Fiscal
@param  cLoja     , Loja da Nota Fiscal

@author Jonatas Martins / Jorge Martins
@since  22/06/2020
@obs    Função chamada no fonte MATA521 na função MaDelNfs
/*/
//-------------------------------------------------------------------
Function J206FatNF(lPosiciona, cDocumento, cSerie, cCliente, cLoja)
Local aArea         := GetArea()
Local aAreaNXA      := NXA->(GetArea())
Local cAlsNXA       := ""
Local lContinue     := .T.
Local lMotCan       := .F.

Default lPosiciona  := .T.
Default cDocumento  := ""
Default cSerie      := ""
Default cCliente    := ""
Default cLoja       := ""

	lTransaction := .T.

	If !FwIsInCallStack("JA204CanFa") // cancelamento de NF a partir da fatura
		If lPosiciona
			cAlsNXA := GetNextAlias()
			BeginSql Alias cAlsNXA
				SELECT NXA.R_E_C_N_O_ RECFAT
				  FROM %Table:NXA% NXA
				WHERE NXA.NXA_FILIAL = %xFilial:NXA%
				  AND NXA.NXA_DOC    = %Exp:cDocumento%
				  AND NXA.NXA_SERIE  = %Exp:cSerie%
				  AND NXA.NXA_CLIPG  = %Exp:cCliente%
				  AND NXA.NXA_LOJPG  = %Exp:cLoja%
				  AND NXA.%NotDel%
			EndSql

			If (cAlsNXA)->(!EOF())
				NXA->(DbGoTo((cAlsNXA)->RECFAT))
				lContinue := NXA->(!EOF())
			EndIf

			(cAlsNXA)->(DbCloseArea())
		EndIf

		If lContinue
			If !Empty(NXA->NXA_DOC)
				RecLock("NXA", .F.)
				NXA->NXA_DOC   := ""
				NXA->NXA_SERIE := ""
				NXA->NXA_NFGER := "2"
				If NXA->(ColumnPos("NXA_NFCOTA")) > 0
					NXA->NXA_NFCOTA := 0
				EndIf
				If NXA->(ColumnPos("NXA_NFELET")) > 0
					NXA->NXA_NFELET := ""
					NXA->NXA_LINKNF := ""
				EndIf
				NXA->(MsUnlock())
			EndIf

			// Cancela as faturas relacionadas as NFs
			If SuperGetMV("MV_JCFATNF",, .F.) // Indica se a fatura vinculada a NF de Saída deve ser cancelada quando ocorrer a exclusão da NF. (.T. / .F.).
				lMotCan := SuperGetMV('MV_JMOTCAN',, '2' ) == '1' // É obrigatório informar o motivo de cancelamento das faturas? 1- Sim; 2- Não.
				
				If !lMotCan .Or. (lMotCan .And. !Empty(_cMotCanc))
					lTransaction := J204CANPG(NXA->NXA_CPREFT,, _cMotCanc, NXA->NXA_CFIXO, NXA->NXA_CFTADC)
				Else
					lTransaction := .F.
					ApMsgInfo(STR0047) // "As faturas relacionadas aos documentos fiscais não foram canceladas pois não foi escolhido um Motivo de Cancelamento. por favor, faça o cancelamento manual, caso necessário."
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaNXA)
	RestArea(aArea)

Return lTransaction

//-------------------------------------------------------------------
/*/{Protheus.doc} J206Baixas
Retorna se existem baixas lançadas que não sejam de compensação

@param  cFil, Filial do Escritório

@return lRet, Existem baixas que não sejam de compensação

@author fabiana.silva
@since  27/12/2021
/*/
//-------------------------------------------------------------------
Static Function J206Baixas(cFil)
Local lRet    := .F.
Local cQuery  := ""
Local cQryRes := ""

If (lRet := J204PFinan(.F.) <> "1")
	lRet    := .F.
	cQryRes := GetNextAlias()
	cQuery  := JA204Query('TI', xFilial('NXA'),  NXA->NXA_COD, NXA->NXA_CESCR, cFil)
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQryRes, .T., .T.)

	Do While !(cQryRes)->(Eof()) .And. !lRet
		lRet := J204BxSE1((cQryRes)->SE1RECNO)
		(cQryRes)->(DbSkip())
	EndDo
	(cQryRes)->(DbCloseArea())
EndIf

Return lRet
