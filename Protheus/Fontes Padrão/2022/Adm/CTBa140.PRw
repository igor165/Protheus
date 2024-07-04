// 17/08/2009 -- Filial com mais de 2 caracteres

#INCLUDE "CTBA140.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
# Define IMG_INCLUIR	"BMPINCLUIR"     


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBA140   ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 11.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao do Cadastro de Moedas Contabeis                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA140()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA140(aRotAuto,nOpcAuto)
Local cTabla := SuperGetMV("MV_CTBMOED", .T., '')
Private aRotina 	:= MenuDef()
Private cCadastro	:= STR0006  // "Cadastro Moedas Contabeis"
Private lExibMsg   := .T.   
PRIVATE lCTB140AUT := ( aRotAuto <> NIL )
PRIVATE aCabAuto 	:= aRotAuto

// Atualiza o campo moeda com conteudo 1
If cPaisLoc $ "ANG/ARG/AUS/BOL/BRA/CHI/COL/COS/DOM/EQU/EUA/HAI/MEX/PAD/PAN/PER/POR/PTG/SAL/TRI/URU/VEN'
	DbSelectArea( "SA6" )
	SA6->( DbGoTop() )
	While SA6->( !Eof() )
		If SA6->A6_MOEDA <= 0
			RecLock( "SA6" )
			SA6->A6_MOEDA := 1
			MsUnLock()
		EndIf
		SA6->( DbSkip() )
	End
EndIf

If cPaisLoc == "MEX" .And. CTO->(FieldPos("CTO_MOESAT")) > 0 .And. !Empty(cTabla)
	CTBMoedSAT(cTabla)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCTB140AUT
	DEFAULT nOpcAuto := 3
	MBrowseAuto(nOpcAuto,aCabAuto,"CTO")
Else	
	mBrowse( 6, 1,22,75,"CTO")
Endif
dbSelectArea("CTO")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ctb140Inc ³ Autor ³ Pilar S Albaladejo    ³ Data ³ 11.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inclusao de Moedas                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb140InccAlias,nReg,nOpc,lNovaTela,lWizard)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias			                                       ³±±
±±³          ³ ExpN1 : Numero do Registro                                 ³±±
±±³          ³ ExpN2 : Opcao do Menu                                      ³±±
±±³          ³ ExpL1 : Indica se a funcao eh chamada pela nova tela       ³±±
±±³          ³ ExpL2 : Indica se a funcao passa pela inclusao do Wizard   ³±±
±±³          ³ ExpL3 : Indica se a funcao passa pela tela inicial do Wiz  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb140Inc(cAlias,nReg,nOpc,lNovaTela,lWizard,lWiz2,oWndDetalhe)

Local aSaveArea	:= GetArea()
Local nOpca		:= 0
Local cMensagem	:= STR0007 //"Apos a inclusao de uma nova moeda, cadastrar a amarracao da moeda com um calendario contabil."                  
Local cMensagem1	:= STR0008 //"O codigo da moeda deve ser igual a quantidade de moedas existente no cadastro. "
Local lExibMsg	:= Type("aCabAuto") <> 'A'  
Local nCntFor		:= 0
Local nCntFor2	:= 0
Local aCoords		:= {}

DEFAULT lNovaTela 	:= .F.
DEFAULT lWizard		:= .F. //variavel utilizada pelo wizard
DEFAULT lWiz2			:= .F. //variavel utilizada pelo wizard
DEFAULT oWndDetalhe	:= Nil

dbSelectArea("CTO")
dbSetOrder(1)

BEGIN TRANSACTION

If Type("lCTB140AUT") <> "U" .and. lCTB140AUT
	RegToMemory("CTO",.T.,.F.)  
	If EnchAuto(cAlias,aCabAuto,,nOpc)
		nOpca := AxIncluiAuto(cAlias)
	EndIf
