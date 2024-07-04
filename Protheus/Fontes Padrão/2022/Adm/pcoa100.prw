#INCLUDE "pcoa100.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "pcoicons.ch"

#Define BMP_CHK    "NOTE_PQ"
#Define BMP_INCL   "PCOBRANCO"

//Tradução PTG 20080721

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOA100  ³ AUTOR ³ Edson Maricate        ³ DATA ³ 25-11-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Programa de manutecao da planilha orcamentaria.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOA100                                                      ³±±
±±³_DESCRI_  ³ Programa de manutecao da planilha orcamentaria.              ³±±
±±³_FUNC_    ³ Esta funcao podera ser utilizada com a sua chamada normal a  ³±±
±±³          ³ partir do Menu ou a partir de uma funcao pulando assim o     ³±±
±±³          ³ browse principal e executando a chamada direta da rotina     ³±±
±±³          ³ selecionada.                                                 ³±±
±±³          ³ Exemplo : PCOA010(2) - Executa a chamada da funcao de visua- ³±±
±±³          ³                        zacao da rotina.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_PARAMETR_³ ExpN1 : Chamada direta sem passar pela mBrowse               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static nQtdEntid

Function PCOA100(nCallOpcx,cRevisa, lRev, lSim,xAutoCab, xAutoItens, xAutoEstru)

LOCAL RetC1	:= 0
LOCAL RetC2 := 0
LOCAL aCores :=  {}


PRIVATE nMvPar  := 1
PRIVATE lMvPar2 := .T.
PRIVATE lEdtPar := .F.
PRIVATE cCadastro	:= STR0001 //"Planilha Orcamentaria"
PRIVATE aRotina := MenuDef()
PRIVATE nRecAK1
PRIVATE lRecForm		:= .F.
PRIVATE lCopyPlan		:= .F.
PRIVATE lRevisao		:= If(lRev<>Nil,lRev,.F.)
PRIVATE lSimulac		:= If(lSim<>Nil,lSim,.F.)
PRIVATE aPCO100Cor

/*+-------------------------------------+
¦ Variaveis para rotina automatica    ¦
+-------------------------------------+*/
Private lPCOAuto  := ( ValType(xAutoCab) == "A" .OR. ValType(xAutoItens) == "A" .OR. ValType(xAutoEstru) == "A" )
Private aAutoCab  := {}
Private aAutoItens := {}
Private aAutoEstru := {}
Private cVldUsrCO := ''

aCores := PCO100CLEG(2)

Set Key VK_F12 To A100PBox()//FAtiva()
if lPCOAuto
	aAutoCab := xAutoCab
	aAutoItens := xAutoItens
	aAutoEstru := xAutoEstru
	MBrowseAuto(nCallOpcx,Aclone(aAutoCab),"AK1",,.T.)
Else
	If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )

		A100PBox(.T.,@RetC1,@RetC2)

		nMvPar  :=	Iif(Valtype(RetC1)!="N", VAL(RetC1), RetC1)
		lMvPar2 := Iif(Valtype(RetC2)!="N",(VAL(RetC2)== 1),RetC2== 1)

		If nCallOpcx <> Nil
			PCO100DLG("AK1",AK1->(RecNo()),nCallOpcx,,,cRevisa, lRevisao)
		Else
			mBrowse(6,1,22,75,"AK1",,,,,, aCores)
		EndIf
	endif
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCO100BLEGºAutor  ³Microsiga           º Data ³  04/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Lengenda do Browse                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PCO100BLEG(cAlias,nReg,nOpcx)

Local aLegenda := PCO100CLEG(1)

BrwLegenda(cCadastro,STR0030, aLegenda) //"Legenda"

Return


Static Function PCO100CLEG(nOpc)

Local aRetorno  		:= {}
Local aBR_COR		:= {}
Local aArea			:= GetArea()
Local nPosCor		:= 0
Local nX				:= 0

IF  ValType(aPCO100Cor) == "U"

	aPCO100Cor := {}
	AADD(aBR_COR,{"1","BR_VERMELHO"})	 // Vermelho
	AADD(aBR_COR,{"2","BR_VERDE"})			 // Verde
	AADD(aBR_COR,{"3","BR_AZUL"})				 // Azul
	AADD(aBR_COR,{"4","BR_LARANJA"})		 // Laranja
	AADD(aBR_COR,{"5","BR_CINZA"})			 // Cinza
	AADD(aBR_COR,{"6","BR_MARRON"})		 // Marron
	AADD(aBR_COR,{"7","BR_PINK"})				 // Pink
	AADD(aBR_COR,{"8","BR_AMARELO"})		 // Amarelo
	AADD(aBR_COR,{"9","BR_PRETO"})			 // Preto
	AADD(aBR_COR,{"A","BR_BRANCO"})		 // Branco

	DbSelectArea("AMO")
	DbSetOrder(1)
	DbSeek(xFilial("AMO"))
	While AMO->(!EOF()) .AND. AMO->AMO_FILIAL == xFilial("AMO")

		nPosCor := aScan(aBR_COR,{|x| x[1] == ALLTRIM(AMO->AMO_CORBRW)})
		nPosCor := IIF(nPosCor == 0, 10, nPosCor)

		AADD(aPCO100Cor,{	/*BR_COR*/ aBR_COR[nPosCor][2],;
										/*BR_STRING*/ AMO->AMO_DESCRI,;
										/*BR_REGRA*/ "AK1_FASE == '"+Alltrim(AMO->AMO_FASE)+"'"})

		AMO->(DbSkip())
	End

	// Quando o campo fase está em branco
	AADD(aPCO100Cor,{/*BR_COR*/ "BR_BRANCO",/*BR_STRING*/ "INDEFINIDA",/*BR_REGRA*/ "Empty(AK1_FASE)"})

ELSEIF ValType(aPCO100Cor) == "U"

	aPCO100Cor := {}
	// Quando o campo fase não está em uso
	AADD(aPCO100Cor,{/*BR_COR*/ "BR_BRANCO",/*BR_STRING*/ "NAO CONTROLA",/*BR_REGRA*/ "AllWaysTrue()"})

ENDIF

IF nOpc == 1

	For nX := 1 to Len(aPCO100Cor)
		AADD(aRetorno, {aPCO100Cor[nx][1]/*BR_COR*/,aPCO100Cor[nx][2]/*BR_STRING*/})
	Next nX

ELSEIF nOpc == 2

	For nX := 1 to Len(aPCO100Cor)
		AADD(aRetorno, {aPCO100Cor[nx][3]/*BR_REGRA*/,aPCO100Cor[nx][1]/*BR_COR*/})
	Next nX

ENDIF

RestArea(aArea)
Return aRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCO100DLG³ Autor ³ Edson Maricate         ³ Data ³ 28-11-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de montagem da DIALOG de manutencao da planilha     ³±±
±±³          ³ orcamentaria.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCO100DLG(cAlias,nReg,nOpcx,cR1,cR2,cVers,lRevisao)

Local oDlg, oMenu, oMenu2, oMenu3, oMenu4

Local nX			:= 0
Local nTotRev		:= 0		// Total de revisoes realizadas em uma planilha orcamentaria

Local cCOInic
Local cArquivo		:= CriaTrab(,.F.)
Local cQuery		:= ""
Local cFiltro 		:= ".T."

Local lOk
Local lSelec        := .F.
Local l100Inclui	:= .F.
Local l100Visual	:= .F.
Local l100Altera	:= .F.
Local l100Exclui	:= .F.
Local lContinua		:= .T.
Local lQuery		:= .F.
Local cAK1Fase 		:= IIF(AK1->(FieldPos('AK1_FASE')) > 0 , AK1->AK1_FASE , "")
Local aButtons		:= {}
Local aUsrButons	:= {}
Local aMenu			:= {}
Local aRetFil       := {}
Local aSize, aRotAnt
Local lPA100Alt	:= ExistBlock("PA100ALT")
Local lVldAlt	:= .T.

Local aHeaderFil, aHeaderAK2, aPeriodo, aCpoSel
Local aCampos := {}

Local aCpoAK2 := {		"AK2_CO",;
					    "AK2_DESCCO",;
						"AK2_CLASSE",;
						"AK2_DESCLA",;
						"AK2_OPER",;
						"AK2_CC",;
						"AK2_DESCCC",;
						"AK2_ITCTB",;
						"AK2_DESCIT",;
						"AK2_CLVLR",;
						"AK2_DESCCL"}

Local nI := 0
LOCAL RetC1	:= 0
LOCAL RetC2 := 0
Local lNotBlind := !IsBlind()

DEFAULT	cVers := AK1->AK1_VERSAO

aAdd(aCpoAK2, "AK2_UNIORC")

If nQtdEntid == NIL //alteracao
	If cPaisLoc == "RUS" 
		nQtdEntid := PCOQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor.
	Else
		nQtdEntid := CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
EndIf

For nI := 5 to nQtdEntid //alteracao
	aAdd(aCpoAK2, "AK2_ENT" + StrZero(nI,2,0))
Next nI

DEFAULT	cVers := AK1->AK1_VERSAO

A100TitCpo(aCpoAK2, aCampos)

