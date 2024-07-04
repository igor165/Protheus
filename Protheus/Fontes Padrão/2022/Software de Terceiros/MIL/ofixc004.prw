#include "Protheus.ch"
#include "colors.ch"
#include "OFIXC004.ch"

#DEFINE AOS_TAMANHO		16 // Tamanho da matriz
#DEFINE AOS_ATUALIZADO	01 // Indica se foi Atualizado
#DEFINE AOS_CHAVE		02 // Chave para Pesquisa
#DEFINE AOS_STATUS		03 // Status
#DEFINE AOS_PROGRESSO	04 // Progresso (%)
#DEFINE AOS_NUMOSV 		05 // Num. da OS
#DEFINE AOS_PLACA 		06 // Placa
#DEFINE AOS_MODELO 		07 // Modelo do Veiculo
#DEFINE AOS_CONSULTOR	08 // Consultor
#DEFINE AOS_BOX			09 // Box
#DEFINE AOS_ENTRADA		10 // Entrada
#DEFINE AOS_SAIDA		11 // Saida
#DEFINE AOS_TEMPAD		12 // Tempo Padrao
#DEFINE AOS_TEMTRAB		13 // Tempo Trabalhado
#DEFINE AOS_CLIENTE		14 // Cliente
#DEFINE AOS_LOJA		15 // Loja
#DEFINE AOS_NOME		16 // Nome do Cliente

