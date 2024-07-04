// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 19     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "PROTHEUS.CH"
#INCLUDE "VEIXX019.CH"

Static cPrefVEI := GetNewPar("MV_PREFVEI","VEI") // Modulo de Veiculos - Prefixo de Origem ( F2_PREFORI / E1_PREFORI )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXX019 ³ Autor ³ Andre Luis Almeida                ³ Data ³ 10/12/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manutencao do Atendimento de Veiculos Aprovado / Faturado              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos - VEIXA019 - Manut Atendimento                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX019(cAlias,nReg,nOpc)

Local cBotAtF7      := "1" // Imagem do Botao <F7> - Veiculos
Local cDirFotos     := GetNewPar("MV_DIRFTGC","")
Local aLogo         := {}

Local aBotEncX19    := {}
Local aObjects	    := {} // Objetos Principal da Tela
Local aObjEnchoice  := {} // Objetos Enchoice (VV9) e Gets alteracao
Local aObjInf       := {}
Local aObjLD        := {}
Local aObjVlrNeg    := {} // Objetos Valores de Negociacao
Local aObjVlrTNeg   := {} // Objetos Total Valores de Negociacao

Local aPOPri	    := {} // Divisao Principal da Tela
Local aPOEnc	    := {} // Parte da tela onde ficarao a Enchoice (VV9) e Gets alteracao
Local aPOInf        := {}
Local aPOLD         := {}                                                                           
Local aPOVlrNeg     := {} 
Local aPOVlrTVal    := {} 
Local aPOVlrTNeg    := {} 

Local aX19VS9       := {{},{}}
Local aX19VSE       := {{},{}}

Local aSizeAut	    := MsAdvSize(.t.)
Local nPos
Local nColBut       := 2  // Coluna para Criacao dos Botoes no Scroll de Valores de Negociacao
Local nColMSGet     := 74 // Coluna para Criacao dos Get's no Scroll de Valores de Negociacao
Local nAuxLinha     := 1

Local aTotVZ7       := {}
Local lCPagPad      := ( GetNewPar("MV_MIL0016","0") == "1" ) //Utiliza no Atendimento de Veículos, Condição de Pagamento da mesma forma que no Faturamento Padrão do ERP? (0=Não / 1= Sim) - Chamado CI 001985

Local cBotAten      := GetNewPar("MV_BOTATEN","111111") // Habilitar Botoes Padroes de Valores de Negociacao do Atendimento

Local cCpoAlt       := "" // Lista dos campos que poderão ser alterados 
Local aCpoAlt       := {} // Controla os Campos que poderão sofrer alteracoes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Matrizes de Parametros utilizadas nas chamadas dos VEIX's auxiliares ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aX19ParFin  := {0,"","","","","","","","","","","",0,0,{}}	// Financiamento FI / Leasing
Private aX19ParFna	:= {"","","","",""}								// Finame
Private aX19ParPro	:= {"",0,ctod(""),0,0,0,"0",0,0,"1111111111111"}	// Financiamento Proprio
Private aX19ParCon  := {""} 									   		// Consorcio
Private aX19ParUsa  := {""} 											// Veiculos Usados para Troca
Private aX19ParEnt  := {"",0} 											// Entradas
Private cVendAnt    := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Criacao/Controle das Enchoices ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cX19VV9nEdit  := ""	// Campos nao editaveis
Private cX19VV9Mostra := "VV9_NUMATE/VV9_NOMVIS/VV9_DATVIS/VV9_CODCLI/VV9_LOJA  /VV9_NUMNFI/VV9_SERNFI/"	// Campos VV9 a serem exibidos
Private aX19CpoVV9    := {} // ARRAY DE CAMPOS DA ENCHOICE

Private oDlgX19 	// Dialog Principal
Private oEncX19VV9	// Enchoice VV9

Private aX19CpoPar  := {}
Private aParTotal   := {}
Private aVSETotal   := {{},{}}
Private aMEMOVS9    := {}

Private aAuxHeader  := {}

Private nQtdTitulos := 0

Private oVlVeicu , nVlVeicu := 0 				// Get e Valor do Veiculo
Private oVlAtend , nVlAtend := 0 				// Get e Valor do Atendimento
Private oVlNegoc , nVlNegoc := 0 				// Get e Valor do Total Negociado
Private oVlDevol , oTitDevol , nVlDevol := 0 	// Get e Valor da Devolucao
Private oVlSaldo , oTitSaldo , nVlSaldo := 0 	// Get e Valor do Saldo Restante

Private overd := LoadBitmap( GetResources(), "BR_VERDE")    // Titulo sem manutencao
Private obran := LoadBitmap( GetResources(), "BR_BRANCO")   // Titulo Incluido
Private oazul := LoadBitmap( GetResources(), "BR_AZUL")     // Titulo Alterado
Private overm := LoadBitmap( GetResources(), "BR_VERMELHO") // Titulo Baixado
Private ocanc := LoadBitmap( GetResources(), "BR_CANCEL")   // Titulo Excluido

Private aVVAs := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botoes e Get's de Valores de Negociacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aX19ObjVlNeg := {}

If !lCPagPad // Padrão Veículos

	///////////////////////////
	// Financiamento/Leasing //
	///////////////////////////
	AADD(aX19ObjVlNeg, {'oX19BFinLea' , STR0002 , 'VX019BTVLN("1",4,@aX19ParFin,@aX19VS9,@aX19VSE)' , 71 , 11 , 'oVlFinanc' , 'nVlFinanc' , '@E 9,999,999.99' , 50 , 1 , '+' , ( substr(cBotAten,1,1) == "1" ) } ) // Financiamento/Leasing
	
	///////////////////////////
	// Finame                //
	///////////////////////////
	AADD(aX19ObjVlNeg, {'oX19BFiname' , STR0003 , 'VX019BTVLN("2",4,@aX19ParFna,@aX19VS9,)'         , 71 , 11 , 'oVlFiname' , 'nVlFiname' , '@E 9,999,999.99' , 50 , 1 , '+' , .f. /*( substr(cBotAten,2,1) == "1" )*/ } ) // Finame
	
	///////////////////////////
	// Financiamento Proprio //
	///////////////////////////
	AADD(aX19ObjVlNeg, {'oX19BFinPro' , STR0004 , 'VX019BTVLN("3",4,@aX19ParPro,@aX19VS9,)'         , 71 , 11 , 'oVlFinPro' , 'nVlFinPro' , '@E 9,999,999.99' , 50 , 1 , '+' , .f. /*( substr(cBotAten,3,1) == "1" )*/ } ) // Financiamento Proprio
	
	///////////////////////////
	// Consorcio             // 
	///////////////////////////
	AADD(aX19ObjVlNeg, {'oX19BConsor' , STR0005 , 'VX019BTVLN("4",4,@aX19ParCon,@aX19VS9,@aX19VSE)' , 71 , 11 , 'oVlConsor' , 'nVlConsor' , '@E 9,999,999.99' , 50 , 1 , '+' , ( substr(cBotAten,4,1) == "1" ) } ) // Consorcio
	
	///////////////////////////
	// Veiculo Usado         //
	///////////////////////////
	AADD(aX19ObjVlNeg, {'oX19BVeiUsa' , STR0006 , 'VX019BTVLN("5",4,@aX19ParUsa,@aX19VS9,)'         , 71 , 11 , 'oVlVeicUs' , 'nVlVeicUs' , '@E 9,999,999.99' , 50 , 1 , '+' , ( substr(cBotAten,5,1) == "1" ) } ) // Veiculo Usado
	
	///////////////////////////
	// Entradas              //
	///////////////////////////
	AADD(aX19ObjVlNeg, {'oX19BEntrad' , STR0007 , 'VX019BTVLN("6",4,@aX19ParEnt,@aX19VS9,@aX19VSE)' , 71 , 11 , 'oVlEntrad' , 'nVlEntrad' , '@E 9,999,999.99' , 50 , 1 , '+' , ( substr(cBotAten,6,1) == "1" ) } ) // Entradas
	
Else

	nVlFinanc := 0
	nVlFinPro := 0
	nVlFiname := 0
	nVlConsor := 0
	nVlVeicUs := 0
	///////////////////////////
	// Entradas              //
	///////////////////////////
	AADD(aX19ObjVlNeg, {'oX19BEntrad' , STR0007 , 'VX019BTVLN("6",4,@aX19ParEnt,@aX19VS9,@aX19VSE)' , 71 , 11 , 'oVlEntrad' , 'nVlEntrad' , '@E 9,999,999.99' , 50 , 1 , '+' , ( substr(cBotAten,6,1) == "1" ) } ) // Entradas

EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria e Inicializa Var. Private dos Botoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nPos := 1 to Len(aX19ObjVlNeg)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Get's de valores de negociacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aX19ObjVlNeg[nPos,6])
		SetPrvt(AllTrim(aX19ObjVlNeg[nPos,6]))
		SetPrvt(AllTrim(aX19ObjVlNeg[nPos,7]))
		&(AllTrim(aX19ObjVlNeg[nPos,7]) + ' := 0')
	EndIf
Next nPos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Botao na Enchoice referente ao Historico de Manutencao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aBotEncX19, {"FORM"     ,{|| VEIXX013(VV9->VV9_NUMATE,0) },STR0010} ) // Mapa de Avaliacao - Aprovacao
//AADD(aBotEncX19, {"PRODUTO",{|| VEIXC008(VV9->VV9_FILIAL,VV9->VV9_NUMATE) },STR0011} ) // FOLLOW-UP
cBotAtF7 := GetNewPar("MV_BOTATF7","1")
Do Case
	Case cBotAtF7 == "1" // Perua
		cBotAtF7 := "CARGA"
	Case cBotAtF7 == "2" // 2 Carros
		cBotAtF7 := "PAPIMG32.PNG"
	Case cBotAtF7 == "3" // Carro e Caminhao
		cBotAtF7 := "VEIIMG32.PNG"
	Case cBotAtF7 == "4" // Caminhao
		cBotAtF7 := "TMSIMG32.PNG"
	Case cBotAtF7 == "5" // Trator
		cBotAtF7 := "AGRIMG32.PNG"
	Case cBotAtF7 == "6" // Ambulancia
		cBotAtF7 := "HSPIMG32.PNG"
	Case cBotAtF7 == "7" // Empilhadeira
		cBotAtF7 := "EMPILHADEIRA"
	Case cBotAtF7 == "8" // Chave
		cBotAtF7 := "CHAVE2" 
EndCase
AADD(aBotEncX19, {cBotAtF7,{|| VX019VVA(aVVAs) },(STR0047)} ) // Veiculo(s)
AADD(aBotEncX19, {"HISTORIC" ,{|| VX019VMANUT(VV9->VV9_FILIAL,VV9->VV9_NUMATE) },STR0009} ) // Historico de Manutencao
AADD(aBotEncX19, {"PMSCOLOR", {|| VX019LEG() },(STR0008)} ) // Legenda 