Else
	If lWizard
		//nOpca	:= 1
		For nCntFor := 1 to Len(oGetD:aCols)
			If !oGetD:aCols[nCntFor][Len(oGetD:aHeader)+1]
				RecLock("CTO",.T.)
				For nCntFor2 := 1 To Len(oGetD:aHeader)
					If ( oGetD:aHeader[nCntFor2][10] != "V" )
						CTO->(FieldPut(FieldPos(oGetD:aHeader[nCntFor2][2]),oGetD:aCols[nCntFor][nCntFor2]))
					EndIf
				Next nCntFor2
				CTO->CTO_FILIAL	:= xFilial("CTO")
				MsUnlock()
			EndIf
		Next nCntFor
	ElseIf !lWizard .AND. !lWiz2 
		//Se existir o objeto da nova tela de cadastros
		If Type("oWndDetalhe") == "O"
			aCoords := FWGetCoorsAbsolute(oWndDetalhe) 
			aDim :=  {aCoords[2],aCoords[1],aCoords[2]+oWndDetalhe:nHeight,aCoords[1]+oWndDetalhe:nWidth} // DLGinPANEL(oWndDetalhe)		
			nOpca := AxInclui(cAlias,nReg,nOpc,;
								/*[aAcho]*/,; 			//[4]
								/*[cFunc]*/,;				//[5]
								/*[aCpos]*/,;				//[6]
								"Ctb140Vld()",;			//[7]
								/*[lF3]*/,;				//[8]
								/*[cTransact]*/,;			//[9]
								/*[aButtons]*/,;			//[10]
								/*[aParam ]*/,;			//[11]
								/*[aAuto]*/,;				//[12]
								/*[lVirtual]*/,;			//[13]
								/*[lMaximized]*/,;		//[14]
								/*[cTela]*/,;				//[15]
								/*[lPanelFin]*/,;			//[16]
								oWndDetalhe/*[oFather]*/,;//[17]
								aDim /*[aDim]*/,;			//[18]
								/*[uArea]*/,;				//[19]
								.T./*[lFlat]*/)			//[20]
		Else
			nOpca := AxInclui(cAlias, nReg, nOpc,,,,"Ctb140Vld()")
		Endif
	EndIf
	//nOpca := AxInclui(cAlias,nReg,nOpc,,,,,,)
Endif

If nOpca == 1  
	// Recarrega variavel de moedas em uso			
	__nQuantas := CtbMoedas()

	SX3->(DbSetOrder(2))
	If CTO->CTO_MOEDA <> "01" .And. ! SX3->(DbSeek("CT2_VALR" + CTO->CTO_MOEDA))
		SX3->(DbSetOrder(1))
		SX3->(DbSeek("CT3"))
		SX3->(DbSkip(-1))
		CtbImpReg("SX3", { 	{ "CT2", Soma1(SX3->X3_ORDEM),"CT2_VALR"  + CTO->CTO_MOEDA,;
							"N",17,2,"Vlr Moeda " + CTO->CTO_MOEDA,"Vl Moneda " +;
							CTO->CTO_MOEDA, "Vl.Curr. " + CTO->CTO_MOEDA,;
							"Valor Moeda " + CTO->CTO_MOEDA,;
							"Valor Asiento Moneda " + CTO->CTO_MOEDA,;
							"Currency " + CTO->CTO_MOEDA + " Entry Value",;
							"@E 99,999,999,999,999.99","ValidaValor(M->CT2_VALR" +;
							CTO->CTO_MOEDA + ") .And. Ctb105Conv(M->CT2_VALR" +;
							CTO->CTO_MOEDA + ")","€€€€€€€€€€€€€€ ",;
							"","",1,"‚À","","","S","N","","V","","","","","",;
							"","","","","" } })
	Endif
	SX3->(DbSetOrder(1)) 
	                   
	//Exibira a mensagem informando que a moeda contabil devera ser amarrada com um calendario contabil. 
	If lExibMsg
		MsgInfo(cMensagem)
	EndIf

	//Verificar se o codigo da moeda eh igual a quant. de moedas existente no cadastro de moedas. 
	If CTO->CTO_MOEDA <> StrZero(__nQuantas,2)
		MsgAlert(cMensagem1) //"O codigo da moeda deve ser igual a quantidade de moedas existente no cadastro. "		
	EndIf		
		
	// ponto de entrada para antes da gravação
	IF ExistBlock("Ctb140Inc") 
		ExecBlock( "Ctb140Inc", .F. , .F. ) 
	Endif

	If lNovaTela
		//Reordena(2,oTreeCad2,IMG_INCLUIR,cCabTMoeda)
		Ctba011AtMoe(nOpc)
	Endif
EndIf

