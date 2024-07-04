#include "Protheus.ch"
#include "VEIVM130.CH"
#INCLUDE "FWMVCDEF.CH"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ VEIVM130 ≥ Autor ≥  Andre Luis Almeida   ≥ Data ≥ 15/09/09 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Consulta / Movimentacao de Tarefas                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Veiculos                                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function VEIVM130(_cNumAte,cFilAtend,_cOrigem)
Local aObjects   := {} , aInfo := {}, aPos := {}, nCntFor
Local aSizeHalf  := MsAdvSize(.f.)
Local nTime      := 50 // Default 50 segundos
Local nCol       := 0
Local nLinAObj := 0
Private lVAYORIGEM := VAY->(FieldPos("VAY_ORIGEM")) <> 0
Private cNumAte   := Space(TamSX3("VV9_NUMATE")[1])
Private cNumPedV  := ""
Private cStaTaref := "1" // Em Aberto ( Pendente + Aprovado com restricoes )
Private aStaTaref := {"0="+STR0002,"1="+STR0003,"2="+STR0004,"4="+STR0005,"5="+STR0006,"6="+STR0007,"7="+STR0008} // Todos / Em Aberto ( Pendente + Aprovado com restricoes ) / Pendente / Aprovado com restricoes / Aprovado / Rejeitado / Deletado pelo Usuario
Private cTipDat  := "1" // Solicitacao
Private aTipDat  := {"1="+STR0009,"2="+STR0010} // Solicitacao / Execucao
Private dDatIni  := ctod("")
Private dDatFin  := dDataBase
Private aTarefas := {}
Private aVVAs    := {}
Private cObsVV9  := ""
Private nBkpVV9  := 0 // Controle para nao buscar o mesmo Atendimento sem necessidade pois pode haver mais de uma linha (tarefas diferentes) para o mesmo Atendimento
Private nBkpVRJ  := 0 // Controle para nao buscar o mesmo Atendimento sem necessidade pois pode haver mais de uma linha (tarefas diferentes) para o mesmo Atendimento
Private oBR_BRAN := LoadBitmap( GetResources(), "BR_BRANCO")	// Vetor em branco
Private oBR_VERM := LoadBitmap( GetResources(), "BR_VERMELHO")	// Pendente
Private oBR_VERD := LoadBitmap( GetResources(), "BR_VERDE")		// Aprovado
Private oBR_AMAR := LoadBitmap( GetResources(), "BR_AMARELO")	// Aprovado com restricoes
Private oBR_PRET := LoadBitmap( GetResources(), "BR_PRETO")		// Rejeitado
Private oBR_LARA := LoadBitmap( GetResources(), "BR_LARANJA")	// Deletado pelo Usuario
Private oBR_PINK := LoadBitmap( GetResources(), "BR_PINK")		// Pre-Pendente
Private lBotExec := .f.
Private lVisualAte := .f.
Private cFilAte := ""
Private lPrePen := GetNewPar("MV_TARPREP","N") == "S" // Tarefa Pre-Pendente

If lPrepen
	aStaTaref := {"0="+STR0002,"1="+STR0003,"2="+STR0004,"3="+STR0047,,"4="+STR0005,"5="+STR0006,"6="+STR0007,"7="+STR0008} // Todos / Em Aberto ( Pendente + Aprovado com restricoes ) / Pendente / PrÈ-Pendente / Aprovado com restricoes / Aprovado / Rejeitado / Deletado pelo Usuario
Endif

Default _cNumAte := space(TamSx3("VV9_NUMATE")[1])
Default cFilAtend := space(TamSx3("VV9_FILIAL")[1])
Default _cOrigem := ""

If _cOrigem == "3" // Pedido de Venda Montadora
	cNumPedV := _cNumAte
Else
	cNumAte := _cNumAte
EndIf

cFilAte := cFilAtend
cOrigem := _cOrigem
lVisualAte := ! Empty(_cNumAte) // Deixa Alterar(EXECUTAR) o registro quando nao for visualizado apartir do Atendimento
If lVisualAte // Visualiza um atendimento especÌfico
	cStaTaref := "0" // Todos
Else // ManutenÁ„o de todas as Tarefas, sem atendimento especÌfico
	dDatIni := (dDataBase - day(dDataBase)) + 1 // Trazer mÍs corrente
EndIf

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
AAdd( aObjects, { 0, 13, .T., .f. } )
AAdd( aObjects, { 0, 13, .T., .f. } ) // 2™ linha para caber no padr„o 1024x768
AAdd( aObjects, { 0,  0, .T., .T. } )
AAdd( aObjects, { 0, 70, .T., .f. } ) // VVAs / Observacao do Atendimento
AAdd( aObjects, { 0, 11, .T., .f. } )
AAdd( aObjects, { 0, 13, .T., .f. } )

AAdd( aObjects, { 0, 10, .T., .f. } )
aPos := MsObjSize( aInfo, aObjects )
_nSpc := 40

DbSelectArea("VAX")
DbSelectArea("VAY")
FS_FILTRO(0)
// ########################################################################
// # Montagem da tela com informacoes fixas                               #
// ########################################################################
DEFINE MSDIALOG oMovTarefas FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE STR0001 OF oMainWnd PIXEL // Consulta/Movimentacao de Tarefas

nLinAObj++
nCol := aPos[nLinAObj,2] + 3

oSay00 := TSay():New(aPos[nLinAObj, 1] + 1,nCol,{|| STR0046 },oMovTarefas,,,,,,.t.,CLR_BLUE,,_nSpc,8)  // Filial Atendimento
nCol += 29
@ aPos[nLinAObj, 1] , nCol MSGET oFilAte VAR cFilAte F3 "SM0_01" VALID VM130VLDFIL(cFilAte) SIZE 43,8 OF oMovTarefas PIXEL WHEN !lVisualAte HASBUTTON
oFilAte:bGotFocus   := {|| oTimeS:lActive := .f. }
oFilAte:bLostFocus  := {|| oTimeS:lActive := .t. }

nCol += 60
oSay01 := TSay():New(aPos[nLinAObj, 1] + 1,nCol,{|| STR0011 },oMovTarefas,,,,,,.t.,CLR_BLUE,,_nSpc,8)  // Atendimento
nCol += 33
@ aPos[nLinAObj, 1] , nCol MSGET oNumAte VAR cNumAte F3 "VV0ATE" SIZE 48,8 OF oMovTarefas PIXEL WHEN !lVisualAte HASBUTTON VALID VM130003_Valid("ATEND")
oNumAte:bGotFocus   := {|| oTimeS:lActive := .f. }
oNumAte:bLostFocus  := {|| oTimeS:lActive := .t. }

If lVAYORIGEM
	If Empty(cNumPedV)
		cNumPedV := Space(TamSX3("VRJ_PEDIDO")[1])
	EndIf
	nCol += 65
	oSay10 := TSay():New(aPos[nLinAObj, 1] + 1,nCol,{|| "Ped. Venda Montadora" },oMovTarefas,,,,,,.t.,CLR_BLUE,,60,8)  // Pedido de Venda Montadora 
	nCol += 60
	@ aPos[nLinAObj, 1] , nCol MSGET oNumPedV VAR cNumPedV F3 "VRJ" SIZE 48,8 OF oMovTarefas PIXEL WHEN !lVisualAte HASBUTTON VALID VM130003_Valid("PEDVENDA")
	oNumPedV:bGotFocus   := {|| oTimeS:lActive := .f. }
	oNumPedV:bLostFocus  := {|| oTimeS:lActive := .t. }
EndIf

nCol += 65
oSay02 := TSay():New(aPos[nLinAObj, 1] + 1,nCol,{|| STR0012 },oMovTarefas,,,,,,.t.,CLR_BLUE,,_nSpc,8) // Status
nCol += 20
@ aPos[nLinAObj, 1] , nCol COMBOBOX oStatus VAR cStaTaref ITEMS aStaTaref SIZE 150,8 PIXEL OF oMovTarefas
oStatus:bLostFocus  := {|| oTimeS:lActive := .t. }

nLinAObj++

oSay03 := TSay():New(aPos[ nLinAObj ,1]+1,aPos[ nLinAObj ,2]+3,{|| STR0013 },oMovTarefas,,,,,,.t.,CLR_BLUE,,_nSpc,8) // Periodo
@ aPos[ nLinAObj ,1],aPos[ nLinAObj ,2]+26 COMBOBOX oTipDat VAR cTipDat ITEMS aTipDat SIZE 55,8 PIXEL OF oMovTarefas

oTipDat:bGotFocus   := {|| oTimeS:lActive := .f. }
oTipDat:bLostFocus  := {|| oTimeS:lActive := .t. }

@ aPos[ nLinAObj ,1],aPos[ nLinAObj ,2]+88 MSGET oDatIni VAR dDatIni SIZE 40,8 OF oMovTarefas PIXEL

oDatIni:bGotFocus   := {|| oTimeS:lActive := .f. }
oDatIni:bLostFocus  := {|| oTimeS:lActive := .t. }

oSay04 := TSay():New(aPos[ nLinAObj ,1]+1,aPos[ nLinAObj ,2]+135,{|| STR0014 },oMovTarefas,,,,,,.t.,CLR_BLUE,,_nSpc,8) // ate
@ aPos[ nLinAObj ,1],aPos[ nLinAObj ,2]+150 MSGET oDatFin VAR dDatFin SIZE 40,8 OF oMovTarefas PIXEL
oDatFin:bGotFocus   := {|| oTimeS:lActive := .f. }
oDatFin:bLostFocus  := {|| oTimeS:lActive := .t. }

@ aPos[ nLinAObj ,1],aPos[ nLinAObj ,2] + 200 BUTTON oBotFiltrar PROMPT (STR0015) OF oMovTarefas SIZE 20,10 PIXEL ACTION FS_FILTRO(1) // Filtrar


nLinAObj++
oLbTarefas := TWBrowse():New( aPos[ nLinAObj ,1],aPos[ nLinAObj ,2], aPos[ nLinAObj ,4] - aPos[ nLinAObj ,2], aPos[ nLinAObj ,3] - aPos[ nLinAObj ,1],,,,oMovTarefas,,,,;
	{ || FS_BOTEXEC(left(aTarefas[oLbTarefas:nAt,4],1))},;
	{ |nRow,nCol,nFlags| VEIM130VisualizaOrigem(aTarefas[oLbTarefas:nAt]) },;
	,,,,,,.F.,,.T.,,.F.,,, )
oLbTarefas:addColumn( TCColumn():New( ""      , { || aTarefas[oLbTarefas:nAt,1] }      ,,,, "LEFT" , 08 ,.T.,.F.,,,,.F.,) )
oLbTarefas:addColumn( TCColumn():new( RetTitle("VAY_FILIAL") , { || aTarefas[oLbTarefas:nAt,12] }     ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) )
If lVAYORIGEM
	oLbTarefas:AddColumn( TCColumn():New( RetTitle("VAY_ORIGEM") , { || aTarefas[oLbTarefas:nAt,16] } ,,,, "LEFT",  035 ,.F.,.F.,,,,.F.,) )
	oLbTarefas:addColumn( TCColumn():new( RetTitle("VAY_NUMIDE") , { || aTarefas[oLbTarefas:nAt,2] }      ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) )
Else
	oLbTarefas:addColumn( TCColumn():new( STR0011 , { || aTarefas[oLbTarefas:nAt,2] }      ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) ) // "Atendimento"
