#INCLUDE "OMSA341.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE FIN_VLRTIT      1   //Valor do Titulo
#DEFINE FIN_VLRABT      2   //Abatimento
#DEFINE FIN_VLRPRC      3   //Parcial
#DEFINE FIN_VLRDEC      4   //Decrescimo
#DEFINE FIN_VLRACR      5   //Acrescimo
#DEFINE FIN_VLRSLD      6   //Saldo do Titulo
#DEFINE FIN_VLRSLM      7   //Saldo do Titulo na moeda
#DEFINE FIN_VLRJRS      8   //Juros
#DEFINE FIN_VLRDES      9   //Desconto
#DEFINE FIN_VLRCRM      10  //Correcao Monetaria
#DEFINE FIN_VLRVRT      11  //Valor a ser Recebido na moeda do titulo
#DEFINE FIN_VLRVRM      12  //Valor a ser Recebido na moeda corrente

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicoes do array de geracao de titulos para o motorista³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE COB_CODIGO      1
#DEFINE COB_SEQUEN      2
#DEFINE COB_CODMOT      3
#DEFINE COB_CODFOR      4
#DEFINE COB_LOJA        5
#DEFINE COB_NOME        6
#DEFINE COB_PREFIX      7
#DEFINE COB_NATUR       8
#DEFINE COB_TIPO        9
#DEFINE COB_VALOR       10

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicoes da getdados de liquidacao na prestacao de contas              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE LQ_PREFIXO      1
#DEFINE LQ_BANCO        2
#DEFINE LQ_AGENCIA      3
#DEFINE LQ_CONTA        4
#DEFINE LQ_NUMERO       5
#DEFINE LQ_DATA         6
#DEFINE LQ_VALOR        7
#DEFINE LQ_STATUS       8

#DEFINE OMSA34101 "OMSA34101"
#DEFINE OMSA34102 "OMSA34102"
#DEFINE OMSA34103 "OMSA34103"
#DEFINE OMSA34104 "OMSA34104"

Static __oTempSE1 := Nil // Tabela Temporária de Títulos
Static __oTempCPS := Nil // Tabela Temporária de Compensação
Static __oTempPRC := Nil // Tabela Temporária de Processamento
Static __cAliTRB  := ""
Static __cAliCPS  := ""
Static __cAliPRC  := ""
Static __aIdxTRB  := {}
Static __aIdxCPS  := {}
Static __aIdxPRC  := {}
Static __aCampos  := {}
Static __aCpoBrw  := {}
Static __SDesc    := 0 //-- levar o valor de desconto para calculo Oms341End
Static __cFilCar  := ""

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMSA341   ³ Autor ³ Henry Fila            ³ Data ³14.11.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de Prestacao de contas da Carga                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo realizar a prestacao de contas ³±±
±±³          ³financeira de uma determinada carga gerada e faturada        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMSA341()
Local oBrowse := Nil
Local cCondicao := "DAK_FILIAL = '"+xFilial("DAK")+"' AND DAK_FEZNF = '1' AND DAK_ACECAR = '1'"

Private cCadastro := OemToAnsi(STR0077) // "Prestar Títulos"

	__cFilCar := cFilAnt // Tratamento para OMS OL

	If ExistBlock("OS341TNF")
		ExecBlock("OS341TNF",.F.,.F.,{"I"})
	EndIf

	If ExistBlock("OS341BRW")
		ExecBlock("OS341BRW",.F.,.F.)
	EndIf
	
	If ExistBlock("OM341CND")
		cCondicao += ExecBlock("OM341CND",.F.,.F.)
	EndIf
	

	Pergunte("OMS341",.F.)

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("DAK")                       // Alias da tabela utilizada
	oBrowse:SetMenuDef("OMSA341")                 // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)               // Descrição do browse "Prestacao de Contas"
	oBrowse:SetFilterDefault("@"+cCondicao)       // Filtro padrão do browse
	oBrowse:SetParam({|| Pergunte("OMS341",.T.)}) // Tecla F12
	oBrowse:AddLegend("DAK_ACEFIN == '2'",'ENABLE' ,STR0029) // "Em aberto"
	oBrowse:AddLegend("DAK_ACEFIN == '3'",'YELLOW' ,STR0028) // "Conferida"
	oBrowse:AddLegend("DAK_ACEFIN == '1'",'DISABLE',STR0027) // "Encerrada"
	oBrowse:SetAmbiente(.F.)                      // Desabilita opção Ambiente do menu Ações Relacionadas
	oBrowse:SetWalkThru(.F.)                      // Desabilita opção WalkThru do menu Ações Relacionadas
	oBrowse:SetCheckLoop({|| .T.})
	oBrowse:Activate()

	If ExistBlock("OS341TNF")
		ExecBlock("OS341TNF",.F.,.F.,{"F"})
	EndIf
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
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
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()
Private aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"  OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "Oms341Man" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "Oms341Man" OPERATION 4 ACCESS 0 // "Conferir"
	ADD OPTION aRotina TITLE STR0006 ACTION "Oms341Man" OPERATION 5 ACCESS 0 // "Estornar Conf."
	If cPaisLoc == "BRA"
		ADD OPTION aRotina TITLE STR0007 ACTION "Oms341Cli" OPERATION 3 ACCESS 0 // "Prestar Cliente"
		ADD OPTION aRotina TITLE STR0077 ACTION "Oms341Tit" OPERATION 3 ACCESS 0 // "Prestar Títulos"
	EndIf
	ADD OPTION aRotina TITLE STR0094 ACTION "OMSA341VBx" OPERATION 1 ACCESS 0 // "Status Financeiro"

	If ExistBlock("OMS341MNU")
		ExecBlock("OMS341MNU",.F.,.F.)
	EndIf

Return aRotina

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341MAN ³ Autor ³ Henry Fila            ³ Data ³14.11.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Interface da Conferencia da Prestacao de contas              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de carga                              ³±±
±±³          ³ExpN2: Numero do Registro                                    ³±±
±±³          ³ExpN3: Opcao do aRotina                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo controlar a interface da confe-³±±
±±³          ³rencia da prestacao de contas ( recepcao dos valores )       ³±±
±±³          ³de venda.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Oms341Man(cAlias,nReg,nOpc)

Local aCpoEnable:= { "DAP_CODGRU","DAP_REALIZ", "DAP_INVALI" }
Local aCpoUsr   := {}
Local aFormas   := {}
Local aGet      := {}
Local aInfo     := {}
Local aObjects  := {}
Local aPosObj   := {}
Local aSize     := {}
Local aRecDAP   := {}
Local aTitles   := {    OemtoAnsi(STR0059),; //"Totais"
						RTrim(RetTitle("DA3_COD")),; //"Veiculo"
						RTrim(RetTitle("F2_CARGA"))}  //"Carga"
Local aButtons  := {}
Local aUsButtons:= {}

Local cCaminhao := DAK->DAK_CAMINH
Local cCarga    := DAK->DAK_COD
Local cDescCam  := ""
Local cSeqCar   := DAK->DAK_SEQCAR
Local cMotori   := DAK->DAK_MOTORI
Local cNomeMot  := ""
Local cPlaca    := ""

Local lDelConf  := .T.
Local lProcessa := .T.

Local nMoeda    := 1
Local nPosForma := 0
Local nUsado    := 0
Local dDataGer  := DAK->DAK_DATA

Local nValor    := DAK->DAK_VALOR
Local nPeso     := DAK->DAK_PESO
Local nPtoEnt   := DAK->DAK_PTOENT
Local nOpcA     := 0
Local nX        := 0
Local nCntFor   := 0

Local oDlg

Local cSeek     := ""
Local cWhile    := ""
Local aNoFields := {"DAP_VLRBX"}
Local bCond     := {|| .T.}                     // Se bCond .T. executa bAction1, senao executa bAction2
Local bAction1  := {|| Oms341Rec(@aRecDAP)}     // Retornar .T. para considerar o registro e .F. para desconsiderar
Local bAction2  := {|| .F. }                    // Retornar .T. para considerar o registro e .F. para desconsiderar

Private aHeader   := {}
Private aCols     := {}
Private nTotal    := 0
Private nTotalDev := 0
Private nTotalDig := 0
Private nTotalDif := 0
Private aRotina   := MenuDef()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para adicionar botoes na EnchoiceBar         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  ExistBlock( "OMS341BC" )
		aUsButtons := ExecBlock( "OMS341BC", .F., .F. )
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf

	If  nOpc == 3 //-- Conferir
		If  DAK->DAK_ACEFIN == "1"
			Help(" ",1,"OMS341JAEN") //Carga já encerrada para alteração de conferencia.
			lProcessa := .F.
		EndIf
	EndIf

	//-- Ponto de entrada para permitir editar campos especificos.
	If  ExistBlock("OM341CPO")
		aCpoUsr := ExecBlock("OM341CPO",.F.,.F.)
		If  ValType(aCpoUsr) == "A"
			For nX := 1 To Len(aCpoUsr)
				aAdd(aCpoEnable,aCpoUsr[nX])
			Next
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trava o registro da Carga                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  SoftLock("DAK") .And. lProcessa
		//-- Verifica as formas de pagamento da Carga
		aFormas := OsFormasPg(cCarga,cSeqCar,nMoeda)
		If  nOpc <> 2
			If  Len(aFormas) == 0
				lProcessa := .F.
				If  nOpc == 3
					If  MsgYesNo(STR0079) //"Esta carga nao possui titulos a serem prestados. Deseja encerra-la ?"
						OsAvalDAK("DAK",9)
					EndIf
				Else
					If  MsgYesNo(STR0089) //"Esta carga nao possui titulos a serem prestados. Deseja estorna-la ?"
						RecLock("DAK",.F.)
							DAK->DAK_ACEFIN := "2"
						MsUnlock()
					EndIf
				EndIf
			EndIf
		EndIf
		If  lProcessa
			//-- DAP - Acerto Financeiro
			dbSelectArea("DAP")
			dbSetOrder(1)
			MsSeek(xFilial("DAP")+DAK->DAK_COD+DAK->DAK_SEQCAR)
			If  nOpc <> 2
				//-- Verifica movimentacao do titulo do motorista caso tenha gerado
				If  DAP->(!Eof())
					dbSelectArea("SE2")
					dbSetOrder(1)
					If  MsSeek(xFilial("SE2")+DAP->DAP_PREFIX+DAP->DAP_NUM+DAP->DAP_PARCEL+DAP->DAP_TIPO)
						lDelConf := FaCanDelCP("SE2","OMSA341")
					EndIf
				EndIf
				//-- DAM - Movimentacao Acerto Financeiro
				dbSelectArea("DAM")
				dbSetOrder(1)
				If  MsSeek(xFilial("DAM")+cCarga+cSeqCar)
					lDelConf := .F.
				EndIf
				If !lDelConf
					Help(" ",1,"OMS341MOV") //"Existem movimentacoes efetuadas nesta carga"
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem do aHeader e aCols                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³FillGetDados( nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, uSeekFor, aNoFields, aYesFields, lOnlyYes,       ³
			//³               cQuery, bMountFile, lInclui )                                                                ³
			//³nOpcx            - Opcao (inclusao, exclusao, etc).                                                         ³
			//³cAlias       - Alias da tabela referente aos itens                                                          ³
			//³nOrder       - Ordem do SINDEX                                                                              ³
			//³cSeekKey     - Chave de pesquisa                                                                            ³
			//³bSeekWhile   - Loop na tabela cAlias                                                                        ³
			//³uSeekFor     - Valida cada registro da tabela cAlias (retornar .T. para considerar e .F. para desconsiderar ³
			//³               o registro)                                                                                  ³
			//³aNoFields    - Array com nome dos campos que serao excluidos na montagem do aHeader                         ³
			//³aYesFields   - Array com nome dos campos que serao incluidos na montagem do aHeader                         ³
			//³lOnlyYes     - Flag indicando se considera somente os campos declarados no aYesFields + campos do usuario   ³
			//³cQuery       - Query para filtro da tabela cAlias (se for TOP e cQuery estiver preenchido, desconsidera     ³
			//³            parametros cSeekKey e bSeekWhiele)                                                              ³
			//³bMountFile   - Preenchimento do aCols pelo usuario (aHeader e aCols ja estarao criados)                     ³
			//³lInclui      - Se inclusao passar .T. para qua aCols seja incializada com 1 linha em branco                 ³
			//³aHeaderAux   -                                                                                              ³
			//³aColsAux     -                                                                                              ³
			//³bAfterCols   - Bloco executado apos inclusao de cada linha no aCols                                         ³
			//³bBeforeCols  - Bloco executado antes da inclusao de cada linha no aCols                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSeek  := xFilial("DAP")+DAK->DAK_COD+DAK->DAK_SEQCAR
			cWhile := "DAP->DAP_FILIAL+DAP->DAP_CARGA+DAP->DAP_SEQCAR"
			FillGetDados(2,"DAP",1,cSeek,{|| &cWhile },{{bCond,bAction1,bAction2}},aNoFields,/*aYesFields*/,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,Inclui,/*aHeaderAux*/,/*aColsAux*/,{|x| OMS341PCol(x,aFormas,lDelConf)},{|x| lDelConf})

			If Len(aCols) == 1 .And. aCols[1][GDFieldPos("DAP_REC_WT")] == 0

				// Monta aCols manualmente pois array aFormas esta aglutionado por forma de pagamento
				aCols := {}
				ADel(aHeader,GDFieldPos("DAP_ALI_WT"))
				ADel(aHeader,GDFieldPos("DAP_REC_WT"))
				ASize(aHeader,Len(aHeader)-2)
				nUsado := Len(aHeader)

				For nX := 1 to Len(aFormas)
					aadd(aCols,Array(nUsado+1))
					For nCntFor := 1 To nUsado
						Do Case
							Case Alltrim(aHeader[nCntFor][2]) == "DAP_CODGRU"
								aCols[Len(aCols)][nCntFor] := aFormas[nX][3]
							Case Alltrim(aHeader[nCntFor][2]) == "DAP_PREVIS"
								aCols[Len(aCols)][nCntFor] := aFormas[nX][5]
								nTotal    += aCols[Len(aCols)][nCntFor]
							Case Alltrim(aHeader[nCntFor][2]) == "DAP_DEVOL"
								aCols[Len(aCols)][nCntFor] := aFormas[nX][6]
								nTotalDev += aCols[Len(aCols)][nCntFor]
							Case Alltrim(aHeader[nCntFor][2]) == "DAP_DIFERE"
								aCols[Len(aCols)][nCntFor] := aFormas[nX][5] - aFormas[nX][6]
							Case Alltrim(aHeader[nCntFor][2]) == "DAP_GRUPO"
								aCols[Len(aCols)][nCntFor] := aFormas[nX][4]
							OtherWise
								aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
						EndCase
					Next nCntFor
					aCols[Len(aCols)][nUsado+1] := .F.
				Next nX
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se houveram devolucoes nao previstas nas formas      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPosForma := Ascan(aFormas,{|x| Alltrim(x[3]) == "" })
				If  nPosForma > 0
					nTotalDev += aFormas[nPosForma][6]
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza total da diferenca do valor digitado                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotalDif := nTotalDig - ( nTotal - nTotalDev )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Interface com o usuario                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lDelConf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Pega campos do SX3                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aadd(aGet,{FWX3Titulo("DAK_COD"   ),X3Picture("DAK_COD"   )})
				aadd(aGet,{FWX3Titulo("DAK_DATA"  ),X3Picture("DAK_DATA"  )})
				aadd(aGet,{FWX3Titulo("DAK_MOTORI"),X3Picture("DAK_MOTORI")})
				aadd(aGet,{FWX3Titulo("DAK_CAMINH"),X3Picture("DAK_CAMINH")})
				aadd(aGet,{FWX3Titulo("DA3_PLACA" ),X3Picture("DA3_PLACA" )})
				aadd(aGet,{FWX3Titulo("DAK_VALOR" ),X3Picture("DAK_VALOR" )})
				aadd(aGet,{FWX3Titulo("DAK_PESO"  ),X3Picture("DAK_PESO"  )})
				aadd(aGet,{FWX3Titulo("DAK_PTOENT"),X3Picture("DAK_PTOENT")})
				aadd(aGet,{FWX3Titulo("DAP_DEVOL" ),X3Picture("DAP_DEVOL" )})

				dbSelectArea("DA4")
				dbSetOrder(1)
				If MsSeek(xFilial("DA4")+cMotori)
					cNomeMot := DA4->DA4_NOME
				EndIf

				dbSelectArea("DA3")
				dbSetOrder(1)
				If MsSeek(xFilial("DA3")+cCaminhao)
					cDescCam := DA3->DA3_DESC
					cPlaca   := DA3->DA3_PLACA
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calcula tamanho da tela dimensionando os objetos              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aSize := MsAdvSize()
				AAdd( aObjects, { 100, 020, .T., .F. } )
				AAdd( aObjects, { 100, 100, .T., .T. } )
				AAdd( aObjects, { 000, 075, .T., .F. } )
				aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
				aPosObj := MsObjSize( aInfo, aObjects,.T.)

				DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0001)From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL //"Prestacao de contas"

					@ aPosObj[1][1]+05,aPosObj[1][2] SAY aGet[1][1] SIZE 50,7 OF oDlg PIXEL
					@ aPosObj[1][1]+05,aPosObj[1][2]+30 MsGet cCarga PICTURE aGet[1][2] WHEN .F. SIZE 35,7 OF oDlg PIXEL

					@ aPosObj[1][1]+05,aPosObj[1][2]+85  SAY aGet[2][1] SIZE 50,7 OF oDlg PIXEL
					@ aPosObj[1][1]+05,aPosObj[1][2]+105 MsGet dDataGer PICTURE aGet[1][2] WHEN .F. SIZE 50,7 OF oDlg PIXEL

					oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"Oms341LOk()","Oms341TOk()",,.T.,aCpoEnable,1,,9999,,,,'Oms341Ace')

					oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitles,{"","","","",""},oDlg,,,, .T., .F.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1],)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Cria folders do rodape na digitacao da conferencia            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					oFolder:aDialogs[1]:oFont := oDlg:oFont

					@ 5,005 SAY OemtoAnsi(STR0009) SIZE 50,7  Of oFolder:aDialogs[1] PIXEL  //"Valor Total"
					@ 5,045 MsGet oTotal VAR nTotal PICTURE "@E 99,999,999.99" WHEN .F. SIZE 50,7 Of oFolder:aDialogs[1] PIXEL

					@ 5,115 SAY aGet[9][1] SIZE 50,7 OF oFolder:aDialogs[1] PIXEL
					@ 5,158 MsGet oTotalDev VAR nTotalDev PICTURE aGet[7][2] WHEN .F. SIZE 50,7 OF oFolder:aDialogs[1] PIXEL

					@ 25 ,11  TO 26 ,400 LABEL '' OF oFolder:aDialogs[1] PIXEL

					@ 35,005 SAY OemtoAnsi(STR0010) SIZE 50,7  Of oFolder:aDialogs[1] PIXEL //"Valor Conferido"
					@ 35,045 MsGet oTotalDig VAR nTotalDig PICTURE "@E 99,999,999.99" WHEN .F. SIZE 50,7 Of oFolder:aDialogs[1] PIXEL

					@ 35,115 SAY OemtoAnsi(STR0011) SIZE 50,7  Of oFolder:aDialogs[1] PIXEL //"Diferenca"
					@ 35,158 MsGet oTotalDif VAR nTotalDif PICTURE "@E 99,999,999.99" WHEN .F. SIZE 50,7 Of oFolder:aDialogs[1] PIXEL


					oFolder:aDialogs[2]:oFont := oDlg:oFont

					@ 05,005 SAY aGet[3][1] SIZE 50,7 OF oFolder:aDialogs[2] PIXEL
					@ 05,035 MsGet cMotori PICTURE aGet[3][2] WHEN .F. SIZE 35,7 Of oFolder:aDialogs[2] PIXEL
					@ 05,075 MsGet cNomeMot PICTURE "@!" WHEN .F. SIZE 90,7 OF oFolder:aDialogs[2] PIXEL

					@ 20,005 SAY aGet[4][1] SIZE 50,7 OF oFolder:aDialogs[2] PIXEL
					@ 20,035 MsGet cCaminhao PICTURE aGet[4][2] WHEN .F. SIZE 35,7 OF oFolder:aDialogs[2] PIXEL
					@ 20,075 MsGet cDescCam PICTURE "@!" WHEN .F. SIZE 90,7 OF oFolder:aDialogs[2] PIXEL

					@ 35,005 SAY aGet[5][1] SIZE 50,7 OF oFolder:aDialogs[2] PIXEL
					@ 35,035 MsGet cPlaca PICTURE aGet[5][2] WHEN .F. SIZE 35,7 Of oFolder:aDialogs[2] PIXEL


					oFolder:aDialogs[3]:oFont := oDlg:oFont

					@ 05,005 SAY aGet[6][1] SIZE 50,7 OF oFolder:aDialogs[3] PIXEL
					@ 05,035 MsGet nTotal PICTURE aGet[6][2] WHEN .F. SIZE 50,7 Of oFolder:aDialogs[3] PIXEL

					@ 05,095 SAY aGet[9][1] SIZE 50,7 OF oFolder:aDialogs[3] PIXEL
					@ 05,135 MsGet nTotalDev PICTURE aGet[7][2] WHEN .F. SIZE 50,7 OF oFolder:aDialogs[3] PIXEL

					@ 20,005 SAY aGet[8][1] SIZE 50,7 OF oFolder:aDialogs[3] PIXEL
					@ 20,035 MsGet nPtoEnt PICTURE aGet[8][2] WHEN .F. SIZE 50,7 OF oFolder:aDialogs[3] PIXEL

					@ 20,095 SAY aGet[7][1] SIZE 50,7 OF oFolder:aDialogs[3] PIXEL
					@ 20,135 MsGet nPeso PICTURE aGet[7][2] WHEN .F. SIZE 50,7 OF oFolder:aDialogs[3] PIXEL



				ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(oGetd:TudoOk() .And. Oms341Cob(nTotalDif,nOpc-2) ,(nOpcA := 1,oDlg:End()),nOpcA := 0)},{||nOpcA:= 0,oDlg:End()},, aButtons )
				If nOpcA == 1 .And. nOpc <> 2
					Begin Transaction
						Oms341Grv(nOpc-2,cCarga,cSeqCar,nTotalDif,aRecDAP)
						While __lSx8
							ConfirmSx8()
						EndDo
						EvalTrigger()
					End Transaction

					If ExistBlock("OMS341CF")
						ExecBlock("OMS341CF",.F.,.F.,{cCarga,cSeqCar})
					EndIf

				EndIf
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura a integridade da rotina                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsUnLockAll()

Return(nOpcA)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341GRV ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de gravacao da conferencia do lote                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Opcao da gravacao  (Conferencia / Exclusao)           ³±±
±±³          ³       [1] Inclusao/Alteracao                                ³±±
±±³          ³       [2] Exclusao                                          ³±±
±±³          ³ExpC2: Numero da Carga                                       ³±±
±±³          ³ExpC3: Sequencia da Carga                                    ³±±
±±³          ³ExpN4: Diferenca entre prevista x realizado                  ³±±
±±³          ³ExpA5: Array com os registros do DAP                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como gravar a confencia do lote de acordo    ³±±
±±³          ³com as opcoes do aRotina                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341Grv(nOpcao,cCarga,cSeqcar,nTotalDif,aRegNo)
Local cFilCp    := ""
Local cPrefixo  := ""
Local cParcela  := ""
Local cNumero   := ""
Local cTipo     := ""
Local cCliFor   := ""
Local cLoja     := ""
Local aAreaDAP  := DAP->(GetArea())
Local aAreaDAK  := DAK->(GetArea())
Local aArea     := GetArea()
Local lGravou   := .F.
Local lTravou   := .F.
Local nX        := 0
Local nY        := 0
Local nToler    := (GetNewPar("MV_OSTLMOT",0)) //-- Tolerancia para que seja gerada a cobranca contra o motorista
Local cCodUsr   := RetCodUsr()

	Do Case
		Case nOpcao == 1
			For nX := 1 To Len(aCols)
				lTravou := .F.
				If nX <= Len(aRegNo)
					dbSelectArea("DAP")
					dbGoto(aRegNo[nX])
					RecLock("DAP")
					lTravou := .T.
				EndIf
				If ( !aCols[nX][Len(aHeader)+1] )
					If !lTravou
						RecLock("DAP",.T.)
					EndIf
					For nY := 1 to Len(aHeader)
						If aHeader[nY][10] <> "V"
							DAP->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
						EndIf
					Next nY

					DAP->DAP_FILIAL := xFilial("DAP")
					DAP->DAP_CARGA  := DAK->DAK_COD
					DAP->DAP_SEQCAR := DAK->DAK_SEQCAR
					DAP->DAP_DTACER := dDataBase
					DAP->DAP_USER   := cCodUsr
					DAP->DAP_FILCP  := Iif(!Empty(FwFilial("SE2")),xFilial("SE2"),cFilAnt)

					MsUnLock()
					lGravou := .T.
				Else
					If lTravou
						DAP->(dbDelete())
					EndIf
				EndIf
				MsUnLock()
			Next nX

			//-- Geracao de Cobranca do Motorista
			If nTotalDif*-1 > nToler .And. cPaisLoc = "BRA"
				OsPcCpCob(DAK->DAK_COD,DAK->DAK_SEQCAR,nTotalDif)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Gravo status de apenas conferido                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lGravou
				dbSelectArea("DAK")
				dbSetOrder(1) //DAK_FILIAL+DAK_COD+DAK_SEQCAR
				If MsSeek(xFilial("DAK")+cCarga+cSeqcar)
					RecLock("DAK",.F.)
					DAK->DAK_ACEFIN := "3"
					MsUnlock()
				EndIf
			EndIf

		Case nOpcao == 2

			dbSelectArea("DAP")
			dbSetOrder(1) //DAP_FILIAL+DAP_CARGA+DAP_SEQCAR+DAP_CODGRU
			If MsSeek(xFilial("DAP")+DAK->DAK_COD+DAK->DAK_SEQCAR)

				cFilCp   := DAP->DAP_FILCP
				cPrefixo := DAP->DAP_PREFIXO
				cNumero  := DAP->DAP_NUM
				cParcela := DAP->DAP_PARCELA
				cTipo    := DAP->DAP_TIPO
				cCliFor  := DAP->DAP_FORNECE
				cLoja    := DAP->DAP_LOJA

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grava a tabela de conferencia                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				While ( DAP->(!Eof()) .And. DAP->DAP_FILIAL+DAP->DAP_CARGA+DAP->DAP_SEQCAR == ;
									xFilial("DAP")+DAK->DAK_COD+DAK->DAK_SEQCAR )

					RecLock("DAP")
						dbDelete()
					MsUnLock()
					dbSelectArea("DAP")
					dbSkip()
				EndDo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gravo status em aberto da carga como conferido                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("DAK")
				dbSetOrder(1) //DAK_FILIAL+DAK_COD+DAK_SEQCAR
				If MsSeek(xFilial("DAK")+cCarga+cSeqCar)
					RecLock("DAK",.F.)
					DAK->DAK_ACEFIN := "2"
					MsUnlock()
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Exclui o titulo gerado caso houve diferenca contra o motorista³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				dbSelectArea("SE2")
				dbSetOrder(1) //E2_FILIAL+E2_NATUREZ+E2_NOMFOR+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE
				If MsSeek(OsFilial("SE2",cFilCp)+cPrefixo+cNumero+cParcela+cTipo+cCliFor+cLoja)
					FaAvalSe2(2,"OMSA341")
					FaAvalSe2(3,"OMSA341")

					RecLock("SE2",.F.)
						dbDelete()
					MsUnlock()
				EndIf

			EndIf

			If ExistBlock("OMS341GT")
				ExecBlock("OMS341GT",.F.,.F.)
			EndIf

	EndCase

RestArea(aAreaDAK)
RestArea(aAreaDAP)
RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341ACE ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de atualizacao do rodape da conferencia do lote       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo atualizar o rodape da conferen-³±±
±±³          ³cai do lote                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Oms341Ace()
Local nX       := 0
Local nPosReal := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAP_REALIZ"})

	nTotalDig := 0

	For nX := 1 to Len(aCols)

		If !aCols[nX][Len(aHeader)+1]

			If nX == n .And. ( "DAP_REALIZ" $ ReadVar() )
				nTotalDig += M->DAP_REALIZ
			Else
				nTotalDig += aCols[nX][nPosReal]
			EndIf
		EndIf

	Next

	nTotalDif := nTotalDig - ( nTotal - nTotalDev )

	oTotalDig:Refresh()
	oTotalDif:Refresh()

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341VLD ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de validacao de condicao de pagamento redundante      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. - Nao existe condicao redundante digitada                ³±±
±±³          ³.F. - Existe condicao redundante digitada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo validar se existe condicoes de ³±±
±±³          ³pagamentos redundantes na digitacao da conferencia           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Oms341Vld()
Local nX        := 0
Local nPosForma := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAP_CODGRU"})
Local nUsado    := Len(aHeader)
Local lRet      := .T.

	For nX := 1 to Len(aCols)

		If !aCols[nX][nUsado+1]
			If n != nX
				If ( M->DAP_CODGRU == aCols[nX][nPosForma] )
					Help(" ",1,"OMS341FOR") //"Forma de pagamento ja existente na conferencia."
					lRet := .F.
				EndIf
			EndIf
		EndIf

	Next

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341LOK ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de validacao da linha da conferencia do lote          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. - Nao existe campos obrigatorios em branco               ³±±
±±³          ³.F. - Faltam campos obrigatorioas a serem digitados          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo validar se existe campos obriga³±±
±±³          ³torios em branco no acols;                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMS341LOk()
Local lRet      := .T.
Local nPosForma := AScan(aHeader,{|x| Alltrim(x[2]) == "DAP_CODGRU"})
Local nX        := 0
Local nUsado    := Len(aHeader)+1

	If !aCols[n][nUsado]
		If  Empty(aCols[n][nPosForma])
			Help(" ",1,"OBRIGAT")
			lRet := .F.
		Else
			For nX := 1 to Len(aCols)
				If !aCols[nX][nUsado] .And. nX != n .And. ;
					aCols[nX][nPosForma] == aCols[n][nPosForma]
					Help(" ",1,"M410FORMA") //Forma de pagamento invalida.
					lRet := .F.
				EndIf
			Next
		EndIf
	EndIf

	If  ExistBlock("OMS341LO")
		lRet := ExecBlock("OMS341LO",.F.,.F.)
	EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341TOK ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de validacao da TudoOk - Conferencia                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. - Nao existe campos obrigatorios em branco               ³±±
±±³          ³.F. - Faltam campos obrigatorioas a serem digitados          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo validar a TudoOk.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMS341TOk()
Local lRet := .T.
	If ExistBlock("OMS341TO")
		lRet := ExecBlock("OMS341TO",.F.,.F.)
	EndIf
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341CLI ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de Prestacao de contas da carga                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de carga                              ³±±
±±³          ³ExpN2: Numero do Registro                                    ³±±
±±³          ³ExpN3: Opcao do aRotina                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo realizar a prestacao de contas ³±±
±±³          ³e baixa dos titulos da carga                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Oms341Cli(cAlias,nReg,nOpc)

Local aButtons   := {{"PESQUISA",   { || Oms341Vis() }, OemtoAnsi(STR0017), OemtoAnsi(STR0003) },; //"Visualiza Titulo"###"Visualiza"
					{ "EXCLUIR",    { || Oms341Can(oFolder:nOption,;
												aClientes[nX][2],;
												aClientes[nX][3],;
												cCarga,;
												cSeqCar) },OemtoAnsi(STR0072), OemtoAnsi(STR0037) },; //"Cancelamento da baixa"###"Cancelar"
					{ "SDUPROP",    { || Oms341Pesq(aClientes,;
												@nX,;
												oFolder,;
												DAK->DAK_COD,;
												DAK->DAK_SEQCAR,;
												oMarkCmp,;
												oMarkSE1,;
												oDlg,;
												@cMotBx,;
												@cBanco,;
												@cAgencia,;
												@cConta,;
												@dBaixa,;
												@dDataLiq,;
												@dDtCredito,;
												@nValRec,;
												@nTotRec,;
												@nQtdeTit,;
												@nValTit,;
												@nDescont,;
												@nValJur,;
												@nAbatim,;
												@nPgParc,;
												oSayQtde,;
												oSayVal,;
												oSayRec,;
												1) }, OemtoAnsi(STR0073), OemtoAnsi(STR0002)} } //"Pesquisa Cliente / Fatura"###"Pesquisa"

Local aCpoEnable:= { "DAP_CODGRU", "DAP_REALIZ", "DAP_INVALI" }
Local aCpoLiq   := { "E1_PREFIXO", "E1_BCOCHQ" , "E1_AGECHQ","E1_CTACHQ","E1_NUM","E1_VENCTO","E1_VLCRUZ","E1_EMITCHQ" }
Local aCpoUsr   := {}
Local aDescMotbx:= {}
Local aFormas   := {}
Local aClientes := {}
Local aGet      := {}
Local aMotBx    := ReadMotBx()
Local aPages    := {"HEADER"}
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local nTamBco   := TamSx3("E1_BCOCHQ")[1]
Local nTamAge   := TamSx3("E1_AGECHQ")[1]
Local nTamCta   := TamSx3("E1_CTACHQ")[1]
Local nTamNum   := TamSx3("E1_NUM")[1]
Local aTitles   := {    OemtoAnsi(STR0004),;//"Conferencia"
						OemToAnsi(STR0013),;//Titulos
						OemToAnsi(STR0014),;//"Baixa"
						OemToAnsi(STR0015),;//"Liquidacao"
						OemToAnsi(STR0016) }//"Compensacao"

Local aUser     := {}
Local aHeaderBk := {}
Local aObjBaixa := {}

Local cMotBx    := SuperGetMv("MV_OMSMOT",.F.,"")
Local cBanco    := Padr(SuperGetMv("MV_OMSBCO",.F.,""),Len(SA6->A6_COD))
Local cAgencia  := Padr(SuperGetMv("MV_OMSAGE",.F.,""),Len(SA6->A6_AGENCIA))
Local cConta    := Padr(SuperGetMv("MV_OMSCTA",.F.,""),Len(SA6->A6_NUMCON))

Local cCarga    := DAK->DAK_COD
Local cCaminhao := DAK->DAK_CAMINH
Local cSeqCar   := DAK->DAK_SEQCAR
Local cMotori   := DAK->DAK_MOTORI
Local cCliente  := ""
Local cDescCam  := ""
Local cHistBx   := ""
Local cLoja     := ""
Local cNome     := ""
Local cNomeMot  := ""
Local cPlaca    := ""
Local cRetPE    := ""
Local cBcoAuto  := SuperGetMv("MV_OMSBCO",.F.,"")
Local cAgeAuto  := SuperGetMv("MV_OMSAGE",.F.,"")
Local cCtaAuto  := SuperGetMv("MV_OMSCTA",.F.,"")
Local cMotAuto  := SuperGetMv("MV_OMSMOT",.F.,"")

Local cTpBxCr   := SuperGetMv("MV_OMSBXCR",.F.,"")
Local cTpLiq    := SuperGetMv("MV_OMSBXLQ",.F.,"")
Local cTpCmp    := SuperGetMv("MV_OMSBXCP",.F.,"")

Local dBaixa    := CriaVar("E1_BAIXA")
Local dDataLiq  := CriaVar("E1_BAIXA")

Local dDtCredito:= dDatabase
Local dDataGer  := DAK->DAK_DATA

Local lRetPE    := .T.

