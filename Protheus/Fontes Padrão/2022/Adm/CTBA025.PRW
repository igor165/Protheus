#INCLUDE "CTBA025.CH"
#INCLUDE "PROTHEUS.CH"

// 17/08/2009 -- Filial com mais de 2 caracteres

Static nContVer := 0 //controle de versão
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBA025  ³ Autor ³ Felipe Aurelio de Melo³ Data ³ 11/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastramento de Planos de contas de referencias - SIGACTB ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA025()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA025()

Local aCores := {		{ "( CVN_STAPLA == '2' .And. ( dDatabase > CVN_DTVIGI .AND. dDatabase < CVN_DTVIGF )" , "BR_PINK"    },; //"Revisão"
						{ "( !Empty( CVN_DTVIGI )   .AND. dDatabase < CVN_DTVIGI )" , "BR_AMARELO"  },; // Exercicio Não Iniciado
					   { "( !Empty( CVN_DTVIGF )   .AND. dDatabase > CVN_DTVIGF )" , "BR_VERMELHO" },; // Exercicio Finalizado
					   { "( dDatabase > CVN_DTVIGI .AND. dDatabase < CVN_DTVIGF )" , "BR_VERDE"    }} // REVISÃO

Private cAlias    := "CVN"
Private aRotina   := MenuDef(.T.)
Private cCadastro := STR0001  //"Plano Referencial"

Private lDefTop := .F.

SetKey(VK_F12,{|a,b|AcessaPerg("CTB025",.T.)})

Pergunte("CTB025",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowse := FWMBrowse():New()
DbSelectArea("CVN")
DbSetOrder(5)
oBrowse:SetAlias(cAlias)

oBrowse:SetDescription(STR0001) //"Plano Referencial"
oBrowse:AddLegend( "( CVN_STAPLA == '2' )", "BR_PINK" ,OemToAnsi(STR0062))//"Revisão"
oBrowse:AddLegend( "( !Empty( CVN_DTVIGI )   .AND. dDatabase < CVN_DTVIGI )", "BR_AMARELO", OemToAnsi(STR0010)) // Exercicio Não Iniciado
oBrowse:AddLegend( "( !Empty( CVN_DTVIGF )   .AND. dDatabase > CVN_DTVIGF )", "BR_VERMELHO",OemToAnsi(STR0011)) // Exercicio Finalizado
oBrowse:AddLegend( "( dDatabase >= CVN_DTVIGI .AND. dDatabase <= CVN_DTVIGF )", "BR_VERDE" , OemToAnsi(STR0012)) // Sem restrição

oBrowse:Activate()

SET KEY VK_F12 to

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Felipe Aurelio de Melo³ Data ³11/09/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±     
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com opcoes da rotina.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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
Static Function MenuDef(lTela)
Local aRotina2  := {{  OemToAnsi(STR0055),	"Ctb025IVer"	,0,1},;	// "Copiar"
						{ OemToAnsi(STR0056),	"Ctb025IVer"	,0,2},;	//"Importar"
						{ OemToAnsi(STR0057),	"Ctb025IVer"	,0,4}}	//"Manual"

Local aRotina := {;
                   { OemToAnsi(STR0002)   ,"AxPesqui"  ,0 , 1,,.F.},;//"Pesquisar"
                   { OemToAnsi(STR0003)   ,"Ctb025Pla" ,0 , 2},;//"Visualizar"
                   { OemToAnsi(STR0004)   ,"Ctb025Pla" ,0 , 3},;//"Incluir"
                   { OemToAnsi(STR0005)   ,"Ctb025Pla" ,0 , 4},;//"Alterar"
                   { OemToAnsi(STR0006)   ,"Ctb025Pla" ,0 , 5},;//"Excluir"
                   { OemToAnsi(STR0007)   ,"Ctb025Imp" ,0 , 3},;//"Imp.Plano.Ref."
                   { OemToAnsi(STR0008)   ,"Ctb025Exp" ,0 , 3},;//"Exp.Plano.Ref."
                   { OemToAnsi(STR0009)   ,"Ctb025Leg" ,0 , 6,,.F.};//"Legenda"
                  }

Default lTela := .F.

If lTela 
	aAdd(aRotina,{ OemToAnsi(STR0058)  ,aRotina2,0 , 7})//"Incluir Versão"
	aAdd(aRotina,{ OemToAnsi(STR0062)  ,"CTBA026",0 , 8})//"Revisão"
	aAdd(aRotina,{ OemToAnsi(STR0064)	,"CTBA026",0 , 9})//"Efetivar Revisão"
EndIf

Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTB025LEG    ³ Autor ³ Felipe A. Melo    ³ Data ³ 11/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a legenda referente ao status                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB025LEG()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb025Leg()

BrwLegenda(STR0009,STR0001,{;                                             //"Legenda"###"Plano Referencial"###
                                           { "BR_AMARELO"  , STR0010 },;  //"Exercicio Não Iniciado"
                                           { "BR_VERMELHO" , STR0011 },;  //"Exercicio Finalizado"
                                           { "BR_VERDE"    , STR0012 },;  //"Sem restrição"
                                           { "BR_PINK"    	, STR0062 }})  //"Revisão"

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB025PLA ³ Autor ³ Felipe Aurelio de Melo³ Data ³ 11.09.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Exibe na tela enchoice e a getdados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb025Pla(cAlias,nReg,nOpc)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA025                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do Registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb025Pla(cAlias,nReg,nOpc)
Local nTamLin       := Len(CVN->CVN_LINHA)

// Declaração das variaveis
Private oEnch
Private oDlg
Private oGDItens
Private aGets     := {} 
Private aTela     := {}
Private aButtons  := {}
Private nOpcao		:= 0
Private bOk       := { || IIf(Obrigatorio(aGets,aTela) .And. oGDItens:TudoOk() , (nOpcao:=1,oDlg:End()) , nOpcao := 0) }
Private bCancel   := { || nOpcao:=0 , oDlg:End() }
Private nSuperior := 0
Private nEsquerda := 0
Private nInferior := 0
Private nDireita  := 0
Private aSizeAut  := {}
Private aObjects  := {}
Private aInfo     := {}
Private aPosGet   := {}
Private aPosObj   := {}
Private aCT1Blq	:= {}

nReg   := IIf(nOpc==3,Nil,CVN->(Recno()))
cAlias := "CVN"

// Maximizacao da tela em relação a area de trabalho
aSizeAut := MsAdvSize()
aAdd(aObjects,{100,060,.T.,.F.})
aAdd(aObjects,{100,080,.T.,.T.})

aInfo     := {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],3,3}
aPosObj   := MsObjSize(aInfo,aObjects)

// Verifica o tipo de chamada e trata a situação
cNaoExbCps := "CVN_LINHA/CVN_CTAREF/CVN_DSCCTA/CVN_TPUTIL/CVN_CLASSE/CVN_CTASUP/CVN_CTAREL/CVN_CLASSE, CVN_NATCTA,CVN_CTASUP" //"CVN_CODPLA/CVN_DSCPLA/CVN_DTVIGI/CVN_DTVIGF/CVN_ENTREF"

Do Case
	Case nOpc == 2	//Visualização
		nOpEnch:= 2
		aExbCpo:= fInitVarX3(cAlias,.F.,cNaoExbCps)
		
	Case nOpc == 3	//Inclusão
		nOpEnch:= 3
		aExbCpo:= fInitVarX3(cAlias,.T.,cNaoExbCps)
		
	Case nOpc == 4	//Alteração
		nOpEnch:= 3
		If !Empty(CVN->CVN_LINHA) .And. Len(Alltrim(CVN->CVN_LINHA)) < nTamLin
			If Aviso(STR0065, STR0066, {STR0053, STR0054}, 2) == 1  //"Atenção"##"O campo linha do plano de contas referencial está com tamanho menor do que o definido no dicionario de dados. Deseja ajusta-lo para mesmo tamanho do dicionario ? "##"Sim"##"Nao"
				FWMsgRun(, {|oSay| Ctba025Ajt(oSay) }, STR0067, STR0068)  //"Processando"##"Processando a rotina para ajuste campo Linha da grid."
			EndIf
		EndIf
		aExbCpo:= fInitVarX3(cAlias,.F.,cNaoExbCps)
		
	Case nOpc == 5	//Exclusão
		nOpEnch:= 5
		aExbCpo:= fInitVarX3(cAlias,.F.,cNaoExbCps)
		
	Otherwise //Outras situações
		nOpEnch:= 2
		aExbCpo:= fInitVarX3(cAlias,.F.,cNaoExbCps)
EndCase

//Ajuste para incluir versão manual 
If FWIsInCallStack("Ctb025IVer") 
	M->CVN_CODPLA := CVN->CVN_CODPLA
	M->CVN_DSCPLA := CVN->CVN_DSCPLA 
	M->CVN_DTVIGI := CVN->CVN_DTVIGI
	M->CVN_DTVIGF := CVN->CVN_DTVIGF
	M->CVN_ENTREF	:= CVN->CVN_ENTREF
	M->CVN_VERSAO := NumVersao(CVN->CVN_CODPLA)//Traz a proxima versao
	M->CVN_STAPLA := Iif(M->CVN_VERSAO == "0001","1","2" )
EndIf

// Montagem da tela que serah apresentada para usuario (lay-out)
Define MsDialog oDlg Title cCadastro From aSizeAut[7],0 To aSizeAut[6],aSizeAut[5] Of oMainWnd Pixel

/*Cabeçalho		*/	oEnch := Msmget():New(cAlias,nReg,nOpEnch,,,,aExbCpo,aPosObj[1],aExbCpo,,,,,oDlg,,.T.)
/*Itens			*/ fGDItens(nOpc,oDlg,nReg)

Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

Do Case
   //Se for inclusao e foi confirmado
   Case nOpc == 3 .And. nOpcao == 1
        fSalvaTudo(nOpc,cAlias,aExbCpo,nReg)
        //Ajuste para incluir versão manual

   //Se for alteracao e foi confirmado
   Case nOpc == 4 .And. nOpcao == 1
        fSalvaTudo(nOpc,cAlias,aExbCpo,nReg)

   //Se for exclusao e foi confirmado
   Case nOpc == 5 .And. nOpcao == 1
        fExcluiTudo()
EndCase

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fGDItens     ³ Autor ³ Felipe A. Melo    ³ Data ³ 11/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta MsNewGetDados                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGDItens()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fGDItens(nOpc,oDefTela,nReg)

// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local cGetOpc        := Iif(Altera .OR. Inclui, GD_INSERT+GD_DELETE+GD_UPDATE, 0)    // GD_INSERT+GD_DELETE+GD_UPDATE  
Local cLinhaOk       := "Ctb025LOk"                      // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk        := "Ctb025TOk"                      // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos       := "+CVN_LINHA"                     // Nome dos campos do tipo caracter que utilizarao incremento automatico.                                                              
Local nFreeze        := Nil                              // Campos estaticos na GetDados.                                                               
Local nMax           := 9999                             // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cCampoOk       := "Ctb025COk"                      // Funcao executada na validacao do campo                                           
Local cSuperApagar   := Nil                              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cApagaOk       := "Ctb025Del"                      // Funcao executada para validar a exclusao de uma linha do aCols                   
Local aHead          := {}                               // Array do aHeader
Local aCols          := {}                               // Array do aCols

// Valor das variaveis que as rotinas faCols e faHead irá utilizar como referencia
Local x       := 1                                       //Variavel usada no For/Next
Local cGetAls := "CVN"                                   //Alias usado na função para montar o aHeader e o Acols
Local nGetOpc := nOpc                                    //Opção da operação que está sendo executada
Local cGetOrd := 5                                       //Ordem do Indice utilizado na função que carrega o aCols
Local nGetQtd := 1                                       //Quantidade de linhas iniciadas no aCols quando inclusão
Local cGetCnd := "xFilial('CVN')+M->CVN_CODPLA+M->CVN_VERSAO"          //
Local cGetCpo := "CVN->CVN_FILIAL+CVN->CVN_CODPLA+CVN->CVN_VERSAO"       //
Local cExbCpo := "CVN_LINHA/CVN_CTAREF/CVN_DSCCTA/CVN_TPUTIL/CVN_CLASSE/CVN_CTASUP/CVN_NATCTA"       //Forçar mostrar no MsNewGetDados apenas os campos definidos nesta variavel
Local aTrtCpo := {}                                      //Array contendo campos com valores que serão usadas no aCols quando inclusão
Local aArea := GetArea()

//A quantidade máxima de linha conforme o tamanho do campo CVN_LINHA
nMax := Val(Replicate("9",TamSx3("CVN_LINHA")[1]))           

//Montando um array conforme parametros acima para ser usada na função que montas o aCols
For x:=1 To nGetQtd
    aAdd(aTrtCpo,{"CVN_LINHA",StrZero(x,Len(CriaVar("CVN_LINHA"))),.F.})
Next x

//Execução das rotinas
aHead := faHead(cGetAls,cExbCpo)
aCols := faCols(aHead,cGetAls,nGetQtd,nGetOpc,cGetOrd,cGetCnd,cGetCpo,cExbCpo,aTrtCpo)
oGDItens := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],cGetOpc,cLinhaOk,cTudoOk,cIniCpos,,nFreeze,nMax,cCampoOk,cSuperApagar,cApagaOk,oDefTela,aHead,aCols)                                   

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fInitVarX3   ³ Autor ³ Felipe A. Melo    ³ Data ³ 11/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega as variaveis em memoria                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fInitVarX3()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fInitVarX3(cAlias,lInitVarX3,cNaoExbCps)

Local aExibLst := {}

SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
	If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
		If Empty(cNaoExbCps) .Or. !(AllTrim(SX3->X3_CAMPO) $ cNaoExbCps)
			If lInitVarX3
				_SetOwnerPrvt(Trim(SX3->X3_CAMPO),CriaVar(Trim(SX3->X3_CAMPO),.T.))
			Else
				If SX3->X3_CONTEXT != "V"
					_SetOwnerPrvt(Trim(SX3->X3_CAMPO),&(SX3->X3_CAMPO))
				Else
					_SetOwnerPrvt(Trim(SX3->X3_CAMPO),&(SX3->X3_RELACAO))
				EndIf
			EndIf
			AADD(aExibLst,SX3->X3_CAMPO)
		EndIf
	EndIf
	SX3->(DbSkip())
End

Return(aExibLst)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ faHead       ³ Autor ³ Felipe A. Melo    ³ Data ³ 11/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega aHeader usado no MsNewGetDados                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ faHead()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function faHead(cAlias,cExibeCpos)

Local aHead := {}

// Montagem do aHeader
SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
	If (X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL)
		If Empty(cExibeCpos) .Or. AllTrim(SX3->X3_CAMPO) $ cExibeCpos
			aAdd(aHead, { AllTrim(X3Titulo()),;
                        SX3->X3_CAMPO,;
                        SX3->X3_PICTURE,;
                        SX3->X3_TAMANHO,;
                        SX3->X3_DECIMAL,;
                        SX3->X3_VALID,;
                        SX3->X3_USADO,;
                        SX3->X3_TIPO,;
                        SX3->X3_F3,;
                        SX3->X3_CONTEXT,;
                        SX3->X3_CBOX,;
                        SX3->X3_RELACAO,;
                        SX3->X3_WHEN,;
                        SX3->X3_VISUAL,;
                        SX3->X3_VLDUSER,;
                        SX3->X3_PICTVAR,;
                        SX3->X3_OBRIGAT})
		EndIf
	EndIf
	SX3->(DbSkip())
End

Return(aHead)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ faCols       ³ Autor ³ Felipe A. Melo    ³ Data ³ 11/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega aCols usado no MsNewGetDados                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ faCols()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function faCols(aHead,cGetAls,nGetQtd,nGetOpc,cGetOrd,cGetCnd,cGetCpo,cExbCpo,aTrtCpo)

Local lFoiTratado := .F.
Local lFirstAlt		:= .F.

Local aCol        	:= {}
Local y         	:= 1
Local k        	  	:= 1

Local cMsgAtu		:= ""

If nGetOpc == 3
	// Montagem do aCols em Branco
	For y := 1 To nGetQtd
		AADD(aCol,Array(Len(aHead)+1))
		nLin	:= Len(aCol)
		//Sempre reposicionar a set para o alias correto
		SX3->(DbSetOrder(1))
		SX3->(DbSeek(cGetAls))
		While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cGetAls
			If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
				//Faz tratamento para montagem do acols somente com campos especificos ou com todos habilitados via sigacfg
				If Empty(cExbCpo) .Or. AllTrim(SX3->X3_CAMPO) $ cExbCpo
					//Faz tratamento de campos especificas caso seja necessario
					lFoiTratado := .F.
					For k := 1 To Len(aTrtCpo)
						If aTrtCpo[k,1] $ SX3->X3_CAMPO .And. !aTrtCpo[k,3]
							aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==AllTrim(SX3->X3_CAMPO)})] := aTrtCpo[k,2]
							aTrtCpo[k,3] := .T.
							lFoiTratado := .T.
							k := Len(aTrtCpo)
						EndIf
					Next k
					//Caso não seja um tratamento especifico seguirá o padrão
					If !lFoiTratado
						If Empty(SX3->X3_RELACAO)
							aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==AllTrim(SX3->X3_CAMPO)})] := CriaVar(SX3->X3_CAMPO)
						Else
							aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==AllTrim(SX3->X3_CAMPO)})] := &(SX3->X3_RELACAO)
						EndIf
					EndIf
				EndIf
			EndIf
			SX3->(DbSkip())
		End
		aCol[nLin,Len(aHead)+1] := .F.
	Next y
Else
	// Montagem do aCols com registros caso tenha
	DbSelectArea(cGetAls)
	DbSetOrder(cGetOrd)
	If DbSeek(&(cGetCnd))
		While !EOF() .And. &(cGetCnd) == &(cGetCpo)
			
			aAdd(aCol,Array(Len(aHead)+1))
			nLin	:= Len(aCol)
			
			SX3->(DbSetOrder(1))
			SX3->(DbSeek(cGetAls))
			While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cGetAls
				If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
					//Faz tratamento para montagem do acols somente com campos especificos ou com todos habilitados via sigacfg
					If Empty(cExbCpo) .Or. AllTrim(SX3->X3_CAMPO) $ cExbCpo
						aCol[nLin,aScan(aHead,{|x|Alltrim(x[2])==AllTrim(SX3->X3_CAMPO)})] := &(SX3->X3_CAMPO)
					EndIf
				EndIf
				SX3->(DbSkip())
			End
			
			aCol[nLin,Len(aHead)+1] := .F.
			DbSkip()
		End
	EndIf
	
	If nGetOpc == 4 
		//Verifica se é primeira alteração após a criação do campo de versão do plano referencial
		lFirstAlt	:= FirstAlt()
		
		If lFirstAlt
			cMsgAtu := STR0049 //"Atualiza Conta Superior? "
			If SimNao(cMsgAtu) == "S"
				aCol	:= fAtuCtaSup(aHead,aCol)
				aCol	:= fAtuClasse(aHead,aCol)
			Endif		
		Endif
	
	EndIf
EndIf

Return(aCol)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fSalvaTudo   ³ Autor ³ Felipe A. Melo    ³ Data ³ 12/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel pela gravacao das inclusoes e alteracoes³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fSalvaTudo()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fSalvaTudo(nOpc,cAlias,aExbCpo)

// Declara variaveis
Local x        := 1
Local nOrdSeek := 5
Local aGrvCps  := {}
Local cCpoItem := "CVN_LINHA"
Local cCndSeek := "xFilial('CVN')+M->CVN_CODPLA+M->CVN_VERSAO" 
Local cStaPla	 := "'1'"
//Trata campos do enchoice
For x:=1 To Len(aExbCpo)
    aAdd(aGrvCps,{aExbCpo[x] ,"M->"+aExbCpo[x]	})
Next x

//Ajuste para incluir versão manual 
If FWIsInCallStack("Ctb025IVer")
	cStaPla := "'2'"
ElseIf ALTERA .And. (CVN->CVN_STAPLA == "2") 
	cStaPla := "'2'"
EndIf

//Trata campos extras
aAdd(aGrvCps,{"CVN_FILIAL"   ,"xFilial('CVN')"   })
aAdd(aGrvCps,{"CVN_LINHA"    ,"cCodItem"         })
aAdd(aGrvCps,{"CVN_STAPLA"   ,cStaPla         })

//Atualiza a linha da getdados por cod. conta ref. ou cod. conta superior, conforme definido pelo usuário.
fAtuLinha(oGdItens)

//Executa rotina pra tratar gravação das variaveis acima e do MsNewGetDados
fGravaGD(oGDItens,cAlias,aGrvCps,nOpc,nOrdSeek,cCndSeek,cCpoItem)

//Executa procedimento de bloqueio dos planos de contas
If Len(aCT1Blq) > 0
	For x:=1 To Len(aCT1Blq)
		CT1->(DbGoTo(aCT1Blq[X]))
		RecLock("CT1",.F.)
		CT1->CT1_BLOQ := "1" //Conta Bloqueada
		CT1->(MsUnLock())
	Next x