lQuery := ( TcGetDb() # "AS/400" )

PRIVATE cRevisa		:= cVers
PRIVATE cCodUsu
Private nOrdAK2		:= 1



if lPCOAuto .and. ( nOPCX <> 3 .and. nOPCX <> 4 .AND. nOPCX <> 6 .AND. nOPCX <> 7 )
	AutoGrLog( "Opção "+Str(nOpcx)+" não é aceita pela rotina automatica!")
	lMostraErro := .T.
	Return .F.
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizado com as validações de fases					|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case (aRotina[nOpcx][4] == 2)
		l100Visual  := .T.
	Case (aRotina[nOpcx][4] == 3)
		If !(Pco100Fase("AMR",SuperGetMv("MV_PCOORCI",,"001"),"0001",.T.)) 	// Evento Incluir Planilha
			Return
		Else
			l100Inclui	:= .T.
		EndIf
	Case (aRotina[nOpcx][4] == 4)
		//Se for ExecAuto, posicionar no Orçamento
		If (lPCOAuto .AND. Len(aAutoCab) > 0)
			If (PCO100Posi())
				cAK1Fase := IIF(AK1->(FieldPos('AK1_FASE')) > 0 , AK1->AK1_FASE , "")
			EndIf
		EndIf
		AK1->( MsUnlock() )
		IF lPA100Alt
			lVldAlt := ExecBlock("PA100ALT",.F.,.F.)
			IF !lVldAlt
				Return
			EndIF
		ENDIF
		If !Pco100Fase("AMR",cAK1Fase,"0002",.T.) 				// Evento Alterar Planilha
			Return
		Else
			l100Altera	:= .T.
		EndIf
	Case (aRotina[nOpcx][4] == 5)
		If !Pco100Fase("AMR",cAK1Fase,"0003",.T.) 				// Evento Excluir Planilha
			Return
		Else
			lOk			:= .F.
			l100Exclui	:= .T.
			l100Visual	:= .T.
		EndIf
EndCase

If !lRevisao

	If (l100Altera .OR. l100Exclui)
		If AK1->AK1_STATUS == "2"  // ORCAMENTO EM REVISAO
			HELP("  ",1,"PCOA100REV")
			lContinua := .F.
		EndIf
	EndIf

	If lContinua .And. SuperGetMv( "MV_PCORBLQ", .F., .F. ) .And. l100Altera

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o parametro MV_PCORBLQ estiver ativo, o sistema deve verificar se existe mais de um historico ³
		//³ de revisoes para a planilha, pois soh deve bloquear se jah existir pelo menos uma revisao.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! lQuery

			AKE->( dbSetOrder( 1 ) )
			If AKE->( dbSeek( xFilial("AKE") + AK1->AK1_CODIGO ) )
				AKE->( dbEval( { || nTotRev ++ }, { || xFilial("AKE") + AKE_ORCAME == AK1->(AK1_FILIAL + AK1_CODIGO) } ) )
			EndIf

		Else

			cQuery	:= " SELECT COUNT( AKE_ORCAME ) TOTREV"
			cQuery	+= " FROM " + RetSQLName("AKE")
			cQuery	+= " WHERE "
			cQuery  += "     AKE_FILIAL = '" + xFilial("AKE")  + "'"
			cQuery  += " AND AKE_ORCAME = '" + AK1->AK1_CODIGO + "'"
			cQuery	+= " AND D_E_L_E_T_ = ' ' "
			cQuery	:= ChangeQuery(cQuery)

			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAKE", .T., .T. )

			nTotRev	:= TMPAKE->TOTREV

			TMPAKE->( dbCloseArea() )
			dbSelectArea( "AK1" )

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso jah exista uma revisao para a planilha, nao permite que o usuario faca alteracao a partir da ³
		//³ opcao de orcamento. A alteracao somente podera ser realizada a partir da opcao de revisao.        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTotRev > 1
			if lPCOAuto
				HELP("   ",1,"PLANREV",,STR0082+STR0083,3,0) //"Planilha Orçamentária já possui revisao cadastrada."###"As alterações necessárias devem ser realizadas na opção Atualizações\Planilhas\Revisões."
			else
				//"Atencao"###"Planilha Orçamentária já possui revisao cadastrada."###"As alterações necessárias devem ser realizadas na opção Atualizações\Planilhas\Revisões."###"Fechar"
				Aviso(STR0034,STR0082+STR0083,{STR0036},2)
			endif
			lContinua := .F.
		EndIf

	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica direitos do Usuario para a Entidade AK1     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. !l100Inclui .and. !lPCOAuto
	lContinua := (PcoVerAcessoPlan(nOpcx) > 0 )
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Utiliza a funcao axInclui para incluir o Orcamento   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua .And. l100Inclui
	if !lPCOAuto
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona botoes do usuario na EnchoiceBar                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock( "PCOA1002" )
			//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//P_E³ Ponto de entrada utilizado para inclusao de botoes de usuarios na      ³
			//P_E³ enchoicebar da telade cadastro de orcamentos                           ³
			//P_E³ Parametros : Nenhum                                                    ³
			//P_E³ Retorno    : Array contendo os botoes a serem adicionados na enchoice  ³
			//P_E³               Ex. :  User Function PCOA1002                            ³
			//P_E³                      Return {{PEDIDO",{||U_TESTE()},"Teste"}}          ³
			//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ValType( aUsButtons := ExecBlock( "PCOA1002", .F., .F. ) ) == "A"
				AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
			EndIf
		EndIf
	endif
	lContinua := A100IncPlan(cAlias,nReg,nOpcx,"PCO100Atu()",aButtons, aAutoCab)

	If lContinua
		cVers := AK1->AK1_VERSAO
	EndIf
	nMvPar := 1

EndIf

If lContinua
	If lNotBlind
		MENU oMenu3 POPUP
			MenuAddItem("----- "+STR0049+" -----" ,,,.F.,{|| },"","", oMenu3,) //"S a l d o s   n a   D a t a"
			dbSelectArea("AL1")
			dbSetOrder(1)
			dbSeek(xFilial())
			While !Eof() .And. AL1->AL1_FILIAL == xFilial("AL1")
				If "AKD->AKD_CODPLA+AKD->AKD_VERSAO" $ UPPER(AllTrim(AL1->AL1_CHAVER)) .Or. "AKD->AKD_CODPLA" $ UPPER(AllTrim(AL1->AL1_CHAVER))
					MenuAddItem(Space(3)+STR0050+AL1->AL1_CONFIG+" - "+Alltrim(AL1->AL1_DESCRI)+"" ,,,.T.,{|| },"","PCOCUBE", oMenu3,MontaBlock("{ || c100Sld('"+AL1->AL1_CONFIG+"') }") ,,,,,, ) //"Cubo "
				EndIf
				dbSkip()
			End
			MenuAddItem("----- "+STR0051+" -----" ,,,.F.,{|| },"","", oMenu3,)		 //"S a l d o s   p o r   P e r i o d o"
			dbSelectArea("AL1")
			dbSetOrder(1)
			dbSeek(xFilial())
			While !Eof() .And. AL1->AL1_FILIAL == xFilial("AL1")
				If "AKD->AKD_CODPLA+AKD->AKD_VERSAO" $ UPPER(AllTrim(AL1->AL1_CHAVER)).Or. "AKD->AKD_CODPLA" $ UPPER(AllTrim(AL1->AL1_CHAVER))
					MenuAddItem(Space(3)+STR0050+AL1->AL1_CONFIG+" - "+Alltrim(AL1->AL1_DESCRI) ,,,.T.,{|| },"","PCOCUBE", oMenu3,MontaBlock("{ || c100Per('"+AL1->AL1_CONFIG+"') }") ,,,,,, ) //"Cubo "
				EndIf
				dbSkip()
			End
		ENDMENU
		If nMvPar != 4

		    //Opcoes de Ordenacao dos itens da planilha
			MENU oMenu4 POPUP
				MENUITEM STR0101 ACTION (nOrdAK2:= 1, Pco100Ord( nOrdAK2, @OgD[1]))	// "Ordenar Por Item"
				MENUITEM STR0102 ACTION (nOrdAK2:= 2, Pco100Ord( nOrdAK2, @OgD[1]))	// "Ordenar Por Centro de Custo "
				MENUITEM STR0103 ACTION (nOrdAK2:= 3, Pco100Ord( nOrdAK2, @OgD[1])) 	// Ordenar Por Item Contabil
			ENDMENU

			If !l100Visual
				MENU oMenu POPUP
					MENUITEM STR0008 ACTION (Pco100to101(2,cArquivo),Eval(bRefresh,cFiltro)) //"Visualizar C.O."
					MENUITEM STR0009 ACTION Iif( Pco100Fase("AMR",cAK1Fase,"0004",.T.) ,(Pco100to101(3,cArquivo),Eval(bRefresh,cFiltro)),NIL) //"Incluir C.O."
					MENUITEM STR0010 ACTION Iif( Pco100Fase("AMR",cAK1Fase,"0005",.T.) ,(Pco100to101(4,cArquivo),Eval(bRefresh,cFiltro)),NIL) //"Alterar C.O."
					MENUITEM STR0011 ACTION Iif( Pco100Fase("AMR",cAK1Fase,"0006",.T.) ,(Pco100to101(5,cArquivo),Eval(bRefresh,cFiltro)),NIL) //"Excluir C.O."
					MENUITEM STR0151 ACTION Iif( Pco100Fase("AMR",cAK1Fase,"0004",.T.) ,(Pco100to101(6,cArquivo),Eval(bRefresh,cFiltro)),NIL) //"Incluir C.O."
				ENDMENU

				MENU oMenu2 POPUP
					MENUITEM STR0041 ACTION Iif( Pco100Fase("AMR",cAK1Fase,"0008",.T.) , (lOk:=Pco100RatVlr(cArquivo,oGd[1], (cArquivo)->XK3_CO), NIL ) , Nil ) //"Rateio de Valores nos Periodos"
					MENUITEM STR0038 ACTION Iif( Pco100Fase("AMR",cAK1Fase,"0008",.T.) , (lOk:=Pco100AltOrc(cArquivo,cVers,lRevisao,lSimulac), If(lOk, Eval(bRefresh,cFiltro), NIL)) , Nil ) //"Reajustar Valores Orcados"
					MENUITEM STR0052 ACTION Iif( Pco100Fase("AMR",cAK1Fase,"0008",.T.) , (lOk:=Pco100RecForm(cArquivo,cVers, oGd[1],lRevisao,lSimulac), If(lOk, (lRecForm:=.T.,oDlg:End()), NIL) ) , Nil ) //"Recalculo de Formulas"
					MENUITEM STR0053 ACTION Iif( Pco100Fase("AMR",cAK1Fase,"0008",.T.) , (lOk:=PcoA102(AK1->AK1_CODIGO, cVers), If(lOk, (lCopyPlan:=.T.,oDlg:End()), NIL) ) , Nil )  //"Copiar Planilha/Contas"
					MENUITEM STR0117 ACTION A100VlIp(AK1->AK1_CODIGO,cVers,bBrwChange) //"Importar dados Integração"
					MENUITEM STR0118 ACTION A100VlDs(cAK1Fase,cArquivo,oGd[1],(cArquivo)->XK3_CO) // "Distribuição Valores"
				ENDMENU
			Else
				MENU oMenu POPUP
					MENUITEM STR0008 ACTION (Pco100to101(2,cArquivo),Eval(bRefresh,cFiltro)) //"Visualizar C.O."
				ENDMENU
				MENU oMenu2 POPUP
					MENUITEM STR0041 ACTION Iif( Pco100Fase("AMR",cAK1Fase,"0008",.T.) , (lOk:=Pco100RatVlr( cArquivo, oGd[1], (cArquivo)->XK3_CO), NIL ) , Nil ) //"Rateio de Valores nos Periodos"
					MENUITEM STR0038 ACTION Iif( Pco100Fase("AMR",cAK1Fase,"0008",.T.) , (lOk:=Pco100AltOrc(cArquivo,cVers,lRevisao,lSimulac), Nil /*If(lOk, oDlg:End(), NIL)*/ ) , Nil ) //"Reajustar Valores Orcados"
					MENUITEM STR0052 ACTION Iif( Pco100Fase("AMR",cAK1Fase,"0008",.T.) , (lOk:=Pco100RecForm(cArquivo,cVers, oGd[1],lRevisao,lSimulac), If(lOk, oDlg:End(), NIL) ) , Nil ) //"Recalculo de Formulas"
					MENUITEM STR0053 ACTION Iif( Pco100Fase("AMR",cAK1Fase,"0008",.T.) , (lOk:=PcoA102(AK1->AK1_CODIGO, cVers), If(lOk, (lCopyPlan:=.T.,oDlg:End()), NIL) ) , Nil )  //"Copiar Planilha/Contas"
					MENUITEM STR0117 ACTION A100VlIp(AK1->AK1_CODIGO,cVers,bBrwChange) //"Importar dados Integração"
					MENUITEM STR0118 ACTION A100VlDs(cAK1Fase,cArquivo,oGd[1],(cArquivo)->XK3_CO) // "Distribuição Valores"
				ENDMENU
			EndIf

			aMenu := {}
			If !l100Visual
				aAdd(aMenu,	{TIP_FILTRO,        {|| PcoAK1Fil(@cFiltro),If(!Empty(cFiltro),Eval(bRefresh,cFiltro),NIL)}, BMP_FILTRO, TOOL_FILTRO})
				aAdd(aMenu,	{TIP_ORC_CONSULTAS,;
					 {||oMenu3:Activate((oMainWnd:nWidth - oMenu3:nClientWidth)/2,(oMainWnd:nHeight - oMenu3:nClientHeight)/2,) },;
					 BMP_ORC_CONSULTAS,TOOL_ORC_CONSULTAS})
				aAdd(aMenu,	{TIP_PESQUISAR,		{|| PcoAK1Pesq(cArquivo), Eval(bBrwChange) }, BMP_PESQUISAR, TOOL_PESQUISAR})
				aAdd(aMenu,	{TIP_FERRAMENTAS,   {|| PCO100Menu(@oMenu,@oMenu2,lRevisao,l100Visual,cArquivo),;
					oMenu2:Activate((oMainWnd:nWidth - oMenu2:nClientWidth)/2,(oMainWnd:nHeight - oMenu2:nClientHeight)/2,) },;
					BMP_FERRAMENTAS, STR0039}) //"Ferram."

				aAdd(aMenu,	{TIP_ORC_ESTRUTURA,	{|| PCO100Menu(@oMenu,@oMenu2,lRevisao,l100Visual,cArquivo),;
					oMenu:Activate((oMainWnd:nWidth - oMenu:nClientWidth)/2,(oMainWnd:nHeight - oMenu:nClientHeight)/2,) },;
					BMP_ORC_ESTRUTURA,TOOL_ORC_ESTRUTURA})
				aAdd(aMenu, {TIP_DOCUMENTOS, 	{|| Pco100Doc(l100Visual, lRevisao, lSimulac)}, BMP_DOCUMENTOS, TOOL_DOCUMENTOS})
				aAdd(aMenu, {TIP_ORDENACAO,;
					{|| oMenu4:Activate((oMainWnd:nWidth - oMenu4:nClientWidth)/2,(oMainWnd:nHeight - oMenu4:nClientHeight)/2,)},;
					 BMP_ORDENACAO, TOOL_ORDENACAO})// Ordena os Itens da Planilha Orcamentaria
			Else
				aAdd(aMenu,	{TIP_FILTRO,        {|| PcoAK1Fil(@cFiltro),If(!Empty(cFiltro),Eval(bRefresh,cFiltro),NIL)}, BMP_FILTRO, TOOL_FILTRO})
				aAdd(aMenu,	{TIP_ORC_CONSULTAS,;
					 {||oMenu3:Activate((oMainWnd:nWidth - oMenu3:nClientWidth)/2,(oMainWnd:nHeight - oMenu3:nClientHeight)/2,) },;
					 BMP_ORC_CONSULTAS,TOOL_ORC_CONSULTAS})
				aAdd(aMenu,	{TIP_PESQUISAR,		{|| PcoAK1Pesq(cArquivo), Eval(bBrwChange) }, BMP_PESQUISAR, TOOL_PESQUISAR})
				aAdd(aMenu,	{TIP_ORC_ESTRUTURA,	{|| PCO100Menu(@oMenu,@oMenu2,lRevisao,l100Visual,cArquivo),;
					oMenu:Activate((oMainWnd:nWidth - oMenu:nClientWidth)/2,(oMainWnd:nHeight - oMenu:nClientHeight)/2,) },;
					BMP_ORC_ESTRUTURA,TOOL_ORC_ESTRUTURA})
				aAdd(aMenu, {TIP_DOCUMENTOS, 	{|| Pco100Doc(l100Visual, lRevisao, lSimulac)}, BMP_DOCUMENTOS, TOOL_DOCUMENTOS})
				aAdd(aMenu, {TIP_ORDENACAO,;
							{|| oMenu4:Activate((oMainWnd:nWidth - oMenu4:nClientWidth)/2,(oMainWnd:nHeight - oMenu4:nClientHeight)/2,)},;
							BMP_ORDENACAO, TOOL_ORDENACAO})// "Ordena os Itens da Planilha Orcamentaria"
			EndIf
		Else
	      //edicao em modo de filtro especificando os campos
	      MENU oMenu2 POPUP
				MENUITEM STR0041 ACTION Pco100RatVlr( cArquivo,oGd[1], M->AK2_CO/*(cArquivo)->XK3_CO*/, .F.)  //"Rateio de Valores nos Periodos"
				MENUITEM STR0053 ACTION PcoA102(AK1->AK1_CODIGO, cVers)  //"Copiar Planilha/Contas"   //Alterado por Fernando Radu Muscalu em 28/09/2011
				MENUITEM STR0118 ACTION Iif( Pco100Fase("AMR",cAK1Fase,"0019",.T.) , ( lOk:=Pco100DisV("AMZ",oGd[1],M->AK2_CO) ) , NIL )
		  ENDMENU

			aMenu := {}
			aAdd(aMenu,	{STR0054,			{|| lOk := .T., oDlg:End()}, "RELATORIO", STR0055}) //"Edicao em Modo Planilha Completa"###"Completa"
			If !l100Visual
				aAdd(aMenu,	{TIP_ORC_CONSULTAS,;
					 {|| oMenu3:Activate((oMainWnd:nWidth - oMenu3:nClientWidth)/2,(oMainWnd:nHeight - oMenu3:nClientHeight)/2,) },;
					BMP_ORC_CONSULTAS,TOOL_ORC_CONSULTAS})
				aAdd(aMenu,	{TIP_FERRAMENTAS,;
					   {|| oMenu2:Activate((oMainWnd:nWidth - oMenu2:nClientWidth)/2,(oMainWnd:nHeight - oMenu2:nClientHeight)/2,) },;
					 BMP_FERRAMENTAS, STR0039}) //"Ferram."
				aAdd(aMenu, {TIP_DOCUMENTOS, {|| Pco100Doc(l100Visual, lRevisao, lSimulac)}, BMP_DOCUMENTOS, TOOL_DOCUMENTOS})
			Else
				aAdd(aMenu,	{TIP_ORC_CONSULTAS,;
					 {||oMenu3:Activate((oMainWnd:nWidth - oMenu3:nClientWidth)/2,(oMainWnd:nHeight - oMenu3:nClientHeight)/2,) },;
					 BMP_ORC_CONSULTAS,TOOL_ORC_CONSULTAS})
				aAdd(aMenu, {TIP_DOCUMENTOS, {|| Pco100Doc(l100Visual, lRevisao, lSimulac)}, BMP_DOCUMENTOS, TOOL_DOCUMENTOS})
			EndIf
		EndIf
	EndIf

	If ExistBlock("PCOA1007")
		ExecBlock("PCOA1007",.F.,.F.,cArquivo)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ExecBlock para inclusao de botoes customizados       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PCOA1003")
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios na     ³
		//P_E³ tela da planilha orcamentaria                                          ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na planilha ³
		//P_E³              [1] : Titulo                                              ³
		//P_E³              [2] : Codeblock contendo a funcao do usuario              ³
		//P_E³              [3] : Resource utilizado no bitmap                        ³
		//P_E³              [4] : Tooltip do bitmap                                   ³
		//P_E³              Exemplo :                                                 ³
		//P_E³              User Function PCOXFUN1                                    ³
		//P_E³              Return {{"Titulo", {|| U_Botao() }, "BPMSDOC","Titulo" }} ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aUsrButons := ExecBlock("PCOA1003",.F.,.F.)
		For nx := 1 to Len(aUsrButons)
			aAdd(aMenu,{aUsrButons[nx,1],aUsrButons[nx,2],aUsrButons[nx,3],aUsrButons[nx,4]})
		Next
	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ExecBlock para inclusao de Filtro definido por usuario    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PCOA1005")
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de filtro como funcoes de     ³
		//P_E³ usuarios na tela da planilha orcamentaria                              ³
		//P_E³ tela da planilha orcamentaria                                          ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : Array contendo:                                           ³
		//P_E³           { String Filtro, String Conta Orcamentaria Inicial }         ³
		//P_E³           Exemplo :                                                    ³
		//P_E³           User Function PCOA1005                                       ³
		//P_E³           Local cFiltro, cConta                                        ³
		//P_E³           cFiltro:="AK3->AK3_CO == PadR('3202010201',Len(AK3->AK3_CO))"³
		//P_E³           cConta := PadR('3202010201',Len(AK3->AK3_CO))                ³
		//P_E³           Return({cFiltro, cConta}                                     ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRetFil := ExecBlock("PCOA1005",.F.,.F.)
		cFiltro := aRetFil[1]
		cCOInic := aRetFil[2]
		If (cCOInic != Nil .And. Empty(cCOInic)) .OR. ;
			! l100Altera
			cCOInic := NIL
		EndIf

	Else

		If (l100Altera .And. nMvPar > 1) .OR. (l100Visual .And. nMvPar == 4)

			cCodUsu := RetCodUsr()
			aSize		:= MsAdvSize(,.F.,430)
			aRotAnt     := aRotina
			aRotina     := {}

	        If nMvPar == 4

				aHeaderFil := {}
				aHeaderAK2 := {}
				aCpoSel := {}

				aPeriodo := PcoRetPer()
				M->AK2_CO := AK1->AK1_CODIGO

				lContinua := A100Espec_Cpos(aHeaderFil, aHeaderAK2, aPeriodo, aCampos, aCpoAK2, aCpoSel, lEdtPar)

			ElseIf nMvPar == 3 .And. ;//Filtro por Usuario
				AK1->AK1_CTRUSR == "1"  .And. ;//Controle de Usuarios Habilitado
				cCodUsu != "000000"  //usuario administrador
				AKG->(dbSetOrder(2))
				__MaWndBrowse(aSize[7],0,aSize[6],aSize[5],STR0012,"AKG",,aRotina,,"xFilial('AKG')+AK1->AK1_CODIGO+cCodUsu","xFilial('AKG')+AK1->AK1_CODIGO+cCodUsu",.F.,,,{{STR0014,2}},xFilial('AKG')+AK1->AK1_CODIGO+cCodUsu,,, @lSelec)  //"Usuario x Conta Orcamentaria - Posicione na C.O. desejada" //"Conta Orcamentaria"
				If ! lSelec
					lContinua := .F.
				EndIf
				cCOInic := AKG->AKG_CO
			Else
				AK3->(dbSetOrder(3))
				AK3->(dbGoTop())
				lRet := .F.
				While ! lRet
					__MaWndBrowse(aSize[7],0,aSize[6],aSize[5],STR0015,"AK3",,aRotina,,"xFilial('AK3')+AK1->AK1_CODIGO+cRevisa","xFilial('AK3')+AK1->AK1_CODIGO+cRevisa",.F.,,,{{STR0014,1}},xFilial('AK3')+AK1->AK1_CODIGO+cRevisa,,, @lSelec)   //"Contas Orcamentarias da Planilha  - Posicione na C.O. desejada"###"Conta Orcamentaria"
					If ! lSelec
						lContinua := .F.
						Exit
					EndIf
					cCOInic := AK3->AK3_CO
					If PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,1,"ESTRUT",AK3->AK3_VERSAO)
						lRet := .T.
						Exit
					Else
						HELP("  ",1,"PCONOACESS",,Alltrim(AK3->AK3_CO))
						lSelec := .F.
					EndIf
				End
			EndIf
			aRotina := aRotAnt
		Else
			nMvPar := 1
		EndIf
	EndIf

	If lContinua
		if !lPCOAuto
			If nMvPar != 4
				dbSelectArea("AK1")
				PCOAK1PLAN(STR0001,,cArquivo,@lOk,aMenu,@oDlg,,,l100Visual, cFiltro, cCOInic,lMvpar2) //"Planilha Orcamentaria"
			Else
				PCOAK2PLAN(STR0001,cArquivo,@lOk,aMenu,@oDlg, cFiltro, cCOInic, aHeaderFil, aHeaderAK2, aPeriodo, aCpoAK2, aCampos, aCpoSel, @lEdtPar, l100Visual) //"Planilha Orcamentaria"
				If lOk
					If lOk <> Nil .And. lOk
						If MsgNoYes( STR0054 + " ?", STR0034 )
							nMvPar := 1
							PCO100DLG(cAlias,nReg,nOpcx,cR1,cR2,cVers,lRevisao)
						EndIf
						A100PBox(.T.,@RetC1,@RetC2)
						nMvPar  :=	Iif(Valtype(RetC1)!="N", VAL(RetC1), RetC1)
						lMvPar2 := Iif(Valtype(RetC2)!="N",(VAL(RetC2)== 1),RetC2== 1)
					EndIf
				EndIf
			EndIf
		else
			If nOpcx = 4 .AND. Valtype(aAutoEstru) = "A" .AND. Len(aAutoEstru) > 0
				// Alteração da Estrutura da Planilha
				PCO100to101(3, , aAutoEstru)
			EndIf
			if nOpcx = 4 .and. Valtype(aAutoItens) = "A" .and. Len(aAutoItens) > 0
				// Alteração dos itens automatica
				if A100VCabec(aAutoCab)
					PCOAK1Aut(STR0001,,cArquivo,@lOk,aMenu,@oDlg,,,l100Visual, cFiltro, cCOInic,lMvpar2, nOpcx)
				endif
			endif
		EndIf
	EndIf

	If nMvPar != 4
		If l100Exclui
			If A100Conf(5) .And. ((lOk <> Nil .And. lOk) .Or. lPCOAuto)
			   If AK1->AK1_STATUS == "2"
			      Help("  ",1,"PCOA1201")
			   Else
					PcoIniLan("000252")
					A100Exclui()
					PcoFinLan("000252")
			   EndIf
			EndIf
		ElseIf lRecForm <> NIL .And. lRecForm
			If lOk <> Nil .And. lOk
				PCO100DLG(cAlias,nReg,nOpcx,cR1,cR2,cVers,lRevisao)
	    	EndIf
		ElseIf lCopyPlan <> NIL .And. lCopyPlan
			If lOk <> Nil .And. lOk
				PCO100DLG(cAlias,nReg,nOpcx,cR1,cR2,cVers,lRevisao)
	    	EndIf
		EndIf
	EndIf

	//Limpa variaveis static
	If ExistFunc("PCOCleanSt")
		PCOCleanSt()
	EndIf
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCO100ATU³ Autor ³ Edson Maricate         ³ Data ³ 28-11-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de chamada da rotina de atualiacao das tabelas relacio³±±
±±³          ³ nadas a planilha orcamentaria.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCO100ATU()

nRecAK1 := Recno()
PcoAvalAK1("AK1",1)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCO100Menu³ Autor ³ Edson Maricate        ³ Data ³ 28-11-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de controle do menu de atualizacoes.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCO100Menu(oMenu,oMenu2,lRevisao,lVisual,cArquivo)
Local aArea		:= GetArea()
Local cAlias
Local nRecView

cAlias	:= (cArquivo)->ALIAS
nRecView	:= (cArquivo)->RECNO
dbSelectArea(cAlias)
dbGoto(nRecView)