EndIf
oLbTarefas:addColumn( TCColumn():new( STR0049 , { || aTarefas[oLbTarefas:nAt,13] }     ,,,, "LEFT" , 80 ,.F.,.F.,,,,.F.,) ) // "Vendedor"
oLbTarefas:addColumn( TCColumn():new( STR0050 , { || aTarefas[oLbTarefas:nAt,14] }     ,,,, "LEFT" , 110 ,.F.,.F.,,,,.F.,) ) // "Cliente"
oLbTarefas:addColumn( TCColumn():new( STR0016 , { || aTarefas[oLbTarefas:nAt,3] }      ,,,, "LEFT" , 100 ,.F.,.F.,,,,.F.,) ) // "Tarefa"
oLbTarefas:addColumn( TCColumn():new( STR0012 , { || substr(aTarefas[oLbTarefas:nAt,4],5) } ,,,, "LEFT" , 30 ,.F.,.F.,,,,.F.,) ) // "Status"
oLbTarefas:addColumn( TCColumn():new( STR0017 , { || aTarefas[oLbTarefas:nAt,5] }      ,,,, "LEFT" , 50 ,.F.,.F.,,,,.F.,) ) // "Solicitante"
oLbTarefas:addColumn( TCColumn():new( STR0026 , { || Transform(aTarefas[oLbTarefas:nAt,6],"@E 999,999,999.99") } ,,,, "RIGHT", 50 ,.F.,.F.,,,,.F.,) ) // "Valor Solicitado
oLbTarefas:addColumn( TCColumn():new( STR0018 , { || aTarefas[oLbTarefas:nAt,7] }      ,,,, "LEFT" , 50 ,.F.,.F.,,,,.F.,) ) // "Executor"
oLbTarefas:addColumn( TCColumn():new( STR0019 , { || Transform(aTarefas[oLbTarefas:nAt,8],"@E 999,999,999.99") } ,,,, "RIGHT", 50 ,.F.,.F.,,,,.F.,) ) // "Valor Liberado
oLbTarefas:addColumn( TCColumn():new( STR0045 , { || Transform(aTarefas[oLbTarefas:nAt,11],"@D") }  ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) ) // "RealizaÁ„o"
oLbTarefas:addColumn( TCColumn():new( STR0022 , { || aTarefas[oLbTarefas:nAt,9] }      ,,,, "LEFT" , 80 ,.F.,.F.,,,,.F.,) ) // "ObservaÁ„o"
oLbTarefas:bChange := { || VM1300011_AtualizaVeiculosObservacao( aTarefas[oLbTarefas:nAt,12] , aTarefas[oLbTarefas:nAt,15] , IIf( lVAYORIGEM , aTarefas[oLbTarefas:nAt,17] , "" ) ) , FS_BOTEXEC(left(aTarefas[oLbTarefas:nAt,4],1)) }
oLbTarefas:setArray(aTarefas)
//

nLinAObj++
oLbVVAs := TWBrowse():New( aPos[nLinAObj,1],aPos[nLinAObj,2] , ( aPos[nLinAObj,4]/2 ) , aPos[nLinAObj,3]-aPos[nLinAObj,1],,,,oMovTarefas,,,,,{ || .t. },,,,,,,.F.,,.T.,,.F.,,,)
oLbVVAs:addColumn( TCColumn():new( STR0051 , { || aVVAs[oLbVVAs:nAt,1] }  ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) ) // Marca
oLbVVAs:addColumn( TCColumn():new( STR0052 , { || aVVAs[oLbVVAs:nAt,2] }  ,,,, "LEFT" ,100 ,.F.,.F.,,,,.F.,) ) // Modelo
oLbVVAs:addColumn( TCColumn():new( STR0053 , { || aVVAs[oLbVVAs:nAt,3] }  ,,,, "LEFT" , 80 ,.F.,.F.,,,,.F.,) ) // Cor
oLbVVAs:addColumn( TCColumn():new( STR0054 , { || aVVAs[oLbVVAs:nAt,4] }  ,,,, "LEFT" , 50 ,.F.,.F.,,,,.F.,) ) // Placa
oLbVVAs:addColumn( TCColumn():new( STR0055 , { || aVVAs[oLbVVAs:nAt,5] }  ,,,, "LEFT" ,100 ,.F.,.F.,,,,.F.,) ) // Chassi
oLbVVAs:setArray(aVVAs)
//
@ aPos[nLinAObj,1],(aPos[nLinAObj,4]/2)+5 GET oObsVV9 VAR cObsVV9 OF oMovTarefas MEMO SIZE (aPos[nLinAObj,4]/2)-7,aPos[nLinAObj,3]-aPos[nLinAObj,1] PIXEL READONLY MEMO
//



nCol := 8
nLinAObj++
If lPrePen
	@ aPos[ nLinAObj ,1]+3,nCol BITMAP oBran RESOURCE "BR_PINK" OF oMovTarefas NOBORDER SIZE 10,10 PIXEL
	oSay05 := TSay():New(aPos[ nLinAObj ,1]+3,nCol+10,{|| STR0047 },oMovTarefas,,,,,,.t.,CLR_BLUE,,100,8) // PrÈ-Pendente
	nCol += 80
Endif
@ aPos[ nLinAObj ,1]+3,nCol BITMAP oBran RESOURCE "BR_VERMELHO" OF oMovTarefas NOBORDER SIZE 10,10 PIXEL
oSay05 := TSay():New(aPos[ nLinAObj ,1]+3,nCol+10,{|| STR0004 },oMovTarefas,,,,,,.t.,CLR_BLUE,,100,8) // Pendente
nCol += 80
@ aPos[ nLinAObj ,1]+3,nCol BITMAP oAmar RESOURCE "BR_AMARELO" OF oMovTarefas NOBORDER SIZE 10,10 PIXEL
oSay06 := TSay():New(aPos[ nLinAObj ,1]+3,nCol+10,{|| STR0005 },oMovTarefas,,,,,,.t.,CLR_BLUE,,100,8) // Aprovado com restricoes

nLinAObj++
nCol := 8
@ aPos[ nLinAObj ,1]+3,nCol BITMAP oVerd RESOURCE "BR_VERDE" OF oMovTarefas NOBORDER SIZE 10,10 PIXEL
oSay07 := TSay():New(aPos[ nLinAObj ,1]+3,nCol+10,{|| STR0006 },oMovTarefas,,,,,,.t.,CLR_BLUE,,100,8) // Aprovado
nCol += 80
@ aPos[ nLinAObj ,1]+3,nCol BITMAP oPret RESOURCE "BR_PRETO" OF oMovTarefas NOBORDER SIZE 10,10 PIXEL
oSay08 := TSay():New(aPos[ nLinAObj ,1]+3,nCol+10,{|| STR0007 },oMovTarefas,,,,,,.t.,CLR_BLUE,,100,8) // Rejeitado
nCol += 80
@ aPos[ nLinAObj ,1]+3,nCol BITMAP oPret RESOURCE "BR_LARANJA" OF oMovTarefas NOBORDER SIZE 10,10 PIXEL
oSay09 := TSay():New(aPos[ nLinAObj ,1]+3,nCol+10,{|| STR0008 },oMovTarefas,,,,,,.t.,CLR_BLUE,,100,8) // Deletado pelo Usuario

nEspacamento := 7
nBtnSize := 40

nCol := aPos[ nLinAObj ,4] - aPos[ nLinAObj ,2] - ( 3 * nBtnSize ) - ( 2 * nEspacamento )
@ aPos[ nLinAObj ,1] + 2 , nCol BUTTON oBotVoltar PROMPT (STR0035) OF oMovTarefas SIZE nBtnSize,10 PIXEL ACTION FS_VOLTAR(aTarefas[oLbTarefas:nAt,10],aTarefas[oLbTarefas:nAt,12]) WHEN ( !lVisualAte .and. aTarefas[oLbTarefas:nAt,1] <> oBR_VERM ) // Volta Execucao

nCol := aPos[ nLinAObj ,4] - aPos[ nLinAObj ,2] - ( 2 * nBtnSize ) - ( nEspacamento )
@ aPos[ nLinAObj ,1] + 2 , nCol BUTTON oBotExec PROMPT (STR0020) OF oMovTarefas SIZE nBtnSize,10 PIXEL ACTION FS_EXECUTAR(aTarefas[oLbTarefas:nAt,10],aTarefas[oLbTarefas:nAt,12]) WHEN ( !lVisualAte .and. lBotExec ) // Executar

nCol := aPos[ nLinAObj ,4] - aPos[ nLinAObj ,2] - nBtnSize
@ aPos[ nLinAObj ,1]+2, nCol BUTTON oBotSAIR PROMPT (STR0025) OF oMovTarefas SIZE nBtnSize,10 PIXEL ACTION oMovTarefas:End() // SAIR

nCol := aPos[ nLinAObj ,4] - aPos[ nLinAObj ,2] - ( 3 * nBtnSize ) - ( 3 * nEspacamento )
@ aPos[ nLinAObj ,1]-3,nCol - 58 TO aPos[ nLinAObj ,1] + 15, nCol LABEL (" "+STR0033+" ") OF oMovTarefas PIXEL // Refresh Tela
@ aPos[ nLinAObj ,1]+3,nCol - 50 MSGET oTime VAR nTime PICTURE("99") VALID(nTime>=1.and.nTime<=99,oTimeS:NINTERVAL:=(1000*nTime),oTimeS:lActive:=.t.) SIZE 15,06 OF oMovTarefas PIXEL COLOR CLR_BLUE
oSay04 := TSay():New(aPos[ nLinAObj ,1] + 5,nCol - 30,{|| STR0034 },oMovTarefas,,,,,,.t.,CLR_BLUE,,_nSpc,8) // segundos


oTime:bGotFocus   := {|| oTimeS:lActive := .f. }
oTime:bLostFocus  := {|| oTimeS:lActive := .t. }

DEFINE TIMER oTimeS INTERVAL (1000*nTime) ACTION FS_FILTRO(1) OF oMovTarefas
oTimeS:lActive := .t.

ACTIVATE MSDIALOG oMovTarefas
DbSelectArea("VV9")
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥FS_BOTEXEC≥ Autor ≥  Andre Luis Almeida   ≥ Data ≥ 15/09/09 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Refresh no Botao Executar                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_BOTEXEC(_cTp)
lBotExec := .f.
If _cTp $ "02" // 0-Pendente / 2-Aprovado com restricoes
	lBotExec := .t.
EndIf
oBotExec:Refresh()
oBotExec:SetFocus()
oLbTarefas:SetFocus()
oLbTarefas:Refresh()
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥FS_FILTRO ≥ Autor ≥  Andre Luis Almeida   ≥ Data ≥ 15/09/09 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Filtra Tarefas                                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_FILTRO(_nTp)
Local ni         := 0
Local cQuery     := ""
Local cQAlVAY    := "SQLVAYX"
Local oTp        := oBR_BRAN
Local cTarefas   := ""
Local cAuxStat   := ""
Local nCont      := 0
Local oFilHelp   := DMS_FilialHelper():New()
Local aSM0       := oFilHelp:GetAllFilPermis(.f.)
Local cFilBkp    := cFilAnt
Local oSqlHlp    := DMS_SqlHelper():New()
Local cQueryExe := ""
Local lVAYORIGEM := VAY->(FieldPos("VAY_ORIGEM")) <> 0

Local aVAYORIGEMCBox := {}

aTarefas := {}
cConcat := oSqlHlp:Concat({"'%'", "VAY3.VAY_CODTAR", "'%'"})

