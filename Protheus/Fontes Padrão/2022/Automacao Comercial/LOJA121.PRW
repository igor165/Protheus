#INCLUDE "LOJA121.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWADAPTEREAI.CH"

#DEFINE NTAMMIN	40

Static lIntegra 	:= SuperGetMv("MV_LJGRINT",.F.,.F.)  	//Verifica se a integracao esta habilitada
Static lIntPOS 		:= (SuperGetMV("MV_LJSYNT",,"0") == "1")//Valida se está integrado com PDV Synthesis
Static oIntegra 	:= Nil									//Objeto do tipo LJCAdapXmlEnvSLG						
Static lMV_LJTEF20	:= .F.  								//Verifica se e tef20
Static lSalvaTef	:= .F.									//Avisa se salva config tef novo
Static cTipImp  	:= ""									//Tipo impressora
Static aImpFiscal 	:= {}									//Lista Impressoras fiscais
Static aFabFiscal 	:= {}									//Lista Fabricantes fiscais
Static aImpNotFisc 	:= {}									//Lista Impressoras nao fiscais
Static aFabNotFisc 	:= {}									//Lista Fabricantes nao fiscais
Static aFabric		:= {}									//Lista Geral de fabricantes de impressoras
Static oImpFFab		:= Nil									//Combo fabricantes impressoras						
Static oDlgEst		:= Nil									//Tela Principal do cadastro
Static cSigaDLLVer	:= ""									//Versao da Dll SIGALOJA
Static nNFCeFolder	:= 0
Static nFldIntRaas  := 0
Static oAtivNFce	:= Nil
Static oURLTSS		:= Nil
Static oToken		:= Nil
Static oUTCNfce		:= Nil
Static oIDToken		:= Nil
Static oEditNfce	:= Nil				
Static cSiglaSat	:= IIF( ExistFunc("LjSiglaSat"),LjSiglaSat(), "SAT" )	//Retorna sigla do equipamento que esta sendo utilizado
Static cTipoPAF 	:= ""

#DEFINE LINHATEF 28

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ LOJA121  ³ Autor ³ Vendas Clientes       ³ Data ³22/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao do cadastro de Estacoes                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LOJA121( cFolder, lCallCenter, xAutoCab, nOpcAuto ) 

If LjChkHtml()
	FwAvisoHtml()
	Return
EndIf
	
// Define Array contendo as Rotinas a executar do programa
// ----------- Elementos contidos por dimensao ------------
// 1. Nome a aparecer no cabecalho
// 2. Nome da Rotina associada
// 3. Usado pela rotina
// 4. Tipo de Transacao a ser efetuada
//    1 - Pesquisa e Posiciona em um Banco de Dados
//    2 - Simplesmente Mostra os Campos
//    3 - Inclui registros no Bancos de Dados
//    4 - Altera o registro corrente
//    5 - Remove o registro corrente do Banco de Dados

PRIVATE aRotina 	:= MenuDef()

//Define o cabecalho da tela de atualizacoes
PRIVATE cCadastro	:= STR0006			// Cadastramanto de Estacao
PRIVATE cFoldEst	:= cFolder
PRIVATE lCall		:= lCallCenter		// Variavel utilizada na criacao do folder TEF. Inibe objetos que nao sao utilizados pelo Call Center.
Private lLj121Auto	:= xAutoCab <> Nil
Private aAutoSlg	:= {}

//Se a variavel de retorno do ExecAuto nao foi criada, faz a inicializacao
If Type("lMsErroAuto") == "U"
	Private lMsErroAuto	:= .F.
EndIf

DEFAULT cFoldEst	:= "1234567"
DEFAULT lCall		:= .F.
DEFAULT nOpcAuto	:= 3

If (Type("lLj121Auto") <> "U" .And. lLj121Auto)	
	aAutoSlg := xAutoCab	
	MBrowseAuto(nOpcAuto, aAutoSlg, "SLG")
Else
	mBrowse( 6, 1,22,75,"SLG")
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    |MenuDef	³ Autor ³ Vendas Clientes       ³ Data ³12/12/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de definição do aRotina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRotina   retorna a array com lista de aRotina             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef() 

Local aRotina:= {  	{STR0001, "AxPesqui"	, 0, 1 , , .F.},;    // Pesquisar
					{STR0002, "LJ121Vis"	, 0, 2 , , .T.},;    // Visualizar
					{STR0003, "LJ121Inc"	, 0, 3 , , .T.},;    // Inclui
					{STR0004, "LJ121Alt"	, 0, 4 , , .T.},;    // Alterar
					{STR0005, "LJ121Exc"	, 0, 5 , , .T.},;    // Excluir
					{STR0048, "LJXRPL"		, 0, 6 , , .T.} }    // Replicar --> Funcao Generica no LOJXFUNA.PRX						  
							
Return ARotina

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ LJ121Inc ³ Autor ³ Vendas Clientes       ³ Data ³22/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclusao de Estacoes                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ121Inc()

If !lLj121Auto
	ManutEst("I")
Else
	If EnchAuto("SLG", aAutoSlg)
		LJEstAuto("I")
	Else
		lMsErroAuto := .T.
		Help( " ", 1, "Help",, STR0221, 1, 0 ) //#"Erro na inclusao da Estacao" 
	EndIf
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ LJ121Vis ³ Autor ³ Vendas Clientes       ³ Data ³17/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizacao de Estacoes                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ121Vis()

ManutEst("V")

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ LJ121Alt ³ Autor ³ Vendas Clientes       ³ Data ³22/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Alteracao de Estacoes                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ121Alt()

If Eof()
	Return NIL
EndIf

If !lLj121Auto
	ManutEst("A")
Else
	If EnchAuto("SLG", aAutoSlg)
		LJEstAuto("A")
	Else
		lMsErroAuto := .T.
		Help( " ", 1, "Help",, STR0222, 1, 0 ) //#"Erro na alteracao da Estacao" 
	EndIf
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ LJ121Exc ³ Autor ³ Vendas Clientes       ³ Data ³22/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclusao de Estacoes                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ121Exc()
If Eof()
	Return NIL
EndIf

If !lLj121Auto
	ManutEst("E")
Else
	If EnchAuto("SLG", aAutoSlg)
		LJEstAuto("E")
	Else
		lMsErroAuto := .T.
		Help( " ", 1, "Help",, STR0223, 1, 0 ) //#"Erro na exclusao da Estacao" 	
	EndIf
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ ManutEst ³ Autor ³ Vendas Clientes       ³ Data ³22/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao generica para manutencao nos registros do arquivos  ³±±
±±³          ³ de estacoes                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTipo - tipo de operacao a ser efetuado, sendo :           ³±±
±±³          ³ I - Inclusao                                               ³±±
±±³          ³ A - Alteracao                                              ³±±
±±³          ³ E - Exclusao                                               ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ManutEst( cTipo )
Local oFolder
Local cRot		:= STR0003  // Incluir
Local lFlagCod	:= .T.
Local oCodEst
Local cCodigo	:= Space(TamSx3("LG_CODIGO")[1])
Local oNomeEst
Local cNome		:= Space(TamSx3("LG_NOME")[1])
Local oSerie
Local cSerie	:= Space(TamSx3("LG_SERIE")[1])
Local cNomeRede	:= Iif( SLG->(ColumnPos("LG_NOMCOMP")) > 0 , Space(TamSx3("LG_NOMCOMP")[1]) , "" )
Local oNomeRede
Local lNomeRede := SLG->(ColumnPos("LG_NOMCOMP")) > 0
Local oTamSer
Local cTamSer	:= If( SLG->(ColumnPos("LG_TAMSER"))>0, Space(TamSx3("LG_TAMSER")[1]), Space( 6 ) )
Local oPdv
Local cPdv		:= Space(TamSx3("LG_PDV")[1])
Local lSerieCNF	:= SLG->(ColumnPos("LG_SERNFIS")) > 0
Local oSerieCNF
Local M->LG_SERNFIS	:= Iif( lSerieCNF, CriaVar("LG_SERNFIS",.F.), "" )

Local oTermTEF
Local nTermTEF	:= 0
Local cTEFCons	:= Repli("S",TamSx3("LG_TEFCONS")[1])
Local cLista	:= Space(10000)
Local nTamImpF  := TamSx3("LG_IMPFISC")[1]

Local nTamFabSAT := IIF(SLG->(ColumnPos("LG_FABSAT")) > 0,TamSx3("LG_FABSAT")[1], 40 ) //Fabricante SAT
Local nTamModSAT := IIF(SLG->(ColumnPos("LG_MODSAT")) > 0,TamSx3("LG_MODSAT")[1], 40 ) //Modelo SAT

Local cImpFisc	:= Space(nTamImpF)
Local aImpList	:= {cImpFisc}
Local oImpFisc

Local aImpFTot  := {cImpFisc}

Local aFabricSAT   := {nTamFabSAT} //Fabricante SAT
Local aModSAT   := {nTamModSAT} //Modelo SAT

Local aModelo	:= {cImpFisc}

Local oChkTiFa  := Nil
Local lChkTiFa  := .F.

Local oChkPvNf  := Nil
Local cChkPvNf  := "N"

Local oRecTktFat := Nil
Local cRecTktFat := "n"
Local cImpFFab  := Space(nTamImpF)
Local oTipImp	:= Nil 
Local aTipImp  	:= {}

Local cSAT  := Space(nTamFabSAT) //Fabricante SAT
Local oComboSAT := Nil //Obj tipos de SAT
Local oAtivSAt := Nil //SAT ATIVO
Local OSerSAT  := Nil //Serie SAT
Local oChvReq  := Nil //Chave de requisição MFE
Local oChvAccVld  := Nil //chave do validador fiscal MFE

Local cModelSAT := Space(nTamModSAT) //Modelo SAT
Local oComboModSAT := Nil //Modelos SAT

Local oCbAtivSAT := Nil //Combo Ativa SAT
Local cAtivSAT := ""    //Se o SAT esta Ativo 
Local aAtivSAT := {" ", "Sim", "Não"} //Informaçoes de ativaçao SAT

Local cAltFMod  := Space(nTamImpF)

Local cImpFMod  := Space(nTamImpF)
Local oImpFMod

Local cImpFUni  := Space(nTamImpF)

Local cPortIF	:= Space(TamSx3("LG_PORTIF")[1])
Local aPortIF	:= {	cPortIF	, "COM1", "COM2" , "COM3", ;
						"COM4"	, "COM5", "COM6" , "COM7", ;
						"COM8"	, "COM9", "COM10"}
Local oPortIF

Local cJournal	:= Space(TamSx3("LG_JOURNAL")[1])
Local oJournal

Local cImpChq	:= Space(TamSx3("LG_IMPCHQ")[1])
Local aImpChq	:= {cImpChq}
Local oImpChq

Local aPortChq	:= {	cPortIF	, "LPT1", "LPT2", "COM1", ;
						"COM2"	, "COM3", "COM4", "COM5", ;
						"COM6"	, "COM7", "COM8", "COM9", ;
						"COM10" , "USB"}
Local cPortChq	:= cPortIF
Local oPortchq

Local cImpCup	:= Space(TamSx3("LG_IMPCUP")[1])
Local aImpCup	:= {cImpCup, "EPSON"}
Local oImpCup

Local aPortICP	:= {	cPortIF	, "LPT1", "LPT2", "COM1", ;
						"COM2"	, "COM3", "COM4", "COM5", ;
						"COM6"	, "COM7", "COM8", "COM9", ;
						"COM10" , "USB"}
Local cPortICP	:= cPortIF
Local oPortICP

Local cOptico	:= Space(TamSx3("LG_OPTICO")[1])
Local aLeitOpt	:= {cOptico}
Local oLeitOpt

Local aPortOpt	:= aClone(aPortIF)
Local cPortOpt	:= cPortIF
Local oPortOpt

Local cPinPad	:= Space(TamSx3("LG_PINPAD")[1])
Local aPinPad	:= {cPinPad}
Local oPinPad

Local aPortPad	:= aClone(aPortIF)
Local cPortPad	:= cPortIF
Local oPortPad

Local cCMC7		:= Space(TamSx3("LG_CMC7")[1])
Local aCMC7		:= {cCMC7}
Local oCMC7
Local oCMC7Dir											//Objeto para o ComboBox do CMC7 Direto
Local aCMC7Dir	:= {"",STR0192,STR0193}					//"1=Sim" "2=Nao" Array do ComboBox do CMC7 Direto
Local cCMC7Dir	:= ""									//Variavel para o item selecionado no ComboBox do CMC7 Direto
Local lCMC7Dir	:= SLG->(ColumnPos("LG_CMC7DIR")) > 0	//variavel que guarda se o campo do CMC7 existe

Local aPortCMC7	:= aClone(aPortIF)
Local cPortCMC7	:= cPortIF
Local oPortMC7

Local cCartMag	:= Space(TamSx3("LG_CARTMAG")[1])
Local aCartMag	:= {cCartMag}
Local oCartMag

Local aPortMag	:= aClone(aPortIF)
Local cPortMag	:= cPortIF
Local oPortMag

Local aPortBal	:= aClone(aPortIF)
Local cBalanca	:= Space(TamSx3("LG_BALANCA")[1])
Local aBalanca	:= {cBalanca, "FILIZOLA BCSA R 15","FILIZOLA CS - R","FILIZOLA PLATINA"}
Local oBalanca                   
Local oPortBal 
Local cPortBal	:= ""								// Porta da balanca
Local nTimeOut	:= 0
Local oTimeOut 
Local cDirBal	:= Space(TamSx3("LG_DIRBAL")[1])	// Diretorio da balanca
Local oDirBal

Local cGaveta	:= Space(TamSx3("LG_GAVETA")[1])
Local aGaveta	:= {cGaveta}
Local oGaveta

Local oGavStat 
Local lGavStat	:= .F. 		

Local aPortGav	:= aClone(aPortICP)
Local cPortGav	:= cPortICP
Local oPortGav

Local cDisplay	:= Space(TamSx3("LG_DISPLAY")[1])
Local aDisplay	:= {cDisplay}
Local oDisplay

Local cPortDis	:= cPortICP
Local oPortDis

//Display Torre
Local cDispTorre	:= If( SLG->(ColumnPos("LG_DISPTOR")) > 0, Space(TamSx3("LG_DISPTOR")[1]), Space(20) )	// Display torre selecionado
Local aDispTorre 	:= {cDispTorre}		//Array dos displays de torre
Local cPortTorre	:= cPortICP			//Porta do display torre selecionada
Local oDispTorre						//Objeto COMBOBOX dos displays torre
Local oPortTorre						//Objeto COMBOBOX das portas do display torre

//RFID  
Local oComboRFID	:= Nil					//Objeto COMBOBOX RFID
Local cRFID			:= If( SLG->(ColumnPos("LG_RFID")) > 0, Space(TamSx3("LG_RFID")[1]), Space(1) )	// COMBOBOX RFID
Local oGetIDRFID	:= Nil					//Objeto Get ID RFID
Local cGetIDRFID 	:= If( SLG->(ColumnPos("LG_IDRFID")) > 0, Space(TamSx3("LG_IDRFID")[1]), Space(3) )

// TEF
Local cImpTEF	:= STR0008
Local aImpComp	:= {STR0008,STR0059,STR0060} //  Nao Imprime/"Fiscal "/ "Cupom"
Local nImpTEFC	:= 2
Local cTEFVias	:= "0"
Local aVias		:= {'0','1','2','3','4','5','6','7','8','9'}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³nTipTef                  ³
//³-------------------------³
//³1 - Não Utiliza          ³
//³2 - Dedicado Sem Cliente ³
//³3 - Sitef Modular        ³
//³4 - Discado              ³
//³5 - Lote                 ³
//³6 - Clisitef             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nTipTef	:= 1
Local oDirTrans
Local nTamDirTx := Space(TamSx3("LG_DIRTTX")[1])				// Tamanho da variavel nTamDirTx
Local cDirTTX	:= nTamDirTx
Local oDirRec
Local nTamDirRX := Space(TamSx3("LG_DIRTRX")[1])				// Tamanho da variavel nTamDirRX
Local cDirTRX	:= nTamDirRX
Local oPadMsg
Local cPadMsg	:= Space(TamSx3("LG_PADMSG")[1])
Local oChk1
Local oChk2
Local oChk3
Local oChk4
Local oChk5
Local oChk6
Local oChk7				// Objeto do Checkbox

Local lVar1
Local lVar2
Local lVar3
Local lVar4
Local lVar5
Local lVar6
Local lVar7															// Variavel do Checkbox (TECBAN)
Local lVar8															// Variavel do Checkbox (REDECARD)
Local lRecarga														// Variavel do Check box (recarga de celular)

Local oImpTEFC
Local nPos 
Local oTipoEmp	:= Nil												//Objeto do COMBOBOX da empresa que vai operar as transacoes TEF
Local cTipoEmp	:= Space(TamSx3("LG_TIPOATE")[1])					//Empresa que vai operar as transacoes TEF 1-Sitef , 2-E-Financial
Local aTipoEmp	:= {" ",STR0107,STR0108}							//"Sitef" / "E-Financial"
Local oPanel														// Panel para o LG_IPSITEF
Local oIPSiTEF
Local cIPSiTEF	:= Space(15)      


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Bloco de codigo para inicializar todas as variaveis do folder³
//³ TEF, e desabilitar seus objetos apos um refresh que e para   ³
//³ atualizar seus valores quando selecionado "Nao Utiliza" TEF  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando a variavel lCall estiver habilitada (lCall = .T.)      |
//|alguns objetos do Folder TEF nao serao criados. Quando esta   |
//|estiver desabilitada (lCall == .F.) os objetos serao criados  |
//|normalmente e poderao ser validados no CodeBlock abaixo.      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local bTefDis := {|| cImpTEF := ;
					If(!lCall,(If(!Empty(cImpFisc),aImpComp[2],aImpComp[1])	, oImpComp:refresh() ,oImpComp:Disable()),"")	,;
					If(!lCall,(cTEFVias := "0"			, oVias:Refresh()    	, oVias:Disable()),"")    						,;
					If(!lCall,(nImpTEFC := 2 			, oImpTEFC:Refresh() 	, oImpTEFC:Disable()),"") 						,;
					If(lCall, (cTipoEmp := aTipoEmp[1]	, oTipoEmp:Refresh() 	, oTipoEmp:Disable()),"") 						,;
					lVar1    :=.F.       		  		, oChk1:Refresh()    	, oChk1:Disable()    							,;
					lVar2    :=.F.                		, oChk2:Refresh()   	, oChk2:Disable()    							,;
					lVar3    :=.F.                		, oChk3:Refresh()   	, oChk3:Disable()    							,;
					lVar4    :=.F.                		, oChk4:Refresh()   	, oChk4:Disable()    							,;
					lVar5    :=.F.                		, oChk5:Refresh()   	, oChk5:Disable()    							,;
					lVar6    :=.F.                		, oChk6:Refresh()   	, oChk6:Disable()   							,;
					lVar7    :=.F.                		, oChk7:Refresh()   	, oChk7:Disable()   							,;
					lVar8    :=.F.                		, oChk8:Refresh()   	, oChk8:Disable()   							,;
					cDirTTX  := nTamDirTx          		, oDirTrans:Refresh() 	, oDirTrans:Disable()							,;
					cDirTRX  := nTamDirRX         		, oDirRec:Refresh() 	, oDirRec:Disable()}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita os obejetos do folder TEF, quando selecionado opcao ³
//³ diferente de "Nao Utiliza" TEF                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando a variavel lCall estiver habilitada (lCall = .T.)      |
//|alguns objetos do Folder TEF nao serao criados. Quando esta   |
//|estiver desabilitada (lCall == .F.) os objetos serao criados  |
//|normalmente e poderao ser validados no CodeBlock abaixo.      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local bTefEnab:={|| cImpTEF := ;
					If(!lCall,(If(!Empty(cImpFisc),aImpComp[2],If(Empty(cImpTEF),aImpComp[1],cImpTef))),""),;
					If(!lCall,oImpComp :Refresh(),""),;
					If(!lCall,oImpComp :Enable() ,""),;
					If(!lCall,oVias    :Enable() ,""),;
					If(!lCall,oImpTEFC :Enable() ,""),;
					If(lCall,oTipoEmp  :Enable() ,""),;
					oChk1    :Enable(),;
					oChk2    :Enable(),;
					oChk3    :Enable(),;
					oChk4    :Enable(),;
					oChk5    :Enable(),;
					oChk6    :Enable(),;
					oChk7    :Enable(),;
					oDirTrans:Enable(),;
					oDirRec  :Enable()}
					
// Servidor RPC
Local cRPCSrv		:= Space(TamSx3("LG_RPCSRV")[1])
Local cRPCPort		:= Space(TamSx3("LG_RPCPORT")[1])
Local cRPCEnv		:= Space(TamSx3("LG_RPCENV")[1])
Local cRPCEmp		:= Space(TamSx3("LG_RPCEMP")[1])
Local cRPCFil		:= Space(TamSx3("LG_RPCFIL")[1])
Local nRPCInt		:= 5
Local cRMTEnv		:= PadR(GetPvProfString("APFrontLoja", "Environment", "", GetAdv97()),20)
Local cRMTEmp		:= PadR(GetPvProfString("APFrontLoja", "Parm1", "", GetAdv97()),2)
Local cRMTFil		:= PadR(GetPvProfString("APFrontLoja", "Parm2", "", GetAdv97()),FWGETTAMFILIAL)

Local oRPCSrv
Local oRPCPort
Local oRPCEnv
Local oRPCEmp
Local oRPCFil
Local oRPCInt
Local oRMTEnv
Local oRMTEmp
Local oRMTFil

// AP Terminal Services Client
Local cTSCSrv		:= Space(TamSx3("LG_TSCSRV")[1])

Local cCodSAT     := IIF(SLG->(ColumnPos("LG_CODSAT")) > 0,Space(TamSx3("LG_CODSAT")[1]), Space(9) ) //Codigo do equipamento SAT
Local cSerSAT     := IIF(SLG->(ColumnPos("LG_SERSAT")) > 0,Space(TamSx3("LG_SERSAT")[1]), Space(9) ) //Serie do equipamento SAT
Local cChvReq     := IIF(SLG->(ColumnPos("LG_CHVREQ")) > 0,Space(TamSx3("LG_CHVREQ")[1]), Space(9) ) //Chave de requisição do MFE
Local cChvVld     := IIF(SLG->(ColumnPos("LG_CHVVLD")) > 0,Space(TamSx3("LG_CHVVLD")[1]), Space(9) ) //Chave do validador fiscal MFE

Local cTSCPort		:= Space(TamSx3("LG_TSCPORT")[1])

Local oTSCSrv
Local oTSCPort

// Servidor de Consultas cheque-pre.com
Local lIntCns
Local oIntCns
Local cDirOri		:= Space(TamSx3("LG_DIRORI")[1])
Local oDirOri
Local cDirDes		:= Space(TamSx3("LG_DIRDES")[1])
Local oDirDes
Local cDirExec		:= Space(TamSx3("LG_DIREXEC")[1])
Local oDirExec
Local cRedeCns		:= Space(TamSx3("LG_REDECNS")[1])
Local oRedeCns
Local cLojaCns		:= Space(TamSx3("LG_LOJACNS")[1])
Local oLojaCns
Local cCtrCns		:= Space(TamSx3("LG_CTRCNS")[1])
Local oCtrCns

// Servidor WebService de Recebimento e Fidelizacao
Local oWebSvc
Local cWebSvc	:= Space(TamSX3("LG_WSSRV")[1])
Local lWSSRVMT	:= .F.			//Verifica se tem Ws	
Local oWebMtz 	:= Nil			// Carrga Ws
Local cWebMtz 	:= ""       	// Ws Matriz
Local lMtzOk	:= .F.			// Matriz ok	
Local oMtzOk	:= Nil			// verifica se 

// Integração com o SIGACRD
Local oCrdImp
Local cCrdImp		:= Space(TamSx3("LG_CRDIMP")[1])
Local aCrdImp		:= {}
Local oCrdXInt
Local cCrdXInt		:= Space(TamSx3("LG_CRDXINT")[1])
Local aCrdXInt		:= {}

Local oCrdVias
Local nCrdVias		:= 0

//Variaveis para a criacao automatica dos folders.
Local aFolder		:= {}
Local aPrompts		:= {}
Local nFolder		:= 0

//Variaveis para tela de cadastramento de mensagem do cupom fiscal.
Local oMsgCup
Local cMsgCup		:= ''
Local oFnt0
 
// TouchScreen
Local oTouch																					//Objeto TouchScreen dos modelos Touch Screen
Local cTouch		:= If (SLG->( ColumnPos("LG_TOUCH") ) > 0,Space(TamSx3("LG_TOUCH")[1]),"")	// modelos dos Touch Screen
Local aTouch		:= {STR0122}																//"Waytec"	//Array com os modelos dos Touch Screeen
Local nTipoTela		:= 1																		//Define qual tela sera' usada no sistema 1 = Desktop	2 = Touch Screen

//Variaveis que controlam o dimensionamento da tela 
Local aSize1		:= MsAdvSize( .T., .F., 600 )		// SIZE da Dialog
Local aObjects		:= {}								// Objetos da dialog
Local aInfo			:= {}								// Array com as informacoes
Local aPosObj		:= {}								// Array com a posicao dos objetos
Local nImpFisc		:= TamSX3("LG_IMPFISC")[1]			// Tamanho do campo LG_IMPFISC
Local cValidRec		:= "2"
Local lMsgRec		:= .F.  
Local nTamRPCFil 	:= 45								//Tamanho do MSGET onde sera informada a filial.
Local oCfgTef 		:= NIL	// Configurador do Novo Tef
Local nOpc			:= 0                              	// Opcao de tef ativo 
Local lTefMex		:= cPaisLoc == "MEX"     // SE USA TEF MEXICO
Local cCompany		:= ""		// Companhia Centro de Pagos
Local oCompany		:= Nil      // Objeto de Telado Centro de Pagos
Local cUrlServ		:= ""		// Url Centro de Pagos
Local oUrlServ		:= Nil		// Obj Url Centro de Pagos
Local cBranch 		:= ""		// Unid Centro de Pagos
Local oBranch       := Nil		// Onj Unid Centro de Pagos
Local cContry 		:= ""		// Pais Centro de Pagos
Local oContry      	:= Nil      // Obj Pais Centro de Pagos
Local cMerchant 	:= ""		// Nº Afiliação Centro de Pagos
Local oMerchant    	:= Nil      // Obj Nº Afiliação Centro de Pagos
Local cUserCp		:= ""		// Usuario Centro de Pagos
Local oUserCp		:= Nil		// Obj Usuario Centro de Pagos
Local cPwsCp		:= ""		// Senha Centro de Pagos
Local oPwsCp		:= Nil		// Obj Senha Centro de Pagos
Local cOpType		:= ""		// Tip Ope Centro de Pagos
Local oOpType		:= Nil		// Obj Tip Ope Centro de Pagos
Local cCurrenc 		:= ""		// Moeda Centro de Pagos
Local oCurrenc      := Nil		// Obj Moeda Centro de Pagos
Local aCurrenc		:= {}		// "Sitef" / "E-Financial"
Local nCurrenc		:= 0		// Moeda
Local oTipMexCp		:= Nil		// Tipo do Centro de Pagamentos
Local cTipMexCp		:= ""		// Tipo do Centro de Pagamentos
Local nTipMexCp		:= 	2		// Tipo do Centro de Pagamentos
Local aTipMexCp		:= {}		// Tipo do Centro de Pagamentos
Local aModelos      := {}       // Modelos utilizados no Serie3
Local lPOS			:= STFIsPOS() //Pos?
Local lPafEcf		:= IIF(lPOS, STBIsPAF(), LjNfPafEcf(SM0->M0_CGC))
Local lNoPaf		:= LjNfNoPaf(SM0->M0_CGC)
Local lNFCe			:= .F.
Local nRecSLG		:= 0
Local lDefColECF	:= IIf(SLG->(ColumnPos("LG_LARGCOL")) == 0,.F.,.T.)	//Campo para definicao de largura de colunas para impressao ECF definida?

//Definicao largura impressao da ECF?
Local oLargCol
Local nLargCol		:= IIf(lDefColECF,CriaVar("LG_LARGCOL",.T.),0)								//Variavel para armazenar a largura em colunas de impressao da ECF
Local aDados		:= {}
Local cIsPos		:= "" 
Local aIsPos		:= {}
Local oIsPos		:= NIL

//³Tratamento Integracao POS - Synthesis  ³
Local cIntPos		:= "" 
Local aIntPos		:= {}
Local oIntPos		:= NIL
Local oEditMsRod    := Nil // Edit para mensagem no Rodapé
Local oEditSAT    	:= Nil // Edit para mensagem do SAT		
Local cMsgFaqSAT   	:= ""  // Mensagem da FAQ SAT
Local oFont			:= Nil
Local cMsgRodape	:= ""
Local cAtivNfce		:= ""
Local cURLTSS		:= ""
Local cToken		:= ""
Local cUTCNfce		:= ""
Local cIDToken		:= ""
Local oBtnConfig	:= Nil
Local lIntegHtl 	:= SuperGetMv("MV_INTHTL",, .F.) .And. FWHasEAI("LOJA701",, .T., .T.) //Integracao via Mensagem Unica - Hotelaria
Local cSerPdv   	:= Space(TamSX3("LG_SERPDV")[1]) //Serie do Equipamento
Local oSerPdv   	:= Nil //Objeto da Serie do PDV
Local lLG_CRECFPA	:= SLG->(ColumnPos("LG_CRECFPA")) > 0
Local cCredECF		:= IIF(lLG_CRECFPA, Space(TamSX3("LG_CRECFPA")[1]), "")
Local oCredECF		:= NIL
Local cUrlMFe		:= ""
Local cMsgMfe		:= ""
Local nLinhas		:= 0
Local lLG_IPIMPRD	:= SLG->(ColumnPos("LG_IPIMPRD")) > 0
Local cIPImpRD		:= IIf( lLG_IPIMPRD , Space(TamSX3("LG_IPIMPRD")[1]), "")
Local oIPImpRD		:= NIL
Local aLeg61		:= LJAnalisaLeg(1)
Local lUsePayHub 	:= ExistFunc("LjUsePayHub") .And. LjUsePayHub()

//Pdv Online
Local oComboPdv := Nil //Recebe o objeto do combobox (Sim/Não)
Local cIsOnline := "2" //O conteúdo padrão é 2 pois sempre que cria uma nova estação coloca como PDV Online = Não

Local oComboPAF		:= Nil 


cTipoPAF := ""

cSigaDLLVer 	:= IIF( lPOS , STWDLLVersionControl(),LJDLLVER() )

DEFINE FONT oFont NAME "Courier New" SIZE 06,20

aFabric   := {cImpFisc}

If SLG->(ColumnPos("LG_ISPOS")) > 0
	If cTipo $ "I"
		cIsPos		:= SLG->(CriaVar("LG_ISPOS"))
		
		If lPOS   
			cIsPos := "1" //"Sim"
		Else
			cIsPos := "2" //Não
		EndIf 
		
		aIsPos := StrTokArr( Posicione("SX3", 2, PadR("LG_ISPOS",10), "X3CBox()" ), ";") 
	
	Else 
		aIsPos := StrTokArr( Posicione("SX3", 2, PadR("LG_ISPOS",10), "X3CBox()" ), ";")
		cIsPos := LG_ISPOS
		If Empty(cIsPos)
			cIsPos := IIF(lPOS, "1", "2")
		EndIf
	EndIf

	lMV_LJTEF20 := .T.
EndIf 

//PDV Online
If SLG->(ColumnPos("LG_PDVON")) > 0
	If cTipo $ "I"
		cIsOnline := "2"
	Else
		cIsOnline := IIF(Empty(SLG->LG_PDVON), "2", SLG->LG_PDVON)
	EndIf
EndIf

If SLG->(ColumnPos("LG_TIPOPAF")) > 0
	cTipoPAF := SLG->LG_TIPOPAF
EndIf

If lPOS

	STFStrategyECF()
    aDados := STFFireEvent(	ProcName(0) ,;		// Nome do processo
 					"STCheckDLL",;// Nome do evento
 					{.T.} )
EndIf

oCfgTef := LJCCfgTef():New(.T.)

If lTefMex
	cCompany		:= Space(TamSX3("LG_COMPANY")[1])	// Companhia Centro de Pagos
	oCompany		:= Nil                             	// Objeto de Telado Centro de Pagos
	cUrlServ		:= Space(TamSX3("LG_SETURL")[1])	// Url Centro de Pagos
	oUrlServ		:= Nil								// Obj Url Centro de Pagos
	cBranch 		:= Space(TamSX3("LG_BRANCH")[1])	// Unid Centro de Pagos
	oBranch       	:= Nil								// Onj Unid Centro de Pagos
	cContry 		:= Space(TamSX3("LG_COUNTRY")[1])	// Pais Centro de Pagos
	oContry      	:= Nil                          	// Obj Pais Centro de Pagos
	cMerchant 		:= Space(TamSX3("LG_MERCHAN")[1])	// Nº Afiliação Centro de Pagos
	oMerchant    	:= Nil                          	// Obj Nº Afiliação Centro de Pagos
	cUserCp			:= Space(TamSX3("LG_USERCP")[1])	// Usuario Centro de Pagos
	oUserCp			:= Nil								// Obj Usuario Centro de Pagos
	cPwsCp			:= Space(TamSX3("LG_PWDCP")[1])	// Senha Centro de Pagos
	oPwsCp			:= Nil								// Obj Senha Centro de Pagos
	cOpType			:= Space(TamSX3("LG_OPTYPE")[1])	// Tip Ope Centro de Pagos
	oOpType			:= Nil								// Obj Tip Ope Centro de Pagos
	cCurrenc 		:= "USD"							// Moeda Centro de Pagos
	oCurrenc      	:= Nil								// Obj Moeda Centro de Pagos
	aCurrenc		:= {"MXN - "+STR0187, "USD - "+STR0188}		// "Sitef" / "E-Financial"
	nCurrenc		:= 1                                       	// Moeda para CP
	oTipMexCp		:= Nil										// Objeto de Telas		
	cTipMexCp		:= STR0190									// Tipo de tela
	nTipMexCp		:= 	2										// Objeto de Telas		
	aTipMexCp		:= {STR0189, STR0190} 						// SIM/NÃO
EndIf

If SLG->(ColumnPos("LG_PORTBAL")) > 0
	cPortBal := Space(TamSX3("LG_PORTBAL")[1]) 	// Tamanho da variavel cPortBal
Else
	cPortBal := Space( 5 )
EndIf

lWSSRVMT := (SLG->(ColumnPos("LG_WSSRVMT")) > 0)

If lWSSRVMT
	cWebMtz 	:= Space(TamSX3("LG_WSSRVMT")[1])
EndIf
                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mensagem para alertar sobre a alteração no cadastro de³
//³estação e aplicação do boletim, se ja foi alterado nao³
//³deve inserir. Se o LG_IMPFISC estiver com tamanho 40  ³
//³nao deve ser exibida.                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nImpFisc < 40 
	MsgStop( STR0117 + Chr( 10 ) + Chr( 13 ) + ; // "A partir da versão 0.2.87.30 da SIGALOJA.DLL a lista de impressoras fiscais"
	         STR0118 + Chr( 10 ) + Chr( 13 ) + ; // "passou a permitir a visualização da versão do software básico. Para que"                          
			 STR0119 + Chr( 10 ) + Chr( 13 ) + ; // "essa alteração tenha efeito é necessa´rio seguir os procedimentos do Boletim"
	         STR0120 ) 							  // "Técnico: 'Visualização da Versão do Software Básico do ECF no Cadastro de Estação'"