VAI->(dbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis de Memoria para a VV9 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VV9")
dbSetOrder(1)
// Lista dos campos que poderão ser alterados //
cCpoAlt := "VV9_FILNEG/"
If VV9->VV9_STATUS == "L" .and. VAI->VAI_ATEOUT == "2" // Somente Atendimento Aprovado e Usuario pode Incluir/Alterar Atendimento de Outros Vendedores
	cCpoAlt += "VV0_CODVEN/"
EndIf
//
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV9")
While !Eof().and.(SX3->X3_ARQUIVO=="VV9")
	If X3USO(SX3->X3_USADO) .and. cNivel>=SX3->X3_NIVEL 
		if (Alltrim(SX3->X3_CAMPO) $ cX19VV9Mostra)
			AADD(aX19CpoVV9,SX3->X3_CAMPO)
		endif
		if AllTrim(SX3->X3_CAMPO) $ cCpoAlt
			AADD(aCpoAlt, { SX3->X3_CAMPO , ;
							SX3->X3_TIPO , ;
							SX3->X3_TAMANHO , ;
							SX3->X3_DECIMAL , ;
							SX3->X3_PICTURE , ;
							SX3->X3_TITULO , ;
							IIf(!Empty(SX3->X3_VALID),AllTrim(SX3->X3_VALID),".T.")+".and."+IIf(!Empty(SX3->X3_VLDUSER),AllTrim(SX3->X3_VLDUSER),".T."),;
							SX3->X3_WHEN ,;
							SX3->X3_CONTEXT ,;
							SX3->X3_F3 } )
		endif
	EndIf
	If SX3->X3_CONTEXT == "V"
		&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
	Else
		&("M->"+SX3->X3_CAMPO):= &("VV9->"+SX3->X3_CAMPO)
	EndIf
	DbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis de Memoria para a VV0 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VV0")
dbSetOrder(1)
dbSeek(xFilial("VV0")+VV9->VV9_NUMATE)
nRegVV0  := VV0->(Recno())
cVendAnt := VV0->VV0_CODVEN // Salva Vendedor para perguntar o Motivo caso houve alteracao

If FS_BAIXADO("'NCC'","'NCF'","001")
	MsgStop(STR0033,STR0032) // Ha titulo(s) de Devolucao para o Cliente ja baixado(s) referente(s) a este Atendimento! / Atencao
	Return(.f.)
EndIf

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV0")
While !Eof().and.(SX3->X3_ARQUIVO=="VV0")
	if AllTrim(SX3->X3_CAMPO) $ cCpoAlt
		AADD(aCpoAlt, { SX3->X3_CAMPO , ;
						SX3->X3_TIPO , ;
						SX3->X3_TAMANHO , ;
						SX3->X3_DECIMAL , ;
						SX3->X3_PICTURE , ;
						SX3->X3_TITULO , ;
						IIf(!Empty(SX3->X3_VALID),AllTrim(SX3->X3_VALID),".T.")+".and."+IIf(!Empty(SX3->X3_VLDUSER),AllTrim(SX3->X3_VLDUSER),".T."),;
						SX3->X3_WHEN ,;
						SX3->X3_CONTEXT ,;
						SX3->X3_F3 } )
	endif
	If SX3->X3_CONTEXT == "V"
		&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
	Else
		&("M->"+SX3->X3_CAMPO):= &("VV0->"+SX3->X3_CAMPO)
	EndIf
	DbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog Principal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlgX19 := MSDIALOG():New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],STR0001,,,,128,,,,,.t.)
oDlgX19:lEscClose := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Variaveis para Configuracao da Janela Principal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD( aObjects, { 100,  070, .T., .F. } ) // Parte Superior - Enchoice (VV9) e Gets alteracao
AADD( aObjects, { 100,  030, .T., .T. } ) // Parte Inferior - Valores e Botoes de Negociacao, Scrollbox, Listbox (VS9)

// Parte Inferior 
AADD( aObjInf, { 140,  010, .F., .T. } ) // LADO ESQUERDO - Valores e Botoes de Negociacao 
AADD( aObjInf, { 100,  030, .T., .T. } ) // LADO DIREITO  - Scrollbox, Listbox (VS9)

AADD( aObjLD, { 100,  100, .T., .T. } ) // Listbox com registros da VS9 

AADD( aObjEnchoice, { 40,  100, .T., .T. } ) // Enchoice - VV9
AADD( aObjEnchoice, { 50,  100, .T., .T. } ) // Gets alteracao

AADD( aObjVlrNeg  , { 010,  20, .T., .F. } ) // Valor da Venda
AADD( aObjVlrNeg  , { 010, 100, .T., .T. } ) // Scroll com Botao de Opcoes
AADD( aObjVlrNeg  , { 010,  20, .T., .F. } ) // Valor Total das Entradas / Saldo Restante ou Devolucao ou Troco
	
AADD( aObjVlrTNeg , { 010,  10, .T., .T. } ) // Gets com Total das Negociacoes 
AADD( aObjVlrTNeg , { 056,  10, .F., .T. } ) // Gets com Total das Negociacoes 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Divisao principal da Tela                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPOPri := MsObjSize( { aSizeAut[ 1 ] , aSizeAut[ 2 ] ,aSizeAut[ 3 ] , aSizeAut[ 4 ] , 1 , 1 } , aObjects , .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicao da Enchoice e Gets alteracao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPOEnc := MsObjSize( { aPOPri[1,2] , aPOPri[1,1] , aPOPri[1,4] , aPOPri[1,3] , 1, 1 } , aObjEnchoice , .T. , .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Divisao da parte Inferior                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPOInf := MsObjSize( { aPOPri[2,2] , aPOPri[2,1] , aPOPri[2,4] , aPOPri[2,3] , 1, 1 } , aObjInf , .T. , .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicao dos Objetos dentro de Valores de Negociacao             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPOVlrNeg := MsObjSize( { aPOInf[1,2]+2 , aPOInf[1,1]+5 , aPOInf[1,4]-2 , aPOInf[1,3] , 1 , 1 } , aObjVlrNeg , .T. )

aPOVlrTVal := MsObjSize( { aPOVlrNeg[1,2]+2 , aPOVlrNeg[1,1] , aPOVlrNeg[1,4]-2 , aPOVlrNeg[1,3] , 1, 1 } , aObjVlrTNeg , .T. , .T. )
aPOVlrTNeg := MsObjSize( { aPOVlrNeg[3,2]+2 , aPOVlrNeg[3,1] , aPOVlrNeg[3,4]-2 , aPOVlrNeg[3,3] , 1, 1 } , aObjVlrTNeg , .T. , .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicao dos Scrollbox Listbox VS9                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPOLD := MsObjSize( { aPOInf[2,2] , aPOInf[2,1] , aPOInf[2,4] , aPOInf[2,3] , 2, 2 } , aObjLD , .T.)

lInclui   := .f.
lAltera   := .f.
lVisual   := .t.

VISUALIZA := .t.
INCLUI    := .f.
ALTERA    := .f.
EXCLUI    := .f.
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice da VV9 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTPaX19VV9 := TPanel():New(aPOEnc[1,1] ,aPOEnc[1,2],"",oDlgX19,NIL,.T.,.F.,NIL,NIL,aPOEnc[1,4]-aPOEnc[1,2],aPOEnc[1,3]-aPOEnc[1,1],.T.,.F.)
oEncX19VV9 := MSMGet():New( "VV9",nReg, 2 /* Visualizacao */ , /*aCRA*/, /*cLetra*/, /*cTexto*/, aX19CpoVV9, aPOEnc[1], {}/*aX19CpoVV9*/ , 3, /*nColMens*/, /*cMensagem*/, /*cTudoOk*/, oTPaX19VV9, .f., .t., .t. /*lColumn*/ , "", .t. /*lNoFolder */, .f.)
oEncX19VV9:oBox:Align := CONTROL_ALIGN_ALLCLIENT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura Valores de Negociacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPOInf[1,1],aPOInf[1,2] TO aPOInf[1,3],aPOInf[1,4] LABEL STR0018 OF oDlgX19 PIXEL // Valores da Negociacao

//
If FindFunction("IsHtml")
	If !IsHtml() // Nao esta utilizando SmartClient HTML
		aLogo := Directory(cDirFotos+"VLOGOATEND.png","S") // 36pix X 36pix
		If len(aLogo) <= 0
			aLogo := Directory(cDirFotos+"VLOGOATEND.jpg","S") // 36pix X 36pix
		EndIf
	EndIf
EndIf
If len(aLogo) > 0
	oBitMapVei := TBtnBmp2():New((aPOVlrTVal[1,1]+1)*2,(aPOVlrTVal[1,2]-1)*2,36,36,"XXX",,,,{|| VX019VVA(aVVAs) },oDlgX19,STR0047,,.T.) // Veiculo(s)
	oBitMapAux := TBitmap():New((aPOVlrTVal[1,1]+1),(aPOVlrTVal[1,2]-1),18,18,,cDirFotos+aLogo[1,1],.T.,oDlgX19,,,.F.,.F.,,,.F.,,.T.,,.F.)
Else
	oBitMapVei := TBtnBmp2():New((aPOVlrTVal[1,1]+1)*2,(aPOVlrTVal[1,2]-1)*2,36,36,cBotAtF7,,,,{|| VX019VVA(aVVAs) },oDlgX19,STR0047,,.T.) // Veiculo(s)
EndIf
//
@ aPOVlrTVal[1,1]     , aPOVlrTVal[1,2]+20 SAY (STR0019+":") OF oDlgX19 PIXEL COLOR CLR_HBLUE // Vlr.Veiculo(s)
@ aPOVlrTVal[1,1] + 7 , aPOVlrTVal[1,2]+20 MSGET oVlVeicu VAR nVlVeicu PICTURE "@E 9,999,999.99" SIZE 50,1 OF oDlgX19 PIXEL HASBUTTON WHEN .F.
@ aPOVlrTVal[2,1]     , aPOVlrTVal[2,2] SAY (STR0020+":") OF oDlgX19 PIXEL COLOR CLR_HBLUE // Vlr.Atendimento
@ aPOVlrTVal[2,1] + 7 , aPOVlrTVal[2,2] MSGET oVlAtend VAR nVlAtend PICTURE "@E 9,999,999.99" SIZE 50,1 OF oDlgX19 PIXEL HASBUTTON WHEN .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Scrollbox com Botoes de Negociacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oX19ScrVlNeg := TScrollBox():New( oDlgX19 , aPOVlrNeg[2,1] , aPOVlrNeg[2,2] , aPOVlrNeg[2,3] - aPOVlrNeg[2,1] ,aPOVlrNeg[2,4] - aPOVlrNeg[2,2] , .t. , , .t. )

For nPos := 1 to Len(aX19ObjVlNeg)

	If aX19ObjVlNeg[nPos,12] // Habilita Botoes do Atendimento 
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Botoes de valores de negociacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aX19ObjVlNeg[nPos,1])
			&(aX19ObjVlNeg[nPos,1]) := TButton():New( nAuxLinha /*<nRow>*/, nColBut /*<nCol>*/, aX19ObjVlNeg[nPos,2] /*<cCaption>*/, oX19ScrVlNeg /*<oWnd>*/,;
				&('{ || ' + aX19ObjVlNeg[nPos,3] + ' }')	/*<{uAction}>*/, aX19ObjVlNeg[nPos,4] /*<nWidth>*/, aX19ObjVlNeg[nPos,5] /*<nHeight>*/, /*<nHelpId>*/, /*<oFont>*/, /*<.default.>*/,;
				.t.	/*<.pixel.>*/, /*<.design.>*/, /*<cMsg>*/, /*<.update.>*/, /*<{WhenFunc}>*/,;
				/*<{uValid}>*/, /*<.lCancel.>*/	)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Get's de valores de negociacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aX19ObjVlNeg[nPos,6])
			&(aX19ObjVlNeg[nPos,6]) := TGet():New( nAuxLinha /*<nRow>*/, nColMSGet /*<nCol>*/, ;
			&('{ | U | IF( PCOUNT() == 0,'+aX19ObjVlNeg[nPos,7]+','+aX19ObjVlNeg[nPos,7]+' := U ) }') /*bSETGET(<uVar>)*/,;
			oX19ScrVlNeg /*[<oWnd>]*/, aX19ObjVlNeg[nPos,9] /*<nWidth>*/, aX19ObjVlNeg[nPos,10]/*<nHeight>*/, aX19ObjVlNeg[nPos,8]/*<cPict>*/, /*<{ValidFunc}>*/,;
			/*<nClrFore>*/, /*<nClrBack>*/, /*<oFont>*/, /*<.design.>*/,;
			/*<oCursor>*/, .t. /*<.pixel.>*/, /*<cMsg>*/, /*<.update.>*/, { || .f. } /*<{uWhen}>*/,;
			/*<.lCenter.>*/, /*<.lRight.>*/,;
			/*[\{|nKey, nFlags, Self| <uChange>\}]*/, /*<.readonly.>*/,;
			/*<.pass.>*/ ,/*<cAlias>*/,/*<(uVar)>*/,,/*[<.lNoBorder.>]*/, /*[<nHelpId>]*/, .t. /*[<.lHasButton.>]*/ )
		EndIf
		
		nAuxLinha += 12

	EndIf
	
