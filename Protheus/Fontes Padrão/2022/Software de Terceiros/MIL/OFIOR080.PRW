// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 04     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "Protheus.ch"
#INCLUDE "OFIOR080.CH"

/*                                                                                  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ OFIOR080 ³ Autor ³ Wagner Xavier         ³ Data ³ 05.09.91 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relacao da Analise de Estoques                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo P.S.³17/11/97³12867A³ Incluir perg. Lista prod.c/saldo zerado. ³±±
±±³Edson   M.  ³19/01/98³XXXXXX³ Inclusao do Campo C2_SLDOP.              ³±±
±±³Edson   M.  ³02/02/98³XXXXXX³ Subst. do Campo C2_SLDOP p/ Funcao.      ³±±
±±³FernandoJoly³10/11/98³XXXXXX³ Ajuste para o Ano 2000.                  ³±±
±±³Rodrigo Sart³07/02/99³META  ³ Filtragem por Tipo de OP.                ³±±
±±³Patricia Sal³13/03/00³Melhor³ Inclusao perg. Almoxarifado de/ate.      ³±±
±±³Patricia Sal³19/10/00³006423³ Incluir perg. "Consid Residuos PV ?"     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR080
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL Tamanho  := "G"
LOCAL titulo   := STR0001	//"Relacao para Analise dos Estoques"
LOCAL cDesc1   := STR0002	//"Este relatorio demonstra a situacao de cada item em relacao ao"
LOCAL cDesc2   := STR0003	//"seu saldo , seu empenho , suas entradas previstas e sua classe"
LOCAL cDesc3   := STR0004	//"ABC."
LOCAL cString  := "SB1"
LOCAL nTipo    := 0
LOCAL aOrd     := {OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008),OemToAnsi(STR0020)}  //############" Por Consumo //" Por Codigo         "###" Por Tipo           "###" Por Descricao     "###" Por Grupo        "
LOCAL wnrel := "OFIOR080"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aReturn:= {OemToAnsi(STR0009), 1,OemToAnsi(STR0010), 1, 2, 1, "",1 }			//"Zebrado"###"Administracao"
PRIVATE nLastKey:= 0 ,cPerg := "OFR080"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // Produto de                                   ³
//³ mv_par02     // Produto ate                                  ³
//³ mv_par03     // tipo de                                      ³
//³ mv_par04     // tipo ate                                     ³
//³ mv_par05     // grupo de                                     ³
//³ mv_par06     // grupo ate                                    ³
//³ mv_par07     // descricao de                                 ³
//³ mv_par08     // descricao ate                                ³
//³ mv_par09     // Tudo ou so a Comprar                         ³
//³ mv_par10     // Subtrai empenho para Calculo Saldo           ³
//³ mv_par11     // Lista apenas itens obsoletos                 ³
//³ mv_par12     // data limite p/itens obsoletos                ³
//³ mv_par13     // Cons. Saldo do Almox. Processo ?  Sim , Nao  ³
//³ mv_par14     // Desconsidera P.V. que N Atu.Est.? Sim , Nao  ³
//³ mv_par15     // Lista produto com Saldo zerado  ? Sim , Nao  ³
//³ mv_par16     // Considera OPs 1- Firmes 2- Previstas 3- Ambas³
//³ mv_par17     // Almoxarifado De  ?                           ³
//³ mv_par18     // Almoxarifado Ate ?                           ³
//³ mv_par19     // Consid Residuos PV ?  Sim, Nao               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho)

If nLastKey = 27
   Set Filter to
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
   Set Filter to
   Return
Endif
RptStatus({|lEnd| C290Imp(aOrd,@lEnd,wnRel,cString,tamanho,titulo)},titulo)
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C290IMP  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 12.12.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C290Imp(aOrd,lEnd,WnRel,cString,tamanho,titulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cRodaTxt := STR0022
LOCAL nCntImpr := 0
LOCAL nSaldoPro,nEmpPro,nSCPro,nPCPro,nOPPro,nPVPro
LOCAL nSaldoSub,nEmpSub,nSCSub,nPCSub,nOPSub,nPVSub
LOCAL nSaldoTot,nEmpTot,nSCTot,nPCTot,nOPTot,nPVTot
LOCAL lPAssou1,lPassou2,nFirst := 0,dUsai,nSaldo, cLocProc := GETMV("MV_LOCPROC")
LOCAL cArqTmp,cFiltro
Local cChave := ""

//
Local cGruVei    := PadR(AllTrim(GetNewPar("MV_GRUVEI","VEIC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Local cGruSrv    := PadR(AllTrim(GetNewPar("MV_GRUSRV","SRVC")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Servico
//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE li := 80 ,m_pag := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis privadas exclusivas deste programa                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCondicao ,lContinua ,cVar ,cCondSec

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := IIF(aReturn[4]==1,GetMV("MV_COMP"),GetMV("MV_NORM"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona a ordem escolhida ao titulo do relatorio          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("NewHead")#"U"
   NewHead += " ("+AllTrim(aOrd[aReturn[8]])+")"
Else
   Titulo += " ("+AllTrim(aOrd[aReturn[8]])+")"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cabec1 := STR0011		//" GRUP   COD ITEM       CODIGO          DESCRICAO                      TP   UM   SALDO ATUAL   EMPENHO PARA           SC's PC's/CONTRATOS           OP's           PV's     PONTO DE         LOTE   PRAZO  ESTOQUE       CONSUMO   ULTIMA   CL  "
cabec2 := STR0012		//"                                                                         REQ/PV/RESERVA      COLOCADAS      COLOCADOS      COLOCADAS      COLOCADOS       PEDIDO    ECONOMICO ENTREGA EM MESES         MEDIO    SAIDA       "

dbSelectArea("SB1")
SetRegua(LastRec())

Set Softseek On
Set Order To aReturn[8]

If aReturn[8] == 4
   Seek cFilial+mv_par05
   cCondicao := "lContinua .And. !Eof() .And. B1_GRUPO <= mv_par06"
ElseIf aReturn[8] == 3
       Seek cFilial+mv_par07
       cCondicao := "lContinua .And. !Eof() .And. B1_DESC <= mv_par08"
ElseIf aReturn[8] == 2
       Seek cFilial+mv_par03
       cCondicao := "lContinua .And. !Eof() .And. B1_TIPO <= mv_par04"
Else
       Seek cFilial+mv_par01
       cCondicao := "lContinua .And. !Eof() .And. B1_COD <= mv_par02"
Endif
Set SoftSeek Off

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona os indices dos arquivos consultados                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC1")
dbSetOrder(2)

dbSelectArea("SC2")
dbSetOrder(2)

dbSelectArea("SC6")
dbSetOrder(2)

dbSelectArea("SC7")
dbSetOrder(2)

Store 0 To nSaldoTot,nEmpTot,nSCTot,nPCTot,nOPTot,nPVTot
lPassou1  := .F.
lContinua := .T.
If aReturn[8] == 5
	dbSelectArea("SB3")
	cCondicao := "lContinua .And. SB3->(!Eof())"
	cFiltro := "B3_COD>='"+mv_par01+"'.And.B3_COD<='"+mv_par02+"'.and.B3_FILIAL=='"+xFilial("SB3")+"'"
	cArqTmp := CriaTrab('',.F.)
	IndRegua('SB3',cArqTmp,'STR(B3_MEDIA)',,cFiltro,STR0021)  //"Selecionando Registros"
	nIndSb3:=RetIndex("SB3")
	#IFNDEF TOP
		dbSetIndex(cArqTmp+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndSb3 + 1)
	dbGotop()
	
Else
	dbSelectArea("SB1")
	cCondicao += ".and.B1_FILIAL=='"+xFilial("SB1")+"'"
Endif
While &cCondicao
    cCondSec := "B1_FILIAL=='"+xFilial("SB1")+"' .And. "
	If aReturn[8] == 5
		dbSelectArea("SB1")
		dbSeek(xFilial()+SB3->B3_COD)
		cCondSec += "B1_COD == SB3->B3_COD"
	ElseIf aReturn[8] == 4
		
		cVar     := B1_GRUPO
		cCondSec += "B1_GRUPO == cVar"
	ElseIf aReturn[8] == 3
		cVar     := B1_DESC
		cCondSec += "B1_DESC == cVar"
	ElseIf aReturn[8] == 2
		cVar     := B1_TIPO
		cCondSec := "B1_TIPO == cVar"
	Else
		cVar     := B1_COD
		cCondSec += "B1_COD == cVar"
	Endif
	
	Store 0 To nSaldoSub,nEmpSub,nSCSub,nPCSub,nOPSub,nPVSub
	lPassou2 := .F.
	While &cCondicao .And. &(cCondSec)
		
		If lEnd
			@ PROW()+1,001 PSay  STR0013		//"CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		EndIf
		
		IncRegua()

		// Desconsiderar VEICULOS e SERVICOS
		If B1_GRUPO == cGruVei .or. B1_GRUPO == cGruSrv
			Skip
			Loop
		EndIf
		
		If B1_COD < mv_par01 .Or. B1_COD > mv_par02
			Skip
			Loop
		EndIf
		
		If B1_LOCPAD < mv_par17 .Or. B1_LOCPAD > mv_par18
			Skip
			Loop
		EndIf
		
		If B1_TIPO < mv_par03 .Or. B1_TIPO > mv_par04
			Skip
			Loop
		EndIf
		
		If B1_GRUPO < mv_par05 .Or. B1_GRUPO > mv_par06
			Skip
			Loop
		EndIf
		
		If B1_DESC < mv_par07 .Or. B1_DESC > mv_par08
			Skip
			Loop
		EndIf
		
		Store 0 To nSaldoPro,nEmpPro,nSCPro,nPCPro,nOPPro,nPVPro
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Soma os saldos iniciais e os empenhos do SB2                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB2")
		Seek cFilial+SB1->B1_COD
		dUsai := B2_USAI
		While !Eof() .And. B2_FILIAL+B2_COD == cFilial+SB1->B1_COD
			
			If lEnd
				@ PROW()+1,001 PSay STR0013	//"CANCELADO PELO OPERADOR"
				lContinua := .F.
				Exit
			EndIf
			
			IF B2_LOCAL == cLocProc .and. mv_par13 == 2
				dbSkip()
				Loop
			Endif
			nSaldoPro += B2_QATU
			nEmpPro   += If(mv_par16==1,B2_QEMP,If(mv_par16==2,B2_QEMPPRE,B2_QEMP+B2_QEMPPRE))
			nEmpPro   += B2_RESERVA
			If dUsai < B2_USAI
				dUsai := B2_USAI
			EndIf
			dbSkip()
			
		EndDo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se deve subtrair empenho do saldo atual             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par10 == 1
			nSaldoPro -= nEmpPro
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se deve listar apenas os obsoletos                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par11 == 1 .And. (Empty(dUsai) .Or. dUsai > mv_par12)
			dbSelectArea("SB1")
			dbSkip()
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o relatorio foi interrompido pelo usuario        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lContinua
			Exit
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona-se no arquivo de Demandas para pegar dados         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aReturn[8] # 5
			dbSelectArea("SB3")
			dbSeek(cFilial+SB1->B1_COD)
		EndIf
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Aglutina as Solicitacos de Compra sem pedido colocado        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC1")
		Seek cFilial+SB1->B1_COD
		While !Eof() .And. C1_FILIAL+C1_PRODUTO == cFilial+SB1->B1_COD
			
			If lEnd
				@ PROW()+1,001 PSay STR0013		//"CANCELADO PELO OPERADOR"
				lContinua := .F.
				Exit
			EndIf
			
			If C1_QUJE < C1_QUANT .And. MtrAvalOp(mv_par16,"SC1")
				nSCPro += (C1_QUANT - C1_QUJE)
			EndIf
			dbSkip()
			
		EndDo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o relatorio foi interrompido pelo usuario        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lContinua
			Exit
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Aglutina as Ordens de Producao em aberto                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC2")
		dbSeek(xFilial()+SB1->B1_COD)
		
		While !Eof() .And. C2_FILIAL+C2_PRODUTO == xFilial()+SB1->B1_COD
			
			If lEnd
				@ PROW()+1,001 PSay STR0013		//"CANCELADO PELO OPERADOR"
				lContinua := .F.
				Exit
			EndIf
			
			If Empty(C2_DATRF) .And. (aSC2Sld()) > 0 .And. MtrAvalOp(mv_par16)
				nOPPro += (aSC2Sld())
			EndIf
			dbSkip()
			
		EndDo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o relatorio foi interrompido pelo usuario        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lContinua
			Exit
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Aglutina os Pedidos de Vendas ainda nao entregues            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC6")
		Seek cFilial+SB1->B1_COD
		
		While !Eof() .And. C6_FILIAL+C6_PRODUTO == cFilial+SB1->B1_COD
			
			If lEnd
				@ PROW()+1,001 PSay STR0013	//"CANCELADO PELO OPERADOR"
				lContinua := .F.
				Exit
			EndIf
			
			If MV_PAR14 == 1
				dbSelectArea("SF4")
				dbSetOrder(1)
				dbSeek(xFilial()+SC6->C6_TES)
				dbSelectArea("SC6")
				If SF4->F4_ESTOQUE != "S"
					dbSkip()
					Loop
				End
			End
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se devera considerar ou nao os Residuos             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par19 == 2 .And. AllTrim(C6_BLQ) == "R"
				dbSkip()
				Loop
			EndIf
			
			nPVPro += SC6->C6_QTDVEN
			dbSelectArea("SC9")
			dbSetOrder(1)
			cChave :=xFilial() + SC6->C6_NUM + SC6->C6_ITEM
			If dbSeek(cChave)
				While ! SC9->(EOF()) .And. cChave=SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM
					If (Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED)) .And.+;
						SC9->C9_PRODUTO == SC6->C6_PRODUTO
						nPvPro -= SC9->C9_QTDLIB
					ElseIf SC9->C9_BLEST == "10" .AND. SC9->C9_PRODUTO == SC6->C6_PRODUTO
						nPvPro -= SC9->C9_QTDLIB
					EndIF
					dbskip()
				End
			Endif
			nPVPro := Max(0,nPVPro)
			dbSelectArea("SC6")
			dbSkip()
			
		EndDo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o relatorio foi interrompido pelo usuario        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lContinua
			Exit
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Aglutina os Pedidos de Compra ainda nao entregues            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC7")
		Seek cFilial+SB1->B1_COD
		
		While !Eof() .And. C7_FILIAL+C7_PRODUTO == cFilial+SB1->B1_COD
			
			If lEnd
				@ PROW()+1,001 PSay STR0013		//"CANCELADO PELO OPERADOR"
				lContinua := .F.
				Exit
			EndIf
			
			If (C7_QUANT-C7_QUJE) > 0 .And. Empty(C7_RESIDUO) .And. MtrAvalOp(mv_par16,"SC7")
				nPCPro += (C7_QUANT-C7_QUJE)
			EndIf
			dbSkip()
			
		EndDo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o relatorio foi interrompido pelo usuario        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lContinua
			Exit
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica deve listar apenas os itens a comprar               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par09 == 2
			nSaldo := nSaldoPro+nSCPro+nPCPro+nOPPro
			If nSaldo > SB1->B1_EMIN .Or. (SB1->B1_EMIN == 0 .And. nSaldo == 0)
				dbSelectArea("SB1")
				dbSkip()
				Loop
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica deve listar saldo de produto zerado                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par15 == 2
			If nSaldoPro == 0
				dbSelectArea("SB1")
				dbSkip()
				Loop
			Endif
		Endif
		
		lPassou1 := .T.
		lPassou2 := .T.
		
		If li > 58
			Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona 1 ao contador de registros impressos         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCntImpr++
		
		dbSelectArea("SB1")  
     
		@ li,000 PSay ""
		@ li,pcol()+1 PSay substr(SB1->B1_GRUPO,1,4)   
		@ li,pcol()+1 pSay substr(SB1->B1_CODITE,1,27)   
		@ li,pcol()+1 PSay Substr(B1_DESC,1,29)   
		@ li,pcol()+1 PSay B1_TIPO
		@ li,pcol()+1 PSay B1_UM
		@ li,pcol()+1 PSay nSaldoPro Picture PesqPictQt("B2_QATU",8)
		@ li,pcol()+1 PSay nEmpPro   Picture PesqPictQt("B2_QEMP",8)       
		@ li,pcol()+1 PSay nSCPro    Picture PesqPictQt("C1_QUANT",8)
		@ li,pcol()+1 PSay nPCPro    Picture PesqPictQt("C7_QUANT",8)
	  	@ li,pcol()+1 PSay nOPPro    Picture PesqPictQt("C2_QUANT",8)
		@ li,pcol()+3 PSay nPVPro    Picture PesqPictQt("C6_QTDVEN",8)
		@ li,pcol()+1 PSay B1_EMIN   Picture PesqPictQt("B1_EMIN",8)
		@ li,pcol()+1 PSay B1_LE     Picture PesqPictQt("B1_LE",12)
		@ li,pcol()+1 PSay CalcPrazo(B1_COD,B1_LE) Picture "99999"
		@ li,pcol()+1 PSay B1_TIPE     
	  		
		If SB3->B3_MEDIA != 0
  	  	  	@ li,pcol()+3 PSay nSaldoPro/SB3->B3_MEDIA Picture "99999"
  	  	Else
	      @ li,pcol()+5 PSay "N/D"
	  	EndIf
        @ li,pcol()+1 PSay SB3->B3_MEDIA Picture PesqPictQt("B3_MEDIA",13)
        @ li,pcol()+3 PSay dUsai
        @ li,pcol()+1 PSay SB3->B3_CLASSE 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Soma o Total do Produto ao total da quebra                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSaldoSub += nSaldoPro
		nEmpSub   += nEmpPro
		nSCSub    += nSCPro
		nPCSub    += nPCPro
		nOPSub    += nOPPro
		nPVSub    += nPVPro
		
		Skip
		li++
		
	EndDo
	
	If (aReturn[8] == 2 .Or. aReturn[8] == 4) .And. lPassou2
		If aReturn[8] == 2
			@ li,024 PSay STR0014+cVar		//"T o t a l  d o   T i p o : "
		ElseIf aReturn[8] == 4
			@ li,023 PSay STR0015+cVar		//"T o t a l   d o   G r u p o : "
		EndIf    
	

		@ li,058 PSay nSaldoSub Picture PesqPictQt("B2_QATU",8)
		@ li,073 PSay nEmpSub   Picture PesqPictQt("B2_QEMP",8)
		@ li,088 Say nSCSub    Picture PesqPictQt("C1_QUANT",8)
    	@ li,103 PSay nPCSub    Picture PesqPictQt("C7_QUANT",8)
    	@ li,118 PSay nOPSub    Picture PesqPictQt("C2_QUANT",8)
		@ li,133 pSay nPVSub    Picture PesqPictQt("C6_QTDVEN",8)
	   @ li,  0 PSay __PrtThinLine()
     
      
      
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Soma o Total do Produto ao total da quebra                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSaldoTot += nSaldoSub
	nEmpTot   += nEmpSub
	nSCTot    += nSCSub
	nPCTot    += nPCSub
	nOPTot    += nOPSub
	nPVTot    += nPVSub
	
	If aReturn[8] == 5
		dbSelectArea("SB3")
		dbSkip()
	Else
		dbSelectArea("SB1")
	EndIf
	
EndDo

If lPassou1

   If li > 56
      Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
   EndIf

   li++
   @ li,23 PSay STR0016              //"T o t a l   G e r a l :"
   @ li,pcol()+24 PSay nSaldoTot Picture PesqPictQt("B2_QATU",8)
   @ li,pcol()+01 PSay nEmpTot   Picture PesqPictQt("B2_QEMP",8)
   @ li,pcol()+1 PSay nSCTot    Picture PesqPictQt("C1_QUANT",8)
   @ li,pcol()+1 PSay nPCTot    Picture PesqPictQt("C7_QUANT",8)
   @ li,pcol()+1 PSay nOPTot    Picture PesqPictQt("C2_QUANT",8)
   @ li,pcol()+3 PSay nPVTot    Picture PesqPictQt("C6_QTDVEN",8)

EndIf

dbSelectArea("SC1")
dbSetOrder(1)
dbSelectArea("SC2")
dbSetOrder(1)
dbSelectArea("SC6")
dbSetOrder(1)
dbSelectArea("SC7")
dbSetOrder(1)

If li != 80
   Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original do arquivo principal             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cString)
Set Filter To
Set Order To 1

If aReturn[5] = 1
   Set Printer To
   dbCommitAll()
   OurSpool(wnrel)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga Arquivos Temporarios                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[8] == 5
   dbSelectArea("SB3")
   Ferase(cArqTmp+OrdBagExt())
   dbSetOrder(1)
EndIf

MS_FLUSH()

Return()