Local nValor    := DAK->DAK_VALOR
Local nPeso     := DAK->DAK_PESO
Local nPtoEnt   := DAK->DAK_PTOENT
Local nMoeda    := 1
Local nPosForma := 0
Local nQtdeTit  := 0
Local nValTit   := 0
Local nValJur   := 0
Local nDescont  := 0
Local nAbatim   := 0
Local nPgParc   := 0
Local nTotRec   := 0
Local nQtdCPS   := 0
Local nValCPS   := 0
Local nOpca     := 0
Local nCol1Grp  := 0
Local nLin2Grp  := 0
Local nCol2Grp  := 0
Local nUsado1   := 0
Local nUsado2   := 0
Local nX        := 0
Local nY        := 0
Local nCntFor   := 0
Local nTamCli   := TamSx3("DA7_CLIENT")[1]
Local nTamLoj   := TamSx3("DA7_LOJA")[1]
Local lOMS341CO := ExistBlock("OMS341CO")

Local oDlg      := Nil
Local oQtdeTit  := Nil
Local oValTit   := Nil
Local oDescont  := Nil
Local oValJur   := Nil
Local oAbatim   := Nil
Local oPagParc  := Nil
Local oTotRec   := Nil
Local oSayQtde  := Nil
Local oSayVal   := Nil
Local oSayRec   := Nil
Local oSayQtdCp := Nil
Local oSayValCp := Nil
Local oFontLbl  := Nil
Local oFontGrp  := Nil
Local oGetDad1  := Nil
Local oGetDad2  := Nil

Local cFilBkp   := cFilAnt

Private cSeqTrb341 := "000"
Private aHeader  := {}
Private aCols    := {}
Private aColsSEF := {}
Private aColsCHQ := {}
Private aHeader1 := {}
Private aCols1   := {}
Private aHeader2 := {}
Private aCols2   := {}
Private nValRec  := 0 //-- Var. usada na valid. dos totais dos cheques info na baixa.
Private oMarkCmp := Nil
Private cMarkCmp := ""
Private oMarkSE1 := Nil
Private cMarkSE1 := ""
Private oFolder  := Nil
Private oCbx     := Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Objetos atualizados na Linok() do acols de liquidacao                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private oSayQtdCh
Private oSayValCh

Private nTotal    := 0
Private nTotalDig := 0
Private aRotina   := MenuDef()