For nCont := 1 to Len(aSM0)

	If Empty(cFilAte) .or. Alltrim(cFilAte) == Alltrim(aSM0[nCont])

		cFilAnt := aSM0[nCont]

		cQuery := "SELECT TEMP.* ,"
		If lVAYORIGEM
			cQuery += " CASE TEMP.VAY_ORIGEM WHEN '3' THEN VRJ.VRJ_CODCLI ELSE VV0.VV0_CODCLI END CODCLI ,"
			cQuery += " CASE TEMP.VAY_ORIGEM WHEN '3' THEN VRJ.VRJ_LOJA   ELSE VV0.VV0_LOJA   END LOJA ,"
			cQuery += " CASE TEMP.VAY_ORIGEM WHEN '3' THEN SA1VRJ.A1_NOME ELSE SA1.A1_NOME    END NOME ,"
			cQuery += " CASE TEMP.VAY_ORIGEM WHEN '3' THEN VRJ.VRJ_CODVEN ELSE VV0.VV0_CODVEN END CODVEN,"
			cQuery += " CASE TEMP.VAY_ORIGEM WHEN '3' THEN SA3VRJ.A3_NOME ELSE SA3.A3_NOME    END NOMVEM ,"
			cQuery += " CASE TEMP.VAY_ORIGEM WHEN '3' THEN VRJ.R_E_C_N_O_ ELSE VV9.R_E_C_N_O_ END RECORIGEM "
		Else
			cQuery += " VV0.VV0_CODCLI CODCLI, VV0.VV0_LOJA LOJA  , SA1.A1_NOME NOME , "
			cQuery += " VV0.VV0_CODVEN CODVEN, SA3.A3_NOME NOMVEM , VV9.R_E_C_N_O_ AS RECORIGEM "
		EndIf
		
		cQuery += " FROM ( "

		If !lPrePen

			cQuery += "SELECT VAY.VAY_STATUS , VAY.VAY_NUMIDE , VAY.VAY_CODTAR , "

			cQuery += "VAY.VAY_DATSOL , VAY.VAY_HORSOL , VAY.VAY_USUSOL , VAY.VAY_VALSOL , "
			cQuery += "VAY.VAY_DATEXE , VAY.VAY_HOREXE , VAY.VAY_USUEXE , VAY.VAY_VALLIB , "
			cQuery += "VAY.VAY_OBSTAR , VAY.VAY_SEQTAR , VAY.VAY_DATREA , VAX.VAX_DESTAR , "
			If lVAYORIGEM
				cQuery += " VAY.VAY_ORIGEM "
			Else 
				cQuery += " ' ' VAY_ORIGEM "
			EndIf
			cQuery += "FROM "+RetSqlName("VAY")+" VAY "
			cQuery += "JOIN "+RetSqlName("VAX")+" VAX ON ( VAX.VAX_FILIAL='"+xFilial("VAX")+"' AND VAY.VAY_CODTAR=VAX.VAX_CODTAR AND VAX.D_E_L_E_T_=' ' ) "
			//
			cQuery += "WHERE VAY.VAY_FILIAL='"+xFilial("VAY")+"' AND "

		Else

			cQueryExe := ;
				" ( SELECT CASE WHEN MIN(VAY3.VAY_DATEXE) is null THEN 'ERRADO' ELSE MIN(VAY3.VAY_DATEXE) END " +;
				    " FROM "+RetSqlName("VAY")+" VAY3 " +;
				   " WHERE VAY_FILIAL = VAY.VAY_FILIAL " +;
				     " AND VAY3.VAY_NUMIDE = VAY.VAY_NUMIDE " +;
				     " AND VAY3.VAY_STATUS <> '4' " +;
				     " AND VAX_REQTAR like "+cConcat+" ) "

			cQuery += "SELECT VAX_REQTAR,"
			cQuery +=       " VAY.VAY_STATUS , VAY.VAY_NUMIDE , VAY.VAY_CODTAR , "
			cQuery +=       " VAY.VAY_DATSOL , VAY.VAY_HORSOL , VAY.VAY_USUSOL , VAY.VAY_VALSOL , "
			cQuery +=       " VAY.VAY_DATEXE , VAY.VAY_HOREXE , VAY.VAY_USUEXE , VAY.VAY_VALLIB ,
			cQuery +=       " VAY.VAY_OBSTAR , VAY.VAY_SEQTAR , VAY.VAY_DATREA , VAX.VAX_DESTAR , "
			cQuery +=       cQueryExe + " AS PREPEN "
			If lVAYORIGEM
				cQuery += " , VAY.VAY_ORIGEM "
			Else 
				cQuery += " , ' ' VAY_ORIGEM "
			EndIf
			cQuery += "FROM "+RetSqlName("VAX")+" VAX "
			cQuery += "JOIN "+RetSqlName("VAY")+" VAY ON VAY_FILIAL = '"+xFilial("VAY")+"' AND VAY_CODTAR = VAX_CODTAR AND VAY.D_E_L_E_T_ = ' ' "
			//
			cQuery += "WHERE VAX_FILIAL = '"+xFilial("VAX")+"' AND VAX.D_E_L_E_T_ = ' ' AND "

		Endif

		If !Empty(cNumAte)
			If lVAYORIGEM
				cQuery += "VAY.VAY_ORIGEM IN (' ','1','2') AND " // Filtra Registros de Atendimento / Venda Direta
			EndIf
			cQuery += "VAY.VAY_NUMIDE = '" + PadR(cNumAte,TamSx3("VAY_NUMIDE")[1]," ") + "' AND "
		EndIf

		If lVAYORIGEM .and. !Empty(cNumPedV)
			cQuery += "VAY.VAY_ORIGEM = '3' AND " // Filtra Registros de Pedido de Venda de Montadora
			cQuery += "VAY.VAY_NUMIDE = '" + PadR(cNumPedV,TamSx3("VAY_NUMIDE")[1]," ") + "' AND "
		EndIf

		If !lVisualAte // Se nao estiver visualizando o atendimento, filtra somente as tarefas referentes ao usuario
			If VAI->(FieldPos("VAI_TAREXE")) <> 0
				VAI->(dbSetOrder(4))
				VAI->(dbSeek(xFilial("VAI")+__cUserID))
				If left(VAI->VAI_TAREXE,1) <> "*"
					cTarefas += "'*'"
					For ni := 1 to (len(VAI->VAI_TAREXE)/7)
						cTarefas += ",'"+substr(VAI->VAI_TAREXE,(ni*7)-6,6)+"'"
					Next
					cQuery += "VAY.VAY_CODTAR IN ("+cTarefas+") AND "
				EndIf
			EndIf
		EndIf

		If cStaTaref <> STR0002 // Todos
			Do Case
				Case lPrePen .and. cStaTaref == "3" // PrÈ-Pendente
					cQuery += "VAY.VAY_STATUS='0' AND " + cQueryExe + " = ' ' AND "

				Case lPrePen .and. cStaTaref == "1" // Em Aberto ( Pendente + Aprovado com restricoes )
					cQuery += "VAY.VAY_STATUS IN ('0','2') AND " + cQueryExe + " <> ' ' AND "

				Case cStaTaref == "1" // Em Aberto ( Pendente + Aprovado com restricoes )
					cQuery += "VAY.VAY_STATUS IN ('0','2') AND "

				Case lPrePen .and. cStaTaref == "2" // Pendente
					cQuery += "VAY.VAY_STATUS='0' AND " + cQueryExe + " <> ' ' AND "

				Case cStaTaref == "2" // Pendente
					cQuery += "VAY.VAY_STATUS='0' AND "

				Case cStaTaref == "5" // Aprovado
					cQuery += "VAY.VAY_STATUS='1' AND "

				Case cStaTaref == "4" // Aprovado com restricoes
					cQuery += "VAY.VAY_STATUS='2' AND "
					
				Case cStaTaref == "6" // Rejeitado
					cQuery += "VAY.VAY_STATUS='3' AND "
					
				Case cStaTaref == "7" // Deletado pelo Usuario
					cQuery += "VAY.VAY_STATUS='4' AND "
			EndCase
		EndIf

		If cTipDat == "1" // Solicitacao
			cQuery += "VAY.VAY_DATSOL >= '"+dtos(dDatIni)+"' AND VAY.VAY_DATSOL <= '"+dtos(dDatFin)+"' AND "
		ElseIf cTipDat == "2" // Execucao
			cQuery += "VAY.VAY_DATEXE >= '"+dtos(dDatIni)+"' AND VAY.VAY_DATEXE <= '"+dtos(dDatFin)+"' AND "
		EndIf
		cQuery += "VAY.D_E_L_E_T_ = ' '"

		cQuery += " ) TEMP "
	
		cQuery += "LEFT JOIN "+RetSqlName("VV9")+" VV9 ON VV9.VV9_FILIAL = '"+xFilial("VV9")+"' AND TEMP.VAY_ORIGEM IN (' ','1','2') AND VV9.VV9_NUMATE = TEMP.VAY_NUMIDE AND VV9.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN "+RetSqlName("VV0")+" VV0 ON VV0.VV0_FILIAL = '"+xFilial("VV0")+"' AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE AND VV0.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_COD = VV0.VV0_CODCLI AND SA1.A1_LOJA = VV0.VV0_LOJA AND SA1.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN "+RetSqlName("SA3")+" SA3 ON SA3.A3_FILIAL = '"+xFilial("SA3")+"' AND SA3.A3_COD = VV0.VV0_CODVEN AND SA3.D_E_L_E_T_ = ' ' "

		If lVAYORIGEM .and. FWAliasInDic("VRJ", .f.)
			cQuery += "LEFT JOIN "+RetSqlName("VRJ")+" VRJ ON VRJ.VRJ_FILIAL = '"+xFilial("VRJ")+"' AND TEMP.VAY_ORIGEM = '3' AND VRJ.VRJ_PEDIDO = TEMP.VAY_NUMIDE AND VRJ.D_E_L_E_T_ = ' ' "
			cQuery += "LEFT JOIN "+RetSqlName("SA1")+" SA1VRJ ON SA1VRJ.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1VRJ.A1_COD = VRJ.VRJ_CODCLI AND SA1VRJ.A1_LOJA = VRJ.VRJ_LOJA AND SA1VRJ.D_E_L_E_T_ = ' ' "
			cQuery += "LEFT JOIN "+RetSqlName("SA3")+" SA3VRJ ON SA3VRJ.A3_FILIAL = '"+xFilial("SA3")+"' AND SA3VRJ.A3_COD = VRJ.VRJ_CODVEN AND SA3VRJ.D_E_L_E_T_ = ' ' "
		EndIf
		
		cQuery += " ORDER BY TEMP.VAY_NUMIDE , TEMP.VAY_CODTAR"

		If Select(cQAlVAY) > 0
		  ( cQAlVAY )->( DbCloseArea() )
		EndIf

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAY , .F., .T. )
		While !( cQAlVAY )->( Eof() )
			oTp      := oBR_BRAN
			cAuxStat := ""
			Do Case
				Case lPrePen .and. ( cQAlVAY )->( VAY_STATUS ) == "0"	.and. Empty( ( cQAlVAY )->PREPEN )	// PrÈ-Pendente
					oTp      := oBR_PINK
					cAuxStat := STR0047 // PrÈ-Pendente

				Case ( cQAlVAY )->( VAY_STATUS ) == "0"	// Pendente
					oTp      := oBR_VERM
					cAuxStat := STR0004 // Pendente

				Case ( cQAlVAY )->( VAY_STATUS ) == "1"	// Aprovado
					oTp      := oBR_VERD
					cAuxStat := STR0006 // Aprovado

				Case ( cQAlVAY )->( VAY_STATUS ) == "2"	// Aprovado com restricoes
					oTp      := oBR_AMAR
					cAuxStat := STR0005 // Aprovado com restricoes

				Case ( cQAlVAY )->( VAY_STATUS ) == "3"	// Rejeitado
					oTp      := oBR_PRET
					cAuxStat := STR0007 // Rejeitado

				Case ( cQAlVAY )->( VAY_STATUS ) == "4"	// Deletado pelo Usuario
					oTp      := oBR_LARA
					cAuxStat := STR0008 // Deletado pelo Usuario
			EndCase

			If lVAYORIGEM .and. !Empty( (cQAlVAY)->VAY_ORIGEM )
				cVAYORIGEM := X3CBOXDESC( "VAY_ORIGEM", (cQAlVAY)->VAY_ORIGEM, @aVAYORIGEMCBox)
			Else
				cVAYORIGEM := ""
			EndIf

			AAdd( aTarefas , {	oTp , ; // 01
								( cQAlVAY )->( VAY_NUMIDE ) , ; // 02
								( cQAlVAY )->( VAY_CODTAR )+" - "+( cQAlVAY )->( VAX_DESTAR ) , ; // 03
								( cQAlVAY )->( VAY_STATUS )+" - "+cAuxStat , ; // 04
								Transform(stod(( cQAlVAY )->( VAY_DATSOL )),"@D")+" "+Transform(( cQAlVAY )->( VAY_HORSOL ),"@R 99:99")+STR0027+" - "+( cQAlVAY )->( VAY_USUSOL ) , ; // 05
								( cQAlVAY )->( VAY_VALSOL ) , ; // 06
								Transform(stod(( cQAlVAY )->( VAY_DATEXE )),"@D")+" "+Transform(( cQAlVAY )->( VAY_HOREXE ),"@R 99:99")+STR0027+" - "+( cQAlVAY )->( VAY_USUEXE ) , ;  // 07
								( cQAlVAY )->( VAY_VALLIB ) , ; // 08
								( cQAlVAY )->( VAY_OBSTAR ) , ; // 09
								( cQAlVAY )->( VAY_SEQTAR ) ,; // 10
								transform(stod(( cQAlVAY )->( VAY_DATREA )),"@D"),; // 11
								cFilAnt ,; // 12
								( cQAlVAY )->( CODVEN )+" - "+( cQAlVAY )->( NOMVEM ) ,; // 13
								( cQAlVAY )->( CODCLI )+"-"+( cQAlVAY )->( LOJA )+" "+( cQAlVAY )->( NOME ) ,; // 14
								( cQAlVAY )->RECORIGEM ,; // 15
								cVAYORIGEM,; // 16
								(cQAlVAY)->VAY_ORIGEM }) // 17

			( cQAlVAY )->( DbSkip() )
		EndDo
		( cQAlVAY )->( dbCloseArea() )
		DBSelectArea("VAY")
	EndIf
