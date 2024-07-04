#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA502.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FATA502  ³ Autor ³ Vendas CRM            ³ Data ³           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Baixa dos Orcamentos de Venda  Ref(MATA416)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void FATA502(void)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FATA502( xStatus )

Local lGerar   		:= .F.
Local lContinua		:=.F.
Local cAlias   		:= Alias()
Local nOps     		:= 0
Local nOpc     		:= 0
Local nX       		:= 0
Local nCntFor  		:= 0
Local nMaxFor  		:= 0
Local aCores 		:= {	{ 'SCJ->CJ_STATUS=="A"'	, 'ENABLE' 		},;
							{ 'SCJ->CJ_STATUS=="B"'	, 'DISABLE'		},;
							{ 'SCJ->CJ_STATUS=="C"'	, 'BR_PRETO'	},;
							{ 'SCJ->CJ_STATUS=="D"'	, 'BR_AMARELO'	},;
							{ 'SCJ->CJ_STATUS=="U"'	, 'BR_AZUL'		},;
							{ 'SCJ->CJ_STATUS=="T"'	, 'BR_CINZA'		},;
							{ 'SCJ->CJ_STATUS=="F"'	, 'BR_MARROM'	}}
					
Local xAutoCab		:= Nil	
Local xAutoItens	:= Nil
Local cFiltroSCJ	:= ""					
					
PRIVATE aHeadC6		:= {}
PRIVATE aHeadD4		:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas na geracao de SCS aglutinadas por data  ³
//³ de necessidade.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aDataOPC1 	:= {}
PRIVATE aDataOPC7 	:= {}
PRIVATE aOPC1     	:= {}
PRIVATE aOPC7     	:= {}
PRIVATE lEnd      	:= .F.
PRIVATE INCLUI    	:= .T.
PRIVATE lMTA650I  	:= (ExistBlock( "MTA650I" ) )
PRIVATE lMT650C1 	:= (ExistBlock( "MT650C1" ) )
PRIVATE lM650EmpT	:= (ExistTemplate( "EMP650"  ) ) 
PRIVATE lM650Emp  	:= (ExistBlock( "EMP650"  ) )
PRIVATE cPedido   	:= ""
PRIVATE cItemPV   	:= ""
PRIVATE cCadastro 	:= STR0001 //"Baixa de Propostas"
PRIVATE l416Auto  	:= ( xAutoCab <> NIL  .and. xAutoItens <> NIL )
PRIVATE aAutoCab  	:= {}
PRIVATE aAutoItens	:= {}
PRIVATE aValidGet 	:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para integracao com programa MATA650    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aSav650	 	:= Array(20)
PRIVATE lConsTerc
PRIVATE lConsNPT
PRIVATE aRotina 	:= MenuDef()
PRIVATE cStatus		:= xStatus

DEFAULT cStatus		:= "A"		

If ExistBlock("MATA416A")
	ExecBlock("MATA416A",.F.,.F.)
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 Mostra Ordem de Producao   ? Sim/Nao        ³
//³ mv_par02 Mostra Empenho do PV.      ? Sim/Nao        ³
//³ mv_par03 Gera PV s/ SugestÆo        ? Sim/Nao        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F-10 para parametros                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("MTA416",.F.)
If !(l416Auto)
	SetKey( VK_F12 , {|| Pergunte("MTA416",.T.) } )
EndIf

DbSelectArea("SCJ")

If IsInCallStack("FATA320")
	If ADL->ADL_ENTIDA == "SUS"
		cFiltroSCJ := "CJ_PROSPE = '" + ADL->ADL_CODENT + "' .AND. CJ_LOJPRO = '" + ADL->ADL_LOJENT + "'"
	ElseIf ADL->ADL_ENTIDA == "SA1"
		cFiltroSCJ := "CJ_CLIENTE = '" + ADL->ADL_CODENT + "' .AND. CJ_LOJA = '" + ADL->ADL_LOJENT + "'"
	EndIf      
	If !Empty(cFiltroSCJ)
		dbSetFilter({|| &cFiltroSCJ}, cFiltroSCJ)
	EndIf
EndIf

If Empty(SCJ->(DbFilter()))
	cFiltroSCJ := "SCJ->CJ_STATUS == '" + cStatus + "'"
Else
	cFiltroSCJ := SCJ->(DbFilter()) + " .AND. SCJ->CJ_STATUS == '" + cStatus + "' "
EndIf

If Len(cFiltroSCJ) >= 2000
	cFiltroSCJ := "SCJ->CJ_STATUS == '" + cStatus + "'"
