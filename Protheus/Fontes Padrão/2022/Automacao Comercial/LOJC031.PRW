#INCLUDE "LOJC031.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE P_TROCOENT         1
#DEFINE P_TROCOSAI         2
#DEFINE P_PAGAMENTOS       3
#DEFINE P_RECEBIMENTOS     4
#DEFINE P_SANG_DINHEIRO    5
#DEFINE P_SANG_CHEQUE      6
#DEFINE P_SANG_CARTAO      7
#DEFINE P_SANG_VALE        8
#DEFINE P_SANG_CONVENIO    9
#DEFINE P_SANG_FINANCIADO 10 
#DEFINE P_SANG_DEBAUTO    11
#DEFINE P_SANG_OUTROS     12
#DEFINE P_TRANSF_ORIGEM   13
#DEFINE P_TRANSF_DESTINO  14 
#DEFINE P_VEND_DINHEIRO   15
#DEFINE P_VEND_CHEQUE     16
#DEFINE P_VEND_CARTAO     17
#DEFINE P_VEND_VALE       18
#DEFINE P_VEND_CONVENIO   19
#DEFINE P_VEND_FINANCIADO 20
#DEFINE P_VEND_DEBAUTO    21
#DEFINE P_VEND_CREDITO    22
#DEFINE P_VEND_OUTROS     23
#DEFINE P_DEVOLUCAO       24
#DEFINE P_MAXDEFINE       24
#DEFINE P_VEND_CARTFID    25  

Static nMoedaCorAnt 
Static aDadosVenOri
Static aDadosSanOri
Static lR5		:= GetRpoRelease("R5")                                      //Release 11.5 Ativo
Static lLjcFid	:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt() .AND. lR5	//Indica se a recarga de cartao fidelidade esta ativa

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ lojc031	³ Autor ³ Julio Cesar           ³ Data ³ 14/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Resumo do Caixa - Localizado           					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LOJC031()									              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA 												  ³±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lojc031()

Local oDlg		
Local oFnt
Local oFnt2
Local oFnt3
Local oGroup 
Local oTrocoEnt									// Objeto contendo informações sobre o entrada de troco
Local oTrocoSai									// Objeto contendo informações sobre a saida de troco
Local oSaldFinal								// Objeto contendo informações sobre o saldo final
Local oTotCre									// Variavel total do credito
Local oTotDeb                                   // Variavel total do debito
Local oFolder 									// Objeto contendo informações sobre o folder
Local oBntTits
Local nTrocoEnt  := 0							// Variavel contendo informações sobre o troco entrada
Local nTrocoSai  := 0							// Variavel contendo informações sobre o troco saida
Local nTotDeb    := 0							// Variavel contendo informações sobre o debito
Local nTotCre    := 0 							// Variavel contendo informações sobre o credito
Local nSaldFinal := 0            				// Variavel contendo informações sobre o saldo final
Local nMoedaCor  := 1
Local nDecs      := MsDecimais(1)
Local nI         := 0							// Variavel contador
Local aCaixa     := {}							// Array contendo informações do Caixa 
Local aCaixaStr  := {}
Local aMoeda     := {}							// Array contendo informações da moeda
Local cMoeda     := Space(10)					// Variaval contendo informação da moeda	
Local cNomeCxa   := Space(30)					// Variaval Nome do Caixa
Local cPicture   := PesqPict("SL1","L1_VLRTOT",16,nMoedaCor)  // Variavel contendo mascara do campo L1_VLRTOT
Local cArrayFoc  := ""  			 			// Determina o array que esta com o foco 
Local aFields    := {}                         // Array contendo arquivos
Local aTitles	 := {	STR0041,; 				// "Total Geral na Moeda Corrente"
                      	STR0042 } 				// "Totais por Moeda"                      
Local cNomFilDe	 := ""                      	// Nome da filial "Filial De"
Local cNomFilAte := ""                      	// Nome da filial "Filial Ate"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena a posicao de todas as areas utilizadas...³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAreaAtu   := GetArea()
Local aAreaSA6   := SA6->(GetArea())
Local aAreaSD1   := SD1->(GetArea())
Local aAreaSE5   := SE5->(GetArea())
Local aAreaSE1   := SE1->(GetArea())
Local aAreaSL1   := SL1->(GetArea())
Local aAreaSL4   := SL4->(GetArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Protege rotina para que seja usada apenas no SIGALOJA / Front Loja³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !AmIIn(12,23,72)
	Return(.F.)
Endif                     	
                      	
Private oMovVen
Private oMovSan
Private oMovGer
Private oCbx
Private aDadosVen := {{"",0}}
Private aDadosSan := {{"",0}}              
Private aDadosGer := {}
Private aDDownE   := Array(12)	//Contem o 2o. nivel das opcoes 
Private aDDownS   := Array(12)	//Contem o 2o. nivel das opcoes
Private aFormaEnt := {} 
Private aFormaSai := {}
Private cCaixa    := "   "
Private dDataMovto:= dDataBase
Private lQuery    := .F.

#IFDEF TOP
	If TCSrvType() <> "AS/400"
		lQuery := .T.
	Endif
#Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - De Data            ?                              ³
//³ mv_par02 - Ate Data           ?                              ³
//³ mv_par03 - De Caixa           ?                              ³
//³ mv_par04 - Ate Caixa          ?                              ³
//³ mv_par05 - De Filial          ?                              ³
//³ mv_par06 - Ate Filial         ?                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Pergunte("LJC031",.T.)
	Return(NIL)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valoriza o Array aFields...³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aFields,STR0037) //"Moneda"
AAdd(aFields,STR0005) //"Saldo Inicial"
AAdd(aFields,STR0038) //"Ingresos"
AAdd(aFields,STR0039) //"Egresos"
If SuperGetMV("MV_LJTRLOC",,.F.)
	AAdd(aFields,STR0040) //"Sal. de Vuelto"
Endif
AAdd(aFields,STR0018) // "Saldo Final"

For nI := 1	To MoedFin()
	If !Empty(SuperGetMV("MV_MOEDA"+Str(nI,1)))
		AAdd(aMoeda,SuperGetMV("MV_MOEDA"+Str(nI,1))) 
		AAdd(aDadosGer,{nI,SuperGetMV("MV_MOEDA"+Str(nI,1))+"("+SuperGetMV("MV_SIMB"+Str(nI,1))+")",;
		                0,0,0,0,0,PesqPict("SL1","L1_VLRTOT",16,nI)})
	Else
		Exit
	Endif
Next nI

Ljc031Fil(@cNomFilDe, @cNomFilAte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Resumo de Caixa³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg FROM 0.1,0.1 TO 482,610 TITLE STR0001 PIXEL OF oMainWnd  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Largura x Altura ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFnt	NAME "Times New Roman" SIZE 9,13 BOLD  
DEFINE FONT oFnt2	NAME "Arial"                     BOLD
DEFINE FONT oFnt3	NAME "Courier New"     
	
@ 001 ,004 TO 037 ,250 LABEL "" OF oDlg  PIXEL

@ 005, 007 SAY STR0048  SIZE 60,10 OF oDlg PIXEL Font oFnt3		// "De Data   :"
@ 005, 070 SAY MV_PAR01 SIZE 42,10 OF oDlg PIXEL RIGHT Font oFnt3
@ 015, 007 SAY STR0049  SIZE 60,10 OF oDlg PIXEL Font oFnt3 	// "De Caixa  :"
@ 015, 070 SAY MV_PAR03 SIZE 42,10 OF oDlg PIXEL RIGHT Font oFnt3
@ 025, 007 SAY STR0050+" "+Alltrim(MV_PAR05)+"-"+Alltrim(cNomFilDe)   SIZE 150,10 OF oDlg PIXEL Font oFnt3		// "De Filial :"  
@ 005, 130 SAY STR0051  SIZE 60,10 OF oDlg PIXEL Font oFnt3		// "Ate Data   :"
@ 005, 200 SAY MV_PAR02 SIZE 42,10 OF oDlg PIXEL RIGHT Font oFnt3
@ 015, 130 SAY STR0052  SIZE 60,10 OF oDlg PIXEL Font oFnt3    // "Ate Caixa  :"
@ 015, 200 SAY MV_PAR04 SIZE 42,10 OF oDlg PIXEL RIGHT Font oFnt3
@ 025, 130 SAY STR0053+" "+Alltrim(MV_PAR06)+"-"+Alltrim(cNomFilAte)  SIZE 150,10 OF oDlg PIXEL Font oFnt3		// "Ate Filial :"  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Creditos (Vendas)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 040, 004 GROUP oGroup TO 158, 152 LABEL STR0002 OF oDlg PIXEL 
oGroup:SetFont(oFnt2)

@ 046, 009 LISTBOX oMovVen FIELDS HEADER "Numerario                     Valor  Qtde de Docs."	SIZE 137, 108 ;
    ON DBLCLICK	LJ031Refresh(oDlg      ,cCaixa     ,@cNomeCxa  ,@nTrocoEnt   ,;
                             @nTrocoSai,@nTotCre   ,@nTotDeb   ,@nSaldFinal  ,;
                             oMovVen   ,oMovSan    ,@aCaixa    ,@aCaixaStr   ,;
                             dDataMovto,oMovVen:nAt,nMoedaCor  ,nDecs        ,;
                             oTotCre   ,oTotDeb    ,oSaldFinal ,oTrocoEnt    ,;
                             oTrocoSai ,"aDadosVen");
    OF oDlg PIXEL FONT oFnt3
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ D‚bitos (Sangrias)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 040, 156 GROUP oGroup TO 158, 303 LABEL STR0003 OF oDlg PIXEL 
oGroup:SetFont(oFnt2)

@ 046, 161 LISTBOX oMovSan FIELDS HEADER "" SIZE 137, 108 ;
    ON DBLCLICK	LJ031Refresh(oDlg      ,cCaixa     ,@cNomeCxa   ,@nTrocoEnt   ,;
                             @nTrocoSai,@nTotCre   ,@nTotDeb    ,@nSaldFinal  ,;
                             oMovVen   ,oMovSan    ,@aCaixa     ,@aCaixaStr   ,;
                             dDataMovto,oMovSan:nAt,nMoedaCor   ,nDecs        ,;
                             oTotCre   ,oTotDeb    ,oSaldFinal  ,oTrocoEnt    ,;
                             oTrocoSai ,"aDadosSan");
    OF oDlg PIXEL FONT oFnt3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta Vetores de Dados de Credito / Debito para ListBox     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMovVen:SetArray(aDadosVen)
oMovVen:bLine := {|| {	aDadosVen[oMovVen:nAt][1] } }
oMovVen:bGotFocus := {||  cArrayFoc := "aDadosVen" } 
oMovSan:SetArray(aDadosSan)
oMovSan:bLine := {|| {	aDadosSan[oMovSan:nAt][1] } }
oMovSan:bGotFocus := {||  cArrayFoc := "aDadosSan" }

//                        LI  CI                              QC  QL
oFolder := TFolder():New(162,004,aTitles,{},oDlg,,,, .T., .F.,299,076,)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                  ³
//³Dados do Folder 1 ³
//³                  ³
//³Total de Cr‚ditos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 006, 004 GROUP oGroup TO 022, 147  LABEL STR0014 OF oFolder:aDialogs[1] PIXEL  
oGroup:SetFont(oFnt2)

@ 012, 078 SAY oTotCre PROMPT Transform(nTotCre, cPicture) SIZE 64, 10 OF oFolder:aDialogs[1];
PIXEL RIGHT FONT oFnt COLOR CLR_HRED
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Total de D‚bitos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 006, 151 GROUP oGroup TO 022,296  LABEL STR0017 OF oFolder:aDialogs[1] PIXEL
oGroup:SetFont(oFnt2)

@ 012, 225 SAY oTotDeb PROMPT Transform(nTotDeb, cPicture) SIZE 64, 10 OF oFolder:aDialogs[1];
PIXEL RIGHT FONT oFnt COLOR CLR_HRED
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Saldo Inicial³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 024, 004 GROUP oGroup TO 040, 147 LABEL STR0005 OF oFolder:aDialogs[1] PIXEL  
oGroup:SetFont(oFnt2)

@ 030, 078 SAY oTrocoEnt VAR Transform(nTrocoEnt, cPicture) SIZE 64, 10 OF oFolder:aDialogs[1];
PIXEL RIGHT FONT oFnt COLOR CLR_HRED

If !(SuperGetMV("MV_LJTRLOC",,.F.))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Saldo Final³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 024, 151 GROUP oGroup TO 040, 296 LABEL STR0018 OF oFolder:aDialogs[1] PIXEL
	oGroup:SetFont(oFnt2)

	@ 030, 225 SAY oSaldFinal PROMPT Transform(nSaldFinal, cPicture) SIZE 64, 12 OF oFolder:aDialogs[1];
	PIXEL RIGHT FONT oFnt COLOR CLR_HRED
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Saida de Troco ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 024, 151 GROUP oGroup TO 040, 296 LABEL STR0035 OF oFolder:aDialogs[1] PIXEL
	oGroup:SetFont(oFnt2)
	
	@ 030, 225 SAY oTrocoSai PROMPT Transform(nTrocoSai, cPicture) SIZE 64, 12 OF oFolder:aDialogs[1];
	PIXEL RIGHT FONT oFnt COLOR CLR_HRED
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Saldo Final³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 042, 151 GROUP oGroup TO 058, 296 LABEL STR0018 OF oFolder:aDialogs[1] PIXEL
	oGroup:SetFont(oFnt2)

	@ 048, 225 SAY oSaldFinal PROMPT Transform(nSaldFinal, cPicture) SIZE 64, 12 OF oFolder:aDialogs[1];
	PIXEL RIGHT FONT oFnt COLOR CLR_HRED
Endif
//ÚÄÄÄÄÄÄÄ¿
//³ Moeda:³
//ÀÄÄÄÄÄÄÄÙ
@ 48,004 SAY STR0034   SIZE 49, 10 OF oFolder:aDialogs[1] PIXEL   
@ 48, 025 COMBOBOX oCBX VAR cMoeda ITEMS aMoeda ON CHANGE (nMoedaCor:=oCBX:nAt,;
                                                           nDecs:=MsDecimais(nMoedaCor),;
												           cPicture := PesqPict("SL1","L1_VLRTOT",16,nMoedaCor),;
												           LJ031Refresh(oDlg      ,cCaixa    ,@cNomeCxa    ,@nTrocoEnt ,;
												           				@nTrocoSai,@nTotCre  ,@nTotDeb     ,@nSaldFinal,;
												           				oMovVen   ,oMovSan   ,@aCaixa      ,@aCaixaStr ,;
												           				dDataMovto,          ,nMoedaCor    ,nDecs      ,;
												           				oTotCre   ,oTotDeb   ,oSaldFinal   ,oTrocoEnt  ,;
												           				oTrocoSai ));
												SIZE 50,50 OF oFolder:aDialogs[1] PIXEL

@ 47,090 BUTTON oBntTits PROMPT STR0061 SIZE 40,13 ACTION Lj031Titulos(nMoedaCor,nDecs,cPicture,dDataMovto,cArrayFoc) OF oFolder:aDialogs[1] PIXEL //"Exhibir Titulos"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados do Folder 2 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//                        LS  CI  CG  LI
oMovGer := TWBrowse():New(006,004,290,055,,aFields,,oFolder:aDialogs[2],,,,,,,,,,,,.F.,,.T.,,.F.,,,)

oMovGer:SetArray(aDadosGer)                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configura os dados contidos no Array aDadosGer para que os mesmos possam³
//³ser exibidos no objeto oMovGer...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Lj031BLine(@oMovGer,aDadosGer) 

@ 0.0, 63 BUTTON STR0019 SIZE 50,11 FONT oDlg:oFont ACTION Lj031Imp(aCaixa,aCaixaStr,nMoedaCor,aFields)  OF oDlg	// Imprimir
@ 1.2, 63 BUTTON STR0033 SIZE 50,11 FONT oDlg:oFont ACTION ExecBlock('Lj030ECF') WHEN (!Empty(aCaixa) .AND. lFiscal .AND. ExistBlock('Lj030ECF')) OF oDlg 	// Imprimir ECF
@ 2.5, 63 BUTTON STR0020 SIZE 50,11 FONT oDlg:oFont ACTION (Lj031Sair(),oDlg:End()) OF oDlg CANCEL	// Sair

ACTIVATE MSDIALOG oDlg ON INIT LJ031Refresh(oDlg      ,cCaixa   ,@cNomeCxa   ,@nTrocoEnt   ,;
                                            @nTrocoSai,@nTotCre ,@nTotDeb    ,@nSaldFinal  ,;
                                            oMovVen   ,oMovSan  ,@aCaixa     ,@aCaixaStr   ,;
                                            dDataMovto,         ,nMoedaCor   ,nDecs        ,;
                                            oTotCre   ,oTotDeb  ,oSaldFinal  ,oTrocoEnt    ,;
                                            oTrocoSai) VALID Lj031Sair(oDlg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados						     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSA6)
RestArea(aAreaSD1)
RestArea(aAreaSE5)
RestArea(aAreaSE1)
RestArea(aAreaSL1)
RestArea(aAreaSL4)
RestArea(aAreaAtu) 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LJ031Imp ³ Autor ³ Julio Cesar           ³ Data ³ 14/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao do Fechamento do Caixa        					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³Lj031Imp(ExpA1,ExpA2,ExpN1,ExpA3)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os totais por tipo de entrada/saida      ³±±
±±³          ³ ExpA2 = Descricao da posicao do array aCaixa               ³±±
±±³          ³ ExpN1 = Moeda corrente do relatorio         			      ³±± 
±±³          ³ ExpA3 = Cabecalho do total geral por moedas                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJC031                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cleber M. ³13/05/05³811   ³QNC: 001818/2005-00 Abre a tela de setup    ³±±
±±³          ³        ³      ³caso nao encontre a impressora local	      ³±±
±±³          ³        ³      ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj031Imp( aCaixa  ,aCaixaStr  ,nMoedaCor  ,aFields  )

Local lPrinter := .F.
Private oPrint, oFont, oFont1
                                                       
//Caso o array aCaixa esteja vazio a rotina eh abortada...                 
If Empty(aCaixa)
	Return
Endif                 
oFont  := TFont():New("Courier New",,14,,.T.,,,,.T.,)
oFont1 := TFont():New("Courier New",,10,,,,,,,)
oFont2 := TFont():New("Courier New",,10,,.T.,,,,,)

oPrint := TMSPrinter():New( STR0021 )
//Verifica se existe alguma impressora conectada...
lPrinter:= oPrint:IsPrinterActive()   
                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso nao encontre a impressora conectada localmente,³
//³abre a tela para escolha de impressora de rede      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lPrinter
	oPrint:Setup()
Endif

If ! oPrint:IsPrinterActive()
	MsgInfo(STR0047) //"No existe ninguna impresora conectada en la computadora, por eso no es posible realizar la impresion del informe"
	Return
Endif	
oPrint:SetPortrait()

LJMsgRun(STR0043,,{|| Lj031ImpTe(aCaixa,aCaixaStr,nMoedaCor,aFields)}) //"Preparando los datos para impresion ..."

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o	  ³Lj031ImpTe³ Autor ³ Julio Cesar   	     ³ Data ³ 14/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Impressao do fechamento do caixa		                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³Lj031ImpTe(ExpA1,ExpA2,ExpN1,ExpA3)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 = Array com os totais por tipo de entrada/saida      ³±±
±±³           ³ ExpA2 = Descricao da posicao do array aCaixa               ³±±
±±³           ³ ExpN1 = Moeda corrente do relatorio         			   ³±± 
±±³           ³ ExpA3 = Cabecalho do total geral por moedas                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³ LOJC031                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj031ImpTe( aCaixa   ,aCaixaStr   ,nMoedaCor   ,aFields )

Local nCol
Local nColFim
Local nColIni
Local nLin
Local nI
Local nA
Local nJ
Local nLinBox
Local nLinIni
Local nTrocoEnt   := 0
Local nTrocoSai   := 0
Local nTotCredito := 0 
Local nTotDebito  := 0
Local nSaldFinal  := 0
Local nTam        := 0
Local nPosMoeda   := 0                //Moeda a ser considerada na picture na impressao da consulta
Local cPicture    := PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)
Local cMoedaCor   := SuperGetMV("MV_MOEDA"+Str(nMoedaCor,1))+" ("+SuperGetMV("MV_SIMB"+Str(nMoedaCor,1))+")"
Local aDadosSBkp := aClone(aDadosSan)
Local aDadosVBkp := aClone(aDadosVen)    
Local aMoeda      := {}              //Array com os nomes das moedas na comparacao para determinar a picture do valor impresso
Local cDados     := ""
Local cCxOrig    := "" 
Local cCxDest    := "" 
Local cMaskVlr   := ""              //Picture que considera a moeda 
Local cNomeMoeda := ""              //Nome da moeda usado na comparacao para determinar a picture do valor impresso

