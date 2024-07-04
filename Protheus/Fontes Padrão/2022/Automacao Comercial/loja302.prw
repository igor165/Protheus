#INCLUDE "LOJA302.ch"
#INCLUDE "Protheus.ch"

#DEFINE PACOTE_PRODUTO 		"0000001"  //Codigo do pacote de PRODUTOS
#DEFINE PACOTE_PRECO   		"0000002"  //Codigo do pacote de PRECOS
#DEFINE PACOTE_DESCONTO		"0000003"  //Codigo do pacote de REGRA DE DESCONTOS

#DEFINE ACAO_ATUALIZADADOS	"0000001"  //Codigo da acao de atualizacao de dados
#DEFINE ACAO_IMPETIQUETAS	"0000002"  //Codigo da acao de impressao de etiquetas
#DEFINE ACAO_GERACARGA		"0000003"  //Codigo da acao de geracao de cargas
#DEFINE ACAO_GERTEC			"0000004"  //Codigo da acao de geracao dos arquivos GERTEC

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LOJA302  º Autor ³  Vendas Clientes   º Data ³  14/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Browse de visualizacao dos LOTES de manutencao nos produtosº±±
±±º          ³ descontos e precos                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LOJA302()    

Local aCores := {	{ 'MBE_STATUS == "1" ', 'BR_VERDE'    	},;
{ 'MBE_STATUS == "2" ', 'BR_AMARELO'   	},;
{ 'MBE_STATUS == "3" ', 'BR_AZUL'   	},;
{ 'MBE_STATUS == "4" ', 'BR_PRETO'   	},;
{ 'MBE_STATUS == "5" ', 'BR_VERMELHO'  	} } // Array contendo as cores utilizadas nos status do lote

Local cFiltro := ""   // Variavel utilizada para retorno do filtro dos lotes
Local bFilBrw := ""   // Bloco utilizado para efetuar o filtro dos lotes

Private cCadastro 	:= STR0001               // Variavel utilizada para exibir nome da rotina na mbrowse //"Painel de Gestão de Precificação"
Private aRotina 	:= { 	{STR0002, "AxPesqui",0,1},; //"Pesquisar"
{STR0003 ,"LJ302Visual",0,2},; //"Visualizar"
{STR0004 ,"LJ302Lib",0,3},; //"Liberar Lote"
{STR0005 ,"LJ302Imp",0,4},; //"Impr.Antecipada"
{STR0006 ,"LJ302Can",0,5},; //"Cancela Imp.Antec."
{STR0007 ,"LJ302Leg",0,6}}  // Array contendo os campos a serem utilizados no menu //"Legenda"

If MsgYesNo(STR0021) //"Deseja filtrar os lotes a serem listados no Painel de Gestão?"
	
	While .T.
		
		If Pergunte("LOJA302",.T.)
			
			If (!EMPTY(MV_PAR01) .or. !EMPTY(MV_PAR02)) .and. !EMPTY(MV_PAR03)
				msginfo(STR0022) //"Informe no filtro apenas Filiais Inicial/Final ou Grupo de Filiais. As duas informações não possibilita a criação do filtro."
				Loop
			EndIf
			
			If (!EMPTY(MV_PAR01) .and. EMPTY(MV_PAR02))
				msginfo(STR0023) //"Com a Filial Inicial preenchida, informe um conteúdo na pergunta Filial Final. Sem esta informação não é possível a criação do filtro."
				Loop
			EndIf
			
			If (!EMPTY(MV_PAR04) .and. EMPTY(MV_PAR05))
				msginfo(STR0024) //"Com o Lote Inicial preenchido, informe um conteúdo na pergunta Lote Final. Sem esta informação não é possível a criação do filtro."
				Loop
			EndIf
			
			If (!EMPTY(MV_PAR06) .and. EMPTY(MV_PAR07))
				msginfo(STR0025) //"Com a data 'Do Inicio da Vigência' preenchida, informe um conteúdo na pergunta data 'Até Inicio da Viegência'. Sem esta informação não é possível a criação do filtro."
				Loop
			EndIf
			
			cFiltro := LJ302Filter()  // Funcao que retorna o filtro escolhido pelo usuario
			
			// Caso o usuario escolha filtro
			If !EMPTY(cFiltro)
				DbSelectArea("MBE")
				bFilBrw := &("{|| " + cFiltro + " }")
				DbSetFilter(bFilBrw, cFiltro)
				DbGoTop()
				Exit
			EndIf
			
		Else
			Return .F.
		EndIf
		
	End
	
