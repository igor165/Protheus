#Include "FINC030.CH"
#Include "PROTHEUS.CH"
#Include "MSGRAPHI.CH"

Static lFc030Con
Static _oFINC0301
Static _oFINC0302
Static _oFINC0303  
Static _oFINC0304
Static _oFINC0305
Static _oFINC0306
Static _oFINC0307
Static _oFINC0308
Static __lExisFKD	:= .F.
Static __lFAPodeTVA	:= ExistFunc( "FAPodeTVA" )

#DEFINE POS_DATA	1
#DEFINE POS_TIPO	2
#DEFINE POS_CLIFOR	3
#DEFINE POS_LOJA	4
#DEFINE POS_RECPAG	5
#DEFINE POS_BANCO	6
#DEFINE POS_AGENCIA	7                  
#DEFINE POS_CONTA	8
#DEFINE POS_NUMCHEQ	9
#DEFINE POS_NATUREZ	10
#DEFINE POS_ORDREC	11
#DEFINE POS_MOTBX	12
#DEFINE POS_TIPODOC	13
#DEFINE POS_VALOR	14
#DEFINE POS_TXMOEDA	15
#DEFINE POS_HISTOR	16
#DEFINE POS_VLMOED2	17
#DEFINE POS_VLJUROS	18
#DEFINE POS_VLMULTA	19
#DEFINE POS_VLDESCO	20


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINC030  ³ Autor ³ Wagner Xavier             ³ Data ³ 15/01/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta a Posicao de Fornecedores                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpX1 := FINC030( ExpC1 )                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FinC030( cRotina, nPosArotina )

LOCAL xRet := .T.
Local aRotinaNew   
Local cFilter := Nil
Local lConsVisual	:= .F.

Private aRotina := MenuDef()
// Ponto de entrada F030TitAber
Private lF030TitAb := ExistBlock("F030TITABER")
// Ponto de entrada F030TitPago
Private lF030TitPg := ExistBlock("F030TITPAGO")
// Ponto de entrada F030TitCom
Private lF030TitCom := ExistBlock("F030TITCOM")
// Ponto de entrada F030TitFat
Private lF030TitFat := ExistBlock("F030TITFAT")
Private oRed		:= LoadBitmap(GetResources(), "BR_VERMELHO")
Private oGre		:= LoadBitmap(GetResources(), "BR_VERDE")
Private oYel		:= LoadBitmap(GetResources(), "BR_AMARELO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita o Banco de Conhecimento                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aRotina,{STR0131,"MsDocument", 0 , 6}) //"Conhecimento"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. utilizado para adicionar itens no Menu da mBrowse       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FC030ROT")
	aRotinaNew := ExecBlock("FC030ROT",.F.,.F.,aRotina)
	If (ValType(aRotinaNew) == "A")
		aRotina := aClone(aRotinaNew)
	EndIf
EndIf

PRIVATE cCadastro  := STR0005 //"Consulta Posi‡„o Fornecedores"
PRIVATE nJuros
PRIVATE nTotal1    := nTotal2 := nTotal3 := 0
PRIVATE dBaixa     := dDataBase
PRIVATE nVlrGerNF := 0
PRIVATE nVlrGerNF5:= 0

PRIVATE oFolder030
Private nDest030
Private cFilCorr	:= cFilAnt

M-> nJuros := 0
DEFAULT nPosArotina := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso a função de F030VISUAL esteja na pilha de chamada   ³
//³ não executar a consulta novamente                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lConsVisual := FwIsInCallStack("F030VISUAL")

If GetHlpLGPD({"A2_CGC"})
	Return
EndIf

If ValType( cRotina ) == "C"
   If !lConsVisual
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Faz tratamento para chamada por outra rotina             ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If !Empty( nScan := AScan( aRotina, { |x| x[2] == cRotina } ) ) 
	      cRoda := cRotina + "( 'SA2', SA2->( Recno() ), " + Str(nScan,2) + ")" 
	      xRet  := Eval( { || &( cRoda ) } ) 
	   EndIf 
	Else
		MsgAlert(STR0153) //"A rotina de consulta Posição Fornecedor(FINC030) já está sendo executada"
	EndIf
Else	
	If ExistBlock("FC030FIL")
		cFilter := ExecBlock( "FC030FIL",.F.,.F.,{cFilter})
	EndIf      

   SetKey (VK_F12,{|a,b| Pergunte("FIC030",.T.)})

   If nPosArotina > 0 // Sera executada uma opcao diretamento de aRotina, sem passar pela mBrowse
	   dbSelectArea("SA2")
	   bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
	   Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina)
   Else	
	   mBrowse( 6, 1,22,75,"SA2",,,,,,,,,,,,,,cFilter)
   Endif
   Set Key VK_F12 To
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera as Ordens Originais                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC7")
dbSetOrder(1)
dbSelectArea("SF1")
dbSetOrder(1)
dbSelectArea("SE2")
dbSetOrder(1)
dbSelectArea("SA2")
dbSetOrder(1)

Return( xRet ) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fc030Con ³ Autor ³ Wagner Xavier         ³ Data ³ 15/01/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta a Posicao de Fornecedores                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FINC030()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fc030Con()
 
	Local lPanelFin		:= IsPanelFin()
	Local nCont			:= 0
	Local aTamSX3		:= {}
	Local lProc030a		:= .F.  // Carregar dados de Titulos em aberto
	Local lProc030b		:= .F.  // Carregar dados de Titulos Pagos
	Local lProc030c		:= .F.  // Carregar dados de Pedidos e Produtos
	Local lProc030d		:= .F.  // Carregar dados de Faturamento
	Local lProc030e		:= .F.  // Carregar dados da Devolucao
	Local lProc030f		:= .F.  // Carregar dados da Entrega
	Local cFilBkp		:= cFilAnt
	Local lC7Fiscori	:= SC7->(FieldPos("C7_FISCORI")) > 0
	Local cDesMoed1   	:= SuperGetMv('MV_SIMB1',.F.,"R$") 

	Private aCampos1	:= {}
	Private aCampos2	:= {}
	Private aCampos3	:= {}
	Private aCampos4	:= {}
	Private aCampos5	:= {}
	Private aCampos6	:= {}
	Private aCampos7	:= {}  
	Private aCampos8	:= {}
	Private aNomearq[8]	
	Private aTotal6		:= {0.00,0,0.00,0}
	Private nCasas		:= GetMv("MV_CENT")
	Private nTitulos1	:= nTitulos2 := nTitulos3 := nTitulos4 := nTitulos5 := nTitulos6 := nTitulos7 := nTitulos8 := 0
	Private nTot1		:= nTot2     := 0
	Private aSelFil		:= {}
	Private aTmpFil		:= {}
	Private aTmpTables	:= {}
	
	nTotal1    := nTotal2 := nTotal3 := 0 

	//-------------------------------------------------------------------
	// Valores Acessórios
	//-------------------------------------------------------------------
	__lExisFKD := TableInDic('FKD') .And. TableInDic('FKC')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as Perguntas                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPanelFin
		 lPergunte := PergInPanel("FIC030",.T.)
	Else
		If FunName()=="FINC030"
			lPergunte := Pergunte("FIC030",.T.)
		Else
			Pergunte("FIC030",.F.)
		    lPergunte := .T.
		Endif
	Endif
	
	If !lPergunte 
		cFilant := cFilBkp
		Return
	Endif 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulos Em Aberto ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTamSx3 := TamSX3("E2_NUM")
	aCampos1:=	{{"FILORIG"		, "C", FWSizeFilial(), 0, SX3->(RetTitle("E2_FILORIG"))}, ;			
				{ "PREFIXO"		, "C", 03, 0, STR0006 }, ;						//"Prefixo"
				{ "NUMERO"		, "C", aTamSx3[1],aTamSx3[2], STR0007 }, ;		//"Numero"
				{ "PARCELA"		, "C", TamSx3("E2_PARCELA")[1],0, STR0008 }, ;	//"Parcela"
				{ "TIPO"		, "C", 03, 0,STR0009 }, ;				 		//"Tipo"
				{ "EMISSAO"		, "D", 08, 0,STR0010 }, ;			 			//"Emissao"
				{ "DATAVENC"	, "D", 08, 0,STR0011 }, ;	 					//"Data Vencimento"
				{ "NATUREZA"	, "C", 10, 0,STR0012 }, ;			 			//"Natureza"
				{ "SALDOPAGAR"	, "N", 16, 2,STR0013 }, ;		 				//"Saldo a Pagar"
				{ "ATRASO"		, "N", 06, 0,STR0014 }, ;			 			//"Atraso"
				{ "VALORJUROS"	, "N", 16, 2,STR0015 }, ;			 			//"Valor Juros"
				{ "ACRESCIMO"	, "N", TamSx3("E2_ACRESC")[1] , TamSx3("E2_ACRESC")[2] ,STR0121 }, ;			 			
				{ "DECRESCIMO"	, "N", TamSx3("E2_DECRESC")[1], TamSx3("E2_DECRESC")[2],STR0122 }}			 		
	
	If cPaisLoc == "BRA"	// Sergio Fuzinaka - 20.08.01
		aAdd(aCampos1, { "VLR_IR"	, "N", 16, 2,STR0016 })	//"Valor IRRF"
		aAdd(aCampos1, { "VLR_ISS"	, "N", 16, 2,STR0017 })	//"Valor ISS"
		aAdd(aCampos1, { "VLR_INSS" , "N", 16, 2,STR0018 })	//"Valor INSS"
		If __lExisFKD	//"Valor acessorio"
			aAdd(aCampos1, { "VALORACES", "N", 16, 2,STR0160 })			//"Valor acessorio"
		EndIf //"Valor acessorio"
	EndIf
	aAdd(aCampos1, { "NUMBCO"	, "C", 15, 0,STR0019 })		//"Numero do Cheque"
	aAdd(aCampos1, { "HISTORICO", "C", TamSx3("E2_HIST")[1], 0,STR0120 }) //"Historico"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para incluir campos no arquivo temporario de titulos em aberto.                          ³
	//³ Rdmake deve ter 3 etapas, estas, quando Ponto de Entrada passar como referencia o primeiro valor igual a: ³ 
	//³                                                                                                           ³ 
	//³ (1) - Etapa de Adicionar os campos novos no array de criação do arquivo de dados temporário               ³
	//³ (2) - Etapa de Abastecimento dos campos                                                                   ³
	//³ (3) - Etapa de Tratamento do objeto LISTBOX com os campos que deseja visualizar na aba de Tit Abertos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lF030TitAb // Etapa 1   
		aCampos1 := ExecBlock("F030TITABER",.F.,.F.,{1,aCampos1})	
	Endif                    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulos Pagos                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( cPaisLoc!="BRA" )
		aCampos2 :=	{{"FILORIG"		, "C", FWSizeFilial(), 0, SX3->(RetTitle("E2_FILORIG"))}, ;
					{ "ORDPAGO"		, "C", TamSx3("E2_ORDPAGO")[1], 0, STR0020 },; 					 	//"Ord. de Pago"
					{ "PREFIXO"		, "C", 03, 0, STR0006 }, ;					 	//"Prefixo"
					{ "NUMERO"		, "C", aTamSx3[1],aTamSx3[2], STR0007 }, ;	 	//"Numero"
					{ "PARCELA"		, "C", TamSx3("E2_PARCELA")[1],0, STR0008 }, ;	//"Parcela"
					{ "TIPO"		, "C", 03, 0, STR0009 }, ;						//"Tipo"				
					{ "EMISSAO"		, "D", 08, 0, STR0010 }, ;					 	//"Emissao"
					{ "NATUREZA"	, "C", 10, 0, STR0012 }, ;					 	//"Natureza"
					{ "VALORTIT"	, "N", 16, 2, STR0021 }, ;					 	//"Valor Titulo"
					{ "VALORPAGO"	, "N", 16, 2, STR0022 }, ;					 	//"Valor Pago"
					{ "TX_MOEDA"	, "N", 11, 4, STR0115 }, ;					 	//"Taxa Moeda
					{ "BAIXA"		, "D", 08, 0, STR0023 }, ;					 	//"Data Baixa"
					{ "VENCIMENTO"	, "D", 08, 0, STR0011 }, ;					 	//"Data Vencimento"
					{ "ATRASO"		, "N", 06, 0, STR0014 }, ;					 	//"Atraso"
					{ "BANCO"		, "C", 03, 0, STR0024 }, ;					 	//"Banco"
					{ "AGENCIA"		, "C", 06, 0, STR0025 }, ;					 	//"Agencia"
					{ "CONTA"		, "C", 15, 0, STR0026 }, ;					 	//"Conta"
					{ "HISTORICO"	, "C", TamSx3("E2_HIST")[1], 0, STR0027 }, ;	//"Historico"
					{ "MOTIVO"		, "C", 15, 0, STR0028 }, ;					 	//"Motivo"
					{ "NUMBCO"		, "C", 15, 0, STR0019 }}					 	 //"Numero do Cheque"
	Else
		aCampos2 :=	{{"FILORIG"		, "C", FWSizeFilial(), 0, SX3->(RetTitle("E2_FILORIG"))}, ;
					{ "PREFIXO"		, "C", 03, 0, STR0006 }, ;					 	//"Prefixo"
					{ "NUMERO"		, "C", aTamSx3[1],aTamSx3[2], STR0007 }, ;	 	//"Numero"
					{ "PARCELA"		, "C", TamSx3("E2_PARCELA")[1],0, STR0008 }, ;	//"Parcela"
					{ "TIPO"		, "C", 03, 0, STR0009 }, ;						//"Tipo"								
					{ "EMISSAO"		, "D", 08, 0, STR0010 }, ;					 	//"Emissao"
					{ "VENCIMENTO"	, "D", 08, 0, STR0011 }, ;					 	//"Data Vencimento"
					{ "BAIXA"		, "D", 08, 0, STR0023 }, ;					 	//"Data Baixa"
					{ "NATUREZA"	, "C", 10, 0, STR0012 }, ;					 	//"Natureza"
					{ "VALORTIT"	, "N", 16, 2, STR0021 }, ;					 	//"Valor Titulo"
					{ "VALORPAGO"	, "N", 16, 2, STR0022 }, ;					 	//"Valor Pago"			
					{ "JUROS"		, "N", 16, 2, STR0116 }, ;						//"Juros" 
					{ "MULTA"		, "N", 16, 2, STR0117 }, ;						//"Multa" 
					{ "DESCONTO"	, "N", 16, 2, STR0118 }, ;						//"Desconto" 
					{ "VALORACES"	, "N", 16, 2, STR0160 }, ;						//"Valor Acessório"	
					{ "TX_MOEDA"	, "N", 11, 4, STR0115 }, ;					 	//"Taxa Moeda
					{ "ATRASO"		, "N", 06, 0, STR0014 }, ;					 	//"Atraso"
					{ "BANCO"		, "C", 03, 0, STR0024 }, ;					 	//"Banco"
					{ "AGENCIA"		, "C", 06, 0, STR0025 }, ;					 	//"Agencia"
					{ "CONTA"		, "C", 15, 0, STR0026 }, ;					 	//"Conta"
					{ "HISTORICO"	, "C", TamSx3("E2_HIST")[1], 0, STR0027 }, ;	//"Historico"
					{ "MOTIVO"		, "C", 15, 0, STR0028 }, ;					 	//"Motivo"
					{ "NUMBCO"		, "C", 15, 0, STR0019 }, ;				 	    //"Numero do Cheque"
					{ "VLR_IR"		, "N", 16, 2, STR0016 }, ;	                    //"Valor IRRF"
					{ "VLR_ISS"		, "N", 16, 2, STR0017 }, ;	                    //"Valor ISS"
					{ "VLR_INSS"	, "N", 16, 2, STR0018 }, ;	                    //"Valor INSS"
					{ "MOEDA"	    , "C", 02, 0, STR0162 }, ;						//"Moeda"
					{ "VALPAGTO1"	, "N", 16, 2, STR0022+" ("+cDesMoed1+")" }}   	//"Valor Pago (R$)"
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para incluir campos no arquivo temporario de titulos pagos.                              ³
	//³ Rdmake deve ter 3 etapas, estas, quando Ponto de Entrada passar como referencia o primeiro valor igual a: ³ 
	//³                                                                                                           ³ 
	//³ (1) - Etapa de Adicionar os campos novos no array de criação do arquivo de dados temporário               ³
	//³ (2) - Etapa de Abastecimento dos campos                                                                   ³
	//³ (3) - Etapa de Tratamento do objeto LISTBOX com os campos que deseja visualizar na aba de Tit Pagos       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lF030TitPg // Etapa 1   
		aCampos2 := ExecBlock("F030TITPAGO",.F.,.F.,{1,aCampos2})	
	Endif                    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pedidos de Compras ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lC7Fiscori
		aCampos3 :=	{{"FILORIG"		, "C", FWSizeFilial(), 0, SX3->(RetTitle("C7_FISCORI"))}, ;
					{ "NUMERO"		, "C", 06, 0, STR0007  }, ;				 //"Numero"
					{ "EMISSAO"		, "D", 08, 0, STR0010 }, ;			     //"Emissao"
					{ "ENTREGA"		, "D", 08, 0, STR0135 }, ;				 //"Data de Entrega"
					{ "VALORITEM"	, "N", 16, 2, STR0029 }}				 //"Valor Item"
	Else
		aCampos3 :=	{{"NUMERO"	, "C", 06, 0, STR0007 }, ;					 //"Numero"
					{ "EMISSAO"		, "D", 08, 0, STR0010 }, ;			     //"Emissao"
					{ "ENTREGA"		, "D", 08, 0, STR0135 }, ;				 //"Data de Entrega"
					{ "VALORITEM"	, "N", 16, 2, STR0029}}					 //"Valor Item"
	Endif
					
	If lF030TitCom // Etapa 1   
		aCampos3 := ExecBlock("F030TITCOM",.F.,.F.,{1,aCampos3})	
	Endif  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faturamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	azamSx3 := TamSX3("F1_DOC")
	adupSx3 := TamSX3("F1_DUPL")
	If cPaisLoc == "BRA"
		aCampos4:=		{{"FILORIG"		, "C", FWSizeFilial(), 0, SX3->(RetTitle("F1_FILORIG"))}, ;
						{ "NUMERO"		, "C", aTamSx3[1],aTamSx3[2], STR0007}, ;		//"Numero"
						{ "EMISSAO"		, "D", 08, 0, STR0010 }, ;					    //"Emissao"
						{ "VALORNOTA"	, "N", 16, 2, STR0030 }, ;					    //"Valor Nota"
						{ "DUPLICATA"	, "C",adupSx3[1], 0, STR0031 }, ;			 	//"Duplicata"
						{ "XX_RECNO"	, "N",12, 0,"RECNO" }}			 				//"Recno"
	Else
		aCampos4:=		{{"FILORIG"		, "C", FWSizeFilial(), 0, SX3->(RetTitle("F1_FILORIG"))}, ;
						{ "NUMERO"		, "C", aTamSx3[1],aTamSx3[2], STR0007 }, ;		//"Numero"
						{ "EMISSAO"		, "D", 08, 0, STR0010 }, ;						//"Emissao"
						{ "VALORNOTA"	, "N", 16, 2, STR0030 }, ;						//"Valor Nota"
						{ "DUPLICATA"	, "C",adupSx3[1], 0, STR0031 },; 
						{ "MOEDA"	    , "N", 02, 0, STR0041 }, ;						//"Moeda"
						{ "TAXA"	    , "N", 11, 4, STR0114 }, ;						//"Taxa"
						{ "XX_RECNO"	, "N",12, 0,"RECNO" }}							//"Recno"
	EndIf          
	
	If lF030TitFat // Etapa 1   
		aCampos4 := ExecBlock("F030TITFAT",.F.,.F.,{1,aCampos4})	
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Produtos de Compras ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Prd_Sx3  := TamSX3("C7_PRODUTO")
	Qtd_Sx3  := TamSX3("C7_QUANT")
	Prc_Sx3  := TamSX3("C7_PRECO")
	Desc_Sx3  := TamSX3("C7_DESCRI")
	
	If lC7Fiscori
		aCampos5 :=	{{"FILORIG"	, "C", FWSizeFilial(), 0, SX3->(RetTitle("C7_FISCORI"))}, ;
					{"NUMERO"   , "C", 06, 0, STR0007 }, ;							//"Numero"
				 	{"EMISSAO"	, "D", 08, 0, STR0010 }, ;							//"Emissao"
				 	{"PRODUTO"	, "C", Prd_Sx3[1],Prd_Sx3[2], STR0032 }, ;			//"Produto"
				 	{"DESCRI"	, "C", Desc_Sx3[1],Desc_Sx3[2], STR0132 }, ;		//"Descrição"
				 	{"UM"		, "C", 02, 0, STR0033 }, ;						 	//"UM"
				 	{"SEGUM"	, "C", 02, 0, STR0034 }, ;						 	//"2a.UM"
				 	{"QUANT"	, "N", Qtd_Sx3[1],Qtd_Sx3[2], STR0035 }, ;			//"Quantidade"
				 	{"QTSEGUM"	, "N", Qtd_Sx3[1],Qtd_Sx3[2], STR0036 }, ;		 	//"Quant.2a."
				 	{"PRECO"	, "N", Prc_Sx3[1],Prc_Sx3[2], STR0037 }, ; 	    	//"Vlr.Unit."
				 	{"CONDPAG"	, "C", 03,0, STR0038 }} 						 	//"Cond.Pagto."
	Else			 				 	
		aCampos5 :=	{{"NUMERO"   , "C", 06, 0, STR0007 }, ;						 //"Numero"
				 	{"EMISSAO"	, "D", 08, 0, STR0010 }, ;						 //"Emissao"
				 	{"PRODUTO"	, "C", Prd_Sx3[1],Prd_Sx3[2], STR0032 }, ;		 //"Produto"
				 	{"DESCRI"	, "C", Desc_Sx3[1],Desc_Sx3[2], STR0132  }, ;	 //"Descrição"
				 	{"UM"		, "C", 02, 0, STR0033 }, ;						 //"UM"
				 	{"SEGUM"	, "C", 02, 0, STR0034 }, ;						 //"2a.UM"
				 	{"QUANT"	, "N", Qtd_Sx3[1],Qtd_Sx3[2], STR0035 }, ;		 //"Quantidade"
				 	{"QTSEGUM"	, "N", Qtd_Sx3[1],Qtd_Sx3[2], STR0036 }, ;		 //"Quant.2a."
				 	{"PRECO"	, "N", Prc_Sx3[1],Prc_Sx3[2], STR0037 }, ; 	     //"Vlr.Unit."
				 	{"CONDPAG"	, "C", 03,0, STR0038 }} 						 //"Cond.Pagto."
	Endif			 	
	
	If cPaisLoc	!=	"BRA"
	 	aCampos6 :=	{{"FILORIG"		, "C", FWSizeFilial(), 0, SX3->(RetTitle("E2_FILORIG"))}, ;
 					{"SITUACION"	, "C", 08,0, STR0039 }, ;							//"Situacao"
					{"NUMERO"		, "C", TamSx3("EF_NUM")[1],0, STR0007 }, ;		    //"Numero"
					{"EMISSAO"		, "D", 08,0, STR0010 }, ;							//"Emissao"
					{"VENCTO"		, "D", 08,0, STR0011 }, ;							//"Data Vencimento"
					{"VALOR"		, "N", 16,2, STR0040 }, ;							//"Valor T¡tulo"
					{"MONEDA"		, "N", 02,0, STR0041 }, ;							//"Moeda"
					{"VLMOED1"		, "N", 16,2, STR0042+Getmv("MV_MOEDAP1") }, ;		//"Valor Pesos"
					{"ORDPAGO"		, "C", TamSx3("E2_ORDPAGO")[1],0, STR0020 }, ;	//"Ord. de Pago"
					{"BANCO"		, "C", 03,0, STR0024 }, ;							//"Banco"
					{"AGENCIA"		, "C", 05,0, STR0025 }, ;							//"Agencia"
					{"CUENTA"		, "C", 10,0, STR0026 }, ;							//"Conta"
					{"DTBAIXA"		, "D", 08,0, STR0023 }}								//"Data Baixa"
	Endif
	  
	aCampos7 :=	{{"FILORIG"		, "C", FWSizeFilial(), 0, SX3->(RetTitle("E2_FILORI"))}, ;
				{ "NUMERO" 	 	, "C", TamSX3("F2_DOC")[1], 0, STR0007 }, ;		//"Numero"
				{ "EMISSAO"		, "D", 08, 0, STR0010 }, ;		//"Emissao"
				{ "VALORNOTA"	, "N", 16, 2, STR0029 },;		//"Valor Item"	
				{ "XX_RECNO"	, "N",12, 0,"RECNO"}}
	
	aTamNf   := TamSX3("F1_DOC")
	 
	aCampos8 :=	{{"FILORIG"		, "C", FWSizeFilial(), 0, SX3->(RetTitle("E2_FILORI"))}, ;
				{ "NOTA"  	    , "C", TamSX3("F1_DOC")[1], 0,"NOTA"}, ;
				{ "EMISNF"      , "D", 08, 0,"EMISSAO" },;
				{ "PEDIDO"      , "C", TamSX3("C7_NUM")[1], 0,"PEDIDO" },;
				{ "EMISPD"      , "D", 08, 0,"EMISSAO" },;
				{ "PRODUTO"     , "C", TamSX3("D1_COD")[1], 0,"PRODUTO" },;
                { "DESCR"       , "C", TamSX3("B1_DESC")[1],0,"DESCRICAO"},;
				{ "DT_PREV"     , "D", 08, 0,"PREVISTA" },;
				{ "DT_REAL"     , "D", 08, 0,"REALIZADA" },;
				{ "DIF_DIAS"    , "N", 12, 0,"DIFERENCA" },;
				{ "LEG"         , "C", 1,  0,"LEGENDA" },;
				{ "XX_RECNO"	, "N", 12, 0,"RECNO"}}					
	  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria os arquivos temporarios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa( { |lEnd| Fc030Procri() } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se todos os arquivos foram criados	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCont := 1 to IIF(cPaisLoc!="BRA",5,4)
		If(Select("cArq" + Str(nCont,1)) <= 0)
			Help("",1,"Fc030NOARQ") 
			cFilant := cFilBkp
			Return
		EndIf
	Next nCont
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe tela principal da consulta ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FWModeAccess("SA2",3) == "C"
		If MV_PAR10 == 1
			If  FindFunction("AdmSelecFil")
				AdmSelecFil("FIC030",10,.F.,@aSelFil,"SA2",(FWModeAccess("SA2",1) == "E"),(FWModeAccess("SA2",2) == "E"),cFilCorr)
			Else
				aSelFil := AdmGetFil(.F.,.F.,"SA2")
			Endif
		Else
			Aadd(aSelFil,cFilAnt)	// Se não seleciona filiais, carrega apenas a filial atual
		Endif
	Endif

	If Empty(aSelFil)
		If FWModeAccess("SA2",3) == "C"
			aSelFil := FWAllFilial(FWCompany("SA2"),FWUnitBusiness("SA2"),,.F.)
		Else
			Aadd(aSelFil,Xfilial("SA2"))
		EndIf
	Endif		
	FC030Mostr(lProc030a ,lProc030b,lProc030c,lProc030d,lProc030e,lProc030f)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga os arquivos temporarios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCont := 1 To Len(aTmpTables)
		If &(aTmpTables[nCont]) <> Nil
			&(aTmpTables[nCont]):Delete()
			&(aTmpTables[nCont]) := Nil
		EndIf
	Next nCont
	
	lProc030a := .F.  // Carregar dados de Titulos em aberto
	lProc030b := .F.  // Carregar dados de Titulos Pagos
	lProc030c := .F.  // Carregar dados de Pedidos e Produtos
	lProc030d := .F.  // Carregar dados de Faturamento
	lProc030e := .F.  // Carregar dados da Devolucao
	lProc030f := .F.  // Carregar dados da Entrega
	FC030QFil(2)
	cFilant := cFilBkp

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fC030Cria ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 15/01/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria estruturas dos arquivos de Trabalho                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fC030Cria()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nao tem                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fc030Cria(aCampos, nCont)

	Local cCpoUser  := ""
	
	If(nCont == 1)
	
		If(_oFINC0301 <> NIL)
			_oFINC0301:Delete()
			_oFINC0301 := NIL
		EndIf
		_oFINC0301 := FwTemporaryTable():New("cArq" + Str(nCont,1))
		_oFINC0301:SetFields(aCampos)
		
	ElseIf(nCont == 2)
	
		If(_oFINC0302 <> NIL)
			_oFINC0302:Delete()
			_oFINC0302 := NIL
	
		EndIf
		_oFINC0302 := FwTemporaryTable():New("cArq" + Str(nCont,1))
		_oFINC0302:SetFields(aCampos)
	
	ElseIf(nCont == 3)
	
		If(_oFINC0303 <> NIL)
			_oFINC0303:Delete()
			_oFINC0303 := NIL
	
		EndIf
		_oFINC0303 := FwTemporaryTable():New("cArq" + Str(nCont,1))
		_oFINC0303:SetFields(aCampos)
	
	ElseIf(nCont == 4)
	
		If(_oFINC0304 <> NIL)
			_oFINC0304:Delete()
			_oFINC0304 := NIL
		EndIf
		_oFINC0304 := FwTemporaryTable():New("cArq" + Str(nCont,1))
		_oFINC0304:SetFields(aCampos)
	
	ElseIf(nCont == 5)
	
		If(_oFINC0305 <> NIL)
			_oFINC0305:Delete()
			_oFINC0305 := NIL
	
		EndIf
		_oFINC0305 := FwTemporaryTable():New("cArq" + Str(nCont,1))
		_oFINC0305:SetFields(aCampos)
	
	ElseIf(nCont == 6)
	
		If(_oFINC0306 <> NIL)
			_oFINC0306:Delete()
			_oFINC0306 := NIL
		EndIf
	
		_oFINC0306 := FwTemporaryTable():New("cArq" + Str(nCont,1))
		_oFINC0306:SetFields(aCampos)
	
	ElseIf(nCont == 7)
	
		If(_oFINC0307 <> NIL)
			_oFINC0307:Delete()
			_oFINC0307 := NIL
		EndIf
		_oFINC0307 := FwTemporaryTable():New("cArq" + Str(nCont,1))
		_oFINC0307:SetFields(aCampos)
	
	Else
	
		If(_oFINC0308 <> NIL)
			_oFINC0308:Delete()
			_oFINC0308 := NIL
		EndIf
		_oFINC0308 := FwTemporaryTable():New("cArq" + Str(nCont,1))
		_oFINC0308:SetFields(aCampos)
	
	EndIf
	
	If(nCont == 1)
		
		_oFINC0301:AddIndex("1",{"DATAVENC"})
		_oFINC0301:Create()
		aAdd(aTmpTables, "_oFINC0301")
		
	ElseIf(nCont == 2)//Titulos a Pagar
	
		If(ExistBlock("Fc030Ind"))
			cCpoUser := ExecBlock("FC030Ind",.F.,.F.,{nCont,aCampos})
		EndIf
		If(!Empty(cCpoUser))
			_oFINC0302:AddIndex("1", Strtokarr2( cCpoUser, "+"))
		EndIf
		_oFINC0302:Create()
		aAdd(aTmpTables, "_oFINC0302")
		
	ElseIf(nCont == 3)//Pedidos de Compra
	
		_oFINC0303:AddIndex("1",{"NUMERO"})
		_oFINC0303:Create()
		aAdd(aTmpTables, "_oFINC0303")
		
	ElseIf(nCont == 4 )
	
		If(ExistBlock("FC030IND"))
			cCpoUser := ExecBlock("FC030Ind",.F.,.F.,{nCont,aCampos})
		EndIf
		If(!Empty(cCpoUser))
			_oFINC0304:AddIndex("1", Strtokarr2( cCpoUser, "+"))
		Else
			_oFINC0304:AddIndex("1", {"FILORIG","NUMERO"})
		EndIf
		_oFINC0304:Create()
		aAdd(aTmpTables, "_oFINC0304")
		
	ElseIf(nCont == 5)
	
		_oFINC0305:AddIndex("1",{"NUMERO"})
		_oFINC0305:Create()
		aAdd(aTmpTables, "_oFINC0305")
		
	ElseIf(cPaisLoc != "BRA" .And. nCont == 6)
	
		_oFINC0306:AddIndex("1",{"DTBAIXA","VENCTO"})
		_oFINC0306:Create()
		aAdd(aTmpTables, "_oFINC0306")
		
	ElseIf(nCont == 7)
	
		_oFINC0307:AddIndex("1",{"NUMERO"})
		_oFINC0307:Create()
		aAdd(aTmpTables, "_oFINC0307")
	
	ElseIf(nCont == 8)
	
		_oFINC0308:AddIndex("1",{"NOTA"})
		_oFINC0308:Create()
		aAdd(aTmpTables, "_oFINC0308")
		
	EndIf

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fC030Mostr³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 15/01/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra tela principal da consulta                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fC030Mostr()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nao tem                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FC030Mostr(lProc030a,lProc030b,lProc030c,lProc030d,lProc030e,lProc030f)
Local lPanelFin := IsPanelFin()
Local oDlg		:= Nil
Local cMoeda	:= ""
Local cPict		:= ""
Local cRetCGC 	:= RTrim(RetTitle("A2_CGC"))
Local aObjects	:= {},aPosObj :={}
Local aSize   	:= MsAdvSize(.f.)
Local aInfo   	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local oBtnNF	:= Nil
Local lC7Fiscori :=	SC7->(FieldPos("C7_FISCORI")) > 0
Local oNomCli	:= Nil
Local oNumCGC	:= Nil
Local oNumTel	:= Nil
Local cDesMoed1 := SuperGetMv('MV_SIMB1',.F.,"R$")

Private oLbx,oLbx1,oLbx2,oLbx3,oLbx4,oLbx5,oLbx6

cMoeda   	  := GetMv("MV_MCUSTO")
cMoeda   	  := SubStr(Getmv("MV_SIMB"+cMoeda)+Space(4),1,4)
lFc030Con	  := If(lFc030Con==Nil,ExistBlock("FC030CON"),lFc030Con)
cPict    	  := PesqPict("SA2","A2_CGC")

AADD(aObjects,{100,040,.T.,.F.,.F.})
AADD(aObjects,{100,100,.T.,.T.,.F.})
aPosObj:=MsObjSize(aInfo,aObjects)

DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]
oDlg:lMaximized := .T.

