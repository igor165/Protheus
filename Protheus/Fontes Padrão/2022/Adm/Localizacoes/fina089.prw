#INCLUDE "PROTHEUS.CH"
#INCLUDE "FINA089.CH"
#INCLUDE "FWMVCDEF.CH"

STATIC lMod2	:= .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ RFINA01  ³ Autor ³ BRUNO SOBIESKI             ³ Data ³ 26/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Baixa de CHEQUES E TRANSFERENCIAS.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RFINA01()                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINANCIERO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³   BOPS   ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Bruno         ³16/11/99³  Melhor  ³Inclu‡ao da funcao rfina08               ³±±
±±³Leonardo	     ³17/04/00³  Melhor  ³Mudanca para FINA089 - Protheus          ³±±
±±³Sergio F.     ³20/06/02³  016488  ³Inclusao da funcao F089Seq()             ³±±
±±³Adilson 		 ³23/11/04³  075767  ³Performance - Inclusão funcao FILBROWSE  ³±±
±±³Wagner        ³08/06/10³          ³Implementado tributação de ITF na liqui  ³±±
±±³Montenegro    ³        ³          ³dação de cheques conforme sua Natureza.  ³±±
±±³              ³        ³          ³Implementado no cancelamento de cheque o ³±±
±±³              ³        ³          ³cancelamento do ITF nas liquidações que  ³±±
±±³              ³        ³          ³houve incidência.                        ³±±
±±³              ³        ³          ³Implementado consistência na exibição de ³±±
±±³              ³        ³          ³registros para exibir apenas registros   ³±±
±±³              ³        ³          ³que Portador !$(MV_CXFIN/MV_CARTEIR/     ³±±
±±³              ³        ³          ³ISCAIXALOJA())                           ³±±
±±³Luis Enríquez ³30/12/16³SERINN001-³Se realizó merge para                    ³±±
±±³              ³        ³484       ³agregar clase FWTemporaryTable para      ³±±
±±³              ³        ³          ³creación de tablas temp. como CTREE      ³±±
±±³Marco A. Glz  ³03/05/17³ MMI-136  ³Se replican llamados(TWKCP9 y MMI-4415), ³±±
±±³              ³        ³          ³correspondientes a V12116 y V12117, los  ³±±
±±³              ³        ³          ³cuales solucionan errores al usar las    ³±±
±±³              ³        ³          ³opciones de Cobro y Rechazo de Cheques,  ³±±
±±³              ³        ³          ³para Mexico.                             ³±±
±±³Luis Enriquez ³06/12/17³DMINA-1008³En la función A089Rechaz se asigna el    ³±±
±±³              ³        ³          ³identificador FK1DETAIL al componente de ³±±
±±³              ³        ³          ³modelo de datos oFK1,después se asignan  ³±±
±±³              ³        ³          ³los datos del modelo para actualizar los ³±±
±±³              ³        ³          ³los títulos por cobrar (FK1),tambien se  ³±±
±±³              ³        ³          ³agregó solución de issues DMINA-222,     ³±±
±±³              ³        ³          ³DMINA-214 y MMI-5828 (PERU)              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Fina089() // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cCondicao := ""
	Local nOrd,OrdSIX
	Local lTemRegs  := .T.
	Local aCposBrw  := {}
	Local aCores    := {}

	SetPrvt("VK_F12,LDIGITA,LAGLUTINA,LGERALANC,CINDEX")
	SetPrvt("CTXTIND,CKEY,NINDEX,CCADASTRO,AROTINA,_SALIAS")
	SetPrvt("CPERG,AREGS,NA,NB,")

	Private lInverte, cKeyBusca
	Private lQuery		:= .F.
	Private nValorSel	:= 0
	Private cAliasTmp	:= ""
	Private aIndex		:= {}
	Private bFiltraBrw	:= {||}
	Private aDiario		:= {}
	Private cCodDiario	:= ""
	Private aFlagCTB	:= {}
	Private lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/ )

	Private lFindITF	:= .T.
	Private cFilCxCtr	:= Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+;
	IIf(!Empty(GetMv("MV_CARTEIR")),"/"+GetMv("MV_CARTEIR"),"")+;
	IIf(!Empty(IsCxLoja()),"/"+IsCxLoja(),"")
	Private cFilter		:= ""
	Private oTmpTable	:= Nil
	/*
	* Verificação do processo que está configurado para ser utilizado no Módulo Financeiro (Argentina)
	*/
	If lMod2
		If !FinModProc()
			Return()
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega fun‡„o Pergunte                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetKey (VK_F12,{|| A089Buscar(1) })

	pergunte("RFIA01",.F.)

	lDigita	:=	Iif(mv_par01==1,.T.,.F.)
	lAglutina:=	Iif(mv_par02==1,.T.,.F.)
	lGeraLanc:= Iif(mv_par03==1,.T.,.F.)
	lInverte := Iif(MV_PAR04==1,.T.,.F.)  // Traz os facturas marcadas

	DbSelectArea("SE1")
	dbSetOrder(4)
	DbGoTop()

	If ExistBlock("RFA01ORD")
		OrdSIX:=ExecBlock("RFA01ORD",.F.,.F.)

		// Verifica se o ponto de entrada retornou caracter
		If ValType(OrdSIX)=="C"
			// Transforma o retorno passado para numerico compreensivel ao dbsetorder
			nOrd:= If(ASC(OrdSIX)>=49 .and. ASC(OrdSIX)<=57,Val(OrdSIX),ASC(OrdSix)-55)

			If ValType(nOrd)=="N" .and. (SIX->(DbSeek("SE1"+OrdSIX)))
				dbSetOrder(nOrd)
			EndIf
		EndIf
	Endif

	OrdSIX:=If(Valtype(OrdSIX)=="C",OrdSIX,"4")

	SIX->(DbSeek("SE1"+OrdSIX))
	cKeyBusca := SIX->(SixDescricao())
	IF Empty(cKeyBusca)
		cKeyBusca := INDEXKEY()
	EndIf


	#IFDEF TOP
		cCondicao := "E1_FILIAL = '"+xFilial('SE1')+"' AND E1_TIPO IN ('"+IIF(Type('MVCHEQUES')=='C',StrTran(MVCHEQUES,"|","','"),MVCHEQUE)+"',"
		cCondicao += "'"+MVPROVIS+"','"+MVRECANT+"','"+MV_CRNEG+"','"+MVENVBCOR+"')"
		cCondicao += " AND (E1_SITUACA <> '0' OR (E1_SITUACA = '0' AND E1_STATUS = 'R'))"
		If cPaisLoc == "PER"
			cCondicao += " AND E1_PORTADO NOT IN ('" + StrTran(cFilCxCtr,"/","','") + "')"
		Endif
		If ExistBlock("A089FBROW")
			cCondicao	+=	" AND " + ExecBlock("A089FBROW",.F.,.F.,{cCondicao})
		Endif
	
		cFilter := cCondicao

	#ELSE
		cCondicao := "E1_FILIAL == '"+xFilial('SE1')+"' .AND. E1_TIPO $ ('"+IIF(Type('MVCHEQUES')=='C',MVCHEQUES,MVCHEQUE) + "|"
		cCondicao += MVPROVIS + "|" + MVRECANT + "|" + MV_CRNEG + "|" + MVENVBCOR + "')"
		cCondicao += " .AND. (E1_SITUACA != '0' .OR. (E1_SITUACA == '0' .AND. E1_STATUS == 'R'))"
		If cPaisLoc == "PER"
			cCondicao += " .AND. !E1_PORTADO $ ('" + cFilCxCtr + "')"
		Endif
		If ExistBlock("A089FBROW")
			cCondicao	+=	" .AND. " + ExecBlock("A089FBROW",.F.,.F.,{cCondicao})
		Endif
	
		bFiltraBrw := {|| FilBrowse("SE1",@aIndex,@cCondicao)}
		//Atualiza o browse
		Eval( bFiltraBrw )

	#ENDIF

	lTemRegs  := !(BOF() .And. EOF())

	If lTemRegs
		aCores :={	{ 'E1_STATUS="R"','BR_PRETO'},;	// Titulo rechazado
		{ 'E1_SALDO>0' , 'ENABLE'},; 	// Titulo cancelado
		{ 'E1_SALDO=0' , 'DISABLE'}}	// Titulo Baixado

		cCadastro := OemToAnsi(STR0003)  //"Recepcion Bancaria"

		Private aRotina := MenuDef()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Endere‡a a fun‡„o de BROWSE                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SE1")
		DbSetOrder(1)
		#IFDEF TOP
			mBrowse( 6, 1,22,75,"SE1",NIL,,,,,aCores,,,,,,,,cFilter)
		#ELSE
			mBrowse( 6, 1,22,75,"SE1",NIL,,,,,aCores)
		#ENDIF
	Else
		Help(" ",1,"RECNO")
	ENDIF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recupera a Integridade dos dados                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET KEY VK_F12 to
	DbClearFilter()
	RETINDEX("SE1")
	dbSelectArea( "SE5" )
	dbSetOrder( 1 )
	dbSelectArea("SE1")
	#IFNDEF TOP
		EndFilBrw("SE1",aIndex)
		oTmpTable:Delete()
	#ENDIF
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ **** Comentarios sobre as areas de trabalho e alias ****             ³
//³ "TMP089" - area de trabalho com os registros selecionados pelas queries ³
//³ ou filtro. Gerado na funcao a089CrTRB(), chamado pelas opcoes de     ³
//³ Cobranca, Devolucao de cheque, Cancelamento de cobranca.             ³
//³                                                                      ³
//³ cAliasTmp(SE1TMP) - Alias das queries dos registros selecionados.    ³
//³ Opcoes: Cobranca, Devolucao de Cheque e Cancelamento de cobranca     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A089Buscar ³ Autor ³                      ³ Data ³ 11.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesquisa                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA089                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A089Buscar(nOpcao)        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetPrvt("LDIGITA,LAGLUTINA,LGERALANC,")

	If nOpcao==1
		Pergunte("RFIA01",.T.)
		lDigita	 :=	Iif(mv_par01==1,.T.,.F.)
		lAglutina:=	Iif(mv_par02==1,.T.,.F.)
		lGeraLanc:= Iif(mv_par03==1,.T.,.F.)
		lInverte := Iif(MV_PAR04==1,.T.,.F.)  // Traz os facturas marcadas
	ELSE
		//	AxPesqInd(cKeyBusca,"4")
		A089Pesquisa()
	ENDIF

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A089Recibe³ Autor ³ BRUNO SOBIESKI        ³ Data ³ 26.03.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ BAJA LOS TITULOS RECIBIDOS DEL BANCO.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA089                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Bruno Sobieski³23.09.99³Melhor³Atualizar saldo bancario.               ³±±
±±³Bruno Sobieski³11.11.99³Melhor³Atualizar saldo duplicatas no SA1       ³±±
±±³Bruno Sobieski³01.12.99³Melhor³Pegar Numero de lanzamento padronizado  ³±±
±±³              ³        ³      ³ do fa070Pad(). (Aten‡ao! Atualizar SI5 ³±±
±±³              ³        ³      ³ de 520 para 521).                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A089Recibe(lAutomato)        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
Local aAreaA089		:= GetArea()
Local cBordero		:= Criavar("E1_NUMBOR")
Local cCondicoes	:= ""
Local cCondWhile	:= ""
Local aCampos		:= {}
Local aTits			:= {}
Local aCamposShw	:= {}
Local cTipCheques	:= ""
Local nA			:= 0
Local nX			:= 0
Local nI			:= 0
Local nH			:= 0
Local cTipos		:= MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVENVBCOR
Local nValor		:= 0
Local oModel
Local oFK1
Local oFKA
Local oFK5
Local nPosBor		:= 0
Local iCx			:= 0
Local aButtons 		:= {}
Local cIdFK1		:= ""
Local cIdFK5		:= ""
Local cTpDoc		:= ""
Local cSequencia	:= ""
Private nXaux		:=0
Private oTmpTable	:= Nil
Private cArqTrb		:= ""
Private aBorderos		:= {}
Private aHdlPrv		:= {}
Private lBordero		:= .F.
Private cSeqFRF		:= ""
Private AreaSEF		:= {}
Private cFiltroSEF    := ""
Private cCamposE5 := ""
Private cLog 	 := ""
Private cIdDoc := ""
Private cChaveTit := ""
Private aBanco:={}
Private aCliente:={}
Private cLstDesc		:= FN022LSTCB(2)	//Lista das situacoes de cobranca (Descontada)
Private cLstBcoNoDesc	:= FN022LSTCB(5)	//Lista das situacoes de cobranca (Em banco mas sem desconto)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetPrvt("CARQUIVO,NHDLPRV,NTOTALLANC,CLOTECOM,NLINHA,LCANCEL")
	SetPrvt("CBCODE,CBCOATE,DDATADE,DDATAATE,NREC")
	SetPrvt("NINDEX1,NINDEX,NTOTSEL,CMARCAE1,ACAMPOS")
	SetPrvt("N,NCONFIRMO,LPRIM,ARECSSE5,LLANCPAD70,LLANCTOK")
	SetPrvt("CBCOFJN,CAGEFJN,CPOSFJN")
	SetPrvt("NA,")

	//Definidos como Privates para poder ser usados no ponto de entrada, a089canc
Private cIndexKey	:=	"E1_CLIENTE+E1_NUM"
Private cIndexKey1	:=	"E1_CLIENTE+E1_NUM"
Private cMsg   	:=	STR0047 //"Cliente+Numero"
Private cFilCxCtr :=Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR")+"/"+IsCxLoja()
Default lAutomato	:= .F.  // Utilizada para el paso de scripts automatizados

	cTipos	:=	StrTran(cTipos,',','/')
	cTipos	:=	StrTran(cTipos,';','/')
	cTipos	:=	StrTran(cTipos,'|','/')
	cTipos	:=	StrTran(cTipos,'\','/')
	cArquivo := ""
	nHdlPrv := 1
	nTotalLanc := 0
	cLoteCom := ""
	nLinha := 2
	lCancel	:=	.T.
	nRec	:=	SE1->(Recno())
	SA1->(DbSetOrder(1))
	SA6->(DbSetOrder(1))

   If cPaisLoc <> "BRA" .AND. FUNNAME()=="FINA096"
	If ValType(lExecute)=="L"
		lExecute	:= .F.
	EndIf
	cIndexKey1	:=	"E1_OK+E1_CLIENTE+E1_NUM"
		lCancel		:= .F.
		If !lAutomato
			cBordero	:= If(ValType(cBord380) == "C", cBord380, cBordero)
		Else
		   IIF (SE1->E1_NUMBOR != " ", lBordero := .T., lBordero)		   
		   If FindFunction("GetParAuto")
				aRetAuto 		:= GetParAuto("FINA096TESTCASE")
				cBcoDe 			:= aRetAuto[1]
				cBcoAte 		:= aRetAuto[1]
				cBcoFJN			:= aRetAuto[6]
				cAgeFJN			:= aRetAuto[7]
				dDataAte		:= aRetAuto[5]
				cPosFJN			:= aRetAuto[9]
				lGeraLanc		:= aRetAuto[11]
				If lBordero
					cBord380	:= aRetAuto[10]
					cBordero	:= aRetAuto[10]
				Endif
				lInverte 		:= .F.
		   Endif
	   EndIf
   Else
		cBcoDe 	:= Space(TamSx3("A6_COD")[1])
		cBcoAte	:= Space(TamSx3("A6_COD")[1])
		dDataDe := dDataBase
		dDataAte := dDataBase
	If !lAutomato
		DEFINE MSDialog oDlg1 FROM 65,0 To 210,386  Title OemToAnsi(STR0010) PIXEL //"Par metros"
		@ 00,003 To 56,184 OF oDLG1 PIXEL
		@ 09,008 SAY OemToAnsi(STR0011) 	SIZE 40,10 	OF oDLG1 PIXEL  // "Banco de "
		@ 09,045 MSGet cBcoDe   F3 "BCO" Picture "@!" Valid (NAOVAZIO().and. If(cPaisLoc=="PER",If(!cBcoDe $ cFilCxCtr ,.T.,Eval({||MsgAlert(STR0087),.F.})),.T.) .and.ExistCpo("SA6")) OF oDLG1 PIXEL
		@ 09,095 SAY OemToAnsi(STR0012)  SIZE 40,10	OF oDLG1 PIXEL// "Banco Hasta "
		@ 09,136 MSGet cBcoAte  F3 "BCO" Picture "@!" Valid (NAOVAZIO().and. If(cPaisLoc=="PER",If(!cBcoAte $ cFilCxCtr ,.T.,Eval({||MsgAlert(STR0087),.F.})),.T.) .and.ExistCpo("SA6")) OF oDLG1 PIXEL
		@ 25,008 SAY OemToAnsi(STR0013)   OF oDLG1 PIXEL// "Vencto. de "
		@ 25,045 MSGet dDataDe  Picture "@!" SIZE 40,10  OF oDLG1 PIXEL
		@ 25,095 SAY OemToAnsi(STR0014)  SIZE 40,10 OF oDLG1 PIXEL // "Vencto. Hasta "
		@ 25,136 MSGet dDataAte Picture "@!" SIZE 40,10 OF oDLG1 PIXEL

		@ 41,008 SAY OemToAnsi(STR0046) SIZE 40,10 Of oDlg1 PIXEL //"Bordero : "
		@ 41,045 MSGet cBordero Picture X3Picture("E1_NUMBOR") OF oDLG1 PIXEL

		DEFINE SButton FROM 59,108 Type 1 Action (lCancel	:=	.F.,oDlg1:END()) ENABLE OF oDLG1 PIXEL
		DEFINE SButton FROM 59,149 Type 2 Action (oDlg1:END()) ENABLE OF oDLG1 PIXEL
		  Activate MSDialog oDlg1 CENTERED
	   Else
		  If FindFunction("GetParAuto")
				aRetAuto 		:= GetParAuto("FINA089TESTCASE")
				cBcoDe 			:= aRetAuto[1]
				cBcoAte 		:= aRetAuto[2]
				dDataDe			:= aRetAuto[3]
				dDataAte		:= aRetAuto[4]
				lGeraLanc		:= .F.
				lCancel 		:= .F.
				lInverte 		:= .F.
		  Endif
	   Endif
   Endif
   
	If lCancel
		RETURN
	Endif

	aCampos	:=	{}
	aTits		:=	{}
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("E1_OK")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{" ",""})
	If cPaisLoc == "PAR"
		DbSeek("E1_NUMCHQ")
		Aadd(aCampos,{X3_CAMPO	,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
		AAdd(aTits,{X3Titulo(),X3_PICTURE})
	EndIf
	DbSeek("E1_TIPO")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_VALOR")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_BCOCHQ")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_AGECHQ")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_CTACHQ")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_PORTADO")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_NUM")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_MOEDA")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_VLCRUZ")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_CLIENTE")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_LOJA")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_VENCTO")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_NUMBOR")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