EndIf


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fGravaGD     ³ Autor ³ Felipe A. Melo    ³ Data ³ 12/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel pela gravacao das inclusoes e alteracoes³±±
±±³          ³ apontadas no MsNewGetDados / tratamento por objeto         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGravaGD()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fGravaGD(oObjct,cAlias,aCposAdd,nTpOper,nOrdSeek,cCndSeek,cCpoItm)

Local x := 1
Local y := 1
Local k := 1
Private cCodItem := StrZero(1,Len(CriaVar(cCpoItm)))

DbSelectArea(cAlias)

For x:=1 To Len(oObjct:aCols)
	If !oObjct:aCols[x,Len(oObjct:aHeader)+1]
		
		DbSelectArea(cAlias)
		DbSetOrder(nOrdSeek)
		
		If nTpOper == 3
			RecLock(cAlias,.T.)
		ElseIf DbSeek(&(cCndSeek)+oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==cCpoItm})])
			RecLock(cAlias,.F.)
		Else
			RecLock(cAlias,.T.)
		EndIf
		
		For y:=1 To Len(oObjct:aHeader)
			&(oObjct:aHeader[y,2]) := oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==AllTrim(oObjct:aHeader[y,2])})]
		Next y
		
		For k:=1 To Len(aCposAdd)
			&(aCposAdd[k,1]) := &(aCposAdd[k,2])
		Next k
		
		cCodItem := Soma1(cCodItem)
		MsUnLock()
	Else
		DbSelectArea(cAlias)
		DbSetOrder(nOrdSeek)
		If nTpOper != 3
			If DbSeek(&(cCndSeek)+oObjct:aCols[x][aScan(oObjct:aHeader,{|x|Alltrim(x[2])==cCpoItm})])
				RecLock(cAlias,.F.)
				dbDelete()
				MsUnLock()
			EndIf
		EndIf
	EndIf
Next x

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fExcluiTudo  ³ Autor ³ Felipe A. Melo    ³ Data ³ 12/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao responsavel pela exclusão de todos os itens         ³±±
±±³          ³ apresentados na tela                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGravaGD()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fExcluiTudo()

Local cCodPla		:= ""
Local cQry			:= ""
Local cAliasCVN	:= GetNextAlias()
Local aArea		:= GetArea()
Local aAreaCVN	:= CVN->(GetArea())
Local aAreaCVD	:= CVD->(GetArea())
Local cVersao		:= ""
Local nBloqCT1	:= 0

nBloqCT1 := Aviso(STR0013,STR0014+STR0015+CRLF+STR0016,{STR0053,STR0054}) //"Confirma exclusão?"##"Os planos de contas relacionados com os"##" itens que estão sendo excluídos serão "##"bloqueados."##"OK"##"CANCELA"

//Executa procedimento de exclusão de registros
CVN->(DbSetOrder(5)) //CVN_FILIAL+CVN_CODPLA+CVN_VERSAO+CVN_LINHA 
cCodPla	:= M->CVN_CODPLA 
cVersao	:= M->CVN_VERSAO
	
//pega a ultima versao
cQry := "SELECT MAX( CVN_VERSAO ) VERSAO " +CRLF
cQry += " FROM " + RetSqlname( "CVN" ) + " CVN"+CRLF
cQry += "WHERE CVN_FILIAL = '"+xFilial("CVN")+"' "+CRLF
cQry += "AND CVN_CODPLA = '"+ cCodPla+"'" +CRLF
cQry += "AND CVN_STAPLA = '3'"+CRLF
cQry += " AND CVN.D_E_L_E_T_ = ' '"+CRLF
	
cQry := ChangeQuery( cQry )	

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasCVN)	
	                                                                                                                 
If CVN->(DbSeek(xFilial('CVN')+M->CVN_CODPLA+M->CVN_VERSAO))
	While CVN->(!Eof()) .And. xFilial('CVN')+M->CVN_CODPLA+M->CVN_VERSAO == CVN->(CVN_FILIAL+CVN_CODPLA+CVN_VERSAO)
			
		//Bloqueia contas contabeis quando exclusão de registros usandos
		If nBloqCT1 == 1
			CVD->(DbSetOrder(2))
			If CVD->(DbSeek(xFilial("CVD")+CVN->(CVN_CODPLA+CVN_CTAREF)))
				CT1->(DbSetOrder(1))
				If CT1->(DbSeek(xFilial("CT1")+CVD->CVD_CONTA))
					RecLock("CT1",.F.)
					CT1->CT1_BLOQ := "1" //Conta Bloqueada
					CT1->(MsUnLock())
				EndIf
			EndIf
		EndIF
			
		RecLock("CVN",.F.)
		dbDelete()
		MsUnLock()
			
			
		//Limpa registro na CVD quando o plano for excluido
		CVD->(dbSetOrder(5)) //CVD_FILIAL+CVD_CODPLA+CVD_CTAREF+CVD_VERSAO+CVD_CONTA        
		If CVD->(dbSeek(xFilial("CVD")+CVN->CVN_CODPLA+CVN->CVN_CTAREF+cVersao))
			RecLock("CVD",.F.)
			dbDelete()
			CVD->(MsUnLock())
		EndIf
			
		CVN->(DbSkip())
	End



	//Ativa a ultima versão do plano de contas
	If (cAliasCVN)->(!Eof()) .And.  CVN->(DbSeek(xFilial('CVN')+cCodPla+(cAliasCVN)->VERSAO))
		While CVN->(!Eof()) .And. xFilial('CVN')+cCodPla+(cAliasCVN)->VERSAO == CVN->(CVN_FILIAL+CVN_CODPLA+CVN_VERSAO)
			RecLock("CVN",.F.)
			CVN->CVN_STAPLA	:= "1" // Ativa
			CVN->(MsUnLock())
			CVN->(DbSkip())
		End
	EndIf
				
			
EndIf

RestArea(aAreaCVD)
RestArea(aAreaCVN)
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ctb025TOk    ³ Autor ³ Felipe A. Melo    ³ Data ³ 15/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida todos os campos do MsNewGetDados de todas as linhas ³±±
±±³          ³ para obrigar preenchimento dos campos obrigatorio.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb025TOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ctb025TOk()

Local nGDLin := 1
Local nGDCol := 1
Local lRet := .T.

//Valida campos obrigatorios do MsNewGetDados
For nGDLin:=1 To Len(oGDItens:aCols)
	For nGDCol:=1 To Len(oGDItens:aHeader)
		If X3OBRIGAT(oGDItens:aHeader[nGDCol,2]) .And. Empty(oGDItens:aCols[nGDLin,nGDCol])
			lRet := .F.
			Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(oGDItens:aHeader[nGDCol,2])),3,1)
			nGDLin:=Len(oGDItens:aCols)
			nGDCol:=Len(oGDItens:aHeader)
		EndIf
	Next nGDCol
Next nGDLin

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ctb025LOk    ³ Autor ³ Felipe A. Melo    ³ Data ³ 15/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida linhas do MsNewGetDados para obrigar preenchimento  ³±±
±±³          ³ dos campos obrigatorio.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb025LOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ctb025LOk()

Local nGDLin := oGDItens:oBrowse:nAt
Local nGDCol := 1
Local lRet := .T.

//Valida campos obrigatorios do MsNewGetDados
For nGDCol:=1 To Len(oGDItens:aHeader)
	If X3OBRIGAT(oGDItens:aHeader[nGDCol,2]) .And. Empty(oGDItens:aCols[nGDLin,nGDCol])
		lRet := .F.
		Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(oGDItens:aHeader[nGDCol,2])),3,1)
		nGDCol:=Len(oGDItens:aHeader)
	EndIf
Next nGDCol

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ctb025COk    ³ Autor ³ Felipe A. Melo    ³ Data ³ 15/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida campos do MsNewGetDados para proibir duplicidades   ³±±
±±³          ³ e tratar alteração do codigo digitado que já foi utilizado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb025LOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ctb025COk()

Local nGDLin := oGDItens:oBrowse:nAt
Local nGDCol := oGDItens:oBrowse:ColPos
Local cGDCpo := &("M->"+oGDItens:aHeader[nGDCol,2])
Local cVCpos := "CVN_LINHA/CVN_CTAREF"
Local nConta := 1
Local lRet := .T.

//Trava alteração caso arquivo deletado
If oGDItens:aCols[nGDLin,Len(oGDItens:aHeader)+1] .And. lRet
	lRet := .F.
	Help(" ",1,"HELP",STR0019,STR0020+STR0021,3,1) //"PROIBIDO"##"Favor restaurar linha excluída para "##"depois alterar."
Endif

//Valida duplicidade de alguns campos do MsNewGetDados
//conforme definido acima na variavel cVCpos
If AllTrim(oGDItens:aHeader[nGDCol,2]) $ cVCpos .And. lRet
	For nConta:=1 To Len(oGDItens:aCols)
		If nConta != nGDLin
			If AllTrim(cGDCpo) == AllTrim(oGDItens:aCols[nConta,nGDCol])
				lRet := .F.
				Help(" ",1,"EXISTE",,STR0022+STR0023,3,1) //"Já existe um registro com esta "##"informação!"
				nConta := Len(oGDItens:aCols)
			EndIf
		EndIf
	Next nConta
EndIf

//Realiza tratamento quando registro foi alterado
If AllTrim(oGDItens:aHeader[nGDCol,2]) == "CVN_CTAREF" .And. lRet
	If !Empty(oGDItens:aCols[oGDItens:oBrowse:nAt,nGDCol])
		//Executa função que verifica se existe registro em uso deste plano+conta referencial
		lRet := CtaJaUsada(oGDItens:oBrowse:nAt,1)
	EndIf
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ctb025Del    ³ Autor ³ Felipe A. Melo    ³ Data ³ 15/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida exclusão de linhas do MsNewGetDados para verificar  ³±±
±±³          ³ se já foi utilizada em alguma outra rotina                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb025Del()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ctb025Del()

Local lRet := CtaJaUsada(oGDItens:oBrowse:nAt,2)

Return(lRet)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CtaJaUsada   ³ Autor ³ Felipe A. Melo    ³ Data ³ 16/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida exclusão de linhas do MsNewGetDados para verificar  ³±±
±±³          ³ se já foi utilizada em alguma outra rotina                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtaJaUsada()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CtaJaUsada(nGDLin,nChamada)

Local nGDCol  := aScan(oGDItens:aHeader,{|x|Alltrim(x[2])=="CVN_CTAREF"})
Local cCodPla := M->CVN_CODPLA
Local cVersao	:= M->CVN_VERSAO
Local cCodCta := oGDItens:aCols[nGDLin,nGDCol]
Local cMsgAlt := ""
Local lRet := .T.

//Desconsidera quando alterado para o mesmo valor
If nChamada = 1
	If cCodCta == M->CVN_CTAREF
		Return(.T.)
	EndIf
EndIf