@ 001,aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] OF oDlg PIXEL

@ 004,008 SAY STR0044 						SIZE 021,7 OF oDlg PIXEL			 //"Codigo"
@ 004,136 SAY STR0045 						SIZE 016,7 OF oDlg PIXEL			 //"Loja"
@ 004,156 SAY STR0046 						SIZE 019,7 OF oDlg PIXEL			 //"Nome"
@ 023,008 SAY cRetCGC						SIZE 020,7 OF oDlg PIXEL			 //"(CGC,RIF,RUT,CUIT,...)"
@ 023,080 SAY STR0047 						SIZE 025,7 OF oDlg PIXEL			 //"Telefone"
@ 012,007 MSGET SA2->A2_COD   				SIZE 120,9 OF oDlg PIXEL When .F.
@ 012,135 MSGET SA2->A2_LOJA				SIZE 020,9 OF oDlg PIXEL When .F.
@ 012,155 MSGET oNomCli Var SA2->A2_NOME	SIZE 150,9 OF oDlg PIXEL When .F. 
@ 030,007 MSGET oNumCGC Var SA2->A2_CGC		SIZE 070,9 OF oDlg PIXEL When .F. 
@ 030,079 MSGET oNumTel Var SA2->A2_TEL		SIZE 060,9 OF oDlg PIXEL When .F. 

If !lPanelFin
	@ 012,315 BUTTON STR0048 SIZE 42,13 FONT oDlg:oFont ACTION oDlg:End() OF oDlg PIXEL 		 //"Sair"
	@ 028,315 BUTTON STR0049 SIZE 42,13 FONT oDlg:oFont ACTION FC030GRF(@lProc030a,@lProc030b) OF oDlg PIXEL 		 //"Financeiro"
Endif

cFolder1 := STR0050 //"Informacoes Gerais"
cFolder2 := STR0051 //"Titulos Em Aberto"
cFolder3 := STR0052 //"Titulos Pagos"
cFolder4 := STR0053 //"Pedidos de Compras"
cFolder5 := STR0054 //"Faturamento"
cFolder6 := STR0055 //"Produtos"
aFolder  := {cFolder1,cFolder2,cFolder3,cFolder4,cFolder5,cFolder6}
If cPaisLoc!="BRA"
	cFolder7 := STR0056 //"Carteira de Cheques"
	aAdd(aFolder,cFolder7)
Else
	cFolder7 := STR0138  //"Devolução"
	aAdd(aFolder,cFolder7)
Endif         
cFolder8 := STR0139 //"Entrega"
aAdd(aFolder,cFolder8)

oFolder030:=TFolder():New(aPosObj[2,1],aPosObj[2,2],aFolder,{},oDlg,,,, .T., .F.,aPosObj[2,4]-5,aPosObj[2,3]-55,)
oFolder030:bSetOption:={|nDest030| Fc030ChFol(nDest030,oFolder030:nOption,@lProc030a,@lProc030b,@lProc030c,@lProc030d,@lProc030e,@lProc030f,oLbx,oLbx1,oLbx2,oLbx3,oLbx4,oLbx5,oLbx6)}
oFolder030:aDialogs[1]:oFont :=oDlg:oFont
oFolder030:aDialogs[2]:oFont :=oDlg:oFont
oFolder030:aDialogs[3]:oFont :=oDlg:oFont
oFolder030:aDialogs[4]:oFont :=oDlg:oFont
oFolder030:aDialogs[5]:oFont :=oDlg:oFont
oFolder030:aDialogs[6]:oFont :=oDlg:oFont
If cPaisLoc!="BRA"
	oFolder030:aDialogs[7]:oFont :=oDlg:oFont
Else
	oFolder030:aDialogs[7]:oFont :=oDlg:oFont
Endif
oFolder030:aDialogs[8]:oFont :=oDlg:oFont

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informacoes do Folder - Inf.Gerais                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPosObj[1,1]+05,aPosObj[1,2]+005 SAY STR0057			    SIZE 55,9 OF oFolder030:aDialogs[1] PIXEL	COLOR CLR_BLUE	 //"Saldo Atual"
@ aPosObj[1,1]+20,aPosObj[1,2]+005 SAY STR0058+" "+cMoeda	SIZE 55,9 OF oFolder030:aDialogs[1] PIXEL	COLOR CLR_BLUE	 //"Maior Compra"
@ aPosObj[1,1]+35,aPosObj[1,2]+005 SAY STR0133+" "+cMoeda	SIZE 55,9 OF oFolder030:aDialogs[1] PIXEL	COLOR CLR_BLUE	 //"Maior Nota"
@ aPosObj[1,1]+50,aPosObj[1,2]+005 SAY STR0059+" "+cMoeda	SIZE 55,9 OF oFolder030:aDialogs[1] PIXEL	COLOR CLR_BLUE	 //"Maior Saldo"
@ aPosObj[1,1]+65,aPosObj[1,2]+005 SAY STR0060+" "+cMoeda	SIZE 60,9 OF oFolder030:aDialogs[1] PIXEL	COLOR CLR_BLUE	 //"Saldo Historico em"

@ aPosObj[1,1]+05,aPosObj[1,2]+150 SAY STR0061			SIZE 55,9 OF oFolder030:aDialogs[1] PIXEL	COLOR CLR_BLUE	 //"Primeira Compra"
@ aPosObj[1,1]+20,aPosObj[1,2]+150 SAY STR0062			SIZE 55,9 OF oFolder030:aDialogs[1] PIXEL	COLOR CLR_BLUE	 //"Ultima"
@ aPosObj[1,1]+35,aPosObj[1,2]+150 SAY STR0063			SIZE 55,9 OF oFolder030:aDialogs[1] PIXEL	COLOR CLR_BLUE	 //"Maior Atraso"
@ aPosObj[1,1]+03,aPosObj[1,2]+065 MSGET SA2->A2_SALDUP  			SIZE 60,9 OF oFolder030:aDialogs[1] PIXEL When .F. Picture Tm(SA2->A2_SALDUP,15,nCasas) HASBUTTON

@ aPosObj[1,1]+18,aPosObj[1,2]+065 MSGET SA2->A2_MCOMPRA 		SIZE 60,9 OF oFolder030:aDialogs[1] PIXEL When .F. Picture Tm(SA2->A2_MCOMPRA,15,nCasas) HASBUTTON
@ aPosObj[1,1]+33,aPosObj[1,2]+065 MSGET SA2->A2_MNOTA 			SIZE 60,9 OF oFolder030:aDialogs[1] PIXEL When .F. Picture Tm(SA2->A2_MNOTA,15,nCasas) HASBUTTON
@ aPosObj[1,1]+48,aPosObj[1,2]+065 MSGET SA2->A2_MSALDO  		SIZE 60,9 OF oFolder030:aDialogs[1] PIXEL When .F. Picture Tm(SA2->A2_MSALDO,15,nCasas)  HASBUTTON
@ aPosObj[1,1]+63,aPosObj[1,2]+065 MSGET SA2->A2_SALDUPM 		SIZE 60,9 OF oFolder030:aDialogs[1] PIXEL When .F. Picture Tm(SA2->A2_SALDUPM,15,nCasas) HASBUTTON

@ aPosObj[1,1]+03,aPosObj[1,2]+205 MSGET SA2->A2_PRICOM				SIZE 53,9 OF oFolder030:aDialogs[1] PIXEL When .F. HASBUTTON
@ aPosObj[1,1]+18,aPosObj[1,2]+205 MSGET SA2->A2_ULTCOM  			SIZE 53,9 OF oFolder030:aDialogs[1] PIXEL When .F. HASBUTTON	
@ aPosObj[1,1]+33,aPosObj[1,2]+205 MSGET SA2->A2_MATR     			SIZE 53,9 OF oFolder030:aDialogs[1] PIXEL When .F. Picture PesqPictQt("A2_MATR") HASBUTTON
                                                                                                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informacoes do Folder - Titulos Em Aberto                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("cArq1")
dbGoTop()
If cPaisLoc == "BRA"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para incluir campos no arquivo temporario de titulos em aberto.                          ³
	//³ Rdmake deve ter 3 etapas, estas, quando Ponto de Entrada passar como referencia o primeiro valor igual a: ³ 
	//³                                                                                                           ³ 
	//³ (1) - Etapa de Adicionar os campos novos no array de criação do arquivo de dados temporário               ³
	//³ (2) - Etapa de Abastecimento dos campos                                                                   ³
	//³ (3) - Etapa de Tratamento do objeto LISTBOX com os campos que deseja visualizar na aba de Tit Abertos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	If lF030TitAb  // Etapa 3  
		ExecBlock("F030TITABER",.F.,.F.,{3,aPosObj,STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018,STR0019,STR0120,STR0121,STR0122})
	Else	
		If FWModeAccess("SE2",1) == "E"		/* GESTAO - adiciona-se a filial de origem */
			@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx FIELDS cArq1->FILORIG,cArq1->PREFIXO,cArq1->NUMERO,cArq1->PARCELA,cArq1->TIPO,cArq1->EMISSAO,cArq1->DATAVENC,cArq1->NATUREZA, ;
				Transform(cArq1->SALDOPAGAR,PesqPict("SE2","E2_SALDO")),Transform(cArq1->ATRASO,"999999"),Transform(cArq1->VALORJUROS,PesqPict("SE2","E2_SALDO")),Transform(cArq1->VLR_IR,PesqPict("SE2","E2_SALDO")),;
				Transform(cArq1->VLR_ISS,PesqPict("SE2","E2_SALDO")),Transform(cArq1->VLR_INSS,PesqPict("SE2","E2_SALDO")),cArq1->NUMBCO,cArq1->HISTORICO,;
				Transform(cArq1->ACRESCIMO,PesqPict("SE2","E2_ACRESC")),Transform(cArq1->DECRESCIMO,PesqPict("SE2","E2_DECRESC")),;
				Transform(cArq1->VALORACES,PesqPict("SE2","E2_SALDO"));	
				HEADER SX3->(RetTitle("E2_FILORIG")),STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018,STR0019,STR0120,STR0121,STR0122,STR0160 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[2] PIXEL
		Else
			@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx FIELDS cArq1->PREFIXO,cArq1->NUMERO,cArq1->PARCELA,cArq1->TIPO,cArq1->EMISSAO,cArq1->DATAVENC,cArq1->NATUREZA, ;
				Transform(cArq1->SALDOPAGAR,PesqPict("SE2","E2_SALDO")),Transform(cArq1->ATRASO,"999999"),Transform(cArq1->VALORJUROS,PesqPict("SE2","E2_SALDO")),Transform(cArq1->VLR_IR,PesqPict("SE2","E2_SALDO")),;
				Transform(cArq1->VLR_ISS,PesqPict("SE2","E2_SALDO")),Transform(cArq1->VLR_INSS,PesqPict("SE2","E2_SALDO")),cArq1->NUMBCO,cArq1->HISTORICO,;
				Transform(cArq1->ACRESCIMO,PesqPict("SE2","E2_ACRESC")),Transform(cArq1->DECRESCIMO,PesqPict("SE2","E2_DECRESC")),;
				Transform(cArq1->VALORACES,PesqPict("SE2","E2_SALDO"));
				HEADER STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018,STR0019,STR0120,STR0121,STR0122,STR0160 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[2] PIXEL
		Endif
	Endif
