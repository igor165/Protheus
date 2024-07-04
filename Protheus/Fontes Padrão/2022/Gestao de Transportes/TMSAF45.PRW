#include "PROTHEUS.ch"
#include "TMSAF45.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออหออออออออออออหอออออออหออออออออออออออออออออหออออออหออออออออออปฑฑ
ฑฑบ Programa   บ  TMSAF45   บ Autor บ Richard Anderson   บ Data บ 14/01/07 บฑฑ
ฑฑฬออออออออออออสออออออออออออสอออออออสออออออออออออออออออออสออออออสออออออออออนฑฑ
ฑฑบ Planilha de Custos do Veiculo                                          บฑฑ
ฑฑฬออออออออออออหอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Sintaxe    บ  TMSAF45()                                                บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros บ                                                           บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Retorno    บ NIL                                                       บฑฑ
ฑฑบออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso        บ SIGATMS - Gestao de Transportes                           บฑฑ
ฑฑฬออออออออออออฮอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Comentario บ                                                           บฑฑ
ฑฑบ            บ                                                           บฑฑ
ฑฑฬออออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          Atualizacoes efetuadas desde a coDFHicacao inicial            บฑฑ
ฑฑฬออออออออออออหออออออออหออออออหอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ  Data  บ BOPS บ             Motivo da Alteracao           บฑฑ
ฑฑฬออออออออออออฮออออออออฮออออออฮอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            บxx/xx/02บxxxxxxบ                                           บฑฑ
ฑฑศออออออออออออสออออออออสออออออสอออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TMSAF45()

Private cCadastro	:= STR0001 //-- Planilha de Custos do Veiculo
Private aRotina	:= {{ STR0002  , "AxPesqui"  , 0, 1 },; //"Pesquisar"
				          { STR0003  , "TMAF45Mnt" , 0, 2 } } //"Visualizar"

dbSelectArea("DFK")
dbSetOrder(1)
dbGoTop()

mBrowse(06,01,22,75,"DFK")

Return Nil

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ TMAF45Mnt ณ Autor ณ Richard Anderson     ณ Data ณ14.01.2007 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ Interface da Rotina de Planilha de Custos                   ณฑฑ
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
Function TMAF45Mnt(cAlias, nReg, nOpcx)

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

//-- Controle de dimensoes de objetos
Local aObjects		:= {}
Local aInfo			:= {}

//-- GetDados
Local nNumLinhas  := 999

//-- EnchoiceBar
Private aTela[0][0]
Private aGets[0]

//-- GetDados
Private oTmsGetD
Private aHeader	 := {}
Private aCols	    := {}
Private aTmsPosObj := {}

Aadd(aNoFields,'DFL_IDCTMS')
Aadd(aNoFields,'DFL_CODVEI')

//-- Configura variaveis da Enchoice
RegToMemory( cAlias, INCLUI )

//-- Configura variaveis da GetDados
TMSFillGetDados( nOpcx, 'DFL', 1, xFilial( 'DFL' ) + M->DFK_IDCTMS+M->DFK_CODVEI, { ||  DFL->(DFL_FILIAL + DFL_IDCTMS + DFL_CODVEI) },;
																		 { || .T. }, aNoFields,	aYesFields )
nTLinhas := Len(aCols)																			 
																			 
//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 040, .T., .T. } )
AAdd( aObjects, { 100, 060, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aTmsPosObj := MsObjSize( aInfo, aObjects,.T.)

DFL->(dbGoto(0))

DEFINE MSDIALOG oTmsDlgEsp TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL
	//-- Monta a enchoice.
	oTmsEnch	:= MsMGet():New( cAlias, nReg, nOpcx,,,,, aTmsPosObj[1],, 3,,,,,,.T. )
	//        MsGetDados(                      nT ,                  nL,                 nB,                  nR,    nOpc,     cLinhaOk,      cTudoOk,cIniCpos,lDeleta,aAlter,nFreeze,lEmpty,nMax,cFieldOk,cSuperDel,aTeclas,cDelOk,oWnd)
	oTmsGetD := MSGetDados():New(aTmsPosObj[ 2, 1 ], aTmsPosObj[ 2, 2 ],aTmsPosObj[ 2, 3 ], aTmsPosObj[ 2, 4 ], nOpcx,"TMAF45LOk()","TMAF45TOk()","+DFL_ITEM",.T.,nil,nil,nil,nNumLinhas)
	
ACTIVATE MSDIALOG oTmsDlgEsp ON INIT EnchoiceBar( oTmsDlgEsp,{|| If(oTmsGetD:TudoOk(),(oTmsDlgEsp:End(),nOpcA := 1),nOpcA := 0)},{|| nOpcA := 0, oTmsDlgEsp:End() }) 

RestArea(aAreaAtu)

Return nOpcA

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ TMAF45LOk ณ Autor ณ Richard Anderson     ณ Data ณ14.01.2007 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ Validacao de digitacao de linha                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGATMS                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function TMAF45LOk()
Local lRet := .T.
Return(lRet)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ TMAF45TOk ณ Autor ณ Richard Anderson     ณ Data ณ22.11.2006 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ Validacao de confirmacao para gravacao                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGATMS                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function TMAF45TOk()

Local lRet  := .T.
Return(lRet)
