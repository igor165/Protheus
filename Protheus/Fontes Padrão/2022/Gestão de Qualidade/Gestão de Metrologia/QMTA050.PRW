#include "QMTA050.CH"
#include "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMTA050  ³ Autor ³ Wanderley Goncalves Jr³ Data ³ 28/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Procedimentos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ BOPS     ³ 64260 ³Construcao de Filtros na MBrowse                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { {OemToAnsi(STR0001),"AxPesqui"  , 0 , 1,,.F.},;    // "Pesquisar"
					{OemToAnsi(STR0002),"AxVisual"  , 0 , 2},;    // "Visualizar"
					{OemToAnsi(STR0003),"A050IPro"  , 0 , 3},;    // "Incluir"
					{OemToAnsi(STR0004),"A050IPro"  , 0 , 4},;    // "Alterar"
					{OemToAnsi(STR0005),"qmt050dPro"  , 0 , 5, 3},; // "Excluir"
					{OemToAnsi(STR0020),"qmt050PrCal" , 0 , 6},;	//Procedimentos de Medicao
					{OemToAnsi(STR0021),"qmt050PrUtl" , 0 , 6},;	//Procedimentos de Utilizacao
					{OemToAnsi(STR0022),"qmt050PrAll" , 0 , 6},;	//Todos os Procedimentos 
					{OemToAnsi(STR0027),"qmt050VDoc" , 0 , 6},;	//Visual.Docto
					{OemToAnsi(STR0014),"A050Text"  , 0 , 6} }		// "Texto"


Return aRotina