If !lVisual
	Do Case
		Case !Eval(oEdit:bWhen) .And. Eval(oWrite:bWhen)
			//se estiver em edicao nao deve habilitar os menus
				oMenu:aItems[1]:Enable()
				oMenu:aItems[2]:Disable()
				oMenu:aItems[3]:Disable()
				oMenu:aItems[4]:Disable()
				oMenu:aItems[5]:Disable()
				oMenu2:aItems[1]:Enable()
				oMenu2:aItems[2]:Disable()
				oMenu2:aItems[3]:Disable()
				oMenu2:aItems[4]:Disable()

		Case cAlias == "AK3" .And. AK3->AK3_NIVEL=="001"
			If PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,Space(Len(AK3->AK3_PAI)),2,"ESTRUT",AK3->AK3_VERSAO)
				oMenu:aItems[1]:Enable()
				oMenu:aItems[2]:Enable()
				oMenu:aItems[3]:Disable()
				oMenu:aItems[4]:Disable()
				oMenu:aItems[5]:Enable()
				oMenu2:aItems[1]:Disable()
				oMenu2:aItems[2]:Disable()
				oMenu2:aItems[3]:Disable()
				oMenu2:aItems[4]:Enable()
			Else
				oMenu:aItems[1]:Enable()
				oMenu:aItems[2]:Disable()
				oMenu:aItems[3]:Disable()
				oMenu:aItems[4]:Disable()
				oMenu:aItems[5]:Disable()
				oMenu2:aItems[1]:Disable()
				oMenu2:aItems[2]:Disable()
				oMenu2:aItems[3]:Disable()
				oMenu2:aItems[4]:Disable()
			EndIf
		Case cAlias == "AK3"
			If PcoChkUser(AK3->AK3_ORCAME,AK3->AK3_CO,AK3->AK3_PAI,2,"ESTRUT",AK3->AK3_VERSAO)
				oMenu:aItems[1]:Enable()
				oMenu:aItems[2]:Enable()
				oMenu:aItems[3]:Enable()
				oMenu:aItems[4]:Enable()
				oMenu:aItems[5]:Enable()
				oMenu2:aItems[1]:Enable()
				oMenu2:aItems[2]:Enable()
				oMenu2:aItems[3]:Enable()
				oMenu2:aItems[4]:Enable()
			Else
				oMenu:aItems[1]:Enable()
				oMenu:aItems[2]:Disable()
				oMenu:aItems[3]:Disable()
				oMenu:aItems[4]:Disable()
				oMenu:aItems[5]:Disable()
				oMenu2:aItems[1]:Disable()
				oMenu2:aItems[2]:Disable()
				oMenu2:aItems[3]:Disable()
				oMenu2:aItems[4]:Disable()
			EndIf
		Otherwise
			oMenu:aItems[1]:Enable()
			oMenu:aItems[2]:Disable()
			oMenu:aItems[3]:Disable()
			oMenu:aItems[4]:Disable()
			oMenu:aItems[5]:Disable()
			oMenu2:aItems[1]:Disable()
			oMenu2:aItems[2]:Disable()
			oMenu2:aItems[3]:Disable()
			oMenu2:aItems[4]:Disable()
	EndCase

Else
	oMenu:aItems[1]:Enable()
	oMenu2:aItems[1]:Disable()
	oMenu2:aItems[2]:Disable()
	oMenu2:aItems[3]:Disable()
	oMenu2:aItems[4]:Disable()
	oMenu2:aItems[5]:Disable()
EndIf

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCO100to101³ Autor ³ Edson Maricate       ³ Data ³ 10-12-2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de chamada do PCOA101 para atualizacao do CO           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PCOA100                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCO100to101(nOpc,cArquivo, xAutoEstru)

Local aArea		:= GetArea()
Local cAK1Fase 	:= IIF(AK1->(FieldPos('AK1_FASE')) > 0 , AK1->AK1_FASE , "")

/**
Rotina Automática
**/
Local l100Auto  := IIf(ValType(xAutoEstru) == "A", .T., .F.) //Rotina Automatica ?
Local nC        := 0 //Controle do FOR
Local nX        := 0 //Controle do FOR
Local nPosPlan  := 0 //Posição do Campo AK3_ORCAME
Local nPosVers  := 0 //Posição do Campo AK3_VERSAO
Local nPosPai   := 0 //Posição do Campo AK3_PAI
Local nPosConta := 0 //Posição do Campo AK3_CO
Local cNivelCO  := StrZero(01, TamSX3('AK3_NIVEL')[01]) //Nivel da C.O. na Estrutura

Default xAutoEstru := {}
Default cArquivo   := ''


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ExecBlock para inclusao de botoes customizados       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PCOA1004")
	//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//P_E³ Ponto de entrada utilizado para validacao da rotina chamada no menu    ³
	//P_E³ Estrutura no programa de atualizacao da planilha orcamentaria.         ³
	//P_E³ Parametros : [1] - Numerico - Opcao selecionada                        ³
	//P_E³ Retorno    : Logico - Permite ou na a utilizacao da opcao selecionada. ³
	//P_E³              Exemplo :                                                 ³
	//P_E³              User Function PCOA1004                                    ³
	//P_E³              Local lRet := .F.                                         ³
	//P_E³              If ParamIXB[1] == 1                                       ³
	//P_E³                 lRet := .T.                                            ³
	//P_E³              EndIf                                                     ³
	//P_E³              Return lRet                                               ³
	//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ExecBlock("PCOA1004", .F., .F., {nOpc})
		RestArea(aArea)
		Return
	EndIf
EndIf

//Verifica se é rotina automática
If (l100Auto)
	//Percorrendo o Array e Adicionando as Contas Pai
	PCO100AdPai(@xAutoEstru)
	//Percorre o array e verifica se é inclusão ou alteração da C.O.
	For nC := 1 To Len(xAutoEstru)
		//Buscando a Posição do Campo AK3_ORCAME
		nPosPlan  := AScan(xAutoEstru[nC], {|x| AllTrim(x[01]) == 'AK3_ORCAME'})
		//Buscando a Posição do Campo AK3_VERSAO
		nPosVers  := AScan(xAutoEstru[nC], {|x| AllTrim(x[01]) == 'AK3_VERSAO'})
		//Buscando a Posição do Campo AK3_CO
		nPosConta := AScan(xAutoEstru[nC], {|x| AllTrim(x[01]) == 'AK3_CO'})
		//Buscando a Posição do Campo AK3_PAI
		nPosPai   := AScan(xAutoEstru[nC], {|x| AllTrim(x[01]) == 'AK3_PAI'})
		//Caso encontrou todos os campos, prosseguir
		If (nPosPlan > 0 .AND. nPosVers > 0 .AND. nPosConta > 0 .AND. nPosPai > 0)
			//Alimentando Array de referência
			aGetCpos := {}
			For nX := 1 To Len(xAutoEstru[nC])
				AAdd(aGetCpos, {xAutoEstru[nC][nX, 01], xAutoEstru[nC][nX, 02], .F.})
			Next nX
			//Verifica se a C.O. da Planilha já existe
			If !(AK3->(DbSeek(FWxFilial('AK3') +;
				PadR(xAutoEstru[nC][nPosPlan, 02], TamSX3('AK3_ORCAME')[01]) +;
				PadR(xAutoEstru[nC][nPosVers, 02], TamSX3('AK3_VERSAO')[01]) +;
				PadR(xAutoEstru[nC][nPosConta, 02] , TamSX3('AK3_CO')[01]) ;
				)))
				/*Inclusão*/
				//Pegando o último Nível para a Planilha
				If !(Empty(xAutoEstru[nC][nPosPai, 02]))
					DbSelectArea('AK3')
					AK3->(DbSetOrder(01)) //AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_CO
					If (AK3->(DbSeek(FWxFilial('AK3') +;
						PadR(xAutoEstru[nC][nPosPlan, 02], TamSX3('AK3_ORCAME')[01]) +;
						PadR(xAutoEstru[nC][nPosVers, 02], TamSX3('AK3_VERSAO')[01]) +;
						PadR(xAutoEstru[nC][nPosPai, 02] , TamSX3('AK3_CO')[01]) ;
						)))
						cNivelCO := AK3_NIVEL
					EndIf
				EndIf
				//Processando
				nRecAK3	:= PCOA101(3, aGetCpos, cNivelCO, l100Auto)
			Else
				//Alteração
				nRecAK3	:= PCOA101(4, aGetCpos, cNivelCO, l100Auto)
			EndIf
		EndIf
	Next nC
Else
	cAlias := (cArquivo)->ALIAS
	nRecAlias := (cArquivo)->RECNO

	dbSelectArea(cAlias)
	dbGoto(nRecAlias)
	Do Case
		Case nOpc == 2
			PCOA101(2,,"000")
		Case nOpc == 3
			//17/08/2010 Alteração para validação de permissões do usuário atraves da fase.
			If Pco100Fase("AMR",cAK1Fase,"0004")
				aGetCpos := {	{"AK3_ORCAME",AK3->AK3_ORCAME,.F.},;
								{"AK3_VERSAO",AK3->AK3_VERSAO,.F.},;
								{"AK3_PAI",AK3->AK3_CO,.F.}}
				nRecAK3	:= PCOA101(3,aGetCpos,AK3->AK3_NIVEL)
			EndIf
		Case nOpc == 4
			//17/08/2010 Alteração para validação de permissões do usuário atraves da fase.
			If Pco100Fase("AMR",cAK1Fase,"0005")
				PCOA101(4,,"000")
			EndIf
		Case nOpc == 5
			//17/08/2010 Alteração para validação de permissões do usuário atraves da fase.
			If Pco100Fase("AMR",cAK1Fase,"0006")
				If PadR(AK3_ORCAME, Len(AK3_CO))!=PadR(AK3_CO, Len(AK3_CO))
					PCOA101(5,,"000")
				EndIf
			EndIF
		Case nOpc == 6  //INCLUSAO POR LOTE É IGUAL A INCLUSAO 
			//17/08/2010 Alteração para validação de permissões do usuário atraves da fase.
			If Pco100Fase("AMR",cAK1Fase,"0004")
				aGetCpos := {	{"AK3_ORCAME",AK3->AK3_ORCAME,.F.},;
								{"AK3_VERSAO",AK3->AK3_VERSAO,.F.},;
								{"AK3_PAI",AK3->AK3_CO,.F.}}
				nRecAK3	:= PCOA101(6,aGetCpos,AK3->AK3_NIVEL)
			EndIf
	EndCase
EndIf

RestArea(aArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A100ExcluiºAutor  ³Paulo Carnelossi    º Data ³  13/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ funcao para exclusao do orcamento e suas dependencias      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A100Exclui()
Local cOrcame := AK1->AK1_CODIGO
Local cAK1Fase:= IIF(AK1->(FieldPos('AK1_FASE')) > 0 , AK1->AK1_FASE , "")

//17/08/2010 Alteração para validação de permissões do usuário atraves da fase.
If Pco100Fase("AMR",cAK1Fase,"0003")

	Begin Transaction

	//exclui as versões simuladas
	dbSelectArea("AKR")
	dbSetOrder(1)

	While dbSeek(xFilial("AKR")+cOrcame)
		RecLock("AKR",.F.,.T.)
		dbDelete()
		MsUnlock()
	End

	//exclui a amarracao usuario x conta orcamentaria
	dbSelectArea("AKG")
	dbSetOrder(1)

	While dbSeek(xFilial("AKG")+cOrcame)
		RecLock("AKG",.F.,.T.)
		dbDelete()
		MsUnlock()
	End

	//exclui a ITENS da conta orcamentaria
	dbSelectArea("AK2")
	dbSetOrder(1)

	While dbSeek(xFilial("AK2")+cOrcame)
		If AK2->AK2_VERSAO == AK1->AK1_VERSAO
			PcoDetLan("000252","01","PCOA100",.T.)
		Else
			PcoDetLan("000252","02","PCOA100",.T.)
		EndIf
		RecLock("AK2",.F.,.T.)
		dbDelete()
		MsUnlock()
	End

	//exclui contas orcamentaria da planilha
	dbSelectArea("AK3")
	dbSetOrder(1)

	While dbSeek(xFilial("AK3")+cOrcame)
		RecLock("AK3",.F.,.T.)
		dbDelete()
		MsUnlock()
	End

	//exclui o registro de revisoes
	dbSelectArea("AKE")
	dbSetOrder(1)

	While dbSeek(xFilial("AKE")+cOrcame)
		RecLock("AKE",.F.,.T.)
		dbDelete()
		MsUnlock()
	End

	//exclui contas orcamentaria da planilha
	dbSelectArea("AK1")
	dbSetOrder(1)

	While dbSeek(xFilial("AK1")+cOrcame)
		RecLock("AK1",.F.,.T.)
		dbDelete()
		MsUnlock()
	End

	End Transaction

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOA100   ºAutor  ³Paulo Carnelossi   º Data  ³  13/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao identica a MaWndBrowse() somente o botao Sair foi   º±±
±±º          ³ renomeado para Selecionar                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function __MaWndBrowse(nLin1,nCol1,nLin2,nCol2,cTitle,uAlias,aCampos,aRotina,cFun,cTopFun,cBotFun,lCentered,aResource,nModelo,aPesqui,cSeek,lDic,lSavOrd, lOk)

Local oBrowse
Local oRes1
Local oRes2
Local cCodeBlock
Local nButtonSize := 35
Local cSavCad := cCadastro
Local bViewReg	:= {|| Nil }
LOCAL nMyWidth  := oMainWnd:nClientWidth - 7
LOCAL nMyHeight := oMainWnd:nClientHeight- 34
Local bWhen     := {||.T.}
Local nY		:= 0

DEFAULT nModelo := 2
DEFAULT lDic    := .T.
DEFAULT lSavOrd := .T.

Private oWind

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define tamanho padrao da janela.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLin1 := IIF(nLin1!=Nil,nLin1,120)
nCol1 := IIF(nCol1!=Nil,nCol1,83)
nLin2 := IIF(nLin2!=Nil,nLin2,nMyHeight)
nCol2 := IIF(nCol2!=Nil,nCol2,nMyWidth)

If lDic
	dbSelectArea(uAlias)
	dbSeek(xFilial())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o code block para visualizacao do registro            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ny := 1 to Len(aRotina)
	If Len(aRotina[ny])==7 .And. aRotina[ny][7]
		cCodeBlock := "{||WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+"(Alias(),RecNo(),"+Str(ny)+"),oWind:End()}"
	Else
		cCodeBlock := "{||WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+"(Alias(),RecNo(),"+Str(ny)+"),oBrowse:SetFocus(),oBrowse:Refresh()}"
	EndIf
	If aRotina[ny][4] == 2
		bViewReg := &cCodeBlock
	EndIf
Next

DEFINE MSDIALOG oWind TITLE cTitle FROM nLin1,nCol1 TO nLin2,nCol2 Of oMainWnd PIXEL
	If nModelo == 1

      oBrowse := MaMakeBrow(oWind,uAlias,{14, 2, ((nCol2-nCol1)/2)-2, ((nLin2-nLin1)/2-If(aResource==Nil,14,22))},,lDic,aCampos,cFun,cTopFun,cBotFun,aResource,bViewReg)

		@ 0, 0 BITMAP oBmp RESNAME "TOOLBAR" oF oWind SIZE 600,20  NOBORDER WHEN .F. PIXEL

		If aResource != Nil
			@ ((nLin2-nLin1)/2-7),6 BITMAP oRes1 RESOURCE aResource[1][1] SIZE 8,8 Of oWind PIXEL NOBORDER
			@ ((nLin2-nLin1)/2-7),18 SAY aResource[1][2] Of oWind SIZE 60,9 PIXEL
			@ ((nLin2-nLin1)/2-7),(((nCol2-nCol1)/2)/2)+5 BITMAP oRes2 RESOURCE aResource[2][1] SIZE 8,8 Of oWind PIXEL NOBORDER
			@ ((nLin2-nLin1)/2-7),(((nCol2-nCol1)/2)/2)+17 SAY aResource[2][2] Of oWind PIXEL

			@ 19,2 TO 23,((nCol2-nCol1)/2) LABEL '' Of oWind PIXEL
		EndIf

	   TButton():New( 1, 3, "&"+STR0002, oWind ,{||WndxPesqui(oBrowse,aPesqui,cSeek,lSavOrd)}, nButtonSize, 12,,oWind:oFont, .F., .T., .F.,, .F.,,) //"Pesquisar"

		For ny := 1 to Len(aRotina)
			If (Len(aRotina[ny]) == 6)
				bWhen:= IIf(aRotina[ny][6],{||.T.},{||.F.})
			Else
				bWhen:= {||.T.}
			EndIf

			If Len(aRotina[ny])==7 .And. aRotina[ny][7]

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verificacao de arquivo vazio.                           ³
				//³Dependendo da operação valida a existencia de registros.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aRotina[ny][4] == 3
					cCodeBlock := "{||WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+"(Alias(),RecNo(),"+Str(ny)+"),oWind:End()}"
				Else
					cCodeBlock := "{||IIf(&('"+Alias()+"->(Eof())'),Help(' ',1,'ARQVAZIO'),(WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+"(Alias(),RecNo(),"+Str(ny)+"),oWind:End()))}"
				EndIf

			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verificacao de arquivo vazio.                           ³
				//³Dependendo da operação valida a existencia de registros.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aRotina[ny][4] == 3
					cCodeBlock := "{||WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+"(Alias(),RecNo(),"+Str(ny)+"),oBrowse:SetFocus(),oBrowse:Refresh()}"
				Else
					cCodeBlock := "{||IIf(&('"+Alias()+"->(Eof())'),Help(' ',1,'ARQVAZIO'),(WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+"(Alias(),RecNo(),"+Str(ny)+"),oBrowse:SetFocus(),oBrowse:Refresh()))}"
				EndIf
			EndIf

		   TButton():New( 1, 3+((ny)*nButtonSize), aRotina[ny][1], oWind ,&cCodeBlock  , nButtonSize, 12,,oWind:oFont, .F., .T., .F.,, .F.,bWhen,)
		Next ny


	   TButton():New( 1, 3+((Len(aRotina)+1)*nButtonSize), OemToAnsi(STR0013) , oWind ,{|| lOk := .T.,oWind:End()} , nButtonSize, 12,,oWind:oFont, .F., .T., .F.,, .F.,, )  //"&Selecionar"

	Else

      oBrowse := MaMakeBrow(oWind,uAlias,{2,nButtonSize+3, ((nCol2-nCol1)/2)-nButtonSize-4, ((nLin2-nLin1)/2-If(aResource==Nil,2,10))},,lDic,aCampos,cFun,cTopFun,cBotFun,aResource,bViewReg)

		If aResource != Nil
			@ ((nLin2-nLin1)/2-7),6 BITMAP oRes1 RESOURCE aResource[1][1] SIZE 8,8 Of oWind PIXEL NOBORDER
			@ ((nLin2-nLin1)/2-7),18 SAY aResource[1][2] Of oWind SIZE 60,9 PIXEL
			@ ((nLin2-nLin1)/2-7),(((nCol2-nCol1)/2)/2)+5 BITMAP oRes2 RESOURCE aResource[2][1] SIZE 8,8 Of oWind PIXEL NOBORDER
			@ ((nLin2-nLin1)/2-7),(((nCol2-nCol1)/2)/2)+17 SAY aResource[2][2] Of oWind PIXEL

			@ 19,2 TO 23,((nCol2-nCol1)/2) LABEL '' Of oWind PIXEL
		EndIf


	   TButton():New( 2, 1, "&"+STR0002, oWind ,{||WndxPesqui(oBrowse,aPesqui,cSeek,lSavOrd)}, nButtonSize, 9,,oWind:oFont, .F., .T., .F.,, .F.,,) //"Pesquisar"

		For ny := 1 to Len(aRotina)
			If (Len(aRotina[ny]) == 6)
				bWhen:= IIf(aRotina[ny][6],{||.T.},{||.F.})
			Else
				bWhen:= {||.T.}
			EndIf

			If Len(aRotina[ny])==7 .And. aRotina[ny][7]
				cCodeBlock := "{||WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+"(Alias(),RecNo(),"+Str(ny)+"),oWind:End()}"
			Else
				cCodeBlock := "{||WMudaCad(cTitle,'"+aRotina[ny][1]+"'),"+ aRotina[ny][2]+"(Alias(),RecNo(),"+Str(ny)+"),oBrowse:SetFocus(),oBrowse:Refresh()}"
			EndIf

		   TButton():New( 2+(ny*10) , 1 , aRotina[ny][1], oWind ,&cCodeBlock  , nButtonSize, 9,,oWind:oFont, .F., .T., .T.,, .F.,bWhen,)
		Next ny

	   TButton():New( 2+((Len(aRotina)+1)*10), 1, OemToAnsi(STR0013) , oWind ,{||  lOk := .T., oWind:End()} , nButtonSize, 9,,oWind:oFont, .F., .T., .F.,, .F.,, ) //"&Selecionar"

	EndIf