DbSeek("E1_AGEDEP")
Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
AAdd(aTits,{X3Titulo(),X3_PICTURE})
DbSeek("E1_CONTA")
Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
AAdd(aTits,{X3Titulo(),X3_PICTURE})

	If cPaisLoc <> "BRA" .AND. FUNNAME()=="FINA096"

		DbSeek("E1_PREFIXO")
		Aadd(aCampos,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
		AAdd(aTits,{X3Titulo(),X3_PICTURE})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Requisito de Entidades Bancarias - Junho de 2012 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If dbSeek( "E1_POSTAL" )
			Aadd(aCampos,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
			AAdd(aTits,{X3Titulo(),X3_PICTURE})
		EndIf

	Endif
	If ExistBlock("A089CAMP")
		Execblock("A089CAMP",.F.,.F.,1)
	Endif

	Aadd(aCampos,{"RECSE1","N",14,0})

	#IFDEF TOP
		SE1->(DbSetOrder(IIf(Empty(cBordero),7,5)))
If cPaisLoc <> "BRA" .AND. FUNNAME()=="FINA096"
	
	cQuery:= "SELECT  "
	For nX	:=	1	To	Len(aCampos) - 1
		cQuery	+=	aCampos[nX][1] + ","
	Next
	cQuery+= " E1_VENCREA,E1_FILIAL,E1_NOMCLI,E1_PARCELA, SE1.R_E_C_N_O_  RECNO "
	cQuery+= " FROM " + RetSqlName("SE1")
	cQuery+= " SE1 WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
	If !EMPTY(dDataDe) .AND. !EMPTY(dDataAte)
		cQuery+=	" AND SE1.E1_VENCREA BETWEEN '" + Dtos(dDataDe) + "' AND '" + dTos(dDataAte) + "'"
	EndIf
	//Estas condicoes sao colocadas para que o forcar o banco pegar o Indice 7
	//que sera sempre mas favoravel na performance da query  que o indice 4
	//pois o intervalo entre datas geralmente sera menor que o intervalo
	//entre portador.
	//Bruno.
	If !Empty(cBordero)
		cQuery+= " AND SE1.E1_NUMBOR ='"+cBordero+"'"
	Endif
	cQuery+= " AND SE1.D_E_L_E_T_ <> '*' AND ( "
	cTipCheques := Substr(MVCHEQUES,1,3)
	For nH = 1 to Len(MVCHEQUES) Step 4
		cQuery += " SE1.E1_TIPO = '"+cTipCheques+"'"
		If nH+2 <> Len(MVCHEQUES)
			cQuery += " OR "
			cTipCheques := Substr(MVCHEQUES,nH+4,3)
		EndIf
	Next nH
	cQuery+= ")"
	
	cQuery+= " AND SE1.E1_SALDO > 0 "
	
	If !EMPTY(cBcoDe+cBcoAte)
		cQuery+= " AND SE1.E1_PORTADO = '" + cBcoDe + "'"
	EndIf
	
	If  cPaisloc == "ARG"
		cQuery+= " AND ( SE1.E1_SITUACA IN " + FormatIN (cLstBcoNoDesc,'|') + " )"
	Else
		cQuery+= " AND ( SE1.E1_SITUACA IN " + FormatIN (cLstBcoNoDesc,'|') + " OR SE1.E1_SALDO<>0 )"
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Expressao de Filtro para Entidades Bancarias - Junho de 2012 ³
	//³ Variaveis declaradas em FINA096 - Cheques Recebidos          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If Empty( cBcoFJN )
		If !Empty( cPosFJN )
			cQuery += " AND SE1.E1_POSTAL = '" + cPosFJN + "'"
		EndIf
	Else
		cQuery += " AND SE1.E1_BCOCHQ = '" + cBcoFJN + "'"
		cQuery += " AND SE1.E1_AGECHQ = '" + cAgeFJN + "' "
	EndIf
Else
		cQuery:= "SELECT "
		For nX	:=	1	To	Len(aCampos) - 1
			cQuery	+=	aCampos[nX][1] + ","
		Next
		cQuery+= " R_E_C_N_O_  RECNO "
		cQuery+= " FROM " + RetSqlName("SE1")
		cQuery+= " WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
		If !EMPTY(dDataDe) .AND. !EMPTY(dDataAte)
			cQuery+=	" AND E1_VENCREA BETWEEN '" + Dtos(dDataDe) + "' AND '" + dTos(dDataAte) + "'"
		EndIf
		//Estas condicoes sao colocadas para que o forcar o banco pegar o Indice 7
		//que sera sempre mas favoravel na performance da query  que o indice 4
		//pois o intervalo entre datas geralmente sera menor que o intervalo
		//entre portador.
		//Bruno.
		If !Empty(cBordero)
			cQuery+= " AND E1_NUMBOR ='"+cBordero+"'"
		Endif
		cQuery+=	" AND E1_NOMCLI  >= ' ' "
		cQuery+=	" AND E1_PREFIXO >= ' ' "
		cQuery+=	" AND E1_NUM     >= ' ' "
		cQuery+=	" AND E1_PARCELA >= ' ' "
		cQuery+= " AND D_E_L_E_T_ <> '*' AND ( "
		cTipCheques := Substr(MVCHEQUES,1,3)
		For nH = 1 to Len(MVCHEQUES) Step 4
			cQuery += " E1_TIPO = '"+cTipCheques+"'"
			If nH+2 <> Len(MVCHEQUES)
				cQuery += " OR "
				cTipCheques := Substr(MVCHEQUES,nH+4,3)
			EndIf
		Next nH
		cQuery+= ")"
		If !Empty(MVPROVIS) .Or. !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .Or. !Empty(MVENVBCOR)
			cQuery += "   AND  E1_TIPO NOT IN "+FormatIn(cTipos,'/')
		Endif
		cQuery+= " AND E1_SALDO > 0 "
	
		If !EMPTY(cBcoDe+cBcoAte)
			cQuery+= " AND E1_PORTADO BETWEEN '" + cBcoDe + "' AND '" + cBcoAte + "'"
		EndIf
	
		cQuery+= " AND E1_PORTADO <> '" +Space(lEN(SE1->E1_PORTADO))+"' AND ( E1_SITUACA IN " + FormatIN (cLstBcoNoDesc,'|') + " OR E1_SALDO<>0 )"
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Expressao de Filtro para Entidades Bancarias - Junho de 2012 ³
		//³ Variaveis declaradas em FINA096 - Cheques Recebidos          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc <> "BRA"
			If Empty( cBcoFJN )
				If !Empty( cPosFJN )
					cQuery += " AND E1_POSTAL = '" + cPosFJN + "'"
				EndIf
			Else
				cQuery += " AND E1_BCOCHQ = '" + cBcoFJN + "'"
				cQuery += " AND E1_AGECHQ = '" + cAgeFJN + "' "
			EndIf
	
		EndIf
EndIf
		If cPaisLoc="PER"
			cQuery+= " AND E1_PORTADO NOT IN "+FormatIn(cFilCxCtr,,3)
		Endif
	
		If ExistBlock("A089CONDS")
			cQuery	+=	ExecBlock("A089CONDS",.F.,.F.,1)
		Endif
	
		cQuery+= " ORDER BY " + SQLORDER(SE1->(IndexKey()))
		cQuery:= ChangeQuery(cQuery)
	  
		MsAguarde({ | | dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1TMP', .T., .T.) },STR0048,STR0049 ) //"Por favor aguarde"###"Seleccionando registros en el Servidor..."
	  
		For nI := 1 to Len(aCampos)-1
			If aCampos[ni,2] != 'C'
				TCSetField('SE1TMP', aCampos[ni,1], aCampos[ni,2],aCampos[ni,3],aCampos[ni,4])
			Endif
		Next
		DbSelectArea("SE1TMP")
		cAliasTmp	:=	"SE1TMP"
		If cPaisLoc="PER"
			cCondicoes	:=	"!IsCaixaLoja(E1_PORTADO)"
	//ElseIf cPaisLoc <> "BRA" .AND. FUNNAME()=="FINA096"
	//	cCondicoes	:= "A096ConSEF((xFilial('SEF')+'R'+SE1->E1_BCOCHQ+SE1->E1_AGECHQ+SE1->E1_CTACHQ+Padr(SUBSTR(SE1->E1_NUM,1,Len(SEF->EF_NUM)),len(SEF->EF_NUM),' ')+SE1->E1_PREFIXO),6,1)"
		Else
			cCondicoes	:=	".T."
		Endif
		cCondWhile	:=	"!EOF()"
	#ELSE
		cCondicoes	:= "E1_TIPO $  '"+MVCHEQUES +"' .AND. !(E1_TIPO $ '"+MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVENVBCOR+"') .AND. E1_SALDO > 0 .AND.  DTOS(E1_VENCREA)  >= '" + Dtos(dDataDe) + "' .AND. DTOS(E1_VENCREA) <= '" + dTos(dDataAte) + "'"
		cCondicoes 	+= ".AND. !Empty(E1_PORTADO) .AND. (E1_SITUACA $ '"+cLstBcoNoDesc+"' .Or. E1_SALDO<>0)"
		cCondicoes	+= ".AND.  E1_PORTADO >='" + cBcoDe + "' .AND.  E1_PORTADO <='" + cBcoAte + "'"
		If cPaisLoc="PER"
			cCondicoes	+= " .AND. !(E1_PORTADO $ '" +  cFilCxCtr + "') "
		Endif
		If ExistBlock("A089CONDS")
			cCondicoes	+=	ExecBlock("A089CONDS",.F.,.F.,1)
		Endif
		If Empty(cBordero)
			cCondWhile	:=	"DTOS(E1_VENCREA) <= '" + dtos(dDataAte)+ "' .And. !EOF()"
			DbSelectArea("SE1")
			DbSetOrder(7)
			DbSeek(xFilial()+DTOS(dDataDe),.T.)
		Else
			cCondWhile	:=	"E1_NUMBOR=='"+cBordero+"' .And. !EOF()"
			DbSelectArea("SE1")
			DbSetOrder(5)
			DbSeek(xFilial()+cBordero)
		Endif
		cAliasTmp := "SE1"
	#ENDIF

	cMarcaE1 :=	GetMark()
	Processa( {|| a089CrTRB(cCondicoes,cCondWhile,cAliasTmp,aCampos,@cArqTrb,cMarcaE1,lInverte)})

	#IFDEF TOP
		DbSelectArea(cAliasTmp)
		DbCloseArea()
	#ELSE
		nIndex := Retindex("SE1")
	#ENDIF
	DbSelectArea("TMP089")
	dbGoTop()
	If BOF() .and. EOF()
		HELP(" ",1,"NORECS")
	
		If oTmpTable <> Nil   
			oTmpTable:Delete()  
			oTmpTable := Nil
		EndIf 
	
		DbSelectArea("SE1")
		If !lAutomato
		   Eval( bFiltraBrw )
		Endif
		Return
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Voy montar el RDSELECT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCamposShw  := {}
		//Carregar os campos a serem exibidos
		For nX   := 1  To Len(aTits)
			Aadd(aCamposShw,{aCampos[nX][1],"",aTits[nX][1],aTits[nX][2]})
		Next

		If !lAutomato
			If FUNNAME()=="FINA096" 
				aAdd(aButtons,{"Pesquisa",{|| F096Busca("TMP089",cArqTrb,cIndexKey)},STR0004,STR0004})
				If ExistBlock("FA89BUTL")
					aButtons :=ExecBlock("FA89BUTL",.F.,.F.,{aButtons})
				EndIf
			EndIf
			nConfirmo:=RdSelect("TMP089","E1_OK",,aCamposShw,OemToAnsi(STR0027),OemToAnsi(STR0028+STR0050+cMsg),,cMarcaE1,.F.,,,"FI089TO",aButtons) //" .  Ordenado Por : "
        Else 
           If FUNNAME()=="FINA096" 
            F096Busca("TMP089",cArqTrb,cIndexKey,lAutomato)
           EndIf
            Replace TMP089->E1_OK With cMarcaE1      
            nConfirmo := 1
        Endif

		If UsaSeqCor()
			cCodDiario := CTBAVerDia()
		Endif

		If nConfirmo <>1
			If oTmpTable <> Nil   
				oTmpTable:Delete()  
				oTmpTable := Nil
			EndIf 
			DbSelectArea("SE1")
			Eval( bFiltraBrw )
			Return
		Endif

		DbSelectArea("TMP089")
		DbGoTop()
		lPrim	:=	.T.
		aRecsSe5	:=	{}
		nValor := 0
		aBorderos := {}
		lBordero := .F.

		PcoIniLan("000360")
	//Para o Fina096 a gravação foi alteração, pois existe a necessidade de exibir a barra de progresso
	If Funname()=="FINA096"
		
		SA6->(DbSetOrder(1))
		SA6->(MSSeek(xFilial()+TMP089->E1_PORTADO+TMP089->E1_AGEDEP+TMP089->E1_CONTA))
		aAreaSEF:=SEF->(GetArea())
		cFiltroSEF := ""
		FiltroSEF := SEF->(DbFilter())
		SEF->(DbClearFilter())
		SEF->(DbSetOrder(6))
		Processa({|| A089GRV()},"Aguarde...")
		
		If cPaisLoc <> "BRA"
			If Len(aBanco)>0
				SA6->(DbSetOrder(1))
				For Nx:=1 to Len(aBanco)
			
					SA6->(DbSeek(aBanco[nX][1]))
					AtuSalBco(SA6->A6_COD,SA6->A6_AGENCIA,SA6->A6_NUMCON,dDataBase,aBanco[nX][2],"+")
				Next
			EndIf
			If Len(aCliente)>0
				SA1->(DbSetOrder(1))
				For Nx:=1 to Len(aCliente)
					SA1->(DbSeek(aCliente[nX][1]))
					AtuSalDup("-",aCliente[nX][3],1,aCliente[nX][2],,aCliente[nX][4])
				Next
			EndIf
		EndIf
		
		If !Empty(cFiltroSEF)
			SEF->(DbSetfilter({||&cFiltroSEF},cFiltroSEF))
		EndIf
		SEF->(RestArea(aAreaSEF))
	Else

		Do while !EOF()
		cCamposE5:=""
			//O lInverte nao e compativel com a RDSELECT
			If E1_OK == cMarcaE1
				SE1->(DbGoTo(TMP089->RECSE1))
				RecLock("SE1",.F.)
				SE1->E1_BAIXA := dDatabase
				SE1->E1_SALDO := 0.00
				SE1->E1_STATUS := "B"
				SE1->E1_MOVIMEN:= dDataBase
				If !(SE1->E1_SITUACA $ cLstDesc)  //Situacao de cobranca diferende de descontada
					If cPaisLoc$"URU|PAR|CHI|BOL"
						lBordero := !Empty(SE1->E1_NUMBOR)
						If lBordero
							nValor:=xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1)
							nPosBor	:=	AScan(aBorderos,{|X| x[4] == SE1->E1_NUMBOR })
							If nPosBor	== 0
								AAdd(aBorderos,{SE1->E1_PORTADO,SE1->E1_AGEDEP,SE1->E1_CONTA,SE1->E1_NUMBOR,nValor})
							Else
								aBorderos[nPosBor][5]+=	nValor
							Endif
						Endif
						lBordero := .F.
					Endif
				Endif
				MsUnlock()
				SA6->(DbSetOrder(1))
				SA6->(DbSeek(xFilial()+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA))
				//
				oModel := FWLoadModel('FINM010') //Baixas a receber.
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				oModel:Activate()
				oModel:SetValue( "MASTER", "NOVOPROC", .T. ) //Novo processo
				//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
				cCamposE5 := "{{'E5_DTDIGIT'	,dDataBase}"
				cCamposE5 += ",{'E5_TIPO'		,SE1->E1_TIPO}"                            
				cCamposE5 += ",{'E5_PREFIXO'	,SE1->E1_PREFIXO}"
				cCamposE5 += ",{'E5_NUMERO'		,SE1->E1_NUM}"
				cCamposE5 += ",{'E5_PARCELA'	,SE1->E1_PARCELA}"
				cCamposE5 += ",{'E5_CLIFOR'		,SE1->E1_CLIENTE}"
				cCamposE5 += ",{'E5_LOJA'		,SE1->E1_LOJA}"                            
				cCamposE5 += ",{'E5_BENEF'		,SE1->E1_NOMCLI}"
				If FunName() $ "FINA096"                            
					cCamposE5 += ",{'E5_BCOCHQ'	,SE1->E1_BCOCHQ}"
					cCamposE5 += ",{'E5_AGECHQ'	,SE1->E1_AGECHQ}" 
					cCamposE5 += ",{'E5_CTACHQ'	,SE1->E1_CTACHQ}"
				EndIf
				cCamposE5 += ",{'E5_DTDISPO'	, dDataBase}}"
				//FK7 x SE1.
				cChaveTit := xFilial("SE1")  + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM 			+ "|" +;
				SE1->E1_PARCELA + "|" +  SE1->E1_TIPO 		+ "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA

				cIdDoc := FINGRVFK7("SE1", cChaveTit)

				cTpDoc		:= If(lBordero .Or. SE1->E1_SITUACA $ cLstDesc,"BA","VL")
				cSequencia	:= F089Seq()

				//			
				oFKA := oModel:GetModel('FKADETAIL')
				oFK1 := oModel:GetModel('FK1DETAIL')
				oFK5 := oModel:GetModel('FK5DETAIL')

				//Cria FKA x FK1
				If !oFKA:IsEmpty()
					//Inclui a quantidade de linhas necessárias
					oFKA:AddLine()
					//Vai para linha criada
					oFKA:GoLine(oFKA:Length())
				Endif
				
				cIdFK1:= FWUUIDV4()

				oFKA:SetValue('FKA_IDORIG', cIdFK1)
				oFKA:SetValue('FKA_TABORI','FK1')

				oFK1:SetValue('FK1_IDFK1' , cIdFK1 )
				oFK1:SetValue('FK1_IDDOC' , cIdDoc)
				oFK1:SetValue('FK1_RECPAG', 'R')
				oFK1:SetValue('FK1_HISTOR', OemToAnsi(STR0029))
				oFK1:SetValue('FK1_MOTBX' , 'NOR')
				oFK1:SetValue('FK1_DATA'  , dDataBase)
				oFK1:SetValue('FK1_VENCTO', dDataBase)
				oFK1:SetValue('FK1_NATURE', SE1->E1_NATUREZ)
				oFK1:SetValue('FK1_TPDOC' , cTpDoc)
				oFK1:SetValue('FK1_MOEDA' , StrZero(Max(SA6->A6_MOEDA,1),2))
				oFK1:SetValue('FK1_VALOR' , xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,Max(SA6->A6_MOEDA,1)))
				oFK1:SetValue('FK1_VLMOE2', SE1->E1_VALOR)
				oFK1:SetValue('FK1_SERREC', PADR(SE1->E1_SERREC,TamSX3("FK1_SERREC")[1]))
				oFK1:SetValue('FK1_ORDREC', SE1->E1_RECIBO)
				oFK1:SetValue('FK1_SEQ'   , cSequencia)

				oFK1:SetValue('FK1_FILORI',	SE1->E1_FILORIG)
				oFK1:SetValue('FK1_TXMOED',	SE1->E1_TXMOEDA )
				oFK1:SetValue('FK1_ORIGEM', FunName() )

				//--------------------------------------------------------------------------------
				// Verifica se o movimento bancário atualiza banco pelo tipodoc e motivo de baixa
				//--------------------------------------------------------------------------------
				If FINVerMov(cTpDoc).AND. MovBcobx('NOR',.T.)

					//Relacionamento FKA X FK5
					If !oFKA:IsEmpty()
						//Inclui a quantidade de linhas necessárias
						oFKA:AddLine()
						//Vai para linha criada
						oFKA:GoLine(oFKA:Length())
					Endif

					cIdFK5 := FWUUIDV4()

					oFKA:SetValue('FKA_IDORIG'	,cIdFK5															)
					oFKA:SetValue('FKA_TABORI'	,'FK5'																)

					oFK5:SetValue('FK5_IDMOV'	,cIdFK5															)
					oFK5:SetValue('FK5_RECPAG'	,"R"																)
					oFK5:SetValue('FK5_HISTOR'	,OemToAnsi(STR0029)												)
					oFK5:SetValue('FK5_DATA'		,dDataBase															)
					oFK5:SetValue('FK5_NATURE'	,SE1->E1_NATUREZ													)
					oFK5:SetValue('FK5_TPDOC'	,Iif ((cPaisLoc$"URU|CHI") .Or. (cPaisLoc $ "PAR" .and. !Empty(SE1->E1_NUMBOR)),"BA",cTpDoc))
					oFK5:SetValue('FK5_MOEDA'	,StrZero(Max(SA6->A6_MOEDA,1),2)								)
					oFK5:SetValue('FK5_VALOR'	,XMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,Max(SA6->A6_MOEDA,1))	)
					oFK5:SetValue('FK5_VLMOE2'	,SE1->E1_VALOR													)
					oFK5:SetValue('FK5_SEQ'		,cSequencia														)
					oFK5:SetValue('FK5_BANCO'	,SE1->E1_PORTADO													)
					oFK5:SetValue('FK5_AGENCI'	,SE1->E1_AGEDEP													)
					oFK5:SetValue('FK5_CONTA'	,SE1->E1_CONTA													)
					oFK5:SetValue('FK5_DTDISP'	,dDataBase															)
					oFK5:SetValue('FK5_ORIGEM'	,FunName()															)
					oFK5:SetValue('FK5_DOC'		,SE1->E1_NUMBOR													)
					oFK5:SetValue('FK5_FILORI'	,SE1->E1_FILORIG													)

					If !Empty(SE1->E1_NUMNOTA) .And. "LOJ" $ SE1->E1_ORIGEM
						oFK5:SetValue('FK5_NUMCH', SE1->E1_NUMNOTA)
					Endif

				EndIf

				oModel:SetValue('MASTER','E5_CAMPOS', cCamposE5)
				oModel:SetValue('MASTER','E5_GRV'		, .T.)
				//
				If oModel:VldData()
					oModel:CommitData()
				Else
					cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
					cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) 				 + ' - '
					cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])               
					Help( ,,"FN89VALID",,cLog, 1, 0 )              
				EndIf
					oModel:DeActivate()
					oModel:Destroy()
					oModel := Nil

				If FunName() == "FINA096"

					aAreaSEF:=SEF->(GetArea())
					cFiltroSEF := ""
					cFiltroSEF := SEF->(DbFilter())
					SEF->(DbClearFilter())
					SEF->(DbSetOrder(6))
					If SEF->(DbSeek(xFilial("SEF")+"R"+SE1->E1_BCOCHQ+SE1->E1_AGECHQ+SE1->E1_CTACHQ+SUBSTR(SE1->E1_NUM,1,Len(SEF->EF_NUM))+SE1->E1_PREFIXO))
						RecLock("SEF",.F.)
						SEF->EF_DATAPAG	:= dDataBase
						SEF->EF_REFTIP		:= "LR"
						SEF->EF_STATUS		:= "04"
						SEF->(MsUnLock())
						DbSelectArea("FRF")
						cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
						RecLock("FRF",.T.)
						FRF->FRF_FILIAL		:= xFilial("FRF")
						FRF->FRF_BANCO		:= SEF->EF_BANCO
						FRF->FRF_AGENCI		:= SEF->EF_AGENCIA
						FRF->FRF_CONTA		:= SEF->EF_CONTA
						FRF->FRF_NUM		:= SEF->EF_NUM
						FRF->FRF_PREFIX		:= SEF->EF_PREFIXO
						FRF->FRF_CART		:= "R"
						FRF->FRF_DATPAG		:= dDataBase
						FRF->FRF_MOTIVO		:= "10"
						FRF->FRF_DESCRI		:= "CHEQUE COMPENSADO"
						FRF->FRF_SEQ		:= cSeqFRF
						FRF->(MsUnLock())
						ConfirmSX8()
					Endif
					If !Empty(cFiltroSEF)
						SEF->(DbSetfilter({||&cFiltroSEF},cFiltroSEF))
					EndIf
					SEF->(RestArea(aAreaSEF))
				Endif
				// Se Portugal, alimenta aDiario
				If UsaSeqCor()
					AADD(aDiario,{"SE5",SE5->(recno()),cCodDiario,"E5_NODIA","E5_DIACTB"})
				endif

				SA6->(DbSetOrder(1))
				SA6->(DbSeek(xFilial()+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA))
				AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,dDataBase,SE5->E5_VALOR,"+")

				SA1->(DbSetOrder(1))
				SA1->(DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA))
				AtuSalDup("-",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,,SE1->E1_EMISSAO)
				// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				// ³  Ponto de Entrada para gravar campos de Usuário em SE5        ³
				// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("F089ATU")
					ExecBlock("F089ATU",.F.,.F.)
				EndIf

				// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				// ³  SI ES LA PRIMER BAJA DE LA SERIE DE BAJAS, CHEQUEO SI EXISTE EL      ³
				// ³  ASIENTO PADRONIZADO Y GENERO EL ENCABEZADO DEL ASIENTO SI ES VERDAD  ³
				// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cPadrao  := Fa070Pad()

				If lGeraLanc
					lLancPad70  := VerPadrao(cPadrao)
				Else
					lLancPad70	:= .F.
				EndIf
				If lPrim
					If lLancPad70 //.and. !__TTSInUse
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Posiciona numero do Lote para Lancamentos do Financeiro      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("SX5")
						dbSeek(xFilial()+"09FIN")
						cLoteCom:=IIF(Found(),Trim(X5_DESCRI),"FIN")
						nHdlPrv:=HeadProva( cLoteCom,;
						"FINA089",;
						Subs(cUsuario,7,6),;
						@cArquivo)
						If nHdlPrv <= 0
							Help(" ",1,"A100NOPROV")
						EndIf
					EndIf
					lPrim	:=	.F.
				Endif

				If nHdlPrv > 0 .and. lLancPad70 //.and. !__TTSInUse
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Genera Items de asiento Contab. para Baja de Cheques.    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lLancPad70
						SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
						SA6->(DbSeek(xFilial("SA6")+SE1->E1_PORTADOR+SE1->E1_AGEDEP+SE1->E1_CONTA))
						nTotalLanc += DetProva( nHdlPrv,;
						cPadrao,;
						"FINA089",;
						cLoteCom,;
						@nLinha,;
						/*lExecuta*/,;
						/*cCriterio*/,;
						/*lRateio*/,;
						/*cChaveBusca*/,;
						/*aCT5*/,;
						/*lPosiciona*/,;
						@aFlagCTB,;
						/*aTabRecOri*/,;
						/*aDadosProva*/ )

						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
							aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
						Else
							oModel := FWLoadModel("FINM010")
							oModel:SetOperation(MODEL_OPERATION_UPDATE)
						oModel:Activate()
						//Atualiza o campo Identifica Lançamento;
						oFKA := oModel:GetModel('FKADETAIL')
						If oFKA:SeekLine({{"FKA_IDORIG", SE5->E5_IDORIG}})
								oModel:SetValue( 'FK1DETAIL', 'FK1_LA', "S")
									
								If oModel:VldData()
									oModel:CommitData()
									Reclock("SE5")
									REPLACE E5_LA With "S"
									MsUnlock()
							Else
								cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
								cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) + ' - '
								cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])
								Help( ,,"FN370VL",,cLog, 1, 0 )
							EndIf
							Else
								
								cLog := STR0059 +  SE5->E5_IDORIG
								Help( ,,"FN370VL",,cLog, 1, 0 )
							Endif	
							
							oModel:Deactivate()
							oModel:Destroy()
							oModel:=nil				
						Aadd(aRecsSe5,SE5->(Recno()))
					EndIf
				Endif
                If cPAISLOC$"PER|BOL"
                	If lFindITF .And. FinProcITF( SE5->(Recno()),1 ) .AND. lRetCkPG(3,,SE5->E5_BANCO)
                    	FinProcITF( SE5->(Recno()),3,SE5->E5_VALOR, .F.,{nHdlPrv,cPadrao,"FINA089","FINA089",cLotecom},)
                   	EndIf
                EndIf
             Else
                If cPAISLOC$"PER|BOL"
                	If lFindITF .And. FinProcITF( SE5->(Recno()),1 ) .AND. lRetCkPG(3,,SE5->E5_BANCO)
                    	FinProcITF( SE5->(Recno()),3,SE5->E5_VALOR, .F.)
                   	EndIf
                EndIf
			Endif

			PcoDetLan("000360","01","FINA089",.F.)//BAJA LOS TITULOS RECIBIDOS DEL BANCO

			Endif
			DbSelectArea("TMP089")
			DbSkip()
		Enddo
	EndIf
		If cPaisLoc$"URU|PAR|CHI|BOL"
			SA6->(DbSetOrder(1))
			For nX:=1 To Len(aBorderos)
				nXaux := nX
				SA6->(MsSeek(xFilial("SA6")+aBorderos[nX][1]+aBorderos[nX][2]+aBorderos[nX][3]))
				oModel := FWLoadModel('FINM030') //Mov.Bancaria.
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				oModel:Activate()
				cCamposE5 := "{{'E5_DTDIGIT'	, dDataBase}"
				cCamposE5 += ",{'E5_DOCUMEN', aBorderos[nXaux][4]}"                            
				cCamposE5 += ",{'E5_VENCTO'	, dDataBase}"
				If cPaisLoc=="URU"
					cCamposE5 += " {'E5_FILIAL'		,'" + FWxFilial("SE5") + "'}"
					cCamposE5 += ",{'E5_CLIFOR'		,'" + SE1->E1_CLIENTE + "'}"
					cCamposE5 += ",{'E5_LOJA'		,'" + SE1->E1_LOJA + "'}"
					cCamposE5 += ",{'E5_NUMERO'		,'" + "BOR"+aBorderos[nXaux][4] + "'}"
					cCamposE5 += ",{'E5_PREFIXO'	,'" + SE1->E1_PREFIXO + "'}"
					cCamposE5 += ",{'E5_PARCELA'	,'" + SE1->E1_PARCELA + "'}"
					cCamposE5 += ",{'E5_TIPO'		,'" + SE1->E1_TIPO + "'}"
					cCamposE5 += ",{'E5_BENEF'		,'" + SE1->E1_NOMCLI + "'}"
				EndIf
				cCamposE5 += ",{'E5_FILORIG'	,'" + SE1->E1_FILORIG + "'}"
				cCamposE5 += ",{'E5_DTDISPO'	, dDataBase}}"
				
				oFKA := oModel:GetModel('FKADETAIL')
				oFK5 := oModel:GetModel('FK5DETAIL')
				//Cria FKA x FK5
				oFKA:SetValue('FKA_IDORIG', FWUUIDV4())
				oFKA:SetValue('FKA_TABORI','FK5')
				//
				oFK5:SetValue('FK5_RECPAG', 'R')
				oFK5:SetValue('FK5_HISTOR', STR0029)
				oFK5:SetValue('FK5_DATA'  , dDataBase)
				oFK5:SetValue('FK5_VLMOE2', aBorderos[nX][5])
				oFK5:SetValue('FK5_MOEDA' , StrZero(Max(SA6->A6_MOEDA,1),2))
				oFK5:SetValue('FK5_VALOR' , xMoeda(aBorderos[nX][5],1,Max(SA6->A6_MOEDA,1)))
				oFK5:SetValue('FK5_BANCO' , aBorderos[nX][1])
				oFK5:SetValue('FK5_AGENCI', aBorderos[nX][2])
				oFK5:SetValue('FK5_CONTA' , aBorderos[nX][3])		
				oFK5:SetValue('FK5_SEQ'   , F089Seq())		
				oFK5:SetValue('FK5_TPDOC' , "VL")
				//
				oModel:SetValue('MASTER','E5_GRV'		,.T.)
				oModel:SetValue('MASTER','E5_CAMPOS',cCamposE5)
				//
				If oModel:VldData()
					oModel:CommitData()
					oModel:DeActivate()
				Else
					cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
					cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ])        + ' - '
					cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])               
					Help( ,,"FN89VALID",,cLog, 1, 0 )              
				EndIf 	
				If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
					aAdd( aFlagCTB, {"E5_LA", "S", "SE5",SE5->( Recno() ), 0, 0, 0} )
				Else  
					oModel := FWLoadModel('FINM010')
					oModel:SetOperation(MODEL_OPERATION_UPDATE)
					oModel:Activate()
					//Atualiza o campo Identifica Lançamento;
					
					oFKA := oModel:GetModel('FKADETAIL')
					If oFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
						oFK1 := oModel:GetModel('FK1DETAIL')
						oFK1:SetValue( "FK1_MOEDA",SE5->E5_MOEDA)
						oFK1:SetValue( "FK1_DATA"  , dDataBase)
						oFK1:SetValue( "FK1_VALOR" ,SE5->E5_VALOR)							
						oFK1:SetValue( "FK1_TPDOC" ,SE5->E5_TIPODOC)
						oFK1:SetValue( "FK1_RECPAG",SE5->E5_RECPAG )
						oFK1:SetValue( "FK1_MOTBX" ,'NOR')
						oFK1:SetValue( "FK1_LA", "S")
						If oModel:VldData()
							oModel:CommitData()
							Reclock("SE5")
							REPLACE E5_LA With "S"
							MsUnlock()
							oModel:DeActivate()
						Else
							cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
							cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) 				 + ' - '
							cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])         	
							Help( ,,"FN89VL",,cLog, 1, 0 )
						EndIf	
					EndIf
				EndIf
			Next
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Genera Pie de asiento Contab. para Baja de Cheques.      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nHdlPrv > 0 .and. lLancPad70 //.and. !__TTSInUse
			RodaProva(	nHdlPrv,;
			nTotalLanc)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia para Lancamento Contabil, se gerado arquivo   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			n	:=	1
			lLanctOk := cA100Incl( cArquivo,;
			nHdlPrv,;
			3,;
			cLoteCom,;
			lDigita,;
			lAglutina,;
			/*cOnLine*/,;
			/*dData*/,;
			/*dReproc*/,;
			@aFlagCTB,;
			/*aDadosProva*/,;
			aDiario )
			aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

			If !lLanctOk .And. Len(aREcsSe5) > 0 .AND. !lUsaFlag

				oModel := FWLoadModel('FINM010') //Baixas a receber.
				For nA:=1  to Len(aREcsSe5)

					SE5->(DbGoTo(aRecsSE5[nA]))
					oModel:SetOperation(MODEL_OPERATION_UPDATE)
					oModel:Activate()
					//Atualiza o campo Identifica Lançamento;
					oFKA := oModel:GetModel('FKADETAIL')
					If oFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
						oFK1:SetValue( 'FK1DETAIL', 'FK1_MOEDA',SE5->E5_MOEDA)
						oFK1:SetValue( 'FK1DETAIL', 'FK1_VENCTO',SE5->E5_VENCTO)
						oFK1:SetValue( 'FK1DETAIL', 'FK1_DATA', dDataBase)
						oFK1:SetValue( "FK1DETAIL", 'FK1_VALOR' ,SE5->E5_VALOR)							
						oFK1:SetValue( "FK1DETAIL", 'FK1_TPDOC' ,SE5->E5_TIPODOC)
						oFK1:SetValue( "FK1DETAIL", 'FK1_RECPAG',SE5->E5_RECPAG )
						oFK1:SetValue( "FK1DETAIL", 'FK1_MOTBX' ,SE5->E5_MOTBX)
						oFK1:SetValue( "FK1DETAIL", "FK1_LA", " ")
						//
						If oModel:VldData()
							oModel:CommitData()
							oModel:DeActivate()	
						Else
							cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
							cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) 				 + ' - '
							cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])         	
							Help( ,,"FN370VL",,cLog, 1, 0 )
						EndIf	
					EndIf

				Next
			EndIf
		EndIf
	EndIf

	PcoFinLan("000360")

	If oTmpTable <> Nil   
		oTmpTable:Delete()  
		oTmpTable := Nil
	EndIf 
	DbSelectArea("SE1")
    If !lAutomato
    	Eval( bFiltraBrw )
	Endif
	If cPaisLoc $ "ARG|DOM|EQU" .and. FunName() == "FINA096"
		RestArea(aAreaA089)
	Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A089Rechaz³ Autor ³ BRUNO SOBIESKI        ³ Data ³ 26/03/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rechazar cheques.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA089                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Bruno Sobieski³01.10.99³Melhor³Gravar E1_STATUS="R".                   ³±±
±±³Bruno Sobieski³12.11.99³Melhor³Atualizar os campos de CHQ devolvidos.  ³±±
±±³              ³        ³      ³ Gerar uma NDC para documentar a divida.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A089Rechaz(lAutomato)        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local oBanco
	Local oGet1
	Local oGet2
	Local oGet3
	Local oGet4
	Local oFnt
	Local oCBX
	Local cTipDev		:= ""
	Local cBordero		:= Criavar("E1_NUMBOR"	)
	Local nRecSE1		:= 0
	Local cArqTrb		:= ""
	Local cCondicoes	:= ""
	Local cCondWhile	:= ""
	Local aCampos		:= {}
	Local aTits			:= {}
	Local aCamposShw	:= {}
	Local lConfirmado	:= .F.
	Local cBanco		:= Criavar("A6_COD")
	Local cAgencia		:= ""
	Local cConta		:= ""
	Local dRedep		:= CTOD("")
	Local cDescBco		:= ""
	Local cHistor		:= STR0037  // "Por cheque rechazado."
	Local aOpcoes		:= {OemToAnsi(STR0069),OemToAnsi(STR0070)}  //"Revertir","Anular"
	Local cOpcao		:= aOpcoes[1]
	Local nA1			:= 205
	Local nA2			:= 55
	Local cTipCheques	:= ""
	Local cTipoDiv 		:= ""
	Local nA			:= 0
	Local nX			:= 0
	Local nI			:= 0
	Local nH			:= 0
	Local aAreaSA1		:= {}
	Local aAreaSE1		:= {}
	Local aAreaSE5		:= {}
	Local aAreaSEA		:= {}
	Local cChaveSEA		:= {}
	Local cTipos		:= MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVENVBCOR
	Local cLstDesc		:= FN022LSTCB(2)	//Lista das situacoes de cobranca (Descontada)
	Local cLstBcoNoDesc	:= FN022LSTCB(5)	//Lista das situacoes de cobranca (Em banco mas sem desconto)
	Local cChaveTit := ""
	Local cIdDoc    := ""
	Local cLog      := ""
	Local oModel  
	Local oFKA    
	Local oFK1