Next
//
If len(aTarefas) <= 0
	AAdd( aTarefas , {;
		oTp,; // 01
		"",; // 02
		"",; // 03
		space(10),; // 04
		"",; // 05
		"",; // 06
		"",; // 07
		0,; // 08
		"",; // 09
		0,; // 10
		"",; // 11
		"",; // 12
		"",; // 13
		"",; // 14
		0,; // 15
		"",; // 16
		"" }) // 17
EndIf
If _nTp > 0
	oLbTarefas:nAt := 1
	oLbTarefas:SetArray(aTarefas)
		
	FS_BOTEXEC(left(aTarefas[1,4],1))
EndIf

cFilAnt := cFilBkp

Return()

Static Function VEIM130VisualizaOrigem(aAuxTarefa)

	If lVisualAte
		Return .t.
	EndIf

	Do Case
		// Atendimento
		Case Empty(aAuxTarefa[14]) .or. aAuxTarefa[14] == "1"
			FS_ATENDIM(aAuxTarefa[2], aAuxTarefa[12])

		// Pedido de Venda - Montadora
		Case  aAuxTarefa[14] == "3"
			VEIM130PedVendaMontadora(aAuxTarefa[12], aAuxTarefa[2])
	EndCase

Return .t.

Static Function VEIM130PedVendaMontadora(cFilPedV, cNumPedV)

	Local cFilBkp   := cFilAnt
	Local oExecView

	cFilAnt := cFilPedV

	DbSelectArea("VRJ")
	VRJ->(dbSetOrder(1))
	If ! VRJ->(dbSeek(xFilial("VRJ") + cNumPedV))
		MsgInfo("Pedido n„o encontrado")
		Return .t.
	EndIf

	oExecView := FWViewExec():New()
	oExecView:setSource("VEIA060")
	oExecView:setOperation(MODEL_OPERATION_VIEW)
	oExecView:openView(.F.)
		
	cFilAnt := cFilBkp

Return .t.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥FS_ATENDIM≥ Autor ≥  Andre Luis Almeida   ≥ Data ≥ 15/09/09 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Visualiza Atendimento                                      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_ATENDIM(_cAtend,cFilAtend)
Local cFilBkp   := cFilAnt
Private Inclui  := .f. // Variavel INTERNA utilizada no VEIVM011
Private Altera  := .f. // Variavel INTERNA utilizada no VEIVM011
Private lEmiNfi := .t. // Variavel INTERNA utilizada no VEIVM011
Private lNegPag := .t. // Variavel INTERNA utilizada no VEIVM011
Private lLibVei := .f. // Variavel INTERNA utilizada no VEIVM011
Private lAutFat := .f. // Variavel INTERNA utilizada no VEIVM011
Private _lVerBotoes := .f. // Variavel INTERNA utilizada no VEIVM011
Private cCampo := ""
Private nOpc := 2
Private bFiltraBrw := {|| Nil}
Private aCampos := {}
Private cCadastro := (STR0011) //  Atendimento
Private aNewBot := {}
Private aRotina := {{"","PesqV011", 0, 1},;
{"","ATEND011", 0, 2},;
{"","ATEND011", 0, 3},;
{"","ATEND011", 0, 4},;
{"","ATEND011", 0, 5}}
If !Empty(_cAtend)
	cFilAnt := cFilAtend
	DbSelectArea("VV9")
	DbSetOrder(1)
	If DbSeek( xFilial("VV9") + left(_cAtend,TamSx3("VV9_NUMATE")[1]) )
		If !FM_PILHA("VEIXX002") .and. !FM_PILHA("VEIXX030")
			VEIXX002(NIL,NIL,NIL,2,)
		EndIf
	EndIf
	cFilAnt := cFilBkp
EndIf
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥FS_EXECUTAR≥ Autor ≥  Andre Luis Almeida  ≥ Data ≥ 15/09/09 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Executa Tarefa                                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_EXECUTAR(cSeqTar,cFilAtend)
Local cRStatus    := "5" // Aprovado
Local aRStatus    := {"5="+STR0006,"4="+STR0005,"6="+STR0007} // Aprovado / Aprovado com restricoes / Rejeitado
Local nRValLib    := 0
Local nRValSol    := 0
Local cRObsTar    := space(TamSX3("VAY_OBSTAR")[1])
Local dDtRealiz   := ctod("")
Local nPos        := 0
Local ni          := 0
Local cTp         := "0"
Local lOk         := .f.
Local nRecVVA     := 0
Local cQuery      := ""
Local cSQLVVA     := "SQLVVA"
Local cQAlVAY     := "SQLVAY"
Local aTarAtend   := {} // Tarefas do Atendimento
Local cBkpFil     := cFilAnt
Local lW_DATREA   := .t.
Local dR_DATREA   := ctod("")
Default cFilAtend := xFilial("VAY")

DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek("VAY_DATREA")
	If !Empty(SX3->X3_WHEN)
		lW_DATREA := &(SX3->X3_WHEN)
	EndIf
	If !Empty(SX3->X3_RELACAO)
		dR_DATREA := &(SX3->X3_RELACAO)
	EndIf
EndIf
DbSelectArea("VAY")

if !Empty(cFilAtend)
	cFilAnt := cFilAtend
Endif

