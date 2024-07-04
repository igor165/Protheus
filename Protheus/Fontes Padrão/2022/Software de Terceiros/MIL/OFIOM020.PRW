#include "Protheus.ch"
#include "TopConn.ch"
#include "OFIOM020.CH"

#INCLUDE "ofixdef.ch"

#DEFINE PECAORC_TIPTEM    02
#DEFINE PECAORC_CLIFAT    03
#DEFINE PECAORC_LOJFAT    04
#DEFINE PECAORC_NOME      05
#DEFINE PECAORC_GRUITE    06
#DEFINE PECAORC_CODITE    07
#DEFINE PECAORC_DESRICAO  08
#DEFINE PECAORC_QTDITE    09
#DEFINE PECAORC_FORMUL    10
#DEFINE PECAORC_VALPEC    11
#DEFINE PECAORC_LOCPAD    12
#DEFINE PECAORC_LOCALIZ   13
#DEFINE PECAORC_RESPEC    14
#DEFINE PECAORC_GRUINCONV 15
#DEFINE PECAORC_CODINCONV 16
#DEFINE PECAORC_DESINCONV 17
#DEFINE PECAORC_RECNO     18
#DEFINE PECAORC_CODTES    19
#DEFINE PECAORC_SEQINCONV 20
#DEFINE PECAORC_NUMORC    21
#DEFINE PECAORC_FORMU2    22
#DEFINE PECAORC_PERDES    23
#DEFINE PECAORC_VALDES    24
#DEFINE PECAORC_VALORLIQ  25
#DEFINE PECAORC_OPER      26
#DEFINE PECAORC_ESTOQUE   27
#DEFINE PECAORC_DEPGAR    28
#DEFINE PECAORC_DEPINT    29
#DEFINE PECAORC_LOTECT    30
#DEFINE PECAORC_NUMLOT    31
#DEFINE PECAORC_CODIGOVSJ 32
#DEFINE PECAORC_ORIDAD    33
#DEFINE PECAORC_B1COD     34
#DEFINE PECAORC_QTDRES    35
#DEFINE PECAORC_SUGCOM    36

#DEFINE X3_USADO_EMUSO "€€€€€€€€€€€€€€ " // TORNA USADO POR TODOS OS MODULOS

Static cMVGRUVEI  		:= GetMv("MV_GRUVEI")
Static cMVCHKCRE  		:= GetMv("MV_CHKCRE")
Static lCtrlLote   		:= GetNewPar("MV_RASTRO", "N") == "S"
Static cCREDCLI   		:= SuperGetMv("MV_CREDCLI")
Static lInconveniente 	:= (GetNewPar("MV_INCORC", "N") == "S")
Static cMVMIL0006 		:= GetNewPar("MV_MIL0006", "") // Codigo da Marca da Concessionaria
Static lCANUSETT  		:= FindFunction("FMX_CANUSETT")
Static lVOITPATEN 		:= FindFunction("FGX_VOITPATEN")
Static OFNJD15011 		:= FindFunction("OFNJD15011_RetornaMarca")
Static PEVERTPGCC 		:= ExistBlock("VERTPGCC")
Static lOm020Ast  		:= ExistBlock("OM020AST")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ OFIOM020 ณ Autor ณ  Fabio                ณ Data ณ 19/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Requisicao de Pecas                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico  (Modelo3)                                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOM020(cOSFiltro, lNoMBrowse, xAutoItens, nOpcAuto)
Private aHeader := {}
Private cCadastro := (STR0001),cReqDev := "1",cGruFor := "04" //"Requisicao de Pecas"
Private aIndVO1   := {}
Private cCondicao := ""
Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private aRotina := MenuDef()
Private aPecReqDupl := {}
Private aIteRel := {{"","","",0,0,"","",""}}					// Vetor contendo os itens relacionados da listbox oLItRel
Private lachou := .f.
Private cNumOrc  := ""
Private lA1_IBGE := SA1->(FieldPos("A1_IBGE")) <> 0 // Verifica se existe o campo SA1->A1_IBGE
Private M->VO3_OPER := ""
Private aNewBot := {}
Private oReqPecDao := Nil
Private oArrHelper := DMS_ArrayHelper():New()
//
Private bRefresh := { || .t. } // Variavel necessaria ao MAFISREF
Private cTpTpoPEVM := space(4) // Tipo de Tempo Pecas
Private cProdPEVM  := space(6) // Tipo de Tempo Servico
//
Private aAutoItens := {}
Private lOM020Auto := ( xAutoItens <> NIL )
Private oCliente   := DMS_Cliente():New()
Private lNaForte   := GetNewPar("MV_MIL0132",.F.)
Private OFP8600016 := ExistFunc("OFP8600016_VerificacaoFormula")
//
Private lVOICONVOW := (VOI->(FieldPos("VOI_CONVOW")) > 0)
Private aPecaSel := {} // Controla as linhas que ja estejam selecionadas
//
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRafael - 22/03   ณ
//ณFiltro do Mbrowseณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Default cOSFiltro := ""
Default lNoMBrowse := .f.
//
If ExistBlock("OM020INI")
	ExecBlock("OM020INI",.f.,.f.)
EndIf
//

//AjustaHelp()

// Valida se a empresa tem autorizacao para utiliza o modulo de oficina.
If AMIIn(11,14,41)

	//Altera a opera็ใo da Devolu็ใo de 6 para 3
	//Devolu็ใo que estแ como 6  
	//por motivos de compatibiliade
	//com o cadastro de Privil้gios
	aRotina[3,4] := 3

	dbSelectArea("VO1")
	dbSetOrder(1)
	VO1->(dbClearFilter())

	// Monta parametros da Rotina ...
	//Local aCPOPerg := { "VO3_OPER","VO3_CODTES","VO3_FORMUL","VO3_FATPAR","VO3_LOJA  " } // NAO ADICIONAR MAIS CAMPOS
	//Local aHelpCpo := {STR0186,STR0187,STR0188,STR0189,STR0190} // Informe Operacao Remessa Atend.Externo / Informe Tes Remessa Atend.Externo / Informe Formula Remessa Atend.Externo / Informe Cliente Remessa Atend.Externo / Informe Loja Remessa Atend.Externo
	//SX3->(dbSetOrder(2))
	//For nCont := 1 to Len(aCPOPerg)
	//	SX3->(dbSeek(aCPOPerg[nCont]))
	//	AADD(aRegs,{ SX3->X3_TITULO , SX3->X3_TITSPA , SX3->X3_TITENG , 'MV_CH' + Str(nCont,1) , ;
	//				 SX3->X3_TIPO   , SX3->X3_TAMANHO,,,'G','','MV_PAR' + StrZero(nCont,2),'','','','','','','','','','','','','','','','','','','','','','','','',;
	//				 SX3->X3_F3,;
	//				 '','','',;
	//				 SX3->X3_PICTURE,{aHelpCpo[nCont]},{aHelpCpo[nCont]},{aHelpCpo[nCont]}})
	//Next nCont
	//AADD(aRegs,{ STR0265,STR0265,STR0265,'MV_CH6','N',1,0,1,'C','','MV_PAR06','Sim','Sim','Sim','','','Nใo','Nใo','Nใo','','','','','','','','','','','','','','','','','','','','','',; // Altera quantidade utilizada ?
	//	{ "Permite alterar quantidade utilizada",;
	//	  "no retorno de remessa para atendimento",;
	//	  "externo."},{},{}})

	If !lOM020Auto
		If lNoMBrowse
			dbSelectArea("VO1")
			If ( nOpc <> 0 ) .And. !Deleted()
				bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nOpc,2 ] + "(a,b,c,d,e) }" )
				Eval( bBlock, Alias(), (Alias())->(Recno()),nOpc)
			EndIf
		Else

			IF !empty(cOSFiltro)
				FilBrowse("VO1",{},"VO1->VO1_FILIAL=='"+xFilial("VO1")+"' .and. VO1->VO1_NUMOSV=='"+cOSFiltro+"'",.t.) 	// Filtra a OS
			Else
				dbSelectArea("VAI")
				dbSetOrder(4)
				dbSeek(xFilial("VAI")+__cUserID)

				if VAI->VAI_TIPTEC == "4"
					DbSelectArea("VO1")
					dbSetOrder(1)

					cCondicao := "VO1->VO1_FUNABE == VAI->VAI_CODTEC"

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Endereca a funcao de BROWSE                                  ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					bFiltraBrw := {|| FilBrowse("VO1",@aIndVO1,@cCondicao) }
					Eval(bFiltraBrw)

				Endif
			Endif
			SetKey(VK_F12,{ || Pergunte( "OFM020REM", .T. ,,,,.f.)})
			mBrowse(6, 1, 22, 75, "VO1",,,,,, OM020LEG())
			SetKey(VK_F12,Nil)
			dbSelectArea("VO1")
			dbClearFilter()
		EndIf
	Else
		aAutoItens := xAutoItens
		MBrowseAuto( nOpcAuto , , "VO1" , .f. , .t. )
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM020     บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM020(cAlias,nReg,nOpc)

//Local bCampo   := { |nCPO| Field(nCPO) }
Local _ni := 0
Local cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Local ny, nNew
Local aRegVO3 := {}
Local cMsg := ""
Local cMsgRem := ""
Local lCpoDesconto := .f.
Local lRotAutom := .f. // EXECAUTO - Verifica se Rotina executada de forma automatica via outras rotinas Padroes permitidas
Private nTotal := 0 , nOpcE := 0 , nOpcG := 0 , nUsado := 0
Private cabec1,cabec2,nLastKey:=0,wnrel,tamanho:="P"
Private aCpoEnchoice := {} , aCols := {} ,  aItensRel := {} , cTitulo
Private aPecaOrc := {}
Private aKeys := {}
Private l241:=.F.,l242:=.F.
Private aIteaDev := {} // Itens de Devolucao
Private lJaexec  := .f.
Private aAlterMan // Campos da Getdados que podem ser alterados quando for requisicao avulsa
Private aAlterOrc // Campos da Getdados que podem ser alterados quando for requisicao de peca vinda do orcamento

Private aAvCred := {}
Private lVldCredLOK := .f.

Private lVSJCODIGO := (VSJ->(FieldPos("VSJ_CODIGO")) <> 0)

if lachou
	lachou := .f.
	Return
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida se a Ordem de Servico esta aberta.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if iif(lOm020Ast,ExecBlock("OM020AST",.F.,.F.,{VO1->VO1_STATUS}),VO1->VO1_STATUS) # "A"
	Help("  ",1,"OSNABERTA")

	DbSelectArea("VO1")
	DbSetOrder(1)
	//	Eval(bFiltraBrw)

	Return

EndIf

If nOpc == 2
	// EXECAUTO - Verifica se Rotina executada de forma automatica via outras rotinas Padroes permitidas
	lRotAutom := (	FWIsInCallStack("OFIA212")  .or. ;
					FWIsInCallStack("OFINJD15") .or. ;
					FWIsInCallStack("OFINNH20") .or. ;
					FWIsInCallStack("OFIOM490") .or. ;
					FWIsInCallStack("OFIA310") .or. ;
					FwIsInCallStack("OM0200025_ReqPecaNaoUtilizada") ;
				)
	If !lRotAutom .And. GetNewPar("MV_MIL0145","0") == "1" // Se nao for Rotina Automatica e Trabalhar com Conferencia de Itens na Oficina - NAO DEIXA REQUISITAR - Serแ necessario fazer via Conferencia
		FMX_HELP("OFIOM020_MV_MIL0145", STR0292, STR0293) // Impossํvel Requisitar Pe็as quando a Confer๊ncia de Itens Oficina estiver ativa! / Necessแrio requisitar via rotina de Confer๊ncia de Itens Oficina.
		Return
	EndIf
	cReqDev := "1"     // Requisicao
Else
	cReqDev := "0"     // Devolucao
EndIf

If FindFunction("FM_VEIGAR")
	FM_VEIGAR(VO1->VO1_CHAINT,) // Verifica se o Veiculo esta em garantia - 04/05/2009 - Andre Luis Almeida
EndIf

DbSelectArea("VO2")
DbSetOrder(1)
DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV+"P")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da Enchoice                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("VO2",.T.)

aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VO2")
While !Eof().and.(x3_arquivo=="VO2")

	If X3USO(SX3->x3_usado).and.cNivel>=SX3->x3_nivel.And.!(Alltrim(SX3->x3_campo) $ [VO2_TIPREQ/VO2_DEVOLU])
		AADD(aCpoEnchoice,SX3->x3_campo)
	Endif

	If Alltrim(x3_campo) $ "VO2_NOSNUM"
		&( "M->"+Alltrim(SX3->x3_campo) ) := GetSxeNum("VO2",SX3->x3_campo,,2)
		ConfirmSx8()
	Else
		&( "M->"+Alltrim(SX3->x3_campo) ) := CriaVar(SX3->x3_campo)
	EndIf

	dbSkip()
End

// Fixar nOPC
nOpc  := 3
nOpcE := 2
nOpcG := 3

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria variaveis M->????? da Enchoice                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RegToMemory("VO3",.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria aHeader e aCols da GetDados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nUsado:=0
aHeader:={}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDevolucao de Requisicaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cReqDev  == "0"

	dbSelectArea("VAI")
	dbSetOrder(4)
	dbSeek(xFilial("VAI")+__cUserID)
	if VAI->(FieldPos("VAI_DEVPEC")) > 0
		if VAI->VAI_DEVPEC == "0"
			Help(" ",1,"M020PERMDEV")
			Return .f.
		Endif
	Endif
	If lJaexec
		lJaexec := .f.
		Return .f.
	endif

	FS_Dev020()

	// Controla os registro de origem da devolucao...
	// para tentar impedir que dois usuarios tentem devolver o mesmo produto ...
	aRegVO3 := {}

	If Len(aIteaDev) > 0
		FS_MTPECAAHEAD(.T.)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Indica se os campos de desconto estao criado ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		if FG_POSVAR("VO3_VALDES") <> 0 .and. VO3->(FieldPos("VO3_VALDES")) <> 0 .and. ;
			FG_POSVAR("VO3_PERDES") <> 0 .and. VO3->(FieldPos("VO3_PERDES")) <> 0 .and. ;
			VO3->(FieldPos("VO3_VALLIQ")) <> 0
			lCpoDesconto := .t.
		endif

		aCols := {}
		For ny := 1 to Len( aIteaDev )

			If aIteaDev[ny,9] > 0 .and. aIteaDev[ny,1]

				Aadd(aCols, Array( Len(aHeader)+1 ) )

				DbSelectArea("VO3")
				DbGoto(aIteaDev[ny,13,1])

				For nNew := 1 to Len( aHeader )
					If aHeader[nNew,2] == "VO3_CODVSJ"
						aCols[Len(aCols),nNew] := Space(TamSX3("VO3_CODVSJ")[1])
						Loop
					EndIf
					aCols[Len(aCols),nNew]:=If(aHeader[nNew,10] # "V",FieldGet(FieldPos(aHeader[nNew,2])),CriaVar(aHeader[nNew,2]))
				Next
				aCols[Len(aCols),FG_POSVAR("VO3_QTDREQ")] := aIteaDev[ny,9]
				If lCpoDesconto .and. VO3->VO3_VALDES <> 0
					aCols[Len(aCols),FG_POSVAR("VO3_VALDES")] := ( VO3->VO3_VALPEC - VO3->VO3_VALLIQ ) * aIteaDev[ny,9]
				EndIf
				aCols[Len(aCols),nUsado+1]:=.F.

				// Adiciona na matriz para bloquear registros da VO3...
				// Tentativa para evitar que duas conexoes devolvam a mesma peca ao mesmo tempo ...
				For _ni := 1 to Len(aIteaDev[ny,13])
					If (aScan( aRegVO3 , aIteaDev[ny,13,_ni] )) == 0
						AADD( aRegVO3 , aIteaDev[ny,13,_ni] )
					EndIf
				Next _ni
				//

			Endif

		Next

		If Len(aCols) > 0

			// Tenta Bloquear todos os registros da tabela VO2
			For nY := 1 to Len(aRegVO3)
				VO3->(dbGoTo(aRegVO3[nY]))
				If !RecLock("VO3",.F.)
					Help("  ",1,"REGNLOCK")
					MsUnlockAll()
					aCols := {} // Zera aCols para nao processar nada ...
					Return
				EndIf
			Next nY
			//

			// Verifica o saldo da requisicao de todas as pecas ...
			cMsg := ""
			cMsgRem := ""
			If !FS_SALDPEC(@cMsg,@cMsgRem)
				MsUnlockAll()
				Aviso(STR0075,;
					STR0128 + CHR(13) + CHR(10) + ; // "Nใo foi possํvel realizar a devolu็ใo."
					IIF(!Empty(cMsg)    , STR0129 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cMsg    + CHR(13) + CHR(10) , "" ) + ; // Problema(s) no saldo de requisi็ใo no(s) seguinte(s) registo(s):
					IIF(!Empty(cMsgRem) , STR0164 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cMsgRem , "" ) ,; // "Saldo de pe็as em remessa serแ maior do que o saldo de pe็as requisitado"
					{ STR0130 } , 3 ) // OK
				Return
			EndIf
			//

			FS_CHAMAGRAREQ()
		Endif
		lJaexec := .t.

	Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRequisicao de Pecasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Else

	SETKEY(VK_F4,{|| OM020KEYF4() })

	FS_MTPECAAHEAD()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta o aCols                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lOM020Auto
		aCols:={Array(nUsado+1)}
		aCols[1,nUsado+1]:=.F.
		For _ni:=1 to nUsado
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
			If aHeader[_ni,2] == "VO3_PROREQ"
				VAI->(DbSetOrder(4))
				VAI->(DbSeek(xFilial("VAI")+__cUserID))
				If VAI->VAI_FUNPRO=="1" .and. VAI->VAI_REQPEC == "1"
					aCols[1,_ni] := VAI->VAI_CODTEC
				EndIf
			EndIf
		Next
	EndIf

	If ExistBlock("OM3020TP")
		ExecBlock("OM3020TP",.f.,.f.)
	EndIf

	lJaexec := .f.

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Executa a Modelo 3                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cTitulo       :=If(cReqDev == "1",STR0001,STR0007) //"Requisicao de Pecas"###"Devolucao de Pecas"
	cAliasEnchoice:="VO2"
	cAliasGetD    :="VO3"
	cLinOk        :="FS_LINOK020()"
	cTudOk        :="FS_TUDOK020()"
	cFieldOk      :="FS_FIELD020()"

	FS_Mod3020(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)

	SetKey(VK_F4,Nil)

Endif

If !lOM020Auto
	dbSelectArea("VAI")
	dbSetOrder(4)
	dbSeek(xFilial("VAI")+__cUserID)
	// Volta Filtro
	if VAI->VAI_TIPTEC == "4"
		If Type("bFiltraBrw") # "U"
			bFiltraBrw := {|| FilBrowse("VO1",@aIndVO1,@cCondicao) }
			Eval(bFiltraBrw)
			///	VO1->(DbGoTo(nRecnoVO1))
		EndIf
	Endif
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_MTPECAAHEAD  บAutor  ณMicrosiga    บ Data ณ  07/08/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta aHeader                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function  FS_MTPECAAHEAD( lTodoCampos )

Local cCampos
Local cInc := ""

if !lInconveniente
	cInc := "VO3_GRUINC/VO3_CODINC/VO3_DESINC/VO3_SEQINC/"
endif

If cReqDev == "1" // Requisicao
	cCampos := cInc+"VO3_DESGRU/VO3_DEPOSV/VO3_NUMNFI/VO3_SERNFI/VO3_DATFEC/VO3_HORFEC/VO3_DATDIS/VO3_HORDIS/VO3_FUNFEC/VO3_NOSNUM/VO3_PECINT/VO3_DESTEM/VO3_VALGRU/VO3_VALBRU/VO3_ALQICM/VO3_VALICM/VO3_DATCAN/VO3_HORCAN/VO3_CONSRV/VO3_NUMDOC/VO3_ACRESC/VO3_MARLUC/VO3_NUMOSV/VO3_LIBVOO/VO3_PEDNUM/VO3_PEDITE/VO3_VECREL/VO3_ITENFI/VO3_CENCUS/VO3_CONTA/VO3_ITEMCT/VO3_CLVL/VO3_FUNDIS"
Else // Devolucao
	cCampos := cInc+"VO3_PROREQ/VO3_DEPINT/VO3_DEPGAR/VO3_FORMUL/VO3_VALPEC/VO3_VALTOT/VO3_DESGRU/VO3_DEPOSV/VO3_NUMNFI/VO3_SERNFI/VO3_DATFEC/VO3_HORFEC/VO3_DATDIS/VO3_HORDIS/VO3_DATCAN/VO3_HORCAN/VO3_FUNFEC/VO3_NOSNUM/VO3_PECINT/VO3_DESTEM/VO3_PERDES/VO3_VALDES/VO3_VALGRU/VO3_VALBRU/VO3_ALQICM/VO3_VALICM/VO3_DATCAN/VO3_HORCAN/VO3_CONSRV/VO3_NUMDOC/VO3_NUMSER/VO3_ACRESC/VO3_MARLUC/VO3_CENCUS/VO3_CONTA/VO3_ITEMCT/VO3_CLVL  /VO3_CODVSJ/"
EndIf

Default lTodoCampos := .f.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria aHeader e aCols da GetDados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nUsado:=0
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VO3")
aHeader:={}
While !Eof().And.(x3_arquivo=="VO3")

	If X3USO(x3_usado).And.cNivel>=x3_nivel.And.( !(Alltrim(x3_campo) $ cCampos) .Or. ( lTodoCampos ) )

		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )

	Endif

	&( "M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)

	DbSkip()
End

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ FS_Mod3020 ณ Autor ณ Fabio               ณ Data ณ 12/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณEnchoice e GetDados                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณlRet:=Modelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,      ณฑฑ
ฑฑณ          ณ cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice)ณฑฑ
ฑฑณ          ณlRet=Retorno .T. Confirma / .F. Abandona                    ณฑฑ
ฑฑณ          ณcTitulo=Titulo da Janela                                    ณฑฑ
ฑฑณ          ณcAlias1=Alias da Enchoice                                   ณฑฑ
ฑฑณ          ณcAlias2=Alias da GetDados                                   ณฑฑ
ฑฑณ          ณaMyEncho=Array com campos da Enchoice                       ณฑฑ
ฑฑณ          ณcLinOk=LinOk                                                ณฑฑ
ฑฑณ          ณcTudOk=TudOk                                                ณฑฑ
ฑฑณ          ณnOpcE=nOpc da Enchoice                                      ณฑฑ
ฑฑณ          ณnOpcG=nOpc da GetDados                                      ณฑฑ
ฑฑณ          ณcFieldOk=validacao para todos os campos da GetDados         ณฑฑ
ฑฑณ          ณlVirtual=Permite visualizar campos virtuais na enchoice     ณฑฑ
ฑฑณ          ณnLinhas=Numero Maximo de linhas na getdados                 ณฑฑ
ฑฑณ          ณaAltEnchoice=Array com campos da Enchoice Alteraveis        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณRdMake                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_Mod3020(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice)
Local nOpca := 0
Local nReg:=(cAlias1)->(Recno())
Local aObjects := {} , aPosObj := {} , aInfo := {} , aSizeAut := MsAdvSize() // Variaveis para posicionamento de Tela
Local nAuxPos := 0

Local nAuxLin, nAuxCol

Local lImpVSJ := .f.
Local aQReqConf := {}
Local nColCODVSJ := 0
Local nColQTDREQ := 0

Private oDlgReqPec
Private oLbIteRel,ItensRel:={},oTotal,oFonte   := TFont():New( "System", 8, 12 )
Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0)
Private bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

nOpcE := If(nOpcE==Nil,3,nOpcE)
nOpcG := If(nOpcG==Nil,3,nOpcG)
lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
nLinhas:=Iif(nLinhas==Nil,99,nLinhas)

aAlterMan := {}
aAlterOrc := {}

If !lOM020Auto

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta matriz auxiliar para saber os campos que podem ser alterados da GetDados ณ
	//ณ Quando for peca de orcamento, nao deixar alterar alguns campos                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nAuxPos := 1 to Len(aHeader)
		// Evitando estes campos de serem alterados em geral ja evita a requisicao de nova linha ;)
		if lNaForte .and. aHeader[nAuxPos,2] $ "VO3_TIPTEM,VO3_FATPAR,VO3_LOJA,VO3_CODTES,VO3_OPER,VO3_GRUITE,VO3_CODITE,VO3_FORMUL,VO3_LOTECT,VO3_NUMLOT,VO3_QTDREQ"
			loop
		endif

		// Campos de Desconto nunca poderao ser alterados
		if !(aHeader[nAuxPos,2] $ "VO3_PERDES,VO3_VALDES")
			AADD( aAlterMan , aHeader[nAuxPos,2] ) // Campos alteraveis quando for requisicao avulsa
			if !(Alltrim(aHeader[nAuxPos,2]) $ "VO3_TIPTEM,VO3_FATPAR,VO3_LOJA,VO3_GRUITE,VO3_CODITE,VO3_FORMUL,VO3_LOTECT,VO3_NUMLOT")
				AADD( aAlterOrc , aHeader[nAuxPos,2] ) // Campos alteraveis quando for requisicao vinda de orcamento
			endif
		endif
	Next nAuxPos

	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 315, 70 , .T., .F. } ) // EnchoiceBar
	AAdd( aObjects, { 315, 100, .T., .T. } ) // GetDados Pecas
	AAdd( aObjects, { 315, 16 , .T., .F. } ) // Linha com Total
	AAdd( aObjects, { 315, 60 , .T., .T. } ) // GetDados Itens Relacionados
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects, .t.)

	SETKEY(VK_F6,{|| OM020KEYF6() } )

	aNewBot := {}
	AADD( aNewBot, { "NOVACELULA" , { || FS_CATALOGO()  } , ( STR0021 )} ) //Catalogo Fabrica //Catalogo Fabrica - <Ctrl-F>
	AADD( aNewBot, { "PENDENTE"   , { || (aColsOld:=Aclone(aCols),aHeaderOld:=Aclone(aHeader),nOld:=n,nReg:=("VOP")->(Recno()),OF110("VOP", nReg, 3,STR0022),aCols:=Aclone(aColsOld),aHeader:=Aclone(aHeaderOld),n:=nOld)  },( STR0022 )} ) //Campanha/Pendencia/Assunto Tecnica //Pendencia/Campanha/Assunto Tecnico - <Ctrl-P>
	AADD( aNewBot, { "BUDGET"     , { || (SX3->(DbSetOrder(1)),OFMI900("VE6",nReg:=("VE6")->(Recno()),3,.t.,,,STR0023))  },( STR0023 )} ) //"Requisicao de Compras //Requisicao de Compras- <Ctrl-R>
	AADD( aNewBot, { "LJPRECO"    , { || FS_PECAORC(.t.)   } ,( STR0236 )} ) // "Pe็as Pendentes da OS"
	AADD( aNewBot, { "PESQUISA"   , { || FG_OSONLINE()  } ,( STR0078 )} ) // Catalogo Fabrica //Catalogo Fabrica - <Ctrl-F>
	AADD( aNewBot, { "ANALITICO"  , { || IIf(Pergunte("OF20MV"),OFIOC150(MV_PAR01,MV_PAR02),NIL)  },( STR0083 )} ) //Movimento da Peca
	AADD( aNewBot, { "EDIT"       , { || OFIOM250(MV_PAR01,MV_PAR03,MV_PAR04,MV_PAR05,2)  },( STR0084 )} )  //Pedido
	AADD( aNewBot, { "PRODUTO"    , { || OFIOC040()     } , ( STR0085 )} )  //Consulta Itens e Kit's
	AADD( aNewBot, { "AUTOM"      , { || FS_DELPECORC() } , ( STR0237 )} )  // "Deleta Pe็as Pendentes da OS"
	AADD( aNewBot, { "MAQFOTO"    , { || OM020KEYF6()   } , ("<F6> "+STR0142)} ) // "Foto(s)/Video(s)"
	AADD( aNewBot, { "FORM"       , { || OM020AVARES()  } , STR0143} ) // Aval.Result.
	If cMVMIL0006 == "JD"
		AADD(aNewBot, {"LJPRECO", { || OM020REQOPC()  },( STR0193 )} ) // Req. Opc. de Equipamento com N๚mero de S้rie
	EndIf
	AADD( aNewBot, { "PESQUISA"   , { || OM0200151_Visualizar_Remessa() } , STR0302 } ) // Consulta de Opera็๕es de Pe็as para Remessa
	FM_NEWBOT("OM020BTR","aNewBot") // Ponto de Entrada para Manutencao do aNewBot - Definicao de Botoes na EnchoiceBar

	DEFINE MSDIALOG oDlgReqPec TITLE cTitulo From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL
	EnChoice(cAlias1,nReg,nOpcE,,,,aMyEncho,aPosObj[1],aAltEnchoice,3,,,,,,lVirtual)
	oGetReqPec := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),aAlterMan,,,nLinhas,cFieldOk)

	oGetReqPec:oBrowse:bChange  := {|| FS_MEMVAR(),FS_ITEREL(),FS_TOTAL(),FS_REPPRO(),FS_BLQCPO(M->VO3_GRUITE, M->VO3_CODITE, IIF(lInconveniente, M->VO3_SEQINC , "" ),lInconveniente )}
	oGetReqPec:oBrowse:bEditCol := {|| FG_PULACPO(oGetReqPec) }
	oGetReqPec:oBrowse:bDelete  := {|| FS_DELLINHA() }

	@ aPosObj[3,1],aPosObj[3,2] TO aPosObj[3,3],aPosObj[3,4] OF oDlgReqPec PIXEL
	@ aPosObj[3,1]+4,aPosObj[3,4]-80 SAY STR0008 Font oFonte OF oDlgReqPec PIXEL COLOR CLR_RED //"Total"
	@ aPosObj[3,1]+3,aPosObj[3,4]-60 MSGET oTotal VAR nTotal PICTURE "@E 999,999,999.99" SIZE 55,4 OF oDlgReqPec PIXEL COLOR CLR_RED When .f.

	@ aPosObj[4,1],aPosObj[4,2] TO aPosObj[4,3],aPosObj[4,4] LABEL STR0009 OF oDlgReqPec PIXEL //"Itens Relacionados"

	sl1 := (aPosObj[3,4] - aPosObj[3,2])	// LARGURA DA CELULA

	@ aPosObj[4,1]+8,aPosObj[4,2]+3 LISTBOX oLbIteRel FIELDS HEADER ;
		(STR0147), ;   // marca
		(STR0012), ;   // descricao
		(STR0033), ;   // codigo interno
		(STR0010), ;   // grupo
		(STR0011), ;	// c๓digo do item
		(STR0012), ;	// descricao
		(STR0013), ;	// quantidade
		(STR0014) ;	// valor
		COLSIZES 0.05 * sl1, 0.125 * sl1, 0.125 * sl1, 0.035 * sl1, 0.125 * sl1, 0.175 * sl1, 0.045 * sl1, 0.09 * sl1 ;
		SIZE aPosObj[4,4]-aPosObj[4,2]-6,aPosObj[4,3]-aPosObj[4,1]-12 OF oDlgReqPec PIXEL ON DBLCLICK (FS_ITEREL(oLbIteRel:nAt),FS_VALOR(),FS_TOTAL(),oLbIteRel:Refresh())

//	ACTIVATE MSDIALOG oDlgReqPec ON INIT (EnchoiceBar(oDlgReqPec,{||nOpca:=1 ,if(oGetReqPec:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,If(FS_CHAMAGRAREQ(),oDlgReqPec:End(),nOpca:=0)),nOpca := 0)},{||oDlgReqPec:End()},,aNewBot), Iif(FindFunction("OFA1100016_PesquisaCampanha") .And. VOU->(FieldPos("VOU_SERINT")) > 0, OFA1100016_PesquisaCampanha(VV1->VV1_CHASSI), NIL) )
	ACTIVATE MSDIALOG oDlgReqPec ON INIT (;
		EnchoiceBar(oDlgReqPec,;
			{ || nOpca:=1 ,IIf(oGetReqPec:TudoOk() , IIf( !obrigatorio(aGets,aTela) , nOpca := 0 , IIf( FS_CHAMAGRAREQ() , oDlgReqPec:End() , nOpca:=0 ) ) , nOpca := 0 )},;
			{ || oDlgReqPec:End()},,aNewBot),;
		Iif(FindFunction("OFA1100016_PesquisaCampanha") .And. VOU->(FieldPos("VOU_SERINT")) > 0, OFA1100016_PesquisaCampanha(VV1->VV1_CHASSI), NIL) )

	UnLockByName("OFIOM020"+VO1->VO1_NUMOSV,.t.,.t.)

Else

	nColCODVSJ := 0
	nColQTDREQ := 0
	SX3->(dbSetOrder(2))
	For nAuxLin := 1 to Len(aAutoItens)
		For nAuxCol := 1 to Len(aAutoItens[nAuxLin])
			nPos := AScan( aHeader , { |x| x[2] == aAutoItens[nAuxLin,nAuxCol,1] } )
			If nPos > 0
				If SX3->(dbSeek(aAutoItens[nAuxLin,nAuxCol,1]))
					aAutoItens[nAuxLin,nAuxCol,3] := ""
					If aAutoItens[nAuxLin,nAuxCol,1] $ "VO3_CODVSJ"
						lImpVSJ := .t.
						nColCODVSJ:= nAuxCol // Coluna correspondente ao VO3_CODVSJ
					EndIf
					If aAutoItens[nAuxLin,nAuxCol,1] $ "VO3_QTDREQ"
						nColQTDREQ:= nAuxCol // Coluna correspondente ao VO3_QTDREQ
					EndIf
					If !Empty(SX3->X3_VALID) .and. !aAutoItens[nAuxLin,nAuxCol,1] $ "VO3_FATPAR"
						aAutoItens[nAuxLin,nAuxCol,3] := "(" + AllTrim(SX3->X3_VALID) + ")"
					EndIf
					If !Empty(SX3->X3_VLDUSER)
						aAutoItens[nAuxLin,nAuxCol,3] += IIf( !Empty(aAutoItens[nAuxLin,nAuxCol,3]) , " .AND. " , "" ) + "(" + AllTrim(SX3->X3_VLDUSER) + ")"
					EndIf
					aAutoItens[nAuxLin,nAuxCol,3] += IIf( !Empty(aAutoItens[nAuxLin,nAuxCol,3]) , " .AND. " , "" ) + "(" + cFieldOk + ")"
				EndIf
			EndIf
		Next nAuxCol
	Next nAuxLin

	If lImpVSJ
		If nColCODVSJ > 0 .and. nColQTDREQ > 0
			For nAuxLin := 1 to len(aAutoItens)
				aAdd(aQReqConf,{ aAutoItens[nAuxLin,nColCODVSJ,2] , aAutoItens[nAuxLin,nColQTDREQ,2] })
			Next
		EndIf
		If !OM020VSJLOAD( VO1->VO1_NUMOSV , .f. , aQReqConf )
			Return
		EndIf
		aEval( aPecaOrc, {|x| AADD( aPecaSel , x[1] ) } )
	EndIf

	//cTudoOk := "(" + cTudoOk + ") .AND. FS_CHAMAGRAREQ()"
	aAutoCab := {}
	lRet := MsGetDAuto(aAutoItens , cLinOk,	cTudoOk , aAutoCab , nOpcG ,.f.)
	If !lRet
		lMsErroAuto := .t.
		return .f.
	EndIf
	If !FS_CHAMAGRAREQ()
		lMsErroAuto := .t.
		return .f.
	EndIf

EndIf
SET KEY VK_F6 TO

// Variavel para nao chamar a janela de campanha do veiculo
//lAchou := .t.
Return(.t.)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun็ใo    |OM020KEYF6  | Autor | Andre Luis Almeida    | Data | 26/07/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri็ใo | Chamada da tecla de atalho <F6> Foto do Produtos             |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Auto Pecas                                                   |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM020KEYF6()
//
SET KEY VK_F6 TO
//
SB1->(DBSetOrder(7))
SB1->(DBSeek( xFiliaL("SB1") + aCols[n,FG_POSVAR("VO3_GRUITE")] + aCols[n,FG_POSVAR("VO3_CODITE")] ))
//
If FindFunction("OFIXC003")
	OFIXC003( SB1->B1_COD )
EndIf
//
SETKEY(VK_F6,{|| OM020KEYF6() } )
//
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณFS_MEMVAR ณ Autor ณ Fabio                 ณ Data ณ 16/07/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณSalva conteudo do aCols p/ variaveis de memoria             ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_MEMVAR()

Local bCampo := {|x| aHeader[x,2]} , z := 0

For z=1 to Len(aHeader)
	&("M->"+(EVAL(bCampo,z))) := aCols[n,z]
Next

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_PECAORCบAutor  ณFabio               บ Data ณ  09/28/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pecas do Orcamento                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_PECAORC(lRetorna)

Local   lMarcar := .f.
Local   aSizeAut
Local   aPE := {}  // vetor que recebe retorno do PE OM020VSJ (utilizado para manipulacao do aPecOrc)

Private oLbPecaOrc
Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oVerde := LoadBitmap( GetResources(), "BR_VERDE" )
Private oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private aNewBot := { {"PMSCOLOR", {|| BrwLegenda(STR0027, STR0093, { {"BR_VERDE" ,STR0132},{"BR_VERMELHO",STR0133} } ) } , STR0093 } } // Pe็as Do Or็amento / Legenda / Quantidade disponํvel no stock / Quantidade indisponํvel no stock / Legenda

Private aAvCredPec := {}

Private aImpFatPar := {}

Default lRetorna := .t. // .t. = Retorna PEวAS selecionadas para aCols / .f. = Apenas Consulta das Pe็as Pendentes

// Pecas
If Len( aPecaOrc ) == 0
	If !OM020VSJLOAD( VO1->VO1_NUMOSV , .f. , {} )
		Return
	EndIf
Else
	OM020VSJATU( .t. , .t. )
EndIf

If Len(aPecaOrc) > 0
	oReqPecDao  := DMS_RequisicaoPECA():New(VO1->VO1_NUMOSV) // Cria Obj de requisicao de pecas
	aPecReqDupl := oReqPecDao:PecasDuplicadas()
EndIf

//
// PE para manipulacao do vetor que importa Pecas do Orcamento para Acols do VO3
If ExistBlock("OM020VSJ")
	aPE := ExecBlock("OM020VSJ",.f.,.f.,{aPecaOrc})
	If ValType(aPE) == "A"
		aPecaOrc := aClone(aPE)
	Endif
Endif
//
If Len(aPecaOrc) # 0

	If lRetorna
		If !LockByName("OFIOM020"+VO1->VO1_NUMOSV,.t.,.t.)
			Help(" ",1,"ROTINA_EM_USO",,STR0284,4,1 )		 // "A Importa็ใo de Pe็as desta OS estแ travada por outro usuแrio nesse momento! Impossํvel Continuar!"
			Return
		Endif
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica as linhas que jแ estejam marcadas, pois quando cancela a ณ
	//ณ tela ele estava desmarcando todas as linhas da aPecaorc           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aPecaSel := {}
	aEval( aPecaOrc, {|x| AADD( aPecaSel , x[1] ) } )
	//

	aSizeAut := MsAdvSize(.t.)
	aObjects := {}

	AADD( aObjects, { 000,  150, .T., .T. } )
	AADD( aObjects, { 000,  150, .T., .T. } )
	aInfo := { aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4], 0 , 2 }
	aPosObj := MsObjSize( { aSizeAut[ 1 ] , aSizeAut[ 2 ] ,aSizeAut[ 3 ] , aSizeAut[ 4 ] , 2 , 2 } , aObjects , .T. )

	DEFINE MSDIALOG oDlgOrc TITLE STR0027 From aSizeAut[7],00 to aSizeAut[6],aSizeAut[5] PIXEL of oMainWnd STYLE DS_MODALFRAME //Pecas do Orcamento
	oDlgOrc:lEscClose := .F.

	// =====================
	// FOLDERS
	// =====================
	aFolders := {}
	AAdd( aFolders , STR0009) // 1 - Req. Padrใo
	AAdd( aFolders , STR0182) // 2 - Req. Agrupada
	oFolder060       := TFolder():New( aPosObj[2,1], aPosObj[2,2], aFolders, aFolders, oDlgOrc,,,, .T., .F., aPosObj[2,4], aPosObj[2,3]-aPosObj[2,1])

	lMarcar := .t.
	// Listbox ...
	oLbPecaOrc := TWBrowse():New(aPosObj[1,1]+002 , aPosObj[1,2] , aPosObj[1,4] , (aPosObj[1,3]-aPosObj[1,1]),,,,oDlgOrc,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oLbPecaOrc:nAt := 1
	oLbPecaOrc:SetArray(aPecaOrc)
	If lRetorna
		oLbPecaOrc:addColumn( TCColumn():New(" "						, { || If(aPecaOrc[oLbPecaOrc:nAt,1],oOk,oNo) }						,,,,"LEFT" ,10,.T.,.F.,,,,.F.,) )
	EndIf
	oLbPecaOrc:addColumn( TCColumn():New(" "						, { || If(aPecaOrc[oLbPecaOrc:nAt,9] > 0 .and. aPecaOrc[oLbPecaOrc:nAt,9] <= aPecaOrc[oLbPecaOrc:nAt,27],oVerde,oVermelho) }	,,,,"LEFT" ,10,.T.,.F.,,,,.F.,) )
	oLbPecaOrc:addColumn( TCColumn():New(STR0111					, { || aPecaOrc[oLbPecaOrc:nAt,21] }								,,,,"LEFT" ,28,.F.,.F.,,,,.F.,) ) //Orcamento
	oLbPecaOrc:addColumn( TCColumn():New(STR0029					, { || aPecaOrc[oLbPecaOrc:nAt,02] }								,,,,"LEFT" ,10,.F.,.F.,,,,.F.,) ) //Tp
	oLbPecaOrc:addColumn( TCColumn():New(STR0030					, { || aPecaOrc[oLbPecaOrc:nAt,03] }								,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) //Faturar Para
	oLbPecaOrc:addColumn( TCColumn():New(STR0031					, { || aPecaOrc[oLbPecaOrc:nAt,04] }								,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) //Loja
	oLbPecaOrc:addColumn( TCColumn():New(STR0032					, { || aPecaOrc[oLbPecaOrc:nAt,05] }								,,,,"LEFT" ,60,.F.,.F.,,,,.F.,) ) //Nome
	If lInconveniente
		oLbPecaOrc:addColumn( TCColumn():New(RetTitle("VSJ_GRUINC")	, { || aPecaOrc[oLbPecaOrc:nAt,15] }								,,,,"LEFT" ,10,.F.,.F.,,,,.F.,) ) //Cod do Grupo
		oLbPecaOrc:addColumn( TCColumn():New(RetTitle("VSJ_CODINC")	, { || aPecaOrc[oLbPecaOrc:nAt,16] }								,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) //Inconvenient
		oLbPecaOrc:addColumn( TCColumn():New(RetTitle("VSJ_SEQINC")	, { || aPecaOrc[oLbPecaOrc:nAt,20] }								,,,,"LEFT" ,10,.F.,.F.,,,,.F.,) ) //Seq. Inconveniente - VST
		oLbPecaOrc:addColumn( TCColumn():New(RetTitle("VSJ_DESINC")	, { || aPecaOrc[oLbPecaOrc:nAt,17] }								,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) //Descr Inconv
	EndIf
	oLbPecaOrc:addColumn( TCColumn():New(STR0010					, { || aPecaOrc[oLbPecaOrc:nAt,06] }								,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) //Grupo
	oLbPecaOrc:addColumn( TCColumn():New(STR0033					, { || aPecaOrc[oLbPecaOrc:nAt,07] }								,,,,"LEFT" ,60,.F.,.F.,,,,.F.,) ) //Codigo
	oLbPecaOrc:addColumn( TCColumn():New(STR0012					, { || aPecaOrc[oLbPecaOrc:nAt,08] }								,,,,"LEFT" ,60,.F.,.F.,,,,.F.,) ) //Descricao
	If lCtrlLote
		oLbPecaOrc:addColumn( TCColumn():New(RetTitle("VSJ_LOTECT")	, { || aPecaOrc[oLbPecaOrc:nAt,PECAORC_LOTECT] }					,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) //Lote
		oLbPecaOrc:addColumn( TCColumn():New(RetTitle("VSJ_NUMLOT")	, { || aPecaOrc[oLbPecaOrc:nAt,PECAORC_NUMLOT] }					,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) //Sub-Lote
	EndIf
	oLbPecaOrc:addColumn( TCColumn():New(STR0034					, { || Transform(aPecaOrc[oLbPecaOrc:nAt,09],PesqPict("VS3","VS3_QTDITE")) }	,,,,"RIGHT",30,.F.,.F.,,,,.F.,) ) //Quantidade
	oLbPecaOrc:addColumn( TCColumn():New(STR0131					, { || Transform(aPecaOrc[oLbPecaOrc:nAt,27],PesqPict("VS3","VS3_QTDITE")) }	,,,,"RIGHT",30,.F.,.F.,,,,.F.,) ) //Qtd. Estoque
	oLbPecaOrc:addColumn( TCColumn():New(STR0035					, { || aPecaOrc[oLbPecaOrc:nAt,10] }								,,,,"LEFT" ,25,.F.,.F.,,,,.F.,) ) //Formula
	oLbPecaOrc:addColumn( TCColumn():New(STR0014					, { || Transform(aPecaOrc[oLbPecaOrc:nAt,11],PesqPict("VS3","VS3_VALPEC")) }	,,,,"RIGHT",40,.F.,.F.,,,,.F.,) ) //Valor
	oLbPecaOrc:addColumn( TCColumn():New(RetTitle("VS3_PERDES")		, { || Transform(aPecaOrc[oLbPecaOrc:nAt,23],PesqPict("VS3","VS3_PERDES")) }			,,,,"RIGHT",25,.F.,.F.,,,,.F.,) ) //Percentual de Desconto
	oLbPecaOrc:addColumn( TCColumn():New(RetTitle("VS3_VALDES")		, { || Transform(aPecaOrc[oLbPecaOrc:nAt,24],PesqPict("VS3","VS3_VALDES")) }	,,,,"RIGHT",40,.F.,.F.,,,,.F.,) ) //Valor de Desconto
	oLbPecaOrc:addColumn( TCColumn():New(STR0014					, { || Transform(aPecaOrc[oLbPecaOrc:nAt,25],PesqPict("VS3","VS3_VALTOT")) }	,,,,"RIGHT",40,.F.,.F.,,,,.F.,) ) //Valor
	oLbPecaOrc:addColumn( TCColumn():New(STR0294					, { || Transform(aPecaOrc[oLbPecaOrc:nAt,35],PesqPict("VS3","VS3_QTDITE")) }	,,,,"RIGHT",40,.F.,.F.,,,,.F.,) ) // Qtd. Reservada
	If lRetorna
		oLbPecaOrc:bHeaderClick := {|oObj,nCol| If( nCol==1, ( FS_TPecOrc( .T. , lMarcar ) , ( lMarcar:=!lMarcar ) ) ,Nil) , oLbPecaOrc:Refresh() }
		oLbPecaOrc:bLDblClick := { || FS_TPecOrc() }
	EndIf
	oLbPecaOrc:bChange := {|| FS_ITRELE(oLbPecaOrc:nAt,"0") }
	//
	@ aPosObj[2,1],aPosObj[2,2] SAY STR0009 SIZE 100,08 OF oFolder060:aDialogs[1] PIXEL COLOR CLR_BLUE // Itens Relacionados

	sl1 := (aPosObj[2,4] - aPosObj[2,2])	// LARGURA DA CELULA

	@ aPosObj[2,1]+008,aPosObj[2,2] LISTBOX oLItRel FIELDS HEADER ;
		(STR0147), ;   // marca
		(STR0148), ;   // descricao
		(STR0149), ;   // codigo interno
		(STR0150), ;   // grupo
		(STR0151), ;	  // c๓digo do item
		(STR0148), ;	  // descricao
		(STR0152), ;	  // quantidade
		(STR0153)  ;	  // valor
		COLSIZES 0.05 * sl1, 0.125 * sl1, 0.125 * sl1, 0.035 * sl1, 0.125 * sl1, 0.175 * sl1, 0.045 * sl1, 0.09 * sl1 ;
		SIZE aPosObj[2,4],aPosObj[2,3]-aPosObj[2,1]-025;
		OF oFolder060:aDialogs[1] PIXEL

	oLbPecaOrc:Refresh() // trouxe pra baixo por conta do problema da lib
	//
	oLItRel:SetArray(aIteRel)
	oLItRel:bLine := { || { aIteRel[oLItRel:nAt,6],;
		aIteRel[oLItRel:nAt,7],;
		aIteRel[oLItRel:nAt,8],;
		aIteRel[oLItRel:nAt,1],;
		aIteRel[oLItRel:nAt,2],;
		aIteRel[oLItRel:nAt,3],;
		FG_AlinVlrs(Transform(aIteRel[oLItRel:nAt,4],"@E 999,999")),;
		FG_AlinVlrs(Transform(aIteRel[oLItRel:nAt,5],"@E 999,999,999.99"))}}
	oLItRel:Align := CONTROL_ALIGN_ALLCLIENT

	@ 10 , 10 LISTBOX oLbSaldoAgru FIELDS HEADER ;
		STR0171, ; // Atende Total
		STR0172, ; // Grupo Item.
		STR0173, ; // Cod. Item
		STR0174, ; // Desc. Item
		STR0175, ; // Lote
		STR0176, ; // Sub-Lote
		STR0177, ; // Qtd. Estoque.
		STR0178, ; // Qtd. Requisitada.
		STR0179, ; // Saldo Requisi็๕es
		STR0180, ; // Qtd. Selecionados
		STR0181, ; // Saldo Selecionados
		COLSIZES 40, 80, 80, 40, 40, 35, 35, 35, 35, 35, 35 ;
		SIZE     500, 250 ;
		Of oFolder060:aDialogs[2] PIXEL
	oLbSaldoAgru:Align := CONTROL_ALIGN_ALLCLIENT
	If Len(aPecReqDupl) <= 0
		AADD(aPecReqDupl, { '', '', '', 0, 0, 0, 0, 0, 0, '', '' })
		oFolder060:HidePage(2)
	EndIf
	oLbSaldoAgru:SetArray(aPecReqDupl)
	oLbSaldoAgru:bLine := { || {   ;
		IIF(aPecReqDupl[oLbSaldoAgru:nAt, 4] <= aPecReqDupl[oLbSaldoAgru:nAt, 5], oVerde, oVermelho), ; //oVerde oVermelho
		aPecReqDupl[oLbSaldoAgru:nAt, 1], ; // VS3_GRUITE
		aPecReqDupl[oLbSaldoAgru:nAt, 2], ; // VS3_CODITE
		aPecReqDupl[oLbSaldoAgru:nAt, 3], ; // B1_DESC
		aPecReqDupl[oLbSaldoAgru:nAt, 7], ; // Lote
		aPecReqDupl[oLbSaldoAgru:nAt, 6], ; // Sub-Lote
		aPecReqDupl[oLbSaldoAgru:nAt, 5], ; // 1 - QUANTIDADE ATUAL NO ESTOQUE
		aPecReqDupl[oLbSaldoAgru:nAt, 4], ; // 2 - QUANTIDADE TOTAL NO VSJ DESTA PEวA
		aPecReqDupl[oLbSaldoAgru:nAt, 5] - aPecReqDupl[oLbSaldoAgru:nAt, 4], ; // 3 - SALDO APำS REQUISIวรO (1-2)
		oArrHelper:Sum(9, aPecaOrc, { |el| el[1] == .T. .AND. aPecReqDupl[oLbSaldoAgru:nAt, 1] == el[6] .AND. aPecReqDupl[oLbSaldoAgru:nAt, 2] == el[7] .AND. aPecReqDupl[oLbSaldoAgru:nAt, 7] == el[30] .AND. aPecReqDupl[oLbSaldoAgru:nAt, 6] == el[31] }) , ; // 4 - QUANTIDADE SELECIONADA NO LIST ACIMA "Soma o total do indice 9(qtd req) quando codite e gruite forem iguais"
		aPecReqDupl[oLbSaldoAgru:nAt, 5] - oArrHelper:Sum(9, aPecaOrc, {|el| el[1] == .T. .AND. aPecReqDupl[oLbSaldoAgru:nAt, 1] == el[6] .AND. aPecReqDupl[oLbSaldoAgru:nAt, 2] == el[7] .AND. aPecReqDupl[oLbSaldoAgru:nAt, 7] == el[30] .AND. aPecReqDupl[oLbSaldoAgru:nAt, 6] == el[31] }) ; // 5 - SALDO APำS SELECIONADO (1-4)
	}}

	ACTIVATE MSDIALOG oDlgOrc ON INIT EnchoiceBar(oDlgOrc, { || IIf(lRetorna,FS_IMPORC("R"),.t.),oDlgOrc:End() } , { || IIf(lRetorna,FS_IMPORC("C"),.t.),oDlgOrc:End() },, aNewBot)
	
	If lRetorna
		FS_ITEREL()
	EndIf

EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM020VSJLOAD บAutor  ณ Rubens         บ Data ณ  21/06/2016 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega dados da VSJ                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM020VSJLOAD(cNumOsv, lDelPecPen, aQReqConf)

	Local lVS3OPER   := (VS3->(FieldPos("VS3_OPER")) <> 0)
	Local lCpoDesconto := .f.

	Local cMVRESITE := PadR( AllTrim(GetMv("MV_RESITE")), TamSX3("B2_LOCAL")[1] )
	Local cMVRESLOC := PadR( AllTrim(GetMV("MV_RESLOC")), TamSX3("B5_LOCALI2")[1])
	Local cCodMarVV1

	Local lVSJOPER   := ( VSJ->(FieldPos("VSJ_OPER")) > 0 )
	Local lVSJSUGCOM := ( VSJ->(FieldPos("VSJ_SUGCOM")) > 0 )
	
	Local nPosAux := 0

	Default lDelPecPen := .f.
	Default aQReqConf := {}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Indica se os campos de desconto estao criado ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If VO3->(FieldPos("VO3_VALDES")) <> 0 .and. ;
		VO3->(FieldPos("VO3_PERDES")) <> 0 .and. ;
		VO3->(FieldPos("VO3_VALLIQ")) <> 0
		lCpoDesconto := .t.
	EndIf

	VS1->(DbSetOrder(1))
	SA1->(DbSetOrder(1))
	VS3->(DbSetOrder(2))
	VOI->(dbSetOrder(1))

	DbSelectArea("VSJ")
	DbSetOrder(1)
	DbSeek( xFilial("VSJ") + cNumOsv )
	Do While !Eof() .And. VSJ->VSJ_FILIAL == xFilial("VSJ") .And. VSJ->VSJ_NUMOSV == cNumOsv

		If VSJ->VSJ_QTDITE <= 0
			Skip()
			Loop
		EndIf

		if VSJ->VSJ_QTDINI > 0 // veio do NA oficina 
			if VSJ->VSJ_QESTNA == 0 // nao tinha saldo ao requisitar no NA
				skip()
				loop
			endif
		endif

		SB1->(DbSetOrder(7))
		SB1->(DbSeek( xFilial("SB1") + VSJ->VSJ_GRUITE + VSJ->VSJ_CODITE ))

		SB5->(DbSetOrder(1))
		SB5->(DbSeek( xFilial("SB5") + SB1->B1_COD  ))

		AADD( aPecaOrc , Array(36) )
		nPosPecOrc := Len(aPecaOrc)
		aPecaOrc[ nPosPecOrc , 01 ] := .f.
		aPecaOrc[ nPosPecOrc , PECAORC_GRUITE    ] := VSJ->VSJ_GRUITE
		aPecaOrc[ nPosPecOrc , PECAORC_CODITE    ] := VSJ->VSJ_CODITE
		aPecaOrc[ nPosPecOrc , PECAORC_DESRICAO  ] := SB1->B1_DESC
		nPosAux := 0
		If len(aQReqConf) > 0 // Qtdades Conferidas pelo VSJ
			nPosAux := aScan( aQReqConf , { |x| x[1] == VSJ->VSJ_CODIGO } )
		EndIf
		If nPosAux > 0
			aPecaOrc[ nPosPecOrc , PECAORC_QTDITE ] := aQReqConf[nPosAux,2] // Requisitar somente a Quantidade Conferida
		Else
			if VSJ->VSJ_QTDINI > 0 // veio do NA oficina 
				if VSJ->VSJ_QESTNA >= VSJ->VSJ_QTDITE // se nใo tem o total preciso colocar no grid somente o que tem, pois senao nao da certo a requisicao
					aPecaOrc[ nPosPecOrc , PECAORC_QTDITE ] := VSJ->VSJ_QTDITE
				else
					aPecaOrc[ nPosPecOrc , PECAORC_QTDITE ] := VSJ->VSJ_QESTNA
				endif
			else // veio de exportacao de orcamento
				aPecaOrc[ nPosPecOrc , PECAORC_QTDITE ] := VSJ->VSJ_QTDITE
			endif
		EndIf
		aPecaOrc[ nPosPecOrc , PECAORC_LOCPAD    ] := OM0200065_ArmazemOrigem( VSJ->VSJ_TIPTEM )  // Almoxarifado Padrao do Produto
		aPecaOrc[ nPosPecOrc , PECAORC_LOCALIZ   ] := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2") // Localizacao Padrao do Produto
		aPecaOrc[ nPosPecOrc , PECAORC_RESPEC    ] := VSJ->VSJ_RESPEC 		// Indica se foi feito reserva
		aPecaOrc[ nPosPecOrc , PECAORC_GRUINCONV ] := " "	 				// Grupo de Inconveniente
		aPecaOrc[ nPosPecOrc , PECAORC_CODINCONV ] := " " 					// Codigo do Inconveniente
		aPecaOrc[ nPosPecOrc , PECAORC_DESINCONV ] := " " 					// Descricao do Inconveniente
		aPecaOrc[ nPosPecOrc , PECAORC_RECNO     ] := VSJ->(Recno())	 	// Recno
		aPecaOrc[ nPosPecOrc , PECAORC_SEQINCONV ] := " "	 				// Seq. do Inconveniente - VST
		aPecaOrc[ nPosPecOrc , PECAORC_NUMORC    ] := VSJ->VSJ_NUMORC	 	// Num Orcamento
		aPecaOrc[ nPosPecOrc , PECAORC_PERDES    ] := 0						// Percentual de Desconto aplicado na peca
		aPecaOrc[ nPosPecOrc , PECAORC_VALDES    ] := 0						// Valor de Desconto aplicado na peca
		aPecaOrc[ nPosPecOrc , PECAORC_VALORLIQ  ] := 0						// Valor Liquido da Peca (VALPEC - Desconto)
		aPecaOrc[ nPosPecOrc , PECAORC_ESTOQUE   ] := 0						// Qtde de Peca Disponivel em Estoque
		aPecaOrc[ nPosPecOrc , PECAORC_DEPGAR    ] := VSJ->VSJ_DEPGAR		// Depto Garantia
		aPecaOrc[ nPosPecOrc , PECAORC_DEPINT    ] := VSJ->VSJ_DEPINT		// Depto Interno
		aPecaOrc[ nPosPecOrc , PECAORC_LOTECT    ] := VSJ->VSJ_LOTECT
		aPecaOrc[ nPosPecOrc , PECAORC_NUMLOT    ] := VSJ->VSJ_NUMLOT
		aPecaOrc[ nPosPecOrc , PECAORC_CODIGOVSJ ] := IIf( lVSJCODIGO , VSJ->VSJ_CODIGO , "" ) // ID da Movimentacao da VSJ
		aPecaOrc[ nPosPecOrc , PECAORC_ORIDAD    ] := VSJ->VSJ_ORIDAD		// Origem do Registro
		aPecaOrc[ nPosPecOrc , PECAORC_B1COD     ] := SB1->B1_COD			// Codigo SB1 do produto
		if lVSJOPER
			aPecaOrc[ nPosPecOrc , PECAORC_OPER  ] := VSJ->VSJ_OPER			// Codigo SB1 do produto
		endif
		aPecaOrc[ nPosPecOrc , PECAORC_SUGCOM    ] := IIf(lVSJSUGCOM , VSJ->VSJ_SUGCOM , "" )
		aPecaOrc[ nPosPecOrc , PECAORC_QTDRES    ] := FM_SALDORESV( VSJ->VSJ_GRUITE , VSJ->VSJ_CODITE , VSJ->VSJ_NUMOSV , VSJ->VSJ_LOTECT , VSJ->VSJ_NUMLOT , IIf(lVSJSUGCOM , VSJ->VSJ_SUGCOM , "" ) ) // Retorna a qtde Reservada

		// Registro gerado pelo Or็amento
		If VSJ->VSJ_ORIDAD == "2"

			VS1->(MsSeek( xFilial("VS1") + VSJ->VSJ_NUMORC ))
			SA1->(MsSeek( xFilial("SA1") + VS1->VS1_CLIFAT + VS1->VS1_LOJA ))

			VS3->(DbSeek( xFilial("VS3") + VSJ->VSJ_NUMORC + VSJ->VSJ_GRUITE + VSJ->VSJ_CODITE ))

			cTipTem := VS1->VS1_TIPTEM

			aPecaOrc[ nPosPecOrc , PECAORC_TIPTEM ] := VS1->VS1_TIPTEM
			aPecaOrc[ nPosPecOrc , PECAORC_CLIFAT ] := VS1->VS1_CLIFAT
			aPecaOrc[ nPosPecOrc , PECAORC_LOJFAT ] := VS1->VS1_LOJA
			aPecaOrc[ nPosPecOrc , PECAORC_NOME   ] := SA1->A1_NOME
			aPecaOrc[ nPosPecOrc , PECAORC_FORMUL ] := VS3->VS3_FORMUL	 	// Formula
			aPecaOrc[ nPosPecOrc , PECAORC_VALPEC ] := VS3->VS3_VALPEC	 	// Valor da Peca
			if !Empty(VS3->VS3_LOCAL)
				aPecaOrc[ nPosPecOrc ,  PECAORC_LOCPAD ] := VS3->VS3_LOCAL		// Almoxarifado Padrao do Produto
			Endif
			aPecaOrc[ nPosPecOrc , PECAORC_CODTES ] := VS3->VS3_CODTES	 	// TES
			aPecaOrc[ nPosPecOrc , PECAORC_FORMU2 ] := VS3->VS3_FORMUL		// Formula para calculo do valor da peca
			if empty(aPecaOrc[ nPosPecOrc , PECAORC_OPER ])
				aPecaOrc[ nPosPecOrc , PECAORC_OPER ] := IIF( lVS3OPER , VS3->VS3_OPER,Space(2)) // Tipo de Opera็ใo
			endif

			if lCpoDesconto
				If VS3->VS3_VALLIQ > 0
					aPecaOrc[Len(aPecaOrc),PECAORC_PERDES  ] := VS3->VS3_PERDES	// 23 - Percentual de Desconto aplicado na peca
					aPecaOrc[Len(aPecaOrc),PECAORC_VALDES  ] := Iif( VSJ->VSJ_QTDITE != VS3->VS3_QTDITE, VSJ->VSJ_QTDITE * ( VS3->VS3_VALPEC - VS3->VS3_VALLIQ ),VS3->VS3_VALDES ) 	// 24 - Valor de Desconto aplicado na peca
					aPecaOrc[Len(aPecaOrc),PECAORC_VALORLIQ] := VS3->VS3_VALLIQ	// 25 - Valor Liquido da Peca (VALPEC - Desconto Unitario)
				Else
					aPecaOrc[Len(aPecaOrc),PECAORC_VALORLIQ] := VS3->VS3_VALPEC	// 25 - Valor Liquido da Peca (VALPEC - Desconto Unitario)
				EndIf
			endif

			if lInconveniente
				aPecaOrc[Len(aPecaOrc),PECAORC_SEQINCONV] := VSJ->VSJ_SEQINC

				dbSelectArea("VST")
				dbSetOrder(1)
				if VST->(dbSeek(xFilial("VST")+"2"+VSJ->VSJ_NUMOSV+VSJ->VSJ_SEQINC))
					aPecaOrc[Len(aPecaOrc),PECAORC_GRUINCONV] := VST->VST_GRUINC
					aPecaOrc[Len(aPecaOrc),PECAORC_CODINCONV] := VST->VST_CODINC
					aPecaOrc[Len(aPecaOrc),PECAORC_DESINCONV] := VST->VST_DESINC
				endif

			endif

			cNumOrc := VSJ->VSJ_NUMORC

		EndIf
		//

		DbSelectArea("VV1")
		DbSetOrder(1)
		DbSeek( xFilial("VV1") + VO1->VO1_CHAINT )

		DbSelectArea("VV2")
		DbSetOrder(1)
		DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )

		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek( xFilial("SA1") +  VV1->VV1_PROATU + VV1->VV1_LJPATU )

		// Registro gerado pela Garantia da John Deere ou Digitado Manualmente
		If VSJ->VSJ_ORIDAD $ "3/4"

			VOI->(dbSeek( xFilial("VOI") + VSJ->VSJ_TIPTEM ))

			cTipTem := VSJ->VSJ_TIPTEM
			nValPec := FG_VALPEC(cTipTem,,VSJ->VSJ_GRUITE,VSJ->VSJ_CODITE,,.f.,.t.)

			If cMVMIL0006 == "JD " .and. OFNJD15011
				cCodMarVV1 := OFNJD15011_RetornaMarca(VO1->VO1_CODMAR)
			Else
				cCodMarVV1 := FMX_RETMAR(cMVMIL0006)
			EndIf

			aPecaOrc[ nPosPecOrc , PECAORC_CLIFAT ] := ""
			aPecaOrc[ nPosPecOrc , PECAORC_LOJFAT ] := ""

			aImpFatPar := {"","",""}
			FG_TIPTPFAT(cTipTem,"aImpFatPar[1]","aImpFatPar[2]","aImpFatPar[3]",IIf( VSJ->VSJ_ORIDAD == "3" , cCodMarVV1 , VV1->VV1_CODMAR ),,,.F.,.t.)
			If !Empty(aImpFatPar[1])
				aPecaOrc[ nPosPecOrc , PECAORC_CLIFAT ] := aImpFatPar[1]
				aPecaOrc[ nPosPecOrc , PECAORC_LOJFAT ] := aImpFatPar[2]
				aPecaOrc[ nPosPecOrc , PECAORC_NOME   ] := aImpFatPar[3]
			EndIf

			aPecaOrc[ nPosPecOrc , PECAORC_TIPTEM ] := VSJ->VSJ_TIPTEM
			aPecaOrc[ nPosPecOrc , PECAORC_FORMUL ] := VOI->VOI_VALPEC 	// Formula
			aPecaOrc[ nPosPecOrc , PECAORC_VALPEC ] := nValPec			// Valor da Peca
			aPecaOrc[ nPosPecOrc , PECAORC_CODTES ] := VSJ->VSJ_CODTES 	// TES
			aPecaOrc[ nPosPecOrc , PECAORC_FORMU2 ] := VOI->VOI_VALPEC	// Formula para calculo do valor da peca

			aPecaOrc[ nPosPecOrc , PECAORC_PERDES   ] := 0				// Percentual de Desconto aplicado na peca
			aPecaOrc[ nPosPecOrc , PECAORC_VALDES   ] := 0 				// Valor de Desconto aplicado na peca
			aPecaOrc[ nPosPecOrc , PECAORC_VALORLIQ ] := nValPec			// Valor Liquido da Peca (VALPEC - Desconto Unitario)

			if ! Empty(VOI->VOI_CODOPE)
				aPecaOrc[ nPosPecOrc , PECAORC_OPER ] := VOI->VOI_CODOPE	// Tipo de Opera็ใo
			endif

		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRubens - 06/11/2009                                                           ณ
		//ณRetirado tratamento, pois o faturar para ja deve vir corretamente do orcamentoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aImpFatPar := {"","",""}
		if !FG_FATSP(cTipTem,aPecaOrc[Len(aPecaOrc),3]+aPecaOrc[Len(aPecaOrc),4],aImpFatPar[3],,.f.)
			aImpFatPar := {"","",""}
			FG_TIPTPFAT(cTipTem,"aImpFatPar[1]","aImpFatPar[2]","aImpFatPar[3]",VS1->VS1_CODMAR,,,.F.,.t.)

			If !Empty(aImpFatPar[1])
				aPecaOrc[Len(aPecaOrc), PECAORC_CLIFAT ] := aImpFatPar[1]
				aPecaOrc[Len(aPecaOrc), PECAORC_LOJFAT ] := aImpFatPar[2]
				aPecaOrc[Len(aPecaOrc), PECAORC_NOME   ] := aImpFatPar[3]
			ElseIf !lDelPecPen
				aDel(aPecaOrc,Len(aPecaOrc))
				aSize(aPecaOrc,Len(aPecaOrc)-1)
				VSJ->(DbSkip())
				Loop
			EndIf
		endif

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณFoi feita a reserva da pecaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If VSJ->VSJ_RESPEC == "1"
			aPecaOrc[Len(aPecaOrc) , PECAORC_LOCPAD  ] := cMVRESITE
			aPecaOrc[Len(aPecaOrc) , PECAORC_LOCALIZ ] := cMVRESLOC
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Adiciona Saldo do Estoque ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		aPecaOrc[Len(aPecaOrc),PECAORC_ESTOQUE] := FS_SALDOESTQ( SB1->B1_COD , aPecaOrc[Len(aPecaOrc), PECAORC_LOCPAD] )
		//

		DbSelectArea("VSJ")
		DbSkip()

	EndDo

	If Len(aPecaOrc) == 0
		ShowHelpDlg ( "NOVSJ", { STR0230 }) // "Nใo existe registro de pe็a pendente para requisi็ใo."
		Return .f.
	EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM020VSJATU  บAutor  ณ Rubens         บ Data ณ  21/06/2016 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza matriz dos dados da VSJ                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM020VSJATU( lAtuACols , lAtuEstoque )
	Local nCont := 1
	Local nReg

	While nCont <= Len(aPecaOrc)

		VSJ->(dbGoTo(aPecaOrc[nCont,18]))

		// Verifica se ainda existe registro na VSJ
		If VSJ->(Deleted()) .or. VSJ->VSJ_QTDITE <= 0
			nReg := FS_POSACOLS(nCont,.t.)

			If lAtuACols .and. nReg <> 0
				aCols[nReg,Len(aCols[nReg])] := .t.
			EndIf

			aDel(aPecaOrc,nCont)
			aSize(aPecaOrc,Len(aPecaOrc)-1)

		Else

			// Atualiza saldo do estoque
			If lAtuEstoque
				SB1->(dbSetOrder(7))
				SB1->(dbSeek(xFilial("SB1") + aPecaOrc[nCont,06] + aPecaOrc[nCont,07]))
				SB1->(dbSetOrder(1))

				aPecaOrc[nCont,PECAORC_ESTOQUE] := FS_SALDOESTQ( SB1->B1_COD , aPecaOrc[nCont, PECAORC_LOCPAD] )
			EndIf
			nCont++

		EndIf
		//

	End
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TPecOrcบAutor  ณFabio               บ Data ณ  09/28/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca pecas do orcamento                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TPecOrc( lAll , lMarcar , nPPecaOrc)
Local lRet := .t.
Local ni := 0
Local lExibMsg := .t.

Default lAll := .f.
Default lMarcar := .f.
Default nPPecaOrc := oLbPecaOrc:nAt

If lAll

	For ni := 1 to Len(aPecaOrc)
		If lMarcar
			If !FS_VALIMPORC( ni , @lExibMsg)
				lRet := .f.
			Else
				aPecaOrc[ni,1] := .t.
			EndIf
		Else
			aPecaOrc[ni,1] := .f.
		EndIf
	Next

Else

	If !aPecaOrc[nPPecaOrc,1] .And. FS_VALIMPORC( nPPecaOrc )
		aPecaOrc[nPPecaOrc,1] := .t.
	Else
		aPecaOrc[nPPecaOrc,1] := .f.
	EndIf

EndIf
If ! lOM020Auto
	oLbPecaOrc:Refresh()
	oLbSaldoAgru:Refresh()
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALIMPOบAutor  ณFabio               บ Data ณ  09/28/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a importacao do orcamento                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VALIMPORC( nReg , lMensagem)

Default lMensagem := .t.

// Verifica permissao do funcionario para o tipo de tempo
// Manoel - 27/10/2010 - FNC  16392
if lVOICONVOW
	VOI->(DbSetOrder(1))
	VOI->(MsSeek( xFilial("VOI") + aPecaOrc[nReg,2] ) )
	if !(VOI->VOI_CONVOW == "0")

		VAI->(dbSetOrder(4))
		VAI->(MsSeek(xFilial("VAI")+__cUserID))

		DbSelectArea("VOW")
		DbSetOrder(1)
		If !( MsSeek( xFilial("VOW") + VAI->VAI_CODTEC + aPecaOrc[nReg,2] ))
			If lMensagem
				Help(" ",1,"TPPRODUT")
				lMensagem := .f.
			Endif
			Return .f.
		EndIf
	EndIf
Endif
//

// Verifica se existe saldo para requisicao
If !FS_QTDDISP( aPecaOrc[nReg,6] ,;
				aPecaOrc[nReg,7] ,;
				aPecaOrc[nReg,9] ,;
				@lMensagem,;
				aPecaOrc[nReg,3]+aPecaOrc[nReg,4] ,;
				,;
				aPecaOrc[nReg,2],;
				,;
				.f. ,;
				aPecaOrc[nReg,20] ,;
				aPecaOrc[nReg,19] ,;
				IIF( lCtrlLote , aPecaOrc[nReg,PECAORC_LOTECT] , "") ,;
				IIF( lCtrlLote , aPecaOrc[nReg,PECAORC_NUMLOT] , "") ,;
				nReg ,;
				aPecaOrc[nReg,32] )

	// Se o saldo for zero nao permiti importar mas se tiver saldo parcial importa.
	DbSelectArea("SB1")
	DbSetOrder(7)
	MsSeek(xFilial("SB1")+aPecaOrc[nReg,6]+aPecaOrc[nReg,7])
	DbSetOrder(1)
	DbSelectArea("SB2")
	DbSetOrder(1)
	MsSeek(xFilial("SB2")+SB1->B1_COD+aPecaOrc[nReg,12])
	If SaldoSB2() <= 0
		Return(.f.)
	EndIf

EndIf
//

//Validacao por Ponto de Entrada
If ExistBlock("OM020VIO") // Valida Importa็ใo do Orcamento
	lRet := ExecBlock("OM020VIO",.f.,.f.,{nReg})
	If !lRet
		Return (.f.)
	Endif
Endif

// Validacao de Credito
If "P" $ cMVCHKCRE .and. GetNewPar("MV_MIL0138","1") <> "0" // Checagem do limite de Credito do Cliente, Pe็a a Pe็a
	If !OM0200091_LimiteCreditoPecasOrcamento( nReg , nReg , .f. )
		Return .f.
	EndIf
EndIf
//

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_IMPORC บAutor  ณMicrosiga           บ Data ณ  09/28/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Importa itens de orcamento                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_IMPORC( cButton )

Local ni := 0 , nReg := 0 , nCol := 0 , lAdd := .f., nQtdSaldo := 0
Local nQtdReserva := 0
Local lInconveniente := (GetNewPar("MV_INCORC","N") == "S")
Local lCpoDesconto := .f.
Local cMsgImpor := STR0114 + CHR(13)+CHR(10)+CHR(13)+CHR(10)//Os Itens:
Local lESTNEG  := (GetMV("MV_ESTNEG") == "S")
Private nVlrPec := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Usuario cancelou a tela de importacao de peca do orcamento ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cButton == "C"
	For ni := 1 to Len(aPecaOrc)
		aPecaOrc[ ni , 1] := aPecaSel[nI]
	Next
	Return
Else
	// Validacao de Credito
	If "P" $ cMVCHKCRE
		If !OM0200091_LimiteCreditoPecasOrcamento( 1 , len(aPecaOrc) , .t. ) // Validar com Todas as Pecas
			aPecaOrc := {} // Zerar vetor para novo levantamento
			aPecaSel := {} // Zerar vetor para novo levantamento
			Return
		EndIf
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Indica se os campos de desconto estao criado ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if FG_POSVAR("VO3_VALDES") <> 0 .and. VO3->(FieldPos("VO3_VALDES")) <> 0 .and. ;
	FG_POSVAR("VO3_PERDES") <> 0 .and. VO3->(FieldPos("VO3_PERDES")) <> 0 .and. ;
	VO3->(FieldPos("VO3_VALLIQ")) <> 0
	lCpoDesconto := .t.
endif

For ni := 1 to Len(aPecaOrc)

	lAdd := .f.
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRubens - 05/11/2009                                                                   ณ
	//ณAdiciona um registro novo na aCols somente quando TT, Grupo e Codigo estiver em brancoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF !Empty(aCols[Len(aCols),FG_POSVAR("VO3_TIPTEM")]) .and. !Empty(aCols[Len(aCols),FG_POSVAR("VO3_GRUITE")]) .and. !Empty(aCols[Len(aCols),FG_POSVAR("VO3_CODITE")])
		lAdd := .t.
	ENDIF

	//
	nReg := FS_POSACOLS( ni , .t. )

	// Marcado para importar
	If aPecaOrc[ni,1]

		If nReg == 0
			If lAdd
				Aadd(aCols, Array( Len(aHeader)+1 ) )
				nReg := Len(aCols)

				For nCol := 1 to Len(aHeader)
					aCols[nReg,nCol] := CriaVar( aHeader[nCol,2] )
				Next
			EndIf
			nReg := Len(aCols)
		Else
			aCols[nReg,Len(aCols[nReg])] := .f.
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica se ela estava marcada anteriormente, se estava nao faz nada ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		if aPecaSel[nI] .and. nReg <> 0
			Loop
		endif
		//

		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek(xFilial()+aPecaOrc[ni,6]+aPecaOrc[ni,7])

		aCols[nReg,FG_POSVAR("VO3_TIPTEM")] := aPecaOrc[ni,2]
		aCols[nReg,FG_POSVAR("VO3_FATPAR")] := aPecaOrc[ni,3]
		aCols[nReg,FG_POSVAR("VO3_LOJA")  ] := aPecaOrc[ni,4]
		aCols[nReg,FG_POSVAR("VO3_NOMCLI")] := aPecaOrc[ni,5]
		aCols[nReg,FG_POSVAR("VO3_GRUITE")] := aPecaOrc[ni,6]
		aCols[nReg,FG_POSVAR("VO3_CODITE")] := aPecaOrc[ni,7]
		aCols[nReg,FG_POSVAR("VO3_DESITE")] := aPecaOrc[ni,8]
		aCols[nReg,FG_POSVAR("VO3_CODTES")] := aPecaOrc[ni,19]
		if VO3->(FieldPos("VO3_OPER")) > 0
			aCols[nReg,FG_POSVAR("VO3_OPER")]   := aPecaOrc[ni,26]
		Endif
		VAI->(DbSetOrder(4))
		VAI->(MsSeek(xFilial("VAI")+__cUserID))
		If VAI->VAI_FUNPRO=="1" .and. VAI->VAI_REQPEC == "1"
			aCols[nReg,FG_POSVAR("VO3_PROREQ")] := VAI->VAI_CODTEC
		EndIf

		nQtdSaldo := FS_SALDOESTQ( SB1->B1_COD , aPecaOrc[ni, PECAORC_LOCPAD] )

		If FG_POSVAR("VO3_LOCPRO")#0
			aCols[nReg,FG_POSVAR("VO3_LOCPRO")] := OM020LOCACAO( SB1->B1_COD )
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Posiciona TES para verificar se movimenta estoque ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+aPecaOrc[ni,19]))

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPL 31 - Shark - Rubens - 21/10/2009 ณ
		//ณProcura reserva do item             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nQtdReserva := 0
		IF aPecaOrc[ni,PECAORC_RESPEC] == "1" //.and. GetNewPar("MV_RITEORC","N") == "S"
			nQtdReserva := FM_SALDORESV(aPecaOrc[ni,6],aPecaOrc[ni,7],M->VO2_NUMOSV,aPecaOrc[ni,PECAORC_LOTECT],aPecaOrc[ni,PECAORC_NUMLOT],aPecaOrc[ni,PECAORC_SUGCOM])
		ENDIF

		If FG_POSVAR("VO3_QTDEST")#0
			aCols[nReg,FG_POSVAR("VO3_QTDEST")]:=M->VO3_QTDEST:= nQtdSaldo
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRubens                                                ณ
		//ณSe o item estiver excluido na aCols, zera a qtde antesณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		if !lAdd .and. aCols[nReg,Len(aHeader)+1]
			aCols[nReg,FG_POSVAR("VO3_QTDREQ")] := 0
		endif

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPL 31 - Shark - Rubens - 21/10/2009ณ
		//ณSe foi feita reserva ...           ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If aPecaOrc[ni,PECAORC_RESPEC] == "1"
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPL 31 - Shark - Rubens - 21/10/2009              ณ
			//ณSe a qtde for maior do que a reserva, requisitar ณ
			//ณsomente as pecas reservadas                      ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nQtdReserva < (aCols[nReg,FG_POSVAR("VO3_QTDREQ")]+aPecaOrc[ni,9])
				aCols[nReg,FG_POSVAR("VO3_QTDREQ")] := nQtdReserva
			Else
				aCols[nReg,FG_POSVAR("VO3_QTDREQ")] := aPecaOrc[ni,9]
			EndIf
		Else
			aCols[nReg,FG_POSVAR("VO3_QTDREQ")] := aPecaOrc[ni,9]
		EndIf

		If !lESTNEG // nใo pode trabalhar com Estoque Negativo (MV_ESTNEG == "N")
			// Se tiver saldo para a requisicao e movimenta estoque
			If nQtdSaldo < aCols[nReg,FG_POSVAR("VO3_QTDREQ")] .and. SF4->F4_ESTOQUE == "S"
				aCols[nReg,FG_POSVAR("VO3_QTDREQ")] := nQtdSaldo
			EndIf
			//
		EndIf

		//funcao para validar a quantidade maxima do item por modelo
		If !VALPMOD020( aCols[nReg,FG_POSVAR("VO3_GRUITE")] , aCols[nReg,FG_POSVAR("VO3_CODITE")] , aCols[nReg,FG_POSVAR("VO3_QTDREQ")] , "2")
			aCols[nReg,FG_POSVAR("VO3_QTDREQ")] := 0
			cMsgImpor += Alltrim(aCols[nReg,FG_POSVAR("VO3_GRUITE")])+" - "+Alltrim(aCols[nReg,FG_POSVAR("VO3_CODITE")]) +CHR(13)+CHR(10)
		EndIf

		aCols[nReg,FG_POSVAR("VO3_FORMUL")] := aPecaOrc[ni,10]
		aCols[nReg,FG_POSVAR("VO3_VALPEC")] := aPecaOrc[ni,11]
		aCols[nReg,FG_POSVAR("VO3_VALTOT")] := (aCols[nReg,FG_POSVAR("VO3_QTDREQ")] * aCols[nReg,FG_POSVAR("VO3_VALPEC")] )
		aCols[nReg,Len(aCols[nReg])]        := .F.

		//ฺฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Desconto ณ
		//ภฤฤฤฤฤฤฤฤฤฤู
		if lCpoDesconto
			aCols[nReg,FG_POSVAR("VO3_PERDES")] := aPecaOrc[ni,23]
			aCols[nReg,FG_POSVAR("VO3_VALDES")] := Iif( aCols[nReg,FG_POSVAR("VO3_QTDREQ")]  != aPecaOrc[ni,9],( aPecaOrc[ni,11] - aPecaOrc[ni,25] ) * aCols[nReg,FG_POSVAR("VO3_QTDREQ")], aPecaOrc[ni,24])
			aCols[nReg,FG_POSVAR("VO3_VALLIQ")] := aPecaOrc[ni,25]
			aCols[nReg,FG_POSVAR("VO3_VALTOT")] := (aCols[nReg,FG_POSVAR("VO3_QTDREQ")] * aPecaOrc[ni,25] )
		endif

		if lInconveniente
			aCols[nReg,FG_POSVAR("VO3_GRUINC")] := aPecaOrc[nI,15]
			aCols[nReg,FG_POSVAR("VO3_CODINC")] := aPecaOrc[nI,16]
			aCols[nReg,FG_POSVAR("VO3_DESINC")] := aPecaOrc[nI,17]
			aCols[nReg,FG_POSVAR("VO3_SEQINC")] := aPecaOrc[nI,20]
		endif

		aCols[nReg,FG_POSVAR("VO3_IMPORC")] := "1"
		aCols[nReg,FG_POSVAR("VO3_DEPGAR")] := aPecaOrc[nI,28]
		aCols[nReg,FG_POSVAR("VO3_DEPINT")] := aPecaOrc[nI,29]

		aCols[nReg,FG_POSVAR("VO3_LOTECT")] := aPecaOrc[nI,PECAORC_LOTECT]
		aCols[nReg,FG_POSVAR("VO3_NUMLOT")] := aPecaOrc[nI,PECAORC_NUMLOT]

		If lVSJCODIGO
			aCols[nReg,FG_POSVAR("VO3_CODVSJ")] := aPecaOrc[nI,PECAORC_CODIGOVSJ]
		EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Linha Excluida ... ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Else

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica se ela estava marcada anteriormente, se estava deve excluir a linha da GetDados ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		if aPecaSel[nI] .and. nReg <> 0
			aCols[nReg,Len(aCols[nReg])] := .t.
		endif

	EndIf

	If ExistBlock("RQPCOM020")
		ExecBlock("RQPCOM020",.f.,.f.,{ni,nReg})
	EndIf

Next
IF cMsgImpor <> STR0114 + CHR(13)+CHR(10)+CHR(13)+CHR(10)//Os Itens:
	cMsgImpor +=CHR(13)+CHR(10)+STR0113 //terao as quantidades zeradas pois exedeu o limite maximo permitido por modelo.
	MsgAlert(cMsgImpor,STR0075) // Aten็ใo
EndIF

FS_TOTAL()

if n > Len(aCols)
	n := 1
endif

FS_MEMVAR()
if !lOM020Auto
	FS_BLQCPO(M->VO3_GRUITE, M->VO3_CODITE, IIF(lInconveniente, M->VO3_SEQINC , "" ),lInconveniente )
EndIf

if n >= 1
	VOI->(dbSetOrder(1))
	VOI->(dbSeek(xfilial("VOI")+M->VO3_TIPTEM))
endif

If !lOM020Auto
	oGetReqPec:oBrowse:Refresh()
EndIf

Return

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFS_CATALOGO ณ Autor ณ Fabio                 ณ Data ณ 25/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณMostra catalogo de pecas da marca do veiculo.                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_CATALOGO()

Local cSelect1 := Alias()



Local cTitReq , nOperacao := 0

Local oOficina := DMS_Oficina():New()

Private oLbTexto
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oLbItens,lBxFilho := .f.
Private aPecas := {} ,aPecasSele := {},aArqTxt:={}                     //Nome do Vetor em Uso

DbSelectArea("VE4")
DbSetOrder(1)
If !(DbSeek(xFilial("VE4")+VV1->VV1_CODMAR))
	Help(" ",1,"NAOPARFAB")
	Return
EndIf

cTitReq := cTitulo+STR0037+M->VO2_DESMAR // - Catalogo Fabrica

nOperacao := Aviso( cTitReq , STR0038 , { STR0039 , STR0040 , STR0041 } ) //Tipo de consulta Catalogo###Nova###Ja Existente###Cancelar

If nOperacao == 3

	Return

EndIf

If nOperacao == 1

	WaitRun(VE4->VE4_DIRFEX,1)                          //Chamada do Executavel do catalogo.

EndIf

aPecas := &( Alltrim(VE4->VE4_FUNCAO) )            //Chamada da Funcao p/ Montar os Itens

If Len(aArqTxt) == 0
	Return
EndIf

DEFINE MSDIALOG oDlgPecas TITLE cTitReq From 7,08 to 36,92      of oMainWnd

@ 17,.2 SAY aHeader[FG_POSVAR("VO3_TIPTEM"),1] OF oDlgPecas PIXEL COLOR CLR_BLUE
@ 17,033 MSGET M->VO3_TIPTEM PICTURE "@!" F3 "VIO" VALID !oOficina:TipoTempoBloqueado(M->VO3_TIPTEM,.t.).And.FG_TIPTPFAT(,"M->VO3_FATPAR","M->VO3_LOJA","M->VO3_NOMCLI") OF oDlgPecas PIXEL COLOR CLR_BLACK
@ 17,060 MSGET VOI->VOI_DESTTE PICTURE "@!S15" SIZE 080,10 OF oDlgPecas PIXEL COLOR CLR_BLUE when .f.

@ 17,150 SAY aHeader[FG_POSVAR("VO3_FATPAR"),1] OF oDlgPecas PIXEL COLOR CLR_BLUE
@ 17,183 MSGET M->VO3_FATPAR PICTURE "@!" F3 "SA1" VALID FG_SEEK("SA1","M->VO3_FATPAR",1) OF oDlgPecas PIXEL COLOR CLR_BLACK When If(Posicione("VOI",1,xFilial("VOI")+M->VO3_TIPTEM,"VOI_ALTCLI") == "0",.f.,.t.)
//@ 17,225 MSGET M->VO3_NOMCLI PICTURE "@!S15" SIZE 080,10 OF oDlgPecas PIXEL COLOR CLR_BLUE When .f.

@ 32,.2 SAY aHeader[FG_POSVAR("VO3_LOJA"),1] OF oDlgPecas PIXEL COLOR CLR_BLUE
@ 32,033 MSGET M->VO3_LOJA PICTURE "@!" VALID FG_SEEK("SA1","M->VO3_FATPAR+M->VO3_LOJA",1,.F.) .AND. FS_NOMCLI() OF oDlgPecas PIXEL COLOR CLR_BLACK When If(Posicione("VOI",1,xFilial("VOI")+M->VO3_TIPTEM,"VOI_ALTCLI") == "0",.f.,.t.)
@ 32,060 MSGET M->VO3_NOMCLI PICTURE "@!S15" SIZE 080,10 OF oDlgPecas PIXEL COLOR CLR_BLUE When .f.

@ 32,150 SAY aHeader[FG_POSVAR("VO3_GRUITE"),1] OF oDlgPecas PIXEL COLOR CLR_BLUE
@ 32,183 MSGET M->VO3_GRUITE PICTURE "@!" F3 "E13" VALID SBM->(DbSeek(xFilial("SBM")+M->VO3_GRUITE)).And.FG_GRUTEM( M->VO3_TIPTEM ) OF oDlgPecas PIXEL COLOR CLR_BLACK
@ 32,225 MSGET SBM->BM_DESC PICTURE "@!S15" SIZE 080,10 OF oDlgPecas PIXEL COLOR CLR_BLUE When .f.

@ 48,.2  SAY aHeader[FG_POSVAR("VO3_PROREQ"),1] OF oDlgPecas PIXEL COLOR CLR_BLUE
@ 48,033 MSGET M->VO3_PROREQ PICTURE "@!" F3 "V1A" SIZE 020,10  VALID VAI->(DbSeek(xFilial("VAI")+M->VO3_PROREQ)).And.VAI->VAI_FUNPRO != "0".And.FG_PROTRA(M->VO2_NUMOSV,M->VO3_PROREQ) OF oDlgPecas PIXEL COLOR CLR_BLACK
@ 48,060 MSGET VAI->VAI_NOMTEC PICTURE "@!S15" SIZE 080,10 OF oDlgPecas PIXEL COLOR CLR_BLUE When .f.

@ 60,002 TO 220,331 LABEL STR0042 OF oDlgPecas PIXEL //Catalogos

@ 5,001 LISTBOX oLbTexto FIELDS HEADER  (STR0043),; // Cod item //Arquivo
(STR0044),; //Tamanho
(STR0045),; //Data
(STR0046),; //Hora
(STR0047); //Atributos
COLSIZES 60,60,60,60,60;
SIZE 316,50 OF oDlgPecas ON CHANGE (FS_ITENS(olbTexto:nAt))

oLbTexto:SetArray(aArqTxt)
oLbTexto:bLine := { || { aArqTxt[oLbTexto:nAt,1] ,;
	str(aArqTxt[oLbTexto:nAt,2]) ,;
	dtoc(aArqTxt[oLbTexto:nAt,3]) ,;
	aArqTxt[oLbTexto:nAt,4] ,;
	aArqTxt[oLbTexto:nAt,5]}}

@ 9,001 LISTBOX oLbItens FIELDS HEADER (""),;
	(STR0011),; //  //Cod Item
	(STR0012),; //  //Descricao
	(STR0034); //  //Quantidade
	COLSIZES 60,60,90,20 ;
	SIZE 316,88 OF oDlgPecas ON DBLCLICK(If(Val(aPecasSele[oLbItens:nAt,4])#0,If(aPecasSele[oLbItens:nAt,1],aPecasSele[oLbItens:nAt,1]:=.F.,aPecasSele[oLbItens:nAt,1]:=.T.),.T.),IIF(aPecasSele[oLbItens:nAt,1],oOk,oNo))

ACTIVATE MSDIALOG oDlgPecas ON INIT EnchoiceBar(oDlgPecas,{|| If( FS_CONFREQ(aArqTxt[oLbTexto:nAt,1]) , oDlgPecas:End() , .f. ) },{|| oDlgPecas:End() }) CENTER

oGetReqPec:ForceRefresh()

DbSelectArea(cSelect1)

Return

Function FS_NOMCLI()

If SA1->(MsSeek(xFilial("SA1")+M->VO3_FATPAR+M->VO3_LOJA))
	M->VO3_NOMCLI := SA1->A1_NOME
	Return(.t.)
EndIf

Return(.f.)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFS_ITENS    ณ Autor ณ Fabio                 ณ Data ณ 25/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Filtra os Itens de acordo com o arquivo.                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_ITENS(nLin)

Local cont := 0

aPecasSele := {}
For cont:=1 to Len(aPecas)
	If Alltrim(aPecas[cont,1]) == Alltrim(aArqTxt[nLin,1])
		Aadd(aPecasSele,{ If(Val(aPecas[cont,4]) == 0,.F.,.T.) , aPecas[cont,2] , aPecas[cont,3] , aPecas[cont,4] })
	EndIf
Next

If Len( aPecasSele ) == 0
	Aadd(aPecasSele,{ .F. , "" , "" , "0" })
EndIf

oLbItens:SetArray(aPecasSele)
oLbItens:bLine := { || {  IIF(aPecasSele[oLbItens:nAt,1],oOk,oNo) ,;
	aPecasSele[oLbItens:nAt,2] ,;
	aPecasSele[oLbItens:nAt,3] ,;
	aPecasSele[oLbItens:nAt,4]}}
oLbItens:SetFocus()
oLbTexto:SetFocus()

Return

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFS_CONFREQ  ณ Autor ณ Fabio                 ณ Data ณ 25/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Confere se a pecas pode ser requisitada                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_CONFREQ(cArquivo)

Local aArquivo := {}
Local nHandle , cString , nTamanho , cont := 0
Local nValUnit := 0 , _ni := 0

Local cReadVar := ReadVar()

//nHandle  := Alltrim(VE4->VE4_DIRFAB)+cArquivo
cArquivo := Alltrim( Substr( VE4->VE4_DIRFAB , 1 , Rat(ALLTRIM(" \ "),VE4->VE4_DIRFAB) ) ) + cArquivo
nHandle  := FOpen(cArquivo,FO_READWRITE)
cString  := FSeek(nHandle,0,2)
nTamanho := (cString/Len(aPecasSele))


FSeek(nHandle,0)

For cont:=1 to Len(aPecasSele)
	If aPecasSele[cont,1]

		DbSelectArea("SB1")
		DbSetOrder(7)
		If !DbSeek(xFilial("SB1")+M->VO3_GRUITE+aPecasSele[cont,2])
			Help(" ",1,"REGNOIS",,RetTitle("VO3_GRUITE") + ": " + M->VO3_GRUITE + CHR(13) + CHR(10) + RetTitle("VO3_CODITE") + ": " + AllTrim(aPecasSele[cont,2]),4,1)
			Return( .f. )
		EndIf

		If !FS_QTDDISP(M->VO3_GRUITE,aPecasSele[cont,2],Val(aPecasSele[cont,4]),.F.,,,M->VO3_TIPTEM)                         // **********************Teste
			Help(" ",1,"CATALOGO")
			Return( .f. )
		EndIf

		nValUnit := FG_VALPEC(M->VO3_TIPTEM,"M->VO3_FORMUL",M->VO3_GRUITE,aPecasSele[cont,2],"M->VO3_VALPEC",.f.,.t.)

		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek(xFilial("SB1")+M->VO3_GRUITE+aPecasSele[cont,2])

		Aadd(aCols, Array(Len(aHeader)+1) )

		aCols[Len(aCols),FG_POSVAR("VO3_TIPTEM")] := M->VO3_TIPTEM
		aCols[Len(aCols),FG_POSVAR("VO3_FATPAR")] := M->VO3_FATPAR
		aCols[Len(aCols),FG_POSVAR("VO3_LOJA")]   := M->VO3_LOJA
		aCols[Len(aCols),FG_POSVAR("VO3_NOMCLI")] := Posicione("SA1",1,xFilial("SA1")+M->VO3_FATPAR,"A1_NOME")
		aCols[Len(aCols),FG_POSVAR("VO3_GRUITE")] := M->VO3_GRUITE
		aCols[Len(aCols),FG_POSVAR("VO3_CODITE")] := aPecasSele[cont,2]
		aCols[Len(aCols),FG_POSVAR("VO3_DESITE")] := SB1->B1_DESC

		If FG_POSVAR("VO3_QTDEST") # 0
			aCols[Len(aCols),FG_POSVAR("VO3_QTDEST")]:=M->VO3_QTDEST:= FS_SALDOESTQ( SB1->B1_COD , OM0200065_ArmazemOrigem( M->VO3_TIPTEM ) )
		EndIf

		If FG_POSVAR("VO3_LOCPRO") # 0 .And. (cReadVar == 'M->VO3_GRUITE' .or. cReadVar == 'M->VO3_CODITE')
			aCols[Len(aCols),FG_POSVAR("VO3_LOCPRO")]:= M->VO3_LOCPRO:= OM020LOCACAO( SB1->B1_COD )
		Endif

		aCols[Len(aCols),FG_POSVAR("VO3_QTDREQ")] := Val(aPecasSele[cont,4])
		aCols[Len(aCols),FG_POSVAR("VO3_PROREQ")] := M->VO3_PROREQ
		//       aCols[Len(aCols),] := " "
		aCols[Len(aCols),FG_POSVAR("VO3_FORMUL")] := M->VO3_FORMUL
		aCols[Len(aCols),FG_POSVAR("VO3_VALPEC")] := nValUnit
		aCols[Len(aCols),FG_POSVAR("VO3_VALTOT")] := nValUnit * aCols[Len(aCols),FG_POSVAR("VO3_QTDREQ")]
		aCols[Len(aCols),Len(aCols[Len(aCols)])] := .F.

		For _ni := 1 to Len(aHeader)
			If Empty(aCols[Len(aCols),_ni])
				aCols[Len(aCols),_ni]:=CriaVar(aHeader[_ni,2])
			EndIf
		Next

		aPecasSele[cont,4] := "0"
		aPecasSele[cont,1] := .F.
		aPecas[cont,4]     := "0"

	EndIf

	cString  := FREADSTR(nHandle,nTamanho)
	Aadd(aArquivo,cString)

Next

For cont:=1 to len(aPecasSele)
	If Val(aPecasSele[cont,4]) == 0
		aArquivo[cont] := Substr(aArquivo[cont],1,VE4->VE4_QTDINI)+Space(VE4->VE4_QTDTAM-2)+"0"+Substr(aArquivo[cont],(VE4->VE4_QTDINI+VE4->VE4_QTDTAM))
	EndIf
	FSeek(nHandle,(cont-1)*(nTamanho),0)

	FWRITE(nHandle,aArquivo[cont])
Next

FClose(nHandle)

FS_TOTAL()

If Ascan( aPecasSele , {|x| Alltrim(x[4]) # "0" } ) == 0
	Delet File &(cArquivo)
	oDlgPecas:End()
EndIf

oLbItens:SetFocus()
oLbTexto:SetFocus()

Return( .t. )

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFS_DFATPAR  ณ Autor ณ Fabio                 ณ Data ณ 25/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Se devolucao Devolve o faturar par do Item                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Exclusivo                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_DFATPAR()

Local oLbFatPar , lMostra := .t. , w := 0
Local lIgual
Private aFatPar := {} , oDlgFatPar

If (ReadVar() == "M->VO3_CODITE") .And. cReqDev == "0"

	aFatPar:={}
	DbSelectArea("VO2")
	Fg_Seek("VO2","M->VO2_NUMOSV",1,.f.)
	Do While !Eof() .And. VO2->VO2_FILIAL == xFilial("VO2") .and. VO2->VO2_NUMOSV == M->VO2_NUMOSV
		DbSelectArea("VO3")
		Fg_Seek("VO3","VO2->VO2_NOSNUM",1,.f.)
		Do While !Eof() .And. VO3->VO3_FILIAL == xFilial("VO3") .And. VO3->VO3_NOSNUM == VO2->VO2_NOSNUM
			if lInconveniente
				lIgual := (VO3->VO3_TIPTEM+VO3->VO3_GRUITE+VO3->VO3_CODITE+VO3->VO3_GRUINC+VO3->VO3_CODINC == aCols[n,FG_POSVAR("VO3_TIPTEM")]+aCols[n,FG_POSVAR("VO3_GRUITE")]+M->VO3_CODITE+aCols[n,FG_POSVAR("VO3_GRUINC")]+aCols[n,FG_POSVAR("VO3_CODINC")])
			else
				lIgual := (VO3->VO3_TIPTEM+VO3->VO3_GRUITE+VO3->VO3_CODITE == aCols[n,FG_POSVAR("VO3_TIPTEM")]+aCols[n,FG_POSVAR("VO3_GRUITE")]+M->VO3_CODITE)
			endif
			If lIgual
				lMostra:=.t.
				For w:=1 to Len(aFatPar)
					If Alltrim(aFatPar[w,1]) == Alltrim(VO3->VO3_FATPAR)
						lMostra:=.f.
						Exit
					EndIf
				Next
				If lMostra
					AADD(aFatPar,Array(2))
					aFatPar[Len(aFatPar)] := {VO3->VO3_FATPAR,Posicione("SA1",1,xFilial("SA1")+VO3->VO3_FATPAR,"A1_NOME"),VO3->VO3_FORMUL,VO3->VO3_VALPEC }
				EndIf
			EndIf

			DbSkip()
		EndDo

		DbSelectArea("VO2")
		DbSkip()
	EndDo

	VOI->(dbSeek(xFilial("VOI")+aCols[n,FG_POSVAR("VO3_TIPTEM")]))
	If VOI->VOI_ALTCLI == "0" .And. VOI->VOI_USAPRO == "2"
		aCols[n,FG_POSVAR("VO3_FATPAR")] := VOI->VOI_CLIFAT
		aCols[n,FG_POSVAR("VO3_NOMCLI")] := Posicione("SA1",1,xFilial("SA1")+VOI->VOI_CLIFAT,"A1_NOME")
		nPosFatPar := Ascan(aFatPar,{|x| x[1] == VOI->VOI_CLIFAT })
		Return(.t.)
	EndIf

	If Len(aFatPar) > 1

		DEFINE MSDIALOG oDlgFatPar TITLE STR0048 From 23,08 to 31,88   of oMainWnd //Devolucao Para

		@ .1,.1 LISTBOX oLbFatPar FIELDS HEADER (STR0043),; // Cod item //Arquivo
			(STR0047); //Atributos
			COLSIZES 60,90;
			SIZE 316,60 OF oDlgFatPar ON DBLCLICK FS_DPARA(oLbFatPar:nAt)

		oLbFatPar:SetArray(aFatPar)
		oLbFatPar:bLine := { || { aFatPar[oLbFatPar:nAt,1] ,;
			aFatPar[oLbFatPar:nAt,2]}}

		ACTIVATE MSDIALOG oDlgFatPar

	ElseIf Len(aFatPar) == 1

		FS_DPARA(1)
		Return(.t.)

	Else

		Return(.f.)

	EndIF

EndIf

Return(.t.)

Function FS_DPARA(nLin)

aCols[n,FG_POSVAR("VO3_FATPAR")] := Alltrim(aFatPar[nLin,1])
aCols[n,FG_POSVAR("VO3_NOMCLI")] := Alltrim(aFatPar[nLin,2])
If Len(aFatPar) > 1
	oDlgFatPar:End()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ITEREL บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMostra Itens relacionados das pecas                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_ITEREL(nLin)

Local nSalvaValor := 0


Local nPosPecOrc

If Pcount() == 1
	nSalvaValor := aCols[n,FG_POSVAR("VO3_VALPEC")]
	aCols[n,FG_POSVAR("VO3_VALPEC")]:= aItensRel[nLin,5]

	If !FS_QTDDISP(aItensRel[nLin,1],aItensRel[nLin,2],aCols[n,FG_POSVAR("VO3_QTDREQ")],.T.,,,,,,,M->VO3_CODTES)

		aCols[n,FG_POSVAR("VO3_VALPEC")] := nSalvaValor
		Return

	EndIf
	If VO3->(FieldPos("VO3_VALLIQ")) <> 0 .and. FG_POSVAR("VO3_VALLIQ") <> 0
		M->VO3_VALLIQ := aCols[n,FG_POSVAR("VO3_VALLIQ")] := aItensRel[nLin,5]
		M->VO3_VALDES := aCols[n,FG_POSVAR("VO3_VALDES")] := 0
		M->VO3_PERDES := aCols[n,FG_POSVAR("VO3_PERDES")] := 0
	EndIf
	If FG_POSVAR("VO3_IMPORC") <> 0
		If aCols[n,FG_POSVAR("VO3_IMPORC")] == "1"
			nPosPecaOrc := FS_POSORC2( .t. , .t. , n)
			If nPosPecOrc <> 0
				aPecaOrc[nPosPecOrc,1] := .f.
			EndIf
		EndIf
		M->VO3_IMPORC := aCols[n,FG_POSVAR("VO3_IMPORC")] := "0"
	EndIf
	If FG_POSVAR("VO3_CODVSJ") <> 0
		M->VO3_CODVSJ := aCols[n,FG_POSVAR("VO3_CODVSJ")] := Space(TamSX3("VO3_CODVSJ")[1])
	EndIf
	M->VO3_GRUITE := aCols[n,FG_POSVAR("VO3_GRUITE")]:= aItensRel[nLin,1]
	M->VO3_CODITE := aCols[n,FG_POSVAR("VO3_CODITE")]:= aItensRel[nLin,2]
	M->VO3_DESITE := aCols[n,FG_POSVAR("VO3_DESITE")]:= aItensRel[nLin,3]

	// Quando trocar o item deve deixar a TES em branco para recarregar com a TES do novo item informado
	aCols[n,FG_POSVAR("VO3_CODTES")] := Space(TAMSX3("VO3_CODTES")[1])
	M->VO3_CODTES := Space(TAMSX3("VO3_CODTES")[1])

	M->VO3_VALPEC := aCols[n,FG_POSVAR("VO3_VALPEC")]
	M->VO3_QTDREQ := aCols[n,FG_POSVAR("VO3_QTDREQ")]
	M->VO3_VALTOT := aCols[n,FG_POSVAR("VO3_VALTOT")] := Round(M->VO3_VALPEC * M->VO3_QTDREQ,2)

	OM0200139_CarregaTES()
	
	If FG_POSVAR("VO3_QTDEST")#0
		aCols[n,FG_POSVAR("VO3_QTDEST")] := M->VO3_QTDEST := FS_SALDOESTQ( SB1->B1_COD , OM0200065_ArmazemOrigem( aCols[n,FG_POSVAR("VO3_TIPTEM")] ) )
	EndIf
	oGetReqPec:oBrowse:Refresh()
EndIf

aItensRel := FS_MNTITEREL(;
	aCols[n,FG_POSVAR("VO3_TIPTEM")],;
	aCols[n,FG_POSVAR("VO3_GRUITE")],;
	If(ReadVar()=="M->VO3_CODITE",M->VO3_CODITE,aCols[n,FG_POSVAR("VO3_CODITE")]),;
	"M->VO3_FORMUL",;
	OM0200065_ArmazemOrigem( aCols[n,FG_POSVAR("VO3_TIPTEM")] );
	)


oLbIteRel:SetArray(aItensRel)
oLbIteRel:bLine := { || { aItensRel[oLbIteRel:nAt,6] ,;
	aItensRel[oLbIteRel:nAt,7] ,;
	aItensRel[oLbIteRel:nAt,8] ,;
	aItensRel[oLbIteRel:nAt,1] ,;
	aItensRel[oLbIteRel:nAt,2] ,;
	aItensRel[oLbIteRel:nAt,3] ,;
	FG_AlinVlrs(Transform(aItensRel[oLbIteRel:nAt,4],"@E 999,999")),;
	FG_AlinVlrs(Transform(aItensRel[oLbIteRel:nAt,5],"@E 999,999,999.99"))}}


oLbIteRel:nAt := 1
oLbIteRel:SetFocus(1)
oLbIteRel:Refresh()

Return(.t.)

Static Function FS_MNTITEREL( cParTipTem, cParGrupo, cParCodIte, cParFormula , cArmSB2 )

Local aAuxItensRel := FG_ITEREL(cParTipTem, cParGrupo, cParCodIte, cParFormula, cArmSB2 )
Local nCntFor
Local cFilSBM := xFilial("SBM")
Local cFilVE1 := xFilial("VE1")
Local cSQLSB1 := "SELECT B1_COD FROM " + RetSQLName("SB1") + " WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND D_E_L_E_T_ = ' ' "

VE1->(DBSetOrder(1))
SB1->(DBSetOrder(7))

For nCntFor := 1 to Len(aAuxItensRel)
	SBM->(MsSeek( cFilSBM + aAuxItensRel[nCntFor,1]))
	VE1->(MsSeek( cFilVE1 + SBM->BM_CODMAR))
	aAdd(aAuxItensRel[nCntFor],SBM->BM_CODMAR)
	aAdd(aAuxItensRel[nCntFor],VE1->VE1_DESMAR)
	aAdd(aAuxItensRel[nCntFor], FM_SQL(cSQLSB1 + "AND B1_GRUPO = '" + aAuxItensRel[nCntFor,1] + "' AND B1_CODITE = '" + aAuxItensRel[nCntFor,2] + "'" ) )
Next

Return aAuxItensRel

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFS_QTDDISP  ณ Autor ณ Fabio                 ณ Data ณ 25/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Verifica se a Peca esta disponivel p/ ser requisitada.       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametro ณ cGruIte:=Grupo do Item                                       ณฑฑ
ฑฑณ          ณ cCodIte:=Codigo do Item                                      ณฑฑ
ฑฑณ          ณ nQtd:=Quantidade a Pesquisar                                 ณฑฑ
ฑฑณ          ณ lMensagem:=Mostra Mensagem                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Exclusivo                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_QTDDISP(cGruIte,cCodIte,nQtd,lMensagem,cCodCli,lValor,cTipTem,laCols,lValPecOrc,cSeqInc,cCodTes, cLote, cSubLote , nLinVet , cVO3_CODVSJ )

Local nDisponivel
Local nQtdReq   := 0
Local nQuantReq := 0
Local nQuantDev := 0
Local aFatPar   := {}
Local nVerQtd
Local i := 0
Local cLocPad    := ""
Local nLocPadReg := 0
Local nQtdReserva

Local cAuxGrupo  := ""
Local cAuxCodigo := ""
Local lAddQtd := .f.

Local lESTNEG  := (GetMV("MV_ESTNEG") == "S")
Local lValidEst := .t.

Default lMensagem := .t.
Default lValor    := .f.
Default cTipTem   :=  M->VO3_TIPTEM
Default laCols    := .t.
Default lValPecOrc:= .t.
Default cSeqInc   := ""
Default cCodTes   := ""
Default cLote     := ""
Default cSubLote  := ""
Default nLinVet   := 0
Default cVO3_CODVSJ := ""

if lInconveniente .and. Len(cSeqInc) == 0
	cSeqInc := Space(TamSX3("VS3_SEQINC")[1])
endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se a TES Movimenta estoque ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF !Empty(cCodTes)
	if FM_SQL("SELECT F4_ESTOQUE FROM " + RetSQLName("SF4") + " WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = '" + cCodTes + "' AND D_E_L_E_T_ = ' '") <> "S"
		return .t.
	endif
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRequisicao...ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cReqDev == "1"

	DbSelectArea("SB1")
	DbSetOrder(7)
	DbSeek( xFilial("SB1") + cGruIte + cCodIte )

	cLocPad := OM0200065_ArmazemOrigem( cTipTem )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExiste peca que pode ser importada do Orcamentoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Type("aPecaOrc") # "U" .And. Len(aPecaOrc) # 0

		If nLinVet == 0
			nLocPadReg := FS_POSPECAORC(;
				.T.,;
				lValPecOrc, ;
				cTiptem ,;
				/* cParFatPar */ , ;
				/* cParLoja   */ , ;
				cGruIte, ;
				cCodIte, ;
				cSeqInc, ;
				IIf(!Empty(cVO3_CODVSJ),cVO3_CODVSJ,nil) /* cParVSJCod */ , ;
				cLote, ;
				cSubLote )
		Else
			nLocPadReg := nLinVet
		EndIf

		if nLocPadReg # 0
			cLocPad := aPecaOrc[nLocPadReg,12]

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPL 31 - Shark - Rubens - 21/10/2009                                        ณ
			//ณSe tiver sido reservado, deixar requisitar somente a quantidade reservada, ณ
			//ณpara nใo acontecer de requisitar pecas reservadas de outra OS              ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			IF aPecaOrc[nLocPadReg,PECAORC_RESPEC] == "1" //.and. GetNewPar("MV_RITEORC","N") == "S"
				nQtdReserva := FM_SALDORESV(aPecaOrc[nLocPadReg,6],aPecaOrc[nLocPadReg,7],M->VO2_NUMOSV,aPecaOrc[nLocPadReg,PECAORC_LOTECT], aPecaOrc[nLocPadReg,PECAORC_NUMLOT], aPecaOrc[nLocPadReg,PECAORC_SUGCOM])
				IF nQtd > nQtdReserva
					Alert(STR0108+chr(13)+STR0109+Transform(nQtdReserva,"@E 999,999,999")) // "Nใo ้ possivel requisitar mais pecas do que a quantidade reservada." / Qtd. reservada disponํvel: 
					Return(.f.)
				ENDIF
			ENDIF

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณFNC 29088/2009 - Rubens - 03/12/2009                             ณ
			//ณValida se a qtde solicitaca ้ maior do que a qtde exportada da OSณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DbSelectArea("VOI")
			DbSetOrder(1)
			If VOI->(MsSeek( xFilial("VOI") + cTipTem ))
				If VOI->VOI_BLQORC == "1" .and. nQtd > aPecaOrc[nLocPadReg,9]
					Alert(STR0110) // Qtd. requisitada ้ maior do que a qtd. seleccionada no or็amento.
					Return .f.
				EndIf
			EndIf

		endif

	EndIf

	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek(xFilial("SB2")+SB1->B1_COD+cLocPad)
	If BlqInvent(SB1->B1_COD, SB2->B2_LOCAL)
		ShowHelpDlg ( "OM020BLQINVENT", { STR0235 + chr(13) + chr(10) + chr(13) + chr(10) + AllTrim(RetTitle("VO3_CODITE")) + ": " + AllTrim(SB1->B1_GRUPO + "-" + SB1->B1_CODITE) + chr(13) + chr(10) + AllTrim(RetTitle("VO3_DESITE")) + ": " + AllTrim(SB1->B1_DESC) }) // "O Produto estแ sendo inventariado e nใo poderแ ser Faturado!"
		Return .f.
	Endif

	lValidEst := .t.
	IF FWIsInCallStack("OFIA310") // necessario pegar o estoque da OS somente no momento da digita็ใo da rotina OFIA310.
		IF !FWIsInCallStack("OA3100131_Executa_Dev_e_Req")
			if !empty(oGetOA310:aCols[oGetoA310:nat,FG_POSVAR("VO3_NUMOSV","oGetOA310:aHeader")])
				nDisponivel := oGetOA310:aCols[oGetoA310:nat,FG_POSVAR("VO3_QTDEST","oGetOA310:aHeader")]
			Else
				lValidEst := .f.
			endif
		else // Utiliza o estoque disponivel na valida็ใo da requisi็ใo mesmo chamando do OFIA310
			nDisponivel := FS_SALDOESTQ( SB1->B1_COD , cLocPad )
		endif
	else
		nDisponivel := FS_SALDOESTQ( SB1->B1_COD , cLocPad )
	endif

	nQtdReq := 0

	If Type("aCols") # "U" .and. !Empty(aCols[n,FG_POSVAR("VO3_CODITE")])

		cAuxGrupo  := aCols[n,FG_POSVAR("VO3_GRUITE")]
		cAuxCodigo := aCols[n,FG_POSVAR("VO3_CODITE")]

		For i := 1 to Len(aCols)

			If (aCols[i,Len(aCols[i])]) .or. i == n
				Loop
			EndIf

			If aCols[i,FG_POSVAR("VO3_GRUITE")] == cAuxGrupo .and. aCols[i,FG_POSVAR("VO3_CODITE")] == cAuxCodigo

				lAddQtd := .f.
				// Peca importada da VSJ
				If aCols[i,FG_POSVAR("VO3_IMPORC")] == "1"
					nLocPadReg := FS_POSORC2( .T. , .T. , i )
					If aPecaOrc[ nLocPadReg, PECAORC_LOCPAD ] == cLocPad
						lAddQtd := .t.
					EndIf
				Else
					If cLocPad == OM0200065_ArmazemOrigem( cTipTem )
						lAddQtd := .t.
					EndIf
				EndIf

				If lAddQtd
					nQtdReq := nQtdReq + aCols[i,FG_POSVAR("VO3_QTDREQ")]
				EndIf
			EndIf

		Next

	EndIf

	If lValidEst .and. !lESTNEG // nใo pode trabalhar com Estoque Negativo (MV_ESTNEG == "N")
		If nQtd+nQtdReq > nDisponivel
			If lMensagem
				Help(" ",1,"QTDREQPEC",,AllTrim(RetTitle("VO3_CODITE")) + ": " + cGruIte + "-" + cCodIte ,4,1)
				lMensagem := .f.
			EndIf
			Return(.f.)
		EndIf
	Endif

//ฺฤฤฤฤฤฤฤฤฤฟ
//ณDevolucaoณ
//ภฤฤฤฤฤฤฤฤฤู
Else

	nQuantReq:=nQuantDev:=0
	aFatPar:={}

	DbSelectArea("VO2")
	DbSetOrder(1)
	DbSeek(xFilial("VO2")+M->VO2_NUMOSV)
	Do While !Eof() .And. VO2->VO2_FILIAL == xFilial("VO2") .and. VO2->VO2_NUMOSV == M->VO2_NUMOSV

		DbSelectArea("VO3")
		DbSetOrder(1)
		DbSeek(xFilial("VO3")+VO2->VO2_NOSNUM)
		Do While !Eof() .And. VO3->VO3_FILIAL == xFilial("VO3") .And. VO3->VO3_NOSNUM == VO2->VO2_NOSNUM

			If VO3->VO3_GRUITE+VO3->VO3_CODITE == cGruIte+cCodIte
				If ( Alltrim(VO3->VO3_FATPAR+VO3->VO3_LOJA) == Alltrim(cCodCli) .Or. Alltrim(VO3->VO3_FATPAR)+Alltrim(VO3->VO3_LOJA) == Alltrim(cCodCli) )
					If VO2->VO2_DEVOLU == "1"
						nQuantReq := nQuantReq + VO3->VO3_QTDREQ
					Else
						nQuantDev := nQuantDev + VO3->VO3_QTDREQ
					EndIf
				EndIf
			EndIf

			DbSkip()

		EndDo

		DbSelectArea("VO2")
		DbSkip()

	EndDo

	nVerQtd := 0
	If laCols

		For i:=1 to Len(aCols)
			If aCols[i,FG_POSVAR("VO3_FATPAR")]+aCols[i,FG_POSVAR("VO3_LOJA")]+aCols[i,FG_POSVAR("VO3_GRUITE")]+aCols[i,FG_POSVAR("VO3_CODITE")] == aCols[n,FG_POSVAR("VO3_FATPAR")]+aCols[n,FG_POSVAR("VO3_LOJA")]+aCols[n,FG_POSVAR("VO3_GRUITE")]+aCols[n,FG_POSVAR("VO3_CODITE")] .And. i # n
				nVerQtd := nVerQtd + aCols[i,FG_POSVAR("VO3_QTDREQ")]
			EndIf
		Next

	EndIF

	If lValor
		Return(nQuantReq-nQuantDev)
	EndIf

	If nQtd+nVerQtd > (nQuantReq-nQuantDev)
		If lMensagem
			Help(" ",1,"DEVREQPECA")
		EndIf
		Return(.f.)
	EndIf

EndIf

Return(.t.)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ FS_VALOR   ณ Autor ณ Fabio                 ณ Data ณ 25/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Busca o valor unitario                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Exclusivo                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VALOR(cGruIte,cCodIte)

Local cSelect:=Alias()

If Pcount() == 0

	DbSelectArea("SB1")
	DbSetOrder(7)
	DbSeek(xFilial("SB1")+M->VO3_GRUITE+M->VO3_CODITE)

	aCols[n,FG_POSVAR("VO3_VALPEC")] := M->VO3_VALPEC := FG_VALPEC(M->VO3_TIPTEM,"M->VO3_FORMUL",M->VO3_GRUITE,M->VO3_CODITE,"M->VO3_VALPEC",.f.,.t.)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Edicao manual da aCols ณ
	//ณ Limpar desconto        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	if FG_POSVAR("VO3_VALDES") <> 0 .and. VO3->(FieldPos("VO3_VALDES")) <> 0 .and. ;
		FG_POSVAR("VO3_PERDES") <> 0 .and. VO3->(FieldPos("VO3_PERDES")) <> 0 .and. ;
		VO3->(FieldPos("VO3_VALLIQ")) <> 0
		aCols[n,FG_POSVAR("VO3_VALDES")] := M->VO3_VALDES := 0
		aCols[n,FG_POSVAR("VO3_PERDES")] := M->VO3_PERDES := 0
		aCols[n,FG_POSVAR("VO3_VALLIQ")] := M->VO3_VALLIQ := aCols[n,FG_POSVAR("VO3_VALPEC")]
	endif
	//
Else
	Return(FG_VALPEC(M->VO3_TIPTEM,,cGruIte,cCodIte,,.f.,.t.))
EndIf

DbSelectArea(cSelect)

Return(.t.)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ FS_TOTAL   ณ Autor ณ Fabio                 ณ Data ณ 25/08/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Valor total das Pecas                                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_TOTAL(cCodCli_, cLoja_,lVarMem , lArAvCred)

Local nTotCli := 0 , x := 0
Local nTotPec := 0
Local lCpoDesconto := .f.
Local nAuxValPec := 0
Local nAvalCred := 0
Local nPos := 0

Local nVO3VALLIQ := FG_POSVAR("VO3_VALLIQ")
Local nVO3VALPEC := FG_POSVAR("VO3_VALPEC")
Local nVO3QTDREQ := FG_POSVAR("VO3_QTDREQ")
Local nVO3FATPAR := FG_POSVAR("VO3_FATPAR")
Local nVO3LOJA   := FG_POSVAR("VO3_LOJA")

Default cCodCli_  := ""
Default cLoja_    := ""
Default lVarMem  := .f.
Default lArAvCred := .f.

lCpoDesconto := ( VO3->(FieldPos("VO3_VALLIQ")) <> 0 )

nTotal := 0
For x:=1 to Len(aCols)

	If !( aCols[x,Len(aCols[x])] )

		If lCpoDesconto .and. aCols[x,nVO3VALLIQ] > 0
			nAuxValPec := aCols[x,nVO3VALLIQ]
		Else
			nAuxValPec := aCols[x,nVO3VALPEC]
		EndIf

		If lVarMem .And. x == n
			nTotPec := A410Arred(M->VO3_QTDREQ * nAuxValpec,"C6_VALOR")
		Else
			nTotPec := A410Arred(aCols[x,nVO3QTDREQ] * nAuxValpec,"C6_VALOR")
		EndIf

		// Atualiza total por cliente
		if !Empty(cCodCli_) .and. cCodCli_ == aCols[x,nVO3FATPAR] .and. cLoja_ == aCols[x,nVO3LOJA]
			nTotCli += nTotPec
		endif
		//

		nTotal += nTotPec

	EndIf

Next

If !lOM020Auto
	if cReqDev == "1"
		oTotal:Refresh()
	Endif

	oGetReqPec:oBrowse:SetFocus()
EndIf

If !Empty(cCodCli_)

	If lArAvCred
		nPos := aScan( aAvCred , { |x| x[1] == cCodCli_ .and. x[2] == cLoja_ } )
		If nPos == 0
			AADD( aAvCred , Array(03) )
			nPos := Len(aAvCred)
			aAvCred[nPos,01] := cCodCli_
			aAvCred[nPos,02] := cLoja_
			aAvCred[nPos,03] := FG_AVALCRED( cCodCli_ , cLoja_ )
		EndIf
		nAvalCred := aAvCred[nPos,03]
	Else
		nAvalCred := FG_AVALCRED( cCodCli_ , cLoja_ )
	EndIf

	Return( nTotCli + nAvalCred )

EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ORDBUSCบAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSet saida de dados para a impressora                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_ORDBUSCA(aVO2NOSNUM)

//Executa RdMake da Ordem de Busca
if ExistBlock("ORDBUSCA")
	ExecBlock("ORDBUSCA",.f.,.f.,{aVO2NOSNUM})
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VL     บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEspaco do when insuficiente                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VL()

If cReqDev=="1"

	If !(FS_VALFOR( M->VO3_TIPTEM , M->VO3_GRUITE , M->VO3_CODITE, IIF(lInconveniente,M->VO3_SEQINC,"") )) .Or. !(FG_VALPEC(M->VO3_TIPTEM,,M->VO3_GRUITE,M->VO3_CODITE,,.t.))

		Return( .f. )

	EndIf

EndIf

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TPF    บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEspaco do when insuficiente                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณOficina                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION FS_TPF()
Return(IIf(cReqDev == "1",FG_TIPTPFAT(aCols[n,FG_POSVAR("VO3_TIPTEM")]),.f.))


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ OM020A     ณ Autor ณ Fabio                 ณ Data ณ 29/09/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Lista Pecas Requisitadas na OS e Altera os Itens             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Exclusivo                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM020A(cAlias,nReg,nOpc)

Local   cTitulo := STR0064 + " - " + STR0124 + " " + VO1->VO1_NUMOSV //Itens Requisitados na OS
Local   cCpoInc := ""

Local   aObjects := {}, aSizeAut := {}, aPosObj := {}

Local   aPesqPeca := {}
Local   aPesqSrvc := {}
Local   nPosMov
Local   nCont
Local   nPosPeca
Local   cCampos := "VO3_TIPTEM/VO3_FATPAR/VO3_LOJA/VO3_NOMCLI/VO3_FORMUL/VO3_DEPINT/VO3_DEPGAR/VO3_OPER/"

Local oOficina := DMS_Oficina():New()

Private oOk     := LoadBitmap( GetResources(), "LBOK" )
Private oNo     := LoadBitmap( GetResources(), "LBNO" )
Private aPecas  := {} ,aPecasAlt := {} ,aServicos := {},aTitulo := {}                     //Nome do Vetor em Uso
Private oLbItens,lBxFilho := .f. , oTipTem
Private oOrdens,cOrdens,aOrdens:={(STR0065),(STR0066)} //Tipo de Tempo + Cliente + Grupo do Item + Codigo do Item###Cliente + Tipo de Tempo + Grupo do Item + Codigo do Item
Private lMarcar  := .F.

Private lVSJCODIGO := (VSJ->(FieldPos("VSJ_CODIGO")) <> 0)

Private lVAIALTPRQ  := (VAI->(FieldPos("VAI_ALTPRQ")) <> 0)
Private cAltProdRq  := ""

if lInconveniente
	cCpoInc += "VO3_GRUINC/VO3_CODINC/VO3_DESINC/VO3_SEQINC/"
	cCampos += cCpoInc
endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida se a Ordem de Servico esta aberta.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

if iif(lOm020Ast,ExecBlock("OM020AST",.F.,.F.,{VO1->VO1_STATUS}),VO1->VO1_STATUS) # "A"
	Help("  ",1,"OSNABERTA")

	DbSelectArea("VO1")
	DbSetOrder(1)
	//	Eval(bFiltraBrw)

	Return

EndIf

If lVAIALTPRQ
	VAI->(DbSetOrder(4))
	VAI->(MsSeek(xFilial("VAI")+__cUserID))
	cAltProdRq := VAI->VAI_ALTPRQ
Endif

If cAltProdRq=="1"
	cCampos += "VO3_PROREQ/"
Endif

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VO3")
While !Eof().and.(x3_arquivo=="VO3")
	If X3USO(x3_usado).and.cNivel>=x3_nivel.And.(Alltrim(x3_campo) $ cCampos)
		&("M->"+x3_campo) := CriaVar(x3_campo)
	Endif
	DbSkip()
EndDo

DbSelectArea("VV1")
DbSetOrder(1)
DbSeek(xFilial("VV1")+VO1->VO1_CHAINT)

DbSelectArea("VE1")
DbSetOrder(1)
DbSeek(xFilial("VE1")+VV1->VV1_CODMAR)

aPesqPeca := FMX_CALPEC(VO1->VO1_NUMOSV,,, ,.t.  ,.f.   ,.f.       ,.t.    ,.f.    ,.f.    ,.t.    ,       ,          ,.f.,.f.)
For nCont := 1 to Len(aPesqPeca)

	If aPesqPeca[ nCont, PECA_STATUS ] <> "C" .and. aPesqPeca[ nCont, PECA_QTDREQ ] <> 0

		nPosPeca := Len(aPecas) + 1

		Aadd(aPecas,{;
			.F.,;
			aPesqPeca[ nCont , PECA_TIPTEM ] ,;			// 02
			aPesqPeca[ nCont , PECA_CLIENTE ],;			// 03
			aPesqPeca[ nCont , PECA_LOJA ]   ,;			// 04
			aPesqPeca[ nCont , PECA_GRUITE ] ,;			// 05
			aPesqPeca[ nCont , PECA_CODITE ] ,;			// 06
			aPesqPeca[ nCont , PECA_DESCRICAO ] ,;		// 07
			aPesqPeca[ nCont , PECA_DEPINT ] ,;			// 08
			aPesqPeca[ nCont , PECA_DEPGAR ] ,;			// 09
			aPesqPeca[ nCont , PECA_QTDREQ ] ,;			// 10
			aPesqPeca[ nCont , PECA_INCONV_GRUPO  ],;	// 11 - Grupo de Inconveniente
			aPesqPeca[ nCont , PECA_INCONV_CODIGO ],;	// 12 - Codigo do Inconveniente
			aPesqPeca[ nCont , PECA_INCONV_SEQ    ],;	// 13 - Seq do Inconveniente
			aPesqPeca[ nCont , PECA_INCONV_DESCR  ],;	// 14 - Descricao do Inconveniente
			aPesqPeca[ nCont , PECA_TES] ,;				// 15 - TES
			aPesqPeca[ nCont , PECA_FORMULA] ,;			// 16 - Formula
			nPosPeca,; 									// 17 - Sequencia para relacionamento com a aPecasAlt
			IIf( lCtrlLote , aPesqPeca[ nCont , PECA_LOTECT] , "" ) ,;			// 18 - Lote
			IIf( lCtrlLote , aPesqPeca[ nCont , PECA_NUMLOT] , "" ) })			// 19 - Sub-Lote

			For nPosMov := 1 to Len(aPesqPeca[nCont, PECA_MOV ])
				AADD(aPecasAlt,{;
					.F.,;
					aPesqPeca[ nCont , PECA_MOV , nPosMov , PECA_MOV_NOSNUM ] ,;	// 02
					aPesqPeca[ nCont , PECA_MOV , nPosMov , PECA_MOV_REQDEV ] ,;	// 03
					aPesqPeca[ nCont , PECA_TIPTEM],; 										// 04
					aPesqPeca[ nCont , PECA_CLIENTE],;										// 05
					aPesqPeca[ nCont , PECA_LOJA],;											// 06
					aPesqPeca[ nCont , PECA_GRUITE],;										// 07
					aPesqPeca[ nCont , PECA_CODITE],;										// 08
					aPesqPeca[ nCont , PECA_VALBRU],;										// 09
					aPesqPeca[ nCont , PECA_INCONV_GRUPO  ],;								// 10 - Grupo do Inconveniente
					aPesqPeca[ nCont , PECA_INCONV_CODIGO ],;								// 11 - Codigo do Inconveniente
					aPesqPeca[ nCont , PECA_INCONV_SEQ    ],;								// 12 - Seq do Inconveniente
					aPesqPeca[ nCont , PECA_INCONV_DESCR  ],;								// 13 - Descricao do Inconveniente
					aPesqPeca[ nCont , PECA_MOV , nPosMov, PECA_MOV_RECVO3] ,; 		// 14 - Recno para Reposicionar no Arquivo
					aPesqPeca[ nCont , PECA_TES ] ,;											// 15 - TES
					aPesqPeca[ nCont , PECA_FORMULA ] ,;									// 16 - Formula
					aPesqPeca[ nCont , PECA_STATUS ] ,;										// 17 - Status do Tipo de Tempo
					nPosPeca })																		// 18 - Posicao da Matriz aPecas (Utilizado para Relacionamento)
			Next nPosMov

		EndIf

Next nCont

aPesqSrvc := FMX_CALSER(VO1->VO1_NUMOSV, , , , .t., .f., .t., .f., .f., .f., , )
For nCont := 1 to Len(aPesqSrvc)
	For nPosMov := 1 to Len(aPesqSrvc[nCont, SRVC_APONT])

		Aadd(aServicos,{;
			.F.,;
			aPesqSrvc[ nCont , SRVC_APONT , nPosMov , SRVC_APONT_NOSNUM ],;	// 02
			aPesqSrvc[ nCont , SRVC_APONT , nPosMov , SRVC_APONT_SEQUEN ],;	// 03
			aPesqSrvc[ nCont , SRVC_TIPTEM ] ,;	// 04
			aPesqSrvc[ nCont , SRVC_CLIENTE ] ,;	// 05
			aPesqSrvc[ nCont , SRVC_LOJA ] ,;		// 06
			aPesqSrvc[ nCont , SRVC_CODSER ] ,;	// 07
			aPesqSrvc[ nCont , SRVC_VALBRU ] ,;	// 08
			aPesqSrvc[ nCont , SRVC_INCONV_GRUPO ] ,;				// 09 - Grupo do inconveniente
			aPesqSrvc[ nCont , SRVC_INCONV_CODIGO ] ,;			// 10 - Codigo do inconveniente
			aPesqSrvc[ nCont , SRVC_TIPSER] ,;	// 11
			aPesqSrvc[ nCont , SRVC_INCONV_SEQ ] ,;				// 12 - Seq do Inconveniente
			aPesqSrvc[ nCont , SRVC_INCONV_DESCR ] ,;				// 13 - Descricao do Inconveniente
			aPesqSrvc[ nCont , SRVC_APONT , nPosMov , SRVC_APONT_RECVO4 ] }) 	// 14 - Recno para Reposicionar no Arquivo

	Next nPosMov
Next nCont

If Len(aPecas) == 0
	Help(" ",1,"ITENSOSV")
	Return
EndIf

Asort(aPecas,1,,{|x,y|x[2]+x[3]+x[4]+x[5]+x[6]+x[14] < y[2]+y[3]+y[4]+y[5]+y[6]+y[14]})

VOI->( DbSetOrder(1) )

aSizeAut := MsAdvSize(.t.)
AADD( aObjects, { 0 , 110 , .T. , .F. } ) // Scroll
AADD( aObjects, { 0 , 100 , .T. , .T. } ) // ListBox
AADD( aObjects, { 0 , 028 , .T. , .F. } ) // Combo com Sort
aInfo := { aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4], 0 , 2 }
aPosObj := MsObjSize( aInfo, aObjects )

cDescriDI := ""//Descricao do Depto Interno
cDescriDG := ""//Descricao do Depto Garantia

DEFINE MSDIALOG oDlgPecas TITLE cTitulo From aSizeAut[7],00 TO aSizeAut[6], aSizeAut[5] of oMainWnd PIXEL

o020Scroll := TScrollBox():New( oDlgPecas , aPosObj[1,1] , aPosObj[1,2] , aPosObj[1,3] - aPosObj[1,1], aPosObj[1,4] - aPosObj[1,2], .t. , , .t. )

// Tipo Tempo
@ 05,002 SAY STR0067 OF o020Scroll PIXEL COLOR CLR_HBLUE
@ 04,040 MSGET oTipTem VAR M->VO3_TIPTEM PICTURE "@!" F3 "VOI" ;
	VALID ( ;
		!oOficina:TipoTempoBloqueado(M->VO3_TIPTEM,.t.) .And. ;
		FG_TIPTPFAT(,"M->VO3_FATPAR","M->VO3_LOJA","M->VO3_NOMCLI",VO1->VO1_CODMAR,,,,,, (cMVMIL0006 <> "SCA") ) .And. ;
		FS_020INTGAR(VO1->VO1_NUMOSV,M->VO3_TIPTEM) .And. ;
		FS_VALTPABE(VO1->VO1_CHASSI,M->VO3_TIPTEM,VO1->VO1_NUMOSV) .And. ;
		FS_ALTTPREQ() .And. ;
		Iif(lVOITPATEN, FGX_VOITPATEN(VO1->VO1_TPATEN, M->VO3_TIPTEM, .t.), .t.) .And. ;
		( M->VO3_OPER := VOI->VOI_CODOPE , FS_FORMUL( M->VO3_OPER , M->VO3_TIPTEM , .f. ) ) ) ;
	SIZE 10,1 OF o020Scroll PIXEL COLOR CLR_BLACK HASBUTTON

// Descricao de Tipo de Tempo
@ 05,160 SAY RetTitle("VOI_DESTTE") OF o020Scroll PIXEL
@ 04,200 MSGET VOI->VOI_DESTTE PICTURE "@!S15" SIZE 80,1 OF o020Scroll PIXEL when .f.

// Codigo do Cliente
@ 16,002 SAY RetTitle("VO3_FATPAR") OF o020Scroll PIXEL COLOR CLR_HBLUE
@ 15,040 MSGET M->VO3_FATPAR PICTURE "@!" F3 "VSA" SIZE 40,1 VALID FG_SEEK("SA1","M->VO3_FATPAR",1) OF o020Scroll PIXEL COLOR CLR_BLACK When IIf(Posicione("VOI",1,xFilial("VOI")+M->VO3_TIPTEM,"VOI_ALTCLI") == "0",.f.,.t.) HASBUTTON

// Loja
@ 16,160 SAY RetTitle("VO3_LOJA") OF o020Scroll PIXEL COLOR CLR_HBLUE
@ 15,200 MSGET M->VO3_LOJA PICTURE "@!" VALID FS_NOMCLI() SIZE 10,1 OF o020Scroll PIXEL COLOR CLR_BLACK when IIf(Posicione("VOI",1,xFilial("VOI")+M->VO3_TIPTEM,"VOI_ALTCLI") == "0",.f.,.t.)

// Nome do cliente
@ 27,002 SAY RetTitle("VO3_NOMCLI") OF o020Scroll PIXEL
@ 26,040 MSGET M->VO3_NOMCLI SIZE 240,1 OF o020Scroll PIXEL When .f.

//Operacao
if VO3->(FieldPos("VO3_OPER"))>0
	@ 38,002 SAY RetTitle("VO3_OPER") OF o020Scroll PIXEL
	@ 37,040 MSGET M->VO3_OPER PICTURE "@!" F3 "DJ" VALID ( ( Vazio() .or. SX5->(DbSeek(xFilial("SX5")+"DJ"+M->VO3_OPER)) ) .and. FS_FORMUL( M->VO3_OPER , M->VO3_TIPTEM , .f. ) ) OF o020Scroll PIXEL COLOR CLR_BLACK SIZE 10,1 HASBUTTON
endif

//Formula
@ 49,002 SAY STR0035 OF o020Scroll PIXEL COLOR CLR_HBLUE
@ 48,040 MSGET M->VO3_FORMUL ;
	PICTURE "@!" ;
	F3 "VEG" ;
	VALID Iif (OFP8600016, OFP8600016_VerificacaoFormula(M->VO3_FORMUL), VEG->(DbSeek(xFilial("VEG")+M->VO3_FORMUL))) ;
	SIZE 10,1 ;
	OF o020Scroll ;
	PIXEL ;
	COLOR CLR_BLACK ;
	when FG_VALPEC(M->VO3_TIPTEM,"M->VO3_FORMUL",aPecas[oLbItens:nAt,5],aPecas[oLbItens:nAt,6],,.t.) ;
	HASBUTTON
// Descricao da Formula
@ 49,160 SAY RetTitle("VEG_DESCRI") OF o020Scroll PIXEL
@ 48,200 MSGET IIf(!Empty(M->VO3_FORMUL),VEG->VEG_DESCRI,"") PICTURE "@!S15" SIZE 80,1 OF o020Scroll PIXEL When .f.

//Dep Interno
@ 60,002 SAY STR0068 OF o020Scroll PIXEL
@ 59,040 MSGET M->VO3_DEPINT PICTURE "@!" F3 "VD" VALID (SX5->(DbSeek(xFilial("SX5")+"VD"+M->VO3_DEPINT)) .and. (cDescriDI := SX5->X5_DESCRI)) OF o020Scroll PIXEL COLOR CLR_BLACK SIZE 10,1 When VOI->VOI_DEPINT == "1" HASBUTTON
// Descricao do Departamento Interno
@ 60,160 SAY STR0012 OF o020Scroll PIXEL
@ 59,200 MSGET IIf(!Empty(M->VO3_DEPINT),cDescriDI,"") PICTURE "@!S15" SIZE 80,1 OF o020Scroll PIXEL SIZE 90,1 When .f.

//Dep Garantia
@ 71,002 SAY STR0069 OF o020Scroll PIXEL
@ 70,040 MSGET M->VO3_DEPGAR PICTURE "@!" F3 "VF" VALID (SX5->(DbSeek(xFilial("SX5")+"VF"+M->VO3_DEPGAR)) .and. (cDescriDG := SX5->X5_DESCRI)) OF o020Scroll PIXEL COLOR CLR_BLACK SIZE 10,1 When VOI->VOI_DEPGAR == "1" HASBUTTON
// Descricao do Departamento de Garantia
@ 71,160 SAY STR0012 OF o020Scroll PIXEL
@ 70,200 MSGET IIf(!Empty(M->VO3_DEPGAR),cDescriDG,"") PICTURE "@!S15" OF o020Scroll PIXEL SIZE 80,1 When .f.

// Produtivo Requisitante
If cAltProdRq=="1"
	@ 80,002 SAY RetTitle("VO3_PROREQ") OF o020Scroll PIXEL
	@ 79,040 MSGET M->VO3_PROREQ PICTURE "@!" F3 "V1A" VALID FG_StrZero("M->VO3_PROREQ",6) .AND.FG_Seek("VAI","M->VO3_PROREQ") .AND. IF(VAI->VAI_PROFIL<>"1",VAI->VAI_FILPRO==FWCodFil(),.T.) OF o020Scroll PIXEL COLOR CLR_BLACK SIZE 10,1 HASBUTTON
Endif


TGroup():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],STR0070,oDlgPecas,,,.t.)

oLbItens := TWBrowse():New(aPosObj[2,1] + 10,aPosObj[2,2] + 4,aPosObj[2,4] - aPosObj[2,2] - 8,aPosObj[2,3] - aPosObj[2,1] - 15,,,,oDlgPecas,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbItens:addColumn(TCColumn():New( " " , { || IIf(oLbItens:aArray[oLbItens:nAt,1],oOk,oNo) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) )
If lInconveniente
	oLbItens:addColumn(TCColumn():New( RetTitle("VO3_GRUINC") , { || oLbItens:aArray[oLbItens:nAt,11] } ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) // Grupo do Inconveniente
	oLbItens:addColumn(TCColumn():New( RetTitle("VO3_CODINC") , { || oLbItens:aArray[oLbItens:nAt,12] } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // Codigo do Inconveniente
	oLbItens:addColumn(TCColumn():New( RetTitle("VO3_SEQINC") , { || oLbItens:aArray[oLbItens:nAt,13] } ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) // Seq do Inconveniente
	oLbItens:addColumn(TCColumn():New( RetTitle("VO3_DESINC") , { || oLbItens:aArray[oLbItens:nAt,14] } ,,,,"LEFT" ,70,.F.,.F.,,,,.F.,) ) // Descricao do Inconveniente
EndIf
oLbItens:addColumn(TCColumn():New( RetTitle("VO3_TIPTEM") , { || oLbItens:aArray[oLbItens:nAt,02] } ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) // Tipo de Tempo
oLbItens:addColumn(TCColumn():New( STR0072                , { || oLbItens:aArray[oLbItens:nAt,03] } ,,,,"LEFT" ,35,.F.,.F.,,,,.F.,) ) // Cod Cliente
oLbItens:addColumn(TCColumn():New( STR0031                , { || oLbItens:aArray[oLbItens:nAt,04] } ,,,,"LEFT" ,15,.F.,.F.,,,,.F.,) ) // Loja
oLbItens:addColumn(TCColumn():New( STR0010                , { || oLbItens:aArray[oLbItens:nAt,05] } ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) // Grupo
oLbItens:addColumn(TCColumn():New( STR0011                , { || oLbItens:aArray[oLbItens:nAt,06] } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // Cod Item
oLbItens:addColumn(TCColumn():New( STR0012                , { || oLbItens:aArray[oLbItens:nAt,07] } ,,,,"LEFT" ,70,.F.,.F.,,,,.F.,) ) // Descricao
If lCtrlLote
	oLbItens:addColumn(TCColumn():New( RetTitle("VO3_LOTECT") , { || oLbItens:aArray[oLbItens:nAt,18] } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // Lote
	oLbItens:addColumn(TCColumn():New( RetTitle("VO3_NUMLOT") , { || oLbItens:aArray[oLbItens:nAt,19] } ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) // Sub-Lote
EndIf
oLbItens:addColumn(TCColumn():New( RetTitle("VO3_CODTES") , { || oLbItens:aArray[oLbItens:nAt,15] } ,,,,"LEFT" ,10,.F.,.F.,,,,.F.,) ) // TES
oLbItens:addColumn(TCColumn():New( RetTitle("VO3_FORMUL") , { || oLbItens:aArray[oLbItens:nAt,16] } ,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) // Formula
oLbItens:addColumn(TCColumn():New( STR0068                , { || oLbItens:aArray[oLbItens:nAt,08] } ,,,,"LEFT" ,15,.F.,.F.,,,,.F.,) ) // Dep Interno
oLbItens:addColumn(TCColumn():New( STR0069                , { || oLbItens:aArray[oLbItens:nAt,09] } ,,,,"LEFT" ,15,.F.,.F.,,,,.F.,) ) // Dep Garantia
oLbItens:addColumn(TCColumn():New( STR0034                , { || oLbItens:aArray[oLbItens:nAt,10] } ,,,,"RIGHT",20,.F.,.F.,,,,.F.,) ) // Quantidade
oLbItens:nAt := 1
oLbItens:SetArray(aPecas)
oLbItens:bHeaderClick := {|oObj,nCol| IIf( nCol == 1 , ( lMarcar := !lMarcar , FS_SELECIONA(lMarcar) , oLbItens:Refresh() ) , .t. ) , }
oLbItens:bLDblClick := { || IIf( oLbItens:aArray[oLbItens:nAt,1] , ;
											oLbItens:aArray[oLbItens:nAt,1] := .F. , ;
											oLbItens:aArray[oLbItens:nAt,1] := FS_TPLIBFEC(VO1->VO1_NUMOSV ,oLbItens:aArray[oLbItens:nAt,2] )) }
oLbItens:Refresh()

TGroup():New(aPosObj[3,1],aPosObj[3,2],aPosObj[3,3],aPosObj[3,4],STR0073,oDlgPecas,,,.t.)
@ aPosObj[3,1] + 10 , aPosObj[3,2] + 4 MSCOMBOBOX oOrdens VAR cOrdens ITEMS aOrdens ;
	SIZE aPosObj[3,4] - aPosObj[3,2] - 8 , aPosObj[3,3] - aPosObj[3,1] - 15 ;
	OF oDlgPecas PIXEL;
	ON CHANGE (If(cOrdens == STR0065,Asort(aPecas,1,,{|x,y|x[2]+x[3]+x[4]+x[5]+x[6] < y[2]+y[3]+y[4]+y[5]+y[6]}),Asort(aPecas,1,,{|x,y|x[3]+x[4]+x[2]+x[5]+x[6] < y[3]+y[4]+y[2]+y[5]+y[6]})),oLbItens:SetFocus()) //Tipo de Tempo + Cliente + Grupo do Item + Codigo do Item*/

ACTIVATE MSDIALOG oDlgPecas ON INIT EnchoiceBar(oDlgPecas,{|| nOpca := 1,FS_ALTREQ()},{|| nOpca := 0,(oDlgPecas:End())})

DbSelectArea("VO1")
DbSetOrder(1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ALTREQ บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAltera Requisicao de pecas e Srv                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_ALTREQ()

Local nValor := 0 ,lTPGRU := .t. , i := 0 , iP := 0 , iPA := 0 , iS := 0
Local lRet := .t. , nPosPeca := 0
Local aItensNew:={}

Local lIgual // Controla se a Linha de aPecas for igual a aPecasAlt
Local lCpoDesconto := (VO3->(FieldPos("VO3_VALDES")) <> 0 .and. VO3->(FieldPos("VO3_PERDES")) <> 0 .and. VO3->(FieldPos("VO3_VALLIQ")) <> 0)
Local lAltCli := .f.
Local cAliasVFB := "SQLVFB"

Local aPecBKP    := aClone( aPecas )		// Backup da Array aPecas
Local aPecAltBKP := aClone( aPecasAlt )		// Backup da Array aPecasAlt

Local lAltDpI := .f.
Local lAltDpG := .f.

Local aLockVO3 := {}
Local aLockVO4 := {}

Local oOficina := DMS_Oficina():New()

Local lSEMAF261  := (GetNewPar("MV_MIL0130","0")=="1") // Utiliza semแforo na Movimenta็ใo de Pecas da rotina Requisi็ใo de Pecas (0-Nao, 1-Sim)                                                                

Local lMItemRem
Local aIteRem := {}

Local oEst     := DMS_Estoque():New()
Local aItemMov := {}

///////////////////////////////////////////////////

if oCLiente:Bloqueado(M->VO3_FATPAR, M->VO3_LOJA, .T.)
	Return(.f.)
EndIf

If !FMX_TTVLDCLIENTE( VO1->VO1_NUMOSV, M->VO3_TIPTEM , M->VO3_FATPAR , M->VO3_LOJA )
	Return .f.
EndIf

If !FG_FATSP(M->VO3_TIPTEM,M->VO3_FATPAR+M->VO3_LOJA,"M->VO3_NOMCLI","A1_NOME")
	If !MsgYesNo(STR0074+" "+M->VO3_TIPTEM,STR0075)  //Sera Alterado todos os clientes do tipo de tempo###Atencao!!!
		Return(.f.)
	Else
		lAltCli := .t.
	EndIf
EndIf

If oOficina:TipoTempoBloqueado(M->VO3_TIPTEM,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
	Return(.f.)
EndIf
If VOI->VOI_DEPINT == "1" // Tipo de Tempo Interno
	If Empty(M->VO3_DEPINT)
		MsgStop(STR0121+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0075) // Departamento nใo informado! / Dep Interno / Atencao
		Return(.f.)
	EndIf
	lAltDpI := .t.
ElseIf VOI->VOI_DEPGAR == "1" // Tipo de Tempo Garantia
	If Empty(M->VO3_DEPGAR)
		MsgStop(STR0121+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0069,STR0075) // Departamento nใo informado! / Dep Garantia / Atencao
		Return(.f.)
	EndIf
	lAltDpG := .t.
EndIf

aEval(aPecasAlt,{ |x| x[1] := .f. })

For i:=1 to Len(aPecas)
	For iPA:=1 to Len(aPecasAlt)
		If aPecasAlt[iPA,18] == aPecas[i,17]
			If aPecas[i,1]
				If aPecasAlt[iPA,3] == "0"
					nValor := nValor - aPecasAlt[iPA,9]
				Else
					nValor := nValor + aPecasAlt[iPA,9]
				EndIf
			EndIf

			aPecasAlt[iPA,1] := aPecas[i,1]
		EndIf
	Next
	If aPecas[i,1]
		// Servicos
		If Len(aServicos)#0 .And. aScan(aServicos,{|x| x[4] == aPecas[i,2]}) # 0
			For iS:=1 to Len(aServicos)
				// Mesmo Tipo de Tempo
				If aServicos[iS,4] == aPecas[i,2]
					lIgual := .f.

					// Se utiliza inconveniente, a Sequencia deve ser a mesma
					if lInconveniente
						if aServicos[iS,12] == aPecas[i,13]
							lIgual := .t.
						endif
					else
						lIgual := .t.
					endif
					//

					if lIgual
						aServicos[iS,1] := aPecas[i,1]
					endif

					nValor := nValor + aServicos[iS,8]
				EndIf
			Next
		EndIf
	EndIf
Next

// Alterar
lMsHelpAuto := .F.
//Validacao por Ponto de Entrada
If ExistBlock("OM020ALT") // Valida antes da Requisicao
	lRet := ExecBlock("OM020ALT",.f.,.f.)
	If !lRet
		Return (.f.)
	Endif
Endif

If !lAltCli
	nValor := 0
Endif

//Validacao por Ponto de Entrada
lVerTpgCC := .t.
If PEVERTPGCC // Verifica tipo de Pagamento para Checagem de Credito
	lVerTpgCC := ExecBlock("VERTPGCC",.f.,.f.,{"OFIOM020"})
Endif

If lVerTpgCC

	If "P" $ cMVCHKCRE .And. !(VOI->VOI_SITTPO $ "2/3/4")

		If !FGX_AVALCRED(M->VO3_FATPAR,M->VO3_LOJA,nValor,.t.)
			Help("  ",1,"LIMITECRED")
			lRet := .f.
			Return(.t.)
		EndIf

	EndIf

Endif

lMsHelpAuto := .t.
lMsErroAuto := .f.

Begin Transaction

// Bloqueia todos os registros da VO3 e VO4 para verificar se pode continuar a liberacao...
For iP := 1 to Len(aPecasAlt)
	If aPecasAlt[iP, 1]
		AADD( aLockVO3 , aPecasAlt[ iP , 07 ] + aPecasAlt[ iP , 08 ] + aPecasAlt[ iP , 02 ] + aPecasAlt[ iP , 04 ] + aPecasAlt[ iP , 12 ] )
	EndIf
Next iP
For iP := 1 to Len(aServicos)
	If aServicos[iP,4] == M->VO3_TIPTEM
		AADD( aLockVO4 , aServicos[ iP , 02 ] + aServicos[ iP , 03 ] )
	EndIf
Next iP
If !MultLock("VO3",aLockVO3,2) .and. !MultLock("VO4",aLockVO4,8)
	MsUnlockAll()
	DisarmTransaction()
	Return .f.
EndIf
//

// Verifica se a situacao do TT permite requisicao
If lCANUSETT
	For iP := 1 to Len(aPecasAlt)
		If aPecasAlt[iP,1] .and. !FMX_CANUSETT( "2" , VO1->VO1_NUMOSV , aPecasAlt[iP,04] , .f. , .t. , , aPecasAlt[iP,14] , 0 )
			MsUnlockAll()
			DisarmTransaction()
			Return .f.
		EndIf
	Next iP
EndIf
//


// Altera Peca
For iP:=1 to Len(aPecasAlt)

	If !aPecasAlt[iP,1]
		Loop
	EndIf

	DbSelectArea("VO3")
	DbSetOrder(2)

	If !FG_GRUTEM( M->VO3_TIPTEM , aPecasAlt[iP,7] )
		lTPGRU := .f.
		lRet := .f.
		Loop
	EndIF

	VO3->(dbGoTo(aPecasAlt[iP,14]))

	if OM0200105_ItemEmRemessa(VO3->VO3_NUMOSV, VO3->VO3_TIPTEM, VO3->VO3_GRUITE, VO3->VO3_CODITE)

		If Len(aIteRem) == 0 .and. lMItemRem == NIL
			lMItemRem := MsgNoYes(STR0288)
		EndIf

		If lMItemRem
			dbSelectArea("SB1")
			dbSetOrder(7)
			dbSeek(xFilial("SB1")+VO3->VO3_GRUITE+VO3->VO3_CODITE)
			
			aAdd(aIteRem,{VO3->VO3_TIPTEM, VO3->VO3_GRUITE, VO3->VO3_CODITE,SB1->B1_DESC})
		EndIf

		Loop
	EndIf

	If !Empty(VO3->VO3_DATDIS)
		MsgStop(STR0183,STR0075) // "Registro jแ liberado."
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf

	If !RecLock("VO3",.F.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf

	VO3->VO3_TIPTEM := M->VO3_TIPTEM
	VO3->VO3_FATPAR := M->VO3_FATPAR
	VO3->VO3_LOJA   := M->VO3_LOJA
	If !Empty( M->VO3_DEPINT )
		VO3->VO3_DEPINT := M->VO3_DEPINT
		VO3->VO3_DEPGAR := ""
	Else
		VO3->VO3_DEPINT := ""
	EndIf
	If !Empty( M->VO3_DEPGAR )
		VO3->VO3_DEPGAR := M->VO3_DEPGAR
		VO3->VO3_DEPINT := ""
	Else
		VO3->VO3_DEPGAR := ""
	EndIf

	M->VO3_CODTES := VO3->VO3_CODTES // Salva a TES Atual
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+VO3->VO3_GRUITE+VO3->VO3_CODITE)
	If VO3->(FieldPos("VO3_OPER"))>0 .and. !Empty(M->VO3_OPER)
		M->VO3_CODTES := MaTesInt(2,M->VO3_OPER,M->VO3_FATPAR,M->VO3_LOJA,"C",SB1->B1_COD)
		If Empty(M->VO3_CODTES)
			M->VO3_CODTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
		Endif
		SF4->(dbSetOrder(1))
		If !SF4->(MsSeek(xFilial("SF4") + M->VO3_CODTES))
			Help(" ",1,"REGNOIS",,AllTrim(RetTitle("VO3_CODTES")) + ": " + M->VO3_CODTES ,4,1)
			lRet := .f.
			MsUnLock()	// VO3
			DisarmTransaction()
			Break
		EndIf
		If Empty(M->VO3_CODTES)
			MsgStop(STR0119 + chr(13) + chr(10) + chr(13) + chr(10) + ;	// "TES inteligente nใo retornou um TES vแlido."
			AllTrim(RetTitle("VO3_CODITE")) + ": " + VO3->VO3_GRUITE + "-" + VO3->VO3_CODITE,STR0075) // Aten็ใo
			lRet := .f.
			MsUnLock()	// VO3
			DisarmTransaction()
			Break
		EndIf
	EndIf

	dbSelectArea("SF4")
	dbSetOrder(1)
	MsSeek(xFilial("SF4")+VO3->VO3_CODTES)
	cMovTesAnt := SF4->F4_ESTOQUE

	MsSeek(xFilial("SF4")+M->VO3_CODTES)
	cMovTesAtu := SF4->F4_ESTOQUE

	If cMovTesAtu <> cMovTesAnt
		MsgStop(STR0116 +" = '"+ cMovTesAnt +"' ( "+VO3->VO3_CODTES+" )"+CHR(13)+CHR(10)+; // "A Movimenta็ใo anterior foi com TES Movimenta Estoque"
				STR0117 +" = '"+ cMovTesAtu +"' ( "+  M->VO3_CODTES+" )"+CHR(13)+CHR(10)+; // "A Movimenta็ใo atual estแ com TES Movimenta Estoque"
				STR0118 ,STR0075) // "A Opera็ใo serแ cancelada!" / Aten็ใo
		lRet := .f.
		MsUnLock()	// VO3
		DisarmTransaction()
		Break
	Endif

	VO3->VO3_CODTES := M->VO3_CODTES
	If VO3->(FieldPos("VO3_OPER")) > 0 .and. !Empty(M->VO3_OPER)
		VO3->VO3_OPER := M->VO3_OPER
	Endif
	
	If lVAIALTPRQ .and. cAltProdRq == "1" .and. !Empty(M->VO3_PROREQ)
		VO3->VO3_PROREQ := M->VO3_PROREQ
	Endif

	MsUnLock()

	FG_Seek("VOI","M->VO3_TIPTEM",1)

	/* SO ALTERA O PRECO DE ACORDO COM O CONFIGURADO NO TIPO DE TEMPO, SE FOR "1" O SISTEMA NAO PODE ALTERAR */

	cQuery := "SELECT VFB.R_E_C_N_O_ AS RECVFB "
	cQuery += "FROM "
	cQuery += RetSqlName( "VFB" ) + " VFB "
	cQuery += "WHERE "
	cQuery += "VFB.VFB_FILIAL='"+ xFilial("VFB")+ "' AND VFB.VFB_CODCLI = '"+VO1->VO1_PROVEI+"' AND VFB.VFB_LOJA = '"+VO1->VO1_LOJPRO+"' AND "
	cQuery += "VFB.VFB_CHAINT = '"+VO1->VO1_CHAINT+"' AND VFB.VFB_NUMOSV = '"+VO1->VO1_NUMOSV+"' AND VFB.VFB_SERPEC = 'P' AND "
	cQuery += "VFB.VFB_TIPTEM = '"+aPecasAlt[iP,4]+"' AND "
	cQuery += "VFB.D_E_L_E_T_=' '"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVFB, .T., .T. )

	Do While !( cAliasVFB )->( Eof() )

		dbSelectArea("VFB")
		VFB->(dbGoTo(( cAliasVFB )->RECVFB))
		If !RecLock("VFB",.F.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		VFB->VFB_CODCLI := VO1->VO1_PROVEI
		VFB->VFB_LOJA   := VO1->VO1_LOJPRO
		VFB->VFB_TIPTEM := M->VO3_TIPTEM
		MsUnlock()

		( cAliasVFB )->(DbSkip())

	EndDo
	( cAliasVFB )->(dbCloseArea())

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Movimenta Estoque ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nPosPeca := aScan(aPecas,{ |x| x[17] == aPecasAlt[iP,18] })
	If aPecasAlt[iP,4] # M->VO3_TIPTEM ;
		.and. aPecasAlt[iP,3] <> "0" ; // Requisi็ใo
		.And. (nPosPeca#0 .And. aPecas[nPosPeca,1] .And. !Empty(aPecas[nPosPeca,10]) )

		dbSelectArea("SF4")
		dbSetOrder(1)
		MsSeek(xFilial("SF4")+M->VO3_CODTES)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMovimentacao interna do Item                                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		if SF4->F4_ESTOQUE == "S"
			aItensNew:={}

			DbSelectArea("SB1")
			DbSetOrder(7)
			DbSeek( xFilial("SB1") + VO3->VO3_GRUITE + VO3->VO3_CODITE )
			DbSetOrder(1)

			_cAlmOrig := Posicione("VOI",1,xFilial("VOI")+aPecasAlt[iP,4],"VOI_CODALM")
			_cAlmDest := Posicione("VOI",1,xFilial("VOI")+VO3->VO3_TIPTEM,"VOI_CODALM")

			If _cAlmOrig # _cAlmDest

				If lSEMAF261 // Utiliza semแforo na Movimenta็ใo de Pecas da rotina Requisi็ใo de Pecas
					If !LockByName("OFIOM020"+VO1->VO1_NUMOSV+"MOVPEC",.t.,.t.)
						Help(" ",1,"ROTINA_EM_USO",,STR0285,4,1 )		 // "Impossivel continuar! Semแforo estแ sendo utilizado para trazer o N๚mero do Documento da Movimenta็ใo de Pe็as (MATA261)"
						Return .f.
					Endif
				Endif

				dbSelectArea("VO3")
				RecLock("VO3",.f.)
				VO3->VO3_NUMDOC := FS_D3NUMDOC()
				MsUnLock()

				//
				// Adiciona cabecalho com numero do documento e data da transferencia modelo II
				//
				aadd (aItensNew,{ VO3->VO3_NUMDOC , ddatabase})

				nQtdTrans := aPecas[nPosPeca,10]

				cLocOri := Posicione("VOI",1,xFilial("VOI")+aPecasAlt[iP,4],"VOI_LOCALI")
				cLocDes := Posicione("VOI",1,xFilial("VOI")+VO3->VO3_TIPTEM,"VOI_LOCALI")

				aItemMov := oEst:SetItemSD3(SB1->B1_COD     ,; //C๓digo do Produto
											_cAlmOrig       ,; // Armaz้m de Origem
											_cAlmDest        ,; // Armaz้m de Destino
											cLocOri         ,; // Localiza็ใo Origem
											cLocDes         ,; // Localiza็ใo Destino
											nQtdTrans       ,; // Qtd a transferir
											VO3->VO3_LOTECT ,; // Nro de lote
											VO3->VO3_NUMLOT ,; // Nro de Sub-Lote
											VO3->VO3_NUMSER )  // Nro de S้rie

				aAdd(aItensNew, aClone(aItemMov))

				If Localiza(SB1->B1_COD)

					If Empty( Posicione("VOI",1,xFilial("VOI")+aPecasAlt[iP,4],"VOI_LOCALI") ) ;
						.Or. Empty( Posicione("VOI",1,xFilial("VOI")+VO3->VO3_TIPTEM,"VOI_LOCALI") )

						// Cancela Gravacao
						Help(" ",1,"SALDOLOCLZ")
						lRet := .f.
						DisarmTransaction()
						Break

					EndIf

					//Executa RdMake da Ordem de Busca
					if ExistBlock("RDLOCALIZ")
						ExecBlock("RDLOCALIZ",.f.,.f.,{@aItensNew})
					Endif
				Else
					// Ponto de Entrada para alterar informa็๕es das pe็as que serใo transferidas
					// de estoque e que nใo tem a localiza็ใo da pe็a informada
					If (ExistBlock("OM020APEC"))
						aItensNew := ExecBlock("OM020APEC", .f., .f., {aItensNew})
					EndIf
				EndIf

				MSExecAuto({|x| MATA261(x)},aItensNew)

				If lSEMAF261 // Destrava semแforo na Movimenta็ใo de Pecas da rotina Requisi็ใo de Pecas
					UnLockByName("OFIOM020"+VO1->VO1_NUMOSV+"MOVPEC",.t.,.t.)
				Endif

				If lMsErroAuto
					// Cancela Gravacao
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
			EndIf

		Endif

		aPecas[nPosPeca,1] := .f.

	EndIf

	If !Empty( M->VO3_FORMUL ) .AND. VO3->VO3_FORMUL <> M->VO3_FORMUL
		If ( aPecasAlt[iP,4] # M->VO3_TIPTEM .Or. VOI->VOI_VLPCAC <> "1" )  // CONSIDERA O PRECO ATUAL DA PECA
			RecLock("VO3",.F.)
			VO3->VO3_FORMUL := M->VO3_FORMUL
			VO3->VO3_VALPEC := FG_VALPEC(M->VO3_TIPTEM,"M->VO3_FORMUL",aPecasAlt[iP,7],aPecasAlt[iP,8],,.f.,.t.)
			// Se for alterada a formula, deve ZERAR valor de desconto ...
			If lCpoDesconto
				VO3->VO3_VALLIQ := VO3->VO3_VALPEC
				VO3->VO3_VALDES := 0
				VO3->VO3_PERDES := 0
			EndIf
			//
			MsUnLock()
		Else
			MsgStop(STR0120,STR0075)  // "Impossivel alterar a Formula. Para este Tipo de Tempo somente o preco de requisicao ้ valido!" / Aten็ใo
		EndIf
	EndIf

	// Valida se o valor esta correto
	If !FS_VALVLR160(VO3->VO3_GRUITE,VO3->VO3_CODITE,VO3->VO3_VALPEC)
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf

	nPosPeca := aScan(aPecas,{ |x| x[17] == aPecasAlt[iP,18] })
	If nPosPeca # 0
		aPecasAlt[iP,1]    := aPecas[nPosPeca,1]  := .F.
		aPecasAlt[iP,4]    := aPecas[nPosPeca,2]  := M->VO3_TIPTEM
		aPecasAlt[iP,5]    := aPecas[nPosPeca,3]  := M->VO3_FATPAR
		aPecasAlt[iP,6]    := aPecas[nPosPeca,4]  := M->VO3_LOJA
		aPecasAlt[iP,15]   := aPecas[nPosPeca,15] := M->VO3_CODTES
		aPecasAlt[iP,16]   := aPecas[nPosPeca,16] := VO3->VO3_FORMUL
		aPecas[nPosPeca,8] := M->VO3_DEPINT
		aPecas[nPosPeca,9] := M->VO3_DEPGAR
	EndIf

Next

// Estorna requisicoes do tipo de tempo alterado
dbSelectArea("VO3")
For iP := 1 to Len(aPecasAlt)
	If aPecasAlt[iP,04] == M->VO3_TIPTEM .and. aPecasAlt[iP,17] == TT_STATUS_CANCELADO
		VO3->(dbGoTo(aPecasAlt[iP,14]))
		If !RecLock("VO3",.F.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf
		VO3->VO3_DATCAN := CtoD(" ")
		VO3->(MsUnLock())
	EndIf
Next iP

// Quando a altera็ใo for do Faturar Para ou do Loja
// CI 000864
If  lAltCli

	DbSelectArea("VO3")
	DbSetOrder(8)
	DbSeek(xFilial("VO3")+VO1->VO1_NUMOSV+M->VO3_TIPTEM)
	While !Eof() .And. VO3->VO3_FILIAL == xFilial("VO3") .And. VO1->VO1_NUMOSV+M->VO3_TIPTEM == VO3->VO3_NUMOSV+VO3->VO3_TIPTEM

		If !RecLock("VO3",.F.)

			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break

		EndIf

		VO3->VO3_FATPAR := M->VO3_FATPAR
		VO3->VO3_LOJA   := M->VO3_LOJA
		MsUnlock()

		DbSkip()

	EndDo

	For nPosPeca := 1 to Len(aPecas)
		If aPecas[nPosPeca,02] == M->VO3_TIPTEM
			aPecas[nPosPeca,03] := M->VO3_FATPAR
			aPecas[nPosPeca,04] := M->VO3_LOJA
		EndIf
	Next nPosPeca

	For nPosPeca := 1 to Len(aPecasAlt)
		If aPecasAlt[nPosPeca,04] == M->VO3_TIPTEM
			aPecasAlt[nPosPeca,05] := M->VO3_FATPAR
			aPecasAlt[nPosPeca,06] := M->VO3_LOJA
		EndIf
	Next nPosPeca

	For i := 1 to Len(aServicos)
		If aServicos[i,04] == M->VO3_TIPTEM
			aServicos[i,05] := M->VO3_FATPAR
			aServicos[i,06] := M->VO3_LOJA
		EndIf
	Next i

Endif

If lAltDpI .or. lAltDpG

	DbSelectArea("VO3")
	DbSetOrder(8)
	DbSeek(xFilial("VO3")+VO1->VO1_NUMOSV+M->VO3_TIPTEM)
	While !Eof() .And. VO3->VO3_FILIAL == xFilial("VO3") .And. VO1->VO1_NUMOSV+M->VO3_TIPTEM == VO3->VO3_NUMOSV+VO3->VO3_TIPTEM

		If !RecLock("VO3",.F.)

			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break

		EndIf

		If lAltDpI
			VO3->VO3_DEPINT := M->VO3_DEPINT
		Endif

		If lAltDpG
			VO3->VO3_DEPGAR := M->VO3_DEPGAR
		Endif
		MsUnlock()

		DbSkip()

	EndDo

Endif

If Len(aIteRem) > 0
	OM0200115_MostraItensEmRemessa(aIteRem)
EndIf

//  Altera os servicos que tem o MESMO TT selecionado na alteracao
For i:=1 to Len(aServicos)

	DbSelectArea("VO4")
	DbSetOrder(8)

	If aServicos[i,4]#M->VO3_TIPTEM
		Loop
	EndIf

	VO4->(dbGoTo(aServicos[i,14]))

	If lAltDpI .or. lAltDpG
		If !RecLock("VO4",.F.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf
		If !Empty( M->VO3_DEPINT )
			VO4->VO4_DEPINT := M->VO3_DEPINT
		EndIf
		If !Empty( M->VO3_DEPGAR )
			VO4->VO4_DEPGAR := M->VO3_DEPGAR
		EndIf
		MsUnLock()
	Endif

	if VO4->VO4_FATPAR+VO4->VO4_LOJA == M->VO3_FATPAR+M->VO3_LOJA
		Loop
	endif

	If !RecLock("VO4",.F.)
		Help("  ",1,"REGNLOCK")
		lRet := .f.
		DisarmTransaction()
		Break
	EndIf

	VO4->VO4_FILIAL := xFilial("VO4")
	VO4->VO4_TIPTEM := M->VO3_TIPTEM
	VO4->VO4_FATPAR := M->VO3_FATPAR
	VO4->VO4_LOJA   := M->VO3_LOJA
	MsUnLock()

	cQuery := "SELECT VFB.R_E_C_N_O_ AS RECVFB "
	cQuery += "FROM "
	cQuery += RetSqlName( "VFB" ) + " VFB "
	cQuery += "WHERE "
	cQuery += "VFB.VFB_FILIAL='"+ xFilial("VFB")+ "' AND VFB.VFB_CODCLI = '"+VO1->VO1_PROVEI+"' AND VFB.VFB_LOJA = '"+VO1->VO1_LOJPRO+"' AND "
	cQuery += "VFB.VFB_CHAINT = '"+VO1->VO1_CHAINT+"' AND VFB.VFB_NUMOSV = '"+VO1->VO1_NUMOSV+"' AND VFB.VFB_SERPEC = 'S' AND "
	cQuery += "VFB.VFB_TIPTEM = '"+aServicos[i,4]+"' AND "
	cQuery += "VFB.D_E_L_E_T_=' '"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVFB, .T., .T. )

	Do While !( cAliasVFB )->( Eof() )

		dbSelectArea("VFB")
		VFB->(dbGoTo(( cAliasVFB )->RECVFB))
		If !RecLock("VFB",.F.)
			Help("  ",1,"REGNLOCK")
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		VFB->VFB_CODCLI := VO1->VO1_PROVEI
		VFB->VFB_LOJA   := VO1->VO1_LOJPRO
		VFB->VFB_TIPTEM := M->VO3_TIPTEM
		MsUnlock()

		( cAliasVFB )->(DbSkip())

	EndDo
	( cAliasVFB )->(dbCloseArea())

Next

End Transaction

MsUnlockAll()

If !lTPGRU
	Help(" ",1,"CATALOGO")
EndIf

If !lRet
	If lMsErroAuto
		MostraErro()
	EndIf

	// Volta Backup das Matrizes
	aPecas    := aClone( aPecBKP )
	aPecasAlt := aClone( aPecAltBKP )
	//

EndIf


IIf(cOrdens == STR0065,Asort(aPecas,1,,{|x,y|x[2]+x[3]+x[4]+x[5]+x[6] < y[2]+y[3]+y[4]+y[5]+y[6]}),Asort(aPecas,1,,{|x,y|x[3]+x[4]+x[2]+x[5]+x[6] < y[3]+y[4]+y[2]+y[5]+y[6]})) //"Tipo de Tempo + Cliente + Grupo do Item + Codigo do Item"

oLbItens:SetArray(aPecas)
oLbItens:Refresh()
oLbItens:SetFocus()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FORMUL บ Autor ณ Andre Luis Almeida บ Data ณ  25/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna a Formula atraves da Operacao                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_FORMUL( _cOper , _cTipTem , _lAtu_aCols )
Local lRet     := .t.
Local cRetForm := Space(TamSX3("VO3_FORMUL")[1])
//
// PE para retornar a formula a ser utilizada na Requisi็ใo de Pe็as ( VO3 )
If ExistBlock("OM020FML")
	cRetForm := ExecBlock("OM020FML",.f.,.f.,{ _cOper , _cTipTem })
Else // Formula Padrใo
	If !Empty(_cOper)
		If SFM->(FieldPos("FM_FORMUL")) > 0
			SFM->(DBSetOrder(1))
			If SFM->(MsSeek(xFilial("SFM")+_cOper))
				cRetForm := SFM->FM_FORMUL
			EndIf
		EndIf
	EndIf
	If Empty(cRetForm) .and. !Empty(_cTipTem)
		VOI->(dbSetOrder(1))
		If VOI->(MsSeek(xfilial("VOI")+_cTipTem))
			cRetForm := VOI->VOI_VALPEC
		EndIf
	EndIf
EndIf
//
If !Empty(cRetForm) .And. OFP8600016 .And. OFP8600016_VerificacaoFormula(cRetForm)
	M->VO3_FORMUL := cRetForm
	If _lAtu_aCols
		aCols[ n , FG_POSVAR("VO3_FORMUL") ] := cRetForm
	EndIf
Else
	lRet := .f.
EndIf
//
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CHAMAGRบAutor  ณFabio               บ Data ณ  09/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณChama funcao de gravacao e impressao da ordem de busca      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CHAMAGRAREQ()

Local lRet := .t.
Local ni := 0, nPos
Local lVOIVLPERE := (VOI->(FieldPos("VOI_VLPERE")) > 0)

Local lCpoDesconto := .f.

Local aVO2NOSNUM := {}

Local aColsLotes := {}
Local aBkpACols

Local cLocal
Local cLocaliz

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Indica se os campos de desconto estao criado ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if FG_POSVAR("VO3_VALDES") <> 0 .and. VO3->(FieldPos("VO3_VALDES")) <> 0 .and. ;
	FG_POSVAR("VO3_PERDES") <> 0 .and. VO3->(FieldPos("VO3_PERDES")) <> 0 .and. ;
	VO3->(FieldPos("VO3_VALLIQ")) <> 0
	lCpoDesconto := .t.
endif

VOI->(dbSetOrder(1))
SA1->(DbSetOrder(1))

If cReqDev == "1"
	aBkpACols := aClone(aCols)
	nBkpN := N
EndIf

For ni := 1 to len(aCols)
	If aCols[ni,Len(aCols[ni])]
		Loop
	EndIf

	if oCLiente:Bloqueado(aCols[ni,FG_POSVAR("VO3_FATPAR")], aCols[ni,FG_POSVAR("VO3_LOJA")], .T.)
		lRet := .f.
		Exit
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFNC 29088/2009 - Rubens                                                                       ณ
	//ณAnalista todas as Requisicoes para verificar se a qtde ้ maior do que a exportada do orcamentoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	VOI->(dbSeek(xFilial("VOI")+aCols[nI,FG_POSVAR("VO3_TIPTEM")]))

	If !(FWIsInCallStack("OFNJD15AOS"))
		if VOI->VOI_BLQORC == "1" .and. ( lVOIVLPERE .and. VOI->VOI_VLPERE < aCols[nI,FG_POSVAR("VO3_VALPEC")])
			nPos := FS_POSORC2(.t., .t., nI)
			If (nPos) == 0
				if cReqDev == "1" // Requisicao
					Help("  ",1,"OF020BQO",,,4,1)
					Return .f.
				endif
			Else
				if aCols[nI,FG_POSVAR("VO3_QTDREQ")] > aPecaOrc[nPos,9]
					Alert(STR0110)
					Return .f.
				Endif
			Endif
		EndIf
	EndIf

	// Verifica se a situacao do TT permite requisicao
	If cReqDev == "1" .and. lCANUSETT .and. !FMX_CANUSETT( "1" , M->VO2_NUMOSV , aCols[nI,FG_POSVAR("VO3_TIPTEM")] )
		lRet := .f.
		Exit
	EndIf
	//
	SF4->(dbSetOrder(1))
	If !SF4->(MsSeek(xFilial("SF4") + aCols[nI,FG_POSVAR("VO3_CODTES")] ))
		Help(" ",1,"REGNOIS",,AllTrim(RetTitle("VO3_CODTES")) + ": " + aCols[nI,FG_POSVAR("VO3_CODTES")] ,4,1)
		lRet := .f.
		Exit
	EndIf
	If cReqDev == "1" .and. SF4->F4_ESTOQUE == "S"
		n := nI
		lRet := FS_QTDDISP(;
			aCols[nI,FG_POSVAR("VO3_GRUITE")],;
			aCols[nI,FG_POSVAR("VO3_CODITE")],;
			aCols[nI,FG_POSVAR("VO3_QTDREQ")],;
			.t.,;
			aCols[nI,FG_POSVAR("VO3_FATPAR")]+aCols[nI,FG_POSVAR("VO3_LOJA")],;
			,;
			,;
			,;
			,;
			IIf( lInconveniente , aCols[nI,FG_POSVAR("VO3_SEQINC")] , "" ),;
			aCols[nI,FG_POSVAR("VO3_CODTES")],;
			IIf( lCtrlLote , aCols[nI,FG_POSVAR("VO3_LOTECT")] , ""),;
			IIf( lCtrlLote , aCols[nI,FG_POSVAR("VO3_NUMLOT")] , ""),;
			,;
			IIf(FG_POSVAR('VO3_CODVSJ')>0,aCols[nI,FG_POSVAR('VO3_CODVSJ')],"") )
		If !lRet
			Exit
		EndIf
	EndIf

	// Verifica se esta com problema no campo VO3_VALLIQ
	If lCpoDesconto .and. aCols[nI,FG_POSVAR("VO3_VALLIQ")] > 0 .and. aCols[nI,FG_POSVAR("VO3_VALDES")] <> 0
		If A410Arred( aCols[nI,FG_POSVAR("VO3_VALDES")],"VO3_VALDES") <> A410Arred((aCols[nI,FG_POSVAR("VO3_VALPEC")] - aCols[nI,FG_POSVAR("VO3_VALLIQ")]) * aCols[nI,FG_POSVAR("VO3_QTDREQ")],"VO3_VALDES")
			MsgAlert(STR0134 + CHR(13) + CHR(10) + CHR(13) + CHR(10) +;
				AllTrim(RetTitle("VO3_GRUITE")) + ": " + aCols[nI,FG_POSVAR("VO3_GRUITE")] + CHR(13) + CHR(10) +;
				AllTrim(RetTitle("VO3_CODITE")) + ": " + aCols[nI,FG_POSVAR("VO3_CODITE")] + CHR(13) + CHR(10) +;
				AllTrim(RetTitle("VO3_QTDREQ")) + ": " + AllTrim(Transform(aCols[nI,FG_POSVAR("VO3_QTDREQ")],"@E 999,999,999")) + CHR(13) + CHR(10) +;
				AllTrim(RetTitle("VO3_VALPEC")) + ": " + AllTrim(Transform(aCols[nI,FG_POSVAR("VO3_VALPEC")],"@E 999,999,999.99")) + CHR(13) + CHR(10) +;
				AllTrim(RetTitle("VO3_VALLIQ")) + ": " + AllTrim(Transform(aCols[nI,FG_POSVAR("VO3_VALLIQ")],"@E 999,999,999.99")) + CHR(13) + CHR(10) +;
				AllTrim(RetTitle("VO3_VALDES")) + ": " + AllTrim(Transform(aCols[nI,FG_POSVAR("VO3_VALDES")],"@E 999,999,999.99")) + " (" + STR0008 + ")" ; // Total
				, STR0075 ) // "Diverg๊ncia com valor de pe็as"
			lRet := .f.
			Exit
		EndIf
	EndIf
	//

	If cReqDev == "1" .and. lCtrlLote .and. !Empty(aCols[nI,FG_POSVAR("VO3_LOTECT")])
		OM020LOCAL( nI , @cLocal , @cLocaliz )
		If !FG_RASTRO(aCols[nI,FG_POSVAR("VO3_GRUITE")],aCols[nI,FG_POSVAR("VO3_CODITE")],aCols[nI,FG_POSVAR("VO3_QTDREQ")],aCols[nI,FG_POSVAR("VO3_LOTECT")],aCols[nI,FG_POSVAR("VO3_NUMLOT")],,,cLocal)
			Return .f.
		EndIf
	EndIf

	// Verifica se ้ opcional de veiculo
	// AMS para John Deere ...
	If aCols[nI,FG_POSVAR("VO3_GRUITE")] == PadR(cMVGRUVEI, TamSX3("B1_GRUPO")[1]) .AND. !OM020VALVEI(1,aCols[nI,FG_POSVAR("VO3_CODITE")],aCols[nI,FG_POSVAR("VO3_CODTES")])
		lRet := .f.
		Exit
	EndIf
Next

// Controle de Lote
If lRet .and. cReqDev == "1"
 	If lCtrlLote
		lRet := OM020LOTES(@aColsLotes)
	EndIf
EndIf
//

If lRet
	If (ExistBlock("OM020RDOK")) // Ponto de Entrada para adicionar valida็๕es customizadas antes da grava็ใo
		lRet := ExecBlock("OM020RDOK", .f., .f., {cReqDev})
	EndIf
EndIf

If lRet
	aVO2NOSNUM := {}
	lRet := FS_GRAREQ(,,,aColsLotes,@aVO2NOSNUM) // Executa Gravacao
	If !lOM020Auto .and. lRet
		FS_ORDBUSCA(aVO2NOSNUM)
	EndIf
EndIf

If !lRet .and. cReqDev == "1"
	aCols := aClone(aBkpACols)
	N := nBkpN
EndIf

MV_PAR01 := ""
MV_PAR03 := ""
MV_PAR04 := ""
MV_PAR05 := ""

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GRAREQ บAutor  ณFabio               บ Data ณ  12/22/99   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava Requisicao e Devolucao de Pecas.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_GRAREQ( aColsDev , aHeaderDev ,lnotDele , aColsLotes, aVO2NOSNUM)

Local lRet := .t. , ni := 0

Local aAuxACols
Local nPosProc

Private cMVRESITE := PadR( AllTrim(GetMv("MV_RESITE")), TamSX3("B2_LOCAL")[1] )

Private lMVCONSRV  := (GetNewPar("MV_CONSRV" ,"N") == "S")
Private lMVCALCMED := (GetNewPar("MV_CALCMED","N") == "S")
Private lMVRITEORC := (GetNewPar("MV_RITEORC","N") == "S")

Private  lMsHelpAuto := .t. , lMsErroAuto := .f., lMsFinalAuto := .f.

Default lNotDele   := .T.
Default aColsDev   := {}
Default aHeaderDev := {}
Default aColsLotes := {}

// Requisicao
If cReqDev == "1"
	nI := 0
	aAuxACols := {}
	nPosTipTem := FG_POSVAR("VO3_TIPTEM")
	nPosGruIte := FG_POSVAR("VO3_GRUITE")
	nPosCodIte := FG_POSVAR("VO3_CODITE")
	While Len(aCols) <> 0
		nPosProc := 1
		nI++
		AADD( aAuxACols, {} )
		While nPosProc <= Len(aCols)
			If aCols[nPosProc,Len(aCols[nPosProc])]
				aDel(aCols,nPosProc)
				aSize(aCols,Len(aCols)-1)
				Loop
			EndIf

			If aScan(aAuxaCols[nI], { |x| x[nPosTipTem] == aCols[nPosProc,nPosTipTem] .and. x[nPosGruIte] == aCols[nPosProc,nPosGruIte] .and. x[nPosCodIte] == aCols[nPosProc,nPosCodIte] }) == 0
				AADD( aAuxACols[nI] , aClone(aCols[nPosProc]) )
				aDel(aCols,nPosProc)
				aSize(aCols,Len(aCols)-1)
			Else
				nPosProc++
			EndIf
		End
	End
	For nPosProc := 1 to Len(aColsLotes)
		AADD( aAuxACols, aClone(aColsLotes[nPosProc]) )
	Next nPosProc
Else
	aAuxACols := { aClone(aCols) }
EndIf

// Inicio da gravacao
Begin Transaction

	For nPosProc := 1 to Len(aAuxACols)

		aCols := aClone(aAuxACols[nPosProc])

		DbSelectArea("VO2")

		If !OM020VO2CriaRegistro(@aVO2NOSNUM)
			lRet := .f.
			DisarmTransaction()
			Break
		EndIf

		For ni := 1 to len(aCols)

			If aCols[ni,Len(aCols[ni])]
				Loop
			EndIf

			If !OM020VO3CriaRegistro(nI)
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf

			If !OM020VFBMovimenta()
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf

			VV1->(DbSetOrder(1))
			VV1->(MsSeek(xFilial("VV1")+VO1->VO1_CHAINT))

			If !OM020VF6CriaRegistro()
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf

			If VOI->VOI_SITTPO $ "2/4" .Or. (VOI->VOI_SITTPO == "3" .And. VO3->VO3_DEPINT == "R")
				DbSelectArea("VO1")
				If !RecLock("VO1",.F.)
					Help("  ",1,"REGNLOCK")
					lRet := .f.
					DisarmTransaction()
					Break
				EndIf
				VO1->VO1_TEMGAR := "S"
				MsUnlock()
			EndIf

			If !OM020MOVESTOQUE(nI)
				lRet := .f.
				DisarmTransaction()
				Break
			EndIf

			// Verifica se ้ opcional de veiculo
			// AMS para John Deere ...
			If SB1->B1_GRUPO == PadR(cMVGRUVEI, TamSX3("B1_GRUPO")[1])
				aAreaVV1 := VV1->(GetArea())

				VV1->(dbSetOrder(1))
				If VV1->(dbSeek( xFilial("VV1") + Left(SB1->B1_CODITE,TamSX3("VV1_CHAINT")[1]) ))
					RecLock("VV1",.F.)
					VV1->VV1_SITVEI := IIf( cReqDev == "1" , "9" , "0" )
					VV1->(MsUnLock())
				EndIf

				RestArea(aAreaVV1)
			EndIf

		Next

		// Apaga VSJ
		OM020VSJBAIXA()
		//

	Next

End Transaction

If !lRet
	MsUnlockAll()
	MostraErro()
EndIf
lMsHelpAuto := .f.


Return(lRet)


/*/{Protheus.doc} OM020LOTES
Pesquisa lote para requisicao
@author Rubens
@since 06/09/2016
@version undefined
@param aColsLotes, array, descricao
@type function
/*/
Static Function OM020LOTES(aColsLotes)

	Local aLotes := {}
	Local nPosLote
	Local nPosAColsLotes := 1
	Local aBkpACols
	Local nI
	Local lRet := .t.
	Local aLotesAutom := {} // Adiciona os lotes que foram utilizados automaticamente

	aColsLotes := {}

	nBkpN := N
	aBkpACols := aClone(aCols)
	// Ordena por ordem decrescente, pois no processamento, quando existir registro na VSJ, deve procurar primeiro os
	// registros em que possuem lote gravado na VSJ
	aSort( aCols ,,, { |x,y| x[FG_POSVAR("VO3_GRUITE")] + x[FG_POSVAR("VO3_CODITE")] + x[FG_POSVAR("VO3_LOTECT")] > y[FG_POSVAR("VO3_GRUITE")] + y[FG_POSVAR("VO3_CODITE")] + y[FG_POSVAR("VO3_LOTECT")] })
	For nI := 1 to Len(aCols)
		If aCols[ni,Len(aCols[ni])]
			Loop
		EndIf

		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4") + aCols[nI,FG_POSVAR("VO3_CODTES")]))
		If SF4->F4_ESTOQUE <> "S"
			Loop
		EndIf

		cGruIte := aCols[nI,FG_POSVAR("VO3_GRUITE")]
		cCodIte := aCols[nI,FG_POSVAR("VO3_CODITE")]
		cRetLote := OM020PESQLOTE( cGruIte , cCodIte , nI , @aLotes , @aLotesAutom )
		Do Case
		Case cRetLote == "SEMLOTE"
			lRet := .f.
			Exit
		Case cRetLote == "COMLOTE"
			aCols[nI, FG_POSVAR("VO3_LOTECT") ] := aLotes[ 01 , 01]	// Lote
			aCols[nI, FG_POSVAR("VO3_NUMLOT") ] := aLotes[ 01 , 02]	// Sub-Lote
			If Len(aLotes) > 1
				n := nI
				FG_MEMVAR()
				M->VO3_QTDREQ := aLotes[ 01 , 05 ] // Quantidade
				__ReadVar := "M->VO3_QTDREQ"
				If !VALREQ020() .OR. !FS_FIELD020(.f.,)
					lRet := .f.
					Exit
				EndIf
				If Len(aColsLotes) == 0
					AADD(aColsLotes,{})
				EndIf
			EndIf
			For nPosLote := 2 to Len(aLotes)
				nPosAColsLotes := 1
				While .t.
					If aScan(aColsLotes[nPosAColsLotes], { |x| x[FG_POSVAR("VO3_GRUITE")] == cGruIte .and. x[FG_POSVAR("VO3_CODITE")] == cCodIte }) == 0
						Exit
					EndIf
					nPosAColsLotes++
					If nPosAColsLotes > Len(aColsLotes)
						AADD(aColsLotes,{})
						Exit
					EndIf
				End

				AADD(aColsLotes[nPosAColsLotes],aClone(aCols[nI]))
				nItens := Len(aColsLotes[nPosAColsLotes])
				aColsLotes[ nPosAColsLotes, nItens , FG_POSVAR("VO3_LOTECT") ] := aLotes[ nPosLote , 01]	// Lote
				aColsLotes[ nPosAColsLotes, nItens , FG_POSVAR("VO3_NUMLOT") ] := aLotes[ nPosLote , 02]	// Sub-Lote
				aColsLotes[ nPosAColsLotes, nItens , FG_POSVAR("VO3_QTDREQ") ] := aLotes[ nPosLote , 05]	// Quantidade

			Next nPosLote
		End Case
	Next nI
	If !lRet
		aCols := aClone(aBkpACols)
		N := nBkpN
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_020ITESUBบAutor  ณFabio               บ Data ณ  12/28/99   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao interna da Requisica p/ verificar se o item foi subs_  บฑฑ
ฑฑบ          ณtituido                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_020ITESUB()

cCodSIte := FG_ITESUB(M->VO3_GRUITE+M->VO3_CODITE)
if ValType(cCodSIte) == "A"
	M->VO3_GRUITE := cCodSIte[1]
	M->VO3_CODITE := cCodSIte[2]
else
	M->VO3_CODITE := cCodSIte
endif
SB1->(DBSetOrder(7))
SB1->(DBSeek( xFiliaL("SB1") + M->VO3_GRUITE + M->VO3_CODITE ))
//
M->VO3_QTDEST:= FS_SALDOESTQ( SB1->B1_COD , OM0200065_ArmazemOrigem( M->VO3_TIPTEM ) )
//
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_LINOK020บAutor ณFabio               บ Data ณ  01/06/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se a linha do acols esta correta                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_LINOK020()
Local lQtdeDisp

If !FG_OBRIGAT()
	Return(.f.)
EndIf

// Linha deletada
If aCols[n,Len(aCols[n])]
	Return(.t.)
EndIf

SB1->(DbSetOrder(7))
If !SB1->(DbSeek(xFilial('SB1')+aCols[n,FG_POSVAR('VO3_GRUITE')]+aCols[n,FG_POSVAR('VO3_CODITE')] ))
	Help(" ",1,"ITENOTFOUN")
	Return(.f.)
EndIf

If cReqDev == "1" .And. !FG_FATSP(M->VO3_TIPTEM,M->VO3_FATPAR+M->VO3_LOJA,'M->VO3_NOMCLI','A1_NOME',,aCols,,"VO3_TIPTEM","VO3_FATPAR","VO3_LOJA",n)
	Return(.f.)
EndIf

If cReqDev == "1"
	If Empty(aCols[n,FG_POSVAR("VO3_FORMUL")])
		Help(" ",1,"OBRIGAT")
		Return (.f.)
	ElseIf OFP8600016 .And. !OFP8600016_VerificacaoFormula(aCols[n,FG_POSVAR("VO3_FORMUL")])
		Return .f. // A mensagem jแ ้ exibida dentro da fun็ใo
	EndIf
Endif

// Verifica se o Grupo do item pode ser utilizado para o Tipo de Tempo selecionado
If !FG_GRUTEM( aCols[n,FG_POSVAR('VO3_TIPTEM')] , aCols[n,FG_POSVAR('VO3_GRUITE')] )
	Return(.f.)
EndIf

lQtdeDisp := FS_QTDDISP(;
	aCols[n,FG_POSVAR('VO3_GRUITE')],;
	aCols[n,FG_POSVAR('VO3_CODITE')],;
	aCols[n,FG_POSVAR('VO3_QTDREQ')],;
	,;
	aCols[n,FG_POSVAR("VO3_FATPAR")]+aCols[n,FG_POSVAR("VO3_LOJA")],;
	,;
	,;
	,;
	,;
	IIf( lInconveniente , aCols[n,FG_POSVAR("VO3_SEQINC")] , "" ),;
	aCols[n,FG_POSVAR("VO3_CODTES")],;
	IIf( lCtrlLote , aCols[n,FG_POSVAR("VO3_LOTECT")] , ""),;
	IIf( lCtrlLote , aCols[n,FG_POSVAR("VO3_NUMLOT")] , ""),;
	,;
	IIf(FG_POSVAR('VO3_CODVSJ')>0,aCols[n,FG_POSVAR('VO3_CODVSJ')],"") )

If !lQtdeDisp
	Return(.f.)
EndIf

// Validacao de Credito
If cReqDev == "1" .And. lVldCredLOK .and. "P" $ cMVCHKCRE .and. GetNewPar("MV_MIL0138","1") <> "0" // Checagem do limite de Credito do Cliente, Pe็a a Pe็a
	If !OM020AVCRED(M->VO3_FATPAR,M->VO3_LOJA,M->VO3_TIPTEM, FS_TOTAL( M->VO3_FATPAR , M->VO3_LOJA,.T.,.t.) )
		Return(.f.)
	EndIf
EndIf
//

If cReqDev == "1"
	If VOI->VOI_DEPINT=="1" .And. Empty(M->VO3_DEPINT)
		Help("  ",1,"OBRIGAT",,aHeader[FG_POSVAR('VO3_DEPINT'),1],4,1)
		Return(.f.)
	EndIf
	If VOI->VOI_DEPGAR=="1" .And. Empty(M->VO3_DEPGAR)
		Help("  ",1,"OBRIGAT",,aHeader[FG_POSVAR('VO3_DEPGAR'),1],4,1)
		Return(.f.)
	EndIf
EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FIELD020บAutor ณFabio               บ Data ณ  04/02/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida campos "FieldOK"                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_FIELD020(lExeFGMEMVAR,lAtuTELA)

Local nPosCODITE := 0
Local aInconv

Local lRet := .t.
Local lCpoDesconto
Local _cReadVar := Readvar()
Local cAuxTES
Local cSQL
Local cAuxSG
Local cQuery := ""

Local cLocal
Local cLocaliz

Local oOficina := DMS_Oficina():New()

Default lExeFGMEMVAR := .t.
Default lAtuTELA := .t. // Atualiza TELA e campos na aCols sem verificar a existencia dos mesmos ( funcao pode ser chamada de outra rotina - OFIA310 )

If lExeFGMEMVAR
	FG_MEMVAR()
EndIf

lReadTipT := .f.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Indica se os campos de desconto estao criado ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lAtuTELA
	if FG_POSVAR("VO3_VALDES") <> 0 .and. VO3->(FieldPos("VO3_VALDES")) <> 0 .and. ;
		FG_POSVAR("VO3_PERDES") <> 0 .and. VO3->(FieldPos("VO3_PERDES")) <> 0 .and. ;
		VO3->(FieldPos("VO3_VALLIQ")) <> 0
		lCpoDesconto := .t.
	endif
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฟ
//ณRequisicaoณ
//ภฤฤฤฤฤฤฤฤฤฤู
If cReqDev == '1'

	if !Empty(M->VO3_GRUITE) .and. !Empty(M->VO3_CODITE)
		if M->VO3_GRUITE+M->VO3_CODITE <> SB1->B1_GRUPO+SB1->B1_CODITE
			SB1->(DbSetOrder(7))
			SB1->(DbSeek(xFilial("SB1")+M->VO3_GRUITE+M->VO3_CODITE))
		EndIf
	EndIf

	if Empty(aCols[n,FG_POSVAR("VO3_TIPTEM")]) .and. !Empty(cTpTpoPEVM)
		aCols[n,FG_POSVAR("VO3_TIPTEM")] :=cTpTpoPEVM
		M->VO3_TIPTEM := cTpTpoPEVM
		lReadTipT := .t.
	endif
	if  !Empty(cProdPEVM) // Empty(aCols[n,FG_POSVAR("VO3_PROREQ")]) .and.
		aCols[n,FG_POSVAR("VO3_PROREQ")] :=cProdPEVM
		M->VO3_PROREQ := cProdPEVM
	endif

	If ReadVar() $ 'M->VO3_QTDREQ' .OR. ReadVar() $ "M->VO3_QTD2UM"

		If !Empty(M->VO3_LOTECT)
			OM020LOCAL( n , @cLocal , @cLocaliz )
			If !FG_RASTRO(M->VO3_GRUITE,M->VO3_CODITE,M->VO3_QTDREQ,M->VO3_LOTECT,M->VO3_NUMLOT,,,cLocal)
				Return .f.
			EndIf
		EndIf

		If ReadVar() == "M->VO3_QTD2UM"
			M->VO3_QTDREQ := Round(Iif(SB1->B1_TIPCONV=="M",M->VO3_QTD2UM/SB1->B1_CONV,M->VO3_QTD2UM*SB1->B1_CONV),TamSX3("VO3_QTDREQ")[2])
			aCols[n,FG_POSVAR("VO3_QTDREQ")]:= M->VO3_QTDREQ
		EndIf
		If ReadVar() == "M->VO3_QTDREQ" .and. FG_POSVAR("VO3_QTD2UM") > 0
			M->VO3_QTD2UM := Round(Iif(SB1->B1_TIPCONV=="M",M->VO3_QTDREQ*SB1->B1_CONV,M->VO3_QTDREQ/SB1->B1_CONV),TamSX3("VO3_QTDREQ")[2])
			aCols[n,FG_POSVAR("VO3_QTD2UM")]:= M->VO3_QTD2UM
		EndIf

		//Validacao por Ponto de Entrada
		lVerTpgCC := .t.
		If PEVERTPGCC // Verifica tipo de Pagamento para Checagem de Credito
			lVerTpgCC := ExecBlock("VERTPGCC", .f., .f., {"OFIOM020"})
		EndIf

		If lVerTpgCC
			// Sempre chama a avaliacao para atualizar tambem o total (FS_TOTAL)
			If "P" $ cMVCHKCRE .and. GetNewPar("MV_MIL0138","1") <> "0" // Checagem do limite de Credito do Cliente, Pe็a a Pe็a
				If !OM020AVCRED(M->VO3_FATPAR, M->VO3_LOJA, M->VO3_TIPTEM, FS_TOTAL(M->VO3_FATPAR, M->VO3_LOJA, .T., .T.))
					Return .f.
				EndIf
			EndIf
		EndIf
	EndIf

	If ReadVar() $ 'M->VO3_FORMUL'
		If OFP8600016 .And. !OFP8600016_VerificacaoFormula(M->VO3_FORMUL)
			Return .f. // A mensagem jแ ้ exibida dentro da fun็ใo
		EndIf

		lVldCredLOK := .t.
	EndIf

	If ReadVar() $ 'M->VO3_CODTES'

		If !OM020TESVALIDA(M->VO3_CODTES)
			Return .f.
		EndIf

		// Valida configuracao de movimentacao de estoque das TES quando a peca esta sendo importada de orcamento ...
		If aCols[n,FG_POSVAR("VO3_IMPORC")] == "1" .and. !Empty(aCols[n,FG_POSVAR("VO3_CODTES")])
			If !OM020CMPTES( aCols[n,FG_POSVAR("VO3_CODTES")], M->VO3_CODTES )
				Return .f.
			Endif
		Endif
		//
	EndIf

	If ReadVar() $ 'M->VO3_OPER'

		cAuxTES := MaTesInt(2,M->VO3_OPER,M->VO3_FATPAR,M->VO3_LOJA,"C",SB1->B1_COD)

		If !Empty(cAuxTES)
			If !OM020TESVALIDA(cAuxTES)
				Return .f.
			Endif

			// Valida configuracao de movimentacao de estoque das TES quando a peca esta sendo importada de orcamento ...
			If aCols[n,FG_POSVAR("VO3_IMPORC")] == "1" .and. !Empty(aCols[n,FG_POSVAR("VO3_CODTES")])
				If !OM020CMPTES( aCols[n,FG_POSVAR("VO3_CODTES")], cAuxTES )
					Return .f.
				Endif
			EndIf
			//

			aCols[n,FG_POSVAR("VO3_CODTES")]:= M->VO3_CODTES := cAuxTES
		EndIf

	EndIf

	If FG_POSVAR("VO3_QTDEST")#0 .And. (ReadVar() == 'M->VO3_GRUITE' .Or. ReadVar() == 'M->VO3_CODITE') .and. !Empty(M->VO3_GRUITE) .and. !Empty(M->VO3_CODITE)
		aCols[n,FG_POSVAR("VO3_QTDEST")]:=M->VO3_QTDEST:= FS_SALDOESTQ( SB1->B1_COD , OM0200065_ArmazemOrigem( M->VO3_TIPTEM ) )
	EndIf

	If FG_POSVAR("VO3_LOCPRO")#0 .And. (ReadVar() == 'M->VO3_GRUITE' .Or. ReadVar() == 'M->VO3_CODITE') .and. !Empty(M->VO3_GRUITE) .and. !Empty(M->VO3_CODITE)
		aCols[n,FG_POSVAR("VO3_LOCPRO")]:= M->VO3_LOCPRO:= OM020LOCACAO(SB1->B1_COD)
	Endif

	If ReadVar() == 'M->VO3_CODITE'
		If !lOM020Auto
			cCodSIte := FG_ITESUB(M->VO3_GRUITE+M->VO3_CODITE)   // Verifica se o item foi substituido
			if ValType(cCodSIte) == "A"
				M->VO3_GRUITE := cCodSIte[1]
				M->VO3_CODITE := cCodSIte[2]
				aCols[n,FG_POSVAR("VO3_GRUITE")] := M->VO3_GRUITE
				DBSelectArea("SB1")
				DBSetOrder(7)
				DBSeek(xFilial("SB1")+cCodSIte[1]+cCodSIte[2])
				M->VO3_DESITE := SB1->B1_DESC
				aCols[n,FG_POSVAR("VO3_DESITE")] := SB1->B1_DESC
				aCols[n,FG_POSVAR("VO3_QTDEST")] := M->VO3_QTDEST := FS_SALDOESTQ( SB1->B1_COD , OM0200065_ArmazemOrigem( M->VO3_TIPTEM ) )
			else
				M->VO3_CODITE := cCodSIte
			endif
            
			// Quando trocar o item deve deixar a TES em branco para recarregar com a TES do novo item informado
			If ( M->VO3_GRUITE + M->VO3_CODITE ) <> ( aCols[n,FG_POSVAR("VO3_GRUITE")] + aCols[n,FG_POSVAR("VO3_CODITE")] ) .and. !Empty(aCols[n,FG_POSVAR("VO3_CODITE")] )
				aCols[n,FG_POSVAR("VO3_CODTES")] := Space(TAMSX3("VO3_CODTES")[1])
				M->VO3_CODTES := Space(TAMSX3("VO3_CODTES")[1])
			Endif
		EndIf
		If !FG_GARANTIA( VO1->VO1_CHAINT , M->VO3_TIPTEM , M->VO3_GRUITE , M->VO3_CODITE , , dDataBase , VO1->VO1_KILOME )
			Return(.f.)
		EndIf

		If lAtuTELA
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณValida Formulaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			FS_VALFOR( M->VO3_TIPTEM , M->VO3_GRUITE , M->VO3_CODITE , Iif( lInconveniente , M->VO3_SEQINC , "" ))
		EndIf

		if lInconveniente
			// Se a OS utilizou ao menos um inconveniente, deve ser selecionado um inconveniente para o item
			if Empty(aCols[n,FG_POSVAR("VO3_SEQINC")])
				// Procura um item com inconveniente selecinado
				nPosCODITE := Ascan(aCols,{|x| !Empty(x[FG_POSVAR("VO3_SEQINC")]) })

				// Se tiver um item com inconveniente ou ja tiver uma peca requisitada com um inconveniente ...
				if nPosCODITE <> 0 .or. OM420UTILINC( "2" , VO1->VO1_NUMOSV )

					cQuery := "SELECT B1_DESC FROM "+RetSQLName("SB1")
					cQuery += " WHERE B1_FILIAL='"+xFilial("SB1")+"'"
					cQuery += "   AND B1_GRUPO='"+M->VO3_GRUITE+"'"
					cQuery += "   AND B1_CODITE='"+M->VO3_CODITE+"'"
					cQuery += "   AND D_E_L_E_T_=' '"

					aInconv := OM420SELINCON(aCols, { FG_POSVAR("VO3_SEQINC") , ;
					FG_POSVAR("VO3_GRUINC") , ;
					FG_POSVAR("VO3_CODINC") , ;
					FG_POSVAR("VO3_DESINC") } , oMainWnd , "2" , VO1->VO1_NUMOSV ,;
					STR0150+": "+M->VO3_GRUITE+" - "+STR0151+": "+M->VO3_CODITE+" - "+FM_SQL(cQuery) ) // Grupo / Codigo do Item

					aCols[n,FG_POSVAR("VO3_GRUINC")] := aInconv[1]
					aCols[n,FG_POSVAR("VO3_CODINC")] := aInconv[2]
					aCols[n,FG_POSVAR("VO3_DESINC")] := aInconv[3]
					aCols[n,FG_POSVAR("VO3_SEQINC")] := aInconv[4]
					if TYPE("oGetReqPec") <> "U"
						oGetReqPec:oBrowse:Refresh()
					Endif

				endif

			endif
		endif
		If !lOM020Auto
			FS_ITEREL()
		EndIf
		
		OM0200139_CarregaTES()

		If !Empty(M->VO3_OPER)
			// Atualiza a Formula
			FS_FORMUL( M->VO3_OPER , M->VO3_TIPTEM , lAtuTELA ) 
		Endif

		// Calcula o valor unitario da Peca
		If lAtuTELA
			FS_VALOR()
		EndIf

	EndIf

	If ReadVar() == "M->VO3_TIPTEM" .or. lReadTipT

		If ReadVar() == "M->VO3_TIPTEM"
			If oOficina:TipoTempoBloqueado(M->VO3_TIPTEM,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
				Return(.f.)
			EndIf
		EndIf

		// Valida tipo de tempo do orcamento
		if lReadTipT
			tmpReadVar := __readvar
			__readvar := "M->VO3_TIPTEM"
			FG_TIPTPFAT(,"M->VO3_FATPAR","M->VO3_LOJA","M->VO3_NOMCLI",Posicione("VV1",1,xFilial("VV1")+VO1->VO1_CHAINT,"VV1_CODMAR"))
		endif
		If !FS_VALTPORC(M->VO3_TIPTEM)
			Return(.f.)
		EndIf

		// Valida se o veiculo tem tipo de tempo aberto em outra OS
		If !FS_VALTPABE(VO1->VO1_CHASSI,M->VO3_TIPTEM,VO1->VO1_NUMOSV)
			Return(.f.)
		EndIf

		// Valida tipo de atendimento por tipo de tempo
		If lVOITPATEN
			If !FGX_VOITPATEN(VO1->VO1_TPATEN, M->VO3_TIPTEM, .t.)
				Return(.f.)
			EndIf
		EndIf

		// Se for John Deere ...
		If VOI->VOI_SITTPO == "2" .and. TCCanOpen(RetSQLName("VMB"))
			// Verifica se existe SG criada e verifica se ้ de Revisao...
			// Se for de revisao nao pode envolver pe็as ...
			cSQL := "SELECT VMB_CODGAR "
			cSQL +=  " FROM " + RetSQLName("VMB")
			cSQL += " WHERE VMB_FILIAL = '" + xFilial("VMB") + "'"
			cSQL +=   " AND VMB_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
			cSQL +=   " AND VMB_TIPGAR = 'ZZMK'"
			cSQL +=   " AND VMB_SUBGAR = 'MTC'"
			cSQL +=   " AND VMB_STATUS NOT IN ('04','05','15')" // 04=REJEITADO ou 05=DELETADO ou 15=DEBITADO
			cSQL +=   " AND D_E_L_E_T_ = ' '"
			cAuxSG := FM_SQL(cSQL)
			If !Empty(cAuxSG)
				Help("  ",1,"M020SGJDREV")
				Return .f.
			EndIf
			//
		EndIf

		// Grava formula de acordo com o tipo de tempo
		VOI->(dbSetOrder(1))
		VOI->(dbSeek(xfilial("VOI")+M->VO3_TIPTEM))
		If !Empty(VOI->VOI_CODOPE)
			M->VO3_OPER := VOI->VOI_CODOPE
			aCols[n,FG_POSVAR("VO3_OPER")] := M->VO3_OPER
		EndIF

		FS_FORMUL( M->VO3_OPER , M->VO3_TIPTEM , lAtuTELA ) // Atualiza a Formula

		if !Empty(M->VO3_GRUITE) .and. !Empty(M->VO3_CODITE)
			dbSelectArea("SB1")
			dbSetOrder(7)
			dbSeek(xFilial("SB1")+M->VO3_GRUITE+M->VO3_CODITE)

			cAuxTES := MaTesInt(2,M->VO3_OPER,M->VO3_FATPAR,M->VO3_LOJA,"C",SB1->B1_COD)
			If !Empty(cAuxTES)
				SF4->(dbSetOrder(1))
				If !SF4->(MsSeek(xFilial("SF4") + cAuxTES))
					Help(" ",1,"REGNOIS",,AllTrim(RetTitle("VO3_CODTES")) + ": " + cAuxTES ,4,1)
				Else
					aCols[ n , FG_POSVAR("VO3_CODTES") ] := M->VO3_CODTES := cAuxTES
				EndIf
			EndIf

			If lAtuTELA
				FS_VALOR()
			EndIf
		Endif

		If lAtuTELA
			FS_TOTAL()
		EndIf

		FS_020INTGAR(VO1->VO1_NUMOSV,M->VO3_TIPTEM)
		if lReadTipT
			__readvar := tmpReadVar
		endif
	EndIF

	If ReadVar() == "M->VO3_OPER"
		dbSelectArea("SB1")
		dbSetOrder(7)
		dbSeek(xFilial("SB1")+M->VO3_GRUITE+M->VO3_CODITE)

		cAuxTES := MaTesInt(2,M->VO3_OPER,M->VO3_FATPAR,M->VO3_LOJA,"C",SB1->B1_COD)

		// Valida configuracao de movimentacao de estoque das TES quando a peca esta sendo importada de orcamento ...
		If aCols[n,FG_POSVAR("VO3_IMPORC")] == "1" .and. !Empty(aCols[n,FG_POSVAR("VO3_CODTES")])
			If !OM020CMPTES( aCols[n,FG_POSVAR("VO3_CODTES")], cAuxTES )
				Return .f.
			Endif
		Endif
		//

		If !Empty(cAuxTES)
			SF4->(dbSetOrder(1))
			If !SF4->(MsSeek(xFilial("SF4") + cAuxTES))
				Help(" ",1,"REGNOIS",,AllTrim(RetTitle("VO3_CODTES")) + ": " + cAuxTES ,4,1)
			Else
				aCols[n,FG_POSVAR("VO3_CODTES")] := M->VO3_CODTES := cAuxTES
			EndIf
		EndIf
		If Empty(M->VO3_CODTES)
			cAuxTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
			If !Empty(cAuxTES)
				SF4->(dbSetOrder(1))
				If !SF4->(MsSeek(xFilial("SF4") + cAuxTES))
					Help(" ",1,"REGNOIS",,AllTrim(RetTitle("VO3_CODTES")) + ": " + cAuxTES ,4,1)
				Else
					aCols[n,FG_POSVAR("VO3_CODTES")] := M->VO3_CODTES := cAuxTES
				EndIf
			EndIf
		Endif

		FS_FORMUL( M->VO3_OPER , M->VO3_TIPTEM , lAtuTELA ) // Atualiza a Formula

		FG_VALPEC(M->VO3_TIPTEM,"M->VO3_FORMUL",M->VO3_GRUITE,M->VO3_CODITE,"M->VO3_VALPEC",.F.)

	Endif


	If ReadVar() == "M->VO3_DEPINT" .Or. ReadVar() == "M->VO3_DEPGAR"
		IF !FS_020INTGAR(VO1->VO1_NUMOSV,M->VO3_TIPTEM)
			Return (.f.)
		ENDIF
	EndIf

	If ReadVar() == "M->VO3_PROREQ"

		If VAI->VAI_FUNPRO # "1" .Or. VAI->VAI_REQPEC # "1" .Or. !FG_PROTRA(M->VO2_NUMOSV,M->VO3_PROREQ,,,n)
			If VAI->VAI_FUNPRO # "1"
				ShowHelpDlg ( "NAOPRODUTIVO" , { STR0246 } , , {STR0247}) // "Funcionแrio nใo ้ produtivo." / Verifique o cadastro de equipe t้cnica.
			EndIf
			If VAI->VAI_REQPEC # "1"
				ShowHelpDlg ( "REQPEC" , { STR0248 } , , {STR0247}) // "Produtivo sem permissใo para requisitar pe็a." / Verifique o cadastro de equipe t้cnica.
			EndIf

			Return( .f. )

		EndIf

		// Repete produtivo para as pecas do orcamento
		FS_REPPROORC()

	EndIf

	If ReadVar() == "M->VO3_FORMUL" .or. ReadVar() == "M->VO3_OPER" .and. lCpoDesconto
		aCols[n,FG_POSVAR("VO3_VALLIQ")] := M->VO3_VALLIQ := aCols[n,FG_POSVAR("VO3_VALPEC")]
	EndIf
	If ReadVar() == "M->VO3_QTDREQ"
		aCols[n,FG_POSVAR("VO3_QTDREQ")] := M->VO3_QTDREQ
	Endif

	If lOM020Auto .and. ReadVar() == "M->VO3_CODVSJ"
		aPecaSel := {}
		aEval( aPecaOrc, {|x| AADD( aPecaSel , x[1] ) } )
		nPPecaOrc := aScan( aPecaOrc ,{ |x| x[PECAORC_CODIGOVSJ] == M->VO3_CODVSJ } )
		If FS_TPecOrc( .f. , .t. , nPPecaOrc)
			FS_IMPORC( "R" )
		EndIf
	EndIf
	If lAtuTELA
		FS_TOTAL()
	EndIf
EndIf

//Validacao por Ponto de Entrada
If ExistBlock("OM020VLD")
	lRet := ExecBlock("OM020VLD",.f.,.f.,{_cReadVar})
	If !lRet
		Return (.f.)
	Endif
Endif

If lAtuTELA
	if cReqDev == "1"
		if lCpoDesconto .and. M->VO3_VALLIQ > 0
			aCols[n,FG_POSVAR("VO3_VALDES")]:= ( M->VO3_VALPEC - M->VO3_VALLIQ ) * M->VO3_QTDREQ
			aCols[n,FG_POSVAR("VO3_VALTOT")]:= M->VO3_VALLIQ * M->VO3_QTDREQ
		else
			aCols[n,FG_POSVAR("VO3_VALTOT")]:= M->VO3_VALPEC * M->VO3_QTDREQ
		endif
		If !lOM020Auto
			oTotal:Refresh()
		EndIf
	Endif
EndIf

Return( FS_DFATPAR() )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALFOR บAutor  ณFabio               บ Data ณ  12/15/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida Formula                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VALFOR( cTipTem , cGruIte , cCodIte , cSeqInc)

Local cAliasOld := Alias() , lRet := .t.
Local nPosVO2 := VO2->(RecNo()) , nIndVO2 := VO2->(IndexOrd())
Local nPosVO3 := VO3->(RecNo()) , nIndVO3 := VO3->(IndexOrd())
Local nPosPecOrc

Default cSeqInc := ""

DbSelectArea("VO2")
DbSetOrder(1)
DbSeek( xFilial("VO2") + VO1->VO1_NUMOSV )

Do While !Eof() .and. VO2->VO2_FILIAL == xFilial("VO2") .And. VO2->VO2_NUMOSV == VO1->VO1_NUMOSV

	DbSelectArea("VO3")
	DbSetOrder(2)
	If DbSeek( xFilial("VO3") + cGruIte + cCodIte + VO2->VO2_NOSNUM + cTipTem )

		aCols[ n , FG_POSVAR("VO3_FORMUL") ] := M->VO3_FORMUL := VO3->VO3_FORMUL

		lRet := .f.
		Exit

	EndIf

	DbSelectArea("VO2")
	DbSkip()

EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se a peca veio do orcamento, se vier nao deixa alterar a formulaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRet .and. Type("aPecaOrc") # "U" .And. Len(aPecaOrc) # 0
	if lInconveniente
		nPosPecOrc := Ascan( aPecaOrc , { |x| x[1] .and. x[6] == cGruIte .and. x[7] == cCodIte .and. x[20] == cSeqInc } )
	else
		nPosPecOrc := Ascan( aPecaOrc , { |x| x[1] .and. x[6] == cGruIte .and. x[7] == cCodIte } )
	endif

	if nPosPecOrc > 0
		aCols[ n , FG_POSVAR("VO3_FORMUL") ] := M->VO3_FORMUL := aPecaOrc[nPosPecOrc,22]

		lRet := .f.
	endif

EndIf

DbSelectArea("VO2")
DbSetOrder(nIndVO2)
DbGoTo(nPosVO2)
DbSelectArea("VO3")
DbSetOrder(nIndVO3)
DbGoTo(nPosVO3)
DbSelectArea(cAliasOld)

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_020INTGบAutor  ณFabio               บ Data ณ  05/16/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInforma o departamento da garantia e interno                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_020INTGAR(cNumOsv,cTipTem)

Local cSelect:=Alias(),nPosVO2:=VO2->(Recno()),nIndVO2:=VO2->(IndexOrd()),;
nPosVO3:=VO3->(Recno()),nIndVO3:=VO3->(IndexOrd()),;
nPosVO4:=VO4->(Recno()),nIndVO4:=VO4->(IndexOrd())
Local lReturn := .t.
Local cDepInt, cDepGar
Local nPosAcols

cNumOsv := If(cNumOsv#NIL,cNumOsv,VO1->VO1_NUMOSV)
cTipTem := If(cTipTem#NIL,cTipTem,M->VO3_TIPTEM)

If cReqDev == "1"

	if ReadVar() == "M->VO3_DEPINT"
		cDepInt := M->VO3_DEPINT
	else
		M->VO3_DEPINT := cDepInt := Space(VO3->(TamSX3("VO3_DEPINT")[1]))
		if INCLUI
			aCols[n,FG_POSVAR("VO3_DEPINT")] := Space(VO3->(TamSX3("VO3_DEPINT")[1]))
		endif
	endif
	if ReadVar() == "M->VO3_DEPGAR"
		cDepGar := M->VO3_DEPGAR
	else
		M->VO3_DEPGAR := cDepGar := Space(VO3->(TamSX3("VO3_DEPGAR")[1]))
		if INCLUI
			aCols[n,FG_POSVAR("VO3_DEPGAR")] := Space(VO3->(TamSX3("VO3_DEPGAR")[1]))
		endif
	endif
	VO2->(DbSetOrder(1))
	VO2->(DbSeek(xFilial("VO2")+cNumOsv))
	VOI->(DbSetOrder(1))
	VOI->(DbSeek(xFilial("VOI")+cTipTem))
	VO3->(DbSetOrder(8))
	VO4->(DbSetOrder(10))
//	If VO3->(DbSeek(xFilial("VO3")+VO2->VO2_NOSNUM+cTipTem )) .Or. VO4->(DbSeek(xFilial("VO4")+VO2->VO2_NOSNUM+cTipTem ))
	If VO3->(DbSeek(xFilial("VO3")+cNumOsv+cTipTem )) .Or. VO4->(DbSeek(xFilial("VO4")+cNumOsv+cTipTem ))

		If VOI->VOI_DEPINT == "1" // Tipo de Tempo 3=Interno
			// Inicializa Departamento Interno
			If ReadVar() <> 'M->VO3_DEPINT'
				If Empty(M->VO3_DEPINT)
					M->VO3_DEPINT := If(VO3->(Found()),VO3->VO3_DEPINT,If(VO4->(Found()),VO4->VO4_DEPINT,""))
					if Type("aCols") # "U"
						aCols[n,FG_POSVAR("VO3_DEPINT")] := M->VO3_DEPINT
					endif
				EndIf
			Else
				cDepInt := If(VO3->(Found()),VO3->VO3_DEPINT,If(VO4->(Found()),VO4->VO4_DEPINT,""))
			EndIf
		ElseIf VOI->VOI_DEPGAR == "1" // Tipo de Tempo Garantia
			// Inicializa Departamento Garantia
			If ReadVar() <> 'M->VO3_DEPGAR'
			 	If Empty(M->VO3_DEPGAR)
					M->VO3_DEPGAR := If(VO3->(Found()),VO3->VO3_DEPGAR,If(VO4->(Found()),VO4->VO4_DEPGAR,""))
					if Type("aCols") # "U"
						aCols[n,FG_POSVAR("VO3_DEPGAR")] := M->VO3_DEPGAR
					Endif
				endif
			Else
				cDepGar := If(VO3->(Found()),VO3->VO3_DEPGAR,If(VO4->(Found()),VO4->VO4_DEPGAR,""))
			EndIf
		EndIf
		If ReadVar() == 'M->VO3_DEPINT' .Or. ReadVar() == 'M->VO3_DEPGAR'
			if (M->VO3_DEPINT <> cDepInt .and. !Empty(cDepInt)) .or. ;
				(M->VO3_DEPGAR <> cDepGar .and. !Empty(cDepGar))
				lReturn := .f.
			endif
		EndIf
	EndIf

	If Type("aCols") # "U"
		For nPosACols := 1 to Len(aCols)
			If n <> nPosACols .and. aCols[nPosACols,FG_POSVAR("VO3_TIPTEM")] == cTipTem
				cDepInt := aCols[nPosACols,FG_POSVAR("VO3_DEPINT")]
				cDepGar := aCols[nPosACols,FG_POSVAR("VO3_DEPGAR")]
				If (ReadVar() == 'M->VO3_DEPINT' .Or. ReadVar() == 'M->VO3_DEPGAR')
					if (M->VO3_DEPINT <> cDepInt .and. !Empty(cDepInt)) .or. ;
						(M->VO3_DEPGAR <> cDepGar .and. !Empty(cDepGar))
						lReturn := .f.
					endif
				endif
				If ReadVar() == 'M->VO3_TIPTEM'
					aCols[n,FG_POSVAR("VO3_DEPINT")] := If(nPosaCols # 0,aCols[nPosaCols,FG_POSVAR("VO3_DEPINT")],M->VO3_DEPINT)
					aCols[n,FG_POSVAR("VO3_DEPGAR")] := If(nPosaCols # 0,aCols[nPosaCols,FG_POSVAR("VO3_DEPGAR")],M->VO3_DEPGAR)
				EndIf
			EndIf
		Next nPosACols
	EndIf

	If !lReturn
		Help(" ",1,"DEPINTGAR")
	EndIf

EndIf

VO2->(DbSetOrder(nIndVO2))
VO2->(DbGoTo(nPosVO2))
VO3->(DbSetOrder(nIndVO3))
VO3->(DbGoTo(nPosVO3))
VO4->(DbSetOrder(nIndVO4))
VO4->(DbGoTo(nPosVO4))
DbSelectArea(cSelect)

Return(lReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_REPPRO บAutor  ณMicrosiga           บ Data ณ  01/08/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Repete o produtivo da linha anterior da aCols              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_REPPRO()

If GetMv("MV_REPPRO") # "S"
	Return
EndIf

If n#1 .and. Empty(aCols[n,FG_POSVAR("VO3_PROREQ")])
	aCols[n,FG_POSVAR("VO3_PROREQ")]:=M->VO3_PROREQ := aCols[n-1,FG_POSVAR("VO3_PROREQ")]
EndIf

oGetReqPec:oBrowse:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_REPPROOบAutor  ณFabio               บ Data ณ  01/11/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRepete o produtivo do orcamento                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ OFICINA                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_REPPROORC()

Local nRepOrc:=0

If Type("aPecaOrc") # "U" .And. Len(aPecaOrc) # 0

	If Ascan(aPecaOrc,{|x| x[6]+x[7] == M->VO3_GRUITE+M->VO3_CODITE .And. x[1] == .t. }) # 0

		For nRepOrc:=1 to Len(aCols)

			If Empty(aCols[nRepOrc,FG_POSVAR("VO3_PROREQ")]) .And. Ascan(aPecaOrc,{|x| x[6]+x[7] == aCols[nRepOrc,FG_POSVAR("VO3_GRUITE")]+aCols[nRepOrc,FG_POSVAR("VO3_CODITE")] .And. x[1] == .t. }) # 0
				aCols[nRepOrc,FG_POSVAR("VO3_PROREQ")] := M->VO3_PROREQ
			EndIf

		Next

	EndIf

EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM020DUPITE       ณRicardo Farinelli   บ Data ณ  17/09/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o local de origem/localizacao nao eh igual ao   บฑฑ
ฑฑบ          ณlocal de destino/localizacao                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function OM020DUPITE(aItens,lRetorno)
Local lRet := .T.
Local nwnk := 0
Default lRetorno := .F.
For nwnk := 1 to Len(aItens)
	If nwnk > 1
		If aItens[nwnk,1] == aItens[nwnk,6] .and.;
			aItens[nwnk,4] == aItens[nwnk,9] .and.;
			aItens[nwnk,5] == aItens[nwnk,10].and. lRetorno == .F.
			Help(" ",1,"LOCALDUP")
			lRet := .f.
		Endif
	Endif
Next
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_D3NUMDOC บAutor  ณMicrosiga        บ Data ณ  07/26/02   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera um numero de documento para a movimentacao de estoque บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_D3NUMDOC()

Local cNumDoc := ""
Local aAreaAnt := GetArea()
Local aAreaSD3 := SD3->(GetArea())

cNumDoc := nextnumero("SD3",2,"D3_DOC",.t.)

DbSelectArea('SD3')
DbSetOrder(2)
If Empty(cNumDoc) .Or. DbSeek( xFilial("SD3")+cNumDoc ) .Or. Upper(SubStr(cNumDoc,1,5)) == 'INVEN'

	DbSeek(xFilial("SD3")+"INVEN",.T.)
	DbSkip(-1)

	cNumDoc := Soma1(SD3->D3_DOC)

EndIf

RestArea(aAreaSD3)
RestArea(aAreaAnt)

Return(cNumDoc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TPLIBFEบAutor  ณFabio               บ Data ณ  02/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se o tempo foi liberado, fechado ou cancelado        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_TPLIBFEC(cNumOsv,cTipTem)

If (    ( Type("M->VO3_TIPTEM") # "U" .And. cTipTem # M->VO3_TIPTEM .And. !FS_VALTPORC(cTipTem) ) ;
	.Or. ( Type("M->VO4_TIPTEM") # "U" .And. cTipTem # M->VO4_TIPTEM .And. !FS_VALTPORC(cTipTem) ) )

	Return(.f.)

EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALTPORบAutor  ณFabio               บ Data ณ  01/27/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida tipo de tempo do orcamento                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VALTPORC(cTipTem,cNumOsv)

Local aArea := {}
Local lRet := .t.

Default cNumOsv := VO1->VO1_NUMOSV

aArea := sGetArea(aArea , "VOI")

If !(FWIsInCallStack("OFNJD15AOS"))
	//DbSelectArea("VOI")
	VOI->(DbSetOrder(1))
	VOI->(MsSeek( xFilial("VOI") + cTipTem ))
	If VOI->VOI_BLQORC == "1"
			If VOI->(FieldPos("VOI_VLPERE")) > 0 .AND. VOI->VOI_VLPERE == 0
			Help("  ",1,"OF020BQO",,,4,1)
			lRet := .f.
			Endif
	EndIf
EndIf
sRestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALTPABบAutor  ณFabio               บ Data ณ  04/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se tem outra OS com o mesmo tipo de tempo aberto paraบฑฑ
ฑฑบ          ณo veiculo                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VALTPABE(cChassi,cTipTem,cNumOsv)

Local aArea := {}

If GetNewPar("MV_VTPABE","N")=="S"

	aArea := sGetArea(aArea , Alias())
	aArea := sGetArea(aArea , "VV1")
	aArea := sGetArea(aArea , "VO1")
	aArea := sGetArea(aArea , "VO2")
	aArea := sGetArea(aArea , "VO3")
	aArea := sGetArea(aArea , "VO4")

	DbSelectArea("VV1")
	DbSetOrder(2)
	DbSeek( xFilial("VV1") + cChassi )

	DbSelectArea("VO1")
	DbSetOrder(8)
	DbSeek( xFilial("VO1") + cChassi )

	Do While !Eof() .And. VO1->VO1_FILIAL+VO1->VO1_CHASSI == xFilial("VO1") + cChassi

		If VO1->VO1_NUMOSV #	cNumOsv

			DbSelectArea("VO2")
			DbSetOrder(1)
			DbSeek( xFilial("VO2") + VO1->VO1_NUMOSV )

			Do While !Eof() .And. VO2->VO2_FILIAL+VO2->VO2_NUMOSV == xFilial("VO2")+VO1->VO1_NUMOSV

				DbSelectArea("VO3")
				DbSetOrder(1)
				DbSeek( xFilial("VO3") + VO2->VO2_NOSNUM + cTipTem )

				If Found() .And. ( Empty(VO3->VO3_DATCAN) .And. Empty(VO3->VO3_DATDIS) .And. Empty(VO3->VO3_DATFEC) )

					Help("  ",1,"VALTPABE",,(STR0081+Chr(13)+STR0082+VO1->VO1_NUMOSV ),4,1)
					sRestArea(aArea)

					Return(.f.)

				EndIf

				DbSelectArea("VO4")
				DbSetOrder(1)
				DbSeek( xFilial("VO4") + VO2->VO2_NOSNUM + cTipTem )

				If Found() .And. ( Empty(VO4->VO4_DATCAN) .And. Empty(VO4->VO4_DATDIS) .And. Empty(VO4->VO4_DATFEC) )

					Help("  ",1,"VALTPABE",,(STR0081+Chr(13)+STR0082+VO1->VO1_NUMOSV ),4,1)
					sRestArea(aArea)

					Return(.f.)

				EndIf

				DbSelectArea("VO2")
				DbSkip()

			EndDo

		EndIf

		DbSelectArea("VO1")
		DbSkip()

	EndDo

	sRestArea(aArea)

EndIf

Return(.t.)

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณOM020LEG   ณ Autor ณ Fabio                ณ Data ณ 16/02/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria uma janela contendo a legenda da mBrowse              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณofiom020                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM020LEG(nReg)

Local uRetorno  := .t.
Local aLegenda  := {{ 'BR_VERDE'   , STR0089 },; // Aberta
					{ 'BR_AZUL'    , STR0090 },; // Liberada
					{ 'BR_VERMELHO', STR0091 },; // Fechado
					{ 'BR_PRETO'   , STR0092 }}  // Cancelado

// Pontos de Entrada para incluir tipos para legenda
If (ExistBlock("OM020CLG"))
	aLegenda := ExecBlock("OM020CLG", .f., .f., {aLegenda})
EndIf

If nReg == NIL // Chamada direta da fun็ใo onde nใo passa, via menu Recno ้ passado
	uRetorno := {}

	AADD(uRetorno, { 'VO1->VO1_STATUS == "A"', aLegenda[1,1], aLegenda[1,2] }) // Aberta
	AADD(uRetorno, { 'VO1->VO1_STATUS == "D"', aLegenda[2,1], aLegenda[2,2] }) // Liberada
	AADD(uRetorno, { 'VO1->VO1_STATUS == "F"', aLegenda[3,1], aLegenda[3,2] }) // Fechado
	AADD(uRetorno, { 'VO1->VO1_STATUS == "C"', aLegenda[4,1], aLegenda[4,2] }) // Cancelado

 	If (ExistBlock("OM020COR"))
		uRetorno := ExecBlock("OM020COR", .f., .f., {uRetorno, aLegenda})
	EndIf
Else
	BrwLegenda(cCadastro, STR0093, aLegenda) //STR0088
EndIf

Return uRetorno

Static Function MenuDef()
	Local aRotina := {}
	// NAO MUDAR ORDEM POIS PODE PARA DE FUNCIONAR ROTINA COMO EXECAUTO
	aAdd(aRotina,{STR0002 ,"axPesqui" , 0 , 1})  // Pesquisar
	aAdd(aRotina,{ STR0003 ,"OM020"   , 0 , 3})  // Requisitar
	aAdd(aRotina,{ STR0004 ,"OM020"   , 0 , 6})    // Devolucao
	aAdd(aRotina,{ STR0296 ,"OM0200131_Requisitar_Pecas_de_outras_OSs", 0 , 4}) // Requisitar Pe็as de outras OSs
	aAdd(aRotina,{ STR0005 ,"OM020A"  , 0 , 4})   // Alterar
	aAdd(aRotina,{ STR0162 ,"OM020REM", 0 , 4}) // "Rem. Atend. Externo"
	aAdd(aRotina,{ STR0163 ,"OM020RET", 0 , 4}) // "Ret. Rem. Atend. Ext."
	aAdd(aRotina,{ STR0197 ,"OM020CAN", 0 , 4}) // "Canc.NF Rem. Atend. Ext."
	aAdd(aRotina,{ STR0262 ,"OM020001_CancNFRetRem", 0 , 4}) // "Canc. NF Retorno Rem. Atend. Ext."
	aAdd(aRotina,{ STR0231 ,"OM020VSJMANUAL", 0 , 4}) // "Pe็as da OS"
	aAdd(aRotina,{ STR0236 ,"OM0200121_ConsultaPecasPendentesOS", 0 , 2}) // "Pe็as Pendentes da OS"
	aAdd(aRotina,{ STR0297 ,"OM0200141_Visualizar_OS()", 0 , 2}) // Visualizar OS
	if funname() == "OFIOM020"
		aAdd(aRotina,{ STR0122 ,"OM020V", 0 , 1})  // Pesq. Avancada.
	EndIf
	aAdd(aRotina,{ STR0275,"OM020HRD" , 0 , 2,0,.f.}) // "Hist๓rico Req/Dev"
	aAdd(aRotina,{ STR0093,"OM020LEG" , 0 , 4,2,.f.}) // Legenda
	aAdd(aRotina,{STR0302 ,"OM0200151_Visualizar_Remessa" , 0 , 1}) // Consulta de Opera็๕es de Pe็as para Remessa
Return aRotina

///  Valid SX3 - OFICINA Atualiza Grupo automaticamente apos funcao FG_POSSB1() - Andre Luis Almeida - 25/01/07  ///
Function FS_OATUGRP()

Local nValPec := 0
aCols[n,FG_POSVAR("VO3_GRUITE")] := M->VO3_GRUITE := SB1->B1_GRUPO
aCols[n,FG_POSVAR("VO3_DESITE")] := M->VO3_DESITE := SB1->B1_DESC
aCols[n,FG_POSVAR("VO3_QTDREQ")] := M->VO3_QTDREQ := 0

/// Verifica Custo dos Itens
//SF4->(dbseek(xFilial("SF4")+M->VS3_CODTES))
cFormul := GETMV("MV_FMLPECA")
nValPec := FG_VALPEC(M->VO3_TIPTEM,cFormul,M->VO3_GRUITE,M->VO3_CODITE,"M->VO3_VALPEC",.f.,.t.)
//If GetNewPar("MV_LIBVAC","N") == "N" //.and. SF4->F4_OPEMOV == "05"  //VENDA
If GetNewPar("MV_LBVACR","S") == "N" //Libera Venda Abaixo do Custo (requisicao)
	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek(xFilial("SB2")+SB1->B1_COD)
	nSdoPecB2 := 0
	While !eof() .and. xFilial("SB2")+SB1->B1_COD == SB2->B2_FILIAL+SB2->B2_COD
		nSdoPecB2 += SB2->B2_QATU
		dbSkip()
	Enddo
	DbSeek(xFilial("SB2")+SB1->B1_COD + OM0200065_ArmazemOrigem( M->VO3_TIPTEM ) )
	If Round(nValPec,2) < Round(SB2->B2_CM1,2) .and. nSdoPecB2 > 0
		MsgStop(STR0112)
		Return .f.
	Endif
Endif

Return(.t.)
//
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VERBLQ3บAutor  ณ                    บ Data ณ  09/17/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se o Produto esta bloqueado                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VERBLQ3()
	local oPeca := DMS_Peca():New()

	if oPeca:Bloqueado(SB1->B1_COD) // mostrar mensagem ้ padrใo sim na funcao
		Return(.f.)
	Endif
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ALTTPREบAutor  ณFabio               บ Data ณ  09/17/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida alteracao do tipo de tempo                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ALTTPREQ()

if ExistBlock("ALTTPREQ")
	Return( ExecBlock("ALTTPREQ",.f.,.f.) )
Endif

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Dev020 บAutor  ณManoel              บ Data ณ  15/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para devolucao de Itens Requisitados                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DEV020()

Local aSizeAut, aObjects
Local lMarcar := .f.

Local lCpoDesconto := .f.
Local nPosAuto
Local nAuxPos

Local oOficina   := DMS_Oficina():New()

Private Get_grupo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Indica se os campos de desconto estao criado ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if VO3->(FieldPos("VO3_VALDES")) <> 0 .and. VO3->(FieldPos("VO3_PERDES")) <> 0 .and. VO3->(FieldPos("VO3_VALLIQ")) <> 0
	lCpoDesconto := .t.
endif

VOI->(dbSetOrder(1))

aIteaDev := OM020007_MatrizDev(VO1->VO1_NUMOSV)

cPesqTT  := Space(Len(VO3->VO3_TIPTEM))
cPesqGrp := Space(Len(SB1->B1_GRUPO))
cPesqCod := Space(Len(SB1->B1_CODITE))
lMarcar  := .f.

DbSelectArea("SB1")
cSlvOrd := IndexOrd()
DbSetOrder(7)

If Len(aIteaDev) > 0

	If !lOM020Auto

		aSizeAut := MsAdvSize(.t.)

		DEFINE MSDIALOG oDlgD TITLE STR0094 From aSizeAut[7],00 to aSizeAut[6],aSizeAut[5] PIXEL of oMainWnd STYLE DS_MODALFRAME //Pecas do Orcamento
		oDlgD:lEscClose := .F.

		aObjects := {}
		AADD( aObjects, { 00, 25, .t. , .f. } ) 		// Parametros de Pesquisa
		AADD( aObjects, { 00, 10, .t. , .t. , .t. } ) 	// Listbox

		aPos := MsObjSize( { aSizeAut[ 1 ] , aSizeAut[ 2 ] ,aSizeAut[ 3 ] , aSizeAut[ 4 ] , 2 , 2 } , aObjects , .t. )

		oGroupPesq := TGroup():New( aPos[1,1],aPos[1,2],aPos[1,3],aPos[1,4], STR0002, oDlgD, /*<nClrFore>*/, /*<nClrBack>*/, .t., /*<.lDesign.>*/ )

		// Construcao do Listbox
		lMarcar := .t.
		oLboxD := TWBrowse():New( aPos[2,1],aPos[2,2],aPos[2,3],aPos[2,4],,,,oDlgD,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oLboxD:SetArray(aIteaDev)
		oLboxD:nAt := 1
		oLboxD:addColumn( TCColumn():New(" "					, { || Iif(aIteaDev[oLboxD:nAt,01],oOk,oNo) } 	,,,,"LEFT",10,.T.,.F.,,,,.F.,) )
		oLboxD:addColumn( TCColumn():New(STR0095				, { || aIteaDev[oLboxD:nAt,02] }			 	,,,,"LEFT",17,.F.,.F.,,,,.F.,) ) // "TT"
		oLboxD:addColumn( TCColumn():New(STR0096				, { || aIteaDev[oLboxD:nAt,03] } 				,,,,"LEFT",30,.F.,.F.,,,,.F.,) ) // "Faturar p/"
		oLboxD:addColumn( TCColumn():New(STR0097				, { || aIteaDev[oLboxD:nAt,04] }				,,,,"LEFT",20,.F.,.F.,,,,.F.,) ) // "Loja"
		oLboxD:addColumn( TCColumn():New(STR0098				, { || aIteaDev[oLboxD:nAt,05] } 				,,,,"LEFT",40,.F.,.F.,,,,.F.,) ) // "Nome"
		If lInconveniente
			oLboxD:addColumn( TCColumn():New(RetTitle("VO3_GRUINC")	, { || aIteaDev[oLboxD:nAt,14] } 				,,,,"LEFT",30,.F.,.F.,,,,.F.,) )
			oLboxD:addColumn( TCColumn():New(RetTitle("VO3_CODINC")	, { || aIteaDev[oLboxD:nAt,15] } 				,,,,"LEFT",40,.F.,.F.,,,,.F.,) )
			oLboxD:addColumn( TCColumn():New(RetTitle("VO3_SEQINC")	, { || aIteaDev[oLboxD:nAt,18] } 				,,,,"LEFT",30,.F.,.F.,,,,.F.,) )
			oLboxD:addColumn( TCColumn():New(RetTitle("VO3_DESINC")	, { || aIteaDev[oLboxD:nAt,16] } 				,,,,"LEFT",50,.F.,.F.,,,,.F.,) )
		EndIf
		oLboxD:addColumn( TCColumn():New(STR0099				, { || aIteaDev[oLboxD:nAt,06] } 				,,,,"LEFT",30,.F.,.F.,,,,.F.,) ) // "Grupo"
		oLboxD:addColumn( TCColumn():New(STR0100				, { || aIteaDev[oLboxD:nAt,07] } 				,,,,"LEFT",50,.F.,.F.,,,,.F.,) ) // "Codigo"
		oLboxD:addColumn( TCColumn():New(STR0101				, { || aIteaDev[oLboxD:nAt,08] } 				,,,,"LEFT",50,.F.,.F.,,,,.F.,) ) // "Descricao"
		oLboxD:addColumn( TCColumn():New(STR0102				, { || Transform(aIteaDev[oLboxD:nAt,09],X3Picture("VO3_QTDREQ")) },,,,"RIGHT",20,.F.,.F.,,,,.F.,) ) // "Quantidade"
		oLboxD:addColumn( TCColumn():New(RetTitle("VO3_CODTES")	, { || aIteaDev[oLboxD:nAt,22] }				,,,,"LEFT",20,.F.,.F.,,,,.F.,) ) // "TES"
		oLboxD:addColumn( TCColumn():New(RetTitle("VO3_VALPEC")	, { || Transform(aIteaDev[oLboxD:nAt,11],X3Picture("VO3_VALPEC")) },,,,"RIGHT",20,.F.,.F.,,,,.F.,) )
		If lCpoDesconto
			oLboxD:addColumn( TCColumn():New(RetTitle("VO3_VALDES")	, { || Transform(aIteaDev[oLboxD:nAt,21]/aIteaDev[oLboxD:nAt,10],X3Picture("VO3_VALDES")) },,,,"RIGHT",20,.F.,.F.,,,,.F.,) )
			oLboxD:addColumn( TCColumn():New(RetTitle("VO3_VALLIQ")	, { || Transform(aIteaDev[oLboxD:nAt,19],X3Picture("VO3_VALLIQ")) },,,,"RIGHT",20,.F.,.F.,,,,.F.,) )
		EndIf
		oLboxD:addColumn( TCColumn():New(RetTitle("VO3_PROREQ")	, { || aIteaDev[oLboxD:nAt,17] } 				,,,,"LEFT",20,.F.,.F.,,,,.F.,) )
		If lCtrlLote
			oLboxD:addColumn( TCColumn():New(RetTitle("VO3_LOTECT"), { || aIteaDev[oLboxD:nAt,23] } 				,,,,"LEFT",20,.F.,.F.,,,,.F.,) ) // "Lote"
			oLboxD:addColumn( TCColumn():New(RetTitle("VO3_NUMLOT"), { || aIteaDev[oLboxD:nAt,24] } 				,,,,"LEFT",30,.F.,.F.,,,,.F.,) ) // "Sub-Lote"
		EndIf
		oLboxD:addColumn( TCColumn():New(RetTitle("VO3_FORMUL"), { || aIteaDev[oLboxD:nAt,12] } 				,,,,"LEFT",30,.F.,.F.,,,,.F.,) ) // "Formula"

		oLboxD:bHeaderClick := { |oObj,nCol| If( nCol == 1 , ( FS_AltLb(1,.t.,lMarcar) , ( lMarcar:=!lMarcar ) ) , ) , oLboxD:Refresh() }
		oLboxD:bLDblClick := { || FS_AltLb(oLboxD:nAt) }
		oLboxD:Refresh()
		//

		@ aPos[1,1]+10,010 SAY STR0067 SIZE 40,10 OF oDlgD PIXEL COLOR CLR_BLUE // "Tipo Tempo"
		@ aPos[1,1]+09,040 MSGET cPesqTT  PICTURE "@!" F3 "VOI" VALID Empty(cPesqTT) .or. !oOficina:TipoTempoBloqueado(cPesqTT,.t.) SIZE 020,1 OF oDlgD PIXEL COLOR CLR_BLACK HASBUTTON

		@ aPos[1,1]+10,090 SAY STR0010 SIZE 40,10 OF oDlgD PIXEL COLOR CLR_BLUE // "Grupo"
		@ aPos[1,1]+09,110 MSGET cPesqGrp PICTURE "@!" F3 "SBM" VALID (Get_grupo:=cPesqGrp, Empty(cPesqGrp) .or. SBM->(DbSeek(xFilial("SBM")+cPesqGrp))  ) SIZE 030,1 OF oDlgD PIXEL COLOR CLR_BLACK HASBUTTON

		@ aPos[1,1]+10,160 SAY STR0011 SIZE 40,10 OF oDlgD PIXEL COLOR CLR_BLUE // "Cod Item"
		@ aPos[1,1]+09,190 MSGET cPesqCod PICTURE "@!" F3 "B11" VALID Empty(cPesqCod) .or. (FG_POSSB1("cPesqCod","SB1->B1_CODITE","cPesqGrp") .and. FS_Atrib020()) .or. Fg_Seek("SB1",'cPesqGrp+cPesqCod',7,.f.) SIZE 080,1 OF oDlgD PIXEL COLOR CLR_BLUE HASBUTTON

		DEFINE SBUTTON FROM aPos[1,1]+09,300 TYPE 1 ACTION FS_ProcIDv(cPesqTT+cPesqGrp+cPesqCod) ENABLE ONSTOP "" OF oDlgD

		ACTIVATE MSDIALOG oDlgD ON INIT EnchoiceBar(oDlgD,{||oDlgD:End()},{|| FS_AltLb(1,.t.,.f.) , oDlgD:End()})
	Else

		For nPosAuto := 1 to Len(aAutoItens)
			nAuxPos := aScan( aAutoItens[nPosAuto] , { |x| x[1] == "VO3_TIPTEM" } )

			If oOficina:TipoTempoBloqueado( aAutoItens[nPosAuto,nAuxPos,2] ,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
				Return .f.
			EndIf

			cCondPesq := "x[02] == '" + aAutoItens[nPosAuto,nAuxPos,2] + "'"

			nAuxPos := aScan( aAutoItens[nPosAuto] , { |x| x[1] == "VO3_GRUITE" } )
			cCondPesq += " .and. x[06] == '" + aAutoItens[nPosAuto,nAuxPos,2] + "'"

			nAuxPos := aScan( aAutoItens[nPosAuto] , { |x| x[1] == "VO3_CODITE" } )
			cCondPesq += " .and. x[07] == '" + aAutoItens[nPosAuto,nAuxPos,2] + "'"

			If lInconveniente
				nAuxPos := aScan( aAutoItens[nPosAuto] , { |x| x[1] == "VO3_SEQINC" } )
				If nAuxPos <> 0
					cCondPesq += " .and. x[18] == '" + aAutoItens[nPosAuto,nAuxPos,2] + "'"
				EndIf
			EndIf

			If VOI->VOI_VLPCAC == "1" // Valor da Peca no fechamento ้ o Valor da Requisicao
				nAuxPos := aScan( aAutoItens[nPosAuto] , { |x| x[1] == "VO3_VALPEC" } )
				If nAuxPos <> 0
					cCondPesq += " .and. x[11] == " + AllTrim(Str(aAutoItens[nPosAuto,nAuxPos,2],15,GetSX3Cache("VO3_VALPEC","X3_DECIMAL")))
				EndIf
				If lCpoDesconto
					nAuxPos := aScan( aAutoItens[nPosAuto] , { |x| x[1] == "VO3_VALLIQ" } )
					If nAuxPos <> 0
						cCondPesq += " .and. x[19] == " + AllTrim(Str(aAutoItens[nPosAuto,nAuxPos,2],15,GetSX3Cache("VO3_VALLIQ","X3_DECIMAL")))
					EndIf
				EndIf
			EndIf

			nAuxPos := aScan( aAutoItens[nPosAuto] , { |x| x[1] == "VO3_FORMUL" } )
			If nAuxPos <> 0
				cCondPesq += " .and. x[12] == '" + aAutoItens[nPosAuto,nAuxPos,2] + "'"
			EndIf

			nAuxPos := aScan( aAutoItens[nPosAuto] , { |x| x[1] == "VO3_CODTES" } )
			If nAuxPos <> 0
				cCondPesq += " .and. x[22] == '" + aAutoItens[nPosAuto,nAuxPos,2] + "'"
			EndIf

			nAuxPos := aScan( aAutoItens[nPosAuto] , { |x| x[1] == "VO3_LOTECT" } )
			If nAuxPos <> 0
				cCondPesq += " .and. x[23] == '" + aAutoItens[nPosAuto,nAuxPos,2] + "'"
			EndIf

			nAuxPos := aScan( aAutoItens[nPosAuto] , { |x| x[1] == "VO3_NUMLOT" } )
			If nAuxPos <> 0
				cCondPesq += " .and. x[24] == '" + aAutoItens[nPosAuto,nAuxPos,2] + "'"
			EndIf

			nPos := aScan(aIteaDev, &( "{|x| " + cCondPesq + " }") )

			// Se encontrar na matriz para devolucao
			If nPos <> 0
				nAuxPos := aScan( aAutoItens[nPosAuto] , { |x| x[1] == "VO3_QTDREQ" } )
				If FS_VldAlt020(aAutoItens[nPosAuto,nAuxPos,2],nPos,.f.)
					FS_AltLb(nPos,,,aAutoItens[nPosAuto,nAuxPos,2])
				Else
					Return .f.
				EndIf
			Else
				Help(" ",1,"REGNOIS",,STR0004 + ": " + cCondPesq ,4,1) // Devolu็ใo
				Return .f.
			EndIf
			//

		Next nPosAuto

	EndIf
else

	MsgStop(STR0103) // Nใo hแ Elementos Requisitados para Devolver ou pe็a foi devolvida

Endif

DbSelectArea("SB1")
DbSetOrder(cSlvOrd)

Return .t.


/////////////////////////////
Static Function FS_Atrib020()

cPesqGrp:=SB1->B1_GRUPO

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AltLb  บAutor  ณManoel              บ Data ณ  15/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para digitacao da quant a ser devolvida na devolucao  บฑฑ
ฑฑบ          ณ de Itens Requisitados                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_AltLb(nReg,lTodos,lMarcar,nAuxQtde)

Local nConteud := aIteaDev[nReg,9]
Local i := 0
local oPeca := DMS_Peca():New()
Local cCodIte, cGrpIte
Local aRet      := {}
Local aParamBox := {}

Local oOficina := DMS_Oficina():New()

Default lMarcar := .f.
Default nAuxQtde := 0

If lTodos

	If lMarcar
		If MsgYesNo(STR0105) // "Deseja realmente Devolver todos os Itens da Requisicao?"
			for i := 1 to Len(aIteaDev)
				cCodIte := aIteaDev[i, PECAORC_CODITE]
				cGrpIte := aIteaDev[i, PECAORC_GRUITE]
				if ! oPeca:Bloqueado(/*cB1Cod*/, cGrpIte, cCodIte) // mostrar mensagem ้ padrใo sim na funcao
					aIteaDev[i,1] := .t.
					aIteaDev[i,9] := aIteaDev[i,10]
				end
			Next
		Else
			lMarcar := .f.
		Endif
	Else
		for i := 1 to Len(aIteaDev)
			cCodIte := aIteaDev[i, PECAORC_CODITE]
			cGrpIte := aIteaDev[i, PECAORC_GRUITE]
			if ! oPeca:Bloqueado(/*cB1Cod*/, cGrpIte, cCodIte) // mostrar mensagem ้ padrใo sim na funcao
				aIteaDev[i,1] := .t.
				aIteaDev[i,9] := aIteaDev[i,10]
			end

			aIteaDev[i,1] := .f.
			aIteaDev[i,9] := 0
		Next
	Endif

Else

	If oOficina:TipoTempoBloqueado( aIteaDev[nReg,PECAORC_TIPTEM] , .t. ) // Valida se Tipo de Tempo esta BLOQUEADO
		Return .f.
	EndIf

	If nAuxQtde == 0
		aAdd(aParamBox,{1,STR0034,aIteaDev[oLboxD:nAt,9],X3Picture("VO3_QTDREQ"),"FS_VldAlt020(MV_PAR01,,.t.)","","",0,.f.}) // Quantidade
		If ParamBox(aParamBox,STR0094,@aRet,,,,,,,,.F.,.F.) // "Devolucao de Pecas"
			nAuxQtde := aRet[1]
		EndIf
	EndIf

	cCodIte := aIteaDev[nReg, PECAORC_CODITE]
	cGrpIte := aIteaDev[nReg, PECAORC_GRUITE]
	if oPeca:Bloqueado(/*cB1Cod*/, cGrpIte, cCodIte) // mostrar mensagem ้ padrใo sim na funcao
		return .F.
	else
		If nAuxQtde <> 0
			nConteud := nAuxQtde
			aIteaDev[nReg,9] := nConteud

			If nConteud == 0
				aIteaDev[nReg,1] := .f.
			Else
				aIteaDev[nReg,1] := .t.
			Endif

			If (aIteaDev[nReg,1] .and. nConteud != aIteaDev[nReg,9])
				aIteaDev[nReg,1] := .t.
			Endif
		EndIf
	end


Endif

If !lOM020Auto
	oLboxD:Refresh()
EndIf

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldAlt020  บAutor  ณManoel          บ Data ณ  15/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela para digitacao da quant a ser devolvida na devolucao  บฑฑ
ฑฑบ          ณ de Itens Requisitados                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VldAlt020(nQtdDev,nAuxPos,lVldPE)

Default nAuxPos := oLboxD:nAt
Default lVldPE  := .f.

If nQtdDev > aIteaDev[nAuxPos,10]
	Help("  ",1,"M020DEVQTDE",,STR0154 + ": " + transform(aIteaDev[nAuxPos,10],"@E 99999") ,4,1) // Saldo
	return .f.
Endif
If lVldPE .and. ExistBlock("OM020VDV") // ( Tipo de Tempo , Grupo do Item , Codigo do Item , Qtd.Requisitada , Qtd.Devolver )
	If !ExecBlock("OM020VDV",.f.,.f.,{ aIteaDev[nAuxPos,2] , aIteaDev[nAuxPos,6] , aIteaDev[nAuxPos,7] , aIteaDev[nAuxPos,10] , nQtdDev })
		return .f.
	EndIf
EndIf

return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ProcIDv    บAutor  ณManoel          บ Data ณ  17/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Procura Items para Devolver                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_ProcIDv(cChave)
Local nPos

nPos := aScan(aIteaDev,{|x| x[2]+x[6]+x[7] == cChave })
If nPos == 0
	nPos := 1
Endif
oLboxD:nAt := nPos

oLboxD:Refresh()

return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VALREQ020  บAutor ณ Rubens Takahashi   บ Data ณ  11/03/09  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao criada para validar o campo VO3_QTDREQ              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VALREQ020()
Local lRetorno := .f.
Local lVO3CODVSJ := (VO3->(FieldPos("VO3_CODVSJ")) <> 0)

IF M->VO3_QTDREQ > 0 .and. FS_QTDDISP(M->VO3_GRUITE,M->VO3_CODITE,M->VO3_QTDREQ,.T.,M->VO3_FATPAR+M->VO3_LOJA,,,,,M->VO3_SEQINC,M->VO3_CODTES,,,,IIf(lVO3CODVSJ,M->VO3_CODVSJ,Nil))
	lRetorno := .t.
ENDIF

If lRetorno
	lRetorno := VALPMOD020( M->VO3_GRUITE , M->VO3_CODITE )
EndIF

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณREQFRA020 บAutor  ณ Rubens Takahashi   บ Data ณ  05/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Requisicao do valor de franquia de pecas                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function REQFRA020(cNumOsv,cTTSegur)


Local cTTFranquia // Tipo de Tempo de Franquia
Local nValFra // Valor ja lancado como Franquia
Local aArea := {}
Local cQuery := ""

Local oOficina   := DMS_Oficina():New()

Private cCodCliente, cLojCliente, cNomCliente

// -----------------------------------------
// ARMAZENA AREAS PARA RESTAURACAO POSTERIOR
// -----------------------------------------
aArea := sGetArea(aArea,"VO2")
aArea := sGetArea(aArea,"VOI")
aArea := sGetArea(aArea,"VO3")
aArea := sGetArea(aArea,"SB1")
aArea := sGetArea(aArea,"VO1")
If !Empty(Alias())
	aArea := sGetArea(aArea,Alias())
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Posiciona na OS e verifica se existe franquia de PECAS ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
VO1->(dbSetOrder(1))
IF !VO1->(dbSeek(xFilial("VO1") + cNumOsv))
	sRestArea(aArea)
	Help(" ",1,"REGNOIS",,RetTitle("VO1_NUMOSV") + ": " + cNumOsv ,4,1)
	Return .f.
ENDIF

// Nao foi implementado funcionalidade de franquia especifica de pecas
// OU nao foi informado franquia de PECAS ...
IF VO1->(FieldPos("VO1_FRANQP")) == 0 .or. VO1->VO1_FRANQP <= 0
	sRestArea(aArea)
	Return .t.
ENDIF
//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ A partir do TT de Seguradora, procura o TT de Franquia ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If oOficina:TipoTempoBloqueado(cTTSegur,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
	sRestArea(aArea)
	Return .f.
endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se o TT de Franquia esta cadatrado ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTTFranquia := VOI->VOI_TIPFRA
If oOficina:TipoTempoBloqueado(cTTFranquia,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
	sRestArea(aArea)
	Return .f.
endif
//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se ja foi gerado a requisicao de Franquia ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery := "SUM(VO3_VALPEC) "
cQuery +=  " FROM " + RetSQLName("VO2") + " VO2 JOIN " + RetSQLName("VO3") + " VO3 ON VO3.VO3_FILIAL = VO2.VO2_FILIAL AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM AND VO3.D_E_L_E_T_ = ' '"
cQuery += " WHERE VO2.VO2_FILIAL = '" + xFilial("VO2") + "'"
cQuery +=   " AND VO2.VO2_NUMOSV = '" + cNumOsv + "'"
cQuery +=   " AND VO2.VO2_TIPREQ = 'P'"
cQuery +=   " AND VO2.D_E_L_E_T_ = ' '"
cQuery +=   " AND VO3.VO3_TIPTEM = '" + cTTFranquia + "'"
nValFra := FM_SQL(cQuery)
if nValFra > 0
	sRestArea(aArea)
	Return .t.
endif
//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Validacao do Produto Informado no TT de Franquia ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SB1->(DbSetOrder(7))
if !SB1->(DbSeek(xFilial("SB1")+VOI->VOI_GRUITE+VOI->VOI_CODITE))
	sRestArea(aArea)
	Help(" ",1,"REGNOIS",,RetTitle("VOI_GRUITE") + ": " + VOI->VOI_GRUITE + CHR(13) + CHR(10) + RetTitle("VOI_CODITE") + ": " + AllTrim(VOI->VOI_CODITE),4,1)
	Return .f.
endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Procura Cliente de Faturar Para ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cCodCliente := ""
cLojCliente := ""
cNomCliente := ""
FG_TIPTPFAT(cTTFranquia,"cCodCliente","cLojCliente","cNomCliente",VO1->VO1_CODMAR,"P",cNumOsv,.f.,.f.,.f.)
//
RegToMemory("VO2",.T.)

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VO2")
While !Eof().and.(x3_arquivo=="VO2")
	If !Alltrim(x3_campo) $ "VO2_NOSNUM"
		&( "M->"+Alltrim(SX3->x3_campo) ) := CriaVar(SX3->x3_campo)
	EndIf
	dbSkip()
End
//

M->VO2_NUMOSV := cNumOsv

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Gera um Nosso Numero Requisicao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("VO2")
DbSetOrder(2)
Do While Empty(M->VO2_NOSNUM) .Or. DbSeek( xFilial("VO2")+M->VO2_NOSNUM )
	M->VO2_NOSNUM := GetSxeNum("VO2","VO2_NOSNUM",,2)
	ConfirmSx8()
EndDo
DbSelectArea("VO2")
DbSetOrder(1)
If !RecLock("VO2",.T.)
	sRestArea(aArea)
	Help("  ",1,"REGNLOCK")
	Return .f.
EndIf

M->VO2_DATREQ := dDataBase
M->VO2_HORREQ := val(left(time(),2)+substr(time(),4,2))

FG_GRAVAR("VO2")
VO2->VO2_DEVOLU := "1"
VO2->VO2_TIPREQ := "P"
MsUnlock()

cCampos := "VO3_DESGRU/VO3_DEPOSV/VO3_NUMNFI/VO3_SERNFI/VO3_DATFEC/VO3_HORFEC/VO3_DATDIS/VO3_HORDIS/VO3_FUNFEC/VO3_NOSNUM/VO3_PECINT/VO3_DESTEM/VO3_PERDES/VO3_VALDES/VO3_VALGRU/VO3_VALBRU/VO3_ALQICM/VO3_VALICM/VO3_DATCAN/VO3_HORCAN/VO3_CONSRV/VO3_NUMDOC/VO3_CENCUS/VO3_CONTA/VO3_ITEMCT/VO3_CLVL"
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VO3")
While !Eof().And.(x3_arquivo=="VO3")
	If X3USO(x3_usado) .And. cNivel>= x3_nivel .And. (Alltrim(x3_campo) $ cCampos)
		&( "M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
	Endif
	DbSkip()
End
//

DbSelectArea("VO3")
DbSetOrder(1)
RecLock("VO3",.T.)
FG_GRAVAR("VO3")

VO3->VO3_FILIAL := xFilial("VO3")
VO3->VO3_NOSNUM := VO2->VO2_NOSNUM
VO3->VO3_NUMOSV := VO2->VO2_NUMOSV
VO3->VO3_TIPTEM := cTTFranquia
VO3->VO3_FATPAR := cCodCliente
VO3->VO3_LOJA   := cLojCliente
VO3->VO3_GRUITE := VOI->VOI_GRUITE
VO3->VO3_CODITE := VOI->VOI_CODITE
VO3->VO3_PECINT := SB1->B1_COD
VO3->VO3_QTDREQ := 1	// Nao tem quantidade, pois nao movimentara estoque
VO3->VO3_PROREQ := VO2->VO2_FUNREQ
VO3->VO3_CODTES := VOI->VOI_TESFRP
VO3->VO3_VALPEC := VO1->VO1_FRANQP // Franquia de Pecas
MsUnlock()

sRestArea(aArea)

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_BLQCPO บAutor ณ Rubens Takahashi   บ Data ณ  11/08/09   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Habilita ou Desabilita campos da GetDados se a peca requi- บฑฑ
ฑฑบ          ณ sitada tiver sido importada de um orcamento                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ cGruIte = Grupo do Item                                    บฑฑ
ฑฑบ          ณ cCodIte = Codigo do Item                                   บฑฑ
ฑฑบ          ณ cSeqInc = Sequencia do Inconveniente                       บฑฑ
ฑฑบ          ณ lInconveniente = Utiliza Inconveniente ?                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_BLQCPO(cGruIte, cCodIte, cSeqInc, lInconveniente)

Local nAuxPos := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณExiste peca que pode ser importada do Orcamentoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If VO3->(FieldPos("VO3_IMPORC")) <> 0 .and. M->VO3_IMPORC == "1"
	nAuxPos := 1
Else
	If Type("aPecaOrc") # "U" .And. Len(aPecaOrc) # 0
		if lInconveniente
			nAuxPos :=Ascan(aPecaOrc,{|x| x[1] == .t. .And. x[6]+x[7] == cGruIte + cCodIte .And. x[20] == cSeqInc})
		else
			nAuxPos :=Ascan(aPecaOrc,{|x| x[1] == .t. .And. x[6]+x[7] == cGruIte + cCodIte })
		EndIf
	EndIf
EndIf

if nAuxPos == 0
	oGetReqPec:aAlter := oGetReqPec:oBrowse:aAlter := aClone(aAlterMan)
else
	oGetReqPec:aAlter := oGetReqPec:oBrowse:aAlter := aClone(aAlterOrc)
endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ FS_DELLINHA บAutor ณ Rubens Takahashi   บ Data ณ 13/08/09  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se pode excluir a linha da GetDados               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DELLINHA()

Local nPosCODITE

IF FG_POSVAR("VO3_IMPORC") <> 0
	If aCols[n,FG_POSVAR("VO3_IMPORC")] == "1"
		if aCols[n,Len(aCols[n])]
			MsgAlert(STR0125) // "Peca nao pode voltar a requisicao, pois estแ sendo importada de um orcamento"
		else
			MsgAlert(STR0126) // "Peca nao pode ser excluida, pois estแ sendo importada de um orcamento"
		endif
		Return
	Endif
EndIf

// Se estiver voltando a linha ...
if aCols[n,Len(aCols[n])]
	if GetNewPar("MV_INCORC","N") == "S"
		nPosCODITE := Ascan(aCols,{|x| x[FG_POSVAR("VO3_GRUITE")]+x[FG_POSVAR("VO3_CODITE")]+x[FG_POSVAR("VO3_SEQINC")] == M->VO3_GRUITE+M->VO3_CODITE+M->VO3_SEQINC .and. x[Len(x)] == .f. })
	else
		nPosCODITE := Ascan(aCols,{|x| x[FG_POSVAR("VO3_GRUITE")]+x[FG_POSVAR("VO3_CODITE")] == M->VO3_GRUITE+M->VO3_CODITE .and. x[Len(x)] == .f. })
	endif
	If nPosCODITE # 0 .And. nPosCODITE#n
//		Help(" ",1,"EXISTCHAV",, aCols[nPosCODITE,FG_POSVAR("VO3_GRUITE")]+" "+aCols[nPosCODITE,FG_POSVAR("VO3_CODITE")] ,4,1)
//		Return(.f.)
	EndIf
EndIf
//

aCols[n,Len(aCols[n])] := !aCols[n,Len(aCols[n])]

FS_TOTAL()

oGetReqPec:oBrowse:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVALPMOD020 บAutor  ณ Rafael goncalves  บ Data ณ  06/10/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para validar se a quantidade informada do item      บฑฑ
ฑฑบ          ณ solicitado nao ultrapassa a maxima permitida por modelo.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ cCodIte = Codigo do Item                                   บฑฑ
ฑฑบ          ณ cGruIte = Grupo do Item                                    บฑฑ
ฑฑบ          ณ nQtdReq = Quantidade Requisitada(importacar orcamento)     บฑฑ
ฑฑบ          ณ cMoment = 1-valid campo/2-importacao orcamento             บฑฑ
ฑฑบ          ณ cChamada= 0=OS / 1=Orcamento                               บฑฑ
ฑฑบ          ณ cNumOrc = numero do Orcamento                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VALPMOD020( cGruIte , cCodIte , nQtdReq, cMoment, cChamada , cNumOrc)
Local cCodMar := ""
Local cModVei := ""
Local cSeqMod := ""
Local cQuery  := ""
Local cQAlVO3 := "SQLVO3" // VO3
Local cQAlVZZ := "SQLVZZ" // VZZ
Local lRet := .t.
Local nQtdIte := 0
Local cChaint := ""
Local cCodAgm := ""

Default cGruIte := M->VO3_GRUITE
Default cCodIte := M->VO3_CODITE
Default cMoment := "1"//chamada ao informar a quatnidade. valid do campo VO3 ou VS3
Default nQtdReq := 0
default cChamada := "0"//Ordem de servico.
default cNumOrc  := " "//Numero do Orcamento.


If cChamada == "0"//Ordem de servico.
	cChaint := VO1->VO1_CHAINT
ElseIf cChamada == "1"//Orcamento
	cChaint := M->VS1_CHAINT
EndIF

dbSelectArea("SX2")
dbSetOrder(1)
lAchou := dbSeek("VZZ")
DbSelectArea("VV1")
DbSetOrder(1)
If DbSeek( xFilial("VV1") + cChaint )
	DbSelectArea("VV2")
	DbSetOrder(1)
	IF DbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI )
		cCodMar := VV2->VV2_CODMAR
		cModVei := VV2->VV2_MODVEI
		cSeqMod := VV2->VV2_SEGMOD
		if lAchou
			if VZZ->(FieldPos("VZZ_CODAGM")) > 0
				cCodAgm := VV2->VV2_CODAGM
			endif
		Endif
	EndIF
EndIf
if lAchou
	If VZZ->(FieldPos("VZZ_CODAGM")) <> 0 .and. !Empty(cCodAgm)//utiliza a tabale de maxima do componente por modelo
		If cChamada == "0"//Ordem de servico.
			cQuery := "SELECT SUM(VO3.VO3_QTDREQ) AS QTDREQ FROM "+RetSqlName("VO3")+" VO3 "
			cQuery += "INNER JOIN "+RetSqlName("VO2")+" VO2 ON (VO2.VO2_FILIAL='"+xFilial("VO2")+"' AND VO2.VO2_DEVOLU='1' AND VO2.VO2_NOSNUM=VO3.VO3_NOSNUM AND VO2.D_E_L_E_T_=' ' ) "
			cQuery += "INNER JOIN "+RetSqlName("VO1")+" VO1 ON (VO1.VO1_FILIAL='"+xFilial("VO1")+"' AND VO1.VO1_NUMOSV=VO2.VO2_NUMOSV AND VO1.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE VO1.VO1_CHAINT='"+cChaint+"' AND (VO3.VO3_GRUITE='"+cGruIte+"' OR VO3.VO3_GRUITE='"+Space(Len(VO3->VO3_GRUITE))+"') AND VO3.VO3_CODITE='"+cCodIte+"' "

			If (GetNewPar("MV_VERQTCC","1") == "1") //1 somente os atual / 2 todas os do veiculo
				cQuery += "AND VO3.VO3_NUMOSV='"+VO1->VO1_NUMOSV+"' "
			EndIF

			cQuery += "AND VO1.VO1_STATUS NOT IN ('C','F') AND VO3.D_E_L_E_T_=' '"

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVO3 , .F., .T. )
			IF !( cQAlVO3 )->( Eof() )
				nQtdReq += ( cQAlVO3 )->( QTDREQ )
			EndIF
			( cQAlVO3 )->( dbCloseArea() )

			cQuery := "SELECT SUM(VO3.VO3_QTDREQ) AS QTDREQ FROM "+RetSqlName("VO3")+" VO3 "
			cQuery += "INNER JOIN "+RetSqlName("VO2")+" VO2 ON (VO2.VO2_FILIAL='"+xFilial("VO2")+"' AND VO2.VO2_DEVOLU='0' AND VO2.VO2_NOSNUM=VO3.VO3_NOSNUM AND VO2.D_E_L_E_T_=' ' ) "
			cQuery += "INNER JOIN "+RetSqlName("VO1")+" VO1 ON (VO1.VO1_FILIAL='"+xFilial("VO1")+"' AND VO1.VO1_NUMOSV=VO2.VO2_NUMOSV AND VO1.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE VO1.VO1_CHAINT='"+cChaint+"' AND (VO3.VO3_GRUITE='"+cGruIte+"' OR VO3.VO3_GRUITE='"+Space(Len(VO3->VO3_GRUITE))+"') AND VO3.VO3_CODITE='"+cCodIte+"' "

			If (GetNewPar("MV_VERQTCC","1") == "1") //1 somente os atual / 2 todas os do veiculo
				cQuery += "AND VO3.VO3_NUMOSV='"+VO1->VO1_NUMOSV+"' "
			EndIF

			cQuery += "AND VO1.VO1_STATUS NOT IN ('C','F') AND VO3.D_E_L_E_T_=' '"

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVO3 , .F., .T. )
			IF !( cQAlVO3 )->( Eof() )
				nQtdReq -= ( cQAlVO3 )->( QTDREQ )
			EndIF
			( cQAlVO3 )->( dbCloseArea() )


		Elseif cChamada == "1" .and. cMoment<>"1"//Ordem de servico e nao for validacao do campo.

			cQuery := "SELECT SUM(VO3.VO3_QTDREQ) AS QTDREQ FROM "+RetSqlName("VO3")+" VO3 "
			cQuery += "INNER JOIN "+RetSqlName("VO2")+" VO2 ON (VO2.VO2_FILIAL='"+xFilial("VO2")+"' AND VO2.VO2_DEVOLU='1' AND VO2.VO2_NOSNUM=VO3.VO3_NOSNUM AND VO2.D_E_L_E_T_=' ' ) "
			cQuery += "INNER JOIN "+RetSqlName("VO1")+" VO1 ON (VO1.VO1_FILIAL='"+xFilial("VO1")+"' AND VO1.VO1_NUMOSV=VO2.VO2_NUMOSV AND VO1.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE VO1.VO1_CHAINT='"+cChaint+"' AND (VO3.VO3_GRUITE='"+cGruIte+"' OR VO3.VO3_GRUITE='"+Space(Len(VO3->VO3_GRUITE))+"') AND VO3.VO3_CODITE='"+cCodIte+"' "

			If (GetNewPar("MV_VERQTCC","1") == "1") //1 somente os atual / 2 todas os do veiculo
				cQuery += "AND VO3.VO3_NUMOSV='"+cNumOrc+"' "
			EndIF

			cQuery += "AND VO1.VO1_STATUS NOT IN ('C','F') AND VO3.D_E_L_E_T_=' '"

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVO3 , .F., .T. )
			IF !( cQAlVO3 )->( Eof() )
				nQtdReq += ( cQAlVO3 )->( QTDREQ )
			EndIF
			( cQAlVO3 )->( dbCloseArea() )


			cQuery := "SELECT SUM(VO3.VO3_QTDREQ) AS QTDREQ FROM "+RetSqlName("VO3")+" VO3 "
			cQuery += "INNER JOIN "+RetSqlName("VO2")+" VO2 ON (VO2.VO2_FILIAL='"+xFilial("VO2")+"' AND VO2.VO2_DEVOLU='0' AND VO2.VO2_NOSNUM=VO3.VO3_NOSNUM AND VO2.D_E_L_E_T_=' ' ) "
			cQuery += "INNER JOIN "+RetSqlName("VO1")+" VO1 ON (VO1.VO1_FILIAL='"+xFilial("VO1")+"' AND VO1.VO1_NUMOSV=VO2.VO2_NUMOSV AND VO1.D_E_L_E_T_=' ' ) "
			cQuery += "WHERE VO1.VO1_CHAINT='"+cChaint+"' AND (VO3.VO3_GRUITE='"+cGruIte+"' OR VO3.VO3_GRUITE='"+Space(Len(VO3->VO3_GRUITE))+"') AND VO3.VO3_CODITE='"+cCodIte+"' "


			If (GetNewPar("MV_VERQTCC","1") == "1") //1 somente os atual / 2 todas os do veiculo
				cQuery += "AND VO3.VO3_NUMOSV='"+cNumOrc+"' "
			EndIF

			cQuery += "AND VO1.VO1_STATUS NOT IN ('C','F') AND VO3.D_E_L_E_T_=' '"

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVO3 , .F., .T. )
			IF !( cQAlVO3 )->( Eof() )
				nQtdReq -= ( cQAlVO3 )->( QTDREQ )
			EndIF
			( cQAlVO3 )->( dbCloseArea() )

		EndIf

		cQuery := ""
		cQuery := "SELECT SUM(VZZ.VZZ_QTDITE) AS QTDZZZ FROM "+RetSqlName("VZZ")+" VZZ "
		cQuery += "WHERE (VZZ.VZZ_GRUITE='"+cGruIte+"' OR VZZ.VZZ_GRUITE='"+Space(Len(VO3->VO3_GRUITE))+"') AND VZZ.VZZ_CODITE='"+cCodIte+"' "
		cQuery += "AND VZZ.VZZ_CODAGM='"+cCodAgm+"' AND VZZ.D_E_L_E_T_=' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVZZ , .F., .T. )
		IF !( cQAlVZZ )->( Eof() )
			nQtdIte += ( cQAlVZZ )->( QTDZZZ )
		EndIF
		( cQAlVZZ )->( dbCloseArea() )

		DbSelectArea("VZZ")
		DbSetOrder(1)
		If DbSeek(xFilial("VZZ")+cCodAgm)
			If cChamada == "0"//Ordem de servico.

				If cMoment == "1"
					If nQtdIte < ( nQtdReq + M->VO3_QTDREQ ) .and. !Empty(nQtdIte)
						lRet := .f.
						MsgAlert(STR0115,STR0075)// Quantidade requisitada para o item ้ superior a maxima permitida para o modelo do Veiculo / Aten็ใo
					EndIF
				ElseIf cMoment <> "1"
					If nQtdIte < ( nQtdReq ) .and. !Empty(nQtdIte)
						lRet := .f.
						//MsgAlert("Quantidade requisitada para o item ้ superior a maxima permitida para o modelo do Veiculo","Atencao")//
					EndIF
				EndIf


			ElseIf cChamada == "1"//Orcamento

				If cMoment == "1" //valid co campo VS3_QTDITE
					If nQtdIte < ( nQtdReq ) .and. !Empty(nQtdIte)//quantidade maxima for menor que a requisitada.
						lRet := .f.
						MsgAlert(STR0115,STR0075)// Quantidade requisitada para o item ้ superior a maxima permitida para o modelo do Veiculo / Aten็ใo
					EndIF
				ElseIf cMoment <> "1" //na exportacao para OS
					If nQtdIte < ( nQtdReq ) .and. !Empty(nQtdIte)
						lRet := .f.
						//MsgAlert("Quantidade requisitada para o item ้ superior a maxima permitida para o modelo do Veiculo","Atencao")//
					EndIF
				EndIf

			Endif
		EndIF
	EndIf
Endif
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณFS_DELPECORCบAutor  ณManoel              บ Data ณ  23/08/06 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra Pecas do Orcamento a serem deletadas                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_DELPECORC()
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0
////////////////////////////////////////////////////////////////////////////////////////////
Local lMarcar := .f.
Local nPosACols
//Local oInterfHelper := DMS_InterfaceHelper():New()
Local lCancel := .f.
Local aBkpPecaOrc := aClone(aPecaOrc)

Private oLbPecaOrc
Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oCancel   := LoadBitmap( GetResources(), "BR_CANCEL"   )
Private aImpFatPar := {}

If Len(aPecaOrc) == 0
	If !OM020VSJLOAD( VO1->VO1_NUMOSV, .t. , {} )
		Return .f.
	EndIf
Else
	// Verifica se alguma pe็a esta na OS
	For nCntFor := 1 to Len(aPecaOrc)
		If (nPosACols := FS_POSACOLS(nCntFor,.f.)) > 0
			ShowHelpDlg ( "VSJJASEL", { STR0232 }) // "Jแ existe pe็a selecionada para requisi็ใo, nใo ้ possํvel executar op็ใo para excluir pe็as pendentes."
			Return .f.
		EndIf
	Next nCntFor
	//
	OM020VSJATU( .f. , .f. )
EndIf

If Len(aPecaOrc) # 0

	// Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 01, 01 , .T., .T. } )  //Cabecalho

	for nCntFor := 1 to Len(aSizeAut)
		aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
	next

	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)

	DEFINE MSDIALOG oDlgOrc TITLE STR0127 From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL // Deleta Pecas do Orcamento

	@ 001, 006 CHECKBOX oRPecas VAR lMarcar PROMPT "Marcar" ;
		OF oDlgOrc ;
		ON CLICK If( FS_TikPecas( .T. , lMarcar ) , .t. , ( lMarcar:=!lMarcar , oRPecas:Refresh() ) ) ;
		SIZE 40,10 PIXEL


	oLbPecaOrc := TWBrowse():New( aPosObj[1,1]+016, aPosObj[1,2], aPosObj[1,4]-05, aPosObj[1,3]-32,,,,oDlgOrc,,,,,,,,,,,,.F.,,.T.,,.F.,,, )

	oLbPecaOrc:addColumn( TCColumn():New(" "						, { || IIf( aPecaOrc[oLbPecaOrc:nAt,PECAORC_ORIDAD] <> "2" .or. aPecaOrc[oLbPecaOrc:nAt,PECAORC_RESPEC] == "1" , oVermelho , Iif( aPecaOrc[oLbPecaOrc:nAt,1] , oOk , oNo)) }	,,,,"LEFT" ,10,.T.,.F.,,,,.F.,) )
	If lVSJCODIGO
		oLbPecaOrc:addColumn( TCColumn():New(RetTitle("VSJ_CODIGO")	, { || aPecaOrc[oLbPecaOrc:nAt,PECAORC_CODIGOVSJ] }								,,,,"LEFT" ,10,.F.,.F.,,,,.F.,) ) //Cod do Grupo
	EndIf
	oLbPecaOrc:addColumn( TCColumn():New(STR0029					, { || aPecaOrc[oLbPecaOrc:nAt,02] }											,,,,"LEFT" ,10,.F.,.F.,,,,.F.,) ) //Tp
	oLbPecaOrc:addColumn( TCColumn():New(STR0030					, { || aPecaOrc[oLbPecaOrc:nAt,03] }											,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) //Faturar Para
	oLbPecaOrc:addColumn( TCColumn():New(STR0031					, { || aPecaOrc[oLbPecaOrc:nAt,04] }											,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) //Loja
	oLbPecaOrc:addColumn( TCColumn():New(STR0032					, { || aPecaOrc[oLbPecaOrc:nAt,05] }											,,,,"LEFT" ,60,.F.,.F.,,,,.F.,) ) //Nome
	oLbPecaOrc:addColumn( TCColumn():New(STR0010					, { || aPecaOrc[oLbPecaOrc:nAt,06] }											,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) //Grupo
	oLbPecaOrc:addColumn( TCColumn():New(STR0033					, { || aPecaOrc[oLbPecaOrc:nAt,07] }											,,,,"LEFT" ,60,.F.,.F.,,,,.F.,) ) //Codigo
	oLbPecaOrc:addColumn( TCColumn():New(STR0012					, { || aPecaOrc[oLbPecaOrc:nAt,08] }											,,,,"LEFT" ,60,.F.,.F.,,,,.F.,) ) //Descricao
	If lCtrlLote
		oLbPecaOrc:addColumn( TCColumn():New(RetTitle("VSJ_LOTECT")	, { || aPecaOrc[oLbPecaOrc:nAt,PECAORC_LOTECT] }								,,,,"LEFT" ,20,.F.,.F.,,,,.F.,) ) //Lote
		oLbPecaOrc:addColumn( TCColumn():New(RetTitle("VSJ_NUMLOT")	, { || aPecaOrc[oLbPecaOrc:nAt,PECAORC_NUMLOT] }								,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) //Sub-Lote
	EndIf
	oLbPecaOrc:addColumn( TCColumn():New(STR0034					, { || Transform(aPecaOrc[oLbPecaOrc:nAt,09],PesqPict("VS3","VS3_QTDITE")) }	,,,,"RIGHT",30,.F.,.F.,,,,.F.,) ) //Quantidade
	oLbPecaOrc:addColumn( TCColumn():New(STR0035					, { || aPecaOrc[oLbPecaOrc:nAt,10] }											,,,,"LEFT" ,25,.F.,.F.,,,,.F.,) ) //Formula
	oLbPecaOrc:addColumn( TCColumn():New(STR0014					, { || Transform(aPecaOrc[oLbPecaOrc:nAt,11],PesqPict("VS3","VS3_VALPEC")) }	,,,,"RIGHT",40,.F.,.F.,,,,.F.,) ) //Valor
	oLbPecaOrc:bLDblClick := { || FS_TikPecas( .f. , .f. ) }
	oLbPecaOrc:nAt := 1
	oLbPecaOrc:SetArray(aPecaOrc)

	DEFINE SBUTTON FROM aPosObj[1,3]-11,aPosObj[1,4]-90 TYPE 3 ACTION (FS_DELORC("D") ,oDlgOrc:End()) ENABLE ONSTOP "Deletar Pecas do Orcamento no Arquivo" OF oDlgOrc
	DEFINE SBUTTON FROM aPosObj[1,3]-11,aPosObj[1,4]-50 TYPE 2 ACTION (lCancel := .t. ,oDlgOrc:End()) ENABLE OF oDlgOrc

	ACTIVATE MSDIALOG oDlgOrc CENTER

	If lCancel
		aPecaOrc := aClone(aBkpPecaOrc)
	EndIf

Else

	Help("  ",1,"NORCOSV")

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DELORC บAutor  ณManoel              บ Data ณ  23/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDeleta Pecas do Orcamento Importado                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DELORC( cButton )
	Local ni := 0
	DbSelectArea("VSJ")
	DbSetOrder(1)
	For ni := 1 to Len(aPecaOrc)
		If aPecaOrc[ ni , 1]
			VSJ->(dbGoTo(aPecaOrc[ni,PECAORC_RECNO]))
			If VSJ->(Deleted())
				Help("  ",1,"REGNOIS",,"VSJ",4,1)
				Loop
			EndIf
			If VSJ->VSJ_RESPEC <> "1"
				RecLock("VSJ",.f.,.t.)
				dbdelete()
				MsUnlock()
			Endif
		Endif
	Next
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TikPecasบAutor ณFabio               บ Data ณ  09/28/00   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca pecas p/ importar do orcamento                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TikPecas( lAll , lMarcar )
	Local oPeca := DMS_Peca():New()
	Local ni    := 0
	Local nIni  := 0
	Local nFim  := 0
	Local nReg
	Local lRetorno
	Local cCodIte
	Local cGrpIte
	Local cMsgReq := ""
	Local cMsgExp := ""
	Local cMsgRes := ""

	Default lAll := .f.
	Default lMarcar := .f.

	If lAll
		nIni := 1
		nFim := Len(aPecaOrc)
	Else
		nIni := nFim := oLbPecaOrc:nAt
	EndIf

	For nI := nIni to nFim
		// Verifica se a pe็a jแ estแ na GetDados ...
		nReg := FS_POSACOLS(nI,.f.)

		cCodIte := aPecaOrc[nI, PECAORC_CODITE]
		cGrpIte := aPecaOrc[nI, PECAORC_GRUITE]
		if ! oPeca:Bloqueado(/*cB1Cod*/, cGrpIte, cCodIte) // mostrar mensagem ้ padrใo sim na funcao

			If nReg <> 0
				// "Pe็a jแ estแ selecionada para requisi็ใo, nใo ้ possํvel seleciona-la para exclusใo."
				cMsgReq += "   " + RetTitle("VO3_CODITE") + ": " + cGrpIte + " - " + cCodIte + chr(13) + chr(10)

				lRetorno := IIf( lAll , .t. , .f. )
				Loop
			EndIf
			//

			// Verifica origem do registro
			If aPecaOrc[nI,PECAORC_ORIDAD] <> "2"
				// "Nใo ้ permitido remover pe็as que nใo foram exportadas de um or็amento."
				cMsgExp += "   " + RetTitle("VO3_CODITE") + ": " + cGrpIte + " - " + cCodIte + chr(13) + chr(10)

				lRetorno := IIf( lAll , .t. , .f. )
				Loop
			Endif

			If aPecaOrc[nI,1]
				aPecaOrc[nI,1] := .f.
			Else
				// Verifica se a peca foi reservada ...
				If aPecaOrc[nI,14] == "1"
					// "Pe็a foi reservada, nใo ้ possํvel seleciona-la para exclusใo."
					cMsgRes += "   " + RetTitle("VO3_CODITE") + ": " + cGrpIte + " - " + cCodIte + chr(13) + chr(10)

					Loop
				Else
					aPecaOrc[nI,1] := .t.
				EndIf
			Endif
		end
	Next nI

	oLbPecaOrc:Refresh()

	// Se no listbox hแ pe็as com diverg๊ncia para sele็ใo
	If !Empty(cMsgReq) .Or. !Empty(cMsgExp) .Or. !Empty(cMsgRes)
		// STR0278 "Pe็as selecionadas para requisi็ใo:""
		If !Empty(cMsgReq)
			cMsgReq := chr(13) + chr(10) + chr(13) + chr(10) + cMsgReq + "- " + STR0278 + cMsgReq
		EndIf

		// STR0279 "Pe็as nใo exportadas de um or็amento:"
		If !Empty(cMsgExp)
			cMsgExp := chr(13) + chr(10) + chr(13) + chr(10) + "- " + STR0279 + cMsgExp
		EndIf

		// STR0280 "Pe็as reservadas:"
		If !Empty(cMsgRes)
			cMsgRes := chr(13) + chr(10) + chr(13) + chr(10) + "- " + STR0280 + chr(13) + chr(10) + cMsgRes
		EndIf

		Aviso(STR0075,; // Aten็ใo
			STR0277 + ; // As pe็as abaixo nใo podem ser selecionadas para exclusใo, motivo.
			cMsgReq + ;
			cMsgExp + ;
			cMsgRes   ;
			, { STR0130 }, 3) // OK
	EndIf
Return(.t.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SALDPEC บAutor  ณ Takahashi         บ Data ณ  15/06/11   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se tem saldo de peca para fazer a devolucao       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_SALDPEC(cMsg,cMsgRem)
Local lRetorno := .T.
Local nCont
Local cVOIVLPCAC
Local cSQL := ""
Local cAuxTipTem := ""
Local nSaldPec := 0
Local lCpoDesconto := .f.

Local nDecValPec := TamSX3("VO3_VALPEC")[2]
Local nDecValLiq := 0

Local lVDR := AliasInDic("VDR")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Indica se os campos de desconto estao criado ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if VO3->(FieldPos("VO3_VALDES")) <> 0 .and. VO3->(FieldPos("VO3_PERDES")) <> 0 .and. VO3->(FieldPos("VO3_VALLIQ")) <> 0
	lCpoDesconto := .t.
	nDecValLiq := TamSX3("VO3_VALLIQ")[2]
endif


For nCont := 1 to Len(aCols)

	If cAuxTipTem <> aCols[nCont,FG_POSVAR("VO3_TIPTEM")]
		cAuxTipTem := aCols[nCont,FG_POSVAR("VO3_TIPTEM")]
		cVOIVLPCAC := FM_SQL("SELECT VOI_VLPCAC FROM " + RetSQLName("VOI") + " WHERE VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI_TIPTEM = '" + cAuxTipTem + "' AND D_E_L_E_T_ = ' '")
	EndIf

	cSQL := "SELECT SUM( CASE VO2_DEVOLU WHEN '1' THEN VO3_QTDREQ ELSE VO3_QTDREQ * -1 END ) SALDO"
	cSQL +=  " FROM " + RetSQLName("VO2") + " VO2 JOIN " + RetSQLName("VO3") + " VO3 ON VO3_FILIAL = '" + xFilial("VO3") + "' AND VO3_NOSNUM = VO2_NOSNUM AND VO3.D_E_L_E_T_ = ' '"
	cSQL += " WHERE VO2_FILIAL = '" + xFilial("VO2") + "' AND VO2_TIPREQ = 'P' "
	cSQL +=   " AND VO2_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
	cSQL +=   " AND VO2.D_E_L_E_T_ = ' '"
	cSQL +=   " AND VO3.VO3_TIPTEM = '" + cAuxTipTem + "'"
	cSQL +=   " AND VO3.VO3_GRUITE = '" + aCols[nCont,FG_POSVAR("VO3_GRUITE")] + "'"
	cSQL +=   " AND VO3.VO3_CODITE = '" + aCols[nCont,FG_POSVAR("VO3_CODITE")] + "'"
	cSQL +=   " AND VO3.VO3_LOTECT = '" + aCols[nCont,FG_POSVAR("VO3_LOTECT")] + "'"
	cSQL +=   " AND VO3.VO3_NUMLOT = '" + aCols[nCont,FG_POSVAR("VO3_NUMLOT")] + "' "
	If cVOIVLPCAC == "1" // 1 - Para o valor da requisi็ใo
		cSQL += " AND VO3.VO3_VALPEC = " + AllTrim(Str(aCols[nCont, FG_POSVAR("VO3_VALPEC")],20,nDecValPec))
		If lCpoDesconto
			If aCols[nCont, FG_POSVAR("VO3_VALLIQ")] <> 0
				cSQL += " AND VO3.VO3_VALLIQ = " + AllTrim(Str(aCols[nCont, FG_POSVAR("VO3_VALLIQ")],20,nDecValLiq))
			EndIf
			If aCols[nCont, FG_POSVAR("VO3_VALDES")] <> 0
				cSQL += " AND VO3.VO3_VALDES <> 0 "
			Else
				cSQL += " AND VO3.VO3_VALDES = 0 "
			EndIf
		EndIf
	EndIf
	nSaldPec := FM_SQL( cSQL )

	If aCols[nCont,FG_POSVAR("VO3_QTDREQ")] > nSaldPec
		cMsg += STR0095 + ": " + cAuxTipTem + " " + STR0099 + ": " + aCols[nCont,FG_POSVAR("VO3_GRUITE")] + " " + STR0100 + ": " + aCols[nCont,FG_POSVAR("VO3_CODITE")] + CHR(13) + CHR(10)
		lRetorno := .f.
	EndIf

	// Saldo da peca requisitado deve ser maior ou igual o saldo de pecas em remessa para atendimento externo ...
	If lVDR
		cSQL := "SELECT SUM(VDR_QTDREM) VDR_QTDREM"
		cSQL +=  " FROM " + RetSQLName("VDR")
		cSQL += " WHERE VDR_FILIAL = '" + xFilial("VDR") + "'"
		cSQL +=   " AND VDR_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
		cSQL +=   " AND VDR_TIPTEM = '" + cAuxTipTem + "'"
		cSQL +=   " AND VDR_GRUITE = '" + aCols[nCont,FG_POSVAR("VO3_GRUITE")] + "'"
		cSQL +=   " AND VDR_CODITE = '" + aCols[nCont,FG_POSVAR("VO3_CODITE")] + "'"
		cSQL +=   " AND VDR_NFENUM = '         '" // Nota fiscal nao devolvida ...
		cSQL +=   " AND D_E_L_E_T_ = ' '"
		nSaldRem := FM_SQL( cSQL )

		If nSaldRem > (nSaldPec - aCols[nCont,FG_POSVAR("VO3_QTDREQ")])
			cMsgRem += STR0095 + ": " + cAuxTipTem + " " + STR0099 + ": " + aCols[nCont,FG_POSVAR("VO3_GRUITE")] + " " + STR0100 + ": " + aCols[nCont,FG_POSVAR("VO3_CODITE")] + CHR(13) + CHR(10)
			lRetorno := .f.
		EndIf

	EndIf
	//

Next nCont

Return lRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TUDOK020 บAutor  ณ Rubens           บ Data ณ  03/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao final do GetDados de Requisicao de Pecas          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_TUDOK020()

Local nCont
Local nPosFORMUL, nPosCODTES
Local lRetorno := .t.

Local cResCliente := ""
Local nVO3TIPTEM := FG_POSVAR("VO3_TIPTEM")
Local nVO3FATPAR := FG_POSVAR("VO3_FATPAR")
Local nVO3LOJA   := FG_POSVAR("VO3_LOJA")

// Requisicao
If cReqDev == "1"

	// Se avalia credito na requisicao, limpa a matriz para levar os valores atuais ...
	If "P" $ cMVCHKCRE
		aAvCred := {}
	EndIf
	//

	nPosFORMUL := FG_POSVAR("VO3_FORMUL")
	nPosCODTES := FG_POSVAR("VO3_CODTES")

	SF4->(dbSetOrder(1))
	For nCont := 1 to Len(aCols)
		If aCols[nCont,Len(aCols[nCont])]
			Loop
		EndIf

		If OFP8600016 .And. !OFP8600016_VerificacaoFormula(aCols[nCont,nPosFORMUL])
			lRetorno := .f. // A mensagem jแ ้ exibida dentro da fun็ใo
			Exit
		EndIf

		If !SF4->(MsSeek(xFilial("SF4") + aCols[nCont,nPosCODTES]))
			Help(" ",1,"REGNOIS",,AllTrim(RetTitle("VO3_CODTES")) + ": " + aCols[nCont,nPosCODTES] + CHR(13) + CHR(10) + STR0135 + ": " + AllTrim(Str(nCont)) ,4,0)
			lRetorno := .f.
			Exit
		EndIf


		// Requisicao importada de orcamento
		If aCols[nCont,FG_POSVAR("VO3_IMPORC")] == "1"

			if lInconveniente
				nPosOrc := aScan(aPecaOrc, {|x| x[06] == aCols[nCont,FG_POSVAR("VO3_GRUITE")] .and. x[07] == aCols[nCont,FG_POSVAR("VO3_CODITE")] .and. x[20] == aCols[nCont,FG_POSVAR("VO3_SEQINC")] .and. x[02] == aCols[nCont,FG_POSVAR("VO3_TIPTEM")] .and. x[03] == aCols[nCont,FG_POSVAR("VO3_FATPAR")] .and. x[04] == aCols[nCont,FG_POSVAR("VO3_LOJA")] })
			else
				nPosOrc := aScan(aPecaOrc, {|x| x[06] == aCols[nCont,FG_POSVAR("VO3_GRUITE")] .and. x[07] == aCols[nCont,FG_POSVAR("VO3_CODITE")] .and. x[02] == aCols[nCont,FG_POSVAR("VO3_TIPTEM")] .and. x[03] == aCols[nCont,FG_POSVAR("VO3_FATPAR")] .and. x[04] == aCols[nCont,FG_POSVAR("VO3_LOJA")] })
			endif

			If nPosOrc == 0
				Loop
			EndIf

			If !OM020CMPTES( aPecaOrc[nPosOrc,19] , aCols[nCont,FG_POSVAR("VO3_CODTES")] , chr(13) + chr(10) + RetTitle("VO3_CODITE") + ": " + aCols[nCont,FG_POSVAR("VO3_GRUITE")] + " - " + aCols[nCont,FG_POSVAR("VO3_CODITE")] )
				lRetorno := .f.
				Exit
			EndIf

		EndIf
		//

		// Verifica Credito do Cliente
		if "P" $ cMVCHKCRE
			If !((aCols[nCont, nVO3FATPAR]+ aCols[nCont,nVO3LOJA]+"/") $ cResCliente)
				cResCliente += aCols[nCont, nVO3FATPAR]+ aCols[nCont,nVO3LOJA] + "/"
				If !OM020AVCRED( aCols[nCont, nVO3FATPAR] , aCols[nCont,nVO3LOJA], aCols[nCont,nVO3TIPTEM] , FS_TOTAL( aCols[nCont, nVO3FATPAR] , aCols[nCont,nVO3LOJA] ,.f.,.T.) )
					lRetorno := .f.
					Exit
				EndIf
			Endif
		EndIf
		//

	Next nCont
EndIf

If lRetorno
	If ExistBlock("OM020TOK") // Valida็ใo do Usuแrio no TudoOk da Requisi็ใo de Pe็as
		lRetorno := ExecBlock("OM020TOK",.f.,.f.)
	Endif
Endif

Return lRetorno
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun็ใo    | OM020V     | Autor |  Thiago		          | Data | 05/01/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri็ใo | Pesquisa Avancada                                            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM020V()
nOpc := 1
OFIOC450()
Return(.t.)


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun็ใo    | OM020DIST  | Autor |  Manoel		          | Data | 22/06/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descrio | Fun็ใo para Distribui็ao da Devolu็ใo por Endere็o	        |##
##|          | e Prioriza็ใo na Requisi็ใo por Endere็o				        |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM020DIST()

Local cQuery   := ""
Local cQAlias  := "SQLSBF"
Local nCont    := 0
Local _ni      := 0
Local lSair    := .f.
Local aColsOld:=Aclone(aCols)
Local aHeaderOld:=Aclone(aHeader)

aVetRet  := {}
// aVetRet
// 1o Elemento - Produto
// 2o Elemento - Armazem
// 3o Elemento - Localizacao - Endere็o
// 4o Elemento - Lote
// 5o Elemento - Sub-Lote
// 6o Elemento - Prioriza็ใo
// 7o Elemento - Qtd a Devolver Total
// 8o Elemento - Qtd a Devolver por Localiza็ใo

cQuery := "SELECT SBF.BF_LOCAL, SBF.BF_LOCALIZ, SBF.BF_LOTECTL, SBF.BF_NUMLOTE, SBF.BF_PRIOR FROM "+RetSqlName("SBF")+" SBF WHERE SBF.BF_FILIAL = '"+xFilial("SBF")+"' AND "
cQuery += "SBF.BF_PRODUTO = '"+SB1->B1_COD+"' AND SBF.BF_LOCAL = '" + OM0200065_ArmazemOrigem( VO3->VO3_TIPTEM ) +"' AND SBF.BF_QUANT > 0 AND "
If !Empty(VO3->VO3_LOTECT)
	cQuery += "SBF.BF_LOTECTL = '"+VO3->VO3_LOTECT+"' AND "
Endif
If !Empty(VO3->VO3_NUMLOT)
	cQuery += "SBF.BF_NUMLOTE = '"+VO3->VO3_NUMLOT+"' AND "
Endif
cQuery += "SBF.D_E_L_E_T_ = ' ' ORDER BY SBF.BF_PRIOR"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )

If !( cQAlias )->( Eof() )

	While !( cQAlias )->( Eof() )

		nCont++

		AAdd( aVetRet, { SB1->B1_COD,( cQAlias )->( BF_LOCAL ),( cQAlias )->( BF_LOCALIZ ),( cQAlias )->( BF_LOTECTL ),( cQAlias )->( BF_NUMLOTE ),( cQAlias )->( BF_PRIOR ),If(nCont==1,VO3->VO3_QTDREQ,0),If(nCont==1,VO3->VO3_QTDREQ,0) } )

		dbSelectArea(cQAlias)
		( cQAlias )->(dbSkip())

	Enddo

Else

	aVetRet      := {{SB1->B1_COD, OM0200065_ArmazemOrigem( VO3->VO3_TIPTEM ),FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),VO3->VO3_LOTECT,VO3->VO3_NUMLOT,"",VO3->VO3_QTDREQ,VO3->VO3_QTDREQ}}

Endif
( cQAlias )->(dbCloseArea())

If cReqDev == "0"

	aHeader := {}
	aCols   := {}
	nUsado:=0

	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek("DB_PRODUTO")
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_Picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		DbSkip()
	Endif

	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek("DB_LOCAL")
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_Picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		DbSkip()
	Endif

	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek("DB_LOCALIZ")
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_Picture,;
		x3_tamanho, x3_decimal,'ExistCpo("SBE",M->DB_LOCAL+M->DB_LOCALIZ)',;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		DbSkip()
	Endif

	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek("DB_LOTECTL")
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_Picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		DbSkip()
	Endif

	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek("DB_NUMLOTE")
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_Picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		DbSkip()
	Endif

	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek("DB_PRIORI")
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_Picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		DbSkip()
	Endif

	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek("VO3_QTDREQ")
		nUsado:=nUsado+1
		Aadd(aHeader,{ "Qtd a Devolver", x3_campo, x3_Picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		DbSkip()
	Endif

	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek("DB_QUANT")
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_Picture,;
		x3_tamanho, x3_decimal,'.t.',;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
		DbSkip()
	Endif

	For nCont := 1 to Len(aVetRet)
		AADD(acols,Array(nUsado+1))
		For _ni:=1 to nUsado
			acols[Len(acols),_ni] := aVetret[nCont,_ni]
			&( "M->"+aHeader[_ni,2] ) := acols[Len(acols),_ni]
		Next
		acols[Len(acols),nUsado+1]:=.F.
	Next

	If Len(aCols) == 0
		aCols:={Array(nUsado+1)}
		aCols[1,nUsado+1]:=.F.
	Endif

	cTitulo    := (STR0136)
	cAliasEnch := "SDB"
	cLinOk     := "AllwaysTrue()"//"OM020ADLAD()"
	cTudoOk    := "AllwaysTrue()"
	cFieldOk   := "OM020CONFD('D')"

	aAlter     := {"DB_LOCAL","DB_LOCALIZ","DB_QUANT"}

	Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),nPosAnt:=9999,      nColAnt:=9999
	Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

	nOpcG := If(nOpcG==Nil,3,nOpcG)
	nOpcaA:= 0
	lVirtual := .f.
	nLinhas:= 99
	Inclui := .f.
	Altera := .t.

	While !lSair
		DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,112	of oMainWnd // 98
		oGetDados:= MsGetDados():New(15,1,143,445,nOpcG,cLinOk,cTudoOk,"",.T.,aAlter,,,nLinhas,cFieldOk) // 386
		oGetDados:oBrowse:bChange  := {||OM020ADLAD()}
		ACTIVATE MSDIALOG oDlg CENTER ON INIT (EnchoiceBar(oDlg,{|| lSair := OM020CONFD("C"), oDlg:End()},{|| nOpcaA := 2,oDlg:End()},,) )
	Enddo

	aVetRet := {}
	For nCont := 1 to Len(aCols)
		If !aCols[nCont,len(aHeader)+1] .and. aCols[nCont,8] > 0
			AADD(aVetRet,Array(nUsado))
			For _ni:=1 to nUsado
				aVetRet[Len(aVetRet),_ni] := aCols[nCont,_ni]
			Next
		Endif
	Next
	aCols:=Aclone(aColsOld)
	aHeader:=Aclone(aHeaderOld)

Endif

Return (aVetRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณOM020CONFDณ Autor ณ Manoel                             ณ Data ณ 25/06/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Verifica a Distribui็ใo da Quantidade a ser devolvida por Endere็o      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM020CONFD(cMomento)
Local i     := 0
Local nSoma := 0
Local lRet  := .t.
Local cMsg  := ""

If cMomento == "D" // Digitacao

	If ReadVar() == "M->DB_QUANT"

		nSoma := M->DB_QUANT
		For i:=1 to Len(aCols)
			If i <> n .and. !aCols[i,len(aHeader)+1]
				nSoma += aCols[i,8]
			Endif
		Next

		If nSoma > VO3->VO3_QTDREQ
			cMsg := STR0137 + transform(VO3->VO3_QTDREQ,"@E 999999") // Por favor, fa็a correctamente a distribui็ใo da quantidade a ser devolvida. Total a devolver 
			lRet := .f.
		Endif

	Endif

Else // C - Confirmacao

	For i:=1 to Len(aCols)
		If !aCols[i,len(aHeader)+1]
			nSoma += aCols[i,8]
			If Empty(aCols[i,2])
				cMsg := STR0140 // Por favor, informe todos armaz้ns de destino.
				lRet := .f.
			Endif
			If Empty(aCols[i,3])
				cMsg := STR0141 // Por favor, informe todas as localiza็๕es de Destino!
				lRet := .f.
			Endif
		Endif
	Next

	If nSoma <> VO3->VO3_QTDREQ
		cMsg := STR0137 + transform(VO3->VO3_QTDREQ,"@E 999999") // Por favor, fa็a correctamente a distribui็ใo da quantidade a ser devolvida. Total a devolver 
		lRet := .f.
	Endif


Endif
If !lRet
	MsgStop(cMsg,STR0075) // Aten็ใo
Endif
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณOM020ADLADณ Autor ณ Manoel                             ณ Data ณ 25/06/12 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Adiciona linha no Acols da Distruibui็ใo             			       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM020ADLAD()
Local nSoma := 0
Local _ni   := 0
Local i     := 0

For i:=1 to Len(aCols)
	If !aCols[i,len(aHeader)+1]
		nSoma += aCols[i,8]
	Endif
Next

If VO3->VO3_QTDREQ - nSoma > 0 .and. n>Len(acols)
	AADD(acols,Array(nUsado+1))
	For _ni:=1 to nUsado
		If _ni == 1
			acols[Len(acols),_ni] := aVetRet[1,_ni]
			&( "M->"+aHeader[_ni,2] ) := acols[Len(acols),_ni]
		Elseif _ni == 8
			acols[Len(acols),_ni] := VO3->VO3_QTDREQ - nSoma
			&( "M->"+aHeader[_ni,2] ) := acols[Len(acols),_ni]
			//		Elseif _ni == 7
			//			acols[Len(acols),_ni] := VO3->VO3_QTDREQ - nSoma
			//			&( "M->"+aHeader[_ni,2] ) := acols[Len(acols),_ni]
		Else
			acols[Len(acols),_ni] := CriaVar(aHeader[_ni,2])
		Endif
	Next
	acols[Len(acols),nUsado+1]:=.F.
	oGetDados:refresh()
Endif

Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun็ใo    |OM020AVARES | Autor | Luis Delorme          | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri็ใo | Funcao que faz a chamada da rotina de avaliacao de resultado |##
##+----------+--------------------------------------------------------------+##
##| Uso      | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM020AVARES()
Private cArqTrb
Private cArqPes
Private cCodMap
Private cOutMoed
Private cSimOMoe
Private aVetVal := {}
Private aStru   := {}
Private cParPro := "1"
Private cNumero := VO1->VO1_NUMOSV
Private cContChv:= "VEC_NUMOSV"
Private cParTem := ""
Private lCalcTot:= .f.
Private cCpoDiv := "    1"
Private cSimVda   := "P"  // Pecas
Private cTipAva   := "2"  // Pecas
Private aErrAva   := {}   //Array de formulas incorretas (Compatibilidade com Erro na VEIFUNC)

//
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VEC")
Do While !EOF() .and. x3_arquivo == "VEC"
	aadd(aVetVal,{x3_campo,x3_tipo,x3_tamanho,x3_decimal})
	dbSkip()
EndDo

aAltSx1  := { {"02","","","","","",GETMV("MV_SIMB1"),GETMV("MV_SIMB2"),GETMV("MV_SIMB3"),GETMV("MV_SIMB4"),GETMV("MV_SIMB5"),"","","","",""} }
FG_AltSx1("ATDCLI","A",aAltSx1)

if !PERGUNTE("ATDCLI")
	Return
Endif

cCodMap  := Mv_Par01
cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
cSimOMoe := Val(Alltrim(GetMv("MV_INDMFT")))

oObjTempTable := OFDMSTempTable():New()
oObjTempTable:cAlias := "TRB"
oObjTempTable:aVetCampos := aVetVal
oObjTempTable:AddIndex(, {"VEC_FILIAL","VEC_NUMOSV"} )
oObjTempTable:CreateTable()

MSGRUN((STR0144),"",{||CursorWait(),FS_AVRES2(),CursorArrow()}) // "Aguarde... Processando Mapa de Avaliacao"

FG_RESAVA(cOutMoed,3,"P","","OFIOM020") // TODO:

oObjTempTable:CloseTable()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออัออออออออออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AVRES2 ณRicardo Farinelli           | Data ณ  31/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออฯออออออออออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณComplemento da funcao de visualizacao do mapa de resultado  บฑฑ
ฑฑบ          ณcom a MSGRUN para dar um status ao usuario                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGestao de Concessionarias                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_AVRES2()
Local ix_:=0
Local ii := 0

dbSelectArea("TRB")
dbSetOrder(1)

aAvalVO3 := {}
aHeaderP := aClone(aHeader)
aColsP :=  aClone(aCols)
nAnt := n
aHeader := {}
aCols := {}
aAdd(aHeader,{"COD","C6_COD","@!",TamSx3("B1_COD")[1],TamSx3("B1_COD")[2],"","","C","TRB",""})
aAdd(aHeader,{"QUANT","C6_QUANT","@!",TamSx3("D2_QUANT")[1],TamSx3("D2_QUANT")[2],"","","N","TRB",""})
aAdd(aHeader,{"PRC","C6_PRCVEN","@!",TamSx3("D2_PRCVEN")[1],TamSx3("D2_PRCVEN")[2],"","","N","TRB",""})
aAdd(aHeader,{"PRCMER","C6_VALMERC","@!",TamSx3("D2_PRCVEN")[1],TamSx3("D2_PRCVEN")[2],"","","N","TRB",""})
aAdd(aHeader,{"DESC","C6_DESCON","@!",TamSx3("D2_DESCON")[1],TamSx3("D2_DESCON")[2],"","","N","TRB",""})
aAdd(aHeader,{"TES","C6_CODTES","@!",TamSx3("D2_TES")[1],TamSx3("D2_TES")[2],"","","C","TRB",""})
aAdd(aHeader,{"LOTE","C6_LOTE","@!",TamSx3("C6_LOTECTL")[1],TamSx3("C6_LOTECTL")[2],"","","C","TRB",""})
aAdd(aHeader,{"DVALID","C6_DTVALID","@!",TamSx3("C6_DTVALID")[1],TamSx3("C6_DTVALID")[2],"","","D","TRB",""})

aFatPar := { }
For ix_ :=1 to Len(aColsP)

	if aColsP[ix_,Len(aColsP[ix_])] .or. Empty(aColsP[ix_,FG_POSVAR("VO3_GRUITE","aHeaderP")])
		Loop
	Endif
	//
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+aColsP[ix_,FG_POSVAR("VO3_GRUITE","aHeaderP")]+aColsP[ix_,FG_POSVAR("VO3_CODITE","aHeaderP")])
	//
	aAdd(aCols,{ SB1->B1_COD,;
				aColsP[ix_,FG_POSVAR("VO3_QTDREQ","aHeaderP")],;
				aColsP[ix_,FG_POSVAR("VO3_VALPEC","aHeaderP")],;
				aColsP[ix_,FG_POSVAR("VO3_VALPEC","aHeaderP")],;
				aColsP[ix_,FG_POSVAR("VO3_VALDES","aHeaderP")],;
				aColsP[ix_,FG_POSVAR("VO3_CODTES","aHeaderP")],;
				aColsP[ix_,FG_POSVAR("VO3_LOTECT","aHeaderP")],;
				aColsP[ix_,FG_POSVAR("VO3_FATPAR","aHeaderP")],;
				aColsP[ix_,FG_POSVAR("VO3_LOJA","aHeaderP")],;
				dDataBase,;
				aColsP[ix_,FG_POSVAR("VO3_TIPTEM","aHeaderP")] } )

next

if Len(aCols) == 0
	aHeader := aClone(aHeaderP)
	aCols   := aClone(aColsP)
	n       := nAnt

	return .f.
endif

aSort(aCols,1,,{ |x,y| x[8]+x[9] < y[8]+y[9] } )

for ix_ := 1 to Len(aCols)
	n := ix_
	if ix_ == 1 .or. aCols[ix_,8] + aCols[ix_,9] != aCols[ix_ - 1, 8] + aCols[ix_ - 1, 9]
		MaFisEnd()
		SA1->(DbSeek(xFilial("SA1")+aCols[ix_,8] + aCols[ix_,9]))
		MaFisIni(aCols[ix_,8] , aCols[ix_,9],'C','N',SA1->A1_TIPO,MaFisRelImp("OF110",{"VO2","VO3"}))
	endif

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+aCols[ix_, 1])

	dbSelectArea("SB2")
	dbSeek(xFilial("SB2") + SB1->B1_COD + OM0200065_ArmazemOrigem( aCols[ ix_, 11 ] ) )

	dbSelectarea("SF4")
	SF4->(dbSeek(xFilial("SF4")+aCols[ix_, 6]))

	MaFisRef("IT_PRODUTO","VS300",aCols[ix_, 1])
	MaFisRef("IT_QUANT","VS300",aCols[ix_, 2])
	MaFisRef("IT_PRCUNI","VS300",aCols[ix_, 3])
	MaFisRef("IT_VALMERC","VS300",aCols[ix_, 4])
	MaFisRef("IT_TES","VS300",aCols[ix_, 6])
	MaFisRef("IT_DESCONTO","VS300",aCols[ix_, 5])

	nValPis := MaFisRet(n,"IT_VALPIS") + MaFisRet(n,"IT_VALPS2")
	nValCof := MaFisRet(n,"IT_VALCOF") + MaFisRet(n,"IT_VALCF2")
	nValICM := MaFisRet(n,"IT_VALICM")
	aLivroVEC := MaFisRet(n,"IT_LIVRO")
	nValICM := aLivroVEC[5]
	nBaseIcm := MaFisRet(n,"IT_BASEICM")

	dbSelectArea("TRB")

	RecLock("TRB",.t.)

	VEC_FILIAL := xFilial("VEC")
	VEC_NUMOSV := VO1->VO1_NUMOSV
	VEC_NUMREL := GetSXENum("VEC","VEC_NUMREL")
	ConfirmSx8()
	VEC_NUMIDE := GetSXENum("VEC","VEC_NUMIDE")
	ConfirmSx8()
	VEC_GRUITE := SB1->B1_GRUPO
	VEC_CODITE := SB1->B1_CODITE
	VEC_VALVDA := aCols[ix_, 2] * aCols[ix_, 3]
	VEC_VALDES := aCols[ix_, 5]
	VEC_QTDITE := aCols[ix_, 2]
	VEC_VALICM := nValICM
	VEC_VALCOF := nValCof
	VEC_VALPIS := nValPis
	VEC_TOTIMP := VEC_VALICM + VEC_VALCOF + VEC_VALPIS + VEC_DIFAL + VEC_VALCMP
	VEC_CUSMED := SB2->B2_CM1 * aCols[ix_, 2]
	VEC_JUREST := 0
	VEC_CUSTOT := VEC_CUSMED + VEC_JUREST
	VEC_LUCBRU := VEC_VALVDA - VEC_TOTIMP - VEC_CUSMED
	VEC_DATVEN := dDataBase
	VEC_PECINT := SB1->B1_COD

	cCodVen := VO2->VO2_FUNREQ
	//Comissao
	aValCom    := FG_COMISS("P",cCodVen,VEC_DATVEN,VEC_GRUITE,VEC_VALVDA,"T",VEC_NUMIDE)
	VEC_COMVEN := aValCom[1]
	VEC_COMGER := aValCom[2]

	VEC_DESVAR := VEC_COMVEN + VEC_COMGER
	VEC_LUCLIQ := VEC_LUCBRU - VEC_JUREST - VEC_DESVAR - VEC_DESDEP - VEC_DESADM - VEC_DESFIX
	VEC_DESFIX := 0
	VEC_CUSFIX := 0
	VEC_DESDEP := 0
	VEC_DESADM := 0
	VEC_RESFIN := 0
	VEC_BALOFI := "O" //Balcao
	VEC_DEPVEN := ""
	VEC_TIPTEM := ""  //Gravar qdo Ordem de Servico
	VEC_NUMOSV := ""  //Gravar qdo Ordem de Servico
	VEC_RESFIN := VEC_LUCLIQ - VEC_CUSFIX
	VEC_NUMNFI := ""

	VEC_VALBRU := VEC_VALVDA + VEC_VALDES
	VEC_VMFBRU := FG_CALCMF( { {dDataBase,VEC_VALBRU} })
	VEC_VMFVDA := VEC_VMFBRU - FG_CALCMF( {{dDataBase,VEC_VALDES}} )
	VEC_VMFICM := FG_CALCMF( { {FG_RTDTIMP("ICM",dDataBase),VEC_VALICM} })
	VEC_VMFPIS := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VEC_VALPIS} })
	VEC_VMFCOF := FG_CALCMF( { {FG_RTDTIMP("COF",dDataBase),VEC_VALCOF} })
	VEC_TMFIMP := VEC_VMFICM + VEC_VMFCOF + VEC_VMFPIS
	VEC_CMFMED := FG_CALCMF( { {dDataBase,VEC_CUSMED} })
	VEC_JMFEST := FG_CALCMF( { {dDataBase,VEC_JUREST} })
	VEC_CMFTOT := VEC_CMFMED + VEC_JMFEST
	VEC_LMFBRU := VEC_VMFVDA - VEC_TMFIMP - VEC_CMFTOT

	VEC_CMFVEN := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VEC_COMVEN} })
	VEC_CMFGER := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VEC_COMGER} })

	VEC_DMFVAR := VEC_CMFVEN + VEC_CMFGER
	VEC_LMFLIQ := VEC_LMFBRU - VEC_DMFVAR
	VEC_DMFFIX := 0
	VEC_CMFFIX := 0
	VEC_CMFDEP := 0
	VEC_DMFADM := 0
	VEC_RMFFIN := VEC_LMFLIQ - VEC_DMFFIX - VEC_CMFFIX - VEC_DMFDEP - VEC_DMFADM

	dbSelectArea("TRB")
	MsUnlock()

	dbSelectArea("VS5")
	FG_Seek("VS5","cCodMap",1,.f.)

	dbSelectArea("VOQ")
	FG_Seek("VOQ","cCodMap",1,.f.)

	while !eof() .and. VOQ->VOQ_FILIAL == xFilial("VOQ")

		if VOQ_INDATI # "1" // Sim
			dbSkip()
			Loop
		Endif

		if VOQ_CODMAP # cCodMap
			Exit
		Endif

		cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)

		aadd(aStru,{ VS1->VS1_NUMORC,,SB1->B1_COD,VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,;
		VOQ_CODIGO,VOQ_SINFOR,0,0,SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,;
		VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,VS1->VS1_DATORC,0,0,VOQ_CTATOT})

		dbSkip()

	Enddo

	dbSelectArea("TRB")

	FG_CalcVlrs(aStru,SB1->B1_COD)
	cCpoDiv := cCpoDiv + "#" + str(len(aStru)+1,5)

Next

lCalcTot:= .t.

dbSelectArea("VS5")
FG_Seek("VS5","cCodMap",1,.f.)

dbSelectArea("VOQ")
FG_Seek("VOQ","cCodMap",1,.f.)

While !Eof() .and. VOQ->VOQ_FILIAL == xFilial("VOQ")

	if VOQ_INDATI # "1" // Sim
		dbSkip()
		Loop
	Endif

	if VOQ_CODMAP # cCodMap
		exit
	Endif

	cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)

	aadd(aStru,{ VO1->Vo1_NUMOSV,,"Total",VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,;
	VOQ_CODIGO,VOQ_SINFOR,0,0,SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,;
	VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,VS1->VS1_DATORC,0,0,VOQ_CTATOT}) // "Total da Venda"

	dbSkip()

Enddo

// Totaliza Mapa de Resultados quando mais de um Item
If Type("aStru") == "A"

	if Len(aStru) > 0
		cPriCta    := aStru[1,4]
		nQtdEMap   := aScan(aStru,{|x| x[4] == cPriCta},2) - 1  // Qtd de Elementos por Item no Mapa
		nTotStru   := (Len(aStru)-nQtdEMap) // Total de elementos no Vetor, exceto os elementos do Total da Venda
		nPosTotVda := nTotStru // Posicao ultimo elemento do vetor, anterior ao primeiro elemento do Total da Venda

		// Limpeza dos elementos do Total da Venda
		for ii := nPosTotVda+1 To Len(aStru)
			aStru[ii,09] := 0
			aStru[ii,12] := 0
		Next

		// Gravacao dos elementos do Total da Venda
		nSoma := nQtdEMap
		for ii := 1 To nTotStru
			nPosVet := (nPosTotVda+ii)-If(ii>nQtdEMap,nQtdEMap,0)
			if nPosVet > Len(aStru)
				nQtdEMap += nSoma
				nPosVet := (nPosTotVda+ii)-If(ii>nQtdEMap,nQtdEMap,0)
			Endif
			aStru[nPosVet,09] += aStru[ii,09]
			aStru[nPosVet,12] += aStru[ii,12]
		Next
		nTotItem := nTotStru + 1
		for ii := nTotItem To Len(aStru)
			aStru[ii,10] += ( aStru[ii,9]/aStru[nTotItem+1,9] ) * 100
		Next
	Endif
Endif

aHeader := aClone(aHeaderP)
aCols   := aClone(aColsP)
n       := nAnt

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM020CMPTES บAutor  ณRubens            บ Data ณ  11/01/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao da configuracao de movimentacao do estoque da TESบฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM020CMPTES( cTESOrig, cTESDest , cMsgAdic )

Local cMovTesAnt, cMovTesAtu

Default cMsgAdic := ""

cMovTesAnt := FM_SQL("SELECT F4_ESTOQUE FROM " + RetSQLName("SF4") + " F4 WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = '" + cTESOrig + "' AND D_E_L_E_T_ = ' '")
cMovTesAtu := FM_SQL("SELECT F4_ESTOQUE FROM " + RetSQLName("SF4") + " F4 WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = '" + cTESDest + "' AND D_E_L_E_T_ = ' '")

If cMovTesAtu <> cMovTesAnt
	MsgStop(STR0116 +" = '"+ cMovTesAnt +"' ( "+cTESOrig+" )"+CHR(13)+CHR(10)+; // "A Movimenta็ใo anterior foi com TES Movimenta Estoque"
			STR0117 +" = '"+ cMovTesAtu +"' ( "+cTESDest+" )"+CHR(13)+CHR(10)+; // "A Movimenta็ใo atual estแ com TES Movimenta Estoque"
			STR0118 + cMsgAdic,STR0075) // "A Opera็ใo serแ cancelada!"

	Return .f.
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM020AVCRED บAutor  ณRubens            บ Data ณ  05/03/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Avaliacao de credito                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM020AVCRED( cCodCli , cCodLoja, cTipTem , nValor )

Local lRetorno := .t.

// Nao verifica credito na requisicao de pecas ...
If !("P" $ cMVCHKCRE)
	Return .t.
EndIf
//
If !OM0200045_ChecaCredGar()
	Return .t.
EndIf

lVldCredLOK := .f.

SA1->(dbSetOrder(1))
If cCREDCLI == "C" // Verifica credito pela matriz
	SA1->(DbSeek(xFilial("SA1") + cCodCli ))
Else
	SA1->(DbSeek(xFilial("SA1") + cCodCli + cCodLoja ))
EndIf

// Cliente risco A so verifica data de vencimento de credito
If SA1->A1_RISCO == "A"
	If !Empty(SA1->A1_VENCLC) .And. SA1->A1_VENCLC < dDataBase
		lRetorno := .f.
	EndIf
Else

	VOI->(dbSetOrder(1))
	VOI->(MsSeek( xFilial("VOI") + cTipTem ))
	// Nao valida tipo de tempo de GARANTIA, INTERNO e REVISAO
	If !VOI->VOI_SITTPO $ "2/3/4"
		// Risco E sempre bloqueado
		If SA1->A1_RISCO == "E"
			lRetorno := .f.
		// Valida pelo ERP
		Else
			lRetorno := FGX_AVALCRED(cCodCli,cCodLoja,nValor,.f.)
		EndIf
	EndIf
EndIf

If !lRetorno
	Help("  ",1,"LIMITECRED",, cCodCli+"-"+cCodLoja ,4,1)
EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ITRELE บAutor  ณFabio               บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณItens relacionados na exporta็ใo do or็amento.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_ITRELE(nLin,cOpcao)

Local nCntFor
Local cCodSB1 := ""
Local cGrupoVal := aPecaOrc[nLin,6]
Local cCodIteVal := aPecaOrc[nLin,7]
Private cForVal := aPecaOrc[nLin,10]

aIteRel := FG_ITEREL(aPecaOrc[nLin,2],cGrupoVal,cCodIteVal,"cForVal")
For nCntFor := 1 to Len(aIteRel)
	DBSelectArea("SBM")
	DBSeek(xFilial("SBM")+aIteRel[nCntFor,1])
	DbSelectArea("VE1")
	DBSetOrder(1)
	DBSeek(xFilial("VE1")+SBM->BM_CODMAR)
	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFilial("SB1")+aIteRel[nCntFor,1]+aIteRel[nCntFor,2])
	if !Empty(aIteRel[nCntFor,1]+aIteRel[nCntFor,2])
		cCodSB1 := SB1->B1_COD
	Else
		cCodSB1 := ""
	Endif
	aAdd(aIteRel[nCntFor],SBM->BM_CODMAR)
	aAdd(aIteRel[nCntFor],VE1->VE1_DESMAR)
	aAdd(aIteRel[nCntFor],cCodSB1)
	//		aAdd(aIteRel[nCntFor],SB1->B1_COD)
next
//
If ( ExistBlock("OX001IRL") )
	aIteRel := ExecBlock("OX001IRL",.f.,.f.,{aIteRel})
EndIf
//
If len(aIteRel) <= 0
	aIteRel := {{"","","",0,0,"","",""}}
EndIf
//
oLItRel:nAt := 1
oLItRel:SetArray(aIteRel)
oLItRel:bLine := { || { aIteRel[oLItRel:nAt,6] ,;
aIteRel[oLItRel:nAt,7] ,;
aIteRel[oLItRel:nAt,8] ,;
aIteRel[oLItRel:nAt,1] ,;
aIteRel[oLItRel:nAt,2] ,;
aIteRel[oLItRel:nAt,3] ,;
FG_AlinVlrs(Transform(aIteRel[oLItRel:nAt,4],"@E 999,999")),;
FG_AlinVlrs(Transform(aIteRel[oLItRel:nAt,5],"@E 999,999,999.99"))}}
oLItRel:Refresh()
//

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM020CAN บAutor   ณ Thiago	           บ Data ณ  24/03/16 บฑฑ
ฑฑบAtual.    ณOM020CAN บAutor  ณ Fernando Vitor Cavani บ Data ณ  25/04/18 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cancelamento da nota fiscal de remessa.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM020CAN(cAlias, nReg, nOpc)
Local cSerie    := ""
Local cNota     := ""
Local aNFRem    := {}
Local aNFRemRet := {}
Local cAliasVDR := "SQLVDR"
Local aSizeAut  := {}


Private cCadastro := STR0001 //"Requisicao de Pecas"
Private oOk       := LoadBitmap(GetResources(), "LBTIK")
Private oNo       := LoadBitmap(GetResources(), "LBNO")

// Verifica็ใo NF de Remessa
cSQL := "SELECT DISTINCT VDR_NFSEMI, VDR_NFSNUM, VDR_NFSSER, VDR_NFENUM, VDR_CLIENT, VDR_LOJA, A1_NOME "
cSQL += "FROM " + RetSQLName("VDR") + " VDR "
cSQL += "JOIN " + RetSQLName("SA1") + " A1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = VDR_CLIENT "
cSQL += "  AND A1_LOJA = VDR_LOJA AND A1.D_E_L_E_T_ = ' ' "
cSQL += "WHERE VDR_FILIAL = '" + xFilial("VDR")  + "' "
cSQL += "  AND VDR_NUMOSV = '" + VO1->VO1_NUMOSV + "' "
cSQL += "  AND VDR.D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY VDR_NFSEMI, VDR_NFSNUM "
dbUseArea(.T., "TOPCONN", TcGenQry(,, cSQL), cAliasVDR, .T., .T.)

If (cAliasVDR)->(Eof())
	MsgInfo(STR0200) // "Nใo existe nota fiscal relacionada a esta ordem de servi็o"

	(cAliasVDR)->(dbCloseArea())
	dbSelectArea("VDR")

	Return
EndIf

While !(cAliasVDR)->(Eof())
	AADD(Iif(Empty((cAliasVDR)->VDR_NFENUM), aNFRem, aNFRemRet), {;
		.f.,                                                      ;
		(cAliasVDR)->VDR_NFSSER,                                  ;
		(cAliasVDR)->VDR_NFSNUM,                                  ;
		StoD((cAliasVDR)->VDR_NFSEMI),                            ;
		(cAliasVDR)->VDR_CLIENT,                                  ;
		(cAliasVDR)->VDR_LOJA,                                    ;
		(cAliasVDR)->A1_NOME,                                     ;
	})

	(cAliasVDR)->(dbSkip())
EndDo
(cAliasVDR)->(dbCloseArea())
dbSelectArea("VDR")

// Tela para selecionar a NF de Remessa
aSizeAut := MsAdvSize(.t.)
aInfo_   := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } // Tamanho total da tela

aObjects_ := {}
aAdd(aObjects_, { 0, 20, .T., .T. }) // ListBox NF Remessa Disponํvel para Cancelamento
aAdd(aObjects_, { 0, 20, .T., .T. }) // ListBox NF Remessa jแ Retornada

aPos_ := MsObjSize(aInfo_, aObjects_)

DEFINE MSDIALOG oDlg020Can TITLE STR0267 From aSizeAut[7], 00 to aSizeAut[6], aSizeAut[5];
	PIXEL of oMainWnd STYLE DS_MODALFRAME // "Cancelamento de Retorno de Remessa para Atendimento em Campo."

// Listbox NF Remessa Disponํvel para Cancelamento
@ aPos_[1,1], aPos_[1,2] TO aPos_[1,3], aPos_[1,4] LABEL (" " + STR0268 + " ") OF oDlg020Can PIXEL // Remessas Disponํveis para Cancelamento

oLbRem := TWBrowse():New(aPos_[1,1] + 009, aPos_[1,2] + 004, (aPos_[1,4] - aPos_[1,2] - 008), (aPos_[1,3] - aPos_[1,1] - 013),,,,;
	oDlg020Can,,,,,,,,,,,, .F.,, .T.,, .F.,,,)

oLbRem:nAt := 1
oLbRem:SetArray(aNFRem)
oLbRem:addColumn(TCColumn():New(" "                   , { || IIf(aNFRem[oLbRem:nAt,01], oOk, oNo)},,,,;
	"LEFT", 10, .T., .F.,,,, .F.,))

oLbRem:AddColumn(TCColumn():New(STR0272               , { || aNFRem[oLbRem:nAt,02]               },,,,; // S้rie
	"LEFT", 35, .F., .F.,,,, .F.,))

oLbRem:AddColumn(TCColumn():New(STR0273               , { || aNFRem[oLbRem:nAt,03]               },,,,; // N๚mero NF
	"LEFT", 40, .F., .F.,,,, .F.,))

oLbRem:AddColumn(TCColumn():New(STR0274               , { || aNFRem[oLbRem:nAt,04]               },,,,; // Data Emissใo
	"LEFT", 40, .F., .F.,,,, .F.,))

oLbRem:AddColumn(TCColumn():New(RetTitle("VDR_CLIENT"), { || aNFRem[oLbRem:nAt,05]               },,,,;
	 "LEFT", 40, .F., .F.,,,, .F.,))

oLbRem:AddColumn(TCColumn():New(RetTitle("VDR_LOJA")  , { || aNFRem[oLbRem:nAt,06]               },,,,;
	"LEFT", 30, .F., .F.,,,, .F.,))

oLbRem:AddColumn(TCColumn():New(RetTitle("A1_NOME")   , { || aNFRem[oLbRem:nAt,07]               },,,,;
	"LEFT", 70, .F., .F.,,,, .F.,))

oLbRem:bLDblClick := { || OM020TIKCAN(@aNFRem, @cSerie, @cNota, oLbRem:nAt,01), oLbRem:Refresh() }

oLbRem:Refresh()
// Fim Listbox NF Remessa Disponํvel para Cancelamento

// Listbox NF Remessa jแ Retornada
@ aPos_[2,1] + 002, aPos_[2,2] + 001 TO aPos_[2,3], aPos_[2,4] LABEL (" " + STR0269 + " ") OF oDlg020Can PIXEL // Remessas jแ Retornadas

oLbRemRet := TWBrowse():New(aPos_[2,1] + 011, aPos_[2,2] + 005, (aPos_[2,4] - aPos_[2,2] - 009), (aPos_[2,3] - aPos_[2,1] - 015),,,,;
	oDlg020Can,,,,,,,,,,,, .F.,, .T.,, .F.,,,)

oLbRemRet:nAt := 1
oLbRemRet:SetArray(aNFRemRet)
oLbRemRet:AddColumn(TCColumn():New(STR0272               , { || aNFRemRet[oLbRemRet:nAt,02] },,,,; // S้rie
	"LEFT", 35, .F., .F.,,,, .F.,))

oLbRemRet:AddColumn(TCColumn():New(STR0273               , { || aNFRemRet[oLbRemRet:nAt,03] },,,,; // N๚mero NF
	"LEFT", 40, .F., .F.,,,, .F.,))

oLbRemRet:AddColumn(TCColumn():New(STR0274               , { || aNFRemRet[oLbRemRet:nAt,04] },,,,; // Data Emissใo
	"LEFT", 40, .F., .F.,,,, .F.,))

oLbRemRet:AddColumn(TCColumn():New(RetTitle("VDR_CLIENT"), { || aNFRemRet[oLbRemRet:nAt,05] },,,,;
	 "LEFT", 40, .F., .F.,,,, .F.,))

oLbRemRet:AddColumn(TCColumn():New(RetTitle("VDR_LOJA")  , { || aNFRemRet[oLbRemRet:nAt,06] },,,,;
	"LEFT", 30, .F., .F.,,,, .F.,))

oLbRemRet:AddColumn(TCColumn():New(RetTitle("A1_NOME")   , { || aNFRemRet[oLbRemRet:nAt,07] },,,,;
	"LEFT", 70, .F., .F.,,,, .F.,))

oLbRemRet:Refresh()
// Fim Listbox NF Remessa jแ Retornada

ACTIVATE MSDIALOG oDlg020Can ON INIT (EnchoiceBar(oDlg020Can, { || IIf(OM020PCAN(cSerie, cNota),;
	oDlg020Can:End(), NIL) }, { || oDlg020Can:End() }))
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM020REM  บAutor  ณ Takahashi          บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera nota fiscal de remessa.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM020REM(cAlias,nReg,nOpc)

Local nCont
Local nCont2

Local cParOPER
Local cParCODTES
Local cParFATPAR
Local cParLOJA

Local cCpoEnch := "VDR_NUMOSV/VDR_CLIENT/VDR_LOJA  "
Local cCpoGetD := "VDR_TIPTEM/VDR_GRUITE/VDR_CODITE/VDR_OPER  /VDR_CODTES/VDR_QTDREQ/VDR_QTDEXT/VDR_QTDREM/VDR_VALUNI/VDR_LOCAL /"

Local aSizeAut := {}
Local aObjects := {}

Local aHRemAlt := {}
Local aEncVDR  := {}

Local aColsVDR := {}

Local nVDRTIPTEM := 0
Local nVDRGRUITE := 0
Local nVDRCODITE := 0
Local nVDRQTDREQ := 0
Local nVDRQTDEXT := 0
Local nVDRQTDREM := 0
Local nVDROPER   := 0
Local nVDRCODTES := 0
Local nVDRVALUNI := 0
Local nVDRLOCAL  := 0
Local aParamBox  := {}
Local aRetParam  := {}

Local cFatParRem := ""
Local nTamX3Cli  := ""
Local nTamX3Loj  := ""

Local oOficina   := DMS_Oficina():New()

Local aTpFrete   := {}
Local nPos1      := 0

Private aHRem  := {}
Private cParFORMUL
Private cTransp  := ""
Private cVeicul  := ""
Private cMenNota := ""
Private cMenPad  := ""
Private nPesoL   := 0
Private nPesoB   := ""
Private nVolum1  := 0
Private nVolum2  := 0
Private nVolum3  := 0
Private nVolum4  := 0
Private cEspec1  := ""
Private cEspec2  := ""
Private cEspec3  := ""
Private cEspec4  := ""

Private cNaturez := ""
Private lSC5NATUREZ := SC5->(FieldPos("C5_NATUREZ")) <> 0

Private cVend1   := ""
Private lSC5VEND1 := SC5->(FieldPos("C5_VEND1")) <> 0

Private cTpFrete := ""
Private cGrpSX1 := "OFM020REM"

if Type("aHeader")== "U"
	aHeader := {}
endif

DbSelectArea("VO2")
DbSetOrder(1)
DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV+"P")
RegToMemory("VO2",.T.)

aPeca := FMX_CALPEC( VO1->VO1_NUMOSV ,;
						/* cTipTem */ ,;
						/* cGruIte*/ ,;
						/* cCodIte */ ,;
						.f. /* lMov */ ,;
						.f. /* lNegoc */ ,;
						.t. /* lReqZerada */ ,;
						.t. /* lRetAbe */ ,;
						.f. /* lRetLib */ ,;
						.f. /* lRetFec */ ,;
						.f. /* lRetCan */ ,;
						/* cLibVOO */ ,;
						/* cFiltroSQL */ ,;
						.t. /* lRetRem */)

// Se nao achar requisicao de peca ...
If Len(aPeca) <= 0
	MsgInfo(STR0243) // "Ordem de servi็o nใo possui pe็as requisitadas."
	Return .f.
EndIf
//
If lCtrlLote .and. aScan(aPeca, { |x| !Empty(x[PECA_LOTECT]) } ) <> 0
	Return .f.
EndIf

Pergunte(cGrpSX1,.f.,,,,.f.)

nMVPar06 := MV_PAR06 // Para utilizar na fun็ใo OM020007B_ValidacaoMVPAR06 para valida็ใo do parโmetro MV_PAR06.

cFatParRem := If(!Empty(VO1->VO1_FATPAR+VO1->VO1_LOJA),VO1->VO1_FATPAR+VO1->VO1_LOJA,VO1->VO1_PROVEI+VO1->VO1_LOJPRO)
nTamX3Cli := If(!Empty(VO1->VO1_FATPAR+VO1->VO1_LOJA),TamSX3("VO1_FATPAR")[1],TamSX3("VO1_PROVEI")[1])
nTamX3Loj := If(!Empty(VO1->VO1_FATPAR+VO1->VO1_LOJA),TamSX3("VO1_LOJA")[1],TamSX3("VO1_LOJPRO")[1])

SetMVValue(cGrpSX1, "MV_PAR04", Subs(cFatParRem,1,nTamX3Cli))
SetMVValue(cGrpSX1, "MV_PAR05", Subs(cFatParRem,nTamX3Cli+1,nTamX3Loj))

If ExistBlock("OM020PAR")
	ExecBlock("OM020PAR",.f.,.f., cGrpSX1)
EndIf

While .t. 
	If Pergunte(cGrpSX1,.t.,,,,.f.)
		If (MV_PAR23 <> 5 .and. MV_PAR24 == 1) .or.;
			(MV_PAR23 == 5 .and. MV_PAR24 <> 1)
			Exit
		Else
			MsgInfo(STR0300,STR0075) //"Selecione apenas um tipo de frete para a opera็ใo"
		EndIf
	Else
		Return .f.
	EndIf
EndDo

If MV_PAR23 <> 5 .and. MV_PAR24 == 1
	//MV_PAR23
	aAdd(aTpFrete,{1, "C" })
	aAdd(aTpFrete,{2, "F" })
	aAdd(aTpFrete,{3, "T" })
	aAdd(aTpFrete,{4, "S" })
ElseIf MV_PAR23 == 5 .and. MV_PAR24 <> 1
	//MV_PAR24
	aAdd(aTpFrete,{1, "R" })
	aAdd(aTpFrete,{2, "D" })
EndIf

nPos1 := aScan(aTpFrete,{|x| cValToChar(x[1]) == cValToChar(If(MV_PAR23=5,MV_PAR24,MV_PAR23)) })

cParOPER    := MV_PAR01
cParCODTES  := MV_PAR02
cParFORMUL  := MV_PAR03
cParFATPAR  := MV_PAR04
cParLOJA    := MV_PAR05
cTransp     := MV_PAR07
cVeicul     := MV_PAR08
cMenNota    := MV_PAR09 + MV_PAR25 + MV_PAR26 // Alex - Mens. Padrใo (1)+(2)+(3) - Necessแrio criar mais duas perguntas, pois a SX1 s๓ permite colocar tamanho de duas casas decimais, enquanto na SX3, ้ possํvel colocar tr๊s casas decimais no tamanho
cMenPad     := MV_PAR10
nPesoL      := MV_PAR11
nPesoB      := MV_PAR12
nVolum1     := MV_PAR13
nVolum2     := MV_PAR14
nVolum3     := MV_PAR15
nVolum4     := MV_PAR16
cEspec1     := MV_PAR17
cEspec2     := MV_PAR18
cEspec3     := MV_PAR19
cEspec4     := MV_PAR20
cNaturez    := MV_PAR21
cVend1      := MV_PAR22
cTpFrete    := aTpFrete[nPos1,2]

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VDR")
While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO == "VDR")

	&("M->"+AllTrim(SX3->X3_CAMPO)) := CriaVar(SX3->X3_CAMPO,.f.)

	If X3USO(SX3->X3_USADO) .And. (cNivel>=SX3->X3_NIVEL .or. X3OBRIGAT(SX3->X3_CAMPO))
		// Enchoice
		If (AllTrim(SX3->X3_CAMPO) $ cCpoEnch)
			AADD(aEncVDR,SX3->X3_CAMPO)
		EndIf
		// GetDados
		If (AllTrim(SX3->X3_CAMPO) $ cCpoGetD)
			Aadd(aHRem, {AllTrim(X3Titulo()), SX3->X3_CAMPO,		SX3->X3_PICTURE, 	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,     SX3->X3_VALID,		SX3->X3_USADO, 		SX3->X3_TIPO,;
							SX3->X3_F3,			 SX3->X3_CONTEXT,	X3CBOX(), 			SX3->X3_RELACAO })

			IF SX3->X3_VISUAL <> "V"
				Aadd(aHRemAlt,SX3->X3_CAMPO)
			ENDIF
		Endif
	Endif
	SX3->(dbSkip())
End

M->VDR_NUMOSV := VO1->VO1_NUMOSV
M->VDR_CLIENT := cParFATPAR
M->VDR_LOJA   := cParLOJA

nVDRTIPTEM := FG_POSVAR("VDR_TIPTEM","aHRem")
nVDRGRUITE := FG_POSVAR("VDR_GRUITE","aHRem")
nVDRCODITE := FG_POSVAR("VDR_CODITE","aHRem")
nVDRQTDREQ := FG_POSVAR("VDR_QTDREQ","aHRem")
nVDRQTDEXT := FG_POSVAR("VDR_QTDEXT","aHRem")
nVDRQTDREM := FG_POSVAR("VDR_QTDREM","aHRem")
nVDROPER   := FG_POSVAR("VDR_OPER  ","aHRem")
nVDRCODTES := FG_POSVAR("VDR_CODTES","aHRem")
nVDRVALUNI := FG_POSVAR("VDR_VALUNI","aHRem")
nVDRLOCAL  := FG_POSVAR("VDR_LOCAL" ,"aHRem")

// Pecas ..
For nCont := 1 to Len(aPeca)
	if (aPeca[nCont,PECA_QTDREQ]-aPeca[nCont,PECA_QTDREM]) <= 0
		Loop
	Endif
	AADD(aColsVDR, Array(Len(aHRem)+1))
	aColsVDR[Len(aColsVDR),Len(aHRem)+1] := .f.
	For nCont2 := 1 to Len(aHRem)
		aColsVDR[Len(aColsVDR),nCont2] := &("M->"+AllTrim(aHRem[nCont2,2]))
	Next nCont2

	If oOficina:TipoTempoBloqueado(aPeca[nCont,PECA_TIPTEM],.t.) // Valida se Tipo de Tempo esta BLOQUEADO
		Return .f.
	endif

	aColsVDR[Len(aColsVDR),nVDRTIPTEM] := aPeca[nCont,PECA_TIPTEM]
	aColsVDR[Len(aColsVDR),nVDRGRUITE] := aPeca[nCont,PECA_GRUITE]
	aColsVDR[Len(aColsVDR),nVDRCODITE] := aPeca[nCont,PECA_CODITE]
	aColsVDR[Len(aColsVDR),nVDRQTDREQ] := aPeca[nCont,PECA_QTDREQ]
	aColsVDR[Len(aColsVDR),nVDRQTDEXT] := aPeca[nCont,PECA_QTDREM]
	aColsVDR[Len(aColsVDR),nVDRQTDREM] := aColsVDR[Len(aColsVDR),nVDRQTDREQ]-aColsVDR[Len(aColsVDR),nVDRQTDEXT]

	cAuxTES := cParCODTES
	If !Empty(cParOPER) .and. !Empty(cParFATPAR)
		SB1->(dbSetOrder(7))
		SB1->(dbSeek(xFilial("SB1") + aPeca[nCont,PECA_GRUITE] + aPeca[nCont,PECA_CODITE] ))
		SB1->(dbSetOrder(1))
		cAuxTES := MaTesInt(2,cParOPER,cParFATPAR,cParLOJA,"C",SB1->B1_COD)
		If Empty(cAuxTES)
			cAuxTES := cParCODTES
		EndIf
		If !OM0200032_VldTesRemManutExt(cAuxTES,"REM")		
			Return .f.
		Endif
	EndIf

	aColsVDR[Len(aColsVDR),nVDRCODTES] := cAuxTES
	aColsVDR[Len(aColsVDR),nVDROPER  ] := cParOPER
	aColsVDR[Len(aColsVDR),nVDRLOCAL ] := VOI->VOI_CODALM

	// Valor da Peca
	If !Empty(cParFORMUL)
		nAuxValPec := 0
		aColsVDR[Len(aColsVDR),nVDRVALUNI] := FG_VALPEC(aPeca[nCont,PECA_TIPTEM],"cParFORMUL",aPeca[nCont,PECA_GRUITE],aPeca[nCont,PECA_CODITE],"M->VDR_VALUNI",.F.,.t.)
	EndIf
	//

Next nCont
//
if len(aColsVDR) == 0
	MsgInfo("Nใo ha itens para realizar a remessa")
	Return(.f.)
Endif
aSizeAut := MsAdvSize(.t.)
AADD( aObjects, { 100,  093, .T., .F. } ) // Enchoice
AADD( aObjects, { 100,  100, .T., .T. } ) // GetDados
aPosicao := MsObjSize( { aSizeAut[ 1 ] , aSizeAut[ 2 ] ,aSizeAut[ 3 ] , aSizeAut[ 4 ] , 2 , 2 } , aObjects , .T. )

oDlg020Rem := MSDIALOG():New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],STR0157,,,,128,,,,,.t.) // "Remessa Atendimento Externo"

// Cabecalho
oEnchVDR := MSMGet():New("VDR", 1 , 3,;
	/* aCRA */, /* cLetra */, /* cTexto */, aEncVDR, aPosicao[1], aEncVDR , 3 /* nModelo */ ,;
	/* nColMens */, /* cMensagem */, ".T." /* cTudoOk */ , oDlg020Rem, .f. /* lF3 */ , .t. /* lMemoria */ , .T. /* lColumn */ ,;
	"" /* caTela */ , .t. /* lNoFolder */, .f. /* lProperty */)

cLinOk  := "AllwaysTrue()"
cTudoOk := "AllwaysTrue()"
cFieldOK := "AllwaysTrue()"
// Itens
oGetRem := MsNewGetDados():New(aPosicao[2,1],aPosicao[2,2],aPosicao[2,3],aPosicao[2,4],;
				(GD_UPDATE),; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
				cLinOk,cTudoOk,;
				,;		// Nome dos campos do tipo caracter que utilizacao incremento automatico
				aHRemAlt ,; 	// Campos alteraveis da GetDados
				/* nFreeze */,;	// Campos estaticos da GetDados
				Len(aColsVDR),;
				cFieldOK,;
				/* cSuperDel */,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
				/* cDelOk */,; 		// Funcao executada para validar a exclusao de uma linha
				oDlg020Rem,;
				aHRem,;
				aColsVDR)
oGetRem:oBrowse:bChange := { || FG_MEMVAR(oGetRem:aHeader,oGetRem:aCols,oGetRem:nAt) }

ACTIVATE MSDIALOG oDlg020Rem ON INIT ( EnchoiceBar(oDlg020Rem, { || IIf( OM020PREM() , oDlg020Rem:End() , NIL ) }, { || oDlg020Rem:End() } ) )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM020VR   บAutor  ณ Takahashi          บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao da dialog de remessa                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM020VR(cCpoVDR)

Local lRetorno := .t.
Default cCpoVDR := ReadVar()

If cCpoVDR == "M->VDR_QTDREM"
	If M->VDR_QTDREM > (M->VDR_QTDREQ - M->VDR_QTDEXT)
		MsgAlert(STR0158) // "Quantidade invแlida"
		lRetorno := .f.
	EndIf
ElseIf cCpoVDR == "M->VDR_QTDUTI"
	If M->VDR_QTDUTI > M->VDR_QTDREM
		MsgAlert(STR0158) // "Quantidade invแlida"
		lRetorno := .f.
	EndIf
EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ'OM020OPER บAutor  ณ Thiago            บ Data ณ  12/04/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao do tipo de operacao.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM020OPER()
Local nVDRCODTES := FG_POSVAR("VDR_CODTES","aHRem")

dbSelectArea("SB1")
dbSetOrder(7)
dbSeek(xFilial("SB1")+M->VDR_GRUITE+M->VDR_CODITE)
DBSetOrder(1)

M->VDR_CODTES := MaTesInt(2,M->VDR_OPER,M->VDR_CLIENT,M->VDR_LOJA,"C",SB1->B1_COD)
oGetRem:aCols[n,nVDRCODTES] := M->VDR_CODTES

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOM020PREM บAutor  ณ Takahashi          บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa remessa para atendimento em campo                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OM020PREM()

Local aIteTempPV := {}
Local aPvlNfs    := {}

Local cNumPed
Local nCont
Local aInfNF := {}
Local lRet

Local cSerie
Local cNota

Local cSQL
Local cAliasSD2 := "TSD2"

Local cMsgSC9 := ""

Local lESTNEG  := (GetMV("MV_ESTNEG") == "S")

Local nVDRTIPTEM := FG_POSVAR("VDR_TIPTEM","aHRem")
Local nVDRGRUITE := FG_POSVAR("VDR_GRUITE","aHRem")
Local nVDRCODITE := FG_POSVAR("VDR_CODITE","aHRem")

Local nVDRQTDREM := FG_POSVAR("VDR_QTDREM","aHRem")
Local nVDROPER   := FG_POSVAR("VDR_OPER  ","aHRem")
Local nVDRCODTES := FG_POSVAR("VDR_CODTES","aHRem")
Local nVDRVALUNI := FG_POSVAR("VDR_VALUNI","aHRem")
Local nVDRLOCAL  := FG_POSVAR("VDR_LOCAL" ,"aHRem")

Private aCabPv     := {}
Private aItePv     := {}

If !MsgYesNo(STR0159) // "Confirma remessa de pe็as"
	Return .f.
EndIf

lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"), " - " + STR0160) // "Remessa"
If !lRet
	Return .f.
EndIf

SA1->(dbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+M->VDR_CLIENT + M->VDR_LOJA))

Begin Transaction

cNumPed  := CriaVar("C5_NUM")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cabecalho do Pedido de Venda ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aCabPV,{"C5_NUM"    , cNumPed		  		,Nil}) // Numero do pedido
aAdd(aCabPV,{"C5_TIPO"   , "N"			 		,Nil}) // Tipo de pedido
aAdd(aCabPV,{"C5_CLIENTE", SA1->A1_COD			,Nil}) // Codigo do cliente
aAdd(aCabPV,{"C5_LOJACLI", SA1->A1_LOJA			,Nil}) // Loja do cliente
aAdd(aCabPV,{"C5_TIPOCLI", SA1->A1_TIPO	 		,Nil}) // Tipo do Cliente
aAdd(aCabPV,{"C5_EMISSAO", dDataBase			,Nil}) // Data de emissao
aAdd(aCabPV,{"C5_CONDPAG", RetCondVei()			,Nil}) // Codigo da condicao de pagamento
aAdd(aCabPV,{"C5_DESC1"  , 0			  		,Nil}) // Percentual do Desconto Geral
aAdd(aCabPV,{"C5_INCISS" ,"N"					,Nil}) // ISS Incluso
aAdd(aCabPV,{"C5_TIPLIB" , "2"			 		,Nil}) // Tipo de Liberacao ( 2 - Libera por Pedido de Venda. )
aAdd(aCabPV,{"C5_MOEDA"  , 1					,Nil}) // Moeda
aAdd(aCabPV,{"C5_LIBEROK", "S"					,Nil}) // Liberacao Total
aAdd(aCabPV,{"C5_COMIS1" , 0					,Nil}) // Percentual de Comissao
If SC5->(FieldPos("C5_INDPRES")) > 0
	aAdd(aCabPV,{"C5_INDPRES"  ,'0'	,Nil}) 	// Presenca do Comprador
Endif
aAdd(aCabPV, {"C5_TRANSP" , cTransp  	, Nil})
aAdd(aCabPV, {"C5_VEICULO", cVeicul    , Nil})
aAdd(aCabPV, {"C5_PESOL"  , nPesoL     , Nil})
aAdd(aCabPV, {"C5_PBRUTO" , nPesoB     , Nil})
aAdd(aCabPV, {"C5_VOLUME1", nVolum1    , Nil})
aAdd(aCabPV, {"C5_VOLUME2", nVolum2    , Nil})
aAdd(aCabPV, {"C5_VOLUME3", nVolum3    , Nil})
aAdd(aCabPV, {"C5_VOLUME4", nVolum4    , Nil})
aAdd(aCabPV, {"C5_ESPECI1", cEspec1    , Nil})
aAdd(aCabPV, {"C5_ESPECI2", cEspec2    , Nil})
aAdd(aCabPV, {"C5_ESPECI3", cEspec3    , Nil})
aAdd(aCabPV, {"C5_ESPECI4", cEspec4    , Nil})
aAdd(aCabPV, {"C5_MENNOTA", cMenNota   , Nil})
aAdd(aCabPV, {"C5_MENPAD" , cMenPad    , Nil})
If lSC5NATUREZ
	aAdd(aCabPV, {"C5_NATUREZ" , cNaturez , Nil})
EndIf

If lSC5VEND1
	aAdd(aCabPV, {"C5_VEND1" , cVend1 , Nil})
EndIf

aAdd(aCabPV, {"C5_TPFRETE" , cTpFrete    , Nil})

If ExistBlock("OM020SC5")
	aCabPV := ExecBlock("OM020SC5",.f.,.f.,{aCabPV})
EndIf

SB1->(dbSetOrder(7))

cItemPed := "00"

For nCont := 1 to Len(oGetRem:aCols)

	If oGetRem:aCols[nCont,Len(oGetRem:aCols[nCont])]
		Loop
	EndIf

	If oGetRem:aCols[nCont, nVDRQTDREM] <= 0
		Loop
	EndIf

	aIteTempPV := {}
	cItemPed := Soma1( cItemPed , 2 )

	//Items
	SB1->(dbSeek(xFilial("SB1") + oGetRem:aCols[nCont, nVDRGRUITE] + oGetRem:aCols[nCont, nVDRCODITE] ))

	aAdd(aIteTempPV,{"C6_NUM"    ,cNumPed							,Nil}) // Numero do Pedido
	aAdd(aIteTempPV,{"C6_ITEM"   ,cItemPed							,Nil}) // Numero do Item no Pedido
	aAdd(aIteTempPV,{"C6_PRODUTO",SB1->B1_COD						,Nil}) // Codigo do Produto
	aAdd(aIteTempPV,{"C6_QTDVEN" ,oGetRem:aCols[nCont, nVDRQTDREM ]	,Nil}) // Quantidade Vendida
	aAdd(aIteTempPV,{"C6_PRUNIT" ,oGetRem:aCols[nCont, nVDRVALUNI ]	,Nil}) // Preco Unitario Garantia
	aAdd(aIteTempPV,{"C6_PRCVEN" ,oGetRem:aCols[nCont, nVDRVALUNI ]	,Nil}) // Preco Unitario Liquido
	aAdd(aIteTempPV,{"C6_VALOR"  ,A410Arred(oGetRem:aCols[nCont, nVDRQTDREM ] * oGetRem:aCols[nCont, nVDRVALUNI ],"C6_VALOR")	,Nil}) // Valor Total do Item
	aAdd(aIteTempPV,{"C6_ENTREG" ,dDataBase							,Nil}) // Data da Entrega
	aAdd(aIteTempPV,{"C6_UM"     ,SB1->B1_UM						,Nil}) // Unidade de Medida Primar.
	aAdd(aIteTempPV,{"C6_TES"    ,oGetRem:aCols[nCont, nVDRCODTES ]	,Nil}) // Tipo de Entrada/Saida do Item
	aAdd(aIteTempPV,{"C6_LOCAL"  ,oGetRem:aCols[nCont, nVDRLOCAL  ]	,Nil}) // Almoxarifado
	aAdd(aIteTempPV,{"C6_QTDLIB" ,0									,Nil}) // Quantidade Liberada

	If ExistBlock("OM020SC6")
		aIteTempPV := ExecBlock("OM020SC6",.f.,.f.,{aIteTempPV})
	EndIf	

	aAdd(aItePv,aIteTempPV)

	RecLock("VDR",.t.)
	VDR->VDR_FILIAL := xFilial("VDR")
	VDR->VDR_NUMOSV := M->VDR_NUMOSV
	VDR->VDR_CLIENT := M->VDR_CLIENT
	VDR->VDR_LOJA   := M->VDR_LOJA
	VDR->VDR_TIPTEM := oGetRem:aCols[nCont,nVDRTIPTEM]
	VDR->VDR_OPER   := oGetRem:aCols[nCont,nVDROPER  ]
	VDR->VDR_CODTES := oGetRem:aCols[nCont,nVDRCODTES]
	VDR->VDR_GRUITE := oGetRem:aCols[nCont,nVDRGRUITE]
	VDR->VDR_CODITE := oGetRem:aCols[nCont,nVDRCODITE]
	VDR->VDR_QTDREM := oGetRem:aCols[nCont,nVDRQTDREM]
	VDR->VDR_VALUNI := oGetRem:aCols[nCont,nVDRVALUNI]
	VDR->VDR_LOCAL  := oGetRem:aCols[nCont,nVDRLOCAL ]
	VDR->VDR_PEDNUM := cNumPed
	VDR->VDR_PEDITE := cItemPed
	VDR->(MsUnlock())
Next

if ExistBlock("OM020APV")
	if !ExecBlock("OM020APV",.f.,.f.)
		DisarmTransaction()
		RollbackSx8()
		MsUnlockAll()
		Return(.f.)
	Endif
Endif

lMSHelpAuto := .t.
lMsErroAuto := .f.
MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabPv,aItePV,3)

if lMsErroAuto
	DisarmTransaction()
	RollbackSx8()
	MsUnlockAll()
	MostraErro()
	Return .f.
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ LIBERACAO do Pedido de Venda ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//IncProc(STR0060) // "Liberando Pedido de Venda"
lCredito := .t.
lEstoque := .t.
lLiber   := .t.
lTransf  := .f.

SC9->(dbSetOrder(1))
SC6->(dbSetOrder(1))
SC6->(dbSeek(xFilial("SC6") + cNumPed + "01"))
While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPed

	If !SC9->(dbSeek(xFilial("SC9")+cNumPed+SC6->C6_ITEM))
		nQtdLib := SC6->C6_QTDVEN
		nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,(!lESTNEG),lLiber,lTransf)
	EndIf

	SC6->(dbSkip())
Enddo
//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Selecionando Itens para Faturamento ... ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SB1->(dbSetOrder(1))
SC5->(dbSetOrder(1))
SC6->(dbSetOrder(1))
SB5->(dbSetOrder(1))
SB2->(dbSetOrder(1))
SF4->(dbSetOrder(1))
SE4->(dbSetOrder(1))
SC9->(dbSeek(xFilial("SC9") + cNumPed + "01"))
While !SC9->(Eof()) .and. xFilial("SC9") == SC9->C9_FILIAL .and. SC9->C9_PEDIDO == cNumPed
	If Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLEST)
		SC5->(dbSeek( xFilial("SC5") + SC9->C9_PEDIDO ))
		SC6->(dbSeek( xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM ))
		SB1->(dbSeek( xFilial("SB1") + SC9->C9_PRODUTO ))
		SB2->(dbSeek( xFilial("SB2") + SB1->B1_COD ))
		SB5->(dbSeek( xFilial("SB5") + SB1->B1_COD ))
		SF4->(MsSeek( xFilial("SF4") + SC6->C6_TES ))
		SE4->(MsSeek( xFilial("SE4") + SC5->C5_CONDPAG ))
		aAdd(aPvlNfs,{SC9->C9_PEDIDO,;
						SC9->C9_ITEM,;
						SC9->C9_SEQUEN,;
						SC9->C9_QTDLIB,;
						SC9->C9_PRCVEN,;
						SC9->C9_PRODUTO,;
						SF4->F4_ISS=="S",;
						SC9->(RecNo()),;
						SC5->(RecNo()),;
						SC6->(RecNo()),;
						SE4->(RecNo()),;
						SB1->(RecNo()),;
						SB2->(RecNo()),;
						SF4->(RecNo())})
	Else
		If !Empty(SC9->C9_BLCRED)
			cMsgSC9 += AllTrim(RetTitle("C9_PRODUTO"))+": "+Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLCRED"))+": "+SC9->C9_BLCRED+CHR(13)+CHR(10)
		EndIf
		If !Empty(SC9->C9_BLEST)
			cMsgSC9 += AllTrim(RetTitle("C9_PRODUTO"))+": "+Alltrim(SC9->C9_PRODUTO)+" - "+AllTrim(RetTitle("C9_BLEST"))+": "+SC9->C9_BLEST+CHR(13)+CHR(10)
		EndIf
	EndIf
	SC9->(dbSkip())
Enddo

If !Empty(cMsgSC9)
	MsgStop(STR0161+CHR(13)+CHR(10)+CHR(13)+CHR(10)+cMsgSC9) // Existem um ou mais itens do pedido de venda (SC5) que nใo foram liberados. / Atencao
	DisarmTransaction()
	RollbackSx8()
	MsUnlockAll()
	Return(.f.)
EndIf

If len(aPvlNfs) == 0 .and. !FGX_SC5BLQ(cNumPed,.t.) // Verifica SC5 bloqueado
	DisarmTransaction()
	RollbackSx8()
	MsUnlockAll()
	Return(.f.)
EndIf

ConfirmSx8()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Gera F2/D2, Atualiza Estoque, Financeiro, Contabilidade             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PERGUNTE("MT460A",.f.)

//SE4->(dbSetOrder(1))
//SE4->(MsSeek( xFilial("SE4") + M->VOO_CONDPG ))

nCntSE1 := 0
cNota := MaPvlNfs(aPvlNfs,;           // 01
				  cSerie,;            // 02
				  (mv_par01 == 1),;   // 03
				  (mv_par02 == 1),;   // 04
				  (mv_par03 == 1),;   // 05
				  (mv_par04 == 1),;   // 06
				  .F.,;               // 07
				  0,;                 // 08
				  0,;                 // 09
				  .T.,;               // 10
				  .F.,;               // 11
				  ,;				  // 12
				  ,;				  // 13
				  ,;				  // 14
				  ,;				  // 15
				  ,)				  // 16
If lMsErroauto
	DisarmTransaction()
	RollbackSx8()
	MsUnlockAll()
	MostraErro()
	Return(.f.)
EndIf
ConfirmSx8()

// Acerta o tamanho da variavel ...
cNota := PadR(cNota,SF2->(TamSx3("F2_DOC")[1]))
//

// Grava numero da nota fiscal ...
VDR->(dbSetOrder(2))

cSQL := "SELECT D2_PEDIDO , D2_ITEMPV , D2_ITEM "
cSQL += " FROM " + RetSQLName("SD2")
cSQL += " WHERE D2_FILIAL = '" + xFilial("SD2") + "'"
cSQL += " AND D2_PEDIDO = '" + cNumPed + "'"
cSQL += " AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cAliasSD2, .T., .T. )
While !(cAliasSD2)->(Eof())
	If VDR->(dbSeek(xFilial("VDR") + (cAliasSD2)->D2_PEDIDO + (cAliasSD2)->D2_ITEMPV ))
		RecLock("VDR",.f.)
		VDR->VDR_NFSEMI := dDataBase
		VDR->VDR_NFSSER := cSerie
		VDR->VDR_NFSNUM := cNota
		VDR->VDR_NFSITE := (cAliasSD2)->D2_ITEM
	EndIf
	(cAliasSD2)->(dbSkip())
End
(cAliasSD2)->(dbCloseArea())
//

AADD( aInfNF , { cSerie , ;	// Serie da NF
				 cNota  , ;	// Numero da NF
				 Upper(STR0160) } )	// Remessa

End Transaction

dbSelectArea("SF2")
dbSetOrder(1)
if dbSeek(xFilial("SF2")+cNota+cSerie)
	reclock("SF2",.f.)
	SF2->F2_PREFORI := GetNewPar("MV_PREFOFI","OFI")
	msunlock()
Endif
// Por algum motivo o cliente permanece bloqueado
SA1->(MsUnLock())
//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SX6")
MsRUnLock()
//

If ExistBlock("OM020GREM")
	ExecBlock("OM020GREM",.f.,.f.,{cNota,cSerie})
EndIf

FMX_TELAINF( "1", aInfNF )

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM020RET บAutor  ณ Takahashi          บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera nota fiscal de retorno de remessa.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM020RET(cAlias,nReg,nOpc)

Local nCont
Local nCont2
Local lContinua

Local cSQL
Local cAliasVDR := "TVDR"

Local cCpoEnch := "VDR_NUMOSV/VDR_CLIENT/VDR_LOJA  /VDR_NFSNUM/VDR_NFSSER/VDR_NFSEMI"
Local cCpoGetD := "VDR_NFSITE/VDR_TIPTEM/VDR_GRUITE/VDR_CODITE/VDR_CODTES/VDR_QTDREM/VDR_QTDUTI/VDR_VALUNI/"
Local cCpoGetDN := "VDR_NFSITE/VDR_TIPTEM/VDR_GRUITE/VDR_CODITE/VDR_CODTES/VDR_QTDREM/VDR_VALUNI/"

Local aSizeAut := {}
Local aObjects := {}

Local aNFRem := {}

Local aHRetAlt := {}
Local aEncVDR  := {}

Local aColsVDR := {}

Local nVDRCODTES := 0
Local lContinue  := .t.
Local aFormul    := {"1="+STR0249,"2="+STR0250}
Local aDevMerc   := {"","S="+STR0249,"N="+STR0250}
Local lAlteraQtde

Local oChaveNFE

Private aHRet  := {}
Private nMVPar06 := 0

Private cRemSerie := ""
Private cRemNota  := ""

Private oOk := LoadBitmap( GetResources(), "LBTIK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

Private cNumNF     := space(TamSX3("D1_DOC")[1])
Private cSerNF     := space(TamSX3("D1_SERIE")[1])
Private cChaveNFE  := space(TamSX3("F1_CHVNFE")[1])

Pergunte("OFM020REM",.f.,,,,.f.)
lAlteraQtde := (MV_PAR06 == 1)

DbSelectArea("VO2")
DbSetOrder(1)
DbSeek(xFilial("VO2")+VO1->VO1_NUMOSV+"P")
RegToMemory("VO2",.T.)

cSQL := "SELECT DISTINCT VDR_NFSEMI, VDR_NFSNUM, VDR_NFSSER, VDR_CLIENT, VDR_LOJA, A1_NOME"
cSQL +=  " FROM " + RetSQLName("VDR") + " VDR JOIN " + RetSQLName("SA1") + " A1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = VDR_CLIENT AND A1_LOJA = VDR_LOJA AND A1.D_E_L_E_T_ = ' '"
cSQL += " WHERE VDR_FILIAL = '" + xFilial("VDR") + "'"
cSQL +=   " AND VDR_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
cSQL +=   " AND VDR_NFENUM = ' '"
cSQL +=   " AND VDR.D_E_L_E_T_ = ' '"
cSQL += " ORDER BY VDR_NFSEMI, VDR_NFSNUM"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cAliasVDR, .T., .T. )
While !(cAliasVDR)->(Eof())
	AADD( aNFRem , { .f. ,;
					 (cAliasVDR)->VDR_NFSSER, ;
					 (cAliasVDR)->VDR_NFSNUM, ;
					 StoD((cAliasVDR)->VDR_NFSEMI), ;
					 (cAliasVDR)->VDR_CLIENT, ;
					 (cAliasVDR)->VDR_LOJA, ;
					 (cAliasVDR)->A1_NOME } )
	(cAliasVDR)->(dbSkip())
End
(cAliasVDR)->(dbCloseArea())
dbSelectArea("VDR")
//

If Len(aNFRem) == 0
	MsgInfo(STR0165) // "OS sem pe็as em remessa"
	Return
EndIf

aSizeAut := MsAdvSize(.t.)
aInfo_ := { aSizeAut[ 1 ], aSizeAut[ 2 ],aSizeAut[ 3 ] ,aSizeAut[ 4 ], 3, 3 } // Tamanho total da tela

aObjects_   := {}
aAdd( aObjects_, { 0 , 18 , .T. , .F. } ) // Titulo / Botoes
aAdd( aObjects_, { 0 ,  0 , .T. , .T. } ) // ListBox

aPos_ := MsObjSize( aInfo_, aObjects_ )

DEFINE MSDIALOG oDlgRetRem TITLE STR0166 From aSizeAut[7],00 to aSizeAut[6],aSizeAut[5] PIXEL of oMainWnd STYLE DS_MODALFRAME // "Retorno de Remessa para Atendimento em Campo"
lMarcar := .t.

cFormPro   := "1"
cDevMerc   := ""
@ aPos_[1,1]+004,aPos_[1,2]+002 SAY STR0251 SIZE 50,8 OF oDlgRetRem PIXEL COLOR CLR_BLUE // "Formulแrio Pr๓prio:"
@ aPos_[1,1]+003,aPos_[1,2]+052 MSCOMBOBOX oCombo VAR cFormPro ITEMS aFormul SIZE 50,10 OF oDlgRetRem PIXEL ON CHANGE IIf(cFormPro<>"1",cDevMerc:="",.t.)

@ aPos_[1,1]+004,aPos_[1,2]+110 SAY STR0252 SIZE 50,8 OF oDlgRetRem PIXEL COLOR CLR_BLUE // "Numero NF:"
@ aPos_[1,1]+003,aPos_[1,2]+142 MSGET oNumNF VAR cNumNF PICTURE "@!" SIZE 60,08 OF oDlgRetRem PIXEL COLOR CLR_BLUE WHEN (cFormPro == "2")

@ aPos_[1,1]+004,aPos_[1,2]+210 SAY STR0253 SIZE 50,8 OF oDlgRetRem PIXEL COLOR CLR_BLUE // "S้rie NF:"
@ aPos_[1,1]+003,aPos_[1,2]+235 MSGET oSerNF VAR cSerNF PICTURE "@!" SIZE 40,08 OF oDlgRetRem PIXEL COLOR CLR_BLUE WHEN (cFormPro == "2")

@ aPos_[1,1]+004,aPos_[1,2]+285 SAY STR0286 SIZE 50,8 OF oDlgRetRem PIXEL COLOR CLR_BLUE // "Chave NFE:"
@ aPos_[1,1]+003,aPos_[1,2]+315 MSGET oChaveNFE VAR cChaveNFE PICTURE "@!" SIZE 80,08 OF oDlgRetRem PIXEL COLOR CLR_BLUE WHEN (cFormPro == "2")

If SF1->(FieldPos("F1_DEVMERC")) <> 0
	@ aPos_[1,1]+004,aPos_[1,2]+405 SAY RetTitle("F1_DEVMERC") SIZE 50,8 OF oDlgRetRem PIXEL COLOR CLR_BLUE
	@ aPos_[1,1]+003,aPos_[1,2]+440 MSCOMBOBOX oDevMerc VAR cDevMerc ITEMS aDevMerc SIZE 45,08 OF oDlgRetRem PIXEL WHEN (cFormPro == "1")
EndIf

oLbRem := TWBrowse():New(aPos_[2,1],aPos_[2,2],(aPos_[2,4]-aPos_[2,2]),(aPos_[2,3]-aPos_[2,1]),,,,oDlgRetRem,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oLbRem:nAt := 1
oLbRem:SetArray(aNFRem)
oLbRem:addColumn( TCColumn():New( " "                    , { || IIf(aNFRem[oLbRem:nAt,01],oOk,oNo) } ,,,,"LEFT" ,10,.T.,.F.,,,,.F.,) )
oLbRem:AddColumn( TCColumn():New( RetTitle("VDR_NFSSER") , { || aNFRem[oLbRem:nAt,02] } ,,,,"LEFT" ,35,.F.,.F.,,,,.F.,) )
oLbRem:AddColumn( TCColumn():New( RetTitle("VDR_NFSNUM") , { || aNFRem[oLbRem:nAt,03] } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) )
oLbRem:AddColumn( TCColumn():New( RetTitle("VDR_NFSEMI") , { || aNFRem[oLbRem:nAt,04] } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) )
oLbRem:AddColumn( TCColumn():New( RetTitle("VDR_CLIENT") , { || aNFRem[oLbRem:nAt,05] } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) )
oLbRem:AddColumn( TCColumn():New( RetTitle("VDR_LOJA  ") , { || aNFRem[oLbRem:nAt,06] } ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) )
oLbRem:AddColumn( TCColumn():New( RetTitle("A1_NOME   ") , { || aNFRem[oLbRem:nAt,07] } ,,,,"LEFT" ,70,.F.,.F.,,,,.F.,) )
oLbRem:bLDblClick := { || IIf( aNFRem[oLbRem:nAt,01] , ;
								(aNFRem[oLbRem:nAt,01] := .f. ), ;
								(aEval(aNFRem, { |x| x[01] := .f. }) , aNFRem[oLbRem:nAt,01] := .t. , oLbRem:Refresh() ) ;
							  ) }
oLbRem:Refresh()
ACTIVATE MSDIALOG oDlgRetRem CENTER ON INIT EnchoiceBar(oDlgRetRem, { || lContinua := .t. , cRemSerie := aNFRem[oLbRem:nAt,2] , cRemNota := aNFRem[oLbRem:nAt,3] , oDlgRetRem:End() } , { || lContinua := .f. , oDlgRetRem:End() })

If !lContinua
	Return .t.
EndIf

If !lAlteraQtde
	cCpoGetDN += "VDR_QTDUTI"
EndIf

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VDR")
While !SX3->(Eof()) .And. (SX3->X3_ARQUIVO == "VDR")

	&("M->"+AllTrim(SX3->X3_CAMPO)) := CriaVar(SX3->X3_CAMPO,.f.)

	If X3USO(SX3->X3_USADO) .And. (cNivel>=SX3->X3_NIVEL .or. X3OBRIGAT(SX3->X3_CAMPO))
		// Enchoice
		If (AllTrim(SX3->X3_CAMPO) $ cCpoEnch)
			AADD(aEncVDR,SX3->X3_CAMPO)
		EndIf
		// GetDados
		If (AllTrim(SX3->X3_CAMPO) $ cCpoGetD)
			Aadd(aHRet, {AllTrim(X3Titulo()), SX3->X3_CAMPO,		SX3->X3_PICTURE, 	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,     SX3->X3_VALID,		SX3->X3_USADO, 		SX3->X3_TIPO,;
							SX3->X3_F3,			 SX3->X3_CONTEXT,	X3CBOX(), 			SX3->X3_RELACAO })

			IF SX3->X3_VISUAL <> "V" .AND. !(AllTrim(SX3->X3_CAMPO) $ cCpoGetDN)
				Aadd(aHRetAlt,SX3->X3_CAMPO)
			ENDIF
		Endif
	Endif
	SX3->(dbSkip())
End

nVDRCODTES := FG_POSVAR("VDR_CODTES","aHRet")

SF4->(dbSetOrder(1))

dbSelectArea("VDR")

cSQL := "SELECT R_E_C_N_O_ RECNOVDR"
cSQL +=  " FROM " + RetSQLName("VDR")
cSQL += " WHERE VDR_FILIAL = '" + xFilial("VDR") + "'"
cSQL +=   " AND VDR_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
cSQL +=   " AND VDR_NFSSER = '" + cRemSerie + "'"
cSQL +=   " AND VDR_NFSNUM = '" + cRemNota  + "'"
cSQL +=   " AND VDR_NFENUM = ' '"
cSQL +=   " AND D_E_L_E_T_ = ' '"
cSQL += " ORDER BY VDR_NFSITE"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cAliasVDR, .T., .T. )
While !(cAliasVDR)->(Eof())

	VDR->(dbGoTo( (cAliasVDR)->RECNOVDR ))
	RegToMemory("VDR" , .f. , .t. , .t. ) // lInc , lDic , lInitPad
	AADD(aColsVDR, Array(Len(aHRet)+1))
	nCont := Len(aColsVDR)
	aColsVDR[nCont,Len(aHRet)+1] := .f.
	For nCont2 := 1 to Len(aHRet)
		If !lAlteraQtde .and. AllTrim(aHRet[nCont2,2]) == "VDR_QTDUTI"
			aColsVDR[nCont,nCont2] := M->VDR_QTDREM
		Else
			aColsVDR[nCont,nCont2] := &("M->"+AllTrim(aHRet[nCont2,2]))
		EndIf
	Next nCont2

	lContinue := OM0200032_VldTesRemManutExt(M->VDR_CODTES,"RET")
	If lContinue

		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4") + M->VDR_CODTES ))
			
		aColsVDR[nCont,nVDRCODTES] := SF4->F4_TESDV
		M->VDR_CODTES := SF4->F4_TESDV
	Else
		exit
	EndIf

	(cAliasVDR)->(dbSkip())
End
(cAliasVDR)->(dbCloseArea())
dbSelectArea("VDR")

if !lContinue
	Return .f.
EndIf

aSizeAut := MsAdvSize(.t.)
AADD( aObjects, { 100,  093, .T., .F. } ) // Enchoice
AADD( aObjects, { 100,  100, .T., .T. } ) // GetDados
aPosicao := MsObjSize( { aSizeAut[ 1 ] , aSizeAut[ 2 ] ,aSizeAut[ 3 ] , aSizeAut[ 4 ] , 2 , 2 } , aObjects , .T. )

oDlg020Ret := MSDIALOG():New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],STR0166,,,,128,,,,,.t.) // "Retorno de Remessa para Atendimento em Campo"

// Cabecalho
oEnchVDR := MSMGet():New("VDR", 1 , 3,;
	/* aCRA */, /* cLetra */, /* cTexto */, aEncVDR, aPosicao[1], aEncVDR , 3 /* nModelo */ ,;
	/* nColMens */, /* cMensagem */, ".T." /* cTudoOk */ , oDlg020Ret, .f. /* lF3 */ , .t. /* lMemoria */ , .T. /* lColumn */ ,;
	"" /* caTela */ , .t. /* lNoFolder */, .f. /* lProperty */)

cLinOk  := "AllwaysTrue()"
cTudoOk := "AllwaysTrue()"
cFieldOK := "AllwaysTrue()"
// Itens
oGetRem := MsNewGetDados():New(aPosicao[2,1],aPosicao[2,2],aPosicao[2,3],aPosicao[2,4],;
				(GD_UPDATE),; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
				cLinOk,cTudoOk,;
				,;		// Nome dos campos do tipo caracter que utilizacao incremento automatico
				aHRetAlt ,; 	// Campos alteraveis da GetDados
				/* nFreeze */,;	// Campos estaticos da GetDados
				Len(aColsVDR),;
				cFieldOK,;
				/* cSuperDel */,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
				/* cDelOk */,; 		// Funcao executada para validar a exclusao de uma linha
				oDlg020Ret,;
				aHRet,;
				aColsVDR)
oGetRem:oBrowse:bChange := { || FG_MEMVAR(oGetRem:aHeader,oGetRem:aCols,oGetRem:nAt) }

ACTIVATE MSDIALOG oDlg020Ret ON INIT ( EnchoiceBar(oDlg020Ret, { || IIf( OM020PRET(cFormPro,cDevMerc) , oDlg020Ret:End() , NIL ) }, { || oDlg020Ret:End() } ) )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OM020PRET บAutor  ณ Takahashi         บ Data ณ  07/07/00   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa retorno de remessa de pe็as.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM020PRET(cFormPro,cDevMerc)

Local aInfNF := {}

Local aIteVO3    := {}

Local nCont := 0

Local cNumBkp := ""
Local cSerBkp := ""

Local nVDRQTDREM := FG_POSVAR("VDR_QTDREM","aHRet")
Local nVDRQTDUTI := FG_POSVAR("VDR_QTDUTI","aHRet")
Local nVDRTIPTEM := FG_POSVAR("VDR_TIPTEM","aHRet")
Local nVDRGRUITE := FG_POSVAR("VDR_GRUITE","aHRet")
Local nVDRCODITE := FG_POSVAR("VDR_CODITE","aHRet")

Private aRecVDR  := {} // Para atualizacao do VDR apos geracao da NF de Retorno de Remessa
Private cSerie, cNumero

Default cDevMerc := ""

If !MsgYesNo(STR0167) // "Confirma retorno de remessa de pe็as ?"
	Return .f.
EndIf

SA1->(dbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+M->VDR_CLIENT + M->VDR_LOJA))

// ------------------------------------------------------------ //
// Monta matriz para devolver pecas quando nao foram utilizadas //
// ------------------------------------------------------------ //
aDevolu := {}
For nCont := 1 to Len(oGetRem:aCols)
	// se a quantidade utilizada for menor do que a quantidade remetida, deve-se devolver o saldo
	If oGetRem:aCols[nCont,nVDRQTDUTI] <> oGetRem:aCols[nCont,nVDRQTDREM]
		AADD( aDevolu , { ;
			oGetRem:aCols[nCont,nVDRTIPTEM] ,;
			oGetRem:aCols[nCont,nVDRGRUITE] ,;
			oGetRem:aCols[nCont,nVDRCODITE] ,;
			oGetRem:aCols[nCont,nVDRQTDREM] - oGetRem:aCols[nCont,nVDRQTDUTI] } )
	EndIf
Next nCont
If Len(aDevolu) > 0
	If !OM020RELDEV(VO1->VO1_NUMOSV, aDevolu, @aIteVO3)
		Return .f.
	EndIf
EndIf
// ------------------------------------------------------------ //

if cFormPro <> "2"
	lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"))
	If !lRet
		Return .f.
	EndIf
Endif
If GetNewPar("MV_TPNRNFS","1") == "3" // SD9
	cNumero := ""
Endif

Begin Transaction

if cFormPro <> "2"
	cNumero := NxtSX5Nota(cSerie, NIL, GetNewPar("MV_TPNRNFS","1"))
Else
	cNumero := cNumNF
	cSerie  := cSerNF
	
Endif
cNumBkp := cNumero
cSerBkp := cSerie

If !NFRetRem()
	DisarmTransaction()
	RollbackSx8()
	MsUnlockAll()
	MostraErro()
	Return .f.
Endif
ConfirmSx8()

If !Empty(cNumero)
	cNumBkp := cNumero
	cSerBkp := cSerie
Endif

If Len(aIteVO3) <> 0
	nOpc := 3

	lMSHelpAuto := .t.
	lMsErroAuto := .f.
	MSExecAuto({|x,y,z| OFIOM020(,,x,y,z)},aIteVO3,nOpc)

	if lMsErroAuto
		DisarmTransaction()
		RollbackSx8()
		MsUnlockAll()
		MostraErro()
		Return .f.
	Endif
EndIf
//

cNumero := cNumBkp
cSerie  := cSerBkp

AADD( aInfNF , { cSerie   , ;	// Serie da NF
				 cNumero  , ;	// Numero da NF
				 Upper(STR0168) } )	// Retorno


End Transaction

// Por algum motivo o cliente permanece bloqueado
SA1->(MsUnLock())
//

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SX6")
MsRUnLock()

// Ponto de Entrada Depois da Gravacao do Retorno de Remessa
If ExistBlock("OM020GRT")
	ExecBlock("OM020GRT",.f.,.f.,{cNumero,cSerie})
EndIf

FMX_TELAINF( "1", aInfNF )

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaHelpบAutor  ณRubens              บ Data ณ  01/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAjusta Help da Funcao                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//Static Function AjustaHelp()
//
//Local aHelpEng, aHelpSpa, aHelpPor
//
//aHelpPor := { STR0104 }
//aHelpEng := aHelpSpa :=	aHelpPor
//PutHelp("PM020DEVQTDE",aHelpPor,aHelpEng,aHelpSpa,.t.)
//
//aHelpPor := { STR0155 , STR0156 }
//aHelpEng := aHelpSpa :=	aHelpPor
//PutHelp("PM020SGJDREV",aHelpPor,aHelpEng,aHelpSpa,.t.)
//
//aHelpPor := {"Usuแrio nใo tem permissใo para ","realizar devolu็ใo de pe็as!"  }
//aHelpEng := aHelpSpa :=	aHelpPor
//PutHelp("PM020PERMDEV",aHelpPor,aHelpEng,aHelpSpa,.t.)
//
//aHelpPor := {"Verifique o cadastro de equipe ","t้cnica."  }
//aHelpEng := aHelpSpa :=	aHelpPor
//PutHelp("SM020PERMDEV",aHelpPor,aHelpEng,aHelpSpa,.t.)
//
//Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNFRetRem  บAutor  ณManoel              บ Data ณ  18/12/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณgera็ใo da NF de Retorno de Remessa                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NFRetRem()

Local nCntFor := 0
Local nL := 0
Local cAliasVDR := "TVDRR"
Local cSQL

Local aTemp := {}

Local nTotNFRR   := 0
Local nQtdRetRem := 0

Local cChaveSA1  := ""

Local nTamD1Item := TamSX3("D1_ITEM")[1]
Local cItemD1 := Replicate("0",nTamD1Item)

Private aCabNFE := {}
Private aIteNFE := {}

cSQL := "SELECT VDR_CLIENT, VDR_LOJA, VDR_QTDUTI,	VDR_VALUNI,	VDR_CODTES, VDR_LOCAL, VDR_NFSITE, VDR_NFSSER, VDR_NFSNUM,	VDR.R_E_C_N_O_, B1_COD, B1_UM, F4_TESDV, SD2.D2_IDENTB6  "
cSQL += " FROM " + RetSQLName("VDR") + " VDR "
cSQL += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_FILIAL = '" +xFilial("SB1")+ "' AND SB1.B1_GRUPO   = VDR.VDR_GRUITE AND SB1.B1_CODITE  = VDR.VDR_CODITE AND SB1.D_E_L_E_T_ = ' ' "
cSQL += " JOIN " + RetSQLName("SF4") + " SF4 ON SF4.F4_FILIAL = '" +xFilial("SF4")+ "' AND SF4.F4_CODIGO  = VDR.VDR_CODTES AND SF4.D_E_L_E_T_ = ' ' "
cSQL += " JOIN " + RetSQLName("SD2") + " SD2 ON SD2.D2_FILIAL = '" +xFilial("SD2")+ "' AND SD2.D2_CLIENTE = VDR.VDR_CLIENT AND SD2.D2_LOJA    = VDR.VDR_LOJA AND SD2.D2_DOC = VDR.VDR_NFSNUM AND SD2.D2_SERIE = VDR.VDR_NFSSER AND SD2.D2_COD = SB1.B1_COD AND SD2.D2_ITEM = VDR.VDR_PEDITE AND SD2.D_E_L_E_T_ = ' ' "
cSQL += " WHERE VDR_FILIAL = '" + xFilial("VDR") + "'"
cSQL += " AND VDR.VDR_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
cSQL += " AND VDR.VDR_NFSSER = '" + cRemSerie + "'"
cSQL += " AND VDR.VDR_NFSNUM = '" + cRemNota  + "'"
cSQL += " AND VDR.VDR_NFENUM = '        '"
cSQL += " AND VDR.D_E_L_E_T_ = ' '"
cSQL += " ORDER BY VDR_NFSITE"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cAliasVDR, .T., .T. )

While !(cAliasVDR)->(Eof())

	//VDR->( dbGoTo ( (cAliasVDR)->(R_E_C_N_O_) ) )

	nCntFor := aScan(oGetRem:aCols, { |x| x[FG_POSVAR("VDR_NFSITE","aHRet")] == (cAliasVDR)->VDR_NFSITE } )
	nQtdRetRem := oGetRem:aCols[ nCntFor , FG_POSVAR("VDR_QTDREM","aHRet")]

	cItemD1 := Soma1(cItemD1,nTamD1Item)
	AADD(aRecVDR, { (cAliasVDR)->(R_E_C_N_O_) , cItemD1 , oGetRem:aCols[ nCntFor , FG_POSVAR("VDR_QTDUTI","aHRet")] } )

	nTotNFRR   += (cAliasVDR)->(VDR_VALUNI)*nQtdRetRem

	aTemp := {}
	aAdd(aTemp,{"D1_DOC"      ,cNumero								,Nil})
	aAdd(aTemp,{"D1_SERIE"    ,cSerie								,Nil})
	aAdd(aTemp,{"D1_ITEM"     ,cItemD1								,Nil})
	aAdd(aTemp,{"D1_COD"      ,(cAliasVDR)->(B1_COD)	  			,Nil})
	aAdd(aTemp,{"D1_UM"       ,(cAliasVDR)->(B1_UM)       			,Nil})
	aAdd(aTemp,{"D1_QUANT"    ,nQtdRetRem							,Nil})
	aAdd(aTemp,{"D1_VUNIT"    ,(cAliasVDR)->(VDR_VALUNI)			,Nil})
	aAdd(aTemp,{"D1_TOTAL"    ,(cAliasVDR)->(VDR_VALUNI)*nQtdRetRem ,Nil})
	aAdd(aTemp,{"D1_EMISSAO"  ,dDataBase							,Nil})
	aAdd(aTemp,{"D1_TES"      ,(cAliasVDR)->(F4_TESDV) 				,Nil})
	aAdd(aTemp,{"D1_RATEIO"   ,'2'                      			,Nil})
	aAdd(aTemp,{"D1_LOCAL"    ,(cAliasVDR)->(VDR_LOCAL)				,Nil})
	aAdd(aTemp,{"D1_NFORI"    ,(cAliasVDR)->(VDR_NFSNUM)			,Nil})
	aAdd(aTemp,{"D1_SERIORI"  ,(cAliasVDR)->(VDR_NFSSER)			,Nil})
	aAdd(aTemp,{"D1_ITEMORI"  ,(cAliasVDR)->(VDR_NFSITE)			,Nil})
	aAdd(aTemp,{"D1_IDENTB6"  ,(cAliasVDR)->(D2_IDENTB6)			,Nil})
	//

	If ExistBlock("OM020SD1")
		aTemp := ExecBlock("OM020SD1",.f.,.f.,{aTemp})
	EndIf	

	aAdd(aIteNFE,aclone(aTemp))
	cChaveSA1 := (cAliasVDR)->(VDR_CLIENT)+(cAliasVDR)->(VDR_LOJA)

	(cAliasVDR)->(DbSkip())

Enddo
//
SA1->(DbGoTop())
SA1->(DbSetOrder(1))
If !SA1->(dbSeek(xFilial("SA1")+cChaveSA1 ))
	(cAliasVDR)->(DbCloseArea())
	Return .f.
Endif
//
aAdd(aCabNFE,{"F1_TIPO"		,"D"				,Nil})
aAdd(aCabNFE,{"F1_FORMUL"	,Iif(cFormPro=="2","N","S"),Nil})
aAdd(aCabNFE,{"F1_DOC"		,cNumero			,Nil})
aAdd(aCabNFE,{"F1_SERIE"	,cSerie				,Nil})
aAdd(aCabNFE,{"F1_EMISSAO"	,dDataBase			,Nil})
aAdd(aCabNFE,{"F1_FORNECE"	,SA1->A1_COD		,Nil})
aAdd(aCabNFE,{"F1_LOJA"		,SA1->A1_LOJA		,Nil})
aAdd(aCabNFE,{"F1_VALMERC"	,nTotNFRR			,Nil})
aAdd(aCabNFE,{"F1_VALBRUT"	,nTotNFRR			,Nil})
aAdd(aCabNFE,{"F1_TIPODOC"	,"12"  			    ,Nil})
aAdd(aCabNFE,{"F1_ESPECIE"	,"SPED"   		    ,Nil})
aAdd(aCabNFE,{"F1_COND"		, RetCondVei()		,Nil}) // Codigo da condicao de pagamento
aAdd(aCabNFE,{"F1_MOEDA"  	,1        		    ,NIL})
aAdd(aCabNFE,{"F1_TXMOEDA"	,1         		    ,NIL})
aAdd(aCabNFE,{"F1_CHVNFE"	,cChaveNFE 		    ,NIL})
If cFormPro=="1" .and. !Empty(cDevMerc) // Formulario Proprio
	aAdd(aCabNFE,{"F1_DEVMERC"	,cDevMerc		,Nil})
EndIf

If ExistBlock("OM020SF1")
	aCabNFE := ExecBlock("OM020SF1",.f.,.f.,{aCabNFE})
EndIf	

//
(cAliasVDR)->(DbCloseArea())
//
//Chamada do MATA103 (Nota Fiscal de Entrada)
//
SF1->(dbSetOrder(1))
SD1->(dbSetOrder(1))
SB1->(dbSetOrder(1))
//
DbSelectArea("SF1")
dbSetOrder(1)
If dbSeek(xFilial("SF1")+cNumero+cSerie+SA1->A1_COD+SA1->A1_LOJA)
	DisarmTransaction()
	RollBackSX8()
	MsgInfo(STR0169,STR0075)//Numeracao de Nota Fiscal ja existente...","Atencao
	Return .f.
EndIf
//

if Len(aIteNFE) == 0
	DisarmTransaction()
	RollBackSX8()
	MsgStop(STR0244)
	Return .f.
Endif

lMsErroAuto := .f.
nAnt    := MAFISSAVE()
MAFISEND()
aCampos := {}
MSExecAuto({|x,y| MATA103(x,y)},aCabNFE,aIteNFE)
//
MAFISRESTORE(nAnt)
//
If lMsErroAuto
	DisarmTransaction()
	RollBackSX8()
	Return .f.
EndIf

cNumero := SF1->F1_DOC
cSerie  := SF1->F1_SERIE
For nl := 1 to Len(aRecVDR)
    //
	VDR->( dbGoTo ( aRecVDR[nl,1] ) )
    //
	RecLock("VDR",.f.)
	VDR->VDR_NFESER := cSerie
	VDR->VDR_NFENUM := cNumero
	VDR->VDR_NEEEMI := dDataBase
	VDR->VDR_NFEITE := aRecVDR[nl,2]
	VDR->VDR_QTDUTI := aRecVDR[nl,3]
	VDR->(MsUnLock())
    //
Next


Return .t.

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun็ใo    |OM020KEYF4  | Autor |  Thiago               | Data | 27/12/13 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri็ใo | Chamada da tecla de atalho <F4>. Executa comandos dependen-  |##
##|          | do do campo selecionado ( ReadVar() ).                       |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM020KEYF4()

Local lRetorno := .f.
Local cReadVar := ReadVar()

SetKey(VK_F4,Nil)

Do Case
Case cReadVar $ "M->VO3_GRUITE,M->VO3_CODITE"
	//cTmpGrupo  := Space(TamSx3("B1_GRUPO")[1])
	//cTmpCodite := Space(TamSx3("B1_CODITE")[1])
	cTmpGrupo := aCols[n,FG_POSVAR("VO3_GRUITE")]
	cTmpCodite := M->VO3_CODITE
	DBSelectArea("SB1")
	DBSetOrder(7)
	if DBSeek(xFilial("SB1")+cTmpGrupo+cTmpCodite)
		lRetorno := OFIXC001(SB1->B1_COD)
	Else
		lRetorno := OFIXC001(cTmpCodite)
	Endif
	if lRetorno
		M->VO3_GRUITE := SB1->B1_GRUPO
		M->VO3_CODITE := SB1->B1_CODITE
	else
		M->VO3_GRUITE := cTmpGrupo
		M->VO3_CODITE := cTmpCodite
	endif
	aCols[n,FG_POSVAR("VO3_GRUITE")] := M->VO3_GRUITE
	aCols[n,FG_POSVAR("VO3_CODITE")] := M->VO3_CODITE
	DBSelectArea("SB1")
	DBSetOrder(7)
	DBSeek(xFilial("SB1")+M->VO3_GRUITE+ M->VO3_CODITE)
	M->VO3_DESITE := aCols[n,FG_POSVAR("VO3_DESITE")] := SB1->B1_DESC
Case cReadVar $ "M->VO3_LOTECT"
	SB1->(DBSetOrder(7))
	SB1->(DBSeek(xFilial("SB1")+M->VO3_GRUITE+ M->VO3_CODITE))
	F4LOTE(,,,"",SB1->B1_COD, OM0200065_ArmazemOrigem( M->VO3_TIPTEM ) )
End Case
SETKEY(VK_F4,{|| OM020KEYF4() })

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ FS_SELECIONA Autor ณ  THIAGO             ณ Data ณ 27/05/14 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Marca/Desmarca TOTAL Vetor de Alteracao.                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_SELECIONA(lMarcar)
Local nLine := 0

if Empty(M->VO3_TIPTEM)
	Return(.f.)
Endif
For nLine:=1 to Len(aPecas)
	aPecas[nLine,1] := lMarcar
Next
Return

/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Fun็ใo    | OM020REQOPC | Autor | Rubens Takahashi     | Data | 10/08/15 |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descri็ใo | Requisita um opcional com numero de serie (Equipamento VV1)  |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM020REQOPC()

	Private M->VV1_CODMAR := ""

	Private oDlgRecOpc
	Private oEnchParam
	Private oBtnAtualizar
	Private oLBoxOpc

	Private oOk := LoadBitmap( GetResources(), "LBTIK" )
	Private oNo := LoadBitmap( GetResources(), "LBNO" )

	OM020TELAREQOPC()

	ACTIVATE MSDIALOG oDlgRecOpc ON INIT EnchoiceBar(oDlgRecOpc,{ || IIf( OM020IMPOPC() , oDlgRecOpc:End() , ) }, { || oDlgRecOpc:End() },,)

Return

/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Fun็ใo    | OM020IMPOPC | Autor | Rubens Takahashi     | Data | 10/08/15 |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descri็ใo | Importa o item selecionado na GetDados para Requisicao       |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OM020IMPOPC()

	Local nPos
	Local aImpVO3 := {}

	Local aRetParamBox := {}
	Local aParParamBox := {}

	Local aBkpACols := aClone(aCols)

	Local oOficina := DMS_Oficina():New()

	Private aPecaOrc := {}
	Private aPecaSel := {.t.}
	Private aImpFatPar := {"","",""}

	If ( nPos := aScan(oLBoxOpc:aArray,{ |x| x[1] }) ) == 0
		MsgStop(STR0194) // "Selecione um registro para importa็ใo."
		Return .f.
	EndIf

	AADD( aParParamBox , { 1 , STR0067, Space(Len(VOI->VOI_TIPTEM)), "@!", "OM0200081_ValidaTipoTempo(MV_PAR01)", "VOI", "", 10, .t. }) // "Tipo de Tempo"
	If !ParamBox(aParParamBox,STR0067,@aRetParamBox,,,,,,,, .f., .t.) // "Tipo de Tempo"
		Return .f.
	EndIf

	If !MsgYesNo(STR0195) // "Confirma requisi็ใo do opcional ?"
		Return .f.
	EndIf

	cTipTem := aRetParamBox[1]
	If oOficina:TipoTempoBloqueado(cTipTem,.t.) // Valida se Tipo de Tempo esta BLOQUEADO
		Return .f.
	EndIf

	VV1->(dbSetOrder(1))
	VV1->(dbSeek( xFilial("VV1") + oLBoxOpc:aArray[ nPos , 2 ] ))

	// Valida็ใo do Equipamento
	If !OM020VALVEI(2,VV1->VV1_CHAINT,,.t.)
		Return .f.
	EndIf

	FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , PadR(cMVGRUVEI, TamSX3("B1_GRUPO")[1]) )

	aBkpACols := aClone(aCols)

	If !Empty(aCols[n, FG_POSVAR("VO3_TIPTEM","aHeader") ]) .and. !Empty(aCols[n, FG_POSVAR("VO3_CODITE","aHeader")])
		Aadd(aCols, Array( Len(aHeader)+1 ) )
		n := nReg := Len(aCols)
		aEval( aHeader,{ |x,nPos| aCols[nReg,nPos] := CriaVar(x[2]) })
		aCols[nReg,Len(aCols[nReg])] := .f.
	EndIf

	aImpVO3 := Array(04)
	aImpVO3[1] := { "VO3_TIPTEM" , cTipTem }
	aImpVO3[2] := { "VO3_GRUITE" , SB1->B1_GRUPO }
	aImpVO3[3] := { "VO3_CODITE" , SB1->B1_CODITE }
	aImpVO3[4] := { "VO3_QTDREQ" , 1 }

	For nPos := 1 to Len(aImpVO3)
		__readvar := "M->" + aImpVO3[ nPos , 1 ]
		&(__readvar) := aCols[n,FG_POSVAR(aImpVO3[ nPos , 1 ],"aHeader")] := aImpVO3[ nPos , 2 ]

		If aImpVO3[ nPos , 1 ] $ "VO3_TIPTEM/VO3_QTDREQ"
			If SX3->(dbSeek( aImpVO3[ nPos , 1 ] )) .and. !Empty(SX3->X3_VALID)
				If !&(AllTrim(SX3->X3_VALID))
					MsgInfo("Erro valid " + __readvar)
					aCols := aClone(aBkpACols)
					Return .f.
				EndIf
			EndIf
		EndIf
		If !FS_FIELD020(.f.)
			MsgInfo("Erro - " + __readvar)
			aCols := aClone(aBkpACols)
			Return .f.
		EndIf
	Next nPos
	aCols[n,FG_POSVAR("VO3_DESITE","aHeader")] := SB1->B1_DESC

	oGetReqPec:ForceRefresh()

Return .t.

/*
===============================================================================
###############################################################################
##+----------+-----------------+-------+------------------+------+----------+##
##|Fun็ใo    | OM020TELAREQOPC | Autor | Rubens Takahashi | Data | 10/08/15 |##
##+----------+-----------------+-------+------------------+------+----------+##
##|Descri็ใo | Monta tela para requisicao de itens opcionais com numero de  |##
##|          | s้rie.                                                       |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OM020TELAREQOPC()

	Local oSizePrinc
	Local oSizeFiltro
	Local oInterfHelper := DMS_InterfaceHelper():New()

	oInterfHelper:nOpc := 3

	oSizePrinc := oInterfHelper:CreateDefSize(.t. , { { "PARTE_FILTRO",100,100,.f.,.t.} , { "DETALHE",100,100,.t.,.t. } } )
	oSizePrinc:aMargins := { 0 , 2 , 0 , 0 }
	oSizePrinc:lLateral := .t.	// Calcula em colunas
	oSizePrinc:Process()

	oInterfHelper:SetDefSize(oSizePrinc)
	oDlgRecOpc := oInterfHelper:CreateDialog(STR0196) // "Requisi็ใo de Opcionais de Equipamento"

	oSizeFiltro := oInterfHelper:CreateDefSize(.t. , { {"FILTRO",100,100,.t.,.t.},{"BTN_ATUALIZA",100,011,.t.,.f.}} , oSizePrinc:GetNextCallArea("PARTE_FILTRO") )
	oSizeFiltro:Process()

	oInterfHelper:SetDefSize(oSizeFiltro,"FILTRO")

	oInterfHelper:SetOwnerPvt("OM020REQOPC")
	oInterfHelper:SetPrefixo("PAR")
	oInterfHelper:AddMGet( "VV1_CODMAR" , { {"X3_VISUAL","A"} , {"X3_VALID","ExistCpo('VE1',M->PAR_CODMAR) .AND. ( M->VV1_CODMAR := M->PAR_CODMAR )"} } )
	oInterfHelper:AddMGet( "VV1_MODVEI" , { {"X3_VISUAL","A"} , {"X3_VALID","ExistCpo('VV2',M->PAR_CODMAR+M->PAR_MODVEI)"} } )

	oEnchParam := oInterfHelper:CreateMSMGet(.f.)

	M->PAR_CODMAR := M->VV1_CODMAR := FMX_RETMAR( cMVMIL0006 )

	oBtnAtualizar := TButton():New( oSizeFiltro:GetDimension("BTN_ATUALIZA","LININI") + 1, oSizeFiltro:GetDimension("BTN_ATUALIZA","COLINI") ,;
		STR0002, oDlgRecOpc , { || ( oLBoxOpc:SetArray( FS_LBOXOPC() ) , oLBoxOpc:Refresh() ) }, oSizeFiltro:GetDimension("BTN_ATUALIZA","XSIZE") , 010,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Pesquisar"

	oInterfHelper:Clean()
	oInterfHelper:SetDefSize(oSizePrinc,"DETALHE")
	oInterfHelper:AddColLBox( { { "SELECAO" , .t. } , { "SELECAO_UNICO" , .t. } , { "VALIDACAO" , " !Empty(NOME_OBJETO:aArray[ NOME_OBJETO:nAt , 2 ]) .and. OM020VALVEI( 1 , NOME_OBJETO:aArray[NOME_OBJETO:nAt,2] ,, .t. ) " } } )
	oInterfHelper:AddColLBox( { { "X3" , "VV1_CHAINT" } } )
	oInterfHelper:AddColLBox( { { "X3" , "VV1_CHASSI" } } )
	oInterfHelper:AddColLBox( { { "X3" , "VV1_FILENT" } } )
	oInterfHelper:AddColLBox( { { "X3" , "VV2_GRUMOD" } } )
	oInterfHelper:AddColLBox( { { "X3" , "VV2_DESMOD" } } )

	oLBoxOpc := oInterfHelper:CreateLBox("oLBoxOpc")
	oLBoxOpc:SetArray( FS_LBOXOPC() )
	oLBoxOpc:Refresh()

Return

/*
===============================================================================
###############################################################################
##+----------+-----------------+-------+------------------+------+----------+##
##|Fun็ใo    | FS_LBOXOPC      | Autor | Rubens Takahashi | Data | 10/08/15 |##
##+----------+-----------------+-------+------------------+------+----------+##
##|Descri็ใo | Atualiza listbox de opcionais.                               |##
##|          |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_LBOXOPC()

	Local cAliasAMS := "TAMS"
	Local aRetorno := {}

	cQuery := "SELECT VV1_CHAINT, VV1_CHASSI, VV1_FILENT , "
	cQuery +=       " VV2_GRUMOD, VV2_DESMOD "
	cQuery += " FROM " + RetSQLName("VV1") + " VV1 "
	cQuery += " JOIN " + RetSQLName("VV2") + " VV2 ON VV2.VV2_FILIAL = '" + xFilial("VV2") + "'"
	cQuery +=                                   " AND VV2.VV2_CODMAR = VV1.VV1_CODMAR "
	cQuery +=                                   " AND VV2.VV2_MODVEI = VV1.VV1_MODVEI "
	cQuery +=                                   " AND VV2.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE VV1.VV1_FILIAL = '" + xFilial("VV1") + "'"
	cQuery +=  " AND VV1.VV1_FILENT = '" + cFilAnt + "'"
	cQuery +=  " AND VV1.VV1_CODMAR = '" + M->PAR_CODMAR + "'"
	cQuery +=  " AND VV1.VV1_MODVEI = '" + M->PAR_MODVEI + "'"
	cQuery +=  " AND VV1.VV1_SITVEI = '0' " // Estoque
	cQuery +=  " AND VV1.VV1_TRACPA <> ' '"
	//cQuery +=  " AND VV1.VV1_GRASEV = '6'"
	cQuery +=  " AND VV1.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY VV1.VV1_CHASSI "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasAMS , .F., .T. )
	While !(cAliasAMS)->(Eof())
		AADD( aRetorno , { ;
			.f.,;
			(cAliasAMS)->VV1_CHAINT,;
			(cAliasAMS)->VV1_CHASSI,;
			(cAliasAMS)->VV1_FILENT,;
			(cAliasAMS)->VV2_GRUMOD,;
			(cAliasAMS)->VV2_DESMOD } )
		(cAliasAMS)->(dbSkip())
	End
	(cAliasAMS)->(dbCloseArea())

	If Len(aRetorno) == 0
		AADD( aRetorno , { ;
			.f.,;
			" ",;
			" ",;
			" ",;
			" ",;
			" " } )
	EndIf

Return aRetorno


/*
===============================================================================
###############################################################################
##+----------+-----------------+-------+------------------+------+----------+##
##|Fun็ใo    | OM020VALVEI     | Autor | Rubens Takahashi | Data | 10/08/15 |##
##+----------+-----------------+-------+------------------+------+----------+##
##|Descri็ใo | Valida se ้ possํvel utilizar o equipamento opcional         |##
##|          |                                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM020VALVEI(nTP,cChaInt,cCodTES,lImport)
	Default lImport := .f.
	If cReqDev == "0"
		Return .t.
	Else
		// Verifica se o item jแ esta na GetDados
		If lImport .and. aScan( aCols , { |x| x[FG_POSVAR("VO3_GRUITE")] == PadR(cMVGRUVEI, TamSX3("B1_GRUPO")[1]) .and. AllTrim(x[FG_POSVAR("VO3_CODITE")]) == cChaInt }) <> 0
			ShowHelpDlg("OM020JAIMPOPC",{STR0245}) // "Opcional jแ estแ na lista para requisi็ใo."
			Return .f.
		EndIf
	EndIf
Return VEIXX012(nTp,xFilial("VV1"),cChaInt,cCodTes,"_")


/*/{Protheus.doc} OM020VSJMANUAL

Fun็ใo responsแvel por permitir a digita็ใo das pe็as que serใo requisitadas na Ordem de Servi็o

@author Rubens
@since 04/05/2016
@version 1.0
@param cAlias, characters, Alias
@param nReg, numeric, recno da VO1
@param nOpc, numeric, nOpc
@type function
/*/
Function OM020VSJMANUAL(cAlias,nReg,nOpc)

	Private oGetPecas
	Private oDlg020Rascunho
	Private oLbIteRel
	Private Altera := .f.
	Private Inclui := .f.
	Private lMostraEstoque := (GetNewPar("MV_MIL0011","0") == "0")
	Private nColHeadRec   := 0
	Private nColHeadAlias := 0
	Private aAlterGetD := {}
	Private oVerde    := LoadBitmap( GetResources(), "BR_VERDE" )
	Private oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO" )
	Private aNewBot := { {"PMSCOLOR", {|| BrwLegenda(STR0027, STR0093, { {"BR_VERDE" ,STR0132},{"BR_VERMELHO",STR0133} } ) } , STR0093 } }
	Private aHeaderObrigat := {}
	Private oArrHelper := DMS_ArrayHelper():New()

	// Faz reserva automatica na digitacao do VSJ Manual ? 
	If GetNewPar("MV_MIL0155","0") == "1"
		// Este parametro ้ dependente do parametro MV_RITEORC = "S"
		If GetNewPar("MV_RITEORC","N") <> "S"
			MsgInfo(STR0289,STR0075) // Nใo serแ possํvel fazer a Reserva Automแtica na Digita็ใo Manual, pois o conte๚do do parametro MV_RITEORC esta diferente de 'S' / Atencao
		EndIf
	EndIf

	If VSJ->(FieldPos("VSJ_CODIGO")) == 0
		MsgStop(STR0240,STR0075) // "Foi verificado que o campo VSJ_CODIGO nใo existe em seu dicionแrio de dados. Por gentileza, atualize seu ambiente por meio do compatibilizador UPDOFINP."
		Return .f.
	EndIf

	If iif(lOm020Ast,ExecBlock("OM020AST",.F.,.F.,{VO1->VO1_STATUS}),VO1->VO1_STATUS) $ "D/F/C" // Liberada, Fechada ou Cancelada 
		MsgStop(STR0295,STR0075) // Nใo serแ possํvel realizar essa opera็ใo, pois a OS se encontra Liberada, Fechada ou Cancelada.
		Return .F.
	EndIf
 	
	RegToMemory("VO1",.f.)
	RegToMemory("VO3",.t.)

	dbSelectArea("VO1")

	TelaVSJManual(nOpc)
	LoadVSJManual()

	ACTIVATE MSDIALOG oDlg020Rascunho CENTER ON INIT EnchoiceBar( oDlg020Rascunho, { || IIf(OM020VSJGRAVA(),oDlg020Rascunho:End(),.t.) } , { || oDlg020Rascunho:End() } ,, aNewBot)
Return

/*/{Protheus.doc} OM020VSJGRAVA
Fun็ใo responsแvel por persistir as informa็๕es da VSJ na base de dados.
@author Rubens
@since 04/05/2016
@version 1.0

@type function
/*/
Static Function OM020VSJGRAVA()

	Local nCont
	Local aIteVSJ := {}
	Local nii
	Local lDeletado
	Local cArmOri := ""

	If !oGetPecas:TudoOk()
		Return
	EndIf

	// Verifica se itens foram cortados, e se foram, pergunta motivo do cancelamento
	If !FS_REGVENPER()
		Return .f.
	EndIf
	//

	If !MsgYesNo(STR0233,STR0075) // "Confirma grava็ใo dos Dados ?" / Aten็ใo
		Return .f.
	EndIf

	SF4->(dbSetOrder(1))
	VOI->(dbSetOrder(1))

	Begin Transaction

	nii := 0
	For nCont := 1 to Len(oGetPecas:aCols)

		lDeletado := oGetPecas:aCols[nCont,Len(oGetPecas:aCols[nCont])]

		// Inclusao de Registro
		If oGetPecas:aCols[nCont,nColHeadRec] == 0 .and. !lDeletado

			If Empty(oGetPecas:aCols[nCont, FG_POSVAR("VSJ_TIPTEM","oGetPecas:aHeader")])
				Loop
			EndIf

			SB1->(dbSetOrder(7))
			SB1->(dbSeek( xFilial("SB1") + oGetPecas:aCols[ nCont , FG_POSVAR("VSJ_GRUITE","oGetPecas:aHeader") ] + oGetPecas:aCols[ nCont , FG_POSVAR("VSJ_CODITE","oGetPecas:aHeader") ] ) )
			SF4->(MsSeek( xFilial("SF4") + oGetPecas:aCols[ nCont , FG_POSVAR("VSJ_CODTES","oGetPecas:aHeader") ] ))
			VOI->(MsSeek( xFilial("VOI") + oGetPecas:aCols[ nCont , FG_POSVAR("VSJ_TIPTEM","oGetPecas:aHeader") ] ))

			cArmOri := OM0200065_ArmazemOrigem( oGetPecas:aCols[ nCont , FG_POSVAR("VSJ_TIPTEM","oGetPecas:aHeader") ] )

			AADD(aIteVSJ, Array(23))
			nii++
			aIteVSJ[ nii , 01 ] := SB1->B1_GRUPO                                      // 01 - Grupo do Item
			aIteVSJ[ nii , 02 ] := SB1->B1_CODITE                                     // 02 - Codigo do Item
			aIteVSJ[ nii , 03 ] := oGetPecas:aCols[ nCont , FG_POSVAR("VSJ_QTDINI","oGetPecas:aHeader") ] // 03 - Qtde
			aIteVSJ[ nii , 04 ] := cArmOri // 04
			aIteVSJ[ nii , 05 ] := " "                                                // 05 - Grupo do Inconveniente
			aIteVSJ[ nii , 06 ] := " "                                                // 06 - Codigo do Inconveniente
			aIteVSJ[ nii , 07 ] := oGetPecas:aCols[ nCont , FG_POSVAR("VSJ_TIPTEM","oGetPecas:aHeader") ] // 07 - Tipo de Tempo
			aIteVSJ[ nii , 08 ] := oGetPecas:aCols[ nCont , FG_POSVAR("VSJ_FATPAR","oGetPecas:aHeader") ] // 08 - Cliente Faturar Para
			aIteVSJ[ nii , 09 ] := oGetPecas:aCols[ nCont , FG_POSVAR("VSJ_LOJA","oGetPecas:aHeader") ]   // 09 - Loja Faturar Para
			aIteVSJ[ nii , 10 ] := " "                                                // 10 - Seq. do Inconveniente
			aIteVSJ[ nii , 11 ] := " "                                                // 11 - Numero do Orcamento
			aIteVSJ[ nii , 12 ] := SF4->F4_CODIGO                                     // 12 - TES
			aIteVSJ[ nii , 13 ] := SF4->F4_ESTOQUE                                    // 13 - TES Mov. Estoque ??? (F4_ESTOQUE)
			aIteVSJ[ nii , 14 ] := 0                                            // 14 - Valor da Peca
			aIteVSJ[ nii , 15 ] := oGetPecas:aCols[ nCont , FG_POSVAR("VSJ_DEPGAR","oGetPecas:aHeader") ] // 15 - Depto Interno
			aIteVSJ[ nii , 16 ] := oGetPecas:aCols[ nCont , FG_POSVAR("VSJ_DEPINT","oGetPecas:aHeader") ] // 16 - Depto Garantia
			aIteVSJ[ nii , 17 ] := ""                                                 // 17 - Lote
			aIteVSJ[ nii , 18 ] := ""                                                 // 18 - Sub-Lote
			aIteVSJ[ nii , 19 ] := IIf(Localiza(SB1->B1_COD),FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),Space(15)) // 19 - Localiza็ใo - Endere็o
			aIteVSJ[ nii , 20 ] := "4"                                                // 20 - Origem do registro
			aIteVSJ[ nii , 21 ] := CtoD(" ")                                          // 21 - Validade do Lote
			aIteVSJ[ nii , 22 ] := 0                                                  // 22 - Valor de Desconto

			aIteVSJ[ nii , 23 ] := ;
				{ ;
					{ "VSJ_FATPAR" , oGetPecas:aCols[ nCont , FG_POSVAR( "VSJ_FATPAR" , "oGetPecas:aHeader" ) ] } ,;
					{ "VSJ_LOJA"   , oGetPecas:aCols[ nCont , FG_POSVAR( "VSJ_LOJA"   , "oGetPecas:aHeader" ) ] } ,;
					{ "VSJ_OPER"   , oGetPecas:aCols[ nCont , FG_POSVAR( "VSJ_OPER"   , "oGetPecas:aHeader" ) ] } ,;
					{ "VSJ_CODSIT" , oGetPecas:aCols[ nCont , FG_POSVAR( "VSJ_CODSIT" , "oGetPecas:aHeader" ) ] } ,;
					{ "VSJ_QTDDIG" , oGetPecas:aCols[ nCont , FG_POSVAR( "VSJ_QTDINI" , "oGetPecas:aHeader" ) ] } ,;
					{ "VSJ_QTDINI" , oGetPecas:aCols[ nCont , FG_POSVAR( "VSJ_QTDINI" , "oGetPecas:aHeader" ) ] } ,;
					{ "VSJ_QESTNA" , FS_SALDOESTQ( SB1->B1_COD , cArmOri ) } ,;
					{ "VSJ_DATREQ" , dDataBase } ,;
					{ "VSJ_FORMUL" , VOI->VOI_VALPEC } ,;
					{ "VSJ_VALCUS" , FS_VALCUS( SB1->B1_COD , cArmOri ) } ,;
					{ "VSJ_VALPEC" , FG_VALPEC(VOI->VOI_TIPTEM,"VOI->VOI_VALPEC",SB1->B1_GRUPO,SB1->B1_CODITE,,.f.,.t.) } ;
				}
		EndIf
		//

		// Manutencao de Registros
		If oGetPecas:aCols[nCont,nColHeadRec] > 0
			VSJ->(dbGoTo(oGetPecas:aCols[nCont,nColHeadRec ]))
			RecLock("VSJ",.F.)
			VSJ->VSJ_CODSIT := oGetPecas:aCols[nCont , FG_POSVAR( "VSJ_CODSIT" , "oGetPecas:aHeader" )]
			If oGetPecas:aCols[nCont,Len(oGetPecas:aCols[nCont])]
				VSJ->VSJ_QTDITE := 0
				VSJ->VSJ_MOTPED := oGetPecas:aCols[nCont , FG_POSVAR( "VSJ_MOTPED" , "oGetPecas:aHeader" )]
			EndIf
			VSJ->(MsUnLock())
		EndIf
		//

	Next nCont

	// Processa inclusao de novos registros ...
	If !FS_VSJINCLUSAO( aIteVSJ )
		MsUnlockAll()
		DisarmTransaction()
		Return .f.
	EndIf
	//
	End Transaction

	LoadVSJManual()
	OM0200083_BlqCpoRascunho()

	MsgInfo(STR0239,STR0075) // "Dados gravados."

Return .t.

/*/{Protheus.doc} FS_VSJINCLUSAO
Fun็ใo responsแvel por processar a inclusใo de novos registros na VSJ
@author Rubens
@since 04/05/2016
@version 1.0
@param aIteVSJ, array, Itens da VSJ que serใo incluํdos na base de dados.
@type function
/*/
Static Function FS_VSJINCLUSAO( aIteVSJ )

	Local cProbEstoque := ""

	If Len(aIteVSJ) == 0
		Return .t.
	EndIf

	aItensNImp := {}
	aAuxRecno := {}
	If FM_IMPVSJ( @aItensNImp , , VO1->VO1_NUMOSV , aIteVSJ , 3 ,, @aAuxRecno)
// Por enquanto nao faz reserva e nao gera solicitacao de compra automatica
//		If Len(aItensNImp[2]) > 0
//			cTitAviso 	:= "Pe็a(s) sem saldo em estoque!"
//			cMsgPeca	:= "A(s) pe็a(s) abaixo estแ(ใo) com saldo em estoque insuficiente para realizar a requisi็ใo! Verifique:"+CHR(13)+CHR(10)
//			For nii := 1 to Len(aItensNImp[2])
//				cMsgPeca += "Grupo da Pe็a: "+AllTrim(aItensNImp[2,nii,4])+" / C๓digo da Pe็a: "+AllTrim(aItensNImp[2,nii,5]) + " / Quantidade a requisitar: "+ CValtoChar(aItensNImp[2,nii,10]) + CHR(13)+CHR(10)
//			Next nCntFor
//			MsgStop(cMsgPeca,cTitAviso)
//			Return .f.
//		EndIf
		ConfirmSX8()

		If !Empty(cProbEstoque)
			MsgInfo(STR0234,STR0075) // "Um ou mais produtos nใo possuem estoque em quantidade suficiente para atender a quantidade informada." / Aten็ใo
		EndIf
		//
	Else
		RollBackSXE()
		Return .f.
	EndIf

Return .t.

/*/{Protheus.doc} FS_REGVENPER
Registra venda perdida da Oficina
@author Rubens
@since 04/05/2016
@version 1.0

@type function
/*/
Static Function FS_REGVENPER()

	Local aMotCancel := {}
	Local nCont
	Local nVSJTIPTEM := FG_POSVAR("VSJ_TIPTEM","oGetPecas:aHeader")
	Local nVSJCODITE := FG_POSVAR("VSJ_CODITE","oGetPecas:aHeader")
	Local nVSJMOTPED := FG_POSVAR("VSJ_MOTPED","oGetPecas:aHeader")

	// Verifica se existe itens cortados...
	If aScan(oGetPecas:aCols, { |x| x[Len(x)] .and. !Empty(x[nVSJTIPTEM]) .and. !Empty(x[nVSJCODITE]) .and. Empty(x[nVSJMOTPED]) }) > 0
		aMotCancel := OFA210MOT("000002","2","","",.f.) // Filtro da consulta do motivo
		If Len(aMotCancel) == 0
			MsgInfo(STR0228) // "ษ necessแrio informar o motivo do cancelamento do registro de pe็a pendente para requisi็ใo."
			Return .f.
		EndIf
		For nCont := 1 to Len(oGetPecas:aCols)
			If oGetPecas:aCols[nCont,Len(oGetPecas:aCols[nCont])] .and. !Empty(oGetPecas:aCols[nCont,nVSJTIPTEM]) .and. !Empty(oGetPecas:aCols[nCont,nVSJCODITE])
				oGetPecas:aCols[ oGetPecas:nAT, FG_POSVAR("VSJ_MOTPED","oGetPecas:aHeader") ] := aMotCancel[1]
				oGetPecas:aCols[ oGetPecas:nAT, FG_POSVAR("VSJ_DESMOT","oGetPecas:aHeader") ] := aMotCancel[2]
			EndIf
		Next nCont
	EndIf
	//

Return .t.


/*/{Protheus.doc} TelaVSJManual
Monta tela para digita็ใo manual dos registros na VSJ
@author Rubens
@since 04/05/2016
@version 1.0
@param nOpc, numeric, descricao
@type function
/*/
Static Function TelaVSJManual(nOpc)

	Local oInterfHelper := DMS_InterfaceHelper():New()
	Local oSizePrinc
	Local aCamposVSJ := {'VO3_TIPTEM','VO3_FATPAR','VO3_LOJA','VO3_CODTES','VO3_OPER','VO3_GRUITE','VO3_CODITE','VO3_FORMUL','VO3_LOTECT','VO3_NUMLOT','VO3_QTDREQ'}
	Local nCont

	oInterfHelper:nOpc := 3
	oInterfHelper:SetOwnerPvt("OM020VSJMANUAL")
	oSizePrinc := oInterfHelper:CreateDefSize( .t. , ;
		{ ;
			{ "GETDADOS", 80, 30 , .T. , .T. } /* , { "ITEREL"  , 20, 20 , .T. , .T. } */ ;
		} , , 0 )
	oSizePrinc:Process()
	oInterfHelper:SetDefSize(oSizePrinc)

	oDlg020Rascunho := oInterfHelper:CreateDialog(STR0231) // "Pe็as da OS"

	oInterfHelper:SetNomeObjDefSize("GETDADOS")
	oInterfHelper:AddHeaderOBJ( DMS_IFColObj():New( { { "TITULO" , "Classif." } , { "CAMPO" , "DIA_CLASS"  } , { "TAMANHO" , 2 } } ) )
	oInterfHelper:AddHeaderTAB("VSJ", { {"MOSTRA" , "VSJ_TIPTEM/VSJ_FATPAR/VSJ_LOJA  /VSJ_NOMCLI/VSJ_CODITE/VSJ_GRUITE/VSJ_DESITE/VSJ_CODTES/VSJ_QTDINI/VSJ_OPER  /VSJ_DEPINT/VSJ_DEPGAR/VSJ_CODSIT/VSJ_QTDEST/VSJ_MOTPED/VSJ_DESMOT/" } , { "WALKTHRU" , .T. } } )
	oGetPecas := oInterfHelper:CreateNewGetDados("oGetPecas" , { { "OPERACAO" , GD_INSERT + GD_UPDATE + GD_DELETE } , ;
                                                                 { "FIELDOK" , "OM020FOKVSJ()" } , ;
                                                                 { "LINHAOK" , "OM020LOKVSJ()" } , ;
                                                                 { "BCHANGE_ADD", ", OM0200083_BlqCpoRascunho()" } , ;
                                                                 { "FREEZE", 1 } } )
	oGetPecas:oBrowse:bDelete := { || OM020DELRA() }

	oArrHelper:Merge(aCamposVSJ, oGetPecas:aAlter) // juntando os campos alteraveis para pode digitar normal pela tela do VSJ

	aAlterGetD := aCamposVSJ
	aHeaderObrigat := oInterfHelper:MGetRetObrigat()
	For nCont := 1 to Len(oGetPecas:aHeader)
		Do Case
		Case IsHeadRec(oGetPecas:aHeader[nCont,2])   ; nColHeadRec := nCont
		Case IsHeadAlias(oGetPecas:aHeader[nCont,2]) ; nColHeadAlias := nCont
		End Case
	Next nCont
/*
	oInterfHelper:Clean()

	oInterfHelper:SetNomeObjDefSize("ITEREL")
	oInterfHelper:AddColLBox( { { "CABEC" , STR0147 } , { "CODEBLOCK" , "{ || oLbIteRel:aArray[oLbIteRel:nAt,6] }" } , { "TAMANHO" , 20 } } ) // marca
	oInterfHelper:AddColLBox( { { "CABEC" , STR0012 } , { "CODEBLOCK" , "{ || oLbIteRel:aArray[oLbIteRel:nAt,7] }" } , { "TAMANHO" , 50 } } ) // descricao
	oInterfHelper:AddColLBox( { { "CABEC" , STR0033 } , { "CODEBLOCK" , "{ || oLbIteRel:aArray[oLbIteRel:nAt,8] }" } , { "TAMANHO" , 40 } } ) // codigo interno
	oInterfHelper:AddColLBox( { { "CABEC" , STR0010 } , { "CODEBLOCK" , "{ || oLbIteRel:aArray[oLbIteRel:nAt,1] }" } , { "TAMANHO" , 20 } } ) // grupo
	oInterfHelper:AddColLBox( { { "CABEC" , STR0011 } , { "CODEBLOCK" , "{ || oLbIteRel:aArray[oLbIteRel:nAt,2] }" } , { "TAMANHO" , 30 } } ) // c๓digo do item
	oInterfHelper:AddColLBox( { { "CABEC" , STR0012 } , { "CODEBLOCK" , "{ || oLbIteRel:aArray[oLbIteRel:nAt,3] }" } , { "TAMANHO" , 70 } } ) // descricao
	oInterfHelper:AddColLBox( { { "CABEC" , STR0013 } , { "CODEBLOCK" , "{ || Transform(oLbIteRel:aArray[oLbIteRel:nAt,4],'@E 999,999')        }" } , { "ALIGN" , "RIGHT" } , { "TAMANHO" , 30 } } ) // quantidade
	oInterfHelper:AddColLBox( { { "CABEC" , STR0014 } , { "CODEBLOCK" , "{ || Transform(oLbIteRel:aArray[oLbIteRel:nAt,5],'@E 999,999,999.99') }" } , { "ALIGN" , "RIGHT" } , { "TAMANHO" , 40 } } ) // valor
	oLbIteRel := oInterfHelper:CreateLBox("oLbIteRel")
//	oLbIteRel:SetArray( FS_MNTITEREL() )
	oLbIteRel:SetArray( {{"","","",0,0,"","",""}} )
	oLbIteRel:Refresh()
*/
	If .f.
		OM0200083_BlqCpoRascunho()
	EndIf

Return

/*/{Protheus.doc} LoadVSJManual
Carrega os dados gravados na VSJ do tipo manual.
@author Rubens
@since 04/05/2016
@version 1.0

@type function
/*/
Static Function LoadVSJManual()

	Local nCont
	Local cSQL := ""
	Local cAliasVSJ := "TVSJ"
	
	Local nPos := 0

	INCLUI := .f.

	SB1->(dbSetOrder(7))

	cSQL := ;
		"SELECT R_E_C_N_O_ VSJRECNO " +;
		 " FROM " + RetSQLName("VSJ") + " VSJ " +;
		" WHERE VSJ.VSJ_FILIAL = '" + xFilial("VSJ") + "'" +;
		  " AND VSJ.VSJ_NUMOSV = '" + VO1->VO1_NUMOSV + "'" +;
		  " AND VSJ.VSJ_ORIDAD = '4'" +;
		  " AND VSJ.VSJ_QTDITE > 0 " +;
		  " AND VSJ.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cAliasVSJ, .T., .T. )
	If !(cAliasVSJ)->(Eof())
		oGetPecas:aCols := {}
	EndIf
	While !(cAliasVSJ)->(Eof())
		VSJ->(dbGoTo((cAliasVSJ)->VSJRECNO))

		RegToMemory("VSJ",.F.)

		SB1->(dbSeek(xFilial("SB1") + VSJ->VSJ_GRUITE + VSJ->VSJ_CODITE ))

		AADD( oGetPecas:aCols , Array( Len(oGetPecas:aHeader) + 1 )  )
		nPos++
		oGetPecas:aCols[ nPos , Len(oGetPecas:aHeader) + 1 ] := .f.

		For nCont := 1 to Len(oGetPecas:aHeader)
			Do Case
			Case nCont == nColHeadRec   ; oGetPecas:aCols[ nPos , nCont ] := (cAliasVSJ)->VSJRECNO
			Case nCont == nColHeadAlias ; oGetPecas:aCols[ nPos , nCont ] := "VSJ"
			Otherwise; oGetPecas:aCols[ nPos , nCont ] := &( "M->" + oGetPecas:aHeader[nCont,2] )
			End
		Next nCont

		oGetPecas:aCols[ nPos ,FG_POSVAR("VSJ_QTDEST","oGetPecas:aHeader")] := M->VSJ_QTDEST := FS_SALDOESTQ( SB1->B1_COD , OM0200065_ArmazemOrigem( M->VSJ_TIPTEM ) )
		FS_ATULEGESTQ(nPos)

		(cAliasVSJ)->(dbSkip())
	End
	(cAliasVSJ)->(dbCloseArea())
	dbSelectArea("VO1")

	INCLUI := .T.
	n := oGetPecas:nAt := 1
	oGetPecas:Refresh()

Return

/*/{Protheus.doc} OM020FOKVSJ
Field OK da GetDados de digita็ใo das pe็as da OS (VSJ)
@author Rubens
@since 04/05/2016
@version undefined
@param cReadVar, characters, ReadVar para tratamento da GetDados
@type function
/*/
Function OM020FOKVSJ(cReadVar)

	Local lRetorno := .t.

	Default cReadVar := ReadVar()

	If cReadVar == "M->VSJ_TIPTEM"
		M->VO3_TIPTEM := M->VSJ_TIPTEM
		VOI->(DbSetOrder(1))
		VOI->(DbSeek(xFilial("VOI")+M->VSJ_TIPTEM))
		If VOI->VOI_DEPGAR <> "1" .and. !Empty(M->VSJ_DEPGAR)
			aCols[n,FG_POSVAR("VSJ_DEPGAR")] := M->VSJ_DEPGAR := Space(TamSX3("VSJ_DEPGAR")[1])
		EndIf
		If VOI->VOI_DEPINT <> "1" .and. !Empty(M->VSJ_DEPINT)
			aCols[n,FG_POSVAR("VSJ_DEPINT")] := M->VSJ_DEPINT := Space(TamSX3("VSJ_DEPINT")[1])
		EndIf
		If !Empty(VOI->VOI_CODOPE)
			aCols[n,FG_POSVAR("VSJ_OPER")] := M->VSJ_OPER := VOI->VOI_CODOPE
			If !Empty(aCols[n,FG_POSVAR("VSJ_CODITE")])
				OM020FOKVSJ("M->VSJ_OPER")
			EndIf
		EndIf
	EndIf

	If cReadVar == "M->VSJ_GRUITE"
		M->VO3_GRUITE := M->VSJ_GRUITE
	EndIf

	If cReadVar == "M->VSJ_CODITE"
		aCols[n,FG_POSVAR("VSJ_GRUITE")] := M->VSJ_GRUITE := M->VO3_GRUITE := SB1->B1_GRUPO
		aCols[n,FG_POSVAR("VSJ_DESITE")] := M->VSJ_DESITE := SB1->B1_DESC
		aCols[n,FG_POSVAR("VSJ_QTDINI")] := M->VSJ_QTDINI := 0

		If !Empty(aCols[n,FG_POSVAR("VSJ_OPER")])
			OM020FOKVSJ("M->VSJ_OPER")
		EndIf
		If Empty(aCols[n,FG_POSVAR("VSJ_CODTES")]) .and. !Empty(SB1->B1_TS)
			aCols[n,FG_POSVAR("VSJ_CODTES")] := M->VSJ_CODTES := SB1->B1_TS
		EndIf

		If lMostraEstoque
			aCols[n,FG_POSVAR("VSJ_QTDEST")] := M->VSJ_QTDEST := FS_SALDOESTQ( SB1->B1_COD , OM0200065_ArmazemOrigem( M->VSJ_TIPTEM ) )
		EndIf
	EndIf

	If cReadVar == "M->VSJ_OPER"
		cAuxTES := MaTesInt(2,M->VSJ_OPER,M->VSJ_FATPAR,M->VSJ_LOJA,"C",SB1->B1_COD)
		If !Empty(cAuxTES)
			SF4->(dbSetOrder(1))
			If !SF4->(MsSeek(xFilial("SF4") + cAuxTES))
				Help(" ",1,"REGNOIS",,AllTrim(RetTitle("VSJ_CODTES")) + ": " + cAuxTES ,4,1)
				Return .f.
			EndIf
			aCols[n,FG_POSVAR("VSJ_CODTES")]:= M->VSJ_CODTES := cAuxTES
		EndIf
	EndIf

	If cReadVar == "M->VSJ_QTDINI"
		If lMostraEstoque
			FS_ATULEGESTQ()
		EndIf
	EndIf

	//Validacao por Ponto de Entrada
	If ExistBlock("OM020OKV")
		lRetorno := ExecBlock("OM020OKV",.f.,.f.,{cReadVar})
	Endif

Return lRetorno

/*/{Protheus.doc} OM020LOKVSJ
Linha OK da GetDados de digita็ใo das pe็as da OS (VSJ)
@author Rubens
@since 04/05/2016
@version undefined
@param cReadVar, characters, ReadVar para tratamento da GetDados
@type function
/*/
Function OM020LOKVSJ()
	Local lRetorno := .f.

	If Empty(oGetPecas:aCols[oGetPecas:nAt, FG_POSVAR("VSJ_TIPTEM")])
		Return .t.
	EndIf

	if oGetPecas:nAt >= 2
		if empty(oGetPecas:aCols[oGetPecas:nAt, FG_POSVAR("VSJ_CODSIT")])
			oGetPecas:aCols[oGetPecas:nAt, FG_POSVAR("VSJ_CODSIT")] := oGetPecas:aCols[oGetPecas:nAt-1, FG_POSVAR("VSJ_CODSIT")]
		endif
		if empty(oGetPecas:aCols[oGetPecas:nAt, FG_POSVAR("VSJ_CODTES")])
			oGetPecas:aCols[oGetPecas:nAt, FG_POSVAR("VSJ_OPER")] := oGetPecas:aCols[oGetPecas:nAt-1, FG_POSVAR("VSJ_OPER")]
			oGetPecas:aCols[oGetPecas:nAt, FG_POSVAR("VSJ_CODTES")] := oGetPecas:aCols[oGetPecas:nAt-1, FG_POSVAR("VSJ_CODTES")]
			oGetPecas:aCols[oGetPecas:nAt, FG_POSVAR("VSJ_TIPTEM")] := oGetPecas:aCols[oGetPecas:nAt-1, FG_POSVAR("VSJ_TIPTEM")]
		endif
	endif

	lRetorno := FG_OBRIGAT(aHeaderObrigat)
Return lRetorno

/*/{Protheus.doc} FS_ATULEGESTQ
Atualiza coluna da situa็ใo da GetDados de Digita็ใo manual das pe็as da Ordem de Servi็o
@author Rubens
@since 04/05/2016
@version 1.0
@param nPos, numeric, linha da GetDados para atualizacao
@type function
/*/
Static Function FS_ATULEGESTQ(nPos)
	local aItem
	Local aArea := GetArea()
	Default nPos := oGetPecas:nAt
	aItem := oGetPecas:aCols[nPos] // dados do item selecionado
	nRecno := aItem[len(aItem)-1]
	
	If nRecno > 0
		dbSelectArea('VSJ')
		dbGoTo(nRecno)
		aItem[1] := iif(VSJ->VSJ_QESTNA < VSJ->VSJ_QTDINI, oVermelho, oVerde)
	else
		aItem[1] := iif(aItem[FG_POSVAR("VSJ_QTDEST","oGetPecas:aHeader") ] < aItem[FG_POSVAR("VSJ_QTDINI","oGetPecas:aHeader")], oVermelho, oVerde)
	endif
	RestArea( aArea )
Return .t.

/*/{Protheus.doc} FS_SALDOESTQ
Retorna o saldo em estoque do local passado como parametro
@author Rubens
@since 04/05/2016
@version 1.0
@param cProduto, characters, Codigo do Produto para consulta do estoque
@param cAuxLocal, characters, Local para consulta do estoque
@type function
/*/
Static Function FS_SALDOESTQ( cProduto , cAuxLocal )
	Local aArea := GetArea()
	Local nRetSaldo := 0
	DbSelectArea("SB2")
	DbSetOrder(1)
	If DbSeek(xFilial("SB2") + cProduto + cAuxLocal )
		nRetSaldo := SaldoSB2()
	EndIf
	RestArea( aArea )
Return nRetSaldo

/*/{Protheus.doc} FS_VALCUS
Retorna o valor de custo do produto/local enviado como parametro
@author Rubens
@since 04/05/2016
@version 1.0
@param cProduto, characters, Codigo do Produto para consulta do estoque
@param cAuxLocal, characters, Local para consulta do estoque
@type function
/*/
Static Function FS_VALCUS( cProduto , cAuxLocal )
	Local cSQL
	cSQL := "SELECT B2_CM1 " +;
		 " FROM " + RetSQLName("SB2") + " SB2 " +;
		" WHERE SB2.B2_FILIAL = '" + xFilial("SB2") + "'" +;
		  " AND SB2.B2_COD = '" + cProduto + "'" +;
		  " AND SB2.B2_LOCAL = '" + cAuxLocal + "'" +;
		  " AND SB2.D_E_L_E_T_ = ' '"
Return FM_SQL(cSQL)

/*/{Protheus.doc} OM0200083_BlqCpoRascunho
Bloqueia campos para edicao da getdados se o mesmo ja estiver gravado na base de dados
@author Rubens
@since 04/05/2016
@version 1.0
@type function
/*/
Function OM0200083_BlqCpoRascunho()
	If !Empty(oGetPecas:aCols[ oGetPecas:nAt, FG_POSVAR("VSJ_MOTPED", "oGetPecas:aHeader") ])
		oGetPecas:aAlter := oGetPecas:oBrowse:aAlter := {}
	ElseIf oGetPecas:aCols[oGetPecas:nAT,nColHeadRec] <> 0
		oGetPecas:aAlter := oGetPecas:oBrowse:aAlter := { "VSJ_CODSIT" }
	Else
		oGetPecas:aAlter := oGetPecas:oBrowse:aAlter := aAlterGetD
	EndIf
Return

/*/{Protheus.doc} OM020DELRA
Registra venda perdida de oficina quando a peca ้ deletada da GetDados
@author Rubens
@since 04/05/2016
@version 1.0
@type function
/*/
Static Function OM020DELRA()
Local cQuery := ""
	If !Empty(oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VSJ_MOTPED","oGetPecas:aHeader")])
		Return
	EndIf

	If oGetPecas:aCols[oGetPecas:nAT,nColHeadRec] <> 0
		// Se o registro estiver gravado na base, so podera ser marcada venda perdida se nao foi feita requisicao ...
		If !oGetPecas:aCols[ oGetPecas:nAt, Len(oGetPecas:aCols[oGetPecas:nAt])]
			VSJ->(dbGoTo( oGetPecas:aCols[oGetPecas:nAT,nColHeadRec] ))
			If VSJ->VSJ_QTDREQ > 0
				ShowHelpDlg( "VSJMANUAL", { STR0238 }) // "Nใo ้ possํvel registrar venda perdida pois jแ houve requisi็ใo."
				Return
			EndIf
			If GetNewPar("MV_MIL0155","0") == "1" // Tem RESERVA de Pe็as na Digitacao Manual do VSJ ?
				If VSJ->VSJ_RESPEC == "1" // Ja foi feita a Reserva da Pe็a, nao pode excluir
					ShowHelpDlg( "VSJMANUAL", { STR0290 }) // Impossํvel excluir, pois jแ houve reserva da Pe็a.
					Return
				Else // Nใo foi feita a Reserva pq estava sem saldo, gerou Sugestao de Compra ?
					cQuery := "SELECT R_E_C_N_O_ AS RECVE6 "
					cQuery += "  FROM " + RetSqlName( "VE6" )
					cQuery += " WHERE VE6_FILIAL = '"+xFilial("VE6")+"'"
					cQuery += "   AND VE6_INDREG = '0'" // Sugestao
					cQuery += "   AND VE6_ORIREQ = '2'" // Oficina
					cQuery += "   AND VE6_NUMOSV = '"+VO1->VO1_NUMOSV+"'"
					cQuery += "   AND VE6_GRUITE = '"+oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VSJ_GRUITE","oGetPecas:aHeader")]+"'"
					cQuery += "   AND VE6_CODITE = '"+oGetPecas:aCols[oGetPecas:nAt,FG_POSVAR("VSJ_CODITE","oGetPecas:aHeader")]+"'"
					cQuery +=  "  AND D_E_L_E_T_ = ' '"
					If FM_SQL(cQuery) > 0
						ShowHelpDlg( "VSJMANUAL", { STR0291 }) // Impossํvel excluir, pois esta Pe็a jแ possui Sugestใo de Compras relacionada a Ordem de Servi็o.
						Return
					EndIf
				EndIf
			EndIf
		EndIf
		//
	EndIf
	//
	oGetPecas:aCols[ oGetPecas:nAt, Len(oGetPecas:aCols[oGetPecas:nAt])] := !oGetPecas:aCols[ oGetPecas:nAt, Len(oGetPecas:aCols[oGetPecas:nAt])]
	oGetPecas:Refresh()

Return


/*/{Protheus.doc} FS_POSPECAORC
Procura linha da Matriz de Pecas Importadas para a OS (aPecaOrc)
@author Rubens
@since 04/05/2016
@version 1.0
@param lPesqSel, logical, Inidica se deve considerar na pesquisa coluna que indica se a linha da matriz esta ou nao selecionada
@param lParMarcado, logical, Pesquisa linha selecionada ou nao. So sera utilizado se o parametro anterior for .t.
@param cParTiptem, characters, Tipo de tempo para pesquisa
@param cParFatPar, characters, Cliente para pesquisa
@param cParLoja, characters, Loja do Cliente para pesquisa
@param cParGruIte, characters, Grupo da peca para pesquisa
@param cParCodIte, characters, Codigo Item da peca para pesquisa
@param cParSeqInc, characters, Sequencia de incoveniente para pesquisa
@param cParVSJCod, characters, Codigo da VSJ para pesquisa. Se for passado esse parametro a consulta sera feita somente por este codigo.
@type function
/*/
Static Function FS_POSPECAORC(lPesqSel, lParMarcado, cParTiptem , cParFatPar, cParLoja, cParGruIte, cParCodIte, cParSeqInc, cParVSJCod, cParLote, cParSubLote )

	Local nRetPos := 0
	Local cCondicao

	Default cParFatPar := ""
	Default cParLoja := ""
	Default cParVSJCod := ""
	Default cParLote := ""
	Default cParSubLote := ""

	cCondicao := IIf( lPesqSel , IIf( lParMarcado , "x[1]" , "!x[1]" ) + " .and. " , "")
	If lVSJCODIGO .and. !Empty(cParVSJCod)
		cCondicao += "x[" + Str(PECAORC_CODIGOVSJ,2) + "] = '" + cParVSJCod + "'"
	Else
		cCondicao += ;
			" x[02] == '" + cParTiptem + "' .and. " +;
			IIf( !Empty(cParFatPar) , " x[03] == '" + cParFatPar + "' .and. " , "" ) +;
			IIf( !Empty(cParLoja  ) , " x[04] == '" + cParLoja   + "' .and. " , "" ) +;
			" x[06] == '" + cParGruIte + "' .and. " +;
			" x[07] == '" + cParCodIte + "' " +;
			IIf( lInconveniente , " .and. x[20] == '" + cParSeqInc + "'" , "") +;
			IIf( lCtrlLote , " .and. x[30] == '" + cParLote    + "'" , "" ) +;
			IIf( lCtrlLote , " .and. x[31] == '" + cParSubLote + "'" , "" )
	EndIf

	nRetPos := aScan( aPecaOrc , &(" { |x| " + cCondicao + " }" ) )

Return nRetPos

Static Function FS_POSORC2(lPesqSel, lParMarcado, nLinGetDados)
	Local nRetorno
	nRetorno := FS_POSPECAORC(;
		lPesqSel, ;
		lParMarcado, ;
		aCols[nLinGetDados,FG_POSVAR("VO3_TIPTEM")],;
		aCols[nLinGetDados,FG_POSVAR("VO3_FATPAR")],;
		aCols[nLinGetDados,FG_POSVAR("VO3_LOJA")]  ,;
		aCols[nLinGetDados,FG_POSVAR("VO3_GRUITE")],;
		aCols[nLinGetDados,FG_POSVAR("VO3_CODITE")],;
		IIf( lInconveniente, aCols[nLinGetDados,FG_POSVAR("VO3_SEQINC")] , "") ,;
		IIf( lVSJCODIGO    , aCols[nLinGetDados,FG_POSVAR("VO3_CODVSJ")] , "") ,;
		IIf( lCtrlLote     , aCols[nLinGetDados,FG_POSVAR("VO3_LOTECT")] , "") ,;
		IIf( lCtrlLote     , aCols[nLinGetDados,FG_POSVAR("VO3_NUMLOT")] , "") ;
		)
Return nRetorno


/*/{Protheus.doc} FS_POSACOLS

Procura linha da aCols relacionada a uma linha da Matriz de Pecas da VSJ (aPecaOrc)

@author Rubens
@since 04/05/2016
@version 1.0
@param nPosPecaOrc, numeric, Linha da aPecaOrc com os dados para pesquisa na aCols
@param lIgnoreDel, logical, Indica se deve ignorar os registros deletados
@param lPesqLote, logical, Indica se utiliza lote e sublote para pesquisa
@type function
/*/
Static Function FS_POSACOLS( nPosPecaOrc , lIgnoreDel , lPesqLote )

	Local nRetPos := 0
	Local cCondicao := ""
	Local cColunas := Str(Len(aCols[1]),3)

	Default lPesqLote := .t.

	cCondicao := IIf( lIgnoreDel , "" , "!x[" + cColunas + "] .and. " )
	If lVSJCODIGO .and. !Empty(aPecaOrc[nPosPecaOrc,PECAORC_CODIGOVSJ])
		cCondicao += "x[" + Str(FG_POSVAR("VO3_CODVSJ"),3) + "] = '" + aPecaOrc[nPosPecaOrc,PECAORC_CODIGOVSJ] + "'"
	Else
		cCondicao += ;
			"x[" + Str(FG_POSVAR("VO3_GRUITE"),3) + "] == '" + aPecaOrc[nPosPecaOrc,PECAORC_GRUITE] + "' .and. " +;
			"x[" + Str(FG_POSVAR("VO3_CODITE"),3) + "] == '" + aPecaOrc[nPosPecaOrc,PECAORC_CODITE] + "' .and. " +;
			"x[" + Str(FG_POSVAR("VO3_TIPTEM"),3) + "] == '" + aPecaOrc[nPosPecaOrc,PECAORC_TIPTEM] + "' .and. " +;
			"x[" + Str(FG_POSVAR("VO3_FATPAR"),3) + "] == '" + aPecaOrc[nPosPecaOrc,PECAORC_CLIFAT] + "' .and. " +;
			"x[" + Str(FG_POSVAR("VO3_LOJA")  ,3) + "] == '" + aPecaOrc[nPosPecaOrc,PECAORC_LOJFAT] + "' .and. " +;
			"x[" + Str(FG_POSVAR("VO3_IMPORC"),3) + "] == '1' " +;
			IIf( lInconveniente , " .and. x[" + Str(FG_POSVAR("VO3_SEQINC"),3) + "] == '" + aPecaOrc[nPosPecaOrc,PECAORC_SEQINCONV] + "'" , "" )
		If lCtrlLote .AND. lPesqLote
			cCondicao += ;
				" .and. x[" + Str(FG_POSVAR("VO3_LOTECT"),3) + "] == '" + aPecaOrc[nPosPecaOrc,PECAORC_LOTECT] + "' " +;
				" .and. x[" + Str(FG_POSVAR("VO3_NUMLOT"),3) + "] == '" + aPecaOrc[nPosPecaOrc,PECAORC_NUMLOT] + "' "
		EndIf
	EndIf

	nRetPos := aScan( aCols , &(" { |x| " + cCondicao + " }" ) )

Return nRetPos

/*/{Protheus.doc} OM020TESVALIDA
Fun็ใo responsแvel por verificar se o TES existe e se liberada para utiliza็ใo

@author Rubens
@since 08/06/2016
@version undefined
@param cCodTes, characters, C๓digo do TES para valida็ใo

@type function
/*/
Static Function OM020TESVALIDA(cCodTes)

	SF4->(dbSetOrder(1))
	If !SF4->(MsSeek(xFilial("SF4") + cCodTes))
		Help(" ",1,"REGNOIS",,AllTrim(RetTitle("VO3_CODTES")) + ": " + cCodTes ,4,1)
		Return .f.
	EndIf

	If SF4->F4_MSBLQL == "1"
		ShowHelpDlg ( "M020TES", { STR0225 }) // TES bloqueado, impossํvel continuar!
		Return .f.
	Endif

Return .t.


/*/{Protheus.doc} OM020RELDEV
Relaciona itens para devolucao com itens requisitados

@author Rubens
@since 08/06/2016
@version undefined
@param cCodTes, characters, C๓digo do TES para valida็ใo

@type function
/*/
Function OM020RELDEV(cNumOsv, aPecaDev, aIteVO3)


Local aReqPeca := FMX_CALPEC(cNumOsv,,,,.t.,.f.,.t.,.t.,.f.,.f.,.f.,,,.f.,)
Local aFiltroPeca  := {}
Local cProdAtu := ""
Local aAuxIteVO3
Local nPosDatReq
Local nQtdDevolve
Local nPos
Local nCont
Local lCpoDesconto := ( VO3->(FieldPos("VO3_VALLIQ")) <> 0 )

VOI->(dbSetOrder(1))

aIteVO3 := {}

Asort(aPecaDev,,,{ |x,y| x[1] + x[2] + x[3] + StrZero(x[4],10,4) < y[1] + y[2] + y[3] + StrZero(y[4],10,4) })
For nCont := 1 to Len(aPecaDev)
	If cProdAtu <> aPecaDev[nCont,1] + aPecaDev[nCont,2] + aPecaDev[nCont,3]
		aFiltroPeca := {}
		aEval( aReqPeca , { |x| IIF(x[PECA_TIPTEM] == aPecaDev[nCont,1] .and. x[PECA_GRUITE] == aPecaDev[nCont,2] .and. x[PECA_CODITE] == aPecaDev[nCont,3] , AADD( aFiltroPeca , aClone(x) ) , ) })
		For nPos := 1 to Len(aFiltroPeca)
			AADD(aFiltroPeca[nPos],aFiltroPeca[nPos,PECA_MOV,1,PECA_MOV_DATREQ])
		Next nPos
		nPosDatReq := Len(aFiltroPeca[1])
		aSort(aFiltroPeca,,,{ |x,y| DtoS(x[nPosDatReq]) + StrZero(x[PECA_QTDREQ],14,4) < DtoS(y[nPosDatReq]) + StrZero(y[PECA_QTDREQ],14,4) })
		cProdAtu := aPecaDev[nCont,1] + aPecaDev[nCont,2] + aPecaDev[nCont,3]
	EndIf
	nPos := 1
	While nPos <= Len(aFiltroPeca)
		If aFiltroPeca[nPos,PECA_QTDREQ] > 0

			VOI->(MsSeek( xFilial("VOI") + aFiltroPeca[nPos,PECA_TIPTEM]))

			VO3->(dbGoTo(aFiltroPeca[nPos,PECA_MOV,1,PECA_MOV_RECVO3]))

			nQtdDevolve := IIf( aPecaDev[nCont,4] <= aFiltroPeca[nPos,PECA_QTDREQ] , aPecaDev[nCont,4] , aFiltroPeca[nPos,PECA_QTDREQ] )

			aAuxIteVO3 := {}
			AADD(aAuxIteVO3, { "VO3_NUMOSV" , VO1->VO1_NUMOSV , nil } )
			AADD(aAuxIteVO3, { "VO3_TIPTEM" , aPecaDev[nCont,1] , nil } )
			AADD(aAuxIteVO3, { "VO3_GRUITE" , aPecaDev[nCont,2] , nil } )
			AADD(aAuxIteVO3, { "VO3_CODITE" , aPecaDev[nCont,3] , nil } )
			If !Empty(aFiltroPeca[nPos,PECA_INCONV_SEQ])
				AADD(aAuxIteVO3, { "VO3_SEQINC" , aFiltroPeca[nPos,PECA_INCONV_SEQ] , nil } )
			EndIf
			If VOI->VOI_VLPCAC == "1" // Valor da Peca no fechamento ้ o Valor da Requisicao
				AADD(aAuxIteVO3, { "VO3_VALPEC" , VO3->VO3_VALPEC , nil } )
				If lCpoDesconto .AND. VO3->VO3_VALLIQ <> 0
					AADD(aAuxIteVO3, { "VO3_VALLIQ" , VO3->VO3_VALLIQ , nil } )
				EndIf
			EndIf
			AADD(aAuxIteVO3, { "VO3_CODTES" , VO3->VO3_CODTES , nil } )
			AADD(aAuxIteVO3, { "VO3_FORMUL" , VO3->VO3_FORMUL , nil } )
			AADD(aAuxIteVO3, { "VO3_QTDREQ" , nQtdDevolve , nil } )
			AADD( aIteVO3 , aClone( aAuxIteVO3 ) )

			aFiltroPeca[nPos,PECA_QTDREQ] -= nQtdDevolve
			aPecaDev[nCont,4] -= nQtdDevolve

			If aPecaDev[nCont,4] == 0
				Exit
			EndIf
		EndIf
		nPos++
	EndDo
	If aPecaDev[nCont,4] <> 0
		ShowHelpDlg( "OM020RELDEV" , {STR0241 ,; // Nใo foi possํvel relacionar pe็as para devolu็ใo.
			AllTrim(RetTitle("VO3_TIPTEM")) + ": " + aPecaDev[nCont,1] ,;
			AllTrim(RetTitle("VO3_GRUITE")) + ": " + aPecaDev[nCont,2] ,;
			AllTrim(RetTitle("VO3_CODITE")) + ": " + aPecaDev[nCont,3] ,;
			STR0004 + ": " + Transform(aPecaDev[nCont,4],PesqPict("VO3","VO3_QTDREQ")) ; // Devolu็ใo
			} )
		Return .f.
	EndIf
Next nCont
Return .t.

/*/{Protheus.doc} OM020PESQLOTE
Retorna matriz com lotes para movimentacao do estoque
@author Rubens
@since 05/09/2016
@version undefined
@param cGruIte, characters, Grupo da Peca
@param cCodIte, characters, Codigo da Peca
@param nI, numeric, Linha da aCols para consulta
@param aLotes, array, Matriz que retornara os lotes para movimentacao (Parametro deve ser passado como referencia)
@type function
/*/
Static Function OM020PESQLOTE(cGruIte, cCodIte, nI, aLotes, aLotesAutom)

	Local oPeca
	Local cLocal
	Local cLocaliz
	Local cRetorno := "NAORASTRO"
	Local aLotesInf
	Local nAuxPosProc
	Local cLocalProc
	Local cLocalizProc


	SB1->(dbSetOrder(7))
	SB1->(dbSeek(xFilial("SB1") + cGruIte + cCodIte ))
	SB1->(dbSetOrder(1))
	If Rastro(SB1->B1_COD) .and. Empty(aCols[nI,FG_POSVAR("VO3_LOTECT")])

		oPeca := DMS_Peca():New()
		oPeca:LoadB1()

		OM020LOCAL( nI , @cLocal , @cLocaliz )

		aLotesInf := {}
		If ( nAuxPosProc := aScan(aLotesAutom, { |x| x[1] == cGruIte .and. x[2] == cCodIte .and. x[3] == cLocal }) ) <> 0
			aLotesInf := aClone(aLotesAutom[nAuxPosProc,4])
		EndIf

		// Pesquisa se algum lote foi informado manualmente, para que a funcao nao considere o saldo informado ...
		For nAuxPosProc := 1 to Len(aCols)
			If aCols[nAuxPosProc,Len(aCols[nAuxPosProc])]
				Loop
			EndIf

			If aCols[nAuxPosProc,FG_POSVAR("VO3_GRUITE")] == cGruIte .and. ;
				aCols[nAuxPosProc,FG_POSVAR("VO3_CODITE")] == cCodIte .and. ;
				!Empty(aCols[nAuxPosProc,FG_POSVAR("VO3_LOTECT")])

				OM020LOCAL( nAuxPosProc , @cLocalProc , @cLocalizProc )
				If cLocalProc == cLocal // .and. cLocalizProc == cLocaliz
					OM020INFLOTES(;
						@aLotesInf,;
						aCols[nAuxPosProc,FG_POSVAR("VO3_LOTECT")],;
						aCols[nAuxPosProc,FG_POSVAR("VO3_NUMLOT")],;
						cLocalizProc,;
						aCols[nAuxPosProc,FG_POSVAR("VO3_QTDREQ")],;
					)

//					AADD( aLotesInf, {;
//						aCols[nAuxPosProc,FG_POSVAR("VO3_LOTECT")],;
//						aCols[nAuxPosProc,FG_POSVAR("VO3_NUMLOT")],;
//						cLocalizProc,;
//						"",;
//						aCols[nAuxPosProc,FG_POSVAR("VO3_QTDREQ")] })
				EndIf
			EndIf
		Next nAuxPosProc
		//
		aLotes := oPeca:SaldoLoteMovimentacao( cLocal ,;
			aCols[nI,FG_POSVAR("VO3_QTDREQ")] ,;
			aCols[nI,FG_POSVAR("VO3_LOTECT")] ,;
			aCols[nI,FG_POSVAR("VO3_NUMLOT")] ,;
			aLotesInf )

		If Len(aLotes) == 0
			ShowHelpDlg ( "OM020NOLOTE", { STR0242 + CHR(13) + CHR(10) + AllTrim(RetTitle("B2_LOCAL")) + ": " + cLocal + CHR(13) + CHR(10) + AllTrim(RetTitle("B2_COD")) + ": " + SB1->B1_GRUPO + "-" + SB1->B1_COD }) // "Pe็a nใo possui lotes disponํveis para requisi็ใo."
			cRetorno := "SEMLOTE"
		Else
			cRetorno := "COMLOTE"

			For nAuxPosProc := 2 to Len(aLotes)
				OM020AUTLOTES(;
					@aLotesAutom,;
					cGruIte,;
					cCodIte,;
					cLocal,;
					cLocaliz,;
					aLotes[ nAuxPosProc , 01],;
					aLotes[ nAuxPosProc , 02],;
					aLotes[ nAuxPosProc , 05] )
			Next nAuxPosProc

		EndIf
	EndIf

Return cRetorno

/*/{Protheus.doc} OM020INFLOTES
Monta matriz com lotes ja utilizados para nao considerar na pesquisa de lotes
@author Rubens
@since 06/09/2016
@version undefined
@param aLotesInf, array, descricao
@param cLoteCT, characters, descricao
@param cNumLot, characters, descricao
@param cLocaliz, characters, descricao
@param nQtdReq, numeric, descricao
@type function
/*/
Static Function OM020INFLOTES(aLotesInf, cLoteCT, cNumLot, cLocaliz, nQtdReq)
	Local nPosLote
	If (nPosLote := aScan( aLotesInf , { |x| x[1] == cLoteCT .and. x[2] == cNumLot .and. x[3] == cLocaliz } )) == 0
		AADD(aLotesInf, { cLoteCT, cNumLot, cLocaliz, "" , 0 })
		nPosLote := Len(aLotesInf)
	EndIf
	aLotesInf[nPosLote,5] += nQtdReq
Return

/*/{Protheus.doc} OM020AUTLOTES
Guarda os lotes retornados pela funcao SldPorLote
@author Rubens
@since 06/09/2016
@version undefined
@param aLotesAutom, array, descricao
@param cGruIte, characters, descricao
@param cCodIte, characters, descricao
@param cLocal, characters, descricao
@param cLocaliz, characters, descricao
@param cLoteCT, characters, descricao
@param cNumLot, characters, descricao
@param nQtdReq, numeric, descricao
@type function
/*/
Static Function OM020AUTLOTES(aLotesAutom, cGruIte, cCodIte, cLocal , cLocaliz, cLoteCT, cNumLot, nQtdReq)
	Local nPosProduto
	Local nPosLote
	If (nPosProduto := aScan( aLotesAutom , { |x| x[1] == cGruIte .and. x[2] == cCodIte .and. x[3] == cLocal } )) == 0
		AADD(aLotesAutom , { cGruIte , cCodIte , cLocal , {} } )
		nPosProduto := Len(aLotesAutom)
	EndIf
	If (nPosLote := aScan( aLotesAutom[nPosProduto,4] , { |x| x[1] == cLoteCT .and. x[2] == cNumLot .and. x[3] == cLocaliz } )) == 0
		AADD(aLotesAutom[nPosProduto,4], { cLoteCT, cNumLot, cLocaliz, "" , 0 })
		nPosLote := Len(aLotesAutom[nPosProduto,4])
	EndIf
	aLotesAutom[nPosProduto,4,nPosLote,5] += nQtdReq
Return

/*/{Protheus.doc} OM020LOCAL
Retorna Almoxarifado e localizacao que serแ utilizado na movimentacao de estoque
@author Rubens
@since 05/09/2016
@version undefined
@param nI, numeric, Linha da aCols que esta sendo processado
@param cLocal, characters, Local (parametro deve ser passado como referencia)
@param cLocaliz, characters, Localizacao (parametro deve ser passado como referencia)
@type function
/*/
Static Function OM020LOCAL( nI , cLocal , cLocaliz )
	Local nPosPecOrc
	Local lLocaliza

	SB1->(dbSetOrder(7))
	SB1->(MsSeek( xFilial("SB1") + aCols[nI, FG_POSVAR("VO3_GRUITE") ] + aCols[nI, FG_POSVAR("VO3_CODITE") ] ))
	SB1->(dbSetOrder(1))

	cLocal := ""
	cLocaliz := ""

	lLocaliza := Localiza(SB1->B1_COD)

	// Se a peca for de orcamento pega do almoxarifado reservado.
	If aCols[nI,FG_POSVAR("VO3_IMPORC")] == "1"
		nPosPecOrc := FS_POSORC2(.t.,.t.,nI)
		If nPosPecOrc <> 0 .And. aPecaOrc[nPosPecOrc,1] // Foi reservado, entao utiliza LOCAL e LOCALIZACAO da VSJ
			cLocal   := aPecaOrc[nPosPecOrc,12]
			cLocaliz := IIf( lLocaliza ,aPecaOrc[nPosPecOrc,13],Space(15))
		EndIf
	EndIf
	If Empty(cLocal)
		SB5->(DbSetOrder(1))
		SB5->(DbSeek( xFilial("SB5") + SB1->B1_COD  ))

		cLocal := OM0200065_ArmazemOrigem( aCols[ nI ,FG_POSVAR("VO3_TIPTEM")] )
		cLocaliz := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")
	EndIf
Return


/*/{Protheus.doc} OM020VO2CriaRegistro
Cria registro de cabecalho de movimentacao
@author Rubens
@since 05/09/2016
@version undefined

@type function
/*/
Static Function OM020VO2CriaRegistro(aVO2NOSNUM)

	DbSelectArea("VO2")
	DbSetOrder(2)
	Do While Empty(M->VO2_NOSNUM) .Or. DbSeek( xFilial("VO2")+M->VO2_NOSNUM )
		M->VO2_NOSNUM := GetSxeNum("VO2","VO2_NOSNUM",,2)
		ConfirmSx8()
	EndDo
	AADD(aVO2NOSNUM,M->VO2_NOSNUM)

	DbSelectArea("VO2")
	DbSetOrder(1)

	DbSelectArea("VO1")
	DbSetOrder(1)
	DbSeek(xFilial("VO1")+M->VO2_NUMOSV)

	dbselectArea("VO2")
	If !RecLock("VO2",.T.)
		Help("  ",1,"REGNLOCK")
		Return .f.
	EndIf
	
	M->VO2_DATREQ := dDataBase
	M->VO2_HORREQ := val(left(time(),2)+substr(time(),4,2))

	FG_GRAVAR("VO2")
	VO2->VO2_DEVOLU := cReqDev
	VO2->VO2_TIPREQ := "P"
	MsUnlock()

Return .t.

/*/{Protheus.doc} OM020VO3CriaRegistro
Cria registro de movimentacao de peca
@author Rubens
@since 05/09/2016
@version undefined
@param nI, numeric, Linha da aCols que estแ sendo processada
@type function
/*/
Static Function OM020VO3CriaRegistro(nI)

	Local oOficina := DMS_Oficina():New()

	DbSelectArea("SB1")
	DbSetOrder(7)
	DbSeek(xFilial("SB1")+aCols[ni,FG_POSVAR("VO3_GRUITE")]+aCols[ni,FG_POSVAR("VO3_CODITE")])

	If oOficina:TipoTempoBloqueado(aCols[ni,FG_POSVAR("VO3_TIPTEM")],.t.) // Valida se Tipo de Tempo esta BLOQUEADO
		Return .f.
	EndIf

	DbSelectArea("VO3")
	DbSetOrder(1)
	RecLock("VO3",.T.)
	FG_GRAVAR("VO3",aCols,aHeader,ni)
	VO3->VO3_FILIAL := xFilial("VO3")
	VO3->VO3_NOSNUM := M->VO2_NOSNUM
	VO3->VO3_NUMOSV := M->VO2_NUMOSV
	VO3->VO3_PECINT := SB1->B1_COD

	If cReqDev == "1" .And. lMVCONSRV .And. FG_POSVAR("VO3_CONSRV") == 0
		VO3->VO3_CONSRV := FG_PROTRA(VO2->VO2_NUMOSV,VO3->VO3_PROREQ,.t.,.f.,nI)
	EndIf

	MsUnlock()

	if ExistBlock("POM020DG")
		ExecBlock("POM020DG",.f.,.f.)
	Endif

	// Valida se o valor esta correto
	If !FS_VALVLR160(VO3->VO3_GRUITE,VO3->VO3_CODITE,VO3->VO3_VALPEC)
		Return .f.
	EndIf

	If lMsErroAuto
		Return .f.
	EndIf

Return .t.

/*/{Protheus.doc} OM020VFBMovimenta
Cria registro na VFB
@author Rubens
@since 05/09/2016
@version undefined

@type function
/*/
Static Function OM020VFBMovimenta()

	Local nQtdDevolve
	Local cAliasVFB := "SQLVFB"
	Local lContinua := .t.

	// Movimenta VFB
	DbSelectArea("VFB")
	DbSetOrder(1)

	If cReqDev == "0" // Devolucao

		nQtdDevolve := 0

		cQuery := "SELECT VFB.R_E_C_N_O_ AS RECVFB "
		cQuery +=  " FROM " + RetSqlName( "VFB" ) + " VFB "
		cQuery += "WHERE VFB.VFB_FILIAL='"+ xFilial("VFB")+ "'"
		cQuery +=  " AND VFB.VFB_CODCLI = '" + M->VO2_PROVEI + "'"
		cQuery +=  " AND VFB.VFB_LOJA   = '" + M->VO2_LJPVEI + "'"
		cQuery +=  " AND VFB.VFB_CHAINT = '" + VO1->VO1_CHAINT + "'"
		cQuery +=  " AND VFB.VFB_SERPEC = 'P'"
		cQuery +=  " AND VFB.VFB_GRUITE = '" + VO3->VO3_GRUITE + "'"
		cQuery +=  " AND VFB.VFB_CODITE = '" + VO3->VO3_CODITE + "'"
		cQuery +=  " AND VFB.D_E_L_E_T_=' '"
		cQuery += " ORDER BY VFB.VFB_DATAPL DESC,VFB.VFB_NUMOSV DESC"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVFB, .T., .T. )
		Do While !( cAliasVFB )->( Eof() ) .and. lContinua
			dbSelectArea("VFB")
			VFB->(dbGoTo(( cAliasVFB )->RECVFB))

			nQtdDevolve := nQtdDevolve + VFB->VFB_QTDAPL
			If !RecLock("VFB",.F.,.T.)
				( cAliasVFB )->(dbclosearea())
				Return .f.
			EndIf
			If VO3->VO3_QTDREQ > nQtdDevolve
				dbdelete()
			Else
				If VO3->VO3_QTDREQ == nQtdDevolve
					dbdelete()
				Else
					VFB->VFB_QTDAPL := nQtdDevolve - VO3->VO3_QTDREQ
				EndIf
				lContinua := .f.
			EndIf
			MsUnlock()
			( cAliasVFB )->(DbSkip())
		EndDo
		( cAliasVFB )->(dbclosearea())

	Else // Requisicao

		If !RecLock("VFB",.T.)
			Help("  ",1,"REGNLOCK")
			Return .f.
		EndIf

		VFB->VFB_FILIAL := xFilial("VFB")
		VFB->VFB_CODCLI := M->VO2_PROVEI
		VFB->VFB_LOJA   := M->VO2_LJPVEI
		VFB->VFB_CHAINT := VO1->VO1_CHAINT
		VFB->VFB_SERPEC := "P"
		VFB->VFB_GRUITE := VO3->VO3_GRUITE
		VFB->VFB_CODITE := VO3->VO3_CODITE
		VFB->VFB_QTDAPL := VO3->VO3_QTDREQ
		VFB->VFB_NUMOSV := M->VO2_NUMOSV
		VFB->VFB_TIPTEM := VO3->VO3_TIPTEM
		VFB->VFB_DATAPL := M->VO2_DATREQ
		VFB->VFB_NUMREQ := M->VO2_NOSNUM
		VFB->VFB_KILOME := VO1->VO1_KILOME

		MsUnlock()

	EndIf

Return .t.

/*/{Protheus.doc} OM020VF6CriaRegistro
Cria registro na VF6
@author Rubens
@since 05/09/2016
@version undefined

@type function
/*/
Static Function OM020VF6CriaRegistro()

	Local cCodMarVV1
	Local cGraSevVV1
	Local nQtdKm
	Local nQtdKmContr
	Local nQtdIte
	Local nQtdIteContr
	Local cAliasVFB := "SQLVFB"

	dbSelectArea("VF6")
	DbSetOrder(1)
	DbSeek(xFilial("VF6")+VV1->VV1_CODMAR+VV1->VV1_MODVEI+VO3->VO3_GRUITE+VO3->VO3_CODITE)
	If !RecLock("VF6",!Found())
		Help("  ",1,"REGNLOCK")
	EndIf
	VF6->VF6_FILIAL := xFilial("VF6")
	VF6->VF6_CODMAR := VV1->VV1_CODMAR
	VF6->VF6_MODVEI := VV1->VV1_MODVEI
	VF6->VF6_GRUITE := VO3->VO3_GRUITE
	VF6->VF6_CODCOM := VO3->VO3_CODITE

	VO5->(DbSetOrder(1))
	If VO5->(DbSeek(xFilial("VO5")+VO1->VO1_CHAINT)) .and. Alltrim(VO5->VO5_GRASEV) $ "12345" .and. lMVCALCMED

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Faz a media de troca do Item do Modelo do Veiculo baseado no        ณ
		//ณ historico do Modelo.                                                ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nQtdKm := nQtdKmContr := 0
		nQtdIte:= nQtdIteContr:= 0

		cCodMarVV1 := FM_SQL("SELECT VV1.VV1_CODMAR FROM "+RetSQLName("VV1")+" VV1 WHERE VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT = '"+VO1->VO1_CHAINT+"' AND VV1.D_E_L_E_T_=' '")
		cGraSevVV1 := FM_SQL("SELECT VO5.VO5_GRASEV FROM "+RetSQLName("VO5")+" VO5 WHERE VO5.VO5_FILIAL='"+xFilial("VO5")+"' AND VO5.VO5_CHAINT = '"+VO1->VO1_CHAINT+"' AND VO5.D_E_L_E_T_=' '")

		cQuery := "SELECT VO5.VO5_VEIACO , SUM(VFB.VFB_KILOME * VFB.VFB_QTDAPL) VFB_KILOME , SUM(VFB.VFB_QTDAPL) VFB_QTDAPL "
		cQuery +=  " FROM " + RetSQLName("VFB") + " VFB "
		cQuery += 		" JOIN " + RetSQLName("VV1") + " VV1 ON VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1.VV1_CHAINT = VFB.VFB_CHAINT AND VV1.D_E_L_E_T_ = ' '"
		cQuery += 		" JOIN " + RetSQLName("VO5") + " VO5 ON VO5_FILIAL = '" + xFilial("VO5") + "' AND VO5.VO5_CHAINT = VFB.VFB_CHAINT AND VFB.D_E_L_E_T_ = ' '"
		cQuery += " WHERE VFB.VFB_FILIAL = '" + xFilial("VFB") + "'"
		cQuery +=   " AND VFB.VFB_GRUITE = '" + VO3->VO3_GRUITE + "'"
		cQuery +=   " AND VFB.VFB_CODITE = '" + VO3->VO3_CODITE + "'"
		cQuery +=   " AND VFB.D_E_L_E_T_ = ' '"
		cQuery +=   " AND VV1.VV1_CODMAR = '" + cCodMarVV1 + "'"
		cQuery +=   " AND VO5.VO5_GRASEV = '" + cGraSevVV1 + "'"
		cQuery += " GROUP BY VO5_VEIACO"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVFB, .T., .T. )
		Do While !( cAliasVFB )->( Eof() )
			If ( cAliasVFB )->VO5_VEIACO == "0"
				nQtdKm  += ( cAliasVFB )->VFB_KILOME
				nQtdIte += ( cAliasVFB )->VFB_QTDAPL
			Else
				nQtdKmContr  += ( cAliasVFB )->VFB_KILOME
				nQtdIteContr += ( cAliasVFB )->VFB_QTDAPL
			EndIf
			( cAliasVFB )->(DbSkip())
		EndDo
		( cAliasVFB )->(dbCloseArea())

		// Grava Media
		DbSelectArea("VF6")
		&("VF6->VF6_MEDIA"+Alltrim(VO5->VO5_GRASEV)) := (nQtdKm/nQtdIte)
		&("VF6->VF6_OCORR"+Alltrim(VO5->VO5_GRASEV)) := nQtdIte

		If VO5->VO5_VEIACO == "1"
			&("VF6->VF6_MEDCT"+Alltrim(VO5->VO5_GRASEV)) := (nQtdKmContr/nQtdIteContr)
			&("VF6->VF6_OCOCT"+Alltrim(VO5->VO5_GRASEV)) := nQtdIteContr
		EndIf
		//

	EndIf

	MsUnLock()

Return .t.


/*/{Protheus.doc} OM020MOVESTOQUE
Movimenta estoque
@author Rubens
@since 05/09/2016
@version undefined
@param nI, numeric, Linha da aCols que esta sendo processada
@type function
/*/
Static Function OM020MOVESTOQUE(nI)

	Local avetDist  := {} // Vetor para Distribui็ใo da Devolu็ใo por Endere็o
	Local cLocal
	Local cLocaliz
	Local nid := 0
	Local aItensNew := {}
	Local lSEMAF261  := (GetNewPar("MV_MIL0130","0")=="1") // Utiliza semแforo na Movimenta็ใo de Pecas da rotina Requisi็ใo de Pecas (0-Nao, 1-Sim)                                                                

	Local oEst     := DMS_Estoque():New()
	Local aItemMov := {}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se a TES selecionada na requisicao movimenta estoque ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	SF4->(dbSetOrder(1))
	SF4->(MsSeek(xFilial("SF4") + VO3->VO3_CODTES ))
	If SF4->F4_ESTOQUE <> "S"
		Return .t.
	EndIf

	If lSEMAF261 // Utiliza semแforo na Movimenta็ใo de Pecas da rotina Requisi็ใo de Pecas
		If !LockByName("OFIOM020"+VO1->VO1_NUMOSV+"MOVPEC",.t.,.t.)
			Help(" ",1,"ROTINA_EM_USO",,STR0285,4,1 )		 // "Impossivel continuar! Semแforo estแ sendo utilizado para trazer o N๚mero do Documento da Movimenta็ใo de Pe็as (MATA261)"
			Return .f.
		Endif
	Endif

	RecLock("VO3",.F.)
	VO3->VO3_NUMDOC := FS_D3NUMDOC()
	MsUnLock()

	aItensNew:={}

	DbSelectArea("SB5")
	DbSetOrder(1)
	DbSeek( xFilial("SB5") + SB1->B1_COD )

	DbSelectArea("SB1")
	DbSetOrder(1)
	//
	// Adiciona cabecalho com numero do documento e data da transferencia modelo II
	//
	aadd (aItensNew,{ VO3->VO3_NUMDOC , ddatabase})

	//ฺฤฤฤฤฤฤฤฤฤฟ
	//ณDevolucaoณ
	//ภฤฤฤฤฤฤฤฤฤู
	If cReqDev == "0"

		aVetDist := {}
		If Localiza(SB1->B1_COD)
			aVetDist := OM020DIST() // Fun็ใo para Distribui็ao da Devolu็ใo por Endere็o
		Endif

		If Len(aVetDist) > 0
			For nid := 1 to Len(aVetDist)

				aItemMov := oEst:SetItemSD3(SB1->B1_COD     ,; //C๓digo do Produto
											VOI->VOI_CODALM ,; // Armaz้m de Origem
											aVetDist[nid,2] ,; // Armaz้m de Destino
											VOI->VOI_LOCALI ,; // Localiza็ใo Origem
											aVetDist[nid,3] ,; // Localiza็ใo Destino
											aVetDist[nid,8] ,; // Qtd a transferir
											aVetDist[nid,4] ,; // Nro de lote
											aVetDist[nid,5] ,; // Nro de Sub-Lote
											VO3->VO3_NUMSER )  // Nro de S้rie

				aAdd(aItensNew, aClone(aItemMov))

			Next

		Else

			cArmDes := OM0200065_ArmazemOrigem( VO3->VO3_TIPTEM )
			cLocDes := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")

			aItemMov := oEst:SetItemSD3(SB1->B1_COD     ,; //C๓digo do Produto
										VOI->VOI_CODALM ,; // Armaz้m de Origem
										cArmDes         ,; // Armaz้m de Destino
										VOI->VOI_LOCALI ,; // Localiza็ใo Origem
										cLocDes         ,; // Localiza็ใo Destino
										VO3->VO3_QTDREQ ,; // Qtd a transferir
										VO3->VO3_LOTECT ,; // Nro de lote
										VO3->VO3_NUMLOT ,; // Nro de Sub-Lote
										VO3->VO3_NUMSER )  // Nro de S้rie

			aAdd(aItensNew, aClone(aItemMov))

		Endif

	Else

		//ฺฤฤฤฤฤฤฤฤฤฤฟ
		//ณRequisicaoณ
		//ภฤฤฤฤฤฤฤฤฤฤู
		OM020LOCAL( nI , @cLocal , @cLocaliz )

		aVetDist := {}
		If Localiza(SB1->B1_COD) .and. ( cLocal <> cMVRESITE )
			aVetDist := OX001PRAUTLC(SB1->B1_COD,cLocal,VO3->VO3_QTDREQ,VO3->VO3_LOTECT,VO3->VO3_NUMLOT)
		Endif

		If Len(aVetDist) > 0
			For nid := 1 to Len(aVetDist)
				
				aItemMov := oEst:SetItemSD3(SB1->B1_COD     ,; //C๓digo do Produto
											cLocal          ,; // Armaz้m de Origem
											VOI->VOI_CODALM ,; // Armaz้m de Destino
											aVetDist[nid,01],; // Localiza็ใo Origem
											VOI->VOI_LOCALI ,; // Localiza็ใo Destino
											aVetDist[nid,02],; // Qtd a transferir
											VO3->VO3_LOTECT ,; // Nro de lote
											VO3->VO3_NUMLOT ,; // Nro de Sub-Lote
											VO3->VO3_NUMSER )  // Nro de S้rie

				aAdd(aItensNew, aClone(aItemMov))

			Next

		Else

			aItemMov := oEst:SetItemSD3(SB1->B1_COD     ,; //C๓digo do Produto
										cLocal          ,; // Armaz้m de Origem
										VOI->VOI_CODALM ,; // Armaz้m de Destino
										cLocaliz        ,; // Localiza็ใo Origem
										VOI->VOI_LOCALI ,; // Localiza็ใo Destino
										VO3->VO3_QTDREQ ,; // Qtd a transferir
										VO3->VO3_LOTECT ,; // Nro de lote
										VO3->VO3_NUMLOT ,; // Nro de Sub-Lote
										VO3->VO3_NUMSER )  // Nro de S้rie

			aAdd(aItensNew, aClone(aItemMov))

		Endif

	EndIf
	
	If Localiza(SB1->B1_COD)

		If ExistBlock("RDLOCALIZ")
			ExecBlock("RDLOCALIZ",.f.,.f.,{@aItensNew})
		Endif

		If Empty(aItensNew[Len(aItensNew),5])
			MsgAlert(STR0138,STR0075) // O armaz้m de reserva estแ sem localiza็ใo. Por favor, verifique. / Aten็ใo
			Return .f.
		EndIf

		If Empty( aItensNew[Len(aItensNew),10] )
			MsgAlert(STR0139,STR0075) // O armaz้m destino estแ sem localiza็ใo. Por favor, verifique o Registo de Tipos de Tempo / Aten็ใo
			Return .f.
		EndIf
		
	Else

		If (ExistBlock("OM020APEC"))
			aItensNew := ExecBlock("OM020APEC", .f., .f., {aItensNew})
		EndIf

	EndIf

	If OM020DUPITE(aItensNew) // verifica os locais das transferencias
		If aItensNew[2,4] # aItensNew[2,9]
			MSExecAuto({|x| MATA261(x)},aItensNew)
		EndIf
	Else
		lMsErroAuto := .T.
	Endif

	If lSEMAF261 // Destrava semแforo na Movimenta็ใo de Pecas da rotina Requisi็ใo de Pecas
		UnLockByName("OFIOM020"+VO1->VO1_NUMOSV+"MOVPEC",.t.,.t.)
	Endif

	If lMsErroAuto
		// Cancela Gravacao
		Return .f.
	EndIf

	OM020VE6BAIXA("DEVOLUCAO")

Return .t.

/*/{Protheus.doc} OM020VE6BAIXA
Baixa registro na VE6
@author Rubens
@since 05/09/2016
@version undefined

@type function
/*/
Static Function OM020VE6BAIXA(cTipoMov, nPosOrc)

	Local nSaldoBx  := 0
	Local nSaldoAux := 0

	Local aArea := GetArea()

	// Requisicao
	If cTipoMov == "REQUISICAO" .and. cReqDev == "1"

		DbSelectArea("VE6")
		dbSetOrder(5) // VE6_NUMOSV+VE6_INDREG+VE6_GRUITE+VE6_CODITE

		VE6->(dbSeek(xFilial("VE6")+VSJ->VSJ_NUMOSV+"3"+VSJ->VSJ_GRUITE+VSJ->VSJ_CODITE))
		While !VE6->(Eof()) .and. VE6->VE6_FILIAL == xFilial("VE6");
			.and. VE6->VE6_NUMOSV == VSJ->VSJ_NUMOSV;
			.and. VE6->VE6_INDREG == "3";
			.and. VE6->VE6_GRUITE == VSJ->VSJ_GRUITE;
			.and. VE6->VE6_CODITE == VSJ->VSJ_CODITE;
			.and. nSaldoBx < aCols[nPosOrc,FG_POSVAR("VO3_QTDREQ")]

			If VE6->VE6_LOTECT <> VSJ->VSJ_LOTECT .OR. VE6->VE6_NUMLOT <> VSJ->VSJ_NUMLOT
				VE6->(dbSkip())
				Loop
			ENDIF

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณProcessa somente registro de reserva com saldoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			IF (VE6->VE6_QTDITE - VE6->VE6_QTDATE - VE6->VE6_QTDEST) <= 0
				VE6->(dbSkip())
				Loop
			ENDIF

			nSaldoAux := (VE6->VE6_QTDITE - VE6->VE6_QTDATE)

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe o saldo do reg. de reserva + o saldo ja reservado for maior do que a requisicao...ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			IF nSaldoAux + nSaldoBx > aCols[nPosOrc,FG_POSVAR("VO3_QTDREQ")]
				nSaldoAux := aCols[nPosOrc,FG_POSVAR("VO3_QTDREQ")] - nSaldoBx
			ENDIF

			RecLock("VE6" ,.F. ,.T.)
			VE6->VE6_DATATE := dDatabase
			VE6->VE6_QTDATE += nSaldoAux
			MsUnLock()

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza saldo ja requisitadoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nSaldoBx += nSaldoAux

			VE6->(dbSkip())

		End

	EndIf

	If cTipoMov == "DEVOLUCAO" .and. cReqDev == "0" .and. lMVRITEORC // Devolucao e Reserva Automatica

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCria um cursor com os reg. de reserva que foram atendidos ordenado do mais velho para o mais novo.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cQuery := "SELECT R_E_C_N_O_ NUMREG"
		cQuery += "  FROM "+RetSQLName("VE6")+" VE6"
		cQuery += " WHERE VE6_FILIAL = '"+xFilial("VE6")+"'"
		cQuery += "   AND VE6_NUMOSV = '"+VO3->VO3_NUMOSV+"'"
		cQuery += "   AND VE6_INDREG = '3'" // S O M E N T E   R E S E R V A
		cQuery += "   AND VE6_GRUITE = '"+VO3->VO3_GRUITE+"'"
		cQuery += "   AND VE6_CODITE = '"+VO3->VO3_CODITE+"'"
		cQuery += "   AND VE6_QTDATE > 0"
		cQuery += "   AND VE6_QTDDEV <> VE6_QTDATE"
		cQuery += "   AND VE6_LOTECT = '" + VO3->VO3_LOTECT + "'"
		cQuery += "   AND VE6_NUMLOT = '" + VO3->VO3_NUMLOT + "'"
		cQuery += " ORDER BY VE6_DATREG DESC,VE6_HORREG DESC"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TEMPVE6DEV" , .T., .T. )
		While !TEMPVE6DEV->(Eof()) .and. nSaldoBx < VO3->VO3_QTDREQ

			dbSelectArea("VE6")
			VE6->(dbGoTo(TEMPVE6DEV->NUMREG))

			nSaldoAux := (VE6->VE6_QTDATE - VE6->VE6_QTDDEV)

			IF nSaldoAux + nSaldoBx > VO3->VO3_QTDREQ
				nSaldoAux := VO3->VO3_QTDREQ - nSaldoBx
			ENDIF

			RecLock("VE6" ,.F. ,.T.)
			VE6->VE6_QTDDEV += nSaldoAux
			// Devolucao dos itens que tinham sido requisitados
			IF VE6->VE6_QTDDEV == VE6->VE6_QTDATE
				VE6->VE6_DATATE := CtoD(" ")
			ENDIF
			MsUnLock()

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza saldo ja devolvidoณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nSaldoBx += nSaldoAux

			TEMPVE6DEV->(dbSkip())

		End
		TEMPVE6DEV->(dbCloseArea())

	EndIf

	RestArea( aArea )

Return .t.

/*/{Protheus.doc} OM020VSJBAIXA
Baixa registro VSJ no momento da requisicao de peca
@author Rubens
@since 05/09/2016
@version undefined

@type function
/*/
Static Function OM020VSJBAIXA()

	Local nI
	Local nPosOrc

	If cReqDev <> "1"
		Return .t.
	EndIf

	// So processa quando existir a matriz aPecaOrc e existir registro na aCols
	If !(Type("aPecaOrc") # "U" .and. Len(aCols) # 0)
		Return .t.
	EndIf

	For nI := 1 to Len(aPecaOrc)

		If !aPecaOrc[ni,1]
			Loop
		EndIf

		nPosOrc := FS_POSACOLS(nI, .t.)
		IF nPosOrc == 0
			If lCtrlLote .AND. Empty(aPecaOrc[nI,PECAORC_LOTECT]) .and. Rastro(aPecaOrc[nI,PECAORC_B1COD])
				nPosOrc := FS_POSACOLS(nI, .t., .f.)
			EndIf
			IF nPosOrc == 0
				Loop
			EndIf
		EndIf

		DbSelectArea("VSJ")
		dbGoTo(aPecaOrc[ni,18])

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณPL 31 - Shark - Rubens - 06/10/2009           ณ
		//ณSe tiver reserva, marcar a mesma como atendidaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		IF VSJ->VSJ_RESPEC == "1"
			OM020VE6BAIXA("REQUISICAO",nPosOrc)
		EndIf

		RecLock("VSJ",.F.,.T.)
		If lVSJCODIGO .and. !Empty(VSJ->VSJ_CODIGO)
			VSJ->VSJ_QTDREQ += aCols[nPosOrc,FG_POSVAR("VO3_QTDREQ")]
		EndIf
		IF aCols[nPosOrc,FG_POSVAR("VO3_QTDREQ")] <= VSJ->VSJ_QTDITE
			VSJ->VSJ_QTDITE -= aCols[nPosOrc,FG_POSVAR("VO3_QTDREQ")]
		Else
			VSJ->VSJ_QTDITE := 0
		EndIf
		If VSJ->VSJ_QTDITE <= 0 .and. (!lVSJCODIGO .or. (lVSJCODIGO .and. Empty(VSJ->VSJ_CODIGO)))
			dbdelete()
		EndIf
		MsUnLock()

	Next

Return .t.

/*/{Protheus.doc} OM020LOCACAO
Retorna o Endereco para utilizar como Locacao
@author Rubens
@since 05/09/2016
@version undefined
@param cCodSB1, characters, Codigo do produto (B1_COD)
@type function
/*/
Static Function OM020LOCACAO(cCodSB1)
	SB5->(dbSetOrder(1))
	SB5->(dbSeek(xFilial("SB5")+cCodSB1))
Return FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")


/*/{Protheus.doc} OM020001_CancNFRetRem
Cancelamento de Retorno de Remessa para atendimento externo
@author Rubens
@since 28/07/2017
@version undefined
@param cAlias, characters, descricao
@param nReg, numeric, descricao
@param nOpc, numeric, descricao
@type function
/*/
Function OM020001_CancNFRetRem(cAlias,nReg,nOpc)

	Private oDlg020CancNF
	Private oLBoxNFEnt
	Private oOk := LoadBitmap( GetResources(), "LBTIK" )
	Private oNo := LoadBitmap( GetResources(), "LBNO" )

	OM020002_TelaNFRetRem()

	If Len(oLBoxNFEnt:aArray) == 0
		MsgInfo(STR0266,STR0075) //  "Nใo existe nota fiscal de retorno de remessa para esta ordem de servi็o." / Aten็ใo
		Return
	EndIf

	ACTIVATE MSDIALOG oDlg020CancNF ON INIT EnchoiceBar(oDlg020CancNF,{ || IIf( OM020005_ProcCancNFEnt() , oDlg020CancNF:End() , ) }, { || oDlg020CancNF:End() },,)

Return

/*/{Protheus.doc} OM020005_ProcCancNFEnt
Processa o cancelamento da nota fiscal de retorno de remessa para atendimento externo
@author Rubens
@since 28/07/2017
@version undefined

@type function
/*/
Static Function OM020005_ProcCancNFEnt()

	Local nLinSel
	Local cAliasVDR := "TEMPVDR"

	nLinSel := aScan( oLBoxNFEnt:aArray , { |x| x[1] == .t. } )
	If nLinSel == 0
		MsgStop( STR0254 , STR0075 ) // "Selecione uma nota fiscal para cancelamento." / Aten็ใo
		Return .f.
	EndIf

	If ! MsgNoYes(STR0255,STR0075) // "Confirma cancelamento da Nota Fiscal de Retorno ?" / Aten็ใo
		Return .f.
	EndIf

	Begin Transaction

		cSerie   := oLBoxNFEnt:aArray[nLinSel, 2]
		cNota    := oLBoxNFEnt:aArray[nLinSel, 3]
		cFornece := oLBoxNFEnt:aArray[nLinSel, 5]
		cLojaFor := oLBoxNFEnt:aArray[nLinSel, 6]

		If OM020006_NaoPodeCanc(cSerie, cNota, cFornece, cLojaFor)
			MsgInfo(STR0281,STR0075) //Para efetuar o cancelamento da nota fiscal de retorno de remessa externa ้ necessแrio que as requisi็๕es dos itens nใo utilizados seja concluํda / Aten็ใo
			MsUnlockAll()
			DisarmTransaction()
			Return .f.
		Endif

		If !OM020004_CancNFEntrada(cSerie, cNota, cFornece, cLojaFor)
			MsUnlockAll()
			DisarmTransaction()
			Return .f.
		EndIf

		cSQL := "SELECT R_E_C_N_O_ VDRRECNO"
		cSQL +=  " FROM " + RetSQLName("VDR") + " VDR "
		cSQL += " WHERE VDR.VDR_FILIAL = '" + xFilial("VDR") + "'"
		cSQL +=   " AND VDR.VDR_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
		cSQL +=   " AND VDR.VDR_NFENUM = '" + cNota + "'"
		cSQL +=   " AND VDR.VDR_NFESER = '" + cSerie + "'"
		cSQL +=   " AND VDR.VDR_CLIENT = '" + cFornece + "'"
		cSQL +=   " AND VDR.VDR_LOJA   = '" + cLojaFor + "'"
		cSQL +=   " AND VDR.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cAliasVDR, .T., .T. )
		While !(cAliasVDR)->(Eof())
			VDR->(dbGoTo( (cAliasVDR)->VDRRECNO))
			RecLock("VDR",.F.)
			VDR->VDR_NFESER := ""
			VDR->VDR_NFENUM := ""
			VDR->VDR_NEEEMI := CtoD(" ")
			VDR->VDR_NFEITE := ""
			VDR->VDR_QTDUTI := 0
			VDR->(MsUnLock())

			(cAliasVDR)->(dbSkip())
		End
		(cAliasVDR)->(dbCloseArea())
		dbSelectArea("VDR")
		//

	End Transaction
	MsUnlockAll()

	MsgInfo(STR0256,STR0075) // "Nota Fiscal cancelada." / Aten็ใo

Return .t.

/*/{Protheus.doc} OM020006_NaoPodeCanc
Verifica se ้ possํvel cancelar a nota fiscal de retorno de remessa para atendimento externo
@author Rubens
@since 28/07/2017
@version undefined
@param cSerie, characters, descricao
@param cNota, characters, descricao
@param cFornece, characters, descricao
@param cLojaFor, characters, descricao
@type function
/*/
Static Function OM020006_NaoPodeCanc(cSerie, cNota, cFornece, cLojaFor)

	Local cSQL
	Local cAliasVDR := "TEMPVDR"
	Local aPesqPeca
	Local nSaldoReq := 0
	Local lRetorno := .f.
	
	
	Local aItensReq := {}

	SB1->(dbSetOrder(7))

	cSQL := "SELECT VDR_TIPTEM, VDR_GRUITE, VDR_CODITE, VDR_QTDREM, VDR_QTDUTI, "
	cSQL +=       " VDR_VALUNI, VDR_OPER, VDR_CODTES, VDR_CLIENT, VDR_LOJA "
	cSQL += " FROM " + RetSQLName("VDR") + " VDR "
	cSQL += " WHERE VDR.VDR_FILIAL = '" + xFilial("VDR") + "'"
	cSQL +=   " AND VDR.VDR_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
	cSQL +=   " AND VDR.VDR_QTDREM <> VDR.VDR_QTDUTI"
	cSQL +=   " AND VDR.VDR_NFENUM = '" + cNota + "'"
	cSQL +=   " AND VDR.VDR_NFESER = '" + cSerie + "'"
	cSQL +=   " AND VDR.VDR_CLIENT = '" + cFornece + "'"
	cSQL +=   " AND VDR.VDR_LOJA   = '" + cLojaFor + "'"
	cSQL +=   " AND VDR.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cAliasVDR, .T., .T. )
	While !(cAliasVDR)->(Eof())

			aAdd(aItensReq,{VO1->VO1_NUMOSV,;
							(cAliasVDR)->VDR_TIPTEM,;
							(cAliasVDR)->VDR_GRUITE,;
							(cAliasVDR)->VDR_CODITE,;
							(cAliasVDR)->VDR_QTDREM-(cAliasVDR)->VDR_QTDUTI,;
							(cAliasVDR)->VDR_VALUNI,;
							(cAliasVDR)->VDR_OPER,;
							(cAliasVDR)->VDR_CODTES,;
							Space(TamSX3("VO3_PROREQ")[1])})

		(cAliasVDR)->(dbSkip())
	End
	(cAliasVDR)->(dbCloseArea())
	dbSelectarea("VDR")

	aPesqPeca := FMX_CALPEC(;
		VO1->VO1_NUMOSV,; // cNumOS
		,; // cTipTem
		,; // cGruIte
		,; // cCodIte
		.f. ,; // lMov
		.f. ,; // lNegoc
		.f. ,; // lReqZerada
		.t. ,; // lRetAbe
		.f. ,; // lRetLib
		.f. ,; // lRetFec
		.t. ,; // lRetCan
		,; // cLibVOO
		,; // cFiltroSQL
		.f.,; // lRetRem
		.f.) // lAgrInc

	cSQL := "SELECT VDR_TIPTEM, VDR_CODTES, VDR_GRUITE, VDR_CODITE"
	cSQL +=     " , VDR_QTDREM, VDR_NFEITE , VDR_VALUNI, VDR_OPER"
	cSQL +=     " , ( SELECT SUM(VDRSALDO.VDR_QTDREM)
	cSQL +=           " FROM " + RetSQLName("VDR") + " VDRSALDO "
	cSQL +=          " WHERE VDRSALDO.VDR_FILIAL = VDR.VDR_FILIAL "
	cSQL +=            " AND VDRSALDO.VDR_NUMOSV = VDR.VDR_NUMOSV "
	cSQL +=            " AND VDRSALDO.VDR_TIPTEM = VDR.VDR_TIPTEM "
	cSQL +=            " AND VDRSALDO.VDR_GRUITE = VDR.VDR_GRUITE "
	cSQL +=            " AND VDRSALDO.VDR_CODITE = VDR.VDR_CODITE "
	cSQL +=            " AND VDRSALDO.VDR_NFSNUM <> VDR.VDR_NFSNUM "
	cSQL +=            " AND VDRSALDO.VDR_NFENUM = '         ' "
	cSQL +=            " AND VDRSALDO.D_E_L_E_T_ = ' ' "
	cSQL +=          " ) SALDOREM "
	cSQL +=  " FROM " + RetSQLName("VDR") + " VDR "
	cSQL += " WHERE VDR.VDR_FILIAL = '" + xFilial("VDR") + "'"
	cSQL +=   " AND VDR.VDR_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
	cSQL +=   " AND VDR.VDR_NFENUM = '" + cNota + "'"
	cSQL +=   " AND VDR.VDR_NFESER = '" + cSerie + "'"
	cSQL +=   " AND VDR.VDR_CLIENT = '" + cFornece + "'"
	cSQL +=   " AND VDR.VDR_LOJA   = '" + cLojaFor + "'"
	cSQL +=   " AND VDR.VDR_QTDREM = VDR.VDR_QTDUTI"
	cSQL +=   " AND VDR.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cAliasVDR, .T., .T. )
	While !(cAliasVDR)->(Eof())

		nSaldoReq := 0
		aEval( aPesqPeca , { |x| ;
			IIF( x[PECA_TIPTEM] == (cAliasVDR)->VDR_TIPTEM .and. ;
				 x[PECA_GRUITE] == (cAliasVDR)->VDR_GRUITE .and. ;
				 x[PECA_CODITE] == (cAliasVDR)->VDR_CODITE ;
				 , ;
				 nSaldoReq += x[PECA_QTDREQ] ;
				 ,) })

		If (cAliasVDR)->VDR_QTDREM > ( nSaldoReq - (cAliasVDR)->SALDOREM )

			aAdd(aItensReq,{VO1->VO1_NUMOSV,;
							(cAliasVDR)->VDR_TIPTEM,;
							(cAliasVDR)->VDR_GRUITE,;
							(cAliasVDR)->VDR_CODITE,;
							(cAliasVDR)->VDR_QTDREM - ( nSaldoReq - (cAliasVDR)->SALDOREM ),;
							(cAliasVDR)->VDR_VALUNI,;
							(cAliasVDR)->VDR_OPER,;
							(cAliasVDR)->VDR_CODTES,;
							Space(TamSX3("VO3_PROREQ")[1])})

		EndIf

		(cAliasVDR)->(dbSkip())
	End
	(cAliasVDR)->(dbCloseArea())
	dbSelectarea("VDR")

	If Len(aItensReq) > 0 .and. !OM0200015_TelaReqPecaNaoUtilizada(aItensReq)
		lRetorno := .t.
	Endif

Return lRetorno

/*/{Protheus.doc} OM020002_TelaNFRetRem
Monta tela para selecionar a nota fiscal de retorno de remessa para atendimento externo
@author Rubens
@since 28/07/2017
@version undefined

@type function
/*/
Static Function OM020002_TelaNFRetRem()

	
	
	Local oInterfHelper := DMS_InterfaceHelper():New()

	oInterfHelper:nOpc := 3

	oDlg020CancNF := oInterfHelper:CreateDialog(STR0261) // "Cancelamento de Retorno de Remessa"

	oInterfHelper:SetOwnerPvt("OM020001_CancNFRetRem")
	oInterfHelper:SetDefSize(oDlg020CancNF)
	oInterfHelper:AddColLBox( { { "SELECAO" , .t. } , { "SELECAO_UNICO" , .t. } } )
	oInterfHelper:AddColLBox( { { "X3" , "VDR_NFESER" } } )
	oInterfHelper:AddColLBox( { { "X3" , "VDR_NFENUM" } } )
	oInterfHelper:AddColLBox( { { "X3" , "VDR_NEEEMI" } } )
	oInterfHelper:AddColLBox( { { "X3" , "VDR_CLIENT" } } )
	oInterfHelper:AddColLBox( { { "X3" , "VDR_LOJA" } } )
	oInterfHelper:AddColLBox( { { "X3" , "A1_NOME" } } )

	oLBoxNFEnt := oInterfHelper:CreateLBox("oLBoxNFEnt",{{"ALINHAMENTO",CONTROL_ALIGN_ALLCLIENT}})
	oLBoxNFEnt:SetArray( OM020003_DadosNFRet() )
	oLBoxNFEnt:Refresh()

Return

/*/{Protheus.doc} OM020003_DadosNFRet
Levanta notas fiscais de remessa com retorno
@author Rubens
@since 28/07/2017
@version undefined

@type function
/*/
Static Function OM020003_DadosNFRet()

	Local aNFRem := {}
	Local cAliasVDR := "TEMPNFRET"

	cSQL := "SELECT DISTINCT VDR_NEEEMI, VDR_NFENUM, VDR_NFESER, VDR_CLIENT, VDR_LOJA, A1_NOME"
	cSQL +=  " FROM " + RetSQLName("VDR") + " VDR "
	cSQL +=         " JOIN " + RetSQLName("SA1") + " A1 "
	cSQL +=                "  ON A1.A1_FILIAL = '" + xFilial("SA1") + "'"
	cSQL +=                " AND A1.A1_COD  = VDR.VDR_CLIENT "
	cSQL +=                " AND A1.A1_LOJA = VDR.VDR_LOJA "
	cSQL +=                " AND A1.D_E_L_E_T_ = ' '"
	cSQL += " WHERE VDR_FILIAL = '" + xFilial("VDR") + "'"
	cSQL +=   " AND VDR_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
	cSQL +=   " AND VDR_NFENUM <> ' '" // Retorno de Remessa
	cSQL +=   " AND VDR.D_E_L_E_T_ = ' '"
	cSQL += " ORDER BY VDR_NEEEMI, VDR_NFENUM"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cAliasVDR, .T., .T. )
	While !(cAliasVDR)->(Eof())
		AADD( aNFRem , { .f. ,;
						(cAliasVDR)->VDR_NFESER, ;
						(cAliasVDR)->VDR_NFENUM, ;
						StoD((cAliasVDR)->VDR_NEEEMI), ;
						(cAliasVDR)->VDR_CLIENT, ;
						(cAliasVDR)->VDR_LOJA, ;
						(cAliasVDR)->A1_NOME } )
		(cAliasVDR)->(dbSkip())
	End
	(cAliasVDR)->(dbCloseArea())
	dbSelectArea("VDR")
	//

Return aNFRem


/*/{Protheus.doc} OM020004_CancNFEntrada
Cancela nota fiscal de retorno de remessa para atendimento externo
@author Rubens
@since 28/07/2017
@version undefined
@param cSerie, characters, descricao
@param cNota, characters, descricao
@param cFornece, characters, descricao
@param cLojaFor, characters, descricao
@type function
/*/
Static Function OM020004_CancNFEntrada(cSerie, cNota, cFornece, cLojaFor)

	Local aCabec := {}
	Local aLinha := {}
	Local aItens := {}

	dbSelectArea("SF1")
	dbSetOrder(1)
	If ! dbSeek(xFilial("SF1")+cNota+cSerie+cFornece+cLojaFor)
		Return .f.
	EndIf

	// Cabecalho da nota fiscal de entrada
	aadd(aCabec,{"F1_TIPO"   	,SF1->F1_TIPO})
	aadd(aCabec,{"F1_FORMUL" 	,SF1->F1_FORMUL})
	aadd(aCabec,{"F1_DOC"    	,SF1->F1_DOC})
	aadd(aCabec,{"F1_SERIE"  	,SF1->F1_SERIE})
	aadd(aCabec,{"F1_EMISSAO"	,SF1->F1_EMISSAO})
	aadd(aCabec,{"F1_FORNECE"	,SF1->F1_FORNECE})
	aadd(aCabec,{"F1_LOJA"   	,SF1->F1_LOJA})
	aadd(aCabec,{"F1_ESPECIE"	,SF1->F1_ESPECIE})
	aadd(aCabec,{"F1_COND"		,SF1->F1_COND})
	aadd(aCabec,{"F1_EST"		,SF1->F1_EST})
	// Itens da nota fiscal de entrada
	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	While !Eof() .And. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA

		aadd(aLinha,{"D1_ITEM"	,SD1->D1_ITEM,Nil})
		aadd(aLinha,{"D1_COD"	,SD1->D1_COD,Nil})
		aadd(aLinha,{"D1_QUANT"	,SD1->D1_QUANT,Nil})
		aadd(aLinha,{"D1_VUNIT"	,SD1->D1_VUNIT,Nil})
		aadd(aLinha,{"D1_TOTAL"	,SD1->D1_TOTAL,Nil})
		aadd(aLinha,{"D1_LOCAL"	,SD1->D1_LOCAL	,Nil})
		aadd(aLinha,{"D1_GRADE",SD1->D1_GRADE,Nil})
		aadd(aLinha,{"D1_ITEMGRD",SD1->D1_ITEMGRD,Nil})
		aadd(aLinha,{"D1_TES","",Nil})

		aadd(aItens,aLinha)

		dbSkip()
	Enddo

	If Len(aItens) > 0 .And. Len(aCabec) > 0
		lMsHelpAuto := .t.
		lMsErroAuto := .f.
		dbSelectArea("SF1")
		MSExecAuto( { |x,y,z| MATA103(x,y,z) }, aCabec,aItens,5 )
		If lMsErroAuto
			MostraErro()
			Return .f.
		EndIf
	EndIf

Return .t.




/*/{Protheus.doc} OM020007_MatrizDev
Retorna a matriz de Devolu็ใo que serแ utilizada na rotina de Devolu็ใo de Pe็as
@author Rubens
@since 16/11/2017
@version 1.0
@return ${return}, ${return_description}
@param cNumOsv, characters, descricao
@param cPTipTem, characters, descricao
@param cPGruIte, characters, descricao
@param cPCodIte, characters, descricao
@type function
/*/
Function OM020007_MatrizDev( cNumOsv , cPTipTem , cPGruIte , cPCodIte )

	Local cNome, cLoja, cCliente, nCont
	Local aInconv
	Local lCpoDesconto := VO3->(FieldPos("VO3_VALDES")) <> 0 .and. VO3->(FieldPos("VO3_PERDES")) <> 0 .and. VO3->(FieldPos("VO3_VALLIQ")) <> 0
	Local aIteDev:= {}
	
	Local cCondPesq := ""
	Local aRetDev := {}

	Default cPTipTem := ""
	Default cPGruIte := ""
	Default cPCodIte := ""

	DbSelectArea("VO2")
	DbSetOrder(1)
	DbSeek( xFilial("VO2")+ cNumOsv )

	Do While !Eof() .And. VO2->VO2_FILIAL == xFilial("VO2") .and. VO2->VO2_NUMOSV ==  cNumOsv

		//Validacao por Ponto de Entrada
		If ExistBlock("OM020QDV") // Valida็ใo na Devolu็ใo de Pe็as
			If !ExecBlock("OM020QDV",.f.,.f.)
				VO2->(dbSkip())
				Loop
			Endif
		Endif

		DbSelectArea("VO3")
		DbSetOrder(1)
		DbSeek(xFilial("VO3")+VO2->VO2_NOSNUM) // nosnum+grupo+codite
		Do While !Eof() .And. VO3->VO3_FILIAL == xFilial("VO3") .And. VO3->VO3_NOSNUM == VO2->VO2_NOSNUM

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ So exibe pecas que nao foram disponibilizadas, fechadas ou canceladas ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			if !Empty(VO3->VO3_DATFEC) .or. !Empty(VO3->VO3_DATDIS) .or. !Empty(VO3->VO3_DATCAN)
				VO3->(dbSkip())
				Loop
			endif
			//

			if !Empty(cPTipTem) .and. VO3->VO3_TIPTEM <> cPTipTem
				VO3->(dbSkip())
				Loop
			endif

			if !Empty(cPGruIte) .and. (VO3->VO3_GRUITE <> cPGruIte .or. VO3->VO3_CODITE <> cPCodIte)
				VO3->(dbSkip())
				Loop
			endif

			// Verifica se a peca ja esta na matriz de Requisicao / Devolucao (aIteDev)
			//cVOIVLPCAC := FM_SQL("SELECT VOI_VLPCAC FROM " + RetSQLName("VOI") + " WHERE VOI_FILIAL = '" + xFilial("VOI") + "' AND VOI_TIPTEM = '" + VO3->VO3_TIPTEM + "' AND D_E_L_E_T_ = ' '")
			VOI->(MsSeek( xFilial("VOI") + VO3->VO3_TIPTEM ))

			cCondPesq := " x[02] == VO3->VO3_TIPTEM " +;
				" .and. x[06] == VO3->VO3_GRUITE " +;
				" .and. x[07] == VO3->VO3_CODITE " +;
				" .and. x[17] == VO3->VO3_PROREQ " +;
				" .and. x[22] == VO3->VO3_CODTES " +;
				" .and. x[23] == VO3->VO3_LOTECT " +;
				" .and. x[24] == VO3->VO3_NUMLOT " +;
				" .and. x[12] == VO3->VO3_FORMUL "

			if lInconveniente
				cCondPesq += " .and. x[18] == VO3->VO3_SEQINC"
			endif

			if VOI->VOI_VLPCAC == "1" // Valor da Peca no fechamento ้ o Valor da Requisicao
				cCondPesq += " .and. x[11] == VO3->VO3_VALPEC"
				If lCpoDesconto
					If VO3->VO3_VALLIQ > 0
						cCondPesq += " .and. x[19] == VO3->VO3_VALLIQ"
					EndIf
					// Controla a utilizacao do VO3_VALDES por variavel logica,
					// pois neste campo esta contido o valor TOTAL de desconto e nao UNITARIO
					If VO3->VO3_VALDES <> 0
						cCondPesq += " .and. x[20]"
					Else
						cCondPesq += " .and. !x[20]"
					EndIf
				EndIf
			endif
			nPos := aScan(aIteDev, &( "{|x| " + cCondPesq + " }") )

			If nPos == 0

				SB1->(DbsetOrder(7))
				SB1->(Dbseek(xFilial("SB1")+VO3->VO3_GRUITE+VO3->VO3_CODITE))

				cCliente := VO3->VO3_FATPAR
				cLoja    := VO3->VO3_LOJA
				cNome := Left(FM_SQL("SELECT A1_NOME FROM " + RetSQLName("SA1") + " WHERE A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = '" + cCliente + "' AND A1_LOJA = '" + cLoja + "' AND D_E_L_E_T_ = ' '"), 19)

				aadd(aIteDev,{.f.,;
					VO3->VO3_TIPTEM,;	// 02 - Tipo de Tempo
					cCliente,;			// 03 - Cliente
					cLoja,;				// 04 - Loja
					cNome,;				// 05 - Nome
					VO3->VO3_GRUITE,;	// 06 - Grupo do Item
					VO3->VO3_CODITE,;	// 07 - Codigo do Item
					SB1->B1_DESC,;		// 08 - Descricao do Item
					0,;					// 09 - Quantidade Informada para devolucao
					0,;					// 10 - Qtde Requisitada
					VO3->VO3_VALPEC,;	// 11 - Valor das Pecas Requisitadas
					VO3->VO3_FORMUL,;	// 12 - Fomula
					{},;				// 13 - Utilizado para Montagem da aCols
					" ",;				// 14 - Grupo Inconveniente
					" ",;				// 15 - Codigo Inconveniente
					" ",;				// 16 - Descricao Inconveniente
					VO3->VO3_PROREQ,;	// 17 - Produtivo que Requisitou
					Space(TamSX3("VO3_SEQINC")[1]) ,; 				// 18 - Sequencia Inconveniente - VST
					iif( lCpoDesconto .and. VO3->VO3_VALLIQ > 0 , VO3->VO3_VALLIQ , 0 ) ,; 	// 19 - Valor da Peca Liquido
					iif( lCpoDesconto .and. VO3->VO3_VALDES <> 0, .t. , .f. ) ,; 			// 20 - Possui desconto ...
					0 ,; // 21 - Valor de Desconto, utilizar somente para exibir na tela ...
					VO3->VO3_CODTES,;	// 22 - Valor de Desconto, utilizar somente para exibir na tela ...
					VO3->VO3_LOTECT,; // 23 - Lote
					VO3->VO3_NUMLOT}) // 24 - Sub-Lote

				if lInconveniente .and. !Empty(VO3->VO3_SEQINC)
					aInconv := OM420CONSINC( "2" , VO2->VO2_NUMOSV , VO3->VO3_SEQINC )
					aIteDev[Len(aIteDev),14] := aInconv[1]
					aIteDev[Len(aIteDev),15] := aInconv[2]
					aIteDev[Len(aIteDev),16] := AllTrim(aInconv[3]) // Posicione("VST",1,xFilial("VSL")+"2"+VO3->VO3_NUMOSV+VO3->VO3_SEQINC,"VST_DESINC")
					aIteDev[Len(aIteDev),18] := VO3->VO3_SEQINC
				endif

				nPos := Len(aIteDev)

			Endif

			// Requisicao
			if VO2->VO2_TIPREQ == "P"
				If VO2->VO2_DEVOLU == "1"

					// Matriz de Recno ...
					AADD(aIteDev[nPos,13] , VO3->(Recno()) )

					aIteDev[nPos,10] += VO3->VO3_QTDREQ

					if ( lCpoDesconto .and. VO3->VO3_VALDES <> 0 )
						aIteDev[nPos,21] += VO3->VO3_VALDES
					EndIf

					// Devolucao
				Else
					aIteDev[nPos,10] -= VO3->VO3_QTDREQ
					if ( lCpoDesconto .and. VO3->VO3_VALDES <> 0 )
						aIteDev[nPos,21] -= VO3->VO3_VALDES
					EndIf

				EndIf
			Endif

			DbSelectArea("VO3")
			DbSkip()

		EndDo

		DbSelectArea("VO2")
		DbSkip()

	EndDo

	// Verifica se existe algum produto que pode ser devolvido ...
	For nCont := 1 to Len(aIteDev)
		If aIteDev[nCont,10] > 0 // Tem saldo de peca ...
			AADD( aRetDev, aClone( aIteDev[nCont] ) )
		Endif
	Next
	//

	ASort( aRetDev ,,,{|x,y| x[02]+x[06]+x[07]+x[17] < y[02]+y[06]+y[07]+y[17] })

Return aClone(aRetDev)

/*----------------------------------------------------
 Suavizar a nova verifica็ใo de integra็ใo com o WMS
------------------------------------------------------*/
Static Function a261IntWMS(cProduto)
Default cProduto := ""
	If FindFunction("IntWMS")
		Return IntWMS(cProduto)
	Else
		Return IntDL(cProduto)
	EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑบFuncao  ณ OM020PCAN บAutor  ณ Fernando Vitor Cavani บ Data ณ  26/04/18 บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Processa Cancelamento Nota Fiscal de Remessa               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM020PCAN(cSerie, cNota)
Local aRegSD2 := {}
Local aRegSE1 := {}
Local aRegSE2 := {}


Private lMsErroAuto := .f. //Se retornar .t. deu erro

If cNota == ""
	MsgInfo(STR0270 +                           ; // Nใo foi selecionada nota fiscal de remessa
		CHR(13) + CHR(10) + CHR(13) + CHR(10) + ;
		STR0271)                                  // Selecione a nota fiscal de remessa que deseja cancelar

	Return .f.
EndIf

BEGIN TRANSACTION

dbSelectArea("SF2")
dbSetOrder(1)
dbSeek(xFilial("SF2") + cNota + cSerie)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se o estorno do documento de saํda pode ser feito     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SD2")
dbSetOrder(3)
If DbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE)
	cNumPed := SD2->D2_PEDIDO
EndIf

//################################################################
//# VerIfica se o estorno do documento de saํda pode ser feito   #
//################################################################
If MaCanDelF2("SF2", SF2->(RecNo()), @aRegSD2, @aRegSE1, @aRegSE2)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Estorna o documento de saida                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	PERGUNTE("MTA521", .f.)
	SF2->(MaDelNFS(aRegSD2, aRegSE1, aRegSE2, (mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1)))
Else
	DisarmTransaction()
	Return .f.
EndIf

//
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cancelar PEDIDO                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//
lMsErroAuto := .f.

DbSelectArea("SC5")
DbSetOrder(1)
If DbSeek(xFilial("SC5") + cNumPed)
	aMata410Cab   := {{"C5_NUM", cNumPed, Nil}} //Numero do pedido SC5
	aMata410Itens := {{"C6_NUM", cNumPed, Nil}} //Numero do Pedido SC6

	//Exclui Pedido
	SC9->(dbSetOrder(1))
	SC9->(dbSeek(xFilial("SC9") + cNumPed))
	While !SC9->(Eof()) .And. xFilial("SC9") == SC9->C9_FILIAL .And. cNumPed == SC9->C9_PEDIDO
		SC9->(a460Estorna())
		SC9->(dbSkip())
	EndDo

	MSExecAuto({|x, y, z|Mata410(x, y, z)}, aMata410Cab, {aMata410Itens}, 5)
EndIf

If lMsErroAuto
	MostraErro()
	DisarmTransaction()
	Return .f.
EndIf

// Cancelando Remessa de Pe็as (VDR)
VDR->(dbSetOrder(2))
VDR->(dbSeek(xFilial("VDR") + cNumPed))
While !VDR->(Eof()) .And. xFilial("VDR") == VDR->VDR_FILIAL .And. cNumPed == VDR->VDR_PEDNUM
	If cSerie == VDR->VDR_NFSSER .And. cNota == VDR->VDR_NFSNUM
		RecLock("VDR", .F., .T.)
		dbdelete()
		MsUnlock()
	EndIf

	VDR->(dbSkip())
EndDo

END TRANSACTION

FMX_TELAINF("1", { { Alltrim(cSerie), Alltrim(cNota), STR0201 } }) // "CANCELADO"
Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑบFuncao ณ OM020TIKCAN บAutor ณ Fernando Vitor Cavani บ Data ณ  27/04/18 บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Marca/Desmarca Cancelamento Nota Fiscal de Remessa         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OM020TIKCAN(aNFRem, cSerie, cNota, nAuxPos)
	If aNFRem[nAuxPos,01]
		aNFRem[nAuxPos,01] := .f.

		cSerie := ""
		cNota  := ""
	Else
		aEval(aNFRem, { |x| x[01] := .f. })
		aNFRem[nAuxPos,01] := .t.

		cSerie := aNFRem[nAuxPos,2]
		cNota  := aNFRem[nAuxPos,3]
	EndIf
Return


/*/{Protheus.doc} OM020HRD
Fuin็ใo que faz a chamada da fun็ใo de Hist๓rico de Requisi็๕es e Devolu็๕es da OS
@author Manoel
@since 17/05/2018
@version 1.0
@return 
@param
@type function
/*/
Function OM020HRD()

OM020HistRD(VO1->VO1_FILIAL,VO1->VO1_NUMOSV)

Return

/*/{Protheus.doc} OM020HistRD
Hist๓rico de Requisi็๕es e Devolu็๕es da OS
@author Manoel
@since 17/05/2018
@version 1.0
@return 
@param cFilOsv, characters, descricao
@param cNumOsv, characters, descricao
@type function
/*/
Function OM020HistRD(cFilOsv, cNumOsv)


Local aObjects   := {} , aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local aReqDev    := {}

Default cFilOsv  := VO1->VO1_FILIAL
Default cNumOSv  := VO1->VO1_NUMOSV

aReqDev    := OM020ReqDev(cFilOsv,cNumOSv)

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // ListBox Total

aPos := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oHistReqDev FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0276+cNumOsv) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // "Hist๓rico de Requisi็๕es e Devolu็๕es - OS "

	oHistReqDev:lEscClose := .F.

	//Configura็๕es dos campos da tela 
	//{Descri็ใo,Tipo,Tamanho,Picture,Posi็ใo}
	aBrowse := {}
	aADD(aBrowse, {RetTitle("VO2_NOSNUM"),"C", 08,"",1}) 
	aADD(aBrowse, {RetTitle("VO2_DATREQ"),"D", 08,"",2}) 
	aADD(aBrowse, {RetTitle("VO2_NUMOSV"),"C", 08,"",3}) 
	aADD(aBrowse, {RetTitle("VO2_TIPREQ"),"C", 10,"",4}) 
	aADD(aBrowse, {RetTitle("VO3_GRUITE"),"C", 04,"",5}) 
	aADD(aBrowse, {RetTitle("VO3_CODITE"),"C", 27,"",6}) 
	aADD(aBrowse, {RetTitle("VO3_DESITE"),"C", 30,"",7}) 
	aADD(aBrowse, {RetTitle("VO3_QTDREQ"),"N", 10,"",8}) 
	aADD(aBrowse, {RetTitle("VO3_PROREQ"),"C", 20,"",9}) 
	

	oBrowseReqDev := FWBrowse():New()
	oBrowseReqDev:SetOwner(oHistReqDev)
	oBrowseReqDev:SetDataArray()
	oBrowseReqDev:SetColumns(MontCol("oBrowseReqDev",aBrowse,""))
	oBrowseReqDev:SetArray(aReqDev)
	oBrowseReqDev:Activate() // Ativa็ใo do Browse
	oBrowseReqDev:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrowseReqDev:Refresh()
	oBrowseReqDev:GoTop()

ACTIVATE MSDIALOG oHistReqDev ON INIT EnchoiceBar(oHistReqDev,{ || oHistReqDev:End() }, { || oHistReqDev:End() })
	
Return

Static Function OM020ReqDev(cFilOs, cNumOs)

Local aVetorLev := {}
Local cQAlVO3   := "SQLVO3" // VO3

cQuery := "SELECT VO2.VO2_NOSNUM, VO2.VO2_DATREQ, VO2.VO2_DEVOLU, VO3.VO3_GRUITE, VO3.VO3_CODITE, VO3.VO3_QTDREQ, SB1.B1_DESC, VAI.VAI_NOMTEC FROM "+RetSqlName("VO3")+" VO3 "
cQuery += "INNER JOIN "+RetSqlName("VO2")+" VO2 ON (VO2.VO2_FILIAL='"+xFilial("VO2")+"' AND VO2.VO2_NOSNUM=VO3.VO3_NOSNUM AND VO2.D_E_L_E_T_=' ' ) "
cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON (SB1.B1_FILIAL ='"+xFilial("SB1")+"' AND SB1.B1_COD=VO3.VO3_PECINT AND SB1.D_E_L_E_T_=' ' ) "
cQuery += "INNER JOIN "+RetSqlName("VAI")+" VAI ON (VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODTEC=VO3.VO3_PROREQ AND VAI.D_E_L_E_T_=' ' ) "
cQuery += "WHERE VO2.VO2_DEVOLU <>' ' AND VO3.VO3_FILIAL = '"+cFilOs+"' AND VO3.VO3_NUMOSV = '"+cNumOs+"'  AND VO3.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVO3 , .F., .T. )
While !( cQAlVO3 )->( Eof() )
	aadd(avetorLev,{( cQAlVO3 )->VO2_NOSNUM, ( cQAlVO3 )->VO2_DATREQ, cNumOs, ;
	                  IIf( ( cQAlVO3 )->VO2_DEVOLU == "1", "Requisi็ใo", "Devolu็ใo"), ( cQAlVO3 )->VO3_GRUITE,;
                    ( cQAlVO3 )->VO3_CODITE, ( cQAlVO3 )->B1_DESC , ( cQAlVO3 )->VO3_QTDREQ, ( cQAlVO3 )->VAI_NOMTEC})
	 ( cQAlVO3 )->( DbSkip() )
EndDo
( cQAlVO3 )->( dbCloseArea() )

Return aVetorLev

Static Function MontCol(cNomBrw,aHeader,cNomCol1)

	Local aColunas, oColuna
	Local cSetData
	Local nHeader := 0

	Default aHeader := {}
	Default cNomBrw := ""
	Default cNomCol1   := ""

	aColunas := {}

	For nHeader := 1 To Len(aHeader)
		// Instancia a Classe
		oColuna := FWBrwColumn():New()

		// Defini็๕es Bแsicas do Objeto
		oColuna:SetAlign(If(aHeader[nHeader][2] == "N", CONTROL_ALIGN_RIGHT, If(aHeader[nHeader][2] == "X", CONTROL_ALIGN_NONE, CONTROL_ALIGN_LEFT)))
		oColuna:SetEdit(.F.)

		// Defini็๕es do Dado apresentado
		oColuna:SetSize(aHeader[nHeader][3])
		oColuna:SetTitle( aHeader[nHeader][1]  )
		oColuna:SetType(aHeader[nHeader][2])
		oColuna:SetPicture(aHeader[nHeader][4])

		cSetData := "{|| "+cNomBrw+":Data():GetArray()["+cNomBrw+":AT()][" + cValToChar(aHeader[nHeader][5]) + "] }"
		oColuna:SetData(&(cSetData))

		aAdd(aColunas, oColuna)
	Next nHeader
Return aColunas

/*/{Protheus.doc} OM0200015_TelaReqPecaNaoUtilizada
Tela de Requisi็ใo de pe็as nใo utilizadas no retorno de remessa para atendimento externo
@author Renato Vinicius
@since 28/08/2018
@version 1.0
@return lRetReq, l๓gico
@param aItensReq, array, vetor dos itens que nใo foram utilizados na nf de retorno de remessa
@type function
/*/

Static Function OM0200015_TelaReqPecaNaoUtilizada(aItensReq)

Local aCamposPec := {}
Local nCont := 0
Local aAlter := {}
Local aAuxLinha := {}
Local lRetReq := .t.

Default aItensReq := {}

aCols := {}
aHeaderPeca:= {}

AADD( aCamposPec , "VO3_TIPTEM" )
AADD( aCamposPec , "VO3_GRUITE" )
AADD( aCamposPec , "VO3_CODITE" )
AADD( aCamposPec , "VO3_QTDREQ" )
AADD( aCamposPec , "VO3_VALPEC" )
AADD( aCamposPec , "VO3_OPER"   )
AADD( aCamposPec , "VO3_CODTES" )
AADD( aCamposPec , "VO3_PROREQ" )

SX3->(dbSetOrder(2))
For nCont := 1 to Len(aCamposPec)

	SX3->(dbSeek(aCamposPec[nCont]))
	AADD( aHeaderPeca , { AllTrim(X3Titulo()),;
					SX3->X3_CAMPO ,;
					SX3->X3_PICTURE,;
					SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,;
					"AllWaysTrue()",;
					X3_USADO_EMUSO ,;
					SX3->X3_TIPO,;
					SX3->X3_F3,;
					"R",;
					"",;
					"" })
	If aCamposPec[nCont] $ "VO3_PROREQ"
		AADD(aAlter,SX3->X3_CAMPO)
	EndIf

	wVar := "M->"+aCamposPec[nCont]
	&wVar := CriaVar(SX3->X3_CAMPO,.f.)

Next nCont

aAuxLinha := Array(Len(aHeaderPeca)+1)
For nCont := 1 to Len(aHeaderPeca)
	aAuxLinha[nCont] := &("M->"+aHeaderPeca[nCont,2])
Next nCont
aAuxLinha[Len(aAuxLinha)] := .f.

For nCont := 1 to Len(aItensReq)
	AADD(aCols,aClone(aAuxLinha))
	nAuxPos := Len(aCols)

	aCols[nAuxPos,FG_POSVAR("VO3_TIPTEM","aHeaderPeca")] := aItensReq[nCont,02]
	aCols[nAuxPos,FG_POSVAR("VO3_GRUITE","aHeaderPeca")] := aItensReq[nCont,03]
	aCols[nAuxPos,FG_POSVAR("VO3_CODITE","aHeaderPeca")] := aItensReq[nCont,04]
	aCols[nAuxPos,FG_POSVAR("VO3_QTDREQ","aHeaderPeca")] := aItensReq[nCont,05]
	aCols[nAuxPos,FG_POSVAR("VO3_VALPEC","aHeaderPeca")] := aItensReq[nCont,06]
	aCols[nAuxPos,FG_POSVAR("VO3_OPER"  ,"aHeaderPeca")] := aItensReq[nCont,07]
	aCols[nAuxPos,FG_POSVAR("VO3_CODTES","aHeaderPeca")] := aItensReq[nCont,08]
	aCols[nAuxPos,FG_POSVAR("VO3_PROREQ","aHeaderPeca")] := aItensReq[nCont,09]

Next

aSize    := MsAdvSize( .F. ) 
	
aObjects := {}
	
aAdd( aObjects, { 100, 100, .t., .t., .t. } )
aAdd( aObjects, { 140,  66, .F., .T. } )
	
aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj1 := MsObjSize( aInfo, aObjects,  , .T. ) 

DEFINE MSDIALOG oDlgCRemRet TITLE STR0282 OF oMainWnd PIXEL;
	FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL // "Atualizar O.S."

	// Adiciona linha em branco na aCols
	If Len(aCols) == 0
		AADD(aCols,aClone(aAuxLinha))
		For nCont := 1 to Len(aHeaderPeca)
			wVar  := "M->"+aHeaderPeca[nCont,2]
			aCols[1,nCont] := &wVar
		Next nCont
		aCols[1,Len(aCols[1])] := .f.
	EndIf
	//

	cLinOk   := "AllwaysTrue()"
	cTudoOk  := "AllwaysTrue()"
	cFieldOk := "AllwaysTrue()"
	
	lTemPeca := .t.
	
	oPanelReq	:= TPanel():New(00,00,STR0282,oDlgCRemRet,,,,,,0,14)
	oPanelReq:Align := CONTROL_ALIGN_ALLCLIENT

	oGetPecReq := MsNewGetDados():New( 01,01,80,200,;
			GD_UPDATE,; // Operacao - 2 Visualizar / 3 Incluir / 4 Alterar / 5 Excluir
			cLinOk,;
			cTudoOk,;
			,;		// Nome dos campos do tipo caracter que utilizacao incremento automatico
			aAlter ,; 	// Campos alteraveis da GetDados
			/*nFreeze*/,;	// Campos estaticos da GetDados
			999,;
			cFieldOk,;
			/*cSuperDel*/,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
			,; 		// Funcao executada para validar a exclusao de uma linha
			oPanelReq,;
			aHeaderPeca,;
			aCols)

	oGetPecReq:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlgCRemRet ON INIT EnchoiceBar(oDlgCRemRet,{ || lRetReq := OM0200025_ReqPecaNaoUtilizada(aCols,aItensReq),oDlgCRemRet:End() },{|| lRetReq := .f., oDlgCRemRet:End()})

Return lRetReq

/*/{Protheus.doc} OM0200025_ReqPecaNaoUtilizada
Aplica็ใo da requisi็ใo dos itens que nใo foram utilizados na nf de retorno de remessa
@author Renato Vinicius
@since 28/08/2018
@version 1.0
@return l๓gico
@param aCols, array, Vetor contendo as informa็๕es preenchidas em tela
@param aAuxGrv, array, Vetor contendo os itens que nใo foram utilizados na nf de retorno de remessa
@type function
/*/

Static Function OM0200025_ReqPecaNaoUtilizada(aCols,aAuxGrv)

Local nCont := 0
Local aVO3Item := {}

Default aCols   := {}
Default aAuxGrv := {}

VAI->(DbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID))
VAI->(DbSetOrder(1))

For nCont := 1 to Len(aCols)
	
	cCodCliReq := ""
	cLojCliReq := ""
	cNomCliReq := ""
	FG_TIPTPFAT(oGetPecReq:aCols[nCont,FG_POSVAR("VO3_TIPTEM","aHeaderPeca")],;
				"cCodCliReq",;
				"cLojCliReq",;
				"cNomCliReq",;
				VO1->VO1_CODMAR,;
				"P",;
				aAuxGrv[nCont,1],;
				.f.,;
				.f.,;
				.f.)

	aAuxVO3 := {}
	AADD(aAuxVO3, { "VO3_NUMOSV" , aAuxGrv[nCont,1] 									, nil } )
	AADD(aAuxVO3, { "VO3_TIPTEM" , oGetPecReq:aCols[nCont,FG_POSVAR("VO3_TIPTEM","aHeaderPeca")]	, nil } )
	AADD(aAuxVO3, { "VO3_FATPAR" , cCodCliReq											, nil } )
	AADD(aAuxVO3, { "VO3_LOJA"   , cLojCliReq											, nil } )
	AADD(aAuxVO3, { "VO3_GRUITE" , oGetPecReq:aCols[nCont,FG_POSVAR("VO3_GRUITE","aHeaderPeca")]	, nil } )
	AADD(aAuxVO3, { "VO3_CODITE" , oGetPecReq:aCols[nCont,FG_POSVAR("VO3_CODITE","aHeaderPeca")]	, nil } )
	AADD(aAuxVO3, { "VO3_QTDREQ" , oGetPecReq:aCols[nCont,FG_POSVAR("VO3_QTDREQ","aHeaderPeca")]	, nil } )

	If !Empty(oGetPecReq:aCols[nCont,FG_POSVAR("VO3_PROREQ","aHeaderPeca")])
		AADD(aAuxVO3, { "VO3_PROREQ" , oGetPecReq:aCols[nCont,FG_POSVAR("VO3_PROREQ","aHeaderPeca")], nil } )
	Else
		If VAI->VAI_FUNPRO=="1"
			AADD(aAuxVO3, { "VO3_PROREQ" , VAI->VAI_CODTEC , nil } )
		EndIf
	EndIf

	// Operacao
	If !Empty(oGetPecReq:aCols[nCont,FG_POSVAR("VO3_OPER","aHeaderPeca")])
		AADD(aAuxVO3, { "VO3_OPER" , oGetPecReq:aCols[nCont,FG_POSVAR("VO3_OPER","aHeaderPeca")] , nil } )
	EndIf

	// TES
	If !Empty(oGetPecReq:aCols[nCont,FG_POSVAR("VO3_CODTES","aHeaderPeca")])
		AADD(aAuxVO3, { "VO3_CODTES" , oGetPecReq:aCols[nCont,FG_POSVAR("VO3_CODTES","aHeaderPeca")] , nil } )
	EndIf

	AADD( aVO3Item , aClone( aAuxVO3 ) )
Next

If Len(aVO3Item) > 0
	lMSHelpAuto := .t.
	lMsErroAuto := .f.
	MSExecAuto({|x,y,z| OFIOM020(,,x,y,z)},aVO3Item,2 /* Requisi็ใo */ )
	if lMsErroAuto
		DisarmTransaction()
		RollbackSx8()
		MsUnlockAll()
		MostraErro()
		Return .f.
	Endif
	lMSHelpAuto := .f.
EndIf

Return .t.

/*/{Protheus.doc} OM0200032_VldTesRemManutExt
Valida Tes utilizado na Remessa para Manuten็ใo Externa
@author Manoel Filho
@since 26/11/2018
@version 1.0
@return l๓gico
@param cCodTES - TES da Remessa , cTipMovto - Tipo de Movimento (REM - Remessa / RET - Retorno da Remessa)
@type function
/*/
Function OM0200032_VldTesRemManutExt(cCodTES,cTipMovto,lChecaOper)
Local lRet := .t.
Local cSQL_1 := "SELECT F4_TESDV  FROM " + RetSQLName("SF4") + " SF4 WHERE SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4.F4_CODIGO = '" + cCodTES + "' AND SF4.D_E_L_E_T_ = ' ' "
Local cSQL_2 := "SELECT (SELECT F42.F4_DUPLIC FROM " + RetSQLName("SF4") + " F42 WHERE F42.F4_FILIAL = '"+xFilial("SF4")+"' AND F42.F4_CODIGO = SF4.F4_TESDV AND F42.D_E_L_E_T_ = ' ' ) AS F4DUP FROM " + RetSQLName("SF4") + " SF4 WHERE SF4.F4_FILIAL = '"+xFilial("SF4")+"' AND SF4.F4_CODIGO = '" + cCodTES + "' AND SF4.D_E_L_E_T_ = ' '"

Default lChecaOper := .f.

If lChecaOper .and. !Empty(MV_PAR01)
	Return .t.
EndIf

If Empty(FM_SQL(cSQL_1)) // O campo F4_TESDV do TES de Remessa estแ em BRANCO
	If cTipMovto == "REM" // Remessa
		MsgInfo(STR0185 + " " + cCodTes +  CHR(13) + CHR(10) + Subs(STR0192,3))
	Else // RET - Retorno de Remessa
		MsgInfo(STR0191 + cCodTes + STR0192)
	Endif
	lRet := .f.
Else
	If FM_SQL(cSQL_2) == "S" // O campo F4_DUPLIC do TES de Retorno de Remessa estแ para EMITIR DUPLICATA (nใo pode)
		MsgInfo(STR0283)
		lRet := .f.
	Endif
Endif

Return lRet

/*/{Protheus.doc} OM0200045_ChecaCredGar
Fun็ใo que valida se deve verificar limite de credito ao Atualizar OS de garantia
@author Renato Vinicius
@since 12/12/2018
@version 1.0
@return l๓gico
@param
@type function
/*/

Function OM0200045_ChecaCredGar()

Local lRet := .t.
Local cCodMarVV1 := ""

If cMVMIL0006 == "JD " .and. OFNJD15011
	cCodMarVV1 := OFNJD15011_RetornaMarca(VO1->VO1_CODMAR)
Else
	cCodMarVV1 := FMX_RETMAR(cMVMIL0006)
EndIf

if Alltrim(cCodMarVV1) $ "JD/GRS"

	If IsInCallStack("OFNJD15OS") .and. OM0200055_GarantiaEspecialJD() // Funcao Atualiza OS e Garantia especial
		lRet := .f.
	EndIf

EndIf

Return lRet

/*/{Protheus.doc} OM0200055_GarantiaEspecialJD
Fun็ใo que indicarแ se hแ uma garantia especial john deere para OS
@author Renato Vinicius
@since 12/12/2018
@version 1.0
@return l๓gico
@param
@type function
/*/

Static Function OM0200055_GarantiaEspecialJD()

Local lRetGarEsp := .f.

Local cVMBTIPGAR := "ZSPA"
Local cVMBDEALER := GetMV("MV_MIL0005")
Local cVMBSTATUS := "09"
Local cVMBSTATSG := "4"
Local cVO1NUMOSV := VO1->VO1_NUMOSV

cQuery := " SELECT VMB.R_E_C_N_O_"
cQuery += " FROM " + RetSqlName("VMB") + " VMB "
cQuery += " WHERE VMB.VMB_FILIAL = '" + xFilial("VMB") + "'"
cQuery += 	" AND VMB.VMB_TIPGAR = '" + cVMBTIPGAR + "' "
cQuery += 	" AND VMB.VMB_DEALER = '" + cVMBDEALER + "' "
cQuery += 	" AND VMB.VMB_NUMOSV = '" + cVO1NUMOSV + "' "
cQuery += 	" AND VMB.VMB_STATUS = '" + cVMBSTATUS + "' "
cQuery += 	" AND VMB.VMB_STATSG = '" + cVMBSTATSG + "' "
cQuery += 	" AND VMB.D_E_L_E_T_ = ' ' "

lRetGarEsp := FM_SQL(cQuery) > 0

Return lRetGarEsp

/*/{Protheus.doc} OM0200065_ArmazemOrigem
Fun็ใo que levanta o armazem de origem de acordo com o tipo de tempo
@author Renato Vinicius
@since 28/08/2019
@version 1.0
@return l๓gico
@param
@type function
/*/

Function OM0200065_ArmazemOrigem( cTpoTpo, cArmazem )

	Default cArmazem := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")

	If GetNewPar("MV_MIL0136",.f.)

		VOI->(DbSetOrder(1))
		If VOI->( DBSeek( xFilial("VOI") + cTpoTpo ) )
			If !Empty(VOI->VOI_ARMORI)
				cArmazem := VOI->VOI_ARMORI
			EndIf
		EndIf

	EndIf

Return cArmazem

/*/{Protheus.doc} OM0200081_ValidaTipoTempo
Chama o posicionamento/Valida็ใo do Tipo de Tempo
@author Andre Luis Almeida
@since 13/08/2019
@return l๓gico
@type function
/*/
Function OM0200081_ValidaTipoTempo(cTpTempo)
Local oOficina := DMS_Oficina():New()
Return !oOficina:TipoTempoBloqueado(cTpTempo,.t.) // Valida se Tipo de Tempo esta BLOQUEADO


/*/{Protheus.doc} OM0200091_LimiteCreditoPecasOrcamento
Checar Limite De Credito Tela Pecas do Orcamento
@author Andre Luis Almeida
@since 06/12/2019
@return l๓gico
@type function
/*/
Static Function OM0200091_LimiteCreditoPecasOrcamento( nRegIni , nRegFin , lCheckALL )
Local nReg      := 0
Local lVerTpgCC := .t.
Local nTotalImp := 0
Local lVldCrd   := .f.
Local aCliJaOk  := {}
Default lCheckALL := .t.

//Validacao por Ponto de Entrada
If PEVERTPGCC // Verifica tipo de Pagamento para Checagem de Credito
	lVerTpgCC := ExecBlock("VERTPGCC",.f.,.f.,{"OFIOM020"})
Endif

If lVerTpgCC

	For nReg := nRegIni to nRegFin
	
		nTotalImp := 0

		// Calcula total ja selecionado
		aEval( aPecaOrc , { |x| IIf( x[1] .and. x[3] == aPecaOrc[nReg,3] .and. x[4] == aPecaOrc[nReg,4] , nTotalImp += ( x[9] * x[11] ) , ) } )
		//

		VOI->(dbSetOrder(1))
		VOI->(MsSeek( xFilial("VOI") + aPecaOrc[nReg,2]))
		If !VOI->VOI_SITTPO $ "2/3/4"

			// Verifica se ja foi levantado o total deste cliente ...
			nAvCredPec := aScan( aAvCredPec , { |x| x[1] == aPecaOrc[nReg,3] .and. x[2] == aPecaOrc[nReg,4] } )
			If nAvCredPec == 0
				AADD( aAvCredPec , Array(03) )
				nAvCredPec := Len(aAvCredPec)
				aAvCredPec[nAvCredPec,01] := aPecaOrc[nReg,3]
				aAvCredPec[nAvCredPec,02] := aPecaOrc[nReg,4]
				aAvCredPec[nAvCredPec,03] := FS_TOTAL( aPecaOrc[nReg,3] , aPecaOrc[nReg,4] , .T. , .T. )
			EndIf

			lVldCrd := .f.
			If !lCheckALL // Click na linha
				nTotalImp += ( aPecaOrc[nReg,9] * aPecaOrc[nReg,11] ) // Somar linha para validar o Limite de Credito
				lVldCrd := .t.
			Else
				If aPecaOrc[nReg,1] .and. aScan( aCliJaOk , { |x| x[1] == aPecaOrc[nReg,3] .and. x[2] == aPecaOrc[nReg,4] } ) == 0
					lVldCrd := .t.
					aAdd(aCliJaOk,{ aPecaOrc[nReg,3] , aPecaOrc[nReg,4] })
				EndIf
			EndIf

			If lVldCrd
				If !OM020AVCRED(aPecaOrc[nReg,3] , aPecaOrc[nReg,4] , aPecaOrc[nReg,2] , ( nTotalImp + aAvCredPec[nAvCredPec,03] ) )
					Return .f.
				EndIf
			EndIf

		EndIf

	Next

Endif

Return .t.

/*/{Protheus.doc} OM0200105_ItemEmRemessa
	Fun็ใo que verifica se o item estแ em remessa para manuten็ใo externa
@author Renato Vinicius
@since 09/03/2020
@return l๓gico
@type function
/*/

Static Function OM0200105_ItemEmRemessa(cNrOsv, cTpTem, cGpItem, cCdItem)

	Local lRetorno := .f.

	cQuery := "SELECT VDR.R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("VDR") + " VDR "
	cQuery += " WHERE VDR.VDR_FILIAL = '" + xFilial("VDR") + "' "
	cQuery += 	" AND VDR.VDR_NUMOSV = '" + cNrOsv + "' "
	cQuery += 	" AND VDR.VDR_TIPTEM = '" + cTpTem + "' "
	cQuery += 	" AND VDR.VDR_GRUITE = '" + cGpItem + "' "
	cQuery += 	" AND VDR.VDR_CODITE = '" + cCdItem + "' "
	cQuery += 	" AND VDR.VDR_NFENUM = ' ' "
	cQuery += 	" AND VDR.D_E_L_E_T_ = ' '"

	If FM_SQL(cQuery) > 0
		lRetorno := .t.
	Endif

Return lRetorno

/*/{Protheus.doc} OM0200115_MostraItensEmRemessa
	Fun็ใo que apresenta os itens que estใo em remessa para manuten็ใo externa
@author Renato Vinicius
@since 09/03/2020
@return
@type function
/*/

Static Function OM0200115_MostraItensEmRemessa(aItensRem)

	Local oDlgIteRem

	oDlgIteRem := MSDialog():New( 180, 180, 820, 700, STR0287, , , , , , , , , .T., , , , .F. )

		oBrowse := TCBrowse():New( 01 , 01, 260, 156,, { STR0067 , STR0099 , STR0100 , STR0101},{40,50,50,50}, oDlgIteRem,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
		oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oBrowse:SetArray(aItensRem)
		oBrowse:bLine := { || { aItensRem[oBrowse:nAt,01],;
								aItensRem[oBrowse:nAt,02],;
								aItensRem[oBrowse:nAt,03],;
								aItensRem[oBrowse:nAt,04] } }

	oDlgIteRem:Activate( , , , .t. , , , )

Return

/*/{Protheus.doc} OM0200121_ConsultaPecasPendentesOS
	Funcao para declarar variaveis necessarias e chamar a funcao ja existente de Pecas Pendendes (FS_PECAORC)
@author Andre Luis Almeida
@since 18/12/2020
@return
@type function
/*/
Function OM0200121_ConsultaPecasPendentesOS()

Private lVSJCODIGO := (VSJ->(FieldPos("VSJ_CODIGO")) <> 0)
Private aPecaOrc := {}

FS_PECAORC(.f.)

Return

/*/{Protheus.doc} OM0200139_CarregaTES()
Fun็ใo para carregar a TES da pe็a
@author Vanessa Simei Mateus
@since 29/01/2021
@return 
@type function
/*/

Static Function OM0200139_CarregaTES()

	If Empty(M->VO3_CODTES)
		dbSelectArea("SB1")
		dbSetOrder(7)
		dbSeek(xFilial("SB1")+M->VO3_GRUITE+M->VO3_CODITE)

		If !Empty(M->VO3_OPER)

			cAuxTES  := MaTesInt(2,M->VO3_OPER,M->VO3_FATPAR,M->VO3_LOJA,"C",SB1->B1_COD)
			If !Empty(cAuxTES)
				SF4->(dbSetOrder(1))
				If !SF4->(MsSeek(xFilial("SF4") + cAuxTES))
					Help(" ",1,"REGNOIS",,AllTrim(RetTitle("VO3_CODTES")) + ": " + cAuxTES ,4,1)
				Else
					aCols[n,FG_POSVAR("VO3_CODTES")] := M->VO3_CODTES := cAuxTES
				EndIf
			EndIf

		Endif
		If Empty(M->VO3_CODTES)
			cAuxTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
			If !Empty(cAuxTES)
				SF4->(dbSetOrder(1))
				If !SF4->(MsSeek(xFilial("SF4") + cAuxTES))
					Help(" ",1,"REGNOIS",,AllTrim(RetTitle("VO3_CODTES")) + ": " + cAuxTES ,4,1)
				Else
					aCols[n,FG_POSVAR("VO3_CODTES")] := M->VO3_CODTES := cAuxTES
				EndIf
			EndIf
		Endif
	Endif

Return

/*/{Protheus.doc} OM0200131_Requisitar_Pecas_de_outras_OSs
Requisitar Pe็as de Outras OSs -> Transferencia de Pe็as entre OSs

@author Andre Luis Almeida
@since 01/04/2021
@return
@type function
/*/
Function OM0200131_Requisitar_Pecas_de_outras_OSs()

OFIA310( VO1->VO1_NUMOSV ) // Tela para selecionar as Pe็as e OS de Origem para Requisitar

Return

/*/{Protheus.doc} OM0200141_Visualizar_OS
Visualizar VO1 ( Consulta da OS )

@author Andre Luis Almeida
@since 07/04/2021
@return
@type function
/*/
Function OM0200141_Visualizar_OS()
Private nOpc := 2 // variavel necessaria no OFIOC060
OFIOC060(.t.)
Return

/*/{Protheus.doc} OM020007B_ValidacaoMVPAR06
 Fun็ใo para validar(bloqueando) o parmetro MV_PAR06, caso o usurio o altere fora da fun็ใo F12 da rotina de Requisi็ใo de Pe็as.

@author Alecsandre Ferreira
@since 03/09/2021
@return
@type function
/*/

Function OM020007B_ValidacaoMVPAR06()
	If IsInCallStack("OM020REM") .and. nMVPar06 <> MV_PAR06
		MsgAlert(STR0299, STR0075) // A altera็ใo deste parโmetro ้ permitida apenas na fun็ใo F12 da rotina de Requisi็ใo de Pe็as. / Aten็ใo
		Return .F.
	Endif
Return .T.


/*/{Protheus.doc} OM0200151_Visualizar_Remessa
Visualizar NF de Remessa / Retorno - referente a OS posicionada

@author Andre Luis Almeida
@since 15/08/2022
@return
@type function
/*/
Function OM0200151_Visualizar_Remessa()
If FindFunction("OFIC290")
	OFIC290( VO1->VO1_FILIAL , VO1->VO1_NUMOSV ) // Consulta de Opera็๕es de Pe็as para Remessa
EndIf
Return