/*/{Protheus.doc} mil_ver
Versao do fonte modelo novo
@author Rubens
@since 03/08/2017
@version undefined

@type function
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006072_1"


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFIXC004   | Autor |  Rubens Takahashi     | Data | 12/09/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Consulta de Painel de Oficina                                |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXC004(lParametros,lFiltro)

Local nCntFor := 0
Local nCntFor2 := 0

Local aSizeAut	:= MsAdvSize(.f.)

Local nCorLinha1
Local nCorLinha2

Local aPosObj

Local cLogoEmpr := GetNewPar("MV_DIRFTGC","") + "ologopainel.jpg"

Local aObjTela := {}
Local aCabec := {}

Private nCorTexto1 := 32768		// OS com Servico Inicializado
Private nCorTexto2 := 36095		// OS com Servico Pausado
Private nCorTexto3 := 8388608	// OS com Servico Finalizado e Veiculo nao entregue
Private nCorTexto4 := 11209322

Private oTimerTela	// Timer para Atualizacao das OS's na Tela
Private oTimerOS	// Timer para Atualizacao das Dados da OS's

Private oTPanelBOTTOM
Private oTPanelTOP
Private oTPanel

Private oTFont
Private oTFontLD

Private nPrevDe
Private nPrevAte

Private oLetreiro

Private aDados := {}
Private aInfPainel := {}

Default lParametros := .f.
Default lFiltro := .f.

cAuxFrase := Space(15)
nPosLetr := 1

// AADD(aRegs,{STR0001,STR0001,STR0001,'MV_CH1','N',03,0,0,'G','(MV_PAR01 >= 30 )','MV_PAR01','','','','30','','','','','','','','','','','','','','','','','','','','','','','','','999',{},{},{}})
// AADD(aRegs,{STR0002,STR0002,STR0002,'MV_CH2','N',03,0,0,'G','(MV_PAR02 >= 300)','MV_PAR02','','','','300','','','','','','','','','','','','','','','','','','','','','','','','','999',{},{},{}})
// AADD(aRegs,{STR0041,STR0041,STR0041,'MV_CH3','N',03,0,0,'G','','MV_PAR03','','','','0','','','','','','','','','','','','','','','','','','','','','','','','','999',{},{},{}})
// AADD(aRegs,{STR0042,STR0042,STR0042,'MV_CH4','N',03,0,0,'G','','MV_PAR04','','','','0','','','','','','','','','','','','','','','','','','','','','','','','','999',{},{},{}})
// AADD(aRegs,{STR0003,STR0003,STR0003,'MV_CH5','C',60,0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0003,STR0003,STR0003,'MV_CH6','C',60,0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0003,STR0003,STR0003,'MV_CH7','C',60,0,0,'G','','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0006,STR0006,STR0006,'MV_CH8','N',08,0,0,'G','','MV_PAR08','','','','14540253','','','','','','','','','','','','','','','','','','','','','','','','','99999999',{},{},{}})
// AADD(aRegs,{STR0007,STR0007,STR0007,'MV_CH9','N',08,0,0,'G','','MV_PAR09','','','','15395562','','','','','','','','','','','','','','','','','','','','','','','','','99999999',{},{},{}})
// AADD(aRegs,{STR0043,STR0043,STR0043,'MV_CHA','N',08,0,0,'G','','MV_PAR10','','','','32768'   ,'','','','','','','','','','','','','','','','','','','','','','','','','99999999',{},{},{}})
// AADD(aRegs,{STR0044,STR0044,STR0044,'MV_CHB','N',08,0,0,'G','','MV_PAR11','','','','36095'   ,'','','','','','','','','','','','','','','','','','','','','','','','','99999999',{},{},{}})
// AADD(aRegs,{STR0045,STR0045,STR0045,'MV_CHC','N',08,0,0,'G','','MV_PAR12','','','','8388608' ,'','','','','','','','','','','','','','','','','','','','','','','','','99999999',{},{},{}})
// AADD(aRegs,{STR0029,STR0029,STR0029,'MV_CHD','N',08,0,0,'G','','MV_PAR13','','','','11209322','','','','','','','','','','','','','','','','','','','','','','','','','99999999',{},{},{}})
// AADD(aRegs,{STR0004,STR0004,STR0004,'MV_CHE','N',02,0,0,'G','(MV_PAR14 >= 14)','MV_PAR14','','','','21','','','','','','','','','','','','','','','','','','','','','','','','','99',{},{},{}})
// AADD(aRegs,{STR0012,STR0012,STR0012,'MV_CHF','N',02,0,0,'G','','MV_PAR15','','','','0','','','','','','','','','','','','','','','','','','','','','','','','','99',{},{},{}})
// AADD(aRegs,{STR0013,STR0013,STR0013,'MV_CHG','N',02,0,0,'G','(MV_PAR16 >= 1)','MV_PAR16','','','','5','','','','','','','','','','','','','','','','','','','','','','','','','99',{},{},{}})
// AADD(aRegs,{STR0013,STR0013,STR0013,'MV_CHH','N',02,0,0,'G','(MV_PAR17 >= 1)','MV_PAR17','','','','6','','','','','','','','','','','','','','','','','','','','','','','','','99',{},{},{}})
// AADD(aRegs,{STR0004,STR0004,STR0004,'MV_CHI','N',02,0,0,'G','','MV_PAR18','','','','40','','','','','','','','','','','','','','','','','','','','','','','','','99',{},{},{}})
// AADD(aRegs,{STR0004,STR0004,STR0004,'MV_CHJ','N',02,0,0,'G','','MV_PAR19','','','','15','','','','','','','','','','','','','','','','','','','','','','','','','99',{},{},{}})
// AADD(aRegs,{STR0046,STR0046,STR0046,'MV_CHK','C',60,0,0,'G','','MV_PAR20','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0047,STR0047,STR0047,'MV_CHL','N',03,0,0,'G','','MV_PAR21','','','','72','','','','','','','','','','','','','','','','','','','','','','','','','999',{},{},{}})
// AADD(aRegs,{STR0017,STR0017,STR0017,'MV_CHM','N',01,0,2,'C','','MV_PAR22',STR0018,STR0018,STR0018,'','',STR0019,STR0019,STR0019,'','',STR0020,STR0020,STR0020,'','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0032,STR0032,STR0032,'MV_CHN','N',01,0,2,'C','','MV_PAR23',STR0030,STR0030,STR0030,'','',STR0031,STR0031,STR0031,'','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0033,STR0033,STR0033,'MV_CHO','N',01,0,2,'C','','MV_PAR24',STR0030,STR0030,STR0030,'','',STR0031,STR0031,STR0031,'','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0034,STR0034,STR0034,'MV_CHP','N',01,0,2,'C','','MV_PAR25',STR0030,STR0030,STR0030,'','',STR0031,STR0031,STR0031,'','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0035,STR0035,STR0035,'MV_CHQ','N',01,0,1,'C','','MV_PAR26',STR0030,STR0030,STR0030,'','',STR0031,STR0031,STR0031,'','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0036,STR0036,STR0036,'MV_CHR','N',01,0,2,'C','','MV_PAR27',STR0030,STR0030,STR0030,'','',STR0031,STR0031,STR0031,'','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0037,STR0037,STR0037,'MV_CHS','N',01,0,2,'C','','MV_PAR28',STR0030,STR0030,STR0030,'','',STR0031,STR0031,STR0031,'','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0038,STR0038,STR0038,'MV_CHT','N',01,0,2,'C','','MV_PAR29',STR0030,STR0030,STR0030,'','',STR0031,STR0031,STR0031,'','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0039,STR0039,STR0039,'MV_CHU','N',01,0,2,'C','','MV_PAR30',STR0030,STR0030,STR0030,'','',STR0031,STR0031,STR0031,'','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0040,STR0040,STR0040,'MV_CHV','N',01,0,2,'C','','MV_PAR31',STR0030,STR0030,STR0030,'','',STR0031,STR0031,STR0031,'','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0048,STR0048,STR0048,'MV_CHX','N',01,0,2,'C','','MV_PAR32',STR0030,STR0030,STR0030,'','',STR0031,STR0031,STR0031,'','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// // Variaveis do Filtro (F10)
// AADD(aRegs,{STR0051,STR0051,STR0051,'MV_CHY','C',01,0,0,'G','','MV_PAR33','','','','3','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0052,STR0052,STR0052,'MV_CHW','C',01,0,0,'G','','MV_PAR34','','','','1','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0053,STR0053,STR0053,'MV_CHZ','C',01,0,0,'G','','MV_PAR35','','','','1','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0054,STR0054,STR0054,'MV_CI1','C',01,0,0,'G','','MV_PAR36','','','','1','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0055,STR0055,STR0055,'MV_CI2','C',01,0,0,'G','','MV_PAR37','','','','1','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0056,STR0056,STR0056,'MV_CI3','C',50,0,0,'G','','MV_PAR38','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0036,STR0036,STR0036,'MV_CI4','C',TamSX3("VSO_NUMBOX")[1],0,0,'G','','MV_PAR39','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{STR0037,STR0037,STR0037,'MV_CI5','C',TamSX3("VO1_FUNABE")[1],0,0,'G','','MV_PAR40','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})
// AADD(aRegs,{RetTitle("VO1_TPATEN"),RetTitle("VO1_TPATEN"),RetTitle("VO1_TPATEN"),'MV_CI6','C',TamSX3("VO1_TPATEN")[1],0,0,'G','','MV_PAR41','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',{},{},{}})


Pergunte("OXC004",.f.,,,,.f.)
if lParametros
	If !FS_PARAM() // Monta TELA com os Parametros
		OFIXC004(.f.,.f.)
		Return
	EndIf
Endif
if lFiltro
	If !OXC04filt() // Monta TELA com os Filtros
		OFIXC004(.f.,.f.)
		Return
	EndIf
Endif

Pergunte("OXC004",.f.,,,,.f.)

SETKEY(VK_F10,  {|| FS_F10F12("F10") })
SETKEY(VK_F12,  {|| FS_F10F12("F12") })

nT_AtTela	:= MV_PAR01 * 1000	// Tempo Atu. Tela
nT_AtDados	:= MV_PAR02 * 1000	// Tempo Atu. Dados
nPrevDe		:= MV_PAR03
nPrevAte	:= MV_PAR04
cFrase		:= AllTrim(MV_PAR05) +" "+ Alltrim(MV_PAR06) +" "+ Alltrim(MV_PAR07) + Space(20) 	// Texto
nCorLinha1	:= MV_PAR08				// Cor Linha 1
nCorLinha2	:= MV_PAR09				// Cor Linha 2
nCorTexto1	:= MV_PAR10				// Cor Texto 1
nCorTexto2	:= MV_PAR11				// Cor Texto 2
nCorTexto3	:= MV_PAR12				// Cor Texto 3
nCorTexto4	:= MV_PAR13				// Cor Texto 4
nAltPanel	  := MV_PAR14				// Alt. Painel
nEspPanel	  := MV_PAR15				// Esp. Painel
nTopSay		  := MV_PAR16				// Pos. Linha
nTopObj		  := MV_PAR17				// Pos. Obj.
nAltPTop	  := MV_PAR18				// Alt. Painel Sup.
nAltPBot	  := MV_PAR19				// Alt. Painel Inf.

oTFontLD    := TFont():New(AllTrim(MV_PAR20),,MV_PAR21*-1,,.f.)
nTamFonte 	:= MV_PAR22				// Tamanho da Fonte

If Empty(cFrase) .and. !File(cLogoEmpr)
	nAltPTop := 1
EndIf

// Configura as colunas que serão exibidas
aExibe := Array(AOS_TAMANHO)
aExibe[AOS_NUMOSV] 		:= (MV_PAR23 == 2)
aExibe[AOS_PLACA]		:= (MV_PAR24 == 2)
aExibe[AOS_MODELO]		:= (MV_PAR25 == 2)
aExibe[AOS_NOME]		:= (MV_PAR26 == 2)
aExibe[AOS_BOX]			:= (MV_PAR27 == 2)
aExibe[AOS_CONSULTOR]	:= (MV_PAR28 == 2)
aExibe[AOS_ENTRADA]		:= (MV_PAR29 == 2)
aExibe[AOS_SAIDA]		:= (MV_PAR30 == 2)
aExibe[AOS_PROGRESSO]	:= (MV_PAR31 == 2)
aExibe[AOS_CLIENTE]		:= .f.
aExibe[AOS_LOJA]		:= .f.
//
// Variaveis do Filtro (F10)
M->cFiltrar    :=  MV_PAR33
M->lPublico    := (MV_PAR34 == "1")
M->lGarantia   := (MV_PAR35 == "1")
M->lInterno    := (MV_PAR36 == "1")
M->lRevisao    := (MV_PAR37 == "1")
M->cExceTT     :=  MV_PAR38
M->cNumBox     :=  MV_PAR39
M->cConSultor  :=  MV_PAR40
M->VO1_TPATEN  :=  MV_PAR41
//
Do Case
Case nTamFonte == 1
	oTFont := TFont():New('Arial',,-16,,.T.)
Case nTamFonte == 2
	oTFont := TFont():New('Arial',,-20,,.T.)
Case nTamFonte == 3
	oTFont := TFont():New('Arial',,-24,,.T.)
End

// Monta Dialog Principal
oMainWnd:ReadClientCoors()
If FlatMode()
	nTop       := 0
	nLeft      := 0
	nBottom    := aSizeAut[6]
	nRight     := aSizeAut[5]
Else
	nTop       := oMainWnd:nTop+10
	nLeft      := oMainWnd:nLeft+5
	nBottom    := oMainWnd:nBottom-20
 	nRight     := oMainWnd:nRight-10
EndIf
DEFINE MSDIALOG oDlgOS TITLE "" OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight //STYLE nStyle
oDlgOS:lEscClose := .T.
oDlgOS:lMaximized := .t.
If !FlatMode()
	oDlgOS:ReadClientCoors()
EndIf

nAuxAltura := 0

// Timer para atualizacao da Lista de OS na Tela
oTimerTela := TTimer():New(nT_AtTela , {|| OXC04ATPN() }, oDlgOS )
oTimerOS   := TTimer():New(nT_AtDados, {|| OXC04ATDAD() }, oDlgOS )

oTPanelTOP := TPanel():New(0,0,"",oDlgOS,NIL,.T.,.F.,NIL,CLR_BLACK,(oDlgOS:nClientWidth / 2),nAltPTop,.F.,.F.)
oTPanelTOP:ReadClientCoors()

// Calcula a Altura do painel com as OS's
nAuxAltura := ( ( oDlgOS:nClientHeight - oTPanelTOP:nHeight ) / 2 ) - nAltPBot
nQtdPanel := Int( nAuxAltura / (nAltPanel + nEspPanel) )
nDif := nAuxAltura - ( nQtdPanel * ( nAltPanel + nEspPanel ) )
nAuxAltura -= nDif
nAltPBot += nDif
nQtdPanel -= 1	// Desconsidera o Cabecalho
//

oTPanel := TPanel():New(;
	(oTPanelTOP:nHeight / 2),;
	0,;
	"",oDlgOS,NIL,.T.,.F.,NIL,;
	107423,;
	(oDlgOS:nClientWidth / 2),;
	nAuxAltura,;
	.F.,.F.)
oTPanel:ReadClientCoors()

oTPanelBOTTOM := TPanel():New(;
	( (oTPanelTOP:nHeight + oTPanel:nHeight) / 2),;
	0,;
	,;
	oDlgOS,;
	oTFontLD,;
	.F.,.F.,NIL,;
	NIL,;
	(oDlgOS:nClientWidth / 2),;
	nAltPBot,;
	.F.,.T.)
oTPanelBOTTOM:ReadClientCoors()

// Legenda no painel inferior
aObjTela := {}
AADD( aObjTela, { 29 , 15 , .T. , .T. , .T. } )
AADD( aObjTela, { 24 , 15 , .T. , .T. , .T. } )
AADD( aObjTela, { 25 , 15 , .T. , .T. , .T. } )
AADD( aObjTela, { 22 , 15 , .T. , .T. , .T. } )
aPosObj   := MsObjSize( { aSizeAut[ 1 ] , aSizeAut[ 2 ] , aSizeAut[ 3 ] , (oTPanelBOTTOM:nClientHeight / 2) , 2 , 0 } , aObjTela , .T. , .T. )
TSay():New( 5 , aPosObj[1,2]+00 , { || STR0043 } , oTPanelBOTTOM,,oTFont,,,,.T.,nCorTexto1,,200,20) 	// 'OS com serviço(s) em andamento'
TSay():New( 5 , aPosObj[2,2]+00 , { || STR0044 } , oTPanelBOTTOM,,oTFont,,,,.T.,nCorTexto2,,200,20)	// 'OS com serviço(s) em pausa'
TSay():New( 5 , aPosObj[3,2]+00 , { || STR0045 } , oTPanelBOTTOM,,oTFont,,,,.T.,nCorTexto3,,200,20) 	// 'OS liberada para faturamento'
TSay():New( 5 , aPosObj[4,2]+00 , { || STR0029 } , oTPanelBOTTOM,,oTFont,,,,.T.,nCorTexto4,,200,20) 	// 'Aguardando Orçamento'
//

// Bitmap do Logotipo
If File(cLogoEmpr)
	TBitmap():New( 002 , 005 , 150 ,  (oTPanelTOP:nClientHeight / 2) - 10 ,,cLogoEmpr,.T.,oTPanelTOP,,,.T.,.F.,,,.F.,,.T.,,.F.)
EndIf
//

oLetreiro := TSay():New( 001 , 170 , { || cAuxFrase } , oTPanelTOP,,oTFontLD,,,,.T.,CLR_WHITE,CLR_BLACK,2000,200)

// Configura se a coluna pode ou nao ser redimensionada
aConfCol := Array(AOS_TAMANHO)
aConfCol[AOS_PROGRESSO]	:= .f.
aConfCol[AOS_NUMOSV] 	:= .f.
aConfCol[AOS_PLACA]		:= .f.
aConfCol[AOS_MODELO]	:= .t.
aConfCol[AOS_CONSULTOR]	:= .t.
aConfCol[AOS_BOX]		:= .f.
aConfCol[AOS_ENTRADA]	:= .f.
aConfCol[AOS_SAIDA]		:= .f.
aConfCol[AOS_CLIENTE]	:= .f.
aConfCol[AOS_LOJA]		:= .f.
aConfCol[AOS_NOME]		:= .t.

aTamCol  := Array(AOS_TAMANHO,3)
// Configura Colunas para Tamanho de Fonte Pequena
aTamCol[AOS_PROGRESSO,1]:= 60
aTamCol[AOS_NUMOSV,1] 	:= 50
aTamCol[AOS_PLACA,1]	:= 55
aTamCol[AOS_MODELO,1]	:= 60
aTamCol[AOS_CONSULTOR,1]:= 50
aTamCol[AOS_BOX,1]		:= 40
aTamCol[AOS_ENTRADA,1]	:= 85
aTamCol[AOS_SAIDA,1]	:= 85
aTamCol[AOS_CLIENTE,1]	:= 45
aTamCol[AOS_LOJA,1]		:= 20
aTamCol[AOS_NOME,1]		:= 50

// Configura Colunas para Tamanho de Fonte Media
aTamCol[AOS_PROGRESSO,2]:= 60
aTamCol[AOS_NUMOSV,2] 	:= 50
aTamCol[AOS_PLACA,2]	:= 55
aTamCol[AOS_MODELO,2]	:= 60
aTamCol[AOS_CONSULTOR,2]:= 50
aTamCol[AOS_BOX,2]		:= 40
aTamCol[AOS_ENTRADA,2]	:= 95
aTamCol[AOS_SAIDA,2]	:= 95
aTamCol[AOS_CLIENTE,2]	:= 45
aTamCol[AOS_LOJA,2]		:= 20
aTamCol[AOS_NOME,2]		:= 50

// Configura Colunas para Tamanho de Fonte Grande
aTamCol[AOS_PROGRESSO,3]:= 60
aTamCol[AOS_NUMOSV,3] 	:= 55
aTamCol[AOS_PLACA,3]	:= 60
aTamCol[AOS_MODELO,3]	:= 30
aTamCol[AOS_CONSULTOR,3]:= 30
aTamCol[AOS_BOX,3]		:= 35
aTamCol[AOS_ENTRADA,3]	:= 110
aTamCol[AOS_SAIDA,3]	:= 110
aTamCol[AOS_CLIENTE,3]	:= 90
aTamCol[AOS_LOJA,3]		:= 20
aTamCol[AOS_NOME,3]		:= 50

aObjTela := {}
aCabec := {}
aConfPainel := {}
If aExibe[AOS_NUMOSV]
	AADD( aObjTela, { aTamCol[AOS_NUMOSV,nTamFonte] , nAltPanel , aConfCol[AOS_NUMOSV] , .T. , .T. } )
	AADD( aCabec , STR0032 ) // OS
	AADD( aConfPainel , { AOS_NUMOSV , 1 } )
EndIf
If aExibe[AOS_PLACA]
	AADD( aObjTela, { aTamCol[AOS_PLACA,nTamFonte] , nAltPanel ,aConfCol[AOS_PLACA]  , .T. , .T. } )
	AADD( aCabec , STR0033 ) // Placa
	AADD( aConfPainel , { AOS_PLACA , 1 } )
EndIf
If aExibe[AOS_MODELO]
	AADD( aObjTela, { aTamCol[AOS_MODELO,nTamFonte] , nAltPanel , aConfCol[AOS_MODELO] , .T. , .T. } )
	AADD( aCabec , STR0034 ) // Modelo
	AADD( aConfPainel , { AOS_MODELO , 1 } )
EndIf
If aExibe[AOS_NOME]
	AADD( aObjTela, { aTamCol[AOS_NOME,nTamFonte] , nAltPanel , aConfCol[AOS_NOME] , .T. , .T. } )
	AADD( aCabec , STR0035 ) // Cliente
	AADD( aConfPainel , { AOS_NOME , 1 } )
EndIf
If aExibe[AOS_BOX]
	AADD( aObjTela, { aTamCol[AOS_BOX,nTamFonte] , nAltPanel , aConfCol[AOS_BOX] , .T. , .T. } )
	AADD( aCabec , STR0036 ) // Box
	AADD( aConfPainel , { AOS_BOX , 1 } )
EndIf
If aExibe[AOS_CONSULTOR]
	AADD( aObjTela, { aTamCol[AOS_CONSULTOR,nTamFonte] , nAltPanel , aConfCol[AOS_CONSULTOR] , .T. , .T. } )
	AADD( aCabec , STR0037 ) // Consultor
	AADD( aConfPainel , { AOS_CONSULTOR , 1 } )
EndIf
If aExibe[AOS_ENTRADA]
	AADD( aObjTela, { aTamCol[AOS_ENTRADA,nTamFonte] , nAltPanel , aConfCol[AOS_ENTRADA] , .T. , .T. } )
	AADD( aCabec , STR0038 ) // Entrada
	AADD( aConfPainel , { AOS_ENTRADA , 1 } )
EndIf
If aExibe[AOS_SAIDA]
	AADD( aObjTela, { aTamCol[AOS_SAIDA,nTamFonte] , nAltPanel , aConfCol[AOS_SAIDA] , .T. , .T. } )
	AADD( aCabec , STR0039 ) // Previsão Saída
	AADD( aConfPainel , { AOS_SAIDA , 1 } )
EndIf
If aExibe[AOS_PROGRESSO]
	AADD( aObjTela, { aTamCol[AOS_PROGRESSO,nTamFonte],  nAltPanel , aConfCol[AOS_PROGRESSO] , .T. , .T. } )
	AADD( aCabec , STR0040 ) // Progresso
	AADD( aConfPainel , { AOS_PROGRESSO , 2 } )
EndIf
aPosObj   := MsObjSize( { aSizeAut[ 1 ] , aSizeAut[ 2 ] , aSizeAut[ 3 ] , nAltPanel , 2 , 0 } , aObjTela , .T. , .T. )

nAuxLinha := 0
oPanelCabec := TPanel():New(nAuxLinha,0,"",oTPanel,NIL,.T.,.F.,NIL,0,(oTPanel:nClientWidth / 2),nAltPanel,.F.,.T.)
nAuxLinha += nAltPanel + nEspPanel

For nCntFor := 1 to Len(aCabec)
	TSay():New( nTopSay , aPosObj[nCntFor,2] , &("{ || '" + aCabec[nCntFor] + "' }") , oPanelCabec,,oTFont,,,,.T.,CLR_WHITE,,200,20)
Next nCntFor

For nCntFor := 1 to nQtdPanel

	AADD( aInfPainel , Array(Len(aConfPainel)) )
	AFill( aInfPainel[nCntFor] , "" )

	SetPrvt("oPanel" + AllTrim(Str(nCntFor)))

	&("oPanel" + AllTrim(Str(nCntFor))) := TPanel():New(nAuxLinha,0,"",oTPanel,NIL,.T.,.F.,NIL,IIf( MOD(nCntFor,2) <> 0 , nCorLinha1 , nCorLinha2 ),(oTPanel:nClientWidth / 2),nAltPanel,.F.,.T.)
	nAuxLinha += nAltPanel + nEspPanel

	// Monta os Objetos para exibicao dos textos
	For nCntFor2 := 1 to Len(aConfPainel)
		Do Case
		Case aConfPainel[nCntFor2,2] == 1
			&("oSay_" + AllTrim(Str(nCntFor)) + "_" + AllTrim(Str(nCntFor2))) := TSay():New( nTopSay , aPosObj[nCntFor2,2] , &("{ || aInfPainel[" + AllTrim(Str(nCntFor)) + "," + AllTrim(Str(nCntFor2)) + "] }") , &("oPanel" + AllTrim(Str(nCntFor))),,oTFont,,,,.T.,,,200,20)
		Case aConfPainel[nCntFor2,2] == 2
			&("oMeter" + AllTrim(Str(nCntFor)))  := TMeter():New(nTopObj , aPosObj[nCntFor2,02],&("{ |u| IIf( PCount() > 0 , aInfPainel[" + AllTrim(Str(nCntFor)) + "," + AllTrim(Str(nCntFor2)) + "] := u , aInfPainel[" + AllTrim(Str(nCntFor)) + "," + AllTrim(Str(nCntFor2)) + "] )}"),100,&("oPanel" + AllTrim(Str(nCntFor))),aPosObj[nCntFor2,03]-10,12,,.T.,,,.T.,)
			&("oMeter" + AllTrim(Str(nCntFor)) + ":SetTotal(100)")
		End
	Next
	//


Next nCntFor

// Cria um separador entre as OS's e o oTPanelBOTTOM
If nEspPanel == 0
	nEspPanel := 2
EndIf
nAuxLinha -= nEspPanel
TPanel():New(nAuxLinha,0,"",oTPanel,NIL,.T.,.F.,CLR_BLACK,0,(oTPanel:nClientWidth / 2),nEspPanel,.F.,.T.)
//

nProximo := 0

OXC04ATDAD()
OXC04ATPN()

//
SETKEY(VK_F11,  {|| OXC04ATPN() })
//

oTimerTela:Activate()
oTimerOS:Activate()

If !Empty(cFrase)
	oTimerLetr := TTimer():New(1000,   {|| OXC04ATLET(1) }, oDlgOS )
	oTimerLet2 := TTimer():New(1000,   {|| OXC04ATLET(2) }, oDlgOS )
	oTimerLet3 := TTimer():New(1500,   {|| OXC04ATLET(3) }, oDlgOS )
	oTimerSync := TTimer():New(600000, {|| OXC04SYNCT()  }, oDlgOS )

	OXC04SYNCT()
	oTimerSync:Activate()
EndIf

ACTIVATE MSDIALOG oDlgOS //CENTER

SetKey(VK_F10,Nil)
SetKey(VK_F11,Nil)
SetKey(VK_F12,Nil)

Return

/*/{Protheus.doc} FS_F10F12
	Chamada do F10 ou do F12 - Fecha rotina e reabre

	@author Manoel Filho
	@since  27/07/2017
	@param  Se "F10" Chama OFIXC004 e abre a tela de Filtro
					Se "F12" Chama OFIXC004 e abre a tela de Parâmetros
	@return