Else
	If lF030TitAb  // Etapa 3  
		ExecBlock("F030TITABER",.F.,.F.,{3,aPosObj,STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017,STR0018,STR0019,STR0120,STR0121,STR0122})
	Else
		If FWModeAccess("SE2",1) == "E"		/* GESTAO - adiciona-se a filial de origem */
			@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx FIELDS cArq1->FILORIG,cArq1->PREFIXO,cArq1->NUMERO,cArq1->PARCELA,cArq1->TIPO,cArq1->EMISSAO,cArq1->DATAVENC,cArq1->NATUREZA, ;
			Transform(cArq1->SALDOPAGAR,PesqPict("SE2","E2_SALDO")),Transform(cArq1->ATRASO,"999999"),Transform(cArq1->VALORJUROS,PesqPict("SE2","E2_SALDO")),cArq1->NUMBCO,cArq1->HISTORICO ;
			HEADER SX3->(RetTitle("E2_FILORIG")),STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0019,STR0120 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[2] PIXEL
		Else
			@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx FIELDS cArq1->PREFIXO,cArq1->NUMERO,cArq1->PARCELA,cArq1->TIPO,cArq1->EMISSAO,cArq1->DATAVENC,cArq1->NATUREZA, ;
			Transform(cArq1->SALDOPAGAR,PesqPict("SE2","E2_SALDO")),Transform(cArq1->ATRASO,"999999"),Transform(cArq1->VALORJUROS,PesqPict("SE2","E2_SALDO")),cArq1->NUMBCO,cArq1->HISTORICO ;
			HEADER STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0019,STR0120 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[2] PIXEL
		Endif
	EndIf
EndIf
@ aPosObj[2,3]-84,aPosObj[2,2]+150 Say STR0064+": " + Transf(nTotal1,Tm(nTotal1,15,nCasas)) OF oFolder030:aDialogs[2] PIXEL //"Valor Total"
@ aPosObj[2,3]-84,aPosObj[2,2]+300 Say STR0065+": " + Str(nTitulos1,5) OF oFolder030:aDialogs[2] PIXEL //"Quantidade T¡tulos"
oFolder030:aDialogs[2]:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informacoes do Folder - Titulos Pagos                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("cArq2")
dbGoTop()

If cPaisLoc != "BRA"
	If lF030TitPg // Etapa 3  
		ExecBlock("F030TITPAGO",.F.,.F.,{3,aPosObj,STR0006,STR0007,STR0008,STR0010,STR0012,STR0021,STR0022,STR0116,STR0117,STR0118,STR0115,STR0023,STR0011,STR0014,STR0024,STR0025,STR0026,STR0027,STR0028,STR0019,STR0016,STR0017,STR0018})
	Else		
		If FWModeAccess("SE2",1) == "E"		/* GESTAO */	
			@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx1 FIELDS cArq2->FILORIG,cArq2->ORDPAGO,cArq2->PREFIXO,cArq2->NUMERO,cArq2->PARCELA,cArq2->TIPO,cArq2->EMISSAO,cArq2->NATUREZA,Transform(cArq2->VALORTIT,PesqPict("SE2","E2_SALDO")), ;
			Transform(cArq2->VALORPAGO,PesqPict("SE2","E2_SALDO")),cArq2->BAIXA,cArq2->VENCIMENTO,Transform(cArq2->ATRASO,"999999"),cArq2->BANCO,cArq2->AGENCIA,cArq2->CONTA,cArq2->HISTORICO,cArq2->MOTIVO,cArq2->NUMBCO ;
			HEADER SX3->(RetTitle("E2_FILORIG")),STR0020,STR0006,STR0007,STR0008,STR0009,STR0010,STR0012,STR0021,STR0022,STR0023,STR0011,STR0014,STR0024,STR0025,STR0026,STR0027,STR0028,STR0019 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[3] PIXEL
	 	Else	
			@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx1 FIELDS cArq2->ORDPAGO,cArq2->PREFIXO,cArq2->NUMERO,cArq2->PARCELA,cArq2->TIPO,cArq2->EMISSAO,cArq2->NATUREZA,Transform(cArq2->VALORTIT,PesqPict("SE2","E2_SALDO")), ;
			Transform(cArq2->VALORPAGO,PesqPict("SE2","E2_SALDO")),cArq2->BAIXA,cArq2->VENCIMENTO,Transform(cArq2->ATRASO,"999999"),cArq2->BANCO,cArq2->AGENCIA,cArq2->CONTA,cArq2->HISTORICO,cArq2->MOTIVO,cArq2->NUMBCO ;
			HEADER STR0020,STR0006,STR0007,STR0008,STR0009,STR0010,STR0012,STR0021,STR0022,STR0023,STR0011,STR0014,STR0024,STR0025,STR0026,STR0027,STR0028,STR0019 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[3] PIXEL
		Endif
	EndIf	
	@ aPosObj[2,3]-84,aPosObj[2,2]+150 Say STR0064+": " + Transf(nTotal2,Tm(nTotal2,15,nCasas)) OF oFolder030:aDialogs[3] PIXEL //"Valor Total"
	@ aPosObj[2,3]-84,aPosObj[2,2]+300 Say STR0065+": " + Str(nTitulos2,5) OF oFolder030:aDialogs[3] PIXEL //"Quantidade T¡tulos"
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para incluir campos no arquivo temporario de titulos em pagos.                           ³
	//³ Rdmake deve ter 3 etapas, estas, quando Ponto de Entrada passar como referencia o primeiro valor igual a: ³ 
	//³                                                                                                           ³ 
	//³ (1) - Etapa de Adicionar os campos novos no array de criação do arquivo de dados temporário               ³
	//³ (2) - Etapa de Abastecimento dos campos                                                                   ³
	//³ (3) - Etapa de Tratamento do objeto LISTBOX com os campos que deseja visualizar na aba de Tit Pagos       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lF030TitPg // Etapa 3  
		ExecBlock("F030TITPAGO",.F.,.F.,{3,aPosObj,STR0006,STR0007,STR0008,STR0010,STR0012,STR0021,STR0022,STR0022+" ("+cDesMoed1+")",STR0116,STR0117,STR0118,STR0115,STR0162,STR0023,STR0011,STR0014,STR0024,STR0025,STR0026,STR0027,STR0028,STR0019,STR0016,STR0017,STR0018})
	Else		
		If FWModeAccess("SE2",1) == "E"		/* GESTAO */
			@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx1 FIELDS cArq2->FILORIG,cArq2->PREFIXO,cArq2->NUMERO,cArq2->PARCELA,cArq2->TIPO,cArq2->EMISSAO,cArq2->NATUREZA,Transform(cArq2->VALORTIT,PesqPict("SE2","E2_SALDO")), ;
			Transform(cArq2->VALORPAGO,PesqPict("SE2","E2_SALDO")),Transform(cArq2->VALPAGTO1,PesqPict("SE2","E2_SALDO")),Transform(cArq2->JUROS,PesqPict("SE5","E5_VLJUROS")),Transform(cArq2->MULTA,PesqPict("SE5","E5_VLMULTA")),Transform(cArq2->DESCONTO,PesqPict("SE5","E5_VLDESCO")),;
			Transform(cArq2->VALORACES,PesqPict("SE2","E2_SALDO")),;	// VALOR ACESSÓRIO
			Transform(cArq2->TX_MOEDA,PesqPict("SE2","E2_TXMOEDA")),cArq2->MOEDA,cArq2->BAIXA,cArq2->VENCIMENTO,Transform(cArq2->ATRASO,"999999"),cArq2->BANCO,;
			cArq2->AGENCIA,cArq2->CONTA,cArq2->HISTORICO,cArq2->MOTIVO,cArq2->NUMBCO,;
			Transform(cArq2->VLR_IR,PesqPict("SE2","E2_SALDO")),Transform(cArq2->VLR_ISS,PesqPict("SE2","E2_SALDO")),Transform(cArq2->VLR_INSS,PesqPict("SE2","E2_SALDO"));
			HEADER SX3->(RetTitle("E2_FILORIG")),STR0006,STR0007,STR0008,STR0009,STR0010,STR0012,STR0021,STR0022,STR0022+" ("+cDesMoed1+")",STR0116,STR0117,STR0118,STR0160,STR0115,STR0162,STR0023,STR0011,STR0014,STR0024,STR0025,STR0026,STR0027,STR0028,STR0019,STR0016,STR0017,STR0018;
			SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[3] PIXEL
		Else	
			@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx1 FIELDS cArq2->PREFIXO,cArq2->NUMERO,cArq2->PARCELA,cArq2->TIPO,cArq2->EMISSAO,cArq2->NATUREZA,Transform(cArq2->VALORTIT,PesqPict("SE2","E2_SALDO")), ;
			Transform(cArq2->VALORPAGO,PesqPict("SE2","E2_SALDO")),Transform(cArq2->VALPAGTO1,PesqPict("SE2","E2_SALDO")),Transform(cArq2->JUROS,PesqPict("SE5","E5_VLJUROS")),Transform(cArq2->MULTA,PesqPict("SE5","E5_VLMULTA")),Transform(cArq2->DESCONTO,PesqPict("SE5","E5_VLDESCO")),;
			Transform(cArq2->VALORACES,PesqPict("SE2","E2_SALDO")),;	// VALOR ACESSÓRIO
			Transform(cArq2->TX_MOEDA,PesqPict("SE2","E2_TXMOEDA")),cArq2->MOEDA,cArq2->BAIXA,cArq2->VENCIMENTO,Transform(cArq2->ATRASO,"999999"),cArq2->BANCO,;
			cArq2->AGENCIA,cArq2->CONTA,cArq2->HISTORICO,cArq2->MOTIVO,cArq2->NUMBCO,;
			Transform(cArq2->VLR_IR,PesqPict("SE2","E2_SALDO")),Transform(cArq2->VLR_ISS,PesqPict("SE2","E2_SALDO")),Transform(cArq2->VLR_INSS,PesqPict("SE2","E2_SALDO"));
			HEADER STR0006,STR0007,STR0008,STR0009,STR0010,STR0012,STR0021,STR0022,STR0022+" ("+cDesMoed1+")",STR0116,STR0117,STR0118,STR0160,STR0115,STR0162,STR0023,STR0011,STR0014,STR0024,STR0025,STR0026,STR0027,STR0028,STR0019,STR0016,STR0017,STR0018;
			SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[3] PIXEL 
		Endif
	EndIf	
	@ aPosObj[2,3]-84,aPosObj[2,2]+150 Say STR0064+" ("+cDesMoed1+"): " + Transf(nTotal2,Tm(nTotal2,15,nCasas)) OF oFolder030:aDialogs[3] PIXEL //"Valor Total"
	@ aPosObj[2,3]-84,aPosObj[2,2]+300 Say STR0065+": " + Str(nTitulos2,5) OF oFolder030:aDialogs[3] PIXEL //"Quantidade T¡tulos"
EndIf	

oFolder030:aDialogs[3]:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informacoes do Folder - Pedidos de Compra                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("cArq3")
dbGoTop()            
If lF030TitCom // Etapa 3  
	ExecBlock("F030TITCOM",.F.,.F.,{3,aPosObj,STR0007,STR0010,STR0135,STR0029})
Else
	If lC7Fiscori .And. FWModeAccess("SC7",1) == "E"		/* GESTAO */	
		@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx2 FIELDS cArq3->FILORIG,cArq3->NUMERO,cArq3->EMISSAO,cArq3->ENTREGA,Transform(cArq3->VALORITEM,"@E 999,999,999,999,999,999.99") ;
		HEADER SX3->(RetTitle("C7_FISCORI")),STR0007,STR0010,STR0135,STR0029 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[4] PIXEL 
		
	Else	
		@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx2 FIELDS cArq3->NUMERO,cArq3->EMISSAO,cArq3->ENTREGA,Transform(cArq3->VALORITEM,"@E 999,999,999,999,999,999.99") ;
		HEADER STR0007,STR0010,STR0135,STR0029 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[4] PIXEL
	Endif
EndIf
@ aPosObj[2,3]-84,aPosObj[2,2]+150 Say STR0066+": " + Str(nTitulos3,5) OF oFolder030:aDialogs[4] PIXEL  //"Notas"
@ aPosObj[2,3]-84,aPosObj[2,2]+300 Say STR0067+": " + Transf(nTotal3,Tm(nTotal3,15,nCasas)) OF oFolder030:aDialogs[4] PIXEL //"Total Geral"
If lC7Fiscori
	DEFINE SBUTTON oBtnNF FROM aPosObj[2,3]-86,aPosObj[2,2]+001 TYPE 15 ACTION ( F030PCVis(cArq3->FILORIG,cArq3->NUMERO) ) ENABLE OF oFolder030:aDialogs[4] Pixel
Else
	DEFINE SBUTTON oBtnNF FROM aPosObj[2,3]-86,aPosObj[2,2]+001 TYPE 15 ACTION ( F030PCVis(,cArq3->NUMERO) ) ENABLE OF oFolder030:aDialogs[4] Pixel
Endif
oFolder030:aDialogs[4]:Refresh()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informacoes do Folder - Faturamento                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("cArq4")
dbGoTop()
If cPaisLoc == "BRA"  
	If lF030TitFat // Etapa 3  
		ExecBlock("F030TITFAT",.F.,.F.,{3,aPosObj,STR0007,STR0010,STR0030,STR0031})
	Else
		If FWModeAccess("SF1",1) == "E"		/* GESTAO */
			@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx3 FIELDS cArq4->FILORIG,cArq4->NUMERO,cArq4->EMISSAO,Transform(cArq4->VALORNOTA,PesqPict("SF1","F1_VALMERC")),cArq4->DUPLICATA ;
			HEADER SX3->(RetTitle("E2_FILORIG")),STR0007,STR0010,STR0030,STR0031 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[5] PIXEL
		Else
			@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx3 FIELDS cArq4->NUMERO,cArq4->EMISSAO,Transform(cArq4->VALORNOTA,PesqPict("SF1","F1_VALMERC")),cArq4->DUPLICATA ;
			HEADER STR0007,STR0010,STR0030,STR0031 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[5] PIXEL
		Endif 
	EndIf
Else  
	If lF030TitFat // Etapa 3  
		ExecBlock("F030TITFAT",.F.,.F.,{3,aPosObj,STR0007,STR0010,STR0030,STR0031,STR0041,STR0114})
	Else
		If FWModeAccess("SF1",1) == "E"		/* GESTAO */
			@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx3 FIELDS cArq4->FILORIG,cArq4->NUMERO,cArq4->EMISSAO,Transform(cArq4->VALORNOTA,PesqPict("SF1","F1_VALMERC")),cArq4->DUPLICATA,;
			cArq4->MOEDA,Transform(cArq4->TAXA,PesqPict("SF1","F1_TXMOEDA")) HEADER SX3->(RetTitle("E2_FILORIG")),STR0007,STR0010,STR0030,STR0031,STR0041,STR0114 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[5] PIXEL
		Else
			@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx3 FIELDS cArq4->NUMERO,cArq4->EMISSAO,Transform(cArq4->VALORNOTA,PesqPict("SF1","F1_VALMERC")),cArq4->DUPLICATA,;
			cArq4->MOEDA, Transform(cArq4->TAXA,PesqPict("SF1","F1_TXMOEDA")) HEADER STR0007,STR0010,STR0030,STR0031,STR0041,STR0114 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[5] PIXEL
		Endif 
	EndIf
EndIf
@ aPosObj[2,3]-84,aPosObj[2,2]+150 Say STR0066+": " + Str(nTitulos4,5) OF oFolder030:aDialogs[5] PIXEL //"Notas"
@ aPosObj[2,3]-84,aPosObj[2,2]+300 Say STR0067+": " + Transf(nVlrGerNF,Tm(nVlrGerNF,15,nCasas)) OF oFolder030:aDialogs[5] PIXEL //"Total Geral"
DEFINE SBUTTON oBtnNF FROM aPosObj[2,3]-86,aPosObj[2,2]+001 TYPE 15 ACTION ( F030VISUAL("SF1",CARQ4->XX_RECNO,0) ) ENABLE OF oFolder030:aDialogs[5] Pixel
oFolder030:aDialogs[5]:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informacoes do Folder - Produtos                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("cArq5")
dbGoTop()
If lC7Fiscori .And. FWModeAccess("SC7",1) == "E"		/* GESTAO */
	@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx4 FIELDS cArq5->FILORIG,cArq5->NUMERO,cArq5->EMISSAO,cArq5->PRODUTO,cArq5->DESCRI,cArq5->UM,cArq5->SEGUM,Transform(cArq5->QUANT,PesqPictQt("C7_QUANT",15)),Transform(cArq5->QTSEGUM,PesqPictQt("C7_QUANT",15)),Transform(cArq5->PRECO,PesqPict("SC7","C7_TOTAL")),cArq5->CONDPAG ;
	HEADER  SX3->(RetTitle("C7_FISCORI")),STR0007,STR0010,STR0032,STR0132,STR0033,STR0034,STR0035,STR0036,STR0037,STR0038 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[6] PIXEL 
	oFolder030:aDialogs[6]:Refresh()
Else
	@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx4 FIELDS cArq5->NUMERO,cArq5->EMISSAO,cArq5->PRODUTO,cArq5->DESCRI,cArq5->UM,cArq5->SEGUM,Transform(cArq5->QUANT,PesqPictQt("C7_QUANT",15)),Transform(cArq5->QTSEGUM,PesqPictQt("C7_QUANT",15)),Transform(cArq5->PRECO,PesqPict("SC7","C7_TOTAL")),cArq5->CONDPAG ;
	HEADER STR0007,STR0010,STR0032,STR0132,STR0033,STR0034,STR0035,STR0036,STR0037,STR0038 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[6] PIXEL 
	oFolder030:aDialogs[6]:Refresh()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informacoes do Folder - Cart.Cheques                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc != "BRA"
	dbSelectArea("cArq6")
	dbGoTop()
	If FWModeAccess("SE2",1) == "E"		/* GESTAO */
		@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx5 FIELDS cArq6->FILORIG,cArq6->SITUACION,cArq6->NUMERO,cArq6->EMISSAO,cArq6->VENCTO,cArq6->MONEDA,Transform(cArq6->VLMOED1,PesqPict("SE2","E2_SALDO")),cArq6->ORDPAGO,cArq6->BANCO,cArq6->AGENCIA,cArq6->CUENTA,cArq6->DTBAIXA ;
		HEADER SX3->(RetTitle("E2_FILORIG")),STR0039,STR0007,STR0010,STR0011,STR0041,STR0042+GetMV("MV_MOEDAP1"),STR0020,STR0024,STR0025,STR0026,STR0023 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[7] PIXEL
	Else
		@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx5 FIELDS cArq6->SITUACION,cArq6->NUMERO,cArq6->EMISSAO,cArq6->VENCTO,cArq6->MONEDA,Transform(cArq6->VLMOED1,PesqPict("SE2","E2_SALDO")),cArq6->ORDPAGO,cArq6->BANCO,cArq6->AGENCIA,cArq6->CUENTA,cArq6->DTBAIXA ;
		HEADER STR0039,STR0007,STR0010,STR0011,STR0041,STR0042+GetMV("MV_MOEDAP1"),STR0020,STR0024,STR0025,STR0026,STR0023 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[7] PIXEL
	Endif 
	@ aPosObj[2,3]-84,aPosObj[2,2]+010 Say STR0068+": " + Str(aTotal6[2],5) 							OF oFolder030:aDialogs[7] PIXEL	//"Cheques Em Aberto"
	@ aPosObj[2,3]-84,aPosObj[2,2]+080 Say STR0069+": " + Transf(aTotal6[1],Tm(aTotal6[1],15,nCasas))	OF oFolder030:aDialogs[7] PIXEL 	//"Total Chqs Em Aberto"
	@ aPosObj[2,3]-84,aPosObj[2,2]+180 Say STR0070+": " + Str(aTotal6[4],5) 							OF oFolder030:aDialogs[7] PIXEL 	//"Cheques dep."
	@ aPosObj[2,3]-84,aPosObj[2,2]+250 Say STR0071+": " + Transf(aTotal6[3],Tm(aTotal6[3],15,nCasas)) OF oFolder030:aDialogs[7] PIXEL 	//"Total Chqs dep."
	oFolder030:aDialogs[7]:Refresh()
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informacoes do Folder - Devolucao                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("cArq7")
	dbGoTop()
	If FWModeAccess("SF2",1) == "E"		/* GESTAO */
		@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx5 FIELDS cArq7->FILORIG,cArq7->NUMERO,cArq7->EMISSAO,Transform(cArq7->VALORNOTA,PesqPict("SF2","F2_VALMERC")) ;
				HEADER SX3->(RetTitle("E2_FILORIG")),STR0007,STR0010,STR0030 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[7] PIXEL 
	Else
		@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx5 FIELDS cArq7->NUMERO,cArq7->EMISSAO,Transform(cArq7->VALORNOTA,PesqPict("SF2","F2_VALMERC")) ;
				HEADER STR0007,STR0010,STR0030 SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[7] PIXEL 
	Endif
	@ aPosObj[2,3]-84,aPosObj[2,2]+150 Say STR0066+": " + Str(nTitulos7,5) OF oFolder030:aDialogs[7] PIXEL //"Notas"
	@ aPosObj[2,3]-84,aPosObj[2,2]+300 Say STR0067+": " + Transf(nVlrGerNF5,Tm(nVlrGerNF5,15,nCasas)) OF oFolder030:aDialogs[7] PIXEL //"Total Geral"
	DEFINE SBUTTON oBtnNF FROM aPosObj[2,3]-86,aPosObj[2,2]+001 TYPE 15 ACTION ( F030VISUAL("SF2",CARQ7->XX_RECNO,0) ) ENABLE OF oFolder030:aDialogs[7] Pixel
	oFolder030:aDialogs[7]:Refresh()
EndIf

dbSelectArea("cArq8")
dbGoTop()
If FWModeAccess("SF1",1) == "E"		/* GESTAO */
	@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx6 ;
        FIELDS If(cArq8->Leg=='3',oYel,If(cArq8->Leg=='1',oRed,oGre)),cArq8->FILORIG,;      		
                cArq8->NOTA,cArq8->EMISNF,cArq8->PEDIDO,cArq8->EMISPD,cArq8->PRODUTO,cArq8->DESCR,cArq8->DT_PREV,cArq8->DT_REAL,cArq8->DIF_DIAS,"" ;
		HEADER "",SX3->(RetTitle("E2_FILORIG")),STR0066,STR0010,"Pedido",STR0010,STR0032,STR0132,STR0142,STR0143,STR0144,"" ;
		SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[8] PIXEL 
Else
	@ aPosObj[2,1]-47,aPosObj[2,2]-2 LISTBOX oLbx6 ;
        FIELDS If(cArq8->Leg=='3',oYel,If(cArq8->Leg=='1',oRed,oGre)),;
                cArq8->NOTA,cArq8->EMISNF,cArq8->PEDIDO,cArq8->EMISPD,cArq8->PRODUTO,cArq8->DESCR,cArq8->DT_PREV,cArq8->DT_REAL,cArq8->DIF_DIAS,"" ;
		HEADER "",STR0140,STR0010,STR0141,STR0010,STR0032,STR0132,STR0142,STR0143,STR0144,"" ; //Nota,"Emissao","Pedido","Emissao","Produto","Descrição","Dt Prevista","Dt Realizada","Diferença Dias"
		SIZE aPosObj[2,4]-9,aPosObj[2,3]-86 OF oFolder030:aDialogs[8] PIXEL