Next nPos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Total Valor Negociado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPOVlrTNeg[2,1]  , aPOVlrTNeg[2,2] SAY (STR0021+":") OF oDlgX19 PIXEL COLOR CLR_HBLUE // Total Pagtos
@ aPOVlrTNeg[2,1]+7, aPOVlrTNeg[2,2] MSGET oVlNegoc VAR nVlNegoc PICTURE "@E 9,999,999.99" SIZE 50,1 OF oDlgX19 WHEN .f. PIXEL HASBUTTON

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Total Devolucao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPOVlrTNeg[1,1]  , aPOVlrTNeg[1,2] SAY oTitDevol VAR (STR0022+":") SIZE 50,10 OF oDlgX19 PIXEL COLOR CLR_HBLUE // Devolucao
@ aPOVlrTNeg[1,1]+7, aPOVlrTNeg[1,2] MSGET oVlDevol VAR nVlDevol PICTURE "@E 9,999,999.99" SIZE 50,1 OF oDlgX19 WHEN .f. PIXEL HASBUTTON
oVlDevol:lVisible := .f.
oTitDevol:lVisible := .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Total Saldo     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPOVlrTNeg[1,1]  , aPOVlrTNeg[1,2] SAY oTitSaldo VAR (STR0023+":") SIZE 50,10 OF oDlgX19 PIXEL COLOR CLR_HRED // Saldo Restante
@ aPOVlrTNeg[1,1]+7, aPOVlrTNeg[1,2] MSGET oVlSaldo VAR nVlSaldo PICTURE "@E 9,999,999.99" SIZE 50,1 OF oDlgX19 WHEN .f. PIXEL HASBUTTON
oVlSaldo:lVisible := .f.
oTitSaldo:lVisible := .f.


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Scrollbox com GETs que poderao ser alterados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                                 
oX19ScrGet := TScrollBox():New( oDlgX19, aPOEnc[2,1] , aPOEnc[2,2] , aPOEnc[2,3] - aPOEnc[2,1] , aPOEnc[2,4] - aPOEnc[2,2] , .t. , , .t. )

nLin := 4
nCol := 40
nDisLin := 11
nDisCol := 160

For nPos := 1 to Len(aCpoAlt)

	if nPos <> 1
		if MOD(nPos,2) == 0
			nCol += nDisCol
		else
			nLin += nDisLin
			nCol := 40
		endif
	endif

	bWhen := NIL
	If aCpoAlt[nPos, 9] == "V"
		bWhen := { || .f. }
	ElseIf !Empty(aCpoAlt[nPos,8])
		bWhen := &("{ || " + AllTrim(aCpoAlt[nPos,8]) + " }")
	EndIf
	
	bBloco := "{|| '" + AllTrim(RetTitle(aCpoAlt[nPos,1])) +"' }"
	TSay():New ( nLin+1 , nCol-35 , MontaBlock(bBloco), oX19ScrGet , /*cPicture */, oX19ScrGet:oFont /*oFont*/ , .f. , .f. , .f. , .t. /*lPixels*/, /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/ ,.F.,.F.,.F.,.F.,.F. )	

	nTamGet := CalcFieldSize( aCpoAlt[nPos,2] , aCpoAlt[nPos,3] , 0 , aCpoAlt[nPos,5] , " ")
	cObjGName := "oGet" + AllTrim(aCpoAlt[nPos,1])
	&(cObjGName) := TGet():New( nLin /*<nRow>*/, nCol /*<nCol>*/, ;
		&('{ | U | IF( PCOUNT() == 0,M->'+aCpoAlt[nPos,1]+',M->'+aCpoAlt[nPos,1]+' := U ) }') /*bSETGET(<uVar>)*/,;
		oX19ScrGet /*[<oWnd>]*/, nTamGet+10 /*<nWidth>*/, 1 /*<nHeight>*/, aCpoAlt[nPos,5]/*<cPict>*/, &('{|| ' +aCpoAlt[nPos,7]+' }') /*<{ValidFunc}>*/,;
		/*<nClrFore>*/, /*<nClrBack>*/, /*<oFont>*/, /*<.design.>*/,;
		/*<oCursor>*/, .t. /*<.pixel.>*/, /*<cMsg>*/, /*<.update.>*/, bWhen /*<{uWhen}>*/,;
		/*<.lCenter.>*/, /*<.lRight.>*/,;
		/*[\{|nKey, nFlags, Self| <uChange>\}]*/, /*<.readonly.>*/,;
		/*<.pass.>*/ , iif( !Empty(aCpoAlt[nPos,10]) , aCpoAlt[nPos,10] , NIL ) /*<cAlias>*/,/*<(uVar)>*/,,/*[<.lNoBorder.>]*/, /*[<nHelpId>]*/, .t. /*[<.lHasButton.>]*/ )

Next nPos 

SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1") + VV9->VV9_CODCLI + VV9->VV9_LOJA))

aX19ParFin[02] := SA1->A1_COD
aX19ParFin[03] := SA1->A1_LOJA
aX19ParFin[04] := SA1->A1_PESSOA
aX19ParFin[09] := M->VV0_CODBCO // Banco FI
aX19ParFin[10] := M->VV0_TABFAI // Tabela FI
aX19ParFin[12] := M->VV9_NUMATE
///////////////////////////////
// Carregar Veiculos ( VVA ) //
///////////////////////////////
DbSelectArea("VVA")
DbSetOrder(1)
DbSeek(VV9->VV9_FILIAL+VV9->VV9_NUMATE)
While !Eof() .and. VVA->VVA_FILIAL == VV9->VV9_FILIAL .and. VVA->VVA_NUMTRA == VV9->VV9_NUMATE
	aX19ParFin[05] := VVA->VVA_CHAINT	// Chassi Interno (CHAINT)
	aX19ParFin[06] := VVA->VVA_ESTVEI	// Estado do Veiculo (0=Novo/1=Usado)
	aX19ParFin[07] := VVA->VVA_GRUMOD	// Grupo do Modelo
	aX19ParFin[08] := VVA->VVA_MODVEI	// Modelo do Veiculo
	AADD(aX19ParFin[15],{ VVA->VVA_CHAINT , VVA->VVA_ESTVEI , VVA->VVA_GRUMOD , VVA->VVA_MODVEI , VVA->VVA_CODMAR } )
	//
	aAdd(aVVAs,{VVA->VVA_CHAINT,VVA->VVA_CHASSI,VVA->VVA_CODMAR,VVA->VVA_MODVEI,"",VVA->VVA_CORVEI,"",""})
	//
	DbSelectArea("VVA")
	DbSkip()
EndDo

aX19ParCon[01] := M->VV9_NUMATE
aX19ParUsa[01] := M->VV9_NUMATE
aX19ParEnt[01] := M->VV9_NUMATE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Listbox com registros da VS9 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ aPOLD[1,1]-2 ,aPOLD[1,2] TO aPOLD[1,3]+2,aPOLD[1,4]+2 LABEL STR0012 OF oDlgX19 PIXEL // Composicao das Parcelas
@ aPOLD[1,1]+6,aPOLD[1,2]+2 LISTBOX oLBX19Parc ;
	FIELDS HEADER "",STR0024,STR0025,STR0026,STR0027 COLSIZES 5,25,35,80,160 SIZE aPOLD[1,4] - aPOLD[1,2] - 2 , aPOLD[1,3] - aPOLD[1,1] - 6 OF oDlgX19 PIXEL ;
	ON DBLCLICK VX019DTVS9(4,VV9->VV9_NUMATE,@aX19VS9,oLBX19Parc:aArray[oLBX19Parc:nAt,7],oLBX19Parc:aArray,oLBX19Parc:nAt) // ( nOPC , Nro.Atendimento , @aVS9 , RECNO VS9 , Vetor das Parcelas , Posicao do Vetor )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Matriz com Registros da VS9 e VSE ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VX002X3LOAD( "VS9" , .t. , @aX19VS9   , 1 , "VS9_FILIAL+VS9_NUMIDE+VS9_TIPOPE" , xFilial("VS9")+PadR(M->VV9_NUMATE,TamSX3("VS9_NUMIDE")[1]," ")+"V" )
nQtdTitulos := len(aX19VS9[2])

VX002X3LOAD( "VSE" , .t. , @aX19VSE )
VX002X3LOAD( "VSE" , .t. , @aVSETotal , 1 , "VSE_FILIAL+VSE_NUMIDE+VSE_TIPOPE" , xFilial("VSE")+PadR(M->VV9_NUMATE,TamSX3("VSE_NUMIDE")[1]," ")+"V" )

VX019ATTELA(aX19VS9,0)

DbSelectArea("VV9")

oDlgX19:bInit := { || ( EnchoiceBar(oDlgX19,{|| IIf( VX019TUDOK(aX19VS9) , oDlgX19:End() , .f. ) }, {|| oDlgX19:End()} ,,aBotEncX19)) }
oDlgX19:Activate()

DbSelectArea("VV9")

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX019TUDOK º Autor ³ Andre Luis Almeida º Data ³  11/12/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida se pode haver alteracao e faz gravacoes dos arquivosº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX019TUDOK(aX19VS9)
Local nSeqVS9    := 0
Local nVlConsor  := 0
Local lSelMotivo := .f.
Local aMotManut  := {}
Local cObsMot    := ""
Local aAux       := {}
Local ni         := 0
Local nj         := 0
Local nCntLinha  := 0
Local nCntCampo  := 0
Local cTipVSA    := ""
Local nPosNUMIDE := 0
Local nPosTIPOPE := 0
Local nPosTIPPAG := 0
Local nPosSEQUEN := 0
Local nPosPARCEL := 0
Local nPosNUMTRA := 0
Local nPosCODACV := 0
Local nPosITECAM := 0
Local nPosREFPAG := 0
Local cString    := ""
Local nUsado     := 0
Local cTitAten   := left(GetNewPar("MV_TITATEN","0"),1) // Momento da Geracao dos Titulos
Local lCPagPad   := ( GetNewPar("MV_MIL0016","0") == "1" ) //Utiliza no Atendimento de Veículos, Condição de Pagamento da mesma forma que no Faturamento Padrão do ERP? (0=Não / 1= Sim) - Chamado CI 001985
Private aAuxHeader := {}
aAuxHeader := aClone(aX19VS9[1])
nPosPARCEL := FG_POSVAR("VS9_PARCEL","aAuxHeader")
nPosSEQUEN := FG_POSVAR("VS9_SEQUEN","aAuxHeader")
nPosNUMIDE := FG_POSVAR("VS9_NUMIDE","aAuxHeader")
nPosTIPOPE := FG_POSVAR("VS9_TIPOPE","aAuxHeader")
nPosTIPPAG := FG_POSVAR("VS9_TIPPAG","aAuxHeader")
nPosREFPAG := FG_POSVAR("VS9_REFPAG","aAuxHeader")
//////////////////////////////////////////////////////////////
// Verificar Valor Original com o Valor Atual da manutencao //
//////////////////////////////////////////////////////////////
If nVlAtend > nVlNegoc
	MsgStop(STR0034+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Ha divergencia nos valores!
			FG_AlinVlrs(left(STR0035+space(14),14))            +FG_AlinVlrs(left(STR0036+space(14),14))             +FG_AlinVlrs(left(STR0037+space(14),14))+CHR(13)+CHR(10)+; // Vlr.Total / Vlr.Parcelas / Divergencia
			FG_AlinVlrs(Transform(nVlAtend,"@E 999,999,999.99"))+FG_AlinVlrs(Transform(nVlNegoc,"@E 999,999,999.99"))+FG_AlinVlrs(Transform(nVlNegoc-nVlAtend,"@E 999,999,999.99")),STR0032) // Atencao
	Return(.f.)