DEFINE FONT oFontGrp NAME "Arial" SIZE 6, 15 BOLD
DEFINE FONT oFontLbl SIZE 15,0 BOLD

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para adicionar botoes na EnchoiceBar         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("OMS341BP")
		aUser := ExecBlock("OMS341BP",.F.,.F.)
		For nX := 1 To Len(aUser)
			Aadd(aButtons,aClone(aUser[nX]))
		Next nX
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Travo o registro da carga                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !SoftLock("DAK")
		Return
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se foi feito a conferencia da prestacao de conta    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If DAK->DAK_ACEFIN == "2"
		OmsHelp(STR0101,STR0102,OMSA34103) // "A conferência desta carga ainda não foi realizada." // "Efetue a conferência da carga antes de realizar a baixa dos títulos."
		DAK->(MsUnlock())
		Return
	EndIf

	// A busca de formas de pagamento deve considerar a filial da carga
	cFilAnt := __cFilCar

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se existe contas a receber para o titulo             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFormas    := OsAglForma(cCarga,cSeqCar)
	aClientes  := OsCargaNf(cCarga,cSeqCar)

	// Restaura a filial para a prestação de contas
	cFilAnt    := cFilBkp

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array aHeader.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := {}
	aCols   := {}

	FillGetDados(3,'DAP',,,,,,,,,{|| })

	nUsado1 := Len(aHeader)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona o array no DAP para montar o aCols                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	For nX := 1 to Len(aFormas)

		Aadd(aCols,Array(nUsado1+1))

		For nY := 1 To nUsado1

			Do Case
				Case Alltrim(aHeader[nY][2]) == "DAP_CODGRU"
					aCols[Len(aCols)][nY] := aFormas[nX][1]
				Case Alltrim(aHeader[nY][2]) == "DAP_GRUPO"
					aCols[Len(aCols)][nY] := aFormas[nX][2]
				Case Alltrim(aHeader[nY][2]) == "DAP_PREVIS"
					aCols[Len(aCols)][nY] := aFormas[nX][3]
				Case Alltrim(aHeader[nY][2]) == "DAP_DEVOL"
					aCols[Len(aCols)][nY] := aFormas[nX][4]
				Case Alltrim(aHeader[nY][2]) == "DAP_DIFERE"
					aCols[Len(aCols)][nY] := aFormas[nX][3]- aFormas[nX][4]
				Case Alltrim(aHeader[nY][2]) == "DAP_REALIZ"
					aCols[Len(aCols)][nY] := aFormas[nX][5]
				Case Alltrim(aHeader[nY][2]) == "DAP_VLRBX"
					aCols[Len(aCols)][nY] := aFormas[nX][6]
			Endcase
		Next nX

		aCols[Len(aCols)][nUsado1+1] := .F.

	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza total da diferenca                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aCols) == 0
		Aadd(aCols,Array(nUsado1+1))
		For nCntFor := 1 To nUsado1
			aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
		Next nCntFor
		aCols[Len(aCols)][nUsado1+1] := .F.
	EndIf

	aHeader1 := aClone(aHeader)
	aCols1   := aClone(aCols)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria aHeader do Segundo Folder                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aHeader := {}
	aCols   := {}

	Aadd(aHeader,{RTrim(RetTitle("E1_PREFIXO")),"E1_PREFIXO","!!!",;    //"PREFIXO "
			3,0,"Oms341VProc()","û","C","SE1" } )
	Aadd(aHeader,{RTrim(RetTitle("E1_BCOCHQ")),"E1_BCOCHQ","@!",;       //"BCO. "
			nTamBco,0,"Oms341VProc()","û","C","SE1" } )
	Aadd(aHeader,{RTrim(RetTitle("E1_AGECHQ")),"E1_AGECHQ","@!",;       //"AGENCIA"
			nTamAge,0,"Oms341VProc()","û","C","SE1" } )
	Aadd(aHeader,{RTrim(RetTitle("E1_CTACHQ")),"E1_CTACHQ","@!",;       //"CONTA"
			nTamCta,0,"Oms341VProc()","û","C","SE1" } )
	Aadd(aHeader,{RTrim(RetTitle("E1_NUM")),"E1_NUM","@!",;         //"NRO. CHEQUE"
			nTamNum,0,"Oms341VProc()","û","C","SE1" } )
	Aadd(aHeader,{RTrim(RetTitle("E1_VENCTO")),"E1_VENCTO"," ",;        //"DATA BOA"
			8,0,"Oms341VProc()","û","D","SE1" } )
	Aadd(aHeader,{RTrim(RetTitle("E1_VLCRUZ")),"E1_VLCRUZ","@E 9999,999,999.99",;   //"VALOR"
			14,2,"Oms341VProc()","û","N","SE1" } )
	Aadd(aHeader,{RTrim(RetTitle("DA7_CLIENT")),"DA7_CLIENT","@!",; //"CLIENTE"
			nTamCli,0,"Oms341VProc()","û","C","DA7" } )
	Aadd(aHeader,{RTrim(RetTitle("DA7_LOJA")),"DA7_LOJA","@!",;     //"LOJA"
			nTamLoj,0,"Oms341VProc()","û","C","DA7" } )
	Aadd(aHeader,{RTrim(RetTitle("E1_EMITCHQ")),"E1_EMITCHQ","@!",;
			30,0,"Oms341VProc()","û","C","SE1" } )
	Aadd(aHeader,{RTrim(STR0084),"E1_ADM","@!",;                        //"Sequencia"
			1,0,"Oms341VProc()","û","C","SE1" } )

	aHeaderBk := aClone(aHeader)

	If lOMS341CO
		ExecBlock("OMS341CO", .F., .F.,)
	EndIf

	For nX := 1 to Len(aHeader)
		If Ascan(aHeaderBk,{|x| Alltrim(x[2]) == Alltrim(aHeader[nX][2]) } ) == 0
			Aadd(aCpoLiq,Alltrim(aHeader[nX][2]) )
		EndIf
	Next nX


	nUsado2 := Len(aHeader)
	aCols := Array( 1 , (nUsado2+1) )
	aCols[1,nUsado2+1] := .F.
	For nCntFor := 1 To nUsado2
		aCols[1,nCntFor] := CriaVar(aHeader[nCntFor,2],.T.)
	Next nCntFor

	aHeader2 := aClone(aHeader)
	aCols2   := aClone(aCols)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega modelo dos campos                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aGet,{FWX3Titulo("DAK_COD" ),X3Picture("DAK_COD" )})
	aadd(aGet,{FWX3Titulo("DAK_DATA"),X3Picture("DAK_DATA")})
	aadd(aGet,{FWX3Titulo("A1_COD"  ),X3Picture("A1_COD"  )})

	dbSelectArea("DA4")
	dbSetOrder(1)
	If MsSeek(xFilial("DA4")+cMotori)
		cNomeMot := DA4->DA4_NOME
	EndIf

	dbSelectArea("DA3")
	dbSetOrder(1)
	If MsSeek(xFilial("DA4")+cCaminhao)
		cDescCam := DA3->DA3_DESC
		cPlaca   := DA3->DA3_PLACA
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula tamanho da tela                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize := MsAdvSize()
	AAdd( aObjects, { 100, 020, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 010, .T., .F. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	// Cria as tabelas temporárias de Títulos, Compensação e Processamento
	Oms341Cria()

	//-- Traz a janela novamente de acordo com a qtde de clietes da carga
	If Len(aClientes) > 0
		nX := 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Filtra os dados do acerto para o clientes especificado da carga³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Oms341Trb(1,;
			aClientes[1],;
			DAK->DAK_COD,;
			DAK->DAK_SEQCAR,,,,;
			@cMotBx,;
			@cBanco,;
			@cAgencia,;
			@cConta,;
			@dBaixa,;
			@dDataLiq,;
			@dDtCredito,;
			@nValRec,;
			@nTotRec,;
			@nQtdeTit,;
			@nValTit,;
			@nDescont,;
			@nValJur,;
			@nAbatim,;
			@nPgParc,;
			oSayQtde,;
			oSayVal,;
			oSayRec,;
			.F.,;
			1)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza as variaveis da tela do financeiro                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCliente  := aClientes[1][2]
		cLoja     := aClientes[1][3]
		cNome     := aClientes[1][4]

		cMotBx     := SuperGetMv("MV_OMSMOT",.F.,"")
		cBanco     := Padr(SuperGetMv("MV_OMSBCO",.F.,""),Len(SA6->A6_COD))
		cAgencia   := Padr(SuperGetMv("MV_OMSAGE",.F.,""),Len(SA6->A6_AGENCIA))
		cConta     := Padr(SuperGetMv("MV_OMSCTA",.F.,""),Len(SA6->A6_NUMCON))

		dBaixa    := CriaVar("E1_BAIXA")
		dDataLiq  := CriaVar("E1_BAIXA")
		dDtCredito:= dDatabase
		aMotBx    := ReadMotBx()
		cMotBx    := CriaVar("E1_MOTIVO")
		cHistBx   := OemtoAnsi(STR0012) //"VALOR RECEBIDO"
		nValRec   := 0
		nQtdeTit  := 0
		nValTit   := 0
		nValJur   := 0
		nDescont  := 0
		nAbatim   := 0
		nPgParc   := 0
		nTotRec   := 0

		//-- Ponto de entrada para alterar conteudo padrao da variavel cHistBx no folder da baixa
		If ExistBlock("OM341HIS")
			cRetPE := ExecBlock("OM341HIS",.F.,.F.)
			If ValType(cRetPE) == "C"
				cHistBx := cRetPE
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Zera a opcao de confirmacao de tela                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOpca := 0

		SetEnch(,.F.)
		DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0001)From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL //"Prestacao de Contas"

			@ aPosObj[1][1],aPosObj[1][2] SAY aGet[1][1] SIZE 50,7 OF oDlg PIXEL
			@ aPosObj[1][1],aPosObj[1][2]+30 MsGet cCarga PICTURE aGet[1][2] WHEN .F. SIZE 35,7 OF oDlg PIXEL

			@ aPosObj[1][1],aPosObj[1][2]+85  SAY aGet[2][1] SIZE 50,7 OF oDlg PIXEL
			@ aPosObj[1][1],aPosObj[1][2]+105 MsGet dDataGer PICTURE aGet[1][2] WHEN .F. SIZE 50,7 OF oDlg PIXEL

			@ aPosObj[1][1]+12,aPosObj[1][2] SAY RTrim(RetTitle("A1_COD")) SIZE 50,7 OF oDlg PIXEL  //"Cliente"
			@ aPosObj[1][1]+12,aPosObj[1][2]+30 MsGet aClientes[nX][2] WHEN .F. SIZE 35 ,7 OF oDlg PIXEL
			@ aPosObj[1][1]+12,aPosObj[1][2]+65 MsGet aClientes[nX][3] WHEN .F. SIZE 15 ,7 OF oDlg PIXEL

			@ aPosObj[1][2]+12,aPosObj[1][2]+85 SAY RTrim(RetTitle("A1_NOME")) SIZE 50,7 OF oDlg PIXEL   //"Nome"
			@ aPosObj[1][2]+12,aPosObj[1][2]+105 MsGet aClientes[nX][4] WHEN .F. SIZE 100,7 OF oDlg PIXEL

			@ aPosObj[1][2]+12,(aSize[5]/2)-60 SAY StrZero(nX,3)+"/"+StrZero(Len(aClientes),3) PIXEL OF oDlg FONT oFontLbl

			@ aPosObj[3,1],005 SAY OemToAnsi(STR0023+": ")  SIZE 53,07 OF oDlg PIXEL FONT oFontGrp //"Qtde de Titulos"
			@ aPosObj[3,1],055 SAY oSayQtde Prompt ""       SIZE 40,10 OF oDlg PIXEL FONT oFontGrp

			@ aPosObj[3,1],090 SAY OemToAnsi(STR0024+": ")  SIZE 53,07 OF oDlg PIXEL FONT oFontGrp //"Valor dos Titulos"
			@ aPosObj[3,1],148 SAY oSayVal Prompt ""        SIZE 40,10 OF oDlg PIXEL FONT oFontGrp

			@ aPosObj[3,1],190 SAY OemToAnsi(STR0035+": ")  SIZE 53,07 OF oDlg PIXEL FONT oFontGrp //"Valor a Receber"
			@ aPosObj[3,1],245 SAY oSayRec Prompt ""        SIZE 40,10 OF oDlg PIXEL FONT oFontGrp

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inicializa os objetos zerados                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oSayQtde:SetText(Alltrim(Transform(nQtdeTit,"999999")))
			oSayVal:SetText(Alltrim(Transform(nValTit,"@R 99,999,999.99")))
			oSayRec:SetText(Alltrim(Transform(nTotRec,"@R 99,999,999.99")))

			oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,aPages,oDlg,,,, .T., .F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta folder de Compensacao                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			oMarkCmp := MsSelect():New(__cAliCPS,"TRB_MARCA","E1_SALDO == 0",__aCpoBrw,Nil,Nil,{5,5,aPosObj[2,3]-aPosObj[2,1]-30,aPosObj[2,4]-aPosObj[2,2]-10},,,oFolder:aDialogs[5])

			oMarkCmp:bAval := {||Oms341Chg(@nQtdeTit,;
											@nValTit,;
											@nTotRec,;
											@nValJur,;
											@nDescont,;
											@nAbatim,;
											@nPgParc,;
											@nQtdCps,;
											@nValCps,;
											dDatabase,;
											dDataLiq,;
											cMotBx,;
											nMoeda,;
											oSayQtde,;
											oSayVal,;
											oSayRec,;
											oSayQtdCp,;
											oSayValCp,2)}

			oMarkCmp:oBrowse:lhasMark    := .T.
			oMarkCmp:oBrowse:lCanAllmark := .F.
			cMarkCmp := ThisMark()

			@ aPosObj[2,3]-aPosObj[2,1]-25,005 SAY OemtoAnsi(STR0023+": ")  SIZE 53,07 Of oFolder:aDialogs[5] PIXEL FONT oFontGrp //"Qtde de Titulos"
			@ aPosObj[2,3]-aPosObj[2,1]-25,065 SAY oSayQtdCp Prompt ""      SIZE 40,10 Of oFolder:aDialogs[5] PIXEL FONT oFontGrp

			@ aPosObj[2,3]-aPosObj[2,1]-25,100 SAY OemtoAnsi(STR0024+": ")  SIZE 53,07 Of oFolder:aDialogs[5] PIXEL FONT oFontGrp //"Valor dos Titulos"
			@ aPosObj[2,3]-aPosObj[2,1]-25,165 SAY oSayValCp Prompt ""      SIZE 40,10 Of oFolder:aDialogs[5] PIXEL FONT oFontGrp

			oSayQtdCp:SetText(Alltrim(Transform(0,"999999")))
			oSayValCp:SetText(Alltrim(Transform(0,"@R 99,999,999.99")))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta folder de Liquidacao                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aHeader := aClone(aHeader2)
			aCols   := aClone(aCols2)

			@ 5,005 SAY OemtoAnsi(STR0078) SIZE 50,10 Of oFolder:aDialogs[4] PIXEL //"Data Recebimento"
			@ 5,050 MSGET dDataLiq SIZE 40,10 OF oFolder:aDialogs[4] PIXEL Valid Oms341DtLq(dDataLiq) 
			@ 5,100 BUTTON "CMC7"   SIZE 45,12  Of oFolder:aDialogs[4] PIXEL ACTION OmsCMC7()
			//          MsGetDados(nT , nL,  nB,  nR,                nOpc,   cLinhaOk,   cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
			oGetDad2 := MsGetDados():New(20,5,aPosObj[2,3]-aPosObj[2,1]-30,aPosObj[2,4]-aPosObj[2,2]-10,nOpc,"Oms341LOk2","AllWaysTrue",,.T.,aCpoLiq,1,,,,,,,oFolder:aDialogs[4])
			oGetDad2:oBrowse:lDisablePaint := .T.
			oGetDad2:oBrowse:aColumns[8]:bData := {||aCols[n,8]:=aClientes[nX,2],aCols[n,9]:=aClientes[nX,3],aClientes[nX,2]}
			oGetDad2:oBrowse:aColumns[9]:bData := {||aClientes[nX,3]}

			@ aPosObj[2,3]-aPosObj[2,1]-25,05 SAY OemtoAnsi(STR0055)    SIZE 53,07 Of oFolder:aDialogs[4] PIXEL FONT oFontGrp //"Qtde de cheques :"
			@ aPosObj[2,3]-aPosObj[2,1]-25,65 SAY oSayQtdCh Prompt ""   SIZE 40,10 Of oFolder:aDialogs[4] PIXEL FONT oFontGrp

			@ aPosObj[2,3]-aPosObj[2,1]-25,100 SAY OemtoAnsi(STR0056)   SIZE 53,07 Of oFolder:aDialogs[4] PIXEL FONT oFontGrp //"Valor dos cheques :"
			@ aPosObj[2,3]-aPosObj[2,1]-25,165 SAY oSayValCh Prompt ""  SIZE 40,10 Of oFolder:aDialogs[4] PIXEL FONT oFontGrp

			oSayQtdCh:SetText(Alltrim(Transform(0,"999999")))
			oSayValCh:SetText(Alltrim(Transform(0,"@R 99,999,999.99")))


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Monta folder das baixas                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//-- Array com os motivos da baixa
			If len( aDescMotbx ) == 0
				For nY := 1 to Len(aMotBx)
					If Substr(aMotBx[nY],34,01) == "A" .or. Substr(aMotBx[nY],34,01) == "R"
						AADD( aDescMotbx,Substr(aMotBx[nY],07,10))
					EndIf
				Next
			EndIf

			//-- Ponto de entrada para bloquear alteracao dos campos: Motivo, Banco, Agencia e Conta.
			If ExistBlock("OS341BLQ")
				lRetPE := ExecBlock("OS341BLQ",.F.,.F.)
				If  ValType(lRetPE)<>"L"
					lRetPE := .T.
				EndIf
			EndIf

			//-- Calcula grupos de acordo com a definicao da tela
			nCol1Grp2 := ((aPosObj[2,4]-aPosObj[2,2]-10) / 2) + 5
			nLin2Grp2 := ( aPosObj[2,3]-aPosObj[2,1]-20)
			nCol2Grp2 := ( aPosObj[2,4]-aPosObj[2,2]-10)

			@ 005,005 GROUP oGrp1 TO aPosObj[2,3]-aPosObj[2,1]-20, (aPosObj[2,4]-aPosObj[2,2]-10)/2  LABEL OemToAnsi( STR0085 ) OF oFolder:aDialogs[3] PIXEL //"Dados da Baixa"
			oScroll := TScrollBox():New( oFolder:aDialogs[3], 15, 10,aPosObj[2,3]-aPosObj[2,1]-40,(aPosObj[2,4]-aPosObj[2,2]-40)/2)
			oGrp1:oFont := oFontGrp

			@ 010,010 SAY Rtrim(RetTitle("E1_MOTIVO"))  SIZE 32, 07 OF oScroll PIXEL  //"Motivo
			@ 010,056 COMBOBOX oCbx VAR cMotBx ITEMS aDescMotBx VALID OMS341VMot(cMotBx,@cBanco,@cAgencia,@cConta) WHEN lRetPE SIZE 56, 07 OF oScroll PIXEL

			@ 029,010 SAY RTrim(RetTitle("E5_BANCO"))   SIZE 32, 07 OF oScroll PIXEL //"Banco"
			@ 029,056 MSGET oBanco var cBanco           VALID !MovBcobx(cMotBx, .T.) .Or. CarregaSA6(@cBanco,,,.T.) .Or. Empty(cBanco) WHEN lRetPE .And. MovBcoBx(cMotBx, .T.) SIZE 22, 08 OF oScroll PIXEL F3 "SA6"

			@ 042,010 SAY Rtrim(RetTitle("E5_AGENCIA")) SIZE 32, 07 OF oScroll PIXEL //"Agˆncia"
			@ 042,056 MSGET oAgencia var cAgencia       VALID !MovBcobx(cMotBx, .T.) .Or. CarregaSA6(@cBanco,@cAgencia,,.T.) .Or. Empty(cAgencia) WHEN lRetPE .And. MovBcoBx(cMotBx, .T.) SIZE 35, 08 OF oScroll PIXEL

			@ 055,010 SAY Rtrim(RetTitle("E5_CONTA"))   SIZE 28, 07 OF oScroll PIXEL //"Conta"
			@ 055,056 MSGET oConta var cConta           VALID !MovBcobx(cMotBx, .T.) .Or. CarregaSA6(@cBanco,@cAgencia,@cConta,.T.,,.T.) .Or. Empty(cConta) WHEN lRetPE .And. MovBcoBx(cMotBx, .T.) SIZE 66, 08 OF oScroll PIXEL

			If cPaisLoc == "BRA"
				@ 068,010 SAY STR0083 SIZE 39, 07 OF oScroll PIXEL //"Cheque(s)"
				@ 137,110 BTNBMP RESOURCE "LIQCHECK" SIZE 25, 15 OF oScroll PIXEL Action CadCheqCR(cBanco,cAgencia,cConta,nValRec,dBaixa,1,@aColsSEF) When OmsCadCR(aClientes[1][5][1][1],nQtdeTit) .And. !(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
			EndIf

			@ 081,010 SAY OemToAnsi(STR0018) SIZE 39, 07 OF oScroll PIXEL //"Data Receb."
			@ 081,056 MSGET dBaixa Valid Oms341DtLq(dBaixa) SIZE 43, 08 OF oScroll PIXEL

			@ 094,010 SAY OemToAnsi(STR0019) SIZE 32, 07 OF oScroll PIXEL //"Data Cr‚dito"
			@ 094,056 MSGET dDtCredito SIZE 43, 08 OF oScroll PIXEL Valid (dDtCredito >= dBaixa  .and. DtMovFin(dDtCredito)) .or. GetMv("MV_ANTCRED")

			@ 107,010 SAY OemToAnsi(STR0020) SIZE 32, 07 OF oScroll PIXEL //"Hist.Baixa"
			@ 107,056 MSGET cHistBx SIZE 83, 08 OF oScroll PIXEL Picture "@!"

			@ 122,010 SAY OemToAnsi(STR0021) SIZE 53,07 OF oScroll PIXEL //"Valor Recebido"
			@ 122,056 MSGET oValRec VAR nValRec Valid Oms341VlBx(nValRec,nTotRec,cBanco,cAgencia,cConta,dBaixa,dDtCredito,.T.) SIZE 66, 08 OF oScroll PIXEL Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99"

			@ 005,nCol1Grp2 GROUP oGrp2 TO nLin2Grp2, nCol2Grp2 LABEL OemToAnsi( STR0022 ) OF oFolder:aDialogs[3]  PIXEL //"Dados dos Titulos"

			oGrp2:oFont := oFontGrp

			@ 015,nCol1Grp2+10 SAY OemToAnsi(STR0023)               SIZE 53,07 OF oFolder:aDialogs[3] PIXEL //"Qtde de Titulos"
			@ 015,nCol1Grp2+70 MSGET oQtdeTit VAR nQtdeTit WHEN .F. SIZE 66,10 OF oFolder:aDialogs[3] PIXEL Picture "999999"

			@ 030,nCol1Grp2+10 SAY "(+) " + OemToAnsi(STR0024)      SIZE 53,07 OF oFolder:aDialogs[3] PIXEL //"Valor dos Titulos"
			@ 030,nCol1Grp2+70 MSGET oValTit VAR nValTit WHEN .F.   SIZE 66,10 OF oFolder:aDialogs[3] PIXEL Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99"

			@ 045,nCol1Grp2+10 SAY "(-) " + OemToAnsi(STR0034)      SIZE 53,07 OF oFolder:aDialogs[3] PIXEL //"Abatimentos"
			@ 045,nCol1Grp2+70 MSGET oAbatim VAR nAbatim WHEN .F.   SIZE 66,10 OF oFolder:aDialogs[3] PIXEL Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99"

			@ 060,nCol1Grp2+10 SAY "(-) " + OemToAnsi(STR0091)      SIZE 53,07 OF oFolder:aDialogs[3] PIXEL //"Pagtos. Parciais"
			@ 060,nCol1Grp2+70 MSGET oPagParc VAR nPgParc WHEN .F.  SIZE 66,10 OF oFolder:aDialogs[3] PIXEL Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99"

			@ 075,nCol1Grp2+10 SAY "(-) " + OemToAnsi(STR0025)      SIZE 53,07 OF oFolder:aDialogs[3] PIXEL //"Valor Desconto"
			@ 075,nCol1Grp2+70 MSGET oDescont VAR nDescont WHEN .F. SIZE 66,10 OF oFolder:aDialogs[3] PIXEL Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99"

			@ 090,nCol1Grp2+10 SAY "(+) " + OemToAnsi(STR0026)      SIZE 53,07 OF oFolder:aDialogs[3] PIXEL //"Tx. Permanencia"
			@ 090,nCol1Grp2+70 MSGET oValJur VAR nValJur WHEN .F.   SIZE 66,10 OF oFolder:aDialogs[3] PIXEL Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99"

			nTotRec := nValTit+nValJur-nDescont-nAbatim-nPgParc

			@ 105,nCol1Grp2+10 SAY "(=) " + OemToAnsi(STR0035)      SIZE 53,07 OF oFolder:aDialogs[3] PIXEL //"Valor a Receber"
			@ 105,nCol1Grp2+70 MSGET oTotRec VAR nTotRec WHEN .F.   SIZE 66,10 OF oFolder:aDialogs[3] PIXEL Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99"

			aObjBaixa := {oValTit,oDescont,oValJur,oAbatim,oTotRec}

			//ÚÄÄÄÄÄÄÄ¿
			//³Titulos³
			//ÀÄÄÄÄÄÄÄÙ

			oMarkSE1 :=MsSelect():New(__cAliTRB,"TRB_MARCA","E1_SALDO == 0",__aCpoBrw,Nil,Nil,{5,5,aPosObj[2,3]-aPosObj[2,1]-20,aPosObj[2,4]-aPosObj[2,2]-10},,,oFolder:aDialogs[2])
			oMarkSE1:bAval := {||Oms341Chg( @nQtdeTit,;
											@nValTit,;
											@nTotRec,;
											@nValJur,;
											@nDescont,;
											@nAbatim,;
											@nPgParc,;
											@nQtdCps,;
											@nValCps,;
											dDatabase,;
											dDataLiq,;
											cMotBx,;
											nMoeda,;
											oSayQtde,;
											oSayVal,;
											oSayRec,;
											oSayQtdCp,;
											oSayValCp,1)}

			oMarkSE1:oBrowse:lhasMark    := .T.
			oMarkSE1:oBrowse:lCanAllmark := .T.
			oMarkSE1:oBrowse:bAllMark    := {||OMSMarkAll(@nQtdeTit,;
											@nValTit,;
											@nTotRec,;
											@nValJur,;
											@nDescont,;
											@nAbatim,;
											@nPgParc,;
											@nQtdCps,;
											@nValCps,;
											dDatabase,;
											dDataLiq,;
											cMotBx,;
											nMoeda,;
											oSayQtde,;
											oSayVal,;
											oSayRec,;
											oSayQtdCp,;
											oSayValCp,1)}
			cMarkSE1 := ThisMark()

			//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Conferencia³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÙ

			aHeader  := aClone(aHeader1)
			aCols    := aClone(aCols1)
			oGetDad1 := MsGetDados():New(5,5,aPosObj[2,3]-aPosObj[2,1]-30,aPosObj[2,4]-aPosObj[2,2]-10,2,"Oms341LOk()","AllWaysTrue()",,.T.,aCpoEnable,1,,9999,,,,,oFolder:aDialogs[1])
			oGetDad1:oBrowse:lDisablePaint := .T.

			oFolder:SetOption(1)
			oFolder:bSetOption:={|nAtu| Oms341Fld(nAtu,;
													oFolder:nOption,;
													oFolder,;
													{oGetDad1,oGetDad2},;
													cCarga,;
													cSeqCar,;
													@cMotBx,;
													@cBanco,;
													@cAgencia,;
													@cConta,;
													@dBaixa,;
													@dDataLiq,;
													@dDtCredito,;
													@nTotRec,;
													@nQtdeTit,;
													@nValTit,;
													@nDescont,;
													@nValJur,;
													@nAbatim,;
													@nPgParc,;
													@nValRec,;
													@nQtdCps,;
													@nValCps,;
													oSayQtde,;
													oSayVal,;
													oSayRec,;
													oSayQtdCp,;
													oSayValCp,;
													cMarkSE1)}

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Botao da baixa automatica                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			@ aPosObj[2,3]-aPosObj[2,1]-27,aPosObj[2,4]-aPosObj[2,2]-60 BUTTON oBtnOp PROMPT STR0086 ; //"Bx. Automatica"
				SIZE 45, 12 OF oFolder:aDialogs[1] PIXEL ACTION (   Oms341Ok(oFolder:nOption,;
																cCarga,;
																cSeqCar,;
																@cMotBx,;
																@cBanco,;
																@cAgencia,;
																@cConta,;
																@dBaixa,;
																@dDataLiq,;
																@dDtCredito,;
																@nValRec,;
																@nQtdeTit,;
																@nValTit,;
																@nDescont,;
																@nValJur,;
																@nAbatim,;
																@nPgParc,;
																@nTotRec,;
																oFolder,;
																oSayQtde,;
																oSayVal,;
																oSayRec,;
																1),;
																Os341BxAut(.T.,cCarga,cSeqCar,1),;
																Oms341End(), ;
																oDlg:End(),nOpca := 0) ;
																WHEN Os341BxAut(.F.,cCarga,cSeqCar,1)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Botao da volta cliente na prestacao                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			DEFINE SBUTTON FROM aPosObj[3,1],(aSize[5]/2)-60 TYPE 22 ACTION (Iif(nX > 1,nX--,nX := 1),;
																			Oms341Trb(oFolder:nOption,;
																			aClientes[nX],;
																			DAK->DAK_COD,;
																			DAK->DAK_SEQCAR,;
																			oMarkCmp,;
																			oMarkSE1,;
																			oDlg,;
																			@cMotBx,;
																			@cBanco,;
																			@cAgencia,;
																			@cConta,;
																			@dBaixa,;
																			@dDataLiq,;
																			@dDtCredito,;
																			@nValRec,;
																			@nTotRec,;
																			@nQtdeTit,;
																			@nValTit,;
																			@nDescont,;
																			@nValJur,;
																			@nAbatim,;
																			@nPgParc,;
																			oSayQtde,;
																			oSayVal,;
																			oSayRec,;
																			.T.,;
																			1)) ENABLE OF oDlg

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Botao avanca cliente na prestacao                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			DEFINE SBUTTON FROM aPosObj[3,1],(aSize[5]/2)-30 TYPE 21 ACTION (nX++ ,Iif(nX <= Len(aClientes) ,;
																			Oms341Trb(oFolder:nOption,;
																			aClientes[nX],;
																			DAK->DAK_COD,;
																			DAK->DAK_SEQCAR,;
																			oMarkCmp,;
																			oMarkSE1,;
																			oDlg,;
																			@cMotBx,;
																			@cBanco,;
																			@cAgencia,;
																			@cConta,;
																			@dBaixa,;
																			@dDataLiq,;
																			@dDtCredito,;
																			@nValRec,;
																			@nTotRec,;
																			@nQtdeTit,;
																			@nValTit,;
																			@nDescont,;
																			@nValJur,;
																			@nAbatim,;
																			@nPgParc,;
																			oSayQtde,;
																			oSayVal,;
																			oSayRec,;
																			.T.,;
																			1),nX--)) ENABLE OF oDlg

		ACTIVATE MSDIALOG oDlg ON INIT ( Oms341Ref( { oGetDad1, oGetDad2 } ),;
					EnchoiceBar(oDlg,{|| If(Oms341Ok(oFolder:nOption,;
											cCarga,;
											cSeqCar,;
											@cMotBx,;
											@cBanco,;
											@cAgencia,;
											@cConta,;
											@dBaixa,;
											@dDataLiq,;
											@dDtCredito,;
											@nValRec,;
											@nQtdeTit,;
											@nValTit,;
											@nDescont,;
											@nValJur,;
											@nAbatim,;
											@nPgParc,;
											@nTotRec,;
											oFolder,;
											oSayQtde,;
											oSayVal,;
											oSayRec,;
											1,;
											aColsSEF,;
											cHistBx), ;
											(Oms341End(), ;
											oDlg:End()), .F. );										
											 },;
										{||Iif(OMS341Fec(),(oDlg:End(),nOpca := 0),'')},,aButtons) )

		// Desabilita a funcionalidade de reabrir a tela depois de clicar em Salvar
		MbrChgLoop(.F.)

	EndIf

	DelTempTab()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura a integridade da rotina                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsUnLockAll()

	//nTpBxAnt := 0 // Zerando o Status da Ultima Operacao Executada do Usuario

	dbSelectArea("DAK")
Return

Static Function OMSMarkAll(nQtdetit,;
						nValTit,;
						nTotRec,;
						nValJur,;
						nDescont,;
						nAbatim,;
						nPgParc,;
						nQtdCps,;
						nValCps,;
						dBaixa,;
						dDataLiq,;
						cMotBx,;
						nMoeda,;
						oSayQtde,;
						oSayVal,;
						oSayRec,;
						oSayQtdCp,;
						oSayValCp,;
						nPasta)

	Local aArea  := (__cAliTRB)->(GetArea())
	Local lMarca := Nil

	(__cAliTRB)->(dbGotop())
	Do While (__cAliTRB)->(!Eof())
		// Pula os registros que já foram baixados
		If (__cAliTRB)->E1_SALDO <= 0
			(__cAliTRB)->(dbSkip())
			Loop
		EndIf
		// Define se vai marcar ou desmarcar os registros
		If  (lMarca==NIL)
			lMarca := ((__cAliTRB)->TRB_MARCA == cMarkSE1)
		EndIf
		// Executa regra de marcação
		If  (__cAliTRB)->TRB_MARCA == Iif(lMarca,cMarkSE1,'  ')
			Oms341Chg(  @nQtdeTit,;
						@nValTit,;
						@nTotRec,;
						@nValJur,;
						@nDescont,;
						@nAbatim,;
						@nPgParc,;
						@nQtdCps,;
						@nValCps,;
						dDatabase,;
						dDataLiq,;
						cMotBx,;
						nMoeda,;
						oSayQtde,;
						oSayVal,;
						oSayRec,;
						oSayQtdCp,;
						oSayValCp,1)
		EndIf
		(__cAliTRB)->(dbSkip())
	EndDo

RestArea(aArea)
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341TIT ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de Prestacao de contas da carga                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela de carga                              ³±±
±±³          ³ExpN2: Numero do Registro                                    ³±±
±±³          ³ExpN3: Opcao do aRotina                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo realizar a prestacao de contas ³±±
±±³          ³e baixa dos titulos da carga                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Oms341Tit(cAlias,nReg,nOpc)

Local aButtons   := {{"PESQUISA",   { || Oms341Vis() }, OemtoAnsi(STR0017), OemtoAnsi(STR0003) },; //"Visualiza Titulo"###"Visualiza"
					{ "EXCLUIR",    { || Oms341Can(oFolder:nOption,;
												"",;
												"",;
												cCarga,;
												cSeqCar) },OemtoAnsi(STR0072), OemtoAnsi(STR0037) } } //"Cancelamento da baixa"###"Cancelar"

Local aCpoEnable:= { "DAP_CODGRU", "DAP_REALIZ", "DAP_INVALI" }
Local aCpoLiq   := { "E1_PREFIXO", "E1_BCOCHQ" , "E1_AGECHQ","E1_CTACHQ","E1_NUM","E1_VENCTO","E1_VLCRUZ","DA7_CLIENT","DA7_LOJA","E1_EMITCHQ" }
Local aCpoUsr   := {}
Local aDescMotbx:= {}
Local aClientes := {}
Local aFormas   := {}
Local aGet      := {}
Local aMotBx    := ReadMotBx()
Local aPages    := {"HEADER"}
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local nTamBco   := TamSx3("E1_BCOCHQ")[1]
Local nTamAge   := TamSx3("E1_AGECHQ")[1]
Local nTamCta   := TamSx3("E1_CTACHQ")[1]
Local nTamNum   := TamSx3("E1_NUM")[1]
Local nTamCli   := TamSx3("DA7_CLIENT")[1]
Local nTamLoj   := TamSx3("DA7_LOJA")[1]
Local aTitles   := {    OemtoAnsi(STR0004),;//"Conferencia"
						OemToAnsi(STR0013),;//Titulos
						OemToAnsi(STR0014),;//"Baixa"
						OemToAnsi(STR0015),;//"Liquidacao"
						OemToAnsi(STR0016) }//"Compensacao"

Local aUser     := {}
Local aHeaderBk := {}

Local cMotBx    := SuperGetMv("MV_OMSMOT",.F.,"")
Local cBanco    := Padr(SuperGetMv("MV_OMSBCO",.F.,""),Len(SA6->A6_COD))
Local cAgencia  := Padr(SuperGetMv("MV_OMSAGE",.F.,""),Len(SA6->A6_AGENCIA))
Local cConta    := Padr(SuperGetMv("MV_OMSCTA",.F.,""),Len(SA6->A6_NUMCON))

Local cCarga    := DAK->DAK_COD
Local cCaminhao := DAK->DAK_CAMINH
Local cSeqCar   := DAK->DAK_SEQCAR
Local cMotori   := DAK->DAK_MOTORI
Local cCliente  := ""
Local cDescCam  := ""
Local cHistBx   := ""
Local cLoja     := ""
Local cNome     := ""
Local cNomeMot  := ""
Local cPlaca    := ""
Local cRetPE    := ""
Local cBcoAuto  := SuperGetMv("MV_OMSBCO",.F.,"")
Local cAgeAuto  := SuperGetMv("MV_OMSAGE",.F.,"")
Local cCtaAuto  := SuperGetMv("MV_OMSCTA",.F.,"")
Local cMotAuto  := SuperGetMv("MV_OMSMOT",.F.,"")

Local cTpBxCr   := SuperGetMv("MV_OMSBXCR",.F.,"")
Local cTpLiq    := SuperGetMv("MV_OMSBXLQ",.F.,"")
Local cTpCmp    := SuperGetMv("MV_OMSBXCP",.F.,"")

Local dBaixa    := CriaVar("E1_BAIXA")
Local dDataLiq  := CriaVar("E1_BAIXA")

Local dDtCredito:= dDatabase
Local dDataGer  := DAK->DAK_DATA

Local lRetPE    := .T.

Local nValor    := DAK->DAK_VALOR
Local nPeso     := DAK->DAK_PESO
Local nPtoEnt   := DAK->DAK_PTOENT
Local nMoeda    := 1
Local nPosForma := 0
Local nQtdeTit  := 0
Local nValTit   := 0
Local nValJur   := 0
Local nDescont  := 0
Local nAbatim   := 0
Local nPgParc   := 0
Local nTotRec   := 0
Local nQtdCPS   := 0
Local nValCPS   := 0
Local nOpca     := 0
Local nCol1Grp  := 0
Local nLin2Grp  := 0
Local nCol2Grp  := 0
Local nUsado1   := 0
Local nUsado2   := 0
Local nX        := 0
Local nY        := 0
Local nCntFor   := 0
Local lOMS341CO := ExistBlock("OMS341CO")

Local oDlg      := Nil
Local oQtdeTit  := Nil
Local oValTit   := Nil
Local oDescont  := Nil
Local oValJur   := Nil
Local oAbatim   := Nil
Local oPagParc  := Nil
Local oTotRec   := Nil
Local oSayQtde  := Nil
Local oSayVal   := Nil
Local oSayRec   := Nil
Local oSayQtdCp := Nil
Local oSayValCp := Nil
Local oFontLbl  := Nil
Local oFontGrp  := Nil
Local oGetDad1  := Nil
Local oGetDad2  := Nil

Local cFilBkp   := cFilAnt

Private cSeqTrb341 := "000"
Private aHeader  := {}
Private aCols    := {}
Private aColsSEF := {}
Private aColsCHQ := {}
Private aHeader1 := {}
Private aCols1   := {}
Private aHeader2 := {}
Private aCols2   := {}
Private nValRec  := 0 //-- Var. usada na valid. dos totais dos cheques info na baixa.
Private oMarkCmp := Nil
Private cMarkCmp := ""
Private oMarkSE1 := Nil
Private cMarkSE1 := ""
Private oFolder  := Nil
Private oCbx     := Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Objetos atualizados na Linok() do acols de liquidacao                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private oSayQtdCh
Private oSayValCh

Private nTotal    := 0
Private nTotalDig := 0
Private aRotina   := MenuDef()

DEFINE FONT oFontGrp NAME "Arial" SIZE 6, 15 BOLD
DEFINE FONT oFontLbl SIZE 15,0 BOLD

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para adicionar botoes na EnchoiceBar         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("OMS341BP")
		aUser := ExecBlock("OMS341BP",.F.,.F.)
		For nX := 1 To Len(aUser)
			Aadd(aButtons,aClone(aUser[nX]))
		Next nX
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Travo o registro da carga                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !SoftLock("DAK")
		Return
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se foi feito a conferencia da prestacao de conta    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If DAK->DAK_ACEFIN == "2"
		OmsHelp(STR0101,STR0102,OMSA34103) // "A conferência desta carga ainda não foi realizada." // "Efetue a conferência da carga antes de realizar a baixa dos títulos."
		DAK->(MsUnlock())
		Return
	EndIf

	// A busca de formas de pagamento deve considerar a filial da carga
	cFilAnt := __cFilCar

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se existe contas a receber para o titulo             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFormas    := OsAglForma(cCarga,cSeqCar)
	aClientes  := OsCargaNf(cCarga,cSeqCar)

	// Restaura a filial para a prestação de contas
	cFilAnt    := cFilBkp

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Array aHeader.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := {}
	aCols   := {}

	FillGetDados(3,'DAP',,,,,,,,,{|| })

	nUsado1 := Len(aHeader)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Adiciona o array no DAP para montar o aCols                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aFormas)

		Aadd(aCols,Array(nUsado1+1))

		For nY := 1 To nUsado1

			Do Case
				Case Alltrim(aHeader[nY][2]) == "DAP_CODGRU"
					aCols[Len(aCols)][nY] := aFormas[nX][1]
				Case Alltrim(aHeader[nY][2]) == "DAP_GRUPO"
					aCols[Len(aCols)][nY] := aFormas[nX][2]
				Case Alltrim(aHeader[nY][2]) == "DAP_PREVIS"
					aCols[Len(aCols)][nY] := aFormas[nX][3]
				Case Alltrim(aHeader[nY][2]) == "DAP_DEVOL"
					aCols[Len(aCols)][nY] := aFormas[nX][4]
				Case Alltrim(aHeader[nY][2]) == "DAP_DIFERE"
					aCols[Len(aCols)][nY] := aFormas[nX][3]- aFormas[nX][4]
				Case Alltrim(aHeader[nY][2]) == "DAP_REALIZ"
					aCols[Len(aCols)][nY] := aFormas[nX][5]
				Case Alltrim(aHeader[nY][2]) == "DAP_VLRBX"
					aCols[Len(aCols)][nY] := aFormas[nX][6]
			Endcase
		Next nX

		aCols[Len(aCols)][nUsado1+1] := .F.

	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza total da diferenca                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aCols) == 0
		Aadd(aCols,Array(nUsado1+1))
		For nCntFor := 1 To nUsado1
			aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
		Next nCntFor
		aCols[Len(aCols)][nUsado1+1] := .F.
	EndIf

	aHeader1 := aClone(aHeader)
	aCols1   := aClone(aCols)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria aHeader do Segundo Folder                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aHeader := {}
	aCols   := {}

	Aadd(aHeader,{RTrim(RetTitle("E1_PREFIXO")),"E1_PREFIXO","!!!",;    //"PREFIXO "
			3,0,"Oms341VProc()","û","C","SE1" } )
	Aadd(aHeader,{RTrim(RetTitle("E1_BCOCHQ")),"E1_BCOCHQ","@!",;       //"BCO. "
			nTamBco,0,"Oms341VProc()","û","C","SE1" } )
	Aadd(aHeader,{RTrim(RetTitle("E1_AGECHQ")),"E1_AGECHQ","@!",;       //"AGENCIA"
			nTamAge,0,"Oms341VProc()","û","C","SE1" } )
	Aadd(aHeader,{RTrim(RetTitle("E1_CTACHQ")),"E1_CTACHQ","@!",;       //"CONTA"
			nTamCta,0,"Oms341VProc()","û","C","SE1" } )
	Aadd(aHeader,{RTrim(RetTitle("E1_NUM")),"E1_NUM","@!",;         //"NRO. CHEQUE"
			nTamNum,0,"Oms341VProc()","û","C","SE1" } )
	Aadd(aHeader,{RTrim(RetTitle("E1_VENCTO")),"E1_VENCTO"," ",;        //"DATA BOA"
			8,0,"Oms341VProc()","û","D","SE1" } )
	Aadd(aHeader,{RTrim(RetTitle("E1_VLCRUZ")),"E1_VLCRUZ","@E 9999,999,999.99",;   //"VALOR"
			14,2,"Oms341VProc()","û","N","SE1" } )
	Aadd(aHeader,{RTrim(RetTitle("DA7_CLIENT")),"DA7_CLIENT","@!",; //"CLIENTE"
			nTamCli,0,"Oms341VProc()","û","C","DA7" } )
	Aadd(aHeader,{RTrim(RetTitle("DA7_LOJA")),"DA7_LOJA","@!",;     //"LOJA"
			nTamLoj,0,"Oms341VProc()","û","C","DA7" } )
	Aadd(aHeader,{RTrim(RetTitle("E1_EMITCHQ")),"E1_EMITCHQ","@!",;
			30,0,"Oms341VProc()","û","C","SE1" } )
	Aadd(aHeader,{RTrim(STR0084),"E1_ADM","@!",;                        //"Sequencia"
			1,0,"Oms341VProc()","û","C","SE1" } )

	aHeaderBk := aClone(aHeader)

	If lOMS341CO
		ExecBlock("OMS341CO", .F., .F.,)
	EndIf

	For nX := 1 to Len(aHeader)
		If Ascan(aHeaderBk,{|x| Alltrim(x[2]) == Alltrim(aHeader[nX][2]) } ) == 0
			Aadd(aCpoLiq,Alltrim(aHeader[nX][2]) )
		EndIf
	Next nX

	nUsado2 := Len(aHeader)
	aCols := Array( 1 , (nUsado2+1) )
	aCols[1,nUsado2+1] := .F.
	For nCntFor := 1 To nUsado2
		aCols[1,nCntFor] := CriaVar(aHeader[nCntFor,2],.T.)
	Next nCntFor

	aHeader2 := aClone(aHeader)
	aCols2   := aClone(aCols)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega modelo dos campos                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aGet,{FWX3Titulo("DAK_COD" ),X3Picture("DAK_COD" )})
	aadd(aGet,{FWX3Titulo("DAK_DATA"),X3Picture("DAK_DATA")})
	aadd(aGet,{FWX3Titulo("A1_COD"  ),X3Picture("A1_COD"  )})

	dbSelectArea("DA4")
	dbSetOrder(1)
	If MsSeek(xFilial("DA4")+cMotori)
		cNomeMot := DA4->DA4_NOME
	EndIf

	dbSelectArea("DA3")
	dbSetOrder(1)
	If MsSeek(xFilial("DA4")+cCaminhao)
		cDescCam := DA3->DA3_DESC
		cPlaca   := DA3->DA3_PLACA
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula tamanho da tela                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize := MsAdvSize()
	AAdd( aObjects, { 100, 020, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 010, .T., .F. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	// Cria as tabelas temporárias de Títulos, Compensação e Processamento
	Oms341Cria()

	// Carrega para cada cliente os títulos a receber relacionados à carga,
	// além dos títulos pendentes de compensação, se for o caso
	Oms341Trb2(1,;
		aClientes,;
		DAK->DAK_COD,;
		DAK->DAK_SEQCAR,,,,;
		@cMotBx,;
		@cBanco,;
		@cAgencia,;
		@cConta,;
		@dBaixa,;
		@dDataLiq,;
		@dDtCredito,;
		@nValRec,;
		@nTotRec,;
		@nQtdeTit,;
		@nValTit,;
		@nDescont,;
		@nValJur,;
		@nAbatim,;
		@nPgParc,;
		oSayQtde,;
		oSayVal,;
		oSayRec,;
		.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza as variaveis da tela do financeiro                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cBanco    := CriaVar("E1_PORTADO",.F.)
	cAgencia  := CriaVar("E1_AGEDEP" ,.F.)
	cConta    := CriaVar("E1_CONTA"  ,.F.)

	cMotBx    := SuperGetMv("MV_OMSMOT",.F.,"")
	cBanco    := Padr(SuperGetMv("MV_OMSBCO",.F.,""),Len(SA6->A6_COD))
	cAgencia  := Padr(SuperGetMv("MV_OMSAGE",.F.,""),Len(SA6->A6_AGENCIA))
	cConta    := Padr(SuperGetMv("MV_OMSCTA",.F.,""),Len(SA6->A6_NUMCON))

	dBaixa    := CriaVar("E1_BAIXA")
	dDataLiq  := CriaVar("E1_BAIXA")
	dDtCredito:= dDatabase
	aMotBx    := ReadMotBx()
	cMotBx    := CriaVar("E1_MOTIVO")
	cHistBx   := OemtoAnsi(STR0012) //"VALOR RECEBIDO"
	nValRec   := 0
	nQtdeTit  := 0
	nValTit   := 0
	nValJur   := 0
	nDescont  := 0
	nAbatim   := 0
	nPgParc   := 0
	nTotRec   := 0

	//-- Ponto de entrada para alterar conteudo padrao da variavel cHistBx no folder da baixa
	If ExistBlock("OM341HIS")
		cRetPE := ExecBlock("OM341HIS",.F.,.F.)
		If ValType(cRetPE) == "C"
			cHistBx := cRetPE
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Zera a opcao de confirmacao de tela                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpca := 0

	SetEnch(,.F.)
	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0001)From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL //"Prestacao de Contas"

		@ aPosObj[1][1]+05,aPosObj[1][2] SAY aGet[1][1] SIZE 50,7 OF oDlg PIXEL
		@ aPosObj[1][1]+05,aPosObj[1][2]+30 MsGet cCarga PICTURE aGet[1][2] WHEN .F. SIZE 35,7 OF oDlg PIXEL

		@ aPosObj[1][1]+05,aPosObj[1][2]+85  SAY aGet[2][1] SIZE 50,7 OF oDlg PIXEL
		@ aPosObj[1][1]+05,aPosObj[1][2]+105 MsGet dDataGer PICTURE aGet[1][2] WHEN .F. SIZE 50,7 OF oDlg PIXEL

		@ aPosObj[3,1],005 SAY OemToAnsi(STR0023+": ")  SIZE 53,07 OF oDlg PIXEL FONT oFontGrp //"Qtde de Titulos"
		@ aPosObj[3,1],055 SAY oSayQtde Prompt ""       SIZE 40,10 OF oDlg PIXEL FONT oFontGrp

		@ aPosObj[3,1],090 SAY OemToAnsi(STR0024+": ")  SIZE 53,07 OF oDlg PIXEL FONT oFontGrp //"Valor dos Titulos"
		@ aPosObj[3,1],148 SAY oSayVal Prompt ""        SIZE 40,10 OF oDlg PIXEL FONT oFontGrp

		@ aPosObj[3,1],190 SAY OemToAnsi(STR0035+": ")  SIZE 53,07 OF oDlg PIXEL FONT oFontGrp //"Valor a Receber"
		@ aPosObj[3,1],245 SAY oSayRec Prompt ""        SIZE 40,10 OF oDlg PIXEL FONT oFontGrp

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa os objetos zerados                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSayQtde:SetText(Alltrim(Transform(nQtdeTit,"999999")))
		oSayVal:SetText(Alltrim(Transform(nValTit,"@R 99,999,999.99")))
		oSayRec:SetText(Alltrim(Transform(nTotRec,"@R 99,999,999.99")))

		oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,aPages,oDlg,,,, .T., .F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta folder de Compensacao                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		oMarkCmp := MsSelect():New(__cAliCPS,"TRB_MARCA","E1_SALDO == 0",__aCpoBrw,Nil,Nil,{5,5,aPosObj[2,3]-aPosObj[2,1]-30,aPosObj[2,4]-aPosObj[2,2]-10},,,oFolder:aDialogs[5])

		oMarkCmp:bAval := {||Oms341Chg(@nQtdeTit,;
										@nValTit,;
										@nTotRec,;
										@nValJur,;
										@nDescont,;
										@nAbatim,;
										@nPgParc,;
										@nQtdCps,;
										@nValCps,;
										dDatabase,;
										dDataLiq,;
										cMotBx,;
										nMoeda,;
										oSayQtde,;
										oSayVal,;
										oSayRec,;
										oSayQtdCp,;
										oSayValCp,2)}

		oMarkCmp:oBrowse:lhasMark    := .T.
		oMarkCmp:oBrowse:lCanAllmark := .F.
		cMarkCmp := ThisMark()

		@ aPosObj[2,3]-aPosObj[2,1]-25,005 SAY OemtoAnsi(STR0023+": ")  SIZE 53,07 Of oFolder:aDialogs[5] PIXEL FONT oFontGrp //"Qtde de Titulos"
		@ aPosObj[2,3]-aPosObj[2,1]-25,065 SAY oSayQtdCp Prompt ""      SIZE 40,10 Of oFolder:aDialogs[5] PIXEL FONT oFontGrp

		@ aPosObj[2,3]-aPosObj[2,1]-25,100 SAY OemtoAnsi(STR0024+": ")  SIZE 53,07 Of oFolder:aDialogs[5] PIXEL FONT oFontGrp //"Valor dos Titulos"
		@ aPosObj[2,3]-aPosObj[2,1]-25,165 SAY oSayValCp Prompt ""      SIZE 40,10 Of oFolder:aDialogs[5] PIXEL FONT oFontGrp

		oSayQtdCp:SetText(Alltrim(Transform(0,"999999")))
		oSayValCp:SetText(Alltrim(Transform(0,"@R 99,999,999.99")))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta folder de Liquidacao                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aHeader  := aClone(aHeader2)
		aCols    := aClone(aCols2)

		@ 5,005 SAY OemtoAnsi(STR0078) SIZE 50,10 Of oFolder:aDialogs[4] PIXEL //"Data Recebimento"
		@ 5,050 MSGET dDataLiq  SIZE 40,10  Of oFolder:aDialogs[4] PIXEL Valid Oms341DtLq(dDataLiq)
		@ 5,100 BUTTON "CMC7"   SIZE 45,12  Of oFolder:aDialogs[4] PIXEL ACTION OmsCMC7()
		//          MsGetDados(nT , nL,  nB,  nR,                nOpc,   cLinhaOk,   cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
		oGetDad2 := MsGetDados():New(20,5,aPosObj[2,3]-aPosObj[2,1]-30,aPosObj[2,4]-aPosObj[2,2]-10,nOpc,"Oms341LOk2","AllWaysTrue",,.T.,aCpoLiq,1,,,,,,,oFolder:aDialogs[4])
		oGetDad2:oBrowse:lDisablePaint := .T.

		@ aPosObj[2,3]-aPosObj[2,1]-25,005 SAY OemtoAnsi(STR0055)   SIZE 53,07 Of oFolder:aDialogs[4] PIXEL FONT oFontGrp //"Qtde de cheques :"
		@ aPosObj[2,3]-aPosObj[2,1]-25,065 SAY oSayQtdCh Prompt ""  SIZE 40,10 Of oFolder:aDialogs[4] PIXEL FONT oFontGrp

		@ aPosObj[2,3]-aPosObj[2,1]-25,100 SAY OemtoAnsi(STR0056)   SIZE 53,07 Of oFolder:aDialogs[4] PIXEL FONT oFontGrp //"Valor dos cheques :"
		@ aPosObj[2,3]-aPosObj[2,1]-25,165 SAY oSayValCh Prompt ""  SIZE 40,10 Of oFolder:aDialogs[4] PIXEL FONT oFontGrp

		oSayQtdCh:SetText(Alltrim(Transform(0,"999999")))
		oSayValCh:SetText(Alltrim(Transform(0,"@R 99,999,999.99")))


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta folder das baixas                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//-- Array com os motivos da baixa
		If len( aDescMotbx ) == 0
			For nY := 1 to Len(aMotBx)
				If Substr(aMotBx[nY],34,01) == "A" .or. Substr(aMotBx[nY],34,01) == "R"
					AADD( aDescMotbx,Substr(aMotBx[nY],07,10))
				EndIf
			Next
		EndIf

		//-- Ponto de entrada para bloquear alteracao dos campos: Motivo, Banco, Agencia e Conta.
		If ExistBlock("OS341BLQ")
			lRetPE := ExecBlock("OS341BLQ",.F.,.F.)
			If  ValType(lRetPE)<>"L"
				lRetPE := .T.
			EndIf
		EndIf

		//-- Calcula grupos de acordo com a definicao da tela
		nCol1Grp2 := ((aPosObj[2,4]-aPosObj[2,2]-10) / 2) + 5
		nLin2Grp2 := ( aPosObj[2,3]-aPosObj[2,1]-20)
		nCol2Grp2 := ( aPosObj[2,4]-aPosObj[2,2]-10)

		@ 005,005 GROUP oGrp1 TO aPosObj[2,3]-aPosObj[2,1]-20, (aPosObj[2,4]-aPosObj[2,2]-10)/2  LABEL OemToAnsi( STR0085 ) OF oFolder:aDialogs[3] PIXEL //"Dados da Baixa"
		oScroll := TScrollBox():New( oFolder:aDialogs[3], 15, 10,aPosObj[2,3]-aPosObj[2,1]-40,(aPosObj[2,4]-aPosObj[2,2]-40)/2)
		oGrp1:oFont := oFontGrp

		@ 010,010 SAY Rtrim(RetTitle("E1_MOTIVO"))  SIZE 32, 07 OF oScroll PIXEL //"Motivo
		@ 010,056 COMBOBOX oCbx VAR cMotBx ITEMS aDescMotBx VALID OMS341VMot(cMotBx,@cBanco,@cAgencia,@cConta) WHEN lRetPE SIZE 56, 07 OF oScroll PIXEL

		@ 029,010 SAY RTrim(RetTitle("E5_BANCO"))   SIZE 32, 07 OF oScroll PIXEL //"Banco"
		@ 029,056 MSGET oBanco var cBanco           VALID !MovBcobx(cMotBx, .T.) .Or. CarregaSA6(@cBanco,,,.T.) .Or. Empty(cBanco) WHEN lRetPE .And. MovBcoBx(cMotBx, .T.) SIZE 22, 08 OF oScroll PIXEL F3 "SA6"

		@ 042,010 SAY Rtrim(RetTitle("E5_AGENCIA")) SIZE 32, 07 OF oScroll PIXEL //"Agˆncia"
		@ 042,056 MSGET oAgencia var cAgencia       VALID !MovBcobx(cMotBx, .T.) .Or. CarregaSA6(@cBanco,@cAgencia,,.T.) .Or. Empty(cAgencia) WHEN lRetPE .And. MovBcoBx(cMotBx, .T.) SIZE 35, 08 OF oScroll PIXEL

		@ 055,010 SAY Rtrim(RetTitle("E5_CONTA"))   SIZE 28, 07 OF oScroll PIXEL //"Conta"
		@ 055,056 MSGET oConta var cConta           VALID !MovBcobx(cMotBx, .T.) .Or. CarregaSA6(@cBanco,@cAgencia,@cConta,.T.,,.T.) .Or. Empty(cConta) WHEN lRetPE .And. MovBcoBx(cMotBx, .T.) SIZE 66, 08 OF oScroll PIXEL

		If cPaisLoc == "BRA"
			@ 068,010 SAY STR0083 SIZE 39, 07 OF oScroll PIXEL //"Cheque(s)"
			@ 137,110 BTNBMP RESOURCE "LIQCHECK" SIZE 25, 15 OF oScroll PIXEL Action CadCheqCR(cBanco,cAgencia,cConta,nValRec,dBaixa,1,@aColsSEF) When OmsCadCR(aClientes[1][5][1][1],nQtdeTit) .And. !(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
		EndIf

		@ 081,010 SAY OemToAnsi(STR0018) SIZE 39, 07 OF oScroll PIXEL //"Data Receb."
		@ 081,056 MSGET dBaixa Valid Oms341DtLq(dBaixa) SIZE 43, 08 OF oScroll PIXEL

		@ 094,010 SAY OemToAnsi(STR0019) SIZE 32, 07 OF oScroll PIXEL //"Data Cr‚dito"
		@ 094,056 MSGET dDtCredito SIZE 43, 08 OF oScroll PIXEL Valid (dDtCredito >= dBaixa  .and. DtMovFin(dDtCredito)) .or. GetMv("MV_ANTCRED")

		@ 107,010 SAY OemToAnsi(STR0020) SIZE 32, 07 OF oScroll PIXEL //"Hist.Baixa"
		@ 107,056 MSGET cHistBx SIZE 83, 08 OF oScroll PIXEL Picture "@!"

		@ 122,010 SAY OemToAnsi(STR0021) SIZE 53,07 OF oScroll PIXEL //"Valor Recebido"
		@ 122,056 MSGET oValRec VAR nValRec Valid Oms341VlBx(nValRec,nTotRec,cBanco,cAgencia,cConta,dBaixa,dDtCredito,.T.) SIZE 66, 08 OF oScroll PIXEL Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99"

		@ 005,nCol1Grp2 GROUP oGrp2 TO nLin2Grp2, nCol2Grp2 LABEL OemToAnsi( STR0022 ) OF oFolder:aDialogs[3]  PIXEL //"Dados dos Titulos"

		oGrp2:oFont := oFontGrp

		@ 015,nCol1Grp2+10 SAY OemToAnsi(STR0023)               SIZE 53,07 OF oFolder:aDialogs[3] PIXEL //"Qtde de Titulos"
		@ 015,nCol1Grp2+70 MSGET oQtdeTit VAR nQtdeTit WHEN .F. SIZE 66,10 OF oFolder:aDialogs[3] PIXEL Picture "999999"

		@ 030,nCol1Grp2+10 SAY "(+) " + OemToAnsi(STR0024)      SIZE 53,07 OF oFolder:aDialogs[3] PIXEL //"Valor dos Titulos"
		@ 030,nCol1Grp2+70 MSGET oValTit VAR nValTit WHEN .F.   SIZE 66,10 OF oFolder:aDialogs[3] PIXEL Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99"

		@ 045,nCol1Grp2+10 SAY "(-) " + OemToAnsi(STR0034)      SIZE 53,07 OF oFolder:aDialogs[3] PIXEL //"Abatimentos"
		@ 045,nCol1Grp2+70 MSGET oAbatim VAR nAbatim WHEN .F.   SIZE 66,10 OF oFolder:aDialogs[3] PIXEL Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99"

		@ 060,nCol1Grp2+10 SAY "(-) " + OemToAnsi(STR0091)      SIZE 53,07 OF oFolder:aDialogs[3] PIXEL //"Pagtos. Parciais"
		@ 060,nCol1Grp2+70 MSGET oPagParc VAR nPgParc WHEN .F.  SIZE 66,10 OF oFolder:aDialogs[3] PIXEL Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99"

		@ 075,nCol1Grp2+10 SAY "(-) " + OemToAnsi(STR0025)      SIZE 53,07 OF oFolder:aDialogs[3] PIXEL //"Valor Desconto"
		@ 075,nCol1Grp2+70 MSGET oDescont VAR nDescont WHEN .F. SIZE 66,10 OF oFolder:aDialogs[3] PIXEL Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99"

		@ 090,nCol1Grp2+10 SAY "(+) " + OemToAnsi(STR0026)      SIZE 53,07 OF oFolder:aDialogs[3] PIXEL //"Tx. Permanencia"
		@ 090,nCol1Grp2+70 MSGET oValJur VAR nValJur WHEN .F.   SIZE 66,10 OF oFolder:aDialogs[3] PIXEL Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99"

		nTotRec := nValTit+nValJur-nDescont-nAbatim-nPgParc

		@ 105,nCol1Grp2+10 SAY "(=) " + OemToAnsi(STR0035)      SIZE 53,07 OF oFolder:aDialogs[3] PIXEL //"Valor a Receber"
		@ 105,nCol1Grp2+70 MSGET oTotRec VAR nTotRec WHEN .F.   SIZE 66,10 OF oFolder:aDialogs[3] PIXEL Picture PesqPict( "SE1","E1_VALOR" )  ;//"@E 999,999,999,999.99"

		//ÚÄÄÄÄÄÄÄ¿
		//³Titulos³
		//ÀÄÄÄÄÄÄÄÙ

		oMarkSE1 :=MsSelect():New(__cAliTRB,"TRB_MARCA","E1_SALDO == 0",__aCpoBrw,Nil,Nil,{5,5,aPosObj[2,3]-aPosObj[2,1]-20,aPosObj[2,4]-aPosObj[2,2]-10},,,oFolder:aDialogs[2])
		oMarkSE1:bAval := {||Oms341Chg( @nQtdeTit,;
										@nValTit,;
										@nTotRec,;
										@nValJur,;
										@nDescont,;
										@nAbatim,;
										@nPgParc,;
										@nQtdCps,;
										@nValCps,;
										dDatabase,;
										dDataLiq,;
										cMotBx,;
										nMoeda,;
										oSayQtde,;
										oSayVal,;
										oSayRec,;
										oSayQtdCp,;
										oSayValCp,1)}
		oMarkSE1:oBrowse:lhasMark    := .T.
		oMarkSE1:oBrowse:lCanAllmark := .T.
		oMarkSE1:oBrowse:bAllMark    := {||OMSMarkAll(@nQtdeTit,;
										@nValTit,;
										@nTotRec,;
										@nValJur,;
										@nDescont,;
										@nAbatim,;
										@nPgParc,;
										@nQtdCps,;
										@nValCps,;
										dDatabase,;
										dDataLiq,;
										cMotBx,;
										nMoeda,;
										oSayQtde,;
										oSayVal,;
										oSayRec,;
										oSayQtdCp,;
										oSayValCp,1)}
		cMarkSE1 := ThisMark()

		//ÚÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Conferencia³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÙ

		aHeader  := aClone(aHeader1)
		aCols    := aClone(aCols1)
		oGetDad1 := MsGetDados():New(5,5,aPosObj[2,3]-aPosObj[2,1]-30,aPosObj[2,4]-aPosObj[2,2]-10,2,"Oms341LOk()","AllWaysTrue()",,.T.,aCpoEnable,1,,9999,,,,,oFolder:aDialogs[1])
		oGetDad1:oBrowse:lDisablePaint := .T.

		oFolder:SetOption(1)
		oFolder:bSetOption:={|nAtu| Oms341Fld(nAtu,;
												oFolder:nOption,;
												oFolder,;
												{oGetDad1,oGetDad2},;
												cCarga,;
												cSeqCar,;
												@cMotBx,;
												@cBanco,;
												@cAgencia,;
												@cConta,;
												@dBaixa,;
												@dDataLiq,;
												@dDtCredito,;
												@nTotRec,;
												@nQtdeTit,;
												@nValTit,;
												@nDescont,;
												@nValJur,;
												@nAbatim,;
												@nPgParc,;
												@nValRec,;
												@nQtdCps,;
												@nValCps,;
												oSayQtde,;
												oSayVal,;
												oSayRec,;
												oSayQtdCp,;
												oSayValCp,;
												cMarkSE1)}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Botao da baixa automatica                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		@ aPosObj[2,3]-aPosObj[2,1]-27,aPosObj[2,4]-aPosObj[2,2]-60 BUTTON oBtnOp PROMPT STR0086 ; //"Bx. Automatica"
			SIZE 45, 12 OF oFolder:aDialogs[1] PIXEL ACTION (Oms341Ok(oFolder:nOption,;
															cCarga,;
															cSeqCar,;
															@cMotBx,;
															@cBanco,;
															@cAgencia,;
															@cConta,;
															@dBaixa,;
															@dDataLiq,;
															@dDtCredito,;
															@nValRec,;
															@nQtdeTit,;
															@nValTit,;
															@nDescont,;
															@nValJur,;
															@nAbatim,;
															@nPgParc,;
															@nTotRec,;
															oFolder,;
															oSayQtde,;
															oSayVal,;
															oSayRec,;
															2,, ;
															cHistBx),;
															Os341BxAut(.T.,cCarga,cSeqCar,1),;
															Oms341End(), ;
															oDlg:End(),nOpca := 0) ;
															WHEN Os341BxAut(.F.,cCarga,cSeqCar,1)

	ACTIVATE MSDIALOG oDlg ON INIT ( Oms341Ref( { oGetDad1, oGetDad2 } ),;
					EnchoiceBar(oDlg,{|| Oms341Ok(oFolder:nOption,;
										cCarga,;
										cSeqCar,;
										@cMotBx,;
										@cBanco,;
										@cAgencia,;
										@cConta,;
										@dBaixa,;
										@dDataLiq,;
										@dDtCredito,;
										@nValRec,;
										@nQtdeTit,;
										@nValTit,;
										@nDescont,;
										@nValJur,;
										@nAbatim,;
										@nPgParc,;
										@nTotRec,;
										oFolder,;
										oSayQtde,;
										oSayVal,;
										oSayRec,2,;
										aColsSEF, cHistBx),;
										Oms341End(), ;
										oDlg:End() },;
										{||Iif(OMS341Fec(),(oDlg:End(),nOpca := 0),'')},,aButtons) )

	// Desabilita a funcionalidade de reabrir a tela depois de clicar em Salvar
	MbrChgLoop(.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Restaura a integridade da rotina                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsUnLockAll()

	DelTempTab()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341CRIA³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de Criacao do TRB para a prestacao de contas          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do arquivo de titulos                           ³±±
±±³          ³ExpC2: Alias do arquivo de compensacao                       ³±±
±±³          ³ExpC3: Nome do arquivo de Baixa                              ³±±
±±³          ³ExpC4: Nome do arquivo de Compensacao                        ³±±
±±³          ³ExpA5: Array com os campos que aparecerao no browse          ³±±
±±³          ³ExpA6: Array com os campos para criacao do arquivo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo criar os arquivos temporarios  ³±±
±±³          ³onde serao aramazenados os titulos e as NCCs                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341Cria()
Local cCposTit   := ""
Local oStructSE1 := Nil
Local aFieldsSE1 := {}
Local nI         := 1
Local aNaoUsados := {"E1_SDDECRE","E1_SDACRES","E1_VALLIQ","E1_DESCONT"}
Local aColsSX3   := {}

	If Len(__aCampos) == 0

		AAdd(__aCpoBrw,{"TRB_MARCA" ,," "," "})

		AAdd(__aCampos,{"TRB_MARCA"  ,"C",2                      ,0})
		AAdd(__aCampos,{"TRB_SEQUEN" ,"C",3                      ,0})
		AAdd(__aCampos,{"TRB_FILTIT" ,"C",FWSizeFilial()         ,0})
		AAdd(__aCampos,{"TRB_RECNO"  ,"N",12                     ,0})
		AAdd(__aCampos,{"TRB_OPERA"  ,"C",1                      ,0})
		AAdd(__aCampos,{"TRB_TPBAIX" ,"C",TamSX3("E1_MOTIVO" )[1],0})
		AAdd(__aCampos,{"TRB_BANCO"  ,"C",TamSX3("E1_PORTADO")[1],0})
		AAdd(__aCampos,{"TRB_AGENC"  ,"C",TamSX3("E1_AGEDEP" )[1],0})
		AAdd(__aCampos,{"TRB_CONTA"  ,"C",TamSX3("E1_CONTA"  )[1],0})
		AAdd(__aCampos,{"TRB_DATA"   ,"D",8                      ,0})
		AAdd(__aCampos,{"TRB_DTCRED" ,"D",8                      ,0})
		AAdd(__aCampos,{"TRB_VALREC" ,"N",12                     ,2})
		AAdd(__aCampos,{"TRB_VALJUR" ,"N",12                     ,2})
		AAdd(__aCampos,{"TRB_VALDES" ,"N",12                     ,2})

		cCposTit   := CpoTit341()
		oStructSE1 := FwFormStruct(1,"SE1",{|cCampo| AllTrim(cCampo) $ cCposTit})
		aFieldsSE1 := oStructSE1:GetFields()

		// Só adiciona nos arrays se não for do tipo Memo e nem virtual
		For nI := 1 To Len(aFieldsSE1)
			If aFieldsSE1[nI,4] != "M"
				AAdd(__aCampos,{aFieldsSE1[nI,3],aFieldsSE1[nI,4],aFieldsSE1[nI,5],aFieldsSE1[nI,6]})
				AAdd(__aCpoBrw,{aFieldsSE1[nI,3],,aFieldsSE1[nI,1],X3Picture(aFieldsSE1[nI,3])})
			EndIf
		Next

		// Este trecho de código pode ser removido quando o módulo Financeiro alterar
		// os campos E1_SDDECRE, E1_SDACRES, E1_VALLIQ e E1_DESCONT para Usados
		For nI := 1 To Len(aNaoUsados)
			If AScan(aFieldsSE1,{|x| x[3] == aNaoUsados[nI]}) <= 0
				BuscarSX3(aNaoUsados[nI],,aColsSX3)
				AAdd(__aCampos,{aNaoUsados[nI],"N",aColsSX3[3],aColsSX3[4]})
				AAdd(__aCpoBrw,{aNaoUsados[nI],,aColsSX3[1],aColsSX3[2]})
			EndIf
		Next

		AAdd(__aIdxTRB,"E1_PREFIXO+E1_NUM+E1_PARCELA" )
		AAdd(__aIdxTRB,"TRB_TPBAIX+TRB_BANCO+TRB_AGENC+TRB_CONTA+TRB_DATA+TRB_DTCRED" )
		AAdd(__aIdxTRB,"TRB_OPERA+TRB_TPBAIX+TRB_BANCO+TRB_AGENC+TRB_CONTA+E1_PREFIXO+E1_NUM+E1_PARCELA" )
		AAdd(__aIdxTRB,"E1_CLIENTE+E1_LOJA")

		AAdd(__aIdxCPS,"E1_PREFIXO+E1_NUM+E1_PARCELA" )
		AAdd(__aIdxCPS,"TRB_OPERA+E1_PREFIXO+E1_NUM+E1_PARCELA" )

		AAdd(__aIdxPRC,"E1_PREFIXO+E1_NUM+E1_PARCELA" )
		AAdd(__aIdxPRC,"TRB_TPBAIX+TRB_BANCO+TRB_AGENC+TRB_CONTA+TRB_DATA+TRB_DTCRED" )
		AAdd(__aIdxPRC,"TRB_OPERA+TRB_TPBAIX+TRB_BANCO+TRB_AGENC+TRB_CONTA+E1_PREFIXO+E1_NUM+E1_PARCELA" )

	EndIf

	// Cria Tabela Temporária de Títulos
	__cAliTRB := CriaTabTmp(__aCampos,__aIdxTRB,,@__oTempSE1)

	// Cria Tabela Temporária de Compensação
	__cAliCPS := CriaTabTmp(__aCampos,__aIdxCPS,,@__oTempCPS)

	// Cria Tabela Temporária de Processamento
	__cAliPRC := CriaTabTmp(__aCampos,__aIdxPRC,,@__oTempPRC)

Return

//----------------------------------------------------------
/*/{Protheus.doc} DelTempTab
Deleta as tabelas temporárias utilizadas no processo de prestação de contas
@author  Guilherme A. Metzger
@version P12
@since   22/06/2018
/*/
//----------------------------------------------------------
Static Function DelTempTab()
	If Select(__cAliTRB) > 0
		DelTabTmp(__cAliTRB,__oTempSE1)
		DelTabTmp(__cAliCPS,__oTempCPS)
		DelTabTmp(__cAliPRC,__oTempPRC)
	EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341TRB ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de gravacao do arquivo temporario de titulos e NCCs   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Folder ativo no momento da chamada                    ³±±
±±³          ³ExpC2: Alias do arquivo de titulos                           ³±±
±±³          ³ExpC3: Alias do arquivo de compensacao                       ³±±
±±³          ³ExpA4: Array com os campos para criacao do arquivo           ³±±
±±³          ³ExpA5: Array com a nota e o cliente para o filtro            ³±±
±±³          ³ExpA6: Numero da Carga                                       ³±±
±±³          ³ExpA7: Sequencia da carga                                    ³±±
±±³          ³ExpA8: Objeto do browse de compensacao                       ³±±
±±³          ³ExpA9: Objeto do browse de titulos                           ³±±
±±³          ³ExpA10: Objeto da janela                                     ³±±
±±³          ³cExp11: Motivo da Baixa                                      ³±±
±±³          ³cExp12: Banco                                                ³±±
±±³          ³cExp13: Agencia                                              ³±±
±±³          ³cExp14: Conta                                                ³±±
±±³          ³dExp15: Data da baixa                                        ³±±
±±³          ³dExp16: Data do Credito                                      ³±±
±±³          ³nExp17: Valor Recebido                                       ³±±
±±³          ³nExp18: Valor Total a Receber                                ³±±
±±³          ³nExp19: Qtde de titulos                                      ³±±
±±³          ³nExp20: Valor dos titulos                                    ³±±
±±³          ³nExp21: Valor dos descontos                                  ³±±
±±³          ³nExp22: Valor dos juros                                      ³±±
±±³          ³nExp23: VAlor dos abatimentos                                ³±±
±±³          ³lExp24: Se foi chamada do botao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo gravar no arquivo temporario   ³±±
±±³          ³os titulos e NCCs de um determinado cliente da carga         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341Trb(nFldAtu,;
						aNotas,;
						cCarga,;
						cSeqCar,;
						oMarkCmp,;
						oMarkSE1,;
						oDlg,;
						cMotBx,;
						cBanco,;
						cAgencia,;
						cConta,;
						dBaixa,;
						dDataLiq,;
						dDtCredito,;
						nValRec,;
						nTotRec,;
						nQtdeTit,;
						nValTit,;
						nDescont,;
						nValJur,;
						nAbatim,;
						nPgParc,;
						oSayQtde,;
						oSayVal,;
						oSayRec,;
						lButton,;
						nEvento)

Local aArea     := GetArea()
Local aStruSE1  := SE1->(dbStruct())

Local cAliasSE1 := "SE1"
Local cCampos   := "TRB_MARCA#TRB_RECNO#TRB_FILTIT#TRB_OPERA#TRB_TPBAIX#TRB_BANCO#TRB_AGENC#TRB_CONTA#TRB_DATA#TRB_DTCRED#TRB_VALREC#TRB_VALJUR#TRB_VALDES#TRB_SEQUEN"
Local cQry      := ""

Local cRetPE    := ""
Local cFilCli   := ""

Local nX        := 0
Local lProcessa := .T.

Local lOM341QRY  := ExistBlock("OM341QRY")

Default nFldAtu  := 1
Default oSayQtde := Nil
Default oSayVal  := Nil
Default oSayRec  := Nil

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o tipo de operacao para pegar filial                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se foi chamada do botao para validar as movimentacoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If  lButton
		Oms341Ok(nFldAtu,;
		cCarga,;
		cSeqCar,;
		@cMotBx,;
		@cBanco,;
		@cAgencia,;
		@cConta,;
		@dBaixa,;
		@dDataLiq,;
		@dDtCredito,;
		@nValRec,;
		@nQtdeTit,;
		@nValTit,;
		@nDescont,;
		@nValJur,;
		@nAbatim,;
		@nPgParc,;
		@nTotRec,;
		oFolder,;
		oSayQtde,;
		oSayVal,;
		oSayRec,;
		nEvento)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa os arquivos de trabalho                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(__cAliTRB)
	Zap
	dbSelectArea(__cAliCPS)
	Zap
	dbSelectArea(__cAliPRC)
	Zap
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona os titulos do cliente                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE1")
	dbSetOrder(8) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_STATUS+DTOS(E1_VENCREA)

	cAliasSE1 := "SE1QRY"
	cQry := "SELECT SE1.*,SE1.R_E_C_N_O_ SE1RECNO"
	cQry +=  " FROM "+RetSqlName("SE1")+" SE1"
	cQry += " WHERE SE1.E1_FILIAL  = '"+xFilial("SE1")+"'"
	cQry +=   " AND SE1.E1_CLIENTE = '"+aNotas[2]+"'"
	cQry +=   " AND SE1.E1_LOJA    = '"+aNotas[3]+"'"
	cQry +=   " AND SE1.E1_STATUS  = 'A'"
	cQry +=   " AND SE1.D_E_L_E_T_ = ' '"
	If  lOM341QRY
		cRetPE := ExecBlock("OM341QRY",.F.,.F.,{cQry})
		cQry   := If(ValType(cRetPE)=="C", cRetPE, cQry)
	EndIf
	cQry += "ORDER BY "+SqlOrder(SE1->(IndexKey()))
	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cAliasSE1,.F.,.T.)
	For nX := 1 To Len(aStruSE1)
		If  aStruSE1[nX][2]!="C"
			TcSetField(cAliasSE1,aStruSE1[nX][1],aStruSE1[nX][2],aStruSE1[nX][3],aStruSE1[nX][4])
		EndIf
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza os arquivo de trabalho com base nos titulos do cliente  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (cAliasSE1)->(!Eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o titulo eh valido                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !((cAliasSE1)->E1_SITUACA $ "27" .Or. (cAliasSE1)->E1_SALDO == 0)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Traz todas as NCC's do cliente                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ((cAliasSE1)->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
				//-- Nao permite NCC com data posterior a data atual.
				If (cAliasSE1)->E1_EMISSAO <= dDataBase
					dbSelectArea(__cAliCPS)
					RecLock(__cAliCPS,.T.)
					For nX := 1 to Len(__aCampos)
						If !__aCampos[nX][1]$cCampos
							(__cAliCPS)->(FieldPut(FieldPos(__aCampos[nX][1]),(cAliasSE1)->(FieldGet(FieldPos(__aCampos[nX][1])))))
						EndIf
					Next nX
					(__cAliCPS)->TRB_RECNO := (cAliasSE1)->SE1RECNO
					(__cAliCPS)->(MsUnlock())
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Somente os titulos da carga sao validos                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  aScan(aNotas[5],{|x| OsFilial("SE1",x[1]) == (cAliasSE1)->E1_FILIAL .And. x[5] == (cAliasSE1)->E1_PREFIXO .And. x[4] == (cAliasSE1)->E1_NUM })>0 .And. ;
					(cAliasSE1)->E1_TIPO $ MVNOTAFIS
					dbSelectArea(__cAliTRB)
					RecLock(__cAliTRB,.T.)
						For nX := 1 to Len(__aCampos)
							If !__aCampos[nX][1]$cCampos
								(__cAliTRB)->(FieldPut(FieldPos(__aCampos[nX][1]),(cAliasSE1)->(FieldGet(FieldPos(__aCampos[nX][1])))))
							EndIf
						Next nX
						(__cAliTRB)->TRB_RECNO  := (cAliasSE1)->SE1RECNO
						(__cAliTRB)->TRB_FILTIT := (cAliasSE1)->E1_FILIAL
					(__cAliTRB)->(MsUnlock())
				EndIf
			EndIf
		EndIf
		(cAliasSE1)->(dbSkip())
	EndDo
	(cAliasSE1)->(dbCloseArea())

	Oms341VarBx(@cMotBx,;
				@cBanco,;
				@cAgencia,;
				@cConta,;
				@dBaixa,;
				@dDataLiq,;
				@dDtCredito,;
				@nValRec,;
				@nTotRec,;
				@nQtdeTit,;
				@nValTit,;
				@nDescont,;
				@nValJur,;
				@nAbatim,;
				@nPgParc,;
				.T.)

	If  lButton
		oSayQtde:SetText(Alltrim(Transform(nQtdeTit,"999999")))
		oSayVal:SetText(Alltrim(Transform(nValTit,"@R 99,999,999.99")))
		oSayRec:SetText(Alltrim(Transform(nTotRec,"@R 99,999,999.99")))
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a integradade da rotina                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(__cAliTRB)
	(__cAliTRB)->(dbGotop())

	dbSelectArea(__cAliCPS)
	(__cAliCPS)->(dbGotop())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua os refresh's na interface da rotina                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  oMarkCmp != Nil .And. oMarkSE1 != Nil .And. oDlg != Nil
		oMarkCmp:oBrowse:Refresh()
		oMarkSE1:oBrowse:Refresh()
		oDlg:Refresh()
	EndIf

RestArea(aArea)
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341TRB2³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de gravacao do arquivo temporario de titulos e NCCs   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Folder ativo no momento da chamada                    ³±±
±±³          ³ExpC2: Alias do arquivo de titulos                           ³±±
±±³          ³ExpC3: Alias do arquivo de compensacao                       ³±±
±±³          ³ExpA4: Array com os campos para criacao do arquivo           ³±±
±±³          ³ExpA5: Array com a nota e o cliente para o filtro            ³±±
±±³          ³ExpA6: Numero da Carga                                       ³±±
±±³          ³ExpA7: Sequencia da carga                                    ³±±
±±³          ³ExpA8: Objeto do browse de compensacao                       ³±±
±±³          ³ExpA9: Objeto do browse de titulos                           ³±±
±±³          ³ExpA10: Objeto da janela                                     ³±±
±±³          ³cExp11: Motivo da Baixa                                      ³±±
±±³          ³cExp12: Banco                                                ³±±
±±³          ³cExp13: Agencia                                              ³±±
±±³          ³cExp14: Conta                                                ³±±
±±³          ³dExp15: Data da baixa                                        ³±±
±±³          ³dExp16: Data do Credito                                      ³±±
±±³          ³nExp17: Valor Recebido                                       ³±±
±±³          ³nExp18: Valor Total a Receber                                ³±±
±±³          ³nExp19: Qtde de titulos                                      ³±±
±±³          ³nExp20: Valor dos titulos                                    ³±±
±±³          ³nExp21: Valor dos descontos                                  ³±±
±±³          ³nExp22: Valor dos juros                                      ³±±
±±³          ³nExp23: VAlor dos abatimentos                                ³±±
±±³          ³lExp24: Se foi chamada do botao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo gravar no arquivo temporario   ³±±
±±³          ³os titulos e NCCs de um determinado cliente da carga         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341Trb2(nFldAtu,;
						aClientes,;
						cCarga,;
						cSeqCar,;
						oMarkCmp,;
						oMarkSE1,;
						oDlg,;
						cMotBx,;
						cBanco,;
						cAgencia,;
						cConta,;
						dBaixa,;
						dDataLiq,;
						dDtCredito,;
						nValRec,;
						nTotRec,;
						nQtdeTit,;
						nValTit,;
						nDescont,;
						nValJur,;
						nAbatim,;
						nPgParc,;
						oSayQtde,;
						oSayVal,;
						oSayRec,;
						lButton)

Local aArea     := GetArea()
Local aStruSE1  := SE1->(dbStruct())

Local cAliasSE1 := "SE1"
Local cCampos   := "TRB_MARCA#TRB_RECNO#TRB_FILTIT#TRB_OPERA#TRB_TPBAIX#TRB_BANCO#TRB_AGENC#TRB_CONTA#TRB_DATA#TRB_DTCRED#TRB_VALREC#TRB_VALJUR#TRB_VALDES#TRB_SEQUEN"
Local cQry      := ""
Local cRetPE    := ""
Local nCntFor   := 0
Local nX        := 0
Local lOM341QRY  := ExistBlock("OM341QRY")

Default nFldAtu  := 1
Default oSayQtde := Nil
Default oSayVal  := Nil
Default oSayRec  := Nil

	For nCntFor := 1 to Len(aClientes)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona os titulos do cliente                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cAliasSE1 := "SE1QRY"
		cQry := "SELECT SE1.*,SE1.R_E_C_N_O_ SE1RECNO"
		cQry +=  " FROM "+RetSqlName("SE1")+" SE1"
		cQry += " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"'"
		cQry +=   " AND SE1.E1_CLIENTE = '"+aClientes[nCntFor][2]+"'"
		cQry +=   " AND SE1.E1_LOJA    = '"+aClientes[nCntFor][3]+"'"
		cQry +=   " AND SE1.E1_STATUS  = 'A'"
		cQry +=   " AND SE1.E1_SALDO   > 0"
		cQry +=   " AND SE1.E1_SITUACA NOT IN ('2','7')"
		cQry +=   " AND SE1.D_E_L_E_T_ = ' '"
		If  lOM341QRY
			cRetPE := ExecBlock("OM341QRY",.F.,.F.,{cQry})
			cQry   := If(ValType(cRetPE)=="C", cRetPE, cQry)
		EndIf
		cQry += "ORDER BY "+SqlOrder(SE1->(IndexKey(8)))
		cQry := ChangeQuery(cQry)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cAliasSE1,.F.,.T.)
		For nX := 1 To Len(aStruSE1)
			If  aStruSE1[nX][2]!="C"
				TcSetField(cAliasSE1,aStruSE1[nX][1],aStruSE1[nX][2],aStruSE1[nX][3],aStruSE1[nX][4])
			EndIf
		Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza os arquivo de trabalho com base nos titulos do cliente  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While (cAliasSE1)->(!Eof())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Traz todas as NCC's do cliente                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ((cAliasSE1)->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
				//-- Nao permite NCC com data posterior a data atual.
				If (cAliasSE1)->E1_EMISSAO <= dDataBase
					dbSelectArea(__cAliCPS)
					RecLock(__cAliCPS,.T.)
					For nX := 1 to Len(__aCampos)
						If !__aCampos[nX][1]$cCampos
							(__cAliCPS)->(FieldPut(FieldPos(__aCampos[nX][1]),(cAliasSE1)->(FieldGet(FieldPos(__aCampos[nX][1])))))
						EndIf
					Next nX
					(__cAliCPS)->TRB_RECNO := (cAliasSE1)->SE1RECNO
					(__cAliCPS)->(MsUnlock())
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Somente os titulos da carga sao validos                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  aScan(aClientes[nCntFor][5],{|x| OsFilial("SE1",x[1]) == (cAliasSE1)->E1_FILIAL .And. x[5] == (cAliasSE1)->E1_PREFIXO .And. x[4] == (cAliasSE1)->E1_NUM }) > 0 .And. ;
					(cAliasSE1)->E1_TIPO $ MVNOTAFIS
					dbSelectArea(__cAliTRB)
					RecLock(__cAliTRB,.T.)
						For nX := 1 to Len(__aCampos)
							If !__aCampos[nX][1]$cCampos
								(__cAliTRB)->(FieldPut(FieldPos(__aCampos[nX][1]),(cAliasSE1)->(FieldGet(FieldPos(__aCampos[nX][1])))))
							EndIf
						Next nX
						(__cAliTRB)->TRB_RECNO  := (cAliasSE1)->SE1RECNO
						(__cAliTRB)->TRB_FILTIT := (cAliasSE1)->E1_FILIAL
					(__cAliTRB)->(MsUnlock())
				EndIf
			EndIf
			(cAliasSE1)->(dbSkip())
		EndDo
		(cAliasSE1)->(dbCloseArea())
	Next nCntFor

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a integridade da rotina                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(__cAliTRB)
	(__cAliTRB)->(dbGotop())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua os refresh's na interface da rotina                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  oMarkCmp != Nil .And. oMarkSE1 != Nil .And. oDlg != Nil
		oMarkCmp:oBrowse:Refresh()
		oMarkSE1:oBrowse:Refresh()
		oDlg:Refresh()
	EndIf

RestArea(aArea)
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Oms341Chg ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Efetua a marca e atualizacao dos valores quando clicar na    ³±±
±±³          ³markbrowse                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Quantidade de titulos (por referencia)                ³±±
±±³          ³ExpN2: Valor do titulo marcado(por referencia)               ³±±
±±³          ³ExpN3: Total dos titulos marcadados(referencia)              ³±±
±±³          ³ExpN4: Valor dos juros (por referencia)                      ³±±
±±³          ³ExpN5: Valor dos descontos (por referencia)                  ³±±
±±³          ³ExpN6: Valor dos abatimentos (por referencia)                ³±±
±±³          ³ExpD7: Data da Baixa                                         ³±±
±±³          ³ExpD8: Motivo da baixa                                       ³±±
±±³          ³ExpD9: Moeda                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo mostrar os valores acumulados  ³±±
±±³          ³no folder da baixa                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341Chg(nQtdetit,;
						nValTit,;
						nTotRec,;
						nValJur,;
						nDescont,;
						nAbatim,;
						nPgParc,;
						nQtdCps,;
						nValCps,;
						dBaixa,;
						dDataLiq,;
						cMotBx,;
						nMoeda,;
						oSayQtde,;
						oSayVal,;
						oSayRec,;
						oSayQtdCp,;
						oSayValCp,;
						nPasta)

Local aArea    := GetArea()
Local aCliCmp  := {}
Local aCliTrb  := {}
Local nRecnoCPS:= (__cAliCPS)->(Recno())
Local nRecnoTRB:= (__cAliTRB)->(Recno())
Local lOMSCPS  := SuperGetMv("MV_OMSCPS",.F.,.T.) // .F. p/efetuar baixa de titulos dif.clientes
Local lComp    := .T.
Local aBaixas  := {}

Private lDescOms := .F. // mostra desconto para titulos baixados por compensacao

	Do Case
		Case nPasta == 1

			If (__cAliTRB)->E1_SALDO > 0

				If Empty((__cAliTRB)->TRB_OPERA)

					If ExistBlock("OS341MRK")   //-- Ponto de entrada que permite ou nao amarcacao de titulos
						If !ExecBlock("OS341MRK",.F.,.F.,{__cAliTRB,__cAliCPS,nQtdetit,nValTit,nTotRec,nValJur,nDescont,nAbatim,nPgParc,nQtdCps,;
														nValCps,dBaixa,dDataLiq,cMotBx,nMoeda,oSayQtde,oSayVal,oSayRec,oSayQtdCp,oSayValCp,nPasta})
							RestArea(aArea)
							Return
						EndIf
					EndIf

					RecLock(__cAliTRB,.F.)
						(__cAliTRB)->TRB_MARCA := Iif(Empty((__cAliTRB)->TRB_MARCA), cMarkSE1, "  ")
					MsUnlock()

					aBaixas := Baixas(  (__cAliTRB)->E1_NATUREZA,(__cAliTRB)->E1_PREFIXO,   (__cAliTRB)->E1_NUM,;
										(__cAliTRB)->E1_PARCELA, (__cAliTRB)->E1_TIPO,1,'R',(__cAliTRB)->E1_CLIENTE,,(__cAliTRB)->E1_LOJA )

					If aBaixas[9] == 'Compensacao'
						lDescOms := .T.
					EndIf
					SE1->(DbGoTo((__cAliTRB)->TRB_RECNO))
					aRetorno := FaVlAtuCr("SE1",dBaixa,TrazCodMot(cMotBx))


					//Atualiza o valor de desconto financeiro
					RecLock(__cAliTRB,.F.)
					(__cAliTRB)->E1_DESCONT   := aRetorno[FIN_VLRDES]
					MsUnlock()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Conforme a escolha dos titulos e calculada e atualizado³
					//³seus valores na pasta de baixa                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (__cAliTRB)->TRB_MARCA != cMarkSE1 //-- Desmarca Titulo
						If !Empty(aRetorno[3])
							nTotRec -= (__cAliTRB)->E1_VALOR -  nAbatim - aRetorno[FIN_VLRPRC]- IIF(aRetorno[9]>nDescont,nDescont,aRetorno[9])
						Else
							nTotRec -= (__cAliTRB)->E1_VALOR - aRetorno[FIN_VLRDES] - aRetorno[FIN_VLRDEC]
						EndIf
						nQtdeTit -= 1
						nValTit  -= aRetorno[FIN_VLRTIT] //-- Valor do Titulo
						nValJur  -= aRetorno[FIN_VLRJRS] //-- Juros
						nPgParc  -= aRetorno[FIN_VLRPRC] //-- Pagamentos Parciais
						nDescont -= aRetorno[FIN_VLRDES] //-- Descontos
						nDescont -= aRetorno[FIN_VLRDEC] //-- Decrescimo
						nAbatim  -= xMoeda(aRetorno[FIN_VLRABT],(__cAliTRB)->E1_MOEDA,nMoeda) //-- Abatimento
					Else //-- Marca Titulo
						nQtdeTit += 1
						nValTit  += aRetorno[FIN_VLRTIT] //-- Valor do Titulo
						nValJur  += aRetorno[FIN_VLRJRS] //-- Juros
						nPgParc  += aRetorno[FIN_VLRPRC] //-- Pagamentos Parciais
						nDescont += aRetorno[FIN_VLRDES] //-- Descontos
						nDescont += aRetorno[FIN_VLRDEC] //-- Decrescimo
						nAbatim  += xMoeda(aRetorno[FIN_VLRABT],(__cAliTRB)->E1_MOEDA,nMoeda) //-- Abatimento
						If !Empty(aRetorno[3])
							nTotRec += (__cAliTRB)->E1_VALOR -  nAbatim - aRetorno[FIN_VLRPRC]- IIF(aRetorno[9]>nDescont,nDescont,aRetorno[9])
						Else
							nTotRec += (__cAliTRB)->E1_VALOR - aRetorno[FIN_VLRDES] - aRetorno[FIN_VLRDEC]
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Calcula o valor liquido da operacao                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Else
					nQtdeTit := 0
					nValTit  := 0
					nTotRec  := 0
				EndIf

			EndIf

			oSayQtde:SetText(Alltrim(Transform(nQtdeTit,"999999") ) )
			oSayVal:SetText(Alltrim(Transform(nValTit,"@R 99,999,999.99") ) )
			oSayRec:SetText(Alltrim(Transform(nTotRec,"@R 99,999,999.99") ) )

		Case nPasta == 2

			RecLock(__cAliCPS,.F.)
			(__cAliCPS)->TRB_MARCA  := Iif(Empty((__cAliCPS)->TRB_MARCA), cMarkCmp, "  ")
			(__cAliCPS)->(MsUnlock())

			If  lOMSCPS
				dbSelectArea(__cAliCPS)
				(__cAliCPS)->(dbGotop())
				While (__cAliCPS)->(!Eof())
					If (__cAliCPS)->TRB_MARCA == cMarkCmp

						If Ascan(aCliCmp,{|x| x[1]+x[2] == (__cAliCPS)->E1_CLIENTE+(__cAliCPS)->E1_LOJA }) == 0
							Aadd(aCliCmp,{(__cAliCPS)->E1_CLIENTE,(__cAliCPS)->E1_LOJA})
						EndIf

						If Len(aCliCmp) > 1
							lComp := .F.
							Help(" ",1,"OMS341CPS")
							Exit
						EndIf
					EndIf

					(__cAliCPS)->(dbSkip())
				EndDo

				If lComp
					dbSelectArea(__cAliTRB)
					(__cAliTRB)->(dbGotop())
					While (__cAliTRB)->(!Eof())

						If (__cAliTRB)->TRB_MARCA == cMarkSE1

							If Ascan(aCliTrb,{|x| x[1]+x[2] == (__cAliTRB)->E1_CLIENTE+(__cAliTRB)->E1_LOJA }) == 0
								Aadd(aCliTrb,{(__cAliTRB)->E1_CLIENTE,(__cAliTRB)->E1_LOJA})
							EndIf

							If Len(aCliTrb) > 1
								lComp := .F.
								Help(" ",1,"OMS341CPS")
								Exit
							EndIf
						EndIf

						(__cAliTRB)->(dbSkip())

					EndDo
				EndIf

				(__cAliCPS)->(MsGoto(nRecnoCps))
				(__cAliTRB)->(MsGoto(nRecnoTrb))

				If Len(aCliCmp) > 0 .And. Len(aCliTrb) > 0
					If ( aCliCmp[1][1]+aCliCmp[1][2] <> aCliTrb[1][1]+aCliTrb[1][2] )
						lComp := .F.
						Help(" ",1,"OMS341CPS")
					EndIf
				EndIf

			EndIf
			If lComp
				If (__cAliCPS)->TRB_MARCA != cMarkCmp
					nQtdCps  -= 1
					nValCps  -= (__cAliCPS)->E1_SALDO
				Else
					nQtdCps  += 1
					nValCps  += (__cAliCPS)->E1_SALDO
				EndIf

				oSayQtdCp:SetText(Alltrim(Transform(nQtdCps,"999999") ) )
				oSayValCp:SetText(Alltrim(Transform(nValCps,"@R 99,999,999.99") ) )
			Else
				RecLock(__cAliCPS,.F.)
				(__cAliCPS)->TRB_MARCA  := Iif(Empty((__cAliCPS)->TRB_MARCA), cMarkCmp, "  ")
				(__cAliCPS)->(MsUnlock())
			EndIf

	EndCase

RestArea(aArea)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341VIS ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Efetua a visualizacao do titulo posicionado                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do arquivo de titulos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo visualizar o titulo posiciona  ³±±
±±³          ³do                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341Vis()
Local aArea    := GetArea()
Local aAreaSE1 := SE1->(GetArea())

Local cFilSE1   := ""

Local nTipoOper := OsVlEntCom()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o tipo de operacao para pegar filial                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cFilSE1 := Iif (nTipoOper == 1, xFilial("SE1"),(__cAliTRB)->TRB_FILTIT )

	dbSelectArea("SE1")
	SE1->(dbSetOrder(2))
	If SE1->(dbSeek(OsFilial("SE1",(__cAliTRB)->TRB_FILTIT)+(__cAliTRB)->E1_CLIENTE+(__cAliTRB)->E1_LOJA+(__cAliTRB)->E1_PREFIXO+(__cAliTRB)->E1_NUM+(__cAliTRB)->E1_PARCELA+(__cAliTRB)->E1_TIPO))
		AxVisual("SE1",SE1->(Recno()),2)
	EndIf

RestArea(aAreaSE1)
RestArea(aArea)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341FLD ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Efetua o tratamento e validacao dos folders                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Folder de Destino                                    ³±±
±±³          ³ExpN2 : Folder Atual                                         ³±±
±±³          ³ExpO3 : Objeto do Folder                                     ³±±
±±³          ³ExpA4 : Array com as getdados.                               ³±±
±±³          ³ExpN5 : Valor recebido                                       ³±±
±±³          ³ExpN6 : VAlor dos titulos escolhidos                         ³±±
±±³          ³ExpN7 : Alias do arquivo de titulos                          ³±±
±±³          ³ExpN8 : Alias do arquivo de compensacao                      ³±±
±±³          ³ExpN9 : Marca da markbrowse                                  ³±±
±±³          ³ExpN10: Banco da baixa                                       ³±±
±±³          ³ExpN11: Agencia                                              ³±±
±±³          ³ExpN12: Conta                                                ³±±
±±³          ³ExpD13: Data da baixa                                        ³±±
±±³          ³ExpD14: Data do Credito                                      ³±±
±±³          ³ExpN15: Total recebido                                       ³±±
±±³          ³ExpN16: Quantidade de titulos                                ³±±
±±³          ³ExpN17: Valor dos titulos                                    ³±±
±±³          ³ExpN18: Valor dos Descontos                                  ³±±
±±³          ³ExpN19: Valor dos Juros                                      ³±±
±±³          ³ExpN20: Valor dos Abatimentos                                ³±±
±±³          ³ExpN21: Valor dos titulos                                    ³±±
±±³          ³ExpN22: Valor dos Recebido                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. - Possibilita a troca de acordo com as validacoes        ³±±
±±³          ³.F. - Nao possibilita a troca de acordo com as validacoes    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo validar os folders na troca    ³±±
±±³          ³dos mesmos                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341Fld(nFldDst,;
							nFldAtu,;
							oFolder,;
							aGetDad,;
							cCarga,;
							cSeqCar,;
							cMotBx,;
							cBanco,;
							cAgencia,;
							cConta,;
							dBaixa,;
							dDataLiq,;
							dDtCredito,;
							nTotRec,;
							nQtdeTit,;
							nValTit,;
							nDescont,;
							nValJur,;
							nAbatim,;
							nPgParc,;
							nValRec,;
							nQtdCps,;
							nValCps,;
							oSayQtde,;
							oSayval,;
							oSayRec,;
							oSayQtdCp,;
							oSayValCp,;
							cMarkSE1)


Local aArea      := GetArea()
Local aAreaCPS   := (__cAliCPS)->(GetArea())

Local nTpBaixa   := 0

Local lRetorno   := .T.
Local lTrocouDst := .F.
Local lTrocouAtu := .F.

	nTpBaixa := Oms341TpBx(nFldAtu,nValRec)

	If nTpBaixa > 0 .And. nFldAtu > 2 .And. nFldDst > 2
		Help(,1,"OMS341ABA",,STR0098,1,0,,,,,,/*aSolucao*/) // "Ao selecionar a execução de algum tipo de baixa, só será possível retornar para as abas 'Conferir' ou 'Títulos'!"
		Return .F.
	EndIf

	If nTpBaixa == 3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida os dados digitados na baixa para permitir a baixa na troca de folder³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRetorno := Oms341VlBx(nValRec,nTotRec,cBanco,cAgencia,cConta,dBaixa,dDtCredito,.F.,cMotBx)
		//-- Restaura Foco para ComboBox Motivos da Baixa.
		oCbx:SetFocus()
		oCbx:Refresh()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se passou pelas validacoes e existem baixas a serem realizadas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lRetorno

		Do Case
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida as baixas selecionados                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case ( nTpBaixa != 0 .And. nFldAtu != 1 .And. nFldAtu != 2 )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processo a execucao da baixa caso tenha movimentacao               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			lRetorno := Oms341Proc(oFolder,;
							nTpBaixa,;
							cCarga,;
							cSeqCar,;
							@cMotBx,;
							@cBanco,;
							@cAgencia,;
							@cConta,;
							@dBaixa,;
							@dDataLiq,;
							@dDtCredito,;
							@nValRec,;
							@nQtdeTit,;
							@nValTit,;
							@nDescont,;
							@nValJur,;
							@nAbatim,;
							@nPgParc,;
							@nTotRec,;
							@nQtdCps,;
							@nValCps,;
							oSayQtde,;
							oSayVal,;
							oSayRec,;
							oSayQtdCp,;
							oSayValCp)

			If (nFldDst == 2 .Or. nFldDst == 1) .And. !lRetorno
				lRetorno := .T.
			EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se foi escolhido titulos para a movimentacao          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case ( nFldAtu == 1 .Or. nFldAtu == 2 ) .And.;
			 ( nFldDst == 3 .Or. nFldDst == 4 .Or. nFldDst == 5 )

			If nValtit == 0
				Help(" ",1,"OMS341NTIT") //"Nao ha titulos escolhidos para movimentacao."
				lRetorno := .F.
			EndIf

			Do Case
				Case nTpBaixa  == 3 .And. nFldDst != 3
					Help(" ",1,"OMS341BAIX") //"Existem baixas simples a serem processadas."
					lRetorno := .F.
				Case nTpBaixa  == 4 .And. nFldDst != 4
					Help(" ",1,"OMS341LIQ") //"Existem liquidacoes pendentes a serem processadas."
					lRetorno := .F.
				Case nTpBaixa  == 5 .And. nFldDst != 5
					Help(" ",1,"OMS341COMP") //"Existem compensacoes pendentes a serem processadas."
					lRetorno := .F.
			EndCase
		EndCase

		If ( nFldDst == 1 .Or. nFldDst == 4 ) .And. lRetorno
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifico a utilizacao do folder 3 caso esteja nele³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Do Case
				Case ( nFldDst == 4 )
					nFldDst := 2
					lTrocouDst := .T.
				Case ( nFldAtu == 4 )
					nFldAtu := 2
					lTrocouAtu := .T.
			EndCase
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetua a Validacao da GetDados                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( nFldAtu == 1 ) .Or. ( nFldAtu == 2 .And. lTrocouAtu )
				aGetDad[nFldAtu]:oBrowse:lDisablePaint := .T.
			EndIf
			Do Case
				Case ( nFldAtu == 1 )
					aCols1  := aClone(aCols)
					aHeader1:= aClone(aHeader)
				Case ( nFldAtu == 2 .And. lTrocouAtu )
					aCols2  := aClone(aCols)
					aHeader2:= aClone(aHeader)
			EndCase

			n := Max(aGetDad[nFldDst]:oBrowse:nAt,1)

			Do Case
				Case ( nFldDst == 1 )
					aCols   := aClone(aCols1)
					aHeader := aClone(aHeader1)
					aGetDad[nFldDst]:oBrowse:lDisablePaint := .F.
					aGetDad[nFldDst]:oBrowse:Refresh(.T.)
				Case ( nFldDst == 2 .And. lTrocouDst )
					aCols   := aClone(aCols2)
					aHeader := aClone(aHeader2)
					aGetDad[nFldDst]:oBrowse:lDisablePaint := .F.
					aGetDad[nFldDst]:oBrowse:Refresh(.T.)
				EndCase
		EndIf
	EndIf

	If ExistBlock("OS341FLD")
		lRet := ExecBlock("OS341FLD",.F.,.F.,{nFldDst, nFldAtu, oFolder, aGetDad, __cAliTRB, __cAliCPS, __cAliPRC, cCarga, cSeqCar})
		If ValType(lRet)=="L"
			lRetorno := lRet
		EndIf
	EndIf

RestArea(aAreaCPS)
RestArea(aArea)
Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Oms341Ref ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Efetua o refresh quando e trocada a getdados de acordo com   ³±±
±±³          ³o folder escolhido                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 : Array com a Getdados                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nemhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar o refresh no objeto da ³±±
±±³          ³getdados na troca dos folders                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341Ref(aGetDad)
Local nLoop := 1

	aGetDad[nLoop]:oBrowse:lDisablePaint := .F.
	aGetDad[nLoop]:oBrowse:Refresh(.T.)

Return( .T. )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Oms341PROC³ Autor ³ Henry Fila            ³ Data ³27.07.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Funcao que processa a movimentacao de baixa antes da movimen ³±±
±±³          ³tacao efetiva                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExp1 : Folder ativo da movimentacao                         ³±±
±±³          ³nExp2 : Tipo da baixa [1]Simples - [2]Liq. - [3]Compensacao  ³±±
±±³          ³cExp3 : Alias do arquivo temporario                          ³±±
±±³          ³cExp4 : Alias do arquivo temporario da compensacao           ³±±
±±³          ³cExp5 : Carga                                                ³±±
±±³          ³cExp6 : Sequencia da carga                                   ³±±
±±³          ³cExp7 : Motivo da Baixa                                      ³±±
±±³          ³cExp8 : Banco                                                ³±±
±±³          ³cExp9 : Agencia                                              ³±±
±±³          ³cExp10: Conta                                                ³±±
±±³          ³dExp11: Data da baixa                                        ³±±
±±³          ³dExp12: Data do Credito                                      ³±±
±±³          ³nExp13: Valor Recebido                                       ³±±
±±³          ³nExp14: Quantidade de titulos                                ³±±
±±³          ³nExp15: Valor Total a Receber                                ³±±
±±³          ³nExp16: Descontos                                            ³±±
±±³          ³nExp17: Juros                                                ³±±
±±³          ³nExp18: Abatimentos                                          ³±±
±±³          ³nExp19: Valor Total a Receber Liquido                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. - Processou a pre movimentacao                           ³±±
±±³          ³.F. - Nao processou a pre movimentacao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341Proc(oFolder,;
							nTpBaixa,;
							cCarga,;
							cSeqCar,;
							cMotBx,;
							cBanco,;
							cAgencia,;
							cConta,;
							dBaixa,;
							dDataLiq,;
							dDtCredito,;
							nValRec,;
							nQtdeTit,;
							nValTit,;
							nDescont,;
							nValJur,;
							nAbatim,;
							nPgParc,;
							nTotRec,;
							nQtdCps,;
							nValCps,;
							oSayQtde,;
							oSayVal,;
							oSayRec,;
							oSayQtdCp,;
							oSayValCp)

Local aArea     := GetArea()
Local cDesc     := ""
Local cLote     := ""
Local cTpBaixa  := ""
Local cSequen   := ""
Local lProcessa := .T.
Local nPosTotRl := Ascan(aHeader1,{|x| Alltrim(x[2]) == "DAP_REALIZ"})
Local nPosTotBx := Ascan(aHeader1,{|x| Alltrim(x[2]) == "DAP_VLRBX"})
Local nPosLq    := Ascan(aCols1,{|x| Alltrim(x[1]) == "LQ"})
Local nPosBx    := Ascan(aCols1,{|x| Alltrim(x[1]) == "BX"})
Local nPosCp    := Ascan(aCols1,{|x| Alltrim(x[1]) == "CP"})
Local nPosOt    := Ascan(aCols1,{|x| Alltrim(x[1]) == "OT"})
Local nVlrCh    := 0
Local nSldRec   := 0
Local nRecTit   := 0
Local nSldTitAnt:= 0
Local nUsado    := 0
Local nX        := 0
Local nPosStatus:= 0
Local nRecTRB   := 0
Local nPosPref  := 0
Local nPosBco   := 0
Local nPosAge   := 0
Local nPosCta   := 0
Local nPosNum   := 0
Local nPosData  := 0
Local nPosVlrCh := 0
Local nPosCli   := 0
Local nPosLoja  := 0
Local nSeek     := 0
Local nSoma     := 0
Local nJuros    := 0
Local aSoma     := {}
Local aValCPS   := {}
Local aFirst    := {0,0}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico pelo folder o tipo de baixa para gravar no TRB                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Do Case
		Case nTpBaixa == 3
			cTpBaixa := "1"
			If nPosBx > 0
				If nValRec + aCols1[nPosBx][nPosTotBx] > aCols1[nPosBx][nPosTotRl]
					cDesc := OemtoAnsi(STR0067) //"O Valor Total das baixas e maior que o realizado."
				EndIf
			Else
				If nValRec + aCols1[nPosOt][nPosTotBx] > aCols1[nPosOt][nPosTotRl]
					cDesc := OemtoAnsi(STR0069) //"O Valor Total e maior que o realizado."
				EndIf
			EndIf

		Case nTpBaixa == 4
			cTpBaixa := "2"
			If oFolder:nOption == 4
				aCols2   := aClone(aCols)
				aHeader2 := aClone(aHeader)
			EndIf
			nUsado := Len(aHeader2)+1

			nPosVlrCh := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_VLCRUZ"} )
			nPosPref  := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_PREFIXO"} )
			nPosBco   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_BCOCHQ"} )
			nPosAge   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_AGECHQ"} )
			nPosCta   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_CTACHQ"} )
			nPosNum   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_NUM"} )
			nPosData  := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_VENCTO"} )
			nPosStatus:= Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_ADM"} )
			nPosCli   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "DA7_CLIENT"} )
			nPosLoja  := Ascan(aHeader2,{|x| Alltrim(x[2]) == "DA7_LOJA"} )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida as baixas com o realizado na conferencia                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 to Len(aCols2)

				If (Empty(aCols2[nX][nPosBco]) .Or. Empty(aCols2[nX][nPosAge] ) .Or.;
					Empty(aCols2[nX][nPosCta]) .Or. Empty(aCols2[nX][nPosNum] ) .Or. Empty(aCols2[nX][nPosData]).Or. ;
					Empty(aCols2[nX][nPosCli]) .Or. Empty(aCols2[nX][nPosLoja]) .Or.;
					Empty(aCols2[nX][nPosVlrCh]) ) .And. !aCols2[nX][nUsado]
					Help(" ",1,"OBRIGAT")
					lProcessa := .F.
				EndIf

				If !aCols2[nX][nUsado] .And. Empty(aCols2[nX][nPosStatus])
					// Calcula o valor total das liquidações
					nVlrCh += aCols2[nX][nPosVlrCh]
					// Grava no array o total de liquidações por cliente/loja
					If (nSoma := aScan(aSoma,{|x| x[1]+x[2] == aCols2[nX][nPosCli]+aCols2[nX][nPosLoja]})) == 0
						Aadd(aSoma,{aCols2[nX][nPosCli],aCols2[nX][nPosLoja],aCols2[nX][nPosVlrCh]})
					Else
						aSoma[nSoma][3] += aCols2[nX][nPosVlrCh]
					EndIf
				EndIf

			Next

			If lProcessa
				If nPosLq > 0 
				   If nVlrCh + aCols1[nPosLq][nPosTotBx] > aCols1[nPosLq][nPosTotRl]
					   cDesc := OemtoAnsi(STR0066) //"O Valor Total das liquidacoes e maior que o realizado."
			       EndIf 
				Else
				   If nPosOt > 0 .And. (nVlrCh + aCols1[nPosOt][nPosTotBx] > aCols1[nPosOt][nPosTotRl])
					  cDesc := OemtoAnsi(STR0069) //"O Valor Total e maior que o realizado."
				   EndIf 
				EndIf
			EndIf
	EndCase

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a esta no folder correto para  a movimentacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  lProcessa

		Do Case
		Case nTpBaixa == 3
			cDesc += OemtoAnsi(STR0031) //"Confirma baixa dos titulos selecionados ?"
		Case nTpBaixa == 4
			cDesc += OemtoAnsi(STR0032) //"Confirma liquidacao dos titulos selecionados ?"
		Case nTpBaixa == 5
			cDesc += OemtoAnsi(STR0033) //"Confirma compensacao dos titulos selecionados ?"
		EndCase

		nRecTRB := (__cAliTRB)->(Recno())

		If  MsgYesNo(cDesc)
			cSequen := Oms341Seq()
			If nTpBaixa == 5
				//Regra para compensação de títulos
				lProcessa := OmsProcCmp(aFirst,cSequen)
			Else
				dbSelectArea(__cAliTRB)
				(__cAliTRB)->(dbSetOrder(1))
				(__cAliTRB)->(dbGotop())

				nSldRec := Iif(nTpBaixa == 3,nValRec,Iif(nTpBaixa == 4,nVlrCh,nValCps))

				While (__cAliTRB)->(!Eof()) .And. nSldRec > 0
					If !Empty((__cAliTRB)->TRB_MARCA)

						nSldTitAnt := (__cAliTRB)->E1_SALDO
						nRecTit    := 0

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Calcula saldos dos titulos no browse de marcacao ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RecLock(__cAliTRB,.F.)
						Do Case
							Case nTpBaixa == 3
								If ((__cAliTRB)->E1_SALDO - nSldRec - (__cAliTRB)->E1_DESCONT) <= 0
									nJuros  := nSldRec-(__cAliTRB)->E1_SALDO+(__cAliTRB)->E1_DESCONT
									(__cAliTRB)->E1_SALDO := 0
									nRecTit := (nSldTitAnt-(__cAliTRB)->E1_SALDO-(__cAliTRB)->E1_DESCONT)
								Else
									nJuros := nSldRec-(__cAliTRB)->E1_SALDO
									(__cAliTRB)->E1_SALDO := (__cAliTRB)->E1_SALDO - nSldRec
									nRecTit := (nSldTitAnt-(__cAliTRB)->E1_SALDO )
								EndIf
							Case nTpBaixa == 4
								nSoma := aScan(aSoma,{|x| x[1]+x[2] == (__cAliTRB)->E1_CLIENTE+(__cAliTRB)->E1_LOJA})
								If nSoma == 0
									nSoma := aScan(aSoma,{|x| Empty(x[1])})
								EndIf
								If nSoma <> 0
									If (__cAliTRB)->E1_SALDO - (__cAliTRB)->E1_DESCONT - aSoma[nSoma][3] > 0
										(__cAliTRB)->E1_SALDO := (__cAliTRB)->E1_SALDO - aSoma[nSoma][3]
									Else
										(__cAliTRB)->E1_SALDO := 0
									EndIf
									aSoma[nSoma][3] -= (nSldTitAnt-(__cAliTRB)->E1_SALDO)
									nRecTit := (nSldTitAnt-(__cAliTRB)->E1_SALDO-(__cAliTRB)->E1_DESCONT)
								EndIf
						EndCase
						(__cAliTRB)->(MsUnlock())

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Grava no temporario de processamento os dados que serao baixados ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nRecTit > 0

							nSldRec -= nRecTit

							RecLock(__cAliPRC,.T.)
							(__cAliPRC)->TRB_RECNO := (__cAliTRB)->TRB_RECNO
							(__cAliPRC)->TRB_FILTIT:= (__cAliTRB)->TRB_FILTIT
							(__cAliPRC)->TRB_SEQUEN:= cSequen
							(__cAliPRC)->TRB_OPERA := cTpBaixa
							(__cAliPRC)->E1_NUM    := (__cAliTRB)->E1_NUM
							(__cAliPRC)->E1_TIPO   := (__cAliTRB)->E1_TIPO
							(__cAliPRC)->E1_PARCELA:= (__cAliTRB)->E1_PARCELA
							(__cAliPRC)->E1_PREFIXO:= (__cAliTRB)->E1_PREFIXO
							(__cAliPRC)->E1_VALOR  := (__cAliTRB)->E1_VALOR
							(__cAliPRC)->E1_CLIENTE:= (__cAliTRB)->E1_CLIENTE
							(__cAliPRC)->E1_LOJA   := (__cAliTRB)->E1_LOJA
							If  nTpBaixa == 3
								(__cAliPRC)->TRB_BANCO  := cBanco
								(__cAliPRC)->TRB_AGENC  := cAgencia
								(__cAliPRC)->TRB_CONTA  := cConta
								(__cAliPRC)->TRB_TPBAIX := cMotBx
								(__cAliPRC)->TRB_DATA   := dBaixa
								(__cAliPRC)->TRB_DTCRED := dDtCredito
								(__cAliPRC)->TRB_VALREC := nRecTit
								(__cAliPRC)->TRB_VALDES := (__cAliTRB)->E1_DESCONT
							EndIf
							(__cAliPRC)->(MsUnlock())

							aFirst[1] := (__cAliTRB)->(Recno())
							aFirst[2] := (__cAliPRC)->(Recno())
						Else
							aFirst[1] := (__cAliTRB)->(Recno())
						EndIf
					EndIf
					(__cAliTRB)->(dbSkip())
				EndDo
			EndIf
			
			//Se houver sobre de recebimento eh sinal que ouve um recebimento
			//a maior que deve ser adicionado no primeiro item
			If aFirst[2] <> 0
				dbSelectArea(__cAliPRC)
				MsGoto(aFirst[2])
				RecLock(__cAliPRC)
				If  nSldRec > 0
					(__cAliPRC)->TRB_VALREC += nSldRec
					(__cAliPRC)->TRB_VALJUR += nSldRec
				Else
					If ((__cAliPRC)->E1_VALOR - (__cAliPRC)->TRB_VALREC - (__cAliPRC)->TRB_VALDES + (__cAliPRC)->TRB_VALJUR) <= GetNewPar("MV_OSTLREC",0)
						(__cAliPRC)->TRB_VALDES += (__cAliPRC)->E1_VALOR - (__cAliPRC)->TRB_VALREC - (__cAliPRC)->TRB_VALDES + (__cAliPRC)->TRB_VALJUR
					EndIf
					If nJuros > 0 .And. nJuros <= GetNewPar("MV_OSTLREC",0)
						nSldRec -= nJuros
						(__cAliPRC)->TRB_VALREC += nJuros
						(__cAliPRC)->TRB_VALJUR := nJuros
					EndIf
				EndIf
				(__cAliPRC)->(MsUnLock())
			EndIf
			
			//Atualiza o resumo do primeiro folder
			Do Case

				Case nTpBaixa == 3

					If  nPosBx > 0
						aCols1[nPosBx][nPosTotBx] += nValRec
					Else
						aCols1[nPosOt][nPosTotBx] += nValRec
					EndIf

				Case nTpBaixa == 4

					nPosStatus := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_ADM"} )

					For nX := 1 to Len(aCols2)

						If  Empty(aCols2[nX][nPosStatus]) .And. !aCols2[nX][nUsado]

							If  nPosLq > 0
								aCols1[nPosLq][nPosTotBx] += aCols2[nX][7]
							Else
								aCols1[nPosOt][nPosTotBx] += aCols2[nX][7]
							EndIf

							aCols2[nX][nPosStatus] := cSequen

						EndIf

					Next

					aCols := aClone(aCols2)
			EndCase

			//-- Guarda cheques informados para processamento da baixa.
			If  nTpBaixa == 3
				If  Len(aColsSEF) > 0
					aColsCHQ := aClone(aColsSEF)
					aColsSEF := {}
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se for baixa simples zero as variaveis da pasta          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Oms341VarBx(@cMotBx,;
						@cBanco,;
						@cAgencia,;
						@cConta,;
						@dBaixa,;
						@dDataLiq,;
						@dDtCredito,;
						@nValRec,;
						@nTotRec,;
						@nQtdeTit,;
						@nValTit,;
						@nDescont,;
						@nValJur,;
						@nAbatim,;
						@nPgParc,;
						.F.)

			CalcTits(@nQtdeTit,@nValTit,@nTotRec,nValJur)

			nQtdCps  := 0
			nValCps  := 0
		//-- Setar variavel p/ nao deixar mais selecionar titulos.
		Else
			lProcessa := .F.
		EndIf

		oSayQtde:SetText(Alltrim(Transform(nQtdeTit,"999999")))
		oSayVal:SetText(Alltrim(Transform(nValTit,"@R 99,999,999.99")))
		oSayRec:SetText(Alltrim(Transform(nTotRec,"@R 99,999,999.99")))

		If oSayQtdCp != Nil
			oSayQtdCp:SetText(Alltrim(Transform(nQtdCPS,"999999")))
			oSayValCp:SetText(Alltrim(Transform(nValCPS,"@R 99,999,999.99")))
		EndIf
	
	EndIf

	(__cAliTRB)->(MsGoto(nRecTRB))

	oMarkCmp:oBrowse:Refresh()
	oMarkSE1:oBrowse:Refresh()

RestArea(aArea)
Return(lProcessa)

//----------------------------------------------------------
/*/{Protheus.doc} CalcTits
Calcula quantidade, valor e saldo a receber dos títulos selecionados
@author  Guilherme A. Metzger
@version P12
@since   10/09/2018
/*/
//----------------------------------------------------------
Static Function CalcTits(nQtdeTit,nValTit,nTotRec,nValJur)
Local aAreaAnt  := GetArea()
Local cAliasQry := GetNextAlias()
Local cQuery    := ""
Local aTamSX3   := {}

	cQuery := "SELECT COUNT(*) TRB_QTDTIT,"
	cQuery +=       " SUM(E1_VALOR  ) E1_VALOR,"
	cQuery +=       " SUM(E1_SALDO  ) E1_SALDO,"
	cQuery +=       " SUM(E1_DESCONT) E1_DESCONT"
	cQuery +=  " FROM " + __oTempSE1:GetRealName()
	cQuery += " WHERE TRB_MARCA  = '"+cMarkSE1+"'"
	cQuery +=   " AND E1_SALDO   > 0"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	TcSetField(cAliasQry,"TRB_QTDTIT","N",3         ,0         ); aTamSX3 := TamSX3("E1_VALOR")
	TcSetField(cAliasQry,"E1_VALOR"  ,"N",aTamSX3[1],aTamSX3[2]); aTamSX3 := TamSX3("E1_SALDO")
	TcSetField(cAliasQry,"E1_SALDO"  ,"N",aTamSX3[1],aTamSX3[2]); aTamSX3 := TamSX3("E1_DESCONT")
	TcSetField(cAliasQry,"E1_DESCONT","N",aTamSX3[1],aTamSX3[2])
	If !(cAliasQry)->(Eof())
		nQtdeTit := (cAliasQry)->TRB_QTDTIT
		nValTit  := (cAliasQry)->E1_VALOR
		nTotRec  := (cAliasQry)->E1_SALDO-(cAliasQry)->E1_DESCONT+nValJur
	EndIf
	(cAliasQry)->(DbCloseArea())

RestArea(aAreaAnt)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341OK  ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Efetua o processamento efetivo dos titulos do cliente        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Alias do arquivo de titulos                          ³±±
±±³          ³ExpC2 : Alias do arquivo de compensacao                      ³±±
±±³          ³ExpC3 : Numero da carga                                      ³±±
±±³          ³ExpC4 : Sequencia da carga                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³1  - Processamento OK                                        ³±±
±±³          ³2  - Processamento nao realizado                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo processar os titulos efetiva-  ³±±
±±³          ³mente na prestacao de contas financeiras                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341Ok(nFldAtu,;
						cCarga,;
						cSeqCar,;
						cMotBx,;
						cBanco,;
						cAgencia,;
						cConta,;
						dBaixa,;
						dDataLiq,;
						dDtCredito,;
						nValRec,;
						nQtdeTit,;
						nValTit,;
						nDescont,;
						nValJur,;
						nAbatim,;
						nPgParc,;
						nTotRec,;
						oFolder,;
						oSayQtde,;
						oSayVal,;
						oSayRec,;
						nEvento,;
						aColsSEF,;
						cHistBx)


Local cMotBxProc  := ""
Local cBancoProc  := ""
Local cAgeProc    := ""
Local cContaProc  := ""
Local dBxLiq      := dDataLiq
Local cFilBaixa   := ""
Local cFilBak     := ""
Local cSeqTrb     := ""
Local cCliente    := ""
Local cLoja       := ""

Local nRetorno    := 0
Local nValRecProc := 0
Local nTpBaixa    := 0
Local nPosPref    := 0
Local nPosBco     := 0
Local nPosAge     := 0
Local nPosCta     := 0
Local nPosNum     := 0
Local nPosData    := 0
Local nPosVlrCh   := 0
Local nPosStatus  := 0
Local nPosCli     := 0
Local nPosLoja    := 0
Local nPosEmit    := 0
Local nUsado2     := Len(aHeader2)
Local nX          := 0
Local nCntFor     := 0
Local nLoop       := 0
Local nY          := 0
Local nZ          := 0
Local nSeek       := 0

Local aSe1Bx      := {}
Local aSe1Liq     := {}
Local aSe1Ref     := {}
Local aSe1Cps     := {}
Local aBaixa      := {}
Local aNCC        := {}
Local aLiq        := {}
Local aColsLiq    := {}
Local aParam      := {}
Local aSE1Dados   := {}
Local aValores    := {}
Local aAuxLiq     := {}
Local aAuxSE1     := {}
Local aCpoUser    := {}
Local aColsSav    := {}
Local lBaixa      := .T.
Local lRet        := .T.
Local cSldBxCr    := SuperGetMv("MV_SLDBXCR",.F.,"B")
Local lGRSEFLQ    := SuperGetMv("MV_GRSEFLQ",.F.,.F.)  // Indica se deve gravar SEF na liquidacao
Local aColsSEFLiq := {}
Local cSeqSE5     := "01"
Local nToler      := (GetNewPar("MV_OSTLREC",0))
Local lOMS341CHQ  := ExistBlock("OMS341CHQ")
Local lOMS341SEF  := ExistBlock("OMS341SEF")

Local cQuery      := ""
Local cAliasQry   := ""

DEFAULT aColsSEF  := {}
DEFAULT cHistBx   := ""

Private nSomaCheq := 0
Private lDescOms  := .F.
	


	//-- Adiciona parametros para a funcao de baixa baseado na pergunta do F12
	Pergunte("OMS341",.F.)

	Aadd(aParam,(mv_par01 == 1))
	Aadd(aParam,(mv_par02 == 1))
	Aadd(aParam,(mv_par03 == 1))
	Aadd(aParam,(mv_par04 == 1))
	Aadd(aParam,(mv_par05 == 1))
	Aadd(aParam,(mv_par06 == 1))

	dbSelectArea(__cAliTRB)

	//-- Verifica se existe algum tipo de baixa em aberto
	nTpBaixa := Oms341TpBx(nFldAtu,nValRec)

	//Mov bancaria? Obriga dados bancários se motivo da baixa indicar que há movimentação bancária. 
	If nTpBaixa = 4 .and. lGRSEFLQ
		OmsHelp(STR0104,STR0105,OMSA34104) 
		lRet := .F.
	EndIf

	If lRet .And. nTpBaixa = 3 .And. nValTit > 0 .And. MovBcobx(cMotBx, .T.) .And. !CarregaSA6(cBanco,cAgencia,cConta,.T.,,.T.)
		Return 0
	EndIf

	//-- para permitir validar a realizacao de baixa, liquidacao e compensacao de titulos
	If ExistBlock("OMS341OK")
		lRet := ExecBlock("OMS341OK", .F., .F.)
		If  ValType(lRet)<>"L"
			lRet := .T.
		EndIf
	EndIf

	//-- Se existia algum tipo de baixa pendente é realizado no momento
	__SDesc := nDescont
	If lRet .And. nTpBaixa <> 0
		lBaixa := Oms341Proc(oFolder,;
							nTpBaixa,;
							cCarga,;
							cSeqCar,;
							@cMotBx,;
							@cBanco,;
							@cAgencia,;
							@cConta,;
							@dBaixa,;
							@dDataLiq,;
							@dDtCredito,;
							@nValRec,;
							@nQtdeTit,;
							@nValTit,;
							@nDescont,;
							@nValJur,;
							@nAbatim,;
							@nPgParc,;
							@nTotRec,;
							0,;
							0,;
							oSayQtde,;
							oSayVal,;
							oSayRec)
	EndIf

	aColsLiq := Iif(nFldAtu == 4,aClone(aCols),aClone(aCols2))

	If lRet .And. lBaixa .And. Oms341Tree(cCarga,cSeqCar,aColsLiq)

		Begin Transaction

		cLote := Oms341Lote(cCarga,cSeqCar,1)

		(__cAliPRC)->(dbSetOrder(2))
		(__cAliPRC)->(dbGotop())

		While (__cAliPRC)->(!Eof())

			cCliente    := (__cAliPRC)->E1_CLIENTE
			cLoja       := (__cAliPRC)->E1_LOJA
			cSeqTrb     := (__cAliPRC)->TRB_SEQUEN
			cFilBaixa   := (__cAliPRC)->TRB_FILTIT
			cMotBxProc  := (__cAliPRC)->TRB_TPBAIX
			cBancoProc  := (__cAliPRC)->TRB_BANCO
			cAgeProc    := (__cAliPRC)->TRB_AGENC
			cContaProc  := (__cAliPRC)->TRB_CONTA
			dBaixaProc  := (__cAliPRC)->TRB_DATA
			dDtCredProc := (__cAliPRC)->TRB_DTCRED
			nValRecProc := 0

			aSe1Bx     := {}
			aSe1Liq    := {}
			aSe1Ref    := {}
			aSe1Cps    := {}
			aBaixa     := {}
			aNCC       := {}

			aSE1Dados  := {}
			aValores   := {}
			aAuxLiq    := {}
			aAuxSE1    := {}

			If nDescont > 0   //usado para usar o desconto correto numa baixa simples precedida de uma compensacao
				lDescOms := .T.
			EndIf
			While   (__cAliPRC)->(!Eof()) .And. ;
					(__cAliPRC)->(TRB_TPBAIX+TRB_BANCO+TRB_AGENC+TRB_CONTA+Dtos(TRB_DATA)+Dtos(TRB_DTCRED)+TRB_SEQUEN+E1_CLIENTE+E1_LOJA) == ;
					cMotBxProc+cBancoProc+cAgeProc+cContaProc+Dtos(dBaixaProc)+Dtos(dDtCredProc)+cSeqTrb+cCliente+cLoja

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Cria array de tipos de baixas a serem realizadas           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				Do Case
					Case (__cAliPRC)->TRB_OPERA == "1"
						dbSelectArea(__cAliPRC)
						Aadd(aSE1Bx,(__cAliPRC)->TRB_RECNO)
						SE1->(MsGoto((__cAliPRC)->TRB_RECNO))
						SE1->(RecLock("SE1"))
						aValores := FaVlAtuCr("SE1",dBaixaProc)
						aAdd(aSe1Dados,{(__cAliPRC)->TRB_RECNO,Nil,aValores})
						aSE1Dados[Len(aSE1Dados)][2] := cHistBx
						If nToler > 0 
							If Empty(Atail(aSE1Dados)[3][8])
								Atail(aSE1Dados)[3][8]  += (__cAliPRC)->TRB_VALJUR //Juros
								Atail(aSE1Dados)[3][12] += (__cAliPRC)->TRB_VALJUR
							EndIf
							If Empty(Atail(aSE1Dados)[3][9])
								Atail(aSE1Dados)[3][9] +=   (__cAliPRC)->TRB_VALDES //Desconto
								Atail(aSE1Dados)[3][12] -=  (__cAliPRC)->TRB_VALDES
								__SDesc += (__cAliPRC)->TRB_VALDES
							ElseIf (Atail(aSE1Dados)[3][12] - (__cAliPRC)->TRB_VALREC) <=  nToler //Desconta o valor da diferenca quando estiver dentro da tolerancia
								Atail(aSE1Dados)[3][9] += Atail(aSE1Dados)[3][12] - (__cAliPRC)->TRB_VALREC + (__cAliPRC)->TRB_VALJUR
								__SDesc += Atail(aSE1Dados)[3][12] - (__cAliPRC)->TRB_VALREC + (__cAliPRC)->TRB_VALJUR
							EndIf

						EndIf
					Case (__cAliPRC)->TRB_OPERA == "2"
						dbSelectArea(__cAliPRC)
						SE1->(MsGoto((__cAliPRC)->TRB_RECNO))
						SE1->(RecLock("SE1"))
						aValores  := FaVlAtuCr("SE1",dBaixaProc)
						Aadd(aSE1Liq,{(__cAliPRC)->TRB_RECNO,cSeqTrb,(__cAliPRC)->E1_CLIENTE,(__cAliPRC)->E1_LOJA,aValores})
					Case (__cAliPRC)->TRB_OPERA == "3"
						dbSelectArea(__cAliPRC)
						Aadd(aSE1Cps,(__cAliPRC)->TRB_RECNO)
						SE1->(MsGoto((__cAliPRC)->TRB_RECNO))
						SE1->(RecLock("SE1"))
						aValores  := FaVlAtuCr("SE1",dBaixaProc,Nil,.T.)
						aadd(aSe1Dados,{(__cAliPRC)->TRB_RECNO,Nil,aValores})
						aSE1Dados[Len(aSE1Dados)][2] := cHistBx
				EndCase
				nValRecProc += (__cAliPRC)->TRB_VALREC
				lDescOms := .F. //-- Desconto deve ser aplicado apenas uma vez
				(__cAliPRC)->(dbSkip())
			EndDo

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄadminÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executo a baixa caso existam registros marcados para a operacao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aSE1Bx) > 0
				aBaixa := {TrazCodMot(cMotBxProc),nValRecProc,cBancoProc,cAgeProc,cContaProc,dBaixaProc,dDtCredProc}

				//-- Troca a filial de acordo com a filial do titulo.
				cFilBak := cFilAnt
				If !Empty(FwFilial("SE1")) .And. !Empty(cFilBaixa)
					cFilAnt := cFilBaixa
				EndIf

				//-- Controla saldo na compensacao do cheque.
				If  cSldBxCr == "C"
					//-- Soma o total recebido em cheques informados na baixa.
					aColsSav  := aClone(aCols)
					aCols     := aClone(aColsCHQ)
					nSomaCheq := SomaCheqCr(.F.,SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE)
					aCols     := aClone(aColsSEF)
					nSomaCheq += SomaCheqCr(.F.,SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE)
					aCols     := aClone(aColsSav)
					aColsSEF  := {}
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Baixa os titulos selecionados                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MaIntBxCR(1,aSE1Bx,aBaixa,Nil,Nil,aParam,{|x,y| cSeqSE5 := OmsGrvDAM(x,y,cCarga,cSeqcar,cLote,"1")},/*aEstorno*/,aSE1Dados,/*aNewSE1*/,/*nSaldoComp*/,/*aCpoUser*/,/*aNCC_RAvlr*/,nSomaCheq)

				If  Len(aColsCHQ) > 0
					GravaChqCR(cSeqSE5,"OMSA341",aColsCHQ) // Grava os cheques no SEF - Compensacao
					aColsCHQ := {}
				EndIf

				//-- Restaura a filial original
				cFilAnt := cFilBak
				aSe1Bx  := {}
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se existirem registros marcados para compensar³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( Len(aSE1Cps) > 0 )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Monto o array com as compensacoes                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea(__cAliCPS)
				(__cAliCPS)->(dbGotop())
				While (__cAliCPS)->(!Eof())
					If (__cAliCPS)->TRB_OPERA == "3" .And. (__cAliCPS)->(E1_CLIENTE+E1_LOJA) == cCliente+cLoja
						Aadd(aNCC,(__cAliCPS)->TRB_RECNO)
					EndIf
					(__cAliCPS)->(dbSkip())
				EndDo

				//-- Troca a filial de acordo com a filial do titulo
				cFilBak := cFilAnt
				If !Empty(FwFilial("SE1")) .And. !Empty(cFilBaixa)
					cFilAnt := cFilBaixa
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Compensa os titulos selecionados                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MaIntBxCR(3,aSE1Cps,Nil,aNCC,Nil,aParam,{|x,y| OmsGrvDAM(x,y,cCarga,cSeqcar,cLote,"3")})

				//-- Restaura a filial original
				cFilAnt := cFilBak

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se existirem registros marcados para liquidar ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aSe1Liq) > 0
				nPosPref   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_PREFIXO"} )
				nPosBco    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_BCOCHQ"} )
				nPosAge    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_AGECHQ"} )
				nPosCta    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_CTACHQ"} )
				nPosNum    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_NUM"} )
				nPosData   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_VENCTO"} )
				nPosStatus := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_ADM"} )
				nPosVlrCh  := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_VLCRUZ"} )
				nPosCli    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "DA7_CLIENT"} )
				nPosLoja   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "DA7_LOJA"} )
				nPosEmit   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_EMITCHQ"} )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ordena para achar primeiro os clientes informados          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nEvento == 2
					aColsLiq  := aSort(aColsLiq,,,{|x,y| x[8]+x[9]+x[11] > y[8]+y[9]+y[11]})
				EndIf
				aSE1Ref := aClone(aSe1Liq)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Vincula os cheques ao titulos conforme a sequencia de baixa³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				For nY := 1 to Len(aColsLiq)
					If  aColsLiq[nY][nUsado2+1]
						Loop
					EndIf
					aSe1Liq := {}
					aLiq    := {}
					aCpoUser:= {}
					If nEvento == 1
						For nLoop := 1 to Len(aSe1Ref)
							If aColsLiq[nY][nPosStatus] == aSe1Ref[nLoop][2]
								Aadd(aSe1Liq,aSe1Ref[nLoop][1])
							EndIf
						Next nLoop
					Else
						For nLoop := 1 to Len(aSe1Ref)
							If aColsLiq[nY][nPosStatus] == aSe1Ref[nLoop][2] .And. aColsLiq[nY][nPosCli]==aSe1Ref[nLoop][3] .And. aColsLiq[nY][nPosLoja]==aSe1Ref[nLoop][4]
								Aadd(aSe1Liq,aSe1Ref[nLoop])
							EndIf
						Next nLoop
					EndIf
					If !Empty(aSe1Liq)
						If nEvento == 1
							aAdd(aLiq,{ aColsLiq[nY][nPosPref],;
										aColsLiq[nY][nPosBco],;
										aColsLiq[nY][nPosAge],;
										aColsLiq[nY][nPosCta],;
										aColsLiq[nY][nPosNum],;
										aColsLiq[nY][nPosData],;
										aColsLiq[nY][nPosVlrCh],;
										"CH ",;
										"",;
										1,;
										dBxLiq})
							aAdd(aCpoUser,{})
							nSeek := Len(aCpoUser)
							aAdd(aCpoUser[nSeek],{"E1_EMITCHQ",aColsLiq[nY][nPosEmit]})
						Else
							aAdd(aLiq,{ aColsLiq[nY][nPosPref],;
										aColsLiq[nY][nPosBco],;
										aColsLiq[nY][nPosAge],;
										aColsLiq[nY][nPosCta],;
										aColsLiq[nY][nPosNum],;
										aColsLiq[nY][nPosData],;
										aColsLiq[nY][nPosVlrCh],;
										"CH ",;
										"",;
										1,;
										dBxLiq,;
										aColsLiq[nY][nPosCli],;
										aColsLiq[nY][nPosLoja],;
										{"E1_EMITCHQ",aColsLiq[nY][nPosEmit]}})
						EndIf
						//-- Array aColsSEF para gravacao do cheque
						If  lGRSEFLQ //-- Indica se deve gravar SEF na liquidacao
							aColsSEFLiq := {}
							CadCheqCR(  aColsLiq[nY][nPosBco],;
										aColsLiq[nY][nPosAge],;
										aColsLiq[nY][nPosCta],;
										aColsLiq[nY][nPosVlrCh],;
										aColsLiq[nY][nPosData],,;
										aColsSEFLiq,.F.)
							//-- Adiciona Nro Titulo
							aColsSEFLiq[1][1] := aColsLiq[nY][nPosBco]
							aColsSEFLiq[1][2] := aColsLiq[nY][nPosAge]
							aColsSEFLiq[1][3] := aColsLiq[nY][nPosCta]
							aColsSEFLiq[1][4] := aColsLiq[nY][nPosNum]
							aAdd(aColsSEF, aColsSEFLiq[1])
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Troca a filial de acordo com a filial do titulo            ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cFilBak := cFilAnt
						If !Empty(FwFilial("SE1")) .And. !Empty(cFilBaixa)
							cFilAnt := cFilBaixa
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Liquida  os titulos selecionados                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nEvento == 1
							MaIntBxCR(2,aSe1Liq,Nil,Nil,aLiq,aParam,{|x,y,z| cSeqSE5 := OmsGrvDAM(x,y,cCarga,cSeqcar,cLote,"2",z)},,,,,aCpoUser)
						Else
							aLiq    := aSort(aLiq   ,,,{|x,y| x[12]+x[13] < y[12]+y[13]})
							aSe1Liq := aSort(aSE1Liq,,,{|x,y| x[03]+x[04] < y[03]+y[04]})
							For nX := 1 To Len(aSe1Liq)
								cCliente := aSe1Liq[nX][03]
								cLoja    := aSe1Liq[nX][04]
								aAuxSE1  := {}
								For nX := nX to Len(aSE1Liq)
									If  cCliente == aSe1Liq[nX][03] .And. cLoja == aSe1Liq[nX][04]
										aadd(aAuxSE1,aSe1Liq[nX][01])
									Else
										Exit
									EndIf
								Next nX
								aAuxLiq  := {}
								aCpoUser := {}
								For nZ := 1 to Len(aLiq)
									If !Empty(aLiq[nZ])
										If aLiq[nZ][12] == cCliente .And. aLiq[nZ][13] == cLoja
											AAdd(aCpoUser,{aLiq[nZ,14]})
											ADel(aLiq[nZ],14)
											aSize(aLiq[nZ],13)
											AAdd(aAuxLiq,aLiq[nZ])
											aLiq[nZ] := {}
										EndIf
									EndIf
								Next nZ
								If Empty(aAuxLiq)
									For nZ := 1 to Len(aLiq)
										If !Empty(aLiq[nZ]) .And. Empty(aLiq[nZ][12])
											AAdd(aCpoUser,{aLiq[nZ,14]})
											ADel(aLiq[nZ],14)
											aSize(aLiq[nZ],13)
											AAdd(aAuxLiq,aLiq[nZ])
											aLiq[nZ] := {}
										EndIf
									Next nZ
								EndIf
								If !Empty(aAuxSE1) .And. !Empty(aAuxLiq)
									MaIntBxCR(2,aAuxSE1,Nil,Nil,aAuxLiq,aParam,{|x,y,z| cSeqSE5 := OmsGrvDAM(x,y,cCarga,cSeqcar,cLote,"2",z)},,,,,aCpoUser)
								EndIf
								nX--
							Next nX
						EndIf
						If Len(aColsSEF) > 0
							// Deve reposicionar no título referente aos cheques para gerar a SEF corretamente
							If SE1->E1_TIPO == "NCC"
								cQuery := "SELECT R_E_C_N_O_ RECNOSE1"
								cQuery +=  " FROM "+RetSqlName("SE1")+" SE1"
								cQuery += " WHERE E1_FILIAL  = '"+xFilial("SE1")+"'"
								cQuery +=   " AND E1_NUMLIQ  = '"+SE1->E1_NUMLIQ+"'"
								cQuery +=   " AND E1_CLIENTE = '"+SE1->E1_CLIENTE+"'"
								cQuery +=   " AND E1_LOJA    = '"+SE1->E1_LOJA+"'"
								cQuery +=   " AND E1_TIPO    = 'CH'"
								cQuery +=   " AND D_E_L_E_T_ = ' '"
								cQuery := ChangeQuery(cQuery)
								cAliasQry := GetNextAlias()
								DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
								If !(cAliasQry)->(Eof())
									SE1->(DbGoTo((cAliasQry)->RECNOSE1))
								EndIf
								(cAliasQry)->(DbCloseArea())
							EndIF
							If lOMS341CHQ
								ExecBlock("OMS341CHQ",.F.,.F., aColsSEF)
							EndIf
							GravaChqCR(cSeqSE5,"OMSA341",aColsSEF) // Grava os cheques no SEF - Liquidacao
							If lOMS341SEF
								ExecBlock("OMS341SEF",.F.,.F., aColsSEF) //Ponto de entrada para atualização dos dados no SEF.
							EndIf
							aColsSEF := {}
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Restaura a filial original                                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cFilAnt := cFilBak

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Limpa o acols de liquidacao caos houve alguma movimentacao            ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aCols2  := Array( 1 , (nUsado2+1) )
						aCols2[1,nUsado2+1] := .F.
						For nCntFor := 1 To nUsado2
							aCols2[1,nCntFor] := CriaVar(aHeader2[nCntFor,2],.T.)
						Next nCntFor
					EndIf
				Next nY
			EndIf
		EndDo

		nRetorno := 1

		End Transaction

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa o acols de liquidacao caos houve alguma movimentacao            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols2  := Array( 1 , (nUsado2+1) )
	aCols2[1,nUsado2+1] := .F.
	For nCntFor := 1 To nUsado2
		aCols2[1,nCntFor] := CriaVar(aHeader2[nCntFor,2],.T.)
	Next nCntFor

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpa objetos do rodape da tela de liquidacoes                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSayQtdCh:SetText(Alltrim(Transform(0,"999999") ) )
	oSayValCh:SetText(Alltrim(Transform(0,"@R 99,999,999.99") ) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se estiver ja no folder de liquidacao limpa o mesmo com o aCols2      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nFldAtu == 4
		aCols := aClone(aCols2)
	EndIf

Return(nRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341DAM ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Efetua o processamento do arquivo de movimentacao da presta  ³±±
±±³          ³cao de contas                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Numero do registro do SE1                            ³±±
±±³          ³ExpC2 : Retorno do bloco de codigo                           ³±±
±±³          ³ExpC3 : Numero da carga                                      ³±±
±±³          ³ExpC4 : Sequencia da carga                                   ³±±
±±³          ³ExpC5 : Numero do lote                                       ³±±
±±³          ³ExpC6 : Tipo da baixa                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo gravar o arquivo de movimenta  ³±±
±±³          ³cao ao baixar o titulo na prestacao de contas                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Bloco de codigo a ser passado na funcao MAINTBXCR()         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OmsGrvDAM(nRecSE1,cRetorno,cCarga,cSeqCar,cLote,cBaixa,cNumLiq)
Local nValor    := SE1->E1_VALLIQ
Default cNumLiq := ""
	dbSelectArea("SE1")
	MsGoto(nRecSE1)

	If cBaixa == "3"
		//Se for baixa por compensação, desconta o valor já abatido por outras compensações
		//Tratamento válido para situações onde 1 título será abatido por 2 compensações diferentes
		nValor := SE1->E1_VALLIQ - OmsValDAM(cCarga,cSeqCar,cLote,cBaixa)
	EndIf

	RecLock("DAM",.T.)
		DAM->DAM_FILIAL := xFilial("DAM")
		DAM->DAM_CARGA  := cCarga
		DAM->DAM_SEQCAR := cSeqCar
		DAM->DAM_LOTE   := cLote
		DAM->DAM_PREFIX := SE1->E1_PREFIXO
		DAM->DAM_NUMERO := SE1->E1_NUM
		DAM->DAM_PARCEL := SE1->E1_PARCELA
		DAM->DAM_TIPO   := SE1->E1_TIPO
		DAM->DAM_CLIENT := SE1->E1_CLIENTE
		DAM->DAM_LOJA   := SE1->E1_LOJA
		DAM->DAM_VALOR  := nValor
		DAM->DAM_TPBAIX := cBaixa
		DAM->DAM_SEQBX  := cRetorno
		DAM->DAM_FILCR  := Iif(!Empty(FwFilial("SE1")),SE1->E1_FILIAL,cFilAnt) 
		DAM->DAM_USER   := __cUserID //RetCodUsr()
		DAM->DAM_NUMLIQ := cNumLiq
	Msunlock()

	If ExistBlock("OS341SE1")
		ExecBlock("OS341SE1",.F.,.F.,cBaixa)
	EndIf

Return cRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341LOTE³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Traz o numero do ultimo lote da carga                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Numero da carga                                      ³±±
±±³          ³ExpC2 : Sequencia da carga                                   ³±±
±±³          ³ExpN3 : Tipo do retorno                                      ³±±
±±³          ³        1 - Traz o novo lote                                 ³±±
±±³          ³        2 - Traz o ultimo lote                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cLote - Numero do ultimo lote da carga                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo trazer o numero do ultimo lote ³±±
±±³          ³da carga                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341Lote(cCarga,cSeqCar,nTipo)
Local aArea  := GetArea()
Local cLote  := "000001"
Local cQry   := ""

	cQry := "SELECT MAX(DAM_LOTE) LOTE "
	cQry += "FROM "+RetSqlName("DAM") + " DAM "
	cQry += "WHERE DAM.DAM_FILIAL='"+xFilial("DAM")+"' AND "
	cQry += "DAM.DAM_CARGA = '"+cCarga+"' AND "
	cQry += "DAM.DAM_SEQCAR = '"+cSeqCar+"' AND "
	cQry += "DAM.D_E_L_E_T_=' ' "
	cQry := ChangeQuery(cQry)

	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"DAMMAX",.F.,.T.)
	If DAMMAX->(!Eof())
		cLote := StrZero(Val(LOTE)+1,6)
	EndIf

	dbSelectArea("DAMMAX")
	dbCloseArea()
	dbSelectArea("DAM")

RestArea(aArea)
Return(cLote)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341VARBX ³ Autor ³ Henry Fila          ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Zera as variaveis da baixa                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 : Motivo da Baixa                                      ³±±
±±³          ³cExp2 : Banco                                                ³±±
±±³          ³cExp3 : Agencia                                              ³±±
±±³          ³cExp4 : Conta                                                ³±±
±±³          ³dExp5 : Data da baixa                                        ³±±
±±³          ³dExp6 : Data do Credito                                      ³±±
±±³          ³nExp7 : Valor Recebido                                       ³±±
±±³          ³nExp8 : Quantidade de titulos                                ³±±
±±³          ³nExp9 : Valor Total a Receber                                ³±±
±±³          ³nExp10: Descontos                                            ³±±
±±³          ³nExp11: Juros                                                ³±±
±±³          ³nExp12: Abatimentos                                          ³±±
±±³          ³lExp13: Acumula Total                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cLote - Numero do ultimo lote da carga                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo trazer o numero do ultimo lote ³±±
±±³          ³da carga                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341VarBx(cMotBx,;
							cBanco,;
							cAgencia,;
							cConta,;
							dBaixa,;
							dDataLiq,;
							dDtCredito,;
							nValRec,;
							nTotRec,;
							nQtdeTit,;
							nValTit,;
							nDescont,;
							nValJur,;
							nAbatim,;
							nPgParc,;
							lAcumula)

Local aMotBx     := ReadMotBx()
Local aDescMotBx := {}
Local nY         := 0

	//-- Array com os motivos da baixa
	For nY := 1 to Len(aMotBx)
		If Substr(aMotBx[nY],34,01) == "A" .or. Substr(aMotBx[nY],34,01) == "R"
			aAdd(aDescMotbx,Substr(aMotBx[nY],07,10))
		EndIf
	Next

	If (nY:=aScan(aDescMotBx,{|x|Trim(x)==cMotBx}))==0
		nY:= 1
	EndIf
	cMotBx   := aDescMotBx := aDescMotBx[nY]
	cBanco   := CriaVar("E1_PORTADO",.F.)
	cAgencia := CriaVar("E1_AGEDEP" ,.F.)
	cConta   := CriaVar("E1_CONTA"  ,.F.)

	dBaixa     := dDataBase
	dDataLiq   := dDatabase
	dDtCredito := dDatabase

	nValRec    := 0
	nTotRec    := 0

	If lAcumula
		nQtdeTit := 0
		nValTit  := 0
		nDescont := 0
		nValJur  := 0
		nAbatim  := 0
		nPgParc  := 0
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341CAN ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Cancela a movimentacao gerada na prestacao de contas         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Numero da carga                                      ³±±
±±³          ³ExpC2 : Sequencia da carga                                   ³±±
±±³          ³ExpC3 : Codigo do Cliente                                    ³±±
±±³          ³ExpC4 : Loja do Cliente                                      ³±±
±±³          ³ExpC5 : Carga                                                ³±±
±±³          ³ExpC6 : Sequencia da carga                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo cancelar as movimentacoes      ³±±
±±³          ³feitas do cliente                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Oms341Can(nFldAtu, cCliente, cLoja, cCarga, cSeqCar)
Local aCbx       := {OemtoAnsi(STR0049),OemtoAnsi(STR0050),OemtoAnsi(STR0051)} //"BAIXAS"###"LIQUIDACOES"###"COMPENSACOES"
Local aArea      := GetArea()
Local aAreaSE1   := SE1->(GetArea())
Local aColsLiq   := Iif(nFldAtu == 4,aClone(aCols),aClone(aCols2))
Local aAreaAnt   := {}

Local cCbx       := ""
Local cQuery     := ""
Local cAliasDAM  := ""
Local cAliasSE1  := ""
Local cFilSE1    := ""
Local cFilBak    := ""
Local aTamSX3    := {}

Local nBaixa     := 0
Local nOpca      := 0
Local nRecTRB    := (__cAliTRB)->(Recno())
Local nRecCPS    := (__cAliCPS)->(Recno())
Local nTipo      := 1
Local nUsadoLiq  := Len(aHeader2)
Local nPosAcols  := 0
Local nX         := 0
Local nTipoOper  := OsVlEntCom()
Local nCntFor    := 0

Local lProcessa  := .T.
Local lOm341Can  := ExistBlock("OM341CAN")
Local lOM341CBX  := ExistBlock("OM341CBX")
Local lRet       := .T.
Local lRetPE     := .T.

Local aItensDAM  := {}
Local aHDAM      := {}
Local oDlg
Local oListBox
Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")
Local aParam     := {}

	Aadd(aParam,(mv_par01 == 1))
	Aadd(aParam,(mv_par02 == 1))
	Aadd(aParam,(mv_par03 == 1))
	Aadd(aParam,(mv_par04 == 1))
	Aadd(aParam,(mv_par05 == 1))
	Aadd(aParam,(mv_par06 == 1))

	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0071) FROM 09,00 TO 20,40 OF oMainWnd //"Tipos de movimentacoes"

		@ 000, 0 BITMAP oBmp RESNAME "PROJETOAP" OF oDlg SIZE 30, 1000 NOBORDER WHEN .F. PIXEL ADJUST
		@ 014, 35 MSCOMBOBOX oCbx VAR cCbx ITEMS aCbx SIZE 115, 65 OF oDlg PIXEL ON CHANGE (nTipo := oCbx:nAt)

		DEFINE SBUTTON oBut1 FROM 062, 090 TYPE 1 ACTION (nOpca := 1, oDlg:End()) ENABLE of oDlg
		DEFINE SBUTTON oBut1 FROM 062, 120 TYPE 2 ACTION (nOpca := 0, oDlg:End()) ENABLE of oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 0
		Return
	EndIf

	If lOm341Can
		lRetPE := ExecBlock("OM341CAN",.F.,.F.,{cCliente, cLoja, cCarga, cSeqCar})
		If ValType(lRetPE) == "L" .And. !lRetPE
			Return
		EndIf
	EndIf

	// Busca as movimentações de acerto financeiro de acordo com o tipo de baixa selecionado para cancelamento
	cQuery := "SELECT DAM_PREFIX,"
	cQuery +=       " DAM_NUMERO,"
	cQuery +=       " DAM_PARCEL,"
	cQuery +=       " DAM_TIPO,"
	cQuery +=       " DAM_CLIENT,"
	cQuery +=       " DAM_LOJA,"
	cQuery +=       " DAM_NUMLIQ,"
	cQuery +=       " DAM_NUMCMP,"
	cQuery +=       " DAM_SEQBX,"
	cQuery +=       " DAM_VALOR,"
	cQuery +=       " DAM_TPBAIX,"
	cQuery +=       " DAM_FILCR,"
	cQuery +=       " DAM.R_E_C_N_O_ DAMRECNO"
	cQuery += " FROM "+RetSqlName("DAM") + " DAM"
	cQuery += " WHERE "
	If nTipoOper == 1
		cQuery += " DAM_FILIAL = '"+xFilial("DAM")+"' AND"
	EndIf
	cQuery +=     " DAM_CARGA  = '"+cCarga+"'"
	cQuery += " AND DAM_SEQCAR = '"+cSeqCar+"'"
	If !Empty(cCliente)
		cQuery += " AND DAM_CLIENT = '"+cCliente+"'"
		cQuery += " AND DAM_LOJA   = '"+cLoja+"'"
	EndIf
	cQuery += " AND DAM_TPBAIX = '"+StrZero(nTipo,1)+"'"
	cQuery += " AND DAM.D_E_L_E_T_ = ' '"
	// Para só permitir o cancelamento das movimentações relacionadas à filial em questão
	cQuery += " AND EXISTS (SELECT 1"
	cQuery +=               " FROM "+RetSqlName("SE1")+" SE1"
	cQuery +=              " WHERE SE1.E1_FILIAL  = '"+xFilial("SE1")+"'"
	cQuery +=                " AND SE1.E1_CLIENTE = DAM.DAM_CLIENT"
	cQuery +=                " AND SE1.E1_LOJA    = DAM.DAM_LOJA"
	cQuery +=                " AND SE1.E1_PREFIXO = DAM.DAM_PREFIX"
	cQuery +=                " AND SE1.E1_NUM     = DAM.DAM_NUMERO"
	cQuery +=                " AND SE1.E1_PARCELA = DAM.DAM_PARCEL"
	cQuery +=                " AND SE1.E1_TIPO    = DAM.DAM_TIPO"
	cQuery +=                " AND SE1.D_E_L_E_T_ = ' ')"
	cQuery := ChangeQuery(cQuery)
	cAliasDAM := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDAM,.F.,.T.)
	aTamSX3 := TamSX3("DAM_VALOR")
	TcSetField(cAliasDAM,"DAM_VALOR","N",aTamSX3[1],aTamSX3[2])

	If (cAliasDAM)->(Eof())
		OMSHelp(OmsFmtMsg(STR0099,{{"[VAR01]",AllTrim(aCbx[nTipo])},{"[VAR02]",AllTrim(xFilial("SE1"))},{"[VAR03]",cCarga}}),,OMSA34102) // "Não foram encontradas movimentações de acerto financeiro do tipo [VAR01] disponíveis para cancelamento na Filial [VAR02] / Carga [VAR03]."
		(cAliasDAM)->(DbCloseArea())
		RestArea(aArea)
		Return
	EndIf

	While !(cAliasDAM)->(Eof())
		aAdd(aItensDAM,{.T.,     ;
		(cAliasDAM)->DAM_PREFIX, ;
		(cAliasDAM)->DAM_NUMERO, ;
		(cAliasDAM)->DAM_PARCEL, ;
		(cAliasDAM)->DAM_TIPO,   ;
		(cAliasDAM)->DAM_CLIENT, ;
		(cAliasDAM)->DAM_LOJA,   ;
		(cAliasDAM)->DAM_NUMLIQ, ;
		(cAliasDAM)->DAM_NUMCMP, ;
		(cAliasDAM)->DAM_SEQBX,  ;
		Transform((cAliasDAM)->DAM_VALOR,PesqPict("DAM","DAM_VALOR")) } )
		(cAliasDAM)->(dbSkip())
	EndDo

	DEFINE MSDIALOG oDlg TITLE STR0001+" - "+aCbx[nTipo] From 150,200 TO 400,800 OF oMainWnd PIXEL
		AAdd(aHDAM, " ")
		AAdd(aHDAM, RetTitle("DAM_PREFIX" ))
		AAdd(aHDAM, RetTitle("DAM_NUMERO" ))
		AAdd(aHDAM, RetTitle("DAM_PARCEL" ))
		AAdd(aHDAM, RetTitle("DAM_TIPO"   ))
		AAdd(aHDAM, RetTitle("DAM_CLIENTE"))
		AAdd(aHDAM, RetTitle("DAM_LOJA"   ))
		AAdd(aHDAM, RetTitle("DAM_NUMLIQ" ))
		AAdd(aHDAM, RetTitle("DAM_NUMCMP" ))
		AAdd(aHDAM, RetTitle("DAM_SEQBX"  ))
		AAdd(aHDAM, RetTitle("DAM_VALOR"  ))
		oListBox := TWBrowse():New(001,001,299,110,,aHDAM,,oDlg,,,,,,,,,,,,, "ARRAY", .T. )
		oListBox:SetArray(aItensDAM)
		oListBox:bLine := { || {If(aItensDAM[oListBox:nAT,1]==.T.,oOk,oNo), ;
		aItensDAM[oListBox:nAT, 2],;
		aItensDAM[oListBox:nAT, 3],;
		aItensDAM[oListBox:nAT, 4],;
		aItensDAM[oListBox:nAT, 5],;
		aItensDAM[oListBox:nAT, 6],;
		aItensDAM[oListBox:nAT, 7],;
		aItensDAM[oListBox:nAT, 8],;
		aItensDAM[oListBox:nAT, 9],;
		aItensDAM[oListBox:nAT,10],;
		aItensDAM[oListBox:nAT,11]}}
		oListBox:bLDblClick := { || DblClick(nTipo,aItensDAM,oListBox) }
		DEFINE SBUTTON oBut1 FROM 112, 220 TYPE 1 ACTION (nOpca := 1, oDlg:End()) ENABLE of oDlg
		DEFINE SBUTTON oBut1 FROM 112, 250 TYPE 2 ACTION (nOpca := 0, oDlg:End()) ENABLE of oDlg
	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 1

		Begin Transaction

		(__cAliTRB)->(dbGotop())
		While !(__cAliTRB)->(Eof())
			//-- Verifica o tipo de baixa escolhida para estorno e processa
			If StrZero(nTipo,1) == (__cAliTRB)->TRB_OPERA
				RecLock(__cAliTRB,.F.)
						(__cAliTRB)->TRB_OPERA  := Space(1)
						(__cAliTRB)->TRB_BANCO  := ""
						(__cAliTRB)->TRB_AGENC  := ""
						(__cAliTRB)->TRB_CONTA  := ""
						(__cAliTRB)->TRB_TPBAIX := ""
						(__cAliTRB)->TRB_DATA   := Ctod("//")
						(__cAliTRB)->TRB_DTCRED := Ctod("//")
						(__cAliTRB)->TRB_VALREC := 0
				MsUnlock()
			EndIf
			(__cAliTRB)->(dbSkip())
		EndDo
		Do Case
			Case nTipo == 2
				aColsLiq := Array( 1 , nUsadoLiq+1 )
				aColsLiq[1,nUsadoLiq+1] := .F.
				For nCntFor := 1 To nUsadoLiq
					aColsLiq[1,nCntFor] := CriaVar(aHeader2[nCntFor,2],.T.)
				Next nCntFor
				//-- Se estiver no folder de liquidacao altera o proprio acols caso contrario altera o da memoria
				If  nFldAtu == 4
					aCols := aClone(aColsLiq)
				Else
					aCols2 := aClone(aColsLiq)
				EndIf
			Case nTipo == 3
				(__cAliCPS)->(dbGotop())
				While !(__cAliCPS)->(Eof())
					//-- Verifica o tipo de baixa escolhida para estorno e processa
					If  StrZero(nTipo,1) == (__cAliCPS)->TRB_OPERA
						RecLock(__cAliCPS,.F.)
						(__cAliCPS)->TRB_OPERA := Space(1)
						MsUnlock()
					EndIf
					(__cAliCPS)->(dbSkip())
				EndDo
		EndCase

		(cAliasDAM)->(DbGotop())
		While !(cAliasDAM)->(Eof())

			lProcessa := .F.

			// 2-Prefixo;3-Titulo;4-Parcela;5-Tipo;6-Cliente;7-Loja;8-Liquid;9-Compens;10-Seq.Baixa.
			If (nPos:=aScan(aItensDAM,{|x| X[2]+X[3]+X[4]+X[5]+X[6]+x[7]+x[8]+x[9]+x[10]==(cAliasDAM)->(DAM_PREFIX+DAM_NUMERO+DAM_PARCEL+DAM_TIPO+DAM_CLIENT+DAM_LOJA+DAM_NUMLIQ+DAM_NUMCMP+DAM_SEQBX)})) > 0
				lProcessa := aItensDAM[nPos,1]
			EndIf

			If !lProcessa
				(cAliasDAM)->(DbSkip())
				Loop
			EndIf

			If Empty(FwFilial("SE1")) .Or. nTipoOper == 1 
				cFilSE1 := xFilial("SE1")
			Else
				cFilSE1 := (cAliasDAM)->DAM_FILCR
			EndIf

			SE1->(dbSetOrder(1))
			If SE1->(DbSeek(cFilSE1+(cAliasDAM)->(DAM_PREFIX+DAM_NUMERO+DAM_PARCEL+DAM_TIPO+DAM_CLIENT+DAM_LOJA)))

				nBaixa := Val((cAliasDAM)->DAM_TPBAIX)

				//-- Verifica o tipo de operacao e a filial no qual sera realizado o estorno
				If  nTipoOper == 2 .Or. nTipoOper == 3
					cFilBak := cFilAnt
					If !Empty(FwFilial("SE1"))
						cFilAnt := (cAliasDAM)->DAM_FILCR
					EndIf
				EndIf

				// PE para tratamentos adicionais antes do cancelamento da baixa
				If lOM341CBX
					ExecBlock("OM341CBX",.F.,.F.,{nBaixa,(cAliasDAM)->DAMRECNO})
				EndIf

				Do Case
					Case nTipo == 1

						//-- Verifica se existe um cheque gerado para este TITULO
						//-- pois se tiver, dever  ser cancelado.
						dbSelectArea("SEF")
						SEF->(dbSetOrder(3))//EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_NUM+EF_SEQUENC
						If SEF->(dbSeek(xFilial("SEF")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
							While !Eof().And.SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)==;
								EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO.AND.EF_FILIAL==xFilial("SEF")
								If (SEF->EF_FORNECE == SE1->E1_CLIENTE .Or. SEF->EF_CLIENTE == SE1->E1_CLIENTE) .And. ;
									AllTrim(SEF->EF_SEQUENC) == AllTrim((cAliasDAM)->DAM_SEQBX) .And. ;
									AllTrim(SEF->EF_ORIGEM)  == "OMSA341"
									Reclock("SEF")
									SEF->(dbDelete())
									SEF->(MsUnlock())
								EndIf
								SEF->(dbSkip())
							Enddo
						EndIf

						//-- Estorna o titulo selecionado
						MaIntBxCR(nBaixa,{SE1->(Recno())},{0,0,0},Nil,Nil,aParam,Nil,{Alltrim((cAliasDAM)->DAM_SEQBX)})

						nPosaCols := Ascan(aCols1,{|x| Alltrim(x[1]) == "BX" })
						If  nPosaCols > 0
							aCols1[nPosaCols][4] -= DAM->DAM_VALOR
						EndIf

					Case nTipo == 2
						cQuery := "SELECT 1"
						cQuery +=  " FROM "+RetSqlName("SE1")+" SE1 "
						cQuery += " WHERE SE1.E1_FILIAL   = '"+xFilial("SE1")+"'"
						cQuery +=   " AND SE1.E1_NUMLIQ   = '"+(cAliasDAM)->DAM_NUMLIQ+"'"
						cQuery +=   " AND SE1.E1_TIPO     = 'CH'"
						cQuery +=   " AND SE1.E1_SITUACA <> '0'" // 0-CARTEIRA
						cQuery +=   " AND SE1.D_E_L_E_T_  = ' '"
						cQuery := ChangeQuery(cQuery)
						cAliasSE1 := GetNextAlias()
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.T.,.T.)
						If !(cAliasSE1)->(Eof())
							Help(" ",1,"FA040SITU",,OemtoAnsi(STR0083)+CHR(10)+CHR(13)+"CH - "+(cAliasDAM)->DAM_NUMLIQ,2,1) //Este título não está em carteira.
							lProcessa := .F.
						EndIf
						(cAliasSE1)->(DbCloseArea())
						If lProcessa
							//-- Estorna titulo da liquidacao selecionado do tipo CH
							MaIntBxCR(nBaixa,{SE1->(Recno())},Nil,Nil,{{0,0,0,0,0,0,0,"CH ",0,0,0,0,0,AllTrim((cAliasDAM)->DAM_NUMLIQ)}},Nil,Nil,{Alltrim((cAliasDAM)->DAM_SEQBX)})

							nPosaCols := Ascan(aCols1,{|x| Alltrim(x[1]) == "LQ" })
							If  nPosaCols > 0
								aCols1[nPosaCols][4] -= DAM->DAM_VALOR
							EndIf

							//-- Estorna titulo da liquidacao do tipo NCC
							cAliasSE1 := GetNextAlias()
							BeginSql Alias cAliasSE1
								SELECT SE1.R_E_C_N_O_ RECNOSE1
								FROM %Table:SE1% SE1
								WHERE SE1.E1_FILIAL = %xFilial:SE1%
								AND SE1.E1_NUMLIQ   = %Exp:(cAliasDAM)->DAM_NUMLIQ%
								AND SE1.E1_TIPO     = 'NCC'
								AND SE1.%NotDel%
							EndSql
							While (cAliasSE1)->(!EoF())
								SE1->(DbGoTo((cAliasSE1)->RECNOSE1))
								RecLock("SE1",.F.)
								SE1->(DbDelete())
								SE1->(MsUnlock())
								(cAliasSE1)->(DbSkip())
							EndDo
							(cAliasSE1)->(DbCloseArea())
						EndIf

					Case nTipo == 3

						//-- Estorna o titulo selecionado
						MaIntBxCR(nBaixa,{SE1->(Recno())},{0,0,0},Nil,Nil,aParam,Nil,{{Alltrim((cAliasDAM)->DAM_SEQBX)}})

						nPosaCols := Ascan(aCols1,{|x| Alltrim(x[1]) == "CP" })
						If  nPosaCols > 0
							aCols1[nPosaCols][4] -= DAM->DAM_VALOR
						EndIf

				EndCase

				//-- Restaura filial original caso a operacao seja inter filial
				If  nTipoOper == 2 .Or. nTipoOper == 3
					cFilAnt := cFilBak
				EndIf

			EndIf

			If lProcessa
				DAM->(MsGoto((cAliasDAM)->DAMRECNO))
				RecLock("DAM",.F.)
				DAM->(dbDelete())
				DAM->(MsUnlock())
			EndIf

			(cAliasDAM)->(dbSkip())

		EndDo

		// Atualiza o status de Acerto Financeiro da Carga
		AtuStFin(cCarga,cSeqCar,"1")

		End Transaction

		OmsMessage(STR0100) // "Processo finalizado!"

	EndIf
	(cAliasDAM)->(dbCloseArea())

	// Restaura a integridade dos dados e posiciona nos registros
	(__cAliTRB)->(dbGoto(nRecTRB))
	(__cAliCPS)->(dbGoto(nRecCPS))