Endif
@ aPosObj[2,3]-84,aPosObj[2,2]+150 Say STR0145+": " + Str(nTitulos8,5) OF oFolder030:aDialogs[8] PIXEL  // "Itens"
@ aPosObj[2,3]-84,aPosObj[2,2]+300 Say STR0146+": " + Str(nTot1,10) OF oFolder030:aDialogs[8] PIXEL // "Entrega no Prazo"
@ aPosObj[2,3]-84,aPosObj[2,2]+500 Say STR0147+": " + Str(nTot2,10) OF oFolder030:aDialogs[8] PIXEL //"Entrega Atrasada"
@ aPosObj[2,3]-85,aPosObj[2,2]+600 BUTTON STR0148 SIZE 030,09 ACTION LjLeg() OF oFolder030:aDialogs[8] PIXEL //"Legenda"
oFolder030:aDialogs[8]:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informacoes do PE FC030CON - Usa Botao ao lado do "Sair"     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lFC030Con )
	@ 028,160 BUTTON STR0072 SIZE 42,13 FONT oDlg:oFont ACTION ExecBlock("FC030CON",.F.,.F.) OF oDlg  PIXEL //"Cons. Especif."
EndIf

If lPanelFin  //Chamado pelo Painel Financeiro			
	aButtonTxt := {}	
	AADD(aButtonTxt,{STR0049,STR0049,{||FC030GRF(@lProc030a,@lProc030b)}}) // Financeiro
	ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,,{||oDlg:End()},,aButtonTxt)
Else
	ACTIVATE MSDIALOG oDlg
Endif	

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fC030Gera ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 15/01/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera registros dos arquivos de trabalho                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fC030Gera()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nao tem                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fc030Gera(nProcess)

Local nRec		:= 0
Local nTotAbat	:= 0
Local nAtraso	:= 0
Local nPago		:= 0
Local nPago1	:= 0
Local dData		:= CTOD("//")
Local dVencto	:= CTOD("//")
Local nAtrBai	:= 0
Local cMotBx	:= ""
Local cBanco	:= ""
Local cAgencia	:= ""
Local cConta	:= ""
Local cHistor	:= ""
Local cDescr	:= ""
Local nPos		:= 0
Local aMotBx	:= ReadMotBx()
Local aStru		:= {}
Local cQuery	:= ""
Local cOrder	:= ""
Local cFiltro	:= ""
Local nCotac	:= 0
Local nTxMOeda	:= 0
Local cCheque	:= ""
Local nI		:= 0
Local cOrdPg	:=""
Local lFC030Ord	:= ExistBlock("FC030ORD")
Local cCpoDisp	:= ""
Local cOrdCustom := ""
Local lF030Filt	:= ExistBlock("F030FILT")
Local lC7Fiscori	:=	SC7->(FieldPos("C7_FISCORI")) > 0

// GESTAO - inicio */
Local nPosAlias	:= 0
Local cFilAtual	:= cFilAnt
Local cLayoutSM0 := FWSM0Layout()
Local lGestao	 := Substr(cLayoutSM0,1,1) $ "E|U"

// TOTALMENTE COMPARTILHADO
Local lSE2Comp	:= .F.
Local lSE5Comp	:= .F.
Local lSC7Comp	:= .F.
Local lSF1Comp	:= .F.
Local nSaldoPG	:= 0

Local cTipoNot	:= ""

Local nSC7TamFil := Len(Alltrim(xFilial("SC7")))
Local nSD1TamFil := Len(Alltrim(xFilial("SD1")))

If cPaisLoc!="BRA"
	aTotal6:= {0.00,0,0.00,0}
Endif

If lGestao
	If Substr(cLayoutSM0,1,1) == "E"
		lSE2Comp := FWModeAccess("SE2",1) == "C"
		lSE5Comp := FWModeAccess("SE5",1) == "C"
		lSC7Comp := FWModeAccess("SC7",1) == "C"
		lSF1Comp := FWModeAccess("SF1",1) == "C"
		lSF2Comp := FWModeAccess("SF2",1) == "C"
	Else
		lSE2Comp := FWModeAccess("SE2",2) == "C"
		lSE5Comp := FWModeAccess("SE5",2) == "C"
		lSC7Comp := FWModeAccess("SC7",2) == "C"
		lSF1Comp := FWModeAccess("SF1",2) == "C"
		lSF2Comp := FWModeAccess("SF2",2) == "C"
	EndIf
Else
	lSE2Comp := FWModeAccess("SE2",3) == "C"
	lSE5Comp := FWModeAccess("SE5",3) == "C"
	lSC7Comp := FWModeAccess("SC7",3) == "C"
	lSF1Comp := FWModeAccess("SF1",3) == "C"
	lSF2Comp := FWModeAccess("SF2",3) == "C"
EndIF

/* GESTAO - fim
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Geracao de registro de titulos em aberto                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nProcess == 1
	IncProc(STR0109 + IIF(cPaisLoc != "BRA",STR0110," ")) //"Selecionando Dados - T¡tulos em Aberto"###" / Cheques"

	SomaAbat("","","","P")
	aStru := {}
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("E2_FILIAL")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_FILORIG")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_PREFIXO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_NUM")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_PARCELA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_TIPO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_FORNECE")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_LOJA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_EMISSAO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_VENCTO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_VENCREA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_BAIXA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_VALOR")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_SALDO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_FATURA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_NATUREZ")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_NUMBCO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_MOEDA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_VALJUR")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_PORCJUR")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_TXMOEDA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	If cPaisLoc == "BRA"
		dbSeek("E2_IRRF")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E2_ISS")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E2_INSS")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	Else
		dbSeek("E2_ORDPAGO")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E2_BCOCHQ")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E2_AGECHQ")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E2_CTACHQ")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	Endif                                                                               
	dbSeek("E2_HIST")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_ACRESC")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_DECRESC")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_SDACRES")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_SDDECRE")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		
	dbSelectArea("SE2")
	dbSetOrder(6)
	cQuery := ""
	aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
	cCpoDisp := SubStr(cQuery,2)
	cQuery := "SELECT "+SubStr(cQuery,2)+" FROM " + RetSqlName("SE2")
	/*
	GESTAO - inicio */
	If !lSE2Comp
		nPosAlias := FC030QFil(1,"SE2")
		cQuery += " WHERE E2_FILIAL " + aTmpFil[nPosAlias,2]
	Else
		cQuery += " WHERE E2_FILIAL = '" + Space(TamSx3("E2_FILIAL")[1]) + "'"
	EndIf
	/* GESTAO - fim
	*/
	cQuery += " AND E2_FORNECE = '"+SA2->A2_COD+"'"
	cQuery += " AND E2_LOJA = '"+SA2->A2_LOJA+"'"
	cQuery += " AND E2_EMISSAO   between '" + DTOS(mv_par01)  + "' AND '" + DTOS(mv_par02) + "'"
	cQuery += " AND E2_VENCREA between '" + DTOS(mv_par03)  + "' AND '" + DTOS(mv_par04) + "'"
	cQuery += " AND E2_TIPO NOT IN "+FormatIn(MVABATIM,";") 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para filtrar pelo MSFIL em caso de ³
	//³ arquivo compartilhado.                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If (ExistBlock("FO30FILT"))    
		cQuery += ExecBlock("FO30FILT",.F.,.F.)
	Endif                    

	If mv_par05 == 2
		cQuery += " AND E2_TIPO <> '"+MVPROVIS+"'"
	EndIf
	If mv_par06 == 2
		cQuery += " AND E2_FATURA IN('"+Space(Len(E2_FATURA))+"','NOTFAT')"
	Endif
	
	cQuery += " AND D_E_L_E_T_ = ' '"
	cOrder := SqlOrder(IndexKey())
	If lFC030Ord                  
		cOrdCustom := ExecBlock("FC030ORD",.F.,.F.,{cCpoDisp,cOrder,nProcess})
		If ValType(cOrdCustom) == "C"
			cQuery += " ORDER BY " + cOrdCustom
		EndIf
	Else
		cQuery += " ORDER BY " + cOrder			
	EndIf
	cQuery := ChangeQuery(cQuery)
	
	If lF030Filt
		
		cOldQuery := cQuery
		cQuery := ExecBlock( "F030FILT", .f., .f., { cQuery, nProcess, cCpoDisp } )
	
		If Empty(cQuery)  
			cQuery := cOldQuery         	
		EndIf
		
	EndIf
	
	dbSelectArea("SE2")
	dbCloseArea()
	dbSelectArea("SA2")
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE2', .T., .T.)
	For ni := 1 to Len(aStru)
		If aStru[ni,2] != 'C'
			TCSetField('SE2', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		Endif
	Next

	dbSelectArea("SE2")
	dbGoTop()

	nRec:= SE2->(RecNo())
	nTotal1 := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionamento do SE5 neste ponto que servira para   ³
	//³pesquisa de descarte de registros geradores de       ³
	//³desdobramento                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	dbSelectArea("SE5")
  	SE5->(dbSetOrder(7))	//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
	
	cFilAtual := cFilAnt
	While !SE2->(Eof()) .And. IIF(lF030FILT,SE2->E2_FORNECE+SE2->E2_LOJA==SA2->A2_COD+SA2->A2_LOJA,;
			SE2->E2_FORNECE+SE2->E2_LOJA==SA2->A2_COD+SA2->A2_LOJA)
		
		cFilAnt := SE2->E2_FILORIG		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nao lˆ outros fornecedores, abatimentos e provis¢rios.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE2->E2_VENCREA < mv_par03 .or. SE2->E2_VENCREA > mv_par04 .or. ;
			SE2->E2_TIPO $ MVABATIM
			SE2->(dbSkip())
			Loop
		EndIF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se considera Titulos Provisorios.            	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	SE2->E2_TIPO $ MVPROVIS .and. mv_par05 == 2
			dbSkip()
			Loop
		Endif
	
		//Nao considera titulos faturados se mv_par06 == 2
		IF !Empty(SE2->E2_FATURA) .and. Substr(SE2->E2_FATURA,1,6) != "NOTFAT" .and. mv_par06 == 2
			dbSkip( )
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pesquisa de descarte de registros geradores de       ³
		//³desdobramento                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE5->(dbSeek(xFilial("SE5") + SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
			If AllTrim(SE5->E5_TIPODOC) == "BA" .AND. AllTrim(SE5->E5_MOTBX) == "DSD"
				SE2->(dbSkip())
				Loop
			Endif
		Endif		
	
		nSavRec := SE2->(RECNO())
	
		IF SE2->E2_VENCREA>=mv_par03 .and. SE2->E2_VENCREA<=mv_par04 .And.;
				SE2->E2_EMISSAO>=mv_par01 .and. SE2->E2_EMISSAO<=mv_par02
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava cheques (para versao localizada) num arquivo espec. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cPaisLoc!="BRA") .And. SE2->E2_TIPO$IIF(Type('MVCHEQUES')=='C',MVCHEQUES,MVCHEQUE)
	            dbSelectArea("cArq6")
				RecLock("cArq6",.T.)
				If SE2->E2_SALDO>0.AND.EMPTY(SE2->E2_BAIXA)
					aTotal6[1]+=	Moeda(SE2->E2_SALDO,1,"P")
					aTotal6[2]+=	1
					Replace SITUACION With "No Dep."
				Else
					aTotal6[3]+=	Moeda(SE2->E2_VALOR,1,"P")
					aTotal6[4]+=	1
					Replace SITUACION With "Dep."
				Endif
				Replace FILORIG	With SE2->E2_FILORIG		/* GESTAO */
				Replace NUMERO	With SE2->E2_NUM
				Replace EMISSAO	With SE2->E2_EMISSAO
				Replace VENCTO	With SE2->E2_VENCREA
				Replace VALOR	With IIF(SE2->E2_SALDO==0,SE2->E2_VALOR,SE2->E2_SALDO)
				Replace MONEDA	With SE2->E2_MOEDA
				Replace VLMOED1	With IIF(SE2->E2_SALDO==0,MOEDA(SE2->E2_VALOR,1,"P"),MOEDA(SE2->E2_SALDO,1,"P"))
				Replace ORDPAGO	With SE2->E2_ORDPAGO
				Replace BANCO	With SE2->E2_BCOCHQ
				Replace AGENCIA	With SE2->E2_AGECHQ
				Replace CUENTA	With SE2->E2_CTACHQ
				Replace DTBAIXA	With SE2->E2_BAIXA
				MsUnLock()
				dbSelectArea("SE2")
				dbSkip()
				Loop
			Endif
	
			If SE2->E2_SALDO <= 0
				SE2->(DbSkip())
				Loop
			Endif
			nTotAbat:=0
			If cPaisLoc <> "EQU" .Or. (cPaisLoc$"EQU" .And. SE2->E2_SALDO==SE2->E2_VALOR)
				nTotAbat:=SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,,SE2->E2_FORNECE,SE2->E2_LOJA)
			EndIf
			// Tratamento dos VALORES ACESSORIOS - CONTAS A PAGAR - (SE2)
			nVa	:= 0
			If __lExisFKD 
				//     FValAcess(cPrefixo			,cNum			,cParcela		,cTipo		 ,cCliFor		 ,cLoja		  , cNatureza		, lBaixados				,cCodVa	,cCarteira	,dDtBaixa		,aValAces,nMoedaTit,nMoedaBco,nTxMoeda)
			    nVa := FValAcess( SE2->E2_PREFIXO	,SE2->E2_NUM	,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA, SE2->E2_NATUREZA,!Empty(SE2->E2_BAIXA)	,		,"P"		,SE2->E2_BAIXA	,		 ,SE2->E2_MOEDA )
			EndIf

			nJuros  := 0
			nJuros  := fa080Juros()
			nAtraso := dDataBase - fC030Venc()
			nAtraso := If(nAtraso>0,nAtraso,0)
	
			// Grava registros no arquivo temporario
			dbSelectArea("cArq1")
			RecLock("cArq1",.T.)
			Replace FILORIG		With SE2->E2_FILORIG		/* GESTAO */
			Replace PREFIXO		With SE2->E2_PREFIXO
			Replace NUMERO		With SE2->E2_NUM
			Replace PARCELA		With SE2->E2_PARCELA
			Replace TIPO		With SE2->E2_TIPO
			Replace EMISSAO		With SE2->E2_EMISSAO
			Replace NATUREZA	With SE2->E2_NATUREZ
			
			//Caso mv_par09 seja igual a Dt de Movimento entao devo enviar a data de vencto do titulo para ser a data base para a pesquisa da moeda.
			nSaldoPG := xMoeda(SE2->(E2_SDACRES + E2_SALDO - E2_SDDECRE) - nTotAbat + nVA,SE2->E2_MOEDA,1,Iif(mv_par09==1,SE2->E2_VENCREA,Nil),,Iif(mv_par09==1,SE2->E2_TXMOEDA,0))

			// A partir de 08/04/2016 passa a ser exibido com o sinal de menos (-). Ver FAQS - Financeiro
			If SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
				nSaldoPG *= (-1)
			EndIf
 		   	
			// Atualiza o total no rodapé do Browser - STR0064 "Valor total"
			nTotal1+=nSaldoPG
			
			Replace SALDOPAGAR   With  nSaldoPG  
			Replace DATAVENC     With  Fc030Venc()
			Replace ATRASO       With  nAtraso
			Replace VALORJUROS   With  nJuros
			Replace ACRESCIMO    With  SE2->E2_SDACRES
			Replace DECRESCIMO   With  SE2->E2_SDDECRE

			If cPaisLoc == "BRA"	// Sergio Fuzinaka - 20.08.01
				Replace VLR_IR	  With  SE2->E2_IRRF
				Replace VLR_ISS	  With  SE2->E2_ISS
				Replace VLR_INSS  With  SE2->E2_INSS
				Replace VALORACES With  nVa 
			Endif
			Replace NUMBCO		 With  SE2->E2_NUMBCO
			Replace HISTORICO    With  SE2->E2_HIST
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para incluir campos no arquivo temporario de titulos em aberto.                          ³
			//³ Rdmake deve ter 3 etapas, estas, quando Ponto de Entrada passar como referencia o primeiro valor igual a: ³ 
			//³                                                                                                           ³ 
			//³ (1) - Etapa de Adicionar os campos novos no array de criação do arquivo de dados temporário               ³
			//³ (2) - Etapa de Abastecimento dos campos                                                                   ³
			//³ (3) - Etapa de Tratamento do objeto LISTBOX com os campos que deseja visualizar na aba de Tit Abertos     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lF030TitAb  // Etapa 2  
				ExecBlock("F030TITABER",.F.,.F.,{2})
			Endif       	
			MsUnLock()
		EndIF
	
		dbSelectArea("SE2")
		dbGoTo(nSavRec)
		dbSkip()

	EndDO
	
	cFilAnt := cFilAtual	/* GESTAO */
	dbSelectArea("SE2")
	dbCloseArea()
	ChKFile("SE2")

	dbSelectArea("cArq1")
	dbGoTop()
	nTitulos1 := RecCount()
	If cPaisLoc != "BRA"
		dbSelectArea("cArq6")
		dbGoTop()
		nTitulos6 := RecCount()
	Endif
	dbSelectArea("SE2")
	dbSetOrder(1)