//Verifica se existe registro em uso deste plano+conta referencial
CVD->(DbSetOrder(5))//CVD_FILIAL+CVD_CODPLA+CVD_CTAREF+CVD_VERSAO+CVD_CONTA
If CVD->(DbSeek(xFilial("CVD")+cCodPla+cCodCta+cVersao))
	If !oGDItens:aCols[nGDLin,Len(oGDItens:aHeader)+1]
		cMsgAlt := STR0024+STR0025+Chr(10)+Chr(13)+STR0026  //"Existe um ou mais plano de contas "##"utilizando esta conta referencial."##"Deseja bloqueá-los?"
	Else
		cMsgAlt := STR0024+STR0027+Chr(10)+Chr(13)+STR0028  //"Existe um ou mais plano de contas "##"marcado para ser bloqueado."##"Deseja desmarcá-los?"
	EndIf
	If SimNao(cMsgAlt) == "S"
		While CVD->(!Eof()) .And. xFilial("CVD")+cCodPla+cCodCta == CVD->(CVD_FILIAL+CVD_CODPLA+CVD_CTAREF)
			CT1->(DbSetOrder(1))
			If CT1->(DbSeek(xFilial("CT1")+CVD->CVD_CONTA))
				If !oGDItens:aCols[nGDLin,Len(oGDItens:aHeader)+1]
					//Adiciona recno da conta que será bloqueada
					If aScan(aCT1Blq,{|x| x = CT1->(RECNO())}) = 0
						aAdd(aCT1Blq,CT1->(RECNO()))
					EndIf
				Else
					//Localiza recno do array da conta que será bloqueada
					While aScan(aCT1Blq,{|x| x = CT1->(RECNO())}) != 0
						//Exclui recno do plano de contas do array para não ser mais bloqueados
						aDel(aCT1Blq,aScan(aCT1Blq,{|x| x = CT1->(RECNO())}))
						//Exclui registro nulo do array deixado pelo comando aDel
						aSize(aCT1Blq,Len(aCT1Blq)-1)
					End
				EndIf
			EndIf
			CVD->(DbSkip())
		End
	Else
		lRet := .F.
	EndIf
Else
	If nChamada = 1
		cCodCta:=M->CVN_CTAREF
		If CVD->(DbSeek(xFilial("CVD")+cCodPla+cCodCta+cVersao))
			cMsgAlt := STR0024+STR0027+Chr(10)+Chr(13)+STR0028 //"Existe um ou mais plano de contas "##"marcado para ser bloqueado."##"Deseja desmarcá-los?"
			If SimNao(cMsgAlt) == "S"
				While CVD->(!Eof()) .And. xFilial("CVD")+cCodPla+cCodCta == CVD->(CVD_FILIAL+CVD_CODPLA+CVD_CTAREF)
					CT1->(DbSetOrder(1))
					If CT1->(DbSeek(xFilial("CT1")+CVD->CVD_CONTA))
						//Localiza recno do array da conta que será bloqueada
						While aScan(aCT1Blq,{|x| x = CT1->(RECNO())}) != 0
							//Exclui recno do plano de contas do array para não ser mais bloqueados
							aDel(aCT1Blq,aScan(aCT1Blq,{|x| x = CT1->(RECNO())}))
							//Exclui registro nulo do array deixado pelo comando aDel
							aSize(aCT1Blq,Len(aCT1Blq)-1)
						End
					EndIf
					CVD->(DbSkip())
				End
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ctb025Exp    ³ Autor ³ Felipe A. Melo    ³ Data ³ 17/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exporta cadastro do plano de contas referencial            ³±±
±±³          ³ se já foi utilizada em alguma outra rotina                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb025Exp()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ctb025Exp()

Local aEstru	:=	{}            
Local aPar	:=	{}   
Local aRet	:=	{}   
Local cLin	:=	""
Local aTxt	:=	{}
Local nX,nY

SaveInter()

aAdd(aPar,{6,STR0001,padr('',150),"",,"",90 ,.T.,"Arquivo .CVE |*.CVE",'',GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}) //"Plano referencial"
aAdd(aPar,{1,STR0029,Space(TamSx3("CVN_CODPLA")[1]),"@!","NaoVazio().and.ExistCpo('CVN',mv_par02,1)",,,3,.T.}) //"Código plano ref."

If ParamBox(aPar,STR0030,@aRet) //"Exportar para arquivo plano referencial"
	If At('.',aRet[1]) == 0
		aRet[1]	:=	Alltrim(aRet[1])+'.CVE'
	Endif	
 	If (nHandle := FCreate(aRet[1]))== -1
		Help(" ",1,"HELP",STR0031,STR0032,3,1) //"ERRO"##"Erro na criacao do arquivo!"
		Return
	EndIf
	CVN->(DbSetOrder(1))
	If !CVN->(DbSeek(xFilial("CVN")+mv_par02)) .Or. Empty(mv_par02)
		Help(" ",1,"HELP",STR0019,STR0033+STR0034+STR0035,3,1) //"PROIBIDO"##"Favor preencher o campo "##"'Código plano ref.' com um "##"código existente!"
		Return
	EndIf

	SX3->(DbSetOrder(2)) 	
	aEstru	:=	CVN->(DbStruct())

	For nX:=1 To Len(aEstru)
		cLin	+=	aEstru[nX,1]+";"
	Next	

	cLin := Substr(cLin,1,Len(cLin)-1) + CHR(13) + CHR(10)
	FWrite(nHandle,cLin,Len(cLin))
	
	//--------------------------------------------------------------
	DbSelectArea("CVN")
	DbSetOrder(1)
	DbSeek(xFilial("CVN")+mv_par02)
	While !Eof() .And. CVN->(CVN_FILIAL+CVN_CODPLA) == xFilial("CVN")+mv_par02
		AAdd(aTxt,{})
		For nX:=1 To Len(aEstru)
			Do Case
			Case aEstru[nX,2] == "C"
				AADd(aTxt[Len(aTxt)],FieldGet(FieldPos(aEstru[nX,1])))
			Case aEstru[nX,2] == "L"
				AADd(aTxt[Len(aTxt)],If(FieldGet(FieldPos(aEstru[nX,1])),"T","F"))
			Case aEstru[nX,2] == "D"
				AADd(aTxt[Len(aTxt)],Dtos(FieldGet(FieldPos(aEstru[nX,1]))))
			Case aEstru[nX,2] == "N"
				AADd(aTxt[Len(aTxt)],Str(FieldGet(FieldPos(aEstru[nX,1]))))
			EndCase					
		Next
		DbSkip()
	Enddo          

	For nX:= 1 To Len(aTxt)
		cLin	:=	"" 
		For nY:=1 To Len(aTxt[nX])
			cLin  +=   aTxt[nX,nY]+";"
		Next                      
		cLin := Substr(cLin,1,Len(cLin)-1) + CHR(13) + CHR(10)		
		FWrite(nHandle,cLin,Len(cLin))                          	
	Next	
	FClose(nHandle)
	Aviso(STR0037,STR0038,{STR0017}) //"Finalizado"##"Exportacao gerada com sucesso"##"OK"
Endif

RestInter()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Ctb025Imp    ³ Autor ³ Felipe A. Melo    ³ Data ³ 17/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exporta cadastro do plano de contas referencial            ³±±
±±³          ³ se já foi utilizada em alguma outra rotina                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb025Imp()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA025                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ctb025Imp(lWizard, cRet, cCod)

Local nX,nY
Local nMv		:= 0 
Local nLinha 	:= CVN->CVN_LINHA
Local nPosLinha := 0
Local nPosConta	:= 0
Local nPosTxt	:= 0
Local nPosCpoT	:= 0
Local nCont1	:= 0 

Local cLin		:= ""
Local cCodCtaRef:= ""
Local cCtaSup	:= ""
Local cNatCta	:= ""

Local aPar		:=	{}
Local aRetP1 	:=  {}	
Local aTxt		:=	{}
Local aMvPar	:=  {}
Local aCampo	:=	CVN->(DbStruct())
Local aPosCampos:= {}   
Local aYesNo	:= {STR0053,STR0054}//"Sim"##"Nao"
Local aNewCpoT	:= {}

Private aRet	:=	{}
If ValType(lWizard) <> "L"
	lWizard := .F.
Endif

SaveInter()

AADD(aNewCpoT, "CVN_VERSAO")
AADD(aNewCpoT, "CVN_STAPLA")
AADD(aNewCpoT, "CVN_CTASUP")
AADD(aNewCpoT, "CVN_CLASSE")
AADD(aNewCpoT, "CVN_TPUTIL")
AADD(aNewCpoT, "CVN_CTAREL")

For nMv := 1 To 10
   aAdd( aMvPar, &( "mv_par" + StrZero( nMv, 2, 0 ) ) )
Next nMv

//Define o valor do array conforme estrutura
aPosCampos:= Array(Len(aCampo))
mv_par01:=Space(150)
mv_par02:=Space(003)
aAdd(aPar,{6,STR0001,padr('',150),"","FILE(mv_par01)","", 90 ,.T.,"Arquivo .CVE |*.CVE",'',GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}) //"Plano referencial"
aAdd(aPar,{1,STR0029,Space(TamSx3("CVN_CODPLA")[1]),"@!","NaoVazio().and.ExistChav('CVN',mv_par02+'001')",,,3,.T.}) //"Código plano ref."
aAdd(aPar,{2,STR0049,1,aYesNo,50,,.T.}) //"Atualiza Conta Superior? 
aAdd(aPar,{2,STR0052,1,aYesNo,50,,.T.}) //"Atualiza Classe da conta (Sintetica/Analítica)?


