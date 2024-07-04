#INCLUDE "PROTHEUS.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "LOJA764.CH"

Static lMulPas	:= .F.
Static cFormtTrs := PesqPict("SL1","L1_VLRTOT")
Static oBtAdSim		:= Nil					//Botใo Simular
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณLjTEFTela บAutora ณSolange Zanardi     บ Data ณ  12/14/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a abertura da tela de interacao cupom TEF            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณParametrosณoExp1 -Obj Multi Negocia็ใo								  บฑฑ
ฑฑณ          ณnExp2 -Modeda					  							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Lj76TelNeg(oMultNegoc, nMoeX)

Local nGetOp 		:= 0					//Recebe valor de opcao
Local cMens			:= "" 					//Titulo
Local oDlgNg       	:= Nil           		//Tela
Local oFontMens    	:= Nil					//Fonte padrao
Local oFontPad     	:= Nil					//Fonte
Local cMvSimb		:= "" 					// Moeda
Local cGetPar	    := "000"				//Get de Parcelas
Local oListBox 		:= Nil 					//List Box
Local oSay2 		:= Nil					//Total a Prazo
Local oSay3			:= Nil					//Nota de Cr้dito Cliente:
Local oSay5			:= Nil 					//Total Geral:
Local oSay6 		:= Nil					//Arred. Ultima. Parcela:
Local oFont1 := TFont():New("Arial",,018,,.T.,,,,,.F.,.F.)			//Fote de resumo
Local oFont2 := TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)	//Fote de resumo
Local oRetItem 	:= Nil 						//Retorno do instens Mn
Local aFabric	:= {}						//Array com os daos
Local oBtAdEnt	:= Nil						//Botam adiciona Entrada
Local oBtZeraEnt:= Nil						//Botao Zerar Valor de Entrada
Local oListBox03:= Nil						//Valor da Entrada
Local oGetEnt 	:= Nil						//Tipo de Entrad
Local oGetVEnt	:= Nil						//Tipo de Entrad
Local nGetVEnt	:= 0						//Valor de Entrad
Local cSaldoEnt	:= "0"  					//Saldo Entrad
Local nGetIten	:= 0                       	//Lista da entrada
Local aRetForList 	:= {}                  	//Array Lis Simo
Local oTelReMn		:= LJCTelReMn():New()	//Objetos com a tela de simmulados
Local dVencimento	:= dDataBase + 30		//Vencimento de Parcela
Local nValJurDIa	:= 0					//Valor de Juros Por dia
Local aRetMn		:= {}					//Retorno da fu็ใo
Local oBtFechar		:= Nil					//Botใo fechar
Local aMn			:= {}					//Array com  MN
Local oPanA			:= Nil					//Painel A
Local oPanB			:= Nil					//Painel b
Local oPanSup01		:= Nil					//Superior
Local oPanMei01		:= Nil                 	//Meio
Local oPanInf01		:= Nil                  //Inferior
Local oPanSup02		:= Nil 					//LayerB
Local oPanInf02		:= Nil 					//LayerB
Local aFPEnInf		:= {}					//Entrada
Local nMagSay 		:= 180					//Magrgem  090
Local oPanel1 		:= Nil					//Painel
Local oSayTrav 		:= Nil					//TRANSFERENCIA
Local oBtConfirma	:= Nil					//Confirma Mn
Local nDescont      := 0                    // Valor desconto da Multinegocia็ใo
Local lLJ7091		:= ExistBlock("LJ7091") // Verifica a existencia do PE LJ7091
Local alLJ7091		:= {}					// Array de parametro do PE LJ7091
Local nPosMn		:= 0
Local nPosCond		:= 0
Local lMNAcresci  	:= SuperGetMV("MV_LJMNACR",,.T.)
Local oMultPgto     := Nil
Local aSize         := MsAdvSize(.F.,.F.)
Local aResumNeg     := {}
Local oGetTxJuros   := Nil
Local oGetdesVenc   := Nil
Local nGetTxJrs     := 0
Local nGetDescV     := SuperGetMV("MV_LJMNDES",,0)
Local oCapTxJuros   := Nil
Local oCapDesVenc   := Nil
Local cTxSalEnt     := "Saldo entrada: "
Local aRecTotal     := {}
Local cCodCaixa     := xNumCaixa()
Local lJurDesc      := LJ764PermJD(cCodCaixa)	// Verifica se o Usuario tem poermissao para alterar o Juros ou o Desconto.
Local oGetdesParc	:= Nil
Local nGetParce     := 0
Local oGetDtFixo	:= Nil
Local dGetDtFixo    := dDataBase
Local oCapDFixo     := Nil
Local nAuxPac       := 0
Local lProcessa     := .t.
Local lPermTxDes	:= SuperGetMv("MV_LJMNPER", , .F. ) 

Default nMoeX		:= 0
Default oMultNegoc	:= Nil

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica simbolo de moedaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nModulo == 12
	cMvSimb	:= AllTrim(SuperGetMV("MV_SIMB"+Alltrim(STR(nMoedaCor)))) 	// Moeda
Else
	cMvSimb	:= AllTrim(SuperGetMV("MV_SIMB"+Alltrim(STR(nMoeX)))) 		// Moeda
EndIf

If nGetDescV >= 100 .Or. nGetDescV < 0  .Or. !lPermTxDes  // nao de ter desconto de 100% e o valor nใo pode ser menor que 0
	nGetDescV := 0
EndIf 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrega Mn      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aMn := LJ164MNeg(oMultNegoc)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Tela de Opcoes de Negociacao					ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlgNg TITLE STR0005 FROM 0, 0 TO aSize[6], aSize[5] PIXEL

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFontes utilizadasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE FONT oFontMens	NAME "Arial" 		SIZE 12,20
DEFINE FONT oFontPad	NAME "Arial" 		SIZE 07,17 BOLD

cMens := STR0049				//"Multi Negocia็ใo"

oFwLayerMaster := FwLayer():New()
oFwLayerMaster:init(oDlgNg,.F.)

oFwLayerMaster:addLine("LINHA01", 	100, .T.)

oFwLayerMaster:addCollumn("COLENT01",35, .T. , "LINHA01")
oFwLayerMaster:addCollumn("COLENT02",35, .T. , "LINHA01")
oFwLayerMaster:addCollumn("COLENT03",30, .T. , "LINHA01")

oPanA := oFwLayerMaster:getColPanel("COLENT01","LINHA01")
oPanB := oFwLayerMaster:getColPanel("COLENT02","LINHA01")
oPanC := oFwLayerMaster:getColPanel("COLENT03","LINHA01")

oFwLayerA := FwLayer():New()
oFwLayerA:init(oPanA,.F.)

oFWLayerA:addLine("LINHA01", 	30, .T.)
oFWLayerA:addLine("LINHA02",	30, .T.)
oFWLayerA:addLine("LINHA03",	40, .T.)

oFWLayerA:addCollumn("COLENT01",100, .T. , "LINHA01")
oFWLayerA:addCollumn("COLENT01",100, .T. , "LINHA02")
oFWLayerA:addCollumn("COLENT01",100, .T. , "LINHA03")


oFwLayerB := FwLayer():New()
oFwLayerB:init(oPanB,.F.)

oFWLayerB:addLine("LINHA01",	66, .T.)
oFWLayerB:addLine("LINHA02",	34, .T.)

oFWLayerB:addCollumn("COLENT02",100, .T. , "LINHA01")
oFWLayerB:addCollumn("COLENT02",100, .T. , "LINHA02")

oFwLayerC := FwLayer():New()
oFwLayerC:init(oPanC,.F.)
oFWLayerC:addLine("LINHA01",	100, .T.)
oFWLayerC:addCollumn("COLENT03",100, .T. , "LINHA01")

oFWLayerA:addWindow("COLENT01", "WINENT", STR0005	, 100, .T., .T., , "LINHA01") //"Multi Negocia็ใo"
oFWLayerA:addWindow("COLENT01", "WINENT", STR0013	, 100, .T., .T., , "LINHA02") //"Forma de Pagamento"
oFWLayerA:addWindow("COLENT01", "WINENT", STR0014	, 100, .T., .T., , "LINHA03") //"Entrada"

oFWLayerB:addWindow("COLENT02", "WINENT", STR0015	, 100, .T., .T., , "LINHA01") //"Simulado de Parcelas"
oFWLayerB:addWindow("COLENT02", "WINENT", STR0016	, 100, .T., .T., , "LINHA02") //"Resumo"

oFWLayerC:addWindow("COLENT03", "WINENT", "Resumo das Negocia็๕es"	, 100, .T., .T., , "LINHA01") //Resumo das Negociacoes
// Coluna 01
oPanSup01 := oFWLayerA:GetWinPanel("COLENT01","WINENT","LINHA01")
oPanMei01 := oFWLayerA:GetWinPanel("COLENT01","WINENT","LINHA02")
oPanInf01 := oFWLayerA:GetWinPanel("COLENT01","WINENT","LINHA03")

// Coluna 02
oPanSup02 := oFWLayerB:GetWinPanel("COLENT02","WINENT","LINHA01")
oPanInf02 := oFWLayerB:GetWinPanel("COLENT02","WINENT","LINHA02")

// Coluna 03
oPanSup03 := oFWLayerC:GetWinPanel("COLENT03","WINENT","LINHA01")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณListBox 01 - Multi Negocia็ใoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ 0,0 ListBox oListBox Fields ;
HEADER STR0017 ,STR0018 , STR0019; 	// "C๓digo" ,"Descri็ใo" , "Valor"
Size oPanSup01:nWidth/2, oPanSup01:nHeight/2 Of oPanSup01 Pixel;
ColSizes 40, 30, 30, 30, 30, 30, 30, 30  ON CHANGE(nGetOp	:= oListBox:nAt)
oListBox:SetArray(aMn)
oListBox:bLine 		:= {||{aMn[oListBox:nAT,01],aMn[oListBox:nAT,02],aMn[oListBox:nAT,03]}}
oListBox:bChange 	:= {||	LJ164FmPgs(oMultNegoc,aMn[oListBox:nAT,01], @oListBox02, @oRetItem, @oGetEnt), ;
							Lj764AtSal(	@cSaldoEnt	, 	@oListBox02		, @oCapSalEnt	, @aFPEnInf, 	;
										@oListBox03	, 	Nil				, @oTelReMn		, @oListBox01B, ;
										@aRetForList, 	@oMultNegoc		, @oBtZeraEnt   , @nGetVEnt,	;
										@aResumNeg	,	@aRecTotal		, @oListBoxRn   , @oBtAdEnt,	;
										@oGetVEnt	,	nAuxPac			, @nGetTxJrs	, oGetTxJuros	) }

oListBox:lHScroll := .T.
oListBox:lVScroll := .T.
oListBox:Refresh()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณListBox 02 Itensณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ 0,0 ListBox oListBox02 Fields ;
HEADER STR0020 , STR0021 ,  STR0022, STR0023, STR0024 , STR0025, STR0026;				//"Tipo" , "Adm Fin" ,  "Parc De:", "Parc At้:", "Taxa de Juros" , "Tipo de Juros", "Valor da Entrada"
Size oPanMei01:nWidth/2, oPanMei01:nHeight/2 Of oPanMei01 Pixel;
ColSizes 10, 30, 30, 30, 30   ON CHANGE(nGetIten	:= 	oListBox02:nAt, ;
														Lj764AtSal(	@cSaldoEnt	, 	@oListBox02, 	@oCapSalEnt	, @aFPEnInf, ;
																	@oListBox03	,	Nil, 			@oTelReMn	, @oListBox01B, ;
																	@aRetForList, 	@oMultNegoc,	@oBtZeraEnt , @nGetVEnt,	;
																	@aResumNeg 	,	@aRecTotal,		@oListBoxRn	, @oBtAdEnt,	;
																	@oGetVEnt	,	@nAuxPac,		@nGetTxJrs	, oGetTxJuros) )

