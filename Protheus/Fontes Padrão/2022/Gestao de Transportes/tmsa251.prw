#INCLUDE "TMSA251.ch"
#INCLUDE "PROTHEUS.ch"

Static lTM251Lib := ExistBlock('TM251Lib')
Static lTM251Est := ExistBlock('TM251Est')
Static lTM251Par := ExistBlock('TM251PAR')
Static lTM251XML := ExistBlock('TM251XML')
Static lTM251Con := ExistBlock('TM251Con')
Static lTM251Can := ExistBlock('TM251Can')
Static lTM251Ope := ExistBlock('TM251Ope')
Static cTMSERP   := SuperGetMv("MV_TMSERP",,"0")
Static lRepTrace := SuperGetMv("MV_REPTRAC",,.T.) .And.  GetMV( 'MV_TMSXML',, .F. ) .And. ExistFunc('TmsRepTrac') //--ExistFunc("STBHomolPaf")
Static lRestRepom := SuperGetMV( 'MV_VSREPOM',, '1' ) == '2.2'

#xtranslate Trace251(<uVar>) => Iif(lRepTrace, TmsRepTrac(<uVar>), Nil)

/*Função Dummy apenas para o Translate. */
Static Function Trace251()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSA251  ³ Autor ³ Vitor Raspa           ³ Data ³ 06.jul.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Liberacao para Pagamento do Contrato de Carreteiro           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA251()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA251(cAlias,nReg,nOpc)

Local aSays         := {}
Local aButtons      := {}
Local nOpca         := 0

Default nOpc := 3

SaveInter()
cCadastro   := Iif(nOpc==3,STR0001,STR0050) //"Liberacao de Contrato de Carreteiro" ## "Pagto Saldo em Lotes"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Contrato de      ?                                      ³
//³ mv_par02 - Contrato Ate     ?                                      ³
//³ mv_par03 - Data de          ?                                      ³
//³ mv_par04 - Data Ate         ?                                      ³
//³ mv_par05 - Proprietario de  ?                                      ³
//³ mv_par06 - Loja de          ?                                      ³
//³ mv_par07 - Proprietario Ate ?                                      ³
//³ mv_par08 - Loja Ate         ?                                      ³
//³ mv_par09 - Filial Origem de ?                                      ³
//³ mv_par10 - Viagem de        ?                                      ³
//³ mv_par11 - Filial Origem Ate?                                      ³
//³ mv_par12 - Viagem Ate       ?                                      ³
//³ mv_par13 - Filtra Contratos ? (1=Aguard. Lib, 2=Liberados, 3=Ambos ³
//³ mv_par14 - Contabiliza on Line ?                                   ³
//³ mv_par15 - Mostra lancamentos contabeis    ?                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Pergunte("TMA251",.F.)

Aadd( aSays, Iif(nOpc == 3,STR0002,STR0051) ) //"Este programa ira filtrar os contratos de Carreteiro que estao com o Status Aguardando"  ##  "Este programa ira filtrar os contratos de Carreteiro para Pagto de Saldo na Operadora."
Aadd( aSays, Iif(nOpc == 3,STR0003,STR0052) ) //"Lib. Pagamento. Sera apresentada uma janela para que o usuario possa marcar "  ##  "Sera apresentada uma janela para que o usuario possa marcar "
Aadd( aSays, Iif(nOpc == 3,STR0004,STR0053) ) //"os  contratos que deverao ser liberados para pagamento"  ##  "os  contratos que deverao ter seu Saldo pagos junto à Operadora"

Aadd( aButtons, { 1, .T., {|o| nOpca := 1, o:oWnd:End() } } )
Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )
Aadd( aButtons, { 5, .T., {|| Pergunte("TMA251",.T.) } } )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	Processa({|lEnd| TMSA251Brw(nOpc)},"","",.F.)
EndIf

RestInter()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA251Brw ³ Autor ³ Vitor Raspa         ³ Data ³06.Jul.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Apresenta Browse para selecao dos contratos a serem        ³±±
±±³          ³liberados.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA251                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA251Brw(nOpc)

Local bFiltraBrw := {||}
Local aIndexDTY  := {}
Local cFilDTY    := ''
Local cRetPE     := ''
Local bIniBrw    := {||}

Default nOpc := 3 

Private oMarkBrw := NIL
Private aRotina  := MenuDef(nOpc)

     //+----------------------------------------------------------
     //| Composição do Filtro Padrão
     //+----------------------------------------------------------
     cFilDTY += 'DTY_NUMCTC >= "' + MV_PAR01 + '" .And. DTY_NUMCTC <= "' + MV_PAR02 + '"'
     cFilDTY += '.And. DtoS(DTY_DATCTC) >= "' + DtoS(MV_PAR03) + '" .And. DtoS(DTY_DATCTC) <= "' + DtoS(MV_PAR04) + '"'
     cFilDTY += '.And. DTY_CODFOR+DTY_LOJFOR >= "' + MV_PAR05+MV_PAR06 + '" .And. DTY_CODFOR+DTY_LOJFOR <= "' + MV_PAR07+MV_PAR08 + '"'
     cFilDTY += '.And. DTY_FILORI >= "' + MV_PAR09 + '" .And. DTY_FILORI <= "' + MV_PAR11 + '"'
     cFilDTY += '.And. DTY_VIAGEM >= "' + MV_PAR10 + '" .And. DTY_VIAGEM <= "' + MV_PAR12 + '"'
	 If nOpc == 5
		cFilDTY += '.And. DTY_CODOPE > " " '
	 ElseIf nOpc <> 5
		If MV_PAR13 == 1
			cFilDTY += '.And. DTY_STATUS == "2"'
		ElseIf MV_PAR13 == 2
			cFilDTY += '.And. DTY_STATUS $ "3|8|B"'
		ElseIf MV_PAR13 == 3
			cFilDTY += '.And. DTY_STATUS $ "2|3|8|B" '
		EndIf
	EndIf

     If   ExistBlock("TM251FIL")
          cRetPE := ExecBlock("TM251FIL",.F.,.F.,{cFilDTY})
          cFilDTY   := If(ValType(cRetPE)=="C", cRetPE, cFilDTY)
     EndIf


    //+-------------------------------------------------------------
    //| Instância do Objeto MarkBrowser
    //+-------------------------------------------------------------
    oMarkBrw := FwMarkBrowse():New() //('DTY','DTY_OK',,aCampos,, GetMark(,"DTY","DTY_OK"),'TMSA251Mrk("1")',,,,'TMSA251Mrk("2")',,,, aCores)
    oMarkBrw:SetAlias("DTY")
    oMarkBrw:SetDescription(cCadastro)

    oMarkBrw:SetFieldMark("DTY_OK")
    oMarkBrw:SetFilterDefault(cFilDTY)

    //+-------------------------------------------------------------
    //| Legendas do Browser
    //+-------------------------------------------------------------
    oMarkBrw:AddLegend("DTY_STATUS=='1'","BR_VERDE"        ,STR0039) //--"Em Aberto"
    oMarkBrw:AddLegend("DTY_STATUS=='2'","BR_AMARELO"      ,STR0040) //--"Aguardando Liberacao p/ Pagamento"
    oMarkBrw:AddLegend("DTY_STATUS=='3'","BR_LARANJA"      ,STR0041) //--"Liberacao p/ Pagamento"
    oMarkBrw:AddLegend("DTY_STATUS=='4'","BR_AZUL"         ,STR0042) //--"Contrato Quitado com Ped. de Compra"
    oMarkBrw:AddLegend("DTY_STATUS=='5'","BR_VERMELHO"     ,STR0043) //--"Contrato Quitado/Pagamento Realizado"
    oMarkBrw:AddLegend("DTY_STATUS=='A'","BR_VERDE_ESCURO" ,STR0044) //--"Contr.Parcial/Pagto Parcial"
    oMarkBrw:AddLegend("DTY_STATUS=='6'","BR_CINZA"        ,STR0045) //--"Titulo em Fatura"
    oMarkBrw:AddLegend("DTY_STATUS=='7'","BR_BRANCO"       ,STR0046) //--"Aguardando Confirm.Web Service"
    oMarkBrw:AddLegend("DTY_STATUS=='8'","BR_MARRON"       ,STR0047) //--"Aguardando Autoriz.Pagto"
    oMarkBrw:AddLegend("DTY_STATUS=='9'","BR_PRETO"        ,STR0048) //--"Pagamento Bloqueado"
	oMarkBrw:AddLegend("DTY_STATUS=='B'",'F12_MARR'		   ,STR0049) //--"Contrato Quitado/Aguardando autorização Operadora"

    oMarkBrw:SetValid({|| TMSA251Vld(nOpc)})
    oMarkBrw:SetAllMark({|| TMSA251Mrk("1") })
    oMarkBrw:SetDoubleClick({|| TMSA251Mrk("2") })
	oMarkBrw:SetAfterMark( {|| AfterMark() })

    //| Ativacao da classe
    oMarkBrw:Activate()