If lWizard .Or. ParamBox(aPar,STR0039,@aRet) //"Importar arquivo para plano referencial"

	If lWizard
		AADD(aRet,cRet) 
		mv_par02 := cCod
	Endif

	aRetP1 := AjRetParam(aRet,aPar)
	
	If AllTrim(aRetP1[1]) == '\samples\documents\ctb'
		Help(" ",1,"NOFILEIMPOR")
		For nMv := 1 To Len( aMvPar )
    		&( "mv_par" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
		Next nMv		
		Return
	Endif
	
	If (nHandle := FT_FUse(AllTrim(aRetP1[1])))== -1
		Help(" ",1,"NOFILEIMPOR")
		For nMv := 1 To Len( aMvPar )
    		&( "mv_par" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
		Next nMv		
		Return
	EndIf
	
	CVN->(DbSetOrder(1))
	If CVN->(DbSeek(xFilial("CVN")+aRetP1[2])) .Or. Empty(aRetP1[2])
		Help(" ",1,"HELP",STR0019,STR0033+STR0034+STR0036,3,1) //"PROIBIDO"##"Favor preencher o campo "##"'Código plano ref.' com um "##"novo código!"
		For nMv := 1 To Len( aMvPar )
		    &( "mv_par" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
		Next nMv		
		Return
	EndIf

	FT_FGOTOP()
	cLinha := FT_FREADLN()
	nPos	:=	0
	nAt	:=	1
	While nAt > 0
		nPos++
		nAt	:=	AT(";",cLinha)
		If nAt == 0
			cCampo := cLinha
		Else
			cCampo	:=	Substr(cLinha,1,nAt-1)
		Endif
		
		nPosCpoT	:= ASCAN(aNewCpoT, cCampo)
		If nPosCpoT > 0 
			ADel(aNewCpoT,nPosCpoT)
			ASize(aNewCpoT,Len(aNewCpoT)-1)
			nPosCpoT	:= 0			 
		Endif  
		
		nPosCpo	:=	aScan( aCampo, { |x| x[1] == cCampo } )
		If nPosCPO > 0
			aPosCampos[nPosCpo]:= nPos
		Endif
		cLinha	:=	Substr(cLinha,nAt+1)
	Enddo
	
	//Tratamento para os novos campos que não existem no arquivo a ser importado
	nPos++
	For nCont1	:= 1 to Len(aNewCpoT)
		nPosCpo	:=	aScan( aCampo, { |x| x[1] == aNewCpoT[nCont1] } )
		If nPosCpo > 0
			aPosCampos[nPosCpo]:= nPos
		Endif
		nPos++
	Next 
	
	If (nPosNil:= Ascan(aPosCampos,Nil)) > 0 .And. !lWizard
		Aviso(STR0040,STR0041+aCampo[nPosNil][1]+STR0042+STR0043,{STR0044}) //"Estrutura incorreta."##"O campo "##" nao foi achado na estrutura,"##" por favor verificar."##"Sair"
		For nMv := 1 To Len( aMvPar )
    		&( "mv_par" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
		Next nMv		
		Return .F.
	Endif
	nPosLinha := aScan( aCampo, { |x| x[1] == "CVN_LINHA" } )
	If nPosLinha == 0 .OR. aPosCampos[nPosLinha] == 0
		MsgAlert(STR0048) //"Nao encontrado campo linha na estrutura do arquivo texto a ser importado."
	EndIf
	FT_FSKIP()
	While !FT_FEOF()
		cLinha := FT_FREADLN()
		AADD(aTxt,{})
		nCampo := 1
		While At(";",cLinha)>0
			aAdd(aTxt[Len(aTxt)],Substr(cLinha,1,At(";",cLinha)-1))
			nCampo ++
			cLinha := StrTran(Substr(cLinha,At(";",cLinha)+1,Len(cLinha)-At(";",cLinha)),'"','')
		End
		If Len(AllTrim(cLinha)) > 0
			aAdd(aTxt[Len(aTxt)],StrTran(Substr(cLinha,1,Len(cLinha)),'"','') )
		Else
			aAdd(aTxt[Len(aTxt)],"")
		Endif
		FT_FSKIP()
	End
	FT_FUSE()
	Begin Transaction
	For nX:=1 To Len(aTxt)
		CVN->(DbSetOrder(1))		                                  
		nLinha := PadL( AllTrim( aTxt[nX,aPosCampos[nPosLinha] ] ), TamSX3( "CVN_LINHA" )[1], "0" )
  		If CVN->(DbSeek(xFilial("CVN")+mv_par02+nLinha))       
		  Loop
		EndIf
		RecLock("CVN",.T.)
		For nY:=1 To Len(aCampo) 
			If AllTrim(aCampo[nY][1]) == "CVN_FILIAL"
				FieldPut(FieldPos(aCampo[nY][1]),xFilial("CVN"))		
			ElseIf AllTrim(aCampo[nY][1]) == "CVN_CODPLA"
				FieldPut(FieldPos(aCampo[nY][1]),mv_par02)
			ElseIf AllTrim(aCampo[nY][1]) == "CVN_LINHA"
				FieldPut( FieldPos( aCampo[nY][1] ), PadL( AllTrim( aTxt[nX,aPosCampos[nY] ] ), TamSX3( "CVN_LINHA" )[1], "0" ) )
			ElseIf AllTrim(aCampo[nY][1]) == "CVN_VERSAO"
				FieldPut(FieldPos(aCampo[nY][1]),"0001")
			ElseIf AllTrim(aCampo[nY][1]) == "CVN_CTASUP"
			
				If aRetP1[3] == 1 //Se atualiza conta superior
					nPosConta	:= aScan( aCampo, { |x| x[1] == "CVN_CTAREF" } )				
					If nPosConta > 0
						nPosTxt		:= aPosCampos[nPosConta]					 
						cCtaRef		:= aTxt[nX][nPosTxt]
						cCtaSup		:= fImpCtaSup(mv_par02,"0001",cCtaRef,aCampo,aPosCampos,aTxt)
					 	If ASCAN(aNewcpoT,"CVN_CTASUP") > 0 //Campo não existe no TXT
							FieldPut(FieldPos(aCampo[nY][1]),cCtaSup)					 	
					 	Else
							If Empty(aTxt[nX,aPosCampos[nY]])	//Se o campo CVN_CTASUP estiver vazio
								FieldPut(FieldPos(aCampo[nY][1]),cCtaSup)
							Else
								FieldPut(FieldPos(aCampo[nY][1]),aTxt[nX,aPosCampos[nY]])				
							Endif
						EndIf	
					Endif
				Else
					If ASCAN(aNewcpoT,"CVN_CTASUP") == 0 //Só atualiza se o campo exisitir no TXT
						FieldPut(FieldPos(aCampo[nY][1]),aTxt[nX,aPosCampos[nY]])
					EndIF				
				EndIf
			ElseIf AllTrim(aCampo[nY][1]) == "CVN_STAPLA"
				FieldPut(FieldPos(aCampo[nY][1]),"1")
			ElseIf AllTrim(aCampo[nY][1]) == "CVN_CLASSE"
				If ASCAN(aNewcpoT,"CVN_CLASSE") > 0 //Esse campo não existe no arquivo TXT
					FieldPut(FieldPos(aCampo[nY][1]),"")
				Else
					FieldPut(FieldPos(aCampo[nY][1]),aTxt[nX,aPosCampos[nY]])				
				Endif
			ElseIf AllTrim(aCampo[nY][1]) == "CVN_CTAREL"
				FieldPut(FieldPos(aCampo[nY][1]),"")
			ElseIf AllTrim(aCampo[nY][1]) == "CVN_TPUTIL"
				If ASCAN(aNewcpoT,"CVN_TPUTIL") > 0 //Esse campo não existe no arquivo TXT 
					FieldPut(FieldPos(aCampo[nY][1]),"F")				
				Else				
					If Empty(aTxt[nX,aPosCampos[nY]])	//Se o campo CVN_TPUTIL estiver vazio
						FieldPut(FieldPos(aCampo[nY][1]),"F")
					Else		
						FieldPut(FieldPos(aCampo[nY][1]),aTxt[nX,aPosCampos[nY]])
					Endif
				EndIf
			ElseIf AllTrim(aCampo[nY][1]) == "CVN_NATCTA"
				cNatCta	:= StrZero(Val((aTxt[nX,aPosCampos[nY]])),2)
				If cNatCta $ "01/02/03/04/05/09"
					FieldPut(FieldPos(aCampo[nY][1]),cNatCta)
				EndIf
			ElseIF aCampo[nY][2] == "C"
				FieldPut(FieldPos(aCampo[nY][1]),aTxt[nX,aPosCampos[nY]])
			ElseIF aCampo[nY][2] == "D" 
				FieldPut(FieldPos(aCampo[nY][1]),STOD(aTxt[nX,aPosCampos[nY]]))
			EndIf
		Next    

		MsUnLock()
	Next
	
	End Transaction
	
	//Se atualiza a classe da conta
	If aRetP1[4] == 1
		fImpClasse(aRetP1[2],"0001")
	EndIf
		
	If !lWizard
		Aviso(STR0037,STR0045,{STR0017}) //"Finalizado"##"Importacao finalizada com sucesso"##"OK"
	Endif
Endif

For nMv := 1 To Len( aMvPar )
    &( "mv_par" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
Next nMv

RestInter()

Return
//-------------------------------------------------------------------
/*{Protheus.doc} CTB025SUP 
Sugere código de conta ref. superior
@author Simone Mie Sato Kakinoana
   
@version P12
@since   13/03/2015
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function Ctb025Sup()

Local aAmbSave 	:= GetArea()
Local aAmbCVN  	:= CVN->( GetArea() )
Local cCodigo	:= ""
Local cCod		:= ""
 
Local nCont		:= 0
Local nGDLin 	:= oGDItens:oBrowse:nAt
Local nColCtaRef:= aScan(oGDItens:aHeader,{|x|Alltrim(x[2])=="CVN_CTAREF"})
Local nColCtaSup:= aScan(oGDItens:aHeader,{|x|Alltrim(x[2])=="CVN_CTASUP"})
Local nLinSup	:= 0

If mv_par01 == 1	// Se a geração do código de conta superior for automático	

	cCodigo			:= AllTrim(oGDItens:aCols[nGDLin,nColCtaRef])
		
	For nCont := 1 to Len(cCodigo)
		
		cCod  := padr(Substr(cCodigo,1,Len(cCodigo)-nCont),20)
			
		//Procura no próprio objeto
		nLinSup	:=aScan(oGDItens:aCols,{|x|Alltrim(x[nColCtaRef]) == Alltrim(cCod)})
			
		If nLinSup > 0
			cCod := oGDItens:aCols[nLinSup,nColCtaRef]
			Exit
		Endif
	Next
Else
	cCodigo			:= AllTrim(oGDItens:aCols[nGDLin,nColCtaSup])	
Endif

RestArea( aAmbCVN )
RestArea( aAmbSave )

Return cCod 

//-------------------------------------------------------------------
/*{Protheus.doc} fAtuLinha 
Atualiza a linha para ordem de conta de ref. ou conta superior, conforme parâmetro definido pelo usuário.
@author Simone Mie Sato Kakinoana
   
@version P12
@since   13/03/2015
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function fAtuLinha(oGdItens)

Local aSaveArea		:= GetArea()
Local aColsTrb		:= ACLONE(oGdItens:aCols)

Local nCont			:= 0
Local nColCtaRef	:= aScan(oGDItens:aHeader,{|x|Alltrim(x[2])=="CVN_CTAREF"})
Local nColCtaSup	:= aScan(oGDItens:aHeader,{|x|Alltrim(x[2])=="CVN_CTASUP"})
Local nColLinha		:= aScan(oGDItens:aHeader,{|x|Alltrim(x[2])=="CVN_LINHA"})
	
cItem := StrZero( 1,Len(CVN->CVN_LINHA) )

If mv_par02 == 1 		// Se for ordenar por codigo de conta ref.
 	aColsTrb	:= ASort(aColsTrb,,,{|x,y|y[nColCtaRef]>x[nColCtaRef]})
 	For nCont	:= 1 to Len(aColsTrb)
 		aColsTrb[nCont][nColLinha]	:= cItem
		cItem := Soma1(cItem) 	
 	Next
Else					// Se for ordenar por codigo de conta superior
 	aColsTrb		:= ASort(aColsTrb,,,{|x,y|y[nColCtaSup]+y[nColCtaRef]>x[nColCtaSup]+x[nColCtaRef]})
 	For nCont	:= 1 to Len(aColsTrb)
 		aColsTrb[nCont][nColLinha]	:= cItem
		cItem := Soma1(cItem) 	
 	Next	
Endif

oGdItens:aCols	:= ACLONE(aColsTrb)

RestArea(aSaveArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} FirstAlt  
Verifica se existe alguma conta superior preenchida. 
@author Simone Mie Sato Kakinoana
   
@version P12
@since   16/03/2015
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function FirstAlt()

Local lRet			:= .F.

Local cAliasCVN		:= "CVN"
Local cCodigo		:= M->CVN_CODPLA
Local cVersao		:= M->CVN_VERSAO 

cAliasCVN			:= GetNextAlias()

BeginSql Alias cAliasCVN
	SELECT COUNT(*) REGS
	FROM %table:CVN% CVN
	WHERE CVN.CVN_FILIAL = %xFilial:CVN% 
	AND CVN.CVN_CODPLA = %Exp:cCodigo%
	AND CVN.CVN_VERSAO = %Exp:cVersao%
	AND CVN.CVN_CTASUP <> ''
	AND CVN.%NotDel%
EndSql

DbSelectArea(cAliasCVN)

If (cAliasCVN)->REGS > 0 
	lRet	:= .F.
Else
	lRet	:= .T.
EndIf	

dbSelectArea(cAliasCVN)
dbCloseArea()

Return(lRet)


//-------------------------------------------------------------------
/*{Protheus.doc} fAtuCtaSup 
Se for primeira alteração após a criação do campo "Versão" e o 
usuário escolher para atualizar Conta Superior, o sistema irá sugerir
a conta superior na getdados. 
@author Simone Mie Sato Kakinoana
   
@version P12
@since   16/03/2015
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function fAtuCtaSup(aHead,aCol)

Local aSaveArea		:= GetArea()
Local aSaveCVN		:= CVN->(GetArea())	
Local aColTmp		:= ACLONE(aCol)

Local cCodPla	:= ""
Local cVersao	:= ""
Local cCodigo	:= "" 
Local cCod		:= ""
 
Local nCont1	:= 0
Local nCont2	:= 0 
Local nColCtaRef:= aScan(aHead,{|x|Alltrim(x[2])=="CVN_CTAREF"})
Local nColCtaSup:= aScan(aHead,{|x|Alltrim(x[2])=="CVN_CTASUP"})


cCodPla	:= M->CVN_CODPLA
cVersao	:= M->CVN_VERSAO

DbSelectArea("CVN")
DbSetOrder(4)	//CVN_FILIAL+CVN_CODPLA+CVN_VERSAO+CVN_CTAREF

For nCont1 := 1 to Len(aColTmp)

	cCodigo			:= AllTrim(aColTmp[nCont1,nColCtaRef])
		
	For nCont2 := 1 to Len(cCodigo)
		
		cCod  := padr(Substr(cCodigo,1,Len(cCodigo)-nCont2),20)			
		If MsSeek(xFilial("CVN")+cCodPla+cVersao+cCod,.f.)			
			cCod := CVN->CVN_CTAREF
			Exit
		Endif
	Next
	
	aColTmp[nCont1][nColCtaSup] := cCod
	cCod	:= ""
Next

RestArea(aSaveCVN)
RestArea(aSaveArea)

Return(aColTmp)


//-------------------------------------------------------------------
/*{Protheus.doc} CtbCVNCVD 
Na inicialização do módulo, atualiza os campos CVN_VERSAO,CVN_STAPLA e CVD_VERSAO, 
caso não tenha nenhum registro do plano referencial com esses campos 
preenchidos. 
@author Simone Mie Sato Kakinoana
   
@version P12
@since   17/03/2015
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CtbCVNCVD()

Local cNewTmp	:= GetNextAlias()
Local cQuery	:= ""

Local lAtualiza	:= .F.
Local lRet		:= .F.

cQuery := " SELECT COUNT(*) REGS "
cQuery += " FROM " + RetSqlname( "CVN" ) + " CVN"
cQuery += " WHERE CVN.CVN_FILIAL = '"+xFilial("CVN")+"' "
cQuery += " AND CVN.CVN_VERSAO <> '' " 
cQuery += " AND CVN.D_E_L_E_T_ = ' '"
	
cQuery := ChangeQuery( cQuery )	

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNewTmp)	

DbSelectArea(cNewTmp)
DbGoTop()
If (cNewTmp)->REGS	> 0 
	lAtualiza	:= .F.
Else
	lAtualiza	:= .T.
EndIf

(cNewTmp )->(dbCloseArea())
	
If lAtualiza
	cQuery := " UPDATE "
	cQuery += " "+RetSqlName("CVN")
	cQuery += " SET CVN_VERSAO = '0001', CVN_STAPLA = '1' "
	cQuery += " WHERE CVN_FILIAL = '"+xFilial("CVN")+"'"
	cQuery += " AND D_E_L_E_T_ = ' '"
							
	If TcSqlExec(cQuery) <> 0
		UserException(STR0050  ;  //"Erro na selecao do cadastro do plano referencial"
			+ CRLF + STR0051+ CRLF + TCSqlError() )  //"Processo cancelado..."
		lRet	:=	.F.
	Else
		lRet	:= .T.				
	Endif

	If lRet
		cQuery := " UPDATE "
		cQuery += " "+RetSqlName("CVD")
		cQuery += " SET CVD_VERSAO = '0001'"
		cQuery += " WHERE CVD_FILIAL = '"+xFilial("CVD")+"'"
		cQuery += " AND D_E_L_E_T_ = ' '"
								
		If TcSqlExec(cQuery) <> 0									
			UserException(STR0050  ;  //"Erro na selecao do cadastro do plano referencial"
			+ CRLF + STR0051+ CRLF + TCSqlError() )  //"Processo cancelado..."
			lRet	:=	.F.
		Endif
	Endif
EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} fAtuClasse 
Se for primeira alteração após a criação do campo "Versão" e o 
usuário escolher para atualizar Conta Superior, o sistema irá sugerir
a classe da conta (analitica/sintética) 
@author Simone Mie Sato Kakinoana
   
@version P12
@since   17/03/2015
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function fAtuClasse(aHead,aCol)

Local aSaveArea		:= GetArea()
Local aSaveCVN		:= CVN->(GetArea())	
Local aColTmp		:= ACLONE(aCol)

Local cCodigo	:= "" 
 
Local nCont1	:= 0
Local nLinSup	:= 0 
Local nColCtaRef:= aScan(aHead,{|x|Alltrim(x[2])=="CVN_CTAREF"})
Local nColCtaSup:= aScan(aHead,{|x|Alltrim(x[2])=="CVN_CTASUP"})
Local nColClasse:= aScan(aHead,{|x|Alltrim(x[2])=="CVN_CLASSE"})

cCodPla	:= M->CVN_CODPLA
cVersao	:= M->CVN_VERSAO

For nCont1 := 1 to Len(aColTmp)

	cCodigo			:= AllTrim(aColTmp[nCont1,nColCtaRef])
	
	//Procura no próprio objeto
	nLinSup	:=aScan(aCol,{|x|Alltrim(x[nColCtaSup]) == Alltrim(cCodigo)}) 
	
	//Se a conta referencial está como superior de outra, é sintética		
	If nLinSup > 0	
		aColTmp[nCont1][nColClasse] := "1"	//Sintetica
	Else
		aColTmp[nCont1][nColClasse] := "2"	//Analítica
	Endif
Next

RestArea(aSaveCVN)
RestArea(aSaveArea)

Return(aColTmp)

//-------------------------------------------------------------------
/*{Protheus.doc} fImpCtaSup 
Na rotina de importação do arquivo, se a conta superior não estiver
preenchida no arquivo, sistema irá preencher a conta superior.
@author Simone Mie Sato Kakinoana
   
@version P12
@since   18/03/2015
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function fImpCtaSup(cCodPla,cVersao,cConta,aCampo,aPosCampos,aTxt)

Local aSaveArea		:= GetArea()

Local cCodigo	:= "" 
Local cCod		:= ""

Local nCont		:= 0
Local nLinSup  
Local nPosCtRef1:= aScan( aCampo, { |x| x[1] == "CVN_CTAREF" } )
Local nPosTxt	:= aPosCampos[nPosCtRef1]

cCodigo			:= AllTrim(cConta)
		
For nCont := 1 to Len(cCodigo)
	cCod  	:= padr(Substr(cCodigo,1,Len(cCodigo)-nCont),20)
	nLinSup	:=aScan(aTxt,{|x|Alltrim(x[nPosTXT]) == Alltrim(cCod)})
			
	If nLinSup > 0
		cCod := aTxt[nLinSup,nPosTXT]
		Exit
	Endif		
Next
	
RestArea(aSaveArea)

Return(cCod)

//-------------------------------------------------------------------
/*{Protheus.doc} fImpClasse  
Na rotina de importação do arquivo, se a classe da conta não estiver
preenchida, sistema ira prencher a classe autaomaticamente.  
 
@author Simone Mie Sato Kakinoana
   
@version P12
@since   18/03/2015
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function fImpClasse(cCodPla,cVersao)

Local aSaveArea		:= GetArea()

Local cCtaRef		:= ""
Local cClasse		:= ""

Local nRecCVN		:= 0

DbSelectArea("CVN")
DbSetOrder(4) 	//CVN_FILIAL+CVN_CODPLA+CVN_VERSAO+CVN_CTAREF
If DbSeek(xFilial("CVN")+cCodPla+cVersao)
		
	While !Eof() .And. CVN->CVN_CODPLA == cCodPla .And. CVN->CVN_VERSAO == cVersao			
		cCtaRef	:= CVN->CVN_CTAREF
		nRecCVN	:= CVN->(Recno())		
		
		If Empty(CVN->CVN_CLASSE)
			DbSetOrder(3)//CVN_FILIAL+CVN_CODPLA+CVN_VERSAO+CVN_CTASUP+CVN_CTAREF
			If DbSeek(xFilial("CVN")+cCodPla+cVersao+cCtaRef)//Verificar se o código da conta ref. é superior de outra conta
				cClasse	:= "1"
			Else
				cClasse	:= "2"
			Endif
					
			DbSetOrder(4)
			DbGoto(nRecCVN)
			RecLock("CVN",.F.)
			CVN->CVN_CLASSE	:= cClasse
			MsUnlock()
			cClasse	:= ""
		EndIf
		DbSelectArea("CVN")
		DbSkip()
	End
			
EndIf

RestArea(aSaveArea)

Return
//-------------------------------------------------------------------
/*{Protheus.doc} AjRetParam  
Ajusta o retorno da Parambox.
 
@author Simone Mie Sato Kakinoana
   
@version P12
@since   18/03/2015
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Static Function AjRetParam(aRet,aParamBox)

Local nX	:= 1

IF ValType(aRet) == "A" .AND. Len(aRet) == Len(aParamBox)
	For nX := 1 to Len(aParamBox)
		If aParamBox[nX][1] == 1
			aRet[nX] := aRet[nX]
		ElseIf aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "C"
			aRet[nX] := aScan(aParamBox[nX][4],{|x| Alltrim(x) == aRet[nX]})
		ElseIf aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "N"
			aRet[nX] := aRet[nX]
		Endif
	Next nX
ENDIF

Return aRet


//-------------------------------------------------------------------
/*{Protheus.doc} Ctb025Filt 
Função para filtro de código e versão no plano referencial na consulta
padrão da conta referencial (CVN4) 
@author Simone Mie Sato Kakinoana
   
@version P12
@since   06/04/2015
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ctb025Filt

Local cRet	:= ""

cRet	:= CVN->CVN_CODPLA == M->CVN_CODPLA .And. CVN->CVN_VERSAO == M->CVN_VERSAO

Return(cRet)


//-------------------------------------------------------------------
/*{Protheus.doc} Ctb025IVer 
Chamada para copiar, importar e incluir manual nova versão.
@author Mayara Alves
   
@version P12
@since   15/04/2015
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function Ctb025IVer(cAlias,nReg,nOpc)
Local nOrdSeek := 5
Local aGrvCps  := {}
Local cVersao		:= ""
Local cStatus		:= "2"
Local cCndSeek := "xFilial('CVN')+CVN->CVN_CODPLA+CVN->CVN_VERSAO" 

Local cPlan		:= ""
Local cProVer			:= ""


//Valida a criação da nova versao
If VldVersao(CVN->CVN_CODPLA,nOpc)
	If nOpc == 1 //Copiar

		CVN->(dbSetOrder(5))

		If CVN->(dbSeek(xFilial('CVN')+CVN->CVN_CODPLA+CVN->CVN_VERSAO))

			cPlan		:= CVN->CVN_CODPLA
			cVersao		:= CVN->CVN_VERSAO
		
		//Traz o numero da nova versão 
			cProVer:=NumVersao(cPlan)

			While  CVN->(!Eof()) .And. (cPlan == CVN->CVN_CODPLA) .And. (cVersao	== CVN->CVN_VERSAO)

				cCpoItem		:= CVN->CVN_LINHA
		
				aGrvCps := {}
		
				nX := 1
			//Trata campos extras
				aAdd(aGrvCps,{"CVN_FILIAL"   ,xFilial('CVN')   })
				aAdd(aGrvCps,{"CVN_CODPLA"   ,CVN->CVN_CODPLA   })
				aAdd(aGrvCps,{"CVN_DSCPLA"   ,CVN->CVN_DSCPLA   })
				aAdd(aGrvCps,{"CVN_DTVIGI"   ,CVN->CVN_DTVIGI   })
				aAdd(aGrvCps,{"CVN_DTVIGF"   ,CVN->CVN_DTVIGF   })
				aAdd(aGrvCps,{"CVN_ENTREF"   ,CVN->CVN_ENTREF   })
				aAdd(aGrvCps,{"CVN_LINHA"    ,CVN->CVN_LINHA    })
				aAdd(aGrvCps,{"CVN_CTAREF"   ,CVN->CVN_CTAREF   })
				aAdd(aGrvCps,{"CVN_DSCCTA"   ,CVN->CVN_DSCCTA   })
				aAdd(aGrvCps,{"CVN_TPUTIL"   ,CVN->CVN_TPUTIL   })
				aAdd(aGrvCps,{"CVN_VERSAO"   ,cProVer				}) //CVN_VERSAO+1
				aAdd(aGrvCps,{"CVN_CLASSE"   ,CVN->CVN_CLASSE   })
				aAdd(aGrvCps,{"CVN_NATCTA"   ,CVN->CVN_NATCTA   })
				aAdd(aGrvCps,{"CVN_CTASUP"   ,CVN->CVN_CTASUP   })
				aAdd(aGrvCps,{"CVN_CTAREL"   ,CVN->CVN_CTAREL   })
				aAdd(aGrvCps,{"CVN_STAPLA"   ,If (cProVer == "0001" , "1","2" )}) // 2 - Revisão.

				fGravaCop(aGrvCps)
		
				CVN->(DbSkip())

			End

		EndIf
	ElseIf nOpc == 2 //Importar
		Ctb025IpVe(.F., "", "")
	ElseIf nOpc == 3 //Manual

		Ctb025Pla(cAlias,nReg,nOpc)
		
		nContVer++

	EndIf
EndIf

Return

Static Function fGravaCop(aGrvCps)
Local nK			:= 0
Local aArea		:=GetArea()
Local aAreaCVN	:= CVN->(GetArea()) 
		RecLock(cAlias,.T.)

		For nK:=1 To Len(aGrvCps)
			&(aGrvCps[nK,1]) := aGrvCps[nK,2]
		Next nK

		CVN->(MsUnLock())

RestArea(aAreaCVN)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} NumVersao  
Pega o numero para a proxima versao

@author Mayara Alves

@version P12
@since   13/04/2015
@return  cRet - Numero da proxima versao
@obs	 
*/
//-------------------------------------------------------------------
Static Function NumVersao(cPlan)

Local cQuery	:= ""
Local cNextA	:= GetNextAlias()
Local cRet		:= ""

		cQuery := " SELECT MAX(CVN_VERSAO) VERSAO"
		cQuery += " FROM " + RetSqlname( "CVN" ) + " CVN"
		cQuery += " WHERE CVN.CVN_FILIAL = '"+xFilial("CVN")+"' "
		cQuery += " AND CVN_CODPLA = '"+cPlan+"'"
		cQuery += " AND CVN.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery( cQuery )

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextA)

		DbSelectArea(cNextA)
		If (cNextA)->(!Eof())
			cRet:= Soma1((cNextA)->VERSAO)
		EndIf

	(cNextA)->(dbCloseArea())		
Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} Ctb025IpVe  
Importa a nova versao

@author Mayara Alves

@version P12
@since   13/04/2015
@obs	 
*/
//-------------------------------------------------------------------
Static Function Ctb025IpVe(lWizard, cRet, cCod)

Local nX	:= 0
Local nY	:= 0
Local nMv		:= 0 
Local nLinha 	:= CVN->CVN_LINHA
Local nPosLinha := 0
Local nPosConta	:= 0
Local nPosTxt	:= 0
Local nPosCpoT	:= 0
Local nCont1	:= 0 

Local cLin		:= ""


Local aPar		:=	{}
Local aRetP1 	:=  {}	
Local aTxt		:=	{}
Local aMvPar	:=  {}
Local aCampo	:=	CVN->(DbStruct())
Local aPosCampos:= {}   
Local aNewCpoT	:= {}
Local cVersao		:= ""
Local cCodPla		:= ""
Local cVazio		:= ""


Local dDtVigi	:= nil
Local cDscpla	:= ""
Local dDtVigf	:= nil
Local cEntref	:= ""
Local mv_par01 := ""

Private aRet	:=	{}
If ValType(lWizard) <> "L"
	lWizard := .F.
Endif

AADD(aNewCpoT, "CVN_VERSAO")
AADD(aNewCpoT, "CVN_STAPLA")
AADD(aNewCpoT, "CVN_CTASUP")
AADD(aNewCpoT, "CVN_CLASSE")
AADD(aNewCpoT, "CVN_TPUTIL")
AADD(aNewCpoT, "CVN_CTAREL")

For nMv := 1 To 10
   aAdd( aMvPar, &( "mv_par" + StrZero( nMv, 2, 0 ) ) )
Next nMv

//Define o valor do array conforme estrutura
aPosCampos:= Array(Len(aCampo))
mv_par01:=Space(150)
aAdd(aPar,{6,STR0001,padr('',150),"","FILE(mv_par01)","", 90 ,.T.,"Arquivo .CVE |*.CVE",'',GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}) //"Plano referencial"

If lWizard .Or. ParamBox(aPar,STR0039,@aRet) //"Importar arquivo para plano referencial"

	aRetP1 := AjRetParam(aRet,aPar)
	
	If AllTrim(aRetP1[1]) == '\samples\documents\ctb'
		Help(" ",1,"NOFILEIMPOR",,STR0060,3,1) //"Arquivo não pode estar no caminho '\samples\documents\ctb'"
		
				//restaura os parametros
		For nMv := 1 To Len( aMvPar )
    		&( "mv_par" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
		Next nMv
		
		Return
	Endif
	
	If (nHandle := FT_FUse(AllTrim(aRetP1[1])))== -1
		Help(" ",1,"NOFILEIMPOR",,STR0061,3,1) //"Arquivo não encontrado."
		
				//restaura os parametros
		For nMv := 1 To Len( aMvPar )
    		&( "mv_par" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
		Next nMv
		
		Return
	EndIf

	FT_FGOTOP()
	cLinha := FT_FREADLN()
	nPos	:=	0
	nAt	:=	1
	While nAt > 0
		nPos++
		nAt	:=	AT(";",cLinha)
		If nAt == 0
			cCampo := cLinha
		Else
			cCampo	:=	Substr(cLinha,1,nAt-1)
		Endif
		
		nPosCpoT	:= ASCAN(aNewCpoT, cCampo)
		If nPosCpoT > 0
			ADel(aNewCpoT,nPosCpoT)
			ASize(aNewCpoT,Len(aNewCpoT)-1)
			nPosCpoT	:= 0
		Endif
		
		nPosCpo	:=	aScan( aCampo, { |x| x[1] == cCampo } )
		If nPosCPO > 0
			aPosCampos[nPosCpo]:= nPos
		Endif
		cLinha	:=	Substr(cLinha,nAt+1)
	Enddo
	
	//Tratamento para os novos campos que não existem no arquivo a ser importado
	nPos++
	For nCont1	:= 1 to Len(aNewCpoT)
		nPosCpo	:=	aScan( aCampo, { |x| x[1] == aNewCpoT[nCont1] } )
		If nPosCpo > 0
			aPosCampos[nPosCpo]:= nPos
		Endif
		nPos++
	Next
	
	If (nPosNil:= Ascan(aPosCampos,Nil)) > 0 .And. !lWizard
		Aviso(STR0040,STR0041+aCampo[nPosNil][1]+STR0042+STR0043,{STR0044}) //"Estrutura incorreta."##"O campo "##" nao foi achado na estrutura,"##" por favor verificar."##"Sair"
		//restaura os parametros
		For nMv := 1 To Len( aMvPar )
    		&( "mv_par" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
		Next nMv

		Return .F.
	Endif
	nPosLinha := aScan( aCampo, { |x| x[1] == "CVN_LINHA" } )
	If nPosLinha == 0 .OR. aPosCampos[nPosLinha] == 0
		MsgAlert(STR0048) //"Nao encontrado campo linha na estrutura do arquivo texto a ser importado."
	EndIf
	FT_FSKIP()
	cVazio	:= FT_FREADLN()
	While !FT_FEOF()
		cLinha := FT_FREADLN()
		AADD(aTxt,{})
		nCampo := 1
		While At(";",cLinha)>0
			aAdd(aTxt[Len(aTxt)],Substr(cLinha,1,At(";",cLinha)-1))
			nCampo ++
			cLinha := StrTran(Substr(cLinha,At(";",cLinha)+1,Len(cLinha)-At(";",cLinha)),'"','')
		End
		If Len(AllTrim(cLinha)) > 0
			aAdd(aTxt[Len(aTxt)],StrTran(Substr(cLinha,1,Len(cLinha)),'"','') )
		Else
			aAdd(aTxt[Len(aTxt)],"")
		Endif
		FT_FSKIP()
	End
	FT_FUSE()
	Begin Transaction
	//atualiza campos da nova versão
		cVersao 	:= NumVersao(CVN->CVN_CODPLA)//Traz a proxima versao
		cCodPla	:= CVN->CVN_CODPLA
		dDtVigi	:= CVN->CVN_DTVIGI
		dDtVigf	:= CVN->CVN_DTVIGF
		cDscpla	:= CVN->CVN_DSCPLA
		cEntref	:= CVN->CVN_ENTREF
 
		If !Empty(cVazio)
			For nX:=1 To Len(aTxt)
				CVN->(DbSetOrder(1))
				nLinha := PadL( AllTrim( aTxt[nX,aPosCampos[nPosLinha] ] ), TamSX3( "CVN_LINHA" )[1], "0" )
		
				If CVN->(DbSeek(xFilial("CVN")+CVN->CVN_CODPLA+nLinha+cVersao))
					Loop
				EndIf
		
				RecLock("CVN",.T.)
				For nY:=1 To Len(aCampo)
					If AllTrim(aCampo[nY][1]) == "CVN_FILIAL"
						FieldPut(FieldPos(aCampo[nY][1]),xFilial("CVN"))
					ElseIf AllTrim(aCampo[nY][1]) == "CVN_CODPLA"
						FieldPut(FieldPos(aCampo[nY][1]),cCodPla)
					ElseIF aCampo[nY][1] == "CVN_DSCPLA"
						FieldPut(FieldPos(aCampo[nY][1]),cDscpla)
					ElseIF aCampo[nY][1] == "CVN_DTVIGF"
						FieldPut(FieldPos(aCampo[nY][1]),dDtVigf)
					ElseIF aCampo[nY][1] == "CVN_DTVIGI"
						FieldPut(FieldPos(aCampo[nY][1]),dDtVigi)
					ElseIF aCampo[nY][1] == "CVN_ENTREF"
						FieldPut(FieldPos(aCampo[nY][1]),cEntref)
					ElseIf AllTrim(aCampo[nY][1]) == "CVN_LINHA"
						FieldPut( FieldPos( aCampo[nY][1] ), PadL( AllTrim( aTxt[nX,aPosCampos[nY] ] ), TamSX3( "CVN_LINHA" )[1], "0" ) )
					ElseIf AllTrim(aCampo[nY][1]) == "CVN_VERSAO"
						FieldPut(FieldPos(aCampo[nY][1]),cVersao)
					ElseIf AllTrim(aCampo[nY][1]) == "CVN_CTASUP"
						If ASCAN(aNewcpoT,"CVN_CTASUP") == 0 //Só atualiza se o campo exisitir no TXT
							FieldPut(FieldPos(aCampo[nY][1]),aTxt[nX,aPosCampos[nY]])
						EndIF
					ElseIf AllTrim(aCampo[nY][1]) == "CVN_STAPLA"
						FieldPut(FieldPos(aCampo[nY][1]),"2")
					ElseIf AllTrim(aCampo[nY][1]) == "CVN_CLASSE"
						If ASCAN(aNewcpoT,"CVN_CLASSE") > 0 //Esse campo não existe no arquivo TXT
							FieldPut(FieldPos(aCampo[nY][1]),"")
						Else
							FieldPut(FieldPos(aCampo[nY][1]),aTxt[nX,aPosCampos[nY]])
						Endif
					ElseIf AllTrim(aCampo[nY][1]) == "CVN_CTAREL"
						FieldPut(FieldPos(aCampo[nY][1]),"")
					ElseIf AllTrim(aCampo[nY][1]) == "CVN_TPUTIL"
						If ASCAN(aNewcpoT,"CVN_TPUTIL") > 0 //Esse campo não existe no arquivo TXT
							FieldPut(FieldPos(aCampo[nY][1]),"F")
						Else
							If Empty(aTxt[nX,aPosCampos[nY]])	//Se o campo CVN_TPUTIL estiver vazio
								FieldPut(FieldPos(aCampo[nY][1]),"F")
							Else
								FieldPut(FieldPos(aCampo[nY][1]),aTxt[nX,aPosCampos[nY]])
							Endif
						EndIf
					ElseIF aCampo[nY][2] == "C"
						FieldPut(FieldPos(aCampo[nY][1]),aTxt[nX,aPosCampos[nY]])
	
					EndIf
				Next

				MsUnLock()
			Next
		Else
			Help(" ",1,"VAZIOARQ",,STR0063,3,1) //"O arquivo se encontra vazio"
		EndIf
	End Transaction
		
	If !lWizard
		Aviso(STR0037,STR0045,{STR0017}) //"Finalizado"##"Importacao finalizada com sucesso"##"OK"
	Endif
Endif



For nMv := 1 To Len( aMvPar )
    &( "mv_par" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
Next nMv

Return


//-------------------------------------------------------------------
/*{Protheus.doc} Ctb025IpVe  
Valida a criação da nova versao

@author Mayara Alves

@version P12
@since   13/04/2015
@obs	 
*/
//-------------------------------------------------------------------
Static Function VldVersao(cPlan,nOpc)
Local lRet		:= .T.
Local cQuery	:= ""
Local cNextB	:= GetNextAlias()
Local cRet		:= ""


cQuery := " SELECT COUNT(CVN_STAPLA) STATUS"
cQuery += " FROM " + RetSqlname( "CVN" ) + " CVN"
cQuery += " WHERE CVN.CVN_FILIAL = '"+xFilial("CVN")+"' "
cQuery += " AND CVN_CODPLA = '"+cPlan+"'"
cQuery += " AND CVN_STAPLA = '2'"
cQuery += " AND CVN.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery( cQuery )

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextB)

DbSelectArea(cNextB)
If (cNextB)->(!Eof()) .And. (cNextB)->STATUS >= 1
	lRet := .F.
	If nContVer == 0
		Help(" ",1,"VLDVERSAO",,STR0059,3,1) //"Não pode incluir uma nova versão, pois já existe uma versão com o Status de Revisão."
	Else
		nContVer := 0
	EndIf
EndIf
	
	(cNextB)->(dbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} Ctb025WCD  
when do campo CVN_CODPLA , para que só na inclusão o campo fique
editavel.

@author Mayara Alves

@version P12
@since   28/04/2015
@obs	 
*/
//-------------------------------------------------------------------
Function Ctb025WCD()
Local lRet := INCLUI

If INCLUI .And. (FWIsInCallStack("Ctb025IVer"))
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} CTBA025GDV  
Gatilha a versão a partir do CVD_CODPLA e preenche o CVD_VERSAO com a
última versão (COD_ULTVER).

@author Thiago M

@version P12
@since   04/01/2017
@return Ultima versao CVN_VERSAO (COD_ULTVER) 
@obs Uso na rotina ctba020 Plano de Conta Referencial	 
*/
//-------------------------------------------------------------------
Function CTBA025GDV(cCodPla)

Local cRet		:= ""
Local cQuery	:= ""
Local cNextC	:= ""

If(!empty(cCodPla))	
	
	cNextC	:= GetNextAlias()

	cQuery := " SELECT ISNULL(MAX(CVN_VERSAO), ' ') COD_ULTVER " 
	cQuery += " FROM " + RetSqlname( "CVN" ) + " CVN " 
	cQuery += " WHERE CVN.CVN_FILIAL = '"+xFilial("CVN")+"' " 
	cQuery += "   AND CVN.CVN_CODPLA = '"+cCodPla+"' " 
	cQuery += "   AND CVN.D_E_L_E_T_ <> '*' "
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextC)

		cRet := (cNextC)->COD_ULTVER 
	
	(cNextC)->(dbCloseArea())
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctba025Ajt
Rotina para ajustar campo CVN_LINHA quando tamanho do campo definido no for diferente do conteudo do campo

@author TOTVS
@since 23/09/2019
@version P11.8
/*/
//-------------------------------------------------------------------
Static Function Ctba025Ajt(oSay)
Local nTamLin := Len(CVN->CVN_LINHA)
Local xValue  := ""
Local cFilCVN := CVN_FILIAL
Local cCodPla := CVN_CODPLA
Local cVerPla := CVN_VERSAO
Local aArea   := GetArea()
Local aAreaCVN := CVN->(  GetArea() )

dbSelectArea("CVN")
dbSetOrder(3)
//aqui manter sempre dbSeek para garantir posicionamento correto sempre da filial corrente plano versao posicionada na mbrowse
If dbSeek( cFilCVN+cCodPla+cVerPla )

	//1 TRANSACAO POR PLANO REFERENCIAL
	Begin Transaction
	
	While CVN->( !Eof() .And. CVN_FILIAL+CVN_CODPLA+CVN_VERSAO == cFilCVN+cCodPla+cVerPla )

		xValue := CVN->CVN_LINHA
		RecLock("CVN",.F.)
		CVN->CVN_LINHA := StrZero( Val( xValue ), nTamLin )
		CVN->(MsUnLock())

		CVN->( dbSkip() )
	EndDo
	
	End Transaction
EndIf

RestArea(aAreaCVN)
RestArea(aArea)

Return    	