Endif

	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Geracao de registro de titulos PAGOS                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nProcess == 2
	IncProc(STR0111) //"Selecionando Dados - T¡tulos Pagos"

	aStru := {}
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("E2_FILIAL")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	/* GESTAO */
	dbSeek("E2_FILORIG")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	/*-*/
	dbSeek("E2_PREFIXO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_NUM")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_PARCELA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_TIPO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_FORNECE")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_LOJA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_EMISSAO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_VENCTO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_VENCREA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_BAIXA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_VALOR")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_SALDO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_FATURA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_NATUREZ")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_NUMBCO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_MOEDA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_VALJUR")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_PORCJUR")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E2_TXMOEDA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E5_SEQ")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E5_DATA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E5_RECPAG")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E5_TIPO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E5_BANCO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E5_AGENCIA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E5_CONTA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E5_NUMCHEQ")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E5_NATUREZ")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E5_ORDREC")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	If cPaisLoc $ "MEX|BRA"
		dbSeek("E5_MOEDA")	
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E5_TXMOEDA")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})    		
	EndIf
	dbSeek("E5_VALOR")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E5_HISTOR")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E5_MOTBX")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("E5_VLMOED2")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	If cPaisLoc == "BRA"
		dbSeek("E2_IRRF")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E2_ISS")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E2_INSS")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E5_VLJUROS")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E5_VLMULTA")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("E5_VLDESCO")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	Else
		dbSeek("E2_ORDPAGO")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	Endif
	dbSelectArea("SE2")
	dbSetOrder(6)
	cQuery := ""
	aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
	cCpoDisp := SubStr(cQuery,2)
	cQuery := "SELECT "+SubStr(cQuery,2)
	cQuery += " FROM "+RetSqlName("SE2")+" SE2,"
	cQuery +=         RetSqlName("SE5")+" SE5 "

	If !lSE2Comp
		nPosAlias := FC030QFil(1,"SE2")
		cQuery += "WHERE SE2.E2_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
	Else
		cQuery += "WHERE SE2.E2_FILIAL = '" + Space(TamSx3("E2_FILIAL")[1]) + "' AND "
	EndIf

	cQuery += "SE2.E2_FORNECE='" + SA2->A2_COD    +"' AND "
	cQuery += "SE2.E2_LOJA='"    + SA2->A2_LOJA   +"' AND "
	cQuery += "SE2.E2_EMISSAO>='"+ Dtos(mv_par01) +"' AND "
	cQuery += "SE2.E2_EMISSAO<='"+ Dtos(mv_par02) +"' AND "
	cQuery += "SE2.E2_VENCREA>='"+ Dtos(mv_par03) +"' AND "
	cQuery += "SE2.E2_VENCREA<='"+ Dtos(mv_par04) +"' AND "

	// Ponto de entrada para filtrar pelo MSFIL em caso de Arquivo compartilhado.  Titulos Pagos
	If (ExistBlock("FO30FLTP"))    
		cQuery += +ExecBlock("FO30FLTP",.F.,.F.)
	Endif                    

	If mv_par05 == 2
		cTipoNot +=   MVPROVIS + "|"
	EndIf					
	If mv_par06 == 2
		cQuery += " SE2.E2_FATURA IN('"+Space(Len(SE2->E2_FATURA))+"','NOTFAT') AND "
	Endif

	cTipoNot += MVABATIM +"|"+ MVPAGANT +"|"+ MVRECANT +"|"+ MV_CRNEG +"|"+ MV_CPNEG

	cTipoNot := F030TipoIN(cTipoNot)

	cQuery += "SE2.E2_TIPO NOT IN " + cTipoNot +" AND "
	cQuery += "SE2.E2_VALOR != SE2.E2_SALDO AND "
	cQuery += "SE2.D_E_L_E_T_=' ' AND "

	If !lSE5Comp
		nPosAlias := FC030QFil(1,"SE5")
		cQuery += "SE5.E5_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
	Else
		cQuery += "SE5.E5_FILIAL = '" + Space(TamSx3("E5_FILIAL")[1]) + "' AND "
	EndIf

	cQuery += "SE5.E5_PREFIXO=SE2.E2_PREFIXO AND "
	cQuery += "SE5.E5_NUMERO=SE2.E2_NUM AND "
	cQuery += "SE5.E5_PARCELA=SE2.E2_PARCELA AND "
	cQuery += "SE5.E5_TIPO=SE2.E2_TIPO AND "
	cQuery += "SE5.E5_CLIFOR=SE2.E2_FORNECE AND "
	cQuery += "SE5.E5_LOJA=SE2.E2_LOJA AND "
	cQuery += "SE5.E5_FILORIG=SE2.E2_FILORIG AND "
	cQuery += "SE5.E5_RECPAG='P' AND "
	cQuery += "SE5.E5_SITUACA!='C' AND "
	cQuery += "SE5.E5_TIPODOC IN ('BA','VL','CP') AND "	
	cQuery += "SE5.D_E_L_E_T_=' ' AND NOT EXISTS ("
	cQuery += "SELECT A.E5_NUMERO "
	cQuery += "FROM "+RetSqlName("SE5")+" A "
	cQuery += "WHERE "
	/*
	GESTAO - inicio */
	If !lSE5Comp
		nPosAlias := FC030QFil(1,"SE5")
		cQuery += " A.E5_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
	Else
		cQuery += " A.E5_FILIAL = '" + Space(TamSx3("E5_FILIAL")[1]) + "' AND "
	EndIf
	/* GESTAO - fim 
	*/
	cQuery += "A.E5_PREFIXO=SE5.E5_PREFIXO AND "
	cQuery += "A.E5_NUMERO=SE5.E5_NUMERO AND "
	cQuery += "A.E5_PARCELA=SE5.E5_PARCELA AND "
	cQuery += "A.E5_TIPO=SE5.E5_TIPO AND "
	cQuery += "A.E5_CLIFOR=SE5.E5_CLIFOR AND "
	cQuery += "A.E5_LOJA=SE5.E5_LOJA AND "
	cQuery += "A.E5_SEQ=SE5.E5_SEQ AND "
	cQuery += "A.E5_TIPODOC='ES' AND "
	cQuery += "A.E5_RECPAG!='P' AND "
	cQuery += "A.E5_DATA<='"+DtoS(dDataBase)+"' AND "
	cQuery += "A.D_E_L_E_T_=' ')"
	cOrder := SqlOrder(IndexKey())
	If lFC030Ord                  
		cOrdCustom := ExecBlock("FC030ORD",.F.,.F.,{cCpoDisp,cOrder,nProcess})
		If ValType(cOrdCustom) == "C"
			cQuery += " ORDER BY " + cOrdCustom
		EndIf
	Else
		cQuery += " ORDER BY " + cOrder			
	EndIf			
	cQuery := ChangeQuery(cQuery)     
	
	If lF030Filt
		
		cOldQuery := cQuery
		cQuery := ExecBlock( "F030FILT", .f., .f., { cQuery, nProcess, cCpoDisp } )
	
		If Empty(cQuery)  
			cQuery := cOldQuery         	
		EndIf
	
	EndIf

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRBPG', .T., .T.)
	For ni := 1 to Len(aStru)
		If aStru[ni,2] != 'C'
			TCSetField('TRBPG', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		Endif
	Next

	DbGotop()
	
	nTotal2 := 0	
	nTitulos2 := 0         

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionamento do SE5 neste ponto que servira para   ³
	//³pesquisa de descarte de registros geradores de       ³
	//³desdobramento                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE5")
	SE5->(dbSetOrder(7))	//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somente refaz os filtros abaixo se nao eh topconnect ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Do While TRBPG->(!EoF())
		If cPaisLoc!="BRA" .And. TRBPG->E2_TIPO$IIF(Type('MVCHEQUES')=='C',MVCHEQUES,MVCHEQUE)
			TRBPG->(dbSkip())
			Loop
		EndIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pesquisa de descarte de registros geradores de       ³
		//³desdobramento                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE5->(dbSeek(xFilial("SE5") + TRBPG->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
			If AllTrim(SE5->E5_TIPODOC) == "BA" .AND. AllTrim(SE5->E5_MOTBX) == "DSD"
				TRBPG->(dbSkip())
				Loop
			Endif
		Endif

		// Tratamento dos VALORES ACESSORIOS - CONTAS A PAGAR - (SE5)
		nVa := 0
		If __lExisFKD 
			cChaveTit := xFilial("SE5", TRBPG->E2_FILORIG ) + "|" + TRBPG->E2_PREFIXO + "|" + TRBPG->E2_NUM + "|" + TRBPG->E2_PARCELA + "|" + TRBPG->E2_TIPO + "|" + TRBPG->E2_FORNECE + "|" + TRBPG->E2_LOJA
			cChaveFK7 := FINGRVFK7("SE2", cChaveTit)
			DbSelectArea("FK2")
			FK2->(DbSetOrder(2))
			If(FK2->(DbSeek(xFilial("FK2")+cChaveFK7)))
				While FK2->(!EOF()) .AND. FK2->FK2_IDDOC == cChaveFK7
				
					nVA += FxLoadFK6("FK2",FK2->FK2_IDFK2,"VA")[1][2]
					
					FK2->(DbSkip())
				EndDo
			EndIf
		EndIf			

		nPago   := 0
		nPago1  := 0
		nCotac  := 0
		nTxMoeda := 0
		dData   := TRBPG->E5_DATA
		dVencto := TRBPG->E2_VENCREA
		nAtrBai := TRBPG->E5_DATA - TRBPG->E2_VENCREA
		If Dow(TRBPG->E2_VENCTO)=1 .or. Dow(TRBPG->E2_VENCTO) = 7
			If TRBPG->E5_DATA > TRBPG->E2_VENCREA
				nAtrBai := TRBPG->E5_DATA - TRBPG->E2_VENCTO
			Else
				nAtrBai := TRBPG->E5_DATA - TRBPG->E2_VENCREA
			Endif
		Endif

		cMotBx   := Space(09)
		cBanco   := TRBPG->E5_BANCO
		cAgencia := TRBPG->E5_AGENCIA
		cConta   := TRBPG->E5_CONTA
		cCheque	:= TRBPG->E5_NUMCHEQ
		cNaturez := TRBPG->E5_NATUREZ
		If cPaisloc <> "BRA"
			cOrdPg:= TRBPG->E5_ORDREC
		EndIf
		
		nPos := Ascan(aMotBx, {|x| Substr(x,1,3) == Upper(TRBPG->E5_MOTBX) })
		If nPos > 0
			cMotBx := Substr(aMotBx[nPos],07,09)
		ElseIf TRBPG->E5_MOTBX == "CEC"
			cMotBx := STR0073 //"COMP CART"
		EndIf
		
		If cPaisLoc == "MEX"
			nPago += xMoeda(TRBPG->E5_VALOR,Val(TRBPG->E5_MOEDA),1,,,Iif(mv_par09==1,TRBPG->E5_TXMOEDA,0))
		Else
			If TRBPG->E5_TIPO $ MV_CPNEG
				nPago -= TRBPG->E5_VLMOED2
			Else
				nPago += TRBPG->E5_VLMOED2
			EndIf
		EndIf				

		If cPaisLoc == "BRA"
			nPago1 += xMoeda(TRBPG->E5_VALOR,Val(TRBPG->E5_MOEDA),1,,,TRBPG->E5_TXMOEDA)
		Endif

		cHistor := TRBPG->E5_HISTOR
		If cPaisLoc == "BRA" .And. TRBPG->E5_TXMOEDA > 0
			nTxMoeda += TRBPG->E5_TXMOEDA
		Else
			nTxMoeda += TRBPG->E5_VALOR/TRBPG->E5_VLMOED2
		Endif
		nCotac++

		If nPago != 0 .Or. nCotac <> 0 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava registros no arquivo temporario                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If cPaisLoc <> "BRA" .And. FindFunction("F030RetTit")
				nPago -= F030RetTit(cOrdPg, TRBPG->E2_PREFIXO, TRBPG->E2_NUM, TRBPG->E2_PARCELA)
			EndIf

			RecLock("cArq2",.T.)
			If cPaisLoc!="BRA" 
				cArq2->ORDPAGO := cOrdPg
			EndIf
			cArq2->FILORIG		:= TRBPG->E2_FILORIG					
			cArq2->PREFIXO		:= TRBPG->E2_PREFIXO
			cArq2->NUMERO		:= TRBPG->E2_NUM
			cArq2->PARCELA		:= TRBPG->E2_PARCELA
			cArq2->TIPO			:= TRBPG->E2_TIPO
			cArq2->EMISSAO		:= TRBPG->E2_EMISSAO
			cArq2->NATUREZA		:= cNaturez
			If cPaisLoc == "BRA"
				cArq2->VALORTIT		:= TRBPG->E2_VALOR
			Else
				cArq2->VALORTIT		:= xMoeda(TRBPG->E2_VALOR,TRBPG->E2_MOEDA,1,,,Iif(mv_par09==1,TRBPG->E2_TXMOEDA,0))
			Endif
			cArq2->VALORPAGO	:= nPago
			cArq2->TX_MOEDA		:= nTxMoeda/nCotac //(Media das taxas da moeda no dia)
			cArq2->BAIXA		:= dData
			cArq2->VENCIMENTO	:= dVencto
			cArq2->ATRASO		:= nAtrBai
			cArq2->BANCO		:= cBanco
			cArq2->AGENCIA		:= cAgencia
			cArq2->CONTA		:= cConta
			cArq2->HISTORICO	:= cHistor
			cArq2->MOTIVO		:= cMotBx
			cArq2->NUMBCO		:= cCheque
			If cPaisLoc == "BRA"	// Sergio Fuzinaka - 20.08.01
				cArq2->VLR_IR	:= TRBPG->E2_IRRF
				cArq2->VLR_ISS	:= TRBPG->E2_ISS
				cArq2->VLR_INSS	:= TRBPG->E2_INSS
				cArq2->JUROS	:= TRBPG->E5_VLJUROS
				cArq2->MULTA	:= TRBPG->E5_VLMULTA
				cArq2->DESCONTO	:= TRBPG->E5_VLDESCO
				cArq2->VALORACES:= nVa
				cArq2->VALPAGTO1:= nPago1
				cArq2->MOEDA    := TRBPG->E5_MOEDA
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para incluir campos no arquivo temporario de titulos pagos.                              ³
			//³ Rdmake deve ter 3 etapas, estas, quando Ponto de Entrada passar como referencia o primeiro valor igual a: ³ 
			//³                                                                                                           ³ 
			//³ (1) - Etapa de Adicionar os campos novos no array de criação do arquivo de dados temporário               ³
			//³ (2) - Etapa de Abastecimento dos campos                                                                   ³
			//³ (3) - Etapa de Tratamento do objeto LISTBOX com os campos que deseja visualizar na aba de Tit Pagos       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lF030TitPg // Etapa 2  
				ExecBlock("F030TITPAGO",.F.,.F.,{2})
			Endif       	
			cArq2->(MsUnlock())
			If cPaisLoc == "BRA"
				nTotal2+=nPago1
			Else
				nTotal2+=nPago
			Endif
		EndIf
		
		cTitAnt := TRBPG->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)

		TRBPG->(dbSkip())
		
		If TRBPG->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) <> cTitAnt
			nTitulos2++
		EndIf	

	EndDo                      
	TRBPG->(dbCloseArea())
	dbSelectArea("SE2")

	dbSelectArea("SE2")
	cFilAnt := cFilAtual
	dbSelectArea("SE2")
	dbCloseArea()
	ChKFile("SE2")

	dbSelectArea("cArq2")
	dbGoTop()
	dbSelectArea("SE2")
	dbSetOrder(1)
	dbSelectArea("SE5")
	dbSetOrder(1)