END TRANSACTION

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integra Protheus x TIN                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == 1 .AND. FWHasEAI("CTBA140",.T.,,.T.)
	//Informado o quinto parâmetro "cFunName" para que o response message retorne corretamente para o adapter de moeda,
	//no caso da integração ser chamada pelo assistente de criação de calendário contábil ou ser chamada por outra rotina 
	FwIntegDef( 'CTBA140', , , , 'CTBA140' )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integra Protheus x LEGAL DESK - SIGAPFS             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Grava na fila de sincronização se o parâmetro MV_JFSINC = '1' - SIGAPFS
If nOpca == 1
	J170GRAVA("CTO", xFilial("CTO") + CTO->CTO_MOEDA, "3")
EndIf 
 
RestArea(aSaveArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTB140WIZ  ³ Autor ³ Leandro F. Dourado     ³ Data ³ 25/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de moedas                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Ctb140Wiz()

Local cCadastro		:= STR0009
Local nOpca 			:= 0
Local aWizMoeda
Local aWizPanMoe
Local aPanel
Local bFinalWiz
Local lRet
Local nSisMoedas						// Informa o numero de moedas configuradas no sistema
Local nMoedas			:= 0	 				// Informa o numero de moedas cadastradas
Local nMax
Local aDadMoed
Local lWizard 		:= .T.
Local nWiz 			:= 0 			//variável para informar numero inicial do panel dos outros assistentes

Private oGetD			:= Nil  
Private aHeaderSv		:= {{},{}}		// Array para salvar aHeaders
Private aHeader      	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader
Private aColsSv		:= {{},{}}		// Array para salvar aCols
Private aCols        	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols

CTO->(dbGoTop())
CTO->(dbEval({|| nMoedas++ }))
CTO->(dbGoTop())

nSisMoedas				:= ADMMoedas()

nMax					:= nSisMoedas - nMoedas

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array aWizMoeda - Estrutura:                        ³
//³ Posicao 1 - Titulo                                  ³
//³         2 - Mensagem Explicativa                    ³
//³         3 - bNext                                   ³
//³         4 - bFinish                                 ³
//³         5 - lPanel                                  ³
//³         6 - lNoFist                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
aWizMoeda 				:= {}
aAdd(aWizMoeda, cCadastro)
aAdd(aWizMoeda, STR0010 + cCadastro + STR0011)  //"Este assistente do "###" vai lhe orientar no preenchimento dos dados."
aAdd(aWizMoeda, {||.T.})
aAdd(aWizMoeda, {||.T.})
aAdd(aWizMoeda, .T.)
aAdd(aWizMoeda, .F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Paineis                                             ³
//³ Array aWizPanel - Estrutura:                        |
//³ Para cada linha deste array multidimensional        ³
//³ Posicao 1 - Titulo do painel                        ³
//³         2 - Mensagem Explicativa                    ³
//³         3 - bNext                                   ³
//³         4 - bFinish                                 ³
//³         5 - lPanel                                  ³
//³         6 - bBack                                   ³
//³         7 - bExecute                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aWizPanMoe  			:= {}
aPanel					:= {}
//bFinalWiz 				:= {|| If(nOpca == 1,(n:=1),NIL)}
							//"Atencao"##"Confirma os Dados"##"Sim"##"Nao"

//{||  If(nOpca == 1,(n:=1,lRet := Ctb140Vld,If(lRet, .T., (nOpca := 0, .F.))),NIL)}

If nMax > 0
	aAdd(aWizPanMoe, {cCadastro, STR0012 ,;
		{||lRet:= Aviso(STR0013,STR0022,{STR0014, STR0015})==1,If(lRet,(If (Ct140TudOK(),(Ctb140Inc("CTO",0,3,.T.,.T.,.T.),.T.),(nOpca := 0, .F.))),(nOpca := 0, .F.))},;
		{||.T.}, .T.,{||.T.}	, {||CTB140WMoe(aPanel[1],nMax,@lWizard),nOpca := 1,.T.} })
		aAdd(aWizPanMoe, {cCadastro, "" ,{||.T.},{||.T.}, .T.,{||.T.}	, {||Ctb140WFim(aPanel[2]),.T.} })
	nWiz := 2	
Else
	aAdd(aWizPanMoe, {cCadastro, "" ,{||.T.},{||.T.}, .T.,{||.T.}	, {||CTBWzAlt(aPanel[1]),.T.} })
	nWiz := 1
EndIf

CTB010WIZ(.T.,aWizMoeda,aWizPanMoe,aPanel,nWiz)


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTB140WMoe  ³ Autor ³ Leandro F. Dourado  ³ Data ³ 25/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela do Wizard do cadastro de Moedas                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CTB140WMoe(oDlg,nMax,lWizard)

Local nX 	 := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aCpoGDa      	:= {}				// Campos Visiveis da GetDados
Local cAliasGD			:= "CTO"		    // Alias da GetDados
Local nSuperior    	:= 50 // 081     	// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= 30	            // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= 120 				// Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= 280 			    // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
Local cLinOk       	:= "Ct140LinOK"	// Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= "AllwaysTrue"   // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= ""        		// Nome dos campos do tipo caracter que utilizarao incremento automatico.            
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                                                         
Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo                                           
Local cSuperDel		:= ""              	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk       	:= "AllwaysFalse" 	// Funcao executada para validar a exclusao de uma linha do aCols                                        
Local aAlterGDa		:= {}				// Campos alteraveis da GetDados
Local nUsado2			:= 0

aHeader:= aClone(aHeaderSv[2])
aCols	:= aClone(aColsSv[2])    

DbSelectArea("SX3")
DbSetOrder(1)
MsSeek(cAliasGD)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Campos visiveis da GetDados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !Eof() .And. SX3->X3_ARQUIVO == cAliasGD
	If	!(AllTrim(SX3->X3_CAMPO) $ "CTO_FILIAL") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)		
		AAdd(aCpoGDa,SX3->X3_CAMPO)
	EndIf		 
	DbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Campos alteraveis da GetDados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAlterGDa := aClone(aCpoGDa)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nUsado2:=0
dbSelectArea("SX3")
dbSeek("CTO")
aHeader:={}
While !Eof().And.(x3_arquivo=="CTO")
	If X3USO(x3_usado).And.cNivel>=x3_nivel
    	nUsado2:=nUsado2+1
        aAdd( aHeader, { AlLTrim( X3Titulo() ), ; // 01 - Titulo
		SX3->X3_CAMPO	, ;			// 02 - Campo
		SX3->X3_Picture	, ;			// 03 - Picture
		SX3->X3_TAMANHO	, ;			// 04 - Tamanho
		SX3->X3_DECIMAL	, ;			// 05 - Decimal
		SX3->X3_Valid  	, ;			// 06 - Valid
		SX3->X3_USADO  	, ;			// 07 - Usado
		SX3->X3_TIPO   	, ;			// 08 - Tipo
		SX3->X3_F3		   , ;		// 09 - F3
		SX3->X3_CONTEXT   , ;       // 10 - Contexto
		SX3->X3_CBOX	  , ; 		// 11 - ComboBox
		SX3->X3_RELACAO    } )   // 12 - Relacao
	Endif
	
    dbSkip()
End

RegToMemory("CTO", .T.)


aCols:={Array(nUsado2+1)}
aCols[1,nUsado2+1]:=.F.
For nX:=1 to nUsado2
	
	IF aHeader[nX,2] == "CTO_MOEDA"
		aCols[1,nX]:= "0001"
	ELSE
		aCols[1,nX]:=CriaVar(aHeader[nX,2])
	ENDIF
		
Next

oGetD:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,GD_INSERT+GD_UPDATE,cLinOk,cTudoOk,cIniCpos,aAlterGDa,nFreeze,;
								5,cFieldOk,cSuperDel,cDelOk,oDlg,aHeader,aCols)	                             