/*/
Static Function FS_F10F12(cChmF)
SetKey(VK_F10,Nil)
SetKey(VK_F11,Nil)
SetKey(VK_F12,Nil)

oDlgOS:End()

If cChmF == "F10"
	OFIXC004(.f.,.t.)
Else // F12
	OFIXC004(.t.,.f.)
Endif

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OXC04SYNCT | Autor |  Rubens Takahashi     | Data | 12/09/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Sincroniza o Timer do Letreiro                               |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OXC04SYNCT()
oTimerLetr:DeActivate()
oTimerLet2:DeActivate()
oTimerLet3:DeActivate()

oTimerLetr:Activate()
oTimerLet3:Activate()
Return



/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OXC04ATLET | Autor |  Rubens Takahashi     | Data | 12/09/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Atualiza o Letreiro                                          |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OXC04ATLET(nTimer)

Local nPula := 1

If nTimer == 3
	oTimerLet3:DeActivate()
	oTimerLet2:Activate()
EndIf

cAuxFrase := Right(cAuxFrase,Len(cAuxFrase)-nPula) + SubStr(cFrase,nPosLetr,nPula)
nPosLetr += nPula

If nPosLetr >= Len(cFrase)
	nPosLetr := 1
EndIf
If oLetreiro <> nil
	oLetreiro:Refresh()
Endif

Return

/*/{Protheus.doc} OXC04ATDAD
	Atualiza os dados para exibicao

	@authorRubens Takahashi
	@since  12/09/2012
	@param
	@return