If !Empty(cSeqTar)
	DbSelectArea("VAY")
	DbSetOrder(1)
	If DbSeek( xFilial("VAY") + cSeqTar ) // Posciona na Tarefa a ser executada
		nRValSol :=	VAY->VAY_VALSOL
		If VAY->VAY_STATUS == "2"
			cRStatus := "4" // Aprovado com restricoes
			nRValLib :=	VAY->VAY_VALLIB
		EndIf
		cRObsTar  := VAY->VAY_OBSTAR
		dDtRealiz := VAY->VAY_DATREA
		If Empty(dDtRealiz) .and. !Empty(dR_DATREA)
			dDtRealiz := dR_DATREA
		EndIf
		DbSelectArea("VAX")
		DbSetOrder(1)
		DbSeek( xFilial("VAX") + VAY->VAY_CODTAR )
		// Verificar se a tarefa possui pre requisito //
		If !Empty(left(VAX->VAX_REQTAR,6))

			// Levantar Tarefas no Atendimento //
			cQuery := "SELECT VAY.VAY_CODTAR , VAY.VAY_STATUS , VAY.VAY_VALSOL , VAY.VAY_VALLIB , VAX.VAX_TARBLQ , VAX.VAX_TIPPAG , VAX.VAX_REQTAR , VAX.VAX_BLQENT , VAX.VAX_BLQAPR " +;
				" FROM "+RetSqlName("VAY")+" VAY , "+RetSqlName("VAX")+" VAX " +;
				" WHERE VAY.VAY_FILIAL='"+xFilial("VAY")+"'" +;
				" AND VAY.VAY_NUMIDE='"+VAY->VAY_NUMIDE+"'" +;
				" AND VAY.VAY_STATUS<>'4'" +;
				" AND VAX.VAX_FILIAL='"+xFilial("VAX")+"'" +;
				" AND VAY.VAY_CODTAR=VAX.VAX_CODTAR" +;
				" AND VAY.D_E_L_E_T_=' '" +;
				" AND VAX.D_E_L_E_T_=' '"
			If lVAYORIGEM
				If VAY->VAY_ORIGEM == '3'
					cQuery += " AND VAY.VAY_ORIGEM = '" + cVAYORIGEM + "'"
				Else
					cQuery += " AND VAY.VAY_ORIGEM IN (' ','1','2') " // Filtra Registros de Atendimento / Venda Direta
				EndIf
			EndIf
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAY , .F., .T. )
			While !( cQAlVAY )->( Eof() )

				aadd(aTarAtend,{ ;
					( cQAlVAY )->( VAY_CODTAR ) ,;
					( cQAlVAY )->( VAY_STATUS ) ,;
					( cQAlVAY )->( VAX_TARBLQ ) ,;
					( cQAlVAY )->( VAX_TIPPAG ) ,;
					( cQAlVAY )->( VAX_REQTAR ) ,;
					( cQAlVAY )->( VAY_VALSOL ) ,;
					( cQAlVAY )->( VAY_VALLIB ) ,;
					( cQAlVAY )->( VAX_BLQENT ) ,;
					( cQAlVAY )->( VAX_BLQAPR ) })

				( cQAlVAY )->( DbSkip() )
			EndDo
			( cQAlVAY )->( dbCloseArea() )
			DbSelectArea("VAX")

			For ni := 1 to (len(VAX->VAX_REQTAR)/7)

				If !Empty(substr(VAX->VAX_REQTAR,(ni*7)-6,6))

					nPos := aScan(aTarAtend,{|x| x[1] == substr(VAX->VAX_REQTAR,(ni*7)-6,6) })
					If nPos == 0 .or. !aTarAtend[nPos,2] $ "12" // Diferente de Aprovado / Aprovado com restricoes
						MsgStop(STR0042,STR0032) // Impossivel executar a Tarefa! Existe(m) pre-requisito(s) nao aprovado(s). / Atencao
						cFilAnt := cBkpFil
						Return()
					EndIf

				EndIf

			Next
		EndIf
		If !Empty(VAX->VAX_FUNCAO) // Executa FUNCAO do cadastro de Tarefa
			If "(" $ VAX->VAX_FUNCAO
				&(Alltrim(VAX->VAX_FUNCAO))
			Else
				&(Alltrim(VAX->VAX_FUNCAO)+"()")
			EndIf
		EndIf
		If VAX->VAX_EXEPAD == "1" // Tela Padrao de Tarefa a executar
			DbSelectArea("VAY")
			DbSetOrder(1)
			DbSeek( xFilial("VAY") + cSeqTar )
			DEFINE MSDIALOG oExecPrad FROM 000,000 TO 009,070 TITLE (STR0024+": "+VAX->VAX_CODTAR+" - "+Alltrim(VAX->VAX_DESTAR)) OF oMainWnd // Tarefa a Executar
			@ 004,007 TO 060,270 LABEL (" "+Alltrim(UPPER(UsrRetName(__CUSERID)))+" - "+STR0011+": "+Alltrim(VAY->VAY_NUMIDE)+" ") OF oExecPrad PIXEL // Atendimento
			@ 016,014 SAY STR0021 SIZE 50,08 OF oExecPrad PIXEL COLOR CLR_BLUE // Novo Status
			@ 015,055 COMBOBOX oRStatus VAR cRStatus ITEMS aRStatus VALID IIf(cRStatus<>"4",nRValLib:=0,.t.) SIZE 100,8 PIXEL OF oExecPrad // Aprovado com restricoes
			@ 016,157 SAY STR0044 SIZE 50,08 OF oExecPrad PIXEL COLOR CLR_BLUE // Data Realizacao
			@ 015,205 MSGET oDtRealiz VAR dDtRealiz PICTURE "@D" SIZE 60,08 OF oExecPrad PIXEL COLOR CLR_BLUE WHEN lW_DATREA
			@ 030,013 SAY STR0022 SIZE 50,08 OF oExecPrad PIXEL COLOR CLR_BLUE // Observacao
			@ 029,055 MSGET oRObsTar VAR cRObsTar PICTURE "@!" SIZE 209,08 OF oExecPrad PIXEL COLOR CLR_BLUE
			@ 044,013 SAY STR0026 SIZE 50,08 OF oExecPrad PIXEL COLOR CLR_BLUE // Valor Solicitado
			@ 043,055 MSGET oRValSol VAR nRValSol PICTURE "@E 999,999,999.99" SIZE 50,08 OF oExecPrad PIXEL COLOR CLR_BLUE WHEN .f.
			@ 044,115 SAY STR0019 SIZE 50,08 OF oExecPrad PIXEL COLOR CLR_BLUE // Valor Liberado
			@ 043,158 MSGET oRValLib VAR nRValLib VALID ( nRValLib > 0 ) PICTURE "@E 999,999,999.99" SIZE 50,08 OF oExecPrad PIXEL COLOR CLR_BLUE WHEN ( cRStatus == "4" )
			@ 044,223 BUTTON oOK PROMPT STR0023 OF oExecPrad SIZE 40,10 PIXEL ACTION (lOk:=.t.,oExecPrad:End()) // OK
			ACTIVATE MSDIALOG oExecPrad CENTER
			If lOk

				If ( ExistBlock("VM130AET") )
					If !(ExecBlock("VM130AET",.F.,.F.,{cRStatus, dDtRealiz, nRValSol, nRValLib}))
						return .f.
					EndIf
				EndIf

				If cRStatus == "5" // Aprovado
					cTp := "1"
					If VAX->(FieldPos("VAX_LIBERA")) <> 0
						If VAX->VAX_LIBERA <> "0"
							nRecVVA := VVA->(RecNo())
							cQuery := "SELECT VVA.R_E_C_N_O_ VVARECNO FROM "+RetSQLName("VVA")+" VVA WHERE "
							cQuery += "VVA.VVA_FILIAL='"+xFilial("VVA")+"' AND VVA.VVA_NUMTRA='"+left(VAY->VAY_NUMIDE+space(20),TamSx3("VVA_NUMTRA")[1])+"' AND VVA.D_E_L_E_T_=' '"
							dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLVVA , .F. , .T. )
							While !( cSQLVVA )->( Eof() )
								DbSelectArea("VVA")
								DbGoTo(( cSQLVVA )->( VVARECNO ))
								RecLock("VVA",.F.)
								If VAX->VAX_LIBERA == "1" // Liberar para Faturamento
									VVA->VVA_DTLIBF := dDataBase // Data da Liberacao
								ElseIf VAX->VAX_LIBERA == "2" // Liberar para Entrega
									VVA->VVA_DTLIBE := dDataBase // Data da Liberacao
								EndIf
								MsUnlock()
								( cSQLVVA )->( DbSkip() )
							EndDo
							( cSQLVVA )->( dbCloseArea() )
							If nRecVVA > 0
								VVA->(DbGoTo(nRecVVA))
							EndIf
							DbSelectArea("VAY")
						EndIf
					EndIf
				ElseIf cRStatus == "4" // Aprovado com restricoes
					cTp := "2"
				ElseIf cRStatus == "6" // Rejeitado
					cTp := "3"
				EndIf
				DbSelectArea("VAY")
				RecLock("VAY",.f.)
				VAY->VAY_STATUS := cTp
				VAY->VAY_VALLIB := nRValLib
				VAY->VAY_OBSTAR := cRObsTar
				if !Empty(dDtRealiz)
					VAY->VAY_DATREA := dDtRealiz
				Else
					VAY->VAY_DATREA := dDatabase
				Endif
				VAY->VAY_USUEXE := __cUserID
				VAY->VAY_DATEXE := dDataBase
				VAY->VAY_HOREXE := Val(Substr(Time(),1,2)+Substr(Time(),4,2))
				MsUnLock()

				// PONTO DE ENTRADA no final depois execuÁ„o da tarefa (aprovaÁ„o ou n„o).
				If ExistBlock("VM130DET")
					ExecBlock("VM130DET",.f.,.f.)
				EndIf

			EndIf
		EndIf
		FS_FILTRO(1)
	EndIf
EndIf

cFilAnt := cBkpFil

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ FS_VOLTAR ≥ Autor ≥  Andre Luis Almeida  ≥ Data ≥ 15/09/09 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Volta Execucao da Tarefa                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_VOLTAR(cSeqTar,cFilAtend)
Local ni      := 0
Local nRecVAX := 0
Local cQuery  := ""
Local cSQLVAX := "SQLVAX"
Local cSQLVAY := "SQLVAY"
Local cBkpFil     := cFilAnt

Local lVAXORIGEM := VAX->(FieldPos("VAX_ORIGEM")) <> 0
Local lVAYORIGEM := VAY->(FieldPos("VAY_ORIGEM")) <> 0

Default cFilAtend := xFilial("VAY")

FWClearHlp()

if !Empty(cFilAtend)
	cFilAnt := cFilAtend
Endif

If !Empty(cSeqTar)
	DbSelectArea("VAY")
	DbSetOrder(1)

	If DbSeek( xFilial("VAY") + cSeqTar ) // Posciona na Tarefa a ser executada (VOLTA)

		cVAYORIGEM :=  IIf( lVAYORIGEM , VAY->VAY_ORIGEM , "" )

		DbSelectArea("VAX")
		DbSetOrder(1)
		DbSeek( xFilial("VAX") + VAY->VAY_CODTAR )

		If VAX->VAX_VOLTAR <> "1"
			cFilAnt := cBkpFil
			FMX_HELP("VM130ERR002",STR0036+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0038) // Impossivel voltar a execucao da Tarefa! / Esta tarefa n„o permite voltar a execucao! / Atencao
			Return()
		EndIf

		If VAX->VAX_BLQAPR == "1" // Tarefa Bloqueia Aprovacao do Atendimento
			If VM130001_StatusOrigem(cVAYORIGEM, VAY->VAY_NUMIDE) == "L"
				FMX_HELP("VM130ERR003",STR0036+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0043) // Impossivel voltar a execucao da Tarefa! / Esta tarefa bloqueia a aprovacao de um Atendimento que ja foi aprovado! / Atencao
				cFilAnt := cBkpFil
				Return()
			EndIf
		EndIf
		If VAX->VAX_TARBLQ == "1" // Tarefa Bloqueia Faturamento
			If VM130001_StatusOrigem(cVAYORIGEM, VAY->VAY_NUMIDE) == "F"
				FMX_HELP("VM130ERR004", STR0036+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0039) // Impossivel voltar a execucao da Tarefa! / Esta tarefa bloqueia a finalizacao de um Atendimento que ja foi finalizado! / Atencao
				cFilAnt := cBkpFil
				Return()
			EndIf
		EndIf
		If VAX->VAX_BLQENT == "1" // Tarefa Bloqueia Entrega
		
			If VM130002_VeiculoEntregue(cVAYORIGEM, VAY->VAY_NUMIDE)
				FMX_HELP("VM130ERR005"+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0040,STR0032) // Impossivel voltar a execucao da Tarefa! /	Esta tarefa bloqueia a entrega de um Veiculo que ja foi entregue! / Atencao
				cFilAnt := cBkpFil
				Return()
			EndIf
		EndIf

		If VAY->VAY_STATUS $ "1/2" // 1=Aprovado / 2=Aprovado com restricoes

			nRecVAX := VAX->(RecNo())
			// Verifica em quais tarefas existe como pre-requisito a Tarefa em questao
			cQuery := "SELECT VAX.R_E_C_N_O_ RECVAX " +;
				"FROM " + RetSqlName("VAX") + " VAX" +;
				" WHERE VAX.VAX_FILIAL='"+xFilial("VAX")+"'" +;
				  " AND VAX.VAX_REQTAR LIKE '%"+ VAY->VAY_CODTAR +"%'" +;
				  " AND VAX.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLVAX , .F. , .T. )
			While !( cSQLVAX )->( Eof() )

				VAX->(DbGoTo(( cSQLVAX )->( RECVAX )))

				// Verifica se as tarefas que precisam do pre-requisito nao esta Aprovada ou Aprovada com restricoes
				cQuery := "SELECT VAY.R_E_C_N_O_ RECVAY " +;
					" FROM " + RetSqlName("VAY") + " VAY" +;
					" WHERE VAY.VAY_FILIAL = '" + xFilial("VAY") + "' " +;
					  " AND VAY.VAY_CODTAR = '" + VAX->VAX_CODTAR + "'" +;
					  " AND VAY.VAY_NUMIDE = '" + VAY->VAY_NUMIDE + "'" +;
					  " AND VAY.VAY_STATUS IN ('1','2') " +;
					  " AND VAY.D_E_L_E_T_=' '"
				If lVAYORIGEM
					If cVAYORIGEM == '3'
						cQuery += " AND VAY.VAY_ORIGEM = '" + cVAYORIGEM + "'"
					Else
						cQuery += " AND VAY.VAY_ORIGEM IN (' ','1','2') " // Filtra Registros de Atendimento / Venda Direta
					EndIf
				EndIf
				If FM_SQL(cQuery) > 0
					VAX->(DbGoTo(nRecVAX))
					FMX_HELP("VM130ERR006",STR0036+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0041) // Impossivel voltar a execucao da Tarefa! / Existe(m) tarefa(s) Aprovada(s), a(s) qual(is) esta tarefa È pre-requisito. / Atencao
					cFilAnt := cBkpFil
					( cSQLVAX )->( dbCloseArea() )
					dbSelectArea("VAX")
					Return()
				EndIf
				( cSQLVAX )->( DbSkip() )
			EndDo
			( cSQLVAX )->( dbCloseArea() )
			dbSelectArea("VAX")
			VAX->(DbGoTo(nRecVAX))
			DbSelectArea("VAY")
		EndIf

		If !Empty(VAX->VAX_FUNVOL) // Executa (VOLTA) FUNCAO do cadastro de Tarefa
			If "(" $ VAX->VAX_FUNVOL
				&(Alltrim(VAX->VAX_FUNVOL))
			Else
				&(Alltrim(VAX->VAX_FUNVOL)+"()")
			EndIf
		EndIf

		DbSelectArea("VAY")
		RecLock("VAY",.f.)
		VAY->VAY_STATUS := "0" // 0=Pendente
		VAY->VAY_VALLIB := 0
		VAY->VAY_OBSTAR := ""
		VAY->VAY_USUEXE := ""
		VAY->VAY_DATEXE := ctod("")
		VAY->VAY_HOREXE := 0
		MsUnLock()
		FS_FILTRO(1)
	EndIf
