#INCLUDE "TMSAF99.ch"
#INCLUDE "Protheus.ch"

//-- Poscionamento de Matrizes

#DEFINE VG_QTDCOL  11 //-- Viagens
#DEFINE VG_FILORI   1
#DEFINE VG_VIAGEM   2
#DEFINE VG_KM       3
#DEFINE VG_PESO     4
#DEFINE VG_PESOM3   5
#DEFINE VG_VALMER   6
#DEFINE VG_QTDVOL   7
#DEFINE VG_VALRAT   8
#DEFINE VG_TMPVGE   9
#DEFINE VG_SERTMS  10
#DEFINE VG_CODVEI  11

#DEFINE VE_QTDCOL  15 //-- Veículos
#DEFINE VE_CODVEI   1
#DEFINE VE_KM       2
#DEFINE VE_PESO     3
#DEFINE VE_PESOM3   4
#DEFINE VE_VALMER   5
#DEFINE VE_QTDVOL   6
#DEFINE VE_KMCOL    7
#DEFINE VE_KMTRA    8
#DEFINE VE_KMENT    9
#DEFINE VE_CATVEI  10
#DEFINE VE_TMPCOL  11
#DEFINE VE_TMPTRA  12
#DEFINE VE_TMPENT  13
#DEFINE VE_SRTVEI  14
#DEFINE VE_FILBAS  15	

#DEFINE MN_QTDCOL   7 //-- Manutenção de Veículos
#DEFINE MN_CODSERV  1
#DEFINE MN_CODPROD  2
#DEFINE MN_CODBEM   3
#DEFINE MN_CUSTO    4
#DEFINE MN_GRPEST   5
#DEFINE MN_CODVEI   6
#DEFINE MN_FILBAS   7 

#DEFINE MO_QTDCOL  12 //-- Motoristas
#DEFINE MO_FILORI   1
#DEFINE MO_VIAGEM   2
#DEFINE MO_CODVEI   3
#DEFINE MO_CODMOT   4
#DEFINE MO_MATRIC   5
#DEFINE MO_FILBAS   6
#DEFINE MO_CUSTO    7
#DEFINE MO_KM       8
#DEFINE MO_PESO     9
#DEFINE MO_TEMPO   10
#DEFINE MO_VALHOR  11
#DEFINE MO_SERMOT  12

#DEFINE MS_QTDCOL   7 //-- Quantidade de Colunas em ValMotSVg
#DEFINE MS_FILORI   1
#DEFINE MS_CODMOT   2
#DEFINE MS_MATRIC   3
#DEFINE MS_FILBAS   4
#DEFINE MS_CUSTO    5
#DEFINE MS_VALHOR   6
#DEFINE MS_SERMOT   7

#DEFINE VS_QTDCOL   6 //-- Quantidade de Colunas em aDepVeiSVg
#DEFINE VS_CODVEI   1
#DEFINE VS_CUSVEI   2
#DEFINE VS_SERVEI   3
#DEFINE VS_TABVEI   4
#DEFINE VS_FILBAS   5
#DEFINE VS_CODDES   6

STATIC lTMA99CTF := ExistBlock("TMA99CTF")
STATIC lTMA99RAT := ExistBlock("TMA99RAT")

//-- Conteúdo dos ARRAY´s utilizados no processo...

//-- ARRAY aQtdVge
//-- [01] - No.da Viagem
//-- [02] - Km da Viagem
//-- [03] - Peso
//-- [04] - Peso Cubado
//-- [05] - Valor Mercadoria
//-- [06] - Quantidade Volume
//-- [07] - Valor Rateado
//-- [08] - Tempo Viagem
//-- [09] - Tipo da Viagem
//-- [10] - Veículo da Viagem

//-- ARRAY aQtdVei
//-- [01] - Codigo do Veiculo
//-- [02] - Km Total do Veiculo
//-- [03] - Peso Real Transportado
//-- [04] - Peso Cubado Transportado
//-- [05] - Valor de Mercadoria Transportada
//-- [06] - Qtde. de volume Transportado
//-- [07] - Km Viagens de Coleta
//-- [08] - Km Viagens de Transporte
//-- [09] - Km Viagens de Entrega
//-- [10] - Categoria do Veículo
//-- [11] - Tempo da viagem de coleta
//-- [12] - Tempo da viagem de transferência
//-- [13] - Tempo da viagem de entrega
//-- [14] - Serviço do veículo

//-- ARRAY aMntBem
//-- [01] - Código do Serviço
//-- [02] - Código do Produto
//-- [03] - Código do Bem
//-- [04] - Custo do Recurso
//-- [05] - Grupo de Estoque
//-- [06] - Código Veículo

//-- ARRAY aMotVge
//-- [01] - Filial origem
//-- [02] - Número da viagem
//-- [03] - Codigo do veículo da viagem em que o motorista esteve alocado
//-- [04] - Codigo do motorista
//-- [05] - Matricula do motorista no sistema SIGAGPE
//-- [06] - Filial de base do veiculo
//-- [07] - Filial base do motorista
//-- [08] - Custo total do motorista (SIGAGPE)
//-- [09] - KM total da viagem
//-- [10] - Peso total da viagem
//-- [11] - Tempo da viagem
//-- [12] - Km total do motorista alocado na viagem
//-- [13] - Tempo total do motorista alocado na viagem
//-- [14] - Custo hora do motorista
//-- [15] - Serviço(s) prestado(s) - Coleta / Transferência / Entrega

//-- ARRAY aMotSVg
//-- [01] - Filial origem
//-- [02] - Codigo do motorista
//-- [03] - Matricula do motorista no sistema SIGAGPE
//-- [04] - Filial base do motorista
//-- [05] - Custo total do motorista (SIGAGPE)
//-- [06] - Serviço(s) prestado(s) - Coleta / Transferência / Entrega

//-- ARRAY aDepVeiSVg
//-- [01] - Veículo
//-- [02] - Custo
//-- [03] - Serviço do Veículo
//-- [04] - Tipo Tabela (Depreciação/Manutenção/Abastecimentos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSAF99  ³ Autor ³ Richard Anderson      ³ Data ³25/Jun/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cálculo de Custos de Transporte                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF99()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAF99() 
                                                                                           
Local   aCores    := {}
Private cCadastro := STR0001 //-- "Custos de Transporte"
Private aRotina	:=	{ { STR0002 ,"AxPesqui"  , 0, 1, 0, .F. },;	//"Pesquisar"
     					   {   STR0003 ,"TMSAF99Mnt", 0, 2, 0, NIL },;	//"Visualizar"
					      {   STR0004 ,"TMSAF99Cal", 0, 3, 0, NIL },;	//"Calcular"
					      {   STR0005 ,"TMSAF99Exc", 0, 5, 0, NIL },;	//"Cancelar"
					      {   STR0012 ,"TMSAF99Leg", 0, 6, 0, NIL } } 	//"Legenda" 						      

Aadd( aCores, { "DFJ_STATUS == '1'", 'BR_AMARELO'} ) // 'Em Processo
Aadd( aCores, { "DFJ_STATUS == '2'", 'BR_AZUL'   } ) // 'Processado
Aadd( aCores, { "DFJ_STATUS == '9'", 'BR_PRETO'  } ) // 'Cancelado'

dbSelectArea('SDG')

dbSelectArea('DFJ')
dbSetOrder(1)
mBrowse(,,,,'DFJ',,,,,,aCores)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF99Mnt³ Autor ³ Richard Anderson      ³ Data ³ 26/Jun/07 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutenção do cálculo de custos de transporte              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF99Est()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAF99                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSAF99Mnt(cAlias,nReg,nOpcx)

Local   aArea      := GetArea()
Local   aInfoCusto := {}  
Private bProcess   := {|| .F. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VerIfica se esta' vizualizando um registro da mesma filial            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo						     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory(cAlias, .F., .F. )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis para campos Memos Virtuais						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Aadd( aInfoCusto, { "Visualizar", { | oCenterPanel | TMSAF99Vis('DFJ',2,Recno(),oCenterPanel) }, "PRECO" } )

tNewProcess():New( 'TMSAF99', STR0001, bProcess, STR0001,, aInfoCusto )

RestArea(aArea)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF99Vis³ Autor ³ Richard Anderson      ³ Data ³ 26/Jun/07 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutenção do cálculo de custos de transporte              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF99Est()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAF99                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSAF99Vis(cAlias,nReg,nOpcx, oObj)

Local   aArea    := GetArea()
Local   cMemo    := ""
LOcal   nX       := 0
Local   lVirtual := .F. // Qdo .F. carrega inicializador padrao nos campos virtuais
Local   aAcho      := {}
Local 	aFldTmp		:= {}

Private aTELA[0][0]
Private aGETS[0]
Private aMsgErr

aFldTmp := ApBuildHeader(cAlias, {"DFJ_NOMUSR"})
For nX := 1 To Len(aFldTmp)
	aAdd(aAcho, aFldTmp[nX][2])
Next

aSize(aFldTmp, 0)
aFldTmp := Nil
                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VerIfica se esta' vizualizando um registro da mesma filial            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo						     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory(cAlias, .F., .F. )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis para campos Memos Virtuais						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("aMemos")=="A"
	For nX := 1 To Len(aMemos)
		cMemo := aMemos[nX][2]
		If ExistIni(cMemo)
			&cMemo := InitPad(GetSX3Cache(cMemo, "X3_RELACAO"))
		Else
			&cMemo := ""
		EndIf
	Next nX
EndIf

EnChoice( cAlias, nReg, 2,,,, aAcho, { 0, 0, oObj:nHeight, oObj:nWidth },,,,,, oObj,,lVirtual)

RestArea(aArea)

Return NIL 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF99Cal³ Autor ³ Richard Anderson      ³ Data ³ 26/Jun/07 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cálculo de custos de transporte                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF99Cal()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAF99                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSAF99Cal(cAlias,nReg,nOpcx)

Local cPerg      := "TMAF99"
Local aInfoCusto := {}
Local lTemDg := SDG->(ColumnPos("DG_GERADOR") > 0) .And. SDG->(ColumnPos("DG_TIPGER") > 0) // Verifica campos ausentes SDG

If lTemDG 
    If LockByName( "TMSAF99", .T., .F. ) 

        Pergunte(cPerg,.F.)

        bProcess := { |oSelf| Iif( TMSAF99Vld( nOpcx ), TMSAF99Prc( oSelf ), .f. ) }

        tNewProcess():New( 'TMSAF99', STR0001, bProcess, ( STR0006 + STR0007 ), cPerg, aInfoCusto )

        UnLockByName( "TMSAF99", .T., .F. ) // Libera Lock

    Else
        Help( "", 1, "TMSAF9909" ) //-- Cálculo de Custo em Processamento.
        Return
    EndIf
Else
    Help("",1,'TMSAF99ATU', ,STR0055, 1, 0, , , , , , {STR0056})  //-- "Favor entrar em contato com o suporte Totvs para atualizar a rotina de Custos - TMSAF99" - . //"Verifique o ausência dos campos (DG_GERADOR) e (DG_TIPGER)."
    Return 
EndIf 
    
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF99Exc³ Autor ³ Richard Anderson      ³ Data ³ 26/Jun/07 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cancelamento do cálculo de custos de transporte           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF99Exc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAF99                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSAF99Exc(cAlias,nReg,nOpcx)

Local   aArea      := GetArea()
Local   nOpcB      := 0
Local   aInfoCusto := {}
Private bProcess   := NIL

nOpcB := aRotina[nOpcx,4]

If nOpcB == 5 .And. !TMSAF99Vld(nOpcB)
	Return NIL
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VerIfica se esta' vizualizando um registro da mesma filial            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo						     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory(cAlias, .F., .F. )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis para campos Memos Virtuais						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nOpcB == 5 

	bProcess := { |oSelf| TMSAF99Del( oSelf ) }
	
	Aadd( aInfoCusto, { "Visualizar", { | oCenterPanel | TMSAF99Vis('DFJ',2,Recno(),oCenterPanel) }, "PRECO" } )
	
	tNewProcess():New( 'TMSAF99', STR0001, bProcess, STR0017,, aInfoCusto )

	UnLockByName( "TMSAF99Exc", .T., .F. ) // Libera Lock

Else
	Help( "", 1, "TMSAF9910" ) //-- Cancelamento do Cálculo de Custo em Processamento.
EndIf

RestArea(aArea)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF99Vld³ Autor ³ Richard Anderson      ³ Data ³ 26/Jun/07 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validação do processamento do cálculo de custos            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF99Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAF99                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSAF99Vld(nOpcx)

Local   lRet      := .T.
Local   aAreaDFJ  := DFJ->(GetArea())
Local   cAliasDFJ := GetNextAlias()
Local   cQuery    := ''
Local   lDatInv   := .F.
Local   nCon1     := 0

Local   dDatFTMS  := GetMv("MV_DATATMS",.F.,CtoD(''))
Local   cMvDesDep := GetMv('MV_DESDEP',,'') //-- Despesa de Depreciação
Local   cMvDesVei := GetMv('MV_DESVEI',,'') //-- Despesa de Veículo para custo de viagem
Local   cMvDesAba := GetMv('MV_DESABA',,'') //-- Despesa de Veículo para Abastecimento  
Local   cMvDesMot := GetMv('MV_DESMOT',,'') //-- Despesa de Veículo para custo do motorista
Local   cMvDesPdg := GetMv('MV_DESPDG',,'') //-- Despesa de Pedagio 
Local   cMvDesSeg := GetMv('MV_DESSEG',,'') //-- Despesa de Seguros.

Local   cMvDepSVg := GetMv('MV_DEPSVG',,'') //-- Despesa de Depreciação para Veículos Sem Viagem
Local   cMvMntSVg := GetMv('MV_MNTSVG',,'') //-- Despesa de Manutenção para Veículo Sem Viagem
Local   cMvAmzSVg := GetMv('MV_AMZSVG',,'') //-- Despesa de Amortização para Veículo Sem Viagem
Local   cMvAbtSVg := GetMv('MV_ABTSVG',,'') //-- Despesa de Abastecimento para Veículo Sem Viagem
Local   cMvMotSVg := GetMv('MV_MOTSVG',,'') //-- Despesa de Salário de Motorista Sem Viagem

//--Estes campos foram criados durante a validacao do projeto

If nOpcx == 3	 
	If Empty(mv_par01) .Or. Empty(mv_par02)
		lDatInv := .T.
	ElseIf mv_par01 > mv_par02
		lDatInv := .T.
	ElseIf mv_par02 < mv_par01
		lDatInv := .T.
	ElseIf mv_par01 > dDataBase .Or. mv_par02 > dDataBase
		lDatInv := .T.						
	EndIf
	If lDatInv
		Help('',1,'TMSAF9901') //Intervalo de datas inválido!
		lRet := .F.
	EndIf
	//--Validar os parametros antes do processamento, por eles fazerem parte de alguns processamentos
	DT7->(dbSetOrder(1))	

	If lRet
		If Empty(cMvDesDep)
			Help('',1,'TMSAF9902',,'MV_DESDEP',04,01) //-- Informe o parametro:
			lRet := .F.
		EndIf
		If lRet .And. DT7->(!dbSeek(xFilial('DT7')+cMvDesDep))
			Help('',1,'TMSAF9903',,cMvDesDep,04,01) //-- Verifique a existência da Despesa informada:
			lRet := .F.
		EndIf
	EndIf	
	If lRet
		If Empty(cMvDesVei)
			Help('',1,'TMSAF9902',,'MV_DESVEI',04,01) //-- Informe o parametro:
			lRet := .F.
		EndIf
		If lRet .And. DT7->(!dbSeek(xFilial('DT7')+cMvDesVei))
			Help('',1,'TMSAF9903',,cMvDesVei,04,01) //-- Verifique a existência da Despesa informada:
			lRet := .F.
		EndIf
	EndIf
	If lRet
		If Empty(cMvDesAba)
			Help('',1,'TMSAF9902',,'MV_DESABA',04,01) //-- Informe o parametro:
			lRet := .F.
		EndIf
		If lRet .And. DT7->(!dbSeek(xFilial('DT7')+cMvDesAba))
			Help('',1,'TMSAF9903',,cMvDesAba,04,01) //-- Verifique a existência da Despesa informada:
			lRet := .F.
		EndIf
	EndIf
	If lRet
		If Empty(cMvDesMot)
			Help('',1,'TMSAF9902',,'MV_DESMOT',04,01) //-- Informe o parametro:
			lRet := .F.
		EndIf
		If lRet .And. DT7->(!dbSeek(xFilial('DT7')+cMvDesMot))
			Help('',1,'TMSAF9903',,cMvDesMot,04,01) //-- Verifique a existência da Despesa informada:
			lRet := .F.
		EndIf
	EndIf
	If lRet
		If Empty(cMvDesPdg)
			Help('',1,'TMSAF9902',,'MV_DESPDG',04,01) //-- Informe o parametro:
			lRet := .F.
		EndIf
		If lRet .And. DT7->(!dbSeek(xFilial('DT7')+cMvDesPdg))
			Help('',1,'TMSAF9903',,cMvDesPdg,04,01) //-- Verifique a existência da Despesa informada:
			lRet := .F.
		EndIf
	EndIf			
	If lRet
		cQuery := "SELECT DFJ_DATINI, R_E_C_N_O_ DFJRECNO"
		cQuery += "  FROM "+RetSqlName('DFJ')
		cQuery += " WHERE   DFJ_FILIAL  = '"+xFilial('DFJ')+"'"
		cQuery += "   AND ((DFJ_DATINI >= '"+Dtos(mv_par01)+"' AND DFJ_DATFIM <= '"+Dtos(mv_par02)+"')"
		cQuery += "    OR   DFJ_DATFIM >= '"+Dtos(mv_par02)+"')"
		cQuery += "   AND   DFJ_STATUS IN ( '1', '2' )"
		cQuery += "   AND   D_E_L_E_T_  = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDFJ)
		TCSetField(cAliasDFJ,"DFJ_DATINI","D",TamSx3("DFJ_DATINI")[1],TamSx3("DFJ_DATINI")[2])
		If (cAliasDFJ)->(!Eof()) .And. DFJ->DFJ_STATUS <> '1'
			MsgAlert(STR0008) //-- Cálculo de custos já efetuado nesse período!
			lRet := .F.
		EndIf	
		(cAliasDFJ)->(dbCloseArea())		
		If DFJ->DFJ_STATUS == '1' .And. ((DFJ->DFJ_DATINI >= mv_par01 .And. DFJ->DFJ_DATFIM <= mv_par02) .Or. DFJ->DFJ_DATFIM >= mv_par02)
			lRet := MsgNoYes(STR0018)
		EndIf
	EndIf
	If lRet
		If Iif(FindFunction("MVUlmes"),MVUlmes(),GetMV("MV_ULMES")) >  mv_par01
			Help( " ", 1, "FECHTO" ) //"Nao pode ser digitado movimento com data anterior a ultima data de fechamento (virada de saldos)"
			lRet := .F.
		EndIf
		If lRet .And. !Empty(dDatFTMS)
			If dDatFTMS < mv_par02
				Help( " ", 1, "FECHATMS" )
				lRet := .F.
			EndIf
		EndIf
	EndIf

   If lRet	//-- Despesa de Seguros.
		If Empty(cMvDesSeg)
			Help('',1,'TMSAF9902',,'MV_DESSEG',04,01) //-- Informe o parametro:
			lRet := .F.
		EndIf
		If lRet .And. DT7->(!dbSeek(xFilial('DT7')+cMvDesSeg))
			Help('',1,'TMSAF9903',,cMvDesSeg,04,01) //-- Verifique a existência da Despesa informada:
			lRet := .F.
		EndIf
	EndIf
	
   If lRet	//-- Despesa de Depreciação para Veículos Sem Viagem.
		If Empty(cMvDepSVg)	
			Help('',1,'TMSAF9902',,'MV_DEPSVG',04,01) //-- Informe o parametro:
			lRet := .F.
		EndIf
		If lRet .And. DT7->(!dbSeek(xFilial('DT7')+cMvDepSVg))
			Help('',1,'TMSAF9903',,cMvDepSVg,04,01) //-- Verifique a existência da Despesa informada:
			lRet := .F.
		EndIf
	EndIf

   If lRet	//-- Despesa de Manutenção para Veículo Sem Viagem.
		If Empty(cMvMntSVg)
			Help('',1,'TMSAF9902',,'MV_MNTSVG',04,01) //-- Informe o parametro:
			lRet := .F.
		EndIf
		If lRet .And. DT7->(!dbSeek(xFilial('DT7')+cMvMntSVg))
			Help('',1,'TMSAF9903',,cMvMntSVg,04,01) //-- Verifique a existência da Despesa informada:
			lRet := .F.
		EndIf
	EndIf

   If lRet	//-- Despesa de Amortização para Veículo Sem Viagem.
		If Empty(cMvAmzSVg)
			Help('',1,'TMSAF9902',,'MV_AMZSVG',04,01) //-- Informe o parametro:
			lRet := .F.
		EndIf
		If lRet .And. DT7->(!dbSeek(xFilial('DT7')+cMvAmzSVg))
			Help('',1,'TMSAF9903',,cMvAmzSVg,04,01) //-- Verifique a existência da Despesa informada:
			lRet := .F.
		EndIf
	EndIf

   If lRet	//-- Despesa de Abastecimento para Veículo Sem Viagem.
		If Empty(cMvAbtSVg)
			Help('',1,'TMSAF9902',,'MV_ABTSVG',04,01) //-- Informe o parametro:
			lRet := .F.
		EndIf
		If lRet .And. DT7->(!dbSeek(xFilial('DT7')+cMvAbtSVg))
			Help('',1,'TMSAF9903',,cMvAbtSVg,04,01) //-- Verifique a existência da Despesa informada:
			lRet := .F.
		EndIf
	EndIf

   If lRet	//-- Despesa de Salário de Motorista Sem Viagem.
		If Empty(cMvMotSVg)
			Help('',1,'TMSAF9902',,'MV_MOTSVG',04,01) //-- Informe o parametro:
			lRet := .F.
		EndIf
		If lRet .And. DT7->(!dbSeek(xFilial('DT7')+cMvMotSVg))
			Help('',1,'TMSAF9903',,cMvMotSVg,04,01) //-- Verifique a existência da Despesa informada:
			lRet := .F.
		EndIf
	EndIf

	nCon1 := TMSTcLk(,.T.)
	If nCon1 <> NIL
		If nCon1 < 0 //-- Nao Conectou com o TcLink	
			Help('',1,'TMSAF9904') //-- Verificar as tabelas do SIGAGPE, nao foi possivel conexao no banco de dados!
			lRet := .F. 
		Else
		  	TMSTclK(nCon1,.F.)
	   EndIf 
   EndIf   
Else
	If DFJ->DFJ_STATUS == '9' //-- Cancelado
		Help('',1,'TMSAF9905') //-- Processamento de cálculo já cancelado!
		lRet := .F.
	EndIf
	If lRet
		cQuery  := "SELECT MAX(DFJ_IDCTMS) DFJ_IDCTMS "
		cQuery  += "  FROM "+RetSqlName('DFJ')
		cQuery  += " WHERE DFJ_FILIAL  = '"+xFilial('DFJ')+"'"
		cQuery  += "   AND DFJ_STATUS IN ( '1', '2' )"
		cQuery  += "   AND D_E_L_E_T_  = ' '"
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDFJ)
		If (cAliasDFJ)->(!Eof())
			If (cAliasDFJ)->DFJ_IDCTMS != DFJ->DFJ_IDCTMS
			Help('',1,'TMSAF9905',,DFJ->DFJ_IDCTMS,04,01) //--- Existe processamento de cálculo superior ao ID: 
				lRet := .F.
			EndIf
		EndIf
		(cAliasDFJ)->(dbCloseArea())
	EndIf		
EndIf			
	
RestArea(aAreaDFJ)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF99Prc³ Autor ³ Richard Anderson      ³ Data ³ 26/Jun/07 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processamento do cálculo de custos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF99Prc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAF99                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSAF99Prc( oSelf )
                 
Local nA         := 0
Local nX         := 0
Local nI         := 0
Local cQuery     := ''
Local cIdCTMS    := ''
Local cAliasDFE  := GetNextAlias()
Local cAliasQry  := GetNextAlias()
Local cAliasVge  := GetNextAlias()
Local cAliasDFH  := GetNextAlias()
Local cAliasSTJ  := GetNextAlias()
Local cAliasTQN  := GetNextAlias()
Local cAliasEsp  := GetNextAlias()
Local cAliasDFB  := GetNextAlias()
Local cAliasDT6  := GetNextAlias()
Local cAliasDFJ  := "DFJ"
Local nTempoPrc  := 0
Local dDtIniPrc  := Date()
Local cHrIniPrc  := Left(Time(),5)
Local dDtFimPrc  := Ctod('')
Local cHrFimPrc  := ''

Local aQtdVge    := {}
Local aQtdVei    := {}
Local aMntBem    := {}
Local aMsgErr    := {}
Local aMotVge    := {}
Local aMotSVg    := {}
Local aDepVeiSVg := {}

Local aOpcTra    := {}
Local aDocTms    := {}
Local aFaixas    := {}
Local aLogTmp    := {}
Local aDistRot   := {}
Local aCont      := {}
Local aFiliFSM0  := {}

Local nPQtVei    := 0
Local cCodVei    := ''
Local nQKmVei    := 0
Local nQKmVge    := 0
Local nPQtVge    := 0
Local nPesVge    := 0
Local cTmpVge    := ''

Local nTotKmVge  := 0 //-- Total de Km das Viagens
Local nTotPsVge  := 0 //-- Total de Peso das Viagens
Local nTotP3Vge  := 0 //-- Total de Peso Cubado das Viagens
Local nTotVlVge  := 0 //-- Total de volume das Viagens
Local nTotHrVge  := 0 //-- Total de Horas das Viagens

Local nPerVei    := 0
Local nQKmDoc    := 0
Local cFilOri    := ''
Local cFilBas    := ''
Local cFilBasDA3 := '' 
Local cViagem    := ''
Local cItem      := ''
Local aStruDFH   := DFH->(dbStruct())
Local nVdMes1    := 0, nVdMes2 := 0, nVdMes3 := 0, nVdMes4 := 0, nVdMes5 := 0
Local nCusto1    := 0, nCusto2 := 0, nCusto3 := 0, nCusto4 := 0, nCusto5 := 0
Local nValRt1    := 0, nValRt2 := 0, nValRt3 := 0, nValRt4 := 0, nValRt5 := 0
Local nValRat    := 0

Local cOS        := ''
Local cPlano     := ''
Local nTER       := 0
Local nTRO       := 0
Local nSUB       := 0
Local nAPO       := 0
Local nMDO       := 0

Local nPCust     := 0
Local cPrd       := ''
Local cCodDes    := ''
Local cNumAmz    := ''
Local nMvCargDir := GetMv( 'MV_CARGDIR',, 0 ) //-- Carga Direta
//-- Despesas
Local cMvDesDep  := GetMv( 'MV_DESDEP',, '' ) //-- Despesa de Depreciação.
Local cMvDesVei  := GetMv( 'MV_DESVEI',, '' ) //-- Despesa de Veículo para custo de viagem.
Local cMvDesAba  := GetMv( 'MV_DESABA',, '' ) //-- Despesa de Veículo para Abastecimento.
Local cMvDesMot  := GetMv( 'MV_DESMOT',, '' ) //-- Despesa de Veículo para custo do motorista.
Local cMvDesSeg  := GetMv( 'MV_DESSEG',, '' ) //-- Despesa de Seguros.
Local cMvDesPdg  := GetMv( 'MV_DESPDG',, '' ) //-- Despesa de Pedagio

Local cMvDepSVg  := GetMv( 'MV_DEPSVG',, '' ) //-- Despesa de Depreciação para Veículos Sem Viagem.
Local cMvMntSVg  := GetMv( 'MV_MNTSVG',, '' ) //-- Despesa de Manutenção para Veículo Sem Viagem.
Local cMvAmzSVg  := GetMv( 'MV_AMZSVG',, '' ) //-- Despesa de Amortização para Veículo Sem Viagem.
Local cMvAbtSVg  := GetMv( 'MV_ABTSVG',, '' ) //-- Despesa de Abastecimento para Veículo Sem Viagem.
Local cMvMotSVg  := GetMv( 'MV_MOTSVG',, '' ) //-- Despesa de Salário de Motorista Sem Viagem.

//-- Parametros de Cálculo
Local dDatIni    := mv_par01
Local dDatFim    := mv_par02
Local nRVeiVCol  := mv_par03
Local nRVeiVTra  := mv_par04
Local nRVeiVEnt  := mv_par05
Local nRVColDoc  := mv_par06
Local nRVTraDoc  := mv_par07 //-- Transporte Rodoviario
Local nRVEntDoc  := mv_par08
Local nCoEnPeso  := mv_par09 //-- 1-Peso Real 2-Peso Cubado
Local nTranPeso  := mv_par10 //-- 1-Peso Real 2-Peso Cubado 
Local nRVTrFDoc  := mv_par11 //-- Transporte Fluvial
Local nRVTrEDoc  := mv_par12 //-- Transporte Aereo     
Local nRateDoc   := 0

Local cAuxStr    := ""
Local cFilCta    := ""
Local nCtSMov    := 0
Local nCCSaldo   := 0
Local cConta     := ""
Local cItemCT    := ""
Local cClasCL    := ""
Local cConta2    := ""
Local cItemCT2   := ""
Local cClasCL2   := ""
Local cCtDe      := ""
Local cCtAte     := ""
Local cDocCus    := ""
Local cDocEsp    := ""
Local cAuxDoc    := ""
Local nFx        := 0
Local nTFaixa    := 0
Local nVFaixa    := 0
Local nVCusto    := 0
Local aCotacao   := {1,RecMoeda(Date(),2),RecMoeda(Date(),3),RecMoeda(Date(),4),RecMoeda(Date(),5)}
Local cFilDoc    := ""
Local cDoc       := ""
Local cSerie     := ""
Local cSerTms    := ""
Local cTipTra    := ""
Local nPeso      := 0
Local nPesoM3    := 0
Local nValMer    := 0
Local nValFat    := 0
Local nQtdVol    := 0
Local lCarExp    := .T.
Local lCarRec    := .T.
Local lCarRep    := .T.
Local cDocCar    := ""
Local cFilSTJ    := xFilial("STJ")
Local cFilSTL    := xFilial("STL")
Local cSeekSTL   := ""
Local lCont      := .T.
Local nValCta    := 0
Local lGrpFoun   := .F.
Local cGrpProd   := ''    
Local bSeek      := ''
Local bWhile1    := ''
Local bWhile2    := ''
Local lTM99SPDG  := DA8->(FieldPos('DA8_VLRPDG')) > 0
Local cIntCusGfe := SuperGetMv( 'MV_GFEI21',.F., "3" ) //-- 1-Sob Demanda; 2-Automática; 3-Não integrar

Local nCusVei    := 0
Local cFroVei    := ""
Local cCatVei    := ""
Local cCodMot    := ""

//-- Variaves do Calculo do Manuseio chamada do ponto Solver
Local nFiliais   := 0
Local nPesoM3Ori := 0 
Local cTipCar    := ''
Local cCarExp    := ''
Local cCarRec    := ''
Local cCarRep    := ''
Local cFaixa     := ''
Local nPerRep    := 0
Local nCCDesp    := 0
Local cSrtCus    := ''
Local cTptCus    := ''
Local aTamKm     := TamSx3("DFK_KM")
Local aTamPeso   := TamSx3("DFK_PESO")
Local aTamPesoM3 := TamSx3("DFK_PESOM3")
Local nTamKm     := VAL(Repl('9',((aTamKm[1]-1)-aTamKm[2]))+"."+Repl('9',aTamKm[2]))
Local nTamPeso   := VAL(Repl('9',((aTamPeso[1]-1)-aTamPeso[2]))+"."+Repl('9',aTamPeso[2]))
Local nTamPesoM3 := VAL(Repl('9',((aTamPesoM3[1]-1)-aTamPesoM3[2]))+"."+Repl('9',aTamPesoM3[2]))
Local cAliaTDOC  := ''
Local cAliaTSAL  := ''
Local cAliaTFAI  := ''
Local oTempTDOC	 := Nil
Local oTempTFAI	 := Nil
Local oTempTSAL  := Nil
Local cRealTDOC	 := ""
Local cRealTFAI	 := ""
Local cRealTSAL	 := ""
Local nPesDoc    := 0
Local lNewVge    := .F.
Local lCusto	 := .T.
Local cFilBkp	 := cFilAnt
Local lTMA99GSDG := ExistBlock("TMA99GSDG")
Local nCustoProc := 0
Local cInsert	 := ""

oSelf:SetRegua1( 2 )
oSelf:SetRegua2( 15 )

oSelf:IncRegua1( STR0019 + Dtoc( Date() ) + STR0020 + Left( Time(), 5 ) ) //-- Processo INICIADO em