For nI := 1	To MoedFin()
	If(!(Empty(&("MV_MOEDA"+Str(nI,1)))))
		AAdd(aMoeda,UPPER(ALLTRIM(&("MV_MOEDA"+Str(nI,1))))) 
	Else
		Exit
	Endif
Next nI

nColIni  := 50		// Coluna inicial                      
nColFim  := 2000	// Coluna final
nSalto   := 40		// Salto de uma linha a outra

// Alimenta Totalizadores / Array aDadosVen / Array aDadosSan...
aDadosVen := aClone(aDadosVenOri)
aDadosSan := aClone(aDadosSanOri)
For nA := 1 To 2
	cDados := If(nA==1,"aDadosVen","aDadosSan")  
	cDDown := If(nA==1,"aDDownE","aDDownS")
	nTam   := Len(&cDados.)
	
	For nI := 1 To Len(&cDDown.)
		If !Empty(&cDDown.[nI])
			nTam += Len(&cDDown.[nI])
			For nJ := 1 To Len(&cDDown.[nI])
				If Len(&cDDown.[nI,nJ]) == 3
					nTam += Len(&cDDown.[nI,nJ,3])
				Endif
			Next nJ
		Endif
	Next nI     
	
	For nI := 1 To nTam
		Lj031Dados(aCaixa      ,aCaixaStr   ,@nTrocoEnt   ,@nTrocoSai   ,;
		           @nTotCredito,@nTotDebito ,@nSaldFinal  ,nI           ,;
		           cDados      ,nMoedaCor)
	Next nI
Next nA
        
SA6->(DbSetOrder(1))
If SA6->(DbSeek(xFilial("SA6")+MV_PAR03))         
   cCxOrig  := Substr(SA6->A6_NOME,1,20)
Endif
If SA6->(DbSeek(xFilial("SA6")+MV_PAR04))         
   cCxDest  := Substr(SA6->A6_NOME,1,20)
Endif  

// Inicia a impressao da pagina
oPrint:StartPage()

// Imprime o cabecalho                            
oPrint:SetFont(oFont)
oPrint:Say( 110, 030, PadC( Upper(STR0021)+STR0044+cMoedaCor, 65 ) ) //" - En "

oPrint:SetFont(oFont1)
oPrint:Line( 160, nColIni, 160, nColFim )
oPrint:Say( 180, 100, STR0055 + " " + MV_PAR03 + " - " + cCxOrig)  //"De  Caixa: "	
oPrint:Say( 180, 900, STR0056 + " " + MV_PAR04 + " - " + cCxDest)  //"Ate Caixa: " 					
oPrint:Say( 215, 100, STR0057 + " " + DtoC( MV_PAR01 ) )  //"De  Data: "
oPrint:Say( 215, 900, STR0058 + " " + DtoC( MV_PAR02 ) )  //"Ate Data: " 					
oPrint:Say( 250, 100, STR0059 + " " + MV_PAR05 )  //"De  Filial: "
oPrint:Say( 250, 900, STR0060 + " " + MV_PAR06 )  //"Ate Filial: " 					


oPrint:Line( 300, nColIni, 300, nColFim )
oPrint:Say( 320, 100, STR0024 + Transform( nTrocoEnt, cPicture ) )

If SuperGetMV("MV_LJTRLOC",,.F.)
	oPrint:Say( 360, 100, STR0036 + Transform( nTrocoSai, cPicture ) )
Endif

// Imprime os dados de venda
oPrint:Line( 400, nColIni, 400, nColFim )
oPrint:Say( 420, 100, STR0025 + Transform( nTotCredito, cPicture ) )

nLin := 470

For nI := 1 To Len(aDadosVen)
    cNomeMoeda  := UPPER(ALLTRIM(Left(aDadosVen[nI][1],23)))
    nPosMoeda   := Ascan(aMoeda,{|x| x == cNomeMoeda}) 
    If nPosMoeda > 0
       cMaskVlr    := PesqPict("SL1","L1_VLRTOT",14,nPosMoeda)
    Else
       cMaskVlr    := PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)          
    Endif   
	nPosSin := At("-",aDadosVen[nI][1])
  	If nPosSin == 3
		oPrint:Say( nLin, 100, PadR(PadR(aDadosVen[nI][1],23," ")+" ",40,".")+Transform(aDadosVen[nI][2], cMaskVlr))
	ElseIf SubStr(aDadosVen[nI][1],3,1) == " "                                                                               
		oPrint:Say( nLin, 100, PadR(PadR(aDadosVen[nI][1],23," ")+" ",26,".")+Transform(aDadosVen[nI][2], cMaskVlr))
	Else	
		oPrint:Say( nLin, 100, PadR(Left(aDadosVen[nI][1],23)+" ",54,".")+Transform(aDadosVen[nI][2], cMaskVlr))
	Endif
	nLin += nSalto

	If nLin >= 3000                                 
		nLin := 3000
		// Monta a borda de fora pois neste momento sabemos qual a linha final
		oPrint:Line( 100, nColIni, 100, nColFim )
		oPrint:Line( nLin, nColIni, nLin, nColFim )
		oPrint:Line( 100, nColIni, nLin, nColIni )
		oPrint:Line( 100, nColFim, nLin, nColFim )
		nLin := 110
		oPrint:EndPage()
	Endif
Next nI     

// Imprime os dados de Sangria
nLin += nSalto
oPrint:Line( nLin, nColIni, nLin, nColFim )
nLin += nSalto
oPrint:Say( nLin, 100, STR0026 + Transform( nTotDebito, cPicture ) )
nLin += (nSalto + 10)

For nI := 1 To Len(aDadosSan)
    cNomeMoeda  := UPPER(ALLTRIM(Left(aDadosSan[nI][1],23)))
    nPosMoeda   := Ascan(aMoeda,{|x| x == cNomeMoeda}) 
    If nPosMoeda > 0
       cMaskVlr    := PesqPict("SL1","L1_VLRTOT",14,nPosMoeda)
    Else
       cMaskVlr    := PesqPict("SL1","L1_VLRTOT",14,nMoedaCor)          
    Endif   
	nPosSin := At("-",aDadosSan[nI][1])
	If SubStr(aDadosSan[nI][1],3,1) == " "                                                                               
		oPrint:Say( nLin, 100, PadR(PadR(aDadosSan[nI][1],23," ")+" ",40,".")+Transform(aDadosSan[nI][2], cMaskVlr))
	Else	
		oPrint:Say( nLin, 100, PadR(Left(aDadosSan[nI][1],23)+" ",54,".")+Transform(aDadosSan[nI][2], cMaskVlr))
	Endif
	nLin += nSalto
	
	If nLin >= 3000                                 
		nLin := 3000
		// Monta a borda de fora pois neste momento sabemos qual a linha final
		oPrint:Line( 100, nColIni, 100, nColFim )
		oPrint:Line( nLin, nColIni, nLin, nColFim )
		oPrint:Line( 100, nColIni, nLin, nColIni )
		oPrint:Line( 100, nColFim, nLin, nColFim )
		nLin := 110
		oPrint:EndPage()
	Endif
Next nI

nLin += nSalto
oPrint:Line( nLin, nColIni, nLin, nColFim )
nLin += nSalto
oPrint:Say( nLin, 100, STR0027 + Transform( nSaldFinal, cPicture ) )
nLin += (nSalto + 10)                      

// Monta a borda de fora pois neste momento sabemos qual a linha final
oPrint:Line( 100, nColIni, 100, nColFim )
oPrint:Line( nLin, nColIni, nLin, nColFim )
oPrint:Line( 100, nColIni, nLin, nColIni )
oPrint:Line( 100, nColFim, nLin, nColFim )

nLin    += (nSalto + 100)                      
nLinBox := nLin
nCol    := 100                               

oPrint:SetFont(oFont)
oPrint:Say( nLin, 030, PadC( STR0045, 65 ) ) //"Ingresos/Egresos/Saldo en todas las Monedas"
oPrint:SetFont(oFont1)

nLin    += (nSalto*2)
nLinIni := nLin
oPrint:Line( nLin, nColIni, nLin, nColFim )
nLin    += nSalto

For nI := 1 To Len(aFields)
	oPrint:Say( nLin, nCol, PadR(aFields[nI],15,""))
	nCol += If(nI == 1,245,320)
Next nI

nLin += nSalto
oPrint:Line( nLin, nColIni, nLin, nColFim )
nLin += nSalto

For nI := 1 To Len(aDadosGer)
	oPrint:Say( nLin,  100, aDadosGer[nI][2])
	oPrint:Say( nLin,  300, Transform(aDadosGer[nI][3],aDadosGer[nI][8]))
	oPrint:Say( nLin,  600, Transform(aDadosGer[nI][4],aDadosGer[nI][8]))
	oPrint:Say( nLin,  900, Transform(aDadosGer[nI][5],aDadosGer[nI][8]))
	If SuperGetMV("MV_LJTRLOC",,.F.)
		oPrint:Say( nLin, 1200, Transform(aDadosGer[nI][6],aDadosGer[nI][8]))
		oPrint:Say( nLin, 1580, Transform(aDadosGer[nI][7],aDadosGer[nI][8]))
	Else
		oPrint:Say( nLin, 1200, Transform(aDadosGer[nI][7],aDadosGer[nI][8]))
	Endif
	If nI < Len(aDadosGer)
		nLin += nSalto
		oPrint:Line( nLin, nColIni, nLin, nColFim )
	Endif
	nLin += nSalto
Next nI

nCol := 330                               
For nI := 1 To (Len(aFields)-1)
	oPrint:Line( nLinIni, nCol, nLin, nCol )
	nCol += 325
Next nI

// Monta a borda de fora pois neste momento sabemos qual a linha final
oPrint:Line( nLinBox, nColIni, nLinBox, nColFim )
oPrint:Line( nLin, nColIni, nLin, nColFim )
oPrint:Line( nLinBox, nColIni, nLin, nColIni )
oPrint:Line( nLinBox, nColFim, nLin, nColFim )

oPrint:EndPage()

oPrint:Preview()      

//Restaura os arrays originais
aDadosVen := aClone(aDadosVBkp)
aDadosSan := aClone(aDadosSBkp)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o	  ³MovimCxLoc³ Autor ³ Julio Cesar  	     ³ Data ³ 14/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³Carrega array com valores totais do caixa em uma data       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³MovimCxLoc(ExpA1,ExpA2,ExpC1,ExpD1,ExpN1,ExpN2)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 = Array com os totais por tipo de entrada/saida      ³±±
±±³           ³ ExpA2 = Descricao da posicao do array aCaixa               ³±±
±±³           ³ ExpC1 = Codigo do caixa                                    ³±±
±±³           ³ ExpD1 = Data do movimento                                  ³±±
±±³           ³ ExpN1 = Moeda corrente do relatorio         			   ³±± 
±±³           ³ ExpN2 = Qtde de decimais da moeda corrente                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³ SIGALOJA                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³  DATA     ³ BOPS ³Program.³    ALTERACAO                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³09/11/06   ³111921³Marcos R³Alteracao para corrigir error.log na utiliza³±±
±±³           ³      ³        ³cao das casas decimais da moeda referente a ³±±
±±³           ³      ³        ³a parcela, onde o sistema pegava o codigo da³±±
±±³           ³      ³        ³administrador e nao o da moeda.             ³±±
±±³28/06/07   ³127773³Norbert ³Verifica se o tipo da movimentacao financei-³±±
±±³           ³      ³        ³ra (SE5) antes de somar o valor ao total dos³±±
±±³           ³      ³        ³recebimentos.                               ³±±
±±³           ³      ³        ³Na chamada da funcao LJ031TotFormas, o nume-³±±   
±±³           ³      ³        ³ro do registro (Recno) estava incorreto     ³±±
±±³           ³      ³        ³quando a rotina utiliza queries.            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function MovimCxLoc( aCaixa   ,aCaixaStr   ,cCaixa   ,dDataMovto  ,;
                     nMoedaCor,nDecs        )

Local bTab      	:= {|x| Space(16 - Len(x))}
Local cNumero   	:= ""
Local cForma    	:= ""
Local cTipMov   	:= ""
Local cPicture  	:= PesqPict("SL1","L1_BASIMP1",14,nMoedaCor)
Local cCpoImps  	:= ""
Local nTxMoeda  	:= 0							
Local nForma		:= 0		
Local nMoeda    	:= 1
Local nSe5Valor 	:= 0
Local nI        	:= 0
Local nJ        	:= 0
Local nA        	:= 0
Local nPos      	:= 0
Local nTotImps  	:= 0
Local lAdm      	:= .F.
Local lLJC031SL1	:= ExistBlock("LJC031SL1") //Variaveis que verificam a existencia dos
Local lLJC031SE5	:= ExistBlock("LJC031SE5") //PEs que manipulam a consulta do resumo de
Local lLJC031SE1	:= ExistBlock("LJC031SE1") //caixa...
Local lLJC031SD1	:= ExistBlock("LJC031SD1")
Local aTesImpInf	:= {}
Local lOk       	:= .F.
Local lExprCanc 	:= .F.
Local aCaixaQtde	:= {}      
Local nMoedaTit		:= 1						//Utilizada para configurar as casas decimais conforme a moeda da parcela.
Local nRegistro		:= 0
Local nFormOp		:= 0 // Guarda Valor do Define para poder verificar Versão.
Local cMvTpRet		:= SuperGetMV("MV_LJCTRET",,"RI|RG|RB|RS")
 
Private	cDados    	:= ""
Private cDDown    	:= ""
Private aValFormaE	:= Array(12) 
Private aValFormaS	:= Array(12)
Private cDeFilSE5	:= "" 
Private	cAteFilSE5	:= "" 
Private	cDeFilSL1	:= "" 
Private	cAteFilSL1	:= "" 
Private	cDeFilSE1	:= "" 
Private	cAteFilSE1	:= "" 
Private	cDeFilSD1	:= "" 
Private	cAteFilSD1	:= ""
Private cQuery		:= "" 
Private cSubQuery	:= ""
Private lUsaParam  	:= Empty(cCaixa)
Private cAlias		:=""

Default nMoedaCor 	:= 1
Default nDecs     	:= MsDecimais(1)
Default dDataMovto	:= dDataBase

If lUsaParam
	cDeFilSE5  := If(LjxEMod("SE5"), Space(FWGETTAMFILIAL), MV_PAR05)	// Calcula a "De Filial" do SE5
	cAteFilSE5 := If(LjxEMod("SE5"), Space(FWGETTAMFILIAL), MV_PAR06)	// Calcula a "Ate Filial" do SE5
	cDeFilSL1  := If(LjxEMod("SL1"), Space(FWGETTAMFILIAL), MV_PAR05)	// Calcula a "De Filial" do SL1
	cAteFilSL1 := If(LjxEMod("SL1"), Space(FWGETTAMFILIAL), MV_PAR06)	// Calcula a "Ate Filial" do SL1
	cDeFilSE1  := If(LjxEMod("SE1"), Space(FWGETTAMFILIAL), MV_PAR05)	// Calcula a "De Filial" do SE1
	cAteFilSE1 := If(LjxEMod("SE1"), Space(FWGETTAMFILIAL), MV_PAR06)	// Calcula a "Ate Filial" do SE1
	cDeFilSD1  := If(LjxEMod("SD1"), Space(FWGETTAMFILIAL), MV_PAR05)	// Calcula a "De Filial" do SD1
	cAteFilSD1 := If(LjxEMod("SD1"), Space(FWGETTAMFILIAL), MV_PAR06)	// Calcula a "Ate Filial" do SD1
Else
	cDeFilSE5  := xFilial("SE5")
	cAteFilSE5 := xFilial("SE5")
	cDeFilSL1  := xFilial("SL1")
	cAteFilSL1 := xFilial("SL1")
	cDeFilSE1  := xFilial("SE1")
	cAteFilSE1 := xFilial("SE1")
	cDeFilSD1  := xFilial("SD1")
	cAteFilSD1 := xFilial("SD1")
Endif

// Inicializa vetor que armazena os subitens dos itens do ListBox de Vendas
For nI:=1 To Len(aDDownE)
	aDDownE[nI]    := {}
	aDDownS[nI]    := {}	
	aValFormaE[nI] := {}  
	aValFormaS[nI] := {} 
Next	

aCaixa    := {}
aCaixaStr := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄH¿
//³Carto Fidelidade e Versão 11.5 Ativa.                       ³
//³Realiza o For até o valor do Define de Cartao Fidelidade que³
//³esta na posição 25. para que seja exibido.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄHÙ
If lLjcFid
	nFormOp := P_VEND_CARTFID 