EndIf
cFilAnt := cBkpFil

Return()

/*/{Protheus.doc} VEIVM130TAR

Funcao chamada de dentro do Atendimento / Pedido de Venda Atacado

_cMoment = 0A - Verifica/Valida Aprovacao
         = 0F - Verifica/Valida Finalizacao
         = E  - Verifica/Valida Entrega Veiculo
         = 1  - Cria Tarefa na Gravacao do Atendimento
         = 2  - Cria Tarefa na Finalizacao do Atendimento
         = 3  - Cria Tarefa chamada pelo Usuario (menu F10)
         = 4  - Cria Tarefa no status Pendente Aprovacao
         = 5  - Cria Tarefa no status Pre-Aprovado
         = 6  - Cria Tarefa no status Aprovado
         = 7  - Cria Tarefa na Reserva
         = 8  - Cria Tarefa no Cancelamento da Reserva
         = 9  - Cria Tarefa no Cancelamento do Atendimento

_cOrigem = 1  - Atendimento Normal
         = 2  - Faturamento Direto
         = 3  - Pedido de Venda Atacado


@author Andre Luis Almeida
@since 15/09/2019
@version 1.0
@return lRet, Indica se foi possivel continuar
@param _cAtend, characters, Numero do Atendimento / Pedido de Venda Atacado
@param _cMoment, characters, Momento da chamada da funcao
@param _cOrigem, characters, Origem da chamada
@param cFilAtend, characters, Filial do Atendimento
@param lVM130Auto, logical, Indica se a chamada foi realizada por uma rotina em ExecAuto 
@type function
/*/
Function VEIVM130TAR(_cAtend,_cMoment,_cOrigem,cFilAtend,lVM130Auto,_cTipVen,_cCodMar)
Local aTarAtend := {} // Tarefas do Atendimento
Local aControle := {} // Controle de Tarefas a serem chamadas
Local aVS9SeqTar:= {} // Sequencia Tarefa no VS9
Local oBran   := LoadBitmap( GetResources(), "BR_BRANCO" )
Local oVerd   := LoadBitmap( GetResources(), "BR_VERDE" )
Local oAzul   := LoadBitmap( GetResources(), "BR_AZUL" )
Local lRet    := .t.
Local cTip    := "0"
Local nVlr    := 0
Local nRecVS9 := 0
Local ni      := 0
Local nPos    := 0
Local lOk     := .t.
Local cTSqTar := "" // Todas as Seq.Tarefas
Local cVV1_ESTVEI := "2"
Local cQuery  := ""
Local cQAlVAY := "SQLVAY"
Local cQAlVAX := "SQLVAX"
Local cQAlVV1 := "SQLVV1"
Local lVAXORIGEM := VAX->(FieldPos("VAX_ORIGEM")) <> 0
Local lVAXCODMAR := VAX->(FieldPos("VAX_CODMAR")) <> 0
Local lVAXTIPVEN := VAX->(FieldPos("VAX_TIPVEN")) <> 0
Local lVAYORIGEM := VAY->(FieldPos("VAY_ORIGEM")) <> 0

Private aTarPoss := {} // Tarefas Possiveis
Private lMarcarT := .f.
Default _cAtend  := VV0->VV0_NUMTRA // Nro do Atendimento
Default _cMoment := "0F"
Default _cOrigem := "1"
Default cFilAtend := xFilial("VAY")
Default lVM130Auto := .f.
Default _cCodMar := ""
Default _cTipVen := ""

DbSelectArea("VAX")

// Levanta o Estado do Veiculo ( Novo / Usado ) //
cVV1_ESTVEI := "0"
cQuery := "SELECT VV1.VV1_ESTVEI "
cQuery +=  " FROM "+RetSqlName("VVA")+" VVA "
cQuery +=         " JOIN "+RetSqlName("VV1")+" VV1 "
cQuery +=                "  ON VV1.VV1_FILIAL = '"+xFilial("VV1")+"'"
cQuery +=                " AND VV1.VV1_CHAINT = VVA.VVA_CHAINT "
cQuery +=                " AND VV1.D_E_L_E_T_ = ' '"
cQuery += " WHERE VVA.VVA_FILIAL='"+xFilial("VVA")+"' "
cQuery +=   " AND VVA.VVA_NUMTRA='"+left(_cAtend+space(20),TamSx3("VVA_NUMTRA")[1])+"'"
cQuery +=   " AND VVA.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVV1 , .F., .T. )
If !( cQAlVV1 )->( Eof() )
	cVV1_ESTVEI := ( cQAlVV1 )->( VV1_ESTVEI )
EndIf
( cQAlVV1 )->( dbCloseArea() )


DbSelectArea("VAY")
// Levantar Tarefas no Atendimento //
cQuery := "SELECT VAY.VAY_CODTAR , VAY.VAY_STATUS , VAY.VAY_VALSOL , VAY.VAY_VALLIB , VAX.VAX_TARBLQ , VAX.VAX_TIPPAG , VAX.VAX_REQTAR , VAX.VAX_BLQENT , VAX.VAX_BLQAPR, VAX.VAX_ORIGEM "
cQuery += " FROM "+RetSqlName("VAY")+" VAY , "+RetSqlName("VAX")+" VAX "
cQuery += " WHERE VAY.VAY_FILIAL = '"+cFilAtend+"'"
cQuery +=   " AND VAY.VAY_NUMIDE = '"+left(_cAtend+space(20),TamSx3("VAY_NUMIDE")[1])+"'"
cQuery +=   " AND VAY.VAY_STATUS <>'4'"
cQuery +=   " AND VAX.VAX_FILIAL = '"+xFilial("VAX")+"'"
if lVAYORIGEM .and. !Empty(_cOrigem)
	If _cOrigem == '3'
		cQuery += " AND VAY.VAY_ORIGEM = '" + _cOrigem + "'" // Filtra registros de Pedido de Venda Montadora
	Else
		cQuery += " AND VAY.VAY_ORIGEM IN (' ','1','2') " // Filtra Registros de Atendimento / Venda Direta
	EndIf
Endif
cQuery += " AND VAY.VAY_CODTAR = VAX.VAX_CODTAR"
cQuery += " AND VAY.D_E_L_E_T_ = ' '"
cQuery += " AND VAX.D_E_L_E_T_ = ' '"

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAY , .F., .T. )
While !( cQAlVAY )->( Eof() )
	aadd(aTarAtend,{ ;
		( cQAlVAY )->( VAY_CODTAR ) ,; // 01
		( cQAlVAY )->( VAY_STATUS ) ,; // 02
		( cQAlVAY )->( VAX_TARBLQ ) ,; // 03
		( cQAlVAY )->( VAX_TIPPAG ) ,; // 04
		( cQAlVAY )->( VAX_REQTAR ) ,; // 05
		( cQAlVAY )->( VAY_VALSOL ) ,; // 06
		( cQAlVAY )->( VAY_VALLIB ) ,; // 07
		( cQAlVAY )->( VAX_BLQENT ) ,; // 08
		( cQAlVAY )->( VAX_BLQAPR ) ,; // 09
		( cQAlVAY )->( VAX_ORIGEM ) }) // 10
	( cQAlVAY )->( DbSkip() )
EndDo
( cQAlVAY )->( dbCloseArea() )
DbSelectArea("VAY")
//
If _cMoment == "0A" .or. _cMoment == "0F" .or. _cMoment == "E"
	//////////////////////////////////////////////////////////////////////////////
	// Verifica/Valida: 0A - Aprovacao / 0F - Finalizacao / E - Entrega Veiculo //
	//////////////////////////////////////////////////////////////////////////////
	// Validar todas as tarefas do Atendimento quando existem Tarefas com restricoes ( BLOQUEIA Aprovacao ou Finalizacao? 1=SIM )
	For ni := 1 to len(aTarAtend)
		// Tarefa:   BLOQUEIA Aprovacao?   ou   BLOQUEIA Finalizacao?   ou   BLOQUEIA Entrega?    1=SIM
		If ( _cMoment == "0A" .and. aTarAtend[ni,9] == "1" ) .or. ( _cMoment == "0F" .and. aTarAtend[ni,3] == "1" ) .or. ( _cMoment == "E" .and. aTarAtend[ni,8] == "1" )
			If aTarAtend[ni,2] $ "03" .or. ( aTarAtend[ni,2]=="2" .and. aTarAtend[ni,6]<aTarAtend[ni,7] ) // Pendente / Rejeitado / Aprovado com restricoes
				lRet := .f.
				FMX_HELP("VM130ERR001", STR0031) // Existe(m) tarefa(s) NAO Aprovada(s) para o Atendimento. Impossivel continuar! / Atencao
				If ! lVM130Auto
					VEIVM130(_cAtend,cFilAtend,_cOrigem)
				EndIf
				Exit
			EndIf
		EndIf
	Next