EndIf
//
Begin Transaction
	If ( cVendAnt <> M->VV0_CODVEN )
		lSelMotivo := .t. // Selecionar Motivo
	EndIf
	For ni := 1 to len(aX19CpoPar)
		If aX19CpoPar[ni,6] <> "overd" .and. aX19CpoPar[ni,6] <> "overm" // Diferente de "Verde" (Titulo nao alterado) e "Vermelho" (Titulo ja baixado)
        	lSelMotivo := .t.
			cTipVSA := FM_SQL("SELECT VSA_TIPO FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG='"+aX19CpoPar[ni,3]+"' AND VSA.D_E_L_E_T_=' '")
			If aX19VS9[2,aX19CpoPar[ni,7],nPosPARCEL] == NIL .or. Empty(aX19VS9[2,aX19CpoPar[ni,7],nPosPARCEL])
				aX19VS9[2,aX19CpoPar[ni,7],nPosPARCEL] := " "
				If aX19CpoPar[ni,6] == "obran" // Novo registro
					nSeqVS9 := val(FM_SQL("SELECT MAX(VS9_SEQUEN) FROM "+RetSQLName("VS9")+" VS9 WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE='"+aX19VS9[2,aX19CpoPar[ni,7],nPosNUMIDE]+"' AND VS9.VS9_TIPOPE='V' AND VS9.VS9_TIPPAG='"+aX19VS9[2,aX19CpoPar[ni,7],nPosTIPPAG]+"' AND VS9.D_E_L_E_T_=' '"))
					aX19VS9[2,aX19CpoPar[ni,7],nPosSEQUEN] := strzero(nSeqVS9+1,2)
				EndIf
			EndIf			
			Do Case
				Case cTipVSA == "1" // Financiamento / Leasing
					FS_CANCELTIT(1,("'"+aX19CpoPar[ni,3]+"','RF ','TC ','CMF'"),aX19VS9[2,aX19CpoPar[ni,7],nPosPARCEL]) // ( Tipo VSA , Tipo Pagto , Parcela )
					If aX19CpoPar[ni,6] == "ocanc"
						M->VV0_VALFIN := 0 // Valor do Financiamento FI / Leasing
						M->VV0_CODBCO := "" // Banco FI
						M->VV0_TABFAI := "" // Tabela FI
						M->VV0_DIA1PC := 0
						M->VV0_PARCEL := 0
						M->VV0_INTERV := 0
						M->VV0_COEFIC := 0
						M->VV0_VALTAC := 0
						M->VV0_TACLIQ := 0
						M->VV0_TACFIN := "0"
						M->VV0_TACSUB := "0"
						M->VV0_SUBFIN := 0
						M->VV0_PTXRET := 0
						M->VV0_VTXRET := 0
						M->VV0_PCUSFN := 0
						M->VV0_VCUSFN := 0
						M->VV0_PREBFN := 0
						M->VV0_VALREB := 0
						M->VV0_PCOMFN := 0
						M->VV0_VCOMFN := 0
					Else
						If aX19ParFin[13]+aX19ParFin[14] > 0
							M->VV0_VALFIN := aX19ParFin[01] // aX19ParFin - Valor do Financiamento FI / Leasing
							M->VV0_CODBCO := aX19ParFin[09] // aX19ParFin - Banco FI
							M->VV0_TABFAI := aX19ParFin[10] // aX19ParFin - Tabela FI
							VAS->(DbGoTo(aX19ParFin[13])) // aX19ParFin - VAS->RecNo()
							VAR->(DbGoTo(aX19ParFin[14])) // aX19ParFin - VAR->RecNo()
							M->VV0_DIA1PC := val(VAS->VAS_PPARVI)
							M->VV0_PARCEL := val(VAS->VAS_QTDPAR)
							M->VV0_INTERV := val(VAS->VAS_INTERV)
							M->VV0_COEFIC := VAS->VAS_COEFIC
							M->VV0_VALTAC := VAS->VAS_VLRTAC
							M->VV0_TACLIQ := IIf(VAS->VAS_TACLIQ>0,VAS->VAS_TACLIQ,VAS->VAS_VLRTAC)
							M->VV0_TACFIN := VAR->VAR_TACFIN
							M->VV0_TACSUB := VAS->VAS_TACSUB
							M->VV0_SUBFIN := VAS->VAS_SUBFIN
							M->VV0_PTXRET := VAS->VAS_PERRET
							M->VV0_VTXRET := ( M->VV0_VALFIN * ( M->VV0_PTXRET / 100 ) ) // Retorno
							M->VV0_PCOMFN := VAS->VAS_PEPLUS
							M->VV0_VCOMFN := ( M->VV0_VALFIN * ( M->VV0_PCOMFN / 100 ) ) // Plus
							M->VV0_PREBFN := VAS->VAS_PERCTB
							M->VV0_VALREB := ( M->VV0_VALFIN * ( M->VV0_PREBFN / 100 ) ) // Rebate
							M->VV0_PCUSFN := VAS->VAS_CUSREC
							M->VV0_VCUSFN := ( ( M->VV0_VTXRET +  M->VV0_VCOMFN + M->VV0_TACLIQ )  * ( M->VV0_PCUSFN / 100 ) ) // Custo do Financiamento, utilizado para abater o titulo de retorno
							M->VV0_VTXRET := M->VV0_VTXRET * ((100-M->VV0_PCUSFN)/100) // Valor Liquido Retorno
							M->VV0_VCOMFN := M->VV0_VCOMFN * ((100-M->VV0_PCUSFN)/100) // Valor Liquido Plus
							M->VV0_TACLIQ := M->VV0_TACLIQ * ((100-M->VV0_PCUSFN)/100) // Valor Liquido TAC
						EndIf
					EndIf
//				Case cTipVSA == "2" // Financiamento Proprio
					// FAZER DEPOIS ( 2a. FASE )
				Case cTipVSA == "3" // Consorcio
					FS_CANCELTIT(3,aX19CpoPar[ni,3],aX19VS9[2,aX19CpoPar[ni,7],nPosPARCEL]) // ( Tipo VSA , Tipo Pagto , Parcela )
				Case cTipVSA == "4" // Veiculo Usado (Avaliacoes)
					DbSelectArea("VAZ")
					DbSetOrder(5)
					If DbSeek(xFilial("VAZ")+aX19VS9[2,aX19CpoPar[ni,7],nPosREFPAG])
						RecLock("VAZ",.f.)
							VAZ->VAZ_FILATE := ""
							VAZ->VAZ_NUMATE := ""
							VAZ->VAZ_APROVA := "1"
						MsUnLock()
					EndIf					
					FS_CANCELTIT(4,aX19CpoPar[ni,3],aX19VS9[2,aX19CpoPar[ni,7],nPosPARCEL]) // ( Tipo VSA , Tipo Pagto , Parcela )
				Case cTipVSA == "5" // Entradas
					FS_CANCELTIT(5,aX19CpoPar[ni,3],aX19VS9[2,aX19CpoPar[ni,7],nPosPARCEL]) // ( Tipo VSA , Tipo Pagto , Parcela )
//				Case cTipVSA == "6" // Finame
					// FAZER DEPOIS ( 2a. FASE )
			EndCase
			If aX19CpoPar[ni,6] == "ocanc"
				FS_RECVS9(.f.,aX19VS9,aX19CpoPar[ni,7]) // Excluir VS9
			Else
				FS_RECVS9(.t.,aX19VS9,aX19CpoPar[ni,7]) // Incluir VS9 / Alterar VS9
			EndIf
		EndIf
	Next
	If lSelMotivo
		aMotManut := OFA210MOT("000005","1",VV9->VV9_FILIAL,VV9->VV9_NUMATE,.t.) // Filtro da consulta do motivo ( 000005 = Manutencao do Atendimento de Veiculos )
		If len(aMotManut) <= 0
			DisarmTransaction()
			Return .f.
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui todos os VSE relacionados ao Atendimento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cString := "DELETE FROM "+RetSqlName("VSE")+ " WHERE VSE_FILIAL='"+xFilial("VSE")+"' AND VSE_NUMIDE='"+VV9->VV9_NUMATE+"' AND VSE_TIPOPE='V'"
		TCSqlExec(cString)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inclui todos os VSE relacionados ao Atendimento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nUsado := Len(aVSETotal[2,1])
		DbSelectArea("VSE")
		DbSetOrder(1) // VSE_FILIAL+VSE_NUMIDE+VSE_TIPOPE+VSE_TIPPAG+VSE_SEQUEN
		aAuxHeader := aClone(aVSETotal[1]) // Compatibilizacao com FG_POSVAR
		nPosNUMIDE := FG_POSVAR("VSE_NUMIDE","aAuxHeader")
		nPosTIPOPE := FG_POSVAR("VSE_TIPOPE","aAuxHeader")
		nPosTIPPAG := FG_POSVAR("VSE_TIPPAG","aAuxHeader")
		nPosSEQUEN := FG_POSVAR("VSE_SEQUEN","aAuxHeader")
		For nCntLinha := 1 to Len(aVSETotal[2])
			// Verifica se a linhas esta vazia ...
			If Empty( aVSETotal[2,nCntLinha,nPosNUMIDE] + aVSETotal[2,nCntLinha,nPosTIPOPE] + aVSETotal[2,nCntLinha,nPosTIPPAG] + aVSETotal[2,nCntLinha,nPosSEQUEN] )
				Loop
			EndIf
			// Se nao tiver excluido
			If !aVSETotal[2,nCntLinha,nUsado]
				RecLock("VSE",.T.)
				VSE->VSE_FILIAL := xFilial("VSE")
				aVSETotal[2,nCntLinha,nPosNUMIDE] := PadR(VV9->VV9_NUMATE,aVSETotal[1,nPosNUMIDE,4]," ")
				For nCntCampo := 1 to (nUsado - 1)
					// Campo de Visualizacao
					If aVSETotal[1,nCntCampo,10] <> "V"
						If aVSETotal[2,nCntLinha,nCntCampo] == NIL
							&("VSE->" + aVSETotal[1,nCntCampo,2]) := CriaVar(aVSETotal[1,nCntCampo,2])
						Else
							&("VSE->" + aVSETotal[1,nCntCampo,2]) := aVSETotal[2,nCntLinha,nCntCampo]
						EndIf
					EndIf
				Next nCntCampo
				MsUnLock()
			EndIf
		Next nCntLinha
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desposicionar, para considerar em SELECT no meio da transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VSE->(dbGoTo(VSE->(Recno())))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza a Categoria, Tipo de Venda e Cliente/Loja Alienacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAux := VX002CATVEN(M->VV9_NUMATE)
		M->VV0_CATVEN := aAux[1] // Categoria de Venda
		M->VV0_TIPVEN := aAux[2] // Tipo de Venda
		M->VV0_CLIALI := aAux[3] // Cliente Alienacao
		M->VV0_LOJALI := aAux[4] // Loja Cliente Alienacao
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza Valor total da Carteira de Consorcios e Entradas    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M->VV0_VCARCR := FM_SQL("SELECT SUM(VS9.VS9_VALPAG) AS VALOR FROM "+RetSQLName("VS9")+" VS9 , "+RetSQLName("VSA")+" VSA WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE='"+M->VV9_NUMATE+"' AND VS9.VS9_TIPOPE='V' AND VS9.D_E_L_E_T_=' ' AND VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG=VS9.VS9_TIPPAG AND VSA.VSA_TIPO='3' AND VSA.D_E_L_E_T_=' '")
		M->VV0_TOTENT := FM_SQL("SELECT SUM(VS9.VS9_VALPAG) AS VALOR FROM "+RetSQLName("VS9")+" VS9 , "+RetSQLName("VSA")+" VSA WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE='"+M->VV9_NUMATE+"' AND VS9.VS9_TIPOPE='V' AND VS9.D_E_L_E_T_=' ' AND VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG=VS9.VS9_TIPPAG AND VSA.VSA_TIPO='5' AND VSA.D_E_L_E_T_=' '")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Titulos de Devolucao ao Cliente NCC/NCF                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FS_CANCELTIT(99,"NCC","001") // ( Tipo VSA , Tipo Pagto , Parcela )
		M->VV0_VALTRO := 0
		If VV0->VV0_VALTOT < nVlNegoc
			M->VV0_VALTRO := nVlNegoc - VV0->VV0_VALTOT
		EndIf
		
		If !lCPagPad // Padrão do ERP
			M->VV0_FORPAG := RetCondVei()
		Endif

		DbSelectArea("VV0")
		RecLock("VV0",.f.)
		FG_GRAVAR("VV0")
		MsUnLock()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desposicionar, para considerar em SELECT no meio da transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VV0->(dbGoTo(VV0->(Recno())))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera Titulos na 1=Pre-Aprovacao, 2=Aprovacao ou 0=Finalizacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTitAten == "1" .or. ( cTitAten == "2" .and. VV9->VV9_STATUS<>"O" ) .or. VV9->VV9_STATUS=="F"
			If !VEIXI002(VV9->VV9_NUMATE,.f.,.f.,.t.,"",.t.) //  ( NroAtend. , lPedido , lNF , lTitulos , cSerie , lManutencao )
				DisarmTransaction()
				Return .f.
			EndIf
		EndIf
		DbSelectArea("VMA") 
		DbSetOrder(1)
		DbSeek(xFilial("VMA")+VV9->VV9_FILIAL+VV9->VV9_NUMATE+dtos(dDataBase)+Alltrim(str(val(left(time(),2)+substr(time(),4,2)))))
		RecLock("VMA",!Found())
			VMA->VMA_FILIAL := xFilial("VMA")
			VMA->VMA_FILATE := VV9->VV9_FILIAL
			VMA->VMA_NUMATE := VV9->VV9_NUMATE
			VMA->VMA_STATUS := VV9->VV9_STATUS
			VMA->VMA_DATMAN := dDataBase
			VMA->VMA_HORMAN := val(left(time(),2)+substr(time(),4,2))
			VMA->VMA_USUMAN := __cUserID
			VMA->VMA_MOTIVO := aMotManut[1]
		MsUnLock()
		//
		DbSelectArea("VV0")
		cObsMot := E_MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1])
		If !Empty(cObsMot)
			cObsMot += Chr(13)+Chr(10)
		EndIf
		cObsMot += Repl("_",TamSx3("VV0_OBSERV")[1])+Chr(13)+Chr(10)+"***  "+left(Alltrim(UsrRetName(__CUSERID)),15)+"  "+Transform(dDataBase,"@D")+" - "+Transform(time(),"@R 99:99")+"  ***"+Chr(13)+Chr(10)
		cObsMot += STR0038+" "+aMotManut[2] // Manutencao do Atendimento! Motivo:
		For nCntLinha := 1 to len(aMotManut[4])
			If !Empty(aMotManut[4,nCntLinha,1])
				cObsMot += CHR(13)+CHR(10)+" - "+Alltrim(aMotManut[4,nCntLinha,1])+": "+Transform(aMotManut[4,nCntLinha,2],aMotManut[4,nCntLinha,6])
			EndIf
		Next
		MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1],,cObsMot,1,,,"VV0","VV0_OBSMEM")
    	//
	EndIf