dbSelectArea("DTY")
RetIndex("DTY")
dbClearFilter()
aEval(aIndexDTY,{|x| Ferase(x[1]+OrdBagExt())})

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA250Lib³ Autor ³Vitor Raspa          ³ Data ³ 07.Jul.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa a Liberacao dos Contratos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA251                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA251Lib()
Processa({|| TMSA251Prc('1')},STR0001,STR0012,.F.) //"Liberacao de Contrato de Carreteiro"###"Processando a Opcao Selecionada ..."
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA250Est³ Autor ³Vitor Raspa          ³ Data ³ 07.Jul.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa o Estorno da Liberacao dos Contratos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA251                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA251Est()
Processa({|| TMSA251Prc('2')},STR0001,STR0012,.F.) //"Liberacao de Contrato de Carreteiro"###"Processando a Opcao Selecionada ..."
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA251Pg ³ Autor ³Daniel Leme          ³ Data ³ 07.Mai.22  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa o Pagto de Saldo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA251                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA251Pg()
Processa({|| TMSA251Prc('5')},STR0050,STR0012,.F.) //"Pagto Saldo em Lotes"###"Processando a Opcao Selecionada ..."
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSA251Prc³ Autor ³Vitor Raspa          ³ Data ³ 07.Jul.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa a Opcao Selecionada pelo usuario                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExpC1: Opcao Selecionada: 1=Liberar                        ³±±
±±³          ³                           2=Estornar Liberac.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA251                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA251Prc( cOpcao, lWs, aQuita, lPosto )
Local cQuery     := ''
Local cAliasQry  := GetNextAlias()
Local cMarca     := oMarkBrw:Mark() //ThisMark()
Local lInverte   := oMarkBrw:IsInvert()//ThisInv()
Local aDadosCTC  := {}
Local cQuebra    := ''
Local cCodForn   := ''
Local cLojForn   := ''
Local cCodFav    := ''
Local cLojFav    := ''
Local cCondPag   := ''
Local lTM250COND := ExistBlock('TM250COND')
Local cPrefixo   := ''
Local cTipDeb    := ''
Local cGerTitPdg := ''
Local cDedPdg    := ''
Local nBasImp    := 0
Local cPerg      := ""
Local aMsgErr    := {}
Local aVisErr    := {}
Local nOpcx      := 0
Local lRet       := .T.
Local cFilOld    := ''
Local lTMSOPdg   := SuperGetMV('MV_TMSOPDG',,'0') == '2' //-- Integracao com Operadoras de Frota
Local aDadosQuit := {}
Local aContratos := {}
Local aContrt    := {}
Local lTabDFI    := AliasIndic("DFI") .And. nModulo==39
Local cTipUso    := IIf(AliasIndic("DFI") .And. nModulo==39,"2","1")
Local nStatusDTY := 0
Local aStatusDTY := {}
Local cSeekSDG   := ""
Local bWhileSDG  := {||.T.}
Local cTMSDTVC   := SuperGetMV("MV_TMSDTVC",,"") //-- Data de Vigencia do Contrato do Fornecedor utilizada na Liberacao do Contrato: 1- Data da Emissao do Contrato, 2- Data Liberacao do Contrato.
Local cCodOpe 	 := ""
Local cFilOri 	 := ""
Local cViagem    := ""
Local cNumCtc 	 := ""
Local cTipDTY 	 := ""
Local cCodVei 	 := ""
Local aImposto	 := {}
Local cTipPess	 := ''
Local lRepom	 := SuperGetMV('MV_TMSOPDG',,'0') == '2' .And. SuperGetMV('MV_VSREPOM',,'0') $ '2|2.2'
Local lFilLib    := DTY->(FieldPos("DTY_FILLIB")) > 0
Local lSeqBx     := AliasIndic('DYI')
Local cSeekDYI	 := ''
Local aRetorno   := {{}}
Local cPrefTit   := ''
Local cNumContr	 := ''
Local lLibCTC	 := .T.
Local LTITFRE	 := DTY->(ColumnPos('DTY_TITFRE')) > 0
Local cGerTitCont := ''
Local cMomTitPDG  := "1"    //| Informa o momento que o tit.de pdg. deve ser gerado(Conf.Contrato do Fornecedor)
Local cMomTitAdi  := ""     //| Informa o momento que o tit.de adi. deve ser gerado(Conf.Contrato do Fornecedor)
Local lPaMovBco   := .F.
Local lReemb      := DTY->(ColumnPos('DTY_VLREEM')) > 0
Local aDadosOpe   := {}
Local lCiotPer    := DTR->(ColumnPos('DTR_TPCIOT')) > 0
Local cMv_NatCTC  := Padr( GetMV("MV_NATCTC"), Len( SE2->E2_NATUREZ ) ) //-- Natureza Contrato de Carreteiro
Local lMv_LibCTC  := SuperGetMv("MV_LIBCTC",,.F.)
Local cIdParcela  := ''
Local cNatuPDG    := Padr( GetMV('MV_NATPDG'), Len( SE2->E2_NATUREZ ) ) // Natureza Pedagio
Local cNatuDeb    := Padr( GetMV('MV_NATDEB'), Len( SE2->E2_NATUREZ ) ) // Natureza Utilizada nos Titulos Gerados para a Filial de Debito
Local cTipCTC     := Padr( GetMV('MV_TPTCTC'), Len( SE2->E2_TIPO ) )    // Tipo Contrato de Carreteiro
Local lTipOpVg    := DTQ->(ColumnPos("DTQ_TPOPVG")) > 0
Local cImpCTC 	  := SuperGetMv("MV_IMPCTC",,"0") //--Responsável pelo cálculo dos impostos (0=ERP/1=Operadora).
Local aErroSLD