Else
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Criacao ( 1-Gravacao / 2-Finalizacao / 3-Pelo Usuario / 4-Pendente Aprovacao / 5-Pre-Aprovado / 6-Aprovado / 7-Reserva / 8-Cancela Reserva / 9-Cancela Atendimento ) //
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Levanta todas as Tarefas Possiveis //
	cQuery := "SELECT VAX.VAX_CODTAR , VAX.VAX_CONDCH , VAX.VAX_REQTAR, VAX.VAX_OBRIGA , VAX.VAX_TIPPAG , VAX.VAX_DESTAR , VAX.VAX_BLQENT, VAX.VAX_ORIGEM "
	cQuery +=     " , VAX.VAX_BLQAPR "
	cQuery +=  " FROM "+RetSqlName("VAX")+" VAX "
	cQuery += " WHERE VAX.VAX_FILIAL='"+xFilial("VAX")+"'"
	cQuery +=   " AND VAX.VAX_CHAMAD='"+_cMoment+"' "
	if lVAXORIGEM .and. !Empty(_cOrigem)
		cQuery += " AND VAX.VAX_ORIGEM = '"+_cOrigem+"' "
	Endif
	If lVAXCODMAR .AND. !Empty(_cCodMar)
		cQuery += " AND VAX.VAX_CODMAR IN ('" + Space(TamSX3("VAX_CODMAR")[1]) + "'," + _cCodMar + ")"
	EndIf
	If lVAXTIPVEN .AND. !Empty(_cTIPVEN)
		cQuery += " AND (VAX.VAX_TIPVEN = ' ' OR VAX.VAX_TIPVEN = '"+_cTIPVEN+"') "
	EndIf

	cQuery +=  " AND VAX.VAX_ESTVEI IN ('"+cVV1_ESTVEI+"','2') "
	cQuery +=  " AND VAX.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAX , .F., .T. )
	While !( cQAlVAX )->( Eof() )
		nPos := aScan(aTarAtend,{|x| x[1] == ( cQAlVAX )->( VAX_CODTAR ) })
		If nPos == 0
			aadd(aControle,{ ( cQAlVAX )->( VAX_CODTAR ) })
		EndIf
		( cQAlVAX )->( DbSkip() )
	EndDo
	( cQAlVAX )->( dbGoTop() )

	While !( cQAlVAX )->( Eof() )

		If !Empty( ( cQAlVAX )->( VAX_CONDCH ) ) // Verifica se existe a funcao ( Condicao da Chamada )
			If "(" $ ( cQAlVAX )->( VAX_CONDCH )
				If !(&(Alltrim(( cQAlVAX )->( VAX_CONDCH ))))// Executa Funcao de Condicao da Chamada para geracao da Tarefa
					( cQAlVAX )->( DbSkip() )
					Loop
				EndIf
			Else
				If !(&(Alltrim(( cQAlVAX )->( VAX_CONDCH ))+"()")) // Executa Funcao de Condicao da Chamada para geracao da Tarefa
					( cQAlVAX )->( DbSkip() )
					Loop
				EndIf
			EndIf
		EndIf

		nPos := aScan(aTarAtend,{|x| x[1] == ( cQAlVAX )->( VAX_CODTAR ) })
		If nPos == 0
			lOk := .t.
			If !Empty(left(( cQAlVAX )->( VAX_REQTAR ),6))
				// Verificar se a tarefa possui pre requisito, caso todos os pre requisitos estiverem ok, colocar no vetor //
				For ni := 1 to (len(( cQAlVAX )->( VAX_REQTAR ))/7)
					nPos := aScan(aTarAtend,{|x| x[1] == substr(( cQAlVAX )->( VAX_REQTAR ),(ni*7)-6,6) })
					If nPos > 0
						If !aTarAtend[nPos,2] $ "12" // Diferente de Aprovado / Aprovado com restricoes
							lOk := .f.
							Exit
						EndIf
					Else // Valida se ainda vai ser chamada a TAREFA //
						nPos := aScan(aControle,{|x| x[1] == substr(( cQAlVAX )->( VAX_REQTAR ),(ni*7)-6,6) })
						If nPos > 0
							lOk := .f.
							Exit
						EndIf
					EndIf
				Next
			EndIf
			If lOk

				cTip := "0"
				If ( cQAlVAX )->( VAX_OBRIGA ) == "1" // Obrigatorio
					cTip := "2"
				EndIf

				nVlr := 0
				nRecVS9 := 0 // Verificar VS9 ---> "2" Obrigatorio (quando relacionado ao VS9) //
				dbSelectArea("VS9")
				dbSetOrder(1)
				if dbSeek(xFilial("VS9")+left(_cAtend+space(30),len(VS9->VS9_NUMIDE))+"V"+( cQAlVAX )->( VAX_TIPPAG ))
					nVlr := VS9->VS9_VALPAG
					nRecVS9 := VS9->(RecNo())
				EndIf

				If Empty((cQAlVAX )->( VAX_TIPPAG )) .or. (!Empty((cQAlVAX )->( VAX_TIPPAG)) .and. nRecVS9 > 0)

					aadd(aTarPoss,{;
						cTip,;
						( cQAlVAX )->( VAX_CODTAR ),;
						( cQAlVAX )->( VAX_DESTAR ),;
						nVlr,;
						nRecVS9 ,;
						( cQAlVAX )->( VAX_ORIGEM )})

					aadd(aTarAtend,{;
						( cQAlVAX )->( VAX_CODTAR ),; // 01
						cTip,; // 02
						"0",; // 03
						"  ",; // 04
						"",; // 05
						nVlr,; // 06
						nVlr,; // 07
						( cQAlVAX )->( VAX_BLQENT ),; // 08
						( cQAlVAX )->( VAX_BLQAPR ),; // 09
						( cQAlVAX )->( VAX_ORIGEM ) }) // 10
				EndIf
			EndIf
		EndIf
		( cQAlVAX )->( DbSkip() )
	EndDo
	( cQAlVAX )->( dbCloseArea() )

	DbSelectArea("VAY")
	If len(aTarPoss) > 0
		lOk := .f.
		DEFINE MSDIALOG oTarPossiv FROM 000,000 TO 025,090 TITLE STR0024 OF oMainWnd // Tarefa a Executar

		@ 003,003 LISTBOX oLbTarPossi FIELDS HEADER (""),(STR0024) COLSIZES 10,200 SIZE 350,165 OF oTarPossiv ON DBLCLICK ( FS_DBLCLICK(oLbTarPossi:nAt) ) PIXEL
		oLbTarPossi:SetArray(aTarPoss)
		oLbTarPossi:bLine := { || { IIf(aTarPoss[oLbTarPossi:nAt,1]=="0",oBran,IIf(aTarPoss[oLbTarPossi:nAt,1]=="1",oVerd,oAzul)),aTarPoss[oLbTarPossi:nAt,2]+" - "+aTarPoss[oLbTarPossi:nAt,3] }}
		oLbTarPossi:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lMarcarT := !lMarcarT , FS_DBLCLICK(0) ) ,Nil) , }

		@ 168,003 TO 186,283 LABEL (" "+STR0016+" ") OF oTarPossiv PIXEL // Tarefa
		@ 176,015 BITMAP oBranLeg RESOURCE "BR_BRANCO" OF oTarPossiv NOBORDER SIZE 10,10 PIXEL
		@ 176,025 SAY STR0028 SIZE 110,08 OF oTarPossiv PIXEL COLOR CLR_BLUE // Nao selecionada
		@ 176,110 BITMAP oVerdLeg RESOURCE "BR_VERDE" OF oTarPossiv NOBORDER SIZE 10,10 PIXEL
		@ 176,120 SAY STR0029 SIZE 110,08 OF oTarPossiv PIXEL COLOR CLR_BLUE // Selecionada
		@ 176,205 BITMAP oAzulLeg RESOURCE "BR_AZUL" OF oTarPossiv NOBORDER SIZE 10,10 PIXEL
		@ 176,215 SAY STR0030 SIZE 110,08 OF oTarPossiv PIXEL COLOR CLR_BLUE // Obrigatoria

		DEFINE SBUTTON FROM 173,290 TYPE 1 ACTION (lOk:=.t.,oTarPossiv:End()) ENABLE OF oTarPossiv PIXEL // OK
		DEFINE SBUTTON FROM 173,324 TYPE 2 ACTION (oTarPossiv:End()) ENABLE OF oTarPossiv PIXEL // Cancela

		ACTIVATE MSDIALOG oTarPossiv CENTER
		For ni := 1 to len(aTarPoss)
			If ( lOk .and. aTarPoss[ni,1] == "1" ) .or. aTarPoss[ni,1] == "2" // 1-Selecionado pelo usuario / 2-Obrigatorio (relacionado ao VS9)
				DbSelectArea("VAY")
				RecLock("VAY",.t.)
				VAY->VAY_FILIAL := xFilial("VAY")
				VAY->VAY_SEQTAR := GetSXENum("VAY","VAY_SEQTAR")
				VAY->VAY_CODTAR := aTarPoss[ni,2]
				VAY->VAY_NUMIDE := _cAtend
				VAY->VAY_STATUS := "0" // Pendente
				VAY->VAY_VALSOL := aTarPoss[ni,4]
				VAY->VAY_USUSOL := __cUserID
				VAY->VAY_DATSOL := dDataBase
				VAY->VAY_HORSOL := Val(Substr(Time(),1,2)+Substr(Time(),4,2))
				If lVAYORIGEM
					VAY->VAY_ORIGEM := aTarPoss[ni,6]
				Endif
				ConfirmSx8()
				MsUnLock()
				cTSqTar += VAY->VAY_SEQTAR+"/"


				If aTarPoss[ni,5] > 0 // Alterar o VS9 (Relacionamento com o VAY)
					DbSelectArea("VS9")
					DbGoto(aTarPoss[ni,5])
					RecLock("VS9",.f.)
					VS9->VS9_SEQTAR := VAY->VAY_SEQTAR
					MsUnLock()
				EndIf

			EndIf
		Next
	Else
		If _cMoment == "3"//chamada pelo usuario. - Atendimento Novo.
			MsgInfo(STR0037,STR0032) // N„o existe tarefa cadastrada para o usuario! / Atencao
		EndIf
	EndIf


	cChaveAtend := left(_cAtend+space(30),len(VS9->VS9_NUMIDE))
	dbSelectArea("VS9")
	dbSetOrder(1)
	dbSeek(xFilial("VS9") + cChaveAtend + "V")
	While !Eof() .and. xFilial("VS9") == VS9->VS9_FILIAL .and. cChaveAtend == VS9->VS9_NUMIDE .and. "V" == VS9->VS9_TIPOPE
		If !Empty(VS9->VS9_SEQTAR)
			aAdd(aVS9SeqTar,{VS9->VS9_SEQTAR})
		EndIf
		DbSkip()
	EndDo

	cChaveAtend := left(_cAtend+space(30),len(VAY->VAY_NUMIDE))
	dbSelectArea("VAY")
	dbSetOrder(3)
	dbSeek(xFilial("VAY") + cChaveAtend )
	While !Eof() .and. xFilial("VAY") == VAY->VAY_FILIAL .and. cChaveAtend == VAY->VAY_NUMIDE
		If !Empty(VAY->VAY_SEQTAR) .and. !( VAY->VAY_SEQTAR $ cTSqTar )
			dbSelectArea("VAX")
			dbSetOrder(1)
			dbSeek(xFilial("VAX")+VAY->VAY_CODTAR)
			If !Empty(VAX->VAX_TIPPAG)
				If aScan(aVS9SeqTar,{|x| x[1] == VAY->VAY_SEQTAR }) <= 0
					DbSelectArea("VAY")
					RecLock("VAY",.f.)
					VAY->VAY_STATUS := "4" // Deletado pelo Usuario
					MsUnLock()
				EndIf
			EndIf
			DbSelectArea("VAY")
		EndIf
		DbSkip()
	EndDo

EndIf
DbSelectArea("VS9")

if lRet
	// PONTO DE ENTRADA logo apÛs ter inserido nova tarefa.
	If ExistBlock("VM130AIT")
		ExecBlock("VM130AIT",.f.,.f.)
	EndIf
Endif

Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥FS_DBLCLICK≥ Autor ≥  Andre Luis Almeida  ≥ Data ≥ 15/09/09 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Marcar/Desmarcar registros no ListBox das possiveis Tarefas≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_DBLCLICK(nPos)
Local ni := 0
If nPos <> 0 // Individual ( Duplo Click no ListBox )
	If aTarPoss[nPos,1] == "0"
		aTarPoss[nPos,1] := "1"
	ElseIf aTarPoss[nPos,1] == "1"
		aTarPoss[nPos,1] := "0"
	EndIf
Else // Todos ( Marcar/Desmarcar )
	For ni := 1 to len(aTarPoss)
		If aTarPoss[ni,1] <> "2"
			If lMarcarT
				aTarPoss[ni,1] := "1"
			Else
				aTarPoss[ni,1] := "0"
			EndIf
		EndIf
	Next
EndIf
oLbTarPossi:Refresh()
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥VEIVM130DEL≥ Autor ≥  Andre Luis Almeida  ≥ Data ≥ 05/07/12 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Funcao chamada de dentro do Atendimento                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ _cAtend  = Nro do Atendimento                              ≥±±
±±≥          ≥ _cStatus = A - Atendimento voltou para Em Aberto           ≥±±
±±≥          ≥          = L - Atendimento voltou para Aprovado            ≥±±
±±≥          ≥          = C - Atendimento foi Cancelado                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function VEIVM130DEL(_cAtend,_cStatus,cFilAtend, cVAYORIGEM)
Local aTarAtend  := {} // Tarefas do Atendimento
Local ni         := 0
Local cQuery     := ""
Local cQAlVAY    := "SQLVAY"
Local cChamadas  := ""
Local lVAYORIGEM := VAY->(FieldPos("VAY_ORIGEM")) <> 0

Default _cAtend  := VV9->VV9_NUMATE // Nro do Atendimento
Default _cStatus := ""
Default cFilAtend := xFilial("VAY")
Default cVAYORIGEM := ""

DbSelectArea("VAY")
// Levantar Tarefas do Atendimento //
cQuery := "SELECT VAY.R_E_C_N_O_ AS RECVAY , VAX.VAX_CHAMAD "
cQuery +=  " FROM "+RetSqlName("VAY")+" VAY , "+RetSqlName("VAX")+" VAX "
cQuery += " WHERE VAY.VAY_FILIAL='"+cFilAtend+"'"
cQuery +=   " AND VAY.VAY_NUMIDE='"+left(_cAtend+space(20),TamSx3("VAY_NUMIDE")[1])+"'"
If lVAYORIGEM .AND. cVAYORIGEM == "3"
	cQuery += " AND VAY.VAY_ORIGEM = '" + cVAYORIGEM + "'"