lWizard 		:= .T.
aHeaderSv[2]	:= aClone(aHeader) 
aColsSv[2]		:= aClone(aCols) 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTBWzAlt  ³ Autor ³ Leandro F. Dourado     ³ Data ³ 25/10/11³  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela Alternativa do Wizard                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CTBWzAlt(oDlg)
Local oSay
Local oFont

oFont := TFont():New(,,-14,,, )
oFont2 := TFont():New(,,-18,,.T., )

oSay := TSay():Create(oDlg, {||STR0016},,130,,oFont2,,,,,,,,)
oSay := TSay():Create(oDlg, {||STR0017 + CRLF + STR0018},20,20,,oFont,,,,,,,,60)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtbWSave  ³ Autor ³ Leandro F. Dourado     ³ Data ³ 25/10/11³  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela para salvar as moedas cadastradas                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Ctb140WFim(oDlg)
Local oSay
Local oFont

oFont 	:= TFont():New(,,-14,,, )
oFont2 := TFont():New(,,-18,,.T., )

oSay := TSay():Create(oDlg, {||STR0016},,130,,oFont2,,,,,,,,)
oSay := TSay():Create(oDlg, {||STR0019 + CRLF + STR0020},20,20,,oFont,,,,,,,,60)


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTB140Alt  ³ Autor ³ Renato F. Campos     ³ Data ³ 24/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de moedas                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTB140Alt(cAlias, nReg, nOpc, lNovaTela, oWndDet)
Local nOpcA		:= 0
Local cSimbAnt	:= CTO->CTO_SIMB
Local lCanAlt		:= .T.

