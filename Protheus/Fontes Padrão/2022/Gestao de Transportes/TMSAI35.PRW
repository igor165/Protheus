#include "PROTHEUS.ch"
#include "TMSAI35.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออหออออออออออออหอออออออหออออออออออออออออออออหออออออหออออออออออปฑฑ
ฑฑบ Programa   บ  TMSAI35   บ Autor บ Richard Anderson   บ Data บ 22/11/06 บฑฑ
ฑฑฬออออออออออออสออออออออออออสอออออออสออออออออออออออออออออสออออออสออออออออออนฑฑ
ฑฑบ             	Altera็๕es do CRT                           		         บฑฑ
ฑฑฬออออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe    บ  TMSAI35()                                                บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros บ                                         			         บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    บ NIL                                                       บฑฑ
ฑฑบออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso        บ SIGATMS - Gestao de Transportes                           บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Comentario บ                                                           บฑฑ
ฑฑบ            บ                                                           บฑฑ
ฑฑฬออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          Atualizacoes efetuadas desde a codificacao inicial            บฑฑ
ฑฑฬออออออออออออหออออออออหออออออหอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ  Data  บ BOPS บ             Motivo da Alteracao           บฑฑ
ฑฑฬออออออออออออฮออออออออฮออออออฮอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            บxx/xx/02บxxxxxxบ                                           บฑฑ
ฑฑศออออออออออออสออออออออสออออออสอออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TMSAI35()

Private aMemos    := {}
Private cCadastro	:= STR0001 //-- "Altera็๕es do CRT"
Private aRotina	:= {{ STR0002  , "AxPesqui"  , 0, 1 },; //"Pesquisar"
				          { STR0003  , "TMAI35Mnt" , 0, 2 } } //"Visualizar"

dbSelectArea("DIB")
dbSetOrder(1)
dbGoTop()

mBrowse(06,01,22,75,"DIB")

Return Nil

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ TMAI35Mnt ณ Autor ณ Richard Anderson     ณ Data ณ19.03.2006 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ Interface da Rotina de geracao de CRT                       ณฑฑ
ฑฑณ          ณ                                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1: Alias da tabela                                      ณฑฑ
ฑฑณ          ณ ExpN2: Numero do Registro                                   ณฑฑ
ฑฑณ          ณ ExpN3: Opcao do aRotina                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGATMS                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function TMAI35Mnt(cAlias, nReg, nOpcx)

Local nI       := 0
Local aAreaAtu := GetArea()
Local nTLinhas := 0

//-- EnchoiceBar
Local aTmsVisual	:= {}
Local aTmsAltera	:= {}
Local nOpcA			:= 0
Local nOpcB       := aRotina[nOpcx,4]
Local oTmsEnch

//-- Dialog
Local oTmsDlgEsp
Local aNoFields	:= {}
Local aYesFields	:= {}
Local oFont       := TFont():New( "Courier New", 6, 15 )

//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]

//-- Configura variaveis da Enchoice
RegToMemory( cAlias, INCLUI )

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oTmsDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

	//-- Monta a enchoice.
	oTmsEnch	:= MsMGet():New( cAlias, nReg, nOpcx,,,,, aTmsPosObj[1],, 3,,,,,,.T. )
	
	//-- Muda o fonte dos gets de campo Memo
	For nI := 1 To Len(oTmsEnch:aEntryCtrls)
		If oTmsEnch:aEntryCtrls[nI]:ClassName() == "TMULTIGET"
			oTmsEnch:aEntryCtrls[nI]:oFont := oFont
		EndIf
	Next nI					
	
ACTIVATE MSDIALOG oTmsDlgEsp ON INIT EnchoiceBar( oTmsDlgEsp,{|| nOpcA := 1, oTmsDlgEsp:End() },{|| nOpcA := 0, oTmsDlgEsp:End() }) 

RestArea(aAreaATU)

Return nOpcA