EndIf
cQuery +=   " AND VAY.VAY_STATUS<>'4'"
cQuery +=   " AND VAX.VAX_FILIAL='"+xFilial("VAX")+"'"
cQuery +=   " AND VAY.VAY_CODTAR=VAX.VAX_CODTAR"
cQuery +=   " AND VAY.D_E_L_E_T_=' '"
cQuery +=   " AND VAX.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVAY , .F., .T. )
While !( cQAlVAY )->( Eof() )
	aadd(aTarAtend,{ ( cQAlVAY )->( VAX_CHAMAD ) , ( cQAlVAY )->( RECVAY ) })
	( cQAlVAY )->( DbSkip() )
EndDo
( cQAlVAY )->( dbCloseArea() )
DbSelectArea("VAY")
//
cChamadas := ""
If _cStatus == "A" // Atendimento voltou para Em Aberto
	cChamadas := "1/2/3/4/5/6/7/8/" // 1-Gravacao / 2-Finalizacao / 3-Pelo Usuario / 4-Pendente Aprovacao / 5-Pre-Aprovado / 6-Aprovado / 7-Reserva / 8-Cancela Reserva
ElseIf _cStatus == "L" // Atendimento voltou para Aprovado
	cChamadas := "2/" // 2-Finalizacao
ElseIf _cStatus == "C" // Atendimento foi Cancelado
	cChamadas := "1/2/3/4/5/6/7/8/" // 1-Gravacao / 2-Finalizacao / 3-Pelo Usuario / 4-Pendente Aprovacao / 5-Pre-Aprovado / 6-Aprovado / 7-Reserva / 8-Cancela Reserva
EndIf
If !Empty(cChamadas)
	For ni := 1 to len(aTarAtend)
		If aTarAtend[ni,1] $ cChamadas
			DbSelectArea("VAY")
			DbGoTo(aTarAtend[ni,2])
			RecLock("VAY",.F.)
			VAY->VAY_STATUS := "4" // Deletado pelo Usuario
			MsUnlock()
		EndIf
	Next
EndIf
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥VM130VLDFIL≥ Autor ≥  Andre Luis Almeida  ≥ Data ≥ 27/06/17 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Valida permissao do usuario na Filial digitada do filtro   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function VM130VLDFIL(cFilAte)
Local lRet     := .t.
Local oFilHelp := DMS_FilialHelper():New()
Local aSM0     := oFilHelp:GetAllFilPermis(.f.)
If !Empty(cFilAte)
	If ascan(aSM0,cFilAte) <= 0
		lRet := .f.
		MsgStop(STR0048,STR0032) // Usuario sem permissao para utilizar a Filial. / Atencao
	EndIf
EndIf
Return lRet




/*/{Protheus.doc} VM130001_StatusOrigem
Retorna Status de um Atendimento ou Pedido de Venda de Montadora
@author Rubens
@since 04/02/2019
@version 1.0
@return Status, Status
@param cOrigem, characters, Origem do Registro
@param cChavePesq, characters, Chave de Pesquisa
@type function
/*/
Static Function VM130001_StatusOrigem(cOrigem, cChavePesq)

	Default cOrigem := "";

	If cOrigem == "3"
		VRJ->(DbSetOrder(1))
		VRJ->(MsSeek(xFilial("VRJ")+cChavePesq))
		Return VRJ->VRJ_STATUS
	Else
		VV9->(DbSetOrder(1))
		VV9->(MsSeek(xFilial("VV9")+cChavePesq))
		Return VV9->VV9_STATUS
	EndIf

Return ""


/*/{Protheus.doc} VM130002_VeiculoEntregue
Retorna se algum veiculo do atendimento ou pedido de venda foi entregue
@author Rubens
@since 04/02/2019
@version 1.0
@return logical, Veiculo ja entregue
@param cOrigem, characters, Origem do Registro
@param cChavePesq, characters, Chave de Pesquisa
@type function
/*/
Static Function VM130002_VeiculoEntregue(cOrigem, cChavePesq)

	Default cOrigem := "";

	If cOrigem == "3"
		
	Else
		cSQL := "SELECT COUNT(*) " +;
			 " FROM " + RetSQLName("VVA") + " VVA" +;
			" WHERE VVA.VVA_FILIAL = '" + xFilial("VVA") + "'" +;
			  " AND VVA.VVA_NUMTRA = '" + cChavePesq + "'" +;
			  " AND VVA.VVA_DTEREA <> ' '" +;
			  " AND VVA.D_E_L_E_T_ = ' '"
		Return (FM_SQL(cSQL) <> 0)

	EndIf
Return .f.

/*/{Protheus.doc} VM130003_Valid
Validacao dos Gets de Numero do Atendimento e Numero do pedido de Venda Montadora
@author Rubens
@since 04/02/2019
@version 1.0
@return ${return}, ${return_description}
@param cValidacao, characters, Get de Origem da Chamada
@type function
/*/
Static Function VM130003_Valid(cValidacao)

	Do Case
	Case cValidacao == "ATEND"
		If lVAYORIGEM .and. !Empty(cNumAte)
			cNumPedV  := Space(TamSX3("VRJ_PEDIDO")[1])
		EndIf
	Case cValidacao == "PEDVENDA"
		If !Empty(cNumPedV)
			cNumAte   := Space(TamSX3("VV9_NUMATE")[1])
		EndIf
	EndCase
Return .t.

/*/{Protheus.doc} VM1300011_AtualizaVeiculosObservacao
Atualiza ListBox dos VVAs e Observacao do Atendimento

@author Andre Luis Almeida
@since 22/09/2020
@version undefined

@type function
/*/
Static Function VM1300011_AtualizaVeiculosObservacao( cFil , nRecOrigem, cOrigem )
Local cQuery  := ""
Local cQAlVVA := "SQLVVA"
Local cFilBkp := cFilAnt
Local lRefresh := .f.

Default cOrigem := ""

If nRecOrigem == 0 .or. (cOrigem <> "3" .and. nRecOrigem <> nBkpVV9) .or. (cOrigem == "3" .and. nRecOrigem <> nBkpVRJ) // limpar variavel e vetor aVVAs se nao tiver VV9 ou for diferente do ultimo posicionado
	cObsVV9 := ""
	aVVAs := {}
	lRefresh := .t.
EndIf

// Origem no Atendimento 
If cOrigem <> "3" .and. nRecOrigem > 0 .and. nRecOrigem <> nBkpVV9 // carregar variavel e vetor aVVAs se existir VV9 e for diferente do ultimo posicionado
	cFilAnt := cFil

	VV9->(DbGoto(nRecOrigem))

	INCLUI := .f. // necessario no E_MSMM

	cObsVV9 := E_MSMM(VV9->VV9_OBSMEM,TamSx3("VV9_OBSERV")[1])

	cQuery := "SELECT VV1.VV1_CODMAR , VV2.VV2_DESMOD , VVC.VVC_DESCRI , VV1.VV1_PLAVEI , VV1.VV1_CHASSI "
	cQuery += "  FROM "+RetSqlName("VVA")+" VVA "
	cQuery += "  JOIN "+RetSqlName("VV1")+" VV1 ON VV1.VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1.VV1_CHAINT = VVA.VVA_CHAINT AND VV1.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+RetSqlName("VV2")+" VV2 ON VV2.VV2_FILIAL = '"+xFilial("VV2")+"' AND VV2.VV2_CODMAR = VV1.VV1_CODMAR AND VV2.VV2_MODVEI = VV1.VV1_MODVEI AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD AND VV2.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+RetSqlName("VVC")+" VVC ON VVC.VVC_FILIAL = '"+xFilial("VVC")+"' AND VVC.VVC_CODMAR = VV1.VV1_CODMAR AND VVC.VVC_CORVEI = VV1.VV1_CORVEI AND VVC.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VVA.VVA_FILIAL = '"+VV9->VV9_FILIAL+"'"
	cQuery += "   AND VVA.VVA_NUMTRA = '"+VV9->VV9_NUMATE+"'"
	cQuery += "   AND VVA.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVVA , .F., .T. )
	While !( cQAlVVA )->( Eof() )
		AAdd( aVVAs , {	( cQAlVVA )->( VV1_CODMAR ) ,;
						( cQAlVVA )->( VV2_DESMOD ) ,;
						( cQAlVVA )->( VVC_DESCRI ) ,;
						( cQAlVVA )->( VV1_PLAVEI ) ,;
						( cQAlVVA )->( VV1_CHASSI ) })
		( cQAlVVA )->( DbSkip() )
	EndDo

	( cQAlVVA )->( dbCloseArea() )
	DbSelectArea("VAY")

	cFilAnt := cFilBkp

	nBkpVV9 := nRecOrigem // Controle para nao buscar o mesmo Atendimento sem necessidade pois pode haver mais de uma linha (tarefas diferentes) para o mesmo Atendimento
	nBkpVRJ := 0

	lRefresh := .t.
EndIf

// Origem no Pedido de Venda de Montadora 
If cOrigem == "3" .and. nRecOrigem > 0 .and. nRecOrigem <> nBkpVRJ // carregar variavel e vetor aVVAs se existir VV9 e for diferente do ultimo posicionado

	cFilAnt := cFil

	cObsVV9 := ""

	cQuery := "SELECT VV1.VV1_CODMAR , VV2.VV2_DESMOD , VVC.VVC_DESCRI , VV1.VV1_PLAVEI , VV1.VV1_CHASSI "
	cQuery += "  FROM "+RetSqlName("VRJ")+" VRJ "
	cQuery += "  JOIN "+RetSqlName("VRK")+" VRK ON VRK.VRK_FILIAL = '"+xFilial("VRK")+"' AND VRK.VRK_PEDIDO = VRJ.VRJ_PEDIDO AND VRK.VRK_CANCEL IN ('0',' ') AND VRK.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+RetSqlName("VV1")+" VV1 ON VV1.VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1.VV1_CHAINT = VRK.VRK_CHAINT AND VV1.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+RetSqlName("VV2")+" VV2 ON VV2.VV2_FILIAL = '"+xFilial("VV2")+"' AND VV2.VV2_CODMAR = VV1.VV1_CODMAR AND VV2.VV2_MODVEI = VV1.VV1_MODVEI AND VV2.VV2_SEGMOD = VV1.VV1_SEGMOD AND VV2.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN "+RetSqlName("VVC")+" VVC ON VVC.VVC_FILIAL = '"+xFilial("VVC")+"' AND VVC.VVC_CODMAR = VV1.VV1_CODMAR AND VVC.VVC_CORVEI = VV1.VV1_CORVEI AND VVC.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VRJ.R_E_C_N_O_ = " + cValToChar(nRecOrigem)
	cQuery += "   AND VRJ.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVVA , .F., .T. )
	While !( cQAlVVA )->( Eof() )
		AAdd( aVVAs , {	( cQAlVVA )->( VV1_CODMAR ) ,;
						( cQAlVVA )->( VV2_DESMOD ) ,;
						( cQAlVVA )->( VVC_DESCRI ) ,;
						( cQAlVVA )->( VV1_PLAVEI ) ,;
						( cQAlVVA )->( VV1_CHASSI ) })
		( cQAlVVA )->( DbSkip() )
	EndDo

	( cQAlVVA )->( dbCloseArea() )
	DbSelectArea("VAY")

	cFilAnt := cFilBkp

	nBkpVV9 := 0
	nBkpVRJ := nRecOrigem // Controle para nao buscar o mesmo Pedido sem necessidade pois pode haver mais de uma linha (tarefas diferentes) para o mesmo pedido

	lRefresh := .t.
EndIf

//

If lRefresh // Atualizar ListBox e Observacao
	oLbVVAs:nAt := 1
	oLbVVAs:setArray(aVVAs)
	oLbVVAs:Refresh()
	oObsVV9:Refresh()
EndIf


Return()