RestArea(aArea)
Return

//----------------------------------------------------------
/*/{Protheus.doc} DblClick
Executa regra de marcação automática dos títulos no cancelamento
de Liquidação ou Compensação

@author  Guilherme A. Metzger
@version P12
@since   24/09/2018
/*/
//----------------------------------------------------------
Static Function DblClick(nTipo,aItensDAM,oListBox)
Local lMark := !aItensDAM[oListBox:nAt,1]
Local nI    := 1
Local nCol  := 1

	If nTipo > 1
		// Define qual posição do array será considerada de acordo com o processo que está sendo cancelado
		nCol := Iif(nTipo == 2,8,9)
		For nI := 1 To Len(aItensDAM)
			// Marca/desmarca todos os registros com mesmo número de Liquidação/Compensação
			If aItensDAM[nI,nCol] == aItensDAM[oListBox:nAt,nCol]
				aItensDAM[nI,1] := lMark
			EndIf
		Next
	Else
		// Se for cancelamento de baixa simples
		aItensDAM[oListBox:nAt,1] := lMark
	EndIf

	oListBox:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341VLBX³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Valida o valor das baixas recebidas                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Valor recebido                                       ³±±
±±³          ³ExpN2 : Valor total a receber                                ³±±
±±³          ³ExpC3 : Banco da baixa                                       ³±±
±±³          ³ExpC4 : Agencia                                              ³±±
±±³          ³ExpC5 : Conta                                                ³±±
±±³          ³ExpD6 : Data da baixa                                        ³±±
±±³          ³ExpD7 : Data do Credito                                      ³±±
±±³          ³ExpL8 : Verifica se a validacao e de Get o do Folder         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.   - Valor recebido e menor ou igual ao total             ³±±
±±³          ³.F.   - Valor recebido e maior que o total                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo validar o total recebido digie ³±±
±±³          ³tado na pasta de baixas                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341VlBx(nValRec,nTotRec,cBanco,cAgencia,cConta,dBaixa,dDtCredito,lGet,cMotBx)
Local lRet   := .T.
Local nToler := (GetNewPar("MV_OSTLREC",0))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se esta no get e mostra aviso de inconsistencia          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nValRec > nTotRec+nToler
		If lGet
			Help(" ",1,"OMS341VLR") //"Valor recebido nao pode ser maior que o total a receber."
		EndIf
		lRet := .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for a validacao do folder verifica todas as inconsistencias    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  lRet .And. !lGet .And. (nValRec > nTotRec .Or. ;
		If(MovBcobx(cMotBx, .T.),Empty(cBanco) .Or. Empty(cAgencia) .Or. Empty(cConta),.F.) .Or. ;
		Empty(dBaixa) .Or. Empty(dDtCredito))
		Help(" ",1,"OMS341BCO") //"Favor informar os dados de Banco, Agencia e Conta."
		lRet := .F.
	EndIf
	If  lRet .And. !lGet .And. MovBcobx(cMotBx, .T.)
		lRet := CarregaSA6(@cBanco,@cAgencia,@cConta,.T.,,.T.)
	EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341TREE³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Efetua a demonstracao do resumo da movimentacao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 : Alias do arquivo de titulos                          ³±±