End Transaction
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_RECVS9 º Autor ³ Andre Luis Almeida º Data ³  11/12/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Incluir / Alterar / Excluir  ->  VS9                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_RECVS9(lIncAlt,aX19VS9,nLinhaVS9)
Local cObserv    := ""
Local cObsNew    := ""
Local ni         := 0
Local nCntCampo  := 0
Local nPosNUMIDE := 0
Local nPosTIPOPE := 0
Local nPosTIPPAG := 0
Local nPosSEQUEN := 0
Private aAuxHeader := aClone(aX19VS9[1]) // Compatibilizacao com FG_POSVAR
nPosNUMIDE := FG_POSVAR("VS9_NUMIDE","aAuxHeader")
nPosTIPOPE := FG_POSVAR("VS9_TIPOPE","aAuxHeader")
nPosTIPPAG := FG_POSVAR("VS9_TIPPAG","aAuxHeader")
nPosSEQUEN := FG_POSVAR("VS9_SEQUEN","aAuxHeader")
ni := ascan(aMEMOVS9,{|x| x[1] == nLinhaVS9 })
If ni > 0
	cObsNew := aMEMOVS9[ni,2]
EndIf
DbSelectArea("VS9")
DbSetOrder(1)
DbSeek(xFilial("VS9")+aX19VS9[2,nLinhaVS9,nPosNUMIDE]+aX19VS9[2,nLinhaVS9,nPosTIPOPE]+aX19VS9[2,nLinhaVS9,nPosTIPPAG]+aX19VS9[2,nLinhaVS9,nPosSEQUEN])
If lIncAlt // Incluir / Alterar
	If !VS9->(Found())
		RecLock("VS9",.T.)
		VS9->VS9_FILIAL := xFilial("VS9")
		aX19VS9[2,nLinhaVS9,nPosNUMIDE] := PadR(M->VV9_NUMATE,aX19VS9[1,nPosNUMIDE,4]," ")
		aX19VS9[2,nLinhaVS9,nPosTIPOPE] := "V"
	Else
		cObserv := E_MSMM(VS9->VS9_OBSMEM,TamSx3("VS9_OBSERV")[1])
		If !Empty(cObserv)
			cObserv += CHR(13)+CHR(10)+repl("_",TamSx3("VS9_OBSERV")[1])+CHR(13)+CHR(10)
		EndIf
		RecLock("VS9",.F.)
	EndIf
	For nCntCampo := 1 to len(aX19VS9[1])
		// Campo de Visualizacao
		If aX19VS9[1,nCntCampo,10] <> "V"
			If aX19VS9[2,nLinhaVS9,nCntCampo] == NIL
				&("VS9->" + aX19VS9[1,nCntCampo,2]) := CriaVar(aX19VS9[1,nCntCampo,2])
			Else
				&("VS9->" + aX19VS9[1,nCntCampo,2]) := aX19VS9[2,nLinhaVS9,nCntCampo]
			EndIf
		EndIf
	Next nCntCampo
	VS9->VS9_PARCEL := ""
	If !Empty(cObsNew)
		MSMM(VS9->VS9_OBSMEM,TamSx3("VS9_OBSERV")[1],,cObserv+"***  "+left(Alltrim(UsrRetName(__CUSERID)),15)+"  "+Transform(dDataBase,"@D")+" - "+Transform(time(),"@R 99:99")+"  ***"+Chr(13)+Chr(10)+cObsNew,1,,,"VS9","VS9_OBSMEM")
	EndIf	
	MsUnLock()
Else // Excluir
	If VS9->(Found())
		RecLock("VS9",.F.,.T.)
		VS9->(dbDelete())
		MsUnLock()
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desposicionar, para considerar em SELECT no meio da transacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VS9->(dbGoTo(VS9->(Recno())))
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_CANCELTITº Autor ³ Andre Luis Almeida º Data ³ 11/12/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cancelar Titulos SE1 / SE2                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CANCELTIT(nTp,cTipPag,cParcel)
Local aParcelas := {}
Local cQuery    := ""
Local ni        := 0
Local cSQLAlias := "SQLSE1SE2"
Local cNumTit   := "V"+Right(VV9->VV9_NUMATE,TamSx3("E1_NUM")[1]-1)
Local cNumNFI   := VV0->VV0_NUMNFI
Local cPreTit   := &(GetNewPar("MV_PTITVEI","''")) // Prefixo dos Titulos de Veiculos
If left(GetNewPar("MV_TITATEN","0"),1) == "0" // Geracao dos Titulos no momento da geracao da NF
	If !Empty(cNumNFI) // Titulos gerados com o Nro da Nota Fiscal
		SF2->(DbSetOrder(1)) // F2_FILIAL + F2_DOC + F2_SERIE
		If SF2->(DbSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI))
			cPreTit := SF2->F2_PREFIXO
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CANCELAR TITULOS -> CONTAS A RECEBER ( SE1 )                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT SE1.E1_PREFIXO , SE1.E1_NUM , SE1.E1_PARCELA , SE1.E1_TIPO FROM " + RetSQLName("SE1") + " SE1 WHERE SE1.E1_FILIAL='" + xFilial("SE1") + "' AND "
cQuery += "SE1.E1_PREFIXO='"+cPreTit+"' AND "
cQuery += "( SE1.E1_NUM='"+cNumTit+"' "
If !Empty(cNumNFI) // Titulos gerados com o Nro da Nota Fiscal
	cQuery += "OR SE1.E1_NUM='"+cNumNFI+"' "
EndIf
cQuery += ") AND "
If nTp == 1 // Financiamento / Leasing
	cQuery += "SE1.E1_TIPO IN ("+cTipPag+") AND "
Else
	cQuery += "SE1.E1_TIPO='"+cTipPag+"' AND SE1.E1_PARCELA='"+cParcel+"' AND "
EndIf
cQuery += "SE1.E1_PREFORI='"+cPrefVEI+"' AND SE1.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
While !(cSQLAlias)->(Eof())
	If (cSQLAlias)->(E1_TIPO) $ MVIRABT+"/"+MVINABT+"/"+MVCFABT+"/"+MVCSABT+"/"+MVPIABT // Nao leva para a exclusao os Titulo de Abatimento de Impostos
		(cSQLAlias)->(DbSkip())
		Loop
	EndIf
	aAdd(aParcelas,{{"E1_PREFIXO" , (cSQLAlias)->( E1_PREFIXO ) ,nil},;
					{"E1_NUM"     , (cSQLAlias)->( E1_NUM )     ,nil},;
					{"E1_PARCELA" , (cSQLAlias)->( E1_PARCELA ) ,nil},;
					{"E1_TIPO"    , (cSQLAlias)->( E1_TIPO )    ,nil},;
					{"E1_ORIGEM"  , "MATA460"                    ,nil}}) 
	(cSQLAlias)->(DbSkip())
Enddo
(cSQLAlias)->(DbCloseArea())
DbSelectArea("SE1")
Pergunte("FIN040",.F.)
For ni := 1 to len(aParcelas)
	lMsErroAuto := .f.
	MSExecAuto({|x,y| FINA040(x,y)},aParcelas[ni],5)
	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
		Return .f.
	EndIf
Next
If nTp == 1 .or. nTp == 99 // SE2 - Financiamento / Leasing  ou  Devolucao ao Cliente
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CANCELAR TITULOS -> CONTAS A PAGAR ( SE2 )                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aParcelas := {}
	cQuery := "SELECT SE2.E2_PREFIXO , SE2.E2_NUM , SE2.E2_PARCELA , SE2.E2_TIPO FROM " + RetSQLName("SE2") + " SE2 WHERE SE2.E2_FILIAL='" + xFilial("SE2") + "' AND "
	cQuery += "SE2.E2_NUM='"+cNumTit+"' AND "
	cQuery += "( ( SE2.E2_FORNECE='______' AND SE2.E2_LOJA='__' ) "
	If FGX_SA1SA2(VV9->VV9_CODCLI,VV9->VV9_LOJA,.f.) // Cliente como Fornecedor
		cQuery += " OR ( SE2.E2_FORNECE='"+SA2->A2_COD+"' AND SE2.E2_LOJA='"+SA2->A2_LOJA+"' ) "
	EndIf
	// Levantar todos os Clientes/Lojas de 1=Financiamento como Fornecedor
	cQueryAux := "SELECT VSA.VSA_CODCLI , VSA.VSA_LOJA FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='1' AND VSA.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryAux ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->( Eof() )
		If FGX_SA1SA2((cSQLAlias)->( VSA_CODCLI ),(cSQLAlias)->( VSA_LOJA ),.f.)
			cQuery += " OR ( SE2.E2_FORNECE='"+SA2->A2_COD+"' AND SE2.E2_LOJA='"+SA2->A2_LOJA+"' ) "
	   	EndIf
	(cSQLAlias)->(DbSkip())
	EndDo
	(cSQLAlias)->(DbCloseArea())
	cQuery += " ) AND "
	If nTp == 1 // Financiamento / Leasing
		cQuery += "SE2.E2_TIPO IN ('TC ','RBT') AND " // ( TAC e Rebate )
	Else // Devolucao ao Cliente
		cQuery += "SE2.E2_TIPO='NCF' AND " // ( NCF - Nota de Credito Fornecedor )
	EndIf
	cQuery += "SE2.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
	While !(cSQLAlias)->(Eof())
		aAdd(aParcelas,{{"E2_PREFIXO" , (cSQLAlias)->( E2_PREFIXO ) ,nil},;
						{"E2_NUM"     , (cSQLAlias)->( E2_NUM )     ,nil},;
						{"E2_PARCELA" , (cSQLAlias)->( E2_PARCELA ) ,nil},;
						{"E2_TIPO"    , (cSQLAlias)->( E2_TIPO )    ,nil}})
		(cSQLAlias)->(DbSkip())
	Enddo
	(cSQLAlias)->(DbCloseArea())
	DbSelectArea("SE2")
	Pergunte("FIN050",.F.)
	For ni := 1 to len(aParcelas)
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z| FINA050(x,y,z)},aParcelas[ni],,5)
		If lMsErroAuto
			MostraErro()
			DisarmTransaction()
			Return .f.
		EndIf
	Next
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX019ATTELAº Autor ³ Andre Luis Almeida º Data ³  11/12/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza Tela ( Objetos na Dialog )                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VX019ATTELA(aX19VS9,nVez)
Local cQuery    := ""
Local cSQLAux   := "SQLAUX"
Local nPos      := 0 
Local cCor      := ""
Local ni        := 0
Local cTpPgE1   := ""
Local cTpPgE2   := ""
Local cTipVSA   := ""
Local cAuxObs   := ""
Local nPosTIPPAG, nPosDATPAG, nPosVALPAG, nPosDESPAG, nPosREFPAG, nPosSEQUEN , nPosPARCEL
Local nVSETIPPAG, nVSESEQUEN, nVSEDESCCP, nVSEVALDIG
Private aAuxHeader := {}