EndIf

If !Empty(cFiltroSCJ)
	dbSetFilter({|| &cFiltroSCJ}, cFiltroSCJ)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader do SC6                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeadC6 := {}
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SC6",.T.)
While ( !Eof() .And. (SX3->X3_ARQUIVO == "SC6") )
	If (  ((X3Uso(SX3->X3_USADO) .And. ;
			!( Trim(SX3->X3_CAMPO) == "C6_NUM" ) .And.;
			Trim(SX3->X3_CAMPO) != "C6_QTDEMP"  .And.;
			Trim(SX3->X3_CAMPO) != "C6_QTDENT") .And.;
			cNivel >= SX3->X3_NIVEL) .Or.;
			Trim(SX3->X3_CAMPO)=="C6_NUMORC" .Or. ;
			Trim(SX3->X3_CAMPO)=="C6_NUMOP"  .Or. ;
			Trim(SX3->X3_CAMPO)=="C6_ITEMOP" .Or. ;
			Trim(SX3->X3_CAMPO)=="C6_OP" .Or. ;
			Trim(SX3->X3_CAMPO)=="C6_OPC" )	
		Aadd(aHeadC6,{TRIM(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			If(Trim(SX3->X3_CAMPO)=="C6_NUMORC",".F.",SX3->X3_VALID),;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader do SD4                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SD4")
While ( !Eof() .And. SX3->X3_ARQUIVO == "SD4" )
	If ( X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		Aadd(aHeadD4,{ Trim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT })
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo
dbSelectArea("ABI")
dbSelectArea("SCJ")
dbSetOrder(1)
If (l416Auto)
	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens
	MBrowseAuto(4,Aclone(aAutoCab),"SCJ")
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para alterar cores do Browse do Cadastro    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("MA416COR")
		aCores := ExecBlock("MA416COR",.F.,.F.,aCores)
	EndIf
	MsSeek(xFilial("SCJ"))
	mBrowse( 6, 1,22,75,"SCJ",,,,,,aCores)
EndIf
INCLUI := .F. // For‡ado para compatibilizacao
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe SC's ou OP's para serem geradas           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey( VK_F12 , Nil )
Pergunte("MTA650",.F.)
//Salvar variaveis existentes
For nx := 1 to 20
	aSav650[nx] := &("mv_par"+StrZero(nx,2))
Next nx
lConsNPT  := (aSav650[14] == 1)
lConsTerc := !(aSav650[15] == 1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera SC's aglutinadas por OP.                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( aSav650[06] == 2 )
	nMaxFor  := Len(aOPC1)
	For nCntFor := 1 to nMaxFor
		A650GravC1(	aOPC1[nCntFor,1],aOPC1[nCntFor,2],aOPC1[nCntFor,3],;
			aOPC1[nCntFor,4],aOPC1[nCntFor,5],aOPC1[nCntFor,6],;
			aOPC1[nCntFor,7],aOPC1[nCntFor,8],aOPC1[nCntFor,9],;
			aOPC1[nCntFor,10])
	Next nCntFor
	nMaxFor  := Len(aOPC7)
	For nCntFor := 1 to nMaxFor
		A650GravC7(	aOPC7[nCntFor,1],aOPC7[nCntFor,2],aOPC7[nCntFor,3],;
			aOPC7[nCntFor,4],aOPC7[nCntFor,5],aOPC7[nCntFor,6],;
			aOPC7[nCntFor,7])
	Next nCntFor
ElseIf ( aSav650[06] == 3 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera SC's aglutinadas por data de Necessidade.               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nMaxFor := Len(aDataOPC1)
	For nCntFor := 1 to nMaxFor
		A650GravC1(	aDataOPC1[nCntFor,1],aDataOPC1[nCntFor,2],;
			aDataOPC1[nCntFor,3],aDataOPC1[nCntFor,4],;
			aDataOPC1[nCntFor,5],aDataOPC1[nCntFor,6],;
			aDataOPC1[nCntFor,7],aDataOPC1[nCntFor,8],;
			aDataOPC1[nCntFor,9],aDataOPC1[nCntFor,10])
	Next nCntFor
	nMaxFor := Len(aDataOPC7)
	For nCntFor := 1 to nMaxFor
		A650GravC7(	aDataOPC7[nCntFor,1],aDataOPC7[nCntFor,2],;
			aDataOPC7[nCntFor,3],aDataOPC7[nCntFor,4],;
			aDataOPC7[nCntFor,5],aDataOPC7[nCntFor,6],;
			aDataOPC7[nCntFor,7])
	Next nCntFor
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe OP's Intermediarias para geracao          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua:= .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Numero de Registros a Processar                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua
		a650RegOPI(@lGerar, @nOps, Funname())		
	Else
		dbSelectArea("BAT")
		dbSetOrder(2)
		While !Eof()
			If ( Empty(BAT->OK) .And. BAT->OR == "S" )
				lGerar := .T.
				nOps++
			EndIf
			dbSkip()
		End
	EndIf
	If ( lGerar )
		MTA650OK(@nOpc)
		If ( nOpc == 1 )
			Processa({|lEnd| MA650Process(@lEnd,nOps,.T.)},STR0005,STR0006,.F.)   //"Gera‡„o de OPs Intermediarias e SCs"###"Gerando OPs Intermediarias e SCs..."
		EndIf
	EndIf
	dbSelectArea("BAT")
	dbCloseArea()
Endif

dbSelectArea("SCJ")
dbClearFilter()

dbSelectArea(cAlias)
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Vendas CRM            ³ Data ³01/09/2006³±±
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
               
Private aRotina := {	{ STR0002,"AxPesqui"	, 0 , 1 , 0 , .F.},;	//"Pesquisar"
						{ STR0003,"A502Desbl"	, 0 , 2 , 0 , NIL},;	//"Desbloquear" 
						{ STR0004,"A502Legend"	, 0 , 2 }}   			//"Legenda"

Return(aRotina)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A502Legend³Autor  ³ Vendas CRM            ³ Data ³08/09/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina monta uma dialog com a descricao das cores da    ³±±
±±³          ³Mbrowse.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A502Legend()

Local aCores := {	{ 'ENABLE'    , STR0007 },; //'Orcamento em Aberto'
					{ 'DISABLE'   , STR0008 },; //'Orcamento Baixado'
					{ 'BR_PRETO'  , STR0009 },; //'Orcamento Cancelado' 	
					{ 'BR_AMARELO', STR0010 },; //'Orcamento nao Orcado'
					{ 'BR_AZUL'   , STR0011 },; // 'Orcamento aprovado'
					{ 'BR_CINZA'  , STR0012 },; // 'Orcamento aprovado'
					{ 'BR_MARROM' , STR0013 }}	//"Orcamento bloqueado"
					
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para alterar cores da legenda    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MA415LEG")
	aCores := ExecBlock("MA415LEG",.F.,.F.,aCores)
Endif
					
BrwLegenda(cCadastro,STR0014,aCores )   //"Pedido Liberado"
	
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A502LiberaºAutor  ³Vendas CRM          º Data ³  22/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Liberacao do orcamento com bloqueio de regra de negocio     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATA416/MATA415                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A502Libera(cAlias,nReg,nOpcx,oDlg)

Local aArea		:= GetArea()							// Armazena o posicionamento atual
Local aAreaSA3	:= SA3->(GetArea())						// Armazena o posicionamento da SA3
Local aAreaACA	:= ACA->(GetArea())						// Armazena o posicionamento da ACA
Local lContinua	:= .T.									// Controla a execucao da rotina
Local cCodUsr	:= __cUserId             				// Codigo do usuario logado
Local lFT502Lib := (ExistBlock( "FT502Lib"  ) )			// Ponto de entrada na liberacao da proposta
Local aRecOrc	:= {}									// Registros do Orcamento a serem desbloqueados
Local cProposta	:= ""									// Numero da proposta
Local cFilSCJ	:= xFilial("SCJ")						// Filial dos orcamentos
Local nX		:= 0									// Contador de loop
Local lFT502Fat	:= (ExistBlock( "FT502Fat"  ) )			// Ponto de entrada utilizado para tratar a liberacao do orcamento pelo faturamento
Local cFiltro	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se eh pela workarea³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IsInCallStack("FATA320")
	SA3->(DbSetOrder(7))//A3_FILIAL+A3_CODUSR
	ACA->(DbSetOrder(1))//ACA_FILIAL+ACA_GRPREP
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Localiza o grupo do representante e valida sua permissao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If 	SA3->(DbSeek(xFilial("SA3")+cCodUsr)) .AND.;
		ACA->(DbSeek(xFilial("ACA")+SA3->A3_GRPREP))	
		If ACA->ACA_LIBORC <> "1"
			lContinua := .F.
			MsgInfo(STR0015) //"Usuário sem permissão para liberar a proposta"
		EndIf		
	Else 
		lContinua	:= .F.
		MsgInfo(STR0017) //"Seu usuário não está associado a nenhum vendedor."
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Libera os orcamentos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua
	
	DbSelectArea("SCJ")
	DbGoTo(nReg)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o orcamento foi originado a partir de uma proposta, libera³
	//³todos os orcamentos                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SCJ->CJ_PROPOST)
		
		cProposta	:= SCJ->CJ_PROPOST
		
		SCJ->(DbSetOrder(4)) //CJ_FILIAL+CJ_PROPOST
		SCJ->(DbSeek(cFilSCJ+cProposta))
		
		While !SCJ->(Eof()) 			.AND.;
			SCJ->CJ_FILIAL == cFilSCJ 	.AND.;
			SCJ->CJ_PROPOST == cProposta			
			
			AAdd(aRecOrc,SCJ->(Recno()))								
			SCJ->(DbSkip())
			
		End
		
	Else                              
		AAdd(aRecOrc,SCJ->(Recno()))
	EndIf

	
	For nX := 1 to Len(aRecOrc) 
		SCJ->(DbGoTo(aRecOrc[nX]))   

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Este ponto de entrada foi criado para permitir a liberacao do orcamento somente³
		//³quando o faturamento conferir a proposta e dar o Ok para ser Faturado          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
		If lFT502Fat	
			ExecBlock("FT502Fat",.F.,.F.)	          
   		Endif
   		
   		DbSelectArea("SCJ")
   		
		If SCJ->CJ_STATUS == "F"
			RecLock("SCJ",.F.) 
			MaAvalOrc("SCJ",11)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Realiza a Baixa do Orcamento no Faturamento    ³
			//³Apenas para orcamento em Aberto(cfe. A415Baixa)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			If ( SCJ->CJ_STATUS == "A" )			
				cFiltro := SCJ->(dbFilter())
				//Limpa o filtro da tabela para fazer a baixa do orçamento
				If !Empty(cFiltro)
					dbSelectArea("SCJ")
					dbClearFilter()
				EndIf
				A502GrvBx()
				//Volta o filtro
				If !Empty(cFiltro)	  
					dbSelectArea("SCJ")
					Set Filter To &cFiltro
				EndIf				
			EndIf
			MsUnLock()		
		EndIf
			
	Next nX
      
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada ao final da liberacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFT502Lib
		ExecBlock("FT502Lib",.F.,.F.)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Encerra a tela da proposta³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oDlg <> Nil	 
		oDlg:End()
	EndIf
	
EndIf

RestArea(aAreaACA)
RestArea(aAreaSA3)
RestArea(aArea)

Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A502GrvBx ³ Autor ³ Vendas CRM            ³ Rev. ³30.11.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de interface da baixa manual dos orcamentos de venda  ³±±
±±³          ³Ref. MATA416                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo controlar a interface da baixa ³±±
±±³          ³manual do orcamento de venda                                 ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A502GrvBx()

Local aArea     := GetArea()
Local bSetKey   := SetKey(VK_F12,Nil)
Local lLibPv	 := .F. 
Local lMostraPV	:= SuperGetMV("MV_TKEXPV",,.F.)


If SuperGetMV("MV_ORCSLIB",,.F.)
	Pergunte("MTA410",.F.)
	lLibPV := MV_PAR01==1
EndIf

Pergunte("MTA416",.F.)

MaBxOrc(SCJ->CJ_NUM,MV_PAR01==1,MV_PAR02==1,MV_PAR03==1,lMostraPV,,,lLibPV)

SetKey(VK_F12,bSetKey)
RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A502Desbl ºAutor  ³Vendas CRM          º Data ³  04/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Aciona a tela para visualizacao do Orcamento/Proposta a ser º±±
±±º          ³aprovado ou reprovado                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATA416/MATA415                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A502Desbl(cAlias,nReg,nOpcx)

Local aArea		:= GetArea()
Local cFatProp	:= SuperGetMV("MV_FATPROP",,"O") //Indica se a oportunidade manipula orcamento ou propostas.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama a funcao p/ visualizacao da Proposta ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cFatProp == "P"
	DbSelectArea("ADY")
	DbSetOrder(1) //ADY_FILIAL+ADY_PROPOS
	If DbSeek(xFilial("ADY")+SCJ->CJ_PROPOST)
		FWExecView(Upper(STR0019),"VIEWDEF.FATA600",MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)
	EndIf 
Else
	A502Libera(cAlias,nReg,nOpcx)
EndIf

RestArea(aArea) 

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A416DesaprºAutor  ³Vendas CRM          º Data ³  22/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Reprovacao do orcamento com bloqueio de regra de negocio    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATA416/MATA415                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A502Desapr(cAlias,nReg,nOpcx,oDlg)
Local aArea    		:= GetArea()             					// Armazena o posicionamento atual
Local aAreaSA3    	:= SA3->(GetArea())                        // Armazena o posicionamento da SA3
Local aAreaACA   	:= ACA->(GetArea())                        // Armazena o posicionamento da ACA
Local aAreaAD1  	:= AD1->(GetArea())                        // Armazena o posicionamento da AD1
Local lContinua		:= .T.                                      // Controla a execucao da rotina
Local cCodUsr  		:= __cUserId                                // Codigo do usuario logado
Local lMT416Des 	:= (ExistBlock( "MT416Des"  ) )            // Ponto de entrada na desaprovacao da proposta
Local aRecOrc  		:= {}                                      // Registros do Orcamento a serem desbloqueados
Local cProposta 	:= ""                                      // Numero da proposta
Local cFilSCJ  		:= xFilial("SCJ")                          // Filial dos orcamentos
Local nX   			:= 0                               		  // Contador de loop

SA3->(DbSetOrder(7))//A3_FILIAL+A3_CODUSR
ACA->(DbSetOrder(1))//ACA_FILIAL+ACA_GRPREP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se eh pela workarea³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IsInCallStack("FATA320")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Localiza o grupo do representante e valida sua permissao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SA3->(DbSeek(xFilial("SA3")+cCodUsr)) .AND.;
			ACA->(DbSeek(xFilial("ACA")+SA3->A3_GRPREP))

  			If ACA->ACA_LIBORC <> "1"
               	lContinua := .F.
     			MsgInfo(STR0015)		//"Usuário sem permissão para liberar o orçamento"
        	EndIf
	Else 
			lContinua          := .F.
	  		MsgInfo(STR0017)				//"Seu usuário não está associado a nenhum vendedor."
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Desaprova os orcamentos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lContinua
	DbSelectArea("SCJ")
	DbGoTo(nReg)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o orcamento foi originado a partir de uma proposta, libera³
	//³todos os orcamentos                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SCJ->CJ_PROPOST)
		cProposta         := SCJ->CJ_PROPOST
		
		SCJ->(DbSetOrder(4)) //CJ_FILIAL+CJ_PROPOST
		SCJ->(DbSeek(cFilSCJ+cProposta))

		While !SCJ->(Eof())  .AND.;
    				SCJ->CJ_FILIAL == cFilSCJ      .AND.;
         			SCJ->CJ_PROPOST == cProposta                               

			AAdd(aRecOrc,SCJ->(Recno()))
			SCJ->(DbSkip())
		End

	Else
		AAdd(aRecOrc,SCJ->(Recno()))
	EndIf
	
	For nX := 1 to Len(aRecOrc) 
		SCJ->(DbGoTo(aRecOrc[nX]))
		
		If SCJ->CJ_STATUS == "T"
			RecLock("SCJ",.F.) 
			SCJ->CJ_STATUS := "A"
			SCJ->(MsUnLock())
			
			If ChkFile("ADY")
				DbSelectArea("ADY")
				DbSetOrder(1) //ADY_FILIAL+ADY_PROPOS
				If DbSeek(xFilial("ADY") + cProposta)
					RecLock("ADY",.F.)
					ADY->ADY_STATUS	:= "A"
					MsUnLock()
				EndIf
			EndIf
				
			DbSelectArea("AD1")
			DbSetOrder(1)
			If DbSeek(xFilial("AD1") + SCJ->CJ_NROPOR) .OR. !Empty(SCJ->CJ_NROPOR)
				RecLock("AD1",.F.) 
					AD1->AD1_STATUS := "1"
				AD1->(MsUnLock())
			Endif
		EndIf
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada ao final da liberacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMT416Des
		ExecBlock("MT416Des",.F.,.F.)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processo p/ Reprovacao de Orcamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ExecCRMPro("000009")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Encerra a tela da proposta³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If oDlg <> Nil	 
		oDlg:End()
	EndIf
	
EndIf

RestArea(aAreaAD1)
RestArea(aAreaACA)
RestArea(aAreaSA3)
RestArea(aArea)
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FATA502A ³ Autor ³ Vendas CRM            ³ Data ³           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Encapsulamento da funcao FATA502, para chamada via menu-XNU.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void FATA502a(void)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FATA502A()
FATA502( "F" )
Return Nil