If lCentered
	ACTIVATE MSDIALOG oWind CENTERED
Else
	ACTIVATE MSDIALOG oWind
EndIf

cCadastro := cSavCad

Return NIL




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FAtiva    ºAutor  ³Jair Ribeiro 		 º Data ³  08/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Parambox para tipo de exibicao planilha				      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lPload:.T. para chamada da funcao paramload (Default .F.)  º±±
±±º          ³ RetC1: Resposta combo 1                                    º±±
±±º          ³ RetC2: Resposta combo 2                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A100PBox(lPload,RetC1,RetC2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rotina alterada para chamda de um parambox³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local alPerg	:= {}
	Local alRec		:= {}
	Local llConfirm	:= .F.
	Local clText	:= STR0106
	Local cLoad		:= 	__cUserID+"_PCOA100"
	Default lPload	:=  .F.

	aAdd(alPerg ,{2		,STR0107		,1,{"1="+STR0109,"2="+STR0110,"3="+STR0111,"4="+STR0112}	,80,"",.T.})
	aAdd(alPerg ,{2		,STR0108		,1,{"1="+STR0113,"2="+STR0114}								,80,"",.T.})
	aAdd(alPerg ,{9		,clText			,200														,50	  ,.T.})

	If lPload
		RetC1:=ParamLoad(cLoad,alPerg,1,"1")
		RetC2:=ParamLoad(cLoad,alPerg,2,"1")
 	ElseIf llConfirm := Parambox(alPerg,STR0115,alRec,,,,,,,"PCOA100",.T.,.T.)
 		nMvPar 	:= Iif(Valtype(alRec[1])!="N", VAL(alRec[1]), alRec[1])
		lMvPar2 := Iif(Valtype(alRec[2])!="N",(VAL(alRec[2])== 1),alRec[2]== 1)
 	EndIf
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco100AltOrc³ Autor ³Paulo Carnelossi      ³ Data ³ 06/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que altera os valores orcados da planilha              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco100AltOrc(cArquivo, cRevisa,lRevisa , lSimula)
Local lRet		:= .T.
Local aParam    := {}
Local aTipos    := {STR0016,STR0017, STR0018,STR0096} //"Por Percentual Normal"###"Por Percentual Embutido"###"Por Valor"##"Formula"
Local aCalculo  := {STR0019,STR0020, STR0021} //"Somar"###"Diminuir"###"Substituir Valor"
Local aAplica   := {STR0022, STR0023} //"Conta Orcamentaria Posicionada"###"Todas as Contas Orcamentarias"
Local aPeriodo  := {STR0024, STR0025,STR0097} //"Todos"###"Para o(s) Periodo(s) Informado(s)"##"A partir do periodo informado"
Local cBlqRMes  := SuperGetMV( "MV_PCOBLRM", .F., "0" )
DEFAULT lRevisa	:=	.F.
DEFAULT lSimula	:=	.F.
If ! Eval(oWrite:bWhen)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o evento de alteracao no Fase atual.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ParamBox( {	{3,STR0026,1,aTipos,130,"",.F.},; //"Tipo de Reajuste"
					{3,STR0027,1,aCalculo,130,"",.F.},; //"Operacao"
					{3,STR0028,1,aAplica,130,"",.F.},; //"Aplicar a"
					{3,STR0029,1,aPeriodo,130,"",.F.},; //"Para o(s) Periodo(s)"
					{7,STR0030,"AK3",""},; //"Filtro Contas Orcamentarias"
					{7,STR0040,"AK2",""},; //"Filtro Itens das Contas Orcamentarias"
					{1,STR0031,0             ,"@E 9,999,999,999.99","","","mv_par01 <> 4",100,.F.},; //"Valor ou Percentual"
					{1,STR0032,CtoD(Space(8)),"@D"                 ,"","","mv_par04 <> 1",100,.F.},;
					{1,STR0098,CtoD(Space(8)),"@D"                 ,"mv_par09 >= mv_par08","","mv_par04 == 2",100,.F.},;  //"Data Final do Periodo"
					{1,STR0096,Space(Len(SM4->M4_CODIGO)),"@!","ExistCpo('SM4')","SM4","mv_par01 == 4",100,.F.}},STR0033,@aParam) //"Data Inicial Periodo"###"Parametros"##"Formula"
		lRet := .F.
	EndIf

	If lRet .And. aParam[4] == 2 .And. Empty(aParam[8])
		Aviso(STR0034,STR0035,{STR0036},2)  //"Atencao"###"Nao informado o periodo a ser reajustado!"###"Fechar"
		lRet := .F.
	EndIf

	If lRet .And. lRevisa
		If cBlqRMes == "1"	// Bloqueia revisao de orcamento anterior ao mes de inicio da revisao
			AKE->( dbSetOrder(1) )
			AKE->( MsSeek( xFilial("AKE") + AK1->AK1_CODIGO + cRevisa ) )
			If DtoS(AKE->AKE_DATAI) <= DtoS(AK1->AK1_FIMPER)
				If aParam[4] == 1
					cDataPos := DtoS(AK1->AK1_INIPER)
				ElseIf aParam[4] == 2 .Or. aParam[4] == 3
					cDataPos := DtoS(aParam[8])
				Else
					lRet := .F.
				EndIf
				If lRet
					lRet := Left(cDataPos,6) >= Left(DtoS(AKE->AKE_DATAI),6)
				EndIf
			Else
				lRet := .F.
			EndIf
			If !lRet
				Aviso( STR0034, STR0100,{"Ok"})  //"Atenção"##"Período inválido. É permitido revisar apenas os períodos subsequentes à data de início da revisão."
			EndIf
		EndIf
	EndIf

	If lRet
		PcoIniLan('000252')
		Processa({||Pco100Reaj(cArquivo,cRevisa,aParam,lRevisa,lSimula)},STR0037) //"Atualizando valores orcamentarios. Aguarde..."
		PcoFinLan('000252')
	EndIf
Else
	MsgAlert(STR0150)	//Não é permitido reajustar os valores em modo de edição ativa
	lRet := .F.
EndIf

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco100Reaj  ³ Autor ³Paulo Carnelossi      ³ Data ³ 06/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que altera os valores orcados da planilha              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco100Reaj(cArquivo,cRevisa,aParam,lRevisa,lSimula)
Local cAlias := Alias()
Local aArea := GetArea()
Local aAreaAK3 := AK3->(GetArea())
Local cContaOrc := (cArquivo)->XK3_CO
Local cChave, bCondic
DEFAULT lRevisa	:=	.F.
DEFAULT lSimula :=	.F.

dbSelectArea("AK3")
dbSetOrder(1)
cChave := xFilial("AK3")+AK1->AK1_CODIGO+cRevisa

If aParam[3] == 2 //Todas as Contas
	dbSeek(cChave)
	bCondic := {||!Eof() .And. AK3_FILIAL == xFilial("AK3") .And. ;
					AK3_ORCAME == AK1->AK1_CODIGO .And. ;
					AK3_VERSAO == cRevisa }
Else            //somente conta posicionada
	dbSeek(cChave+cContaOrc)
	bCondic := {||!Eof() .And. AK3_FILIAL == xFilial("AK3") .And. ;
					AK3_ORCAME == AK1->AK1_CODIGO .And. ;
					AK3_VERSAO == cRevisa .And. ;
					AK3_CO == cContaOrc }

EndIf

While Eval(bCondic)

	If !Empty(aParam[5]) .And. !&(aParam[5])   //Filtro Conta Orcamentaria
		dbSelectArea("AK3")
		dbSkip()
		Loop
	EndIf

	//Reajuste itens orcamentarios
	//faz o lock por item do AK2
	Pco100ItReaj(cArquivo,cRevisa,AK3->AK3_CO,aParam,lRevisa,lSimula)

	dbSelectArea("AK3")
	dbSkip()

End

AK3->(MsUnlockAll())

RestArea(aAreaAK3)
RestArea(aArea)
dbSelectArea(cAlias)

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco100ItReaj³ Autor ³Paulo Carnelossi      ³ Data ³ 06/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que altera os valores orcados da planilha              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco100ItReaj(cArquivo,cRevisa,cContaOrc,aParam,lRevisa,lSimula)
Local cAlias	:= Alias()
Local aArea		:= GetArea()
Local aAreaAK2	:= AK2->(GetArea())
Local cChave	:= ""
Local bCondic	:= {||}
Local nFator	:= 0
Local nReajuste := 0
Local nOpcAviso	:= 0
Local cIdAtu	:= ''
Local nX		:= 0
Local nAuxVal	:= 0				//Soma o valor total dos itens com o reajuste
Local cCodPlan	:= AK1->AK1_CODIGO	//Codigo da planilha
Local aAK2Reaj	:= {}				//Array com o recno e valor do item a sofrer reajuste

DEFAULT lRevisa	:=	.F.
DEFAULT lSimula :=	.F.

dbSelectArea("AK2")
dbSetOrder(5)
cChave := xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+cContaOrc

dbSeek(cChave)

bCondic := {||!Eof() .And. AK2_FILIAL == xFilial("AK2") .And. ;
					AK2_ORCAME == AK1->AK1_CODIGO .And. ;
					AK2_VERSAO == cRevisa .And. ;
					AK2_CO == cContaOrc }

cIDAtu	:=	AK2->AK2_ID
While Eval(bCondic) .And. nOpcAviso <> 3
	If !Empty(aParam[6]) .And. !&(aParam[6])   //Filtro Item Orcamentaria
		nAuxVal += AK2->AK2_VALOR
		dbSelectArea("AK2")
		dbSkip()
		Loop
	EndIf

    If aParam[4] == 2 .And. ( DTOS(AK2_PERIOD) < DTOS(aParam[8]) .Or. DTOS(AK2_PERIOD) > DTOS(aParam[9]) )
		nAuxVal += AK2->AK2_VALOR
		dbSelectArea("AK2")
		dbSkip()
		Loop
	ElseIf aParam[4] == 3 .And. DTOS(AK2_PERIOD) < DTOS(aParam[8])
		nAuxVal += AK2->AK2_VALOR
		dbSelectArea("AK2")
		dbSkip()
		Loop
	EndIf

    //Reajuste itens orcamentarios
    nVlrOrig := AK2->AK2_VALOR

	Do Case
		Case aParam[1] == 1 //Por Percentual normal

		 	If aParam[2] == 1	//Somar
			    nFator := 1+(aParam[7]/100)
			ElseIf aParam[2] == 2 //Diminuir
				nFator := 1-(aParam[7]/100)
			Else              //Substituir
				nFator := (aParam[7]/100)
			EndIf

			nReajuste := nVlrOrig * nFator

		Case aParam[1] == 2 //Por Percentual Embutido
		 	If aParam[2] == 1	//Somar
			    nFator := 1-(aParam[7]/100)
			    nReajuste := nVlrOrig / nFator

			ElseIf aParam[2] == 2 //Diminuir
				nFator := 1+(aParam[7]/100)
			    nReajuste := nVlrOrig / nFator

			Else
				nFator := 1+(aParam[7]/100)
			    nReajuste := nVlrOrig / nFator
				nReajuste := nVlrOrig - nReajuste

			EndIf


		Case aParam[1] == 3 //Por Valor

		 	If aParam[2] == 1	//Somar
		 		nReajuste := nVlrOrig + aParam[7]

			ElseIf aParam[2] == 2 //Diminuir
		 		nReajuste := nVlrOrig - aParam[7]

			Else
				nReajuste := aParam[7]
			EndIf
		Case aParam[1] == 4 //Formula
		 	If aParam[2] == 1	//Somar
		 		nReajuste := nVlrOrig + Formula(aParam[10])
			ElseIf aParam[2] == 2 //Diminuir
		 		nReajuste := nVlrOrig -Formula(aParam[10])
			Else
				nReajuste := Formula(aParam[10])
			EndIf
	EndCase

	Aadd(aAK2Reaj,{AK2->(Recno()),nReajuste})

	nAuxVal += nReajuste

dbSelectArea("AK2")
dbSkip()

EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Avalia o limite orcamentario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aAK2Reaj) > 0 .And. PCOVLDLIM(oGD,cContaOrc,cCodPlan,nAuxVal,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava o valor reajustado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aAK2Reaj)

		//Tentar novamente a gravacao
		If nOpcAviso == 2
			nX := Val(Tira1(Str(nX)))
			nOpcAviso := 0
		EndIf

		//Posiciona no registro da AK2
		AK2->(DbGoTo(aAK2Reaj[nX][1]))

		//Pular para o proximo item
		If nOpcAviso == 1
			If xFilial("AK2")+cCodPlan+cRevisa+cContaOrc+cAK2ID == AK2->(xFilial("AK2")+AK2->AK2_ORCAME+AK2_VERSAO+AK2_CO+AK2_ID)
				Loop
			Else
				nOpcAviso := 0
			EndIf
		EndIf

		If PCOLockAK2(AK2->(xFilial("AK2")+AK2_ORCAME+AK2_VERSAO+AK2_CO+AK2_ID),.F.)
			RecLock("AK2", .F.)
			AK2->AK2_VALOR := aAK2Reaj[nX][2]
			MsUnLock()
			If lSimula
				PcoDetLan("000252","03","PCOA100")
			ElseIf lRevisa
				PcoDetLan("000252","02","PCOA100")
			Else
				PcoDetLan("000252","01","PCOA100")
			Endif
		Else
			cAK2ID		:= AK2->AK2_ID
			nOpcAviso	:= Aviso(STR0034,STR0135+AK2->AK2_ID+STR0136+AK2->AK2_CO+STR0137,{STR0131,STR0138,STR0095}) // "Atenção"## 'O item ' ## " da conta " ## " esta em uso e nao pode ser ajustado." ## 'Continuar' ## 'Tentar nov.' ## 'Cancelar'

			If nOpcAviso == 0 //Tela da pergunta finalizada pelo botão no canto superior direito
				nOpcAviso := 2
			ElseIf nOpcAviso == 3 //Cancelar
				Exit
			EndIf

		Endif
		If AK2->AK2_ID <> cIdAtu
			PCOUnLockAK2(cChave+cIdAtu)
			cIDAtu	:=	AK2->AK2_ID
		Endif

	Next nX

EndIf

RestArea(aAreaAK2)
RestArea(aArea)
dbSelectArea(cAlias)

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco100RatVlr³ Autor ³Paulo Carnelossi      ³ Data ³ 06/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que altera os valores orcados da planilha              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco100RatVlr(cArquivo, oGd, cContaOrc, lReg)
Local lRet		:= .T.
Local cAlias := Alias()
Local aArea := GetArea()
Local aAreaAK3 := AK3->(GetArea())
Local nX, nY, nParcela := 0, nRateio := 0
Local nPosClasse := aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})
Local nPosDescri := aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_DESCLA"})
Local nPosAlter	:=	aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_ALTER"})
Local nPosJustf	:=	aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_JUSTIF"})
Local cChave
Local cClasse
Local cItemOrc, aPeriodo := {}, aValores := {}
Local aClasse:= {	{ 1 ,STR0056, Space(Len(AK2->AK2_CLASSE)) ,"@!" 	 ,""  ,"AK6" ,"" ,65 ,.T. }} //"Classe Orcamentaria"
Local aParam := {Space(Len(AK2->AK2_CLASSE))}
Local lGrvClasse 	:= .F.
Local cJustif  := ""

DEFAULT lReg := .T.

If nPosClasse == 0
	cClasse := M->AK2_CLASSE
Else
	cClasse := oGd:Acols[oGd:nAt][nPosClasse]
EndIf

If Empty(cClasse)
	lRet := ParamBox(aClasse ,STR0057, aParam,,,.F.,120,3)  //"Informe"
	lGrvClasse := lRet
	cClasse := aParam[1]
EndIf