aAuxHeader := aClone(aVSETotal[1]) // Compatibilizacao com FG_POSVAR
nVSETIPPAG := FG_POSVAR("VSE_TIPPAG","aAuxHeader")
nVSESEQUEN := FG_POSVAR("VSE_SEQUEN","aAuxHeader")
nVSEDESCCP := FG_POSVAR("VSE_DESCCP","aAuxHeader")
nVSEVALDIG := FG_POSVAR("VSE_VALDIG","aAuxHeader")

aAuxHeader := aClone(aX19VS9[1]) // Compatibilizacao com FG_POSVAR
nPosTIPPAG := FG_POSVAR("VS9_TIPPAG","aAuxHeader")
nPosDATPAG := FG_POSVAR("VS9_DATPAG","aAuxHeader")
nPosVALPAG := FG_POSVAR("VS9_VALPAG","aAuxHeader")
nPosDESPAG := FG_POSVAR("VS9_DESPAG","aAuxHeader")
nPosREFPAG := FG_POSVAR("VS9_REFPAG","aAuxHeader")
nPosSEQUEN := FG_POSVAR("VS9_SEQUEN","aAuxHeader")
nPosPARCEL := FG_POSVAR("VS9_PARCEL","aAuxHeader")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valor do(s) Veiculo(s)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTotVZ7	   := VX003TOTAL(M->VV9_NUMATE,"")
nVlVeicu   := ( M->VV0_VALMOV - aTotVZ7[1] )
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valor do Atendimento    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlAtend   := M->VV0_VALTOT

aX19CpoPar := {}
nVlNegoc   := 0

nVlFinanc  := 0
nVlFinPro  := M->VV0_VALFPR // Financiamento Proprio - Utilizar Valor Total (VV0_VALFPR), pois o VS9 esta com o Juros embutido no Valor
nVlFiname  := 0
nVlConsor  := 0
nVlVeicUs  := 0
nVlEntrad  := 0

For nPos := 1 to Len(aX19VS9[2])

	cCor    := "overd"
	cAuxObs := ""
	
	If !aX19VS9[2,nPos,len(aX19VS9[2,nPos])]

		cTpPgE1 := "'"+aX19VS9[2,nPos,nPosTIPPAG]+"'"
		cTpPgE2 := ""

		cTipVSA := FM_SQL("SELECT VSA_TIPO FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG='"+aX19VS9[2,nPos,nPosTIPPAG]+"' AND VSA.D_E_L_E_T_=' '")
		
		Do Case
	
			Case cTipVSA == "1" // Financiamento / Leasing
				cTpPgE1 += ",'RF ','TC ','CMF'"
				cTpPgE2 := "'TC ','RBT'"
				cAuxObs := Alltrim(X3CBOXDESC("VAR_TIPTAB",left(aX19VS9[2,nPos,nPosREFPAG],1)))+" - "
		        For ni := 1 to len(aVSETotal[2])
					If !aVSETotal[2,ni,len(aVSETotal[2,ni])]
			    		If aVSETotal[2,ni,nVSETIPPAG] == aX19VS9[2,nPos,nPosTIPPAG] .and. aVSETotal[2,ni,nVSESEQUEN] == aX19VS9[2,nPos,nPosSEQUEN]
							cAuxObs += Alltrim(substr(aVSETotal[2,ni,nVSEDESCCP],2))+" "+Alltrim( aVSETotal[2,ni,nVSEVALDIG] )+" "
							If left( aVSETotal[2,ni,nVSEDESCCP] ,1) == "4"
								Exit
							EndIf
			        	EndIf
		        	EndIf
				Next
				nVlFinanc += aX19VS9[2,nPos,nPosVALPAG]
	
			Case cTipVSA == "2" // Financiamento Proprio
				cAuxObs := aX19VS9[2,nPos,nPosREFPAG]  // 001/100
			
			Case cTipVSA == "3" // Consorcio
				cAuxObs := IIf(left(aX19VS9[2,nPos,nPosREFPAG],1)=="1",STR0044,STR0045)+" - " // Quitado / Nao Quitado
		        For ni := 1 to len(aVSETotal[2])
					If !aVSETotal[2,ni,len(aVSETotal[2,ni])]
			    		If aVSETotal[2,ni,nVSETIPPAG] == aX19VS9[2,nPos,nPosTIPPAG] .and. aVSETotal[2,ni,nVSESEQUEN] == aX19VS9[2,nPos,nPosSEQUEN]
							cAuxObs += Alltrim(substr( aVSETotal[2,ni,nVSEDESCCP] ,2))+" "+Alltrim( aVSETotal[2,ni,nVSEVALDIG] )+" "
			        	EndIf
		        	EndIf
				Next
				nVlConsor += aX19VS9[2,nPos,nPosVALPAG]
	
			Case cTipVSA == "4" // Veiculo Usado (Avaliacoes)
				cQuery := "SELECT VAZ.VAZ_PLAVEI , VAZ.VAZ_FABMOD , VAZ.VAZ_CODMAR , VV2.VV2_DESMOD FROM "+RetSqlName("VAZ")+" VAZ "
				cQuery += "INNER JOIN "+RetSQLName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VAZ.VAZ_CODMAR AND VV2.VV2_MODVEI=VAZ.VAZ_MODVEI AND VV2.D_E_L_E_T_ = ' ' ) "
				cQuery += "WHERE VAZ.VAZ_FILIAL='"+xFilial("VAZ")+"' AND VAZ.VAZ_CODIGO='"+aX19VS9[2,nPos,nPosREFPAG]+"' AND VAZ.D_E_L_E_T_=' ' ORDER BY VAZ.VAZ_REVISA DESC "
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAux, .F., .T. )
				If !(cSQLAux)->( Eof() )
					cAuxObs := Transform((cSQLAux)->( VAZ_PLAVEI ),VV1->(x3Picture("VV1_PLAVEI")))+" - "+Transform((cSQLAux)->( VAZ_FABMOD ),VV1->(x3Picture("VV1_FABMOD")))+" - "+(cSQLAux)->( VAZ_CODMAR )+" "+(cSQLAux)->( VV2_DESMOD )
				EndIf
				(cSQLAux)->( dbCloseArea() )
				nVlVeicUs += aX19VS9[2,nPos,nPosVALPAG]
	
			Case cTipVSA == "5" // Entradas
		        For ni := 1 to len(aVSETotal[2])
					If !aVSETotal[2,ni,len(aVSETotal[2,ni])]
			    		If aVSETotal[2,ni,nVSETIPPAG] == aX19VS9[2,nPos,nPosTIPPAG] .and. aVSETotal[2,ni,nVSESEQUEN] == aX19VS9[2,nPos,nPosSEQUEN]
							cAuxObs += Alltrim(aVSETotal[2,ni,nVSEDESCCP])+": "+Alltrim( aVSETotal[2,ni,nVSEVALDIG] )+", "
			        	EndIf
		        	EndIf
				Next
				nVlEntrad += aX19VS9[2,nPos,nPosVALPAG]

			Case cTipVSA == "6" // Finame
				cAuxObs := M->VV0_CLFINA+"-"+M->VV0_LJFINA+" "
				cAuxObs += Alltrim(left(FM_SQL("SELECT SA1.A1_NOME FROM "+RetSQLName("SA1")+" SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD='"+M->VV0_CLFINA+"' AND SA1.A1_LOJA='"+M->VV0_LJFINA+"' AND SA1.D_E_L_E_T_=' '"),20))+" "
				cAuxObs += "( "+STR0003+": "+Alltrim(M->VV0_CFINAM)+" - "+STR0046+": "+Alltrim(M->VV0_NFINAM)+" )" // Finame / Nro.PAC
				nVlFiname += aX19VS9[2,nPos,nPosVALPAG]

		EndCase
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verificar Titulos ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aX19VS9[2,nPos,nPosPARCEL])
			////////////////////////////////////////////////
			// Veirifica se ja existe baixa para o Titulo //
			////////////////////////////////////////////////
			If FS_BAIXADO(cTpPgE1,cTpPgE2,aX19VS9[2,nPos,nPosPARCEL])
				cCor := "overm"
			EndIf
		EndIf
		If nQtdTitulos <= len(aX19CpoPar)
			cCor := "obran"
		EndIf


	Else
	
		cCor := "ocanc"
	
	EndIf

	aX19VS9[2,nPos,nPosDESPAG] := FM_SQL("SELECT VSA.VSA_DESPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG='"+aX19VS9[2,nPos, nPosTIPPAG]+"' AND VSA.D_E_L_E_T_=' '")

	AADD(aX19CpoPar,{ aX19VS9[2,nPos,nPosDATPAG] , aX19VS9[2,nPos,nPosVALPAG] , aX19VS9[2,nPos,nPosTIPPAG] , aX19VS9[2,nPos,nPosDESPAG] , cAuxObs , cCor , nPos } )

Next

//////////////////////////////////////////////////////////////////////////////////////
nVlNegoc := ( nVlFinanc + nVlFinPro + nVlFiname + nVlConsor + nVlVeicUs + nVlEntrad )
//////////////////////////////////////////////////////////////////////////////////////

If len(aX19CpoPar) <= 0
	AADD(aX19CpoPar , { ctod("") , 0 , "" , "" , "" , "overd" , 0 } )
ElseIf len(aX19CpoPar) == 1
	If Empty(aX19CpoPar[1,3]+aX19CpoPar[1,4]+aX19CpoPar[1,5])
		aX19CpoPar[1,1] := ctod("")
		aX19CpoPar[1,2] := 0
		aX19CpoPar[1,6] := "overd"
		aX19CpoPar[1,7] := 0
	EndIf
EndIf
///////////////////////////////////////////////////////////////////
// Gravar aParTotal para verificar o que foi alterado            //
///////////////////////////////////////////////////////////////////
If nVez == 0
	aParTotal := aClone(aX19CpoPar)
EndIf

///////////////////////////////////////////////////////////////////
// Verifica se houve alteracao entre os vetores dos titulos      //
///////////////////////////////////////////////////////////////////
For ni := 1 to len(aX19CpoPar)
	If aX19CpoPar[ni,6] == "overd" .and. len(aParTotal) >= ni
		For nPos := 1 to 5
	   		If aX19CpoPar[ni,nPos] <> aParTotal[ni,nPos]
		   		aX19CpoPar[ni,6] := "oazul"
		   		Exit
	   		EndIf
	 	Next
		nPos := ascan(aMEMOVS9,{|x| x[1] == ni })
		If nPos > 0
			aX19CpoPar[ni,6] := "oazul"
		EndIf
 	EndIf