EndIf

mBrowse( 6,1,22,75,"MBE",,,,,,aCores)

MBE->( DbClearFilter() )

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ302VisualºAutor  ³  Vendas Clientes   º Data ³  17/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualizacao do LOTE                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ302Visual() 

Local oDlgLote     := Nil    // Objeto utilizado para montar dialog
Local oTree        := Nil    // Objeto utilizado para montar arvore de entre o lote e pacotes
Local oSayStatus   := Nil    // Objeto utilizado para armazenar os status
Local oListPacotes := Nil    // Objeto utilizado para armazenar o array dos pacotes
Local aListPacotes := {{LoadBitmap( GetResources(),"br_branco"),CToD("  /  /  "),""}} // array que contem os dados a serem apresentados no list dos pacotes
Local oListAcoes   := Nil    // Objeto utilizado para armazenar o array das acoes
Local aListAcoes   := {{LoadBitmap( GetResources(),"br_branco"),"","",CToD("  /  /  "),CToD("  /  /  "),"","","",""}} //array que contem os dados para as acoes
Local oFolder1     := Nil    // Pasta 1 que contera o listbox dos pacotes
Local oFolder2     := Nil    // Pasta 2 que contera o listbox das acoes
Local aCoordenadas := MsAdvSize(.T.)   // Coordenadas para dimensoes da interface
Local nOpcClick    := 0      // Variavel utilizada para armazenar o resultado do botao Ok ou Cancela na interface do Painel de Gestao
Local aButtons     := {}     // Array que contem os novos botoes a serem inseridos na interface do Painel de Gestao
Local aCores1      := {}     // Array que armazena as cores dos status dos pacotes
Local aCores2      := {}     // Array que armazena as cores dos status das acoes

// Cores dos status dos pacotes
Aadd(aCores1,{"br_verde_ocean"   , STR0026  }) //"Pacote Em Liberação"
Aadd(aCores1,{"br_amarelo_ocean" , STR0027  }) //"Pacote Aguardando Execução"
Aadd(aCores1,{"br_cinza_ocean"   , STR0028  }) //"Pacote Executado Parcialmente"
Aadd(aCores1,{"br_azul_ocean"    , STR0029  }) //"Pacote Executado"
Aadd(aCores1,{"br_vermelho_ocean", STR0030  }) //"Pacote Falhou"

// Cores dos status das acoes
Aadd(aCores2,{"br_verde_ocean"   , STR0031  }) //"Ação Em Liberação"
Aadd(aCores2,{"br_amarelo_ocean" , STR0032  }) //"Ação Aguardando Execução"
Aadd(aCores2,{"br_azul_ocean"    , STR0033  }) //"Ação Executada"
Aadd(aCores2,{"br_vermelho_ocean", STR0034  }) //"Ação Falhou"

// Botao na EnchoiceBar que apresenta legendas dos pacotes e das acoes
AAdd(aButtons, {"NOTE" , {|| MontaLeg(STR0035,aCores1, aCores2)}, STR0036 }) //"Legendas Pacotes x Ações"###"Legenda Pacote x Ação"

//Desenha a tela
oDlgLote := TDialog():New(000,000,aCoordenadas[6],aCoordenadas[5],OemToAnsi(STR0037),,,,,,,,oMainWnd,.T.) //"Painel de Gestão da Precificação"
oTree := DbTree():New(014,001,oDlgLote:nClientHeight/2-30,oDlgLote:nClientWidth/6.5,oDlgLote,{|| MontaTree(oTree,2,@aListPacotes,@oListPacotes,@oListAcoes,@aListAcoes) },,.T.,)
oTree:AddTree(STR0038+MBE->MBE_CODIGO+Space(50),.T.,"FOLDER5","FOLDER6",,,Replicate("X",50)) //"Pacote(s) do Lote: "
oTree:EndTree()