±±³          ³ExpC2 : Alias do arquivo de compensacao                      ³±±
±±³          ³ExpC3 : Numero da carga                                      ³±±
±±³          ³ExpC4 : Sequencia da carga                                   ³±±
±±³          ³ExpC5 : Array com os cheques das liquidacoes                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.- Confirma o processamento                                ³±±
±±³          ³.F.- Volta para a prestacao de contas                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo desmonstrar as movimentacoes-  ³±±
±±³          ³feitas antes do usuario confirmar                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341Tree(cCarga,cSeqCar,aColsLiq)
Local aArea    := GetArea()
Local aSize    := MsAdvSize()
Local aPosObj1 := {}
Local aObjects := {}

Local cPrompt  := " "
Local cMotBx   := ""
Local cBanco   := ""
Local cAgencia := ""
Local cConta   := ""

Local lBaixa   := .F.

Local nOpca    := 1
Local nValRec  := 0
Local nPosPref   := 0
Local nPosBco    := 0
Local nPosAge    := 0
Local nPosCta    := 0
Local nPosNum    := 0
Local nPosData   := 0
Local nPosVlrCh  := 0
Local nUsado2    := Len(aHeader2)
Local nX         := 0
Local nPosStatus := 0
Local lRet       := .T.  //nOpca == 1