Else
	nFormOp := P_MAXDEFINE
End

For nI := 1 To nFormOp
	AAdd(aCaixa, 0)
	AAdd(aCaixaQtde, 0)
	AAdd(aCaixaStr, "")
Next

aFormaEnt := {}
AAdd(aFormaEnt,{SuperGetMV("MV_SIMB1"),P_VEND_DINHEIRO}) 
AAdd(aFormaEnt,{"CC",P_VEND_CARTAO})
AAdd(aFormaEnt,{"CD",P_VEND_DEBAUTO})
AAdd(aFormaEnt,{"CO",P_VEND_CONVENIO})
AAdd(aFormaEnt,{"FI",P_VEND_FINANCIADO})	 
AAdd(aFormaEnt,{"VA",P_VEND_VALE})
AAdd(aFormaEnt,{"CH",P_VEND_CHEQUE})	 
AAdd(aFormaEnt,{"OU",P_VEND_OUTROS})
AAdd(aFormaEnt,{"CR",P_VEND_CREDITO})	 
AAdd(aFormaEnt,{"RC",P_RECEBIMENTOS})  
AAdd(aFormaEnt,{"TD",P_TRANSF_DESTINO})  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cartao Fidelidade Ativo e Versão 11.5                  ³
//³Inclui a Forma de Pagamento Cartao Fidelidade no Array.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLjcFid
	AAdd(aFormaEnt,{"FID",P_VEND_CARTFID})  
EndIf

aFormaSai := {}
AAdd(aFormaSai,{"$" ,P_SANG_DINHEIRO}) 
AAdd(aFormaSai,{"CC",P_SANG_CARTAO})
AAdd(aFormaSai,{"CD",P_SANG_DEBAUTO})
AAdd(aFormaSai,{"CO",P_SANG_CONVENIO})
AAdd(aFormaSai,{"FI",P_SANG_FINANCIADO})	 
AAdd(aFormaSai,{"VA",P_SANG_VALE})
AAdd(aFormaSai,{"CH",P_SANG_CHEQUE})	 
AAdd(aFormaSai,{"OU",P_SANG_OUTROS})
AAdd(aFormaSai,{"DV",P_DEVOLUCAO})	 
AAdd(aFormaSai,{"PG",P_PAGAMENTOS})  
AAdd(aFormaSai,{"TO",P_TRANSF_ORIGEM})  

