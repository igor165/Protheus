#INCLUDE "TMSC010.ch"
#include 'Protheus.ch'
#define PDCODIGO		1
#define PDPEDIDO		2
#define PDITEM		   3
#define PDBLCRED		4
#define PDBLTMS 		5
#define PDCLIENTE	   6
#define PDLOJA		   7
#define PDNREDUZ		8
#define PDPRODUTO	   9
#define PDQTDLIB		10
#define PDPRCVEN		11
#define PDSERVIC		12
#define PDBLINF 		13
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSC010  ³ Autor ³ Alex Egydio           ³ Data ³21.03.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta os pedidos com bloqueio de credito por Lote de   ³±±
±±³          ³ Nota Fiscal de Entrada do Cliente.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSC010(ExpA1,ExpC2,ExpN1)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Vetor com pedidos bloqueados                       ³±±
±±³          ³ ExpC1 = Nr. do lote de entrada de notas fiscais do cliente ³±±
±±³          ³         ou numero da solicitacao de frete.                 ³±±
±±³          ³ ExpL1 = .T. consulta por lote de NFC / .F. nr.sol.frete    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSC010( aPedido, cCodigo )
//-- Variaveis genericas
Local bWhile
//-- Controle de dimensoes de objetos
Local aObjects	:= {}
Local aInfo		:= {}
Local aPosObj	:= {}
Local aSize		:= {}
//-- MsDialog
Local oDlgEsp
Local nOpca		:= 0
//-- EnchoiceBar
Local aButtons	:= {}       
//-- ListBox
Local cLbx		:= ''
Local oLbx
Local nCntFor	:= 0     

Private aPedidoRel := {}      

DEFAULT aPedido	:= {}
DEFAULT cCodigo	:= ''

If Empty( aPedido ) .And. Empty( cCodigo )
	If	!Pergunte('TMC010', .T.)
		Return NIL
	EndIf

	cCodIni := mv_par01
	cCodFim := mv_par02
Else
	cCodIni := cCodFim := cCodigo
EndIf