//-- Variaveis utilizadas no TMSA250
Private cFilDeb     := ''
Private cPrefDeb    := ''
Private cUniao      := GetMV('MV_UNIAO')  	// Cod. para Pagto. do Imposto de Renda
Private cNatuCTC    := '' 					// Natureza Contrato de Carreteiro
Private cTipPDG     := Padr( GetMV('MV_TPTPDG'), Len( SE2->E2_TIPO ) )    // Tipo Pedagio
Private cTipPre     := Padr( GetMV('MV_TPTPRE'), Len( SE2->E2_TIPO ) )    // Tipo Premio
Private cCodDesCTC  := Padr( GetMV('MV_DESCTC'), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de contrato de carreteiro
Private cCodDesPDG  := Padr( GetMV('MV_DESPDG'), Len( DT7->DT7_CODDES ) ) // Codigo de Despóesa de Pedagio
Private cCodDesPRE  := Padr( GetMV('MV_DESPRE'), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Premio
Private nHdlPrv
Private lExcSched250 := IsBlind()   //--> Variável que será utilizada para definir se a execução é via Schedule.
Private oDTClass := NIL
Default lWs := .F.
Default aQuita := {}
Default lPosto := .F.

//|
//| Valida se existe a classe de integração EAI Contas Pagar
If Len(GetSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0
   oDTClass := TransportDocumentClass():New()
EndIf

//-- Se o parametro MV_TPTCTC nao estiver preenchido
If Empty(cTipCTC)
	cTipCTC   := Padr( "C" + FWFilial(),Len(SE2->E2_TIPO))
EndIf

cPrefixo := TMA250GerPrf(cFilAnt)

If lTM251Par
	cNatuPDG := ExecBlock('TM251PAR',.F.,.F.,{2})
	cNatuDeb := ExecBlock('TM251PAR',.F.,.F.,{3})
	If ValType(cNatuPDG) <> 'C'
		cNatuPDG := Padr( GetMV("MV_NATPDG"), Len( SE2->E2_NATUREZ ) ) // Natureza Pedagio
	EndIf
	If ValType(cNatuDeb) <> 'C'
		cNatuDeb := Padr( GetMV("MV_NATDEB"), Len( SE2->E2_NATUREZ ) ) // Natureza Utilizada nos Titulos Gerados para a Filial de Debito
	EndIf
EndIf

//-- Recarrega as Perguntas
Pergunte("TMA251",.F.)

If lWs .And. !Empty(aQuita) // Recebe dados do Ws para usar na query / ignora o pergunte
	cQuery := "SELECT DTY_NUMCTC, DTY_TIPCTC, DTY_VALFRE, DTY_CODFOR, DTY_LOJFOR, DTY_CODFAV, DTY_LOJFAV, DTY_IRRF, DTY_SEST, DTY_INSS, DTY_CSLL, DTY_ISS, DTY_PIS, DTY_COFINS, "
	cQuery += "DTY_FILORI, DTY_VIAGEM, DTY_VALPDG, DTY_ADIFRE, DTY_CODVEI, DTY_DOCSDG, DTY_STATUS, DTY_BASIMP, DTY_CODOPE, DTY_DATCTC, DTY_FILDEB, " + IIf(lFilLib,'DTY_FILLIB,','') + IIf(LTITFRE,'DTY_TITFRE,','') + 'DTY_PARCTC,' + IIf(lReemb,'DTY_VLREEM,','')  + " R_E_C_N_O_ RECDTY "
	cQuery += "FROM " + RetSqlName("DTY") + " WHERE "
	cQuery += "DTY_FILIAL = '" + xFilial('DTY') + "' AND "
	cQuery += "DTY_NUMCTC = '" + aQuita[1] + "' AND "
	cQuery += "DTY_CODFOR = '" + aQuita[2] + "' AND "
	cQuery += "DTY_LOJFOR = '" + aQuita[3] + "' AND "
	cQuery += "DTY_FILORI = '" + aQuita[4] + "' AND "
	cQuery += "DTY_VIAGEM = '" + aQuita[5] + "' AND "
	If cOpcao == '1' //-- Liberar
		If lWs
			cQuery += "DTY_STATUS = '1' AND "
		Else
			cQuery += "DTY_STATUS = '2' AND "
		EndIf
	EndIf
	cQuery += "D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY DTY_NUMCTC"
	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza o filtro no DTY conforme itens selecionados no MarkBrowse ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT DTY_NUMCTC, DTY_TIPCTC, DTY_VALFRE, DTY_CODFOR, DTY_LOJFOR, DTY_CODFAV, DTY_LOJFAV, DTY_IRRF, DTY_SEST, DTY_INSS, DTY_CSLL, DTY_ISS, DTY_PIS, DTY_COFINS, "
	cQuery += "DTY_FILORI, DTY_VIAGEM, DTY_VALPDG, DTY_ADIFRE, DTY_CODVEI, DTY_DOCSDG, DTY_STATUS, DTY_BASIMP, DTY_CODOPE, DTY_DATCTC, DTY_FILDEB, " + IIf(lFilLib,'DTY_FILLIB,','') + IIf(LTITFRE,'DTY_TITFRE,','') + 'DTY_PARCTC,' + IIf(lReemb,'DTY_VLREEM,','')+ " R_E_C_N_O_ RECDTY "
	cQuery += "FROM " + RetSqlName("DTY") + " WHERE "
	cQuery += "DTY_FILIAL = '" + xFilial('DTY') + "' AND "
	cQuery += "DTY_NUMCTC BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
	cQuery += "DTY_DATCTC BETWEEN '" + DtoS(MV_PAR03) + "' AND '" + DtoS(MV_PAR04) + "' AND "
	cQuery += "DTY_CODFOR BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR07 + "' AND "
	cQuery += "DTY_LOJFOR BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR08 + "' AND "
	cQuery += "DTY_FILORI BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR11 + "' AND "
	cQuery += "DTY_VIAGEM BETWEEN '" + MV_PAR10 + "' AND '" + MV_PAR12 + "' AND "
	If lInverte <> Nil .and. cMarca <> Nil
		If ( lInverte )
			cQuery    += "DTY_OK <> '" + cMarca + "' AND "
		Else
			cQuery    += "DTY_OK = '" + cMarca + "' AND "
		EndIf
	EndIf
	If cOpcao == '1' //-- Liberar
		If lWs
			cQuery += "DTY_STATUS = '1' AND "
		Else
			cQuery += "(DTY_STATUS = '2' OR (DTY_STATUS = 'B' AND DTY_CODOPE = '01')) AND "
		EndIf
	ElseIf cOpcao == '2' //-- Estornar liberacao
		cQuery += "DTY_STATUS in('3','8','B') AND "
	EndIf
	cQuery += "D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY DTY_NUMCTC"
	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
EndIf
If !(cAliasQry)->(EoF())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do Array aDadosCTC:                                        ³
	//³ aDadosCTC[n,01] - Codigo do Fornecedor                               ³
	//³ aDadosCTC[n,02] - Loja do Fornecedor                                 ³
	//³ aDadosCTC[n,03] - Tipo Fornec. (Pessoa Fisica, Juridica, ...)        ³
	//³ aDadosCTC[n,04] - Contato do Fornecedor                              ³
	//³ aDadosCTC[n,05] - Filial de Debito Fornecedor                        ³
	//³ aDadosCTC[n,06] - Condicao de Pagamento do Fornecedor                ³
	//³ aDadosCTC[n,07] - Filial de Origem                                   ³
	//³ aDadosCTC[n,08] - No. da Viagem                                      ³
	//³ aDadosCTC[n,09] - No. do Contrato                                    ³
	//³ aDadosCTC[n,10] - Valor do Frete informado na viagem / Calculado     ³
	//³ aDadosCTC[n,11] - Valor dos Adiantamentos                            ³
	//³ aDadosCTC[n,12] - Credor dos Adiantamentos                           ³
	//³ aDadosCTC[n,13] - Loja do Credor                                     ³
	//³ aDadosCTC[n,14] - Prefixo do Titulo                                  ³
	//³ aDadosCTC[n,15] - Codigo do Veiculo                                  ³
	//³ aDadosCTC[n,16] - Valor do Pedagio                                   ³
	//³ aDadosCTC[n,17] - Tipo do Titulo                                     ³
	//³ aDadosCTC[n,18] - Codigo do Favorecido                               ³
	//³ aDadosCTC[n,19] - Loja do Favorecido                                 ³
	//³ aDadosCTC[n,20] - Valor do ISS                                       ³
	//³ aDadosCTC[n,21] - Natureza do Titulo                                 ³
	//³ aDadosCTC[n,22] - Gera Titulo do Pedagio ? (1=Sim/2=Nao)             ³
	//³ aDadosCTC[n,23] - Deduz Pedagio do Valor do Frete? (1=Sim/2=Nao)     ³
	//³ aDadosCTC[n,24] - Valor Base para Calculo dos Impostos               ³
	//³ aDadosCTC[n,25] - Controla a Liberacao do Contrato de Carreteiro?    ³
	//³ aDadosCTC[n,26] - Contrato vinculado a Operadora de Frotas?          ³
	//³ aDadosCTC[n,27] - Valor do INSS Retido                               ³
	//³ aDadosCTC[n,28] - Tipo de Uso - 1=Viagem;2=Carga - Frete Embarcador  ³
	//³ aDadosCTC[n,29] - Indentificador de Viagem ou Carga - Frt.Embarcador ³
	//³ aDadosCTC[n,30] - Gera Titulo do Contrato ?(1=Sim/2=Nao)             ³
	//³ aDadosCTC[n,31] - Rota Municipal ?(1=Sim/2=Nao)                      ³
	//³ aDadosCTC[n,32] - Gera Pedido de Venda ?(1=Sim/2=Nao)                ³
	//³ aDadosCTC[n,33] - Array de Impostos pela Repom (IRRF,SEST, INSS)     ³
	//³ aDadosCTC[n,34] - Codigo da Operadora de Frete e Pedagio        	 ³
	//³ aDadosCTC[n,35] - Foi executada a liberacao do contrato?        	    ³
	//³ aDadosCTC[n,36] - Gera titulo do frete, independente do MV_LIBCTC?    ³
	//³ aDadosCTC[n,37] - Baixa Titulo de Pedagio Automaticamente	     	    ³
	//³ aDadosCTC[n,38] - Gera o Titulo de NDF na geracao do conrato  		 ³
	//³                   independente do MV_LIBCTC?						 ³
	//³ aDadosCTC[n,39] - Informa se o titulo de NDF ja foi gerado    	   	 ³
	//³ aDadosCTC[n,40] - Informa o momento que o tit.de pdg. deve ser gerado³
	//³ aDadosCTC[n,41] - Informa o momento que o tit.de adi. deve ser gerado³
	//³ aDadosCTC[n,42] - Informa se o PA deverá movimentar banco.           ³
	//³ aDadosCTC[n,43] - Valor do reembolso						         ³
	//³ aDadosCTC[n,44] - CIOT (somente por periodo)                         ³
	//³ aDadosCTC[n,45] - contrato complementar                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cOpcao == '1'

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³LIBERACAO DOS CONTRATOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		cQuebra := (cAliasQry)->(DTY_NUMCTC + DTY_TIPCTC)
		While !(cAliasQry)->(EoF()) .And. lRet
			If lRepTrace
				Trace251("While 1 " + AllToChar((cAliasQry)->(Recno())))
			EndIf
			If lTM251Con
				lRetPE := ExecBlock('TM251Con',.F.,.F.,{(cAliasQry)->DTY_NUMCTC,(cAliasQry)->DTY_FILORI,(cAliasQry)->DTY_VIAGEM})
				If ValType(lRetPE)=="L" .And. !lRetPE
					(cAliasQry)->(DbSkip())
					Loop
				EndIf
  			EndIf

			//-- Verifica a Filial de Debito (posiciona no arquivo SA2)
			cCodForn := (cAliasQry)->DTY_CODFOR
			cLojForn := (cAliasQry)->DTY_LOJFOR
			cCodFav  := (cAliasQry)->DTY_CODFAV
			cLojFav  := (cAliasQry)->DTY_LOJFAV
			cFilDeb 	:= TMSA250FilDeb(cCodForn, cLojForn, @cCodFav, @cLojFav, .F., (cAliasQry)->DTY_FILORI, (cAliasQry)->DTY_VIAGEM,,(cAliasQry)->DTY_CODVEI) //--Nao checa filial de descarga
			Trace251("250FilDeb")
			SA2->(DbSetOrder(1))
			SA2->(MsSeek(FwxFilial('SA2')+cCodForn+cLojForn))

			Trace251("Seek SA2")
			cCondPag := SA2->A2_COND
			If lTM250COND
				cCondPag := ExecBlock('TM250COND',.F.,.F.)
				If ValType(cCondPag) <> 'C'
					cCondPag := Space(Len(SA2->A2_COND))
				Else
					SE4->(DbSetOrder(1))
					If SE4->(!dbSeek(xFilial('SE4') + cCondPag))
						cCondPag := Space(Len(SA2->A2_COND))
					EndIf
				EndIf
			EndIf
			Trace251("Seek SE4")
			If Empty(cCondPag) .And. cTMSERP == "0" //| valida condição de pagamento somente quando integração está desligada.
				AAdd( aMsgErr, { STR0013 + SA2->A2_COD + "/" + SA2->A2_LOJA + ' - ' + AllTrim(SA2->A2_NREDUZ), '03', "MATA020()" } ) // 'Cond. de Pagamento Invalida ou nao informada no Fornecedor: '
				lRet := .F.
			EndIf
			If !lFilLib .And. (cAliasQry)->(DTY_FILORI) <> cFilAnt
				If lRet .And. lRepom .And. (cAliasQry)->DTY_CODOPE == '01'
					lRet:= .T.
				Else
					AAdd( aMsgErr, { STR0025 + (cAliasQry)->(DTY_NUMCTC) + " " + STR0026 + (cAliasQry)->(DTY_FILORI) + "!" + STR0027, '06',"TMSA251()"} ) //--"O Contrato "//--"deve ser liberado pela filial: "//--"Para efetuar liberacao por outras filiais execute o Update TMS10R169."
					lRet := .F.
				EndIf
			EndIf
			If Empty(cTipCTC)
				cTipDeb := Padr( "C" + cFilDeb, Len( SE2->E2_TIPO ) )
			Else
				cTipDeb := cTipCTC
			EndIf
			If Empty(Tabela("05",cTipDeb,.F.))
				AAdd( aMsgErr, { STR0015 +  cFilDeb + '. ' + STR0016 + cFilDeb , '02', "" } ) //"Nao foi encontrado o tipo de Titulo na Tabela '05' para a filial de Debito: "### "Tipo do Titulo a ser cadastrado : "
				lRet := .F.
			EndIf
			Trace251("Seek Sx5")

			If !Empty(SA2->A2_NATUREZ)
				cNatuCTC := SA2->A2_NATUREZ
			Else
				cNatuCTC := cMv_NatCTC
			EndIf
			If cTMSERP == "0"
				If Empty(cNatuCTC)
					AAdd( aMsgErr, { STR0028 + (cAliasQry)->(DTY_NUMCTC) + " " + STR0029 , '04', "" } ) //""Natureza do Contrato de Carreteiro: " //--"nao encontrada."
					lRet := .F.
				Else
					SED->(dbSetOrder(1))
					If !SED->(MsSeek(xFilial('SED')+cNatuCTC) )
						AAdd( aMsgErr, { STR0030 , '05', "" } ) //"Conteudo do parametro invalido MV_NATCTC"
						lRet := .F.
					EndIf
				EndIf
				Trace251("Seek SED")
			EndIf

			Trace251("Continua " +AllToChar(lRet))
			If lRet
				DTQ->(DbSetOrder(2))
				DTQ->(MsSeek(xFilial('DTQ') + (cAliasQry)->(DTY_FILORI + DTY_VIAGEM)))
				Trace251("Seek DTQ: "+ xFilial('DTQ') + (cAliasQry)->(DTY_FILORI + DTY_VIAGEM))

				aContrt := TMSContrFor(cCodForn, cLojForn,Iif(cTMSDTVC == "2",dDataBase,STOD((cAliasQry)->DTY_DATCTC)),;
				DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA,.F.,Posicione('DA3',1,xFilial('DA3') + (cAliasQry)->DTY_CODVEI,'DA3_TIPVEI'),Iif(lTipOpVg,DTQ->DTQ_TPOPVG,''))
				Trace251("aContrt "+ AllToChar(Empty(aContrt)))

				If Empty(aContrt)
					aContrt := TMSContrFor(cCodForn, cLojForn,Iif(cTMSDTVC == "2",dDataBase,STOD((cAliasQry)->DTY_DATCTC)),;
					DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA,.T.,,Iif(lTipOpVg,DTQ->DTQ_TPOPVG,''))
					Trace251("aContrt 2 "+ AllToChar(Empty(aContrt)))
				EndIf

				cGerTitPDG := ""
				cDedPDG    := ""
				If Len(aContrt) > 0
					cGerTitPDG := aContrt[1][5]
					cDedPDG    := aContrt[1][6]
					cGerTitCont:= aContrt[1][8]
					cMomTitPDG := aContrt[1][15]
					cMomTitAdi := aContrt[1][13]
				EndIf

				If Empty(cGerTitPDG) .And. !lRepom .And. (cAliasQry)->DTY_CODOPE == '01'
					lRet := .F.
				EndIf

				//-- Valor da Base dos Impostos
				nBasImp := (cAliasQry)->DTY_BASIMP
			EndIf

			Trace251("Continua 2 " +AllToChar(lRet))
			If lRet
				//-- Rota Municipal
				cRotMun:=''
				If cTipUso == "1" //--TMS
					DA8->(DbSetOrder(1))
					If DA8->(MsSeek(xFilial("DA8")+DTQ->DTQ_ROTA))
						cRotMun:= DA8->DA8_ROTMUN
					EndIf
				EndIf
				Trace251("Seek DA8 " +  cRotMun )

				SA2->(DbSetOrder(1))
				If SA2->(DbSeek(xFilial("SA2")+cCodForn+cLojForn))
					cTipPess := SA2->A2_TIPO
				EndIf

				Trace251("Seek SA2 cTipPess " +  cTipPess )
				//--Se o título já foi gerado, seta variável de liberação = .F. para que na TMSA250QBR, ele não tente gerar o título
				If (IIf(LTITFRE,(cAliasQry)->DTY_TITFRE,'') == '1')
					cGerTitCont := "2"
				EndIf

				AAdd( aDadosCTC, {	(cAliasQry)->DTY_CODFOR,;      //|01
									(cAliasQry)->DTY_LOJFOR,; //|02
									SA2->A2_TIPO,;            //|03
									SA2->A2_CONTATO,;         //|04
									cFilDeb,;                 //|05
									cCondPag,;                //|06
									(cAliasQry)->DTY_FILORI,; //|07
									(cAliasQry)->DTY_VIAGEM,; //|08
									(cAliasQry)->DTY_NUMCTC,; //|09
									(cAliasQry)->DTY_VALFRE,; //|10
									(cAliasQry)->DTY_ADIFRE,; //|11
									(cAliasQry)->DTY_CODFOR,; //|12
									(cAliasQry)->DTY_LOJFOR,; //|13
									cPrefixo,;                //|14
									(cAliasQry)->DTY_CODVEI,; //|15
									(cAliasQry)->DTY_VALPDG,; //|16
									cTipDeb,;                 //|17
									cCodFav,;                 //|18
									cLojFav,;                 //|19
									0,;//|20
									cNatuCTC,;//|21
									cGerTitPdg,;//|22
									cDedPdg,;//|23
									nBasImp,;//|24
									lLibCTC,; //|25
									.F.,;//|26
									Posicione("DTR",3,xFilial("DTR")+(cAliasQry)->(DTY_FILORI+DTY_VIAGEM+DTY_CODVEI),"DTR_INSRET"),;//|27
									,;//|28
									,;//|29
									cGerTitCont,;//|30
									cRotMun,;//|31
									'2',;//|32
									aImposto,;//|33
									(cAliasQry)->DTY_CODOPE,;//|34
									.T.,;//|35
									'1',;//|36
									'',;//|37
									'1',;//|38
									.F.,;           							//| 39 - Informa se o titulo de NDF ja foi gerado
									cMomTitPDG,;    							//| 40 - Informa o momento que o tit.de pdg. deve ser gerado
									cMomTitAdi,;    							//| 41 - Informa o momento que o tit.de adi. deve ser gerado
									lPaMovBco,;									//| 42 - Informa se o PA deverá movimentar banco.
									IIf(lReemb,(cAliasQry)->DTY_VLREEM,0),;   	//| 43 - Valor do reembolso
									IIf(lCiotPer .And. DTR->DTR_TPCIOT == "2", DTR->DTR_CIOT,"" ),;   	//| 44 - CIOT
									(cAliasQry)->DTY_TIPCTC == '5'}) //| 45 - Contrato Complementar?

				Trace251("aDadosCTC OK " +  AllToChar(Len(aDadosCTC)) )

				If	cMarca <> NIL
					aAdd(aStatusDTY , {(cAliasQry)->RECDTY,'3',dDataBase,Iif(IsMark("DTY_OK", cMarca), Space(Len(DTY->DTY_OK)), cMarca)} )
					Trace251("aStatusDTY OK " +  AllToChar(Len(aStatusDTY)) )
				Else
					aAdd(aStatusDTY , {(cAliasQry)->RECDTY,'3',dDataBase} )
					Trace251("aStatusDTY 2 OK " +  AllToChar(Len(aStatusDTY)) )
				EndIf
			EndIf

			cCodOpe := (cAliasQry)->DTY_CODOPE
			cFilOri := (cAliasQry)->DTY_FILORI
			cViagem := (cAliasQry)->DTY_VIAGEM
			cNumCtc := (cAliasQry)->DTY_NUMCTC
			cTipDTY := (cAliasQry)->DTY_TIPCTC
			cCodVei := (cAliasQry)->DTY_CODVEI

			Trace251("Qry Skip")

			(cAliasQry)->(DbSkip())

			Trace251("Continua 3 " +AllToChar(lRet .And. ( (cAliasQry)->(EoF()) .Or. cQuebra <> (cAliasQry)->(DTY_NUMCTC + DTY_TIPCTC)) ) )
			If lRet .And. ( (cAliasQry)->(EoF()) .Or. cQuebra <> (cAliasQry)->(DTY_NUMCTC + DTY_TIPCTC))
				If Right(cQuebra,1) == '1' //-- Por Viagem
					cPerg := "TMA250"
					nOpcx := 3
				ElseIf Right(cQuebra,1) == '2' .Or. Right(cQuebra,1) == '5' //-- Por Periodo ou Complementar
					cPerg := "TM250A"
					nOpcx := 4
				ElseIf Right(cQuebra,1) == '3'
					cPerg := "TMA251"
					nOpcx := 0
				EndIf

				aDadosOpe := {}
				If lRet .And. cCodOpe == "01" .And. DTY->DTY_STATUS != 'B' .And. cGerTitCont == "1"
					If !lRestRepom 
						Trace251("Consultando contrato " )
						lRet := A250ChkOpe(cCodOpe,DTY->DTY_FILORI,DTY->DTY_VIAGEM,@aDadosOpe,@aMsgErr)
						Trace251("Retornando consulta contrato " + AllToChar(lRet))
					Else
						If cImpCTC == "1"   //--Responsável pelo cálculo dos impostos (0=ERP/1=Operadora).
							lRet := A250ChkRep(DTY->DTY_FILORI,DTY->DTY_VIAGEM,@aMsgErr)
						Else
							//--- Verifica se o Contrato está Quitado na Repom para geração do titulo
							lRet := TMSC15ARep(10,DTY->DTY_FILORI,DTY->DTY_VIAGEM)
							If !lRet
								AAdd(aMsgErr,{"O Contrato não está Quitado na REPOM: " + DTY->DTY_NUMCTC  } ) 
							EndIf
						EndIf
					EndIf
				EndIf

				If lRet

					Begin Transaction
						Trace251("Begin Transaction " + DTY->DTY_STATUS)

						If !(cCodOpe == "01" .And. DTY->DTY_STATUS == 'B')
							//-- Acrescentado o looping abaixo para tratar parcelas, já que no SDG pode existir 'n' parcelas vinculadas numa única viagem
							aAreaSDG := Getarea("SDG")
							SDG->(Dbsetorder(5))
							If lMv_LibCTC .And. SDG->(MsSeek(xFilial("SDG")+DTY->DTY_FILORI+DTY->DTY_VIAGEM))
								Trace251("Seek SDG libctc "+  xFilial("SDG")+DTY->DTY_FILORI+DTY->DTY_VIAGEM )
								While SDG->(!EOF()) .And. SDG->(DG_FILORI+DG_VIAGEM) == DTR->(DTR_FILORI+DTR_VIAGEM)
									Trace251("Loop SDG "+ AllToChar(SDG->(Recno())))
									TMSA070Bx("1",SDG->DG_SEQORI,SDG->DG_FILORI,SDG->DG_VIAGEM,SDG->DG_CODVEI,DATE(),"01",SDG->DG_VALCOB,,,,)
									SDG->(DbSkip())
								EndDo
							EndIf
							RestArea(aAreaSDG)

							Trace251("Chamando TMSA250Qbr "+AllToChar(Intransact()) )
							lRet := TMSA250QBR(nOpcx, aDadosCTC, aMsgErr, aVisErr, cPerg,,,cNatuPDG,cNatuDeb,cTipCTC)
							Trace251("Voltando TMSA250Qbr "+AllToChar(Intransact()) + AllToChar(lRet))

							If lRet
								For nStatusDTY := 1 To Len(aStatusDTY)
									Trace251("STATUS DTY " + AllToChar(aStatusDTY[nStatusDTY][1]))
									DTY->(DbGoTo( aStatusDTY[nStatusDTY][1] ))
									RecLock('DTY',.F.)
									If DTY->DTY_CODOPE== '01' .And. DTY->DTY_LOCQUI != '1' // Se quita em filial, aguarda aviso de pagamento
										DTY->DTY_STATUS := '8'
									Else
										DTY->DTY_STATUS := aStatusDTY[nStatusDTY][2] //-- Liberado para Pagamento
									EndIf
									DTY->DTY_DATLIB := aStatusDTY[nStatusDTY][3]
									If cMarca <> NIL
										DTY->DTY_OK 	:= aStatusDTY[nStatusDTY][4]
									EndIf
									If lFilLib
										DTY->DTY_FILLIB := cFilAnt
									EndIf
									DTY->DTY_FILDEB := cFilDeb

									MsUnLock()
								Next nStatusDTY
							EndIf
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REALIZA A INTEGRACAO COM OPERADORAS DE FROTA³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Trace251("Continua 4 " + AllToChar( lRet .And. lTMSOPdg .And. !Empty(cCodOpe) .And. (cCodOpe != '01' .Or. cTipDTY <> '5') )  )
						If lRet .And. lTMSOPdg .And. !Empty(cCodOpe) .And. (cCodOpe != '01' .Or. cTipDTY <> '5')
							CursorWait()
							Trace251("Chamando o TMA251Aut"+ AllToChar(Intransact()))
							MsgRun( STR0019,; //-- "Autorização do Pagamento do Contrato..."
									STR0018,; //-- 'Aguarde...'
									{|| lRet := TMA251Aut( cCodOpe, cFilOri, cViagem, @aMsgErr, @aDadosQuit, cNumCtc, cCodVei, .F., cCondPag, cCodForn, cLojForn )} )
							CursorArrow()
							Trace251("Voltando do TMA251Aut lRet/Intran "+ AllToChar(lRet) + "/"+ AllToChar(Intransact()))
							If !lRet .And. cCodOpe == "01"
								lRet := .T. //-- Não Desarma a transação caso o erro seja apenas na autorização, quando Repom
								//-- Ajusta Status do contrato para reenvio da autorização
								For nStatusDTY := 1 To Len(aStatusDTY)
									Trace251("Ajustando nAutorizado: STATUS DTY " + AllToChar(aStatusDTY[nStatusDTY][1]))
									DTY->(DbGoTo( aStatusDTY[nStatusDTY][1] ))
									RecLock('DTY',.F.)
									DTY->DTY_STATUS := "B" //-- Contrato Quitado/Aguardando autorização Operadora
									MsUnLock()
								Next nStatusDTY
							ElseIf lRet .And. cCodOpe == "01" .And. DTY->DTY_STATUS == "B"
								RecLock('DTY',.F.)
								If DTY->DTY_LOCQUI != '1'
									DTY->DTY_STATUS := '8'
								Else
									DTY->DTY_STATUS := "3"
								EndIf
								MsUnLock()
							EndIf
						EndIf

						cQuebra   := (cAliasQry)->(DTY_NUMCTC + DTY_TIPCTC)
						aDadosCTC := {}
						aStatusDTY:= {}

						If !lRet
							Trace251("Disarm Transaction" + AllToChar(Intransact()))
							DisarmTransaction()
						EndIf
						Trace251("End Transaction" + AllToChar(Intransact()))
					End Transaction
				Else
					Trace251("Não liberou" + AllToChar(Intransact()))
				EndIf
			EndIf

			//-- Array para o Ponto de entrada
			If lTM251Lib .And. lRet
				AAdd( aContratos, { cFilOri, cViagem, cNumCtc } )
			EndIf

			lRet := .T. // Voltando lRet verdadeiro para processar proximos registros

			Trace251("EndDo")
		EndDo

		//-- Ponto de Entrada apos a liberacao do contrato:
		If lTM251Lib .And. Len(aContratos) > 0
			ExecBlock('TM251Lib',.F.,.F.,{ aContratos })
		EndIf

	ElseIf cOpcao == '2' //-- Estorno da Liberacao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ESTORNO DA LIBERACAO DOS CONTRATOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !(cAliasQry)->(EoF()) .And. lRet

			//--Verifica se o título foi gerado na geração do contrato
			If LTITFRE
				cGerTitCont := (cAliasQry)->DTY_TITFRE			
			EndIf

			Trace251("ESTORNO DA LIBERACAO DOS CONTRATOS " + (cAliasQry)->(DTY_FILORI+"/"+DTY_VIAGEM+"/"+DTY_NUMCTC+"/"+DTY_STATUS+"/"+DTY_CODOPE+"/"+DTY_TIPCTC) )
			If lTM251Can
				lRet := ExecBlock('TM251Can',.F.,.F., {(cAliasQry)->DTY_FILORI, (cAliasQry)->DTY_VIAGEM, (cAliasQry)->DTY_NUMCTC } ) //--(cAliasQry)->DTY_NUMCTC
				If ValType(lRet) != "L"
					lRet := .T.
				EndIf
				Trace251("Estorno Lib - retorno PE TM251Can "+ AllToChar(lRet) )
			EndIf

			If lRet
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se a Filial foi a responsavel pela liberacao  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lFilLib .And. !Empty((cAliasQry)->DTY_FILLIB)
					If (cAliasQry)->DTY_FILLIB <> cFilAnt
				  		AAdd( aMsgErr, { STR0031 + (cAliasQry)->(DTY_NUMCTC)  + " " + STR0032 + (cAliasQry)->(DTY_FILLIB), '04', "TMSA251()" } ) //--"O Estorno da liberacao do contrato: "//--"deve ser realizado pela filial: "
						Trace251("Estorno Lib - erro FilLib")
						lRet := .F.
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³REALIZA A INTEGRACAO COM OPERADORAS DE FROTA³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				//*Se o contrato estiver liberado, significa que o mesm ojá foi pago pela REPOM, sendo assim a exclusão não será permitida. */
				If lRet .And. lTMSOPdg .And. (cAliasQry)->DTY_CODOPE == '01' .And. (cAliasQry)->DTY_TIPCTC <> '5' .And. (cAliasQry)->DTY_STATUS <> 'B'
					Trace251("Estorno Lib - Vld Repom")
					DTR->(DbSetOrder(1))
					If DTR->(MsSeek(xFilial('DTR') + (cAliasQry)->(DTY_FILORI+DTY_VIAGEM)))
						If !lRestRepom
							Trace251("Estorno Lib - Repom não permite status")
							Aviso(STR0008,STR0038 + DTR->DTR_PRCTRA,{"OK"}) //-- "A liberação do contrato não pode ser efetuada, já que o contrato foi pago pela Operadora. Nº Contrato Operadora: "
							lRet := .F.
						Else
							lRet:= TM15ChkPag(DTR->DTR_FILORI,DTR->DTR_VIAGEM,5)  //Valida o estorno do Contrato na REPOM
							If lRet
								lRet:= RepCanPgto(DTR->DTR_FILORI,DTR->DTR_VIAGEM)  //Cancelamento da Autorização de Pagamento
							Else
	                            Aviso(STR0008,STR0038 + DTR->DTR_PRCTRA,{"OK"})
                            EndIf
						EndIf
					EndIf
				ElseIf lRet .And. lTMSOPdg .And. (cAliasQry)->DTY_CODOPE == '02'
					Trace251("Estorno Lib - Vld Pamcard")
					DTR->(DbSetOrder(1))
					DTR->(MsSeek(xFilial('DTR') + (cAliasQry)->(DTY_FILORI+DTY_VIAGEM)))
					aRetCNPJ   := PamCNPJEmp((cAliasQry)->(DTY_CODOPE), (cAliasQry)->(DTY_FILORI)) //Função para obter CNPJ da contrante e filial de origem
					cIdParcela := PamRetIDPa(cPrefixo, cTipCTC, (cAliasQry)->(DTY_FILORI), (cAliasQry)->(DTY_NUMCTC))
					//Consulta parcela para saber se ja foi efetivada
					nRetParc := PamConParc((cAliasQry)->(DTY_FILORI), (cAliasQry)->(DTY_VIAGEM), aRetCNPJ, cIdParcela ) //Chama a rotina que consulta a parcela de Saldo Final.
					If nRetParc == 5 //Parcela Efetivada
						Trace251("Estorno Lib - Pamcard Parc Efetivada")
						Help('',1,'TMSPAM014',,,3,0) //"Parcela ja efetivada no sistema", " Pamcard, estorno da liberação","do contrato não permitida."
						lRet:= .F.
					ElseIf nRetParc == 0
						lRet := .F.
					EndIf
				EndIf


				//| A baixa e tratada de acordo com o retorno da integração na rotina TMSA250VerBai quando o parametro MV_TMSERP == "1".
				Trace251("Estorno Lib - Continua " + AllToChar(lRet))
				If lRet
                    // Se integração cTMSERP == "1" o Estorno deve ser liberado pelo controle da Integração .
					Trace251("Estorno Lib - Chamando TMSA250VerBai " + AllToChar(cTMSERP))
					lRet     := TMSA250VerBai(	cPrefixo, (cAliasQry)->DTY_NUMCTC, (cAliasQry)->DTY_CODFOR, (cAliasQry)->DTY_LOJFOR)
					Trace251("Estorno Lib - voltando TMSA250VerBai " + AllToChar(lRet) + AllToChar(InTransact()))
					If !lRet
						AAdd( aMsgErr, { STR0017 +cPrefixo+"/"+(cAliasQry)->DTY_NUMCTC, '01', "FINA080()" } ) //"Titulo Baixado. No. do  Titulo : "

					ElseIf lSeqBx .And. cTMSERP == "0"
						DYI->(dbSetOrder(1))
						If DYI->(dbSeek(cSeekDYI:= xFilial('DYI')+(cAliasQry)->(DTY_FILORI+DTY_NUMCTC)))
							While DYI->(!Eof()) .And.  DYI->(DYI_FILIAL+DYI_FILORI+DYI_NUMCTC) == cSeekDYI
								Aadd( aRetorno[1], DYI->DYI_SEQBX )
								DYI->(dbSkip())
							EndDo
						EndIf
						If (cAliasQry)->DTY_FILDEB <> cFilAnt
							cPrefTit := TMA250GerPrf((cAliasQry)->(DTY_FILDEB))
						Else
							cPrefTit := cPrefixo
						EndIf
						Trace251("Estorno Lib - Continua " + VarInfo("aRetorno",aRetorno))
						SE2->(dbSetOrder(6)) //--E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
						If SE2->(dbSeek(xFilial('SE2')+(cAliasQry)->(DTY_CODFOR+DTY_LOJFOR)+cPrefTit+(cAliasQry)->(DTY_NUMCTC)))
							MaIntBxCP(2,{SE2->(Recno())},{0,0,0},Nil,Nil,Nil,Nil, aRetorno)
							Trace251("Estorno Lib - Voltou MaIntBxCP" )
						EndIf
					EndIf

			     EndIf


				Begin Transaction
				  	Trace251("Begin Transaction 2"+AllToChar(lRet))
					If lRet
					  	Trace251("Estorno Lib - Chamando TMA250DelTit "+AllToChar(lRet) + AllToChar(Intransact()))
						lRet := TMA250DelTit(cPrefixo, (cAliasQry)->DTY_NUMCTC,,(cAliasQry)->DTY_CODFOR, (cAliasQry)->DTY_LOJFOR, (cAliasQry)->DTY_CODFAV, (cAliasQry)->DTY_LOJFAV, '', 2)
					  	Trace251("Estorno Lib - Voltando TMA250DelTit "+AllToChar(lRet) + AllToChar(Intransact()))
		    			If lRet
							//-- Verifica a Filial de Debito
							 cFilDeb := (cAliasQry)->DTY_FILDEB
							//-- Deletar Contas a Pagar da Filial de Debito
							If cFilDeb <> cFilAnt
								cFilOld  := cFilAnt
								cPrefDeb := TMA250GerPrf(cFilDeb)
								cFilAnt  := cFilDeb
							  	Trace251("Estorno Lib - Chamando TMA250DelTit FilDeb dif "+cFilOld + "/"+cFilDeb+ "/"+AllToChar(lRet) + AllToChar(Intransact()))
								lRet     := TMA250DelTit(cPrefDeb, (cAliasQry)->DTY_NUMCTC, cFilDeb, (cAliasQry)->DTY_CODFOR, (cAliasQry)->DTY_LOJFOR, (cAliasQry)->DTY_CODFAV, (cAliasQry)->DTY_LOJFAV, '', 2)
					  			Trace251("Estorno Lib - Voltando TMA250DelTit  FilDeb dif "+AllToChar(lRet) + AllToChar(Intransact()))
								cFilAnt  := cFilOld
							EndIf
						EndIf
					EndIf

				  	Trace251("Estorno Lib - continua "+AllToChar(lRet)+ AllToChar(Intransact()))
					If lRet
						cNumContr := (cAliasQry)->DTY_NUMCTC
                        // Apos estornar a SE2, altera o status de todos os contrato no periodo.
						While lRet .And. !(cAliasQry)->(EoF()) .And. cNumContr = (cAliasQry)->DTY_NUMCTC

							DTY->(DbGoTo( (cAliasQry)->RECDTY ))
							RecLock('DTY',.F.)
							DTY->DTY_STATUS := '2' //-- Aguardando Liberacao para Pagamento
							DTY->DTY_DATLIB := CtoD(Space(08))
							DTY->DTY_IRRF   := 0
							DTY->DTY_INSS   := 0
							DTY->DTY_OK := Iif(IsMark("DTY_OK", cMarca), Space(Len(DTY->DTY_OK)), cMarca)
							If lFilLib
								DTY->DTY_FILLIB := ""
							EndIf
							DTY->DTY_FILDEB := ""
							MsUnLock()

							Trace251("Estorno Lib - Operadora "+(cAliasQry)->DTY_CODOPE+ "/"+AllToChar(lRet)+ AllToChar(Intransact()))
							If lRet .And. lTMSOPdg .And. (cAliasQry)->DTY_CODOPE == '02'
								Trace251("Chamando PamEstPaCt "+AllToChar(InTransact()) )
								lRet := PamEstPaCt((cAliasQry)->DTY_FILORI, (cAliasQry)->DTY_VIAGEM, aRetCNPJ,(cAliasQry)->DTY_NUMCTC,cIdParcela) //Modifica o status da parcela de liberada para Excluída
								Trace251("Voltando PamEstPaCt lRet/Intran: "+AllToChar(lRet) + "/" + AllToChar(InTransact()) )
							EndIf

							If lRet 
								Trace251("Estorno Lib - DTY_STATUS => 2 - "+AllToChar((cAliasQry)->DTY_NUMCTC)+ AllToChar(Intransact()))
								If lTabDFI .And. cTipUso == "2" //--OMS com Frete Embarcador
									SDG->(dbSetOrder(8))
									cSeekSDG  := xFilial("SDG")+cTipUso+(cAliasQry)->DTY_IDENT+(cAliasQry)->DTY_CODVEI
									bWhileSDG := {|| SDG->(!Eof()) .And. SDG->(DG_FILIAL+DG_TIPUSO+DG_IDENT+DG_CODVEI) == cSeekSDG }
								ElseIf cTipUso == "1" //--TMS
									SDG->(dbSetOrder(5))
									cSeekSDG  := xFilial("SDG")+(cAliasQry)->DTY_FILORI+(cAliasQry)->DTY_VIAGEM+(cAliasQry)->DTY_CODVEI
									bWhileSDG := {|| SDG->(!Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM+DG_CODVEI) == cSeekSDG }
								EndIf

								SDG->(dbSeek(cSeekSDG))
								While Eval(bWhileSDG)
									If Empty(SDG->DG_BANCO) .And. SDG->DG_ORIGEM <> 'DTY'
										If SDG->DG_NUMCTC == (cAliasQry)->DTY_NUMCTC
											Reclock("SDG",.F.)
											SDG->DG_NUMCTC := ""
											SDG->( MsUnlock() )
											Trace251("Estorno Lib - DG_NUMCTC => '' - "+AllToChar(SDG->(Recno()))+ AllToChar(Intransact()))
										EndIf
									EndIf
									//Estorna Baixa
									If SDG->DG_ORIGEM <> 'DTR'
										Trace251("Estorno Lib - Chamando TMSA070Bx "+AllToChar(SDG->DG_NUMSEQ)+ AllToChar(Intransact()))
										TMSA070Bx("2",SDG->DG_NUMSEQ)
										Trace251("Estorno Lib - Voltando TMSA070Bx "+AllToChar(SDG->DG_NUMSEQ)+ AllToChar(Intransact()))
									EndIf
									SDG->(dbSkip())
								EndDo

								//--Apaga registros da tabela de Acerto Finaceiro do Contrato
								If AliasIndic('DYI')
									Trace251("Estorno Lib - Chamando A250SeqBx "+ AllToChar(Intransact()))
									A250SeqBx(,,(cAliasQry)->DTY_FILORI,(cAliasQry)->DTY_VIAGEM,2)
									Trace251("Estorno Lib - Voltando A250SeqBx "+ AllToChar(Intransact()))
								EndIf

								Trace251("Estorno Lib - Operadora "+(cAliasQry)->DTY_CODOPE+ "/"+AllToChar(lRet)+ AllToChar(Intransact()))
								If (cAliasQry)->DTY_CODOPE == '01' .And. (cAliasQry)->DTY_STATUS == "B"
									DTY->(DbGoTo( (cAliasQry)->RECDTY ))
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³REALIZA A INTEGRACAO COM OPERADORAS DE FROTA³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									Trace251("Chamando A250ExcRpm "+AllToChar(InTransact()) )
									lRet := A250ExcRpm(aMsgErr, .T.)
									Trace251("Voltando A250ExcRpm lRet/Intran: "+AllToChar(lRet) + "/" + AllToChar(InTransact()) )
								EndIf
							EndIf

							If lTM251Est .And. lRet
 								AAdd( aContratos, { (cAliasQry)->DTY_FILORI, (cAliasQry)->DTY_VIAGEM, (cAliasQry)->DTY_NUMCTC } )
							EndIf
							(cAliasQry)->(DbSkip())
						EndDo
					EndIf
					If !lRet
	  				  	Trace251("Disarm Transaction 3 " + AllToChar(Intransact()))
						DisarmTransaction()
						Break
					EndIf
 				  	Trace251("end Transaction 2 " + AllToChar(Intransact()))
				End Transaction
			  	Trace251("Depois do end Transaction 2  " )

			EndIf
		  	Trace251("Qry Skip 2 " )
			(cAliasQry)->(DbSkip())
		EndDo

		//-- Ponto de Entrada apos o Estorno da liberacao do contrato:
		If lTM251Est .And. lRet
			ExecBlock('TM251Est',.F.,.F.,{ aContratos })
		EndIf

	ElseIf cOpcao == '5' //-- Pagto Saldo Lotes
		While !(cAliasQry)->(EoF()) 
			DTY->(DbGoTo((cAliasQry)->RECDTY))
			//-- "enganar" help's do  250SLD
			lMsErroAuto     := .F.	
			lAutoErrNoFile  := .T.	
			lMsHelpAuto     := .T.
			MSExecAuto({|cAlias, nRecno, nOpc| Tmsa250SLD(cAlias, nRecno, nOpc) }, "DTY",DTY->(Recno()),4)
			If lMsErroAuto
				//-- Todo: Get do erro Getautogrlog
				cErro 	:= "Contrato " +DTY->DTY_NUMCTC + ": "
				//-- Le os dados do erro e guarda no vetor
				aErroSLD 	:= GetAutoGRLog()   
				//-- Remove caracteres "ENTER" e espaços da String
				aEval(aErroSLD,{|x,y|   aErroSLD[y] := StrTran(aErroSLD[y],Chr(13),""), ;
										aErroSLD[y] := StrTran(aErroSLD[y],Chr(10),""), ;
										aErroSLD[y] := StrTran(aErroSLD[y],"  "," ")     })
				aEval(aErroSLD, { |x| cErro += AllTrim(x) + " " } )
				AAdd( aMsgErr, { cErro, '03', "" } )
			EndIf

			(cAliasQry)->(DbSkip())
		EndDo

	EndIf
Else
	Help('',1,'TMSA25101') // 'Nenhum item foi Selecionado.'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TRATAMENTO DOS ERROS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Trace251("251Prc FINAL " + VarInfo("aMsgErr",aMsgErr))
If !Empty(aMsgErr) .And. !lWs
	AaddMsgErr( aMsgErr, @aVisErr)
	TmsMsgErr( aVisErr )
EndIf

(cAliasQry)->(DbCloseArea())
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcoes   ³TMSA251Mrk ³ Autor ³Vitor Raspa          ³ Data ³ 07.Jul.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa a Marcacao dos Contratos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSA251                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA251Mrk( cMarkAll )

Default cMarkAll	:= "2"//-- 1=Todos;2=Individual

Processa({|| TMSA251Mark( cMarkAll )},STR0001,STR0014,.F.) //"Liberacao de Contrato de Carreteiro"###"Processando a marcacao dos Contratos..."

Return

Static Function TMSA251Mark(cMarkAll)
Local aAreaDTY 	:= DTY->(GetArea())
Local cNumCTC  	:= ''
Local cMarca   	:= oMarkBrw:Mark()//ThisMark()
Local nRecno	:= 0
Local aAreaAux, cFilOri, cViagem

Default cMarkAll	:= "2" //-- 1=Todos;2=Individual

If cMarkAll == "2"

	cNumCTC := DTY->DTY_NUMCTC
	DTY->(DbSetOrder(1)) //-- DTY_FILIAL+DTY_NUMCTC
	DTY->(MsSeek(xFilial('DTY') + cNumCTC))
	While DTY->(!Eof()) .And. DTY->(DTY_FILIAL+DTY_NUMCTC) == xFilial('DTY') + cNumCTC
		//-- Quando Repom, força a marca em contratos complementares
		If DTY->DTY_CODOPE == "01"

			aAreaAux := DTY->(GetArea())

			cFilOri  := DTY->DTY_FILORI
			cViagem  := DTY->DTY_VIAGEM
			DTY->(DbSetOrder(2)) //-- DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC
			DTY->(MsSeek( xFilial('DTY') + cFilOri + cViagem ))
			While DTY->(!Eof()) .And. DTY->(DTY_FILIAL+DTY_FILORI+DTY_VIAGEM) == xFilial('DTY') + cFilOri + cViagem
				RecLock('DTY',.F.)
				DTY->DTY_OK := Iif(IsMark("DTY_OK", cMarca), Space(Len(DTY->DTY_OK)), cMarca)
				MsUnLock()

				DTY->(DbSkip())
			EndDo

			RestArea(aAreaAux)
		Else
			RecLock('DTY',.F.)
			DTY->DTY_OK := Iif(IsMark("DTY_OK", cMarca), Space(Len(DTY->DTY_OK)), cMarca)
			MsUnLock()
		EndIF
		DTY->(DbSkip())
	EndDo
Else
	DbSelectArea("DTY")
	ProcRegua(Reccount())
	nRecno	:=	Recno()
	DbGoTop()

	While !EOF()
		RecLock('DTY',.F.)
		DTY->DTY_OK := Iif(IsMark("DTY_OK", cMarca), Space(Len(DTY->DTY_OK)), cMarca)
		MsUnLock()
		DbSelectArea("DTY")
		DbSkip()
	Enddo
	MsGoTo(nRecno)

EndIf

RestArea(aAreaDTY)
oMarkBrw:Refresh(.F.)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA251Oper³ Autor ³ Vitor Raspa           ³ Data ³ 15.Nov.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a Quitacao do Contrato junto a Operadora de Frota   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lRet := TMA310Oper(cExpC1, cExpC2, cExpC3, @aExpA1 )        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExpC1 - Codigo da Operadora de Frotas                      ³±±
±±³          ³cExpC2 - Filial de Origem                                   ³±±
±±³          ³cExpC3 - Numero da Viagem                                   ³±±
±±³          ³aExpA1 - Array com as Mensagens de Erro (Por Referencia)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico - .T. indica sucesso no processamento do metodo      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMA251Oper( cCodOpe, cFilOri, cViagem, aMsgErr, aDadosQuit, cContrat, cCodVei, lQuitacao, nValFre)
Local lRet     := .T.
Local cXML     := ''
If cCodOpe == "01"
	//-- Bloco de código movido para TMSRepom.prw
	lRet := RepQuitMet( @cCodOpe, @cFilOri, @cViagem, @aMsgErr, @aDadosQuit, @cContrat, @cCodVei, @lQuitacao, @nValFre)
EndIf

Return( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA251Aut ³ Autor ³ Guilherme Gaiofatto   ³ Data ³ 16.01.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Realiza a Autorizacao do pagamento na a Operadora de Frota  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExpC1 - Codigo da Operadora de Frotas                      ³±±
±±³          ³cExpC2 - Filial de Origem                                   ³±±
±±³          ³cExpC3 - Numero da Viagem                                   ³±±
±±³          ³aExpA1 - Array com as Mensagens de Erro (Por Referencia)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico - .T. indica sucesso no processamento do metodo      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMA251Aut( cCodOpe, cFilOri, cViagem, aMsgErr, aDadosQuit, cContrat, cCodVei, lQuitacao, cCond, cCodFor, cLojFor )
Local lRet     := .F.
Local cXML     := ''
Local aArea    := GetArea()
Local aAreaDTR := DTR->(GetArea())
Local aAreaDTY := {}
Local oXML     := NIL
Local nValFret := ''
Local cLocQui  := ''
Local aAreaDg  := SDG->( GetArea() )
Local nAux     := 0
Local nPeso	   := 0
//-- Configura o tamanho do nome das Variaveis
SetVarNameLen( 255 )

Default lQuitacao := .T.
Default cCond    := ''
Default cCodFor  := ''
Default cLojFor  := ''
Default cCodVei  := ''

// tento localizar na DTY se nao passar os dados via parametro
IF Empty( cCond )
	IF ( Empty( cCodFor ) .And. Empty( cLojFor ) )
		aAreaDTY := DTY->( getArea() )
		DTY->(DbSetOrder(2))
		If DTY->(DbSeek(xFilial('DTY') + cFilOri + cViagem))
			nPeso    := DTY->DTY_PESO
			nValFret := DTY->DTY_VALFRE
			cCodFor  := DTY->DTY_CODFOR
			cLojFor  := DTY->DTY_LOJFOR
			cLocQui  := DTY->DTY_LOCQUI
			If  Empty(cCodVei)
   				cCodVei := DTY->DTY_CODVEI
   	  		Endif
		EndIf
		RestArea( aAreaDTY )
	Endif

	// Localiza a a condicao de pagto do Fornecedor
	If !Empty(cCodFor) .And.!Empty(cLojFor)
		SA2->(DbSetOrder(1))
		If SA2->(MsSeek(xFilial('SA2')+cCodFor+cLojFor))
			cCond	:= SA2->A2_COND
		EndIf
	EndIf
EndIf

If !Empty(cCodFor) .And.!Empty(cLojFor)
	SA2->(DbSetOrder(1))
	If SA2->(MsSeek(xFilial('SA2')+cCodFor+cLojFor))
	     cCond	:= SA2->A2_COND
	EndIf
EndIf

DEG->(DbSetOrder(1))
If DEG->(MsSeek(xFilial('DEG')+cCodOpe))
	If cCodOpe == '01' //-- REPOM Tecnologia
		//-- Bloco de código movido para TMSRepom.prw
		nAux := 0
		Do While !lRet .And. ++nAux < 5
			lRet := RepAutPgto( @cCodOpe, @cFilOri, @cViagem, @aMsgErr, @aDadosQuit, @cContrat, @cCodVei, @lQuitacao, @cCond, @cCodFor, @cLojFor )
			Sleep(2000)
		EndDo
	ElseIf cCodOpe == '02'
		aRetCNPJ   := PamCNPJEmp(cCodOpe, cFilOri) //Função para obter CNPJ da contrante e filial de origem
		//--Gera Parcela Liberada na PAMCARD!
		lRet:= PamLibPaCt(cFilOri, cViagem, aRetCNPJ, cContrat)

		If lRet .And. lTM251Ope
			ExecBlock('TM251Ope',.F.,.F.,{cCodOpe, cFilOri, cViagem, cContrat, cCodVei, oXML, lQuitacao})
		EndIf
	EndIf
EndIf
//-- Configura o tamanho do nome das Variaveis
SetVarNameLen( 10 )

RestArea(aArea)
RestArea(aAreaDTR)
RestArea(aAreaDg)
Return( lRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Rodolfo K. Rosseto    ³ Data ³04/04/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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

Static Function MenuDef(nOpc)
Default nOpc := 3

If nOpc == 3
	aRotina  := {	{ STR0005 ,"AxPesqui"     , 0 , 1,0,.F.},;	//"Pesquisar"
					{ STR0006 ,"VIEWDEF.TMSA250" , 0 , 2,0,.T.},;	//"Visualizar"
					{ STR0007 ,"TMSA251Lib()" , 0 , 3,0,.T.},;	//"Liberar"
					{ STR0008 ,"TMSA251Est()" , 0 , 4,0,.T.},;	//"Estornar Lib."
					{ STR0009 ,"TMSA250Leg()" , 0 , 5,0,.F.}}	//"Legenda"
Else
	aRotina  := {	{ STR0005 ,"AxPesqui"     , 0 , 1,0,.F.},;	//"Pesquisar"
					{ STR0006 ,"VIEWDEF.TMSA250" , 0 , 2,0,.T.},;	//"Visualizar"
					{ STR0054 ,"TMSA251Pg()" , 0 , 3,0,.T.},;	//"Pagar Saldos"
					{ STR0009 ,"TMSA250Leg()" , 0 , 5,0,.F.}}	//"Legenda"
EndIf

If ExistBlock("TMA251MNU")
	ExecBlock("TMA251MNU",.F.,.F.)
EndIf

Return(aRotina)

/*/{Protheus.doc} TMSA251Vld()

Validar a Marcação do Registro

@author Katia

@since 19/06/2018
@version 1.0
/*/

Static Function TMSA251Vld(nOpc)
Local lRet      := .T.
Local cIdOpe    := ""
Local aRetCNPJ  := {}
Local aArea     := {}
Local aConsCard := {}
Local cStatus   := ""

If nOpc == 3 .And. FindFunction('TMSIDPAM') .And. DTY->DTY_CODOPE == '02' //PAMCARD
	aArea:= GetArea()
	//--- Retorna o Cartao do Motorista
	cIdOpe    := TMSIDPAM(DTY->DTY_FILORI, DTY->DTY_VIAGEM, '2' ) //2-Tipo Parcela do Pagamento da Viagem (DLD)

	// Se cartao Cancelado --> Validar a parcela na Pamcardy: Parcela Efetivada --> Libera pagamento, sem liberar o pagto na Pamcardy.
	// Se Cartao <> Cancelado --> Libera processo normal inclusive liberar pagto na Pamcardy.
	//--Consulta para saber se o Status do cartão está bloqueado..
	aRetCNPJ   := PamCNPJEmp(DTY->DTY_CODOPE, DTY->DTY_FILORI) //Função para obter CNPJ da contrante e filial de origem
	If !Empty(cIdOpe)
		AAdd(aConsCard,{'viagem.contratante.documento.numero',aRetCNPJ[1]})
		AAdd(aConsCard,{'viagem.unidade.documento.tipo'      ,aRetCNPJ[2]})
		AAdd(aConsCard,{'viagem.unidade.documento.numero'    ,aRetCNPJ[3]})
		AAdd(aConsCard,{'viagem.cartao.numero'               ,AllTrim(cIdOpe) })

		lRet := PamFindCar(aConsCard, .T., ,@cStatus)
	EndIf

	If lRet .And. !Empty(cStatus) //Verifica o retorno do status do cartão
		lRet:= TMSIDPAMST(aRetCNPJ,DTY->DTY_FILORI,DTY->DTY_VIAGEM,cIdOpe,aConsCard,cStatus)
	EndIf

	aSize(aRetCNPJ, 0)
	RestArea(aArea)
EndIf

Return lRet

/*/{Protheus.doc} AfterMark()
Bloco a ser executado após a marcação dos registros

@author Caio Murakami

@since 16/01/2019
@version 1.0
/*/
Static Function AfterMark()
Local cMarca   	:= oMarkBrw:Mark()//ThisMark()
Local nRecno	:= 0 
Local aAreaDTY	:= DTY->(GetArea())
Local cNumCTC	:= DTY->DTY_NUMCTC
Local cViagem	:= DTY->DTY_VIAGEM

DbSelectArea("DTY")
ProcRegua(Reccount())
nRecno	:=	Recno()
DbGoTop()

While !EOF()
	
	If DTY->DTY_NUMCTC == cNumCTC .And. DTY->DTY_VIAGEM <> cViagem
		RecLock('DTY',.F.)
		DTY->DTY_OK := Iif(IsMark("DTY_OK", cMarca), Space(Len(DTY->DTY_OK)), cMarca)
		MsUnLock()
		DbSelectArea("DTY")
	EndIf

	DbSkip()
Enddo

MsGoTo(nRecno)

RestArea(aAreaDTY)
oMarkBrw:Refresh(.F.)

Return