If lRet
	dbSelectArea("AK3")
	dbSetOrder(1)
	cChave := xFilial("AK3")+AK1->AK1_CODIGO+cRevisa

	If !dbSeek(cChave+cContaOrc)
		lRet := .F.
	EndIf

	cItemOrc := oGd:aCols[oGd:nAt][aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_ID"})]
	lRet := lRet .And. PCOA103(AK1->AK1_CODIGO, cRevisa, cContaOrc, cItemOrc, aPeriodo, aValores,@cJustif)
EndIf

If lRet
	lRet	:=	PCOLockAK2(AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+cItemOrc)
	If lRet
	    //estes objetos e variaveis estao declaradas no pcoxfun como private
		oCopia:bWhen:= {|| .F. }
		oCola:bWhen	:= {|| .F. }
		oEdit:bWhen := {|| .F. }
		oWrite:bWhen := {|| .T. }
		oFormula:bWhen := {|| .F. }
		oFormZe1:SetFocus()
		lRet := .T.
		nRecEdic := If(lReg, (cArquivo)->(Recno()), 0)
	Else
		lRet := .F.
	EndIf
    aColsAux:=aClone(oGd:Acols)
	If lRet

	   If oGd:lNewLine
    	  oGd:lNewLine := .F.
	   EndIf

		If lGrvClasse
			oGd:Acols[oGd:nAt][nPosClasse]	:= cClasse
			oGd:Acols[oGd:nAt][nPosDescri]	:= Posicione("AK6", 1, xFilial("AK6")+cClasse, "AK6_DESCRI")
		EndIf

		If nPosJustf > 0
			oGd:Acols[oGd:nAt][nPosJustf]	:= cJustif
		EndIf

		If nPosAlter > 0 .And. nMvPar == 4 .And. oGd:Acols[oGd:nAt][nPosAlter] <> BMP_INCL
			oGd:Acols[oGd:nAt][nPosAlter] := BMP_CHK
		Endif

		For nY := 1 TO Len(aPeriodo)
			If aValores[nY] > 0
				nPosPer := aScan(oGD:aHeader,{|x| AllTrim(x[1]) == ALLTRIM(aPeriodo[nY])})
				If nPosPer > 0
					oGd:aCols[oGd:nAt][nPosPer] := PcoPlanCel(aValores[nY], cClasse)
				EndIf
			EndIf
		Next

		SetFocus(oGD:oBrowse:hWnd)
		oGD:oBrowse:Refresh()

		oCopia:Refresh()
		oCola:Refresh()
		oEdit:Refresh()
		oWrite:Refresh()
		oWrite:SetFocus()

	EndIf

EndIf

RestArea(aAreaAK3)
RestArea(aArea)
dbSelectArea(cAlias)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco100RecForm³ Autor ³Paulo Carnelossi     ³ Data ³ 16/02/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que recalcula as formulas dos itens orcamentarios      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPMS                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco100RecForm(cArquivo, cRevisa, oGd, aFormula,lRevisa,lSimula)
Local lRet		:= .F.
Local aParam    := {}
Local aAplica   := {STR0058, STR0059, STR0060+StrZero(oGd:nAt, 3)+")"} //"Todas as Formulas da Planilha Orcamentaria"###"Todos os Itens da Conta Orc. Posicionada"###"Somente as Formulas do Item Posicionado (L:"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o evento de alteracao no Fase atual.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ParamBox( {	{3,STR0028,3,aAplica,130,"",.T.}},STR0061,@aParam)  //"Recalculo das Formulas"

	Processa({||Pco100CalcForm(cArquivo,cRevisa,aParam, oGd, aFormula,lRevisa,lSimula)}, STR0062) //"Recalculando formulas. Aguarde..."

	If aParam[1] == 1   		// toda a planilha
		lRet := .T.    //para fechar janela e reconstruir a planilha

	ElseIf aParam[1] == 2 		//todos os itens da conta orcamentaria posicionada
		lRet := .F.  // nao fecha a planilha e obriga pressionar botao gravar

	ElseIf aParam[1] == 3 		//Somente a linha posicionada da grade
		lRet := .F.  // nao fecha a planilha e obriga pressionar botao gravar

	EndIf
EndIf

Return(lRet)

Static Function Pco100CalcForm(cArquivo,cRevisa,aParam, oGd, aFormula,lRevisa,lSimula)
Local nX, nY, nZ, cFormula
Local nLin 			:= oGd:nAt
Local nLenCols		:= 0
Local nLenHeader	:= 0

Local cClasse, nValor, cCpo

Local bCondic
Local cAlias 	:= Alias()
Local aArea 	:= GetArea()
Local aAreaAK2 	:= AK2->(GetArea())
Local aAreaAK3 	:= AK3->(GetArea())
Local cContaOrc := (cArquivo)->XK3_CO
Local cChave	:= ""
Local cQuery	:= ""
Local lGerAKD 	:= .F.

DEFAULT lRevisa	:=	.F.
DEFAULT lSimula	:=	.F.

If aParam[1] == 1   // toda a planilha

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Conta linhas que serao processadas para montar gauge ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT COUNT( R_E_C_N_O_ ) TOTREG "
	cQuery += "FROM " + RetSQLName( "AK2" ) + " AK2 "
	cQuery += "WHERE "
	cQuery += "   AK2_FILIAL = '" + xFilial("AK2") + "' AND "
	cQuery += "   AK2_ORCAME = '" + AK1->AK1_CODIGO + "' AND "
	cQuery += "   AK2_VERSAO = '" + cRevisa + "' AND "
	cQuery += "   AK2_FORMUL <> ' ' AND "
	cQuery += "   D_E_L_E_T_ = ' ' "

	cQuery	:=	ChangeQuery(cQuery)
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),"QRYTRB", .F., .F. )

	ProcRegua( QRYTRB->TOTREG )

	QRYTRB->( dbCloseArea() )
	dbSelectArea("AK2")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Traz somente as linhas da AK2 que tem formula para re-processar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT "
    cQuery += "AK3.R_E_C_N_O_ RECAK3, AK2.R_E_C_N_O_ RECAK2 "
	cQuery += "FROM "
	cQuery += RetSQLName("AK2") + " AK2 "
	cQuery += "INNER JOIN "
	cQuery += RetSQLName("AK3") + " AK3 ON "
    cQuery += "    AK3.AK3_FILIAL = '" + xFilial("AK3") + "' "
    cQuery += "AND AK3.AK3_ORCAME = '" + AK1->AK1_CODIGO + "' "
    cQuery += "AND AK3.AK3_VERSAO = '" + cRevisa + "' "
    cQuery += "AND AK3.AK3_CO = AK2.AK2_CO "
    cQuery += "AND AK3.D_E_L_E_T_ = ' ' "
    cQuery += "WHERE "
    cQuery += "    AK2.AK2_FILIAL = '" + xFilial("AK2")  + "' "
    cQuery += "AND AK2.AK2_ORCAME = '" + AK1->AK1_CODIGO + "' "
    cQuery += "AND AK2.AK2_VERSAO = '" + cRevisa + "' "
    cQuery += "AND AK2.AK2_FORMUL <> ' ' "
    cQuery += "AND AK2.D_E_L_E_T_ = ' ' "

	cQuery	:= ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "QRYTRB", .T., .T. )

	// Processa todas as formulas diretamente na tabela AK2
	Do While QRYTRB->( !EoF() )

		nRecAK3 := QRYTRB->RECAK3

		AK3->( dbGoTo(nRecAK3) )

	    // Reajuste itens orcamentarios
	    If SoftLock("AK3")

			Do While QRYTRB->( !EoF() ) .And. nRecAK3 == QRYTRB->RECAK3

				IncProc()

		    	// Processa as formula dos itens orcamentarios
				AK2->( dbGoTo(QRYTRB->RECAK2) )

				// Jogar em variaveis de memoria tab itens (ak2) para utilizacao nas formulas
				For nX := 1 TO AK2->(FCount())
					cCpo := ("AK2->"+Trim(AK2->(FieldName(nX))))
					_SetOwnerPrvt(Trim(AK2->(FieldName(nX))), &cCpo)
				Next

				If !lGerAKD
					lGerAKD := .T.
					PcoIniLan("000252")  //ALTERACAO DA PLANILHA
				EndIf

				cFormula := AK2->AK2_FORMUL
				nValor := &(cFormula)

				RecLock("AK2", .F.)
				AK2->AK2_VALOR := nValor
				AK2->(MsUnLock())

				If lSimula
					PcoDetLan("000252","03","PCOA100")
				ElseIf lRevisa
					PcoDetLan("000252","02","PCOA100")
				Else
					PcoDetLan("000252","01","PCOA100")
				Endif

				QRYTRB->( dbSkip() )

			EndDo

		EndIf

	EndDo

	If lGerAKD
		PcoFinLan("000252")
	EndIf

	QRYTRB->(dbCloseArea())
	dbSelectArea("AK2")

	AK3->(MsUnlockAll())

ElseIf aParam[1] == 2 //todos os itens da conta orcamentaria posicionada

	nLenCols 	:= Len(oGd:Acols)
	nLenHeader	:= Len(oGd:aHeader)

	ProcRegua(nLenCols*nLenHeader)

    Eval(oEdit:bAction)  // simula pressionar botao edit

    //processamento das formulas
    For nX := 1 TO nLenCols
	    cClasse	:= oGD:aCols[nX][aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})]
	    //jogar todas as coluna em variaveis de memoria M-> para uso em formulas
	    For nZ := 1 TO nLenHeader
	    	If Alltrim(oGD:aHeader[nZ][2]) != "AK2_VAL"
				_SetOwnerPrvt(Trim(oGd:aHeader[nZ][2]), oGd:Acols[nX][nZ])
    		EndIf
        Next
    	For nY := 1 TO nLenHeader
	    	IncProc()
    		If Alltrim(oGD:aHeader[nY][2]) == "AK2_VAL"
    		    //jogar para variavel de memoria para uso em formula
    			_SetOwnerPrvt("AK2_VALOR", PcoPlanVal(oGd:Acols[nX][nY], cClasse))
    			_SetOwnerPrvt("AK2_DATAI", CTOD(AllTrim(Substr(oGD:aHeader[nY][1],01,10))) )
   				_SetOwnerPrvt("AK2_DATAF", CTOD(AllTrim(Substr(oGD:aHeader[nY][1],14,10))) )
    			cFormula := Alltrim(Ret_Formula(oGd, nY, nX))
			    If !Empty(cFormula)
	    	        nValor := &(cFormula)
					oGd:aCols[nX][nY] := PcoPlanCel(nValor, cClasse)
				EndIf
			EndIf
    	Next
    Next
    oGD:oBrowse:Refresh()
    //forca mudanca do foco para refresh dos botoes
    oWrite:refresh()
    oFormZe1:SetFocus()


ElseIf aParam[1] == 3 //Somente a linha posicionada da grade

	nLenHeader := Len(oGd:aHeader)

	ProcRegua(nLenHeader)

    Eval(oEdit:bAction)  //simula pressionar do botao editar

    //processamento das formulas
	cClasse	:= oGD:aCols[nLin][aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})]

	 //jogar todas as coluna em variaveis de memoria M-> para uso em formulas
    For nZ := 1 TO nLenHeader
    	If Alltrim(oGD:aHeader[nZ][2]) != "AK2_VAL"
			_SetOwnerPrvt(Trim(oGd:aHeader[nZ][2]), oGd:Acols[nLin][nZ])
    	EndIf
    Next

    For nY := 1 TO nLenHeader
       	IncProc()
    	If Alltrim(oGD:aHeader[nY][2]) == "AK2_VAL"
    	   	//jogar para variavel de memoria para uso em formula
    		_SetOwnerPrvt("AK2_VALOR", PcoPlanVal(oGd:Acols[nLin][nY], cClasse))
   			_SetOwnerPrvt("AK2_DATAI", CTOD(AllTrim(Substr(oGD:aHeader[nY][1],01,10))) )
			_SetOwnerPrvt("AK2_DATAF", CTOD(AllTrim(Substr(oGD:aHeader[nY][1],14,10))) )
		    cFormula := Alltrim(Ret_Formula(oGd, nY, nLin))
		    If !Empty(cFormula)
    	        nValor := &(cFormula)
				oGd:aCols[nLin][nY] := PcoPlanCel(nValor, cClasse)
			EndIf
		EndIf
    Next
    oGD:oBrowse:Refresh()
    //forca mudanca do foco para refresh dos botoes
    oWrite:refresh()
	oFormZe1:SetFocus()

EndIf

RestArea(aAreaAK2)
RestArea(aAreaAK3)
RestArea(aArea)
dbSelectArea(cAlias)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A100IncPlan ºAutor ³Paulo Carnelossi    º Data ³ 05/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que Inclui a planilha (AK1)+conta orcamentaria      º±±
±±º          ³ principal+controle de revisao + usuario                    º±±
±±º          ³ para poder utilizar em outras rotinas alem do pcoa100      º±±
±±º          ³ deve ser declarada variavel private nRecAK1 := 0           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A100IncPlan(cAlias,nReg,nOpcx,cFuncInclui,aButtons, aAutoCab)
Local lContinua	:= .T.
Local lRotAuto	:= .F.

If Type("lPCOAuto") == "U"
	Private lPCOAuto := .F.
EndIf

//nao utilizar getarea--restarea
dbSelectArea(cAlias)

If IsInCallStack("PCO100DLG")
	lRotAuto := lPCOAuto
EndIf

If !lRotAuto
	If AxInclui(cAlias,nReg,nOpcx,,,,"A100VldDta(M->AK1_INIPER,M->AK1_FIMPER,M->AK1_TPPERI)",,cFuncInclui,aButtons,{{||.T.},{|| Iif(FunName() == "PCOA016", FCreatePln(),.T.)},{|| .T.},{|| .T.}},) <> 1
		lContinua := .F.
	EndIf
Else
	// SE FOR ROTINA AUTOMATICA
	If (AxInclui(cAlias, nReg, nOpcx, , , , "A100VldDta(M->AK1_INIPER,M->AK1_FIMPER,M->AK1_TPPERI)", , cFuncInclui,aButtons, {{||.T.},{|| Iif(FunName() == "PCOA016", FCreatePln(),.T.)},{|| .T.},{|| .T.}},  aAutoCab ) <> 1)
		lContinua := .F.
	EndIf
EndIf

If lContinua
	//se incluiu registro normalmente
	dbSelectArea("AK1")
	dbGoto(nRecAK1)  //variavel nRecAK1 foi atribuida na function PCO100Atu()
	cRevisa := AK1->AK1_VERSAO

	//se controla usuario ja insere o criador com controle total em todos os niveis
	If AK1->AK1_CTRUSR == "1"
		dbSelectArea("AKG")
		RecLock("AKG", .T.)
		AKG_FILIAL := xFilial("AKG")
		AKG_ORCAME := AK1->AK1_CODIGO
		AKG_CO := AK1->AK1_CODIGO
		AKG_USER := RetCodUsr()
		AKG_NOME := UsrRetName(AKG->AKG_USER)
		AKG_ESTRUT := "3"
		AKG_ITENS := "4"
		AKG_CNTUSU := "4"
		AKG_REVISA := "4"
		AKG_CCUSTO := "2"
		AKG_ITMCTB := "2"
		AKG_CLAVLR := "2"
		AKG_ENTIDA := "2"
		dbSelectArea("AK1")
	Endif

	//Posicionar tb em AK3 - contas orcamentarias da planilha
	dbSelectArea("AK3")
	dbSetOrder(1)
	//conta orcamentaria raiz recebe o mesmo codigo do orcamento
	dbSeek(xFilial("AK3")+AK1->AK1_CODIGO+AK1->AK1_VERSAO+AK1->AK1_CODIGO)

	dbSelectArea("AK1")

EndIf

Return(lContinua)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MsDocument³ Autor ³ Sergio Silveira       ³ Data ³06/12/2000  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Amarracao entidades x documentos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Entidade                                            ³±±
±±³          ³ ExpN1 -> Registro                                            ³±±
±±³          ³ ExpN2 -> Opcao                                               ³±±
±±³          ³ ExpX1 -> Sem Funcao                                          ³±±
±±³          ³ ExpN3 -> Tipo de Operacao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PcoXLS( cAlias, nReg, nOpc, xVar, nOper, aRecACB )

Local aRecAC9      := {}
Local aPosObj      := {}
Local aPosObjMain  := {}
Local aObjects     := {}
Local aSize        := {}
Local aInfo        := {}
Local aGet		   := {}
Local aTravas      := {}
Local aEntidade    := {}
Local aArea        := GetArea()
Local aExclui      := {}
Local aButtons     := {}
Local aUsButtons   := {}
Local aChave       := {}

Local cCodEnt      := ""
Local cCodDesc     := ""
Local cNomEnt      := ""
Local cEntidade    := ""

Local lTravas      := .T.

Local nCntFor      := 0
Local nUsado       := 0
Local nGetCol      := 0
Local nPosItem     := 0
Local nOpcA	       := 0
Local nScan        := 0

Local oDlg
Local oGetD
Local oGet
Local oGet2
Local oOle
Local oScroll

DEFAULT aRecAC9    := {}
DEFAULT aRecACB    := {}
DEFAULT nOper      := 1

PRIVATE aCols      := {}
PRIVATE aHeader    := {}
PRIVATE INCLUI     := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona a entidade                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cEntidade := cAlias

dbSelectArea( cEntidade )
MsGoto( nReg )

aEntidade := MsRelation()

If !Empty( nScan := AScan( aEntidade, { |x| x[1] == cEntidade } ) )

	aChave   := aEntidade[ nScan, 2 ]

	cCodEnt  := MaBuildKey( cEntidade, aChave )

	cCodEnt  := PadR( cCodEnt, Len( AC9->AC9_CODENT ) )
	cCodDesc := AllTrim( cCodEnt ) + "-" + Capital( Eval( aEntidade[ nScan, 3 ] ) )

	Do Case
	Case nOper == 1

		SX2->( dbSetOrder( 1 ) )
		SX2->( dbSeek( cEntidade ) )

		cNomEnt := Capital( X2NOME() )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem do Array do Cabecalho                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX3")
		dbSetOrder(2)
		dbSeek("AA2_CODTEC")
		aadd(aGet,{X3Titulo(),SX3->X3_PICTURE,SX3->X3_F3})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem do aHeader                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AC9")
		While ( !SX3->( Eof() ) .And. SX3->X3_ARQUIVO=="AC9" )
			If ( X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. ;
					!AllTrim(SX3->X3_CAMPO)$"AC9_ENTIDA|AC9_CODENT" )
				nUsado++
				aadd(aHeader,{ AllTrim(X3Titulo()),;
					SX3->X3_CAMPO,;
					SX3->X3_PICTURE,;
					SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,;
					SX3->X3_VALID,;
					SX3->X3_USADO,;
					SX3->X3_TIPO,;
					SX3->X3_ARQUIVO,;
					SX3->X3_CONTEXT } )
				If ( AllTrim(SX3->X3_CAMPO)=="AA2_ITEM" )
					nPosItem := nUsado
				Endif
			EndIf

			SX3->( dbSkip() )
		EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem do aCols                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsDocArray( cEntidade, cCodEnt,@aCols, @aTravas, @aRecAC9, 2 )

		If Empty( aCols )
			AAdd(aCols,Array(nUsado+1))
			For nCntFor := 1 To nUsado
				aCols[1,nCntFor] := CriaVar(aHeader[nCntFor,2], .F. )
			Next nCntFor
			aCols[1][nUsado+1] := .F.
		EndIf

		If ( lTravas )

			aSize := MsAdvSize( )

			aObjects := {}
			AAdd( aObjects, { 100, 100, .T., .T. } )

			aInfo       := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
			aPosObjMain := MsObjSize( aInfo, aObjects )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Resolve os objetos lateralmente                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aObjects := {}

			AAdd( aObjects, { 150, 100, .T., .T. } )
			AAdd( aObjects, { 100, 100, .T., .T., .T. } )

			aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 4, 4 }
			aPosObj := MsObjSize( aInfo, aObjects, .T. , .T. )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Resolve os objetos da parte esquerda                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aInfo   := { aPosObj[1,2], aPosObj[1,1], aPosObj[1,4], aPosObj[1,3], 0, 4, 0, 0 }

			aObjects := {}
			AAdd( aObjects, { 100,  36, .T., .F., .T. } )
			AAdd( aObjects, { 100, 100, .T., .T. } )
			AAdd( aObjects, { 100,  15, .T., .F. } )

			aPosObj2 := MsObjSize( aInfo, aObjects )

			aHide := {}

			INCLUI := .T.

			DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL


			@ aPosObj2[1,1],aPosObj2[1,2] MSPANEL oPanel PROMPT "" SIZE aPosObj2[1,3],aPosObj2[1,4] OF oDlg CENTERED LOWERED //"Botoes"

			nGetCol := 40

			@ 006,005     SAY STR0063         SIZE 040,009 OF oPanel  PIXEL // "Entidade" //"Entidade" //"Entidade"
			@ 005,nGetCol GET oGet  VAR cNomEnt  SIZE 090,009 OF oPanel PIXEL WHEN .F.

			@ 019,005     SAY STR0064        SIZE 040,009 OF oPanel PIXEL // "Codigo" //"Descricao" //"Descricao"
			@ 018,nGetCol GET oGet2 VAR cCodDesc SIZE aPosObj2[1,3] - nGetCol - 6,009 OF oPanel PIXEL WHEN .F.

			oGetd:=MsGetDados():New(aPosObj2[2,1],aPosObj2[2,2],aPosObj2[2,3],aPosObj2[2,4], nOpc,"MsDocLok","AlwaysTrue",,.T.,NIL,NIL,NIL,1000)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ A classe scrollbox esta com o size invertido...                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oScroll := TScrollBox():New( oDlg, aPosObj[2,1], aPosObj[2,2], aPosObj[2,4],aPosObj[2,3])

			oOle    := TOleContainer():New( 0, 0, aPosObj2[2,3],aPosObj2[2,4],oScroll, , "" )
			oOle:Hide()

			oScroll:Cargo := 1

			@ aPosObj2[3,1] + 3, aPosObj2[3,4] - 70  BUTTON oButPrev PROMPT "Preview" SIZE 035,012 FONT oDlg:oFont ACTION (  oGetd:oBrowse:SetFocus(), MsFlPreview( oOle, @aExclui ) )  OF oDlg PIXEL     //"Preview"
			@ aPosObj2[3,1] + 3, aPosObj2[3,4] - 34  BUTTON oButOpen PROMPT STR0065   SIZE 035,012 FONT oDlg:oFont ACTION ( oGetd:oBrowse:SetFocus(), PcoXlsOpen() ) OF oDlg PIXEL                              //"Abrir" //"Abrir"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona ao array dos objetos que devem ser escondidos                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd( aHide, oPanel )
			AAdd( aHide, oGetD  )
			AAdd( aHide, oButPrev )
			AAdd( aHide, oButOpen )

			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(oGetd:TudoOk(),oDlg:End(),nOpcA:=0)},{||oDlg:End()},, aButtons )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui os temporarios      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( aExclui )
				MsDocExclui( aExclui, .F. )
			EndIf

		EndIf
		For nCntFor := 1 To Len(aTravas)
			dbSelectArea(aTravas[nCntFor][1])
			dbGoto(aTravas[nCntFor][2])
			MsUnLock()
		Next nCntFor

	EndCase

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao inclusao, permite a exibicao de mensagens em tela               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOper == 1
		Aviso( STR0066, STR0067 + cAlias, { "Ok" } ) 	  //"Atencao !"###"Nao existe chave de relacionamento definida para o alias "
	EndIf