oListBox02:bLostFocus := {||lj764CarEnt(oRetItem, oListBox02:nAt, @oGetEnt,@oBtAdEnt,@nGetTxJrs), ;
							Lj764AtSal(	@cSaldoEnt	, 	@oListBox02, 	@oCapSalEnt	, @aFPEnInf, ;
										@oListBox03	,	Nil, 			@oTelReMn	, @oListBox01B, ;
										@aRetForList, 	@oMultNegoc,	@oBtZeraEnt , @nGetVEnt,	;
										@aResumNeg 	,	@aRecTotal,		@oListBoxRn	, @oBtAdEnt,	;
										@oGetVEnt	,	@nAuxPac,		@nGetTxJrs	, oGetTxJuros)}
oListBox02:bChange 	:= {||lj764AtuGet(oRetItem, oListBox02:nAt, @oGetEnt,@nGetTxJrs,@oGetTxJuros,@nGetIten) }
oListBox02:lHScroll := .T.
oListBox02:lVScroll := .T.
oListBox02:SetFocus()
oListBox02:bLDBLClick := {||oGetEnt:SetFocus(), nGetParce := oListBox02:AARRAY[oListBox02:nAt][4],;
							nGetVEnt := oListBox02:AARRAY[oListBox02:nAt][7]} 

LJ164FmPgs(oMultNegoc,  aMn[oListBox:nAT,01],  @oListBox02, @oRetItem)

aFPEnInf := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณListBox 03 Entradaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

AaDD(aFPEnInf,{"","",""})

@ 0,0  ListBox oListBox03 Fields ;
HEADER STR0020 ,STR0019 ; 	//"Tipo" ,"Valor"
Size oPanInf01:nWidth/2, oPanInf01:nHeight/8 Of oPanInf01 Pixel;
ColSizes 40, 30 ON CHANGE(nGetOp := oListBox03:nAt)
oListBox03:SetArray(aFPEnInf)
oListBox03:bLine := {||{aFPEnInf[oListBox03:nAT,01],aFPEnInf[oListBox03:nAT,02]}}
oListBox03:lHScroll := .T.
oListBox03:lVScroll := .T.
oListBox03:Refresh()

@ oPanInf01:nTop +10 , 2 COMBOBOX oGetEnt VAR cGetPar SIZE 60, 8  OF oPanInf01 ITEMS aFabric PIXEL
@ oPanInf01:nTop + 10, 65 MSGET oGetVEnt VAR nGetVEnt PICTURE PesqPict("SL1","L1_VLRTOT") SIZE 55, 7 OF oPanInf01 PIXEL

@ oPanInf01:nTop + 25, 2 MSGET 	oGetTxJuros	VAR nGetTxJrs PICTURE "@E 99.99" SIZE 15, 7 OF oPanInf01 PIXEL
If(!lJurDesc .or. !lPermTxDes ,oGetTxJuros:Hide(),)

@ oPanInf01:nTop + 25, 35 SAY oCapTxJuros PROMPT "Tx.Juros" SIZE 57, 6 OF oPanInf01 PIXEL // Tx. Juros - Vermelho COLORS 255, 16777215
If(!lJurDesc .or. !lPermTxDes ,oCapTxJuros:Hide(),)

@ oPanInf01:nTop + 25, 60 MSGET oGetdesVenc VAR nGetDescV PICTURE "@E 99.99" SIZE 15, 7 OF oPanInf01 PIXEL
If(!lJurDesc .or. !lPermTxDes ,oGetdesVenc:Hide(),)

@ oPanInf01:nTop + 25, 90 SAY oCapDesVenc PROMPT "Desc.Venc." SIZE 57, 6 OF oPanInf01 PIXEL // Desc. Ate Venc.
If(!lJurDesc .or. !lPermTxDes ,oCapDesVenc:Hide(),)

@ oPanInf01:nTop + 40, 2 MSGET oGetDtFixo VAR dGetDtFixo PICTURE "99/99/9999" SIZE 40, 7 OF oPanInf01 PIXEL ;
VALID IIF(Lj764VlVen(dGetDtFixo, oMultNegoc:ODADOSITEN:ACOLECAO[oListBox02:nAT][2]:NLIM1PA), .T., (dGetDtFixo := DDATABASE, oGetDtFixo:Refresh(), .F.))

@ oPanInf01:nTop + 40, 45 SAY oCapDFixo PROMPT "Data 1 Parcela" SIZE 57, 6 OF oPanInf01 PIXEL 	// Quantidade de Parcelas.

@ oPanInf01:nTop + 40, 90 MSGET oGetdesParc VAR nGetParce PICTURE "@E 99" SIZE 15, 7 OF oPanInf01 PIXEL ;
VALID Lj764VParc(aFPEnInf,nGetParce)
If(!lJurDesc .or. !lPermTxDes ,oGetdesParc:Hide(),)