Function QMTA050(uCodProc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis que determinam o tipo de Procedimento              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// uCodProc = C : Medicao
// uCodProc = U : Utilizacao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cEspecie := 'QMTA050 ' // Para gravacao de textos
Private axtextos := {}  // Vetor que contem os textos dos Topicos
Private cProced  := uCodProc
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Inclui registros no Bancos de Dados                   ³
//³    4 - Altera o registro corrente                            ³
//³    5 - Remove o registro corrente do Banco de Dados          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro       

If cProced == NIL
	MsgAlert(OemToAnsi(STR0017),OemToAnsi(STR0018)) //"N„o Ser  poss¡vel executar o programa. O arquivo Sigaqmt.MNU est  incompat¡vel. Informe o suporte t‚cnico Microsiga."###"Aten‡„o"
	Return .T.
EndIf

dbSelectar("QA5")
DbSetOrder(1)

If cProced == "C"
	cCadastro := OemtoAnsi(STR0006)  // "Procedimento Medicao"
ElseIf cProced == "U"
	cCadastro := OemtoAnsi(STR0007)  // "Procedimento Utiliza‡„o"
Endif

cFiltro := 'QA5_FILIAL == "'+xFilial("QA5")+'" .and. QA5_CODTAB == "'+cProced+'"'
Set Filter to &(cFiltro)
DbGotop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Sugere todos os procedimentos do banco de dados	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If QA5->(Eof())    
	MsgInfo(OemToAnsi(STR0043)+cCadastro+". "+OemToAnsi(STR0044)) //"Nao existe(m) registro(s) de " ### "O sistema ira apresentar todos os procedimentos cadastrados caso exista(m)."
	Set Filter to
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

mBrowse( 6, 1,22,75,"QA5")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retornar os index do sistema                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Filter to

Set Key VK_F12 To

Return .T.

/*/
antigo a050DPro
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³qmt050dPro³ Autor ³ Wanderley Goncalves Jr³ Data ³ 28/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Procedimentos - Delecao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ qmt050dPro(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function qmt050dPro(cAlias,nReg,nOpc)
Local nOpcA ,cCod //,aAC := { OemToAnsi(STR0011),OemToAnsi(STR0012) }  //"Abandona"###"Confirma"
Local cChave := ""
Local oDlg   
Local aPosObj := {}  
Local aObjects:= {}   
Local aInfo   := {}  
Local aSize   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define tamanho da tela                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize(, .F., 400 )
aObjects := {}
AAdd( aObjects, { 100, 600, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects )

If cProced == QA5->QA5_CODTAB
	
	While .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia para processamento dos Gets          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOpcA:=0
		dbSelectArea(cAlias)
		RecLock(cAlias,.F.)  
		
		DEFINE MSDIALOG oDlg TITLE cCadastro FROM  aSize[7],000 to aSize[6],aSize[5] OF GetWndDefault() PIXEL 
		oDlg:lMaximized:=.T.	 
		nOpcA := EnChoice( cAlias, nReg, nOpc, ,"AC",OemToAnsi(STR0010), , aPosObj[1])  //"Quanto a exclus„o?"
		nOpca := 1
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})
		
		dbSelectArea(cAlias)
		
		IF nOpcA == 2
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Antes de deletar verifica se e' utilizado em Produtos ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCod 		:= QA5->QA5_NORMA
			cChave 	:= QA5->QA5_CHAVE
			
			dbSelectArea('QM1')  // Familias de Instrumento
			If cProced == "C"
				DbSetOrder(2)		// Indice por Procedimento de Medicao
			ElseIf cProced == "U"
				DbSetOrder(3)		// Indice por Procedimento de Utilizacao
			EndIf
			dbSeek( xFilial()+cCod)
			dbSetOrder(1)
			if Found()
				HELP(" ",1,"A050DNORMA",,AllTrim(QM1->QM1_TIPO)+' - '+QM1->QM1_REVTIP,2,1)
				
				dbSelectArea(cAlias)
				Exit
			EndIf
			
			Begin Transaction
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apos passar por todas as verificacoes , deleta o registro    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cAlias)
			RecLock(cAlias,.F.,.T.)
			dbDelete()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancela o Texto do Topico no QA2      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("QA2") // Textos
			QA_DelTxt(cChave,cEspecie,,@axtextos)   // QAXFUN
			dbselectArea("QA5")
			DbSetOrder(1)
			End Transaction
		Else
			MsUnLock()
			
		EndIf
		
		Exit
	EndDo
Else
	MsgStop(STR0019,STR0018) //"O procedimento selecionado nao pertence a esse tipo"###"Aviso"
EndIf

dbSelectArea(cAlias)

Return(Nil)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A050IPro ³ Autor ³ Wanderley Gonalves Jr ³ Data ³ 28/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Procedimentos - Inc/Alt         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050IPro(ExpC1,ExpN1,ExpN2)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A050IPro(cAlias,nReg,nOpc,cProc)

Local aInfo    := {}
Local aObjects := {}
Local aPosObj  := {}
Local aSize    := {}
Local bCampo   :={|nCPO| Field(nCPO) }
Local cCadr    := ""
Local cDesc    := ""
Local cEmit    := ""
Local dDatav   := CtoD( '  /  /  ' )
Local lCont    := .f. // Se for inclusao ou alteracao do mesmo tipo de procedimento
Local nCntFor  := 0
Local nI       := 0
Local nOpcA    := 0
Local oSize    := NIL

DEFAULT cProc	:="C"
DEFAULT cProced := cProc


 
Private aTELA[0][0],aGETS[0]
Private lFRvPr  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define tamanho da tela                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize(, .F., 400 )
aObjects := {}
AAdd( aObjects, { 100, 600, .T., .T. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects )

oSize := FwDefSize():New()
oSize:AddObject( "TELA",  100, 100, .T., .T. ) // Totalmente dimensionavel
oSize:lProp := .T. // Pr	oporcional             
oSize:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
oSize:Process() // Dispara os calculos  


If Altera
	If cProced == QA5->QA5_CODTAB
		lCont := .t.
	EndIf
Else
	lCont := .t.
EndIf

If lCont
	If nOpc == 3
		For nI := 1 To FCount()
			cCampo := Eval( bCampo, nI )
			lInit  := .F.
			If ExistIni( cCampo )
				lInit := .T.
				M->&( cCampo ) := InitPad( GetSx3Cache(cCampo,"X3_RELACAO") )
				If ValType( M->&( cCampo ) ) = "C"
					M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo,"X3_TAMANHO") )
				EndIf
				If M->&( cCampo ) == Nil
					lInit := .F.
				EndIf
			EndIf
			If !lInit
				M->&( cCampo ) := FieldGet( nI )
				If ValType( M->&( cCampo ) ) = "C"
					M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
				ElseIf ValType( M->&( cCampo ) ) = "N"
					M->&( cCampo ) := 0
				ElseIf ValType( M->&( cCampo ) ) = "D"
					M->&( cCampo ) := CtoD( "  /  /  " )
				ElseIf ValType( M->&( cCampo ) ) = "L"
					M->&( cCampo ) := .f.
				EndIf
			Endif
	   	Next nI

		M->QA5_FILIAL:= xFilial("QA5")
	Else
		For nI := 1 To FCount()
			M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
		Next nI
	Endif

	While .T.
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia para processamento dos Gets          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOpcA:=0		
		Begin Transaction
		nCntFor := 1		
		If nOpc == 3  // Inclusao
			
			DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],000 to aSize[6],aSize[5] OF GetWndDefault() PIXEL 
			nOpcA := EnChoice( cAlias, nReg, nOpc, , , , , aPosObj[1], , , , , , , , .T. )			 
			lFRvPr := .T.
			oDlg:lMaximized:=.T.	
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
			{||nOpca:=1,if(Obrigatorio(aGets,aTela).and.QMT050PrCod(),oDlg:End(),nOpca := 0)},;
			{ || oDlg:End() }) CENTERED
			
			If nOpcA == 1   // Confirmou a inclusao
				QMT050GrProc(nOpc,.F.)
			Endif
		elseif nOpc == 4  // Alteracao
			DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],000 to aSize[6],aSize[5] OF GetWndDefault() PIXEL 
				oDlg:lMaximized:=.T.	
				nOpcA := EnChoice( cAlias, nReg, nOpc, , , , , aPosObj[1], , , , , , , , .T. )			
				// Guardo as variaveis que podem gerar Revisao
				cDesc  := M->QA5_DESCRI
				cEmit  := M->QA5_EMIT
				cCadr  := M->QA5_CADR
				dDatav := M->QA5_DATAV
    			//Verifica se existe revisao de documento novo...
    			dbSelectArea("QDH")
    			dbSetOrder(1)
    			If dbSeek(xFilial()+M->QA5_DOCTO)
    				If Val(QDH->QDH_DOCTO) > Val(M->QA5_DOCTO)
		   				//Verifica se documento esta cancelado, obsoleto e com status diferente de leitura
		   				If QDH->QDH_CANCEL <> "S" .AND. QDH->QDH_OBSOL <> "S" .AND. QDH->QDH_STATUS == "L  "
							If MsgYesNo(OemToAnsi(STR0029),OemToAnsi(STR0018)) //"Existe nova revisao de documento, deseja fazer nova revisao de procedimento?","Atencao"   					
								lFRvPr := .T.							
								M->QA5_REVPRO	:= Soma1(M->QA5_REVPRO)
								M->QA5_DATA		:= dDataBase       
							Endif
						Endif				
    				Endif
    			Endif     			
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
			{||nOpca:=4,if(Obrigatorio(aGets,aTela),oDlg:End(),nOpca := 0)},;
			{||oDlg:End() }) CENTERED
			If nOpca == 4
				If  !lFRvPr  .AND.;
				    QMT050vIns(M->QA5_NORMA, M->QA5_REVPRO, M->QA5_CODTAB) .AND.;    // Verifico se existem calibracoes para algums  instrumento que  tenha este  procedimento
				   (cDesc  <> M->QA5_DESCRI .OR.;  // Caso algum campo seja  alterado
				    cEmit  <> M->QA5_EMIT .OR.;  
					cCadr  <> M->QA5_CADR .OR.;
					dDatav <> M->QA5_DATAV)
					lFRvPr := .T.							
					M->QA5_REVPRO	:= Soma1(M->QA5_REVPRO)
					M->QA5_DATA		:= dDataBase
				EndIf
				QMT050GrProc(nOpc,lFRvPr)
			Endif
		endif
		End Transaction
		
		axtextos := {}       // Vetor que contem os textos dos Topicos
		Exit
	EndDo
Else
	MsgStop(STR0019,STR0018) //"O procedimento selecionado nao pertence a esse tipo"###"Aviso"
EndIf


dbSelectArea(cAlias)
return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMTA051  ³ Autor ³ Wanderley             ³ Data ³ 01.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa funcao QMTA050 como Procedimento de Utilizacao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA051                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMTA051
QMTA050("U")            // Chamar o programa montando o indice para Procedimento
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QMTA052  ³ Autor ³ Wanderley             ³ Data ³ 01.12.97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa funcao QMTA050 como Procedimento de Medicao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTA050                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QMTA052
QMTA050("C")            // Chamar o programa montando o indice para Procedimento
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A050Text ³ Autor ³ Wanderley             ³ Data ³ 04/12/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama funcao que edita texto do topico                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A050Text()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QmtA050 - E' chamada no X3_VALID do cpo. QA5_TEXTO  - SX3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A050Text(cAlias,nReg,nOpc)
Local cChave
Local cCabec
Local cTitulo := OemtoAnsi(STR0013)  // "Procedimento"
Local nTamlin := TamSX3("QA2_TEXTO")[1]
Local lTxtQa  := .T.	
Private lFRvPr := .F.
	
If cProced == QA5->QA5_CODTAB
	
	axtextos := {}  // Vetor que contem os textos
	
	If cProced=="C"
		cCabec := OemtoAnsi(STR0006)  // "Procedimento Medicao"
		cChave := xFilial("QA2")+'C' + QA5_NORMA + QA5_REVPRO
	ElseIf cProced=="U"
		cCabec := OemtoAnsi(STR0007)  // "Procedimento Utiliza‡„o"
		cChave := xFilial("QA2")+'U' + QA5_NORMA + QA5_REVPRO
	EndIf
	
	If !empty(QA5->QA5_CHAVE)
		cChave := QA5->QA5_CHAVE
	Else
		cChave := Qa_CvKey(cChave,"QA5",2)
		
		RecLock("QA5",.F.)
		QA5->QA5_CHAVE := cChave
	EndIf
	
	lTxtQa := QA_TEXTO(cChave,cEspecie,nTamlin,cTitulo,;
	alltrim(QA5_NORMA)+' - '+QA5_REVPRO,@axtextos,1,;
	cCABEC)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava Texto do Procedimento de Medicao no QA2         	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTxtQa
		QA_GrvTxt(cChave,cEspecie,1,@axtextos)  // QAXFUN
	Endif	
	dbselectArea("QM2")
Else
	MsgStop(STR0019,STR0018) //"O procedimento selecionado nao pertence a esse tipo"###"Aviso"
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt050PrCalºAutor  ³Denis Martins       º Data ³  05/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seleciona somente procedimentos de Medicao	               º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA050                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt050PrCal()
	MsgRun(OemToAnsi(STR0026),OemToAnsi(STR0023),{||Qmt050Filt('C')}) //"Selecionando Procedimetos de Medicao" ### "Aguarde..."
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt050PrCalºAutor  ³Denis Martins       º Data ³  05/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seleciona somente procedimentos de Medicao                   º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA050                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt050PrUtl()
	MsgRun(OemToAnsi(STR0025),OemToAnsi(STR0023),{||Qmt050Filt('U')}) //"Selecionando Procedimetos de Medicao" ### "Aguarde..."
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt050ProcsºAutor  ³Denis Martins       º Data ³  05/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Seleciona somente procedimentos de acordo com parametro pas- º±±
±±º          ³sado (C - Calib. / U - Utilizacao / A - Todos)               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA050                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt050PrAll()
	MsgRun(OemToAnsi(STR0024),OemToAnsi(STR0023),{||Qmt050Filt('A')}) //"Selecionando Todos os Procedimetos" ### "Aguarde..."
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Qmt050Filt ºAutor  ³Denis Martins       º Data ³  05/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza filtro de registros no Browse                        º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA050                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Qmt050Filt(cCalib)
Local  cFiltro := ""
Default cCalib:= "A"

Set Filter To
QA5->(dbGoTop())

If Alltrim(cCalib) == "A"
	cFiltro := "QA5->QA5_CODTAB == 'C' .or. QA5->QA5_CODTAB == 'U'" //"Todos os Procedimentos"
ElseIf Alltrim(cCalib) == "C"
	cFiltro := "QA5->QA5_CODTAB == 'C'" //"Procedimentos de Medicao"
ElseIf Alltrim(cCalib) == "U"
	cFiltro := "QA5->QA5_CODTAB == 'U'" //"Procedimentos de Utilizacao"
Endif

dbSelectArea("QA5")
dbSetorder(1)
Set Filter to &(cFiltro)
dbSeek(xFilial("QA5"))

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³qmt050VDocºAutor  ³Denis Martins       º Data ³  08/13/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualiza documento associado ao Procedimento de Medicao 	  º±±
±±º          ³(Word)                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA050                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function qmt050VDoc()

If !Empty(QA5->QA5_DOCTO)
	QDOVIEW( , QA5->QA5_DOCTO ) //Visualiza documento Word...
Else
	MsgInfo(STR0028) //"Nao existe documento associado a este procedimento"
Endif	

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT050GrProcºAutor  ³Denis Martins       º Data ³  09/29/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao responsavel pela gravacao dos procedimentos            º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA050                                                   	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT050GrProc(nOpc,lFRvPr)

Local bCampo     :={|nCPO| Field(nCPO) }
Local nCntFor    := 0
Local cProced    := QA5->QA5_CODTAB
Default lFRvPr   := .F.

Default cEspecie := ''
Default axtextos := {}

If nOpc == 3 .or. lFRvPr
	RecLock("QA5",.T.)
Else
	RecLock("QA5",.F.)
Endif

For nCntFor := 1 To FCount()
	If Alltrim(FieldName(nCntFor)) == "QA5_FILIAL"
		FieldPut(nCntFor, xFilial("QA5"))
	Else
		FieldPut(nCntFor, M->&(EVAL(bCampo,nCntFor)))
	EndIf
Next nCntFor	

If QA5->QA5_CODTAB <> ""
    QA5->QA5_CODTAB:=cProced
    If Alltrim(FunName()) <> "QMTA030"
        If IsInCallStack("QMTA051")
            QA5->QA5_CODTAB:="U"
        Else 
            QA5->QA5_CODTAB:="C"
        Endif
    EndIf
Endif

If IsInCallStack("AxInclui")
	cEspecie := 'QMTA050' 
	axtextos := {}
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava revisao invertida  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QA5->QA5_REVINV := Inverte(QA5->QA5_REVPRO)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Texto do Procedimento de Medicao no QA2         	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChave := QA5->QA5_FILIAL+QA5->QA5_CODTAB+QA5->QA5_NORMA+QA5->QA5_REVPRO
cChave := QA_CVKEY(cChave,"QA5",2)

QA_GrvTxt(cChave,cEspecie,1,@axtextos)   // QAXFUN
dbselectArea("QA5")
MsUnLock()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT050PrCodºAutor  ³Denis Martins       º Data ³  11/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe codigo do procedimento no arquivo QA5     º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA050                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT050PrCod()
Local lRet := .T.
Local cProced

If empty(cProced)
	cProced:=QA5->QA5_CODTAB
Endif

If QA5->QA5_CODTAB==" " .And. IsInCallStack("AxInclui")
	MsgStop(STR0045,STR0018) 
	lFecha := .T.
	oDlg:End()
	Return
EndIf

If !empty(cProced)
lRet := ExistChav("QA5",cProced+M->QA5_NORMA + Inverte(M->QA5_REVPRO))
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT050EmailºAutor  ³Denis Martins       º Data ³  02/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Envia e-mail de procedimento a vencer                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA050                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT050Email()
Local cHtml		:= " "
Local lFirst	:= .T.
Local aUsua		:= {}
Local aMsg		:= {}
Local cSubject	:= OemToAnsi(STR0042) //"Importante - Aviso de Procedimento de Medicao e/ou Utilizacao a vencer"
Local cNomeArq	:= SubStr(DtoS(dDataBase),5,7)+".Q50"
Local nDias		:= GETMV("MV_QQTDIAS")
Local cArqInd	:= ""
Local cChave	:= ""
Local cFiltro	:= ""
Local lEncont	:= .F.
Local nOpca		:= 0
Local oMtEmail		
Local cEmails   := ""
Local oGrp
Local lFecha	:= .F.
Local oEmail 
Local cNomMail 	:= CriaVar("QAA_EMAIL",.F.)
Local ni		:= 0
Private nHdl	:= 0
Private	TRB_TPPROC	:= ""
Private	TRB_NORMA	:= ""
Private	TRB_DATAV	:= ""
Private nBytesTxt	:= 0
Private nCurrent	:= 0
Private nTamTxt		:= 0 
Private nFilePosTxt	:= 0
Private cBufTxt		:= ""
Private lAchou		:= .F.
Private cTpMail		:= ""	
//Deleta arquivos anteriores - Vinte Arquivos anteriores
For ni := 1 to 20
	If File(SubStr(DtoS(dDataBase-ni),5,7)+".Q50")
		FErase(SubStr(DtoS(dDataBase-ni),5,7)+".Q50")
	Endif  
Next

//Cria arquivo com data
If File(cNomeArq)
	nHdl := FOpen( cNomeArq, FO_READWRITE+FO_SHARED ) 
Else	
	nHdl := FCreate( cNomeArq, FC_NORMAL ) 
Endif		

DbSelectArea("QA5")
DbSetOrder(1)            

//Lay-out do Cliente
//MV_QQTDIAS - Quantidade de dias a serem considerados no aviso do e-mail
//Ponto de Entrada para tratamento de lay-out de cliente...
If ExistBlock("QMT050Mai")
	ExecBlock("QMT050Mai",.F.,.F.,{QA5->QA5_CODTAB,QA5->QA5_NORMA,QA5->QA5_REVPRO})
Else

	cQuery := "SELECT QA5.QA5_FILIAL,QA5.QA5_CODTAB,QA5.QA5_NORMA,QA5.QA5_REVPRO,QA5.QA5_DATAV"
	cQuery += " FROM " + RetSqlName("QA5") +" QA5 "
	cQuery += " WHERE QA5.QA5_FILIAL = '"	+ xFilial("QA5") + "' AND "
	cQuery += " QA5.QA5_DATAV >= '" + DtoS(dDataBase-nDias) + "' AND " 
	cQuery += " QA5.QA5_DATAV <= '" + DtoS(dDataBase) + "' AND " 
	cQuery += " QA5.D_E_L_E_T_<>'*' "
	cQuery += " ORDER BY QA5.QA5_FILIAL,QA5.QA5_NORMA"			

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)

	TcSetField("TRB","QA5_DATAV","D",8,0)

	dbSelectArea("TRB")

	dbGoTop()
	
	If QA5->(!Eof())
		cEmails := CriaVar("QAA_MAT",.F.)
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0030) FROM 9,0 TO 25,50 OF oMainWnd //"Procedimentos

		@ 6,53 SAY OemToAnsi(STR0031) SIZE 189,8 COLOR CLR_HRED OF oDlg PIXEL	//"*** Envio de E-mail - Procedimento(s) ***"		
		@ 17,2	Group oGrp TO 49,197 LABEL OemToAnsi(STR0030) COLOR CLR_BLUE OF oDlg PIXEL	//Procedimentos
		@ 24,12 SAY OemToAnsi(STR0032) SIZE 189,8 OF oDlg PIXEL 
		@ 31,12 SAY OemToAnsi(STR0033) SIZE 189,8 OF oDlg PIXEL //"Por favor, informe o responsavel para envio de e-mail contendo tal(is) "
		@ 37,12 SAY OemToAnsi(STR0034) SIZE 200,8 OF oDlg PIXEL // procedimento(s)
		@ 51,2	Group oGrp TO 100,197 LABEL OemToAnsi(STR0035) COLOR CLR_BLUE OF oDlg PIXEL //"Responsavel"
		@ 70,7 SAY OemToAnsi(STR0035)+": " SIZE 52,8 OF oDlg PIXEL //Responsavel
		@ 70,44 MSGET oMtEmail VAR cEmails SIZE 52,8 OF oDlg PIXEL F3 "QAA"
		@ 71,97 SAY oEmail PROMPT cNomMail SIZE 200,8 COLOR CLR_BLUE OF oDlg PIXEL
		
		oMtEmail:bLostFocus := {|| If(!Empty(cEmails),(cNomMail := QMT050PeMail(@cEmails),oEmail:SetText(cNomMail),oEmail:Refresh()),.T.)}
		
		DEFINE SBUTTON FROM 104,123	TYPE 1 ENABLE OF oDlg PIXEL ACTION (nOpca := 1,lFecha := .T.,cNomMail := QMT050PeMail(@cEmails),oEmail:SetText(cNomMail),oEmail:Refresh(),If(!Empty(cNomMail),oDlg:End(),.F.))
		DEFINE SBUTTON FROM 104,158	TYPE 2 ENABLE OF oDlg PIXEL ACTION (nOpca := 2,lFecha := .T.,oDlg:End())
		
		ACTIVATE MSDIALOG oDlg VALID lFecha CENTERED 

	Endif

	If nOpca == 2
		Return .F.	 
    Endif         
	
	While !Eof()

	TRB_TPPROC	:= TRB->QA5_CODTAB
	TRB_NORMA	:= TRB->QA5_NORMA
	TRB_DATAV	:= TRB->QA5_DATAV
			
	If nHdl > 0
		nTamTxt := FSEEK( nHdl, 0, FS_END ) //Verifica o tamanho do arquivo
		FSEEK( nHdl, 0 ) //Seta o FSeek para inicio do arquivo 
       	
		nCurrent := 19 //Tamanho da Linha CodTab + Procedimento 
        	
		While( nCurrent <= nTamTxt )
			nFilePosTxt := FSEEK( nHdl, 0, FS_RELATIVE )
			cBufTxt     := FREADSTR( nHdl, nCurrent )
			nBytesTxt   := AT( TRB_TPPROC+TRB_NORMA, cBufTxt )				
	    	
			If nBytesTxt > 0
				lAchou	:= .T.
				Exit
			Else
				lAchou	:= .F.	
			Endif  	
			nCurrent += 19
			Loop
		Enddo
	Endif

	//Realiza Gravacao
	If !lAchou
		FWrite( nHdl, TRB_TPPROC+TRB_NORMA) 
		FWrite( nHdl, Chr(13)+Chr(10))				
    Endif
    
	If !lAchou
	If lFirst
		lEncont := .T.
		If Alltrim(cTpMail) == "1" //Se For HTML
			cHtml :='<html>'
			cHtml +='<head>' 
			cHtml +='<body>'
			cHtml +='<p></p>'					
			cHtml +='<table borderColor="#0099cc" height="29" cellSpacing="1" width="679" borderColorLight="#0099cc" border="1">'
			cHtml +='  <tr>'
			cHtml +='    <td borderColor="#0099cc" borderColorLight="#0099cc" align="left" width="640" bgColor="#0099cc" borderColorDark="#0099cc" height="1">'
			cHtml +='    <p align="center"><font face="Courier New" color="#ffffff" size="4"><b>'+OemToAnsi(STR0036)+'</b></font></td>' //"* * * Relacao de Procedimento(s) a ser(em) revisado(s) * * *"
			cHtml +='  </tr>'
			cHtml +='</table>' 
			cHtml +='<p align="center">&nbsp;</p>'
			
			cHtml +='<p align="justify"><font face="Arial">'+OemToAnsi(STR0037)+QAA->QAA_NOME+","+'</font></p>' //"Sr. "
			cHtml +='<p align="justify"><font face="Arial">'+OemToAnsi(STR0038)+'</font></p>' //"Segue relacao de procedimento(s) a ser(em) revisado(s)."
			cHtml +='<p align="justify">&nbsp;</p>'
			cHtml +='<table borderColor="#0099cc" height="29" cellSpacing="1" width="679" borderColorLight="#0099cc" border="1">'
			cHtml +='  <tr>'
			cHtml +='    <td width="333">'
			cHtml +='	    <p align="center"><b><i>'+OemToAnsi(STR0030)+'</i></b></td>' //"Procedimento(s)"
			cHtml +='    <td width="333">'
			cHtml +='	    <p align="center"><b><i>'+OemToAnsi(STR0039)+'</i></b></td>' //"Data de Validade"
			cHtml +='  </tr>'
			cHtml +='</table>'
			cHtml +='	<p align="center">&nbsp;</p>'
			cHtml +='	<table borderColor="#0099cc" height="29" cellSpacing="1" width="679" borderColorLight="#0099cc" border="1">'
			cHtml +='	  <tr>'
			cHtml +='    	<td width="333" align="center">'+TRB_NORMA+'</td>' 
			cHtml +='	    <td width="333" align="center">'+SubStr(DtoS(TRB_DATAV),7,2) + "/" +SubStr(DtoS(TRB_DATAV),5,2) + "/" + SubStr(DtoS(TRB_DATAV),1,4)+'</td>'
			cHtml +='	  </tr>'
			cHtml +='	</table>'
			lFirst := .F.
		Else
			cHtml :=OemToAnsi(STR0036)+Chr(13)+Chr(10)+Chr(13)+Chr(10)  //"* * * Relacao de Procedimento(s) a ser(em) revisado(s) * * *"
			cHtml +=OemToAnsi(STR0037)+QAA->QAA_NOME+","+Chr(13)+Chr(10) //"Sr." 
			cHtml +=OemToAnsi(STR0038)+Chr(13)+Chr(10)  //"Segue relacao de procedimento(s) a ser(em) revisado(s)."
			cHtml +=Chr(13)+Chr(10)
			cHtml +=Chr(13)+Chr(10)
			cHtml +=OemToAnsi(STR0030)+" - "+OemToAnsi(STR0039)+"..............."+Chr(13)+Chr(10) //"Procedimento(s) - Data de Validacao"
			cHtml +=TRB_PADRAO+".........."+SubStr(DtoS(TRB_DATAV),7,2) + "/" +SubStr(DtoS(TRB_DATAV),5,2) + "/" + SubStr(DtoS(TRB_DATAV),1,4)+Chr(13)+Chr(10)
			lFirst := .F.
		Endif
	Else
		If Alltrim(cTpMail) == "1" 
			cHtml +='<table borderColor="#0099cc" height="29" cellSpacing="1" width="679" borderColorLight="#0099cc" border="1">'
			cHtml +='	  <tr>'
			cHtml +='    	<td width="333" align="center">'+TRB_NORMA+'</td>' 
			cHtml +='	    <td width="333" align="center">'+SubStr(DtoS(TRB_DATAV),7,2) + "/" +SubStr(DtoS(TRB_DATAV),5,2) + "/" + SubStr(DtoS(TRB_DATAV),1,4)+'</td>'
			cHtml +='	  </tr>'
			cHtml +='	</table>'      
		Else
			cHtml +=TRB_NORMA+".........."+SubStr(DtoS(TRB_DATAV),7,2) + "/" +SubStr(DtoS(TRB_DATAV),5,2) + "/" + SubStr(DtoS(TRB_DATAV),1,4)+Chr(13)+Chr(10)			
		Endif
	Endif           
	Endif	

		dbSelectArea("TRB")			
		dbSkip()
	Enddo
	//Garante o ultimo registro...
	If Eof() .and. lEncont
		If Alltrim(cTpMail) == "1"
			cHtml +='</body>'
			cHtml +='</html>'
		Endif
		aMsg:= { { cSubject,cHtml, "" } }     		                                              
		aadd(aUsua,{ QAA->QAA_NOME,Trim(cNomMail),aMsg })
		QaEnvMail(aUsua,,,,)
		aUsua := {}
	Endif

	dbCloseArea()		
	dbSelectArea("QA5")				
	dbSetOrder(1)
Endif  

Return                
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT050PeMailºAutor  ³Denis Martins       º Data ³  07/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica/Retorna o e-mail do responsavel escolhido            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³Codigo do Usuario                                           	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QMTA050                                                   	º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT050PeMail(cEmails)

Local cNomMail := CriaVar("QAA_EMAIL",.f.)

dbSelectArea("QAA")
dbSetOrder(1)
If dbSeek(xFilial("QAA")+cEmails)
	If !Empty(QAA->QAA_EMAIL) //Se nao existir e-mail avisar usuario
		cNomMail:= Alltrim(QAA->QAA_EMAIL)
		cTpMail := QAA->QAA_TPMAIL
	Else
	    MessageDlg(OemToAnsi(STR0040),,3)	 //"Nao existe e-mail cadastrado para esse usuario"
        cNomMail := CriaVar("QAA_MAT",.F.)	
        Return Nil
	Endif	
Else
    MessageDlg(OemToAnsi(STR0041),,3) //"Usuario nao cadastrado..."
    cNomMail := CriaVar("QAA_MAT",.F.)	
	Return Nil    
Endif
Return cNomMail	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT050FaPr ºAutor  ³Denis Martins       º Data ³  11/12/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existe codigo do procedimento no arquivo QA5     º±±
±±º          ³FAMILIA                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QMTA050                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMT050FaPr()
Local lRet := .T.
dbSelectArea("QA5")
dbSetOrder(1)
If !dbSeek(xFilial("QA5")+"C"+M->QM1_PROCAL)
	lRet := .F.
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT050NRD  ºAutor  ³Cicero Cruz         º Data ³  02/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ira gerar uma nova revisao de procedimento quando uma  nova º±±
±±º          ³ revisao de um documento for gerada                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRACAO QDO                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                   
Function QMT050NRD ()
Local aCampos   := {}  // Array com os  campos a serem copiados  {Nome_Campo, Valor}
Local axtextos  := {}  // Array para o campo Memo
Local bCampo	:= {|nCPO| Field(nCPO) }
Local nCntFor	:= 0
Local cDescri   := ""
Local cChave    := "" 
Local cEspec := 'QMTA050 '


For nCntFor := 1 To FCount()
	If EVAL(bCampo,nCntFor) == "QA5_REVPRO"                 
		Aadd(aCampos, {EVAL(bCampo,nCntFor),Soma1(QA5->QA5_REVPRO)})
	ElseIf EVAL(bCampo,nCntFor) == "QA5_DATA"   
		Aadd(aCampos, {EVAL(bCampo,nCntFor),dDataBase})	
	Else
		Aadd(aCampos, {EVAL(bCampo,nCntFor),QA5->&(EVAL(bCampo,nCntFor))})
	EndIf
Next nCntFor	

cDescri := QA_Rectxt(QDH->QDH_CHAVE,cEspec) 
Q_MemoArray(cDescri, @axtextos, TamSx3("QA2_TEXTO")[1])

RecLock("QA5",.T.)

For nCntFor := 1 To len(aCampos)
	QA5->&(aCampos[nCntFor][1]) := aCampos[nCntFor][2]
Next nCntFor	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava revisao invertida  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QA5->QA5_REVINV := Inverte(QA5->QA5_REVPRO)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Texto do Procedimento de Medicao no QA2         	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChave := QA5->QA5_FILIAL+QA5->QA5_CODTAB+QA5->QA5_NORMA+QA5->QA5_REVPRO
cChave := QA_CVKEY(cChave,"QA5",2)

QA_GrvTxt(cChave,cEspec,1,@axtextos)   // QAXFUN
dbselectArea("QA5")
MsUnLock()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT050RevApºAutor  ³Cicero Cruz         º Data ³  02/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se e a ultima revisao do procedimento e se ela estaº±±
±±º          ³ apta para que uma nova revisao do procedimento seja gerada  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRACAO QDO                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                   
Function QMT050RevAp(cPro, cRev, cTipo, cDoc, cRevi)
Local lRet      := .T.  
Local aArea   	:= GetArea() 
Local cRevisao  := ""

DBSelectArea("QA5") 
DbSetOrder(1)

If QA5->(DbSeek(xFilial("QA5")+cTipo+cPro))
	cRevisao := QA5->QA5_REVPRO
EndIf           

If !(cRev == cRevisao)         
     lRet := .F. // Nao e a  Revisao atual
Else
	// Se a Revisao estiver apta verifico se ha calibracoes para no minimo uma das Familias     
	If !QMT050vIns(QA5->QA5_NORMA, QA5->QA5_REVPRO, QA5->QA5_CODTAB,cDoc, cRevi)
	     lRet := .F. // Nao ha calibracoes
	EndIf
EndIf

RestArea(aArea)
Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMT050vIns ºAutor  ³Cicero Cruz         º Data ³  02/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se para as Familias associadas ao Procedimento ha  º±±
±±º          ³ um instrumento com calibracao                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ INTEGRACAO QDO                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                   
Function QMT050vIns(cPro, cRev, cTipo,cDoc, cRevi)
Local lRet := .F.  // Indica a existecia de Calibracoes
Local cURQM1 := "" // Ultima Revisao da Familia                
Local   nW      := 0 // Indica se foi encontrada uma calibracao

DBSelectArea("QM1")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Localizo as Familias Associadas a Calibracao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo == "C"    
	DBSetOrder(2) // Procedimento de Medicao
	If DBSeek(xFilial("QM1")+QA5->QA5_NORMA)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifico para cada Familia se existem  instrumentos vigentes calibrados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !EOF() .and. xFilial("QA5")+QA5->QA5_NORMA == xFilial("QM1")+ QM1->QM1_PROCAL  .and. nW == 0         
		    cURQM1 := QMA030UltR(QM1->QM1_TIPO)
		    If QM1->QM1_REVTIP == cURQM1 .and. QMA050Cal(QM1->QM1_TIPO,QM1->QM1_REVTIP,cDoc, cRevi)
				lRet := .T.        
				nW++
			EndIf
			QM1->(DBSkip())
		End
	EndIf
ElseIf cTipo == "U"
	DBSetOrder(3) // Procedimento de Utilizacao
	If DBSeek(xFilial("QM1")+QA5->QA5_NORMA)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifico para cada Familia se existem  instrumentos vigentes calibrados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !EOF() .and. xFilial("QA5")+QA5->QA5_NORMA == xFilial("QM1")+ QM1->QM1_PROUTI .and. nW == 0
		    cURQM1 := QMA030UltR(QM1->QM1_TIPO)
		    If QM1->QM1_REVTIP == cURQM1 .and. QMA050Cal(QM1->QM1_TIPO,QM1->QM1_REVTIP, cDoc, cRevi,QA5->QA5_CODTAB)
				lRet := .T. 
				nW++
			EndIf
			QM1->(DBSkip())
		End
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QMA050Cal ³ Autora³ Iuri Seto             ³ Data ³ 14/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a rev da familia ja foi utilizada na calibracao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030									  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QMA050Cal (cTipo,cRevTip,cDoc,cRev,ctip)
Local  	lRet	:= .F.    // Indica a existencia de uma Calibração
Local 	cIndice := CriaTrab(NIL,.F.)  // Arquivo do Incice
Local 	cChave 	:= "QM6_FILIAL+QM6_TIPO+QM6_REVTIP"  // Chave  do Indice
Local 	cExpr	:= "QM6_FILIAL == '" + xFilial('QM6') + "' .And. QM6_TIPO == '" + cTipo + "' .And. QM6_REVTIP == '" + cRevTip + "'" //Condicao do Filtro
Local   nW      := 0 // Indica se foi encontrada uma calibracao
Local   nRec    := 0 // Indica o instrumento que esta  sendo  analisado

IndRegua("QM6",cIndice,cChave,,cExpr,,.F.)
nIndice := RetIndex("QM6")
dbSetOrder(nIndice+1)
dbGoTop()  

nW := 0

While !Eof() .and. xFilial('QM6')+QM6->QM6_TIPO+QM6->QM6_REVTIP == xFilial('QM6')+cTipo+cRevTip .and. nW == 0 .and. cTip == "C"
	If QM6->QM6_REVINS == QMA010UltR(QM6->QM6_INSTR)   // Verifico se e a Ultima  Revisão
		nRec := Recno() // Salvo o registro do instrumento atual
		If QMA010Cal(QM6->QM6_INSTR,QM6->QM6_REVINS)  // Verifico se a Ultima  Revisão  tem  Calibracoes
			dbgoto(nRec) // Volto para o instrumento que esta sendo analisado
			If cRev <> Nil
				If QM6->QM6_REVDOC == STRZERO((VAL(cRev)-1),3)  // So sera gerada uma revisao se um intrumento tiver utilizado o documento imediatemente anterior isso vai evitar muitas  revisoes ssem necessidade
					lRet := .T.						
					nW++    // Se acho uma calibracao apta posso sair  do While
				EndIf
			Else     // Alteracoes via Tela
				lRet := .T.						
				nW++    // Se acho uma calibracao apta posso sair  do While
			EndIf
		EndIf
	EndIf  
	DbSkip()  
End

dbSelectArea("QM6")
RetIndex("QM6")                      
Set Filter to
Ferase(cIndice + OrdBagExt())
QM7->(DbSetOrder(1))
QM7->(DbGoTop())

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³QMTRevPro ³ Autora³ Cintia B. Paul        ³ Data ³ 01/06/21 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ X3_VALID do campo QA5_REVPRO                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QMTA030									  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QMTRevPro()
Local lRet:=.T.

If IsInCallStack("AxInclui") 
	cProced:=QA5->QA5_CODTAB
EndIf

lRet := ExistChav("QA5",cProced+M->QA5_NORMA + Inverte(M->QA5_REVPRO)).and.FreeForUse("QA5",cProced+M->QA5_NORMA+Inverte(M->QA5_REVPRO))

Return