EndIf

RestArea( aArea )

Return()


Static Function A100Espec_Cpos(aHeaderFil, aHeaderAK2, aPeriodo, aCampos, aCpoAK2, aCpoSel, lEdtPar)
Local nX, lRet := .T.
Local aParametros := {}
Local aConfig := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.}
Local oDlg, oFont
Local nItem := 1
Local aButtons		:= {}
Local cTipo, cPicture, nTamanho, nDecimal, cF3, cValid, cWhen
Local lFilePar, cGrvPar, cLidoArq, lCheck, cLinAux
Local nI := 0
Local cValidUsr := ''
Local cValidRot := ''

aConfig := Array(Len(aCampos))
aFill(aConfig,.T.)

aCpoSel := {}

lFilePar := File("\PROFILE\PCOA100_"+__cUserID+".PFG")

If !lFilePar
	lEdtPar := .T.
Else
	cLidoArq := MEMOREAD("\PROFILE\PCOA100_"+__cUserID+".PFG")
	nLenArq := MLCOUNT(cLidoArq)
	For nX := 2 TO nLenArq
		cLinAux := MEMOLINE(cLidoArq, 80, nX)
		lCheck := If(Subs(cLinAux,1,1)=="1", .T., .F.)
		If lCheck
			aAdd(aCpoSel, {Val(Subs(cLinAux,2,2)), Alltrim(Subs(cLinAux,4))})
		EndIf
		aAdd(aParametros, {4,"",lCheck,aCampos[nX-1],120,,.F.})
	Next
EndIf

If lEdtPar
	DEFINE FONT oFont NAME "Arial" SIZE 0, -11 BOLD
	aSize := MsAdvSize(,.F.,400)
	aObjects := {}

	AAdd( aObjects, { 100, 100 , .T., .T. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	If ! lFilePar
		For nX := 1 TO Len(aCampos)
			aAdd(aParametros,{4,"",aConfig[nx],aCampos[nx],120,,.F.})
		Next
	EndIf

	If ParamBox(aParametros ,STR0033, aConfig,,,.F.,120,3) //"Parametros"
	   aCpoSel := {}
		For nX := 1 TO Len(aConfig)
			If aConfig[nX]
				aAdd(aCpoSel, {nItem++, aCampos[nX]})
			EndIf
		Next

	   If Empty(aCpoSel)
				aAdd(aCpoSel, {nItem++, aCampos[1]})
	   EndIf

		DEFINE MSDIALOG oDlg TITLE STR0068 From 0,0 to 200,400 of oMainWnd PIXEL //"Colunas Itens Orcamentarios"
		AAdd( aButtons, { "PMSSETADOWN", { || A100MudaOrd(1,aCpoSel,oCampos) }, STR0069, STR0069 } )    //"Abaixo"###"Abaixo"
		AAdd( aButtons, { "PMSSETAUP"  , { || A100MudaOrd(2,aCpoSel,oCampos) }, STR0070, STR0070 } ) //"Acima"###"Acima"

		oCampos := 	TWBrowse():New(  2,2,aPosObj[1,4]-6,aPosObj[1,3]-aPosObj[1,1]-16,,{STR0071,STR0072},,oDlg,,,,,,,oFont,,,,,.F.,,.T.,,.F.,,,) //"Ordem"###"Colunas Itens Orçamentários"
		oCampos:Align := CONTROL_ALIGN_ALLCLIENT
		oCampos:SetArray(aCpoSel)
		oCampos:bLine := { || aCpoSel[oCampos:nAT]}

		// Quando nao for MDI chama centralizada.
		If SetMDIChild()
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||lRet := .F., oDlg:End()},, aButtons)
		Else
			ACTIVATE MSDIALOG oDlg  ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||lRet := .F., oDlg:End()},, aButtons) CENTERED
		EndIf

	Else

		lRet := .F.

	EndIf
EndIf

If lRet
	If lEdtPar .And. Aviso(STR0034, STR0073, {STR0074, STR0075}) == 1 //"Atencao"###"Gravar parametros ? "###"Sim"###"Nao"
	   cGrvPar := STR0076+CRLF //"Arquivo de Parametros - Alteracao Planilha Orcamentaria"
	   For nX := 1 TO Len(aConfig)
	   	cGrvPar += If(aConfig[nX],"1","0")
	   	If aConfig[nX]
		   	nPos := aScan(aCpoSel, {|aVal| aVal[2] == aCampos[nX]})
		   	cGrvPar += StrZero(aCpoSel[nPos][1],2)
	   		cGrvPar += aCpoSel[nPos][2]
	   	EndIf
	   	cGrvPar += CRLF
	   Next
	   MemoWrit("\PROFILE\PCOA100_"+__cUserID+".PFG",cGrvPar)
	   lEdtPar := .F.
   EndIf
	//montar array do aHeader para grade do filtro
	For nX := 1 TO Len(aCpoSel)

		nPos := Ascan(aCampos, aCpoSel[nX][2])
		If nPos == 0
			MsgAlert(STR0099)  //"Erro no arquivo de configuracao das colunas do Filtro. Editar e Gravar Novamente."
			A100Espec_Cpos(aHeaderFil, aHeaderAK2, aPeriodo, aCampos, aCpoAK2, aCpoSel, .T.)
			Return(.F.)
		EndIf
		cCampo := aCpoAK2[nPos]
		dbSelectArea("SX3")
		dbSetOrder(2)
		dbSeek(cCampo)
		cTipo  := SX3->X3_TIPO
		cPicture := SX3->X3_PICTURE
		nTamanho := SX3->X3_TAMANHO
		nDecimal := SX3->X3_DECIMAL
		cF3 := SX3->X3_F3
		cWhen := ""
		cValid := Alltrim(SX3->X3_VALID)
		cCampo := AllTrim(cCampo)
		If !Empty(cValid) .And. !("vazio"$lower(cValid))
			cValid := 'Vazio() .Or. ('+cValid+')'
		EndIf

		CT0->(dbSetOrder(1))

		If nQtdEntid == NIL //alteracao
			If cPaisLoc == "RUS"
				nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
			Else
				nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
			EndIf
		EndIf

		For nI := 5 To nQtdEntid

			CT0->(dbSeek(xFilial("CT0")+StrZero(nI,2,0)))

			If cCampo == "AK2_ENT" + StrZero(nI,2,0)
				cValidRot := 'A100DesCpo(M->XK2_ENT'+StrZero(nI,2,0)+',"","'+CT0->CT0_CPODSC+'")'
			EndIf

		Next nI

		cValidUsr := alltrim(Posicione("SX3", 2, cCampo, "X3_VLDUSER"))
		If !Empty(cValidUsr)
			If cCampo != 'AK2_CO'
				cValidUsr := ' .and. '+cValid
			EndIf
			cValidUsr := StrTran(cValidUsr,'AK2_','XK2_')
		EndIf

		If cCampo =="AK2_CO"
			cValid := '(Vazio() .Or. ExistCpo("AK5")) .And. A100DesCpo(M->XK2_CO,"DESCCO","AK5_DESCRI")'
			cVldUsrCO := cValidUsr
		ElseIf cCampo =="AK2_CLASSE"
			cValid := "(Vazio() .Or. ExistCpo('AK6')).And.A100DesCpo(M->XK2_CLASSE,'DESCLA','AK6_DESCRI')"
		ElseIf cCampo =="AK2_CC"
			if !('validacusto' $ lower(cValid+cValidUsr))
				cValidRot:='ValidaCusto(M->XK2_CC) .And. '
			EndIf
			cValidRot += "A100DesCpo(M->XK2_CC,'DESCCC','CTT_DESC01')"
		ElseIf cCampo =="AK2_ITCTB"
			cValid :="ValidItem(M->XK2_ITCTB).And.A100DesCpo(M->XK2_ITCTB,'DESCIT','CTD_DESC01')
		ElseIf cCampo =="AK2_CLVLR"
			cValid := "(Vazio() .Or. (ExistCpo('CTH',,1) .AND. ValidaCLVL(M->XK2_CLVLR))).And.A100DesCpo(M->XK2_CLVLR,'DESCCL','CTH_DESC01')"
		ElseIf (cCampo == "AK2_UNIORC") .And. (AK2->(FieldPos("AK2_UNIORC")) > 0)
			cValid := '(Vazio() .Or. ExistCpo("AMF")).And.A100DesCpo(M->XK2_UNIORC,"","AMF_DESCRI")'
		ElseIf cCampo =="AK2_DESCLA" .Or. cCampo =="AK2_DESCCO" .Or.;
		       cCampo =="AK2_DESCCC" .Or. cCampo =="AK2_DESCIT" .Or.;
		       cCampo =="AK2_DESCCL"
			cWhen := ".F."
		EndIf

		If !Empty(cValidUsr)
			cValid += cValidUsr
		EndIf
			//Acrescenta Validação da rotina
			If !Empty(cValidRot)
			If !Empty(cValid)
				cValid += ' .And. '
			EndIf
			cValid+=cValidRot
		Endif

		dbSetOrder(1)

		cCampo := StrTran(cCampo, "AK2", "XK2")

		AADD(aHeaderFil,{ aCampos[nPos],;
							cCampo/*SX3->X3_CAMPO*/,;
							cPicture/*SX3->X3_PICTURE*/,;
							nTamanho/*SX3->X3_TAMANHO*/,;
							nDecimal/*SX3->X3_DECIMAL*/,;
							cValid/*""SX3->X3_VALID*/,;
							""/*SX3->X3_USADO*/,;
							cTipo/*SX3->X3_TIPO*/,;
							cF3/*SX3->X3_F3*/,;
							"V"/*SX3->X3_CONTEXT*/,;
							""/*SX3->X3_CBOX*/,;
							Space(nTamanho)/*SX3->X3_RELACAO*/,;
							cWhen/*SX3->X3_WHEN*/})

	Next

	PcoAK2MontHead(aPeriodo, aHeaderAK2, aHeaderFil)

EndIf

Return(lRet)

Static Function A100MudaOrd(nDirecao, aCpoSel, oCampos)
Local lRet := .T.
Local nX

If nDirecao == 2 .And. oCampos:nAt == 1
	Aviso(STR0034, STR0077,{STR0078}) //"Atencao"###"Topo de Lista"###"OK"
	lRet := .F.

ElseIf nDirecao == 1 .And. oCampos:nAt == Len(aCpoSel)
	Aviso(STR0034, STR0079,{"OK"}) //"Atencao"###"Ultimo Item da Lista"
   lRet := .F.

EndIf

If lRet
   aAuxCop := aClone(aCpoSel[oCampos:nAt])
   aSize(aCpoSel, Len(aCpoSel)+1)
   If nDirecao == 1
   	aIns(aCpoSel, oCampos:nAt+1)
   	aCpoSel[oCampos:nAt+1] := aClone(aAuxCop)
   	aCpoSel[oCampos:nAt] := aClone(aCpoSel[oCampos:nAt+2])
   	aDel(aCpoSel, oCampos:nAt+2)
   	oCampos:nAt++
   Else
   	aIns(aCpoSel, oCampos:nAt-1)
   	aCpoSel[oCampos:nAt-1] := aClone(aAuxCop)
   	aDel(aCpoSel, oCampos:nAt+1)
   	oCampos:nAt--
   EndIf
   aSize(aCpoSel, Len(aCpoSel)-1)
	//Renumera a Ordem dos Campos
	For nX := 1 TO Len(aCpoSel)
		aCpoSel[nX][1] := nX
	Next
EndIf

Return


Function A100DesCpo( cCodPes, cCampo, cDescri )
Local nPosCpo	:= aScan(oGD[2]:aHeader,{|x|AllTrim(x[2])=='XK2_'+cCampo})
Local cAlias	:= Left( cDescri, 3 )
If nPosCpo > 0
	If Empty( cCodPes )
		oGd[2]:aCols[oGd[2]:nAt][nPosCpo] := Space(oGD[2]:aHeader[nPosCpo,4])
	Else
		(cAlias)->(dbSetOrder(1))
		(cAlias)->(dbSeek(xFilial()+cCodPes))
		oGd[2]:aCols[oGd[2]:nAt][nPosCpo] := (cAlias)->&(cDescri)
	EndIf
	oGd[2]:refresh()
EndIf
Return(.T.)

Function c100Per(cCube)
Local aFilIni := {}
Local aFilFim := {}

dbSelectArea("AL1")
dbSetOrder(1)
dbSeek(xFilial("AL1")+cCube)

dbSelectArea("AKW")
dbSetOrder(1)
dbSeek(xFilial("AKW")+cCube)
While !Eof() .And. xFilial("AKW")+cCube == AKW->AKW_FILIAL+AKW->AKW_COD
	If "AKD->AKD_CODPLA+AKD->AKD_VERSAO"==UPPER(AllTrim(AKW->AKW_CHAVER))
		aAdd(aFilIni,AK1->AK1_CODIGO+cRevisa)
		aAdd(aFilFim,AK1->AK1_CODIGO+cRevisa)
	Else
		aAdd(aFilIni,Nil)
		aAdd(aFilFim,Nil)
	EndIf
	dbSkip()
End

PCOC340(2,AK1->AK1_INIPER,AK1->AK1_FIMPER,aFilIni,aFilFim,.F.,Val(AK1->AK1_TPPERI))

Return


Function c100Sld(cCube)
Local aFilIni := {}
Local aFilFim := {}

dbSelectArea("AL1")
dbSetOrder(1)
dbSeek(xFilial()+cCube)

dbSelectArea("AKW")
dbSetOrder(1)
dbSeek(xFilial("AKW")+cCube)
While !Eof() .And. xFilial("AKW")+cCube == AKW->AKW_FILIAL+AKW->AKW_COD
	If "AKD->AKD_CODPLA+AKD->AKD_VERSAO"==UPPER(AllTrim(AKW->AKW_CHAVER))
		aAdd(aFilIni,AK1->AK1_CODIGO+cRevisa)
		aAdd(aFilFim,AK1->AK1_CODIGO+cRevisa)
	ElseIf "AKD->AKD_CODPLA"==UPPER(AllTrim(AKW->AKW_CHAVER))
		aAdd(aFilIni,AK1->AK1_CODIGO)
		aAdd(aFilFim,AK1->AK1_CODIGO)
	ElseIf "AKD->AKD_VERSAO"==UPPER(AllTrim(AKW->AKW_CHAVER))
		aAdd(aFilIni,cRevisa)
		aAdd(aFilFim,cRevisa)
	Else
		aAdd(aFilIni,Nil)
		aAdd(aFilFim,Nil)
	EndIf
	dbSkip()
End

PCOC330(2,AK1->AK1_FIMPER,aFilIni,aFilFim,.F.)

Return

Static Function Pco100Doc(l100Visual, lRevisao, lSimulac)
Local cChaveAKE := ""
Local cAK1Fase 	:= IIF(AK1->(FieldPos('AK1_FASE')) > 0 , AK1->AK1_FASE , "")
DEFAULT lRevisao := .F.
DEFAULT lSimulac := .F.

//variaveis para carregar os valores armazenados na planilha excel
Private nValueExcel := 0
Private cFormAK2    := ""
Private aFormExcel  := {}


If Pco100Fase("AMR",cAK1Fase,"0016",.T.) // Evento Incluir Documento
	If lRevisao .And. !lSimulac
		cChaveAKE := AK1->AK1_CODIGO+AK1->AK1_VERREV
	ElseIf lSimulac
		cChaveAKE := AK1->AK1_CODIGO+cRevisa
	Else
		cChaveAKE := AK1->AK1_CODIGO+AK1->AK1_VERSAO
	EndIf

	If !Empty(cChaveAKE)
		dbSelectArea("AKE")
		dbSetOrder(1)
		If dbSeek(xFilial("AKE")+cChaveAKE)
			If !l100Visual
				MsDocument("AKE",AKE->(RecNo()),3,,,,.T.)
			Else
				MsDocument("AKE",AKE->(RecNo()),2)
			EndIf
		EndIf
	EndIf
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoVerAcessoPlanºAutor ³Paulo Carnelossi º Data ³ 17/11/05  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o usuario tem acesso a planilha orcamentaria    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoVerAcessoPlan(nOpcx)
Local aArea := GetArea()
Local aAreaAK1 := AK1->(GetArea())
Local aAreaAKG := AKG->(GetArea())
Local nDirEntAK1 := 0