Aadd(aLogTmp,{ STR0019 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo INICIADO em
oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	
If DFJ->(!Eof()) .And. DFJ->DFJ_STATUS == '1' 
	RecLock('DFJ',.F.)
	DFJ->DFJ_DATCAL := dDataBase
	DFJ->DFJ_HORCAL := StrTran(cHrIniPrc,':','')
	DFJ->DFJ_USRCAL := RetCodUsr()
	DFJ->DFJ_DATINI := dDatIni
	DFJ->DFJ_DATFIM := dDatFim
	DFJ->DFJ_TMPCAL := StrZero(0,Len(DFJ->DFJ_TMPCAL))
	MsUnLock()
	dbCommit()
	cIdCTMS := DFJ->DFJ_IDCTMS 
Else
	cIdCTMS := GetSXENum('DFJ','DFJ_IDCTMS')
	ConfirmSX8()
	
	RecLock('DFJ',.T.)
	DFJ->DFJ_FILIAL := xFilial('DFJ')
	DFJ->DFJ_IDCTMS := cIdCTMS
	DFJ->DFJ_DATCAL := dDataBase
	DFJ->DFJ_HORCAL := StrTran(cHrIniPrc,':','')
	DFJ->DFJ_USRCAL := RetCodUsr()
	DFJ->DFJ_DATINI := dDatIni
	DFJ->DFJ_DATFIM := dDatFim
	DFJ->DFJ_TMPCAL := StrZero(0,Len(DFJ->DFJ_TMPCAL))
	DFJ->DFJ_STATUS := '1' //-- Em Processo 
	DFJ->DFJ_INIPRO := StrZero(0,Len(DFJ->DFJ_INIPRO)) // primeiro processo controlado
	DFJ->DFJ_FIMPRO := StrZero(0,Len(DFJ->DFJ_FIMPRO)) 
	DFJ->(MsUnLock())
	DFJ->(dbCommit())
EndIf	

oSelf:IncRegua2( OemToAnsi( "1-" + STR0021 ) )

IncProc("1-" + STR0021) //-- Odometro Coleta/Transporte/Entrega dos Veiculos processados
Aadd(aLogTmp,{ '1o.' + STR0022 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo iniciado em + Hora
oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])

//-- Obtem quilometragem dos veiculos proprios a partir das viagens encerradas e canceladas no período de cálculo
//-- Km Veiculo
cQuery := "SELECT DUV_CODVEI DUV_CODVEI, DUV_ODOSAI, DUV_ODOENT, DUV_FILORI, DUV_VIAGEM, DTQ_SERTMS, DA3_FROVEI, DUT_CATVEI, DTQ_DATINI, DTQ_HORINI, DTQ_DATFIM, DTQ_HORFIM, DA3_FILBAS " 
cQuery += "  FROM "
cQuery += RetSQLName('DUV')+" DUV, "           
cQuery += RetSQLName('DTQ')+" DTQ, "
cQuery += RetSQLName('DA3')+" DA3, "
cQuery += RetSQLName('DUT')+" DUT  "
cQuery += " WHERE DTQ.DTQ_FILIAL  = '"+xFilial('DTQ')+"'"
cQuery += "   AND DTQ.DTQ_DATENC  BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFim)+"'"
cQuery += "   AND DTQ.DTQ_STATUS IN ( '3', '9' )" //--Encerrado ou Cancelado
cQuery += "   AND DTQ.D_E_L_E_T_  = ' '"
cQuery += "   AND DUV.DUV_FILORI  = DTQ_FILORI"
cQuery += "   AND DUV.DUV_VIAGEM  = DTQ_VIAGEM"
cQuery += "   AND DUV.D_E_L_E_T_  = ' '"
cQuery += "   AND DA3.DA3_FILIAL  = '"+xFilial('DA3')+"'"
cQuery += "   AND DA3.DA3_COD     = DUV_CODVEI"
cQuery += "   AND DA3.D_E_L_E_T_  = ' '"
cQuery += "   AND DUT.DUT_FILIAL  = '"+xFilial('DUT')+"'"
cQuery += "   AND DUT.DUT_TIPVEI  = DA3.DA3_TIPVEI"
cQuery += "   AND DUT.D_E_L_E_T_  = ' '"
//-- Km 1o. Reboque
cQuery += " UNION ALL "
cQuery += "SELECT DUV_CODRB1 DUV_CODVEI, DUV_ODOSR1, DUV_ODOER1, DUV_FILORI, DUV_VIAGEM, DTQ_SERTMS, DA3_FROVEI, DUT_CATVEI, DTQ_DATINI, DTQ_HORINI, DTQ_DATFIM, DTQ_HORFIM, DA3_FILBAS "
cQuery += "  FROM "
cQuery += RetSQLName('DUV')+" DUV, "           
cQuery += RetSQLName('DTQ')+" DTQ, "
cQuery += RetSQLName('DA3')+" DA3, "
cQuery += RetSQLName('DUT')+" DUT  "
cQuery += " WHERE DTQ.DTQ_FILIAL  = '"+xFilial('DTQ')+"'"
cQuery += "   AND DTQ.DTQ_DATENC BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFim)+"'"
cQuery += "   AND DTQ.DTQ_STATUS IN ( '3', '9' )" //--Encerrada e Cancelada
cQuery += "   AND DTQ.D_E_L_E_T_  = ' '"
cQuery += "   AND DUV.DUV_FILORI  = DTQ_FILORI"
cQuery += "   AND DUV.DUV_VIAGEM  = DTQ_VIAGEM"
cQuery += "   AND DUV.DUV_CODRB1 <> ' '"
cQuery += "   AND DUV.D_E_L_E_T_  = ' '"
cQuery += "   AND DA3.DA3_FILIAL  = '"+xFilial('DA3')+"'"
cQuery += "   AND DA3.DA3_COD     = DUV_CODRB1"
cQuery += "   AND DA3.D_E_L_E_T_  = ' '"
cQuery += "   AND DUT.DUT_FILIAL  = '"+xFilial('DUT')+"'"
cQuery += "   AND DUT.DUT_TIPVEI  = DA3.DA3_TIPVEI"
cQuery += "   AND DUT.D_E_L_E_T_  = ' '"
//-- Km 2o. Reboque
cQuery += " UNION ALL "
cQuery += "SELECT DUV_CODRB2 DUV_CODVEI, DUV_ODOSR2, DUV_ODOER2, DUV_FILORI, DUV_VIAGEM, DTQ_SERTMS, DA3_FROVEI, DUT_CATVEI, DTQ_DATINI, DTQ_HORINI, DTQ_DATFIM, DTQ_HORFIM, DA3_FILBAS "
cQuery += "  FROM "
cQuery += RetSQLName('DUV')+" DUV, "
cQuery += RetSQLName('DTQ')+" DTQ, "
cQuery += RetSQLName('DA3')+" DA3, "
cQuery += RetSQLName('DUT')+" DUT  "
cQuery += " WHERE DTQ.DTQ_FILIAL  = '"+xFilial('DTQ')+"'"
cQuery += "   AND DTQ.DTQ_DATENC  BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFim)+"'"
cQuery += "   AND DTQ.DTQ_STATUS IN ( '3', '9' )" //--Encerrado ou Cancelado
cQuery += "   AND DTQ.D_E_L_E_T_  = ' '"
cQuery += "   AND DUV.DUV_FILORI  = DTQ_FILORI"
cQuery += "   AND DUV.DUV_VIAGEM  = DTQ_VIAGEM"
cQuery += "   AND DUV.DUV_CODRB2 <> ' '"
cQuery += "   AND DUV.D_E_L_E_T_  = ' '"
cQuery += "   AND DA3.DA3_FILIAL  = '"+xFilial('DA3')+"'"
cQuery += "   AND DA3.DA3_COD     = DUV_CODRB2"
cQuery += "   AND DA3.D_E_L_E_T_  = ' '"
cQuery += "   AND DUT.DUT_FILIAL  = '"+xFilial('DUT')+"'"
cQuery += "   AND DUT.DUT_TIPVEI  = DA3.DA3_TIPVEI"
cQuery += "   AND DUT.D_E_L_E_T_  = ' '"
If DUV->(ColumnPos('DUV_ODOSR3')) > 0
// -- Km 3o. Reboque 
	cQuery += " UNION ALL "
	cQuery += "SELECT DUV_CODRB3 DUV_CODVEI, DUV_ODOSR3, DUV_ODOER3, DUV_FILORI, DUV_VIAGEM, DTQ_SERTMS, DA3_FROVEI, DUT_CATVEI, DTQ_DATINI, DTQ_HORINI, DTQ_DATFIM, DTQ_HORFIM, DA3_FILBAS "
	cQuery += "  FROM "
	cQuery += RetSQLName('DUV')+" DUV, "
	cQuery += RetSQLName('DTQ')+" DTQ, "
	cQuery += RetSQLName('DA3')+" DA3, "
	cQuery += RetSQLName('DUT')+" DUT  "
	cQuery += " WHERE DTQ.DTQ_FILIAL  = '"+xFilial('DTQ')+"'"
	cQuery += "   AND DTQ.DTQ_DATENC  BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFim)+"'"
	cQuery += "   AND DTQ.DTQ_STATUS IN ( '3', '9' )" //--Encerrado ou Cancelado
	cQuery += "   AND DTQ.D_E_L_E_T_  = ' '"
	cQuery += "   AND DUV.DUV_FILORI  = DTQ_FILORI"
	cQuery += "   AND DUV.DUV_VIAGEM  = DTQ_VIAGEM"
	cQuery += "   AND DUV.DUV_CODRB3 <> ' '"
	cQuery += "   AND DUV.D_E_L_E_T_  = ' '"
	cQuery += "   AND DA3.DA3_FILIAL  = '"+xFilial('DA3')+"'"
	cQuery += "   AND DA3.DA3_COD     = DUV_CODRB3"
	cQuery += "   AND DA3.D_E_L_E_T_  = ' '"
	cQuery += "   AND DUT.DUT_FILIAL  = '"+xFilial('DUT')+"'"
	cQuery += "   AND DUT.DUT_TIPVEI  = DA3.DA3_TIPVEI"
	cQuery += "   AND DUT.D_E_L_E_T_  = ' '"
EndIf
cQuery += " ORDER BY DUV_CODVEI, DUV_FILORI, DUV_VIAGEM"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
TCSetField(cAliasQry,"DUV_ODOENT","N",TamSx3("DUV_ODOENT")[1],TamSx3("DUV_ODOENT")[2])
TCSetField(cAliasQry,"DUV_ODOSAI","N",TamSx3("DUV_ODOSAI")[1],TamSx3("DUV_ODOSAI")[2])
TCSetField(cAliasQry,"DTQ_DATINI","D",8,0)
TCSetField(cAliasQry,"DTQ_DATFIM","D",8,0)
//--- Apuração de Kilometragens
While (cAliasQry)->(!Eof())
	cCodVei := (cAliasQry)->DUV_CODVEI
	cFilOri := (cAliasQry)->DUV_FILORI
	cViagem := (cAliasQry)->DUV_VIAGEM
	cSerTms := (cAliasQry)->DTQ_SERTMS
	cFroVei := (cAliasQry)->DA3_FROVEI
	cCatVei := (cAliasQry)->DUT_CATVEI
	cFilBasDA3 := (cAliasQry)->DA3_FILBAS 
	cTmpVge := TmsTotHora( (cAliasQry)->DTQ_DATINI, (cAliasQry)->DTQ_HORINI, (cAliasQry)->DTQ_DATFIM, (cAliasQry)->DTQ_HORFIM, "@R 999:99" )
	nQKmVge := 0
	lNewVge := .F.
	While (cAliasQry)->(!Eof()) .And. (cAliasQry)->(DUV_CODVEI+DUV_FILORI+DUV_VIAGEM) == cCodVei+cFilOri+cViagem
		If (cAliasQry)->DUV_ODOENT >= (cAliasQry)->DUV_ODOSAI
			nQKmVge += (cAliasQry)->DUV_ODOENT - (cAliasQry)->DUV_ODOSAI
		Else
			//-- Virada de Odometro
			nQKmVge += Val(Replicate('9',TamSx3("DUV_ODOSAI")[1])) - (cAliasQry)->DUV_ODOSAI
			nQKmVge += (cAliasQry)->DUV_ODOENT
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo

	If nQKmVge > 0 .And. AllTrim( cCatVei ) <> '3'
		nPQtVge := Ascan(aQtdVge, { | e | e[VG_FILORI]+e[VG_VIAGEM] == cFilOri+cViagem })
		If nPQtVge == 0

			Aadd( aQtdVge, Array( VG_QTDCOL ) )

			nPQtVge := Len(aQtdVge)

			aQtdVge[ nPQtVge ][ VG_FILORI ] := cFilOri
			aQtdVge[ nPQtVge ][ VG_VIAGEM ] := cViagem
			aQtdVge[ nPQtVge ][ VG_KM     ] := nQKmVge
			aQtdVge[ nPQtVge ][ VG_PESO   ] := 0
			aQtdVge[ nPQtVge ][ VG_PESOM3 ] := 0
			aQtdVge[ nPQtVge ][ VG_VALMER ] := 0
			aQtdVge[ nPQtVge ][ VG_QTDVOL ] := 0
			aQtdVge[ nPQtVge ][ VG_VALRAT ] := 0
			aQtdVge[ nPQtVge ][ VG_TMPVGE ] := cTmpVge
			aQtdVge[ nPQtVge ][ VG_SERTMS ] := cSerTms
			aQtdVge[ nPQtVge ][ VG_CODVEI ] := cCodVei

			lNewVge   := .T.
		nTotKmVge += nQKmVge
		Else
			aQtdVge[nPQtVge,VG_KM] += nQKmVge
		nTotKmVge += nQKmVge
		EndIf
		If cFroVei == '1' //-- Frota Propria
			nPQtVei := Ascan(aQtdVei,{ | e | e[VE_CODVEI] == cCodVei })
			If nPQtVei == 0

				Aadd( aQtdVei, Array( VE_QTDCOL ) )

				nPQtVei := Len(aQtdVei)  

				aQtdVei[ nPQtVei ][ VE_CODVEI ] := cCodVei
				aQtdVei[ nPQtVei ][ VE_KM     ] := 0
				aQtdVei[ nPQtVei ][ VE_PESO   ] := 0
				aQtdVei[ nPQtVei ][ VE_PESOM3 ] := 0
				aQtdVei[ nPQtVei ][ VE_VALMER ] := 0
				aQtdVei[ nPQtVei ][ VE_QTDVOL ] := 0
				aQtdVei[ nPQtVei ][ VE_KMCOL  ] := 0
				aQtdVei[ nPQtVei ][ VE_KMTRA  ] := 0
				aQtdVei[ nPQtVei ][ VE_KMENT  ] := 0
				aQtdVei[ nPQtVei ][ VE_CATVEI ] := cCatVei
				aQtdVei[ nPQtVei ][ VE_TMPCOL ] := 0
				aQtdVei[ nPQtVei ][ VE_TMPTRA ] := 0
				aQtdVei[ nPQtVei ][ VE_TMPENT ] := 0
				aQtdVei[ nPQtVei ][ VE_SRTVEI ] := ''
				aQtdVei[ nPQtVei ][ VE_FILBAS ] := cFilBasDA3

			EndIf
			aQtdVei[nPQtVei][VE_KM] += nQKmVge
			If cSerTms == '1' //-- Coleta
				aQtdVei[nPQtVei][VE_KMCOL ] += nQKmVge
				aQtdVei[nPQtVei][VE_TMPCOL] += Val( cTmpVge )
			ElseIf cSerTms == '2' //-- Transporte
				aQtdVei[nPQtVei][VE_KMTRA ] += nQKmVge
				aQtdVei[nPQtVei][VE_TMPTRA] += Val( cTmpVge )
			ElseIf cSerTms == '3' //-- Entrega
				aQtdVei[nPQtVei][VE_KMENT ] += nQKmVge
				aQtdVei[nPQtVei][VE_TMPENT] += Val( cTmpVge )
			EndIf
		EndIf 
		If lNewVge
			If (cAliasQry)->DTQ_SERTMS $ '2;3' //-- Transporte ou Entrega
				cQuery := "SELECT SUM(DT6_PESO) DT6_PESO, SUM(DT6_PESOM3) DT6_PESOM3, SUM(DT6_VALMER) DT6_VALMER "
				If (cAliasQry)->DTQ_SERTMS == '2'
					cQuery += ", SUM(DT6_QTDVOL) DT6_QTDVOL"
				Else
					cQuery += ", SUM(DT6_VOLORI) DT6_QTDVOL"
				EndIf					
				cQuery += "  FROM "
				cQuery += RetSqlName('DT6')+" DT6, "
				cQuery += RetSqlName('DUD')+" DUD  "
				cQuery += " WHERE DUD.DUD_FILIAL = '"+xFilial('DUD')+"'"
				cQuery += "   AND DUD.DUD_FILORI = '"+cFilOri+"'"
				cQuery += "   AND DUD.DUD_VIAGEM = '"+cViagem+"'"
				cQuery += "   AND DUD.D_E_L_E_T_ = ' '"
				cQuery += "   AND DT6.DT6_FILIAL = '"+xFilial('DT6')+"'"
				cQuery += "   AND DT6.DT6_FILDOC = DUD_FILDOC"
				cQuery += "   AND DT6.DT6_DOC    = DUD_DOC"
				cQuery += "   AND DT6.DT6_SERIE  = DUD_SERIE"
				cQuery += "   AND DT6.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasVge)
			Else
				cQuery := "SELECT SUM(DUA_PESOCO) DT6_PESO  , SUM(DT6_PESOM3) DT6_PESOM3, SUM(DT6_VALMER) DT6_VALMER, SUM(DUA_QTDOCO) DT6_QTDVOL"
				cQuery += "  FROM "
				cQuery += RetSqlName('DT6')+" DT6, "
				cQuery += RetSqlName('DUA')+" DUA, "
				cQuery += RetSqlName('DT2')+" DT2  "
				cQuery += " WHERE DUA.DUA_FILIAL = '"+xFilial('DUA')+"'"
				cQuery += "   AND DUA.DUA_FILORI = '"+cFilOri+"'"
				cQuery += "   AND DUA.DUA_VIAGEM = '"+cViagem+"'"
				cQuery += "   AND DUA.D_E_L_E_T_ = ' '"
				cQuery += "   AND DT2.DT2_FILIAL = '"+xFilial('DTA')+"'"
				cQuery += "   AND DT2.DT2_CODOCO = DUA_CODOCO"
				cQuery += "   AND DT2.DT2_TIPOCO NOT IN ( '05' )"
				cQuery += "   AND DT2.D_E_L_E_T_ = ' '"
				cQuery += "   AND DT6.DT6_FILIAL = '"+xFilial('DT6')+"'"
				cQuery += "   AND DT6.DT6_FILDOC = DUA_FILDOC"
				cQuery += "   AND DT6.DT6_DOC    = DUA_DOC"
				cQuery += "   AND DT6.DT6_SERIE  = DUA_SERIE"
				cQuery += "   AND DT6.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasVge)
			EndIf				
			TCSetField(cAliasVge,"DT6_PESO"  ,"N",TamSx3("DT6_PESO"  )[1],TamSx3("DT6_PESO"  )[2])
			TCSetField(cAliasVge,"DT6_PESOM3","N",TamSx3("DT6_PESOM3")[1],TamSx3("DT6_PESOM3")[2])
			TCSetField(cAliasVge,"DT6_VALMER","N",TamSx3("DT6_VALMER")[1],TamSx3("DT6_VALMER")[2])
			TCSetField(cAliasVge,"DT6_QTDVOL","N",TamSx3("DT6_QTDVOL")[1],TamSx3("DT6_QTDVOL")[2])
			If (cAliasVge)->(!Eof())      
				aQtdVge[nPQtVge,VG_PESO  ] += (cAliasVge)->DT6_PESO
				aQtdVge[nPQtVge,VG_PESOM3] += Iif( (cAliasVge)->DT6_PESOM3 == 0, (cAliasVge)->DT6_PESO, (cAliasVge)->DT6_PESOM3 ) //-- Caso de PesoM3 Zerado assume o Peso
				aQtdVge[nPQtVge,VG_VALMER] += (cAliasVge)->DT6_VALMER
				aQtdVge[nPQtVge,VG_QTDVOL] += (cAliasVge)->DT6_QTDVOL

			nTotPsVge += (cAliasVge)->DT6_PESO
			nTotP3Vge += Max((cAliasVge)->DT6_PESO,(cAliasVge)->DT6_PESOM3)
			nTotVlVge += (cAliasVge)->DT6_QTDVOL
			nTotHrVge += 0  //-- Total de Horas das Viagens - Acrescentar

				If cFroVei == '1' //-- Frota Propria
					aQtdVei[nPQtVei,VE_PESO  ] += (cAliasVge)->DT6_PESO
					aQtdVei[nPQtVei,VE_PESOM3] += Iif( (cAliasVge)->DT6_PESOM3 == 0, (cAliasVge)->DT6_PESO, (cAliasVge)->DT6_PESOM3 ) //-- Caso de PesoM3 Zerado assume o Peso
					aQtdVei[nPQtVei,VE_VALMER] += (cAliasVge)->DT6_VALMER
					aQtdVei[nPQtVei,VE_QTDVOL] += (cAliasVge)->DT6_QTDVOL
				EndIf
				(cAliasVge)->(dbCloseArea())
			EndIf					
		EndIf
	EndIf
EndDo
(cAliasQry)->(dbCloseArea())
dBSelectArea(cAliasDFJ) 
Aadd(aLogTmp,{ '1o.' + STR0023 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo finalizado em + Hora
oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])

aCont := TMSAF99Con(StrZero(2,Len(DFJ->DFJ_INIPRO)))

oSelf:IncRegua2( OemToAnsi( "2-" + STR0024 ) )

If aCont[1]	            

	IncProc("2-" + STR0024) //-- Depreciações de Veículos Processadas
	Aadd(aLogTmp,{ '2o.' + STR0022 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo iniciado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])

	If aCont[2] //Exclusao devido a continuacao
		TMSAF99SDG('',,,cIdCTMS,dDatFim,StrZero(2,Len(DFJ->DFJ_INIPRO)))
	EndIf
		
	//-- Depreciação de veículos
	cQuery := "SELECT DFG_CODVEI, DA3_FILBAS, DFH.*, DFH.R_E_C_N_O_ DFHRECNO FROM " 
	cQuery += RetSqlName( 'DFG' ) + " DFG, "
	cQuery += RetSqlName( 'DFH' ) + " DFH, " 
	cQuery += RetSqlName( 'DA3' ) + " DA3  " 
	cQuery += " WHERE DFG.DFG_FILIAL = '" + xFilial('DFG') + "'"
	cQuery += "   AND DFG.DFG_STATUS = '1'"
	cQuery += "   AND DFG.D_E_L_E_T_ = ' '"
	cQuery += "   AND DFH.DFH_FILIAL = '" + xFilial('DFH') + "'"
	cQuery += "   AND DFH.DFH_CODVEI = DFG_CODVEI"
	cQuery += "   AND DFH.DFH_STATUS = '1'"
	cQuery += "   AND DFH.D_E_L_E_T_ = ' '"
	cQuery += "   AND DA3.DA3_FILIAL = '" + xFilial('DA3') + "'"  
	cQuery += "   AND DA3.DA3_COD = DFG_CODVEI"  
	cQuery += "   AND DA3.D_E_L_E_T_ = ' '"  
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasDFH )

	For nX := 1 To Len(aStruDFH)
		If aStruDFH[nX][2]<>"C"
			TcSetField(cAliasDFH,aStruDFH[nX][1],aStruDFH[nX][2],aStruDFH[nX][3],aStruDFH[nX][4])
		EndIf
	Next nX

	aStruDFH := {} //-- Limpa variavel
	While (cAliasDFH)->(!Eof())
		nVdMes1 := 0
		nVdMes2 := 0
		nVdMes3 := 0
		nVdMes4 := 0
		nVdMes5 := 0
		If (cAliasDFH)->DFH_TXDEP1 > 0
			nVdMes1 := (((cAliasDFH)->DFH_TXDEP1 / 12) * (cAliasDFH)->DFH_VORIG1) / 100
		EndIf			
		If (cAliasDFH)->DFH_TXDEP2 > 0
			nVdMes2 := (((cAliasDFH)->DFH_TXDEP2 / 12) * (cAliasDFH)->DFH_VORIG2) / 100
		EndIf			
		If (cAliasDFH)->DFH_TXDEP3 > 0
			nVdMes3 := (((cAliasDFH)->DFH_TXDEP3 / 12) * (cAliasDFH)->DFH_VORIG3) / 100
		EndIf			
		If (cAliasDFH)->DFH_TXDEP4 > 0
			nVdMes4 := (((cAliasDFH)->DFH_TXDEP4 / 12) * (cAliasDFH)->DFH_VORIG4) / 100
		EndIf			
		If (cAliasDFH)->DFH_TXDEP5 > 0
			nVdMes5 := (((cAliasDFH)->DFH_TXDEP5 / 12) * (cAliasDFH)->DFH_VORIG5) / 100
		EndIf
		Begin Transaction
			//-- Atualiza depreciacao
			DFH->(dbGoTo((cAliasDFH)->DFHRECNO))
			RecLock('DFH',.F.)
			DFH->DFH_VDMES1 := nVdMes1
			DFH->DFH_VDACU1 := DFH->DFH_VDACU1 + nVdMes1
			DFH->DFH_VDMES2 := nVdMes2
			DFH->DFH_VDACU2 := DFH->DFH_VDACU2 + nVdMes2
			DFH->DFH_VDMES3 := nVdMes3
			DFH->DFH_VDACU3 := DFH->DFH_VDACU3 + nVdMes3
			DFH->DFH_VDMES4 := nVdMes4
			DFH->DFH_VDACU4 := DFH->DFH_VDACU4 + nVdMes4
			DFH->DFH_VDMES5 := nVdMes5
			DFH->DFH_VDACU5 := DFH->DFH_VDACU5 + nVdMes5
			If DFH->DFH_VDACU1 >= DFH->DFH_VORIG1
				DFH->DFH_FIMDEP := dDatFim 
				DFH->DFH_STATUS := '2' //-- Encerrada
			EndIf
			MsUnLock()     
			
			If aCont[2] //Exclusao SDG devido a continuacao
				TMSAF99SDG('DFH',cMvDesDep,(cAliasDFH)->DFG_CODVEI,cIdCTMS,dDatFim)
			EndIf
			//-- Atualiza SDG
			If nVdMes1 > 0
				If lTMA99GSDG
					nCustoProc := ExecBlock('TMA99GSDG',.F.,.F.,{2, cIdCTMS, nVdMes1, cMvDesDep, (cAliasDFH)->DFG_CODVEI})
					If ValType(nCustoProc) != 'N'
						nCustoProc := 0
					EndIf
					TMA250GrvSDG('DFH', , , cMvDesDep, nCustoProc, , (cAliasDFH)->DFG_CODVEI, , , , cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2")
				Else
					TMA250GrvSDG('DFH', , , cMvDesDep, nVdMes1, , (cAliasDFH)->DFG_CODVEI, , , , cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2")
				EndIf
			EndIf
			
			If Ascan( aQtdVei, { |x| x[ VE_CODVEI ] == ( cAliasDFH )->DFG_CODVEI } ) == 0
				nPos := Ascan( aDepVeiSVg, { |x| x[ VS_CODVEI ] + x[ VS_TABVEI ] == ( cAliasDFH )->DFG_CODVEI + 'DFH' } )
				If nPos == 0
					Aadd( aDepVeiSVg, Array( VS_QTDCOL ) )
					aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_CODVEI ] := ( cAliasDFH )->DFG_CODVEI
					aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_CUSVEI ] := nVdMes1
					aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_SERVEI ] := ''
					aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_TABVEI ] := 'DFH'
					aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_FILBAS ] := ( cAliasDFH )->DA3_FILBAS 
					aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_CODDES ] := cMvDepSVg
				Else
					aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_CUSVEI ] += nVdMes1
				EndIf
			EndIf

		End Transaction
		(cAliasDFH)->(dbSkip())
	EndDo			
	(cAliasDFH)->(dbCloseArea())
	DbSelectArea(cAliasDFJ)
	Aadd(aLogTmp,{ '2o.' + STR0023 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo finalizado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	TMSAF99Con(StrZero(2,Len(DFJ->DFJ_INIPRO)),.T.)
EndIf

aCont := TMSAF99Con(StrZero(3,Len(DFJ->DFJ_INIPRO)))

oSelf:IncRegua2( OemToAnsi( "3-" + STR0025 ) )

If aCont[1]

	IncProc("3-" + STR0025) //-- Serviços de Manutenção Processados
	Aadd(aLogTmp,{ '3o.' + STR0022 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' })  //-- Processo iniciado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	//-- Verifica serviços de manutenção
	If AliasInDic('STJ')
		If aCont[2] //Exclusao devido a continuacao
			TMSAF99SDG('',,,cIdCTMS,dDatFim,StrZero(3,Len(DFJ->DFJ_INIPRO)))
		EndIf
		nMDO   := 0		
		cQuery := "SELECT TJ_FILIAL, TJ_ORDEM, TJ_PLANO, TJ_SERVICO, TJ_CODBEM, DA3_COD, DA3_FILBAS, DA3_FILATU, DUT_CATVEI "
		cQuery += "  FROM "
		cQuery += RetSqlName('STJ') + " STJ, "
		cQuery += RetSqlName('DA3') + " DA3, "
		cQuery += RetSqlName('DUT') + " DUT  "
		//--Se for exclusivo nao pode validar filial
		If Empty(cFilSTJ)
			cQuery += " WHERE STJ.TJ_FILIAL  = '"+xFilial('STJ')+"'"
			cQuery += "   AND STJ.TJ_DTMRFIM BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFim)+"'"
		Else
			cQuery += " WHERE STJ.TJ_DTMRFIM BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFim)+"'"
		EndIf
		cQuery += "      AND STJ.TJ_TERMINO = 'S'"
		cQuery += "      AND STJ.D_E_L_E_T_ = ' '"
		cQuery += "      AND DA3.DA3_FILIAL = '"+xFilial('DA3')+"'"
		cQuery += "      AND DA3.DA3_CODBEM = STJ.TJ_CODBEM"
		cQuery += "      AND DA3.D_E_L_E_T_ = ' '"
		cQuery += "      AND DUT.DUT_FILIAL = '"+xFilial('DUT')+"'" 
		cQuery += "      AND DUT.DUT_TIPVEI = DA3.DA3_TIPVEI"
		cQuery += "      AND DUT.D_E_L_E_T_ = ' '"
		cQuery += "    ORDER BY TJ_CODBEM, TJ_ORDEM, TJ_PLANO "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSTJ)
		While (cAliasSTJ)->(!Eof())
			cOS     := (cAliasSTJ)->TJ_ORDEM
			cPlano  := (cAliasSTJ)->TJ_PLANO
			nTER    := 0
			nTRO    := 0
			nSUB    := 0
			nAPO    := 0
			STL->(dbSetOrder(1))
			//--Se o STL for Exclusivo, pegar a filila do STJ, que ja pesquisamos todas as filiais na query anterior
			If !Empty(cFilSTL)
				cSeekSTL := (cAliasSTJ)->TJ_FILIAL+cOS+cPlano
			Else
				cSeekSTL := xFILIAL('STL')+cOS+cPlano
			EndIf		
			STL->(dbSeek(cSeekSTL))
			While STL->(!Eof()) .And. STL->(TL_FILIAL+TL_ORDEM+TL_PLANO) == cSeekSTL
			If (NgVerify("STL") .And. AllTrim(STL->TL_SEQRELA) == "0") .Or. (!NgVerify("STL") .And. STL->TL_SEQUENC == 0)
				STL->(dbSkip())
				Loop
			EndIf                      
			lGrpFoun := .F.
			If Empty(STL->TL_CODIGO)
				cPrd := Space(Len(SB1->B1_COD))
			Else
				cPrd := STL->TL_CODIGO
			EndIf
			
			If STL->TL_TIPOREG == "T"     //-- Terceiro da OS
				nTER += STL->TL_CUSTO
			ElseIf STL->TL_TIPOREG == "P" //-- Produto da OS
				If STL->TL_DESTINO == "T"  //-- Troca
					nTRO += STL->TL_CUSTO
				ElseIf STL->TL_DESTINO == "S" //-- SUBSTITUICAO
					nSUB += STL->TL_CUSTO
				Else                         //-- APOIO 
					nAPO += STL->TL_CUSTO
					//-- Se encontrou despesa para o servico x produto, apura o custo para o produto
					cGrpProd := Posicione("SB1", 1, xFilial("SB1") + STL->TL_CODIGO, "B1_GRUPO")
					
					DFD->( dbSetOrder( 3 ) )
					If DFD->(dbSeek(xFilial('DFD')+(cAliasSTJ)->TJ_SERVICO+cGrpProd))
						lGrpFoun := .T.
						cPrd := STL->TL_CODIGO
						Else	 //-- Se encontrou despesa para o servico x produto, apura o custo para o produto
						DFD->( dbSetOrder( 2 ) )
						If DFD->(dbSeek(xFilial('DFD')+(cAliasSTJ)->TJ_SERVICO+STL->TL_CODIGO))
							cPrd  := STL->TL_CODIGO 
							Else //-- Se nao encontrou despesa para o servico x produto ou servico x grupo nao considera
								cQuery := "SELECT * "
								cQuery += "  FROM "
								cQuery += RetSQLName('DFD')+" DFD "    
								cQuery += "   WHERE "
								cQuery += "   DFD.DFD_SERMNT     = '"+(cAliasSTJ)->TJ_SERVICO+"'"
								cQuery += "   AND DFD.DFD_CODPRO = '"+Space(Len(DFD->DFD_CODPRO))+"'"							
								cQuery += "   AND DFD.DFD_GRUPO  = '"+Space(Len(DFD->DFD_GRUPO))+"'"
								cQuery += "   AND DFD.D_E_L_E_T_ = ' '"
								cQuery := ChangeQuery(cQuery)
								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
								If (cAliasQry)->(Eof())
									(cAliasQry)->(dbCloseArea())
									STL->(dbSkip())
								Loop
							EndIf
							(cAliasQry)->(dbCloseArea())	            							
						EndIf
						EndIf	            	
				EndIf
			ElseIf STL->TL_TIPOREG == "M" //-- Mao de Obra a OS
				nMDO += STL->TL_CUSTO
			EndIf
			If (nPCust := Ascan(aMntBem,{ | e | e[MN_CODSERV]+e[MN_CODPROD]+e[MN_CODBEM] == (cAliasSTJ)->TJ_SERVICO+cPrd+(cAliasSTJ)->TJ_CODBEM })) > 0
					aMntBem[nPCust,MN_CUSTO] += STL->TL_CUSTO
				Else

					Aadd( aMntBem, Array( MN_QTDCOL ) )

					aMntBem[ Len(aMntBem) ][ MN_CODSERV ] := (cAliasSTJ)->TJ_SERVICO
					aMntBem[ Len(aMntBem) ][ MN_CODPROD ] := cPrd
					aMntBem[ Len(aMntBem) ][ MN_CODBEM  ] := (cAliasSTJ)->TJ_CODBEM
					aMntBem[ Len(aMntBem) ][ MN_CUSTO   ] := STL->TL_CUSTO
					aMntBem[ Len(aMntBem) ][ MN_GRPEST  ] := Iif(lGrpFoun,cGrpProd,'')
					aMntBem[ Len(aMntBem) ][ MN_CODVEI  ] := (cAliasSTJ)->DA3_COD
					aMntBem[ Len(aMntBem) ][ MN_FILBAS  ] := (cAliasSTJ)->DA3_FILBAS 

				EndIf					

			STL->(dbSkip())

			EndDo
			(cAliasSTJ)->(dbSkip())
		EndDo	
		(cAliasSTJ)->(dbCloseArea())
		For nI := 1 To Len(aMntBem)
	
			cCodVei := aMntBem[nI,MN_CODVEI]
			
			If Empty(cCodVei)
				Aadd(aMsgErr,{ STR0046 + " STJ: " + AllTrim(aMntBem[nI,MN_CODBEM]), '00', '' }) //-- Não foi encontrado veículo relacionado ao Bem a partir da tabela
				Loop
			EndIf
			
			lCont := .T.   
	
			If !Empty( aMntBem[nI,MN_GRPEST] )
			DFD->( dbSetOrder( 3 ) )
			bSeek   := { || DFD->(dbSeek(AllTrim( xFilial('DFD')+aMntBem[nI,MN_CODSERV]+aMntBem[nI,MN_GRPEST] ))) }
				bWhile1 := { || !Eof() .And. lCont .And. DFD->(DFD_FILIAL+DFD_SERMNT+DFD_GRUPO) == xFilial("DFD") + aMntBem[nI,MN_CODSERV]+aMntBem[nI,MN_GRPEST]   }
				bWhile2 := { || !Eof() .And. DFD->(DFD_FILIAL+DFD_SERMNT+DFD_GRUPO+DFD_CODDES) == xFilial("DFD") + aMntBem[nI,MN_CODSERV]+aMntBem[nI,MN_GRPEST] + cCodDes  }
			Else
			DFD->( dbSetOrder( 2 ) )
			bSeek   := { || DFD->(dbSeek(AllTrim(xFilial('DFD')+aMntBem[nI,MN_CODSERV]+aMntBem[nI,MN_CODPROD]))) }
				bWhile1 := { || !Eof() .And. lCont .And. DFD->(DFD_FILIAL+DFD_SERMNT+DFD_CODPRO) == xFilial("DFD") + aMntBem[nI,MN_CODSERV]+aMntBem[nI,MN_CODPROD]   }
				bWhile2 := { || !Eof() .And. DFD->(DFD_FILIAL+DFD_SERMNT+DFD_CODPRO+DFD_CODDES) == xFilial("DFD") + aMntBem[nI,MN_CODSERV]+aMntBem[nI,MN_CODPROD] + cCodDes  }
			EndIf
			
			DFD->( Eval( bSeek ) )
			
			While DFD->( Eval( bWhile1 ) )		
				cCodDes := DFD->DFD_CODDES
				While DFD->( Eval( bWhile2 ) )
					If aMntBem[nI,MN_CUSTO] <= DFD->DFD_VLSATE
						If DFD->DFD_TIPAMZ == '0' //-- Não utiliza 
						If aCont[2] //Exclusao SDG devido a continuacao
								TMSAF99SDG('DFD',cCodDes,cCodVei,cIdCTMS,dDatFim)						   
						EndIf
							//-- Atualiza SDG
							If aMntBem[nI,MN_CUSTO] > 0
								If lTMA99GSDG
									nCustoProc := ExecBlock('TMA99GSDG',.F.,.F.,{3, cIdCTMS, aMntBem[nI,MN_CUSTO], cCodDes, cCodVei})
									If ValType(nCustoProc) != 'N'
										nCustoProc := 0
									EndIf
									DbSelectArea("SDG") //--A NextNumero esta sem o alias SDG aberto neste momento, precisa selecionar neste ponto
									TMA250GrvSDG('DFD', , , cCodDes, nCustoProc, , cCodVei, , , , cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2")
								Else
									DbSelectArea("SDG") //--A NextNumero esta sem o alias SDG aberto neste momento, precisa selecionar neste ponto
									TMA250GrvSDG('DFD', , , cCodDes, aMntBem[nI,MN_CUSTO], , cCodVei, , , , cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2")
								EndIf
							EndIf
							If Ascan( aQtdVei, { |x| x[ VE_CODVEI ] == cCodVei } ) == 0 
								nPos := Ascan( aDepVeiSVg, { |x| x[ VS_CODVEI ] + x[ VS_TABVEI ] == cCodVei + 'DFD' } )
								If nPos == 0
							Aadd( aDepVeiSVg, Array( VS_QTDCOL ) )
							aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_CODVEI  ] := cCodVei
							aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_CUSVEI  ] := aMntBem[nI,MN_CUSTO]
							aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_SERVEI  ] := ''
								aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_TABVEI  ] := 'DFD'
								aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_FILBAS  ] := aMntBem[nI,MN_FILBAS] 
								aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_CODDES ] := cMvMntSVg
						Else
									aDepVeiSVg[ nPos ][ VS_CUSVEI ] += aMntBem[nI,MN_CUSTO]
								EndIf
							EndIf
						Else
							cNumAmz := CriaVar('DFE_NUMAMZ',.T.)
							If __lSX8
								ConfirmSX8()
							EndIf					
							RecLock('DFE',.T.)
							DFE->DFE_FILIAL := xFilial('DFE')
							DFE->DFE_NUMAMZ := cNumAmz
							DFE->DFE_DATAMZ := dDatFim
							DFE->DFE_CODDES := cCodDes
							DFE->DFE_SERMNT := aMntBem[nI,MN_CODSERV]
							DFE->DFE_CODVEI := cCodVei
							DFE->DFE_CODPRO := aMntBem[nI,MN_CODPROD]
							DFE->DFE_TIPAMZ := DFD->DFD_TIPAMZ
							DFE->DFE_PERAMZ := DFD->DFD_PERAMZ
							DFE->DFE_VLRDES := aMntBem[nI,MN_CUSTO]
							DFE->DFE_VLRQTA := (aMntBem[nI,MN_CUSTO] / DFD->DFD_PERAMZ)
							DFE->DFE_CATAMZ := '2' //-- Automatica
							DFE->DFE_STATUS := '1' //-- Em Aberto
							DFE->DFE_IDCTMS := cIdCTMS
							MsUnLock()
							dbCommit()
						EndIf
						lCont := .F.
						Exit
					EndIf
					DFD->(dbSkip())
				EndDo
			EndDo
		Next nI
	EndIf
	aMntBem := {} //-- Limpa Variavel
	Aadd(aLogTmp,{ '3o.' + STR0023 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo finalizado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])       
	If Val(DFJ->DFJ_INIPRO) <= 2 //-- Processo Mao de obra PREMISSSA para o processo 22
		TMSAF99Con(StrZero(3,Len(DFJ->DFJ_INIPRO)),.T.)
	EndIf