DEFAULT lNovaTela		:= .F.
DEFAULT oWndDet	:= Nil
                  
If lCanAlt
	BEGIN TRANSACTION
		If Type("lCTB140AUT") <> "U" .AND. lCTB140AUT
			RegToMemory("CTO",.T.,.F.)  
			If EnchAuto(cAlias,aCabAuto,,nOpc)
				nOpca := AxIncluiAuto(cAlias,,,4,RecNo())
			Else 
				nOpca := 0
			EndIf
		Else  
			//Se existir o objeto da nova tela de cadastros 
			If ValType(oWndDet) == "O"			
				aCoords	:= FWGetCoorsAbsolute(oWndDet) 
				aDim		:= {aCoords[2],aCoords[1],aCoords[2]+oWndDet:nHeight,aCoords[1]+oWndDet:nWidth}		
				nOpca		:= AxAltera(cAlias,nReg,nOpc,;
  										/*[aAcho]*/,; 			//[4]
	 									/*[aCpos]*/,;				//[5]
										/*[nColMens]*/,;			//[6]
										/*[cMensagem]*/,;			//[7]
										/*[cTudoOk]*/,;			//[8]
										/*[cTransact]*/,;			//[9]
										/*[cFunc]*/,;				//[10]
										/*[aButtons]*/,;			//[11]
										/*[aParam]*/,;			//[12]
										/*[aAuto]*/,;				//[13]
										/*[lVirtual]*/,;			//[14]
										/*[lMaximized]*/,;		//[15]
										/*[cTela]*/,;				//[16]
										/*[lPanelFin]*/,;			//[17]
		 								oWndDet/*[oFather]*/,;//[18]
										aDim /*[aDim]*/,;			//[19]
										/*[uArea]*/,;				//[20]
										.T./*[lFlat]*/)			//[21]
		   	Else
				nOpca := AxAltera(cAlias, nReg, nOpc)
			Endif
		EndIf
	
		if nOpca == 1
			
			// ponto de entrada para antes da gravação
			If ExistBlock("CTB140Alt") 
				ExecBlock( "CTB140Alt", .F. , .F. ) 
			EndIf
			If lNovaTela
				//Reordena(2,oTreeCad2,IMG_INCLUIR,cCabTMoeda)
				Ctba011AtMoe(nOpc)
			Endif
		endif	
	END TRANSACTION
EndIf        

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integra Protheus x TIN                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpca == 1 .and. FWHasEAI("CTBA140",.T.,,.T.)
	//Informado o quinto parâmetro "cFunName" para que o response message retorne corretamente para o adapter de moeda,
	//no caso da integração ser chamada pelo assistente de criação de calendário contábil ou ser chamada por outra rotina 
	FwIntegDef( 'CTBA140', , , , 'CTBA140' )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integra Protheus x LEGAL DESK - SIGAPFS             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Grava na fila de sincronização se o parâmetro MV_JFSINC = '1' - SIGAPFS
If nOpca == 1
	J170GRAVA("CTO", xFilial("CTO") + CTO->CTO_MOEDA, "4")
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ctb140Bloq³ Autor ³ Pilar S Albaladejo    ³ Data ³ 11.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Aviso de Bloqueio / Desbloqueio da moeda                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTB140Bloq(cBloq)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Conteudo do campo CTO_BLOQ                          ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB140Bloq(cBloq)

Local aSaveArea := GetArea()

If cBloq != CTO->CTO_BLOQ
	Help(" ",1,"CTB140BL")
EndIf
	
RestArea(aSaveArea)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ExistCpoCt1³ Autor ³ Claudio D. de Souza  ³ Data ³ 05.10.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica a existencia do campo CVD para as moeda do CTO    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExistCpoCT1(cMoeda,cCampo,lContinua,lHelp)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1: .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Código da moeda                                    ³±±
±±³          ³ ExpC2 - Nome do campo                                      ³±±
±±³          ³ ExpL1 - Flg q indica se deve continuar.					  ³±±
±±³          ³ ExpL2 - Exibe Help - .F., .T. 							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION ExistCpoCt1( cMoeda, cCampo, lContinua, lHelp )