/*/
Static Function OXC04ATDAD()

Local cSQL
Local cAliasOS   := GetNextAlias()
Local cAliasVEIC := GetNextAlias()
Local aInfOS := {}
Local nCont
Local nCont2
Local nHora := Val(Substr(time(),1,2)+Substr(time(),4,2))

aEval( aDados , { |x| x[AOS_ATUALIZADO] := .f. } )

// Desabilita momentaneamente o Timer da Tela
oTimerTela:DeActivate()

// Seleciona todas as OS's com agendamento e Apontamento Inicial
cSQL := "SELECT DISTINCT '1' TPREG , VSO_NUMIDE CHAVE , VSO_STATUS STATUS "
cSQL += " FROM " + RetSQLName("VSO") + " VSO "
cSQL += " WHERE VSO_FILIAL = '" + xFilial("VSO") + "'"
cSQL +=   " AND VSO_AGCONF = '2' " // Cliente presente na concessionaria
cSQL +=   " AND VSO_STATUS IN ('1','2','3','5')"
cSQL +=   " AND VSO.D_E_L_E_T_ = ' '"
cSQL +=   " AND VSO_DATAGE >= '" + DtoS(dDataBase - nPrevDe) + "'"
cSQL +=   " AND VSO_DATAGE <= '" + DtoS(dDataBase + nPrevAte) + "'"
cSQL +=   " AND NOT EXISTS (SELECT VO1_NUMOSV FROM " + RetSQLName("VS1") + " VS1 "
cSQL +=                                     " JOIN " + RetSQLName("VO1") + " VO1 ON VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1_NUMOSV = VS1_NUMOSV AND VO1.D_E_L_E_T_ = ' '"
cSQL +=                                   " WHERE VS1_FILIAL = '" + xFilial("VS1") + "' AND VS1_NUMAGE = VSO_NUMIDE AND VS1.D_E_L_E_T_ = ' ')"
cSQL += " UNION "
cSQL += "SELECT DISTINCT '2' TPREG, VO1_NUMOSV CHAVE , VO1_STATUS STATUS "
cSQL +=  " FROM " + RetSQLName("VO1") + " VO1 "
cSQL += " WHERE VO1_FILIAL = '" + xFilial("VO1") + "'"
cSQL +=   " AND VO1_STATUS IN ('A','D')"
cSQL +=   " AND VO1_DATSAI = '        ' "
cSQL +=   " AND VO1_DATENT >= '" + DtoS(dDataBase - nPrevDe) + "'"
cSQL +=   " AND VO1_DATENT <= '" + DtoS(dDataBase + nPrevAte) + "'"
cSQL +=   " AND VO1.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasOS , .F., .T. )
While (cAliasOS)->(!Eof())

	nAuxPos := aScan( aDados , { |x| x[AOS_CHAVE] == (cAliasOS)->TPREG + (cAliasOS)->CHAVE } )
	If nAuxPos == 0

		Do Case
		Case (cAliasOS)->TPREG == "1"
			cSQL := "SELECT ' ' NUMOSV, VSO_PLAVEI PLAVEI, VSO_NUMBOX NUMBOX, VSO_DATAGE DATABE, VSO_HORAGE HORABE, '  ' DATENT, 0 HORENT, VVR_DESCRI, VAI_CODTEC, VAI_NOMTEC, VSO_PROVEI CLIENTE, VSO_LOJPRO LOJA, VSO_NOMPRO NOME "
			cSQL += " FROM " + RetSQLName("VSO") + " VSO "
			cSQL +=       " LEFT JOIN " + RetSQLName("VV2") + " VV2 ON VV2.VV2_FILIAL = '" + xFilial("VV2") + "' AND VV2_CODMAR = VSO_CODMAR AND VV2_MODVEI = VSO_MODVEI AND VV2.D_E_L_E_T_ = ' '"
			cSQL +=       " LEFT JOIN " + RetSQLName("VVR") + " VVR ON VVR.VVR_FILIAL = '" + xFilial("VVR") + "' AND VVR_CODMAR = VV2_CODMAR AND VVR_GRUMOD = VV2_GRUMOD AND VVR.D_E_L_E_T_ = ' '"
			cSQL +=  " LEFT JOIN " + RetSqlName("VON") + " VON ON VON.VON_FILIAL = '" + xFilial("VON") + "' AND VON_NUMBOX = VSO_NUMBOX AND VON.D_E_L_E_T_ = ' '"
			cSQL +=  " LEFT JOIN " + RetSqlName("VAI") + " VAI ON VAI.VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODTEC = VON_CODPRO AND VAI.D_E_L_E_T_ = ' '"
			cSQL += " WHERE VSO_FILIAL  = '" + xFilial("VSO") + "'"
			cSQL +=   " AND VSO_NUMIDE = '" + (cAliasOS)->CHAVE + "'"
			If !Empty(M->cNumBox)
				cSQL +=   " AND VSO_NUMBOX = '" + M->cNumBox + "'"
			Endif
			cSQL +=   " AND VSO.D_E_L_E_T_ = ' '"
		Case (cAliasOS)->TPREG == "2"
			cSQL := "SELECT VO1_NUMOSV NUMOSV, VO1_PLAVEI PLAVEI, VO1_NUMBOX NUMBOX, VO1_DATABE DATABE, VO1_HORABE HORABE, VO1_DATENT DATENT, VO1_HORENT HORENT, VVR_DESCRI, VAI_CODTEC, VAI_NOMTEC, VO1_PROVEI CLIENTE, VO1_LOJPRO LOJA, A1_NOME NOME "
			cSQL += " FROM " + RetSQLName("VO1") + " VO1 "
			cSQL += 	" JOIN " + RetSQLName("VV1") + " VV1 ON VV1_FILIAL = '" + xFilial("VV1") + "' AND VV1_CHAINT = VO1_CHAINT AND VV1.D_E_L_E_T_ = ' '"
			cSQL += 	" LEFT JOIN " + RetSQLName("VV2") + " VV2 ON VV2_FILIAL = '" + xFilial("VV2") + "' AND VV2_CODMAR = VV1_CODMAR AND VV2_MODVEI = VV1_MODVEI AND VV2.D_E_L_E_T_ = ' '"
			cSQL += 	" LEFT JOIN " + RetSQLName("VVR") + " VVR ON VVR_FILIAL = '" + xFilial("VVR") + "' AND VVR_CODMAR = VV2_CODMAR AND  VVR_GRUMOD = VV2_GRUMOD AND VVR.D_E_L_E_T_ = ' '"
			cSQL += 	" JOIN " + RetSQLName("SA1") + " A1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = VO1_PROVEI AND A1_LOJA = VO1_LOJPRO AND A1.D_E_L_E_T_ = ' '"
			cSQL += 	" LEFT JOIN " + RetSQLName("VAI") + " VAI ON VAI_FILIAL = '" + xFilial("VAI") + "' AND VAI_CODTEC = VO1_FUNABE AND VVR.D_E_L_E_T_ = ' '"
			cSQL += " WHERE VO1_FILIAL  = '" + xFilial("VO1") + "'"
			cSQL +=   " AND VO1_NUMOSV = '" + (cAliasOS)->CHAVE + "'"
			If !Empty(M->cNumBox)
				cSQL +=   " AND VO1_NUMBOX = '" + M->cNumBox + "'"
			Endif
			If !Empty(M->VO1_TPATEN)
				cSQL +=   " AND VO1_TPATEN = '" + M->VO1_TPATEN + "'"
			Endif
			cSQL +=   " AND VO1.D_E_L_E_T_ = ' '"
		End
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVEIC , .F., .T. )
		If  ( (cAliasOS)->TPREG == "1" .and. M->cFiltrar == "1") .or. ;	// Apenas Agendamento
				( (cAliasOS)->TPREG == "2" .and. M->cFiltrar == "2") .or.;	// Apenas OS's
			 	M->cFiltrar == "3" // Ambos

			AADD( aDados , Array(AOS_TAMANHO) )
			nAuxPos := Len(aDados)
			aDados[nAuxPos,AOS_CHAVE]		:= (cAliasOS)->TPREG + (cAliasOS)->CHAVE
			aDados[nAuxPos,AOS_STATUS]		:= 2
			aDados[nAuxPos,AOS_PROGRESSO]	:= 0
			aDados[nAuxPos,AOS_NUMOSV] 		:= (cAliasVEIC)->NUMOSV
			aDados[nAuxPos,AOS_PLACA]  		:= Transform((cAliasVEIC)->PLAVEI,X3Picture("VV1_PLAVEI"))
			aDados[nAuxPos,AOS_BOX]			:= (cAliasVEIC)->NUMBOX
			aDados[nAuxPos,AOS_ENTRADA]		:= DtoC(StoD((cAliasVEIC)->DATABE)) + " - " + Transform( (cAliasVEIC)->HORABE , "@R 99:99" ) + "h"
			aDados[nAuxPos,AOS_SAIDA]		:= DtoC(StoD((cAliasVEIC)->DATENT)) + " - " + Transform( (cAliasVEIC)->HORENT , "@R 99:99" ) + "h"
			aDados[nAuxPos,AOS_CLIENTE]		:= (cAliasVEIC)->CLIENTE
			aDados[nAuxPos,AOS_LOJA]		:= (cAliasVEIC)->LOJA

			Do Case
			Case nTamFonte == 1
				aDados[nAuxPos,AOS_MODELO] 	:= Left((cAliasVEIC)->VVR_DESCRI,13)
				aDados[nAuxPos,AOS_CONSULTOR]	:= Left((cAliasVEIC)->VAI_NOMTEC,13)
				aDados[nAuxPos,AOS_NOME]		:= Left((cAliasVEIC)->NOME,13)
			Case nTamFonte == 2
				aDados[nAuxPos,AOS_MODELO] 	:= Left((cAliasVEIC)->VVR_DESCRI,13)
				aDados[nAuxPos,AOS_CONSULTOR]	:= Left((cAliasVEIC)->VAI_NOMTEC,13)
				aDados[nAuxPos,AOS_NOME]		:= Left((cAliasVEIC)->NOME,13)
			Case nTamFonte == 3
				aDados[nAuxPos,AOS_MODELO] 	:= Left((cAliasVEIC)->VVR_DESCRI,13)
				aDados[nAuxPos,AOS_CONSULTOR]	:= Left((cAliasVEIC)->VAI_NOMTEC,07)
				aDados[nAuxPos,AOS_NOME]		:= Left((cAliasVEIC)->NOME,13)
			End
		Endif
		//
		If !Empty(M->cConSultor)
			If Alltrim((cAliasVEIC)->VAI_CODTEC) <> Alltrim(M->cConSultor)
				(cAliasVEIC)->(DbCloseArea())
				(cAliasOS)->(dbSkip())
				Loop
			EndIf
		Endif
		//
		(cAliasVEIC)->(DbCloseArea())
		dbSelectArea(cAliasOS)

	EndIf

	If Len(aDados) > 0 .and. nAuxPos > 0

		// Marca que o registro foi atualizado
		aDados[nAuxPos,AOS_ATUALIZADO] := .t.
		//

		If (cAliasOS)->TPREG == "1"
			aDados[nAuxPos,AOS_STATUS] := 4
			aDados[nAuxPos,AOS_TEMPAD] := 100
			aDados[nAuxPos,AOS_TEMTRAB] := 0
			aDados[nAuxPos,AOS_PROGRESSO] := 0
		EndIf

		// Registro de OS
		If (cAliasOS)->TPREG == "2"

			// Se faz necessária a chamada da FMX_CALSER quando:
			If (cAliasOS)->STATUS == "A" .or. ; // OS Aberta
				( !M->lPublico  .or.;  // Não Lista Situação de TT Publico
					!M->lGarantia .or.;	 // Não Lista Situação de TT Garantia
					!M->lInterno  .or.;  // Não Lista Situação de TT Interno
					!M->lRevisao  .or.;  // Não Lista Situação de TT Revisao
					!Empty(M->cExceTT) ) // Não lista alguns Tipos de Tempo

				aInfOS := FMX_CALSER( (cAliasOS)->CHAVE ,;
									/* cTipTem */ ,;
									/* cGruSer */ ,;
									/* cCodSer */ ,;
									.T. /* lApont */ ,;
									.F. /* lNegoc */ ,;
									.T. /* lRetAbe */ ,;
									.T. /* lRetLib */ ,;
									.T. /* lRetFec */ ,;
									.F. /* lRetCan */ )

				aDados[nAuxPos,AOS_TEMPAD] := 0
				aDados[nAuxPos,AOS_TEMTRAB] := 0
				
				// Atualiza Tempo Padrao / Trabalhado
				For nCont := 1 to Len(aInfOS)

					If Alltrim(aInfOS[nCont,4]) $ cExceTT
						Loop
					EndIf

					If !M->lPublico .or. !M->lGarantia .or. !M->lInterno .or. !M->lRevisao
						VOI->(dbSetOrder(1))
						VOI->(MSSeek(xFilial("VOI")+aInfOS[nCont,4]))
						If (!M->lPublico  .and. VOI->VOI_SITTPO == "1") .or. ; // Não Lista Situação do tipo de Tempo Publico
								(!M->lGarantia .and. VOI->VOI_SITTPO == "2") .or. ; // Não Lista Situação do tipo de Tempo Publico
								(!M->lInterno  .and. VOI->VOI_SITTPO == "3") .or. ; // Não Lista Situação do tipo de Tempo Publico
								(!M->lRevisao  .and. VOI->VOI_SITTPO == "4")        // Não Lista Situação do tipo de Tempo Publico
								Loop
						Endif
					Endif

					aDados[nAuxPos,AOS_TEMPAD] += aInfOS[nCont,10]

					For nCont2 := 1 to Len(aInfOS[nCont,14])
						// Apontamento Inicializado
						If !Empty(aInfOS[nCont,14,nCont2,02])
							// Apontamento Finalizado
							If !Empty(aInfOS[nCont,14,nCont2,04])

								If aDados[nAuxPos,AOS_STATUS] <> 1 .and. aDados[nAuxPos,AOS_STATUS] <> 3
									aDados[nAuxPos,AOS_STATUS] := 2
								EndIf

								aDados[nAuxPos,AOS_TEMTRAB] += aInfOS[nCont,14,nCont2,06]
							Else
								If aDados[nAuxPos,AOS_STATUS] <> 3
									aDados[nAuxPos,AOS_STATUS] := 1
								EndIf

								aDados[nAuxPos,AOS_TEMTRAB] += FG_TEMPTRA( aInfOS[nCont,14,nCont2,01] ,;
											aInfOS[nCont,14,nCont2,02] ,;
											aInfOS[nCont,14,nCont2,03] ,;
											dDataBase,;
											nHora,;
											"N",;
											,;
											,;
											aInfOS[nCont,14,nCont2,09] + aInfOS[nCont,14,nCont2,07],,)

							EndIf
						EndIf
					Next nCont2

				Next nCont
			//
			Endif
			//
			If aDados[nAuxPos,AOS_TEMPAD] == 0
				aDados[nAuxPos,AOS_ATUALIZADO] := .f.
				(cAliasOS)->(dbSkip())
				Loop
			Endif
			//
			If (cAliasOS)->STATUS == "D"
				aDados[nAuxPos,AOS_STATUS] := 3
				aDados[nAuxPos,AOS_TEMPAD] := 100
				aDados[nAuxPos,AOS_TEMTRAB] := 100
				aDados[nAuxPos,AOS_PROGRESSO] := 100
			EndIf
			// Calcula Progresso
			aDados[nAuxPos,AOS_PROGRESSO] := ( aDados[nAuxPos,AOS_TEMTRAB] / aDados[nAuxPos,AOS_TEMPAD] ) * 100
			If aDados[nAuxPos,AOS_PROGRESSO] > 100
				aDados[nAuxPos,AOS_PROGRESSO] := 100
			EndIf
				//
		EndIf

	EndIf

	(cAliasOS)->(dbSkip())