Endif		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Geracao de registro de pedidos colocados                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nProcess == 3
	IncProc(STR0112) //"Selecionando Dados - Pedidos Colocados / Produtos"

	aStru := {}
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("C7_FILIAL")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	
	If lC7Fiscori
		dbSeek("C7_FISCORI")		/* GESTAO */
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	Endif
		
	dbSeek("C7_FORNECE")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_LOJA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_NUM")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_TOTAL")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_PRODUTO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_DESCRI")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_QUJE")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_EMISSAO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_DATPRF") 
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_UM")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_SEGUM")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_QUANT")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_QTSEGUM")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_PRECO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_COND")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_VLDESC")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_RESIDUO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})			

	dbSelectArea("SC7")
	dbSetOrder(3)
	cQuery := ""
	aEval(aStru,{|x| cQuery += "," + AllTrim(x[1])})
	cCpoDisp := SubStr(cQuery,2)
	cQuery := "SELECT "+SubStr(cQuery,2)+" FROM " + RetSqlName("SC7") 
	/*
	GESTAO - inicio */			
				
	If !lSC7Comp
		nPosAlias := FC030QFil(1,"SC7")
		cQuery += "WHERE C7_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
	Else
		cQuery += "WHERE C7_FILIAL = '" + Space(TamSx3("C7_FILIAL")[1]) + "' AND "
	EndIf
					
	/* GESTAO - fim
	*/
				
	cQuery += " C7_FORNECE = '"+SA2->A2_COD+"'"
	cQuery += " AND C7_LOJA = '"+SA2->A2_LOJA+"'"
	cQuery += " AND C7_EMISSAO  between '" + DTOS(mv_par01)  + "' AND '" + DTOS(mv_par02) + "'"
	If mv_par07 = 2  //Apenas pedidos em aberto
		cQuery += " AND (C7_QUANT - C7_QUJE) > 0 AND C7_RESIDUO = ' ' "
	Endif

	cQuery += " AND D_E_L_E_T_ <> '*' "
	cOrder := SqlOrder(IndexKey())
	cQuery += " ORDER BY " + cOrder
	cQuery := ChangeQuery(cQuery) 
	
	If lF030Filt
		
		cOldQuery := cQuery
		cQuery := ExecBlock( "F030FILT", .f., .f., { cQuery, nProcess, cCpoDisp } )
	
		If Empty(cQuery)  
			cQuery := cOldQuery         	
		EndIf
	
	EndIf
	
	dbSelectArea("SC7")
	dbCloseArea()
	dbSelectArea("SA2")
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SC7', .T., .T.)
	For ni := 1 to Len(aStru)
		If aStru[ni,2] != 'C'
			TCSetField('SC7', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		Endif
	Next
	
	dbSelectArea("SC7")
	dbGotop()

	nTotal3 := 0	
	
	While !Eof() .And. IIF(lF030FILT,SC7->C7_FORNECE+C7_LOJA == SA2->A2_COD+SA2->A2_LOJA,;
			SC7->C7_FORNECE+C7_LOJA == SA2->A2_COD+SA2->A2_LOJA )

		If mv_par07 == 2
			If (SC7->C7_QUANT - SC7->C7_QUJE) == 0 .Or. !Empty(SC7->C7_RESIDUO)
				dbSkip()
				Loop
			EndIf
		EndIf
	
		IF SC7->C7_EMISSAO >= mv_par01 .And. SC7->C7_EMISSAO <= mv_par02
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava registros no arquivo temporario - Pedidos              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("cArq3")
			If MSSeek(SC7->C7_NUM)
				RecLock("cArq3",.F.)
				VALORITEM += SC7->(C7_TOTAL-C7_VLDESC)
			Else
				RecLock("cArq3",.T.)
				
				If lC7Fiscori
					Replace FILORIG		With SC7->C7_FISCORI
				Endif	
				
				Replace NUMERO		With SC7->C7_NUM
				Replace EMISSAO		With SC7->C7_EMISSAO
				Replace ENTREGA		With SC7->C7_DATPRF 
				Replace VALORITEM	With VALORITEM+SC7->(C7_TOTAL-C7_VLDESC)
			Endif       
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para incluir campos no arquivo temporario de titulos pagos.                              ³
			//³ Rdmake deve ter 3 etapas, estas, quando Ponto de Entrada passar como referencia o primeiro valor igual a: ³ 
			//³ (1) - Etapa de Adicionar os campos novos no array de criação do arquivo de dados temporário               ³
			//³ (2) - Etapa de Abastecimento dos campos                                                                   ³
			//³ (3) - Etapa de Tratamento do objeto LISTBOX com os campos que deseja visualizar na aba de Tit Pagos       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lF030TitCom // Etapa 2  
				ExecBlock("F030TITCOM",.F.,.F.,{2})
			Endif  
			MsUnlock()			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava registros no arquivo temporario - Produtos             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("cArq5")
			RecLock("cArq5",.T.)
			
			If lC7Fiscori
				Replace  FILORIG     With  SC7->C7_FISCORI
			Endif
			
			Replace  NUMERO      With  SC7->C7_NUM
			Replace  EMISSAO     With  SC7->C7_EMISSAO
			Replace  PRODUTO     With  SC7->C7_PRODUTO
			Replace  DESCRI      With  SC7->C7_DESCRI			
			Replace  UM          With  SC7->C7_UM
			Replace  SEGUM       With  SC7->C7_SEGUM
			Replace  QUANT       With  SC7->C7_QUANT
			Replace  QTSEGUM     With  SC7->C7_QTSEGUM
			Replace  PRECO       With  SC7->C7_PRECO
			Replace  CONDPAG	 With  SC7->C7_COND
	
			MsUnlock()
			nTotal3 += SC7->(C7_TOTAL-C7_VLDESC)
		Endif
		dbSelectArea("SC7")
		dbSkip()
	EndDO

	dbSelectArea("SC7")
	dbCloseArea()
	ChKFile("SC7")

	dbSelectArea("cArq3")
	dbGoTop()
	nTitulos3 := RecCount()
	dbSelectArea("cArq5")
	dbGoTop()
	nTitulos5 := RecCount()
	dbSelectArea("SC7")
	dbSetOrder(1)
Endif	


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Geracao de registro de faturamento                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nProcess == 4
	IncProc(STR0113) //"Selecionando Dados - Faturamento"
	cFiltro := SF1->( dbFilter() )
	aArea   := SF1->( GetArea() )

	aStru := {}
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("F1_FILIAL")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_FORNECE")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_LOJA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_EMISSAO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_TIPO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_VALMERC")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_FRETE")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_VALIPI")			
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_ICMSRET")			
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})			
	dbSeek("F1_DESPESA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_DESCONT")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_DOC")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_DUPL")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	If cPaisLoc <> "BRA"
		dbSeek("F1_MOEDA")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		dbSeek("F1_TXMOEDA")
		aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	EndIf
	dbSelectArea("SF1")
	dbSetOrder(2)

	cOrder := SqlOrder(IndexKey())
	cQuery := ""
	aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
	cCpoDisp := SubStr(cQuery,2)
	If FieldPos("F1_CANCEL") > 0
		cQuery += ",F1_CANCEL"
	Endif
	cQuery := "SELECT "+SubStr(cQuery,2)+",R_E_C_N_O_ SF1RECNO FROM " + RetSqlName("SF1") 
	/*
	GESTAO - inicio */			

	If !lSF1Comp
		nPosAlias := FC030QFil(1,"SF1")
		cQuery += "WHERE F1_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
	Else
		cQuery += "WHERE F1_FILIAL = '" + Space(TamSx3("F1_FILIAL")[1]) + "' AND "
	EndIf
	
	
	/* GESTAO - fim
	*/
	cQuery += " F1_FORNECE = '"+SA2->A2_COD+"'"
	cQuery += " AND F1_LOJA = '"+SA2->A2_LOJA+"'"
	cQuery += " AND F1_EMISSAO  between '" + DTOS(mv_par01)  + "' AND '" + DTOS(mv_par02) + "'"
	cQuery += " AND F1_ESPECIE NOT IN('RCN')"
	cQuery += " AND F1_TIPO NOT IN ('B','D') "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY " + cOrder
	cQuery := ChangeQuery(cQuery)
	
	If lF030Filt			   

		cOldQuery := cQuery
		cQuery := ExecBlock( "F030FILT", .f., .f., { cQuery, nProcess, cCpoDisp } )
	
		If Empty(cQuery)  
			cQuery := cOldQuery         	
		EndIf         	
	EndIf
	
	dbSelectArea("SF1")
	dbCloseArea()
	dbSelectArea("SA2")
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SF1', .T., .T.)
	For ni := 1 to Len(aStru)
		If aStru[ni,2] != 'C'
			TCSetField('SF1', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		Endif
	Next

	dbSelectArea("SF1")
	dbGoTop()

	nVlrGerNF := 0	

	While !Eof() .And. IIF(lF030FILT,SF1->F1_FORNECE+F1_LOJA == SA2->A2_COD+SA2->A2_LOJA,;
			SF1->F1_FORNECE+F1_LOJA == SA2->A2_COD+SA2->A2_LOJA)

		IF SF1->F1_EMISSAO >= mv_par01 .And. SF1->F1_EMISSAO <= mv_par02 .And. !(SF1->F1_TIPO $ "BD")
			nTotNota:=F1_VALMERC+F1_FRETE+F1_VALIPI+F1_ICMSRET+F1_DESPESA-F1_DESCONT
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Notas Canceladas   --  SHELL                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			#IFDEF SHELL
				IF F1_CANCEL == "S"
					dbSkip()
					Loop
				EndIf
			#ENDIF
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava registros no arquivo temporario                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("cArq4")
			RecLock("cArq4",.T.)
			Replace  FILORIG	With SF1->F1_FILIAL
			Replace  NUMERO		With SF1->F1_DOC
			Replace  EMISSAO	With SF1->F1_EMISSAO
			Replace  VALORNOTA	With nTotNota
			Replace  DUPLICATA	With SF1->F1_DUPL
			Replace  XX_RECNO   With  SF1->SF1RECNO

			If cPaisLoc <> "BRA"
				Replace MOEDA With SF1->F1_MOEDA
				Replace TAXA  With SF1->F1_TXMOEDA 				
			EndIf                                  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para incluir campos no arquivo temporario de titulos pagos.                              ³
			//³ Rdmake deve ter 3 etapas, estas, quando Ponto de Entrada passar como referencia o primeiro valor igual a: ³ 
			//³ (1) - Etapa de Adicionar os campos novos no array de criação do arquivo de dados temporário               ³
			//³ (2) - Etapa de Abastecimento dos campos                                                                   ³
			//³ (3) - Etapa de Tratamento do objeto LISTBOX com os campos que deseja visualizar na aba de Tit Pagos       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lF030TitFat // Etapa 2  
				ExecBlock("F030TITFAT",.F.,.F.,{2})
			Endif 
			MsUnlock()
			If cPaisLoc == "BRA"
				nVlrGerNF += nTotNota
			Else                      
				nVlrGerNF += Iif(SF1->F1_MOEDA==1,nTotNota,xMoeda(nTotNota,SF1->F1_MOEDA,1,SF1->F1_EMISSAO,MsDecimais(1),Iif(mv_par09==1,SF1->F1_TXMOEDA,0)))
			EndIf
		EndIF
		dbSelectArea("SF1")
		dbSkip()
	EndDO

	dbSelectArea("SF1")
	dbCloseArea()
	ChKFile("SF1")

	dbSelectArea("cArq4")
	dbGoTop()
	nTitulos4 := RecCount()
	dbSelectArea("SF1")
	RestArea(aArea)
	Set Filter to &(cFiltro)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Geracao de registro de devolucao                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nProcess == 5
	IncProc("Selecionando Dados - Devolução") 
	cFiltro := SF2->( dbFilter() )
	aArea   := SF2->( GetArea() )

	aStru := {}
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("F2_FILIAL")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F2_CLIENTE")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F2_LOJA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F2_EMISSAO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F2_TIPO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F2_VALMERC")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F2_FRETE")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F2_VALIPI")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F2_DESPESA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F2_DESCONT")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F2_DOC")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F2_DUPL")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	
	dbSelectArea("SF2")
	dbSetOrder(2)

	cOrder := SqlOrder(IndexKey())
	cQuery := ""
	aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
	cCpoDisp := SubStr(cQuery,2)
	cQuery := "SELECT "+SubStr(cQuery,2)+",R_E_C_N_O_ SF2RECNO FROM " + RetSqlName("SF2")  
	/*
	GESTAO - inicio */
		
	If !lSF2Comp
		nPosAlias := FC030QFil(1,"SF2")
		cQuery += "WHERE F2_FILIAL " + aTmpFil[nPosAlias,2] + " AND "
	Else
		cQuery += "WHERE F2_FILIAL = '" + Space(TamSx3("F2_FILIAL")[1]) + "' AND "
	EndIf
	
	/* GESTAO - fim
	*/
	cQuery += " F2_CLIENTE = '"+SA2->A2_COD+"'"
	cQuery += " AND F2_LOJA = '"+SA2->A2_LOJA+"'"
	cQuery += " AND F2_EMISSAO  between '" + DTOS(mv_par01)  + "' AND '" + DTOS(mv_par02) + "'"
	//cQuery += " AND F1_ESPECIE NOT IN('RCN')"
	cQuery += " AND F2_TIPO IN ('D') "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY " + cOrder
	cQuery := ChangeQuery(cQuery)
		
	If lF030Filt
		
		cOldQuery := cQuery
		cQuery := ExecBlock( "F030FILT", .f., .f., { cQuery, nProcess, cCpoDisp } )
	
		If Empty(cQuery)  
			cQuery := cOldQuery         	
		EndIf
	
	EndIf
	
	dbSelectArea("SF2")
	dbCloseArea()
	dbSelectArea("SA2")
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SF2', .T., .T.)
	For ni := 1 to Len(aStru)
		If aStru[ni,2] != 'C'
			TCSetField('SF2', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		Endif
	Next

	dbSelectArea("SF2")
	dbGoTop()
	
	nVlrGerNF5 := 0	

	While !Eof() .And. IIF(lF030FILT,SF2->F2_CLIENTE+F2_LOJA == SA2->A2_COD+SA2->A2_LOJA,;
			SF2->F2_CLIENTE+F2_LOJA == SA2->A2_COD+SA2->A2_LOJA)

		IF SF2->F2_EMISSAO >= mv_par01 .And. SF2->F2_EMISSAO <= mv_par02 .And. SF2->F2_TIPO $ "D"
			nTotNota:=F2_VALMERC+F2_FRETE+F2_VALIPI+F2_DESPESA-F2_DESCONT
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava registros no arquivo temporario                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("cArq7")
			RecLock("cArq7",.T.)
			Replace FILORIG		With SF2->F2_FILIAL
			Replace NUMERO		With SF2->F2_DOC
			Replace EMISSAO		With SF2->F2_EMISSAO
			Replace VALORNOTA	With nTotNota
			Replace XX_RECNO    With SF2->SF2RECNO

			MsUnlock()

			nVlrGerNF5 += nTotNota
		EndIF
		dbSelectArea("SF2")
		dbSkip()
	EndDO

	dbSelectArea("SF2")
	dbCloseArea()
	ChKFile("SF2")

	dbSelectArea("cArq7")
	dbGoTop()
	nTitulos7 := RecCount()
	dbSelectArea("SF2")
	RestArea(aArea)
	Set Filter to &(cFiltro)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Geracao de registro de devolucao                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nProcess == 6
	IncProc("Selecionando Dados - Entrega") 
	cFiltro := SF1->( dbFilter() )
	aArea   := SF1->( GetArea() )

	aStru := {}
	dbSelectArea("SX3")
	dbSetOrder(2)
	dbSeek("F1_FILIAL")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_FORNECE")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_LOJA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_EMISSAO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_TIPO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_VALMERC")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_FRETE")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_VALIPI")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_DESPESA")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_DESCONT")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_DOC")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("F1_DUPL")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("D1_PEDIDO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("D1_ITEMPC")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("D1_COD")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_DATPRF")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("C7_EMISSAO")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	dbSeek("D1_DTDIGIT")
	aadd(aStru ,{AllTrim(SX3->X3_CAMPO),SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
	
	dbSelectArea("SF1")
	dbSetOrder(2)

	cOrder := SqlOrder(IndexKey())
	cQuery := ""
	aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
	cCpoDisp := SubStr(cQuery,2)
	
	cQuery := "SELECT "+SubStr(cQuery,2)+",SF1.R_E_C_N_O_ SF1RECNO FROM " + RetSqlName("SF1") + " SF1 " 
	cQuery += " LEFT JOIN " + RetSqlName("SD1") + " SD1 ON "
	cQuery += " SD1.D1_FILIAL   = SF1.F1_FILIAL  AND "
	cQuery += " SD1.D1_FORNECE  = SF1.F1_FORNECE AND "
	cQuery += " SD1.D1_LOJA     = SF1.F1_LOJA    AND "
	cQuery += " SD1.D1_DOC      = SF1.F1_DOC     AND "
	cQuery += " SD1.D_E_L_E_T_ <> '*'
	cQuery += " LEFT  JOIN " +RetSqlName("SC7") + " SC7 ON "

	IF !EMPTY(nSC7TamFil) .AND. !EMPTY(nSD1TamFil)
		IF nSC7TamFil <> nSD1TamFil
			cQuery += " SUBSTRING(SC7.C7_FILIAL,1," + ALLTRIM(STR(MIN(nSC7TamFil,nSD1TamFil))) + ") = "
			cQuery += " SUBSTRING(SD1.D1_FILIAL,1," + ALLTRIM(STR(MIN(nSC7TamFil,nSD1TamFil))) + ") AND "
		ELSE
			cQuery += " SC7.C7_FILIAL = SD1.D1_FILIAL AND "
		ENDIF
	ENDIF
	
	cQuery += " SC7.C7_NUM = SD1.D1_PEDIDO AND "
	cQuery += " SC7.C7_ITEM = SD1.D1_ITEMPC AND "
	cQuery += " SC7.D_E_L_E_T_ = ' ' "

	nPosAlias := FC030QFil(1,"SF1")
	cQuery += " WHERE F1_FILIAL " + aTmpFil[nPosAlias,2]
	cQuery += " AND   SF1.F1_FORNECE = '"+SA2->A2_COD+"'"
	cQuery += " AND   SF1.F1_LOJA = '"+SA2->A2_LOJA+"'"
	cQuery += " AND   SF1.F1_EMISSAO  between '" + DTOS(mv_par01)  + "' AND '" + DTOS(mv_par02) + "'"
	cQuery += " AND   SF1.F1_ESPECIE NOT IN('RCN')"
	cQuery += " AND   SF1.F1_TIPO NOT IN ('B','D') "
	cQuery += " AND   SF1.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY " + cOrder
	cQuery := ChangeQuery(cQuery)
	
	If lF030Filt
		
		cOldQuery := cQuery
		cQuery := ExecBlock( "F030FILT", .f., .f., { cQuery, nProcess, cCpoDisp } )
	
		If Empty(cQuery)  
			cQuery := cOldQuery         	
		EndIf
	
	EndIf
	
	dbSelectArea("SF1")
	dbCloseArea()
	dbSelectArea("SA2")
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SF1', .T., .T.)
	For ni := 1 to Len(aStru)
		If aStru[ni,2] != 'C'
			TCSetField('SF1', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		Endif
	Next
	
	dbSelectArea("SF1")
	dbGoTop()
	
	nVlrGerNF6  := 0	
    nTot1       := 0
    nTot2       := 0
	While !Eof() 
		If !Empty(SF1->D1_PEDIDO)	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava registros no arquivo temporario                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cDescr := Posicione("SB1",1,xFilial("SB1")+SF1->D1_COD,"SB1->B1_DESC")
			dbSelectArea("cArq8")
			RecLock("cArq8",.T.)
			REPLACE FILORIG		With  SF1->F1_FILIAL
			Replace NOTA        With  SF1->F1_DOC
			Replace EMISNF      With  SF1->F1_EMISSAO
			Replace PEDIDO      With  SF1->D1_PEDIDO 
			Replace EMISPD      With  SF1->C7_EMISSAO
			Replace PRODUTO     With  SF1->D1_COD    
			Replace Descr       With  cDescr
			Replace DT_PREV     With  SF1->C7_DATPRF  
			Replace DT_REAL     With  SF1->D1_DTDIGIT
			If !Empty(SF1->C7_DATPRF) 
			   Replace DIF_DIAS With SF1->(C7_DATPRF - D1_DTDIGIT)
			   If SF1->(C7_DATPRF - D1_DTDIGIT) >= 0
			      Replace LEG   With  "2"
			      nTot1++
			   Else
       	          Replace LEG   With  "1"
       	          nTot2++
			   Endif
			Else
			   Replace DIF_DIAS With 0
			   Replace LEG   With  "3"
			   nTot1++
			Endif 
			
			MsUnlock()

		Endif
		dbSelectArea("SF1")
		dbSkip()
	EndDO

	dbSelectArea("SF1")
	dbCloseArea()
	ChKFile("SF1")

	dbSelectArea("cArq8")
	dbGoTop()
	nTitulos8 := RecCount()
	dbSelectArea("SF1")
	RestArea(aArea)
	Set Filter to &(cFiltro)
Endif

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fC030Imp ³ Autor ³ Wagner Xavier         ³ Data ³ 06/07/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime a consulta de titulos                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fC030Imp()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fc030Imp()

LOCAL cDesc1    := STR0074 //"Este programa ira imprimir a Consulta de um Fornecedor,"
LOCAL cDesc2    := STR0075 //"informando os dados acumulados do Fornecedor, os Pedidos"
LOCAL cDesc3    := STR0076 //"em aberto, Titulos em Aberto e rela‡„o do Faturamento."
LOCAL cString   := "SA2"
LOCAL nRegistro := SA2 -> (RecNo())
LOCAL cTamanho  := "G"  
Local cFilBkp   := cFilAnt

PRIVATE cPerg   := "FIC030"
PRIVATE aReturn := { STR0077, 1, STR0078, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE nLastKey:= 0
PRIVATE cTitulo := STR0079 //"Consulta Posicao Atual de Fornecedores"
PRIVATE nCasas  := GetMv("MV_CENT")

li       := 80
m_pag    := 1

pergunte("FIC030",.F.)

wnrel := "FINC030"

wnrel := SetPrint(cString,wnrel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,cTamanho,"",.F.)

If nLastKey == 27
	cFilant := cFilBkp
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	cFilant := cFilBkp
	Return
Endif

dbSelectArea("SA2")
dbGoTo(nRegistro)
RptStatus({|lEnd| Fc030Rel(@lEnd,wnRel,cString)},cTitulo)
cFilant := cFilBkp

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ Fc030Rel ³ Autor ³ Pilar S. ALbaladejo   ³ Data ³ 16/01/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Impressao da posicao de Fornecedor                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ Fc030Rel(lEnd,wnRel,cString)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACON                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ lEnd    - A‡Æo do Codeblock                                ³±±
±±³           ³ wnRel   - T¡tulo do relat¢rio                              ³±±
±±³           ³ cString - Mensagem                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fc030Rel(lEnd,WnRel,cString)

LOCAL cCabec1	:= ""
LOCAL cCabec2	:= ""
LOCAL cCabec3	:= ""
LOCAL cCabec4	:= ""
LOCAL cCabec5	:= ""
LOCAL cTamanho	:= ""
LOCAL cNomeProg	:= ""
LOCAL dData		:= CTOD("//")
LOCAL dVencto	:= ""
LOCAL cBanco	:= ""
LOCAL cAgencia	:= ""
LOCAL cConta	:= ""
LOCAL cHistor	:= ""
LOCAL cMotBx	:= ""
LOCAL nPedidos  := 0
LOCAL nNotas    := 0
LOCAL nTotal    := 0
LOCAL nTitulos  := 0
LOCAL nTotNota  := 0
LOCAL nTotPgto  := 0
LOCAL nTitPagos := 0
LOCAL nValPed   := 0
Local nValItPed := 0
Local nFN030IPC := 0
LOCAL nSavRec   := 0
LOCAL nTotalNF  := 0
LOCAL cbcont    := 0
Local nCotac	:= 0
LOCAL aMatriz   := {}
LOCAL cMoeda	:= ""
LOCAL cbtxt     := SPACE(10)
LOCAL nPos      := 0
LOCAL aMotBx    := ReadMotBx()
Local nLaco		:= 0
Local nSpaceNum := 14 - TamSX3("E2_NUM")[1]
Local nMulta	:= 0
Local nDesco	:= 0
Local nTotJur	:= 0
Local nTotMul	:= 0
Local nTotDes	:= 0
LOCAL cDescMoeda:= " "      		
Local nColMovel	:= {}
Local cQuery	:= ""
Local cFilAtual := ""
Local cAliasTmp := ""
Local nPosAlias := 0
Local nEspacoFil := 0
Local lC7Fiscori :=	SC7->(FieldPos("C7_FISCORI")) > 0
Local cNewFilOri := ""
Local cOldFilOri := ""
Local nQtdFilial := 1
Local aFilsBx	 := {}
Local lMovM2	 := .F.
Local cTipoNot	 := ""

Private aSelFil		:= {}
Private aTmpFil		:= {}

nEspacoFil := FWSizeFilial() + 2
If FWModeAccess("SA2",3) == "C"
	If MV_PAR10 == 1
		If  FindFunction("AdmSelecFil")
			AdmSelecFil("FIC030",10,.F.,@aSelFil,"SA2",(FWModeAccess("SA2",1) == "E"),(FWModeAccess("SA2",2) == "E"),cFilCorr)
		Else
			aSelFil := AdmGetFil(.F.,.F.,"SA2")
		Endif
	Else
		Aadd(aSelFil,cFilAnt)	// Se não seleciona filiais, carrega apenas a filial atual
	Endif
Endif

If Empty(aSelFil)
	Aadd(aSelFil,cFilCorr)
Endif		
cMoeda   := GetMv("MV_MCUSTO")
cMoeda   := SubStr(Getmv("MV_SIMB"+cMoeda)+Space(4),1,4)

cTamanho := "G"
cCabec2  := " "
cNomeProg:= "FIC030"
cCabec1  := " "
cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
li++

If cPaisLoc == "MEX"
	nColMovel := {{163,184,197},{173,184,197}}
Else
	nColMovel := {{163,179,192},{173,194,207}}
EndIf
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao dos dados do Fornecedor           				  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If RetGlbLGPD("A2_NOME")
	@li, 1 pSay Padr(AllTrim(STR0044),30,".") + ": " + SA2->A2_COD + "   " + STR0046 + ": " + Replicate("*", TamSX3("A2_NOME")[1] ) //"Codigo"###"Nome"
Else
	@li, 1 pSay Padr(AllTrim(STR0044),30,".") + ": " + SA2->A2_COD + "   " + STR0046 + ": " + SA2->A2_NOME //"Codigo"###"Nome"
Endif

li++

If RetGlbLGPD("A2_CGC")
	@li, 1 pSay Padr(AllTrim(STR0080),30,".") + ": " + Replicate("*", TamSX3("A2_CGC")[1] ) 				//"N.Contrib.Jur."
Else
	@li, 1 pSay Padr(AllTrim(STR0080),30,".") + ": " + SA2->A2_CGC 				//"N.Contrib.Jur."
Endif

li++
@li, 1 pSay Padr(AllTrim(STR0061),30,".") + ": " + DTOC(SA2->A2_PRICOM)  	//"Primeira Compra"
li++
@li, 1 pSay Padr(AllTrim(STR0081),30,".") + ": " + DTOC(SA2->A2_ULTCOM)   	//"Ultima Compra"
li++
@li, 1 pSay Padr(AllTrim(STR0063),30,".") + ":" 								//"Maior Atraso"
@li,Pcol() + 1 pSay SA2->A2_MATR Picture tm(SA2->A2_MATR,14)
li++
@li, 1 pSay Padr(AllTrim(STR0057),30,".") + ":" 								//"Saldo Atual"
@li,Pcol() + 1 pSay SA2->A2_SALDUP Picture tm(SA2->A2_SALDUP,14,nCasas)
li++
@li, 1 pSay Padr(AllTrim(STR0058),30,".") + ":" 								//"Maior Compra"
@li,Pcol() + 1 pSay SA2->A2_MCOMPRA Picture tm(SA2->A2_MCOMPRA,14,nCasas)
li++
@li, 1 pSay Padr(AllTrim(STR0059),30,".") + ":" 								//"Maior Saldo"
@li,Pcol() + 1 pSay SA2->A2_MSALDO Picture tm(SA2->A2_MSALDO,14,nCasas)
li++
@li, 1 pSay Padr(AllTrim(STR0060 + " " + AllTrim(cMoeda)),30,".") + ":" 		//"Saldo Atual em"
@li,Pcol() + 1 pSay SA2->A2_SALDUPM Picture tm(SA2->A2_SALDUPM,14,nCasas)
li+=3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao dos Titulos em aberto             				  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@li,1 pSay Upper(STR0051) //"TITULOS EM ABERTO"
li++
@li, 1 pSay Repl("-",17)

SetRegua( Reccount() )
If cPaisLoc == "BRA"	// Sergio Fuzinaka - 20.08.01
	cCabec1 := STR0082 //"PRF  NUMERO       PC TIPO  EMISSAO    NATUREZA     SALDO A PAGAR   DATA VENCTO    ATRASO   VALOR ACESSORIO  VALOR JUROS    VALOR IRRF     VALOR ISS   VALOR  INSS   NUM CHEQUE"
Else
	If cPaisLoc == "MEX"
		cCabec1 := STR0137 //"PRF  NUMERO              PC TIPO  EMISION    MODALIDAD    SALDO POR PAGAR   FCH. VENCTO    ATRASO   VALOR INTERES  NUM CHEQUE"	
	Else
		cCabec1 := STR0083 //"PRF  NUMERO       PC TIPO  EMISSAO    NATUREZA     SALDO A PAGAR   DATA VENCTO    ATRASO   VALOR JUROS    NUM CHEQUE"
	EndIf
Endif

aMatriz := {}

dbSelectArea("SE2")
dbSetOrder(3)

cQuery := "select R_E_C_N_O_ RECSE2 from " + RetSQLName("SE2")
nPosAlias := FC030QFil(1,"SE2")
cQuery += " WHERE E2_FILIAL " + aTmpFil[nPosAlias,2]
cQuery += " and E2_FORNECE = '" + SA2->A2_COD + "'"
cQuery += " and E2_LOJA = '" + SA2->A2_LOJA + "'"
cQuery += " and E2_VENCREA >= '" + Dtos(mv_par03) + "'"
cQuery += " and E2_VENCREA <= '" + Dtos(mv_par04) + "'"
cQuery += " and D_E_L_E_T_ = ' '"
cQuery += " order by E2_FILORIG,E2_VENCREA,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO"
cQuery := ChangeQuery(cQuery)
cAliasTmp := GetNextAlias()
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .T., .T.)
cFilAtual := cFilAnt
While !((cAliasTmp)->(Eof()))
	DbSelectArea("SE2")
	SE2->(DbGoTo((cAliasTmp)->RECSE2))
	cFilAnt := SE2->E2_FILORIG

	If lEnd
		@Prow()+1,0 PSay cCancel
		Exit
	EndIF
	
	IncRegua()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao lˆ outros fornecedores, abatimentos e provis¢rios.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SE2->E2_FORNECE+SE2->E2_LOJA # SA2->A2_COD+SA2->A2_LOJA .or. SE2->E2_TIPO $ MVABATIM .or. SE2->E2_SALDO = 0
		(cAliasTmp)->(dbSkip())
		Loop
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao lˆ cheques para versao localizada, sao tratados por ³
	//³ separado na rotina "Cartera de cheques".                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc != "BRA" .And. SE2->E2_TIPO$IIF(Type('MVCHEQUES')=='C',MVCHEQUES,MVCHEQUE)
		(cAliasTmp)->(dbSkip())
		Loop
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se considera Titulos Provisorios.            	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	SE2->E2_TIPO $ MVPROVIS .and. mv_par05 == 2
		(cAliasTmp)->(dbSkip())
		Loop
	Endif		
	
	IF mv_par06 == 2 .and. !Empty(SE2->E2_FATURA) .and. Substr(SE2->E2_FATURA,1,6) != "NOTFAT"
		(cAliasTmp)->(dbSkip())
		Loop
	Endif
	
	nSavRec := SE2->( Recno() )
	
	nTotAbat := 0
	IF SE2->E2_VENCTO >= mv_par03 .and. SE2->E2_VENCTO <= mv_par04 .and. ;
			SE2->E2_EMISSAO >= mv_par01 .and. SE2->E2_EMISSAO <= mv_par02
		nTotAbat:=0
		nTotAbat:=SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,,SE2->E2_FORNECE,SE2->E2_LOJA)
		If !empty(SE2->E2_SDDECRE) 
			nTotAbat += SE2->E2_SDDECRE
		Endif
		dbSetOrder(6)
		IF SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
			nTotal-=xMoeda(SE2->E2_SALDO-nTotAbat,SE2->E2_MOEDA,1,,,Iif(mv_par09==1,SE2->E2_TXMOEDA,0))
		Else
			nTotal+=xMoeda(SE2->E2_SALDO-nTotAbat,SE2->E2_MOEDA,1,,,Iif(mv_par09==1,SE2->E2_TXMOEDA,0))
		Endif
		
		nTitulos++
		nAtraso := dDataBase-fC030Venc()
		nJuros	:= fa080Juros()
		
		//Chamar calculo Valores Acessorios
		If __lFAPodeTVA
				nVA := FValAcess(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA, SE2->E2_NATUREZA,!Empty(SE2->E2_BAIXA),,"P",SE2->E2_BAIXA,,SE2->E2_MOEDA)
		EndIf
		
		If cPaisLoc == "BRA"	// Sergio Fuzinaka - 20.08.01
			Aadd( aMatriz ,{ DTOS(fc030Venc())+"|"+SE2->E2_PREFIXO+"  "+SE2->E2_NUM+Space(4)+;
			SE2->E2_PARCELA+"  "+SE2->E2_TIPO + " "+PADC(DTOC(SE2->E2_EMISSAO),10)+"    "+SE2->E2_NATUREZ + ;
			Transform(xMoeda(SE2->E2_SALDO-nTotAbat,SE2->E2_MOEDA,1,,,Iif(mv_par09==1,SE2->E2_TXMOEDA,0)),Tm(SE2->E2_SALDO,15,nCasas) ) +"    "+;
			PADC(DTOC(fc030Venc()),10)+Space(3)+Str(nAtraso,6)+" "+;
			Transform(nJuros,Tm(nJuros,15,nCasas) )+;
			Transform(nVa,Tm(nVa,15,nCasas) )+;
			Transform(SE2->E2_IRRF,Tm(SE2->E2_IRRF,15,nCasas)) + Transform(SE2->E2_ISS,Tm(SE2->E2_ISS,15,nCasas) ) +;
			Transform(SE2->E2_INSS,Tm(SE2->E2_INSS,15,nCasas)) + "   "+ SE2->E2_NUMBCO, SE2->E2_FILORIG, SE2->E2_FILORIG+DTOS(fc030Venc()) })
		Else
			Aadd( aMatriz , {DTOS(fc030Venc())+"|"+SE2->E2_PREFIXO+"  "+SE2->E2_NUM+Space(nSpaceNum)+" "+;
				SE2->E2_PARCELA+" "+SE2->E2_TIPO + "   "+PADC(DTOC(SE2->E2_EMISSAO),10)+" "+SE2->E2_NATUREZ+"  "+;
				Transform(Moeda((SE2->E2_SALDO-nTotAbat),1,"P"),Tm(SE2->E2_SALDO,15,nCasas) ) +"     "+;
				PADC(DTOC(fc030Venc()),10)+Space(2)+Str(nAtraso,6)+" "+Transform(nJuros,Tm(nJuros,15,nCasas) )+;
				"    "+ SE2->E2_NUMBCO,SE2->E2_FILORIG, SE2->E2_FILORIG+DTOS(fc030Venc()) })
		Endif
	EndIF
	
	dbSelectArea("SE2")
	dbSetOrder(3)
	(cAliasTmp)->(dbSkip())
EndDo

cFilAnt := cFilAtual
DbSelectArea(cAliasTmp)
DbCloseArea()
DbSelectArea("SE2")

dbSetOrder(1)

aSort( aMatriz , , , { | x,y | x[3] < y[3] } )

For nLaco := 1 to Len( aMatriz)
	
	IF li > 58
		cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
	Endif

	If(empty(cNewFilOri),li--,nil)
	cNewFilOri := aMatriz[nLaco][2]//Subst( aMatriz[nLaco] , 10+Len(SE2->E2_FILIAL) , Len( SE2->E2_FILORIG ) )

	li++
	If cNewFilOri <> cOldFilOri
		li++
		@li, 01 pSay cNewFilOri +" - "+Posicione("SM0",1,cEmpAnt+cNewFilOri,"M0_NOMECOM")  
		li++
		@li, 1 pSay Repl("-",Len(Alltrim(cNewFilOri +" - "+Posicione("SM0",1,cEmpAnt+cNewFilOri,"M0_NOMECOM"))))
		li++
		@li, 1 pSay cCabec1
		li++
	Endif 
	
	@li, 01 pSay Subst( aMatriz[nLaco][1] , 10 , Len( aMatriz[nLaco] [1]) )
	
	cOldFilOri := cNewFilOri
	
Next

li+=2
@li, 1 pSay STR0084 //"Total de Titulos .........."
@Prow(),Pcol() pSay nTitulos Picture "9999"
@li,nEspacoFil + 50 pSay nTotal Picture tm(nTotal,15,nCasas)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao dos Titulos pagos                 				  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCabec1 := " "
cCabec2 := " "
cNewFilOri := "" 
cOldFilOri := ""
IF li > 50
	cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
	@li, 00 pSay Replicate("*",220)
	li++
Else
	li+=3
EndIF
//                 1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9
//        123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
If cPaisLoc == "MEX"
	cCabec1 := STR0136 //"PRF NUMERO       PC  EMISSAO   NATUREZA     VALOR TITULO     VALOR PAGO   BAIXA       VENCTO.    ATRASO  BCO. AGENCIA CONTA       HISTORICO                             MOTIVO BAIXA   NUM CHEQUE"
Else
	cCabec1 := STR0085 //"PRF NUMERO       PC  EMISSAO   NATUREZA     VALOR TITULO     VALOR PAGO   BAIXA       VENCTO.    ATRASO  BCO. AGENCIA CONTA       HISTORICO                             MOTIVO BAIXA   NUM CHEQUE"
EndIf
cCabec3 := STR0123 //54/30, 58/20, 64/20
cCabec4 := STR0124 //92
cCabec5 := STR0125 //107
@li,1 pSay Upper(STR0052) //"TITULOS PAGOS"
li++
@li, 1 pSay Repl("-",17)
li++

SetRegua( Reccount() )

dbSelectArea("SE2")
dbSetOrder(3)

cQuery := "SELECT E2_FILORIG,E2_VENCREA,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO, R_E_C_N_O_ RECSE2 from " + RetSQLName("SE2")
nPosAlias := FC030QFil(1,"SE2")
cQuery += " WHERE E2_FILIAL " + aTmpFil[nPosAlias,2]
cQuery += " and E2_FORNECE = '" + SA2->A2_COD + "'"
cQuery += " and E2_LOJA = '" + SA2->A2_LOJA + "'"
cQuery += " and E2_EMISSAO >= '" + Dtos(mv_par01) + "'"
cQuery += " and E2_EMISSAO <= '" + Dtos(mv_par02) + "'"
cQuery += " and E2_VENCREA >= '" + Dtos(mv_par03) + "'"
cQuery += " and E2_VENCREA <= '" + Dtos(mv_par04) + "'"
cQuery += " and E2_VALOR != E2_SALDO AND "

cTipoNot := MVABATIM +"|"+ MVPAGANT +"|"+ MVRECANT +"|"+ MV_CRNEG +"|"+ MV_CPNEG
If mv_par05 == 2
	cTipoNot +=  "|" + MVPROVIS 
EndIf					
cTipoNot := F030TipoIN(cTipoNot)

cQuery += "E2_TIPO NOT IN " + cTipoNot +" AND "

If mv_par06 == 2
	cQuery += " E2_FATURA IN('"+Space(Len(SE2->E2_FATURA))+"','NOTFAT') AND "
Endif

cQuery += " D_E_L_E_T_ = ' '"

cQuery += " order by E2_FILORIG,E2_VENCREA,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO"
cQuery := ChangeQuery(cQuery)
cAliasTmp := GetNextAlias()
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .T., .T.)
cFilAtual := cFilAnt
While !((cAliasTmp)->(Eof()))
	DbSelectArea("SE2")
	SE2->(DbGoTo((cAliasTmp)->RECSE2))
	cFilAnt := SE2->E2_FILORIG
	If (Empty(cNewFilOri),li--,)
	cNewFilOri := SE2->E2_FILORIG

	If lEnd
		@Prow()+1,0 PSay cCancel
		Exit
	EndIF
	
	IncRegua()
	
	nSavRec := SE2->( Recno() )
	
	nTotAbat := 0
	aFilsBx := GetFlBxSE5( SE2->E2_PREFIXO , SE2->E2_NUM , SE2->E2_PARCELA , SE2->E2_TIPO , SE2->E2_FORNECE , SE2->E2_LOJA , SE2->E2_NATUREZ , SE2->E2_FILORIG , "P" , 2 )

	nPos := Ascan(aFilsBx, {|x| Alltrim(x) == Alltrim(xFilial( "SE2", SE2->E2_FILORIG ) ) })

	If nPos == 0
		aAdd( aFilsBx , xFilial( "SE2", SE2->E2_FILORIG ) )
	Endif

	For nQtdFilial := 1 To Len( aFilsBx )
		dbSelectArea("SE5")
		dbSetOrder(4)
		dbSeek(aFilsBx[nQtdFilial]+SE2->E2_NATUREZ+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO)
		While !Eof() .And. aFilsBx[nQtdFilial] == SE5->E5_FILIAL .And. SE2->E2_NATUREZ == SE5->E5_NATUREZA .And.;
				SE2->E2_PREFIXO == SE5->E5_PREFIXO .And. SE2->E2_NUM == SE5->E5_NUMERO .And.;
				SE2->E2_PARCELA == SE5->E5_PARCELA .And. SE2->E2_TIPO == SE5->E5_TIPO

			If SE2->E2_FILORIG == SE5->E5_FILORIG
				dData   := SE5->E5_DATA
				dVencto := SE2->E2_VENCREA
				nAtrBai := SE5->E5_DATA - SE2->E2_VENCREA
				If Dow(SE2->E2_VENCTO)=1 .or. Dow(SE2->E2_VENCTO) = 7
					If SE5->E5_DATA > SE2->E2_VENCREA
						nAtrBai := SE5->E5_DATA - SE2->E2_VENCTO
					Else
						nAtrBai := SE5->E5_DATA - SE2->E2_VENCREA
					Endif
				Endif
				
				nCotac	:= 0
				nPago	:= 0
				nJuros	:= 0
				nMulta	:= 0
				nDesco	:= 0
				While !Eof() .And. aFilsBx[nQtdFilial] == SE5->E5_FILIAL .And. SE2->E2_NATUREZ == SE5->E5_NATUREZA .And.;
					SE2->E2_PREFIXO == SE5->E5_PREFIXO .And. SE2->E2_NUM == SE5->E5_NUMERO .And.;
					SE2->E2_PARCELA == SE5->E5_PARCELA .And. SE2->E2_TIPO == SE5->E5_TIPO .And. ;
					dData == SE5->E5_DATA .and. SE2->E2_FILORIG == SE5->E5_FILORIG
					
					IF E5_TIPO $ MVRECANT+"/"+MV_CRNEG .OR. E5_TIPO $ MVPAGANT+"/"+MV_CPNEG;
						.or. E5_CLIFOR+E5_LOJA != SE2->E2_FORNECE+SE2->E2_LOJA
						dbSkip()
						Loop
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se existe estorno para esta baixa                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SE5->E5_SITUACA == "C" .OR.;
						TemBxCanc(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)
						SE5->( dbSkip() )
						Loop
					EndIf
								
					If cNewFilOri <> cOldFilOri
						li++
						@li, 01 pSay cNewFilOri +" - "+Posicione("SM0",1,cEmpAnt+cNewFilOri,"M0_NOMECOM")
						li++
						@li, 1 pSay Repl("-",Len(Alltrim(cNewFilOri +" - "+Posicione("SM0",1,cEmpAnt+cNewFilOri,"M0_NOMECOM"))))
						li++
						@li, 1 pSay cCabec1
						@li, nEspacoFil + nColMovel[Iif(TamSX3("E5_CONTA")[1]==10,1,2),1] pSay cCabec3
						@li, nEspacoFil + nColMovel[Iif(TamSX3("E5_CONTA")[1]==10,1,2),2] pSay cCabec4
						@li, nEspacoFil + nColMovel[Iif(TamSX3("E5_CONTA")[1]==10,1,2),3] pSay cCabec5
						cOldFilOri := cNewFilOri
					Endif
						
					cMotBx   := space(09)
					cBanco   := E5_BANCO
					cAgencia := E5_AGENCIA
					cConta   := E5_CONTA
					cHistor  := AllTrim(E5_HISTOR)
					cCheque	:= E5_NUMCHEQ
	
					nPos := Ascan(aMotBx, {|x| Substr(x,1,3) == Upper(SE5->E5_MOTBX) })
					If nPos > 0
						cMotBx := Substr(aMotBx[nPos],07,09)
					ElseIf E5_MOTBX == "CEC"
						cMotBx := STR0073	 //"COMP CART"
					EndIf
	
					IF E5_TIPODOC $ "VL/BA/CP"
						nCotac++       
						lMovM2 := MovMoedEs(SE5->E5_MOEDA, SE5->E5_TIPODOC, SE5->E5_MOTBX, DTOS(SE5->E5_DATA), "P") 
						
						If cPaisLoc $ "MEX|BOL"
							nPago += xMoeda(SE5->E5_VALOR,Val(SE5->E5_MOEDA),1,,,Iif(mv_par09==1,SE5->E5_TXMOEDA,0))         
						Else
							nPago+= If(lMovM2, SE5->E5_VLMOED2, SE5->E5_VALOR)
						Endif
						
						nJuros += SE5->E5_VLJUROS
						nMulta += SE5->E5_VLMULTA
						nDesco += SE5->E5_VLDESCO
						IF li > 58
							cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
						Endif
						dbSelectArea( "SE2" )
						li++
						If cPaisLoc $ "MEX|BOL"
							@li, 01 pSay SE2->E2_PREFIXO
							@li, 05 pSay SE2->E2_NUM
							@li, 26 pSay SE2->E2_PARCELA
							@li, 28 pSay DTOC(SE2->E2_EMISSAO)
							@li, 39 pSay SE2->E2_NATUREZ
							@li, 49 pSay Transf(xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,1,,,Iif(mv_par09==1,SE2->E2_TXMOEDA,0)),Tm(SE2->E2_VALOR,14,nCasas))
							@li, 64 pSay Transf(xMoeda(SE5->E5_VALOR,Val(SE5->E5_MOEDA),1,,,Iif(mv_par09==1,SE5->E5_TXMOEDA,0)),Tm(SE5->E5_VALOR,14,nCasas))
							@li, 78 pSay SE5->E5_VLJUROS	Picture Tm(SE5->E5_VLJUROS,11,nCasas) //@E 9999,999.99
							@li, 89 pSay SE5->E5_VLMULTA	Picture Tm(SE5->E5_VLMULTA,11,nCasas) //@E 9999,999.99
							@li,100 pSay SE5->E5_VLDESCO	Picture Tm(SE5->E5_VLDESCO,11,nCasas) //@E 9999,999.99
							@li,112 pSay DTOC(dData)
							@li,124 pSay DTOC(dVencto)
							@li,135 pSay nAtrBai		Picture PesqPictQt("A2_MATR")
							@li,145 pSay SubStr(cBanco, 1, 4)
							@li,149 pSay SubStr(cAgencia, 1, 7)
							@li,155 pSay SubStr(cConta, 1, 6)
							dbSelectArea( "SE5" )
							If TamSX3("E5_CONTA")[1] == 10
								@li,nColMovel[1,1] pSay SUBSTR(cHistor,1,30)
								@li,nColMovel[1,2]+1 pSay Substr(cMotBx,1,12)
								@li,nColMovel[1,3]+1 pSay cCheque
								If (mv_par08==1) .And. (TamSX3("E5_HISTOR")[1] > 30)
									li++
									@li,nColMovel[1,1] pSay SUBSTR(cHistor,31,TamSX3("E5_HISTOR")[1]-30)
								EndIf
							Else
								@li,nColMovel[2,1] pSay SUBSTR(cHistor,1,20)
								@li,nColMovel[2,2]+1 pSay Substr(cMotBx,1,12)
								@li,nColMovel[2,3]+1 pSay cCheque
								If (mv_par08==1) .And. (TamSX3("E5_HISTOR")[1] > 20)
									li++
									@li,nColMovel[2,1] pSay SUBSTR(cHistor,21,TamSX3("E5_HISTOR")[1]-20)
								EndIf
							EndIf
						Else
							@li, 01 pSay SE2->E2_PREFIXO
							@li, 05 pSay SE2->E2_NUM
							@li, 17 pSay SE2->E2_PARCELA
							@li, 21 pSay DTOC(SE2->E2_EMISSAO)
							@li, 35 pSay SE2->E2_NATUREZ
							@li, 46 pSay Transf(If(lMovM2, SE5->E5_VLMOED2, xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,1,,,Iif(mv_par09==1,SE2->E2_TXMOEDA,0))),Tm(SE2->E2_VALOR,14,nCasas))
							@li, 61 pSay If(lMovM2, SE5->E5_VLMOED2, SE5->E5_VALOR) Picture Tm(SE5->E5_VALOR,14,nCasas)//@E 999,999,999.99
							@li, 73 pSay SE5->E5_VLJUROS	Picture Tm(SE5->E5_VLJUROS,11,nCasas)	//@E 9999,999.99
							@li, 81 pSay SE5->E5_VLMULTA	Picture Tm(SE5->E5_VLMULTA,11,nCasas)	//@E 9999,999.99
							@li, 93 pSay SE5->E5_VLDESCO	Picture Tm(SE5->E5_VLDESCO,11,nCasas)	//@E 9999,999.99
							@li, 106 pSay DTOC(dData)
							@li, 119 pSay DTOC(dVencto)
							@li, 131 pSay nAtrBai		Picture PesqPictQt("A2_MATR")
							@li, 140 pSay SubStr(cBanco, 1, 4)
							@li, 146 pSay SubStr(cAgencia, 1, 7) 
							@li, 152 pSay SubStr(cConta, 1, 10)
							dbSelectArea( "SE5" )
							@li,nColMovel[1,1]+1 pSay SUBSTR(cHistor,1,15)
							@li,nColMovel[1,2]+1 pSay Substr(cMotBx,1,12)
							@li,nColMovel[1,3]+1 pSay cCheque
							If (mv_par08==1) .And. (Len(cHistor) > 15)
								li++
								@li,   nColMovel[1,1] + 1 pSay SUBSTR(cHistor,16)
							EndIf
						Endif
					Endif
					SE5->(dbSkip( ))
				Enddo
				If nPago != 0 .Or. nCotac <> 0 
					nTotPgto+=nPago
					nTotJur+=nJuros
					nTotMul+=nMulta
					nTotDes+=nDesco								
					nTitPagos++
				EndIf
			Else
				SE5->(dbSkip( ))
			EndIf
		Enddo
	Next nQtdFilial

	dbSelectArea( "SE2" )
	dbSetOrder(3)
	dbGoTo( nSavRec )
	(cAliasTmp)->(dbSkip())