If	Empty( aPedido )
	//-- Procura pedidos com bloqueio de credito.

	SC9->( DbSetOrder( 8 ) )	//-- C9_FILIAL + C9_LOTNFC + C9_PEDIDO + C9_ITEM
	bWhile := { || SC9->( ! Eof() .And. SC9->C9_FILIAL == xFilial('SC9') .And. SC9->C9_LOTNFC <= cCodFim ) }

	SC9->( MsSeek( xFilial('SC9') + cCodIni, .T. ) )
	
	While Eval( bWhile )
		If	! Empty( SC9->C9_LOTNFC )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Bloqueios do SC9                                                      ³
			//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
			//³ C9_BLCRED: 01 - Bloqueio de Credito por Valor                         ³
			//³            04 - Vencto do Limite de Credito                           ³
			//³            05 - Bloqueio de Credito por Estorno                       ³
			//³            06 - Bloqueio de Credito por Risco                         ³
			//³            09 - Rejeicao de Credito                                   ³
			//³                                                                       ³
			//³ C9_BLEST:  02 - Bloqueio de Estoque                                   ³
			//³            03 - Bloqueio Manual de Estoque                            ³
			//³                                                                       ³
			//³ C9_BLWMS:  01 - Bloqueio de Enderecamento do WMS/Somente SB2          ³
			//³            02 - Bloqueio de Enderecamento do WMS                      ³
			//³            05 - Liberacao para Bloqueio 01                            ³
			//³            06 - Liberacao para Bloqueio 02                            ³
			//³ C9_BLTMS:  10 - Comercial                                             ³
			//³            20 - Operacional                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//-- Se estiver com bloqueio de credito/tms  carrega array para a tela   
			If	(!Empty( SC9->C9_BLCRED ) .And. SC9->C9_BLCRED != '10') .Or. (!Empty(SC9->C9_BLTMS))
				Aadd( aPedido, { SC9->C9_LOTNFC, SC9->C9_PEDIDO, SC9->C9_ITEM, SC9->C9_BLCRED, SC9->C9_BLTMS, SC9->C9_CLIENTE, SC9->C9_LOJA, Posicione('SA1', 1, xFilial('SA1') + SC9->C9_CLIENTE + SC9->C9_LOJA, 'A1_NREDUZ'), SC9->C9_PRODUTO, SC9->C9_QTDLIB, SC9->C9_PRCVEN, SC9->C9_SERVIC, SC9->C9_BLINF } )
			EndIf
	//-- Se estiver com bloqueio de credito/tms carrega array para o relatorio
			If	(!Empty( SC9->C9_BLCRED ) .And. SC9->C9_BLCRED != '10') 
				Aadd( aPedidoRel, { SC9->C9_LOTNFC, SC9->C9_PEDIDO, SC9->C9_ITEM, SC9->C9_BLCRED, SC9->C9_CLIENTE, SC9->C9_LOJA, Posicione('SA1', 1, xFilial('SA1') + SC9->C9_CLIENTE + SC9->C9_LOJA, 'A1_NREDUZ'), SC9->C9_PRODUTO, SC9->C9_QTDLIB, SC9->C9_PRCVEN, SC9->C9_SERVIC ,"CREDITO"} )
   		EndIf
		   If (!Empty(SC9->C9_BLTMS))
				Aadd( aPedidoRel, { SC9->C9_LOTNFC, SC9->C9_PEDIDO, SC9->C9_ITEM, SC9->C9_BLTMS, SC9->C9_CLIENTE, SC9->C9_LOJA, Posicione('SA1', 1, xFilial('SA1') + SC9->C9_CLIENTE + SC9->C9_LOJA, 'A1_NREDUZ'), SC9->C9_PRODUTO, SC9->C9_QTDLIB, SC9->C9_PRCVEN, SC9->C9_SERVIC, "TRANSPORTE" } )
   		EndIf
		EndIf
		SC9->( DbSkip() )
	EndDo
Else     
	//-- Carrega array para relatorio
	For nCntFor := 1 To Len( aPedido )      
       If (!Empty( aPedido[nCntFor,4] ) .And. aPedido[nCntFor,4] != '10')
          AAdd( aPedidorel, { aPedido[nCntFor,1], aPedido[nCntFor,2], aPedido[nCntFor,3], aPedido[nCntFor,4], aPedido[nCntFor,6], aPedido[nCntFor,7], aPedido[nCntFor,8], aPedido[nCntFor,9], aPedido[nCntFor,10], aPedido[nCntFor,11], aPedido[nCntFor,12] ,"CREDITO"}	)
       Endif
       If (!Empty(aPedido[nCntFor,5]))    
          AAdd( aPedidorel, { aPedido[nCntFor,1], aPedido[nCntFor,2], aPedido[nCntFor,3], aPedido[nCntFor,5], aPedido[nCntFor,6], aPedido[nCntFor,7], aPedido[nCntFor,8], aPedido[nCntFor,9], aPedido[nCntFor,10], aPedido[nCntFor,11], aPedido[nCntFor,12] ,"TRANSPORTE"}	)
       Endif
	Next

EndIf

If	Empty( aPedido )
	Help(' ', 1, 'TMSC01001')			//-- Nao encontrou pedidos com bloqueio de credido (SC9)
	Return NIL
EndIf

Aadd(aButtons,	{'PEDIDO' ,{|| TMSC010Vis(aPedido[ oLbx:nAT, PDPEDIDO ]) }	, STR0001 , STR0006 }) //'Visualizar pedido...'
Aadd(aButtons,	{'IMPRESSAO',{|| TMSR010( aPedidoRel, cCodigo ) }	, STR0002 , STR0007 }) //'Imprime pedidos bloqueados por credito / transporte 

//-- Calcula as dimensoes dos objetos
aSize  := MsAdvSize( .T. )