EndIf

aCont := TMSAF99Con(StrZero(4,Len(DFJ->DFJ_INIPRO)))

oSelf:IncRegua2( OemToAnsi( "4-" + STR0026 ) )

If aCont[1]	

	//-- Verifica amortizações de despesas de manutencoes pendentes
	IncProc("4-" + STR0026 ) //-- Amortizações Processadas
	Aadd(aLogTmp,{ '4o.' + STR0022 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo iniciado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	
	If aCont[2] //Exclusao devido a continuacao
		TMSAF99SDG('',,,cIdCTMS,dDatFim,StrZero(4,Len(DFJ->DFJ_INIPRO)))
	EndIf
	
	DFE->(dbSetOrder(1))
	cQuery := "SELECT DFE_FILIAL, DFE_NUMAMZ, DFE_CODDES, DFE_CODVEI, DFE_TIPAMZ, DFE_PERAMZ, DFE_VLRDES, DFE_VLRQTA, DFE_VLRAMZ, DFE.R_E_C_N_O_ DFERECNO"
	cQuery += " , DA3_FILBAS " 
	cQuery += "   FROM "+RetSqlName('DFE')
	cQuery += "   DFE , " + RetSqlName( 'DA3' ) + " DA3  " 
	cQuery += " WHERE DFE.DFE_FILIAL = '"+xFilial('DFE')+"'"
	cQuery += "   AND DFE.DFE_STATUS = '1'"
	cQuery += "   AND DFE.D_E_L_E_T_ = ' '"
	cQuery += "   AND DA3.DA3_FILIAL = '" + xFilial('DA3') + "'"  
	cQuery += "   AND DA3.DA3_COD = DFE_CODVEI"
	cQuery += "   AND DA3.D_E_L_E_T_ = ' '" 
	cQuery += " ORDER BY "+SqlOrder(DFE->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDFE)
	TCSetField(cAliasDFE,"DFE_PERAMZ","N",TamSx3("DFE_PERAMZ")[1],TamSx3("DFE_PERAMZ")[2])
	TCSetField(cAliasDFE,"DFE_VLRDES","N",TamSx3("DFE_VLRDES")[1],TamSx3("DFE_VLRDES")[2])
	TCSetField(cAliasDFE,"DFE_VLRQTA","N",TamSx3("DFE_VLRQTA")[1],TamSx3("DFE_VLRQTA")[2])
	TCSetField(cAliasDFE,"DFE_VLRAMZ","N",TamSx3("DFE_VLRAMZ")[1],TamSx3("DFE_VLRAMZ")[2])
	While (cAliasDFE)->(!Eof())
		nVlrAmz := 0
		If (cAliasDFE)->DFE_TIPAMZ == '0'
			nQtdQta := 1
			nVlrAmz := (cAliasDFE)->DFE_VLRDES
		ElseIf (cAliasDFE)->DFE_TIPAMZ == '1' //-- Mes
			nQtdQta := 1
			nVlrAmz := (cAliasDFE)->DFE_VLRQTA
		ElseIf (cAliasDFE)->DFE_TIPAMZ == '2' //-- Contador
			If (nPQtVei:= Ascan(aQtdVei,{ | e | e[VE_CODVEI] == (cAliasDFE)->DFE_CODVEI })) > 0
				nQtdQta := aQtdVei[nPQtVei,VE_KM]
				nVlrAmz := (cAliasDFE)->DFE_VLRQTA * nQtdQta
			EndIf
		EndIf		
		If nVlrAmz > 0
			If ((cAliasDFE)->DFE_VLRAMZ + nVlrAmz) > (cAliasDFE)->DFE_VLRDES
				nVlrAmz := (cAliasDFE)->DFE_VLRDES - (cAliasDFE)->DFE_VLRAMZ
			EndIf
			Begin Transaction
				//-- Atualiza DFF
				RecLock('DFF',.T.)
				DFF->DFF_FILIAL := xFilial('DFF')
				DFF->DFF_NUMAMZ := (cAliasDFE)->DFE_NUMAMZ
				DFF->DFF_DATMOV := dDatFim
				DFF->DFF_QTDQTA := nQtdQta
				DFF->DFF_VLRAMZ := nVlrAmz
				DFF->DFF_IDCTMS := cIdCTMS
				MsUnLock()
				//-- Atualiza DFE 
				DFE->(dbGoTo((cAliasDFE)->DFERECNO))
				RecLock('DFE',.F.)
				DFE->DFE_VLRAMZ += nVlrAmz
				If DFE->DFE_VLRDES == DFE->DFE_VLRAMZ
					DFE->DFE_STATUS := '2' //-- Encerrado
				EndIf
				MsUnLock()  
				If aCont[2] //Exclusao SDG devido a continuacao
					TMSAF99SDG('DFF',(cAliasDFE)->DFE_CODDES,(cAliasDFE)->DFE_CODVEI,cIdCTMS,dDatFim)
				EndIf
				//-- Atualiza SDG
				If nVlrAmz > 0
					If lTMA99GSDG 
						nCustoProc := ExecBlock('TMA99GSDG',.F.,.F.,{4, cIdCTMS, nVlrAmz, (cAliasDFE)->DFE_CODDES, (cAliasDFE)->DFE_CODVEI})
						If ValType(nCustoProc) != 'N'
							nCustoProc := 0
						EndIf
						TMA250GrvSDG('DFF', , , (cAliasDFE)->DFE_CODDES, nCustoProc, , (cAliasDFE)->DFE_CODVEI,	, , , cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2")
					Else	
						TMA250GrvSDG('DFF', , , (cAliasDFE)->DFE_CODDES, nVlrAmz, , (cAliasDFE)->DFE_CODVEI,	, , , cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2")
					EndIf
				EndIf
				If Ascan( aQtdVei, { |x| x[ VE_CODVEI ] == ( cAliasDFE )->DFE_CODVEI } ) == 0
					nPos := Ascan( aDepVeiSVg, { |x| x[ VS_CODVEI ] + x[ VS_TABVEI ] == ( cAliasDFE )->DFE_CODVEI + 'DFF' } )
					If nPos == 0
						Aadd( aDepVeiSVg, Array( VS_QTDCOL ) )
						aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_CODVEI  ] := ( cAliasDFE )->DFE_CODVEI
						aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_CUSVEI  ] := nVlrAmz
						aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_SERVEI  ] := ''
						aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_TABVEI  ] := 'DFF'
						aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_FILBAS  ] := ( cAliasDFE )->DA3_FILBAS 
						aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_CODDES ] := cMvAmzSVg 
					Else
						aDepVeiSVg[ nPos ][ VS_CUSVEI ] += nVlrAmz
					EndIf
				EndIf

			End Transaction		
			
		EndIf					
		(cAliasDFE)->(dbSkip())
	EndDo
	(cAliasDFE)->(dbCloseArea())
	DbSelectArea(cAliasDFJ)
	Aadd(aLogTmp,{ '4o.' + STR0023 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo finalizado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	TMSAF99Con(StrZero(4,Len(DFJ->DFJ_INIPRO)),.T.)
EndIf

aCont := TMSAF99Con(StrZero(5,Len(DFJ->DFJ_INIPRO)))

oSelf:IncRegua2( OemToAnsi( "5-" + STR0027 ) )

If aCont[1]

	//-- Apura abastecimento dos veiculos
	IncProc("5-" + STR0027) //-- Abastecimentos Processados
	Aadd(aLogTmp,{ '5o.' + STR0022 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo iniciado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	
	If AliasInDic('TQN') 
		DT7->(dbSetOrder(1))	
		cQuery := "SELECT TQN_FILIAL, TQN_FROTA, SUM(TQN_VALTOT) TQN_VALTOT, TQF_CODFIL "
		cQuery += "  FROM "
		cQuery += RetSqlName('TQN') + " TQN, "
		cQuery += RetSqlName('TQF') + " TQF  "
		cQuery += " WHERE TQN.TQN_DTABAS BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFim)+"'"
		cQuery += "   AND TQN.D_E_L_E_T_ = ' '"
		cQuery += "	AND TQF.TQF_FILIAL = TQN.TQN_FILIAL"
		cQuery += "   AND TQF.TQF_CODIGO = TQN.TQN_POSTO"
		cQuery += "   AND TQF.TQF_LOJA = TQN.TQN_LOJA"
		cQuery += "   AND TQF.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY TQN_FILIAL, TQN_FROTA, TQN_POSTO, TQF_CODFIL"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTQN)
		TCSetField(cAliasTQN,"TQN_VALTOT","N",TamSx3("TQN_VALTOT")[1],TamSx3("TQN_VALTOT")[2])
		While (cAliasTQN)->(!Eof())
		cCodVei := Posicione( 'DA3', 5, xFilial( 'DA3' ) + ( cAliasTQN )->TQN_FROTA, 'DA3_COD' )
			If Empty(cCodVei)
				Aadd(aMsgErr,{ STR0046 + ' TQN: ' + ( cAliasTQN )->TQN_FROTA, '00', '' }) //-- Não foi encontrado veículo relacionado ao Bem a partir da tabela TQN:
				(cAliasTQN)->(dbSkip())
				Loop
			EndIf
			If aCont[2] //Exclusao SDG devido a continuacao
				TMSAF99SDG('TQN',cMvDesAba,cCodVei,cIdCTMS,dDatFim)						   
			EndIf    
			If (cAliasTQN)->TQN_VALTOT > 0
				If lTMA99GSDG 
					nCustoProc := ExecBlock('TMA99GSDG',.F.,.F.,{5, cIdCTMS, (cAliasTQN)->TQN_VALTOT, cMvDesAba, cCodVei})
					If ValType(nCustoProc) != 'N'
						nCustoProc := 0
					EndIf
					TMA250GrvSDG( 'TQN', , , cMvDesAba, nCustoProc             , , cCodVei, , ,	, cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2" )
				Else
					TMA250GrvSDG( 'TQN', , , cMvDesAba, (cAliasTQN)->TQN_VALTOT, , cCodVei, , ,	, cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2" )
				EndIf
			EndIf
			If Ascan( aQtdVei, { |x| x[ VE_CODVEI ] == cCodVei } ) == 0
				nPos := Ascan( aDepVeiSVg, { |x| x[ VS_CODVEI ] + x[ VS_TABVEI ] == cCodVei + 'TQN' } )
				If nPos == 0
					Aadd( aDepVeiSVg, Array( VS_QTDCOL ) )
					aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_CODVEI  ] := cCodVei
					aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_CUSVEI  ] := ( cAliasTQN )->TQN_VALTOT
					aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_SERVEI  ] := ''
					aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_TABVEI  ] := 'TQN'
					aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_FILBAS  ] := DA3->DA3_FILBAS
					aDepVeiSVg[ Len( aDepVeiSVg ) ][ VS_CODDES  ] := cMvAbtSVg
				Else
					aDepVeiSVg[ nPos ][ VS_CUSVEI ] += ( cAliasTQN )->TQN_VALTOT
				EndIf
			EndIf

			(cAliasTQN)->(dbSkip())
		EndDo
		(cAliasTQN)->(dbCloseArea())
	EndIf     
	dbSelectArea(cAliasDFJ)
	Aadd(aLogTmp,{ '5o.' + STR0023 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo finalizado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	TMSAF99Con(StrZero(5,Len(DFJ->DFJ_INIPRO)),.T.)
EndIf

aCont := TMSAF99Con(StrZero(6,Len(DFJ->DFJ_INIPRO)))

oSelf:IncRegua2( OemToAnsi( "6-" + STR0028 ) )

If aCont[1]		

	IncProc("6-" + STR0028 ) //-- Salários de Motorista
	Aadd(aLogTmp,{ '6o.' + STR0022 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo iniciado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])

	cQuery := "SELECT DTQ_FILORI, DTQ_VIAGEM, DTR_CODVEI, DUP_CODMOT, DA4_FILBAS, DA4_MAT, DTQ_SERTMS, DA3_FILBAS "
	cQuery += "  FROM "
	cQuery += RetSQLName('DTQ')+" DTQ, "
	cQuery += RetSQLName('DTR')+" DTR, "
	cQuery += RetSQLName('DUP')+" DUP, "
	cQuery += RetSQLName('DA3')+" DA3, "
	cQuery += RetSQLName('DA4')+" DA4  "
	cQuery += " WHERE DTQ.DTQ_FILIAL  = '"+xFilial('DTQ')+"'"
	cQuery += "   AND DTQ.DTQ_DATENC  BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFim)+"'"
	cQuery += "   AND DTQ.DTQ_STATUS IN ( '3', '9' )" //--Encerrado ou Cancelado
	cQuery += "   AND DTQ.D_E_L_E_T_  = ' '"
	cQuery += "   AND DTR.DTR_FILIAL  = '"+xFilial('DTR')+"'"
	cQuery += "   AND DTR.DTR_FILORI  = DTQ_FILORI"
	cQuery += "   AND DTR.DTR_VIAGEM  = DTQ_VIAGEM"
	cQuery += "   AND DTR.D_E_L_E_T_  = ' '"
	cQuery += "   AND DA3.DA3_FILIAL  = '"+xFilial('DA3')+"'"
	cQuery += "   AND DA3.DA3_COD     = DTR_CODVEI"
	cQuery += "   AND DA3.DA3_FROVEI  = '1'" //-- Frota Propria
	cQuery += "   AND DA3.D_E_L_E_T_  = ' '"
	cQuery += "   AND DUP.DUP_FILIAL  = '"+xFilial('DUP')+"'"
	cQuery += "   AND DUP.DUP_FILORI  = DTR_FILORI"
	cQuery += "   AND DUP.DUP_VIAGEM  = DTR_VIAGEM"
	cQuery += "   AND DUP.DUP_ITEDTR  = DTR_ITEM"
	cQuery += "   AND DUP.D_E_L_E_T_  = ' '"
	cQuery += "   AND DA4.DA4_FILIAL  = '"+xFilial('DA4')+"'"
	cQuery += "   AND DA4.DA4_COD     = DUP_CODMOT"
	cQuery += "   AND DA4.D_E_L_E_T_  = ' '"
	cQuery += "   ORDER BY DTR.DTR_CODVEI " 
	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	While (cAliasQry)->(!Eof()) 
		cFilOri := (cAliasQry)->DTQ_FILORI
		cViagem := (cAliasQry)->DTQ_VIAGEM

		nPos    := Ascan( aMotVge, { | e | e[MO_FILORI] + e[MO_VIAGEM] == cFilOri+cViagem })
		nPQtVge := Ascan( aQtdVge, { | e | e[VG_FILORI] + e[VG_VIAGEM] == cFilOri+cViagem })

		If nPos == 0 .And. nPQtVge > 0

			Aadd( aMotVge, Array( MO_QTDCOL ) )
	
			aMotVge[ Len( aMotVge ) ][ MO_FILORI ] := cFilOri
			aMotVge[ Len( aMotVge ) ][ MO_VIAGEM ] := cViagem
			aMotVge[ Len( aMotVge ) ][ MO_CODVEI ] := (cAliasQry)->DTR_CODVEI
			aMotVge[ Len( aMotVge ) ][ MO_CODMOT ] := (cAliasQry)->DUP_CODMOT
			aMotVge[ Len( aMotVge ) ][ MO_MATRIC ] := (cAliasQry)->DA4_MAT
			aMotVge[ Len( aMotVge ) ][ MO_FILBAS ] := (cAliasQry)->DA4_FILBAS
			aMotVge[ Len( aMotVge ) ][ MO_CUSTO  ] := 0
			aMotVge[ Len( aMotVge ) ][ MO_KM     ] := aQtdVge[nPQtVge][VG_KM  ]
			aMotVge[ Len( aMotVge ) ][ MO_PESO   ] := aQtdVge[nPQtVge][VG_PESO]
			aMotVge[ Len( aMotVge ) ][ MO_TEMPO  ] := aQtdVge[nPQtVge][VG_TMPVGE]
			aMotVge[ Len( aMotVge ) ][ MO_VALHOR ] := 0
			aMotVge[ Len( aMotVge ) ][ MO_SERMOT ] := (cAliasQry)->DTQ_SERTMS

		EndIf			
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())		

	//-- Calcula o custo do motorista
	TMSCustoFun( @aMotVge, dDatIni, dDatFim, @aMsgErr, 'CV' )
		
	For nA := 1 To Len( aMotVge )
	
		cCodVei   := aMotVge[ nA ][ MO_CODVEI ]

		If mv_par09 == 1      //-- Quilometragem

			If nA > 1
				If aMotVge[ nA ][ MO_CODMOT ] <> aMotVge[ ( nA - 1 ) ][ MO_CODMOT ]
					nTotKmVge := 0
					aEval( aMotVge, { |x| nTotKmVge += Iif( x[ MO_CODMOT ] == aMotVge[ nA ][ MO_CODMOT ], x[ MO_KM ], 0 ) } )
				EndIf
			Else
				nTotKmVge := 0
				aEval( aMotVge, { |x| nTotKmVge += Iif( x[ MO_CODMOT ] == aMotVge[ nA ][ MO_CODMOT ], x[ MO_KM ], 0 ) } )
		EndIf

			nCusVei := ( aMotVge[ nA ][ MO_CUSTO ] / nTotKmVge ) * aMotVge[ nA ][ MO_KM ]

		ElseIf mv_par09 == 2  //-- Rateio por Peso			

			If nA > 1
				If aMotVge[ nA ][ MO_CODMOT ] <> aMotVge[ ( nA - 1 ) ][ MO_CODMOT ]
					nTotPsVge := 0
					aEval( aMotVge, { |x| nTotPsVge += Iif( x[ MO_CODMOT ] == aMotVge[ nA ][ MO_CODMOT ], x[ MO_PESO ], 0 ) } )
				EndIf
			Else
				nTotPsVge := 0
				aEval( aMotVge, { |x| nTotPsVge += Iif( x[ MO_CODMOT ] == aMotVge[ nA ][ MO_CODMOT ], x[ MO_PESO ], 0 ) } )
		EndIf

			nCusVei := ( aMotVge[ nA ][ MO_CUSTO ] / nTotPsVge ) * aMotVge[ nA ][ MO_PESO ]

		ElseIf mv_par09 == 3  //-- Carga horaria			

			If nA > 1
				If aMotVge[ nA ][ MO_CODMOT ] <> aMotVge[ ( nA - 1 ) ][ MO_CODMOT ]
					nTotHrVge := 0
					aEval( aMotVge, { |x| nTotHrVge += Iif( x[ MO_CODMOT ] == aMotVge[ nA ][ MO_CODMOT ], Val( x[ MO_TEMPO ] ), 0 ) } )
				EndIf
			Else
				nTotHrVge := 0
				aEval( aMotVge, { |x| nTotHrVge += Iif( x[ MO_CODMOT ] == aMotVge[ nA ][ MO_CODMOT ], Val( x[ MO_TEMPO ] ), 0 ) } )
		EndIf
			nCusVei := ( aMotVge[ nA ][ MO_CUSTO ] / nTotHrVge ) * Val( aMotVge[ nA ][ MO_TEMPO ] )
		EndIf			
		
		If aCont[2] //Exclusao SDG devido a continuacao
			TMSAF99SDG('DUP',cMvDesMot,cCodVei,cIdCTMS,dDatFim)						   
		EndIf
		If nCusVei > 0   
			If lTMA99GSDG
				nCustoProc := ExecBlock('TMA99GSDG',.F.,.F.,{6, cIdCTMS, cMvDesMot, nCusVei, cCodVei})
				If ValType(nCustoProc) != 'N'
					nCustoProc := 0
				EndIf
				TMA250GrvSDG('DUP',,, cMvDesMot, nCustoProc,, cCodVei,,,, cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2")
			Else
				TMA250GrvSDG('DUP',,, cMvDesMot, nCusVei,, cCodVei,,,, cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2")
			EndIf
		EndIf
	Next nA
	
	Aadd(aLogTmp,{ '6o.' + STR0023 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo finalizado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
If Val(DFJ->DFJ_INIPRO) <= 10 //-- Processo Salario PREMISSSA para o processo 20
		TMSAF99Con(StrZero(6,Len(DFJ->DFJ_INIPRO)),.T.)
	EndIf
EndIf

aCont := TMSAF99Con(StrZero(7,Len(DFJ->DFJ_INIPRO)))

oSelf:IncRegua2( OemToAnsi( "7-" + STR0029 ) )

If aCont[1]		

	IncProc("7-" + STR0029 ) //-- Salário de Motorista sem Viagem
	Aadd(aLogTmp,{ '7o.' + STR0022 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo iniciado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	
	//-- Motoristas que nao trabalharam no periodo
	cQuery := "SELECT DA4_FILIAL, DA4_COD, DA4_MAT, DA4_FILBAS "
	cQuery += "  FROM "
	cQuery += RetSQLName('DA4')+" DA4  "
	cQuery += " WHERE DA4.DA4_FILIAL  = '"+xFilial('DA4')+"'"
	cQuery += "   AND DA4.DA4_TIPMOT  = '1'"
	cQuery += "   AND DA4.D_E_L_E_T_  = ' '"
	cQuery += "   AND NOT EXISTS ( SELECT 1 FROM "
	cQuery +=                      RetSQLName('DTQ')+" DTQ, "
	cQuery +=                      RetSQLName('DTR')+" DTR, "
	cQuery +=                      RetSQLName('DUP')+" DUP, "
	cQuery +=                      RetSQLName('DA3')+" DA3  "
	cQuery += "                    WHERE DTQ.DTQ_FILIAL  = '"+xFilial('DTQ')+"'"
	cQuery += "                      AND DTQ.DTQ_DATENC  BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFim)+"'"
	cQuery += "                      AND DTQ.DTQ_STATUS IN ( '3', '9' )" //--Encerrado ou Cancelado
	cQuery += "                      AND DTQ.D_E_L_E_T_  = ' '"
	cQuery += "                      AND DTR.DTR_FILIAL  = '"+xFilial('DTR')+"'"
	cQuery += "                      AND DTR.DTR_FILORI  = DTQ_FILORI"
	cQuery += "                      AND DTR.DTR_VIAGEM  = DTQ_VIAGEM"
	cQuery += "                      AND DTR.D_E_L_E_T_  = ' '"
	cQuery += "                      AND DA3.DA3_FILIAL  = '"+xFilial('DA3')+"'"
	cQuery += "                      AND DA3.DA3_COD     = DTR_CODVEI"
	cQuery += "                      AND DA3.DA3_FROVEI  = '1'" //-- Frota Propria
	cQuery += "                      AND DA3.D_E_L_E_T_  = ' '"
	cQuery += "                      AND DUP.DUP_FILIAL  = '"+xFilial('DUP')+"'"
	cQuery += "                      AND DUP.DUP_FILORI  = DTR_FILORI"
	cQuery += "                      AND DUP.DUP_VIAGEM  = DTR_VIAGEM"
	cQuery += "                      AND DUP.DUP_ITEDTR  = DTR_ITEM"
	cQuery += "                      AND DUP.DUP_CODMOT  = DA4_COD"
	cQuery += "                      AND DUP.D_E_L_E_T_  = ' ' )"
	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

	While (cAliasQry)->(!Eof()) 

		cFilOri := (cAliasQry)->DA4_FILIAL
		cCodMot := (cAliasQry)->DA4_COD
		cFilBas := (cAliasQry)->DA4_FILBAS

		nPos := Ascan(aMotSVg, { | e | e[MS_FILORI] + e[MS_CODMOT] + e[MS_FILBAS] == cFilOri + cCodMot + cFilBas } )

		If nPos == 0

			Aadd( aMotSVg, Array( MS_QTDCOL ) )

			aMotSVg[ Len( aMotSVg ) ][ MS_FILORI  ] := cFilOri
			aMotSVg[ Len( aMotSVg ) ][ MS_CODMOT  ] := cCodMot
			aMotSVg[ Len( aMotSVg ) ][ MS_MATRIC ] := (cAliasQry)->DA4_MAT
			aMotSVg[ Len( aMotSVg ) ][ MS_FILBAS ] := cFilBas
			aMotSVg[ Len( aMotSVg ) ][ MS_CUSTO  ] := 0
			aMotSVg[ Len( aMotSVg ) ][ MS_VALHOR ] := 0
			aMotSVg[ Len( aMotSVg ) ][ MS_SERMOT ] := ""

		EndIf			

	(cAliasQry)->(dbSkip())

	EndDo
	(cAliasQry)->(dbCloseArea())
	
	//-- Calcula o custo do motorista
	TMSCustoFun( @aMotSVg, dDatIni, dDatFim, @aMsgErr, 'SV' )
		
	For nI := 1 To Len( aMotSVg ) //-- Motoristas SEM viagem...
	
		For nX := 1 To Len( aMotVge ) //-- Rateio de custo dos motoristas sem viagem, para os motoristas COM viagem...

			nPos := Ascan( aQtdVei, { |y| y[ VE_CODVEI ] == aMotVge[ nX ][ MO_CODVEI ] } )

			If nX > 1 .And. aMotVge[ nX ][ MO_CODVEI ] == aMotVge[ ( nX -1 ) ][ MO_CODVEI ]

				Loop

			EndIf

			cCodVei := aMotVge[ nX ][ MO_CODVEI ]    //-- Veículo do Motorista COM Viagem...
			nPerVei := TMSAF99Per( cCodVei, aQtdVge, aMotSVg[ nI ][ MS_FILBAS ], aMotSVg[ nI ][ MS_SERMOT ], 9, nPos )
			nCusVei := ( ( aMotSVg[ nI ][ MS_CUSTO  ] * nPerVei ) / 100 )

			MsUnLock()  
			If aCont[2] //Exclusao SDG devido a continuacao
			TMSAF99SDG('DUP',cMvMotSVg,cCodVei,cIdCTMS,dDatFim)
			EndIf   
			//-- Atualiza SDG
			If nCusVei > 0
				If lTMA99GSDG 
					nCustoProc := ExecBlock('TMA99GSDG',.F.,.F.,{7, cIdCTMS, nCusVei, cMvMotSVg, cCodVei})
					If ValType(nCustoProc) != 'N'
						nCustoProc := 0
					EndIf
					DbSelectArea("SDG")
					TMA250GrvSDG('DUP',,, cMvMotSVg, nCustoProc,, cCodVei,,,, cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2")
				Else
					DbSelectArea("SDG")
					TMA250GrvSDG('DUP',,, cMvMotSVg, nCusVei,, cCodVei,,,, cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2")
				EndIf		
			EndIf 

	Next nX

Next nI

	Aadd(aLogTmp,{ '7o.' + STR0023 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo finalizado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	TMSAF99Con(StrZero(7,Len(DFJ->DFJ_INIPRO)),.T.)
EndIf

aCont := TMSAF99Con(StrZero(8,Len(DFJ->DFJ_INIPRO)))

oSelf:IncRegua2( OemToAnsi( "8-" + STR0030 ) )

If aCont[1]

	IncProc("8-" + STR0030 ) //-- Rateio de Contas Contábeis por Veículo
	Aadd(aLogTmp,{ '8o.' + STR0022 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo iniciado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	
	//-- Calculo padrao por despesas de veiculos - Despesas de Pneus e Despesas de Viagens
	DbSelectArea(cAliasDFJ)
	cQuery := "SELECT DFZ.*, DFY.* "
	cQuery += " FROM " + RetSQLName('DFZ') + " DFZ "
	cQuery += " JOIN " + RetSqlName('DFY') + " DFY "
	cQuery += "   ON DFY.DFY_FILIAL = DFZ.DFZ_FILIAL "
	cQuery += "  AND DFY.DFY_CODDES = DFZ.DFZ_CODDES "
	cQuery += "  AND DFY.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE DFZ.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY DFZ_FILIAL,DFZ_CODDES"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	While (cAliasQry)->(!Eof())
		cCodDes   := (cAliasQry)->DFY_CODDES
		cSerTms   := (cAliasQry)->DFY_SRTCUS
		nCCSaldo  := 0
		nCCTSaldo := 0
		nValCta   := 0
		cSerTms   := ""
		cFilAnt   := (cAliasQry)->DFY_FILIAL
				
		While (cAliasQry)->(!Eof()) .And. (cAliasQry)->(DFZ_CODDES) == cCodDes .And. (cAliasQry)->DFZ_FILIAL == cFilAnt
			cCodDes   := (cAliasQry)->DFZ_CODDES
			cConta    := (cAliasQry)->DFZ_CONTA
			cItemCT   := (cAliasQry)->DFZ_ITEMCT
			cClasCL   := (cAliasQry)->DFZ_CLVL
			cCtDe     := (cAliasQry)->DFZ_CC
			cCtAte    := (cAliasQry)->DFZ_CC2
			//--O 5o parametro da CTSMMOV precisa ser 3, para trazer o Movimento da Conta Contabil, nao deve ser o Saldo
			nValCta   := CTSMMOV(dDatIni,dDatFim,"01","1",3,cConta,cConta,cCtDe,cCtAte,cItemCT,cItemCT,cClasCL,cClasCL)
			nCCSaldo  += (nValCta *-1)
		(cAliasQry)->(dbSkip())			
		EndDo		
		//Se o Saldo for positivo prossegue o processamento, senao precisa dar a mensagem de erro para ser apurado por custos
		If nCCSaldo > 0
			For nI := 1 To Len(aQtdVei)
				cCodVei := aQtdVei[nI,VE_CODVEI]
				cFilBas := aQtdVei[nI,VE_FILBAS]
				nPerVei := TMSAF99Per( cCodVei, aQtdVge, cFilBas,,11, nI )
				nRatVei := ( ( nCCSaldo * nPerVei ) / 100 )
				If aCont[2] //Exclusao SDG devido a continuacao
					TMSAF99SDG('DFZ',cCodDes,cCodVei,cIdCTMS,dDatFim)
				EndIf
				If nRatVei > 0
					If lTMA99GSDG 
						nCustoProc := ExecBlock('TMA99GSDG',.F.,.F.,{8, cIdCTMS, nRatVei, cCodDes, cCodVei})
						If ValType(nCustoProc) != 'N'
							nCustoProc := 0
						EndIf
						TMA250GrvSDG('DFZ', , , cCodDes, nCustoProc, ,cCodVei, , , , cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2")
					Else
						TMA250GrvSDG('DFZ', , , cCodDes, nRatVei, ,cCodVei, , , , cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2")
					EndIf
				EndIf
			Next nI
		Else
			If nCCSaldo < 0
				Aadd(aMsgErr,{ STR0047 + AllTrim( cConta ), '00', '' }) //--"Verifique o valor negativo da conta:"
			EndIf
		EndIf
	EndDo
	//-- Restaura a Fillial original apos o processamento. 
	cFilAnt := cFilBkp
	
	(cAliasQry)->(dbCloseArea())
	DbSelectArea(cAliasDFJ) 
	Aadd(aLogTmp,{ '8o.' + STR0023 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo finalizado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	TMSAF99Con(StrZero(8,Len(DFJ->DFJ_INIPRO)),.T.)
EndIf	

aCont := TMSAF99Con(StrZero(9,Len(DFJ->DFJ_INIPRO)))

oSelf:IncRegua2( OemToAnsi( "9-" + STR0031 ) )

If aCont[1]		

	IncProc("9-" + STR0031 ) //-- Custos de Veículos sem Viagem
	Aadd(aLogTmp,{ '9o.' + STR0022 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo iniciado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])

For nX := 1 To Len( aDepVeiSVg )

		For nI := 1 To Len( aQtdVei )

			cCodVei := aQtdVei[ nI ][ VE_CODVEI ]
			nPerVei := TMSAF99Per( cCodVei, aQtdVge, aDepVeiSVg[ nX ][ VS_FILBAS ], aDepVeiSVg[ nX ][ VS_SERVEI ], 11, nI )
			nCusVei := ( ( aDepVeiSVg[ nX ][ VS_CUSVEI ] * nPerVei ) / 100 )

			MsUnLock()  
			If aCont[2] //Exclusao SDG devido a continuacao
				TMSAF99SDG( aDepVeiSVg[ nX ][ VS_TABVEI ], aDepVeiSVg[ nX ][ VS_CODDES ],cCodVei,cIdCTMS,dDatFim)
			EndIf   
			//-- Atualiza SDG
			If nCusVei > 0
				If lTMA99GSDG 
					nCustoProc := ExecBlock('TMA99GSDG',.F.,.F.,{9, cIdCTMS, nCusVei, aDepVeiSVg[ nX ][ VS_CODDES ], cCodVei})
					If ValType(nCustoProc) != 'N'
						nCustoProc := 0
					EndIf
					DbSelectArea("SDG")
					TMA250GrvSDG( aDepVeiSVg[ nX ][ VS_TABVEI ],,, aDepVeiSVg[ nX ][ VS_CODDES ], nCustoProc,, cCodVei,,,, cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2")
				Else
					DbSelectArea("SDG")
					TMA250GrvSDG( aDepVeiSVg[ nX ][ VS_TABVEI ],,, aDepVeiSVg[ nX ][ VS_CODDES ], nCusVei,, cCodVei,,,, cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2")
				EndIf
			EndIf
		Next nI

Next nX

	Aadd(aLogTmp,{ '9o.' + STR0023 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo finalizado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	TMSAF99Con(StrZero(9,Len(DFJ->DFJ_INIPRO)),.T.)

EndIf

aCont := TMSAF99Con(StrZero(10,Len(DFJ->DFJ_INIPRO)))

oSelf:IncRegua2( OemToAnsi( "10-" + STR0032 ) )

If aCont[1]

	IncProc("10-" + STR0032 ) //-- Planilha de Veiculo gravada
	Aadd(aLogTmp,{ '10o.' + STR0022 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo iniciado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])

	If aCont[2] //Exclusao devido a continuacao
		TMSAF99SDG('',,,cIdCTMS,dDatFim,StrZero(10,Len(DFJ->DFJ_INIPRO)))
	EndIf

	lCont   := .F.
	//-- Apura despesas dos veiculos e grava a planilha de veiculos   
	cQuery := "SELECT DG_CODVEI, DG_CODDES, SUM(DG_CUSTO1) DG_CUSTO1, SUM(DG_CUSTO2) DG_CUSTO2, "
	cQuery += "                             SUM(DG_CUSTO3) DG_CUSTO3, SUM(DG_CUSTO4) DG_CUSTO4, SUM(DG_CUSTO5) DG_CUSTO5"
	cQuery += "  FROM "
	cQuery += RetSqlName('SDG')+" SDG, "
	cQuery += RetSqlName('DA3')+" DA3  "
	cQuery += " WHERE SDG.DG_EMISSAO BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFim)+"'"
	cQuery += "   AND SDG.DG_CODVEI   <> ' '"
	cQuery += "   AND SDG.DG_VIAGEM   = ' '"
	cQuery += "   AND SDG.DG_STATUS   = '3'" 
	If lTM99SPDG
		cQuery += "  AND SDG.DG_CODDES <> '"+cMvDesPdg+"'" //Nao Considerar despesa de Pedagio lancada via contrato
	EndIf
	cQuery += "   AND SDG.D_E_L_E_T_   = ' '"
	cQuery += "   AND DA3.DA3_FILIAL   = '"+xFilial('DA3')+"'"
	cQuery += "   AND DA3.DA3_COD      = DG_CODVEI"
	cQuery += "   AND DA3.DA3_FROVEI   = '1'"
	cQuery += "   AND DA3.D_E_l_E_T_   = ' '"
	cQuery += " GROUP BY DG_CODVEI, DG_CODDES"
	cQuery += " ORDER BY DG_CODVEI, DG_CODDES"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	TCSetField(cAliasQry,"DG_CUSTO1","N",TamSx3("DG_CUSTO1")[1],TamSx3("DG_CUSTO1")[2])
	TCSetField(cAliasQry,"DG_CUSTO2","N",TamSx3("DG_CUSTO2")[1],TamSx3("DG_CUSTO2")[2])
	TCSetField(cAliasQry,"DG_CUSTO3","N",TamSx3("DG_CUSTO3")[1],TamSx3("DG_CUSTO3")[2])
	TCSetField(cAliasQry,"DG_CUSTO4","N",TamSx3("DG_CUSTO4")[1],TamSx3("DG_CUSTO4")[2])
	TCSetField(cAliasQry,"DG_CUSTO5","N",TamSx3("DG_CUSTO5")[1],TamSx3("DG_CUSTO5")[2])
	While (cAliasQry)->(!Eof())
		cCodVei := (cAliasQry)->DG_CODVEI
		nCusto1 := 0
		nCusto2 := 0
		nCusto3 := 0
		nCusto4 := 0
		nCusto5 := 0

		If (nPQtVei := Ascan(aQtdVei,{ | e | e[VE_CODVEI] == cCodVei })) > 0
		//-- Valida o tamanho do campo KM
			nQKmVei := Round(aQtdVei[nPQtVei,VE_KM],aTamKm[2])	 	
			If ( nQKmVei < 0 ) .OR. ( nQKmVei > nTamKm )
				lCont := .T.
				oSelf:SaveLog( STR0050 + cCodVei + STR0051 + AllTrim(Str(nQKmVei))) //-- 'Veículo: + com KM incorreto: +
				(cAliasQry)->(dbSkip())
				Loop
			EndIf           
		//-- Valida o tamanho do campo Peso
			nPeso := Round(aQtdVei[nPQtVei,VE_PESO],aTamPeso[2])
			If ( nPeso < 0 ) .OR. ( nPeso > nTamPeso ) 
				lCont := .T.
				oSelf:SaveLog( STR0050 + cCodVei + STR0052 + AllTrim(Str(nPeso))) //-- 'Veículo: + com PESO incorreto: +
				(cAliasQry)->(dbSkip())
				Loop
			EndIf                              
		//-- Valida o tamanho do campo PesoM3
		nPesoM3 := Round(aQtdVei[nPQtVei,VE_PESOM3],aTamPesoM3[2])
			If ( nPesoM3 < 0 ) .OR. ( nPesoM3 > nTamPesoM3 ) 
				lCont := .T.
				oSelf:SaveLog( STR0050 + cCodVei + STR0053 + AllTrim(Str(nPesoM3))) //-- 'Veículo: + com PesoM3 incorreto: +
				(cAliasQry)->(dbSkip())
				Loop
			EndIf

			Begin Transaction
				RecLock('DFK',.T.)
				DFK->DFK_FILIAL := xFilial('DFK')
				DFK->DFK_IDCTMS := cIdCTMS
				DFK->DFK_CODVEI := cCodVei
				DFK->DFK_KM     := nQKmVei 
				DFK->DFK_PESO   := nPeso   
				DFK->DFK_PESOM3 := nPesoM3
				DFK->DFK_VALMER := aQtdVei[nPQtVei,VE_VALMER]
				DFK->DFK_QTDVOL := aQtdVei[nPQtVei,VE_QTDVOL] 
				DFK->DFK_STAMOV := '1'
				MsUnLock()
				cItem := StrZero(1,Len(DFL->DFL_ITEM))
				While (cAliasQry)->(!Eof()) .And. (cAliasQry)->DG_CODVEI == cCodVei
					nCusto1 += (cAliasQry)->DG_CUSTO1
					nCusto2 += (cAliasQry)->DG_CUSTO2
					nCusto3 += (cAliasQry)->DG_CUSTO3
					nCusto4 += (cAliasQry)->DG_CUSTO4
					nCusto5 += (cAliasQry)->DG_CUSTO5
					RecLock('DFL',.T.)
					DFL->DFL_FILIAL := xFilial('DFL')
					DFL->DFL_IDCTMS := cIdCTMS
					DFL->DFL_CODVEI := cCodVei
					DFL->DFL_ITEM   := cItem
					DFL->DFL_CODDES := (cAliasQry)->DG_CODDES
					DFL->DFL_CUSTO1 := (cAliasQry)->DG_CUSTO1
					DFL->DFL_CUSTO2 := (cAliasQry)->DG_CUSTO2
					DFL->DFL_CUSTO3 := (cAliasQry)->DG_CUSTO3
					DFL->DFL_CUSTO4 := (cAliasQry)->DG_CUSTO4
					DFL->DFL_CUSTO5 := (cAliasQry)->DG_CUSTO5
					MsUnLock()
					cItem := Soma1(cItem)
					(cAliasQry)->(dbSkip())
				EndDo
				RecLock('DFK',.F.)
				DFK->DFK_CUSTO1 := nCusto1
				DFK->DFK_CUSTO2 := nCusto2
				DFK->DFK_CUSTO3 := nCusto3
				DFK->DFK_CUSTO4 := nCusto4
				DFK->DFK_CUSTO5 := nCusto5
				MsUnLock()
			End Transaction
		Else                            
		//-- Horas Paradas
			Begin Transaction            		
				RecLock('DFK',.T.)
				DFK->DFK_FILIAL := xFilial('DFK')
				DFK->DFK_IDCTMS := cIdCTMS
				DFK->DFK_CODVEI := cCodVei
				DFK->DFK_KM     := 0
				DFK->DFK_PESO   := 0
				DFK->DFK_PESOM3 := 0
				DFK->DFK_VALMER := 0
				DFK->DFK_QTDVOL := 0      
				DFK->DFK_STAMOV := '2'
				MsUnLock()
				cItem := StrZero(1,Len(DFL->DFL_ITEM))
				While (cAliasQry)->(!Eof()) .And. (cAliasQry)->DG_CODVEI == cCodVei
					nCusto1 += (cAliasQry)->DG_CUSTO1
					nCusto2 += (cAliasQry)->DG_CUSTO2
					nCusto3 += (cAliasQry)->DG_CUSTO3
					nCusto4 += (cAliasQry)->DG_CUSTO4
					nCusto5 += (cAliasQry)->DG_CUSTO5
					RecLock('DFL',.T.)
					DFL->DFL_FILIAL := xFilial('DFL')
					DFL->DFL_IDCTMS := cIdCTMS
					DFL->DFL_CODVEI := cCodVei
					DFL->DFL_ITEM   := cItem
					DFL->DFL_CODDES := (cAliasQry)->DG_CODDES
					DFL->DFL_CUSTO1 := (cAliasQry)->DG_CUSTO1
					DFL->DFL_CUSTO2 := (cAliasQry)->DG_CUSTO2
					DFL->DFL_CUSTO3 := (cAliasQry)->DG_CUSTO3
					DFL->DFL_CUSTO4 := (cAliasQry)->DG_CUSTO4
					DFL->DFL_CUSTO5 := (cAliasQry)->DG_CUSTO5
					MsUnLock()
					cItem := Soma1(cItem)
					(cAliasQry)->(dbSkip())
				EndDo
				RecLock('DFK',.F.)
				DFK->DFK_CUSTO1 := nCusto1
				DFK->DFK_CUSTO2 := nCusto2
				DFK->DFK_CUSTO3 := nCusto3
				DFK->DFK_CUSTO4 := nCusto4
				DFK->DFK_CUSTO5 := nCusto5
				MsUnLock()
			End Transaction
		EndIf
	EndDo
	(cAliasQry)->(dbCloseArea())
	DbSelectArea(cAliasDFJ)
	If lCont		
		Aadd(aMsgErr,{ STR0048 }) //-- Veículos da Planilha com problemas de Km ou Peso. Verifique o Console do protheus
	EndIf
	
	Aadd(aLogTmp,{ '10o.' + STR0023 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo finalizado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	TMSAF99Con(StrZero(10,Len(DFJ->DFJ_INIPRO)),.T.)
EndIf	

aTamKm     := {} //-- Limpa Variavel
aTamPeso   := {} //-- Limpa Variavel
aTamPesoM3 := {} //-- Limpa Variavel

aCont := TMSAF99Con(StrZero(11,Len(DFJ->DFJ_INIPRO)))

oSelf:IncRegua2( OemToAnsi( "11-" + STR0033 ) )

If aCont[1]	

	IncProc("11-" + STR0033 ) //-- Rateio Plan.Veiculo nas Viagens Processado
	Aadd(aLogTmp,{ '11o.' + STR0022 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo iniciado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	
	//-- Rateio Plan.Veiculo nas viagens
	cQuery := "SELECT DFK_CODVEI, DFK_KM, DFK_PESO, DFK_PESOM3, DFK_CUSTO1, DFK_CUSTO2 " 
	cQuery += "  FROM "
	cQuery += RetSQLName('DFK')+" DFK  "
	cQuery += " WHERE DFK.DFK_FILIAL  = '"+xFilial('DFK')+"'"
	cQuery += "   AND DFK.DFK_IDCTMS  = '"+cIdCTMS+"'"
	cQuery += "   AND DFK.DFK_STAMOV  = '1'"
	cQuery += "   AND DFK.D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	TCSetField(cAliasQry,"DFK_KM"    ,"N",TamSx3("DFK_KM"    )[1],TamSx3("DFK_KM"    )[2])
	TCSetField(cAliasQry,"DFK_PESO"  ,"N",TamSx3("DFK_PESO"  )[1],TamSx3("DFK_PESO"  )[2])
	TCSetField(cAliasQry,"DFK_PESOM3","N",TamSx3("DFK_PESOM3")[1],TamSx3("DFK_PESOM3")[2])	
	TCSetField(cAliasQry,"DFK_CUSTO1","N",TamSx3("DFK_CUSTO1")[1],TamSx3("DFK_CUSTO1")[2])
	TCSetField(cAliasQry,"DFK_CUSTO2","N",TamSx3("DFK_CUSTO2")[1],TamSx3("DFK_CUSTO2")[2])

	While (cAliasQry)->(!Eof())

		nPos := Ascan( aQtdVge, { | e | e[VG_CODVEI] == (cAliasQry)->(DFK_CODVEI) })

		For nPQtVge := nPos To Len( aQtdVge )

			If aQtdVge[ nPQtVge ][ VG_CODVEI ] == (cAliasQry)->(DFK_CODVEI)

				nValRat := 0
				If aQtdVge[ nPQtVge ][ VG_SERTMS ] == '1'                                                             //-- Coleta
					If nRVeiVCol == 1                                                                                  //-- Quilometragem
						nValRat := ((cAliasQry)->DFK_CUSTO1 / (cAliasQry)->DFK_KM)   * aQtdVge[nPQtVge,VG_KM]
					ElseIf nRVeiVCol == 2                                                                              //-- Peso      
					If nCoEnPeso == 1                                                                               //-- Peso Real
							nValRat := ((cAliasQry)->DFK_CUSTO1 / (cAliasQry)->DFK_PESO) * aQtdVge[nPQtVge,VG_PESO]
						ElseIf nCoEnPeso == 2                                                                           //-- Peso Cubado
							nValRat := ((cAliasQry)->DFK_CUSTO1 / (cAliasQry)->DFK_PESOM3) * aQtdVge[nPQtVge,VG_PESOM3]
						EndIf				
					EndIf
				ElseIf aQtdVge[ nPQtVge ][ VG_SERTMS ] == '2'                                                         //-- Transporte		
					If nRVeiVTra == 1                                                                                  //-- Quilometragem
						nValRat := ((cAliasQry)->DFK_CUSTO1 / (cAliasQry)->DFK_KM)   * aQtdVge[nPQtVge,VG_KM]
					ElseIf nRVeiVTra == 2                                                                              //-- Peso   
					If nTranPeso == 1                                                                               //-- Peso Real
							nValRat := ((cAliasQry)->DFK_CUSTO1 / (cAliasQry)->DFK_PESO) * aQtdVge[nPQtVge,VG_PESO]
						ElseIf nTranPeso == 2                                                                           //-- Peso Cubado
							nValRat := ((cAliasQry)->DFK_CUSTO1 / (cAliasQry)->DFK_PESOM3) * aQtdVge[nPQtVge,VG_PESOM3]
						EndIf	
					EndIf
				ElseIf aQtdVge[ nPQtVge ][ VG_SERTMS ] == '3'                                                         //-- Entrega
					If nRVeiVEnt == 1                                                                                  //-- Quilometragem
						nValRat := ((cAliasQry)->DFK_CUSTO1 / (cAliasQry)->DFK_KM)   * aQtdVge[nPQtVge,VG_KM]
					ElseIf nRVeiVEnt == 2                                                                              //-- Peso
						If nCoEnPeso == 1                                                                               //-- Peso Real
							nValRat := ((cAliasQry)->DFK_CUSTO1 / (cAliasQry)->DFK_PESO) * aQtdVge[nPQtVge,VG_PESO]
						ElseIf nCoEnPeso == 2                                                                           //-- Peso Cubado
							nValRat := ((cAliasQry)->DFK_CUSTO1 / (cAliasQry)->DFK_PESOM3) * aQtdVge[nPQtVge,VG_PESOM3]
						EndIf
					EndIf
				EndIf
				aQtdVge[nPQtVge,VG_VALRAT] += nValRat
		EndIf

		Next nPQtVge

		(cAliasQry)->(dbSkip())

	EndDo

	(cAliasQry)->(dbCloseArea()) 
	dbSelectArea(cAliasDFJ)
	For nI := 1 To Len(aQtdVge)
		//-- Atualiza SDG
		cFilOri := aQtdVge[nI,VG_FILORI]
		cViagem := aQtdVge[nI,VG_VIAGEM]
		nCusto1 := aQtdVge[nI,VG_VALRAT]
		If nCusto1 > 0 
			If aCont[2] //Exclusao SDG devido a continuacao
				TMSAF99SDG('DFK',cMvDesVei,,cIdCTMS,dDatFim,,cFilOri,cViagem) 				           
			EndIf
			If lTMA99GSDG 
				nCustoProc := ExecBlock('TMA99GSDG',.F.,.F.,{10, cIdCTMS, nCusto1,cMvDesVei, cCodVei, cViagem})
				If ValType(nCustoProc) != 'N'
					nCustoProc := 0
				EndIf
				TMA250GrvSDG('DFK', cFilOri, cViagem, cMvDesVei, nCustoProc, , , , , , cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2")
			Else
				TMA250GrvSDG('DFK', cFilOri, cViagem, cMvDesVei, nCusto1, , , , , , cIdCTMS, STR0013, dDatFim,,,,,,lCusto,,,"TMSAF99","2")
			EndIf
		EndIf
	Next nI
	Aadd(aLogTmp,{ '11o.' + STR0023 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo finalizado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	TMSAF99Con(StrZero(11,Len(DFJ->DFJ_INIPRO)),.T.)
EndIf	

aCont := TMSAF99Con(StrZero(12,Len(DFJ->DFJ_INIPRO)))

oSelf:IncRegua2( OemToAnsi( "12-" + STR0034 ) )

If aCont[1]

	//-- Apura custo das viagens 
	IncProc("12-" + STR0034 ) //-- Apuracao de Custos das Viagens
	Aadd(aLogTmp,{ '12o.' + STR0022 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo iniciado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	
	If aCont[2] //Exclusao devido a continuacao
		TMSAF99SDG('',,,cIdCTMS,dDatFim,StrZero(12,Len(DFJ->DFJ_INIPRO)))
	EndIf
	
	aFilSDG:= {}
	cQuery := "SELECT SDG.DG_FILIAL FROM "+RetSqlName('SDG')+" SDG WHERE SDG.DG_VIAGEM <> ' ' AND SDG.D_E_L_E_T_ = ' ' GROUP BY DG_FILIAL ORDER BY DG_FILIAL"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	While (cAliasQry)->(!Eof())
	Aadd(aFilSDG,(cAliasQry)->DG_FILIAL)
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())             	
	If Empty(aFilSDG)
		Aadd(aFilSDG,cFilAnt)
	EndIf		
	For nX := 1 To Len(aFilSDG)  
		//-- Apura custo das viagens	
		cQuery := "SELECT DG_FILORI, DG_VIAGEM, DG_CODDES, SUM(DG_CUSTO1) DG_CUSTO1, SUM(DG_CUSTO2) DG_CUSTO2, "
		cQuery += "                                        SUM(DG_CUSTO3) DG_CUSTO3, SUM(DG_CUSTO4) DG_CUSTO4, SUM(DG_CUSTO5) DG_CUSTO5"
		cQuery += "  FROM "
		cQuery += RetSqlName('SDG')+" SDG "
		cQuery += " JOIN "+RetSqlName('DTQ')+" DTQ " 
		cQuery += "    ON DTQ.DTQ_FILIAL  = '"+xFilial('DTQ')+"'"
		cQuery += "   AND DTQ.DTQ_DATENC  BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFim)+"'"
		cQuery += "   AND DTQ.DTQ_STATUS IN ( '3', '9' )"
		cQuery += "   AND DTQ.DTQ_FILORI  = SDG.DG_FILORI "          
		cQuery += "   AND DTQ.DTQ_VIAGEM  = SDG.DG_VIAGEM "          
		cQuery += "   AND DTQ.D_E_L_E_T_  = ' '"          	
		cQuery += " WHERE SDG.DG_FILIAL   = '"+Iif(Empty(xFilial('SDG')),xFilial('SDG'),aFilSDG[nX])+"'"
		cQuery += "   AND SDG.DG_VIAGEM  <> ' '"
		cQuery += "   AND SDG.DG_STATUS   = '3'"          
		cQuery += "   AND SDG.D_E_L_E_T_  = ' '" 		
		cQuery += " GROUP BY DG_FILORI, DG_VIAGEM, DG_CODDES"
		cQuery += " ORDER BY DG_FILORI, DG_VIAGEM" 
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		TCSetField(cAliasQry,"DG_CUSTO1","N",TamSx3("DG_CUSTO1")[1],TamSx3("DG_CUSTO1")[2])
		TCSetField(cAliasQry,"DG_CUSTO2","N",TamSx3("DG_CUSTO2")[1],TamSx3("DG_CUSTO2")[2])
		TCSetField(cAliasQry,"DG_CUSTO3","N",TamSx3("DG_CUSTO3")[1],TamSx3("DG_CUSTO3")[2])
		TCSetField(cAliasQry,"DG_CUSTO4","N",TamSx3("DG_CUSTO4")[1],TamSx3("DG_CUSTO4")[2])
		TCSetField(cAliasQry,"DG_CUSTO5","N",TamSx3("DG_CUSTO5")[1],TamSx3("DG_CUSTO5")[2])
		While (cAliasQry)->(!Eof())
			cFilOri := (cAliasQry)->DG_FILORI
			cViagem := (cAliasQry)->DG_VIAGEM
			nCusto1 := 0
			nCusto2 := 0
			nCusto3 := 0
			nCusto4 := 0
			nCusto5 := 0                                                                  
			While (cAliasQry)->(!Eof()) .And. (cAliasQry)->(DG_FILORI+DG_VIAGEM) == cFilOri+cViagem
				RecLock('DFM',.T.)
				DFM->DFM_FILIAL := xFilial('DFM')
				DFM->DFM_IDCTMS := cIdCTMS
				DFM->DFM_FILORI := cFilOri
				DFM->DFM_VIAGEM := cViagem
				DFM->DFM_CODDES := (cAliasQry)->DG_CODDES
				DFM->DFM_CUSTO1 := (cAliasQry)->DG_CUSTO1
				DFM->DFM_CUSTO2 := (cAliasQry)->DG_CUSTO2
				DFM->DFM_CUSTO3 := (cAliasQry)->DG_CUSTO3
				DFM->DFM_CUSTO4 := (cAliasQry)->DG_CUSTO4
				DFM->DFM_CUSTO5 := (cAliasQry)->DG_CUSTO5
				MsUnLock()
				dbCommit()
				nCusto1 += (cAliasQry)->DG_CUSTO1
				nCusto2 += (cAliasQry)->DG_CUSTO2
				nCusto3 += (cAliasQry)->DG_CUSTO3
				nCusto4 += (cAliasQry)->DG_CUSTO4
				nCusto5 += (cAliasQry)->DG_CUSTO5
				(cAliasQry)->(dbSkip())
			EndDo
			If nCusto1 > 0
				DTQ->(dbSetOrder(2))
				If DTQ->(dbSeek(xFilial('DTQ')+cFilOri+cViagem))
					RecLock('DTQ',.F.)
					DTQ->DTQ_CUSTO1 := nCusto1
					DTQ->DTQ_CUSTO2 := nCusto2
					DTQ->DTQ_CUSTO3 := nCusto3
					DTQ->DTQ_CUSTO4 := nCusto4
					DTQ->DTQ_CUSTO5 := nCusto5
					MsUnLock()
					dbCommit()
				EndIf
			EndIf
		EndDo
		(cAliasQry)->(dbCloseArea())     
	DbSelectArea(cAliasDFJ)	
	Next
	Aadd(aLogTmp,{ '12o.' + STR0023 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo finalizado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	TMSAF99Con(StrZero(12,Len(DFJ->DFJ_INIPRO)),.T.)
EndIf	

aCont := TMSAF99Con(StrZero(13,Len(DFJ->DFJ_INIPRO)))

oSelf:IncRegua2( OemToAnsi( "13-" + STR0035 ) )

If aCont[1]

	//-- Apura custo dos documentos a partir das viagens
	IncProc("13-" + STR0035 ) //-- Apuracao de Custos dos Documentos processado
	Aadd(aLogTmp,{ '13o.' + STR0022 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo iniciado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	
	If aCont[2] //Exclusao devido a continuacao
		TMSAF99SDG('',,,cIdCTMS,dDatFim,StrZero(13,Len(DFJ->DFJ_INIPRO)))
	EndIf	
	
	aDistRot := {}
	cQuery := "SELECT DFM_FILORI, DFM_VIAGEM, DFM_CODDES, DFM_CUSTO1, DFM_CUSTO2, DFM_CUSTO3, DFM_CUSTO4, "
	cQuery += "       DFM_CUSTO5, DTQ_SERTMS, DTQ_TIPTRA"
	cQuery += "  FROM "
	cQuery += RetSqlName('DFM')+" DFM, "
	cQuery += RetSqlName('DTQ')+" DTQ  "
	cQuery += " WHERE DFM.DFM_FILIAL = '"+xFilial('DFM')+"'"
	cQuery += "   AND DFM.DFM_IDCTMS = '"+cIdCTMS+"'"
	cQuery += "   AND DFM.D_E_L_E_T_ = ' '"
	cQuery += "   AND DTQ.DTQ_FILIAL = '"+xFilial('DTQ')+"'"
	cQuery += "   AND DTQ.DTQ_FILORI = DFM_FILORI"
	cQuery += "   AND DTQ.DTQ_VIAGEM = DFM_VIAGEM"
	cQuery += "   AND DTQ.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY DFM_FILORI, DFM_VIAGEM, DFM_CODDES"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	TCSetField(cAliasQry,"DFM_CUSTO1","N",TamSx3("DFM_CUSTO1")[1],TamSx3("DFM_CUSTO1")[2])
	TCSetField(cAliasQry,"DFM_CUSTO2","N",TamSx3("DFM_CUSTO2")[1],TamSx3("DFM_CUSTO2")[2])
	TCSetField(cAliasQry,"DFM_CUSTO3","N",TamSx3("DFM_CUSTO3")[1],TamSx3("DFM_CUSTO3")[2])
	TCSetField(cAliasQry,"DFM_CUSTO4","N",TamSx3("DFM_CUSTO4")[1],TamSx3("DFM_CUSTO4")[2])
	TCSetField(cAliasQry,"DFM_CUSTO5","N",TamSx3("DFM_CUSTO5")[1],TamSx3("DFM_CUSTO5")[2])
	While (cAliasQry)->(!Eof())
		If (nPQtVge := Ascan(aQtdVge, { | e | e[VG_FILORI]+e[VG_VIAGEM] == (cAliasQry)->(DFM_FILORI+DFM_VIAGEM) })) == 0
			(cAliasQry)->(dbSkip())
			Loop
		EndIf		
		If (cAliasQry)->DTQ_SERTMS == '2'           //-- Transporte
		If nTranPeso == 1                        //-- Peso Real
				nPesVge := aQtdVge[nPQtVge,VG_PESO]
			ElseIf nTranPeso == 2                    //-- Peso Cubado
				nPesVge := aQtdVge[nPQtVge,VG_PESOM3]			
			EndIf	
			cQuery := "SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_PESO PESDOC, DT6_PESOM3 PESDOCM3, DT6_CDRORI, DT6_CDRCAL, DUD_FILATU, DUD_FILDCA, 0 KMDOC  "
			cQuery += "  FROM "
			cQuery += RetSqlName('DT6')+" DT6, "
			cQuery += RetSqlName('DUD')+" DUD  "
			cQuery += " WHERE DUD.DUD_FILIAL = '"+xFilial('DUD')+"'"
			cQuery += "   AND DUD.DUD_FILORI = '"+(cAliasQry)->DFM_FILORI+"'"
			cQuery += "   AND DUD.DUD_VIAGEM = '"+(cAliasQry)->DFM_VIAGEM+"'"
			cQuery += "   AND DUD.D_E_L_E_T_ = ' '"
			cQuery += "   AND DT6.DT6_FILIAL = '"+xFilial('DT6')+"'"
			cQuery += "   AND DT6.DT6_FILDOC = DUD_FILDOC"
			cQuery += "   AND DT6.DT6_DOC    = DUD_DOC"
			cQuery += "   AND DT6.DT6_SERIE  = DUD_SERIE"
			cQuery += "   AND DT6.D_E_L_E_T_ = ' '"
		Else
			If nCoEnPeso == 1                         //-- Peso Real
				nPesVge := aQtdVge[nPQtVge,VG_PESO]
			ElseIf nCoEnPeso == 2                     //-- Peso Cubado
				nPesVge := aQtdVge[nPQtVge,VG_PESOM3]			
			EndIf	
			If DUA->(ColumnPos('DUA_KMDOC')) > 0
				cQuery := "SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, DUA_PESOCO PESDOC, DT6_PESOM3 PESDOCM3, DT6_CDRORI, DT6_CDRCAL, DUD_FILATU, DUD_FILDCA, DUA_KMDOC KMDOC "
			Else
				cQuery := "SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, DUA_PESOCO PESDOC, DT6_PESOM3 PESDOCM3, DT6_CDRORI, DT6_CDRCAL, DUD_FILATU, DUD_FILDCA "
			EndIf
			cQuery += "  FROM "
			cQuery += RetSqlName('DT6')+" DT6, "
			cQuery += RetSqlName('DUD')+" DUD, "
			cQuery += RetSqlName('DUA')+" DUA, "						
			cQuery += RetSqlName('DT2')+" DT2  "						
			cQuery += " WHERE DUD.DUD_FILIAL = '"+xFilial('DUD')+"'"
			cQuery += "   AND DUD.DUD_FILORI = '"+(cAliasQry)->DFM_FILORI+"'"
			cQuery += "   AND DUD.DUD_VIAGEM = '"+(cAliasQry)->DFM_VIAGEM+"'"
			cQuery += "   AND DT6.DT6_FILIAL = '"+xFilial('DT6')+"'"
			cQuery += "   AND DT6.DT6_FILDOC = DUD_FILDOC"
			cQuery += "   AND DT6.DT6_DOC    = DUD_DOC"
			cQuery += "   AND DT6.DT6_SERIE  = DUD_SERIE"
			cQuery += "   AND DT6.D_E_L_E_T_ = ' '"
			cQuery += "   AND DUA.DUA_FILIAL = '"+xFilial('DUD')+"'"
			cQuery += "   AND DUA.DUA_FILORI = DUD_FILORI"
			cQuery += "   AND DUA.DUA_VIAGEM = DUD_VIAGEM"
			cQuery += "   AND DUA.DUA_FILDOC = DUD_FILDOC"
			cQuery += "   AND DUA.DUA_DOC    = DUD_DOC   "
			cQuery += "   AND DUA.DUA_SERIE  = DUD_SERIE "
			cQuery += "   AND DUA.D_E_L_E_T_ = ' '"
			cQuery += "   AND DT2.DT2_FILIAL = '"+xFilial('DTA')+"'"
			cQuery += "   AND DT2.DT2_CODOCO = DUA_CODOCO"
			cQuery += "   AND DT2.DT2_TIPOCO NOT IN ( '05' )"
			cQuery += "   AND DT2.D_E_L_E_T_ = ' '"
		EndIf		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasVge)                              
		TCSetField(cAliasVge,"PESDOC"    ,"N",TamSx3("DT6_PESO"  )[1],TamSx3("DT6_PESO"  )[2])
		TCSetField(cAliasVge,"PESDOCM3"  ,"N",TamSx3("DT6_PESOM3")[1],TamSx3("DT6_PESOM3")[2])
		nQKmVge := aQtdVge[nPQtVge,VG_KM]
		While (cAliasVge)->(!Eof())
			nCusto1 := (cAliasQry)->DFM_CUSTO1
			nCusto2 := (cAliasQry)->DFM_CUSTO2
			nCusto3 := (cAliasQry)->DFM_CUSTO3
			nCusto4 := (cAliasQry)->DFM_CUSTO4
			nCusto5 := (cAliasQry)->DFM_CUSTO5
			nPesDoc := 0
			nQKmDoc := 0  
			nValRt1 := 0
			nValRt2 := 0
			nValRt3 := 0
			nValRt4 := 0
			nValRt5 := 0 
			nPos := Ascan( aQtdVge, { |y| y[ VG_FILORI ] + y[ VG_VIAGEM ] == (cAliasQry)->DFM_FILORI + (cAliasQry)->DFM_VIAGEM } )
			If nPos > 0
				If DUA->(ColumnPos('DUA_KMDOC')) > 0
					nQKmDoc := (cAliasVge)->KMDOC 
				Else
					nQKmDoc := aQtdVge[ nPos ][ VG_KM ]
				EndIf
			EndIf
			If (cAliasQry)->DTQ_SERTMS == '1' //-- Coleta		 			
				If nCoEnPeso == 1 //-- Peso Real
					nPesDoc := (cAliasVge)->PESDOC
				ElseIf nCoEnPeso == 2 //-- Peso Cubado
					nPesDoc := Max((cAliasVge)->PESDOC,(cAliasVge)->PESDOCM3)  //-- Caso de PesoM3 Zerado assume o Peso
				EndIf		
				If nRVColDoc == 1 //-- Quilometragem
					If nCusto1 > 0
						nValRt1 := (nCusto1 / nQKmVge) * nQKmDoc
					EndIf
					If nCusto2 > 0
						nValRt2 := (nCusto2 / nQKmVge) * nQKmDoc
					EndIf						
					If nCusto3 > 0
						nValRt3 := (nCusto3 / nQKmVge) * nQKmDoc
					EndIf						
					If nCusto4 > 0
						nValRt4 := (nCusto4 / nQKmVge) * nQKmDoc
					EndIf						
					If nCusto5 > 0
						nValRt5 := (nCusto5 / nQKmVge) * nQKmDoc
					EndIf						
				ElseIf nRVColDoc == 2 //-- Quilometragem e Peso
					If nCusto1 > 0
						nValRt1 := (nCusto1 / (nQKmVge * nPesVge)) * (nPesDoc * nQKmDoc)
					EndIf
					If nCusto2 > 0
						nValRt2 := (nCusto2 / (nQKmVge * nPesVge)) * (nPesDoc * nQKmDoc)
					EndIf
					If nCusto3 > 0
						nValRt3 := (nCusto3 / (nQKmVge * nPesVge)) * (nPesDoc * nQKmDoc)
					EndIf
					If nCusto4 > 0
						nValRt4 := (nCusto4 / (nQKmVge * nPesVge)) * (nPesDoc * nQKmDoc)
					EndIf
					If nCusto5 > 0
						nValRt5 := (nCusto5 / (nQKmVge * nPesVge)) * (nPesDoc * nQKmDoc)
					EndIf
				ElseIf nRVColDoc == 3 //-- Peso
					If nCusto1 > 0
						nValRt1 := (nCusto1 / nPesVge) * nPesDoc
					EndIf						
					If nCusto2 > 0
						nValRt2 := (nCusto2 / nPesVge) * nPesDoc
					EndIf						
					If nCusto3 > 0
						nValRt3 := (nCusto3 / nPesVge) * nPesDoc
					EndIf						
					If nCusto4 > 0
						nValRt4 := (nCusto4 / nPesVge) * nPesDoc
					EndIf						
					If nCusto5 > 0
						nValRt5 := (nCusto5 / nPesVge) * nPesDoc
					EndIf						
				EndIf
			ElseIf (cAliasQry)->DTQ_SERTMS == '2' //-- Transporte
				If nTranPeso == 1 //-- Peso Real
					nPesDoc := (cAliasVge)->PESDOC
				ElseIf nTranPeso == 2 //-- Peso Cubado
					nPesDoc := Max((cAliasVge)->PESDOC,(cAliasVge)->PESDOCM3)  //-- Caso de PesoM3 Zerado assume o Peso
				EndIf		
				If (cAliasQry)->DTQ_TIPTRA == "2" //-- Aereo
					nRateDoc := nRVTrEDoc 
				ElseIf (cAliasQry)->DTQ_TIPTRA == "3" //-- Fluvial
					nRateDoc := nRVTrFDoc
				Else  //--Rodoviario -- Internacional
					nRateDoc := nRVTraDoc
				EndIf
				If nRateDoc == 1 //-- Quilometragem
					If nCusto1 > 0
						nValRt1 := (nCusto1 / nQKmVge) * nQKmDoc
					EndIf
					If nCusto2 > 0
						nValRt2 := (nCusto2 / nQKmVge) * nQKmDoc
					EndIf						
					If nCusto3 > 0
						nValRt3 := (nCusto3 / nQKmVge) * nQKmDoc
					EndIf						
					If nCusto4 > 0
						nValRt4 := (nCusto4 / nQKmVge) * nQKmDoc
					EndIf						
					If nCusto5 > 0
						nValRt5 := (nCusto5 / nQKmVge) * nQKmDoc
					EndIf						
				ElseIf nRateDoc == 2 //-- Quilometragem e Peso
					If nCusto1 > 0
						nValRt1 := (nCusto1 / (nQKmVge * nPesVge)) * (nPesDoc * nQKmDoc)
					EndIf
					If nCusto2 > 0
						nValRt2 := (nCusto2 / (nQKmVge * nPesVge)) * (nPesDoc * nQKmDoc)
					EndIf
					If nCusto3 > 0
						nValRt3 := (nCusto3 / (nQKmVge * nPesVge)) * (nPesDoc * nQKmDoc)
					EndIf
					If nCusto4 > 0
						nValRt4 := (nCusto4 / (nQKmVge * nPesVge)) * (nPesDoc * nQKmDoc)
					EndIf
					If nCusto5 > 0
						nValRt5 := (nCusto5 / (nQKmVge * nPesVge)) * (nPesDoc * nQKmDoc)
					EndIf
				ElseIf nRateDoc == 3 //-- Peso
					If nCusto1 > 0
						nValRt1 := (nCusto1 / nPesVge) * nPesDoc
					EndIf						
					If nCusto2 > 0
						nValRt2 := (nCusto2 / nPesVge) * nPesDoc
					EndIf						
					If nCusto3 > 0
						nValRt3 := (nCusto3 / nPesVge) * nPesDoc
					EndIf						
					If nCusto4 > 0
						nValRt4 := (nCusto4 / nPesVge) * nPesDoc
					EndIf						
					If nCusto5 > 0
						nValRt5 := (nCusto5 / nPesVge) * nPesDoc
					EndIf						
				EndIf
			ElseIf (cAliasQry)->DTQ_SERTMS == '3' //-- Entrega
				If nCoEnPeso == 1 //-- Peso Real
					nPesDoc := (cAliasVge)->PESDOC
				ElseIf nCoEnPeso == 2 //-- Peso Cubado
					nPesDoc := Max((cAliasVge)->PESDOC,(cAliasVge)->PESDOCM3)  //-- Caso de PesoM3 Zerado assume o Peso
				EndIf		
				If nRVEntDoc == 1 //-- Quilometragem
					If nCusto1 > 0
						nValRt1 := (nCusto1 / nQKmVge) * nQKmDoc
					EndIf
					If nCusto2 > 0
						nValRt2 := (nCusto2 / nQKmVge) * nQKmDoc
					EndIf						
					If nCusto3 > 0
						nValRt3 := (nCusto3 / nQKmVge) * nQKmDoc
					EndIf						
					If nCusto4 > 0
						nValRt4 := (nCusto4 / nQKmVge) * nQKmDoc
					EndIf						
					If nCusto5 > 0
						nValRt5 := (nCusto5 / nQKmVge) * nQKmDoc
					EndIf						
				ElseIf nRVEntDoc == 2 //-- Quilometragem e Peso
					If nCusto1 > 0
						nValRt1 := (nCusto1 / (nQKmVge * nPesVge)) * (nPesDoc * nQKmDoc)
					EndIf
					If nCusto2 > 0
						nValRt2 := (nCusto2 / (nQKmVge * nPesVge)) * (nPesDoc * nQKmDoc)
					EndIf
					If nCusto3 > 0
						nValRt3 := (nCusto3 / (nQKmVge * nPesVge)) * (nPesDoc * nQKmDoc)
					EndIf
					If nCusto4 > 0
						nValRt4 := (nCusto4 / (nQKmVge * nPesVge)) * (nPesDoc * nQKmDoc)
					EndIf
					If nCusto5 > 0
						nValRt5 := (nCusto5 / (nQKmVge * nPesVge)) * (nPesDoc * nQKmDoc)
					EndIf
				ElseIf nRVEntDoc == 3 //-- Peso
					If nCusto1 > 0
						nValRt1 := (nCusto1 / nPesVge) * nPesDoc
					EndIf						
					If nCusto2 > 0
						nValRt2 := (nCusto2 / nPesVge) * nPesDoc
					EndIf						
					If nCusto3 > 0
						nValRt3 := (nCusto3 / nPesVge) * nPesDoc
					EndIf						
					If nCusto4 > 0
						nValRt4 := (nCusto4 / nPesVge) * nPesDoc
					EndIf						
					If nCusto5 > 0
						nValRt5 := (nCusto5 / nPesVge) * nPesDoc
					EndIf						
				EndIf
			EndIf
			If nValRt1 > 0	.Or. nValRt2 > 0 .Or. nValRt3 > 0 .Or. nValRt4 > 0 .Or. nValRt5 > 0
				DFN->(dbSetOrder(1))
				If DFN->(!dbSeek(xFilial('DFN')+cIdCTMS+(cAliasVge)->(DT6_FILDOC+DT6_DOC+DT6_SERIE)+(cAliasQry)->(DTQ_SERTMS+DTQ_TIPTRA+DFM_CODDES)))
					RecLock('DFN',.T.)
					DFN->DFN_FILIAL := xFilial('DFN')
					DFN->DFN_IDCTMS := cIdCTMS
					DFN->DFN_FILDOC := (cAliasVge)->DT6_FILDOC
					DFN->DFN_DOC    := (cAliasVge)->DT6_DOC
					DFN->DFN_SERIE  := (cAliasVge)->DT6_SERIE
					DFN->DFN_SERTMS := (cAliasQry)->DTQ_SERTMS
					DFN->DFN_TIPTRA := (cAliasQry)->DTQ_TIPTRA
					DFN->DFN_CODDES := (cAliasQry)->DFM_CODDES
				Else
					RecLock('DFN',.F.)
				EndIf			
				DFN->DFN_CUSTO1 += nValRt1
				DFN->DFN_CUSTO2 += nValRt2
				DFN->DFN_CUSTO3 += nValRt3
				DFN->DFN_CUSTO4 += nValRt4
				DFN->DFN_CUSTO5 += nValRt5
				MsUnLock()
				dbCommit()
		EndIf
			(cAliasVge)->(dbSkip())
		EndDo				
		(cAliasVge)->(dbCloseArea())
		DbSelectArea(cAliasQry)	
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	dBSelectArea(cAliasDFJ) 
	Aadd(aLogTmp,{ '13o.' + STR0023 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo finalizado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	TMSAF99Con(StrZero(13,Len(DFJ->DFJ_INIPRO)),.T.)
EndIf	

aDistRot  := {} //-- Limpa Variavel
cAliaTFAI := GetNextAlias() 	
cAliaTDOC := GetNextAlias()		
cAliaTSAL := GetNextAlias()		

aCont := TMSAF99Con(StrZero(14,Len(DFJ->DFJ_INIPRO)))

oSelf:IncRegua2( OemToAnsi( "14-" + STR0036 ) )

If aCont[1]

	//-- Rateio de despesas por contas contábeis
	IncProc("14-" + STR0036 ) //-- Rateio de Despesas por Contas Contabeis
	Aadd(aLogTmp,{ '14o.' + STR0022 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo iniciado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria arquivos de trabalho para controle  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !TMSAF99Trb(cAliaTDOC,cAliaTSAL,cAliaTFAI,cIdCTMS,@oTempTDOC,@oTempTSAL,@oTempTFAI)
		Return(Nil)
	EndIf

	cRealTDOC	:= oTempTDOC:GetRealName()
	cRealTSAL 	:= oTempTSAL:GetRealName()
	cRealTFAI	:= oTempTFAI:GetRealName()

	aFiliFSM0 := {}
	cQuery := "SELECT DF9.DF9_FILIAL FROM "+RetSqlName('DF9')+" DF9 WHERE DF9.D_E_L_E_T_ = ' ' GROUP BY DF9_FILIAL ORDER BY DF9_FILIAL"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	While (cAliasQry)->(!Eof())
	Aadd(aFiliFSM0,(cAliasQry)->DF9_FILIAL)	
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	dBSelectArea(cAliasDFJ)      
	
	nFiliais := Len(aFiliFSM0)
	For nX := 1 To nFiliais
		cQuery := "SELECT DFA.*, DF9.* , DF9.R_E_C_N_O_ DF9RECNO "
		cQuery += "  FROM "
		cQuery += RetSqlName("DFA")+" DFA, "
		cQuery += RetSqlName("DF9")+" DF9  "
		cQuery += "WHERE DF9.DF9_FILIAL = '"+aFiliFSM0[nX]+"' "
		cQuery += "  AND DF9.D_E_L_E_T_ = ' ' "
		cQuery += "  AND DFA.DFA_FILIAL = DF9.DF9_FILIAL "
		cQuery += "  AND DFA.DFA_CODDES = DF9.DF9_CODDES "
		cQuery += "  AND DFA.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY DF9_FILIAL, DF9_CODDES, DF9_RATEIO, DFA_IDENCT, DFA_ITEM "
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		While (cAliasQry)->(!Eof())
			cFilCta  := (cAliasQry)->DF9_FILIAL
			cCodDes  := (cAliasQry)->DF9_CODDES
			cRateio  := (cAliasQry)->DF9_RATEIO
			cSrtCus  := (cAliasQry)->DF9_SRTCUS
			cTptCus  := (cAliasQry)->DF9_TPTCUS
			cDocCus  := (cAliasQry)->DF9_DOCCUS
			cTipCar  := (cAliasQry)->DF9_TIPCAR
			cCarExp  := (cAliasQry)->DF9_CAREXP
			cCarRec  := (cAliasQry)->DF9_CARREC
			cCarRep  := (cAliasQry)->DF9_CARREP
			cFaixa   := (cAliasQry)->DF9_FAIXA
			nPerRep  := (cAliasQry)->DF9_PERREP
			aFaixas  := {}
			nCCSaldo := 0
			nCCDesp  := 0
			cFilAnt	 := (cAliasQry)->DF9_FILIAL 
			If !Empty(cSrtCus)
				If AT('*',cSrtCus) > 0
					aOpcTra:= TMSValField('SERTMS',.F.,,.F.,.T.)
					cAuxStr:= ''
					For nI := 1 To Len(aOpcTra)
						If !Empty(cAuxStr)
							cAuxStr += ';'
						EndIf
						cAuxStr += aOpcTra[nI,1]
					Next nI
				Else
					cAuxStr := cSrtCus
				EndIf
				cSrtCus := ""
				While AT(";",cAuxStr) > 0
					cSrtCus += "'"+Subs(cAuxStr,1,AT(";",cAuxStr)-1)
					cAuxStr := Stuff(cAuxStr,AT(";",cAuxStr)-1,2, '')
					If !Empty(cSrtCus)
						cSrtCus += "',"
					EndIf
				EndDo
				If !Empty(cAuxStr)
					cSrtCus += "'"+Alltrim(cAuxStr)
				EndIf
				If !Empty(cSrtCus)
					cSrtCus += "'"
				EndIf
			EndIf
			If !Empty(cTptCus)
				If AT("*",cTptCus) > 0
					aOpcTra:= TMSValField("TIPTRA",.F.,,.F.,.T.)
					cAuxStr:= ''
					For nI := 1 To Len(aOpcTra)
						If !Empty(cAuxStr)
							cAuxStr += ";"
						EndIf
						cAuxStr += aOpcTra[nI,1]
					Next nI
				Else
					cAuxStr := cTptCus
				EndIf
				cTptCus := ""
				While AT(";",cAuxStr) > 0
					cTptCus += "'"+Subs(cAuxStr,1,AT(";",cAuxStr)-1)
					cAuxStr := Stuff(cAuxStr,AT(";",cAuxStr)-1,2, '')
					If !Empty(cTptCus)
						cTptCus += "',"
					EndIf
				EndDo
				If !Empty(cAuxStr)
					cTptCus += "'"+Alltrim(cAuxStr)
				EndIf
				If !Empty(cTptCus)
					cTptCus += "'"
				EndIf
			EndIf
			If !Empty(cDocCus)
				If AT("*",cDocCus) > 0
					aOpcTra:= TMSValField("DOCTMS",.F.,,.F.,.T.)
					cAuxStr:= ''
					For nI := 1 To Len(aOpcTra)
						If !Empty(cAuxStr)
							cAuxStr += ";"
						EndIf
						cAuxStr += aOpcTra[nI,1]
					Next nI
				Else
					cAuxStr := cDocCus
				EndIf
				cDocCus := ""
				While AT(";",cAuxStr) > 0
					cDocCus += "'"+Subs(cAuxStr,1,AT(";",cAuxStr)-1)
					cAuxStr := Stuff(cAuxStr,AT(";",cAuxStr)-1,2, '')
					If !Empty(cDocCus)
						cDocCus += "',"
					EndIf
				EndDo
				If !Empty(cAuxStr)
					cDocCus += "'"+Alltrim(cAuxStr)
				EndIf
				If !Empty(cDocCus)
					cDocCus += "'"
				EndIf
			EndIf
			If cFaixa <> '0' //Não Utiliza Rateio
				cQuery   := "SELECT DFB_FILIAL, DFB_VALATE"
				cQuery   += "  FROM "
				cQuery   += RetSqlName("DFB")+" DFB "
				cQuery   += "WHERE DFB.DFB_FILIAL = '" + xFilial("DFB") + "'"
				cQuery   += "  AND DFB.DFB_CODDES = '"+cCodDes+"'"
				cQuery   += "  AND DFB.D_E_L_E_T_ = ' '"
				cQuery   := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDFB)
				TCSetField(cAliasDFB,"DFB_VALATE","N",TamSx3("DFB_VALATE")[1],TamSx3("DFB_VALATE")[2])
				While (cAliasDFB)->(!Eof())	
					//-- ARRAY aFaixas
					//-- [1] - Valor Ate
					//-- [2] - Realiza rateio
					//-- [3] - Valor Acumulado da Faixa
					//-- [4] - Valor Acumulado da Faixa * Valor da Despesa
					Aadd(aFaixas,{ (cAliasDFB)->DFB_VALATE, .T., 0, 0 })					
					(cAliasDFB)->(dbSkip())
				EndDo
				(cAliasDFB)->(dbCloseArea())
			EndIf
			If Len(aFaixas) == 0
				Aadd(aFaixas,{ 999999999.9999, .F., 0, 0 })
			EndIf
			cQuery := "SELECT DT6_FILDOC, DT6_DOC   , DT6_SERIE , DT6_SERTMS, DT6_TIPTRA, "
			cQuery += "       DT6_PESO  , DT6_VALMER, DT6_PESOM3, DT6_VALFAT, DT6_QTDVOL, "
			cQuery += "       DT6_FILDES, DUD_FILORI"
			cQuery += "  FROM "
			cQuery += RetSqlName("DT6")+" DT6, "
			cQuery += RetSqlName("DUD")+" DUD  "
			cQuery += " WHERE DT6.DT6_FILIAL = '" + xFilial("DT6") + "'"
			cQuery += "   AND DT6.DT6_DATEMI BETWEEN '" +Dtos(dDatIni) + "' AND '" +Dtos(dDatFim) +"'  "
			If !Empty(cSrtCus)
				cQuery += "AND DT6.DT6_SERTMS IN ( "+cSrtCus+" ) "
			EndIf
			If !Empty(cTptCus)
				cQuery += "AND DT6.DT6_TIPTRA IN ( "+cTptCus+" ) "
			EndIf
			If !Empty(cDocCus)
				cQuery += "AND DT6.DT6_DOCTMS IN ( "+cDocCus+" ) "
			EndIf
			cQuery += "   AND DT6.D_E_L_E_T_ = ' '"
			cQuery += "   AND DUD.DUD_FILIAL = '" + xFilial("DUD") + "'"
			cQuery += "   AND DUD.DUD_FILDOC = DT6_FILDOC"
			cQuery += "   AND DUD.DUD_DOC    = DT6_DOC   "
			cQuery += "   AND DUD.DUD_SERIE  = DT6_SERIE "
			If !Empty(FwModeAccess('DF9',3))
				cQuery += "AND DUD.DUD_FILORI = '"+cFilCta+"'"
			EndIf					
			cQuery += "   AND DUD.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDT6)
			TCSetField(cAliasDT6,"DT6_PESO"  ,"N",TamSx3("DT6_PESO"  )[1],TamSx3("DT6_PESO"  )[2])
			TCSetField(cAliasDT6,"DT6_PESOM3","N",TamSx3("DT6_PESOM3")[1],TamSx3("DT6_PESOM3")[2])
			TCSetField(cAliasDT6,"DT6_VALMER","N",TamSx3("DT6_VALMER")[1],TamSx3("DT6_VALMER")[2])
			TCSetField(cAliasDT6,"DT6_VALFAT","N",TamSx3("DT6_VALFAT")[1],TamSx3("DT6_VALFAT")[2])
			TCSetField(cAliasDT6,"DT6_QTDVOL","N",TamSx3("DT6_QTDVOL")[1],TamSx3("DT6_QTDVOL")[2])
			While (cAliasDT6)->(!Eof())
				nPeso   := (cAliasDT6)->DT6_PESO
				nPesoM3 := (cAliasDT6)->DT6_PESOM3
				//-- Tipo da Carga
				If cTipCar == '1'  //-- Carga Direta
					If Max(nPeso,nPesoM3) <= nMvCargDir
						(cAliasDT6)->(dbSkip())
						Loop
					EndIf
				ElseIf cTipCar == '2' //-- Carga Fracionada
					If Max(nPeso,nPesoM3) >  nMvCargDir
						(cAliasDT6)->(dbSkip())
						Loop
					EndIf
				EndIf
				lCarExp := (cAliasDT6)->DT6_FILDOC == (cAliasDT6)->DUD_FILORI
				lCarRec := (cAliasDT6)->DT6_FILDOC <> (cAliasDT6)->DUD_FILORI .And. (cAliasDT6)->DT6_FILDES == (cAliasDT6)->DUD_FILORI
				lCarRep := (cAliasDT6)->DT6_FILDOC <> (cAliasDT6)->DUD_FILORI .And. (cAliasDT6)->DT6_FILDES <> (cAliasDT6)->DUD_FILORI
				cDocCar := ""
				
				If cCarExp == '1'
					cDocCar += Iif(lCarExp,'1','2')
				ElseIf cCarExp == '2'
					cDocCar += '2'
				EndIf
				
				If cCarRec == '1'
					cDocCar += Iif(lCarRec,'1','2')
				ElseIf cCarRec $ '0;2'
					cDocCar += '2'
				EndIf
				
				If cCarRep == '1'
					cDocCar += Iif(lCarRep,'1','2')
					//-- Carga Reprocessada
					If nPerRep > 0 .And. lCarRep
						nPeso   := nPeso   * ( nPerRep / 100 )
						nPesoM3 := nPesoM3 * ( nPerRep / 100 )
					EndIf
				ElseIf cCarRep $ '0;2'
					cDocCar += '2'
				EndIf

				If !Empty(cDocCar) .And. !('1' $ cDocCar)
					(cAliasDT6)->(dbSkip())
					Loop
				EndIf
				
				cInsert		:= " INSERT INTO " + cRealTDOC + " ( TRB_IDCTMS ,  TRB_FILIAL , TRB_CODDES , TRB_FILDOC , TRB_DOC , TRB_SERIE , TRB_SERTMS , "
				cInsert		+= " TRB_TIPTRA ,  TRB_VALMER , TRB_VALFAT , TRB_QTDVOL , TRB_PESO , TRB_PESOM3 , TRB_RATEIO , TRB_CAREXP , TRB_CARREC , TRB_CARREP ) "
				cInsert		+= " VALUES ( "
				cInsert		+= "'" + cIdCTMS + "' , "
				cInsert		+= "'" + cFilCta + "' , "
				cInsert		+= "'" + cCodDes + "' , "
				cInsert		+= "'" + (cAliasDT6)->DT6_FILDOC + "' , "
				cInsert		+= "'" + (cAliasDT6)->DT6_DOC + "' , "
				cInsert		+= "'" + (cAliasDT6)->DT6_SERIE + "' , "
				cInsert		+= "'" + (cAliasDT6)->DT6_SERTMS + "' , "
				cInsert		+= "'" + (cAliasDT6)->DT6_TIPTRA  + "' , "
				cInsert		+= "'" + cValToChar((cAliasDT6)->DT6_VALMER)  + "' , "
				cInsert		+= "'" + cValToChar((cAliasDT6)->DT6_VALFAT) + "' , "
				cInsert		+= "'" + cValToChar((cAliasDT6)->DT6_QTDVOL) + "' , "
				cInsert		+= "'" + cValToChar( nPeso ) + "' , "
				cInsert		+= "'" + cValToChar( nPesoM3 ) + "' , "
				cInsert		+= "'" + cValToChar( cRateio ) + "' , "
				cInsert		+= "'" + Iif(lCarExp,'1','2') + "' , "
				cInsert		+= "'" + Iif(lCarRec,'1','2') + "' , "
				cInsert		+= "'" + Iif(lCarRep,'1','2') + "' "
				cInsert		+= " ) "
				
				TCSqlExec(cInsert)
							
				dbSelectArea(cAliasDT6)
				(cAliasDT6)->(dbSkip())
			EndDo
			(cAliasDT6)->(dbCloseArea())
					
			If cRateio <> '0' //-- Especifico
				cAliasTR1 := GetNextAlias()
				cQuery := "SELECT  TRB_FILIAL, TRB_CODDES, TRB_FILDOC, TRB_DOC   , TRB_SERIE , TRB_SERTMS, TRB_TIPTRA, "
				cQuery += "        TRB_PESO ,  TRB_PESOM3, TRB_VALMER, TRB_VALFAT, TRB_QTDVOL, TRB_RATEIO"
				cQuery += "  FROM "
				cQuery	+= cRealTDOC + " TRB "
				cQuery += " WHERE TRB.TRB_FILIAL = '"+cFilCta+"' "
				cQuery += "   AND TRB.TRB_CODDES = '"+cCodDes+"' "			
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTR1)
				TCSetField(cAliasTR1,"TRB_PESO"  ,"N",TamSx3("DT6_PESO"  )[1],TamSx3("DT6_PESO"  )[2])
				TCSetField(cAliasTR1,"TRB_PESOM3","N",TamSx3("DT6_PESOM3")[1],TamSx3("DT6_PESOM3")[2])
				TCSetField(cAliasTR1,"TRB_VALMER","N",TamSx3("DT6_VALMER")[1],TamSx3("DT6_VALMER")[2])
				TCSetField(cAliasTR1,"TRB_VALFAT","N",TamSx3("DT6_VALFAT")[1],TamSx3("DT6_VALFAT")[2])
				TCSetField(cAliasTR1,"TRB_QTDVOL","N",TamSx3("DT6_QTDVOL")[1],TamSx3("DT6_QTDVOL")[2])
				While (cAliasTR1)->(!Eof())
					nPeso   := (cAliasTR1)->TRB_PESO 
					nPesoM3 := (cAliasTR1)->TRB_PESOM3
					nValMer := (cAliasTR1)->TRB_VALMER
					nValFat := (cAliasTR1)->TRB_VALFAT
					nQtdVol := (cAliasTR1)->TRB_QTDVOL
					
					For nFx := 1 To Len(aFaixas)
						If cRateio == '1' //-- Qtde.Documento
							If cFaixa == '2' //-- Peso
								If nPeso <= aFaixas[nFx,1]
									aFaixas[nFx,3] += 1
								EndIf
							ElseIf cFaixa == '3' //-- Volume
								If nQtdVol <= aFaixas[nFx,1]
									aFaixas[nFx,3] += 1
								EndIf
							ElseIf cFaixa == '4' //-- Valor Mercadoria
								If nValMer <= aFaixas[nFx,1]
									aFaixas[nFx,3] += 1
								EndIf
							ElseIf cFaixa == '5' //-- Peso Cubado
								If nPesoM3 <= aFaixas[nFx,1]
									aFaixas[nFx,3] += 1
								EndIf
							Else
								aFaixas[nFx,3] += 1
							EndIf
						ElseIf cRateio == '2' //-- Peso
							If cFaixa == '2' //-- Peso
								If nPeso <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nPeso
								EndIf
							ElseIf cFaixa == '3' //-- Volume
								If nQtdVol <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nPeso
								EndIf
							ElseIf cFaixa == '4' //-- Valor Mercadoria
								If nValMer <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nPeso
								EndIf
							ElseIf cFaixa == '5' //-- Peso Cubado
								If nPesoM3 <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nPeso
								EndIf
							Else
								aFaixas[nFx,3] += nPeso
							EndIf
						ElseIf cRateio == '3' //-- Volume
							If cFaixa == '2' //-- Peso
								If nPeso <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nQtdVol
								EndIf
							ElseIf cFaixa == '3' //-- Volume
								If nQtdVol <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nQtdVol
								EndIf
							ElseIf cFaixa == '4' //-- Valor Mercadoria
								If nValMer <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nQtdVol
								EndIf
							ElseIf cFaixa == '5' //-- Peso Cubado
								If nPesoM3 <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nQtdVol
								EndIf
							Else
								aFaixas[nFx,3] += nQtdVol
							EndIf
						ElseIf cRateio == '4' //-- Valor mercadoria
							If cFaixa == '2' //-- Peso
								If nPeso <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nValMer
								EndIf
							ElseIf cFaixa == '3' //-- Volume
								If nQtdVol <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nValMer
								EndIf
							ElseIf cFaixa == '4' //-- Valor Mercadoria
								If nValMer <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nValMer
								EndIf
							ElseIf cFaixa == '5' //-- Peso Cubado
								If nPesoM3 <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nValMer
								EndIf
							Else
								aFaixas[nFx,3] += nValMer
							EndIf
						ElseIf cRateio == '5' //-- Peso cubado
							If cFaixa == '2' //-- Peso
								If nPeso <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nPesoM3
								EndIf
							ElseIf cFaixa == '3' //-- Volume
								If nQtdVol <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nPesoM3
								EndIf
							ElseIf cFaixa == '4' //-- Valor Mercadoria
								If nValMer <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nPesoM3
								EndIf
							ElseIf cFaixa == '5' //-- Peso Cubado
								If nPesoM3Ori <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nPesoM3
								EndIf
							Else
								aFaixas[nFx,3] += nPesoM3
							EndIf
						ElseIf cRateio == '6' //-- Faturamento
							If cFaixa == '2' //-- Peso
								If nPeso <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nValFat
								EndIf
							ElseIf cFaixa == '3' //-- Volume
								If nQtdVol <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nValFat
								EndIf
							ElseIf cFaixa == '4' //-- Valor Mercadoria
								If nValMer <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nValFat
								EndIf
							ElseIf cFaixa == '5' //-- Peso Cubado
								If nPesoM3 <= aFaixas[nFx,1]
									aFaixas[nFx,3] += nValFat
								EndIf
							Else
								aFaixas[nFx,3] += nValFat
							EndIf
						ElseIf cRateio == '7' //-- % Despesas x Receita
							If nValFat <= aFaixas[nFx,1]
								aFaixas[nFx,3] += nValFat
							EndIf
						EndIf
					Next nFx
				
					(cAliasTR1)->(dbSkip())
				EndDo
				(cAliasTR1)->(dbCloseArea())
			Else
				If lTMA99RAT
					aFaixas := ExecBlock( 'TMA99RAT', .F., .F., { cAliasTR1, aFaixas, cCodDes } )
				EndIf
			EndIf
			DbSelectArea(cAliasQry)
			While (cAliasQry)->(!Eof()) .And. (cAliasQry)->(DF9_FILIAL+DF9_CODDES+DF9_RATEIO) == cFilCta+cCodDes+cRateio .And. (cAliasQry)->DFA_FILIAL == cFilAnt
				cConta  := (cAliasQry)->DFA_CONTA  //--Conta De
				cContA2 := IIf(Empty((cAliasQry)->DFA_CONTA2),(cAliasQry)->DFA_CONTA,(cAliasQry)->DFA_CONTA2) //--Conta Ate
				nCtSMov := 0
				If (cAliasQry)->DFA_TPITEM == '1' //-- Conta Contabil
					cItemCT  := (cAliasQry)->DFA_ITEMCT
					cItemCT2 := IIf(Empty((cAliasQry)->DFA_ITECT2),(cAliasQry)->DFA_ITEMCT,(cAliasQry)->DFA_ITECT2)
					cClasCL  := (cAliasQry)->DFA_CLVL
					cClasCL2 := IIf(Empty((cAliasQry)->DFA_CLVL2),(cAliasQry)->DFA_CLVL,(cAliasQry)->DFA_CLVL2)
					cCtDe    := (cAliasQry)->DFA_CC
					cCtAte   := (cAliasQry)->DFA_CC2
					
					//--O 5o parametro da CTSMMOV precisa ser 3, para trazer o Movimento da Conta Contabil, nao deve ser o Saldo
					nCtSMov  := CTSMMOV(dDatIni,dDatFim,"01","1",3 ,cConta,cConta2,cCtDe,cCtAte,cItemCT,cItemCT2,cClasCL,cClasCL2)					
					//--precisamos inverter o sinal
					nCtSMov := (nCtSMov * -1)
					
				ElseIf (cAliasQry)->DFA_TPITEM == '2' //-- Conta Especifica
					DFW->(dbSetOrder(1))
					If DFW->(dbSeek(xFilial('DFW')+cConta))
						cAuxDoc := DFW->DFW_DOCCUS
						If AT("*",cAuxDoc) > 0
							aDocTms:= TMSValField('DOCTMS',.F.,,.F.,.T.)
							cAuxDoc:= ''
							For nI := 1 To Len(aDocTms)
								If !Empty(cAuxDoc)
									cAuxDoc += ';'
								EndIf
								cAuxDoc += aDocTms[nI,1]
							Next nI
						EndIf     
						cDocEsp := ''
						While AT(";",cAuxDoc) > 0
							cDocEsp += "'"+Subs(cAuxDoc,1,AT(";",cAuxDoc)-1)
							cAuxDoc := Stuff(cAuxDoc,AT(";",cAuxDoc)-1,2, '')
							If !Empty(cDocEsp)
								cDocEsp += "',"
							EndIf
						EndDo
						If !Empty(cAuxDoc)
							cDocEsp += "'"+Alltrim(cAuxDoc)
						EndIf
						If !Empty(cDocEsp)
							cDocEsp += "'"
						EndIf
						If DFW->DFW_TIPOCT == '1' //-- Faturamento
							cQuery := "SELECT SUM(DT6_VALFAT) DT6_VALFAT FROM ( "
							cQuery += "SELECT DFN_FILDOC, DFN_DOC, DFN_SERIE "
							cQuery += "  FROM "
							cQuery += RetSqlName("DFN")+" DFN "
							cQuery += " WHERE DFN.DFN_FILIAL = '"+xFilial("DFN")+"'"
							cQuery += "   AND DFN.DFN_IDCTMS = '"+cIdCTMS+"'"
							cQuery += "   AND DFN.DFN_FILDOC = '"+cFilCta+"'"
							cQuery += "   AND DFN.D_E_L_E_T_ = ' '"
							cQuery += " GROUP BY DFN_FILDOC, DFN_DOC, DFN_SERIE) QRYDFN, "
							cQuery += RetSqlName("DT6")+" DT6  "
							cQuery += " WHERE DT6.DT6_FILIAL = '"+xFilial("DT6")+"'"
							cQuery += "   AND DT6.DT6_FILDOC = DFN_FILDOC"
							cQuery += "   AND DT6.DT6_DOC    = DFN_DOC   "
							cQuery += "   AND DT6.DT6_SERIE  = DFN_SERIE "
							cQuery += "   AND DT6.DT6_DOCTMS IN ( "+cDocEsp+" )"
							cQuery += "   AND DT6.D_E_L_E_T_ = ' '"
							cQuery := ChangeQuery(cQuery)
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasEsp)
							TCSetField(cAliasEsp,"DT6_VALFAT","N",TamSx3("DT6_VALFAT")[1],TamSx3("DT6_VALFAT")[2])
							If (cAliasEsp)->(!Eof())
								nCtSMov := (cAliasEsp)->DT6_VALFAT
							EndIf
							(cAliasEsp)->(dbCloseArea())
						ElseIf DFW->DFW_TIPOCT == '2' //-- Custo
							cQuery := "SELECT SUM(DFN_CUSTO1) DFN_CUSTO1"
							cQuery += "  FROM "
							cQuery += RetSqlName('DFN')+" DFN, "
							cQuery += RetSqlName("DT6")+" DT6  "
							cQuery += " WHERE DFN.DFN_FILIAL = '"+xFilial('DFN')+"'"
							cQuery += "   AND DFN.DFN_IDCTMS = '"+cIdCTMS+"'"
							cQuery += "   AND DFN.DFN_FILDOC = '"+cFilCta+"'"
							cQuery += "   AND DFN.D_E_L_E_T_ = ' '"
							cQuery += "   AND DT6.DT6_FILDOC = DFN_FILDOC"
							cQuery += "   AND DT6.DT6_DOC    = DFN_DOC"
							cQuery += "   AND DT6.DT6_SERIE  = DFN_SERIE"
							cQuery += "   AND DT6.DT6_DOCTMS IN ( "+cDocEsp+" )"
							cQuery += "   AND DT6.D_E_L_E_T_ = ' '"
							cQuery := ChangeQuery(cQuery)
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasEsp)
							TCSetField(cAliasEsp,"DFN_CUSTO1","N",TamSx3("DFN_CUSTO1")[1],TamSx3("DFN_CUSTO1")[2])
							If (cAliasEsp)->(!Eof())
								nCtSMov := (cAliasEsp)->DFN_CUSTO1
							EndIf
							(cAliasEsp)->(dbCloseArea())
						EndIf
					EndIf
				EndIf
				If (cAliasQry)->DFA_PERCCT > 0
					nCtSMov := nCtSMov * ((cAliasQry)->DFA_PERCCT / 100)
				EndIf
				If cRateio == '7' //-- % Despesas x Receitas
					If (cAliasQry)->DFA_IDENCT == '1' //-- Receita (+)
						nCCSaldo += nCtSMov
					ElseIf (cAliasQry)->DFA_IDENCT == '2' //-- Receita (-)
						nCCSaldo -= nCtSMov
					ElseIf (cAliasQry)->DFA_IDENCT == '3' //-- Despesa (+)
						nCCDesp  += nCtSMov
					ElseIf (cAliasQry)->DFA_IDENCT == '4' //-- Despesa (-)
						nCCDesp  -= nCtSMov
					EndIf
				Else
					nCCSaldo += nCtSMov
				EndIf
				If (cAliasQry)->DFA_DEDSLM == '1' //-- Deduz salario do motorista
					For nI := 1 To Len(aMotVge)
						nCCSaldo -= aMotVge[nI,MO_CUSTO]
					Next nI
					For nI := 1 To Len(aMotSVg)
						nCCSaldo -= aMotSVg[nI,MS_CUSTO]
					Next nI
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo  
			//-- Restaura a Filial original após o processamento
			cFilAnt := cFilBkp
			
			nTFaixa := 0
			Aeval(aFaixas,{ | e | nTFaixa += e[3] })
			If cRateio == '7' //-- % Despesas x Receita
				nVFaixa := (nCCDesp / nCCSaldo) * 100
			Else
				nVFaixa:= nCCSaldo / nTFaixa
			EndIf
			For nI := 1 To Len(aFaixas)
				//-- Realiza rateio
				If aFaixas[nI,2]
					aFaixas[nI,4] := aFaixas[nI,3] * nVFaixa
				Else
					aFaixas[nI,4] := nVFaixa
				EndIf  

				cInsert		:= " INSERT INTO " + cRealTFAI  + " ( TRB_IDCTMS , TRB_FILIAL , TRB_CODDES , TRB_VALATE , TRB_REARAT , TRB_VALACU , TRB_TOTGER , TRB_RATEIO ) "
				cInsert		+= " VALUES ( "
				cInsert		+= "'" + cIdCTMS + "',"
				cInsert		+= "'" + Iif(Empty(cFilCta),cFilAnt,cFilCta)   + "',"
				cInsert		+= "'" + cCodDes + "',"
				cInsert		+= "'" + cValToChar( aFaixas[nI,1] )+ "',"
				cInsert		+= "'" + Iif(aFaixas[nI,2],'S','N') + "',"
				cInsert		+= "'" + cValToChar( aFaixas[nI,3] ) + "',"
				cInsert		+= "'" + cValToChar( aFaixas[nI,4] ) + "',"
				cInsert		+= "'" + cRateio + "' "
				cInsert		+= " ) "

				TCSqlExec(cInsert)

				DbSelectArea(cAliasQry)
			Next nI            
			
			cInsert	:= " INSERT INTO " + cRealTSAL + " ( TRB_IDCTMS, TRB_FILIAL , TRB_CODDES , TRB_NSALDO , TRB_NDESP , TRB_RATEIO  ) "
			cInsert	+= " VALUES ( "
			cInsert	+= "'" + cIdCTMS + "',"
			cInsert	+= "'" + Iif(Empty(cFilCta),cFilAnt,cFilCta) + "',"
			cInsert	+= "'" + cCodDes + "',"
			cInsert	+= "'" + cValToChar(nCCSaldo) + "',"
			cInsert	+= "'" + cValToChar(nCCDesp) + "',"
			cInsert	+= "'" + cRateio + "'"
			cInsert	+= " ) " 

			TCSqlExec(cInsert)
			
			DbSelectArea(cAliasQry)
			
			cAliasTR1 := GetNextAlias()
			cAliasTR2 := GetNextAlias()
			cAliasTR3 := GetNextAlias()
			
			cQuery := "SELECT TRB_FILIAL, TRB_CODDES, TRB_NSALDO, TRB_NDESP , TRB_RATEIO  "
			cQuery += "  FROM "
			cQuery += cRealTSAL + " TRB "
			cQuery += " WHERE TRB.TRB_FILIAL = '" + Iif(Empty(cFilCta),cFilAnt,cFilCta) + "' "
			cQuery += "   AND TRB.TRB_CODDES = '" + cCodDes + "' "			
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTR1)
			TCSetField(cAliasTR1,"TRB_NSALDO","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2])
			TCSetField(cAliasTR1,"TRB_NDESP" ,"N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2])

			While (cAliasTR1)->(!Eof())

				cFilCta := (cAliasTR1)->TRB_FILIAL				
				cCodDes := (cAliasTR1)->TRB_CODDES
				aFaixas := {}

				cQuery  := "SELECT TRB_FILIAL, TRB_CODDES, TRB_VALATE, TRB_REARAT, TRB_VALACU, TRB_TOTGER "
				cQuery  += "  FROM "
				cQuery += cRealTFAI + " TRB "
				cQuery  += " WHERE TRB.TRB_FILIAL = '"+cFilCta+"' "
				cQuery  += "   AND TRB.TRB_CODDES = '"+cCodDes+"' "			
				cQuery  := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTR2)
				TCSetField(cAliasTR2,"TRB_VALATE","N",TamSx3("DFB_VALATE")[1],TamSx3("DFB_VALATE")[2])
				TCSetField(cAliasTR2,"TRB_VALACU","N",TamSx3("DFN_CUSTO1")[1],TamSx3("DFN_CUSTO1")[2])
				TCSetField(cAliasTR2,"TRB_TOTGER","N",TamSx3("DFN_CUSTO1")[1],TamSx3("DFN_CUSTO1")[2])				
				While (cAliasTR2)->(!Eof())
					Aadd(aFaixas,{ (cAliasTR2)->TRB_VALATE, ((cAliasTR2)->TRB_REARAT == 'S'), (cAliasTR2)->TRB_VALACU, (cAliasTR2)->TRB_TOTGER })					
					(cAliasTR2)->(DbSkip())	           
				Enddo
				(cAliasTR2)->(DbCloseArea())   				
				DbSelectArea(cAliasTR1)		  
				
				cQuery := "SELECT TRB_FILIAL, TRB_CODDES, TRB_FILDOC, TRB_DOC   , TRB_SERIE , TRB_SERTMS, TRB_TIPTRA, "
				cQuery += "       TRB_PESO  , TRB_PESOM3, TRB_VALMER, TRB_VALFAT, TRB_QTDVOL, TRB_RATEIO"
				cQuery += "  FROM "
				cQuery	+= cRealTDOC + " TRB "
				cQuery += " WHERE TRB.TRB_FILIAL = '"+cFilCta+"' "
				cQuery += "   AND TRB.TRB_CODDES = '"+cCodDes+"' "			
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTR3)
				TCSetField(cAliasTR3,"TRB_PESO"  ,"N",TamSx3("DT6_PESO"  )[1],TamSx3("DT6_PESO"  )[2])
				TCSetField(cAliasTR3,"TRB_PESOM3","N",TamSx3("DT6_PESOM3")[1],TamSx3("DT6_PESOM3")[2])
				TCSetField(cAliasTR3,"TRB_VALMER","N",TamSx3("DT6_VALMER")[1],TamSx3("DT6_VALMER")[2])
				TCSetField(cAliasTR3,"TRB_VALFAT","N",TamSx3("DT6_VALFAT")[1],TamSx3("DT6_VALFAT")[2])
				TCSetField(cAliasTR3,"TRB_QTDVOL","N",TamSx3("DT6_QTDVOL")[1],TamSx3("DT6_QTDVOL")[2])
				While (cAliasTR3)->(!Eof())
				nVCusto := 0
					cFilDoc := (cAliasTR3)->TRB_FILDOC
					cDoc    := (cAliasTR3)->TRB_DOC
					cSerie  := (cAliasTR3)->TRB_SERIE
					cSerTms := (cAliasTR3)->TRB_SERTMS
					cTipTra := (cAliasTR3)->TRB_TIPTRA
					nPeso   := (cAliasTR3)->TRB_PESO 
					nPesoM3 := (cAliasTR3)->TRB_PESOM3 
					nValMer := (cAliasTR3)->TRB_VALMER
					nValFat := (cAliasTR3)->TRB_VALFAT
					nQtdVol := (cAliasTR3)->TRB_QTDVOL
					For nFx := 1 To Len(aFaixas)
						//-- Realiza rateio
						If aFaixas[nFx,2]
							If cFaixa == '1' //-- Qtde. de documento
								nVCusto := (aFaixas[nFx,4] / aFaixas[nFx,3])
								Exit
							ElseIf cFaixa == '2' //-- Peso
								If nPeso   <= aFaixas[nFx,1]
									nVCusto := nPeso   * (aFaixas[nFx,4] / aFaixas[nFx,3])
									Exit
								EndIf
							ElseIf cFaixa == '3' //-- Volume
								If nQtdVol <= aFaixas[nFx,1]
									nVCusto := nQtdVol * (aFaixas[nFx,4] / aFaixas[nFx,3])
									Exit
								EndIf
							ElseIf cFaixa == '4' //-- Valor Mercadoria
								If nValMer <= aFaixas[nFx,1]
									nVCusto := nValMer * (aFaixas[nFx,4] / aFaixas[nFx,3])
									Exit
								EndIf
							ElseIf cFaixa == '5' //-- Peso Cubado
								If nPesoM3 <= aFaixas[nFx,1]
									nVCusto := nPesoM3 * (aFaixas[nFx,4] / aFaixas[nFx,3])
									Exit
								EndIf
							EndIf
						Else
							If cRateio == '1' //-- Qtde. de documento
								nVCusto := aFaixas[nFx,4]
								Exit
							ElseIf cRateio == '2' //-- Peso
								nVCusto := nPeso * aFaixas[nFx,4]
								Exit
							ElseIf cRateio == '3' //-- Volume
								nVCusto := nQtdVol * aFaixas[nFx,4]
								Exit
							ElseIf cRateio == '4' //-- Valor mercadoria
								nVCusto := nValMer * aFaixas[nFx,4]
								Exit
							ElseIf cRateio == '5' //-- Peso cubado
								nVCusto := nPesoM3 * aFaixas[nFx,4]
								Exit
							ElseIf cRateio == '6' //-- Faturamento
								nVCusto := nValFat * aFaixas[nFx,4]
								Exit
							ElseIf cRateio == '7' //-- % Despesas x Receita
								nVCusto := nValFat * (aFaixas[nFx,4] / 100)
								Exit
							EndIf
						EndIf
					Next nFx

					DFN->(dbSetOrder(1))
					If DFN->(!dbSeek(xFilial('DFN')+cIdCTMS+cFilDoc+cDoc+cSerie+cSerTms+cTipTra+cCodDes+cFilCta))
						RecLock('DFN',.T.)
						DFN->DFN_FILIAL := xFilial('DFN')
						DFN->DFN_IDCTMS := cIdCTMS
						DFN->DFN_FILDOC := cFilDoc
						DFN->DFN_DOC    := cDoc
						DFN->DFN_SERIE  := cSerie
						DFN->DFN_SERTMS := cSerTms
						DFN->DFN_TIPTRA := cTipTra
						DFN->DFN_CODDES := cCodDes
						DFN->DFN_FILCUS := cFilCta
					Else
						RecLock('DFN',.F.)
					EndIf
					DFN->DFN_CUSTO1 += nVCusto
					DFN->DFN_CUSTO2 += If(aCotacao[2]>0,nVCusto/aCotacao[2],0)
					DFN->DFN_CUSTO3 += If(aCotacao[3]>0,nVCusto/aCotacao[3],0)
					DFN->DFN_CUSTO4 += If(aCotacao[4]>0,nVCusto/aCotacao[4],0)
					DFN->DFN_CUSTO5 += If(aCotacao[5]>0,nVCusto/aCotacao[5],0)
					MsUnLock()
					dbCommit()

					(cAliasTR3)->(DbSkip())						    
				EndDo			
				(cAliasTR3)->(DbCloseArea())

				DbSelectArea(cAliasTR1)		
				(cAliasTR1)->(DbSkip())			
			EndDo
			(cAliasTR1)->(DbCloseArea())
			If aCont[2] //Exclusao devido a continuacao
				TMSAF99Con(StrZero(14,Len(DFJ->DFJ_INIPRO)),.T.,cIdCTMS,.T.,nDF9RECNO)	         
			EndIf
		EndDo 
		(cAliasQry)->(dbCloseArea())
		DbSelectArea(cAliasDFJ)
	Next nX	  
	
	//-- Apaga dados de Temporarios 
	oTempTDOC:Delete()
	oTempTFAI:Delete()
	oTempTSAL:Delete()
	
	aFaixas := {} //-- Limpa Variavel
	
	Aadd(aLogTmp,{ '14o.' + STR0023 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo finalizado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	TMSAF99Con(StrZero(14,Len(DFJ->DFJ_INIPRO)),.T.)
EndIf

aCont := TMSAF99Con(StrZero(15,Len(DFJ->DFJ_INIPRO)))

oSelf:IncRegua2( OemToAnsi( "15-" + STR0037 ) )

If aCont[1]
	//-- Custo Seguros.
	IncProc("15-" + STR0037 ) //-- Rateio de Despesas por Custo Seguro processado
	Aadd(aLogTmp,{ '15o.' + STR0022 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo iniciado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	
	If aCont[2] //Exclusao devido a continuacao
		TMSAF99SDG('',cMvDesSeg,,cIdCTMS,dDatFim,StrZero(16,Len(DFJ->DFJ_INIPRO)))
	EndIf
	
	//-- Seleciona todos os documentos deste codseg e aplica este percetual de item a item.
	cQuery := " SELECT DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_SERTMS, DT6_TIPTRA, SUM(DU7.DU7_PREMIO) DU7_PREMIO "
	cQuery += "   FROM "
	cQuery += RetSqlName("DT6") + " DT6, "
	cQuery += RetSqlName("DU7") + " DU7  "
	cQuery += "  WHERE DT6.DT6_FILIAL  = '" + xFilial( "DT6" ) + "'"
	cQuery += "    AND DT6.DT6_DATEMI BETWEEN '" + dTos(dDatIni) + "' AND '" + dTos(dDatFim) + "'"
	cQuery += "    AND DT6.DT6_SERTMS IN ( '2', '3' )" 
	cQuery += "    AND DT6_DOCSEG 	 <> ' ' " 
	cQuery += "    AND DT6.D_E_L_E_T_  = ' ' " 
	cQuery += "    AND DU7.DU7_FILIAL  = '" + xFilial( "DU7" ) + "'"
	cQuery += "    AND DU7.DU7_FILDOC  = DT6_FILDOC"
	cQuery += "    AND DU7.DU7_DOC     = DT6_DOC   "
	cQuery += "    AND DU7.DU7_SERIE   = DT6_SERIE "
	cQuery += "    AND DT6.D_E_L_E_T_  = ' '" 
	cQuery += "    AND DU7.D_E_L_E_T_  = ' '"
	cQuery += "  GROUP BY DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_SERTMS, DT6_TIPTRA "
	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	TcSetField(cAliasQry,"DU7_PREMIO","N",TamSX3('DU7_PREMIO')[1],TamSX3('DU7_PREMIO')[2])
	DFN->(dbSetOrder(1))
	While (cAliasQry)->(!Eof())
		nValRt1 := (cAliasQry)->DU7_PREMIO
		If DFN->(!dbSeek(xFilial('DFN')+cIdCTMS+(cAliasQry)->(DT6_FILDOC+DT6_DOC+DT6_SERIE+DT6_SERTMS+DT6_TIPTRA+cMvDesSeg+DT6_FILDOC))) 
			RecLock('DFN',.T.)
			DFN->DFN_FILIAL := xFilial('DFN')
			DFN->DFN_IDCTMS := cIdCTMS
			DFN->DFN_FILDOC := (cAliasQry)->DT6_FILDOC
			DFN->DFN_DOC    := (cAliasQry)->DT6_DOC
			DFN->DFN_SERIE  := (cAliasQry)->DT6_SERIE
			DFN->DFN_SERTMS := (cAliasQry)->DT6_SERTMS
			DFN->DFN_TIPTRA := (cAliasQry)->DT6_TIPTRA
			DFN->DFN_CODDES := cMvDesSeg
			DFN->DFN_FILCUS := (cAliasQry)->DT6_FILDOC
		Else
			RecLock('DFN',.F.)
		EndIf
		DFN->DFN_CUSTO1 += nValRt1
		DFN->DFN_CUSTO2 += If( aCotacao[2] > 0, nValRt1 / aCotacao[2], 0 )
		DFN->DFN_CUSTO3 += If( aCotacao[3] > 0, nValRt1 / aCotacao[3], 0 )
		DFN->DFN_CUSTO4 += If( aCotacao[4] > 0, nValRt1 / aCotacao[4], 0 )
		DFN->DFN_CUSTO5 += If( aCotacao[5] > 0, nValRt1 / aCotacao[5], 0 )					
		MsUnLock()
		dbCommit()
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea()) 
	dbSelectArea(cAliasDFJ)	
	Aadd(aLogTmp,{ '15o.' + STR0023 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo finalizado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	TMSAF99Con(StrZero(15,Len(DFJ->DFJ_INIPRO)),.T.)
EndIf

//-------------------------------------------------APURACÃO CUSTO DOS DOCUMENTOS PAGOS NO GFE------------------------------------------------------------
If aCont[1] .And. SDG->(ColumnPos('DG_FILFRT')) > 0 .And. ( cIntCusGfe == "1" .Or. cIntCusGfe == "2" ) 

	//-- Apura custo dos documentos pagos no GFE
	IncProc("16-" + STR0054 ) //-- Apuracao de Custos dos Documentos pagos no GFE
	Aadd(aLogTmp,{ '16o.' + STR0022 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo iniciado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	
	If aCont[2] //Exclusao devido a continuacao
		TMSAF99SDG('',,,cIdCTMS,dDatFim,StrZero(16,Len(DFJ->DFJ_INIPRO)))
	EndIf
	
	aFilSDG:= {}
	cQuery := "SELECT SDG.DG_FILIAL FROM "+RetSqlName('SDG')+" SDG WHERE SDG.DG_VIAGEM = ' ' AND SDG.D_E_L_E_T_ = ' ' GROUP BY DG_FILIAL ORDER BY DG_FILIAL"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	While (cAliasQry)->(!Eof())
	Aadd(aFilSDG,(cAliasQry)->DG_FILIAL)
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())             	
	If Empty(aFilSDG)
		Aadd(aFilSDG,cFilAnt)
	EndIf		
	For nX := 1 To Len(aFilSDG)  
		//-- Apura custo dos documentos sem viagem - SDG gerados pelo GFE	
		cQuery := "SELECT DG_FILORI, DG_DOC, DG_CODDES, DG_FILFRT, DG_DOCFRT, DG_SERFRT, SUM(DG_CUSTO1) DG_CUSTO1, SUM(DG_CUSTO2) DG_CUSTO2, "
		cQuery += "  SUM(DG_CUSTO3) DG_CUSTO3, SUM(DG_CUSTO4) DG_CUSTO4, SUM(DG_CUSTO5) DG_CUSTO5"
		cQuery += "  FROM "
		cQuery += RetSqlName('SDG')+" SDG "
		cQuery += " JOIN "+RetSqlName('DT6')+" DT6 " 
		cQuery += "    ON DT6.DT6_FILIAL  = '"+xFilial('DT6')+"'"
		cQuery += "   AND DT6.DT6_FILDOC  = SDG.DG_FILFRT"
		cQuery += "   AND DT6.DT6_DOC	  = SDG.DG_DOCFRT "          
		cQuery += "   AND DT6.DT6_SERIE   = SDG.DG_SERFRT "          
		cQuery += "   AND DT6.D_E_L_E_T_  = ' '"          	
		cQuery += " WHERE SDG.DG_FILIAL   = '"+Iif(Empty(xFilial('SDG')),xFilial('SDG'),aFilSDG[nX])+"'"
		cQuery += "   AND SDG.DG_EMISSAO  BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFim)+"'"
		cQuery += "   AND SDG.DG_VIAGEM   = ' '"
		cQuery += "   AND SDG.DG_STATUS   = '3'"          
		cQuery += "   AND SDG.D_E_L_E_T_  = ' '" 		
		cQuery += " GROUP BY DG_FILORI, DG_DOC, DG_CODDES, DG_FILFRT, DG_DOCFRT, DG_SERFRT"
		cQuery += " ORDER BY DG_FILORI, DG_DOC" 
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		TCSetField(cAliasQry,"DG_CUSTO1","N",TamSx3("DG_CUSTO1")[1],TamSx3("DG_CUSTO1")[2])
		TCSetField(cAliasQry,"DG_CUSTO2","N",TamSx3("DG_CUSTO2")[1],TamSx3("DG_CUSTO2")[2])
		TCSetField(cAliasQry,"DG_CUSTO3","N",TamSx3("DG_CUSTO3")[1],TamSx3("DG_CUSTO3")[2])
		TCSetField(cAliasQry,"DG_CUSTO4","N",TamSx3("DG_CUSTO4")[1],TamSx3("DG_CUSTO4")[2])
		TCSetField(cAliasQry,"DG_CUSTO5","N",TamSx3("DG_CUSTO5")[1],TamSx3("DG_CUSTO5")[2])
		While (cAliasQry)->(!Eof())
			nCusto1 := (cAliasQry)->DG_CUSTO1
			nCusto2 := (cAliasQry)->DG_CUSTO2
			nCusto3 := (cAliasQry)->DG_CUSTO3
			nCusto4 := (cAliasQry)->DG_CUSTO4
			nCusto5 := (cAliasQry)->DG_CUSTO5                                                              
			If nCusto1 > 0 .Or. nCusto2 > 0 .Or. nCusto3 > 0 .Or. nCusto4 > 0 .Or. nCusto5 > 0 
				DT6->(dbSetOrder(1)) //--Filial+Fil.Doc+Num.Doc+Serie Doc
				If DT6->(dbSeek(xFilial("DT6") + (cAliasQry)->(DG_FILFRT+DG_DOCFRT+DG_SERFRT)))
					cSerTMS := DT6->DT6_SERTMS
					cTipTra := DT6->DT6_TIPTRA
				EndIf
				
				DFN->(dbSetOrder(5)) //--ID.Custo TMS+Fil.Docto.+No.Docto.+Serie Docto.+Cod.Despesa
				If DFN->(!dbSeek(xFilial('DFN')+cIdCTMS+(cAliasQry)->(DG_FILFRT+DG_DOCFRT+DG_SERFRT+DG_CODDES)))
					RecLock('DFN',.T.)
					DFN->DFN_FILIAL := xFilial('DFN')
					DFN->DFN_IDCTMS := cIdCTMS
					DFN->DFN_FILDOC := (cAliasQry)->DG_FILFRT
					DFN->DFN_DOC    := (cAliasQry)->DG_DOCFRT
					DFN->DFN_SERIE  := (cAliasQry)->DG_SERFRT
					DFN->DFN_SERTMS := cSerTMS
					DFN->DFN_TIPTRA := cTipTra
					DFN->DFN_CODDES := (cAliasQry)->DG_CODDES
				Else
					RecLock('DFN',.F.)
				EndIf			
				DFN->DFN_CUSTO1 += (cAliasQry)->DG_CUSTO1
				DFN->DFN_CUSTO2 += (cAliasQry)->DG_CUSTO2
				DFN->DFN_CUSTO3 += (cAliasQry)->DG_CUSTO3
				DFN->DFN_CUSTO4 += (cAliasQry)->DG_CUSTO4
				DFN->DFN_CUSTO5 += (cAliasQry)->DG_CUSTO5
				MsUnLock()
				dbCommit()
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())     
	DbSelectArea(cAliasDFJ)	
	Next
	Aadd(aLogTmp,{ '16o.' + STR0023 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- Processo finalizado em + Hora
	oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])
	TMSAF99Con(StrZero(16,Len(DFJ->DFJ_INIPRO)),.T.)
EndIf	


DbSelectArea(cAliasDFJ)

oSelf:IncRegua1( STR0038 + Dtoc( Date() ) + STR0020 + Left( Time(), 5 ) ) //-- 'Processo FINALIZADO em ' + ' Hora'

Aadd(aLogTmp,{ STR0038 + Dtoc(Date()) + STR0020 + Left(Time(),5), '00', '' }) //-- 'Processo FINALIZADO em ' + ' Hora'
oSelf:SaveLog(aLogTmp[Len(aLogTmp)][1])

//-- Limpa Variavel
aQtdVei := {}
aQtdVge := {}

//-- Atualiza DFJ
dDtFimPrc := Date()
cHrFimPrc := Left(Time(),5)
nTempoPrc := A680Tempo(dDtIniPrc, cHrIniPrc, dDtFimPrc, cHrFimPrc)

DFJ->(dbSetOrder(1))
If DFJ->(dbSeek(xFilial('DFJ')+cIdCTMS))
	RecLock('DFJ',.F.)
	If nTempoPrc > 0
		DFJ->DFJ_TMPCAL := StrTran(IntToHora(nTempoPrc),':','')
	EndIf
	DFJ->DFJ_STATUS := '2' //-- Processado
	MsUnLock()
	dbCommit()
EndIf

If Len(aMsgErr) > 0
	TmsMsgErr( aMsgErr )
EndIf

//--Exibe os horarios do processo, para tratamento de performance
If Len(aLogTmp) > 0
	TmsMsgErr( aLogTmp )
EndIf

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF99Del³ Autor ³ Richard Anderson      ³ Data ³ 26/Jun/07 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Estorno do processamento do cálculo                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF99Del()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAF99                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSAF99Del( oSelf )

Local nX        := 0
Local aAreaDFJ  := DFJ->(GetArea())
Local aAreaDTQ  := DTQ->(GetArea())
Local aAreaDFF  := DFF->(GetArea())
Local aAreaDFM  := DFM->(GetArea())
Local aAreaDT6  := DT6->(GetArea())
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
//-- Depreciacao de veiculos
Local cAliasDFH := GetNextAlias()
Local aStruDFH  := DFH->(dbStruct())
Local cIdCtms   := DFJ->DFJ_IDCTMS
Local aFiliFSM0 := {}

oSelf:SetRegua1( 2 )
oSelf:SetRegua2( 7 )

oSelf:IncRegua1( STR0019 + Dtoc( Date() ) + STR0020 + Left( Time(), 5 ) ) //-- Processo INICIADO em
oSelf:SaveLog(   STR0019 + Dtoc( Date() ) + STR0020 + Left( Time(), 5 ) ) //-- Processo INICIADO em

Begin Transaction

//-- Cancelamento amortização de despesas
oSelf:IncRegua2( OemToAnsi( "1-" + STR0039 ) ) //-- Cancelamento de Amortizacao de Despesas
oSelf:SaveLog(   OemToAnsi( "1-" + STR0039 ) ) //-- Cancelamento de Amortizacao de Despesas

cQuery := "UPDATE " + retSqlName("DFE") + CRLF
cQuery += " SET DFE_VLRAMZ = (DFE_VLRAMZ-" + CRLF
cQuery += " (SELECT DFF_VLRAMZ" + CRLF
cQuery += " FROM " + retSqlName("DFF") + CRLF
cQuery += " WHERE 1=1" + CRLF
cQuery += " AND DFF_FILIAL = DFE_FILIAL" + CRLF
cQuery += " AND DFF_NUMAMZ = DFE_NUMAMZ" + CRLF
cQuery += " AND DFF_IDCTMS = '" + cIdCtms + "' AND D_E_L_E_T_ <> '*'" + CRLF
cQuery += " ) )," + CRLF
cQuery += " DFE_STATUS = '1'" + CRLF
cQuery += " WHERE 1=1" + CRLF
cQuery += " AND DFE_FILIAL = '" + xFilial("DFE") + "'" + CRLF
cQuery += " AND DFE_IDCTMS = ' '" + CRLF
cQuery += " AND D_E_L_E_T_ <> '*'" + CRLF
cQuery += " AND DFE_NUMAMZ IN" + CRLF
cQuery += " ( SELECT DFF_NUMAMZ" + CRLF
cQuery += " FROM " + retSqlTab("DFF") + CRLF
cQuery += " WHERE 1=1" + CRLF
cQuery += " AND DFF.DFF_FILIAL = DFE_FILIAL" + CRLF
cQuery += " AND DFF.DFF_IDCTMS = '" + cIdCtms + "' AND DFF.D_E_L_E_T_ <> '*'" + CRLF
cQuery += ")" + CRLF

If TCSqlExec( cQuery ) <> 0
	Help('',1,'TMSAF9907',,'DFE',04,01) //-- Erro ao Excluir Registro da Tabela:
EndIf

TCRefresh(RetSqlName('DFE'))
//-- IncProc("1-" + STR0039 )
cQuery := "UPDATE " + RetSqlName('DFF')
cQuery += "   SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
cQuery += " WHERE DFF_FILIAL = '" + xFilial( 'DFF' ) + "' "
cQuery += "   AND DFF_IDCTMS = '" + cIdCtms + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
If TCSqlExec( cQuery ) <> 0
	Help('',1,'TMSAF9907',,'DFF',04,01) //-- Erro ao Excluir Registro da Tabela:
EndIf
TCRefresh(RetSqlName('DFF'))

//-- Depreciação de veículos
oSelf:IncRegua2( OemToAnsi( "2-" + STR0040 ) ) //-- Cancelando Depreciacao de Veiculos
oSelf:SaveLog(   OemToAnsi( "2-" + STR0040 ) ) //-- Cancelando Depreciacao de Veiculos

//-- IncProc("2-" + STR0040 ) //-- Cancelando Depreciacao de Veiculos
cQuery := "SELECT DFH.*, DFH.R_E_C_N_O_ DFHRECNO FROM "
cQuery += RetSqlName('DFH')+" DFH "
cQuery += " WHERE  DFH.DFH_FILIAL = '" + xFilial( 'DFH' ) + "'"
cQuery += "   AND (DFH.DFH_STATUS = '1'"
cQuery += "    OR  DFH.DFH_FIMDEP = '" + Dtos( DFJ->DFJ_DATFIM ) + "')"
cQuery += "   AND  DFH.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDFH)
For nX := 1 To Len(aStruDFH)
	If aStruDFH[nX][2]<>"C"
		TcSetField(cAliasDFH,aStruDFH[nX][1],aStruDFH[nX][2],aStruDFH[nX][3],aStruDFH[nX][4])
	EndIf
Next nX
While (cAliasDFH)->(!Eof())
	//-- Atualiza depreciacao
	DFH->(dbGoTo((cAliasDFH)->DFHRECNO))
	RecLock('DFH',.F.)
	If DFH->DFH_VDACU1 > 0
		DFH->DFH_VDACU1 := DFH->DFH_VDACU1 - DFH->DFH_VDMES1
		DFH->DFH_VDMES1 := 0
	EndIf			
	If DFH->DFH_VDACU2 > 0
		DFH->DFH_VDACU2 := DFH->DFH_VDACU2 - DFH->DFH_VDMES2
		DFH->DFH_VDMES2 := 0
	EndIf			
	If DFH->DFH_VDACU3 > 0
		DFH->DFH_VDACU3 := DFH->DFH_VDACU3 - DFH->DFH_VDMES3
		DFH->DFH_VDMES3 := 0
	EndIf			
	If DFH->DFH_VDACU4 > 0
		DFH->DFH_VDACU4 := DFH->DFH_VDACU4 - DFH->DFH_VDMES4
		DFH->DFH_VDMES4 := 0
	EndIf			
	If DFH->DFH_VDACU5 > 0
		DFH->DFH_VDACU5 := DFH->DFH_VDACU5 - DFH->DFH_VDMES5
		DFH->DFH_VDMES5 := 0
	EndIf			
	DFH->DFH_FIMDEP := Ctod('')
	DFH->DFH_STATUS := '1' //-- Em Aberto
	MsUnLock()
	(cAliasDFH)->(dbSkip())
EndDo			
(cAliasDFH)->(dbCloseArea())

//-- Cancelamento Rateio de Despesas Automáticas
oSelf:IncRegua2( OemToAnsi( "3-" + STR0041 ) ) //-- Cancelando Rateio de Despesas Automaticas
oSelf:SaveLog(   OemToAnsi( "3-" + STR0041 ) ) //-- Cancelando Rateio de Despesas Automaticas

//-- IncProc("3-" + STR0041 ) //-- Cancelando Rateio de Despesas Automaticas
cQuery := "UPDATE " + RetSqlName('DFE')
cQuery += "   SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
cQuery += " WHERE DFE_FILIAL = '" + xFilial('DFE') + "' "
cQuery += "   AND DFE_IDCTMS = '" + cIdCtms + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
If TCSqlExec( cQuery ) <> 0
	Help('',1,'TMSAF9907',,'DFE',04,01) //-- Erro ao Excluir Registro da Tabela:
EndIf
TCRefresh(RetSqlName('DFE'))

//-- Cancelando Movimento de Custo de Transporte
oSelf:IncRegua2( OemToAnsi( "4-" + STR0042 ) ) //-- Cancelando Movimento de Custo de Transporte
oSelf:SaveLog(   OemToAnsi( "4-" + STR0042 ) ) //-- Cancelando Movimento de Custo de Transporte

//-- IncProc("4-" + STR0042 ) //-- Cancelando Movimento de Custo de Transporte
aFiliFSM0 := {}
cQuery := "SELECT SDG.DG_FILIAL FROM "+RetSqlName('SDG')+" SDG WHERE SDG.DG_IDCTMS = '"+cIdCtms+"' AND SDG.D_E_L_E_T_ = ' ' GROUP BY DG_FILIAL ORDER BY DG_FILIAL"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
While (cAliasQry)->(!Eof())
	Aadd(aFiliFSM0,(cAliasQry)->DG_FILIAL)
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())

For nX := 1 To Len(aFiliFSM0)
	//-- Cancelamento movimento de custo de transporte
	cQuery := "UPDATE " + RetSqlName('SDG')
	cQuery += "   SET D_E_L_E_T_ = '*'"
	cQuery += " WHERE DG_FILIAL  = '" + aFiliFSM0[nX] + "' "
	cQuery += "   AND DG_IDCTMS  = '" + cIdCtms + "' "
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	If TCSqlExec( cQuery ) <> 0
	Help('',1,'TMSAF9907',,'SDG',04,01) //-- Erro ao Excluir Registro da Tabela:
	EndIf
	TCRefresh(RetSqlName('SDG'))
Next nX

//-- Exclui itens da planilha de custos do veículo
oSelf:IncRegua2( OemToAnsi( "5-" + STR0043 ) ) //-- Cancelando Planilha de Custo de Veículos
oSelf:SaveLog(   OemToAnsi( "5-" + STR0043 ) ) //-- Cancelando Planilha de Custo de Veículos

//-- IncProc("5-" + STR0043 ) //-- Cancelando Planilha de Custo de Veículos
cQuery := "UPDATE " + RetSqlName('DFL')
cQuery += "   SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
cQuery += " WHERE DFL_FILIAL = '" + xFilial( 'DFL' ) + "' "
cQuery += "   AND DFL_IDCTMS = '" + cIdCtms + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
If TCSqlExec( cQuery ) <> 0
	Help('',1,'TMSAF9907',,'DFL',04,01) //-- Erro ao Excluir Registro da Tabela:
EndIf
TCRefresh(RetSqlName('DFL'))

//-- Exclui cabecalho da planilha de custos do veiculo
cQuery := "UPDATE " + RetSqlName('DFK')
cQuery += "   SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
cQuery += " WHERE DFK_FILIAL = '" + xFilial( 'DFK' ) + "' "
cQuery += "   AND DFK_IDCTMS = '" + cIdCtms + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
If TCSqlExec( cQuery ) <> 0
	Help('',1,'TMSAF9907',,'DFK',04,01) //-- Erro ao Excluir Registro da Tabela:
EndIf
TCRefresh(RetSqlName('DFK'))

End Transaction

//-- Finalizando a transacao no meio, para liberar mais rapido a planilha de veiculo
oSelf:IncRegua2( OemToAnsi( "6-" + STR0044 ) ) //-- Cancelando Custos da Viagem
oSelf:SaveLog(   OemToAnsi( "6-" + STR0044 ) ) //-- Cancelando Custos da Viagem

//-- IncProc("6-" + STR0044 ) //-- Cancelando Custos da Viagem
DFM->(dbSetOrder(1))
DTQ->(dbSetOrder(2))
cQuery := "SELECT DFM_FILORI, DFM_VIAGEM, DTQ.R_E_C_N_O_ DTQRECNO, SUM(DFM_CUSTO1) DFM_CUSTO1, SUM(DFM_CUSTO2) DFM_CUSTO2,"
cQuery += "                                                        SUM(DFM_CUSTO3) DFM_CUSTO3, SUM(DFM_CUSTO4) DFM_CUSTO4," 
cQuery += "                                                        SUM(DFM_CUSTO5) DFM_CUSTO5 "
cQuery += "  FROM "+RetSqlName('DFM') + " DFM, "+RetSqlName('DTQ') + " DTQ "
cQuery += " WHERE DFM_FILIAL     = '"+xFilial('DFM')+"'"
cQuery += "   AND DFM_IDCTMS     = '"+cIdCtms+"'"
cQuery += "   AND DFM.D_E_L_E_T_ = ' '"  
cQuery += "   AND DTQ.DTQ_FILIAL = '"+xFilial('DTQ')+"'"
cQuery += "   AND DTQ.DTQ_FILORI = DFM.DFM_FILORI "
cQuery += "   AND DTQ.DTQ_VIAGEM = DFM.DFM_VIAGEM " 
cQuery += "   AND DTQ.D_E_L_E_T_ = ' '" 
cQuery += "   AND (DTQ.DTQ_CUSTO1+DTQ.DTQ_CUSTO2+DTQ.DTQ_CUSTO3+DTQ.DTQ_CUSTO4+DTQ.DTQ_CUSTO5) <> 0 "
cQuery += "   GROUP BY DFM_FILORI, DFM_VIAGEM, DTQ.R_E_C_N_O_ "
cQuery += "   ORDER BY DFM_FILORI, DFM_VIAGEM, DTQ.R_E_C_N_O_ "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
TCSetField(cAliasQry,"DFM_CUSTO1","N",TamSx3("DFM_CUSTO1")[1],TamSx3("DFM_CUSTO1")[2])
TCSetField(cAliasQry,"DFM_CUSTO2","N",TamSx3("DFM_CUSTO2")[1],TamSx3("DFM_CUSTO2")[2])
TCSetField(cAliasQry,"DFM_CUSTO3","N",TamSx3("DFM_CUSTO3")[1],TamSx3("DFM_CUSTO3")[2])
TCSetField(cAliasQry,"DFM_CUSTO4","N",TamSx3("DFM_CUSTO4")[1],TamSx3("DFM_CUSTO4")[2])
TCSetField(cAliasQry,"DFM_CUSTO5","N",TamSx3("DFM_CUSTO5")[1],TamSx3("DFM_CUSTO5")[2])
Begin Transaction  
While (cAliasQry)->(!Eof())
	DTQ->(dbGoTo((cAliasQry)->DTQRECNO))
	RecLock('DTQ',.F.)
	DTQ->DTQ_CUSTO1 := (DTQ->DTQ_CUSTO1 - (cAliasQry)->DFM_CUSTO1)
	DTQ->DTQ_CUSTO2 := (DTQ->DTQ_CUSTO2 - (cAliasQry)->DFM_CUSTO2)
	DTQ->DTQ_CUSTO3 := (DTQ->DTQ_CUSTO3 - (cAliasQry)->DFM_CUSTO3)
	DTQ->DTQ_CUSTO4 := (DTQ->DTQ_CUSTO4 - (cAliasQry)->DFM_CUSTO4)
	DTQ->DTQ_CUSTO5 := (DTQ->DTQ_CUSTO5 - (cAliasQry)->DFM_CUSTO5)
	MsUnLock()
	(cAliasQry)->(dbSkip())
EndDo	 
(cAliasQry)->(dbCloseArea())

cQuery := "UPDATE " + RetSqlName('DFM')
cQuery += "   SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
cQuery += " WHERE DFM_FILIAL = '" + xFilial( 'DFM' ) + "' "
cQuery += "   AND DFM_IDCTMS = '" + cIdCtms + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
If TCSqlExec( cQuery ) <> 0
	Help('',1,'TMSAF9907',,'DFM',04,01) //-- Erro ao Excluir Registro da Tabela:
EndIf
TCRefresh(RetSqlName('DFM'))

End Transaction

//-- Apaga custos dos documentos de transporte
oSelf:IncRegua2( OemToAnsi( "7-" + STR0045 ) ) //-- Cancelando Custos dos Documentos
oSelf:SaveLog(   OemToAnsi( "7-" + STR0045 ) ) //-- Cancelando Custos dos Documentos

//-- IncProc("7-" + STR0045 ) //-- Cancelando Custos dos Documentos
DFN->(dbSetOrder(1))
DT6->(dbSetOrder(1))
cQuery := "SELECT DFN_FILDOC, DFN_DOC, DFN_SERIE, DT6.R_E_C_N_O_ DT6RECNO, SUM(DFN_CUSTO1) DFN_CUSTO1, SUM(DFN_CUSTO2) DFN_CUSTO2," 
cQuery += "                                                                SUM(DFN_CUSTO3) DFN_CUSTO3, SUM(DFN_CUSTO4) DFN_CUSTO4,"
cQuery += "                                                                SUM(DFN_CUSTO5) DFN_CUSTO5"
cQuery += "  FROM "+RetSqlName('DFN') + " DFN, "+RetSqlName('DT6') + " DT6 "
cQuery += " WHERE DFN.DFN_FILIAL = '"+xFilial('DFN')+"'"
cQuery += "   AND DFN.DFN_IDCTMS = '"+cIdCtms+"'"
cQuery += "   AND DFN.D_E_L_E_T_ = ' '"  
cQuery += "   AND DT6.DT6_FILIAL = '"+xFilial('DT6')+"'"
cQuery += "   AND DT6.DT6_FILDOC = DFN.DFN_FILDOC "
cQuery += "   AND DT6.DT6_DOC    = DFN.DFN_DOC " 
cQuery += "   AND DT6.DT6_SERIE  = DFN.DFN_SERIE "
cQuery += "   AND DT6.D_E_L_E_T_ = ' '" 
cQuery += "   AND (DT6.DT6_CUSTO1+DT6.DT6_CUSTO2+DT6.DT6_CUSTO3+DT6.DT6_CUSTO4+DT6.DT6_CUSTO5) <> 0 "
cQuery += "   GROUP BY DFN_FILDOC, DFN_DOC, DFN_SERIE, DT6.R_E_C_N_O_ "
cQuery += "   ORDER BY DFN_FILDOC, DFN_DOC, DFN_SERIE, DT6.R_E_C_N_O_ "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
TCSetField(cAliasQry,"DFN_CUSTO1","N",TamSx3("DFN_CUSTO1")[1],TamSx3("DFN_CUSTO1")[2])
TCSetField(cAliasQry,"DFN_CUSTO2","N",TamSx3("DFN_CUSTO2")[1],TamSx3("DFN_CUSTO2")[2])
TCSetField(cAliasQry,"DFN_CUSTO3","N",TamSx3("DFN_CUSTO3")[1],TamSx3("DFN_CUSTO3")[2])
TCSetField(cAliasQry,"DFN_CUSTO4","N",TamSx3("DFN_CUSTO4")[1],TamSx3("DFN_CUSTO4")[2])
TCSetField(cAliasQry,"DFN_CUSTO5","N",TamSx3("DFN_CUSTO5")[1],TamSx3("DFN_CUSTO5")[2])
Begin Transaction    
While (cAliasQry)->(!Eof())
	DT6->(dbGoTo((cAliasQry)->DT6RECNO))
	RecLock('DT6',.F.)
	DT6->DT6_CUSTO1 := (DT6->DT6_CUSTO1 - (cAliasQry)->DFN_CUSTO1)
	DT6->DT6_CUSTO2 := (DT6->DT6_CUSTO2 - (cAliasQry)->DFN_CUSTO2)
	DT6->DT6_CUSTO3 := (DT6->DT6_CUSTO3 - (cAliasQry)->DFN_CUSTO3)
	DT6->DT6_CUSTO4 := (DT6->DT6_CUSTO4 - (cAliasQry)->DFN_CUSTO4)
	DT6->DT6_CUSTO5 := (DT6->DT6_CUSTO5 - (cAliasQry)->DFN_CUSTO5)
	MsUnLock()   
	dbCommit()
	(cAliasQry)->(dbSkip())
EndDo	
(cAliasQry)->(dbCloseArea())

cQuery := "UPDATE " + RetSqlName('DFN')
cQuery += "   SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
cQuery += " WHERE DFN_FILIAL = '" + xFilial( 'DFN' ) + "' "
cQuery += "   AND DFN_IDCTMS = '" + cIdCtms + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
If TCSqlExec( cQuery ) <> 0
	Help('',1,'TMSAF9907',,'DFN',04,01) //-- Erro ao Excluir Registro da Tabela:
EndIf
TCRefresh(RetSqlName('DFN'))
			
//-- Atualiza DFJ
RecLock('DFJ',.F.)
DFJ->DFJ_STATUS := '9' //-- Cancelado
MsUnLock()      

End Transaction

oSelf:IncRegua1( STR0038 + Dtoc( Date() ) + STR0020 + Left( Time(), 5 ) ) //-- Processo FINALIZADO em
oSelf:SaveLog(   STR0038 + Dtoc( Date() ) + STR0020 + Left( Time(), 5 ) ) //-- Processo FINALIZADO em

RestArea(aAreaDFJ)          
RestArea(aAreaDTQ)
RestArea(aAreaDFF)
RestArea(aAreaDFM)
RestArea(aAreaDT6)

Return NIL

/*                                                                           
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF99Leg³ Autor ³Richard Anderson       ³ Data ³ 25/Jun/07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Legenda                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSAF99Leg()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAF99                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAF99Leg()
BrwLegenda( cCadastro,; 
				STR0009  ,; //"Status"
				{ { "BR_AMARELO", STR0014 } ,;   //'Em Processo'
				  { "BR_AZUL"	 , STR0010 } ,;	//'Processado'
				  { "BR_PRETO"	 , STR0011 } })	//'Cancelado'

Return NIL

/*                                                                           
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF99KmD³ Autor ³Richard Anderson       ³ Data ³ 07/Nov/07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retornar a quilometragem do documento nas viagens de trans- ³±±
±±³          ³ferencia                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSAF99KmD()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAF99                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAF99KmD(cFilOri,cViagem,cFilSai,cFilDca,lPorRota,aDistRot)

Local nQKmDoc   := 0
Local cQuery    := ''
Local aAreaAtu  := GetArea()
Local cAliasQry := GetNextAlias()
Local cCdrOri	 := ''
Local cCdrDes	 := ''
Local nPosKmd   := 0

Default lPorRota := .T.

If lPorRota
	nPosKmd   := Ascan(aDistRot,{ | e | e[1] == cFilSai+cFilDca })
    If nPosKmd == 0
		cCdrOri := PadR(SuperGetMv("MV_CDRORI",,"",cFilSai),Len(DUD->DUD_CDRDES))
        cCdrDes := PadR(SuperGetMv("MV_CDRORI",,"",cFilDca),Len(DUD->DUD_CDRDES))
        
        nQKmDoc := TMSDistRot(,.F.,cCdrOri,cCdrDes)
 		Aadd(aDistRot,{cFilSai+cFilDca,nQKmDoc} )
 	Else
	 	nQKmDoc := aDistRot[nPosKmd,2]
 	EndIf
Else
	cQuery := "SELECT DUV_FILSAI, DUV_ODOSAI, DUV_FILENT, DUV_ODOENT, DUV.R_E_C_N_O_ DUVRECNO "
	cQuery += "  FROM "
	cQuery += RetSQLName('DUV')+" DUV "
	cQuery += " WHERE DUV.DUV_FILORI  = '"+cFilOri+"'"
	cQuery += "   AND DUV.DUV_VIAGEM  = '"+cViagem+"'"
	cQuery += "   AND DUV.D_E_L_E_T_  = ' '"
	cQuery += " ORDER BY DUVRECNO
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	TCSetField(cAliasQry,"DUV_ODOSAI","N",TamSx3("DUV_ODOSAI")[1],TamSx3("DUV_ODOSAI")[2])
	TCSetField(cAliasQry,"DUV_ODOENT","N",TamSx3("DUV_ODOENT")[1],TamSx3("DUV_ODOENT")[2])
	While (cAliasQry)->(!Eof())
		If (cAliasQry)->DUV_FILSAI == cFilSai .Or. nQKmDoc > 0
			If (cAliasQry)->DUV_ODOENT >= (cAliasQry)->DUV_ODOSAI
				nQKmDoc += (cAliasQry)->DUV_ODOENT - (cAliasQry)->DUV_ODOSAI
			Else
				//-- Virada de Odometro
				nQKmDoc += 999999 - (cAliasQry)->DUV_ODOSAI
				nQKmDoc += (cAliasQry)->DUV_ODOENT
			EndIf
		EndIf
		If (cAliasQry)->DUV_FILENT == cFilDca
			Exit
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())	
EndIf
RestArea(aAreaAtu)

Return nQKmDoc

/*                                                                           
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMCustoFun ³ Autor ³Richard Anderson       ³ Data ³ 07/Nov/07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o custo do funcionario a partir do SIGAGPE ou custo- ³±±
±±³          ³mizacao                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMCustoFun()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSAF99                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSCustoFun( aMtrzSal, dDatIni, dDatFim, aMsgErr, cTipoLoop )

Local aAliasGPE := { 'SRA','SRD','SRT','SRV' }
Local nCustoFun := 0
Local cTMSVerb  := SuperGetMv('MV_TMSVERB',,'') //-- verbas para calculo do custo do funcionario
Local cCodVerb  := ''
Local cString   := ''
Local cQuery    := ''
Local nCon1     := 0
Local cTMSTcLk  := SuperGetMv('MV_TMSTCLK',,'') //'ddabase';'ip or named';porta
Local cAliasQry := ''
Local aAreaAtu  := GetArea()
Local nMot      := 0
Local nI        := 0

If lTMA99CTF

	For nMot := 1 To Len( aMtrzSal )

		nCustoFun := ExecBlock('TMA99CTF',.F.,.F.,{aMtrzSal[nMot],dDatIni,dDatFim,cTipoLoop})

		If ValType(nCustoFun) != 'N'
			nCustoFun := 0
		EndIf

		aMtrzSal[ nMot ][ Iif( cTipoLoop == 'CV', MO_CUSTO, MS_CUSTO ) ] := nCustoFun
	next nMot
	
Else	
	Begin Sequence
	
	If !Empty(cTMSTcLk)
		//-- Realiza Link em outro ambiente da folha caso necessario para obter proventos
		//-- Passar True na chamada do TcLink, para nao exibir a mensagem, pois esta rotina e processamento e nao pode parar
		AEval(aAliasGPE,{ | e | dbSelectArea(e),dbCloseArea() })
		nCon1  := TMSTcLk(,.T.)
		If nCon1 > 0 //--Conectou com o TcLink
			AEval(aAliasGPE,{ | e | ChkFile(e) })
		Else
			TMSTclK(nCon1,.F.)
			AEval(aAliasGPE,{ | e | ChkFile(e) })
			Aadd(aMsgErr,{ STR0049, '00', '' }) //-- Verificar as tabelas do SIGAGPE. Nao foi possivel conexao no banco de dados
			Break
		EndIf
	EndIf
				
	For nMot := 1 To Len( aMtrzSal )

		cFilBas    := aMtrzSal[ nMot ][ Iif( cTipoLoop == 'CV', MO_FILBAS, MS_FILBAS ) ]
		cMatricula := aMtrzSal[ nMot ][ Iif( cTipoLoop == 'CV', MO_MATRIC, MS_MATRIC ) ]

		If !Empty(cFilBas) .And. !Empty(cMatricula)
			aMtrzSal[ nMot ][ Iif( cTipoLoop == 'CV', MO_CUSTO, MS_CUSTO  ) ] := CalCustoFun(cFilBas,cMatricula,.T.,.T.,dDatIni,dDatFim)

			cCodVerb := ''
			If !Empty(cTMSVerb)
				For nI := 1 To Len(cTMSVerb)
					If Substr(cTMSVerb,nI,1) == ';' .Or. ;
						Substr(cTMSVerb,nI,1) == '/'
						cCodVerb += "'"+cString+"', "	 
						cString  := ""
					EndIf
					cString += Substr(cTMSVerb,nI,1)
				Next nI
				cCodVerb  += "'"+cString+"'"	 
				cAliasQry := GetNextAlias()
				cQuery := "SELECT SUM(RD_VALOR) RD_VALOR "
				cQuery += "  FROM "+RetSqlName('SRD') + " SRD "	
				cQuery += "  JOIN "+RetSqlName('SRV') + " SRV "
				cQuery += "    ON SRV.RV_FILIAL  = '" + xFilial( 'SRV' )  + "' "
				cQuery += "   AND SRV.RV_COD = SRD.RD_PD "
				cQuery += "   AND SRV.RV_TIPOCOD = '1' " //--Proventos
				cQuery += "   AND SRV.D_E_L_E_T_ = ' ' "
				cQuery += " WHERE SRD.RD_FILIAL  = '" + cFilBas           + "' "
				cQuery += "   AND SRD.RD_MAT     = '" + cMatricula        + "' "
				cQuery += "   AND SRD.RD_DATARQ >= '" + MesAno( dDatIni ) + "' "
				cQuery += "   AND SRD.RD_DATARQ <= '" + MesAno( dDatFim ) + "' "
				cQuery += "   AND SRD.RD_PD IN   ( "  + cCodVerb + ")"
				cQuery += "   AND SRD.D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
				TCSetField(cAliasQry,"RD_VALOR","N",TamSx3("RD_VALOR")[1],TamSx3("RD_VALOR")[2])
				If (cAliasQry)->(!Eof())
					aMtrzSal[ nMot ][ Iif( cTipoLoop == 'CV', MO_CUSTO, MS_CUSTO ) ] += (cAliasQry)->RD_VALOR
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
		EndIf		

		aMtrzSal[ nMot ][ Iif( cTipoLoop == 'CV', MO_VALHOR, MS_VALHOR ) ] := aMtrzSal[ nMot ][ Iif( cTipoLoop == 'CV', MO_CUSTO, MS_CUSTO ) ] / Posicione( 'SRA', 1, xFilial( 'SRA' ) + cMatricula, 'RA_HRSMES' )

	Next nMot

	If nCon1 > 0
		TMSTclK(nCon1,.F.)
		AEval(aAliasGPE,{ | e | ChkFile(e) })
	EndIf	
	
	End Sequence
EndIf	
	
RestArea(aAreaAtu)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSAF99Con ³ Autor ³Telso Carneiro      ³ Data ³ 04/Dez/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Controle de Continuacao do calculo de custos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSAF99                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSAF99Con(cProc,lFim,cIdCTMS,lDesp,nDF9Recno)
Local aArea     := GetArea()
Local aRet      := {.F.,.F.} //Rodar,Deletar
Local lNProc    := .F.
Default lFim    := .F.
Default lDesp   := .F.
Default cIdCTMS := ''

If !lDesp
	If !lFim
		If DFJ->DFJ_STATUS == '1'
			DO CASE
				CASE cProc == StrZero(10,Len(DFJ->DFJ_INIPRO)) .OR. cProc == StrZero(8,Len(DFJ->DFJ_INIPRO)) //-- Processo de salario e Mao de obra PREMISSSA para o processo 20 e 22
					aRet[1] := .T.  //Rodar
					aRet[2] := .T.  //Deletar
				CASE DFJ->DFJ_INIPRO == cProc .And. DFJ->DFJ_FIMPRO == StrZero(0,Len(DFJ->DFJ_FIMPRO))
					aRet[1] := .T.  //Rodar
					aRet[2] := .T.  //Deletar
				CASE Val(DFJ->DFJ_INIPRO) < Val(cProc)
					aRet[1] := .T.  //Rodar
					aRet[2] := .F.  //Deletar
					lNProc  := .T.
			EndCASE
		Else
			aRet[1] := .T.  //Rodar
			aRet[2] := .F.  //Deletar
			lNProc  := .T.
		EndIf
		If lNProc
			RecLock('DFJ',.F.)
			DFJ->DFJ_INIPRO := cProc
			DFJ->DFJ_FIMPRO := StrZero(0,Len(DFJ->DFJ_FIMPRO))
			MsUnLock()
			dbCommit()
		EndIf
	Else
		RecLock('DFJ',.F.)
		DFJ->DFJ_INIPRO := cProc
		DFJ->DFJ_FIMPRO := cProc
		MsUnLock()
		dbCommit()
	EndIf
EndIf
RestArea(aArea)
Return(aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSAF99SDG ³ Autor ³Telso Carneiro      ³ Data ³ 04/Dez/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Controle de Continuacao do calculo de custos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSAF99                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSAF99SDG(cOrigem,cCodDes,cCodVei,cIdCTMS,dDatFim,cProc,cFilOri,cViagem,cFilcta,cAliaTDOC,cAliaTSAL,cAliaTFAI,cAliaGDT6)
Local aArea := GetArea()                                                         
Local cAliasQry 
Local cQuery  := ''
Local cAliasDFH 
Local aStruDFH  
Local nX

If !Empty(cOrigem)
	cAliasQry := GetNextAlias()
	cQuery := "SELECT R_E_C_N_O_ SDGRECNO "
	cQuery += "  FROM "
	cQuery += RetSqlName('SDG')+" SDG "
	cQuery += " WHERE SDG.DG_FILIAL    = '" + xFilial( "SDG" ) + "'"
	cQuery += "   AND SDG.DG_EMISSAO   = '" + Dtos( dDatFim )  + "'"
	cQuery += "   AND SDG.DG_STATUS    = '" + StrZero( 3, Len( SDG->DG_STATUS ) ) + "'"  //-- Baixa Total
	cQuery += "   AND SDG.DG_ORIGEM    = '" + cOrigem + "'"
	cQuery += "   AND SDG.DG_IDCTMS    = '" + cIdCTMS + "'"
	cQuery += "   AND SDG.DG_CODDES    = '" + cCodDes + "'"
	If !Empty(cCodVei)
		cQuery += "   AND SDG.DG_CODVEI = '" + cCodVei + "'"
		cQuery += "   AND SDG.DG_VIAGEM = ' '" 
	Else
		cQuery += "   AND SDG.DG_FILORI = '" + cFilOri + "'"
		cQuery += "   AND SDG.DG_VIAGEM = '" + cViagem + "'"	
	EndIf
	cQuery += "   AND SDG.D_E_L_E_T_   = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
	While (cAliasQry)->(!Eof())
		SDG->(DbGoto((cAliasQry)->SDGRECNO))
		If SDG->DG_GERADOR == "TMSAF99" .And. SDG->DG_TIPGER == "1"	//-- Manual
			AtuTabSDG(,5)
			dbCommit()
		EndIf
		(cAliasQry)->(dBSkip())
	Enddo
	(cAliasQry)->(DbCloseArea())
Else    

	DO CASE
	CASE cProc == StrZero(2,Len(DFJ->DFJ_INIPRO))
		cAliasDFH := GetNextAlias()
		aStruDFH  := DFH->(dbStruct())

		//-- Depreciação de veículos		
		cQuery := "SELECT DFH.*, DFH.R_E_C_N_O_ DFHRECNO FROM "
		cQuery += RetSqlName('DFH')+" DFH "
		cQuery += " WHERE  DFH.DFH_FILIAL = '" + xFilial( 'DFH' ) + "'"
		cQuery += "   AND (DFH.DFH_STATUS = '1'"
		cQuery += "    OR  DFH.DFH_FIMDEP = '" + Dtos( dDatFim ) + "')"
		cQuery += "   AND  DFH.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDFH)
		For nX := 1 To Len(aStruDFH)
			If aStruDFH[nX][2]<>"C"
				TcSetField(cAliasDFH,aStruDFH[nX][1],aStruDFH[nX][2],aStruDFH[nX][3],aStruDFH[nX][4])
			EndIf
		Next nX
		While (cAliasDFH)->(!Eof())
			//-- Atualiza depreciacao
			DFH->(dbGoTo((cAliasDFH)->DFHRECNO))
			RecLock('DFH',.F.)
			If DFH->DFH_VDACU1 > 0
				DFH->DFH_VDACU1 := DFH->DFH_VDACU1 - DFH->DFH_VDMES1
				DFH->DFH_VDMES1 := 0
			EndIf
			If DFH->DFH_VDACU2 > 0
				DFH->DFH_VDACU2 := DFH->DFH_VDACU2 - DFH->DFH_VDMES2
				DFH->DFH_VDMES2 := 0
			EndIf
			If DFH->DFH_VDACU3 > 0
				DFH->DFH_VDACU3 := DFH->DFH_VDACU3 - DFH->DFH_VDMES3
				DFH->DFH_VDMES3 := 0
			EndIf
			If DFH->DFH_VDACU4 > 0
				DFH->DFH_VDACU4 := DFH->DFH_VDACU4 - DFH->DFH_VDMES4
				DFH->DFH_VDMES4 := 0
			EndIf
			If DFH->DFH_VDACU5 > 0
				DFH->DFH_VDACU5 := DFH->DFH_VDACU5 - DFH->DFH_VDMES5
				DFH->DFH_VDMES5 := 0
			EndIf
			DFH->DFH_FIMDEP := Ctod('')
			DFH->DFH_STATUS := '1' //-- Em Aberto
			MsUnLock()       
			dbCommit()
			(cAliasDFH)->(dbSkip())
		EndDo
		(cAliasDFH)->(dbCloseArea())	
		
	CASE cProc == StrZero(3,Len(DFJ->DFJ_INIPRO))
		//-- Cancelamento Rateio de Despesas Automáticas
		cQuery := "UPDATE " + RetSqlName( 'DFE' )
		cQuery += "   SET D_E_L_E_T_ = '*' "
		cQuery += " WHERE DFE_FILIAL = '" + xFilial( 'DFE' ) + "' "
		cQuery += "   AND DFE_IDCTMS = '" + cIdCtms + "' "
		cQuery += "   AND D_E_L_E_T_ = ' ' "
		If TCSqlExec( cQuery ) <> 0
			Help('',1,'TMSAF9907',,'DFE',04,01) //-- Erro ao Excluir Registro da Tabela:
		EndIf
		TCRefresh(RetSqlName('DFE')) 
		           
	CASE cProc == StrZero(4,Len(DFJ->DFJ_INIPRO))
		//-- Cancelamento amortização de despesas
		cQuery := "UPDATE " + RetSqlName( 'DFF' )
		cQuery += "   SET D_E_L_E_T_ = '*' "
		cQuery += " WHERE DFF_FILIAL = '" + xFilial( 'DFF' ) + "' "
		cQuery += "   AND DFF_IDCTMS = '" + cIdCtms + "' "
		cQuery += "   AND D_E_L_E_T_ = ' ' "
		If TCSqlExec( cQuery ) <> 0
			Help('',1,'TMSAF9907',,'DFF',04,01) //-- Erro ao Excluir Registro da Tabela:
		EndIf
		TCRefresh(RetSqlName('DFF')) 
		
	CASE cProc == StrZero(10,Len(DFJ->DFJ_INIPRO))
		//-- Exclui itens da planilha de custos do veiculo
		cQuery := "UPDATE " + RetSqlName( 'DFL' )
		cQuery += "   SET D_E_L_E_T_ = '*' "
		cQuery += " WHERE DFL_FILIAL = '" + xFilial( 'DFL' ) + "' "
		cQuery += "   AND DFL_IDCTMS = '" + cIdCtms + "' "
		cQuery += "   AND D_E_L_E_T_ = ' ' "
		If TCSqlExec( cQuery ) <> 0
			Help('',1,'TMSAF9907',,'DFL',04,01) //-- Erro ao Excluir Registro da Tabela:
		EndIf
		TCRefresh(RetSqlName('DFL'))
		
		//-- Exclui cabecalho da planilha de custos do veiculo
		cQuery := "UPDATE " + RetSqlName( 'DFK' )
		cQuery += "   SET D_E_L_E_T_ = '*' "
		cQuery += " WHERE DFK_FILIAL = '" + xFilial( 'DFK' ) + "' "
		cQuery += "   AND DFK_IDCTMS = '" + cIdCtms + "' "
		cQuery += "   AND D_E_L_E_T_ = ' ' "
		If TCSqlExec( cQuery ) <> 0
			Help('',1,'TMSAF9907',,'DFK',04,01) //-- Erro ao Excluir Registro da Tabela:
		EndIf
		TCRefresh(RetSqlName('DFK'))
				
	CASE cProc == StrZero(12,Len(DFJ->DFJ_INIPRO))
		//-- Exclui custo das viagens e  contrato de carreteiro	
		cAliasQry := GetNextAlias()			
		DFM->(dbSetOrder(1))
		DTQ->(dbSetOrder(2))
		cQuery := "SELECT DFM_FILORI, DFM_VIAGEM, DTQ.R_E_C_N_O_ DTQRECNO, SUM(DFM_CUSTO1) DFM_CUSTO1, SUM(DFM_CUSTO2) DFM_CUSTO2,"
		cQuery += "                                                        SUM(DFM_CUSTO3) DFM_CUSTO3, SUM(DFM_CUSTO4) DFM_CUSTO4," 
		cQuery += "                                                        SUM(DFM_CUSTO5) DFM_CUSTO5 "
		cQuery += "  FROM " + RetSqlName( 'DFM' ) + " DFM, " + RetSqlName( 'DTQ' ) + " DTQ "
		cQuery += " WHERE DFM_FILIAL     = '" + xFilial( 'DFM' ) + "'"
		cQuery += "   AND DFM_IDCTMS     = '" + cIdCtms + "'"
		cQuery += "   AND DFM.D_E_L_E_T_ = ' '"  
		cQuery += "   AND DTQ.DTQ_FILIAL = '" + xFilial( 'DTQ' ) + "'"
		cQuery += "   AND DTQ.DTQ_FILORI = DFM.DFM_FILORI "
		cQuery += "   AND DTQ.DTQ_VIAGEM = DFM.DFM_VIAGEM " 
		cQuery += "   AND DTQ.D_E_L_E_T_ = ' '" 
		cQuery += "   AND (DTQ.DTQ_CUSTO1+DTQ.DTQ_CUSTO2+DTQ.DTQ_CUSTO3+DTQ.DTQ_CUSTO4+DTQ.DTQ_CUSTO5) <> 0 "
		cQuery += "   GROUP BY DFM_FILORI, DFM_VIAGEM, DTQ.R_E_C_N_O_ "
		cQuery += "   ORDER BY DFM_FILORI, DFM_VIAGEM, DTQ.R_E_C_N_O_ "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		TCSetField(cAliasQry,"DFM_CUSTO1","N",TamSx3("DFM_CUSTO1")[1],TamSx3("DFM_CUSTO1")[2])
		TCSetField(cAliasQry,"DFM_CUSTO2","N",TamSx3("DFM_CUSTO2")[1],TamSx3("DFM_CUSTO2")[2])
		TCSetField(cAliasQry,"DFM_CUSTO3","N",TamSx3("DFM_CUSTO3")[1],TamSx3("DFM_CUSTO3")[2])
		TCSetField(cAliasQry,"DFM_CUSTO4","N",TamSx3("DFM_CUSTO4")[1],TamSx3("DFM_CUSTO4")[2])
		TCSetField(cAliasQry,"DFM_CUSTO5","N",TamSx3("DFM_CUSTO5")[1],TamSx3("DFM_CUSTO5")[2])
		While (cAliasQry)->(!Eof())
			DTQ->(dbGoTo((cAliasQry)->DTQRECNO))
			RecLock('DTQ',.F.)
			DTQ->DTQ_CUSTO1 := (DTQ->DTQ_CUSTO1 - (cAliasQry)->DFM_CUSTO1)
			DTQ->DTQ_CUSTO2 := (DTQ->DTQ_CUSTO2 - (cAliasQry)->DFM_CUSTO2)
			DTQ->DTQ_CUSTO3 := (DTQ->DTQ_CUSTO3 - (cAliasQry)->DFM_CUSTO3)
			DTQ->DTQ_CUSTO4 := (DTQ->DTQ_CUSTO4 - (cAliasQry)->DFM_CUSTO4)
			DTQ->DTQ_CUSTO5 := (DTQ->DTQ_CUSTO5 - (cAliasQry)->DFM_CUSTO5)
			MsUnLock()                                  
			dbCommit()
			(cAliasQry)->(dbSkip())
		EndDo	 
		(cAliasQry)->(dbCloseArea())
		
		cQuery := "UPDATE " + RetSqlName( 'DFM' )
		cQuery += " SET D_E_L_E_T_ = '*' "
		cQuery += " WHERE DFM_FILIAL = '" + xFilial( 'DFM' ) + "' "
		cQuery += "   AND DFM_IDCTMS = '" + cIdCtms + "' "
		cQuery += "   AND D_E_L_E_T_ = ' ' "
		If TCSqlExec( cQuery ) <> 0
			Help('',1,'TMSAF9907',,'DFM',04,01) //-- Erro ao Excluir Registro da Tabela:
		EndIf
		TCRefresh(RetSqlName('DFM'))               
		
	CASE cProc == StrZero(13,Len(DFJ->DFJ_INIPRO))
		//-- Apaga custos dos documentos de transporte
		cAliasQry := GetNextAlias()
		DFN->(dbSetOrder(1))
		DT6->(dbSetOrder(1))
		cQuery := "SELECT DFN_FILDOC, DFN_DOC, DFN_SERIE, DT6.R_E_C_N_O_ DT6RECNO, SUM(DFN_CUSTO1) DFN_CUSTO1, SUM(DFN_CUSTO2) DFN_CUSTO2," 
		cQuery += "                                                                SUM(DFN_CUSTO3) DFN_CUSTO3, SUM(DFN_CUSTO4) DFN_CUSTO4,"
		cQuery += "                                                                SUM(DFN_CUSTO5) DFN_CUSTO5"
		cQuery += "  FROM " + RetSqlName( 'DFN' ) + " DFN, " + RetSqlName( 'DT6' ) + " DT6 "
		cQuery += " WHERE DFN_FILIAL     = '" + xFilial( 'DFN' ) + "'"
		cQuery += "   AND DFN_IDCTMS     = '" + cIdCtms + "'"
		cQuery += "   AND DFN.D_E_L_E_T_ = ' '"  
		cQuery += "   AND DT6.DT6_FILIAL = '" + xFilial( 'DT6' ) + "'"
		cQuery += "   AND DT6.DT6_FILDOC = DFN.DFN_FILDOC "
		cQuery += "   AND DT6.DT6_DOC    = DFN.DFN_DOC " 
		cQuery += "   AND DT6.DT6_SERIE  = DFN.DFN_SERIE "
		cQuery += "   AND DT6.D_E_L_E_T_ = ' '" 
		cQuery += "   AND (DT6.DT6_CUSTO1+DT6.DT6_CUSTO2+DT6.DT6_CUSTO3+DT6.DT6_CUSTO4+DT6.DT6_CUSTO5) <> 0 "
		cQuery += "   GROUP BY DFN_FILDOC, DFN_DOC, DFN_SERIE, DT6.R_E_C_N_O_ "
		cQuery += "   ORDER BY DFN_FILDOC, DFN_DOC, DFN_SERIE, DT6.R_E_C_N_O_ "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		TCSetField(cAliasQry,"DFN_CUSTO1","N",TamSx3("DFN_CUSTO1")[1],TamSx3("DFN_CUSTO1")[2])
		TCSetField(cAliasQry,"DFN_CUSTO2","N",TamSx3("DFN_CUSTO2")[1],TamSx3("DFN_CUSTO2")[2])
		TCSetField(cAliasQry,"DFN_CUSTO3","N",TamSx3("DFN_CUSTO3")[1],TamSx3("DFN_CUSTO3")[2])
		TCSetField(cAliasQry,"DFN_CUSTO4","N",TamSx3("DFN_CUSTO4")[1],TamSx3("DFN_CUSTO4")[2])
		TCSetField(cAliasQry,"DFN_CUSTO5","N",TamSx3("DFN_CUSTO5")[1],TamSx3("DFN_CUSTO5")[2])
		While (cAliasQry)->(!Eof())
			DT6->(dbGoTo((cAliasQry)->DT6RECNO))
			RecLock('DT6',.F.)
			DT6->DT6_CUSTO1 := (DT6->DT6_CUSTO1 - (cAliasQry)->DFN_CUSTO1)
			DT6->DT6_CUSTO2 := (DT6->DT6_CUSTO2 - (cAliasQry)->DFN_CUSTO2)
			DT6->DT6_CUSTO3 := (DT6->DT6_CUSTO3 - (cAliasQry)->DFN_CUSTO3)
			DT6->DT6_CUSTO4 := (DT6->DT6_CUSTO4 - (cAliasQry)->DFN_CUSTO4)
			DT6->DT6_CUSTO5 := (DT6->DT6_CUSTO5 - (cAliasQry)->DFN_CUSTO5)
			MsUnLock()     
			dbCommit()
			(cAliasQry)->(dbSkip())
		EndDo	
		(cAliasQry)->(dbCloseArea())
		
		cQuery := "UPDATE " + RetSqlName('DFN')
		cQuery += "   SET D_E_L_E_T_ = '*' "
		cQuery += " WHERE DFN_FILIAL = '" + xFilial( 'DFN' ) + "' "
		cQuery += "   AND DFN_IDCTMS = '" + cIdCtms + "' "
		cQuery += "   AND D_E_L_E_T_ = ' ' "
		If TCSqlExec( cQuery ) <> 0
			Help('',1,'TMSAF9907',,'DFN',04,01) //-- Erro ao Excluir Registro da Tabela:
		EndIf
		TCRefresh(RetSqlName('DFN'))
		
	CASE cProc == StrZero(14,Len(DFJ->DFJ_INIPRO))
		cAliasQry := GetNextAlias()
		cQuery := "SELECT  DFN.R_E_C_N_O_ DFNRECNO " 
		cQuery += "  FROM "+RetSqlName('DFN') + " DFN, "+cAliaTDOC + " TRB "
		cQuery += " WHERE DFN_FILIAL     = '"+xFilial('DFN')+"'"
		cQuery += "   AND DFN_IDCTMS     = '"+cIdCtms+"'"
		cQuery += "   AND DFN_CODDES     = '"+cCodDes+"'"				
		cQuery += "   AND DFN.D_E_L_E_T_ = ' '"  
		cQuery += "   AND TRB.TRB_FILIAL = '"+cFilcta+"'" 
		cQuery += "   AND TRB.TRB_IDCTMS = '"+cIdCtms+"'"
		cQuery += "   AND TRB.TRB_CODDES = '"+cCodDes+"'"				
		cQuery += "   GROUP BY  DFN.R_E_C_N_O_ "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		While (cAliasQry)->(!Eof())
			DFN->(dbGoTo((cAliasQry)->DFNRECNO))
			RecLock('DFN',.F.)
			DbDelete()
			MsUnlock()
			DbCommit() 
			(cAliasQry)->(DbSkip())		
		EndDo	  
		(cAliasQry)->(dbCloseArea())
		
	CASE cProc == StrZero(15,Len(DFJ->DFJ_INIPRO))
	
		cQuery := "UPDATE " + RetSqlName('DFN')
		cQuery += "   SET D_E_L_E_T_ = '*' "
		cQuery += " WHERE DFN_FILIAL  = '" + xFilial( 'DFN' ) + "' "
		cQuery += "   AND DFN_IDCTMS = '" + cIdCtms + "' "
		cQuery += "   AND DFN_CODDES = '" + cCodDes + "'"
		cQuery += "   AND D_E_L_E_T_ = ' ' "
		If TCSqlExec( cQuery ) <> 0
			Help('',1,'TMSAF9907',,'DFN',04,01) //-- Erro ao Excluir Registro da Tabela:
		EndIf
		TCRefresh(RetSqlName('DFN'))
		
	CASE cProc == StrZero(16,Len(DFJ->DFJ_INIPRO))
		cAliasQry := GetNextAlias()
		cAliasDT6 := GetNextAlias()
		cQuery := "SELECT * " 
		cQuery += "  FROM "+cAliaGDT6 + " TRB "
		cQuery += " WHERE TRB.TRB_IDCTMS = '"+cIdCtms+"'"
		cQuery += "   AND TRB.TRB_INICIO = '1'"
		cQuery += "   AND TRB.TRB_FIM    = '0'"				
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		While (cAliasQry)->(!Eof())
		   //-- Apaga custos dos documentos de transporte
			cQuery := "SELECT DFN_FILDOC, DFN_DOC, DFN_SERIE, DT6.R_E_C_N_O_ DT6RECNO, SUM(DFN_CUSTO1) DFN_CUSTO1, SUM(DFN_CUSTO2) DFN_CUSTO2," 
			cQuery += "                                                                SUM(DFN_CUSTO3) DFN_CUSTO3, SUM(DFN_CUSTO4) DFN_CUSTO4,"
			cQuery += "                                                                SUM(DFN_CUSTO5) DFN_CUSTO5"
			cQuery += "  FROM "+RetSqlName('DFN') + " DFN, "+RetSqlName('DT6') + " DT6 "
			cQuery += " WHERE DFN.DFN_FILIAL = '"+xFilial('DFN')+"'" 
			cQuery += "   AND DFN.DFN_FILDOC = '"+(cAliasQry)->TRB_FILDOC+"'"
			cQuery += "   AND DFN.DFN_IDCTMS = '"+cIdCtms+"'"
			cQuery += "   AND DFN.D_E_L_E_T_ = ' '"  
			cQuery += "   AND DT6.DT6_FILIAL = '"+xFilial('DT6')+"'"
			cQuery += "   AND DT6.DT6_FILDOC = DFN.DFN_FILDOC "
			cQuery += "   AND DT6.DT6_DOC = DFN.DFN_DOC " 
			cQuery += "   AND DT6.DT6_SERIE = DFN.DFN_SERIE "
			cQuery += "   AND DT6.D_E_L_E_T_ = ' '" 
			cQuery += "   AND (DT6.DT6_CUSTO1+DT6.DT6_CUSTO2+DT6.DT6_CUSTO3+DT6.DT6_CUSTO4+DT6.DT6_CUSTO5) <> 0 "
			cQuery += "   GROUP BY DFN_FILDOC, DFN_DOC, DFN_SERIE, DT6.R_E_C_N_O_ "
			cQuery += "   ORDER BY DFN_FILDOC, DFN_DOC, DFN_SERIE, DT6.R_E_C_N_O_ "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDT6)
			TCSetField(cAliasDT6,"DFN_CUSTO1","N",TamSx3("DFN_CUSTO1")[1],TamSx3("DFN_CUSTO1")[2])
			TCSetField(cAliasDT6,"DFN_CUSTO2","N",TamSx3("DFN_CUSTO2")[1],TamSx3("DFN_CUSTO2")[2])
			TCSetField(cAliasDT6,"DFN_CUSTO3","N",TamSx3("DFN_CUSTO3")[1],TamSx3("DFN_CUSTO3")[2])
			TCSetField(cAliasDT6,"DFN_CUSTO4","N",TamSx3("DFN_CUSTO4")[1],TamSx3("DFN_CUSTO4")[2])
			TCSetField(cAliasDT6,"DFN_CUSTO5","N",TamSx3("DFN_CUSTO5")[1],TamSx3("DFN_CUSTO5")[2])
			Begin Transaction    
			While (cAliasDT6)->(!Eof())
				DT6->(dbGoTo((cAliasDT6)->DT6RECNO))
				RecLock('DT6',.F.)
				DT6->DT6_CUSTO1 := (DT6->DT6_CUSTO1 - (cAliasDT6)->DFN_CUSTO1)
				DT6->DT6_CUSTO2 := (DT6->DT6_CUSTO2 - (cAliasDT6)->DFN_CUSTO2)
				DT6->DT6_CUSTO3 := (DT6->DT6_CUSTO3 - (cAliasDT6)->DFN_CUSTO3)
				DT6->DT6_CUSTO4 := (DT6->DT6_CUSTO4 - (cAliasDT6)->DFN_CUSTO4)
				DT6->DT6_CUSTO5 := (DT6->DT6_CUSTO5 - (cAliasDT6)->DFN_CUSTO5)
				MsUnLock()   
				dbCommit()
				(cAliasDT6)->(dbSkip())
			EndDo	                        
			End Transaction
			(cAliasDT6)->(dbCloseArea())
		
			(cAliasQry)->(DbSkip())		
		EndDo	  
		(cAliasQry)->(dbCloseArea())
	
	EndCASE
EndIf

RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSAF99Per ³ Autor ³Marcelo C. Coutinho ³ Data ³ 04/Jun/11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Calcula a representatividade do veiculo no montante         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSAF99                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAF99Per(cCodVei, aQtdVge, cFilBas, cSrtSVg, nPerg, nPos )

Local   nTotKmVge := 0
Local   nTotPsVge := 0
Local   nTotTmpVge := 0
Local   nTotKmVei := 0
Local   nTotPsVei := 0
Local   nTotTmpVei := 0
Local   nPerc     := 0
Local   nI        := 0
Local   nTipRat   := 0
Default nPos      := 0
Default nPerg     := 10   
Default cSrtSVg   := ''

If nPos > 0
	nTipRat := &('mv_par'+StrZero(nPerg,2))
	
	For nI := 1 To Len(aQtdVge)
		If !Empty(cSrtSVg) .And. AllTrim(cSrtSVg) <> '*'
			If !(AllTrim(aQtdVge[nI,VG_SERTMS]) $ cSrtSVg)
				Loop
			EndIf
		ElseIf aQtdVge[nI,VG_FILORI] <> cFilBas
			Loop
		EndIf
		
		nTotKmVge += aQtdVge[nI,VG_KM  ]
		nTotPsVge += aQtdVge[nI,VG_PESO]
		nTotTmpVge += Val(aQtdVge[nI,VG_TMPVGE]) 
		
		If aQtdVge[nI,VG_CODVEI] == cCodVei 
			nTotKmVei += aQtdVge[nI,VG_KM  ]
			nTotPsVei += aQtdVge[nI,VG_PESO]
			nTotTmpVei += Val(aQtdVge[nI,VG_TMPVGE]) 
		EndIf
		
	Next nI
	
	If nTipRat == 1      //-- Quilometragem
		nPerc := ( ( nTotKmVei * 100 ) / nTotKmVge )

	ElseIf nTipRat == 2  //-- Quilometragem e Peso
		nPerc := ( ( (nTotKmVei*nTotPsVei) * 100 ) / (nTotKmVge*nTotPsVge) )
	
	ElseIf nTipRat == 3  //-- Rateio por Peso			
		If nPerg == 9 
		   nPerc := ( ( nTotTmpVei * 100 ) / nTotTmpVge )
		Else			
			nPerc := ( ( nTotPsVei * 100 ) / nTotPsVge )
		EndIf
	EndIf

EndIf
	
Return nPerc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TMSAF99trb ³ Autor ³Telso Carneiro      ³ Data ³ 04/Dez/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria ou Abre os Temporarios para o Calculo 20 e 22          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³TMSAF99                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAF99Trb(cAliaTDOC,cAliaTSAL,cAliaTFAI,cIdCTMS,oTempTDOC,oTempTSAL,oTempTFAI)
Local aStruTFAI	:= {}
Local aStruTDOC	:= {}
Local aStruTSAL := {}
Local aTam     	:= {}  

Default oTempTDOC	:= Nil
Default oTempTSAL	:= Nil
Default oTempTFAI	:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho para  controle aFaixas      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aTam := TamSx3("DFJ_IDCTMS")
AAdd(aStruTFAI, {"TRB_IDCTMS" , "C", aTam[1], aTam[2]})
AAdd(aStruTFAI, {"TRB_FILIAL" , "C", TamSx3("DFJ_FILIAL")[1], 0 })
aTam := TamSx3("DFA_CODDES")
AAdd(aStruTFAI, {"TRB_CODDES" , "C", aTam[1], aTam[2]})
aTam := TamSx3("DFB_VALATE")
AAdd(aStruTFAI, {"TRB_VALATE" , "N", aTam[1], aTam[2]})
AAdd(aStruTFAI, {"TRB_REARAT" , "C", 1      , 0})
aTam := TamSx3("DFN_CUSTO1")
AAdd(aStruTFAI, {"TRB_VALACU" , "N", aTam[1], aTam[2]})
aTam := TamSx3("DFN_CUSTO1")
AAdd(aStruTFAI, {"TRB_TOTGER" , "N", aTam[1], aTam[2]})
aTam := TamSx3("DF9_RATEIO")
AAdd(aStruTFAI, {"TRB_RATEIO" , "C", aTam[1], aTam[2]})

//-- Cria tabela Temporária
oTempTFAI	:= FwTemporaryTable():New(cAliaTFAI)
oTempTFAI:SetFields( aStruTFAI )
oTempTFAI:AddIndex("01",{"TRB_IDCTMS","TRB_FILIAL","TRB_CODDES","TRB_RATEIO"})
oTempTFAI:Create()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho para documentos antigo aDocCus      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aTam := TamSx3("DFJ_IDCTMS")
AAdd(aStruTDOC, {"TRB_IDCTMS" , "C", aTam[1], aTam[2]})
aTam := TamSx3("DT6_FILDOC")
AAdd(aStruTDOC, {"TRB_FILIAL" , "C", TamSx3("DFJ_FILIAL")[1], 0})
aTam := TamSx3("DFA_CODDES")
AAdd(aStruTDOC, {"TRB_CODDES" , "C", aTam[1], aTam[2]})
aTam := TamSx3("DT6_FILDOC")
AAdd(aStruTDOC, {"TRB_FILDOC" , "C", aTam[1], aTam[2]})
aTam := TamSx3("DT6_DOC")
AAdd(aStruTDOC, {"TRB_DOC"    , "C", aTam[1], aTam[2]})
aTam := TamSx3("DT6_SERIE")
AAdd(aStruTDOC, {"TRB_SERIE"  , "C", aTam[1], aTam[2]})
aTam := TamSx3("DT6_SERTMS")
AAdd(aStruTDOC, {"TRB_SERTMS"  , "C", aTam[1], aTam[2]})
aTam := TamSx3("DT6_TIPTRA")
AAdd(aStruTDOC, {"TRB_TIPTRA"  , "C", aTam[1], aTam[2]})
aTam := TamSx3("DT6_VALMER")
AAdd(aStruTDOC, {"TRB_VALMER"  , "N", aTam[1], aTam[2]})
aTam := TamSx3("DT6_VALFAT")
AAdd(aStruTDOC, {"TRB_VALFAT"  , "N", aTam[1], aTam[2]})
aTam := TamSx3("DT6_QTDVOL")
AAdd(aStruTDOC, {"TRB_QTDVOL"  , "N", aTam[1], aTam[2]})
aTam := TamSx3("DT6_PESO")
AAdd(aStruTDOC, {"TRB_PESO"    , "N", aTam[1], aTam[2]})
aTam := TamSx3("DT6_PESOM3")
AAdd(aStruTDOC, {"TRB_PESOM3"  , "N", aTam[1], aTam[2]})
aTam := TamSx3("DF9_RATEIO")  
AAdd(aStruTDOC, {"TRB_RATEIO"  , "C", aTam[1], aTam[2]})
aTam := TamSx3("DF9_CAREXP")  
AAdd(aStruTDOC, {"TRB_CAREXP"  , "C", aTam[1], aTam[2]})
aTam := TamSx3("DF9_CARREC")  
AAdd(aStruTDOC, {"TRB_CARREC"  , "C", aTam[1], aTam[2]})
aTam := TamSx3("DF9_CARREP")  
AAdd(aStruTDOC, {"TRB_CARREP"  , "C", aTam[1], aTam[2]})
	
aTam := {} //-- Limpa variavel

//-- Cria tabela temporária
oTempTDOC	:= FwTemporaryTable():New(cAliaTDOC)
oTempTDOC:SetFields(aStruTDOC)
oTempTDOC:AddIndex("01",{"TRB_IDCTMS","TRB_FILIAL","TRB_CODDES","TRB_RATEIO"})
oTempTDOC:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho para antigo aCCSaldo     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aTam := TamSx3("DFJ_IDCTMS")
AAdd(aStruTSAL, {"TRB_IDCTMS","C",aTam[1], aTam[2]})
AAdd(aStruTSAL, {"TRB_FILIAL","C",TamSx3("DFJ_FILIAL")[1] , 0 })
aTam := TamSx3("DFA_CODDES")
AAdd(aStruTSAL, {"TRB_CODDES","C",aTam[1], aTam[2]})
aTam := TamSx3("CT7_ATUDEB")
AAdd(aStruTSAL, {"TRB_NSALDO","N",aTam[1], aTam[2]})
aTam := TamSx3("CT7_ATUDEB")
AAdd(aStruTSAL, {"TRB_NDESP" ,"N",aTam[1], aTam[2]})
aTam := TamSx3("CT7_ATUDEB")
AAdd(aStruTSAL, {"TRB_NMDO"  ,"N",aTam[1], aTam[2]})		//-- Mao de obra TL_CUSTO
aTam := TamSx3("CT7_ATUDEB")
AAdd(aStruTSAL, {"TRB_SALMOT","N",aTam[1], aTam[2]})		//-- Salario do motorista de veiculo de linha
aTam := TamSx3("CT7_ATUDEB")
AAdd(aStruTSAL, {"TRB_VIAVAZ","N",aTam[1], aTam[2]})		//-- Custo de viagens vazias
aTam := TamSx3("DF9_RATEIO")
AAdd(aStruTSAL, {"TRB_RATEIO","C",aTam[1], aTam[2]})
aTam :={} //-- Limpa variavel

//-- Cria tabela Temporária
oTempTSAL	:= FwTemporaryTable():New(cAliaTSAL)
oTempTSAL:SetFields(aStruTSAL)
oTempTSAL:AddIndex("01",{"TRB_IDCTMS","TRB_FILIAL","TRB_CODDES","TRB_RATEIO"})
oTempTSAL:Create()

aSize(aStruTSAL,0)
aSize(aStruTDOC,0)
aSize(aStruTFAI,0)

Return .T. 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TM99CViag ºAutor  ³Rafael Souza      º Data ³  20/01/16     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visualizacao do custo da Viagem                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSAF99                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TM99CViag()

Local cCadastro := "Custo da Viagem" //-- "Custo da Viagem"
Local oPanSoma
Local oDlgCusto
//-- Calcula as dimensoes dos objetos.
Local aSize    := MsAdvSize( .T. )
Local oListBox
Local aHDados  := {}
Local aDados   := {}
Local cQuery   := ''
Local cAliasQry:= CriaTrab(Nil,.F.)
Local nCont    := 0
Local oTot1
Local oTot2
Local oTot3
Local oTot4
Local oTot5
Local nTota1 := 0
Local nTota2 := 0
Local nTota3 := 0
Local nTota4 := 0
Local nTota5 := 0
Local aARea  := GetArea()

SaveInter()

AAdd(aHDados,"Item")
AAdd(aHDados,RetTitle("DFM_CODDES") )
AAdd(aHDados,RetTitle("DT7_DESCRI") )
AAdd(aHDados,RetTitle("DFM_CUSTO1") )
AAdd(aHDados,RetTitle("DFM_CUSTO2") )
AAdd(aHDados,RetTitle("DFM_CUSTO3") )
AAdd(aHDados,RetTitle("DFM_CUSTO4") )
AAdd(aHDados,RetTitle("DFM_CUSTO5") )

cQuery := "SELECT DFM.*, DT7.DT7_DESCRI "
cQuery += " FROM "+RetSqlName("DFM")+" DFM "
cQuery += " 	JOIN "+RetSqlName("DT7")+" DT7 ON DT7.DT7_CODDES = DFM.DFM_CODDES "
cQuery += " WHERE DFM.DFM_FILIAL = '"+xFilial("DFM")+"' "
cQuery += "   AND DFM.DFM_FILORI = '"+DTQ->DTQ_FILORI+"' "
cQuery += "   AND DFM.DFM_VIAGEM = '"+DTQ->DTQ_VIAGEM+"' "
cQuery += "   AND DFM.D_E_L_E_T_ = ' '"
cQuery += "   AND DT7.DT7_FILIAL = '"+xFilial("DT7")+"' "
cQuery += "   AND DT7.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY DFM_IDCTMS, DFM_CODDES"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

TCSetField(cAliasQry,"DFM_CUSTO1","N",TamSx3("DFM_CUSTO1")[1],TamSx3("DFL_CUSTO1")[2])
TCSetField(cAliasQry,"DFM_CUSTO2","N",TamSx3("DFM_CUSTO2")[1],TamSx3("DFL_CUSTO2")[2])
TCSetField(cAliasQry,"DFM_CUSTO3","N",TamSx3("DFM_CUSTO3")[1],TamSx3("DFL_CUSTO3")[2])
TCSetField(cAliasQry,"DFM_CUSTO4","N",TamSx3("DFM_CUSTO4")[1],TamSx3("DFL_CUSTO4")[2])
TCSetField(cAliasQry,"DFM_CUSTO5","N",TamSx3("DFM_CUSTO5")[1],TamSx3("DFL_CUSTO5")[2])

nTota1 := 0
nTota2 := 0
nTota3 := 0
nTota4 := 0
nTota5 := 0
nCont++
While (cAliasQry)->(!Eof())
	AAdd(aDados,{StrZero(nCont++,2),(cAliasQry)->DFM_CODDES,(cAliasQry)->DT7_DESCRI,(cAliasQry)->DFM_CUSTO1,(cAliasQry)->DFM_CUSTO2,(cAliasQry)->DFM_CUSTO3,(cAliasQry)->DFM_CUSTO4,(cAliasQry)->DFM_CUSTO5 })
	nTota1 += (cAliasQry)->DFM_CUSTO1
	nTota2 += (cAliasQry)->DFM_CUSTO2
	nTota3 += (cAliasQry)->DFM_CUSTO3
	nTota4 += (cAliasQry)->DFM_CUSTO4
	nTota5 += (cAliasQry)->DFM_CUSTO5
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())
RestArea(aArea)

If Empty(aDados)
	Help('',1,'TMSAF9911')// Não há dados de custo para a viagem. Realize o cálculo do Custo do período correspondente a viagem.           
Else

	DEFINE MSDIALOG oDlgCusto TITLE cCadastro FROM aSize[7],00 TO (aSize[6]/1.5),aSize[5] PIXEL

	oListBox := TWBrowse():New( aSize[7],00,aSize[6],aSize[5],,aHDados,,oDlgCusto,,,,,,,,,,,,,"ARRAY",.T.)
	oListBox:SetArray( aDados )

	// Ajusta alinhamento do TWBrowse para pegar o dialogo inteiro
	oListBox:Align := CONTROL_ALIGN_ALLCLIENT
	oListBox:bLine := {|| aDados[oListBox:nAT] }

	@000,000 MSPANEL oPanSoma PROMPT "Totais" SIZE 025,030 OF oDlgCusto //-- "Totais"
	oPanSoma:Align := CONTROL_ALIGN_BOTTOM

	@ 10, 05 SAY RetTitle("DFM_CUSTO1")  SIZE 43, 10 OF oPanSoma PIXEL COLOR CLR_BLUE
	@ 10, 45 MSGET oTot1 VAR nTota1 PICTURE PesqPict('DFM','DFM_CUSTO1') When .F. SIZE 50, 10 OF oPanSoma PIXEL

	@ 10,105 SAY RetTitle("DFM_CUSTO2")  SIZE 43, 10 OF oPanSoma PIXEL COLOR CLR_BLUE
	@ 10,145 MSGET oTot2 VAR nTota2 PICTURE PesqPict('DFM','DFM_CUSTO2') When .F. SIZE 50, 10 OF oPanSoma PIXEL

	@ 10,205 SAY RetTitle("DFM_CUSTO3")  SIZE 43, 10 OF oPanSoma PIXEL COLOR CLR_BLUE
	@ 10,245 MSGET oTot3 VAR nTota3 PICTURE PesqPict('DFM','DFM_CUSTO3') When .F. SIZE 50, 10 OF oPanSoma PIXEL

	@ 10,305 SAY RetTitle("DFM_CUSTO4")  SIZE 43, 10 OF oPanSoma PIXEL COLOR CLR_BLUE
	@ 10,345 MSGET oTot4 VAR nTota4 PICTURE PesqPict('DFM','DFM_CUSTO4') When .F. SIZE 50, 10 OF oPanSoma PIXEL

	@ 10,405 SAY RetTitle("DFM_CUSTO5")  SIZE 43, 10 OF oPanSoma PIXEL COLOR CLR_BLUE
	@ 10,445 MSGET oTot5 VAR nTota5 PICTURE PesqPict('DFM','DFM_CUSTO5') When .F. SIZE 50, 10 OF oPanSoma PIXEL

	ACTIVATE MSDIALOG oDlgCusto ON INIT EnchoiceBar(oDlgCusto,{|| oDlgCusto:End() }, {|| oDlgCusto:End() } )
EndIf

RestInter()
Return( Nil )

//-------------------------------------------------------------------
/*{Protheus.doc} AtuTabSDG
Atualiza SDG
@type Function
@author CAio Murakami
@since 10/06/2021
@version 12.1.30
@param
@return lRet
*/
//------------------------------------------------------------------
Static Function AtuTabSDG( aCab , nOpc )
Local nCount	:= 1 
Local lExclui	:= .F. 
Local aArea		:= GetArea()

Default aCab	:= {}
Default nOpc	:= 3 

If FindFunction("TMSA070Aut")
	TMSA070Aut( aCab , nOpc )
Else 

	If nOpc == 3 
		RecLock("SDG",.T.)
	ElseIf nOpc == 4 .Or. nOpc == 5 
		RecLock("SDG",.F.)
		If nOpc == 5 
			lExclui	:= .T. 
		EndIf 
	EndIf 

	If lExclui
		SDG->(DbDelete())
	Else	
		For nCount := 1 To Len(aCab )
			SDG->&(aCab[nCount,1])	:= aCab[nCount,2]
		Next nCount 
	EndIf 

	SDG->(MsUnlock())
EndIf 

RestArea(aArea)
Return 