Next
oLBX19Parc:nAt := 1
oLBX19Parc:SetArray(aX19CpoPar)
oLBX19Parc:bLine := { || { &(aX19CpoPar[oLBX19Parc:nAt,6]) , ;
						Transform(aX19CpoPar[oLBX19Parc:nAt,1],"@D") , ;
						FG_AlinVlrs(Transform(aX19CpoPar[oLBX19Parc:nAt,2],"@E 99,999,999.99")) , ;
						aX19CpoPar[oLBX19Parc:nAt,3]+" - "+aX19CpoPar[oLBX19Parc:nAt,4] , ;
						aX19CpoPar[oLBX19Parc:nAt,5] }}
oLBX19Parc:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Refresh nos Valores        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oVlVeicu:Refresh()
oVlAtend:Refresh()
oVlNegoc:Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza SALDO / DEVOLUCAO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlDevol := 0
nVlSaldo := 0
oVlDevol:lVisible  := .f.
oVlSaldo:lVisible  := .f.
oTitDevol:lVisible := .f.
oTitSaldo:lVisible := .f.
If nVlAtend < nVlNegoc
	nVlDevol := nVlNegoc - nVlAtend
	oTitDevol:lVisible := .t.
	oVlDevol:lVisible  := .t.
	oVlDevol:Refresh()
ElseIf nVlAtend > nVlNegoc
	nVlSaldo := nVlAtend - nVlNegoc
	oTitSaldo:lVisible := .t.
	oVlSaldo:lVisible  := .t.
	oVlSaldo:Refresh()
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_BAIXADO  º Autor ³ Andre Luis Almeida º Data ³ 11/12/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se titulos estao Baixados                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_BAIXADO(cTpPgE1,cTpPgE2,cParcel)
Local cQuery    := ""
Local cQueryAux := ""
Local cSQLAux   := "SQLAUX"
Local lRet      := .f.
Local cNumTit   := "V"+Right(VV9->VV9_NUMATE,TamSx3("E1_NUM")[1]-1)
Local cNumNFI   := VV0->VV0_NUMNFI
Local cPreTit   := &(GetNewPar("MV_PTITVEI","''")) // Prefixo dos Titulos de Veiculos
If left(GetNewPar("MV_TITATEN","0"),1) == "0" // Geracao dos Titulos no momento da geracao da NF
	If !Empty(cNumNFI) // Titulos gerados com o Nro da Nota Fiscal
		SF2->(DbSetOrder(1)) // F2_FILIAL + F2_DOC + F2_SERIE
		If SF2->(DbSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI))
			cPreTit := SF2->F2_PREFIXO
		EndIf
	EndIf
EndIf
cQuery := "SELECT SE1.R_E_C_N_O_ AS RECSE1 FROM "+RetSQLName("SE1")+" SE1 WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
cQuery += "SE1.E1_PREFIXO='"+cPreTit+"' AND "
cQuery += "( SE1.E1_NUM='"+cNumTit+"' "
If !Empty(cNumNFI) // Titulos gerados com o Nro da Nota Fiscal
	cQuery += "OR SE1.E1_NUM='"+cNumNFI+"' "
EndIf
cQuery += ") AND "
If len(cTpPgE1) > 6 // Financiamento
	cQuery += "SE1.E1_TIPO IN ("+cTpPgE1+") AND "
Else
	cQuery += "SE1.E1_TIPO="+cTpPgE1+" AND "
	If cParcel <> NIL
		cQuery += "SE1.E1_PARCELA='"+cParcel+"' AND "
	Else
		cQuery += "SE1.E1_PARCELA=' ' AND "
	EndIf
EndIf
cQuery += "SE1.E1_PREFORI='"+cPrefVEI+"' AND "
cQuery += "( SE1.E1_BAIXA <> ' ' OR SE1.E1_SALDO <> SE1.E1_VALOR ) AND SE1.D_E_L_E_T_=' '"
If FM_SQL(cQuery) > 0
	lRet := .t.
Else
   	If !Empty(cTpPgE2)
		cQuery := "SELECT SE2.R_E_C_N_O_ AS RECSE2 FROM "+RetSQLName("SE2")+" SE2 WHERE SE2.E2_FILIAL='"+xFilial("SE2")+"' AND "
		cQuery += "SE2.E2_NUM='"+cNumTit+"' AND "
		cQuery += "( ( SE2.E2_FORNECE='______' AND SE2.E2_LOJA='__' ) "
		If FGX_SA1SA2(VV9->VV9_CODCLI,VV9->VV9_LOJA,.f.) // Cliente como Fornecedor
			cQuery += " OR ( SE2.E2_FORNECE='"+SA2->A2_COD+"' AND SE2.E2_LOJA='"+SA2->A2_LOJA+"' ) "
		EndIf
		// Levantar todos os Clientes/Lojas de 1=Financiamento como Fornecedor
		cQueryAux := "SELECT VSA.VSA_CODCLI , VSA.VSA_LOJA FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='1' AND VSA.D_E_L_E_T_ = ' ' "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryAux ), cSQLAux , .F. , .T. )
		While !(cSQLAux)->( Eof() )
			If FGX_SA1SA2((cSQLAux)->( VSA_CODCLI ),(cSQLAux)->( VSA_LOJA ),.f.)
				cQuery += " OR ( SE2.E2_FORNECE='"+SA2->A2_COD+"' AND SE2.E2_LOJA='"+SA2->A2_LOJA+"' ) "
	      	EndIf
			(cSQLAux)->(DbSkip())
		EndDo
		(cSQLAux)->(DbCloseArea())
		cQuery += " ) AND SE2.E2_TIPO IN ("+cTpPgE2+") AND ( SE2.E2_BAIXA <> ' ' OR SE2.E2_SALDO <> SE2.E2_VALOR ) AND SE2.D_E_L_E_T_=' '"
		If FM_SQL(cQuery) > 0
			lRet := .t.
		EndIf
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX019BTVLN  º Autor ³ Andre Luis Almeida º Data ³ 11/12/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Opcoes do Botao de Valores da Negociacao                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX019BTVLN(cTp,nOpc,aPar1,aPar2,aPar3,aPar4)
Local cTipVSA    := ""
Local ni         := 0
Local nVSETIPPAG := 0
Local cTpPgE1    := ""
Local cTpPgE2    := ""
Private aAuxHeader := {}
Default aPar1 := {}
Default aPar2 := {}
Default aPar3 := {}
aAuxHeader := aClone(aPar2[1]) // Compatibilizacao com FG_POSVAR
nPosTIPPAG := FG_POSVAR("VS9_TIPPAG","aAuxHeader")
If Len(aPar3) > 0
	aAuxHeader := aClone(aPar3[1]) // Compatibilizacao com FG_POSVAR
	nVSETIPPAG := FG_POSVAR("VSE_TIPPAG","aAuxHeader")
EndIf
If cTp == "1" // Financiamento FI / Leasing
	If VV9->VV9_STATUS == "F"
//		MsgStop(STR0039,STR0032) // Atendimento ja Finalizado. Impossivel Incluir/Alterar Financimento/Leasing! / Atencao
//		Return()
		If !MsgYesNo("Alteração no Financiamento/Leasing para Atendimento Finalizado pode acarretar problemas nos módulos Fiscal e Financeiro. Deseja continuar?",STR0032) // Atencao
			Return()
		EndIf
	EndIf
	For ni := 1 to Len(aPar2[2])
		If !aPar2[2,ni,len(aPar2[2,ni])]
			cTipVSA := FM_SQL("SELECT VSA_TIPO FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG='"+aPar2[2,ni,nPosTIPPAG]+"' AND VSA.D_E_L_E_T_=' '")
			If cTipVSA == "1" // Financiamento / Leasing
				cTpPgE1 := "'"+aPar2[2,ni,nPosTIPPAG]+"','RF ','TC ','CMF'"
				cTpPgE2 := "'TC ','RBT'"
				If FS_BAIXADO(cTpPgE1,cTpPgE2,"")
					MsgStop(STR0040,STR0032) // Ha Titulos ja baixados. Impossivel Incluir/Alterar Financimento/Leasing! / Atencao
					Return()
				EndIf
				Exit
			EndIf
		EndIf
	Next
	If VEIXX005(4,@aPar1,@aPar2,@aPar3)	// ( nOpc / aParFin / aVS9 / aVSE )
        For ni := 1 to len(aVSETotal[2])
			cTipVSA := FM_SQL("SELECT VSA.VSA_TIPO FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG='"+aVSETotal[2,ni,nVSETIPPAG]+"' AND VSA.D_E_L_E_T_=' '")
        	If cTipVSA == "1"
				aVSETotal[2,ni,len(aVSETotal[2,ni])] := .t.
        	EndIf
		Next
        For ni := 2 to len(aPar3[2])
			aAdd(aVSETotal[2],aClone(aPar3[2,ni]))
		Next
		VX019ATTELA(@aPar2,1,@aPar4)
	EndIf	
ElseIf cTp == "4" // Consorcio
	If VEIXX010(4,@aPar1,@aPar2,@aPar3)	// ( nOpc / aParCon / aVS9 / aVSE )
        For ni := 1 to len(aVSETotal[2])
			cTipVSA := FM_SQL("SELECT VSA.VSA_TIPO FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG='"+aVSETotal[2,ni,nVSETIPPAG]+"' AND VSA.D_E_L_E_T_=' '")
        	If cTipVSA == "3"
				aVSETotal[2,ni,len(aVSETotal[2,ni])] := .t.
        	EndIf
		Next
        For ni := 1 to len(aPar3[2])
			aAdd(aVSETotal[2],aClone(aPar3[2,ni]))
		Next
		VX019ATTELA(@aPar2,1,@aPar4)
	EndIf
ElseIf cTp == "5" // Veiculo Usado
	If VEIXX008(4,@aPar1,@aPar2)			// ( nOpc / aParUsa / aVS9 )
		VX019ATTELA(@aPar2,1,@aPar4)
	EndIf
ElseIf cTp == "6" // Entrada
	If VEIXX011(4,@aPar1,@aPar2,@aPar3)	// ( nOpc / aParEnt / aVS9 / aVSE )
        For ni := 1 to len(aVSETotal[2])
			cTipVSA := FM_SQL("SELECT VSA.VSA_TIPO FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG='"+aVSETotal[2,ni,nVSETIPPAG]+"' AND VSA.D_E_L_E_T_=' '")
        	If cTipVSA == "5"
				aVSETotal[2,ni,len(aVSETotal[2,ni])] := .t.
        	EndIf
		Next
        For ni := 1 to len(aPar3[2])
			aAdd(aVSETotal[2],aClone(aPar3[2,ni]))
		Next
		VX019ATTELA(@aPar2,1,@aPar4)
	EndIf
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX019DTVS9º Autor ³ Andre Luis Almeida º Data ³  11/12/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Alteracao das Datas/Observacao do Titulo no VS9            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX019DTVS9(nOpc,cNumAte,aX19VS9,nLinhaVS9,aCompParc,nLinhaParc)
Local lOk        := .t.
Local nOpcao     := 0
Local ni         := 0
Local dDatTit    := dDataBase
Local cVSATipo   := ""
Local cObserv    := ""
Local cObsNew    := ""
Local nPosNUMIDE := 0
Local nPosTIPOPE := 0
Local nPosTIPPAG := 0
Local nPosSEQUEN := 0
Local nPosDATPAG := 0
Local nPosOBSMEM := 0
If Empty(aCompParc[nLinhaParc,3]+aCompParc[nLinhaParc,4]+aCompParc[nLinhaParc,5])
	Return()