Local cIdFK5    := ""
Local cIdFK1    := ""
Local lBan      := .T.

	cTipos	:=	StrTran(cTipos,',','/')
	cTipos	:=	StrTran(cTipos,';','/')
	cTipos	:=	StrTran(cTipos,'|','/')
	cTipos	:=	StrTran(cTipos,'\','/')

	If cPaisLoc$"URU|BOL"
		nA1	:=	215
		nA2 := 57
	Endif

	cHistor	+=	Space( TamSx3("E1_HIST")[1] -  Len(cHistor) )

	SetPrvt("CARQUIVO,NHDLPRV,NTOTALLANC,CLOTECOM,NLINHA,LCANCEL")
	SetPrvt("CCLIENTE,CLOJA,DDATADE,DDATAATE,NREC")
	SetPrvt("NINDEX1,NINDEX,NTOTSEL,CMARCAE1,ACAMPOS")
	SetPrvt("N,NCONFIRMO,LPRIM,ARECSSE5,LLANCPAD70,LLANCTOK")
	SetPrvt("NA,")

	//Definidos como Proivates para poder ser usados no ponto de entrada, a089canc
	Private cIndexKey	:= "E1_CLIENTE+E1_NUM"
	Private cMsg		:= STR0047 //"Cliente+Numero"
	Private nOpcao		:= 0
	Private nRadio		:= 1  // Usado na Rotina do FINA590para excluir o Bordero
	Private cNumBor 	:= Criavar("E1_NUMBOR"	)   // Usado na Rotina do FINA590para excluir o Bordero
	Private aDiario		:= {}
	Private cCodDiario	:= ""
    Default lAutomato	:= .F.  // Utilizada para el paso de scripts automatizados
	cArquivo	:= ""
	nHdlPrv		:= 1
	nTotalLanc	:= 0
	cLoteCom	:= ""
	nLinha		:= 2
	lCancel		:= .T.
	cCliente	:= CriaVar("A1_COD")
	cLoja		:= CriaVar("A1_LOJA")
	dDataDe 	:= dDataBase
	dDataAte	:= dDataBase
	nRec		:= SE1->(Recno())
	 If !lAutomato	
		DEFINE MSDialog oDlg1 FROM 65,0 To nA1,386  Title OemToAnsi(STR0010)  PIXEL // "Par metros"
		@ 00,003 To nA2,184 OF oDLG1 PIXEL
		@ 09,008 SAY OemToAnsi(STR0030)  OF oDLG1 PIXEL // "Cliente "
		@ 09,045 MSGet cCliente F3 "SA1" Picture "@!" Valid ExistCpo("SA1") OF oDLG1 PIXEL
		@ 09,108 SAY OemToAnsi(STR0031)  SIZE 40,10  OF oDLG1 PIXEL // "Sucursal"
		@ 09,136 MSGet cLoja  Picture "@!" Valid ExistCpo("SA1",cCliente+cLoja) OF oDLG1 PIXEL
		@ 25,008 SAY OemToAnsi(STR0013)  OF oDLG1 PIXEL // "Vencto. de "
		@ 25,045 MSGet dDataDe Picture "@!" SIZE 40,10 OF oDLG1 PIXEL
		@ 25,095 SAY OemToAnsi(STR0014)  SIZE 40,10 OF oDLG1 PIXEL // "Vencto. Hasta "
		@ 25,136 MSGet dDataAte Picture "@!" SIZE 40,10 OF oDLG1 PIXEL
		@ 41,008 SAY OemToAnsi(STR0046)   PIXEL Of oDlg1//"Bordero : "
		@ 41,045 MSGet cBordero 	Picture "@!" Valid .T. PIXEL Of oDlg1
		If cPaisLoc$"URU|BOL"
			@ 41,095 SAY OemToAnsi(STR0071) PIXEL SIZE 80,10 Of oDlg1  //"Titulos "
			@ 41,136 COMBOBOX oCBX VAR cOpcao ITEMS aOpcoes  Valid (!Empty(cBordero).Or.oCbx:nAt == 1 ) SIZE 40,40 OF oDlg1 PIXEL
		EndIf
		DEFINE SBUTTON FROM 59,108 Type 1 Action (lCancel	:=	.F.,oDlg1:END()) ENABLE OF oDLG1 PIXEL
		DEFINE SBUTTON FROM 59,149 Type 2 Action (oDlg1:END()) ENABLE OF oDLG1 PIXEL

		Activate MSDialog oDlg1 CENTERED
	 Else
		 If FindFunction("GetParAuto")
				aRetAuto 		:= GetParAuto("FINA089TESTCASE")
				cCliente 		:= aRetAuto[1]
				cLoja	 		:= aRetAuto[2]
				dDataDe			:= aRetAuto[3]
				dDataAte		:= aRetAuto[4]
				lGeraLanc		:= .F.
				lCancel 		:= .F.
				lInverte 		:= .F.
				lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/ )
				oTmpTable 		:= Nil
		 Endif
	 EndIf
 
	If lCancel
		RETURN
	Endif

	aCampos	:=	{}
	aTits		:=	{}
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("E1_OK")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{" ",""})
	If cPaisLoc == "PAR"
		DbSeek("E1_NUMCHQ")
		Aadd(aCampos,{X3_CAMPO	,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
		AAdd(aTits,{X3Titulo(),X3_PICTURE})
	EndIf
	DbSeek("E1_TIPO")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_VALOR")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_BCOCHQ")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_AGECHQ")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_CTACHQ")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_PORTADO")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_NUM")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_MOEDA")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_VLCRUZ")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_CLIENTE")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_LOJA")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_VENCTO")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})

	If ExistBlock("A089CAMP")
		Execblock("A089CAMP",.F.,.F.,2)
	Endif

	Aadd(aCampos,{"RECSE1"		,"N"    ,14        ,0         })

	#IFDEF TOP
		SE1->(DbSetOrder(2))
		cQuery:= "SELECT "
		For nX	:=	1	To	Len(aCampos) - 1
			cQuery	+=	aCampos[nX][1] + ","
		Next
		//Ver con quico ~!!!!!!!
		cQuery+= " R_E_C_N_O_  RECNO "
		cQuery+= " FROM " + RetSqlName("SE1")
		cQuery+= " WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
		cQuery+= " AND E1_CLIENTE =  '" + cCliente  + "' AND E1_LOJA =  '" + cLoja + "'"
		cQuery+= " AND E1_PREFIXO >= ' ' "
		cQuery+= " AND E1_NUM     >= ' ' "
		cQuery+= " AND E1_PARCELA >= ' ' AND ("
		cTipCheques := Substr(MVCHEQUES,1,3)
		For nH = 1 to Len(MVCHEQUES) Step 4
			cQuery += " E1_TIPO = '"+cTipCheques+"'"
			If nH+2 <> Len(MVCHEQUES)
				cQuery += " OR "
				cTipCheques := Substr(MVCHEQUES,nH+4,3)
			EndIf
		Next nH
		cQuery+= ")"
		If !Empty(MVPROVIS) .Or. !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .Or. !Empty(MVENVBCOR)
			cQuery += "   AND  E1_TIPO NOT IN "+FormatIn(cTipos,'/')
		Endif
	
		cQuery+= " AND D_E_L_E_T_ <> '*' "
		If !Empty(cBordero)
			cQuery	+= " AND E1_NUMBOR ='"+cBordero+"' "
		Endif
		If cOpcao == aOpcoes[2]
			cQuery+= " AND E1_SALDO = 0 AND E1_SITUACA IN "+ FormatIn(cLstDesc,'|')
		Else
			cQuery+= " AND E1_SALDO > 0 AND E1_SITUACA IN "+ FormatIn(cLstBcoNoDesc,'|')
		Endif
		cQuery+= " AND E1_PORTADO <> '" +Space(lEN(SE1->E1_PORTADO))+"' "
		cQuery+= " AND E1_VENCREA BETWEEN '" + Dtos(dDataDe) + "' AND '" + dTos(dDataAte) + "'"
		If ExistBlock("A089CONDS")
			cQuery	+=	ExecBlock("A089CONDS",.F.,.F.,2)
		Endif
	
		cQuery+= " ORDER BY " + SQLORDER(SE1->(IndexKey()))
		cQuery:= ChangeQuery(cQuery)
	  If !lAutomato
		 MsAguarde({ | | MsProcTxt(STR0051),dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1TMP', .T., .T.) },STR0048,STR0049 ) //"Por favor aguarde"###"Seleccionando registros en el Servidor... "
	  Else
		 MsAguarde({ | | dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1TMP', .T., .T.) },STR0048,STR0049 ) //"Seleccionando registros en el Servidor... "###"Por favor aguarde"###"Seleccionando registros en el Servidor..."
	  Endif
		For ni := 1 to Len(aCampos)-1
			If aCampos[ni,2] != 'C'
				TCSetField('SE1TMP', aCampos[ni,1], aCampos[ni,2],aCampos[ni,3],aCampos[ni,4])
			Endif
		Next
		DbSelectArea("SE1TMP")
		cAliasTmp	:=	"SE1TMP"
		cCondicoes	:=	".T."
		cCondWhile	:=	"!EOF()"

	#ELSE

		cCondicoes	:= "E1_TIPO $ '"+MVCHEQUES +"' "
		cCondicoes	+= ".AND. !(E1_TIPO $ '"+MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVENVBCOR+"')" // Alteracao conforme BOPS 66.626
		cCondicoes	+= ".AND. DTOS(E1_VENCREA) >= '" + Dtos(dDataDe) + "' .AND. DTOS(E1_VENCREA) <= '" + dTos(dDataAte) + "'"
		cCondicoes 	+= ".AND. E1_PORTADO <> '" +Space(lEN(SE1->E1_PORTADO))+"' "
		If !Empty(cBordero)
			cCondicoes	+=	" .AND. E1_NUMBOR =='"+cBordero+"' "
		Endif
		If cOpcao == aOpcoes[2]
			cCondicoes += " .AND. E1_SALDO == 0 .AND. E1_SITUACA $ '" + cLstDesc     + "' "
		Else
			cCondicoes += " .AND. E1_SALDO > 0 .AND. E1_SITUACA $  '" +cLstBcoNoDesc + "' "
		Endif
		If ExistBlock("A089CONDS")
			cCondicoes	+=	ExecBlock("A089CONDS",.F.,.F.,2)
		Endif
		cCondWhile	:=	 "!EOF() .AND. E1_CLIENTE == '" + cCliente + "' .AND. E1_LOJA == '"+ cLoja +"'"
		DbSelectArea("SE1")
		DbSetOrder(2)
		DbSeek(xFilial()+cCliente+cLoja)
		cAliasTmp	:=	"SE1"
	#ENDIF

	cMarcaE1	:=	GetMark()
	Processa( {|| a089CrTRB(cCondicoes,cCondWhile,cAliasTmp,aCampos,@cArqTrb,cMarcaE1,lInverte)})

	#IFDEF TOP
		DbSelectArea(cAliasTmp)
		DbCloseArea()
	#ELSE
		nIndex := Retindex("SE1")
	#ENDIF
	DbSelectArea("TMP089")
	DbGoTop()

	If BOF() .and. EOF()
		HELP(" ",1,"NORECS")
		If oTmpTable <> Nil   
			oTmpTable:Delete()  
			oTmpTable := Nil
		EndIf 
		DbSelectArea("SE1")
		If !lAutomato
			Eval( bFiltraBrw )
		Endif
		Return
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Voy montar el RDSELECT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCamposShw  := {}
		//Carregar os campos a serem exibidos
		For nX   := 1  To Len(aTits)
			Aadd(aCamposShw,{aCampos[nX][1],"",aTits[nX][1],aTits[nX][2]})
		Next

		DbGoTop()
		n	:=	1
		//"Selecci¢n de t¡tulos recibidos","Cliente : ","   Sucursal : "
	  If !lAutomato
		  nConfirmo:=RdSelect("TMP089","E1_OK",,aCamposShw,OemToAnsi(STR0027),OemToAnsi(STR0035) + cCliente + OemToAnsi(STR0036)+cLoja ,,cMarcaE1,.F.,,,"FI089TO")
      Else 
            Replace TMP089->E1_OK With cMarcaE1      
            nConfirmo := 1
      Endif
		If UsaSeqCor()
			cCodDiario := CTBAVerDia()
		Endif

		If nConfirmo <>1
			If oTmpTable <> Nil   
				oTmpTable:Delete()  
				oTmpTable := Nil
			EndIf 
			DbSelectArea("SE1")
			Eval( bFiltraBrw )
			Return
		Endif

		If !cPaisLoc$"URU|BOL"
			aOpcoes := {IIf(cPaisLoc=="CHI",STR0075,STR0052),STR0053} //"Cancelar el cheque y generar nota de debito"###"Transferir para una caja"
			DEFINE FONT oFnt  NAME "Arial" SIZE 09,11 BOLD

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Criacao da Interface                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		  If !lAutomato
			DEFINE MSDialog  oDlgRech FROM 261,343 To 473,815 Title OemToAnsi(STR0054) PIXEL //"Cheques rechazados"
			@ 005,005 To 106,185 LABEL OemToAnsi(STR0055) PIXEL Of oDlgRech //"Tratamiento de cheques rechazados"
			@ 010,006  RADIO oRadio VAR nOpcao 3D ;
			SIZE 150,10 ;
			ITEMS OemToansi(aOpcoes[1]), OemToAnsi(aOpcoes[2]);
			ON CHANGE { || a089Refr(oGet1,oGet2,oGet3,oGet4,,,nOpcao) };
			Pixel OF oDlgRech

			@ 33,050 MSGET cHistor	 	Picture "@!" 	SIZE 120,10 OF oDlgRech PIXEL
			@ 33,010 SAY OemToAnsi(STR0063) SIZE 20, 10 OF oDlgRech PIXEL  //"Historico "

			@ 50,010 To 099,179 LABEL OemToAnsi(STR0056) PIXEL Of oDlgRech //"Elija la caja"

			@ 60,016 MSGET oGet1 VAR cBanco		F3 "SA6" Picture "@S3"    Valid CarregaSa6(@cBanco,@cAgencia,@cConta,.F.) 	.And.	((ExistCpo("SA6",cBanco+cAgencia+cConta ).Or.Empty(cBanco  )).And. a089Refr(oGet1,oGet2,oGet3,oGet4,@oBanco,cBanco+cAgencia+cConta,3))	SIZE 10, 10 OF oDlgRech PIXEL
			@ 60,047 MSGET oGet2 VAR cAgencia	Picture "@S5"             Valid CarregaSa6(@cBanco,@cAgencia,@cConta,.F.)	.And. ((ExistCpo("SA6",cBanco+cAgencia+cConta ).Or.Empty(cAgencia)).And. a089Refr(oGet1,oGet2,oGet3,oGet4,@oBanco,cBanco+cAgencia+cConta,3))	SIZE 20, 10 OF oDlgRech PIXEL
			@ 60,079 MSGET oGet3 VAR cConta		Picture "@S10"            Valid CarregaSa6(@cBanco,@cAgencia,@cConta,.F.)	.And. ((ExistCpo("SA6",cBanco+cAgencia+cConta ).Or.Empty(cConta)  ).And. a089Refr(oGet1,oGet2,oGet3,oGet4,@oBanco,cBanco+cAgencia+cConta,3))	SIZE 45, 10 OF oDlgRech PIXEL

			@ 75,020 SAY oBanco VAR cDescBco SIZE 150, 10 OF oDlgRech FONT  oFnt COLOR  CLR_BLUE PIXEL

			@ 85,065 MSGET oGet4 VAR dRedep	 Valid  (Empty(dRedep).Or.dRedep>=dDataBase)	SIZE 40, 10 OF oDlgRech PIXEL
			@ 85,016 SAY OemToAnsi(STR0064) SIZE 40, 10 OF oDlgRech PIXEL  //"Redepositar el  "

			a089Refr(oGet1,oGet2,oGet3,oGet4,oBanco,,nOpcao)

			DEFINE SBUTTON FROM 085,192 Type 1  Action IIf(nOpcao <> 0,(lConfirmado	:=	.T. ,oDlgRech:End()),Nil) ENABLE OF oDlgRech

			Activate MSDialog oDlgRech CENTERED
		  Else
		    nOpcao := 1
			lConfirmado := .T.
		  EndIf
		Else
			nOpcao := 1
			lConfirmado := .T.
		Endif
		If lConfirmado
			DbSelectArea("TMP089")
			DbGoTop()
			lPrim	:=	.T.
			aRecsSe5	:=	{}

			PcoIniLan("000360")

			Do while !EOF()
				If E1_OK == cMarcaE1
					If nOpcao == 1
						cCamposE5 := ""
						DbSelectArea("SE1")
						DbGoTo(TMP089->RECSE1)
			
						nRecSE1	:=	Recno()
						RecLock("SE1",.F.)
						SE1->E1_BAIXA 		:= dDatabase
						SE1->E1_SALDO 		:= 0.00
						SE1->E1_STATUS		:=	"R"
						SE1->E1_MOVIMEN	    := dDataBase
						SE1->E1_SITUACA	    := "0"
						SE1->E1_HIST   	    := cHistor
						MsUnlock()
						//Estorno da conbranza descontada
						DbSelectArea("SE5" )
						If cOpcao == aOpcoes[2]
			
							oModel := FWLoadModel('FINM010') //Baixas a receber.
							oModel:SetOperation(MODEL_OPERATION_INSERT)
							oModel:Activate()
							oFKA := oModel:GetModel('FKADETAIL')
							oFK1 := oModel:GetModel('FK1DETAIL')
							oFK5 := oModel:GetModel('FK5DETAIL')
							//FK7 x SE1.
							cChaveTit := xFilial("SE1")  + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM 			+ "|" +;
							SE1->E1_PARCELA + "|" +  SE1->E1_TIPO 		+ "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
							cIdDoc := FINGRVFK7("SE1", cChaveTit)
							//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
							cCamposE5 := "{{'E5_DTDIGIT'	, dDataBase}"
							cCamposE5 += ",{'E5_TIPO'	   , SE1->E1_TIPO}"                            
							cCamposE5 += ",{'E5_PREFIXO'	, SE1->E1_PREFIXO}"
							cCamposE5 += ",{'E5_NUMERO'	, SE1->E1_NUM}"
							cCamposE5 += ",{'E5_PARCELA'	, SE1->E1_PARCELA}"
							cCamposE5 += ",{'E5_CLIFOR'	, SE1->E1_CLIENTE}"
							cCamposE5 += ",{'E5_LOJA'			, SE1->E1_LOJA}"                            
							cCamposE5 += ",{'E5_BENEF'		, SE1->E1_NOMCLI}"
							cCamposE5 += ",{'E5_DTDISPO'	, dDataBase}}"
							//FKA
							oFKA:SetValue('FKA_IDORIG', FWUUIDV4())
							oFKA:SetValue('FKA_TABORI', 'FK1')
			
							//FKA x FK1
							oFK1:SetValue('FK1_DATA'  ,dDataBase)
							oFK1:SetValue('FK1_MOEDA' ,StrZero(SE1->E1_MOEDA,2))
							oFK1:SetValue('FK1_VALOR' ,SE1->E1_VLCRUZ)							
							oFK1:SetValue('FK1_TPDOC' ,'CB')
							oFK1:SetValue('FK1_RECPAG','P' )
							oFK1:SetValue('FK1_HISTOR',cHistor)
							oFK1:SetValue('FK1_SEQ'   ,F089Seq())
							oFK1:SetValue('FK1_VENCTO',dDataBase)
							oFK1:SetValue('FK1_DOC'   ,SE1->E1_NUMBOR)
							oFK1:SetValue('FK1_VLMOE2',SE1->E1_VALOR)
							oFK1:SetValue('FK1_NATURE',SE1->E1_NATUREZ)
							oFK1:SetValue('FK1_MOTBX' ,'NOR')
							oFK1:SetValue('FK1_ORDREC',SE1->E1_RECIBO)
							oFK1:SetValue('FK1_SERREC',SE1->E1_SERREC)
							If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
								aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
							Else
								oFK1:SetValue('FK1_LA','S')
							EndIf	
			
							//FKA x FK5
							oFKA:AddLine()
							oFKA:SetValue('FKA_IDORIG', FWUUIDV4())
							oFKA:SetValue('FKA_TABORI', 'FK5')
							//
							oFK5:SetValue('FK5_BANCO' ,SE1->E1_PORTADO)
							oFK5:SetValue('FK5_AGENCI',SE1->E1_AGEDEP)
							oFK5:SetValue('FK5_CONTA' ,SE1->E1_CONTA) 
							oFK5:SetValue('FK5_DTDISP',dDataBase)
			
							oModel:SetValue('MASTER','E5_CAMPOS',cCamposE5)
							If oModel:VldData()
								oModel:CommitData()
							Else
								cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
								cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) 				 + ' - '
								cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])                  
								Help( ,,"M010VALID",,cLog, 1, 0 )              
							EndIf	
			
							AtuSalBco(SE1->E1_PORTADO,SE1->E1_AGEDEP,SE1->E1_CONTA,dDataBase,SE5->E5_VALOR,"-")
			
							oModel:DeActivate()
							oModel:Destroy()
							oModel := nil
							oFKA := nil
							oFK1 := nil
							oFK5 := nil
						Else
							oModel := FWLoadModel('FINM010') //Baixas a receber.
							oModel:SetOperation(MODEL_OPERATION_INSERT)
							oModel:Activate()
							oFKA := oModel:GetModel('FKADETAIL')
							oFK1 := oModel:GetModel('FK1DETAIL')
							oFK5 := oModel:GetModel('FK5DETAIL')
							lBan  := .F.
						Endif
			
						If cPaisLoc == "CHI"
							cPadrao := "574"
						Else
							cPadrao	:=	Fa070Pad()
						EndIf
						If lBan
							oModel := FWLoadModel('FINM010') //Baixas a receber.
							oModel:SetOperation( MODEL_OPERATION_INSERT )
							oModel:Activate()
			
							oFKA := oModel:GetModel('FKADETAIL')
							oFK1 := oModel:GetModel('FK1DETAIL')
							oFK5 := oModel:GetModel('FK5DETAIL')
						EndIf
						//Campos SE1.
						cNatSE1:= SE1->E1_NATUREZ
						cNumSE1:= SE1->E1_NUM 
						cParcSE1:= SE1->E1_PARCELA
						cCliSE1:= SE1->E1_CLIENTE
						cLojaSE1:= SE1->E1_LOJA
						cNomeSE1:= SE1->E1_NOMCLI
						nValorSE1:= SE1->E1_VALOR
						nMoedaSE1:= SE1->E1_MOEDA
			
						nVlCSE1:= SE1->E1_VLCRUZ
						cCamposE5 := "{{'E5_DTDIGIT'	, dDataBase}"
						cCamposE5 += ",{'E5_TIPO'	   , SE1->E1_TIPO}"                            
						cCamposE5 += ",{'E5_PREFIXO'	, SE1->E1_PREFIXO}"
						cCamposE5 += ",{'E5_NUMERO'	, SE1->E1_NUM}"
						cCamposE5 += ",{'E5_PARCELA'	, SE1->E1_PARCELA}"
						cCamposE5 += ",{'E5_CLIFOR'	, SE1->E1_CLIENTE}"
						cCamposE5 += ",{'E5_LOJA'			, SE1->E1_LOJA}"                            
						cCamposE5 += ",{'E5_BENEF'		, SE1->E1_NOMCLI}"
						cCamposE5 += ",{'E5_BANCO'		, SE1->E1_PORTADO}"
						cCamposE5 += ",{'E5_AGENCIA'		, SE1->E1_AGEDEP}"
						cCamposE5 += ",{'E5_CONTA'		, SE1->E1_CONTA}"
						cCamposE5 += ",{'E5_DOCUMEN'		, SE1->E1_NUMBOR}"
						cCamposE5 += ",{'E5_DTDISPO'	, dDataBase}}"
						//FK7 x SE1.
						cChaveTit := xFilial("SE1")  + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM 			+ "|" +;
						SE1->E1_PARCELA + "|" +  SE1->E1_TIPO 		+ "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
						cIdDoc    := FINGRVFK7("SE1", cChaveTit)
						//FKA
						oFKA:SetValue('FKA_IDORIG', FWUUIDV4())
						oFKA:SetValue('FKA_TABORI', 'FK1')
						//FKA x FK1
						oFK1:SetValue('FK1_IDFK1' , cIdFK1 )
						oFK1:SetValue('FK1_IDDOC' , cIdDoc)
						oFK1:SetValue('FK1_DATA'  , dDataBase)
						oFK1:SetValue('FK1_MOTBX' , "NOR")
						oFK1:SetValue('FK1_NATURE', SE1->E1_NATUREZ)
						oFK1:SetValue('FK1_TPDOC' , "BA")
						oFK1:SetValue('FK1_HISTOR', cHistor)
						oFK1:SetValue('FK1_RECPAG', "R")
						oFK1:SetValue('FK1_SERREC', SE1->E1_SERREC)
						oFK1:SetValue('FK1_ORDREC', SE1->E1_RECIBO)
						oFK1:SetValue('FK1_VLMOE2', SE1->E1_VALOR )
						oFK1:SetValue('FK1_MOEDA' , StrZero(SE1->E1_MOEDA,2))
						oFK1:SetValue('FK1_VALOR' , SE1->E1_VLCRUZ)
						oFK1:SetValue('FK1_VENCTO', dDataBase)
						oFK1:SetValue('FK1_SEQ'   , F089Seq())
						//
						//Relacionamento FKA X FK5
						If !oFKA:IsEmpty()
							oFKA:AddLine()
							oFKA:GoLine(oFKA:Length())
						Endif
			
						cIdFK5 := FWUUIDV4()
						//FKA x FK5
						oFKA:SetValue('FKA_IDORIG'	,cIdFK5)
						oFKA:SetValue('FKA_TABORI'	,'FK5')
						//FK5
						oFK5:SetValue('FK5_IDMOV'	,cIdFK5)
						oFK5:SetValue('FK5_HISTOR'	,cHistor)
						oFK5:SetValue('FK5_DATA'	,dDataBase)
						oFK5:SetValue('FK5_NATURE'	,SE1->E1_NATUREZ)
						oFK5:SetValue('FK5_VLMOE2'	,SE1->E1_VALOR)
						oFK5:SetValue('FK5_BANCO'	,SE1->E1_PORTADO)
						oFK5:SetValue('FK5_AGENCI'	,SE1->E1_AGEDEP)
						oFK5:SetValue('FK5_CONTA'	,SE1->E1_CONTA)
						oFK5:SetValue('FK5_ORIGEM'	,FunName())
						oFK5:SetValue('FK5_DOC'		,SE1->E1_NUMBOR)
						oFK5:SetValue('FK5_FILORI'	,SE1->E1_FILORIG)
						oFK5:SetValue('FK5_VALOR' , SE1->E1_VLCRUZ)
						oFK5:SetValue('FK5_MOEDA' , StrZero(SE1->E1_MOEDA,2))
						oFK5:SetValue('FK5_TPDOC' , "BA")
						oFK5:SetValue('FK5_DTDISP',dDataBase)
						oModel:SetValue('MASTER','E5_CAMPOS',cCamposE5)
						oModel:SetValue('MASTER','E5_GRV'		,.T.)
						If oModel:VldData()
							oModel:CommitData()
						Else
							cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
							cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) 				 + ' - '
							cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])                   
							Help( ,,"FN89VALID",,cLog, 1, 0 )              
						EndIf	  
						oModel:DeActivate()
						oModel:Destroy()
						oModel := nil
						oFKA := nil
						oFK1 := nil
			
						cTipDev := F089TipDev(SE1->E1_TIPO)
						If ( Empty(cTipDev) )
							// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							// ³  Gravo uma NDC no SE1 para documentar a d¡vida . O prefixo vai ser DEV³
							// ³  que vƒ indicar que a origem e uma devolu‡Æo e o n£mero o mesmo do CH.³
							// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If cPaisLoc$"URU|BOL"
								cTipoDiv := "CHR"
							ElseIf	cPaisLoc == "CHI"
								cTipoDiv := "CHP"
							Else
								cTipoDiv := "NDC"
							EndIf
						Else
							cTipoDiv := cTipDev
						Endif
			
						// Se Portugal, alimenta aDiario
						If UsaSeqCor()
							AADD(aDiario,{"SE5",SE5->(recno()),cCodDiario,"E5_NODIA","E5_DIACTB"})
						endif
			
			
						RecLock("SE1",.T.)
						SE1->E1_FILIAL    := xFilial("SE1")
						SE1->E1_NATUREZ   := cNatSE1
						SE1->E1_PREFIXO   := "DEV"
						SE1->E1_NUM       := cNumSE1
						SE1->E1_PARCELA   := cParcSE1 
						SE1->E1_CLIENTE   := cCliSE1  
						SE1->E1_LOJA      := cLojaSE1 
						SE1->E1_NOMCLI    := cNomeSE1 
						SE1->E1_VALOR     := nValorSE1 
						SE1->E1_SALDO     := nValorSE1 
						SE1->E1_TIPO      := cTipoDiv
						SE1->E1_MOEDA     := nMoedaSE1   
						SE1->E1_VLCRUZ    := nVlCSE1   
						SE1->E1_EMISSAO   := dDataBase
						SE1->E1_VENCTO    := dDataBase
						SE1->E1_VENCORI   := dDataBase
						SE1->E1_VENCREA   := dDataBase
						SE1->E1_EMIS1     := dDataBase
						SE1->E1_STATUS    := "A"
						SE1->E1_HIST      := cHistor
						SE1->E1_SITUACA   := "0"
			
						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
							aAdd( aFlagCTB, {"E1_LA", "S", "SE1", SE1->( Recno() ), 0, 0, 0} )
						Else
							SE1->E1_LA        := "S"
						EndIf
			
						MsUnLock()
					Else
						DbSelectArea("SE1")
						DbGoTo(TMP089->RECSE1)
						nRecSE1	:=	Recno()
						cChaveSEA := SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
			
						If !Empty(SE1->E1_NUMBOR	 )    .AND.  cPaisLoc <> "ARG"
							// Guardar Posicao dos arquivos
							aAreaSA1:= 	SA1->(GetArea())
							aAreaSE1:=	SE1->(GetArea())
							aAreaSE5:=	SE5->(GetArea())
							aAreaSEA:=	SEA->(GetArea())
			
							cNumBor:= SE1->E1_NUMBOR
							Fa590Canc()
			
							// Restaurar posicao dos arquivos
							SA1->(RestArea(aAreaSA1))
							SE1->(RestArea(aAreaSE1))
							SE5->(RestArea(aAreaSE5))
							SEA->(RestArea(aAreaSEA))
						EndIf
						RecLock("SE1",.F.)
						SE1->E1_STATUS	:="R"
						SE1->E1_MOVIMEN:= dDataBase
						// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						// ³ Por solicitações das regras de Negocios para Argentina, não apagar    ³
						// ³ E1_NUMBOR e E1_DATABOR...											   ³
						// ÀÄLucasÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SE1->E1_SITUACA := "0"
						SE1->E1_PORTADO := cBanco
						SE1->E1_AGEDEP	:= cAgencia
						SE1->E1_CONTA	:= cConta
						SE1->E1_HIST    := cHistor
						SE1->E1_DTACRED := CTOD("")
						If !Empty(dRedep)
							SE1->E1_VENCREA	:= Datavalida(dRedep)
							SE1->E1_VENCTO 	:= SE1->E1_VENCREA
						Endif
						MsUnlock()
						cPadrao	:=	"547"
					EndIf
			
					SA1->(DbSetOrder(1))
					SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
			
					RecLock("SA1",.F.)
					SA1->A1_DTULCHQ   := dDataBase
					SA1->A1_CHQDEVO   := SA1->A1_CHQDEVO + 1
					MsUnLock()
					If ExistBlock("FA089001")
						ExecBlock("FA089001",.F.,.F.)
					Endif
			
					// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					// ³  SI ES LA PRIMER BAJA DE LA SERIE DE BAJAS, CHEQUEO SI EXISTE EL      ³
					// ³  ASIENTO PADRONIZADO Y GENERO EL ENCABEZADO DEL ASIENTO SI ES VERDAD  ³
					// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
					If lGeraLanc
						lLancPad70 	:= VerPadrao(cPadrao)
					Else
						lLancPad70	:= .F.
					EndIf
					If lPrim
						If lLancPad70 //.and. !__TTSInUse
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Posiciona numero do Lote para Lancamentos do Financeiro      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							dbSelectArea("SX5")
							dbSeek(xFilial()+"09FIN")
							cLoteCom:=IIF(Found(),Trim(X5_DESCRI),"FIN")
							nHdlPrv:=HeadProva( cLoteCom,;
							"FINA089",;
							Subs(cUsuario,7,6),;
							@cArquivo)
							If nHdlPrv <= 0
								Help(" ",1,"A100NOPROV")
							EndIf
						EndIf
						lPrim	:=	.F.
					Endif
			
					If nHdlPrv > 0 .and. lLancPad70 //.and. !__TTSInUse
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Genera Items de asiento Contab. para Baja de Cheques.    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lLancPad70
							SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
							nTotalLanc += DetProva( nHdlPrv,;
							cPadrao,;
							"FINA089",;
							cLoteCom,;
							@nLinha,;
							/*lExecuta*/,;
							/*cCriterio*/,;
							/*lRateio*/,;
							/*cChaveBusca*/,;
							/*aCT5*/,;
							/*lPosiciona*/,;
							@aFlagCTB,;
							/*aTabRecOri*/,;
							/*aDadosProva*/ )
							If cPadrao <> "547"
								Aadd(aRecsSe5,SE5->(Recno()))
							Endif
						Endif
					Endif
					SE1->(DbGoTo(nRecSE1))
				Endif
			
				PcoDetLan("000360","02","FINA089",.F.)//RECHAZAR
			
				DbSelectArea("TMP089")
				DbSkip()
			EndDo			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Genera Pie de asiento Contab. para Baja de Cheques.      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nHdlPrv > 0 .and. lLancPad70 //.and. !__TTSInUse
				RodaProva(	nHdlPrv,;
				nTotalLanc)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia para Lancamento Contabil, se gerado arquivo   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				n	:=	1
				lLanctOk := cA100Incl( cArquivo,;
				nHdlPrv,;
				3,;
				cLoteCom,;
				lDigita,;
				lAglutina,;
				/*cOnLine*/,;
				/*dData*/,;
				/*dReproc*/,;
				@aFlagCTB,;
				/*aDadosProva*/,;
				aDiario )
				aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

				If lLanctOk .And. Len(aREcsSe5) > 0 .AND. !lUsaFlag
					For nA:=1  to Len(aREcsSe5)
						SE5->(DbGoTo(aRecsSE5[nA]))

				oModel := FWLoadModel('FINM010') //Baixas a receber.
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
				oModel:Activate()
				//Atualiza o campo Identifica Lançamento;
				oFKA := oModel:GetModel('FKADETAIL')
				oFK1 := oModel:GetModel('FK1DETAIL') 
				If oFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
					oFK1:SetValue('FK1_MOEDA',SE5->E5_MOEDA)
					oFK1:SetValue( 'FK1_VENCTO',SE5->E5_VENCTO)
					oFK1:SetValue( "FK1_DATA", dDatabase)
					oFK1:SetValue( 'FK1_VALOR' ,SE5->E5_VALOR)							
					oFK1:SetValue(  'FK1_TPDOC' ,SE5->E5_TIPODOC)
					oFK1:SetValue( 'FK1_RECPAG',SE5->E5_RECPAG )
					oFK1:SetValue( 'FK1_MOTBX' ,SE5->E5_MOTBX)
					oFK1:SetValue( "FK1_LA", "S")
					//
					If oModel:VldData()
						oModel:CommitData()
					Else
						cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
						cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) 				 + ' - '
						cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])           	
						Help( ,,"FN89VL",,cLog, 1, 0 )
					EndIf	
				EndIf
				oModel:DeActivate()
				oModel:Destroy()
				oModel := nil
				oFKA := nil
				oFK1 := nil	
			Next
				EndIf
			Endif
		Endif
	Endif

	PcoFinLan("000360")

	If oTmpTable <> Nil   
		oTmpTable:Delete()  
		oTmpTable := Nil
	EndIf 
	DbSelectArea("SE1")
   
    If !lAutomato
		   Eval( bFiltraBrw )
	Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A089Canrec³ Autor ³ MARCELLO              ³ Data ³ 07/12/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cancelar o rechaco de titulos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA089                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A089CanRech(lAutomato)
	Local cTipDev		:=  ""
	Local cBordero		:=	Criavar("E1_NUMBOR"	)
	Local nRecSE1		:=	0
	Local cArqTrb		:=	""
	Local cCondicoes	:=	""
	Local cCondWhile	:=	""
	Local aCampos		:=	{}
	Local aTits			:=	{}
	Local aCamposShw	:=	{}
	Local cBanco		:=	Criavar("A6_COD"),cAgencia:="",cConta:=""
	Local oBanco
	Local oGet1,oGet2,oGet3,oGet4
	Local dRedep		:=	CTOD("")
	Local cDescBco		:=	""
	Local cTipCheques	:= ""
	Local cTipoDiv 		:= ""
	Local cCheques		:= IIF(Type('MVCHEQUES')=='C',MVCHEQUES,MVCHEQUE)
	Local aAreaSE5		:= {}
	Local cTipos		:=	MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVENVBCOR
	Local cChvSE1		:= ""
	Local cPadrao		:= ""
	Local nX			:= 0
	Local nH			:= 0
	Local nI			:= 0
	Local lFinRe	    := ExistBlock("89RECHAZO") // Anulacíon de Rechazo
	Local cLstDesc		:= FN022LSTCB(2)	//Lista das situacoes de cobranca (Descontada)
	Local cLstBcoNoDesc	:= FN022LSTCB(5)	//Lista das situacoes de cobranca (Em banco mas sem desconto)

	SetPrvt("CARQUIVO,NHDLPRV,NTOTALLANC,CLOTECOM,NLINHA,LCANCEL")
	SetPrvt("CCLIENTE,CLOJA,DDATADE,DDATAATE")
	SetPrvt("NINDEX1,NINDEX,NTOTSEL,CMARCAE1,ACAMPOS")
	SetPrvt("N,NCONFIRMO,LPRIM,ARECSSE5,LLANCPAD70,LLANCTOK")
	SetPrvt("NA,")
	//Definidos como Proivates para poder ser usados no ponto de entrada, a089canc
	Private cIndexKey	:= "E1_CLIENTE+E1_NUM"
	Private cMsg		:= STR0047 //"Cliente+Numero"
	Private nOpcao		:= 0
	Private nRadio 		:= 1  // Usado na Rotina do FINA590para excluir o Bordero
	Private cNumBor 	:= Criavar("E1_NUMBOR"	)   // Usado na Rotina do FINA590para excluir o Bordero
	Private aDiario		:= {}
	Private cCodDiario	:= ""
    Default lAutomato 	:= .F.  // Utilizada para el paso de scripts automatizados
	cTipos		:=	StrTran(cTipos,',','/')
	cTipos		:=	StrTran(cTipos,';','/')
	cTipos		:=	StrTran(cTipos,'|','/')
	cTipos		:=	StrTran(cTipos,'\','/')
	cArquivo	:= ""
	nHdlPrv		:= 1
	nTotalLanc	:= 0
	cLoteCom	:= ""
	cPadrao		:= "527"
	nLinha		:= 2
	lCancel		:= .T.
	cCliente	:= CriaVar("A1_COD")
	cLoja		:= CriaVar("A1_LOJA")
	dDataDe 	:= dDataBase
	dDataAte	:= dDataBase
	If !lAutomato
		DEFINE MSDialog oDlg1 FROM 65,0 To 205,386  Title OemToAnsi(STR0010)  PIXEL // "Par metros"
		@ 00,003 To 055,184 OF oDLG1 PIXEL
		@ 09,008 SAY OemToAnsi(STR0030)  OF oDLG1 PIXEL // "Cliente "
		@ 09,045 MSGet cCliente F3 "SA1" Picture "@!" Valid ExistCpo("SA1") OF oDLG1 PIXEL
		@ 09,108 SAY OemToAnsi(STR0031)  SIZE 40,10  OF oDLG1 PIXEL // "Sucursal"
		@ 09,136 MSGet cLoja  Picture "@!" Valid ExistCpo("SA1",cCliente+cLoja) OF oDLG1 PIXEL
		@ 25,008 SAY OemToAnsi(STR0013)  OF oDLG1 PIXEL // "Vencto. de "
		@ 25,045 MSGet dDataDe Picture "@!" SIZE 40,10 OF oDLG1 PIXEL
		@ 25,095 SAY OemToAnsi(STR0014)  SIZE 40,10 OF oDLG1 PIXEL // "Vencto. Hasta "
		@ 25,136 MSGet dDataAte Picture "@!" SIZE 40,10 OF oDLG1 PIXEL
		If cPaisLoc=="ARG"
			@ 41,008 SAY OemToAnsi(STR0046)   PIXEL Of oDlg1//"Bordero : "
			@ 41,045 MSGet cBordero 	Picture "@!" Valid .T. PIXEL Of oDlg1
		Endif
		DEFINE SBUTTON FROM 59,108 Type 1 Action (lCancel	:=	.F.,oDlg1:END()) ENABLE OF oDLG1 PIXEL
		DEFINE SBUTTON FROM 59,149 Type 2 Action (oDlg1:END()) ENABLE OF oDLG1 PIXEL
		
		Activate MSDialog oDlg1 CENTERED
    Else
		 If FindFunction("GetParAuto")
				aRetAuto 		:= GetParAuto("FINA089TESTCASE")
				cCliente 		:= aRetAuto[1]
				cLoja	 		:= aRetAuto[2]
				dDataDe			:= aRetAuto[3]
				dDataAte		:= aRetAuto[4]
				lGeraLanc		:= .F.
				lCancel 		:= .F.
				lInverte 		:= .F.
				lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/ )
				oTmpTable 		:= Nil
		 Endif
	 EndIf

	// Se Portugal, pega cod. Diario
	If UsaSeqCor()
		cCodDiario := CTBAVerDia()
	Endif

	If lCancel
		RETURN
	Endif
	aCampos	:=	{}
	aTits		:=	{}
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("E1_OK")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{" ",""})
	If cPaisLoc == "PAR"
		DbSeek("E1_NUMCHQ")
		Aadd(aCampos,{X3_CAMPO	,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
		AAdd(aTits,{X3Titulo(),X3_PICTURE})
	EndIf
	DbSeek("E1_TIPO")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_VALOR")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_BCOCHQ")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_AGECHQ")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_CTACHQ")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_PORTADO")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_NUM")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_MOEDA")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_VLCRUZ")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_CLIENTE")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_LOJA")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_VENCTO")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	Aadd(aCampos,{"RECSE1"		,"N"    ,14        ,0         })

	If lFinRe
		ExecBlock("89RECHAZO",.F.,.F.)
	EndIf

	#IFDEF TOP
		SE1->(DbSetOrder(2))
		cQuery:= "SELECT "
		For nX	:=	1	To	Len(aCampos) - 1
			cQuery	+=	aCampos[nX][1] + ","
		Next
		//Ver con quico ~!!!!!!!
		cQuery+= " R_E_C_N_O_  RECNO "
		cQuery+= " FROM " + RetSqlName("SE1")
		cQuery+= " WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
		cQuery+= " AND E1_CLIENTE =  '" + cCliente  + "' AND E1_LOJA =  '" + cLoja + "'"
		cQuery+= " AND E1_PREFIXO >= ' ' "
		cQuery+= " AND E1_NUM     >= ' ' "
		cQuery+= " AND E1_PARCELA >= ' ' AND ("
		cTipCheques := Substr(cCheques,1,3)
		For nH = 1 to Len(cCheques) Step 4
			cQuery += " E1_TIPO = '"+cTipCheques+"'"
			If nH+2 <> Len(cCheques)
				cQuery += " OR "
				cTipCheques := Substr(cCheques,nH+4,3)
			EndIf
		Next nH
		cQuery+= ")"
		If !Empty(MVPROVIS) .Or. !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .Or. !Empty(MVENVBCOR)
			cQuery += "   AND  E1_TIPO NOT IN "+FormatIn(cTipos,'/')
		Endif
	
		cQuery+= " AND D_E_L_E_T_ <> '*' "
		If !Empty(cBordero)
			cQuery	+= " AND E1_NUMBOR ='"+cBordero+"' "
		Endif
		cQuery+= " AND E1_SITUACA='0' AND E1_STATUS='R'"
		cQuery+= " AND E1_PORTADO <> '" +Space(lEN(SE1->E1_PORTADO))+"' "
		cQuery+= " AND E1_VENCREA BETWEEN '" + Dtos(dDataDe) + "' AND '" + dTos(dDataAte) + "'"
	
		If ExistBlock("A089CONDS")
			cQuery	+=	ExecBlock("A089CONDS",.F.,.F.,2)
		Endif
	
		cQuery+= " ORDER BY " + SQLORDER(SE1->(IndexKey()))
		cQuery:= ChangeQuery(cQuery)
		If !lAutomato
			MsAguarde({ | | MsProcTxt(STR0051),dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1TMP', .T., .T.) },STR0048,STR0049 ) //"Seleccionando registros en el Servidor... " //"Por favor aguarde"###"Seleccionando registros en el Servidor..."
		Else
			MsAguarde({ | | dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1TMP', .T., .T.) },STR0048,STR0049 ) //"Seleccionando registros en el Servidor... "###"Por favor aguarde"###"Seleccionando registros en el Servidor..."
		EndIf
		For ni := 1 to Len(aCampos)-1
			If aCampos[ni,2] != 'C'
				TCSetField('SE1TMP', aCampos[ni,1], aCampos[ni,2],aCampos[ni,3],aCampos[ni,4])
			Endif
		Next
		DbSelectArea("SE1TMP")
		cAliasTmp	:=	"SE1TMP"
		cCondicoes	:=	".T."
		cCondWhile	:=	"!EOF()"

	#ELSE

		cCondicoes	:= "E1_TIPO $ '"+cCheques +"' "
		cCondicoes	+= ".AND. !(E1_TIPO $ '"+MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVENVBCOR+"')" // Alteracao conforme BOPS 66.626
		cCondicoes	+= ".AND. DTOS(E1_VENCREA) >= '" + Dtos(dDataDe) + "' .AND. DTOS(E1_VENCREA) <= '" + dTos(dDataAte) + "'"
		cCondicoes 	+= ".AND. E1_PORTADO <> '" +Space(lEN(SE1->E1_PORTADO))+"' "
		If !Empty(cBordero)
			cCondicoes	+=	" .AND. E1_NUMBOR =='"+cBordero+"' "
		Endif
		cCondicoes += " .AND. E1_SITUACA=='0' .AND. E1_STATUS=='R'"
	
		If ExistBlock("A089CONDS")
			cCondicoes	+=	ExecBlock("A089CONDS",.F.,.F.,2)
		Endif
	
		cCondWhile	:=	 "!EOF() .AND. E1_CLIENTE == '" + cCliente + "' .AND. E1_LOJA == '"+ cLoja +"'"
		DbSelectArea("SE1")
		DbSetOrder(2)
		DbSeek(xFilial()+cCliente+cLoja)
		cAliasTmp	:=	"SE1"

	#ENDIF

	cMarcaE1	:=	GetMark()
	Processa( {|| a089CrTRB(cCondicoes,cCondWhile,cAliasTmp,aCampos,@cArqTrb,cMarcaE1,lInverte)})

	#IFDEF TOP
		DbSelectArea(cAliasTmp)
		DbCloseArea()
		SE1->(DbClearFilter())
	#ELSE
		nIndex := Retindex("SE1")
	#ENDIF

	DbSelectArea("TMP089")
	DbGoTop()

	If BOF() .and. EOF()
		HELP(" ",1,"NORECS")
		If oTmpTable <> Nil   
			oTmpTable:Delete()  
			oTmpTable := Nil
		EndIf 
		DbSelectArea("SE1")
        If !lAutomato
        	Eval( bFiltraBrw )
		EndIf
		Return
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Voy montar el RDSELECT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCamposShw  := {}
		//Carregar os campos a serem exibidos
		For nX   := 1  To Len(aTits)
			Aadd(aCamposShw,{aCampos[nX][1],"",aTits[nX][1],aTits[nX][2]})
		Next

		DbGoTop()
		n	:=	1
		//"Selecci¢n de t¡tulos recibidos","Cliente : ","   Sucursal : "
		If !lAutomato
			nConfirmo:=RdSelect("TMP089","E1_OK",,aCamposShw,OemToAnsi(STR0027),OemToAnsi(STR0035) + cCliente + OemToAnsi(STR0036)+cLoja ,,cMarcaE1,.F.,,,"FI089TO")
		Else 
            Replace TMP089->E1_OK With cMarcaE1      
            nConfirmo := 1
        Endif
		If nConfirmo <>1
			If oTmpTable <> Nil   
				oTmpTable:Delete()  
				oTmpTable := Nil
			EndIf 
			DbSelectArea("SE1")
			Eval( bFiltraBrw )
			Return
		Else
			DbSelectArea("SE1")
			DbSetOrder(2)
			DbSelectArea("SE5")
			aAreaSE5:=GetArea()
			DbSetOrder(7)
			DbSelectArea("TMP089")
			DbGoTop()
			lPrim := .T.

			PcoIniLan("000360")

			Do while !EOF()
				If E1_OK == cMarcaE1
					nConfirmo:=1
					// Atualizacao do SE1
					DbSelectArea("SE1")
					DbGoTo(TMP089->RECSE1)
					cTipDev := F089TipDev(SE1->E1_TIPO)
					If ( Empty(cTipDev) )
						If cPaisLoc$"URU|BOL"
							cTipoDiv := "CHR"
						ElseIf	cPaisLoc == "CHI"
							cTipoDiv := "CHP"
						Else
							cTipoDiv := "NDC"
						EndIf
					Else
						cTipoDiv := cTipDev
					Endif
					cChvSE1:=xfilial("SE1")+SE1->E1_CLIENTE+SE1->E1_LOJA+"DEV"+SE1->E1_NUM+SE1->E1_PARCELA+cTipoDiv
					If DbSeek(cChvSE1)
						If FaCanDelCr("SE1","")
							RecLock("SE1",.F.)
							SE1->(DbDelete())
							SE1->(MsUnlock())
						Else
							nConfirmo:=0
						Endif
					Endif
					If nConfirmo==1
						SE1->(DbGoTo(TMP089->RECSE1))
						RecLock("SE1",.F.)
						If !Empty(SE1->E1_NUMBOR) .And. SEA->(DbSeek(xFilial("SEA")+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
							SE1->E1_PORTADO := SEA->EA_PORTADO
							SE1->E1_AGEDEP	:= SEA->EA_AGEDEP
							SE1->E1_CONTA	:= SEA->EA_NUMCON
							SE1->E1_SITUACA	:= SEA->EA_SITUACA
						Else
							SE1->E1_SITUACA	:= "0"
							SE1->E1_PORTADO := ""
							SE1->E1_AGEDEP	:= ""
							SE1->E1_CONTA	:= ""
						Endif
						If !(SE1->E1_SITUACA $ cLstDesc)
							SE1->E1_BAIXA	:= Ctod("")
							SE1->E1_SALDO	:= SE1->E1_VALOR
						Endif
						SE1->E1_MOVIMEN	:= dDataBase
						SE1->E1_HIST	:= ""
						SE1->E1_STATUS	:= "A"
						MsUnlock()
						cChvSE1:=xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA
						If SE5->(DbSeek(cChvSE1))
							While SE5->E5_FILIAL+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR+SE5->E5_LOJA == cChvSE1
								If SE1->E1_SITUACA $ cLstDesc
									If SE5->E5_TIPODOC=="CB" .Or. (SE5->E5_TIPODOC=="BA" .And. SE5->E5_MOTBX=="DEV")
										If SE5->E5_TIPODOC=="CB"
											AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,dDataBase,SE5->E5_VALOR,"+")
										Endif
										If UsaSeqCor()
											AADD(aDiario,{"SE5",SE5->(recno()),cCodDiario,"E5_NODIA","E5_DIACTB"})
										Endif
									oModel := FWLoadModel('FINM010') //Baixas a receber.
										oModel:SetOperation(MODEL_OPERATION_UPDATE)
										oModel:Activate()
										oModel:SetValue('MASTER','E5_OPERACAO',3) //Exclui SE5.
										If oModel:VldData()
											oModel:CommitData()
										Else
											cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
											cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) 				 + ' - '
											cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])                   
											Help( ,,"M010VALID",,cLog, 1, 0 )              
										EndIf
									oModel:DeActivate()
									oModel:Destroy()
									oModel := nil
								Endif
								Else
									If UsaSeqCor()
										AADD(aDiario,{"SE5",SE5->(recno()),cCodDiario,"E5_NODIA","E5_DIACTB"})
									Endif

									//
									oModel := FWLoadModel('FINM010') //Baixas a receber.
									oModel:SetOperation(MODEL_OPERATION_UPDATE)
									oModel:Activate()
									oModel:SetValue('MASTER','E5_OPERACAO',3) //Exclui SE5.
									If oModel:VldData()
										oModel:CommitData()
									Else
										cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
										cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) 				 + ' - '
										cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])              
										Help( ,,"M010VALID",,cLog, 1, 0 )              
								EndIf
								oModel:DeActivate()
								oModel:Destroy()
								oModel := nil
									//
								Endif

								SE5->(DbSkip())
							Enddo
						Endif
						SA1->(DbSetOrder(1))
						SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
						RecLock("SA1",.F.)
						SA1->A1_CHQDEVO := SA1->A1_CHQDEVO - 1
						MsUnLock()
						// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						// ³  SI ES LA PRIMER BAJA DE LA SERIE DE BAJAS, CHEQUEO SI EXISTE EL      ³
						// ³  ASIENTO PADRONIZADO Y GENERO EL ENCABEZADO DEL ASIENTO SI ES VERDAD  ³
						// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lPrim
							If lGeraLanc
								lLancPad70 	:= VerPadrao(cPadrao)
							Else
								lLancPad70	:= .F.
							EndIf
							If lLancPad70 //.and. !__TTSInUse
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Posiciona numero do Lote para Lancamentos do Financeiro      ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								dbSelectArea("SX5")
								dbSeek(xFilial()+"09FIN")
								cLoteCom:=IIF(Found(),Trim(X5_DESCRI),"FIN")
								nHdlPrv:=HeadProva( cLoteCom,;
								"FINA089",;
								Subs(cUsuario,7,6),;
								@cArquivo)
								If nHdlPrv <= 0
									Help(" ",1,"A100NOPROV")
								EndIf
							EndIf
							lPrim	:=	.F.
						Endif

						If nHdlPrv > 0 .and. lLancPad70 //.and. !__TTSInUse
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Genera Items de asiento Contab. para Baja de Cheques.    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lLancPad70
								SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
								nTotalLanc += DetProva( nHdlPrv,;
								cPadrao,;
								"FINA089",;
								cLoteCom,;
								@nLinha,;
								/*lExecuta*/,;
								/*cCriterio*/,;
								/*lRateio*/,;
								/*cChaveBusca*/,;
								/*aCT5*/,;
								/*lPosiciona*/,;
								@aFlagCTB,;
								/*aTabRecOri*/,;
								/*aDadosProva*/ )
							Endif
						Endif
					Endif
				Endif

				PcoDetLan("000360","03","FINA089",.F.)//Cancelar Rechazo

				DbSelectArea("TMP089")
				TMP089->(DbSkip())
			Enddo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Genera Pie de asiento Contab. para Baja de Cheques.      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nHdlPrv > 0 .and. lLancPad70 //.and. !__TTSInUse
				RodaProva(	nHdlPrv,;
				nTotalLanc)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia para Lancamento Contabil, se gerado arquivo   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				n	:=	1
				lLanctOk := cA100Incl( cArquivo,;
				nHdlPrv,;
				3,;
				cLoteCom,;
				lDigita,;
				lAglutina,;
				/*cOnLine*/,;
				/*dData*/,;
				/*dReproc*/,;
				@aFlagCTB,;
				/*aDadosProva*/,;
				aDiario )
				aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
			Endif
			SE5->(RestArea(aAreaSE5))
		Endif
	Endif

	PcoFinLan("000360")

	If oTmpTable <> Nil   
		oTmpTable:Delete()  
		oTmpTable := Nil
	EndIf
	
	DbSelectArea("SE1")
	If !lAutomato
		Eval( bFiltraBrw )
	EndIf
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A089Refr   ³ Autor ³                      ³ Data ³ 11.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o status dos objetos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA089                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a089Refr(oGet1,oGet2,oGet3,oGet4,oBanco,cChave,nOpcao)
	Local lRet	:=	.T.
	If nOpcao == 1
		oGet1:Disable()
		oGet2:Disable()
		oGet3:Disable()
		oGet4:Disable()
	ElseIf nOpcao == 2
		oGet1:Enable()
		oGet2:Enable()
		oGet3:Enable()
		oGet4:Enable()
	ElseIf nOpcao == 3
		If SA6->(DbSeek(xFilial()+cChave))
			If Alltrim(SA6->A6_COD) $ GetMV("MV_CARTEIR")
				oBanco:SetText(SA6->A6_NOME)
				oBanco:Refresh()
			Else
				Help("",1,"CARTEIR")
				lRet	:=	.F.
			Endif
		Else
			oBanco:SetText("")
			oBanco:Refresh()
		Endif
	Endif
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A089Cancel³ Autor ³ BRUNO SOBIESKI        ³ Data ³ 30/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cancelar entrada de cheques.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fina089	                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Bruno Sobieski³23.09.99³Melhor³Atualizar saldo bancario.               ³±±
±±³Bruno Sobieski³01.10.99³Melhor³No cancelar cheques rechazados.         ³±±
±±³Bruno Sobieski³11.11.99³Melhor³Atualizar saldo duplicatas no SA1       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A089Cancel(lAutomato)        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
	Local cBordero		:= Criavar("E1_NUMBOR",.F.)
	Local cArqTrb	:=	""
	Local cCondicoes	:=	""
	Local cCondWhile	:=	""
	Local aCampos	:=	{}
	Local aTits  	:=	{}
	Local aCamposShw	:=	{}
	Local cBcoDe 	:= Space(TamSx3("A6_COD")[1])
	Local cBcoAte	:= Space(TamSx3("A6_COD")[1])
	Local dDataDe 		:= dDataBase
	Local dDataAte 	:= dDataBase
	Local dDataAcred	:= CTOD("")
	Local aOpcoes		:= {OemToAnsi(STR0065),OemToAnsi(STR0066)}  //"Revertir","Anular"
	Local oLBX
	Local aMotivos	:= {}
	Local aButtons	:= {}
	Local cOpcao		:=	aOpcoes[1]
	Local nOpcao		:=	1
	Local oCBX
	Local aDados		:=	{}
	Local aBorderos	:=	{}
	Local nPosBor		:=	0
	Local cTipCheques	:= ""
	Local nX			:= 0
	Local nI			:= 0
	Local nH			:= 0
	Local cTipos		:=	MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVENVBCOR
	Local cSeqFRF		:=""
	Local aAreaSEF
	Local cFiltroSEF    := ""
	Local nW:=0
	Local cNumPX
	Local nTotSX8
	Local nL
	local aAreaSEK		:=SEK->(getarea())
	/*
	notas de debito */
	Local oEspecieC
	Local cEspecieC		:= Criavar("F2_ESPECIE")
	Local oEspecieF
	Local cEspecieF		:= Criavar("F1_ESPECIE")
	Local cLoja			:= ""
	Local cCLieFor		:= ""
	Local aNDsC			:= {{"NDC","",2},{"NCE","",3}}
	Local aNDsF			:= {{"NDP","",9},{"NCI","",8}}
	Local aRegSEF		:= {}
	Local aRegSEFOP		:= {}
	Local aRegND		:= {}
	Local nTipoNDC		:= 0
	Local nTipoNDF		:= 0
	Local aEspeciesC	:= {}
	Local aEspeciesF	:= {}
	Local lPerg			:= .T.
	Local aDadosCanc	:= {}
	Local nCanc			:= 0
	Local cFilSA1		:= XFILIAL("SA1")
	Local cFilSA6		:= XFILIAL("SA6")
	Local cFilSE1		:= XFILIAL("SE1")
	Local cFilSE5		:= XFILIAL("SE5")
	Local cFilSEF		:= XFILIAL("SEF")
	Local cNumOrdPag	:= ""
	Local cRelOrdPag	:= ""
	Local lVldImpFor	:= .F.
	Local cLstDesc		:= FN022LSTCB(2)	//Lista das situacoes de cobranca (Descontada)
	Local cLstBcoNoDesc	:= FN022LSTCB(5)	//Lista das situacoes de cobranca (Em banco mas sem desconto)
	Local aCamposFK5 := FINLisCpo('FK5')
	Local nPos := 0
	Local oModel 
	Local oFK1
	Local oFKA 
	Local oFK5
	Local cLog := ""