Enddo

cFilAnt := cFilAtual
DbSelectArea(cAliasTmp)
DbCloseArea()

DbSelectArea("SE2")
dbSetOrder(1)
Li+=2
@li,  1 pSay STR0086 //"Total de Pagamentos ......."
@li, nEspacoFil + 28 pSay nTitPagos	Picture PesqPictQt("A2_MATR")
@li, nEspacoFil + 61 pSay nTotPgto	Picture Tm(nTotPgto,14,nCasas)
@li, nEspacoFil + 73 pSay nTotJur	Picture Tm(nTotJur,11,nCasas)
@li, nEspacoFil + 81 pSay nTotMul	Picture Tm(nTotMul,11,nCasas)
@li, nEspacoFil + 93 pSay nTotDes	Picture Tm(nTotDes,11,nCasas)								
					
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao dos Pedidos Colocados             				  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCabec1 := " "
cCabec2 := " "
IF li > 50
	cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
	@li, 00 pSay Replicate("*",220)
	li++
Else
	li+=3
EndIF
@li,1 pSay STR0087 //"PEDIDOS COLOCADOS"
li++
@li, 1 pSay Repl("-",17)
li++
cCabec1 := STR0088 //"NUMERO        DATA EMISSAO                   VALOR DO ITEM"

If lC7Fiscori
	cCabec1 := PadR(Upper(SX3->(RetTitle("C7_FISCORI"))),nEspacoFil+Len(SM0->M0_NOMECOM)+3) + cCabec1
Endif

dbSelectArea("SC7")
SetRegua( Reccount() )

dbSetOrder(3)
@li, 1 pSay cCabec1

cQuery := "select R_E_C_N_O_ RECSC7 from " + RetSQLName("SC7")
nPosAlias := FC030QFil(1,"SC7")
cQuery += " WHERE C7_FILIAL " + aTmpFil[nPosAlias,2]
cQuery += " and C7_FORNECE = '" + SA2->A2_COD + "'"
cQuery += " and C7_LOJA = '" + SA2->A2_LOJA + "'"
cQuery += " and C7_EMISSAO >= '" + Dtos(mv_par01) + "'"
cQuery += " and C7_EMISSAO <= '" + Dtos(mv_par02) + "'"
cQuery += " and D_E_L_E_T_ = ' '"
cQuery += " order by C7_FILIAL,C7_FORNECE,C7_LOJA,C7_NUM"
cQuery := ChangeQuery(cQuery)
cAliasTmp := GetNextAlias()
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .T., .T.)

While !((cAliasTmp)->(Eof()))
	DbSelectArea("SC7")
	SC7->(DbGoTo((cAliasTmp)->RECSC7))

	If lEnd
		@Prow()+1,0 PSay cCancel
		Exit
	EndIF
	
	IncRegua()
	
	IF SC7->C7_EMISSAO >= mv_par01 .And. SC7->C7_EMISSAO <= mv_par02
		If mv_par07 == 2 
			If (SC7->C7_QUANT - SC7->C7_QUJE) == 0
				(cAliasTmp)->(dbSkip())
				Loop
			EndIf
		EndIf
		nPedidos++
		li++
		IF li > 58
			cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
		EndIF
		
		nValItPed := SC7->C7_TOTAL
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada para manipular o valor total do item do Pedido de Compras³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("FN030IPC")
			nFN030IPC := Execblock("FN030IPC",.F.,.F.,{nValItPed})
			If ValType(nFN030IPC) == "N"
				nValItPed := nFN030IPC
			EndIf
		EndIf
		
		If lC7Fiscori
			@li,01 PSay SC7->C7_FISCORI+" - "+Posicione("SM0",1,cEmpAnt+SC7->C7_FISCORI,"M0_NOMECOM")
			@li,nEspacoFil + 63 + 01 pSay SC7->C7_NUM
			@li,nEspacoFil + 63 + 26 pSay SC7->C7_EMISSAO
			@li,nEspacoFil + 63 + 54 pSay nValItPed Picture PesqPict("SC7","C7_TOTAL",14)			
		Else
			@li, 1 pSay SC7->C7_NUM
			@li,26 pSay SC7->C7_EMISSAO
			@li,54 pSay nValItPed Picture PesqPict("SC7","C7_TOTAL",14)
		Endif
		
		nValPed+=nValItPed
	EndIF
	(cAliasTmp)->(dbSkip())
EndDO
li+=2
IF li > 58
	cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
EndIF
@li,01 pSay STR0089+StrZero(nPedidos,4) //"Total de Itens ............ "
@li,nEspacoFil + 54 pSay nValPed Picture PesqPict("SC7","C7_TOTAL",14)

DbSelectArea(cAliasTmp)
DbCloseArea()

DbSelectArea("SC7")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do Faturamento                    				  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
cCabec1 := " "
cCabec2 := " "
IF li > 50
	cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
	@li, 00 pSay Replicate("*",220)
	li++
Else
	li+=3
EndIF
@li,1 pSay Upper(STR0054) //"FATURAMENTO"
li++
@li, 1 pSay Repl("-",11)
li++
cCabec1:=" "+STR0090 //"NUMERO         DATA EMISSAO    VALOR DA NOTA  DUPLICATA"

If FWModeAccess("SF1",1) == "E"
	cCabec1 := PadR(Upper(SX3->(RetTitle("E2_FILORIG"))),nEspacoFil+Len(SM0->M0_NOMECOM)+2) + cCabec1
	nEspacoFil := FWSizeFilial() + Len(SM0->M0_NOMECOM)+ 5
Else
	nEspacoFil := 0
Endif  

dbSelectArea("SF1")
SetRegua( Reccount() )
dbSetOrder(2)
@li, 1 pSay cCabec1
nTotalNf := 0

cQuery := "select R_E_C_N_O_ RECSF1 from " + RetSQLName("SF1")
nPosAlias := FC030QFil(1,"SF1")
cQuery += " WHERE F1_FILIAL " + aTmpFil[nPosAlias,2]
cQuery += " and F1_FORNECE = '" + SA2->A2_COD + "'"
cQuery += " and F1_LOJA = '" + SA2->A2_LOJA + "'"
cQuery += " and F1_EMISSAO >= '" + Dtos(mv_par01) + "'"
cQuery += " and F1_EMISSAO <= '" + Dtos(mv_par02) + "'"
cQuery += " and F1_TIPO not in ('B','D')"
cQuery += " and D_E_L_E_T_ = ' '"
cQuery += " order by F1_FORNECE,F1_LOJA,F1_DOC"
cQuery := ChangeQuery(cQuery)
cAliasTmp := GetNextAlias()
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .T., .T.)
cFilAtual := cFilAnt