End
(cAliasOS)->(dbCloseArea())
dbSelectArea("VSO")

// Remove as linhas que nao foram atualizadas...
// OS provavelmente nao deve mais ser exibida ...
nAuxPos := 1
While nAuxPos <= Len(aDados)
	If !aDados[nAuxPos,AOS_ATUALIZADO] .or. Empty(aDados[nAuxPos,AOS_CLIENTE])
		ADel( aDados , nAuxPos )
		ASize( aDados , Len(aDados) - 1)
	Else
		nAuxPos++
	End
End
//
oTimerTela:Activate()
//
Return


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OXC04ATPN  | Autor |  Rubens Takahashi     | Data | 12/09/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Atualiza tela com informacoes das OS's                       |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OXC04ATPN()


Local nCntFor2

Local nPosInfPainel := 0

Local nAuxCor := 0



if MV_PAR32 == 1
	If nQtdPanel >= Len(aDados) .or. (nProximo + 1) > Len(aDados)
		nProximo := 0
	EndIf
	++nProximo
Else
	If nQtdPanel >= Len(aDados) .or. (nProximo + nQtdPanel) > Len(aDados) .or. nProximo == 0
		nProximo := 1
	Else
		nProximo += nQtdPanel
	EndIf
Endif

nPosAVei := nProximo
For nPosInfPainel := 1 to nQtdPanel

	If nPosInfPainel <= Len(aDados) .AND. nPosAVei <= Len(aDados)

		Do Case
		// Servico Iniciado em Andamento
		Case aDados[nPosAVei,AOS_STATUS] == 1
			nAuxCor := nCorTexto1
		// Servico Iniciado e Pausado
		Case aDados[nPosAVei,AOS_STATUS] == 2
			nAuxCor := nCorTexto2
		// Servico Finalizado
		Case aDados[nPosAVei,AOS_STATUS] == 3
			nAuxCor := nCorTexto3
		// Aguardando Orcamento
		Case aDados[nPosAVei,AOS_STATUS] == 4
			nAuxCor := nCorTexto4
		Otherwise
			nAuxCor := CLR_BLACK
		End

		For nCntFor2 := 1 to Len(aConfPainel)
			aInfPainel[nPosInfPainel,nCntFor2] := aDados[nPosAVei,aConfPainel[nCntFor2,1]]
			Do Case
			Case aConfPainel[nCntFor2,2] == 1
				&("oSay_" + AllTrim(Str(nPosInfPainel)) + "_" + AllTrim(Str(nCntFor2)) + ":nClrText := " + Str(nAuxCor))
				&("oSay_" + AllTrim(Str(nPosInfPainel)) + "_" + AllTrim(Str(nCntFor2)) + ":Refresh()")
			Case aConfPainel[nCntFor2,2] == 2
				&("oMeter" + AllTrim(Str(nPosInfPainel)) + ":Set(" + AllTrim(Str(aDados[nPosAVei,aConfPainel[nCntFor2,1]])) + ")")
				&("oMeter" + AllTrim(Str(nPosInfPainel)) + ":lVisible") := .t.
			End
		Next nCntFor2

		If (nPosAVei + 1) > Len(aDados) .AND. MV_PAR32 == 1
			nPosAVei := 1
		Else
			++nPosAVei
		EndIf
	Else

		AFill( aInfPainel[nPosInfPainel] , "" )
		For nCntFor2 := 1 to Len(aConfPainel)
			Do Case
			Case aConfPainel[nCntFor2,2] == 1
				&("oSay_" + AllTrim(Str(nPosInfPainel)) + "_" + AllTrim(Str(nCntFor2)) + ":Refresh()")
			Case aConfPainel[nCntFor2,2] == 2
				&("oMeter" +AllTrim(Str(nPosInfPainel))+":lVisible") := .f.
			End
		Next nCntFor2


	EndIf