Local cCamposE5:=""
	Local lVldAnuChq	:= .T.
	Local cMvparAnt := ""
	/*-*/
	Private cNumNota	:= ""
	Private cSerNota	:= ""
	Private cEspNota	:= ""
	/*-*/
	Private lMsErroAuto := .F.
	Private aDiario := {}
	Private cCodDiario:= ""
	Private cFilCxCtr :=Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR")+"/"+IsCxLoja()
	Private nChvLbx		:=	0
	Private cChvLbx		:=	""
	Private cLocxNFPV	:= ""
	cTipos	:=	StrTran(cTipos,',','/')
	cTipos	:=	StrTran(cTipos,';','/')
	cTipos	:=	StrTran(cTipos,'|','/')
	cTipos	:=	StrTran(cTipos,'\','/')
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetPrvt("LLANCE,LLANCPAD70,CARQUIVO,NHDLPRV,NTOTALLANC,CLOTECOM")
	SetPrvt("NLINHA,LCANCEL,CBCODE,CBCOATE,DDATADE,DDATAATE")
	SetPrvt("NREC,NINDEX1,NINDEX,NTOTSEL,CMARCAE1")
	SetPrvt("ACAMPOS,N,NCONFIRMO,LPRIM,")
	SetPrvt("CBCOFJN,CAGEFJN,CPOSFJN,CPOSTAL")

	//Definidos como Proivates para poder ser usados no ponto de entrada, a089canc
	Private cIndexKey	:=	"E1_CLIENTE+E1_NUM"
	Private cMsg   	:=	STR0047 //"Cliente+Numero"
	Private cHistor	:=	STR0067 //"Acred. Anulada"

    Default lAutomato := .F.  // Utilizada para el paso de scripts automatizados

	lLance		:=	.F.
	lLancPad70	:=	.F.
	cArquivo 	:= ""
	nHdlPrv 		:= 0
	nTotalLanc 	:= 0
	cLoteCom 	:= ""
	nLinha 		:= 2
	lCancel		:=	.T.

	If FunName()="FINA096"
		cBcoDe 	:= cBco380
		cBcoAte	:= cBco380
		dDataDe 	:= dIniDt380
		dDataAte := dFimDt380
		cBordero	:= If(ValType(cBord380) == "C", cBord380, cBordero)
	If cPaisLoc $ "ARG"
		If ValType(lExecute)=="L"
			lExecute	:= .F.
		EndIf
	EndIf	
		SX5->(DbSeek(xFilial("SX5")+"G0"))
		While !SX5->(Eof()) .and. SX5->X5_FILIAL==xFilial("SX5") .and. SX5->X5_TABELA=="G0"
			Aadd(aMotivos,Trim(SX5->X5_CHAVE)+" - "+Capital(Trim(X5Descri())))
			SX5->(DbSkip())
		Enddo
		/*
		verifica a descricao das notas de debito*/
		If !(cPaisLoc == "BRA")
			aEspeciesC := {}
			For nL := 1 To Len(aNDsC)
				If SX5->(DbSeek(xFilial("SX5") + "42" + PadR(aNDsC[nL,1],Len(SX5->X5_CHAVE))))
					aNDsC[nL,2] := AllTrim(Lower(X5Descri()))
					Aadd(aEspeciesC,AllTrim(aNDsC[nL,1]) + "=" + aNDsC[nL,2])
				Endif
			Next
			aEspeciesF := {}
			For nL := 1 To Len(aNDsC)
				If SX5->(DbSeek(xFilial("SX5") + "42" + PadR(aNDsF[nL,1],Len(SX5->X5_CHAVE))))
					aNDsF[nL,2] := AllTrim(Lower(X5Descri()))
					Aadd(aEspeciesF,AllTrim(aNDsF[nL,1]) + "=" + aNDsF[nL,2])
				Endif
			Next
		Endif
	Endif
	SA1->(DbSetOrder(1))
	SA6->(DbSetOrder(1))

	nRec	:=	SE1->(Recno())

	If !(cPaisLoc <> "BRA" .AND. FUNNAME()=="FINA096")
	 	If !lAutomato
			DEFINE MSDialog oDlg1 FROM 65,0 To 240,386  Title OemToAnsi(STR0010) PIXEL // "Par metros"
			@ 00,003 To 72,184 PIXEL Of oDlg1
			@ 09,008 SAY OemToAnsi(STR0011)  PIXEL Of oDlg1// "Banco de "
			@ 09,045 MSGet oGet1	VAR cBcoDe   	F3 "BCO" Picture "@!"	Valid EXISTCPO("SA6",cBcoDe,1) .AND. If(cPaisLoc=="PER",If(!cBcoDe $ cFilCxCtr ,.T.,Eval({||MsgAlert(STR0087),.F.})),.T.) PIXEL Of oDlg1
			@ 09,095 SAY OemToAnsi(STR0012)   SIZE 40,10 PIXEL Of oDlg1// "Banco Hasta "
			@ 09,136 MSGet oGet2 VAR cBcoAte  	F3 "BCO" Picture "@!"  	Valid EXISTCPO("SA6",cBcoAte,1) .AND. If(cPaisLoc=="PER",If(!cBcoAte $ cFilCxCtr ,.T.,Eval({||MsgAlert(STR0087),.F.})),.T.) SIZE 40,10 PIXEL Of oDlg1
			@ 25,008 SAY OemToAnsi(STR0013)   PIXEL Of oDlg1// "Vencto. de "
			@ 25,045 MSGet oGet3 VAR dDataDe  	Picture "@!" SIZE 40,10  PIXEL Of oDlg1
			@ 25,095 SAY OemToAnsi(STR0014)   SIZE 40,10 PIXEL Of oDlg1// "Vencto. Hasta "
			@ 25,136 MSGet oGet4 VAR dDataAte 	Picture "@!" SIZE 40,10  PIXEL Of oDlg1
			@ 41,008 SAY OemToAnsi(STR0046)   PIXEL Of oDlg1//"Bordero : "
			@ 41,045 MSGet cBordero 	Picture "@!" Valid If(cPaisLoc$"URU|BOL",a089Refr(@oGet1,@oGet2,@oGet3,@oGet4,,,If(Empty(cBordero),2,1)),.T.) PIXEL Of oDlg1
			@ 41,095 SAY OemToAnsi(STR0057) PIXEL Of oDlg1 //"Acreditado "
			@ 41,136 MSGet dDataAcred	Picture "@!" SIZE 40,10  PIXEL Of oDlg1
			@ 57,008 SAY OemToAnsi(STR0068) PIXEL SIZE 80,10 Of oDlg1  //"Tratamiento del movimiento"
			@ 57,095 COMBOBOX oCBX VAR cOpcao ITEMS aOpcoes  SIZE 50,50 OF oDlg1 PIXEL
			DEFINE SBUTTON FROM 75,108 Type 1 Action (lCancel	:=	.F., nOpcao :=	oCBX:nAt, oDlg1:END()) PIXEL ENABLE Of oDlg1
			DEFINE SBUTTON FROM 75,149 Type 2 Action (oDlg1:End()) PIXEL ENABLE Of oDlg1
			Activate MSDialog oDlg1 CENTERED
	   Else
		  If FindFunction("GetParAuto")
				aRetAuto 		:= GetParAuto("FINA089TESTCASE")
				cBcoDe 			:= aRetAuto[1]
				cBcoAte 		:= aRetAuto[2]
				dDataDe			:= aRetAuto[3]
				dDataAte		:= aRetAuto[4]
				dDataAcred		:= aRetAuto[5]
				lCancel 		:= .F.
				lInverte 		:= .F.
				lGeraLanc		:= .F.
				lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/ )
				oTmpTable 		:= Nil
		  Endif
	   Endif

		// Se Portugal, pega cod. Diario
		If UsaSeqCor()
			cCodDiario := CTBAVerDia()
		Endif

		If lCancel
			RETURN
		Endif

	Endif


	aCampos	:=	{}
	aTits		:=	{}
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("E1_OK")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{" ",""})
	If cPaisLoc == "PAR"
		DbSeek("E1_NUMCHQ")
		Aadd(aCampos,{X3_CAMPO	,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
		AAdd(aTits,{X3Titulo(),X3_PICTURE})
	EndIf
	DbSeek("E1_TIPO")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_VALOR")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_BCOCHQ")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_AGECHQ")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_CTACHQ")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_PORTADO")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_NUM")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_MOEDA")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_VLCRUZ")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_CLIENTE")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_LOJA")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_VENCTO")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})
	DbSeek("E1_SALDO")
	Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
	AAdd(aTits,{X3Titulo(),X3_PICTURE})

	If !(cPaisLoc == "BRA") .AND. FUNNAME()=="FINA096"

		DbSeek("E1_PREFIXO")
		Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
		AAdd(aTits,{X3Titulo(),X3_PICTURE})

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Requisito de Entidades Bancarias - Junho de 2012 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If dbSeek( "E1_POSTAL" )
			Aadd(aCampos,{X3_CAMPO		,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
			AAdd(aTits,{X3Titulo(),X3_PICTURE})
		EndIf

	Endif
	If ExistBlock("A089CAMP")
		Execblock("A089CAMP",.F.,.F.,3)
	Endif
	If !(cPaisLoc == "BRA") .and. FUNNAME()=="FINA096"
		AAdd(aTits,{"Dev.Forn","@!"})
		Aadd(aCampos,{"lCancelOP"		,"C"    ,1        ,0         })
	Endif
	Aadd(aCampos,{"RECSE1"		,"N"    ,14        ,0         })

	#IFDEF TOP

		SE1->(DbSetOrder(IIf(Empty(cBordero),7,5)))
		cQuery:= "SELECT "
		If !(cPaisLoc == "BRA") .and. FUNNAME()=="FINA096"
			For nX	:=	1	To	Len(aCampos) - 2
				cQuery	+=	aCampos[nX][1] + ","
			Next
		Else
			For nX	:=	1	To	Len(aCampos) - 1
				cQuery	+=	aCampos[nX][1] + ","
			Next
		Endif
		//Ver con quico ~!!!!!!!
		cQuery+= " R_E_C_N_O_  RECNO "
		cQuery+= " FROM " + RetSqlName("SE1")
		cQuery+= " WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
		//Estas condicoes sao colocadas para que o forcar o banco pegar o Indice 7
		//que sera sempre mas favoravel na performance da query  que o indice 4
		//pois o intervalo entre datas geralmente sera menor que o intervalo
		//entre portador.
		//Bruno.
		If Empty(cBordero)
			cQuery += " AND E1_VENCREA BETWEEN '" + Dtos(dDataDe) + "' AND '" + dTos(dDataAte) + "'"
		Else
			cQuery += " AND E1_NUMBOR  = '" +cBordero+"'"
			If !cPaisLoc$"URU|BOL"
				cQuery += " AND E1_VENCREA BETWEEN '" + Dtos(dDataDe) + "' AND '" + dTos(dDataAte) + "'"
			Endif
		Endif
		cQuery+= " AND E1_NOMCLI  >= ' ' "
		cQuery+= " AND E1_PREFIXO >= ' ' "
		If !(cPaisLoc $ "ARG|DOM|EQU")  .or. cPaisLoc $ "ARG|DOM|EQU" .and. FUNNAME()<>"FINA096"
			cQuery+= " AND E1_SALDO = 0 "
		Endif
		cQuery+= " AND E1_NUM     >= ' ' AND ("
		cTipCheques := Substr(MVCHEQUES,1,3)
		For nH = 1 to Len(MVCHEQUES) Step 4
			cQuery += " E1_TIPO = '"+cTipCheques+"'"
			If nH+2 <> Len(MVCHEQUES)
				cQuery += " OR "
				cTipCheques := Substr(MVCHEQUES,nH+4,3)
			EndIf
		Next nH
		cQuery+= ")"
		If !Empty(MVPROVIS) .Or. !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .Or. !Empty(MVENVBCOR)
			cQuery += "   AND  E1_TIPO NOT IN "+FormatIn(cTipos,'/')
		Endif
		cQuery+= " AND E1_PARCELA >= ' ' "
		If !Empty(dDataAcred) .And. !cPaisLoc$"URU|BOL"
			cQuery+=	" AND E1_BAIXA = '"+DTOS(dDataAcred)+"'"
		EndIf
		If !cPaisLoc$"URU|BOL"
			If EMPTY(cBcoDe+cBcoAte)
				cQuery+= " AND E1_PORTADO BETWEEN '" + Space(TamSX3('E1_PORTADOR')[1]) + "' AND '" + PADR( "Z", 30, "Z") + "'"
			Else
				cQuery+= " AND E1_PORTADO BETWEEN '" + cBcoDe + "' AND '" + cBcoAte + "'"
			EndIf
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Expressao de Filtro para Entidades Bancarias - Junho de 2012 ³
		//³ Variaveis declaradas em FINA096 - Cheques Recebidos          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If !(cPaisLoc == "BRA")
         If Empty( cBcoFJN )
            If !Empty( cPostal )
	          cQuery += " AND E1_POSTAL = '" + cPosFJN + "'"
            EndIf
         Else
		     cQuery += " AND E1_BCOCHQ = '" + cBcoFJN + "'"
		     cQuery += " AND E1_AGECHQ = '" + cAgeFJN + "' "
         EndIf
      EndIf
	
		cQuery+= " AND E1_BAIXA   <= '" +DTOS(dDataBase)+"'"
		cQuery+= " AND E1_PORTADO <> '" +Space(lEN(SE1->E1_PORTADO))+"' "
		cQuery+= " AND E1_STATUS <>'R'"
		cQuery+= " AND D_E_L_E_T_ <> '*' "
		If ExistBlock("A089CONDS")
			cQuery	+=	ExecBlock("A089CONDS",.F.,.F.,3)
		Endif
	
		cQuery+= " ORDER BY " + SQLORDER(SE1->(IndexKey()))
		cQuery:= ChangeQuery(cQuery)
	  If !lAutomato
	     MsAguarde({ | | MsProcTxt(STR0051),dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1TMP', .T., .T.) },STR0048,STR0049 ) //"Seleccionando registros en el Servidor... "###"Por favor aguarde"###"Seleccionando registros en el Servidor..."
	  Else
		 MsAguarde({ | | dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1TMP', .T., .T.) },STR0048,STR0049 ) //"Seleccionando registros en el Servidor... "###"Por favor aguarde"###"Seleccionando registros en el Servidor..."
	  Endif
		If !(cPaisLoc == "BRA") .and. FUNNAME()=="FINA096"
			For ni := 1 to Len(aCampos)-2
				If aCampos[ni,2] != 'C'
					TCSetField('SE1TMP', aCampos[ni,1], aCampos[ni,2],aCampos[ni,3],aCampos[ni,4])
				Endif
			Next
		Else
			For ni := 1 to Len(aCampos)-1
				If aCampos[ni,2] != 'C'
					TCSetField('SE1TMP', aCampos[ni,1], aCampos[ni,2],aCampos[ni,3],aCampos[ni,4])
				Endif
			Next
		Endif
		DbSelectArea("SE1TMP")
		cAliasTmp	:=	"SE1TMP"
		If !(cPaisLoc == "BRA") .AND. FUNNAME()=="FINA096"
	  	cCondicoes	:= "A096ConSEF((xFilial('SEF')+'R'+SE1->E1_BCOCHQ+SE1->E1_AGECHQ+SE1->E1_CTACHQ+Padr(SUBSTR(SE1->E1_NUM,1,Len(SEF->EF_NUM)),len(SEF->EF_NUM),' ')+SE1->E1_PREFIXO),6,2)"
		Else
			cCondicoes	:=	".T."
		Endif
		cCondWhile	:=	"!EOF()"
	#ELSE
		cCondicoes	:= "E1_TIPO $ '"+MVCHEQUES +"' .AND. !(E1_TIPO $ '"+MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVENVBCOR+"') .AND. E1_SALDO == 0  .And. E1_PORTADO >= '" + cBcoDe + "'.And. E1_PORTADO <= '" + cBcoAte + "'"
		cCondicoes	+=	".AND. E1_PORTADO <> '" +Space(lEN(SE1->E1_PORTADO))+"'"
		cCondicoes	+= ".And. DTOS(E1_BAIXA) <= '"+DTOS(dDataBase)+"'"
		cCondicoes	+= ".And. E1_STATUS <> 'R' "
		If !Empty(dDataAcred)
			cCondicoes	+= ".And. DTOS(E1_BAIXA) == '"+DTOS(dDataAcred)+"'"
		Endif
		//Ponto de entrada para modificar as condicoes
		If ExistBlock("A089CONDS")
			cCondicoes	+=	ExecBlock("A089CONDS",.F.,.F.,3)
		Endif
		If !Empty(cBordero)
			DbSelectArea("SE1")
			DbSetOrder(5)
			DbSeek(xFilial()+cBordero)
			cCondWhile	:=	"!EOF() .And. E1_FILIAL=='"+xFilial("SE1")+ "'.And. E1_NUMBOR=='"+cBordero+"'"
		Else
			DbSelectArea("SE1")
			DbSetOrder(7)
			DbSeek(xFilial()+dTOS(dDataDe),.T.)
			cCondWhile	:=	"!EOF() .AND. E1_FILIAL=='"+xFilial("SE1")+"'.And. DTOS(E1_VENCTO) <= '" + dTos(dDataAte) + "'"
		Endif
		cAliasTmp	:=	"SE1"
	#ENDIF

	cMarcaE1	:=	GetMark()
	Processa( {|| a089CrTRB(cCondicoes,cCondWhile,cAliasTmp,aCampos,@cArqTrb,cMarcaE1,lInverte) })

	#IFDEF TOP
		DbSelectArea(cAliasTmp)
		DbCloseArea()
	#ELSE
		nIndex := Retindex("SE1")
	#ENDIF
	DbSelectArea("TMP089")
	DbGoTop()                          
	If BOF() .and. EOF()
		HELP(" ",1,"NORECS")
		
		If oTmpTable <> Nil   
			oTmpTable:Delete()  
			oTmpTable := Nil
		EndIf 
		DbSelectArea("SE1")
		If !lAutomato
			Eval( bFiltraBrw )
		Endif
		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Voy montar el RDSELECT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCamposShw  := {}
	//Carregar os campos a serem exibidos
	For nX   := 1  To Len(aTits)
		Aadd(aCamposShw,{aCampos[nX][1],"",aTits[nX][1],aTits[nX][2]})
	Next

	DbGoTop()
	n	:=	1
	//"Selecci¢n de t¡tulos recibidos"
	If FUNNAME()=="FINA096"
		aAdd(aButtons,{"Pesquisa",{|| F096Busca("TMP089",cArqTrb,cIndexKey)},STR0004,STR0004})
	
		If ExistBlock("FA89BUTA")
			aButtons :=ExecBlock("FA89BUTA",.F.,.F.,{aButtons})
		EndIf
	
	EndIf
	
	If cPaisLoc=="ARG"
		nConfirmo:=FA096RdSel("TMP089","E1_OK",,aCamposShw,OemToAnsi(STR0027) ,STR0058 + cMsg,,cMarcaE1,.F.,,,"FI089TO",aButtons) //" .  Ordenado Por : "
	Else
	  If !lAutomato
		nConfirmo:=RdSelect("TMP089","E1_OK",,aCamposShw,OemToAnsi(STR0027) ,STR0058 + cMsg,,cMarcaE1,.F.,,,"FI089TO",aButtons) //" .  Ordenado Por : "
	  Else
	     Replace TMP089->E1_OK With cMarcaE1      
         nConfirmo := 1
	  Endif
	Endif
	If nConfirmo <> 1
		If oTmpTable <> Nil   
			oTmpTable:Delete()  
			oTmpTable := Nil
		EndIf 
		DbSelectArea("SE1")

		Eval( bFiltraBrw )
		Return
	Endif

	DbSelectArea("TMP089")
	TMP089->(DbGoTop())
	lPrim	:=	.T.

	If FUNNAME()=="FINA096"
		If !(cPaisLoc == "BRA")
			nTipoNDC := aNDsC[1,3]
			nTipoNDF := aNDsF[1,3]
			DEFINE MSDialog oDlg1 FROM 65,0 To 350,420  Title OemToAnsi(STR0010) PIXEL // "Par metros"
			@009,008 SAY "Motivo: " PIXEL SIZE 80,10 Of oDlg1  //Motivo
			@009,051 LISTBOX oLBX VAR nChvLbx ITEMS aMotivos  SIZE 150,60 OF oDlg1 PIXEL
			oLBX:bChange := {|| cChvLbx := Substr(aMotivos[nChvLbx],1,2)}
			@80,008 SAY "ND cliente" PIXEL SIZE 80,10 Of oDlg1
			@80,051 COMBOBOX oEspecieC VAR cEspecieC ITEMS aEspeciesC SIZE 150,60 OF oDlg1 PIXEL ON CHANGE (nTipoNDC := aNDsC[oEspecieC:nAt,3])
			@96,008 SAY "ND fornecedor" PIXEL SIZE 80,10 Of oDlg1
			@96,051 COMBOBOX oEspecieF VAR cEspecieF ITEMS aEspeciesF SIZE 150,60 OF oDlg1 PIXEL ON CHANGE (nTipoNDF := aNDsF[oEspecieF:nAt,3])
			DEFINE SBUTTON FROM 115,108 Type 1  Action (lCancel	:=	.F., Eval({||cChvLbx:= Substr(aMotivos[oLBX:nAt],1,2), nChvLbx:=oLBX:nAt}), nOpcao := 2, oDlg1:END()) PIXEL ENABLE Of oDlg1
			DEFINE SBUTTON FROM 115,149 Type 2 Action (oDlg1:End()) PIXEL ENABLE Of oDlg1
			Activate MSDialog oDlg1 CENTERED
		Else
			DEFINE MSDialog oDlg1 FROM 65,0 To 240,386  Title OemToAnsi(STR0010) PIXEL // "Par metros"
			@ 09,008 SAY STR0008 + ": " PIXEL SIZE 80,10 Of oDlg1  //Motivo
			@ 09,026 LISTBOX oLBX VAR nChvLbx ITEMS aMotivos  SIZE 150,60 OF oDlg1 PIXEL
			oLBX:bChange:={|| cChvLbx:=Substr(aMotivos[nChvLbx],1,2)}
			DEFINE SBUTTON FROM 75,108 Type 1  Action (lCancel	:=	.F., Eval({||cChvLbx:= Substr(aMotivos[oLBX:nAt],1,2), nChvLbx:=oLBX:nAt}), nOpcao := 2, oDlg1:END()) PIXEL ENABLE Of oDlg1
			DEFINE SBUTTON FROM 75,149 Type 2 Action (oDlg1:End()) PIXEL ENABLE Of oDlg1
			Activate MSDialog oDlg1 CENTERED
		Endif

		/*
		Ajuste na validação de anulação de cheques, permitindo anular os mesmos desde que informados os motivos 12(Devolución definitiva)/97( Cheque sustituido).
		*/
		If cChvLbx == '11'
			lVldAnuChq := .F.
		ElseIf cChvLbx == '12'
			lVldAnuChq := .F.
		ElseIf cChvLbx == '97'
			lVldAnuChq := .F. 
		EndIf


		If lVldAnuChq .Or. cChvLbx == '11' //Tipo onze pode ser anulado porem não pode ter OP vinculado
			Do While TMP089->(!EOF())
				If  TMP089->E1_OK == cMarcaE1
					DbSelectArea("SEF")
					SEF->(DbSetOrder(1))
					If SEF->(DbSeek(xFilial("SEF") + TMP089->E1_BCOCHQ + TMP089->E1_AGECHQ + TMP089->E1_CTACHQ + TMP089->E1_NUM))
						If cPaisLoc $ "ARG" .And. !Empty(SEF->EF_ORDPAGO) //Não permitir a anulação de um cheque caso o mesmo tenha uma ordem de pago vinculado
							MSGALERT( STR0095 + ' ' + Alltrim (SEF->EF_NUM) + ' ' + STR0096 + ' ' + SEF->EF_ORDPAGO)
							Return
						EndIf
					EndIf
				EndIf
				TMP089->(DbSkip())
			EndDo
			TMP089->(DbGoTop())
		EndIf

		// Se Portugal, pega cod. Diario
		If  UsaSeqCor()
			cCodDiario := CTBAVerDia()
		Endif

		If lCancel
			RETURN
		Endif
	EndIf

Begin Transaction
		PcoIniLan("000360")

		Do while TMP089->(!EOF())
			//Pois o lInverte nao e compativel com a RDSELECT a
			If  TMP089->E1_OK == cMarcaE1 .and. ((cPaisLoc == "ARG" .AND. FUNNAME()=="FINA089").OR. ((cPaisLoc <> "ARG" .And. !(FunName() == "FINA096")) .or. TMP089->E1_OK == cMarcaE1 .and. cPaisLoc <> "BRA" .and. FUNNAME()=="FINA096" .and. TMP089->LCANCELOP<>"R"))
				DbSelectArea("SE1")
				SE1->(DbGoTo(TMP089->RECSE1))

				If cPaisLoc == "ARG" .AND. FUNNAME()=="FINA089".OR. (cPaisLoc <> "ARG" .And. !(FunName() == "FINA096")) .or. cPaisLoc <> "BRA" .and. Empty(TMP089->LCANCELOP) .and. cChvLbx $ "11|97"
					RecLock("SE1",.F.)
					SE1->E1_BAIXA	:= CToD("")
					SE1->E1_SALDO	:= SE1->E1_VALOR
					SE1->E1_STATUS	:= "A"
					SE1->E1_MOVIMEN	:= dDataBase
					SE1->(MsUnlock())
				EndIf

				If !(cPaisLoc == "BRA") .And. (FUNNAME() == "FINA096" .OR. FUNNAME()=="FINA089")
					aDadosCanc  := {}
					AADD(aDadosCanc,{SE1->(E1_BCOCHQ+E1_AGECHQ+E1_CTACHQ) ,SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)})
				EndIf

				SA1->(DbSetOrder(1))
				SA1->(DbSeek(cFilSA1+SE1->E1_CLIENTE+SE1->E1_LOJA))

				AtuSalDup("+",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,,SE1->E1_EMISSAO)
				SA1->(RecLock("SA1",.F.))
				SA1->A1_MSALDO :=Iif(SA1->A1_SALDUPM>SA1->A1_MSALDO,SA1->A1_SALDUPM,SA1->A1_MSALDO)

				nValForte := ConvMoeda(SE1->E1_EMISSAO,SE1->E1_VENCTO,Moeda(SE1->E1_VALOR,1,"R"),;
				Iif(SA1->A1_MOEDALC > 0,AllTrim(STR(SA1->A1_MOEDALC)),GetMv("MV_MCUSTO")))

				If ( nValForte > SA1->A1_MAIDUPL )
					SA1->A1_MAIDUPL := nValForte
				EndIf
				SA1->(MsUnLock())

				If FUNNAME()=="FINA089" .OR. (!(cPaisLoc == "BRA") .and. Empty(TMP089->LCANCELOP))
					DbSelectArea("SE5")
					SE5->(DbSetOrder(7))
					If SE5->(DbSeek(cFilSE5+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA))
						While SE5->(!EOF()) .And. cFilSE5+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA ==;
						SE5->E5_FILIAL+SE5->E5_PREFIXO+SE5->E5_NUMero+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR +SE5->E5_LOJA
							If SE5->E5_SITUACA <> "C" .And. SE5->E5_TIPODOC $ "BA|VL"
								Exit
							Endif
							SE5->(DbSkip())
							Loop
						EndDo
						If SE5->(EOF()) .OR. cFilSE5+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA <>;
						SE5->E5_FILIAL+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR +SE5->E5_LOJA
							DbSelectArea("TMP089")
							dBSkip()
							Loop
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//|Si fue contabilizado On-Line, genero el registro de Contabiliacion del ³
						//³cancelamiento de la baja                                               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (Alltrim(SE5->E5_LA)=="S" .And. nOpcao == 2) .Or. lGeraLanc
							lLance	:=	.T.
							// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							// ³  SI ES LA PRIMER BAJA DE LA SERIE DE BAJAS, CHEQUEO SI EXISTE EL      ³
							// ³  ASIENTO PADRONIZADO Y GENERO EL ENCABEZADO DEL ASIENTO SI ES VERDAD  ³
							// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

							If lGeraLanc
								lLancPad70 	:= VerPadrao("527")
							Else
								lLancPad70	:= .F.
							EndIf
							If lPrim
								If lLancPad70 //.and. !__TTSInUse
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Posiciona numero do Lote para Lancamentos do Financeiro      ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									dbSelectArea("SX5")
									dbSeek(xFilial()+"09FIN")
									cLoteCom:=IIF(Found(),Trim(X5_DESCRI),"FIN")
									nHdlPrv:=HeadProva( cLoteCom,;
									"FINA089",;
									Subs(cUsuario,7,6),;
									@cArquivo)
									If nHdlPrv <= 0
										Help(" ",1,"A100NOPROV")
									EndIf
								EndIf
								lPrim	:=	.F.
							Endif
							If nHdlPrv > 0 .and. lLancPad70 //.and. !__TTSInUse
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Genera Items de asiento Contab. para Baja de Cheques.    ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lLancPad70
									SA1->(DbSeek(cFilSA1+SE1->E1_CLIENTE+SE1->E1_LOJA))
									SA6->(DbSeek(cFilSA6+SE1->E1_PORTADOR+SE1->E1_AGEDEP+SE1->E1_CONTA))
									nTotalLanc += DetProva( nHdlPrv,;
									"527",;
									"FINA089",;
									cLoteCom,;
									@nLinha,;
									/*lExecuta*/,;
									/*cCriterio*/,;
							/*lRateioadmin	*/,;
									/*cChaveBusca*/,;
									/*aCT5*/,;
									/*lPosiciona*/,;
									@aFlagCTB,;
									/*aTabRecOri*/,;
									/*aDadosProva*/ )
								Endif
							Endif
						Endif

						PcoDetLan("000360","04","FINA089",.F.)//Cancelar entrada de cheque

						If !(SE1->E1_SITUACA $ clstDesc)
							SA6->(DbSeek(cFilSA6+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA))
							AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,IIf(nOpcao==1,dDataBase,SE5->E5_DATA),SE5->E5_VALOR,"-")
					If SE5->E5_TIPODOC == "BA" .And. !Empty(SE1->E1_NUMBOR)
						nPosBor	:=	AScan(aBorderos,{|X| x[4] == SE1->E1_NUMBOR })
						If nPosBor	== 0
							AAdd(aBorderos,{SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE1->E1_NUMBOR,SE5->E5_VALOR,SE5->E5_DATA})
						Else
									aBorderos[nPosBor][5]	+=	SE5->E5_VALOR
								Endif
							Endif
						Endif
						If nOpcao == 1
							DbSelectArea("SE5" )
							If SE5->E5_TIPODOC == "BA"

								oModel := FWLoadModel('FINM010') //Baixas a receber.
								oModel:SetOperation(MODEL_OPERATION_UPDATE)
								oModel:Activate()
								oModel:SetValue('MASTER','E5_OPERACAO',3) //Exclui SE5.
								If oModel:VldData()
									oModel:CommitData()
									oModel:DeActivate()
								Else
									cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
									cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) 				 + ' - '
									cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])                
									Help( ,,"M010VALID",,cLog, 1, 0 )              
								EndIf

							Else
								oModel := FWLoadModel('FINM010') //Baixas a receber.
								oModel:SetOperation( MODEL_OPERATION_UPDATE ) //Alteração
								oModel:Activate()
								oModel:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
								oFKA := oModel:GetModel( "FKADETAIL" )
								oFK1 := oModel:GetModel( "FK1DETAIL" )
								oFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
								oModel:SetValue( "MASTER", "E5_OPERACAO", 2 ) //Estorno
								oModel:SetValue( "MASTER", "HISTMOV"    , cHistor  )
								//
								oFK1 := oModel:GetModel( "FK1DETAIL" )
								If !lUsaFlag
									If lLancPad70
										oFK1:SetValue("FK1_LA", "S")
									Else
										oFK1:SetValue("FK1_LA", " ")
									Endif
								EndIf
								//
								If oModel:VldData()
									oModel:CommitData()
									nRecSE5 := oModel:GetValue("MASTER","E5_RECNO")
									SE5->(dbGoTo(nRecSE5))
								Else
									lRet := .F.
									cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
									cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) 				 + ' - '
									cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])           	
									Help( ,,"M020VLDE2",,cLog, 1, 0 )
								Endif								
						oModel:DeActivate()
						oModel:Destroy()
						oModel := nil
						oFK1 := nil
						oFKA := nil
						
								nProcITF := SE5->E5_PROCTRA
																
								If cPAISLOC$"PER|BOL"
									SE5->(DbGoTop())
									SE5->(DbSetOrder(15))
									IF SE5->(DBSeek(xFilial("SE5")+nProcITF))
										While !EOF() .and. SE5->E5_PROCTRA=nProcITF
											If lFindITF .And. FinProcITF( SE5->( Recno() ),2 )
												FinProcITF( nRecSE5 ,6,, .F.,{ nHdlPrv, "573", "", "FINA089", cLotecom } , @aFlagCTB )
												EXIT
											ENDIF
											SE5->(DBSkip())
										Enddo
									Endif
								Endif
								SE5->(DbSetOrder(7))
							Endif
						Else
							If FUNNAME()=="FINA096"
								cFiltroSEF := ""
								cFiltroSEF := SEF->(DbFilter())
								SEF->(DbClearFilter())
								aAreaSEF := SEF->(GetArea("SEF"))
								SEF->(DbSetOrder(6))
						lAchou:=.F.
							cSeek:= SE5->E5_BCOCHQ+SE5->E5_AGECHQ+SE5->E5_CTACHQ
						If Empty(SE5->E5_BCOCHQ).or. Empty(SE5->E5_AGECHQ) .or. Empty(SE5->E5_AGECHQ)
							cSeek:= SE1->E1_BCOCHQ+SE1->E1_AGECHQ+SE1->E1_CTACHQ
						EndIf
						IF SEF->( DbSeek( cFilSEF+If(SE5->E5_ORIGEM=="F100BXCT","P",SE5->E5_RECPAG)+cSeek + SUBSTR(SE5->E5_NUMERO,1,TAMSX3("EF_NUM")[1]) +SE5->E5_PREFIXO))
							/* A origem do SE5 indica se o cheque é de terceiro usado em para pagamento a fornecedores (ver fina100). */
							lAchou:=.T.
						Else   
						SEF->(DbSetOrder(3)) 
						SEF->( DbSeek( cFilSEF+(SE5->E5_PREFIXO+SE5->E5_ORDREC+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_NUMERO)))							
							lAchou:=.T.
							SEF->(DbSetOrder(6))
						ENdIf
						
						If lAchou
							RecLock("SEF")
							If !(cPaisLoc == "BRA") .and. Empty(SEF->EF_ORDPAGO)
								SEF->EF_STATUS	:= If(cChvLbx=="11","01",If(cChvLbx="12","07","05"))
								SEF->EF_RECONC	:=	""
								SEF->(MSUnlock())
								If cChvLbx <> "11"
									Aadd(aRegSEF,{SEF->(Recno()),SEF->EF_CLIENTE,SEF->EF_LOJACLI})
									If !Empty(SEF->EF_FORNECE)
										Aadd(aRegSEFOP,{SEF->(Recno()),SEF->EF_CLIENTE,SEF->EF_LOJACLI,"",SEF->EF_FORNECE,SEF->EF_LOJA})
									Endif
								Endif
								RecLock("SE1",.F.)
								SE1->E1_STATUS:= "R"
								SE1->(MSUnlock())
								// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        						// ³  Ponto de Entrada para gravar campos de Usuário em SE1        ³
        						// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						        If ExistBlock("F089SE1")
						         ExecBlock("F089SE1",.F.,.F.)
						        EndIf
									Else
										If !(cPaisLoc == "BRA") .and. !Empty(SEF->EF_ORDPAGO)
											If cChvLbx == "97" .And. SEF->EF_STATUS == "09"
												cNumOrdPag := SEF->EF_ORDPAGO
												cRelOrdPag	+= (If(Empty(cRelOrdPag)," ","; ") + SEF->EF_ORDPAGO)
											EndIf
											/*
											* quando o cheque foi utilizado para pagamento de fornecedores deverao ser geradas nd para eles tambem
											*/
											If cChvLbx <> "11"
												If cChvLbx <> "97" .Or. SEF->EF_STATUS <> "09"
													Aadd(aRegSEF,{SEF->(Recno()),SEF->EF_CLIENTE,SEF->EF_LOJACLI})
												EndIf
												Aadd(aRegSEFOP,{SEF->(Recno()),SEF->EF_CLIENTE,SEF->EF_LOJACLI,SEF->EF_ORDPAGO})
											Endif

											Do Case
												Case cChvLbx == "11" //Devolucion Con Nueva Presentacion
												SEF->EF_STATUS := "01"
												Case cChvLbx == "12" //Devolucion definitiva
												SEF->EF_STATUS := "07"
												Case cChvLbx == "97" .And. SEF->EF_STATUS == "09" //Cheque Sustituido
												SEF->EF_STATUS	:= "01"
												SEF->EF_ORDPAGO	:= CriaVar("EF_ORDPAGO",.F.)
												OtherWise
												SEF->EF_STATUS := "05"
											EndCase

											SEF->EF_RECONC	:=	""
											SEF->(MSUnlock())

										Endif
									Endif
									DbSelectArea("FRF")
									cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
									RecLock("FRF",.T.)
									FRF->FRF_FILIAL		:= xFilial("FRF")
									FRF->FRF_BANCO		:= SEF->EF_BANCO
							FRF->FRF_AGENCI	:= SEF->EF_AGENCIA
									FRF->FRF_CONTA		:= SEF->EF_CONTA
									FRF->FRF_NUM		:= SEF->EF_NUM
									FRF->FRF_PREFIX		:= SEF->EF_PREFIXO
									FRF->FRF_CART		:= "R"
									FRF->FRF_DATPAG		:= SEF->EF_DATAPAG
									FRF->FRF_DATDEV		:= dDataBase
									FRF->FRF_MOTIVO		:= cChvLbx
									If Empty(cNumOrdPag)
										FRF->FRF_DESCRI	:= Substr(aMotivos[nChvLbx],(TamSX3("X5_TABELA")[1]+4),Len(FRF->FRF_DESCRI))
									Else
										FRF->FRF_DESCRI	:= Substr(aMotivos[nChvLbx] + ". "+STR0093+": " + cNumOrdPag,(TamSX3("X5_TABELA")[1]+4),Len(FRF->FRF_DESCRI)) //"Ord. Pago"
									EndIf
									FRF->FRF_SEQ		:= cSeqFRF
									FRF->(MsUnLock())
									ConfirmSX8()
								Endif
								If !Empty(cFiltroSEF)
									SEF->(DbSetfilter({||&cFiltroSEF},cFiltroSEF))
								EndIf
								SEF->(RestArea(aAreaSEF))
							Endif
							DbSelectArea("SE5" )
							If SE5->E5_TIPODOC == "BA"

								oModel := FWLoadModel('FINM010') //Baixas a receber.
								oModel:SetOperation(MODEL_OPERATION_UPDATE)
								oModel:Activate()
								oModel:SetValue('MASTER','E5_OPERACAO',3) //Exclui SE5.
								If oModel:VldData()
									oModel:CommitData()
								Else
									cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
									cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ])        + ' - '
									cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])                  
									Help( ,,"FN89VALID",,cLog, 1, 0 )              
								EndIf

							Else

								oModel  := FWLoadModel("FINM010") //Baixas a receber						
								oModel:SetOperation(MODEL_OPERATION_UPDATE) //Alteração
								oModel:Activate()
								oModel:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
								//
								oFKA := oModel:GetModel( "FKADETAIL" )
								oFK1 := oModel:GetModel( "FK1DETAIL" )
								If oFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
									oModel:SetValue( "MASTER", "E5_OPERACAO", 1 ) //SITUACAO = 'C'
									oFK1:SetValue( "FK1_MOEDA",SE5->E5_MOEDA)
									oFK1:SetValue( "FK1_DATA"  , dDataBase)
									oFK1:SetValue( "FK1_RECPAG",SE5->E5_RECPAG )
									oFK1:SetValue( "FK1_TPDOC" ,SE5->E5_TIPODOC)
									oFK1:SetValue( "FK1_MOTBX" ,'NOR')
									If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
										aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
									Else
										oFK1:SetValue('FK1_LA', "S")
									EndIf
									//	
									If oModel:VldData()
										oModel:CommitData()
									Else
										lRet := .F.
										cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
										cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ])        + ' - '
										cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])          	
										Help( ,,"M020VLDE2",,cLog, 1, 0 )
									Endif								
								EndIf
								nProcITF:=SE5->E5_PROCTRA
								If cPAISLOC$"PER|BOL"
									If lFindITF .And. FinProcITF( SE5->( Recno() ),1 ) .AND. lRetCkPG(3,,SE5->E5_BANCO)
										FinProcITF( SE5->( Recno() ),5,, .F.,{ nHdlPrv, "573", "", "FINA089", cLotecom } , @aFlagCTB )
									EndIf
								Endif
								SE5->(DbSetOrder(7))

							Endif
					oModel:DeActivate()
					oModel:Destroy()
					oModel := nil
					oFK1 := nil
					oFKA := nil
						Endif
					Endif
				Else
					If !(cPaisLoc == "BRA")  .and. FUNNAME() == "FINA096" .and. !Empty(TMP089->LCANCELOP)
						cFiltroSEF := ""
						cFiltroSEF := SEF->(DbFilter())
						SEF->(DbClearFilter())
						aAreaSEF:=SEF->(GetArea("SEF"))
						SEF->(DbSetOrder(6))
						If SEF->( DbSeek( xFilial("SEF")+"R"+TMP089->E1_BCOCHQ+TMP089->E1_AGECHQ+TMP089->E1_CTACHQ+SUBSTR(TMP089->E1_NUM,1,TAMSX3("EF_NUM")[1])+TMP089->E1_PREFIXO))
							RecLock("SEF")
							SEF->EF_STATUS	:= If(cChvLbx=="11","01",If(cChvLbx="12","07","05"))
							SEF->EF_RECONC	:=	""
							SEF->EF_DTDEVCH := DDATABASE
							SEF->(MSUnlock())
							If cChvLbx <> "11"
								Aadd(aRegSEF,{SEF->(Recno()),SEF->EF_CLIENTE,SEF->EF_LOJACLI})
								/*
								* quando o cheque foi utilizado para pagamento de fornecedores deverao ser geradas nd para eles tambem
								*/
								If !Empty(SEF->EF_ORDPAGO)
									Aadd(aRegSEFOP,{SEF->(Recno()),SEF->EF_CLIENTE,SEF->EF_LOJACLI,SEF->EF_ORDPAGO})
								Endif
							Endif
							DbSelectArea("FRF")
							cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
							RecLock("FRF",.T.)
							FRF->FRF_FILIAL		:= xFilial("FRF")
							FRF->FRF_BANCO		:= SEF->EF_BANCO
							FRF->FRF_AGENCIA	:= SEF->EF_AGENCIA
							FRF->FRF_CONTA		:= SEF->EF_CONTA
							FRF->FRF_NUM		:= SEF->EF_NUM
							FRF->FRF_PREFIX		:= SEF->EF_PREFIXO
							FRF->FRF_CART		:= "R"
							FRF->FRF_DATPAG		:= SEF->EF_DATAPAG
							FRF->FRF_DATDEV		:= dDataBase
							FRF->FRF_MOTIVO		:= cChvLbx
							FRF->FRF_DESCRI		:= Substr(aMotivos[nChvLbx],(TamSX3("X5_TABELA")[1]+4),Len(FRF->FRF_DESCRI))
							FRF->FRF_SEQ		:= cSeqFRF
							FRF->(MsUnLock())
							ConfirmSX8()
						Endif
						If !Empty(cFiltroSEF)
							SEF->(DbSetfilter({||&cFiltroSEF},cFiltroSEF))
						EndIf
						SEF->(RestArea(aAreaSEF))
					Endif
				Endif
			Else
				If TMP089->E1_OK == cMarcaE1 .and. !(cPaisLoc == "BRA")  .and. FUNNAME()=="FINA096" .and. TMP089->LCANCELOP=="R"
					cFiltroSEF := ""
					cFiltroSEF := SEF->(DbFilter())
					SEF->(DbClearFilter())
					aAreaSEF:=SEF->(GetArea("SEF"))
					SEF->(DbSetOrder(6))
					IF SEF->( DbSeek( xFilial("SEF")+"R"+TMP089->E1_BCOCHQ+TMP089->E1_AGECHQ+TMP089->E1_CTACHQ+SUBSTR(TMP089->E1_NUM,1,TAMSX3("EF_NUM")[1])+TMP089->E1_PREFIXO))
						RecLock("SEF")
						DbSelectArea("FRF")
						cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
						RecLock("FRF",.T.)
						FRF->FRF_FILIAL		:= xFilial("FRF")
						FRF->FRF_BANCO		:= SEF->EF_BANCO
						FRF->FRF_AGENCIA	:= SEF->EF_AGENCIA
						FRF->FRF_CONTA		:= SEF->EF_CONTA
						FRF->FRF_NUM		:= SEF->EF_NUM
						FRF->FRF_PREFIX		:= SEF->EF_PREFIXO
						FRF->FRF_CART		:= "R"
						FRF->FRF_DATPAG		:= SEF->EF_DATAPAG
						FRF->FRF_DATDEV		:= dDataBase
						FRF->FRF_MOTIVO		:= cChvLbx
						FRF->FRF_DESCRI		:= Substr(aMotivos[nChvLbx],(TamSX3("X5_TABELA")[1]+4),Len(FRF->FRF_DESCRI))
						FRF->FRF_SEQ		:= cSeqFRF
						FRF->(MsUnLock())
						ConfirmSX8()
					Endif
				Endif
			Endif

			// Se Portugal, alimenta aDiario
			If  UsaSeqCor()
				AADD(aDiario,{"SE5",SE5->(recno()),cCodDiario,"E5_NODIA","E5_DIACTB"})
			EndIf

			DbSelectArea("TMP089")
			TMP089->(DbSkip())
		EndDo

		For nX := 1	 To Len(aBorderos)
			cHistor	:=	STR0074  //"Ajuste Canc. Bordero"
			SE5->(DbSetOrder(1))
			SE5->(DbSeek(cFilSE5+Dtos(aBorderos[nX][6])+aBorderos[nX][1]+aBorderos[nX][2]+aBorderos[nX][3]))
			//Busco el credito original (por total). Bruno
			While aBorderos[nX][6] == SE5->E5_DATA .And. !SE5->(EOF()) .And. ;
			cFilSE5+aBorderos[nX][1]+aBorderos[nX][2]+aBorderos[nX][3] == ;
			SE5->(E5_FILIAL+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA)

				If SE5->E5_TIPODOC == "VL" .And. Empty(SE5->E5_TIPO) .And. ;
				SE5->E5_RECPAG == 'R' .And. Alltrim(SE5->E5_DOCUMEN) == aBorderos[nX][4]
					If SE5->E5_SITUACA <> "C"
						If nOpcao == 2 .And.	aBorderos[nX][5] == SE5->E5_VALOR

							oModel  := FWLoadModel("FINM010")	//Baixas a receber.					
							oModel:SetOperation(MODEL_OPERATION_UPDATE) 
							oModel:Activate()
							oModel:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
							oFKA := oModel:GetModel( "FKADETAIL" )
							oFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
							//
							oModel:SetValue( "MASTER", "E5_OPERACAO", 1 ) //SITUACAO = 'C'
							//		
							If oModel:VldData()
								oModel:CommitData()
							Else
								lRet := .F.
								cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
								cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) 				 + ' - '
								cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])      	
								Help( ,,"M020VLDE2",,cLog, 1, 0 )	
							Endif								
					oModel:DeActivate()
					oModel:Destroy()
					oModel := nil
					oFKA := nil				
							//Subtrair do valor total do bordero, por causa de um eventual ajuste
							//por algum titulo devolvido antes da cancelacao. Bruno
							aBorderos[nX][5] :=	0
						Endif
					Endif
				Endif
				SE5->(DbSkip())
			Enddo
		Next

		For nX := 1	 To Len(aBorderos)

			If  aBorderos[nX][5] <> 0

				oModel := FWLoadModel("FINM030") //Mov. Bancaria;
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				oModel:Activate()
				oFKA := oModel:GetModel( "FKADETAIL" )
				oFK5 := oModel:GetModel('FK5DETAIL')
				oFKA:SetValue('FKA_IDORIG',FWUUIDV4())
				oFKA:SetValue('FKA_TABORI','FK5')
				//
				If type("cCamposE5") == "U"
					cCamposE5 := ""
				EndIf
				cCamposE5 += "{{'E5_DTDIGIT'	, dDataBase}"
				If cPaisLoc=="URU"
					cCamposE5 += " {'E5_FILIAL'		,'" + FWxFilial("SE5") + "'}"
					cCamposE5 += ",{'E5_CLIFOR'		,'" + SE1->E1_CLIENTE + "'}"
					cCamposE5 += ",{'E5_LOJA'		,'" + SE1->E1_LOJA + "'}"
					cCamposE5 += ",{'E5_NUMERO'		,'" + "BOR"+aBorderos[nX][4] + "'}"
					cCamposE5 += ",{'E5_PREFIXO'	,'" + SE1->E1_PREFIXO + "'}"
					cCamposE5 += ",{'E5_PARCELA'	,'" + SE1->E1_PARCELA + "'}"
					cCamposE5 += ",{'E5_TIPO'		,'" + SE1->E1_TIPO + "'}"
					cCamposE5 += ",{'E5_BENEF'		,'" + SE1->E1_NOMCLI + "'}"
					cCamposE5 += ",{'E5_DOCUMEN'	,'" + aBorderos[nX][4] +"'}"  
				EndIf
				cCamposE5 += ",{'E5_DTDISPO'	, dDataBase}}"
				oFK5 := oModel:GetModel('FK5DETAIL')
				oFK5:SetValue('FK5_BANCO' , Iif(Empty(aBorderos[nX][1]),SEK->EK_BANCO,aBorderos[nX][1])	)			
				oFK5:SetValue('FK5_AGENCI', Iif(Empty(aBorderos[nX][2]),SEK->EK_AGENCIA,aBorderos[nX][2])	)	
				oFK5:SetValue('FK5_CONTA' , Iif(Empty(aBorderos[nX][3]),SEK->EK_CONTA,aBorderos[nX][3])	)	
				oFK5:SetValue('FK5_DOC'   , aBorderos[nX][4])
				oFK5:SetValue('FK5_DATA'  , dDataBase				  )
				oFK5:SetValue('FK5_TPDOC' , "ES"            )
				oFK5:SetValue('FK5_HISTOR', cHistor         )
				oFK5:SetValue('FK5_RECPAG', "P"             )
				oFK5:SetValue('FK5_VALOR' , Abs(aBorderos[nX][5]))
				oFK5:SetValue('FK5_VLMOE2', Abs(aBorderos[nX][5]))
				oFK5:SetValue('FK5_MOEDA', "01")
				If Funname()="FINA096"
					oFK5:SetValue( "FK5_NATURE" ,SEK->EK_NATUREZ )
				EndIf

				If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
					aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
				Else
					oFK5:SetValue('FK5_LA' , "S")
				EndIf		
				//Outros valores serão gravados dentro do modelo com base na FK1.
				oModel:SetValue('MASTER','E5_CAMPOS', cCamposE5)
				oModel:SetValue('MASTER','E5_GRV'		, .T.)
				//
				If oModel:VldData()
					oModel:CommitData()
				Else
					cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
					cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ])        + ' - '
					cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])               
					Help( ,,"FN89VALID",,cLog, 1, 0 )              
				EndIf
				oModel:DeActivate()
				oModel:Destroy()
				oModel := nil
				oFK5 := nil
				oFKA := Nil
		
				If UsaSeqCor()
					AADD(aDiario,{"SE5",SE5->(recno()),cCodDiario,"E5_NODIA","E5_DIACTB"})
				Endif

			Endif
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Genera Pie de asiento Contab. para CAncelamiento de baja ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nHdlPrv > 0 .and. lLancPad70  .And.lLance //.and. !__TTSInUse
			RodaProva(	nHdlPrv,;
			nTotalLanc)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia para Lancamento Contabil, se gerado arquivo   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			n := 1
			cA100Incl( cArquivo,;
			nHdlPrv,;
			3,;
			cLoteCom,;
			lDigita,;
			lAglutina,;
			/*cOnLine*/,;
			/*dData*/,;
			/*dReproc*/,;
			@aFlagCTB,;
			/*aDadosProva*/,;
			aDiario )
			aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
		Endif

		PcoFinLan("000360")
		/*
		geracao das notas de debito */
		If !(cPaisLoc == "BRA") .and. FUNNAME()=="FINA096"
			/*
			geracao de nd para fornecedores e para clientes, quando o cheques destes foram utilizados para pagamento daqueles*/
			nL := Len(aRegSEFOP)
			lPerg := .T.
			If nL > 0
				/* obter os codigos dos fornecedores a partir da OP */
				SEK->(DbSetOrder(1))
				For nX := 1 To nL
					If !Empty(aRegSEFOP[nX,4])
						If SEK->(DbSeek(xFilial("SEK") + aRegSEFOP[nX,4]))
							Aadd(aRegSEFOP[nX],SEK->EK_FORNECE)
							Aadd(aRegSEFOP[nX],SEK->EK_LOJA)
						Else
							Aadd(aRegSEFOP[nX]," ")
							Aadd(aRegSEFOP[nX]," ")
						Endif
					Endif
				Next
				/*
				gerar as nd para fornecedores */
				lVldImpFor	:= cChvLbx == "97"
				aRegSEFOP := Asort(aRegSEFOP,,,{|x,y| (x[5]+x[6]) < (y[6]+y[6])})		//ordenar o array para agrupar por fornecedor/loja
				nX := 1
				While (nX <= nL)
					/*
					seleciona os documentos de um mesmo fornecedor para gerar uma unica ND*/
					cClieFor := aRegSEFOP[nX,5]
					cLoja := aRegSEFOP[nX,6]
					aRegND := {}
					While (nX <= nL) .And. (cClieFor == aRegSEFOP[nX,5]) .And. (cLoja == aRegSEFOP[nX,6])
						Aadd(aRegND,aRegSEFOP[nX,1])
						nX++
					Enddo
					/*
					executar da mesma forma que para os cheques emitidos */
					cNumNota	:= ""
					cSerNota	:= ""
					cEspNota	:= ""
					If cPaisLoc == "ARG"
						cMvparAnt:= MV_PAR01
						If !Pergunte("PVXARG",.T.)
							DisarmTrans()
							Return .F.
						Endif
						cLocxNFPV := MV_PAR01
			 			MV_PAR01:= cMvparAnt
					EndIf
					MsgRun(OemToAnsi(STR0089 + " (" + STR0091 + ")."),,{|| NFxInclui(nTipoNDF,{|| A095DadosND(cClieFor,cLoja,aRegND,,,,,lVldImpFor)},lPerg)})		//"Gerando documento de débito" ###"Gerando documento de débito" ###
					lPerg := .F.
					If Empty(cNumNota)
						DisarmTrans()
						aRegSEF := {}
					Else
						For nI := 1 To Len(aRegND)
							SEF->(DbGoTo(aRegND[nI]))
							/*
							registra a criacao da ND no historico do documento*/
							cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
							RecLock("FRF",.T.)
							Replace FRF->FRF_FILIAL		With xFilial("FRF")
							Replace FRF->FRF_BANCO		With SEF->EF_BANCO
							Replace FRF->FRF_AGENCIA	With SEF->EF_AGENCIA
							Replace FRF->FRF_CONTA		With SEF->EF_CONTA
							Replace FRF->FRF_NUM		With SEF->EF_NUM
							Replace FRF->FRF_PREFIX		With SEF->EF_PREFIXO
							Replace FRF->FRF_CART		With "P"
							Replace FRF->FRF_DATPAG		With SEF->EF_DATAPAG
							Replace FRF->FRF_DATDEV		With dDataBase
							Replace FRF->FRF_MOTIVO		With "80"
							Replace FRF->FRF_DESCRI		With STR0089 // "Documento de débito (fornecedor)"
							Replace FRF->FRF_SEQ		With cSeqFRF
							Replace FRF->FRF_FORNEC		With cClieFor
							Replace FRF->FRF_LOJA		With cLoja
							Replace FRF->FRF_NUMDOC		With cNumNota
							SerieNFID("FRF",1,"FRF_SERDOC",dDataBase,cEspNota,cSerNota)	
							Replace FRF->FRF_ITDOC		With AllTrim(StrZero(nI,TamSX3("D2_ITEM")[1]))
							Replace FRF->FRF_ESPDOC		With cEspNota
							FRF->(MsUnLock())
							ConfirmSX8()
						Next
					Endif
				Enddo
			Endif
			/*
			Geracao das nd para clientes. */
			aRegSEF := Asort(aRegSEF,,,{|x,y| (x[2]+x[3]) < (y[2]+y[3])})		//ordenar o array para agrupar por cliente/loja
			nL := Len(aRegSEF)
			nX := 1
			While (nX <= nL)
				/*
				seleciona os documentos de um mesmo cliente para gerar uma unica ND*/
				cClieFor := aRegSEF[nX,2]
				cLoja := aRegSEF[nX,3]
				aRegND := {}
				While (nX <= nL) .And. (cClieFor == aRegSEF[nX,2]) .And. (cLoja == aRegSEF[nX,3])
					Aadd(aRegND,aRegSEF[nX,1])
					If Upper(AllTrim(SEF->EF_ORIGEM)) == "FINA100"
						SE5->(DbSetOrder(11))
						For nCanc = 1 To Len(aDadosCanc)
							If aDadosCanc[nCanc][1] == SEF->(EF_BANCO + EF_AGENCIA + EF_CONTA)
								If SE5->(DbSeek(xFilial("SE5") + aDadosCanc[nCanc][2] + SEF->EF_NUM))
									aRegSE5 := {}
									While  Len(aRegSE5) == 0
										If SE5->(E5_CLIFOR+E5_LOJA) == SEF->(EF_CLIENTE+EF_LOJACLI)
											AADD(aRegSE5,{"E5_DATA",SE5->E5_DATA,Nil})
											Fina100(0,aRegSE5,6)
										EndIf
										SE5->(DbSkip())
									EndDo
								Endif
								If Len(aRegSE5) >= 0
									Exit
								EndIf
							EndIf
						Next
					Endif
					nX++
				Enddo
				/*
				* Antes de se chamar funcao da locxnf - mata465 - deve-se inicializar a variavel abaixo com um bloco de codigo que sera usado para
				* preencher os dados da nota automaticamente. Este bloco de codigo e executado logo apos a criacao da tela de digitacao da nota e
				* alem de inicializar as variaveis, define o bloco de validacao executado apos a digitacao da ND. O bloco de validacao e responsavel
				* por recuperar os dados da ND digitada.
				*/
				/*
				* As variaveis com os dados da nota sao declaradas como private para estarem disponiveis para o bloco de validacao preenche-las apos a
				* finalizacao da digitacao da ND.
				*/
				N:= 1
				cNumNota	:= ""
				cSerNota	:= ""
				cEspNota	:= ""
				cLocxNFPV	:=""
				If cPaisLoc == "ARG"
					cMvparAnt:= MV_PAR01
					If !Pergunte("PVXARG",.T.)
						DisarmTrans()
						Return .F.
					Endif
					cLocxNFPV := MV_PAR01
		 			MV_PAR01:= cMvparAnt
				EndIf
				MsgRun(OemToAnsi(STR0090 + " (" + STR0030 + "). " + STR0091 + "."),,{|| NFxInclui(nTipoNDC,{|| A096DadosND(cClieFor,cLoja,aRegND,,,,,cLocxNFPV)},lPerg)}) //"Gerando documento de débito" //"Cliente" // "Aguarde"				
				If Empty(cNumNota)
					DisarmTrans()
					nX := nL + 1
				Else
					For nI := 1 To Len(aRegND)
						SEF->(DbGoTo(aRegND[nI]))
						/*
						registra a criacao da ND no historico do documento*/
						cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
						RecLock("FRF",.T.)
						Replace FRF->FRF_FILIAL		With xFilial("FRF")
						Replace FRF->FRF_BANCO		With SEF->EF_BANCO
						Replace FRF->FRF_AGENCIA	With SEF->EF_AGENCIA
						Replace FRF->FRF_CONTA		With SEF->EF_CONTA
						Replace FRF->FRF_NUM		With SEF->EF_NUM
						Replace FRF->FRF_PREFIX		With SEF->EF_PREFIXO
						Replace FRF->FRF_CART		With "R"
						Replace FRF->FRF_DATPAG		With SEF->EF_DATAPAG
						Replace FRF->FRF_DATDEV		With dDataBase
						Replace FRF->FRF_MOTIVO		With "81"
						Replace FRF->FRF_DESCRI		With STR0092 //"Documento de débito (cliente)"
						Replace FRF->FRF_SEQ		With cSeqFRF
						Replace FRF->FRF_CLIENT		With cClieFor
						Replace FRF->FRF_LOJA		With cLoja
						Replace FRF->FRF_NUMDOC		With cNumNota
						SerieNFID("FRF",1,"FRF_SERDOC",,,,SF2->F2_SERIE)		
						Replace FRF->FRF_ITDOC		With AllTrim(StrZero(nI,TamSX3("D2_ITEM")[1]))
						Replace FRF->FRF_ESPDOC		With cEspNota
						FRF->(MsUnLock())
						ConfirmSX8()
					Next
				Endif
			Enddo
		Endif
		/*-*/
