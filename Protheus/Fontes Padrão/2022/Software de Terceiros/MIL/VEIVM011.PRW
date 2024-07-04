#Include "Protheus.ch"
#include "TopConn.ch"
#include "Veivm011.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVM011 ³ Autor ³ ANDRE                 ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atendimento ao cliente                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVM011
Local oFolder
Local ni
Local lFiltra    := .f.
Local aIndVV9    := {}                                      
Local cCondicao  := ""
local cSalvaAlias:= ""
Local cUsadoVV0  := ""  
Local _cUsa      := ""
Local _cRes      := ""
Private nOpcFora
Private cChave     := Space(30)
Private cTipVei    := Space(30)
Private cCodMar    := Space(3)
Private cGruMod    := Space(30)
Private cModVei    := Space(10)
Private lEmiNfi    := .t.
Private lNegPag    := .t.
Private lLibVei    := .f.
Private lResVei    := .t.
Private lAutFat    := .t.
Private lPedApr    := .t.
Private lAltApr    := .t. // Indica se o Tecnico pode alterar atendimento aprovado 
Private lAltPAp    := .t. // Indica se o Tecnico pode alterar atendimento pre-aprovado 
Private lMinComv   := .f. // Indica se para o Tecnico sera considerado o parametro de minimo comercial (MV_MINCOMV)
Private bFiltraBrw := {|| Nil}
Private aCampos    := {}
Private cCadastro  := OemToAnsi(STR0001)  //Atendimento de venda
Private aRotina    := MenuDef()
Private lMudouNum  := .f.
Private cSitVei    := "0"
Private aNewBot    := { {"FILTRO",{|| FILVEI011() },STR0002}, {"MAQFOTO",{|| FS_FOTO011() },STR0003}, {"ROTEIRO",{|| VEIVC180(cCodMar,cModVei) },STR0340} } //Filtro - Foto  / Progresso de Veiculo
Private cCliFin7   := "" // Cliente Banco quando leasing
Private cLojFin7   := "" // Loja Cliente Banco quando leasing
Private lAprovacao := .f. // vale .t. quando se entra na Opcao APROVAR do MenuDef
Private aCoresUsr := {}
Private nRecAnt   := 0

Private lGeraNF    := Subs(GetMv("MV_CRNFVEI"),3,1) == "S" // Indica se cria a NF no Modulo Concessionarias. 1a posicao (Balcao) - 2a (oficina) - 3a (Veic) Ex: SNN - so gera NF para Balcao

cSalvaAlias := Alias() 

DbSelectArea("SX3")
DbSetOrder(1) 

DbSelectArea(cSalvaAlias)
//////////////////////////////////////////////////////////////////////////////////

If FindFunction("FM_NEWBOT")
	FM_NEWBOT("PVM011BTEN","aNewBot") // Ponto de Entrada de Manutencao da aNewBot - Definicao de Novos Botoes na EnchoiceBar
	// Exemplo de PE
	// Local aRet := {}
	//	aadd(aRet,{"FILTRO",{|| U_FS_teste1()},"BOTAO1"})
	//	return(aRet)                            
Endif


&& Valida se a empresa tem autorizacao para utiliza o modulo de oficina.
If !AMIIn(11,14,41)
	Return
EndIf

#IFDEF TOP
	dbSelectArea("VV9")
	set filter to
	dbSelectArea("VV0")
	set filter to
	dbSelectArea("VVA")
	set filter to
	dbSelectArea("VS9")
	set filter to
#ENDIF

FS_VEND011()
dbSelectArea("VV9")
dbSetOrder(1)
//if !(lPedApr .or. lLibVei .or. lAutFat)
if !(lLibVei .or. lAutFat)
	RetIndex()
	dbSetOrder(1)
	cCondicao  := "VV9->VV9_USUARI == '"+__cUserID+"'"
	//cCondicao += " .AND. VV9->VV9_STATUS <> 'E'"
	bFiltraBrw := {|| FilBrowse("VV9",@aIndVV9,@cCondicao) }
	Eval(bFiltraBrw)
	lFiltra := .t.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCores := {{'VV9->VV9_STATUS == "A" .AND. VM011VEIVD()','lbok_ocean'},;
{'VV9->VV9_STATUS == "A"','BR_VERDE'},;
{'VV9->VV9_STATUS == "F"','BR_PRETO'},;
{'VV9->VV9_STATUS == "P"','BR_AMARELO'},;
{'VV9->VV9_STATUS == "R"','BR_LARANJA'},;
{'VV9->VV9_STATUS == "O"','BR_BRANCO'},;
{'VV9->VV9_STATUS == "L"','BR_AZUL'},;
{'VV9->VV9_STATUS == "C"','BR_VERMELHO'}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para inclusão de nova COR da legenda       ³
//³Rafael Goncalves - 30*03*10 - FNC 6754 - A Realera          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ExistBlock("VM011LEG") )			
	aCoresUsr := ExecBlock("VM011LEG",.F.,.F.,{aCores,"C"})
	If ( ValType(aCoresUsr) == "A" )
		aCores := aClone(aCoresUsr)
	EndIf
EndIf
			
mBrowse( 6, 1,22,75,"VV9",,,,,,aCores)

dbSelectArea("VV9")
If lFiltra
	RetIndex("VV9")
	dbClearFilter()
	aEval(aIndVV9,{|x| Ferase(x[1]+OrdBagExt())})
EndIf
Return

Function VM011VEIVD() // Atendimento "A"berto com veiculo ja vendido em outro Atendimento // Andre Luis Almeida - 07/11/08
Local lRet := .f.
DbSelectArea("VVA")
DbSetOrder(1)
DbSeek(VV9->VV9_FILIAL+VV9->VV9_NUMATE)
DbSelectArea("VV1")
DbSetOrder(1)
DbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
If VV1->VV1_SITVEI == "1" // 1-Vendido
	lRet := .t.
EndIf
DbSelectArea("VV9")
Return(lRet)

Static Function FS_LEVFILIAL() // Levantamento das Filiais/Lojas da Empresa Logada
Local nRecSM0 := SM0->(Recno())
Local cCodSM0 := SM0->M0_CODIGO
aFilVV1 := {}
aNomFil := {}
aAdd( aFilVV1 , "" )
aAdd( aNomFil ,{"",""})
DbSelectArea("SM0")
DbSetOrder(1)
DbGoTop()
DbSeek( cCodSM0 )
While !Eof() .and. cCodSM0 == SM0->M0_CODIGO
	if SM0->M0_CODFIL $ FG_FILLIB(1)
		aAdd( aFilVV1 , SM0->M0_CODFIL )
		aAdd( aNomFil ,{ SM0->M0_CODFIL, SM0->M0_FILIAL })
	Endif
	DbSkip()
End
DbGoTo(nRecSM0)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ATEND011     ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa o processo de atendimento                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATEND011( cAlias , nReg , nOpc , cTitJanela )

Local cont
Local cStr1    := ""
Local cStr2    := ""
Local nValor   := 0
Local lInclui  := Inclui
Local bCampo   := { |nCPO| Field(nCPO) }
Local nOpca    := 0
Local nOpcNeg  := 3
Local nOpcUlt  := 3
Local aPriEnc  := {}
Local aSegEnc  := {}
Local aTerEnc  := {}
Local aQuaEnc  := {}
Local aQuiEnc  := {}
Local aSexEnc  := {}
Local aSetEnc  := {}
//Local aTitles  := {OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008),OemToAnsi(STR0009),OemToAnsi(STR0010)}//Selecao - Valores - Acessorios - Campanha - Diversos - Negociacao - Recebimento
Local aTitles  := {OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0296),OemToAnsi(STR0007),OemToAnsi(STR0008),OemToAnsi(STR0009),OemToAnsi(STR0010)}//Selecao - Valores - Acessorios - Campanha - Diversos - Negociacao - Recebimento
Local nCodMar  := 1
Local nGruMod  := 1
Local nTamObs, cAuxObs
Private oDlgAtend
Private oFoto    := LoadBitmap( GetResources(), "MAQFOTO" )
Private oGratis  := LoadBitmap( GetResources(), "bpmstask1" )
Private oChecked := LoadBitmap( GetResources(), "checked" )
Private oNada    := LoadBitmap( GetResources(), "NADA" )
Private oTik     := LoadBitmap( GetResources(), "LBTIK" )
Private oMarcaX  := LoadBitmap( GetResources(), "LBOK" )
Private oNo      := LoadBitmap( GetResources(), "LBNO" )
Private oBranco  := LoadBitmap( GetResources(), "BR_BRANCO" )
Private oVerde   := LoadBitmap( GetResources(), "BR_VERDE" )
Private oAmarelo := LoadBitmap( GetResources(), "BR_AMARELO" )
Private oVermelho:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oAzul    := LoadBitmap( GetResources(), "BR_AZUL" )
Private oLaranja := LoadBitmap( GetResources(), "BR_LARANJA" )
Private oPreto   := LoadBitmap( GetResources(), "BR_PRETO" )
Private cMotivo  := "000001"  //Filtro da consulta do motivo
Private cTipAva  := "1" //Veiculos
Private cCpoDiv  := "    1"
Private aStru    := {}
Private aErrAva  := {}
Private cSimVda  := "V"
Private cMoedCor := cOutMoed := GetMv("MV_SIMB1")
Private cSimOMoe := 1
Private cTipOpe  := 3   //Veiculos
Private cStaRes  := GetNewPar("MV_STATRES","03") //Codigo da tbela de status do veiculo para reservado
Private lExclui  := nOpc == 5
Private lVisual  := nOpc == 2
Private lFatura  := .t.
Private cBlqFat  := ""
Private nTamNota := 9
Private lJaFiltro:= .f.
Private lJaPer011:= !Inclui
Private lJaGravou:= !Inclui
Private lJaCal011:= !Inclui
Private lFechaDlg:= .f.
Private nValorMin:= 0
Private cNota    := ""
Private cSerie   := ""
Private aAcessor := {}
Private aKits    := {}
Private aCorM    := {}
Private aCorP    := {}
Private aCor     := {}
Private cCorM    := ""
Private cCorP    := ""
Private nValCor  := 0
Private nTipCor  := 0
Private cGruVei  := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Private cPrefNF  := "   "
Private cPrefixo := GetNewPar("MV_PREFVEI","VEI")
Private aIteParc := {}
Private lCalcVEI := .f. // Calcula VALORES quando AVANCAR
Private cFilVV1  := If(!Empty(xFilial("VV1")),xFilial("VV1"),SM0->M0_CODFIL)
Private cFilAntVV1 := xFilial("VV1")
Private cFilSelVV1 := xFilial("VV1")
Private lFiltro  := .f.
Private cChaRes  := ""
Private aFilVV1  := {}
Private lCaixaNF := GetNewPar("MV_CXEMINF","N")  == "S"
Private lMEstAte := If(GetNewPar("MV_MESTATE","1")=="1",.t.,.f.) // Mostra Estoque TOTAL dos Veiculos no Atendimento
Private cTipPag1 := "VV0_FORPAG"
Private oTipPag, oDesPag, oDesBco, oCodBco
Private cCondic1 := ctod(" ")
Private cCondic2 := space(02)
Private cCondic3 := space(02)
Private cCondic4 := space(02)
Private cCondic5 := "1"
Private lTroco   := .f.
Private aTipVei  := {}
Private aMarca   := {}
Private aGener   := {}
Private aEspec   := {}
Private cCombus  := ""
Private cTipCor  := ""
Private cGruCor  := Space(02)
Private cCor     := Space(30)
Private cOpcVei  := Space(100)
Private nAnoIni  := 0
Private nAnoFin  := 0
Private nValFxI  := 0
Private nValFxF  := 0
Private nKMFxa   := 0
Private cEstVeiF := ""
Private lSelect  := .f.
Private nAcessor := 0
Private nAceTer  := 0
Private nKits    := 0
Private nImpost  := 0
Private cTipTit  := Space(2)
Private nTitDif  := 0
Private nTotalEnt:= 0
Private nTotalNF := 0
Private nTotEntr := 0
Private aHeaderC := {}
Private aColsC   := {}
Private aHeaderIC:= {}
Private aColsIC  := {}
Private aHeaderTC:= {}
Private aColsTC  := {}
Private aHeaderAG:= {}
Private aColsAG  := {}
Private aGravaEnt:= {}
Private cLinOk   := "AllwaysTrue()"
Private cTudoOk  := "AllwaysTrue()"
Private cFieldOk := "FG_DADOSENT(M->VV0_VALTOT,3,if(ReadVar()=='M->VS9_REFPAG',.f.,.t.),n),FS_CALC011()"
Private lCkFilEst  := .t.
Private lCkFilVir  := .f.
Private lCkFilTra  := .f.
Private lCkFilRes  := .f.
Private lCkFilRem  := .f.
Private lCkFilCon  := .f.
Private lCkFilAti  := .f.
Private lPriVez    := .t. // Trazer mais rapido o filtro para 1a.vez
Private lPriVezVZ7 := .t. // Na FS_ITECAM nao deve chamar tela de F&I na primeira chamada
Private lPriGravacao := .f. // 1a. Gravacao
Private lValChassi := .t. // Valida Chassi (qdo campo for obrigatorio)
Private nAcresFin  := 0
Private aNomFil    := {} // Nome das Filiais
DbSelectArea("SX6")
DbSetOrder(1)
If !DbSeek(xFilial("SX6")+"MV_CRNFVEI")
	RecLock("SX6",.t.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "MV_CRNFVEI"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Indica se cria a NF no Modulo Concessionarias. "
		SX6->X6_DSCSPA  := SX6->X6_DESCRIC
		SX6->X6_DSCENG  := SX6->X6_DESCRIC
		SX6->X6_DESC1   := "1a posicao (Balcao) - 2a (oficina) - 3a (Veic)"
		SX6->X6_DSCSPA1 := SX6->X6_DESC1
		SX6->X6_DSCENG1 := SX6->X6_DESC1
		SX6->X6_DESC2   := "Ex: SNN - so gera NF para Balcao"
		SX6->X6_DSCSPA2 := SX6->X6_DESC2
		SX6->X6_DSCENG2 := SX6->X6_DESC2
		SX6->X6_CONTEUD := "SSS"
		SX6->X6_CONTSPA := SX6->X6_CONTEUD
		SX6->X6_CONTENG := SX6->X6_CONTEUD
		SX6->X6_PROPRI  := "S"
		SX6->X6_PYME    := "S"
	MsUnLock()
EndIf	
If Type("_lVerBotoes") == "U"
	Private _lVerBotoes:= .t. // Mostrar todas OPCOES no BOTAO de OPCOES (.f. qdo chamado por outro fonte p/consultar o atendimento)
EndIf

Private aStruVV1 := {}
// 1o Elemento - .f. / .t. (indica se o veiculo esta sendo selecionada)
// 2o Elemento - Qual a situacao -(A - Ativo Imobilizado / T - Transito / R - Remessa / C - Consignado)
// 3o Elemento -Nome do Arquivo de Imagem do Veiculos - VV1->VV1_BITMAP
// 4o Elemento - Dias no Estoque
// 5o Elemento - Chassi - VV1->VV1_CHASSI
// 6o Elemento - Modelo - VV2->VV2_DESMOD
// 7o Elemento - Marca  - VV1->VV1_CODMAR
// 8o Elemento - Cor 
// 9o Elemento - Valor de Venda
//10o Elemento - Estado do Veiculo (Novo ou Usado)
//11o Elemento - Ano de Fabricacao - Subs(VV1->VV1_FABMOD,1,4)
//12o Elemento - Modelo Fabricacao - Subs(VV1->VV1_FABMOD,5,4)
//13o Elemento - Kilometragem do Veiculo - VV1->VV1_KILVEI
//14o Elemento - Filial onde esta o Veiculo - cFilAtu
//15o Elemento - If(!Empty(VV1->VV1_FILIAL),VV1->VV1_FILIAL,VV1->VV1_FILENT), } ) //"Novo - Usado"
//16o Elemento - Placa do Veiculo - VV1->VV1_PLAVEI
//17o Elemento - Data Emissao Fabrica - VVF_DATEMI 
//18o Elemento - Indice de Calculo - VVG_CODIND    
//19o Elemento - Carencia de Indice de Calculo - VVH_DIACAR
//20o Elemento - Transacao de Compra - VV1_TRACPA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rubens - 19/11/2009                                                                          ³
//³Implementacao de Log de Alteração, o mesmo sera gravado no campo de observacao do Atendimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aVS9LogAlter := {} , aLogAlter := {}, lLogAlter := (GetNewPar("MV_LOGALTV","N") == "S")
Private aObsGravada := {} // Utilizada para verificar se o usuario alterou a observacao gerada automaticamente pelo sistema
Default cTitJanela := ""

cCodMar := space(3)
cModVei := space(30)
cGruMod := space(30)
cChave  := Space(30)

nOpcFora := nOpc
//// Trata variaveis Private quando ATEND011 chamado por outros programas ////
If Type("lPedApr") == "U"
	lPedApr  := .t.
EndIf
If Type("lAltApr") == "U"
	lAltApr  := .t. // Indica se o Tecnico pode alterar atendimento aprovado 
EndIf
If Type("lAltPAp") == "U"
	lAltPAp  := .t. // Indica se o Tecnico pode alterar atendimento pre-aprovado
EndIf
If Type("lMinComv") == "U"
	lMinComv := .f. // Indica se para o Tecnico sera considerado o parametro de minimo comercial (MV_MINCOMV)
EndIf
If Type("lGeraNF") == "U"
	lGeraNF  := Subs(GetMv("MV_CRNFVEI"),3,1) == "S" // Indica se cria a NF no Modulo Concessionarias. 1a posicao (Balcao) - 2a (oficina) - 3a (Veic) Ex: SNN - so gera NF para Balcao
EndIf
//////////////////////////////////////////////////////////////////////////////

AADD(aLogAlter,{"VV0->VV0_VALMOV",,,})
AADD(aLogAlter,{"VV0->VV0_FORPAG",,,"AllTrim(Posicione('SE4',1,xFilial('SE4')+VV0->VV0_FORPAG,'E4_DESCRI'))"})
AADD(aLogAlter,{"VVA->VVA_CHASSI",,,})

FS_LEVFILIAL() // Levantamento das Filiais/Lojas da Empresa Logada

dbSelectArea("VV9")
dbSetOrder(1)
If VV9->VV9_STATUS == "E"
	MsgInfo(VV9->VV9_NUMATE+" - "+ STR0011,STR0012) //Atendimento EXCLUIDO! - Atencao
	Return()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro de atendimento ao cliente                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV9")
While x3_arquivo == "VV9" .and. !eof()
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. AllTrim(x3_campo) $ "VV9_NOMVIS/VV9_NUMNFI/VV9_SERNFI/VV9_DATVIS/VV9_TELVIS/VV9_TIPMID/VV9_OBSMEM/VV9_OBSERV/VV9_CODCLI/VV9_LOJA/VV9_PEDFAB"
		AADD(aPriEnc,x3_campo)
	Endif
	wVar := "M->"+x3_campo
	&wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo

if !Inclui

	If nOpc == 4 // Alteracao
		If VV9->VV9_STATUS=="O" .and. !lAltPAp
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Andre Luis Almeida - 02/02/2010                                                             ³
		//³Verifica se o Tecnico tem permissão de alterar atendimentos com status pre-aprovado         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MsgStop(STR0310,STR0265) // Usuário sem permissão de alterar atendimento pré-aprovado!
			Return
		ElseIf VV9->VV9_STATUS=="L" .and. !lAltApr
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Rubens - 19/11/2009                                                                        ³
		//³Verifica se o Tecnico tem permissão de alterar atendimentos com status aprovado            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MsgStop(STR0348,STR0265) // Usuário sem permissão de alterar atendimento aprovado!
			Return
		EndIf
	EndIf

	lLevCam := .f.
	dbSelectArea("VV9")
	For cont := 1 TO FCount()
		M->&(EVAL(bCampo,cont)) := FieldGet(cont)
	Next
	dbSelectarea("VV0")
	dbSetOrder(1)
	dbSeek(xFilial("VV0")+M->VV9_NUMATE)
	dbSelectarea("VVA")
	dbSetOrder(1)
	dbSeek(xFilial("VVA")+M->VV9_NUMATE)
	if VV0->(FieldPos("VV0_FILCHA")) <> 0
		cFilSelVV1 := VV0->VV0_FILCHA
		cFilAntVV1 := VV0->VV0_FILCHA
	Endif
	if !Empty(VVA->VVA_CHASSI)
		dbSelectarea("VV1")
		dbSetOrder(2)
		dbSeek(cFilSelVV1+VVA->VVA_CHASSI)
	Endif
	M->VV0_CHASSI := VVA->VVA_CHASSI
	M->VV0_CHAINT := VVA->VVA_CHAINT
	cCodMar := VV9->VV9_CODMAR
	cModVei := VV9->VV9_MODVEI
	VV2->(DbSetOrder(1))
	VV2->(DbSeek(xFilial("VV2")+VV9->VV9_CODMAR+VV9->VV9_MODVEI))
	VVR->(DbSetOrder(2))
	VVR->(DbSeek(xFilial("VVR")+VV9->VV9_CODMAR+VV2->VV2_GRUMOD))
	VVR->(DbSetOrder(1))
	cGruMod := VVR->VVR_DESCRI
	If Empty(M->VV0_CHASSI)
		FS_FILTROVV(.f.,3)
	EndIf
	If VV0->VV0_OPEMOV == "1" .or. VV0->VV0_OPEMOV == "8" // Nao validar o Chassi do veiculo em 1-Simulacao ou 8-Venda Futura
		lValChassi := .f.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera log de alteração na Observacao do atendimento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lLogAlter
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Rubens - 19/11/2009                                ³
		//³Carrega valores, que serao utilizados na gravacao, ³
		//³para verificar se o usuario alterou os mesmos      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For Cont := 1 to Len(aLogAlter)
			aLogAlter[Cont,2] := &(aLogAlter[Cont,1])
		Next Cont
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Rubens - 26/11/2009                                      ³
		//³Carrega a Obs, para verificar se o usuario alterou a obs.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTamObs := TamSx3("VV9_OBSERV")[1]
		cAuxObs := E_MSMM(VV9->VV9_OBSMEM,nTamObs)
		For Cont := 1 to MLCount(cAuxObs,nTamObs)
			if Left(MemoLine(cAuxObs,nTamObs,Cont),3) $ "___,***"
				AADD(aObsGravada,MemoLine(cAuxObs,nTamObs,Cont))
			endif
		Next Cont
	endif
Else
	If Type("aTelaIncl") <> "U" // Nova tela de Incluir
		If !Empty(aTelaIncl[1,1])
			M->VV9_CODCLI := aTelaIncl[1,1] // Codigo Cliente
			M->VV9_LOJA   := aTelaIncl[1,2] // Loja Cliente
			M->VV9_NOMVIS := aTelaIncl[1,3] // Nome Cliente
			M->VV9_TELVIS := aTelaIncl[1,4] // Fone Cliente
			VISIT011()
		EndIf
	EndIf
	lLevCam := .t.
	lPriGravacao := .t.
	//	M->VV9_NUMATE := GetSXENum("VV9","VV9_NUMATE")
	M->VV9_NUMATE := GetSXENum("VV0","VV0_NUMTRA")
	M->VV0_NUMTRA := M->VV9_NUMATE
Endif

If ExistBlock("CAMPOSVEI1")
	cStr1 := ExecBlock("CAMPOSVEI1",.f.,.f.)
	if Type("cStr1") <> "C"
		cStr1 := ""
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atendimento ao cliente                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV0")
While x3_arquivo == "VV0" .and. !eof()
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. AllTrim(x3_campo) $ cStr1+"VV0_CHASSI/VV0_CODMAR/VV0_DESMAR/VV0_GRUMOD/VV0_DESGRU/VV0_MODVEI/VV0_DESMOD/VV0_CORVEI/VV0_DESCOR/VV0_FABMOD/"+;
		"VV0_PLAVEI/VV0_CODVEN/VV0_NOMVEN/VV0_VALMOV/VV0_ACESSO/VV0_VALCOR/VV0_PERDES/VV0_VALDES/VV0_VALTOT/VV0_FORPAG/VV0_DESFPG/VV0_RESERV/VV0_DATVAL/VV0_HORVAL/VV0_VALTAB/VV0_DEPTO/VV0_NATFIN/VV0_CCUSTO/VV0_CODTES/VV0_CODGRU/VV0_NUMCOT/VV0_TPFRET/VV0_DEPTO"
		AADD(aSegEnc,x3_campo)
	Endif
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. x3_campo $ "VV0_VALMOV/VV0_ACESSO/VV0_VALDES/VV0_VALTOT/VV0_TOTENT/VV0_VALFIN/VV0_VALTRO/VV0_IMPOST"
		AADD(aQuiEnc,x3_campo)
	Endif
	if x3_campo <> "VV0_NUMTRA"
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
//	Else
//		M->VV0_NUMTRA := Space(TamSx3("VV0_  NUMTRA")[1])
	Endif
	dbSkip()
EndDo

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVA")
While x3_arquivo == "VVA" .and. !eof()
	wVar := "M->"+x3_campo
	&wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campanha promocional                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VZ7")
nUsadoIC:=0
While !Eof().And.(x3_arquivo=="VZ7")
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !(Alltrim(x3_campo) $ "VZ7_COMPAG/VZ7_GERORC/VZ7_ORCTRO")
		nUsadoIC:=nUsadoIC+1
		Aadd(aHeaderIC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		wVar  := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	Endif
	dbSkip()
Enddo

aColsIC:={}
aColsIC:={Array(nUsadoIC+1)}
aColsIC[1,nUsadoIC+1]:=.F.
For cont:=1 to nUsadoIC
	aColsIC[1,cont]:=CriaVar(aHeaderIC[cont,2])
Next


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Acessorios de terceiros                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV6")
nUsadoTC:=0
While !Eof().And.(x3_arquivo=="VV6")
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. Alltrim(x3_campo) $ "VV6_CODFOR/VV6_LOJA/VV6_NOMFOR/VV6_VALEQP/VV6_DATINS"
		nUsadoTC:=nUsadoTC+1
		Aadd(aHeaderTC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
	Endif
	wVar  := "M->"+x3_campo
	&wVar := CriaVar(x3_campo)
	dbSkip()
Enddo

aColsTC:={}
aColsTC:={Array(nUsadoTC+1)}
aColsTC[1,nUsadoTC+1]:=.F.
For cont:=1 to nUsadoTC
	aColsTC[1,cont]:=CriaVar(aHeaderTC[cont,2])
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Agregados                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VAT")
nUsadoAG:=0
While !Eof().And.(x3_arquivo=="VAT")
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. Alltrim(x3_campo) $ "VAT_CODNEG/VAT_DESNEG/VAT_VALNEG/VAT_DATNEG/VAT_TIPPAG/"
		nUsadoAG:=nUsadoAG+1
		Aadd(aHeaderAG,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
	Endif
	wVar  := "M->"+x3_campo
	&wVar := CriaVar(x3_campo)
	dbSkip()
Enddo

aColsAG:={}
aColsAG:={Array(nUsadoAG+1)}
aColsAG[1,nUsadoAG+1]:=.F.
For cont:=1 to nUsadoAG
	aColsAG[1,cont]:=CriaVar(aHeaderAG[cont,2])
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Negociacao de pagamento                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV0")
While x3_arquivo == "VV0" .and. !eof()

	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. AllTrim(x3_campo) $ "VV0_FORPAG/VV0_DESFPG/VV0_CODBCO/VV0_CODAGE/VV0_AGEFIN/"+;
		"VV0_DATINI/VV0_DIA1PC/VV0_PARCEL/VV0_INTERV/VV0_FIXDIA/VV0_DIAFIX/VV0_TXAFIN/VV0_COEFIC/VV0_PTXRET/VV0_VTXRET/VV0_PCUSFN/"+;
		"VV0_VCUSFN/VV0_PCOMFN/VV0_VCOMFN/VV0_TIPFIN/VV0_TABFAI/VV0_DESFAI/VV0_VALTAC/VV0_VALPAR"

		if AllTrim(x3_campo) $ "VV0_FORPAG/VV0_DESFPG/VV0_CODBCO/VV0_CODAGE/VV0_AGEFIN/"+;
			"VV0_DATINI/VV0_DIA1PC/VV0_PARCEL/VV0_INTERV/VV0_FIXDIA/VV0_DIAFIX/VV0_TIPFIN/VV0_COEFIC/VV0_TABFAI/VV0_DESFAI/VV0_VALPAR"
			AADD(aTerEnc,x3_campo)
		Endif
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
	Endif

	dbSkip()

EndDo

If ExistBlock("CAMPOSVEI2")
	cStr2 := ExecBlock("CAMPOSVEI2",.f.,.f.)
	if Type("cStr2") <> "C"
		cStr2 := ""
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Outros dados para o atendimento de venda                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cStr3 := ""
If ExistBlock("CAMPOSVEI3")
	cStr3 := ExecBlock("CAMPOSVEI3",.f.,.f.)
	if Type("cStr3") <> "C"
		cStr3 := ""
	Endif
Endif
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVA")
While x3_arquivo == "VVA" .and. !eof()
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. AllTrim(x3_campo) $ cStr3+"VVA_REDCUS/VVA_DATRCU/VVA_BONFAB/VVA_BONREG/VVA_BONCON/VVA_DATBFB/VVA_DESCLI/VVA_REDVDA/VVA_DATDCL/VVA_RECTEC/VVA_DATRTC/VVA_INPICO/"+;
		"VVA_INPCRT/VVA_INPCBF/VVA_INISRT/VVA_INISBF/VVA_VALFRE/VVA_VALREV/VVA_DESVEI/VVA_VALREV/VVA_ASSIMP/VVA_DESFIX/VVA_DSPFIN/VVA_RECVEI"
		AADD(aSetEnc,x3_campo)
	Endif
	wVar := "M->"+x3_campo
	&wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finalizacao da venda                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV0")
While x3_arquivo == "VV0" .and. !eof()
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. x3_campo $ cStr2+"VV0_VBAICM/VV0_ALIICM/VV0_TOTICM/VV0_DESACE/"+;
		"VV0_CODTRA/VV0_CODAVA/VV0_LOJAAV/VV0_NOMAVA/VV0_CBCOAA/VV0_ABCOAA/VV0_NBCOAA/VV0_TIPVEN/VV0_DESTVD/"+;
		"VV0_CATVEN/VV0_BASSOL/VV0_VALSOL/VV0_CLIALI/VV0_LOJALI"   ///VV0_VALMOV/VV0_VALDES/VV0_VALTOT/VV0_ACESSO
		AADD(aQuaEnc,x3_campo)
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

if !Inclui
	dbSelectArea("VV0")
	For cont := 1 TO FCount()
		M->&(EVAL(bCampo,cont)) := FieldGet(cont)
	Next
	dbSelectArea("VVA")
	For cont := 1 TO FCount()
		M->&(EVAL(bCampo,cont)) := FieldGet(cont)
	Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Negociacao de pagamentos da entrada                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsadoC:=0
dbSelectArea("SX3")
dbSeek("VS9")
aHeaderC:={}
While !Eof().And.(x3_arquivo=="VS9")
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_OBSERV#VS9_SEQUEN#VS9_PORTAD#VS9_DESPOR#VS9_TIPTEM#VS9_NATURE#VS9_CARTEI#VS9_SEQTAR")
//	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_OBSERV#VS9_SEQUEN#VS9_PORTAD#VS9_DESPOR#VS9_NATURE#VS9_CARTEI")
		nUsadoC++
		Aadd(aHeaderC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		wVar := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for alteracao traz valores digitados                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M->VV0_VALFIN := 0
if !Inclui
	dbSelectArea("VS9")
	dbSetOrder(1)
	if dbSeek(xFilial("VS9")+left(M->VV0_NUMTRA+space(30),len(VS9->VS9_NUMIDE))+"V")
		While !Eof() .and. VS9->VS9_FILIAL+VS9->VS9_NUMIDE+VS9->VS9_TIPOPE == xFilial("VS9")+left(M->VV0_NUMTRA+space(30),len(VS9->VS9_NUMIDE))+'V'
			If VS9->VS9_TIPPAG == "DP"  //Duplicata
				aAdd(aIteParc, {VS9->VS9_DATPAG,VS9->VS9_VALPAG})
				nValor += VS9->VS9_VALPAG
				if !Empty(VS9->VS9_REFPAG)
					M->VV0_DATINI := cTod(Substr(VS9->VS9_REFPAG,01,08))
					M->VV0_DIA1PC := val(Substr(VS9->VS9_REFPAG,09,02))
					M->VV0_PARCEL := val(Substr(VS9->VS9_REFPAG,11,02))
//					M->VV0_INTERV := val(Substr(VS9->VS9_REFPAG,13,02))
				Endif
			Else
				AADD(aColsC,Array(nUsadoC+1))
				For cont := 1 to nUsadoC
					aColsC[Len(aColsC),cont]:=If(aHeaderC[cont,10] # "V",FieldGet(FieldPos(aHeaderC[cont,2])),CriaVar(aHeaderC[cont,2]))
				Next
				aColsC[Len(aColsC),nUsadoC+1]:=.F.
				nTotEntr := nTotEntr + VS9->VS9_VALPAG
				M->VV0_TOTENT := nTotEntr
				dbSelectArea("VSA")
				dbSetOrder(1)
				if dbSeek(xFilial("VSA")+VS9->VS9_TIPPAG) .and. VSA->(FieldPos("VSA_FINANC")) > 0 .and. VSA->VSA_FINANC == "1"
					M->VV0_VALFIN += VS9->VS9_VALPAG
					nTotEntr := nTotEntr - VS9->VS9_VALPAG
					M->VV0_TOTENT := nTotEntr
				EndIf
				dbSelectArea("VSE")
				dbSetOrder(1)
				if dbSeek(xFilial("VSE")+M->VV0_NUMTRA+"V"+VS9->VS9_TIPPAG+VS9->VS9_SEQUEN)
					while !EOF() .and. &(VSE->(indexKey())) == xfilial("VSE")+M->VV0_NUMTRA+"V"+VS9->VS9_TIPPAG+VS9->VS9_SEQUEN
						aadd(aGravaEnt,{Len(aColsC),VSE->VSE_TIPPAG,VSE->VSE_DESCCP,VSE->VSE_NOMECP,VSE->VSE_TIPOCP,VSE->VSE_TAMACP,VSE->VSE_DECICP,VSE->VSE_PICTCP,VSE->VSE_VALDIG})
						dbSkip()
					Enddo
				Endif
				dbSelectArea("VS9")
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Rubens - 19/11/2009                                 ³
				//³Adiciona na matriz para verificar se houve alteracao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				if lLogAlter
					AADD( aVS9LogAlter , { aColsC[Len(aColsC), FG_POSVAR("VS9_TIPPAG","aHeaderC")],;
												aColsC[Len(aColsC), FG_POSVAR("VS9_VALPAG","aHeaderC")],;
												.f. ,;  	// Indica que houve alteracao (pelo menos por enquanto)
												.f. ,;  	// Indica que é um registro novo 
												.f. ,;  	// Indica se o registro foi excluido 
												0 ;		// Valor Novo 
												} ) 
				endif
				
			Endif
			dbSkip()
		Enddo
		lTroco := (M->VV0_TOTENT+M->VV0_VALFIN) > VV0->VV0_VALTOT
		if lTroco
			M->VV0_VALTRO := M->VV0_TOTENT + M->VV0_VALFIN - VV0->VV0_VALTOT
		Endif
	Endif
	
	if VV0->(FieldPos("VV0_IMPOST")) <> 0
		nImpost := M->VV0_IMPOST
	Endif
	M->VV0_VALRES := (M->VV0_VALTOT - nImpost) - M->VV0_TOTENT - M->VV0_VALFIN
//	M->VV0_VALRES := (M->VV0_VALTOT - nImpost) - M->VV0_TOTENT - nValor - M->VV0_VALFIN
	if M->VV0_VALRES < 0
		M->VV0_VALRES := 0
	Endif
Endif

if Len(aColsC) == 0
	aColsC:={Array(nUsadoC+1)}
	aColsC[1,nUsadoC+1]:=.F.
	For cont:=1 to nUsadoC
		aColsC[1,cont]:=CriaVar(aHeaderC[cont,2])
	Next
Endif

if Len(aIteParc) == 0
	aIteParc := {{cTod(""),0}}
Endif

FS_VEND011()
if !Inclui
	VISIT011()
	M->VV0_CHASSI := VVA->VVA_CHASSI
	M->VV0_CHAINT := VVA->VVA_CHAINT
	M->VV0_FABMOD := VV1->VV1_FABMOD
	M->VV0_PLAVEI := VV1->VV1_PLAVEI
Endif

//Traz o TES padrao para esta operacao de saida (S) normal (N)
dbSelectArea("VZA")
dbSetOrder(1)
if dbSeek(xFilial("VZA")+"SN"+iif( Inclui, "0",VV1->VV1_ESTVEI) )
	if Empty(M->VV0_CODTES)
		M->VV0_CODTES := VZA->VZA_CODTES
	Endif
Endif

Consultar := .f.

cCadastro := OemToAnsi(STR0001) //Atendimento de venda
if !Inclui
	dbSelectarea("VV1")
	dbSetOrder(2)
	dbSeek(cFilSelVV1+M->VV0_CHASSI)
	
	VV2->(dbSetOrder(1))
	VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	
	SB1->(dbSetOrder(7))
	SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
	
	cCadastro := OemToAnsi(STR0001)+"  ["+VV9->VV9_NUMATE+"]"   //Atendimento de venda
	M->VV0_CODTES := VVA->VVA_CODTES
//	M->VV0_SIMULA := iif(VV0->VV0_OPEMOV == "1","1","0")
	M->VV0_ALIICM := if(VV1->VV1_ESTVEI == "0",Val(subs(GetMv("MV_ESTICM"),at(GetMv("MV_ESTADO"),GetMv("MV_ESTICM"))+2,2)),0)
	
	if SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+VV1->VV1_LOCPAD))
		If SB2->B2_QATU > 0
			M->VV0_OPEMOV := "0"
//			M->VV0_SIMULA := "0"
			If VV0->VV0_TIPFAT <> "2"
				M->VV0_TIPFAT := iif(!empty(VV1->VV1_ESTVEI),VV1->VV1_ESTVEI,"0")
			Else
				M->VV0_TIPFAT := VV0->VV0_TIPFAT
			Endif
			M->VV0_MODVDA := M->VV0_TIPFAT
		Endif
	Endif
	If !lExclui
		ACESS011()
		AGREG011()
		CORES011()
		INIFIS011()
		FISCAL011()
	Endif
Else
	cCadastro := OemToAnsi(STR0001)+"  ["+M->VV9_NUMATE+"]"//atendimento de venda
	FS_FILTROVV(.f.)
	lJaFiltro := .t.
Endif
Altera    := .f.
Excluir   := .f.
if !Inclui
	If nOpc == 4 // Alterar
		Altera := .t.
		if M->VV9_STATUS == "F"
			Inclui := .f.
			nOpc   := 2
			nOpcNeg:= 2
			nOpcUlt:= 4
			if lCaixaNF
				MsgInfo(STR0013 ,STR0012) //Atendimento nao pode ser alterado pois ja esta finalizado! - Atencao
			Endif
		Endif
		lPriVezVZ7 := .f. // TESTE RUBENS ERRO VIAMAR LEDITCOL
		FS_LevVZ7() // Levanta Campanha
	ElseIf nOpc == 2 // Consultar
		Consultar := .t.
		lPriVezVZ7 := .f. // TESTE RUBENS ERRO VIAMAR LEDITCOL
		FS_LevVZ7() // Levanta Campanha
	ElseIf nOpc == 5 // Excluir
		Excluir := .t.
		lPriVezVZ7 := .f. // TESTE RUBENS ERRO VIAMAR LEDITCOL
		FS_LevVZ7() // Levanta Campanha
	EndIf
EndIf
FISCAL011()

If nOpc == 7 // Aprovacao do Atendimento
	VM011_Apr(.t.)
   Return
Endif
If oDlgAtend # NIL // Andre Luis Almeida - 07/11/08 - 'MAXIMUM NUMBER OF COMPONENTS'
	DeleteObject( oDlgAtend )
EndIf
DEFINE MSDIALOG oDlgAtend TITLE cCadastro FROM  00,00 To 32,90 OF oMainWnd STYLE DS_MODALFRAME STATUS
	oDlgAtend:lEscClose := .F.

aSvtela  := {{},{},{},{},{},{},{},{}}
aSvGets  := {{},{},{},{},{},{},{},{}}

@ 048,001 FOLDER oFolder011 SIZE 354,182 OF oDlgAtend PROMPTS aTitles[1],aTitles[2],aTitles[3],aTitles[4],aTitles[5],aTitles[6],aTitles[7] PIXEL
FG_INIFOLDER("oFolder011")
oFolder011:bChange    := {||  BOTOES011()  } // Executa na mudanca da aba
oFolder011:bSetOption := {|x| .t.    }       // Validacao na saida da aba

if !Inclui
	oFolder011:noption := 2
Endif

//Tela de informacoes do cliente
aTela    := {}
aGets    := {}
dbSelectArea("VV9")
Zero()
oGetMGet1:= MsMGet():New("VV9",0,nOpc,,,,aPriEnc,{014,001,060,355},,2,,,,oDlgAtend,,.T.,.F.,"aSvTela[1]",.t.)
oGetMGet1:oBox:bGotFocus   := {|| AL_Entra(1,"VV9")}
oGetMGet1:oBox:bLostFocus  := {|| AL_Sai(1)}
aSvTela[1] := aClone(aTela)
aSvGets[1] := aClone(aGets)
Inclui := lInclui

//Tela de selecao do veiculo/modelo
aadd(aTipVei,"")
aadd(aMarca ,"")
aadd(aGener ,"")
aadd(aEspec ,"")

DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek("VV1_TIPVEI")
	cTipVei := X3CBOX()
	While len(cTipVei) > 1
		cont := If(at(";",cTipVei)==0,len(cTipVei)+1,at(";",cTipVei))
		aAdd(aTipVei,substr(cTipVei,1,cont-1))
		cTipVei := Alltrim(substr(cTipVei,cont+1,len(cTipVei)))
	EndDo
	cTipVei := ""
EndIf

nCodMar := 1
dbSelectArea("VE1")
dbSetOrder(1)
dbSeek(xFilial("VE1"))
While !Eof() .and. xFilial("VE1") == VE1->VE1_FILIAL
	aadd(aMarca,VE1->VE1_CODMAR)
	If cCodMar == VE1->VE1_CODMAR
		nCodMar := len(aMarca)
	EndIf
	dbSkip()
Enddo
if Len(aMarca) == 0
	aMarca := {""}
Endif

nGruMod := 1
dbSelectArea("VVR")
dbSetOrder(1)
dbSeek(xFilial("VVR")+aMarca[nCodMar])
While !Eof() .and. xFilial("VVR") == VVR->VVR_FILIAL .and. VVR->VVR_CODMAR == aMarca[nCodMar]
	if aScan(aGener,VVR->VVR_DESCRI) = 0
		aadd(aGener,VVR->VVR_DESCRI)
		If cGruMod == VVR->VVR_DESCRI
			nGruMod := len(aGener)
		EndIf
	Endif
	dbSkip()
Enddo
if Len(aGener) == 0
	aGener := {""}
Endif

dbSelectArea("VVR")
dbSetOrder(1)
dbSeek(xFilial("VVR")+aMarca[nCodMar]+aGener[nGruMod])
dbSelectArea("VV2")
dbSetOrder(3)
dbSeek(xFilial("VV2")+aMarca[nCodMar]+VVR->VVR_GRUMOD)
While !Eof() .and. xFilial("VV2") == VV2->VV2_FILIAL .and. VVR->VVR_CODMAR == aMarca[nCodMar] .and. VV2->VV2_GRUMOD == VVR->VVR_GRUMOD
	if aScan(aEspec,VV2->VV2_MODVEI) == 0
		aadd(aEspec,VV2->VV2_MODVEI)
	Endif
	dbSkip()
Enddo
if Len(aEspec) == 0
	aEspec := {""}
Endif

@  001, 001 SAY STR0014  SIZE 80,8 OF oFolder011:aDialogs[1] PIXEL COLOR CLR_BLUE   //Loja
@  008, 001 MSCOMBOBOX cbxFilVV1 VAR cFilVV1 SIZE 25,10 COLOR CLR_BLACK ITEMS aFilVV1 OF oFolder011:aDialogs[1] ON CHANGE FS_FILTROVV(.t.,4) PIXEL

@  001, 029 SAY STR0015  SIZE 80,8 OF oFolder011:aDialogs[1] PIXEL COLOR CLR_BLUE    //Tipo de Veiculo
@  008, 029 MSCOMBOBOX cbxTipVei VAR cTipVei SIZE 48,10 COLOR CLR_BLACK ITEMS aTipVei OF oFolder011:aDialogs[1] ON CHANGE FS_FILTROVV(.t.,4) PIXEL

@  001, 080 SAY STR0016  SIZE 80,8 OF oFolder011:aDialogs[1] PIXEL COLOR CLR_BLUE   //Marca
@  008, 080 MSCOMBOBOX cbxCodMar VAR cCodMar SIZE 60,10 COLOR CLR_BLACK ITEMS aMarca OF oFolder011:aDialogs[1] ON CHANGE FS_FILTROVV(.t.,1) PIXEL

@  001, 143 SAY STR0017 SIZE 80,8 OF oFolder011:aDialogs[1] PIXEL COLOR CLR_BLUE   //Grupo
@  008, 143 MSCOMBOBOX cbxGruMod VAR cGruMod SIZE 103,10 COLOR CLR_BLACK ITEMS aGener OF oFolder011:aDialogs[1] ON CHANGE FS_FILTROVV(.t.,2) PIXEL

@  001, 249 SAY STR0018 SIZE 80,8 OF oFolder011:aDialogs[1] PIXEL COLOR CLR_BLUE   //Modelo
@  008, 249 MSCOMBOBOX cbxModVei VAR cModVei SIZE 103,50 COLOR CLR_BLACK ITEMS aEspec OF oFolder011:aDialogs[1] ON CHANGE (IIF(M->VV0_TIPFAT=="3",M->VV0_TIPFAT:="",.T.),FS_FILTROVV(.t.,3)) PIXEL

//cCodMar := ""
//cGruMod := ""
//cModVei := ""
nLin    := 020

@ nLin,1 LISTBOX oLbox FIELDS HEADER;
OemToAnsi(""),;         //Indicador de Relacionamento
OemToAnsi("R"),;        //Indicador p/ veiculos reservados
OemToAnsi("Ft"),;       //Indica se o veiculo tem foto cadastrada
OemToAnsi(STR0019),;    //Indica a Loja
OemToAnsi(STR0020),;    //Dias em estoque
OemToAnsi(STR0021),;    //Chassi
OemToAnsi(STR0309),;    //Placa
OemToAnsi(STR0018),;    //Modelo
OemtoAnsi(STR0016),;    //Marca
OemtoAnsi(STR0022),;    //Cor
OemToAnsi(STR0023),;    //Preco
OemToAnsi(STR0024),;    //Estado (Novo/Usado)
OemToAnsi(STR0025),;    //Ano Fabricacao
OemToAnsi(STR0026),;    //Ano Modelo
OemToAnsi(STR0027),;    //Kilometragem
OemToAnsi(STR0028); 	//Em Poder de
COLSIZES 5,5,5,5,15,65,30,72,19,50,45,22,20,20,40,130;
SIZE 351,132 OF oFolder011:aDialogs[1] PIXEL ON DBLCLICK (nPos:=oLbox:nAt,IIF(nPos>0.AND.nPos<=Len(aStruVV1),FS_MARCA011(),nPos:=oLbox:nAt),oLbox:Refresh(),oLbox:nAt:=nPos)

if len(aStruVV1) == 0
	aAdd(aStruVV1, { .f.,"N",.f.," "," "," "," "," ",0,"","","",0,"","","","","",0,"" } )
Endif

oLbox:SetArray(aStruVV1)
oLbox:bLine := { || { IIf(!aStruVV1[oLbox:nAt,01],oNo,oTik),;
IIf(aStruVV1[oLbox:nAt,02]=="N",oBranco,IIf(aStruVV1[oLbox:nAt,02]=="V",oVerde,IIf(aStruVV1[oLbox:nAt,02]=="T",oLaranja,IIf(aStruVV1[oLbox:nAt,02]=="R",oVermelho,IIf(aStruVV1[oLbox:nAt,02]=="C",oAzul,IIf(aStruVV1[oLbox:nAt,02]=="A",oPreto,oAmarelo)))))),;
IIf(!aStruVV1[oLbox:nAt,03],oNada,oFoto),;
aStruVV1[oLbox:nAt,15],;
aStruVV1[oLbox:nAt,04],;
aStruVV1[oLbox:nAt,05],;
transform(aStruVV1[oLbox:nAt,16],VV1->(x3Picture("VV1_PLAVEI"))),;
aStruVV1[oLbox:nAt,06],;
aStruVV1[oLbox:nAt,07],;
aStruVV1[oLbox:nAt,08],;
FG_AlinVlrs(Transform(aStruVV1[oLbox:nAt,09],"@E 9,999,999.99")),;
aStruVV1[oLbox:nAt,10],;
aStruVV1[oLbox:nAt,11],;
aStruVV1[oLbox:nAt,12],;
aStruVV1[oLbox:nAt,13],;
aStruVV1[oLbox:nAt,14]} }

nLin += 137

@ nLin-5,002 TO nLin+12,072 LABEL STR0029 OF oFolder011:aDialogs[1] PIXEL //Pesquisar Veiculo
@ nLin+1,004 MSGET oChave VAR cChave VALID PESFIL011() PICTURE "@!" SIZE 67,08  OF oFolder011:aDialogs[1] PIXEL COLOR CLR_BLACK

@ nLin-5,074 TO nLin+12,112 LABEL STR0030 OF oFolder011:aDialogs[1] PIXEL  //Estoque
@ nLin+1,085 CHECKBOX oCkFilEst VAR lCkFilEst PROMPT "" OF oFolder011:aDialogs[1] ON CLICK FS_CKFiltro("EST") SIZE 08,08 PIXEL
@ nLin+3,095 BITMAP oxNormal RESOURCE "BR_BRANCO" OF oFolder011:aDialogs[1] NOBORDER SIZE 10,10 when .f. PIXEL

@ nLin-5,114 TO nLin+12,152 LABEL STR0031 OF oFolder011:aDialogs[1] PIXEL  //Virtual
@ nLin+1,125 CHECKBOX oCkFilVir VAR lCkFilVir PROMPT "" OF oFolder011:aDialogs[1] ON CLICK FS_CKFiltro("VIR") SIZE 08,08 PIXEL
@ nLin+3,135 BITMAP oxNorma2 RESOURCE "BR_VERDE" OF oFolder011:aDialogs[1] NOBORDER SIZE 10,10 when .f. PIXEL

@ nLin-5,154 TO nLin+12,192 LABEL STR0032 OF oFolder011:aDialogs[1] PIXEL  //Em Transito
@ nLin+1,165 CHECKBOX oCkFilTra VAR lCkFilTra PROMPT "" OF oFolder011:aDialogs[1] ON CLICK FS_CKFiltro("TRA") SIZE 08,08 PIXEL
@ nLin+3,175 BITMAP oxTransito RESOURCE "BR_LARANJA" OF oFolder011:aDialogs[1] NOBORDER SIZE 10,10 when .f. PIXEL

@ nLin-5,194 TO nLin+12,232 LABEL STR0033 OF oFolder011:aDialogs[1] PIXEL   //Reservado
@ nLin+1,205 CHECKBOX oCkFilRes VAR lCkFilRes PROMPT "" OF oFolder011:aDialogs[1] ON CLICK FS_CKFiltro("RES") SIZE 08,08 PIXEL
@ nLin+3,215 BITMAP oxReservado RESOURCE "BR_AMARELO" OF oFolder011:aDialogs[1] NOBORDER SIZE 10,10 when .f. PIXEL

@ nLin-5,234 TO nLin+12,272 LABEL STR0034 OF oFolder011:aDialogs[1] PIXEL  //Remessa
@ nLin+1,245 CHECKBOX oCkFilRem VAR lCkFilRem PROMPT "" OF oFolder011:aDialogs[1] ON CLICK FS_CKFiltro("REM") SIZE 08,08 PIXEL
@ nLin+3,255 BITMAP oxVerme RESOURCE "BR_VERMELHO" OF oFolder011:aDialogs[1] NOBORDER SIZE 10,10 when .f. PIXEL

@ nLin-5,274 TO nLin+12,312 LABEL STR0035 OF oFolder011:aDialogs[1] PIXEL  //Consignado
@ nLin+1,285 CHECKBOX oCkFilCon VAR lCkFilCon PROMPT "" OF oFolder011:aDialogs[1] ON CLICK FS_CKFiltro("CON") SIZE 08,08 PIXEL
@ nLin+3,295 BITMAP oxAzul RESOURCE "BR_AZUL" OF oFolder011:aDialogs[1] NOBORDER SIZE 10,10 when .f. PIXEL

@ nLin-5,314 TO nLin+12,352 LABEL STR0266 OF oFolder011:aDialogs[1] PIXEL  //Imobilizado
@ nLin+1,325 CHECKBOX oCkFilAti VAR lCkFilAti PROMPT "" OF oFolder011:aDialogs[1] ON CLICK FS_CKFiltro("ATI") SIZE 08,08 PIXEL
@ nLin+3,335 BITMAP oxPret RESOURCE "BR_PRETO" OF oFolder011:aDialogs[1] NOBORDER SIZE 10,10 when .f. PIXEL

nLin += 2

//Tela de valores do atendimento
dbSelectArea("VV0")
Zero()
aTela := {}
aGets := {}
oGetMGet2:= MsMGet():New("VV0",0,nOpc,,,,aSegEnc,{000,000,170,355},,2,,,,oFolder011:aDialogs[2],,.T.,.F.,"aSvTela[2]",.t.)
oGetMGet2:oBox:bGotFocus   := {|| AL_Entra(2,"VV0")}
oGetMGet2:oBox:bLostFocus  := {|| AL_Sai(2)}
aSvTela[2] := aClone(aTela)
aSvGets[2] := aClone(aGets)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
MENU oMenu POPUP   
	If _lVerBotoes // Nao Mostra OPCAO quando chamado por outro fonte
		MENUITEM STR0036 Action (lFechaDlg := .f.,STATUS011("O",.t.),iif(lFechaDlg,oDlgAtend:End(),.f.))//Pre-Aprovar
		MENUITEM STR0037 Action (lFechaDlg := .f.,STATUS011("L",.t.),iif(lFechaDlg,oDlgAtend:End(),.f.))//Aprovar Fat
		MENUITEM STR0038 Action (ENCERRA011(2),iif(!empty(M->VV9_MOTIVO),oDlgAtend:End(),.t.)) .and. STATUS011("R",.t.)//Reprovar
		MENUITEM STR0039 Action STATUS011("A",.t.)	//Reativar
		MENUITEM STR0040 Action (ENCERRA011(2),iif(!empty(M->VV9_MOTIVO),oDlgAtend:End(),.t.))//Cancela Venda
		MENUITEM STR0041 Action (CANRES011())		////Cancela Reserva
	EndIf
	MENUITEM STR0042 Action AVARES011() 		//Avaliacao
	MENUITEM STR0043 Action FS_CLI011()			//Clientes
	MENUITEM STR0296 Action (oFolder011:noption := 3, oGetDadosAgr:oBrowse:lVisible := .f., oFldAcess:lVisible := .t. ,ACESS011() ,oAvancar:cCaption := STR0058+" >>")
//	MENUITEM STR0006 Action (oFolder011:noption := 3, oGetDadosAgr:oBrowse:lVisible := .f., oFldAcess:lVisible := .t. ,ACESS011() ,oAvancar:cCaption := STR0058+" >>")//Acessorios - Avancar
//	MENUITEM STR0044 Action (oFolder011:noption := 3, oFldAcess:lVisible := .f., oGetDadosAgr:oBrowse:lVisible := .t. ,oAvancar:cCaption := STR0058+" >>")//Agregados - Avancar
	If _lVerBotoes // Nao Mostra OPCAO quando chamado por outro fonte
		MENUITEM STR0045 Action FS_SIMFAI()			//Simulacao FI
		MENUITEM STR0351 Action FS_TestDriv()			//Formulario TestDrive
	EndIf
	MENUITEM STR0007+" / "+STR0350 Action (oFolder011:noption := 4,oGetDadosIC:oBrowse:SetFocus(), oAvancar:cCaption := STR0058+" >>")//Campanha / Troco -- Avancar
	MENUITEM STR0046 Action (oFolder011:noption := 5, oAvancar:cCaption := STR0058+" >>")//Outras Informacoes -- Avancar
	MENUITEM STR0062 Action FS_DERE011(nOpc)		//Despesas / Receitas
	MENUITEM STR0047 Action FS_CONSNEG()		//Valores Negociacao
//	MENUITEM STR0047 Action FS_VALMIN()			//Valores Negociacao
	MENUITEM STR0048 Action VEIVC140(IIf(lSelect,VV1->VV1_CHASSI,M->VV0_CHASSI))	//Rastreamento do Veiculo
	MENUITEM STR0049 Action CHKLST011()			//Check-List de Veiculo
	If _lVerBotoes // Nao Mostra OPCAO quando chamado por outro fonte
		MENUITEM STR0050 Action IMPPRO011()			//Impressao Proposta
	EndIf
	MENUITEM STR0051 Action VEIVC090(M->VV9_CODCLI,M->VV9_LOJA,.t.)  //Veiculos do Cliente ---- Andre Luis Almeida 13/03/2008 - Inclusao do BOTAO para Visualizar os Veiculos do Cliente
	If _lVerBotoes // Nao Mostra OPCAO quando chamado por outro fonte
		MENUITEM STR0052 Action ML500A()  			//Abordagem / Reclamacao ---- Andre Luis Almeida 27/02/2008 - Inclusao do BOTAO para Registro de Abordagem / RAIC
	EndIf
//	MENUITEM "Consulta CRM/CallCenter" Action FG_CONSAC8(xFilial("SA1"),M->VV9_CODCLI,M->VV9_LOJA)  // Luis Delorme 28/03/2008 - Inclusao do BOTAO para Visualizar o CRM/CallCenter
// MENUITEM STR0053 Action (FS_VALFIS("V"))	//Planilha Financeira // Andre Luis Almeida 13/02/2009 - Retirado (solicitacao Alexandre)
	If FindFunction("VEIVM130TAR") // Tarefas do Atendimento - Andre Luis Almeida 18/09/09 T1031 Maipu //
		MENUITEM STR0271 Action VEIVM130TAR(M->VV9_NUMATE,"3") // "Solicitar Tarefas" 1-Gravacao / 2-Finalizacao / 3-Pelo Usuario / 4-Pendente Aprovacao / 5-Pre-Aprovado / 6-Aprovado / 7-Reserva / 8-Cancela Reserva / 9-Cancela Atendimento
	EndIf
	If FindFunction("VEIVM130") // Tarefas do Atendimento - Andre Luis Almeida 18/09/09 T1031 Maipu //
		MENUITEM STR0268 Action VEIVM130(M->VV9_NUMATE)	// Visualiza Tarefas
	EndIf
	MENUITEM STR0332 Action FS_CALCDTENT("1",M->VV9_NUMATE,.t.) // Calcula Sugestao da Data de Entrega
	MENUITEM STR0341 Action FS_MINCOMV() // Minimo Comercial
	MENUITEM "Observacao na Impressao da NF" Action FS_OBSNF(nOpc) // Observacao na Impressao da NF
ENDMENU
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@ 231,010 BUTTON oOpcoes   PROMPT OemToAnsi(STR0054)    OF oDlgAtend SIZE 43,11 PIXEL ACTION OPCOES011( oOpcoes, 2, -280, oMenu , _lVerBotoes ) //Opcoes
@ 231,060 BUTTON oCalcula  PROMPT OemToAnsi(STR0055)  OF oDlgAtend SIZE 43,11 PIXEL ACTION FS_CALC011() 	//Calcular
@ 231,060 BUTTON oCortesia PROMPT OemToAnsi(STR0056)  OF oDlgAtend SIZE 43,11 PIXEL ACTION ITECORT011() 	//Cortesia

@ 231,255 BUTTON oVoltar  PROMPT OemToAnsi("<< "+STR0057)  OF oDlgAtend SIZE 43,11 PIXEL ACTION VOLTAR011()  	//Voltar
@ 231,305 BUTTON oAvancar PROMPT OemToAnsi(STR0058+" >>") OF oDlgAtend SIZE 43,11 PIXEL ACTION AVANCA011(aPriEnc,aSegEnc,aTerEnc,aQuaEnc)  	//Avancar

oCalcula:lVisible := .f.
oCortesia:lVisible := .f.

//@ 001,094 FOLDER oFldAcess SIZE 214,167 OF  oFolder011:aDialogs[3] PROMPTS STR0006 PIXEL // STR0059,STR0006,STR0060 PIXEL //Opcionais-Acessorios-Terceiros
@ 001,094 FOLDER oFldAcess SIZE 214,167 OF  oFolder011:aDialogs[3] PROMPTS STR0296 PIXEL // "Consulta Opc Mod" 

//Tela de Opcionais
@ 001,001 LISTBOX oLboxAce FIELDS HEADER;
OemToAnsi(""),;      //Indicador de selecao
OemToAnsi(STR0061),; //Descricao do acessorio
OemToAnsi(STR0023),; //Valor do acessorio
OemToAnsi("");       //Crotesia
COLSIZES 8,130,45,5;
SIZE 211,153 OF oFldAcess:aDialogs[1] PIXEL ON DBLCLICK (MARACE011(),oLboxAce:Refresh())

if len(aAcessor) == 0
	aAdd(aAcessor, { .f.," ",0,"",.f.,.f. } )
Endif

oLboxAce:SetArray(aAcessor)
oLboxAce:bLine := { || { if(aAcessor[oLboxAce:nAt,01] == .f.,oNo,iif(aAcessor[oLboxAce:nAt,06],oChecked,oTik)),;
aAcessor[oLboxAce:nAt,02],;
FG_AlinVlrs(Transform(aAcessor[oLboxAce:nAt,03],"9,999,999.99")),;
iif(aAcessor[oLboxAce:nAt,05] == .f.,oNada,oGratis) }}

if len(aKits) == 0
	aAdd(aKits, { .f.," ",0,"","",.f. } )
Endif
/*
//Tela de Acessorios
@ 001,001 LISTBOX oLboxKit FIELDS HEADER;
OemToAnsi(""),;      //Indicador de selecao
OemToAnsi(STR0061),; //Descricao do acessorio
OemToAnsi(STR0023),; //Valor do acessorio
OemToAnsi("");       //Crotesia
COLSIZES 8,130,45,5;
SIZE 211,153 OF oFldAcess:aDialogs[2] PIXEL ON DBLCLICK (MARKIT011(),oLboxKit:Refresh())

oLboxKit:SetArray(aKits)
oLboxKit:bLine := { || { if(aKits[oLboxKit:nAt,01] == .f.,oNo,oTik),;
aKits[oLboxKit:nAt,02],;
FG_AlinVlrs(Transform(aKits[oLboxKit:nAt,03],"9,999,999.99")),;
iif(aKits[oLboxKit:nAt,06] == .f.,oNada,oGratis) }}
*/

//Tela de Terceiros
aHeader := aClone(aHeaderTC)
aCols   := aClone(aColsTC)
n       := nTC := 1
/*
oGetDadosTer:= MsGetDados():New(01,1,154,212,nOpc,cLinOk,cTudoOk,"",.T.,,,,,,,,,oFldAcess:aDialogs[3])
oGetDadosTer:oBrowse:default()
oGetDadosTer:oBrowse:bChange     := {|| FG_MEMVAR(), lSalvou := .f. }
oGetDadosTer:oBrowse:bEditCol    := {|| if(!Empty(aCols[n,FG_POSVAR("VV6_CODFOR")]),aCols[n,FG_POSVAR("VV6_NOMFOR")] := SA2->A2_NOME,.t.),lSalvou := .f.,oGetMGet5:Refresh() }
oGetDadosTer:oBrowse:bAltered    := {|| lSalvou := .f. ,FG_TOTENT(.T.)}
oGetDadosTer:oBrowse:bDelete     := {|| if(aCols[n,Len(aCols[n])], aCols[n,Len(aCols[n])] := .f., aCols[n,Len(aCols[n])] := .t.),FG_MEMVAR()}
oGetDadosTer:oBrowse:bGotFocus   := {|| n := nTC, aCols := aClone(aColsTC), aHeader := aClone(aHeaderTC), oGetDadosTer:oBrowse:Refresh()}
oGetDadosTer:oBrowse:bLostFocus  := {|| nTC := n, aColsTC := aClone(aCols), aHeaderTC := aClone(aHeader), oGetDadosTer:oBrowse:Refresh()}
*/

//Tela de Agregados
dbSelectArea("VAT")
dbSetOrder(1)
aHeader  := aClone(aHeaderAG)
aCols    := aClone(aColsAG)
n        := nAG := 1
oGetDadosAgr:= MsGetDados():New(001,94,169,354,nOpc,cLinOk,cTudoOk,"",.T.,,,,,,,,,oFolder011:aDialogs[3])
oGetDadosAgr:oBrowse:default()
oGetDadosAgr:oBrowse:bChange     := {|| FG_MEMVAR(), lSalvou := .f. }
oGetDadosAgr:oBrowse:bEditCol    := {|| if(!Empty(aCols[n,FG_POSVAR("VAT_CODNEG")]),aCols[n,FG_POSVAR("VAT_DESNEG")] := VAU->VAU_DESNEG,.t.),lSalvou := .f., oGetMGet5:Refresh() }
oGetDadosAgr:oBrowse:bDelete     := {|| if(aCols[n,Len(aCols[n])] , aCols[n,Len(aCols[n])] := .f. , aCols[n,Len(aCols[n])] := .t.),FG_MEMVAR()}
oGetDadosAgr:oBrowse:bGotFocus   := {|| n := nAG, aCols := aClone(aColsAG), aHeader := aClone(aHeaderAG), oGetDadosAgr:oBrowse:Refresh()}
oGetDadosAgr:oBrowse:bLostFocus  := {|| nAG := n, aColsAG := aClone(aCols), aHeaderAG := aClone(aHeader), oGetDadosAgr:oBrowse:Refresh()}
oGetDadosAgr:oBrowse:lVisible    := .f.

dbSelectArea("VV0")
Zero()
aTela := {}
aGets := {}
if cVersao <> "P10"
	oGetMGet6:= MsMGet():New("VV0",0,nOpc,,,,aQuiEnc,{001,001,168,080},,2,,,,oFolder011:aDialogs[3],,.T.,.T.,"aSvTela[6]",.t.)
Else
   oGetMGet6:= MsMGet():New("VV0",0,nOpc,,,,aQuiEnc,{001,001,168,092},,2,,,,oFolder011:aDialogs[3],,.T.,.T.,"aSvTela[6]",.t.)
   
Endif
oGetMGet6:oBox:bGotFocus   := {|| AL_Entra(6,"VV0")}
oGetMGet6:oBox:bLostFocus  := {|| AL_Sai(6)}
aSvTela[6] := aClone(aTela)
aSvGets[6] := aClone(aGets)
Inclui := lInclui

dbSelectArea("VV2")
dbSetOrder(1)
dbSeek(xFilial("VV2")+M->VV0_CODMAR)
/*
@ 083,002 RADIO oTipCor VAR nTipCor 3D SIZE 50,10 PROMPT;
OemToAnsi("Cor Solida"), OemToAnsi("Cor Metalica"), OemToAnsi("Cor Perolisada");
OF oFolder011:aDialogs[3] PIXEL ON CHANGE (cCor := Space(30), oCor:Refresh()) When (M->VV0_TIPFAT <> "0" .or. M->VV0_SIMULA == "1")

@  085, 056 SAY STR0023  SIZE 74,8 OF oFolder011:aDialogs[3] PIXEL COLOR CLR_BLUE
@  093, 056 MSGET oValCor VAR nValCor PICTURE "9999" SIZE 37,4 OF oFolder011:aDialogs[3] PIXEL COLOR CLR_BLACK When (M->VV0_TIPFAT <> "0" .or. M->VV0_SIMULA == "1")

@  111, 002 SAY "Cor"  SIZE 80,8 OF oFolder011:aDialogs[3] PIXEL COLOR CLR_BLUE
@  120, 002 MSGET oCor    VAR cCor    PICTURE "@!" F3 "VVC1" SIZE 92,4 OF oFolder011:aDialogs[3] PIXEL COLOR CLR_BLACK When (M->VV0_TIPFAT <> "0" .or. M->VV0_SIMULA == "1")
*/

/*
//Cores Metalicas
@ 001,204 LISTBOX oLboxCorM FIELDS HEADER;
OemToAnsi(""),;              //Indicador de selecao
OemToAnsi("Cor Metalica"),;  //Cor
OemToAnsi(STR0023);          //Valor da cor
COLSIZES 10,40,20;
SIZE 108,062 OF oFolder011:aDialogs[3] PIXEL ON DBLCLICK (MARCOR011(1))

if len(aCorM) == 0
aAdd(aCorM, { .f.," ",0 } )
Endif

oLboxCorM:SetArray(aCorM)
oLboxCorM:bLine := { || { if(aCorM[oLboxCorM:nAt,01] == .f.,oNo,oTik),;
aCorM[oLboxCorM:nAt,02],;
FG_AlinVlrs(Transform(aCorM[oLboxCorM:nAt,03],"9,999.99")),} }

//Cores Perolizadas
@ 068,204 LISTBOX oLboxCorP FIELDS HEADER;
OemToAnsi(""),;                //Indicador de selecao
OemToAnsi("Cor Perolizada"),;  //Cor
OemToAnsi(STR0023);            //Valor da cor
COLSIZES 10,40,20;
SIZE 108,062 OF oFolder011:aDialogs[3] PIXEL ON DBLCLICK (MARCOR011(2))

if len(aCorP) == 0
aAdd(aCorP, { .f.," ",0 } )
Endif

oLboxCorP:SetArray(aCorP)
oLboxCorP:bLine := { || { if(aCorP[oLboxCorP:nAt,01] == .f.,oNo,oTik),;
aCorP[oLboxCorP:nAt,02],;
FG_AlinVlrs(Transform(aCorP[oLboxCorP:nAt,03],"9,999.99")),} }

*/

//Campanha promocional
aHeader  := aClone(aHeaderIC)
aCols    := aClone(aColsIC)
n        := nIC := 1
oGetDadosIC:= MsGetDados():New(01,1,169,354,nOpc,cLinOk,cTudoOk,"",.T.,,,,,'FS_ITECAM("A")',,,,oFolder011:aDialogs[4])
oGetDadosIC:oBrowse:default()
//oGetDadosIC:oBrowse:bChange     := {|| FS_ITECAM("A"), oGetDadosIC:oBrowse:Refresh()  }
//oGetDadosIC:oBrowse:bChange     := {|| n := nIC , aCols := aClone(aColsIC) , aHeader := aClone(aHeaderIC) , FG_MEMVAR() , oGetDadosIC:oBrowse:Refresh() }
oGetDadosIC:oBrowse:bChange     := {|| FG_MEMVAR() }
oGetDadosIC:oBrowse:bDelete     := {|| FS_ITECAM("D"),iif(aCols[n,Len(aCols[n])], aCols[n,Len(aCols[n])] := .f., aCols[n,Len(aCols[n])] := .t.), oGetDadosIC:oBrowse:Refresh() }
oGetDadosIC:oBrowse:bGotFocus   := {|| n := nIC, aCols := aClone(aColsIC), aHeader := aClone(aHeaderIC), FG_MEMVAR() , oGetDadosIC:oBrowse:Refresh()}
oGetDadosIC:oBrowse:bLostFocus  := {|| nIC := n, aColsIC := aClone(aCols), aHeaderIC := aClone(aHeader), oGetDadosIC:oBrowse:Refresh()}

//Outros valores do atendimento
dbSelectArea("VVA")
aTela    := {}
aGets    := {}
Zero()
if funname() == "VEIVC170"
	oGetOut:= MsMGet():New("VVA",0,2,,,,aSetEnc,{000,000,142,355},,2,,,,oFolder011:aDialogs[5],,.T.,.F.,"aSvTela[7]",.t.)
Else
	oGetOut:= MsMGet():New("VVA",0,4,,,,aSetEnc,{000,000,142,355},,2,,,,oFolder011:aDialogs[5],,.T.,.F.,"aSvTela[7]",.t.)
Endif
aSvTela[7] := aClone(aTela)
aSvGets[7] := aClone(aGets)

//Negociacao de pagamento
dbSelectArea("VV0")
Zero()
aTela := {}
aGets := {}
if Funname() == "VEIVC170"
	if cVersao <> "P10"
		oGetMGet5:= MsMGet():New("VV0",0,2,,,,aQuiEnc,{001,001,109,080},,2,,,,oFolder011:aDialogs[6],,.T.,.T.,"aSvTela[5]",.t.)
	Else
		oGetMGet5:= MsMGet():New("VV0",0,2,,,,aQuiEnc,{001,001,109,125},,2,,,,oFolder011:aDialogs[6],,.T.,.T.,"aSvTela[5]",.t.)
	Endif
Else
	if cVersao <> "P10"
		oGetMGet5:= MsMGet():New("VV0",0,nOpcNeg,,,,aQuiEnc,{001,001,109,080},,2,,,,oFolder011:aDialogs[6],,.T.,.T.,"aSvTela[5]",.t.)
	Else
		oGetMGet5:= MsMGet():New("VV0",0,nOpcNeg,,,,aQuiEnc,{001,001,109,125},,2,,,,oFolder011:aDialogs[6],,.T.,.T.,"aSvTela[5]",.t.)
	Endif
Endif
oGetMGet5:oBox:bGotFocus   := {|| AL_Entra(5,"VV0")}
oGetMGet5:oBox:bLostFocus  := {|| AL_Sai(5)}
aSvTela[5] := aClone(aTela)
aSvGets[5] := aClone(aGets)
Inclui := lInclui

dbSelectArea("VV0")
Zero()
aTela := {}
aGets := {}
if Funname() == "VEIVC170"
	if cVersao <> "P10"
		oGetMGet3:= MsMGet():New("VV0",0,2  ,,,,aTerEnc,{001,001,109,080},,2,,,,oFolder011:aDialogs[6],,.T.,.T.,"aSvTela[3]",.t.)
	Else
		oGetMGet3:= MsMGet():New("VV0",0,2  ,,,,aTerEnc,{001,126,109,251},,2,,,,oFolder011:aDialogs[6],,.T.,.T.,"aSvTela[3]",.t.)
	Endif
Else
	if cVersao <> "P10"
		oGetMGet3:= MsMGet():New("VV0",0,4  ,,,,aTerEnc,{001,001,109,080},,2,,,,oFolder011:aDialogs[6],,.T.,.T.,"aSvTela[3]",.t.)
	Else
		oGetMGet3:= MsMGet():New("VV0",0,4  ,,,,aTerEnc,{001,126,109,251},,2,,,,oFolder011:aDialogs[6],,.T.,.T.,"aSvTela[3]",.t.)
	Endif
Endif
oGetMGet3:oBox:bGotFocus   := {|| AL_Entra(3,"VV0")}
oGetMGet3:oBox:bLostFocus  := {|| AL_Sai(3)}
aSvTela[3] := aClone(aTela)
aSvGets[3] := aClone(aGets)

@ 001, 252 LISTBOX oLbParc FIELDS HEADER  OemToAnsi(STR0119),OemToAnsi(STR0023); //data - valor
COLSIZES 40,50;
SIZE 101,108 OF oFolder011:aDialogs[6] PIXEL ON DBLCLICK (lCalcVEI:=.f.,if(funname() <> "VEIVC170",FG_ALTFINAN(oLbParc:nAt),.f.))
oLbParc:SetArray(aIteParc)
oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}

nLinhas  := 99
aHeader  := aClone(aHeaderC)
aCols    := aClone(aColsC)
n        := nC := 1
if Funname() == "VEIVC170"
	oGetCondicao:= MsGetDados():New(110,001,169,354,2,cLinOk,cTudoOk,"",If(nOpc > 2 .and. nOpc < 5,.t.,.f.),,,,nLinhas,cFieldOk,,,,oFolder011:aDialogs[6])
Else
	oGetCondicao:= MsGetDados():New(110,001,169,354,nOpcNeg,cLinOk,cTudoOk,"",If(nOpc > 2 .and. nOpc < 5,.t.,.f.),,,,nLinhas,cFieldOk,,,,oFolder011:aDialogs[6])
Endif
oGetCondicao:oBrowse:Default()
oGetCondicao:oBrowse:bChange     := {|| FG_MEMVAR(), lSalvou := .f. }
oGetCondicao:oBrowse:bEditCol    := {|| FS_VALOR011(),if(!Empty(aCols[n,FG_POSVAR("VS9_TIPPAG")]),aCols[n,FG_POSVAR("VS9_DESPAG")] := VSA->VSA_DESPAG,.t.), aColsC := aClone(aCols), aHeaderC := aClone(aHeader),FS_CALC011(),lSalvou := .f.,oGetMGet5:Refresh()}
oGetCondicao:oBrowse:bAltered    := {|| lSalvou := .f., aColsC := aClone(aCols), aHeaderC := aClone(aHeader) ,FG_TOTENT(.T.)}
oGetCondicao:oBrowse:bDelete     := {|| iif(aCols[n,Len(aCols[n])], aCols[n,Len(aCols[n])] := .f., aCols[n,Len(aCols[n])] := .t.), aColsC := aClone(aCols), aHeaderC := aClone(aHeader), oGetCondicao:oBrowse:Refresh(), FS_CALC011(), FG_MEMVAR()}
oGetCondicao:oBrowse:bGotFocus   := {|| n := nC, aCols := aClone(aColsC), aHeader := aClone(aHeaderC), oGetCondicao:oBrowse:Refresh()}
oGetCondicao:oBrowse:bLostFocus  := {|| nC := n, aColsC := aClone(aCols), aHeaderC := aClone(aHeader), oGetCondicao:oBrowse:Refresh()}

//Finalizacao da venda
dbSelectArea("VV0")
Zero()
aTela := {}
aGets := {}
if cVersao <> "P10"
	oGetMGet8:= MsMGet():New("VV0",0,nOpc,,,,aQuiEnc,{001,001,168,080},,2,,,,oFolder011:aDialogs[7],,.T.,.T.,"aSvTela[8]",.t.)
Else
	oGetMGet8:= MsMGet():New("VV0",0,nOpc,,,,aQuiEnc,{001,001,168,125},,2,,,,oFolder011:aDialogs[7],,.T.,.T.,"aSvTela[8]",.t.)
Endif
oGetMGet8:oBox:bGotFocus   := {|| AL_Entra(8,"VV0")}
oGetMGet8:oBox:bLostFocus  := {|| AL_Sai(8)}
aSvTela[8] := aClone(aTela)
aSvGets[8] := aClone(aGets)
Inclui := lInclui

dbSelectArea("VV0")
Zero()
aTela := {}
aGets := {}
if Funname() == "VEIVC170"
	if cVersao <> "P10"
		oGetMGet4:= MsMGet():New("VV0",0,2,,,,aQuaEnc,{001,160,168,354},,2,,,"FS_LEASIN011()",oFolder011:aDialogs[7],,.T.,.T.,"aSvTela[4]",.t.)
	Else
		oGetMGet4:= MsMGet():New("VV0",0,2,,,,aQuaEnc,{001,126,168,354},,2,,,"FS_LEASIN011()",oFolder011:aDialogs[7],,.T.,.T.,"aSvTela[4]",.t.)
	Endif
Else
	if cVersao <> "P10"
		oGetMGet4:= MsMGet():New("VV0",0,nOpcUlt,,,,aQuaEnc,{001,160,168,354},,2,,,"FS_LEASIN011()",oFolder011:aDialogs[7],,.T.,.T.,"aSvTela[4]",.t.)
	Else
		oGetMGet4:= MsMGet():New("VV0",0,nOpcUlt,,,,aQuaEnc,{001,126,168,354},,2,,,"FS_LEASIN011()",oFolder011:aDialogs[7],,.T.,.T.,"aSvTela[4]",.t.)
	Endif
Endif
oGetMGet4:oBox:bGotFocus   := {|| AL_Entra(4,"VV0")}
oGetMGet4:oBox:bLostFocus  := {|| AL_Sai(4)}
aSvTela[4] := aClone(aTela)
aSvGets[4] := aClone(aGets)

If !Empty(cTitJanela)
	SetDlg(oDlgAtend,cTitJanela) // Mudar Nome (TITULO) do aRotina - Andre Luis Almeida (02/12/09)
EndIf

ACTIVATE MSDIALOG oDlgAtend CENTER ON INIT (EnchoiceBar(oDlgAtend, {|| nOpca := 1, iif(FINAL011(),oDlgAtend:End(),.f.) },{|| nOpca := 2, iif(Inclui,iif(ENCERRA011(1),oDlgAtend:End(),.f.),oDlgAtend:End()) },,aNewBot))

If nOpca == 0
	ENCERRA011(1)
EndIf

If MaFisFound('NF')
	MAFISEND()
EndIf

dbSelectArea("VV9")
dbSetOrder(1)


// AJUSTE INTERNO PARA CORREÇÃO NA HD VVO_DATMOV x F2_EMISSAO
cQryAl001 := GetNextAlias()
cQuery := "SELECT SF2.F2_EMISSAO, VV0.R_E_C_N_O_ RECVV0 FROM "+RetSQLName("SF2")+" SF2, "+RetSQLName("VV0")+" VV0 WHERE"
cQuery += " VV0.VV0_FILIAL = SF2.F2_FILIAL AND"
cQuery += " VV0.VV0_NUMNFI = SF2.F2_DOC AND"
cQuery += " VV0.VV0_SERNFI = SF2.F2_SERIE AND"
cQuery += " SF2.F2_EMISSAO <> VV0.VV0_DATMOV"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAl001, .F., .T. ) 
//
DBSelectArea("VV0")
while !(cQryAl001)->(eof())
	DBGoto((cQryAl001)->(RECVV0))
	reclock("VV0",.f.)
	VV0->VV0_DATMOV := stod((cQryAl001)->(F2_EMISSAO))
	msunlock()
	(cQryAl001)->(DBSkip())
enddo
(cQryAl001)->(dbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AVANCA011    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avanca para o proximo passo no atendimento                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AVANCA011(aPriEnc,aSegEnc,aTerEnc,aQuaEnc)

Local lEnd			:= .f.
Local iii 			:= 0
                                                                                                                                          
if getnewpar("MV_SELFEST","S") == "N" // Se S ,permite selecao de veiculo fora do estoque. Se N nao permite.
    if aStruVV1[oLbox:nAt,1] == .f.
		lAvanca := .f.
	Else
		lAvanca := .t.
	Endif	
Else
	lAvanca := .t.
Endif	
if ((!lSelect .and. (Empty(cCodMar) .or. Empty(cGruMod) .or. Empty(cModVei))) .and. (M->VV0_TIPFAT < "1" .and. Empty(M->VV0_CHASSI))) .or. lAvanca == .f.
	MsgInfo(STR0063 ,STR0012) //Selecione um Veiculo ou uma Marca/Modelo... -- Atencao
	Return
Endif

if (!lSelect .and. !(Empty(cCodMar) .or. Empty(cGruMod) .or. Empty(cModVei)) .and. !lJaPer011)  .and. (M->VV0_TIPFAT < "1" .and. Empty(M->VV0_CHASSI))
	if !FS_PERG011(1)
		Return
	Endif
Endif

if oFolder011:noption == 1
	ACESS011()
	CORES011()
	FS_LevVZ7() // Levanta Campanha
Endif

if oAvancar:cCaption == STR0064 //Finalizar
	lFechaDlg := .f.
	if oFolder011:noption == 2
		lEnd := FINAL011(1)
	Endif
	if oFolder011:noption == 6
		lEnd := FINAL011(2)
	Endif
	if oFolder011:noption == 7
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Otavio - 24/06/2009 - FNC 00000015252                        ³
//³ Verifica obrigatorios dos campos de todas Gets               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For iii:=1 to Len(aSegEnc)	
			If lValChassi .or. aSegEnc[iii] <> "VV0_CHASSI" // Para validar Chassi somente quando for preciso
				If X3Obrigat(aSegEnc[iii]) .and. Empty(&("M->"+aSegEnc[iii]))
					Help(" ",1,"OBRIGAT2",,RetTitle(aSegEnc[iii]),4,1 )
					Return
				EndIf
			EndIf
		Next
		IF Empty(M->VV0_CODTES)
			MsgStop(STR0158 ,STR0012) //TES de venda nao informado...- Atencao
			Return	
   		EndIf
		
		For iii:=1 to Len(aTerEnc)	
			If X3Obrigat(aTerEnc[iii]) .and. Empty(&("M->"+aTerEnc[iii]))
				Help(" ",1,"OBRIGAT2",,RetTitle(aTerEnc[iii]),4,1 )
				Return
			EndIf
		Next
	
		For iii:=1 to Len(aQuaEnc)	
			If X3Obrigat(aQuaEnc[iii]) .and. Empty(&("M->"+aQuaEnc[iii]))
				Help(" ",1,"OBRIGAT2",,RetTitle(aQuaEnc[iii]),4,1 )
				Return
			EndIf
		Next
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Otavio - 24/06/2009 - FNC 00000015252                        ³
//³ Verifica obrigatorios dos campos da Enchoice                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For iii:=1 to Len(aPriEnc)	
			If X3Obrigat(aPriEnc[iii]) .and. Empty(&("M->"+aPriEnc[iii]))
				Help(" ",1,"OBRIGAT2",,RetTitle(aPriEnc[iii]),4,1 )
				Return
			EndIf
		Next			
		
		lEnd := FINAL011(3)
	Endif
	if lEnd .or. lFechaDlg
		oDlgAtend:End()
	Endif
	Return
Endif

if oFolder011:noption == 2
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Otavio - 24/06/2009 - FNC 00000015252                        ³
//³ Verifica obrigatorios dos campos da MsMGet Atual             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("VV0")
	For iii:=1 to Len(aSegEnc)	
		If lValChassi .or. aSegEnc[iii] <> "VV0_CHASSI" // Para validar Chassi somente quando for preciso
			If X3Obrigat(aSegEnc[iii]) .and. Empty(&("M->"+aSegEnc[iii]))
				Help(" ",1,"OBRIGAT2",,RetTitle(aSegEnc[iii]),4,1 )
				Return
			EndIf
		EndIf
	Next
	IF Empty(M->VV0_CODTES)
		MsgStop(STR0158 ,STR0012) //TES de venda nao informado...- Atencao
		Return	
	EndIf
Endif

if oFolder011:noption == 6
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Otavio - 24/06/2009 - FNC 00000015252                        ³
//³ Verifica obrigatorios dos campos da MsMGet Atual             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("VV0")
	For iii:=1 to Len(aTerEnc)	
		If X3Obrigat(aTerEnc[iii]) .and. Empty(&("M->"+aTerEnc[iii]))
			Help(" ",1,"OBRIGAT2",,RetTitle(aTerEnc[iii]),4,1 )
			Return
		EndIf
	Next
Endif

if oFolder011:noption # 1
	If lCalcVEI
		FS_CALC011()
		lCalcVEI := .f.
	EndIf
EndIf

if oFolder011:noption == 6
	if !lJaCal011 .or. Empty(M->VV0_FORPAG)
		MsgInfo(STR0066 ,STR0012) //Informe uma condicao de pagamento! - Atencao
		Return
	Endif
	if !FS_VLDCDP()
		Return
	Endif
	INIFIS011()
	FISCAL011()
Endif

if (oFolder011:noption == 1 .and. !lNegPag .and. !lEmiNfi) .or. /* (oFolder011:noption == 2 .and. lNegPag .and. !lEmiNfi) .or.*/  (oFolder011:noption == 6 .or. oFolder011:noption == 7)  //.or. (oFolder011:noption == 4 .and. !lEmiNfi)
	oAvancar:cCaption := STR0064 //Finalizar
Else
	oAvancar:cCaption := STR0058 +" >>" //avancar
Endif

if  /*(oFolder011:noption == 6 .and. !lEmiNfi) .or.*/  (oFolder011:noption == 2 .and. !lNegPag .and. !lEmiNfi) //.or. (oFolder011:noption == 3 .and. !lEmiNfi)
	Return
Endif

aCols   := aClone(aColsC)
aHeader := aClone(aHeaderC)
n := nC
oGetCondicao:oBrowse:Refresh()

if oFolder011:noption == 2
	oFolder011:noption := oFolder011:noption + 4
Elseif oFolder011:noption == 3
	oFolder011:noption := oFolder011:noption + 3
ElseIf oFolder011:noption == 5
	oFolder011:noption := 2 // Volta para o 2o. Folder 
Else
	oFolder011:noption := oFolder011:noption + 1
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VOLTAR011    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avanca para o proximo passo no atendimento                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VOLTAR011()

if oFolder011:noption == 2 .and. !lJaFiltro
	FS_FILTROVV(.t.)
Endif

if oFolder011:noption == 6
	oFolder011:noption := oFolder011:noption - 4
Elseif oFolder011:noption == 5
	oFolder011:noption := oFolder011:noption - 3
Elseif oFolder011:noption == 4
	oFolder011:noption := oFolder011:noption - 2
Else
	oFolder011:noption := oFolder011:noption - 1
Endif

if (oFolder011:noption == 2 .and. !lNegPag .and. !lEmiNfi)  //.or. (oFolder011:noption == 6 .and. lNegPag .and. !lEmiNfi)
	oAvancar:cCaption := STR0064 //Finalizar
Else
	oAvancar:cCaption := STR0058 +" >>" //avancar
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FINAL011     ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Finaliza o atendimento                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FINAL011(nOpc)

Local lRet := .f.
Local lCEV := .t.
Local lImpr:= .t.
Local cGCFVCEV := ""
Local cGCPVCEV := ""
Local lMsSlvHelp := .f.
Local cTIPOPAGTO := GetNewPar("MV_TPVEITR","VEICULOS")
Local cNAteExc   := VV9->VV9_NUMATE
Local nTamObs, cAuxObs, nPosObs, Cont
Local lMosTAprov := .f. // Se .t. mostra Aprovacao Na finalizacao do Atendimento
Local cChaAval := ""//Grava o chassi para alteraaco avaliacao de veiculo para mudar para nao aprovada. - Rafael
Local cQuery := ""
Local cQAlias:= "SQLVAZ"
Local	nVJ1Numtra := 0

Private lMsErroAuto := .f.
Private lMsHelpAuto := .t.
Private cSerie := cNumero := ""
Private lOk := .t.

Default nOpc := 1


if getnewpar("MV_SELFEST","S") == "N" // Se S ,permite selecao de veiculo fora do estoque. Se N nao permite.
	if aStruVV1[oLbox:nAt,1] == .f.
		MsgInfo(STR0063 ,STR0012) //Selecione um Veiculo ou uma Marca/Modelo... -- Atencao
	    Return(.f.)
	Endif
Endif
if lVisual
	Return(.t.)
Endif

if lExclui
    if VV0->VV0_SITNFI == "2"
       MsgInfo(STR0263,STR0012)
       Return(.f.)
    Endif 
    if !Empty(VVA->VVA_CHASSI)
	    VV1->(DbSetOrder(2))
	    VV1->(DbSeek(xFilial("VV1")+VVA->VVA_CHASSI))
	    VV1->(DbSetOrder(1))
	    if VV1->VV1_SITVEI <> "1" .and. VV1->VV1_SITVEI <> "0"
	       MsgInfo(STR0264,STR0012)
	       Return(.f.)
	    Endif   
    endif
	if nOpc <> 1
		MsgInfo(STR0067,STR0012) //Confirme a exclusao no botao de ok! - Atencao
		Return(.f.)
	Else
		If MsgYesNo(OemToAnsi(STR0068),OemToAnsi(STR0069))//Cancela Atendimento? - Cancelamento...
			Begin Transaction
				lOk := FS_EXCATE()
			End Transaction
			if !lOk
				Return(.f.)
			Endif
			if lMsErroauto
				MostraErro()
			Else
				
				FGX_AMOVVEI(xFilial("VV1"),M->VV0_CHASSI)				
			
				// Exclui VAZ (Avaliacao de Veiculo Usado) na Exclusao do Atendimento
				DbSelectArea("VAZ")
				DbSetOrder(4)
				If DbSeek( xFilial("VAZ") + cNAteExc )
					If MsgYesNo(STR0335,STR0012) // Deseja excluir as avaliacoes de veiculos usados referentes a esse Atendimento ? / Atencao 
						While !Eof() .and. xFilial("VAZ") == VAZ->VAZ_FILIAL .and. cNAteExc == VAZ->VAZ_NUMATE
							RecLock("VAZ",.f.,.t.)
							DbDelete()
							MsUnlock()
							DbSkip()
						End
					Else
						// Gravar VAZ (Avaliacao de Veiculo Usado) - Limpa link das avaliacoes com o Atendimento
						DbSelectArea("VAZ")
						DbSetOrder(4)
						While .t.
							If DbSeek( xFilial("VAZ") + cNAteExc )
								RecLock("VAZ",.F.)
									If VAZ->VAZ_APROVA == "2" // Avaliacao com Veiculo Negociado
										VAZ->VAZ_APROVA := "1" // Avalicao Aprovada
									EndIf
									VAZ->VAZ_NUMATE := "" // Limpa link com o Atendimento
								MsUnlock()
							Else
								Exit
							EndIf
						EndDo
					EndIf
				EndIf
			EndIf
		EndIf
		Return(!lMsErroauto)
	Endif
Endif
if ExistBlock("VM011GVA")
	If !ExecBlock("VM011GVA",.f.,.f.)
		Return .f.
	Endif
Endif

If !lEmiNfi
	If nOpc == 3
		MsgInfo("Usuario sem permissao para Emitir NF!",STR0012)
		Return .f.
	Endif
Endif

if M->VV9_STATUS == "C"
	MsgInfo(STR0070 ,STR0012) //Atendimento nao pode ser fechado pois esta cancelado! - Atencao
	Return(.f.)
Endif

if M->VV9_STATUS == "F"
	MsgInfo(STR0071 ,STR0012) //Atendimento ja finalizado! - Atencao
	Return(.f.)
Endif

If FS_VERAPROV(M->VV9_NUMATE)  // Verifica se existe outro Atendimento ja pre-aprovado/aprovado para o mesmo Veiculo (CHASSI)
	return(.f.)
EndIf

if M->VV9_STATUS == "T" .and. lCaixaNF
	MsgInfo(STR0072 ,STR0012) //Atendimento ja finalizado para o caixa! - Atencao
	Return(.f.)
Endif

if M->VV9_STATUS == "R" .and. VV9->VV9_STATUS == "R"
   M->VV9_STATUS := "A"
//	MsgInfo(STR0073 ,STR0012) //Atendimento reprovado nao pode ser finalizado! - Atencao
//	Return(.f.)
Endif

//if M->VV0_SIMULA == "1" .and. !(M->VV0_TIPFAT $ "2/3") .and. nOpc <> 1
if M->VV0_OPEMOV == "1" .and. !(M->VV0_TIPFAT $ "2/3") .and. nOpc <> 1
	MsgInfo(STR0074 ,STR0012) //Esta e uma simulacao, nao pode ser finalizada! - Atencao
	Return(.f.)
Endif
/*
IF M->VV0_CATVEN == "7" .AND. nOpc <> 1
	DbSelectArea("SA6")
	DBSetOrder(1)
	if !DBSeek(xFilial("SA6")+M->VV0_CBCOAA+M->VV0_ABCOAA)
		MsgInfo(STR0075 ,STR0012) //Na modalidade leasing e necessario o preenchimento do banco alienado. Impossivel continuar - Atencao
		return .f.
	endif
	DBSelectArea("SA1")
	if !DBSeek(xFilial("SA1")+SA6->A6_CODCLI+SA6->A6_LOJCLI)
		MsgInfo(STR0076 ,STR0012) //O Banco do Leasing nao esta relacionado a nenhum cliente. Verifique o cadastro do banco. - Atencao
		return .f.
	endif
endif
*/
if M->VV9_STATUS <> "L" .and. nOpc == 3
	if !lEmiNfi .and. lPedApr .and. nOpc == 3
		nOpc := 2
	Elseif !lEmiNfi .and. !lPedApr .and. nOpc == 3
		nOpc := 1
	Endif
	
	if nOpc == 3 .and. !lAutFat
		if lPedApr
			nOpc := 2
		Else
			nOpc := 1
		Endif
	Endif
Endif

if !lFatura .and. nOpc > 2
	MsgInfo(STR0077 +If(!Empty(cBlqFat),chr(13)+chr(10)+chr(13)+chr(10)+cBlqFat,""),STR0012) //Veiculo nao pode ser faturado devido a sua situacao!  - Atencao
	Return(.f.)
Endif

//if nOpc > 1 .and. VV1->VV1_SITVEI == "6" .and. !(M->VV0_RESERV == "1" .and. alltrim(VV1->VV1_DTHVAL) == alltrim(Dtoc(M->VV0_DATVAL) + "/" + M->VV0_HORVAL))
//   MsgInfo("Veiculo esta reservado por outro atendimento !","Atencao...")
//   Return(.f.)
//Endif

if M->VV0_TIPFAT == "2"
	if !FS_FATDIR()
		Return(.f.)
	Endif
Endif

if Empty(M->VV9_NOMVIS)
	MsgInfo(STR0078 ,STR0012) //Necessario informar o nome do visitante! - Atencao
	Return(.f.)
Endif

if Empty(M->VV9_TELVIS)
	MsgInfo(STR0079 ,STR0012) //Necessario informar o telefone do visitante! - Atencao
	Return(.f.)
Endif

if !lLibVei .and. !FS_VALMIN(.t.,.f.)
	MsgInfo(STR0080 +" "+Transform(nValorMin,"@E 999,999,999.99")+" "+ STR0081,STR0012) //Valor para faturamento menor que o valor minimo de R$ - Aprovado - Atencao
	Return(.f.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rubens - 23/11/2009                                                                   ³
//³Verifica se vai houve alteracao na observacao, na parte que ja estava gravada no Banco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aObsGravada) > 0
	nPosObs := 0
	nTamObs := TamSx3("VV9_OBSERV")[1]
	cAuxObs := E_MSMM(VV9->VV9_OBSMEM,nTamObs)
	// Descobre qual eh a linha que comeca o log de alteracao 
	For nPosObs := 1 to MLCount(M->VV9_OBSERV,nTamObs)
		if Left(MemoLine(M->VV9_OBSERV,nTamObs,nPosObs),3) $ "___,***"
			Exit
		endif
	Next nPosObs
	// 
	nPosObs--
	// Verifica se foi excluida alguma linha da observacao 
	if (MLCount(M->VV9_OBSERV,nTamObs) - nPosObs) <> Len(aObsGravada)
		MsgStop(STR0311,STR0265) // Histórico de Observação não pode ser alterado !
		Return(.f.)
	endif

	// Verifica linha por linha se esta com o mesmo conteudo carregado no inicio da alteracao do atendimento 
	For Cont := 1 to Len(aObsGravada)
		if MemoLine(M->VV9_OBSERV,nTamObs,Cont+nPosObs) <> aObsGravada[Cont]
			MsgStop(STR0311,STR0265) // Histórico de Observação não pode ser alterado !
			Return(.f.)
		endif
	Next Cont

Endif

/*
if M->VV0_TIPFAT == "3" .and. nOpc > 1
If MsgYesNo(OemToAnsi("Finaliza Venda?"),OemToAnsi(STR0012)) //Atencao
if (VV1->VV1_RESERV == "3" .or. VV1->VV1_RESERV == "1") .and. M->VV0_RESERV <> "1" .and. Empty(M->VV0_DATVAL)
MsgInfo("Veiculo ja esta reservado para outro atendimento !","Atencao...")
Return(.f.)
Endif
Begin Transaction
FS_GRVATE1()
//Ponto de entrada para avisar vendedor que foi liberado
If ExistBlock("CHKFAT011")
if !ExecBlock("CHKFAT011",.f.,.f.)
Return(.f.)
Endif
Endif
if FS_LIBATE() .and. FS_CLI011(.f.)
if FS_GERATIT()
STATUS011("T")
dbSelectarea("VV9")
dbSetOrder(1)
RecLock("VV9",.F.)
VV9->VV9_STATUS := M->VV9_STATUS
MsUnlock()

if !Empty(M->VV0_CHASSI)
dbSelectarea("VV1")
dbSetOrder(2)
if dbSeek(xFilial("VV1")+M->VV0_CHASSI)
RecLock("VV1",.f.)
VV1->VV1_RESERV := "3" // Reservado
MsUnlock()
Endif
Endif

Endif
Endif
if lMsErroAuto
DisarmTransaction()
Break
Endif
End Transaction
if lMsErroauto
MostraErro()
Endif
Endif
Return(.t.)
Endif
*/

// Manoel - 03/02/2010
If VAI->(FieldPos("VAI_TELAPR")) <> 0
	If nOpc == 3 .and. lLibVei .and. M->VV9_STATUS != "L"
		If VAI->VAI_TELAPR == "1" // Se 1 = Sim, mostra tela de Aprovacao na Finalizacao do Atendimento
		   lMosTAprov := .t.
		   nOpc := 2
		Else
	   		FS_GRVDTAPR(1) // Gravar a Data da Aprovacao (1=M->VV0_DATAPR)
		Endif
	Endif
Endif          

if M->VV0_OPEMOV == "8" // Fat. Entrega Futura
	If FieldPos("VJ1_NUMTRA") > 0
		cQryAlias := "SQLVJ1"
		cQuery := "SELECT COUNT(*) CNT FROM "+RetSqlName("VJ1")+" WHERE VJ1_FILIAL ='"+xFilial("VJ1")+"' AND D_E_L_E_T_=' ' AND VJ1_NUMTRA = '"+ M->VV0_NUMTRA+ "'"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )
		nVJ1Numtra := (cQryAlias)->(CNT)
		(cQryAlias)->(dbCloseArea())
	Endif
/*   If nVJ1Numtra == 0
		cQryAlias := "SQLVJ1"
		cQuery := "SELECT * FROM "+RetSqlName("VJ1")+" WHERE VJ1_FILIAL ='"+xFilial("VJ1")+"' AND D_E_L_E_T_=' ' AND VJ1_MODVEI = '"+cModVei+"'AND VJ1_CODMAR = '"+cCodMar+"' AND VJ1_NUMNFI = '000000' AND VJ1_NUMTRA = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )
		(cQryAlias)->(dbGoTop())
		If !(cQryAlias)->(eof())
			If MsgYesNo("Deseja Selecionar o Veiculo no Progresso?",OemToAnsi(STR0012))
				Veivc180(cCodMar,cModVei,.t.)
				lMsErroAuto := .f.
			Endif
		Endif
		(cQryAlias)->(dbCloseArea())
	Endif
*/
   If nOpc == 3
		If VV9->VV9_STATUS $ "L.O"
		   If Empty(M->VV0_CHASSI)
				MsgInfo("Veiculo de Entrega Futura ainda nao possui CHASSI! Impossivel Continuar!")
				Return(.f.)    
			Else
				M->VV0_TIPFAT := "0"	
				M->VV0_OPEMOV := "0"	
			Endif
		Else
			nOpc := 2
		Endif
	Endif
Endif
if nOpc == 1
	DbSelectArea("VV9")
	DbSetOrder(1)
	If DbSeek( xFilial("VV9") + M->VV9_NUMATE )
		If VV9->VV9_STATUS == "F" //Atendimento ja finalizado! <<< NAO GRAVAR >>>
			Return(.t.)
		Endif
	Endif
	If MsgYesNo(OemToAnsi(STR0082),OemToAnsi(STR0012)) //Grava Atendimento? - Atencao
		Begin Transaction
		If nVJ1Numtra == 0 .and. FieldPos("VJ1_NUMTRA") > 0
			cQryAlias := "SQLVJ1"
			cQuery := "SELECT * FROM "+RetSqlName("VJ1")+" WHERE VJ1_FILIAL ='"+xFilial("VJ1")+"' AND D_E_L_E_T_=' ' AND VJ1_MODVEI = '"+cModVei+"'AND VJ1_CODMAR = '"+cCodMar+"' AND VJ1_NUMNFI = '000000' AND VJ1_NUMTRA = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )
			(cQryAlias)->(dbGoTop())
			If !(cQryAlias)->(eof())
				If MsgYesNo("Deseja Selecionar o Veiculo no Progresso?",OemToAnsi(STR0012))
					Veivc180(cCodMar,cModVei,.t.)
					lMsErroAuto := .f.
				Endif
			Endif
			(cQryAlias)->(dbCloseArea())
		Endif
		Processa({|| FS_GRVATE1() })
		End Transaction
		IMPPRO011()
		lRet := .t.
	Endif
ElseIf nOpc == 2
	If MsgYesNo(OemToAnsi(STR0083),OemToAnsi(STR0012)) //Finaliza atendimento? - Atencao

		Begin Transaction
		if FS_LIBATE() .and. FS_CLI011(.f.)
			FS_GRVATE1()
			
//			if lTit
				lRet := .t.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rubens - Retirado em 08/06/2010, pois na Harley estava exibindo ³
//³ o atendimento como CANCELADO e nao PENDENTE APROVACAO           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//				if lLibVei .and. !lMosTAprov .and. M->VV0_OPEMOV != "8"
//					lTit := .t.
//					if GetNewPar("MV_TITAPR","S") <> "S"
//						lTit := FS_GERATIT()
//					Endif
//					M->VV9_STATUS := "T"
//					STATUS011("T")
//				Else
					M->VV9_STATUS := "P"
					STATUS011("P",.f.)
//				Endif
				dbSelectarea("VV9")
				dbSetOrder(1)
				RecLock("VV9",.F.)
				VV9->VV9_STATUS := M->VV9_STATUS
				VV9->VV9_MOTIVO := ""
				VV9->VV9_DATCAN := ctod("")
				MsUnlock()
				
				/*
				dbSelectarea("VV1")
				dbSetOrder(2)
				if dbSeek(xFilial("VV1")+M->VV0_CHASSI)
				RecLock("VV1",.f.)
				VV1->VV1_SITVEI := "1" // Vendido
				VV1->VV1_DATVEN := ddatabase
				If !Empty(M->VV9_CODCLI)
				VV1->VV1_PROANT := VV1->VV1_PROATU
				VV1->VV1_LJPANT := VV1->VV1_LJPATU
				VV1->VV1_PROATU := M->VV9_CODCLI
				VV1->VV1_LJPATU := M->VV9_LOJA
				EndIf
				MsUnlock()
				Endif
				*/
				
				if M->VV0_TIPFAT <> "3"
					ORDSER011(3)
				Endif
//			Endif
		Else
			lRet := .f.
		Endif
		if lMsErroAuto
			DisarmTransaction()
			Break
		Endif
		End Transaction
		if lMsErroAuto
			MostraErro()
		Else
			If lRet
				If VV9->VV9_STATUS == "P"
					VEIVM130TAR(VV9->VV9_NUMATE,"4")// 0-Verifica/Valida / 1-Gravacao / 2-Finalizacao / 3-Pelo Usuario / 4-Pendente Aprovacao / 5-Pre-Aprovado / 6-Aprovado / 7-Cancela Reserva / 8-Cancela Atendimento
					//valida regra para tarefas - Rafael Goncalves - 28/01/2010
					If FindFunction("VA400REGRA")
						//if VV0->VV0_RESERV $ "1/3"
							VA400REGRA(VV9->VV9_NUMATE,"2")// 1 - Gravacao / 2- Pendente / 3- pre-aprovado / 4 aprovado
						//EndIF
					EndIf
				EndIf
			EndIf
		Endif      
		If lMosTAprov
			VM011_Apr(.f.)
		Endif
	Endif
	
ElseIf nOpc == 3

	if Empty(M->VV9_CODCLI) .or. Empty(M->VV9_LOJA)
		MsgInfo(STR0099 ,STR0012) //Cliente nao informado ou cliente nao cadastrado... - Atencao
		Return .f.
	Endif

	If "V" $ GetMv("MV_CHKCRE")
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+M->VV9_CODCLI+M->VV9_LOJA)
		If !MaAvalCred(M->VV9_CODCLI,M->VV9_LOJA,(M->VV0_VALTOT+FG_AVALCRED(M->VV9_CODCLI,M->VV9_LOJA)),1,.T.)
			lMsSlvHelp  := lMsHelpAuto // Salva lMsHelpAuto para voltar
			lMsHelpAuto := .f. // Coloca .f. para poder mostrar o HELP LIMITECRED na tela.
			Help("  ",1,"LIMITECRED")
			lMsHelpAuto := lMsSlvHelp // Volta lMsHelpAuto
			Return .f.
		EndIf
	EndIf

	if FS_CHKINF()
	                             
		///  VALIDA TAREFAS REFERENTE AO ATENDIMENTO DE VEICULOS - Andre Luis Almeida - 21/09/2009 ///
		If FindFunction("VEIVM130TAR") .and. M->VV0_OPEMOV != "1"
			VEIVM130TAR(M->VV0_NUMTRA,"2") // 0-Verifica/Valida / 1-Gravacao / 2-Finalizacao / 3-Pelo Usuario / 4-Pendente Aprovacao / 5-Pre-Aprovado / 6-Aprovado / 7-Reserva / 8-Cancela Reserva / 9-Cancela Atendimento
			If !VEIVM130TAR(M->VV0_NUMTRA,"0") // 0-Verifica/Valida / 1-Gravacao / 2-Finalizacao / 3-Pelo Usuario / 4-Pendente Aprovacao / 5-Pre-Aprovado / 6-Aprovado / 7-Reserva / 8-Cancela Reserva / 9-Cancela Atendimento
				return .f.
			EndIf
		EndIf
		/////////////////////////////////////////////////////////////////////////////////////////////

		If MsgYesNo(if(lGeraNF,OemToAnsi(STR0084),OemToAnsi("Gera Pedido de Venda?")),OemToAnsi(STR0012)) //Gera Nota Fiscal? - Atencao
			lCEV := .t.
			if FS_LIBATE()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava 1 fase dos arquivos de Cabecalho e detalhes do atendimento    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FS_GRVATE1()              
				
				//Ponto de Entrada - Depois da gravacao do Atendimento
				If ExistBlock("VM011DGA")
					If !ExecBlock("VM011DGA",.f.,.f.)
						return .f.
					Endif
				Endif
				
				if M->VV0_TIPFAT <> "2"
					
					If lGeraNF .and. FM_NRNFFP(1) // 1a Chamada da tela que verifica NF quando Formulario Proprio
						
						lCEV := .f.
						
					Else
						
						Begin Transaction
						cNota := cNumero
						
						Processa({|| FS_GERANOTA() })
						lRet := !lMsErroAuto
						if lMsErroAuto
							lCEV := .f.
							lImpr:= .f.
							DisarmTransaction()
							Break
						Endif
						
						ORDSER011(3)
						
						If ExistBlock("VM011DNF")
							ExecBlock("VM011DNF",.f.,.f.)
						EndIf

						//////////////////////////////////////////////
						// Andre Luis Almeida      //    16/07/09   //
						// Inclusao de Orcamento com Acao de Vendas //
						//////////////////////////////////////////////
						If !FS_INCORC()
							lCEV := .f.
							lImpr:= .f.
							DisarmTransaction()
							Break
						EndIf

						If !lGeraNF
							DbselectArea("SC5")
							ConfirmSx8()
							M->VV9_STATUS := "F"
							dbSelectarea("VV9")
							dbSetOrder(1)
							RecLock("VV0",.F.)
							VV0->VV0_NUMPED := SC5->C5_NUM
							VV0->VV0_STATUS := M->VV9_STATUS
							MsUnlock()
							RecLock("VV9",.F.)
							VV9->VV9_STATUS := M->VV9_STATUS
							MsUnlock()
						Endif            

						
						End Transaction

//////////////////////////////////////
						if !lMsErroAuto
			                
							// Gravar CODIGO DA CONCESSIONARIA que vendeu o Veiculo //
							If VV1->(FieldPos("VV1_CODCON")) <> 0
								VVK->(dbSetOrder(2))
								VVK->(dbSeek(xFilial("VVK")+SM0->M0_CGC))
								VV1->(dbSetOrder(2))
								If VV1->(dbSeek(xFilial("VV1")+VVA->VVA_CHASSI))
									RecLock("VV1",.f.)
										VV1->VV1_CODCON := VVK->VVK_CODCON
									MsUnLock()
								EndIf
							EndIf
							//////////////////////////////////////////////////////////
							
							If lCEV 
								// CEV - Deletar agenda de PERSEGUICAO em aberto quando Finalizar Atendimento - Andre Luis Almeida - 17/06/2009 // 
								cGCPVCEV := Alltrim(GetNewPar("MV_GCPVCEV"," "))
								If !Empty( cGCPVCEV )
									If ( VC1->(FieldPos("VC1_TIPORI")) <> 0 )
										DbSelectArea("VC1")
										DbSetOrder(3) // VC1_FILIAL+VC1_TIPAGE+VC1_CODCLI+VC1_LOJA+DTOS(VC1_DATAGE)
										DbSeek( xFilial("VC1") + left(cGCPVCEV,1) + VV9->VV9_CODCLI + VV9->VV9_LOJA )
										While !Eof() .and. xFilial("VC1") == VC1->VC1_FILIAL .and. left(cGCPVCEV,1) == VC1->VC1_TIPAGE .and. VV9->VV9_CODCLI + VV9->VV9_LOJA == VC1->VC1_CODCLI + VC1->VC1_LOJA
											If VC1->VC1_TIPORI == "V" .and. Alltrim(VC1->VC1_ORIGEM) == Alltrim(VV9->VV9_NUMATE) .and. Empty(VC1->VC1_DATVIS)
												RecLock("VC1",.f.,.t.)
													DbDelete()
												MsUnlock()
											EndIf
											DbSelectArea("VC1")
											DbSkip()
										End
									Else  
										// Bloco Temporario 24/02/2010 / Ate subir UPDVEI70 campo VC1_TIPORI - bloco correto esta no IF acima //
										DbSelectArea("VC1")
										DbSetOrder(3) // VC1_FILIAL+VC1_TIPAGE+VC1_CODCLI+VC1_LOJA+DTOS(VC1_DATAGE)
										DbSeek( xFilial("VC1") + left(cGCPVCEV,1) + VV9->VV9_CODCLI + VV9->VV9_LOJA )
										While !Eof() .and. xFilial("VC1") == VC1->VC1_FILIAL .and. left(cGCPVCEV,1) == VC1->VC1_TIPAGE .and. VV9->VV9_CODCLI + VV9->VV9_LOJA == VC1->VC1_CODCLI + VC1->VC1_LOJA
											If Alltrim(VC1->VC1_ORIGEM) == Alltrim(VV9->VV9_NUMATE) .and. Empty(VC1->VC1_DATVIS)
												RecLock("VC1",.f.,.t.)
													DbDelete()
												MsUnlock()
											EndIf
											DbSelectArea("VC1")
											DbSkip()
										End
									EndIf
									//////////////////////////////////////////////////////////////////////////////////////////////////////////////
								EndIf
								// CEV - Agenda Contato quando Finaliza Atendimento - POS-VENDA - Satisfacao do Cliente - Andre Luis Almeida - 27/02/2008 //
								cGCFVCEV := Alltrim(GetNewPar("MV_GCFVCEV",""))
								If !Empty( cGCFVCEV )
									FS_AGENDA( Left(cGCFVCEV,1) ,;
									( dDataBase+Val(Substr(cGCFVCEV,2,3)) ) ,;
									Substr(cGCFVCEV,5,6) ,;
									VV9->VV9_CODCLI ,;
									VV9->VV9_LOJA ,;
									"" ,;
									VV9->VV9_NUMATE ,;
									"" ,;
									STR0085 +" "+ VV9->VV9_NUMATE +" "+ STR0086 +" "+VV1->VV1_CHASSI+" - "+VV1->VV1_CODMAR+" "+VV2->VV2_DESMOD ,;
									"",;
									"" ) //Atendimento FINALIZADO  - Veiculo:
								EndIf
								// Gravar VAZ (Avaliacao de Veiculo Usado) na Finalizacao do Atendimento
								dbSelectArea("VS9")
								dbSetOrder(1)
								If dbSeek(xFilial("VS9")+left(VV9->VV9_NUMATE+space(30),len(VS9->VS9_NUMIDE)))
									While !Eof() .and. xFilial("VS9") == VS9->VS9_FILIAL .and. left(VV9->VV9_NUMATE+space(30),len(VS9->VS9_NUMIDE)) == VS9->VS9_NUMIDE
										If VS9->VS9_TIPPAG == cTIPOPAGTO
											//DbSelectArea("VAZ")
											//DbSetOrder(5)
											//If DbSeek( xFilial("VAZ") + VS9->VS9_REFPAG )
												cQuery := "SELECT VAZ.R_E_C_N_O_ VAZRECNO FROM "+RetSqlName("VAZ")+" VAZ  WHERE "
												cQuery += "VAZ.VAZ_FILIAL='"+xFilial("VAZ")+"' AND VAZ.VAZ_CODIGO='"+VS9->VS9_REFPAG+"' AND VAZ.VAZ_APROVA='1' AND "
											    cQuery += "VAZ.D_E_L_E_T_=' ' ORDER BY VAZ.VAZ_REVISA  desc"
												dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
											    IF !( cQAlias )->( Eof() )
											    	DbSelectArea("VAZ")
											    	DbGoTo(( cQAlias )->( VAZRECNO ))	
													cChaAval := VAZ->VAZ_CHASSI
													RecLock("VAZ",.F.)
														VAZ->VAZ_APROVA := "2" // Avaliacao com Veiculo Negociado
														VAZ->VAZ_NUMATE := VV9->VV9_NUMATE
														VAZ->VAZ_VALCOM := VS9->VS9_VALPAG
													MsUnlock()
											    	( cQAlias )->( dbCloseArea() )
													DbSelectArea("VAZ")
											  	EndIf
										   //	EndIf
										   Exit
										EndIf
										DbSelectArea("VS9")
										DbSkip()
									End
								EndIf
								//procura as outras avaliacoes para o veiculo e altera o VAZ_APROVA para 0=nao - Rafael/Manoel - VIAMAR 12/02/10
								//Solicitacao VIAMAR - Robson Luiz (RLEG)
							   	If cChaAval <> ""
									DbSelectArea("VAZ")
									DbSetOrder(1)     
									If dbSeek(xFilial("VAZ")+left(cChaAval+space(len(VAZ->VAZ_CHASSI)),len(VAZ->VAZ_CHASSI)))
										While !Eof() .and. xFilial("VAZ") == VAZ->VAZ_FILIAL .and. left(cChaAval+space(len(VAZ->VAZ_CHASSI)),len(VAZ->VAZ_CHASSI)) == VAZ->VAZ_CHASSI .and. VAZ->VAZ_APROVA == "1"
											RecLock("VAZ",.F.)
												VAZ->VAZ_APROVA := "0" // Nao Aprovado.
											MsUnlock()
											DbSelectArea("VAZ")
											DbSkip()
								   		End
								   	EndIF
								EndIf 
								
								
								// Calcula automaticamente a Data de Entrega do Veiculo
								FS_CALCDTENT("1",VV9->VV9_NUMATE,.f.)
							EndIf
						EndIf
//////////////////////////////////////
						If lImpr
							if M->VV0_TIPFAT == "2" //Faturamento Direto
								if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) <> "S"
									If ExistBlock("NFSERVIC") // Programa de Nota Fiscal de Diversos
										ExecBlock("NFSERVIC",.f.,.f.,{VV0->VV0_NUMNFI,VV0->VV0_SERNFI,"CFD"})
									Endif
								EndIF
							Elseif !M->VV0_OPEMOV $ "234" // Venda/Remessa/Transferencia/Devolucao
								if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) <> "S"
									dbSelectArea("VV0")
									dbSetOrder(1)
									dbSeek(xFilial("VV0")+VV9->VV9_NUMATE)
									If ExistBlock("NFSAIVEI")
										ExecBlock("NFSAIVEI",.f.,.f.,{SF2->F2_DOC,SF2->F2_SERIE})
										
										dbSelectArea("SA6")
										dbSetOrder(1)
										if dbSeek(xFilial("SA6")+VV0->VV0_CODBCO)
											cDesBco := ""
											cObs1   := Substr(SA6->A6_MENSAGE,001,49)
											cObs2   := Substr(SA6->A6_MENSAGE,050,49)
											cObs3   := Substr(SA6->A6_MENSAGE,100,50)
											if ExistBlock("BLQCOB")
												ExecBlock("BLQCOB",.f.,.f.,{SF2->F2_DOC,,,,SF2->F2_PREFIXO,"1",cObs1,cObs2,cObs3,VV0->VV0_CODBCO})
											Endif
										Endif
									Endif
								EndIF
							Endif
						Endif
						
					EndIf
					
				EndIf
				
			Else
				lRet := .f.
				lCEV := .f.
			Endif
			if lMsErroAuto
				MostraErro()
				lCEV := .f.
			Endif
         /*
			if !lMsErroAuto
                
				// Gravar CODIGO DA CONCESSIONARIA que vendeu o Veiculo //
				If VV1->(FieldPos("VV1_CODCON")) <> 0
					VVK->(dbSetOrder(2))
					VVK->(dbSeek(xFilial("VVK")+SM0->M0_CGC))
					VV1->(dbSetOrder(2))
					If VV1->(dbSeek(xFilial("VV1")+VVA->VVA_CHASSI))
						RecLock("VV1",.f.)
							VV1->VV1_CODCON := VVK->VVK_CODCON
						MsUnLock()
					EndIf
				EndIf
				//////////////////////////////////////////////////////////
				
				If lCEV 
					// CEV - Deletar agenda de PERSEGUICAO em aberto quando Finalizar Atendimento - Andre Luis Almeida - 17/06/2009 // 
					cGCPVCEV := Alltrim(GetNewPar("MV_GCPVCEV"," "))
					If !Empty( cGCPVCEV )
						If ( VC1->(FieldPos("VC1_TIPORI")) <> 0 )
							DbSelectArea("VC1")
							DbSetOrder(3) // VC1_FILIAL+VC1_TIPAGE+VC1_CODCLI+VC1_LOJA+DTOS(VC1_DATAGE)
							DbSeek( xFilial("VC1") + left(cGCPVCEV,1) + VV9->VV9_CODCLI + VV9->VV9_LOJA )
							Do While !Eof() .and. xFilial("VC1") == VC1->VC1_FILIAL .and. left(cGCPVCEV,1) == VC1->VC1_TIPAGE .and. VV9->VV9_CODCLI + VV9->VV9_LOJA == VC1->VC1_CODCLI + VC1->VC1_LOJA
								If VC1->VC1_TIPORI == "V" .and. Alltrim(VC1->VC1_ORIGEM) == Alltrim(VV9->VV9_NUMATE) .and. Empty(VC1->VC1_DATVIS)
									RecLock("VC1",.f.,.t.)
										DbDelete()
									MsUnlock()
								EndIf
								DbSelectArea("VC1")
								DbSkip()
							EndDo
						Else  
							// Bloco Temporario 24/02/2010 / Ate subir UPDVEI70 campo VC1_TIPORI - bloco correto esta no IF acima //
							DbSelectArea("VC1")
							DbSetOrder(3) // VC1_FILIAL+VC1_TIPAGE+VC1_CODCLI+VC1_LOJA+DTOS(VC1_DATAGE)
							DbSeek( xFilial("VC1") + left(cGCPVCEV,1) + VV9->VV9_CODCLI + VV9->VV9_LOJA )
							Do While !Eof() .and. xFilial("VC1") == VC1->VC1_FILIAL .and. left(cGCPVCEV,1) == VC1->VC1_TIPAGE .and. VV9->VV9_CODCLI + VV9->VV9_LOJA == VC1->VC1_CODCLI + VC1->VC1_LOJA
								If Alltrim(VC1->VC1_ORIGEM) == Alltrim(VV9->VV9_NUMATE) .and. Empty(VC1->VC1_DATVIS)
									RecLock("VC1",.f.,.t.)
										DbDelete()
									MsUnlock()
								EndIf
								DbSelectArea("VC1")
								DbSkip()
							EndDo
						EndIf
						//////////////////////////////////////////////////////////////////////////////////////////////////////////////
					EndIf
					// CEV - Agenda Contato quando Finaliza Atendimento - POS-VENDA - Satisfacao do Cliente - Andre Luis Almeida - 27/02/2008 //
					cGCFVCEV := Alltrim(GetNewPar("MV_GCFVCEV",""))
					If !Empty( cGCFVCEV )
						FS_AGENDA( Left(cGCFVCEV,1) , ( dDataBase+Val(Substr(cGCFVCEV,2,3)) ) , Substr(cGCFVCEV,5,6) , VV9->VV9_CODCLI , VV9->VV9_LOJA , STR0085 +" "+ VV9->VV9_NUMATE +" "+ STR0086 +" "+VV1->VV1_CHASSI+" - "+VV1->VV1_CODMAR+" "+VV2->VV2_DESMOD , VV9->VV9_NUMATE ) //Atendimento FINALIZADO  - Veiculo:
					EndIf
					// Gravar VAZ (Avaliacao de Veiculo Usado) na Finalizacao do Atendimento
					dbSelectArea("VS9")
					dbSetOrder(1)
					If dbSeek(xFilial("VS9")+left(VV9->VV9_NUMATE+space(30),len(VS9->VS9_NUMIDE)))
						Do While !Eof() .and. xFilial("VS9") == VS9->VS9_FILIAL .and. left(VV9->VV9_NUMATE+space(30),len(VS9->VS9_NUMIDE)) == VS9->VS9_NUMIDE
							If VS9->VS9_TIPPAG == cTIPOPAGTO
								//DbSelectArea("VAZ")
								//DbSetOrder(5)
								//If DbSeek( xFilial("VAZ") + VS9->VS9_REFPAG )
									cQuery := "SELECT VAZ.R_E_C_N_O_ VAZRECNO FROM "+RetSqlName("VAZ")+" VAZ  WHERE "
									cQuery += "VAZ.VAZ_FILIAL='"+xFilial("VAZ")+"' AND VAZ.VAZ_CODIGO='"+VS9->VS9_REFPAG+"' AND VAZ.VAZ_APROVA='1' AND "
								    cQuery += "VAZ.D_E_L_E_T_=' ' ORDER BY VAZ.VAZ_REVISA  desc"
									dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
								    IF !( cQAlias )->( Eof() )
								    	DbSelectArea("VAZ")
								    	DbGoTo(( cQAlias )->( VAZRECNO ))	
										cChaAval := VAZ->VAZ_CHASSI
										RecLock("VAZ",.F.)
											VAZ->VAZ_APROVA := "2" // Avaliacao com Veiculo Negociado
											VAZ->VAZ_NUMATE := VV9->VV9_NUMATE
											VAZ->VAZ_VALCOM := VS9->VS9_VALPAG
										MsUnlock()
								    	( cQAlias )->( dbCloseArea() )
										DbSelectArea("VAZ")
								  	EndIf
							   //	EndIf
							   Exit
							EndIf
							DbSelectArea("VS9")
							DbSkip()
						EndDo
					EndIf
					//procura as outras avaliacoes para o veiculo e altera o VAZ_APROVA para 0=nao - Rafael/Manoel - VIAMAR 12/02/10
					//Solicitacao VIAMAR - Robson Luiz (RLEG)
				   	If cChaAval <> ""
						DbSelectArea("VAZ")
						DbSetOrder(1)     
						If dbSeek(xFilial("VAZ")+left(cChaAval+space(len(VAZ->VAZ_CHASSI)),len(VAZ->VAZ_CHASSI)))
							Do While !Eof() .and. xFilial("VAZ") == VAZ->VAZ_FILIAL .and. left(cChaAval+space(len(VAZ->VAZ_CHASSI)),len(VAZ->VAZ_CHASSI)) == VAZ->VAZ_CHASSI .and. VAZ->VAZ_APROVA == "1"
								RecLock("VAZ",.F.)
									VAZ->VAZ_APROVA := "0" // Nao Aprovado.
								MsUnlock()
								DbSelectArea("VAZ")
								DbSkip()
					   		EndDo
					   	EndIF
					EndIf 
					
					
					// Calcula automaticamente a Data de Entrega do Veiculo
					FS_CALCDTENT("1",VV9->VV9_NUMATE,.f.)
				EndIf
			EndIf
			*/
		Endif
	Endif
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_EXCATE    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclusao do atendimento                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_EXCATE(nOpc)

Local Cont
Local aPref := {SM0->M0_CODFIL+"E",SM0->M0_CODFIL+"F",PrefTIT()}
Local cNumero := iif(Empty(VV0->VV0_NUMNFI),Right(M->VV9_NUMATE,nTamNota),VV0->VV0_NUMNFI)

if ExistBlock("VLDEXC011")
	if !ExecBlock("VLDEXC011",.f.,.f.)
		Return .f.
	Endif
Endif

MV_PAR01 := "      "
if GetNewPar("MV_EXCATE","S")  <> "S"
	if !PERGUNTE("OFI151")
		Return .f.
	Endif
Endif

ProcRegua(4)

if ExistBlock("VM011VLEX") //Validação extra de negocios
	If !ExecBlock("VM011VLEX",.f.,.f.)
		Return .f.
	Endif
Endif
For cont := 1 to len(aPref)
	dbSelectArea("SE1")
	dbSetOrder(1)
	if dbSeek(xFilial("SE1")+aPref[cont]+cNumero)
		While !Eof() .and. SE1->E1_FILIAL == xFilial('SE1') .and. SE1->E1_PREFIXO == aPref[cont] .and. SE1->E1_NUM == cNumero
			If !Empty(SE1->E1_BAIXA) .or. SE1->E1_SALDO != SE1->E1_VALOR
				MsgInfo(STR0087 ,STR0012) //Ha titulos baixados referentes a esta Venda.. - Atencao
				lMsErroAuto := .f.
				DisarmTransaction()
				Break
			EndIf
			DbSelectArea("SE1")
			DbSkip()
		Enddo
	EndIf
Next

if VV9->VV9_STATUS == "A" .and. 	GetNewPar("MV_EXCATE","S")  == "S"
	
	DELNEG011()
	
	RecLock("VV9",.f.,.t.)
	dbDelete()
	MsUnlock()
	WriteSx2("VV9")

	if VV0->VV0_TIPFAT == "3" .and. VV2->(FieldPos("VV2_QTDATU")) <> 0 // Venda Futura
		//
		VV2->(dbSetOrder(1))
		If VV2->(dbSeek(xFilial("VV2")+VV0->VV0_CODMAR+VV0->VV0_MODVEI))
			RecLock("VV2",.f.)
				VV2->VV2_QTDATU += 1
			MsUnLock()
			If VV0->(FieldPos("VV0_BXAFUT")) <> 0 // Veiculo Baixado na Venda Futura
				RecLock("VV0",.f.)
					VV0->VV0_BXAFUT := "0" // 1-Sim / 0-Nao
				MsUnlock()
	        EndIf
	   EndIf
	EndIf
	
	RecLock("VV0",.f.,.t.)
	dbDelete()
	MsUnlock()
	WriteSx2("VV0")
	
	RecLock("VVA",.f.,.t.)
	dbDelete()
	MsUnlock()
	WriteSx2("VVA")

	dbSelectarea("VV1")
	dbSetOrder(2)
	if dbSeek(xFilial("VV1")+M->VV0_CHASSI)
		RecLock("VV1",.f.)
		VV1->VV1_DESLOC := ""
		VV1->VV1_RESERV := ""
		VV1->VV1_DTHRES := ""
		VV1->VV1_DTHVAL := ""
	EndIf

Elseif VV9->VV9_STATUS == "A" .and. GetNewPar("MV_EXCATE","S") <> "S"
	
	PERGUNTE("OFI151",.f.)
	dbSelectarea("VV9")
	RecLock("VV9",.f.)
	VV9->VV9_STATUS := "C"
	VV9->VV9_MOTIVO := MV_PAR01
	VV9->VV9_DATCAN := dDataBase
	MsUnlock()

	If FindFunction("VEIVM130TAR")
		VEIVM130TAR(VV9->VV9_NUMATE,"9") // 0-Verifica/Valida / 1-Gravacao / 2-Finalizacao / 3-Pelo Usuario / 4-Pendente Aprovacao / 5-Pre-Aprovado / 6-Aprovado / 7-Reserva / 8-Cancela Reserva / 9-Cancela Atendimento
	EndIf

	dbSelectarea("VV1")
	dbSetOrder(2)
	if dbSeek(xFilial("VV1")+M->VV0_CHASSI)
		RecLock("VV1",.f.)
		VV1->VV1_DESLOC := ""
		VV1->VV1_RESERV := ""
		VV1->VV1_DTHRES := ""
		VV1->VV1_DTHVAL := ""
	EndIf
	
Else
	
	IncProc(STR0088)  //Cancelando Nota Fiscal
	
	if (lMsErroAuto := FS_CANCNFS())
		DisarmTransaction()
		Break
	Endif
	
	IncProc(STR0089)  //Cancelando Pedido de Venda
	
	if (lMsErroAuto := FS_CANCPED())
		DisarmTransaction()
		Break
	Endif
	
	IncProc(STR0090)  //Cancelando Titulos
	
	if (lMsErroAuto := FS_CANCTIT())
		DisarmTransaction()
		Break
	Endif
	
	IncProc(STR0091)  //Atualizando Status do Atendimento
	
	if !lMsErroAuto
		if ExistBlock("EXCATE011")
			ExecBlock("EXCATE011",.f.,.f.)
		Endif
		PERGUNTE("OFI151",.f.)
		dbSelectarea("VV9")
		RecLock("VV9",.f.)
		VV9->VV9_STATUS := "A"
		VV9->VV9_MOTIVO := MV_PAR01
		VV9->VV9_DATCAN := dDataBase
		MsUnlock()
	Endif
	
	dbSelectarea("VV0")
	dbSetOrder(1)
	if dbSeek(xFilial("VV0")+M->VV9_NUMATE)
		RecLock("VV0",.f.)
		VV0->VV0_SITNFI := "0" // Cancelada 
		VV0->VV0_NUMNFI := ""
		VV0->VV0_SERNFI := ""
		VV0->VV0_NUMPED := ""
		MsUnlock()
	Endif
	
	dbSelectarea("VV1")
	dbSetOrder(2)
	if dbSeek(xFilial("VV1")+M->VV0_CHASSI)
		RecLock("VV1",.f.)
		If VV1->VV1_SITVEI == "1" // Vendido
			VV1->VV1_PROATU := VV1->VV1_PROANT
			VV1->VV1_LJPATU := VV1->VV1_LJPANT
			VV1->VV1_PROANT := ""
			VV1->VV1_LJPANT := ""
		EndIf
		VV1->VV1_DESLOC := "" 
		VV1->VV1_SITVEI := "0" //Estoque
		VV1->VV1_RESERV := ""
// Manoel - 01/03/2010 - ficou desnecessario com a utilizacao da FGX_AMOVVEI		
//		if !Empty(VV1->VV1_STATUS)
//			dbSelectArea("VVG")
//			dbSetOrder(2)
//			if !dbSeek(xFilial("VVG")+VV1->VV1_CHAINT)
//				VV1->VV1_SITVEI := " "
//			Endif
//		Endif
		VV1->VV1_DTHRES := ""
		VV1->VV1_DTHVAL := ""
		VV1->VV1_DATVEN := ctod("")
		MsUnlock()
	Else
		if M->VV0_TIPFAT <> "3"
			if Empty(M->VV0_CHAINT)
				MsgInfo(STR0092 ,STR0012) //Chassi interno do veiculo no atendimento sem conteudo... - Atencao
			Else
				MsgInfo(STR0093 ,STR0012) //Nao encontrou o veiculo... - Atencao
			Endif
			DisarmTransaction()
			Break
		Endif
	Endif
Endif

If FunName() == "VEIVM011"
	FS_AtuVZ7("D") // Delecao dos Itens de Campanha
Endif

Return(!lMsErroAuto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FILTROVV  ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra os veiculos no browse de selecao                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FILTROVV(lObj,nCombo)
Local lFazWhile := .t.
Local cont
Local aArea     := VV0->(GetArea())
Local nValorVda := 0
Local nDiasEst  := 0
Local lFilVV1   := If(!Empty(cFilVV1),.t.,.f.)
Local cFiliFilt := ""
Local lEstVir   := .f.
Local cSQL      := ""
Local _cQuery   := ""
Local _cQueryAux:= ""
Local _cAlSA1   := "SQLSA1"
Local _cAlSA2   := "SQLSA2"
Local _cAlVV1   := "SQLVV1"
Local _cAlVVP   := "SQLVVP"
Local _cAlVVC   := "SQLVVC"
Local _cAlVVF   := "SQLVVF"
Local _cAlVVG   := "SQLVVG"
Local _cAlVVH   := "SQLVVH"
Local _cAlSB1   := "SQLSB1"
Local _cAlSB2   := "SQLSB2"
Local _cAlVVR   := "SQLVVR"
Local _cVV1     := "INICIAL"
Local _xFilSA1  := xFilial("SA1")
Local _xFilSA2  := xFilial("SA2")
Local _xFilVV1  := xFilial("VV1")
Local _xFilSB1  := xFilial("SB1")
Local _xFilVVP  := xFilial("VVP")
Local _xFilVVC  := xFilial("VVC")
Local _xFilVVF  := xFilial("VVF")
Local _xFilVVG  := xFilial("VVG")
Local _xFilVVH  := xFilial("VVH")
//Local lFilLib   := ( VAE->(FieldPos("VAE_FILLIB")) <> 0 )
Local cGrupos   := ""
Local cCores    := ""
Local cFilAtu   := ""
Local aQUltMov  := {}
Local lReserv   := .f.
Local lFilInic  := .f.
Local cPesqCor  := "INICIAL"
Local cCorVei   := ""
Local cOpcAux   := ""
Local nOpcAux   := 0
Local aRet      := {}
Local lVerBloq  := .t.
Local cBloqStat := GetNewPar("MV_BLQSTAV","L.O")
Local lMostraVei:= .t.
Local cVAIEstVei:= "2"
Local cTipoCor := ""
lFiltro   := .t.
If nCombo == 1 // Marca
	cGruMod := "" // Limpa Grupo do Modelo
	cModVei := "" // Limpa Modelo
ElseIf nCombo == 2 // Grupo Modelo
	cModVei := "" // Limpa Modelo
EndIf
VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
If VAI->VAI_BLOQVE == "0"
	lVerBloq := .f. // Nao mostrar veiculos bloqueados
EndIf
If VAI->(FieldPos("VAI_ESTVEI")) <> 0
	If !Empty(VAI->VAI_ESTVEI)
		cVAIEstVei := VAI->VAI_ESTVEI // 0=Novos / 1=Usados / 2=Ambos
	EndIf
EndIf
If !lMEstAte // Mostra Estoque TOTAL dos Veiculos
	If Empty(cGruMod)
		lFazWhile := .f. // Nao mostrar se o MODELO nao estiver preenchido!
	EndIf
EndIf
VV1->(dbSetOrder(1))

aStruVV1 := {}           
If Len(aFilVV1) > 0
	For cont := 1 To Len(aFilVV1)
		If !Empty(aFilVV1[cont])
			cFiliFilt += "'"+aFilVV1[cont]+"',"
		Endif
	Next    
Endif
If !Empty(cFiliFilt)
	cFiliFilt := Left(cFiliFilt,Len(cFiliFilt)-1)
Endif
If lFazWhile
//	_cQuery := "SELECT VV1.VV1_FILIAL , VV1.VV1_CHAINT , VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_SITVEI , VV1.VV1_ESTVEI , VV1.VV1_TRACPA , VV1.VV1_STATUS , VV1.VV1_FABMOD , VV1.VV1_KILVEI , VV1.VV1_LOCPAD , VV1.VV1_RESERV , VV1.VV1_BITMAP , VV1.VV1_DTHVAL , VV1.VV1_SUGVDA , VV1.VV1_CODORI , VV1.VV1_SEGMOD , VV1.VV1_CORVEI , VV1.VV1_PLAVEI, VV2.VV2_DESMOD , VAE.VAE_DESCRI "+IIF(lFilLib,", VAE.VAE_FILLIB ","")
	_cQuery := "SELECT VV1.VV1_FILIAL , VV1.VV1_CHAINT , VV1.VV1_CHASSI , VV1.VV1_CODMAR , VV1.VV1_MODVEI , VV1.VV1_SITVEI , VV1.VV1_ESTVEI , VV1.VV1_TRACPA , VV1.VV1_STATUS ,VV1.VV1_FILENT, VV1.VV1_FABMOD , VV1.VV1_KILVEI , VV1.VV1_LOCPAD , VV1.VV1_RESERV , VV1.VV1_BITMAP , VV1.VV1_DTHVAL , VV1.VV1_SUGVDA , VV1.VV1_CODORI , VV1.VV1_SEGMOD , VV1.VV1_CORVEI , VV1.VV1_PLAVEI, VV1.VV1_TRACPA, VV2.VV2_DESMOD "
//	 Manoel / Luis - 01/03/2010 - ficou desnecessario com a utilizacao da FGX_AMOVVEI - usaremos o VV1_FILENT
//	_cQuery += "FROM "+RetSqlName("VV1")+" VV1 INNER JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV1.VV1_CODMAR=VV2.VV2_CODMAR AND VV1.VV1_MODVEI=VV2.VV2_MODVEI  AND VV2.D_E_L_E_T_=' ' ) LEFT OUTER JOIN "+RetSqlName("VAE")+" VAE ON ( VAE.VAE_FILIAL='"+xFilial("VAE")+"' AND VV1.VV1_STATUS=VAE.VAE_CODIGO AND VAE.VAE_LIBSP='1' AND VAE.D_E_L_E_T_=' ' ) WHERE ( "
	_cQuery += "FROM "+RetSqlName("VV1")+" VV1 INNER JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV1.VV1_CODMAR=VV2.VV2_CODMAR AND VV1.VV1_MODVEI=VV2.VV2_MODVEI  AND VV2.D_E_L_E_T_=' ' ) WHERE ( "
	If lFilVV1
//		_cQuery += "VV1.VV1_FILIAL='"+cFilVV1+"' OR VV1.VV1_STATUS='"+cFilVV1+"' ) AND ( "
		_cQuery += "VV1.VV1_FILIAL='"+cFilVV1+"' OR VV1.VV1_FILENT='"+cFilVV1+"' ) AND ( "
	Else
//		_cQuery += "VV1.VV1_FILIAL IN ("+cFiliFilt+") OR VV1.VV1_STATUS IN ("+cFiliFilt+") ) AND ( "
		_cQuery += "VV1.VV1_FILIAL IN ("+cFiliFilt+") OR VV1.VV1_FILENT IN ("+cFiliFilt+") ) AND ( "
	EndIf
	If lPriVez .or. ( lCkFilEst .and. !lCkFilVir .and. !lCkFilTra .and. !lCkFilRes .and. !lCkFilRem .and. !lCkFilCon .and. !lCkFilAti )
		_cQuery += "VV1.VV1_SITVEI='0' AND (VV1.VV1_RESERV<>'1' OR VV1.VV1_RESERV<>'3') AND VV1.VV1_TRACPA<>'"+space(len(VV1->VV1_TRACPA))+"' "
	Else
		If lCkFilRes
			_cQuery += "( VV1.VV1_SITVEI IN (' ','0','2') AND VV1.VV1_RESERV IN ('1','3')  ) OR "
		EndIf
		If lCkFilVir
			_cQuery += "( VV1.VV1_SITVEI=' ' AND VV1.VV1_CODORI='3' ) OR "
		EndIf
		If lCkFilEst
			_cQuery += "VV1.VV1_SITVEI IN ('0'"
		Else
			_cQuery += "VV1.VV1_SITVEI IN ('*'" // * Somante para dar certo o IN do SQL
		EndIf
		If lCkFilTra
			_cQuery += ",'2'"
		EndIf
		If lCkFilRem
			_cQuery += ",'3'"
		EndIf
		If lCkFilCon
			_cQuery += ",'4'"
		EndIf
		_cQuery += ")"
		If lCkFilAti
			_cQuery += " OR ( VV1.VV1_SITVEI=' ' AND (VV1.VV1_RESERV<>'1' OR VV1.VV1_RESERV<>'3') AND VV1.VV1_CODORI<>'3' ) "
		EndIf
	EndIf
	_cQuery += ") AND "
	If !lPriVez
		If !Empty(cTIPVEI)
			_cQuery += "VV1.VV1_TIPVEI='"+left(cTIPVEI,1)+"' AND "
		EndIf
		if !Empty(cCODMAR)
			_cQuery += "VV1.VV1_CODMAR='"+cCODMAR+"' AND "
		Endif
		if !Empty(cMODVEI)
			_cQuery += "VV1.VV1_MODVEI='"+cMODVEI+"' AND "
		Else
			if !Empty(cGruMod)
				_cQueryAux := "SELECT VV2.VV2_MODVEI FROM "+RetSqlName("VVR")+" VVR INNER JOIN "+RetSqlName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VVR.VVR_CODMAR AND VV2.VV2_GRUMOD=VVR.VVR_GRUMOD AND VV2.D_E_L_E_T_=' ' ) WHERE VVR.VVR_FILIAL='"+xFilial("VVR")+"' AND VVR.VVR_CODMAR='"+cCODMAR+"' AND VVR.VVR_DESCRI='"+cGruMod+"' AND VVR.D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQueryAux ), _cAlVVR , .F., .T. )
				While !( _cAlVVR )->( Eof() )
					cGrupos += ",'"+( _cAlVVR )->( VV2_MODVEI )+"'"
					( _cAlVVR )->( DbSkip() )
				EndDo
				( _cAlVVR )->( dbCloseArea() )
				If !Empty(cGrupos)
					cGrupos := substr(cGrupos,2)
					_cQuery += "VV1.VV1_MODVEI IN (" +  cGrupos + ") AND "
				EndIf
			EndIf
		EndIf
		if !Empty(cCOR)
			_cQuery += "VV1.VV1_CORVEI='"+cCOR+"' AND "
		Else
			if !Empty(cGruCor)
				_cQueryAux := "SELECT VVC.VVC_CORVEI FROM "+RetSqlName("VVC")+" VVC WHERE VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_GRUCOR='"+cGruCor+"' AND VVC.D_E_L_E_T_=' '"
				If !empty(cTipCor)
					_cQueryAux += " AND VVC.VVC_TIPCOR='"+Subs(cTipCor,1,1)+"'"
				EndIf
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQueryAux ), _cAlVVC , .F., .T. )
				While !( _cAlVVC )->( Eof() )
					cCores += ",'"+( _cAlVVC )->( VVC_CORVEI )+"'"
					( _cAlVVC )->( DbSkip() )
				EndDo
				( _cAlVVC )->( dbCloseArea() )
				If !Empty(cCores)
					cCores  := substr(cCores,2)
					_cQuery += "VV1.VV1_CORVEI IN (" +  cCores + ") AND "
				EndIf
			Endif
		EndIf
		if !Empty(cCombus)
			_cQuery += "VV1.VV1_COMVEI='"+Subs(cCombus,1,1)+"' AND "
		Endif
		If cVAIEstVei == "2" // Ambos
			if !Empty(cEstVeiF)
				_cQuery += "VV1.VV1_ESTVEI='"+Subs(cEstVeiF,1,1)+"' AND "
			Endif
		Else
			_cQuery += "VV1.VV1_ESTVEI='"+cVAIEstVei+"' AND " // 0=Novos ou 1=Usados
		Endif
		if nKMFxa > 0
			_cQuery += "VV1.VV1_KILVEI<="+str(nKMFxa)+" AND "
		Endif
		if !Empty(cOpcVei)
			cOpcAux := Alltrim(cOpcVei)
			For cont := 1 to len(cOpcAux)
				nOpcAux := at("/",cOpcAux)
				If nOpcAux <= 0
					nOpcAux := len(cOpcAux)+1
				EndIf
				_cQuery += "VV1.VV1_OPCFAB LIKE '%"+substr(cOpcAux,1,nOpcAux)+"%' AND "
				cOpcAux := substr(cOpcAux,nOpcAux+1)
				If Empty(cOpcAux)
					Exit
				EndIf
			Next
		Endif
	Else
		If cVAIEstVei <> "2" // Novos ou Usados
			_cQuery += "VV1.VV1_ESTVEI='"+cVAIEstVei+"' AND " // 0=Novos ou 1=Usados
		Endif
	Endif
	_cQuery += "VV1.D_E_L_E_T_=' ' ORDER BY VV1.VV1_CHASSI "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVV1 , .F., .T. )
	While !( _cAlVV1 )->( Eof() )
		cLetra  := "N"
		If !lPriVez
			if nAnoIni > 0
				If Subs(( _cAlVV1 )->( VV1_FABMOD ),1,4) < Str(nAnoIni,4)
					( _cAlVV1 )->( DbSkip() )
					Loop
				EndIf
			Endif
			if nAnoFin > 0
				If Subs(( _cAlVV1 )->( VV1_FABMOD ),5,4) > Str(nAnoFin,4)
					( _cAlVV1 )->( DbSkip() )
					Loop
				EndIf
			Endif
//			if lFilLib
//				If !Empty(VAE->VAE_FILLIB) .and. !(_xFilVV1 $ VAE->VAE_FILLIB)
//					( _cAlVV1 )->( DbSkip() )
//					Loop
//				Endif
//			Endif
			lEstVir := .f.
			if Empty(( _cAlVV1 )->( VV1_SITVEI )) .and. ( _cAlVV1 )->( VV1_CODORI )=="3"
				If !lCkFilVir
					( _cAlVV1 )->( DbSkip() )
					Loop
				EndIf
				lEstVir := .t.
				cLetra  := "V"
			Else
				If ( _cAlVV1 )->( VV1_SITVEI ) <> "2" //Diferente de Transito
					If Empty(( _cAlVV1 )->( VV1_TRACPA ))
						( _cAlVV1 )->( DbSkip() )
						Loop
					EndIf
				EndIf
			EndIf
		EndIf
///////////////////////////////////////////////////////////////////////
		lReserv := .f.
		If ( _cAlVV1 )->( VV1_RESERV ) $ "1/3" // Reservado
			If !Empty(( _cAlVV1 )->( VV1_DTHVAL ))
				lReserv := .t.
				dDatRes := ctod(subs(( _cAlVV1 )->( VV1_DTHVAL ),1,8))
				if dDataBase > dDatRes
					lReserv := .f.
				Elseif dDataBase == dDatRes
					cHorTmp := subs(( _cAlVV1 )->( VV1_DTHVAL ),10,2)+":"+subs(( _cAlVV1 )->( VV1_DTHVAL ),12,2)
					if Substr(Time(),1,5) > cHorTmp
						lReserv := .f.
					Endif
				Endif
				If lReserv
					If !lCkFilRes
						( _cAlVV1 )->( DbSkip() )
						Loop
					EndIf
					cLetra := "B"
				EndIf
			EndIf
		EndIf
///////////////////////////////////////////////////////////////////////
		If lPriVez
			If cLetra <> "N"
				( _cAlVV1 )->( DbSkip() )
				Loop
			EndIf
		Else
			If cLetra <> "B" .and. cLetra <> "V"
				Do Case
					Case ( _cAlVV1 )->( VV1_SITVEI ) == "2" //Transito
						cLetra := "T"
					Case ( _cAlVV1 )->( VV1_SITVEI ) == "3" //Remessa
						cLetra := "R"
					Case ( _cAlVV1 )->( VV1_SITVEI ) == "4" //Consignado
						cLetra := "C"
					Case ( _cAlVV1 )->( VV1_SITVEI ) == " " // Ativo Imobilizado
						If !( _cAlVV1 )->( VV1_RESERV ) $ "1/3" .and. ( _cAlVV1 )->( VV1_CODORI ) <> "3"
							cLetra := "A"
						EndIf
				EndCase
			EndIf
			If cLetra == "N" .and. ( _cAlVV1 )->( VV1_SITVEI ) == "0" .and. !lCkFilEst
				( _cAlVV1 )->( DbSkip() )
				Loop
			EndIf
		EndIf
		nValorVda := 0
		If ( _cAlVV1 )->( VV1_SUGVDA ) > 0
			nValorVda := ( _cAlVV1 )->( VV1_SUGVDA )
		EndIf
		If nValorVda == 0
			_cQuery := "SELECT VVP.VVP_VALTAB, VVP.VVP_VACRPR, VVP.VVP_VACRMT FROM "+RetSqlName("VVP")+" VVP WHERE VVP.VVP_FILIAL='"+_xFilVVP+"' AND VVP.VVP_CODMAR='"+( _cAlVV1 )->( VV1_CODMAR )+"' AND VVP.VVP_MODVEI='"+( _cAlVV1 )->( VV1_MODVEI )+"' AND VVP.VVP_SEGMOD='"+( _cAlVV1 )->( VV1_SEGMOD )+"' AND VVP.VVP_DATPRC<='"+dtos(dDataBase)+"' AND VVP.D_E_L_E_T_=' ' ORDER BY VVP.VVP_DATPRC DESC"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVP , .F., .T. )
			If !( _cAlVVP )->( Eof() )
				nValorVda := ( _cAlVVP )->( VVP_VALTAB )
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acrescenta valor adicional pelo tipo da cor ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(( _cAlVV1 )->( VV1_CORVEI ))
				
					cTipoCor := FM_SQL("SELECT VVC_TIPCOR FROM "+RetSQLName("VVC")+" VVC WHERE VVC.VVC_FILIAL = '"+xFilial("VVC")+"' AND VVC.VVC_CODMAR = '"+( _cAlVV1 )->( VV1_CODMAR )+"' AND VVC.VVC_CORVEI = '"+( _cAlVV1 )->( VV1_CORVEI )+"' AND VVC.D_E_L_E_T_ = ' '")
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acrescenta valor para Cor do Modelo Metalica   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					if cTipoCor == "1" 
						nValorVda += ( _cAlVVP )->( VVP_VACRMT )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acrescenta valor para Cor do Modelo Perolizada ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					elseif cTipoCor == "2" 
						nValorVda += ( _cAlVVP )->( VVP_VACRPR )
					endif
					
				EndIf
						
			EndIf
			( _cAlVVP )->( dbCloseArea() )
		EndIf
		If !lPriVez
			if nValFxI > 0
				If nValorVda < nValFxI
					( _cAlVV1 )->( DbSkip() )
					Loop
				Endif
			Endif
			if nValFxF > 0
				If nValorVda > nValFxF
					( _cAlVV1 )->( DbSkip() )
					Loop
				Endif
			Endif
		EndIf
		lSelect := .f.
		If _cVV1 # ( _cAlVV1 )->( VV1_CHASSI )
			_cVV1 := ( _cAlVV1 )->( VV1_CHASSI )
			nDiasEst := 0
			If !lEstVir .and. cLetra <> "V"
				//				aQUltMov := FM_VEIUMOV( ( _cAlVV1 )->( VV1_CHASSI ) , "E" , "0" )
				//				If len(aQUltMov) > 0
				//	      	   nDiasEst := (dDataBase-aQUltMov[5])
				//				EndIf
				_cQuery := "SELECT SB1.B1_UCOM FROM "+RetSqlName("SB1")+" SB1 WHERE SB1.B1_FILIAL='"+_xFilSB1+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE='"+( _cAlVV1 )->( VV1_CHAINT )+"' AND SB1.D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlSB1 , .F., .T. )
				If !( _cAlSB1 )->( Eof() )
					If !Empty(( _cAlSB1 )->( B1_UCOM ))
						nDiasEst := ( dDataBase - stod(( _cAlSB1 )->( B1_UCOM )) )
					Else
						aQUltMov := FM_VEIUMOV( ( _cAlVV1 )->( VV1_CHASSI ) , "E" , "0" )
						If len(aQUltMov) > 0
							nDiasEst := (dDataBase-aQUltMov[5])
						EndIf
					EndIf
				Else
					aQUltMov := FM_VEIUMOV( ( _cAlVV1 )->( VV1_CHASSI ) , "E" , "0" )
					If len(aQUltMov) > 0
						nDiasEst := (dDataBase-aQUltMov[5])
					EndIf
				EndIf
				( _cAlSB1 )->( dbCloseArea() )
			EndIf
//			 Manoel / Luis - 01/03/2010 - ficou desnecessario com a utilizacao da FGX_AMOVVEI - usaremos o VV1_FILENT
//			cFilAtu := ( _cAlVV1 )->( VV1_STATUS )+" - "+( _cAlVV1 )->( VAE_DESCRI )
			nPos := aScan(aNomFil,{|x| Alltrim(x[1]) == Alltrim(( _cAlVV1 )->VV1_FILENT)})
			cFilAtu := ( _cAlVV1 )->( VV1_FILENT )
			If nPos > 0
				cFilAtu += " - "+aNomFil[nPos,2]
			Endif
			If !lPriVez
				If cLetra $ "RC" // Remessa / Consignado
					cFilAtu  := ""
					aQUltMov := FM_VEIUMOV( ( _cAlVV1 )->( VV1_CHASSI ) )
					If len(aQUltMov) > 0
						If aQUltMov[1] == "S" // SAIDA
							If aQUltMov[4] $ "67" // Retorno de Remessa/Consignado
								_cQuery := "SELECT SA2.A2_NOME FROM "+RetSqlName("SA2")+" SA2 WHERE SA2.A2_FILIAL='"+_xFilSA2+"' AND SA2.A2_COD='"+aQUltMov[6]+"' AND SA2.A2_LOJA='"+aQUltMov[7]+"' AND SA2.D_E_L_E_T_=' '"
								dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlSA2 , .F., .T. )
								If !( _cAlSA2 )->( Eof() )
									cFilAtu := STR0094 +" "+aQUltMov[6]+"-"+aQUltMov[7]+" "+left(( _cAlSA2 )->( A2_NOME ),20)   //Fornecedor:
								Endif
								( _cAlSA2 )->( dbCloseArea() )
							Else
								_cQuery := "SELECT SA1.A1_NOME FROM "+RetSqlName("SA1")+" SA1 WHERE SA1.A1_FILIAL='"+_xFilSA1+"' AND SA1.A1_COD='"+aQUltMov[6]+"' AND SA1.A1_LOJA='"+aQUltMov[7]+"' AND SA1.D_E_L_E_T_=' '"
								dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlSA1 , .F., .T. )
								If !( _cAlSA1 )->( Eof() )
									cFilAtu := STR0095 +" "+aQUltMov[6]+"-"+aQUltMov[7]+" "+left(( _cAlSA1 )->( A1_NOME ),20)   //Cliente:
								Endif
								( _cAlSA1 )->( dbCloseArea() )
							EndIf
						Else // ENTRADA
							If aQUltMov[4] $ "78" // Retorno de Remessa/Consignado
								_cQuery := "SELECT SA1.A1_NOME FROM "+RetSqlName("SA1")+" SA1 WHERE SA1.A1_FILIAL='"+_xFilSA1+"' AND SA1.A1_COD='"+aQUltMov[6]+"' AND SA1.A1_LOJA='"+aQUltMov[7]+"' AND SA1.D_E_L_E_T_=' '"
								dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlSA1 , .F., .T. )
								If !( _cAlSA1 )->( Eof() )
									cFilAtu := STR0095 +" "+aQUltMov[6]+"-"+aQUltMov[7]+" "+left(( _cAlSA1 )->( A1_NOME ),20)  //Cliente
								Endif
								( _cAlSA1 )->( dbCloseArea() )
							Else
								_cQuery := "SELECT SA2.A2_NOME FROM "+RetSqlName("SA2")+" SA2 WHERE SA2.A2_FILIAL='"+_xFilSA2+"' AND SA2.A2_COD='"+aQUltMov[6]+"' AND SA2.A2_LOJA='"+aQUltMov[7]+"' AND SA2.D_E_L_E_T_=' '"
								dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlSA2 , .F., .T. )
								If !( _cAlSA2 )->( Eof() )
									cFilAtu := STR0094 +" "+aQUltMov[6]+"-"+aQUltMov[7]+" "+left(( _cAlSA2 )->( A2_NOME ),20) //Fornecedor
								Endif
								( _cAlSA2 )->( dbCloseArea() )
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			If !Inclui
				lSelect := (( _cAlVV1 )->( VV1_CHASSI ) == M->VV0_CHASSI)
			EndIf
			If cPesqCor # ( _cAlVV1 )->( VV1_CODMAR ) + ( _cAlVV1 )->( VV1_CORVEI )
				cPesqCor := ( _cAlVV1 )->( VV1_CODMAR ) + ( _cAlVV1 )->( VV1_CORVEI )
				_cQuery := "SELECT VVC.VVC_DESCRI FROM "+RetSqlName("VVC")+" VVC WHERE VVC.VVC_FILIAL='"+_xFilVVC+"' AND VVC.VVC_CODMAR='"+( _cAlVV1 )->( VV1_CODMAR )+"' AND VVC.VVC_CORVEI='"+( _cAlVV1 )->( VV1_CORVEI )+"' AND VVC.D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVC , .F., .T. )
				cCorVei := ""
				If !( _cAlVVC )->( Eof() )
					cCorVei := left(( _cAlVVC )->( VVC_DESCRI ),12)
				Endif
				( _cAlVVC )->( dbCloseArea() )
			EndIf

			// Posicionamento no VVF
			_cQuery := "SELECT VVF.VVF_DATEMI FROM "+RetSqlName("VVF")+" VVF WHERE VVF.VVF_FILIAL='"+_xFilVVF+"' AND VVF.VVF_TRACPA='"+( _cAlVV1 )->( VV1_TRACPA )+"' AND VVF.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVF , .F., .T. )
			cDatEmiVVF := ""
			If !( _cAlVVF )->( Eof() )
				cDatEmiVVF := ( _cAlVVF )->( VVF_DATEMI)
			Endif
			( _cAlVVF )->( dbCloseArea() )
			// Posicionamento no VVG
			_cQuery := "SELECT VVG.VVG_CODIND FROM "+RetSqlName("VVG")+" VVG WHERE VVG.VVG_FILIAL='"+_xFilVVG+"' AND VVG.VVG_TRACPA='"+( _cAlVV1 )->( VV1_TRACPA )+"' AND VVG.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVG , .F., .T. )
			cCodIndVVG := ""
			If !( _cAlVVG )->( Eof() )
				cCodIndVVG := ( _cAlVVG )->( VVG_CODIND)
			Endif
			( _cAlVVG )->( dbCloseArea() )
			// Posicionamento no VVH
			_cQuery := "SELECT VVH.VVH_DIACAR FROM "+RetSqlName("VVH")+" VVH WHERE VVH.VVH_FILIAL='"+_xFilVVH+"' AND VVH.VVH_CODIND='"+cCodIndVVG+"' AND VVH.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVH , .F., .T. )
			nDiaCarVVH := 0
			If !( _cAlVVH )->( Eof() )
				nDiaCarVVH := ( _cAlVVH )->( VVH_DIACAR)
			Endif
			( _cAlVVH )->( dbCloseArea() )

			lMostraVei := .t.
			If !lVerBloq // Usuario nao pode ver os Veiculos BLOQUEADOS //
				If FindFunction("VM060VEIBLO")
					aRet := VM060VEIBLO(( _cAlVV1 )->( VV1_CHAINT ),"B") // Verifica se o Veiculo esta Bloqueado, retorna registro do Bloqueio.
				    If len(aRet) > 0
						lMostraVei := .f.	
					EndIf
				EndIf
			EndIf

			If lMostraVei
//				aAdd(aStruVV1, { lSelect,cLetra,!Empty(( _cAlVV1 )->( VV1_BITMAP )),Str(nDiasEst,3),( _cAlVV1 )->( VV1_CHASSI ),( _cAlVV1 )->( VV2_DESMOD ),( _cAlVV1 )->( VV1_CODMAR ),cCorVei,nValorVda,if(( _cAlVV1 )->( VV1_ESTVEI )=="0",STR0096,STR0097),Subs(( _cAlVV1 )->( VV1_FABMOD ),1,4),Subs(( _cAlVV1 )->( VV1_FABMOD ),5,4),( _cAlVV1 )->( VV1_KILVEI ),cFilAtu, If(!Empty(( _cAlVV1 )->( VV1_FILIAL )),( _cAlVV1 )->( VV1_FILIAL ),( _cAlVV1 )->( VV1_STATUS )),( _cAlVV1 )->( VV1_PLAVEI ),cDatEmiVVF,cCodIndVVG,nDiaCarVVH,( _cAlVV1 )->( VV1_TRACPA ) } )

				// Nao mostrar Veiculos que estao em Atendimentos com STATUS Bloqueados //
				If !Empty(cBloqStat)
					cSQL := "SELECT VV9.VV9_STATUS "
					cSQL += " FROM "+RetSQLName("VVA")+" VVA , "+RetSQLName("VV0")+" VV0, "+RetSQLName("VV9")+" VV9 "
					cSQL += " WHERE VVA_FILIAL IN "+FormatIN(FM_ALLFIL("VVA"),",")
					cSQL += " AND VVA_CHAINT = '"+( _cAlVV1 )->( VV1_CHAINT )+"' AND VVA.D_E_L_E_T_ = ' '"
					cSQL += " AND VV0_FILIAL = VVA_FILIAL AND VV0_NUMTRA = VVA_NUMTRA AND VV0.D_E_L_E_T_ = ' '"
					cSQL += " AND VV9_FILIAL = VVA_FILIAL AND VV9_NUMATE = VV0_NUMTRA AND VV9_STATUS NOT IN ('C','F','T','R','D') AND VV9.D_E_L_E_T_ = ' '" // Considerar somente atendimento em aberto 
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), "TATEND" , .F., .T. )
					While !TATEND->(Eof()) .and. lMostraVei
						If TATEND->VV9_STATUS $ cBloqStat // STATUS de outro Atendimento do mesmo Veículo que bloqueia novo Atendimento
	                    	lMostraVei := .f.
						EndIf					  
						TATEND->(dbSkip())
					EndDo
					TATEND->(dbCloseArea())
				EndIf
				//////////////////////////////////////////////////////////////////////////
				
				If lMostraVei
					aAdd(aStruVV1, { lSelect,cLetra,!Empty(( _cAlVV1 )->( VV1_BITMAP )),Str(nDiasEst,3),( _cAlVV1 )->( VV1_CHASSI ),( _cAlVV1 )->( VV2_DESMOD ),( _cAlVV1 )->( VV1_CODMAR ),cCorVei,nValorVda,if(( _cAlVV1 )->( VV1_ESTVEI )=="0",STR0096,STR0097),Subs(( _cAlVV1 )->( VV1_FABMOD ),1,4),Subs(( _cAlVV1 )->( VV1_FABMOD ),5,4),( _cAlVV1 )->( VV1_KILVEI ),cFilAtu, If(!Empty(( _cAlVV1 )->( VV1_FILIAL )),( _cAlVV1 )->( VV1_FILIAL ),( _cAlVV1 )->( VV1_FILENT )),( _cAlVV1 )->( VV1_PLAVEI ),cDatEmiVVF,cCodIndVVG,nDiaCarVVH,( _cAlVV1 )->( VV1_TRACPA ) } )
				EndIf

			EndIf

			If lEstVir .and. lSelect
				lFatura := .f.
				cBlqFat := STR0098 //veiculo de estoque virtual
			EndIf
			
		EndIf
		
		( _cAlVV1 )->( DbSkip() )
	EndDo
	( _cAlVV1 )->( dbCloseArea() )
	
EndIf

lPriVez := .f.

dbSelectArea("VV1")
dbSetOrder(1)

if len(aStruVV1) == 0
	aAdd(aStruVV1, { .f.,"N",.f.," "," "," "," "," ",0,"","","",0,"","","","","",0,"" } )
Endif

Asort(aStruVV1,,,{|x,y| x[4]+x[5] > y[4]+y[5] })
If ExistBlock("PEVM011OSV") // Ponto de Entrada que Ordena a Selecao do Veiculo
	ExecBlock("PEVM011OSV",.f.,.f.)
Endif
/*
// Imprime lista dos veiculos que sairao no VEIVM011
ni := 0
Outputfile := FCREATE(__RELDIR+"VEIVM011.##R",0)
For cont := 1 to len(aStruVV1)
ni++
fwrite(outputfile,aStruVV1[cont,4]+" "+aStruVV1[cont,5]+CHR(13)+CHR(10))
If ni >= 50
ni := 0
fwrite(outputfile,CHR(13)+CHR(10)+CHR(12))
EndIf
Next
fclose(Outputfile)
*/

if (lObj == Nil .or. lObj)
	oLbox:nAt := 1
	oLbox:SetArray(aStruVV1)
	oLbox:bLine := { || { IIf(!aStruVV1[oLbox:nAt,01],oNo,oTik),;
	IIf(aStruVV1[oLbox:nAt,02]=="N",oBranco,IIf(aStruVV1[oLbox:nAt,02]=="V",oVerde,IIf(aStruVV1[oLbox:nAt,02]=="T",oLaranja,IIf(aStruVV1[oLbox:nAt,02]=="R",oVermelho,IIf(aStruVV1[oLbox:nAt,02]=="C",oAzul,IIf(aStruVV1[oLbox:nAt,02]=="A",oPreto,oAmarelo)))))),;
	IIf(!aStruVV1[oLbox:nAt,03],oNada,oFoto),;
	aStruVV1[oLbox:nAt,15],;
	aStruVV1[oLbox:nAt,04],;
	aStruVV1[oLbox:nAt,05],;
	transform(aStruVV1[oLbox:nAt,16],VV1->(x3Picture("VV1_PLAVEI"))),;
	aStruVV1[oLbox:nAt,06],;
	aStruVV1[oLbox:nAt,07],;
	aStruVV1[oLbox:nAt,08],;
	Fg_AlinVlrs(Transform(aStruVV1[oLbox:nAt,09],"@E 9,999,999.99")),;
	aStruVV1[oLbox:nAt,10],;
	aStruVV1[oLbox:nAt,11],;
	aStruVV1[oLbox:nAt,12],;
	aStruVV1[oLbox:nAt,13],;
	aStruVV1[oLbox:nAt,14] } }
	oLBox:Refresh()
Endif

if nCombo == 1
	aGener := {""}
	aEspec := {""}
	dbSelectArea("VVR")
	dbSetOrder(1)
	dbSeek(xFilial("VVR")+cCODMAR)
	While !Eof() .and. xFilial("VVR") == VVR->VVR_FILIAL .and. alltrim(VVR->VVR_CODMAR) == cCODMAR
		if aScan(aGener,VVR->VVR_DESCRI) = 0
			aadd(aGener,VVR->VVR_DESCRI)
		Endif
		dbSkip()
	Enddo
	If (lObj == Nil .or. lObj)
		cbxGruMod:AITEMS := aGener
		cbxModVei:AITEMS := aEspec
	EndIf
	cModVei := ""
Endif

if !Empty(cGRUMOD) .and. nCombo == 2
	aEspec := {""}
	dbSelectArea("VVR")
	dbSetOrder(1)
	dbSeek(xFilial("VVR")+cCODMAR+SPACE(TamSx3("VV1_CODMAR")[1]-len(cCODMAR))+cGRUMOD)
	dbSelectArea("VV2")
	dbSetOrder(3)
	dbSeek(xFilial("VV2")+cCODMAR+SPACE(TamSx3("VV1_CODMAR")[1]-len(cCODMAR))+VVR->VVR_GRUMOD)
	While !Eof() .and. xFilial("VV2") == VV2->VV2_FILIAL .and. alltrim(VVR->VVR_CODMAR) == cCODMAR .and. VV2->VV2_GRUMOD == VVR->VVR_GRUMOD
		if aScan(aEspec,VV2->VV2_MODVEI) = 0 //VV2->VV2_DESMOD
			aadd(aEspec,VV2->VV2_MODVEI)  //VV2->VV2_DESMOD
		Endif
		dbSkip()
	Enddo
	If (lObj == Nil .or. lObj)
		cbxModVei:AITEMS := aEspec
	EndIf
ElseIf Empty(cGRUMOD)
	aEspec := {""}
	If (lObj == Nil .or. lObj)
		cbxModVei:AITEMS := aEspec
	EndIf
Endif

lSelect   := .f.
lJaPer011 := .f.

RestArea(aArea)

dbSelectArea("VV1")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ORDSER011    ³ Autor ³ ANDRE             ³ Data ³ 25/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria ORDEM DE SERVICO dos acessorios selecionados          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ORDSER011(nOpc)

Local cont, nopca
Local bOk,oDlgPM900,aCampos := {}, nMemoria := 0
Local aAltCpo    := {}
Local aColsSlv   := if(Type("aCols") # "U",aClone(aCols),Nil)
Local aHeaderSlv := if(Type("aHeader") # "U",aClone(aHeader),Nil)

Local nTotSrv := 0
Local nTotPec := 0
Local nTotDes := 0
Local nTotOsv := 0

if M->VV0_TIPFAT == "3"
	Return(.t.)
Endif

if !Inclui .and. !Empty(VV0->VV0_NUMOSV)
	Return .f.
Endif

if M->VV0_ACESSO = 0
	Return .f.
Endif

if Empty(M->VV9_CODCLI) .or. Empty(M->VV9_LOJA)
	MsgInfo(STR0099 ,STR0012) //Cliente nao informado ou cliente nao cadastrado... - Atencao
	Return .f.
Endif

if !MsgYesNo(STR0100 ,STR0012) //Gera Ordem de Servico? - Atencao
	Return .f.
Endif

aEncOS    := {}
aCols     := Nil
aHeader   := Nil
aCols_P   := {}
aHeader_P := {}
aCols_S   := {}
aHeader_S := {}

Private Inclui   := .t. , Altera := .f. , Consultar := .f. , Excluir := .f.
Private aTELA[0][0],aGETS[0]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ordem de servicos                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VO1")
While x3_arquivo == "VO1" .and. !eof()
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. !AllTrim(x3_campo) $ "VO1_GETKEY/VO1_NUMBOX/VO1_CODCOR/VO1_PRISMA/VO1_CODMOT/"+;
		"VO1_MOTIVO/VO1_MECREQ/VO1_NUMLIB/VO1_FORPAG/VO1_CODBCO/VO1_APOLIC/VO1_SINIST/VO1_NROAPR/VO1_FRANQU"+iif(VV1->VV1_ESTVEI=="0","/VO1_KILOME","")
		AADD(aEncOS,x3_campo)
	Endif
	wVar := "M->"+x3_campo
	&wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pecas da Ordem de servico                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VO3")
nUsado_P:=0
While !Eof().And.(x3_arquivo=="VO3")
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. Alltrim(x3_campo) $ "VO3_GRUITE/VO3_CODITE/VO3_DESITE/VO3_QTDREQ/VO3_QTDEST/VO3_VALPEC/VO3_VALBRU/VO3_TIPTEM"
		nUsado_P:=nUsado_P+1
		Aadd(aHeader_P,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,"VLDVO3011()",;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
	Endif
	wVar  := "M->"+x3_campo
	&wVar := CriaVar(x3_campo)
	dbSkip()
Enddo

aCols_P:={}
aCols_P:={Array(nUsado_P+1)}
aCols_P[1,nUsado_P+1]:=.F.
For cont:=1 to nUsado_P
	aCols_P[1,cont]:=CriaVar(aHeader_P[cont,2])
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Servicos da Ordem de servico                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VO4")
nUsado_S:=0
While !Eof().And.(x3_arquivo=="VO4")
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. Alltrim(x3_campo) $ "VO4_GRUSER/VO4_CODSER/VO4_DESSER//VO4_TIPTEM"
		nUsado_S:=nUsado_S+1
		Aadd(aHeader_S,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
	Endif
	wVar  := "M->"+x3_campo
	&wVar := CriaVar(x3_campo)
	dbSkip()
Enddo

aCols_S:={}
aCols_S:={Array(nUsado_S+1)}
aCols_S[1,nUsado_S+1]:=.F.
For cont:=1 to nUsado_S
	aCols_S[1,cont]:=CriaVar(aHeader_S[cont,2])
Next

M->VO1_GETKEY := VV1->VV1_CHASSI
M->VO1_CHASSI := VV1->VV1_CHASSI
M->VO1_PROVEI := VV1->VV1_PROATU
M->VO1_LOJPRO := VV1->VV1_LJPATU
M->VO1_NOMPRO := Posicione("SA1",1,xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU,"A1_NREDUZ")
M->VO1_PLAVEI := VV1->VV1_PLAVEI
M->VO1_CHAINT := VV1->VV1_CHAINT
M->VO1_PLAVEI := VV1->VV1_PLAVEI
M->VO1_DESMAR := Posicione("VE1",1,xFilial("VE1")+VV1->VV1_CODMAR,"VE1_DESMAR")
M->VO1_DESMOD := Posicione("VV2",1,xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI,"VV2_DESMOD")
M->VO1_DESCOR := Posicione("VVC",1,xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI,"VVC_DESCRI")

M->VO1_FATPAR := M->VV9_CODCLI
M->VO1_LOJA   := M->VV9_LOJA
M->VO1_NOMFAT := Posicione("SA1",1,xFilial("SA1")+M->VV9_CODCLI+M->VV9_LOJA,"A1_NREDUZ")

dbSelectArea("VVW")
dbSetOrder(1)

For cont := 1 to Len(aAcessor)
	if aAcessor[cont,1]
		if cont > 1
			aadd(aCols_P,Array(nUsado_P+1))
			aCols_P[Len(aCols_P),nUsado_P+1]:=.F.
		Endif
		if VVM->(dbSeek(xFilial("VVM")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD+aAcessor[cont,4])) //Acessorios
			if VVW->(dbSeek(xFilial("VVW")+VV1->VV1_CODMAR+aAcessor[cont,4])) .and. VVW->VVW_OPCSER <> "1" .and. !Empty(VVW->VVW_CODITE)
				aCols_P[Len(aCols_P),FG_POSVAR("VO3_GRUITE","aHeader_P")] := VVW->VVW_GRUITE
				aCols_P[Len(aCols_P),FG_POSVAR("VO3_CODITE","aHeader_P")] := VVW->VVW_CODITE
				aCols_P[Len(aCols_P),FG_POSVAR("VO3_DESITE","aHeader_P")] := VVW->VVW_DESOPC
				aCols_P[Len(aCols_P),FG_POSVAR("VO3_QTDREQ","aHeader_P")] := 1
				aCols_P[Len(aCols_P),FG_POSVAR("VO3_VALPEC","aHeader_P")] := iif(VVM->VVM_VALCON > 0,VVM->VVM_VALCON,VVW->VVW_VALOPC)
				aCols_P[Len(aCols_P),FG_POSVAR("VO3_VALBRU","aHeader_P")] := iif(VVM->VVM_VALCON > 0,VVM->VVM_VALCON,VVW->VVW_VALOPC)
			Endif
		Endif
	Endif
Next

dbSelectArea("VO1")
M->VO1_NUMOSV := GetSxeNum("VO1","VO1_NUMOSV")   

DEFINE MSDIALOG oDlgOSV TITLE STR0101 FROM 9,0 TO 42,80 OF oMainWnd   //Ordem de Servico

aTela    := {}
aGets    := {}
dbSelectArea("VO1")
Zero()
oGetOSV:= MsMGet():New("VO1",0,nOpc,,,,aEncOS,{014,001,120,316},,2,,,,oDlgOSV,,.T.,.F.,,.t.) //,"aSvTela[1]"

@ 121,001 FOLDER oFldOSV SIZE 315,110 OF oDlgOSV PROMPTS STR0102,STR0105 PIXEL //Pecas - Servicos

aHeader    := aClone(aHeader_P)
aCols      := aClone(aCols_P)
n          := n_P := 1
oGetDados_P:= MsGetDados():New(01,1,105,354,nOpc,cLinOk,cTudoOk,"",.T.,,,,,,,,,oFldOSV:aDialogs[1])
oGetDados_P:oBrowse:default()
oGetDados_P:oBrowse:bGotFocus   := {|| n := n_P, aCols := aClone(aCols_P), aHeader := aClone(aHeader_P), oGetDados_P:oBrowse:Refresh()}
oGetDados_P:oBrowse:bLostFocus  := {|| n_P := n, aCols_P := aClone(aCols), aHeader_P := aClone(aHeader), oGetDados_P:oBrowse:Refresh()}

aHeader    := aClone(aHeader_S)
aCols      := aClone(aCols_S)
n          := n_S := 1
oGetDados_S:= MsGetDados():New(01,1,105,354,nOpc,cLinOk,cTudoOk,"",.T.,,,,,,,,,oFldOSV:aDialogs[2])
oGetDados_S:oBrowse:default()
oGetDados_S:oBrowse:bGotFocus   := {|| n := n_S, aCols := aClone(aCols_S), aHeader := aClone(aHeader_S), oGetDados_S:oBrowse:Refresh()}
oGetDados_S:oBrowse:bLostFocus  := {|| n_S := n, aCols_S := aClone(aCols), aHeader_S := aClone(aHeader), oGetDados_S:oBrowse:Refresh()}

@ 237,004 Say OemToAnsi(STR0102) SIZE 40,08 OF oDlgOSV PIXEL COLOR CLR_BLUE  //Pecas
@ 237,030 msget oTotPec VAR nTotPec Picture "@E 999,999.99" SIZE 40,08 OF oDlgOSV PIXEL COLOR CLR_BLACK when .f.
@ 237,080 Say OemToAnsi(STR0105) SIZE 40,08 OF oDlgOSV PIXEL COLOR CLR_BLUE  //Servicos
@ 237,110 msget oTotSrv VAR nTotSrv Picture "@E 999,999.99" SIZE 40,08 OF oDlgOSV PIXEL COLOR CLR_BLACK when .f.
@ 237,163 Say OemToAnsi(STR0106) SIZE 40,08 OF oDlgOSV PIXEL COLOR CLR_BLUE //Descontos
@ 237,194 msget oTotDes VAR nTotDes Picture "@E 999,999.99" SIZE 40,08 OF oDlgOSV PIXEL COLOR CLR_BLACK when .f.
@ 237,245 Say OemToAnsi(STR0107) SIZE 40,08 OF oDlgOSV PIXEL COLOR CLR_BLUE  //Total
@ 237,268 msget oTotOsv VAR nTotOsv Picture "@E 999,999.99" SIZE 40,08 OF oDlgOSV PIXEL COLOR CLR_BLACK when .f.

ACTIVATE MSDIALOG oDlgOSV ON INIT EnchoiceBar(oDlgOSV,{|| GRVOSV011(),oDlgOSV:End() },{|| oDlgOSV:End() } )

aCols   := aClone(aColsSlv)
aHeader := aClone(aHeaderSlv)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VLDVO3011    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida os campos do VO3                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VLDVO3011()

if ReadVar() == "M->VO3_QTDREQ"
	M->VO3_VALBRU := aCols[n,FG_POSVAR("VO3_VALPEC")] * M->VO3_QTDREQ
	aCols[n,FG_POSVAR("VO3_VALBRU")] := M->VO3_VALBRU
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GRVOSV011    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava a Ordem de Servico                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GRVOSV011()

Local cont

Private aOsAbert := {} , aSrv := {} , aPeca := {} , lMovto := .T.
Private lMsErroAuto := .F.

if MsgYesNo(STR0108 ,STR0012) //Grava Ordem de Servico? - Atencao
	
	dbSelectArea("VO1")
	RecLock("VO1",.t.)
	VO1->VO1_FILIAL := xFilial("VO1")
	VO1->VO1_NUMOSV := M->VO1_NUMOSV
	VO1->VO1_CHASSI := VV1->VV1_CHASSI
	VO1->VO1_PROVEI := VV1->VV1_PROATU
	VO1->VO1_LOJPRO := VV1->VV1_LJPATU
	VO1->VO1_PLAVEI := VV1->VV1_PLAVEI
	VO1->VO1_CHAINT := VV1->VV1_CHAINT
	VO1->VO1_FATPAR := M->VV9_CODCLI
	VO1->VO1_LOJA   := M->VV9_LOJA
	VO1->VO1_KILOME := M->VO1_KILOME
	VO1->VO1_DATABE := M->VO1_DATABE
	VO1->VO1_HORABE := M->VO1_HORABE
	VO1->VO1_STATUS := FMX_GRVOSSTAT(VO1->VO1_NUMOSV,"A")
	MsUnlock()
	
	M->VO2_NOSNUM := GetSxeNum("VO2","VO2_NOSNUM")
	ConfirmSx8()
	dbSelectArea("VO2")
	RecLock("VO2",.t.)
	VO2->VO2_FILIAL := xFilial("VO2")
	VO2->VO2_NUMOSV := M->VO1_NUMOSV
	VO2->VO2_NOSNUM := M->VO2_NOSNUM
	VO2->VO2_DEVOLU := "1"
	VO2->VO2_DATREQ := dDataBase
	VO2->VO2_HORREQ := val(left(time(),2)+substr(time(),4,2))
	VO2->VO2_FUNREQ := VAI->VAI_CODTEC
	VO2->VO2_TIPREQ := "P"
	MsUnlock()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PECAS                                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For cont := 1 to Len(aCols_P)
		if !Empty(aCols_P[cont,fg_posvar("VO3_GRUITE","aHeader_P")]) .and. !aCols_P[cont,len(aCols_P[cont])]
			cGrupo  := aCols_P[cont,fg_posvar("VO3_GRUITE","aHeader_P")]
			cCodigo := aCols_P[cont,fg_posvar("VO3_CODITE","aHeader_P")]
			nQtdeEst:= aCols_P[cont,fg_posvar("VO3_QTDREQ","aHeader_P")]
			dbSelectArea("SB1")
			dbSetOrder(7)
			dbSeek(xFilial("SB1")+cGrupo+cCodigo)
			
			Aadd( aPeca , { .T. , "C" , M->VV9_CODCLI , M->VV9_LOJA , SA1->A1_NOME , cGrupo , cCodigo , SB1->B1_DESC , VS3->VS3_QTDITE , VS3->VS3_FORMUL , FG_VALPEC("C","",cGrupo,cCodigo,,.f.,.t. ) , .t. } )
		Endif
	Next
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SERVICOS                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For cont := 1 to Len(aCols_S)
		if !Empty(aCols_S[cont,fg_posvar("VO4_GRUSER","aHeader_S")]) .and. !aCols_S[cont,len(aCols_S[cont])]
			cGruSer := aCols_S[cont,fg_posvar("VO4_GRUSER","aHeader_S")]
			cCodSer := aCols_S[cont,fg_posvar("VO4_CODSER","aHeader_S")]
			cTipSer := aCols_S[cont,fg_posvar("VO4_TIPSER","aHeader_S")]
			cTemPad := aCols_S[cont,fg_posvar("VO4_TEMPAD","aHeader_S")]
			cKilRod := aCols_S[cont,fg_posvar("VO4_KILROD","aHeader_S")]
			nValTot := aCols_S[cont,fg_posvar("VO4_VALVEN","aHeader_S")]
			
			dbSelectArea("VO6")
			dbSetOrder(2)
			dbSeek( xFilial("VO6") + FG_MARSRV(VV1->VV1_CODMAR,cCodSer) + cCodSer )
			Aadd( aSrv , { .T. , "C" , M->VV9_CODCLI , M->VV9_LOJA , SA1->A1_NOME , cGruSer , cCodSer , VO6->VO6_DESSER , cTipSer , cTemPad , cKilRod , nValTot } )
		Endif
	Next
	
	Aadd( aOsAbert , { .T. , VO1->VO1_NUMOSV , VV1->VV1_CHASSI , VV1->VV1_CODMAR , VV1->VV1_MODVEI , VV2->VV2_DESMOD , VV1->VV1_PROATU , VV1->VV1_LJPATU , SA1->A1_NOME , aClone(aSrv) , aClone(aPeca)})
	
	aColsIniFim := {}
	
	If OM210IMP("VO1",0,3) .and. !lMsErroAuto
		VV0->(RecLock("VV0",.F.))
		VV0->VV0_NUMOSV := M->VO1_NUMOSV
		VV0->(MsUnlock())
	EndIf
	
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ADMFAI    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacos do F&I                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ADMFAI(lMsg,lVld)

default lMsg := .t.
default lVld := .f.

if VAR->VAR_APLICA <> "3"
	if val(VAR->VAR_APLICA)-1 <> val(VV1->VV1_ESTVEI)
		if lMsg
			MsgInfo(STR0109 ,STR0012) //Tabela nao se aplica ao estado do veiculo (Novo/Usado)... - Atencao
		Endif
		Return .f.
	Endif
Endif

if VAR->VAR_PESSOA <> "3"
	if (VAR->VAR_PESSOA == "1" .AND. SA1->A1_PESSOA <> "F") .OR. (VAR->VAR_PESSOA == "2" .AND. SA1->A1_PESSOA <> "J")
		if lMsg
			MsgInfo(STR0110 ,STR0012) //Tabela nao se aplica ao tipo de pessoa (Fisica/Juridica)... - Atencao
		Endif
		Return .f.
	Endif
Endif

if !Empty(VAR->VAR_GRUMOD)
	if VAR->VAR_GRUMOD <> VV2->VV2_GRUMOD      // FNC 6471 - BOBY - 01/06/10
		if lMsg
			MsgInfo(STR0111 ,STR0012) //Tabela nao se aplica ao Grupo de Modelo do veiculo (Novo/Usado)... - Atencao
		Endif
		Return .f.
	Endif
Endif

if !Empty(VAR->VAR_MODVEI)
	if VAR->VAR_MODVEI <> VV2->VV2_MODVEI       // FNC 6471 - BOBY - 01/06/10
		if lMsg
			MsgInfo(STR0112 ,STR0012) //Tabela nao se aplica ao Modelo do veiculo (Novo/Usado).. - Atencao
		Endif
		Return .f.
	Endif
Endif
//VERIFICAR A DATA DE VIGENCIA DO F&I PELO FILHO - RAFAEL - ANDRE 
if VAS->(FieldPos("VAS_DATFIN")) <> 0
	if !Empty(VAS->VAS_DATFIN)
		if (VAS->VAS_DATINI > dDataBase) .or. (VAS->VAS_DATFIN < dDataBase)
			if lMsg
				MsgInfo(STR0113 ,STR0012) //Tabela esta fora do periodo de validade... - Atencao
			Endif
			Return .f.
		Endif
	Endif
ElseIf VAR->(FieldPos("VAR_DATFIN")) <> 0
	if !Empty(VAR->VAR_DATFIN)
		if (VAR->VAR_DATINI > dDataBase) .or. (VAR->VAR_DATFIN < dDataBase)
			if lMsg
				MsgInfo(STR0113 ,STR0012) //Tabela esta fora do periodo de validade... - Atencao
			Endif
			Return .f.
		Endif
	Endif
EndIf
//M->VV0_VALTAC := VAS->VAS_VLRTAC

if !lVld
	FS_DADFAI()
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_DADFAI    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega dos dados do F&I                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_DADFAI()

M->VV0_DIA1PC := val(VAS->VAS_PPARVI)
M->VV0_PARCEL := val(VAS->VAS_QTDPAR)
M->VV0_INTERV := val(VAS->VAS_INTERV)
M->VV0_COEFIC := VAS->VAS_COEFIC
M->VV0_PTXRET := VAS->VAS_PERRET
M->VV0_PCOMFN := VAS->VAS_PEPLUS 
M->VV0_VTXRET := (M->VV0_VALTOT / 100) * M->VV0_PTXRET
M->VV0_PCUSFN := VAS->VAS_CUSREC
M->VV0_VCUSFN := (M->VV0_VALTOT / 100) * M->VV0_PCUSFN
M->VV0_TIPFIN := "1"
M->VV0_VALTAC := VAS->VAS_VLRTAC

FS_CALC011()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_SIMFAI    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de simulacao do F&I                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SIMFAI()
Local cCodLoj := ""
Local nValFi  := M->VV0_VALFIN
Local cBanco  := SPACE(TamSx3("VAR_CODBCO")[1])
Local nLinha  := 1
Local nCntFor
Private aTabFAI := {}
//1o Elemento - Indicador de selecao
//2o Elemento - Banco (codigo + descricao)
//3o Elemento - Tabela
//4o Elemento - Descricao da Tabela
//5o Elemento - Quantidade de Parcelas
//6o Elemento - Coeficiente
//7o Elemento - Valor das Parcelas
//8o Elemento - Codigo de Cliente (no SA1) do Banco
//9o Elemento - Percentual de Retorno
                                            
Private aItePar := {} 

//Rafael - 11-01-10 - Pl 20 item 8.2.2.1 Nao permitir a execucao do F&I quando o codigo cliente estiver em branco.

if !FM_PILHA("VEIXA011")
	if Empty(M->VV9_CODCLI)  
		MsgAlert(STR0339 ,STR0012) //"Para prosseguir com a Simulação de F&I é necessário informar o código do Cliente." ### Atencao
		Return .t. 
	EndIf
Endif
if !Empty(M->VV0_FORPAG)
	dbSelectArea("SE4")
	dbSetOrder(1)
	if dbSeek(xFilial("SE4")+M->VV0_FORPAG) .and. SE4->E4_TIPO <> "A"
		If MsgYesNo(STR0275,STR0012) // "A condicao de pagamento atual nao permite simulacao. Deseja altera-la automaticamente?" / "Atencao"
			M->VV0_FORPAG := RetCondVei()
			SE4->(dbSetOrder(1))
			SE4->(dbSeek(xFilial("SE4")+M->VV0_FORPAG))
			M->VV0_DESFPG := SE4->E4_DESCRI
		Else
			Return .t.
		EndIf
	Endif
Else
	If MsgYesNo(STR0276,STR0012) // "Condicao de pagamento nao informada. Deseja altera-la automaticamente?" / "Atencao"
		M->VV0_FORPAG := RetCondVei()
		SE4->(dbSetOrder(1))
		SE4->(dbSeek(xFilial("SE4")+M->VV0_FORPAG))
		M->VV0_DESFPG := SE4->E4_DESCRI
	Else
		Return .t.
	EndIf
Endif

nOpca := 0
cComboFI := space(10)
if VAR->(FieldPos("VAR_TIPTAB")) > 0
    aComboFI := {"0-Todos"}
	aComboFI2 := FS_CBOX("VAR_TIPTAB")  // Cria ComboBox com SX3
	for nCntFor := 1 to Len(aComboFI2)
		aAdd(aComboFI,aComboFI2[nCntFor])
	next
endif
DEFINE MSDIALOG oDlgFAI TITLE OemtoAnsi(STR0114) FROM  01,01 TO 22,76 OF oMainWnd  //Simulacao do F'&'I

@  008, 005 SAY STR0336  SIZE 72,8 OF oDlgFAI PIXEL COLOR CLR_BLUE //Valor Financiado
@  007, 050 MSGET oValFi VAR nValFi PICTURE "@E 99,999,999.99" VALID FS_LISFAI(cBanco,nValFi,cComboFI) SIZE 60,4 OF oDlgFAI PIXEL COLOR CLR_BLACK
@  008, 120 SAY STR0337  SIZE 72,8 OF oDlgFAI PIXEL COLOR CLR_BLUE //Banco
@  007, 145 MSGET oBanco VAR cBanco PICTURE "@!" F3 "VAR" VALID FS_LISFAI(cBanco,nValFi,cComboFI) SIZE 37,4 OF oDlgFAI PIXEL COLOR CLR_BLACK
if VAR->(FieldPos("VAR_TIPTAB")) > 0
	@  008, 200 SAY "Tipo"  SIZE 72,8 OF oDlgFAI PIXEL COLOR CLR_BLUE //Banco
	@  007, 225 MSCOMBOBOX oComboFI VAR cComboFI VALID FS_LISFAI(cBanco,nValFi,cComboFI) SIZE 70,08 ITEMS aComboFI OF oDlgFAI PIXEL COLOR CLR_BLACK
endif

//Lista das tabelas disponiveis para a negociacao
@ 023,001 LISTBOX oLboxFAI FIELDS HEADER;
OemToAnsi(""),;          //Indicador de selecao
OemToAnsi(STR0337),; 	 //Banco
OemToAnsi(STR0116),; 	 //Tabela - Descricao do acessorio
OemToAnsi(STR0061),;     //Valor do acessorio
OemToAnsi(STR0117),;     //Parcelas - Valor do acessorio
OemToAnsi(STR0118),;     //Coeficiente - Crotesia
OemToAnsi(STR0338);      //Valor da Parcela
COLSIZES 8,70,20,45,5,30,40;
SIZE 295,118 OF oDlgFAI PIXEL ON DBLCLICK ( cBanco := Left(aTabFAI[oLboxFAI:nAt,02],3), FS_LISFAI(cBanco,nValFi,cComboFI),FS_MLBFAI(oLboxFAI:nAt) )
//SIZE 281,116 OF oDlgFAI PIXEL ON DBLCLICK ( FS_MLBFAI(oLboxFAI:nAt),FS_CALFAI(cBanco,aTabFAI[oLboxFAI:nAt,03],aTabFAI[oLboxFAI:nAt,05],nValFi) )
//SIZE 180,116 OF oDlgFAI PIXEL ON DBLCLICK ( FS_MLBFAI(oLboxFAI:nAt),FS_CALFAI(cBanco,aTabFAI[oLboxFAI:nAt,02],aTabFAI[oLboxFAI:nAt,04],nValFi) )

if len(aTabFAI) == 0
	aAdd(aTabFAI, { .f.," "," ","",0,0,0,0,0,0} )
Endif

oLboxFAI:SetArray(aTabFAI)
oLboxFAI:bLine := { || { if(aTabFAI[oLboxFAI:nAt,01] == .f.,oNo,oTik),;
aTabFAI[oLboxFAI:nAt,02],;
aTabFAI[oLboxFAI:nAt,03],;
aTabFAI[oLboxFAI:nAt,04],;
FG_AlinVlrs(Transform(aTabFAI[oLboxFAI:nAt,05],"9999")),;
FG_AlinVlrs(Transform(aTabFAI[oLboxFAI:nAt,06],"9.99999999")),;
FG_AlinVlrs(Transform(aTabFAI[oLboxFAI:nAt,07],"999,999.99")) }}

//@ 010, 185 LISTBOX oLbPar FIELDS HEADER  OemToAnsi(STR0119),OemToAnsi(STR0023); //data - valor
//COLSIZES 40,50;
//SIZE 100,129 OF oDlgFAI PIXEL
            
if len(aItePar) == 0
	aAdd(aItePar, { ctod(""),0} )
Endif

//oLbPar:SetArray(aItePar)
//oLbPar:bLine := { || { dToc(aItePar[oLbPar:nAt,1]),;
//Transform(aItePar[oLbPar:nAt,2],"@E 999,999,999.99")}}

//@ 145,001 BUTTON oCalc   PROMPT OemToAnsi(STR0055) OF oDlgFAI SIZE 43,11 PIXEL ACTION (FS_MLBFAI(oLboxFAI:nAt),FS_CALFAI(cBanco,aTabFAI[oLboxFAI:nAt,02],aTabFAI[oLboxFAI:nAt,04],nValFi)) //calcular
@ 145,192 BUTTON oOk     PROMPT OemToAnsi(STR0121) OF oDlgFAI SIZE 43,11 PIXEL ACTION (lRet := .t., nOpca := 1, nLinha := oLboxFAI:nAt ,oDlgFAI:End()) //OK //
@ 145,245 BUTTON oCancel PROMPT OemToAnsi(STR0120) OF oDlgFAI SIZE 43,11 PIXEL ACTION (oDlgFAI:End())  //Cancelar

ACTIVATE MSDIALOG oDlgFAI CENTER


if nOpca == 1

	nLinSalva  := nLinha
	aTabFAISlv := aClone(aTabFAI)
	FS_DADFAI()
	nLinha  := nLinSalva
	aTabFAI := aClone(aTabFAISlv)
	
//	M->VV0_FORPAG := RetCondVei()
	M->VV0_CODBCO := Left(aTabFAI[nLinha,02],3)
	M->VV0_TABFAI := aTabFAI[nLinha,03]
	M->VV0_DESFAI := aTabFAI[nLinha,04]
	M->VV0_COEFIC := aTabFAI[nLinha,06]
	M->VV0_VALPAR := aTabFAI[nLinha,07]

	oLbParc:SetArray(aIteParc)
	oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
	Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}

	dbSelectArea("VAS")
	If aTabFAI[nLinha,10] > 0
		dbGoto(aTabFAI[nLinha,10])
		cCodLoj := aTabFai[nLinha,8]
	
	
		FS_DADFAI()
		
		DbSelectArea("VSA")
		DbSetorder(0)
		Dbgotop()
	    cTipPgVs9 := ""
	    cDesPgVs9 := ""
		While !eof()
			If !Empty(VSA->VSA_CODCLI) .and. VSA->VSA_CODCLI+VSA->VSA_LOJA == cCodLoj
			   cTipPgVs9 := VSA->VSA_TIPPAG
			   cDesPgVs9 := VSA->VSA_DESPAG
			   exit
			Endif                          
			DbSkip()
		Enddo
		
		nPos := aScan(aColsC,{|x| x[1] == cTipPgVs9 })
		If nPos == 0
		    If Len(aColsC) == 0 .or. (Len(aColsC) == 1 .and. !Empty(aColsC[1,1]))
				AADD(aColsC,Array(nUsadoC+1))
			Endif		
			aColsC[Len(aColsC),FG_POSVAR("VS9_TIPPAG","aHeaderC")] := cTipPgVs9
			aColsC[Len(aColsC),FG_POSVAR("VS9_DESPAG","aHeaderC")] := cDesPgVs9
			aColsC[Len(aColsC),FG_POSVAR("VS9_DATPAG","aHeaderC")] := dDataBase
			aColsC[Len(aColsC),FG_POSVAR("VS9_VALPAG","aHeaderC")] := nValFi
			aColsC[Len(aColsC),FG_POSVAR("VS9_SEQUEN","aHeaderC")] := StrZero(Len(aColsC),2)
			aColsC[Len(aColsC),nUsadoC+1] := .F.	
		Else
		    If   !aColsC[nPos,Len(aColsC[nPos])]
				aColsC[nPos,FG_POSVAR("VS9_VALPAG","aHeaderC")] := nValFi
			Else
			    If Len(aColsC) > 1 .or. (Len(aColsC) == 1 .and. !Empty(aColsC[1,1]))
					AADD(aColsC,Array(nUsadoC+1))
				Endif		
				aColsC[Len(aColsC),FG_POSVAR("VS9_TIPPAG","aHeaderC")] := cTipPgVs9
				aColsC[Len(aColsC),FG_POSVAR("VS9_DESPAG","aHeaderC")] := cDesPgVs9
				aColsC[Len(aColsC),FG_POSVAR("VS9_DATPAG","aHeaderC")] := dDataBase
				aColsC[Len(aColsC),FG_POSVAR("VS9_VALPAG","aHeaderC")] := nValFi
				aColsC[Len(aColsC),FG_POSVAR("VS9_SEQUEN","aHeaderC")] := StrZero(Len(aColsC),2)
				aColsC[Len(aColsC),nUsadoC+1] := .F.	
			Endif
		Endif                                           
	EndIf
	M->VV0_VALFIN := nValFi
	M->VV0_VALRES := M->VV0_VALTOT-M->VV0_TOTENT-M->VV0_VALFIN

	oGetMGet3:Refresh()
	oGetMGet3:SetFocus()
	oGetCondicao:oBrowse:Refresh()
	oGetCondicao:oBrowse:SetFocus()
Else
	aIteParc := {{cTod(""),0}}
Endif

if Type("oLbParc") <> "U"
	oLbParc:SetArray(aIteParc)
	oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
	Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
	oLbParc:Refresh()
Endif
lJaCal011 := .f.
FS_CALC011()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LISFAI    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lista as tabelas no listbox                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_LISFAI(cBco,nVF,cTab)
Local nValFin := nVF     
Local nValPar := 0
//Local cWhen
//Local cBanco  := cBco 
//
cBco := Left(cBco + space(100),TamSx3("VAS_CODBCO")[1])
//
if !Empty(cTab)
	cTab := Left(cTab,1)
	if cTab == "0"
		cTab := ""
	endif
endif
//	
aTabFAI := {}
//
If nVF > 0 .and. (getNewPar("MV_FIALLBC","S") == "S" .or. !Empty(cBco))
	dbSelectArea("VAR")
	dbSetOrder(1)
	
	dbSelectArea("VAS")
	dbSetOrder(1)
	DBGoTop()
	
	While !Eof() .and. VAS->VAS_FILIAL == xFilial("VAS") 
		If !Empty(cBco) 
			if VAS->VAS_CODBCO != cBco
				DBSkip()
				loop
			endif
		endif
		If !Empty(cTab) 
			if VAS->VAS_TIPTAB != cTab
				DBSkip()
				loop
			endif
		endif
		if VAR->(dbSeek(xFilial("VAR")+VAS->VAS_CODBCO+VAS->VAS_CODIGO+cTab))
			if FS_ADMFAI(.F.,.t.)
				nValFin := nVF	
				if VAR->VAR_TACFIN == "1"
					nValFin += VAS->VAS_VLRTAC
				Endif	
				if VAS->VAS_COEFIC > 0
					nValPar := (nValFin) * VAS->VAS_COEFIC
				Endif
				aadd(aTabFAI,{.f.,VAR->VAR_CODBCO+"-"+Left(VAR->VAR_NOMBCO,14)+" Tipo "+cTab,VAR->VAR_CODIGO,VAR->VAR_DESCOD,Val(VAS->VAS_QTDPAR),VAS->VAS_COEFIC,nValPar,Iif(VAR->(FieldPos("VAR_BCOCLI"))>0,VAR->VAR_BCOCLI+VAR->VAR_BCOLOJ,Space(8)),VAS->VAS_PERRET,VAS->(Recno())})
			Endif
		Endif
		dbSelectArea("VAS")
		dbSkip()
	Enddo
	Asort(aTabFAI,,,{|x,y| x[9] > y[9] })
Endif
	
if len(aTabFAI) == 0
	aAdd(aTabFAI, { .f.," "," ","",0,0,0,0,0,0} )
Endif

if Type("oLboxFAI") <> "U"
	oLboxFAI:SetArray(aTabFAI)
	oLboxFAI:bLine := { || { if(aTabFAI[oLboxFAI:nAt,01] == .f.,oNo,oTik),;
	aTabFAI[oLboxFAI:nAt,02],;
	aTabFAI[oLboxFAI:nAt,03],;
	aTabFAI[oLboxFAI:nAt,04],;
	FG_AlinVlrs(Transform(aTabFAI[oLboxFAI:nAt,05],"@E 9999")),;
	FG_AlinVlrs(Transform(aTabFAI[oLboxFAI:nAt,06],"@E 9.99999999")),;
	FG_AlinVlrs(Transform(aTabFAI[oLboxFAI:nAt,07],"@E 999,999.999")) }}
	oLboxFAI:Refresh()
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_MLBFAI    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula as parcelas da tabela do F&I                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_MLBFAI(nLinha)

Local cont

For cont := 1 to Len(aTabFAI)
	aTabFAI[cont,1] := (cont == nLinha)
Next

oLboxFAI:Refresh()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CALFAI    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula as parcelas da tabela do F&I                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CALFAI(cBco,cTab,cPar,nValFi)

Local cont
Local nValFin := iIf(nValFi==0,Iif(M->VV0_VALFIN==0,M->VV0_VALTOT,M->VV0_VALFIN),nValFi)
Local nValPar := 0
//Local nValFin := M->VV0_VALTOT

If !Empty(cBco)

	dbSelectArea("VAS")
	dbSetOrder(1)
	dbSeek(xFilial("VAS")+cBco+cTab+cPar)
	
	DbSelectArea("VAR")
	DbSeek(xFilial("VAR")+cBco)
	if VAR->VAR_TACFIN == "1"
		nValFin += VAS->VAS_VLRTAC
	Endif	
//	M->VV0_FORPAG := RetCondVei()
	
	// Estou somando nValFi no 7o parametro para que no FG_CONDICAO nao seja descontado o Valor da Entrada.
	FG_CONDICAO(dDataBase,strzero(val(VAS->VAS_PPARVI),4),strzero(val(VAS->VAS_QTDPAR),4),strzero(val(VAS->VAS_INTERV),4),"1","VV0_FORPAG",nValFin)
	//aItePar := aclone(aIteParc)
	
	if VAS->VAS_COEFIC > 0
		//   nValPar := (iIf(Empty(M->VV0_VALFIN),M->VV0_VALTOT-M->VV0_TOTENT,M->VV0_VALFIN)) * VAS->VAS_COEFIC
	//	nValPar := (M->VV0_VALTOT-M->VV0_TOTENT) * VAS->VAS_COEFIC
		nValPar := (nValFin) * VAS->VAS_COEFIC
		For cont := 1 to Len(aItePar)
			aItePar[cont,2] := nValPar
		Next
	    
	Endif
Endif	

//if Type("oLbPar") <> "U"
//	oLbPar:SetArray(aItePar)
//	oLbPar:bLine := { || { dToc(aItePar[oLbPar:nAt,1]),;
//	Transform(aItePar[oLbPar:nAt,2],"@E 999,999,999.99")}}
//	oLbPar:Refresh()
//Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_MARCA011  ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Marca o veiculo do estoque selecionado                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MARCA011()
Local aRet    := {}
Local cSavAlias := Alias()
Local i := 0
Local dDtMov  := ctod("")
Local cQuery  := ""
Local cQAlVVF := "SQLVVF" // VVF
Local cAux    := ""
Local lAchou := .f.
Local aMemos  := {{"VV9_OBSMEM","VV9_OBSERV"}}
Local p_, _ni
Local lDelVV0 := .t.
Local cLocVei := ""
Local cSQL    := ""
Local lAtePend := .f.
Local cAtePend := ""
Local lStatBlq := .f. // Status que bloqueia Atendimento de um veiculo com outro Atendimento com STATUS contido no MV_BLQSTAV
Local aLeg := {{'A','lbok_ocean'     ,STR0217},; //Em Aberto com Veiculo ja Vendido 
{'A','BR_VERDE'       ,STR0216},; //Atendimento em Aberto
{'F','BR_PRETO'       ,STR0218},; //Atendimento Finalizado 
{'T','BR_PRETO'       ,STR0218},; //Atendimento Finalizado 
{'P','BR_AMARELO'     ,STR0220},; //Pendente de Aprovacao
{'R','BR_LARANJA'     ,STR0221},; //Atendimento Reprovado
{'O','BR_BRANCO'      ,STR0222},;//Pre-Aprovado
{'L','BR_AZUL'        ,STR0223},; //Aprovado
{'C','BR_VERMELHO'    ,STR0224}} //Atendimento Cancelado
For i := 1 to len(aStruVV1)
	If aStruVV1[i,1] .and. i # oLBox:nat
		aStruVV1[i,1] := .f.
	ElseIf aStruVV1[i,1]
		lDelVV0 := .f.	
	Endif
Next
If lDelVV0 // Apaga CHASSI quando nenhum Veiculo foi selecionado
	M->VV0_CHASSI := space(len(VV1->VV1_CHASSI))
EndIf
lFiltro  := .f.
lCalcVEI := .t.
lFatura  := .t.
cBlqFat  := ""  
Do Case 
	Case aStruVV1[oLbox:nAt,2] == "R" //Veiculo de Remessa
		lFatura := .f.
		cBlqFat := STR0122+" "+aStruVV1[oLbox:nAt,14] 
		MsgInfo(cBlqFat,STR0012)
		//Return .t.
	Case aStruVV1[oLbox:nAt,2] == "T" //Veiculo em Transito 
		lFatura := .f.			
		If VAI->(FieldPos("VAI_ESTNEG")) <> 0
		   If VAI->VAI_ESTNEG == "1" // Permite Faturar sem Estoque
				lFatura := .t.
			Else
				lFatura := .f.			
			Endif
		Endif
		cBlqFat := STR0123 
		MsgInfo(STR0123,STR0012)
		//Return .t.
	Case aStruVV1[oLbox:nAt,2] == "C" //Veiculo de Consignacao
		lFatura := .f.
		cBlqFat := STR0124+" "+aStruVV1[oLbox:nAt,14] 
		MsgInfo(cBlqFat,STR0012)
		//Return .t.
	Case aStruVV1[oLbox:nAt,2] == "B" // Veiculo Bloqueado
		lFatura := .f.
		lSelect := .f.
EndCase

dbSelectArea("VV1")
dbSetOrder(2) //Filial+Chassi
If Empty(xFilial("VV1"))
	dbSeek(xFilial("VV1")+aStruVV1[oLbox:nAt,5])
Else
	dbSeek(aStruVV1[oLbox:nAt,15]+aStruVV1[oLbox:nAt,5])
EndIf
if !aStruVV1[oLbox:nAt,1]
	if aStruVV1[oLbox:nAt,2] == "B"
		MsgInfo(STR0126,STR0012) //Este veiculo nao podera ser selecionado pois encontra-se reservado! - Atencao
		Return .f.
	Endif
Endif

//Ponto de Entrada - No momento da Selecao do Veiculo
If ExistBlock("VM011SELVEI")
	If !ExecBlock("VM011SELVEI",.f.,.f.)
		return .f.
	Endif
Endif

If aStruVV1[oLbox:nAt,2] == "N" // Verifica se o Veiculo esta em Estoque quando LISTBOX mostra ESTOQUE
	cLocVei := VV1->VV1_LOCPAD
	if Empty(VV1->VV1_LOCPAD)
		cLocVei := GETMV("MV_LOCVEIN") //Novo
		if VV1->VV1_ESTVEI == '1'
			cLocVei := GETMV("MV_LOCVEIU") //Usado
		Endif
	Endif
	If Empty(cLocVei)       //FNC 20246 - Boby-Antonio - 08/09/10
		MsgInfo(STR0355,STR0012)//"Parâmetro(s) MV_LOCVEIN ou MV_LOCVEIU vazio(s), para prosseguir você deve preenchê-lo(s)" //Atencao
		Return
	EndIf
	SB1->(dbSetOrder(7))
	If SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
		SB2->(dbSetOrder(1))
		if !SB2->(dbSeek(aStruVV1[oLbox:nAt,15]+SB1->B1_COD+cLocVei)) .or. SB2->B2_QATU <= 0
			MsgInfo(STR0160,STR0012) //Veiculo nao esta no estoque! - Atencao
			lAchou := .t.
		Endif
	Else
		MsgInfo(STR0160,STR0012) //Veiculo nao esta no estoque! - Atencao
		lAchou := .t.
	Endif
EndIf

//Valida se esta desmarcando um veiculo reservado no atendimento
if !Inclui
	if aStruVV1[oLbox:nAt,1]
		if VV1->VV1_RESERV $ "1/3" .and. VV0->VV0_RESERV $ "1/3"
			if MsgYesNo(STR0127,STR0012) //Este veiculo esta reservado para este atendimento, a reserva sera cancelada, continua? - Atencao
				/*
				dbSelectArea("VV1")
				RecLock("VV1",.f.)
				VV1->VV1_RESERV := ""
				VV1->VV1_DTHRES := ""
				VV1->VV1_DTHVAL := ""
				MsUnlock()
				
				dbSelectArea("VV0")
				RecLock("VV0",.f.)
				VV0->VV0_RESERV := ""
				VV0->VV0_DATVAL := CTOD("")
				VV0->VV0_HORVAL := ""
				MsUnlock()
				*/
				
				cChaRes := VV1->VV1_CHASSI
				lJaPer011 := .f.
				aStruVV1[oLbox:nAt,2] := "N"
				M->VV0_RESERV := ""
				M->VV0_DATVAL := CTOD("")
				M->VV0_HORVAL := "     "
				M->VVA_CHASSI := ""
				M->VVA_CHAINT := ""
				
				If FindFunction("VEIVM130TAR")
					VEIVM130TAR(M->VV0_NUMTRA,"8") // 0-Verifica/Valida / 1-Gravacao / 2-Finalizacao / 3-Pelo Usuario / 4-Pendente Aprovacao / 5-Pre-Aprovado / 6-Aprovado / 7-Reserva / 8-Cancela Reserva / 9-Cancela Atendimento
				EndIf

			Else
				Return .f.
			Endif
		Endif
	Endif
Endif

//Traz o TES padrao para esta operacao de saida (S) normal (N)
dbSelectArea("VZA")
dbSetOrder(1)
if dbSeek(xFilial("VZA")+"SN"+VV1->VV1_ESTVEI)
	M->VV0_CODTES := VZA->VZA_CODTES
Endif

//If Empty(VV1->VV1_FILIAL)
SB1->(dbSetOrder(7))
SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
If !SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+VV1->VV1_LOCPAD)) .or. SB2->B2_QATU <= 0
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+M->VV0_CODTES))
	If SF4->F4_ESTOQUE == "S" // TES Movimenta Estoque
		If VAI->(FieldPos("VAI_ESTNEG")) <> 0
		   If VAI->VAI_ESTNEG != "1" // nao Permite Faturar sem Estoque
				lFatura := .f.
				cBlqFat := STR0128  //Veiculo nao esta no estoque ou pertence a outra filial
			EndIf
		Else
			lFatura := .f.
			cBlqFat := STR0128  //Veiculo nao esta no estoque ou pertence a outra filial
		EndIf
	EndIf
EndIf
//EndIf

// Mostra TELA se o Veiculo estiver BLOQUEADO
If FindFunction("VM060VEIBLO")
	aRet := VM060VEIBLO(VV1->VV1_CHAINT,"B") // Verifica se o Veiculo esta Bloqueado, retorna registro do Bloqueio.
    If len(aRet) > 0
    	DEFINE FONT oFBloqVei NAME "Arial" SIZE 07,13 BOLD
		lFatura := .f.
		cBlqFat := STR0129 +" "+aRet[1,1]+CHR(13)+CHR(10)+CHR(13)+CHR(10) 	//Veiculo Bloqueado por
		cBlqFat += STR0130 + CHR(13)+CHR(10) + aRet[1,2] + CHR(13)+CHR(10)+CHR(13)+CHR(10)  // Motivo:
		cBlqFat += STR0131 +" "+aRet[1,3]  	//Validade:
		DEFINE MSDIALOG oBloqVei FROM 000,000 TO 011,055 TITLE (STR0132+" "+aStruVV1[oLbox:nAt,5]) OF oMainWnd 	//Veiculo Bloqueado:
		@ 015,015 SAY VAI->VAI_NOMUSU SIZE 180,08 OF oBloqVei PIXEL COLOR CLR_BLUE FONT oFBloqVei
		DEFINE SBUTTON FROM 013,175 TYPE 1 ACTION (oBloqVei:End()) ENABLE OF oBloqVei // Botao OK
		@ 030,013 SAY cBlqFat SIZE 240,60 OF oBloqVei PIXEL COLOR CLR_HRED FONT oFBloqVei
		@ 005,007 TO 077,211 LABEL "" OF oBloqVei PIXEL // Caixa Sair
		ACTIVATE MSDIALOG oBloqVei CENTER
	EndIf
EndIf

if GetNewPar("MV_VEIOUFI","N")  <> "S"
	If !Empty(xFilial("VV1")) .and. xFilial("VV1") # aStruVV1[oLbox:nAt,15] .and. !Empty(aStruVV1[oLbox:nAt,5])
		DEFINE FONT oFBloqVei NAME "Arial" SIZE 08,13 BOLD
		lFatura:= .f.
		cBlqFat:= STR0133 +" "+aStruVV1[oLbox:nAt,15]+"."+CHR(13)+CHR(10)+CHR(13)+CHR(10) //Veiculo encontra-se na Loja
		cQuery := "SELECT VVF.VVF_FILIAL , VVF.VVF_DATMOV FROM "+RetSqlName("VVF")+" VVF , "+RetSqlName("VVG")+" VVG "
		cQuery += "WHERE VVF.VVF_FILIAL=VVG.VVG_FILIAL AND VVF.VVF_TRACPA=VVG.VVG_TRACPA AND VVG.VVG_CHASSI='"+aStruVV1[oLbox:nAt,5]+"' AND "
		cQuery += "VVF.VVF_OPEMOV='0' AND VVF.D_E_L_E_T_=' ' AND VVG.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVVF, .F., .T. )
		While !( cQAlVVF )->( Eof() )
			If dDtMov < stod( ( cQAlVVF )->( VVF_DATMOV ) )
				dDtMov := stod( ( cQAlVVF )->( VVF_DATMOV ) )
				cAux   := STR0134 +" "+( cQAlVVF )->( VVF_FILIAL )+" "+ STR0135 +" "+Transform(stod(( cQAlVVF )->( VVF_DATMOV )),"@D")+"." 		 //Adquirido pela Loja ### em
			EndIf
			( cQAlVVF )->( DbSkip() )
		End
		( cQAlVVF )->( dbCloseArea() )
		cBlqFat += cAux
		DEFINE MSDIALOG oBloqVei FROM 000,000 TO 011,055 TITLE (STR0136 +" "+aStruVV1[oLbox:nAt,5]) OF oMainWnd     //Veiculo:
		@ 015,015 SAY VAI->VAI_NOMUSU SIZE 180,08 OF oBloqVei PIXEL COLOR CLR_BLUE FONT oFBloqVei
		DEFINE SBUTTON FROM 013,175 TYPE 1 ACTION (oBloqVei:End()) ENABLE OF oBloqVei // Botao OK
		@ 040,015 SAY cBlqFat SIZE 240,60 OF oBloqVei PIXEL COLOR CLR_HRED FONT oFBloqVei
		@ 005,007 TO 077,211 LABEL "" OF oBloqVei PIXEL // Caixa Sair
		ACTIVATE MSDIALOG oBloqVei CENTER
		DbSelectArea("VV1")
		Return()
	EndIf
Else
	If Empty(xFilial("VV1"))
		cFilSelVV1 := xFilial("VV1")
	Else
		cFilSelVV1 := aStruVV1[oLbox:nAt,15]
	EndIf
	cFilAntVV1 := cFilSelVV1
	if !Inclui
		if VV0->(FieldPos("VV0_FILCHA")) <> 0
			cFilAntVV1 := VV0->VV0_FILCHA
		Endif
	Endif
Endif

If aStruVV1[oLbox:nAt,1] == .f. .and. !Empty(aStruVV1[oLbox:nAt,5])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rubens - 24/11/2009                                                       ³
	//³Exibe uma mensagem se ja existir um atendimento em aberto do mesmo veiculo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := "SELECT VVA_FILIAL, VVA_CHASSI, VVA_CHAINT, VV0_CODVEN, VV9_STATUS, VV9_NUMATE, A3_NOME, VV9_STATUS"
	cSQL +=  " FROM "+RetSQLName("VVA")+" VVA , "+RetSQLName("VV0")+" VV0, "+RetSQLName("VV9")+" VV9, "+RetSQLName("SA3")+" A3"
	cSQL += " WHERE VVA_FILIAL IN "+FormatIN(FM_ALLFIL("VVA"),",")
	cSQL +=   " AND VVA_CHAINT = '"+VV1->VV1_CHAINT+"'"
	cSQL +=   " AND VVA.D_E_L_E_T_ = ' '"
	cSQL +=   " AND VV0_FILIAL = VVA_FILIAL"
	cSQL +=   " AND VV0_NUMTRA = VVA_NUMTRA"
	cSQL +=   " AND VV0.D_E_L_E_T_ = ' '"
	cSQL +=   " AND VV9_FILIAL = VVA_FILIAL"
	cSQL +=   " AND VV9_NUMATE = VV0_NUMTRA"
	cSQL +=   " AND VV9_STATUS NOT IN ('C','F','T','R','D')" // Considerar somente atendimento em aberto 
	cSQL +=   " AND VV9.D_E_L_E_T_ = ' '"
	cSQL +=   " AND A3.A3_FILIAL = '"+xFilial("SA3")+"' "
	cSQL +=   " AND A3.A3_COD = VV0_CODVEN"
	cSQL +=   " AND A3.D_E_L_E_T_ = ' '	"
	cSQL += " ORDER BY VVA_FILIAL, VV9_NUMATE"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), "TATEND" , .F., .T. )
	cSQL := ""
	While !TATEND->(Eof())
		cSQL += AllTrim(RetTitle("VVA_FILIAL"))+": "+TATEND->VVA_FILIAL + CHR(13) + CHR(10) +;
				  AllTrim(RetTitle("VV9_NUMATE"))+": "+TATEND->VV9_NUMATE + CHR(13) + CHR(10) + ;
				  AllTrim(RetTitle("VV9_STATUS"))+": "+If(TATEND->VV9_STATUS=='A',IIf((VV1->VV1_SITVEI == "1"),STR0217,STR0216),aLeg[aScan(aLeg,{|x| x[1] == TATEND->VV9_STATUS}),3]) + CHR(13) + CHR(10) + ;
				  AllTrim(RetTitle("VV0_CODVEN"))+": "+AllTrim(TATEND->A3_NOME) + CHR(13) + CHR(10) + Replicate("-",87) + CHR(13) + CHR(10)				  

		If TATEND->VV9_STATUS $ GetNewPar("MV_BLQSTAV","L.O") // STATUS de outro Atendimento do mesmo Veículo que bloqueia novo Atendimento
		   lStatBLQ := .t.
		Endif
		If TATEND->VV9_STATUS == "P"
			lAtePend := .t.
			cAtePend += TATEND->VV9_NUMATE + space(1)
		EndIf					  
		TATEND->(dbSkip())
	EndDo
	TATEND->(dbCloseArea())
	If !Empty(cSQL)
	  If lStatBLQ 
		  Aviso(STR0349,STR0322+chr(13)+chr(10)+chr(13)+chr(10)+cSQL, {STR0121} , 3)  
		  Return .f.
	  Else
			Aviso(STR0265,STR0322+chr(13)+chr(10)+chr(13)+chr(10)+cSQL, {STR0121} , 3)
     Endif
	EndIf
	
	If lAtePend .and. !GetMv("MV_AUTPEN")
		Aviso(STR0345,STR0346 + cAtePend + STR0347,{"OK"}, 2)
		Return .f.
	EndIf
	
	if !lAchou 
		aStruVV1[oLbox:nAt,1] := .t.
	Else
	    if getnewpar("MV_SELFEST","S") == "N" // Se S ,permite selecao de veiculo fora do estoque. Se N nao permite.
			aStruVV1[oLbox:nAt,1] := .f.
		Else
			aStruVV1[oLbox:nAt,1] := .t.
		Endif	
	Endif
/*	if !Inclui
		aAreaVV1 := GetArea()
		dbSelectArea("VV1")
		dbSetOrder(2)
		dbSeek(cFilAntVV1+M->VV0_CHASSI)
		if aStruVV1[oLbox:nAt,5] <> M->VV0_CHASSI
			If !Empty(M->VV9_OBSERV)
				M->VV9_OBSERV += Chr(13)+Chr(10)
			EndIf
			M->VV9_OBSERV += "*** "+left(Alltrim(UsrRetName(__CUSERID)),15)+" "+Transform(dDataBase,"@D")+"-"+Transform(time(),"@R 99:99")+" ***"+Chr(13)+Chr(10)
			if !Empty(M->VV0_CHASSI)
				M->VV9_OBSERV += "*** "+VV1->VV1_CHASSI+" - "+VV1->VV1_MODVEI+" - "+Transform(M->VV0_VALTOT,"@E 999,999.99")+" ***"
			Else
				M->VV9_OBSERV += "*** "+ STR0137 +" - "+VV1->VV1_MODVEI+" - "+Transform(M->VV0_VALTOT,"@E 999,999.99")+" ***"     //VENDA ANTECIPADA
			Endif
		Endif
		RestArea(aAreaVV1)
	Endif*/
	
	dbSelectArea("VV1")
	dbSetOrder(2) //Filial+Chassi
	If Empty(xFilial("VV1"))
		dbSeek(xFilial("VV1")+aStruVV1[oLbox:nAt,5])
	Else
		dbSeek(aStruVV1[oLbox:nAt,15]+aStruVV1[oLbox:nAt,5])
	EndIf
	
	If M->VV0_TIPFAT <> "2"
		M->VV0_TIPFAT := iif(!empty(VV1->VV1_ESTVEI),VV1->VV1_ESTVEI,"0")
	Endif
	
//	M->VV0_SIMULA := "0"
	M->VV0_OPEMOV := "0"
	
	M->VVA_CHASSI := VV1->VV1_CHASSI
	M->VVA_CHAINT := VV1->VV1_CHAINT
	
	
	M->VV0_CHASSI := aStruVV1[oLbox:nAt,5]
	M->VV0_VALMOV := aStruVV1[oLbox:nAt,9]
	M->VV0_VALTOT := aStruVV1[oLbox:nAt,9] + nAcresFin
	if VV0->(FieldPos("VV0_VALTAB")) > 0
		M->VV0_VALTAB := aStruVV1[oLbox:nAt,9]
	Endif
	
	M->VV0_CODMAR := VV1->VV1_CODMAR
	M->VV0_MODVEI := VV1->VV1_MODVEI
	M->VV0_FABMOD := VV1->VV1_FABMOD
	M->VV0_PLAVEI := VV1->VV1_PLAVEI
	M->VV0_CHAINT := VV1->VV1_CHAINT
	
	VE1->(dbSetOrder(1))
	VE1->(dbSeek(xFilial("VE1")+VV1->VV1_CODMAR))
	M->VV0_DESMAR := VE1->VE1_DESMAR
	VV2->(dbSetOrder(1))
	VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	M->VV0_DESMOD := VV2->VV2_DESMOD
	VVR->(dbSetOrder(2))
	VVR->(dbSeek(xFilial("VVR")+VV1->VV1_CODMAR+VV2->VV2_GRUMOD))
	M->VV0_GRUMOD := VV2->VV2_GRUMOD
	M->VV0_DESGRU := VVR->VVR_DESCRI
	
	VVC->(dbSetOrder(1))
	VVC->(dbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))
	M->VV0_CORVEI := VVC->VVC_CORVEI
	M->VV0_DESCOR := VVC->VVC_DESCRI

	VVF->(dbSetOrder(1))
	if VVF->(dbSeek(xFilial("VVF")+VV1->VV1_TRACPA))
		VVG->(dbSetOrder(1))
		VVG->(dbSeek(xFilial("VVG")+VV1->VV1_TRACPA))
		M->VVA_VALREV := VVG->VVG_VALREV
  Endif
  
	SB1->(dbSetOrder(7))
	SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))
	
	lEstVir := .f.
// Manoel - 01/03/2010 - ficou desnecessario com a utilizacao da FGX_AMOVVEI		
/*
	if Alltrim(VV1->VV1_SITVEI) == ""
		if !Empty(VV1->VV1_STATUS) .and. Empty(VV1->VV1_TRACPA)
			dbSelectArea("VAE")
			dbSetOrder(1)
			if (dbSeek(xFilial("VAE")+VV1->VV1_STATUS) .and. VAE->VAE_LIBSP == "1")
				lFatura := .t.
				lEstVir := .t.
				M->VV0_TIPFAT := "3"
//				M->VV0_SIMULA := "1" //Sim
				M->VV0_OPEMOV := "1" //Simulacao
			Endif
		Endif
	Endif
*/	
Else
	M->VV0_CHASSI  := Space(25)
	M->VV0_CHAINT  := Space(06)
	M->VV0_CODMAR  := Space(3)
	M->VV0_MODVEI  := Space(30)
	M->VV0_CORVEI  := Space(6)
	M->VV0_VALMOV  := 0
	aStruVV1[oLbox:nAt,1] := .f.
Endif

oLbox:SetArray(aStruVV1)
oLbox:bLine := { || { IIf(!aStruVV1[oLbox:nAt,01],oNo,oTik),;
IIf(aStruVV1[oLbox:nAt,02]=="N",oBranco,IIf(aStruVV1[oLbox:nAt,02]=="V",oVerde,IIf(aStruVV1[oLbox:nAt,02]=="T",oLaranja,IIf(aStruVV1[oLbox:nAt,02]=="R",oVermelho,IIf(aStruVV1[oLbox:nAt,02]=="C",oAzul,IIf(aStruVV1[oLbox:nAt,02]=="A",oPreto,oAmarelo)))))),;
IIf(!aStruVV1[oLbox:nAt,03],oNada,oFoto),;
aStruVV1[oLbox:nAt,15],;
aStruVV1[oLbox:nAt,04],;
aStruVV1[oLbox:nAt,05],;
transform(aStruVV1[oLbox:nAt,16],VV1->(x3Picture("VV1_PLAVEI"))),;
aStruVV1[oLbox:nAt,06],;
aStruVV1[oLbox:nAt,07],;
aStruVV1[oLbox:nAt,08],;
Fg_AlinVlrs(Transform(aStruVV1[oLbox:nAt,09],"@E 9,999,999.99")),;
aStruVV1[oLbox:nAt,10],;
aStruVV1[oLbox:nAt,11],;
aStruVV1[oLbox:nAt,12],;
aStruVV1[oLbox:nAt,13],;
aStruVV1[oLbox:nAt,14]} }

lSelect := aStruVV1[oLbox:nAt,1] == .t.

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MARACE011    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Marca/Desmarca o acessorio para compor no valor do veiculo ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MARACE011(lMarca)

Local cont
default lMarca := .t.

if aAcessor[oLboxAce:nAt,6]
	Return
Endif

if lMarca
	If aAcessor[oLboxAce:nAt,1] == .f.
		aAcessor[oLboxAce:nAt,1] := .t.
	Else
		aAcessor[oLboxAce:nAt,1] := .f.
	Endif
Endif

oLboxAce:SetArray(aAcessor)
oLboxAce:bLine := { || { if(aAcessor[oLboxAce:nAt,01] == .f.,oNo,iif(aAcessor[oLboxAce:nAt,06],oChecked,oTik)),;
aAcessor[oLboxAce:nAt,02],;
FG_AlinVlrs(Transform(aAcessor[oLboxAce:nAt,03],"9,999,999.99")),;
iif(aAcessor[oLboxAce:nAt,05] == .f.,oNada,oGratis) }}
oLboxAce:Refresh()

nAcessor := 0
For cont := 1 to Len(aAcessor)
	if aAcessor[cont,1] .and. !aAcessor[cont,5]
		nAcessor := nAcessor + aAcessor[cont,3]
	Endif
Next

nAceTer := 0
For cont := 1 to Len(aColsTC)
	if !aColsTC[cont,Len(aColsTC[cont])]
		nAceTer += aColsTC[cont,FG_POSVAR("VV6_VALEQP","aHeaderTC")]
	Endif
Next

nValor := 0
//if Empty(M->VV0_VALFIN)
//	For cont :=1 to Len(aIteParc)
//	   if aIteParc[cont,2] > 0
//	      nValor += aIteParc[cont,2]
//	   Endif
//	Next
//Endif

if VV0->(FieldPos("VV0_IMPOST")) <> 0
	nImpost := M->VV0_IMPOST
Endif

M->VV0_ACESSO := nAcessor+nKits+nAceTer

M->VV0_VALTOT := (M->VV0_VALMOV + M->VV0_ACESSO) + Round(nAcresFin,2) // Considerar o valor de Acessorios no Valor Total  //

//M->VV0_VALTOT := (M->VV0_VALMOV + M->VV0_ACESSO) - M->VV0_VALDES
//M->VV0_VALRES := (M->VV0_VALTOT - nImpost) - M->VV0_TOTENT - M->VV0_VALFIN - nValor
M->VV0_VALRES := (M->VV0_VALTOT - nImpost) - M->VV0_TOTENT - M->VV0_VALFIN
if M->VV0_VALRES < 0
	M->VV0_VALRES := 0
Endif
aTabFai := FS_CondPgFI(M->VV0_VALRES+M->VV0_VALFIN)
If Len(aTabFai) > 0
	FS_AtuDADFI()
Endif

M->VV0_VALTRO := 0
//if (lTroco := (M->VV0_TOTENT+M->VV0_VALFIN) > VV0->VV0_VALTOT)
lTroco := M->VV0_TOTENT > VV0->VV0_VALTOT
if lTroco
	// M->VV0_VALTRO := M->VV0_TOTENT + M->VV0_VALFIN - M->VV0_VALTOT
//	M->VV0_VALTRO := M->VV0_TOTENT - M->VV0_VALTOT
   M->VV0_VALTRO := M->VV0_TOTENT - VV0->VV0_VALTOT
   oGetMGet2:Refresh()
Endif

oGetMGet6:Refresh()
oGetMGet6:oBox:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MARKIT011    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Marca/Desmarca o Kit para compor no valor do veiculo       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MARKIT011(lMarca)

Local cont

default lMarca := .t.

if lMarca
	If aKits[oLboxAce:nAt,1] == .f.
		aKits[oLboxAce:nAt,1] := .t.
	Else
		aKits[oLboxAce:nAt,1] := .f.
	Endif
Endif

oLboxKit:SetArray(aKits)
oLboxKit:bLine := { || { if(aKits[oLboxKit:nAt,01] == .f.,oNo,oTik),;
aKits[oLboxKit:nAt,02],;
FG_AlinVlrs(Transform(aKits[oLboxKit:nAt,03],"9,999,999.99")),;
iif(aKits[oLboxKit:nAt,06] == .f.,oNada,oGratis) }}
oLboxKit:Refresh()

nKits := 0
For cont := 1 to Len(aKits)
	if aKits[cont,1] .and. !aKits[cont,6]
		nKits := nKits + aKits[cont,3]
	Endif
Next

nValor := 0
//if Empty(M->VV0_VALFIN)
//	For cont :=1 to Len(aIteParc)
//	   if aIteParc[cont,2] > 0
//	      nValor += aIteParc[cont,2]
//	   Endif
//	Next
//Endif

if VV0->(FieldPos("VV0_IMPOST")) <> 0
	nImpost := M->VV0_IMPOST
Endif

M->VV0_ACESSO := nKits+nAcessor+nAceTer
//M->VV0_VALTOT := (M->VV0_VALMOV + M->VV0_ACESSO) - M->VV0_VALDES
//M->VV0_VALRES := (M->VV0_VALTOT - nImpost) - M->VV0_TOTENT - M->VV0_VALFIN - nValor
M->VV0_VALRES := (M->VV0_VALTOT - nImpost) - M->VV0_TOTENT - M->VV0_VALFIN
if M->VV0_VALRES < 0
	M->VV0_VALRES := 0
Endif
aTabFai := FS_CondPgFI(M->VV0_VALRES+M->VV0_VALFIN)
If Len(aTabFai) > 0
	FS_AtuDADFI()
Endif

M->VV0_VALTRO := 0
//if (lTroco := (M->VV0_TOTENT+M->VV0_VALFIN) > VV0->VV0_VALTOT)
lTroco := ( M->VV0_TOTENT+M->VV0_VALFIN > VV0->VV0_VALTOT )
if lTroco
	M->VV0_VALTRO := M->VV0_TOTENT + M->VV0_VALFIN - M->VV0_VALTOT
	   oGetMGet2:Refresh()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MARCOR011    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Seleciona a cor do veiculo                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MARCOR011(nOpcao)

Local cMar := VV1->VV1_CODMAR
Local cMod := VV1->VV1_MODVEI

if !lSelect // M->VV0_SIMULA == "1"
	cMar := cCodMar
	cMod := cModVei
Endif

dbSelectArea("VVC")
dbSetOrder(2)

if nOpcao == 1
	if dbSeek(xFilial("VVC")+cMar+cCor)
		M->VV0_VALCOR := nValCor
		M->VV0_CORVEI := VVC->VVC_CORVEI
		M->VV0_DESCOR := VVC->VVC_DESCRI
		M->VV0_VALTOT := (M->VV0_VALMOV + M->VV0_ACESSO + M->VV0_VALCOR) - M->VV0_VALDES + Round(nAcresFin,2)
	Else
		M->VV0_VALCOR := 0
		M->VV0_CORVEI := ""
		M->VV0_DESCOR := ""
		M->VV0_VALTOT := (M->VV0_VALMOV + M->VV0_ACESSO + M->VV0_VALCOR) - M->VV0_VALDES + Round(nAcresFin,2)
	Endif
Else
	if dbSeek(xFilial("VVC")+cMar+cCor)
		M->VV0_VALCOR := nValCor
		M->VV0_CORVEI := VVC->VVC_CORVEI
		M->VV0_DESCOR := VVC->VVC_DESCRI
		M->VV0_VALTOT := (M->VV0_VALMOV + M->VV0_ACESSO + M->VV0_VALCOR) - M->VV0_VALDES + Round(nAcresFin,2)
	Else
		M->VV0_VALCOR := 0
		M->VV0_CORVEI := ""
		M->VV0_DESCOR := ""
		M->VV0_VALTOT := (M->VV0_VALMOV + M->VV0_ACESSO + M->VV0_VALCOR) - M->VV0_VALDES + Round(nAcresFin,2)
	Endif
Endif

/*
oLboxCorM:SetArray(aCorM)
oLboxCorM:bLine := { || { if(aCorM[oLboxCorM:nAt,01] == .f.,oNo,oTik),;
aCorM[oLboxCorM:nAt,02],;
FG_AlinVlrs(Transform(aCorM[oLboxCorM:nAt,03],"9,999.99")),} }
oLboxCorM:Refresh()

oLboxCorP:SetArray(aCorP)
oLboxCorP:bLine := { || { if(aCorP[oLboxCorP:nAt,01] == .f.,oNo,oTik),;
aCorP[oLboxCorP:nAt,02],;
FG_AlinVlrs(Transform(aCorP[oLboxCorP:nAt,03],"9,999.99")),} }
oLboxCorP:Refresh()
*/

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_COR011    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa no browse do atendimento e retorna com o filtro   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_COR011(nPosBrw)

Local oCor

if aStruVV1[nPosBrw,2] == "T"
	oCor := oLaranja
Endif
if aStruVV1[nPosBrw,2] == "R"
	oCor := oVermelho
Endif
if aStruVV1[nPosBrw,2] == "C"
	oCor := oAzul
Endif
if aStruVV1[nPosBrw,2] == "B"
	oCor := oAmarelo
Endif

Return( oCor )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CALCACE      ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula o valor dos acessorios e dos agregados             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CALACE011()

Local cont

nAcessor := 0
For cont := 1 to Len(aAcessor)
	if aAcessor[cont,1] .and. !aAcessor[cont,5]
		nAcessor := nAcessor + aAcessor[cont,3]
	Endif
Next

aCols[n,FG_POSVAR("VV6_VALEQP","aHeader")] := M->VV6_VALEQP
nAceTer := 0
For cont := 1 to Len(aCols)
	if !aCols[cont,Len(aCols[cont])]
		nAceTer += aCols[cont,FG_POSVAR("VV6_VALEQP","aHeader")]
	Endif
Next

nValor := 0
//if Empty(M->VV0_VALFIN)
//	For cont :=1 to Len(aIteParc)
//	   if aIteParc[cont,2] > 0
//	      nValor += aIteParc[cont,2]
//	   Endif
//	Next
//Endif

if VV0->(FieldPos("VV0_IMPOST")) <> 0
	nImpost := M->VV0_IMPOST
Endif

M->VV0_ACESSO := nAcessor+nKits+nAceTer
M->VV0_VALTOT := (M->VV0_VALMOV + M->VV0_ACESSO + M->VV0_AGREGA) - M->VV0_VALDES + Round(nAcresFin,2)
//M->VV0_VALRES := (M->VV0_VALTOT - nImpost) - M->VV0_TOTENT - M->VV0_VALFIN - nValor
//M->VV0_VALRES := (M->VV0_VALTOT - nImpost) - M->VV0_TOTENT
M->VV0_VALRES := (M->VV0_VALTOT) - M->VV0_TOTENT - M->VV0_VALFIN
if M->VV0_VALRES < 0
	M->VV0_VALRES := 0
Endif
aTabFai := FS_CondPgFI(M->VV0_VALRES+M->VV0_VALFIN)
If Len(aTabFai) > 0
	FS_AtuDADFI()
Endif

M->VV0_VALTRO := 0
//if (lTroco := (M->VV0_TOTENT+M->VV0_VALFIN) > VV0->VV0_VALTOT)
lTroco := ( M->VV0_TOTENT+M->VV0_VALFIN > VV0->VV0_VALTOT )
if lTroco
	M->VV0_VALTRO := M->VV0_TOTENT + M->VV0_VALFIN - M->VV0_VALTOT
//			   M->VV0_VALTRO := M->VV0_TOTENT - VV0->VV0_VALTOT
   oGetMGet2:Refresh()
Endif

oGetMGet5:Refresh()
oGetMGet5:oBox:Refresh()

oGetMGet6:Refresh()
oGetMGet6:oBox:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CALAGR011    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula o valor dos acessorios e dos agregados             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CALAGR011()

Local cont

aCols[n,FG_POSVAR("VAT_VALNEG","aHeader")] := M->VAT_VALNEG

nAgreg := 0
For cont := 1 to Len(aCols)
	if !aCols[cont,len(aCols[cont])]
		nAgreg += aCols[cont,FG_POSVAR("VAT_VALNEG","aHeader")]
	Endif
Next

nValor := 0
//if Empty(M->VV0_VALFIN)
//	For cont :=1 to Len(aIteParc)
//	   if aIteParc[cont,2] > 0
//	      nValor += aIteParc[cont,2]
//	   Endif
//	Next
//Endif

if VV0->(FieldPos("VV0_IMPOST")) <> 0
	nImpost := M->VV0_IMPOST
Endif

M->VV0_AGREGA := nAgreg
M->VV0_VALTOT := (M->VV0_VALMOV + M->VV0_ACESSO + M->VV0_AGREGA) - M->VV0_VALDES + Round(nAcresFin,2)
//M->VV0_VALRES := (M->VV0_VALTOT - nImpost) - M->VV0_TOTENT - M->VV0_VALFIN - nValor
//M->VV0_VALRES := (M->VV0_VALTOT - nImpost) - M->VV0_TOTENT
M->VV0_VALRES := (M->VV0_VALTOT) - M->VV0_TOTENT - M->VV0_VALFIN
if M->VV0_VALRES < 0
	M->VV0_VALRES := 0
Endif
aTabFai := FS_CondPgFI(M->VV0_VALRES+M->VV0_VALFIN)
If Len(aTabFai) > 0
	FS_AtuDADFI()
Endif

M->VV0_VALTRO := 0
lTroco := ( M->VV0_TOTENT+M->VV0_VALFIN > VV0->VV0_VALTOT )
if lTroco
	M->VV0_VALTRO := M->VV0_TOTENT + M->VV0_VALFIN - M->VV0_VALTOT
   oGetMGet2:Refresh()
Endif

oGetMGet5:Refresh()
oGetMGet5:oBox:Refresh()

oGetMGet6:Refresh()
oGetMGet6:oBox:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PesqV011     ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa no browse do atendimento e retorna com o filtro   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Function PesqV011()

Local nOpca   := 0
Local cNumero := space(30)
Private cChave:= ""
Private nPesq := 1
Private aAte  := {{"","","","",0}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela de pesquisa                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgPesq TITLE OemtoAnsi("Pesquisa Atendimento") FROM  01,05 TO 23,70 OF oMainWnd

nCkPerg1 := 1
@ 001,005 RADIO oRadio1 VAR nPesq 3D SIZE 70,10 PROMPT;
OemToAnsi("Numero"), OemToAnsi("Veiculo");
OF oDlgPesq PIXEL

@ 021,005 SAY "Pesquisa"  SIZE 80,8 OF oDlgPesq PIXEL COLOR CLR_BLUE
@ 030,005 MSGET oNumero VAR cNumero PICTURE "@!" SIZE 110,10 OF oDlgPesq PIXEL

@ 048,005 BUTTON oOk  PROMPT OemToAnsi("Confirma") OF oDlgPesq SIZE 43,11 PIXEL ACTION (PesqQuery(cNumero))
@ 048,048 BUTTON oNo  PROMPT OemToAnsi("Cancela")  OF oDlgPesq SIZE 43,11 PIXEL ACTION (nOpca := 2, oDlgPesq:End())

@ 065,005 LISTBOX oLbAte FIELDS HEADER;
OemToAnsi(STR0246),;//filial
OemToAnsi(STR0247),;//atendimento
OemToAnsi(STR0250),;//cliente
OemToAnsi("Chassi"),;
OemToAnsi("Valor");
COLSIZES 15,30,90,60,40;
SIZE 250,100 OF oDlgPesq PIXEL ON DBLCLICK (nOpca := 1, (cChave := aAte[oLbAte:nAt,01]+aAte[oLbAte:nAt,02]), oDlgPesq:End() )

oLbAte:SetArray(aAte)
oLbAte:bLine := { || { aAte[oLbAte:nAt,01],;
aAte[oLbAte:nAt,02],;
aAte[oLbAte:nAt,03],;
aAte[oLbAte:nAt,04],;
Transform(aAte[oLbAte:nAt,05],"@E 999,999.99") }}

ACTIVATE MSDIALOG oDlgPesq CENTER

if nOpca == 1 .and. !Empty(cChave)
dbSelectArea("VV9")
dbSetOrder(1)
dbSeek(cChave)
ATEND011("VV9",Recno(),4)
Endif

Return
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PesqQuery    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa no browse do atendimento e retorna com o filtro   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PesqQuery(cPesq)

aAte    := {}
cNome   := ""
cAlPesq := "ATDTMP"

cQuery := "SELECT VVA.VVA_FILIAL, VVA.VVA_NUMTRA, VVA.VVA_CHASSI "
if nPesq = 1
	cQuery += "FROM "+RetSqlName("VVA")+" VVA WHERE VVA.VVA_NUMTRA LIKE '%"+alltrim(cPesq)+"' AND VVA.D_E_L_E_T_=' '"
Else
	cQuery += "FROM "+RetSqlName("VVA")+" VVA WHERE VVA.VVA_CHASSI LIKE '%"+alltrim(cPesq)+"' AND VVA.D_E_L_E_T_=' '"
Endif
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlPesq, .F., .T. )
If !( cAlPesq )->( Eof() )
	lRet := .t.
	While !( cAlPesq )->( Eof() )
		cNome := ""
		if VV9->(dbSeek( (cAlPesq )->( VVA_FILIAL ) + ( cAlPesq )->( VVA_NUMTRA ) ))
			cNome := VV9->VV9_NOMVIS
		Endif
		
		VV0->(dbSeek( (cAlPesq )->( VVA_FILIAL ) + ( cAlPesq )->( VVA_NUMTRA ) ))
		
		Aadd(aAte,{ ( cAlPesq )->( VVA_FILIAL ) , ( cAlPesq )->( VVA_NUMTRA ) , ( cNome ) , ( cAlPesq )->( VVA_CHASSI ), VV0->VV0_VALMOV })
		( cAlPesq )->( DbSkip() )
	End
EndIf
( cAlPesq )->( dbCloseArea() )

if Len(aAte) = 0
	aAte  := {{"","","","",0}}
Endif

oLbAte:SetArray(aAte)
oLbAte:bLine := { || { aAte[oLbAte:nAt,01],;
aAte[oLbAte:nAt,02],;
aAte[oLbAte:nAt,03],;
aAte[oLbAte:nAt,04],;
Transform(aAte[oLbAte:nAt,05],"@E 999,999.99") }}

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TIPFAT    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Trata os campos de acordo com o tipo de faturamento        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TIPFAT()

if M->VV0_TIPFAT == "2"
//	M->VV0_SIMULA := "1"
	M->VV0_OPEMOV := "1"
Else
//	M->VV0_SIMULA := "0"
	M->VV0_OPEMOV := "0"
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ACESS011     ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega os acessorios do modelo selecionado                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACESS011()

Local cont
Local lCortesia := .f.
Local lOpcFab   := .f.
Local cMar := VV1->VV1_CODMAR
Local cMod := VV1->VV1_MODVEI
Local nValOpc := 0

If !lSelect // M->VV0_SIMULA == "1"
	cMar := cCodMar
	cMod := cModVei
Endif

aAcessor := {}
dbSelectArea("VV6")
dbSetOrder(4)
dbSelectArea("VVM")
dbSetOrder(1)

if dbSeek(xFilial("VVM")+alltrim(cMar)+SPACE(TamSx3("VV1_CODMAR")[1]-len(alltrim(cMar)))+cMod)
	while !EOF() .and. xFilial("VVM")+alltrim(cMar)+SPACE(TamSx3("VV1_CODMAR")[1]-len(alltrim(cMar)))+allTrim(cMod) == VVM->VVM_FILIAL+VVM->VVM_CODMAR+Alltrim(VVM->VVM_MODVEI)
		dbSelectArea("VVW")
		dbSetOrder(1)
		if dbSeek(xFilial("VVW")+VVM->VVM_CODMAR+VVM->VVM_CODOPC)
			lFound  := VV6->(dbSeek(xFilial("VV6")+M->VV9_NUMATE+VVM->VVM_CODOPC)) //Acessorios
			lOpcFab := .f.
			nValOpc := iif(VVM->VVM_VALCON > 0,VVM->VVM_VALCON,VVW->VVW_VALOPC)
			if lFound .and. (!VVM->VVM_OPCSER <> "1")
				nAcessor  := nAcessor + iif(VVM->VVM_VALCON > 0,VVM->VVM_VALCON,VVW->VVW_VALOPC)
				lCortesia := (VV6->VV6_GRATIS == "S")
			ElseIf (VVM->VVM_OPCSER <> "1")
				lFound  := .t.
				lOpcFab := .t.
				nValOpc := 0
			Endif
			If !lOpcFab
				If M->VVA_CHAINT == VV1->VV1_CHAINT
					If (Alltrim(VVW->VVW_CODOPC)+"/") $ Alltrim(VV1->VV1_OPCFAB)+"/"
						lOpcFab := .t.
						nValOpc := 0
					EndIf
				EndIf
			EndIf
			aAdd(aAcessor, { lFound .or. lOpcFab,alltrim(VVW->VVW_CODOPC)+" - "+VVW->VVW_DESOPC,nValOpc,VVW->VVW_CODOPC,lCortesia,lOpcFab } )
		Endif
		dbSelectArea("VVM")
		dbSkip()
	EndDo
Endif
	
aKits    := {}
dbSelectArea("VV6")
dbSetOrder(3)
dbSelectArea("VET")
dbSetOrder(1)
if dbSeek(xFilial("VET")+cMar+cMod)
	while !EOF() .and. xFilial("VET")+cMar+cMod == VET->VET_FILIAL+VET->VET_CODMAR+VET->VET_MODVEI
		dbSelectArea("VEH")
		dbSetOrder(1)
		if dbSeek(xFilial("VEH")+VET->VET_GRUKIT+VET->VET_CODKIT+"2")
			lFound := VV6->(dbSeek(xFilial("VV6")+M->VV9_NUMATE+VET->VET_GRUKIT+VET->VET_CODKIT)) //Acessorios
			if lFound
				nKits := nKits + VEH->VEH_VALKIT
				lCortesia := (VV6->VV6_GRATIS == "S")
			Endif
			aAdd(aKits, { lFound,alltrim(VEH->VEH_CODKIT)+" - "+VEH->VEH_DESKIT,VEH->VEH_VALKIT,VET->VET_GRUKIT,VET->VET_CODKIT,lCortesia } )
		Endif
		dbSelectArea("VET")
		dbSkip()
	EndDo
Endif

nAceTer := 0
aColsTC := {}
dbSelectArea("VV6")
dbSetOrder(5)
if dbSeek(xFilial("VV6")+M->VV9_NUMATE)
	while !EOF() .and. VV6->VV6_NUMATE == M->VV9_NUMATE
		if VV6->VV6_TIPREG == "4"
			AADD(aColsTC,Array(nUsadoTC+1))
			For cont := 1 to nUsadoTC
				aColsTC[Len(aColsTC),cont]:=If(aHeaderTC[cont,10] # "V",FieldGet(FieldPos(aHeaderTC[cont,2])),CriaVar(aHeaderTC[cont,2]))
			Next
			aColsTC[Len(aColsTC),nUsadoTC+1]:=.F.
			nAceTer += VV6->VV6_VALEQP
		Endif
		dbSelectArea("VV6")
		dbSkip()
	EndDo
Endif

if Len(aColsTC) = 0
	aColsTC:={Array(nUsadoTC+1)}
	aColsTC[1,nUsadoTC+1]:=.F.
	For cont:=1 to nUsadoTC
		aColsTC[1,cont]:=CriaVar(aHeaderTC[cont,2])
	Next
Endif

if len(aAcessor) == 0
	aAdd(aAcessor, { .f.," ",0,"",.f.,.f. } )
Endif

if Type("oLboxAce") <> "U"
	oLboxAce:SetArray(aAcessor)
	oLboxAce:bLine := { || { if(aAcessor[oLboxAce:nAt,01] == .f.,oNo,iif(aAcessor[oLboxAce:nAt,06],oChecked,oTik)),;
	aAcessor[oLboxAce:nAt,02],;
	FG_AlinVlrs(Transform(aAcessor[oLboxAce:nAt,03],"9,999,999.99")),;
	iif(aAcessor[oLboxAce:nAt,05] == .f.,oNada,oGratis) }}
	oLboxAce:Refresh()
Endif

if len(aKits) == 0
	aAdd(aKits, { .f.," ",0,"","",.f. } )
Endif

if Type("oLboxKit") <> "U"
	oLboxKit:SetArray(aKits)
	oLboxKit:bLine := { || { if(aKits[oLboxKit:nAt,01] == .f.,oNo,oTik),;
	aKits[oLboxKit:nAt,02],;
	FG_AlinVlrs(Transform(aKits[oLboxKit:nAt,03],"9,999,999.99")),;
	iif(aKits[oLboxKit:nAt,06] == .f.,oNada,oGratis) }}
	oLboxKit:Refresh()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AGREG011     ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega os acessorios do modelo selecionado                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AGREG011()

Local cont

M->VV0_AGREGA := 0

aColsAG := {}
dbSelectArea("VAT")
dbSetOrder(1)
if dbSeek(xFilial("VAT")+M->VV9_NUMATE)
	while !EOF() .and. VAT->VAT_NUMATE == M->VV9_NUMATE
		if !Empty(VAT->VAT_CODNEG)
			AADD(aColsAG,Array(nUsadoAG+1))
			For cont := 1 to nUsadoAG
				aColsAG[Len(aColsAG),cont]:=If(aHeaderAG[cont,10] # "V",FieldGet(FieldPos(aHeaderAG[cont,2])),CriaVar(aHeaderAG[cont,2]))
			Next
			aColsAG[Len(aColsAG),nUsadoAG+1]:=.F.
			M->VV0_AGREGA += VAT->VAT_VALNEG
		Endif
		dbSelectArea("VAT")
		dbSkip()
	EndDo
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CORES011     ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega as cores do modelo selecionado                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CORES011()

Local cMar := VV1->VV1_CODMAR
Local cMod := VV1->VV1_MODVEI
Local cSeg := VV1->VV1_SEGMOD
Local _cQuery := ""
Local _cAlVVP := "SQLVVP"
Local nVlr1   := 0
Local nVlr2   := 0
if !lSelect // M->VV0_SIMULA == "1"
	cMar := cCodMar
	cMod := cModVei
	cSeg := ""
Endif
aCorM := {}
aCorP := {}
dbSelectArea("VVC")
dbSetOrder(1)
if dbSeek(xFilial("VVC")+cMar)
	_cQuery := "SELECT VVP.VVP_DATPRC , VVP.VVP_VACRMT , VVP.VVP_VACRPR FROM "+RetSqlName("VVP")+" VVP WHERE VVP.VVP_FILIAL='"+xFilial("VVP")+"' AND VVP.VVP_CODMAR='"+cMar+"' AND VVP.VVP_MODVEI='"+cMod+"'"+IIf(!Empty(cSeg)," AND VVP.VVP_SEGMOD='"+cSeg+"' "," ")+"AND VVP.D_E_L_E_T_=' ' ORDER BY VVP.VVP_DATPRC"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVP , .F., .T. )
	While !( _cAlVVP )->( Eof() )
		If	( _cAlVVP )->( VVP_DATPRC ) <= dtos(dDataBase)
			nVlr1 := ( _cAlVVP )->( VVP_VACRMT )
			nVlr2 := ( _cAlVVP )->( VVP_VACRPR )
		Else
			Exit
		EndIf
		( _cAlVVP )->( DbSkip() )
	EndDo
	( _cAlVVP )->( dbCloseArea() )
	dbSelectArea("VVC")
	while !EOF() .and. xFilial("VVC")+cMar == VVC->VVC_FILIAL+VVC->VVC_CODMAR
		nValCor := nVlr1
		if VVC->VVC_TIPCOR == "1"
			aAdd(aCorM,{.f.,VVC->VVC_DESCRI,nVlr1})
		Endif
		if VVC->VVC_TIPCOR == "2"
			aAdd(aCorP,{.f.,VVC->VVC_DESCRI,nVlr2})
		Endif
		dbSelectArea("VVC")
		dbSkip()
	EndDo
Endif

if len(aCorM) == 0
	aAdd(aCorM, { .f.," ",0 } )
Endif
if len(aCorP) == 0
	aAdd(aCorP, { .f.," ",0 } )
Endif

if Type("oLboxCorM") <> "U"
	oLboxCorM:SetArray(aCorM)
	oLboxCorM:bLine := { || { if(aCorM[oLboxCorM:nAt,01] == .f.,oNo,oTik),;
	aCorM[oLboxCorM:nAt,02],;
	FG_AlinVlrs(Transform(aCorM[oLboxCorM:nAt,03],"9,999.99")),} }
	oLboxCorM:Refresh()
Endif

if Type("oLboxCorP") <> "U"
	oLboxCorP:SetArray(aCorP)
	oLboxCorP:bLine := { || { if(aCorP[oLboxCorP:nAt,01] == .f.,oNo,oTik),;
	aCorP[oLboxCorP:nAt,02],;
	FG_AlinVlrs(Transform(aCorP[oLboxCorP:nAt,03],"9,999.99")),} }
	oLboxCorP:Refresh()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALOR011  ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Administra os campos de valor                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALOR011()

//Local cont
Local nImpost := 0
Local nValFin := 0
Local	aHeaderSlv  := {}
Local	aColsSlv    := {}
If FunName() == "VEIVM011"
	If Type("aHeader") <> "U"
		aHeaderSlv  := aClone(aHeader)
		aColsSlv    := aClone(aCols)
	Endif
Else
	aHeaderIC   := {}
	aColsIC		:= {}
Endif

If !MaFisFound('NF')
	M->VV0_VALTOT := M->VV0_VALMOV + Round(nAcresFin,2)
//	M->VV0_VALTOT := (M->VV0_VALMOV + M->VV0_ACESSO + M->VV0_DESACE + M->VV0_AGREGA + M->VV0_VALCOR)-;
//	M->VVA_BONFAB + M->VVA_RECTEC + M->VVA_DESVEI + M->VVA_VALASS + M->VVA_ASSIMP + M->VVA_DESFIX + M->VVA_DSPFIN //M->VVA_VALREV +
	aHeader  := aClone(aHeaderIC)
	aCols    := aClone(aColsIC)
	FS_ITECAM("L")
	aHeader  := aClone(aHeaderSlv)
	aCols    := aClone(aColsSlv)

//	M->VV0_VALTOT += M->VV0_ACESSO + M->VV0_DESACE// + M->VV0_AGREGA 
Endif

cTemp :=	M->VV0_VALTOT//(M->VV0_VALMOV + M->VV0_ACESSO + M->VV0_DESACE + M->VV0_AGREGA + M->VV0_VALCOR)- M->VVA_BONFAB +;
//M->VVA_RECTEC + M->VVA_DESVEI + M->VVA_VALASS + M->VVA_ASSIMP + M->VVA_DESFIX + M->VVA_DSPFIN //M->VVA_VALREV +

if ReadVar() == "M->VV0_VALMOV"
	M->VV0_VALDES := 0
	M->VV0_PERDES := 0
	lCalcVEI := .t.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rubens - 08/09/2009                           ³
	//³Atualiza a VV0_VALTOT para calculo de impostos³
	//³FNC 18018/2009                                ³
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	IF FunName() $ "VEIVM016,VEIVM017,VEIVM030,VEIVM018"
		M->VV0_VALTOT := M->VV0_VALMOV + Round(nAcresFin,2)
	ENDIF	
Elseif ReadVar() == "M->VV0_PERDES"
	//   M->VV0_VALDES := (iif(M->VV0_VALFIN>0,M->VV0_VALFIN,cTemp) / 100) * M->VV0_PERDES
	M->VV0_VALDES := (cTemp / 100) * M->VV0_PERDES
	lCalcVEI := .t.
Elseif ReadVar() == "M->VV0_VALDES"
	// M->VV0_PERDES := Val(Transform((M->VV0_VALDES / iif(M->VV0_VALFIN>0,M->VV0_VALFIN,cTemp)) * 100,"999.99"))
	M->VV0_PERDES := Val(Transform((M->VV0_VALDES / cTemp) * 100,"999.99"))
	// M->VV0_VALDES := (iif(M->VV0_VALFIN>0,M->VV0_VALFIN,cTemp) / 100) * M->VV0_PERDES
  //	M->VV0_VALDES := (cTemp / 100) * M->VV0_PERDES
	lCalcVEI := .t.
Elseif ReadVar() == "M->VV0_PTXRET"
	// M->VV0_VTXRET := (iif(M->VV0_VALFIN>0,M->VV0_VALFIN,cTemp) / 100) * M->VV0_PTXRET
	M->VV0_VTXRET := (cTemp / 100) * M->VV0_PTXRET
Elseif ReadVar() == "M->VV0_VTXRET"
	// M->VV0_PTXRET := (M->VV0_VTXRET / iif(M->VV0_VALFIN>0,M->VV0_VALFIN,cTemp)) * 100
	M->VV0_PTXRET := (M->VV0_VTXRET / cTemp) * 100
Elseif ReadVar() == "M->VV0_PCUSFN"
	// M->VV0_VCUSFN := (iif(M->VV0_VALFIN>0,M->VV0_VALFIN,cTemp) / 100) * M->VV0_PCUSFN
	M->VV0_VCUSFN := (cTemp / 100) * M->VV0_PCUSFN
Elseif ReadVar() == "M->VV0_VCUSFN"
	// M->VV0_PCUSFN := (M->VV0_VCUSFN / iif(M->VV0_VALFIN>0,M->VV0_VALFIN,cTemp)) * 100
	M->VV0_PCUSFN := (M->VV0_VCUSFN / cTemp) * 100
Elseif ReadVar() == "M->VV0_PCOMFN"
	// M->VV0_VCOMFN := (iif(M->VV0_VALFIN>0,M->VV0_VALFIN,cTemp) / 100) * M->VV0_PCOMFN
	M->VV0_VCOMFN := (cTemp / 100) * M->VV0_PCOMFN
Elseif ReadVar() == "M->VV0_VCOMFN"
	// M->VV0_PCOMFN := (M->VV0_VCOMFN / iif(M->VV0_VALFIN>0,M->VV0_VALFIN,cTemp)) * 100
	M->VV0_PCOMFN := (M->VV0_VCOMFN / cTemp) * 100
Elseif ReadVar() == "M->VV0_FORPAG"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rubens - 08/09/2009                           ³
	//³Atualiza a VV0_VALTOT para calculo de impostos³
	//³FNC 18018/2009                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF FunName() $ "VEIVM016,VEIVM017,VEIVM030,VEIVM018"
		M->VV0_VALTOT := M->VV0_VALMOV + Round(nAcresFin,2)
	ENDIF	
Endif

If !MaFisFound('NF')
	M->VV0_VALTOT := M->VV0_VALTOT - M->VV0_VALDES + Round(nAcresFin,2)
Else
	FISCAL011()
Endif

If FunName() == "VEIVM011"
	nTotalEnt := ATUENT011()
	M->VV0_TOTENT := nTotalEnt
Else
	nTotalEnt := 0
	M->VV0_TOTENT := nTotalEnt
Endif
nValfin := M->VV0_VALFIN
//if Empty(M->VV0_VALFIN)
//	For cont :=1 to Len(aIteParc)
//	   if aIteParc[cont,2] > 0
//	      nValfin += aIteParc[cont,2]
//	   Endif
//	Next
//Endif

//if Empty(M->VV0_VALFIN)
//   nValFin := M->VV0_VALTOT - M->VV0_TOTENT
//Endif

if VV0->(FieldPos("VV0_IMPOST")) <> 0
	nImpost := M->VV0_IMPOST
Endif

//M->VV0_VALRES := (M->VV0_VALTOT - nImpost) - M->VV0_TOTENT - nValfin - nImpost  

if Empty(M->VV0_OPEMOV)
	M->VV0_OPEMOV := "0"
Endif	
//M->VV0_VALRES := (M->VV0_VALTOT - nImpost) - M->VV0_TOTENT
nValOrig      := M->VV0_VALRES
nValMerc      := FS_ATVMERC()
M->VV0_VALRES := (nValMerc-M->VV0_VALDES) - M->VV0_TOTENT - M->VV0_VALFIN
If nValOrig != M->VV0_VALRES
//	aTabFai := FS_CondPgFI(M->VV0_VALRES+M->VV0_VALFIN)
	aTabFai := FS_CondPgFI(M->VV0_VALRES)
	If Len(aTabFai) > 0
		FS_AtuDADFI()
	Endif
Endif
if M->VV0_VALRES < 0
	M->VV0_VALRES := 0
Endif

M->VV0_VALTRO := 0
lTroco := (M->VV0_TOTENT+M->VV0_VALFIN) > M->VV0_VALTOT
if lTroco
	M->VV0_VALTRO := M->VV0_TOTENT + M->VV0_VALFIN - M->VV0_VALTOT
	   oGetMGet2:Refresh()
Endif
	
if Type("oGetMGet5") <> "U"
	oGetMGet5:Refresh()
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALTES011 ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o TES digitado e atualiza os campos fiscais         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALTES011()
Local lRet := .t.
Local cSaveArea := GetArea()
if val(M->VV0_CODTES) < 500
	lRet := .f.
Endif
If VV1->VV1_SITVEI==" " .and. !VV1->VV1_RESERV $ "1/3" .and. VV1->VV1_CODORI<>"3" // Ativo Imobilizado
	If VAI->(FieldPos("VAI_ESTNEG")) <> 0
	   If VAI->VAI_ESTNEG != "1" // nao Permite Faturar sem Estoque
			lFatura := .f.
	   Endif
	Else
		lFatura := .f.
   Endif
	If SF4->F4_ESTOQUE == "N" // TES NAO Movimenta Estoque
		lFatura := .t.
	Else
		If SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+VV1->VV1_LOCPAD)) .and. SB2->B2_QATU > 0
			lFatura := .t.
		EndIf	
	EndIf
EndIf
INIFIS011()
FISCAL011()
FS_CALC011()
If FunName() == "VEIVM016" .and. lRet
	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xFilial("SF4")+M->VV0_CODTES)
	If SF4->F4_OPEMOV <> "03"
		MsgStop(STR0277,STR0012) // "Selecione um TES que possua a operacao do movimento do tipo transferencia!" / Atencao
		lRet := .f.
	EndIf 	
	RestArea(cSaveArea)
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AL_AR011     ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o nome do banco Alienado / Arrendado               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AL_AR011(lWhen)

Default lWhen := .f.

VV3->(dbSetOrder(1))
VV3->(dbSeek(xFilial("VV3")+M->VV0_TIPVEN))
If VV3->VV3_ALIARR == "1"
	if Empty(M->VV0_CBCOAA)
		Return (iif(lWhen,.t.,.f.))
	Else
		if !FG_SEEK("SA6","M->VV0_CBCOAA",1,.f.,"VV0_NBCOAA","A6_NOME")
			Return .f.
		Else
			if !Empty(M->VV0_ABCOAA)
				if !FG_SEEK("SA6","M->VV0_CBCOAA+M->VV0_ABCOAA",1,.f.,"VV0_NBCOAA","A6_NOME")
					Return .f.
				Endif
			Else
				M->VV0_ABCOAA := SA6->A6_AGENCIA
			Endif
		Endif
	Endif
Else
	if lWhen
		Return .f.
	Endif
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ INIFIS011    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa as variaveis fiscais                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function INIFIS011()

if !Empty(M->VV9_CODCLI) .and. !Empty(M->VV9_LOJA)
	If !MaFisFound('NF')
		MaFisIni(M->VV9_CODCLI,M->VV9_LOJA,'C','N',SA1->A1_TIPO,MaFisRelImp("VEIVM011",{"VV0","VVA"}))
	EndIf
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FISCAL011    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envia todos os campos necessario para as funcoes fiscais   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISCAL011()
If Type("aHeader") <> "U"
	aHeaderSlv  := aClone(aHeader)
	aColsSlv    := aClone(aCols)
Else
	aHeaderSlv  := {}
	aColsSlv    := {}
Endif

if type("n") == "U"
	n := 1
Endif

if M->VV0_VALMOV > 0 .and. MaFisFound('NF')
	SB1->(dbSetOrder(7))
	SB1->(dbSeek(xFilial("SB1")+cGruVei+M->VV0_CHAINT))
	FISREF011("NF_NATUREZA" ,iif(Empty(M->VV0_NATFIN),SA1->A1_NATUREZ,M->VV0_NATFIN))
	if Type("aHeaderIC")== "A"
		aHeader  := aClone(aHeaderIC)
		aCols    := aClone(aColsIC)
		FS_ITECAM("L")
   		aHeader  := aClone(aHeaderSlv)
   		aCols    := aClone(aColsSlv)
  	endif
//	FISREF011("IT_VALMERC" ,M->VV0_VALTOT+(MaFisRet(1,"IT_DESCONTO")))
	FISREF011("IT_VALMERC" ,M->VV0_VALTOT)
//	FISREF011("IT_VALMERC" ,(M->VV0_VALMOV + M->VV0_ACESSO + M->VV0_DESACE + M->VV0_AGREGA + M->VV0_VALCOR)-;
//	(M->VVA_BONFAB + M->VVA_RECTEC + M->VVA_DESVEI + M->VVA_VALASS + M->VVA_ASSIMP + M->VVA_DESFIX + M->VVA_DSPFIN)) //M->VVA_VALREV +
	
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+M->VV0_CODTES))
	
	// Estrutura do Array aExcecao
	// [01] - Aliq. de ICMS Interna
	// [02] - Aliq. de ICMS Externa
	// [03] - Margem de Lucro Presumida
	// [04] - Grupo de Tributacao
	// [05] - "S"
	// [06] - Aliq. de ICMS Destino
	// [07] - Refere-se ao ISS "S/N"
	// [08] - Valor do Solidario de Pauta
	// [09] - Valor do IPI de Pauta
	// [10] - Valor do PIS
	// [11] - Valor Cofins
	// [12] - Aliquota do PIS
	// [13] - Aliquota do Cofins
	// [14] - Reducao da base de calculo do ICMS
	// [15] - Reducao da base de calculo do IPI
	// [16] - Icms Pauta
	// [17] - Aliquota de IPI
	// [18] - Reducao da base de calculo do PIS
	// [19] - Reducao da base de calculo da COFINS
	// [20] - Pauta Produto "S/N"
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	if FunName() == "VEIVM011"
		dbSeek(xFilial("SA1")+M->VV9_CODCLI+M->VV9_LOJA)
	Else
		dbSeek(xFilial("SA1")+M->VV0_CODCLI+M->VV0_LOJA)
	Endif
	
	If SA1->A1_TIPO == "S" // Cliente Tipo S - Solidario
		dbSelectArea("SF7")
		dbSetOrder(1)
		If dbSeek(xFilial("SF7")+SB1->B1_GRTRIB+SA1->A1_GRPTRIB) .and. Len(MaFisRet(1,"IT_EXCECAO")) = 0 .and. SF4->F4_INCSOL <> "N" .and. SF4->F4_MKPSOL <> "1" .and. SF4->F4_MKPCMP <> "1"
			While !EOF() .and. SF7->F7_GRTRIB == SB1->B1_GRTRIB
//				If F7_EST == "**" .or. F7_EST == SA2->A2_EST
				If SF7->F7_EST == "**" .or. SF7->F7_EST == SA1->A1_EST
					FISREF011("IT_EXCECAO",{SF7->F7_ALIQINT,SF7->F7_ALIQEXT,SF7->F7_MARGEM,SB1->B1_GRTRIB,"N",SF7->F7_ALIQDST,0,0,0,SF7->F7_VLR_PIS,SF7->F7_VLR_COF,SF7->F7_ALIQPIS,SF7->F7_ALIQCOF,0,0,0,0,0,0,"N"})
					nAliSol := SF7->F7_MARGEM
					FISREF011("IT_ALIQICM",SF7->F7_ALIQEXT)
					Exit
				EndIf
				dbSelectArea("SF7")
				dbSkip()
			EndDo
		EndIf
	EndIf
	
	M->VV0_ALIICM := MaFisRet(1,"IT_ALIQICM")
	
	/*
	if !(M->VVG_PISENT+M->VVG_COFENT > 0) .and. M->VVG_PICOSB == "1"
	aPisCof := CalcPisCofEnt(nBasePC)
	//M->VVG_PISENT := aPisCof[1,1] //nBasePC * nAliPis
	//M->VVG_COFENT := aPisCof[1,2] //nBasePC * nAliCof
	//aCols[n,FG_POSVAR("VVG_PISENT")] := M->VVG_PISENT
	//aCols[n,FG_POSVAR("VVG_COFENT")] := M->VVG_COFENT
	
	FISREF011("IT_BASEPS2",nBasePC)
	FISREF011("IT_ALIQPS2",nAliPis)
	
	FISREF011("IT_BASECF2",nBasePC)
	FISREF011("IT_ALIQCF2",nAliCof)
	
	FISREF011("IT_VALPS2",M->VVG_PISENT)
	FISREF011("IT_VALCF2",M->VVG_COFENT)
	
	Else
	MaFisAlt("IT_VALPS2",M->VVG_PISENT,n)
	MaFisAlt("IT_VALCF2",M->VVG_COFENT,n)
	Endif
	*/
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Rubens - 31/07/2009                                              ³
	//³Inserindo informacoes de Transportadora, Vl Frete e Tipo do Frete³
	//³FNC 18018/2009                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	IF FunName() $ "VEIVM018"
		FISREF011("IT_FRETE",M->VVA_VALFRE)
//	ENDIF
	
	FISREF011("IT_GRPTRIB" ,SB1->B1_GRTRIB)
	FISREF011("IT_DESPESA" ,M->VV0_DESACE)
	FISREF011("IT_DESCONTO",M->VV0_VALDES)
	if !Empty(M->VV0_CODTES)
		FISREF011("IT_TES",M->VV0_CODTES)
		if M->VV0_ALIICM > 0
			FISREF011("IT_ALIQICM",M->VV0_ALIICM)
		Endif
		if SB1->B1_IPI > 0
			FISREF011("IT_ALIQIPI",SB1->B1_IPI)
		Endif
		M->VV0_VBAICM := MaFisRet(,"NF_BASEICM")
		M->VV0_TOTICM := MaFisRet(,"NF_VALICM")
		
		//Valor Solidario
		If SA1->A1_TIPO == "S" // Cliente Tipo S - Solidario
			M->VV0_BASSOL := MaFisRet(1,"NF_BASESOL")
			M->VV0_VALSOL := MaFisRet(1,"NF_VALSOL")
		Endif
	Endif
	
	if VV0->(FieldPos("VV0_IMPOST")) <> 0 .and. !Empty(M->VV0_CODTES)
		If SA1->A1_TIPO == "S" .or. SA1->A1_TIPO $ GetMv("MV_TPSOLCF") // Cliente Tipo S - Solidario
			M->VV0_IMPOST := MaFisRet(,"NF_VALIPI")+MaFisRet(,"NF_VALSOL")
		Else
			M->VV0_IMPOST := MaFisRet(,"NF_VALIPI")
		Endif
	Endif
	
	M->VV0_VALTOT := MaFisRet(,"NF_TOTAL")-MAFISRET(,"NF_DESCZF")
	 
Endif

//FS_CALC011()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FISREF011    ³ Autor ³ ANDRE             ³ Data ³ 23/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza os campos fiscais de acordo com o tes digitado    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISREF011(cReferencia,xValor)

Local aArea	:= GetArea()

if M->VV0_TIPFAT $ "013"
	If !MaFisFound("IT",1)
		MaFisAdd(SB1->B1_COD,M->VV0_CODTES,0,0,0,CriaVar("D2_NFORI"),CriaVar("D2_SERIORI"),,0,0,0,0,0)
		MaFisAlt(cReferencia,xValor,1)
	Endif
	If MaFisFound("NF")
		MaFisAlt(cReferencia,xValor,1)
	EndIf
Endif

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GRVATE1   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava o processo de atendimento                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRVATE1(nOpcao)
Local cGCPVCEV := ""
Local cVar
Local cont, cont1
Local cMVCrmVei := GetMv("MV_CRMVEI",,"NNNN")
Local aMemos    := {{"VV9_OBSMEM","VV9_OBSERV"}}
Local bCampo    := { |nCPO| Field(nCPO) }
Local lFazReserv := .f.
Local lDesReserv := .f.
Local aVetTra    := {}
Local cAuxObs,cObsAlteracao
Default nOpcao  := 3 // Inclusao
Inclui := !lJaGravou

//Registro do atendimento
dbSelectarea("VV9")
dbSetOrder(1)
RecLock("VV9",!lJaGravou)
FG_GRAVAR("VV9")
VV9->VV9_FILIAL := xFilial("VV9")
//VV9->VV9_NUMATE := if(Inclui,GetSXENum("VV9","VV9_NUMATE"),VV9->VV9_NUMATE)
VV9->VV9_NUMATE := M->VV9_NUMATE
VV9->VV9_TELVIS := M->VV9_TELVIS
VV9->VV9_CODMAR := M->VV0_CODMAR
VV9->VV9_MODVEI := M->VV0_MODVEI
//if Inclui
//	ConfirmSx8()
//Endif
if Empty(VV9->VV9_STATUS)
	VV9->VV9_STATUS := "A"
Endif
dbSelectarea("SA1")
dbSetOrder(2)
if dbSeek(xFilial("SA1")+M->VV9_NOMVIS) .and. !ReadVar() $ "M->VV9_CODCLI/M->VV9_LOJA"
	if Empty(SA1->A1_TEL)
		RecLock("SA1",.f.)
		SA1->A1_TEL := M->VV9_TELVIS
		MsUnlock()
	Endif
Endif
cVar := aMemos[1][2]
MSMM(,TamSx3("VV9_OBSERV")[1],,&cVar,1,,,"VV9","VV9_OBSMEM")
MsUnlock()
//M->VV9_NUMATE := VV9->VV9_NUMATE

//Cabecalho do atendimento
dbSelectarea("VV0")
dbSetOrder(1)
RecLock("VV0",!lJaGravou)
FG_GRAVAR("VV0")
For cont := 1 TO FCount()
	If FieldPos(EVAL(bCampo,cont)) # 0 
		VV0->&(EVAL(bCampo,cont)) := M->&(EVAL(bCampo,cont))
	EndIf
Next
If !lJaGravou
	ConfirmSX8()
Endif
dbSelectarea("VV0")
VV0->VV0_FILIAL := xFilial("VV0")
VV0->VV0_NUMTRA := M->VV0_NUMTRA // VV9->VV9_NUMATE
VV0->VV0_DATMOV := dDataBase
VV0->VV0_OPEMOV := M->VV0_OPEMOV // Iif(M->VV0_SIMULA == "1","1","0")
//VV0->VV0_SEQVIS := Right(VV0->VV0_NUMTRA,6)
VV0->VV0_CORVEI := M->VV0_CORVEI
VV0->VV0_VALNEG := M->VV0_VALMOV
VV0->VV0_DESACE := M->VV0_DESACE
VV0->VV0_VALDES := M->VV0_VALDES
VV0->VV0_NUMLIB := M->VV0_NUMLIB
VV0->VV0_CODCLI := M->VV9_CODCLI
VV0->VV0_LOJA   := M->VV9_LOJA
VV0->VV0_CODAVA := M->VV0_CODAVA
VV0->VV0_LOJAAV := M->VV0_LOJAAV
VV0->VV0_CBCOAA := M->VV0_CBCOAA
VV0->VV0_ABCOAA := M->VV0_ABCOAA
VV0->VV0_AGEFIN := M->VV0_AGEFIN
VV0->VV0_CODBCO := M->VV0_CODBCO
VV0->VV0_CODAGE := M->VV0_CODAGE
VV0->VV0_TIPVEN := M->VV0_TIPVEN
VV0->VV0_CATVEN := M->VV0_CATVEN
VV0->VV0_FORPAG := M->VV0_FORPAG
VV0->VV0_VCARCR := M->VV0_VCARCR
VV0->VV0_EMPCON := M->VV0_EMPCON
VV0->VV0_CODGRU := M->VV0_CODGRU
VV0->VV0_NUMCOT := M->VV0_NUMCOT
VV0->VV0_VALFIN := M->VV0_VALFIN
If VV0->(FieldPos("VV0_DEPTO")) <> 0
	VV0->VV0_DEPTO  := M->VV0_DEPTO
EndIf
If VV0->(FieldPos("VV0_FILCHA")) <> 0
	VV0->VV0_FILCHA := cFilSelVV1
EndIf

VV0->VV0_VBAICM := M->VV0_VBAICM
VV0->VV0_ALIICM := M->VV0_ALIICM
VV0->VV0_TOTICM := M->VV0_TOTICM

VV0->VV0_SITNFI := "1" //Normal
VV0->VV0_DTHEMI := Dtoc(dDataBase) + [/] + Time()

if M->VV0_TIPFAT == "2" //Faturamento Direto
	VV0->VV0_NUMNFI := "FATDIR"
	VV0->VV0_MODVDA := M->VV0_MODVDA
	VV0->VV0_DPGFAB := M->VV0_DPGFAB
	VV0->VV0_PERCOM := M->VV0_PERCOM
	VV0->VV0_COMFTD := M->VV0_COMFTD
	VV0->VV0_PERREP := M->VV0_PERREP
	VV0->VV0_REPFTD := M->VV0_REPFTD
Endif

MsUnlock()

//Arquivo de detalhes do veiculo
dbSelectarea("VVA")
dbSetOrder(1)
RecLock("VVA",!lJaGravou)
For cont := 1 TO FCount()
	if !Empty(M->&(EVAL(bCampo,cont)))
		VVA->&(EVAL(bCampo,cont)) := M->&(EVAL(bCampo,cont))
	Endif
Next
VVA->VVA_FILIAL := xFilial("VVA")
VVA->VVA_NUMTRA := M->VV0_NUMTRA // VV9->VV9_NUMATE
VVA->VVA_CHASSI := M->VV0_CHASSI //iif(M->VV0_TIPFAT <> "2",VV1->VV1_CHASSI,"")
VVA->VVA_CHAINT := M->VV0_CHAINT //iif(M->VV0_TIPFAT <> "2",VV1->VV1_CHAINT,"")
VVA->VVA_VALVDA := M->VV0_VALTOT
VVA->VVA_VALMOV := M->VV0_VALMOV
VVA->VVA_CODTES := M->VV0_CODTES

nValorBase := IMPOSTO011()

aAdd(aVetTra,{VV0->VV0_CODVEN,1})
If ExistBlock("FS_COMVEI")
	ExecBlock("FS_COMVEI",.f.,.f.)
	VVA->VVA_COMVDE := M->VVA_COMVDE
	ExecBlock("FS_COMVEI",.f.,.f.)
	VVA->VVA_COMGER := M->VVA_COMGER
Else
	aValCom := FG_COMISS("V",aVetTra,VV0->VV0_DATMOV,VV0->VV0_TIPFAT,nValorBase,"T")
	VVA->VVA_COMVDE := aValCom[1]
	VVA->VVA_COMGER := aValCom[2]
Endif

MsUnlock()

If lPriGravacao .and. nOpcao <> 5 // 1a. Gravacao // .and. !Empty(Alltrim(VV9->VV9_CODCLI+VV9->VV9_LOJA))
	lPriGravacao := .f.
	// CEV - Agenda Contato quando Grava a 1a.vez o Atendimento - PERSEGUICAO - Andre Luis Almeida - 12/06/2009 //
	cGCPVCEV := Alltrim(GetNewPar("MV_GCPVCEV",""))
	If !Empty( cGCPVCEV )
		FS_AGENDA( left(cGCPVCEV,1) ,;
			( dDataBase+Val(Substr(cGCPVCEV,2,3)) ) ,;
			IIf(!Empty(Substr(cGCPVCEV,5,6)),Substr(cGCPVCEV,5,6),M->VV0_CODVEN) ,;
			VV9->VV9_CODCLI ,;
			VV9->VV9_LOJA ,;
			"" ,;
			VV9->VV9_NUMATE ,;
			"" ,;
			Alltrim(STR0247) +" "+ VV9->VV9_NUMATE +" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5)+"hs "+;
				Alltrim(RetTitle("VV0_CODVEN"))+": "+Alltrim(M->VV0_NOMVEN)+" "+IIf(VV9->(FieldPos("VV9_SENNEG"))<>0,Alltrim(RetTitle("VV9_SENNEG"))+": "+X3CBOXDESC("VV9_SENNEG",VV9->VV9_SENNEG)+" ","")+;
				Alltrim(RetTitle("VV9_TIPMID"))+": "+X3CBOXDESC("VV9_TIPMID",VV9->VV9_TIPMID)+CHR(13)+CHR(10)+ STR0086 +" "+ IIf(lSelect,VV1->VV1_CHASSI+" - "+VV1->VV1_CODMAR+" "+VV2->VV2_DESMOD,cCodMar+" "+cGruMod+" "+cModVei) ,;
			"" ,;
			"" ) //Atendimento - Veiculo:
	EndIf
EndIf

//If ExistBlock("VM011GVA")
//   ExecBlock("VM011GVA",.f.,.f.)
//EndIf
//Arquivo de veiculos
if M->VV0_TIPFAT <> "2"

	if M->VV0_TIPFAT == "3" .and. VV2->(FieldPos("VV2_QTDATU")) <> 0 // Venda Futura
		If VV0->(FieldPos("VV0_BXAFUT")) <= 0 .or. VV0->VV0_BXAFUT <> "1"
			VV2->(dbSetOrder(1))
			If VV2->(dbSeek(xFilial("VV2")+M->VV0_CODMAR+M->VV0_MODVEI))
				RecLock("VV2",.f.)
					VV2->VV2_QTDATU -= 1
				MsUnLock()
			EndIf
			If VV0->(FieldPos("VV0_BXAFUT")) <> 0 // Veiculo Baixado na Venda Futura
				RecLock("VV0",.f.)
					VV0->VV0_BXAFUT := "1" // 1-Sim / 0-Nao
				MsUnlock()
	        EndIf
		EndIf
	EndIf
	
	dbSelectarea("VV1")
	dbSetOrder(2)
	If dbSeek(xFilial("VV1")+M->VV0_CHASSI)
		RecLock("VV1",.f.)
			VV1->VV1_DESLOC := M->VV0_NOMVEN
		MsUnLock()
   EndIf
	
	lRet := .t.
	// Andre e Manoel - 10/08/2010 - Comentamos pois nao entendemos o por que da nao alteracao data e hora de RESERVA no VV1
/*
	if !Empty(VV1->VV1_DTHVAL)
		dDatTmp := dToS(cToD(subs(VV1->VV1_DTHVAL,1,8)))
		dDatRes := Subs(dDatTmp,7,2) + "/" + Subs(dDatTmp,5,2) + "/" + Subs(dDatTmp,1,4)
		cHorTmp := subs(VV1->VV1_DTHVAL,10,2)+":"+subs(VV1->VV1_DTHVAL,12,2)
		if dDataBase < ctod(dDatRes)
			lRet := .f.
		Elseif dDataBase = ctod(dDatRes)
			if LEFT(Time(),5) < cHorTmp
				lRet := .f.
			Endif
		Endif
	Endif
*/
	if lRet
		dbSelectarea("VV1")
		dbSetOrder(2)
		if dbSeek(cFilSelVV1+M->VV0_CHASSI)
			lFazReserv := .f.
			lDesReserv := .f.
			RecLock("VV1",.f.)
				VV1->VV1_DESLOC := M->VV0_NOMVEN
				if M->VV0_RESERV $ "1/3" .and. !Empty(M->VV0_DATVAL)
					VV1->VV1_RESERV := "1" //Reservado
					VV1->VV1_DTHRES := Dtoc(dDataBase) + [/] + Time()
					VV1->VV1_DTHVAL := Dtoc(M->VV0_DATVAL) + [/] + M->VV0_HORVAL
					lFazReserv := .t.
				ElseIf VV1->VV1_RESERV $ "1/3" .OR. M->VV0_RESERV == "0"
					VV1->VV1_RESERV := ""
					VV1->VV1_DTHRES := ""
					VV1->VV1_DTHVAL := ""
					lDesReserv := .t. 
					M->VV0_DATVAL := ctod("")
					M->VV0_HORVAL := "     "
				Endif
			MsUnlock()       
			VV0->(RecLock("VV0",.f.))
				VV0->VV0_RESERV := M->VV0_RESERV
				VV0->VV0_DATVAL := M->VV0_DATVAL
				VV0->VV0_HORVAL := M->VV0_HORVAL
			VV0->(MsUnlock())  
				
			If lFazReserv // Tarefa no momento da Reserva
				If FindFunction("VEIVM130TAR")
					VEIVM130TAR(M->VV0_NUMTRA,"7") // 0-Verifica/Valida / 1-Gravacao / 2-Finalizacao / 3-Pelo Usuario / 4-Pendente Aprovacao / 5-Pre-Aprovado / 6-Aprovado / 7-Reserva / 8-Cancela Reserva / 9-Cancela Atendimento
				EndIf
			EndIf
			If lDesReserv // Tarefa no momento da Desreserva
				If FindFunction("VEIVM130TAR")
					VEIVM130TAR(M->VV0_NUMTRA,"8") // 0-Verifica/Valida / 1-Gravacao / 2-Finalizacao / 3-Pelo Usuario / 4-Pendente Aprovacao / 5-Pre-Aprovado / 6-Aprovado / 7-Reserva / 8-Cancela Reserva / 9-Cancela Atendimento
				EndIf
			EndIf
		Endif
	ELSE
		If !M->VV0_RESERV $ "1/3"
			dbSelectarea("VV1")
			dbSetOrder(2)
			if dbSeek(cFilSelVV1+M->VV0_CHASSI)
				RecLock("VV1",.f.)
					VV1->VV1_RESERV := ""
					VV1->VV1_DTHRES := ""
					VV1->VV1_DTHVAL := ""
				MsUnlock() 
				M->VV0_DATVAL := ctod("")
				M->VV0_HORVAL := "     "				
				VV0->(RecLock("VV0",.f.))
					VV0->VV0_RESERV := M->VV0_RESERV
					VV0->VV0_DATVAL := M->VV0_DATVAL
					VV0->VV0_HORVAL := M->VV0_HORVAL
		   		VV0->(MsUnlock()) 
			EndIf
		Endif	
	Endif
	if !Empty(cChaRes)
		dbSelectarea("VV1")
		dbSetOrder(2)
		if dbSeek(cFilSelVV1+cChaRes)
			RecLock("VV1",.f.)
				VV1->VV1_DESLOC := M->VV0_NOMVEN
				If VV1->VV1_RESERV $ "1/3"
					VV1->VV1_RESERV := ""
					VV1->VV1_DTHRES := ""
					VV1->VV1_DTHVAL := ""
				Endif
			MsUnlock()
		Endif
	Endif
Endif

//Grava as informacoes da negociacao de pagamento
cStaTmp := "F/T/P/L"
if GetNewPar("MV_TITAPR","S") == "S"
	cStaTmp := "F/T/L"
Endif
if !M->VV9_STATUS $ cStaTmp
	GRVNEG011()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rubens - 23/11/2009                                                     ³
//³Verifica se houve alteração e grava na Obs. do Atendimento as Alteracoes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Inclui .and. lLogAlter
	cAuxObs       := ""
	cObsAlteracao := ""

	// Verifica se houve alteração nos campos adicionados na matriz aLogAlter
	For Cont := 1 to Len(aLogAlter)
		// Compara com o valor gravado 
		IF aLogAlter[Cont,2] <> &(aLogAlter[Cont,1])
			aLogAlter[Cont,3] := &(aLogAlter[Cont,1]) // Carrega valor atual (novo) 
			cObsAlteracao += "*** "+ AllTrim(UPPER(RetTitle(Right(aLogAlter[Cont,1],Len(aLogAlter[Cont,1])-5))))+" - "+STR0317+": "
			If ValType(aLogAlter[Cont,2]) == "N"
				cObsAlteracao += Transform(aLogAlter[Cont,2],x3Picture(Right(aLogAlter[Cont,1],Len(aLogAlter[Cont,1])-5)))+" - "+STR0318+": "+Transform(aLogAlter[Cont,3],x3Picture(Right(aLogAlter[Cont,1],Len(aLogAlter[Cont,1])-5)))
			Else
				cObsAlteracao += AllTrim(aLogAlter[Cont,2])+" - "+STR0318+": "+AllTrim(aLogAlter[Cont,3])
			Endif
			
			// Se foi passado uma macro para adicionar alguma informacao a mais no log do registro 
			If ValType(aLogAlter[Cont,4]) <> "U"
				cObsAlteracao += " " + &(aLogAlter[Cont,4])
			EndIf
			
			cObsAlteracao += " ***"+Chr(13)+Chr(10) 
		EndIf
	Next Cont

	// Verifica se houve alteração nos tipos de entrada 
	cAuxObs := ""
	For Cont := 1 to Len(aVS9LogAlter)
	
		// Verifica se o registro foi alterado ou incluido ou excluido 
		IF !aVS9LogAlter[Cont,3] .or. aVS9LogAlter[Cont,4] .or. aVS9LogAlter[Cont,5]
		
			cAuxObs += "***    "+ aVS9LogAlter[Cont,1] + " - " + AllTrim(Posicione("VSA",1,xFilial("VSA")+aVS9LogAlter[Cont,1],"VSA_DESPAG"))
			Do Case
				// Registro com alteracao de valor 
				Case !aVS9LogAlter[Cont,3] .and. !aVS9LogAlter[Cont,4] .and. !aVS9LogAlter[Cont,5]
					cAuxObs += " - "+STR0317+": "+Transform(aVS9LogAlter[Cont,2],"@E 999,999.99")+" - "+STR0318+": "+Transform(aVS9LogAlter[Cont,6],"@E 999,999.99")+" ***"+Chr(13)+Chr(10)
	
				// Registro Novo 
				Case aVS9LogAlter[Cont,4] .and. !aVS9LogAlter[Cont,5]
					cAuxObs += " - "+STR0320+": "+Transform(aVS9LogAlter[Cont,6],"@E 999,999.99")+" ***"+Chr(13)+Chr(10)
				
				// Registro Excluido
				Case aVS9LogAlter[Cont,5]
					cAuxObs += " - "+STR0321+": "+Transform(aVS9LogAlter[Cont,2],"@E 999,999.99")+" ***"+Chr(13)+Chr(10)
				
			EndCase
		EndIf
	Next Cont

	// Se houve alteracao nos tipos de entrada, adiciona na observacao
	if !Empty(cAuxObs)
		cObsAlteracao += "*** " + STR0319 + ":"+CHR(13)+CHR(10) + cAuxObs
	endiF
	
	// Se houve alguma alteração, grava a observacao gerada 
	if !Empty(cObsAlteracao)
	
		// Remove o Ultimo CHR(13) + CHR(10)
		cObsAlteracao := Left(cObsAlteracao,Len(cObsAlteracao)-2)

		// Carrega Observacao gravada para adicionar o Log de Alteração 
		cAuxObs := MSMM(VV9->VV9_OBSMEM,TamSx3("VV9_OBSERV")[1])
		If !Empty(cAuxObs)
			cAuxObs += Chr(13)+Chr(10)+Repl("_",TamSx3("VV9_OBSERV")[1])+Chr(13)+Chr(10)
		EndIf
		cAuxObs += "*** "+left(Alltrim(UsrRetName(__CUSERID)),15)+" "+Transform(dDataBase,"@D")+"-"+Transform(time(),"@R 99:99")+" ***"+Chr(13)+Chr(10)
	
		// Grava alteracoes na Observacao 
		dbSelectArea("VV9")
		RecLock("VV9",.f.)
			MSMM(,TamSx3("VV9_OBSERV")[1],,cAuxObs+cObsAlteracao,1,,,"VV9","VV9_OBSMEM")
		MsUnLock()
	
	endif

EndIf


///  CRIAR TAREFAS REFERENTE AO ATENDIMENTO DE VEICULOS - Andre Luis Almeida - 21/09/2009 ///
If nOpcao <> 5
	If FindFunction("VEIVM130TAR") .and. M->VV0_OPEMOV != "1"
		VEIVM130TAR(M->VV0_NUMTRA,"1")// 0-Verifica/Valida / 1-Gravacao / 2-Finalizacao / 3-Pelo Usuario / 4-Pendente Aprovacao / 5-Pre-Aprovado / 6-Aprovado / 7-Reserva / 8-Cancela Reserva / 9-Cancela Atendimento
	EndIf
	//valida regra para tarefas - Rafael Goncalves - 28/01/2010
	If FindFunction("VA400REGRA") .and. M->VV0_OPEMOV != "1"  
   		//if M->VV0_RESERV $ "1/3"
			VA400REGRA(M->VV0_NUMTRA,"1")// 1 - Gravacao / 2- Pendente / 3- pre-aprovado / 4 aprovado
		//EndIf
	EndIf
EndIf
/////////////////////////////////////////////////////////////////////////////////////////////

//Grava os acessorios selecionados
GRVACE011()

//Grava os agregados
//GRVAGR011()

//Ponto de entrada
If ExistBlock("GRVATD011")
	ExecBlock("GRVATD011",.f.,.f.)
Endif

If FunName() == "VEIVM011" .and. !lAprovacao
	FS_AtuVZ7("I") // Inclusao ou Alteracao dos Itens de Campanha
Endif

lJaGravou := .t.

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GERANOTA  ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Finaliza o atendimento gerando a nota fiscal               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GERANOTA()

Local x_
Local cClaFis
Local nIteLib := 0
Local aItePv  := {}
Local aPvlNfs := {}
Local cLocVei := VV1->VV1_LOCPAD
Local aHeaderSlv := aClone(aHeader)
Local aColsSlv   := aClone(aCols)
Private aCabPv  := {}
Private aIteTPv := {}

if M->VV0_TIPFAT == "3"
	Return(.t.)
Endif

ProcRegua(8)

IncProc(STR0138) //Gravando atendimento passo 1

if Empty(VV1->VV1_LOCPAD)
	cLocVei := GETMV("MV_LOCVEIN") //Novo
	if VV1->VV1_ESTVEI == '1'
		cLocVei := GETMV("MV_LOCVEIU") //Usado
	Endif
	if VV1->VV1_SITVEI == "4" //Consignado
		cLocVei := GETMV("MV_LOCVEIC")
	Endif
Endif

IncProc(STR0139)   //Pontos de entrada

//Ponto de Entrada - Orcamento
If ExistBlock("INSEREORC")
	ExecBlock("INSEREORC",.f.,.f.)
Endif

//Ponto de Entrada - OS
If ExistBlock("INSEREOSV")
	ExecBlock("INSEREOSV",.f.,.f.)
Endif

if M->VV0_TIPFAT <> "2" //VDI/Frotista
	
	VV2->(dbSetOrder(1))
	VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+M->VV0_MODVEI))
	
	dbSelectarea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
	
	//Verifica se existe saldo para faturar o veiculo
	dbSelectArea("SB2")
	dbSetOrder(1)
	if !dbSeek(xFilial("SB2")+SB1->B1_COD+cLocVei) .or. SB2->B2_QATU <= 0
		SF4->(dbSetOrder(1))
		SF4->(dbSeek(xFilial("SF4")+M->VV0_CODTES))
		If SF4->F4_ESTOQUE == "S" // TES Movimenta Estoque
			If VAI->(FieldPos("VAI_ESTNEG")) <> 0
			   If VAI->VAI_ESTNEG != "1" // nao Permite Faturar sem Estoque
					MsgInfo(STR0140 ,STR0012) //Veiculo nao esta no estoque! - Atencao 
					aStruVV1[oLbox:nAt,01] := .f.
					lMsErroAuto := .t.
					Return(.f.)
			   Endif
			Else
				MsgInfo(STR0140 ,STR0012) //Veiculo nao esta no estoque! - Atencao
				lMsErroAuto := .t.
				Return(.f.)
		   Endif
		EndIf
	EndIf
	
	IncProc(STR0141)  //Pedido de venda
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pedido de venda                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	M->VV0_NUMPED:= CriaVar("C5_NUM")
	//Classificacao fiscal
	cClaFis := FG_CLAFIS(M->VV0_CODTES)
	
	IF M->VV0_CATVEN == "7"
	   If !Empty(M->VV0_CBCOAA)
			DbSelectArea("SA6")
			DBSetOrder(1)
			DBSeek(xFilial("SA6")+M->VV0_CBCOAA+M->VV0_ABCOAA)
			DBSelectArea("SA1")
			DbSetOrder(1)
			DBSeek(xFilial("SA1")+SA6->A6_CODCLI+SA6->A6_LOJCLI)
		Else
			DBSelectArea("SA1")
			DbSetOrder(1)
			DBSeek(xFilial("SA1")+cCliFin7+cLojFin7)
		Endif
	Else
		DBSelectArea("SA1")
		DbSetOrder(1)
		DBSeek(xFilial("SA1")+M->VV9_CODCLI+M->VV9_LOJA)
	endif

	//Cabecalho do pedido
	aAdd(aCabPV,{"C5_NUM"    ,M->VV0_NUMPED ,Nil}) // Numero do pedido
	aAdd(aCabPV,{"C5_TIPO"   ,"N"           ,Nil}) // Tipo de pedido
	aAdd(aCabPV,{"C5_CLIENTE",SA1->A1_COD   ,Nil}) // Codigo do cliente
	aAdd(aCabPV,{"C5_LOJAENT",SA1->A1_LOJA  ,Nil}) // Loja para entrada
	aAdd(aCabPV,{"C5_LOJACLI",SA1->A1_LOJA  ,Nil}) // Loja do cliente
	aAdd(aCabPV,{"C5_CONDPAG",RetCondVei()  ,Nil}) // Codigo da condicao de pagamanto
	aAdd(aCabPV,{"C5_VEND1"  ,M->VV0_CODVEN ,Nil}) // Codigo do vendedor
	aAdd(aCabPV,{"C5_EMISSAO",M->VV0_DATMOV ,Nil}) // Data de emissao
	aAdd(aCabPV,{"C5_TRANSP" ,M->VV0_CODTRA ,Nil}) // Transportadora
	aAdd(aCabPV,{"C5_TIPOCLI",SA1->A1_TIPO  ,Nil}) // Tipo do Cliente
	aAdd(aCabPV,{"C5_DESC1"  ,0             ,Nil}) // Percentual de Desconto
	aAdd(aCabPV,{"C5_BANCO"  ,M->VV0_CODBCO ,Nil}) // Banco
	aAdd(aCabPV,{"C5_INCISS" ,"N"           ,Nil}) // ISS Incluso
	aAdd(aCabPV,{"C5_TIPLIB" ,"2"           ,Nil}) // Tipo do Cliente
	aAdd(aCabPV,{"C5_MOEDA"  ,1             ,Nil}) // Moeda
	aAdd(aCabPV,{"C5_LIBEROK","S"           ,Nil}) // Liberacao Total
	aAdd(aCabPV,{"C5_COMIS1" ,SA3->A3_COMIS ,Nil}) // Percentual de Comissao
	aAdd(aCabPV,{"C5_DESPESA",M->VV0_DESACE ,Nil}) // Despesa Acessorio
	
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SC5")
	While !Eof().and.(x3_arquivo=="SC5")
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
		dbSkip()
	EndDo
	
	For x_:=1 to Len(aCabPV)
		Private &("M->"+aCabPV[x_,1]) := aCabPV[x_,2]
	Next
	
	SF4->(dbSeek(xFilial("SF4")+M->VV0_CODTES))
	cCFiscal := FG_CLAFIS(M->VV0_CODTES)
	
	aAdd(aIteTPv,{"C6_NUM"    ,M->VV0_NUMPED  ,Nil}) // Numero do Pedido
	aAdd(aIteTPv,{"C6_ITEM"   ,"01"           ,Nil}) // Numero do Item no Pedido
	aAdd(aIteTPv,{"C6_PRODUTO",SB1->B1_COD    ,Nil}) // Codigo do Produto
	aAdd(aIteTPv,{"C6_QTDVEN" ,1              ,Nil}) // Quantidade Vendida
//	aAdd(aIteTPv,{"C6_PRUNIT" ,M->VV0_VALTOT+M->VV0_VALDES ,Nil}) // Preco Unitario do Produto

	aAdd(aIteTPv,{"C6_PRCVEN" ,(M->VV0_VALTOT)+iif(MaFisFound('NF'),MAFISRET(,"NF_DESCZF"),0)+M->VV0_VALDES-M->VV0_IMPOST ,Nil}) // Preco Unitario Liquido *
	aAdd(aIteTPv,{"C6_VALOR"  ,(M->VV0_VALTOT)+iif(MaFisFound('NF'),MAFISRET(,"NF_DESCZF"),0)+M->VV0_VALDES-M->VV0_IMPOST ,Nil}) // Valor Total do Item *

	aAdd(aIteTPv,{"C6_ENTREG" ,M->VV0_DATMOV  ,Nil}) // Data da Entrega
	aAdd(aIteTPv,{"C6_UM"     ,"UN"         	 ,Nil}) // Unidade de Medida Primar.
	aAdd(aIteTPv,{"C6_TES"    ,M->VV0_CODTES  ,Nil}) // Tipo de Entrada/Saida do Item
	aAdd(aIteTPv,{"C6_LOCAL"  ,cLocVei        ,Nil}) // Almoxarifado
	aAdd(aIteTPv,{"C6_CF"     ,cCFiscal       ,Nil}) // CFO
	aAdd(aIteTPv,{"C6_CLASFIS",Left(SB1->B1_ORIGEM,1)+SF4->F4_SITTRIB,Nil}) // Situacao Tributaria
	aAdd(aIteTPv,{"C6_VALDESC",M->VV0_VALDES  ,Nil}) // Valor do Desconto
//		aAdd(aIteTPv,{"C6_DESCONT",(M->VV0_VALDES/M->VV0_VALTOT)*100,Nil}) // Percentual de Desconto
	//	aAdd(aIteTPv,{"C6_VALDESC",0              ,Nil}) // Valor do Desconto
	//	aAdd(aIteTPv,{"C6_DESCONT",0              ,Nil}) // Percentual de Desconto
	aAdd(aIteTPv,{"C6_COMIS1" ,SA3->A3_COMIS  ,Nil}) // Comissao Vendedor
	aAdd(aIteTPv,{"C6_DESCRI" ,SB1->B1_DESC   ,Nil}) // Descricao do Produto
	aAdd(aIteTPv,{"C6_CLI"    ,SA1->A1_COD    ,Nil}) // Cliente
	aAdd(aIteTPv,{"C6_LOJA"   ,SA1->A1_LOJA   ,Nil}) // Loja do Cliente
	aAdd(aIteTPv,{"C6_QTDEMP" ,1              ,Nil}) // Quantidade Empenhada
	
	if ExistBlock("PEDVEI011")
		ExecBlock("PEDVEI011",.f.,.f.)
	Endif
	
	aAdd(aItePv,aClone(aIteTPv))
	
	FG_X3ORD("C",,aCabPv)
	FG_X3ORD("I",,aItePv)

	MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItePv,3) //Faz Liberacao do Pedido se LiberOk = "S" e QtdLib = QtdEmp
	if lMsErroauto
		Return(.f.)
	Endif
	
	IncProc(STR0142)  //Liberacao do pedido de venda
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Liberacao do pedido de venda                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lCredito := .t.
	lEstoque := .t.
	lLiber   := .t.
	lTransf  := .f.
	
	dbSelectArea("SC9")
	dbSetOrder(1)
	
	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(xFilial("SC6")+M->VV0_NUMPED+"01")
	While !eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == M->VV0_NUMPED
		dbSelectArea("SC9")
		if !dbSeek(xFilial("SC9")+M->VV0_NUMPED+SC6->C6_ITEM)
			nQtdLib := SC6->C6_QTDVEN
			nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,.F.,lLiber,lTransf)
		Endif
		dbSelectArea("SC6")
		dbSkip()
	Enddo
	
	dbSelectArea("SC9")
	dbSeek(xFilial("SC9")+M->VV0_NUMPED+"01")
	While !Eof() .and. xFilial("SC9")==SC9->C9_FILIAL .and. SC9->C9_PEDIDO == M->VV0_NUMPED
		
		If Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLEST)
			
			FG_Seek("SB1","SC9->C9_PRODUTO",1)
			FG_Seek("SC5","SC9->C9_PEDIDO",1,.F.)
			FG_Seek("SC6","SC9->C9_PEDIDO+SC9->C9_ITEM",1)
			FG_Seek("SB5","SB1->B1_COD")
			FG_Seek("SB2","SB1->B1_COD")
			FG_Seek("SF4","M->VV0_CODTES")
			FG_Seek("SE4","VV0->VV0_FORPAG",1)  //Tem que ser Tipo A para nao criar E1 automatico
			
			aAdd(aPvlNfs,{C9_PEDIDO,;
			C9_ITEM,;
			C9_SEQUEN,;
			C9_QTDLIB,;
			C9_PRCVEN,;
			C9_PRODUTO,;
			SF4->F4_ISS=="S",;
			SC9->(RecNo()),;
			SC5->(RecNo()),;
			SC6->(RecNo()),;
			SE4->(RecNo()),;
			SB1->(RecNo()),;
			SB2->(RecNo()),;
			SF4->(RecNo())})
			nIteLib++
		Else
			MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabPv,aItePv,5)
		EndIf
		dbSelectArea("SC9")
		dbSkip()
	Enddo
	
	If lGeraNF

		IncProc(STR0143)  //Geracao da nota fiscal
         
		FM_LOCVZL(2)
		
		VV0->(dbGoTo(VV0->(Recno())))
		FGX_AMOVVEI(xFilial("VV1"),M->VV0_CHASSI)
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera F2/D2, Atualiza Estoque, Financeiro, Contabilidade             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if nIteLib > 0
			//Funcao que trata aliquota do ICMS para veiculos
			FS_ALIICMS(SB1->B1_COD)
			
			PERGUNTE("MT460A",.f.)
			cNota := MaPvlNfs(aPvlNfs,cSerie, (mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1), .F., 0, 0, .T., .F.)
		Endif

		dbSelectArea("SF2")
		RecLock("SF2",.f.)
		SF2->F2_COND    := M->VV0_FORPAG
//		if VE4->VE4_GTPRFT  == "0" // Gera titulo na Proposta
//			SF2->F2_DUPL := Right(VV0->VV0_NUMTRA,nTamNota)
//		Else
			SF2->F2_DUPL := cNota
//		Endif
		SF2->F2_PREFORI := cPrefixo
		SF2->F2_VALFAT  := M->VV0_VALTOT
		SF2->F2_PREFIXO := &(GetNewPar("MV_1DUPREF","cSerie"))
		MsUnlock()
		
		cPrefNF := SF2->F2_PREFIXO

	Endif
		
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	if SC5->(dbSeek(xFilial("SC5")+M->VV0_NUMPED))
		RecLock("SC5",.f.)
		SC5->C5_CONDPAG := M->VV0_FORPAG
		SC5->C5_TPFRETE := M->VV0_TPFRET
		MsUnlock()
	Endif
	
Endif

If lGeraNF

	IncProc(STR0144) //Gravando titulos no financeiro
	
	aHeaderSlv := aClone(aHeader)
	aColsSlv   := aClone(aCols)
	
	dbSelectArea("SE1")
	dbSetOrder(1)
	if !dbSeek(xFilial("SE1")+SM0->M0_CODFIL+"E"+Right(M->VV9_NUMATE,nTamNota)) .and. !dbSeek(xFilial("SE1")+SM0->M0_CODFIL+"F"+Right(M->VV9_NUMATE,nTamNota))
		FS_GERATIT()
	Else
		while !EOF() .and. dbSeek(xFilial("SE1")+SM0->M0_CODFIL+"E"+Right(M->VV9_NUMATE,nTamNota))
			RecLock("SE1",.f.)
			SE1->E1_NUM     := cNota
			SE1->E1_PREFIXO := cPrefNF
			MsUnlock()
			DbSkip()
		Enddo
		if dbSeek(xFilial("SE1")+SM0->M0_CODFIL+"F"+Right(M->VV9_NUMATE,nTamNota))
			while !EOF() .and. dbSeek(xFilial("SE1")+SM0->M0_CODFIL+"F"+Right(M->VV9_NUMATE,nTamNota))
				RecLock("SE1",.f.)
				SE1->E1_NUM     := cNota
				SE1->E1_PREFIXO := cPrefNF
				MsUnlock()
				DbSkip()
			Enddo
		Endif
		
		dbSelectArea("SE5")
		dbSetOrder(7)
		if dbSeek(xFilial("SE5")+SM0->M0_CODFIL+"E"+Right(M->VV9_NUMATE,nTamNota))
			while !EOF() .and. dbSeek(xFilial("SE5")+SM0->M0_CODFIL+"E"+Right(M->VV9_NUMATE,nTamNota))
				RecLock("SE5",.f.)
				SE5->E5_NUMERO  := cNota
				SE5->E5_PREFIXO := cPrefNF
				MsUnlock()
				DbSkip()
			Enddo
		Endif
		if dbSeek(xFilial("SE5")+SM0->M0_CODFIL+"F"+Right(M->VV9_NUMATE,nTamNota))
			while !EOF() .and. dbSeek(xFilial("SE5")+SM0->M0_CODFIL+"F"+Right(M->VV9_NUMATE,nTamNota))
				RecLock("SE5",.f.)
				SE5->E5_NUMERO  := cNota
				SE5->E5_PREFIXO := cPrefNF
				MsUnlock()
				DbSkip()
			Enddo
		Endif
	Endif
	
	aHeader := aClone(aHeaderSlv)
	aCols   := aClone(aColsSlv)


	if lMsErroauto
		Return(.f.)
	Endif
	
	IncProc(STR0145) //Gravando atendimento passo 2
	
	nRecF2 := SF2->(RecNo())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava 2 fase dos arquivos de Cabecalho e detalhes do atendimento    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FS_GRVATE2()
	
	IncProc(STR0146) //Gravando valores em moeda forte
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava valores de moeda forte nos arquivos do atendimento            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FS_MFORTE("A")
	
	SF2->(DbGoTo(nRecF2))
	
	if lMsErroauto
		Return(.f.)
	Endif

Else

	MsgInfo(OemToAnsi(STR0141)+" nro "+SC5->C5_NUM,STR0012)
	
Endif
/* Andre Almeida e Manoel - 28/10/2009 - retirada daqui e inserida no Final do End Transaction da funcao FINAL011

if lMsErroauto
	Return(.f.)
Else
	if M->VV0_TIPFAT == "2" //Faturamento Direto
		if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) <> "S"
			If ExistBlock("NFSERVIC") // Programa de Nota Fiscal de Diversos
				ExecBlock("NFSERVIC",.f.,.f.,{VV0->VV0_NUMNFI,VV0->VV0_SERNFI,"CFD"})
			Endif
		EndIF
	Elseif !M->VV0_OPEMOV $ "234" // Venda/Remessa/Transferencia/Devolucao
		if Substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) <> "S"
			dbSelectArea("VV0")
			dbSetOrder(1)
			dbSeek(xFilial("VV0")+VV9->VV9_NUMATE)
			If ExistBlock("NFSAIVEI")
				ExecBlock("NFSAIVEI",.f.,.f.,{SF2->F2_DOC,SF2->F2_SERIE})
				
				dbSelectArea("SA6")
				dbSetOrder(1)
				if dbSeek(xFilial("SA6")+VV0->VV0_CODBCO)
					cDesBco := ""
					cObs1   := Substr(SA6->A6_MENSAGE,001,49)
					cObs2   := Substr(SA6->A6_MENSAGE,050,49)
					cObs3   := Substr(SA6->A6_MENSAGE,100,50)
					if ExistBlock("BLQCOB")
						ExecBlock("BLQCOB",.f.,.f.,{SF2->F2_DOC,,,,SF2->F2_PREFIXO,"1",cObs1,cObs2,cObs3,VV0->VV0_CODBCO})
					Endif
				Endif
			Endif
		EndIF
	Endif
Endif
*/

oDlgAtend:End()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CANCPED   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancela a geracao do pedido/nota fiscal                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CANCPED()

lMsErroAuto := .f.

dbSelectArea("SC5")
dbSetOrder(1)
if dbSeek(xFilial("SC5")+VV0->VV0_NUMPED)
	aMata410Cab   := {{"C5_NUM"      , VV0->VV0_NUMPED,Nil}}   //Numero do pedido SC5
	aMata410Itens := {{"C6_NUM"      , VV0->VV0_NUMPED,Nil}}   //Numero do Pedido SC6
	
	//Exclui Pedido
	SC9->(dbSetOrder(1))
	SC9->(dbSeek(xFilial("SC9")+VV0->VV0_NUMPED))
	While !SC9->(Eof()) .And. xFilial('SC9') == SC9->C9_FILIAL .and. VV0->VV0_NUMPED == SC9->C9_PEDIDO
		SC9->(a460Estorna())
		SC9->(dbSkip())
	EndDo
	
	MSExecAuto({|x,y,z|Mata410(x,y,z)},aMata410Cab,{aMata410Itens},5)
Endif

if !lMSErroAuto

	DBSelectArea("VVA")
	DBSetOrder(1)
	DBSeek(xFilial("VVA")+VV0->VV0_NUMTRA)
	//
	FG_Seek("VV1","VVA->VVA_CHASSI",2,.f.)
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
	dbSetOrder(1)
	FM_LOCVZL(1)
endif	
Return(lMsErroAuto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GERATIT   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera os titulos referente a negociacao de pagamento        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GERATIT()

Local ix1, i_
Local aHeaderSlv := {}
Local aColsSlv   := {}
Local	cCodFabF
Local	cLojFabF
Local	cCodFabC
Local cLojFabC
Local cNumTit   := cNota
Local aItens    := {}
Local cTipo     := "DP"
Local cDesTipo  := "DUPLICATA"
//Local cTipCob   := if(!Empty(M->VV0_CODBCO),"1","0")
Local cTipCob   := "0"  //if(!Empty(M->VV0_CODBCO),"1","0")
Local nSeqPro   := 1
Local nPagFab   := 0
Local cNatureza := M->VV0_NATFIN
Local cCliFin   := ""
Local cJojFin   := ""
Local aTitAgreg := {}
Local ni := 0
Local nValParc  := 0
Local aParcelas := {}
Local aFinanc   := {}
Private cCodBco := M->VV0_CODBCO

If Type("aHeader") != "U" .and. Type("aCols")!="U"
	aHeaderSlv := aClone(aHeader)      
	aColsSlv   := aClone(aCols)
Endif

SA1->(dbSetOrder(1))
if Empty(cNatureza)
	SA1->(dbSeek(xFilial("SA1")+M->VV9_CODCLI+M->VV9_LOJA))
	cNatureza := SA1->A1_NATUREZ
Endif

//ponto de entrada que valida a gravacao
if ExistBlock("VM011GV2")
	If !ExecBlock("VM011GV2",.f.,.f.)
		Return .f.
	Endif
Endif

if Empty(cNota)
	cPrefNF := SM0->M0_CODFIL+"E"
	if Empty(M->VV9_NUMATE)
		M->VV9_STATUS := "T"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava 1 fase dos arquivos de Cabecalho e detalhes do atendimento    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FS_GRVATE1()
	Endif
	cNumTit := Right(VV9->VV9_NUMATE,nTamNota)
Endif

if Len(cNumTit) < nTamNota
	cNumTit := Left(alltrim(cNumTit)+space(nTamNota),nTamNota)
Endif

dbSelectArea("VE4")
dbSeek(xFilial("VE4")+VV1->VV1_CODMAR)
if GetNewPar("MV_TPRVVEI","N") == "S" .and. Empty(cNota)
	cTipo     := "PR" //Provisorio
	cDesTipo  := "PROVISORIO"
Endif

dbSelectArea("SF4")
dbSetOrder(1)
if dbSeek(xFilial("SF4")+M->VV0_CODTES)
	if SF4->F4_DUPLIC == "S"
		
		if Empty(M->VV0_CODBCO)
			M->VV0_CODBCO := GetMv("MV_BCOCXA")
		Endif

		DbSelectArea("VAS")
		DbSeek(xFilial("VAS") + M->VV0_CODBCO + M->VV0_TABFAI + StrZero(M->VV0_PARCEL,4))

		VAR->(dbSeek(xFilial("VAR")+VAS->VAS_CODBCO+VAS->VAS_CODIGO))

		
		if nTitDif > 0
			AADD(aColsC,Array(nUsadoC+1))
			aColsC[Len(aColsC),FG_POSVAR("VS9_TIPPAG")] := cTipTit
			aColsC[Len(aColsC),FG_POSVAR("VS9_DATPAG")] := dDataBase
			aColsC[Len(aColsC),FG_POSVAR("VS9_VALPAG")] := nTitDif
			aColsC[Len(aColsC),FG_POSVAR("VS9_SEQUEN")] := StrZero(Len(aColsC),2)
			aColsC[Len(aColsC),nUsadoC+1] := .F.
		Endif
		
		if (Len(aColsC) = 1) .and. (Empty(aColsC[1,1])) .and. (Empty(aIteParc[1,1])) .and. !lTroco
			aItens := aClone(aColsC)
			aItens[1,1] := cTipo
			aItens[1,2] := cDesTipo
			aItens[1,3] := dDataBase
			aItens[1,4] := M->VV0_VALTOT
		Else
			aItens := aClone(aColsC)
		Endif
		
		nCont := 0
		For ix1 :=1 to len(aItens)
			
			if Empty(aItens[ix1,1]) .or. aItens[ix1,4]==0 .or. aItens[ix1,Len(aItens[ix1])]
				Loop
			Endif
			aParcelas := {}
			
			cCodBco := M->VV0_CODBCO
			if !Empty(aItens[ix1,FG_POSVAR('VS9_PORTAD',"aHeaderC")])
				cCodBco := aItens[ix1,FG_POSVAR('VS9_PORTAD',"aHeaderC")]
			Endif
			FG_Seek("SA6","cCodBco",1,.f.)
			cNumBord:= ""
			dDatBord:= cTod("")
			if SA6->A6_BORD == "0"
				cNumBord := "BCO"+SA6->A6_COD
				dDatBord := dDataBase
			Endif
			
			//Se for tipo de titulo informativo nao gera titulo
			if cTipo == GetNewPar("MV_TPTITIN","")
				nPagFab += aItens[ix1,4]
				Loop
			Endif
			
			if Empty(cNota)
				cPrefNF := SM0->M0_CODFIL+"E"
			Endif
			
			if cTipo <> "PR"
				if val(aItens[ix1,FG_POSVAR('VS9_SEQUEN',"aHeaderC")]) > 0
					nCont := val(aItens[ix1,FG_POSVAR('VS9_SEQUEN',"aHeaderC")])
				Else
					nCont++
				Endif
			Else
				nCont += 1
			Endif
   
	   	c_Natureza := M->VV0_NATFIN
			If VS9->(FieldPos("VS9_NATURE")) <> 0
				If !Empty(aItens[ix1,FG_POSVAR("VS9_NATURE","aHeaderC")])
			      c_Natureza := aItens[ix1,FG_POSVAR("VS9_NATURE","aHeaderC")]
			 	Endif		      
	   	Endif

			dbSelectArea("VS9")
			dbSetOrder(1)
			if dbSeek(xFilial("VS9")+left(VV9->VV9_NUMATE+space(30),len(VS9->VS9_NUMIDE))+"V"+aItens[ix1,FG_POSVAR("VS9_TIPPAG","aHeaderC")]+aItens[ix1,FG_POSVAR("VS9_SEQUEN","aHeaderC")])
				RecLock("VS9",.f.)
				VS9->VS9_TIPTIT := iif(cTipo=="PR","0","1")
				//		   	if TamSx3("E1_PARCELA")[1] == 1
				VS9->VS9_SEQPRO := ConvPN2PC(nSeqPro)
				//   	   	Else
				//   	   		VS9->VS9_SEQPRO := Soma1( strzero(nSeqPro-1,TamSx3("E1_PARCELA")[1]) )
				//   	   	Endif
				nSeqPro += 1
				MsUnlock()
			Endif
			
			if VE4->VE4_GTPRFT <> "0" .and. Empty(cNota) .and. M->VV0_TIPFAT <> "3"
				if ix1 = 1
					MsgInfo(STR0147 ,STR0012) //Os Titulos serao gerados somente no faturamento do atendimento ### Atencao
				Endif
				Loop
			Endif
			
			cCliFin := VV9->VV9_CODCLI
			cLojFin := VV9->VV9_LOJA
			
			dbSelectArea("VSA")
			dbSetOrder(1)
			if dbSeek(xFilial("VSA")+iif(cTipo <> "PR",aItens[ix1,1],cTipo)) .and. VSA->(FieldPos("VSA_FINANC")) > 0 .and. VSA->VSA_FINANC == "1"
				if !Empty(VSA->VSA_CODCLI)
					cCliFin  := VSA->VSA_CODCLI
					cLojFin  := VSA->VSA_LOJA
					cCliFin7 := VSA->VSA_CODCLI
					cLojFin7 := VSA->VSA_LOJA
				Endif
				IF M->VV0_CATVEN == "7"
				   If !Empty(M->VV0_CBCOAA)
						DbSelectArea("SA6")
						DBSetOrder(1)
						nPPos := recno()
						DBSeek(xFilial("SA6")+M->VV0_CBCOAA+M->VV0_ABCOAA)
						cCliFin := SA6->A6_CODCLI
						cLojFin := SA6->A6_LOJCLI
						cCliFin7 := VSA->VSA_CODCLI
						cLojFin7 := VSA->VSA_LOJA
						DBGoto(nPPos)
					Endif
				endif
			Endif
			
			cSE1CVend := SA3->A3_COD
			nSE1Comis := SA3->A3_COMIS
			If !Empty(M->VV0_NUMPED)
				SC5->(DbSetOrder(1))
				SC5->(DbSeek(xFilial("SC5")+M->VV0_NUMPED))
				cSE1CVend := SC5->C5_VEND1
				nSE1Comis := SC5->C5_COMIS1
			EndIf

			dEmissao := dDataBase
			if aItens[ix1,3] < dDataBase
				dEmissao := aItens[ix1,3]
			Endif
			
			if TamSx3("E1_PARCELA")[1] == 1
				cParcela := ConvPN2PC(ncont)
			Else
				//	   	   cParcela := Soma1( ALLTRIM(str(ncont-1)) )
				cParcela := Soma1( strzero(ncont-1,TamSx3("E1_PARCELA")[1]) )
			Endif
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Otavio - 24/06/2009 - FNC 00000015252                        ³
//³ Somente alimenta com natureza caso a mesma esteja preenchida ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd(aParcelas,{"E1_PREFIXO" , cPrefNF                  ,nil})
			aAdd(aParcelas,{"E1_NUM"     , cNumTit                  ,nil})
			aAdd(aParcelas,{"E1_PARCELA" , cParcela                 ,nil})
			aAdd(aParcelas,{"E1_TIPO"    , iif(cTipo <> "PR",aItens[ix1,1],cTipo),nil})
			If !Empty(c_Natureza)
				aAdd(aParcelas,{"E1_NATUREZ" , c_Natureza                ,nil})
			EndIf
			aAdd(aParcelas,{"E1_CLIENTE" , cCliFin                  ,nil})
			aAdd(aParcelas,{"E1_LOJA"    , cLojFin                  ,nil})
			aAdd(aParcelas,{"E1_EMISSAO" , dEmissao                 ,nil})
			aAdd(aParcelas,{"E1_VENCTO"  , aItens[ix1,3]            ,nil})
			aAdd(aParcelas,{"E1_VENCREA" , DataValida(aItens[ix1,3]),nil})
			aAdd(aParcelas,{"E1_VALOR"   , aItens[ix1,4]            ,nil})
//			aAdd(aParcelas,{"E1_NUMBOR"  , cNumBord                 ,nil})
//			aAdd(aParcelas,{"E1_DATABOR" , dDatBord                 ,nil})
//			aAdd(aParcelas,{"E1_PORTADO" , cCodBco                  ,nil})
			aAdd(aParcelas,{"E1_PREFORI" , cPrefixo                 ,nil})
			aAdd(aParcelas,{"E1_SITUACA" , cTipCob                  ,nil})
			aAdd(aParcelas,{"E1_VEND1"   , cSE1CVend                ,nil})
			aAdd(aParcelas,{"E1_COMIS1"  , nSE1Comis                ,nil})
			aAdd(aParcelas,{"E1_BASCOM1" , aItens[ix1,4]            ,nil})
			aAdd(aParcelas,{"E1_PEDIDO"  , M->VV0_NUMPED            ,nil})
			aAdd(aParcelas,{"E1_NUMNOTA" , M->VV0_NUMNFI            ,nil})
			aAdd(aParcelas,{"E1_SERIE"   , M->VV0_SERNFI            ,nil})
			If VV0->(FieldPos("VV0_CCUSTO")) > 0
				aAdd(aParcelas,{"E1_CCC"     , M->VV0_CCUSTO            ,nil})
			EndIf 
			aAdd(aParcelas,{"E1_ORIGEM" , "MATA460"              ,nil})
			
			pergunte("FIN040",.F.)
			
			dbSelectArea("VSB")
			dbSetOrder(1)
			if dbSeek(xFilial("VSB")+aItens[ix1,1])
				while !EOF() .and. VSB->VSB_TIPPAG == aItens[ix1,1]
					if VSB->VSB_TABDES == "SE1"
						dbSelectArea("VSE")
						if dbSeek(xFilial("VSE")+VV9->VV9_NUMATE+"V"+aItens[ix1,FG_POSVAR('VS9_TIPPAG',"aHeaderC")]+aItens[ix1,FG_POSVAR('VS9_SEQUEN',"aHeaderC")])
							if !Empty(VSE->VSE_VALDIG) .and. !Empty(VSB->VSB_CAMDES)
								aAdd(aParcelas,{VSB->VSB_CAMDES, VSE->VSE_VALDIG                  ,nil})
							Endif
						Endif
					Endif
					dbSelectArea("VSB")
					dbSkip()
				EndDo
			Endif
			
			aCols   := Nil
			
			if ExistBlock("DUPVEI011")
				aRecebe := {}
				aRecebe := ExecBlock("DUPVEI011",.f.,.f.,{aParcelas})
				If ValType(aRecebe) == "A"
					aParcelas := aClone(aRecebe)
				Endif
			Endif

			_nRecSA1 := SA1->(Recno())//salva posicao SA1
			
			MSExecAuto({|x| FINA040(x)},aParcelas)
			
			SA1->(Dbgoto(_nRecSA1))	//volta posicao SA1			
		
			if lMsErroAuto
				Help(" ",1,"ERROGERACR")
				Return(.f.)
			Endif
			
			if VS9->(FieldPos("VS9_PARCEL")) > 0
				DBSelectArea("VS9")
				reclock("VS9",.f.)
				VS9->VS9_PARCEL := SE1->E1_PARCELA
				msunlock()
			endif

			if Alltrim(GetMV("MV_BXVEI")) == "S" .and. cTipo <> "PR"
				if DTOS(aItens[ix1,3]) == DTOS(dDataBase)
					aTitulos  := {}
					AADD(aTitulos,{"E1_FILIAL"   ,xFilial("SE1")    ,Nil})
					AADD(aTitulos,{"E1_PREFIXO"  ,cPrefNF           ,Nil})
					AADD(aTitulos,{"E1_NUM"      ,cNumTit           ,Nil})
					AADD(aTitulos,{"E1_PARCELA"  ,SE1->E1_PARCELA,Nil})
					AADD(aTitulos,{"E1_TIPO"     ,SE1->E1_TIPO,Nil})
					AADD(aTitulos,{"AUTOTBX"     ,"NOR"             ,Nil})
					AADD(aTitulos,{"AUTDTBAIXA"  ,dDataBase         ,Nil})
					AADD(aTitulos,{"AUTDTCREDITO",dDataBase         ,Nil})
					AADD(aTitulos,{"AUTHIST"     ,'Baixa Automatica',Nil})
					AADD(aTitulos,{"AUTVALREC"   ,aItens[ix1,4]     ,Nil})
					
					MSExecAuto({|x| FINA070(x)},aTitulos)
					
					if lMsErroAuto
						Help(" ",1,"ERROBXATAV")
						Return(.f.)
					Endif
					
					//Marca como baixado no VS9
					dbSelectArea("VS9")
					dbSetOrder(1)
					if dbSeek(xFilial("VS9")+left(VV9->VV9_NUMATE+space(30),len(VS9->VS9_NUMIDE))+"V"+aItens[ix1,FG_POSVAR("VS9_TIPPAG")]+aItens[ix1,FG_POSVAR("VS9_SEQUEN")])
						RecLock("VS9",.f.)
						VS9->VS9_DATBAI := dDataBase
						MsUnlock()
					Endif
				Endif
			Endif
		Next
	Endif
	
	if Empty(cCodBco)
		cCodBco := GetMv("MV_BCOCXA")
	Endif
	FG_Seek("SA6","cCodBco",1,.f.)
	cNumBord:= ""
	dDatBord:= cTod("")
	if SA6->A6_BORD == "0"
		cNumBord := "BCO"+SA6->A6_COD
		dDatBord := dDataBase
	Endif
	
//	IF M->VV0_CATVEN == "7"
//		DbSelectArea("SA6")
//		DBSetOrder(1)
//		DBSeek(xFilial("SA6")+M->VV0_CBCOAA+M->VV0_ABCOAA)
//		DBSelectArea("SA1")
//		DbSetOrder(1)
//		DBSeek(xFilial("SA1")+SA6->A6_CODCLI+SA6->A6_LOJCLI)
//	Else
		SA1->(dbSeek(xFilial("SA1")+VV9->VV9_CODCLI+VV9->VV9_LOJA))
//	Endif
	// Financiamento - Integracao com Microsiga
	nCont:=0
//	dbSelectArea("SE4")
//	dbSetOrder(1)
//	dbSeek(xFilial("SE4")+M->VV0_FORPAG)
	For ix1 :=1 to Len(aIteParc)
		
		if Empty(aIteParc[ix1,1]) .or. aIteParc[ix1,2] == 0
			Loop
		Endif
		
		if Empty(cNota)
			cPrefNF := SM0->M0_CODFIL+"F"
		Endif
		
		if cTipo == "PR"
			nCont := nSeqPro
		Endif
		
		dbSelectArea("VS9")
		dbSetOrder(1)
		if dbSeek(xFilial("VS9")+left(VV9->VV9_NUMATE+space(30),len(VS9->VS9_NUMIDE))+"VDP"+strzero(ix1,2))
			RecLock("VS9",.f.)
			//	   	if TamSx3("E1_PARCELA")[1] == 1
			VS9->VS9_SEQPRO := ConvPN2PC(nSeqPro)
			//	   	Else
			//	   		VS9->VS9_SEQPRO := Soma1( ALLTRIM(str(nSeqPro-1)) )
			//    		VS9->VS9_SEQPRO := Soma1( strzero(nSeqPro-1,TamSx3("E1_PARCELA")[1]) )
			//    	Endif
			nSeqPro += 1
			MsUnlock()
		Endif
		
		if VE4->VE4_GTPRFT <> "0" .and. Empty(cNota) .and. M->VV0_TIPFAT <> "3"
			Loop
		Endif
		
		dEmissao := dDataBase
		if aIteParc[ix1,1] < dDataBase
			dEmissao := aIteParc[ix1,1]
		Endif
		
		nCont++
		
		if TamSx3("E1_PARCELA")[1] == 1
			cParcela := ConvPN2PC(ncont)
		Else
			//   	   cParcela := Soma1( ALLTRIM(str(ncont-1)) )
			cParcela := Soma1( strzero(ncont-1,TamSx3("E1_PARCELA")[1]) )
		Endif
		
		aFinanc := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Otavio - 24/06/2009 - FNC 00000015252                        ³
//³ Somente alimenta com natureza caso a mesma esteja preenchida ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		cSE1CVend := SA3->A3_COD
		nSE1Comis := SA3->A3_COMIS
		If !Empty(M->VV0_NUMPED)
			SC5->(DbSetOrder(1))
			SC5->(DbSeek(xFilial("SC5")+M->VV0_NUMPED))
			cSE1CVend := SC5->C5_VEND1
			nSE1Comis := SC5->C5_COMIS1
		EndIf
		
		aAdd(aFinanc,{"E1_PREFIXO" , cPrefNF                   ,nil})
		aAdd(aFinanc,{"E1_NUM"     , cNumTit                    ,nil})
		aAdd(aFinanc,{"E1_PARCELA" , cParcela                   ,nil})
		aAdd(aFinanc,{"E1_TIPO"    , cTipo                      ,nil})
		If !Empty(cNatureza)
			aAdd(aFinanc,{"E1_NATUREZ" , cNatureza                  ,nil})
		EndIf
		aAdd(aFinanc,{"E1_CLIENTE" , SA1->A1_COD                ,nil})
		aAdd(aFinanc,{"E1_LOJA"    , SA1->A1_LOJA               ,nil})
		aAdd(aFinanc,{"E1_EMISSAO" , dEmissao                   ,nil})
		aAdd(aFinanc,{"E1_VENCTO"  , aIteParc[ix1,1]            ,nil})
		aAdd(aFinanc,{"E1_VENCREA" , DataValida(aIteParc[ix1,1]),nil})
		aAdd(aFinanc,{"E1_VALOR"   , aIteParc[ix1,2]            ,nil})
//		aAdd(aFinanc,{"E1_NUMBOR"  , cNumBord                   ,nil})
//		aAdd(aFinanc,{"E1_DATABOR" , dDatBord                   ,nil})
//		aAdd(aFinanc,{"E1_PORTADO" , cCodBco                    ,nil})
		aAdd(aFinanc,{"E1_PREFORI" , cPrefixo                   ,nil})
		aAdd(aFinanc,{"E1_SITUACA" , cTipCob                    ,nil})
		aAdd(aFinanc,{"E1_VEND1"   , cSE1CVend                ,nil})
		aAdd(aFinanc,{"E1_COMIS1"  , nSE1Comis              ,nil})
		aAdd(aFinanc,{"E1_BASCOM1" , aIteParc[ix1,2]            ,nil})
		aAdd(aFinanc,{"E1_PEDIDO"  , M->VV0_NUMPED              ,nil})
//		aAdd(aFinanc,{"E1_NUMNOTA" , M->VV0_NUMNFI              ,nil})
		aAdd(aFinanc,{"E1_NUMNOTA" , cNumTit		              ,nil})
//		aAdd(aFinanc,{"E1_SERIE"   , M->VV0_SERNFI              ,nil})
		aAdd(aFinanc,{"E1_SERIE"   , cSerie			              ,nil})
//		Aadd(aFinanc,{"E1_PORCJUR" , SE4->E4_ACRSFIN			     , Nil  })
		If VV0->(FieldPos("VV0_CCUSTO")) > 0
			aAdd(aFinanc,{"E1_CCC"     , M->VV0_CCUSTO            ,nil})
		EndIf   
		aAdd(aFinanc,{"E1_ORIGEM" , "MATA460"              ,nil}) 
		
		lMsErroAuto := .f.
		lMsHelpAuto := .t.
		
		aHeader := Nil
		aCols   := Nil
		
		if ExistBlock("DUPVEI011")
			aRecebe := {}
			aRecebe := ExecBlock("DUPVEI011",.f.,.f.,{aFinanc})
			If ValType(aRecebe) == "A"
				aFinanc := aClone(aRecebe)
			Endif
		Endif         
		
		pergunte("FIN040",.F.)

		_nRecSA1 := SA1->(Recno())//salva posicao SA1
		
		MSExecAuto({|x| FINA040(x)},aFinanc)
		
		SA1->(Dbgoto(_nRecSA1))	//volta posicao SA1			
				

		
		if lMsErroAuto
			Help(" ",1,"ERROGERACR") // Erro na Geracao do Contas a Receber
			Return(.f.)
		Endif
		
		if VS9->(FieldPos("VS9_PARCEL")) > 0
			DBSelectArea("VS9")
			reclock("VS9",.f.)
			VS9->VS9_PARCEL := SE1->E1_PARCELA
			msunlock()
		endif

		//				{"E1_PARCELA"  ,ConvPN2PC(ix1)+SPACE(TamSx3("E1_PARCELA")[1]-len(ConvPN2PC(ix1))) ,Nil},;
		//				{"E1_TIPO"	   ,cTipo+" "            ,Nil},;
		
		if Alltrim(GetMV("MV_BXVEI")) == "S" .and. cTipo <> "PR"
			if DTOS(aIteParc[ix1,1]) == DTOS(dDataBase)   // Se for a Vista Baixa
				aBaixa  := {{"E1_PREFIXO"  ,cPrefNF,Nil},;
				{"E1_NUM"	   ,cNumTit              ,Nil},;
				{"E1_PARCELA"  ,SE1->E1_PARCELA      ,Nil},;
				{"E1_TIPO"	   ,SE1->E1_TIPO         ,Nil},;
				{"AUTMOTBX"	   ,"NOR"                ,Nil},;
				{"AUTDTBAIXA"  ,dDataBase            ,Nil},;
				{"AUTDTCREDITO",dDataBase            ,Nil},;
				{"AUTHIST"	   ,'Baixa Automatica'   ,Nil},;
				{"AUTVALREC"   ,aIteParc[ix1,2]     ,Nil }}
				
				lMsErroAuto := .f.
				lMsHelpAuto := .t.
				
				MSExecAuto({|x| FINA070(x)},aBaixa)
				
				If lMsErroAuto
					Help(" ",1,"ERROBXATAV") // Erro na Baixa do Titulo a Vista
					Return(.f.)
				EndIf
				
				//Marca como baixado no VS9
				dbSelectArea("VS9")
				dbSetOrder(1)
				if dbSeek(xFilial("VS9")+left(VV9->VV9_NUMATE+space(30),len(VS9->VS9_NUMIDE))+"VDP"+strzero(ix1,2))
					RecLock("VS9",.f.)
					VS9->VS9_DATBAI := dDataBase
					MsUnlock()
				Endif
			Endif
		Endif
	Next
	
	if M->VV0_VALTRO > 0 //lTroco .and. GetNewPar("MV_GE2TRTR","S") == "S" //Troca com Troco
		//nValPar := 0
		//For ix1:=1 to Len(aItens)
		//    nValPar += aItens[ix1,FG_POSVAR("VS9_VALPAG","aHeaderC")]
		//Next
		//if nValPar > iif(M->VV0_VALFIN>0,M->VV0_VALTOT-M->VV0_VALFIN,M->VV0_VALTOT)
		
		dbSelectArea("SA1")
		dbSeek(xFilial("SA1")+VV9->VV9_CODCLI+VV9->VV9_LOJA)
		nRecSA1 := SA1->(recno())
		If VV0->VV0_TIPVEN == "CA" .and. !Empty(VV0->VV0_CLIALI)
			dbSelectArea("SA1")
			dbSeek(xFilial("SA1")+VV0->VV0_CLIALI+VV0->VV0_LOJALI)
		Endif
		
		dbSelectArea("SA2")
		dbSetOrder(3)
		If !dbSeek(xFilial("SA2")+SA1->A1_CGC)
			// Cria Fornecedor
			aCabFornecedor := {}
			aAdd(aCabFornecedor,{"A2_FILIAL"  ,xFilial("SA2")    ,Nil})
			aAdd(aCabFornecedor,{"A2_COD"     ,GetSxENum("SA2","A2_COD") ,Nil})
			aAdd(aCabFornecedor,{"A2_LOJA"    ,SA1->A1_LOJA      ,Nil})
			aAdd(aCabFornecedor,{"A2_NOME"    ,SA1->A1_NOME      ,Nil})
			aAdd(aCabFornecedor,{"A2_TIPO"    ,SA1->A1_PESSOA    ,Nil})
			aAdd(aCabFornecedor,{"A2_CGC"     ,SA1->A1_CGC       ,Nil})
			aAdd(aCabFornecedor,{"A2_NREDUZ"  ,SA1->A1_NREDUZ    ,Nil})
			aAdd(aCabFornecedor,{"A2_END"     ,SA1->A1_END       ,Nil})
			aAdd(aCabFornecedor,{"A2_BAIRRO"  ,SA1->A1_BAIRRO    ,Nil})
			aAdd(aCabFornecedor,{"A2_MUN"     ,SA1->A1_MUN       ,Nil})
			aAdd(aCabFornecedor,{"A2_EST"     ,SA1->A1_EST       ,Nil})
			aAdd(aCabFornecedor,{"A2_CEP"     ,SA1->A1_CEP       ,Nil})
			aAdd(aCabFornecedor,{"A2_DDD"     ,SA1->A1_DDD       ,Nil})
			aAdd(aCabFornecedor,{"A2_TEL"     ,SA1->A1_TEL       ,Nil})
			aAdd(aCabFornecedor,{"A2_FAX"     ,SA1->A1_FAX       ,Nil})
			aAdd(aCabFornecedor,{"A2_EMAIL"   ,SA1->A1_EMAIL     ,Nil})
			aAdd(aCabFornecedor,{"A2_ATIVIDA" ,SA1->A1_ATIVIDA   ,Nil})
			aAdd(aCabFornecedor,{"A2_NATUREZ" ,GETNEWPAR("MV_NATNCC",SA1->A1_NATUREZ)   ,Nil})
			aAdd(aCabFornecedor,{"A2_SATIV1"  ,SA1->A1_SATIV1    ,Nil})
			aAdd(aCabFornecedor,{"A2_INSCR"   ,SA1->A1_INSCR     ,Nil})
			aAdd(aCabFornecedor,{"A2_ESTADO"  ,SA1->A1_ESTADO    ,Nil})
			aAdd(aCabFornecedor,{"A2_DDI"     ,SA1->A1_DDI       ,Nil})
			aAdd(aCabFornecedor,{"A2_PAIS"    ,SA1->A1_PAIS      ,Nil})
			aAdd(aCabFornecedor,{"A2_PFISICA" ,SA1->A1_PFISICA   ,Nil})
			aAdd(aCabFornecedor,{"A2_INSCRM"  ,SA1->A1_INSCRM    ,Nil})
			aAdd(aCabFornecedor,{"A2_CONTA"   ,SA1->A1_CONTA     ,Nil})
			aAdd(aCabFornecedor,{"A2_HPAGE"   ,SA1->A1_HPAGE     ,Nil})
			If SA1->(FieldPos("A1_IBGE"))>0 .and. SA2->(FieldPos("A2_IBGE"))>0
				aAdd(aCabFornecedor,{"A2_IBGE" ,SA1->A1_IBGE      ,Nil})
			EndIf
			
			ConfirmSx8()
			
			dbSelectArea("SA2")
			dbSetOrder(1)
			
			lMsErroAuto := .f.
			lMsHelpAuto := .t.
			
			MSExecAuto({|x,y| MATA020(x)},aCabFornecedor)
			
			If lMsErroAuto
				Return(.f.)
			EndIf
		Endif
		
		cCodBco := M->VV0_CODBCO
		cNumBord:= ""
		dDatBord:= cTod("")
		FG_Seek("SA6","cCodBco",1,.f.)
		if SA6->A6_BORD == "0"
			cNumBord := "BCO"+SA6->A6_COD
			dDatBord := dDataBase
		Endif
		
		cCodCli   := SA2->A2_COD
		cLojCli   := SA2->A2_LOJA
		cNatureza := SA2->A2_NATUREZ
		//nValParc  := nValPar - iif(M->VV0_VALFIN>0,M->VV0_VALTOT-M->VV0_VALFIN,M->VV0_VALTOT)
		nValParc  := M->VV0_VALTRO
		
		dbSelectArea("SE2")
		dbSetOrder(1)
		
		aVetDesp  := {}
		aAdd(aVetDesp,{"E2_PREFIXO"  ,cPrefNF    ,Nil})
		aAdd(aVetDesp,{"E2_NUM"      ,cNota       ,Nil})
		aAdd(aVetDesp,{"E2_TIPO"     ,cTipo       ,Nil})
		aAdd(aVetDesp,{"E2_NATUREZ"  ,cNatureza   ,Nil})
		aAdd(aVetDesp,{"E2_PARCELA"  ,"1"         ,Nil})
		aAdd(aVetDesp,{"E2_FORNECE"  ,SA2->A2_COD ,Nil})
		aAdd(aVetDesp,{"E2_LOJA"     ,SA2->A2_LOJA,Nil})
		aAdd(aVetDesp,{"E2_NOMFOR "  ,SA2->A2_NREDUZ,Nil})
		aAdd(aVetDesp,{"E2_EMISSAO"  ,dDataBase   ,Nil})
		aAdd(aVetDesp,{"E2_VENCTO"   ,dDataBase   ,Nil})
		aAdd(aVetDesp,{"E2_VALOR"    ,nValParc    ,Nil})
		aAdd(aVetDesp,{"E2_VLCRUZ"   ,nValParc    ,Nil})
		aAdd(aVetDesp,{"E2_NUMBOR"   ,cNumBord    ,Nil})
		aAdd(aVetDesp,{"E2_PORTADO"  ,cCodBco     ,Nil})
		aAdd(aVetDesp,{"E2_PREFORI"  ,cPrefixo    ,Nil})
		
		lMsHelpAuto := .t.
		lMsErroAuto := .f.
		pergunte("FIN050",.F.)
		MsExecAuto({|x,y,z| FINA050(x,y,z)},aVetDesp)
		if lMsErroAuto
			Return(.f.)
		Endif
		
		SA1->(dbGoto(nRecSA1))
		
		//Endif
	Endif
	
	if M->VV0_TIPFAT == "2" //Venda Direta / Frotista
		
		dbSelectArea("VE4")
		dbSeek(xFilial("VE4")+M->VV0_CODMAR)
		cCodFabF := VE4->VE4_CODFOR
		cLojFabF := VE4->VE4_LOJFOR
		cCodFabC := VE4->VE4_CODFAB
		cLojFabC := VE4->VE4_LOJA
		
		cCodBco  := M->VV0_CODBCO
		cNumBord := ""
		dDatBord := cTod("")
		FG_Seek("SA6","cCodBco",1,.f.)
		if SA6->A6_BORD == "0"
			cNumBord := "BCO"+SA6->A6_COD
			dDatBord := dDataBase
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Titulo a pagar para a fabrica                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA2")
		dbSeek(xFilial("SA2")+cCodFabF+cLojFabF)
		
		dbSelectArea("SE2")
		dbSetOrder(1)
		
		aFinanc := {}
		aAdd(aFinanc,{"E2_PREFIXO"  ,cPrefNF       ,Nil})
		aAdd(aFinanc,{"E2_NUM"      ,cNumTit        ,Nil})
		aAdd(aFinanc,{"E2_TIPO"     ,cTipo          ,Nil})
		aAdd(aFinanc,{"E2_NATUREZ"  ,SA2->A2_NATUREZ,Nil})
		aAdd(aFinanc,{"E2_PARCELA"  ,"1"            ,Nil})
		aAdd(aFinanc,{"E2_FORNECE"  ,cCodFabF       ,Nil})
		aAdd(aFinanc,{"E2_LOJA"     ,cLojFabF       ,Nil})
		aAdd(aFinanc,{"E2_EMISSAO"  ,dDataBase      ,Nil})
		aAdd(aFinanc,{"E2_VENCTO"   ,dDataBase      ,Nil})
		aAdd(aFinanc,{"E2_VALOR"    ,M->VV0_VALTOT-nPagFab  ,Nil})
		aAdd(aFinanc,{"E2_VLCRUZ"   ,M->VV0_VALTOT-nPagFab  ,Nil})
		aAdd(aFinanc,{"E2_NUMBOR"   ,cNumBord       ,Nil})
		aAdd(aFinanc,{"E2_PORTADO"  ,cCodBco        ,Nil})
		aAdd(aFinanc,{"E2_PREFORI"  ,cPrefixo       ,Nil})
		
		lMsHelpAuto := .t.
		lMsErroAuto := .f.
		pergunte("FIN050",.F.)
		MsExecAuto({|x,y,z| FINA050(x,y,z)},aFinanc)
		
		if lMsErroAuto
			DisarmTransaction()
			Break
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Titulo a receber de comissao                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA1")
		dbSeek(xFilial("SA1")+cCodFabC+cLojFabC)
		
		if TamSx3("E1_PARCELA")[1] == 1
			cParcela := ConvPN2PC(1)
		Else
			cParcela := Soma1( strzero(1-1,TamSx3("E1_PARCELA")[1]) )
		Endif
		
		aFinanc := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Otavio - 24/06/2009 - FNC 00000015252                        ³
//³ Somente alimenta com natureza caso a mesma esteja preenchida ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		cSE1CVend := SA3->A3_COD
		nSE1Comis := SA3->A3_COMIS
		If !Empty(M->VV0_NUMPED)
			SC5->(DbSetOrder(1))
			SC5->(DbSeek(xFilial("SC5")+M->VV0_NUMPED))
			cSE1CVend := SC5->C5_VEND1
			nSE1Comis := SC5->C5_COMIS1
		EndIf
		
		aAdd(aFinanc,{"E1_PREFIXO" , cPrefNF                   ,nil})
		aAdd(aFinanc,{"E1_NUM"     , cNumTit                    ,nil})
		//		aAdd(aFinanc,{"E1_PARCELA" , ConvPN2PC(1)               ,nil})
		aAdd(aFinanc,{"E1_PARCELA" , cParcela                   ,nil})
		aAdd(aFinanc,{"E1_TIPO"    , cTipo                      ,nil})
		If !Empty(cNatureza)
			aAdd(aFinanc,{"E1_NATUREZ" , cNatureza                  ,nil})
		EndIf
		aAdd(aFinanc,{"E1_CLIENTE" , cCodFabC                   ,nil})
		aAdd(aFinanc,{"E1_LOJA"    , cLojFabC                   ,nil})
		aAdd(aFinanc,{"E1_EMISSAO" , dDataBase                  ,nil})
		aAdd(aFinanc,{"E1_VENCTO"  , dDataBase                  ,nil})
		aAdd(aFinanc,{"E1_VENCREA" , dDataBase                  ,nil})
		aAdd(aFinanc,{"E1_VALOR"   , M->VV0_COMFTD              ,nil})
//		aAdd(aFinanc,{"E1_NUMBOR"  , cNumBord                   ,nil})
//		aAdd(aFinanc,{"E1_DATABOR" , dDatBord                   ,nil})
//		aAdd(aFinanc,{"E1_PORTADO" , cCodBco                    ,nil})
		aAdd(aFinanc,{"E1_PREFORI" , cPrefixo                   ,nil})
		aAdd(aFinanc,{"E1_SITUACA" , cTipCob                    ,nil})
		aAdd(aFinanc,{"E1_VEND1"   , cSE1CVend               ,nil})
		aAdd(aFinanc,{"E1_COMIS1"  , nSE1Comis              ,nil})
		aAdd(aFinanc,{"E1_BASCOM1" , M->VV0_COMFTD              ,nil})
		aAdd(aFinanc,{"E1_PEDIDO"  , M->VV0_NUMPED              ,nil})
		aAdd(aFinanc,{"E1_NUMNOTA" , M->VV0_NUMNFI              ,nil})
		aAdd(aFinanc,{"E1_SERIE"   , M->VV0_SERNFI              ,nil})
		If VV0->(FieldPos("VV0_CCUSTO")) > 0
			aAdd(aFinanc,{"E1_CCC"     , M->VV0_CCUSTO            ,nil})
		EndIf 
		aAdd(aFinanc,{"E1_ORIGEM" , "MATA460"              ,nil}) 
		
		pergunte("FIN040",.F.)
		lMsErroAuto := .f.
		lMsHelpAuto := .t.
		
		aHeader := Nil
		aCols   := Nil
		                
		_nRecSA1 := SA1->(Recno()) //salva posicao
		
		MSExecAuto({|x| FINA040(x)},aFinanc)
		
		SA1->(Dbgoto(_nRecSA1))	 //retorna posicao		

		
		if lMsErroAuto
			Help(" ",1,"ERROGERACR") // Erro na Geracao do Contas a Receber
			Return(.f.)
		Endif
	Endif
	
	//Valor do retorno do financiamento
	if M->VV0_VTXRET > 0 .and. M->VV0_TIPFIN == "1"

	                                                
		If	VV1->VV1_ESTVEI == "1" // Veiculo Usado
			cNatRetF := GetNewPar("MV_NATRFVU",cNatureza)
		Else // Novo
			cNatRetF := GetNewPar("MV_NATRFVN",cNatureza)
		Endif

		if TamSx3("E1_PARCELA")[1] == 1
			cParcela := ConvPN2PC(1)
		Else
			cParcela := Soma1( strzero(1-1,TamSx3("E1_PARCELA")[1]) )
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Rubens - 24/11/2009                                     ³
		//³Seleciona o Cliente da Instituicao Fin. da tabela de F&I³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCliFin := SA1->A1_COD
		cJojFin := SA1->A1_LOJA
		if VAR->(FieldPos("VAR_BCOCLI")) > 0 .and. VAR->(FieldPos("VAR_BCOLOJ")) > 0
			DbSelectArea("VAR")
			DbSetOrder(1)
			If DbSeek(xFilial("VAR")+M->VV0_CODBCO)
				If !Empty(VAR->VAR_BCOCLI)
					cCliFin := VAR->VAR_BCOCLI
					cJojFin := VAR->VAR_BCOLOJ
				EndIf
			EndIf
		endif
		cSE1CVend := SA3->A3_COD
		nSE1Comis := SA3->A3_COMIS
		If !Empty(M->VV0_NUMPED)
			SC5->(DbSetOrder(1))
			SC5->(DbSeek(xFilial("SC5")+M->VV0_NUMPED))
			cSE1CVend := SC5->C5_VEND1
			nSE1Comis := SC5->C5_COMIS1
		EndIf

		aParcelas := {}
		aAdd(aParcelas,{"E1_PREFIXO" , cPrefNF					        ,nil})
		aAdd(aParcelas,{"E1_NUM"     , cNumTit                     ,nil})
		aAdd(aParcelas,{"E1_PARCELA" , cParcela                    ,nil})
		aAdd(aParcelas,{"E1_TIPO"    , "RF"                        ,nil})
		aAdd(aParcelas,{"E1_NATUREZA", cNatRetF										 ,nil})
		aAdd(aParcelas,{"E1_CLIENTE" , cCliFin                     ,nil})
		aAdd(aParcelas,{"E1_LOJA"    , cJojFin                     ,nil})
		aAdd(aParcelas,{"E1_EMISSAO" , dDataBase                   ,nil})
		aAdd(aParcelas,{"E1_VENCTO"  , dDataBase                   ,nil})
		aAdd(aParcelas,{"E1_VENCREA" , dDataBase                   ,nil})
		aAdd(aParcelas,{"E1_VALOR"   , M->VV0_VTXRET-M->VV0_VCUSFN,nil})
//		aAdd(aParcelas,{"E1_NUMBOR"  , cNumBord                    ,nil})
//		aAdd(aParcelas,{"E1_DATABOR" , dDatBord                    ,nil})
//		aAdd(aParcelas,{"E1_PORTADO" , cCodBco                     ,nil})
		aAdd(aParcelas,{"E1_PREFORI" , cPrefixo                    ,nil})
		aAdd(aParcelas,{"E1_SITUACA" , cTipCob                     ,nil})
		aAdd(aParcelas,{"E1_VEND1"   , cSE1CVend                ,nil})
		aAdd(aParcelas,{"E1_COMIS1"  , nSE1Comis              ,nil})
		aAdd(aParcelas,{"E1_BASCOM1" , M->VV0_VTXRET-M->VV0_VCUSFN,nil})
		aAdd(aParcelas,{"E1_PEDIDO"  , M->VV0_NUMPED              ,nil})
		aAdd(aParcelas,{"E1_NUMNOTA" , M->VV0_NUMNFI              ,nil})
		aAdd(aParcelas,{"E1_SERIE"   , M->VV0_SERNFI              ,nil})
		aAdd(aParcelas,{"E1_ORIGEM" , "MATA460"              ,nil}) 
		If VV0->(FieldPos("VV0_CCUSTO")) > 0
			aAdd(aParcelas,{"E1_CCC"     , M->VV0_CCUSTO            ,nil})
		EndIf
		Acols := Nil
		
		pergunte("FIN040",.F.)

		_nRecSA1 := SA1->(Recno())//salva posicao SA1
		
		MSExecAuto({|x| FINA040(x)},aParcelas)
		
		SA1->(Dbgoto(_nRecSA1))	//volta posicao SA1

		
		if lMsErroAuto
			Help(" ",1,"ERROGERACR")
			Return(.f.)
		Endif
	Endif


	// Valor da TAC
	if M->VV0_VALTAC > 0 .and. VAR->VAR_TACFIN != "1" .and. M->VV0_TIPFIN == "1"
		
		if TamSx3("E1_PARCELA")[1] == 1
			cParcela := ConvPN2PC(1)
		Else
			cParcela := Soma1( strzero(1-1,TamSx3("E1_PARCELA")[1]) )
		Endif

		If	VV1->VV1_ESTVEI == "1" // Veiculo Usado
			cNatTACF := GetNewPar("MV_NATTCVU",cNatureza)
		Else // Novo
			cNatTACF := GetNewPar("MV_NATTCVN",cNatureza)
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Rubens - 24/11/2009                                     ³
		//³Seleciona o Cliente da Instituicao Fin. da tabela de F&I³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cCliFin := SA1->A1_COD
		cJojFin := SA1->A1_LOJA
		if VAR->(FieldPos("VAR_BCOCLI")) > 0 .and. VAR->(FieldPos("VAR_BCOLOJ")) > 0
			DbSelectArea("VAR")
			DbSetOrder(1)
			If DbSeek(xFilial("VAR")+M->VV0_CODBCO)
				If !Empty(VAR->VAR_BCOCLI)
					cCliFin := VAR->VAR_BCOCLI
					cJojFin := VAR->VAR_BCOLOJ
				EndIf
			EndIf			
		endif 
		cSE1CVend := SA3->A3_COD
		nSE1Comis := SA3->A3_COMIS
		If !Empty(M->VV0_NUMPED)
			SC5->(DbSetOrder(1))
			SC5->(DbSeek(xFilial("SC5")+M->VV0_NUMPED))
			cSE1CVend := SC5->C5_VEND1
			nSE1Comis := SC5->C5_COMIS1
		EndIf
		
		aParcelas := {}
		aAdd(aParcelas,{"E1_PREFIXO" , cPrefNF					       ,nil})
		aAdd(aParcelas,{"E1_NUM"     , cNumTit                    ,nil})
		//		aAdd(aParcelas,{"E1_PARCELA" , ConvPN2PC(1)               ,nil})
		aAdd(aParcelas,{"E1_PARCELA" , cParcela                   ,nil})
		aAdd(aParcelas,{"E1_TIPO"    , "TAC"                      ,nil})
		aAdd(aParcelas,{"E1_NATUREZA", cNatTACF                   ,nil})
		aAdd(aParcelas,{"E1_CLIENTE" , cCliFin                    ,nil})
		aAdd(aParcelas,{"E1_LOJA"    , cJojFin                    ,nil})
		aAdd(aParcelas,{"E1_EMISSAO" , dDataBase                  ,nil})
		aAdd(aParcelas,{"E1_VENCTO"  , dDataBase                  ,nil})
		aAdd(aParcelas,{"E1_VENCREA" , dDataBase                  ,nil})
		aAdd(aParcelas,{"E1_VALOR"   , M->VV0_VALTAC              ,nil})
//		aAdd(aParcelas,{"E1_NUMBOR"  , cNumBord                   ,nil})
//		aAdd(aParcelas,{"E1_DATABOR" , dDatBord                   ,nil})
//		aAdd(aParcelas,{"E1_PORTADO" , cCodBco                    ,nil})
		aAdd(aParcelas,{"E1_PREFORI" , cPrefixo                   ,nil})
		aAdd(aParcelas,{"E1_SITUACA" , cTipCob                    ,nil})
		aAdd(aParcelas,{"E1_VEND1"   , cSE1CVend                ,nil})
		aAdd(aParcelas,{"E1_COMIS1"  , nSE1Comis             ,nil})
		aAdd(aParcelas,{"E1_PEDIDO"  , M->VV0_NUMPED              ,nil})
		aAdd(aParcelas,{"E1_NUMNOTA" , M->VV0_NUMNFI              ,nil})
		aAdd(aParcelas,{"E1_SERIE"   , M->VV0_SERNFI              ,nil}) 
		aAdd(aParcelas,{"E1_ORIGEM" , "MATA460"              ,nil}) 
		If VV0->(FieldPos("VV0_CCUSTO")) > 0
			aAdd(aParcelas,{"E1_CCC"     , M->VV0_CCUSTO            ,nil})
		EndIf
		aHeader := Nil
		aCols   := Nil
		
		pergunte("FIN040",.F.)
		_nRecSA1 := SA1->(Recno())//salva posicao SA1
		
		MSExecAuto({|x| FINA040(x)},aParcelas)
		
		SA1->(Dbgoto(_nRecSA1))	//volta posicao SA1

		if lMsErroAuto
			Help(" ",1,"ERROGERACR")
			Return(.f.)
		Endif
	Endif
	
	//Comissao do financiamento // PLUS
	if M->VV0_PCOMFN > 0	.and. M->VV0_TIPFIN == "1" // Comissao de Financiamento // PLUS
	
		DbSelectArea("VV0")
		RecLock("VV0")
		VV0_VCOMFN := (M->VV0_VALFIN / 100) * M->VV0_PCOMFN
		MsUnlock()
		
		if TamSx3("E1_PARCELA")[1] == 1
			cParcela := ConvPN2PC(1)
		Else
			cParcela := Soma1( strzero(1-1,TamSx3("E1_PARCELA")[1]) )
		Endif

		If	VV1->VV1_ESTVEI == "1" // Veiculo Usado
			cNatComF := GetNewPar("MV_NATCFVU",cNatureza)
		Else // Novo
			cNatComF := GetNewPar("MV_NATCFVN",cNatureza)
		Endif
		cSE1CVend := SA3->A3_COD
		nSE1Comis := SA3->A3_COMIS
		If !Empty(M->VV0_NUMPED)
			SC5->(DbSetOrder(1))
			SC5->(DbSeek(xFilial("SC5")+M->VV0_NUMPED))
			cSE1CVend := SC5->C5_VEND1
			nSE1Comis := SC5->C5_COMIS1
		EndIf
		
		aParcelas := {}
		aAdd(aParcelas,{"E1_PREFIXO" , cPrefNF       ,nil})
		aAdd(aParcelas,{"E1_NUM"     , cNumTit                    ,nil})
		//		aAdd(aParcelas,{"E1_PARCELA" , ConvPN2PC(1)               ,nil})
		aAdd(aParcelas,{"E1_PARCELA" , cParcela                   ,nil})
		aAdd(aParcelas,{"E1_TIPO"    , "CMF"                      ,nil})
		aAdd(aParcelas,{"E1_NATUREZA", cNatComF                   ,nil})
		aAdd(aParcelas,{"E1_CLIENTE" , SA1->A1_COD                ,nil})
		aAdd(aParcelas,{"E1_LOJA"    , SA1->A1_LOJA               ,nil})
		aAdd(aParcelas,{"E1_EMISSAO" , dDataBase                  ,nil})
		aAdd(aParcelas,{"E1_VENCTO"  , dDataBase                  ,nil})
		aAdd(aParcelas,{"E1_VENCREA" , dDataBase                  ,nil})
		aAdd(aParcelas,{"E1_VALOR"   , VV0->VV0_VCOMFN            ,nil})
//		aAdd(aParcelas,{"E1_NUMBOR"  , cNumBord                   ,nil})
//		aAdd(aParcelas,{"E1_DATABOR" , dDatBord                   ,nil})
//		aAdd(aParcelas,{"E1_PORTADO" , cCodBco                    ,nil})
		aAdd(aParcelas,{"E1_PREFORI" , cPrefixo                   ,nil})
		aAdd(aParcelas,{"E1_SITUACA" , cTipCob                    ,nil})
		aAdd(aParcelas,{"E1_VEND1"   , cSE1CVend                ,nil})
		aAdd(aParcelas,{"E1_COMIS1"  , nSE1Comis              ,nil})
		aAdd(aParcelas,{"E1_PEDIDO"  , M->VV0_NUMPED              ,nil})
		aAdd(aParcelas,{"E1_NUMNOTA" , M->VV0_NUMNFI              ,nil})
		aAdd(aParcelas,{"E1_SERIE"   , M->VV0_SERNFI              ,nil})
		aAdd(aParcelas,{"E1_ORIGEM" , "MATA460"              ,nil}) 
		If VV0->(FieldPos("VV0_CCUSTO")) > 0
			aAdd(aParcelas,{"E1_CCC"     , M->VV0_CCUSTO            ,nil})
		EndIf
		aHeader := Nil
		aCols   := Nil
		
		pergunte("FIN040",.F.)
		_nRecSA1 := SA1->(Recno())//salva posicao SA1
		
		MSExecAuto({|x| FINA040(x)},aParcelas)
		
		SA1->(Dbgoto(_nRecSA1))	//volta posicao SA1		

		if lMsErroAuto
			Help(" ",1,"ERROGERACR")
			Return(.f.)
		Endif
	Endif

	// Geracao do Rebate
	if M->VV0_VALFIN > 0	.and. M->VV0_TIPFIN == "1"

		DbSelectArea("VAS")
		DbSeek(xFilial("VAS") + M->VV0_CODBCO + M->VV0_TABFAI + StrZero(M->VV0_PARCEL,4))
		nRebate := 0
		If VAS->VAS_PERCTB > 0
			nRebate := (M->VV0_VALFIN * (VAS->VAS_PERCTB/100))
			DbSelectArea("VAR")
			DbSeek(xFilial("VAR") + M->VV0_CODBCO)
			
//			cCodBco  := M->VV0_CODBCO
//			cNumBord := ""
//			dDatBord := cTod("")
//			FG_Seek("SA6","cCodBco",1,.f.)
//			if SA6->A6_BORD == "0"
//				cNumBord := "BCO"+SA6->A6_COD
//				dDatBord := dDataBase
//			Endif
			
			dbSelectArea("SA1")
			DbSetOrder(1)
			dbSeek(xFilial("SA1")+VAR->VAR_BCOCLI+VAR->VAR_BCOLOJ)

			dbSelectArea("SA2")
			DbSetOrder(3)
			dbSeek(xFilial("SA2")+SA1->A1_CGC)
			DbSetOrder(1)
			
			dbSelectArea("SE2")
			dbSetOrder(1)
			
			aRebate := {}
			aAdd(aRebate,{"E2_PREFIXO"  ,cPrefNF       ,Nil})
			aAdd(aRebate,{"E2_NUM"      ,cNumTit        ,Nil})
			aAdd(aRebate,{"E2_TIPO"     ,"RBT"          ,Nil})
			aAdd(aRebate,{"E2_NATUREZ"  ,SA2->A2_NATUREZ,Nil})
			aAdd(aRebate,{"E2_PARCELA"  ,"1"            ,Nil})
			aAdd(aRebate,{"E2_FORNECE"  ,SA2->A2_COD    ,Nil})
			aAdd(aRebate,{"E2_LOJA"     ,SA2->A2_LOJA   ,Nil})
			aAdd(aRebate,{"E2_EMISSAO"  ,dDataBase      ,Nil})
			aAdd(aRebate,{"E2_VENCTO"   ,dDataBase      ,Nil})
			aAdd(aRebate,{"E2_VALOR"    ,nRebate        ,Nil})
			aAdd(aRebate,{"E2_VLCRUZ"   ,nRebate        ,Nil})
//			aAdd(aRebate,{"E2_NUMBOR"   ,cNumBord       ,Nil})
//			aAdd(aRebate,{"E2_PORTADO"  ,cCodBco        ,Nil})
			aAdd(aRebate,{"E2_PREFORI"  ,cPrefixo       ,Nil})
			
			lMsHelpAuto := .t.
			lMsErroAuto := .f.
			pergunte("FIN050",.F.)
			MsExecAuto({|x,y,z| FINA050(x,y,z)},aRebate)
			
			if lMsErroAuto
				DisarmTransaction()
				Break
			Endif
		Endif
		
	Endif

	//Titulos de acessorios/Itens de Campanha/Agregados
	aTitAgreg := {}
	// 1o Elemento - Tipo do titulo
	// 2o Elemento - Valor
	if VZ7->(FieldPos("VZ7_TIPTIT")) <> 0

		For ni := 1 to Len(aColsIC)
	
			If !aColsIC[ni,len(aColsIC[ni])]
				If !Empty(aColsIC[ni,FG_POSVAR("VZ7_TIPTIT","aHeaderIC")])// Gera titulo
					nPos := aScan(aTitAgreg,{|x| alltrim(x[1]) == aColsIC[ni,FG_POSVAR("VZ7_TIPTIT","aHeaderIC")] })
					If nPos == 0
						aadd(aTitAgreg,{aColsIC[ni,FG_POSVAR("VZ7_TIPTIT","aHeaderIC")],aColsIC[ni,FG_POSVAR("VZ7_VALITE","aHeaderIC")]})
					Else 
						aTitAgreg[nPos,2] += aColsIC[ni,FG_POSVAR("VZ7_VALITE","aHeaderIC")]
					Endif
				Endif
			Endif
		Next
		
		For ni := 1 to Len(aTitAgreg)
				
				aParcelas := {}
				
				cCodBco := M->VV0_CODBCO
				FG_Seek("SA6","cCodBco",1,.f.)
				cNumBord:= ""
				dDatBord:= cTod("")
				if SA6->A6_BORD == "0"
					cNumBord := "BCO"+SA6->A6_COD
					dDatBord := dDataBase
				Endif
				
				nCont++
				if TamSx3("E1_PARCELA")[1] == 1
					cParcela := ConvPN2PC(ncont)
				Else
					//	   	   cParcela := Soma1( ALLTRIM(str(ncont-1)) )
					cParcela := Soma1( strzero(ncont-1,TamSx3("E1_PARCELA")[1]) )
				Endif 
				cSE1CVend := SA3->A3_COD
				nSE1Comis := SA3->A3_COMIS
				If !Empty(M->VV0_NUMPED)
					SC5->(DbSetOrder(1))
					SC5->(DbSeek(xFilial("SC5")+M->VV0_NUMPED))
					cSE1CVend := SC5->C5_VEND1
					nSE1Comis := SC5->C5_COMIS1
				EndIf
				aAdd(aParcelas,{"E1_PREFIXO" , cPrefNF                    ,nil})
				aAdd(aParcelas,{"E1_NUM"     , cNumTit                    ,nil})
				aAdd(aParcelas,{"E1_PARCELA" , cParcela                   ,nil})
				aAdd(aParcelas,{"E1_TIPO"    , aTitAgreg[ni,1]            ,nil})
				aAdd(aParcelas,{"E1_NATUREZA", cNatureza                  ,nil})
				aAdd(aParcelas,{"E1_CLIENTE" , SA1->A1_COD                ,nil})
				aAdd(aParcelas,{"E1_LOJA"    , SA1->A1_LOJA               ,nil})
				aAdd(aParcelas,{"E1_EMISSAO" , dDataBase                  ,nil})
				aAdd(aParcelas,{"E1_VENCTO"  , dDataBase		             ,nil})
				aAdd(aParcelas,{"E1_VENCREA" , DataValida(dDataBase)		 ,nil})
				aAdd(aParcelas,{"E1_VALOR"   , aTitAgreg[ni,2]            ,nil})
//				aAdd(aParcelas,{"E1_NUMBOR"  , cNumBord                   ,nil})
//				aAdd(aParcelas,{"E1_DATABOR" , dDatBord                   ,nil})
//				aAdd(aParcelas,{"E1_PORTADO" , cCodBco                    ,nil})
				aAdd(aParcelas,{"E1_PREFORI" , cPrefixo                   ,nil})
				aAdd(aParcelas,{"E1_SITUACA" , cTipCob                    ,nil})
				aAdd(aParcelas,{"E1_VEND1"   , cSE1CVend                  ,nil})
				aAdd(aParcelas,{"E1_COMIS1"  , nSE1Comis	              ,nil})
				aAdd(aParcelas,{"E1_BASCOM1" , aTitAgreg[ni,2]            ,nil})
				aAdd(aParcelas,{"E1_PEDIDO"  , M->VV0_NUMPED              ,nil})
				aAdd(aParcelas,{"E1_NUMNOTA" , M->VV0_NUMNFI              ,nil})
				aAdd(aParcelas,{"E1_SERIE"   , M->VV0_SERNFI              ,nil}) 
				aAdd(aParcelas,{"E1_ORIGEM" , "MATA460"              ,nil}) 
				If VV0->(FieldPos("VV0_CCUSTO")) > 0
					aAdd(aParcelas,{"E1_CCC"     , M->VV0_CCUSTO            ,nil})
				EndIf
				aHeader := Nil
				aCols   := Nil
				
				pergunte("FIN040",.F.)
				_nRecSA1 := SA1->(Recno())//salva posicao SA1

				MSExecAuto({|x| FINA040(x)},aParcelas)
				
				SA1->(Dbgoto(_nRecSA1))	//volta posicao SA1

				
				if lMsErroAuto
					Help(" ",1,"ERROGERACR")
					Return(.f.)
				Endif
				
		Next
		
 	Endif		
/*
	//Titulos de acessorios de terceiros
	nCont := 0
	dbSelectArea("VV6")
	dbSetOrder(3)
	dbSeek(xFilial("VV6")+M->VV9_NUMATE)
	while !EOF() .and. M->VV9_NUMATE == VV6_NUMATE
		
		If VV6->VV6_VALEQP > 0
			
			if VV6->VV6_TIPREG <> "4"
				dbSkip()
				Loop
			Endif
			
			aParcelas := {}
			
			cCodBco := M->VV0_CODBCO
			FG_Seek("SA6","cCodBco",1,.f.)
			cNumBord:= ""
			dDatBord:= cTod("")
			if SA6->A6_BORD == "0"
				cNumBord := "BCO"+SA6->A6_COD
				dDatBord := dDataBase
			Endif
			
			nCont++
			if TamSx3("E1_PARCELA")[1] == 1
				cParcela := ConvPN2PC(ncont)
			Else
				//	   	   cParcela := Soma1( ALLTRIM(str(ncont-1)) )
				cParcela := Soma1( strzero(ncont-1,TamSx3("E1_PARCELA")[1]) )
			Endif
			aAdd(aParcelas,{"E1_PREFIXO" , cPrefNF                    ,nil})
			aAdd(aParcelas,{"E1_NUM"     , cNumTit                    ,nil})
			aAdd(aParcelas,{"E1_PARCELA" , cParcela                   ,nil})
			aAdd(aParcelas,{"E1_TIPO"    , "AT"                       ,nil})
			aAdd(aParcelas,{"E1_NATUREZA", cNatureza                  ,nil})
			aAdd(aParcelas,{"E1_CLIENTE" , SA1->A1_COD                ,nil})
			aAdd(aParcelas,{"E1_LOJA"    , SA1->A1_LOJA               ,nil})
			aAdd(aParcelas,{"E1_EMISSAO" , dDataBase                  ,nil})
			aAdd(aParcelas,{"E1_VENCTO"  , VV6->VV6_DATINS            ,nil})
			aAdd(aParcelas,{"E1_VENCREA" , DataValida(VV6->VV6_DATINS),nil})
			aAdd(aParcelas,{"E1_VALOR"   , VV6->VV6_VALEQP            ,nil})
			aAdd(aParcelas,{"E1_NUMBOR"  , cNumBord                   ,nil})
			aAdd(aParcelas,{"E1_DATABOR" , dDatBord                   ,nil})
			aAdd(aParcelas,{"E1_PORTADO" , cCodBco                    ,nil})
			aAdd(aParcelas,{"E1_PREFORI" , cPrefixo                   ,nil})
			aAdd(aParcelas,{"E1_SITUACA" , cTipCob                    ,nil})
			aAdd(aParcelas,{"E1_VEND1"   , SA3->A3_COD                ,nil})
			aAdd(aParcelas,{"E1_COMIS1"  , SA3->A3_COMIS              ,nil})
			aAdd(aParcelas,{"E1_BASCOM1" , VV6->VV6_VALEQP            ,nil})
			aAdd(aParcelas,{"E1_PEDIDO"  , M->VV0_NUMPED              ,nil})
			aAdd(aParcelas,{"E1_NUMNOTA" , M->VV0_NUMNFI              ,nil})
			aAdd(aParcelas,{"E1_SERIE"   , M->VV0_SERNFI              ,nil})
			If VV0->(FieldPos("VV0_CCUSTO")) > 0
				aAdd(aParcelas,{"E1_CCC"     , M->VV0_CCUSTO            ,nil})
			EndIf
			aHeader := Nil
			aCols   := Nil
			MSExecAuto({|x| FINA040(x)},aParcelas)
			
			if lMsErroAuto
				Help(" ",1,"ERROGERACR")
				Return(.f.)
			Endif
			
		Endif
		
		dbSelectArea("VV6")
		dbSkip()
	EndDo
	
	//Titulos de agregados
	nCont := 0
	dbSelectArea("VAT")
	dbSetOrder(1)
	dbSeek(xFilial("VAT")+M->VV9_NUMATE)
	while !EOF() .and. M->VV9_NUMATE == VAT_NUMATE
		
		If VAT->VAT_VALNEG > 0
			
			dbSelectArea("VAU")
			dbSetOrder(1)
			dbSeek(xFilial("VAU")+VAT->VAT_CODNEG)
			
			aParcelas := {}
			
			cCodBco := M->VV0_CODBCO
			FG_Seek("SA6","cCodBco",1,.f.)
			cNumBord:= ""
			dDatBord:= cTod("")
			if SA6->A6_BORD == "0"
				cNumBord := "BCO"+SA6->A6_COD
				dDatBord := dDataBase
			Endif
			
			nCont++
			if TamSx3("E1_PARCELA")[1] == 1
				cParcela := ConvPN2PC(ncont)
			Else
				//	   	   cParcela := Soma1( ALLTRIM(str(ncont-1)) )
				cParcela := Soma1( strzero(ncont-1,TamSx3("E1_PARCELA")[1]) )
			Endif
			aAdd(aParcelas,{"E1_PREFIXO" , cPrefNF                     ,nil})
			aAdd(aParcelas,{"E1_NUM"     , cNumTit                     ,nil})
			aAdd(aParcelas,{"E1_PARCELA" , cParcela                    ,nil})
			aAdd(aParcelas,{"E1_TIPO"    , VAU->VAU_PRETIT             ,nil})
			aAdd(aParcelas,{"E1_NATUREZA", cNatureza                   ,nil})
			aAdd(aParcelas,{"E1_CLIENTE" , SA1->A1_COD                 ,nil})
			aAdd(aParcelas,{"E1_LOJA"    , SA1->A1_LOJA                ,nil})
			aAdd(aParcelas,{"E1_EMISSAO" , dDataBase                   ,nil})
			aAdd(aParcelas,{"E1_VENCTO"  , VAT->VAT_DATNEG             ,nil})
			aAdd(aParcelas,{"E1_VENCREA" , DataValida(VAT->VAT_DATNEG),nil})
			aAdd(aParcelas,{"E1_VALOR"   , VAT->VAT_VALNEG             ,nil})
			aAdd(aParcelas,{"E1_NUMBOR"  , cNumBord                    ,nil})
			aAdd(aParcelas,{"E1_DATABOR" , dDatBord                    ,nil})
			aAdd(aParcelas,{"E1_PORTADO" , cCodBco                     ,nil})
			aAdd(aParcelas,{"E1_PREFORI" , cPrefixo                    ,nil})
			aAdd(aParcelas,{"E1_SITUACA" , cTipCob                     ,nil})
			aAdd(aParcelas,{"E1_VEND1"   , SA3->A3_COD                ,nil})
			aAdd(aParcelas,{"E1_COMIS1"  , SA3->A3_COMIS              ,nil})
			aAdd(aParcelas,{"E1_BASCOM1" , VAT->VAT_VALNEG            ,nil})
			aAdd(aParcelas,{"E1_PEDIDO"  , M->VV0_NUMPED              ,nil})
			aAdd(aParcelas,{"E1_NUMNOTA" , M->VV0_NUMNFI              ,nil})
			aAdd(aParcelas,{"E1_SERIE"   , M->VV0_SERNFI              ,nil})
			If VV0->(FieldPos("VV0_CCUSTO")) > 0
				aAdd(aParcelas,{"E1_CCC"     , M->VV0_CCUSTO            ,nil})
			EndIf
			Acols := Nil
			MSExecAuto({|x| FINA040(x)},aParcelas)
			
			if lMsErroAuto
				Help(" ",1,"ERROGERACR")
				Return(.f.)
			Endif
			
		Endif
		
		dbSelectArea("VAT")
		dbSkip()
	EndDo
*/
	
	//Ponto de entrada depois da gravacao dos titulos
	If ExistBlock("VM010TIT")
		ExecBlock("VM010TIT",.f.,.f.)
	Endif
	
Else
	
	MsgInfo(STR0149 ,STR0012)  //TES nao encontrado.. ### atenmcao
	Return(.f.)
	
Endif

aCols   := aclone(aColsSlv)
aHeader := aclone(aHeaderSlv)

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CANCTIT   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancela os titulos gerados                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CANCTIT(cTipo)

Local cont, cont2
Local aPrefixo := {}
Local cNumTit  := iif(Empty(VV0->VV0_NUMNFI),Substr(VV9->VV9_NUMATE,2,nTamNota),VV0->VV0_NUMNFI)

if !M->VV9_STATUS $ "A/P"
	aadd(aPrefixo,PrefTIT())
	aadd(aPrefixo,SM0->M0_CODFIL+"E")
	aadd(aPrefixo,SM0->M0_CODFIL+"F")
Endif

For cont:=1 to Len(aPrefixo)
	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))
	If SE1->(dbSeek(xFilial("SE1")+aPrefixo[cont]+cNumTit))
		aParcelas := {}
		while ! Eof() .and. SE1->E1_FILIAL == xFilial('SE1') .and. SE1->E1_PREFIXO == aPrefixo[cont] .and. SE1->E1_NUM == cNumTit
			If SE1->E1_TIPO $ MVIRABT+"/"+MVINABT+"/"+MVCFABT+"/"+MVCSABT+"/"+MVPIABT // Nao leva para a exclusao os Titulo de Abatimento de Impostos
				DbSkip()
				Loop
			Endif
			AADD(aParcelas,{{"E1_PREFIXO" ,E1_PREFIXO ,nil},;
			{"E1_NUM"     ,E1_NUM     ,nil},;
			{"E1_PARCELA" ,E1_PARCELA ,nil},;
			{"E1_TIPO"    ,E1_TIPO    ,nil},;
			{"E1_NATUREZ" ,E1_NATUREZ ,nil},;
			{"E1_CLIENTE" ,E1_CLIENTE ,nil},;
			{"E1_LOJA"    ,E1_LOJA    ,nil},;
			{"E1_EMISSAO" ,E1_EMISSAO ,nil},;
			{"E1_VENCTO"  ,E1_VENCTO  ,nil},;
			{"E1_VENCREA" ,E1_VENCREA ,nil},;
			{"E1_VALOR"   ,E1_VALOR   ,nil},;
			{"E1_NUMBOR"  ,E1_NUMBOR  ,Nil},;
			{"E1_DATABOR" ,E1_DATABOR ,Nil},;
			{"E1_PORTADO" ,E1_PORTADO ,Nil},;
			{"E1_SITUACA" ,E1_SITUACA ,Nil},; 
			{"E1_ORIGEM" , "MATA460"  ,nil}}) 
			dbSelectArea("SE1")
			dbSkip()
		Enddo
		pergunte("FIN040",.F.)
		For cont2 = 1 to len(aParcelas)
			lMsErroAuto := .f.
			MSExecAuto({|x,y| FINA040(x,y)},aParcelas[cont2],5)
			if lMsErroAuto
				MostraErro()
				Return(.f.)
			Endif
		Next
	Endif
Next

dbSelectArea("SE2")
SE2->(dbSetOrder(1))
If SE2->(dbSeek(xFilial("SE2")+cPrefNF+cNumTit))
	aParcelas := {}
	while ! Eof() .and. SE2->E2_FILIAL == xFilial('SE2') .and. SE2->E2_PREFIXO == cPrefNF .and. SE2->E2_NUM == cNumTit
		AADD(aParcelas,{{"E2_PREFIXO" ,E2_PREFIXO ,nil},;
		{"E2_NUM"     ,E2_NUM     ,nil},;
		{"E2_PARCELA" ,E2_PARCELA ,nil},;
		{"E2_TIPO"    ,E2_TIPO    ,nil},;
		{"E2_NATUREZA",E2_NATUREZA,nil},;
		{"E2_FORNECE" ,E2_FORNECE ,nil},;
		{"E2_LOJA"    ,E2_LOJA    ,nil},;
		{"E2_EMISSAO" ,E2_EMISSAO ,nil},;
		{"E2_VENCTO"  ,E2_VENCTO  ,nil},;
		{"E2_VENCREA" ,E2_VENCREA ,nil},;
		{"E2_VALOR"   ,E2_VALOR   ,nil},;
		{"E2_NUMBOR"  ,E2_NUMBOR  ,Nil} })
		dbSelectArea("SE2")
		dbSkip()
	Enddo
	pergunte("FIN050",.F.)
	For cont2 = 1 to len(aParcelas)
		
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z| FINA050(x,y,z)},aParcelas[cont2],,5)
		if lMsErroAuto
			MostraErro()
			Return(.f.)
		Endif
	Next
Endif

Return(lMsErroAuto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CANCNFS   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancela nota fiscal de saida                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CANCNFS()

Local aRegSD2 := {}
Local aRegSE1 := {}
Local aRegSE2 := {}

dbSelectArea("SF2")
dbSetOrder(1)
If dbSeek(xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI )
	cPrefNF := SF2->F2_PREFIXO
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o estorno do documento de saída pode ser feito     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
		/*Alias da Tabela SF2,Recno do SF2, Array com os registro do SD2, Array com os registro do SE1, Array com os registro do SE2 ) */
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estorna o documento de saida                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PERGUNTE("MTA521",.f.)
		SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1)))
	Else
		//Nao pode ser excluida.
		lMsErroAuto:= .T.
		Return(.f.)
	EndIf
Endif

Return(lMsErroAuto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_PRECO011  ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preco de venda do modelo                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PRECO011(lSelecao)
Local nValRpr := 0
Local nValRmt := 0
Local nValCus := 0
Local nValVda := 0
Local _cQuery := ""
Local _cAlVVP := "SQLVVP"
Default lSelecao := .f.

//Levanta preco atual da tabela.
if lSelect // (M->VV0_TIPFAT <> "2" .AND. M->VV0_SIMULA <> "1") .or. lSelecao
	_cQuery := "SELECT VVP.VVP_DATPRC , VVP.VVP_VACRPR , VVP.VVP_VACRMT , VVP.VVP_CUSTAB , VVP.VVP_VALTAB FROM "+RetSqlName("VVP")+" VVP WHERE VVP.VVP_FILIAL='"+xFilial("VVP")+"' AND VVP.VVP_CODMAR='"+VV1->VV1_CODMAR+"' AND VVP.VVP_MODVEI='"+VV1->VV1_MODVEI+"' AND VVP.VVP_SEGMOD='"+VV1->VV1_SEGMOD+"' AND VVP.D_E_L_E_T_=' ' ORDER BY VVP.VVP_DATPRC"
Else
	VV2->(dbSetOrder(1))
	VV2->(dbSeek(xFilial("VV2")+M->VV0_CODMAR+M->VV0_MODVEI))
	_cQuery := "SELECT VVP.VVP_DATPRC , VVP.VVP_VACRPR , VVP.VVP_VACRMT , VVP.VVP_CUSTAB , VVP.VVP_VALTAB FROM "+RetSqlName("VVP")+" VVP WHERE VVP.VVP_FILIAL='"+xFilial("VVP")+"' AND VVP.VVP_CODMAR='"+M->VV0_CODMAR+"' AND VVP.VVP_MODVEI='"+M->VV0_MODVEI+"' AND VVP.VVP_SEGMOD='"+VV2->VV2_SEGMOD+"' AND VVP.D_E_L_E_T_=' ' ORDER BY VVP.VVP_DATPRC"
Endif
dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVP , .F., .T. )
While !( _cAlVVP )->( Eof() )
	If	( _cAlVVP )->( VVP_DATPRC ) <= dtos(dDataBase)
		nValRpr := ( _cAlVVP )->( VVP_VACRPR )
		nValRmt := ( _cAlVVP )->( VVP_VACRMT )
		nValCus := ( _cAlVVP )->( VVP_CUSTAB )
		nValVda := ( _cAlVVP )->( VVP_VALTAB )
	Else
		Exit
	EndIf
	( _cAlVVP )->( DbSkip() )
EndDo
( _cAlVVP )->( dbCloseArea() )
Return(nValVda)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_PERG011   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Perguntas gerais na tela para o usuario                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PERG011(nOpcao)
Local oDlgPerg
Local lRet    := .f.
Local nCheck  := 1
Local nCheck2 := 1
Local _cQuery := ""
Local _cAlVVP := "SQLVVP"
Local lQtdAtu := .t. // Qtde VIRTUAL atual por Modelo 
Local nQtdAtu := 0   // Qtde VIRTUAL atual por Modelo 
lValChassi := .t.
if nOpcao = 1 //Faturamento Direto
	If M->VV0_NUMTRA == VV0->VV0_NUMTRA .and. VV0->VV0_OPEMOV == "8"
		nCheck := 2 // Pre-selecionar Venda Futura
		lValChassi := .f.
	EndIf
	VV2->(dbSetOrder(1))
	VV2->(dbSeek(xFilial("VV2")+cCodMar+space(TamSx3("VV1_CODMAR")[1]-len(cCodMar))+cModVei))
	DEFINE MSDIALOG oDlgPerg TITLE OemtoAnsi(STR0150) FROM  02,04 TO 08,37 OF oMainWnd    //Tipo de venda
//		@ 001,006 RADIO oCheck1 VAR nCheck 3D SIZE 77,10 PROMPT OemToAnsi(STR0151) , OemToAnsi(STR0152) , OemToAnsi(STR0153) OF oDlgPerg PIXEL ON CHANGE FS_RADIO(nCheck) //Faturamento Direto ###Simulacao ### Venda Entrega Futura
		@ 001,006 RADIO oCheck1 VAR nCheck 3D SIZE 77,10 PROMPT OemToAnsi(STR0152) , OemToAnsi(STR0153) OF oDlgPerg PIXEL ON CHANGE FS_RADIO(nCheck) //Faturamento Direto ###Simulacao ### Venda Entrega Futura
		@ 006,083 RADIO oCheck2 VAR nCheck2 3D SIZE 41,10 PROMPT OemToAnsi(STR0096) , OemToAnsi(STR0097) OF oDlgPerg PIXEL   //novo - usado
		@ 001,082 TO 030,124 LABEL "" OF oDlgPerg PIXEL //
		oCheck2:lVisible:=.f.
		If VV2->(FieldPos("VV2_QTDATU")) <> 0
			lQtdAtu := ( VV2->VV2_QTDATU > 0 )
			nQtdAtu := VV2->VV2_QTDATU
		EndIf
		@ 005,092 SAY oModVirt1 VAR STR0257 SIZE 33,08 OF oDlgPerg PIXEL COLOR CLR_RED
		@ 015,090 MSGET oModVirt2 VAR nQtdAtu PICTURE "9999" SIZE 28,4 OF oDlgPerg PIXEL COLOR CLR_BLACK WHEN .f.
		If nCheck <> 2
			oModVirt1:lVisible := .f. 
			oModVirt2:lVisible := .f. 
		EndIf
		@ 032,016 BUTTON oOk     PROMPT OemToAnsi(STR0121) OF oDlgPerg SIZE 43,11 PIXEL ACTION (lRet := .t. , oDlgPerg:End()) WHEN ( nCheck <= 1 .or. lQtdAtu ) // OK
		@ 032,074 BUTTON oCancel PROMPT OemToAnsi(STR0120) OF oDlgPerg SIZE 43,11 PIXEL ACTION (oDlgPerg:End()) //cancelar
		oOk:SetFocus()
	ACTIVATE MSDIALOG oDlgPerg CENTER
	If lRet
		//Verifica se o modelo esta em producao ainda
		If !Empty(VV2->VV2_FINMOD)
			If dDataBase > VV2->VV2_FINMOD
				MsgAlert(STR0154 ,STR0012) //Veiculo fora de producao! ### Atencao
				If !( nCheck == 1 .and. nCheck2 == 2 )
					lRet := .f.
					Return(lRet)
				EndIf
			EndIf
		EndIf
		
		//Ponto de entrada de verificacao do modelo selecionado
		If ExistBlock("CHKMOD011")
			if !ExecBlock("CHKMOD011",.f.,.f.)                             
				Return(.f.)
			Endif
		Endif
		
		lJaPer011 := .t.
//		M->VV0_TIPFAT := iif(nCheck == 1,"2",iif(nCheck == 2,"0","3")) //0=NormalNovo / 1=NormalUsado / 2=Fat.Direto
		M->VV0_TIPFAT := iif(nCheck == 1,"0","3") //0=NormalNovo / 1=NormalUsado / 2=Fat.Direto
//		if nCheck == 2 // Simulacao
		if nCheck == 1 // Simulacao
//			M->VV0_SIMULA := "1" //Sim
			M->VV0_OPEMOV := "1" //Simulacao
		Elseif nCheck == 2 // Venda Futura
			M->VV0_OPEMOV := "8" //Venda Futura
		EndIf
		M->VV0_CODMAR := cCodMar+space(TamSx3("VV1_CODMAR")[1]-len(cCodMar))
		M->VV0_CHASSI := space(TamSx3("VV0_CHASSI")[1])
		M->VV0_GRUMOD := VV2->VV2_GRUMOD
		M->VV0_MODVEI := VV2->VV2_MODVEI
		M->VV0_RESERV := ""
		M->VV0_DATVAL := CTOD("")
		M->VV0_HORVAL := "     "
		
		VLDSX3011("VV0_CODMAR")
		VLDSX3011("VV0_GRUMOD")
		VLDSX3011("VV0_MODVEI")
		_cQuery := "SELECT VVP.VVP_DATPRC , VVP.VVP_VALTAB FROM "+RetSqlName("VVP")+" VVP WHERE VVP.VVP_FILIAL='"+xFilial("VVP")+"' AND VVP.VVP_CODMAR='"+M->VV0_CODMAR+"' AND VVP.VVP_MODVEI='"+M->VV0_MODVEI+"' AND VVP.VVP_SEGMOD='"+VV2->VV2_SEGMOD+"' AND VVP.VVP_VALTAB>0 AND VVP.D_E_L_E_T_=' ' ORDER BY VVP.VVP_DATPRC"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVP , .F., .T. )
		While !( _cAlVVP )->( Eof() )
			If	( _cAlVVP )->( VVP_DATPRC ) <= dtos(dDataBase)
				M->VV0_VALMOV := ( _cAlVVP )->( VVP_VALTAB )
				M->VV0_VALTOT := ( _cAlVVP )->( VVP_VALTAB )
			Else
				Exit
			EndIf
			( _cAlVVP )->( DbSkip() )
		EndDo
		( _cAlVVP )->( dbCloseArea() )
	EndIf
EndIf
Return(lRet)

// Andre Luis Almeida - 22/04/08 - Mostra ou nao o RADIO2 referente ao Veiculo NOVO/USADO //
Static Function FS_RADIO(nCheck)
lValChassi := .t.
oCheck2:lVisible  := .f.
oModVirt1:lVisible := .f.
oModVirt2:lVisible := .f.
If nCheck == 1
	lValChassi := .f.
	oCheck2:lVisible := .t.
	oCheck2:SetFocus()
Else
	If nCheck == 2	.and. VV2->(FieldPos("VV2_QTDATU")) <> 0
		lValChassi := .f.
		oModVirt1:lVisible := .t.
		oModVirt2:lVisible := .t.
	EndIf
	nCheck2 := 1
	oOk:SetFocus()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VLDSX3011    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a validacao do campo que esta no SX3               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VLDSX3011(cCampo)

Local lRet := .f.
Local aArea := GetArea()

dbSelectArea("SX3")
dbSetOrder(2)
if dbSeek(cCampo)
	lRet := &(X3_VALID)
Endif
dbSelectArea("SX3")
dbSetOrder(1)

Restarea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ BOTOES011    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Habilita ou desabilita alguns botoes na tela               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function BOTOES011()

if Type("oCalcula") == "O"
	if oFolder011:noption == 6
		oCalcula:lVisible := .t.
	Else
		oCalcula:lVisible := .f.
	Endif
Endif

if Type("oCortesia") == "O"
	if oFolder011:noption == 3
		oCortesia:lVisible := .t.
	Else
		oCortesia:lVisible := .f.
	Endif
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CLI011    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava 2 fase dos arquivos do atendimento                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CLI011(lTela)

Local lExiste
Local nT := 0 
Default lTela := .t.
dbSelectArea("SA1")
If !Empty(M->VV9_CODCLI+M->VV9_LOJA)
	dbSetOrder(1)
	lExiste := dbSeek(xFilial("SA1")+M->VV9_CODCLI+M->VV9_LOJA)
Else
	dbSetOrder(2)
	lExiste := dbSeek(xFilial("SA1")+M->VV9_NOMVIS)
EndIf
if lTela
	if lExiste
		FC010CON()
	Else //Rafael Gonçalves - incluido a opcao de cadastro de clientes prospects
		nT := Aviso(STR0012, STR0260,{STR0261 ,STR0262}) //Atencao - Cadastro de clietnes - cadastro -Prospects
		If nT == 1
			axInclui("SA1")
			VISIT011()
		//ElseIf nT == 2
		//	VEIVA620CLI()
		EndIf
	Endif
Endif

Return(lExiste)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GRVATE2   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava 2 fase dos arquivos do atendimento                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRVATE2()

Local nValorBase := 0
Local aVetTra    := {}
Local aValCom    := {}
Local aQUltMov   := {}

dbSelectarea("VV9")
RecLock("VV9",.f.)
VV9->VV9_STATUS := "F"
VV9->VV9_MOTIVO := ""
VV9->VV9_DATCAN := ctod("")
MsUnlock()

dbSelectarea("VV1")
dbSetOrder(2)
dbSeek(cFilSelVV1+M->VV0_CHASSI)

dbSelectarea("VV0")
dbSetOrder(1)
dbSeek(xFilial("VV0")+M->VV9_NUMATE)
RecLock("VV0",.f.)
if M->VV0_TIPFAT $ "01"
	VV0->VV0_AUTFAT := "1"
	VV0->VV0_NUMNFI := cNota
	VV0->VV0_SERNFI := cSerie
	VV0->VV0_NUMPED := M->VV0_NUMPED
	VV0->VV0_MODVDA := VV1->VV1_ESTVEI
Else
//	VV0->VV0_AUTFAT := "1"				//So habilitar quando tratar faturamento direto no atendimento.
	VV0->VV0_NUMNFI := "FATDIR"
	VV0->VV0_DPGFAB := M->VV0_DPGFAB
	VV0->VV0_MODVDA := M->VV0_MODVDA
Endif
if VV1->VV1_SITVEI == "4" //Consignado
	VV0->VV0_MODVDA := "4"
Endif
VV0->VV0_STATUS := "F"
MsUnlock()

VV0->(dbGoTo(VV0->(Recno())))
FGX_AMOVVEI(xFilial("VV1"),M->VV0_CHASSI)

dbSelectarea("VVA")
dbSetOrder(1)
dbSeek(xFilial("VVA")+M->VV9_NUMATE)
RecLock("VVA",.f.)
VVA->VVA_ACESSO := M->VVA_ACESSO
If Empty(VVA->VVA_USUARI)
	VVA->VVA_USUARI := Upper(Subs(cUsuario,7,15))
Endif

nValorBase := IMPOSTO011()

aAdd(aVetTra,{VV0->VV0_CODVEN,1})
If ExistBlock("FS_COMVEI")
	ExecBlock("FS_COMVEI",.f.,.f.)
	VVA->VVA_COMVDE := M->VVA_COMVDE
	ExecBlock("FS_COMVEI",.f.,.f.)
	VVA->VVA_COMGER := M->VVA_COMGER
Else
	aValCom := FG_COMISS("V",aVetTra,VV0->VV0_DATMOV,VV0->VV0_TIPFAT,nValorBase,"T")
	VVA->VVA_COMVDE := aValCom[1]
	VVA->VVA_COMGER := aValCom[2]
Endif
MsUnlock()

////////////////////////////////////////////////////////
// Levanta a ultima E-Entrada por 0-Compra do Veiculo //
////////////////////////////////////////////////////////
aQUltMov := FM_VEIUMOV( VVA->VVA_CHASSI , "E" , "0" )
If len(aQUltMov) > 0
	VVG->(dbSetOrder(1))
	VVG->(dbSeek(xFilial("VVG")+aQUltMov[3]))
	DbSelectArea("VVA")
	RecLock("VVA",.f.)
	VVA->VVA_TRACPA := aQUltMov[3] // TRACPA
	VVA->VVA_SIMVDA := "V"
	VVA->VVA_FATTOT := VVA->VVA_VALMOV
	VVA->VVA_ESTVEI := VVG->VVG_ESTVEI
	VVA->VVA_CODORI := VVG->VVG_CODORI
	VVA->VVA_CODIND := VVG->VVG_CODIND
	MsUnLock()
EndIf
////////////////////////////////////////////////////////

CPOMEM011("R")

dbSelectarea("VV1")
dbSetOrder(2)
if dbSeek(cFilSelVV1+M->VV0_CHASSI)
	RecLock("VV1",.f.)
	VV1->VV1_SITVEI := "1" // Vendido
	VV1->VV1_NUMTRA := M->VV9_NUMATE
	VV1->VV1_DATVEN := ddatabase
	VV1->VV1_PROANT := VV1->VV1_PROATU
	VV1->VV1_LJPANT := VV1->VV1_LJPATU
	VV1->VV1_PROATU := VV9->VV9_CODCLI
	VV1->VV1_LJPATU := VV9->VV9_LOJA
	MsUnlock()
Endif


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CHKINF    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Checa informacoes digitadas no atendimento                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CHKINF()

Local cont
Local lRetorno := .t.
Local cMsg := ""
Local cLocVei := VV1->VV1_LOCPAD
Local nValDP := 0
Local lValEstq := .t. // Valida Estoque ?

if Empty(VV1->VV1_LOCPAD)
	cLocVei := GETMV("MV_LOCVEIN") //Novo
	if VV1->VV1_ESTVEI == '1'
		cLocVei := GETMV("MV_LOCVEIU") //Usado
	Endif
	if VV1->VV1_SITVEI == "4" //Consignado
		cLocVei := GETMV("MV_LOCVEIC")
	Endif
Endif

if !(lRetorno := FS_CLI011(.f.))
	cMsg := STR0155   //Cliente nao esta cadastrado...
ElseIf !(lRetorno := !Empty(M->VV0_FORPAG))
	cMsg := STR0156   //Forma de pagamento nao informado...
ElseIf !(lRetorno := !Empty(M->VV0_TIPVEN))
	cMsg := STR0157    //Tipo de venda nao informado...
ElseIf !(lRetorno := !Empty(M->VV0_CODTES))
	cMsg := STR0158    //TES de venda nao informado...
//ElseIf Type("M->VV0_DEPTO") <> "U" .and. !(lRetorno := !Empty(M->VV0_DEPTO))
//	cMsg := STR0312    //Departamento de venda nao informado...
Endif
//If Type("M->VV0_NATFIN") <> "U" .and. !(lRetorno := !Empty(M->VV0_NATFIN))
//	cMsg := "Natureza Financeira nao informada..."    //Natureza Financeira nao informada...
//Else

if lRetorno
	nTotalEnt := ATUENT011()
	nValDP := 0
	For cont :=1 to Len(aIteParc)
		if aIteParc[cont,2] > 0
			nValDP += aIteParc[cont,2]
		Endif
	Next
	If !(Left(GetNewPar("MV_VEIDNFT","N"),1) $ "S/1") // Permite Valores da Venda (NF) e Titulos divergentes ? ( 1 ou S -> Sim / 0 ou N -> Nao )
		if Abs(nTotalEnt+nValDP+M->VV0_VALFIN - M->VV0_VALTOT) > 0.01 .and. !lTroco
			lRetorno := .f.
			cMsg := STR0159   //Valor dos pagamentos estao incoerentes com o valor da venda...
		Endif
	EndIf
Endif

if lRetorno

	If VAI->(FieldPos("VAI_ESTNEG")) <> 0
		If VAI->VAI_ESTNEG == "1" // Usuario permitido Faturar sem Estoque
			lValEstq := .f.
		Endif
	Endif               
	If lValEstq
		dbSelectarea("SB1")
		dbSetOrder(7)
		If dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT)
			dbSelectArea("SB2")
			dbSetOrder(1)
			If !dbSeek(xFilial("SB2")+SB1->B1_COD+cLocVei) .or. SB2->B2_QATU <= 0
				SF4->(dbSetOrder(1))
				SF4->(dbSeek(xFilial("SF4")+M->VV0_CODTES))
				If SF4->F4_ESTOQUE == "S" // TES Movimenta Estoque	
					lRetorno := .f.
					cMsg := STR0160   //Veiculo nao esta no estoque!
				EndIf
			EndIf
		Else
			lRetorno := .f.
			cMsg := STR0160    //Veiculo nao esta no estoque!
		EndIf
	EndIf   

Endif

if lRetorno
	//Ponto de entrada para avisar vendedor que foi liberado
	If ExistBlock("CHKFAT011")
		if !ExecBlock("CHKFAT011",.f.,.f.)
			lRetorno := .f.
			cMsg := STR0161      //Venda nao liberada!
		Endif
	Endif
Endif

if !lRetorno
	MsgInfo(cMsg,STR0012) //Atencao
Endif

Return (lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VEND011   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Traz o vendedor automatico                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VEND011()

dbSelectArea("VAI")
dbSetOrder(4)
dbSeek(xFilial("VAI")+__cUserID)

dbSelectArea("SA3")
dbSetOrder(1)
if type("Inclui") == "U" .or. Inclui .or. (!Inclui .and. Empty(VV0->VV0_CODVEN))
	dbSeek(xFilial("SA3")+VAI->VAI_CODVEN)
	M->VV0_CODVEN := VAI->VAI_CODVEN
	M->VV0_NOMVEN := SA3->A3_NOME
Else
	dbSeek(xFilial("SA3")+M->VV0_CODVEN)
	M->VV0_NOMVEN := SA3->A3_NOME
Endif

lEmiNfi := VAI->VAI_EMINFI == "1"
lNegPag := VAI->VAI_NEGPAG == "1"
lLibVei := VAI->VAI_LIBVEI == "1"
lResVei := VAI->VAI_RESVEI == "1"

if VAI->(FieldPos("VAI_AUTFAT")) > 0
	lAutFat := VAI->VAI_AUTFAT == "1"
Endif
if VAI->(FieldPos("VAI_PEDAPR")) > 0
	lPedApr := VAI->VAI_PEDAPR == "1"
Endif
if VAI->(FieldPos("VAI_ALTAPR")) > 0
	lAltApr := ( VAI->VAI_ALTAPR $ "13" )
	lAltPAp := ( VAI->VAI_ALTAPR $ "23" )
EndIf
if VAI->(FieldPos("VAI_MNCOMV")) > 0
	lMinComv := VAI->VAI_MNCOMV == "1"
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_CALC011   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula as parcelas na negociacao de pagamento             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CALC011()

Local cont
Local cDia
Local nMes
Local nMesAnt
Local nValFin := 0

if Left(Funname(),4) == "VEIX"
	return .t.
Endif

FS_VALOR011()

lCalcVEI := .f.     
if FM_PILHA("VEIVM011")
	INIFIS011()
	FISCAL011()
Endif
//nValFin := iIf(Empty(M->VV0_VALFIN),M->VV0_VALTOT-nTotalEnt,M->VV0_VALFIN)
//nValFin := M->VV0_VALTOT-nTotalEnt
//If M->VV0_VALFIN > 0
//	nValFin := M->VV0_VALFIN
//Else
	nValFin := (M->VV0_VALTOT-Round(nAcresFin,2))-nTotalEnt-M->VV0_VALFIN
	If Round(nAcresFin,2) > 0
		M->VV0_VALTOT -= Round(nAcresFin,2)
	Endif
//Endif
//if !Empty(M->VV0_VALTAC)
//If !Empty(M->VV0_TABFAI)
//   DbSelectArea("VAR")
//   DbSeek(xFilial("VAR")+M->VV0_CODBCO)
//	if VAR->VAR_TACFIN == "1"
//		nValFin += M->VV0_VALTAC
//	Endif
//Endif

if nValFin < 0
	nValFin := 0
Endif
nAcresFin := 0
dbSelectarea("SE4")
dbSetOrder(1)
if dbSeek(xFilial("SE4")+M->VV0_FORPAG)
	if (!AllTrim(SE4->E4_COND) == "0" .or. SE4->E4_TIPO == "A") .and. M->VV0_TIPFIN <> "1"
		FG_CONDICAO(M->VV0_DATINI,strzero(M->VV0_DIA1PC,4),strzero(M->VV0_PARCEL,4),strzero(M->VV0_INTERV,4),"1","VV0_FORPAG",nValFin,cTipOpe)
		if M->VV0_FIXDIA == "1" .and. Val(M->VV0_DIAFIX) > 0 .and. Val(M->VV0_DIAFIX) < 32
			cDia    := M->VV0_DIAFIX
			nMesAnt := 0
			For cont := 1 to Len(aIteParc)
				if Val(cDia) > Day(LastDay(aIteParc[cont,1]))
					cDia := Str(Day(LastDay(aIteParc[cont,1])),2)
				Else
					cDia := M->VV0_DIAFIX
				Endif
				cDia := StrZero(Val(cDia),2)
				nMes := Month(aIteParc[cont,1])
				if nMesAnt == nMes
					nMes := Month(aIteParc[cont,1])+1                                                                                         
					If nMes == 13
						aIteParc[cont,1] := ctod(left(Transform(aIteParc[cont,1],"@D"),6)+Substr(Str(Year(aIteParc[cont,1])+1,4),3,2))
					Endif
				Endif
				aIteParc[cont,1] := ctod(cDia+'/'+StrZero(nMes,2)+"/"+Substr(Str(Year(aIteParc[cont,1]),4),3,2))
				nMesAnt := nMes
			Next
		Endif
		/// PROBLEMA aIteParc *********************************************************************** ///
	   If M->VV0_TIPFIN == "0" // Faturamento Proprio
			if M->VV0_COEFIC > 0                  
			
				If MsgYesno("Valores de Parcela linear?",OemToAnsi(STR0012))
					nCoef   := (M->VV0_COEFIC/30)*M->VV0_INTERV
					nCoefic := 1+(nCoef/100)
					nParcAnt := aIteParc[1,2]
					nTotal  := 0     
					nTotAnt := 0     
					For cont := 1 to Len(aIteParc) 
						nExp    := (aIteParc[cont,1]-dDatabase)/30
						if nExp <= 0
						   nJurMes := 1
						Else
						   nJurMes := nCoefic**nExp
						Endif
//						nTotAnt += aIteParc[cont,2]
//						aIteParc[cont,2] := nParcAnt * nJurmes
						aIteParc[cont,2] := aIteParc[cont,2] * nJurmes
						nParcAnt := aIteParc[cont,2]
						nTotal += nParcAnt
					Next            
					For cont := 1 to Len(aIteParc)              
						aIteParc[cont,2] := nTotal/Len(aIteParc)
					Next            
					nAcresFin := nTotal - nTotAnt
					M->VV0_VALTOT += naCresFin
				Else
				   // Juro simples
	//				nValPar := (nValFin / Len(aIteParc))
	//				nCoefic := (M->VV0_COEFIC/30)/100
	//				For cont := 1 to Len(aIteParc)              
	//					nAcresci := (((aIteParc[cont,2] * nCoefic)) * (aIteParc[cont,1]-dDatabase))
	//					aIteParc[cont,2] := nValPar + nAcresci
	//				Next            
	
					// Juro Composto      
					nCoef   := (M->VV0_COEFIC/30)*M->VV0_INTERV
					nCoefic := 1+(nCoef/100)
					nParcAnt := aIteParc[1,2]
					nTotal  := 0
					nTotAnt := 0
					For cont := 1 to Len(aIteParc)              
						nExp    := (aIteParc[cont,1]-dDatabase)/30
						if nExp <= 0
						   nJurMes := 1
						Else
						   nJurMes := nCoefic**nExp
						Endif
//						nTotAnt += aIteParc[cont,2]
//						aIteParc[cont,2] := nParcAnt * nJurMes
						aIteParc[cont,2] := aIteParc[cont,2] * nJurMes
						nParcAnt := aIteParc[cont,2]
						nTotal  += nParcAnt
					Next            
					nAcresFin := nTotal - nTotAnt
					M->VV0_VALTOT += naCresFin
				Endif				
				
//				nValPar := (nValFin / Len(aIteParc)
//				nValPar := (nValFin * (1+(M->VV0_COEFIC/100))) / Len(aIteParc)
//				For cont := 1 to Len(aIteParc)
//					aIteParc[cont,2] := nValPar
//				Next
			Endif
		Endif
	Else
		dDatPar := dDataBase
		if !Empty(M->VV0_DATINI)
			dDatPar := M->VV0_DATINI
		Endif
		//	   aIteParc := {{dDatPar,iIf(Empty(M->VV0_VALFIN),M->VV0_VALTOT-nTotalEnt,M->VV0_VALFIN)}}
		aIteParc := {{dDatPar,M->VV0_VALTOT-nTotalEnt-M->VV0_VALFIN}}
	Endif
Endif

//M->VV0_VALPAR := nValFin * M->VV0_COEFIC

If ( ExistBlock("VM011PFIN") )// Altera Parcelas do Financiamento (aIteParc)
	aParcFin := ExecBlock("VM011PFIN",.F.,.F.,{aIteParc})
	If ( ValType(aParcFin) == "A" )
		aIteParc := aClone(aParcFin)
	EndIf
EndIf

if lTroco .and. nValFin <= 0  //M->VV0_VALFIN == M->VV0_VALTOT
	nValPar  := 0
	aIteParc := {{cTod(""),0}}
Endif

if Type("oLbParc") <> "U"
	oLbParc:SetArray(aIteParc)
	oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
	Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
	oLbParc:Refresh()
Endif

lJaCal011 := .t.

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VISIT011     ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Seleciona o cliente e mostra os campos na tela             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VISIT011()

dbSelectarea("SA1")
dbSetOrder(2)
if Inclui .and. dbSeek(xFilial("SA1")+M->VV9_NOMVIS) .and. !ReadVar() $ "M->VV9_CODCLI/M->VV9_LOJA"
	M->VV9_CODCLI := SA1->A1_COD
	M->VV9_LOJA   := SA1->A1_LOJA
	if Empty(M->VV9_TELVIS)
		M->VV9_TELVIS := SA1->A1_TEL
	Endif
	M->VV9_TIPMID := "8" //Ja e cliente
Else
	dbSetOrder(1)
	if !Empty(M->VV9_CODCLI) .and. !Empty(M->VV9_LOJA)
		if dbSeek(xFilial("SA1")+M->VV9_CODCLI+M->VV9_LOJA)
			M->VV9_NOMVIS := SA1->A1_NOME
			M->VV9_CODCLI := SA1->A1_COD
			M->VV9_LOJA   := SA1->A1_LOJA
			M->VV9_TELVIS := SA1->A1_TEL
			M->VV9_TIPMID := "8" //Ja e cliente
			If !lVisual // Validar Limite de Credito quando nao for "Visualizar"
				If "V" $ GetMv("MV_CHKCRE")
					If !MaAvalCred(M->VV9_CODCLI,M->VV9_LOJA,FG_AVALCRED(M->VV9_CODCLI,M->VV9_LOJA),1,.T.)
						Help("  ",1,"LIMITECRED")
					EndIf
				EndIf
			EndIf
		Endif
	Endif
Endif

if !Empty(M->VV9_CODCLI)
	//Verifica se o cliente adiantou algum valor para a empresa
	ADIANT011()
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ITECAM    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Trata os itens da campanha promocional                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ITECAM(cPar)
Local it_ := 0  
Local nValOrig := 0

If FunName() != "VEIVM011"
	Return .t.
Endif
If lPriVezVz7
	Excluir   := .f.
	FS_LevVZ7() // Levanta Campanha
Endif

//se mao achar o campo no aheader da return
if ((FG_POSVAR('VZ7_AGRVLR',"aHeaderIC") <= 0) .or. (FG_POSVAR('VZ7_OBRIGA',"aHeaderIC") <= 0);
	.or. (FG_POSVAR('VZ7_VALITE',"aHeaderIC") <= 0) .or. (FG_POSVAR("VZ7_ITECAM","aHeaderIC") <= 0)) 
	Return .t.
EndIf
// Iniciar o valor do M->VZ7_VALITE quando so foi alterado o campo VZ7_AGRVLR
If ReadVar() == "M->VZ7_AGRVLR"
	M->VZ7_VALITE := aCols[n,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]
	aCols[n,FG_POSVAR('VZ7_AGRVLR',"aHeaderIC")] := M->VZ7_AGRVLR
Endif

// Iniciar o valor do M->VZ7_AGRVLR quando so foi alterado o campo VZ7_VALITE
If ReadVar() == "M->VZ7_VALITE"
	aCols[n,FG_POSVAR('VZ7_VALITE',"aHeaderIC")] := M->VZ7_VALITE
	M->VZ7_AGRVLR := aCols[n,FG_POSVAR('VZ7_AGRVLR',"aHeaderIC")]
Endif

// No momento que esta funcao e' chamada, ainda nao houve o tratamento do ultimo campo do aCols referente a delecao //
If cPar == "D" // Deletar
	If aCols[n,len(aCols[n])]
		aCols[n,len(aCols[n])] := .f.
	Else
		aCols[n,len(aCols[n])] := .t.
	EndIf	
	If aCols[n,len(aCols[n])]
	   If aCols[n,FG_POSVAR('VZ7_OBRIGA',"aHeaderIC")] <> "0" // Nao pode deletar Agragado/Campanha qdo definido como Obrigatorio 
			Return .f.
		Endif
	Else // !aCols[n,len(aCols[n])]
		For it_ := 1 to len(aCols)
			If !aCols[it_,len(aCols[it_])]
				If aCols[it_,FG_POSVAR("VZ7_ITECAM")] == aCols[n,FG_POSVAR("VZ7_ITECAM")] .and. it_ <> n
					MsgStop(STR0313,STR0012) // Item já digitado !
					aCols[n,len(aCols[n])] := .t.
					Return .f.
				EndIf
			EndIf
		Next
	EndIf
ElseIf cPar == "A" // Alterar/Inserir
	If ReadVar() == "M->VZ7_ITECAM"
		For it_:=1 to len(aCols)
			If !aCols[it_,len(aCols[it_])] .and. it_ <> n 
				If aCols[it_,FG_POSVAR("VZ7_ITECAM","aHeaderIC")] == M->VZ7_ITECAM
					MsgStop("Item ja digitado!",STR0012)
					Return .f.
				EndIf
			EndIf
		Next
	EndIf
EndIf
M->VV0_VALTOT := M->VV0_VALMOV + Round(nAcresFin,2)
M->VVA_DESCLI := 0
M->VVA_REDVDA := 0
M->VVA_AGREGA := 0
For it_ := 1 to Len(aCols)
	If !aCols[it_,len(aCols[it_])]
		If it_ == n .and. cPar <> "L"
			If M->VZ7_AGRVLR == "0" // Agrega valor ao Total da NF
				M->VV0_VALTOT += M->VZ7_VALITE
			Elseif M->VZ7_AGRVLR == "1" // Agrega valor a Despesa com Clientes
				M->VVA_DESCLI += M->VZ7_VALITE
			Elseif M->VZ7_AGRVLR == "2" // Agrega valor ao Redutor
				M->VVA_REDVDA += M->VZ7_VALITE
			Elseif M->VZ7_AGRVLR == "3" // Agrega valor a Venda Agregada
				M->VVA_AGREGA += M->VZ7_VALITE
			EndIf
		Else
			If aCols[it_,FG_POSVAR('VZ7_AGRVLR',"aHeaderIC")] == "0" // Agrega valor ao Total da NF
				M->VV0_VALTOT += aCols[it_,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]
			Elseif aCols[it_,FG_POSVAR('VZ7_AGRVLR',"aHeaderIC")] == "1" // Agrega valor a Despesa com Clientes
				M->VVA_DESCLI += aCols[it_,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]
			Elseif aCols[it_,FG_POSVAR('VZ7_AGRVLR',"aHeaderIC")] == "2" // Agrega valor ao Redutor
				M->VVA_REDVDA += aCols[it_,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]
			Elseif aCols[it_,FG_POSVAR('VZ7_AGRVLR',"aHeaderIC")] == "3" // Agrega valor a Venda Agregada
				M->VVA_AGREGA += aCols[it_,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]
			EndIf
		EndIf
	Endif
Next
If cPar == "D" // Volta para deletar/desdeletar corretamente //
	If aCols[n,len(aCols[n])]
		aCols[n,len(aCols[n])] := .f.
	Else
		aCols[n,len(aCols[n])] := .t.
	EndIf	
EndIf
If cPar != "L" // Chamado na Func FISCAL011. Apenas para levantar valor do M->VV0_VALTOT
	nValOrig      := M->VV0_VALRES
	M->VV0_VALRES := (M->VV0_VALTOT) - M->VV0_TOTENT - M->VV0_VALFIN - M->VV0_VALDES
	If nValOrig != M->VV0_VALRES .and. !lPriVezVz7
		aTabFai := FS_CondPgFI(M->VV0_VALRES+M->VV0_VALFIN)
		If Len(aTabFai) > 0
			FS_AtuDADFI()
		Endif
	Endif
	lPriVezVZ7 := .f.
Endif
	
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_DERE011  ³ Autor ³ Andre Luis Almeida ³ Data ³ 28/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada do VEIVM040 (DESPESAS/RECEITAS do Veiculo)         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DERE011(nOpc)
Local nNSlv     := n
Local aColsSlv  := aClone(aCols)
Local aHeadSlv  := aClone(aHeader) 
Local nOpcVM040 := 2 // Visualizar
If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
	nOpcVM040 := 4 // Alterar
EndIf
DbSelectArea("VV1")
VM040("VV1",VV1->(RECNO()),nOpcVM040) // VEIVM040 - DESPESAS/RECEITAS do Veiculo
n       := nNSlv
aCols   := aClone(aColsSlv)
aHeader := aClone(aHeadSlv)
M->VVA_DESVEI := 0
M->VVA_RECVEI := 0
dbSelectArea("VVD")
dbSetOrder(1)
if dbSeek(xFilial("VVD")+VV1->VV1_TRACPA+VV1->VV1_CHAINT)
	while !eof() .and. VVD->VVD_TRACPA == VV1->VV1_TRACPA .and. VVD->VVD_CHAINT == VV1->VV1_CHAINT
		If VVD->VVD_TIPOPE == "0" // Despesa
			M->VVA_DESVEI += VVD->VVD_VALOR
		ElseIf VVD->VVD_TIPOPE == "1" // Receita
			M->VVA_RECVEI += VVD->VVD_VALOR
		Endif
		dbSelectArea("VVD")
		dbSkip()
	Enddo
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_MFORTE    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao dos valores da moeda forte                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_MFORTE(cOpcao)

Local nQtdVei  := 0
Local cLocVV0  := iif(cOpcao<>"M","VV0",cOpcao)
Local cLocVVA  := iif(cOpcao<>"M","VVA",cOpcao)

Default cOpcao := "M"

dbSelectArea("SD1")
dbSetOrder(1)
dbSeek(xFilial("SD1")+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA)
While !SD1->(Eof()) .And. xFilial('SD1')+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
	nQtdVei++
	dbSkip()
EndDo

dbSelectArea("VVA")
dbSetOrder(1)
dbSeek(xFilial("VVA")+M->VV0_NUMTRA)

if cOpcao <> "M"
	RecLock("VVA",.f.)
Endif
&(cLocVVA+"->VVA_VMFMOV") := FG_CalcMF(  {{M->VV0_DATMOV,M->VV0_VALMOV}} )
&(cLocVVA+"->VVA_CMFVDE") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_COMVDE}} )
&(cLocVVA+"->VVA_CMFGER") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_COMGER}} )
&(cLocVVA+"->VVA_VMFVEI") := if(!Empty(VVG->VVG_CODIND),FG_CalcMF({ { M->VV0_DATMOV,M->VVA_VCAVEI} }),FG_CalcMF(FG_RetVdCp(VVF->VVF_NUMNFI,VVF->VVF_SERNFI,"E"))/nQtdVei)
&(cLocVVA+"->VVA_SMFVIA") := FG_CalcMF({ {FG_RtDtCV("SGV",VV1->VV1_CODMAR,M->VV0_DATMOV),M->VVA_SEGVIA} })
&(cLocVVA+"->VVA_VMFASS") := FG_CalcMF({ {FG_RtDtCV("ASS",VV1->VV1_CODMAR,M->VV0_DATMOV),M->VVA_VALASS} })
&(cLocVVA+"->VVA_RMFTEC") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_RECTEC}} )
&(cLocVVA+"->VVA_BMFFAB") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_BONFAB}} )
If VVA->(FieldPos("VVA_BMFREG"))>0 .and. VVA->(FieldPos("VVA_BONREG"))>0
	&(cLocVVA+"->VVA_BMFREG") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_BONREG}} )
EndIf
If VVA->(FieldPos("VVA_BMFCON"))>0 .and. VVA->(FieldPos("VVA_BONCON"))>0
	&(cLocVVA+"->VVA_BMFCON") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_BONCON}} )
EndIf
&(cLocVVA+"->VVA_RMFVEI") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_RECVEI}} )
&(cLocVVA+"->VVA_IMFVEN") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_ICMVEN}} )
&(cLocVVA+"->VVA_PMFVEN") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_PISVEN}} )
&(cLocVVA+"->VVA_CMFVEN") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_COFVEN}} )
&(cLocVVA+"->VVA_IMFRTE") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_ISSRTE}} )
&(cLocVVA+"->VVA_PMFRTE") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_PISRTE}} )
&(cLocVVA+"->VVA_PMFBFB") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_PISBFB}} )
&(cLocVVA+"->VVA_IMFBFB") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_ISSBFB}} )
&(cLocVVA+"->VVA_VMFVEI") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_VCAVEI}} )
&(cLocVVA+"->VVA_RMFCUS") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_REDCUS}} )
&(cLocVVA+"->VVA_VMFFRE") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_VALFRE}} )
&(cLocVVA+"->VVA_AMFSSO") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_ACESSO}} )
&(cLocVVA+"->VVA_DMFVEI") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_DESVEI}} )
&(cLocVVA+"->VVA_DMFCLI") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_DESCLI}} )
&(cLocVVA+"->VVA_VMFREV") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_VALREV}} )
&(cLocVVA+"->VVA_JMFEST") := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_JUREST}} )

if cOpcao <> "M"
	MsUnlock()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ IMPOSTO011   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a base para calculos e impostos                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IMPOSTO011()

Local nValor

nValor := M->VV0_VALTOT

Return(nValor)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ENCERRA011   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Encerra o atendimento declarando o motivo                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ENCERRA011(nOpcao)
Local lOk := .f.
Local cGCCVCEV  := ""
Local cNatureza := M->VV0_NATFIN
Local cont2
Local aMemos    := {{"VV9_OBSMEM","VV9_OBSERV"}}
Private lMsErroAuto := .f.
Private lMsHelpAuto := .f.

Default nOpcao := 1

if nOpcao == 1
	if lJaGravou
		Return .t.
	Endif
Endif

if !Empty(M->VV9_NOMVIS) .or. !Empty(M->VV9_CODCLI+M->VV9_LOJA)
	
	if !MsgYesNo(STR0165,STR0012) //Cancela a venda? ### Atencao
		Return .f.
	Endif
	
	if ExistBlock("VLDEXC011")
		if !ExecBlock("VLDEXC011",.f.,.f.)
			Return .f.
		Endif
	Endif
	
	While !lOk
		lOk := PERGUNTE("OFI151")
	EndDo
	
	Begin Transaction
	
	M->VV9_MOTIVO := MV_PAR01
	DbSelectArea("VS0")
	DbSetOrder(1)
	DbSeek( xFilial("VS0") + cMotivo + MV_PAR01 )
	M->VV9_OBSERV += " "+ STR0166 +": "+VS0->VS0_DESMOT 	//Motivo
	
	if Inclui .and. !lJaGravou
		FS_GRVATE1(5)
	Endif
	
	dbSelectArea("VV9")
	RecLock("VV9",.f.)
	VV9->VV9_STATUS := "C"
	VV9->VV9_DATCAN := dDataBase
	VV9->VV9_MOTIVO := MV_PAR01
	MSMM(,TamSx3("VV9_OBSERV")[1],,&(aMemos[1][2]),1,,,"VV9","VV9_OBSMEM")
	MsUnlock()
	
	if !Empty(VV0->VV0_NUMNFI)
		if MsgYesNo(STR0167 ,STR0012) //Cancela NF? ### Atencao
			if (lMsErroAuto := FS_CANCNFS())
				DisarmTransaction()
				Break
			Endif
			if (lMsErroAuto := FS_CANCPED())
				DisarmTransaction()
				Break
			Endif
			if ExistBlock("EXCATE011")
				ExecBlock("EXCATE011",.f.,.f.)
			Endif
		Else
			MsgInfo(STR0168,STR0012) //Sera necessario cancelar a NF primeiro...
			Return .f.
		Endif
	Endif
/*	
//  thiago (UNIDAS)
	dbSelectarea("VV0")
	dbSetOrder(1)
	if dbSeek(xFilial("VV0")+M->VV9_NUMATE)
		RecLock("VV0",.f.)
		VV0->VV0_SITNFI := "0" // Cancelada 
		VV0->VV0_NUMNFI := ""
		VV0->VV0_SERNFI := ""
		VV0->VV0_NUMPED := ""
		MsUnlock()
	Endif
/////
*/
	If !Empty(VV9->VV9_CODCLI+VV9->VV9_LOJA)
		// CEV - Agenda Contato quando Cancela Atendimento - Andre Luis Almeida - 27/02/2008 //
		cGCCVCEV := Alltrim(GetNewPar("MV_GCCVCEV",""))
		If !Empty( cGCCVCEV )
			FS_AGENDA( Left(cGCCVCEV,1) ,;
			( dDataBase+Val(Substr(cGCCVCEV,2,3)) ) ,;
			If(!Empty(VS0->VS0_USURES),VS0->VS0_USURES,Substr(cGCCVCEV,5,6)) ,;
			VV9->VV9_CODCLI ,;
			VV9->VV9_LOJA ,;
			"" ,;
			VV9->VV9_NUMATE ,;
			"" ,;
			STR0171 + " "+VV9->VV9_NUMATE+" "+ STR0172 +" "+Alltrim(VS0->VS0_DESMOT)+If(lFiltro," "+ STR0170 +" "+cFilVV1+" "+ "Tipo:" +" "+cTipVei+" "+ STR0169 +" "+cCodMar+" "+cGruMod+" "+cModVei," "+ STR0169 +" "+VV1->VV1_CHASSI+" - "+VV1->VV1_CODMAR+" "+VV2->VV2_DESMOD) ,;
			"" ,;
			""  )//Atendimento CANCELADO ### Motivo: ### Loja: ### Tipo ### Veiculo: ### Veiculo: ###
		EndIf
		// Cancela a Data de Entrega do Veiculo
		FS_CALCDTENT("2",VV9->VV9_NUMATE,.f.)
		// Gravar VAZ (Avaliacao de Veiculo Usado) no Cancelamento do Atendimento
		DbSelectArea("VAZ")
		DbSetOrder(4)
		If DbSeek( xFilial("VAZ") + VV9->VV9_NUMATE )
			While !Eof() .and. xFilial("VAZ") == VAZ->VAZ_FILIAL .and. VV9->VV9_NUMATE == VAZ->VAZ_NUMATE
				RecLock("VAZ",.f.)
					//alterado para gravar 1 pois ao cancelar atendimento a avaliacao pode ser usada em outro atendimento -Rafae 12/02/10-
					VAZ->VAZ_APROVA := "1" // Avaliacao com Veiculo Negociado
					VAZ->VAZ_NUMATE := ""
				MsUnlock()
				DbSkip()
			End
		EndIf
	EndIf
	
	//Se houver titulos baixados gera titulo de pagamento no CP para o cliente no valor total.
	nTotalTit := 0
	dbSelectArea("VS9")
	dbSetOrder(1)
	If dbSeek(xFilial("VS9")+left(VV9->VV9_NUMATE+space(30),len(VS9->VS9_NUMIDE)))
		cNumTit := iif(Empty(VV0->VV0_NUMNFI),Right(M->VV9_NUMATE,nTamNota),VV0->VV0_NUMNFI)
		if Empty(cPrefNF)
			cPrefNF := VV0->VV0_SERNFI
		Endif
		
		While !Eof() .and. xFilial("VS9") == VS9->VS9_FILIAL .and. left(VV9->VV9_NUMATE+space(30),len(VS9->VS9_NUMIDE)) == VS9->VS9_NUMIDE
			If Empty(VS9->VS9_DATBAI)
				//Deleta os titulos em aberto
				dbSelectArea("SE1")
				dbSetOrder(1)
				
				if Empty(VV0->VV0_NUMNFI)
					cPrefNF   := SM0->M0_CODFIL+"E"
					if alltrim(VS9->VS9_TIPPAG) = "DP"
						cPrefNF   := SM0->M0_CODFIL+"F"
					Endif
				Endif
				
				if TamSx3("E1_PARCELA")[1] == 1
					cParcela := ConvPN2PC(val(VS9->VS9_SEQUEN))
				Else
					//		   	   cParcela := Soma1( ALLTRIM(str(val(VS9->VS9_SEQUEN)-1)) )
					cParcela := Soma1( strzero(val(VS9->VS9_SEQUEN)-1,TamSx3("E1_PARCELA")[1]) )
				Endif
				
				if dbSeek(xFilial("SE1")+cPrefNF+cNumTit+cParcela+VS9->VS9_TIPPAG)
					aParcelas := {}
					AADD(aParcelas,{{"E1_PREFIXO" ,E1_PREFIXO ,nil},;
					{"E1_NUM"     ,E1_NUM     ,nil},;
					{"E1_PARCELA" ,E1_PARCELA ,nil},;
					{"E1_TIPO"    ,E1_TIPO    ,nil},;
					{"E1_NATUREZ" ,E1_NATUREZ ,nil},;
					{"E1_CLIENTE" ,E1_CLIENTE ,nil},;
					{"E1_LOJA"    ,E1_LOJA    ,nil},;
					{"E1_EMISSAO" ,E1_EMISSAO ,nil},;
					{"E1_VENCTO"  ,E1_VENCTO  ,nil},;
					{"E1_VENCREA" ,E1_VENCREA ,nil},;
					{"E1_VALOR"   ,E1_VALOR   ,nil},;
					{"E1_NUMBOR"  ,E1_NUMBOR  ,Nil},;
					{"E1_DATABOR" ,E1_DATABOR ,Nil},;
					{"E1_PORTADO" ,E1_PORTADO ,Nil},;
					{"E1_SITUACA" ,E1_SITUACA ,Nil},;
					{"E1_ORIGEM" , "MATA460"  ,nil}}) 
		
					pergunte("FIN040",.F.)
					For cont2 = 1 to len(aParcelas)
						MSExecAuto({|x,y| FINA040(x,y)},aParcelas[cont2],5)
						if lMsErroAuto
							Return(.f.)
						Endif
					Next
				Endif
			Else
				nTotalTit += VS9->VS9_VALPAG
			Endif
			dbSelectArea("VS9")
			dbSkip()
		End
	Endif
	
	if (lMsErroAuto := FS_CANCTIT())
		DisarmTransaction()
		Break
	Endif
	
	dbSelectArea("SA1")
	if dbSeek(xFilial("SA1")+VV9->VV9_CODCLI+VV9->VV9_LOJA) .and. nTotalTit > 0
		
		if GetNewPar("MV_TITNCC","S") <> "S"
			dbSelectArea("SA2")
			dbSetOrder(3)
			If !dbSeek(xFilial("SA2")+SA1->A1_CGC)
				// Cria Fornecedor
				aCabFornecedor := {}
				aAdd(aCabFornecedor,{"A2_FILIAL"  ,xFilial("SA2")    ,Nil})
				aAdd(aCabFornecedor,{"A2_COD"     ,GetSxENum("SA2","A2_COD") ,Nil})
				aAdd(aCabFornecedor,{"A2_LOJA"    ,SA1->A1_LOJA      ,Nil})
				aAdd(aCabFornecedor,{"A2_NOME"    ,SA1->A1_NOME      ,Nil})
				aAdd(aCabFornecedor,{"A2_TIPO"    ,SA1->A1_PESSOA    ,Nil})
				aAdd(aCabFornecedor,{"A2_CGC"     ,SA1->A1_CGC       ,Nil})
				aAdd(aCabFornecedor,{"A2_NREDUZ"  ,SA1->A1_NREDUZ    ,Nil})
				aAdd(aCabFornecedor,{"A2_END"     ,SA1->A1_END       ,Nil})
				aAdd(aCabFornecedor,{"A2_BAIRRO"  ,SA1->A1_BAIRRO    ,Nil})
				aAdd(aCabFornecedor,{"A2_MUN"     ,SA1->A1_MUN       ,Nil})
				aAdd(aCabFornecedor,{"A2_EST"     ,SA1->A1_EST       ,Nil})
				aAdd(aCabFornecedor,{"A2_CEP"     ,SA1->A1_CEP       ,Nil})
				aAdd(aCabFornecedor,{"A2_DDD"     ,SA1->A1_DDD       ,Nil})
				aAdd(aCabFornecedor,{"A2_TEL"     ,SA1->A1_TEL       ,Nil})
				aAdd(aCabFornecedor,{"A2_FAX"     ,SA1->A1_FAX       ,Nil})
				aAdd(aCabFornecedor,{"A2_EMAIL"   ,SA1->A1_EMAIL     ,Nil})
				aAdd(aCabFornecedor,{"A2_ATIVIDA" ,SA1->A1_ATIVIDA   ,Nil})
				aAdd(aCabFornecedor,{"A2_NATUREZ" ,SA1->A1_NATUREZ   ,Nil})
				aAdd(aCabFornecedor,{"A2_SATIV1"  ,SA1->A1_SATIV1    ,Nil})
				aAdd(aCabFornecedor,{"A2_INSCR"   ,SA1->A1_INSCR     ,Nil})
				aAdd(aCabFornecedor,{"A2_ESTADO"  ,SA1->A1_ESTADO    ,Nil})
				aAdd(aCabFornecedor,{"A2_DDI"     ,SA1->A1_DDI       ,Nil})
				aAdd(aCabFornecedor,{"A2_PAIS"    ,SA1->A1_PAIS      ,Nil})
				aAdd(aCabFornecedor,{"A2_PFISICA" ,SA1->A1_PFISICA   ,Nil})
				aAdd(aCabFornecedor,{"A2_INSCRM"  ,SA1->A1_INSCRM    ,Nil})
				aAdd(aCabFornecedor,{"A2_CONTA"   ,SA1->A1_CONTA     ,Nil})
				aAdd(aCabFornecedor,{"A2_HPAGE"   ,SA1->A1_HPAGE     ,Nil})
				If SA1->(FieldPos("A1_IBGE"))>0 .and. SA2->(FieldPos("A2_IBGE"))>0
					aAdd(aCabFornecedor,{"A2_IBGE" ,SA1->A1_IBGE      ,Nil})
				EndIf
				
				ConfirmSx8()
				
				if ExistBlock("CADFOR011")
					ExecBlock("CADFOR011",.f.,.f.,{@aCabFornecedor})
				Endif
				
				dbSelectArea("SA2")
				dbSetOrder(1)
				
				lMsErroAuto := .f.
				lMsHelpAuto := .t.
				
				MSExecAuto({|x,y| MATA020(x)},aCabFornecedor)
				
				If lMsErroAuto
					DisarmTransaction()
					Break
				EndIf
			Endif
			
			cPrefNF := SM0->M0_CODFIL
			cCodBco := M->VV0_CODBCO
			cNumBord:= ""
			dDatBord:= cTod("")
			FG_Seek("SA6","cCodBco",1,.f.)
			if SA6->A6_BORD == "0"
				cNumBord := "BCO"+SA6->A6_COD
				dDatBord := dDataBase
			Endif
			
			cCodCli   := SA2->A2_COD
			cLojCli   := SA2->A2_LOJA
			
			if Empty(cNatureza)
				cNatureza := SA2->A2_NATUREZ
			Endif
			
			dbSelectArea("SE2")
			dbSetOrder(1)
			
			aVetDesp  := {}
			aAdd(aVetDesp,{"E2_PREFIXO"  ,cPrefNF     ,Nil})
			aAdd(aVetDesp,{"E2_NUM"      ,cNumTit     ,Nil})
			aAdd(aVetDesp,{"E2_TIPO"     ,"NCF"       ,Nil})
			aAdd(aVetDesp,{"E2_NATUREZ"  ,cNatureza   ,Nil})
			aAdd(aVetDesp,{"E2_PARCELA"  ,"1"         ,Nil})
			aAdd(aVetDesp,{"E2_FORNECE"  ,SA2->A2_COD ,Nil})
			aAdd(aVetDesp,{"E2_LOJA"     ,SA2->A2_LOJA,Nil})
			aAdd(aVetDesp,{"E2_NOMFOR "  ,SA2->A2_NREDUZ,Nil})
			aAdd(aVetDesp,{"E2_EMISSAO"  ,dDataBase   ,Nil})
			aAdd(aVetDesp,{"E2_VENCTO"   ,dDataBase   ,Nil})
			aAdd(aVetDesp,{"E2_VALOR"    ,nTotalTit   ,Nil})
			aAdd(aVetDesp,{"E2_VLCRUZ"   ,nTotalTit   ,Nil})
			aAdd(aVetDesp,{"E2_NUMBOR"   ,cNumBord    ,Nil})
			aAdd(aVetDesp,{"E2_PORTADO"  ,cCodBco     ,Nil})
			aAdd(aVetDesp,{"E2_PREFORI"  ,cPrefixo    ,Nil})
			pergunte("FIN050",.F.)
			lMsHelpAuto := .t.
			lMsErroAuto := .f.
			
			MsExecAuto({|x,y,z| FINA050(x,y,z)},aVetDesp)
			if lMsErroAuto
				DisarmTransaction()
				Break
			Endif
		Else
			
			cPrefNF := SM0->M0_CODFIL
			cCodBco := M->VV0_CODBCO
			cNumBord:= ""
			dDatBord:= cTod("")
			FG_Seek("SA6","cCodBco",1,.f.)
			if SA6->A6_BORD == "0"
				cNumBord := "BCO"+SA6->A6_COD
				dDatBord := dDataBase
			Endif
			
			cCodCli   := SA1->A1_COD
			cLojCli   := SA1->A1_LOJA
			
			if Empty(cNatureza)
				cNatureza := SA1->A1_NATUREZ
			Endif
			
			dbSelectArea("SE1")
			dbSetOrder(1)
			
			aVetDesp  := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Otavio - 24/06/2009 - FNC 00000015252                        ³
//³ Somente alimenta com natureza caso a mesma esteja preenchida ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			aAdd(aVetDesp,{"E1_PREFIXO"  ,cPrefNF     ,Nil})
			aAdd(aVetDesp,{"E1_NUM"      ,cNumTit     ,Nil})
			aAdd(aVetDesp,{"E1_TIPO"     ,"NCC"       ,Nil})
			If !Empty(cNatureza)
				aAdd(aVetDesp,{"E1_NATUREZ"  ,cNatureza   ,Nil})
			EndIf
			aAdd(aVetDesp,{"E1_SITUACA" , "0"			,nil})
			aAdd(aVetDesp,{"E1_PARCELA"  ,"1"         ,Nil})
			aAdd(aVetDesp,{"E1_CLIENTE"  ,SA1->A1_COD ,Nil})
			aAdd(aVetDesp,{"E1_LOJA"     ,SA1->A1_LOJA,Nil})
			aAdd(aVetDesp,{"E1_NOMFOR "  ,cNatureza   ,Nil})
			aAdd(aVetDesp,{"E1_EMISSAO"  ,dDataBase   ,Nil})
			aAdd(aVetDesp,{"E1_VENCTO"   ,dDataBase   ,Nil})
			aAdd(aVetDesp,{"E1_VALOR"    ,nTotalTit   ,Nil})
			aAdd(aVetDesp,{"E1_VLCRUZ"   ,nTotalTit   ,Nil})
//			aAdd(aVetDesp,{"E1_NUMBOR"   ,cNumBord    ,Nil})
//			aAdd(aVetDesp,{"E1_PORTADO"  ,cCodBco     ,Nil})
			aAdd(aVetDesp,{"E1_PREFORI"  ,cPrefixo    ,Nil})
			aAdd(aVetDesp,{"E1_ORIGEM" , "MATA460"    ,nil})
			
			lMsHelpAuto := .t.
			lMsErroAuto := .f.
			
			pergunte("FIN040",.F.)
			
			_nRecSA1 := SA1->(Recno())//salva posicao SA1

			MsExecAuto({|x,y,z| FINA040(x,y,z)},aVetDesp)
			
			SA1->(Dbgoto(_nRecSA1))	//volta posicao SA1

			if lMsErroAuto
				DisarmTransaction()
				Break
			Endif
			
		Endif
	Endif
	
	dbSelectArea("VV1")
	dbSetOrder(2)
	if dbSeek(xFilial("VV1")+M->VV0_CHASSI)
		RecLock("VV1",.f.)
// Manoel - 01/03/2010 - ficou desnecessario com a utilizacao da FGX_AMOVVEI		
/*
		VV1->VV1_SITVEI := "0"
		if !Empty(VV1->VV1_STATUS)
			VVG->(dbSetOrder(2))
			if !VVG->(dbSeek(xFilial("VVG")+VV1->VV1_CHAINT))
				VV1->VV1_SITVEI := " "
			Endif
		Endif
*/
		VV1->VV1_RESERV := ""
		VV1->VV1_DTHRES := ""
		VV1->VV1_DTHVAL := ""
		MsUnlock()
	Endif

	dbSelectarea("VV0")
	dbSetOrder(1)
	if dbSeek(xFilial("VV0")+M->VV9_NUMATE)
		RecLock("VV0",.f.)
		VV0->VV0_SITNFI := "0" // Cancelada 
		VV0->VV0_NUMNFI := ""
		VV0->VV0_SERNFI := ""
		VV0->VV0_NUMPED := ""
		MsUnlock()
	Endif
	If !Inclui .or. Empty(M->VV9_MOTIVO)
		VV0->(dbGoTo(VV0->(Recno())))
		FGX_AMOVVEI(xFilial("VV1"),VV1->VV1_CHASSI)
	EndIf


	If TCCanOpen(RetSqlName("VJ1")) .and. FieldPos("VJ1_NUMTRA") > 0
		cQryAlias := GetNextAlias()
		cQuery := "SELECT R_E_C_N_O_ NRECNO FROM "+RetSqlName("VJ1")+" WHERE VJ1_FILIAL ='"+xFilial("VJ1")+"' AND D_E_L_E_T_=' ' AND VJ1_NUMTRA = '"+VV0->VV0_NUMTRA+"'"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. ) 
		//
		(cQryAlias)->(dbGoTop())
		if !(cQryAlias)->(eof())
			VJ1->(DBGoto((cQryAlias)->(NRECNO)))
			reclock("VJ1",.f.)
			VJ1->VJ1_NUMTRA := ""
			msunlock()
		endif
		(cQryAlias)->(dbCloseArea())
	endif
	
	
	If M->VV0_OPEMOV == "8" // Venda com Entrega Futura
		VV2->(DbSetOrder(1))
		If VV2->(FieldPos("VV2_QTDATU")) <> 0
			If VV2->(DbSeek(xFilial("VV2")+VV9->VV9_CODMAR+VV9->VV9_MODVEI))
				RecLock("VV2",.f.)
				VV2->VV2_QTDATU += 1
			EndIf
		EndIf
	Endif
	
	End Transaction

	if M->VV0_TIPFAT == "3" .and. VV2->(FieldPos("VV2_QTDATU")) <> 0 // Venda Futura
		VV2->(dbSetOrder(1))
		If VV2->(dbSeek(xFilial("VV2")+M->VV0_CODMAR+M->VV0_MODVEI))
			RecLock("VV2",.f.)
				VV2->VV2_QTDATU += 1
			MsUnLock()
			If VV0->(FieldPos("VV0_BXAFUT")) <> 0 // Veiculo Baixado na Venda Futura
				RecLock("VV0",.f.)
					VV0->VV0_BXAFUT := "0" // 1-Sim / 0-Nao
				MsUnlock()
	        EndIf
		EndIf
	EndIf
	
	if lMsErroAuto
		MostraErro()
	Else
		If VV9->VV9_STATUS == "C"
			If FindFunction("VEIVM130TAR")
				VEIVM130TAR(VV9->VV9_NUMATE,"9") // 0-Verifica/Valida / 1-Gravacao / 2-Finalizacao / 3-Pelo Usuario / 4-Pendente Aprovacao / 5-Pre-Aprovado / 6-Aprovado / 7-Reserva / 8-Cancela Reserva / 9-Cancela Atendimento
			EndIf
		EndIf
	Endif
	
	//Ponto de Entrada - OS
	If ExistBlock("ENCATE011")
		ExecBlock("ENCATE011",.f.,.f.)
	Endif
Else
	RollBackSx8()
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FILVEI011    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra a consulta de veiculos na tela de selecao           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FILVEI011()

Local lOk  := .t.
Local nLin := 12
Local aCombus  := {OemToAnsi(""),OemToAnsi("0-"+STR0173),OemToAnsi("1-"+STR0174),OemToAnsi("2-"+STR0175),OemToAnsi("3-"+STR0176),OemToAnsi("9-"+STR0177)} //Gasolina ### Alcool ### Diesel ### Gas Natural ### Sem Combustivel
Local aTipCor  := {OemToAnsi(""),OemToAnsi("0-"+STR0178),OemToAnsi("1-"+STR0179),OemToAnsi("2-"+STR0180)} //Solida ### Metalica ### Perolizada
Local aEstVeiF := {OemToAnsi(""),OemToAnsi("0-"+STR0181),OemToAnsi("1-"+STR0182)} //Novo ### Usado

If VAI->(FieldPos("VAI_ESTVEI")) <> 0
	dbSelectArea("VAI")
	dbSetOrder(4)
	dbSeek(xFilial("VAI")+__cUserID)
	If !Empty(VAI->VAI_ESTVEI)
		If VAI->VAI_ESTVEI == "0" // Novos
			aEstVeiF := {OemToAnsi(""),OemToAnsi("0-"+STR0181)} //Novo
		ElseIf VAI->VAI_ESTVEI == "1" // Usados
			aEstVeiF := {OemToAnsi(""),OemToAnsi("1-"+STR0182)} //Usado
		EndIf
	EndIf
EndIf

DEFINE MSDIALOG oDlgNew TITLE OemtoAnsi(STR0183) FROM  02,04 TO 12,86 OF oMainWnd   //Criterios de selecao

//Ano Inicial
@ nLin,004 SAY  OemToAnsi(STR0184)  OF oDlgNew PIXEL COLOR CLR_BLUE  //Ano Inicial
@ nLin+10,004 MSGET oAnoIni VAR nAnoIni PICTURE "9999" SIZE 28,4  OF oDlgNew PIXEL COLOR CLR_BLACK
//Ano Final
@ nLin,034 SAY OemToAnsi(STR0185) OF oDlgNew PIXEL COLOR CLR_BLUE     //Ano Final
@ nLin+10,034 MSGET oAnoFin VAR nAnoFIn PICTURE "9999" SIZE 28,4  OF oDlgNew PIXEL COLOR CLR_BLACK

//Combustivel
@ nLin,70 SAY  OemToAnsi(STR0186)  OF oDlgNew PIXEL COLOR CLR_BLUE   //Combustivel
@ nLin+10,70 MSCOMBOBOX oCombus VAR cCombus SIZE 65,50 COLOR CLR_BLACK ITEMS aCombus OF oDlgNew PIXEL

//Faixa de Preco 1
@ nLin,140 SAY  OemToAnsi(STR0187)  OF oDlgNew PIXEL COLOR CLR_BLUE //Faixa de Valor
@ nLin+10,140 MSGET oValFxI VAR nValFxI PICTURE "@E 9,999,999.99" SIZE 55,4  OF oDlgNew PIXEL  COLOR CLR_BLACK

//Faixa de Preco 2
@ nLin,200 SAY OemToAnsi(STR0187) OF oDlgNew PIXEL COLOR CLR_BLUE  //Faixa de Valor
@ nLin+10,200 MSGET oValFxF VAR nValFxF PICTURE "@E 9,999,999.99" SIZE 55,4  OF oDlgNew PIXEL COLOR CLR_BLACK

//Kilometragem
@ nLin,260 SAY OemToAnsi(STR0188) OF oDlgNew PIXEL COLOR CLR_BLUE   //Kilometragem Maxima
@ nLin+10,260 MSGET oKMFxa VAR nKMFxa PICTURE VV1->(X3PICTURE("VV1_KILVEI")) SIZE 55,4  OF oDlgNew PIXEL COLOR CLR_BLACK

nLin+=23

//Tipo de Cor
@ nLin,002 SAY  OemToAnsi(STR0189)  OF oDlgNew PIXEL COLOR CLR_BLUE   //Tipo de Cor
@ nLin+10,002 MSCOMBOBOX oTipCor VAR cTipCor SIZE 50,50 COLOR CLR_BLACK ITEMS aTipCor OF oDlgNew PIXEL

//Cor
@ nLin,060 SAY  OemToAnsi(STR0022)  OF oDlgNew PIXEL COLOR CLR_BLUE //COR
@ nLin+10,060 MSGET oGruCor VAR cGruCor PICTURE "@!" F3 "VVQ"  SIZE 25,4  OF oDlgNew PIXEL COLOR CLR_BLACK

//Cor Especifica
@ nLin,093 SAY  OemToAnsi(STR0190)  OF oDlgNew PIXEL COLOR CLR_BLUE   //Cor Especifica
@ nLin+10,093 MSGET oCorF VAR cCOR PICTURE "@!" F3 "COR" SIZE 40,4  OF oDlgNew PIXEL  COLOR CLR_BLACK

//Opcionais
@ nLin,140 SAY  OemToAnsi(STR0059)  OF oDlgNew PIXEL COLOR CLR_BLUE   // Opcionais
@ nLin+10,140 MSGET oOpcVei VAR cOpcVei PICTURE VV1->(X3PICTURE("VV1_OPCFAB")) SIZE 112,4  OF oDlgNew PIXEL  COLOR CLR_BLACK

//Estado do veiculo
@ nLin,260 SAY  OemToAnsi(STR0024)  OF oDlgNew PIXEL COLOR CLR_BLUE //estado
@ nLin+10,260 MSCOMBOBOX oEstVeiF VAR cEstVeiF SIZE 50,50 COLOR CLR_BLACK ITEMS aEstVeiF OF oDlgNew PIXEL

nLin+=25

@ nLin,002 BUTTON oLimpa PROMPT OemToAnsi(STR0191) OF oDlgNew SIZE 43,10 PIXEL ACTION (nAnoIni:=nAnoFin:=nValFxI:=nValFxF:=nKMFxa:=0,cCombus:="",cTipCor:="",cGruCor:=space(2),cCOR:=space(6),cOpcVei:=space(100),cEstVeiF:="")     //Limpa

ACTIVATE MSDIALOG oDlgNew CENTER ON INIT (FG_ENCHOICEBAR(oDlgNew,{|| lOk := .t.,oDlgNew:End()},{|| lOk := .f.,oDlgNew:End()}))

if lOk
	FS_FILTROVV()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GVNEG011  ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava todos os dados da negociacao                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GRVNEG011()

Local cont, cont1
Local nPosTipPag, nPosValPag

DELNEG011() //Exclui negociacao anterior

If Type("aHeader") != "U"
	If len(aHeader) > 0
		if substr(aHeader[1,2],1,3) == "VS9"
			aColsC   := aclone(aCols)
			aHeaderC := aclone(aHeader)
		Endif
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rubens - 19/11/2009                             ³
//³Verifica se houve alteracao nos tipos de entrada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !Inclui .and. lLogAlter
	nPosTipPag := FG_PosVar("VS9_TIPPAG","aHeaderC")
	nPosValPag := FG_PosVar("VS9_VALPAG","aHeaderC")
	// Verifica aVS9LogAlter x aColsC 
	For Cont := 1 to Len(aColsC)
		
		If Empty(aColsC[Cont,nPosTipPag]) .and. aColsC[Cont,nPosValPag] == 0
			Loop
		EndIf
	
		// Registro da aColsC referente a uma condicao ja gravada 
		If Cont <= Len(aVS9LogAlter)
			// Se tiver excluida a linha da aColsC 
			If aColsC[Cont,Len(aColsC[Cont])]
				aVS9LogAlter[Cont,5] := .t.
			Else
				// Verifica se houve alteração de valor 
				If aVS9LogAlter[Cont,2] == aColsC[Cont,nPosValPag]
					aVS9LogAlter[Cont,3] := .t. // Marca registro como excluido 
				ELSE 
					aVS9LogAlter[Cont,6] := aColsC[Cont,nPosValPag] // Valor Novo 
				EndIf
			EndIf
		Else
			IF !aColsC[Cont,Len(aColsC[Cont])]
				// Foi adicionado uma Forma de Entrada Nova 
				AADD( aVS9LogAlter , { aColsC[Cont,nPosTipPag] ,;
											0 ,;
											.f. ,;	// Indica que houve alteracao 
											.t. ,;	// Indica que é um registro novo 
											.f. ,;	// Indica que o registro foi excluido 
											aColsC[Cont,nPosValPag] } )	// Valor Novo
			EndIf
		EndIf
	Next Cont
EndIf

aMemos  := {{"VS9_OBSMEM","VS9_OBSERV"}}
nSequ := 1
For cont:=1 to len(aColsC)
	if Empty(aColsC[cont,1])
		Loop
	Endif
	dbSelectArea("VS9")
	dbSetOrder(1)
	if !aColsC[cont,len(aColsC[cont])]
		cObserv2 := aColsC[cont,FG_POSVAR('VS9_OBSERV',"aHeaderC")]
		RecLock("VS9",.T.)
		FG_GRAVAR("VS9",aColsC,aHeaderC,cont)
		VS9->VS9_FILIAL := xFilial("VS9")
		VS9->VS9_NUMIDE := VV9->VV9_NUMATE
		VS9->VS9_TIPOPE := "V"
		VS9->VS9_VALPAG := aColsC[cont,FG_POSVAR('VS9_VALPAG',"aHeaderC")]
		VS9->VS9_REFPAG := aColsC[cont,FG_POSVAR('VS9_REFPAG',"aHeaderC")]
		VS9->VS9_PORTAD := aColsC[cont,FG_POSVAR('VS9_PORTAD',"aHeaderC")]
		VS9->VS9_SEQUEN := aColsC[cont,FG_POSVAR('VS9_SEQUEN',"aHeaderC")]
		VS9->VS9_TIPTIT := iif(aColsC[cont,FG_POSVAR('VS9_TIPPAG',"aHeaderC")]=="PR","0","1")
		MSMM(,TamSx3("VS9_OBSERV")[1],,cObserv2,1,,,"VS9","VS9_OBSMEM")
		ConfirmSx8()
		MsUnlock()
	Endif
	
	For cont1:=1 to len(aGravaEnt)
		dbSelectArea("VSE")
		dbSetOrder(1)
		RecLock("VSE",.T.)
		VSE->VSE_FILIAL := xFilial("VSE")
		VSE->VSE_NUMIDE := VV9->VV9_NUMATE
		VSE->VSE_TIPOPE := 'V'
		VSE->VSE_SEQUEN := aColsC[cont,FG_POSVAR('VS9_SEQUEN',"aHeaderC")]
		VSE->VSE_TIPPAG := aGravaEnt[cont1,2]
		VSE->VSE_DESCCP := aGravaEnt[cont1,3]
		VSE->VSE_NOMECP := aGravaEnt[cont1,4]
		VSE->VSE_TIPOCP := aGravaEnt[cont1,5]
		VSE->VSE_TAMACP := aGravaEnt[cont1,6]
		VSE->VSE_DECICP := aGravaEnt[cont1,7]
		VSE->VSE_PICTCP := aGravaEnt[cont1,8]
		VSE->VSE_VALDIG := aGravaEnt[cont1,9]
		MsUnlock()
	Next
Next
M->VV0_VALFIN := 0
cSeq := aColsC[1,FG_POSVAR('VS9_TIPPAG',"aHeaderC")]
For cont:=1 to len(aColsC)
	if Empty(aColsC[cont,1])
		Loop
	Endif
	dbSelectArea("VS9")
	dbSetOrder(1)
	if dbSeek(xFilial("VS9")+left(VV9->VV9_NUMATE+space(30),len(VS9->VS9_NUMIDE))+"V"+aColsC[cont,FG_POSVAR("VS9_TIPPAG","aHeaderC")]+aColsC[cont,FG_POSVAR("VS9_SEQUEN","aHeaderC")])
		
		if !aColsC[cont,len(aColsC[cont])]
			dbSelectArea("VSA")
			dbSetOrder(1)
			if dbSeek(xFilial("VSA")+aColsC[cont,FG_POSVAR("VS9_TIPPAG","aHeaderC")]) .and. VSA->(FieldPos("VSA_FINANC")) > 0 .and. VSA->VSA_FINANC == "1"
				M->VV0_VALFIN += aColsC[cont,FG_POSVAR("VS9_VALPAG","aHeaderC")]
			EndIf
			
			cObserv2 := aColsC[cont,FG_POSVAR('VS9_OBSERV',"aHeaderC")]
			RecLock("VS9",.f.)
			if !inclui
				///////	         if aColsC[cont,FG_POSVAR('VS9_TIPPAG',"aHeaderC")] == cSeq
				VS9->VS9_SEQUEN := STRZERO(nSequ,2)
				nSequ += 1
				//////	         Endif
			Endif
		Endif
	Endif
	if cont+1 <= len(aColsC)
		if aColsC[cont,FG_POSVAR('VS9_TIPPAG',"aHeaderC")] <> aColsC[cont+1,FG_POSVAR('VS9_TIPPAG',"aHeaderC")]
			nSequ := 1
		Endif
	Endif
	
Next
aMemos  := {{"VVA_OBSMEM","VVA_OBSERV"}}

For cont:=1 to Len(aIteParc)
	if Empty(aIteParc[cont,1])
		Exit
	Endif
	RecLock("VS9", .T.)
	VS9->VS9_FILIAL := xFilial("VS9")
	VS9->VS9_NUMIDE := VV9->VV9_NUMATE
	VS9->VS9_TIPOPE := "V"
	VS9->VS9_TIPPAG := "DP"
//	VS9->VS9_DESPAG := "DUPLICATA"  // Campo VIRTUAL nao e' possivel colocar conteudo.
	VS9->VS9_DATPAG := DataValida(aIteParc[cont,1])
	VS9->VS9_VALPAG := aIteParc[cont,2]
	VS9->VS9_PORTAD := M->VV0_CODBCO
	VS9->VS9_SEQUEN := StrZero(cont,2)
	VS9->VS9_TIPTIT := "1"
	if !Empty(M->VV0_DATINI) .and. M->VV0_PARCEL > 0
		VS9->VS9_REFPAG := alltrim(dtoc(M->VV0_DATINI))+strzero(M->VV0_DIA1PC,2)+strzero(M->VV0_PARCEL,2)+strzero(M->VV0_PARCEL,2)
	Endif
	If VV0->(FieldPos("VV0_NATFIN")) <> 0 .and. VS9->(FieldPos("VS9_NATURE")) <> 0
		VS9->VS9_NATURE := M->VV0_NATFIN
	Endif
	If VV0->(FieldPos("VV0_CARTEI")) <> 0 .and. VS9->(FieldPos("VS9_CARTEI")) <> 0
		VS9->VS9_CARTEI := M->VV0_CARTEI
	Endif
	MsUnlock()
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DELNEG011    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclusao da negociacao                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DELNEG011()

dbSelectArea("VSE")
dbSeek(xfilial("VSE")+VV0->VV0_NUMTRA+'V')
While !Eof() .and. xFilial("VSE") == VSE->VSE_FILIAL .and. VSE->VSE_NUMIDE == VV0->VV0_NUMTRA .and. VSE->VSE_TIPOPE == "V"
	if RecLock("VSE",.f.,.t.)
		VSE->(dbDelete())
		MsUnlock()
	Endif
	dbSkip()
Enddo
WriteSx2("VSE")

dbSelectArea("VS9")
if dbSeek(xFilial("VS9")+left(VV0->VV0_NUMTRA+space(30),len(VS9->VS9_NUMIDE)))
	While (xFilial("VS9")+left(VV0->VV0_NUMTRA+space(30),len(VS9->VS9_NUMIDE)))== (VS9->VS9_FILIAL+VS9->VS9_NUMIDE) .and. !Eof()
		Reclock("VS9",.F.)
		Dbdelete()
		MsUnlock()
		dbSelectArea("VS9")
		dbSkip()
	End
Endif
WriteSx2("VS9")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_LIBATE    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Liberacao do atendimento                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_LIBATE()

Local lRet := .t.

if !Inclui .and. VV9->VV9_STATUS == "P"
	MsgStop(STR0192 ,STR0012) //Atendimento ainda nao aprovado! ### Atencao
	lRet := .f.
Endif

if !Inclui .and. VV9->VV9_STATUS == "O"
	MsgStop(STR0193 ,STR0012) //Faturamento ainda nao aprovado! ### Atencao
	lRet := .f.
Endif


/*
if M->VV9_STATUS == "A" .or. Inclui
//Registro do atendimento
lRet := lLibVei
if !lLibVei
M->VV9_STATUS := "P"
STATUS011("P",.f.)
Processa({|| FS_GRVATE1() })
lFechaDlg := .t.
Endif
Else
if M->VV9_STATUS <> "L" .and. !lLibVei
If ExistBlock("CKLBFT012")
lLibVei := ExecBlock("CKLBFT012",.f.,.f.)
Endif
if !lLibVei
lRet := .f.
MsgStop("Atendimento ainda nao aprovado !","Atencao...")
Endif
Else
lRet := .t.
Endif
Endif
*/

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ STATUS011    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modifica o status do atendimento dependendo da operacao    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function STATUS011(cOpcao, lConfirma)

Local nRegVAI
Local lOk := .t.
Private lMsErroAuto := .f.
Private lMsHelpAuto := .t.

Default lconfirma := .f.

if lConfirma
	if !MsgYesNo(STR0194 ,STR0012) //Confirma operacao? ### Atencao
		Return
	Endif
Endif
//ponto de entrada que valida a gravacao
if ExistBlock("VM011GVA")
	If !ExecBlock("VM011GVA",.f.,.f.)
		Return .f.
	Endif
Endif

//Registro do atendimento
M->VV9_STATUS := cOpcao

if cOpcao == "P"
	//Ponto de entrada para pedir liberacao
	If ExistBlock("PEDLIB011")
		ExecBlock("PEDLIB011",.f.,.f.)
	Endif
Endif

if cOpcao == "O" //PRE-APROVAR  

	If FS_VERAPROV(VV0->VV0_NUMTRA)  // Verifica se existe outro Atendimento ja pre-aprovado/aprovado para o mesmo Veiculo (CHASSI)
		lRet := .f.
		return .f.
	EndIf

	//Ponto de entrada para PRE-APROVAR
	If ExistBlock("PREAPR011")
		lOk := ExecBlock("PREAPR011",.f.,.f.)
	Endif

	If lOk	
		dbSelectArea("VAI")
		dbSetOrder(4)
		nRegVAI := Recno()
		if dbSeek(xFilial("VAI")+VV9->VV9_USUARI)
			Begin Transaction
			if (VV9->VV9_STATUS == "P") .and. FS_CLI011(.f.)
				lRet := .t.
				M->VV9_STATUS := "O"
				Processa({|| FS_GRVATE1() })
				dbSelectArea("VV1")
				dbSetOrder(2)
				if dbSeek(cFilSelVV1+M->VV0_CHASSI)
					RecLock("VV1",.f.)
					VV1->VV1_RESERV := "3"
					MsUnlock()
				Endif
				if GetNewPar("MV_TITAPR","S") == "S"
					lMsErroAuto := !FS_GERATIT()
				Endif
			Else
				lRet := .f.
			Endif
			if lMsErroAuto
				DisarmTransaction()
				Break
			Endif
			End Transaction
			if lMsErroAuto
				MostraErro()
			Else
				If VV9->VV9_STATUS == "O"
					If FindFunction("VEIVM130TAR")
						VEIVM130TAR(VV9->VV9_NUMATE,"5") // 0-Verifica/Valida / 1-Gravacao / 2-Finalizacao / 3-Pelo Usuario / 4-Pendente Aprovacao / 5-Pre-Aprovado / 6-Aprovado / 7-Reserva / 8-Cancela Reserva / 9-Cancela Atendimento
					EndIf 
					//valida regra para tarefas - Rafael Goncalves - 28/01/2010
					If FindFunction("VA400REGRA")
						//if VV0->VV0_RESERV $ "1/3"
							VA400REGRA(VV9->VV9_NUMATE,"3")// 1 - Gravacao / 2- Pendente / 3- pre-aprovado / 4 aprovado
						//EndIF
					EndIf
				EndIf
				//Ponto de entrada para avisar vendedor que foi liberado
				If ExistBlock("AVILIB011")
					ExecBlock("AVILIB011",.f.,.f.)
				Endif				
				//Ponto de entrada GENERICO
				If ExistBlock("DEPLIB011")
					ExecBlock("DEPLIB011",.f.,.f.)
				Endif				
				lFechaDlg := .t.
			Endif
		Endif
		dbSelectArea("VAI")
		dbGoto(nRegVAI)
	EndIf
	
Elseif cOpcao == "L" //APROVAR
	
	If FS_VERAPROV(VV0->VV0_NUMTRA)  // Verifica se existe outro Atendimento ja pre-aprovado/aprovado para o mesmo Veiculo (CHASSI)
		lRet := .f.
		return .f.
	EndIf
	
	lTitAbe := .f.
	dbSelectArea("VS9")
	dbSetOrder(1)
	if dbSeek(xFilial("VS9")+left(VV0->VV0_NUMTRA+space(30),len(VS9->VS9_NUMIDE)))
		While (xFilial("VS9")+left(VV0->VV0_NUMTRA+space(30),len(VS9->VS9_NUMIDE)))== (VS9->VS9_FILIAL+VS9->VS9_NUMIDE) .and. !Eof()
			if Empty(VS9->VS9_DATBAI) // .AND. ( VS9->VS9_TIPPAG $ GetNewPar("MV_TPVEITR","VEICULOS") )
				lTitAbe := .t.
				exit
			endif
			dbSelectArea("VS9")
			dbSkip()
		End
	Endif
	if lTitAbe
		if !(MsgYesNo(STR0195 ,STR0012)) //Existem sinais em aberto. Deseja continuar? ### Atencao
			lRet := .f.
			return .f.
		endif
	endif
	dbSelectArea("VAI")
	dbSetOrder(4)
	nRegVAI := Recno()
	if dbSeek(xFilial("VAI")+VV9->VV9_USUARI)
		Begin Transaction
		if (VV9->VV9_STATUS == "O") .and. FS_CLI011(.f.)
			lRet := .t.
			M->VV9_STATUS := "L"
			Processa({|| FS_GRVATE1() })
			dbSelectArea("VV1")
			dbSetOrder(2)
			if dbSeek(cFilSelVV1+M->VV0_CHASSI)
				RecLock("VV1",.f.)
				VV1->VV1_RESERV := "3"
				MsUnlock()
			Endif
		Else
			lRet := .f.
		Endif
		if lMsErroAuto
			DisarmTransaction()
			Break
		Endif
		End Transaction
		if lMsErroAuto
			MostraErro()
		Else
			If VV9->VV9_STATUS == "L"
				If FindFunction("VEIVM130TAR")
					VEIVM130TAR(VV9->VV9_NUMATE,"6")// 0-Verifica/Valida / 1-Gravacao / 2-Finalizacao / 3-Pelo Usuario / 4-Pendente Aprovacao / 5-Pre-Aprovado / 6-Aprovado / 7-Reserva / 8-Cancela Reserva / 9-Cancela Atendimento
				EndIf
				//valida regra para tarefas - Rafael Goncalves - 28/01/2010
				If FindFunction("VA400REGRA") 
					//if VV0->VV0_RESERV $ "1/3"
						VA400REGRA(VV9->VV9_NUMATE,"4")// 1 - Gravacao / 2- Pendente / 3- pre-aprovado / 4 aprovado
					//EndIf	
				EndIf
			EndIf
			lFechaDlg := .t.
		Endif
	Endif
	dbSelectArea("VAI")
	dbGoto(nRegVAI)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AVARES011    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AVARES011()

if !PERGUNTE("ATDCLI")
	Return
Endif

aStru    := {}
cCodMap  := Mv_Par01
cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
cSimOMoe := Val(Alltrim(GetMv("MV_INDMFT")))

VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))

SB1->(dbSetOrder(7))
SB1->(dbSeek(xFilial("SB1")+cGruVei+VV1->VV1_CHAINT))

dbSelectArea("VS5")
dbSetOrder(1)
if !dbSeek(xFilial("VS5")+cCodMap)
	MsgInfo(STR0196 ,STR0012) //Mapa de veiculos nao cadastrado! ### Atencao
	Return .f.
Endif

dbSelectArea("VOQ")
dbSetOrder(1)
if !dbSeek(xFilial("VOQ")+cCodMap)
	MsgInfo(STR0196 ,STR0012) //Mapa de veiculos nao cadastrado! ### Atencao
	Return .f.
Endif

While !Eof() .and. VOQ->VOQ_FILIAL == xFilial("VOQ")
	
	if !(M->VV0_TIPFAT $ VOQ_TIPFAT)
		dbSkip()
		Loop
	Endif
	If VOQ_INDATI # "1" // Sim
		dbSkip()
		Loop
	Endif
	If VOQ_CODMAP # cCodMap
		exit
	Endif
	
	cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
	aadd(aStru,{ M->VV0_NUMTRA,VV1->VV1_TRACPA,SB1->B1_COD,;
	VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VV1->VV1_CHASSI,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,M->VV0_DATMOV,0,0,VOQ_CTATOT})
	
	dbSkip()
	
Enddo

if M->VV0_TOTICM == 0
	INIFIS011()
	FISCAL011()
Endif

//Simula a gravacao para apresentacao do mapa
CPOMEM011("M")

//Calcula os valores do vetor
FG_CalcVlrs(aStru)

//Executa o mapa de avaliacao
FG_ResAva(cOutMoed,3,"V","","VEIVM010")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CPOMEM011    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava variaves de memoria ou campos no arquivo             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CPOMEM011(cOpcao)

Local cont
Local lOpc
Local nValFre  := 0
Local nCusVei  := 0
Local lChassi  := .f.
Local cWhile2  := ""
//Local cAlias2  := ""
Local dJurEst  := 0
Local	nCusCorr := 0
Local nCorrecao:= 0
Local cLocVV0  := iif(cOpcao<>"M","VV0",cOpcao)
Local cLocVVA  := iif(cOpcao<>"M","VVA",cOpcao)
Local cFunJEst := GetNewPar("MV_FUNJEST","") //Nome da Funcao que Calcula o Juros de Estoque
Local _cQuery := ""
Local _cAlVVP := "SQLVVP"

If !Altera .and. !Inclui
	Return
Endif

if Type(cFunJEst) <> "C"
	cFunJEst := ""
Endif
cFunJEst := AllTrim(cFunJEst)

dbSelectArea("VV1")
dbSetOrder(2)
dbSeek(cFilSelVV1+M->VV0_CHASSI)

dbSelectArea("VVA")

if cOpcao <> "M"
	Reclock("VVA",.f.)
Endif

//Juros de estoque
&(cLocVVA+"->VVA_JUREST") := 0

//if M->VV0_SIMULA <> "1" .and. M->VV0_TIPFAT <> "2" //Nao for faturamento direto e nao for simulacao
if M->VV0_OPEMOV == "0" .and. M->VV0_TIPFAT <> "2" //Nao for faturamento direto e nao for simulacao
	dbSelectArea("VVF")
	dbSetOrder(1)
	if dbSeek(xFilial("VVF")+VV1->VV1_TRACPA)
		dbSelectArea("VVG")
		dbSetOrder(1)
		dbSeek(xFilial("VVG")+VV1->VV1_TRACPA)
		
		nValFre := VVG->VVG_VALFRE
		nCusVei := VVG->VVG_VCNVEI
				
		RegTomemory("VVF",.f.)
		RegTomemory("VVG",.f.)
		
		if VV1->VV1_ESTVEI == "0" //Novo
			dbSelectArea("VVG")
			If !Empty(VV2->VV2_FORCUS)       //Modelo do Veiculo
				nCusVei := FG_FORMULA(VV2->VV2_FORCUS)
			ElseIf !Empty(VE4->VE4_FORCTB)   //Parametros da Montadora do Custo Contabil
				nCusVei := FG_FORMULA(VE4->VE4_FORCTB)
			Endif
		Else
			cFor := GetMv("MV_VUCCTB")
			if !Empty(cFor)
				nCusVei := FG_FORMULA(cFor)
			Endif
		Endif
		
		if VV1->VV1_DESADM > 0
			//Despesas administrativas do veiculo
			nCusVei += VV1->VV1_DESADM
		Endif
		
		dJurEst := VVF->VVF_DATEMI
		dbSelectArea("VVA")
		&(cLocVVA+"->VVA_VCAVEI") := FG_CusVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,dJurEst,dDataBase,nCusVei+nValFre)
		//		nCorrecao := &(cLocVVA+"->VVA_VCAVEI") - (nCusVei+nValFre)
		nCorrecao := 0
		&(cLocVVA+"->VVA_JUREST") := nCorrecao
		
		if nCorrecao == 0
			dbSelectArea("SE2")
			dbSetOrder(1)
			if dbSeek(xFilial("SE2")+VVF->VVF_SERNFI+VVF->VVF_NUMNFI)
				if SE2->E2_BAIXA # ctod("  /  /  ") .and. (dDataBase - SE2->E2_BAIXA) > 0  //baixado
					If !Empty(cFunJEst) .And. ExistBlock(cFunJEst)   // Se existir este PRW, entao ele sera usado
						&(cLocVVA+"->VVA_JUREST") := nCorrecao + ExecBlock(cFunJEst,.f.,.f.,{VV1->VV1_TRACPA,VV1->VV1_CHAINT,SE2->E2_BAIXA,dDataBase,'V'})
					Else
						&(cLocVVA+"->VVA_JUREST") := FG_JurEst(VV1->VV1_TRACPA,VV1->VV1_CHAINT,SE2->E2_BAIXA,dDataBase,"V")
					Endif
				Else
					nCusCorr                  := &(cLocVVA+"->VVA_VCAVEI")
					&(cLocVVA+"->VVA_VCAVEI") := VVG->VVG_VCNVEI
					nCorrecao                 := nCusCorr - &(cLocVVA+"->VVA_VCAVEI")
					&(cLocVVA+"->VVA_JUREST") := nCorrecao
				EndIf
			Else
				If !Empty(cFunJEst) .and. ExistBlock(cFunJEst)   // Se existir este PRW, entao ele sera usado
					&(cLocVVA+"->VVA_JUREST") := nCorrecao + ExecBlock(cFunJEst,.f.,.f.,{VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATEMI,dDataBase,'V'})
				Else
					&(cLocVVA+"->VVA_JUREST") := FG_JurEst(VV1->VV1_TRACPA,VV1->VV1_CHAINT,VVF->VVF_DATEMI,dDataBase,"V")
				Endif
			Endif
		Endif
		
		&(cLocVVA+"->VVA_VBAICM") := M->VV0_VBAICM
		&(cLocVVA+"->VVA_ICMVEN") := M->VV0_TOTICM
		aPisCof := CalcPiscofSai((M->VV0_VALTOT-(VVG->VVG_VCNVEI+VVG->VVG_VALFRE)))
		&(cLocVVA+"->VVA_PISVEN") := aPisCof[1,1]
		&(cLocVVA+"->VVA_COFVEN") := aPisCof[1,2]
		&(cLocVVA+"->VVA_VALREV") := Iif(M->VVA_VALREV>0,M->VVA_VALREV,iif(VV1->VV1_ESTVEI == "0",VV2->VV2_VALREV,VVG->VVG_VALREV))
		&(cLocVVA+"->VVA_SEGVIA") := VVG->VVG_SEGVIA
		&(cLocVVA+"->VVA_VALASS") := VVG->VVG_VALASS
		&(cLocVVA+"->VVA_PISENT") := VVG->VVG_PISENT
		&(cLocVVA+"->VVA_COFENT") := VVG->VVG_COFENT
		&(cLocVVA+"->VVA_CODIND") := VVG->VVG_CODIND
		&(cLocVVA+"->VVA_TOTCUS") := iif(!Empty(GetNewPar("MV_TOTCUFN","")),FG_FORMULA(GetNewPar("MV_TOTCUFN","")),M->VVA_VCAVEI-M->VVA_REDCUS+M->VVA_JUREST+M->VVA_VALFRE+M->VVA_ACESSO+M->VVA_VDESCO+M->VVA_PISENT+M->VVA_COFENT)
	Endif
Else
	//Levanta preco atual da tabela.
	VV2->(dbSetOrder(5))
	VV2->(dbSeek(xFilial("VV2")+M->VV0_CODMAR+cModVei))
	
	nValCor := 0
	nValRpr := 0
	nValRmt := 0
	nValCus := 0
	
	_cQuery := "SELECT VVP.VVP_DATPRC , VVP.VVP_VACRPR , VVP.VVP_VACRMT , VVP.VVP_CUSTAB FROM "+RetSqlName("VVP")+" VVP WHERE VVP.VVP_FILIAL='"+xFilial("VVP")+"' AND VVP.VVP_CODMAR='"+M->VV0_CODMAR+"' AND VVP.VVP_MODVEI='"+M->VV0_MODVEI+"' AND VVP.VVP_SEGMOD='"+VV2->VV2_SEGMOD+"' AND VVP.D_E_L_E_T_=' ' ORDER BY VVP.VVP_DATPRC"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVP , .F., .T. )
	While !( _cAlVVP )->( Eof() )
		If	( _cAlVVP )->( VVP_DATPRC ) <= dtos(dDataBase)
			nValRpr := ( _cAlVVP )->( VVP_VACRPR )
			nValRmt := ( _cAlVVP )->( VVP_VACRMT )
			nValCus := ( _cAlVVP )->( VVP_CUSTAB )
		Else
			Exit
		EndIf
		( _cAlVVP )->( DbSkip() )
	EndDo
	( _cAlVVP )->( dbCloseArea() )
	
	dbSelectArea("VVC")
	dbSetOrder(1)
	dbSeek(xFilial("VVC")+M->VV0_CODMAR+M->VV0_CORVEI)
	
	if VVC->VVC_TIPCOR == "1"
		nValCor := nValRmt
	Endif
	if VVC->VVC_TIPCOR == "2"
		nValCor := nValRpr
	Endif
	
	&(cLocVVA+"->VVA_VBAICM") := M->VV0_VBAICM
	&(cLocVVA+"->VVA_ICMVEN") := M->VV0_TOTICM
	aPisCof := CalcPiscofSai(M->VV0_VALTOT)
	&(cLocVVA+"->VVA_PISVEN") := aPisCof[1,1]
	&(cLocVVA+"->VVA_COFVEN") := aPisCof[1,2]
	&(cLocVVA+"->VVA_VCAVEI") := nValCus + nValCor
	&(cLocVVA+"->VVA_TOTCUS") := iif(!Empty(GetNewPar("MV_TOTCUFD","")),FG_FORMULA(GetNewPar("MV_TOTCUFD","")),M->VVA_VCAVEI-M->VVA_REDCUS+M->VVA_JUREST+M->VVA_ACESSO+M->VVA_VDESCO+M->VVA_PISENT+M->VVA_COFENT)
Endif

VE1->(dbSetOrder(1))
VE1->(dbSeek(xFilial("VE1")+VV1->VV1_CODMAR))
VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))

&(cLocVVA+"->VVA_DESVEI") := 0
&(cLocVVA+"->VVA_RECVEI") := 0
dbSelectArea("VVD")
dbSetOrder(1)
if dbSeek(xFilial("VVD")+VV1->VV1_TRACPA+VV1->VV1_CHAINT)
	while !eof() .and. VVD->VVD_TRACPA == VV1->VV1_TRACPA .and. VVD->VVD_CHAINT == VV1->VV1_CHAINT
		If VVD->VVD_TIPOPE == "0" // Despesa
			&(cLocVVA+"->VVA_DESVEI") += VVD->VVD_VALOR
		ElseIf VVD->VVD_TIPOPE == "1" // Receita
			&(cLocVVA+"->VVA_RECVEI") += VVD->VVD_VALOR
		Endif
		dbSelectArea("VVD")
		dbSkip()
	Enddo
Endif

&(cLocVVA+"->VVA_DESCLI") := M->VVA_DESCLI
if VVA->(FieldPos("VVA_REDVDA")) <> 0
	&(cLocVVA+"->VVA_REDVDA") := M->VVA_REDVDA
EndIf
if VVA->(FieldPos("VVA_AGREGA")) <> 0
	&(cLocVVA+"->VVA_AGREGA") := M->VVA_AGREGA
EndIf
&(cLocVVA+"->VVA_VALMOV") := M->VV0_VALMOV

if cOpcao <> "M"
	VVA->(MsUnlock())
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava valores de moeda forte nas variaveis de memoria               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FS_MFORTE("M")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RESERVA      ³ Autor ³ ANDRE             ³ Data ³ 25/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Reserva o veiculo para o atendimento                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RESERVA()

Local lRet := .t.
Local dDatTmp
Local dDatRes 

if VV1->VV1_RESERV $ "1/3" .and. M->VV0_RESERV $ "1/3"
	if !Empty(VV1->VV1_DTHVAL)
		dDatTmp := dToS(cToD(subs(VV1->VV1_DTHVAL,1,8)))
		dDatRes := Subs(dDatTmp,7,2) + "/" + Subs(dDatTmp,5,2) + "/" + Subs(dDatTmp,1,4)
		cHorTmp := subs(VV1->VV1_DTHVAL,10,2)+":"+subs(VV1->VV1_DTHVAL,12,2)
		if dDataBase < ctod(dDatRes)
			lRet := .f.
		Elseif dDataBase = ctod(dDatRes)
			if Time() < cHorTmp
				lRet := .f.
			Endif
		Endif
	Else
		lRet := .t.
	Endif
Endif

if lRet
	if !lResVei .and. M->VV0_RESERV $ "1/3"
		lRet := .f.
		MsgInfo(STR0197 ,STR0012) //Usuario sem permissao para reservar veiculo... ### Atencao
	Endif
Endif 

If M->VV0_RESERV $ "1/3"  
	If !VM011RES() //verifica se existe reserva para o veiculo em outro atendimneto.
		//lRet := .f.
		M->VV0_RESERV := "0"
		M->VV0_DATVAL := CTOD("  /  /  ")
		M->VV0_HORVAL := "     " 
		lRet := .t.
		oOpcoes:SetFocus() 
		oGetMGet2:SetFocus()
	EndiF
EndiF
//Rafael - incluido validação no momento que selecionar que reserva veiculo para validar se existe tarefas para o veiculo.
If FindFunction("VA400REGRA") .AND. M->VV0_RESERV $ "1/3" .AND. lRet
	lRet := VA400REGRA(M->VV9_NUMATE,"5")// 1 - Gravacao / 2- Pendente / 3- pre-aprovado / 4 aprovado / 5- pelo Usuario
	If !lRet
		M->VV0_RESERV := "0"
		M->VV0_DATVAL := CTOD("  /  /  ")
		M->VV0_HORVAL := "     " 
		lRet := .t.
		oOpcoes:SetFocus() 
		oGetMGet2:SetFocus()
	EndIf
EndIf 
	    
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CANRES011    ³ Autor ³ ANDRE             ³ Data ³ 25/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancela Reserva do veiculo                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CANRES011()

if !Inclui
	if VV1->VV1_RESERV $ "1/3" .and. VV0->VV0_RESERV $ "1/3"
		if !Empty(VV1->VV1_DTHVAL)
			if lLibVei
				M->VV0_RESERV := ""
				M->VV0_DATVAL := CTOD("")
				M->VV0_HORVAL := ""
				RecLock("VV1",.f.)
				VV1->VV1_RESERV := ""
				VV1->VV1_DTHVAL := ""
				MsUnlock()
				If FindFunction("VEIVM130TAR")
					VEIVM130TAR(M->VV0_NUMTRA,"8") // 0-Verifica/Valida / 1-Gravacao / 2-Finalizacao / 3-Pelo Usuario / 4-Pendente Aprovacao / 5-Pre-Aprovado / 6-Aprovado / 7-Reserva / 8-Cancela Reserva / 9-Cancela Atendimento
				EndIf
			Else
				MsgInfo(STR0198,STR0012) //Usuario sem permissao para cancelar reserva de veiculo... ### Atencao
			Endif
		Endif
	Endif
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ADIANT011    ³ Autor ³ ANDRE             ³ Data ³ 10/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra titulos de adiantamento do cliente selecionado      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ADIANT011()
Local aTitulos := {}
Local lPosSA1  := .f.
dbSelectArea("SA1")
If !Empty(M->VV9_CODCLI+M->VV9_LOJA)
	dbSetOrder(1)
	lPosSA1 := dbSeek(xFilial("SA1")+M->VV9_CODCLI+M->VV9_LOJA)
Else
	dbSetOrder(2)
	lPosSA1 := dbSeek(xFilial("SA1")+M->VV9_NOMVIS)
EndIf
If lPosSA1
	dbSelectArea("SE1")
	dbSetOrder(2)
	if dbSeek(xFilial("SE1")+SA1->A1_COD+SA1->A1_LOJA)
		While !EOF() .and. SA1->A1_COD == SE1->E1_CLIENTE .and. SA1->A1_LOJA == SE1->E1_LOJA
			if SE1->e1_TIPO == "RA"
				aadd(aTitulos,{SE1->E1_NUM,SE1->E1_VENCTO,SE1->E1_VALOR})
			Endif
			dbSelectArea("SE1")
			dbSkip()
		EndDo
	Endif
Endif

if Len(aTitulos) > 0
	DEFINE MSDIALOG oDlgAdTit TITLE cCadastro FROM  4.5,0 To 20.5,80 OF oMainWnd
	
	@ nLin,1 LISTBOX oLbox FIELDS HEADER;
	OemToAnsi(""),;
	OemToAnsi(STR0199),;	//Titulo
	OemToAnsi(STR0119),;	//data
	OemToAnsi(STR0023); 	//valor
	COLSIZES 5,5,5,15,65,72,19,50,45,22,20,20,40,50;
	SIZE 312,100 OF oDlgAdTit PIXEL
	
	if len(aTitulos) == 0
		aAdd(aTitulos, { .f.,"","",0} )
	Endif
	
	oLbox:SetArray(aTitulos)
	oLbox:bLine := { || { if(aTitulos[oLbox:nAt,01] == .f.,oNo,oTik),;
	aTitulos[oLbox:nAt,02],;
	FG_AlinVlrs(Transform(aTitulos[oLbox:nAt,03],"9,999,999.99"))} }
	
	ACTIVATE MSDIALOG oDlgAdTit CENTER
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ IMPPRO011    ³ Autor ³ ANDRE             ³ Data ³ 25/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprime proposta de veiculo                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function IMPPRO011()

if M->VV0_VALMOV == 0 
   Return()
Endif  
if MsgYesNo(STR0200 ,STR0012) //Imprime a proposta? ### Atencao 
	//ponto de entrada que valida a gravacao
	if ExistBlock("VM011GVA")
		If !ExecBlock("VM011GVA",.f.,.f.)
			Return .f.
		Endif
	Endif
	//if Inclui
	//   MsgInfo("A proposta/simulacao sera emitida automaticamente apos a confiormacao de gravacao!","Atencao!")
	//   Return
	//Endif
	IF !FS_VLDCDP() 
	   Return()
	Endif   
    
//	if M->VV0_VALRES > 0 .and. M->VV0_OPEMOV <> "1"
//		MsgInfo(STR0201 ,STR0012) //A negociacao nao foi concluida portanto nao sera possivel emitir a proposta de venda! ### Atencao
//		Return
//	Endif
	if Empty(M->VV9_NOMVIS)
		MsgInfo(STR0202 ,STR0012) //E necessario informar o nome do cliente! ### Atencao
		Return
	Endif
	Processa({|| FS_GRVATE1() })
	
	//Executa RdMake da Proposta de Venda
	if ExistBlock("PROPVEI")
		ExecBlock("PROPVEI",.f.,.f.,{VV0->VV0_NUMPED})
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TIPOATD011   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a descricao do tipo de atendimento                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TIPOATD011()

Return(iif(Posicione("VV0",1,xFilial("VV0")+VV9->VV9_NUMATE,"VV0_TIPFAT")$"01",iif(VV0->VV0_OPEMOV == "1",STR0152,STR0205),iif(VV0->VV0_TIPFAT=="2",STR0204,STR0203)))    //Simulacao ### estoque (novo/usado) ### Direto da fabrica ### entrega futura

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VLDCDP    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza entrada da negociacao com o valor total           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VLDCDP()
Local lProbTit:= .f. // Verifica se existem problemas com as Datas dos Titulos
Local cont
Local cTipo   := "DP"
//Local cDesTit := space(30)
//Local dDatTit := dDataBase
//Local nValTit := M->VV0_VALTOT-M->VV0_TOTENT-iif(M->VV0_VALFIN > 0,M->VV0_VALFIN, M->VV0_VALTOT) 
Local nValTit := (M->VV0_VALTOT)-M->VV0_TOTENT-M->VV0_VALFIN
If Len(aColsC) >= 1 .and. !Empty(aColsC[1,1])
	For cont := 1 to Len(aColsC) // Somar parcelas no Valor dos Titulos
		If !aColsC[cont,len(aColsC[cont])]
			If aColsC[cont,3] < dDatabase
				lProbTit := .t.
			EndIf
		EndIf
	Next
EndIf
If !lProbTit // Nenhum problema com as Datas dos Titulos
	For cont := 1 to Len(aIteParc) // Somar parcelas no Valor dos Titulos
		If aIteParc[cont,2] <> 0
			If aIteParc[cont,1] < dDatabase
				lProbTit := .t.
			EndIf
			If aIteParc[cont,2] > 0
				nValTit -= aIteParc[cont,2]
			EndIf
		EndIf
	Next
EndIf
If (Abs(nValTit) > 0.01)
	nValTit := 0
Endif
If Altera .or. Inclui // Somente Validar se for Alterar ou Incluir - FNC 24112/2009 - Andre Luis Almeida - 01/10/2009
	If lProbTit .and. Left(Alltrim(GetNewPar("MV_VTITVEI","S")),1) $ "S/1" // ( 1 ou S -> Sim / 0 ou N -> Nao )
		MsgStop(STR0258,STR0012) // "Existem divergencias nas Datas de Vencimento dos Titulos"
		Return .f.
	EndIf
	If !(Left(GetNewPar("MV_VEIDNFT","N"),1) $ "S/1") // Permite Valores da Venda (NF) e Titulos divergentes ? ( 1 ou S -> Sim / 0 ou N -> Nao )
		If nValTit > 0.01
			MsgStop(STR0159+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0259+Transform(nValTit,"@E 99,999,999.99"),STR0012) // "Valor dos pagamentos estao incoerentes com o valor da venda..."
			Return .f.
		EndIf
	EndIf
	If nValTit+0.01 < 0
		If !MsgyesNo(STR0159+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0259+Transform(nValTit,"@E 99,999,999.99")+STR0323,STR0012) // "Valor dos pagamentos estao incoerentes com o valor da venda..."
			Return .f.
		EndIf
	EndIf
EndIf
nOpca := 1

/*
If nValTit > 0
	nOpca := 0
	DEFINE MSDIALOG oDlgTIT TITLE STR0206 FROM 9,0 TO 14,55 OF oMainWnd   //Titulo de Pagamento
		@ 014,010 Say OemToAnsi(STR0207) SIZE 40,08 OF oDlgTIT PIXEL COLOR CLR_BLUE //Tipo
		@ 022,010 msGet oTipo VAR cTipo Picture "@!" F3 "SAV" SIZE 15,08 OF oDlgTIT PIXEL COLOR CLR_BLACK
		@ 014,035 Say OemToAnsi(STR0061) SIZE 40,08 OF oDlgTIT PIXEL COLOR CLR_BLUE //descricao
		@ 022,035 msGet oDesTit VAR cDesTit Picture "@!" SIZE 88,08 OF oDlgTIT PIXEL COLOR CLR_BLACK when .f.
		@ 014,127 Say OemToAnsi(STR0119) SIZE 40,08 OF oDlgTIT PIXEL COLOR CLR_BLUE //DAta
		@ 022,127 msGet oDatTit VAR dDatTit Picture "@D" SIZE 40,08 OF oDlgTIT PIXEL COLOR CLR_BLACK when .f.
		@ 014,170 Say OemToAnsi(STR0023) SIZE 40,08 OF oDlgTIT PIXEL COLOR CLR_BLUE //valor
		@ 022,170 msGet oValTit VAR nValTit Picture "@E 999,999.99" SIZE 40,08 OF oDlgTIT PIXEL COLOR CLR_BLACK when .f.
	ACTIVATE MSDIALOG oDlgTIT ON INIT EnchoiceBar(oDlgTIT,{|| nOpca := 1, oDlgTIT:End() },{|| nOpca := 2, oDlgTIT:End() } )
Else
	nOpca := 1
Endif
*/

cTipTit := cTipo
nTitDif := nValTit

/*
dbSelectArea("SE1")
dbSetOrder(1)
if !dbSeek(xFilial("SE1")+SM0->M0_CODFIL+"E"+Right(M->VV9_NUMATE,nTamNota)) .or. !dbSeek(xFilial("SE1")+SM0->M0_CODFIL+"F"+Right(M->VV9_NUMATE,nTamNota))
for cont := 1 to len(aCols)
if !Empty(aCols[cont,FG_POSVAR("VS9_TIPPAG","aHeaderC")]) .and. !aCols[cont,len(aCols[cont])] .and. (aCols[cont,FG_POSVAR("VS9_DATPAG","aHeaderC")] < dDataBase)
MsgInfo("A data dos pagamentos de entrada nao podem ser inferior a data de hoje.","Atencao")
nOpca := 2
Endif
next

for cont := 1 to len(aIteParc)
if !Empty(aIteParc[cont,1]) .and. (aIteParc[cont,2] > 0) .and. (aIteParc[cont,1] < dDataBase)
MsgInfo("A data dos vencimentos do financiamento nao podem ser inferior a data de hoje.","Atencao")
nOpca := 2
Endif
next
Endif
*/
Return(nOpca==1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ATUENT011    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza entrada da negociacao com o valor total           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATUENT011()

Local cont
Local nValor := 0
Local aColsSlv
Local aHeaderSlv

if Type("aCols") == "U"
	Return(0)
Endif

aColsSlv   := Aclone(aCols)
aHeaderSlv := Aclone(aHeader)

//if Substr(aHeader[1,2],1,3) <> "VS9"

	aCols := Aclone(aColsC)
	aHeader := Aclone(aHeaderC)
	If ReadVar()=='M->VS9_VALPAG'
	   aCols[n,fg_posvar('VS9_VALPAG','aHeader')]   := M->VS9_VALPAG
	   aColsC[n,fg_posvar('VS9_VALPAG','aHeaderC')] := M->VS9_VALPAG
	Endif
	   
//Endif
M->VV0_VALFIN := 0
For cont := 1 to Len(aCols)
	If !aCols[cont,len(aCols[cont])]
		nValor := nValor + aCols[cont,FG_POSVAR("VS9_VALPAG")]
		dbSelectArea("VSA")
		dbSetOrder(1)
		if dbSeek(xFilial("VSA")+aCols[cont,FG_POSVAR("VS9_TIPPAG")]) .and. VSA->(FieldPos("VSA_FINANC")) > 0 .and. VSA->VSA_FINANC == "1"
			nValor -= aCols[cont,FG_POSVAR("VS9_VALPAG")]
			M->VV0_VALFIN += aCols[cont,FG_POSVAR("VS9_VALPAG")]
		EndIf
	Endif
Next

if ReadVar() == "M->VS9_VALPAG"
	nValor -= aCols[n,FG_POSVAR("VS9_VALPAG")]
	nValor += M->VS9_VALPAG
	dbSelectArea("VSA")
	dbSetOrder(1)
	if dbSeek(xFilial("VSA")+aCols[n,FG_POSVAR("VS9_TIPPAG")]) .and. VSA->(FieldPos("VSA_FINANC")) > 0 .and. VSA->VSA_FINANC == "1"
		M->VV0_VALFIN -= aCols[n,FG_POSVAR("VS9_VALPAG")]
		M->VV0_VALFIN += M->VS9_VALPAG
	EndIf
Endif

aCols   := aClone(aColsSlv)
aHeader := aClone(aHeaderSlv)

Return(nValor)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ATUFIN011    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza entrada da negociacao com o valor total           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATUFIN011()

Local cont
Local nValor := 0

if Type("aIteParc") == "U"
	Return(0)
Endif
For cont := 1 to Len(aIteParc)
	nValor := nValor + aIteParc[cont,2]
Next

Return(nValor)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CHKLST011    ³ Autor ³ ANDRE             ³ Data ³ 28/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Check-list de veiculo                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CHKLST011()

dbSelectArea("VAH")
dbSetOrder(1)
if !dbSeek(xFilial('VAH')+VV9->VV9_NUMATE)
	Reclock("VAH",.t.)
	VAH->VAH_FILIAL := xFilial("VAH")
	VAH->VAH_NUMTRA := VV9->VV9_NUMATE
	MsUnlock()
Endif

VEICM540I("VAH",0,3)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ITECORT011   ³ Autor ³ ANDRE             ³ Data ³ 25/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Marca iten como cortesia                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ITECORT011()

if oFldAcess:nOption = 1
	if oLboxAce:nAt > 0
		aAcessor[oLboxAce:nAt,05] := !aAcessor[oLboxAce:nAt,05]
	Endif
	MARACE011(.f.)
Else
	if oLboxKit:nAt > 0
		aKits[oLboxKit:nAt,06] := !aKits[oLboxKit:nAt,06]
	Endif
	MARKIT011(.f.)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VALRES011    ³ Autor ³ ANDRE             ³ Data ³ 25/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a data da reserva do veiculo para o atendimento     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VALRES011(nOpc)

Local lRet  := .t.
Local nHora := (val(substr(Time(),1,2))+GetNewPar("MV_NMHORRV",2))/24
Local nData := dDataBase + int(nHora)

default nOpc := 1

If FindFunction("VA400REGRA")
	//if VV0->VV0_RESERV $ "1/3"
		VA400REGRA(VV9->VV9_NUMATE,"2")// 1 - Gravacao / 2- Pendente / 3- pre-aprovado / 4 aprovado
	//EndIF
EndIf       

If FindFunction("VA400REGRA")
	If VA400REGRA(M->VV9_NUMATE,"5",.t.)
	
			if val(substr(M->VV0_HORVAL,1,2)) > 23
				lRet := .f.
			Elseif val(substr(M->VV0_HORVAL,3,2)) > 59
				lRet := .f.
			Endif 
	Else
		if nOpc == 1
			lRet := M->VV0_DATVAL <= nData
		Else
			if val(substr(M->VV0_HORVAL,1,2)) > 23
				lRet := .f.
			Elseif val(substr(M->VV0_HORVAL,3,2)) > 59
				lRet := .f.
			Elseif val(substr(M->VV0_HORVAL,1,2)) > (val(substr(Time(),1,2))+GetNewPar("MV_NMHORRV",2))
				lRet := .f.
			Elseif val(substr(M->VV0_HORVAL,1,2)) == (val(substr(Time(),1,2))+GetNewPar("MV_NMHORRV",2)) .and. val(substr(M->VV0_HORVAL,3,2)) > val(substr(Time(),4,2))
				lRet := .f.
			Endif
		Endif 
	Endif 
Else
	if nOpc == 1
		lRet := M->VV0_DATVAL <= nData
	Else
		if val(substr(M->VV0_HORVAL,1,2)) > 23
			lRet := .f.
		Elseif val(substr(M->VV0_HORVAL,3,2)) > 59
			lRet := .f.
		Elseif val(substr(M->VV0_HORVAL,1,2)) > (val(substr(Time(),1,2))+GetNewPar("MV_NMHORRV",2))
			lRet := .f.
		Elseif val(substr(M->VV0_HORVAL,1,2)) == (val(substr(Time(),1,2))+GetNewPar("MV_NMHORRV",2)) .and. val(substr(M->VV0_HORVAL,3,2)) > val(substr(Time(),4,2))
			lRet := .f.
		Endif
	Endif 
Endif 
	

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VALMIN    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra ou valida valores minimos na negociacao             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALMIN(lValida, lTela)

Local oDlgValMin
Local lRet    := .t.
Local nMinVen := 0
Local nMinGer := 0
Local nDifVen := 0
Local nDifGer := 0
Local nValVen := FS_PRECO011(.f.)
Local nValAtu := M->VV0_VALTOT
Local _cQuery := ""
Local _cAlVVP := "SQLVVP"
Default lValida := .f.
Default lTela   := .t.

VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+M->VV0_CODMAR+M->VV0_MODVEI))

nValorMin := 0

//Valor minimo do vendedor
dbSelectArea("VV1")
if !Empty(VV1->VV1_MINVEN)
	nMinVen := VV1->VV1_MINVEN
Else
	If lSelect // M->VV0_TIPFAT <> "2" .AND. M->VV0_SIMULA <> "1"
		_cQuery := "SELECT VVP.VVP_DATPRC , VVP.VVP_MINVEN FROM "+RetSqlName("VVP")+" VVP WHERE VVP.VVP_FILIAL='"+xFilial("VVP")+"' AND VVP.VVP_CODMAR='"+VV1->VV1_CODMAR+"' AND VVP.VVP_MODVEI='"+VV1->VV1_MODVEI+"' AND VVP.VVP_SEGMOD='"+VV1->VV1_SEGMOD+"' AND VVP.VVP_MINVEN>0 AND VVP.D_E_L_E_T_=' ' ORDER BY VVP.VVP_DATPRC"
	Else
		_cQuery := "SELECT VVP.VVP_DATPRC , VVP.VVP_MINVEN FROM "+RetSqlName("VVP")+" VVP WHERE VVP.VVP_FILIAL='"+xFilial("VVP")+"' AND VVP.VVP_CODMAR='"+M->VV0_CODMAR+"' AND VVP.VVP_MODVEI='"+M->VV0_MODVEI+"' AND VVP.VVP_SEGMOD='"+VV2->VV2_SEGMOD+"' AND VVP.VVP_MINVEN>0 AND VVP.D_E_L_E_T_=' ' ORDER BY VVP.VVP_DATPRC"
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVP , .F., .T. )
	While !( _cAlVVP )->( Eof() )
		If	( _cAlVVP )->( VVP_DATPRC ) <= dtos(dDataBase)
			nMinVen := ( _cAlVVP )->( VVP_MINVEN )
		Else
			Exit
		EndIf
		( _cAlVVP )->( DbSkip() )
	EndDo
	( _cAlVVP )->( dbCloseArea() )
Endif

//Valor minimo do gerente
dbSelectArea("VV1")
if !Empty(VV1->VV1_MINGER)
	nMinGer := VV1->VV1_MINGER
Else
	If lSelect // M->VV0_TIPFAT <> "2" .AND. M->VV0_SIMULA <> "1"
		_cQuery := "SELECT VVP.VVP_DATPRC , VVP.VVP_MINGER FROM "+RetSqlName("VVP")+" VVP WHERE VVP.VVP_FILIAL='"+xFilial("VVP")+"' AND VVP.VVP_CODMAR='"+VV1->VV1_CODMAR+"' AND VVP.VVP_MODVEI='"+VV1->VV1_MODVEI+"' AND VVP.VVP_SEGMOD='"+VV1->VV1_SEGMOD+"' AND VVP.VVP_MINGER>0 AND VVP.D_E_L_E_T_=' ' ORDER BY VVP.VVP_DATPRC"
	Else
		_cQuery := "SELECT VVP.VVP_DATPRC , VVP.VVP_MINGER FROM "+RetSqlName("VVP")+" VVP WHERE VVP.VVP_FILIAL='"+xFilial("VVP")+"' AND VVP.VVP_CODMAR='"+M->VV0_CODMAR+"' AND VVP.VVP_MODVEI='"+M->VV0_MODVEI+"' AND VVP.VVP_SEGMOD='"+VV2->VV2_SEGMOD+"' AND VVP.VVP_MINGER>0 AND VVP.D_E_L_E_T_=' ' ORDER BY VVP.VVP_DATPRC"
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVP , .F., .T. )
	While !( _cAlVVP )->( Eof() )
		If	( _cAlVVP )->( VVP_DATPRC ) <= dtos(dDataBase)
			nMinGer := ( _cAlVVP )->( VVP_MINGER )
		Else
			Exit
		EndIf
		( _cAlVVP )->( DbSkip() )
	EndDo
	( _cAlVVP )->( dbCloseArea() )
Endif
if lTela
	DEFINE MSDIALOG oDlgValMin TITLE OemtoAnsi(STR0208) FROM  02,04 TO 12,30 OF oMainWnd  //Valores Minimos
	
	@ 006,004 SAY OemToAnsi(STR0209) OF oDlgValMin PIXEL COLOR CLR_BLUE  //Valor Venda
	@ 006,056 MSGET oValVen VAR nValVen PICTURE "@R 999,999.99" SIZE 45,4  OF oDlgValMin PIXEL COLOR CLR_BLACK when .f.
	
	@ 019,004 SAY OemToAnsi(STR0210) OF oDlgValMin PIXEL COLOR CLR_BLUE  //Valor Atual
	@ 019,056 MSGET oValAtu VAR nValAtu PICTURE "@R 999,999.99" SIZE 45,4  OF oDlgValMin PIXEL COLOR CLR_BLACK when .f.
	
	@ 032,004 SAY OemToAnsi(STR0211) OF oDlgValMin PIXEL COLOR CLR_BLUE  //Minimo Vendedor
	@ 032,056 MSGET oMinVen VAR nMinVen PICTURE "@R 999,999.99" SIZE 45,4  OF oDlgValMin PIXEL COLOR CLR_BLACK when .f.
	
	if lLibVei
		@ 045,004 SAY OemToAnsi(STR0212) OF oDlgValMin PIXEL COLOR CLR_BLUE  //Minimo Gerente
		@ 045,056 MSGET oMinGer VAR nMinGer PICTURE "@R 999,999.99" SIZE 45,4  OF oDlgValMin PIXEL COLOR CLR_BLACK when .f.
	Endif
	
	@ 058,010 BUTTON oOk     PROMPT OemToAnsi(STR0121)       OF oDlgValMin SIZE 43,11 PIXEL ACTION (lRet := .t., nOpca := 1, oDlgValMin:End()) //ok4
	@ 058,055 BUTTON oCancel PROMPT OemToAnsi(STR0120) OF oDlgValMin SIZE 43,11 PIXEL ACTION (oDlgValMin:End()) //cancelar
	
	oOk:SetFocus()
	
	ACTIVATE MSDIALOG oDlgValMin CENTER
Endif

if lValida
	if lLibVei
		if M->VV0_VALTOT < nMinGer
			nValorMin := nMinGer
			lRet := .f.
		Endif
	Else
		if M->VV0_VALTOT < nMinVen
			nValorMin := nMinVen
			lRet := .f.
		Endif
	Endif
Endif

DbSelectArea("VV0")

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GRVACE011    ³ Autor ³ ANDRE             ³ Data ³ 28/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava acessorios / kits selecionados do veiculo            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GRVACE011()

Local cont := 0

dbSelectArea("VV6")
dbSetorder(4)

//Gravacao dos Acessorios / Opcionais
For cont := 1 to Len(aAcessor)
	if !Empty(aAcessor[cont,4])
		VVM->(dbSetOrder(1))
		if VVM->(dbSeek(xFilial("VVM")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD+aAcessor[cont,4])) //Acessorios
			dbSelectArea("VVW")
			dbSetOrder(1)
			if dbSeek(xFilial("VVW")+VVM->VVM_CODMAR+VVM->VVM_CODOPC)
				nCusto := 0
				dbSelectArea("SB1")
				dbSetOrder(7)
				if !Empty(VVW->VVW_GRUITE+VVW->VVW_CODITE)
					if dbSeek(xFilial("SB1")+VVW->VVW_GRUITE+VVW->VVW_CODITE)
						dbSelectArea("SB2")
						dbSetOrder(1)
						if dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
							nCusto := SB2->B2_CM1
						Endif
					Endif
				Endif
				
				dbSelectArea("VV6")
				dbSeek(xFilial("VV6")+M->VV9_NUMATE+aAcessor[cont,4]) //Acessorios no atendimento
				if aAcessor[cont,1]
					RecLock("VV6",!Found())
					VV6->VV6_FILIAL := xFilial("VV6")
					VV6->VV6_TIPREG := VVM->VVM_OPCSER
					VV6->VV6_CODOPC := VVM->VVM_CODOPC
					VV6->VV6_NUMATE := M->VV9_NUMATE
					VV6->VV6_CHAINT := VV1->VV1_CHAINT
					//		VV6->VV6_FORMUL := VVT->VVT_FORMUL
					VV6->VV6_GRUITE := VVW->VVW_GRUITE
					VV6->VV6_CODITE := VVW->VVW_CODITE
					VV6->VV6_VALEQP := iif(VVM->VVM_VALCON > 0,VVM->VVM_VALCON,VVW->VVW_VALOPC)
					//		VV6->VV6_DATINS := VVT->VVT_DATINS
					//		VV6->VV6_ATIVSN := VVT->VVT_ATIVSN
					VV6->VV6_CUSOPC := nCusto
					VV6->VV6_GRATIS := iif(aAcessor[cont,5],"S","N")
					MsUnlock()
				Else
					if Found()
						RecLock("VV6",.f.,.t.)
						VV6->(dbDelete())
						MsUnlock()
						WriteSx2("VV6")
					Endif
				Endif
			Endif
		Endif
	Endif
Next

dbSelectArea("VV6")
dbSetorder(1)

//Gravacao dos Acessorios / Opcionais
For cont := 1 to Len(aKits)
	if !Empty(aKits[cont,4]+aKits[cont,5])
		VET->(dbSeek(xFilial("VET")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD+aKits[cont,4]+aKits[cont,5])) //Acessorios
		nCusto := 0
		dbSelectArea("SB1")
		dbSetOrder(7)
		if dbSeek(xFilial("SB1")+aKits[cont,4]+aKits[cont,5])
			dbSelectArea("SB2")
			dbSetOrder(1)
			if dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
				nCusto := SB2->B2_CM1
			Endif
		Endif
		dbSelectArea("VV6")
		dbSeek(xFilial("VV6")+VV1->VV1_CHAINT+aKits[cont,4]+aKits[cont,5]) //Kits
		if aKits[cont,1]
			RecLock("VV6",!Found())
			VV6->VV6_FILIAL := xFilial("VV6")
			VV6->VV6_TIPREG := "3"
			VV6->VV6_CODOPC := ""
			VV6->VV6_CHAINT := VV1->VV1_CHAINT
			VV6->VV6_NUMATE := M->VV9_NUMATE
			//		VV6->VV6_FORMUL := VVT->VVT_FORMUL
			VV6->VV6_GRUITE := aKits[cont,4]
			VV6->VV6_CODITE := aKits[cont,5]
			VV6->VV6_VALEQP := aKits[cont,3]
			VV6->VV6_CUSOPC := nCusto
			//		VV6->VV6_DATINS := VVT->VVT_DATINS
			//		VV6->VV6_ATIVSN := VVT->VVT_ATIVSN
			MsUnlock()
		Else
			if Found()
				RecLock("VV6",.f.,.t.)
				VV6->(dbDelete())
				MsUnlock()
				WriteSx2("VV6")
			Endif
		Endif
	Endif
Next

//Gravacao dos Acessorios de terceiros
dbSelectArea("VV6")
dbSetOrder(5)
For cont := 1 to Len(aColsTC)
	if !Empty(aColsTC[cont,FG_POSVAR("VV6_VALEQP","aHeaderTC")])
		dbSeek(xFilial("VV6")+M->VV9_NUMATE+aColsTC[cont,FG_POSVAR("VV6_CODFOR","aHeaderTC")]+aColsTC[cont,FG_POSVAR("VV6_LOJA","aHeaderTC")])
		RecLock("VV6",!Found())
		VV6->VV6_FILIAL := xFilial("VV6")
		VV6->VV6_TIPREG := "4"
		VV6->VV6_CODOPC := ""
		VV6->VV6_CHAINT := VV1->VV1_CHAINT
		VV6->VV6_NUMATE := VV9->VV9_NUMATE
		VV6->VV6_GRUITE := ""
		VV6->VV6_CODITE := ""
		VV6->VV6_VALEQP := aColsTC[cont,FG_POSVAR("VV6_VALEQP","aHeaderTC")]
		VV6->VV6_CODFOR := aColsTC[cont,FG_POSVAR("VV6_CODFOR","aHeaderTC")]
		VV6->VV6_LOJA   := aColsTC[cont,FG_POSVAR("VV6_LOJA","aHeaderTC")]
		VV6->VV6_DATINS := aColsTC[cont,FG_POSVAR("VV6_DATINS","aHeaderTC")]
		MsUnlock()
	Else
		if Found()
			RecLock("VV6",.f.,.t.)
			VV6->(dbDelete())
			MsUnlock()
			WriteSx2("VV6")
		Endif
	Endif
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GRVAGR011    ³ Autor ³ ANDRE             ³ Data ³ 28/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava acessorios / kits selecionados do veiculo            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GRVAGR011()
Local cont := 0
If left(aHeader[2,2],3) == "VAT"
	aHeaderAG := aClone(aHeader)
	aColsAG   := aClone(aCols)
Endif
//Gravacao dos agregados
dbSelectArea("VAT")
dbSetorder(1)
For cont := 1 to Len(aColsAG)
	dbSeek(xFilial("VAT")+M->VV9_NUMATE+aColsAG[cont,FG_POSVAR("VAT_CODNEG","aHeaderAG")])
	if !aColsAG[cont,len(aHeaderAG)+1]
		If !Found() .and. aColsAG[cont,FG_POSVAR("VAT_VALNEG","aHeaderAG")] == 0
			Loop
		EndIf
		RecLock("VAT",!Found())
		VAT->VAT_FILIAL := xFilial("VAT")
		VAT->VAT_NUMATE := M->VV9_NUMATE
		VAT->VAT_CODNEG := aColsAG[cont,FG_POSVAR("VAT_CODNEG","aHeaderAG")]
		VAT->VAT_VALNEG := aColsAG[cont,FG_POSVAR("VAT_VALNEG","aHeaderAG")]
		VAT->VAT_DATNEG := aColsAG[cont,FG_POSVAR("VAT_DATNEG","aHeaderAG")]
		VAT->VAT_TIPPAG := aColsAG[cont,FG_POSVAR("VAT_TIPPAG","aHeaderAG")]
		MsUnlock()
	Else
		if Found()
			RecLock("VAT",.f.,.t.)
			VAT->(dbDelete())
			MsUnlock()
			WriteSx2("VAT")
		Endif
	Endif
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PREFTIT      ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pega o prefixo que foi gerado o titulo                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PREFTIT()

dbSelectArea("SF2")
dbSetOrder(1)
If dbSeek(xFilial("SF2") + VV0->VV0_NUMNFI + VV0->VV0_SERNFI )
	cPrefNF := SF2->F2_PREFIXO
Endif

Return(cPrefNF)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FOTO011   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Foto do veiculo                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALFIS(cOpc)

if M->VV0_VALTOT = 0
	Msginfo(STR0213 ,STR0012) //Valor da venda ainda nao definido! ### Atencao
	Return
Endif

INIFIS011()
FISCAL011()
//FG_VALFIS(cOpc)
//FG_PLAFIN()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PESFIL011    ³ Autor ³ ANDRE             ³ Data ³ 17/17/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa veiculo no cadastro                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PESFIL011()
Local nPos := 0
Local _cQuery  := "" 
Local _cAlSB1  := "SQLSB1"
Local _cAlVVC  := "SQLVVC"
Local _cAlVVP  := "SQLVVP"
Local _cAlSA1  := "SQLSA1"
Local _cAlSA2  := "SQLSA2"
Local nDiasEst := 0
Local cCorVei  := ""
Local nValorVda:= 0
Local cLetra   := "N"
Local cFilAtu  := ""
Local aQUltMov := {}
Local _cAlVVF   := "SQLVVF"
Local _cAlVVG   := "SQLVVG"
Local _cAlVVH   := "SQLVVH"
Local _xFilVVF  := xFilial("VVF")
Local _xFilVVG  := xFilial("VVG")
Local _xFilVVH  := xFilial("VVH")
Local aRet      := {}
Local lVerBloq  := .t.
Local lMostraVei:= .t.
VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
If VAI->VAI_BLOQVE == "0"
	lVerBloq := .f. // Nao mostrar veiculos bloqueados
EndIf
If Empty(cChave)
	FS_FILTROVV(.t.,4)
	Return
EndIf
if FG_POSVEI("cChave",)
	nPos := aScan(aStruVV1,{|x| alltrim(x[5]) == alltrim(VV1->VV1_CHASSI) })
	if nPos > 0
		oLbox:nAt := nPos
		oLbox:Refresh()
	Else
		lMostraVei := .t.
		If !lVerBloq // Usuario nao pode ver os Veiculos BLOQUEADOS //
			If FindFunction("VM060VEIBLO")
				aRet := VM060VEIBLO(VV1->VV1_CHAINT,"B") // Verifica se o Veiculo esta Bloqueado, retorna registro do Bloqueio.
			    If len(aRet) > 0
					lMostraVei := .f.	
				EndIf
			EndIf
		EndIf
		If lMostraVei
			if Empty(VV1->VV1_SITVEI) .and. VV1->VV1_CODORI=="3"
				cLetra  := "V"
			EndIf
			lReserv := .f.
			If VV1->VV1_RESERV $ "1/3" // Reservado
				If !Empty(VV1->VV1_DTHVAL)
					lReserv := .t.
					dDatRes := ctod(subs(VV1->VV1_DTHVAL,1,8))
					if dDataBase > dDatRes
						lReserv := .f.
					Elseif dDataBase == dDatRes
						cHorTmp := subs(VV1->VV1_DTHVAL,10,2)+":"+subs(VV1->VV1_DTHVAL,12,2)
						if Substr(Time(),1,5) > cHorTmp
							lReserv := .f.
						Endif
					Endif
					If lReserv
						cLetra := "B"
					EndIf
				EndIf
			EndIf
			If cLetra <> "B" .and. cLetra <> "V"
				Do Case
					Case VV1->VV1_SITVEI == "2" //Transito
						cLetra := "T"
					Case VV1->VV1_SITVEI == "3" //Remessa
						cLetra := "R"
					Case VV1->VV1_SITVEI == "4" //Consignado
						cLetra := "C"
					Case VV1->VV1_SITVEI == " " // Ativo Imobilizado
						If !VV1->VV1_RESERV $ "1/3" .and. VV1->VV1_CODORI <> "3"
							cLetra := "A"
						EndIf
				EndCase
			EndIf
//			cFilAtu := VV1->VV1_STATUS
//			 Manoel / Luis - 01/03/2010 - ficou desnecessario com a utilizacao da FGX_AMOVVEI - usaremos o VV1_FILENT
//			VAE->(DbSetOrder(1))
//			VAE->(DbSeek(xFilial("VAE")+VV1->VV1_STATUS))
//			If VAE->VAE_LIBSP == "1"
//				cFilAtu += " "+VAE->VAE_DESCRI
//			EndIf
			cFilAtu := VV1->VV1_FILENT
			nPos := aScan(aNomFil,{|x| Alltrim(x[1]) == Alltrim(VV1->VV1_FILENT)})
			If nPos > 0
				cFilAtu += " "+aNomFil[nPos,2]
			Endif

			If cLetra $ "RC" // Remessa / Consignado
				cFilAtu  := ""
				aQUltMov := FM_VEIUMOV( VV1->VV1_CHASSI )
				If len(aQUltMov) > 0
					If aQUltMov[1] == "S" // SAIDA
						If aQUltMov[4] $ "67" // Retorno de Remessa/Consignado
							_cQuery := "SELECT SA2.A2_NOME FROM "+RetSqlName("SA2")+" SA2 WHERE SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD='"+aQUltMov[6]+"' AND SA2.A2_LOJA='"+aQUltMov[7]+"' AND SA2.D_E_L_E_T_=' '"
							dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlSA2 , .F., .T. )
							If !( _cAlSA2 )->( Eof() )
								cFilAtu := STR0094 +" "+aQUltMov[6]+"-"+aQUltMov[7]+" "+left(( _cAlSA2 )->( A2_NOME ),20)   //Fornecedor:
							Endif
							( _cAlSA2 )->( dbCloseArea() )
						Else
							_cQuery := "SELECT SA1.A1_NOME FROM "+RetSqlName("SA1")+" SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD='"+aQUltMov[6]+"' AND SA1.A1_LOJA='"+aQUltMov[7]+"' AND SA1.D_E_L_E_T_=' '"
							dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlSA1 , .F., .T. )
							If !( _cAlSA1 )->( Eof() )
								cFilAtu := STR0095 +" "+aQUltMov[6]+"-"+aQUltMov[7]+" "+left(( _cAlSA1 )->( A1_NOME ),20)   //Cliente:
							Endif
							( _cAlSA1 )->( dbCloseArea() )
						EndIf
					Else // ENTRADA
						If aQUltMov[4] $ "78" // Retorno de Remessa/Consignado
							_cQuery := "SELECT SA1.A1_NOME FROM "+RetSqlName("SA1")+" SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD='"+aQUltMov[6]+"' AND SA1.A1_LOJA='"+aQUltMov[7]+"' AND SA1.D_E_L_E_T_=' '"
							dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlSA1 , .F., .T. )
							If !( _cAlSA1 )->( Eof() )
								cFilAtu := STR0095 +" "+aQUltMov[6]+"-"+aQUltMov[7]+" "+left(( _cAlSA1 )->( A1_NOME ),20)  //Cliente
							Endif
							( _cAlSA1 )->( dbCloseArea() )
						Else
							_cQuery := "SELECT SA2.A2_NOME FROM "+RetSqlName("SA2")+" SA2 WHERE SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD='"+aQUltMov[6]+"' AND SA2.A2_LOJA='"+aQUltMov[7]+"' AND SA2.D_E_L_E_T_=' '"
							dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlSA2 , .F., .T. )
							If !( _cAlSA2 )->( Eof() )
								cFilAtu := STR0094 +" "+aQUltMov[6]+"-"+aQUltMov[7]+" "+left(( _cAlSA2 )->( A2_NOME ),20) //Fornecedor
							Endif
							( _cAlSA2 )->( dbCloseArea() )
						EndIf
					EndIf
				EndIf
			EndIf
			_cQuery := "SELECT SB1.B1_UCOM FROM "+RetSqlName("SB1")+" SB1 WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_GRUPO='"+cGruVei+"' AND SB1.B1_CODITE='"+VV1->VV1_CHAINT+"' AND SB1.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlSB1 , .F., .T. )
			If !( _cAlSB1 )->( Eof() )
				If !Empty(( _cAlSB1 )->( B1_UCOM ))
					nDiasEst := ( dDataBase - stod(( _cAlSB1 )->( B1_UCOM )) )
				EndIf
			EndIf
			( _cAlSB1 )->( dbCloseArea() )
			_cQuery := "SELECT VVC.VVC_DESCRI FROM "+RetSqlName("VVC")+" VVC WHERE VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR='"+VV1->VV1_CODMAR+"' AND VVC.VVC_CORVEI='"+VV1->VV1_CORVEI+"' AND VVC.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVC , .F., .T. )
			If !( _cAlVVC )->( Eof() )
				cCorVei := left(( _cAlVVC )->( VVC_DESCRI ),12)
			Endif
			( _cAlVVC )->( dbCloseArea() )
			nValorVda := 0
			If VV1->VV1_SUGVDA > 0
				nValorVda := VV1->VV1_SUGVDA
			EndIf
			If nValorVda == 0
				_cQuery := "SELECT VVP.VVP_VALTAB FROM "+RetSqlName("VVP")+" VVP WHERE VVP.VVP_FILIAL='"+xFilial("VVP")+"' AND VVP.VVP_CODMAR='"+VV1->VV1_CODMAR+"' AND VVP.VVP_MODVEI='"+VV1->VV1_MODVEI+"' AND VVP.VVP_SEGMOD='"+VV1->VV1_SEGMOD+"' AND VVP.VVP_DATPRC<='"+dtos(dDataBase)+"' AND VVP.D_E_L_E_T_=' ' ORDER BY VVP.VVP_DATPRC DESC"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVP , .F., .T. )
				If !( _cAlVVP )->( Eof() )
					nValorVda := ( _cAlVVP )->( VVP_VALTAB )
				EndIf
				( _cAlVVP )->( dbCloseArea() )
			EndIf
			VV2->(DbSetOrder(1))
			VV2->(DbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
	
			// Posicionamento no VVF
			_cQuery := "SELECT VVF.VVF_DATEMI FROM "+RetSqlName("VVF")+" VVF WHERE VVF.VVF_FILIAL='"+_xFilVVF+"' AND VVF.VVF_TRACPA='"+VV1-> VV1_TRACPA+"' AND VVF.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVF , .F., .T. )
			cDatEmiVVF := ""
			If !( _cAlVVF )->( Eof() )
				cDatEmiVVF := ( _cAlVVF )->( VVF_DATEMI)
			Endif
			( _cAlVVF )->( dbCloseArea() )
			// Posicionamento no VVG
			_cQuery := "SELECT VVG.VVG_CODIND FROM "+RetSqlName("VVG")+" VVG WHERE VVG.VVG_FILIAL='"+_xFilVVG+"' AND VVG.VVG_TRACPA='"+VV1-> VV1_TRACPA+"' AND VVG.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVG , .F., .T. )
			cCodIndVVG := ""
			If !( _cAlVVG )->( Eof() )
				cCodIndVVG := ( _cAlVVG )->( VVG_CODIND)
			Endif
			( _cAlVVG )->( dbCloseArea() )
			// Posicionamento no VVH
			_cQuery := "SELECT VVH.VVH_DIACAR FROM "+RetSqlName("VVH")+" VVH WHERE VVH.VVH_FILIAL='"+_xFilVVH+"' AND VVH.VVH_CODIND='"+cCodIndVVG+"' AND VVH.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVH , .F., .T. )
			nDiaCarVVH := 0
			If !( _cAlVVH )->( Eof() )
				nDiaCarVVH := ( _cAlVVH )->( VVH_DIACAR)
			Endif
			( _cAlVVH )->( dbCloseArea() )
	
			aStruVV1 := {} // Inserir o Veiculo pesquisado independente do resultado do FILTRO
//			aAdd(aStruVV1,{.f.,cLetra,!Empty(VV1->VV1_BITMAP),Str(nDiasEst,3),VV1->VV1_CHASSI,VV2->VV2_DESMOD,VV1->VV1_CODMAR,cCorVei,nValorVda,if(VV1->VV1_ESTVEI=="0",STR0096,STR0097),Subs(VV1->VV1_FABMOD,1,4),Subs(VV1->VV1_FABMOD,5,4),VV1->VV1_KILVEI,cFilAtu, If(!Empty(VV1->VV1_FILIAL),VV1->VV1_FILIAL,VV1->VV1_STATUS),VV1->VV1_PLAVEI,cDatEmiVVF,cCodIndVVG,nDiaCarVVH,VV1->VV1_TRACPA } )
			aAdd(aStruVV1,{.f.,cLetra,!Empty(VV1->VV1_BITMAP),Str(nDiasEst,3),VV1->VV1_CHASSI,VV2->VV2_DESMOD,VV1->VV1_CODMAR,cCorVei,nValorVda,if(VV1->VV1_ESTVEI=="0",STR0096,STR0097),Subs(VV1->VV1_FABMOD,1,4),Subs(VV1->VV1_FABMOD,5,4),VV1->VV1_KILVEI,cFilAtu, If(!Empty(VV1->VV1_FILIAL),VV1->VV1_FILIAL,VV1->VV1_FILENT),VV1->VV1_PLAVEI,cDatEmiVVF,cCodIndVVG,nDiaCarVVH,VV1->VV1_TRACPA } )
			oLbox:nAt := 1
			oLbox:SetArray(aStruVV1)
			oLbox:bLine := { || { IIf(!aStruVV1[oLbox:nAt,01],oNo,oTik),;
			IIf(aStruVV1[oLbox:nAt,02]=="N",oBranco,IIf(aStruVV1[oLbox:nAt,02]=="V",oVerde,IIf(aStruVV1[oLbox:nAt,02]=="T",oLaranja,IIf(aStruVV1[oLbox:nAt,02]=="R",oVermelho,IIf(aStruVV1[oLbox:nAt,02]=="C",oAzul,IIf(aStruVV1[oLbox:nAt,02]=="A",oPreto,oAmarelo)))))),;
			IIf(!aStruVV1[oLbox:nAt,03],oNada,oFoto),;
			aStruVV1[oLbox:nAt,15],;
			aStruVV1[oLbox:nAt,04],;
			aStruVV1[oLbox:nAt,05],;
			transform(aStruVV1[oLbox:nAt,16],VV1->(x3Picture("VV1_PLAVEI"))),;
			aStruVV1[oLbox:nAt,06],;
			aStruVV1[oLbox:nAt,07],;
			aStruVV1[oLbox:nAt,08],;
			Fg_AlinVlrs(Transform(aStruVV1[oLbox:nAt,09],"@E 9,999,999.99")),;
			aStruVV1[oLbox:nAt,10],;
			aStruVV1[oLbox:nAt,11],;
			aStruVV1[oLbox:nAt,12],;
			aStruVV1[oLbox:nAt,13],;
			aStruVV1[oLbox:nAt,14] } }
			oLBox:Refresh()
			if VV1->VV1_SITVEI <> "0"
				MsgInfo(STR0214,STR0012) //Este veiculo esta indisponivel para venda... ### Atencao
			Endif
        Else
       		MsgInfo(STR0214,STR0012) //Este veiculo esta indisponivel para venda... ### Atencao
        EndIf
	EndIf
Else
	MsgInfo(STR0215,STR0012) //Veiculo nao encontrado... ### Atencao
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LEGEN011     ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda do browse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LEGEN011()
Local nTam := len(cCadastro)
Local aRecebe := {}
Local aLegenda := {{'lbok_ocean'     ,STR0217},; //Em Aberto com Veiculo ja Vendido
{'BR_VERDE'       ,STR0216},; //Atendimento em Aberto
{'BR_PRETO'       ,STR0218},; //Atendimento Finalizado
{'BR_AMARELO'     ,STR0220},; //Pendente de Aprovacao
{'BR_LARANJA'     ,STR0221},; //Atendimento Reprovado
{'BR_BRANCO'      ,STR0222},;//Pre-Aprovado
{'BR_AZUL'        ,STR0223},; //Aprovado
{'BR_VERMELHO'    ,STR0224}} //Atendimento Cancelado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para inclusão de nova legenda              ³
//³Rafael Goncalves - 30*03*10 - FNC 6754 - A Realera          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ExistBlock("VM011LEG") )			
	aRecebe := ExecBlock("VM011LEG",.F.,.F.,{aLegenda,"L"})
	If ( ValType(aRecebe) == "A" )
		aLegenda := aClone(aRecebe)
	EndIf
EndIf

If at("[",cCadastro) > 2
	nTam := at("[",cCadastro)-1
EndIf
BrwLegenda(substr(cCadastro,1,nTam),STR0225 ,aLegenda) //Legenda

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FATDIR    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faturamento direto                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FATDIR()

Local lRet    := .f.
Local nOpca   := 0
Local nValVen := M->VV0_VALTOT
Local nValNeg := M->VV0_VALTOT - M->VV0_VALDES
Local nPerDes := M->VV0_PERDES
Local nValDes := M->VV0_VALDES
Local nPerCom := M->VV0_PERCOM
Local nValCom := M->VV0_COMFTD
Local nPerRep := M->VV0_PERREP
Local nValRep := M->VV0_REPFTD
Local nValLiq := M->VV0_VALTOT - (M->VV0_COMFTD+M->VV0_REPFTD)

DEFINE MSDIALOG oDlgFatDir TITLE OemtoAnsi(STR0226 ) FROM  02,04 TO 18.5,39 OF oMainWnd 	//Venda Direta / Frotista

@ 001,001 TO 032,137 LABEL "" OF oDlgFatDir PIXEL

@ 006,004 SAY OemToAnsi(STR0209) OF oDlgFatDir PIXEL COLOR CLR_BLUE //valor venda
@ 006,056 MSGET oValVen VAR nValVen PICTURE "@R 999,999.99" SIZE 80,4  OF oDlgFatDir PIXEL COLOR CLR_BLACK when .f.

@ 019,004 SAY OemToAnsi(STR0227) OF oDlgFatDir PIXEL COLOR CLR_BLUE  //Desconto
@ 019,056 MSGET oPerDes VAR nPerDes PICTURE "@R 999.99"     SIZE 06,4  OF oDlgFatDir PIXEL COLOR CLR_BLACK when .f.
@ 019,091 MSGET oValDes VAR nValDes PICTURE "@R 999,999.99" SIZE 45,4  OF oDlgFatDir PIXEL COLOR CLR_BLACK when .f.

@ 033,001 TO 051,137 LABEL "" OF oDlgFatDir PIXEL

@ 038,004 SAY OemToAnsi(STR0228) OF oDlgFatDir PIXEL COLOR CLR_BLUE    //Valor Negociado
@ 038,056 MSGET oValNeg VAR nValNeg PICTURE "@R 999,999.99" SIZE 80,4  OF oDlgFatDir PIXEL COLOR CLR_BLACK when .f.

@ 052,001 TO 070,137 LABEL "" OF oDlgFatDir PIXEL

@ 057,004 SAY OemToAnsi(STR0229) OF oDlgFatDir PIXEL COLOR CLR_BLUE    //Comissao
@ 057,056 MSGET oPerCom VAR nPerCom PICTURE "@R 999.99"     SIZE 06,4 VALID ((nValCom := (nValNeg/100)*nPerCom),nValLiq := nValNeg-nValCom-nValRep,.t.) OF oDlgFatDir PIXEL COLOR CLR_BLACK
@ 057,091 MSGET oValCom VAR nValCom PICTURE "@R 999,999.99" SIZE 45,4 VALID ((nPerCom := (nValCom/nValNeg)*100),nValLiq := nValNeg-nValCom-nValRep,.t.) OF oDlgFatDir PIXEL COLOR CLR_BLACK

@ 071,001 TO 089,137 LABEL "" OF oDlgFatDir PIXEL

@ 076,004 SAY OemToAnsi(STR0230) OF oDlgFatDir PIXEL COLOR CLR_BLUE    //Repasse
@ 076,056 MSGET oPerRep VAR nPerRep PICTURE "@R 999.99"     SIZE 06,4 VALID ((nValRep := (nValNeg/100)*nPerRep),nValLiq := nValNeg-nValRep-nValRep,.t.) OF oDlgFatDir PIXEL COLOR CLR_BLACK
@ 076,091 MSGET oValRep VAR nValRep PICTURE "@R 999,999.99" SIZE 45,4 VALID ((nPerRep := (nValRep/nValNeg)*100),nValLiq := nValNeg-nValRep-nValRep,.t.) OF oDlgFatDir PIXEL COLOR CLR_BLACK

@ 090,001 TO 108,137 LABEL "" OF oDlgFatDir PIXEL

@ 095,004 SAY OemToAnsi( STR0228) OF oDlgFatDir PIXEL COLOR CLR_BLUE    //Valor Negociado
@ 095,056 MSGET oValLiq VAR nValLiq PICTURE "@R 999,999.99" SIZE 80,4  OF oDlgFatDir PIXEL COLOR CLR_BLACK when .f.

@ 110,049 BUTTON oCliente PROMPT OemToAnsi(STR0121)       OF oDlgFatDir SIZE 43,11 PIXEL ACTION (lRet := .t., nOpca := 1, oDlgFatDir:End()) //ok
@ 110,094 BUTTON oCliente PROMPT OemToAnsi(STR0120) OF oDlgFatDir SIZE 43,11 PIXEL ACTION (oDlgFatDir:End())//cancelar

ACTIVATE MSDIALOG oDlgFatDir CENTER

if nOpca == 1
	M->VV0_PERCOM := nPerCom
	M->VV0_COMFTD := nValCom
	M->VV0_PERREP := nPerRep
	M->VV0_REPFTD := nValRep
	lRet := .t.
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FOTO011   ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Foto do veiculo                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FOTO011()

nPos := oLbox:nAt
cKey := aStruVV1[nPos,5]
FG_Seek("VV1","cKey",2,.f.)
if !Empty(VV1->VV1_BITMAP)
	DEFINE MSDIALOG oDlgFoto TITLE STR0231 From 10,0 to 30,44 of oMainWnd  //Foto do veiculo
	@ 001, 001 REPOSITORY oBmp NOBORDER SIZE 175, 160 OF oDlgFoto PIXEL ADJUST
	FG_BMP(ALLTRIM(VV1->VV1_BITMAP),"oBmp")
	ACTIVATE MSDIALOG oDlgFoto CENTER
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_ALIICMS³ Autor ³ Andre                 ³ Data ³ 11/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Muda aliquota de ICMS dependendo do estado do cliente p/    ³±±
±±³          ³veiculos novos                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Veiculos                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ALIICMS(cCodB1)

Local aAreaSB1 := GetArea("SB1")
Local nAliq    := M->VV0_ALIICM

if nAliq = 0
	iif(VV1->VV1_ESTVEI == "0",Val(subs(GetMv("MV_ESTICM"),at(GetMv("MV_ESTADO"),GetMv("MV_ESTICM"))+2,2)),0)
Endif

dbSelectArea("SB1")
dbSetOrder(1)
if dbSeek(xFilial("SB1")+cCodB1)
	RecLock("SB1",.f.)
//	SB1->B1_PICM := nAliq      // FCN 7542 - BOBY - TES INTELIGENTE PREENCHE AUTOMATICAMENTE NA B1 
	MsUnlock()
Endif

if M->VV0_VALMOV > 0 .and. MaFisFound('NF')
	if !Empty(M->VV0_CODTES)
		if M->VV0_ALIICM > 0
			FISREF011("IT_ALIQICM",M->VV0_ALIICM)
		Endif
		M->VV0_VBAICM := MaFisRet(,"NF_BASEICM")
		M->VV0_TOTICM := MaFisRet(,"NF_VALICM")
	Endif
Endif

SB1->(RestArea(aAreaSB1))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OPCOES011    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Opcoes do atendimento                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OPCOES011( oObj, nX, nY, oMenu , _lVerBotoes )
Default _lVerBotoes := .t.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desabilita opcoes dos itens do menu                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//AEval( oMenu:aItems, { |x| x:Disable() } )
If _lVerBotoes // Nao Mostra OPCAO quando chamado por outro fonte

	if M->VV9_STATUS <> "P"
		oMenu:aItems[1]:Disable()
	Endif
	
	if !M->VV9_STATUS $ "P/O"
		oMenu:aItems[2]:Disable()
	Endif
	
	if !Inclui
		if M->VV9_STATUS == "F" .or. M->VV9_STATUS == "T"
			oMenu:aItems[1]:Disable()
			oMenu:aItems[2]:Disable()
			oMenu:aItems[3]:Disable()
		Endif
	Endif
	
	if VV9->VV9_STATUS <> "P"
		oMenu:aItems[1]:Disable()
		oMenu:aItems[3]:Disable()
	Endif
	
	if !lAutFat
		oMenu:aItems[2]:Disable()
		oMenu:aItems[5]:Disable()
	Endif
	
	if !lLibVei
		oMenu:aItems[1]:Disable()
		oMenu:aItems[3]:Disable()
		oMenu:aItems[4]:Disable()
	Endif
	
	if !lLibVei .or. M->VV9_STATUS <> "C" .or. M->VV9_DATCAN <> dDataBase
		oMenu:aItems[4]:Disable()
	Endif

Else

	nY := -218 // Caixa menor para Consulta do Atendimento (MENOS OPCOES) chamada de outro fonte
	
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Menu PopUp                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMenu:Activate( nX, nY, oObj )

Return

Static Function MenuDef()
Local aRotina := {{	 OemtoAnsi(STR0232),"AxPesqui", 0, 1},; 		//Pesquisar
{OemtoAnsi(STR0233),"ATEND011",    0, 2},;  	//Consultar
{OemtoAnsi(STR0234),"V011INCLUIR", 0, 3},;   	//Incluir
{OemtoAnsi(STR0235),"ATEND011",    0, 4},;  	//Alterar
{OemtoAnsi(STR0236),"ATEND011",    0, 5},;  	//Excluir
{OemtoAnsi(STR0225),"LEGEN011",    0, 3 ,2,.f.},; 	//Legenda
{OemtoAnsi(STR0297),"ATEND011", 0, 7 },;			//Aprovacao
{OemtoAnsi(STR0237),"VM011_LVEI", 0, 2 }} 		//Pesq.Avancada


Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³VM011_LVEI³Autor³ Andre Luis Almeida / Rafael ³Data³ 08/10/08 ³±±
±±ÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descr.³ Levantamento dos REGISTROS pelo Chassi do Veiculo            ³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM011_LVEI()
Local nOpca := 0
Local nEmpAtu := SM0->(RecNo())
Local cEmpAtu := SM0->M0_CODIGO
Private nCkPerg1:= 1
Private aComboStat := {"","A-"+STR0216,"X-"+STR0217,"F-"+STR0218,"P-"+STR0220,"R-"+STR0221,"O-"+STR0222,"L-"+STR0223,"C-"+STR0171}  //Atendimento aberto ### Em Aberto com veiulo já vendido ### Atendimento Finalizado ### Atendimento Finalizado parcialmente ### Pendente de Aprovacao ### Atendimento Reprovado ### Pre-Aprovado ### Aprovado ### Atendimento cancelado
Private cComboStat := ""
Private dDtIniAte  := dDataBase-(day(dDataBase)-1)
Private dDtFinAte  := dDataBase
Private cNroNFI  := space(len(VV0->VV0_NUMNFI))
Private cSerNFI  := space(len(VV0->VV0_SERNFI))
Private aEmpAtu  := {}
Private aLevPesq := {{"","","",ctod(""),"",0,"","",""}}
Private cLevChas := left(space(50),len(VV1->VV1_CHASSI))
Private oVerd := LoadBitmap( GetResources() , "BR_VERDE" )
Private oOcea := LoadBitmap( GetResources() , "lbok_ocean" )
Private oPret := LoadBitmap( GetResources() , "BR_PRETO" )
Private oAmar := LoadBitmap( GetResources() , "BR_AMARELO" )
Private oLara := LoadBitmap( GetResources() , "BR_LARANJA" )
Private oBran := LoadBitmap( GetResources() , "BR_BRANCO" )
Private oAzul := LoadBitmap( GetResources() , "BR_AZUL" )
Private oVerm := LoadBitmap( GetResources() , "BR_VERMELHO" )
DbSelectArea("SM0")
DbGoTop()
While !Eof()
	if SM0->M0_CODIGO == cEmpAtu
		aAdd( aEmpAtu , { SM0->M0_CODFIL , SM0->M0_FILIAL } )
	EndIf
	DbSkip()
End
DbSelectArea("SM0")
DbGoTo(nEmpAtu)
DEFINE MSDIALOG oLevPesq TITLE OemtoAnsi(STR0238) FROM  01,05 TO 19,85 OF oMainWnd //Pesquisa Chassi/Cliente/Status/Periodo/NF/Serie

@ 000,002 RADIO oRadio1 VAR nCkPerg1 3D SIZE 50,10 PROMPT OemToAnsi(STR0239),OemToAnsi(STR0240),OemToAnsi(STR0241) OF oLevPesq PIXEL ON CHANGE (FS_COMBOTIPO(),FS_LEVVEI())  //Chassi/Cliente ### Status/Periodo ### NF/Serie

@ 009,055 MSGET oLevChas VAR cLevChas F3 "VV1" VALID (FG_POSVEI("cLevChas",),FS_LEVVEI()) PICTURE "@!" SIZE 100,08 OF oLevPesq PIXEL

@ 009,055 MSCOMBOBOX oCoboStat VAR cComboStat VALID FS_LEVVEI() SIZE 110,08 ITEMS aComboStat OF oLevPesq PIXEL COLOR CLR_BLUE
@ 010,168 SAY oTit1 VAR STR0242 SIZE 33,08 OF oLevPesq PIXEL COLOR CLR_BLUE   			//Periodo:
@ 010,227 SAY oTit2 VAR STR0243 SIZE 10,08 OF oLevPesq PIXEL COLOR CLR_BLUE    			// a

@ 010,070 SAY oTit3 VAR STR0244 SIZE 40,08 OF oLevPesq PIXEL COLOR CLR_BLUE  			//Nro NF/Serie:
@ 009,110 MSGET oNroNFI VAR cNroNFI F3 "SF2" VALID IIf(!Empty(cNroNFI),cSerNFI:=SF2->F2_SERIE,.t.) PICTURE "@!" SIZE 36,08 OF oLevPesq PIXEL
@ 009,156 MSGET oSerNFI VAR cSerNFI PICTURE "@!" SIZE 15,08 OF oLevPesq PIXEL
@ 009,190 BUTTON oOKNF PROMPT OemToAnsi(STR0121) OF oLevPesq SIZE 30,11 PIXEL ACTION (FS_LEVVEI()) //ok

@ 009,189 MSGET oDtIniAte VAR dDtIniAte VALID FS_LEVVEI() PICTURE "@D" SIZE 36,08 OF oLevPesq PIXEL
@ 009,237 MSGET oDtFinAte VAR dDtFinAte VALID FS_LEVVEI() PICTURE "@D" SIZE 36,08 OF oLevPesq PIXEL

oTit1:lVisible:=.f.
oTit2:lVisible:=.f.
oTit3:lVisible:=.f.
oOKNF:lVisible:=.f.
oCoboStat:lVisible:=.f.
oDtIniAte:lVisible:=.f.
oDtFinAte:lVisible:=.f.
oNroNFI:lVisible:=.f.
oSerNFI:lVisible:=.f.

@ 009,274 BUTTON oNo PROMPT OemToAnsi(STR0245) OF oLevPesq SIZE 40,11 PIXEL ACTION (nOpca := 0, oLevPesq:End())    //Sair
@ 029,002 LISTBOX oLbLevPesq FIELDS HEADER OemToAnsi(""),;
OemToAnsi(STR0246),;//Filial
OemToAnsi(STR0119),; //data
OemToAnsi(STR0247),;//Atendimento
OemToAnsi(STR0248),;//Nro NF
OemToAnsi(STR0249),;//Serie
OemToAnsi(STR0023),; //valor
OemToAnsi(STR0250);//Cliente
COLSIZES 10,35,35,30,25,25,40,150 SIZE 313,105 OF oLevPesq PIXEL ON DBLCLICK (nOpca := oLbLevPesq:nAt, oLevPesq:End() )
oLbLevPesq:SetArray(aLevPesq)
oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="A",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="X",oOcea,IIf(aLevPesq[oLbLevPesq:nAt,02]=="F",oPret,IIf(aLevPesq[oLbLevPesq:nAt,02]=="P",oAmar,IIf(aLevPesq[oLbLevPesq:nAt,02]=="R",oLara,IIf(aLevPesq[oLbLevPesq:nAt,02]=="O",oBran,IIf(aLevPesq[oLbLevPesq:nAt,02]=="L",oAzul,oVerm))))))),;
aLevPesq[oLbLevPesq:nAt,03],;
Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
aLevPesq[oLbLevPesq:nAt,05],;
aLevPesq[oLbLevPesq:nAt,08],;
aLevPesq[oLbLevPesq:nAt,09],;
FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
aLevPesq[oLbLevPesq:nAt,07] }}
ACTIVATE MSDIALOG oLevPesq CENTER
DbSelectArea("VV9")
if nOpca > 0 .and. Len(aLevPesq) >= nOpca
	//posiciona no registro
	DbSetOrder(1)//NUM.ATENDIMENTO
	DbSeek(left(aLevPesq[nOpca,3],2)+ aLevPesq[nOpca,1])
endif
Return

Static Function FS_LEVVEI()
Local cEmpAtu := ""
Local nEmpAtu := 0
Local cQuery := ""
Local cQAlVV0 := "SQLVV0"
Local cFilLibs := ""
Local cVV9_STATUS := ""
If Empty(cLevChas) .and. nCkPerg1 == 1 // Chassi/Cliente
	aLevPesq := {{"","","",ctod(""),"",0,"","",""}}
	oLbLevPesq:nAt := 1
	oLbLevPesq:SetArray(aLevPesq)
	oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="A",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="X",oOcea,IIf(aLevPesq[oLbLevPesq:nAt,02]=="F",oPret,IIf(aLevPesq[oLbLevPesq:nAt,02]=="P",oAmar,IIf(aLevPesq[oLbLevPesq:nAt,02]=="R",oLara,IIf(aLevPesq[oLbLevPesq:nAt,02]=="O",oBran,IIf(aLevPesq[oLbLevPesq:nAt,02]=="L",oAzul,oVerm))))))),;
	aLevPesq[oLbLevPesq:nAt,03],;
	Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
	aLevPesq[oLbLevPesq:nAt,05],;
	aLevPesq[oLbLevPesq:nAt,08],;
	aLevPesq[oLbLevPesq:nAt,09],;
	FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
	aLevPesq[oLbLevPesq:nAt,07] }}
	oLbLevPesq:SetFocus()
	oLbLevPesq:Refresh()
	Return()
EndIf
aLevPesq := {}
cQuery := "SELECT VV9.VV9_NUMATE , VV9.VV9_STATUS , VV9.VV9_DATVIS , VV0.VV0_FILIAL , VV0.VV0_NUMNFI , VV0.VV0_SERNFI , VV0.VV0_VALMOV , VV0.VV0_CODCLI , VV0.VV0_LOJA , VVA.VVA_CHAINT FROM "+RetSqlName("VV0")+" VV0 , "+RetSqlName("VV9")+" VV9 , "+RetSqlName("VVA")+" VVA WHERE "
//if !(lPedApr .or. lLibVei .or. lAutFat)
if !(lLibVei .or. lAutFat)
	cQuery += "VV9.VV9_USUARI='"+__cUserID+"' AND "
Endif
cQuery += "VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND "
If nCkPerg1 == 1 // Chassi/Cliente
	cQuery += "VVA.VVA_CHASSI='"+cLevChas+"' AND "
ElseIf nCkPerg1 == 2 // Status/Periodo
	If !Empty(cComboStat)
		If left(cComboStat,1)=="X"
			cQuery += "VV9.VV9_STATUS='A' AND "
		Else
			cQuery += "VV9.VV9_STATUS='"+left(cComboStat,1)+"' AND "
		EndIf
	EndIf
	If Empty(dDtFinAte) .or. dDtIniAte > dDtFinAte
		dDtFinAte := dDtIniAte
		oDtFinAte:Refresh()
	EndIf
	cQuery += "VV9.VV9_DATVIS>='"+dtos(dDtIniAte)+"' AND VV9.VV9_DATVIS<='"+dtos(dDtFinAte)+"' AND "
Else//If nCkPerg1 == 3 // NF/Serie
	cQuery += "VV0.VV0_NUMNFI='"+cNroNFI+"' AND VV0.VV0_SERNFI='"+cSerNFI+"' AND "
EndIf
cFilLibs := FG_FilLib(2) // retorna apenas filiais que o usuario pode acessar
If len(cFilLibs) > 1
	cQuery += "VV0.VV0_FILIAL IN ("
	While len(cFilLibs) > 1
		If SM0->M0_CODIGO == left(cFilLibs,2)
			cQuery += "'"+substr(cFilLibs,3,2)+"',"
		EndIf
		cFilLibs := substr(cFilLibs,6)
	EndDo
	cQuery := left(Alltrim(cQuery),len(Alltrim(cQuery))-1)+") AND "
EndIf
cQuery += "VV0.D_E_L_E_T_=' ' AND VVA.D_E_L_E_T_=' ' AND VV9.D_E_L_E_T_=' ' ORDER BY VV9.VV9_DATVIS , VV9.VV9_NUMATE "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0, .F., .T. )
While !( cQAlVV0 )->( Eof() )
	cVV9_STATUS := ( cQAlVV0 )->( VV9_STATUS )
	If cVV9_STATUS == "A"
		DbSelectArea("VV1")
		DbSetOrder(1)
		DbSeek( xFilial("VV1") + ( cQAlVV0 )->( VVA_CHAINT ) )
		If VV1->VV1_SITVEI == "1" // 1-Vendido
			cVV9_STATUS := "X"
		EndIf
	EndIf
	If ( cVV9_STATUS == "A" .and. left(cComboStat,1) == "X" ) .or. ( cVV9_STATUS == "X" .and. left(cComboStat,1) == "A" )
		( cQAlVV0 )->( DbSkip() )
		Loop
	EndIf
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek( xFilial("SA1") + ( cQAlVV0 )->( VV0_CODCLI ) + ( cQAlVV0 )->( VV0_LOJA ) )
	cEmpAtu := ""
	nEmpAtu := Ascan(aEmpAtu,{|x| x[1] == ( cQAlVV0 )->( VV0_FILIAL ) })
	If nEmpAtu > 0
		cEmpAtu := left(aEmpAtu[nEmpAtu,2],15)
	EndIf
	aAdd(aLevPesq,{ ( cQAlVV0 )->( VV9_NUMATE ) , cVV9_STATUS , ( cQAlVV0 )->( VV0_FILIAL )+"-"+cEmpAtu , stod(( cQAlVV0 )->( VV9_DATVIS )) , ( cQAlVV0 )->( VV9_NUMATE ) , ( cQAlVV0 )->( VV0_VALMOV ) , ( cQAlVV0 )->( VV0_CODCLI )+"-"+( cQAlVV0 )->( VV0_LOJA )+" "+SA1->A1_NOME , ( cQAlVV0 )->( VV0_NUMNFI ) , ( cQAlVV0 )->( VV0_SERNFI ) })
	( cQAlVV0 )->( DbSkip() )
End
( cQAlVV0 )->( dbCloseArea() )
If len(aLevPesq) <= 0
	If nCkPerg1 == 1 // Chassi/Cliente
		MsgAlert(STR0251+" "+cLevChas,STR0012) //Nenhum Atendimento encontrado para o Chassi/Cliente ### Atencao
	ElseIf nCkPerg1 == 2 // Status/Periodo
		MsgAlert(STR0252 ,STR0012) //Nenhum Atendimento encontrado ### Atencao
	Else//If nCkPerg1 == 3 // NF/Serie
		MsgAlert(STR0253 ,STR0012) //Nenhuma NF/Serie encontrada para os Atendimentos ### Atencao
	EndIf
	aLevPesq := {{"","","",ctod(""),"",0,"","",""}}
EndIf
oLbLevPesq:nAt := 1
oLbLevPesq:SetArray(aLevPesq)
oLbLevPesq:bLine := { || {	IIf(aLevPesq[oLbLevPesq:nAt,02]=="A",oVerd,IIf(aLevPesq[oLbLevPesq:nAt,02]=="X",oOcea,IIf(aLevPesq[oLbLevPesq:nAt,02]=="F",oPret,IIf(aLevPesq[oLbLevPesq:nAt,02]=="P",oAmar,IIf(aLevPesq[oLbLevPesq:nAt,02]=="R",oLara,IIf(aLevPesq[oLbLevPesq:nAt,02]=="O",oBran,IIf(aLevPesq[oLbLevPesq:nAt,02]=="L",oAzul,oVerm))))))),;
aLevPesq[oLbLevPesq:nAt,03],;
Transform(aLevPesq[oLbLevPesq:nAt,04],"@D"),;
aLevPesq[oLbLevPesq:nAt,05],;
aLevPesq[oLbLevPesq:nAt,08],;
aLevPesq[oLbLevPesq:nAt,09],;
FG_AlinVlrs(Transform(aLevPesq[oLbLevPesq:nAt,06],"@E 999,999,999.99")),;
aLevPesq[oLbLevPesq:nAt,07] }}
oLbLevPesq:Refresh()
Return

Static Function FS_COMBOTIPO()
oLevChas:lVisible:=.f.
oTit1:lVisible:=.f.
oTit2:lVisible:=.f.
oTit3:lVisible:=.f.
oOKNF:lVisible:=.f.
oCoboStat:lVisible:=.f.
oDtIniAte:lVisible:=.f.
oDtFinAte:lVisible:=.f.
oNroNFI:lVisible:=.f.
oSerNFI:lVisible:=.f.
If nCkPerg1 == 1 // Chassi/Cliente
	oLevChas:lVisible:=.t.
	oLevChas:SetFocus()
ElseIf nCkPerg1 == 2 // Status/Periodo
	oTit1:lVisible:=.t.
	oTit2:lVisible:=.t.
	oCoboStat:lVisible:=.t.
	oCoboStat:SetFocus()
	oDtIniAte:lVisible:=.t.
	oDtFinAte:lVisible:=.t.
Else//If nCkPerg1 == 3 // NF/Serie
	oTit3:lVisible:=.t.
	oNroNFI:lVisible:=.t.
	oNroNFI:SetFocus()
	oSerNFI:lVisible:=.t.
	oOKNF:lVisible:=.t.
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CKFiltro³ Autor ³ Andre Luis Almeida   ³ Data ³ 18/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controla o TIK/Levantamento no CheckBox ( Estoque Chao /   ³±±
±±³          ³ Virtual / Transito / Remessa / Reservado / Consignado )    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CKFiltro(cTip)
Local aAux := {}
Local cAux := ""
Local ni := 0
Local lChamaFiltro := .f.
oCkFilEst:Refresh()
oCkFilVir:Refresh()
oCkFilTra:Refresh()
oCkFilRes:Refresh()
oCkFilRem:Refresh()
oCkFilCon:Refresh()
oCkFilAti:Refresh()
If cTip == "EST"
	cAux := "N"
	If lCkFilEst
		lChamaFiltro := .t.
	EndIf
ElseIf cTip == "VIR"
	cAux := "V"
	If lCkFilVir
		lChamaFiltro := .t.
	EndIf
ElseIf cTip == "TRA"
	cAux := "T"
	If lCkFilTra
		lChamaFiltro := .t.
	EndIf
ElseIf cTip == "REM"
	cAux := "R"
	If lCkFilRem
		lChamaFiltro := .t.
	EndIf
ElseIf cTip == "RES"
	cAux := "B"
	If lCkFilRes
		lChamaFiltro := .t.
	EndIf
ElseIf cTip == "CON"
	cAux := "C"
	If lCkFilCon
		lChamaFiltro := .t.
	EndIf
ElseIf cTip == "ATI"
	cAux := "A"
	If lCkFilAti
		lChamaFiltro := .t.
	EndIf
EndIf
If lChamaFiltro
	FS_FILTROVV(.t.,4)
Else
	For ni := 1 to len(aStruVV1)
		If cAux # aStruVV1[ni,2]
			aAdd(aAux,{aStruVV1[ni,1],aStruVV1[ni,2],aStruVV1[ni,3],aStruVV1[ni,4],aStruVV1[ni,5],aStruVV1[ni,6],aStruVV1[ni,7],aStruVV1[ni,8],aStruVV1[ni,9],aStruVV1[ni,10],aStruVV1[ni,11],aStruVV1[ni,12],aStruVV1[ni,13],aStruVV1[ni,14],aStruVV1[ni,15],aStruVV1[ni,16]} )
		EndIf
	Next
	aStruVV1 := aClone(aAux)
	if len(aStruVV1) == 0
		aAdd(aStruVV1, { .f.,"N",.f.," "," "," "," "," ",0,"","","",0,"","","","","",0,"" } )
	Endif
	oLbox:nAt := 1
	oLbox:SetArray(aStruVV1)
	oLbox:bLine := { || { IIf(!aStruVV1[oLbox:nAt,01],oNo,oTik),;
	IIf(aStruVV1[oLbox:nAt,02]=="N",oBranco,IIf(aStruVV1[oLbox:nAt,02]=="V",oVerde,IIf(aStruVV1[oLbox:nAt,02]=="T",oLaranja,IIf(aStruVV1[oLbox:nAt,02]=="R",oVermelho,IIf(aStruVV1[oLbox:nAt,02]=="C",oAzul,IIf(aStruVV1[oLbox:nAt,02]=="A",oPreto,oAmarelo)))))),;
	IIf(!aStruVV1[oLbox:nAt,03],oNada,oFoto),;
	aStruVV1[oLbox:nAt,15],;
	aStruVV1[oLbox:nAt,04],;
	aStruVV1[oLbox:nAt,05],;
	aStruVV1[oLbox:nAt,06],;
	transform(aStruVV1[oLbox:nAt,16],VV1->(x3Picture("VV1_PLAVEI"))),;
	aStruVV1[oLbox:nAt,07],;
	aStruVV1[oLbox:nAt,08],;
	Fg_AlinVlrs(Transform(aStruVV1[oLbox:nAt,09],"@E 9,999,999.99")),;
	aStruVV1[oLbox:nAt,10],;
	aStruVV1[oLbox:nAt,11],;
	aStruVV1[oLbox:nAt,12],;
	aStruVV1[oLbox:nAt,13],;
	aStruVV1[oLbox:nAt,14] } }
	oLBox:Refresh()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERAPROV³ Autor ³ Andre Luis Almeida   ³ Data ³ 18/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se existe outro Atendimento ja pre-aprovado/apro- ³±±
±±³          ³ vado para o mesmo Veiculo (CHASSI)                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VERAPROV(_cNumAte)
Local lRet := .f.
Local cQuery := ""
Local cQAlVV9A := "SQLVV9A"
cQuery := "SELECT VV9.VV9_FILIAL , VV9.VV9_NUMATE FROM "+RetSqlName("VV9")+" VV9 , "+RetSqlName("VVA")+" VVA WHERE VV9.VV9_FILIAL IN "+FormatIN(FM_ALLFIL("VV9"),",")+" AND VV9.VV9_FILIAL=VVA.VVA_FILIAL AND VV9.VV9_NUMATE=VVA.VVA_NUMTRA AND "
cQuery += "VV9.VV9_NUMATE<>'"+_cNumAte+"' AND VVA.VVA_CHASSI<>'"+Space(Len(VVA->VVA_CHASSI))+"' AND VVA.VVA_CHASSI='"+M->VV0_CHASSI+"' AND VV9.VV9_STATUS IN ('L','O') AND VV9.D_E_L_E_T_=' ' AND VVA.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV9A , .F., .T. )
If !( cQAlVV9A )->( Eof() )
	lRet := .t. // Existe outro Atendimento ja aprovado para o mesmo Veiculo (CHASSI)
	MsgInfo(STR0254 +" ( "+( cQAlVV9A )->( VV9_NUMATE )+" - "+ STR0255 +" "+( cQAlVV9A )->( VV9_FILIAL )+" ) "+ STR0256 ,STR0012) // ### Existe outro Atendimento ### Filial: ### ja pre-aprovado/aprovado para o mesmo veiculo! ### Atencao
EndIf
( cQAlVV9A )->( dbCloseArea() )
DbSelectArea("VV9")
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_IteCamamºAutor  ³Manoel              º Data ³  07/06/05  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Trata delecao e inclusao de itens de campanha               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³cPar == D, Deleta registros do Arquivo VZ7                  º±±
±±º          ³cPar == I, Inclui registros no Arquivo VZ7                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fs_AtuVZ7(cPar)
local itc

DbSelectArea("VZ7")
DbSetOrder(1)

If cPar == "D"
	If DbSeek(xFilial("VZ7")+VV0->VV0_NUMTRA)
		while !eof() .and. VZ7->VZ7_FILIAL+VZ7->VZ7_NUMTRA == xFilial("VZ7")+VV0->VV0_NUMTRA
			RecLock("VZ7",.f.,.t.)
			DbDelete()
			MsUnlock()
			WriteSx2("VZ7")
			DbSelectArea("VZ7")
			DbSkip()
		Enddo
	Endif
Else // inclusao ou alteracao
	DbSelectArea("VZ7")
	if !(FG_POSVAR('VZ7_CODACV',"aHeaderIC") == 0 .or. FG_POSVAR('VZ7_ITECAM',"aHeaderIC") == 0)
	   If Left(aHeader[1,2],3) == "VZ7"  
	   	aColsIc := Aclone(aCols)
	   Endif
		for itc := 1 to Len(aColsIC)
			If aColsIC[itc,FG_POSVAR('VZ7_VALITE',"aHeaderIC")] > 0
				DbSeek(xFilial("VZ7")+VV0->VV0_NUMTRA+aColsIC[itc,FG_POSVAR('VZ7_CODACV',"aHeaderIC")]+aColsIC[itc,FG_POSVAR('VZ7_ITECAM',"aHeaderIC")])
				If Found()
					If acolsIC[itc,len(acolsIC[itc])]
						Reclock("VZ7",.f.,.t.)
						DbDelete()
						MsUnlock()
						WriteSx2("VZ7")
						Loop
					Else
						Reclock("VZ7",.f.)
					Endif
				Else
					If !acolsIC[itc,len(acolsIC[itc])]
						Reclock("VZ7",.t.)
					Else
						Loop
					Endif
				Endif
				VZ7->VZ7_FILIAL := xFilial("VZ7")
				VZ7->VZ7_NUMTRA := VV0->VV0_NUMTRA
				VZ7->VZ7_CODACV := aColsIC[itc,FG_POSVAR('VZ7_CODACV',"aHeaderIC")]
				VZ7->VZ7_ITECAM := aColsIC[itc,FG_POSVAR('VZ7_ITECAM',"aHeaderIC")]
				VZ7->VZ7_VALITE := aColsIC[itc,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]
				VZ7->VZ7_TIPORC := aColsIC[itc,FG_POSVAR('VZ7_TIPORC',"aHeaderIC")]
				VZ7->VZ7_ALTVLR := aColsIC[itc,FG_POSVAR('VZ7_ALTVLR',"aHeaderIC")]
				VZ7->VZ7_OBRIGA := aColsIC[itc,FG_POSVAR('VZ7_OBRIGA',"aHeaderIC")]
				VZ7->VZ7_AGRVLR := aColsIC[itc,FG_POSVAR('VZ7_AGRVLR',"aHeaderIC")]
				VZ7->VZ7_TIPTEM := aColsIC[itc,FG_POSVAR('VZ7_TIPTEM',"aHeaderIC")]
				VZ7->VZ7_GRUITE := aColsIC[itc,FG_POSVAR('VZ7_GRUITE',"aHeaderIC")]
				VZ7->VZ7_CODITE := aColsIC[itc,FG_POSVAR('VZ7_CODITE',"aHeaderIC")]
				VZ7->VZ7_TIPSER := aColsIC[itc,FG_POSVAR('VZ7_TIPSER',"aHeaderIC")]
				VZ7->VZ7_GRUSER := aColsIC[itc,FG_POSVAR('VZ7_GRUSER',"aHeaderIC")]
				VZ7->VZ7_CODSER := aColsIC[itc,FG_POSVAR('VZ7_CODSER',"aHeaderIC")]
				VZ7->VZ7_CODSEC := aColsIC[itc,FG_POSVAR('VZ7_CODSEC',"aHeaderIC")]
				VZ7->VZ7_DEPINT := aColsIC[itc,FG_POSVAR('VZ7_DEPINT',"aHeaderIC")]
				if VZ7->(FieldPos("VZ7_QTDENT")) <> 0
					VZ7->VZ7_QTDENT := aColsIC[itc,FG_POSVAR('VZ7_QTDENT',"aHeaderIC")]
				EndIf
				MsUnlock()
			endif
		Next
	endif
Endif
Return


Static Function FS_LevVZ7()
Local _ni, p_
Local lNlBonus := .f.
Local lJaIncIC := .f.
Local lOk := .t.

If Excluir // Somente para nao duplicar os valores do VZ7
	M->VV0_VALTOT := (M->VV0_VALMOV + M->VV0_ACESSO + M->VV0_AGREGA) - M->VV0_VALDES + Round(nAcresFin,2)
EndIf

	If nUsadoIC == 0
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria aHeader e aCols da GetDados dos Itens de Campanha       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nUsadoIC:=0
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("VZ7")
		aHeaderIC:={}
		While !Eof().And.(x3_arquivo=="VZ7")
			If X3USO(x3_usado).And.cNivel>=x3_nivel // .And. Alltrim(x3_campo) $ [VZ7_CODACV/VZ7_ITECAM/VZ7_VALITE]
				nUsadoIC:=nUsadoIC+1
				Aadd(aHeaderIC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,x3_valid,;
				x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
				wVar  := "M->"+x3_campo
				&wVar := CriaVar(x3_campo)
			Endif
			dbSkip()
		Enddo
		dbSelectArea("SX3")
		dbSetOrder(2)
		dbSeek("VZ7_NUMTRA")
		nUsadoIC:=nUsadoIC+1
		Aadd(aHeaderIC,{ "", x3_campo, x3_picture,;
		x3_tamanho, x3_decimal ,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, "V", x3_Relacao, x3_reserv } )
		
		lzz := .f.
		aColsIC:={}
		aColsIC:={Array(nUsadoIC+1)}
		aColsIC[1,nUsadoIC+1]:=.F.
		For _ni:=1 to nUsadoIC
			aColsIC[1,_ni]:=CriaVar(aHeaderIC[_ni,2])
		Next
		
	Endif
	If !Inclui
		If M->VVA_BONFAB > 0
			M->VVA_BONFAB := 0
		EndIf
		If VVA->(FieldPos("VVA_BONREG"))>0
			If M->VVA_BONREG > 0
				M->VVA_BONREG := 0
			EndIf
		EndIf
		If VVA->(FieldPos("VVA_BONCON"))>0
			If M->VVA_BONCON > 0
				M->VVA_BONCON := 0
			EndIf
		EndIf
	Endif
	M->VVA_BF := 0
	M->VVA_BR := 0
	M->VVA_BC := 0
	If Altera .or. Consultar .or. Excluir

		M->VVA_BF := VVA->VVA_BONFAB
		If VVA->(FieldPos("VVA_BONREG"))>0
			M->VVA_BR := VVA->VVA_BONREG
		EndIf
		If VVA->(FieldPos("VVA_BONCON"))>0
			M->VVA_BC := VVA->VVA_BONCON
		EndIf
//	Else
//		If !lNlBonus
//			M->VVA_BONFAB := VV1->VV1_BONFAB
//		Endif
	Endif
	M->VVA_DESCLI := 0
	M->VVA_REDVDA := 0
	M->VVA_AGREGA := 0
	lChassi := .f.
	lzz 	  := .f.
	DbSelectArea("VV2")
	dbSetOrder(1)
	DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )

	M->VV0_VALTOT := M->VV0_VALMOV + Round(nAcresFin,2)
	M->VVA_BONFAB := 0
	If VVA->(FieldPos("VVA_BONREG"))>0
		M->VVA_BONREG := 0
	EndIf
	If VVA->(FieldPos("VVA_BONCON"))>0
		M->VVA_BONCON := 0
	Endif	
	DbSelectArea("VZ7")
	DbSetOrder(1)
	If !dbSeek(xFilial("VZ7")+M->VV0_NUMTRA) .or. Empty(VZ7->VZ7_NUMTRA)
		DbSelectArea("VZ5")
		dbSetOrder(1)
		dbSeek(xFilial("VZ5"))
		while !eof() .and. xFilial("VZ5") == VZ5->VZ5_FILIAL
			lOk := .f.
			Do Case 
				Case !Empty(VZ5->VZ5_CHASSI) // Chassi
					If ( VZ5->VZ5_CHASSI ) == ( VV1->VV1_CHASSI )
						lOk := .t.
						lChassi := .t.
					EndIf
				Case !Empty(VZ5->VZ5_MODVEI) // Modelo
					If ( VZ5->VZ5_CODMAR + VZ5->VZ5_GRUMOD + VZ5->VZ5_MODVEI ) == ( VV1->VV1_CODMAR + VV2->VV2_GRUMOD + VV1->VV1_MODVEI )
						lOk := .t.
					EndIf
				Case !Empty(VZ5->VZ5_GRUMOD) // Grupo do Modelo
					If ( VZ5->VZ5_CODMAR + VZ5->VZ5_GRUMOD ) == ( VV1->VV1_CODMAR + VV2->VV2_GRUMOD )
						lOk := .t.
					EndIf
				Case !Empty(VZ5->VZ5_CODMAR) // Marca
					If ( VZ5->VZ5_CODMAR ) == ( VV1->VV1_CODMAR )
						lOk := .t.
					EndIf
				OtherWise
					lOk := .t.
			EndCase
			If lOk
				If !Empty(VZ5->VZ5_ESTVEI) .and. VZ5->VZ5_ESTVEI <> "2" // Estado do Veiculo: 0-Novos/1-Usados/2-Ambos
					If VZ5->VZ5_ESTVEI <> VV1->VV1_ESTVEI
						lOk := .f.
					EndIf
				EndIf
			EndIf
			If !lOk
				DbSelectArea("VZ5")
				DbSkip()
				Loop
			EndIf		
			lVai := .t.
			nTtLen := Len(Alltrim(VZ5->VZ5_OPCION))
			for p_ := 1 to nTtLen
				cOpcion := subs(VZ5->VZ5_OPCION,p_*3-2,3)
				If at(cOpcion,VV1->VV1_OPCFAB) == 0
					lVai := .f.
				Endif
			Next
			dDatAcao := dDataBase
			If M->VV0_TIPFAT <> "2"  //Diferente de Faturamento Direto
				If VZ5->VZ5_DATVER == "1" // data de emissao na Fabrica
					dDatAcao := VVF->VVF_DATEMI
				Endif
			Endif
			//						If dDatAcao >= VZ5->VZ5_DATINI .and. dDatAcao <= VZ5->VZ5_DATFIN .and. if(lChassi,If(Empty(VZ5->VZ5_FABMOD),.t.,VV1->VV1_FABMOD == VZ5->VZ5_FABMOD),.t.) .and. lVai .and. If(lChassi,!Empty(VZ5->VZ5_CHASSI),Empty(VZ5->VZ5_CHASSI))
			If dDatAcao >= VZ5->VZ5_DATINI .and. dDatAcao <= VZ5->VZ5_DATFIN .and. If(Empty(VZ5->VZ5_FABMOD),.t.,Alltrim(VV1->VV1_FABMOD) == Alltrim(VZ5->VZ5_FABMOD)) .and. lVai .and. If(lChassi,!Empty(VZ5->VZ5_CHASSI),Empty(VZ5->VZ5_CHASSI))
				If VZ5->(FieldPos("VZ5_BONFAB"))>0
					M->VVA_BONFAB += VZ5->VZ5_BONFAB
				EndIf
				If VVA->(FieldPos("VVA_BONREG"))>0
					M->VVA_BONREG += VZ5->VZ5_BONREG
				EndIf
				If VVA->(FieldPos("VVA_BONCON"))>0
					M->VVA_BONCON += VZ5->VZ5_BONCON
				EndIf
				lNlBonus := .t.
				DbSelectArea("VZ6")
				dbSetOrder(1)
				dbSeek(xFilial("VZ6")+VZ5->VZ5_CODACV)
				cWhile2 := 'VZ6->VZ6_FILIAL+VZ6->VZ6_CODACV == xFilial("VZ6")+VZ5->VZ5_CODACV'
				While !eof() .and. &cWhile2
				  If Empty(VZ6->VZ6_ITECAM)
						DbSelectArea("VZ6")
						DbSkip()
						Loop
				  EndIf
					If !lzz
						aColsIC := {}
					Endif
					lzz := .t.
					//// Valida se ja incluiu na aCols do VZ7 - Andre Luis Almeida 21/07/09 ////
					lJaIncIC := .f.
					For _ni:=1 to len(aColsIC)
						If aColsIC[_ni,FG_POSVAR("VZ7_ITECAM","aHeaderIC")] == VZ6->VZ6_ITECAM
							lJaIncIC := .t.
							Exit
						EndIf
					Next
					////////////////////////////////////////////////////////////////////////////
					If !lJaIncIC
						AADD(aColsIC,Array(nUsadoIC+1))
						For _ni:=1 to nUsadoIC
							aColsIC[Len(aColsIC),_ni]:=If(aHeaderIC[_ni,10] # "V",FieldGet(FieldPos(aHeaderIC[_ni,2])),CriaVar(aHeaderIC[_ni,2]))
						Next
						aColsIC[Len(aColsIC),FG_POSVAR("VZ7_CODACV","aHeaderIC")] := VZ6->VZ6_CODACV
						aColsIC[Len(aColsIC),FG_POSVAR("VZ7_ITECAM","aHeaderIC")] := VZ6->VZ6_ITECAM
						aColsIC[Len(aColsIC),FG_POSVAR("VZ7_DESCAM","aHeaderIC")] := Posicione("SX5",1,xFilial("SX5")+"V3"+VZ6->VZ6_ITECAM,"X5_DESCRI")
						aColsIC[Len(aColsIC),FG_POSVAR("VZ7_VALITE","aHeaderIC")] := VZ6->VZ6_VALITE
						aColsIC[Len(aColsIC),FG_POSVAR('VZ7_TIPORC',"aHeaderIC")] := VZ6->VZ6_TIPORC
						aColsIC[Len(aColsIC),FG_POSVAR('VZ7_ALTVLR',"aHeaderIC")] := VZ6->VZ6_ALTVLR
						aColsIC[Len(aColsIC),FG_POSVAR('VZ7_OBRIGA',"aHeaderIC")] := VZ6->VZ6_OBRIGA
						aColsIC[Len(aColsIC),FG_POSVAR('VZ7_AGRVLR',"aHeaderIC")] := VZ6->VZ6_AGRVLR
						if VZ6->(FieldPos("VZ6_TIPTIT")) <> 0
							aColsIC[Len(aColsIC),FG_POSVAR('VZ7_TIPTIT',"aHeaderIC")] := VZ6->VZ6_TIPTIT
						Endif
						aColsIC[Len(aColsIC),FG_POSVAR('VZ7_TIPTEM',"aHeaderIC")] := VZ6->VZ6_TIPTEM
						aColsIC[Len(aColsIC),FG_POSVAR('VZ7_GRUITE',"aHeaderIC")] := VZ6->VZ6_GRUITE
						aColsIC[Len(aColsIC),FG_POSVAR('VZ7_CODITE',"aHeaderIC")] := VZ6->VZ6_CODITE
						aColsIC[Len(aColsIC),FG_POSVAR('VZ7_TIPSER',"aHeaderIC")] := VZ6->VZ6_TIPSER
						aColsIC[Len(aColsIC),FG_POSVAR('VZ7_GRUSER',"aHeaderIC")] := VZ6->VZ6_GRUSER
						aColsIC[Len(aColsIC),FG_POSVAR('VZ7_CODSER',"aHeaderIC")] := VZ6->VZ6_CODSER
						aColsIC[Len(aColsIC),FG_POSVAR('VZ7_CODSEC',"aHeaderIC")] := VZ6->VZ6_CODSEC
						aColsIC[Len(aColsIC),FG_POSVAR('VZ7_DEPINT',"aHeaderIC")] := VZ6->VZ6_DEPINT
						if VZ6->(FieldPos("VZ6_QTDENT")) <> 0
							aColsIC[Len(aColsIC),FG_POSVAR('VZ7_QTDENT',"aHeaderIC")] := VZ6->VZ6_QTDENT
						EndIf
						aColsIC[Len(aColsIC),nUsadoIC+1]:=.F.
						If VZ6->VZ6_AGRVLR == "0" // Agrega valor ao Total da NF
							M->VV0_VALTOT += VZ6->VZ6_VALITE
						Elseif VZ6->VZ6_AGRVLR == "1" // Agrega valor a Despesa com Clientes
							M->VVA_DESCLI += VZ6->VZ6_VALITE
						Elseif VZ6->VZ6_AGRVLR == "2" // Agrega valor ao Redutor
							M->VVA_REDVDA += VZ6->VZ6_VALITE
						Elseif VZ6->VZ6_AGRVLR == "3" // Agrega valor a Venda Agregada
							M->VVA_AGREGA += VZ6->VZ6_VALITE
						EndIf
					EndIf
					DbSelectArea("VZ6")
					DbSkip()
				Enddo
			Endif
			DbSelectArea("VZ5")
			DbSkip()
		Enddo
	Else
		aColsIC:= {}
		While !eof() .and. VZ7->VZ7_FILIAL+VZ7->VZ7_NUMTRA == xFilial("VZ7")+M->VV0_NUMTRA
			AADD(aColsIC,Array(nUsadoIC+1))
			For _ni:=1 to nUsadoIC
				aColsIC[Len(aColsIC),_ni]:=If(aHeaderIC[_ni,10] # "V",FieldGet(FieldPos(aHeaderIC[_ni,2])),CriaVar(aHeaderIC[_ni,2]))
			Next
			aColsIC[Len(aColsIC),nUsadoIC+1]:=.F.
			If VZ7->VZ7_AGRVLR == "0" // Agrega valor ao Total da NF
				M->VV0_VALTOT += VZ7->VZ7_VALITE
			Elseif VZ7->VZ7_AGRVLR == "1" // Agrega valor a Despesa com Clientes
				M->VVA_DESCLI += VZ7->VZ7_VALITE
			Elseif VZ7->VZ7_AGRVLR == "2" // Agrega valor ao Redutor
				M->VVA_REDVDA += VZ7->VZ7_VALITE
			Elseif VZ7->VZ7_AGRVLR == "3" // Agrega valor a Venda Agregada
				M->VVA_AGREGA += VZ7->VZ7_VALITE
			EndIf
			dbskip()
		Enddo
	Endif
	
	If Len(aHeaderIC) > 0 .and. Len(aColsIC) > 0
		aCols   := aClone(aColsIC)
		aHeader := aClone(aHeaderIC)
		If Inclui
			If !Empty(aCols[1,1])
				IF n > Len(aCols)
					n := Len(aCols)
				EndIf
				oGetDadosIC:oBrowse:Refresh()
			Endif
		Endif
	Endif
	
	If M->VVA_BONFAB == 0
		M->VVA_BONFAB := M->VVA_BF
	EndIf
	If VVA->(FieldPos("VVA_BONREG"))>0
		If M->VVA_BONREG == 0
			M->VVA_BONREG := M->VVA_BR
		EndIf
	EndIf
	If VVA->(FieldPos("VVA_BONCON"))>0
		If M->VVA_BONCON == 0
			M->VVA_BONCON := M->VVA_BC
		EndIf
	EndIf

	CPOMEM011("M")

Return

Function VM011VLDENC()
If ReadVar() == "M->VV0_LOJA"
	Return FG_Seek("SA1","M->VV0_CODCLI+M->VV0_LOJA",1,.f.,"VV0_NOMCLI","A1_NREDUZ") .AND. FS_VMCLI010()
EndIf   
If ReadVar() == "M->VVA_VALDES"
	Return FG_ATRVAL("VVF_VBAICM","M->VVF_VALMOV-M->VVF_VALDES").and.Ve010Icms()
EndIf
Return .t.	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_INCORC ³ Autor ³ Andre Luis Almeida   ³ Data ³ 16/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inclusao de Orcamento utilizando Acao de Vendas (VZ7)      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_INCORC()
Local lRet     := .t.
Local ni       := 0
Local cTipOrc  := "0"
Local cTipTem  := ""
Local lVO6_VALSER := VO6->(FieldPos("VO6_VALSER")) > 0
Local nTemPad  := 0
Local nValHor  := 0
Local nTotOrc  := 0
//
For ni := 1 to Len(aColsIC)
	If !aColsIC[ni,len(aColsIC[ni])]
		If cTipOrc == "0" .or. aColsIC[ni,FG_POSVAR("VZ7_TIPORC","aHeaderIC")] == "2"
			cTipOrc := aColsIC[ni,FG_POSVAR("VZ7_TIPORC","aHeaderIC")]
		EndIf
		If Empty(cTipTem) .and. aColsIC[ni,FG_POSVAR("VZ7_TIPORC","aHeaderIC")] == "2"
			cTipTem := aColsIC[ni,FG_POSVAR("VZ7_TIPTEM","aHeaderIC")]
		EndIf
		If aColsIC[ni,FG_POSVAR("VZ7_TIPORC","aHeaderIC")] == "1" .and. !Empty(aColsIC[ni,FG_POSVAR("VZ7_CODSER","aHeaderIC")])
			cTipOrc := "2" // Orcamento Oficina
		EndIf
	EndIf
Next
//
If cTipOrc <> "0" // Gerar Orcamento
	// Criar novo VS1 //
	DbSelectArea("VS1")
	If !RecLock("VS1",.T.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		Return(lRet)
	EndIf
	VS1->VS1_FILIAL := xFilial("VS1")
	VS1->VS1_NUMORC := GetSXENum("VS1","VS1_NUMORC")
	VS1->VS1_TIPORC := cTipOrc // 1-Pecas / 2-Oficina
	VS1->VS1_CHAINT := VV1->VV1_CHAINT
	VS1->VS1_CLIFAT := VV9->VV9_CODCLI
	VS1->VS1_LOJA   := VV9->VV9_LOJA
	VS1->VS1_NCLIFT := VV9->VV9_NOMVIS
	VS1->VS1_CODMAR := VV1->VV1_CODMAR
	VS1->VS1_DATORC := dDataBase
	VS1->VS1_DATVAL := dDataBase+GetNewPar("MV_DTLIMIT",0)
	VS1->VS1_HORORC := val(subs(time(),1,2)+subs(time(),4,2))
	VS1->VS1_TIPTEM := cTipTem
	VS1->VS1_TIPVEN := "1"
	VS1->VS1_NOROUT := "1"
	If VS1->(FieldPos("VS1_PGTFRE")) <> 0
		VS1->VS1_PGTFRE := "2"
	EndIf
	VS1->VS1_FORMUL := &(GETNEWPAR("MV_FMLPECA",""))
	VS1->VS1_CODVEN := VV0->VV0_CODVEN
	If VS1->(FieldPos("VS1_ALTORC")) <> 0
		VS1->VS1_ALTORC := "0" // Nao
	EndIf
	ConfirmSX8()
	MsUnLock()
	If lRet
		For ni := 1 to Len(aColsIC)
			If !aColsIC[ni,len(aColsIC[ni])]
				If aColsIC[ni,FG_POSVAR("VZ7_TIPORC","aHeaderIC")] <> "0" // Gerar Orcamento (1=Pecas/2=Oficina)
					If !Empty(aColsIC[ni,FG_POSVAR("VZ7_CODITE","aHeaderIC")])
						DbSelectArea("SB1")
						DbSetOrder(7)
						DbSeek(xFilial("SB1")+ aColsIC[ni,FG_POSVAR("VZ7_GRUITE","aHeaderIC")] + aColsIC[ni,FG_POSVAR("VZ7_CODITE","aHeaderIC")] )
						DbSelectArea("VS3")
			         If !RecLock("VS3",.t.)
			            Help("  ",1,"REGNLOCK")
			            lRet := .f.
			            Return(lRet)
			         EndIf
						VS3->VS3_FILIAL := xFilial("VS3")
						VS3->VS3_NUMORC := VS1->VS1_NUMORC
						VS3->VS3_GRUITE := aColsIC[ni,FG_POSVAR("VZ7_GRUITE","aHeaderIC")]
						VS3->VS3_CODITE := aColsIC[ni,FG_POSVAR("VZ7_CODITE","aHeaderIC")]
						VS3->VS3_LOCAL  := SB1->B1_LOCPAD
						VS3->VS3_FORMUL := VS1->VS1_FORMUL
						VS3->VS3_CODTES := SB1->B1_TS
						VS3->VS3_QTDITE := 1
						VS3->VS3_VALPEC := aColsIC[ni,FG_POSVAR("VZ7_VALITE","aHeaderIC")]
						VS3->VS3_VALTOT := aColsIC[ni,FG_POSVAR("VZ7_VALITE","aHeaderIC")]
						MsUnLock()
						nTotOrc += VS3->VS3_VALTOT
					EndIf
					If !Empty(aColsIC[ni,FG_POSVAR("VZ7_CODSER","aHeaderIC")])
						DbSelectArea("VO6")
						DbSetOrder(2)
						DbSeek(xFilial("VO6")+FG_MARSRV(VV1->VV1_CODMAR,aColsIC[ni,FG_POSVAR("VZ7_CODSER","aHeaderIC")])+aColsIC[ni,FG_POSVAR("VZ7_CODSER","aHeaderIC")]) 
						nTemPad := FG_TemPad(VV1->VV1_CHAINT,aColsIC[ni,FG_POSVAR("VZ7_CODSER","aHeaderIC")],"4",,VV1->VV1_CODMAR)
						DbSelectArea("VOK")
						DbSetOrder(1)
						DbSeek(xFilial("VOK")+aColsIC[ni,FG_POSVAR("VZ7_TIPSER","aHeaderIC")]) 
						nValHor := If(VOK->VOK_INCMOB$"0/2/5",0,FG_VALHOR(cTipTem,dDataBase))
						DbSelectArea("VS4")
			         If !RecLock("VS4",.t.)
			            Help("  ",1,"REGNLOCK")
			            lRet := .f.
			            Return(lRet)
			         EndIf
						VS4->VS4_FILIAL := xFilial("VS4")
						VS4->VS4_NUMORC := VS1->VS1_NUMORC
						VS4->VS4_TIPSER := aColsIC[ni,FG_POSVAR("VZ7_TIPSER","aHeaderIC")]
						VS4->VS4_GRUSER := VO6->VO6_GRUSER
						VS4->VS4_CODSER := aColsIC[ni,FG_POSVAR("VZ7_CODSER","aHeaderIC")]
						VS4->VS4_TEMPAD := nTemPad
						VS4->VS4_CODSEC := aColsIC[ni,FG_POSVAR("VZ7_CODSEC","aHeaderIC")]
						If lVO6_VALSER
							If VO6->VO6_VALSER > 0 // Valor Fixo para o Servico
								VS4->VS4_VALSER := VO6->VO6_VALSER
								VS4->VS4_VALTOT := VO6->VO6_VALSER
							EndIf
						EndIf
						VS4->VS4_VALHOR := nValHor
						If VS4->VS4_VALSER <= 0
							VS4->VS4_VALSER := VS4->VS4_VALHOR
							VS4->VS4_VALTOT := ( VS4->VS4_TEMPAD / 100 ) * VS4->VS4_VALHOR
						EndIf
						MsUnLock()
						nTotOrc += VS4->VS4_VALTOT
					EndIf
				EndIf
			EndIf
		Next
	   // Alterar SEQUEN do VS3 //
	   ni := 0
		DbSelectArea("VS3")
		DbSetOrder(3)
		DbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
		While !Eof() .and. VS3->VS3_FILIAL+VS3->VS3_NUMORC == xFilial("VS3")+VS1->VS1_NUMORC
			ni++
		   If !RecLock("VS3",.f.)
		      Help("  ",1,"REGNLOCK")
		      lRet := .f.
            Return(lRet)
		   EndIf
			VS3->VS3_SEQUEN := strzero(ni,3)
			MsUnLock()
	      DbSelectArea("VS3")
	      DbSkip()
		EndDo
	   // Alterar SEQUEN do VS4 //
		ni := 0
		DbSelectArea("VS4")
		DbSetOrder(3)
		DbSeek(xFilial("VS4")+VS1->VS1_NUMORC)
		While !Eof() .and. VS4->VS4_FILIAL+VS4->VS4_NUMORC == xFilial("VS4")+VS1->VS1_NUMORC
			ni++
		   If !RecLock("VS4",.f.)
		      Help("  ",1,"REGNLOCK")
		      lRet := .f.
            Return(lRet)
			EndIf
			VS4->VS4_SEQUEN := strzero(ni,3)
			MsUnLock()
			DbSelectArea("VS4")
			DbSkip()
		EndDo
		// Totaliza Orcamento //
		DbSelectArea("VS1")
	   RecLock("VS1",.f.)
			VS1->VS1_VTOTNF := nTotOrc
		MsUnLock()
	EndIf
EndIf
//
Return(lRet)

Function FS_ValIte()
If FunName() == "VEIVM011"
	If ReadVar() == "M->VZ7_ITECAM"
		aCols[n,FG_POSVAR("VZ7_DESCAM","aHeaderIC")] := Posicione("SX5",1,xFilial("SX5")+"V3"+M->VZ7_ITECAM,"X5_DESCRI")
	EndIf
	If aCols[n,FG_POSVAR('VZ7_ALTVLR',"aHeaderIC")] == "0"
		Return .f.
	EndIf
EndIf
Return .t.

Function FM_VALIDVAL(cPar)
If cPar == "VZ6"
	If M->VZ6_VALITE == 0
		MsgInfo(STR0267,STR0012)
		Return .f.
	Endif
Else // VZ7
	If M->VZ7_VALITE == 0
		MsgInfo(STR0267,STR0012)
		Return .f.
	Endif
Endif
Return .t.

// Valida Valor do VS9 com Tarefas do Atendimento //
Function VM011VS9VLR()
Local lRet := .t.
If FunName() == "VEIVM011"
	If VS9->(FieldPos("VS9_SEQTAR")) <> 0
		If !Empty(M->VS9_SEQTAR)
			DbSelectArea("VAY")
			DbSetOrder(1)
			If DbSeek(xFilial("VAY")+M->VS9_SEQTAR)
				If VAY->VAY_STATUS == "2" // Aprovado com restricoes
					If VAY->VAY_VALLIB < M->VS9_VALPAG
						lRet := .f.
						MsgStop(STR0269,STR0012) // Valor digitado maior que o valor liberado pela tarefa. / Atencao
						If FindFunction("VEIVM130")
							VEIVM130(M->VV0_NUMTRA)
						EndIf
					EndIf
				Else
					lRet := .f.
					MsgStop(STR0270,STR0012) // Impossivel alterar o valor. E' necesario excluir o registro e incluir um novo historico de negociacao. / Atencao
				EndIf
			EndIf
		EndIf
	EndIf
	DbSelectArea("VS9")
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CONDPGFI³ Autor ³ Andre Luis Almeida   ³ Data ³ 05/09/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela com Condicoes de Pagamento F&I                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _nVlr - Valor para Calculo                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Vetor igual aTabFAI                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CONDPGFI(_nVlr)
Local nPos := 0
Local cFIBcoTab := GetNewPar("MV_FIBCTBV","               ")
Private nFIValor  := _nVlr
Private aFIValor  := {}
If !Empty(cFIBcoTab) .and. nFIValor > 0 .and. FunName() == "VEIVM011" .and. ((M->VV0_VALMOV+M->VV0_VALTRO) <= M->VV0_VALTOT)
	DbSelectArea("VAS")
	If FS_LEVANTFI(0,cFIBcoTab)
		DEFINE MSDIALOG oCONDPGFI TITLE OemtoAnsi(VAR->VAR_NOMBCO) FROM 01,01 TO 30,30 OF oMainWnd 
			@ 004,005 SAY STR0272 SIZE 50,08 OF oCONDPGFI PIXEL COLOR CLR_BLUE // "Valor Financiado:"
			@ 002,050 MSGET oFIVlr VAR nFIValor PICTURE "@E 99,999,999.99" VALID (nFIValor>0 .and. FS_LEVANTFI(1,cFIBcoTab)) SIZE 62,09 OF oCONDPGFI PIXEL COLOR CLR_BLACK
			@ 015,001 LISTBOX oFILBoxFAI FIELDS HEADER OemToAnsi(STR0273),OemToAnsi(STR0274) COLSIZES 30,50 SIZE 114,188 OF oCONDPGFI PIXEL ON DBLCLICK (nPos:=oFILBoxFAI:nAt,oCONDPGFI:End()) // "Qtde" / "Valor das Parcelas"
			oFILBoxFAI:SetArray(aFIValor)
			oFILBoxFAI:bLine := { || { Transform(aFIValor[oFILBoxFAI:nAt,01],"@R 999999 X"),FG_AlinVlrs(Transform(aFIValor[oFILBoxFAI:nAt,02],"@E 99,999,999.99")) }}
			@ 206,038 BUTTON oFIAvancar PROMPT OemToAnsi(STR0058) OF oCONDPGFI SIZE 44,10 PIXEL ACTION (oCONDPGFI:End()) //Avancar
		ACTIVATE MSDIALOG oCONDPGFI CENTER
		If nPos > 0
//			M->VV0_VALRES := M->VV0_VALTOT-M->VV0_TOTENT-nFIValor
			Return(FS_FIDBLCLICK(nPos))	
		Else
			M->VV0_VALRES := M->VV0_VALTOT-M->VV0_TOTENT-M->VV0_VALFIN
		EndIf
	EndIf
EndIf
Return({})

Static Function FS_LEVANTFI(nTp,cFIBcoTab) // Faz Levantamento dos Valores Financiamento
Local lRet := .f.
Local cBcox := ""
Local cTab := ""
Local nValPar := 0
Local nValFin := 0
cBcox := substr(cFIBcoTab,1,len(VAS->VAS_CODBCO))
cTab := substr(cFIBcoTab,len(cBcox)+1,len(VAS->VAS_CODIGO))
aFIValor := {}
DbSelectArea("VAR")
DbSetOrder(1)
If DbSeek(xFilial("VAR")+cBcox+cTab)
	DbSelectArea("VAS")
	DbSetOrder(1)
	DbSeek(xFilial("VAS")+cBcox)
	While !Eof() .and. VAS->VAS_FILIAL == xFilial("VAS") .and. VAS->VAS_CODBCO==cBcox
		If FS_ADMFAI(.F.,.t.)
			nValFin := nFIValor
			If VAR->VAR_TACFIN == "1"
				nValFin += VAS->VAS_VLRTAC
			EndIf	
			If VAS->VAS_COEFIC > 0
				nValPar := nValFin * VAS->VAS_COEFIC
			EndIf	
			aadd(aFIValor,{Val(VAS->VAS_QTDPAR),nValPar,VAR->VAR_CODBCO+"-"+Left(VAR->VAR_NOMBCO,14),VAR->VAR_CODIGO,VAR->VAR_DESCOD,Val(VAS->VAS_QTDPAR),VAS->VAS_COEFIC,nValPar,Iif(VAR->(FieldPos("VAR_BCOCLI"))>0,VAR->VAR_BCOCLI+VAR->VAR_BCOLOJ,Space(8)),VAS->VAS_PERRET,VAS->(RecNo())})
			lRet := .t.
		EndIf
		DbSelectArea("VAS")
		DbSkip()
	EndDo	
EndIf
If len(aFIValor) > 0
	Asort(aFIValor,,,{|x,y| x[1] < y[1] })
	If nTp > 0
		oFILBoxFAI:SetArray(aFIValor)
		oFILBoxFAI:bLine := { || { Transform(aFIValor[oFILBoxFAI:nAt,01],"@R 999999 X"),FG_AlinVlrs(Transform(aFIValor[oFILBoxFAI:nAt,02],"@E 99,999,999.99")) }}
		oFILBoxFAI:Refresh()
	Endif
EndIf
Return(lRet)

Static Function FS_FIDBLCLICK(nPos) // Duplo Click no Financiamento desejado
Local aRetorno:={}
aadd(aRetorno,{nFIValor,aFIValor[nPos,3],aFIValor[nPos,4],aFIValor[nPos,5],aFIValor[nPos,6],aFIValor[nPos,7],aFIValor[nPos,8],aFIValor[nPos,9],aFIValor[nPos,10]})
Return(aClone(aRetorno))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_AtuDadFI³ Autor ³ Manoel               ³ Data ³ 07/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza dados referentes ao F&I                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ sem parametros                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ sem retorno			                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AtuDadFI()

If FunName() != "VEIVM011"
	Return
Endif

//M->VV0_FORPAG := RetCondVei()
M->VV0_CODBCO := Left(aTabFAI[1,02],3)
M->VV0_TABFAI := aTabFAI[1,03]
M->VV0_DESFAI := aTabFAI[1,04]
M->VV0_COEFIC := aTabFAI[1,06]
M->VV0_VALPAR := aTabFAI[1,07]

DbSelectArea("VSA")
DbSetorder(0)
Dbgotop()
cTipPgVs9 := ""
cDesPgVs9 := ""
While !eof()
		If !Empty(VSA->VSA_CODCLI) .and. VSA->VSA_CODCLI+VSA->VSA_LOJA == aTabFai[1,8]
		   cTipPgVs9 := VSA->VSA_TIPPAG
		   cDesPgVs9 := VSA->VSA_DESPAG
		   exit
		Endif                          
		DbSkip()
Enddo
	
nPos := aScan(aColsC,{|x| x[1] == cTipPgVs9 })

If nPos == 0
   If Len(aColsC) == 0 .or. (Len(aColsC) == 1 .and. !Empty(aColsC[1,1]))
		AADD(aColsC,Array(nUsadoC+1))
	Endif		
	aColsC[Len(aColsC),FG_POSVAR("VS9_TIPPAG","aHeaderC")] := cTipPgVs9
	aColsC[Len(aColsC),FG_POSVAR("VS9_DESPAG","aHeaderC")] := cDesPgVs9
	aColsC[Len(aColsC),FG_POSVAR("VS9_DATPAG","aHeaderC")] := dDataBase
	aColsC[Len(aColsC),FG_POSVAR("VS9_VALPAG","aHeaderC")] := aTabFAI[1,1]
	aColsC[Len(aColsC),FG_POSVAR("VS9_SEQUEN","aHeaderC")] := StrZero(Len(aColsC),2)
	aColsC[Len(aColsC),nUsadoC+1] := .F.	
Else
   If !aColsC[nPos,Len(aColsC[nPos])]
		aColsC[nPos,FG_POSVAR("VS9_VALPAG","aHeaderC")] := aTabFAI[1,1]
	Else
	   If Len(aColsC) > 1 .or. (Len(aColsC) == 1 .and. !Empty(aColsC[1,1]))
			AADD(aColsC,Array(nUsadoC+1))
		Endif		
		aColsC[Len(aColsC),FG_POSVAR("VS9_TIPPAG","aHeaderC")] := cTipPgVs9
		aColsC[Len(aColsC),FG_POSVAR("VS9_DESPAG","aHeaderC")] := cDesPgVs9
		aColsC[Len(aColsC),FG_POSVAR("VS9_DATPAG","aHeaderC")] := dDataBase
		aColsC[Len(aColsC),FG_POSVAR("VS9_VALPAG","aHeaderC")] := aTabFAI[1,1]
		aColsC[Len(aColsC),FG_POSVAR("VS9_SEQUEN","aHeaderC")] := StrZero(Len(aColsC),2)
		aColsC[Len(aColsC),nUsadoC+1] := .F.	
	Endif
Endif                                           
M->VV0_VALFIN := aTabFAI[1,1]
M->VV0_VALRES := M->VV0_VALTOT - M->VV0_TOTENT - M->VV0_VALFIN
//aCols := aclone(aColsC)
//aHeader := aclone(aHeaderC)
oGetMGet3:Refresh()
oGetMGet3:SetFocus()
oGetCondicao:oBrowse:Refresh()
lJaCal011 := .f.
FS_CALC011()
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_AtVMerc ³ Autor ³ Manoel               ³ Data ³ 07/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza valor da Mercadoria (Veiculo). Somando Agregados /³±±
±±³          ³ Itens de Campanha                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ sem parametros                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ Valor da Mercadoria					                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ATVMERC()

Local nValor      := M->VV0_VALMOV
Local aHeaderSlv  := {}
Local aColsSlv    := {}
Local it_		  := 0

If FunName() != "VEIVM011"
	Return(nValor)
Endif

aHeaderSlv  := aClone(aHeader)
aColsSlv    := aClone(aCols)

aHeader  := aClone(aHeaderIC)
aCols    := aClone(aColsIC)
For it_ := 1 to Len(aCols)
	If !aCols[it_,len(aCols[it_])]
	   If aCols[it_,FG_POSVAR('VZ7_AGRVLR',"aHeaderIC")] == "0" // Agrega valor ao Total da NF
			nValor += aCols[it_,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]
		EndIf
	Endif
Next
aHeader  := aClone(aHeaderSlv)
aCols    := aClone(aColsSlv)

Return(nValor)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VM011_Apr  ³ Autor ³ Manoel               ³ Data ³ 13/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para Reprovacao/Aprovacao do Atendimento de Veiculos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ sem parametros                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ sem retorno			                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VM011_Apr(lVerSTATUS)

Local bCampo        := { |nCPO| Field(nCPO) }
Local ii            := 0
Local cont 		     := 0
Local cGrupVei      := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Local cEmpresa      := ""
Local cCliente      := ""
Local cProposta     := ""
Local cStatus       := ""
Local cNMF := Alltrim(GetMv("MV_INDMFT"))
Private cTipAva     := "1" //Veiculos
Private cCpoDiv     := "    1"
Private aStru       := {}
Private aErrAva     := {}
Private cSimVda     := "V"
Private cMoedCor    := cOutMoed := GetMv("MV_SIMB1")
Private cCodMap     := GetNewPar("MV_MAPAPR","010")
Private cOutMoed    := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
Private cSimOMoe    := Val(Alltrim(GetMv("MV_INDMFT")))
Private Inclui      := .f. // Variavel INTERNA utilizada no VEIVM011
Private Altera      := .f. // Variavel INTERNA utilizada no VEIVM011
Private lEmiNfi     := .t. // Variavel INTERNA utilizada no VEIVM011
Private lNegPag     := .t. // Variavel INTERNA utilizada no VEIVM011
Private lLibVei     := .f. // Variavel INTERNA utilizada no VEIVM011
Private lAutFat     := .f. // Variavel INTERNA utilizada no VEIVM011
Private _lVerBotoes := .f. // Variavel INTERNA utilizada no VEIVM011
Private cCampo      := ""
Private nOpc        := 2
Private bFiltraBrw  := {|| Nil}
Private aCampos     := {}
Private aMostraAva  := {}

DEFAULT lVerSTATUS := .t.
DEFINE FONT oFLib01 NAME "Arial" SIZE 09,13 BOLD
DEFINE FONT oFLib02 NAME "Arial" SIZE 07,13 BOLD

lLevCam := .f.
dbSelectArea("VV9")
For cont := 1 TO FCount()
	M->&(EVAL(bCampo,cont)) := FieldGet(cont)
Next
If lVerSTATUS .and. !VV9->VV9_STATUS $ "P/O"
   MsgInfo(STR0278,STR0012) //"Esta opcao so' e' permitida para Atendimentos PENDENTES DE APROVACAO ou PRE-APROVADOS!")
   return
Endif
dbSelectArea("VAI")
dbSetOrder(4)
dbSeek(xFilial("VAI")+__cUserID)

If !VAI->VAI_LIBVEI == "1"
   MsgInfo(STR0279,STR0012) //"Esta opcao so' e' permitida para usuarios com autorizacao para LIBERAR venda de Veiculos (VAI->VAI_LIBVEI == '1')")
   return
Endif

dbSelectarea("VV0")
dbSetOrder(1)
dbSeek(xFilial("VV0")+M->VV9_NUMATE)
For cont := 1 TO FCount()
	M->&(EVAL(bCampo,cont)) := FieldGet(cont)
Next
dbSelectarea("VVA")
dbSetOrder(1)
dbSeek(xFilial("VVA")+M->VV9_NUMATE)
For cont := 1 TO FCount()
	M->&(EVAL(bCampo,cont)) := FieldGet(cont)
Next
if VV0->(FieldPos("VV0_FILCHA")) <> 0
	cFilSelVV1 := VV0->VV0_FILCHA
	cFilAntVV1 := VV0->VV0_FILCHA
Endif
if !Empty(VVA->VVA_CHASSI)
	dbSelectarea("VV1")
	dbSetOrder(2)
	dbSeek(cFilSelVV1+VVA->VVA_CHASSI)
Endif
M->VV0_CHASSI := VVA->VVA_CHASSI
M->VV0_CHAINT := VVA->VVA_CHAINT

VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))

VVC->(DbSetOrder(1))
VVC->(DbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))

SB1->(dbSetOrder(7))
SB1->(dbSeek(xFilial("SB1")+cGrupVei+VV1->VV1_CHAINT))

dbSelectArea("VS5")
dbSetOrder(1)
if !dbSeek(xFilial("VS5")+cCodMap)
	MsgInfo(STR0196 ,STR0012) //Mapa de veiculos nao cadastrado! ### Atencao
	Return .f.
Endif

dbSelectArea("VOQ")
dbSetOrder(1)
if !dbSeek(xFilial("VOQ")+cCodMap)
	MsgInfo(STR0196 ,STR0012) //Mapa de veiculos nao cadastrado! ### Atencao
	Return .f.
Endif

While !Eof() .and. VOQ->VOQ_FILIAL == xFilial("VOQ")
	
	if !(M->VV0_TIPFAT $ VOQ_TIPFAT)
		dbSkip()
		Loop
	Endif
	If VOQ_INDATI # "1" // Sim
		dbSkip()
		Loop
	Endif
	If VOQ_CODMAP # cCodMap
		exit
	Endif
	
	cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
	aadd(aStru,{ M->VV0_NUMTRA,VV1->VV1_TRACPA,SB1->B1_COD,;
	VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VV1->VV1_CHASSI,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,M->VV0_DATMOV,0,0,VOQ_CTATOT})
	
	dbSkip()
	
Enddo

if M->VV0_TOTICM == 0
	INIFIS011()
	FISCAL011()
Endif

//Simula a gravacao para apresentacao do mapa
CPOMEM011("")

//Calcula os valores do vetor
FG_CalcVlrs(aStru)

//Executa o mapa de avaliacao
//FG_ResAva(cOutMoed,3,"V","","VEIVM010")

If Empty(aStru[1,1])    
   MsgInfo(STR0280,STR0012) //"Nao ha dados a serem consultados!"
   return
Endif    

DbSelectArea("SM2")
Set SoftSeek on
DbSeek(aStru[1,19])
If &("SM2->M2_MOEDA"+cNMF) == 0
	dbskip(-1)
EndIf

aMostraAva := {}
For ii := 1 to Len(aStru)
   aadd(aMostraAva,{aStru[ii,5],aStru[ii,9],aStru[ii,9]/&("SM2->M2_MOEDA"+cNMF),aStru[ii,10],aStru[ii,6],aStru[ii,4],.t.})	
Next
aMosAvaSv := aClone(aMostraAva)

cEmpresa  := SM0->M0_CODIGO + " / " + SM0->M0_CODFIL + " - " + SM0->M0_FILIAL
dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+M->VV9_CODCLI+M->VV9_LOJA)
cCliente  := SA1->A1_COD+"-"+SA1->A1_LOJA+" "+SA1->A1_NOME

If VV9->VV9_STATUS == "O"
	cStatus := STR0222 //"Pre-Aprovado"
Else//If VV9->VV9_STATUS == "P"
	cStatus := STR0220 //"Pendente de Aprovacao"
Endif
cProposta := M->VV9_NUMATE+" - "+Dtoc(M->VV0_DATMOV)+" - "+cStatus
nPComVda  := (M->VVA_COMVDE/M->VV0_VALTOT)*100
nVComVda  := M->VVA_COMVDE
nPDspFin  := GetNewPar("MV_PDSPFIV",4) //
nVDspFin  := (nPDspFin*M->VV0_VALTOT)/100
nPComRes  := 0
nVComRes  := 0
cMoedCor := GetMv("MV_SIMB1")                  
//cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
cCombust := ""
If VV1->VV1_COMVEI=="0"
	cCombust := STR0173 // "Gasolina"
Elseif VV1->VV1_COMVEI=="1"
	cCombust := STR0174 // "Alcool"
Elseif VV1->VV1_COMVEI=="2"
	cCombust := STR0175 // "Diesel"
Elseif VV1->VV1_COMVEI=="3"
	cCombust := STR0176 // "Gas Natural"
Elseif VV1->VV1_COMVEI=="4"
	cCombust := STR0281 // "Alcool/Gasolina"
Elseif VV1->VV1_COMVEI=="5"
	cCombust := STR0282 // "Alcool/Gasolina/GNV"
Elseif VV1->VV1_COMVEI=="9"
	cCombust := STR0177 // "Sem Combustivel"
Endif

cModVeiApr  := Alltrim(VV2->VV2_MODVEI) + " - " + VV2->VV2_DESMOD
cAnoModApr  := Subs(VV1->VV1_FABMOD,1,4) + "/" + Subs(VV1->VV1_FABMOD,5,4)

lAprovacao := .t.

DEFINE MSDIALOG oAnaCus FROM 000,000 TO 038,100 TITLE STR0283 OF oMainWnd //"Aprovacao (Analise de Custos)"
	@ 001,003 TO 042,200 LABEL ("") OF oAnaCus PIXEL
  	@ 005,005 SAY STR0284 SIZE 40,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Empresa"  
   @ 005,050 MSGET oObj1 VAR cEmpresa   SIZE 145,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.
  	@ 017,005 SAY STR0250 SIZE 40,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Cliente"  
   @ 017,050 MSGET oObj2 VAR cCliente   SIZE 145,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.
  	@ 029,005 SAY STR0285 SIZE 40,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Proposta" 
   @ 029,050 MSGET oObj3 VAR cProposta  SIZE 145,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.

	@ 001,203 TO 042,393 LABEL ("") OF oAnaCus PIXEL
  	@ 005,207 SAY STR0286 SIZE 70,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Comissao Venda" 
   @ 005,280 MSGET oPComVda VAR transform(nPComVda,"@R 999.99%") SIZE 05,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02  when .f.
  	@ 005,322 SAY cMoedCor SIZE 10,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib02
   @ 005,335 MSGET oVComVda VAR nVComVda Pict "@E 999,999.99" SIZE 55,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02  when .f.
  	@ 017,207 SAY STR0287 SIZE 70,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01// "Despesa Adm" 
   @ 017,280 MSGET oPDspFin VAR Transform(nPDspFin,"@R 999.99%") SIZE 05,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02  when .f.
  	@ 017,322 SAY cMoedCor SIZE 10,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib02
  	@ 017,335 MSGET oVDspFin VAR nVDspFin Pict "@E 999,999.99" SIZE 55,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02  when .f.
  	@ 029,207 SAY STR0288 SIZE 70,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Comissao Resul" 
   @ 029,280 MSGET oPComRes VAR Transform(nPComRes,"@R 999.99%") SIZE 05,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02  when .f.
  	@ 029,322 SAY cMoedCor SIZE 10,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib02
   @ 029,335 MSGET oVComRes VAR nVComRes Pict "@E 999,999.99" SIZE 55,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02  when .f.

	@ 044,003 TO 084,393 LABEL ("") OF oAnaCus PIXEL
  	@ 048,005 SAY STR0021 SIZE 80,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Chassi"         
   @ 048,050 MSGET oObj1 VAR VV1->VV1_CHASSI SIZE 145,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.
  	@ 048,207 SAY STR0289 SIZE 80,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Marca / Modelo "  
   @ 048,280 MSGET oObj1 VAR cModVeiApr SIZE 110,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.

  	@ 060,005 SAY STR0022 SIZE 80,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Cor"            
   @ 060,050 MSGET oObj2 VAR VVC->VVC_DESCRI SIZE 145,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.
  	@ 060,207 SAY STR0186 SIZE 80,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Combustivel" 
   @ 060,280 MSGET oObj3 VAR cCombust   SIZE 110,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.

  	@ 072,005 SAY STR0290 SIZE 80,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Fab / Mod  "  
   @ 072,050 MSGET oObj2 VAR cAnoModApr SIZE 40,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.


	@ 086,003 LISTBOX oLbGrp FIELDS HEADER OemToAnsi(STR0295),OemToAnsi(cMoedCor),OemToAnsi(cOutMoed),OemToAnsi("%") 150,40,20,40 SIZE 393,182 OF oAnaCus PIXEL ON DBLCLICK (FS_AnaSin()) // Conta
	oLbGrp:SetArray(aMostraAva)
	oLbGrp:bLine := { || { aMostraAva[oLbGrp:nAt,1],;
     	                    FG_AlinVlrs(Transform(aMostraAva[oLbGrp:nAt,2],"@E 999,999,999")) ,;
     	                    FG_AlinVlrs(Transform(aMostraAva[oLbGrp:nAt,3],"@E 999,999,999")) ,;
     	                    FG_AlinVlrs(Transform(aMostraAva[oLbGrp:nAt,4],"@E 99999.99 %")) }}

@ 272,140 BUTTON oObervAte PROMPT OemToAnsi(STR0291) OF OAnaCus SIZE 43,11 PIXEL ACTION (FS_Obs011(STR0293,VV9->VV9_OBSMEM,"VV9_OBSMEM","VV9_OBSERV",.f.))  //Observacoes Atendimento
@ 272,190 BUTTON oReprovar PROMPT OemToAnsi(STR0038) OF OAnaCus SIZE 43,11 PIXEL ACTION (FS_Apr011("R"),oAnaCus:End()) //Reprovar
@ 272,240 BUTTON oPreAprov PROMPT OemToAnsi(STR0036) OF OAnaCus SIZE 43,11 PIXEL ACTION (FS_Apr011("O"),oAnaCus:End()) when VV9->VV9_STATUS != "O"//Pre-Aprovar
@ 272,290 BUTTON oAprovar  PROMPT OemToAnsi(STR0292) OF OAnaCus SIZE 43,11 PIXEL ACTION (FS_Apr011("L"),oAnaCus:End()) //Aprovar
//@ 272,340 BUTTON oSair     PROMPT OemToAnsi(STR0245) OF OAnaCus SIZE 43,11 PIXEL ACTION If(lVerStatus,(STATUS011("A"),oAnaCus:End()),oAnaCus:End()) // SAIR
@ 272,340 BUTTON oSair     PROMPT OemToAnsi(STR0245) OF OAnaCus SIZE 43,11 PIXEL ACTION If(!lVerStatus,(FS_Apr011("A"),oAnaCus:End()),oAnaCus:End()) // SAIR

ACTIVATE MSDIALOG oAnaCus CENTER

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_AnaSin  ³ Autor ³ Manoel               ³ Data ³ 13/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra/Omite as contas analiticas                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ sem parametros                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ sem retorno			                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AnaSin()
Local ii

If aMostraAva[oLbGrp:nAt,5] == "0"// Sintetico

	nPos := aScan(aMosAvaSv,{|x| x[6] == aMostraAva[oLbGrp:nAt,6]})
	If aMostraAva[oLbGrp:nAt,7] 
	   aMosAvaSv[nPos,7] := .f.
		For ii := nPos+1 to Len(aMosAvaSv)
		   If aMosAvaSv[ii,5] == "0"
		      exit
		   Else 
			   aMosAvaSv[ii,7] := .f.
		   Endif
		Next
	Else
	   aMosAvaSv[nPos,7] := .t.
		For ii := nPos+1 to Len(aMosAvaSv)
		   If aMosAvaSv[ii,5] == "0"
		      exit
		   Else 
			   aMosAvaSv[ii,7] := .t.
		   Endif
		Next
	Endif
	
	aMostraAva := {}
	For ii := 1 to Len(aMosAvaSv)
		 
	    If aMosAvaSv[ii,7] .or. (!aMosAvaSv[ii,7] .and. aMosAvaSv[ii,5] == "0")
			 aadd(aMostraAva,{aMosAvaSv[ii,1],aMosAvaSv[ii,2],aMosAvaSv[ii,3],aMosAvaSv[ii,4],aMosAvaSv[ii,5],aMosAvaSv[ii,6],aMosAvaSv[ii,7]})	
	   Endif
	
	Next           

	oLbGrp:nAt := 1
	oLbGrp:SetArray(aMostraAva)
	oLbGrp:bLine := { || { aMostraAva[oLbGrp:nAt,1],;
	  	                    FG_AlinVlrs(Transform(aMostraAva[oLbGrp:nAt,2],"@E 99,999,999")) ,;
	  	                    FG_AlinVlrs(Transform(aMostraAva[oLbGrp:nAt,3],"@E 99,999,999")) ,;
	  	                    FG_AlinVlrs(Transform(aMostraAva[oLbGrp:nAt,4],"@E 9999.99")) }}
	oLbGrp:Refresh()	
	
Endif	

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_Obs011  ³ Autor ³ Manoel               ³ Data ³ 13/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra Observacoes do Atendimento                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ sem parametros                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ sem retorno			                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Obs011(cTitJanela,cCampoMemo,cCampoOBSMEM,cCampoOBSERV,lAltMemo)
aMemos  := {{cCampoOBSMEM,cCampoOBSERV}}
cObserv := E_MSMM(cCampoMemo,77)
nOpObs  := 0
DEFINE MSDIALOG oDlgObs TITLE cTitJanela FROM  02,04 TO 14,56 OF oMainWnd
If lAltMemo
	@ 01,011 GET oObserv VAR cObserv OF oDlgObs MEMO SIZE 182,67 PIXEL
	DEFINE SBUTTON FROM 076,168 TYPE 1 ACTION (oDlgObs:End()) ENABLE OF oDlgObs
Else
	@ 01,011 GET oObserv VAR cObserv OF oDlgObs MEMO SIZE 182,67 PIXEL ReadOnly MEMO
	DEFINE SBUTTON FROM 076,168 TYPE 2 ACTION (oDlgObs:End()) ENABLE OF oDlgObs
EndIf                                                                          
oObserv:SetFocus()
ACTIVATE MSDIALOG oDlgObs CENTER
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_MINCOMV ³ Autor ³ Andre Luis Almeida   ³ Data ³ 28/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra Minimo Comercial para Venda                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MINCOMV()
Local nPerVdaM := 0 // % para calculo do Vlr.Venda Minimo
Local nVlrVdaM := 0 // Vlr.Venda Minimo
Local nVlrDiff := 0 // Valor da diferenca entre Minimo Comercial e Valor atual de venda
Local nVlrNego := ( M->VV0_VALTOT - M->VV0_VALTRO )
Local _cQuery  := ""
Local _cAlVVP  := "SQLVVP"
Local nValorVda := 0
If VV1->VV1_SUGVDA > 0 // Valor Sugerido para Venda
	nValorVda := VV1->VV1_SUGVDA
EndIf
If nValorVda == 0 // Valor de Tabela
	_cQuery := "SELECT VVP.VVP_VALTAB FROM "+RetSqlName("VVP")+" VVP WHERE VVP.VVP_FILIAL='"+xFilial("VVP")+"' AND VVP.VVP_CODMAR='"+VV1->VV1_CODMAR+"' AND VVP.VVP_MODVEI='"+VV1->VV1_MODVEI+"' AND VVP.VVP_SEGMOD='"+VV1->VV1_SEGMOD+"' AND VVP.VVP_DATPRC<='"+dtos(dDataBase)+"' AND VVP.D_E_L_E_T_=' ' ORDER BY VVP.VVP_DATPRC DESC"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), _cAlVVP , .F., .T. )
	If !( _cAlVVP )->( Eof() )
		nValorVda := ( _cAlVVP )->( VVP_VALTAB )
	EndIf
	( _cAlVVP )->( dbCloseArea() )
EndIf
If VV1->(FieldPos("VV1_MNVLVD")) > 0
	nPerVdaM := VV1->VV1_MNVLVD // % Minimo Comercial do Veiculo
EndIf
If nPerVdaM == 0
	If VV2->(FieldPos("VV2_MNVLVD")) > 0
		VV2->(dbSetOrder(1))
		VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
		nPerVdaM := VV2->VV2_MNVLVD // % Minimo Comercial do Modelo do Veiculo
	EndIf
EndIf
If nPerVdaM == 0
	nPerVdaM := GetNewPar("MV_MINCVLV",0) // % Minimo Comercial Valor de Venda
EndIf
nVlrVdaM := ( nValorVda * ( ( 100 - nPerVdaM ) / 100 ) ) // Valor Minimo Comercial (Vlr de Venda - % Minimo Comercial)
nVlrDiff := ( nVlrNego - nVlrVdaM )
DEFINE MSDIALOG oDlgMinCom TITLE STR0341 FROM  00,00 TO 15,44 OF oMainWnd // Minimo Comercial
@ 011,018 SAY (STR0344+":") SIZE 80,20 OF oDlgMinCom PIXEL COLOR CLR_BLUE // Valor de Tabela
@ 010,085 MSGET oVlTabel VAR nValorVda PICTURE "@E 999,999,999.99" SIZE 70,08 OF oDlgMinCom PIXEL COLOR CLR_BLUE WHEN .f.
@ 026,018 SAY (STR0343+":") SIZE 80,20 OF oDlgMinCom PIXEL COLOR CLR_BLUE // % Minimo Comercial
@ 025,085 MSGET oPerVdaM VAR nPerVdaM PICTURE "@E 9999.99 %" SIZE 70,08 OF oDlgMinCom PIXEL COLOR CLR_BLUE WHEN .f.
@ 041,018 SAY (STR0342+":") SIZE 80,20 OF oDlgMinCom PIXEL COLOR CLR_BLUE // Valor Minimo Comercial
@ 040,085 MSGET oVlrVdaM VAR nVlrVdaM PICTURE "@E 999,999,999.99" SIZE 70,08 OF oDlgMinCom PIXEL COLOR CLR_BLUE WHEN .f.
@ 056,018 SAY (STR0228+":") SIZE 80,20 OF oDlgMinCom PIXEL COLOR CLR_BLUE // Valor Negociado
@ 055,085 MSGET oValMov VAR nVlrNego PICTURE "@E 999,999,999.99" SIZE 70,08 OF oDlgMinCom PIXEL COLOR CLR_BLUE WHEN .f.
If nVlrDiff == 0
	@ 071,070 BITMAP oxBranMC RESOURCE "BR_BRANCO" OF oDlgMinCom NOBORDER SIZE 10,10 when .f. PIXEL
ElseIf nVlrDiff > 0
	@ 071,070 BITMAP oxVerdMC RESOURCE "BR_VERDE" OF oDlgMinCom NOBORDER SIZE 10,10 when .f. PIXEL
Else
	@ 071,070 BITMAP oxVermMC RESOURCE "BR_VERMELHO" OF oDlgMinCom NOBORDER SIZE 10,10 when .f. PIXEL
EndIf
@  070,085 MSGET oVlrDiff VAR nVlrDiff PICTURE "@E 999,999,999.99" SIZE 70,08 OF oDlgMinCom PIXEL COLOR CLR_BLUE WHEN .f.
DEFINE SBUTTON FROM 091,130 TYPE 1 ACTION (oDlgMinCom:End()) ENABLE OF oDlgMinCom // Botao OK
ACTIVATE MSDIALOG oDlgMinCom CENTER
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_Apr011  ³ Autor ³ Manoel               ³ Data ³ 13/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Reprova / Aprova o Atendimento de Veiculos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ sem parametros                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno  ³ sem retorno			                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Apr011(cPar)
Local nPMinComV := 0
Default cPar := ""
If cPar == "R" // Reprovar
	DbSelectArea("VV9")
	aMemos := {{"VV9_OBSMEM","VV9_OBSERV"}}
	cObservAnt  := E_MSMM(VV9->VV9_OBSMEM,77)+Chr(13)+Chr(10)+"*** "+left(Alltrim(UsrRetName(__CUSERID)),15)+" "+Transform(dDataBase,"@D")+"-"+Transform(time(),"@R 99:99")+" ***"+Chr(13)+Chr(10)+Repl("_",77)+Chr(13)+Chr(10)	
	cObserv := ""
	nOpObs := 0
	DEFINE MSDIALOG oDlgObs TITLE STR0294 FROM  02,04 TO 14,56 OF oMainWnd // "Motivo da Reprovacao" 
	DEFINE SBUTTON FROM 076,137 TYPE 1 ACTION (nOpObs:=1,oDlgObs:End()) ENABLE OF oDlgObs
	DEFINE SBUTTON FROM 076,168 TYPE 2 ACTION (oDlgObs:End()) ENABLE OF oDlgObs
	@ 01,011 GET oObserv VAR cObserv OF oDlgObs MEMO SIZE 182,67 PIXEL
	oObserv:SetFocus()
	ACTIVATE MSDIALOG oDlgObs CENTER
	If nOpObs == 1
		DbSelectArea("VV9")
		MSMM(,TamSx3("VV9_OBSERV")[1],,cObservAnt+cObserv,1,,,"VV9","VV9_OBSMEM")
	EndIf
Elseif cPar == "A"
	M->VV9_STATUS := "A"
Else
	If VV1->(FieldPos("VV1_MNCOMV")) > 0
		nPMinComV := VV1->VV1_MNCOMV // % Minimo Comercial do Veiculo
	EndIf
	If nPMinComV == 0
		If VV2->(FieldPos("VV2_MNCOMV")) > 0
			VV2->(dbSetOrder(1))
			VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
			nPMinComV := VV2->VV2_MNCOMV // % Minimo Comercial do Modelo do Veiculo
		EndIf
	EndIf
	If nPMinComV == 0
		nPMinComV := GetNewPar("MV_MINCOMV",0) // % Minimo Comercial Geral
	EndIf
	If lMinComV .and. aMostraAva[Len(aMostraAva),4] < nPMinComV // Minimo Comercial - aqui definido com 5%, que compara com o 
																 // Ultimo elemento do vetor (que deve sempre ser o a Margem de Lucro)
		MsgInfo(STR0314 + transform(nPMinComV,"@E 9999.99")+STR0315+" "+transform(aMostraAva[Len(aMostraAva),4],"@E 9999.99")+STR0316,STR0012)
		return
	Else
		If FS_VERAPROV(VV9->VV9_NUMATE)  // Verifica se existe outro Atendimento ja pre-aprovado/aprovado para o mesmo Veiculo (CHASSI)
			return
		EndIf
	EndIf
Endif
If cPar == "O" // O - Pre-Aprovado 
	STATUS011("O")
Endif
DbSelectArea("VV9")
RecLock("VV9",.f.)
	VV9->VV9_STATUS := cPar
MsUnlock()
If !cPar $ "R.A"       
	If FindFunction("VEIVM130TAR") // Tarefas do Atendimento - Andre Luis Almeida 18/09/09 T1031 Maipu //
		If cPar == "L" // L - Aprovado
	   		FS_GRVDTAPR(2) // Gravar a Data da Aprovacao (2=VV0->VV0_DATAPR)
			VEIVM130TAR(M->VV9_NUMATE,"6") // "Solicitar Tarefas" 5-Pre-Aprovado / 6-Aprovado 
			//valida regra para tarefas - Rafael Goncalves - 28/01/2010
			If FindFunction("VA400REGRA")
				//if M->VV0_RESERV $ "1/3" 
					VA400REGRA(M->VV9_NUMATE,"4")// 1 - Gravacao / 2- Pendente / 3- pre-aprovado / 4 aprovado
				//EndIf
			EndIf
		Else // O - Pre-Aprovado 
			VEIVM130TAR(M->VV9_NUMATE,"5")// "Solicitar Tarefas" 5-Pre-Aprovado / 6-Aprovado 
			//valida regra para tarefas - Rafael Goncalves - 28/01/2010
			If FindFunction("VA400REGRA")
   				//if M->VV0_RESERV $ "1/3"
					VA400REGRA(M->VV9_NUMATE,"3")// 1 - Gravacao / 2- Pendente / 3- pre-aprovado / 4 aprovado
				//EndIF
			EndIf		
		Endif
	EndIf
Endif
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |V011INCLUIRº Autor ³ Andre Luis Almeida º Data ³ 22/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Incluir Atendimento:  1 - Padrao / 2 - Nova Tela Consulta  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function V011INCLUIR( cAlias , nReg , nOpc )
Local lV011Inc := .f.
Private cVV9CCli := space(TamSx3("VV9_CODCLI")[1])
Private cVV9LCli := space(TamSx3("VV9_LOJA")[1])
Private cVV9NCli := space(TamSx3("VV9_NOMVIS")[1])
Private cVV9FCli := space(TamSx3("VV9_TELVIS")[1])
Private cVV9ECli := space(TamSx3("A1_EMAIL")[1])
Private o_Verd   := LoadBitmap( GetResources() , "BR_VERDE" )
Private o_Ocea   := LoadBitmap( GetResources() , "lbok_ocean" )
Private o_Pret   := LoadBitmap( GetResources() , "BR_PRETO" )
Private o_Amar   := LoadBitmap( GetResources() , "BR_AMARELO" )
Private o_Lara   := LoadBitmap( GetResources() , "BR_LARANJA" )
Private o_Bran   := LoadBitmap( GetResources() , "BR_BRANCO" )
Private o_Azul   := LoadBitmap( GetResources() , "BR_AZUL" )
Private o_Verm   := LoadBitmap( GetResources() , "BR_VERMELHO" )
Private aTelaIncl:= {}
Private aVerAtend:= {}
aadd(aTelaIncl,{cVV9CCli,cVV9LCli,cVV9NCli,cVV9FCli})
If GetNewPar("MV_V011INC","1") == "1" // 1 - Incluir Padrao
	ATEND011( cAlias , nReg , nOpc ) // Chamada do Atendimento
Else // 2 - Nova Tela Consulta
	FS_LEVATEND(0)
	DbSelectArea("VV9")
	DEFINE MSDIALOG oV011Inc FROM 000,000 TO 038,100 TITLE OemToAnsi(STR0001) OF oMainWnd STYLE DS_MODALFRAME STATUS //Atendimento de venda
	oV011Inc:lEscClose := .F.
	@ 002,002 TO 060,394 LABEL (" "+STR0298+" ") OF oV011Inc PIXEL  // Filtro Cliente
	@ 011,013 SAY (STR0299+":") SIZE 30,10 OF oV011Inc PIXEL COLOR CLR_BLUE // "Codigo Cliente"
	@ 010,050 MSGET oVV9CCli VAR cVV9CCli VALID FS_LEVANTA(1) PICTURE "@!" F3 "SA1" SIZE 37,8 OF oV011Inc PIXEL COLOR CLR_BLUE
	@ 010,090 MSGET oVV9LCli VAR cVV9LCli VALID FS_LEVANTA(1) PICTURE "@!" SIZE 15,8 OF oV011Inc PIXEL COLOR CLR_BLUE
	@ 023,013 SAY (STR0300+":") SIZE 30,10 OF oV011Inc PIXEL COLOR CLR_BLUE // "Nome"
	@ 022,050 MSGET oVV9NCli VAR cVV9NCli VALID FS_LEVANTA(2) PICTURE "@!" SIZE 200,8 OF oV011Inc PIXEL COLOR CLR_BLUE
	@ 035,013 SAY (STR0301+":") SIZE 30,10 OF oV011Inc PIXEL COLOR CLR_BLUE // "Telefone"
	@ 034,050 MSGET oVV9FCli VAR cVV9FCli VALID FS_LEVANTA(3) PICTURE "@!" SIZE 80,8 OF oV011Inc PIXEL COLOR CLR_BLUE
	@ 047,013 SAY (STR0302+":") SIZE 30,10 OF oV011Inc PIXEL COLOR CLR_BLUE // "E-mail"
	@ 046,050 MSGET oVV9ECli VAR cVV9ECli VALID FS_LEVANTA(4) PICTURE "@!" SIZE 200,8 OF oV011Inc PIXEL COLOR CLR_BLUE
	@ 062,002 LISTBOX oLbVerAte FIELDS HEADER OemToAnsi(""),;
		OemToAnsi(STR0246),;//Filial
		OemToAnsi(STR0119),; //data
		OemToAnsi(STR0247),;//Atendimento
		OemToAnsi(STR0248),;//Nro NF
		OemToAnsi(STR0249),;//Serie
		OemToAnsi(STR0023); //valor
		COLSIZES 10,70,50,50,50,50,50 SIZE 392,200 OF oV011Inc PIXEL ON CHANGE FS_TXTBOTAO(aVerAtend[oLbVerAte:nAt,05]) ON DBLCLICK (VV9->(DbSeek(aVerAtend[oLbVerAte:nAt,1])),oV011Inc:End())
		oLbVerAte:SetArray(aVerAtend)
		oLbVerAte:bLine := { || {	IIf(aVerAtend[oLbVerAte:nAt,02]=="A",o_Verd,IIf(aVerAtend[oLbVerAte:nAt,02]=="X",o_Ocea,IIf(aVerAtend[oLbVerAte:nAt,02]$"F.T",o_Pret,IIf(aVerAtend[oLbVerAte:nAt,02]=="P",o_Amar,IIf(aVerAtend[oLbVerAte:nAt,02]=="R",o_Lara,IIf(aVerAtend[oLbVerAte:nAt,02]=="O",o_Bran,IIf(aVerAtend[oLbVerAte:nAt,02]=="L",o_Azul,o_Verm))))))),;
		aVerAtend[oLbVerAte:nAt,03],;
		Transform(aVerAtend[oLbVerAte:nAt,04],"@D"),;
		aVerAtend[oLbVerAte:nAt,05],;
		aVerAtend[oLbVerAte:nAt,07],;
		aVerAtend[oLbVerAte:nAt,08],;
		FG_AlinVlrs(Transform(aVerAtend[oLbVerAte:nAt,06],"@E 999,999,999.99")) }}
		@ 263,002 TO 285,271 LABEL (" "+STR0303+" ") OF oV011Inc PIXEL  // Visualizar
		@ 271,005 BUTTON oBotVisu PROMPT OemToAnsi(STR0247) OF oV011Inc SIZE 77,11 PIXEL ACTION FS_VERATEND(aVerAtend[oLbVerAte:nAt,1]) WHEN !Empty(aVerAtend[oLbVerAte:nAt,1]) // "Atendimento"
		@ 271,084 BUTTON oBotOSrv PROMPT OemToAnsi(STR0304) OF oV011Inc SIZE 60,11 PIXEL ACTION FG_SALDOS(cVV9CCli,cVV9LCli,"","0","T") WHEN !Empty(cVV9CCli+cVV9LCli) // "Ordem de Servico"
		@ 271,146 BUTTON oBotVCli PROMPT OemToAnsi(STR0305) OF oV011Inc SIZE 60,11 PIXEL ACTION VEIVC090(cVV9CCli,cVV9LCli,.t.) WHEN !Empty(cVV9CCli+cVV9LCli) // "Veiculos do Cliente"
		@ 271,208 BUTTON oBotCCEV PROMPT OemToAnsi(STR0306) OF oV011Inc SIZE 60,11 PIXEL ACTION VEICC500(cVV9CCli,cVV9LCli) WHEN !Empty(cVV9CCli+cVV9LCli) // "Contatos CEV"
		@ 263,273 TO 285,345 LABEL (" "+STR0234+" ") OF oV011Inc PIXEL  // Incluir
		@ 271,279 BUTTON oBotIncl PROMPT OemToAnsi(STR0307) OF oV011Inc SIZE 60,11 PIXEL ACTION (lV011Inc:=.t.,oV011Inc:End()) // "Novo Atendimento"
		@ 271,350 BUTTON oBotSair PROMPT OemToAnsi(STR0245) OF oV011Inc SIZE 40,11 PIXEL ACTION oV011Inc:End() // "SAIR"
	ACTIVATE MSDIALOG oV011Inc CENTER 
	If lV011Inc 
		                                                                                                                     
		ATEND011( "VV9" , 0 , 3 , STR0234 ) // Incluir - Chamada do Atendimento 
	EndIf
EndIf
Return()

Static Function FS_VERATEND(cAte) // Visualiza Atendimento
Local lSlvInc := Inclui  // Salva
Local lSlvAlt := Altera  // Salva
Local lSlvEmi := lEmiNfi // Salva
Local lSlvNeg := lNegPag // Salva
Local lSlvLib := lLibVei // Salva
Local lSlvAut := lAutFat // Salva
Inclui  := .f.
Altera  := .f.
lEmiNfi := .t.
lNegPag := .t.
lLibVei := .f.
lAutFat := .f.
nOpc    := 2
nOpca   := 2
DbSelectArea("VV9")
DbSetOrder(1)
If DbSeek( cAte )
	ATEND011( "VV9" , VV9->(RecNo()) , 2 , STR0233 ) // Consultar - Chamada do Atendimento
EndIf
Inclui  := lSlvInc
Altera  := lSlvAlt
lEmiNfi := lSlvEmi
lNegPag := lSlvNeg
lLibVei := lSlvLib
lAutFat := lSlvAut
nOpc    := 3
nOpca   := 3
Return()

Static Function FS_TXTBOTAO(cAte) // Atualiza TEXTO do Botao Visualiza Atendimento
oBotVisu:cCaption := STR0247+" "+cAte // "Atendimento"
oBotVisu:Refresh()
Return()

Static Function FS_LEVATEND(nTip) // Levanta Atendimentos
Local cQuery  := ""
Local cQALVV0 := "SQLVV90A"
Local cVV9_STATUS := ""
Local cFilLibs    := ""
Local aEmpAtu     := {}
Local nEmpAtu := SM0->(RecNo())
Local cEmpAtu := SM0->M0_CODIGO
DbSelectArea("SM0")
DbGoTop()
While !Eof()
	if SM0->M0_CODIGO == cEmpAtu
		aAdd( aEmpAtu , { SM0->M0_CODFIL , SM0->M0_FILIAL } )
	EndIf
	DbSkip()
End
DbSelectArea("SM0")
DbGoTo(nEmpAtu)
aVerAtend := {}
If !Empty(cVV9CCli+cVV9LCli) // Levanta todos atendimentos do Cliente/Loja
	cQuery := "SELECT VV9.VV9_FILIAL , VV9.VV9_NUMATE , VV9.VV9_STATUS , VV9.VV9_DATVIS , VV0.VV0_FILIAL , VV0.VV0_NUMNFI , VV0.VV0_SERNFI , VV0.VV0_VALMOV , VV0.VV0_CODCLI , VV0.VV0_LOJA , VVA.VVA_CHAINT FROM "+RetSqlName("VV0")+" VV0 , "+RetSqlName("VV9")+" VV9 , "+RetSqlName("VVA")+" VVA WHERE "
//	If !(lPedApr .or. lLibVei .or. lAutFat)
	If !(lLibVei .or. lAutFat)
		cQuery += "VV9.VV9_USUARI='"+__cUserID+"' AND "
	EndIf
	cQuery += "VV9.VV9_FILIAL=VV0.VV0_FILIAL AND VV9.VV9_NUMATE=VV0.VV0_NUMTRA AND VV0.VV0_FILIAL=VVA.VVA_FILIAL AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND "
	cQuery += "VV9.VV9_CODCLI='"+cVV9CCli+"' AND VV9.VV9_LOJA='"+cVV9LCli+"' AND "
	cFilLibs := FG_FilLib(2) // retorna apenas filiais que o usuario pode acessar
	If len(cFilLibs) > 1
		cQuery += "VV0.VV0_FILIAL IN ("
		While len(cFilLibs) > 1
			If SM0->M0_CODIGO == left(cFilLibs,2)
				cQuery += "'"+substr(cFilLibs,3,2)+"',"
			EndIf
			cFilLibs := substr(cFilLibs,6)
		EndDo
		cQuery := left(Alltrim(cQuery),len(Alltrim(cQuery))-1)+") AND "
	EndIf
	cQuery += "VV0.D_E_L_E_T_=' ' AND VVA.D_E_L_E_T_=' ' AND VV9.D_E_L_E_T_=' ' ORDER BY VV9.VV9_DATVIS , VV9.VV9_NUMATE "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV0, .F., .T. )
	While !( cQAlVV0 )->( Eof() )
		cVV9_STATUS := ( cQAlVV0 )->( VV9_STATUS )
		If cVV9_STATUS == "A"
			DbSelectArea("VV1")
			DbSetOrder(1)
			DbSeek( xFilial("VV1") + ( cQAlVV0 )->( VVA_CHAINT ) )
			If VV1->VV1_SITVEI == "1" // 1-Vendido
				cVV9_STATUS := "X"
			EndIf
		EndIf
		cEmpAtu := ""
		nEmpAtu := Ascan(aEmpAtu,{|x| x[1] == ( cQAlVV0 )->( VV0_FILIAL ) })
		If nEmpAtu > 0
			cEmpAtu := left(aEmpAtu[nEmpAtu,2],15)
		EndIf
		aAdd(aVerAtend,{ ( cQAlVV0 )->( VV9_FILIAL )+( cQAlVV0 )->( VV9_NUMATE ) , cVV9_STATUS , ( cQAlVV0 )->( VV0_FILIAL )+"-"+cEmpAtu , stod(( cQAlVV0 )->( VV9_DATVIS )) , ( cQAlVV0 )->( VV9_NUMATE ) , ( cQAlVV0 )->( VV0_VALMOV ) , ( cQAlVV0 )->( VV0_NUMNFI ) , ( cQAlVV0 )->( VV0_SERNFI ) })
		( cQAlVV0 )->( DbSkip() )
	End
	( cQAlVV0 )->( dbCloseArea() )
EndIf
If len(aVerAtend) <= 0
	aAdd(aVerAtend,{ "" , "" , "" , ctod("") , "" , 0 , "" , "" })
EndIf
If nTip > 0  
	oLbVerAte:nAt := 1
	oLbVerAte:SetArray(aVerAtend)
	oLbVerAte:bLine := { || {	IIf(aVerAtend[oLbVerAte:nAt,02]=="A",o_Verd,IIf(aVerAtend[oLbVerAte:nAt,02]=="X",o_Ocea,IIf(aVerAtend[oLbVerAte:nAt,02]$"F.T",o_Pret,IIf(aVerAtend[oLbVerAte:nAt,02]=="P",o_Amar,IIf(aVerAtend[oLbVerAte:nAt,02]=="R",o_Lara,IIf(aVerAtend[oLbVerAte:nAt,02]=="O",o_Bran,IIf(aVerAtend[oLbVerAte:nAt,02]=="L",o_Azul,o_Verm))))))),;
	aVerAtend[oLbVerAte:nAt,03],;
	Transform(aVerAtend[oLbVerAte:nAt,04],"@D"),;
	aVerAtend[oLbVerAte:nAt,05],;
	aVerAtend[oLbVerAte:nAt,07],;
	aVerAtend[oLbVerAte:nAt,08],;
	FG_AlinVlrs(Transform(aVerAtend[oLbVerAte:nAt,06],"@E 999,999,999.99")) }}
	oLbVerAte:SetFocus()
	oLbVerAte:Refresh()
EndIf
Return()

Static Function FS_LEVANTA(nTip) // Levanta Clientes
Local cQuery    := "SELECT SA1.A1_COD , SA1.A1_LOJA , SA1.A1_NOME , SA1.A1_TEL , SA1.A1_EMAIL FROM "+RetSqlName("SA1")+" SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND "
Local cQALSA1   := "SQLSA1"
Local aClientes := {}
Local nPos      := 0
If ( nTip == 1 .and. !Empty(cVV9CCli) .and. !Empty(cVV9LCli) ) .or. ;
	( nTip == 2 .and. !Empty(cVV9NCli) ) .or. ;
	( nTip == 3 .and. !Empty(cVV9FCli) ) .or. ;
	( nTip == 4 .and. !Empty(cVV9ECli) )
	Do Case
		Case nTip == 1 // Codigo
			If !Empty(cVV9CCli) .and. !Empty(cVV9LCli)
				cQuery += "SA1.A1_COD='"+cVV9CCli+"' AND SA1.A1_LOJA='"+cVV9LCli+"' AND "
			Else
				cQuery += "SA1.A1_COD='__________' AND " // NAO LEVANTAR
			EndIf
		Case nTip == 2 // Nome
			cQuery += "SA1.A1_NOME LIKE '"+Alltrim(cVV9NCli)+"%' AND "
		Case nTip == 3 // Fone
			cQuery += "SA1.A1_TEL LIKE '%"+Alltrim(cVV9FCli)+"%' AND "
		Case nTip == 4 // E-mail
			cQuery += "( SA1.A1_EMAIL LIKE '%"+Alltrim(cVV9ECli)+"%' OR SA1.A1_EMAIL LIKE '%"+LOWER(Alltrim(cVV9ECli))+"%' ) AND "
	EndCase
	cQuery += "SA1.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQALSA1, .F., .T. )
	While !( cQALSA1 )->( Eof() )
		aAdd(aClientes,{ ( cQALSA1 )->( A1_COD ) , ( cQALSA1 )->( A1_LOJA ) , ( cQALSA1 )->( A1_NOME ) , ( cQALSA1 )->( A1_TEL ) , ( cQALSA1 )->( A1_EMAIL ) })
		( cQALSA1 )->( DbSkip() )
	End
	( cQALSA1 )->( dbCloseArea() )
	cVV9CCli := space(TamSx3("VV9_CODCLI")[1])
	cVV9LCli := space(TamSx3("VV9_LOJA")[1])
	cVV9NCli := space(TamSx3("VV9_NOMVIS")[1])
	cVV9FCli := space(TamSx3("VV9_TELVIS")[1])
	cVV9ECli := space(TamSx3("A1_EMAIL")[1])
	If len(aClientes) == 1
		nPos := 1
	ElseIf len(aClientes) > 1 // Selecionar Cliente
		DEFINE MSDIALOG oClientes FROM 000,000 TO 022,100 TITLE OemToAnsi(STR0308) OF oMainWnd // "Selecionar Cliente"
		@ 002,002 TO 163,394 LABEL (" "+STR0308+" ") OF oClientes PIXEL // Selecionar Cliente
		@ 010,002 LISTBOX oLbClientes FIELDS HEADER OemToAnsi(STR0299),; // Codigo/Loja
			OemToAnsi(STR0300),; //Nome
			OemToAnsi(STR0301),; //Telefone
			OemToAnsi(STR0302); //E-mail
			COLSIZES 40,120,60,100 SIZE 392,151 OF oClientes PIXEL ON DBLCLICK (nPos:=oLbClientes:nAt,oClientes:End())
			oLbClientes:SetArray(aClientes)
			oLbClientes:bLine := { || { aClientes[oLbClientes:nAt,01]+"-"+aClientes[oLbClientes:nAt,02],;
					aClientes[oLbClientes:nAt,03],;
					aClientes[oLbClientes:nAt,04],;
					aClientes[oLbClientes:nAt,05] }}
		ACTIVATE MSDIALOG oClientes CENTER 
	EndIf
	If nPos > 0 // Atualiza VARIAVEIS e Vetor para Retorno ao INCLUIR do VEIVM011 
		cVV9CCli := aClientes[nPos,1]
		cVV9LCli := aClientes[nPos,2]
		cVV9NCli := aClientes[nPos,3]
		cVV9FCli := aClientes[nPos,4]
		cVV9ECli := aClientes[nPos,5]
		aTelaIncl := {}
		aadd(aTelaIncl,{cVV9CCli,cVV9LCli,cVV9NCli,cVV9FCli})
	EndIf
	FS_LEVATEND(1) // Levanta os Atendimentos do Cliente selecionado
	FS_TXTBOTAO(aVerAtend[1,05])
EndIf
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FS_CONSNEGº Autor ³ Manoel              º Data ³ 25/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta da Tela de Negociacao                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CONSNEG()
Local nPosDatPag := FG_PosVar("VS9_DATPAG","aHeaderC")
Local nPosTipPag := FG_PosVar("VS9_TIPPAG","aHeaderC")
Local nPosDesPag := FG_PosVar("VS9_DESPAG","aHeaderC")
Local nPosValPag := FG_PosVar("VS9_VALPAG","aHeaderC")
Local nVlrTroco  := 0
Local nVlrTotal  := 0
Local bCampo        := { |nCPO| Field(nCPO) }
Local ii            := 0
Local it_            := 0
Local cont 		     := 0
Local cGrupVei      := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Local cEmpresa      := ""
Local cCliente      := ""
Local cProposta     := ""
Local cStatus       := ""
Private Inclui      := .f. // Variavel INTERNA utilizada no VEIVM011
Private Altera      := .f. // Variavel INTERNA utilizada no VEIVM011
Private lEmiNfi     := .t. // Variavel INTERNA utilizada no VEIVM011
Private lNegPag     := .t. // Variavel INTERNA utilizada no VEIVM011
Private lLibVei     := .f. // Variavel INTERNA utilizada no VEIVM011
Private lAutFat     := .f. // Variavel INTERNA utilizada no VEIVM011
Private _lVerBotoes := .f. // Variavel INTERNA utilizada no VEIVM011
Private cCampo      := ""
Private nOpc        := 2
Private bFiltraBrw  := {|| Nil}
Private aCampos     := {}
Private aMostraAva  := {}

DEFINE FONT oFLib01 NAME "Arial" SIZE 09,13 BOLD
DEFINE FONT oFLib02 NAME "Arial" SIZE 07,13 BOLD

dbSelectArea("VAI")
dbSetOrder(4)
dbSeek(xFilial("VAI")+__cUserID)

//If !VAI->VAI_LIBVEI == "1"
//   MsgInfo(STR0279,STR0012) //"Esta opcao so' e' permitida para usuarios com autorizacao para LIBERAR venda de Veiculos (VAI->VAI_LIBVEI == '1')")
//   return
//Endif

VV2->(dbSetOrder(1))
VV2->(dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))

VVC->(DbSetOrder(1))
VVC->(DbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))

SB1->(dbSetOrder(7))
SB1->(dbSeek(xFilial("SB1")+cGrupVei+VV1->VV1_CHAINT))

if M->VV0_TOTICM == 0
	INIFIS011()
	FISCAL011()
Endif

//Simula a gravacao para apresentacao do mapa
//CPOMEM011("")

cEmpresa  := SM0->M0_CODIGO + " / " + SM0->M0_CODFIL + " - " + SM0->M0_FILIAL
dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+M->VV9_CODCLI+M->VV9_LOJA)
cCliente  := SA1->A1_COD+"-"+SA1->A1_LOJA+" "+SA1->A1_NOME

cProposta := M->VV9_NUMATE+" - "+Dtoc(M->VV0_DATMOV)+" - "+cStatus
cCombust  := ""
If VV1->VV1_COMVEI=="0"
	cCombust := STR0173 // "Gasolina"
Elseif VV1->VV1_COMVEI=="1"
	cCombust := STR0174 // "Alcool"
Elseif VV1->VV1_COMVEI=="2"
	cCombust := STR0175 // "Diesel"
Elseif VV1->VV1_COMVEI=="3"
	cCombust := STR0176 // "Gas Natural"
Elseif VV1->VV1_COMVEI=="4"
	cCombust := STR0281 // "Alcool/Gasolina"
Elseif VV1->VV1_COMVEI=="5"
	cCombust := STR0282 // "Alcool/Gasolina/GNV"
Elseif VV1->VV1_COMVEI=="9"
	cCombust := STR0177 // "Sem Combustivel"
Endif

cModVeiApr  := Alltrim(VV2->VV2_MODVEI) + " - " + VV2->VV2_DESMOD
cAnoModApr  := Subs(VV1->VV1_FABMOD,1,4) + "/" + Subs(VV1->VV1_FABMOD,5,4)

M->VV0_VALFIN := 0
M->VV0_TOTENT := 0

For ii := 1 to Len(aColsC)
    
    If !aColsc[ii,Len(aHeaderC)+1]
		dbSelectArea("VSA")
		dbSetOrder(1)
		if dbSeek(xFilial("VSA")+aColsC[ii,1]) .and. VSA->(FieldPos("VSA_FINANC")) > 0 .and. VSA->VSA_FINANC == "1"
			M->VV0_VALFIN += aColsC[ii,FG_POSVAR('VS9_VALPAG',"aHeaderC")]
		Else
			M->VV0_TOTENT += aColsC[ii,FG_POSVAR('VS9_VALPAG',"aHeaderC")]
		EndIf
	EndIf

Next                                           

nVlrTroco := (M->VV0_VALFIN+M->VV0_TOTENT) - M->VV0_VALMOV
If nVlrTroco > 0
	M->VV0_VALTRO := nVlrTroco
EndIf

aMostraOVd := {}
aMostraCor := {}
aMostraRed := {}
aMostraAgr := {}
aMostraPar := {}

nOutVendas := 0
nCortesias := 0
nRedutores := 0
nVdaAgrega := 0
For it_ := 1 to Len(aColsIC)
	If !aColsIc[it_,len(aColsIC[it_])]
		If aColsIc[it_,FG_POSVAR('VZ7_AGRVLR',"aHeaderIC")] == "0" // Agrega valor ao Total da NF
			nOutVendas += aColsIc[it_,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]
		    aadd(aMostraOVd,{aColsIc[it_,FG_POSVAR('VZ7_ITECAM',"aHeaderIC")],left(aColsIc[it_,FG_POSVAR('VZ7_DESCAM',"aHeaderIC")],25),aColsIc[it_,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]})
		ElseIf aColsIc[it_,FG_POSVAR('VZ7_AGRVLR',"aHeaderIC")] == "1" // Agrega valor a Despesa com Cliente
			nCortesias += aColsIc[it_,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]
		    aadd(aMostraCor,{aColsIc[it_,FG_POSVAR('VZ7_ITECAM',"aHeaderIC")],left(aColsIc[it_,FG_POSVAR('VZ7_DESCAM',"aHeaderIC")],25),aColsIc[it_,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]})
		ElseIf aColsIc[it_,FG_POSVAR('VZ7_AGRVLR',"aHeaderIC")] == "2" // Agrega valor ao Redutor
			nRedutores += aColsIc[it_,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]
		    aadd(aMostraRed,{aColsIc[it_,FG_POSVAR('VZ7_ITECAM',"aHeaderIC")],left(aColsIc[it_,FG_POSVAR('VZ7_DESCAM',"aHeaderIC")],25),aColsIc[it_,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]})
		ElseIf aColsIc[it_,FG_POSVAR('VZ7_AGRVLR',"aHeaderIC")] == "3" // Agrega valor a Venda Agregada
			nVdaAgrega += aColsIc[it_,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]
		    aadd(aMostraAgr,{aColsIc[it_,FG_POSVAR('VZ7_ITECAM',"aHeaderIC")],left(aColsIc[it_,FG_POSVAR('VZ7_DESCAM',"aHeaderIC")],25),aColsIc[it_,FG_POSVAR('VZ7_VALITE',"aHeaderIC")]})
		EndIf
	Endif
Next
If Len(aMostraOVd) == 0
    aMostraOVd := {{"","",0}}
Endif
If Len(aMostraCor) == 0
    aMostraCor := {{"","",0}}
Endif
If Len(aMostraRed) == 0
    aMostraRed := {{"","",0}}
Endif
If Len(aMostraAgr) == 0
    aMostraAgr := {{"","",0}}
Endif
           
For ii := 1 to Len(aColsC)
	If aColsC[ii,Len(aColsC[ii])] .or. ( Empty(aColsC[ii,nPosTipPag]) .and. aColsC[ii,nPosValPag] == 0 )
		Loop
	EndIf
	aadd(aMostraPar,{aColsC[ii,nPosDatPag],aColsC[ii,nPosTipPag]+" - "+aColsC[ii,nPosDesPag],aColsC[ii,nPosValPag]}) // VS9 -> DATPAG / TIPPAG - DESPAG / VALPAG
Next
nVlrTotal := (M->VV0_VALFIN+M->VV0_TOTENT)
cont := 0
For ii := 1 to len(aIteParc)
	if aIteParc[ii,2] > 0
		nVlrTotal += aIteParc[ii,2]
		cont++
		aadd(aMostraPar,{aIteParc[ii,1],Alltrim(str(cont,6)+"a. "+STR0354),aIteParc[ii,2]}) // a. parcela
	Endif
Next
If Len(aMostraPar) == 0
    aMostraPar := {{"","",0}}
Else
	Asort(aMostraPar,,,{|x,y| dtos(x[1]) < dtos(y[1]) })
Endif

DEFINE MSDIALOG oAnaCus FROM 000,000 TO 041,100 TITLE STR0283 OF oMainWnd //"Aprovacao (Analise de Custos)"
	
	@ 001,003 TO 042,200 LABEL ("") OF oAnaCus PIXEL
	@ 005,005 SAY STR0284 SIZE 40,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Empresa"  
	@ 005,052 MSGET oObj1 VAR cEmpresa   SIZE 145,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.
	@ 017,005 SAY STR0250 SIZE 40,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Cliente"  
	@ 017,052 MSGET oObj2 VAR cCliente   SIZE 145,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.
	@ 029,005 SAY STR0285 SIZE 40,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Proposta" 
	@ 029,052 MSGET oObj3 VAR cProposta  SIZE 145,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.
	
	@ 001,203 TO 108,393 LABEL ("") OF oAnaCus PIXEL
	@ 005,207 SAY STR0324 SIZE 150,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Valor Total"
	@ 005,318 MSGET oPComVPg VAR FG_AlinVlrs(Transform(nVlrTotal,"@E 999,999,999.99")) SIZE 72,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02  when .f.
	@ 018,207 SAY STR0325 SIZE 150,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Valor da Venda"
	@ 018,318 MSGET oPComVda VAR FG_AlinVlrs(Transform(M->VV0_VALMOV,"@E 999,999,999.99")) SIZE 72,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02  when .f.
	@ 031,207 SAY STR0326 SIZE 150,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Valor do Troco" 
	@ 031,318 MSGET oPComTro VAR FG_AlinVlrs(Transform((nVlrTotal-M->VV0_VALMOV),"@E 999,999,999.99")) SIZE 72,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02  when .f.
	@ 044,207 SAY STR0327 SIZE 150,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Utilizacao do Troco"
	@ 044,318 MSGET oPComUTr VAR FG_AlinVlrs(Transform(nOutVendas,"@E 999,999,999.99")) SIZE 72,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02  when .f.
	@ 057,207 SAY STR0328 SIZE 150,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Devolucao ao Cliente"
	@ 057,318 MSGET oPComDvC VAR FG_AlinVlrs(Transform(IIf(nVlrTroco>nOutVendas,(nVlrTroco-nOutVendas),0),"@E 999,999,999.99")) SIZE 72,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02  when .f.
	@ 070,207 SAY STR0329 SIZE 150,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Cortesias"
	@ 070,318 MSGET oPComCor VAR FG_AlinVlrs(Transform(nCortesias,"@E 999,999,999.99")) SIZE 72,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02  when .f.
	@ 082,207 SAY STR0352 SIZE 150,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Redutores"
	@ 082,318 MSGET oPComRed VAR FG_AlinVlrs(Transform(nRedutores,"@E 999,999,999.99")) SIZE 72,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02  when .f.
	@ 094,207 SAY STR0353 SIZE 150,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Vendas Agregadas"
	@ 094,318 MSGET oPComAgr VAR FG_AlinVlrs(Transform(nVdaAgrega,"@E 999,999,999.99")) SIZE 72,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02  when .f.

	@ 044,003 TO 108,200 LABEL ("") OF oAnaCus PIXEL
	@ 047,005 SAY STR0021 SIZE 80,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Chassi"         
	@ 047,072 MSGET oObj1 VAR VV1->VV1_CHASSI SIZE 125,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.
	@ 059,005 SAY STR0022 SIZE 80,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Cor"            
	@ 059,072 MSGET oObj2 VAR VVC->VVC_DESCRI SIZE 125,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.
	@ 071,005 SAY STR0290 SIZE 80,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Fab / Mod  "  
	@ 071,072 MSGET oObj2 VAR cAnoModApr SIZE 125,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.
	@ 083,005 SAY STR0289 SIZE 80,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Marca / Modelo "  
  	@ 083,072 MSGET oObj1 VAR cModVeiApr SIZE 125,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.
	@ 095,005 SAY STR0186 SIZE 80,08 OF oAnaCus PIXEL COLOR CLR_RED FONT oFLib01 // "Combustivel" 
	@ 095,072 MSGET oObj3 VAR cCombust   SIZE 125,06 OF oAnaCus PIXEL COLOR CLR_BLUE FONT oFLib02 when .f.

	@ 110,003 TO 171,200 LABEL (STR0329) OF oAnaCus PIXEL // "Cortesias"
	@ 117,005 LISTBOX oLbGrp FIELDS HEADER OemToAnsi(STR0330),OemToAnsi(STR0061),OemToAnsi(STR0023) 50,70,20 SIZE 192,051 OF oAnaCus PIXEL
	oLbGrp:SetArray(aMostraCor)
	oLbGrp:bLine := { || { aMostraCor[oLbGrp:nAt,1],;
     	                    aMostraCor[oLbGrp:nAt,2],;
     	                    FG_AlinVlrs(Transform(aMostraCor[oLbGrp:nAt,3],"@E 999,999,999.99")) }}

	@ 172,003 TO 233,200 LABEL (STR0352) OF oAnaCus PIXEL // "Redutores"
	@ 179,005 LISTBOX oLbGrpR FIELDS HEADER OemToAnsi(STR0330),OemToAnsi(STR0061),OemToAnsi(STR0023) 50,70,20 SIZE 192,051 OF oAnaCus PIXEL
	oLbGrpR:SetArray(aMostraRed)
	oLbGrpR:bLine := { || { aMostraRed[oLbGrpR:nAt,1],;
     	                    aMostraRed[oLbGrpR:nAt,2],;
     	                    FG_AlinVlrs(Transform(aMostraRed[oLbGrpR:nAt,3],"@E 999,999,999.99")) }}

	@ 234,003 TO 295,200 LABEL (STR0353) OF oAnaCus PIXEL // "Vendas Agregadas"
	@ 241,005 LISTBOX oLbGrpA FIELDS HEADER OemToAnsi(STR0330),OemToAnsi(STR0061),OemToAnsi(STR0023) 50,70,20 SIZE 192,051 OF oAnaCus PIXEL
	oLbGrpA:SetArray(aMostraAgr)
	oLbGrpA:bLine := { || { aMostraAgr[oLbGrpA:nAt,1],;
     	                    aMostraAgr[oLbGrpA:nAt,2],;
     	                    FG_AlinVlrs(Transform(aMostraAgr[oLbGrpA:nAt,3],"@E 999,999,999.99")) }}

	@ 110,203 TO 171,393 LABEL (STR0327) OF oAnaCus PIXEL // "Utilizacao do Troco"
	@ 117,205 LISTBOX oLbGrpT FIELDS HEADER OemToAnsi(STR0330),OemToAnsi(STR0061),OemToAnsi(STR0023) 50,70,20 SIZE 185,051 OF oAnaCus PIXEL 
	oLbGrpT:SetArray(aMostraOVd)
	oLbGrpT:bLine := { || { aMostraOVd[oLbGrpT:nAt,1],;
     	                    aMostraOVd[oLbGrpT:nAt,2],;
     	                    FG_AlinVlrs(Transform(aMostraOVd[oLbGrpT:nAt,3],"@E 999,999,999.99")) }}

	@ 172,203 TO 295,393 LABEL (STR0331) OF oAnaCus PIXEL // Composicao das Parcelas
	@ 179,205 LISTBOX oLbGrpP FIELDS HEADER OemToAnsi(STR0119),OemToAnsi(STR0061),OemToAnsi(STR0023) COLSIZES 30,50 SIZE 185,113 OF oAnaCus PIXEL
	oLbGrpP:SetArray(aMostraPar)
	oLbGrpP:bLine := { || { Transform(aMostraPar[oLbGrpP:nAt,1],"@D"),;
     	                    aMostraPar[oLbGrpP:nAt,2],;
     	                    FG_AlinVlrs(Transform(aMostraPar[oLbGrpP:nAt,3],"@E 999,999,999.99")) }}
     	                    
	@ 297,340 BUTTON oSair PROMPT OemToAnsi(STR0245) OF OAnaCus SIZE 43,11 PIXEL ACTION  oAnaCus:End() // SAIR

ACTIVATE MSDIALOG oAnaCus CENTER

Return()

/////////////////////////////////////////////////////////////////////
//  Calcula a Data de Entrega  -  Andre Luis Almeida  -  03/12/09  //
/////////////////////////////////////////////////////////////////////
Static Function FS_CALCDTENT(_cTp,_cNUMATE,_lTela)
Local aRet      := {}
Local aParamBox := {}
Local cSlvCad   := cCadastro
Local dDtESug   := dDataBase
Local dDtEPrv   := ctod("")
Local nRecVV1   := VV1->(RecNo())
Local nRecVV2   := VV2->(RecNo())
Local nRecVVA   := VVA->(RecNo())
Local nRecVE4   := VE4->(RecNo())
Local nTamObs   := 0
Local Cont      := 0
Local nDias     := 0
Local lEmBranco := .t.
Local lGrava    := .f.
Local lMostraMsg := .t.
Local lFazLevant := .t.
Private cCadastro:= STR0332 // Previsao de Entrega
Default _cTp     := "1" // 1-Inclui 2-Excluir
Default _cNUMATE := M->VV0_NUMTRA
Default _lTela   := .t.

DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("VVA_OBSENT")
nTamObs   := x3_tamanho

If VVA->(FieldPos("VVA_DTEPRV")) <> 0 .and. VVA->(FieldPos("VVA_DTESUG")) <> 0 .and. VVA->(FieldPos("VVA_DTEREA")) <> 0 .and.  VV2->(FieldPos("VV2_QTDENT")) <> 0 .and. VE4->(FieldPos("VE4_QTDENT")) <> 0
	DbSelectArea("VVA")
	DbSetOrder(1)
	If DbSeek( xFilial("VVA") + _cNUMATE )
		While !Eof() .and. xFilial("VVA") == VVA->VVA_FILIAL .and. _cNUMATE == VVA->VVA_NUMTRA
			If _cTp == "1" // 1-Inclui
				If ( Inclui .or. Altera ) .and. !Empty(VVA->VVA_DTEPRV)
					If lMostraMsg // Faz apenas uma vez a perguta
						lMostraMsg := .f.
						lFazLevant := .f.
						If _lTela
							If MsgYesNo(STR0333,STR0012) // Deseja recalcular a Data de Sugestao de Entrega? / Atencao
								lFazLevant := .t.
							EndIf
						EndIf
					EndIf		
				EndIf
				DbSelectArea("VV1")
				DbSetOrder(1)
				DbSeek(xFilial("VV1")+VVA->VVA_CHAINT)
				If ( Inclui .or. Altera ) .and. lFazLevant
					DbSelectArea("VE4")
					DbSetOrder(1)
					If DbSeek(xFilial("VE4")+VV1->VV1_CODMAR)
						If VE4->VE4_QTDENT > 0
							nDias := 0
							ni    := 0
							While .t.
								nDias++
								If dow(dDtESug+nDias) <> 7 .and. dow(dDtESug+nDias) <> 1 // Dias Uteis, desprezar Sabado e Domingo
									ni++
									If ni >= VE4->VE4_QTDENT
										Exit
									EndIf
								EndIf
							EndDo
							dDtESug += nDias
						EndIf
					EndIf
					DbSelectArea("VV2")
					DbSetOrder(1)
					If DbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI)
						If VV2->VV2_QTDENT > 0
							nDias := 0
							ni    := 0
							While .t.
								nDias++
								If dow(dDtESug+nDias) <> 7 .and. dow(dDtESug+nDias) <> 1 // Dias Uteis, desprezar Sabado e Domingo
									ni++
									If ni >= VV2->VV2_QTDENT
										Exit
									EndIf
								EndIf
							EndDo
							dDtESug += nDias
						EndIf
					EndIf
					If ExistBlock("PVM011DTENT")
						dDtESug := ExecBlock("PVM011DTENT",.f.,.f.,{VVA->VVA_NUMTRA,VVA->VVA_CHAINT,dDtESug})
					Endif
				Else
					dDtESug := VVA->VVA_DTESUG
				EndIf
				dDtEPrv := dDtESug
				If !Empty(VVA->VVA_DTEPRV)
					dDtEPrv := VVA->VVA_DTEPRV
				EndIf
				lGrava  := .f.
				cObserv := ""
				If _lTela 
					// ParamBox //
					aParamBox := {}
					aAdd(aParamBox,{1,RetTitle("VVA_DTESUG"),dDtESug,"@D","","",".f.",0,.f.})
					aAdd(aParamBox,{1,RetTitle("VVA_DTEPRV"),dDtEPrv,"@D","!Empty(MV_PAR02)","","",0,.t.})
					If ParamBox(aParamBox,VVA->VVA_CHASSI,@aRet,,,,,,,,.F.)
						If aRet[1]<>aRet[2]
							While Empty(cObserv)
								FS_Obs011(cCadastro+" - "+STR0291,VVA->VVA_ENTMEM,"VVA_ENTMEM","VVA_OBSENT",.t.) // Precisao de Entrega - Observacoes
								If !Empty(cObserv)
									lEmBranco := .t.
									For Cont := 1 to MLCount(cObserv,nTamObs)
										If !Empty(MemoLine(cObserv,nTamObs,Cont))
											lEmBranco := .f.
											Exit
										EndIf
									Next
									If lEmBranco
										cObserv := ""
									EndIf
								EndIf
							EndDo
						EndIf
						lGrava := .t.
						dDtESug := aRet[1]
						dDtEPrv := aRet[2]
					EndIf
				Else
					lGrava := .t.
				EndIf
				If lGrava .and. ( Inclui .or. Altera ) 
					DbSelectarea("VVA")
					RecLock("VVA",.f.)
						VVA->VVA_DTESUG := dDtESug // Grava Dt. de Entrega sugerida pelo sistema
						VVA->VVA_DTEPRV := dDtEPrv // Grava Dt. de Entrega prevista pelo usuario (vendedor)
						MSMM(,TamSx3("VVA_OBSENT")[1],,cObserv,1,,,"VVA","VVA_ENTMEM") // Observacao
					MsUnlock()
				EndIf
			Else //	If _cTp == "2" // 2-Excluir
				cObserv := ""
				DbSelectarea("VVA")
				RecLock("VVA",.f.)
					VVA->VVA_DTESUG := ctod("") // Apaga Dt. de Entrega sugerida pelo sistema
					VVA->VVA_DTEPRV := ctod("") // Apaga Dt. de Entrega prevista pelo usuario (vendedor)
					VVA->VVA_DTEREA := ctod("") // Apaga Dt. Real de Entrega
					MSMM(,TamSx3("VVA_OBSENT")[1],,cObserv,1,,,"VVA","VVA_ENTMEM") // Observacao
				MsUnlock()
			EndIf
			DbSelectArea("VVA")
			DbSkip()
		EndDo
	Else
		If _lTela
			MsgInfo(STR0334,STR0012) // Somente e' possivel calcular a Sugestao da Data de Entrega apos gravacao do Atendimento / Atencao
		EndIf
	EndIf
EndIf
VVA->(DbGoTo(nRecVVA))
VV1->(DbGoTo(nRecVV1))
VV2->(DbGoTo(nRecVV2))
VE4->(DbGoTo(nRecVE4))
cCadastro := cSlvCad
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |Fs_TestDrivº Autor ³ Manoel             º Data ³ 08/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chama Ponto de Entrada para Impressao de Form. TestDrive   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TestDrive()

If ExistBlock("PEVM011ITD")
	ExecBlock("PEVM011ITD",.f.,.f.)
EndIf

return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |Fs_TestDrivº Autor ³ Manoel             º Data ³ 08/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chama Ponto de Entrada para Impressao de Form. TestDrive   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CBOX(cSeek)	// Cria ComboBox com SX3
	Local cRet := ""
	Local cCBx := ""
	Local ni   := 0
	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek(cSeek)
	cCBx := X3CBOX()
	cRet := '"'
	For ni := 1 to len(cCBx)
		cRet += Alltrim(If(substr(cCBx,ni,1)==";",'","',substr(cCBx,ni,1)))
	Next
	cRet := "{"+Alltrim(cRet)+'"}'
Return(&cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |FS_GRVDTAPRº Autor ³ Andre Luis Almeida º Data ³ 15/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava a Data de Aprovacao da Proposta                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRVDTAPR(nTp)
If VV0->(FieldPos("VV0_DATAPR")) <> 0
	M->VV0_DATAPR := dDataBase
	If nTp == 2 // RecLock no VV0
		RecLock("VV0",.f.)
			VV0->VV0_DATAPR := M->VV0_DATAPR
		MsUnLock()
	EndIf
EndIf
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | FS_OBSNF  º Autor ³ Andre Luis Almeida º Data ³ 05/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Observacao para Impressao da NF                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OBSNF(nOpc)
If VV0->(FieldPos("VV0_OBSMNF")) > 0
	If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
		M->VV0_OBSENF := FM_OBSMEM("Observacao na Impressao da NF",VV0->VV0_OBSMNF,"VV0_OBSMNF","VV0_OBSENF",.t.,.t.) // Titulo Janela, Campo Caracter, Nome do Campo Caracter, Campo Memo, Altera (.t./.f.) , Traz Texto existente (.t./.f.)
		If Empty(M->VV0_OBSENF)
			M->VV0_OBSENF := CHR(13)+CHR(10) // Limpar Observacao da NF
		EndIf
		DbSelectArea("VV0")
		MSMM(,TamSx3("VV0_OBSENF")[1],,M->VV0_OBSENF,1,,,"VV0","VV0_OBSMNF")
		M->VV0_OBSMNF := VV0->VV0_OBSMNF
	Else
		FM_OBSMEM("Observacao na Impressao da NF",VV0->VV0_OBSMNF,"VV0_OBSMNF","VV0_OBSENF",.f.,.t.) // Titulo Janela, Campo Caracter, Nome do Campo Caracter, Campo Memo, Altera (.t./.f.) , Traz Texto existente (.t./.f.)
	EndIf
EndIf
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | VM011RES  º Autor ³ Rafael Goncalves   º Data ³ 07/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida se existe reserva em outro atendimento              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VM011RES()

Local nRegVV0 := VV0->(Recno())
Local nRegVV1 := VV1->(Recno())
Local lAltRes	:= .t.
Local cAtend	:=""
Local cQueryVV0 := ""
Local cQAliasVV0:= "SQLVV0"
Local cBloqStat := GetNewPar("MV_BLQSTAV","LO") // Nao mostrar veiculos que estao em Atendimentos com os STATUS informados neste Parametro
   
Private dDtRes  	:= ctod("")
Private cHorRes 	:= space(5)
Private nLimDia := 0 //dias da regra de reserva.

//ler VV0 para verificar se veiculo reservado em outro atendimento.
cQueryVV0 := "SELECT VVA.VVA_NUMTRA , VVA.VVA_CHASSI , VV0.VV0_RESERV , VV0.VV0_DATVAL , VV0.R_E_C_N_O_ , VV0.VV0_HORVAL , VV0.VV0_NUMTRA FROM "+RetSqlName("VVA")+" VVA "
cQueryVV0 += " JOIN "+ RetSqlName("VV0")+" VV0 ON (VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND VV0.VV0_NUMTRA=VVA.VVA_NUMTRA AND VV0.D_E_L_E_T_=' ') "
cQueryVV0 += " JOIN "+ RetSqlName("VV9")+" VV9 ON (VV9.VV9_FILIAL='"+xFilial("VV9")+"' AND VV9.VV9_NUMATE=VVA.VVA_NUMTRA AND VV9.VV9_STATUS NOT IN ('C','F','D') AND VV9.D_E_L_E_T_=' ') "
cQueryVV0 += "WHERE VVA.VVA_CHASSI='"+M->VV0_CHASSI+"' AND VV0.VV0_RESERV IN ('1','3') AND VVA.VVA_FILIAL IN "+FormatIN(FM_ALLFIL("VVA"),",")+" AND VVA.D_E_L_E_T_=' '" 
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryVV0 ), cQAliasVV0, .F., .T. )   //VV9_STATUS NOT IN ('C','F','T','R','D') 
Do While !( cQAliasVV0 )->( Eof() )
	cAtend	:= ( cQAliasVV0 )->( VV0_NUMTRA )
	dDtRes	:= stod(( cQAliasVV0 )->( VV0_DATVAL ))
	cHorRes	:= ( cQAliasVV0 )->( VV0_HORVAL )
	
	IF ( cQAliasVV0 )->( VV0_NUMTRA ) <> M->VV0_NUMTRA  //verifica se a reserva do veiculo é para outro atendimento.
		lAltRes := .f.
	EndIF 
	
 	if !( cQAliasVV0 )->( VV9_STATUS ) $ cBloqStat //status diferente de Liberado realiza o cancelamentod a reserva.	
   			//verificar se a reserva nao esta vencida se tiver cancela a reserva
		If dDtRes <= dDataBase // data da reserva for menor ou igual a data de hoje
			if cHorRes < SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)//se a hora for menor que a hora atual
				//cancelar reserva do veiculo
				dbSelectArea("VV0")
		   		VV0->(DbGoTo(( cQAliasVV0 )->( R_E_C_N_O_ )))
				If VV0->VV0_RESERV $ "1/3"
					VV0->(RecLock("VV0",.f.))
						VV0->VV0_RESERV := ""
						VV0->VV0_DATVAL := ctod("")
						VV0->VV0_HORVAL := space(5)
					VV0->(MsUnlock())    
			    EndIF
			    dbSelectArea("VV1")//cancela reserva do veiculo.
				dbSetOrder(2)
				if dbSeek(xFilial("VV1")+( cQAliasVV0 )->( VVA_CHASSI ))
	                IF VV1->VV1_RESERV $ "1/3"
						VV1->(RecLock("VV1",.f.))
							VV1->VV1_RESERV := ""
							VV1->VV1_DTHRES := ""
							VV1->VV1_DTHVAL := ""
						VV1->(MsUnlock())
				    EndIF
				EndIF 
				lAltRes := .t.
		    EndIf
		EndIF		
	EndIf 
										
	( cQAliasVV0 )->( DbSkip() )
EndDo
( cQAliasVV0 )->( dbCloseArea() ) 
                                    
DbSelectArea("VV0") //posiciona novamente no registro salvo
VV0->(DbGoTo(nRegVV0))
DbSelectArea("VV1")	//posiciona novamente no registro salvo
VV1->(DbGoTo(nRegVV1))
If !lAltRes
	MsgInfo("Veiculo ja reservado para o atendimento: "+cAtend ,STR0012) //Usuario sem permissao para reservar veiculo... ### Atencao		
EndIF                        
Return(lAltRes)


Static Function FM_ALLFIL(cParAlias)
Return cFilAnt