Local oFont

	DEFINE FONT oFont NAME "Ms LineDraw" SIZE 6, 15 BOLD


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o parametro de mostrar o resumo esta ativo              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If mv_par07 == 1 .And. (__cAliPRC)->(!Eof())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula dimensoes da janela                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		aObjects := {}
		AAdd( aObjects, { 100, 100 , .t., .t. } )

		aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
		aPosObj1 := MsObjSize( aInfo, aObjects)

		DEFINE MSDIALOG oDlg2 FROM aSize[7],000 TO aSize[6],aSize[5] TITLE OemtoAnsi(STR0047) Of oMainWnd PIXEL //"Resumo da movimentacao do cliente"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Definicao do DbTree.                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DEFINE DBTREE oTree FROM aPosObj1[1,1]+20,aPosObj1[1,2] TO aPosObj1[1,3],aPosObj1[1,4] CARGO OF oDlg2
			oTree:oFont := oFont

			(__cAliPRC)->(dbSetOrder(3))
			(__cAliPRC)->(dbGotop())

			While (__cAliPRC)->(!Eof())

				Do Case
					Case (__cAliPRC)->TRB_OPERA == " "
						cPrompt := Pad(OemtoAnsi(STR0048),200) //"TITULOS SEM MOVIMENTACAO"
					Case (__cAliPRC)->TRB_OPERA == "1"
						cPrompt := Pad(OemtoAnsi(STR0049),200) //"BAIXAS"
					Case (__cAliPRC)->TRB_OPERA == "2"
						cPrompt := Pad(OemtoAnsi(STR0050),200) //"LIQUIDACOES"
					Case (__cAliPRC)->TRB_OPERA == "3"
						cPrompt := Pad(OemtoAnsi(STR0051),200) //"COMPENSACOES"
				EndCase

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Abre dbtree das movimentacoes                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				cOpera := (__cAliPRC)->TRB_OPERA
				DBADDTREE oTree PROMPT cPrompt RESOURCE "FOLDER5","FOLDER6" CARGO Pad("0 ",200)

				While (__cAliPRC)->(!Eof()) .And. (__cAliPRC)->TRB_OPERA == cOpera

					cMotBx      := (__cAliPRC)->TRB_TPBAIX
					cBanco      := (__cAliPRC)->TRB_BANCO
					cAgencia    := (__cAliPRC)->TRB_AGENC
					cConta      := (__cAliPRC)->TRB_CONTA
					nValRec     += (__cAliPRC)->TRB_VALREC //-(__cAliPRC)->TRB_VALDES

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Valida o tipo de baixa para mostrar no tree                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					Do Case
					Case (__cAliPRC)->TRB_OPERA = "1"

						dbSelectARea("SA6")
						dbSetOrder(1)
						If MsSeek(OsFilial("SA6",(__cAliPRC)->TRB_FILTIT)+cBanco)

							cPrompt := Pad(Rtrim(RetTitle("E1_MOTIVO")) + " : "+cMotBx+;
											" - "+RTrim(RetTitle("E1_BCOCHQ"))+" : "+cBanco+"-"+;
											Alltrim(SA6->A6_NOME)+;
											" - "+Rtrim(RetTitle("E1_AGECHQ"))+": "+cAgencia+;
											" - "+Rtrim(RetTitle("E1_CTACHQ"))+": " +cConta   ,200)


							DBADDTREE oTree PROMPT cPrompt RESOURCE "FOLDER5","FOLDER6" CARGO Pad("1",200)
							lBaixa := .T.
						EndIf
					Case (__cAliPRC)->TRB_OPERA = "2"
						cPrompt := Pad(OemtoAnsi("TITULOS"),200)      //"TITULOS A DEBITO"
						DBADDTREE oTree PROMPT cPrompt RESOURCE "FOLDER5","FOLDER6" CARGO Pad("2",200)
					Case (__cAliPRC)->TRB_OPERA = "3"
						cPrompt := Pad(OemtoAnsi(STR0052),200)    //"TITULOS A DEBITO"
						DBADDTREE oTree PROMPT cPrompt RESOURCE "FOLDER5","FOLDER6" CARGO Pad("2",200)
					EndCase

					nTotal := 0

					While (__cAliPRC)->(!Eof()) .And. (__cAliPRC)->TRB_OPERA+(__cAliPRC)->TRB_TPBAIX+(__cAliPRC)->TRB_BANCO+(__cAliPRC)->TRB_AGENC+;
									(__cAliPRC)->TRB_CONTA == cOpera+cMotBx+cBanco+cAgencia+cConta

						cPrompt := Pad(RTrim(RetTitle("E1_PREFIXO"))      + " : " + (__cAliPRC)->E1_PREFIXO+; //"Prefixo : "
										" - "+RTrim(RetTitle("E1_NUM"))   + " : " +  (__cAliPRC)->E1_NUM+;      //" - Titulo : "
										" - "+Rtrim(RetTitle("E1_PARCELA"))+ " : " +(__cAliPRC)->E1_PARCELA+;  //" - Parcela : "
										" - "+Rtrim(RetTitle("E1_VALOR")) + " : " +Transform((__cAliPRC)->E1_VALOR,"@R 99,999,999.99")+;//" - Valor : "
										" - "+Rtrim(RetTitle("E1_VALLIQ"))+ " : " +Transform((__cAliPRC)->TRB_VALREC,"@R 99,999,999.99"),200) //" - Vlr.Liq.Baixa: "

						DBADDITEM oTree PROMPT cPrompt RESOURCE "CHECKED" CARGO Pad("0 ",200)

						nTotal += IIf((__cAliPRC)->TRB_VALREC==0,(__cAliPRC)->E1_VALOR,(__cAliPRC)->TRB_VALREC)

						(__cAliPRC)->(dbSkip())

					EndDo

					cPrompt := Pad( OemtoAnsi(STR0053) + Transform(nTotal,"@R 99,999,999.99"),200) //"Total : "

					DBADDITEM oTree PROMPT cPrompt RESOURCE "PMSTASK4" CARGO Pad("0 ",200)


					DBENDTREE oTree

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se eh compensacao                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					Do Case
					Case cOpera == "3"

						cPrompt := Pad(OemtoAnsi(STR0054),200)    //"TITULOS A CREDITO"
						DBADDTREE oTree PROMPT cPrompt RESOURCE "FOLDER5","FOLDER6" CARGO Pad("0 ",200)

						dbSelectArea(__cAliCPS)
						(__cAliCPS)->(dbGotop())

						nTotal := 0

						While (__cAliCPS)->(!Eof())
							If (__cAliCPS)->TRB_OPERA == "3"
									cPrompt := Pad(RTrim(RetTitle("E1_PREFIXO"))+(__cAliCPS)->E1_PREFIXO+;   //"Prefixo : "
													" - "+Rtrim(RetTitle("E1_NUM"))    + " : " +(__cAliCPS)->E1_NUM+;       //" - Titulo : "
													" - "+Rtrim(RetTitle("E1_PARCELA"))+ " : " +(__cAliCPS)->E1_PARCELA+;   //" - Parcela : "
													" - "+Rtrim(RetTitle("E1_VALOR"))  + " : " +Transform((__cAliCPS)->E1_VALOR,"@R 99,999,999.99"),200) //" - Valor : "
								DBADDITEM oTree PROMPT cPrompt RESOURCE "CHECKED" CARGO Pad("0 ",200)
								nTotal += (__cAliCPS)->E1_VALOR
							EndIf
							(__cAliCPS)->(dbSkip())
						EndDo

						cPrompt := Pad( OemtoAnsi(STR0053) + Transform(nTotal,"@R 99,999,999.99"),200)  //"Total : "
						DBADDITEM oTree PROMPT cPrompt RESOURCE "PMSTASK4" CARGO Pad("0 ",200)

						DBENDTREE oTree

					Case cOpera == "2"

						cPrompt := Pad(OemtoAnsi(STR0070),200)    //"CHEQUES DIGITADOS"
						DBADDTREE oTree PROMPT cPrompt RESOURCE "FOLDER5","FOLDER6" CARGO Pad("0 ",200)

						nTotal := 0

						nPosPref   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_PREFIXO"} )
						nPosBco    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_BCOCHQ"} )
						nPosAge    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_AGECHQ"} )
						nPosCta    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_CTACHQ"} )
						nPosNum    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_NUM"} )
						nPosData   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_VENCTO"} )
						nPosStatus := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_ADM"} )
						nPosVlrCh  := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_VLCRUZ"} )

						For nX := 1 to Len(aColsLiq)
							If !aColsLiq[nX][nUsado2+1] .Or. !Empty(aColsLiq[nX][nPosStatus])
								cPrompt := Pad(RTrim(RetTitle("E1_PREFIXO"))+": "+aColsLiq[nX][nPosPref]+Space(3)+; //"Prefixo"
											RTrim(RetTitle("E1_BCOCHQ"))+": "+aColsLiq[nX][nPosBco]+Space(3)+; //"Banco"
											RTrim(RetTitle("E1_AGECHQ"))+": "+aColsLiq[nX][nPosAge]+Space(3)+; //"Agencia"
											RTrim(RetTitle("E1_CTACHQ"))+": "+aColsLiq[nX][nPosCta]+Space(3)+; //"Conta
											RTrim(RetTitle("E1_NUM"))+": "+aColsLiq[nX][nPosNum]+Space(3)+; //"Nr. Cheque
											RTrim(RetTitle("E1_VENCTO"))+": "+DtoC(aColsLiq[nX][nPosData])+Space(3)+; //"Data Boa"
											RTrim(RetTitle("E1_VALOR"))+": "+Transform(aColsLiq[nX][nPosVlrCh],"@R 99,999,999.99"),200) //" - Valor : "

								DBADDITEM oTree PROMPT cPrompt RESOURCE "CHECKED" CARGO Pad("0 ",200)

								nTotal += aColsLiq[nX][nPosVlrCh]
							EndIf
						Next

						cPrompt := Pad(OemtoAnsi(STR0053) + Transform(nTotal,"@R 99,999,999.99"),200)  //"Total : "
						DBADDITEM oTree PROMPT cPrompt RESOURCE "PMSTASK4" CARGO Pad("0 ",200)

						DBENDTREE oTree


					EndCase

				Enddo

				DBENDTREE oTree

			EndDo

		ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar( oDlg2, { || nOpca := 1,oDlg2:End()}, {|| nOpca := 0,oDlg2:End()})
	EndIf

	If ExistBlock("OS341TRE")
		lRet := ExecBlock("OS341TRE",.F.,.F.,{__cAliTRB, __cAliCPS, __cAliPRC, cCarga, cSeqCar, aColsLiq})
		If ValType(lRet)=="L"
			Return(lRet)
		EndIf
	EndIf

	(__cAliPRC)->(dbGoTop())
	(__cAliCPS)->(dbGoTop())