Next nPosInfPainel

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    |  FS_PARAM  | Autor | Andre Luis Almeida    | Data | 05/10/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Monta tela com os parametros (SX1) da Rotina                 |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_PARAM()
Local lOk       := .f.
Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private xMV_PAR01 := MV_PAR01
Private xMV_PAR02 := MV_PAR02
Private xMV_PAR03 := MV_PAR03
Private xMV_PAR04 := MV_PAR04
Private xMV_PAR05 := left(MV_PAR05+space(60),60)
Private xMV_PAR06 := left(MV_PAR06+space(60),60)
Private xMV_PAR07 := left(MV_PAR07+space(60),60)
Private xMV_PAR08 := MV_PAR08
Private xMV_PAR09 := MV_PAR09
Private xMV_PAR10 := MV_PAR10
Private xMV_PAR11 := MV_PAR11
Private xMV_PAR12 := MV_PAR12
Private xMV_PAR13 := MV_PAR13
Private xMV_PAR14 := MV_PAR14
Private xMV_PAR15 := MV_PAR15
Private xMV_PAR16 := MV_PAR16
Private xMV_PAR17 := MV_PAR17
Private xMV_PAR18 := MV_PAR18
Private xMV_PAR19 := MV_PAR19
Private xMV_PAR20 := left(MV_PAR20+space(60),60)
Private xMV_PAR21 := MV_PAR21
Private xMV_PAR22 := strzero(MV_PAR22,1)
Private xMV_PAR23 := strzero(MV_PAR23-1,1)
Private xMV_PAR24 := strzero(MV_PAR24-1,1)
Private xMV_PAR25 := strzero(MV_PAR25-1,1)
Private xMV_PAR26 := strzero(MV_PAR26-1,1)
Private xMV_PAR27 := strzero(MV_PAR27-1,1)
Private xMV_PAR28 := strzero(MV_PAR28-1,1)
Private xMV_PAR29 := strzero(MV_PAR29-1,1)
Private xMV_PAR30 := strzero(MV_PAR30-1,1)
Private xMV_PAR31 := strzero(MV_PAR31-1,1)
Private xMV_PAR32 := strzero(MV_PAR32-1,1)
Private aMV_PAR22 := {"1="+STR0018,"2="+STR0019,"3="+STR0020}
Private aMV_PAR23 := {"0="+STR0030,"1="+STR0031} // Nao / Sim
Private aMV_PAR24 := {"0="+STR0030,"1="+STR0031} // Nao / Sim
Private aMV_PAR25 := {"0="+STR0030,"1="+STR0031} // Nao / Sim
Private aMV_PAR26 := {"0="+STR0030,"1="+STR0031} // Nao / Sim
Private aMV_PAR27 := {"0="+STR0030,"1="+STR0031} // Nao / Sim
Private aMV_PAR28 := {"0="+STR0030,"1="+STR0031} // Nao / Sim
Private aMV_PAR29 := {"0="+STR0030,"1="+STR0031} // Nao / Sim
Private aMV_PAR30 := {"0="+STR0030,"1="+STR0031} // Nao / Sim
Private aMV_PAR31 := {"0="+STR0030,"1="+STR0031} // Nao / Sim
Private aMV_PAR32 := {"0="+STR0030,"1="+STR0031} // Nao / Sim
Private aNewBot := {{"PARAMETROS",{|| FS_GRAVASX1(.f.) },(STR0028)} } // Restaurar Parametros Default

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 0 , .T. , .T. } ) // TOTAL
aPos := MsObjSize( aInfo, aObjects )
/////////////////////////////
// Fixar tamanho da janela //
/////////////////////////////
aSizeHalf[6] := ( 495+aPos[1,1] )
aSizeHalf[5] := ( 977 )
/////////////////////////////
DEFINE MSDIALOG oOXC004PAR FROM 0,0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0005) OF oMainWnd PIXEL STYLE DS_MODALFRAME STATUS // PARAMETROS - Painel de Oficina
	oOXC004PAR:lEscClose := .F.
	//
	oTPanelPar := TScrollBox():New( oOXC004PAR , aPos[1,1]+2 , aPos[1,2] , 236 , 239 , .t. , , .t. )
	//
    nLinha  := 3
    nColuna := 3
    //
	@ nLinha+000,nColuna+001 TO nLinha+034,nColuna+111 LABEL STR0021 OF oTPanelPar PIXEL // Tempos de atualizacao em segundos
	@ nLinha+010,nColuna+007 SAY STR0001 SIZE 50,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Tela
	@ nLinha+009,nColuna+027 MSGET oMV_PAR01 VAR xMV_PAR01 PICTURE "@E 999" SIZE 27,08 VALID ( xMV_PAR01 >= 30 ) OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+010,nColuna+057 SAY STR0022 SIZE 100,8 OF oTPanelPar PIXEL COLOR CLR_RED // minimo 30
	@ nLinha+021,nColuna+007 SAY STR0002 SIZE 50,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Dados
	@ nLinha+020,nColuna+027 MSGET oMV_PAR02 VAR xMV_PAR02 PICTURE "@E 999" SIZE 27,08 VALID ( xMV_PAR02 >= 300 ) OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+021,nColuna+057 SAY STR0023 SIZE 100,8 OF oTPanelPar PIXEL COLOR CLR_RED // minimo 300 (5 min)
    //
	@ nLinha+000,nColuna+114 TO nLinha+034,nColuna+223 LABEL STR0009 OF oTPanelPar PIXEL // Dias para Filtro de Dados
	@ nLinha+010,nColuna+122 SAY STR0010 SIZE 60,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Anterior a DataBase
	@ nLinha+009,nColuna+185 MSGET oMV_PAR03 VAR xMV_PAR03 PICTURE "@E 999" SIZE 27,08 VALID ( xMV_PAR03 >= 0 ) OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+021,nColuna+122 SAY STR0011 SIZE 60,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Posterior a DataBase
	@ nLinha+020,nColuna+185 MSGET oMV_PAR04 VAR xMV_PAR04 PICTURE "@E 999" SIZE 27,08 VALID ( xMV_PAR04 >= 0 ) OF oTPanelPar PIXEL COLOR CLR_BLACK
	//
	@ nLinha+037,nColuna+001 TO nLinha+091,nColuna+223 LABEL STR0003 OF oTPanelPar PIXEL // Letreiro
	@ nLinha+045,nColuna+007 SAY STR0004 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Altura
	@ nLinha+044,nColuna+025 MSGET oMV_PAR18 VAR xMV_PAR18 PICTURE "@E 99" VALID ( xMV_PAR18 >= 0 ) SIZE 15,08 OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+045,nColuna+053 SAY STR0046 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Nome Fonte
	@ nLinha+044,nColuna+085 MSGET oMV_PAR20 VAR xMV_PAR20 PICTURE "@!" SIZE 78,08 OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+045,nColuna+176 SAY STR0047 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Tamanho
	@ nLinha+044,nColuna+201 MSGET oMV_PAR21 VAR xMV_PAR21 PICTURE "@E 999" VALID ( xMV_PAR21 > 0 ) SIZE 15,08 OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+055,nColuna+007 MSGET oMV_PAR05 VAR xMV_PAR05 PICTURE "@!" SIZE 212,08 OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+066,nColuna+007 MSGET oMV_PAR06 VAR xMV_PAR06 PICTURE "@!" SIZE 212,08 OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+077,nColuna+007 MSGET oMV_PAR07 VAR xMV_PAR07 PICTURE "@!" SIZE 212,08 OF oTPanelPar PIXEL COLOR CLR_BLACK
    //
	@ nLinha+094,nColuna+001 TO nLinha+115,nColuna+223 LABEL STR0014 OF oTPanelPar PIXEL // Linhas
	@ nLinha+102,nColuna+007 SAY STR0004 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Altura
	@ nLinha+101,nColuna+025 MSGET oMV_PAR14 VAR xMV_PAR14 PICTURE "@E 99" VALID ( xMV_PAR14 >= 14 ) SIZE 15,08 OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+102,nColuna+050 SAY STR0012 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Espacamento
	@ nLinha+101,nColuna+085 MSGET oMV_PAR15 VAR xMV_PAR15 PICTURE "@E 99" VALID ( xMV_PAR15 >= 0 ) SIZE 15,08 OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+102,nColuna+111 SAY STR0013 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Posicao
	@ nLinha+101,nColuna+133 MSGET oMV_PAR16 VAR xMV_PAR16 PICTURE "@E 99" VALID ( xMV_PAR16 > 0 ) SIZE 15,08 OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+102,nColuna+160 SAY STR0017 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Fonte
	@ nLinha+101,nColuna+178 MSCOMBOBOX oMV_PAR22 VAR xMV_PAR22 SIZE 40,08 COLOR CLR_BLACK ITEMS aMV_PAR22 OF oTPanelPar PIXEL COLOR CLR_BLACK
    //
	@ nLinha+118,nColuna+001 TO nLinha+170,nColuna+223 LABEL STR0015 OF oTPanelPar PIXEL // Exibir
	@ nLinha+126,nColuna+007 SAY STR0032 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // OS
	@ nLinha+133,nColuna+007 MSCOMBOBOX oMV_PAR23 VAR xMV_PAR23 SIZE 25,08 COLOR CLR_BLACK ITEMS aMV_PAR23 OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+126,nColuna+044 SAY STR0033 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Placa
	@ nLinha+133,nColuna+044 MSCOMBOBOX oMV_PAR24 VAR xMV_PAR24 SIZE 25,08 COLOR CLR_BLACK ITEMS aMV_PAR24 OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+126,nColuna+081 SAY STR0034 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Modelo
	@ nLinha+133,nColuna+081 MSCOMBOBOX oMV_PAR25 VAR xMV_PAR25 SIZE 25,08 COLOR CLR_BLACK ITEMS aMV_PAR25 OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+126,nColuna+118 SAY STR0035 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Cliente
	@ nLinha+133,nColuna+118 MSCOMBOBOX oMV_PAR26 VAR xMV_PAR26 SIZE 25,08 COLOR CLR_BLACK ITEMS aMV_PAR26 OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+126,nColuna+155 SAY STR0036 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Box
	@ nLinha+133,nColuna+155 MSCOMBOBOX oMV_PAR27 VAR xMV_PAR27 SIZE 25,08 COLOR CLR_BLACK ITEMS aMV_PAR27 OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+126,nColuna+192 SAY STR0037 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Consultor
	@ nLinha+133,nColuna+192 MSCOMBOBOX oMV_PAR28 VAR xMV_PAR28 SIZE 25,08 COLOR CLR_BLACK ITEMS aMV_PAR27 OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+148,nColuna+007 SAY STR0038 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Entrada
	@ nLinha+155,nColuna+007 MSCOMBOBOX oMV_PAR29 VAR xMV_PAR29 SIZE 25,08 COLOR CLR_BLACK ITEMS aMV_PAR29 OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+148,nColuna+044 SAY STR0016 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Previsao
	@ nLinha+155,nColuna+044 MSCOMBOBOX oMV_PAR30 VAR xMV_PAR30 SIZE 25,08 COLOR CLR_BLACK ITEMS aMV_PAR30 OF oTPanelPar PIXEL COLOR CLR_BLACK
    //
	@ nLinha+173,nColuna+001 TO nLinha+194,nColuna+111 LABEL STR0040 OF oTPanelPar PIXEL // Progresso
	@ nLinha+181,nColuna+007 SAY STR0024 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Exibe
	@ nLinha+180,nColuna+025 MSCOMBOBOX oMV_PAR31 VAR xMV_PAR31 SIZE 25,08 COLOR CLR_BLACK ITEMS aMV_PAR31 OF oTPanelPar PIXEL COLOR CLR_BLACK
	@ nLinha+181,nColuna+060 SAY STR0013 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Posicao
	@ nLinha+180,nColuna+083 MSGET oMV_PAR17 VAR xMV_PAR17 PICTURE "@E 99" VALID ( xMV_PAR17 > 0 ) SIZE 15,08 OF oTPanelPar PIXEL COLOR CLR_BLACK
    //
	@ nLinha+173,nColuna+114 TO nLinha+194,nColuna+223 LABEL STR0025 OF oTPanelPar PIXEL // Legenda rodape
	@ nLinha+181,nColuna+122 SAY STR0004 SIZE 40,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Altura
	@ nLinha+180,nColuna+140 MSGET oMV_PAR19 VAR xMV_PAR19 PICTURE "@E 99" VALID ( xMV_PAR19 >= 0 ) SIZE 15,08 OF oTPanelPar PIXEL COLOR CLR_BLACK
	//
	@ nLinha+195,nColuna+001 TO nLinha+218,nColuna+111 LABEL STR0048 OF oTPanelPar PIXEL // Atualiza Tela
	@ nLinha+204,nColuna+007 SAY STR0049 SIZE 60,8 OF oTPanelPar PIXEL COLOR CLR_BLUE // Atualiza tela inteira
	@ nLinha+203,nColuna+056 MSCOMBOBOX oMV_PAR32 VAR xMV_PAR32 SIZE 25,08 COLOR CLR_BLACK ITEMS aMV_PAR32 OF oTPanelPar PIXEL COLOR CLR_BLACK

	@ aPos[1,1]+000,aPos[1,2]+241 TO aPos[1,1]+076,aPos[1,2]+360 LABEL (STR0008+STR0006) OF oOXC004PAR PIXEL // Cor: Linha 1
	oTColor1 := tColorTriangle():New(aPos[1,1]+005,aPos[1,2]+242,oOXC004PAR,115,070)
	oTColor1:SetColorIni( xMV_PAR08 )
	//
	@ aPos[1,1]+000,aPos[1,2]+361 TO aPos[1,1]+076,aPos[1,2]+480 LABEL (STR0008+STR0007) OF oOXC004PAR PIXEL // Cor: Linha 2
	oTColor2 := tColorTriangle():New(aPos[1,1]+005,aPos[1,2]+362,oOXC004PAR,115,070)
	oTColor2:SetColorIni( xMV_PAR09 )
	//
	@ aPos[1,1]+080,aPos[1,2]+241 TO aPos[1,1]+156,aPos[1,2]+360 LABEL (STR0008+STR0043) OF oOXC004PAR PIXEL // Cor: OS com serviço(s) em andamento
	oTColor3 := tColorTriangle():New(aPos[1,1]+085,aPos[1,2]+242,oOXC004PAR,115,070)
	oTColor3:SetColorIni( xMV_PAR10 )
	//
	@ aPos[1,1]+080,aPos[1,2]+361 TO aPos[1,1]+156,aPos[1,2]+480 LABEL (STR0008+STR0044) OF oOXC004PAR PIXEL // Cor: OS com serviço(s) em pausa
	oTColor4 := tColorTriangle():New(aPos[1,1]+085,aPos[1,2]+362,oOXC004PAR,115,070)
	oTColor4:SetColorIni( xMV_PAR11 )
    //
	@ aPos[1,1]+160,aPos[1,2]+241 TO aPos[1,1]+236,aPos[1,2]+360 LABEL (STR0008+STR0045) OF oOXC004PAR PIXEL // Cor: OS liberada para faturamento
	oTColor5 := tColorTriangle():New(aPos[1,1]+165,aPos[1,2]+242,oOXC004PAR,115,070)
	oTColor5:SetColorIni( xMV_PAR12 )
	//
	@ aPos[1,1]+160,aPos[1,2]+361 TO aPos[1,1]+236,aPos[1,2]+480 LABEL (STR0008+STR0029) OF oOXC004PAR PIXEL // Cor: Aguardando Orçamento
	oTColor6 := tColorTriangle():New(aPos[1,1]+165,aPos[1,2]+362,oOXC004PAR,115,070)
	oTColor6:SetColorIni( xMV_PAR13 )
	//