//Carrega as informacoes do LOTE
LJMsgRun(STR0039,STR0040,{|| MontaTree(@oTree) }) //"Aguarde, localizando pacotes do lote..."###"Aguarde..."

// Monta folder e carrega listbox dos pacotes
oFolder1 := TFolder():New(014,oDlgLote:nClientWidth/6.5+3,{STR0041},,oDlgLote,,,,.T.,.F.,oDlgLote:nClientWidth/2-(oDlgLote:nClientWidth/6.5+10),oDlgLote:nClientHeight/4-11) //"Detalhes dos Pacotes"
oListPacotes := TWBrowse():New(001,001,oFolder1:aDialogs[1]:nClientWidth/2-5,oFolder1:aDialogs[1]:nClientHeight/2-5,,{"",STR0042},,oFolder1:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Data da Criação "
oListPacotes:SetArray(aListPacotes)
oListPacotes:bLine := {||{	aListPacotes[oListPacotes:nAt][1],;
aListPacotes[oListPacotes:nAt][2]}}
oListPacotes:bChange   := {|| MontaTree(oTree,3,aListPacotes,oListPacotes,@oListAcoes,@aListAcoes) }
oListPacotes:bGotFocus := {|| MontaTree(oTree,3,aListPacotes,oListPacotes,@oListAcoes,@aListAcoes) }

// Monta folder e carrega listbox das acoes
oFolder2 := TFolder():New(oDlgLote:nClientHeight/4+5,oDlgLote:nClientWidth/6.5+3,{STR0043},,oDlgLote,,,,.T.,.F.,oDlgLote:nClientWidth/2-(oDlgLote:nClientWidth/6.5+10),oDlgLote:nClientHeight/2-(oDlgLote:nClientHeight/4+35)) //"Ações do Pacote"
oListAcoes := TWBrowse():New(001,001,oFolder2:aDialogs[1]:nClientWidth/2-5,oFolder2:aDialogs[1]:nClientHeight/2-5,,{"",STR0044,STR0045,STR0046,STR0047,STR0048,STR0049,"Filial",STR0050},,oFolder2:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Status"###"Tipo de Ação"###"Data do Lote"###"Data da Execução"###"Hora"###"Usuário"###"Codigo"
oListAcoes:SetArray(aListAcoes)
oListAcoes:bLine := {||{	aListAcoes[oListAcoes:nAt][1],;
aListAcoes[oListAcoes:nAt][2],;
aListAcoes[oListAcoes:nAt][7],;
aListAcoes[oListAcoes:nAt][8],;
aListAcoes[oListAcoes:nAt][3],;
aListAcoes[oListAcoes:nAt][4],;
aListAcoes[oListAcoes:nAt][5],;
aListAcoes[oListAcoes:nAt][9],;
aListAcoes[oListAcoes:nAt][6] }}

EnchoiceBar(oDlgLote,{|| nOpcClick := 1, oDlgLote:End() },{|| oDlgLote:End()},,@aButtons)
oDlgLote:Activate(,,,.T.)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LJ302Lib º Autor ³   Vendas Clientes  º Data ³  15/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Botao responsavel pela liberacao do lote e emissao de      º±±
±±º          ³ Etiquetas.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ302Lib()

Local cNumLote  := ""  // Variavel que armazena o numero do lote
Local cTipoImp  := ""  // Variavel que armazena o tipo de impressao (normal, antecipada ou job)
Local oPainel := Nil   // Objeto a ser instanciado pela classe

oPainel := PainelPrecificacao():New()   //Instancia objeto

If MBE->MBE_STATUS <= "2"  .and. ((date()+1) <= MBE->MBE_DATA) // Lote em aberto
	
	If MsgYesNo(STR0051) //"Deseja efetuar a Liberação do Lote?"
		cNumLote := MBE->MBE_CODIGO
		cTipoImp := "N"
		
		Begin transaction
		LJMsgRun(STR0052,STR0040,{|| oPainel:Lj3ImpEtiquetas(cNumLote,cTipoImp) }) //"Aguarde, efetuando a gravação dos dados das etiquetas..."###"Aguarde..."
		End Transaction
	EndIf
	
Else
	msginfo(STR0053+STR0068+STR0054) //"Somente lote '###' poderá ter seu status alterado por esta funcionalidade." //'Em Liberação'
EndIf

RETURN .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LJ302Imp ºAutor  ³ Vendas Clientes    º Data ³  16/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcionalidade que efetua a liberacao antecipada.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ302Imp() 

Local cNumLote  := ""     // Variavel que armazena o numero do lote
Local cTipoImp  := ""     // Variavel que armazena o tipo de impressao (normal, antecipada ou job)
Local oPainel := Nil      // Objeto a ser instanciado pela classe

oPainel := PainelPrecificacao():New()  // Instancia objeto

If (MBE->MBE_DATA > date()+1)    // Libera Impressao antecipada somente ateh dois antes da data de vigencia do lote
	
	If MsgYesNo(STR0055) //"Deseja efetuar a Impressão Antecipada de Etiquetas?"
		
		cNumLote := MBE->MBE_CODIGO
		Dbselectarea("MBE")
		Dbsetorder(1)
		If DbSeek(xFilial("MBE")+alltrim(cNumLote))
			
			If MBE->MBE_STATUS == "1"
				cNumLote := MBE->MBE_CODIGO
				cTipoImp := "A"
				
				Begin transaction
				LJMsgRun(STR0052,STR0040,{|| oPainel:Lj3ImpEtiquetas(cNumLote,cTipoImp) }) //"Aguarde, efetuando a gravação dos dados das etiquetas..."###"Aguarde..."
				End transaction
				
			Else
				msginfo(STR0056+STR0068+STR0057) //"Somente lotes '###' poderão ser efetuadas liberações antecipadas." //'Em Liberação'
			EndIf
			
		EndIf
		
	EndIf
Else
	msginfo(STR0058,STR0059) //"Impressão não pode ser efetuada devido a data de geração ser maior que a data do lote. Apenas a até dois dias antes da data de vigência poderá ser feita a impressão antecipada."###"DATA DO DIA MAIOR QUE A VIGENCIA"
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LJ302Leg  ºAutor  ³  Vendas Clientes   º Data ³  17/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Legenda do Browse                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ302Leg()  

Local aLegenda := {}

aAdd(aLegenda, {'BR_VERDE'		,STR0060}) //"Lote em Aberto"
aAdd(aLegenda, {'BR_AMARELO'	,STR0061}) //"Aberto/Imp. Atencipada"
aAdd(aLegenda, {'BR_AZUL'    	,STR0018}) //"Liberado"
aAdd(aLegenda, {'BR_PRETO'		,STR0019}) //"Executado"
aAdd(aLegenda, {'BR_VERMELHO' 	,STR0020}) //"Falhou"

BrwLegenda(cCadastro, STR0007, aLegenda) //"Legenda"

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MontaTree ºAutor  ³ Vendas Clientes    º Data ³  17/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Visualizacao do LOTE                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaTree(oTree,nOpcao,aListPacotes,oListPacotes,;
oListAcoes,aListAcoes)                                            

Local aLegenda1 := StrToKarr(Posicione("SX3",2,"MB9_STATUS","SX3->X3_CBOX"),";")
Local aLegenda2 := StrToKarr(Posicione("SX3",2,"MBA_STATUS","SX3->X3_CBOX"),";")
Local aCores1    := {}
Local aCores2    := {}

Default nOpcao := 1

Aadd(aCores1,"br_verde_ocean") 		// Pacote Em Liberacao
Aadd(aCores1,"br_amarelo_ocean")  	// Pacote Aguardando Execucao
Aadd(aCores1,"br_cinza_ocean")	    // Pacote Executado Parcialmente
Aadd(aCores1,"br_azul_ocean")     	// Pacote Executado
Aadd(aCores1,"br_vermelho_ocean")  	// Pacote Falhou

Aadd(aCores2,"br_verde_ocean")		// Acao Em Liberacao
Aadd(aCores2,"br_amarelo_ocean")   	// Acao Aguardando Execucao
Aadd(aCores2,"br_azul_ocean")		// Acao Executado
Aadd(aCores2,"br_vermelho_ocean")	// Acao Falhou

//Busca os Pacotes do Lote
If nOpcao == 1
	DbSelectArea("MB9")
	MB9->(DbSetOrder(1))
	MB9->(DbSeek(xFilial("MB9")+MBE->MBE_CODIGO ))
	
	While MB9->(!Eof()) .And. MB9->MB9_FILIAL + MB9->MB9_BECOD == xFilial("MB9")+MBE->MBE_CODIGO
		If !oTree:TreeSeek("MB9_"+MB9->MB9_BBCOD)
			oTree:TreeSeek(Replicate("X",50))
			oTree:AddItem(STR0062 + AllTrim(MB9->MB9_BBCOD) + "-" + Posicione("MBB",1,xFilial("MBB")+MB9->MB9_BBCOD,"MBB->MBB_DESC") ,"MB9_"+MB9->MB9_BBCOD,"FOLDER5","FOLDER6",,,2) //"Tipo de Pacote: "
		EndIf
		MB9->(DbSkip())
	End
	
	oTree:Refresh()
	
	
ElseIf nOpcao == 2 .And. AllTrim(oTree:GetCargo()) <> Replicate("X",50)  	//Busca os PACOTES e as ACOES do tipo selecionado no TREE
	aListPacotes := {}
	DbSelectArea("MB9")
	MB9->(DbSetOrder(1))
	MB9->(DbSeek(xFilial("MB9")+MBE->MBE_CODIGO+AllTrim(SubStr(oTree:GetCargo(),5)) ))
	While MB9->(!Eof()) .And. MB9->MB9_FILIAL + MB9->MB9_BECOD + AllTrim(MB9->MB9_BBCOD) == xFilial("MB9")+MBE->MBE_CODIGO+AllTrim(SubStr(oTree:GetCargo(),5))
		
		AAdd(aListPacotes,{	LoadBitmap( GetResources(),aCores1[Val(MB9->MB9_STATUS)]),;
		MB9->MB9_DATA,;
		MB9->MB9_ID })
		//	substr(aLegenda1[Val(MB9->MB9_STATUS)],3,20) ,;
		
		MB9->(DbSkip())
	End
	
	If Len(aListPacotes) <= 0
		aListPacotes := {{LoadBitmap( GetResources(),"br_branco"),CToD("  /  /  "),""}}
	EndIf
	
	//Atualiza o ListBox
	oListPacotes:SetArray(aListPacotes)
	oListPacotes:bLine := {||{	aListPacotes[oListPacotes:nAt][1],;
	aListPacotes[oListPacotes:nAt][2] }}
	oListPacotes:Refresh()
	
	aListAcoes := {}
	
	If Len(aListAcoes) <= 0
		aListAcoes   := {{LoadBitmap( GetResources(),"br_branco"),"","",CToD("  /  /  "),CToD("  /  /  "),"","","",""}}
	EndIf
	
	oListAcoes:SetArray(aListAcoes)
	oListAcoes:bLine := {||{	aListAcoes[oListAcoes:nAt][1],;
	aListAcoes[oListAcoes:nAt][2],;
	aListAcoes[oListAcoes:nAt][7],;
	aListAcoes[oListAcoes:nAt][8],;
	aListAcoes[oListAcoes:nAt][3],;
	aListAcoes[oListAcoes:nAt][4],;
	aListAcoes[oListAcoes:nAt][5],;
	aListAcoes[oListAcoes:nAt][9],;
	aListAcoes[oListAcoes:nAt][6] }}
	oListAcoes:Refresh()
	
	
ElseIf nOpcao == 3 	//Carrega as Acoes e seus respectivos STATUS de cada pacote posicionado
	aListAcoes := {}
	
	DbSelectArea("MBA")
	MBA->(DbSetOrder(2))
	MBA->(DbSeek(xFilial("MBA")+MBE->MBE_CODIGO+aListPacotes[oListPacotes:nAt,3] ))
	While MBA->(!Eof()) .And. MBA->MBA_FILIAL + MBA->MBA_BECOD + MBA->MBA_ID == xFilial("MBA")+MBE->MBE_CODIGO+aListPacotes[oListPacotes:nAt,3]
		Aadd(aListAcoes,{	LoadBitmap( GetResources(),aCores2[Val(MBA->MBA_STATUS)]) ,;
		substr(aLegenda2[Val(MBA->MBA_STATUS)],3,20) ,;
		MBA->MBA_DATA,;
		MBA->MBA_HORA,;
		MBA->MBA_USBAIX,;
		IIf(MBA->MBA_BBCOD == PACOTE_PRODUTO,MBA->MBA_CODPRO,IIf(MBA->MBA_BBCOD == PACOTE_PRECO,MBA->MBA_CODTAB,MBA->MBA_CODREG)),;
		Posicione("MBD",1,xFilial("MBD")+MBA->MBA_BDCOD,"MBD->MBD_DESC" ),;
		MBA->MBA_DTPAC ,;
		IIf(MBA->MBA_BBCOD == PACOTE_PRODUTO,MBA->MBA_FILPRO,IIf(MBA->MBA_BBCOD == PACOTE_PRECO,MBA->MBA_FILTAB,MBA->MBA_FILREG))})

		MBA->(DbSkip())
	End
	
	If Len(aListAcoes) <= 0
		aListAcoes   := {{LoadBitmap( GetResources(),"br_branco"),"","",CToD("  /  /  "),CToD("  /  /  "),"","","",""}}
	EndIf
	
	oListAcoes:SetArray(aListAcoes)
	oListAcoes:bLine := {||{	aListAcoes[oListAcoes:nAt][1],;
	aListAcoes[oListAcoes:nAt][2],;
	aListAcoes[oListAcoes:nAt][7],;
	aListAcoes[oListAcoes:nAt][8],;
	aListAcoes[oListAcoes:nAt][3],;
	aListAcoes[oListAcoes:nAt][4],;
	aListAcoes[oListAcoes:nAt][5],;
	aListAcoes[oListAcoes:nAt][9],;
	aListAcoes[oListAcoes:nAt][6] }}
	oListAcoes:Refresh()
EndIf

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³	MontaLeg   ³Autor ³   Vendas Clientes   ³ Data ³ 21/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Janela contendo duas legendas de cores para Painel de Gestao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MontaLeg(cTitulo,aCores,aCores2).	                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cTitulo    :Titulo da Janela                                ³±±
±±³          ³aCores1    :Array contendo as cores dos pacotes             ³±±
±±³          ³aCores2    :Array contendo as cores das acoes               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION MontaLeg(cTitulo,aCores1, aCores2) 

Local nY       := 0
Local nX       := 0
Local aBmp[Len(aCores1)]
Local aBmp2[Len(aCores2)]
Local aSays[Len(aCores1)]
Local aSays2[Len(aCores2)]
Local oDlgLeg
Local nXSize 	:= 14

DEFINE MSDIALOG oDlgLeg FROM 0,0 TO ((Len(aCores1)+Len(aCores2))*25)+50,304 TITLE cTitulo  PIXEL

oDlgLeg:bLClicked:= {||oDlgLeg:End()}

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

@ 0, 0 BITMAP oBmp RESNAME "PROJETOAP" oF oDlgLeg SIZE 35,155 NOBORDER WHEN .F. PIXEL
@ 11 ,35  TO 13 ,400 LABEL '' OF oDlgLeg PIXEL
@ 3  ,37  SAY STR0063 Of oDlgLeg PIXEL SIZE 35 ,9 FONT oBold //"Pacotes"

For nX := 1 to Len(aCores1)
	@ 19+((nX-1)*10),44 BITMAP aBmp[nX] RESNAME aCores1[nX][1] of oDlgLeg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 19+((nX-1)*10),(nXSize/2) + 47 SAY If((nY+=1) == nY,aCores1[nY][2]+If(nY==Len(aCores1),If((nY:=0)==nY,"",""),""),"") of oDlgLeg PIXEL
Next nX
nY := 0

@ 81 ,35  TO 83 ,400 LABEL '' OF oDlgLeg PIXEL
@ 73  ,37  SAY STR0064 Of oDlgLeg PIXEL SIZE 35 ,9 FONT oBold //"Ações"

For nX := 1 to Len(aCores2)
	@ 89+((nx-1)*10),44 BITMAP aBmp2[nx] RESNAME aCores2[nx][1] of oDlgLeg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 89+((nx-1)*10),(nXSize/2) + 47 SAY If((nY+=1) == nY,aCores2[nY][2]+If(nY==Len(aCores2),If((nY:=0)==nY,"",""),""),"") of oDlgLeg PIXEL
Next nX
nY := 0

ACTIVATE MSDIALOG oDlgLeg CENTERED

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ302Filterº Autor ³   Vendas Clientes  º Data ³  28/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Filtro realizado de acordo com as opcoes escolhidas pelo    º±±
±±º          ³ usuario.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION LJ302Filter()  

Local cSAUWhile := ""            // Variavel utilizada no while para varrer tabela SAU
Local cFilter 	:= ""            // Variavel utilizada para armazenar o conteudo da query
Local lCondicao	:= .F.           // Variavel logica que controla qual o primeiro filtro informado pelo usuario

If !EMPTY(MV_PAR01) .or. !EMPTY(MV_PAR02)
	cFilter += " ( MBE->MBE_FILIAL >= '"+(MV_PAR01)+"' .and. MBE->MBE_FILIAL <= '"+(MV_PAR02)+"' )"
	lCondicao := .T.
EndIf

// Adiciona as filias que tiverem listadas no Grupo de Filiais informado
If !EMPTY(MV_PAR03)
	Dbselectarea("SAU")
	Dbsetorder(1)
	If DbSeek(xFilial("SAU")+MV_PAR03)
		cSAUWhile := xFilial("SAU")+MV_PAR03
		While cSAUWhile == SAU->AU_FILIAL+SAU->AU_CODGRUP
			If lCondicao
				cFilter += " .OR. "
			Else               
				cFilter += " ( "
			EndIf
			cFilter += " MBE->MBE_FILIAL == '"+(SAU->AU_CODFIL)+"' "
			lCondicao := .T.
			SAU->(Dbskip())
		End
		cFilter += " ) "
	EndIf
EndIf

If !EMPTY(MV_PAR04) .or. !EMPTY(MV_PAR05)
	If lCondicao
		cFilter += " .and. "
	EndIf
	cFilter += " ( MBE->MBE_CODIGO >= '"+(MV_PAR04)+"' .and. MBE->MBE_CODIGO <= '"+(MV_PAR05)+"' ) "
	lCondicao := .T.
EndIf

If !EMPTY(MV_PAR06) .or. !EMPTY(MV_PAR07)
	If lCondicao
		cFilter += " .and. "
	EndIf
	cFilter += " ( DTOS(MBE->MBE_DATA) >= '"+DTOS(MV_PAR06)+"' .and. DTOS(MBE->MBE_DATA) <= '"+DTOS(MV_PAR07)+"' ) "
	lCondicao := .T.
EndIf

If !EMPTY(MV_PAR08)
	If lCondicao
		cFilter += " .and. "
	EndIf
	cFilter += " MBE->MBE_STATUS == '"+alltrim(str(MV_PAR08))+"' "
EndIf

return cFilter


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LJ302CAN º Autor ³   Vendas Clientes  º Data ³  03/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcionalidade que cancela a impressao antecipada retornan-º±±
±±º          ³ do o status do lote para 'Em Aberto'.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ302CAN()

Local cNumLote  := ""   // Variavel que armazena o numero do lote
Local oPainel := Nil    // Variavel que instacia o objeto

oPainel := PainelPrecificacao():New()

If MBE->MBE_STATUS == "2"
	
	If MsgYesNo(STR0065) //"Deseja efetuar o cancelamento da impressão antecipada do Lote?"

		cNumLote := MBE->MBE_CODIGO
		
		Begin transaction
		LJMsgRun(STR0066,STR0040,{|| oPainel:Lj3CancImpEtiquetas(cNumLote) }) //"Aguarde, efetuando o cancelamento das etiquetas..."###"Aguarde..."
		End transaction

	EndIf
	
Else
	msginfo(STR0067+STR0069+STR0054) //"Somente lote com status '###' poderá ter seu status alterado por esta funcionalidade." //'Impressão Antecipada'
EndIf

RETURN .T.