LOCAL lRet := ! Empty(cMoeda) .And. Ct1->(FieldPos(cCampo + cMoeda)) > 0 

DEFAULT lContinua := .F.

If At(" ", cMoeda) > 0
   	If lhelp
   		Help( " ", 1, "Texto" )
   	EndIf	
	lRet := .F.	
Endif

If cMoeda <> "01" .And. Ct1->(FieldPos(cCampo + cMoeda)) == 0 
   	lRet := .F.
   	If lhelp
   		Help( " ", 1, "MOEDANEXIS" )
   	EndIf	
Endif

RETURN lRet .Or. lContinua


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ctb140Vld ³ Autor ³ Pilar S. Albaladejov  ³ Data ³ 14.07.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da Moeda -> Usado no SX3                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb140Vld()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb140Vld()

Local aSaveArea := GetArea()
Local lRet		:= .T.                   

If !isBlind()
	lRet :=	ExistCpoCt1(M->CTO_MOEDA,"CT1_CVC",.F.,.T.) 
	
	If lRet
		lRet := Existchav("CTO", M->CTO_MOEDA,,)
	EndIf
	
	RestArea(aSaveArea)
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³01/12/06 ³±±
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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
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
Local aCT140BUT := {}
Local nX := 0
Local aRotina := {	{ STR0001,"AxPesqui", 0 , 1,,.F.},; //"Pesquisar"
	   					{ STR0002,"AxVisual", 0 , 2},; //"Visualizar"
						{ STR0003,"CTB140Inc", 0 , 3},; //"Incluir"
						{ STR0004,"CTB140Alt", 0 , 4},; //"Alterar"
						{ STR0005,"CTB140Exc", 0 , 5}} //"Excluir"

IF ExistBlock( "CT140BUT" )
	aCT140BUT := ExecBlock( "CT140BUT",.F.,.F.,aRotina)
	
	IF ValType(aCT140BUT) == "A" .AND. Len(aCT140BUT) > 0
		FOR nX := 1 to len(aCT140BUT)
			aAdd(aRotina,aCT140BUT[nX])
		NEXT
	ENDIF