@ oPanInf01:nTop + 40, 105 SAY oCapParc PROMPT "Q. Parc." SIZE 57, 6 OF oPanInf01 PIXEL // Quantidade de Parcelas.
If(!lJurDesc .or. !lPermTxDes ,oCapParc:Hide(),)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona Valor da Entradaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oBtAdEnt := tButton():New(oPanInf01:nTop + 10, 119,"&Entrada"								,; // "&Entrada"
oPanInf01,{||Lj764AdEnt(@oGetEnt				, @nGetVEnt		, @oListBox03	, @aFPEnInf		,;
						oMultNegoc:GetValor()	, @oListBox02	, @oSaldoEnt	, @oCapSalEnt	,;
						@oBtAdSim				, @cSaldoEnt	, @oGetVEnt		, @oTelReMn		,;
						@oMultNegoc				, @aRetForList	, @oListBox01B	, @oBtZeraEnt	,;
						@oBtAdEnt				, @cTxSalEnt 	)},(23),(10),,,,.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณZera as parcelas de Financiamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oBtZeraEnt :=tButton():New(oPanInf01:nTop + 10, 144,"&Limpa" ,; //"Zerar Entrada"
oPanInf01,{|| LJ164FmPgs(oMultNegoc,aMn[oListBox:nAT,01], @oListBox02, @oRetItem, @oGetEnt, @oBtAdEnt	), ;
							Lj764AtSal(	@cSaldoEnt	, 	@oListBox02		, @oCapSalEnt	, @aFPEnInf, 	;
										@oListBox03	, 	Nil				, @oTelReMn		, @oListBox01B, ;
										@aRetForList, 	@oMultNegoc		, @oBtZeraEnt	, @nGetVEnt,	;
										@aResumNeg	,	@aRecTotal		, @oListBoxRn	, @oBtAdEnt,;
										@oGetVEnt	,	@nAuxPac		, @nGetTxJrs 	, oGetTxJuros )},(23),(10),,,,.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSimula Parcelas de Financiamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oBtAdSim := tButton():New(oPanInf01:nTop + 10, 169, STR0029		,; //"&Simular"
oPanInf01,{||	Lj764CalPar(oRetItem, nGetIten, oMultNegoc:GetValor(), Lj764GetEnt(aFPEnInf), @oMultNegoc, @oListBox01B,;
                           @aRetForList,NIL,NIL,NIL,lMNAcresci,nGetVEnt,cGetPar,@oMultPgto,aResumNeg,nGetTxJrs,aRecTotal,;
                           nGetDescV,nGetParce,dGetDtFixo,nAuxPac), ;
				oTelReMn:cSayDifPar := aRetForList[oListBox01B:nAT,08] , oTelReMn:oSayDifPar:Refresh(), oTelReMn:AtuTudo(oMultNegoc, oListBox01B:nAt,aRecTotal), oBtZeraEnt:lVisible := .T.,},(23),(10),,,,.T.) 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSaldo da entradaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oBtZeraEnt:lVisible := .F.
oBtAdSim:lVisible := .F.
cSaldoEnt := "000.00" //91
@ oPanInf01:nTop + 60, 2 SAY oCapSalEnt Var cTxSalEnt SIZE 085, 009 OF oPanInf01 FONT oFont1 COLORS 255, 16777215 PIXEL // "Saldo entrada: " 255, 16777215
@ oPanInf01:nTop + 60, 105 SAY oSaldoEnt  Var cSaldoEnt SIZE 085, 009 OF oPanInf01 FONT oFont1 COLORS 255, 16777215 PIXEL


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณListBox 01 - Simuladoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aadd(aRetForList,{"", "", "", "", "", "", "",""})
If lMNAcresci
	oListBox01B := Nil
	@ 0,0 ListBox oListBox01B Fields ;
	HEADER STR0020 ,STR0031 , STR0032 ,  STR0033, STR0068 , STR0034, STR0035; // "Tipo", "Qtd. Pac" , "Valor Parc" ,  "Tot. Prazo","Tot Ate Venc" , "Acr้scimo", "Venc 1บ Parcela"
	Size oPanSup02:nWidth/2, oPanSup02:nHeight/2 Of oPanSup02 Pixel;
	ColSizes 15, 20, 25, 25, 10, 10,20,10  ON CHANGE(	nGetOp	:= 	oListBox01B:nAt, oTelReMn:cSayDifPar := aRetForList[oListBox01B:nAT,08] , ;
															oTelReMn:oSayDifPar:Refresh(),;
															oTelReMn:AtuTudo(oMultNegoc, oListBox01B:nAt,aRecTotal) )
Else
	oListBox01B := Nil
	@ 0,0 ListBox oListBox01B Fields ;
	HEADER STR0020 ,STR0031 , STR0032 ,  STR0033, STR0068 , STR0035; // "Tipo", "Qtd. Pac" , "Valor Parc" ,  "Tot. Prazo" ,"Tot Ate Venc", "Venc 1บ Parcela"
	Size oPanSup02:nWidth/2, oPanSup02:nHeight/2 Of oPanSup02 Pixel;
	ColSizes 20, 25, 30, 30, 30 , 10, 10  ON CHANGE(	nGetOp	:= 	oListBox01B:nAt, oTelReMn:cSayDifPar := aRetForList[oListBox01B:nAT,08] , ;
															oTelReMn:oSayDifPar:Refresh(),;
															oTelReMn:AtuTudo(oMultNegoc, oListBox01B:nAt,aRecTotal) )
EndIf

oListBox01B:SetArray(aRetForList)
oListBox01B:bLine := {||{	aRetForList[oListBox01B:nAT,01],;
							aRetForList[oListBox01B:nAT,02],;
							aRetForList[oListBox01B:nAT,03],;
							aRetForList[oListBox01B:nAT,04],;
							aRetForList[oListBox01B:nAT,05],;
							aRetForList[oListBox01B:nAT,07]}}
oListBox01B:lHScroll := .T.
oListBox01B:lVScroll := .T.
oListBox01B:Refresh()

oListBox01B:bLDBLClick		:= {||lCalcDesc := Lj746AdRN(oMultPgto,@aResumNeg,oListBox01B:nAt,oListBoxRn,oListBox03,oMultNegoc,@cSaldoEnt,oListBox02,@aFPEnInf,oMultNegoc:GetValor(),;
                                                          @nGetVEnt,oGetVEnt,oSaldoEnt,@aRecTotal,@aRetForList,@oListBox01B,nGetParce,@nAuxPac,oRetItem,nGetIten), Iif (lCalcDesc, Lj764CalPar(oRetItem, nGetIten, oMultNegoc:GetValor(),;
                                                           Lj764GetEnt(aFPEnInf), @oMultNegoc, @oListBox01B, @aRetForList, dVencimento, nValJurDIa, nDescont,Nil,Nil,Nil,Nil,aResumNeg), lCalcDesc := .F.), ;
									oTelReMn:cSayDifPar := aRetForList[oListBox01B:nAT,08] , oTelReMn:oSayDifPar:Refresh(), oTelReMn:AtuTudo(oMultNegoc, oListBox01B:nAt,aRecTotal),LimpaSimul(oMultNegoc,oListBox01B,aRetForList), oListBoxRn:SetFocus()  }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณListBoxRn - Resumo das Negociacoes ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aadd(aResumNeg,{"","", "", "","",""})

	oListBoxRn := Nil
	@ 0,0 ListBox oListBoxRn Fields ;
	HEADER "Venc. Parcela" ,"Val. Parcela" ,"Tipo","Desc. ate Venc.","Val Parc. c/ Desc.","ID Cartใo" ; // "Venc. Parcela" ,"Val. Parcela" ,"Tipo","V Parc Pos Venc"
	Size oPanSup03:nWidth/2, oPanSup03:nHeight/4 + 30 Of oPanSup03 Pixel;
	ColSizes 30, 30, 15,35  ON CHANGE(  )
oListBoxRn:SetArray(aResumNeg)
oListBoxRn:bLine := {||{	aResumNeg[oListBoxRn:nAT,01],;
							aResumNeg[oListBoxRn:nAT,02],;
							aResumNeg[oListBoxRn:nAT,03],;
							aResumNeg[oListBoxRn:nAT,04],;
							aResumNeg[oListBoxRn:nAT,05],;
							aResumNeg[oListBoxRn:nAT,06]}}

oListBoxRn:lHScroll := .T.
oListBoxRn:lVScroll := .T.
oListBoxRn:bLDBLClick := {|| 	Lj7MudaID(@aResumNeg, oListBoxRn:nAT) } 
oListBoxRn:Refresh()

//ฺฤฤฤฤฤฤฤฤฤฟ
//ณResultadoณ
//ภฤฤฤฤฤฤฤฤฤู
nMagSay := 125 //180 //200
oPanel1 := Nil
oSayTrav := nIL

oTelReMn:cSayNcc := PADL(AllTrim(TRANSFORM(oMultNegoc:GetValNcc(), cFormtTrs) ), 15)

@ 046, 000 MSPANEL oPanel1 SIZE 147, 013 OF oPanInf02 COLORS 65535, 16777215 LOWERED

@ 003, 001 SAY oSay1 PROMPT STR0036 SIZE 085, 009 OF oPanInf02 FONT oFont1 COLORS 0, 16777215 PIXEL		// 	"Valor da Entrada:"
@ 014, 001 SAY oSay2 PROMPT STR0037	SIZE 085, 007 OF oPanInf02 FONT oFont2 COLORS 255, 16777215 PIXEL 	// 	"Total a Prazo:"
@ 026, 001 SAY oSay5 PROMPT STR0038	SIZE 085, 007 OF oPanInf02 FONT oFont1 COLORS 0, 16777215 PIXEL 	//	"Total Geral:"

@ 037, 001 SAY oSayTrav PROMPT   Replicate("-",350) 	SIZE 300, 007 OF oPanInf02 FONT oFont1 COLORS 0, 16777215 PIXEL

@ 049, 001 SAY oSay6 PROMPT STR0039	SIZE 085, 007 OF oPanInf02 FONT oFont1 COLORS 0, 16777215 PIXEL	// "Arred. Ultima. Parcela:"
@ 061, 001 SAY oSay3 PROMPT STR0040	SIZE 110, 007 OF oPanInf02 FONT oFont1 COLORS 0, 16777215 PIXEL	//"Nota de Cr้dito Cliente:"

@ 003, nMagSay SAY oTelReMn:oSayEnt 	Var oTelReMn:cSayEnt 		SIZE 050, 008 OF oPanInf02 FONT oFont1 COLORS 0, 	16777215 PIXEL
@ 014, nMagSay SAY oTelReMn:oSayVFin  	Var oTelReMn:cSayVFin 		SIZE 050, 008 OF oPanInf02 FONT oFont2 COLORS 255, 	16777215 PIXEL
@ 026, nMagSay SAY oTelReMn:oSayTotG 	Var oTelReMn:cSayTotG 		SIZE 050, 008 OF oPanInf02 FONT oFont1 COLORS 0, 	16777215 PIXEL
//------------------------------------------------------------------------------------------------------------------------------------
@ 049, nMagSay SAY oTelReMn:oSayDifPar 	Var oTelReMn:cSayDifPar 	SIZE 050, 008 OF oPanInf02 FONT oFont1 COLORS 0, 	16777215 PIXEL
@ 061, nMagSay SAY oTelReMn:oSayNcc 	Var oTelReMn:cSayNcc 		SIZE 050, 008 OF oPanInf02 FONT oFont1 COLORS 0, 	16777215 PIXEL

oTelReMn:Zera()

//275
oBtFechar 	:=tButton():New(oPanSup03:nHeight/4 + 40, 5, STR0042	, oPanSup03,{||aRetMn := {}, oDlgNg:End() },50,16,,,,.T.) // "&Fechar"
oBtConfirma :=tButton():New(oPanSup03:nHeight/4 + 40, 60, STR0041	, oPanSup03,{||Loj764VConf(aResumNeg,@lProcessa,oBtConfirma,oMultNegoc:GetValor()), If (lProcessa, aRetMn := Lj764Conf(oMultNegoc, oListBox01B:nAt, oRetItem, oListBox02:nAt, aFPEnInf,aResumNeg,@oDlgNg,aRecTotal), aRetMn:= {} ), nPosMn := oListBox:nAT, nPosCond := oListBox02:nAt },50,16,,,,.T.)  // "&Confirma"

ACTIVATE MSDIALOG oDlgNg CENTERED

lMulPas := .T.

If Len(aRetMn) > 0 //Confirmar

	If SLQ->( FieldPos( "LQ_CODMNEG" ) ) > 0 .And. SL1->( FieldPos( "L1_CODMNEG" ) ) > 0
		M->LQ_CODMNEG := aMn[nPosMn][1]
	EndIf

	If lLJ7091
		aAdd( alLJ7091 , aRetMn ) //Simulado do Multi Negocia็ใo
		aAdd( alLJ7091 , iIf( Len(aFPEnInf) > 0 .And. !Empty(aFPEnInf[1,1]), aFPEnInf, {}) ) //Info. Valor de Entrada
		aAdd( alLJ7091 , iIf( Len(aMn) >= nPosMn, Val(aMn[nPosMn][3]), 0 )) //Valor original
		aAdd( alLJ7091 , iIf( nPosCond >= 1, oRetItem:Elements(nPosCond):nTxJuro, 0 )) //% Juros
		aRetMn := ExecBlock("LJ7091",.F.,.F.,alLJ7091)
	EndIf

EndIf

Return(aRetMn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณLJ164MNeg บAutora ณSolange Zanardi     บ Data ณ  12/14/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua Implemta็ใo do objeto MN                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnExp1 -Obejeto Mn       									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LJ164MNeg(oMultNegoc)

Local aRet 		:= {}					// Variavel de retorno
Local oRetCab 	:= oMultNegoc:oDadosCab	// Itens do cabe็a็ho
Local nX		:= 0                  	// Contador
Local cUser    := RetCodUsr()
Local aMNCad   := {}
Default oMultNegoc	:= Nil

For nX := 1 To oRetCab:Count()

	aAdd(aRet, {oRetCab:Elements(nX):cCodigo,oRetCab:Elements(nX):cDescricao, AllTrim(TRANSFORM(oMultNegoc:nValor,cFormtTrs)) })

Next nX

    aSort(aRet,,, { |x, y| x[1] < y[1] } )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณChamada o Ponto de LJ764MN1 para que o Usuario possa manipular     ณ
//ณo cadastro de Multi-Negociacao Conforme sua necessidade.           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock( "LJ764MN1" )
	aMNCad :=ExecBlock( "LJ764MN1", .F., .F., {aRet ,cUser} )
	If ValType( aMNCad ) == "A" .And. Len(aMNCad) > 0
		aRet := aMNCad
	EndIf
EndIf
Return(aRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณlj764CarEnบAutora ณSolange Zanardi     บ Data ณ  12/14/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona os itens no objeto do comobx da forma de pgto      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoExp1 -Obejeto Mn itens  									  บฑฑ
ฑฑบ			 ณnExp1 -Iten       										  บฑฑ
ฑฑบ          ณoExp1 -Entrada	       									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function lj764CarEnt(oRetItem, nIten, oGetEnt,oBtAdEnt,nGetTxJrs)

Local cEntrada 	:= ""
Local aFPent	:= {}
Local aBkArea	:= GetArea()
Local nX		:= 0
Local aFormas   := {}
Local nY        := 2

Default oRetItem  	:= Nil
Default nIten    	:= 0
Default oGetEnt    	:= Nil
Default oBtAdEnt    := Nil

If Valtype(oGetEnt) <> "U" .AND. ValType(oRetItem) <> "U"
	If  !Empty(oRetItem:Elements(nIten):FPEnt)
		If oRetItem:Elements(nIten):nEntrada > 0
			cEntrada 	:= oRetItem:Elements(nIten):FPEnt
		Else
			cEntrada 	:= oRetItem:Elements(nIten):cForma
		EndIf
		aFormas		:= StrToArray(cEntrada, ";")
		DbSelectArea("SX5")
		DbSetOrder(1)			//X5_FILIAL+X5_TABELA+X5_CHAVE
	EndIf

   	If ascan(aFormas , { |x| x == "FI" }) > 0 .And. oRetItem:Elements(nIten):nEntrada == 0
	   	aFPent := array(Len(aFormas))
		aFPent[1] := "FI"
		For nX := 1 to Len(aFormas)
			If !aFormas[nX] == "FI"
				aFPent[nY] := aFormas[nX]
				nY++
			EndIf
		Next nX
	Else
		aFPent := aClone (aformas)
	EndIf

	If Len(aFPent) > 0
		For nX := 1 To Len(aFPent)
			If DbSeek(xFilial("SX5")+ "24"+ aFPent[nX])
				aFPent[nX] += " - " + sx5->X5_DESCRI
			Endif
		Next nX


		oGetEnt:aItems := aClone(aFPent)
		If ascan(aFPent , { |x| x == "FI" }) > 0 .And. oRetItem:Elements(nIten):nEntrada == 0
			oGetEnt:Select(ascan(aFPent , { |x| x == "FI" }))
		EndIf
	Else
		oGetEnt:aItems := {""}
	EndIf
	nGetTxJrs := oRetItem:Elements(nIten):nTxJuro
	oGetEnt:Refresh()
	RestArea(aBkArea)

EndIf

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณLj764AdEntบAutora ณSolange Zanardi     บ Data ณ  12/14/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a abertura da tela de interacao cupom TEF            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoExp01 -Obejeto COM entra 								  บฑฑ
ฑฑบ			 ณnExp02 -Tela       										  บฑฑ
ฑฑบ          ณoExp03 -ListBpx 01	       								  บฑฑ
ฑฑบ          ณaExp04 -Array com entradas								  บฑฑ
ฑฑบ          ณnExp05 -Valor da Venda    								  บฑฑ
ฑฑบ          ณoExp06 -List Box 2	       								  บฑฑ
ฑฑบ          ณoExp07 -Saldo da entradaEntrada	       					  บฑฑ
ฑฑบ          ณoExp08 -Saldo da entradaEntrada							  บฑฑ
ฑฑบ          ณoExp09 -Botใo de simulado									  บฑฑ
ฑฑบ          ณcExp10 -Salda de entrada	       							  บฑฑ
ฑฑบ          ณoExp11 -Get do Valor da Venda  							  บฑฑ
ฑฑบ          ณoExp12 -tela	       									      บฑฑ
ฑฑบ          ณoExp13 -Multi negocia็ใo									  บฑฑ
ฑฑบ          ณaExp14 -Simula็ใo	       									  บฑฑ
ฑฑบ          ณoExp15 -lista	       									  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Lj764AdEnt(	oGetEnt		, nEndDig		, oListBox03	, aFPEnInf		,;
							nValTot		, oListBox02	, oSaldoEnt		, oCapSalEnt	,;
							oBtAdSim	, cSaldoEnt		, oGetVEnt		, oTelReMn		,;
							oMultNegoc	, aRetForList	, oListIten		, oBtZeraEnt	,;
							oBtAdEnt	, cTxSalEnt		)
	
Local cFm 		:= ""
Local cValor    := ""
Local nValTmp	:= 0
Local nEnt		:= 0
Local cTipEnt	:= 0

Default oGetEnt 	 := Nil
Default nEndDig	 	:= 0
Default oListBox03	 := Nil
Default aFPEnInf	 := {}
Default nValTot	 := 0
Default oListBox02	 := Nil
Default oSaldoEnt	 := Nil
Default oCapSalEnt	 := Nil
Default oBtAdSim	 := Nil
Default cSaldoEnt	 := ""
Default oGetVEnt	 := Nil
Default oTelReMn	 := Nil
Default oMultNegoc	 := Nil
Default aRetForList := ""
Default oListIten	 := Nil
Default oBtZeraEnt	 := Nil
Default cTxSalEnt   := ""

nEnt 	:=	oListBox02:AARRAY[oListBox02:nAt][7]
cTipEnt :=	SubStr(oGetEnt:AITEMS[oGetEnt:NAT],1,At("-",oGetEnt:AITEMS[oGetEnt:NAT] ) - 2)
oTelReMn:Zera()

If nEnt <> 0 .And. !Empty(cTipEnt)

	nValTmp := Lj764GetEnt(aFPEnInf)

	If (nValTmp + nEndDig) > nValTot
		Alert(STR0043)			//"Total da Entrada, maior que total da Negocia็ใo"
		oGetVEnt:SetFocus()
	ElseIf nEndDig > 0

		If Empty(aFPEnInf[1,1])
			aFPEnInf := {}
		EndIf

		cFm := SubStr(oGetEnt:AITEMS[oGetEnt:NAT],1,At("-",oGetEnt:AITEMS[oGetEnt:NAT] ) - 2)
		cValor := 	AllTrim(TRANSFORM(nEndDig,cFormtTrs))   // AKI
		AAdd(aFPEnInf, { cFm , cValor, nEndDig, nEndDig })
		oListBox03:SetArray(aFPEnInf)
		oListBox03:bLine := {||	{	aFPEnInf[oListBox03:nAT,01],;
									aFPEnInf[oListBox03:nAT,02]}}
		oListBox03:GoBottom()
		oListBox03:Refresh()

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAtualiza Objeto na Telaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cSaldoEnt :=         AllTrim(TRANSFORM(nEnt - (nValTmp + nEndDig),cFormtTrs))
		oSaldoEnt:Refresh()
		If (nValTmp + nEndDig) >= nEnt
			nEndDig := nValTot - (nValTmp + nEndDig)
			cSaldoEnt := AllTrim(TRANSFORM(nEndDig,cFormtTrs))
			cTxSalEnt := STR0055			//"A Financiar : "
			oBtAdSim:lVisible := .T.
			oBtZeraEnt:lVisible := .F.
			oSaldoEnt:Refresh()
			lj764FPGF(oListBox02, oListBox02:nat, oGetEnt)
			oBtAdEnt:bWhen := {||.F.}
		Else
			oSaldoEnt:lVisible := .T.
			oCapSalEnt:lVisible := .T.
			oBtAdSim:lVisible := .F.
			oBtZeraEnt:lVisible := .F.
			oBtAdEnt:bWhen := {||.T.}
			nEndDig := nEnt - (nValTmp + nEndDig)
		EndIf
	EndIf
EndIf

oGetVEnt:SetFocus()
oGetVEnt:Refresh()
oTelReMn:cSayEnt := PADL(AllTrim(TRANSFORM(Lj764GetEnt(aFPEnInf), cFormtTrs) ), 15)
oTelReMn:oSayEnt:Refresh()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณZera List de simuladoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oMultNegoc:oRetPagMn	:= Nil
oMultNegoc:oRetPagMn	:= LJCRetPagMn():New()
aRetForList := {}
aadd(aRetForList,{"", "", "", "", "", "", "",""})
oListIten:SetArray(aRetForList)
oListIten:bLine := {||	{	aRetForList[oListIten:nAT,01],;
							aRetForList[oListIten:nAT,02],;
							aRetForList[oListIten:nAT,03],;
							aRetForList[oListIten:nAT,04],;
							aRetForList[oListIten:nAT,05],;
							aRetForList[oListIten:nAT,06],;
							aRetForList[oListIten:nAT,07]}}
oListIten:Refresh()
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณLJ164FmPgsบAutora ณSolange Zanardi     บ Data ณ  12/14/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona no objeto da mult-negociacao as informacoes do	  บฑฑ
ฑฑบ          ณcadastro para ser apresentado na tela.					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoExp01 -Obejeto Multnegociacao 							  บฑฑ
ฑฑบ			 ณnExp02 -Codigo do cadastro da multinegociacao				  บฑฑ
ฑฑบ          ณoExp03 -Objeto contendo os dados das mult-negiciacoes		  บฑฑ
ฑฑบ          ณaExp04 -Colecao contendo os cadastros da mult-negociacao	  บฑฑ
ฑฑบ          ณnExp05 -Valor da Venda    								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿  */
Static Function LJ164FmPgs(	oMultNegoc, cCodigo, oListIten, oRetItem, ;
								oGetEnt	  , oBtAdEnt )

Local nCount 		:= 0 	// Declara็ใo do contadors
Local aRet			:= {}  // Retorno da Fun็ใo

Default oRetItem	:= Nil
Default cCodigo		:= ""
Default oListIten	:= Nil
Default oRetItem	:= Nil
Default oGetEnt		:= Nil
Default oBtAdEnt	:= Nil

oRetItem := oMultNegoc:TratReIten(cCodigo)

// habilita o Botao de entrada
If Valtype(oBtAdEnt) == "O"
	oBtAdEnt:bWhen := {||.T.}
EndIf

For nCount := 1 To oRetItem:Count()
	AAdd(aRet, {                                            ;
	 	oRetItem:Elements(nCount):cForma					,;
		oRetItem:Elements(nCount):cDescAdm 					,;
		oRetItem:Elements(nCount):nParMin 					,;
		oRetItem:Elements(nCount):nParMax 					,;
	    oRetItem:Elements(nCount):nTxJuro 					,;
		oRetItem:Elements(nCount):cTpJuro 					,;
		oRetItem:Elements(nCount):nEntrada					})
Next nCount

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณZera totalizadoresณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oListIten:SetArray(aRet)
oListIten:bLine := {||	{	aRet[oListIten:nAT,01],;
							aRet[oListIten:nAT,02],;
							aRet[oListIten:nAT,03],;
							aRet[oListIten:nAT,04],;
							aRet[oListIten:nAT,05],;
							aRet[oListIten:nAT,06],;
							aRet[oListIten:nAT,07]}}
oListIten:Refresh()

lj764CarEnt(oRetItem, oListIten:nAT, @oGetEnt)

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณLj764AtSalบAutora ณSolange Zanardi     บ Data ณ  12/14/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a abertura da tela de interacao cupom TEF            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcExp01 -Saldo da Entrada	 								  บฑฑ
ฑฑบ			 ณoExp02 -ListBox      										  บฑฑ
ฑฑบ          ณoExp03 -ListBpx 01	       								  บฑฑ
ฑฑบ          ณaExp04 -Array com entradas								  บฑฑ
ฑฑบ          ณnExp05 -Valor da Venda    								  บฑฑ
ฑฑบ          ณoExp06 -List Box 2	       								  บฑฑ
ฑฑบ          ณoExp07 -Saldo da entradaEntrada	       					  บฑฑ
ฑฑบ          ณoExp08 -Saldo da entradaEntrada							  บฑฑ
ฑฑบ          ณoExp09 -Botใo de simulado									  บฑฑ
ฑฑบ          ณcExp10 -Salda de entrada	       							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Lj764AtSal(	cSaldoEnt	, oListBox02, oCapSalEnt	, aFPEnInf	,;
							oListBox03	, oSayEnt	, oTelReMn		, oListIten	,;
							aRetForList	, oMultNegoc, oBtZeraEnt	, nGetVEnt	,;
							aResumNeg	, aRecTotal	, oListBoxRn	, oBtAdEnt	,;
							oGetVEnt	, nAuxPac   , nGetTxJrs		, oGetTxJuros )

Default cSaldoEnt	:= ""
Default oListBox02  := Nil
Default oCapSalEnt	:= Nil
Default aFPEnInf	:= {}
Default oListBox03	:= Nil
Default oSayEnt		:= Nil
Default oTelReMn	:= Nil
Default oListIten	:= Nil
Default aRetForList	:= {}
Default oMultNegoc	:= Nil
Default oBtZeraEnt	:= Nil
Default nGetVEnt    := 0
Default aResumNeg   := {}
Default aRecTotal   := {}
Default oBtAdEnt    := Nil
Default oGetVEnt    := Nil
Default nAuxPac     := 0
Default nGetTxJrs   := 0
Default oGetTxJuros := Nil

If oListBox02:AARRAY[oListBox02:nAt][7] > 0
	oSaldoEnt:lVisible 	:= .T.
	oCapSalEnt:lVisible := .T.
	oCapSalEnt:SetText(STR0056)			//"Saldo entrada: "
	If ValType(oBtAdSim) <> "U"
		oBtAdSim:lVisible 	:= .F.
		oBtZeraEnt:lVisible := .F.
		oBtAdEnt:lVisible   := .T.		
		oBtAdEnt:bWhen 		:= {||.T.}
		oBtAdEnt:Refresh()
	EndIf
	cSaldoEnt := AllTrim(TRANSFORM(oListBox02:AARRAY[oListBox02:nAt][7],cFormtTrs ))
	nGetVEnt  := oListBox02:AARRAY[oListBox02:nAt][7]
	oGetVEnt:Refresh()
	oSaldoEnt:Refresh()
Else
	nGetVEnt := oMultNegoc:nValor
	oGetVEnt:Refresh()
	cSaldoEnt := AllTrim(TRANSFORM(oMultNegoc:nValor,cFormtTrs ))

	oCapSalEnt:SetText(STR0057)			//"Valor a Financiar.: "
	oBtAdSim:lVisible   := .T.
	oBtZeraEnt:lVisible := .T.
	oBtAdEnt:lVisible   := .F.
	oSaldoEnt:Refresh()
	oBtAdEnt:Refresh()
EndIf
nGetTxJrs := oListBox02:AARRAY[oListBox02:nAt][5]

If Valtype(oListBox03) <> "U"
	aFPEnInf := {}
	aadd(aFPEnInf,{"","", ""})
	oListBox03:SetArray(aFPEnInf)
	oListBox03:bLine := {||	{	aFPEnInf[oListBox03:nAT,01],;
								aFPEnInf[oListBox03:nAT,02]}}
	oListBox03:Refresh()
EndIf

oTelReMn:cSayEnt := PadL(AllTrim(TRANSFORM(Lj764GetEnt(aFPEnInf),cFormtTrs)), 15)
oTelReMn:oSayEnt:Refresh()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณZera List de simuladoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oMultNegoc:oRetPagMn	:= Nil
oMultNegoc:oRetPagMn	:= LJCRetPagMn():New()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณZera contadoresณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aRetForList := {}
aadd(aRetForList,{"", "", "", "", "", "", "",""})
oListIten:SetArray(aRetForList)
nAuxPac := 0

oListIten:bLine := {||	{	aRetForList[oListIten:nAT,01],;
							aRetForList[oListIten:nAT,02],;
							aRetForList[oListIten:nAT,03],;
							aRetForList[oListIten:nAT,04],;
							aRetForList[oListIten:nAT,05],;
							aRetForList[oListIten:nAT,06],;
							aRetForList[oListIten:nAT,07]}}

oListIten:Refresh()
aRecTotal	:= {}
aResumNeg	:= {}
aadd(aResumNeg,{"","", "", "","",""})
oListBoxRn:SetArray(aResumNeg)

oListBoxRn:bLine := {||{	aResumNeg[oListBoxRn:nAT,01],;
							aResumNeg[oListBoxRn:nAT,02],;
							aResumNeg[oListBoxRn:nAT,03],;
							aResumNeg[oListBoxRn:nAT,04],;
							aResumNeg[oListBoxRn:nAT,05],;
							aResumNeg[oListBoxRn:nAT,06]}}

oListBoxRn:Refresh()
If ValType(oGetTxJuros) <> "U"
	oGetTxJuros:Refresh()
EndIf
oTelReMn:Zera()

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณLj764GetEnบAutora ณSolange Zanardi     บ Data ณ  12/14/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a abertura da tela de interacao cupom TEF            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaExp01 -Lista com entrada 								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Lj764GetEnt(aFPEnInf)

Local nValTmp	:= 0 	// Retorno da Variavel
Local nX		:= 0    // Contador

Default aFPEnInf := {}			

If !Empty(aFPEnInf[1,1])
	For nX := 1 To Len(aFPEnInf)
		nValTmp += aFPEnInf[nX, 3]
	Next nX
EndIf

Return(nValTmp)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณLj764CalP บAutora ณSolange Zanardi     บ Data ณ  12/14/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalculo das parcelas para o mult- negociacoes               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcExp01 - Objeto com os dados das mult-negociacoes			  บฑฑ
ฑฑบ			 ณoExp02 - item selecionado da mult-negocia็ใo listbox2		  บฑฑ
ฑฑบ          ณoExp03 - Valor da Venda      								  บฑฑ
ฑฑบ          ณaExp04 - Valor da entrada 								  บฑฑ
ฑฑบ          ณnExp05 - Objeto contendo as informacoes da mult-negociacao  บฑฑ
ฑฑบ          ณoExp06 - objeto que ira receber as parcelas 				  บฑฑ
ฑฑบ          ณoExp07 - Saldo da entradaEntrada	       					  บฑฑ
ฑฑบ          ณoExp08 - Dt de vencimento da 1 parcela do financiamento	  บฑฑ
ฑฑบ          ณoExp09 - Valor do Juros do dia							  บฑฑ
ฑฑบ          ณoExp10 - Valor do Desconto						 	      บฑฑ
ฑฑบ          ณoExp11 - Parametro para mostrar a couluna do acrescimo	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Lj764CalPar(oRetItem	 , nGetIten	  , nVlrFin		, nVlrEnt, ;
					  oMultNegoc , oListIten , aRetForList	, dVencimento,;
					  nValJurDIa , nDescont  , lMNAcresci  ,  nValparc, ;
					  cFormPg	 , oMultPgto , aResumNeg   ,  nGetTxJrs,;
					  aRecTotal	 , nGetDescV , nGetParce   ,  dGetDtFixo,;
					  nAuxPac)

Local aConNeng 	:= {} 	//Carrga condi็ใo ngociada
Local nPac		:= 0	//Numeros de Parcelas
Local aSimPac	:= {}	//Matriz co  dados simulados
Local nIten		:= 0	//Numero do itens (chave)
Local oDadRed	:= LJCItenPagMn():New()	// Clase
Local oARed		:= Nil	//Objetos, com os dados
Local oARedSim	:= Nil	//Objetos, com os dados
Local nItenSim 	:= 0 	//Numero do Iten
Local nX		:= 0	//Contador
Local nCres		:= 0	//Valor do Acressimo
Local nDifUlPar	:= 0	//Ult. ParcelaValor do Acressimo
Local nTotVlFin	:= 0 	//Valor Fin ou a prtazo
Local nTotPrz	:= 0 	//Total a Parazo
Local lLj701A2	:= ExistBlock("Lj701A2")	// Verifica a existencia do PE Lj701A2
Local lLj701A4	:= ExistBlock("LJ701A4")
Local aParPeA2  := {}                      	// Parametros enviados para o Ponto de Entrada lLj701A2
Local dDiapri	:= ctod('')					// Dia da Primeira Parcela Multinegocia็ใo
Local aRetPe	:= {}
Local cCodForm  := ""
Local nItemPgto := 0
Local nPjuros   := 0
Local nValFin   := 0
Local nTotparc  := 0
Local aAreaSAE  := SAE->(Getarea())
Local lFixaDia  := .F.
Local nDiaVenc  := 0
Local cDias     := SuperGetMV("MV_LJMNDIA",,"")
Local cCodCaixa := xNumCaixa()
Local lJurDesc  := LJ764PermJD(cCodCaixa)
Local nTaxaJuros:= 0
Local nAdDias   := 0
Local nAuxValor := 0
Local nTPDesc   := 0
Local cTipoJuros:= ""
Local lLoja761D	:= GetAPOInfo("LOJA761D.PRW")[4] >= Ctod("30/03/2017") 
Local nDifFin	:= 0
Local nDescAdd  := 0   // Valor adicional para as paracelas em FI e Bol e dado o acrescimo caso pago em dia e dado o mesmo valor em desconto.
Local lIsPOS	:= STFIsPOS()		// Valida se ้ TOTVSPDV

nGetIten	:= Iif( Empty(nGetIten),1,nGetIten)

Default oRetItem	:= Nil
Default nVlrFin		:= 0
Default nVlrEnt    	:= 0
Default oMultNegoc	:= Nil
Default oListIten	:= Nil
Default aRetForList	:= {}
Default dVencimento		:= DataValida(Iif(oRetItem:Elements(nGetIten):nIntervalo == 0, dDataBase + 30, dDataBase)) // Se estiver configurado intervalos de dias
Default nValJurDIa	:= 0                                                                           // Sera calculado a entrada a partir do intervalo configurado
Default nDescont	:= 0
Default lMNAcresci	:= .T.
Default cFormPg		:= ""
Default oMultPgto	:= Nil
Default nGetTxJrs	:= 0
Default aRecTotal	:= {}
Default nGetDescV	:= 0
Default nGetParce	:= 0
Default dGetDtFixo	:= dDataBase
Default nAuxPac		:= 0
Default nValparc	:= nVlrFin - nVlrEnt
Default aResumNeg	:= {}

cCodForm := SubStr(cFormPg,1,3)
nPjuros := (nGetDescV /100)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณO valor das parcelas Confirmadas somando aoณ
//ณvalor digitado e a entrada nao pode ser    ณ
//ณmaior que o valor total a financiar.		  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lIsPOS .And. lJurDesc
	nTaxaJuros:= nGetTxJrs
Else 
	nTaxaJuros:= oRetItem:Elements(nGetIten):nTxJuro
EndIf

If(SubStr(oRetItem:Elements(nGetIten):cTpJuro,1,1) == "3" .and. nTaxaJuros == 0)
	cTipoJuros:= "1"
Else
	cTipoJuros:= SubStr(oRetItem:Elements(nGetIten):cTpJuro,1,1) 
EndIf	

If Len(aRecTotal) > 0
   For nX := 1 to Len(aRecTotal)
   	nValFin += aRecTotal[nX][2]
   next nX
EndIf

If nGetParce > 0
	nTotparc := nGetParce
Else
	nTotparc := oRetItem:Elements(nGetIten):nParMax
EndIf

If (nVlrEnt + nValFin + nValparc) > nVlrFin
   MsgAlert(STR0058)		//"Valor digitado na Parcela ้ maior que o valor a financiar."
   return()
EndIf

If ( nValFin == nVlrFin) .or. nValparc == 0
   MsgAlert(STR0059)		//"Nใo existe valor a financiar."
   return()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe jแ existir itens, apaga todosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If oMultNegoc:oRetPagMn:Count() > 0
	oMultNegoc:oRetPagMn	:= Nil
	oMultNegoc:oRetPagMn	:= LJCRetPagMn():New()
EndIf
If Valtype(oMultPgto) == "U"
	oMultPgto	:= LJCRetPagMn():New()
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//|Busco a Adm Financeira para Verificar se |
//|ela esta configurada para usar dia Fixo. |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lFixaDia := If( oRetItem:Elements(nGetIten):nFixaDia <> "2" ,.T., .F.)

//Altero a data para que seja adicionado parcelas na ordem
If Len(aResumNeg) > 0 .And. !Empty(aResumNeg[1][1]) .And. !("CC" $ Alltrim(cFormPg))
    ASORT(aResumNeg, , , { | x,y | x[1] < y[1] } )
	dVencimento := aResumNeg[Len(aResumNeg)][1]
	// S๓ faz a soma de 30 dias caso o campo MBT_VALENT (valor minimo de entrada) estiver zerado
	If oRetItem:Elements(nGetIten):nIntervalo == 0
		dVencimento := dVencimento + 30
	EndIf
Elseif !Empty(dGetDtFixo)
	If dGetDtFixo = dDatabase	//Se a data da primeira parcela for hoje, considera somente a soma com o dia da car๊ncia da primeira parcela
		dVencimento  := DataValida(dDataBase+oRetItem:Elements(nGetIten):nCar1Pa)
	Else
		dVencimento := dGetDtFixo
	EndIf
EndIf

If PADL(AllTrim(Str(Day(dGetDtFixo))),2,"0") $ cDias
	MsgAlert(STR0060 + DtoC(dGetDtFixo) )				//"Essa data nใo pode Ser utilizada "
	Return ()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMultinegocia็ใo.                                         ณ
//ณCaso a entrada de dados de nDescont, seja atrav้s da telaณ
//ณde sele็ใo de planos, converte os dados para num้rico.   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ValType(nDescont) <> "N"
	nDescont := Val(nDescont)
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMultinegocia็ใo                                       ณ
//ณSubtrai o valor de desconto do total do financiamento.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nDescont > 0
	nTotVlFin	:= nVlrFin - nVlrEnt - nDescont
	oMultNegoc:SetDescont(nDescont)
Else
	nTotVlFin	:= nValparc
EndIf

If (oRetItem:Elements(nGetIten):nParMin == 0 ) .OR. ( oRetItem:Elements(nGetIten):nParMax == 0 )
	MsgStop(STR0052)//A quantidade de parcelas deve ser diferente de zero.
	Return
ElseIf ( oRetItem:Elements(nGetIten):nParMin )  >  ( oRetItem:Elements(nGetIten):nParMax )
	MsgStop(STR0053)//A quantidade maxima de parcelas deve ser maior ou igual a quantidade minima.
	Return
EndIf

//Adiciono o nAuxPac para continuar o calculo do juros contando as outras parcelas.
For nPac := 1  To nTotparc  //oRetItem:Elements(nGetIten):nParMax
	nDifUlPar := 0
	aConNeng := {                                    					 ;
					cTipoJuros											,;    	// Tipo juros
					dVencimento+oRetItem:Elements(nGetIten):nIntervalo	,;    	// Data entrada + Intervalo de dias
					0													,;		// Valor Entrada
					nTaxaJuros											,;		// Taxa de Juros
					nPac + If(cTipoJuros == "3" .And. nAuxPac > 0,nAuxPac,0) ,; // Calcula Juros 1บ Pac
					Iif(oRetItem:Elements(nGetIten):nIntervalo == 0, 30,oRetItem:Elements(nGetIten):nIntervalo),; // Mantenho a logica anterior se produto nao estiver configurado
	   				.F.}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMultinegocia็ใo.                        ณ
	//ณPonto de entrada para que seja realizadoณ
	//ณo cแlculo das parcelas.                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If lLj701A2
		aParPeA2:= {	nTotVlFin,	"CN",	aConNeng,;
						oRetItem:Elements(nGetIten):cForma,	nValJurDIa, oRetItem:Elements(nGetIten):cAdm,;
						oRetItem:Elements(nGetIten):cCodigo, oRetItem:Elements(nGetIten):nIntervalo, ;
						nVlrFin, nVlrEnt, nDescont }
		aRet	:= (ExecBlock("LJ701A2",.F.,.F.,aParPeA2))
		If ValType(aRet)=='U'
			Loop

    //Mantenho a data fixa como false pois esta calculando algumas datas incorretamente.
		ElseIf ValType(aRet)<>'A' .OR. Len(aRet) < 1
			Alert(STR0051) // Retorno de fun็ใo invแlido
			aRet := Lj7CalcPgt(	nTotVlFin , "CN" 	   , 	aConNeng		, 0  , ;
								      Nil ,	 Nil	   , 	Nil				, 0  , ;
								      .F. ,	 Nil	   ,	Nil		  		, 0  , ;
		oRetItem:Elements(nGetIten):cForma, nValJurDIa , 	Nil				, Nil, ;
		                              Nil ,  Nil       ,    .T. )
	    EndIf

	Else
		aRet := Lj7CalcPgt(	nTotVlFin , 	  "CN" , aConNeng    , 0  , ;
								  Nil , 	   Nil ,    Nil		 , 0  , ;
							      .F. ,		   Nil ,	Nil		 , 0  , ;
					        cCodForm  , nValJurDIa ,	Nil		 ,Nil , ;
					              Nil ,        Nil ,    .T. )

		If lLj701A4
			aRetPe := ExecBlock("LJ701A4",.F.,.F.,{aRet,aConNeng,nVlrFin, nVlrEnt, nDescont})
			If ValType(aRetPe) =='A' .AND. Len(aRetPe) > 0
				aRet := aRetPe
			EndIf

		EndIf

	EndIf

	oDadRed	:= LJCItenPagMn():New()
	nAuxValor := 0
	For nX := 1 To Len(aRet)
		If aRet[nX][3] <> cCodForm
			aRet[nX][3] := cCodForm
		EndIf
		nAuxValor += aRet[nX][2]
	Next nX
	For nX := 1 To nPac
		Aadd(aSimPac, aRet)
		nIten += 1
		//Caso seja selecionada data fixa forco a data conforme necessidade
		If lFixaDia
			nDiaVenc :=  VAL(SubStr(DtoS(dGetDtFixo),7,8)) // DIA DO VENCIMENTO
			If nX == 1
				AuxaRet := aClone(aRet)
			EndIf

			If (nX == 1 .AND. AllTrim(Str(Month(aRet[nX][1]))) $ ("1,3,5,7,8,10,12") ) .Or. ;
				(nX > 1 .AND. AllTrim(Str(Month(aRet[nX-1][1]))) $ ("1,3,5,7,8,10,12"))
				nAdDias := 31
			Else
				nAdDias := 30
			EndIf
			// forco a primeira parcela pois estava caindo no mesmo mes da entrada por causa da conta com 30 dias
			// alterando a data ficava com a mesma data da entrada.
			If nX == 1 .and. nDiaVenc < 5
				aRet[nX][1] := dVencimento + nAdDias - 30
			EndIf
			If nX > 1 .and. nDiaVenc < 5 // Monta a data por causa de mes com 30 e mes com 31 para a mudanca certa do mes
				aRet[nX][1] := CtoD(SubStr(DtoC(dGetDtFixo),1,3) + SubStr(DtoC(aRet[nX-1][1]+ nAdDias ),4,8))
            Else
				aRet[nX][1] := CtoD(SubStr(DtoC(dGetDtFixo),1,3) + SubStr(DtoC(aRet[nX][1]),4,8))
			EndIf

			//Tratamento para o Mes de Fevereiro
			If nDiaVenc > 28 .And. nX > 1 .And.;
					 (Month(aRet[nX-1][1]) == 1 .OR. (Month(aRet[nX-1][1]) == 2 .AND. Day(aRet[nX-1][1]) <= 25)) 
					 //Se a parcela anterior for 30/01 ou 31/01 e cair em um dia nใo ๚til, avan็a os dias at้ o dia ๚til,
					 // que cairแ nos primeiros dias de Fevereiro. Hแ tolerโncia da parcela anterior at้ 25/02.
				aRet[nX][1] := StoD(Str(Year(aRet[nX-1][1]),4)+"0301")		//yyyy0301, sempre no dia 1 de mar็o.
			ElseIf nDiaVenc <> Day(aRet[nX][1])
				aRet[nX][1] := StoD(SubStr(DtoS(aRet[nX][1]),1,6) + (SubStr(DtoS(dVencimento),7,8)))
			EndIf
			aRet[nX][1] :=	DataValida(aRet[nX][1])
		EndIf
		If nPac + If( cTipoJuros == "3" .and. nAuxPac > 0 ,nAuxPac, 0) > nPac
			aRet[nX][2] :=  Round(nAuxValor / nPac,2)
		EndIf
		nDescAdd := aRet[nX][2] / (1 - nPjuros ) // Calculo do Juros do Desconto.
		oARed := LJCItenDadMn():New( 	nX,;
										aRet[nX][1],;   //Data do Venc Parcela
							 		    If(AllTrim(aRet[nX][3])$"BOL|FI ", nDescAdd ,aRet[nX][2] ),;   //Valor Parcela
										aRet[nX][3],;   //Forma De Pagameto
										If(AllTrim(aRet[nX][3])$"BOL|FI ", nDescAdd - aRet[nX][2]  ,0 ) , ; //Juros por forma de pagamento Forma De Pagameto
										If(AllTrim(aRet[nX][3])$"BOL|FI ", nDescAdd - (nDescAdd -aRet[nX][2]),aRet[nX][2]  ) ; // Valor das Parcela com Desconto
										)
		oDadRed:Add(nX, oARed)

		oARed := Nil

		If nX == 1
			nValPac 	:= oDadRed:Elements(nX):NVALOR  
			cFormPag	:= oDadRed:Elements(nX):CFM		 
		EndIf
		nDifUlPar	+= noRound(If(AllTrim(aRet[nX][3])$"BOL|FI ",nDescAdd,aRet[nX][2] ))
		nTotPrz += oDadRed:Elements(nX):NVALOR
		nTPDesc += oDadRed:Elements(nX):nValparD

	Next nX
	nDifUlPar	:= nTotPrz - nDifUlPar
	nCres :=	nTotPrz - nTotVlFin

	If oDadRed:Count() > 0
		nItenSim += 1
		nItemPgto := oMultPgto:Count() +  1
		oARedSim := LJCRePaCon():New(nItenSim, "PAR", oDadRed, nCres, nValPac, cFormPag, nTotPrz, oDadRed:Count(), nTotVlFin, nVlrEnt, oMultNegoc:GetValNcc(),nTPDesc,nDifUlPar )
		oMultNegoc:oRetPagMn:Add(nItenSim, oARedSim)
		oMultPgto:Add(nItemPgto , oARedSim)
		oDadRed := Nil
		nTotPrz := 0
		nTPDesc := 0
	EndIf

Next nPac

aRetForList := {}

dDiapri := oMultNegoc:oRetPagMn:Elements(1):oPags:elements(1):dDataPac
For nX := 1 To oMultNegoc:oRetPagMn:Count()
	if lLoja761D
		nDifFin :=	oMultNegoc:oRetPagMn:Elements(nX):nDif
	Else
		nDifFin :=	oMultNegoc:oRetPagMn:Elements(nX):nTotPrz- (oMultNegoc:oRetPagMn:Elements(nX):nValorPar * oMultNegoc:oRetPagMn:Elements(nX):nQtdPac)
	EndIf	
	AAdd(aRetForList,{    																						 ;
	   					oMultNegoc:oRetPagMn:Elements(nX):CFM													,;
						nX 																						,;
						AllTrim(TRANSFORM(oMultNegoc:oRetPagMn:Elements(nX):nValorPar,	cFormtTrs))   			,;
						AllTrim(TRANSFORM(oMultNegoc:oRetPagMn:Elements(nX):nTotPrz,	cFormtTrs))   			,;
						AllTrim(TRANSFORM(oMultNegoc:oRetPagMn:Elements(nX):nVparDesc,	cFormtTrs))   			,;
	   					AllTrim(TRANSFORM(oMultNegoc:oRetPagMn:Elements(nX):nCres,		cFormtTrs))				,;
	   					dDiapri																					,;
	   					PADL(AllTrim(TRANSFORM(nDifFin,	cFormtTrs)),15)											,;
	   					nVlrEnt																					,;
	   			   		oRetItem:Elements(nGetIten):cCodigo	})

Next nX

//Utilizado para finalizar processo de financiamento - calculo especifico
If ExistBlock("LJ701A3")
	aRet := ExecBlock("LJ701A3",.F.,.F.,aRetForList)
	If ValType(aRet)=='A'
		If len(aRet) > 0
			aRetForList := aClone(aRet)
			aRet := {}
		Else
			Alert(STR0051)	// Retorno de fun็ใo invแlido
		Endif
	Else
		Alert(STR0051)  // Retorno de fun็ใo invแlido
	Endif

	// -------- Fim atualizacao dos objetos de totais


Endif

If ValType(oListIten) == "O"
	oListIten:SetArray(aRetForList)
	If lMNAcresci
		oListIten:bLine := {||	{	aRetForList[oListIten:nAT,01],;
									aRetForList[oListIten:nAT,02],;
									aRetForList[oListIten:nAT,03],;
									aRetForList[oListIten:nAT,04],;
									aRetForList[oListIten:nAT,05],;
									aRetForList[oListIten:nAT,06],;
									aRetForList[oListIten:nAT,07]}}
	Else
		oListIten:bLine := {||	{	aRetForList[oListIten:nAT,01],;
									aRetForList[oListIten:nAT,02],;
									aRetForList[oListIten:nAT,03],;
									aRetForList[oListIten:nAT,04],;
									aRetForList[oListIten:nAT,06]}}
	EndIf
	oListIten:Refresh()
EndIf

RestArea(aAreaSAE)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณLj764Conf บAutora ณSolange Zanardi     บ Data ณ  12/14/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConforma Multi negocia็ใo						              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoExp01 -Multi Negocia็ใo	 								  บฑฑ
ฑฑบ			 ณnExp02 -Item      										  บฑฑ
ฑฑบ          ณoExp03 -Retorno deo Iten     								  บฑฑ
ฑฑบ          ณnExp04 -Numero do Iten									  บฑฑ
ฑฑบ          ณaExp05 -Valor da Entrada    								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Lj764Conf(	oMultNegoc, nItem    , oRetItem, nItenMn, ;
							aFPEnInf  ,aResumNeg , oDlgNg  , aRecTotal  )

Local aRet 	:= {} 		// retorno
Local nX	:= 0 		// Contador
Local aAdm	:= {}  		// Adm Fin
Local cForma	:= ""
Local nTotParc  := 0
Local nxValParc := 0
Local nDifParc  := 0
Local nSobra    := 0
Local nxQtdParc := 0
Local lMVLJICMJR := SuperGetMV("MV_LJICMJR",,.F.)
Local lMVTEFMULT := SuperGetMV("MV_TEFMULT",,.F.)

Default oMultNegoc	:= Nil
Default nItem		:= 0
Default oRetItem 	:= Nil
Default nItenMn		:= 0
Default aFPEnInf	:= {}
Default aResumNeg   := {}
Default oDlgNg		:= Nil
Default aRecTotal   := {}

If Len(aRecTotal) > 0 .And. Type("oMultNegoc") <> "U"
	For nX := 1 to Len(aRecTotal)
		nTotParc +=	aRecTotal[nX][2]
	Next nX
	If oMultNegoc:nValor > nTotParc
		MSgAlert(STR0061)		//"Valor das Parcelas Menor que o valor da Compra"
		Return(aRet)
	EndIf
EndIf

If Len(aResumNeg) > 0 .AND. Len(aResumNeg[1]) >= 10


	For nX := 1 to Len(aResumNeg)
    	nDifParc := 0
    	If lMVLJICMJR .AND. cPaisLoc == "BRA"
    		If  (!Alltrim(Upper(aResumNeg[nX][3])) $ "CD|CC|R$" .And. aResumNeg[nX][7][7] > 0 )
    			nxQtdParc := aResumNeg[nX][7][7]	//Quantidade de parcelas
				nxValParc := NoRound(aResumNeg[nX][7][6] / nxQtdParc , 2)	//Valor da Parcela
				nDifParc  :=  aResumNeg[nX][8] - nxValParc
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAcerto para o dizimos acrescentado na ultima parcela.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nSobra += (aResumNeg[nX][7][6] / nxQtdParc) - NoRound(aResumNeg[nX][7][6] / nxQtdParc , 2)
				If (nX +1) <= Len(aResumNeg) .And. Alltrim(Upper(aResumNeg[nX+1][3])) <> Alltrim(Upper(aResumNeg[nX][3]))
					aResumNeg[nX][8] := nxValParc + nSobra
					nSobra := 0
				ElseIf (nX) == Len(aResumNeg)
					aResumNeg[nX][8] := nxValParc + nSobra
					nSobra := 0
				Else
					aResumNeg[nX][8] := nxValParc
				EndIf

    		EndIf
    	EndIf
		cForma := aResumNeg[nX][3]
		aAdd( aRet, 	{	aResumNeg[nX][1] 						,;		//01 Data do orcamento
							aResumNeg[nX][8]						,;		//02 Valor
							aResumNeg[nX][3]						,;		//03 Forma de pagamento
							{}										,;		//04 Array de parcelas
							nDifParc								,;		//05 Data base
							If( !cPaisLoc == "BRA", nMoedaCor, 1 )	,;		//06 Moeda
			                aResumNeg[nX][1] 						,;		//oMultNegoc:oRetPagMn:ElementKey(nItem):oPags:Elements(nX):dDataPac	,;	//07 Data
			         		If(AllTrim(cForma) $ "CC|CD" .AND. lMVTEFMULT ,aResumNeg[nX][6],Space(01)),; //08 FormID
			         		aResumNeg[nX][10] ;  							// Valor do Desconto.
			         		} )

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCheque						  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	   	If  AllTrim(cForma) == AllTrim(MVCHEQUE)

			aAdm := {}

			If !Empty(aResumNeg[nX][7][1])
				aAdm := Array(14)
				aAdm[1]  := aResumNeg[nX][2]
				aAdm[2]  := aResumNeg[nX][1]
				aAdm[3]  := AllTrim(Str(aResumNeg[nX][7][5]))
				aAdm[4]  := aResumNeg[nX][7][1]
				aAdm[5]  := ""
				aAdm[6]  := ""
				aAdm[7]  := ""
				aAdm[8]  := ""
				aAdm[9]  := ""
				aAdm[10] := ""
				aAdm[11] := .T.
				aAdm[12] := .F.

				If !cPaisLoc == "BRA"
					If IsMoney( cForma ) .AND. nMoedaCor > 1
						aAdm[13] := SuperGetMV( "MV_SIMB" + Str( nMoedaCor,1 ) )
						aRet[Len(aRet)][3] := aAdm[13]
					EndIf
				Else
					aAdm[13] := cForma
				EndIf

				aAdm[14] := ""
			EndIf

			aRet[Len(aRet)][4] := aClone(aAdm)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCartao de credito/debito/outros	   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		ElseIf !IsMoney(cForma)			
			aAdm := Array(10)
			aAdm[01]  := aResumNeg[nX][2]
			aAdm[02]  := aResumNeg[nX][1]
			aAdm[03]  := AllTrim(Str(aResumNeg[nX][7][5]))
			aAdm[04]  := ""
			aAdm[05]  := LJ764ADM(aResumNeg[nX][3],oRetItem,nItenMn)
			aAdm[06]  := .T.
			aAdm[07]  := aResumNeg[nX][6]
			aAdm[08]  := aResumNeg[nX][7][6]
			aAdm[09]  := aResumNeg[nX][7][7]
			aAdm[10]  := aResumNeg[nX][7][8]

			aRet[Len(aRet)][4] := aClone(aAdm)

		EndIf
	Next nX

oDlgNg:End()
EndIf

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณLjTEFTela บAutora ณSolange Zanardi     บ Data ณ  12/14/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValor da Veda									              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณdExp01 - Data Vencimento	 								  บฑฑ
ฑฑบ			 ณnExp02 - Numero do Limite									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Lj764VlVen(dVencimento, nDiaLim)

Local lRet := .F.

Default dVencimento	:= dDataBase + 30
Default nDiaLim		:= 0

If ((dVencimento >= dDataBase) .AND. (dVencimento <= dDataBase + nDiaLim))
	lRet := .T.
ElseIf (dVencimento < dDataBase )
    Alert(	STR0047  + chr(13) + chr(10)  + dToc(dDataBase )) //"A data para entrada ้ inferior a data do dia "
ElseIf (dVencimento > dDataBase + nDiaLim)
	 Alert(	STR0048  + chr(13) + chr(10)  + dToc(dDataBase ))   // "Data informada ้ superior ao limite estabelecido na Multi-Negocia็ใo"
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณLjTEFTela บAutora ณSolange Zanardi     บ Data ณ  12/14/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValor da Veda									              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณdExp01 - Data Vencimento	 								  บฑฑ
ฑฑบ			 ณnExp02 - Numero do Limite									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Lj64ZMul()

	lMulPas := .F.


Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณLjTEFTela บAutora ณSolange Zanardi     บ Data ณ  12/14/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValor da Veda									              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณdExp01 - Data Vencimento	 								  บฑฑ
ฑฑบ			 ณnExp02 - Numero do Limite									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Lj6GMulP()

Return(lMulPas)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณlj764CarEnบAutora ณSolange Zanardi     บ Data ณ  12/14/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona os itens no objeto do comobx da forma de pgto      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณoExp1 -Obejeto Mn itens  									  บฑฑ
ฑฑบ			 ณnExp1 -Item       										  บฑฑ
ฑฑบ          ณoExp1 -Entrada	       									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function lj764FPGF(oListBox02, nIten, oGetEnt)

Local cEntrada 	:= ""
Local aFPent	:= {}
Local aBkArea	:= GetArea()
Local nX		:= 0

Default oListBox02	:= Nil
Default nIten    	:= 0
Default oGetEnt   	:= Nil

If Valtype(oListBox02) <> "U"
	If  !Empty(oListBox02:AARRAY[nIten][1])
		cEntrada 	:= oListBox02:AARRAY[nIten][1]
		aFPent		:= StrToArray(cEntrada, ";")
		DbSelectArea("SX5")
		DbSetOrder(1)			//X5_FILIAL+X5_TABELA+X5_CHAVE
	EndIf

	If Len(aFPent) > 0
		For nX := 1 To Len(aFPent)
			If DbSeek(xFilial("SX5")+ "24"+ aFPent[nX])
				aFPent[nX] += " - " + sx5->X5_DESCRI
			Endif
		Next nX


		oGetEnt:aItems := aClone(aFPent)
	Else
		oGetEnt:aItems := {""}
	EndIf
	oGetEnt:Refresh()
	RestArea(aBkArea)

EndIf

Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA764
Adiciona os itens ao Array do Resumo das Negociacoes

@author Rene Julian
@since 18/01/2016
@version P11
/*/
//-------------------------------------------------------------------

Static Function Lj746AdRN(oMultPgto		,aResumNeg	,nItem		,oListIten	,oListEntr,;
                          oMultNegoc	,cSaldoEnt	,oListBox02 ,aFPEnInf	,nValTot  ,;
  				          nEndDig	    ,oGetVEnt	,oSaldoEnt	,aRecTotal	,aRetForList,;
  				          oListBox01B  	,nGetParce	,nAuxPac    ,oRetItem 	,nGetIten)

Local nX := 0
Local lDesconto  := .F.
Local cId        := "0"   // Id para Diferenciar os cartoes.
Local nEnt       := 0
Local nValTmp    := 0
Local lEntrada   := .F.
Local nTotParc   := 0
Local nTotParCC  := 0
Local nQuantParc := 0
Local nEntrada   := 0
Local cCodCaixa := xNumCaixa()
Local lJurDesc  := LJ764PermJD(cCodCaixa)
Local lLoja761D	:= GetAPOInfo("LOJA761D.PRW")[4] >= Ctod("30/03/2017") 
Local nOrdem	:= 0

Default oMultPgto  := Nil
Default aResumNeg  := {}
Default nItem      := 1
Default oListIten  := Nil
Default oListEntr  := Nil
Default oMultNegoc := Nil
Default cSaldoEnt  := ""
Default oListBox02 := Nil
Default aFPEnInf   := {}
Default nValTot    := 0
Default nEndDig    := 0
Default oGetVEnt   := Nil
Default aRecTotal  := {}
Default aRetForList := {}
Default oListBox01B := Nil
Default nGetParce   := 0
Default nAuxPac     := 0

nGetIten := Iif(Empty(nGetIten),1,nGetIten)

If ValType(oMultNegoc) == "O" .And. oMultNegoc:oRetPagMn:Count() > 0

	If (!lJurDesc .And. oRetItem:Elements(nGetIten):nParMin > nItem)
		MsgAlert(STR0062)			//"Quantidade de parcelas solicitada ้ menor que a determinada para essa condi็ใo"
		Return(lDesconto)
	ElseIf (!lJurDesc .And. oRetItem:Elements(nGetIten):nParMax  < nItem )
		MsgAlert(STR0063)			//"Quantidade de parcelas solicitada ้ maior que a determinada para essa condi็ใo"
		Return(lDesconto)
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//|Faco a validacao das quantidade de parcelas digitadas |
	//|para que nao utrapasse a quantidade de parcelas do    |
	//|financiamento.										 |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Type("oListBox02") <> "U"
		nQuantParc := oListBox02:aArray[oListBox02:nat][4]
		If nGetParce > 0
			nQuantParc := nGetParce
		EndIf
	EndIf
	If Len(aRecTotal) > 0
		For nX := 1	to Len(aRecTotal)
			If AllTrim(aRecTotal[nX][1]) == "CC"
				If aRecTotal[nX][2] > nTotParCC
					nTotParCC := aRecTotal[nX][4]
				EndIf
			Else
				nTotParc += aRecTotal[nX][4]
			EndIf
		Next nX
		nEntrada := Lj764GetEnt(aFPEnInf)
		If nQuantParc < nTotParc + nTotParCC + nItem
			MsgAlert(STR0064)				//"Quantidade de Parcelas ้ superior ao Financiamento"
			Return(lDesconto)
		EndIf
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//|Adiciono as parcelas de entrada para ser apresentada  |
	//|no resumo da multiNegociacao.					     |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Len(aResumNeg) > 0 .And. Empty(aResumNeg[1][1])
		aResumNeg := {}
		lEntrada := .T.
		oMultNegoc:SetVEntrad(Lj764GetEnt(aFPEnInf))
		//Adiciono as entradas
		For nX := 1 to Len(oListEntr:AARRAY)
			If oListEntr:AARRAY[nX][1] == "CD"
				cId := Soma1(cId)
			EndIf
			If !Empty(oListEntr:AARRAY[nX][2])			
				nOrdem := nOrdem + 1

				AADD(aResumNeg, { ;
							dDataBase				,;
							oListEntr:AARRAY[nX][2]	,;
							oListEntr:AARRAY[nX][1]	,;
							0				        ,;
							oListEntr:AARRAY[nX][2] ,;
							If(oListEntr:AARRAY[nX][1] == "CD", cId, "1"),;
							{"","","",0,0,0,0,0},;	// Array P/ ADM Financeira.
							If(Len(oListEntr:AARRAY[nX])>=4,oListEntr:AARRAY[nX][4],0) ,;
							If(Len(oListEntr:AARRAY[nX])>=4,oListEntr:AARRAY[nX][4],0) ,;
							0 ,;
							nOrdem })
			EndIf
		Next nX
	EndIf

	ASORT(aResumNeg, , , { | x,y | x[11] < y[11] } )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//|Geracao do ID dos Cartoes  |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If AllTrim(oMultNegoc:oRetPagMn:Elements(nItem):CFM) $ "CC|CD"
		For nX := 1 to Len(aResumNeg)
			If AllTrim(aResumNeg[nX][3]) $ "CC|CD" .And. cId <> aResumNeg[nX][6]
				cId := aResumNeg[nX][6]
			EndIf
		Next nX
		cId := Soma1(cId)
	EndIf

	lEntrada := .F.
	For nX := 1 to nItem
		nAuxPac ++
		if nX = nItem .and. lLoja761D 
			nValPac := NoRound(oMultNegoc:oRetPagMn:Elements(nItem):OPAGS:Elements(nx):nvalor,2)+ oMultNegoc:oRetPagMn:Elements(nItem):nDif
		else
			nValPac := NoRound(oMultNegoc:oRetPagMn:Elements(nItem):OPAGS:Elements(nx):nvalor,2)
		EndIf
		nOrdem := nOrdem + 1

		AADD(aResumNeg, { ;
						oMultNegoc:oRetPagMn:Elements(nItem):OPAGS:Elements(nX):DDATAPAC		,;
						AllTrim(TRANSFORM(nValPac, cFormtTrs)),;
						oMultNegoc:oRetPagMn:Elements(nX):CFM							 		,;
						AllTrim(TRANSFORM(oMultNegoc:oRetPagMn:Elements(nItem):OPAGS:Elements(nItem):nvaljuros, cFormtTrs)),;
						AllTrim(TRANSFORM(nValPac - oMultNegoc:oRetPagMn:Elements(nItem):OPAGS:Elements(nItem):nvaljuros, cFormtTrs)),;
						cId ,;
						{"","","",0 ,nX,oMultNegoc:oRetPagMn:Elements(nItem):nTotVlFin,nItem,oMultNegoc:oRetPagMn:Elements(nItem):nTotPRZ},; // Array P/ ADM Financeira.
						nValPac,;
						nValPac - oMultNegoc:oRetPagMn:Elements(nItem):OPAGS:Elements(nItem):nvaljuros,;
						oMultNegoc:oRetPagMn:Elements(nItem):OPAGS:Elements(nItem):nvaljuros ,;
						nOrdem })

	Next nX

	ASORT(aResumNeg, , , { | x,y | x[1]+x[11]  < y[1]+y[11] } )

	oListIten:SetArray(aResumNeg)

	oListIten:bLine := {||	{	aResumNeg[oListIten:nAT,01],;
								aResumNeg[oListIten:nAT,02],;
								aResumNeg[oListIten:nAT,03],;
								aResumNeg[oListIten:nAT,04],;
								aResumNeg[oListIten:nAT,05],;
								aResumNeg[oListIten:nAT,06]}}

	oListIten:lVScroll := .T.
	oListIten:GoBottom()
	oListIten:Refresh()
	AADD(aRecTotal,{oMultNegoc:oRetPagMn:Elements(nItem):CFM,;
	                oMultNegoc:oRetPagMn:Elements(nItem):nTotVlFin,;
	                oMultNegoc:oRetPagMn:Elements(nItem):nTotPRZ,;
	                nItem  })
	nEndDig := 0
	If Len(aRecTotal) > 0
		For nX := 1 to Len(aRecTotal)
			nEndDig += aRecTotal[nX][2]
		Next nX
	EndIf
	nValTmp   := Lj764GetEnt(aFPEnInf)
	nEnt 	  := oListBox02:AARRAY[oListBox02:nAt][7]
	nEndDig   := nValTot - (nValTmp + nEndDig)
	cSaldoEnt := AllTrim(TRANSFORM( nEndDig ,cFormtTrs))
	oSaldoEnt:Refresh()
	oGetVEnt:Refresh()
EndIf


Return(lDesconto)
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA764
Atualiza oS GetS da taxa de juros e desconto

@author Rene Julian
@since 22/01/2016
@version P11
/*/
//-------------------------------------------------------------------


Static Function lj764AtuGet(oRetItem, nItem, oGetEnt,nGetTxJrs,oGetTxJuros,nGetIten)

Default oRetItem  	:= Nil
Default nItem    	:= 0
Default oGetEnt    	:= Nil
Default nGetTxJrs   := 0
Default oGetTxJuros := Nil

nGetIten :=  nItem

If Valtype(oRetItem) <> "U" .and. Valtype(oGetTxJuros) <> "U"
	nGetTxJrs := oRetItem:Elements(nItem):nTxJuro
	oGetTxJuros:Refresh()
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA764
Reinicia o Objeto com as informacoes das parcelas selecionadas e o
Array do Listbox central.

@author Rene Julian
@since 02/02/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function	LimpaSimul(oMultNegoc,oListBox01B,aRetForList)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณZera List de simuladoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oMultNegoc:oRetPagMn	:= Nil
oMultNegoc:oRetPagMn	:= LJCRetPagMn():New()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณZera contadoresณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aRetForList := {}
aadd(aRetForList,{"", "", "", "", "", "", "",""})
oListBox01B:SetArray(aRetForList)

oListBox01B:bLine := {||	{	aRetForList[oListBox01B:nAT,01],;
							aRetForList[oListBox01B:nAT,02],;
							aRetForList[oListBox01B:nAT,03],;
							aRetForList[oListBox01B:nAT,04],;
							aRetForList[oListBox01B:nAT,05],;
							aRetForList[oListBox01B:nAT,06],;
							aRetForList[oListBox01B:nAT,07]}}
oListBox01B:Refresh()

Return()
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA764
Rotina Para Verificar se o usuario possui permissao
para alterar a taxa de juros ou o desconto.

@author Rene Julian
@since 02/02/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function LJ764PermJD(cCodCaixa)
Local aArea := SLF->(GetArea())
Local lRet  := .F.

DbSelectArea("SLF")
DbSetorder(1)			//LF_FILIAL+LF_COD
If DbSeek(xFilial("SLF")+ cCodCaixa)
	cRet := SubStr(SLF->LF_ACESSO,40,1)
	lRet :=  cRet == "S"
EndIf
RestArea(aArea)
Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA764
Rotina Para pegar a Adm Financeira

@author Rene Julian
@since 07/03/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function LJ764ADM(cFormPg,oRetItem,nItenMn)

Local cRet			:= ""
Local aAreaSAE		:= SAE->(Getarea())
Local cCodAdm       := ""
Local nX			:= 0

Default cFormPg		:= ""
Default oRetItem	:= Nil
Default nItenMn		:= 0

If AllTrim(cFormPg) == "FI" .And. nItenMn > 0
	cCodAdm := oRetItem:ACOLECAO[nItenMn][2]:cADM
	SAE->(DbSetOrder(1))			//AE_FILIAL+AE_COD
	If SAE->(DbSeek(xFilial("SAE")+cCodAdm ))
		cRet := SAE->AE_COD + " - " + SAE->AE_DESC	
	EndIf 
Else

	/*
	|| Verifica que sem Adm definida no cadastro da Milt Negocia็ใo
	|| se tiver atribui o codigo dela
	*/
	If ValType(oRetItem) == "O" .AND. Len(oRetItem:aColecao) > 0 //!Empty(oRetItem:aColecao[1][2]:CCODIGO)
		For nX := 1 To Len(oRetItem:aColecao)
			If oRetItem:aColecao[nX][01] == nItenMn .AND. !Empty(oRetItem:aColecao[nX][02]:CADM)
				cRet := oRetItem:aColecao[nX][02]:CADM + " - " + oRetItem:aColecao[nX][02]:CDESCADM
				Exit
			EndIf
		Next nX		
	EndIf

EndIf	

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj764VParc
Rotina para validar a quantidade de parcelas, pois caso ultrapasse a quantidade
no campo de parcelas sera gravado caracteres estranhos.

@author Rene Julian
@since 03/08/2016
@version P11
/*/
//-------------------------------------------------------------------

STatic Function Lj764VParc(aFPEnInf,nGetParce)
Local lRet := .T.
Local nQntent := 0
Default aFPEnInf := {}
Default nGetParce := 0

If !Empty(aFPEnInf[1,1])
	nQntent := Len(aFPEnInf)
EndIf

If  SuperGETMV("MV_1DUP")="A"
	If (nGetParce + nQntent) > 26
   		MsgAlert(STR0069) //"Quantidade de parcelas superior ao permitido. Verifique as configura็๕es do Parยmetro MV_1DUP e o tamanho do campo E1_PARCELA"
    	lRet := .F.
 	EndIf
ElseIf TamSX3("E1_PARCELA")[1] = 1
	If (nGetParce + nQntent) > 60
		MsgAlert(STR0069) //"Quantidade de parcelas superior ao permitido. Verifique as configura็๕es do Parยmetro MV_1DUP e o tamanho do campo E1_PARCELA"
       lRet := .F.
 	EndIf

EndIf


Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} Loj764VConf
Rotina para validar a quantidade de parcelas, pois caso ultrapasse a quantidade
no campo de parcelas sera gravado caracteres estranhos.

@author Rene Julian
@since 03/08/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function Loj764VConf(aResumNeg,lProcessa,oBtConfirma,nVlrFin)
Local nTotParc := 0	// Total de parcelas selecionadas.
Local nPgtotal := 0
Local nX      := 0

Default aResumNeg := {}
Default lProcessa := .T.
Default nVlrFin   := 0

lProcessa := .T.
If !Empty(aResumNeg[1,1])
	nTotParc := Len(aResumNeg)
Else
	lProcessa := .F.
	Return(lProcessa)
EndIf

If  SuperGETMV("MV_1DUP")="A"
	If nTotParc > 26
   		MsgAlert(STR0069) //"Quantidade de parcelas superior ao permitido. Verifique as configura็๕es do Parยmetro MV_1DUP e o tamanho do campo E1_PARCELA"
    	lProcessa := .F.
 	EndIf
ElseIf TamSX3("E1_PARCELA")[1] = 1
	If nTotParc  > 60
		MsgAlert(STR0069) //"Quantidade de parcelas superior ao permitido. Verifique as configura็๕es do Parยmetro MV_1DUP e o tamanho do campo E1_PARCELA"
       lProcessa := .F.
 	EndIf
EndIf

For nX := 1 to Len (aResumNeg)
	nPgtotal += aResumNeg[nX][8]
Next nX

If nVlrFin > nPgtotal
	MsgAlert(STR0070) // O Valor Negociado nใo pode ser inforior ao valor da Compra.
	lProcessa := .F.
EndIf
Return(lProcessa)

/*/{Protheus.doc} Lj7MudaID
	Cria tela para mudan็a do ID do Cartใo quando Multi-Negocia็ใo
	@author Gilmar Costa
	@since 26/05/2020
	@version p12
*/
Function Lj7MudaID(aResumNeg, nLinRN)
Local oIDCart
Local lConfirma := .F.
Local dData 		:= aResumNeg[nLinRN,1]
Local nValor 		:= Val(aResumNeg[nLinRN,2])
local cForma		:= aResumNeg[nLinRN,3]
Local cFormaId		:= aResumNeg[nLinRN,6]

	DEFINE MSDIALOG oDlgPgto TITLE STR0005 FROM 0,0 TO 15,41 OF oDlgVA  //"Multi Negocia็ใo"
	@ 0.3,1 TO 7,18.9 OF oDlgPgto

	@ 1,2    SAY STR0046 SIZE 10,1  				//"Data"
	@ 1,9  MSGET oData VAR dData RIGHT SIZE 45,08 When .F.
		
	@ 2,2    Say STR0019 SIZE 10,1 					//"Valor"
	@ 2,9  MSGET oValor VAR nValor	RIGHT SIZE 55,08 PICTURE PesqPict("SL1","L1_VLRTOT") When .F.

	@ 3,2    Say STR0013 SIZE 10,1 					//"Forma Pgto"
	@ 3,9  MSGET oForma VAR cForma OF oDlgPgto SIZE 15,10 When .F.

	If SuperGetMV("MV_TEFMULT")
		@ 4,2    Say oIDCart VAR STR0071 SIZE 10,1	//"ID"
		@ 4,9  MSGET oCart VAR cFormaId RIGHT SIZE 15,08 PICTURE PesqPict("SL4","L4_FORMAID")
	EndIf

	DEFINE SBUTTON FROM 100,095 	TYPE 1 ACTION (lConfirma := .T., oDlgPgto:End()) ENABLE		//Ok
	DEFINE SBUTTON FROM 100,124.1 	TYPE 2 ACTION ( oDlgPgto:End(), Nil) ENABLE					//Cancelar
	ACTIVATE MSDIALOG oDlgPgto CENTERED

	If lConfirma
		aResumNeg[nLinRN,6] := cFormaId
	EndIf	

Return(lConfirma)	