EndIf
/////////////////////////////////////
// Posiciona no VS9 correspondente //
/////////////////////////////////////
aAuxHeader := aClone(aX19VS9[1]) // Compatibilizacao com FG_POSVAR
nPosNUMIDE := FG_POSVAR("VS9_NUMIDE","aAuxHeader")
nPosTIPOPE := FG_POSVAR("VS9_TIPOPE","aAuxHeader")
nPosTIPPAG := FG_POSVAR("VS9_TIPPAG","aAuxHeader")
nPosSEQUEN := FG_POSVAR("VS9_SEQUEN","aAuxHeader")
nPosDATPAG := FG_POSVAR("VS9_DATPAG","aAuxHeader")
nPosOBSMEM := FG_POSVAR("VS9_OBSMEM","aAuxHeader")
DbSelectArea("VS9")
DbSetOrder(1)
If DbSeek(xFilial("VS9")+aX19VS9[2,nLinhaVS9,nPosNUMIDE]+aX19VS9[2,nLinhaVS9,nPosTIPOPE]+aX19VS9[2,nLinhaVS9,nPosTIPPAG]+aX19VS9[2,nLinhaVS9,nPosSEQUEN])
	cObserv := IIf(!Empty(aCompParc[nLinhaParc,5]),aCompParc[nLinhaParc,5]+CHR(13)+CHR(10)+repl("_",TamSx3("VS9_OBSERV")[1])+CHR(13)+CHR(10),"")
	cObserv += E_MSMM(aX19VS9[2,nLinhaVS9,nPosOBSMEM],TamSx3("VS9_OBSERV")[1])
EndIf
If aCompParc[nLinhaParc,6] == "overm"
	lOk := .f.
Else
	If ( nOpc == 3 .or. nOpc == 4 ) // Incluir ou Alterar
		cVSATipo := FM_SQL("SELECT VSA.VSA_TIPO FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG='"+aCompParc[nLinhaParc,3]+"' AND VSA.D_E_L_E_T_=' '")
		If cVSATipo == "1" // Financiamento/Leasing
			If VV9->VV9_STATUS == "F" // Finalizado
		   		lOk := .f.
	   		EndIf
		ElseIf cVSATipo == "2" // Financiamento Proprio
			lOk := .f.
		EndIf
	Else
		lOk := .f.
	EndIf
EndIf
/////////////////////////////////////////////////////////////////////
// Tela de Alteracao da Data e Visualizacao das Observacoes do VS9 //
/////////////////////////////////////////////////////////////////////
dDatTit := aCompParc[nLinhaParc,1]
ni := ascan(aMEMOVS9,{|x| x[1] == nLinhaParc })
If ni > 0
	cObsNew := aMEMOVS9[ni,2]
EndIf
DEFINE MSDIALOG oVX019DTVS9 TITLE (aCompParc[nLinhaParc,3]+" - "+aCompParc[nLinhaParc,4]) FROM 00,00 TO 370,450 OF oMainWnd PIXEL
@ 007,005 TO 025,220 LABEL "" OF oVX019DTVS9 PIXEL
@ 012,013 SAY STR0024 OF oVX019DTVS9 PIXEL COLOR CLR_HBLUE // Data
@ 011,045 MSGET oDatTit VAR dDatTit PICTURE "@D" SIZE 45,08 OF oVX019DTVS9 VALID dDatTit>=dDataBase PIXEL HASBUTTON WHEN lOk
@ 012,125 SAY STR0025 OF oVX019DTVS9 PIXEL COLOR CLR_BLACK // Valor
@ 011,160 MSGET oValPag VAR aCompParc[nLinhaParc,2] PICTURE "@E 999,999,999.99" SIZE 50,08 OF oVX019DTVS9 PIXEL WHEN .f.
@ 030,005 TO 170,220 LABEL STR0027 OF oVX019DTVS9 PIXEL // Observacao
If lOk
	@ 118,009 GET oObsNew VAR cObsNew OF oVX019DTVS9 MEMO SIZE 207,048 PIXEL
	DEFINE SBUTTON FROM 172,150 TYPE 1 ACTION (nOpcao:=1,oVX019DTVS9:End()) ENABLE OF oVX019DTVS9
Else
	@ 118,009 GET oObsNew VAR cObsNew OF oVX019DTVS9 MEMO SIZE 207,048 PIXEL ReadOnly MEMO
EndIf
@ 038,009 GET oObserv VAR cObserv OF oVX019DTVS9 MEMO SIZE 207,080 PIXEL ReadOnly MEMO
DEFINE SBUTTON FROM 172,185 TYPE 2 ACTION (oVX019DTVS9:End()) ENABLE OF oVX019DTVS9
ACTIVATE MSDIALOG oVX019DTVS9 CENTER
If lOk .and. nOpcao == 1
	If !Empty(cObsNew) .or. ( dDatTit <> aCompParc[nLinhaParc,1] )
		ni := ascan(aMEMOVS9,{|x| x[1] == nLinhaParc })
		If ni <= 0
			aadd(aMEMOVS9,{nLinhaParc,""})
			ni := len(aMEMOVS9)
		EndIf
		aMEMOVS9[ni,2] := cObsNew
		aX19VS9[2,nLinhaVS9,nPosDATPAG] := dDatTit
		VX019ATTELA(@aX19VS9,1)
	EndIf
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX019VMANUTº Autor ³ Andre Luis Almeida º Data ³  11/12/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Visualiza Historico de Manutencao do Atendimento de Veiculoº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX019VMANUT(cFilAte,cNumAte)
Local aObjects  := {} , aPos := {} , aInfo := {} 
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cObserv   := ""
Local aManut    := {}
Local cStatus   := ""
Local nCntFor   := 0
DbSelectArea("VV0")
DbSetOrder(1)
DbSeek(cFilAte+cNumAte)
// Fator de reducao 80%
For nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
Next   
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
cObserv := E_MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1])
AAdd( aObjects, { 0, IIf(!Empty(cObserv),90,0), .T. , .f. } ) // MEMO VV0
AAdd( aObjects, { 0,  0, .T. , .T. } ) // Manutencao do Atendimento
aPos := MsObjSize( aInfo, aObjects )
/////////////////////////////////////
// Levanta Historico de Manutencao //
/////////////////////////////////////
DbSelectArea("VMA")
DbSetOrder(1)
DbSeek(xFilial("VMA")+cFilAte+cNumAte)
While !Eof() .and. VMA->VMA_FILIAL == xFilial("VMA") .and. VMA->VMA_FILATE == cFilAte .and. VMA->VMA_NUMATE == cNumAte
	cStatus := ""
	If VMA->VMA_STATUS == "L"
		cStatus := STR0041 // Aprovado
	ElseIf VMA->VMA_STATUS == "F"
		cStatus := STR0042 // Finalizado
	EndIf
	VS0->(DbSetOrder(1))
	VS0->(DbSeek( xFilial("VS0") + "000005" + VMA->VMA_MOTIVO )) // "000005" - Filtro da consulta do motivo de Manutencao (Atendimento de Veiculos)
	aadd(aManut,{cStatus,Transform(VMA->VMA_DATMAN,"@D"),Transform(VMA->VMA_HORMAN,"@R 99:99"),left(Alltrim(UsrRetName(VMA->VMA_USUMAN)),15),VMA->VMA_MOTIVO+" - "+VS0->VS0_DESMOT})
	DbSelectArea("VMA")
	DbSkip()
EndDo
If len(aManut) <= 0
	aadd(aManut,{"","","","",""})
EndIf
DEFINE MSDIALOG oVX019VMAN TITLE (STR0043+" "+cNumAte) FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Historico de Manutencao do Atendimento
	oVX019VMAN:lEscClose := .F.
	@ aPos[1,1]+3,aPos[1,2] GET oObserv VAR cObserv OF oVX019VMAN MEMO SIZE aPos[1,4]-2,aPos[1,3]-12 PIXEL ReadOnly MEMO
	@ aPos[2,1]+IIf(!Empty(cObserv),3,0),aPos[2,2] LISTBOX oLboxManut FIELDS HEADER STR0029,STR0024,STR0028,STR0030,STR0031 COLSIZES 60,30,25,60,150 SIZE aPos[2,4]-2,aPos[2,3]-IIf(!Empty(cObserv),106,12) OF oVX019VMAN PIXEL
	oLboxManut:SetArray(aManut)
	oLboxManut:bLine := { || { aManut[oLboxManut:nAt,01],aManut[oLboxManut:nAt,02],aManut[oLboxManut:nAt,03],aManut[oLboxManut:nAt,04],aManut[oLboxManut:nAt,05]}}
ACTIVATE MSDIALOG oVX019VMAN CENTER ON INIT (EnchoiceBar(oVX019VMAN,{|| oVX019VMAN:End() },{ || oVX019VMAN:End()},,))
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX019LEG  º Autor ³ Andre Luis Almeida º Data ³  11/12/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Legenda da Composicao das Parcelas                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX019LEG()
Local aLegenda := {	{'BR_VERDE'   ,STR0013},; // Titulo sem manutencao
					{'BR_BRANCO'  ,STR0014},; // Titulo Incluido
					{'BR_AZUL'    ,STR0015},; // Titulo Alterado
					{'BR_VERMELHO',STR0016},; // Titulo Baixado
					{'BR_CANCEL'  ,STR0017}}  // Titulo Excluido
BrwLegenda(STR0012,STR0008,aLegenda) //Composicao das Parcelas / Legenda
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX019VVA  º Autor ³ Andre Luis Almeida º Data ³  13/12/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Mostrar Veiculos (VVA) do Atendimento                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX019VVA(aVVAs)
Local aObjects  := {} , aPos := {} , aInfo := {} 
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor   := 1
For nCntFor := 1 to len(aVVAs)
    If Empty(aVVAs[nCntFor,5])
		aVVAs[nCntFor,5] := FM_SQL("SELECT VV2_DESMOD FROM "+RetSQLName("VV2")+" WHERE VV2_FILIAL='"+xFilial("VV2")+"' AND VV2_CODMAR='"+aVVAs[nCntFor,3]+"' AND VV2_MODVEI='"+aVVAs[nCntFor,4]+"' AND D_E_L_E_T_=' '")
	EndIf
    If Empty(aVVAs[nCntFor,7])
		aVVAs[nCntFor,7] := FM_SQL("SELECT VVC_DESCRI FROM "+RetSQLName("VVC")+" WHERE VVC_FILIAL='"+xFilial("VVC")+"' AND VVC_CODMAR='"+aVVAs[nCntFor,3]+"' AND VVC_CORVEI='"+aVVAs[nCntFor,6]+"' AND D_E_L_E_T_=' '")
	EndIf
	If Empty(aVVAs[nCntFor,8]) .and. !Empty(aVVAs[nCntFor,1])
		aVVAs[nCntFor,8] := Transform(FM_SQL("SELECT VV1_PLAVEI FROM "+RetSQLName("VV1")+" WHERE VV1_FILIAL='"+xFilial("VV1")+"' AND VV1_CHAINT='"+aVVAs[nCntFor,1]+"' AND D_E_L_E_T_=' '"),x3Picture("VV1_PLAVEI"))
	EndIf
Next
// Fator de reducao 80%
For nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
Next   
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0,  0, .T. , .T. } ) // Consorcio
aPos := MsObjSize( aInfo, aObjects )
DbSelectArea("VV1")
DEFINE MSDIALOG oTelaVVA TITLE STR0047 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Veiculo(s)
	oTelaVVA:lEscClose := .F.
	@ aPos[1,1],aPos[1,2] LISTBOX oLboxVVA FIELDS HEADER STR0048,STR0049,STR0050,STR0051,STR0052,STR0053 COLSIZES 25,80,20,100,60,35 SIZE aPos[1,4],aPos[1,3]-aPos[1,1] OF oTelaVVA PIXEL ON DBLCLICK IIf(!Empty(aVVAs[oLboxVVA:nAt,02]),VEIVC140(aVVAs[oLboxVVA:nAt,02],aVVAs[oLboxVVA:nAt,01]),.t.) // ChaInt / Chassi / Marca / Modelo / Cor / Placa
	oLboxVVA:SetArray(aVVAs)
	oLboxVVA:bLine := { || { aVVAs[oLboxVVA:nAt,01] , aVVAs[oLboxVVA:nAt,02] , aVVAs[oLboxVVA:nAt,03] , aVVAs[oLboxVVA:nAt,05] , aVVAs[oLboxVVA:nAt,07] , aVVAs[oLboxVVA:nAt,08] }}
ACTIVATE MSDIALOG oTelaVVA CENTER ON INIT (EnchoiceBar(oTelaVVA,{|| oTelaVVA:End()},{ || oTelaVVA:End()},,))
Return()