RestArea(aArea)
Return(nOpca == 1)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341TPBX³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Traz o tipo de baixa em questao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Folder atual                                         ³±±
±±³          ³ExpC1 : Alias do arquivo de titulos                          ³±±
±±³          ³ExpC2 : Alias do arquivo de compensacao                      ³±±
±±³          ³ExpN2 : Valor a receber                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1 : Numero da baixa                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo retornar o tipo de baixa pen-  ³±±
±±³          ³dente                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341TpBx(nFldAtu,nValRec)
Local aAreaCPS := (__cAliCPS)->(GetArea())
Local nTpBaixa := 0
Local aColsLiq  := Iif(nFldAtu == 4,aClone(aCols),aClone(aCols2))

Local nPosPref   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_PREFIXO"} )
Local nPosBco    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_BCOCHQ"} )
Local nPosAge    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_AGECHQ"} )
Local nPosCta    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_CTACHQ"} )
Local nPosNum    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_NUM"} )
Local nPosData   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_VENCTO"} )
Local nPosVlrCh  := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_VLCRUZ"} )
Local nUsado2    := Len(aHeader2)
Local nX         := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as baixas simples                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nValRec > 0
		nTpBaixa := 3
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as baixas por compensacao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(__cAliCPS)
	(__cAliCPS)->(dbGotop())
	While !Eof()
		If (__cAliCPS)->(IsMark("TRB_MARCA",cMarkCmp,ThisInv()))
			nTpBaixa := 5
			Exit
		EndIf
		(__cAliCPS)->(dbSkip())
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as baixas por liquidacao                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nTpBaixa == 0 .And. (!Empty(aColsLiq[1][nPosPref])   .Or. !Empty(aColsLiq[1][nPosBco]) .Or. !Empty(aColsLiq[1][nPosAge]) .Or.;
							!Empty(aColsLiq[1][nPosCta])    .Or. !Empty(aColsLiq[1][nPosNum]) .Or. !Empty(aColsLiq[1][nPosData])) .And.;
							aColsLiq[1][nPosVlrCh]>0

		For nX := 1 to Len(aColsLiq)
			If !aColsLiq[nX][nUsado2+1]
				If Empty(aColsLiq[nX][Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_ADM"} ) ] )
					nTpBaixa := 4
					Exit
				EndIf
			EndIf
		Next

	EndIf

RestArea(aAreaCPS)
Return nTpBaixa

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341PESQ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Pesquisa de clientes na carga                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Array com clientes                                    ³±±
±±³          ³ExpN2: Posicao atual                                         ³±±
±±³          ³ExpN3: Folder ativo no momento da chamada                    ³±±
±±³          ³ExpC4: Alias do arquivo de titulos                           ³±±
±±³          ³ExpC5: Alias do arquivo de compensacao                       ³±±
±±³          ³ExpA6: Array com os campos para criacao do arquivo           ³±±
±±³          ³ExpA7: Array com a nota e o cliente para o filtro            ³±±
±±³          ³ExpA8: Numero da Carga                                       ³±±
±±³          ³ExpA9: Sequencia da carga                                    ³±±
±±³          ³ExpA10: Objeto do browse de compensacao                      ³±±
±±³          ³ExpA11: Objeto do browse de titulos                          ³±±
±±³          ³ExpA12: Objeto da janela                                     ³±±
±±³          ³cExp13: Motivo da Baixa                                      ³±±
±±³          ³cExp14: Banco                                                ³±±
±±³          ³cExp15: Agencia                                              ³±±
±±³          ³cExp16: Conta                                                ³±±
±±³          ³dExp17: Data da baixa                                        ³±±
±±³          ³dExp18: Data do Credito                                      ³±±
±±³          ³nExp19: Valor Recebido                                       ³±±
±±³          ³nExp20: Valor Total a Receber                                ³±±
±±³          ³nExp21: Qtde de titulos                                      ³±±
±±³          ³nExp22: Valor dos titulos                                    ³±±
±±³          ³nExp23: Valor dos descontos                                  ³±±
±±³          ³nExp24: Valor dos juros                                      ³±±
±±³          ³nExp25: VAlor dos abatimentos                                ³±±
±±³          ³lExp26: Se foi chamada do botao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1 : Numero da baixa                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo retornar o tipo de baixa pen-  ³±±
±±³          ³dente                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Oms341Pesq(aClientes,;
					nX,;
					oFolder,;
					cCodCar,;
					cSeqCar,;
					oMarkCmp,;
					oMarkSE1,;
					oDlg,;
					cMotBx,;
					cBanco,;
					cAgencia,;
					cConta,;
					dBaixa,;
					dDataLiq,;
					dDtCredito,;
					nValRec,;
					nTotRec,;
					nQtdeTit,;
					nValTit,;
					nDescont,;
					nValJur,;
					nAbatim,;
					nPgParc,;
					oSayQtde,;
					oSayVal,;
					oSayRec,;
					nEvento)

Local oDlgPesq
Local nOpca := 0

	DEFINE MSDIALOG oDlgPesq FROM 009, 000 TO 28,80 TITLE OemtoAnsi(STR0061) OF oMainWnd //"Pesquisa de Clientes / Fatura"

		@ 015,005 LISTBOX oNfCli VAR cVar Fields HEADER Rtrim(RetTitle("A1_COD")),; //"Codigo"
														Rtrim(RetTitle("A1_LOJA")),; //"Loja"
														Rtrim(RetTitle("A1_NOME")) ; //"Nome"
														SIZE 300,120 OF oDlgPesq PIXEL

		oNfCli:SetArray(aClientes)
		oNfCli:bLine:={ ||{aClientes[oNfCli:nAT,2],;
							aClientes[oNfCli:nAT,3],;
							aClientes[oNfCli:nAT,4]}}

		oNfCli:Refresh()

	ACTIVATE MSDIALOG  oDlgPesq ON INIT EnchoiceBar(oDlgPesq, {||nX := oNfCli:nAT, Oms341Trb(oFolder:nOption,;
																				aClientes[nX],;
																				cCodCar,;
																				cSeqCar,;
																				oMarkCmp,;
																				oMarkSE1,;
																				oDlg,;
																				@cMotBx,;
																				@cBanco,;
																				@cAgencia,;
																				@cConta,;
																				@dBaixa,;
																				@dDataLiq,;
																				@dDtCredito,;
																				@nValRec,;
																				@nTotRec,;
																				@nQtdeTit,;
																				@nValTit,;
																				@nDescont,;
																				@nValJur,;
																				@nAbatim,;
																				@nPgParc,;
																				oSayQtde,;
																				oSayVal,;
																				oSayRec,;
																				.T.,;
																				nEvento),oDlgPesq:End()},{||oDlgPesq:End()}) CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341LOK2³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Valida a linha da getdados da liquidacao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo validar os cheques da liquida  ³±±
±±³          ³cao digitada                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Oms341LOk2()
Local lRet       := .T.
Local nUsado2    := Len(aHeader2)
Local nVlrCh     := 0
Local aArea      := GetArea()
Local nPosLq     := Ascan(aCols1  ,{|x| Alltrim(x[1]) == "LQ"        })
Local nPosTotRl  := Ascan(aHeader1,{|x| Alltrim(x[2]) == "DAP_REALIZ"})
Local nPosTotBx  := Ascan(aHeader1,{|x| Alltrim(x[2]) == "DAP_VLRBX" })
Local nPosPref   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_PREFIXO"} )
Local nPosBco    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_BCOCHQ" } )
Local nPosAge    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_AGECHQ" } )
Local nPosCta    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_CTACHQ" } )
Local nPosNum    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_NUM"    } )
Local nPosData   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_VENCTO" } )
Local nPosVlrCh  := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_VLCRUZ" } )
Local nPosStatus := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_ADM"    } )
Local nPosCli    := Ascan(aHeader2,{|x| Alltrim(x[2]) == "DA7_CLIENT"} )
Local nPosLoja   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "DA7_LOJA"  } )

Local nQtdCh     := 0
Local nX         := 0

	If (Empty(aCols[n][nPosBco]) .Or. Empty(aCols[n][nPosAge] ) .Or.;
		Empty(aCols[n][nPosCta]) .Or. Empty(aCols[n][nPosNum] ) .Or. Empty(aCols[n][nPosData]).Or. ;
		Empty(aCols[n][nPosCli]) .Or. Empty(aCols[n][nPosLoja]) .Or.;
		Empty(aCols[n][nPosVlrCh]) ) .And. !aCols[n][nUsado2+1]
		Help(" ",1,"OBRIGAT")
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o cheque ja foi digitado na liquidacao              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lRet
		For nX := 1 to Len(aCols)

			If ( aCols[n][nPosPref]+aCols[n][nPosBco]+aCols[n][nPosAge]+aCols[n][nPosCta]+aCols[n][nPosNum] == ;
				aCols[nX][nPosPref]+aCols[nX][nPosBco]+aCols[nX][nPosAge]+aCols[nX][nPosCta]+aCols[nX][nPosNum] ) .And.;
				( nX != n ) .And. !aCols[nX][nUsado2+1] .And. !aCols[n][nUsado2+1]
				Help(" ",1,"OMS341CHQ") //"Cheque ja digitado na liquidacao."
				lRet := .F.
			EndIf

			If !aCols[nX][nUsado2+1] .And. Empty(aCols[nX][nPosStatus])
				nVlrCh += aCols[nX][nPosVlrCh]
				nQtdCh++
			EndIf

		Next
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o total digitado com o acumulado no realizado                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nPosLq > 0

		If ( nVlrCh + aCols1[nPosLq][nPosTotBx]) > aCols1[nPosLq][nPosTotRl]
			lRet := .F.
			Help(" ",1,"OMS341VLLQ") //"O Valor Total das liquidacoes e maior que o realizado."
		EndIf

	EndIf

	If lRet
		oSayQtdCh:SetText(Alltrim(Transform(nQtdCh,"999999") ) )
		oSayValCh:SetText(Alltrim(Transform(nVlrCh,"@R 99,999,999.99") ) )
	EndIf

RestArea(aArea)
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341COB ³ Autor ³ Henry Fila            ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de Geracao de titulos para o motorista                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Total da diferenca gerada                             ³±±
±±³          ³ExpN2: Opcao de manutencao                                   ³±±
±±³          ³       [1]-Inclusao - [2]-Exclusao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo realizar a geracao de titulos  ³±±
±±³          ³para o motorista de acorido com a diferenca da conferencia   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Oms341Cob(nTotalDif,nOpcao)
Local cTitulo  := OemtoAnsi(STR0060) //"Geracao de Cobranca do Motorista"
Local aArea    := GetArea()
Local aSays    := {}
Local aButtons := {}
Local lGera    := .T.
Local nToler   := (GetNewPar("MV_OSTLMOT",0)) //-- Tolerancia para que seja gerada a cobranca contra o motorista

	//Para paises fora do brasil a rend. de contas eh feita como o recibo, entao tenho que RECEBER tudo
	//para poder render, se o motorista nao entregou tudo, ele deve entregar.
	//Manualmente o usuario pode incluir um titulo para o motorista no financeiro
	If cPaisLoc == "BRA"
		If nTotalDif*-1 >  nToler .And. nOpcao == 1

			Aadd(aSays,OemtoAnsi(STR0062)) //"Existe uma diferenca entre o valor previsto e o valor total recebi-"
			Aadd(aSays,OemtoAnsi(STR0063)) //"do. Sera gerado um titulo para o fornecedor associado ao motorista "
			Aadd(aSays,OemtoAnsi(STR0064)) //"responsavel pelo transporte da Carga.                              "

			AADD(aButtons, { 1,.T.,{|o| FechaBatch() } } )
			AADD(aButtons, { 2,.T.,{|o| FechaBatch(),lGera := .F. } } )

			FormBatch( cTitulo, aSays, aButtons )

			RestArea(aArea)

		EndIf
	EndIf

Return(lGera)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OS341BXAUT  ³ Autor ³ Henry Fila          ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de baixa automatica dos titulos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo da Carga                                       ³±±
±±³          ³       Sequencia da CArga                                    ³±±
±±³          ³       Moeda                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo baixar os titulos automaticamen³±±
±±³          ³te de acordo com as formas de baixa  simples                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Os341BxAut(lProcessa,cCarga,cSeqCar,nMoeda)
Local aArea      := GetArea()
Local aFormas    := {}
Local aDevol     := {}
Local aStruSF2   := {}
Local aBaixa     := {}
Local aParam     := {}
Local aRecCps    := {}
Local aRecTit    := {}
Local aOs341Cbx  := {}

Local bWhile

Local cCliente   := ""
Local cQuery     := ""
Local cAliasSF2  := "SF2"
Local cMotBx     := SuperGetMv("MV_OMSMOT",.F.,"")
Local cBanco     := Padr(SuperGetMv("MV_OMSBCO",.F.,""),Len(SA6->A6_COD))
Local cAgencia   := Padr(SuperGetMv("MV_OMSAGE",.F.,""),Len(SA6->A6_AGENCIA))
Local cConta     := Padr(SuperGetMv("MV_OMSCTA",.F.,""),Len(SA6->A6_NUMCON))
Local cTpBxCR    := SuperGetMv("MV_OMSBXCR",.F.,"")
Local cTpNoBx    := SuperGetMv("MV_OMSNOBX",.F.,"")
Local cLote      := ""

Local nTpBaixa   := SuperGetMv("MV_OMSTPBA",.F.,1)
Local nPGrupo    := aScan(aHeader1,{|x| AllTrim(x[2])=="DAP_CODGRU"})
Local nPReal     := aScan(aHeader1,{|x| AllTrim(x[2])=="DAP_REALIZ"})
Local nPVlrBx    := aScan(aHeader1,{|x| AllTrim(x[2])=="DAP_VLRBX"})
Local nPDifere   := aScan(aHeader1,{|x| AllTrim(x[2])=="DAP_DIFERE"})
Local nX         := 0
Local nVlrABx    := 0
Local nVlrRec    := 0
Local nVlrAReal  := 0
Local nTipoOper  := OsVlEntCom()

Local lRetorno   := .T.
Local lBatido    := .T.
Local lOs341Cbx  := ExistBlock("OS341CBX")
Local oExec      := Nil

DEFAULT nMoeda   := 1
DEFAULT lProcessa:= .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a baixa automatica pode ser efetuada                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aCols1)
		If AllTrim(aCols1[nX][nPGrupo]) == "BX"
			If aCols1[nX][nPReal] == aCols1[nX][nPDifere]
				lBatido := .T.
				Exit
			EndIf
		Else
			If aCols1[nX][nPReal] <> aCols1[nX][nPVlrBx] .And. aCols1[nX][nPGrupo] <> "OT"
				lBatido := .F.
			EndIf
		EndIf
	Next nX
	lRetorno := lBatido
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validar os parametros                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cMotBX) .Or. Empty(cBanco) .Or. Empty(cAgencia) .Or. Empty(cConta)
		lRetorno := .F.
	Else
		dbSelectArea("SA6")
		dbSetOrder(1)
		If !MsSeek(xFilial("SA6")+cBanco+cAgencia+cConta)
			lRetorno := .F.
		Else
			If !cMotBx$"DEV#NOR#DAC"
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Efetua a baixa automatica dos titulos                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. lProcessa
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega os parametros da baixa                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Pergunte("OMS341",.F.)

		Aadd(aParam,(mv_par01 == 1))
		Aadd(aParam,(mv_par02 == 1))
		Aadd(aParam,(mv_par03 == 1))
		Aadd(aParam,(mv_par04 == 1))
		Aadd(aParam,(mv_par05 == 1))
		Aadd(aParam,(mv_par06 == 1))

		cLote := Oms341Lote(cCarga,cSeqCar,1)
		aFormas := OsFormasPg(cCarga,cSeqCar,nMoeda,3,@aDevol)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Compensacao das devolucoes de venda                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDevol :=aSort(aDevol,,,{|x,y| x[1] < y[1]})
		For nX := 1 To Len(aDevol)
			dbSelectArea("SD1")
			dbSetOrder(1)
			If MsSeek(xFilial("SD1")+aDevol[nX][1])

				dbSelectArea("SF1")
				dbSetOrder(1)
				If MsSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
					While !Eof() .And. xFilial("SF1") == SF1->F1_FILIAL .And.;
						SD1->D1_DOC       == SF1->F1_DOC .And.;
						SD1->D1_SERIE     == SF1->F1_SERIE .And.;
						SD1->D1_FORNECE   == SF1->F1_FORNECE .And.;
						SD1->D1_LOJA      == SF1->F1_LOJA
						If SD1->D1_FORMUL == SF1->F1_FORMUL .And. SD1->D1_TIPO == SF1->F1_TIPO

							dbSelectArea("SE1")
							dbSetOrder(2)
							If MsSeek(xFilial("SE1")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_PREFIXO+SF1->F1_DOC)

								While !Eof() .And. SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == ;
									xFilial("SE1")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_PREFIXO+SF1->F1_DOC

									If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .And. SE1->E1_SALDO > 0
										Aadd(aRecCPS,SE1->(Recno()))
									EndIf

									dbSelectArea("SE1")
									dbSkip()
								EndDo

							EndIf

						EndIf

						dbSelectArea("SF1")
						dbSkip()

					EndDo
				EndIf
			EndIf
			If Len(aRecCPS) > 0

				dbSelectArea("SD2")
				dbSetOrder(3)
				If MsSeek(xFilial("SD2")+aDevol[nX][2])

					dbSelectArea("SF2")
					dbSetOrder(1)
					If MsSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)

						dbSelectArea("SE1")
						dbSetOrder(2)
						If MsSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DOC)

							While !Eof() .And. SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == ;
								xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DOC

								If SE1->E1_TIPO $ MVNOTAFIS
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Verifica o valor em aberto dos titulos                               ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									aVlrBx := FaVlAtuCr("SE1",dDataBase,cMotBx)

									If Len(aVlrBx) > 0
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Efetuar Baixa                                                       ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										Aadd(aRecTit,SE1->(Recno()))
									EndIf
								EndIf

								dbSelectArea("SE1")
								dbSkip()

							Enddo
						EndIf

					EndIf

				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Efetuar Baixa                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aRecCps) > 0 .And. Len(aRecTit) > 0
				MaIntBxCR(3,aRecTit,Nil,aRecCps,Nil,aParam,{|x,y| OmsGrvDAM(x,y,cCarga,cSeqcar,cLote,"3")})
			EndIf

			aRecCPS := {}
			aRecTit := {}

		Next nX
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processamento das baixas automaticas                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o valor total a ser baixado                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlrAReal := 0
		For nX := 1 To Len(aCols1)
			If AllTrim(aCols1[nX][nPGrupo]) == "BX"
				nVlrAReal += aCols1[nX][nPReal]
			EndIf
		Next nX
		For nX := 1 To Len(aFormas)
			//-- Conforme campo CV_FORMAPG / Tabela SCV - Pedidos X Formas de pagamento.
			If  (nTpBaixa==1 .And.  Alltrim(aFormas[nX][3]) $ cTpBxCR) .Or. ;
				(nTpBaixa==2 .And. !Alltrim(aFormas[nX][3]) $ cTpNoBx)
				If nTpBaixa == 1
					nVlrABx := Min(aFormas[nX][5]-aFormas[nX][6],nVlrAReal)
				Else
					nVlrABx := nVlrAReal
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica o cliente a ser analisado                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCliente := aFormas[nX][2]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica as notas do cliente                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SF2")
				dbSetOrder(5)
				bWhile    := {|| !Eof() }

				cAliasSF2 := "OS341BXAUT"
				cQuery := "SELECT ? FROM "+RetSqlName("SF2")+" SF2 WHERE "
				If nTipoOper == 1
					cQuery    += "SF2.F2_FILIAL='"+xFilial("SF2")+"' AND "
				EndIf
				cQuery    += "SF2.F2_CARGA=? AND "
				cQuery    += "SF2.F2_SEQCAR=? AND "
				cQuery    += "SF2.D_E_L_E_T_=?"
				cQuery := ChangeQuery(cQuery)
				oExec := FwExecStatement():New(cQuery)
				
				oExec:SetUnsafe(1,'F2_CLIENTE,F2_LOJA,F2_PREFIXO,F2_DOC ')
				oExec:SetString(2,cCarga)
				oExec:SetString(3,cSeqCar)
				oExec:SetString(4,' ')

				cAliasSF2 := oExec:OpenAlias()

				While Eval(bWhile)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica os titulos do cliente                                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA == aFormas[nX][2]
						dbSelectArea("SE1")
						dbSetOrder(2)
						MsSeek(xFilial("SE1")+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA+(cAliasSF2)->F2_PREFIXO+(cAliasSF2)->F2_DOC)
						While ( !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
							(cAliasSF2)->F2_CLIENTE == SE1->E1_CLIENTE .And.;
							(cAliasSF2)->F2_LOJA == SE1->E1_LOJA .And.;
							(cAliasSF2)->F2_PREFIXO == SE1->E1_PREFIXO .And.;
							(cAliasSF2)->F2_DOC == SE1->E1_NUM )

							If SE1->E1_TIPO $ MVNOTAFIS
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica o valor em aberto dos titulos                               ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aVlrBx := FaVlAtuCr("SE1",dDataBase,cMotBx)
								If aVlrBx[FIN_VLRVRM] > 0
									nVlrRec   := Min(aVlrBx[FIN_VLRVRM],nVlrABx)
									nVlrABx   -= nVlrRec
									nVlrAReal -= nVlrRec

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³Ponto de entrada proprio para trocar o banco, agencia e conta³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

									If lOs341Cbx
										aOs341Cbx := ExecBlock("OS341CBX",.F.,.F.,{cBanco,cAgencia,cConta,cMotBx})
										cBanco    := aOs341Cbx[1]
										cAgencia  := aOs341Cbx[2]
										cConta    := aOs341Cbx[3]
										cMotBx    := aOs341Cbx[4]
									EndIf

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Efetuar Baixa                                                       ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									aBaixa := {TrazCodMot(cMotBx),nVlrRec,cBanco,cAgencia,cConta,dDataBase,dDataBase}
									MaIntBxCR(1,{SE1->(RecNo())},aBaixa,Nil,Nil,aParam,{|x,y| OmsGrvDAM(x,y,cCarga,cSeqcar,cLote,"1")})
								EndIf
							EndIf
							dbSelectArea("SE1")
							dbSkip()
						EndDo
					EndIf
					dbSelectArea(cAliasSF2)
					dbSkip()
				EndDo
				dbSelectArea(cAliasSF2)
				dbCloseArea()
				dbSelectArea("SF2")
			EndIf
		Next nX

		If ExistBlock("OS341FBA")
			ExecBlock("OS341FBA",.F.,.F.,{cCarga,cSeqCar})
		EndIf

	EndIf