End Transaction

	If oTmpTable <> Nil   
		oTmpTable:Delete()  
		oTmpTable := Nil
	EndIf 
	DbSelectArea("SE1")

	RestArea(aAreaSEK	)
	
    If !lAutomato
		   Eval( bFiltraBrw )
	Endif

	If !(Empty(cNumOrdPag))
		MsgAlert(STR0094 + cRelOrdPag + ".") //"Cheque(s) referente(s) a(s) seguinte(s) Ordem(ns) de Pagamento não ira(ão) gerar nota para o cliente: "
	EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A089AcrAut³ Autor ³ BRUNO SOBIESKI        ³ Data ³ 26.03.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acreditar cheques automaticamente                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA089                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Bruno Sobieski³01.12.99³Melhor³Pegar Numero de lanzamento padronizado  ³±±
±±³              ³        ³      ³ do fa070Pad(). (Aten‡ao! Atualizar SI5 ³±±
±±³              ³        ³      ³ de 520 para 521).                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A089AcrAut(lAutomato)        // incluido pelo assistente de conversao do AP5 IDE em 16/11/99

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cBorde	:= cBorAte	:=	Criavar("E1_NUMBOR")
	Local bWhile,cCond,bCond
	Local nPosBor	:=	0,	aBorderos	:=	{}
	Local nX := 0, nA := 0
	Local lBordero		:= .F.
	Local cLstDesc		:= FN022LSTCB(2)	//Lista das situacoes de cobranca (Descontada)
	Local cLstBcoNoDesc	:= FN022LSTCB(5)	//Lista das situacoes de cobranca (Em banco mas sem desconto)
		
	SetPrvt("LLANCE,LLANCPAD70,CARQUIVO,NHDLPRV,NTOTALLANC,CLOTECOM")
	SetPrvt("NLINHA,LCANCEL,CBCODE,CBCOATE,NREC,LPRIM")
	SetPrvt("ARECSSE5,LLANCTOK,NA,")

	Private lIgnora	:=	.F.
	Private aDiario := {}
	Private cCodDiario:= ""
	Private nXaux1   := 0
    Default lAutomato	:= .F.  // Utilizada para el paso de scripts automatizados

	lLance      := .F.
	lLancPad70	:=	.F.
	cArquivo 	:= ""
	nHdlPrv 		:= 0
	nTotalLanc 	:= 0
	cLoteCom 	:= ""
	nLinha 		:= 2

	lCancel     := .T.

	SA1->(DbSetOrder(1))
	SA6->(DbSetOrder(1))

	cBcoDe 	:= Space(TamSx3("A6_COD")[1])
	cBcoAte	:= Space(TamSx3("A6_COD")[1])

	nRec  := SE1->(Recno())
	IF !lAutomato
		DEFINE MSDIALOG  oDlg1 FROM 00,000 To 145,386  Title OemToAnsi(STR0010) PIXEL //"Parámetros"
		@ 00,003 To 50,184 PIXEL Of oDlg1
		@ 09,008 SAY OemToAnsi(STR0011)   SIZE 40,10 PIXEL Of oDlg1// "Banco de "
		@ 09,045 MSGet cBcoDe   F3 "BCO" Picture "@!" Valid ExistCpo("SA6") .and. If(cPaisLoc=="PER",If(!cBcoDe $ cFilCxCtr ,.T.,Eval({||MsgAlert(STR0087),.F.})),.T.) PIXEL Of oDlg1
		@ 09,095 SAY OemToAnsi(STR0012)   PIXEL SIZE 40,10 Of oDlg1// "Banco Hasta "
		@ 09,136 MSGet cBcoAte  F3 "BCO" Picture "@!" Valid ExistCpo("SA6") .and. If(cPaisLoc=="PER",If(!cBcoAte $ cFilCxCtr ,.T.,Eval({||MsgAlert(STR0087),.F.})),.T.) PIXEL Of oDlg1
	
		@ 25,008 SAY OemToAnsi(STR0059) PIXEL Of oDlg1 //"Bordero de :"
		@ 25,045 MSGet cBorDe   Picture "@!" Valid IIf(Empty(cBorde) .Or. Empty(cBorAte),EVAL({|| oChkBx:DISABLE(),.T.}), EVAL({|| oChkBx:ENABLE(),.T.}) ) PIXEL Of oDlg1
		@ 25,095 SAY OemToAnsi(STR0060) SIZE 40,10 PIXEL Of oDlg1 //"Bordero hasta : "
		@ 25,136 MSGet cBorAte  Picture "@!" Valid IIf(Empty(cBorde) .Or. Empty(cBorAte),EVAL({|| oChkBx:DISABLE(),.T.}), EVAL({|| oChkBx:ENABLE(),.T.}) ) PIXEL Of oDlg1
	
		oChkBx	:=	IW_CHECKBOX(40,008,OemToAnsi(STR0061),"lIgnora") //"Ignorar fecha de acreditacion"
		oChkBx:DISABLE()
	
		DEFINE SBUTTON FROM  52,108 Type 1 Action (Iif(fa089VldBor(cBorde,cBorAte),(lCancel	:=	.F.,oDlg1:END() ),Nil))  ENABLE PIXEL Of oDlg1// Substituido pelo assistente de conversao do AP5 IDE em 16/11/99 ==> @ 25,108 BmpButton Type 1 Action Execute(OkProc)
		DEFINE SBUTTON FROM  52,149 Type 2 Action (oDlg1:END()) PIXEL ENABLE Of oDlg1
		Activate MSDialog oDlg1 CENTERED
    Else
       If FindFunction("GetParAuto")
				aRetAuto 		:= GetParAuto("FINA089TESTCASE")
				cBcoDe 			:= aRetAuto[1]
				cBcoAte 		:= aRetAuto[2]
				lCancel 		:= .F.
				lGeraLanc		:= .F.
				lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/ )
				oTmpTable 		:= Nil
		  Endif
    EndIf
	If lCancel
		DbSelectArea("SE1")
		Eval( bFiltraBrw )
		RETURN
	Endif


	If !Empty(cBorDe) .And. !Empty(cBorAte)
		DbSelectArea("SE1")
		DBSETORDER(5)
		bWhile	:=	{ || !EOF() .And. E1_FILIAL == xFilial("SE1") .And. E1_NUMBOR <= cBorAte }
		cCond		:= '{ || E1_PORTADO >= cBcoDe .And. E1_PORTADO <= cBcoAte .And. E1_SALDO > 0 .And. E1_SITUACA $ "' + cLstBcoNoDesc +'" .AND.!EMPTY(E1_PORTADO)'
		If lIgnora
			bCond	:=	&(cCond+"}")
		Else
			bCond	:=	&(cCond+".AND. E1_DTACRED <= DDATABASE }")
		Endif
		DbSeek(xFilial()+cBorDe,.T.)
	Else
		DbSelectArea("SE1")
		DBSETORDER(4)
		bWhile	:=	{|| !EOF() .AND. E1_FILIAL == xFilial("SE1") .AND. E1_PORTADO	<=	cBcoAte }
		cCond		:= '{ ||  E1_SALDO > 0 .And. E1_SITUACA $ "' + cLstBcoNoDesc +'" .AND.!EMPTY(E1_PORTADO) .AND. E1_DTACRED <= DDATABASE '
		If Empty(cBorAte)
			bCond	:=	&(cCond+"}")
		Else
			bCond	:=	&(cCond+".AND. E1_NUMBOR >= cBorDe  .And. E1_NUMBOR <= cBorAte }")
		Endif
		DbSeek(xFilial()+ cBcoDe, .T. )
	Endif

	lPrim := .T.
	aRecsSe5 := {}
	lBordero := (cPaisLoc$"URU|BOL")

	PcoIniLan("000360")

	While Eval(bWhile)

		If Eval(bCond)

			RecLock("SE1",.F.)
			SE1->E1_BAIXA  := dDatabase
			SE1->E1_SALDO  := 0.00
			SE1->E1_MOVIMEN:= dDataBase
			SE1->E1_STATUS := "B"
			If cPaisLoc=="PAR"
				lBordero := !Empty(SE1->E1_NUMBOR)
			Endif
			MsUnlock()
			SA6->(DbSetOrder(1))
			SA6->(DbSeek(xFilial()+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA))

			oModel := FWLoadModel('FINM010') //Baixas a receber.
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			oModel:Activate()
			//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
			cCamposE5 := "{{'E5_DTDIGIT'	, dDataBase}"
			cCamposE5 += ",{'E5_TIPO'	   , SE1->E1_TIPO}"                            
			cCamposE5 += ",{'E5_PREFIXO'	, SE1->E1_PREFIXO}"
			cCamposE5 += ",{'E5_NUMERO'	, SE1->E1_NUM}"
			cCamposE5 += ",{'E5_PARCELA'	, SE1->E1_PARCELA}"
			cCamposE5 += ",{'E5_CLIFOR'	, SE1->E1_CLIENTE}"
			cCamposE5 += ",{'E5_LOJA'			, SE1->E1_LOJA}"                            
			cCamposE5 += ",{'E5_BENEF'		, SE1->E1_NOMCLI}"
			cCamposE5 += ",{'E5_DTDISPO'	, dDataBase}}"
			//FK7 x SE1.
			cChaveTit := xFilial("SE1")  + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM 			+ "|" +;
			SE1->E1_PARCELA + "|" +  SE1->E1_TIPO 		+ "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
			cIdDoc := FINGRVFK7("SE1", cChaveTit)
			//			
			oFKA := oModel:GetModel('FKADETAIL')
			oFK1 := oModel:GetModel('FK1DETAIL')
			oFK5 := oModel:GetModel('FK5DETAIL')
			//Cria FKA x FK1
			oFKA:SetValue('FKA_IDORIG', FWUUIDV4())
			oFKA:SetValue('FKA_TABORI','FK1')
			//
			oFK1:SetValue('FK1_RECPAG', 'R')
			oFK1:SetValue('FK1_HISTOR', OemToAnsi(STR0039))
			oFK1:SetValue('FK1_MOTBX' , 'NOR')
			oFK1:SetValue('FK1_DATA'  , dDataBase)
			oFK1:SetValue('FK1_VENCTO', dDataBase)
			oFK1:SetValue('FK1_NATURE', SE1->E1_NATUREZ)
			oFK1:SetValue('FK1_TPDOC' , If(lBordero,"BA","VL"))
			oFK1:SetValue('FK1_MOEDA' , StrZero(Max(SA6->A6_MOEDA,1),2))
			oFK1:SetValue('FK1_VALOR' , xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,Max(SA6->A6_MOEDA,1)))
			oFK1:SetValue('FK1_VLMOE2', SE1->E1_VALOR)
			oFK1:SetValue('FK1_SERREC', SE1->E1_SERREC)
			oFK1:SetValue('FK1_ORDREC', SE1->E1_RECIBO)
			oFK1:SetValue('FK1_DOC'   , SE1->E1_NUMBOR)
			oFK1:SetValue('FK1_SEQ'   , F089Seq())
			oFK1:SetValue('FK1_IDDOC' , cIdDoc)
			If !Empty(SE1->E1_NUMNOTA) .And. "LOJ"$SE1->E1_ORIGEM
				SE5->E5_NUMCHEQ	:= SE1->E1_NUMNOTA
			Endif
			//
			If oFK1:GetValue('FK1_TPDOC') == 'VL'
				//Cria FKA x FK5.
				oFKA:AddLine()
				oFKA:SetValue('FKA_IDORIG',FWUUIDV4())
				oFKA:SetValue('FKA_TABORI','FK5')
				//
				oFK5:SetValue('FK5_BANCO' ,SE1->E1_PORTADO)
				oFK5:SetValue('FK5_AGENCI',SE1->E1_AGEDEP)
				oFK5:SetValue('FK5_CONTA' ,SE1->E1_CONTA)			
				//Outros valores serão gravados dentro do modelo com base na FK1.
			EndIf 
			//
			oModel:SetValue('MASTER','E5_CAMPOS', cCamposE5)
			oModel:SetValue('MASTER','E5_GRV'		, .T.)
			//
			If oModel:VldData()
				oModel:CommitData()
			Else
				cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
				cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ])        + ' - '
				cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])               
				Help( ,,"FN89VALID",,cLog, 1, 0 )              
			EndIf
		 	oModel:DeActivate()
 			oModel:Destroy()
 			oModel := nil
 			oFK1 := nil
 			oFK5 := nil
 			oFKA := nil
			// Se Portugal, alimenta aDiario
			If UsaSeqCor()
				AADD(aDiario,{"SE5",SE5->(recno()),cCodDiario,"E5_NODIA","E5_DIACTB"})
			Endif

			If cPaisLoc$"URU|PAR|CHI|BOL"
				If lBordero
					nPosBor	:=	AScan(aBorderos,{|X| x[4] == SE1->E1_NUMBOR })
					If nPosBor	== 0
						AAdd(aBorderos,{SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE1->E1_NUMBOR,SE5->E5_VALOR})
					Else
						aBorderos[nPosBor][5]	+=	SE5->E5_VALOR
					Endif
				Endif
			Endif
			SA6->(DbSetOrder(1))
			SA6->(DbSeek(xFilial()+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA))
			AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,dDataBase,SE5->E5_VALOR,"+")
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA))
			AtuSalDup("-",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,,SE1->E1_EMISSAO)

			// +-----------------------------------------------------------------------+
			// ¦  SI ES LA PRIMER BAJA DE LA SERIE DE BAJAS, CHEQUEO SI EXISTE EL      ¦
			// ¦  ASIENTO PADRONIZADO Y GENERO EL ENCABEZADO DEL ASIENTO SI ES VERDAD  ¦
			// +-----------------------------------------------------------------------+
			cPadrao  := Fa070Pad()
			If lGeraLanc
				lLancPad70  := VerPadrao(cPadrao)
			Else
				lLancPad70  := .F.
			EndIf
			If lPrim
				If lLancPad70 //.and. !__TTSInUse
					//+--------------------------------------------------------------+
					//¦ Posiciona numero do Lote para Lancamentos do Financeiro      ¦
					//+--------------------------------------------------------------+
					dbSelectArea("SX5")
					dbSeek(xFilial()+"09FIN")
					cLoteCom:=IIF(Found(),Trim(X5_DESCRI),"FIN")
					nHdlPrv:=HeadProva( cLoteCom,;
					"FINA089",;
					Subs(cUsuario,7,6),;
					@cArquivo)
					If nHdlPrv <= 0
						Help(" ",1,"A100NOPROV")
					EndIf
				EndIf
				lPrim := .F.
			Endif

			If nHdlPrv > 0 .and. lLancPad70 //.and. !__TTSInUse
				//+----------------------------------------------------------+
				//¦ Genera Items de asiento Contab. para Baja de Cheques.    ¦
				//+----------------------------------------------------------+
				If lLancPad70
					SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
					SA6->(DbSeek(xFilial("SA6")+SE1->E1_PORTADOR+SE1->E1_AGEDEP+SE1->E1_CONTA))
					nTotalLanc += DetProva( nHdlPrv,;
					cPadrao,;
					"FINA089",;
					cLoteCom,;
					@nLinha,;
					/*lExecuta*/,;
					/*cCriterio*/,;
					/*lRateio*/,;
					/*cChaveBusca*/,;
					/*aCT5*/,;
					/*lPosiciona*/,;
					@aFlagCTB,;
					/*aTabRecOri*/,;
					/*aDadosProva*/ )

					If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
					Else

						oModel := FWLoadModel('FINM010') //Baixas a receber.
						oModel:SetOperation( MODEL_OPERATION_INSERT )
						oModel:Activate()
						//Atualiza o campo Identifica Lançamento;
						oFKA := oModel:GetModel('FKADETAIL')
					If oFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
						oModel:SetValue( 'FK1DETAIL', 'FK1_MOEDA',SE5->E5_MOEDA)
						oModel:SetValue( 'FK1DETAIL', 'FK1_VENCTO',SE5->E5_VENCTO)
						oModel:SetValue( 'FK1DETAIL', 'FK1_DATA', dDatabase)
						oModel:SetValue( "FK1DETAIL", 'FK1_VALOR' ,SE5->E5_VALOR)							
						oModel:SetValue( "FK1DETAIL", 'FK1_TPDOC' ,SE5->E5_TIPODOC)
						oModel:SetValue( "FK1DETAIL", 'FK1_RECPAG',SE5->E5_RECPAG )
						oModel:SetValue( "FK1DETAIL", 'FK1_MOTBX' ,SE5->E5_MOTBX)
						oModel:SetValue( 'FK1DETAIL', 'FK1_LA', "S")
						
						//
						If oModel:VldData()
							oModel:CommitData()
						Else
							cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
							cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) + ' - '
							cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])        	
							Help( ,,"FN370VL",,cLog, 1, 0 )
						EndIf								
					
					EndIf
				 	oModel:DeActivate()
 					oModel:Destroy()
 					oModel := nil
				EndIf
					IF cPAISLOC$"PER|BOL"
						If lFindITF .And. FinProcITF( SE5->(Recno()),1 ) .AND. lRetCkPG(3,,SE5->E5_BANCO)
							FinProcITF( SE5->(Recno()),3,SE5->E5_VALOR, .F.,{nHdlPrv,cPadrao,"FINA089","FINA089",cLotecom},)
						EndIf
					ENDIF
				ELSE
					IF cPAISLOC$"PER|BOL"//GERA ITF S/ CONTABILIZAÇÃO
						If lFindITF .And. FinProcITF( SE5->(Recno()),1 ) .AND. lRetCkPG(3,,SE5->E5_BANCO)
							FinProcITF( SE5->(Recno()),3,SE5->E5_VALOR, .F.)
						EndIf
					ENDIF
				Endif
			Endif
		Endif

		PcoDetLan("000360","05","FINA089",.F.)//Acreditar cheques automaticamente

		DbSelectArea("SE1")
		DbSkip()
	Enddo
	If cPaisLoc == "PAR"
		SE1->(DbCloseArea())
			
		DbSelectArea("SE1")
	EndIf
	For nX := 1	 To Len(aBorderos)
	oModel := FWLoadModel('FINM010') //Baixas a receber.
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
		// FKA x FK5.
		oModel:SetValue('FKADETAIL','FKA_IDORIG',FWUUIDV4())
		oModel:SetValue('FKADETAIL','FKA_TABORI','FK5')
		
		If cPaisLoc == "PAR"
			oModel:SetValue('FKADETAIL','FKA_IDFKA' ,FWUUIDV4())
		EndIf
		//
		oModel:SetValue('FK5DETAIL','FK5_BANCO' 	,aBorderos[nX][1])
		oModel:SetValue('FK5DETAIL','FK5_AGENCI'	,aBorderos[nX][2])
		oModel:SetValue('FK5DETAIL','FK5_CONTA' 	,aBorderos[nX][3])
		oModel:SetValue('FK5DETAIL','FK5_DOC'			,aBorderos[nX][4])
		oModel:SetValue('FK5DETAIL','FK5_DATA'		,dDataBase)
		oModel:SetValue('FK5DETAIL','FK5_TPDOC'		,"VL")
		oModel:SetValue('FK5DETAIL','FK5_RECPAG'	,"R")
		oModel:SetValue('FK5DETAIL','FK5_HISTOR'	,OemToAnsi(STR0039))
		oModel:SetValue('FK5DETAIL','FK5_VALOR'		,aBorderos[nX][5])
		oModel:SetValue('FK5DETAIL','FK5_VLMOE2'	,aBorderos[nX][5])


		If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
			aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
		Else
			oModel:SetValue('FK5DETAIL','FK5_LA', "S")
		EndIf
		
		If cPaisLoc == "PAR"
				nXaux1 := nX
				cCamposE5 := "{{'E5_DTDIGIT'	, dDataBase}"
				cCamposE5 += ",{'E5_DOCUMENT', aBorderos[nXaux1][4]}"                            
				cCamposE5 += ",{'E5_VENCTO'	, dDataBase}"
				cCamposE5 += ",{'E5_DTDISPO'	, dDataBase}}"
				oModel:SetValue('MASTER','E5_CAMPOS', cCamposE5)
		EndIF
		
		//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
		cCamposE5 := "{{'E5_DTDIGIT', dDataBase}"
		cCamposE5 += ",{'E5_DTDISPO', dDataBase}}"
		
		If oModel:VldData()
			oModel:CommitData()
			cCamposE5 := ''
		Else
			cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ])        + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])                  
			Help( ,,"FN89VALID",,cLog, 1, 0 )              
		EndIf
 	oModel:DeActivate()
 	oModel:Destroy()
 	oModel := nil
	Next
	//+----------------------------------------------------------+
	//¦ Genera Pie de asiento Contab. para Baja de Cheques.      ¦
	//+----------------------------------------------------------+
	If nHdlPrv > 0 .and. lLancPad70 //.and. !__TTSInUse
		RodaProva(	nHdlPrv,;
		nTotalLanc)
		//+-----------------------------------------------------+
		//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
		//+-----------------------------------------------------+
		n	:=	1
		lLanctOk := cA100Incl( cArquivo,;
		nHdlPrv,;
		3,;
		cLoteCom,;
		lDigita,;
		lAglutina,;
		/*cOnLine*/,;
		/*dData*/,;
		/*dReproc*/,;
		@aFlagCTB,;
		/*aDadosProva*/,;
		aDiario )
		aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

		If !lLanctOk .And. Len(aREcsSe5) > 0 .AND. !lUsaFlag

			For nA := 1 To Len(aREcsSe5)

				SE5->(DbGoTo(aRecsSE5[nA]))
				oModel := FWLoadModel('FINM010')
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
				oModel:Activate()
				//Atualiza o campo Identifica Lançamento;
				oFKA := oModel:GetModel('FKADETAIL')
			If oFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
				oModel:SetValue( 'FK1DETAIL', 'FK1_MOEDA',SE5->E5_MOEDA)
				oModel:SetValue( 'FK1DETAIL', 'FK1_VENCTO',SE5->E5_VENCTO)
				oModel:SetValue( 'FK1DETAIL', 'FK1_DATA', dDatabase)
				oModel:SetValue( "FK1DETAIL", 'FK1_VALOR' ,SE5->E5_VALOR)							
				oModel:SetValue( "FK1DETAIL", 'FK1_TPDOC' ,SE5->E5_TIPODOC)
				oModel:SetValue( "FK1DETAIL", 'FK1_RECPAG',SE5->E5_RECPAG )
				oModel:SetValue( "FK1DETAIL", 'FK1_MOTBX' ,SE5->E5_MOTBX)
				oModel:SetValue( 'FK1DETAIL', 'FK1_LA', " ")
				
				//
				If oModel:VldData()
					oModel:CommitData()
				Else
					cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
					cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) 				 + ' - '
					cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])        	
					Help( ,,"FN370VL",,cLog, 1, 0 )
				EndIf								
			EndIf
			oModel:DeActivate()
			oModel:Destroy()
			oModel  := nil			
		Next

		EndIf
	Endif

	PcoFinLan("000360")

	DbSelectArea("SE1")
    If !lAutomato
	   Eval( bFiltraBrw )
    EndIF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a089CrTRB ºAutor  ³Bruno Sobieski      º Data ³  12/01/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria arquivo temporario                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function a089CrTRB(cCondicoes,cCondWhile,cAlias,aCampos,cArqTrb,cMarca,lMarca)
	Local nX
	Local nCount	:=	1
	Local nRecno := 0 //Variável utilizada para posicionar no Recno correto. Rep. Dom e Equador

	If Select("TMP089") > 0
		DbSelectArea("TMP089")
		DbCloseArea()
	Endif

	nValorSel := 0

	cArqTrb	:=	CriaTrab(aCampos,.F.)
	oTmpTable := FWTemporaryTable():New("TMP089")
	oTmpTable:SetFields( aCampos )
	oTmpTable:AddIndex("IN1", {"E1_CLIENTE","E1_NUM"})
	oTmpTable:AddIndex("IN2", {"E1_NUM"})
	oTmpTable:Create()

	DbSelectArea(cAlias)

	ProcRegua(Reccount())

	While &cCondWhile
		If FUNNAME()=="FINA096"
			nRecno:= (cAlias)->RECNO
			SE1->(DbGoto(nRecno))
		EndIf
		If &cCondicoes
			IncProc(STR0062+ Alltrim(STR(nCount++)) ) //"Procesando cheque "
			//Carregar todos os campos no TRB menos o RECSE1 pois ele nao existe e o
			//E1_OK pois nao e necesario
			Reclock("TMP089",.T.)
			For nX	:=	2	To Len(aCampos)
				nPosCampo	:=	(cAlias)->(FieldPos(aCampos[nX][1]))
				If nPosCampo	>	0
					TMP089->( FIELDPUT(FieldPos(aCampos[nX][1]),(cAlias)->(FIELDGET(nPosCampo) ) ) )
				Endif
			Next
			If cAlias == "SE1"
				Replace RECSE1	With	SE1->(RECNO())
			Else
				Replace RECSE1	With	(cAlias)->RECNO
			Endif
			If lMarca
				Replace E1_OK	With	cMarca
				nValorSel := nValorSel  + E1_VALOR
			Endif
			MsUnLock()
		Endif
		DbSelectArea(cAlias)
		DbSkip()
	Enddo
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa089VldBoº Autor ³Sergio S. Fuzinaka  º Data ³  20.06.02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o numero dos borderos                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Fina089()                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Fa089VldBor(cBorde,cBorate)
	Local lRet	:=	.T.
	If cBorde > cBorAte
		MsgAlert(STR0072)  //"'De bordero' nao pode ser maior que 'Ate bordero'"
		lRet	:=	.F.
	Endif
	If lRet	.And. cPaisLoc$"URU|BOL" .And. (Empty(cBorDe).Or. Empty(cBorAte))
		MsgAlert(STR0073)  //"Informe os borderos"
		lRet	:=	.F.
	Endif


	If UsaSeqCor()
		cCodDiario := CTBAVerDia()
	Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F089Seq   º Autor ³Sergio S. Fuzinaka  º Data ³  20.06.02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a sequencia numerica do campo E5_SEQ.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Fina089()                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function F089Seq()

	Local aArea := GetArea()
	Local nSeq  := 0
	Local nTamSeq	:= TamSX3("E5_SEQ")[1]

	dbSelectArea("SE5")
	dbSetOrder(7)	//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
	While .T.
		nSeq++
		If !dbSeek(xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+;
		SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA + StrZero(nSeq,nTamSeq))
			Exit
		EndIf
		dbSkip()
	Enddo
	RestArea(aArea)