If AK1->AK1_CTRUSR == "1"
	If nOpcx > 2 .And. PcoChkUser(AK1->AK1_CODIGO,PadR(AK1->AK1_CODIGO,Len(AK3->AK3_CO)),Space(Len(AK3->AK3_PAI)),2,"ESTRUT",AK1->AK1_VERSAO)
		nDirEntAK1 := 2
	Else
		If PcoChkUser(AK1->AK1_CODIGO,PadR(AK1->AK1_CODIGO,Len(AK3->AK3_CO)),Space(Len(AK3->AK3_PAI)),1,"ESTRUT",AK1->AK1_VERSAO)
			nDirEntAK1 := 1
		Else
			//Verifica se usuario tem acesso em alguma conta da planilha
			AKG->(dbSetOrder(2))
			If AKG->(dbSeek(xFilial("AKG")+AK1->AK1_CODIGO+__cUserID))
				While AKG->(!Eof() .And. AKG_FILIAL+AKG_ORCAME+AKG_USER==xFilial("AKG")+AK1->AK1_CODIGO+__cUserID)
				   	nDirEntAK1 := Val(AKG->AKG_ESTRUT)
					If nDirEntAK1 == 0 //verifica nos itens
						nDirEntAK1 := If(Val(AKG->AKG_ITENS)>2, 1, 0)
				    EndIf
				    If nDirEntAK1 > 0
				    	Exit
				    EndIf
				    AKG->(dbSkip())
				End
			EndIf
		EndIf
	EndIf
	If nDirEntAK1  == 0 //bloqueado
		Aviso(STR0034,STR0084,{STR0036},2)  //"Atencao"###"Fechar"###"Usuario sem acesso a esta planilha orcamentaria."
	ElseIf nDirEntAK1  == 1 //somente visualizacao
		If nOpcx == 5  //se for opcao exclusao da planilha bloqueia o acesso
			Aviso(STR0034,STR0084,{STR0036},2)  //"Atencao"###"Fechar"###"Usuario sem acesso a esta planilha orcamentaria."
			nDirEntAK1 := 0
		EndIf
	EndIf
Else  //se nao ha controle por usuario - assume 2 alterar por padrao
	nDirEntAK1 := 2
EndIf

RestArea(aAreaAKG)
RestArea(aAreaAK1)
RestArea(aArea)

Return nDirEntAK1

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCO100ALT³ Autor ³ Paulo Carnelossi       ³ Data ³ 08/03/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de alteracao da planilha orcamentaria.              ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCO100ALT(cAlias,nReg,nOpcx,cR1,cR2,cVers,lRevisao)
Local aButtons	 := {}
Local aCamposAK1 := {}
Local cAK1Fase 	:= IIF(AK1->(FieldPos('AK1_FASE')) > 0 , AK1->AK1_FASE , "")
Local lRet := .T.
Inclui := .F.
Altera := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega matriz com campos que serao alterados neste cadastro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("AK1")
Do While !EoF() .And. (X3_ARQUIVO == cAlias)
	If ! (AllTrim(Upper(X3_CAMPO)) $ "AK1_FILIAL/AK1_CODIGO/AK1_VERSAO/AK1_TPPERI/AK1_INIPER/AK1_FIMPER/AK1_STATUS")
		If X3Uso(X3_USADO) .and. cNivel >= X3_NIVEL
			Aadd(aCamposAK1,X3_CAMPO)
		EndIf
	EndIf
	dbSkip()
EndDO
dbSelectArea(cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Faz validacao dos eventos com suas fases, permitindo ou nao ³
//³  alguma acao. Retorna .T. ou .F.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Altera
	lRet := PcoVldFase("AMR",cAK1Fase,"0020",.T.) // Evento Cadastro Planilha
EndIf
If lRet
	If !lPCOAuto		// SE FOR ROTINA AUTOMATICA
		AxAltera(cAlias, nReg, nOpcx, , aCamposAK1, , , /*"Pco100Vld(4)"*/, /*"Pco100Atu"*/, ,aButtons)
	Else
		AxAltera(cAlias, nReg, nOpcx, , aCamposAK1, , , /*"Pco100Vld(4)"*/, /*"Pco100Atu"*/, ,aButtons, /*aParam*/, aAutoCab)
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A100Conf  ºAutor  ³Microsiga           º Data ³  12/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Aviso de confirmacao da exclusao                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A100Conf(nOpcx)
Local lRet := .T.
If nOpcx == 5  .and. !lPCOAuto //Exclusao - Solicita Confirmacao com Aviso que vai excluir os itens orcamentarios
	If Aviso(STR0034,STR0094, {STR0006, STR0095},2)==2//"Atencao"##"Ao excluir a planilha orcamentaria as dependencias serao excluidas (contas/itens/movimentos,etc...). Confirma exclusão planilha orcamentaria ?"##"Excluir"##"Cancelar"
		lRet := .F.
	EndIf
EndIf
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³17/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,	"AxPesqui"  	, 0 , 1, ,.F.},;	//"Pesquisar"
						{ STR0003,	"PCO100DLG" 	, 0 , 2	} ,;		//"Visualizar"
						{ STR0004,	"PCO100DLG" 	, 0 , 3	} ,;		//"Incluir"
						{ STR0005,	"PCO100DLG" 	, 0 , 4	} ,;		//"Alterar"
						{ STR0134,	"PCO100Copy" 	, 0 , 4	} ,;		//"Copiar Plan."
						{ STR0006, 	"PCO100DLG" 	, 0 , 5	} ,;		//"Excluir"
						{ STR0093,	"PCO100ALT" 	, 0 , 4	},;			//"Alt.Cadastro"
						{ STR0116,	"PCOA100AFA"	, 0 , 4	},;			//"Altera Fase"
						{ STR0007,  "PCO100BLEG"	, 0, 4	}}			// "Legenda"

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona botoes do usuario no Browse                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PCOA1001" )
		//P_EÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//P_E³ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ³
		//P_E³ browse da tela de orcamentos                                           ³
		//P_E³ Parametros : Nenhum                                                    ³
		//P_E³ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ³
		//P_E³               Ex. :  User Function PCOPE001                            ³
		//P_E³                      Return {{"Titulo", {|| U_Teste() } }}             ³
		//P_EÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( aUsRotina := ExecBlock( "PCOA1001", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf
EndIf
Return(aRotina)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A100TitCpoºAutor  ³Paulo Carnelossi    º Data ³  18/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega no array acampos os titulos dos campos buscando o   º±±
±±º          ³titulo do dicionario de dados SX3                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A100TitCpo(aCpoAK2, aCampos)
Local nX
Local aArea 	:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())

dbSelectArea("SX3")
dbSetOrder(2)

For nX := 1 TO Len(aCpoAK2)

	If dbSeek(PadR(aCpoAK2[nX], Len(SX3->X3_CAMPO)))
		aAdd(aCampos, X3Titulo())
	Else
		If Alltrim(aCpoAK2[nX]) == "AK2_DESCCO"
				aAdd(aCampos, "Descr.C.O." )
		ElseIf Alltrim(aCpoAK2[nX]) == "AK2_DESCCC"
				aAdd(aCampos, "Descr.C.C.")
		ElseIf Alltrim(aCpoAK2[nX]) == "AK2_DESCIT"
				aAdd(aCampos, "Descr.It.Ctb." )
		ElseIf Alltrim(aCpoAK2[nX]) == "AK2_DESCCL"
				aAdd(aCampos, "Descr.Cl.Vl." )
		Else
			aAdd(aCampos, "Titulo "+StrZero(nX,2) )
		EndIf
	EndIf
Next

RestArea(aAreaSX3)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCO100Ord ºAutor  ³Vogas Junior        º Data ³  06/08/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcionalidade de ordenacao dos itens da planilha orcamenta-º±±
±±º          ³ria.                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco100Ord(nTipo, OgD)

Local nPosItem 	:= aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_ID"})
Local nPosCC 	:= aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_CC"})
Local nPosItCtb	:= aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_ITCTB"})
Local oError := ErrorBlock( { |o| .t. } )

Do Case
	Case nTipo == 1
		Asort( oGd:aCols,,,{|x,y|x[nposItem]< y[nposItem]})
	Case nTipo == 2
		Asort( oGd:aCols,,,{|x,y|x[nPosCC]< y[nPosCC]})
	Case nTipo == 3
		Asort( oGd:aCols,,,{|x,y|x[nPosItCtb]< y[nPosItCtb]})
EndCase

begin sequence
oGD:oBrowse:Refresh()
end sequence

ErrorBlock( oError )

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCOA100   ºAutor  ³Denis Polastri      º Data ³  21/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Encapsulamento da funcao Pco100Fase(), para protecao pois   º±±
±±º          ³a funcao PcoVldFase esta no PCOXFUN                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PCOA100                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco100Fase(cAlias,cCodFase,cCodAcao,lmsg)
Local lRet := .T.

If  AK1->(FieldPos("AK1_FASE")) > 0
	lRet := PcoVldFase(cAlias,cCodFase,cCodAcao,lmsg)
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCOA100AFA ³ Autor ³ Denis Polastri        ³ Data ³ 23-10-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para Alteracao das Fases do Orcamento   	  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PCOA100AFA()

Local clFaseAnt := ""
Local cBkpFase  := ""
Local clFase	:= ""
Local clDescri	:= ""
Local lOk		:= .F.
Local alList	:= {}
Local oGetF		:= Nil
Local oSayNew	:= Nil
Local olDlgF	:= Nil
Local olList	:= Nil
Local olColor	:= Nil
Local olColor2	:= Nil
Local aButtons	:= {}
Local lPermit	:= .F.

clFaseAnt := AK1->AK1_FASE
cBkpFase  := AK1->AK1_FASE
clFase    := clFaseAnt

//Validação de Usuário para alteração de fase - Kazoolo 08/09/2010
lPermit := PCOA008Usr()
If !lPermit
	If clFaseAnt == "003"
		Return()
	EndIf
EndIf

AMO->(dbSetOrder(1))
AMO->(DbSeek(xFilial()+ AK1->AK1_FASE))
clDescri	:= Alltrim(AMO->AMO_DESCRI)

AMR->(dbSetOrder(1))
AMQ->(dbSetOrder(1))

If AMR->(DbSeek(xFilial()+ AK1->AK1_FASE))
	While AMR->(!EOF()) .And. AMR->AMR_FASE == AK1->AK1_FASE
		AMQ->(DbSeek(xFilial()+ AMR->AMR_EVENT))
		olColor		:= FColor(AMR->AMR_PERMIT)
		olColor2	:= FColor(AMR->AMR_PERMIT)
		aadd(alList,{olColor,olColor2,AMQ->AMQ_EVENT,AMQ->AMQ_DESCRI})
		AMR->(dbSkip())
	EndDo
Else
	Aviso(STR0034,STR0126,{STR0127},2,STR0128) // "Atenção !!!" ## "Fase não declarada no Planejamento."##"Voltar"##"Declaraçção da Fase"
	Return
EndIf

//Adiciona botoes na enchoicebar:
aadd(aButtons,{"PMSCOLOR",{||A100LegFas()},STR0007 }) // "Legenda"

DEFINE MSDIALOG olDlgF TITLE STR0001 + Alltrim(clDescri)+"."  OF oMainWnd PIXEL FROM 0,0 TO 400,500
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula dimensões                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize := FwDefSize():New(.T.,,,olDlgF)
	oSize:AddObject( "CABECALHO",  100, 20, .T., .F. ) // Totalmente dimensionavel
	oSize:AddObject( "GETDADOS" ,  100, 80, .T., .T. ) // Totalmente dimensionavel

	oSize:lProp 	:= .T. // Proporcional
	oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

	oSize:Process() 	   // Dispara os calculos

	//oSize:GetDimension("CABECALHO","LININI")
	//,oSize:GetDimension("CABECALHO","COLINI")

	@ oSize:GetDimension("CABECALHO","LININI"),oSize:GetDimension("CABECALHO","COLINI") to oSize:GetDimension("CABECALHO","LINEND"),oSize:GetDimension("CABECALHO","COLEND")-2  PIXEL  OF olDlgF
	@ oSize:GetDimension("CABECALHO","LININI")+6,oSize:GetDimension("CABECALHO","COLINI")+5 Say STR0002  Size 055,008 COLOR CLR_BLACK PIXEL OF olDlgF
	@ oSize:GetDimension("CABECALHO","LININI")+4,oSize:GetDimension("CABECALHO","COLINI")+045 MsGet oGetF Var clFase Size 028,009  F3 'AMO' Valid Iif(clFase <> clFaseAnt,Iif(ExistCpo('AMO',clFase,1),FNewFase(@clFase,@clFaseAnt,@clDescri,@oSayNew,@alList,@olList),.F.),.T.) COLOR CLR_BLACK Picture "@!" PIXEL OF olDlgF HASBUTTON
	@ oSize:GetDimension("CABECALHO","LININI")+6,oSize:GetDimension("CABECALHO","COLINI")+080 Say oSayNew Var clDescri Size 200,008 COLOR CLR_HBLUE PIXEL OF olDlgF SHADOW

	@ oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI") to oSize:GetDimension("GETDADOS","LINEND"),oSize:GetDimension("GETDADOS","COLEND")-2  LABEL STR0003 PIXEL OF olDlgF
	olList := TWBrowse():New( oSize:GetDimension("GETDADOS","LININI")+7,oSize:GetDimension("GETDADOS","COLINI")+3 ,oSize:GetDimension("GETDADOS","XSIZE")-10,oSize:GetDimension("GETDADOS","YSIZE")-10,,{"  ","  ",STR0004,STR0005},{10,10,50,90},olDlgF,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
	olList:SetArray(alList)
	olList:bLine := {|| alList[olList:nAT] }

ACTIVATE MSDIALOG olDlgF ON INIT EnchoiceBar(olDlgF,{|| lOk:=.T.,olDlgF:End()},{|| lOk:=.F.,olDlgF:End()},,aButtons) CENTERED

//Altera a Fase
If lOk
	AK1->(RecLock("AK1",.F.))
	AK1->AK1_FASE:= AllTrim(clFase)
	AK1->(MsUnlock())

	If ExistBlock( "PCOAFAGRV" )
		ExecBlock( "PCOAFAGRV", .F., .F.,{clFase,cBkpFase} )
	EndIf
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FColor		³ Autor ³ Luiz Enrique	        ³ Data ³ 02-08-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para atualizacao do array que contem o eventos conforme³±±
±±³			 ³a alteração da fase.				  									    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FColor(clCor)

Local olCor	:= Nil

olCor:=	If(clCor == "1",LoadBitmap( GetResources(), "BR_VERDE" ),LoadBitmap( GetResources(), "BR_VERMELHO" ))

Return(olCor)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FNewFase	³ Autor ³ Denis Polastri        ³ Data ³ 23-10-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Altera cor da Legenda da Fase.								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³clFase     : Codigo da Atual.   								³±±
±±³			 ³clFaseAnt	 : Codigo da Fase Anterior.				  			³±±
±±³			 ³clDescri	 : Descrição da Fase.				  				³±±
±±³			 ³oSayNew    : Objeto da descrição da fase.				  		³±±
±±³			 ³alList     : Array contendo os eventos.						³±±
±±³			 ³olList     : Obejto dos eventos.								³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCO                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FNewFase(clFase,clFaseAnt,clDescri,oSayNew,alList,olList)

Local nlI	:= 1

AMR->(dbSetOrder(1))
AMO->(dbSetOrder(1))

If AMR->(DbSeek(xFilial()+ clFase))
	While AMR->(!EOF()) .And. AMR->AMR_FASE == clFase
		alList[nlI][2]	:= FColor(AMR->AMR_PERMIT)
		nlI++
		AMR->(dbSkip())
	EndDo
EndIf

clFaseAnt:= clFase

AMO->(DbSeek(xFilial()+ clFase))
clDescri	:= Alltrim(AMO->AMO_DESCRI)

oSayNew:Refresh()
olList:Refresh()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pco100DisVºAutor  ³Microsiga           º Data ³  10/20/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Chamada da rotina de Distribuição de valores nas entidades  º±±
±±º          ³da regra de distribuição orçamentaria                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA100                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Pco100DisV(cArquivo, oGd, cContaOrc, lReg)
Local lRet		:= .T.
Local cAlias := Alias()
Local aArea := GetArea()
Local aAreaAK3 := AK3->(GetArea())
Local nX, nY, nParcela := 0, nRateio := 0
Local nPosClasse := aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_CLASSE"})
Local nPosDescri := aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_DESCLA"})
Local nPosAlter	:=	aScan(oGD:aHeader,{|x| AllTrim(x[2]) == "AK2_ALTER"})
Local cChave
Local cClasse
Local cItemOrc
Local aPeriodo := {}
Local aValores := {}
Local aClasse:= {	{ 1 ,STR0056, Space(Len(AK2->AK2_CLASSE)) ,"@!" 	 ,""  ,"AK6" ,"" ,65 ,.T. }} //"Classe Orcamentaria"
Local aParam := {Space(Len(AK2->AK2_CLASSE))}
Local lGrvClasse := .F.

DEFAULT lReg := .T.

AK2->(dbSetOrder(1))//AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO+DTOS(AK2_PERIOD)+AK2_ID

//Valida se já existe linhas de orçamento definidas para a conta
If lRet .And. AK2->(MsSeek(xFilial("AK2")+AK1->AK1_CODIGO+cRevisa+cContaOrc) )
	HELP("   ",1,"PCODIST",,STR0119,3,0)//"Conta orçamentária já possui itens de orçamento"
	lRet := .F.
EndIf

If lRet
	dbSelectArea("AK3")
	dbSetOrder(1)
	cChave := xFilial("AK3")+AK1->AK1_CODIGO+cRevisa

	If lRet .AND. ALLTRIM(AK3->AK3_TIPO) != '2'
		HELP("   ",1,"PCODIST",,STR0120,3,0)//"A Distribuição somente pode ser feita em contas analíticas"
		lRet := .F.
	EndIf

	If !dbSeek(cChave+cContaOrc)
		lRet := .F.
	EndIf

	If lRet .And. PCOLockAK2(AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO))
		lRet := PCOA104(AK1->AK1_CODIGO, cRevisa, cContaOrc, @oGD:aHeader , @oGd:aCols)
	EndIf

EndIf



If lRet
	//estes objetos e variaveis estao declaradas no pcoxfun como private
	oCopia:bWhen:= {|| .F. }
	oCola:bWhen	:= {|| .F. }
	oEdit:bWhen := {|| .F. }
	oWrite:bWhen := {|| .T. }
	oFormZe1:SetFocus()
	lRet := .T.
	nRecEdic := If(lReg, (cArquivo)->(Recno()), 0)
Else
	lRet := .F.
EndIf

If lRet
	If oGd:lNewLine
		oGd:lNewLine := .F.
	EndIf

	For nY := 1 TO Len(oGd:aCols)
		If nPosAlter > 0 .And. nMvPar == 4 .And. oGd:Acols[nY][nPosAlter] <> BMP_INCL
			oGd:Acols[nY][nPosAlter] := BMP_CHK
		Endif
	Next

	SetFocus(oGD:oBrowse:hWnd)
	oGD:oBrowse:Refresh()
	oCopia:Refresh()
	oCola:Refresh()
	oEdit:Refresh()
	oWrite:Refresh()
	oWrite:SetFocus()