AAdd( aObjects, { 100, 60,.T.,.T. } )

aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
aPosObj:= MsObjSize( aInfo, aObjects,.T. )

DEFINE MSDIALOG oDlgEsp TITLE STR0003 FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL //'Pedidos bloqueados por Credito'

	@ aPosObj[1,1], aPosObj[1,2] LISTBOX oLbx VAR cLbx FIELDS HEADER ;
												Posicione('SX3',2,'C9_LOTNFC'	,'X3Titulo()')		,;
												Posicione('SX3',2,'C9_PEDIDO'	,'X3Titulo()')		,;
												Posicione('SX3',2,'C9_ITEM'	,'X3Titulo()')		,;
												Posicione('SX3',2,'C9_BLCRED'	,'X3Titulo()')		,;
												Posicione('SX3',2,'C9_BLTMS'	,'X3Titulo()')		,;
												Posicione('SX3',2,'C9_BLINF'	,'X3Titulo()')		,;
												Posicione('SX3',2,'C9_CLIENTE','X3Titulo()')		,;
												Posicione('SX3',2,'C9_LOJA'	,'X3Titulo()')		,;
												Posicione('SX3',2,'A1_NREDUZ'	,'X3Titulo()')		,;
												Posicione('SX3',2,'C9_PRODUTO','X3Titulo()')		,;
												Posicione('SX3',2,'C9_QTDLIB'	,'X3Titulo()')		,;
												Posicione('SX3',2,'C9_PRCVEN'	,'X3Titulo()')		,;
												Posicione('SX3',2,'C9_SERVIC'	,'X3Titulo()')		 ;
												SIZE	aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1]-20 OF oDlgEsp PIXEL
	oLbx:SetArray(aPedido)
	oLbx:bLine	:= { || {	aPedido[oLbx:nAT, PDCODIGO		]	,;
									aPedido[oLbx:nAT, PDPEDIDO		]	,;
									aPedido[oLbx:nAT, PDITEM  		]	,;
									aPedido[oLbx:nAT, PDBLCRED		]	,;
									aPedido[oLbx:nAT, PDBLTMS  	]	,;
									aPedido[oLbx:nAT, PDBLINF  	]	,;
									aPedido[oLbx:nAT, PDCLIENTE	]	,;
									aPedido[oLbx:nAT, PDLOJA		]	,;
									aPedido[oLbx:nAT, PDNREDUZ		]	,;
									aPedido[oLbx:nAT, PDPRODUTO	]	,;
									Transform(aPedido[oLbx:nAT, PDQTDLIB ], PesqPictQt('C9_QTDLIB') ),;
									Transform(aPedido[oLbx:nAT, PDPRCVEN ], PesqPict('SC9','C9_PRCVEN') ),;
									aPedido[oLbx:nAT, PDSERVIC		]	} }

ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| nOpca:= 1,oDlgEsp:End() },{||oDlgEsp:End()},, aButtons )

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSC010Vis³ Autor ³ Alex Egydio           ³ Data ³21.03.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza pedido de venda                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSC010Vis(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nr.do pedido de venda                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSC010Vis( cPedido )

Local aAreaAnt := GetArea()
Local aAreaSC5 := SC5->( GetArea() )
Local aRotAnt	:= {}

PRIVATE aRotina := {	{ STR0004 ,'AxPesqui'  ,0,1},; 	//'Pesquisar'
							{ STR0005,'A410Visual',0,2} } 	//'Visualizar'
If Type( 'aRotina' ) == 'A'
	aRotAnt := aClone( aRotina )
EndIf

DbSelectArea('SC5')
DbSetOrder(1)
If	MsSeek( xFilial('SC5') + cPedido, .F. )
	A410Visual( 'SC5', Recno(), 2 )
EndIf

If !Empty( aRotAnt )
	aRotina := aClone( aRotAnt )
EndIf
RestArea( aAreaSC5 )
RestArea( aAreaAnt )

Return NIL