EndIf
                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para outros paises a impressora pode ser paralela     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc <> "BRA"
	AAdd(aPortIF, "LPT1")
	AAdd(aPortIF, "LPT2")
EndIf
// Alimenta o array aCrdImp
aEval( RetSx3Box( Posicione("SX3", 2, PadR("LG_CRDIMP",10), "X3CBox()" ),,, 1 ), {|x| aAdd(aCrdImp,x[3]) } )
// Alimenta o array aCrdXInt
aEval( RetSx3Box( Posicione("SX3", 2, PadR("LG_CRDXINT",10), "X3CBox()" ),,, 1 ), {|x| AAdd(aCrdXInt,x[3]) } )

//Verifica quais os folder`s serao exibidos.
LjGetFolder(@aFolder,@aPrompts)

// Carregar variaveis
If cTipo $ "AVE"
	Do Case
		Case cTipo == "A"
			cRot       := STR0004      // Alterar
		Case cTipo == "V"
			cRot       := STR0002      // Visualizar
		Case cTipo == "E"
			cRot       := STR0005      // Excluir
	EndCase
	lFlagCod	:= .F.
	cCodigo		:= LG_CODIGO
	cNome		:= LG_NOME
	cSerie		:= LG_SERIE
	cPDV		:= LG_PDV
	lNFCe		:= LG_NFCE

	If lNomeRede
		cNomeRede := LG_NOMCOMP
	EndIf

	If lSerieCNF
		M->LG_SERNFIS := SLG->LG_SERNFIS	//passamos o Alias, pois senao ele pega o valor do campo em memoria
	EndIf

	nTermTEF   := LG_TERMTEF

	/*
	A impressora Bematech será acessada somente da SIGLOJA.DLL
	*/
	If AllTrim(LG_IMPFISC) == "BEMATECH MP4200 V01.00.00" .And. IIF( SLG->( ColumnPos("LG_USESAT") ) > 0, (!LG_USESAT .OR. cSigaDLLVer >= "0.3.141.0" ), .T.) 
		nRecSLG := SLG->(Recno())
		RecLock("SLG",.F.)
		REPLACE SLG->LG_IMPFISC WITH "BEMATECH MP-4200 TH 01.00.00(S)"
		SLG->(MsUnlock())
		SLG->(DbGoto(nRecSLG))
	EndIf
	cImpFisc   := SLG->LG_IMPFISC

    cImpFUni   := SLG->LG_IMPFISC
	cImpFFab   := SubStr(cImpFUni , 1 , At(' ',cImpFUni)-1 )														 

	cImpFMod   := SLG->LG_IMPFISC                                 														 
	cAltFMod   := SLG->LG_IMPFISC                                 														 

	cPortIf    := SLG->LG_PORTIF
	cImpCup    := SLG->LG_IMPCUP
	cPortICP   := SLG->LG_PORTICP
	cImpChq    := SLG->LG_IMPCHQ
	cPortChq   := SLG->LG_PORTCHQ
	cOptico    := SLG->LG_OPTICO
	cPortOpt   := SLG->LG_PORTOPT
	cPinPad    := SLG->LG_PINPAD
	cPortPad   := SLG->LG_PORTPAD
	cPadMsg    := SLG->LG_PADMSG
	cCMC7      := SLG->LG_CMC7
	cPortCMC7  := SLG->LG_PORTMC7
	cCartMag   := SLG->LG_CARTMAG
	cPortMag   := SLG->LG_PORTMAG
	cBalanca   := SLG->LG_BALANCA
	cGaveta    := SLG->LG_GAVETA
	cPortGav   := SLG->LG_PORTGAV
	lGavStat   := SLG->LG_GAVSTAT
	If SLG->(ColumnPos("LG_PORTBAL"))>0
		cPortBal := SLG->LG_PORTBAL
	EndIf
	If SLG->(ColumnPos("LG_TIMEBAL"))>0
		nTimeOut := SLG->LG_TIMEBAL
	EndIf
	cDirBal    := SLG->LG_DIRBAL
	If lCMC7Dir
		cCMC7Dir    := SLG->LG_CMC7DIR
	EndIf 
	cImpTEF    := SLG->LG_IMPTEF
	cDisplay   := SLG->LG_DISPLAY
	cPortDis   := SLG->LG_PORTDIS     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Alimentando as variaveis para o Display Torre.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SLG->(ColumnPos("LG_DISPTOR"))>0
		cDispTorre := SLG->LG_DISPTOR
	EndIf	
	If SLG->(ColumnPos("LG_PORTTOR"))>0
		cPortTorre := SLG->LG_PORTTOR
	EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Alimentando as variaveis para o Touch screen  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If SLG->( ColumnPos("LG_TIPTELA") ) > 0
		nTipoTela := Val(SLG->LG_TIPTELA)
	EndIf           
	
	nImpTEFC   := If(SLG->LG_IMPTEFC="S", 1, 2)
	cTEFVias   := STR(SLG->LG_TEFVIAS,1)
	If Empty(SLG->LG_TIPTEF) .OR. Val(SLG->LG_TIPTEF) == 0
		nTipTef    := 1
	Else
		nTipTef    := Val(SLG->LG_TIPTEF)
	EndIf
	cDirTTX    := SLG->LG_DIRTTX
	cDirTRX    := SLG->LG_DIRTRX
	If SLG->(ColumnPos("LG_IPSITEF"))>0
		cIPSiTEF := SLG->LG_IPSITEF		// IP do Servidor SiTEF
	EndIf
	cTEFCons   := SLG->LG_TEFCONS
	cRPCSrv    := SLG->LG_RPCSRV
	cRPCPort   := SLG->LG_RPCPORT
	cRPCEnv    := SLG->LG_RPCENV
	cRPCEmp    := SLG->LG_RPCEmp
	cRPCFil    := SLG->LG_RPCFil
	nRPCInt    := SLG->LG_RPCINT
	cTSCSrv    := SLG->LG_TSCSRV
	cTSCPort   := SLG->LG_TSCPORT
	cJournal   := SLG->LG_JOURNAL
	lIntCns    := SLG->LG_INTCNS
	cDirOri    := SLG->LG_DIRORI
	cDirDes    := SLG->LG_DIRDES
	cDirExec   := SLG->LG_DIREXEC
	cRedeCns   := SLG->LG_REDECNS
	cLojaCns   := SLG->LG_LOJACNS
	cCtrCns    := SLG->LG_CTRCNS
	// Mensagem para impressao do cupom fiscal
	cMsgCup    := SLG->LG_MSGCUP
	cWebSvc    := SLG->LG_WSSRV
	If lWSSRVMT	
		cWebMtz    := SLG->LG_WSSRVMT
		lMtzOk     := !(Empty(cWebMtz))
	EndIf
	cCrdImp	   := RetSx3Box( Posicione("SX3", 2, PadR("LG_CRDIMP",10), "X3CBox()" ),,, 1 )[If(SLG->LG_CRDIMP="0".OR.Empty(SLG->LG_CRDIMP),1,Val(SLG->LG_CRDIMP)),3]
	nCrdVias   := SLG->LG_CRDVIAS
    cTipoEmp   := SLG->LG_TIPOATE
	cCrdXInt   := RetSx3Box( Posicione("SX3", 2, PadR("LG_CRDXINT",10), "X3CBox()" ),,, 1 )[If(SLG->LG_CRDXINT="2".OR.Empty(SLG->LG_CRDXINT),2,Val(SLG->LG_CRDXINT)),3]
	If SLG->(ColumnPos("LG_REDES")) > 0
		If (Substr(SLG->LG_REDES, 3, 1) == "0" .OR. Empty(Substr(SLG->LG_REDES, 3, 1)) .OR. Empty(SLG->LG_REDES)) // Recarga de celular
			lRecarga	:= .F.
		Else
			lRecarga	:= .T.
		EndIf		
	EndIf
	
	If SLG->(ColumnPos("LG_TAMSER"))>0	
		cTamSer     := SLG->LG_TAMSER	
	EndIf
	
	If SLG->(ColumnPos("LG_IMPCUFA")) > 0
		lChkTiFa := SLG->LG_IMPCUFA
	EndIf
	
	If SLG->(ColumnPos("LG_PVAUTNF")) > 0
		cChkPvNf := IIf(SLG->LG_PVAUTNF,"S","N")
	EndIf
	
	If lLG_CRECFPA
		cCredECF := SLG->LG_CRECFPA
	EndIf

	If cPaisLoc == "MEX"
		cCompany 	:= SLG->LG_COMPANY	// Companhia Centro de Pagos
		cUrlServ 	:= SLG->LG_SETURL	// Url Centro de Pagos
		cBranch  	:= SLG->LG_BRANCH	// Unid Centro de Pagos
		cContry 	:= SLG->LG_COUNTRY  	// Pais Centro de Pagos
		cMerchant 	:= SLG->LG_MERCHAN	// Nº Afiliação Centro de Pagos
		cUserCp    	:= SLG->LG_USERCP	// Usuario Centro de Pagos
		cPwsCp 		:= SLG->LG_PWDCP		// Senha Centro de Pagos
		cOpType 	:= SLG->LG_OPTYPE	// Tip Ope Centro de Pagos
		cCurrenc 	:= SLG->LG_CURRENC	// Moeda Centro de Pagos
		
		Do Case
			Case cCurrenc == "MXN"
				nCurrenc := 1      			
			Case cCurrenc == "USD"
				nCurrenc := 2
 		EndCase
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega as configurações TEF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oCfgTef:Carregar(SLG->LG_CODIGO,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao largura em colunas imp. ECF  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lDefColECF
		If Empty(SLG->LG_LARGCOL)
			nLargCol := IIf(Empty(nLargCol),NTAMMIN,nLargCol)
		Else
			nLargCol := SLG->LG_LARGCOL
		Endif
	Endif
	
	If lLG_IPIMPRD
		cIPImpRD := SLG->LG_IPIMPRD
	EndIf
Else
	
	// ****** Definicao largura em colunas imp. ECF *****	
	If lDefColECF
		nLargCol := IIf(Empty(nLargCol),NTAMMIN,nLargCol)
	Endif

	If lNomeRede
		cNomeRede :=  GetComputerName()
	EndIf

EndIf                        

//Carrega o conteudo da Serie do PDV - Hotelaria
cSerPdv := SLG->LG_SERPDV

lVar1      := Subs(cTEFCons, 1, 1) == "S"
lVar2      := Subs(cTEFCons, 2, 1) == "S"
lVar3      := Subs(cTEFCons, 3, 1) == "S"
lVar4      := Subs(cTEFCons, 4, 1) == "S"
lVar5      := Subs(cTEFCons, 5, 1) == "S"
lVar6      := Subs(cTEFCons, 6, 1) == "S"
lVar7      := Subs(cTEFCons, 7, 1) == "S"
lVar8      := Subs(cTEFCons, 8, 1) == "S"
cImpTEF    := If(cImpTEF = "F", STR0059, If( cImpTEF = "C", STR0060, STR0008))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variavel com a empresa que vai operar as transacoes TEF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTipoEmp   := If(cTipoEmp == "1",STR0107,If (cTipoEmp == "2",STR0108," ")) 

// Preparação do array das impressoras
// Alimenta uma string com o nome de todas as impressoras, separadas por virgulas.

AAdd(aTipImp,"1 - " + STR0010 + " " + STR0018) //"Não" "Fiscal"
AAdd(aTipImp,"2 - " + STR0018) //"Fiscal"

aImpFiscal := Lj121LIF(@cLista		, lPOS		, @aFabFiscal	, @aImpFTot,;
					 	cValidRec	, lMsgRec	)

//Carrega lista somente das impressoras não fiscais 7 param = .T.
aImpNotFisc := Lj121LIF(@cLista	, lPOS		, @aFabNotFisc	, @aImpFTot,;  
						 cValidRec	, lMsgRec	, .T.	)

//Retira impressoras não fiscais da lista de impressoras Fiscais
aImpFiscal := Lj121ImpFis()

//Retira impressoras não fiscais da lista de fabricantes de impressoras Fiscais
aFabFiscal := Lj121FabFis()

If Lj121IsFisc(cImpFisc)//Valida se eh impressora fiscal
	cTipImp := "2 - " + STR0018 // "Fiscal"
Else
	cTipImp := "1 - " + STR0010 + " " + STR0018 //"Não" "Fiscal"
EndIf	

Lj121TipImp(@aImpList)
	
// Preparação do array das impressoras de cheque
// Alimenta uma string com o nome de todas as impressoras, separadas por virgulas.
aImpChq := Lj121LChq(cLista, lPOS)
	
// Preparação do array das impressoras de cupom
// Alimenta uma string com o nome de todas as impressoras, separadas por virgulas.
aImpCup := Lj121LINF(@cLista, lPOS)

// Preparação do array dos CMC7s
// Alimenta uma string com o nome de todas os CMC7s, separados por virgulas.
aCMC7 := Lj121LCMC7(cLista, lPOS)
	
// Preparação do array dos PINPADs
// Alimenta uma string com o nome de todas os Pinpads, separados por virgulas.
aPinPad := Lj121LPinPad(@cLista, lPos)

aCartMag := AClone(aPinPad)

// Preparação do array dos Leitores
// Alimenta uma string com o nome de todas os leitores, separados por virgulas.
aLeitOpt := Lj121LLOpt(cLista, lPOS)

// Preparação do array das Balancas
// Alimenta uma string com o nome de todas as balancas, separadas por virgulas.
aBalanca := Lj121LBal(@cLista, lPOS)

// Preparação do array das GAVETAS
// Alimenta uma string com o nome de todas as gavetas, separadas por virgulas.
aGaveta := Lj121LGav(cLista, lPOS)

// Preparação do array dos Displays
// Alimenta uma string com o nome de todos os display, separados por virgulas.

aDisplay := Lj121LDis(cLista, lPOS)

//-----------------------------------------------------------------------------------
//³Preparação do array dos Displays Torre                                           ³
//³Alimenta uma string com o nome de todos os display torre, separados por virgulas.³
//-----------------------------------------------------------------------------------
aDispTorre := Lj121LTDis(cLista, lPOS)

//-----------------------------------------------------------------------
//³ Divide a tela horizontalmente para os objetos 						³
//-----------------------------------------------------------------------
aObjects := {}

AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo       := { aSize1[ 1 ], aSize1[ 2 ], aSize1[ 3 ], aSize1[ 4 ], 0, 0 }
aPosObj     := MsObjSize( aInfo, aObjects,  , .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela Principal   	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlgEst TITLE STR0011+' - '+cRot FROM aSize1[7],0 TO aSize1[6],aSize1[5] PIXEL // Estacao
DEFINE FONT oFnt0 NAME "Courier New"  SIZE 7,19	// Mensagem do Cupom Fiscal

@aPosObj[1,1] - 30, aPosObj[1,2] + 05 TO @aPosObj[1,1] + 260, aPosObj[1,2] + 505 PROMPT STR0012 PIXEL   // Estacao

@aPosObj[1,1] - 15, aPosObj[1,2] + 15 SAY STR0011 PIXEL SIZE 20,9 // Estacao
@aPosObj[1,1] - 14, aPosObj[1,2] + 55 MSGET oCodEst VAR cCodigo PIXEL SIZE 30,9 PICTURE PesqPict("SLG","LG_CODIGO") WHEN lFlagCod .AND. cTipo $ "AI" VALID IIf(lFlagCod,LJ121VD(cCodigo),.T.)

@aPosObj[1,1] 	, aPosObj[1,2] + 15 SAY STR0013 PIXEL SIZE 20,9      // Nome
@aPosObj[1,1] + 1, aPosObj[1,2] + 55 MSGET oNomeEst VAR cNome PIXEL SIZE 75,9 PICTURE "@!" VALID !Empty(cNome) WHEN cTipo $ "AI"


@aPosObj[1,1] - 15, aPosObj[1,2] + 150 SAY  STR0200 PIXEL SIZE 20,9      // "POS ?"
@aPosObj[1,1] - 14, aPosObj[1,2] + 190 COMBOBOX oIsPos ;
												VAR cIsPos ;
												ITEMS aIsPos ;
												WHEN (cTipo $ "IW") .OR. (cIsPos == "2") ;
												PIXEL SIZE 35,15

If lNomeRede	
	@aPosObj[1,1] 	 , aPosObj[1,2] + 150 SAY "Nome de rede" PIXEL // Nome de rede do dispositivo
	@aPosObj[1,1] + 1, aPosObj[1,2] + 190 MSGET oNomeRede VAR cNomeRede PIXEL SIZE 75,9 PICTURE "@!" WHEN cTipo $ "AI"
EndIf	

If lIntPOS  

	If SLG->(ColumnPos("LG_POSFLAG")) > 0
		aIntPos := StrTokArr( Posicione("SX3", 2, PadR("LG_POSFLAG",10), "X3CBox()" ), ";") 
	EndIf
	
	@aPosObj[1,1] + 30, aPosObj[1,2] + 150 SAY  STR0211 PIXEL SIZE 20,9      // "Int. Synthesis?"
	@aPosObj[1,1] + 29, aPosObj[1,2] + 173 COMBOBOX oIntPos ;
													VAR cIntPos ;
													ITEMS aIntPos ;
													PIXEL SIZE 30,20
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao do Folder    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFolder := TFolder():New(aPosObj[1,1] + 20,aPosObj[1,2] + 07,aPrompts[1], aPrompts[2],oDlgEst,,,, .T., .F.,aPosObj[1,2] + 495,aPosObj[1,1] + 155,)

// Folder 1 - Impressoras
nFolder:= Ascan(aFolder,"1")
If nFolder > 0

	If Len(aFabric)  > 0 
		//---------------------------------------------------------------
		//| ->Faz o tratamento para o estado de "MG" E "AM" para nao    |
		//| poder alterar a impressora fiscal depois de configurada.    |
		//| Foram incluidos os estados ES, MA e SC de acordo com legis- |
		//| lacao vigente em cada estado.                               |
		//| -> Quando tem liberação do Uso de PAF não permite o ECF		|
		//---------------------------------------------------------------
		If lNoPaf
			cImpFFab	:= ""
			aFabric		:= {}
		
		ElseIf !Empty( cImpFFab ) .AND. aLeg61[1]															
			aFabric  := { cImpFFab }																			
			If !lPafEcf
				aPortIf  := { cPortIf }    
			EndIf
		EndIf
		
		If lNoPaf
			cImpFMod	:= ""
			aModelo		:= {}
		
		ElseIf !Empty( cImpFMod ) .AND. aLeg61[1]															
			aModelo  := { cImpFMod }																			
			If !lPafEcf
				aPortIf  := { cPortIf }    
			EndIf
		EndIf
		
		nLinhas := IIf(cPaisLoc$"POR|EUA|ARG",10,0)
		
		@ aPosObj[1,1] - 25,aPosObj[1,2] + 07 TO aPosObj[1,1] + IIf(lLG_IPIMPRD,85,IIf(cPaisLoc$"POR|EUA|ARG",80,65)),;
										aPosObj[1,2] + 133 PROMPT STR0018 PIXEL OF oFolder:aDialogs[nFolder]  // Fiscal
										
		If cPaisLoc == "ARG" .AND. SLG->(ColumnPos("LG_IMPCUFA")) > 0
			@ aPosObj[1,1] - 18,aPosObj[1,2] + 10	CHECKBOX oChkTiFa ;
													VAR lChkTiFa PROMPT STR0162 ;
													SIZE 104, 50 ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL ;                        // Imprime Cupom e Fatura
													WHEN cTipo $ "AI"
		EndIf
			
		@ aPosObj[1,1] - (18 - nLinhas),aPosObj[1,2] + 10 SAY STR0225 PIXEL OF oFolder:aDialogs[nFolder]  // "Tipo de Impressora
		@ aPosObj[1,1] - (11 - nLinhas),aPosObj[1,2] + 10 COMBOBOX oTipImp VAR cTipImp ITEMS aTipImp ;
		  ON CHANGE ( 	Lj121TipImp(aImpList,cImpFFab) , ;
		    			LJImpModelo(@aImpList , @cImpFFab  , @aModelo , @oImpFMod , ; 
								    @cTipo    , @cImpFMod , @cAltFMod ) ) ;
	      WHEN cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 50,50
		
		@ aPosObj[1,1] - (18 - nLinhas),aPosObj[1,2] + 62 SAY STR0158 PIXEL OF oFolder:aDialogs[nFolder]                     // Fabricante

		@ aPosObj[1,1] - (11 - nLinhas),aPosObj[1,2] + 62 COMBOBOX oImpFFab VAR cImpFFab ITEMS aFabric ;
											  ON CHANGE ( LJImpModelo(@aImpList , @cImpFFab  , @aModelo , @oImpFMod , ; 
											                          @cTipo    , @cImpFMod , @cAltFMod ), ;
											  			  LJ120VD2("IF" , cImpFFab , @cPortIF , oPortIF , ;
											  			  		   StrTran(StrTran(STR0014,"&",""),"&","")+ " - "+STR0018 , cImpChq , oImpChq , cPortChq , ;
											  			  		   oPortChq ) ) ;
		                                      WHEN cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 71,50  
		oImpFFab:bGotFocus := {|| If(	lNoPaf,MsgAlert(STR0207),; //'CNPJ não pode habilitar uso de ECF por não estar liberado ao uso de PAF-ECF! Verifique!'
										If(!Empty(cImpFFab) .AND. aLeg61[1], LjMsgLeg(aLeg61), ))}

		@ aPosObj[1,1] + 5 + nLinhas,aPosObj[1,2] + 10 SAY STR0019 PIXEL OF oFolder:aDialogs[nFolder]                     // Modelo
		@ aPosObj[1,1] + 14 + nLinhas,aPosObj[1,2] + 10 COMBOBOX oImpFMod VAR cImpFMod ITEMS aModelo ;
											  ON CHANGE ( LJGeraNome(@cImpFisc , @cImpFMod , @cTipo), Lj121USBFiltro(@aPortIf, cImpFMod, @oPortIf) );
											  WHEN cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 123,50 
		oImpFMod:bGotFocus := {||	If(	lNoPaf,MsgAlert(STR0207),; //'CNPJ não pode habilitar uso de ECF por não estar liberado ao uso de PAF-ECF! Verifique!'
									If(!Empty(cImpFMod) .AND. aLeg61[1], LjMsgLeg(aLeg61), ))}
		
		If cPaisLoc == "ARG" 
			If SLG->(ColumnPos("LG_PVAUTNF")) > 0
				@ aPosObj[1,1] + 32 + nLinhas,aPosObj[1,2] + 10 SAY STR0164 PIXEL SIZE 65,18 OF oFolder:aDialogs[nFolder]    		 // PDV autorizado a emitir nota fiscal
				@ aPosObj[1,1] + 32 + nLinhas,aPosObj[1,2] + 90 COMBOBOX oChkPvNf VAR cChkPvNf ITEMS {"S","N"} ;
				 	ON CHANGE LjValPVAut(LG_CODIGO,@oChkPvNf,@cChkPvNf) WHEN cTipo $ "AI" .AND. RetCodUsr()=="000000" PIXEL SIZE 28,50 OF oFolder:aDialogs[nFolder]
			EndIf
		
		
			If SLG->(ColumnPos("LG_TKTFACT")) > 0
				@ aPosObj[1,1] + 32 + nLinhas,aPosObj[1,2] + 10 SAY STR0171 PIXEL SIZE 65,18 OF oFolder:aDialogs[nFolder]    		 // PDV imprime ticket
				@ aPosObj[1,1] + 32 + nLinhas,aPosObj[1,2] + 90 COMBOBOX oRecTktFat VAR cRecTktFat ITEMS {"Ticket", "Factura"} ;
				 	ON CHANGE LjValTktFat(@oRecTktFat, @cRecTktFat) WHEN cTipo $ "AI" .AND. RetCodUsr()=="000000" PIXEL SIZE 28,50 OF oFolder:aDialogs[nFolder]
			EndIf
			
			nLinhas += 7
		EndIf
		
		@ aPosObj[1,1] + 41 + nLinhas,aPosObj[1,2] + 10 SAY STR0091 OF oFolder:aDialogs[nFolder] PIXEL SIZE 20,9			 // PDV
		@ aPosObj[1,1] + 48 + nLinhas,aPosObj[1,2] + 10 MSGET oPDV VAR cPDV OF oFolder:aDialogs[nFolder] PIXEL SIZE 20,9 ;
										PICTURE PesqPict("SLG","LG_PDV") WHEN If(aLeg61[1].AND.!Empty(cPDV),.F.,If(Empty(cImpFisc),(cPDV:=Space(Len(cPdv)),.F.),.T.) .AND. cTipo $ "AI")
		
		@ aPosObj[1,1] + 41 + nLinhas,aPosObj[1,2] + 31 SAY STR0076 OF oFolder:aDialogs[nFolder] PIXEL SIZE 20,9 			 // Serie
		@ aPosObj[1,1] + 48 + nLinhas,aPosObj[1,2] + 31 MSGET oSerie VAR cSerie OF oFolder:aDialogs[nFolder] PIXEL SIZE 15,9 PICTURE "@!" VALID LjSL6Vld(cSerie, cCodigo) WHEN Lj121VlSer(cImpFisc, cSerie, cTipo)
		
		@ aPosObj[1,1] + 41 + nLinhas,aPosObj[1,2] + 51 SAY "Ser.CNF" OF oFolder:aDialogs[nFolder] PIXEL SIZE 20,9	// Serie Comprovante Nao Fiscal
		@ aPosObj[1,1] + 48 + nLinhas,aPosObj[1,2] + 53 MSGET oSerieCNF VAR M->LG_SERNFIS OF oFolder:aDialogs[nFolder] PIXEL SIZE 15,9 PICTURE "@!" WHEN lSerieCNF .AND. IIf(Empty(cImpFisc),(M->LG_SERNFIS := Space(Len(M->LG_SERNFIS)),.F.),.T.) .AND. cTipo $ "AI"

		@ aPosObj[1,1] + 41 + nLinhas,aPosObj[1,2] + 74 SAY STR0113  OF oFolder:aDialogs[nFolder] PIXEL SIZE 23,9 		 // Tamanho do C00
		@ aPosObj[1,1] + 48 + nLinhas,aPosObj[1,2] + 74 MSGET oTamSer VAR cTamSer OF oFolder:aDialogs[nFolder] PIXEL SIZE 25,9 PICTURE "@!" WHEN If(Empty(cImpFisc),(cTamSer:=Space(Len(cTamSer)),.F.),.T.) .AND. cTipo $ "AI"
		
		@ aPosObj[1,1] + 41 + nLinhas,aPosObj[1,2] + 100 SAY STR0020 PIXEL SIZE 25,18 OF oFolder:aDialogs[nFolder]    		 // Porta
		@ aPosObj[1,1] + 48 + nLinhas,aPosObj[1,2] + 100 COMBOBOX oPortIf VAR cPortIf ITEMS aPortIf ;
							VALID LJ120VD2("PIF",cImpFisc,@cPortIF,oPortIF,StrTran(STR0014,"&","")+" - "+(STR0018),;
							@cImpChq,oImpChq,@cPortChq,oPortChq ) .And. If(AllTrim(cPortIF) == "REDE",.T.,(cIPImpRD := Space(Len(cIPImpRD)),.T.)) WHEN;
							If(Empty(cImpFisc),(cPortIF:=Space(Len(cPortIf)),.F.),.T.) .AND. cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 33,15
		
		If lLG_IPIMPRD
			@ aPosObj[1,1] + 61 + nLinhas,aPosObj[1,2] + 10 SAY STR0257 OF oFolder:aDialogs[nFolder] PIXEL SIZE 60,9			 //"IP Impressora Rede" 
			@ aPosObj[1,1] + 68 + nLinhas,aPosObj[1,2] + 10 MSGET oIPImpRD VAR cIPImpRD OF oFolder:aDialogs[nFolder] PIXEL SIZE 60,9 PICTURE PesqPict("SLG","LG_IPIMPRD") ;
							WHEN If(!Empty(cIPImpRD),.T.,If(Empty(cIPImpRD),(cIPImpRD := Space(Len(cIPImpRD)),.T.),.T.) .AND.;
							If(AllTrim(cPortIF) == "REDE",.T.,(cIPImpRD := Space(Len(cIPImpRD)),.F.)) .AND. (cTipo $ "AI"))
			
			nLinhas += 18
		EndIf
		
		If !lPafEcf
			oPortIF:bGotFocus := {|| If (!Empty(cPortIF) .AND. aLeg61[1], LjMsgLeg(aLeg61), )}
		EndIf
		
		If cPaisLoc $ "POR|EUA"
			@ aPosObj[1,1] + 60 + nLinhas,aPosObj[1,2] + 15 SAY STR0088 PIXEL SIZE 103,18 OF oFolder:aDialogs[nFolder]	 // "Path e arquivo para gravação do cupom"
			@ aPosObj[1,1] + 66 + nLinhas,aPosObj[1,2] + 15 MSGET oJournal VAR cJournal PICTURE PesqPict("SLG","LG_JOURNAL") ;
										PIXEL SIZE 103,09 OF oFolder:aDialogs[nFolder] WHEN If(Empty(cImpFisc),(cJournal:=Space(Len(cJournal)),.F.),.T.)			
		EndIf
		
		@ aPosObj[1,1] + 55,aPosObj[1,2] + 135 TO aPosObj[1,1] + 100,aPosObj[1,2] + 253 PROMPT STR0101 PIXEL OF oFolder:aDialogs[1] 	// 'Mensagem no Cupom Fiscal'
		@ aPosObj[1,1] + 65,aPosObj[1,2] + 145 GET oMsgCup VAR cMsgCup FONT oFnt0 OF oFolder:aDialogs[1] MEMO SIZE 100,29  PIXEL 		// 160
	EndIf
	
	nLinhas -= Iif(cPaisLoc$"POR|EUA|ARG",3,0)
	
	/* TERMINAL SERVICES CLIENT */
	@ If(cPaisLoc$"POR|EUA|ARG" , aPosObj[1,1]+ 80 + nLinhas , aPosObj[1,1]+70 + nLinhas) , aPosObj[1,2]+ 07;
	 		TO If(cPaisLoc$"POR|EUA|ARG" , aPosObj[1,1]+110 + nLinhas , aPosObj[1,1] + 100 + nLinhas) , ;
	 		aPosObj[1,2]+125 PROMPT "Terminal Services Client" PIXEL OF oFolder:aDialogs[nFolder]                 		

	@ If(cPaisLoc$"POR|EUA|ARG" , aPosObj[1,1]+87 + nLinhas , aPosObj[1,1]+77 + nLinhas) ,;
	 		aPosObj[1,2]+ 15 SAY STR0063 PIXEL SIZE 40,18 OF oFolder:aDialogs[nFolder]    // "Numero do IP"																								
	@ If(cPaisLoc$"POR|EUA|ARG" , aPosObj[1,1]+95 + nLinhas , aPosObj[1,1]+85 + nLinhas) ,;
	 		aPosObj[1,2]+ 15 MSGET oTSCSrv VAR cTSCSrv PICTURE "@!" OF oFolder:aDialogs[nFolder] PIXEL SIZE 60,09 WHEN cTipo $ "AI"																		
	
	@ If(cPaisLoc$"POR|EUA|ARG" , aPosObj[1,1]+87 + nLinhas , aPosObj[1,1]+77 + nLinhas) ,;
	 		aPosObj[1,2]+ 80 SAY STR0064 PIXEL SIZE 20,18 OF oFolder:aDialogs[nFolder]    // "Porta"                                                                                                       
	@ If(cPaisLoc$"POR|EUA|ARG" , aPosObj[1,1]+95 + nLinhas , aPosObj[1,1]+85 + nLinhas) ,;
	 		aPosObj[1,2]+ 80 MSGET oTSCPort VAR cTSCPort PICTURE "@!" OF oFolder:aDialogs[nFolder];
	 		PIXEL SIZE 20,09 WHEN If(Empty(cTSCSrv),(cTSCPort:=Space(Len(cTSCPort)),.F.),.T.) .AND. cTipo $ "AI" 	
	
	If Len(aImpChq) > 0
		
		@ aPosObj[1,1] - 25,aPosObj[1,2] + 135 TO aPosObj[1,1] + 10,aPosObj[1,2] + 253 PROMPT STR0021 PIXEL OF oFolder:aDialogs[nFolder] // Cheque
		@ aPosObj[1,1] - 18,aPosObj[1,2] + 143 SAY STR0019 PIXEL SIZE 40,18 OF oFolder:aDialogs[nFolder]         // Modelo
		@ aPosObj[1,1] - 11,aPosObj[1,2] + 143 COMBOBOX oImpchq VAR cImpChq ITEMS aImpChq ON;
		 	CHANGE LJ120VD2("ICHQ",cImpChq,@cPortChq,oPortChq,,@cImpFisc,oImpFisc,@cPortIF,oPortIf ) WHEN cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 70,15
		
		@ aPosObj[1,1] - 18,aPosObj[1,2] + 218 SAY STR0020 PIXEL SIZE 25,18 OF oFolder:aDialogs[nFolder]         // Porta
		@ aPosObj[1,1] - 11,aPosObj[1,2] + 218 COMBOBOX oPortChq VAR cPortChq ITEMS aPortChq ;
			VALID LJ120VD2("PCHQ",cImpChq,@cPortChq,oPortChq,StrTran(STR0014,"&","")+	" - "+(STR0021),@cImpFisc,oImpFisc,@cPortIF,oPortIf );
			WHEN If(Empty(cImpChq),(cPortChq:=Space(Len(cPortChq)),.F.),.T.) .AND. cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 33,15
		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o tratamento para o estado de "MG" e "AM"               ³
	//³ poder configurar impressora de cupom depois de selecionada  ³
	//³ uma impressora fiscal.                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(aLeg61[1]) .OR. (Empty( cImpFisc ) .AND. aLeg61[1])
	
		If Len(aImpCup) > 0
			
			@ aPosObj[1,1] + 15,aPosObj[1,2] + 135 TO aPosObj[1,1] + 50,aPosObj[1,2] + 253 PROMPT STR0022 PIXEL OF oFolder:aDialogs[nFolder] // Cupom
			@ aPosObj[1,1] + 22,aPosObj[1,2] + 143 SAY STR0019 PIXEL SIZE 40,18 OF oFolder:aDialogs[nFolder]    // Modelo
			@ aPosObj[1,1] + 30,aPosObj[1,2] + 143 COMBOBOX oImpCup VAR cImpCup ITEMS aImpCup VALID LJ120VD2("IMP",cImpCup,@cPortICP,oPortICP) WHEN cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 70,15
			
			@ aPosObj[1,1] + 22,aPosObj[1,2] + 218 SAY STR0020 PIXEL SIZE 25,18 OF oFolder:aDialogs[nFolder]   // Porta
			@ aPosObj[1,1] + 30,aPosObj[1,2] + 218 COMBOBOX oPortICP VAR cPortICP ITEMS aPortICP VALID LJ120VD2("POR",cImpCup,cPortICP,,StrTran(STR0014,"&","")+" - "+(STR0022)) WHEN If(Empty(cImpCup),(cPortICP:=Space(Len(cPortICP)),.F.),.T.) .AND. cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 33,15
			
		EndIf
	EndIf	
	
	/*Definicao largura em colunas imp. ECF*/
	If lDefColECF
		tGroup():New(aPosObj[1,1] - 25,aPosObj[1,2] + 268,aPosObj[1,1] + 10,aPosObj[1,2] + 386,STR0172,oFolder:aDialogs[nFolder],,,.T.) //"Def. de colunas de impressão ECF"
		tSay():New(aPosObj[1,1] - 18 ,aPosObj[1,2] + 276,{||RetTitle("LG_LARGCOL")},oFolder:aDialogs[nFolder],/*pict*/,/*fonte*/,,,,.T.,,,040,018)
		oLargCol := tGet():New(aPosObj[1,1] - 11,aPosObj[1,2] + 276,{|x| IIf(PCount() > 0,nLargCol := x,nLargCol)},oFolder:aDialogs[nFolder],040,010,,;
			{|| Lj120VldLC(nLargCol)},,,/*font*/,,,.T.,,,{|| .T.},,,,.F.,.F.,,"nLargCol")
	Endif
	
	If lPafEcf .And. lLG_CRECFPA
		@ aPosObj[1,1] + 15,aPosObj[1,2] + 268 TO aPosObj[1,1] + 50,aPosObj[1,2] + 386 PROMPT "Credenciamento do ECF - SEFAZ" PIXEL OF oFolder:aDialogs[nFolder]
		@ aPosObj[1,1] + 22,aPosObj[1,2] + 276 SAY "Numero do Credenciamento" PIXEL SIZE 110,18 OF oFolder:aDialogs[nFolder]
		@ aPosObj[1,1] + 30,aPosObj[1,2] + 276 MSGET oCredECF VAR cCredECF PICTURE "@!" OF oFolder:aDialogs[nFolder] PIXEL SIZE 60,09
	EndIf
EndIf

// Folder 2 - Leitores
nFolder:= Ascan(aFolder,"2")
If (nFolder > 0)
	If Len(aLeitOpt) > 0
		
		@ aPosObj[1,1] - 25,aPosObj[1,2] + 07 TO aPosObj[1,1] + 10,aPosObj[1,2] + 125 PROMPT STR0023 PIXEL OF oFolder:aDialogs[nFolder] // Opticos Emulador de Teclado
		@ aPosObj[1,1] - 18,aPosObj[1,2] + 15 SAY STR0019 PIXEL SIZE 40,18 OF oFolder:aDialogs[nFolder]   // Modelo
		@ aPosObj[1,1] - 11,aPosObj[1,2] + 15 COMBOBOX oLeitOpt VAR cOptico ITEMS aLeitOpt ON CHANGE LJ120VD2("IMP",cOptico,@cPortOpt,oPortOpt) WHEN cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 70,15
		
		@ aPosObj[1,1] - 18,aPosObj[1,2] + 90 SAY STR0020 PIXEL SIZE 25,18 OF oFolder:aDialogs[nFolder]   // Porta
		@ aPosObj[1,1] - 11,aPosObj[1,2] + 90 COMBOBOX oPortOpt VAR cPortOpt ITEMS aPortOpt VALID LJ120VD2("PORL",cOptico,cPortOpt,,StrTran(STR0015,"&","")+" - "+(STR0023)) WHEN If(Empty(cOptico),(cPortOpt:=Space(Len(cPortOpt)),.F.),.T.) .AND. cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 33,15
		
	EndIf
	
	If Len(aCMC7) > 0
		
		@ aPosObj[1,1] - 25,aPosObj[1,2] + 135 TO aPosObj[1,1] + 10,aPosObj[1,2] + 253 PROMPT STR0025 PIXEL OF oFolder:aDialogs[nFolder] // CMC7
		@ aPosObj[1,1] - 18,aPosObj[1,2] + 143 SAY STR0019 PIXEL SIZE 40,18 OF oFolder:aDialogs[nFolder]   // Modelo
		@ aPosObj[1,1] - 11,aPosObj[1,2] + 143 COMBOBOX oCMC7 VAR cCMC7 ITEMS aCMC7 ON CHANGE LJ120VD2("IMP",cCMC7,@cPortCMC7,oPortMC7) WHEN cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 70,15
		
		@ aPosObj[1,1] - 18,aPosObj[1,2] + 218 SAY STR0020 PIXEL SIZE 20,18 OF oFolder:aDialogs[nFolder]   // Porta
		@ aPosObj[1,1] - 11,aPosObj[1,2] + 218 COMBOBOX oPortMC7 VAR cPortCMC7 ITEMS aPortCMC7 VALID LJ120VD2("POR",cCMC7,cPortCMC7,,StrTran(STR0015,"&","")+" - "+(STR0025)) WHEN If(Empty(cCMC7),(cPortCMC7:=Space(Len(cPortCMC7)),.F.),.T.) .AND. cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 33,15
	EndIf
		
	If Len(aPinPad) > 0
		
		@ aPosObj[1,1] + 15,aPosObj[1,2] + 07 TO aPosObj[1,1] + 75,aPosObj[1,2] + 125 PROMPT STR0024 PIXEL OF oFolder:aDialogs[nFolder] // PinPad
		@ aPosObj[1,1] + 22,aPosObj[1,2] + 15  SAY STR0019 PIXEL SIZE 40,18 OF oFolder:aDialogs[nFolder]   // Modelo
		@ aPosObj[1,1] + 30,aPosObj[1,2] + 15  COMBOBOX oPinPad VAR cPinPad ITEMS aPinPad ON CHANGE LJ120VD2("IMP",cPinPad,@cPortPad,oPortPad)WHEN cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 70,15
		
		@ aPosObj[1,1] + 20,aPosObj[1,2] + 90  SAY STR0020 PIXEL SIZE 25,18 OF oFolder:aDialogs[nFolder]   // Porta
		@ aPosObj[1,1] + 30,aPosObj[1,2] + 90  COMBOBOX oPortPad VAR cPortPad ITEMS aPortPad  VALID LJ120VD2("POR",cPinPad,cPortPad,,StrTran(STR0015,"&","")+" - "+(STR0024)) WHEN If(Empty(cPinPad),(cPortPad:=Space(Len(cPortPad)),.F.),.T.) .AND. cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 33,15
		
		@ aPosObj[1,1] + 45,aPosObj[1,2] + 15 SAY STR0047 PIXEL SIZE 80,18 OF oFolder:aDialogs[nFolder]    // Mensagem do Visor
		@ aPosObj[1,1] + 55,aPosObj[1,2] + 15 MSGET oPadMsg VAR cPadMsg PICTURE "@!" WHEN If(Empty(cPinPad),(cPadMsg:=Space(Len(cPadMsg)),.F.),.T.) .AND. cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 100,09
		
	EndIf
	
	If Len(aCartMag) > 0
		
		@ aPosObj[1,1] + 15,aPosObj[1,2] + 135 TO aPosObj[1,1] + 50,aPosObj[1,2] + 253 PROMPT STR0026 PIXEL OF oFolder:aDialogs[nFolder] // Cartao Magnetico
		@ aPosObj[1,1] + 22,aPosObj[1,2] + 143 SAY STR0019 PIXEL SIZE 40,18 OF oFolder:aDialogs[nFolder]   // Modelo
		@ aPosObj[1,1] + 30,aPosObj[1,2] + 143 COMBOBOX oCartMag VAR cCartMag ITEMS aCartMag ON CHANGE LJ120VD2("IMP",cCartMag,@cPortMag,oPortMag) WHEN cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 70,15
		
		@ aPosObj[1,1] + 20,aPosObj[1,2] + 218 SAY STR0020 PIXEL SIZE 25,18 OF oFolder:aDialogs[nFolder]   // Porta
		@ aPosObj[1,1] + 30,aPosObj[1,2] + 218 COMBOBOX oPortMag VAR cPortMag ITEMS aPortMag  VALID LJ120VD2("POR",cCartMag,cPortMag,,StrTran(STR0015,"&","")+" - "+(STR0026)) WHEN If(Empty(cCartMag),(cPortMag:=Space(Len(cPortMag)),.F.),.T.) .AND. cTipo $ "AI" OF oFolder:aDialogs[nFolder] PIXEL SIZE 33,15
	EndIf
	
	If lCMC7Dir
		@ aPosObj[1,1] + 55 ,aPosObj[1,2] + 135 TO aPosObj[1,1] + 90,aPosObj[1,2] + 253 PROMPT STR0191 		PIXEL OF oFolder:aDialogs[nFolder] // CMC7 Direto
		@ aPosObj[1,1] + 60 ,aPosObj[1,2] + 143 SAY STR0191						OF oFolder:aDialogs[nFolder] 	PIXEL SIZE 40,18                    // CMC7 Direto
		@ aPosObj[1,1] + 70 ,aPosObj[1,2] + 143 COMBOBOX oCMC7Dir  VAR cCMC7Dir OF oFolder:aDialogs[nFolder] 	PIXEL SIZE 70,50 ITEMS aCMC7Dir ON CHANGE .T. WHEN If(!Empty(cCMC7),(cCMC7Dir:=Space(Len(cCMC7Dir)),.F.),.T.) .AND. cTipo $ "AI"
	EndIf
EndIf

// Folder 3 - Outros
nFolder:= Ascan(aFolder,"3")
If (nFolder > 0)
	If Len(aBalanca) > 0
		If SLG->(ColumnPos("LG_PORTBAL")) > 0 .AND. SLG->(ColumnPos("LG_TIMEBAL")) > 0

			@ aPosObj[1,1] - 25,aPosObj[1,2] + 07   TO aPosObj[1,1] + 60,aPosObj[1,2] + 120 PROMPT STR0027 ;
													PIXEL OF oFolder:aDialogs[nFolder]  // Balanca
													
			@ aPosObj[1,1] - 18,aPosObj[1,2] + 15	SAY STR0019 ;
													PIXEL SIZE 40,18 ;
													OF oFolder:aDialogs[nFolder]    // Modelo
													
			@ aPosObj[1,1] - 11,aPosObj[1,2] + 15 	COMBOBOX oBalanca ;
													VAR cBalanca ;
													ITEMS aBalanca ;
													ON CHANGE LJ120VD2("IMP", cBalanca, @cDirBal, oDirBal) ;
													WHEN cTipo $ "AI" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 95,15
			
			@ aPosObj[1,1] + 5 ,aPosObj[1,2] + 15 	SAY STR0043 ;
													PIXEL SIZE 40,18 ;
													OF oFolder:aDialogs[nFolder]   // Diretorio
													
			@ aPosObj[1,1] + 15,aPosObj[1,2] + 15 	MSGET oDirBal ;
													VAR cDirBal ;
													PICTURE "@!" ;
													WHEN ( If(Empty(cBalanca),(cDirBal:=Space(Len(cDirBal)),.F.),.T.) .OR. Empty(cPortBal)) .AND. cTipo $ "AI" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 95,09

			@ aPosObj[1,1] + 30,aPosObj[1,2] + 15 	SAY STR0020 ;
													PIXEL SIZE 40,18 ;
													OF oFolder:aDialogs[nFolder]    // Porta
			
			@ aPosObj[1,1] + 40,aPosObj[1,2] + 15 	COMBOBOX oPortBal ;
													VAR cPortBal ;
													ITEMS aPortBal ;
													VALID .T. ;
													PIXEL OF oFolder:aDialogs[nFolder] ;
													SIZE 33,15
		
			@ aPosObj[1,1] + 30,aPosObj[1,2] + 82 	SAY STR0111 ;
													PIXEL SIZE 40,18 ;
													OF oFolder:aDialogs[nFolder]//"TimeOut"
			@ aPosObj[1,1] + 40,aPosObj[1,2] + 82 	MSGET oTimeOut ;
													VAR nTimeOut ;
													PICTURE "9999" ;
													PIXEL OF oFolder:aDialogs[nFolder] ;
													VALID nTimeOut >= 0 ;
													SIZE 28,09
		Else
			@ aPosObj[1,1] - 25,aPosObj[1,2] + 07	TO aPosObj[1,1] + 35,aPosObj[1,2] + 120 PROMPT STR0027 ;
													PIXEL OF oFolder:aDialogs[nFolder]  // Balanca
													
			@ aPosObj[1,1] - 18,aPosObj[1,2] + 15 	SAY STR0019 ;
													PIXEL SIZE 40,18 ;
													OF oFolder:aDialogs[nFolder]    // Modelo
												
			@ aPosObj[1,1] - 11,aPosObj[1,2] + 15 	COMBOBOX oBalanca ;
													VAR cBalanca ;
													ITEMS aBalanca ;
													ON CHANGE LJ120VD2("IMP", cBalanca,@cDirBal,oDirBal) ;
													WHEN cTipo $ "AI" OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 95,15
			
			@ aPosObj[1,1] + 5 ,aPosObj[1,2] + 15 	SAY STR0043 ;
													PIXEL SIZE 40,18 ;
													OF oFolder:aDialogs[nFolder]   // Diretorio
													
			@ aPosObj[1,1] + 15,aPosObj[1,2] + 15 	MSGET oDirBal ;
													VAR cDirBal ;
													PICTURE "@!" ;
													WHEN If(Empty(cBalanca),(cDirBal:=Space(Len(cDirBal)),.F.),.T.) .AND. cTipo $ "AI" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 95,09
		EndIf
	EndIf
	
	If Len(aGaveta) > 0
		If SLG->(ColumnPos("LG_PORTBAL")) > 0 .AND. SLG->(ColumnPos("LG_TIMEBAL")) > 0
			@ aPosObj[1,1] + 70,aPosObj[1,2] + 10	SAY STR0019 ;
													PIXEL SIZE 40,18 ;
													OF oFolder:aDialogs[nFolder]    // Modelo
													
			@ aPosObj[1,1] + 80,aPosObj[1,2] + 10	COMBOBOX oGaveta ;
													VAR cGaveta ;
													ITEMS aGaveta ;
													ON CHANGE LJ120VD2("IMP",cGaveta,@cPortGav,oPortGav) ;
													WHEN cTipo $ "AI" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 70,15
			
			@ aPosObj[1,1] + 70,aPosObj[1,2] + 85	SAY STR0020 ;
													PIXEL SIZE 25,18 ;
													OF oFolder:aDialogs[nFolder]    // Porta
													
			@ aPosObj[1,1] + 80,aPosObj[1,2] + 85	COMBOBOX oPortGav ;
													VAR cPortGav ;
													ITEMS aPortGav ;
													VALID LJ120VD2("POR",cGaveta,cPortGav,,STR0046) ;
													WHEN If(Empty(cGaveta),(cPortGav:=Space(Len(cPortGav)),.F.),.T.) .AND. cTipo $ "AI" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 33,15
			
			If SLG->(ColumnPos("LG_GAVSTAT")) > 0
				@ aPosObj[1,1] + 61,aPosObj[1,2]  + 07	TO aPosObj[1,1] + 105,aPosObj[1,2] + 120 PROMPT STR0046 ;
														PIXEL OF oFolder:aDialogs[nFolder]  // Gaveta
														
				@ aPosObj[1,1] + 95,aPosObj[1,2] + 10	CHECKBOX oGavStat ;
														VAR lGavStat PROMPT STR0100 ;
														SIZE 100,10 ;
														WHEN If(Empty(cGaveta),(lGavStat:=.F.,.F.),.T.) .AND. cTipo $ "AI" ;
														OF oFolder:aDialogs[nFolder] ;
														PIXEL	//"Controla o status da gaveta ?"
			Else
				@ aPosObj[1,1] + 67,aPosObj[1,2] + 07 TO aPosObj[1,1] + 133,aPosObj[1,2] + 125 PROMPT STR0046 PIXEL OF oFolder:aDialogs[nFolder]  // Gaveta
			EndIf
		Else
			@ aPosObj[1,1] + 40,aPosObj[1,2] + 10	SAY STR0019 ;
													PIXEL SIZE 40,18 ;
													OF oFolder:aDialogs[nFolder]    // Modelo
													
			@ aPosObj[1,1] + 50,aPosObj[1,2] + 10 	COMBOBOX oGaveta ;
													VAR cGaveta ;
													ITEMS aGaveta ;
													ON CHANGE LJ120VD2("IMP",cGaveta,@cPortGav,oPortGav) ;
													WHEN cTipo $ "AI" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 70,15
			
			@ aPosObj[1,1] + 40,aPosObj[1,2] + 85 	SAY STR0020 ;
													PIXEL SIZE 25,18 ;
													OF oFolder:aDialogs[nFolder]    // Porta
													
			@ aPosObj[1,1] + 50,aPosObj[1,2] + 85 	COMBOBOX oPortGav ;
													VAR cPortGav ;
													ITEMS aPortGav ;
													VALID LJ120VD2("POR",cGaveta,cPortGav,,STR0046) ;
													WHEN If(Empty(cGaveta),(cPortGav:=Space(Len(cPortGav)),.F.),.T.) .AND. cTipo $ "AI" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 33,15
			
			If SLG->(ColumnPos("LG_GAVSTAT")) > 0
				@ aPosObj[1,1] + 35,aPosObj[1,2] + 07 	TO aPosObj[1,1] + 121,aPosObj[1,2] + 125 PROMPT STR0046 ;
														PIXEL OF oFolder:aDialogs[nFolder]  // Gaveta
				
				@ aPosObj[1,1] + 70,aPosObj[1,2] + 15	CHECKBOX oGavStat ;
														VAR lGavStat PROMPT STR0100 ;
														SIZE 100,10 ;
														WHEN If(Empty(cGaveta),(lGavStat:=.F.,.F.),.T.) .AND. cTipo $ "AI" ;
														OF oFolder:aDialogs[nFolder] ;
														PIXEL	//"Controla o status da gaveta ?"
			Else
				@ aPosObj[1,1] + 35,aPosObj[1,2] + 07 	TO aPosObj[1,1] + 100,aPosObj[1,2] + 125 PROMPT STR0046 ;
														PIXEL OF oFolder:aDialogs[nFolder]  // Gaveta
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄ¿
	//³Display³
	//ÀÄÄÄÄÄÄÄÙ
	If Len(aDisplay) > 0
		@ aPosObj[1,1] -25 ,aPosObj[1,2] + 135	TO aPosObj[1,1] + 10 ,aPosObj[1,2] + 253 PROMPT STR0090 ;
												PIXEL OF oFolder:aDialogs[nFolder] // Display
												
		@ aPosObj[1,1] -18 ,aPosObj[1,2] + 143 SAY STR0019 ;
												PIXEL SIZE 40,18 ;
												OF oFolder:aDialogs[nFolder]   // Modelo
												
		@ aPosObj[1,1] -10 ,aPosObj[1,2] + 143	COMBOBOX oDisplay ;
												VAR cDisplay ;
												ITEMS aDisplay ;
												ON CHANGE LJ120VD2("IMP",cDisplay,@cPortDis,oPortDis) ;
												WHEN cTipo $ "AI" ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL SIZE 70,15
								
		@ aPosObj[1,1] - 18,aPosObj[1,2] + 218 SAY STR0020 ;
												PIXEL SIZE 20,18 ;
												OF oFolder:aDialogs[nFolder]   // Porta
												
		@ aPosObj[1,1] - 10,aPosObj[1,2] + 218	COMBOBOX oPortDis ;
												VAR cPortDis ;
												ITEMS aPortCMC7 ;
												VALID LJ120VD2("POR",cDisplay,cPortDis,,STR0090) ;
												WHEN If(Empty(cDisplay),(cPortDis:=Space(Len(cPortDis)),.F.),.T.) .AND. cTipo $ "AI" ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL SIZE 33,15
	EndIf

   
	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Interface³
	//ÀÄÄÄÄÄÄÄÄÄÙ
	If SLG->( ColumnPos("LG_TIPTELA") ) > 0 .AND. SLG->( ColumnPos("LG_TOUCH") ) > 0									
		@ aPosObj[1,1] - 25,aPosObj[1,2] + 268 TO aPosObj[1,1] + 35,aPosObj[1,2] + 386 PROMPT STR0123 PIXEL OF oFolder:aDialogs[nFolder] //"Tipo Interface"
		@ aPosObj[1,1] - 15,aPosObj[1,2] + 276 Radio oTipoTela ;
												VAR nTipoTela ;
												ITEMS STR0124,STR0125 ; 
												ON CHANGE If(nTipoTela == 1,oTouch:Disable(),oTouch:Enable()) 3D ;
												SIZE 70,09 OF oFolder:aDialogs[nFolder] PIXEL //"Desktop" ## "Touch Screen"
		
		@ aPosObj[1,1] +5    ,aPosObj[1,2] + 277 SAY STR0126;
												PIXEL SIZE 40,18 OF oFolder:aDialogs[nFolder] //"Modelo"
		@ aPosObj[1,1] + 12,aPosObj[1,2] + 277 COMBOBOX oTouch ;
												VAR cTouch ;
												ITEMS aTouch ;
												WHEN nTipoTela <> 1 OF oFolder:aDialogs[nFolder] PIXEL SIZE 95,50	
	EndIf
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Display Torre ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If Len(aDispTorre) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe o campo de Display Torre ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SLG->(ColumnPos("LG_DISPTOR")) > 0 .AND. SLG->(ColumnPos("LG_PORTTOR")) > 0
			@ aPosObj[1,1] + 20,aPosObj[1,2] + 135	TO aPosObj[1,1] + 60,aPosObj[1,2] + 253 PROMPT STR0116 ;
													PIXEL OF oFolder:aDialogs[nFolder] // Display Torre
													
			@ aPosObj[1,1] + 27,aPosObj[1,2] + 143 SAY STR0019 ;
													PIXEL SIZE 40,18 ;
													OF oFolder:aDialogs[nFolder]   // Modelo
													
			@ aPosObj[1,1] + 35,aPosObj[1,2] + 143	COMBOBOX oDispTorre ;
													VAR cDispTorre ;
													ITEMS aDispTorre ;
													ON CHANGE LJ120VD2("IMP",cDispTorre,@cPortTorre,oPortTorre) ;
													WHEN cTipo $ "AI" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 70,15
												
			@ aPosObj[1,1] + 27,aPosObj[1,2] + 218	SAY STR0020 ;
													PIXEL SIZE 20,18 ;
													OF oFolder:aDialogs[nFolder]   // Porta
													
			@ aPosObj[1,1] + 35,aPosObj[1,2] + 218	COMBOBOX oPortTorre ;
													VAR cPortTorre ;
													ITEMS aPortCMC7 ;
													VALID LJ120VD2("POR",cDispTorre,cPortTorre,, STR0109) ;
													WHEN If(Empty(cDispTorre),(cPortTorre := Space(Len(cPortTorre)),.F.),.T.) .AND. cTipo $ "AI" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 30,15
		EndIf
	EndIf	
	
	//RFID 
	If SuperGetMv("MV_RFID",,.F.) .AND. SLG->(ColumnPos("LG_RFID")) > 0  .AND. SLG->(ColumnPos("LG_IDRFID")) > 0
	
		@ aPosObj[1,1] + 90,aPosObj[1,2] + 135	TO aPosObj[1,1] + 135,aPosObj[1,2] + 253 PROMPT STR0208 ; //"RFID"
												PIXEL OF oFolder:aDialogs[nFolder] 
												
		@ aPosObj[1,1] + 95,aPosObj[1,2] + 143 SAY STR0209 ;  // "Habilita"
												PIXEL SIZE 40,18 ;
												OF oFolder:aDialogs[nFolder]
												
		If cTipo == "A"
												   
			If SLG->LG_RFID == "1"
				cRFID := "1-"+STR0009	
			Else
				cRFID := "2-"+STR0010	
			EndIf
			
			cGetIDRFID := SLG->LG_IDRFID
		Else
			cRFID := "2-"+STR0010			
		EndIf	
											
		@ aPosObj[1,1] + 102,aPosObj[1,2] + 143	COMBOBOX oComboRFID ;
												VAR cRFID ;
												ITEMS {"1-"+STR0009,"2-"+STR0010} ;
												WHEN cTipo $ "AI" ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL SIZE 70,50  
		
		@ aPosObj[1,1] + 113,aPosObj[1,2] + 143 SAY STR0210 ;  //"ID Leitor RFID"
												PIXEL SIZE 40,18 ;
												OF oFolder:aDialogs[nFolder] 
		
		
		@ aPosObj[1,1] + 120,aPosObj[1,2] + 143 	MSGET oGetIDRFID 	;
												VAR cGetIDRFID			;
												PICTURE "@!" 				;
												VALID Lj121RFIDVld( cGetIDRFID , SLG->LG_CODIGO) ;
												WHEN cTipo $ "AI" ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL SIZE 40,09
													

	EndIf	
	
	// SAT   
	If cTipo <> "I"
		cAtivSAT := IIF(SLG->LG_USESAT,"Sim","Não") //Ativa ou nao
		If cAtivSAT == "Sim"  
			cSAT     := SLG->LG_FABSAT //Fabricante
			cModelSAT:= SLG->LG_MODSAT //modelo
			cCodSAT  := SLG->LG_CODSAT //Cod de ativaçao
			cSerSAT  := SLG->LG_SERSAT //Numero de serie
		EndIf

		If SM0->M0_ESTCOB $ "CE"			
			cChvReq  := IIF(SLG->(ColumnPos("LG_CHVREQ")) > 0, SLG->LG_CHVREQ, Space(9))  //Chave de Requisição   
			cChvVld  := IIF(SLG->(ColumnPos("LG_CHVVLD")) > 0, SLG->LG_CHVVLD, Space(9))  //Chave de Acesso Validador 
		EndIf		
	EndIf
EndIf

// Folder 4 - TEF
nFolder:= Ascan(aFolder,"4")
If (nFolder > 0 .AND. cPaisLoc == "BRA" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tela DEFAULT para todos os modulos . ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lCall  //  Call Center
		@ aPosObj[1,1] - 25,aPosObj[1,2] + 07 TO aPosObj[1,1] + 40,aPosObj[1,2] + 125 PROMPT STR0034 PIXEL OF oFolder:aDialogs[nFolder]    // Tipo
		If SLG->(ColumnPos("LG_IPSITEF")) > 0
			@ 	aPosObj[1,1] - 18,aPosObj[1,2] + 10	RADIO oTipTef VAR nTipTef ;
													ITEMS 	STR0061, STR0051, STR0092, STR0160, ;
															STR0053, STR0114	;
													ON CHANGE LjONChTEF(	nTipTef	, bTefDis	, bTefEnab, oPanel		, ;
																			oChk7	, oChk1		, oTermTef, @cImpTef	, ; 
																			cTipo	) 3D ;
													SIZE 113,08 OF oFolder:aDialogs[nFolder] PIXEL 
			If __lPyme
				oTipTef:disable(2)														
				oTipTef:disable(3)														
				oTipTef:disable(5)														
			EndIf
		Else
			@ aPosObj[1,1] - 18,aPosObj[1,2] + 10	RADIO oTipTef VAR nTipTef ;
													ITEMS 	STR0061, STR0051, STR0092, STR0160, ;
															STR0053	;
													ON CHANGE EVAL(If(nTipTef=1,bTefDis,bTefEnab) ) 3D ;
													SIZE 70,09 OF oFolder:aDialogs[nFolder] PIXEL  // Nao Utiliza /Dedicado, Discado, Lote
		EndIf

		@ aPosObj[1,1] - 25 ,aPosObj[1,2] + 135 	TO aPosObj[1,1] + 40,aPosObj[1,2] + 222 PROMPT STR0028 ;
												PIXEL OF oFolder:aDialogs[nFolder]    // Comprovante
												
		@ aPosObj[1,1] - 18 ,aPosObj[1,2] + 145 SAY STR0029 ;
												PIXEL SIZE 55,18 ;
												OF oFolder:aDialogs[nFolder]    // Impressora
												
		@ aPosObj[1,1] - 10,aPosObj[1,2] + 145 COMBOBOX oImpComp ;
												VAR cImpTEF ITEMS aImpComp ;
												ON CHANGE LJ120VD2(	"COMP", @cImpTEF, @cTEFVias, ;
																	oVias,,@cImpFisc,,,,cImpCup ) ;
												WHEN Str(nTipTEF,1) $ "2;4" .AND. cTipo $ "AI" ;
												OF oFolder:aDialogs[nFolder] PIXEL SIZE 65,15

								
		@ aPosObj[1,1] + 5,aPosObj[1,2] + 145 SAY STR0033 ;
												PIXEL SIZE 40,18 ;
												OF oFolder:aDialogs[nFolder]     // Vias
												
		@ aPosObj[1,1] + 15,aPosObj[1,2] + 145 COMBOBOX oVias VAR cTEFVias ;
												ITEMS aVias ;
												VALID LJ120VD2(	"VIAS", cImpTEF, @cTEFVias, oVias,,;
																@cImpFisc,,,,cImpCup ) ;
												WHEN Str(nTipTEF,1) $ "2;4" .AND. cTipo $ "AI" ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL SIZE 25,15
																							
		@ aPosObj[1,1] - 25,aPosObj[1,2] + 232 TO aPosObj[1,1] + 5 ,aPosObj[1,2] + 293 PROMPT STR0032+'1' ;
												PIXEL OF oFolder:aDialogs[nFolder]  // Terminal
												
		@ aPosObj[1,1] - 18,aPosObj[1,2] + 240 SAY STR0093+'1' ;
												PIXEL SIZE 55,18 ;
												OF oFolder:aDialogs[nFolder]    // Numero  
														
												
		@ aPosObj[1,1] - 10,aPosObj[1,2] + 240 MSGET oTermTEF ;
												VAR nTermTEF ;
												PICTURE "999" ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL SIZE 20,09 ;
												WHEN Str(nTipTEF,1) $ "2;3;4;6" .AND. cTipo $ "AI"
		
		@ aPosObj[1,1] + 40,aPosObj[1,2] + 07 	TO aPosObj[1,1] + 70,aPosObj[1,2] + 125 PROMPT STR0030 ;
												PIXEL OF oFolder:aDialogs[nFolder]  // Impressao Consulta
												
		@ aPosObj[1,1] + 48,aPosObj[1,2] + 10 	RADIO oImpTEFC ;
												VAR nImpTEFC ;
												ITEMS STR0009, STR0010 3D ;
												SIZE 35,10 OF oFolder:aDialogs[nFolder] ;
												PIXEL;
												WHEN Str(nTipTEF,1) $ "2;3;4;6" .AND. cTipo $ "AI"
												

		@ aPosObj[1,1] + 40,aPosObj[1,2] + 135	TO aPosObj[1,1] + 90 ,aPosObj[1,2] + 293 PROMPT STR0036 ;
												PIXEL OF oFolder:aDialogs[nFolder]  // Tipos de Consultas( Todas as Estacoes)
												
		@ aPosObj[1,1] + 48,aPosObj[1,2] + 143 CHECKBOX oChk1 VAR lVar1 PROMPT STR0037 ;
												SIZE 75, 10 OF oFolder:aDialogs[nFolder] ;
												PIXEL ;
												WHEN Str(nTipTEF,1) $ "2;3;4;6" .AND. cTipo $ "AI"	// SERASA / As.Comercial
												
		@ aPosObj[1,1] + 57,aPosObj[1,2] + 143	CHECKBOX oChk2 ;
												VAR lVar2 PROMPT STR0038 ;
												SIZE 75, 10 ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL WHEN Str(nTipTEF,1) $ "2;3;4;6"	.AND. cTipo $ "AI"	// TeleCheque
												
		@ aPosObj[1,1] + 66,aPosObj[1,2] + 143 CHECKBOX oChk3 ;
												VAR lVar3 PROMPT STR0039 ;
												SIZE 75, 10 ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL ;
												WHEN Str(nTipTEF,1) $ "2;3;4;6"	.AND. cTipo $ "AI"	// Cheque TecBan
												
		@ aPosObj[1,1] + 48,aPosObj[1,2] + 213	CHECKBOX oChk4 ;
												VAR lVar4 PROMPT STR0040 ;
												SIZE 75, 10 ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL ;
												WHEN Str(nTipTEF,1) $ "2;3;4;6" .AND. cTipo $ "AI"	// GDC
												
		@ aPosObj[1,1] + 57,aPosObj[1,2] + 213	CHECKBOX oChk5 ;
												VAR lVar5 PROMPT STR0041 ;
												SIZE 75, 10 ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL ;
												WHEN Str(nTipTEF,1) $ "2;3;4;6" .AND. cTipo $ "AI"	// SPC/TeleCheque
												
		@ aPosObj[1,1] + 66,aPosObj[1,2] + 213 CHECKBOX oChk6 ;
												VAR lVar6 PROMPT STR0099 ;
												SIZE 75, 10 ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL ;
												WHEN Str(nTipTEF,1) $ "2;3;4;6"	.AND. cTipo $ "AI"	// AVS 
		
		@ aPosObj[1,1] + 76,aPosObj[1,2] + 143 CHECKBOX oChk7 ;
												VAR lVar7 PROMPT STR0122 ; 
												SIZE 75, 10 ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL ;
												WHEN Str(nTipTEF,1) $ "6" .AND. cTipo $ "AI"	// "Cheque Papel Tecban"

		@ aPosObj[1,1] + 76,aPosObj[1,2] + 213 CHECKBOX oChk8 ;
												VAR lVar8 PROMPT STR0161 ;					//Cheque Redecard
												SIZE 75, 10 ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL ;
												WHEN Str(nTipTEF,1) $ "2;3;4;6"	.AND. cTipo $ "AI"	// Cheque Redecard		    										
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao de tela somente com os objetos utilizados pelo³
		//³Call Center.                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		@ aPosObj[1,1] +4,aPosObj[1,2] + 07 	TO aPosObj[1,1] + 66,aPosObj[1,2] + 125 PROMPT STR0034 ;
												PIXEL OF oFolder:aDialogs[nFolder]    // Tipo		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Habilita CliSiTEF para Call Center ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SLG->(ColumnPos("LG_IPSITEF")) > 0
			@ aPosObj[1,1] +9,aPosObj[1,2] + 9 	RADIO oTipTef ;
													VAR nTipTef ;
													ITEMS STR0061, STR0051, STR0092, STR0160, STR0053, STR0114 ;
													ON CHANGE  LjONChTEF(	nTipTef	, bTefDis	, bTefEnab, @oPanel		, ;
																			oChk7	,oChk1		, oTermTef,  @oTermTef	, ;
																			cTipo ) ; 
													3D SIZE 125,08 ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL   
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³A STR0051 Dedicado sem Cliente ficará sempre Disable, pois não faz sentido no Call Center³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oTipTef:disable(2) 
				oTipTef:disable(4)
				oTipTef:disable(5)
				
		Else
			@ aPosObj[1,1] + 09,aPosObj[1,2] + 10 	RADIO oTipTef ;
													VAR nTipTef ;
													ITEMS STR0061, STR0051, STR0092, STR0160, STR0053, STR0114 ;
													ON CHANGE LjONChTEF(nTipTef	, bTefDis	, bTefEnab	, @oPanel	, ;
																		oChk7	, oChk1		, oTermTef	, @oTermTef , ;
																		cTipo	) 3D ;
													SIZE 70,08 ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL  // Nao Utiliza /Dedicado com Client / Dedicado Sem Client
				oTipTef:disable(4)
				oTipTef:disable(5)									
		EndIf

		@ aPosObj[1,1] + 04,aPosObj[1,2] + 135 	TO aPosObj[1,1] + 35	,aPosObj[1,2] + 220 PROMPT STR0109 ;
												PIXEL OF oFolder:aDialogs[nFolder]    // Empresas
		@ aPosObj[1,1] + 17,aPosObj[1,2] + 143 COMBOBOX oTipoEmp ;
												VAR cTipoEmp ;
												ITEMS aTipoEmp  ;
												WHEN Str(nTipTEF,1) $ "2;3;4;6" .AND. cTipo $ "AI" ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL SIZE 70,50
		oTipoEmp:cSX1Hlp := "LG_TIPOATE"
		
		@ aPosObj[1,1] + 65,aPosObj[1,2] + 07  TO aPosObj[1,1] + 107,aPosObj[1,2] + 165 PROMPT STR0036 ;
												PIXEL OF oFolder:aDialogs[nFolder]  // Tipos de Consultas( Todas as Estacoes)
												
		@ aPosObj[1,1] + 73,aPosObj[1,2] + 10 	CHECKBOX oChk1 ;
												VAR lVar1 PROMPT STR0037 ;
												SIZE 75, 10 ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL ;
												WHEN Str(nTipTEF,1) $ "2;3;4;6" .AND. cTipo $ "AI"  	// SERASA / As.Comercial
												
		@ aPosObj[1,1] + 81,aPosObj[1,2] + 10 	CHECKBOX oChk2 ;
												VAR lVar2 PROMPT STR0038 ;
												SIZE 75, 10 ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL ;
												WHEN Str(nTipTEF,1) $ "2;3;4;6" .AND. cTipo $ "AI"  	// TeleCheque
												
		@ aPosObj[1,1] + 89,aPosObj[1,2] + 10 	CHECKBOX oChk3 ;
												VAR lVar3 PROMPT STR0039 ;
												SIZE 75, 10 ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL ;
												WHEN Str(nTipTEF,1) $ "2;3;4;6" .AND. cTipo $ "AI" 	// Cheque TecBan
												
		@ aPosObj[1,1] + 73,aPosObj[1,2] + 75 	CHECKBOX oChk4 ;
												VAR lVar4 PROMPT STR0040 ;
												SIZE 75, 10 ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL ;
												WHEN Str(nTipTEF,1) $ "2;3;4;6" .AND. cTipo $ "AI"   	// GDC
												
		@ aPosObj[1,1] + 81,aPosObj[1,2] + 75 	CHECKBOX oChk5 ;
												VAR lVar5 PROMPT STR0041 ;
												SIZE 75, 10 ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL ;
												WHEN Str(nTipTEF,1) $ "2;3;4;6" .AND. cTipo $ "AI"   	// SPC/TeleCheque
												
		@ aPosObj[1,1] + 89,aPosObj[1,2] + 75 	CHECKBOX oChk6 ;
												VAR lVar6 PROMPT STR0099 ;
												SIZE 75, 10 ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL ;
												WHEN Str(nTipTEF,1) $ "2;3;4;6" .AND. cTipo $ "AI"		// AVS 

		@ aPosObj[1,1] + 97,aPosObj[1,2] + 75 	CHECKBOX oChk7 ;
												VAR lVar7 PROMPT STR0122 ;
												SIZE 75, 10 ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL ;
												WHEN Str(nTipTEF,1) $ "6" .AND. cTipo $ "AI"	// "Cheque Papel Tecban" 
		
		@ aPosObj[1,1] + 97,aPosObj[1,2] + 10 	CHECKBOX oChk8 ;
												VAR lVar8 PROMPT STR0161 ;						//"Cheque Redecard"
												SIZE 75, 10 ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL ;
												WHEN Str(nTipTEF,1) $ "2;3;4;6" .AND. cTipo $ "AI" 	// Redecard		    										
	EndIf    
	
	@ aPosObj[1,1] + 17,aPosObj[1,2] + 240 MSGET oTermTEF ;
												VAR nTermTEF ;
												PICTURE "999" ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL SIZE 20,09 ;
												WHEN Str(nTipTEF,1) $ "2;3;4;6" .AND. cTipo $ "AI"											
														
																								
		@ aPosObj[1,1] + 04,aPosObj[1,2] + 232 TO aPosObj[1,1] + 40 ,aPosObj[1,2] + 293 PROMPT STR0032 ;
												PIXEL OF oFolder:aDialogs[nFolder]  // Terminal
												
		@ aPosObj[1,1] + 09,aPosObj[1,2] + 240 SAY STR0093 ;
												PIXEL SIZE 55,18 ;
												OF oFolder:aDialogs[nFolder]    // Numero  														
																								
	@ aPosObj[1,1] + If(! lCall , 90 , 112),aPosObj[1,2] + 07	TO aPosObj[1,1] + If(! lCall , 120 , 138),aPosObj[1,2] + 125 PROMPT STR0042 ;
											PIXEL OF oFolder:aDialogs[nFolder]		// Transmissao dos Arquivos
											
	@ aPosObj[1,1] + If(! lCall , 98 , 117),aPosObj[1,2] + 15 SAY STR0043 ;
											PIXEL ;
											SIZE 40,18 ;
											OF oFolder:aDialogs[nFolder]			// Diretorio
											
	@ aPosObj[1,1] + If(! lCall , 104 , 124),aPosObj[1,2] + 15	MSGET oDirTrans ;
											VAR cDirTTX ;
											PICTURE "@!" ;
											OF oFolder:aDialogs[nFolder] ;
											PIXEL SIZE 95,09 ;
											WHEN Str(nTipTEF,1) $ "2;3;4;5" .AND. cTipo $ "AI"
	
	@ aPosObj[1,1] + If(! lCall , 90 , 112),aPosObj[1,2] + 135	TO aPosObj[1,1] + If(! lCall , 120 , 138),aPosObj[1,2] + 253 PROMPT STR0044 ;
												PIXEL OF oFolder:aDialogs[nFolder]		// Recepcao dos Arquivos
											
	@ aPosObj[1,1] + If(! lCall , 98 , 117),aPosObj[1,2] + 143	SAY STR0043 ;
												PIXEL SIZE 40,18 ;
												OF oFolder:aDialogs[nFolder]			// Diretorio
											
	@ aPosObj[1,1] + If(! lCall , 104 , 124),aPosObj[1,2] + 143	MSGET oDirRec ;
												VAR cDirTRX PICTURE "@!" ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL SIZE 95,09 ;
												WHEN Str(nTipTEF,1) $ "2;3;4;5" .AND. cTipo $ "AI"

	// IP do Servidor SiTEF
	@  aPosObj[1,1] + If(! lCall , 90 , 112),aPosObj[1,2] + 07 MSPANEL oPanel PROMPT SIZE 250,040 ;
																		OF oFolder:aDialogs[nFolder]
		//linha, coluna, linha final,coluna finals																
	@  aPosObj[1,1]-30,aPosObj[1,2] +00	TO aPosObj[1,1]-2,aPosObj[1,2] + 118 PROMPT STR0112 ;
											PIXEL OF oPanel							// "IP do Servidor SiTEF"
											
	@  aPosObj[1,1]-20,aPosObj[1,2] + 08	MSGET oIPSiTEF ;
											VAR cIPSiTEF ;
											OF oPanel ;
											PIXEL SIZE 95,09
											
	If (nTipTEF == 6) 
		oPanel:Show()
	
	Else
		oPanel:Hide()
	EndIf
	
	If nTipTef == 1
		EVAL( bTefDis )
	Else
		EVAL( bTefEnab )
	EndIf
	If !cTipo $ "AI"
		If !lCall
			oImpTEFC:Disable()
		EndIf
		oTipTef:Disable()
	EndIf
ElseIf (nFolder > 0 .AND. cPaisLoc == "MEX" )	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Identificação Empresa³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPosObj[1,1] + 5 ,aPosObj[1,2] + 4 TO 140,135  LABEL STR0173 OF oFolder:aDialogs[nFolder]  PIXEL //"Identificação Empresa" 
	
	
	//	Companhia 
	nLinSay := 10
	nLinGet := 19
	
	@ aPosObj[1,1] + nLinSay,aPosObj[1,2] + 10 	SAY STR0174 ;//"Companhia"
													PIXEL SIZE 125,18 ;
													OF oFolder:aDialogs[nFolder]    
	
	@ aPosObj[1,1] + nLinGet,aPosObj[1,2] + 10 	MSGET oCompany ;
													VAR cCompany ;
													PICTURE "!@" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 100,09;  
													WHEN oTipMexCp:nAt == 1    													
	//Unid Neg CP    
	nLinSay += LINHATEF
	nLinGet += LINHATEF

	@ aPosObj[1,1] + nLinSay,aPosObj[1,2] + 10 	SAY STR0175 ; //"Num Unid Negócio C. P"
													PIXEL SIZE 125,18 ;
													OF oFolder:aDialogs[nFolder]    						       		
	
	@ aPosObj[1,1] + nLinGet,aPosObj[1,2] + 10 	MSGET oBranch ;
													VAR cBranch ;
													PICTURE "!@" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 100,09;  
													WHEN oTipMexCp:nAt == 1    													

	//Pais    
	nLinSay += LINHATEF
	nLinGet += LINHATEF

	@ aPosObj[1,1] + nLinSay,aPosObj[1,2] + 10 	SAY STR0176 ; // "Pais"
													PIXEL SIZE 125,18 ;
													OF oFolder:aDialogs[nFolder]    						       		
	
	@ aPosObj[1,1] + nLinGet,aPosObj[1,2] + 10 	MSGET oContry ;
													VAR cContry ;
													PICTURE "!@" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 100,09;  
													WHEN oTipMexCp:nAt == 1    													

	//Numero da Afiliação    
	nLinSay += LINHATEF
	nLinGet += LINHATEF

	@ aPosObj[1,1] + nLinSay,aPosObj[1,2] + 10 	SAY STR0177 ; //"Número da Afiliação"
													PIXEL SIZE 125,18 ;
													OF oFolder:aDialogs[nFolder]    						       		
	
	@ aPosObj[1,1] + nLinGet,aPosObj[1,2] + 10 	MSGET oMerchant ;
													VAR cMerchant ;
													PICTURE "!@" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 100,09;  
													WHEN oTipMexCp:nAt == 1    													
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados de Operação³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
	@ aPosObj[1,1] + 4  ,aPosObj[1,2] + 150 TO 60,255  LABEL STR0178 OF oFolder:aDialogs[nFolder]  PIXEL // "Dados de Operação"											
	
	// Tipo de Operação
	nLinSay := 10
	nLinGet := 19
	
	
	@ aPosObj[1,1] + nLinSay, aPosObj[1,2] + 154 	SAY STR0179 ; //"Tipo de Operação"
													PIXEL SIZE 125,18 ;
													OF oFolder:aDialogs[nFolder]    
			
	@ aPosObj[1,1] + nLinGet, aPosObj[1,2] + 154 	MSGET oOpType ;
													VAR cOpType ;
													PICTURE "!@" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 80,09;  
													WHEN oTipMexCp:nAt == 1  				

	//Moeda    
	nLinSay += LINHATEF
	nLinGet += LINHATEF

	
	@ aPosObj[1,1] + nLinSay, aPosObj[1,2] + 154 	SAY STR0180 ; // "Moeda"
													PIXEL SIZE 125,18 ;
													OF oFolder:aDialogs[nFolder]    
			
	@ aPosObj[1,1] + nLinGet, aPosObj[1,2] + 154 	COMBOBOX oCurrenc ;
													VAR cCurrenc ;
													ITEMS aCurrenc  ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 80,09;  
													WHEN oTipMexCp:nAt == 1  				
	// posiciona no valor correto
	oCurrenc:NAT := nCurrenc
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dados do Usuário ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPosObj[1,1] + 65  ,aPosObj[1,2] + 150 TO 140,255  LABEL STR0181 OF oFolder:aDialogs[nFolder]  PIXEL //"Dados do Usuário"											

	// Usuario
	nLinSay += LINHATEF + 7
	nLinGet += LINHATEF	+ 7		
	
	@ aPosObj[1,1] + nLinSay, aPosObj[1,2] + 154 	SAY STR0182 ; // "Usuário"
													PIXEL SIZE 125,18 ;
													OF oFolder:aDialogs[nFolder]    
			
	@ aPosObj[1,1] + nLinGet, aPosObj[1,2] + 154 	MSGET oUserCp ;
													VAR cUserCp ;
													PICTURE "!@" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 80,09;  
													WHEN oTipMexCp:nAt == 1  		

	//Senha    
	nLinSay += LINHATEF
	nLinGet += LINHATEF

	
	@ aPosObj[1,1] + nLinSay, aPosObj[1,2] + 154 	SAY STR0183 ; //"Senha"
													PIXEL SIZE 125,18 ;
													OF oFolder:aDialogs[nFolder]    
			
	@ aPosObj[1,1] + nLinGet, aPosObj[1,2] + 154 	MSGET oPwsCp ;
													VAR cPwsCp ;
													PICTURE "!@" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 80,09 ;  
													WHEN oTipMexCp:nAt == 1 				
	
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Servidor 		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	@ aPosObj[1,1] + 4  ,aPosObj[1,2] + 270 TO 35,370  LABEL STR0184 OF oFolder:aDialogs[nFolder]  PIXEL // "Servidor"
				
	//Url Servidor de Pagos
	nLinSay := 10
	nLinGet := 19
	
	@ aPosObj[1,1] + nLinSay, aPosObj[1,2] + 274 	SAY STR0185 ;  //"End: Servidor(http://) "
													PIXEL SIZE 125,18 ;
													OF oFolder:aDialogs[nFolder]    
			
	@ aPosObj[1,1] + nLinGet, aPosObj[1,2] + 274 	MSGET oUrlServ ;
													VAR cUrlServ ;
													PICTURE "!@" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 80,09;  
													WHEN oTipMexCp:nAt == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Habilita Tef  Mex³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	@ aPosObj[1,1] + 35  ,aPosObj[1,2] + 270 TO 80,370  LABEL STR0186 OF oFolder:aDialogs[nFolder]  PIXEL // "Usa Centro de Pagamentos"
				
	//Url Servidor de Pagos
	nLinSay += LINHATEF + 4
	nLinGet += LINHATEF + 4
	
	@ aPosObj[1,1] + nLinGet, aPosObj[1,2] + 274 	COMBOBOX oTipMexCp ;
													VAR cTipMexCp ;
													ITEMS aTipMexCp  ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 80,09  
													
	If nTipTef == 7
		oTipMexCp:nAt := 1
	Else
		oTipMexCp:nAt := 2
	EndIf	
																		
EndIf  

// Folder 5 - Servidor RPC
nFolder:= Ascan(aFolder,"5")
If (nFolder > 0)
	@ aPosObj[1,1] - 25,aPosObj[1,2] + 07 	TO aPosObj[1,1] + 60,aPosObj[1,2] + 125 PROMPT STR0062 ;
											PIXEL OF oFolder:aDialogs[nFolder] //"Conexao com o servidor"
											
	@ aPosObj[1,1] - 18,aPosObj[1,2] + 15 	SAY STR0063 ;
											PIXEL SIZE 40,18 ;
											OF oFolder:aDialogs[nFolder]   //"Numero do IP"
											
	@ aPosObj[1,1] - 11,aPosObj[1,2] + 15 	MSGET oRPCSrv ;
											VAR cRPCSrv ;
											PICTURE "@!" ;
											OF oFolder:aDialogs[nFolder] ;
											PIXEL SIZE 60,09 ;
											WHEN cTipo $ "AI"
	
	@ aPosObj[1,1] - 18,aPosObj[1,2] + 80 	SAY STR0064 ;
											PIXEL SIZE 20,18 ;
											OF oFolder:aDialogs[nFolder]   //"Porta"
											
	@ aPosObj[1,1] - 11,aPosObj[1,2] + 80 	MSGET oRPCPort ;
											VAR cRPCPort ;
											PICTURE "@!" ;
											OF oFolder:aDialogs[nFolder] ;
											PIXEL SIZE 20,09 ;
											WHEN If(Empty(cRPCSrv),(cRPCPort:=Space(Len(cRPCPort)),.F.),.T.) .AND. cTipo $ "AI" 
	
	@ aPosObj[1,1] + 5,aPosObj[1,2] + 15 	SAY STR0065 ;
											PIXEL SIZE 40,18 ;
											OF oFolder:aDialogs[nFolder]   //"Ambiente"
											
	@ aPosObj[1,1] + 15,aPosObj[1,2] + 15 	MSGET oRPCEnv ;
											VAR cRPCEnv  ;
											PICTURE "@!" ;
											OF oFolder:aDialogs[nFolder] ;
											PIXEL SIZE 92,09 ;
											WHEN If(Empty(cRPCSrv),(cRPCEnv:=Space(Len(cRPCEnv)),.F.),.T.) .AND. cTipo $ "AI" 
	
	@ aPosObj[1,1] + 30,aPosObj[1,2] + 15 	SAY STR0066 ;
											PIXEL SIZE 40,18 ;
											OF oFolder:aDialogs[nFolder]   //"Grupo"
	
	@ aPosObj[1,1] + 37,aPosObj[1,2] + 15 	MSGET oRPCEmp ;
											VAR cRPCEmp ;
											PICTURE "@!" ;
											OF oFolder:aDialogs[nFolder] ;
											PIXEL SIZE 10,09 ;
											WHEN If(Empty(cRPCSrv),(cRPCEmp:=Space(Len(cRPCEmp)),.F.),.T.) .AND. cTipo $ "AI" 
	
	@ aPosObj[1,1] + 30,aPosObj[1,2] + 40 	SAY STR0067 ;
											PIXEL SIZE 25,18 ;
											OF oFolder:aDialogs[nFolder]   //"Filial"
											
	@ aPosObj[1,1] + 37,aPosObj[1,2] + 40 	MSGET oRPCFil ;
											VAR cRPCFil ;
											PICTURE "@!" ;
											OF oFolder:aDialogs[nFolder] ;
											PIXEL SIZE nTamRPCFil,09 ;
											WHEN If(Empty(cRPCSrv),(cRPCFil:=Space(Len(cRPCFil)),.F.),.T.) .AND. cTipo $ "AI" 
	
	@ aPosObj[1,1] + 30,aPosObj[1,2] + 90 	SAY STR0068 ;
											PIXEL SIZE 25,18 ;
											OF oFolder:aDialogs[nFolder]   //"Intervalo"
	
	@ aPosObj[1,1] + 37,aPosObj[1,2] + 90 	MSGET oRPCInt ;
											VAR nRPCInt ;
											PICTURE "99" ;
											VALID nRPCInt >= 5 .AND. nRPCInt <= 60 ;
											WHEN If(Empty(cRPCSrv),(nRPCInt:=0,.F.),.T.) .AND. cTipo $ "AI" ;
											OF oFolder:aDialogs[nFolder] ;
											PIXEL SIZE 15,09
	
	@ aPosObj[1,1] - 25,aPosObj[1,2] + 135	TO aPosObj[1,1] + 35,aPosObj[1,2] + 253 PROMPT STR0069 ;
											PIXEL OF oFolder:aDialogs[nFolder] //"Ambiente Local"
											
	@ aPosObj[1,1] -18,aPosObj[1,2] + 143	SAY STR0070 ;
											PIXEL SIZE 40,18 ;
											OF oFolder:aDialogs[nFolder]   //"Ambiente"
											
	@ aPosObj[1,1] -11,aPosObj[1,2] + 143	MSGET oRMTEnv ;
											VAR cRMTEnv ;
											PICTURE "@!" ;
											OF oFolder:aDialogs[nFolder] ;
											PIXEL SIZE 92,09 ;
											WHEN If(Empty(cRPCSrv),(cRMTEnv:=Space(Len(cRMTEnv)),.F.),.T.) .AND. cTipo $ "AI" 		
	
	@ aPosObj[1,1] + 5,aPosObj[1,2] + 143	SAY STR0071 ;
											PIXEL SIZE 40,18 ;
											OF oFolder:aDialogs[nFolder]   //"Grupo"
											
	@ aPosObj[1,1] + 12,aPosObj[1,2] + 143	MSGET oRMTEmp ;
											VAR cRMTEmp ;
											PICTURE "@!" ;
											OF oFolder:aDialogs[nFolder] ;
											PIXEL SIZE 10,09 ;
											WHEN If(Empty(cRPCSrv),(cRMTEmp:=Space(Len(cRMTEmp)),.F.),.T.) .AND. cTipo $ "AI" 
	
	@ aPosObj[1,1] + 5,aPosObj[1,2] + 180	SAY STR0072 ;
											PIXEL SIZE 25,18 ;
											OF oFolder:aDialogs[nFolder]   //"Filial"
											
	@ aPosObj[1,1] + 12,aPosObj[1,2] + 180	MSGET oRMTFil ;
											VAR cRMTFil ;
											PICTURE "@!" ;
											OF oFolder:aDialogs[nFolder] ;
											PIXEL SIZE nTamRPCFil,09 ;
											WHEN If(Empty(cRPCSrv),(cRMTFil:=Space(Len(cRMTFil)),.F.),.T.) .AND. cTipo $ "AI" 
EndIf

nFolder:= Ascan(aFolder,"6")
If (nFolder > 0 .AND. cPaisLoc == "BRA" )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder 6 - Servidor de consultas cheque-pre.com             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	@ aPosObj[1,1] -18,aPosObj[1,2] + 15 	CHECKBOX oIntCns ;
											VAR lIntCns PROMPT STR0079 ;
											SIZE 75, 10 ;
											OF oFolder:aDialogs[nFolder] ;
											PIXEL ;   // Integrado
											ON CHANGE (SrvcnsOK(lIntcns		, @oDirOri	, @oDirDes, @oDirExec, ;
																@oRedeCns	, @oLojaCns	,@oCtrCns))
	
	@ aPosObj[1,1] + 10,aPosObj[1,2] + 25 	SAY STR0082 ;
											PIXEL SIZE 200,40 ;
											OF oFolder:aDialogs[nFolder]   //"Diretorio de origem"
											
	@ aPosObj[1,1] + 17,aPosObj[1,2] + 25 	MSGET oDirOri ;
											VAR cDirOri ;
											VALID SrvchkDir(@cDirOri, .F.) ;
											PICTURE "@!" ;
											OF oFolder:aDialogs[nFolder] ;
											PIXEL SIZE 90,09 ;
											WHEN lIntCns
	
	@ aPosObj[1,1] + 30,aPosObj[1,2] + 25 SAY STR0083 PIXEL SIZE 200,40 OF oFolder:aDialogs[nFolder]   //"Diretorio de Destino"
	@ aPosObj[1,1] + 37,aPosObj[1,2] + 25 MSGET oDirDes VAR cDirDes VALID SrvchkDir(@cDirDes,.F.) PICTURE "@!" OF oFolder:aDialogs[nFolder] PIXEL SIZE 90,09 WHEN lIntCns
	
	@ aPosObj[1,1] + 50,aPosObj[1,2] + 25 SAY STR0084 PIXEL SIZE 200,40 OF oFolder:aDialogs[nFolder]   //"Diretorio do Executavel"
	@ aPosObj[1,1] + 57,aPosObj[1,2] + 25 MSGET oDirExec VAR cDirExec VALID SrvchkDir(@cDirExec,.T.) PICTURE "@!" OF oFolder:aDialogs[nFolder] PIXEL SIZE 90,09 WHEN lIntCns
	
	@ aPosObj[1,1] + 10,aPosObj[1,2] + 165 SAY STR0085 PIXEL SIZE 40,20 OF oFolder:aDialogs[nFolder]   //"Codigo da Rede"
	@ aPosObj[1,1] + 17,aPosObj[1,2] + 165 MSGET oRedeCns VAR cRedeCns PICTURE "@!" OF oFolder:aDialogs[nFolder] PIXEL SIZE 10,09 WHEN lIntCns
	
	@ aPosObj[1,1] + 30,aPosObj[1,2] + 165 SAY STR0086 PIXEL SIZE 40,20 OF oFolder:aDialogs[nFolder]   //"Codigo da Loja"
	@ aPosObj[1,1] + 37,aPosObj[1,2] + 165 MSGET oLojaCns VAR cLojaCns PICTURE "@!" OF oFolder:aDialogs[nFolder] PIXEL SIZE 10,09 WHEN lIntCns
	
	@ aPosObj[1,1] + 50,aPosObj[1,2] + 165 SAY STR0087 PIXEL SIZE 80,20 OF oFolder:aDialogs[nFolder]   //"Codigo do Contrato"
	@ aPosObj[1,1] + 57,aPosObj[1,2] + 165 MSGET oCtrCns VAR cCtrCns PICTURE "@!" OF oFolder:aDialogs[nFolder] PIXEL SIZE 10,09 WHEN lIntCns
	
	@ aPosObj[1,1] ,aPosObj[1,2] + 11  TO aPosObj[1,1] + 80,aPosObj[1,2] + 135 PROMPT STR0096 PIXEL OF oFolder:aDialogs[nFolder] //"Diretorios"
	@ aPosObj[1,1] ,aPosObj[1,2] + 140 TO aPosObj[1,1] + 80,aPosObj[1,2] + 250 PROMPT STR0097 PIXEL OF oFolder:aDialogs[nFolder] //"Codigos"
	@ aPosObj[1,1] - 25,aPosObj[1,2] + 07  TO aPosObj[1,1] + 90,aPosObj[1,2] + 255 PROMPT STR0080 PIXEL OF oFolder:aDialogs[nFolder] //"Configuracoes"
EndIf

nFolder:= Ascan(aFolder,"7")
If nFolder > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder 7 - WebServices de Recebimento e Fidelizacao         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ aPosObj[1,1] - 25,aPosObj[1,2] + 07 TO aPosObj[1,1] + 30,aPosObj[1,2] + 90 PROMPT STR0080 PIXEL OF oFolder:aDialogs[nFolder] //"Configuracoes"

	@ aPosObj[1,1] - 18,aPosObj[1,2] + 10 SAY STR0104 PIXEL SIZE 80,18 OF oFolder:aDialogs[nFolder]	// "IP:Porta do WebService"
	@ aPosObj[1,1] - 11,aPosObj[1,2] + 10 SAY "http://" PIXEL SIZE 80,18 OF oFolder:aDialogs[nFolder]
	@ aPosObj[1,1] - 11,aPosObj[1,2] + 25 MSGET oWebSvc VAR cWebSvc PICTURE "@!" OF oFolder:aDialogs[nFolder] PIXEL SIZE 60,09 WHEN cTipo $ "AI"
	
	@ aPosObj[1,1] - 25,aPosObj[1,2] + 95 TO aPosObj[1,1] + 30,aPosObj[1,2] + 182 PROMPT STR0105 PIXEL OF oFolder:aDialogs[nFolder] // "Comprovante SIGACRD"
	@ aPosObj[1,1] - 18,aPosObj[1,2] + 105 SAY STR0029 PIXEL SIZE 55,18 OF oFolder:aDialogs[nFolder]    // Impressora
	@ aPosObj[1,1] - 11,aPosObj[1,2] + 105 COMBOBOX oCrdImp VAR cCrdImp ITEMS aCrdImp ;
											ON CHANGE LJ120VD2("CRDVIAS",cCrdImp,@nCrdVias,@oCrdVias) ;
											WHEN !(cTipo $ "V/E") OF oFolder:aDialogs[nFolder] PIXEL SIZE 65,15
	
	@ aPosObj[1,1] + 5,aPosObj[1,2] + 105 SAY STR0033 PIXEL SIZE 40,08 OF oFolder:aDialogs[nFolder]     // Vias
	@ aPosObj[1,1] + 12,aPosObj[1,2] + 105 MSGET oCrdVias VAR nCrdVias VALID nCrdVias>=0 WHEN cCrdImp<>aCrdImp[1] OF oFolder:aDialogs[nFolder] PIXEL SIZE 25,08

	@ aPosObj[1,1] + 35,aPosObj[1,2] + 07 TO aPosObj[1,1] + 75,aPosObj[1,2] + 90 PIXEL OF oFolder:aDialogs[nFolder]
	@ aPosObj[1,1] + 42,aPosObj[1,2] + 18 SAY STR0106 PIXEL SIZE 85,18 OF oFolder:aDialogs[nFolder] //"Integrar com o SIGACRD?"
	@ aPosObj[1,1] + 54,aPosObj[1,2] + 18 COMBOBOX oCrdXInt VAR cCrdXInt ITEMS aCrdXInt ;
	WHEN !(cTipo $ "V/E") OF oFolder:aDialogs[nFolder] PIXEL SIZE 65,15

	If SLG->(ColumnPos("LG_REDES")) > 0
		@ aPosObj[1,1] + 35,aPosObj[1,2] + 95 TO aPosObj[1,1] + 65,aPosObj[1,2] + 182 PROMPT STR0123 PIXEL OF oFolder:aDialogs[nFolder] // "Private Label"

		@ aPosObj[1,1] + 42,aPosObj[1,2]+105 CHECKBOX oIntRec VAR lRecarga PROMPT STR0163 SIZE 70,10 ;		// Recarga de Celular
		WHEN !(cTipo $ "V/E") .AND. nTipTef == 6 OF oFolder:aDialogs[nFolder] PIXEL SIZE 65,50
	EndIf
	If lWSSRVMT                                  
		@ aPosObj[1,1] + 77,aPosObj[1,2] + 07 TO aPosObj[1,1] + 110,aPosObj[1,2] + 90 PROMPT "Loja Off-Line" PIXEL OF oFolder:aDialogs[nFolder]
		@ aPosObj[1,1] + 97,aPosObj[1,2] + 10 SAY "http://" PIXEL SIZE 80,18 OF oFolder:aDialogs[nFolder]
		@ aPosObj[1,1] + 95,aPosObj[1,2] + 25 MSGET oWebMtz VAR cWebMtz PICTURE "@!" OF oFolder:aDialogs[nFolder] PIXEL SIZE 60,09 WHEN cTipo $ "AI"
		@ aPosObj[1,1] + 84,aPosObj[1,2] + 15 	CHECKBOX oMtzOk ;
												VAR lMtzOk PROMPT "Venda Off-Line" ;
												SIZE 75, 10 ;
												OF oFolder:aDialogs[nFolder] ;
												PIXEL ;   // Integrado
												ON CHANGE (Lj121WSMtz(lMtzOk, @oWebMtz))
	EndIf			
	
	//Tratamento Hotelaria - Disponibiliza opcao de incluir a Serie do PDV
	If lIntegHtl
		@ aPosObj[1,1] - 25,aPosObj[1,2] + 187 TO aPosObj[1,1] + 7,aPosObj[1,2] + 270 PROMPT STR0220 PIXEL OF oFolder:aDialogs[nFolder] // "Private Label" //#"Hotelaria"
		@ aPosObj[1,1] - 18,aPosObj[1,2] + 191 SAY RetTitle("LG_SERPDV") PIXEL SIZE 85, 18 OF oFolder:aDialogs[nFolder] 						
		@ aPosObj[1,1] - 10,aPosObj[1,2] + 191 MSGET oSerPdv VAR cSerPdv OF oFolder:aDialogs[nFolder] PIXEL SIZE 77,08 PICTURE "@!"	
	EndIf
	
	nFolder:= Ascan(aFolder,"8")
	If nFolder > 0
	
	   //Folder 8 - SAT       
       
       //Retorna os fabricantes homologados	       
       aFabricSAT := Lj121RFSat()
       
       //Carrega opções do combo oComboModSAT
       Lj121RMSat(cSAT,@aModSAT,@oComboModSAT)
   	
        @ aPosObj[1,1] -25,aPosObj[1,2] + 07 TO aPosObj[1,1] + 140,aPosObj[1,2] + 200 PROMPT "Config. " + cSiglaSat PIXEL OF oFolder:aDialogs[nFolder] //"Configuracoes" 

		oEditSAT := TSimpleEditor():New( 08	, 210 ,oFolder:aDialogs[nFolder]  ,200    ,;
                              			151	,     ,.T.    	,       ,;
                              		  oFont	, .T. )
		oEditSAT:TextFormat(1)//1=Html 2=Texto simples
		
		cMsgFaqSAT := 'Acesse a FAQ '+cSiglaSat+' para saber mais detalhes sobre a configuração, copie o link abaixo e abra em seu navegador.<br>' +; 
		'<a href="http://tdn.totvs.com.br/pages/viewpage.action?pageId=212899653"> http://tdn.totvs.com.br/pages/viewpage.action?pageId=212899653</a><br>'    
		
         If SM0->M0_ESTCOB $ 'CE'	
        	
        	cUrlMFe		:= "http://tdn.totvs.com.br/pages/editpage.action?pageId=327330367"	
			cMsgMfe		:= "<p>Para consultar a lista de equipamentos MFe homologados, copie o link abaixo e abra em seu navegador. "+;
							'<a href="' +cUrlMFe + '">'+  cUrlMFe + '</a></p><br>'    
							
			cMsgFaqSAT += cMsgMfe
        EndIf

        
        oEditSAT:Load(cMsgFaqSAT)
                   
        @ aPosObj[1,1] - 18,aPosObj[1,2] + 15 SAY "Ativar " + cSiglaSat  PIXEL OF oFolder:aDialogs[nFolder]                     // Ativar SAT
        @ aPosObj[1,1] - 11,aPosObj[1,2] + 15 COMBOBOX oCbAtivSAT VAR cAtivSAT ITEMS aAtivSAT WHEN IIf(cAtivSAT <> "Sim", !(cTipo $ "V") .AND. LjAnalisaLeg(70)[1], cAtivSat == "Sim" .And. cTipo $ "AI");
			PIXEL OF oFolder:aDialogs[nFolder] PIXEL SIZE 104,50
  	       
        @ aPosObj[1,1] + 7,aPosObj[1,2] + 15 SAY STR0158 PIXEL OF oFolder:aDialogs[nFolder]                     // Fabricante        
        @ aPosObj[1,1] + 14,aPosObj[1,2] + 15 COMBOBOX oComboSAT VAR cSAT ITEMS aFabricSAT WHEN (cAtivSat == "Sim" .And. cTipo $ "AI");
        	VALID Lj121RMSat(cSAT,@aModSAT,@oComboModSAT) PIXEL OF oFolder:aDialogs[nFolder] PIXEL SIZE 104,50
        	        
        @ aPosObj[1,1] + 32,aPosObj[1,2] + 15 SAY STR0215 PIXEL OF oFolder:aDialogs[nFolder] // Modelo
        @ aPosObj[1,1] + 39,aPosObj[1,2] + 15 COMBOBOX oComboModSAT VAR cModelSAT ITEMS aModSAT WHEN (cAtivSat == "Sim" .And. cTipo $ "AI") PIXEL OF oFolder:aDialogs[nFolder] PIXEL SIZE 104,50
 
        
        @ aPosObj[1,1] + 57,aPosObj[1,2] + 15 SAY STR0216 PIXEL OF oFolder:aDialogs[nFolder] // Cod. Ativação
        @ aPosObj[1,1] + 64,aPosObj[1,2] + 15 MSGET oAtivSAt VAR cCodSAT OF oFolder:aDialogs[nFolder] WHEN (cAtivSat == "Sim" .And. cTipo $ "AI") PIXEL SIZE 104,1
            
        @ aPosObj[1,1] + 76,aPosObj[1,2] + 15 SAY STR0219 PIXEL OF oFolder:aDialogs[nFolder] // Numero de Série do Equipamento
        @ aPosObj[1,1] + 83,aPosObj[1,2] + 15 MSGET oSerSAT VAR cSerSAT PICTURE "999999999" OF oFolder:aDialogs[nFolder] WHEN (cAtivSat == "Sim" .And. cTipo $ "AI") PIXEL SIZE 104,1    

		If SM0->M0_ESTCOB $ 'CE'
	        @ aPosObj[1,1] + 96,aPosObj[1,2] + 15 SAY "Chave de Requisição" PIXEL OF oFolder:aDialogs[nFolder] // "Chave de Requisição"
	        @ aPosObj[1,1] + 104,aPosObj[1,2] + 15 MSGET oChvReq VAR cChvReq PICTURE "@!" OF oFolder:aDialogs[nFolder] WHEN .F. PIXEL SIZE 110,1

			@ aPosObj[1,1] + 104,aPosObj[1,2] + 135 BUTTON "Gerar/Validar" SIZE 50, 12 PIXEL OF oFolder:aDialogs[nFolder] ACTION LjSetGuid(@cChvReq,OChvReq) //"Gerar/Validar"
	
	        @ aPosObj[1,1] + 116,aPosObj[1,2] + 15 SAY "Chave Acesso Validador" PIXEL OF oFolder:aDialogs[nFolder] // "Chave Acesso Validador"
	        @ aPosObj[1,1] + 124,aPosObj[1,2] + 15 MSGET oChvAccVld VAR cChvVld OF oFolder:aDialogs[nFolder] WHEN (cAtivSat == "Sim" .And. cTipo $ "AI") PIXEL SIZE 110,1		
	        
	        oChvReq:bGotFocus 		:= { || oEditSAT:Load(cMsgFaqSAT + '<p style="color: blue;"><b> Chave de Requisição <b></p><br>'+;
	        								'Utilização para MF-e.' ) }
	        oChvAccVld:bGotFocus 		:= { || oEditSAT:Load(cMsgFaqSAT + '<p style="color: blue;"><b> Chave Acesso Validador <b></p><br>'+;
	        								'Utilização para MF-e.' ) }	        
	        								
	        oChvReq:bLostFocus 		:= { || oEditSAT:Load(cMsgFaqSAT) }
	        oChvAccVld:bLostFocus 	:= { || oEditSAT:Load(cMsgFaqSAT) }	        								
	    EndIf
        
        oCbAtivSAT:bGotFocus 	:= { || oEditSAT:Load(cMsgFaqSAT + '<p style="color: blue;"><b> Ativar '+cSiglaSat+' <b></p><br>Habilita Uso do '+cSiglaSat+' para esta Estação?<br> '+ ;
        								'ATENÇÃO: Verifique se o Número de Série (LG_SERIE) informado nesta estação está livre para uso. A série deve ser única e exclusiva por Estação.' ) } 


		If SM0->M0_ESTCOB $ 'CE'
			oComboSAT:bGotFocus 	:= { || oEditSAT:Load(cMsgFaqSAT + '<p style="color: blue;"><b> Fabricante <b></p><br>Selecione o fabricante do seu equipamento '+cSiglaSat+'. ' ) }


		Else
			oComboSAT:bGotFocus 	:= { || oEditSAT:Load(cMsgFaqSAT + '<p style="color: blue;"><b> Fabricante <b></p><br>Selecione o fabricante do seu equipamento '+cSiglaSat+'. '+;
											'<br> ATENÇÃO: A DLL do fabricante deverá ser renomeada para dllsat.dll e copiada para pasta SmartClient <br> Exemplo:<br> Bematech renomeie a BemaSat.dll para dllsat.dll' ) }
		EndIf								

        oComboModSAT:bGotFocus 	:= { || oEditSAT:Load(cMsgFaqSAT + '<p style="color: blue;"><b> Modelo     <b></p><br>Selecione o modelo do seu equipamento '+cSiglaSat+'.') }
        oAtivSAt:bGotFocus 		:= { || oEditSAT:Load(cMsgFaqSAT + '<p style="color: blue;"><b> Código de Ativação <b></p><br>Este é código que foi definido pelo usuário no momento da ativação do equipamento '+cSiglaSat+'.'+ ;
        								' Verifique qual foi o código definido pelo usuário responsável. Mais detalhes acesse o item Check-List na FAQ acima.' ) }
        oSerSAT:bGotFocus 		:= { || oEditSAT:Load(cMsgFaqSAT + '<p style="color: blue;"><b> Número de Série do Equipamento <b></p><br>'+;
        								'Número de série que se encontra fixado no equipamento Exemplo:(000012345-99) informar apenas o número até o hífen 000012345. Mais detalhes acesse o item Check-List na FAQ acima.' ) }
                    
        oCbAtivSAT:bLostFocus 	:= { || oEditSAT:Load(cMsgFaqSAT) }
        oComboSAT:bLostFocus 	:= { || oEditSAT:Load(cMsgFaqSAT) }
        oComboModSAT:bLostFocus	:= { || oEditSAT:Load(cMsgFaqSAT) }
        oAtivSAt:bLostFocus 	:= { || oEditSAT:Load(cMsgFaqSAT) }
        oSerSAT:bLostFocus 		:= { || oEditSAT:Load(cMsgFaqSAT) }
   EndIf

	//Folder 9 - NFC-e
	nFolder := Ascan(aFolder,"9")
	If nFolder > 0
		nNFCeFolder := nFolder

        @ aPosObj[1,1] - 25,aPosObj[1,2] + 07 TO aPosObj[1,1] + 120,aPosObj[1,2] + 200 PROMPT STR0226 PIXEL OF oFolder:aDialogs[nFolder] //"Config. NFC-e"

		oEditNfce := TSimpleEditor():New(	08		, 210	, oFolder:aDialogs[nFolder]	,200	,;
                              				141		, Nil	, .T.						,Nil	,;
                              		  		oFont	, .T.	)
		If ExistFunc("LjWizNFCe")
			oBtnConfig := TButton():Create(oFolder:aDialogs[nFolder], aPosObj[1,1]-13, aPosObj[1,2]+135, STR0227, ;
											{|| (LjWizNFCe(), Lj121CfgNF(cAtivSAT, cImpFisc))} ,43, 15,,,,.T.,,STR0238) //"Configurações" //"Validar configuração NFC-e"
		Else
			LjGrvLog("Cadastro de Estação", "Atualizar os fontes LjWizNFCe.prw e TSSConfig.prw para funcionamento da aba NFC-e.")
		EndIf

        @ aPosObj[1,1] - 18,aPosObj[1,2] + 15 SAY STR0228 PIXEL OF oFolder:aDialogs[nFolder] //"NFC-e ativa?"         
        @ aPosObj[1,1] - 11,aPosObj[1,2] + 15 MSGET oAtivNFce VAR cAtivNfce WHEN .F. PIXEL OF oFolder:aDialogs[nFolder] PIXEL SIZE 90,10

        @ aPosObj[1,1] + 07,aPosObj[1,2] + 15 SAY STR0229 PIXEL OF oFolder:aDialogs[nFolder] //"URL do TSS"
        @ aPosObj[1,1] + 14,aPosObj[1,2] + 15 MSGET oURLTSS VAR cURLTSS WHEN .F. PIXEL OF oFolder:aDialogs[nFolder] PIXEL SIZE 90,10

        @ aPosObj[1,1] + 32,aPosObj[1,2] + 15 SAY STR0230 PIXEL OF oFolder:aDialogs[nFolder] //"CSC fornecido pelo SEFAZ"
        @ aPosObj[1,1] + 39,aPosObj[1,2] + 15 MSGET oToken VAR cToken WHEN .F. PIXEL OF oFolder:aDialogs[nFolder] PIXEL SIZE 90,10

        @ aPosObj[1,1] + 57,aPosObj[1,2] + 15 SAY STR0232 PIXEL OF oFolder:aDialogs[nFolder] //"ID CSC fornecido pelo SEFAZ"
        @ aPosObj[1,1] + 64,aPosObj[1,2] + 15 MSGET oIDToken VAR cIDToken WHEN .F. PIXEL OF oFolder:aDialogs[nFolder] PIXEL SIZE 90,10

        @ aPosObj[1,1] + 82,aPosObj[1,2] + 15 SAY STR0231 PIXEL OF oFolder:aDialogs[nFolder] //"Fuso horário no padrão UTC"
        @ aPosObj[1,1] + 89,aPosObj[1,2] + 15 MSGET oUTCNfce VAR cUTCNfce WHEN .F. PIXEL OF oFolder:aDialogs[nFolder] PIXEL SIZE 90,10

		//atenção, parametro MV_PAFNFCE utilizado somente internamente para poder simular ambiente PAF-NFCE com Sigamat AM (NFC-e)
		If SLG->(ColumnPos("LG_TIPOPAF")) > 0 .AND. ExistFunc("LjTipoPAF") .AND. (SM0->M0_ESTCOB $ 'SC' .OR. SuperGetMv("MV_PAFNFCE",,.F.))
			
			@ aPosObj[1,1] + 30 ,aPosObj[1,2] + 130 SAY "Tipo PAF" PIXEL OF oFolder:aDialogs[nFolder] 			

			@aPosObj[1,1] + 40 , aPosObj[1,2] + 130 COMBOBOX oComboPAF ;
													VAR cTipoPAF ;
													ITEMS StrTokArr( Posicione("SX3", 2, PadR("LG_TIPOPAF",10), "X3CBox()" ), ";") ;
													WHEN cTipo $ "AI" .AND. LjIFTipoEcNf(cImpFisc) ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 65,15

		
		Endif

		oFolder:bSetOption := {|nDst| Lj121FlChg(@nDst   ,oFolder:nOption,oFolder, oCfgTef,;
												 nOpc    ,       cAtivSAT, cImpFisc,      )}
 
	EndIf

	//Folder 0 - Totvs Pagamento Digital
	nFolder := Ascan(aFolder,"0")
	If nFolder > 0
		oCfgTef:LjPnlPayHub(oFolder:aDialogs[nFolder],If(cTipo=="V",.T.,.F.))
	EndIf
									
EndIf

//Folder Integrações Varejo
nFolder:= Ascan(aFolder, "A")
If nFolder > 0
    nFldIntRaas := nFolder

	oFolder:bSetOption := {|nDst| Lj121FlChg(@nDst   , oFolder:nOption, oFolder , oCfgTef, nOpc,;
                                             cAtivSAT, cImpFisc       , cCodigo )}
EndIf

//Folder B - Pdv Online
nFolder := Ascan(aFolder, "B")
If nFolder > 0
	@aPosObj[1,1] - 25, aPosObj[1,2] + 07 TO aPosObj[1,1] + 10, aPosObj[1,2] + 100 PROMPT "PDV Online?" PIXEL OF oFolder:aDialogs[nFolder]

	@aPosObj[1,1] - 12, aPosObj[1,2] + 12 COMBOBOX oComboPdv ;
													VAR cIsOnline ;
													ITEMS StrTokArr( Posicione("SX3", 2, PadR("LG_PDVON",10), "X3CBox()" ), ";") ;
													WHEN cTipo $ "AI" ;
													OF oFolder:aDialogs[nFolder] ;
													PIXEL SIZE 65,15
EndIf

//Numeracao da DLL + Mensagem para consultar os equipamentos homologados
cMsgRodape := 	"SIGALOJA.DLL " + STR0159 + ": " + cSigaDLLVer + "<br>" + STR0115 + "<br>" + ; //"Favor consultar a relação dos equipamentos homologados, copie o link abaixo e abra em seu navegador."
				'<a target="_blank" href="http://tdn.totvs.com.br/pages/viewpage.action?pageId=201752301"> http://tdn.totvs.com.br/pages/viewpage.action?pageId=201752301</a>'

oEditMsRod := TSimpleEditor():New( 240	, 007 ,oDlgEst  ,320    ,;
                              35 	,     ,.T.    	,       ,;
                              oFont	, .T. )
oEditMsRod:TextFormat(1)//1=Html 2=Texto simples
oEditMsRod:Load(cMsgRodape)    

DEFINE SBUTTON FROM	aPosObj[1,1] + 240,aPosObj[1,2] + 403 TYPE 1 ENABLE OF oDlgEst ;
	ACTION If(LJESTINC( cCodigo		, cNome		, cImpFisc	, cPortIF	, ;
						cImpCup		, cPortICP	, cImpChq	, cPortChq	, ;
						cOptico		, cPortOpt	, cPinPad	, cPortPad	, ;
						cPadMsg		, cCMC7		, cPortCMC7	, cCartMag	, ;
						cPortMag	, cBalanca	, cDirBal	, cGaveta	, ;
						cPortGav	, lGavStat	, cImpTEF	, nImpTEFC	, ;
						cTEFVias	, nTipTef	, cDirTTX	, cDirTRX	, ;
						lVar1		, lVar2		, lVar3		, lVar4		, ;
						lVar5		, lVar6		, cTipo		, cRPCSrv	, ;
						cRPCPort	, cRPCEnv	, cRPCEmp	, cRPCFil	, ;
						nRPCInt		, cRMTEnv	, cRMTEmp	, cRMTFil	, ;
						cSerie		, lintcns	, cDirOri	, cDirDes	, ;
						cDirExec	, cRedeCns	, cLojaCns	, cCtrCns	, ;
						cJournal	, cDisplay	, cPortDis	, cPdv		, ;
						nTermTEF	, cTSCSrv	, cTSCPort	, cMsgCup	, ;
						cWebSvc		, cCrdImp	, nCrdVias	, cCrdXInt	, ;
						cPortBal	, nTimeOut	, cTipoEmp	, cIPSiTEF	, ;
						cTamSer		, cDispTorre, cPortTorre, lVar7	 	, ;
						cTouch		, nTipoTela	, lVar8		, lChkTiFa  , ; 
						lRecarga	, cChkPvNf	, cWebMtz	, cRecTktFat, ;
						cCompany	, cUrlServ	, cBranch 	, cContry 	, ;	
						cMerchant	, cUserCp	, cPwsCp	, cOpType	, ;
						cCurrenc	, oTipMexCp	, cCMC7Dir	, nLargCol	, ;
						cIsPos		, cRFID		, cGetIDRFID, cIntPos	, ;
						cAtivSAT	, cSAT		, cModelSAT	, cCodSAT	, ;
						cSerSAT		, M->LG_SERNFIS, cCredECF, cSerPdv	, ;
						cChvReq		, cChvVld 	, cNomeRede , cIPImpRD 	, ;
						@oCfgTef	, cIsOnline  ), ;
						oDlgEst:End(), .F. )

DEFINE SBUTTON FROM aPosObj[1,1] + 240,aPosObj[1,2] + 432 TYPE 2 ENABLE OF oDlgEst ACTION ( ValidaTela(cTipo, cCodigo), oDlgEst:End() )

//----------------------------------------------------------------------------------------
//|Senao for TEF20 inicializar a Combo de Impressoras fiscais (TEF) como "Nao Imprimir", |
//|pois o mesmo nao podera inicializar nula.                                             |
//----------------------------------------------------------------------------------------
If !lCall .AND. (cPaisLoc == "BRA") .AND. !lMV_LJTEF20
	If cTipo == "I"          
		cImpTEF            := STR0008 // "Nao imprime"
		oImpComp:nAt       := 1
		oImpComp:Refresh()
	EndIf
EndIf

ACTIVATE MSDIALOG oDlgEst CENTERED ON   INIT ( If(cTipo$"AVE" .And. !aLeg61[1] .AND. !lCall .AND. !lNoPaf, LJImpModelo(	@aImpList, cImpFFab , @aModelo, @oImpFMod,;
																		 	@cTipo	 , @cImpFMod, @cAltFMod ) , )	,LJGeraNome(@cImpFisc , @cImpFMod , @cTipo),; 
																		 	Lj121WSMtz( lMtzOk , oWebMtz )			,Lj121RpcOk( oRMTEnv, oRMTEmp, oRMTFil )	,;
																			Lj121USBFiltro(	@aPortIf	, cImpFMod	, @oPortIf) )   ;
                                        VALID ValidaTela(cTipo, cCodigo)
Return NIL


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ LJESTINC ³ Autor ³ Vendas Clientes       ³ Data ³22/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclusao/Alteracao dos dados na base SLG                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJESTINC(cCodigo,cNome,cTipo)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodigo  - Codigo da Estacao                               ³±±
±±³          ³ cNome - Nome da Estacao                                    ³±±
±±³          ³ cTipo    - tipo de operacao a ser efetuado, sendo :        ³±±
±±³          ³        I - Inclusao                                        ³±±
±±³          ³        A - Alteracao                                       ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJEstInc(	cCodigo		, cNome		, cImpFisc	, cPortIF	, ;
					cImpCup		, cPortICP	, cImpChq	, cPortChq	, ;
				  	cOptico		, cPortOpt	, cPinPad	, cPortPad	, ;
				  	cPadMsg		, cCMC7		, cPortCMC7	, cCartMag	, ;
				  	cPortMag	, cBalanca	, cDirBal	, cGaveta	, ;
				  	cPortGav	, lGavStat	, cImpTEF	, nImpTEFC	, ;
				  	cTEFVias	, nTipTef	, cDirTTX	, cDirTRX	, ;
				  	lVar1		, lVar2		, lVar3		, lVar4		, ;
				  	lVar5		, lVar6		, cTipo		, cRPCSrv	, ;
				  	cRPCPort	, cRPCEnv	, cRPCEmp	, cRPCFil	, ;
				  	nRPCInt		, cRMTEnv	, cRMTEmp	, cRMTFil	, ;
				  	cSerie		, lintcns	, cDirOri	, cDirDes	, ;
				  	cDirExec	, cRedeCns	, cLojaCns	, cCtrCns	, ;
				  	cJournal	, cDisplay	, cPortDis	, cPDV		, ;
				  	nTermTEF	, cTSCSrv	, cTSCPort	, cMsgCup	, ;
				  	cWebSvc		, cCrdImp	, nCrdVias	, cCrdXInt	, ;
				  	cPortBal	, nTimeOut	, cTipoEmp	, cIPSiTEF	, ;
				  	cTamSer		, cDispTorre, cPortTorre, lVar7		, ;
				  	cTouch		, nTipoTela	, lVar8		, lChkTiFa	, ;
				  	lRecarga	, cChkPvNf	, cWebMtz	, cRecTktFat, ;
				  	cCompany	, cUrlServ	, cBranch 	, cContry	, ;	
					cMerchant	, cUserCp	, cPwsCp	, cOpType	, ;
					cCurrenc	, oTipMexCp	, cCmC7Dir	, nLargCol	, ;
					cIsPos		, cRFID		, cGetIDRFID, cIntPos	, ;
					cAtivSAT	, cSAT		, cModelSAT	, cCodSAT	, ;
					cSerSAT		, cSerNFis  , cCredECF	, cSerPdv   , ;
					cChvReq		, cChvVld	, cNomeRede , cIPImpRD	, ;
					oCfgTef		, cIsOnline	 )

Local nI			 := 0	// controle de loop
Local cTEFCons
Local cStr
Local cJobs 
Local lOnStart
Local cClientDir											// Diretorio onde esta o REMOTE
Local cPPVisa												// Arquivo PPVISA.INI
Local lAltConfig  	:= .F.									// Verifica se existe alteracao referente ao JOB FRTA020
Local nHandle		:= 0									// Variavel para criacao de arquivo TXT
Local lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)	// Identifica se o ambiente esta operando em offline
Local lRet			:= .T.                                  // Retorno da função
Local lPOS 			:= STFIsPOS() //Pos?
Local nTipTEFAnt	:= 1	//Armazena tipo do Sitef antes da alteracao
Local lEmitNfce		:= .F.	//É NFC-e?
Local lIntegHtl 	:= SuperGetMv("MV_INTHTL",, .F.) .And. FWHasEAI("LOJA701",, .T., .T.) //Integracao via Mensagem Unica - Hotelaria
Local lUsePayHub 	:= ExistFunc("LjUsePayHub") .And. LjUsePayHub()

Default lRecarga	:= .F.
Default cChkPvNf	:= "N"                             
Default cWebMtz  	:= "" 	//Grava Web Da matriz 
Default cRecTktFat	:= "T"
Default nLargCol	:= 0  
Default cIsPos		:= "2"	//Não
Default cRFID		:= "2"
Default cGetIDRFID	:= ""
Default cIntPos		:= "2" 
Default cCredECF	:= ""
Default cSerPdv		:= ""
Default cChvReq		:= ""
Default cChvVld		:= ""
Default cIPImpRD	:= ""
Default oCfgTef 	:= Nil
Default cIsOnline	:= "2"

//Validação inserida para impedir a inclusão ou a alteração 
//do PDV para um que já está cadastrado na SLG, pois com o número 
//de PDV duplicado temos erro na geração do SpedFiscal com o registro C425 duplicado
If cPaisLoc == "BRA" .AND. !Lj121VldEst( cTipo , cPDV, cImpFisc, cSerie)
	lRet := .F.
EndIf

//Se for integracao com Synthesis valida se existe uma loja(LJ_CODIGO) cadastrada com o mesmo codigo da filial.
If lIntPOS 
	DbSelectArea("SLJ")
	DbSetOrder(1)		//Filial + Loja
	If !DbSeek(xFilial("SLJ") + xFilial("SLG") )	 
		lRet := .F.
		MsgAlert(STR0212 + xFilial("SLG") + STR0213)// "É necessário efetuar o cadastro de uma loja com o código " //" para prosseguir com o cadastro da estacao."	
	EndIf	
EndIf

//Valida se utiliza NFC-e/SAT
If lRet 
	//Valida se o SAT está configurado com ativado e se a impressora informada é não fiscal
	If cAtivSAT == "Sim" .AND. ( Upper(cImpFisc) <> "EMULADOR NAO FISCAL") .AND. !LjIFTipoEcNf(cImpFisc)
		MsgAlert(STR0237) //"Não foi possível salvar estas configurações pois o SAT necessita de uma impressora não fiscal."
		lRet := .F.
	EndIf
	
	If lRet
		//Verifica se é NFC-e	
		lEmitNfce := lj121IsNfce(cAtivSAT, cImpFisc)
	
		//Validacao se os campos do cadastro do SAT estao preenchidos
		If cAtivSAT == "Sim"
		    lRet := LjChangeSAT(cSAT	, cModelSAT	, cCodSAT , cPDV ,;
		    					cSerie	, cImpFisc	, cChvVld ) 
		EndIf
	
		//Valida se serie eh numerica, para NFCe somente eh possivel serie numerica para montagem do Hash da Nota(padrao Sefaz)
		If lEmitNfce
			For nI := 1 To Len(AllTrim(cSerie))
				If !IsDigit(SubStr(AllTrim(cSerie),nI,1))
					lRet := .F.
				EndIf
			Next nI
	       
			If !lRet
				MsgAlert(STR0205 + AllTrim(cSerie) + STR0206)	//"Série:"  ## " inválida. Conteúdo deve ser numérico (Conforme especificação técnica da NFC-e)"
			Else
				lRet := LjVldNFCe(cTipo, cPDV, cSerie)
			EndIf
		EndIf
	EndIf
EndIf

If lRet
	//Valida dados da Aba "Totvs Pagamento Digital" (TEF 2.0)
	lRet := Lj121VlTPD(cTipo,@oCfgTef)
EndIf

If lRet

	If cPaisLoc == "MEX"
		If oTipMexCp:nAt == 1	
			nTipTEF := 7
		Else
			nTipTEF := 1
		EndIf
	EndIf
	
	If cTipo == "V"
		Return (.T.)
	EndIf
	
	If cTipo == "E"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cadastro chamado pelo  Call Center e a Estacao esta sendo utilizada nas movimentacoes do Modulo.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (lCall) .AND. (LjCallPosto(SLG->LG_CODIGO))
		  Return (.F.)
		EndIf

        //Efetua a exclusão das Integrações Varejo
        If !IntegVarej(SLG->LG_CODIGO, .T.)
	        Return .F.
        EndIf

		Lj121Integ(cTipo)
		
		SLG->(RecLock("SLG",.F.,.T.))
		//esse campo deve ficar em branco para que o Registro do PAF
		//faça o filtro correto quando efetuada deleção manual de registro
		If SLG->(ColumnPos("LG_PAFMD5")) > 0
			REPLACE SLG->LG_PAFMD5 WITH ""
		EndIf 
		SLG->(dbDelete())
		SLG->(MsUnLock())
		Lj121InFim(cTipo)

		//Grava dados do TEF 2.0 
		If ValType(oCfgTef) == "O"
			oCfgTef:cCodigo := cCodigo
			If lSalvaTef
				oCfgTef:Salvar(cTipo)
			EndIf
		EndIf

		Return (.T.)

	EndIf
	If nTipTef = 1
		cImpTEF		:= STR0008 // "Nao imprime"
		nImpTEFC	:= 2
		cTEFVias	:= "0"
		cDirTTX		:= Space(20)
		cDirTRX		:= Space(20)
		lVar1		:= .F.
		lVar2		:= .F.
		lVar3		:= .F.
		lVar4		:= .F.
		lVar5		:= .F.
		lVar6		:= .F.
		lVar7		:= .F.
		lVar8		:= .F.
	Else
		If !LJDirect(cDirTTX)
			cDirTTX	:= Space(20)
		EndIf
		If !LJDirect(cDirTRX)
			cDirTRX	:= Space(20)
		EndIf
	EndIf
	If !LJDirect(cDirBal)
		cDirBal		:= Space(20)
	EndIf
	cDirTTX			:= Alltrim(cDirTTX)
	cDirTRX			:= Alltrim(cDirTRX)
	cDirBal			:= Alltrim(cDirBal)
	cStr			:= ""
	If !Empty(cImpFisc) .AND. Empty(cPortIF)
		cStr		:= StrTran(STR0014,"&","") + " " + STR0018 + " " + cImpFisc 	// "&Impressoras" "Fiscal"
	ElseIf !Empty(cImpCup) .AND. Empty(cPortICP)
		cStr		:= StrTran(STR0014,"&","") + " " + STR0022 + " " + cImpCup		// "&Impressoras" "Cupom"
	ElseIf !Empty(cImpChq) .AND. Empty(cPortChq)
		cStr		:= StrTran(STR0014,"&","") + " " + STR0021 + " " + cImpChq 	// "&Impressoras" "Cheque"
	ElseIf !Empty(cCMC7) .AND. Empty(cPortCMC7)
		cStr		:= StrTran(STR0015,"&","") + " " + STR0025 + " " + cCMC7		// "&Leitores" "CMC7"
	ElseIf !Empty(cPinPad) .AND. Empty(cPinPad)
		cStr		:= StrTran(STR0015,"&","") + " " + STR0024 + " " + cPinPad		// "&Leitores" "PinPad" 
	ElseIf !Empty(cCartMag) .AND. Empty(cPortMag)
		cStr		:= StrTran(STR0015,"&","") + " " + STR0026 + " " + cCartMag	// "&Leitores" "Cartäo magnetico"
	ElseIf !Empty(cBalanca) .AND. Empty(cDirBal)
		cStr		:= STR0073+STR0016 + " " + cBalanca								// "diretorio " "Balancas"
	ElseIf !Empty(cGaveta) .AND. Empty(cPortGav)
		cStr		:= STR0046 + " " + cGaveta										// "Gaveta"
	ElseIf Left(cImpTEF,1) = "F" .AND. Empty(cImpFisc)
		cStr		:= StrTran(STR0014,"&","") + " " + STR0018 + " " + STR0028
	ElseIf Left(cImpTEF,1) = "C" .AND. Empty(cImpCup)
		cStr		:= StrTran(STR0014,"&","") + " " + STR0022 + " " + STR0028
	ElseIf Left(cImpTEF,1) = "N" .AND. Val(cTEFVias)>0
		cStr		:= STR0049
	EndIf
	
	If Len(cStr) <> 0
		MsgInfo( STR0050+" "+cStr)
		Return .F.
	EndIf
	
	If (Empty(cSerie) .OR. Empty(cPdv) ).AND. ! Empty(cImpFisc)
		MsgStop(STR0077)
		Return (.F.)
	EndIf
	
	cTEFCons		:= If(lVar1,"S","N")
	cTEFCons		+= If(lVar2,"S","N")
	cTEFCons		+= If(lVar3,"S","N")
	cTEFCons		+= If(lVar4,"S","N")
	cTEFCons		+= If(lVar5,"S","N")
	cTEFCons		+= If(lVar6,"S","N")
	cTEFCons		+= If(lVar7,"S","N")
	cTEFCons		+= If(lVar8,"S","N")
	If Right(cDirTTX,1) <> "\" .AND. !Empty(cDirTTX)
		cDirTTX		+= "\"
	EndIf
	
	If Right(cDirTRX,1) <> "\" .AND. !Empty(cDirTRX)
		cDirTRX		+= "\"
	EndIf
	
	If Right(cDirBal,1) <> "\" .AND. !Empty(cDirBal)
		cDirBal		+= "\"
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Consiste se o tipo de empresa foi preenchido 		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCall                              
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Dedicado com client - Dedicado s/ client³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTipTef == 2 .OR. nTipTef == 3 
			If !Empty(cTipoEmp)
				cTipoEmp   := If(cTipoEmp == STR0107,"1",If (cTipoEmp == STR0108,"2"," ")) 
			Else
				MsgInfo(STR0110)//"Para o tipo de TEF selecionado, será necessário informar a Empresa responsavel pela operação das transações TEF!")
				Return(.F.)
			EndIf	
		EndIf	
	EndIf
	
	
	DbSelectArea("SLG")
	If cTipo = "I"
		Reclock( "SLG", .T. )
	Else
		Reclock( "SLG", .F. )
		
		//Armazena tipo do Sitef antes da alteracao
		nTipTEFAnt := Val(SLG->LG_TIPTEF)
	EndIf
	
	REPLACE LG_FILIAL  WITH xFilial()
	REPLACE LG_CODIGO  WITH cCodigo
	REPLACE LG_NOME	   WITH cNome
	REPLACE LG_SERIE   WITH cSerie
	REPLACE LG_PDV     WITH cPDV

	If SLG->(ColumnPos("LG_NOMCOMP")) > 0
		REPLACE LG_NOMCOMP     WITH cNomeRede
	EndIf

	/*
	A impressora Bematech será acessada somente da SIGLOJA.DLL
	*/
	If AllTrim(cImpFisc) == "BEMATECH MP4200 V01.00.00" .And. IIF(SLG->( ColumnPos("LG_USESAT") ) > 0, ( cAtivSAT == "Não" .OR. cSigaDLLVer >= "0.3.141.0" ), .T.) 
		cImpFisc := "BEMATECH MP-4200 TH 01.00.00(S)"
	EndIf
	REPLACE LG_IMPFISC WITH cImpFisc

	REPLACE LG_PORTIf  WITH cPortIF
	REPLACE LG_IMPCUP  WITH cImpCup
	REPLACE LG_PORTICP WITH cPortICP
	REPLACE LG_IMPCHQ  WITH cImpChq
	REPLACE LG_PORTCHQ WITH cPortChq
	REPLACE LG_OPTICO  WITH cOptico
	REPLACE LG_PORTOPT WITH cPortOpt
	REPLACE LG_PINPAD  WITH cPinPad
	REPLACE LG_PORTPAD WITH cPortPad
	REPLACE LG_PADMSG  WITH cPadMsg
	REPLACE LG_CMC7    WITH cCMC7
	REPLACE LG_PORTMC7 WITH cPortCMC7
	
	If SLG->( ColumnPos("LG_CMC7DIR")) > 0
		REPLACE LG_CMC7DIR WITH cCMC7DIR
	EndIf
	
	REPLACE LG_CARTMAG WITH cCartMag
	REPLACE LG_PORTMAG WITH cPortMag
	REPLACE LG_BALANCA WITH cBalanca
	If !Empty(AllTrim(cBalanca))
		Lj121AltIni(cBalanca)
	EndIf
	REPLACE LG_DIRBAL  WITH cDirBal
	REPLACE LG_GAVETA  WITH cGaveta
	REPLACE LG_PORTGAV WITH cPortGav
	REPLACE LG_GAVSTAT WITH lGavStat
	If SLG->( ColumnPos("LG_PORTBAL")) > 0
		REPLACE LG_PORTBAL WITH If(Empty(cBalanca),Space(5),cPortBal)
	EndIf
	If SLG->( ColumnPos("LG_TIMEBAL")) > 0
		REPLACE LG_TIMEBAL WITH If(Empty(nTimeOut),0,nTimeOut)
	EndIf
	REPLACE LG_DISPLAY WITH cDisplay
	REPLACE LG_PORTDIS WITH cPortDis
	
	If SLG->( ColumnPos("LG_DISPTOR") ) > 0
		REPLACE LG_DISPTOR WITH cDispTorre 
	EndIf	
	If SLG->( ColumnPos("LG_PORTTOR") ) > 0
		REPLACE LG_PORTTOR WITH cPortTorre 
	EndIf

	If SLG->( ColumnPos("LG_RFID") ) > 0 
		REPLACE LG_RFID WITH Substr(cRFID,1,1) 
	EndIf	
	
	If SLG->( ColumnPos("LG_IDRFID") ) > 0 
		REPLACE LG_IDRFID WITH cGetIDRFID
	EndIf
	
	// Grava informações referentes ao SAT
	 If SLG->(ColumnPos("LG_USESAT")) > 0 
        REPLACE LG_USESAT WITH IIF( cAtivSAT == "Sim", .T., .F.)
    EndIf

    If SLG->(ColumnPos("LG_FABSAT")) > 0 
        REPLACE LG_FABSAT WITH cSAT
    EndIf
    
    If SLG->(ColumnPos("LG_MODSAT")) > 0 
        REPLACE LG_MODSAT WITH cModelSAT
    EndIf
    
    If SLG->(ColumnPos("LG_CODSAT")) > 0 
        REPLACE LG_CODSAT WITH cCodSAT
    EndIf
    
    If SLG->(ColumnPos("LG_SERSAT")) > 0 
        REPLACE LG_SERSAT WITH cSerSAT
    EndIf
 
    If SLG->( ColumnPos("LG_CHVREQ") ) > 0 
        REPLACE LG_CHVREQ WITH cChvReq
    EndIf

    If SLG->( ColumnPos("LG_CHVVLD") ) > 0 
        REPLACE LG_CHVVLD WITH cChvVld
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravando informacoes referente a escolha da interface³
	//³Touch screen                                         ³
	//³Desktop                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SLG->( ColumnPos("LG_TIPTELA") ) > 0
		REPLACE LG_TIPTELA  WITH AllTrim(Str(nTipoTela))
	EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³modelo do touch screen a ser utilizado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SLG->( ColumnPos("LG_TOUCH") ) > 0
		REPLACE LG_TOUCH  WITH cTouch
	EndIf	
	
	REPLACE LG_IMPTEF  WITH Left(cImpTEF,1)
	REPLACE LG_IMPTEFC WITH If(nImpTEFC = 1,"S","N")
	REPLACE LG_TEFVIAS WITH Val(cTEFVias)
	REPLACE LG_TIPTEF  WITH Str(nTipTEF,1)
	REPLACE LG_TERMTEF WITH nTermTEF
	REPLACE LG_DIRTTX  WITH cDirTTX
	REPLACE LG_DIRTRX  WITH cDirTRX
	If SLG->( ColumnPos("LG_IPSITEF")) > 0
		REPLACE LG_IPSITEF WITH cIPSiTEF
	EndIf
	REPLACE LG_TEFCONS WITH cTEFCons
	REPLACE LG_RPCSRV  WITH cRPCSrv
	REPLACE LG_RPCPORT WITH cRPCPort
	REPLACE LG_RPCENV  WITH cRPCEnv
	REPLACE LG_RPCEmp  WITH cRPCEmp
	REPLACE LG_RPCFil  WITH cRPCFil
	REPLACE LG_RPCINT  WITH nRPCInt
	REPLACE LG_JOURNAL WITH cJournal
	REPLACE LG_INTCNS  WITH lIntCns
	REPLACE LG_DIRORI  WITH cDirOri
	REPLACE LG_DIRDES  WITH cDirDes
	REPLACE LG_DIREXEC WITH cDirExec
	REPLACE LG_REDECNS WITH cRedeCns
	REPLACE LG_LOJACNS WITH cLojaCns
	REPLACE LG_CTRCNS  WITH cCtrCns
	REPLACE LG_TSCSRV  WITH cTSCSrv
	REPLACE LG_TSCPORT WITH cTSCPort
	REPLACE LG_MSGCUP  WITH cMsgCup
	REPLACE LG_WSSRV   WITH cWebSvc
	If SLG->(ColumnPos("LG_WSSRVMT")) > 0
		REPLACE LG_WSSRVMT WITH cWebMtz     
	EndIf
	REPLACE LG_CRDIMP  WITH Str(aScan( RetSx3Box( Posicione("SX3", 2, PadR("LG_CRDIMP",10), "X3CBox()" ),,, 1 ), { |x| Alltrim(x[3])==Alltrim(cCrdImp) } ) ,1,0)
	REPLACE LG_CRDVIAS WITH nCrdVias
	REPLACE LG_CRDXINT WITH Str(aScan( RetSx3Box( Posicione("SX3", 2, PadR("LG_CRDXINT",10), "X3CBox()" ),,, 1 ), { |x| Alltrim(x[3])==Alltrim(cCrdXInt) } ) ,1,0)
	
	If SLG->( ColumnPos("LG_TAMSER")) > 0
		REPLACE LG_TAMSER WITH cTamSer
	EndIf       
	
	If SLG->( ColumnPos("LG_IMPCUFA")) > 0
		REPLACE LG_IMPCUFA WITH lChkTiFa
	EndIf
	
	If SLG->( ColumnPos("LG_PVAUTNF")) > 0
		REPLACE LG_PVAUTNF WITH IIf(cChkPvNf=="S",.T.,.F.)
	EndIf 
	
	If SLG->( ColumnPos("LG_TKTFACT")) > 0
		REPLACE LG_TKTFACT WITH cRecTktFat
	EndIf 
	
	//Somente se for Call Center efetua a gravacao do tipo de Empresa
	If lCall	
		REPLACE LG_TIPOATE WITH cTipoEmp
	EndIf	
	If SLG->(ColumnPos("LG_REDES")) > 0
		cRedes := "00" + Iif(lRecarga, "1", "0")
		REPLACE LG_REDES WITH cRedes
	EndIf
	
	If SLG->(ColumnPos("LG_LARGCOL")) > 0
		Replace LG_LARGCOL With nLargCol
	Endif
	
	If cModulo != "FAT"
		Replace LG_NFCE With lEmitNfce
	EndIf
	
	If (lEmitNFCe .Or. cAtivSAT == "Sim") .AND. SLG->(ColumnPos("LG_SERNFIS")) > 0
		Replace SLG->LG_SERNFIS With PadR( cSerNFis, TamSX3("LG_SERNFIS")[1] )
	EndIf
	
	//Grava Informações Tef Mexico
	If cPaisLoc == "MEX" 
		REPLACE LG_COMPANY	WITH cCompany	// Companhia Centro de Pagos
		REPLACE LG_SETURL	WITH cUrlServ	// Url Centro de Pagos
		REPLACE LG_BRANCH	WITH cBranch 	// Unid Centro de Pagos
		REPLACE LG_COUNTRY  WITH cContry	// Pais Centro de Pagos
		REPLACE LG_MERCHAN	WITH cMerchant 	// Nº Afiliação Centro de Pagos
		REPLACE LG_USERCP	WITH cUserCp	// Usuario Centro de Pagos
		REPLACE LG_PWDCP	WITH cPwsCp		// Senha Centro de Pagos
		REPLACE LG_OPTYPE	WITH cOpType	// Tip Ope Centro de Pagos
		REPLACE LG_CURRENC	WITH cCurrenc 	// Moeda Centro de Pagos	
	EndIf  
	
	If SLG->(ColumnPos("LG_ISPOS")) > 0   
		REPLACE LG_ISPOS	WITH cIsPOS 	// Moeda Centro de Pagos
	EndIf
	
	/*Integracao com o POS - Synthesis */
	If lIntPOS .AND. SLG->(ColumnPos("LG_POSFLAG") > 0) .And. SLG->(ColumnPos("LG_POSDTEX") > 0)
		REPLACE LG_POSFLAG	WITH cIntPos	// Flag Integracao POS
		REPLACE LG_POSDTEX	WITH CtoD("")	// Data Integracao POS
	EndIf
	
	//Hotelaria - Grava a Serie do PDV informada pelo usuario
	If lIntegHtl
		REPLACE LG_SERPDV	WITH cSerPdv
	EndIf

	IF SLG->(ColumnPos("LG_CRECFPA")) > 0
		REPLACE LG_CRECFPA WITH cCredECF
	EndIf
	
	//Campos referentes a Homologação 2017 - PAF-ECF
	If SLG->(ColumnPos("LG_PAFMD5")) > 0
		REPLACE LG_PAFMD5 WITH STxPafMd5("SLG")
	EndIf
	
	If !Empty(AllTrim(cIPImpRD))
		REPLACE LG_IPIMPRD WITH cIPImpRD
	EndIf

	//PDV Online
	If SLG->(ColumnPos("LG_PDVON")) > 0
		REPLACE LG_PDVON WITH cIsOnline
	EndIf
		
	If SLG->(ColumnPos("LG_TIPOPAF")) > 0
		REPLACE LG_TIPOPAF WITH cTipoPAF
	EndIf
	SLG->(MsUnlock())
	
	/* Execucao da Thread FRTA020, Responsavel por enviar
	 	os Dados ao Servidor via RPC.                    */
	cJobs := AllTrim(GetPvProfString("OnStart", "Jobs", "", GetAdv97()))
	lOnStart := If(Len(cJobs) == 0, .F., .T.)							// Verifica a existencia desta secao
	If At("APFrontLoja",cJobs) > 0									// Elimina a Chamada do Job APFrontLoja
		cJobs := Stuff(cJobs, At("APFrontLoja",cJobs), 12, "")
	EndIf
	cJobs := If(Left(cJobs,1) == ",", SubStr(cJobs,2), cJobs)			// Elimina "," (virgulas) excedentes
	cJobs := If(Right(cJobs,1) == ",", SubStr(cJobs,1,Len(cJobs)-1), cJobs)
	For nI := 1 To Len(cJobs)
		If SubStr(cJobs,nI,2) == ",,"
			cJobs := Stuff(cJobs, nI, 2, ",")
			lAltConfig  := .T.
		EndIf
	Next nI
	
	If !lAmbOffLn
		cJobs := If(Empty(cRMTEnv),"","APFrontLoja")+If(Len(cJobs)>0,",","")+cJobs
	Endif	
	
	If !Empty(cRMTEnv) .OR. lAltConfig .AND. !lAmbOffLn
		WritePProString("OnStart", "Jobs", cJobs, GetAdv97())
	EndIf
	If !Empty(cRMTEnv) .AND. !lAmbOffLn
		WritePProString("APFrontLoja", "Main",			"FRTA020",	GetAdv97())
		WritePProString("APFrontLoja", "Environment",	cRMTEnv,	GetAdv97())
		WritePProString("APFrontLoja", "nParms",		"3",		GetAdv97())
		WritePProString("APFrontLoja", "Parm1",			cRMTEmp,	GetAdv97())
		WritePProString("APFrontLoja", "Parm2",			cRMTFil,	Getadv97())
		WritePProString("APFrontLoja", "Parm3",			cCodigo,	GetAdv97())
	EndIf

	//Grava o PPVISA.INI somente para CliSiTEF e Dedicado Sem Client
	Lj121WIni(nTipTEF, cPinPad, cPortPad, /*cestacao*/, nTipTEFAnt)
	
	Lj121InFim(cTipo)

	//Cadastra a serie no SX5 quando for NFC-e
	If cTipo == "I" .And. SLG->LG_NFCE .And. !SLG->LG_USESAT .And. !Empty(SLG->LG_SERIE)
		lj121CadX5(SLG->LG_SERIE)
	EndIf

	//Grava dados do TEF 2.0 
	If ValType(oCfgTef) == "O"
		oCfgTef:cCodigo := cCodigo
		If lSalvaTef
			oCfgTef:Salvar(cTipo)
		EndIf
	EndIf

EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ LJ121VD  ³ Autor ³ Vendas Clientes       ³ Data ³22/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validar a existencia da uma estacao ja cadastrada          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ121VD(cCodigo)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodigo  - Codigo da Estacao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ121VD(cCodigo)
Local lRet := .T.

DbSelectArea('SLG')
If Empty(cCodigo)
	MsgInfo(STR0075)    	//O código da estação precisa ser informado
	lRet := .F.
ElseIf DbSeek(xFilial('SLG')+cCodigo)
	MsgInfo(STR0045)        //Estacao ja Cadastrada
	lRet := .F.
EndIf
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ LJ120VD2 ³ Autor ³ Vendas Clientes       ³ Data ³22/07/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validar os objetos de configuracao das estacoes            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJ120VD2(cTip,cImp,cPorta,oPorta,cHard)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTip  - Tipo de validacao a ser feito sendo :              ³±±
±±³          ³       If : Impresoora fiscal, caso o modelo seja BEMATECH  ³±±
±±³          ³            "BEMATECH MP40FI II", definir tambem como Imp.  ³±±
±±³          ³            de Chque.Caso nome seja branco desebilitar Porta³±±
±±³          ³      PIf : Porta da impressora fiscal, caso seja definido  ³±±
±±³          ³            impressora forcar o cadastro de uma porta.      ³±±
±±³          ³     ICHQ : Impresoora Chque , caso o modelo seja BEMATECH  ³±±
±±³          ³            "BEMATECH MP40FI II", definir tambem como Imp.  ³±±
±±³          ³            Fiscal  .Caso nome seja branco desebilitar Porta³±±
±±³          ³     PCHQ : Porta da impressora Cheque, caso seja definido  ³±±
±±³          ³            impressora forcar o cadastro de uma porta.      ³±±
±±³          ³     COMP : Impressao do comprovante de TEF seja na imp.    ³±±
±±³          ³            Fiscal ter impressora cadasrada, ou na de CUPOM ³±±
±±³          ³     VIAS : Numero de vias maior que zero sem impressoara   ³±±
±±³          ³            definida                                        ³±±
±±³          ³      IMP : Desabilita porta quando nome da imprssora em    ³±±
±±³          ³            branco                                          ³±±
±±³          ³      POR : forca entrada de uma porta  caso seja definido  ³±±
±±³          ³            impressora.                                     ³±±
±±³          ³ cImp  -   Periferico que esta sendo configurado            ³±±
±±³          ³ cPorta-   Porta do periferico que esta sendo configurado   ³±±
±±³          ³ oPorta-   Objeto da Porta do periferico que esta sendo     ³±±
±±³          ³           configurado                                      ³±±
±±³          ³ cHard-   Descicao do periferico que esta sendo configurado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ120VD2( cTip   , cImp , cPorta, oPorta,;
				   cHard  , cImp2, oImp2 , cPorta2,;
				   oPorta2, cImp3 )
Local lRet := .T.

If cTip = "IF"
	If Empty(cImp)
		cPorta := Space(5)
		oPorta :Disable()
	Else
		oPorta :Enable()
	EndIf
	
	If !Upper(cImp) == "BEMATECH MP40FI II"
	   If ValType(oImp2) == "O"
		  oImp2:Enable()
	   EndIf
	   If ValType(oPorta2) == "O"	   	  
		  oPorta2:Enable()
	   EndIf	  
	EndIf
	
EndIf

If cTip = "PIF"
	If !Empty(cImp) .AND. Empty(cPorta)
		MsgInfo( STR0054 + cHard + " " + cImp) // Definir porta de Comunicacao para
		lRet := .F.
	Else
		If ( Upper(cImp) == "BEMATECH MP40FI II") .OR. ( Upper(cImp) == "SIGTRON FS2000").OR. ( Upper(cImp) == "SWEDA IFS II V1.00")
			cImp2   := cImp
			cPorta2 := cPorta
			oImp2   :Disable()
			oPorta2 :Disable()
		EndIf
	EndIf
EndIf

If cTip = "ICHQ"
	
	If Empty(cImp)
		cPorta := Space(5)
		oPorta:Disable()
	Else
		oPorta:Enable()
	EndIf
	
	If !Upper(cImp) == "BEMATECH MP40FI II"
	   If ValType(oImp2) == "O"	
		  oImp2:Enable()
	   EndIf
	   If ValType(oPorta2) == "O"	   	  
		  oPorta2:Enable()
	   EndIf	  
	EndIf
	
EndIf

If cTip = "PCHQ"	
	If !Empty(cImp) .AND. Empty(cPorta)
		MsgInfo(STR0055+" "+cImp) //"Definir porta de Comunicacao para Impressora de Cheque "
		lRet := .F.
	EndIf
EndIf

If cTip == "COMP"
	oPorta:Enable() //oPorta->oVias
	If Left(cImp,1) = "F" .AND. Empty(cImp2)	// cImp->cImpTEF,cImp2->cImpFisc
		MsgInfo(STR0056)						// Impressora fiscal nao definida
	ElseIf Left(cImp,1) = "C".AND.Empty(cImp3)	// cImp->cImpTEF,cImp3->cImpCup
		MsgInfo(STR0057)						// Impressora de cupom nao definida
	ElseIf Left(cImp,1) = "N"					// cImp->cImpTEF
		cPorta:= "0"							// cPorta->cTEFVias
		oPorta:Disable()						// oPorta->oVias
	EndIf
	oPorta:refresh()							// oPorta->oVias
	lRet := .F.
EndIf

If cTip == "VIAS"
	If Left(cImp,1)$ "N" .AND. Val(cPorta)>0  // cImp->cImpTEF,cPorta->cTEFVias
		MsgInfo(STR0058)              // Definir Local de Impressao
	EndIf
EndIf

If cTip = "IMP"
	If Empty(cImp)
		cPorta := Space(Len(cPorta)	)
		oPorta:Disable()
	Else
		oPorta:Enable()
	EndIf
EndIf

If cTip == "POR"
	If !Empty(cImp) .AND. Empty(cPorta)
		MsgInfo(STR0054 + cHard + " " + cImp)
		lRet := .F.
	EndIf
EndIf

If cTip == "PORL" .AND. cImp=="METROLOGIC MS700i"
	If !Empty(cImp) .AND. Empty(cPorta)
		MsgInfo(STR0054 + cHard + " " + cImp)
		lRet := .F.
	EndIf
EndIf

If cTip == "CRDVIAS"
	If Alltrim(cImp) == Alltrim(RetSx3Box( Posicione("SX3", 2, PadR("LG_CRDIMP",10), "X3CBox()" ),,, 1 )[1,3])
		cPorta := 0			// Utilizado aqui para informar o numero de vias do comprovante do SIGACRD
		oPorta:Refresh()
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ LjGetFolder ³ Autor ³Vendas Clientes        ³ Data ³08/06/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verificar quais os folders que serao exibidos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                               ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjGetFolder( aFolder, aPrompts )
Local nFolder := 0        			// controle de loop
Local cDigits := "1234C567"
Local cFolder := ""
Local aNames  := {	{"1",STR0014},; //"Impressoras"
					{"2",STR0015},;	//"Leitores
					{"3",STR0089},; //"Outros"
				  	{"4",STR0017},; //"TEF"
					{"C",STR0259},; //"TEF Totvs Pdv"
					{"5",STR0074},;	//"Back Office Front Loja"
					{"6",STR0079},;	//"Cheque-pre.com"
				  	{"7",STR0103}} 	//"Integrações"					  
Local aAux    := {}
Local lUsePayHub 	:= ExistFunc("LjUsePayHub") .And. LjUsePayHub()

If cPaisLoc == 'BRA'
	//Se o estado pode utilizar o SAT 
	If LjAnalisaLeg(70)[1]
		cDigits += "8"
		cFoldEst := cDigits
		aAdd(aNames, { "8",cSiglaSat} )	//SAT ou MFE
	EndIf
	
	//Tratamento para add a pasta de NFc-e
	cDigits += "9"
	cFoldEst := cDigits
	aAdd(aNames, { "9","NFC-e"} )	//NFC-e

	//Tratamento para add a pasta "Totvs Pagamento Digital"
	If lUsePayHub
		cDigits += "0"
		cFoldEst := cDigits
		aAdd(aNames, { "0","Totvs Pagamento Digital"} )	//"Totvs Pagamento Digital"
		lSalvaTef := .T.
	EndIf

EndIf

//Integrações Varejo
If ExistFunc("LjxRaasInt") .And. LjxRaasInt()
    cDigits  += "A"
    cFoldEst := cDigits
    aAdd(aNames, {"A", STR0258} )   //"Painel de Integrações Varejo" 
EndIf

If SLG->(ColumnPos("LG_PDVON")) > 0
	cDigits  += "B"
	cFoldEst := cDigits
	aAdd(aNames, {"B", "Totvs PDV"} )
EndIf

//TEF Totvs Pdv
cDigits  += "C"

cFoldEst:= If(Empty(cFoldEst),"1234567",cFoldEst)

If cPaisLoc <> "BRA" .AND. Len(cFoldEst) == 6
   cFoldEst := Stuff( cFoldEst,6, 1, "")
   cFoldEst := Stuff( cFoldEst,4, 1, "")   
EndIf

For nFolder := 1 To Len(cFoldEst)
	cFolder:= SubStr(cFoldEst,nFolder,1)
	If (cFolder $ cDigits)
		Aadd(aFolder,cFolder)
		Aadd(aAux,aNames[Ascan( aNames,{|aFold| aFold[1] == cFolder})][2])
	EndIf
Next nFolder

If (Len(aAux) > 0)
	aPrompts:= Array(2,Len(aAux))
	For nFolder := 1 To Len(aAux)
		aPrompts[1,nFolder]:= aAux[nFolder]
		aPrompts[2,nFolder]:= "HEADER"
	Next nFolder
	
EndIf           

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ LJDirect   | Autor ³ Vendas Clientes     ³ Data ³17/08/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a existencia do diretorio e questiona se deseja   ³±±
±±³          ³ cria-lo                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LJDirect(cPath,lDrive)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPath      - Caminho a ser verificado/criado diretorio     ³±±
±±³          ³ lDrive     - Flag para controlar a digitacao da unid. drive³±±
±±³          ³              .T. -> tera que informar a unidade de drive   ³±±
±±³          ³              .F. -> Nao contrala a unidade de drive        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJDirect( cPath, lDrive )
Local aDir
Local lRet:=.T.

If Empty(cPath)
	Return lRet
EndIf
lDrive := If(lDrive == Nil, .T., lDrive)
cPath := Alltrim(cPath)
If Subst(cPath,2,2) <> ":\" .AND. lDrive
	MsgInfo(STR0095) //"Unidade de drive n„o especificada"
	lRet:=.F.
Else
	cPath := If(Right(cPath,1) == "\", Left(cPath,Len(cPath)-1), cPath)
	aDir  := Directory(cPath,"D")
	If Len(aDir) = 0
		If MsgYesNo(STR0043+" - "+cPath+" - "+STR0094 ) //"Diretorio  -  nao encontrado, deseja cria-lo "
			If MakeDir(cPath) <> 0
				Help(" ",1,"NOMAKEDIR")
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SrvCnsOk ³ Autor ³ Vendas Clientes       ³ Data ³10/10/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cheque-pre - Habilitar e desabilitar campos da configuracao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SrvCnsOk(lIntsrv,odirOri,oDirDes,oDirExec,oRedeCns,		  ³±±
±±³          ³          oLojaCns,oCtrCns)                          		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodEst  - Codigo da Estacao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SrvCnsOk( lIntsrv , odirOri , oDirDes, oDirExec,;
				   oRedeCns, oLojaCns, oCtrCns )
If  lIntSrv
	oDirOri:Enable()
	oDirDes:Enable()
	oDirExec:Enable()
	oRedeCns:Enable()
	oLojaCns:Enable()
	oCtrCns:Enable()
Else
	oDirOri:Buffer  := Space(50)
	oDirOri:cText   := Space(50)
	oDirDes:Buffer  := Space(50)
	oDirDes:cText   := Space(50)
	oDirExec:Buffer := Space(50)
	oDirExec:cText  := Space(50)
	oRedeCns:Buffer := Space(10)
	oRedeCns:cText  := Space(10)
	oLojaCns:Buffer := Space(10)
	oLojaCns:cText  := Space(10)
	oCtrCns:Buffer  := Space(10)
	oCtrCns:cText   := Space(10)
	
	oDirOri:Disable()
	oDirDes:Disable()
	oDirExec:Disable()
	oRedeCns:Disable()
	oLojaCns:Disable()
	oCtrCns:Disable()
EndIf
oDirOri:Refresh()
oDirDes:Refresh()
oDirExec:Refresh()
oRedeCns:Refresh()
oLojaCns:Refresh()
oCtrCns:Refresh()      

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SrvChlDir ³ Autor ³ Vendas Clientes       ³ Data ³20/11/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cheque-pre - Verifica a existencia do diretorio             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SrvChkDir(cdir)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cdir  - Diretorio                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SrvChkDir( cdir, lRoot )
If Right(Alltrim(cdir),1) <> "\"
	cDir := Padr(Alltrim(cdir) + "\" ,Len(cdir))
EndIf

Return LjDirect(cDir)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjCallPostoºAutor  ³Vendas Clientes     ºData ³ 14/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica no cadastro de Grupo de Atendimento do modulo de  º±±
±±º          ³CALL CENTER se esse registro da Estacao esta sendo usada   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³LjCallPosto(cEstacao)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cExpC1 - Codigo da estacao que sera avaliada.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjCallPosto( cEstacao )

Local lRet 	:= .F. 						// Retorno da funcao
Local aArea := GetArea()				// Salva a area atual

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procura no cadastro de Grupo de Atendimento se o codigo da Estacao esta sendo usado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU0")
DbSetOrder(1) 
DbSeek(xFilial("SU0"))
While (!Eof()) .AND. (SU0->U0_FILIAL == xFilial("SU0"))

	If U0_ESTACAO == cEstacao
		Help(" ",1,"TK_U0ESTAC")
		lRet := .T.
		Exit
	EndIf          
	
	DbSelectArea("SUO")
	DbSkip()
End

RestArea(aArea)                      

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjONChTEF ºAutor  ³Vendas Clientes     º Data ³  25/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Habilita e desabilita objetos em tela.                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpN1 - Tipo do TEF                                        º±±
±±º          ³ ExpB1 - Desabilita o botao do TEF        				  º±±
±±º          ³ ExpB2 - Habilita o botao do TEF							  º±±
±±º          ³ ExpL1 - Verifica se habilita ou desabilita o objeto		  º±±
±±º          ³ ExpO1 - Objeto de tela para ser habilitado ou desabilitado º±±
±±º          ³ ExpO2 - Objeto de tela para ser habilitado ou desabilitado º±±
±±º          ³ ExpO3 - Objeto de tela para ser habilitado ou desabilitado º±±
±±º          ³ ExpC1 - Tipo de impressao TEF                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA121                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjONChTEF( 	nTipTef	, bTefDis	, bTefEnab	, oPanel	, ;
							oObj1	, oObj2		, oObj3 	, cImpTef	, ;
							cTipo 	)

If Upper(cTipo) == "A"
	RecLock("SLG", .F.)
	LG_TEFCONS := "NNNNNNN"
	MsUnLock()
EndIf
Do Case
	Case nTipTef == 1
		EVAL( bTefDis )
		oObj3:Disable()
		oObj3:Refresh()
		oPanel:Hide()

	Case nTipTef == 2 .OR. nTipTef == 3 .OR. nTipTef == 4 .OR. nTipTef == 5 .OR. (nTipTef == 6 .AND. lCall)
		EVAL( bTefEnab )
		oPanel:Hide()
		oObj1:Disable()
		oObj1:Refresh()
		If lCall
	   		If nTipTef == 3 
				oObj3:Enable()
				oPanel:Hide()
			ElseIf nTipTef == 6
				oObj3:Enable()
				oPanel:Show()
			EndIf
		ElseIf nTipTef == 4 .OR. nTipTef == 5
			oObj3:Enable()
		Else
			oObj3:Disable()
		EndIf
		
		oObj3:Refresh()
		
	Case nTipTef == 6
		EVAL( bTefEnab )
		oObj1:Enable()
		oObj1:Refresh()
		oObj2:Enable()
		oObj2:Refresh()
		oObj3:Enable()
		oObj3:Refresh()
		oPanel:Show()
		cImpTEF := SLG->LG_IMPTEF
EndCase

Return( Nil )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJA121   ºAutor  ³Vendas Clientes     º Data ³  31/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que escreve no arquivo CLISITEF.INI, conforme confi- º±±
±±º          ³guracoes do cadastro de estacao.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ExpN1 - Tipo de transacao                                   º±±
±±º          ³ExpC1 - Nome do arquivo CLISITEF                            º±±
±±º          ³ExpC2 - Diretorio do cliente                                º±±
±±º          ³ExpC3 - Porta do Pin-Pad                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Logico                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJWriteClis(nTipTef, cClisitef, cClientDir, cPortPad, nTipTEFAnt)
Local cRedes 	:= If(SLG->(ColumnPos("LG_REDES")) > 0, SubStr(SLG->LG_REDES, 1, 1), "0")		// Rede escolhida
Local cTefCons  := If(SubStr(SLG->LG_TEFCONS, 2, 1)=="S", "1", "0")							// Tef de consulta
Local cRecCel	:= If(SLG->(ColumnPos("LG_REDES")) > 0, SubStr(SLG->LG_REDES, 3, 1), "0")		// Recarga de celular
  

If nTipTef == 6 .And. nTipTef <> nTipTEFAnt
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Faço backup do arquivo CLISITEF.INI atual e crio um novo ³
	//³com as novas configurações                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File(cClientDir + "CLISITEF.MS")
		__CopyFile(cCliSitef, cClientDir + "CLISITEF.MS")
	EndIf
	If File(cCliSitef)
		FErase(cCliSitef)
	EndIf
	nHandle := FCreate(cCliSitef)
	FClose(nHandle)
	If nHandle > 0
		WriteFileTxt(	{	"[PagamentoContas]"												, ;
							"HabilitaPagamentoContas="				+ cRedes 				, ;
							""																, ;
							"[REDES]"														, ;
							";HabilitaRedeInfocard="				+ cRedes 				, ;
							";HabilitaRedeTelecheque=" 				+ cTefCons 				, ;
							";HabilitaRecargaCelular="				+ cRecCel				, ;
							""																, ;
							"[RecargaCelular]"												, ;
							";HabilitaRecargaCelular="				+ cRecCel				, ;
							";TipoConfirmacaoNumeroCelular="		+ cRecCel				, ;
							"HabilitaRecargaMultiConcessionaria="	+ cRecCel				, ;
							";RecargaCelularMultiplaPorFilial="		+ cRecCel				, ;
							""																, ;
							"[Cheques]"														, ;
							"NomeArqCheques=Cheque.ini"										, ;
							""																, ;
							"[Geral]"														, ;
							"{Recarga de Celular:Dinheiro,Cheque,Débito,Credito}"			, ;
							"TransacoesAdicionaisHabilitadas=50;51;52;53;54;55;60;61;62;63" , ;
							"TransacoesAdicionaisHabilitadas=10;11;12;13;14"				, ;
                            ""                                                              , ;
							"[PINPADCOMPARTILHADO]"											, ;
							"Porta=" + PadL(Substr(cPortPad,4,1), 2, "0") 					, ;
							""																, ;
							"[VIDALINK]"													, ;
							"VERSAO=03"														},;
							cCliSitef )
	EndIf
EndIf


Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WriteFileTxt ºAutor  ³Vendas Clientes     º Data ³  08/13/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para escrever no arquivo TXT conforme os parametros.   º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ ExpA1 - Chave para ser criana no arquivo TXT                  º±±
±±º          ³ ExpA2 - Tipo do servico a ser criado                          º±±
±±º          ³ ExpA3 - Habilita servico ou desabilita                        º±±
±±º          ³ ExpC1 - Arquivos a ser criado                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FRONTLOJA                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function WriteFileTxt(aChave, cArquivo)

Local nI 		:= 0				// Controle do FOR
Local nHandle 	:= 0				// Varialvel do Handle do arquivo

For nI := 1 to Len(aChave)
	nHandle := FOpen(cArquivo, 2)
    FSeek(nHandle, 0, 2)
    FWrite( nHandle, aChave[nI] + Chr(13) + Chr(10), Len(aChave[nI])+2 )
	FClose(nHandle)
	nHandle := 0
Next nI
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjModelo     ºAutor  ³Vendas Clientes     º Data ³  10/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta uma string somente com os modelos dos equipamentos      º±±
±±º          ³ definidos no primeiro parametro da funcao                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ ExpC1 - Modelo de impressora a ser visualizado no cadastro de º±±
±±º          ³         estacoes                                              º±±
±±º          ³ ExpC2 - String contendo todos os modelos de impressoras       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjModelo( xModelo, cLista )
Local nPos		 				// Variavel de loop
Local cListaAux		:= ""		// Listagem com os modelos de impressoras
Local nTamcLisAux	:= 0		// Tamanho da String auxiliar
Local nX			:= 0
Local aModelo		:= {}

DEFAULT xModelo		:= ""

If ValType(xModelo) == "A"
	aModelo			:= 	aClone(xModelo)
ElseIf !Empty(xModelo)
	AAdd(aModelo , xModelo )     	
EndIf

For nX := 1 To Len(aModelo)
	If !Empty(aModelo[nX])
		While At(aModelo[nX],cLista) <> 0
			nPos	   := At(aModelo[nX],cLista)
			cLista 	   := SubStr(cLista,nPos)
			cListaAux  += '"' + SubStr(cLista, 1, At('"',cLista)-1) + '"' + ","  
			cLista 	   := SubStr(cLista,At('"', cLista))
		End
	EndIf
Next nX
nTamcLisAux := Len(cListaAux)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retira a ultima virgula³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLista := SubStr(cListaAux,1,nTamcLisAux-1)

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LJQuebraImpr³ Autor ³ Vendas Clientes 	  ³ Data ³11/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Transforma uma string com a lista de impressoras (dll), em 	³±±
±±³          ³ um array, quebrado por fabricante, modelo e versao.        	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - String contendo todos os modelos de impressoras  	³±±
±±³          ³ ExpA1 - Array que amazenara' os modelos das impressoras    	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJQuebraImpr(cLista, aEstrutImp)
Local nPosF		 := 0	  			// Variavel de loop.
Local aListaF    := {}	   			// Retorno da funcao.
Local cImpFabAtu := "cImpFabAtu"	// String inicial.
Local cListImp   := ""				// Armazena a listagem das impessoras.
Local nFirst     := 1				// Identifica primeira impressora para abrir o array com primeira posicao vazia.

While Len(cLista) <> 0
    If nFirst = 1
	    nPosF      := At(' ',cLista)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ ABRE array Fabricante & Preenche 1ª Posicao com vazio & Preenche segunda 2ª Posicao com Impressora da DLL.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        cListImp   := '{ "" , "' + cListImp + SubStr(cLista , 2 , nPosF-2 ) + '" ,"'    
        cImpFabAtu := SubStr(cLista , 2 , nPosF-2 )
    Else
        If cImpFabAtu <> SubStr(cLista , 1 , nPosF-2 )
            cListImp    := cListImp + SubStr(cLista , 1 , nPosF-2 ) + '" ,"'
            cImpFabAtu := SubStr(cLista , 1 , nPosF-2 )
        EndIf
    EndIf
	If at('","',cLista) <> 0
	    cLista     := SubStr(cLista, at('","',cLista)+3 )
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ E´ a ultima impressora ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		IF Left(Alltrim(cLista),1)=='"'
			cLista     := SubStr(cLista, 2, at(' ',cLista)-1 )		
		Else
			cLista     := SubStr(cLista, 1, at(' ',cLista)-1 )
		EndIf	
		If cImpFabAtu <> cLista
			cListImp    := cListImp + cLista + '" , "'
		EndIf
		cLista := ""
	EndIf
    nPosF      := at(' ',cLista)+1

    nFirst     := 0

End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ FECHA Todos os array´s³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If cListImp == ""
	cListImp   := '{"",""}'
Else
	cListImp   := SubStr(cListImp,1,Len(cListImp)-3) + '}'                         
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transforma a string cListImp no array aEstrutImp³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEstrutImp := &cListImp                                                        

Return( aListaF )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LJImpFabric³ Autor ³ Vendas Clentes  		 ³ Data ³11/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria um array somente com os "Fabricantes" das impressoras. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array que amazenara' os modelos das impressoras     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJImpFabric( aEstrutImp )
Local nLoop		:= 0  		// Controle de loop
Local aRet		:= {}	   	// Retorno da funcao

Default aEstrutImp := {}

For nLoop := 1 To Len(aEstrutImp)
	aAdd(aRet, aEstrutImp[nLoop])
Next nLoop

Return (aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LJImpModelo³ Autor ³ Vendas Clientes 	  ³ Data ³11/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria um array somente com os "Modelos" das impressoras.    	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Array que amazenara' os modelos das impressoras      ³±±
±±³          ³ ExpC2 - Fabricante                                           ³±±
±±³          ³ ExpA3 - Array com os modelos das impressoras                 ³±±
±±³          ³ ExpO4 - Objeto                                               ³±±
±±³          ³ ExpC5 - Opcao escolhida (INCLUSAO - ALTERACAO - VISUALIZACAO)³±±
±±³          ³ ExpC6 - String com os modelos das impressoras                ³±±
±±³          ³ ExpC7 - String com os modelos das impressoras                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJImpModelo(aImpList, cFabricante, aModelo , oImpFMod,;
					 cTipo 	 , cImpFMod   , cAltFMod)
					 
Local nLoop   := 0			// Controle de loop
Local nTamFab := 0			// Tamanho da string com os nomes do fabricantes

Default aImpList 	:= {}
Default cFabricante := ""
Default aModelo 	:= {}
Default oImpFMod 	:= Nil
Default cTipo 		:= ""
Default cImpFMod 	:= ""
Default cAltFMod 	:= "" 

aModelo := {}
nTamFab := Len(cFabricante)

For nLoop := 1 To Len(aImpList)
    If nTamFab > 0 .AND. cFabricante == SubStr(aImpList[nLoop] , 1 , nTamFab)
		aadd(aModelo, aImpList[nLoop])
	EndIf
Next
If Len(aModelo) <> 0
	oImpFMod:Enable()
	oImpFMod:SetItems(aModelo)
	If cTipo $ "AVE"
		cImpFMod := cAltFMod
	EndIf
	oImpFMod:Refresh()
Else
    If nTamFab == 0
    	oImpFMod:SetItems({Space(20)})
    EndIf
	oImpFMod:Disable()
	oImpFMod:Refresh()
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LJGeraNome| Autor ³ Vendas Clientes 		³ Data ³19/12/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria a string com o nome completo da impressa.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - String com os modelos das impressoras              ³±±
±±³          ³ ExpC2 - String com os modelos das impressoras              ³±±
±±³          ³ ExpC3 - Opcao escolhida (INCLUSAO - ALTERACAO - VISUALIZACA³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJGeraNome(cImpFisc , cImpFMod , cTipo)

If cTipo <> "V" .AND. cTipo <> "E"
  	cImpFisc := cImpFMod
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LjValPVAut| Autor ³ Vendas Clientes 		³ Data ³22/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida se existe alguma estacao autorizada a emitir NF.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Codigo da estacao atual                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjValPVAut(cCodigo,oChkPvNf,cChkPvNf)
Local lRet	:= .T.
Local aArea	:= GetArea()									// Array contendo informações da area

DbSelectArea("SLG")
DbSetOrder(1)
DbSeek(xfilial("SLG"), .T.)

While !EOF() .AND. (xFilial("SLG") == SLG->LG_FILIAL)
	If SLG->LG_PVAUTNF .AND. SLG->LG_CODIGO <> cCodigo
		MsgAlert(STR0165+SLG->LG_CODIGO+STR0166+;			// "A estação " + SLG->LG_CODIGO + "já está autorizada para emissão de nota fiscal."
					Chr(10)+Chr(13)+STR0167)				// "Somente um estação por filial pode ser autorizada."
		lRet := .F.
		cChkPvNf := "N"
		oChkPvNf:Set(cChkPvNf)
		oChkPvNf:Refresh()
		Exit
	EndiF
	DbSkip()
End

RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj121Integ³ Autor ³ Vendas CRM			³ Data ³ 31/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Responsavel em gerar os dados da integracao  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastro de Estacao                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj121Integ(cTipOpInt)

Local lRetorno	:= .T.					//Retorno da funcao
Local cChave 	:= ""                  	//Chave do indice
  
If lIntegra .AND. cTipOpInt == "E" .AND. cModulo == "LOJ"
	
	cTipOpInt := "5"
			
	//Instancia o objeto LJCAdapXmlEnvSLG
	oIntegra :=	LJCAdapXmlEnvSLG():New()
	 
	//Prepara a chave
	cChave 	:= xFilial("SLG") + SLG->LG_CODIGO

	//Processa os dados da integracao		
    oIntegra:Inserir("SLG", cChave, "1", cTipOpInt)
	//Gera XML integracao
	oIntegra:Gerar()
	
EndIf
	
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj121InFim³ Autor ³ Vendas CRM			³ Data ³ 31/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Responsavel em finalizar a integracao  			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastro de Estacao                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj121InFim(cTipOpInt)

Local cChave 	:= ""                  	//Chave do indice 1

If cModulo == "LOJ"

	If lIntegra .AND. oIntegra <> Nil .AND. cTipOpInt == "E" 
		
		//Finaliza - Envia EAI		
	    oIntegra:Finalizar()
	    oIntegra := Nil
		
	ElseIf lIntegra
		
		If cTipOpInt == "I" .OR. cTipOpInt == "A" 
			
			If cTipOpInt == "I"
				cTipOpInt := "3"
		
			ElseIf cTipOpInt == "A"
				cTipOpInt := "4"
			EndIf
			
			//Instancia o objeto LJCAdapXmlEnvSLG
			oIntegra := LJCAdapXmlEnvSLG():New()
					 
			//Prepara a chave
			cChave 	:= xFilial("SLG") + SLG->LG_CODIGO
		
			//Processa os dados da integracao		
		    oIntegra:Inserir("SLG", cChave, "1", cTipOpInt)
			//Gera XML integracao
			oIntegra:Gerar()
			//Finaliza - Envia EAI		
	    	oIntegra:Finalizar()
   			    oIntegra := Nil
		
		EndIf
	
	EndIf

EndIf
	
Return Nil


/*                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj121WSMtz    ³ Autor ³ Vendas CRM		    ³ Data ³09/02/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Web Service - Habilitar e desabilitar 					     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj121WSMtz( lMtzOk , oWebMtz )							     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj121WSMtz( lMtzOk , oWebMtz )

Default lMtzOk	:= .F.    	// Verifica existe Ws
Default oWebMtz := Nil  	// Componente de Ws

If oWebMtz <> Nil
	If  lMtzOk
		oWebMtz:Enable()
	Else
		oWebMtz:Disable()
	EndIf            
	
	oWebMtz:Refresh()
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Lj121RpcOk	³ Autor ³ Vendas CRM  	        ³ Data ³09/02/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³RPC - Desabilita Campo RPC quando OFF-Line					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj121RpcOk( oRMTEnv, oRMTEmp, oRMTFil ) 					      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj121RpcOk( oRMTEnv, oRMTEmp, oRMTFil )

Local lAmbOffLn := SuperGetMv("MV_LJOFFLN", Nil, .F.)			//Identifica se o ambiente esta operando em offline

Default oRMTEnv := Nil		// Ambiente
Default oRMTEmp := Nil 		// Empresa
Default oRMTFil := Nil		// Filial

//Desabilita campo quando Ambiente Off-line
If lAmbOffLn
        
	If oRMTEnv <> Nil
		oRMTEnv:Disable()     
		oRMTEnv:Refresh()
	EndIf
	
	If oRMTEmp <> Nil
		oRMTEmp:Disable()     
		oRMTEmp:Refresh()
	EndIf
	
	If oRMTFil <> Nil
		oRMTFil:Disable()     
		oRMTFil:Refresh()
	EndIf		
	
EndIf


Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj121FlChgºAutor  ³Vendas CRM          º Data ³  09/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Abre tela para preenchimento de informacoes do Novo TEF.    º±±
±±º          ³TEF 2.0                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj121FlChg(nDst    , nOption , oFolder , oCfgTef, nOpc,;
                    cAtivSAT, cImpFisc, cCodEst)

	Local lRet 		:= .T.

    Default cCodEst := ""

    Do Case

		Case nDst == 5 .And. ValType(oCfgTef) == "O"
			lSalvaTef := oCfgTef:Show(nOpc)
			lRet	  := .F.

        Case nDst == nNFCeFolder
			Lj121CfgNF(	cAtivSAT, cImpFisc )
			
        //Integrações Varejo
        Case nDst == nFldIntRaas
            If Empty(cCodEst)
            	MsgInfo(STR0075)    //O código da estação precisa ser informado
            Else                
                IntegVarej(cCodEst, .F.)
            EndIf                
            lRet := .F.

    End Case

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjValTktFatºAutor  ³Vendas CRM          º Data ³  28/10/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o campo LG_TKTFACT.                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjValTktFat(oRecTktFat, cRecTktFat)
Local lRet := .T.

If cRecTktFat == "Ticket"
	cRecTktFat := "T"
Else
	cRecTktFat := "S"
EndIf
Return lRet

/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj121USBFiºAutor  ³Vendas CRM          º Data ³  09/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o equipamento possui USB homologado.            º±±
±±º          ³Remonta a lista de portas.      				              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA/SIGAFRT - ESTACAO                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Lj121USBFiltro(aPortIf, cImpFMod, oPortIf)
Local aImpUSB := {}		// Array de impressoras homologadas
Local aIFisUSB:= {}
Local aImpREDE:= {}
Local aTpPorta:= {"USB","REDE"}
Local nPos    := 0		// Posicao de registro no Array
Local nX	  := 0
Local cSelPorta	:= ""

DEFAULT aPortIf  := {} 	// Lista de portas de comunicacao
DEFAULT cImpFMod := ""	// Modelo de equipamento selecionado
DEFAULT oPortIf	 := Nil	// Objeto combobox contendo a lista de portas
                  
/*MODELOS DE EQUIPAMENTOS HOMOLOGADOS PARA CONEXAO USB */
AAdd( aImpUSB, { "BEMATECH MP4000 THFI - V. 01.00.02" } )
AAdd( aImpUSB, { "EPSON TM-T88V" } )
AAdd( aImpUSB, { "EPSON TM-T20" } )
AAdd( aImpUSB, { "BEMATECH TH" } )
AAdd( aImpUSB, { "BEMATECH MP-4200 TH 01.00.00(S)" } )

aadd(aIFisUSB,{"BEMATECH MP2100 THFI"})
aadd(aIFisUSB,{"BEMATECH MP4000 THFI"})
aadd(aIFisUSB,{"BEMATECH MP4200 THFI"})
aadd(aIFisUSB,{"EPSON TM-T800"})
aadd(aIFisUSB,{"EPSON TM-T900"})

/* MODELOS DE EQUIPAMENTOS HOMOLOGADOS PARA CONEXAO REDE */
AAdd(aImpREDE, { "BEMATECH MP-4200 TH 01.00.00(S)" })

For nX := 1 to Len(aTpPorta)
	
	If aTpPorta[nX] == "USB"
		/*Se o equipamento estiver homologado, acrescenta o item USB no array  
			Caso contrario, verifica se o array possui USB e o remove da lista*/
		nPos := Ascan( aImpUSB, { |x| x[1] == AllTrim(cImpFMod) } )
		
		//Inclusão de alguns modelos de ECF para a porta USB
		If nPos == 0
			nPos := Ascan( aIFisUSB, { |x| x[1] $ AllTrim(cImpFMod) } )
		EndIf
	EndIf
	
	If aTpPorta[nX] == "REDE"
		nPos := Ascan( aImpREDE, { |x| x[1] $ AllTrim(cImpFMod) } )
		
		If !(SLG->(ColumnPos("LG_IPIMPRD")) > 0)
			nPos := 0
		EndIf
	EndIf

	If nPos > 0
		nPos := Ascan( aPortIf, { |x| x == aTpPorta[nX] } )
		If nPos == 0
			AAdd(aPortIf, aTpPorta[nX])
			If oPortIf <> Nil
				oPortIF:SetItems(aPortIf)
				oPortIF:Refresh()
			EndIf
		EndIf
	Else
		nPos := Ascan( aPortIf, { |x| x == aTpPorta[nX] } )
		If nPos > 0
			aDel(aPortIf, nPos)
			aSize(aPortIf, Len(aPortIf) - 1)
			If oPortIf <> Nil
				oPortIF:SetItems(aPortIf)
				oPortIF:Refresh()
			EndIf
		EndIf
	EndIf
Next nX

/*Se estiver alterando um cadastro existente, onde ja esta selecionado 
a porta USB, depois de remontar a lista, deve seleciona-la */
If SLG->LG_PORTIF <> Nil 
	cSelPorta := AllTrim(SLG->LG_PORTIF)
	nPos := Ascan( aPortIf, { |x| x == cSelPorta } )
	If nPos > 0
		oPortIF:Select( nPos )
	EndIf
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj120VldLC ºAutor  ³Vendas Clientes       º Data ³06/12/10        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que valida o conteudo determinado no campo de largura de   º±±
±±º          ³impressao da ECF em colunas.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Exp01[N] : Largura em colunas                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³lRet[L] : Retorna se a validacao esta ok                          º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGALOJA                                                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Lj120VldLC(nLargCol)
Local lRet           	:= .T.		//Retorno
Local lDefColECF		:= IIf(SLG->(ColumnPos("LG_LARGCOL")) == 0,.F.,.T.)							//Definicao de largura de colunas para impressao ECF definida?
Local cValidLC			:= IIf(lDefColECF,AllTrim(GetAdvfVal("SX3","X3_VALID","LG_LARGCOL",2)),"")	//Validacao do campo de largura em colunas

Static nLargColLC		:=	0

Default nLargCol		:= 0

nLargColLC := nLargCol
If !lDefColECF .OR. Empty(nLargColLC)
	Return !lRet
Endif
//Caso exista, ajustar a formula de validacao para utilizar a variavel do campo para efetuar a validacao
If !Empty(cValidLC)
	cValidLC := StrTran(cValidLC,"M->LG_LARGCOL","nLargColLC")
	cValidLC := StrTran(cValidLC,"SLG->LG_LARGCOL","nLargColLC")
Else
	cValidLC := AllToChar(AllwaysTrue())
Endif
//Executar validacao
lRet := &(cValidLC)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjSL6Vld  ºAutor  ³Microsiga           º Data ³  05/24/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a serie da SL6                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjSL6Vld(cSerie, cCodigo)
Local lRet		:= .T.	// Retorno da funcao
Local aArea		:= {}	// Save da area
Local lIntSiac	:= SuperGetMV("MV_SCINTEG", Nil, .F.)	//indica se a integracao Protheus x SIAC esta ativa

Default cSerie	:= ""
Default cCodigo	:= ""

If lIntSiac
	aArea := GetArea()
	DbSelectArea("SL6")
	SL6->( DbSetOrder(1) )	//L6_FILIAL + L6_SERIE + L6_ESTACAO
	
	If SL6->( DbSeek(xFilial("SL6") + cSerie + cCodigo) )
		If SL6->L6_STATUS == "1" //indica se a serie esta habilitada para uso
			lRet := .T.
		Else
			lRet := .F.
			MsgAlert(STR0195 + Chr(13) + Chr(10)+;	// "Série Inativa."
			STR0196)	// "Utilize a rotina 'Gera Série PDV(LOJA130)' para gerar novos números de série para a estação."
		EndIf
	Else
		lRet := .F.
		MsgAlert(STR0197 + Chr(13) + Chr(10)+; 		// "Número de série ou estação não encontrado na tabela SL6."
				STR0198)	// "Utilize a rotina 'Gera Série PDV(LOJA130)' para gerar números de série para a estação."
	EndIf
	
	RestArea(aArea)
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj121LCMC7ºAutor  ³Microsiga           º Data ³  19/04/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna os leitores de CMC7                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/    
Function Lj121LCMC7(cLista, lPos)    
Local lRet := .T. //Retorno da função
Local aDados := {} //Dados da função 
Local aCMC7	:= {}

Default cLista 	:= ""
Default lPOS	:= .F. 

cLista := Space(2000)
	
If !lPOS
	If GetRemoteType() <> REMOTE_LINUX
			lRet   := CMC7Lis(@cLista)        
	Else                                                           
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso nao tenha a autocom.so, nao lista os perifericos no     ³
		//³cadastro de estacao                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( oAutocom ) == "O" .AND. File(GetClientDir()+"libautocom.so")// verifica se  existe a autocom.dll ou autocom.so
			lRet   := CMC7Lis(@cLista)
		EndIf
	EndIf
	
	aCMC7 := LJStrToArr(AllTrim(cLista))				// Alimenta o Vetor com o nome dos CMC7s recuperados
	
Else 
	aDados := {cLista, .T.}        
	STFFireEvent(	ProcName(0) ,;		// Nome do processo
 					"STCMC7List"																,;		// Nome do evento
 					aDados )
	
	cLista := aDados[1]
	
	aCMC7 := STStrToArr( AllTrim(cLista) )	// Alimenta o Vetor com o nome dos CMC7s recuperados
	
EndIf

ASize(aCMC7, Len(aCMC7)+1)			  				// Insere o primeiro elemento em branco para permitir
AIns(aCMC7, 1)										// que o usuario selecione nao usar um equipamento
aCMC7[1] := Space(20)

Return aCMC7   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj121LChq ºAutor  ³Microsiga           º Data ³  22/04/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna as impressoras de chques                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/    
Function Lj121LChq(cLista, lPos) 
Local aImpChq := {}    
Local aDados := {}    

Default cLista 	:= ""
Default lPOS	:= .F. 
// Preparação do array das impressoras de cheque
// Alimenta uma string com o nome de todas as impressoras, separadas por virgulas.
cLista := Space(2000)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o Remote e' Linux, se for, verifica se e' objeto.³
//³Essa validacao atende os casos em que nao ha libautocom.so   ³
//³na pasta do \bin\remote. Nao lista impressora de cheque.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lPOS
	If GetRemoteType() <> REMOTE_LINUX
		lRet := CHListar(@cLista)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso nao tenha a autocom.so, nao lista os perifericos no     ³
		//³cadastro de estacao                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If ValType( oAutocom ) == "O" .AND. File(GetClientDir()+"libautocom.so")// verifica se  existe a autocom.dll ou autocom.so
			lRet := CHListar(@cLista)
		EndIf
	EndIf
	
	aImpChq := LJStrToArr(AllTrim(cLista))				// Alimenta o Vetor com o nome das impressoras recuperadas
	
Else 
	aDados := {cLista, .T.}
	STFFireEvent(	ProcName(0) ,;		// Nome do processo
 					"STCHList"																,;		// Nome do evento
 					aDados )
 	cLista := aDados[1]	
 	
 	aImpChq := STStrToArr( AllTrim(cLista) )   // Alimenta o Vetor com o nome das impressoras recuperadas
 	
EndIf

ASize(aImpChq, Len(aImpChq)+1)						// Insere o primeiro elemento em branco para permitir
AIns(aImpChq, 1)									// que o usuario selecione nao usar um equipamento
aImpChq[1] := Space(20)
		
Return aImpChq   
     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj121LGav ºAutor  ³Microsiga           º Data ³  22/04/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna as impressoras de chques                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    
Function Lj121LGav(cLista, lPos)
    Local aGaveta := {}    
    Local aDados := {}

	Default cLista 	:= ""
	Default lPOS	:= .F. 
    
	cLista := Space(2000)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Remote e' Linux, se for, verifica se e' objeto.³
	//³Essa validacao atende os casos em que nao ha libautocom.so   ³
	//³na pasta do \bin\remote. Nao lista gaveta.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lPOS
		If GetRemoteType() <> REMOTE_LINUX
				lRet := GavetaLis(@cLista)
		Else                                                           
			Conout( "OpenDevice - GavetaLis - oAutocom - " + ValType( oAutocom ) ) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso nao tenha a autocom.so, nao lista os perifericos no     ³
			//³cadastro de estacao                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ValType( oAutocom ) == "O" .AND. File(GetClientDir()+"libautocom.so")// verifica se  existe a autocom.dll ou autocom.so
				lRet := GavetaLis(@cLista)
			EndIf
		EndIf
		
		aGaveta := LJStrToArr(AllTrim(cLista))				// Alimenta o Vetor com o nome das gavetas recuperadas
		
	Else 
		aDados := {cLista, .T.}        
		STFFireEvent(	ProcName(0) ,;		// Nome do processo
	 					"STDrawerList"																,;		// Nome do evento
	 					aDados )
		
		cLista := aDados[1]
		
		aGaveta := STStrToArr( AllTrim(cLista) )			// Alimenta o Vetor com o nome das gavetas recuperadas
				
	EndIf
		
	ASize(aGaveta, Len(aGaveta)+1)		 				// Insere o primeiro elemento em branco para permitir
	AIns(aGaveta, 1)									// que o usuario selecione nao usar um equipamento
	aGaveta[1] := Space(20)

Return aGaveta    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj121LLOptºAutor  ³Microsiga           º Data ³  22/04/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna os Leitores Opticos                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function Lj121LLOpt(cLista, lPOS)
    Local aLeitOpt := {}
    Local aDados := {}

	Default cLista 	:= ""
	Default lPOS	:= .F. 
    
	cLista := Space(2000)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Remote e' Linux, se for, verifica se e' objeto.³
	//³Essa validacao atende os casos em que nao ha libautocom.so   ³
	//³na pasta do \bin\remote. Nao lista leitores de cod. barras.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lPOS
		If GetRemoteType() <> REMOTE_LINUX
				lRet := LeitorLis(@cLista)        
		Else                                                           
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso nao tenha a autocom.so, nao lista os perifericos no     ³
			//³cadastro de estacao                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ValType( oAutocom ) == "O" .AND. File(GetClientDir()+"libautocom.so")// verifica se  existe a autocom.dll ou autocom.so
				lRet := LeitorLis(@cLista)
			EndIf
		EndIf
		
		aLeitOpt := LJStrToArr(AllTrim(cLista))				// Alimenta o Vetor com o nome dos leitores recuperados
		
	Else 
		aDados := {cLista, .T.}        
		STFFireEvent(	ProcName(0) ,;		// Nome do processo
	 					"STReaderList"																,;		// Nome do evento
	 					aDados )
		
		cLista := aDados[1]
		
		aLeitOpt := STStrToArr( AllTrim(cLista) )				// Alimenta o Vetor com o nome dos leitores recuperados
		
	EndIf	
	
	ASize(aLeitOpt, Len(aLeitOpt)+1)					// Insere o primeiro elemento em branco para permitir
	AIns(aLeitOpt, 1)									// que o usuario selecione nao usar um equipamento
	aLeitOpt[1] := Space(20)

Return aLeitOpt

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj121LBal ºAutor  ³Microsiga           º Data ³  22/04/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna as Balanças                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 	
Function Lj121LBal(cLista, lPOS)
    Local aBalanca := {} 
    Local aDados := {}

	Default cLista 	:= ""
	Default lPOS	:= .F. 
    
	// Preparação do array das Balancas
	// Alimenta uma string com o nome de todas as balancas, separadas por virgulas.
	cLista := Space(5000)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Remote e' Linux, se for, verifica se e' objeto.³
	//³Essa validacao atende os casos em que nao ha libautocom.so   ³
	//³na pasta do \bin\remote. Nao lista balanca.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                              
	If !lPOS
		If GetRemoteType() <> REMOTE_LINUX
				lRet := BalancaLis(@cLista)
		Else                                                           
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso nao tenha a autocom.so, nao lista os perifericos no     ³
			//³cadastro de estacao                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ValType( oAutocom ) == "O" .AND. File(GetClientDir()+"libautocom.so")// verifica se  existe a autocom.dll ou autocom.so
				lRet := BalancaLis(@cLista)
			EndIf
		EndIf
		
		aBalanca := LJStrToArr(AllTrim(cLista))				// Alimenta o Vetor com o nome das balancas recuperadas
		
	Else 
		aDados := {cLista, .T.}        
		STFFireEvent(	ProcName(0) ,;		// Nome do processo
	 					"STBalanceList"																,;		// Nome do evento
	 					aDados )
		
		cLista := aDados[1]
		
		aBalanca := STStrToArr( AllTrim(cLista) )				// Alimenta o Vetor com o nome das balancas recuperadas
		
	EndIf
	
	ASize(aBalanca, Len(aBalanca)+1)					// Insere o primeiro elemento em branco para permitir
	AIns(aBalanca, 1)									// que o usuario selecione nao usar um equipamento
	aBalanca[1] := Space(20)

Return aBalanca   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  |Lj121LINF ºAutor  ³Microsiga           º Data ³  22/04/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna as Impressoras Não Fiscais                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj121LINF(cLista, lPOS)
    Local aImpCup := {}
    
	Default cLista 	:= ""
	Default lPOS	:= .F. 

	// Preparação do array das impressoras de cupom
	// Alimenta uma string com o nome de todas as impressoras, separadas por virgulas.
	cLista := Space(2000)
	
	/*Verifica se o Remote e' Linux, se for, verifica se e' objeto.
	Essa validacao atende os casos em que nao ha libautocom.so   
	na pasta do \bin\remote. Nao lista impressora de cupom.     */
	If !lPOS
		If GetRemoteType() <> REMOTE_LINUX
			lRet := ImpCupLis(@cLista)	
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso nao tenha a autocom.so, nao lista os perifericos no     ³
			//³cadastro de estacao                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			If ValType( oAutocom ) == "O" .AND. File(GetClientDir()+"libautocom.so")// verifica se  existe a autocom.dll ou autocom.so
				lRet := ImpCupLis(@cLista)
			EndIf
		EndIf
		
		aImpCup := LJStrToArr(AllTrim(cLista))				// Alimenta o Vetor com o nome das impressoras recuperadas
		
   	Else 
		aImpCup := STStrToArr( AllTrim(cLista) ) 	// Alimenta o Vetor com o nome das impressoras recuperadas
	EndIf
	
	ASize(aImpCup, Len(aImpCup)+1)						// Insere o primeiro elemento em branco para permitir
	AIns(aImpCup, 1)									// que o usuario selecione nao usar um equipamento
	aImpCup[1] := Space(20)

Return aImpCup       

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj121LPinPad ºAutor  ³Microsiga           º Data ³  22/04/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna os Pin-Pads                                           º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj121LPinPad(cLista, lPos) 
Local aModelos := {}
Local aPinPad := {} 
Local aDados  := {}    
 
Default cLista 	:= ""
Default lPOS	:= .F.    

// Preparação do array dos PINPADs
// Alimenta uma string com o nome de todas os Pinpads, separados por virgulas.
cLista := Space(2000)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o Remote e' Linux, se for, verifica se e' objeto.³
//³Essa validacao atende os casos em que nao ha libautocom.so   ³
//³na pasta do \bin\remote. Nao lista PinPad.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                           
If !lPOS
	If GetRemoteType() <> REMOTE_LINUX
			lRet := PinPadLis(@cLista)        
	Else                                                           
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso nao tenha a autocom.so, nao lista os perifericos no     ³
		//³cadastro de estacao                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType( oAutocom ) == "O" .AND. File(GetClientDir()+"libautocom.so")// verifica se  existe a autocom.dll ou autocom.so
			lRet := PinPadLis(@cLista)
		EndIf
	EndIf
	
	aPinPad  := LJStrToArr(AllTrim(cLista))				// Alimenta o Vetor com o nome dos Pinpads recuperadas
	
Else 
	aDados := {cLista, .T.}        
	STFFireEvent(	ProcName(0) ,;		// Nome do processo
 					"STPinPadList"																,;		// Nome do evento
 					aDados )
	
	cLista := aDados[1]
	
	aPinPad  := STStrToArr( AllTrim(cLista) )				// Alimenta o Vetor com o nome dos Pinpads recuperadas
	
EndIf	
aModelos := {STR0194 ,STR0157}  // GERTEC | VERIFONE 
       
If __lPyme
	LjModelo(aModelos,@cLista)	
EndIf

ASize(aPinPad, Len(aPinPad)+1)						// Insere o primeiro elemento em branco para permitir
AIns(aPinPad, 1)									// que o usuario selecione nao usar um equipamento
aPinPad[1] := Space(20)

Return aPinPad

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJ121LIF     ºAutor  ³Microsiga           º Data ³  22/04/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna as Impressoras Fiscais                                º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LJ121LIF(	cLista		, lPOS		, aEstrutImp, aImpFTot, ;
					cValidRec	, lMsgRec	, lOnlyImpNf )
	Local aImpList := {} 
	Local lUsaEmul := .F.	   
	
	DEFAULT cLista 	:= ""
	DEFAULT lPOS	:= .F. 	
	DEFAULT aEstrutImp := {}
	DEFAULT aImpFTot := {}
	DEFAULT cValidRec := "2"
	DEFAULT lMsgRec	:= .F.
	Default lOnlyImpNf := .F.
	
	
	cLista := Space(9000)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Remote e' Linux, se for, verifica se e' objeto.³
	//³Essa validacao atende os casos em que nao ha libautocom.so   ³
	//³na pasta do \bin\remote. Nao lista ECF.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lPOS
		If GetRemoteType() <> REMOTE_LINUX
			lRet := IFListar(@cLista,,lOnlyImpNf)
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso nao tenha a autocom.so, nao lista os perifericos no     ³
			//³cadastro de estacao                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			If ValType( oAutocom ) == "O"  .AND. File(GetClientDir()+"libautocom.so")// verifica se  existe a autocom.dll ou autocom.so
				lRet := IFListar(@cLista,,lOnlyImpNf)
			EndIf
		EndIf
		
		aImpList := LJStrToArr(AllTrim(cLista))					// Alimenta o Vetor com o nome das impressoras recuperadas
		
	Else  
	    STWListPrint(@cLista, .T.,.F.,lOnlyImpNf)
	    aImpList := STStrToArr( AllTrim(cLista) )   	// Alimenta o Vetor com o nome das impressoras recuperadas
	EndIf
	
	ASize(aImpList, Len(aImpList)+1)						// Insere o primeiro elemento em branco para permitir
	AIns(aImpList, 1)											// que o usuario selecione nao usar um equipamento
	aImpList[1] := Space(20)
	
	aImpFTot := AClone( LJQuebraImpr(AllTrim(cLista) , @aEstrutImp) )	// Alimenta o Vetor com FABRICANTES+MODELOS+VERSOES das impressoras recuperadas.   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a empresa for <> de 99 e diferente de Microsiga (uso interno) nao ³
	//³ permite selecionar o ECFEmulator.                                    ³
	//³ Esta alteracao foi efetuada para bloquear o uso do Emulador em base  ³
	//³ de producao.                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lUsaEmul := LjRecEmul(SM0->M0_CGC, cValidRec, lMsgRec)	
	If cEmpAnt <> "99" .AND. SM0->M0_CGC <> "53113791000122" .AND.  ( !lUsaEmul  .OR. ((lPOS .AND. !STWUsaECFE() ) .OR. (!lPOS .AND. !LjUsaECFE(SM0->M0_CGC) ) ) )
		nPos := aScan( aImpList, "ECF Emulator" )
		If nPos > 0
			ADel( aImpList, nPos )
			ASize( aImpList, Len(aImpList)-1 )
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a empresa for <> de 99 e diferente de Microsiga (uso interno) nao ³
	//³ permite selecionar o Emulador HTML.                                    ³
	//³ Esta alteracao foi efetuada para bloquear o uso do Emulador em base  ³
	//³ de producao.                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cEmpAnt <> "99" .AND. Left(SM0->M0_CGC, 8)  <> "53113791"
		nPos := aScan( aImpList, "EMULADOR NAO FISCAL HTML" )
		If nPos > 0
			ADel( aImpList, nPos )
			ASize( aImpList, Len(aImpList)-1 )
		EndIf
	EndIf
Return aImpList

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj121WIni    ºAutor  ³Microsiga           º Data ³  22/04/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava o arquivo de config do Sitef                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj121WIni(nTipTEF, cPinPad, cPortPad, cEstacao, nTipTEFAnt)
Local cClientDir := ""         //Arquivo do Executável
Local cPPVisa := ""            //Arquivo do Visa
Local cClisitef := ""          //Arquivo do Sitef
Local aSLG := SLG->(GetArea())  //WorkArea Cadastro de estação


DEFAULT nTipTEF := 1
DEFAULT cPinPad := ""
DEFAULT cPortPad := ""
DEFAULT cEstacao := ""
DEFAULT nTipTEFAnt := 1

If !Empty(cEstacao)
	SLG->(DbSetOrder(1)) //LG_FILIAL + LG_ESTACAO
	If SLG->(DbSeek(xFilial() + cEstacao))	  
		nTipTEF := Val(SLG->LG_TIPTEF)
		cPinPad := SLG->LG_PINPAD
		cPortPad := SLG->LG_PORTPAD 
	EndIf
EndIf

cClientDir	:= GetClientDir()
cPPVisa		:= cClientDir + "PPVISA.INI"
cClisitef	:= cClientDir + "CLISITEF.INI"  


If (nTipTEF == 2 .OR. nTipTEF == 6) .AND. File(cPPVisa)
	If !Empty(cPinPad)
		cPPVar	:= "Port"
		If "VERIFONE" $ cPinPad
			cPPName := "VFN"
			cPPVar	:= "Config"
			cPPPort	:= SubStr(cPortPad,4,1)+"CHIP"
		ElseIf "DIONE" $ cPinPad
			cPPName := "DIO"
			cPPPort	:= SubStr(cPortPad,4,1)
		ElseIf "SCHL" $ cPinPad
			cPPName := "SLB"
			cPPPort	:= SubStr(cPortPad,4,1)
		ElseIf "GERTEC" $ cPinPad
			cPPName := "GER"
			cPPPort	:= SubStr(cPortPad,4,1)
		ElseIf "INGENICO" $ cPinPad
			cPPName := "ING"
			cPPPort	:= SubStr(cPortPad,4,1)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Exemplo da gravacao do PPVISA.INI              ³
		//³[general]                                      ³
		//³binfile = c:\mp8\bin\remote\PPVISA.BIN         ³
		//³driver32 = c:\mp8\bin\remote\PP<cPPName>W32.DLL³
		//³[???]                                          ³
		//³<cPPVar> = <cPPPort>                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		WritePProString("GENERAL",	"BinFile",	cClientDir+"PPVISA.BIN",			cPPVisa)
		WritePProString("GENERAL",	"Driver32",	cClientDir+"PP"+cPPName+"W32.DLL",	cPPVisa)
		WritePProString(cPPName,	cPPVar,		cPPPort,							cPPVisa)
	EndIf
EndIf

LJWriteClis(nTipTef, cClisitef, cClientDir, cPortPad, nTipTEFAnt)

RestArea(aSLG)

Return      

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj121LDis     ºAutor  ³Microsiga           º Data ³  22/04/2013º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna os Displays                                           º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj121LDis(cLista, lPOS)  
	Local lRet := .F.  //Retorno da Função
	Local aDisplay	:= {}
	DEFAULT cLista 	:= ""
	DEFAULT lPOS	:= .F.

	cLista := Space(2000)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Remote e' Linux, se for, verifica se e' objeto.³
	//³Essa validacao atende os casos em que nao ha libautocom.so   ³
	//³na pasta do \bin\remote. Nao lista display.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lPOS
		If GetRemoteType() <> REMOTE_LINUX
				lRet := DisplayLis(@cLista)       
		Else                                                           
			Conout( "OpenDevice - DisplayLis - oAutocom - " + ValType( oAutocom ) ) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso nao tenha a autocom.so, nao lista os perifericos no     ³
			//³cadastro de estacao                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ValType( oAutocom ) == "O" .AND. File(GetClientDir()+"libautocom.so")// verifica se  existe a autocom.dll ou autocom.so
				lRet := DisplayLis(@cLista)
			EndIf
		EndIf
		
		aDisplay := LJStrToArr(AllTrim(cLista))				// Alimenta o Vetor com o nome das gavetas recuperadas
		
	Else
	
		aDisplay := STStrToArr( AllTrim(cLista) )				// Alimenta o Vetor com o nome das gavetas recuperadas
	
	EndIf                         
	
	
	ASize(aDisplay, Len(aDisplay)+1)		 			// Insere o primeiro elemento em branco para permitir
	AIns(aDisplay, 1)									// que o usuario selecione nao usar um equipamento
	aDisplay[1] := Space(20) 
	
	
Return aDisplay   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj121LTDis   ºAutor  ³Microsiga           º Data ³  22/04/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna os Displays de Torre                                  º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj121LTDis(cLista, lPOS)	
	Local aDispTorre	:= {}
	
	DEFAULT cLista 	:= ""
	DEFAULT lPOS	:= .F.

	cLista := Space(2000)
	If !lPOS
		
		If GetRemoteType() <> REMOTE_LINUX
			DispTorLis(@cLista)       
		EndIf
	   
	   aDispTorre := LJStrToArr(AllTrim(cLista))				// Alimenta o Vetor com o nome das gavetas recuperadas
	   
	Else
		aDispTorre := STStrToArr( AllTrim(cLista) )  	// Alimenta o Vetor com o nome das gavetas recuperadas
	EndIf
	
	ASize(aDispTorre, Len(aDispTorre)+1)		 			// Insere o primeiro elemento em branco para permitir
	AIns(aDispTorre, 1)									    // que o usuario selecione nao usar um equipamento
	aDispTorre[1] := Space(20)
	
Return aDispTorre

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj121VldEst  ºAutor  ³Microsiga           º Data ³  22/08/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Procura se existe algum PDV igual e se existir impedi inclusaoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj121VldEst( cTipo , cPDV, cImpFisc, cSerie)
Local aAreaSLG	:= SLG->(GetArea())
Local cFilSLG	:= ""
Local lRet		:= .T.
Local nRecno	:= 0

Default cImpFisc := ""

If !Empty(cImpFisc) .AND. cTipo $ "I|A"
	nRecno := IIf(cTipo == "A",SLG->(Recno()),0)  //Nao permite validar o mesmo registro caso seja alteracao

	cFilSLG := xFilial()
	SLG->(DbSeek(cFilSLG))

	Do While !SLG->(Eof())
		If SLG->(LG_FILIAL+LG_PDV) == (cFilSLG + cPDV) .AND. IIf( nRecno > 0, !nRecno == SLG->(Recno()), .T. )
			MsgAlert(STR0202 +  CHR(13) +; 							//"Inclusão/Alteração não permitida."
					 STR0201 + AllTrim(cPDV) + STR0256 + CHR(13) +; //" PDV : " ### " Já cadastrada(o)"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        	
					 STR0203 , STR0204) 							//"A inclusão duplicada pode gerar conflitos", "Atenção"
			lRet := .F.
			Exit
		ElseIf SLG->(LG_FILIAL+LG_SERIE) == (cFilSLG + cSerie) .AND. IIf( nRecno > 0, !nRecno == SLG->(Recno()), .T. )
			MsgAlert(STR0202 +  CHR(13) +; 								//"Inclusão/Alteração não permitida."
					 STR0205 +  AllTrim(cSerie) + STR0256 + CHR(13) +; 	//"Serie:" ### " Já cadastrada(o)"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
					 STR0203 , STR0204) 								//"A inclusão duplicada pode gerar conflitos", "Atenção"
			lRet := .F.
			Exit
		EndIf
		SLG->(DbSkip())
	EndDo
	
EndIf

RestArea(aAreaSLG)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjIFTipoEcNf  ºAutor  ³Microsiga          º Data ³  22/08/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna se achou o equipamento nao-fiscal						º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjIFTipoEcNf(cModelo)
Local lRet 			:= .F.
Local cBuffer		:= ""			//variavel auxiliar para uso nas funções da SIGALOJA.DLL
Local aImpressoras	:= {}			//array com as impressoras não fiscais homologadas na SIGALOJA.DLL
Local lPOS			:= STFIsPOS()	//Pos?

If lPOS
	
	//TOTVSAPI.DLL
	If CriaTotApi()
		lRet := STWExistEquip(EQUIP_IMPNAOFISCAL, cModelo)
	EndIf
	
	//SIGALOJA.DLL
	If !lRet
		aImpressoras	:= {Space(7000), .T.}
	
		STFFireEvent	(	ProcName(0) ,;	// Nome do processo
							"STListINF",;	// Nome do evento
							aImpressoras )

		cBuffer			:=	aImpressoras[1]
		aImpressoras	:=	STWLJStrToArr(AllTrim(cBuffer))		//transforma a lista em um array
		cModelo			:=	AllTrim(cModelo)					//retiramos os espaços do modelo

		//verifica se o modelo existe na lista de impressoras
		lRet	:=	(aScan(aImpressoras, {|x| x == cModelo}) > 0)
	EndIf

Else
	lRet := IFTipoEcNf(cModelo)
EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj121VldEst  ºAutor  ³Microsiga           º Data ³  22/08/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³ Procura se existe RFID Leitor igual e se existir impedi inclusaoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj121RFIDVld( cLeitor , cEstacaoAtual)

Local aArea	    	:= GetArea() 		// Guarda area atual
Local lRet				:= .T.

Default cLeitor 			:= ""
Default cEstacaoAtual 	:= ""

cLeitor 		:= AllTrim(cLeitor)
cEstacaoAtual := AllTrim(cEstacaoAtual)

DbSelectArea("SLG")
DbSetOrder(1)//LG_FILIAL+LG_CODIGO
If DbSeek(xFilial("SLG"))

	While !SLG->(Eof())
		
		If cEstacaoAtual <> AllTrim(SLG->LG_CODIGO) .AND. cLeitor == allTrim(SLG->LG_IDRFID)
			Alert( STR0212 + cLeitor + STR0213 + AllTrim(SLG->LG_CODIGO) )//"O Leitor RFID " ### " já está cadastrado para o terminal "
			lRet := .F.
		EndIf
		SLG->(DbSkip())
	End
	
EndIf

//Restaura area anterior
RestArea( aArea )	
	
Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjChangeSAT  ºAutor  ³Microsiga           º Data ³  06/05/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o preenchimento dos  campos referentes ao SAT          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjChangeSAT(	cSAT	, cModelSAT	, cCodSAT	, cPDV , ;
	    				cSerie	, cImpFisc 	, cChvVld	)

Local lRet := .T. // retorno
  
Default cSAT 		:= ""  // Fabricante
Default cModelSAT 	:= "" // Modelo
Default cCodSAT 	:= "" // Código
Default cPDV 		:= "" // PDV
Default cSerie 		:= "" // SERIE
Default cImpFisc 	:= "" // Impressora
Default cChvVld		:= "" // Chave Acesso Validador

If Empty(cSAT)  .OR. Empty(cModelSAT) .OR. Empty(cCodSAT)
    MsgStop(STR0218) //"Preencha os dados do equipamento SAT"
    lRet := .F.
EndIf

If Len(AllTrim(cPDV)) <> 3 .OR. (ExistFunc("STBIsDigit") .AND. !STBIsDigit(AllTrim(cPDV)) )
    MsgStop("O Campo PDV(LG_PDV) deve conter 3 dígitos numéricos e deve ser diferente das outras estações." + CRLF +;
    		"Esta informação não consta no equipamento e deve ser definida pelo usuário."	) 
    lRet := .F.
EndIf

//Valida impressora homologada para SAT?
If !Lj121ImpSat(AllTrim(cImpFisc))
    MsgStop("A impressora selecionada não está na lista de equipamentos homologados para SAT." + CRLF +;
    		"Verifique os equipamentos homologados no item 2 da FAQ SAT."	) 
    lRet := .F.
EndIf

//IE deve ser preenchida e deve ser numerico 
If Empty( SM0->M0_INSC ) .OR. ( ExistFunc("STBIsDigit") .AND. !STBIsDigit(AllTrim(SM0->M0_INSC)) ) 
    MsgStop("A Inscrição Estadual deve ser informada e deve conter apenas dígitos numéricos." + CRLF +;
    		"Campo SM0->M0_INSC."	) 
    lRet := .F.
EndIf    

//Para o uso do MFe deve ser preenchido o campo LQ_CHVVLD
If SM0->M0_ESTCOB $ 'CE' .And. Empty(cChvVld)
	MsgStop("O campo Chave Acesso Validador (LG_CHVVLD) deve ser preenchido para o funcionamento correto do MFe.") 
    lRet := .F.
EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³IntegDef  ºAutor  ³ Vendas CRM           º Data ³  08/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Mensagem Única												º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Mensagem Única                                            	º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function IntegDef(cXml, nTypeTrans, cTypeMessage)

Local aRet := {}
	
aRet:= LOJI121(cXml, nTypeTrans, cTypeMessage)

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LJEstAuto  ºAutor  ³ Vendas CRM          º Data ³  27/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Efetua a gravacao dos campos de Estacao para rotina automaticaº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Loja110                                                   	º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LJEstAuto(cTipo)

	Local nI 		:= 0	//Contador
	Local lContinua := .T.
	
	If cTipo $ "A|I"
		If cTipo == "I" 				
			Reclock("SLG", .T.)	
		Else
			Reclock("SLG", .F.)
		EndIf
		
		SLG->(FieldPut(ColumnPos("LG_FILIAL"), xFilial("SLG"))) //Filial
		
		//Grava informacoes da Estacao			
		For nI := 1 To Len(aAutoSlg)								
			SLG->(FieldPut(ColumnPos(aAutoSlg[nI][1]), aAutoSlg[nI][2]))		
		Next nI
		
		SLG->(MsUnLock())
	
	ElseIf cTipo == "E"
	
        //Efetua a exclusão das Integrações Varejo
        lContinua := IntegVarej(SLG->LG_CODIGO, .T.)
	
        If lContinua
	
			SLG->(RecLock("SLG", .F.))
			//esse campo deve ficar em branco para que o Registro do PAF
			//faça o filtro correto quando efetuada deleção manual de registro
			If SLG->(ColumnPos("LG_PAFMD5")) > 0
				REPLACE SLG->LG_PAFMD5 WITH ""
			EndIf 
			SLG->( dbDelete() )
			SLG->( MsUnLock() )
		EndIf
    EndIf

Return Nil

//---------------------------------------------
/*/{Protheus.doc} Lj121AltIni
Altera o INI de configuração , caso necessário
@type		Function
@param		cModelo , caracter , modelo do equipamento
@author  	Varejo
@version 	P11.8
@since   	31/08/2016
@return  	lRet, logico, alteracao ok ou nao?
/*/
//---------------------------------------------
Function Lj121AltIni(cModelo)
Local lRet		:= .T.
Local cArqINI	:= ""
Local cAux		:= ""

If "TOLEDO" $ Upper(cModelo)
 	cArqINI := GetClientDir() + "SIGALOJA.INI"
 	cAux 	:= Alltrim(GetPvProfString("TOLEDO", "BaudRate", "", cArqINI))
 	If Empty(cAux)
 		WritePProString("TOLEDO", "BaudRate", "9600", cArqINI)
 	EndIf

 	cAux 	:= Alltrim(GetPvProfString("TOLEDO", "DataBits", "", cArqINI))
 	If Empty(cAux)
 	 	If cModelo == "Toledo 9091"
 	 		cAux := "7"
 	 	ElseIf cModelo == "Toledo 9094"
 	 		cAux := "8"
 	 	Else
 	 		cAux := "8"
 	 	EndIf
 	 	WritePProString("TOLEDO", "DataBits", cAux, cArqINI)
 	EndIf
 	
 	cAux 	:= Alltrim(GetPvProfString("TOLEDO", "Parity", "", cArqINI))
 	If Empty(cAux)
 	 	If cModelo == "Toledo 9091" 
 	 		cAux := "2"
 	 	ElseIf cModelo == "Toledo 9094"
 	 		cAux := "0"
 	 	Else
 	 		cAux := "0"
 	 	EndIf
 	 	WritePProString("TOLEDO", "Parity", cAux, cArqINI)
 	EndIf	
EndIf

Return lRet

//---------------------------------------------
/*/{Protheus.doc} Lj121RFSat
Retorna todos fabricantes homologados do SAT
@param		
@author  	Varejo
@version 	P11.8
@since   	15/12/2016
@return  	aRet
/*/
//---------------------------------------------
Function Lj121RFSat()

Local aRet := {}

//Fabricante
If SM0->M0_ESTCOB $ "CE"
	Aadd(aRet, "ELGIN"	)
	Aadd(aRet, "INTEGRADOR"	)
	Aadd(aRet, "COMUNICACAO DIRETA"	)
Else
	Aadd(aRet, "DIMEP"	) 
	Aadd(aRet, "BEMATECH")
	Aadd(aRet, "COMPSIS")
	Aadd(aRet, "EPSON")
	Aadd(aRet, "ELGIN")
	
	//So habilita o emulador para a variável MV_SATTEST 11.111.111/1111-11 
	If Lj121VldSat()
	    Aadd(aRet, "EMULADOR") 
	EndIf
EndIf
        
Return aRet

//---------------------------------------------
/*/{Protheus.doc} Lj121ImpSat
Retorna se a impressora esta homologada para SAT
@param		cImp, Impressora a ser avaliada
@author  	rafael.pessoa
@version 	P12
@since   	06/02/2017
@return  	lRet - Retorna se a impressora esta homologada para SAT
/*/
//---------------------------------------------
Static Function Lj121ImpSat(cImp)

Local aRet 		:= {}
Local lRet		:= .F.

//Impressoras homologadas
Aadd(aRet, "BEMATECH MP-4200 TH 01.00.00(S)")

If cSigaDLLVer < "0.3.141.0" 
	// Permite MP4200 apenas para versoes mais antigas
	// Versoes mais novas usará por padrao a versao da SIGALOJA (S)
	Aadd(aRet, "BEMATECH MP4200 V01.00.00")
EndIf

Aadd(aRet, "BEMATECH TH") 
Aadd(aRet, "DARUMA DR700 (S)")
Aadd(aRet, "DARUMA DR")
Aadd(aRet, "DARUMA DR700 V02.10.01")
Aadd(aRet, "DARUMA DR800")
Aadd(aRet, "EPSON TM-T88V")
Aadd(aRet, "EPSON TM-T20")
 
If Lj121VldSat()
    Aadd(aRet, "EMULADOR NAO FISCAL") 
    Aadd(aRet, "EMULADOR NAO FISCAL HTML")  
EndIf

If aScan( aRet, AllTrim(Upper(cImp)) ) > 0
	lRet := .T. //Impressora homologada
EndIf
        
Return lRet

//---------------------------------------------
/*/{Protheus.doc} Lj121RMSat
Retorna todos modelos homologados do SAT de acordo com o fabricante
@param		
@author  	Varejo
@version 	P11.8
@since   	15/12/2016
@return  	lRet
/*/
//---------------------------------------------
Function Lj121RMSat(cFabSat,aModSAT,oComboModSAT)

Default cFabSat 		:= ""
Default aModSAT 		:= {}

aModSAT := {}

If !Empty(AllTrim(cFabSat))
	If SM0->M0_ESTCOB $ "CE"
		Do Case 
			Case "ELGIN" $ cFabSat 
				Aadd(aModSAT, "ELGIN LINKER")
			Case "INTEGRADOR" $ cFabSat 
				Aadd(aModSAT, "INTEGRADOR FISCAL MFE")
			Case "COMUNICACAO DIRETA" $ cFabSat 
				Aadd(aModSAT, "ELGIN")
				Aadd(aModSAT, "TANCA")
		EndCase
	Else	
		Do Case 
			Case "DIMEP" $ cFabSat 
				Aadd(aModSAT, "D-SAT:01.00.00")
			Case "BEMATECH" $ cFabSat 
				Aadd(aModSAT, "RB-1000 FI")
				Aadd(aModSAT, "RB-2000")
				Aadd(aModSAT, "SAT-GO")
			Case "COMPSIS" $ cFabSat 
				Aadd(aModSAT, "COMPSIS")
			Case "EMULADOR" $ cFabSat 
				Aadd(aModSAT, "EMULADOR SAT")
			Case "EPSON" $ cFabSat 
				Aadd(aModSAT, "SAT-A10")
			Case "ELGIN" $ cFabSat 
				Aadd(aModSAT, "ELGIN LINKER SAT")
		EndCase
	EndIf	
EndIf	

If oComboModSAT <> Nil       
	oComboModSAT:AITEMS := aModSAT
EndIf
       
Return .T.        


//--------------------------------------------------------
/*/{Protheus.doc} Lj121ImpFis
Retorna lista somente com as impressoras fiscais.
As impressoras não fiscais serao retiradas da lista.

@type function
@author  	rafael.pessoa
@since   	01/02/2017
@version 	P12
@param
@return	    aRet - Retorna array somente de impressoras fiscais
/*/
//--------------------------------------------------------
Static Function Lj121ImpFis()

Local nPos 			:= 0
Local nX 			:= 0
Local aRet 			:= {Space(20)}

If Len(aImpFiscal) > 0 .AND. Len(aImpNotFisc) > 0
	
	If Len(aImpFiscal) <> Len(aImpNotFisc) //tamanhos iguais funcao nao preparada p diferenciar fiscal e nao fiscal
		
		For nX := 1 To Len(aImpFiscal) 
			If ! Empty(aImpFiscal[nX])
				nPos := aScan( aImpNotFisc, AllTrim(aImpFiscal[nX]) )
				If nPos == 0				
					AAdd(aRet ,  AllTrim(aImpFiscal[nX]) )
				EndIf	 
			EndIf	
		 Next nX
	Else
		aRet := aImpFiscal
	EndIf
	 
EndIf

Return aRet


//--------------------------------------------------------
/*/{Protheus.doc} Lj121FabFis
Retorna lista somente dos fabricantes de impressoras fiscais.
Os Fabricantes de impressoras não fiscais serao retiradas da lista.

@type function
@author  	rafael.pessoa
@since   	01/02/2017
@version 	P12
@param
@return	    aRet - Retorna array somente de fabricantes de impressoras fiscais
/*/
//--------------------------------------------------------
Static Function Lj121FabFis()

Local nPos 			:= 0
Local nX 			:= 0
Local aRet 			:= {Space(20)}

If Len(aFabFiscal) > 0 .AND. Len(aFabNotFisc) > 0
	
	For nX := 1 To Len(aFabFiscal) 
		If ! Empty(aFabFiscal[nX])
			nPos := aScan( aFabNotFisc, AllTrim(aFabFiscal[nX]) )
			//Valida se esta na lista nao fiscal e se existe na lista fiscal
			If nPos == 0 .OR. aScan( aImpFiscal, { |x| AllTrim(aFabFiscal[nX]) $ AllTrim(x) }) > 0			
				AAdd(aRet ,  AllTrim(aFabFiscal[nX]) )
			EndIf	 
		EndIf	
	 Next nX
	 
EndIf

Return aRet


//--------------------------------------------------------
/*/{Protheus.doc} Lj121TipImp
Realiza a troca do tipo de impressora

@type function
@author  	rafael.pessoa
@since   	01/02/2017
@version 	P12
@param      aImpList , Lista de impressoras
@return	    Nil
/*/
//--------------------------------------------------------
Static Function Lj121TipImp(aImpList)

Default aImpList := {}

If Left(cTipImp,1) == "2" // "2 - Fiscal"
	aImpList := aImpFiscal
	aFabric := AClone( LJImpFabric(aFabFiscal) )	
Else //1 - Não Fiscal
	aImpList := aImpNotFisc
	aFabric := AClone( LJImpFabric(aFabNotFisc) )
EndIf

If oImpFFab <> Nil
	oImpFFab:SetItems(aFabric)
	oImpFFab:Refresh()
EndIf	

Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} Lj121IsFisc
Retorna se a impressora eh fiscal

@type function
@author  	rafael.pessoa
@since   	01/02/2017
@version 	P12
@param		cImpModel , Modelo impressora
@return	    lRet - Retorna se a impressora eh fiscal
/*/
//--------------------------------------------------------
Function Lj121IsFisc( cImpModel )

Local lRet 			:= .F.

Default cImpModel := ""

cImpModel := AllTrim(cImpModel)

// -------------------------------------------------------------------
// Validação para caso a Função seja chamada de outro fonte e o array
// com as impressoras não fsicais esteja vazio
// -------------------------------------------------------------------
If Len(aImpNotFisc) == 0
	aImpNotFisc := LJ121LIF( Nil, Nil, Nil, Nil, Nil, Nil, .T.)
Endif

If !Empty(cImpModel) .AND. Len(aImpNotFisc) > 0

	If aScan( aImpNotFisc, cImpModel ) == 0
		lRet := .T. //eh fiscal pois nao esta na lista das nao fiscais
	EndIf	 

EndIf

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} Lj121CfgNF
Função responsável por montar e atualizar o conteudo da aba NFC-e.

@type		Static Function
@author  	felipe.martinez
@since   	01/02/2017
@version 	P12
@param		cOpc: Operação a ser realizada na  , Modelo impressora
@return	    lRet - Retorna se a impressora eh fiscal
/*/
//-----------------------------------------------------------------
Static Function Lj121CfgNF(cAtivSAT, cImpFisc)
Local cMsg		:= ""
Local lMsgErro	:= .F.

//Atualiza dados (nao utilizar o SuperGetMv pois guarda em cache o conteudo)
oURLTSS:cText	:= AllTrim(GetMv("MV_NFCEURL",,""))
oToken:cText	:= AllTrim(GetMv("MV_NFCETOK",,""))
oUTCNfce:cText	:= AllTrim(GetMV("MV_NFCEUTC",,""))
oIDToken:cText	:= AllTrim(GetMv("MV_NFCEIDT",,""))

//Verifica se a impressora nao fiscal esta configurada
If !LjIFTipoEcNf(cImpFisc)
	cMsg += '- ' + STR0245 + '<br>' //'Configurar a impressora não-fiscal na aba "Impressoras".'
	lMsgErro := .T.
EndIf

//Verifica se o SAT esta ativado
If AllTrim(cAtivSAT)=="Sim"
	cMsg +=	'- ' + STR0235 + '<br>'  //'Desativar o SAT na aba "SAT".'
	lMsgErro := .T.
EndIf

//Verifica se os parametros estao preenchidos
If Empty(oURLTSS:cText) .Or. Empty(oToken:cText) .Or. Empty(oUTCNfce:cText) .Or. Empty(oIDToken:cText)
	cMsg += '- ' + STR0242 + '<br>' //'Clicar no botão "Configurações" ao lado para ajustar os parâmetros da NFC-e.'
	lMsgErro := .T.
EndIf

//Verifica se o estado esta habilitado para NFC-e
If !LJAnalisaLEG(61)[1] .AND. !(ExistFunc("LjTipoPAF") .AND. cTipoPAF $ TIPO_PAF_NFCE)
	cMsg += '- ' + STR0243 + AllTrim(SM0->M0_ESTCOB) + STR0244 + '<br>' //#'O estado (' ## ') da filial utilizada não emite NFC-e.'
	lMsgErro := .T.
EndIf

If lMsgErro
	//Tratamento mensagem de erro 
	cMsg :=	'<p style="color:red">' +; 
			'<h4>' + STR0233 + '</h4><br>' +; //NFC-e desativada!
			STR0234 + '<br>' +; //'Ajuste(s) a ser(em) realizado(s):'
			cMsg +;
			'</p>'
Else
	cMsg := ''	
EndIf

oAtivNFce:cText	:= iIf(lMsgErro, "Não", "Sim")

//Se houve mudança de conteudo da NFC-e, é mostrado mensagem para gravar
If cModulo != "FAT"
	If !lMsgErro .And. !lMsgErro <> SLG->LG_NFCE
		cMsg += '<p style="color:red">' + STR0246 + '<p>' //"Salve o cadastro para efetivar a ativação da NFC-e."
	EndIf
Else
	If !lMsgErro <> SLG->LG_NFCE
		cMsg += '<p style="color:red">' + STR0247 + '<p>' //'Não será possivel alterar as configurações da NFC-e através do módulo "Faturamento". Utilize outro módulo (Ex.: SIGALOJA).'
	EndIf
EndIf

cMsg +=	STR0236 + '<br>' +; //'Para mais detalhes sobre NFC-e consutlar a documentação. Copie o link abaixo e abra em seu navegador.'
		'<a href="http://tdn.totvs.com/pages/viewpage.action?pageId=210055818"> http://tdn.totvs.com/pages/viewpage.action?pageId=210055818</a><br>'

If ExistFunc("LjTipoPAF") .AND. cTipoPAF $ TIPO_PAF_NFCE
	If lMsgErro
		cTipoPAF:=TIPO_PAF_ECF
	Else
		cMsg += '<p style="color:red">' + 'Habilitado o Regime Transitório PAF-NFc-e, válido somente para o Estado de SC, conforme Ato Diat nº 15/2022' + '<p>'
	Endif 
Endif 

oEditNfce:TextFormat(1) //1=Html 2=Texto simples
oEditNfce:Load(cMsg)

//Atualiza objetos da tela
oAtivNFce:Refresh()
oURLTSS:Refresh()
oToken:Refresh()
oUTCNfce:Refresh()
oIDToken:Refresh()
oEditNfce:Refresh()

Return .T.

//--------------------------------------------------------------------------
/*/{Protheus.doc} lj121IsNfce
Retorna se esta configurada a estação para NFC-e.

@type		Function
@author  	felipe.martinez	
@since   	13/02/2017
@version 	P12
@param		cAtivSAT: se o SAt esta Habilitado (Sim) ou desabilitado (Não)
			cImpFisc: configuração da impressora  
@return	    lRet - Se ".T." estação configurada para NFC-e / 
			".F." estação não configurada para NFC-e
/*/
//--------------------------------------------------------------------------
Static Function lj121IsNfce(cAtivSAT, cImpFisc)
Local lRet := .F.

Default cAtivSAT := ""
Default cImpFisc := ""

If AllTrim(Upper(cAtivSAT)) <> "SIM"
	lRet := (LJAnalisaLEG(61)[1] .OR. (Iif(!Empty(cTipoPAF), cTipoPAF$TIPO_PAF_NFCE, .F.))) .And. LjIFTipoEcNf(cImpFisc)
EndIf
	
Return lRet

//------------------------------------------------------------------------
/*/{Protheus.doc} lj121CadX5
Função responsável por incluir a serie no SX5 quando NFC-e.

@type		Function
@author  	felipe.martinez	
@since   	13/02/2017
@version 	P12
@param		cSerie: serie informado o cadastro da estação
@return	    Nil
/*/
//------------------------------------------------------------------------
Static Function lj121CadX5(cSerie)
Local cReturn	:= ""
Local cTabela	:= "01"
Local cNum		:= StrZero(1,9)
Local cOpcao	:= AllTrim(LjTpNrNFS()) //Retorno do parametro MV_TPNRNFS, onde sera controlado o numero da NFC-e  -> 1=SX5;2=SXE/SXF;3=SD9
Local cMsg		:= ""

cSerie := AllTrim(cSerie)

If cOpcao == "1"
	//verifica se a tabela e chave estao no SX5
	If !GenTabPos( cTabela, cSerie, @cReturn ) .And. SX5->(RecLock("SX5", .T.))
		SX5->X5_FILIAL	:= xFilial("SX5")
		SX5->X5_TABELA	:= cTabela
		SX5->X5_CHAVE	:= cSerie
		SX5->X5_DESCRI	:= cNum
		SX5->X5_DESCSPA	:= cNum
		SX5->X5_DESCENG	:= cNum
		SX5->(MSUnlock())
		cMsg := STR0239 + cSerie + STR0240 + CHR(10)+CHR(13) +; //#"Foi incluida a série '" ##"' e numeração '000000001' no dicionário de dados Tabelas Genéricas (SX5)."
				STR0241	+ CHR(10)+CHR(13) +;	//#"Inclusão necessária para a correta transmissão da NFC-e.  Caso necessário alteração, basta acessar o ‘Configurador / Tabelas Genéricas’ e procurar pelas seguintes informações:"
				STR0248 + CHR(10)+CHR(13) +;	//#"Tabela: '01' "
				STR0249 + " '" + cSerie + "'"	//#"Chave:"
	EndIf
Else
	cMsg := STR0250 + cSerie + STR0251 + iif(cOpcao=="3"," (SD9)","") + STR0252 //#"Para a correta transmissão da NFC-e, a numeração da serie '" ##"' deve ser incluída manualmente na tabela de controle de numerações de Nota" ###" caso não exista."	
EndIf

If !Empty(cMsg)
	MsgInfo(cMsg)
EndIf

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} Lj121VldSat
Validação de SAT para Emulador

@type function
@author  	julio.nery
@since   	20/03/2017
@version 	P12
@return	    lRet - Retorna se eh emulador SAT
/*/
//--------------------------------------------------------
Static Function Lj121VldSat()
Local lRet := .F.

	//So habilita o emulador para a variável MV_SATTEST 11.111.111/1111-11
If	(ValType(SuperGetMV("MV_SATTEST",,"")) == "C" .AND. !Empty(SuperGetMV("MV_SATTEST",,"")) .AND.;
  	RTrim(SuperGetMV("MV_SATTEST",,"")) =  "11111111111111") .Or. ;
  	(GetPvProfString("logdll", "SAT", "0" , GetClientDir() + "sigaloja.ini") == "1")
  	lRet := .T.  	
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LjVldNFCe
Procura se existe outro PDV (NFC-e) com a mesma Serie e se existir impede a inclusao

@type function
@author  	albertod
@since   	18/04/2017
@version 	P11.8
@param		cTipo 	Tipo de operacao (I=Inclusao; A=Alteracao)
@param		cPDV 	Codigo do PDV
@param		cSerie 	Serie do PDV
@return	    lRet - Retorna se prossegue ou nao (caso tenha outro PDV com a mesma serie)
/*/
//--------------------------------------------------------
Static Function LjVldNFCe( cTipo , cPDV, cSerie )
Local aAreaSLG	:= SLG->(GetArea())
Local lRet		:= .T.
Local nRecno	:= 0
Local lLG_NFCE 	:= SLG->(ColumnPos("LG_NFCE")) > 0

If cTipo $ "I|A" .And. lLG_NFCE
	nRecno := IIf(cTipo == "A",SLG->(Recno()),0)  //Nao permite validar o mesmo registro caso seja alteracao
	
	SLG->(DbSeek(xFilial("SLG")))
	
	Do While !SLG->(Eof()) .And. SLG->LG_FILIAL == xFilial("SLG")
		If SLG->LG_NFCE .And. SLG->LG_SERIE == cSerie .AND. IIf( nRecno > 0, nRecno <> SLG->(Recno()), .T. )
			MsgAlert(STR0253 + " [" + cSerie + "] " +; //"Foi identificado que a Série"
			STR0254 + SLG->LG_CODIGO + ", " + "PDV: " + SLG->LG_PDV + Chr(13) + Chr(13) +; //"configurada nesta estação, já está configurada na estação: "
			STR0255) //"Não é permitido utilizar a mesma Série para NFC-e em mais de um PDV."
			lRet := .F.
			Exit
		EndIf
		SLG->(DbSkip())
	EndDo
	
EndIf

RestArea(aAreaSLG)

Return lRet

/*/{Protheus.doc} LjSetGuid
	Gera Guid para a LOJA
	@type  Function
	@author bruno.inoue
	@since 25/07/2017
	@version 11.80
	@param 
	@return 
/*/
Function LjSetGuid(cChvReq,OChvReq)
Local aArea 	:= SLG->(GetArea())

If SLG->( ColumnPos("LG_CHVREQ") ) > 0
	SLG->(DbSeek(xFilial("SLG")))
	Do While !SLG->(Eof()) .And. SLG->LG_FILIAL == xFilial("SLG")
		If !Empty( AllTrim(SLG->LG_CHVREQ) )
			cChvReq := SLG->LG_CHVREQ
			Exit
		EndIf
		SLG->(DbSkip())
	EndDo
EndIf

//Se não encontrou nenhuma estação configurada com a chave de requisição
//Gera um novo codigo
If Empty(cChvReq)
	cChvReq := FWUUIDv4(.T.)
EndIf

RestArea(aArea)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj121VlSer
Função responsável pela validação do campo Serie

@author  eduardo.sales
@since   05/12/2017
@version P11
@return  lRet - Retorna se prossegue ou nao
/*/
//-------------------------------------------------------------------
Static Function Lj121VlSer(cImpFisc, cSerie, cTipo)

Local lRet 		:= .T.
Local lLJRMBAC	:= SuperGetMV("MV_LJRMBAC",,.F.)	// Habilita a integração com RM

If (Empty(cImpFisc) .Or. (cTipo <> "I" .And. !Empty(cSerie))) .And. cTipo $ "AI"
	If Empty(cSerie)
		cSerie := Space(Len(cSerie))
	ElseIf lLJRMBAC // Se a integração RM estiver habilitada, não poderá habilitar o campo Serie para edição
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj121Pref
Função responsável pela geração do numero sequencial de prefixo

@author  Paulo Henrique
@since   10/06/2018
@version P12
@return  cRet - Retorna o prefixo
/*/
//-------------------------------------------------------------------
Function Lj121Pref()
Local cRet 		:= "000"
Local cAliasSLG	:= GetNextAlias()
Local cQuery	:= ""
Local lFound	:= .T.
Local lSX5		:= .F.
Local lSE1		:= .F.

If SLG->(ColumnPos("LG_PREFIXO")) > 0
	#IFDEF TOP
	
		cQuery  := " SELECT ISNULL(MAX(SLG.LG_PREFIXO),'   ') LG_PREFIXO"
		cQuery  += " FROM " + RetSqlName("SLG") + " SLG"	
		cQuery  += " WHERE SLG.LG_FILIAL = '" + xFilial('SLG') + "' AND"
		cQuery  += " SLG.D_E_L_E_T_ = ' ' "
		cQuery	:= ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cAliasSLG,.F.,.T.)
		
		If (cAliasSLG)->(!Eof())
			cRet := IIF( Empty((cAliasSLG)->LG_PREFIXO),"000",(cAliasSLG)->LG_PREFIXO)
		EndIf
		
		cRet := Soma1(cRet)
		
		While lFound
			//Busco na tabela 94 o prefixo
			SX5->(DbSetOrder(1))
			If SX5->(DbSeek(xFilial("SX5")+"94"+cRet))
				cRet := Soma1(cRet)
				lSX5 := .F.
			Else
				lSX5 := .T.
			EndIf
			
			//Busco na tabela SE1 o prefixo
			SE1->(DbSetOrder(1))
			If SE1->(DbSeek(xFilial("SE1")+cRet))
				cRet := Soma1(cRet)
				lSE1 := .F.	
			Else
				lSE1 := .T.	
			EndIf
			
			If lSX5 .And. lSE1
				lFound := .F.
			EndIf
		
		End
		
	#ENDIF
EndIf

Return cRet

//----------------------------------------------------------------------
/*/{Protheus.doc} Lj121VlTPD
Faz validação referente a dados da Aba "Totvs Pagamento Digital" (TEF 2.0)

@author  Alberto Deviciente
@since   17/11/2020
@version P12

@param cTipo, Caractere, tipo de operacao a ser efetuado (I=Inclusao; A=Alteracao; E=Exclusao)
@param oCfgTef, Objeto, Objeto de configuração do TEF 2.0

@return  lRet, Lógico, Retorna se a validação está OK.
/*/
//----------------------------------------------------------------------
Static Function Lj121VlTPD(cTipo, oCfgTef)
Local lRet			:= .T.
Local lUsePayHub	:= ExistFunc("LjUsePayHub") .And. LjUsePayHub()

If cTipo $ "I|A" //I=Inclusao; A=Alteracao
	If lUsePayHub .And. ValType(oCfgTef) == "O"
		lRet := oCfgTef:TefVl(@oCfgTef)
		If !lRet
			Alert(oCfgTef:cMenssagem)
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegVarej()
Atualizações na configuração de Integrações Varejo

@type    function
@param   cCodEst, Caractere, Código da Estação
@param   lExclusao, Lógico, Define se é uma exclusão
@return  Lógico, Define se a integração foi feita corretamente
@author  Rafael Tenorio da Costa
@since   26/04/21
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function IntegVarej(cCodEst, lExclusao)

    Local lRetorno  := .T.
    Local oLjIntCfg := Nil

    If ExistFunc("LjxRaasInt") .And. LjxRaasInt()

        oLjIntCfg := LjIntegrationConfiguration():New("RAAS", cCodEst)

        lRetorno := oLjIntCfg:StartInterface(lExclusao)

        FwFreeObj(oLjIntCfg)
    EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaTela()
Efetua validações ao fechar a tela

@type    function
@param   cTipo, Caractere, Tipo de manutenção I=Inclusão, A=Alteração, E=Exclusão
@param   cCodEst, Caractere, Código da Estação
@return  Lógico, Define se a integração foi feita corretamente
@author  Rafael Tenorio da Costa
@since   26/04/21
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidaTela(cTipo, cCodEst)

    Local lRetorno := .T.
    Local aArea    := GetArea()
    Local aAreaSLG := SLG->( GetArea() )

    If cTipo == "I" .And. !Empty(cCodEst)

        //Exclui configurações da Integrações Varejo
        SLG->( DbSetOrder(1) ) //LG_FILIAL + LG_ESTACAO
	    If !SLG->( DbSeek(xFilial("SLG") + cCodEst) )
            IntegVarej(cCodEst, .T.)
        EndIf
    EndIf

    RestArea(aAreaSLG)
    RestArea(aArea)

Return lRetorno