EndIf
RestArea(aAreaAK3)
RestArea(aArea)
dbSelectArea(cAlias)

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoVldFCO ºAutor  ³Microsiga           º Data ³  11/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao de fase para campo AK2_CLASSE, funcao chamada    º±±
±±º          ³ pelo WHEN do campo AK2_CLASSE                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPCO                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoVldFCO()
Local llRet := .T.
Local cAK1Fase := IIF(AK1->(FieldPos('AK1_FASE')) > 0 , AK1->AK1_FASE , "")

If !Empty(aCols[n,GDFieldPos("AK2_CLASSE")]) .and. AllTrim(aCols[n,GDFieldPos("AK2_ID")]) != '*' .and. !Empty(AllTrim(aCols[n,GDFieldPos("AK2_ID")]))
	llRet:= Pco100Fase("AMR",cAK1Fase,"0013",.T.)
EndIf

Return llRet

Function PCO100Copy(cAlias,nReg,nOpcx)

Local aParam 		:= {}
Local aRet 			:= {}
Local nAno			:= Year(AK1->AK1_INIPER)

Private cPlanDest	:= AK1->AK1_CODIGO
Private cVersDest	:= AK1->AK1_VERSAO
//Private aPeriodo 	:= PcoRetPer()

aAdd( aParam , { 1,AllTrim(STR0134),Space(TamSx3("AK1_CODIGO")[1]), "" ,"ExistCpo('AK1')","AK1","", TamSx3("AK1_CODIGO")[1]*7 ,.T.} ) // "Copiar Planilha"

if Empty(AK1->AK1_VERREV) .and. ParamBox(  aParam ,STR0007,@aRet,,,.F.,,,,,.F.)

	If Alltrim(cPlanDest) == Alltrim( aRet[1] )   //se destino e origem for igual nao deve permitir copiar
		HELP("  ",1,"PCOREGINV",,)
	Else
		if(cPaisLoc=='RUS')
			PcoIniLan("000252")
		EndIf
		Processa({|| a100Copy(aRet[1],nAno) }, STR0129) //"Copiando dados da planilha. Aguarde..."
	EndIf

EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a100Copy  ºAutor  ³Microsiga           º Data ³  04/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function a100Copy(cPlanCopy,nAno)

Local aAliasCpy	:= {"AK2","AK3"}
Local aAuxCpy := {}
Local nX,nY
Local lRet			:= .T.
Local lDelAviso	:= .F.
Local nRet			:= 0
Local nPeriodo	:= 0
Local lContinua := .T.

DbSelectArea("AK1")
DbSetorder(1)
If DbSeek(xFilial("AK1") + cPlanCopy)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica e deleta os registros da proxima versao                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For ny := 1 to Len(aAliasCpy)
		IncProc()
		aAuxCpy	:= {}
		dbSelectArea(aAliasCpy[ny])
		If aAliasCpy[ny]=="AK2"
			dbSetOrder(1)
		Else
			dbSetOrder(3)
		Endif

		If DbSeek(xFilial()+cPlanDest+cVersDest)

			If aAliasCpy[ny]=="AK3" .and. AK3->AK3_NIVEL $ "001"  //primeiro nivel da estrutura eh a raiz
				dbSkip()

				If !Eof() .And. FieldGet(FieldPos(aAliasCpy[ny]+"_FILIAL"))+;
								FieldGet(FieldPos(aAliasCpy[ny]+"_ORCAME"))+;
								FieldGet(FieldPos(aAliasCpy[ny]+"_VERSAO"))==;
								xFilial(aAliasCpy[ny])+;
								cPlanDest+;
								cVersDest
					lContinua := .T.
				Else
					lContinua  := .F.
				EndIf
			EndIf

			If lContinua .And. (lDelAviso .or. (nRet := Aviso(STR0034, STR0130,{STR0095,STR0131},2))==2) // "Atenção" ## "Existem movimentos para esta planilha, caso continue os dados seram apagados. Desejá continuar?"##"Cancelar"##"Continuar"
				lDelAviso	:= .T.
				While !Eof() .And. FieldGet(FieldPos(aAliasCpy[ny]+"_FILIAL"))+;
									FieldGet(FieldPos(aAliasCpy[ny]+"_ORCAME"))+;
									FieldGet(FieldPos(aAliasCpy[ny]+"_VERSAO"))==;
									xFilial(aAliasCpy[ny])+;
									cPlanDest+;
									cVersDest

					If aAliasCpy[ny]=="AK2"
						If lSimulac
							PcoDetLan("000252","03","PCOA100",.T.)
						ElseIf lRevisao
							PcoDetLan("000252","02","PCOA100",.T.)
						EndIf
					EndIf

					RecLock(aAliasCpy[ny],.F.,.T.)
					dbDelete()
					MsUnlock()

					dbSkip()
				EndDo
			EndIf
		ElseIf nRet==1
			lRet := .F.
			Exit
		EndIf
	Next ny

	If lRet .And. nRet <> 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria os registros da nova versao                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For ny := 1 to Len(aAliasCpy)
			IncProc()
			aAuxCpy	:= {}
			dbSelectArea(aAliasCpy[ny])
			dbSetOrder(1)
			MsSeek(xFilial()+AK1->AK1_CODIGO+AK1->AK1_VERSAO)
			While !Eof() .And. FieldGet(FieldPos(aAliasCpy[ny]+"_FILIAL"))+;
								FieldGet(FieldPos(aAliasCpy[ny]+"_ORCAME"))+;
								FieldGet(FieldPos(aAliasCpy[ny]+"_VERSAO"))==;
								xFilial(aAliasCpy[ny])+;
								AK1->AK1_CODIGO+;
								AK1->AK1_VERSAO
				If !(aAliasCpy[ny]=="AK3" .and. AK3->AK3_NIVEL="001")
					aAdd(aAuxCpy,(aAliasCpy[ny])->(RecNo()))
				EndIf
				dbSkip()
			End
			If aAliasCpy[ny]=="AK3"
			   aRecAK3 := aClone(aAuxCpy)
			   aRecNew := {}
			EndIf
			For nx := 1 to Len(aAuxCpy)
				nRecNew := 0
               DbGoto(aAuxCpy[nx])
               If aAliasCpy[ny]=="AK2"
                nPeriodo:= nAno
               	dData	:= cTod(SubStr(Dtoc(AK2->AK2_PERIOD),1,6)+Alltrim (Str(nPeriodo)) )
               	dDataI 	:= cTod(SubStr(Dtoc(AK2->AK2_DATAI),1,6)+Alltrim	(Str(nPeriodo)) )
               	dDataF 	:= cTod(SubStr(Dtoc(AK2->AK2_DATAF),1,6)+Alltrim	(Str(nPeriodo)) )
					PmsCopyReg(aAliasCpy[ny],aAuxCpy[nx],{	{aAliasCpy[ny]+"_PERIOD",dData},;
																		{aAliasCpy[ny]+"_DATAI",dDataI},;
																		{aAliasCpy[ny]+"_DATAF",dDataF},;
																		{aAliasCpy[ny]+"_ORCAME",cPlanDest} ,;
																		{aAliasCpy[ny]+"_VERSAO",cVersDest}},;
																@nRecNew)
				ElseIf aAliasCpy[ny]=="AK3" .and. AK3->AK3_NIVEL$"002"
					PmsCopyReg(aAliasCpy[ny],aAuxCpy[nx],{{aAliasCpy[ny]+"_PAI",cPlanDest} ,{aAliasCpy[ny]+"_ORCAME",cPlanDest} ,{aAliasCpy[ny]+"_VERSAO",cVersDest}},@nRecNew)
               Else
					PmsCopyReg(aAliasCpy[ny],aAuxCpy[nx],{{aAliasCpy[ny]+"_ORCAME",cPlanDest} ,{aAliasCpy[ny]+"_VERSAO",cVersDest}},@nRecNew)
               Endif

				If aAliasCpy[ny]=="AK3"
					aAdd(aRecNew, nRecNew)
				EndIf
				If aAliasCpy[ny]=="AK2"
					AK2->(dbGoto(nRecNew))
					PcoDetLan("000252","01","PCOA100")
				EndIf
			Next
		Next ny
	EndIf
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A100LegFas³ Autor ³ Totvs                 ³ Data ³ 02-08-2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra legenda da permissão de Execucao da Acao na Fase.		³±±
±±³			 ³a alteração da fase.				  					        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A100LegFas()

Local aLegenda	:= {}

aLegenda := {{"BR_VERDE",STR0132},{"BR_VERMELHO",STR0133}} // "Permite Executar" ## "Não Permite Executar"
BrwLegenda(STR0037,STR0036,aLegenda) // "Execução da Açõa na Fase"//"Legenda"

Return .T.


/////////////////////////////////////////////////
// Função para proteção do menuitem            //
// Rotina: Importação de dados para integração //
/////////////////////////////////////////////////
Static Function A100VlIp(cCodAk1,cVersion,bBChang)


If PcoA106(cCodAk1,cVersion)
	Eval(bBChang)
EndIf


Return

///////////////////////////////////////
// Função para proteção do menuitem  //
// Rotina: Distribuição de valores   //
///////////////////////////////////////
Static Function A100VlDs(cAK1Fs,cArq,oGrd,cXK3_CO)

Local lRet := .F.

If Pco100Fase("AMR",cAK1Fs,"0019",.T.)
	lRet := Pco100DisV(cArq,oGrd,cXK3_CO)
EndIf

Return lRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A100VldDta³ Autor ³ Ramon Prado           ³ Data ³ 10/02/2012   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida data não permitindo espaçamento entre datas inicial      ³±±
±±³e final maior que a estipulada de acordo com o tipo do período														          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
*/
Function A100VldDta(dDtIniPer,dDtFimPer,cTipoPer)
Local lRet := .T.
Local nCalcPer := 0
Local cDescPer := ""

nCalcPer := YEAR(dDtFimPer) - YEAR(dDtIniPer)

cDescPer := X3Combo("AK1_TPPERI",cTipoPer)
cDescPer := Alltrim(cDescPer)

Do Case
	Case Alltrim(cTipoPer) $ "1|2|7"
		If nCalcPer > 5
			lRet := .F.
			Help( ,, 'A100TPM05',,STR0146+cDescPer+'. '+STR0148, 1, 0 ) // "Não é permitido período maior que 5 anos para o tipo: " # "Escolha período a ser orçado menor que 5 anos"
		Endif
	Case AllTrim(cTipoPer) $ "3|4|5|8"
		If nCalcPer > 20
			Help( ,, 'A100TPM20',,STR0147+cDescPer+'. '+STR0149, 1, 0 ) // "Não é permitido período maior que 20 anos para o tipo: " # "Escolha período a ser orçado menor que 20 anos"
			lRet := .F.
		Endif
EndCase

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A100VCabecºAutor  ³Alexandre Circenis  º Data ³  09/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida as informacoes do array a itens                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A100VCabec(aCabecAuto)
Local lRet := .T.
Local nPosOrca
Local nPosVers
nPosOrca := aScan(aCabecAuto, {|x| Alltrim(x[1]) == "AK2_ORCAME"})
nPosVers := aScan(aCabecAuto, {|x| Alltrim(x[1]) == "AK2_VERSAO"})
nPosCO := aScan(aCabecAuto, {|x| Alltrim(x[1]) == "AK2_CO"})
if nPosOrca = 0 .or. nPosVers = 0 .or. nPosCO = 0
	HELP( ,, 'A100ORCA',,"Falta um ou mais parametros obrigatórios (AK2_ORCAME, AK2_VERSAO ou AK2_CO).", 1, 0 )
	lRet := .F.
else
	// Tentar posicionar na tabela AK1 pelo orcamento fornecido
	dbSelectArea("AK1")
	dbSetOrder(1)
	if !dbSeek(xFilial("AK1")+aCabecAuto[nPosOrca][2]+aCabecAuto[nPosVers][2])
		HELP( ,, 'A100ORCANI',,"Orcamento "+aCabecAuto[nPosOrca][2]+" Versão "+aCabecAuto[nPosVers][2]+" não está cadastrado.", 1, 0 )
		lRet := .F.
	else
		dbSelectArea("AK3")
		dbSetOrder(1)
		if !dbSeek(xFilial("AK3")+aCabecAuto[nPosOrca][2]+aCabecAuto[nPosVers][2]+aCabecAuto[nPosCO][2])
			HELP( ,, 'A100CONOIS',,"Conta Orçamentaria "+aCabecAuto[nPosCO][2]+" não está cadastrada.", 1, 0 )
			lRet := .F.
		endif
	endif
endif
Return lRet

/*/{Protheus.doc} IntegDef
Chamada da mensagem unica de itens de planilha orçamentária.

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.

@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem

@author marylly.araujo
@since 23/05/2014
@version MP120
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransa)
Return PCOI100(cXml, cTypeTrans, cTypeMsg, cVersion, cTransa)

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOAVENT
Valida when do centro de custo, item e classe contabil.

@param - cTabela -> Tabela da entidade.

@author caique.ferreira
@since 14/08/2014
@version MP120
/*/
//-------------------------------------------------------------------

Function PCOAVENT(cTabela)

Local lRet:= .T.
Default cTabela := ""

If Alltrim(cTabela) == "CTT"
	lRet:= CtbMovSaldo("CTT") .And. PcoVldFase('AMR',AK1->AK1_FASE,'0010',.T.)
ElseIf Alltrim(cTabela) == "CTD"
	lRet:= CtbMovSaldo("CTD") .And. PcoVldFase('AMR',AK1->AK1_FASE,'0011',.T.)
ElseIf Alltrim(cTabela) == "CTH"
	lRet:= CtbMovSaldo("CTH") .And. PcoVldFase('AMR',AK1->AK1_FASE,'0012',.T.)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCO100AdPai
Adiciona C.O. Pai no array de ExecAuto

@param - aEstrut -> Array com Estrutura da Planilha (AK3)

@author Alison Lemes
@since 19/04/2018
@version MP12.1.17
/*/
//-------------------------------------------------------------------
Function PCO100AdPai(aEstrut)
	Local nE        := 0 //Controle de FOR
	Local nPosPlan  := 0 //Posição do Campo AK3_ORCAME
	Local nPosVers  := 0 //Posição do Campo AK3_VERSAO
	Local nPosPai   := 0 //Posição do Campo AK3_PAI
	Local nPosConta := 0 //Posição do Campo AK3_CO
	Local cContaPai := '' //C.O. Pai
	Local nPosEstr  := 0 //Posição no Array de Estrutura
	Local aLinha    := 0 //Linha Auxiliar

	For nE := 1 To Len(aEstrut)
		//Buscando a Posição do Campo AK3_ORCAME
		nPosPlan  := AScan(aEstrut[nE], {|x| AllTrim(x[01]) == 'AK3_ORCAME'})
		//Buscando a Posição do Campo AK3_VERSAO
		nPosVers  := AScan(aEstrut[nE], {|x| AllTrim(x[01]) == 'AK3_VERSAO'})
		//Buscando a Posição do Campo AK3_CO
		nPosConta := AScan(aEstrut[nE], {|x| AllTrim(x[01]) == 'AK3_CO'})
		//Buscando a Posição do Campo AK3_PAI
		nPosPai   := AScan(aEstrut[nE], {|x| AllTrim(x[01]) == 'AK3_PAI'})
		If (nPosPlan > 0 .AND. nPosVers > 0 .AND. nPosConta > 0 .AND. nPosPai > 0)
			cContaPai := aEstrut[nE][nPosPai, 02]
			//Verifica se possui Pai
			While !(Empty(cContaPai))
				//Verifica se a Conta Pai já consta no array de estrutura
				nPosEstr := AScan(aEstrut, {|x| AllTrim(x[nPosConta, 02]) == AllTrim(cContaPai)})
				If (nPosEstr == 0)
					//Adicionando no Array
					aLinha := {}
					AAdd(aLinha, {"AK3_ORCAME", aEstrut[nE][nPosPlan, 02], Nil})
					AAdd(aLinha, {"AK3_VERSAO", aEstrut[nE][nPosVers, 02], Nil})
					AAdd(aLinha, {"AK3_CO"    , cContaPai               , Nil})
					//Posicionar na Conta Orçamentária
					DBSelectArea('AK5')
					AK5->(DbSetOrder(01)) //AK5_FILIAL+AK5_CODIGO
					If (AK5->(DbSeek(FWxFilial('AK5') + cContaPai)))
						//AAdd(aLinha, {"AK3_PAI", IIf(Empty(AK5->AK5_COSUP), Replicate('0', TamSX3('AK3_CO')[01]), AK5->AK5_COSUP), Nil})
						AAdd(aLinha, {"AK3_PAI", IIf(Empty(AK5->AK5_COSUP), aEstrut[nE][nPosPlan, 02], AK5->AK5_COSUP), Nil})
						AAdd(aLinha, {"AK3_TIPO"  , AK5->AK5_TIPO, Nil})
						AAdd(aLinha, {"AK3_DESCRI", AK5->AK5_DESCRI, Nil})
						//Definindo o Novo Pai
						cContaPai := AK5->AK5_COSUP
					Else
						cContaPai := ''
					EndIf
					AAdd(aEstrut, AClone(aLinha))
				Else
					cContaPai := ''
				EndIf
			EndDo
			//Verifica se é Conta Orçamentária sem pai, e adiciona o Número da Planilha como Pai
			If (Empty(aEstrut[nE][nPosPai, 02]) .AND. !(AllTrim(aEstrut[nE][nPosConta, 02]) == AllTrim(aEstrut[nE][nPosPlan, 02])))
				aEstrut[nE][nPosPai, 02] := aEstrut[nE][nPosPlan, 02]
			EndIf
		EndIf
	Next nE

	//Ordenando o Array
	If (nPosPai > 0)
		ASort(aEstrut,/*nInicio*/,/*nCont*/,{|x, y| x[nPosPai, 02] < y[nPosPai, 02]})
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PCO100Posi
Posiciona na Planilha Orçamentária

@author Alison Lemes
@since 19/04/2018
@version MP12.1.17
/*/
//-------------------------------------------------------------------
Static Function PCO100Posi()
	Local nPosPlan  := 0 //Posição do Campo AK3_ORCAME
	Local nPosVers  := 0 //Posição do Campo AK3_VERSAO
	Local lPos      := .F. //Posicionou ?

	//Buscando a Posição do Campo AK3_ORCAME
	nPosPlan  := AScan(aAutoCab, {|x| AllTrim(x[01]) == 'AK2_ORCAME'})
	//Buscando a Posição do Campo AK3_VERSAO
	nPosVers  := AScan(aAutoCab, {|x| AllTrim(x[01]) == 'AK2_VERSAO'})
	//Posicionando na Planilha
	If (nPosPlan > 0 .AND. nPosVers > 0)
		DbSelectArea('AK1')
		AK1->(DbSetOrder(01)) //AK1_FILIAL + AK1_CODIGO + AK1_VERSAO
		If (AK1->(DbSeek(FWxFilial('AK1') +;
			PadR(aAutoCab[nPosPlan, 02], TamSX3('AK1_CODIGO')[01]))))/* +;
			PadR(aAutoCab[nPosVers, 02], TamSX3('AK1_VERSAO')[01]) )))*/
			lPos := .T.
		EndIf
	EndIf
Return lPos