While !((cAliasTmp)->(Eof()))
	DbSelectArea("SF1")
	SF1->(DbGoTo((cAliasTmp)->RECSF1))

	If lEnd
		@Prow()+1,0 PSay cCancel
		Exit
	EndIF
	
	IncRegua()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Notas Canceladas   --  SHELL                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
	#IFDEF SHELL
		IF F1_CANCEL == "S"
			dbSkip()
			Loop
		EndIf
	#ENDIF
	
	IF SF1->F1_EMISSAO >= mv_par01 .And. SF1->F1_EMISSAO <= mv_par02 .And. !(SF1->F1_TIPO $ "BD")
		nNotas++
		IF li > 58
			cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
		EndIF
		li++

		If nEspacoFil > 0
			@li,01 PSay SF1->F1_FILIAL +" - "+Posicione("SM0",1,cEmpAnt+SF1->F1_FILIAL,"M0_NOMECOM")
		Endif

		@li, nEspacoFil + 1 pSay SF1->F1_DOC
		@li,nEspacoFil + 25 pSay SF1->F1_EMISSAO
		nTotNota:= SF1->F1_VALMERC+SF1->F1_FRETE+SF1->F1_VALIPI+SF1->F1_ICMSRET+SF1->F1_DESPESA-SF1->F1_DESCONT
		@li,nEspacoFil + 38 pSay nTotNota     Picture tm(nTotNota,14,nCasas)
		@li,nEspacoFil + 63 pSay SF1->F1_DUPL
		nTotalNF += nTotNota
	EndIF
	(cAliasTmp)->(dbSkip())
EndDO
li+=2
IF li > 58
	cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
EndIF

@li, 1 pSay STR0091+StrZero(nNotas,4) //"Total de Notas.: "
@li,nEspacoFil + 38 pSay nTotalNF Picture Tm( nTotalNF, 14,nCasas )

DbSelectArea(cAliasTmp)
DbCloseArea()

DbSelectArea("SF1")
If cPaisLoc != "BRA"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao da carteira de cheques              				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	
	cCabec1 := " "
	cCabec2 := " "
	IF li > 50
		cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
		@li, 00 pSay Replicate("*",220)
		li++
	Else
		li+=3
	EndIF
	@li,1 pSay STR0092 //"CARTEIRA DE CHEQUES"
	li++
	@li, 1 pSay Repl("-",11)
	li++
	     
	cDescMoeda:= ALLTRIM( UPPER(GetMV("MV_MOEDAP1")) )
	If Len(cDescMoeda)>8
		cDescMoeda:=Subs(cDescMoeda,1,8)	
	EndIf
	cDescMoeda := PADR( "(" + cDescMoeda + ")", 10, " " )
	
	cCabec1 := STR0093 + cDescMoeda + STR0119  //"SITUACION NUMERO     FECHA EMISION            VALOR MONEDA      VALOR  FECHA VENCTO BANCO AGENCIA CUENTA     FECHA DEPOSITO ORDEN DE PAGO"
	cCabec1 := PadR(Upper(SX3->(RetTitle("E2_FILORIG"))),nEspacoFil) + cCabec1
	nEspacoFil := FWSizeFilial() + 2

	li++
	
	dbSelectArea("SE2")
	
	SetRegua( Reccount() )
	
	li++
	@li, 1 pSay cCabec1
	
	aTotal6	:=	{0.00,0,0.00,0}
	SE2->(dbSetOrder(6))

	cQuery := "select R_E_C_N_O_ RECSE2 from " + RetSQLName("SE2")
	nPosAlias := FC030QFil(1,"SE2")
	cQuery += " WHERE E2_FILIAL " + aTmpFil[nPosAlias,2]
	cQuery += " and E2_FORNECE = '" + SA2->A2_COD + "'"
	cQuery += " and E2_LOJA = '" + SA2->A2_LOJA + "'"
	cQuery += " and E2_VENCTO >= '" + Dtos(mv_par03) + "'"
	cQuery += " and E2_VENCTO <= '" + Dtos(mv_par04) + "'"
	cQuery += " and E2_EMISSAO >= '" + Dtos(mv_par01) + "'"
	cQuery += " and E2_EMISSAO <= '" + Dtos(mv_par02) + "'"
	cQuery += " and D_E_L_E_T_ = ' '"
    cQuery += " order by E2_VENCREA,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO"
    cQuery := ChangeQuery(cQuery)
    cAliasTmp := GetNextAlias()
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .T., .T.)
	cFilAtual := cFilAnt
	
	While !((cAliasTmp)->(Eof()))
		DbSelectArea("SE2")
		SE2->(DbGoTo((cAliasTmp)->RECSE2))
		cFilAnt := SE2->E2_FILORIG

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra os nao cheques e os que estao fora dos parametros|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE2->E2_VENCTO<=mv_par03 .or. SE2->E2_VENCTO>=mv_par04 .or. ; 		
			SE2->E2_EMISSAO<=mv_par01 .or. SE2->E2_EMISSAO>=mv_par02
         	(cAliasTmp)->(dbSkip())
			Loop
		EndIF
		If SE2->E2_TIPO $ IIF(Type('MVCHEQUES')=='C',MVCHEQUES,MVCHEQUE)
        	If SE2->E2_SALDO>0.AND.EMPTY(SE2->E2_BAIXA)
				aTotal6[1]+=	Moeda(SE2->E2_SALDO,1,"P")
				aTotal6[2]+=	1
				cSituac	:= STR0094 //"No Dep."
			Else
				aTotal6[3]+=	Moeda(SE2->E2_VALOR,1,"P")
				aTotal6[4]+=	1
				cSituac	:= STR0095 //"Dep."
			Endif
	
			If lEnd
				@Prow()+1,0 PSay cCancel
				Exit
			EndIF
			
			IncRegua()
			
			nNotas++
			IF li > 58
				cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
			EndIF
			li++
			@li,001 PSay SE2->E2_FILORIG
			@li,nEspacoFil + 001 pSay cSituac
			@li,nEspacoFil + 011 pSay SE2->E2_NUM
			@li,nEspacoFil + 035 pSay SE2->E2_EMISSAO
			@li,nEspacoFil + 051 pSay SE2->E2_VALOR  Picture Tm( VALOR, 14, nCasas )
			@li,nEspacoFil + 070 pSay STRZERO(E2_MOEDA,2)
			@li,nEspacoFil + 079 pSay MOEDA(SE2->E2_VALOR,1,"P")	Picture Tm( SE2->E2_VALOR, 14,nCasas)
			@li,nEspacoFil + 104 pSay SE2->E2_VENCTO
			@li,nEspacoFil + 117 pSay SE2->E2_BCOCHQ
			@li,nEspacoFil + 123 pSay SE2->E2_AGECHQ 
			@li,nEspacoFil + 131 pSay SE2->E2_CTACHQ
			@li,nEspacoFil + 142 pSay SE2->E2_BAIXA
			@li,nEspacoFil + 157 pSay SE2->E2_ORDPAGO
		Endif	
		(cAliasTmp)->(dbSkip())
	Enddo

	li+=2
	@li,001 Say STR0096 + Str(aTotal6[2],5) 											//"Cheques en abierto "
	@li,nEspacoFil + 026 Say STR0097	+ Str(aTotal6[4],5)  							//"Cheques dep. "
	@li,nEspacoFil + 051 Say STR0098	+ Transf(aTotal6[1],Tm(aTotal6[1],15,nCasas)) 	//"Total Chqs en abierto : "
	@li,nEspacoFil + 079 Say STR0099 + Transf(aTotal6[3],Tm(aTotal6[3],15,nCasas)) 		//"Total Chqs dep. : "
	IF li != 80
		li++
		roda(cbcont,cbtxt,"G")
	EndIF

	cFilAnt := cFilAtual
	DbSelectArea(cAliasTmp)
	DbCloseArea()

	DbSelectArea("SE2")
EndIF

IF li != 80
	li++
	roda(cbcont,cbtxt,"G")
EndIF

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif
MS_FLUSH()

FC030QFil(2)
Return (.T.)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fC030Procri ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 15/01/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria estruturas dos arquivos de Trabalho                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fC030Procri()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINC030                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Fc030Procri()

	// Seta tamanho da regua
	ProcRegua(4)
	
	IncProc(STR0100) //"Criando Arquivo de Trabalho - T¡tulos em Aberto"
	cNomeArq := Fc030Cria(aCampos1,1)
	
	IncProc(STR0101) //"Criando Arquivo de Trabalho - T¡tulos Pagos"
	cNomeArq := Fc030Cria(aCampos2,2)
	
	IncProc(STR0102) //"Criando Arquivo de Trabalho - Pedidos Colocados"
	cNomeArq := Fc030Cria(aCampos3,3)
	
	IncProc(STR0103) //"Criando Arquivo de Trabalho - Faturamento"
	cNomeArq := Fc030Cria(aCampos4,4)
	
	IncProc(STR0104) //"Criando Arquivo de Trabalho - Produtos"
	cNomeArq := Fc030Cria(aCampos5,5)
	
	If cPaisLoc != "BRA"
		IncProc(STR0105) //"Criando Arquivo de Trabalho - Cartera de cheques"
		cNomeArq := Fc030Cria(aCampos6,6)
	Endif
	
	IncProc(STR0149)  //"Criando Arquivo de Trabalho - Devolução"
	cNomeArq := Fc030Cria(aCampos7,7)   
	
	IncProc(STR0150) //"Criando Arquivo de Trabalho - Entrega"
	cNomeArq := Fc030Cria(aCampos8,8)
	
Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FC030GRF ³ Autor ³ Larson Zordan         ³ Data ³ 16/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grafico da Estatistica financeira - a Pagar e Pagos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FC030GRF(lProc030a,lProc030b)
Local oGraph,oDlg
Local aObjects := {},aPosObj  :={}
Local aSize    := MsAdvSize(.F.)
Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

// Carregar dados de Titulos em Aberto
If !lProc030a
	lProc030a := .T.
	Processa( { |lEnd| Fc030Gera(1) } )
Endif
	
// Carregar dados de Titulos Pagos
If !lProc030b
	lProc030b := .T.
	Processa( { |lEnd| Fc030Gera(2) } )
Endif

// Array com objetos utilizados
AADD(aObjects,{100,100,.T.,.T.,.T.})
AADD(aObjects,{100,015,.T.,.F.,.F.})

aPosObj:=MsObjSize(aInfo,aObjects)

DEFINE MSDIALOG oDlg TITLE STR0106 OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]  //"Grafico da Estatistica Financeira - Titulos a Pagar e os Pagos"
@ aPosObj[1,1],aPosObj[1,2] MSGRAPHIC oGraph SIZE aPosObj[1,3],aPosObj[1,4] OF oDlg PIXEL
oGraph:SetMargins( 5, 5, 5, 5 )
oGraph:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
nSerie := oGraph:CreateSerie( 4 )
oGraph:Add(nSerie,nTotal1, STR0107,CLR_HRED) 	//"Total a Pagar"
oGraph:Add(nSerie,nTotal2, STR0108,CLR_HBLUE) 	//"Total Pago   "
oGraph:l3D := .F.
DEFINE SBUTTON FROM aPosObj[2,1],aPosObj[2,4]-30 ACTION oDlg:End() ENABLE OF oDlg PIXEL
ACTIVATE MSDIALOG oDlg
RETURN

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³FC030ChFol³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 13/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Direcionamento da criacao dos arquivos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fc030ChFol(nDest030,nAtual,lProc030a,lProc030b,lProc030c,lProc030d,lProc030e,lProc030f,oLbx,oLbx1,oLbx2,oLbx3,oLbx4,oLbx5,oLbx6)

If nDest030 != nAtual
	// Carregar dados da Entrega
	If (nDest030 == 8)
		If !lProc030f
			lProc030f := .T.
			Processa( { |lEnd| Fc030Gera(6) } )
		EndIf
		oLbx:Refresh()
		
		oLbx6:Gotop()
		oLbx6:Refresh()
		oLbx6:SetFocus()
	Endif
	// Carregar dados de Titulos em aberto
	If (nDest030 == 2 .or. (nDest030 == 7 .and. cPaisLoc != "BRA"))
		If !lProc030a
			lProc030a := .T.
			Processa( { |lEnd| Fc030Gera(1) } )
		EndIf
		oLbx:Refresh()
		oLbx:SetFocus()
		If nDest030 == 7 
			oLbx5:Gotop()
			oLbx5:Refresh()
		Endif
	Endif
	
	// Carregar dados de Devolucao
	If (cPaisLoc == "BRA" .and. nDest030 == 7)
		If !lProc030e
			lProc030e := .T.
			Processa( { |lEnd| Fc030Gera(5) } )
		EndIf
		oLbx:Refresh()
		oLbx:SetFocus()
		
		oLbx5:Gotop()
		oLbx5:Refresh()
	
	Endif
	
	// Carregar dados de Titulos Pagos
	If nDest030 == 3  
		If !lProc030b
			lProc030b := .T.
			Processa( { |lEnd| Fc030Gera(2) } )
		EndIf
		oLbx1:Refresh()
		oLbx1:SetFocus()
	Endif
	
	// Carregar dados de Faturamento
	If (nDest030 == 4 .or. nDest030 == 6) .and. !lProc030c
		lProc030c := .T.
		Processa( { |lEnd| Fc030Gera(3) } )
		oLbx2:Gotop()
		oLbx2:Refresh()
		oLbx4:Refresh()
		oLbx4:SetFocus()
	Endif
	
	// Carregar dados de Pedidos e Produtos
	If nDest030 == 5 .and. !lProc030d
		lProc030d := .T.
		Processa( { |lEnd| Fc030Gera(4) } )
		oLbx3:Refresh()
		oLbx3:SetFocus()
	Endif
Endif	
Return         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINC030   ºAutor  ³Aline Sebrian       º Data ³  22/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe a consulta do Pedido de Compras                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cNumPc -> Numero do Pedido de Compras     				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8.11->FINC030                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    
Static Function F030PCVis(cFilOrig,cNumPC)

Local aArea			:= GetArea()
Local aAreaSC7		:= SC7->(GetArea())
Local nSavNF		:= MaFisSave()
Local cSavCadastro	:= cCadastro
Local cFilBkp		:= ""		/* GESTAO */
Local nregSM0		:= 0		/* GESTAO */

PRIVATE nTipoPed	:= 1
PRIVATE cCadastro	:= STR0066 //"Consulta ao Pedido de Compra"
PRIVATE l120Auto	:= .F.
PRIVATE aBackSC7	:= {}  //Sera utilizada na visualizacao do pedido - MATA120

DEFAULT cFilOrig := xFilial("SC7")

SaveInter() // Salva variaveis publicas

If !empty(cNumPC)
	// Para que a opção Tracker esteja disponível no menu do Pedido de Compras 
	// é necessário que a Visualização seja código = 2
	// A variável aRotina Será restaurada após este bloco na chamada RestInter()
	AEVAL(aRotina,{|e| IF(UPPER(e[2]) == "AXVISUAL",e[4] := 2,NIL)})

	cFilBkp := cFilAnt
	MaFisEnd()
	nRegSM0 := SM0->(Recno())
	SM0->(DbSeek(cEmpAnt + AllTrim(cFilOrig)))
	cFilAnt := SM0->M0_CODFIL
	dbSelectArea("SC7")
	dbSetOrder(1)
	dbSeek(cFilOrig+cNumPC)
	A120Pedido(Alias(),RecNo(),2)
	SM0->(DbGoto(nRegSM0))
	cFilAnt := cFilBkp
Else
	MsgAlert(STR0134) //"Não há registos para consulta."	
EndIf

RestInter() // Restaura variaveis publicas

cCadastro	:= cSavCadastro
MaFisRestore(nSavNF)
RestArea(aAreaSC7)
RestArea(aArea)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINC030   ºAutor  ³Adilson Yamaguchi   º Data ³  28/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe a onsulta da Fatura de Entrada                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cAlias -> Alias do Arquivo de Cabecalho de NF de entrada   º±±
±±º          ³ cRecno -> Record Number do Arquivo cAlias                  º±±
±±º          ³ nOpc   -> Codigo de Opcao do Programa Mata910              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8.11->FINC030                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F030Visual(cAlias, nRecno, nOpc)
Local cFilBkp	:= ""		/* GESTAO */
Local nRegSM0	:= 0		/* GESTAO */

cFilBkp := cFilAnt
nRegSM0 := SM0->(Recno())
SaveInter() // Salva variaveis publicas
(cAlias)->(MsGoTo(nRecno))
If cAlias = "SF1"
	SM0->(DbSeek(cEmpAnt + AllTrim((cAlias)->F1_FILIAL)))
	cFilAnt := SM0->M0_CODFIL 
	dbSelectArea("SD1")
	dbSetOrder(1)
	lAchou := dbSeek(xFilial(cAlias)+(cAlias)->F1_DOC+(cAlias)->F1_SERIE+(cAlias)->F1_FORNECE+(cAlias)->F1_LOJA)
	dbSelectArea(cAlias)
	If lAchou
		If cPaisLoc == "BRA"
			MATA103(,,2)
		Else
			LOCXNF(Val(SF1->F1_TIPODOC), , , , , , 2)
		EndIf
	Else
		MsgAlert(STR0134) //"Não há registos para consulta."	
	EndIF
Else
	SM0->(DbSeek(cEmpAnt + AllTrim((cAlias)->F2_FILIAL)))
	cFilAnt := SM0->M0_CODFIL
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(xFilial(cAlias)+(cAlias)->F2_DOC+(cAlias)->F2_SERIE+(cAlias)->F2_CLIENTE+(cAlias)->F2_LOJA,.t.)
	lAchou := If(xFilial(cAlias)+(cAlias)->F2_DOC+(cAlias)->F2_SERIE+(cAlias)->F2_CLIENTE+(cAlias)->F2_LOJA = xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA,.t.,.f.)
	dbSelectArea(cAlias)
	If lAchou
		Mc090Visual(cAlias,nRecno,2)
	Else
		MsgAlert(STR0134) //"Não há registos para consulta."	
	EndIF
Endif
SM0->(DbGoTo(nRegSM0))
cFilAnt := cFilBkp
RestInter() // Restaura variaveis publicas

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³28/11/06 ³±±
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
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados    		  ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina  := { {	STR0001 ,"AxPesqui"  , 0 , 1} ,;   //"Pesquisar"
					{	STR0002 ,"AxVisual"  , 0 , 1} ,;   //"Visualizar"
					{	STR0003 ,"Fc030Con"  , 0 , 2} ,;   //"Consultar"	
					{	STR0004 ,"Fc030Imp"  , 0 , 2} }    //"Impressao"
Return(aRotina)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FinC030T   ³ Autor ³ Marcelo Celi Marques ³ Data ³ 31.03.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada semi-automatica utilizado pelo gestor financeiro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINC030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FinC030T(aParam)

	ReCreateBrow("SA2",FinWindow)      	
	cRotinaExec := "FINC030"
	FinC030(,aParam[1])
	ReCreateBrow("SA2",FinWindow)      	
	dbSelectArea("SA2")
	
	INCLUI := .F.
	ALTERA := .F.

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LjLeg    ³ Autor ³    Varejo             ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Legenda.                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LjLeg()

Local  aLegenda := {} //Legenda Entrega

aAdd( aLegenda, { "BR_VERDE"	, STR0146  } ) 	//"Entrega no prazo"
aAdd( aLegenda, { "BR_VERMELHO"	, STR0147  } )   	//"Entrega atrasada" 
aAdd( aLegenda, { "BR_AMARELO" 	, STR0151  } ) 	//"Nota sem pedido"

BrwLegenda(STR0152,STR0148 ,aLegenda) //"Consulta Entrega" "Legenda"

Return .T. 

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FC010QFil³ Autor ³                      ³ Data ³06/12/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria um complemento para uso em queries para os casos em   ³±±
±±³          ³ se necessisita verificar em uma relacao de filiais.        ³±±
±±³          ³ Utiliza as funcoes do ctb para controle da quatidade de    ³±±
±±³          ³ filiais.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Paramatros³ nAcao: 1 cria o complemento para query.                    ³±±
±±³          ³        2 apaga as tabelas temporaria, se criadas.          ³±±
±±³          ³ cAliasFil: tabela onde sera comparada a filial.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FC030QFil(nAcao,cAliasFil)
Local nPosAlias		:= 0
Local cTmpFil		:= ""

Default cAliasFil	:= ""
Default nAcao		:= 2     
aTmpFil := {}
If nAcao == 1
	If !Empty(cAliasFil)
		nPosAlias := Ascan(aTmpFil,{|carq| carq[1] == cAliasFil})
		If nPosAlias == 0
			Aadd(aTmpFil,{"","",""})
			nPosAlias := Len(aTmpFil)
			aTmpFil[nPosAlias,1] := cAliasFil
			MsgRun("Favor Aguardar.....",STR0005 ,{|| aTmpFil[nPosAlias,2] := GetRngFil(aSelFil,cAliasFil,.T.,@cTmpFil)}) //"Favor Aguardar....."###"Consulta Posição fornecedores"
			aTmpFil[nPosAlias,3] := cTmpFil
		Endif
	Endif
Else
	If nAcao == 2
		If !Empty(aTmpFil) 
			MsgRun("Favor Aguardar.....",STR0005 ,{|| AEval(aTmpFil,{|tmpfil| CtbTmpErase(tmpFil[3])})}) //"Favor Aguardar....."###"Consulta Posição fornecedores"
			nPosAlias := Len(aTmpFil)
			aTmpFil := {}
			aSelFil := {}
		Endif
	Endif
Endif

If nAcao == 1
	If Empty(FWSM0LayOut(,1)) .And. Empty(FWSM0LayOut(,2)) .And. FWModeAccess(cAliasFil, 3) == "C"
		aTmpFil[1,2] := " = '  ' "
	ElseIf ((Empty(aTmpFil[1,2]) .OR. aTmpFil[1,2] == " = '  ' ") .and. FWModeAccess(cAliasFil,1) == "E")
		aTmpFil[1,2] := (AllTrim("0" + AllTrim(STR((Len(aTmpFil))))))
		aTmpFil[1,2] := " = '" + aTmpFil[1,2] + "'"
	EndIf
EndIf	

Return(nPosAlias)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±                                                                         ±±
±±            Funcoes retiradas do arquivo FINXFUN.PRX                     ±±
±±                                                                         ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fC030Venc³ Autor ³ Vinicius S. Barreira  ³ Data ³ 31/10/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a data de vencimento de acordo com a relacao entre ³±±
±±³          ³ a data nominal, a data real e a data-base.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fC030Venc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fC030Venc()

LOCAL dData := dDataBase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a data de vencimento REAL ja' estiver vencido, o atraso passa a     ³
//³ se calculado em funcao da data NOMINAL. Caso contrario, se ainda nao   ³
//³ estiver vencido, usa-se a propria data do vencimento REAL.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If DataValida(SE2->E2_VENCTO,.T.) <= dDataBase
	dData := SE2->E2_VENCTO
Else
	dData := DataValida(SE2->E2_VENCTO,.T.)
End
Return dData


//-------------------------------------------------------------------------------
/*/{Protheus.doc} F030TipoIN
Monta a expressão do NOT IN da query

@param cTipos Tipos de titulos a serem desconsiderados para o processo

@author Mauricio Pequim Jr
@since  06/11/2019
@version 12.1.7
/*/
//-------------------------------------------------------------------------------

Function F030TipoIN(cTipos As Character)

Default cTipos := MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM
Default lQryIn := .T.

cTipos	:=	StrTran(cTipos,',','/')
cTipos	:=	StrTran(cTipos,';','/')
cTipos	:=	StrTran(cTipos,'|','/')
cTipos	:=	StrTran(cTipos,'\','/')

If lQryIn
	cTipos := Formatin(cTipos,"/")
Endif

Return cTipos