Return(lRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OS341BXAUT  ³ Autor ³ Henry Fila          ³ Data ³08.08.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de baixa automatica dos titulos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo da Carga                                       ³±±
±±³          ³       Sequencia da CArga                                    ³±±
±±³          ³       Moeda                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo baixar os titulos automaticamen³±±
±±³          ³te de acordo com as formas de baixa  simples                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341End()
Local aFormas   := {}
Local nX        := 0
Local lFim      := .F.
Local nLancado  := 0
Local nRealizad := 0
Local nToler    := (GetNewPar("MV_OSTLREC",0))

	//-- -------------------------------------------------------------------------
	//-- |-| OT | OUTROS         | -------- | DEVOLUCOES | --------- | --------- |
	//-- |1| BX | BAIXAS SIMPLES | PREVISTO | DEVOLUCOES | REALIZADO | EFETUADO  | -> MV_OMSBXCR = R$/CC/FI/BOL
	//-- |2| LQ | LIQUIDACOES    | PREVISTO | DEVOLUCOES | REALIZADO | EFETUADO  | -> MV_OMSBXLQ = CH/CHP
	//-- |3| CP | COMPENSACOES   | PREVISTO | DEVOLUCOES | REALIZADO | EFETUADO  | -> MV_OMSBXCP = .
	//-- -------------------------------------------------------------------------
	aFormas := OsAglForma(DAK->DAK_COD,DAK->DAK_SEQCAR,1)
	For nX := 1 To Len(aFormas)
		If  AllTrim(aFormas[nX][1]) <> "OT"
			If Iif(!Empty(aFormas[nX][5]),aFormas[nX][5] > aFormas[nX][6],aFormas[nX][3]+aFormas[nX][4] > aFormas[nX][6])
				lFim := .F.
			EndIf
		EndIf
		//-- Se a somatoria do valor lancado for >= que o valor total, altera o Status da legenda p/ vermelho.
		nRealizad += aFormas[nX][3] //-- PREVISTO
		nLancado  += aFormas[nX][6] //-- EFETUADO
		If nLancado + __SDesc >= nRealizad     //-- Desconto capturado durante calculo do totalizador
			lFim := .T.
		EndIf
	Next nX

	If !lFim .And. nToler > 0
		If (nRealizad - nLancado) <= nToler
			lFim := .T.
		EndIf
	EndIf

	Begin Transaction
		If lFim
			OsAvalDAK("DAK",9)
		Else
			OsAvalDAK("DAK",10)
		EndIf
	End Transaction

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Oms341DtLq   ³ Autor ³ Henry Fila         ³ Data ³ 11/08/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Validacao da data de recebimento da liquidacao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD1: Data da liquidacao    s                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida se a data e maior que a data base                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMS341                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341DtLq(dDataLiq)
Local lRet := .T.

	If dDataLiq > dDatabase .Or. !DtMovFin(dDataLiq)
		Help(" ",1,"DATAERR")
		lRet := .F.
	EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Oms341VProc  ³ Autor ³ Henry Fila         ³ Data ³ 11/08/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Validacao dos dados da liquidacao caso ja tenha sido processa³±±
±±³          ³da                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida se a liquidacao ja foi processada                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ OMS341                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Oms341VProc()
Local cCampo    := ReadVar()
Local cConteudo := &cCampo
Local cCpoOri   := StrTran(cCampo,"M->","")
Local nPosVar   := Ascan(aHeader,{|x| Alltrim(x[2]) == cCpoOri})
Local nPosSts   := Ascan(aHeader,{|x| Alltrim(x[2]) == "E1_ADM"})
Local lRet      := .T.

	If nPosVar > 0
		If !Empty(aCols[n][nPosSts])
			If (aCols[n][nPosVar] <> cConteudo)
				Help(" ",1,"OMS341JPRC") //Esta liquidação não pode ser mais alterada pois já foi processada para baixa.
				lRet := .F.
			EndIf
		EndIf
	EndIf

	Oms341COk2()

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Oms341Seq ³ Autor ³ Henry Fila            ³ Data ³16.09.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Funcao que traz a sequencia de processamento da prestacao de ³±±
±±³          ³contas                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Sequencia da numeracao do processamento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Oms341Seq()

	cSeqTrb341 := Soma1(cSeqTrb341,Len(cSeqTrb341))

Return(cSeqTrb341)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OmsCadCR  ³ Autor ³ Kleber Dias Gomes     ³ Data ³06/10/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Funcao que posiciona o SE1.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OmsCadCR(cCodFil,nQtdeTit)
Local lRetorno   := .T.
Local cSldBxCr   := SuperGetMv("MV_SLDBXCR",.F.,"B")
Default nQtdeTit := 0

	dbSelectArea("SE1")
	dbSetOrder(1)
	If !MsSeek(OsFilial("SE1",cCodFil)+(__cAliTRB)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
		lRetorno := .F.
	EndIf

	//-- Nao permite informar cheques na baixa para mais de 1 titulo marcado
	If  lRetorno .And. cSldBxCr == "C" .And. nQtdeTit > 1
		lRetorno := .F.
	EndIf

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OmsCMC7   ³ Autor ³ Eduardo Riera         ³ Data ³29/11/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Funcao de leitura de leitora de cheque - com interface       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³OMS341                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OmsCMC7()
Local cModelo   := Alltrim(SuperGetMv("MV_CMC7MOD",.F.,""))
Local cPrtCMC7  := AllTrim(SuperGetMv("MV_CMC7PRT",.F.,""))
Local nHdlCMC7  := -1
Local cMensagem := Space(34)
Local oSay
Local oGet
Local oButton
Local oDlg
Local oBold

	If !Empty(cModelo)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Modelo de leitora por porta serial                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cPrtCMC7)
			CheckDLLLj()
			nHdlCMC7 := CMC7Abr(cModelo,cPrtCMC7,"N")
		EndIf

		If nHdlCMC7 >= 0
			Processa({|lEnd| OmsCMC7Com(nHdlCMC7,@lEnd)},,"",.T.)
			CMC7Fec( nHdlCMC7, cPrtCMC7 )
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Modelo de leitora por porta de teclado                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DEFINE MSDIALOG oDlg FROM 200, 001 TO 300, 300 TITLE STR0087 Of oMainWnd PIXEL //"Leitora de Cheque"
			DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
			@ 010  ,013 SAY oSay PROMPT STR0088 Of oDlg PIXEL SIZE 130, 050 FONT oBold  //"Capturando cheques..."
			@ 018 , 013 MSGET oGet  VAR cMensagem Of oDlg PIXEL SIZE 120, 009 VALID (cMensagem := OmsCMC7Tec(cMensagem,oSay,oGet),.T.)
			oButton := TButton():New(35,100,STR0090,oDlg,{|| oButton:SetFocus(),oDlg:End()},32,10,,oDlg:oFont,.F.,.T.,.F.,,.F.,,,.F.) //"Sair"
			ACTIVATE MSDIALOG oDlg CENTERED
		EndIf
	Else
		Help("",1,"")
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OmsCMC7Com³ Autor ³ Eduardo Riera         ³ Data ³29/11/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Funcao de leitura de leitora de cheque - serial              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Handle da leitora de cheque                           ³±±
±±³          ³ExpL2: Força termino na rotina                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³OMS341                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OmsCMC7Com(nHdl,lEnd)
Local nRetorno := 0
Local cBuffer  := ""
Local nPBco    := GdFieldPos("E1_BCOCHQ")
Local nPAge    := GdFieldPos("E1_AGECHQ")
Local nPCta    := GdFieldPos("E1_CTACHQ")
Local nPNum    := GdFieldPos("E1_NUM")
Local nLinha   := N
Local nUsado   := Len(aHeader)
Local nX       := 0
Local nLidos   := 0
Local nTam1    := 14
Local nTam2    := 6
Local nTamNum  := TamSx3("E1_NUM")[1]
Local lOMSCMC7 := ExistBlock("OMSCMC7")

	//1234567890123456789012345678901234
	//<bbbaaaa <nnnnnnnnn >   cccccccc C
	//<34161168<0010002995>651020209808C
	//<23728016<0010002185>777500568207C
	Sleep(2000)
	While nRetorno <> 1 .And. !lEnd
		Sleep(1000)
		IncProc(STR0088+":"+AllTrim(Str(nLidos,6))) //"Capturando cheques..."
		cBuffer  := space(200)
		nRetorno :=CMC7LeD(nHdl,@cBuffer)
		If !Empty(cBuffer)
			If(nTamNum==9)
				nTam1 := 11
				nTam2 := 9
			EndIf
			If nPBco <> 0 .And. nPAge<>0 .And. nPCta<> 0 .And. nPNum<>0
				If aScan(aCols,{|x| x[nPBco] == SubStr(cBuffer, 2, 3) .And.;
									x[nPAge] == SubStr(cBuffer, 5, 4) .And.;
									x[nPCta] == SubStr(cBuffer,25, 8) .And.;
									x[nPNum] == SubStr(cBuffer,nTam1,nTam2) })==0
					If !Empty(aCols[nLinha][nPNum])
						aadd(aCols,Array(nUsado+1))
						nLinha := Len(aCols)
						For nX := 1 To nUsado
							aCols[nLinha][nX] := CriaVar(aHeader[nX,2],.T.)
						Next nX
						aCols[nLinha][Len(aHeader)+1] := .F.
					EndIf
					aCols[nLinha][nPBco] := SubStr(cBuffer, 2, 3)
					aCols[nLinha][nPAge] := SubStr(cBuffer, 5, 4)
					aCols[nLinha][nPCta] := SubStr(cBuffer,25, 8)
					aCols[nLinha][nPNum] := SubStr(cBuffer,nTam1,nTam2)


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Executa ponto de entrada apos montagem do acols para complemento         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lOMSCMC7
						ExecBlock("OMSCMC7",.F.,.F.,{cBuffer,nLinha})
					EndIf

				EndIf
			EndIf
			nLidos ++
		EndIf
		If KillApp()
			Exit
		EndIf
	EndDo

Return(!lEnd)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OmsCMC7Tec³ Autor ³ Eduardo Riera         ³ Data ³29/11/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Funcao de leitura de leitora de cheque - teclado             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Leitura                                               ³±±
±±³          ³ExpO2: Objeto say                                            ³±±
±±³          ³ExpO2: Objeto Get                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³OMS341                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OmsCMC7Tec(cBuffer,oSay,oGet)
Local nPBco    := GdFieldPos("E1_BCOCHQ")
Local nPAge    := GdFieldPos("E1_AGECHQ")
Local nPCta    := GdFieldPos("E1_CTACHQ")
Local nPNum    := GdFieldPos("E1_NUM")
Local nLinha   := N
Local nUsado   := Len(aHeader)
Local nX       := 0
Local nTam1    := 14
Local nTam2    := 6
Local nTamNum  := TamSx3("E1_NUM")[1]

	If !Empty(cBuffer)
		If(nTamNum==9)
			nTam1 := 11
			nTam2 := 9
		EndIf
		If nPBco <> 0 .And. nPAge<>0 .And. nPCta<> 0 .And. nPNum<>0
			If aScan(aCols,{|x| x[nPBco] == SubStr(cBuffer, 2, 3) .And.;
								x[nPAge] == SubStr(cBuffer, 5, 4) .And.;
								x[nPCta] == SubStr(cBuffer,25, 8) .And.;
								x[nPNum] == SubStr(cBuffer,nTam1,nTam2) })==0
				If !Empty(aCols[nLinha][nPNum])
					aadd(aCols,Array(nUsado+1))
					nLinha := Len(aCols)
					For nX := 1 To nUsado
						aCols[nLinha][nX] := CriaVar(aHeader[nX,2],.T.)
					Next nX
					aCols[nLinha][Len(aHeader)+1] := .F.
				EndIf
				aCols[nLinha][nPBco] := SubStr(cBuffer, 2, 3)
				aCols[nLinha][nPAge] := SubStr(cBuffer, 5, 4)
				aCols[nLinha][nPCta] := SubStr(cBuffer,27, 8)
				aCols[nLinha][nPNum] := SubStr(cBuffer,nTam1,nTam2)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Executa ponto de entrada apos montagem do acols para complemento         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("OMSCMC7")
					ExecBlock("OMSCMC7",.F.,.F.,{cBuffer,nLinha})
				EndIf

			EndIf
		EndIf
		oGet:SetFocus()
	EndIf
	oSay:SetText(STR0088+": "+AllTrim(Str(Len(aCols),6))) //"Capturando cheques..."

Return(Space(34))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Oms341Rec ³ Autor ³ Marco Bianchi         ³ Data ³26/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao disparada para validar cada registro da tabela      ³±±
±±³          ³ DAP e adicionar recno no array aRecDAP.                    ³±±
±±³          ³ Se retornar .T. considera o registro.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array com numero dos registros da tabela SF2         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Oms341Rec(aRecDAP)

	aadd(aRecDAP,DAP->(RecNo()))

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OMS341PCol³ Autor ³ Marco Bianchi         ³ Data ³26/12/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza colunas no aCols                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array aCols                                          ³±±
±±³          ³ExpA2: Array aFromas ja preenchido                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OMS341PCol(aCols,aFormas,lDelConf)
Local nPosPrevis := GDFieldPos("DAP_PREVIS")
Local nPosDevol  := GDFieldPos("DAP_DEVOL")
Local nPosRealiz := GDFieldPos("DAP_REALIZ")
Local nPosForma  := Ascan(aFormas,{|x| Alltrim(x[3]) == Alltrim(DAP->DAP_CODGRU) })

	If  lDelConf
		If  aCols[1][GDFieldPos("DAP_REC_WT")] <> 0
			nTotal += aCols[Len(aCols)][nPosPrevis]
			If nPosForma > 0
				aCols[Len(aCols)][nPosDevol] := aFormas[nPosForma][6]
			EndIf
			nTotalDev += aCols[Len(aCols)][nPosDevol]
			nTotalDig += aCols[Len(aCols)][nPosRealiz]
		EndIf
	EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OMS341VMot³ Autor ³ VICCO                 ³ Data ³03/10/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Validacao do Motivo da Baixa                                ³±±
±±³          ³Limpa conteudo de Bco/Age/Cta/N.Chque se nao mov.banco      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Cod. do Motivo de Baixa                              ³±±
±±³          ³ExpC2: Cod. Banco                                           ³±±
±±³          ³ExpC3: Cod. Agencia                                         ³±±
±±³          ³ExpC4: Cod. Conta                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OMS341VMot(cMotBx,cBanco,cAgencia,cConta)
	If !MovBcoBx(cMotBx, .T.)
		cBanco   := Space(3)
		cAgencia := Space(5)
		cConta   := Space(10)
	EndIf
Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OMS341Fec ³ Autor ³ Katia                 ³ Data ³20/08/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Validacao da Opcao Fechar na Prestacao de Titulos/Clientes  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OMS341Fec()
Local lRet := .T.

	If ExistBlock("OMS341FE")
		lRet := ExecBlock("OMS341FE",.F.,.F.)
		If  ValType(lRet) <> "L"
			lRet:= .T.
		EndIf
	EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ    ³ÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±    ³±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿    ³±±
±±³Fun‡„o    ³TMSA250VBx³ Autor ³                      ³ Data ³ 23.06.14        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´    ³±±
±±³Descri‡„o ³ Atualiza o Status dos recebimentos efetuados ao motorista        ³±±
±±³pelo valor da mercadoria transportada                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´    ³±±
±±³Sintaxe   ³ OMSA341VBx()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± ±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß ßßß
*/
Function OMSA341VBx()
Local aSays    := {}
Local aButtons := {}
Local lOk      := .F.

	Aadd( aSays, STR0095 ) //"Esta opção irá checar todos os recebimentos de títulos. "
	Aadd( aSays, STR0096 ) //"Caso o cliente tenha pago todos os títulos da carga,então, "
	Aadd( aSays, STR0097 ) //"o status da carga será atualizado "
	Aadd( aButtons, { 1, .T., {|o| lOk := .T., o:oWnd:End() } } )
	Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
	FormBatch( STR0094, aSays, aButtons ) //-- "Status Financeiro"

	If lOk
		Begin Transaction
		Processa({|lEnd| AtuStFin()},STR0094, STR0092,.T.) //"Verificando baixas de títulos a receber. Por favor, aguarde...."
		End Transaction
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    AtuStFin   Autor ³                         ³ Data ³ 23.Jun.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa a atualizacao dos Status dos Recebimentos          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OMSA341PBx()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtuStFin(cCarga,cSeqCar,cAceFin)
Local aArea     := GetArea()
Local aAreaDAK  := DAK->(GetArea())
Local cAliasDAK := GetNextAlias()
Local cAliasQry := ""
Local cQuery    := ""
Local nTipoOper := OsVlEntCom()

Default cCarga  := ""
Default cSeqCar := ""
Default cAceFin := "3"

	cQuery := "SELECT DAK_COD,"
	cQuery +=       " DAK_SEQCAR,"
	cQuery +=       " R_E_C_N_O_ RECNODAK"
	cQuery +=  " FROM "+RetSqlName("DAK")+" DAK"
	cQuery += " WHERE "
	If nTipoOper == 1
		cQuery += " DAK_FILIAL = '"+xFilial("DAK")+"' AND"
	EndIf
	If !Empty(cCarga)
		cQuery +=     " DAK_COD    = '"+cCarga+"'"
		cQuery += " AND DAK_SEQCAR = '"+cSeqCar+"' AND"
	EndIf
	cQuery +=       " DAK_ACEFIN = '"+cAceFin+"'"
	cQuery +=   " AND DAK_ACECAR = '1'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY DAK_COD"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDAK,.F.,.T.)

	While !(cAliasDAK)->(Eof())

		cQuery := "SELECT 1"
		cQuery +=  " FROM "+RetSqlName("SF2")+" SF2"
		cQuery += " INNER JOIN "+RetSqlName("SE1")+" SE1"
		cQuery +=    " ON SE1.E1_FILIAL  = SF2.F2_FILIAL"
		cQuery +=   " AND SE1.E1_CLIENTE = SF2.F2_CLIENTE"
		cQuery +=   " AND SE1.E1_LOJA    = SF2.F2_LOJA"
		cQuery +=   " AND SE1.E1_PREFIXO = SF2.F2_PREFIXO"
		cQuery +=   " AND SE1.E1_NUM     = SF2.F2_DOC"
		cQuery +=   " AND SE1.E1_STATUS  = 'A'"
		cQuery +=   " AND SE1.D_E_L_E_T_ = ' '"
		cQuery += " WHERE "
		If nTipoOper == 1
			cQuery +=   " SF2.F2_FILIAL  = '"+xFilial("SE1")+"' AND"
		EndIf
		cQuery +=       " SF2.F2_CARGA   = '"+(cAliasDAK)->DAK_COD+"'"
		cQuery +=   " AND SF2.F2_SEQCAR  = '"+(cAliasDAK)->DAK_SEQCAR+"'"
		cQuery +=   " AND SF2.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If !(cAliasQry)->(Eof())
			DAK->(DbGoTo((cAliasDAK)->RECNODAK))
			RecLock("DAK",.F.)
			DAK->DAK_ACEFIN := "3"  // Conferido
			DAK->(MsUnlock())
		Else
			DAK->(DbGoTo((cAliasDAK)->RECNODAK))
			RecLock("DAK",.F.)
			DAK->DAK_ACEFIN := "1"  // Encerrado
			DAK->(MsUnlock())
		EndIf
		(cAliasQry)->(DbCloseArea())

		(cAliasDAK)->(DbSkip())
	EndDo
	(cAliasDAK)->(DbCloseArea())

RestArea(aAreaDAK)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    CpoTit341  Autor ³                         ³ Data ³ 23.Jun.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Campos que aparecerão na pasta título.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CpoTit341()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CpoTit341()
Local cCpoSE1 := ""
Local cRetPE  := ""

	cCpoSE1 += "E1_FILIAL;"
	cCpoSE1 += "E1_PREFIXO;"
	cCpoSE1 += "E1_NUM;"
	cCpoSE1 += "E1_PARCELA;"
	cCpoSE1 += "E1_TIPO;"
	cCpoSE1 += "E1_NATUREZ;"
	cCpoSE1 += "E1_CLIENTE;"
	cCpoSE1 += "E1_LOJA;"
	cCpoSE1 += "E1_NOMCLI;"
	cCpoSE1 += "E1_EMISSAO;"
	cCpoSE1 += "E1_VENCTO;"
	cCpoSE1 += "E1_VENCREA;"
	cCpoSE1 += "E1_VALOR;"
	cCpoSE1 += "E1_HIST;"
	cCpoSE1 += "E1_DESCFIN;"
	cCpoSE1 += "E1_DESCDIA;"
	cCpoSE1 += "E1_ACRESC;"
	cCpoSE1 += "E1_DECRESC;"
	cCpoSE1 += "E1_MOEDA;"
	cCpoSE1 += "E1_DESCONT;"
	cCpoSE1 += "E1_BAIXA;"
	cCpoSE1 += "E1_TXMOEDA;"
	cCpoSE1 += "E1_SDDECRE;"
	cCpoSE1 += "E1_SDACRES;"
	cCpoSE1 += "E1_VALJUR;"
	cCpoSE1 += "E1_PORCJUR;"
	cCpoSE1 += "E1_MULTA;"
	cCpoSE1 += "E1_VALLIQ;"
	cCpoSE1 += "E1_LIDESCF;"
	cCpoSE1 += "E1_DIADESC;"
	cCpoSE1 += "E1_TIPODES;"
	cCpoSE1 += "E1_DESCJUR;"
	cCpoSE1 += "E1_DTVARIA;"
	cCpoSE1 += "E1_ORIGEM;"
	cCpoSE1 += "E1_SALDO;"
	cCpoSE1 += "E1_JUROS;"

	// Permite indicar quais campos de usuário da tabela SE1
	// deverão ser apresentados na tela de Prestação de Contas
	If ExistBlock("OM341CTI")
		cRetPE := ExecBlock("OM341CTI",.F.,.F.)
		If ValType(cRetPE) == "C"
			cCpoSE1 += cRetPE
		EndIf
	EndIf

Return cCpoSE1

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OMS341COK2³ Autor ³Fabio Marchiori Sampaio³ Data ³23.03.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. ou .F.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo validar os cheques da liquida  ³±±
±±³          ³cao digitada                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APDL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Oms341COk2()
Local lRet      := .T.
Local nUsado2   := Len(aHeader2)
Local nVlrCh    := 0
Local aArea     := GetArea()
Local nPosTotRl := Ascan(aHeader1,{|x| Alltrim(x[2]) == "DAP_REALIZ"})
Local nPosTotBx := Ascan(aHeader1,{|x| Alltrim(x[2]) == "DAP_VLRBX"})
Local nPosLq    := Ascan(aCols1,{|x| Alltrim(x[1]) == "LQ"})
Local nPosPref  := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_PREFIXO"} )
Local nPosBco   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_BCOCHQ"} )
Local nPosAge   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_AGECHQ"} )
Local nPosCta   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_CTACHQ"} )
Local nPosNum   := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_NUM"} )
Local nPosData  := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_VENCTO"} )
Local nPosVlrCh := Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_VLCRUZ"} )
Local nPosStatus:= Ascan(aHeader2,{|x| Alltrim(x[2]) == "E1_ADM"} )
Local nQtdCh    := 0
Local nX        := 0

	If (Empty(aCols[n][nPosBco]) .Or. Empty(aCols[n][nPosAge]) .Or.;
		Empty(aCols[n][nPosCta]) .Or. Empty(aCols[n][nPosNum]) .Or. Empty(aCols[n][nPosData]).Or. ;
		Empty(aCols[n][nPosVlrCh]) ) .And. !aCols[n][nUsado2+1]
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o cheque ja foi digitado na liquidacao              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lRet
		For nX := 1 to Len(aCols)

			If ( aCols[n][nPosPref]+aCols[n][nPosBco]+aCols[n][nPosAge]+aCols[n][nPosCta]+aCols[n][nPosNum] == ;
				aCols[nX][nPosPref]+aCols[nX][nPosBco]+aCols[nX][nPosAge]+aCols[nX][nPosCta]+aCols[nX][nPosNum] ) .And.;
				( nX != n ) .And. !aCols[nX][nUsado2+1] .And. !aCols[n][nUsado2+1]
				Help(" ",1,"OMS341CHQ") //"Cheque ja digitado na liquidacao."
				lRet := .F.
			EndIf

			If !aCols[nX][nUsado2+1] .And. Empty(aCols[nX][nPosStatus])
				nVlrCh += aCols[nX][nPosVlrCh]
				nQtdCh++
			EndIf

		Next
	EndIf

	If lRet
		oSayQtdCh:SetText(Alltrim(Transform(nQtdCh,"999999") ) )
		oSayValCh:SetText(Alltrim(Transform(nVlrCh,"@R 99,999,999.99") ) )
	EndIf

RestArea(aArea)
Return(lRet)
/*/{Protheus.doc} OmsProcCmp
Função responsável por processar a compensação de títulos
@author amanda.vieira
@since 27/12/2018
@version 1.0
@return lógico, indica sucesso da operação
@param aFirst, array, array para gravar os títulos compensados
@param cSequen, caracter, sequência do título de baixa
@type function
/*/
Static Function OmsProcCmp(aFirst,cSequen)
Local lRet      := .T.
Local cAliasSE1 := ""
Local cQuery    := ""
Local cAliasTmp := ""
Local nSaldoTit := 0
Local nSaldo    := 0
Local nPosCp    := Ascan(aCols1,{|x| Alltrim(x[1]) == "CP"})
Local nPosOt    := Ascan(aCols1,{|x| Alltrim(x[1]) == "OT"})
Local nPosTotBx := Ascan(aHeader1,{|x| Alltrim(x[2]) == "DAP_VLRBX"})
Local aAreaCPS  := (__cAliCPS)->(GetArea())
	(__cAliCPS)->(dbGotop())
	While (__cAliCPS)->(!Eof())
		If (__cAliCPS)->(IsMark("TRB_MARCA",cMarkCmp,ThisInv()))
			//Saldo do título à compensar
			nSaldo := (__cAliCPS)->E1_SALDO
			//Busca títulos que encontram-se marcados e com saldo para baixa para o mesmo cliente/loja da compensação
			cQuery := " SELECT R_E_C_N_O_ RECNOSE1," 
			cQuery +=        " E1_SALDO"
			cQuery +=   " FROM "+__oTempSE1:GetRealName()
			cQuery +=  " WHERE E1_CLIENTE = '"+(__cAliCPS)->E1_CLIENTE+"'"
			cQuery +=    " AND E1_LOJA = '"+(__cAliCPS)->E1_LOJA+"'"
			cQuery +=    " AND E1_SALDO > 0"
			cQuery +=    " AND TRB_MARCA <> ' '"
			cQuery +=    " AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasSE1 := GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSE1,.F.,.T.)
			While (cAliasSE1)->(!EoF()) .And. nSaldo > 0
				//Cálculo do saldo da compensação e do saldo do título
				If nSaldo >= (cAliasSE1)->E1_SALDO
					nSaldo -= (cAliasSE1)->E1_SALDO
					nSaldoTit := 0
				Else
					nSaldoTit := (cAliasSE1)->E1_SALDO - nSaldo
					nSaldo := 0
				EndIf
				//Grava saldo do título
				(__cAliTRB)->(DbGoTo((cAliasSE1)->RECNOSE1))
				RecLock(__cAliTRB,.F.)
				(__cAliTRB)->E1_SALDO  := nSaldoTit
				(__cAliTRB)->(MsUnlock())

				//Ajusta valor a receber
				If  nPosCp > 0
					aCols1[nPosCp][nPosTotBx] +=(__cAliTRB)->TRB_VALREC
				Else
					aCols1[nPosOt][nPosTotBx] +=(__cAliTRB)->TRB_VALREC
				EndIf

				//Grava tabela de processamento apenas se o registro ainda não estiver gravado
				cQuery := " SELECT E1_NUM"
				cQuery +=   " FROM "+__oTempPRC:GetRealName()
				cQuery +=  " WHERE TRB_FILTIT = '"+(__cAliTRB)->TRB_FILTIT+"'"
				cQuery +=    " AND E1_PREFIXO = '"+(__cAliTRB)->E1_PREFIXO+"'"
				cQuery +=    " AND E1_NUM     = '"+(__cAliTRB)->E1_NUM+"'"
				cQuery +=    " AND E1_PARCELA = '"+(__cAliTRB)->E1_PARCELA+"'"
				cQuery +=    " AND E1_TIPO    = '"+(__cAliTRB)->E1_TIPO+"'"
				cQuery +=    " AND D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				cAliasTmp := GetNextAlias()
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTmp,.F.,.T.)
				If (cAliasTmp)->(EoF())
					RecLock(__cAliPRC,.T.)
					(__cAliPRC)->TRB_RECNO := (__cAliTRB)->TRB_RECNO
					(__cAliPRC)->TRB_FILTIT:= (__cAliTRB)->TRB_FILTIT
					(__cAliPRC)->TRB_SEQUEN:= cSequen
					(__cAliPRC)->TRB_OPERA := "3"
					(__cAliPRC)->E1_NUM    := (__cAliTRB)->E1_NUM
					(__cAliPRC)->E1_TIPO   := (__cAliTRB)->E1_TIPO
					(__cAliPRC)->E1_PARCELA:= (__cAliTRB)->E1_PARCELA
					(__cAliPRC)->E1_PREFIXO:= (__cAliTRB)->E1_PREFIXO
					(__cAliPRC)->E1_VALOR  := (__cAliTRB)->E1_VALOR
					(__cAliPRC)->E1_CLIENTE:= (__cAliTRB)->E1_CLIENTE
					(__cAliPRC)->E1_LOJA   := (__cAliTRB)->E1_LOJA
					(__cAliPRC)->(MsUnlock())

					aFirst[1] := (__cAliTRB)->(Recno())
					aFirst[2] := (__cAliPRC)->(Recno())
				EndIf
				(cAliasTmp)->(DbCloseArea())
				(cAliasSE1)->(dbSkip())
			EndDo
			(cAliasSE1)->(dbCloseArea())

			//Grava saldo do título
			If !((__cAliCPS)->E1_SALDO == nSaldo)
				RecLock(__cAliCPS,.F.)
				(__cAliCPS)->TRB_OPERA := "3"
				(__cAliCPS)->TRB_MARCA := Space(2)
				(__cAliCPS)->E1_SALDO  := nSaldo
				(__cAliCPS)->(MsUnlock())
			EndIf
		EndIf
		(__cAliCPS)->(dbSkip())
	EndDo
	RestArea(aAreaCPS)
Return lRet
/*/{Protheus.doc} Cpl6EnvPed
Função responsável por retornar a soma dos acertos já realizados para o título
Essa função é utilizada para os casos onde 1 título será baixado por 2 compensações diferentes
@author amanda.vieira
@since 02/01/2019
@version 1.0
@return nSomaAcert, soma dos acertos já realizados para o título
@param cCarga, caracter, carga da baixa
@param cSeqCar, caracter, sequência da carga
@param cLote, caracter, lote da baixa
@param cBaixa, caracter, tipo da baixa
@type function
/*/
Static Function OmsValDAM(cCarga,cSeqCar,cLote,cBaixa)
Local nSomaAcert:= 0
Local cQuery    := ""
Local cAliasDAM := ""
	cQuery := " SELECT SUM(DAM_VALOR) DAM_VALOR"
	cQuery +=   " FROM "+RetSqlName('DAM')+" DAM"
	cQuery +=  " WHERE DAM.DAM_FILIAL = '"+xFilial("DAM")+"'"
	cQuery +=    " AND DAM.DAM_CARGA  = '"+cCarga+"'"
	cQuery +=    " AND DAM.DAM_SEQCAR = '"+cSeqCar+"'"
	cQuery +=    " AND DAM.DAM_CLIENT = '"+SE1->E1_CLIENTE+"'"
	cQuery +=    " AND DAM.DAM_LOJA   = '"+SE1->E1_LOJA+"'"
	cQuery +=    " AND DAM.DAM_LOTE   = '"+cLote+"'"
	cQuery +=    " AND DAM.DAM_PREFIX = '"+SE1->E1_PREFIXO+"'"
	cQuery +=    " AND DAM.DAM_NUMERO = '"+SE1->E1_NUM+"'"
	cQuery +=    " AND DAM.DAM_PARCEL = '"+SE1->E1_PARCELA+"'"
	cQuery +=    " AND DAM.DAM_TIPO   = '"+SE1->E1_TIPO+"'"
	cQuery +=    " AND DAM.DAM_TPBAIX = '"+cBaixa+"'"
	cQuery +=    " AND DAM.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasDAM := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDAM,.F.,.T.)
	If (cAliasDAM)->(!EoF())
		nSomaAcert := (cAliasDAM)->DAM_VALOR
	EndIf
	(cAliasDAM)->(DbCloseArea())
Return nSomaAcert