cCaixa     := SubStr(cCaixa,1,3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Leitura do SE5 para considerar: Sangria, Troco e Movimenta-³
//³ ‡”es banc rias.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery
	Lj031MQuery("SE5")
	cAlias := "SE5TMP"
Else
	DbSelectArea("SE5")
	DbSetOrder(1)
	If lUsaParam
		DbSeek(cDeFilSE5 + DToS( MV_PAR01 ), .T. ) // Filial + Data
	Else
		DbSeek(xFilial()+Dtos(dDataMovto)+cCaixa)	// Filial + Data + Caixa
	Endif            
	cAlias := "SE5"
Endif

While !Eof() .AND. 	Iif(!lQuery	,E5_FILIAL >= cDeFilSE5 .AND.;
								 E5_FILIAL <= cAteFilSE5.AND.;
								 If(lUsaParam, .T., DToS(E5_DATA)+E5_BANCO == DToS(dDataMovto)+cCaixa),.T.)

	If !lQuery	
		If lUsaParam .AND. !(E5_DATA >= MV_PAR01 .AND.;
			 E5_DATA   <= MV_PAR02 .AND.;
			 E5_BANCO  >= MV_PAR03 .AND.;
			 E5_BANCO  <= MV_PAR04)
			DbSkip()
			Loop
		Endif

		IF E5_SITUACA == "C" .OR. E5_MOEDA == "ES"
			// Estorno ou cancelado
			DbSkip()
			Loop
		Endif
	Endif
	                     
	//Verifica se tem cancelamento para este titulo. Nao verificar se for Lay-Away porque
	//a exclusao de um titulo do Lay-Away gera estorno e este deve ser mostrado na consulta
	lExprCanc  := TemBxCanc((cAlias)->E5_PREFIXO +(cAlias)->E5_NUMERO+(cAlias)->E5_PARCELA+;
	                        (cAlias)->E5_TIPO    +(cAlias)->E5_CLIFOR+(cAlias)->E5_LOJA   +;
	                        (cAlias)->E5_SEQ      )
	If (IIf(!(cPaisLoc$"EUA|POR" .OR. (cPaisLoc == "MEX" .AND. lR5)),lExprCanc,;
	    IIf((cAlias)->E5_PREFIXO==&(SuperGetMV("MV_LWPREF1")),.F.,lExprCanc)))	
		DbSkip()
		Loop
	Endif  
	
	//Tratamento para Lay-Away, que gera RA(Recebimento Antecipado)
	If IIf ((cPaisLoc$"EUA|POR" .OR. (cPaisLoc == "MEX" .AND. lR5)),(cAlias)->E5_TIPO $ MV_CRNEG .AND. (cAlias)->E5_PREFIXO <> &(SuperGetMV("MV_LWPREF1")),;	
	   (cAlias)->E5_TIPO $ MV_CRNEG) .OR. ((cAlias)->E5_VENCTO > (cAlias)->E5_DATA)
		DbSkip()
		Loop
	Endif	
	
	IF (cAlias)->E5_TIPODOC $ "DC/JR/MT/CM/D2/J2/M2/C2/V2/CP/TL/LJ"  //Valores de Baixas
		DbSkip()
		Loop
	Endif           

	If lLJC031SE5
		//O registro corrente do SE5 deve ser desconsiderado...
		If !ExecBlock("LJC031SE5",.F.,.F.)
			DbSkip()
			Loop
		Endif
	Endif			

	SA6->(DbSetOrder(1))
	SA6->(DbSeek(xFilial("SA6")+(cAlias)->E5_BANCO+(cAlias)->E5_AGENCIA+(cAlias)->E5_CONTA))
	nMoeda := Max(SA6->A6_MOEDA,1)

	// Realiza acerto da data do movimento...
	If Dtos((cAlias)->E5_DATA) <> Dtos(dDataMovto)
		dDataMovto := (cAlias)->E5_DATA
	Endif

    nSe5Valor:= Round(xMoeda((cAlias)->E5_VALOR,nMoeda,nMoedaCor,dDataMovto,nDecs+1,RecMoeda(dDataMovto,nMoeda)),nDecs)
	nPos     := aScan(aDadosGer,{|x| x[1] == nMoeda})
	If (cAlias)->E5_TIPODOC == "TR" .AND. (cAlias)->E5_MOEDA == "TC" .AND. (cAlias)->E5_RECPAG == "R"	// => Saldo inicial
		aCaixa[P_TROCOENT] += nSe5Valor
		aCaixaQtde[P_TROCOENT] += 1
		nForma := 0                         
		If nPos > 0
			//Soma ao total por moeda ==> Saldo Inicial
			aDadosGer[nPos][03] += (cAlias)->E5_VALOR 
		Endif
	ElseIf ((cAlias)->E5_TIPODOC == "VL" .AND. (cAlias)->E5_MOEDA == "TC" .AND. (cAlias)->E5_RECPAG == "P")
		aCaixa[P_TROCOSAI] += nSe5Valor
		aCaixaQtde[P_TROCOSAI] += 1
		nForma := 0                         
		If nPos > 0
			//Soma ao total por moeda ==> Saidas por Troco               
			aDadosGer[nPos][06] += (cAlias)->E5_VALOR
		Endif
	ElseIf ((cAlias)->E5_TIPODOC == "VL" .AND. (cAlias)->E5_MOEDA <> "TC" .AND. (cAlias)->E5_RECPAG <> "P") .OR. Empty((cAlias)->E5_TIPODOC);
	   	.OR. ((cAlias)->E5_TIPODOC == "BA" .AND. (cAlias)->E5_MOEDA <> "TC"  .AND. (cAlias)->E5_MOTBX == "LOJ" .AND. !LjxDMoney( cAlias, (cAlias)->E5_MOEDA, NIL) .AND. !(cAlias)->E5_MOEDA $ cMvTpRet );
		.OR. Iif(cPaisLoc$"EUA|POR",((cAlias)->E5_TIPODOC == "VL" .AND. (cAlias)->E5_MOEDA <> "TC" .AND. AllTrim((cAlias)->E5_TIPO) == "RA"),.F.)  //Baixas dos recebimentos do Lay-Away(Lay-Away cancelado)
	    
		If (cAlias)->E5_RECPAG == "P"
			aCaixa[P_PAGAMENTOS] += nSe5Valor              
			aCaixaQtde[P_PAGAMENTOS] += 1
			nForma := aScan(aFormaSai,{|x| Trim(x[1])=="PG"})
			cTipMov:= "2"
			If nPos > 0
				//Soma ao total por moeda ==> Debitos
				aDadosGer[nPos][05] += (cAlias)->E5_VALOR
			Endif
		ElseIf (cAlias)->E5_RECPAG == "R" .AND. !( Alltrim( (cAlias)->E5_TIPO )$"CH/CC/CD/VA" ) .AND. !IsMoney((cAlias)->E5_TIPO)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento para evitar duplicidade entre recebimento de ³
			//³titulos e baixa automática de titulos FI/CO             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		      If Alltrim( (cAlias)->E5_TIPO ) $ SuperGetMV("MV_LJTPREC", ,"FI/CO") .AND. (LjxDMoney( cAlias, (cAlias)->E5_MOEDA, NIL) .OR. AllTrim((cAlias)->E5_MOEDA) $ "CH/CC/CD/VA/FI/CO" .OR. (cAlias)->E5_MOEDA $ cMvTpRet )
				aCaixa[P_RECEBIMENTOS] += nSe5Valor
				aCaixaQtde[P_RECEBIMENTOS] += 1
				nForma := aScan(aFormaEnt,{|x| Trim(x[1])=="RC"})
				cTipMov:= "1"     
				If nPos > 0    
					//Soma ao total por moeda ==> Creditos
					aDadosGer[nPos][04] += (cAlias)->E5_VALOR
				Endif			
			EndIf			
		Else
			nForma := 0
		Endif
	ElseIf (cAlias)->E5_TIPODOC $ "SG/TR/TE" .AND. (cAlias)->E5_RECPAG == "P"
		If IsMoney((cAlias)->E5_TIPO)		
			aCaixa[P_SANG_DINHEIRO] += nSe5Valor              
			aCaixaQtde[P_SANG_DINHEIRO] += 1
			nForma := aScan(aFormaSai,{|x| Trim(x[1])=="$"})
			cTipMov:= "2"
		ElseIf (cAlias)->E5_MOEDA $ "C1,C2,C3,C4,C5,CH"
			aCaixa[P_SANG_CHEQUE] += nSe5Valor
			aCaixaQtde[P_SANG_CHEQUE] += 1
			nForma := aScan(aFormaSai,{|x| Trim(x[1])=="CH"})
			cTipMov:= "2"
		ElseIf (cAlias)->E5_MOEDA == "CC"
			aCaixa[P_SANG_CARTAO] += nSe5Valor			
			aCaixaQtde[P_SANG_CARTAO] += 1
			nForma := aScan(aFormaSai,{|x| Trim(x[1])==E5_MOEDA})
			cTipMov:= "2"
		ElseIf (cAlias)->E5_MOEDA == "VA" 
			aCaixa[P_SANG_VALE] += nSe5Valor
			aCaixaQtde[P_SANG_VALE] += 1
			nForma := aScan(aFormaSai,{|x| Trim(x[1])==E5_MOEDA})
			cTipMov:= "2"
		ElseIf (cAlias)->E5_MOEDA == "CO"
			aCaixa[P_SANG_CONVENIO] += nSe5Valor
			aCaixaQtde[P_SANG_CONVENIO] += 1
			nForma := aScan(aFormaSai,{|x| Trim(x[1])==E5_MOEDA})
			cTipMov:= "2"
		ElseIf (cAlias)->E5_MOEDA == "FI"
			aCaixa[P_SANG_FINANCIADO] += nSe5Valor
			aCaixaQtde[P_SANG_FINANCIADO] += 1
			nForma := aScan(aFormaSai,{|x| Trim(x[1])==E5_MOEDA})
			cTipMov:= "2"
		ElseIf (cAlias)->E5_MOEDA == "CD"
			aCaixa[P_SANG_DEBAUTO] += nSe5Valor
			aCaixaQtde[P_SANG_DEBAUTO] += 1
			nForma := aScan(aFormaSai,{|x| Trim(x[1])==E5_MOEDA})
			cTipMov:= "2"
		Else
			aCaixa[P_SANG_OUTROS] += nSe5Valor
			aCaixaQtde[P_SANG_OUTROS] += 1
			nForma := aScan(aFormaSai,{|x| Trim(x[1])=="OU"})
			cTipMov:= "2"
		Endif                             
		If nPos > 0
			//Soma ao total por moeda ==> Debitos
			aDadosGer[nPos][05] += (cAlias)->E5_VALOR
		Endif
	ElseIf (cAlias)->E5_TIPODOC $ "TR/TE"
		If (cAlias)->E5_RECPAG == "R" .AND. (cAlias)->E5_MOEDA <> "TC"	// O troco entrou como saldo inicial
			aCaixa[P_TRANSF_DESTINO] += nSe5Valor
			aCaixaQtde[P_TRANSF_DESTINO] += 1
			nForma := aScan(aFormaEnt,{|x| Trim(x[1]) == "TD"})
			cTipMov:= "1"                   
			If nPos > 0                  
				//Soma ao total por moeda ==> Creditos
				aDadosGer[nPos][04] += (cAlias)->E5_VALOR
			Endif
		Else
			nForma := 0
		Endif
	ElseIf (cPaisLoc$"EUA|POR" .OR. (cPaisLoc == "MEX" .AND. lR5)) 
	   If (cAlias)->E5_TIPODOC == "RA" .AND. (cAlias)->E5_RECPAG == "R"  //Recebimentos do Lay-Away
		  aCaixa[P_VEND_OUTROS] += nSe5Valor
		  aCaixaQtde[P_VEND_OUTROS] += 1
		  nForma := aScan(aFormaEnt,{|x| Trim(x[1]) == "OU"})
		  cTipMov:= "1"         
		  If nPos > 0
			 //Soma ao total por moeda ==> Creditos
			 aDadosGer[nPos][04] += (cAlias)->E5_VALOR
		  Endif
       ElseIf (cAlias)->E5_TIPODOC == "ES" .AND. (cAlias)->E5_RECPAG == "P"   //Recebimentos do Lay-Away excluidos		
           aCaixa[P_SANG_OUTROS] += nSe5Valor
           aCaixaQtde[P_SANG_OUTROS] += 1
		   nForma := aScan(aFormaSai,{|x| Trim(x[1])=="OU"})
		   cTipMov:= "2"
    	   aDadosGer[nPos][05] += (cAlias)->E5_VALOR                                         
       Endif
	Else
		nForma := 0
	Endif

	//Gera o array com os subtotais por forma de pagamento...		              
	If nForma > 0
		If lQuery
			nRegistro := (cAlias)->E5_RECNO
		Else
			nRegistro := (cAlias)->(RecNo())
		EndIf
		LJ031TotFormas( cTipMov				,.F.	,nForma		,(cAlias)->E5_VALOR						,;
		                AllTrim(Str(nMoeda)),nMoeda	,nMoedaCor	,MsDecimais(nMoeda)						,;
		                dDataMovto			,"SE5"	,nRegistro	,(cAlias)->E5_CLIFOR+(cAlias)->E5_LOJA	)	
	Endif
	DbSkip()
End

If lQuery
	DbSelectArea("SE5TMP")
	dbCloseArea()

	Lj031MQuery("SL1")
	cAlias   := "SL1TMP"
Else
	DbSelectArea("SL1")
	DbSetOrder(5)
	If lUsaParam
		DbSeek(cDeFilSL1, .T.)	// Filial
	Else
		DbSeek( xFilial() + cCaixa + DToS(dDataMovto))	// Filial + Caixa + Data
	Endif
	cAlias   := "SL1"
Endif

While !Eof() .AND. 	Iif(!lQuery	,L1_FILIAL >= cDeFilSL1 .AND.;
	                             L1_FILIAL <= cAteFilSL1.AND.;
	                             If(lUsaParam, .T., DToS(L1_EMISSAO)+L1_OPERADO == DToS(dDataMovto)+cCaixa),.T.)

	If !lQuery
		If lUsaParam .AND. !(L1_OPERADO >= MV_PAR03 .AND.;
		   L1_OPERADO <= MV_PAR04 .AND.;
		   L1_EMISSAO >= MV_PAR01 .AND.;
		   L1_EMISSAO <= MV_PAR02)
		  
			DbSkip()
			Loop
		Endif
		
		//Caso seja Lay-Away o valor recebido nao deve ser
		//considerado, pois o mesmo ja foi contabilizado
		//no recebimento das respectivas parcelas...
		If (AllTrim(L1_CONDPG) == "LAY") .AND. (AllTrim(L1_FORMPG) == "NF")
			DbSkip()
			Loop
		Endif                                                                  
		     
		// Só deve considerar os orçamentos que já forma finalizados...
		If Empty(L1_DOC)
			DbSkip()
			Loop
		Endif
	Endif

	//O registro corrente do SL1 deve ser desconsiderado...
	If lLJC031SL1
		If !ExecBlock("LJC031SL1",.F.,.F.)
			DbSkip()
			Loop
		Endif
	Endif			
	
	nMoeda     := Max((cAlias)->L1_MOEDA,1)	
    nTxMoeda   := (cAlias)->L1_TXMOEDA		

	// Realiza acerto da data do movimento...
	If Dtos(dDataMovto) <> Dtos((cAlias)->L1_EMISNF)
		dDataMovto := (cAlias)->L1_EMISNF
	Endif
	
	aCaixa[P_VEND_DINHEIRO]		+= Round(xMoeda((cAlias)->L1_DINHEIR,nMoeda,nMoedaCor,dDataMovto,nDecs+1,nTxMoeda),nDecs)
	aCaixa[P_VEND_CHEQUE]		+= Round(xMoeda((cAlias)->L1_CHEQUES,nMoeda,nMoedaCor,dDataMovto,nDecs+1,nTxMoeda),nDecs)
	aCaixa[P_VEND_CARTAO]		+= Round(xMoeda((cAlias)->L1_CARTAO ,nMoeda,nMoedaCor,dDataMovto,nDecs+1,nTxMoeda),nDecs)
	aCaixa[P_VEND_VALE]			+= Round(xMoeda((cAlias)->L1_VALES  ,nMoeda,nMoedaCor,dDataMovto,nDecs+1,nTxMoeda),nDecs)
	aCaixa[P_VEND_CONVENIO]		+= Round(xMoeda((cAlias)->L1_CONVENI,nMoeda,nMoedaCor,dDataMovto,nDecs+1,nTxMoeda),nDecs)
	aCaixa[P_VEND_FINANCIADO]	+= Round(xMoeda((cAlias)->L1_FINANC ,nMoeda,nMoedaCor,dDataMovto,nDecs+1,nTxMoeda),nDecs)
	aCaixa[P_VEND_DEBAUTO] 	 	+= Round(xMoeda((cAlias)->L1_VLRDEBI,nMoeda,nMoedaCor,dDataMovto,nDecs+1,nTxMoeda),nDecs)
	aCaixa[P_VEND_CREDITO] 	 	+= Round(xMoeda((cAlias)->L1_CREDITO,nMoeda,nMoedaCor,dDataMovto,nDecs+1,nTxMoeda),nDecs)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Versao 11.5 e Cartao fidelidade Ativo.                   ³
	//³Adiciona conteudo do L1_CartFid no aCaixa posição 25, com³
	//³valores de operações Cartao Fidelidade.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLjcFid
		aCaixa[P_VEND_CARTFID] 	+= Round(xMoeda((cAlias)->L1_CARTFID ,nMoeda,nMoedaCor,dDataMovto,nDecs+1,nTxMoeda),nDecs)
	EndIf
	aCaixa[P_VEND_OUTROS] 	 	+= Round(xMoeda((cAlias)->L1_OUTROS ,nMoeda,nMoedaCor,dDataMovto,nDecs+1,nTxMoeda),nDecs)

    If (cAlias)->L1_CREDITO > 0    
       	nForma := aScan(aFormaEnt,{|x| Trim(x[1]) == "CR"})    
	   	//Gera o array com os subtotais por forma de pagamento...		              
		If lQuery
			nRegistro := (cAlias)->L1_RECNO
		Else
			nRegistro := (cAlias)->(RecNo())
		EndIf
		LJ031TotFormas("1"								,.F.	,nForma		,(cAlias)->L1_CREDITO	,;
	                  AllTrim(Str((cAlias)->L1_MOEDA))	,nMoeda	,nMoedaCor	,MsDecimais(nMoeda)		,;
	                  dDataMovto						,"SL1"	,nRegistro	,(cAlias)->L1_CLIENTE	+;
	                  (cAlias)->L1_LOJA)
	   	    
       	//Soma ao total por moeda ==> Creditos
	   	nPos := aScan(aDadosGer,{|x| x[1] == (cAlias)->L1_MOEDA})
		If nPos > 0
			aDadosGer[nPos][04] += (cAlias)->L1_CREDITO
		Endif
	Endif   

	// Soh busca a administradora para as opcoes que podem ter administradora relacionada.
	DbSelectArea("SL4")
	DbSetOrder(1)
	If DbSeek(xFilial("SL4")+(cAlias)->L1_NUM)
		While !Eof() .AND. SL4->L4_NUM == (cAlias)->L1_NUM
			cForma   := Iif(IsMoney(SL4->L4_FORMA),SuperGetMV("MV_SIMB1"),Trim(SL4->L4_FORMA))
			nForma   := aScan(aFormaEnt,{|x| Trim(x[1])==cForma})
			If nForma == 0
				cForma := "OU"
				nForma := aScan(aFormaEnt,{|x| Trim(x[1])==cForma})
			Endif
			cCodAdm  := Left(SL4->L4_ADMINIS,3)
			If !Empty(cCodAdm) .AND. (cForma <> "OU")
				SAE->(DbSetOrder(1))
				If SAE->(DbSeek(xFilial("SAE")+cCodAdm))
					lAdm := .T. 
				Else
					lAdm := .F. 		
				Endif
			Else
				lAdm := .F. 		
			Endif
	
			//Soma ao total por moeda ==> Creditos
			nPos   := aScan(aDadosGer,{|x| x[1] == SL4->L4_MOEDA})
			nMoeda := SL4->L4_MOEDA
			If nPos > 0
				aDadosGer[nPos][04] += SL4->L4_VALOR
			Endif					                                     
			//Gera o array com os subtotais por forma de pagamento...		              
			LJ031TotFormas("1"                         ,lAdm     ,nForma         ,SL4->L4_VALOR         ,;
			               AllTrim(Str(SL4->L4_MOEDA)),nMoeda   ,nMoedaCor      ,MsDecimais(nMoeda)    ,;
			               dDataMovto                  ,"SL4"    ,SL4->(RecNo()),(cAlias)->L1_CLIENTE  +;
			               (cAlias)->L1_LOJA)	    
				    
			// Soma o titulo ao array de totais de titulos por forma de pgto...		    
		    aCaixaQtde[aFormaEnt[nForma][2]] += 1
	        DbSkip()
		End        
	Endif
	
	If !lQuery
		DbSelectArea("SL1")
	Else
		DbSelectArea("SL1TMP")
	Endif	                                                       
	DbSkip()
End

// Tratamento das notas de credito (NCC)
If lQuery
	DbSelectArea( "SL1TMP" )
	dbCloseArea()

	Lj031MQuery("SE1")
	cAlias := "SE1TMP"
Else
	DbSelectArea("SE1")
	DbSetOrder(6)
	If lUsaParam
		DbSeek(cDeFilSE1, .T. )	// Filial
	Else
		DbSeek(xFilial() + Dtos(dDataMovto))	// Filial + Data
	Endif
	cAlias := "SE1"
Endif

While !Eof() .AND. Iif(!lQuery	,E1_FILIAL >= cDeFilSE1 .AND. E1_FILIAL <= cAteFilSE1.AND. If(lUsaParam, .T., E1_EMISSAO == dDataMovto),.T.)
                 
	If !lQuery                     
		If lUsaParam .AND. !(E1_EMISSAO >= MV_PAR01 .AND.;
			 E1_EMISSAO <= MV_PAR02)
			DbSkip()
			Loop
		Endif
	Endif                                    
                                                                                          
    If !lQuery
		If lUsaParam
			If	SE1->E1_PORTADO >= MV_PAR03 .AND.;
			  	SE1->E1_PORTADO <= MV_PAR04 .AND.;
			 	SE1->E1_SALDO > 0 .AND. SE1->E1_TIPO == MV_CRNEG
			 	
			 	lOk := .T.
			Endif
		Else
			If	SE1->E1_PORTADO == cCaixa .AND.;
			   	SE1->E1_SALDO > 0 .AND.;
			   	SE1->E1_TIPO == MV_CRNEG
			   	
				lOk := .T.
			Endif
		Endif
	Else
		lOk := .T.
	Endif
                   	
	If lOk	
		If lLJC031SE1
			//O registro corrente do SE1 deve ser desconsiderado...
			If !ExecBlock("LJC031SE1",.F.,.F.)
				DbSkip()
				Loop
			Endif
		Endif			
	
		// Realiza acerto da data do movimento...
		If Dtos(dDataMovto) <> Dtos((cAlias)->E1_EMISSAO)
			dDataMovto := (cAlias)->E1_EMISSAO
		Endif
		
		aCaixa[P_VEND_CREDITO] += Round(xMoeda((cAlias)->E1_SALDO,nMoeda,nMoedaCor,dDataMovto,nDecs+1,RecMoeda(dDataMovto,nMoeda)),nDecs)
		nForma := aScan(aFormaEnt,{|x| Trim(x[1])=="CR"})
		//Gera o array com os subtotais por forma de pagamento...		              
		If lQuery
			nRegistro := (cAlias)->E1_RECNO
		Else
			nRegistro := (cAlias)->(RecNo())
		EndIf
		LJ031TotFormas("1"                              ,.F.    ,nForma		,(cAlias)->E1_VALOR    ,;
		               AllTrim(Str((cAlias)->E1_MOEDA)),nMoeda ,nMoedaCor	,MsDecimais(nMoeda)     ,;
		               dDataMovto                       ,"SE1"  ,nRegistro	,(cAlias)->E1_CLIENTE  +;
		               (cAlias)->E1_LOJA)
		
		//Soma ao total por moeda ==> Creditos
		nPos := aScan(aDadosGer,{|x| x[1] == (cAlias)->E1_MOEDA})
		If nPos > 0
			aDadosGer[nPos][04] += (cAlias)->E1_VALOR
		Endif
		
		// Soma o titulo ao array de totais de titulos por forma de pgto...		    
	    aCaixaQtde[aFormaEnt[nForma][2]] += 1
	Endif
	DbSkip()
End

// Le o SD1 para determinar as devolu‡”es
If lQuery
	DbSelectArea("SE1TMP")
	dbCloseArea()

	Lj031MQuery("SD1")
	cAlias := "SD1TMP"
Else
	DbSelectArea("SD1")
	DbSetOrder(3)
	If lUsaParam
		DbSeek(cDeFilSD1, .T. )	// Filial
	Else
		DbSeek(xFilial()+DToS(dDataMovto))
	Endif
	cAlias := "SD1"
Endif

If !Eof()
	While !Eof() .AND. Iif(!lQuery	,D1_FILIAL >= cDeFilSD1 .AND.;
	                                 D1_FILIAL <= cAteFilSD1.AND.;
	                                 If(lUsaParam, .T., D1_EMISSAO == dDataMovto),.T.)

		If !lQuery
			If lUsaParam .AND. !(D1_EMISSAO >= MV_PAR01 .AND.;
				 D1_EMISSAO <= MV_PAR02)
				DbSkip()
				Loop
			Endif
		Endif
	                                
		If Iif(!lQuery,	(SD1->D1_TIPO == "D")    .AND.;
		                (SD1->D1_ORIGLAN == "LO").AND.;
		                Iif(lUsaParam, Left(SD1->D1_NUMCQ,3) >= MV_PAR03 .AND. Left(SD1->D1_NUMCQ,3) <= MV_PAR04,;
						Substr(SD1->D1_NUMCQ,1,3) == cCaixa),.T.)

			If lLJC031SD1
				//O registro corrente do SD1 deve ser desconsiderado...
				If !ExecBlock("LJC031SD1",.F.,.F.)
					DbSkip()
					Loop
				Endif
			Endif
			nTotImps  := 0
			SF1->(DbSetOrder(1))				
			SF1->(DbSeek(xFilial("SF1")+(cAlias)->D1_DOC+(cAlias)->D1_SERIE+(cAlias)->D1_FORNECE+(cAlias)->D1_LOJA))
			nMoeda := Max(SF1->F1_MOEDA,1)
            aTesImpInf  := TesImpInf((cAlias)->D1_TES)
            For nJ := 1 to Len(aTesImpInf)
            	If aTesImpInf[nJ][3] == "1"  //Soma na NF
                	cCpoImps  := aTesImpInf[nJ][2]
             		If SD1->(FieldPos(aTesImpInf[nJ][2])) > 0 .AND. &(cCpoImps) > 0       
                    	nTotImps += (cAlias)->(FieldGet(FieldPos(cCpoImps)))
                    Endif
               	Endif
			Next nJ
		
			// Realiza acerto da data do movimento...
            If Dtos(dDataMovto) <> Dtos(SF1->F1_EMISSAO)
				dDataMovto := SF1->F1_EMISSAO
			Endif
			             	
			aCaixa[P_DEVOLUCAO] += Round(xMoeda((cAlias)->D1_TOTAL+nTotImps,nMoeda,nMoedaCor,dDataMovto,nDecs+1,RecMoeda(dDataMovto,nMoeda)),nDecs)                
			nForma := aScan(aFormaSai,{|x| Trim(x[1])=="DV"})                				
			//Gera o array com os subtotais por forma de pagamento...		              
			If lQuery
				nRegistro := (cAlias)->D1_RECNO
			Else
				nRegistro := (cAlias)->(RecNo())
			EndIf
			LJ031TotFormas("2"                 ,.F.		,nForma		,(cAlias)->D1_TOTAL+nTotImps ,;
			               AllTrim(Str(nMoeda)),nMoeda	,nMoedaCor	,MsDecimais(nMoeda)          ,;
			               dDataMovto          ,"SD1"	,nRegistro	,SF1->F1_FORNECE            +;
			               SF1->F1_LOJA)

			//Soma ao total por moeda ==> Debitos
			nPos := aScan(aDadosGer,{|x| x[1] == nMoeda})
			If nPos > 0
				aDadosGer[nPos][05] += (cAlias)->D1_TOTAL+nTotImps
			Endif
			
			// Soma o titulo ao array de totais de titulos por forma de pgto...		    
		    aCaixaQtde[aFormaSai[nForma][2]] += 1
		Endif
		DbSkip()
		Loop
		
		While !Empty(cNumero) .AND. (cNumero == (cAlias)->D1_SERIORI+(cAlias)->D1_NFORI)
			DbSkip()
		End 	
	End
Endif            

If lQuery
	DbSelectArea("SD1TMP")
	dbCloseArea()
Endif

// Monta array de subitens para o ListBox de creditos e debitos... 
For nA := 1 To 2
	cDados := If(nA==1,"aValFormaE","aValFormaS")
	cDDown := If(nA==1,"aDDownE","aDDownS")
	For nJ := 1 to Len(&cDados)
		For nI := 1 To (Len(&cDados.[nJ]))
			If !Empty(&cDados.[ nJ, nI, 5 ])
				nMoedaTit	:= nMoedaCor
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se o codigo da moeda esta preenchido. Se estiver, ³
				//³respeita a picture da moeda utilizada na parcela.          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(&cDados.[ nJ, nI, 5, 1, 1 ])
		       		If Val(&cDados.[ nJ, nI, 5, 1, 1 ])  <> 0	
		       			nMoedaTit	:= Val(&cDados.[ nJ, nI, 5, 1, 1 ])
		       		Endif
		    	Endif
			
				AAdd(&cDDown.[ nJ ],{"  + " +	&cDados.[ nJ, nI, 2 ] 							+;
				                      			Eval( bTab, &cDados.[ nJ, nI, 2 ] )			+;
		    	                      			Transform( &cDados.[ nJ, nI, 3 ], PesqPict("SL1","L1_VLRTOT",16,nMoedaTit)   )	+;
		    	                      			"  "											+;
		    	                      			Iif(ValType(&cDados.[ nJ, nI, 4 ]) == "N",;
		    		                          			Transform( &cDados.[ nJ, nI, 4 ], "9999" )	,;
		    		                          			&cDados.[ nJ, nI, 4 ])						,;
		    	    	                  		&cDados.[ nJ, nI, 3 ]								,;
		    	    	                  		&cDados.[ nJ, nI, 5 ]								,;
		    	    	                  		&cDados.[ nJ, nI, 6 ]})		    
		 	Else 
				AAdd(&cDDown.[ nJ ],{"    " +	&cDados.[ nJ, nI, 2 ] 													+;
				                      			Eval( bTab, &cDados.[ nJ, nI, 2 ] ) 									+;
		    	                     			Transform( &cDados.[ nJ, nI, 3 ],; 
		    	                     					PesqPict("SL1","L1_VLRTOT",16, Val(&cDados.[ nJ, nI, 1 ])) )	+;
		    	                     			"  "																	+;
									  			Iif(ValType(&cDados.[ nJ, nI, 4 ]) == "N",;
		    	                          				Transform( &cDados.[ nJ, nI, 4 ], "9999" )	,;
		    	                          				&cDados.[ nJ, nI, 4 ])						,;		    	                      
		        	                  			&cDados.[ nJ, nI, 3 ]								,;
		        	                  			&cDados.[ nJ, nI, 6 ] })	 	
		 	Endif
		Next nI
	Next nJ
Next nA

//Valoriza o array aCaixaStr...   
For nA := 1 To Len(aCaixa)
	If nA >= 16 .AND. nA <= 23
		aCaixaStr[nA] := Transform(aCaixa[nA], cPicture)+"  "+Transform(aCaixaQtde[nA],"9999")
	Else
		aCaixaStr[nA] := Transform(aCaixa[nA], cPicture)
	Endif
Next nA 

//Calcula o total por moedas...                          
//Tirada a posição -x[6](troco), pois a variavel eh o total da venda e nao o total recebido
aEval(aDadosGer,{|x| x[7] := x[3]+x[4]-x[5]})  

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o	  ³LJ031Refresh³ Autor ³ Julio Cesar         ³ Data ³ 14/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³Executa Refresh nos objetos utilizados na consulta          ³±±	
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³LOJC031                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ031Refresh(oDlg      ,cCaixa     ,cNomeCxa   ,nTrocoEnt   ,;
                      nTrocoSai ,nTotCredito,nTotDebito ,nSaldFinal  ,;
                      oMovVen   ,oMovSan    ,aCaixa     ,aCaixaStr   ,;
                      dDataMovto,nOpc       ,nMoedaCor  ,nDecs       ,;
                      oTotCre   ,oTotDeb    ,oSaldFinal ,oTrocoEnt   ,;
                      oTrocoSai ,cArray)

DEFAULT dDataMovto  := dDatabase
 					  
//Desabilita os objetos para evitar erros...
oMovVen:Disable()
oMovSan:Disable()
oMovGer:Disable() 	
oCbx:Disable()

If nMoedaCorAnt <> nMoedaCor
	//Limpa o array de totais gerais...    
    aEval(aDadosGer,{|x| x[3]:=x[4]:=x[5]:=x[6]:=x[7]:=0})
                      
	nMoedaCorAnt:= nMoedaCor
	aDadosVen := aDadosVenOri
	aDadosSan := aDadosSanOri
	aDadosVenOri:= Nil
	aDadosSanOri:= Nil
	LJMsgRun(STR0054,,{|| MovimCxLoc(@aCaixa    ,@aCaixaStr   ,cCaixa   ,dDataMovto   ,;
	                                  nMoedaCor  ,nDecs)}) //"Calculando los totales para el caja "
Endif
	
DbSelectArea("SA6")
DbSetOrder(1) 
DbSeek(xFilial("SA6")+cCaixa,.T.)  
cNomeCxa := Left(SA6->A6_NOME,30)		// Nome do Caixa
                    
// Alimenta Totalizadores / Arrays aDados...
Lj031Dados(aCaixa      ,aCaixaStr   ,@nTrocoEnt   ,@nTrocoSai    ,;
           @nTotCredito,@nTotDebito ,@nSaldFinal  ,nOpc          ,;
           cArray      ,nMoedaCor)

//Habilita os objetos
oMovVen:Enable()
oMovSan:Enable()
oMovGer:Enable() 	
oCbx:Enable()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta Vetores de Dados de Credito / Debito para ListBox/Total Geral por Moeda     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMovVen:SetArray(aDadosVen) 
oMovVen:bLine := {|| {	aDadosVen[oMovVen:nAt][1] } }
oMovSan:SetArray(aDadosSan)
oMovSan:bLine := {|| {	aDadosSan[oMovSan:nAt][1] } }
oMovGer:SetArray(aDadosGer)
//Configura os dados contidos no Array aDadosGer para que os mesmos possam
//ser exibidos no objeto oMovGer...
Lj031BLine(@oMovGer,aDadosGer) 

oDlg:Refresh()
oMovVen:Refresh()                        
oMovSan:Refresh() 	
oMovGer:Refresh() 	
oTotCre:Refresh()
oTotDeb:Refresh()
oTrocoEnt:Refresh()    
oSaldFinal:Refresh()
If ValType(oTrocoSai) == "O"
   oTrocoSai:Refresh()
Endif

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o	  ³LJ031Dados³ Autor ³ Julio Cesar    	     ³ Data ³ 14/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³Fun‡„o que alimenta totalizadores por referˆncia e          ³±±
±±³           ³vetores de Dados aDadosVen e aDadosSan a partir de 		   ³±±
±±³           ³aCaixa recebido como parƒmetro.							   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³SIGALOJA                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj031Dados(aCaixa     ,aCaixaStr   ,nTrocoEnt   ,nTrocoSai   ,;
					nTotCredito,nTotDebito  ,nSaldFinal  ,nOpcao      ,;
					cArray     ,nMoedaCor)
Local cOpcao
Local cPicture 		:= PesqPict("SL1","L1_BASIMP1",14,nMoedaCor)
Local cSimbMoeda	:= "" 											// Simbolo da Moeda da Venda

If cPaisLoc == "BRA"
	cSimbMoeda := "R$"
Else
	cSimbMoeda := "$$"
EndIf

Private aDadosVenBkp := aClone(aDadosVen) 
Private aDadosSanBkp := aClone(aDadosSan) 
                  
nTrocoEnt := aCaixa[P_TROCOENT] 	// Saldo Inicial
nTrocoSai := aCaixa[P_TROCOSAI]    // Saida de troco 
nOpcao := IIf( nOpcao == NIL, 0, nOpcao )

//Verifica qual foi o opcao selecionada nos Creditos e em seguida 
//limpa o respectivo array...
If nOpcao # 0 .AND. nOpcao <= Len(&cArray.)
	cOpcao := &cArray.[nOpcao,1]
Else
	cOpcao := ""
Endif	

//Verifica qual foi o opcao selecionada nos Debitos e em seguida 
//limpa o respectivo array...
If cArray == Nil .OR. cArray == "aDadosSan" .OR. cArray == "aDadosSanOri" 
	aDadosSan := {}


	LJ031Nivel( DesCabec031( cSimbMoeda	, STR0007 )	, cOpcao, aScan( aFormaSai, { |x| x[2]==P_SANG_DINHEIRO   } ), aCaixaStr[P_SANG_DINHEIRO  ], aCaixa[P_SANG_DINHEIRO  ], "2", cPicture, nMoedaCor )
	LJ031Nivel( DesCabec031( "CH"		, STR0008 )	, cOpcao, aScan( aFormaSai, { |x| x[2]==P_SANG_CHEQUE     } ), aCaixaStr[P_SANG_CHEQUE    ], aCaixa[P_SANG_CHEQUE    ], "2", cPicture, nMoedaCor )
	LJ031Nivel( DesCabec031( "CC"		, STR0009 )	, cOpcao, aScan( aFormaSai, { |x| x[2]==P_SANG_CARTAO     } ), aCaixaStr[P_SANG_CARTAO    ], aCaixa[P_SANG_CARTAO    ], "2", cPicture, nMoedaCor )
	LJ031Nivel( DesCabec031( "VA"		, STR0015 )	, cOpcao, aScan( aFormaSai, { |x| x[2]==P_SANG_VALE       } ), aCaixaStr[P_SANG_VALE      ], aCaixa[P_SANG_VALE      ], "2", cPicture, nMoedaCor )
	LJ031Nivel( DesCabec031( "CO"		, STR0010 )	, cOpcao, aScan( aFormaSai, { |x| x[2]==P_SANG_CONVENIO   } ), aCaixaStr[P_SANG_CONVENIO  ], aCaixa[P_SANG_CONVENIO  ], "2", cPicture, nMoedaCor )
	LJ031Nivel( DesCabec031( "FI"		, STR0012 )	, cOpcao, aScan( aFormaSai, { |x| x[2]==P_SANG_FINANCIADO } ), aCaixaStr[P_SANG_FINANCIADO], aCaixa[P_SANG_FINANCIADO], "2", cPicture, nMoedaCor )
	LJ031Nivel( DesCabec031( "CD"		, STR0028 )	, cOpcao, aScan( aFormaSai, { |x| x[2]==P_SANG_DEBAUTO    } ), aCaixaStr[P_SANG_DEBAUTO   ], aCaixa[P_SANG_DEBAUTO   ], "2", cPicture, nMoedaCor )
	LJ031Nivel(                    		  STR0013  	, cOpcao, aScan( aFormaSai, { |x| x[2]==P_SANG_OUTROS     } ), aCaixaStr[P_SANG_OUTROS    ], aCaixa[P_SANG_OUTROS    ], "2", cPicture, nMoedaCor )
	LJ031Nivel( DesCabec031( "PG"		, STR0029 )	, cOpcao, aScan( aFormaSai, { |x| x[2]==P_PAGAMENTOS      } ), aCaixaStr[P_PAGAMENTOS     ], aCaixa[P_PAGAMENTOS     ], "2", cPicture, nMoedaCor )
	LJ031Nivel( DesCabec031( "TO"		, STR0030 )	, cOpcao, aScan( aFormaSai, { |x| x[2]==P_TRANSF_ORIGEM   } ), aCaixaStr[P_TRANSF_ORIGEM  ], aCaixa[P_TRANSF_ORIGEM  ], "2", cPicture, nMoedaCor )
	LJ031Nivel( DesCabec031( "DV"		, STR0016 )	, cOpcao, aScan( aFormaSai, { |x| x[2]==P_DEVOLUCAO       } ), aCaixaStr[P_DEVOLUCAO      ], aCaixa[P_DEVOLUCAO      ], "2", cPicture, nMoedaCor )
	
	nTotDebito := 	aCaixa[P_SANG_DINHEIRO ] + aCaixa[P_SANG_CHEQUE     ] + ;
					aCaixa[P_SANG_CARTAO   ] + aCaixa[P_SANG_VALE       ] + ;
					aCaixa[P_SANG_CONVENIO ] + aCaixa[P_SANG_FINANCIADO ] + ;
					aCaixa[P_SANG_DEBAUTO  ] + aCaixa[P_PAGAMENTOS      ] + ;
					aCaixa[P_TRANSF_ORIGEM ] + aCaixa[P_DEVOLUCAO       ] + ;
					aCaixa[P_SANG_OUTROS   ]
Endif

If cArray == Nil .OR. cArray == "aDadosVen" .OR. cArray == "aDadosVenOri"

	aDadosVen := {}                        

	LJ031Nivel( DesCabec031( cSimbMoeda	, STR0007 )	, cOpcao, aScan(aFormaEnt,{|x| x[2]==P_VEND_DINHEIRO})  , aCaixaStr[P_VEND_DINHEIRO  ], aCaixa[P_VEND_DINHEIRO  ],"1",cPicture,nMoedaCor)
	LJ031Nivel( DesCabec031( "CH"		, STR0008 )	, cOpcao, aScan(aFormaEnt,{|x| x[2]==P_VEND_CHEQUE})    , aCaixaStr[P_VEND_CHEQUE    ], aCaixa[P_VEND_CHEQUE    ],"1",cPicture,nMoedaCor)
	LJ031Nivel( DesCabec031( "CC"		, STR0009 )	, cOpcao, aScan(aFormaEnt,{|x| x[2]==P_VEND_CARTAO})    , aCaixaStr[P_VEND_CARTAO    ], aCaixa[P_VEND_CARTAO    ],"1",cPicture,nMoedaCor)
	LJ031Nivel( DesCabec031( "VA"		, STR0011 )	, cOpcao, aScan(aFormaEnt,{|x| x[2]==P_VEND_VALE})      , aCaixaStr[P_VEND_VALE      ], aCaixa[P_VEND_VALE      ],"1",cPicture,nMoedaCor)
	LJ031Nivel( DesCabec031( "CO"		, STR0010 )	, cOpcao, aScan(aFormaEnt,{|x| x[2]==P_VEND_CONVENIO})  , aCaixaStr[P_VEND_CONVENIO  ], aCaixa[P_VEND_CONVENIO  ],"1",cPicture,nMoedaCor)
	LJ031Nivel( DesCabec031( "FI"		, STR0012 )	, cOpcao, aScan(aFormaEnt,{|x| x[2]==P_VEND_FINANCIADO}), aCaixaStr[P_VEND_FINANCIADO], aCaixa[P_VEND_FINANCIADO],"1",cPicture,nMoedaCor)
	LJ031Nivel( DesCabec031( "DC"		, STR0028 )	, cOpcao, aScan(aFormaEnt,{|x| x[2]==P_VEND_DEBAUTO})   , aCaixaStr[P_VEND_DEBAUTO   ], aCaixa[P_VEND_DEBAUTO   ],"1",cPicture,nMoedaCor)
	LJ031Nivel( 						  STR0013	, cOpcao, aScan(aFormaEnt,{|x| x[2]==P_VEND_OUTROS})    , aCaixaStr[P_VEND_OUTROS    ], aCaixa[P_VEND_OUTROS    ],"1",cPicture,nMoedaCor)
	LJ031Nivel( DesCabec031( "CR"		, STR0032 )	, cOpcao, aScan(aFormaEnt,{|x| x[2]==P_VEND_CREDITO})   , aCaixaStr[P_VEND_CREDITO   ], aCaixa[P_VEND_CREDITO   ],"1",cPicture,nMoedaCor)
	LJ031Nivel( DesCabec031( "TD"		, STR0029 )	, cOpcao, aScan(aFormaEnt,{|x| x[2]==P_TRANSF_DESTINO}) , aCaixaStr[P_TRANSF_DESTINO ], aCaixa[P_TRANSF_DESTINO ],"1",cPicture,nMoedaCor)
	LJ031Nivel( DesCabec031( "RC"		, STR0031 )	, cOpcao, aScan(aFormaEnt,{|x| x[2]==P_RECEBIMENTOS})   , aCaixaStr[P_RECEBIMENTOS   ], aCaixa[P_RECEBIMENTOS   ],"1",cPicture,nMoedaCor)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso Seja 11.5 e Cartão Fidelidade Ativo.                   ³
	//³contabiliza as operações realizadas com Cartão Fidelidade e ³
	//³Adiciona na Variável nTotCredito para dar o valor total.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLjcFid
		LJ031Nivel( DesCabec031( "FID"		, "CARTFI") , cOpcao, aScan(aFormaEnt,{|x| x[2]==P_VEND_CARTFID})   , aCaixaStr[P_VEND_CARTFID], aCaixa[P_VEND_CARTFID   ],"1",cPicture,nMoedaCor)
		
		nTotCredito :=	aCaixa[P_VEND_DINHEIRO ] + aCaixa[P_VEND_CHEQUE     ] + ;
					aCaixa[P_VEND_CARTAO   ] + aCaixa[P_VEND_VALE       ] + ;
					aCaixa[P_VEND_CONVENIO ] + aCaixa[P_VEND_FINANCIADO ] + ;
					aCaixa[P_VEND_DEBAUTO  ] + aCaixa[P_VEND_CREDITO    ] + ;
					aCaixa[P_VEND_OUTROS   ] + aCaixa[P_TRANSF_DESTINO  ] + ;
					aCaixa[P_RECEBIMENTOS  ] + aCaixa[P_VEND_CARTFID  ]
	Else
		nTotCredito :=	aCaixa[P_VEND_DINHEIRO ] + aCaixa[P_VEND_CHEQUE     ] + ;
					aCaixa[P_VEND_CARTAO   ] + aCaixa[P_VEND_VALE       ] + ;
					aCaixa[P_VEND_CONVENIO ] + aCaixa[P_VEND_FINANCIADO ] + ;
					aCaixa[P_VEND_DEBAUTO  ] + aCaixa[P_VEND_CREDITO    ] + ;
					aCaixa[P_VEND_OUTROS   ] + aCaixa[P_TRANSF_DESTINO  ] + ;
					aCaixa[P_RECEBIMENTOS  ]
    EndIf
Endif
       
nSaldFinal := nTrocoEnt + nTotCredito - nTotDebito - nTrocoSai
     
//Armazena os arrays originais...
If aDadosVenOri == Nil .AND. aDadosSanOri == Nil
	aDadosVenOri := aClone(aDadosVen)
	aDadosSanOri := aClone(aDadosSan)
Endif

Return(.T.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LJ031Nivel³ Autor ³ Julio Cesar           ³ Data ³ 14/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para tratar opcoes disponiveis para Drill-Down      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ031Nivel(ExpC1,ExpC2,ExpN1,ExpC3,ExpN2,ExpC4,ExpC5,ExpN3)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = String a ser exibida no ListBox                    ³±±
±±³          ³ ExpC2 = Opcao selecionada com clique duplo                 ³±±
±±³          ³ ExpN1 = Opcao do drill down a ser tratada                  ³±±
±±³          ³ ExpC3 = String com o Valor atualizado da linha do listbox  ³±±
±±³          ³ ExpN2 = Valor atualizado da linha do listbox 			  ³±± 
±±³          ³ ExpC4 = Tipo de Movimento (1->Creditos 2->Debitos          ³±±
±±³          ³ ExpC5 = Picture para formatacao dos valores   			  ³±±
±±³          ³ ExpN3 = Moeda Corrente da consulta           			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJC031                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ031Nivel(cString   ,cDblClick   ,nOpDrill   ,cValor   ,;
                    nValor    ,cTipMov     ,cPicture   ,nMoedaCor)

Local nI, nJ, cSinal, cStrAux, nPos
Local nDifDDown := 0
Local nValDDown := 0
Local nDifDecs  := 0                   
Local nDecs     := MsDecimais(nMoedaCor)
Local cValDDown := ""
Local cNValDDown:= ""
Local bTab      := {|x| Space(20 - Len(x))} // Espacos para alinhar a direita o valor no ListBox
Local bTab1     := {|x| Space(14 - Len(x))} // Espacos para alinhar a direita o valor no ListBox
Local aDadosTits:= {}
                                                                  
Private cDados   := If(cTipMov=="1","aDadosVen","aDadosSan")
Private cDadosBkp:= If(cTipMov=="1","aDadosVenBkp","aDadosSanBkp")
Private cDDown   := If(cTipMov=="1","aDDownE","aDDownS") 

// Prepara array com os dados para pesquisa dos titulos gerados no financeiro...
If !Empty( &cDDown.[nOpDrill] )
	For nI := 1 To Len( &cDDown.[nOpDrill] )
		If ValType(&cDDown.[nOpDrill][nI][Len(&cDDown.[nOpDrill][nI])]) == "A"
			AAdd(aDadosTits,aClone(&cDDown.[nOpDrill][nI][Len(&cDDown.[nOpDrill][nI])]))		
		Endif
	Next nI
	              
	// Ajusta o tamanho do array para compatibilizacao com a funcao que
	// realiza a exibicao dos titulos.
	For nI := 1 To Len(aDadosTits)
		For nJ := 1 To Len( aDadosTits[nI] )
			If Len(aDadosTits[nI][nJ]) == 5
				ADel(aDadosTits[nI][nJ] , 5)
				ASize(aDadosTits[nI][nJ], 4)							
			Endif
		Next nJ		
	Next nI			
Endif

// Se a string passada estiver contida na opcao que foi selecionada com DblClick no ListBox
If cString $ cDblClick
	// Abre os subitens do item do ListBox se houverem
	If (nOpDrill > 0) .AND. (At("+",cDblClick) > 0) .AND. (Len(&cDDown.[nOpDrill]) > 0)
		AAdd( &cDados., {"- " + cString + Eval( bTab, cString ), nValor, aDadosTits } )

		// Verifica se o Drill Down possui mais de um nível, caso permite verifica
		//  se existem diferenças de arredondamento.
		If At("+", &cDDown.[nOpDrill, 01, 01] ) > 0 
			// Verifica se o valor da soma do Drill Down confere com o total exibido
			// para a forma selecionada pelo usuario.
			For nI := 1 To Len( &cDDown.[nOpDrill] )
				nValDDown += &cDDown.[nOpDrill, nI, 02]
			Next nI	
	
			// Caso exista diferença de arredondamento acerta o valor e a string que
			// sera exibida no Drill Down.		
			If ((nDifDDown := nValDDown - nValor) <> 0)
				nDifDecs  := 1/(10^nDecs)
				
				While nDifDDown <> 0 			
					For nI := 1 To Len( &cDDown.[nOpDrill] )
						cValDDown := Transform(&cDDown.[nOpDrill, nI, 02], cPicture)				
						For nJ := 1 To Len( &cDDown.[nOpDrill, nI, 03] )
							If &cDDown.[nOpDrill, nI, 03, nJ, 01] <> Str(nMoedaCor,1)
								If nDifDDown > 0
									&cDDown.[nOpDrill, nI, 02] -= nDifDecs
									&cDDown.[nOpDrill, nI, 03, nJ, 03] -= nDifDecs
									nDifDDown -= nDifDecs
								Else                                      
									&cDDown.[nOpDrill, nI, 02] += nDifDecs
									&cDDown.[nOpDrill, nI, 03, nJ, 03] += nDifDecs
									nDifDDown += nDifDecs
								Endif							
							Endif
						Next nJ
						cNValDDown := Transform(&cDDown.[nOpDrill, nI, 02], cPicture)
						&cDDown.[nOpDrill, nI, 01] := StrTran(&cDDown.[nOpDrill, nI, 01], cValDDown, cNValDDown)   
					Next nI
				End
			Endif
        Endif
        
		// Expande o Drill Down do nivel inicial.
		For nI := 1 To Len( &cDDown.[nOpDrill] )
			AAdd(&cDados., aClone(&cDDown.[nOpDrill, nI]))
		Next nI	
	Else                                              
		// Se nao houverem subitens, reapresenta o item e muda apenas o sinal.
		If At("+",cDblClick) > 0 .AND. (nValor > 0)
			cSinal := "-"
		ElseIf At("-",cDblClick) > 0 .AND.(nValor > 0)	 	                                  
			cSinal := "+"
		Else
			cSinal := " "		
		Endif
		AAdd(&cDados.,{cSinal+" "+cString+Eval(bTab,cString)+cValor, nValor, aDadosTits})
	Endif
Else                                               
	// Se estiver aberto, reimprime os subitens
	nPos := aScan(&cDadosBkp.,{|x| Trim(cString) $ Trim(x[1])})
	If (nOpDrill > 0) .AND. (nPos > 0) .AND. (At("-",&cDadosBkp.[nPos][1]) > 0) .AND.;
	   (Len(&cDDown.[nOpDrill]) > 0)

		// Apenas mantem o que estava anteriormente no ListBox
		AAdd(&cDados.,{"- "+cString+Eval(bTab,cString), nValor})
		
		For nI := 1 To Len( &cDDown.[nOpDrill] )
			cStrAux := SubStr(&cDDown.[nOpDrill, nI, 1],4,At(Trim(Transform(&cDDown.[nOpDrill, nI, 2],cPicture)),&cDDown.[nOpDrill, nI, 1])-1)
			If (nPos := aScan(&cDadosBkp.,{|x| Trim(cStrAux) $ Trim(x[1])})) > 0
				AAdd( &cDados., aClone(&cDDown.[nOpDrill, nI]) )
				If (At("+",&cDadosBkp.[nPos][1]) > 0 .AND. (Trim(cDblClick) == Trim(&cDadosBkp.[nPos][1]))) .OR.;
				   (At("-",&cDadosBkp.[nPos][1]) > 0 .AND. (Trim(cDblClick) <> Trim(&cDadosBkp.[nPos][1])))		
					&cDados.[Len(&cDados.)][1] := "  -"+cStrAux
					For nJ := 1 To Len(&cDDown.[nOpDrill,nI,3])
						AAdd(&cDados.,{"        " +&cDDown.[nOpDrill,nI,3,nJ,2] + ;
										Eval(bTab1,&cDDown.[nOpDrill,nI,3,nJ,2])+ ;
						                Transform( &cDDown.[nOpDrill,nI,3,nJ,3], cPicture )+"  "+ ;
						                Iif(ValType( &cDDown.[nOpDrill,nI,3,nJ,4] ) == "N", ;
						                    Transform( &cDDown.[nOpDrill,nI,3,nJ,4], "9999" ), ;
						                    &cDDown.[nOpDrill,nI,3,nJ,4]), ;
						                &cDDown.[nOpDrill,nI,3,nJ,3], ;
						                &cDDown.[nOpDrill,nI,3,nJ,5] })	 					
					Next nJ
				Endif
			Else                                               
				AAdd(&cDados.,aClone(&cDDown.[nOpDrill, nI]))		
			Endif	
		Next nI	
	Else	        
		// Apenas mantem o que estava anteriormente no ListBox
		AAdd(&cDados.,{If(nValor>0,"+ ","  ")+cString+Eval(bTab, cString)+cValor, nValor, aDadosTits})
	Endif
Endif		

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o	  ³LJ031TotFormas³ Autor ³ Julio Cesar    	     ³ Data ³ 14/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³Cria os arrays que serao utilizados na contabilizacao do total  ³±±
±±³           ³de creditos e debitos. A totalizacao e feita por forma de pgto.,³±± 
±±³           ³administradora financeira e moeda.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³LOJC031                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function LJ031TotFormas(cTipMov   ,lAdm     ,nForma   ,nValor   ,;
							   cMoeda    ,nMoeda   ,nMoedaCor,nDecs    ,;
							   dDataMovto,cAliasAtu,nRecNo   ,cCodCli  )

Local nPos, nPosM, nPosOrc
Local cAdmCart := ""           
Local lCtrlQtde:= Iif(cTipMov=="2",.F.,Iif(aFormaEnt[nForma][2]>=16 .AND. aFormaEnt[nForma][2]<=23,.T.,.F.))

Private cArrayGen   := If(cTipMov=="1","aValFormaE","aValFormaS")
Private cArrayTpMov := If(cTipMov=="1","aFormaEnt","aFormaSai")

If lAdm
  	cAdmCart := RTrim(Left(SAE->AE_DESC, 20))
	nPos     := aScan(aValFormaE[nForma], {|x| x[1] == cCodAdm})
	If nPos # 0         
		&cArrayGen.[nForma,nPos,3] += Round(xMoeda(nValor, nMoeda, nMoedaCor, dDataMovto, nDecs+1, RecMoeda(dDataMovto,nMoeda)), nDecs)
		If lCtrlQtde
			&cArrayGen.[nForma,nPos,4] += 1
		Endif
		nPosM := aScan(&cArrayGen.[nForma,nPos,5],{|x| Trim(x[1]) == cMoeda})
	    If nPosM # 0 
	    	&cArrayGen.[nForma,nPos,5,nPosM,3] += Round(nValor,nDecs)                                    
			If lCtrlQtde
				&cArrayGen.[nForma,nPos,5,nPosM,4] += 1
			Endif
			nPosOrc := aScan(&cArrayGen.[nForma,nPos,5,nPosM,5],;
			                 {|x| Trim(x[1])==Trim(cAliasAtu) .AND. x[2]==nRecNo .AND. Trim(x[3])==Trim(cCodAdm)} )                                           
			If nPosOrc == 0			
				AAdd(&cArrayGen.[nForma][nPos][5][nPosM][5], {cAliasAtu, nRecNo, cCodAdm, &cArrayTpMov.[nForma][1], nMoeda} )			
			Endif

			nPosOrc := aScan(&cArrayGen.[nForma,nPos,6],{|x| Trim(x[1])==Trim(cAliasAtu) .AND. x[2]==nRecNo .AND. Trim(x[3])==Trim(cCodAdm)} )                                           
			If nPosOrc == 0			
				AAdd(&cArrayGen.[nForma][nPos][6],{cAliasAtu, nRecNo, cCodAdm, &cArrayTpMov.[nForma][1]} )
			Endif
	    Else
			AAdd(&cArrayGen.[nForma][nPos][5],{cMoeda,SuperGetMV("MV_MOEDA"+cMoeda),Round(nValor,nDecs),Iif(lCtrlQtde,1,""),{{cAliasAtu, nRecNo, cCodAdm, &cArrayTpMov.[nForma][1], nMoeda}} })			    	
			AAdd(&cArrayGen.[nForma][nPos][6],{cAliasAtu, nRecNo, cCodAdm, &cArrayTpMov.[nForma][1]} )
		Endif	    	
	Else
		AAdd( &cArrayGen.[nForma], { cCodAdm, cAdmCart,Round(xMoeda(nValor, nMoeda, nMoedaCor, dDataMovto, nDecs+1, RecMoeda(dDataMovto,nMoeda)), nDecs ),Iif(lCtrlQtde,1,""),{},{}} )
		AAdd( &cArrayGen.[nForma][Len(&cArrayGen.[nForma])][5],{cMoeda, SuperGetMV("MV_MOEDA"+cMoeda),Round(nValor,nDecs),Iif(lCtrlQtde,1,""),{{cAliasAtu, nRecNo, cCodAdm, &cArrayTpMov.[nForma][1], nMoeda}} })
		AAdd( &cArrayGen.[nForma][Len(&cArrayGen.[nForma])][6],{cAliasAtu, nRecNo, cCodAdm, &cArrayTpMov.[nForma][1]} )
	Endif			
Else
	nPosM := aScan(&cArrayGen.[nForma], {|x| x[1] == cMoeda})
	If nPosM # 0
		&cArrayGen.[nForma,nPosM,3] += Round(nValor,nDecs)
		If lCtrlQtde
			&cArrayGen.[nForma,nPosM,4] += 1
		Endif                                         
		nPosOrc := aScan(&cArrayGen.[nForma,nPosM,6],;
		                 {|x| Trim(x[1])==Trim(cAliasAtu) .AND. x[2]==nRecNo .AND. Trim(x[3])==Trim(cCodCli)} )                                           

		If nPosOrc == 0			
			AAdd(&cArrayGen.[nForma][nPosM][6],{cAliasAtu, nRecNo, cCodCli, &cArrayTpMov.[nForma][1], nMoeda} )			
		Endif
	Else
		AAdd(&cArrayGen.[nForma],{cMoeda,SuperGetMV("MV_MOEDA"+cMoeda),Round(nValor,nDecs),;
		    Iif(lCtrlQtde,1,""),{},{{cAliasAtu, nRecNo, cCodCli, &cArrayTpMov.[nForma][1],;
		    nMoeda}} })
	Endif			
Endif

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o	  ³Lj031BLine³ Autor ³ Julio Cesar    	     ³ Data ³ 14/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³Formata os dados do array aDadosGer para exibicao no objeto ³±±
±±³           ³oMovGer e cria o bloco de comando.                 		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³LOJC031                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
           
Static Function Lj031BLine( oMovGer  ,aDadosGer  )

Local nI   := 0
Local cExp := ""
          
For nI := 2 To 7          
	If (nI <> 6) .OR. ((nI == 6) .AND. SuperGetMV("MV_LJTRLOC",,.F.))
		If ValType(aDadosGer[Len(aDadosGer)][nI]) == "N"
			cExp := cExp+If(nI==2,'{','')+'Transform(aDadosGer[oMovGer:nAt]['+Str(nI,1)+'],aDadosGer[oMovGer:nAt][8],aDadosGer[oMovGer:nAt][1])'+;
			        If(nI==7,'}',',')
		Else
			cExp := cExp+If(nI==2,'{','')+'aDadosGer[oMovGer:nAt][2]'+If(nI==7,'}',',')
		Endif
	Endif
Next nI

oMovGer:bLine := {|| &cExp}

Return(Nil)                                
     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Lj031MQuery()³Autor ³ Julio Cesar          ³Data³ 04/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta a query conforme o parametro informado.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Arquivo para o qual vai ser montada a query        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³LOJC031                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Henry     ³29/06/05³710   ³Bops: 83690 - Alteracao da query de modo a  ³±±
±±³          ³        ³      ³tratar os cancelados a moeda incluindo o ope³±±
±±³          ³        ³      ³rador AND                          	      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj031MQuery(cArq)

Local cImpsLoc := ""
Local aAreaAtu := GetArea()
Local aAreaSx3 := {}
Local aStru    := {}
Local nI       := 0

cQuery := ""
If cArq == "SE5"    
	cQuery := "SELECT SE5.E5_DATA, SE5.E5_VALOR, SE5.E5_BANCO, SE5.E5_AGENCIA, SE5.E5_CONTA, SE5.E5_PREFIXO,"
	cQuery += " SE5.E5_NUMERO, SE5.E5_PARCELA, SE5.E5_TIPO, SE5.E5_TIPODOC, SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_SEQ,"
	cQuery += " SE5.E5_VENCTO, SE5.E5_MOEDA, SE5.E5_RECPAG, SE5.E5_MOTBX, SE5.R_E_C_N_O_ AS E5_RECNO "
	If SE5->(FieldPos("E5_FORMAPG")) > 0
		cQuery += ", SE5.E5_FORMAPG "
	EndIf
	cQuery += " FROM " + RetSQLName("SE5") + " SE5"
	If lUsaParam
		cQuery += " WHERE SE5.E5_FILIAL BETWEEN '" + cDeFilSE5 + "' AND '" + cAteFilSE5 + "'"
		cQuery += " AND SE5.E5_DATA BETWEEN '" + DToS(MV_PAR01) + "' AND '" + DToS(MV_PAR02) + "'"
		cQuery += " AND SE5.E5_BANCO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
	Else
		cQuery += " WHERE SE5.E5_FILIAL = '" + xFilial("SE5") + "'"
		cQuery += " AND SE5.E5_DATA = '" + DToS(dDataMovto) + "'"
		cQuery += " AND SE5.E5_BANCO = '" + cCaixa + "'"
	Endif
	cQuery += " AND (SE5.E5_SITUACA <> 'C' AND SE5.E5_MOEDA <> 'ES')"
	cQuery += " AND SE5.E5_TIPODOC <> 'LJ'"
	cQuery += " AND SE5.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'SE5TMP', .F., .T.)
ElseIf cArq == "SL1"
	cQuery := "SELECT SL1.L1_NUM, SL1.L1_MOEDA, SL1.L1_CONDPG, SL1.L1_FORMPG, SL1.L1_TXMOEDA, SL1.L1_DINHEIR, SL1.L1_CHEQUES,"
	cQuery += " SL1.L1_CARTAO, SL1.L1_VALES, SL1.L1_CONVENI, SL1.L1_FINANC, SL1.L1_VLRDEBI, SL1.L1_CREDITO, SL1.L1_OUTROS,"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso seja 11.5 e Cartao Fidelidade Ativo.      ³
	//³Realiza procura de valores no campo L1_CARTFID.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLjcFid
		cQuery += " SL1.L1_EMISSAO, SL1.L1_EMISNF, SL1.L1_CLIENTE, SL1.L1_LOJA, SL1.L1_CARTFID, SL1.R_E_C_N_O_ AS L1_RECNO"
	Else
		cQuery += " SL1.L1_EMISSAO, SL1.L1_EMISNF, SL1.L1_CLIENTE, SL1.L1_LOJA, SL1.R_E_C_N_O_ AS L1_RECNO"
	EndIf
	cQuery += " FROM " + RetSQLName("SL1") + " SL1"
	If lUsaParam
		cQuery += " WHERE SL1.L1_FILIAL BETWEEN '" + cDeFilSL1 + "' AND '" + cAteFilSL1 + "'"
		cQuery += " AND SL1.L1_EMISNF BETWEEN '" + DToS(MV_PAR01) + "' AND '" + DToS(MV_PAR02) + "'"
		cQuery += " AND SL1.L1_OPERADO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
	Else
		cQuery += " WHERE SL1.L1_FILIAL = '" + xFilial("SL1") + "'"
		cQuery += " AND SL1.L1_EMISSAO = '" + DToS(dDataMovto) + "'"
		cQuery += " AND SL1.L1_OPERADO = '" + cCaixa + "'"         
	Endif
	cQuery += " AND (SL1.L1_TIPO <> '' OR (SL1.L1_TIPO = 'P' AND SL1.L1_DOCPED <> '') OR (SL1.L1_TIPO = 'V' AND SL1.L1_DOC <> ''))"
    cQuery += " AND SL1.L1_CONDPG <> 'LAY' AND SL1.L1_FORMPG NOT IN ('NF')"
	cQuery += " AND SL1.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'SL1TMP', .F., .T.)
ElseIf cArq == "SE1"
	cQuery := " SELECT SE1.E1_SALDO, SE1.E1_MOEDA, SE1.E1_VALOR, SE1.E1_EMISSAO,"
	cQuery += " SE1.E1_CLIENTE,SE1.E1_PORTADO, SE1.E1_TIPO, SE1.E1_LOJA, SE1.R_E_C_N_O_ AS E1_RECNO"
	cQuery += " FROM " + RetSQLName("SE1") + " SE1"
	If lUsaParam
		cQuery += " WHERE SE1.E1_FILIAL BETWEEN '" + cDeFilSE1 + "' AND '" + cAteFilSE1 + "'"
		cQuery += " AND SE1.E1_EMISSAO BETWEEN '" + DToS(MV_PAR01) + "' AND '" + DToS(MV_PAR02) + "'"
		cQuery += " AND SE1.E1_PORTADO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
	Else
		cQuery += " WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "'"
		cQuery += " AND SE1.E1_EMISSAO = '" + DToS(dDataMovto) + "'"
		cQuery += " AND SE1.E1_PORTADO = '" + cCaixa + "'"
	Endif
	cQuery += " AND SE1.E1_SALDO > 0"
	cQuery += " AND SE1.E1_TIPO = '"+MV_CRNEG+"'"
	cQuery += " AND SE1.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'SE1TMP', .F., .T.)
ElseIf cArq == "SD1"
	DbSelectArea("SX3")
	aAreaSx3 := GetArea()
	DbSetOrder(2)
	DbSeek("D1_VALIMP", .T.)
    While !Eof() .AND. "D1_VALIMP" $ Trim(X3_CAMPO)
		cImpsLoc += "SD1."+Trim(X3_CAMPO)+", "
		DbSkip()
	End   
	cImpsLoc := SubStr(cImpsLoc,1,Len(cImpsLoc)-2)
	RestArea(aAreaSx3)
	RestArea(aAreaAtu)  
	
	cQuery := "SELECT SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_TES, SD1.D1_TOTAL, "
	cQuery += cImpsLoc
	cQuery += " ,SD1.R_E_C_N_O_ AS D1_RECNO "
	cQuery += " FROM " + RetSQLName("SD1") + " SD1"
	If lUsaParam
		cQuery += " WHERE SD1.D1_FILIAL BETWEEN '" + cDeFilSD1 + "' AND '" + cAteFilSD1 + "'"
		cQuery += " AND SD1.D1_EMISSAO BETWEEN '" + DToS(MV_PAR01) + "' AND '" + DToS(MV_PAR02) + "'"
		If ! (AllTrim(Upper(TCGetDB())) $ "ORACLE_INFORMIX")
			cQuery += "  AND SUBSTRING(SD1.D1_NUMCQ,1,3) BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
		Else
			cQuery += "  AND SUBSTR(SD1.D1_NUMCQ,1,3) BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
		Endif
	Else
		cQuery += " WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "'"
		cQuery += " AND SD1.D1_EMISSAO = '" + DToS(dDataMovto) + "'"
		If ! (AllTrim(Upper(TCGetDB())) $ "ORACLE_INFORMIX")
			cQuery += "  AND SUBSTRING(SD1.D1_NUMCQ,1,3) = '" + cCaixa + "'"
		Else
			cQuery += "  AND SUBSTR(SD1.D1_NUMCQ,1,3) = '" + cCaixa + "'"
		Endif
	Endif
	cQuery += " AND SD1.D1_TIPO = 'D'"
	cQuery += " AND SD1.D1_ORIGLAN = 'LO'"
	cQuery += " AND SD1.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), 'SD1TMP', .F., .T.)
Endif
                        
//Seleciona a area recem criada...
DbSelectArea(cArq+"TMP")
dbGoTop()
       
//Acerta os campos conforme o seu tipo...           
aStru  := &cArq.->(dbStruct())           
           
For nI := 1 To Len(aStru)
	If aStru[nI][2] <> "C" .AND. FieldPos(aStru[nI][1]) <> 0
		TCSetField(cArq+"TMP", aStru[nI][1], aStru[nI][2], aStru[nI][3], aStru[nI][4])
	Endif
Next nI

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Lj031Sair    ³Autor ³ Julio Cesar          ³Data³ 22/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Limpa as variaveis de memoria static e finaliza a rotina   ³±±
±±³          ³ de consulta de saldo de caixa.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Lj031Sair(oDlg)
            
//"Limpa" as variaveis de memoria static...
nMoedaCorAnt := Nil
aDadosVenOri := Nil
aDadosSanOri := Nil

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Lj031Titulos ³Autor ³ Julio Cesar          ³Data³ 28/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta ListBox com os titulos referentes ao numerario e     ³±±
±±³          ³ moedas selecionados pelo usuario.                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj031Titulos( nMoedaCor  ,nDecs    ,cPicture   ,dDataMovto   ,;
                              cArrayFoc  )

Local oTitulos, oDlgTit, oFnt, oFntBold, oTotTis, oValTot
Local aAreaArq  := {}
Local aAreaSE1  := {}
Local aAreaSA6  := {}
Local aAreaSF1  := {}
Local aAreaAtu  := GetArea()
Local aDados    := {}
Local aDadosAux := {}
Local aRegOrc   := {}
Local aBLine    := {}
Local nNumLinha := Iif(cArrayFoc == "aDadosVen",oMovVen:nAt,oMovSan:nAt)
Local nI        := 0
Local nX        := 0
Local nValTot   := 0
Local nValTit   := 0
Local nTotTits  := 0
Local nDifDecs  := 0
Local nDif      := 0
Local nMoedaAux := 0
Local nTotImps  := 0
Local lPesqTits := .F.   
Local lPesqMoeda:= .F.
Local cAliasArq := ""
Local cCodCli   := ""
Local cChave    := ""
Local cSimbCor  := SuperGetMV("MV_SIMB"+Str(nMoedaCor,1))
Local cPictCor  := cPicture
Local cCpoImps  := ""
Local aCab      := {} 
Local aSizes    := {}
Local aTitulos  := {}
Local aTesImpInf:= {}

Private cCadastro := ""
Private nPosSerie := nPosNumTit:= nPosParc := nPosMoeda := nPosValC := nPosRecNo := 0
Private nPosDtaEmi:= nPosCodCli:= nPosLoja := nPosNomCli:= nPosVal  := nPosMoedE := 0
Private nPosHistor:= nPosBenef := nPosDoc  := nPosSerOri:= nPosNfOri:= nPosItOri := 0

DEFINE FONT oFnt     NAME "Courier New" 
DEFINE FONT oFntBold NAME "Courier New" BOLD

If ValType(&cArrayFoc.[nNumLinha][Len(&cArrayFoc.[nNumLinha])]) == "A"
	aDadosAux := aClone(&cArrayFoc.[nNumLinha][Len(&cArrayFoc.[nNumLinha])])

	// Monta o array aDados para que a leitura seja igual para qualquer nivel
	// do Drill Down...	
	For nI := 1 To Len(aDadosAux)
		For nX := 1 To Len(aDadosAux[nI])
			If ValType(aDadosAux[nI][nX]) == "A"  
				AAdd(aDados,aClone(aDadosAux[nI][nX]))
			Else
				aDados := aClone(aDadosAux)
				Exit
			Endif
		Next nX
	Next nI	
	
	If !Empty(aDados) 
		// Controla se os titulos devem ser pesquisados no arquivo SE1...
		lPesqTits := .T. 
	Endif
Endif            

If lPesqTits        
	For nI := 1 To Len(aDados)
		If Empty(aCab)
			nPosSerie := 1 // Determina a posicao do prefixo do titulo
			nPosNumTit:= 2 // Determina a posicao do numero do titulo                                            
			nPosParc  := 3 // Determina a posicao a que parcela se refere o titulo
			nPosDtaEmi:= 4 // Determina a posicao da data de emissao do titulo
			nPosCodCli:= 5 // Determina a posicao do codigo do cliente
			nPosLoja  := 6 // Determina a posicao da loja do cliente
			nPosNomCli:= 7 // Determina a posicao do nome do cliente
			If aDados[nI][01]$"SL4|SE1"
				// Determina o cabecalho do ListBox
				aCab := {RetTitle("E1_PREFIXO"),RetTitle("E1_NUM")    ,RetTitle("E1_PARCELA"),;
				         RetTitle("E1_EMISSAO"),RetTitle("E1_CLIENTE"),RetTitle("E1_LOJA"),;
				         RetTitle("E1_NOMCLI") ,"Valor Original","Moeda Original",""}
				                                   
				// Determina o tamanho dos campos do ListBox	         
				aAdd(aSizes,Max(Len(aCab[01]),TamSx3("E1_PREFIXO")[1]) * 4.1)
				aAdd(aSizes,Max(Len(aCab[02]),TamSx3("E1_NUM")[1])     * 4.1)
				aAdd(aSizes,Max(Len(aCab[03]),TamSx3("E1_PARCELA")[1]) * 4.1)
				aAdd(aSizes,Max(Len(aCab[04]),TamSx3("E1_EMISSAO")[1]) * 4.1)				
				aAdd(aSizes,Max(Len(aCab[05]),TamSx3("E1_CLIENTE")[1]) * 4.1)
				aAdd(aSizes,Max(Len(aCab[06]),TamSx3("E1_LOJA")[1])    * 4.1)
				aAdd(aSizes,Max(Len(aCab[07]),TamSx3("E1_NOMCLI")[1])  * 4.1)
				aAdd(aSizes,Max(Len(aCab[08]),TamSx3("E1_VALOR")[1])   * 4.1)
				aAdd(aSizes,Max(Len(aCab[09]),TamSx3("E1_MOEDA")[1])   * 4.1)
				aAdd(aSizes,Max(Len(aCab[10]),TamSx3("E1_VALOR")[1])   * 4.1)

				nPosVal   := 08 // Determina a posicao do valor do titulo na moeda do mesmo
				nPosMoedE := 09	// Determina a posicao do nome da moeda                                                                              
				nPosValC  := 10	// Determina a posicao do valor do titulo na moeda corrente
				nPosRecNo := 11	// Determina a posicao onde esta o número do registro
				nPosMoeda := 13	// Determina posicao da moeda no array aTitulos
			ElseIf aDados[nI][01] == "SE5"
				// Determina o cabecalho do ListBox
				aCab := {RetTitle("E5_PREFIXO"),RetTitle("E5_NUMERO"),RetTitle("E5_PARCELA"),;
				         RetTitle("E5_DATA")   ,RetTitle("E5_CLIFOR"),RetTitle("E5_LOJA")   ,;
				         RetTitle("E1_NOMCLI") ,RetTitle("E5_HISTOR") ,RetTitle("E5_BENEF") ,;
				         RetTitle("E5_DOCUMEN"),STR0062,STR0063,""} //"Valor Original"###"Moeda Original"

				// Determina o tamanho dos campos do ListBox	         
				aAdd(aSizes,Max(Len(aCab[01]),TamSx3("E5_PREFIXO")[1]) * 4.1)
				aAdd(aSizes,Max(Len(aCab[02]),TamSx3("E5_NUMERO")[1])  * 4.1)
				aAdd(aSizes,Max(Len(aCab[03]),TamSx3("E5_PARCELA")[1]) * 4.1)
				aAdd(aSizes,Max(Len(aCab[04]),TamSx3("E5_DATA")[1])    * 4.1)
				aAdd(aSizes,Max(Len(aCab[05]),TamSx3("E5_CLIFOR")[1])  * 4.1)
				aAdd(aSizes,Max(Len(aCab[06]),TamSx3("E5_LOJA")[1])    * 4.1)
				aAdd(aSizes,Max(Len(aCab[07]),TamSx3("E1_NOMCLI")[1])  * 4.1)
				aAdd(aSizes,Max(Len(aCab[08]),TamSx3("E5_HISTOR")[1])  * 4.1)
				aAdd(aSizes,Max(Len(aCab[09]),TamSx3("E5_BENEF")[1])   * 4.1)
				aAdd(aSizes,Max(Len(aCab[10]),TamSx3("E5_DOCUMEN")[1]) * 4.1)
				aAdd(aSizes,Max(Len(aCab[11]),TamSx3("E5_VALOR")[1])   * 4.1)
				aAdd(aSizes,Max(Len(aCab[12]),TamSx3("E5_MOEDA")[1])   * 4.1)				
				aAdd(aSizes,Max(Len(aCab[13]),TamSx3("E5_VALOR")[1])   * 4.1)
				
				nPosHistor:= 08	// Determina a posicao do historico do titulo
				nPosBenef := 09	// Determina a posicao do beneficiario do titulo                                   
				nPosDoc   := 10 // Determina a posicao do documento de identificação do título
				nPosVal   := 11 // Determina a posicao do valor do titulo na moeda do mesmo
				nPosMoedE := 12 // Determina a posicao do nome da moeda                                                                              
				nPosValC  := 13 // Determina a posicao do valor do titulo na moeda corrente
				nPosRecNo := 14 // Determina a posicao onde esta o número do registro
				nPosMoeda := 16 // Determina posicao da moeda no array aTitulos
			ElseIf aDados[nI][01] == "SD1"
				// Determina o cabecalho do ListBox
				aCab := {RetTitle("D1_SERIE")   ,RetTitle("D1_DOC")    ,RetTitle("D1_ITEM")   ,;
				         RetTitle("F1_EMISSAO") ,RetTitle("F1_FORNECE"),RetTitle("F1_LOJA")   ,;
   						 RetTitle("A1_NOME")    ,RetTitle("D1_SERIORI"),RetTitle("D1_NFORI") ,;
				         RetTitle("D1_ITEMORI"),STR0062      ,STR0063,""}			 //"Valor Original"###"Moeda Original"
    
				// Determina o tamanho dos campos do ListBox	         
				aAdd(aSizes,Max(Len(aCab[01]),TamSx3("D1_SERIE")[1])   * 4.1)
				aAdd(aSizes,Max(Len(aCab[02]),TamSx3("D1_DOC")[1])     * 4.1)
				aAdd(aSizes,Max(Len(aCab[03]),TamSx3("D1_ITEM")[1])    * 4.1)
				aAdd(aSizes,Max(Len(aCab[04]),TamSx3("F1_EMISSAO")[1]) * 4.1)
				aAdd(aSizes,Max(Len(aCab[05]),TamSx3("F1_FORNECE")[1]) * 4.1)
				aAdd(aSizes,Max(Len(aCab[06]),TamSx3("F1_LOJA")[1])    * 4.1)
				aAdd(aSizes,Max(Len(aCab[07]),TamSx3("A1_NOME")[1])    * 4.1)
				aAdd(aSizes,Max(Len(aCab[08]),TamSx3("D1_SERIORI")[1])* 4.1)
				aAdd(aSizes,Max(Len(aCab[09]),TamSx3("D1_NFORI")[1])   * 4.1)
				aAdd(aSizes,Max(Len(aCab[10]),TamSx3("D1_ITEMORI")[1]) * 4.1)
				aAdd(aSizes,Max(Len(aCab[11]),TamSx3("D1_TOTAL")[1])   * 4.1)
				aAdd(aSizes,Max(Len(aCab[12]),TamSx3("F1_MOEDA")[1])   * 4.1)				
				aAdd(aSizes,Max(Len(aCab[13]),TamSx3("D1_TOTAL")[1])   * 4.1)

				nPosSerOri:= 08	// Determina a posicao da Serie Original
				nPosNfOri := 09	// Determina a posicao da NF Original
				nPosItOri := 10 // Determina a posicao do Item Original
				nPosVal   := 11 // Determina a posicao do valor do titulo na moeda do mesmo
				nPosMoedE := 12 // Determina a posicao do nome da moeda                                                                              
				nPosValC  := 13 // Determina a posicao do valor do titulo na moeda corrente
				nPosRecNo := 14 // Determina a posicao onde esta o número do registro
				nPosMoeda := 16 // Determina posicao da moeda no array aTitulos
			ElseIf aDados[nI][01] == "SL1"
				// Determina o cabecalho do ListBox
				aCab := {RetTitle("L1_NUM")    , RetTitle("E1_EMISSAO"), RetTitle("E1_CLIENTE"), RetTitle("E1_LOJA"),;
				         RetTitle("E1_NOMCLI") , "Valor Original", "Moeda Original", ""}
				                                   
				// Determina o tamanho dos campos do ListBox	         
				aAdd(aSizes,Max(Len(aCab[01]),TamSx3("E1_NUM")[1])     * 4.1)
				aAdd(aSizes,Max(Len(aCab[02]),TamSx3("E1_EMISSAO")[1]) * 4.1)				
				aAdd(aSizes,Max(Len(aCab[03]),TamSx3("E1_CLIENTE")[1]) * 4.1)
				aAdd(aSizes,Max(Len(aCab[04]),TamSx3("E1_LOJA")[1])    * 4.1)
				aAdd(aSizes,Max(Len(aCab[05]),TamSx3("E1_NOMCLI")[1])  * 4.1)
				aAdd(aSizes,Max(Len(aCab[06]),TamSx3("E1_VALOR")[1])   * 4.1)
				aAdd(aSizes,Max(Len(aCab[07]),TamSx3("E1_MOEDA")[1])   * 4.1)
				aAdd(aSizes,Max(Len(aCab[08]),TamSx3("E1_VALOR")[1])   * 4.1)

				nPosNumTit:= 01 // Determina a posicao do numero do orçamento
				nPosDtaEmi:= 02 // Determina a posicao da data de emissao do titulo
				nPosCodCli:= 03 // Determina a posicao do codigo do cliente
				nPosLoja  := 04 // Determina a posicao da loja do cliente
				nPosNomCli:= 05 // Determina a posicao do nome do cliente
				nPosVal   := 06 // Determina a posicao do valor do credito na moeda do mesmo
				nPosMoedE := 07	// Determina a posicao do nome da moeda                                                                              
				nPosValC  := 08	// Determina a posicao do valor do credito na moeda corrente
				nPosRecNo := 09	// Determina a posicao onde esta o número do registro
				nPosMoeda := 11	// Determina posicao da moeda no array aTitulos
			Endif		
		Endif
		
		// Seleciona o registro do alias correspondente...
		DbSelectArea(aDados[nI][01])
		aAreaArq := GetArea()
		dbGoTo(aDados[nI][02])

		// Verifica se considera a moeda na pesquisa do arquivo SE1...
		If (lPesqMoeda := Len(aDados[nI]) == 5)
			cPicture := ""
			cPictCor := ""
		Else
			If aDados[nI][01]$"SL4|SE1"			
				aCab[10] := STR0064+cSimbCor //"Valor em "
			ElseIf aDados[nI][01]$"SE5|SD1"
				aCab[13] := STR0064+cSimbCor //"Valor em "
			ElseIf aDados[nI][01] == "SL1"                
				aCab[08] := STR0064+cSimbCor //"Valor em "
			Endif
		Endif
		                  
		If aDados[nI][01] == "SL4"
			// Verica se o orcamento corrente já teve seus titulos pesquisados...				
			If !Empty(aRegOrc)
				If aScan(aRegOrc,{|x| Trim(x[1]) == Trim(SL4->L4_NUM)}) # 0
					Loop
				Endif
			Endif
	
			DbSelectArea("SL1")
			DbSetOrder(1)
			DbSeek(xFilial("SL1")+SL4->L4_NUM)

			// Verifica se o cliente eh uma administradora financeira...
			If Len(aDados[nI][03]) < (TamSx3("L1_CLIENTE")[01]+TamSx3("L1_LOJA")[01])
				cCodCli := AllTrim(aDados[nI][03])
				cCodCli := cCodCli+Space(TamSx3("L1_CLIENTE")[01] - Len(cCodCli))
				cCodCli := cCodCli+"01"+Space(TamSx3("L1_LOJA")[01] - 2)
			Else
		    	cCodCli := L1_CLIENTE+L1_LOJA
			Endif         
								                           
			// Monta chave de pesquisa no arquivo SE1...
			cChave := xFilial("SE1")+cCodCli+L1_SERIE+L1_DOC            
		
			// Pesquisa o titulo no arquivo SE1...
			DbSelectArea("SE1")
			If Empty(aAreaSE1)  
				aAreaSE1 := GetArea()
			Endif
			DbSetOrder(2)
			If DbSeek(cChave)
				While !Eof() .AND. (E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM == cChave)
	    			// Se o tipo eh diferente do selecionado pelo usuario
	    			// desconsidera o registro...
	    			If IsMoney(aDados[nI][04]) 
	    				If !IsMoney(E1_TIPO)
	    					DbSkip()
	    					Loop
	    				Endif
	    			Else
						If AllTrim(E1_TIPO) <> AllTrim(aDados[nI][04])
							DbSkip()
							Loop
						Endif
					Endif

		    		// Se a moeda eh diferente da selecionada pelo usuario
	    			// desconsidera o registro...
					If lPesqMoeda
						If E1_MOEDA <> aDados[nI][05]
							DbSkip()
						Endif

						If Empty(cPicture)
							cPicture := PesqPict("SL1","L1_VLRTOT",16,MsDecimais(E1_MOEDA))
							cPictCor := cPicture        
							cSimbCor := SuperGetMV("MV_SIMB"+Str(SL4->L4_MOEDA,1))
							aCab[10]  := STR0064+cSimbCor //"Valor em "
						Endif
					Else
						cPicture := PesqPict("SL1","L1_VLRTOT",16,MsDecimais(E1_MOEDA))
					Endif
				
					AAdd(aTitulos,{E1_PREFIXO, E1_NUM, E1_PARCELA, E1_EMISSAO, E1_CLIENTE,;
					               E1_LOJA,E1_NOMCLI, E1_VALOR, SuperGetMV("MV_MOEDA"+Str(E1_MOEDA,1)),;
					               0, RecNo(), cPicture, E1_MOEDA})
					nTotTits++
					If lPesqMoeda			
						nValTot += E1_VALOR        
						aTitulos[Len(aTitulos)][nPosValC] := E1_VALOR
					Else
						nValTit := Round(xMoeda(E1_VALOR,E1_MOEDA,nMoedaCor,dDataMovto,nDecs+1,RecMoeda(dDataMovto,E1_MOEDA)),nDecs)
						nValTot += nValTit
						aTitulos[Len(aTitulos)][nPosValC] := nValTit
					Endif
					DbSkip()
				End
				
				// Determina se os titulos foram consultados no arquivo SE1 ou SL4...
				cAliasArq := "SE1"
				
				// Controla se o orçamento já teve seus títulos pesquisados...
				AAdd(aRegOrc,{SL4->L4_NUM,aDados[nI][02]})  
			Else
				// Determina a picture para a moeda...				
				If lPesqMoeda
					If Empty(cPicture)
						cPicture := PesqPict("SL1","L1_VLRTOT",16,MsDecimais(SL4->L4_MOEDA))
						cPictCor := cPicture
						cSimbCor := SuperGetMV("MV_SIMB"+Str(SL4->L4_MOEDA,1))
						aCab[10]  := STR0064+cSimbCor //"Valor em "
					Endif
				Else
					cPicture := PesqPict("SL1","L1_VLRTOT",16,MsDecimais(SL4->L4_MOEDA))				
				Endif
			
				AAdd(aTitulos,{SL1->L1_SERIE, SL1->L1_DOC, " ", SL1->L1_EMISSAO, SL1->L1_CLIENTE,; 
				               SL1->L1_LOJA, Posicione("SA1",1,xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA,"A1_NOME"),;
				               SL4->L4_VALOR, SuperGetMV("MV_MOEDA"+Str(SL4->L4_MOEDA,1)),;
				               0, SL4->(RecNo()), cPicture, SL4->L4_MOEDA})
				nTotTits++                  
				If lPesqMoeda			
					nValTot += SL4->L4_VALOR
					aTitulos[Len(aTitulos)][nPosValC] := SL4->L4_VALOR
				Else
					nValTit := Round(xMoeda(SL4->L4_VALOR,SL4->L4_MOEDA,nMoedaCor,;
					                 dDataMovto,nDecs+1,RecMoeda(dDataMovto,SL4->L4_MOEDA)),;
					                 nDecs)

					nValTot += nValTit
					aTitulos[Len(aTitulos)][nPosValC] := nValTit
                Endif

				// Determina em que arquivo os titulos ou o registro financeiro foi consultado.
   				cAliasArq := "SL4"
			Endif
		ElseIf aDados[nI][01] == "SE1"
    		// Se a moeda eh diferente da selecionada pelo usuario
   			// desconsidera o registro...
			If lPesqMoeda
				If E1_MOEDA <> aDados[nI][05]
					Loop
				Endif
				
				If Empty(cPicture)
					cPicture := PesqPict("SL1","L1_VLRTOT",16,MsDecimais(E1_MOEDA))
					cPictCor := cPicture        
					cSimbCor := SuperGetMV("MV_SIMB"+Str(E1_MOEDA,1))
					aCab[10]  := STR0064+cSimbCor //"Valor em "
				Endif
			Else
				cPicture := PesqPict("SE1","E1_VALOR",16,MsDecimais(E1_MOEDA))
			Endif
				
			AAdd(aTitulos,{E1_PREFIXO, E1_NUM, E1_PARCELA, E1_EMISSAO, E1_CLIENTE,;
			               E1_LOJA, E1_NOMCLI, E1_VALOR, SuperGetMV("MV_MOEDA"+Str(E1_MOEDA,1)),;
			               0, RecNo(), cPicture, E1_MOEDA})
			nTotTits++
			If lPesqMoeda			
				nValTot += E1_VALOR        
				aTitulos[Len(aTitulos)][nPosValC] := E1_VALOR
			Else
				nValTit := Round(xMoeda(E1_VALOR,E1_MOEDA,nMoedaCor,dDataMovto,nDecs+1,RecMoeda(dDataMovto,E1_MOEDA)),nDecs)
				nValTot += nValTit
				aTitulos[Len(aTitulos)][nPosValC] := nValTit
			Endif
				
			// Determina em que arquivo os titulos ou o registro financeiro foi consultado.
			cAliasArq := "SE1"		
		ElseIf aDados[nI][01] == "SE5"               
    		// Se a moeda eh diferente da selecionada pelo usuario
   			// desconsidera o registro...
			If lPesqMoeda
				nMoedaAux := aDados[nI][05]
				If Empty(cPicture)
					cPicture := PesqPict("SL1","L1_VLRTOT",16,nMoedaAux)
					cPictCor := cPicture        
					cSimbCor := SuperGetMV("MV_SIMB"+Str(nMoedaAux,1))
					aCab[13] := STR0064+cSimbCor //"Valor em "
				Endif
			Else                            
				If Empty(aAreaSA6)
					aAreaSA6 := SA6->(GetArea())
				Endif
				SA6->(DbSetOrder(1))
				SA6->(DbSeek(xFilial("SA6")+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA))
				nMoedaAux := Max(SA6->A6_MOEDA,1)
				cPicture  := PesqPict("SE5","E5_VALOR",16,MsDecimais(nMoedaAux))
			Endif
				
			AAdd(aTitulos,{E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_DATA, E5_CLIFOR, E5_LOJA,;
			               Iif(!Empty(E5_CLIFOR+E5_LOJA),Posicione("SA1",1,xFilial("SA1")+E5_CLIFOR+E5_LOJA,"A1_NOME"),""),;
			               E5_HISTOR, E5_BENEF, E5_DOCUMEN, E5_VALOR,;
			               SuperGetMV("MV_MOEDA"+Str(nMoedaAux,1)), 0, RecNo(),;
			               cPicture, nMoedaAux})
			nTotTits++
			If lPesqMoeda			
				nValTot += E5_VALOR        
				aTitulos[Len(aTitulos)][nPosValC] := E5_VALOR
			Else
				nValTit := Round(xMoeda(E5_VALOR,nMoedaAux,nMoedaCor,dDataMovto,nDecs+1,RecMoeda(dDataMovto,nMoedaAux)),nDecs)
				nValTot += nValTit
				aTitulos[Len(aTitulos)][nPosValC] := nValTit
			Endif
				
			// Determina em que arquivo os titulos ou o registro financeiro foi consultado.
			cAliasArq := "SE5"				         
		ElseIf aDados[nI][01] == "SD1"               
    		// Se a moeda eh diferente da selecionada pelo usuario
   			// desconsidera o registro...
			If lPesqMoeda
				nMoedaAux := aDados[nI][05]
				If Empty(cPicture)
					cPicture := PesqPict("SD1","D1_TOTAL",16,nMoedaAux)
					cPictCor := cPicture        
					cSimbCor := SuperGetMV("MV_SIMB"+Str(nMoedaAux,1))
					aCab[13] := STR0064+cSimbCor //"Valor em "
				Endif
			Else                            
				If Empty(aAreaSF1)
					aAreaSF1 := SF1->(GetArea())        
				Endif
				SF1->(DbSetOrder(1))				
				SF1->(DbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
				While !Eof() .AND. SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == ;
				      xFilial("SF1")+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA

					If AllTrim(SF1->F1_ESPECIE) == AllTrim(D1_ESPECIE)
						Exit
					Endif
					DbSkip()				      
				End   
				nMoedaAux := Max(SF1->F1_MOEDA,1)
				cPicture  := PesqPict("SD1","D1_TOTAL",16,MsDecimais(nMoedaAux))
			Endif

			// Totaliza os impostos variaveis...
	        aTesImpInf  := TesImpInf(D1_TES)
        	    For nX := 1 to Len(aTesImpInf)
            		If aTesImpInf[nX][3] == "1"  //Soma na NF
             	   		If FieldPos(aTesImpInf[nX][2]) > 0
                    		nTotImps += FieldGet(FieldPos(aTesImpInf[nX][2]))
                    	Endif
               		Endif
			Next nX
				
			AAdd(aTitulos,{D1_SERIE, D1_DOC, D1_ITEM, SF1->F1_DTDIGIT, SF1->F1_FORNECE, SF1->F1_LOJA,;
			               Posicione("SA1",1,xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA,"A1_NOME"),;
			               D1_SERIORI, D1_NFORI, D1_ITEMORI, D1_TOTAL+nTotImps, SuperGetMV("MV_MOEDA"+Str(nMoedaAux,1)),;
			               0, RecNo(), cPicture, nMoedaAux})
			nTotTits++
			If lPesqMoeda			
				nValTot += D1_TOTAL+nTotImps
				aTitulos[Len(aTitulos)][nPosValC] := D1_TOTAL+nTotImps
			Else
				nValTit := Round(xMoeda(D1_TOTAL+nTotImps,nMoedaAux,nMoedaCor,dDataMovto,nDecs+1,RecMoeda(dDataMovto,nMoedaAux)),nDecs)
				nValTot += nValTit
				aTitulos[Len(aTitulos)][nPosValC] := nValTit
			Endif
				
			// Determina em que arquivo os titulos ou o registro financeiro foi consultado.
			cAliasArq := "SD1"				         
		ElseIf aDados[nI][01] == "SL1"               
    		// Se a moeda eh diferente da selecionada pelo usuario
   			// desconsidera o registro...
			If lPesqMoeda
				If Empty(cPicture)
					cPicture := PesqPict("SL1","L1_VLRTOT",16,L1_MOEDA)
					cPictCor := cPicture        
					cSimbCor := SuperGetMv("MV_SIMB"+Str(L1_MOEDA,1))
					aCab[08] := STR0064+cSimbCor //"Valor em "
				Endif
			Else                            
				cPicture  := PesqPict("SL1","L1_CREDITO",16,MsDecimais(L1_MOEDA))
			Endif
				
			AAdd(aTitulos,{L1_NUM , L1_EMISSAO, L1_CLIENTE, L1_LOJA,;
			               Posicione("SA1",1,xFilial("SA1")+L1_CLIENTE+L1_LOJA,"A1_NOME"),;
			               L1_CREDITO, SuperGetMv("MV_MOEDA"+Str(L1_MOEDA,1)), 0, RecNo(),;
			               cPicture, L1_MOEDA })
			nTotTits++
			If lPesqMoeda			
				nValTot += L1_CREDITO
				aTitulos[Len(aTitulos)][nPosValC] := L1_CREDITO
			Else
				nValTit := Round(xMoeda(L1_CREDITO,L1_MOEDA,nMoedaCor,dDataMovto,nDecs+1,RecMoeda(dDataMovto,L1_MOEDA)),nDecs)
				nValTot += nValTit
				aTitulos[Len(aTitulos)][nPosValC] := nValTit
			Endif
				
			// Determina em que arquivo os titulos ou o registro financeiro foi consultado.
			cAliasArq := "SL1"				         
		Endif             
		
		// Restaura a area do arquivo no qual foi realizada a pesquisa...
		RestArea(aAreaArq)
	Next nI 
	
	// Caso o arquivo pesquisado tenha sido o SL4, em alguns casos pode ter sido
	// realizada a pesquisa dos titulos no SE1, por isso eh necessario retornar 
	// a sua area original.
	If !Empty(aAreaSE1)
		RestArea(aAreaSE1)
	Endif            
	     
	// Caso o arquivo pesquisado tenha sido o SE5, em alguns casos pode ter sido
	// necessario a pesquisa da moeda do caixa no arquivo SA6, por isso eh 
	// necessario retornar a sua area original.
	If !Empty(aAreaSA6)   
		RestArea(aAreaSA6)
	Endif                         
	
	// Caso o arquivo pesquisado tenha sido o SD1 eh necessario pesquisar no 
	// arquivo SF1 a moeda utilizada na devolução. 
	If !Empty(aAreaSF1)
		RestArea(aAreaSF1)
	Endif                         
	
	// Retorna a area original...
	RestArea(aAreaAtu)

	// Acerta as diferenças de arredondamento...	
	If !lPesqMoeda .AND. ((nDif := nValTot - &cArrayFoc.[nNumLinha][02]) <> 0)
		nDifDecs := 1/(10^nDecs)
		While nDif <> 0 
			For nI := 1 To Len(aTitulos)
				If aTitulos[nI][nPosMoeda] <> nMoedaCor
			   		If nDif > 0
						nDif 	-= nDifDecs	   			
			   			nValTot -= nDifDecs
			   			aTitulos[nI][nPosValC] -= nDifDecs
			   		Else
						nDif 	+= nDifDecs	   			
			   			nValTot += nDifDecs
			   			aTitulos[nI][nPosValC] += nDifDecs			   		
			   		Endif		
				Endif
			Next nI
		End
	Endif
	                               
	// Cria dialog para onde estara a ListBox com os titulos que serao exibidos
	// ao usuario.
	If !Empty(aTitulos)                                                     
		If cAliasArq <> "SL1"
			// Ordena os titulos por prefixo+numero+data de emissao.   
			aTitulos := aSort(aTitulos,,,{|x,y| x[nPosSerie]+x[nPosNumTit]+x[nPosParc]+DToS(x[nPosDtaEmi]) < ;
			                                    y[nPosSerie]+y[nPosNumTit]+y[nPosParc]+DToS(y[nPosDtaEmi]) })
		Else
			// Ordena os titulos por orcamento+dta de emissao+cliente+loja
			aTitulos := aSort(aTitulos,,,{|x,y| x[nPosNumTit]+DToS(x[nPosDtaEmi])+x[nPosCodCli]+x[nPosLoja] < ;
 	                                            y[nPosNumTit]+DToS(y[nPosDtaEmi])+y[nPosCodCli]+y[nPosLoja] })
		Endif

		DEFINE MSDIALOG oDlgTit FROM 0.1,0.1 TO 250,450 TITLE STR0065 PIXEL OF oMainWnd   //"Titulos"
	
	    //                         LS  CD  CE  LI
		oTitulos:= TWBrowse():New( 001,001,210,080,,aCab,aSizes,oDlgTit,,,,,,,,,,,, .F.,, .F.,, .F.,,,)
	    oTitulos:SetFont(oFnt)
		oTitulos:SetArray(aTitulos)
		oTitulos:bLine := {|| Lj031BLiTi(cAliasArq,aTitulos,oTitulos,cPicture,cPictCor)}
		                        
		@ 095, 005 SAY STR0066 SIZE 090,10 OF oDlgTit PIXEL Font oFntBold //"Cantidad de Titulos: "
		@ 095, 065 SAY oTotTis VAR nTotTits SIZE 42,10 OF oDlgTit PIXEL RIGHT Font oFntBold COLOR CLR_HRED Picture "9999"
	
		@ 100, 005 SAY STR0067 SIZE 090,10 OF oDlgTit PIXEL Font oFntBold //"Total de los Titulos: "
		@ 100, 065 SAY oValTot VAR nValTot SIZE 82,10 OF oDlgTit PIXEL RIGHT Font oFntBold COLOR CLR_HRED Picture cPicture
	
		@ 011, 025 BUTTON STR0068 SIZE 50,11 FONT oDlgTit:oFont ACTION (oDlgTit:End()) OF oDlgTit CANCEL //"Cancelar"
		@ 011, 040 BUTTON STR0069  SIZE 50,11 FONT oDlgTit:oFont ACTION Lj031Visu(cAliasArq,aTitulos,oTitulos) OF oDlgTit  //"Detalle"
		
		ACTIVATE MSDIALOG oDlgTit CENTERED
	Endif
Endif

Return(Nil) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Lj031Visu    ³Autor ³ Julio Cesar          ³Data³ 07/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama função para exibição dos titulos que compõe o valor  ³±±
±±³          ³ exibido na ListBox.                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj031Visu( cAliasArq  ,aTitulos  ,oTitulos )

// Valoriza com os dados do título que será exibido detalhadamente...
cCadastro := STR0070  +aTitulos[oTitulos:nAT][nPosNumTit]+; //"Titulo "
             STR0071+aTitulos[oTitulos:nAT][nPosSerie]+; //" Prefijo "
             STR0072  +aTitulos[oTitulos:nAT][nPosParc] //" Cuota "

(cAliasArq)->(dbGoTo(aTitulos[oTitulos:nAT][nPosRecNo]))
AxVisual(cAliasArq,aTitulos[oTitulos:nAT][nPosRecNo],2)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Lj031BLiTi   ³Autor ³ Julio Cesar          ³Data³ 07/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Formata as linhas que serão exibidas no ListBox de exibicao³±±
±±³          ³ dos titulos.                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj031BLiTi( cAliasArq  ,aTitulos   ,oTitulos   ,cPicture   ,;
                            cPictCor   )

Local aBLine := {}

If cAliasArq <> "SL1"
	aBLine := { aTitulos[oTitulos:nAt][nPosSerie] ,;
				aTitulos[oTitulos:nAt][nPosNumTit],;
				aTitulos[oTitulos:nAt][nPosParc]  ,;
				DToC(aTitulos[oTitulos:nAt][nPosDtaEmi]),;
				aTitulos[oTitulos:nAt][nPosCodCli],;
				aTitulos[oTitulos:nAt][nPosLoja]  ,; 
				aTitulos[oTitulos:nAt][nPosNomCli]}
Else                                                                
	aBLine := {	aTitulos[oTitulos:nAt][nPosNumTit],; 
				DToC(aTitulos[oTitulos:nAt][nPosDtaEmi]),;
				aTitulos[oTitulos:nAt][nPosCodCli],;
                aTitulos[oTitulos:nAt][nPosLoja]  ,;
                aTitulos[oTitulos:nAt][nPosNomCli]}
Endif

If cAliasArq == "SE5"
   	AAdd(aBLine,aTitulos[oTitulos:nAt][nPosHistor])
	AAdd(aBLine,aTitulos[oTitulos:nAt][nPosBenef])
	AAdd(aBLine,aTitulos[oTitulos:nAt][nPosDoc])
Endif

If cAliasArq == "SD1"
   	AAdd(aBLine,aTitulos[oTitulos:nAt][nPosSerOri])
	AAdd(aBLine,aTitulos[oTitulos:nAt][nPosNfOri]) 
	AAdd(aBLine,aTitulos[oTitulos:nAt][nPosItOri]) 
Endif

AAdd(aBLine,Transform(aTitulos[oTitulos:nAT][nPosVal],cPicture) )
AAdd(aBLine,aTitulos[oTitulos:nAt][nPosMoedE]        )
AAdd(aBLine,Transform(aTitulos[oTitulos:nAT][nPosValC],cPictCor))		

Return(aBLine)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Ljc031Fil³ Autor ³ Erik                  ³ Data ³ 30/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Criada para mostrar o nome da filial DE e ATE               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³Ljc031Fil(ExpC1,ExpC2)  			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = cNomFilDe (Nome Filial De)						  ³±±
±±³          ³ ExpC2 = cNomFilAte (Nome Filial Ate)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJC031                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			 ³		  ³811   ³											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ljc031Fil(cNomFilDe, cNomFilAte)

Local aArea   := GetArea()              //Area atual

DbSelectArea("SM0")					
DbSetOrder(1)                       	
If DbSeek(cEmpAnt+mv_par05)				
   cNomFilDe	 := SM0->M0_NOME		
EndIf
If DbSeek(cEmpAnt+mv_par06)				
   cNomFilAte	 := SM0->M0_NOME		
EndIf   

RestArea(aArea)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o	 ³DescriCabec  ºAutor  ³ Vendas Clientes º Data ³07/08/2000   º±±    
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca Descricao da forma de pagameto no SX5 pelo parametro  º±±
±±º          ³(Chv) se não encontrar retorna (Str)                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function 	DesCabec031( Chv, Str )
Local 		aArea	:= GetArea()	// Area Atual

Default		Chv 	:= '$'
Default		Str 	:= STR0022		//Dinheiro

DbSelectArea( "SX5" )

If DbSeek( xFilial( "SX5" ) + "24" + Chv )
    Str	:= Capital( Alltrim( X5Descri() ) )
EndIf
RestArea( aArea )

Return ( Str )