ENDIF

Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ctb140Exc ³ Autor ³ Rodrigo Gimenes       ³ Data ³ 24.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exclusão de Moedas                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb140Exc(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias			                                  ³±±
±±³          ³ ExpN1 : Numero do Registro                                 ³±±
±±³          ³ ExpN2 : Opcao do Menu                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb140Exc(cAlias,nReg,nOpc,lNovaTela,oWndDetalhe)

Local aSaveArea		:= GetArea()
Local nOpca			:= 0

DEFAULT lNovaTela		:= .F.
DEFAULT oWndDetalhe	:= Nil

dbSelectArea("CTO")
CTO->(dbSetOrder(1))
dbSelectArea("CTE")
CTE->(dbSetOrder(1))

//Se existir o objeto da nova tela de cadastros
If Type("oWndDetalhe") == "O"
	aCoords	:= FWGetCoorsAbsolute(oWndDetalhe)
	aDim		:= {aCoords[2],aCoords[1],aCoords[2]+oWndDetalhe:nHeight,aCoords[1]+oWndDetalhe:nWidth}	
	//aDim := DLGinPANEL(oWndDetalhe)		
	//nOpca := AxInclui(cAlias,nReg,nOpc,,,,,,,,,,,,,.F.,oWndDetalhe,aDim,,.T.)

	nOpca := AxVisual(	"CTO"/*[cAlias]*/,; 			//[1]
							CTO->(Recno())/*[nReg]*/,;	//[2]
							2/*[nOpc]*/,;					//[3]
							/*[aAcho]*/,;					//[4]
							/*[nColMens]*/,;				//[5]
							/*[cMensagem]*/,;				//[6]
							/*[cFunc]*/,;					//[7]
							/*[aButtons]*/,;				//[8]
							/*[lMaximized]*/,;			//[9]
							/*[cTela]*/,;					//[10]
							/*[lPanel]*/.T.,;				//[11]
							/*[oFather]*/oWndDetalhe,;	//[12]
							/*[oEnc01]*/,;				//[13]
							/*[lCriaBut]*/.T.,;			//[14]
							/*[aDim]*/aDim,;				//[15]
							/*[cStack]*/,;				//[16]
							/*[aCpos]*/)					//[17]
					
	//nOpca := AxDeleta("CTO",CTO->(Recno()),5,,,,,,,,,.T.,/*oWndDetalhe*/,aDim, .F.)
	//AxVisual(cAlias,nReg,nOpc,aAcho,nColMens,cMensagem,cFunc,aButtons,lMaximized,cTela,;
	//				lPanelFin,oFather,oEnc01,lCriaBut,aDim,cStack,aCpos)
Else
	If aCabAuto = Nil
		nOpca := AxVisual(cAlias, nReg, nOpc)
	Else
		If nReg <> Nil
			CTO->(dbGoTo(nReg))
		EndIf
		nOpca	:= 1
	EndIf
Endif

If nOpca == 1    
	If CTE->(!dbSeek(xFilial("CTE")+CTO->CTO_MOEDA)) 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integra Protheus x TIN                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		Begin Transaction
		If FWHasEAI("CTBA140",.T.,,.T.)
			//Informado o quinto parâmetro "cFunName" para que o response message retorne corretamente para o adapter de moeda,
			//no caso da integração ser chamada pelo assistente de criação de calendário contábil ou ser chamada por outra rotina 
			FwIntegDef( 'CTBA140', , , , 'CTBA140' )
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integra Protheus x LEGAL DESK - SIGAPFS             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Grava na fila de sincronização se o parâmetro MV_JFSINC = '1' - SIGAPFS
		J170GRAVA("CTO", xFilial("CTO") + CTO->CTO_MOEDA, "5")
		
		CTO->(RecLock("CTO",.F.))
		CTO->(dbDelete())
		CTO->(MsUnLock())
		End Transaction
		If lNovaTela
			//Reordena(2,oTreeCad2,IMG_INCLUIR,cCabTMoeda)
			Ctba011AtMoe(nOpc)
		Endif
	Else
		Help(" ",1,"CTBA140EX")
	EndIf
EndIf

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CT140LinOK³ Autor ³ Leandro F. Dourado   ³ Data ³ 17.11.11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a linha da getdados                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct010LinOk()												   		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.  		                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct140LinOK()

Local lRet := .T.

If !aCols[n][Len(aHeader)+1]		
		If !MaCheckCols(aHeader,aCols,n)
			lRet := .F.
		EndIf
EndIf		

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ct140TudOK³ Autor ³ Leandro F. Dourado   ³ Data ³ 17.11.11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a getdados completa                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct010TudOk()			                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.  		                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ct140TudOK()

Local lRet		:= .T.
Local nZ		:= 0

aCols 	:= oGetD:aCols
aHeader:= oGetD:aHeader

For nZ := 1 to Len(aCols)
	n:= nZ
	If !Ct140LinOK()
		lRet := .F.
	Endif
Next nZ

Return lRet

//-------------------------------------
/*	Modelo do Browser
@author  	Leandro Ferreira Paulino
@version 	P10 R1.4
@build		7.00.101202A
@since 		17/08/2011
@return 	oModel Objeto do Modelo	 */
//-------------------------------------
Static Function ModelDef()
Local oModel 	:= Nil
Local oStruCTO	:= Nil
	
oStruCTO := FwFormStruct(1,"CTO")        

// Tira validação da estrutura
oStruCTO:SetProperty( '*'         , MODEL_FIELD_VALID, { || .T. } )   
oStruCTO:SetProperty( '*'         , MODEL_FIELD_WHEN,  NIL )             

oModel:= MpFormModel():New("CTBA140",/*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields("CTBA140_CTO",Nil,oStruCTO,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:SetDescription(STR0021) // Metodo XML
oModel:GetModel("CTBA140_CTO"):SetDescription('STR0021')// Metodo XML
oModel:SetPrimaryKey({"CTO_MOEDA"})

Return ( oModel )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IntegDef  ºAutor  ³ Marcelo C. Coutinho  º Data ³  16/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Mensagem Única															    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Mensagem Única                                            	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IntegDef( cXml, nType, cTypeMsg, cVersion )
	Local aRet := {}
	aRet:= CTBI140( cXml, nType, cTypeMsg, cVersion )
Return aRet