ACTIVATE MSDIALOG oOXC004PAR CENTER ON INIT EnchoiceBar(oOXC004PAR,{ || FS_GRAVASX1(.t.) , lOk := .t. , oOXC004PAR:End() }, { || oOXC004PAR:End() },,aNewBot)
Return(lOk)

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | FS_GRAVASX1| Autor | Andre Luis Almeida    | Data | 05/10/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Grava SX1                                                    |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_GRAVASX1(lGravaF12,lGravaF10)
Local lOk := .t.

Default lGravaF12 := .f.
Default lGravaF10 := .f.

If lGravaF12
	MV_PAR01 := xMV_PAR01
	MV_PAR02 := xMV_PAR02
	MV_PAR03 := xMV_PAR03
	MV_PAR04 := xMV_PAR04
	MV_PAR05 := xMV_PAR05
	MV_PAR06 := xMV_PAR06
	MV_PAR07 := xMV_PAR07
	MV_PAR08 := oTColor1:RetColor()
	MV_PAR09 := oTColor2:RetColor()
	MV_PAR10 := oTColor3:RetColor()
	MV_PAR11 := oTColor4:RetColor()
	MV_PAR12 := oTColor5:RetColor()
	MV_PAR13 := oTColor6:RetColor()
	MV_PAR14 := xMV_PAR14
	MV_PAR15 := xMV_PAR15
	MV_PAR16 := xMV_PAR16
	MV_PAR17 := xMV_PAR17
	MV_PAR18 := xMV_PAR18
	MV_PAR19 := xMV_PAR19
	MV_PAR20 := xMV_PAR20
	MV_PAR21 := xMV_PAR21
	MV_PAR22 := val(xMV_PAR22)
	MV_PAR23 := val(xMV_PAR23)+1
	MV_PAR24 := val(xMV_PAR24)+1
	MV_PAR25 := val(xMV_PAR25)+1
	MV_PAR26 := val(xMV_PAR26)+1
	MV_PAR27 := val(xMV_PAR27)+1
	MV_PAR28 := val(xMV_PAR28)+1
	MV_PAR29 := val(xMV_PAR29)+1
	MV_PAR30 := val(xMV_PAR30)+1
	MV_PAR31 := val(xMV_PAR31)+1
	MV_PAR32 := val(xMV_PAR32)+1
ElseIf lGravaF10// Variaveis do Filtro (F10)
	MV_PAR33 := M->cFiltrar
	MV_PAR34 := iIf(M->lPublico,"1","2")
	MV_PAR35 := iIf(M->lGarantia,"1","2")
	MV_PAR36 := iIf(M->lInterno,"1","2")
	MV_PAR37 := iIf(M->lRevisao,"1","2")
	MV_PAR38 := M->cExceTT
	MV_PAR39 := M->cNumBox
	MV_PAR40 := M->cConSultor
	MV_PAR41 := M->VO1_TPATEN