Return(StrZero(nSeq,nTamSeq))
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F089TipDevº Autor ³Cristiano Denardi   º Data ³  26.09.03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna tipo do titulo para titulo que foi devolvido        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FINA089()                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function F089TipDev( cTipo )

	///////
	// Var:
	Local cRet	:= ""
	Local aArea := GetArea()

	DbSelectArea("SES")
	DbSetOrder(1)
	If DbSeek( xFilial("SES")+Alltrim(cTipo) )
		cRet := Alltrim( SES->ES_REJEITA )
	Endif

	RestArea(aArea)

Return( cRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A089Legend ³ Autor ³ Fernando Machima     ³ Data ³ 11.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA089                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A089Legend()
	Local aLegenda := {	{"ENABLE"		, 	STR0082	},;	 //"Titulo pendente"
	{"DISABLE"		, 	STR0083	},;	 //"Titulo baixado"
	{"BR_PRETO"		, 	STR0037	} }	 //"Cheque rechazado"

	BrwLegenda(cCadastro,STR0076,aLegenda) //"Legenda"

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A089Visual ³ Autor ³ Fernando Machima     ³ Data ³ 11.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Permite a visualizacao do registro selecionado na MBrowse  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA089                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A089Visual()

	Local aAcho    := {}
	Local aArea    := GetArea()

	dbSelectArea("SX3")
	dbSetOrder(1)
	If dbSeek("SE1" + "01", .F.)
		Do While !Eof() .And. X3_ARQUIVO == 'SE1'
			If !(X3USO(x3_usado)  .AND. cNivel >= x3_nivel) .or. AllTrim(X3_CAMPO) == "E1_FILIAL"
				DbSkip()
				Loop
			EndIf

			aAdd(aAcho, X3_CAMPO)
			dbSkip()
		EndDo
	EndIf

	DbSelectArea("SE1")
	If lQuery
		DbGoTo(TRB->RECNOSE1)
	EndIf

	AxVisual("SE1",Recno(),2,aAcho)

	RestArea(aArea)

Return NIL

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A089Pesqui³ Autor ³Fernando Machima       ³ Data ³ 12.08.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para pesquisa                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A089Pesquisa(ExpC1,ExpN1,ExpN2)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Fina089                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A089Pesquisa(cAlias,nReg,nOpcx)

	AxPesqui()
	//Atualiza o browse
	Eval( bFiltraBrw )
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³22/11/06 ³±±
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
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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
	Local aRotina := {{ OemToAnsi(STR0004) , 'A089Buscar(2)', 0 , 1 },; //"Buscar"
	{ OemToAnsi(STR0005) , 'A089Visual()' , 0 , 2 },; //"Visualizar"
	{ OemToAnsi(STR0006) , 'A089Recibe()' , 0 , 4 },; //"Recibir"
	{ OemToAnsi(STR0007) , 'A089Rechaz()' , 0 , 4 },; //"rechaZar"
	{ OemToAnsi(STR0086) , 'A089CanRech()', 0 , 4 },;  //"Anular Rechazo"
	{ OemToAnsi(STR0008) , 'A089Cancel()' , 0 , 4 },; //"Canc.Baja"
	{ OemToAnsi(STR0009) , 'A089AcrAut()' , 0 , 5 },; //"Acred. Auto"
	{ OemToAnsi(STR0076) , 'A089Legend()' , 0 , 2 } }  //"Legenda"
	
	If ExistBlock("A089MENU")
			aRotina	:= ExecBlock("A089MENU",.F.,.F.,{aRotina})
		Endif
Return(aRotina)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LRETCKPG  ºAutor  ³Microsiga           ºFecha ³  06/16/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o codigo do banco corresponde a uma caixa      º±±
±±º          ³ interna.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function lRetCkPG(n,cDebInm,cBanco,nPagar)
	Local lRetCx:=.T.
	If cPaisLoc="PER"
		If n==3
			If cBanco $ (Left(GetMv("MV_CXFIN"),TamSX3("A6_COD")[1])+"/"+GetMv("MV_CARTEIR"))  .or. IsCaixaLoja(cBanco)
				lRetCx:=.F.
			Endif
		Endif
	Endif
Return(lRetCx)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ISCXLOJA  ºAutor  ³Microsiga           ºFecha ³  06/16/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria uma string com os codigos de caixas do sigaloja para  º±±
±±º          ³ use em consultas.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IsCxLoja()
	
	Local cStringCX	:=""
	Local cAlias	:= Alias()
LOcal ntamSEF:=Len(SEF->EF_NUM)

	dbSelectArea("SX5")
	dbSeek(xFilial("SX5") + "23")

	While !Eof() .and. X5_TABELA == "23"
		cStringCX+=Substr(X5_CHAVE,1,3)
		dbSkip()
		cStringCX+="/"
	Enddo

	dbSelectArea(cAlias)
	
Return cStringCX
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A089GRVºAutor  ³Microsiga           ºFecha ³  04/07/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de gravação utilizada no FINA096					  º±± 
±±º          ³ use em consultas.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A089GRV()
Local aArea:=GetArea()


If FUNNAME()=="FINA096" .And. TYPE(“cIndexKey1”) <>"U"
	IndRegua("TMP089", cArqTrb,cIndexKey1)
EndIf
TMP089->(DBSeek(cMarcaE1))
ProcRegua(RecCount() )

Do while TMP089->(!EOF())
	IncProc()
	cCamposE5:=""
	//O lInverte nao e compativel com a RDSELECT
	If E1_OK == cMarcaE1
		
		SE1->(DbGoTo(TMP089->RECSE1))
		RecLock("SE1",.F.)
		SE1->E1_BAIXA := dDatabase
		SE1->E1_SALDO := 0.00
		SE1->E1_STATUS := "B"
		SE1->E1_MOVIMEN:= dDataBase
		MsUnlock()	

		oModel := FWLoadModel('FINM010') //Baixas a receber.
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
		oModel:SetValue( "MASTER", "NOVOPROC", .T. )//Informa que a inclusão será feita com um novo número de processo
		//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
		cCamposE5 += "{{'E5_DTDIGIT'	,dDataBase}"
		cCamposE5 += ",{'E5_TIPO'		,SE1->E1_TIPO}"
		cCamposE5 += ",{'E5_PREFIXO'	,SE1->E1_PREFIXO}"
		cCamposE5 += ",{'E5_NUMERO'		,SE1->E1_NUM}"
		cCamposE5 += ",{'E5_PARCELA'	,SE1->E1_PARCELA}"
		cCamposE5 += ",{'E5_CLIFOR'		,SE1->E1_CLIENTE}"
		cCamposE5 += ",{'E5_LOJA'		,SE1->E1_LOJA}"
		cCamposE5 += ",{'E5_BENEF'		,SE1->E1_NOMCLI}"

		If cPaisloc $ "ARG|CHI|URU|PAR"
			cCamposE5 += ",{'E5_FILORIG'    ,SE1->E1_FILORIG}"
		Endif
		
		If FunName() $ "FINA096"
		cCamposE5 += ",{'E5_DOCUMEN'	,SE1->E1_NUMBOR}"
			cCamposE5 += ",{'E5_BCOCHQ'	,SE1->E1_BCOCHQ}"
			cCamposE5 += ",{'E5_AGECHQ'	,SE1->E1_AGECHQ}"
			cCamposE5 += ",{'E5_CTACHQ'	,SE1->E1_CTACHQ}"
		EndIf
		cCamposE5 += ",{'E5_DTDISPO'	, dDataBase}}"
		//FK7 x SE1.
		cChaveTit := xFilial("SE1")  + "|" +  SE1->E1_PREFIXO + "|" + SE1->E1_NUM 			+ "|" +;
			SE1->E1_PARCELA + "|" +  SE1->E1_TIPO 		+ "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
		cIdDoc := FINGRVFK7("SE1", cChaveTit)
		//
		oFKA := oModel:GetModel('FKADETAIL')
		oFK1 := oModel:GetModel('FK1DETAIL')
		oFK5 := oModel:GetModel('FK5DETAIL')
		//Cria FKA x FK1
		oFKA:SetValue('FKA_IDORIG', FWUUIDV4())
		oFKA:SetValue('FKA_TABORI','FK1')
		//
		
		oFK1:SetValue('FK1_RECPAG', 'R')
		oFK1:SetValue('FK1_HISTOR', OemToAnsi(STR0029))
		oFK1:SetValue('FK1_MOTBX' , 'NOR')
		oFK1:SetValue('FK1_DATA'  , dDataBase) 
		oFK1:SetValue('FK1_VENCTO', dDataBase)
		oFK1:SetValue('FK1_NATURE', SE1->E1_NATUREZ)
		oFK1:SetValue('FK1_TPDOC' , If(lBordero .Or. SE1->E1_SITUACA $ cLstDesc,"BA","VL"))
		oFK1:SetValue('FK1_MOEDA' , StrZero(Max(SA6->A6_MOEDA,1),2))
		oFK1:SetValue('FK1_VALOR' , xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,Max(SA6->A6_MOEDA,1)))
		oFK1:SetValue('FK1_VLMOE2', SE1->E1_VALOR)
		oFK1:SetValue('FK1_SERREC', SE1->E1_SERREC)
		oFK1:SetValue('FK1_ORDREC', SE1->E1_RECIBO)
		oFK1:SetValue('FK1_SEQ'   , F089Seq())
		oFK1:SetValue('FK1_IDDOC' , cIdDoc)
		
		
		//
		If oFK1:GetValue('FK1_TPDOC') == 'VL'
			//Cria FKA x FK5.
			oFKA:AddLine()
			oFKA:SetValue('FKA_IDORIG',FWUUIDV4())
			oFKA:SetValue('FKA_TABORI','FK5')
			//
			oFK5:SetValue('FK5_BANCO' ,SE1->E1_PORTADO)
			oFK5:SetValue('FK5_AGENCI',SE1->E1_AGEDEP)
			oFK5:SetValue('FK5_CONTA' ,SE1->E1_CONTA)
			//Outros valores serão gravados dentro do modelo com base na FK1.
			FINGrvFK5(oModel, 'FK1')			
		EndIf
		
		oModel:SetValue('MASTER','E5_CAMPOS', cCamposE5)
		oModel:SetValue('MASTER','E5_GRV'		, .T.)
		//
		If oModel:VldData()
			oModel:CommitData()
		Else
			cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) 				 + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])
			Help( ,,"FN89VALID",,cLog, 1, 0 )
		EndIf
		oModel:DeActivate()
		oModel:Destroy()
		oModel :=  nil
		If FunName() == "FINA096"
			
			aAreaSEF:=SEF->(GetArea())
			cFiltroSEF := ""
			cFiltroSEF := SEF->(DbFilter())
			SEF->(DbClearFilter())
			SEF->(DbSetOrder(6))
			If SEF->(DbSeek(xFilial("SEF")+"R"+SE1->E1_BCOCHQ+SE1->E1_AGECHQ+SE1->E1_CTACHQ+PADR(SUBSTR(SE1->E1_NUM,1,Len(SEF->EF_NUM)),Len(SEF->EF_NUM)," ")+SE1->E1_PREFIXO))
				RecLock("SEF",.F.)
				SEF->EF_DATAPAG	:= dDataBase
				SEF->EF_REFTIP		:= "LR"
				SEF->EF_STATUS		:= "04"
				SEF->(MsUnLock())
				DbSelectArea("FRF")
				cSeqFRF := GetSx8Num("FRF","FRF_SEQ")
				RecLock("FRF",.T.)
				FRF->FRF_FILIAL		:= xFilial("FRF")
				FRF->FRF_BANCO		:= SEF->EF_BANCO
				FRF->FRF_AGENCIA	:= SEF->EF_AGENCIA
				FRF->FRF_CONTA		:= SEF->EF_CONTA
				FRF->FRF_NUM		:= SEF->EF_NUM
				FRF->FRF_PREFIX		:= SEF->EF_PREFIXO
				FRF->FRF_CART		:= "R"
				FRF->FRF_DATPAG		:= dDataBase
				FRF->FRF_MOTIVO		:= "10"
				FRF->FRF_DESCRI		:= "CHEQUE COMPENSADO"
				FRF->FRF_SEQ		:= cSeqFRF
				FRF->(MsUnLock())
				ConfirmSX8()
			Endif
			If !Empty(cFiltroSEF)
				SEF->(DbSetfilter({||&cFiltroSEF},cFiltroSEF))
			EndIf
			SEF->(RestArea(aAreaSEF))
		Endif
		// Se Portugal, alimenta aDiario
		If UsaSeqCor()
			AADD(aDiario,{"SE5",SE5->(recno()),cCodDiario,"E5_NODIA","E5_DIACTB"})
		endif
		If cPaisLoc <> "BRA" .AND. FUNNAME()=="FINA096"
			
			nValor:=xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1)
			nPosCli	:=	AScan(aCliente,{|X| x[1]+x[2] ==xFilial("SE1")+SE1->E1_CLIENTE+SE1->E1_LOJA + SE1->E1_TIPO})
			If nPosCli	== 0
				AAdd(aCliente,{xFilial("SE1")+SE1->E1_CLIENTE+SE1->E1_LOJA,SE1->E1_TIPO,nValor,SE1->E1_EMISSAO})
			Else
				aCliente[nPosCli][3]+=	nValor
			Endif
			
			
			nPosBco	:=	AScan(aBanco,{|X| x[1] ==SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA})
			If nPosBco	== 0
				AAdd(aBanco,{xFilial("SA6")+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA,SE5->E5_VALOR})
			Else
				aBanco[nPosBco][2]+=	SE5->E5_VALOR
			Endif
			
		Else
			SA6->(DbSetOrder(1))
			SA6->(DbSeek(xFilial()+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA))
			AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,dDataBase,SE5->E5_VALOR,"+")
			
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA))
			AtuSalDup("-",SE1->E1_VALOR,SE1->E1_MOEDA,SE1->E1_TIPO,,SE1->E1_EMISSAO)
		EndIf
		// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// ³  Ponto de Entrada para gravar campos de Usuário em SE5        ³
		// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("F089ATU")
			ExecBlock("F089ATU",.F.,.F.)
		EndIf
		
		// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// ³  SI ES LA PRIMER BAJA DE LA SERIE DE BAJAS, CHEQUEO SI EXISTE EL      ³
		// ³  ASIENTO PADRONIZADO Y GENERO EL ENCABEZADO DEL ASIENTO SI ES VERDAD  ³
		// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cPadrao  := Fa070Pad()
		
		If lGeraLanc
			lLancPad70  := VerPadrao(cPadrao)
		Else
			lLancPad70	:= .F.
		EndIf
		If lPrim
			If lLancPad70 //.and. !__TTSInUse
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona numero do Lote para Lancamentos do Financeiro      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SX5")
				dbSeek(xFilial()+"09FIN")
				cLoteCom:=IIF(Found(),Trim(X5_DESCRI),"FIN")
				nHdlPrv:=HeadProva( cLoteCom,;
					"FINA089",;
					Subs(cUsuario,7,6),;
					@cArquivo)
				If nHdlPrv <= 0
					Help(" ",1,"A100NOPROV")
				EndIf
			EndIf
			lPrim	:=	.F.
		Endif
		
		If nHdlPrv > 0 .and. lLancPad70 //.and. !__TTSInUse
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Genera Items de asiento Contab. para Baja de Cheques.    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLancPad70
				SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
				SA6->(DbSeek(xFilial("SA6")+SE1->E1_PORTADOR+SE1->E1_AGEDEP+SE1->E1_CONTA))
				nTotalLanc += DetProva( nHdlPrv,;
					cPadrao,;
					"FINA089",;
					cLoteCom,;
					@nLinha,;
					/*lExecuta*/,;
					/*cCriterio*/,;
					/*lRateio*/,;
					/*cChaveBusca*/,;
					/*aCT5*/,;
					/*lPosiciona*/,;
					@aFlagCTB,;
					/*aTabRecOri*/,;
					/*aDadosProva*/ )
				
				If lUsaFlag .and. Funname() == "FINA096" .AND. cPAISLOC == "ARG"  // Armazena em aFlagCTB para atualizar no modulo Contabil
					aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
					oModel := FWLoadModel('FINM010')
					oModel:SetOperation( MODEL_OPERATION_UPDATE )
					oModel:Activate()
					oFKA := oModel:GetModel('FKADETAIL')
					oFKA:SeekLine( { {"FKA_TABORI", "FK1" } } )			
					oModel:SetValue( 'FK1DETAIL', 'FK1_LA', "S")
					oFKA:SeekLine( { {"FKA_TABORI", "FK5" } } )
					oModel:SetValue( 'FK5DETAIL', 'FK5_LA', "S")
					If	oModel:VldData()
						oModel:CommitData()								
					Else
						cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
						cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) + ' - '
						cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])
						Help( ,,"FN370VL",,cLog, 1, 0 )
					EndIf
				Elseif lUsaFlag
					aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} ) 	
				Else							
					oModel := FWLoadModel('FINM010')
					oModel:SetOperation( MODEL_OPERATION_UPDATE )
					oModel:Activate()
					//Atualiza o campo Identifica Lançamento;
					oFKA := oModel:GetModel('FKADETAIL')				
					If Funname() == "FINA096" .AND. cPAISLOC == "ARG" 
						If oFKA:SeekLine( { {"FKA_TABORI", "FK1" } } )			
							oModel:SetValue( 'FK1DETAIL', 'FK1_LA', "S")
							oFKA:SeekLine( { {"FKA_TABORI", "FK5" } } )
							oModel:SetValue( 'FK5DETAIL', 'FK5_LA', "S")
							If oModel:VldData()
								oModel:CommitData()
								Reclock("SE5")
								REPLACE E5_LA With "S"
								MsUnlock()
							Else
								cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
								cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) + ' - '
								cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])
								Help( ,,"FN370VL",,cLog, 1, 0 )
							EndIf
						Else
							cLog := "TABELA NÃO ENCONTRADA  -  FK1" 
							Help( ,,"FN370VL",,cLog, 1, 0 )
						Endif	
						oModel:DeActivate()
						oModel:Destroy()
						oModel := nil
						Aadd(aRecsSe5,SE5->(Recno()))
					ELSE					
						If oFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )				
							oModel:SetValue( 'FK1DETAIL', 'FK1_LA', "S")
						
							If oModel:VldData()
								oModel:CommitData()
								Reclock("SE5")
								REPLACE E5_LA With "S"
								MsUnlock()
							Else
								cLog := cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
								cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_ID ]) + ' - '
								cLog += cValToChar(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])
								Help( ,,"FN370VL",,cLog, 1, 0 )
							EndIf
						Else
							cLog := STR0059 +  SE5->E5_IDORIG
							Help( ,,"FN370VL",,cLog, 1, 0 )
						Endif	
						oModel:DeActivate()
						oModel:Destroy()
						oModel := nil
						Aadd(aRecsSe5,SE5->(Recno()))
					ENDIF
				EndIf
			Endif
			If cPAISLOC$"PER|BOL"
				If lFindITF .And. FinProcITF( SE5->(Recno()),1 ) .AND. lRetCkPG(3,,SE5->E5_BANCO)
					FinProcITF( SE5->(Recno()),3,SE5->E5_VALOR, .F.,{nHdlPrv,cPadrao,"FINA089","FINA089",cLotecom},)
				EndIf
			EndIf
		Else
			If cPAISLOC$"PER|BOL"
				If lFindITF .And. FinProcITF( SE5->(Recno()),1 ) .AND. lRetCkPG(3,,SE5->E5_BANCO)
					FinProcITF( SE5->(Recno()),3,SE5->E5_VALOR, .F.)
				EndIf
			EndIf
		Endif
		
		PcoDetLan("000360","01","FINA089",.F.)//BAJA LOS TITULOS RECIBIDOS DEL BANCO
		
	Endif
	DbSelectArea("TMP089")
	TMP089->(DbSkip())
Enddo

RestArea(aArea)

Return	