Else
	If !MsgYesNo(STR0027,STR0026) // Deseja voltar as configuracoes default? / Atencao
		lOk := .f.
	EndIf
	If lOk
		// VALORES DEFAULT //
		MV_PAR01 := 30
		MV_PAR02 := 300
		MV_PAR03 := 0
		MV_PAR04 := 0
		MV_PAR05 := space(60)
		MV_PAR06 := space(60)
		MV_PAR07 := space(60)
		MV_PAR08 := 14540253
		MV_PAR09 := 15395562
		MV_PAR10 := 32768
		MV_PAR11 := 36095
		MV_PAR12 := 8388608
		MV_PAR13 := 11209322
		MV_PAR14 := 21
		MV_PAR15 := 0
		MV_PAR16 := 5
		MV_PAR17 := 6
		MV_PAR18 := 40
		MV_PAR19 := 15
		MV_PAR20 := space(60)
		MV_PAR21 := 72
		MV_PAR22 := 2
		MV_PAR23 := 2
		MV_PAR24 := 2
		MV_PAR25 := 2
		MV_PAR26 := 1
		MV_PAR27 := 2
		MV_PAR28 := 2
		MV_PAR29 := 2
		MV_PAR30 := 2
		MV_PAR31 := 2
		//
		xMV_PAR01 := MV_PAR01
		xMV_PAR02 := MV_PAR02
		xMV_PAR03 := MV_PAR03
		xMV_PAR04 := MV_PAR04
		xMV_PAR05 := left(MV_PAR05+space(60),60)
		xMV_PAR06 := left(MV_PAR06+space(60),60)
		xMV_PAR07 := left(MV_PAR07+space(60),60)
		xMV_PAR08 := MV_PAR08
		xMV_PAR09 := MV_PAR09
		xMV_PAR10 := MV_PAR10
		xMV_PAR11 := MV_PAR11
		xMV_PAR12 := MV_PAR12
		xMV_PAR13 := MV_PAR13
		xMV_PAR14 := MV_PAR14
		xMV_PAR15 := MV_PAR15
		xMV_PAR16 := MV_PAR16
		xMV_PAR17 := MV_PAR17
		xMV_PAR18 := MV_PAR18
		xMV_PAR19 := MV_PAR19
		xMV_PAR20 := left(MV_PAR20+space(60),60)
		xMV_PAR21 := MV_PAR21
		xMV_PAR22 := strzero(MV_PAR22,1)
		xMV_PAR23 := strzero(MV_PAR23-1,1)
		xMV_PAR24 := strzero(MV_PAR24-1,1)
		xMV_PAR25 := strzero(MV_PAR25-1,1)
		xMV_PAR26 := strzero(MV_PAR26-1,1)
		xMV_PAR27 := strzero(MV_PAR27-1,1)
		xMV_PAR28 := strzero(MV_PAR28-1,1)
		xMV_PAR29 := strzero(MV_PAR29-1,1)
		xMV_PAR30 := strzero(MV_PAR30-1,1)
		xMV_PAR31 := strzero(MV_PAR31-1,1)
		xMV_PAR32 := strzero(MV_PAR32-1,1)
		//
		oMV_PAR01:Refresh()
		oMV_PAR02:Refresh()
		oMV_PAR03:Refresh()
		oMV_PAR04:Refresh()
		oMV_PAR05:Refresh()
		oMV_PAR06:Refresh()
		oMV_PAR07:Refresh()
		oTColor1:SetColorIni( xMV_PAR08 )
		oTColor2:SetColorIni( xMV_PAR09 )
		oTColor3:SetColorIni( xMV_PAR10 )
		oTColor4:SetColorIni( xMV_PAR11 )
		oTColor5:SetColorIni( xMV_PAR12 )
		oTColor6:SetColorIni( xMV_PAR13 )
		oMV_PAR14:Refresh()
		oMV_PAR15:Refresh()
		oMV_PAR16:Refresh()
		oMV_PAR17:Refresh()
		oMV_PAR18:Refresh()
		oMV_PAR19:Refresh()
		oMV_PAR20:Refresh()
		oMV_PAR21:Refresh()
		oMV_PAR22:Refresh()
		oMV_PAR23:Refresh()
		oMV_PAR24:Refresh()
		oMV_PAR25:Refresh()
		oMV_PAR26:Refresh()
		oMV_PAR27:Refresh()
		oMV_PAR28:Refresh()
		oMV_PAR29:Refresh()
		oMV_PAR30:Refresh()
		oMV_PAR31:Refresh()
	EndIf
EndIf



If lOk
	DbSelectArea("SX1")
	cPerg := PadR("OXC004",len(SX1->X1_GRUPO))
	DbSetOrder(1)
	DbSeek(cPerg)
	While !Eof() .and. SX1->X1_GRUPO == cPerg
		RecLock("SX1",.f.)
			If SX1->X1_GSC == "G" // GET
		   		SX1->X1_CNT01  := Alltrim(IIf(SX1->X1_TIPO=="N",str(&(Alltrim(SX1->X1_VAR01))),&(Alltrim(SX1->X1_VAR01))))
			ElseIf SX1->X1_GSC == "C" // COMBO
				SX1->X1_PRESEL := &(Alltrim(SX1->X1_VAR01))
			EndIf
		MsUnLock()
		DbSelectArea("SX1")
		DbSkip()
	EndDo
EndIf
Return()

/*/{Protheus.doc} OXC04FILT
	Tela de Filtros da rotina

	@author Manoel Filho
	@since  19/07/2017
	@param
	@return
/*/
Static Function OXC04FILT()
Local oIHelp    := DMS_InterfaceHelper():New()


Local lOk       := .f.
//
M->cFiltrar  := MV_PAR33
M->lPublico  := iIf(MV_PAR34=="1",.t.,.f.)
M->lGarantia := iIf(MV_PAR35=="1",.t.,.f.)
M->lInterno  := iIf(MV_PAR36=="1",.t.,.f.)
M->lRevisao  := iIf(MV_PAR37=="1",.t.,.f.)
M->cExceTT   := MV_PAR38
M->cNumBox   := MV_PAR39
M->cConSultor:= MV_PAR40
//
Private oArHelper    := Dms_ArrayHelper():New()
Private oSqlHelper   := Dms_SqlHelper():New()
//
oSizePri := oIHelp:CreateDefSize(.t.,,,0, 0.5)
oSizePri:Process()
//
oIHelp:SetDefSize(oSizePri)
oOXC04Filt := oIHelp:CreateDialog(STR0057) // Filtro
oIHelp:SetDialog(oOXC04Filt) // ACTIVATE
oIHelp:SetOwnerPvt("OFIXC004")
oIHelp:nOpc := 3
//oOXC04Filt:lEscClose := .F.
//
oIHelp:Clean()
//oIHelp:SetDefSize(oSizePri, "QUADRO_1")
//
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "C"                               },;
	{'X3_TAMANHO' , TamSX3("VOI_SITTPO")[1]           },;
	{'X3_CAMPO'   , 'cFiltrar'                        },;
	{'X3_TITULO'  , STR0051                           },; // Filtrar
	{'X3_PICTURE' , "@!"                              },;
	{'X3_RELACAO' , M->cFiltrar                       },;
	{'X3_CBOX'    , "1=Agendamentos;2=OSs;3=Ambos"    } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "L"                               },;
	{'X3_TAMANHO' , 1                                 },;
	{'X3_CAMPO'   , 'lPublico'                        },;
	{'X3_TITULO'  , STR0052                           },; // TT Público
	{'X3_RELACAO' , M->lPublico                       } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "L"                               },;
	{'X3_TAMANHO' , 1                                 },;
	{'X3_CAMPO'   , 'lGarantia'                       },;
	{'X3_TITULO'  , STR0053                           },; // TT Garantia
	{'X3_RELACAO' , M->lGarantia                      } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "L"                               },;
	{'X3_TAMANHO' , 1                                 },;
	{'X3_CAMPO'   , 'lInterno'                        },;
	{'X3_TITULO'  , STR0054                           },; // TT Interno
	{'X3_RELACAO' , M->lInterno                       } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "L"                               },;
	{'X3_TAMANHO' , 1                                 },;
	{'X3_CAMPO'   , 'lRevisao'                        },;
	{'X3_TITULO'  , STR0055                           },; // TT Revisão
	{'X3_RELACAO' , M->lRevisao                       } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "C"                               },;
	{'X3_TAMANHO' , 50                                },;
	{'X3_CAMPO'   , 'cExceTT'                         },;
	{'X3_TITULO'  , STR0056                           },; // TT Exceção
	{'X3_RELACAO' , M->cExceTT                        },;
	{'X3_PICTURE' , "@!"                              } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "C"                               },;
	{'X3_TAMANHO' , TamSX3("VSO_NUMBOX")[1]           },;
	{'X3_CAMPO'   , 'cNumBox'                         },;
	{'X3_TITULO'  , STR0036                           },; // Box
	{'X3_PICTURE' , "@!"                              },;
	{'X3_RELACAO' , M->cNumBox                        },;
	{'X3_F3'      , "BOX"                             } ;
})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "C"                               },;
	{'X3_TAMANHO' , TamSX3("VO1_FUNABE")[1]           },;
	{'X3_CAMPO'   , 'cConSultor'                      },;
	{'X3_TITULO'  , STR0037                           },; // Consultor
	{'X3_PICTURE' , "@!"                              },;
	{'X3_RELACAO' , M->cConsultor                     },;
	{'X3_F3'      , "VAI1"                            } ;
	})
oIHelp:AddMGetTipo({;
	{'X3_TIPO'    , "C"                               },;
	{'X3_TAMANHO' , TamSX3("VO1_TPATEN")[1]           },;
	{'X3_CAMPO'   , 'VO1_TPATEN'                       },;
	{'X3_TITULO'  , RetTitle("VO1_TPATEN")            },; // Tipo de Atendimento
	{'X3_PICTURE' , "@!"                              },;
	{'X3_RELACAO' , M->VO1_TPATEN                     },;
	{'X3_F3'      , "VX5"                             } ;	
	})

//
M->VO1_TPATEN:= MV_PAR41

//
oEnchParam1 := oIHelp:CreateMSMGet(.f.,{{"ALINHAMENTO",CONTROL_ALIGN_ALLCLIENT}})
//
ACTIVATE MSDIALOG oOXC04Filt CENTER ON INIT EnchoiceBar(oOXC04Filt,{|| FS_GRAVASX1(,.t.), lOk := .t., oOXC04Filt:End()  },{||lOk := .f. , oOXC04Filt:End()} )
//
Return lOk