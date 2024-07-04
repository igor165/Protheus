#INCLUDE "fina935.ch"
#include 'protheus.ch'
#include 'tcbrowse.ch'

#DEFINE _RECSE1 		1
#DEFINE _BAIXAS 		2
#DEFINE _SALDO  		3
#DEFINE _MARCADO		"LBTIK"
#DEFINE _DESMARCADO		"LBNO"
#DEFINE _PRETO   		"BR_PRETO"
#DEFINE _AMARELO    	"BR_AMARELO"
#DEFINE _AZUL       	"BR_AZUL"
#DEFINE _VERMELHO       "BR_VERMELHO" 

#DEFINE _RECIBO		1
#DEFINE _CLIENTE	2
#DEFINE _LOJA		3

#DEFINE _RECNO		1
#DEFINE _PREFIJO	2
#DEFINE _VALOR		3
#DEFINE _NUMERO		4
#DEFINE _PARCELA	5
#DEFINE _TIPO		6
#DEFINE _MOEDA		7
#DEFINE _TAXMOEDA	8	
#DEFINE _TIPAGR		9	
#DEFINE _RG1415		10
#DEFINE _VALFACT	11
#DEFINE _ITEMS		12
#DEFINE _IVAPOSD	13
#DEFINE _IVPPOSD	14
#DEFINE _RECVALID	15

/*/

ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA935   บAdrian Perez Hernandez      		 			  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para para generacion de NDC Y NCC de granos	      บฑฑ
ฑฑบ    				                                                      บฑฑ                 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                         บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   
Valida primero campos e informacion de campos	para despues iniciar cargaณฑฑ
             documentos de la tabla SEL con marca de ivaposdatado campo   ณฑฑ
              EL_TIPAGR													  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Fina935()

Local cFiltro	:=	""
Local bFiltro
Local lAutomato := IsBlind()
Local cFilter :=""

Local lFin935:= .F.
Local aAux:= {}
Private aMv:={} 
Private aIndices		:=	{} //Array necessario para a funcion del FilBrowse
Private bFiltraBrw := {|| .T. }
Private aRecSE1		:={}
Private cMoedaTx,nC	:=	MoedFin()
Private nNumDocNF:=0
Private cLocxNFPV:=""
Private cTipo:=""
Private TRB  := GetNextAlias()
Private aMV_PAR		:= Array(7)
Private TRB1  := GetNextAlias()
Private aRecFX6	:=	{}
Private nNewAlicuo := 0
Private lTemFX6:=.F.
If (!(AmIIn(6,12,17,72)) .and. !lAutomato)
	Return
Endif

Private aRotina := MenuDef()

PRIVATE cCadastro :=OemToAnsi(STR0007) 

aAdd(aMv, GETNEWPAR("MV_IVACAN", "F935"))
aAdd(aMv, GETNEWPAR("MV_PIVCAN", "F935"))
aAdd(aMv, GETNEWPAR("MV_CONDGR", "F935"))
aAdd(aMv, GETNEWPAR("MV_IMPGR", "IVA"))


If SEL->(ColumnPos("EL_DOCPOS"))>0 .And. SEL->(ColumnPos("EL_SERPOS"))>0 .And. SEL->(ColumnPos("EL_FILPOS"))>0 .AND. SEL->(ColumnPos("EL_STPOSDT"))>0 .AND. SEL->(ColumnPos("EL_TIPAGR"))>0 .AND. SE1->(ColumnPos("E1_RECGR"))>0
	lFin935:=.T.
Else
	lFin935:=.F.
	MsgAlert(STR0052 ,STR0003)
	Return lFin935
	
EndIf

If SF2->(ColumnPos("F2_RECPOS"))>0 .And. SF2->(ColumnPos("F2_IVAPOS"))>0 .and. SF1->(ColumnPos("F1_RECPOS"))>0 .And. SF1->(ColumnPos("F1_IVAPOS"))>0
	lFin935:=.T.
Else
	lFin935:=.F.
	MsgAlert(STR0053 ,STR0003)
	Return lFin935
	
EndIf


If !aMv[1]=="F935" .and. !aMv[2]=="F935" .and. !aMv[2]=="F935"
	lFin935:=.T.
Else
	lFin935:=.F.
	MsgAlert(STR0054 ,STR0003)
	Return lFin935
	
EndIF

aAux:=fBuscaB1(aMv[01])
lFin935:=fParametros(aAux,STR0058)
IF lFin935
	aAux:={}
	aAux:=fBuscaB1(aMv[02])
	lFin935:=fParametros(aAux,STR0059)
EndIF

If lFin935
	  
	If !Empty(cFiltro)
		cFiltro	:=	"EL_FILIAL='"+xFilial('SEL')+"' "+Iif(Empty(cFiltro),"",".And.("+ cFiltro + ")")
		bFiltro	:=	{|| FilBrowse("SEL",@aIndices,cFiltro )}

	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inicia  BROWSE											     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cfilter:= "EL_TIPAGR!='' AND EL_TIPAGR!='0' "
	IF !lAutomato
	   mBrowse( 6, 1,22,75,"SEL",,,,,, F935Legenda("SEL"),,,,,,,,cFilter)

	Endif
	dbSelectArea("SEL")
	If !Empty(cFiltro)
		EndFilBrw("SEL",@aIndices)
	Endif
	dbSetOrder(1)
	
Else
	Return lFin935
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF935VISTA บAutor  ณAdrian Perez Hernandez					  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstruye tabla temporal para la carga en pantalla.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametros       ณ    												   ฑฑ
               lMultiplo:Va en relacion con lMarcados 					   ฑฑ
               aCorrecoes:Registros a cargar en la tabla temporal         บฑฑ
               lMarcados: Indica si los registros seran marcados o no      ฑฑ
                     			visualmente aparecen con un check si se    ฑฑ
                     			indica que si							   ฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function F935VISTA(lMultiplo,aCorrecoes,lMarcados) 

Local nTotAjuste	:=	0
Local aStruTRB	:=	{}
Local aCampos 	:=	{}
Local nOpca		:=	2
Local nShowCampos	:=	0
Local nIniLoop	:=	0             
Local nX := 1
Local nY := 1
Local aOrdem	:={}
Local lExterno

Private oTmpTable

DEFAULT aCorrecoes	:=	{}
DEFAULT lMarcados 	:=	.F.
DEFAULT lExterno 	:=	.F.

If !dtMovFin(dDataBASE,,"2") 
	Return  .F.
EndIf

If lMultiplo
	aadd(aStruTrb,{"TRB_MARCA"		,"C",12,0})
Endif
aadd(aStruTrb,{"TRB_ORIGEM"	,"C",10,0})
aadd(aStruTrb,{"EL_CLIENTE"	,"C",FWTamSX3("EL_CLIENTE")[1],FWTamSX3("EL_CLIENTE")[2]})
aadd(aStruTrb,{"EL_LOJA"  		,"C",FWTamSX3("EL_LOJA"   )[1],FWTamSX3("EL_LOJA"   )[2]})
aadd(aStruTrb,{"EL_PREFIXO"	,"C",FWTamSX3("EL_PREFIXO")[1],FWTamSX3("EL_PREFIXO")[2]})
aadd(aStruTrb,{"EL_NUMERO"			,"C",FWTamSX3("EL_NUMERO"    )[1],FWTamSX3("EL_NUMERO"    )[2]})
aadd(aStruTrb,{"EL_PARCELA"	,"C",FWTamSX3("EL_PARCELA")[1],FWTamSX3("EL_PARCELA")[2]})
aadd(aStruTrb,{"EL_TIPO"		,"C",FWTamSX3("EL_TIPO"   )[1],FWTamSX3("EL_TIPO"   )[2]})
aadd(aStruTrb,{"EL_RECIBO"		,"C",FWTamSX3("EL_RECIBO" )[1],FWTamSX3("EL_RECIBO" )[2]}) //
aadd(aStruTrb,{"EL_EMISSAO"	,"D",FWTamSX3("EL_EMISSAO")[1],FWTamSX3("EL_EMISSAO")[2]})
aadd(aStruTrb,{"EL_VALOR"		,"N",FWTamSX3("EL_VALOR"  )[1],FWTamSX3("EL_VALOR"  )[2]}) //
aadd(aStruTrb,{"EL_CANCEL"		,"L",FWTamSX3("EL_CANCEL"  )[1],FWTamSX3("EL_CANCEL"  )[2]}) 
nShowCampos	:=	Len(aStruTRB)

If lMultiplo
	AAdd(aCampos,{' ','TRB_MARCA' ,aStruTRB[1][2],aStruTRB[1][3],aStruTRB[1][4],"@BMP"})
	AAdd(aCampos,{' ','TRB_ORIGEM',aStruTRB[2][2],aStruTRB[2][3],aStruTRB[2][4],"@BMP"})
Else
	AAdd(aCampos,{' ','TRB_ORIGEM',aStruTRB[1][2],aStruTRB[1][3],aStruTRB[1][4],"@BMP"})
Endif

nIniLoop	:=	Len(aCampos)+1

For nX := nIniLoop To nShowCampos
	
		AAdd(aCampos,{FWX3Titulo(aStruTRB[nX][1]),aStruTRB[nX][1],aStruTRB[nX][2],aStruTRB[nX][3],aStruTRB[nX][4],PesqPict("SEL",aStruTRB[nX][1])})
Next

aOrdem	:=	{"EL_CLIENTE","EL_LOJA","EL_PREFIXO","EL_NUMERO","EL_PARCELA","EL_TIPO","EL_RECIBO"}
oTmpTable := FWTemporaryTable():New(TRB)
oTmpTable:SetFields( aStruTrb )
oTmpTable:AddIndex("I1", aOrdem)
oTmpTable:Create()

For nY:= 1 To Len(aCorrecoes) 
			SEL->(MsGoTo(aRecSE1[nY]))
			
			Reclock(TRB,.T.)
			Replace EL_CLIENTE With SEL->EL_CLIORIG
			Replace EL_LOJA 	 With SEL->EL_LOJORIG
			Replace EL_PREFIXO With  SEL->EL_PREFIXO
			Replace EL_NUMERO     With SEL->EL_NUMERO
			Replace EL_PARCELA With SEL->EL_PARCELA
			Replace EL_TIPO    With SEL->EL_TIPO
			Replace EL_EMISSAO With SEL->EL_EMISSAO
			Replace EL_RECIBO	 With SEL->EL_RECIBO
			Replace TRB_ORIGEM With iif(Empty(SEL->EL_DOCPOS),_AMARELO,IIF(SEL->EL_TIPAGR =="4",_VERMELHO,_AZUL))
			Replace EL_VALOR   With SEL->EL_VALOR
			Replace EL_CANCEL   With SEL->EL_CANCEL
			If lMultiplo
				TRB_MARCA	:=	IIf(lMarcados,_MARCADO,_DESMARCADO)
			Endif
		MsUnLock()

Next
DbGoTop()
If !lExterno
	nOpca	:=	F935Tela(3,nTotAjuste,aCampos,lMultiplo)
Else
	nOpca	:= 1
EndIf
If nOpca == 1 
	Begin Transaction
	Processa({|| F935Grava(aRecSE1,lMultiplo,lExterno)},STR0009) //"Grabando documentos"
	End Transaction
Endif

DbSelectArea(TRB)
(TRB)->(DbCloseArea())

If oTmpTable <> Nil
	oTmpTable:Delete()
	oTmpTable := Nil
Endif

If !lExterno .And. bFiltraBrw <> Nil
	Eval(bFiltraBrw)
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFDOCGRบAutor  ณAdrian Perez Hernandez						  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณManda panalla de parแmetros para usarlos en la query
              y extraer los datos										  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FDOCGR()
aRecSE1	:=	{}
// Verifica se pode ser incluido mov. com essa data
If !dtMovFin(dDataBASE,,"2") 
	Return  .F.
EndIf

If Pergunte("FIN935",.T.)
	aMV_PAR[01]	:=	MV_PAR01
	aMV_PAR[02]	:=	MV_PAR02
	aMV_PAR[03]	:=	MV_PAR03
	aMV_PAR[04]	:=	MV_PAR04
	aMV_PAR[05]	:=	MV_PAR05
	aMV_PAR[06]	:=	MV_PAR06  // serie Debito
	aMV_PAR[07]	:=	MV_PAR07 //Serie Credito
	
	
	
Else
	Pergunte("FIN935",.F.)
	Return .F.
Endif

Processa({|| F935QUERY(@aRecSE1,aMV_PAR,.T.)}, STR0027) //'Calculando diferencias de cambio'

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica a existencia de registros                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aRecSE1) > 0
	cTipo:="NDC"
	F935VISTA(.T.,aRecSE1,aMV_PAR[05]==1)
EndIf

DbSelectArea('SEL')
If bFiltraBrw <> Nil
	Eval(bFiltraBrw)
Endif    

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ F935QUERY  Autor: Adrian Perez Hernandez					 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusqueda de registros de la SEL	de acuerdo  a parametros. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑบParametros       ณ    												   ฑฑ
               aRecSE1:	registros										  บฑฑ
               aMV_PAR:	parametros a usar en query						  บฑฑ
               lCancelar: indica si ndc o ncc en base al valor			  บฑฑ
                        True muestra datos para crear la vistapara 		  บฑฑ
                        generar NDC	de tipo grano						  บฑฑ
                       Falsemuestra datos para crear la vista para generarบฑฑ
                        NCC	de tipo grano								  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F935QUERY(aRecSE1,aMV_PAR,lCancelar)

Local nCounter	:=	0
Local cAliasSEL:=	'SEL'                      

Local cQuery		:=	''
Local aStru			:=	{}
Local ni := 1 
              
ProcRegua(500) 
dbSelectArea("SEL")
dbSetOrder(1)


	aStru := dbStruct()
	cQuery := "SELECT SEL.*,"
	cQuery += "R_E_C_N_O_ RECNO "
	cQuery += "  FROM "+	RetSqlName("SEL") + " SEL "
	cQuery += " WHERE EL_FILIAL ='" +xFilial('SEL')+ "'"
	If !Empty(aMv_par[01]) .And.  !Empty(aMv_par[02])
		cQuery += "   AND EL_RECIBO Between '" + aMv_par[01] + "' AND '" + aMv_par[02] + "'"
	EndIf
	cQuery += "   AND EL_TIPAGR!='' AND EL_TIPAGR!='0' AND EL_TIPAGR !='4'  "
	If !Empty(aMv_par[03]) .And.  !Empty(aMv_par[04])
		cQuery += "   AND EL_EMISSAO Between '"     + DTOS(aMv_par[03]) + "' AND '" + DTOS(aMv_par[04]) + "'"
	EndIf
	
	cQuery += "   AND EL_CANCEL   = 'F'"
	
	IF SEL->(ColumnPos("EL_TIPAGR")) >0
		If lCancelar
			cQuery += "   AND EL_DOCPOS   = ''"
		Else
			cQuery += "   AND EL_DOCPOS   != ''"
		EndIf
	EndIf
	cQuery += "   AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY "+ SqlOrder(SEL->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SELQRY', .F., .T.)
	
	For ni := 1 to Len(aStru)
		If aStru[ni,2] != 'C' .AND. aStru[ni,2] != "M"
			TCSetField('SELQRY', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		Endif
	Next
	dbSelectArea("SELQRY")
	cAliasSEL	:=	'SELQRY'                      
	
	If SELQRY->(Eof())
		MsgAlert(STR0065,STR0003)
	EndIf
	
While SELQRY->(!Eof()) 
	
	SEL->(MsGoTo(SELQRY->RECNO))

	IncProc(STR0028+' '+(cAliasSEL)->EL_PREFIXO+"/"+(cAliasSEL)->EL_NUMERO) 
	nCounter++

	Aadd(aRecSE1,SEL->(Recno()))

	DbSelectArea('SEL')
	DbSetOrder(1)
	MsGoto(aRecSE1[Len(aRecSE1)])
	DbSelectArea(cAliasSEL)
	DbSkip()
Enddo

	DbSelectArea(cAliasSEL)
	DbCloseArea()
	DbSelectArea('SEL')

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ F935NCC บAutor  ณAdrian Perez                              บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrepara pantalla para crear NCC de las NDC                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F935NCC(lAut)

If Pergunte("FIN935",.T.)
	aMV_PAR[01]	:=	MV_PAR01
	aMV_PAR[02]	:=	MV_PAR02
	aMV_PAR[03]	:=	MV_PAR03
	aMV_PAR[04]	:=	MV_PAR04
	aMV_PAR[05]	:=	MV_PAR05
	aMV_PAR[06]	:=	MV_PAR06  // serie Debito
	aMV_PAR[07]	:=	MV_PAR07 //Serie Credito
Else
	Pergunte("FIN935",.F.)
	Return .F.
Endif


aRecSE1		:={}
Processa({|| F935QUERY(@aRecSE1,aMV_PAR,.F.)}, STR0027) //'Calculando diferencias de cambio'

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica a existencia de registros                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aRecSE1) > 0
	cTipo:="NCC"
	F935VISTA(.T.,aRecSE1,aMV_PAR[05]==1) //CANCELAR
EndIf
Return


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณF935Tela   ณ Autor ณAdrian Perez Hernandez				  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Monta a tela para mostrar os dados                         ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Fina935                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function F935Tela(nOpc,nTotAjuste,aCampos,lMultiplo)
Local aObjects := {}
LOCAL aPosObj  :={}
LOCAL aSize		:=MsAdvSize()
LOCAL aInfo    :={aSize[1],aSize[2],aSize[3],aSize[4],0,0}
Local nOpca		:=	2
Local oCol		:= Nil
Local oLbx
Local nX			:=	0
Local bOk,bCanc
Local nBitMaps	:=	1
Local oTotAjuste
Local aButtons	:=	{}
Local bMarkAll
Local bUnMarkAll
Local bInverte
Local lInclui	:=	(nOpc == 3)
Local lDeleta	:=	(nOpc == 5)
Local oFont

Local lAutomato := IsBlind()
DEFINE FONT oFont NAME "Arial" BOLD

DEFAULT lMultiplo	:=	.F.

If nOpc == 2
	nMoeda := SFR->FR_MOEDA
EndIf

If lMultiplo
	nBitMaps := 2
Endif

If !lDeleta
	bOk	:=	{|| nOpca:=	1,oDlg:End()}
	bCanc	:=	{|| nOpca:=	2,oDlg:End()}
Else
	bCanc	:=	{|| nOpca:=	2,oDlg:End()}
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPasso parametros para calculo da resolucao da tela                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aadd( aObjects, { 100, 015, .T., .T. } )
aadd( aObjects, { 100, 085, .T., .T. } )
aPosObj  := MsObjSize( aInfo, aObjects, .T. )
If !lAutomato
DEFINE MSDIALOG oDlg FROM aSize[7], 000 TO aSize[6], aSize[5] TITLE OemToAnsi(Iif(lDeleta,STR0014,IIf(lInclui,STR0015,STR0023))+" "+STR0024) PIXEL //"Borrado de "###"Generacion de"###"Visualizacion de"###" ajuste por diferencia de cambio"
@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4]-83 LABEL "" OF oDlg  PIXEL

If !lInclui
	@ aPosObj[1,1]+015,010 SAY OemToAnsi(STR0030+' :  '+Dtoc(SE1->E1_EMISSAO)) SIZE 60, 7 OF oDlg PIXEL FONT oFont COLOR CLR_BLUE //Emision
	@ aPosObj[1,1]+015,072 SAY OemToAnsi(STR0031+' : '+SE1->E1_TIPO) SIZE 35, 7 OF oDlg PIXEL FONT oFont COLOR CLR_BLUE //Tipo
	@ aPosObj[1,1]+015,105 SAY OemToAnsi(STR0032+' : '+SE1->E1_PREFIXO) SIZE 40, 7 OF oDlg PIXEL FONT oFont COLOR CLR_BLUE //Prefijo
	@ aPosObj[1,1]+015,145 SAY OemToAnsi(STR0033+' : '+SE1->E1_NUM) SIZE 100, 7 OF oDlg PIXEL FONT oFont COLOR CLR_BLUE //Numero
	@ aPosObj[1,1]+025,010 SAY OemToAnsi(STR0034+' : '+Posicione('SA1',1,xFilial('SA1')+SE1->E1_CLIENTE+SE1->E1_LOJA,"SA1->A1_NOME")) SIZE 150, 7 OF oDlg PIXEL FONT oFont COLOR CLR_BLUE //Cliente
Endif
@ aPosObj[1,1],aPosObj[1,4]-82 TO aPosObj[1,3],aPosObj[1,4] LABEL "" OF oDlg  PIXEL
@ aPosObj[1,1]+005,aPosObj[1,4]-80 BITMAP RESOURCE _AMARELO	NO BORDER SIZE 10,7 OF oDlg PIXEL
@ aPosObj[1,1]+005,aPosObj[1,4]-70 SAY STR0035  SIZE 20, 7 OF oDlg PIXEL //Recibos
@ aPosObj[1,1]+015,aPosObj[1,4]-80 BITMAP RESOURCE _AZUL	NO BORDER 	SIZE 10,7 OF oDlg PIXEL
@ aPosObj[1,1]+015,aPosObj[1,4]-70 SAY STR0036  SIZE 20, 7 OF oDlg PIXEL //Saldo

oLbx := TCBROWSE():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3]-55, , , , , , , , , , ,, , , , , .T., , .T., , .F.,,)
If lMultiplo
	oLbx:BLDblClick := {|| F935Mark(oLbx,@nTotAjuste,@oTotAjuste,1)}
	
	bMarkAll	:= { || CursorWait() ,;
	F935Mark(oLbx,@nTotAjuste,@oTotAjuste,2),;
	CursorArrow();
	}
	bUnMarkAll	:= { || CursorWait() ,;
	F935Mark(oLbx,@nTotAjuste,@oTotAjuste,3),;
	CursorArrow();
	}
	bInverte		:= { || CursorWait() ,;
	F935Mark(oLbx,@nTotAjuste,@oTotAjuste,4),;
	CursorArrow();
	}
	SetKey( VK_F4 , bMarkAll )
	SetKey( VK_F5 , bUnMarkAll )
	SetKey( VK_F6 , bInverte )
	aAdd( aButtons ,	{;
	"CHECKED"						,;
	bMarkAll							,;
	OemToAnsi( STR0037 + "...<F4>" )	,;			//"Marca Todos"
	OemToAnsi( STR0038 )				 ;			//"Marca"
	})
	
	aAdd( aButtons ,	{;
	"UNCHECKED"						,;
	bUnMarkAll							,;
	OemToAnsi( STR0039 + "...<F5>" )	,;			//"Desmarca todos"
	OemToAnsi( STR0040 )				 ;			//"Desmarca"
	})
	aAdd( aButtons ,	{;
	"PENDENTE"						,;
	bInverte							,;
	OemToAnsi( STR0041 + "...<F6>" )	,;			//"Inverte todos"
	OemToAnsi( STR0042 )				 ;			//"Inverte"
	})
Endif
For nX:=1 To nBitMaps
	//Definir colunaa com o BITMAP
	DEFINE COLUMN oCol DATA FIELDWBlock(aCampos[nX][2],Select(TRB)) BITMAP HEADER OemToAnsi(aCampos[nX][1]) PICTURE  aCampos[nX][6] ALIGN LEFT SIZE CalcFieldSize(aCampos[nX,3],aCampos[nX,4],aCampos[nX,5],aCampos[nX,2],aCampos[nX,1]) PIXELS
	oLbx:AddColumn(oCol)
Next

//Definir as demais colunas
For nX:=(nBitMaps+1) To Len(aCampos)
	DEFINE COLUMN oCol DATA FIELDWBlock(aCampos[nX][2],Select(TRB)) HEADER OemToAnsi(aCampos[nX][1]) PICTURE  aCampos[nX][6] ALIGN LEFT SIZE CalcFieldSize(aCampos[nX,3],aCampos[nX,4],aCampos[nX,5],aCampos[nX,2],aCampos[nX,1]) PIXELS
	oLbx:AddColumn(oCol)
Next
   ACTIVATE MSDIALOG oDlg On INIT EnchoiceBar(oDlg,bOk,bCanc,,aButtons)
Else
       nOpca := 1
    EndIf

Set key VK_F4  To
Set key VK_F5  To
Set key VK_F6  To

Return nOpca

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณF935Legendaณ Autor ณ Adrian Perez Hernandez      			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Crea pantalla para mostrar status
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Fina935                                        			  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function F935Legenda(cAlias, nReg)
Local aLegenda := { {"BR_VERDE", STR0018 },	{"BR_PRETO", "Recibo Canc" },;	 //"Titulo en abierto"  // OP Cancelada
{"BR_VERMELHO", STR0021} ,{"BR_AZUL", "Generado na Factura"}} 	 //"Bajado totalmente"

Local uRetorno := .T.

If nReg = Nil	
	uRetorno:={}
	If  SEL->(ColumnPos("EL_DOCPOS"))>0 .And. SEL->(ColumnPos("EL_TIPAGR"))>0 
		Aadd(uRetorno, { 'Empty(EL_DOCPOS) .and. EL_TIPAGR<>"4"  .And. !EL_CANCEL    ', aLegenda[1][1] })
		Aadd(uRetorno, { '!Empty(EL_DOCPOS)', aLegenda[3][1] })
		Aadd(uRetorno, { 'Empty(EL_DOCPOS) .and. EL_TIPAGR=="4"', aLegenda[4][1] })
		Aadd(uRetorno, { 'EL_CANCEL', aLegenda[2][1] })
	EndIf
Else
	BrwLegenda(cCadastro, STR0006 , aLegenda) //"Leyenda"
Endif

Return uRetorno

Static Function F935Mark(oLbx,nTotAjuste,oTotAjuste,nOpc)
Local	cChave	:=	(TRB)->(EL_CLIENTE+EL_LOJA+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO+EL_RECIBO)
Local nRecno	:=	(TRB)->(Recno())
Local cMarca	:=	IIf((TRB)->TRB_MARCA  <> _DESMARCADO,_DESMARCADO,_MARCADO)
Local bWhile

DbSelectArea(TRB)
//Inverte o atual
If nOpc == 1
	bWhile	:=	{|| cChave==(TRB)->(EL_CLIENTE+EL_LOJA+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO+EL_RECIBO)}
	MsSeek(cChave)
	//Marcar todos
ElseIf nOpc == 2
	bWhile	:=	{|| .T.}
	DbGoTop()
	cMarca	:=	_MARCADO
	//DesMarcar todos
ElseIf nOpc == 3
	bWhile	:=	{|| .T.}
	DbGoTop()
	cMarca	:=	_DESMARCADO
	//Inverte todos
ElseIf nOpc == 4
	bWhile	:=	{|| .T.}
	DbGoTop()
Endif
While !Eof() .And. Eval(bWhile)
	If nOpc == 1 .Or. nOpc==4 //Inverte
		cMarca	:=	IIf((TRB)->TRB_MARCA  <> _DESMARCADO,_DESMARCADO,_MARCADO)
	Endif
	cMarcaAnt := TRB_MARCA
	RecLock(TRB,.F.)
	Replace TRB_MARCA  With cMarca
	MsUnlock()

	DbSkip()
Enddo
DbGoTo(nRecno)
oLbx:Refresh()

Return                

     
Static Function MenuDef()
Local aRotina := { { OemToAnsi(STR0001), "PesqBrw" , 0 , 1},; //"Pesquisar" //"Busqueda"
{ OemToAnsi(STR0002)	, "AxVisual" 	, 0 , 2},; //"Visualizar" //"Visualizar"
{ OemToAnsi(STR0022)	, "FDOCGR" , 0 , 4},; // este si
{ OemToAnsi(STR0005)	, "F935NCC(.F.)" 	 ,0 , 5},; //"Cancelar" //"Cancelar" F935NCC(.F.)
{ OemToAnsi(STR0006)	, "F935Legenda",0 , 6} } //"Le&genda" //"Leyenda"

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF084GeraNFบAutor Adrian Perez Hernandez					  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGener NDC O NCC segun lo que se le indique     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametros       
				ณaDato: registros con datos para crear documento		  บฑฑ
				  cTipo: Indica si va ser NDC o NCC        				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function F935GeraNF(aDato,cTipo,cNum) 

Local aCab 		:= {} 	
Local aItem 	:= {} 	
Local aLinea 	:= {} 	
Local lGera 	:= .T.
Local nNurec	:= 0
Local cIvaPos	:= ""
Local lExclui	:= .F.
Local aAux		:= {}
Local aAux1		:= {}
Local aData		:= {}
Local cNumAux	:= ""
Local cTipAux	:= ""
Local cRecibo	:= ""
Local cNumSE1	:= ""
Local nDes		:= 0
Local lAcho 	:= .F.
Local nOpc		:= 1
Local cTpVent	:= ""
Local nPercIvP	:= 1
Local aAreaSF2	:= {}
Local nTxMoeda	:= 0
Local nDoc		:= 0
Local aItemFac	:= {}
Local aItemAux	:= {}
Local nDocIt	:= 0
Local nPosItems	:= 0
Local lAgrupa	:= .F.
Local lPyme		:= .F.
Local aLinFac	:= {}
Local lDescon	:= GetNewPar('MV_DESCSAI','1') =='2'
Local cProvent	:= ""

Local dDataServ	:= dDatabase

Private lMsErroAuto := .F.    
PRIVATE aMv := If(Type('aMv') <> 'A',{},aMv)
Private lFina935 :=.T.
Private cIVPBas		:= ""
Private cIVPVal		:= ""
Private cIVABas		:= ""
Private cIVAVal		:= ""

If Len(aMv) = 0 
	aAdd(aMv, GETNEWPAR("MV_IVACAN", "F935"))
	aAdd(aMv, GETNEWPAR("MV_PIVCAN", "F935"))
	aAdd(aMv, GETNEWPAR("MV_CONDGR", "F935"))
	aAdd(aMv, GETNEWPAR("MV_IMPGR", "IVA"))
EndIf

Default cNum := ""


If lGera .and. len(aDato)>0 .and. SEL->(ColumnPos("EL_TIPAGR")) >0	.and. SEL->(ColumnPos("EL_DOCPOS"))>0 .and.SF2->(ColumnPos("F2_CANJE")) >0 .and. !Empty(aMv[01]) .and. !Empty(aMv[02])// SE1->EL_TIPO $ "NDC" .And. 
	cTipAux:=  "02"	
	
	aAux	:= {}
	aAux	:= fBuscaB1(aMv[01])
	
	aAux1	:= {}
	aAux1	:= fBuscaB1(aMv[02])
	
	cIVPBas		:= fSD2(aAux1[5])
	cIVPVal		:= fSF2(aAux1[5])
	cIVABas		:= fSD2(aAux[5])
	cIVAVal		:= fSF2(aAux[5])
				
	SEL->(DbSetOrder(2))      
	cNumAux:="2"		

	For nDoc := 1 To Len(aDato[5])
		aItemAux	:= {}
		lAcho 		:= .F.
		//EL_FILIAL+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO+EL_CLIORIG+EL_LOJORIG
		If SEL->(MsSeek(xFilial("SEL")+aDato[5][nDoc][_PREFIJO]+aDato[5][nDoc][_NUMERO]+aDato[5][nDoc][_PARCELA]+aDato[5][nDoc][_TIPO]+aDato[_CLIENTE]+aDato[_LOJA] ))
			While !sel->(EOF()) .And.  xFilial("SEL")+aDato[5][nDoc][_PREFIJO]+aDato[5][nDoc][_NUMERO]+aDato[5][nDoc][_PARCELA]+aDato[5][nDoc][_TIPO]+aDato[_CLIENTE]+aDato[_LOJA] ==;
			SEL->(EL_FILIAL+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO+EL_CLIORIG+EL_LOJORIG) .AND. !lAcho
			
				If SEL->EL_RECIBO == aDato[_RECIBO]
					lAcho:=.T.
					aDato[5][nDoc][_RECNO]		:= SEL->(RECNO())
					aDato[5][nDoc][_MOEDA] 		:= SEL->EL_MOEDA
					aDato[5][nDoc][_TAXMOEDA] 	:= IIf(Val(SEL->EL_MOEDA) >1,SEL->&("EL_TXMOE"+SEL->EL_MOEDA),1)
					aDato[5][nDoc][_TIPAGR] 	:= SEL->EL_TIPAGR
					aDato[5][nDoc][_RECVALID] 	:= .T.
				Else
					SEL->(dbskip())
				EndIf
			
			Enddo
			If lAcho
				aItemAux := FIN935GIt(aDato[5][nDoc][_NUMERO], aDato[5][nDoc][_PREFIJO], aDato[_CLIENTE], aDato[_LOJA], @aDato[5][nDoc][_RG1415], @aDato[5][nDoc][_IVAPOSD], @aDato[5][nDoc][_IVPPOSD], @aDato[5][nDoc][_RECVALID],@cProvent) //Realiza la agrupaci๓n de los items de la factura.
				If Len(aItemAux) > 0
					aDato[5][nDoc][_ITEMS] := aClone(aItemAux)
					aEval(aItemAux,{|x| aDato[5][nDoc][_VALFACT] += x[3]})
				EndIf
			EndIf
		EndIf
	
	Next nDoc
	
	nTxMoeda	:= 1
	cTpVent		:= "1"
	
	aAdd(aCab, {"F2_CLIENTE"		, aDato[02]							,Nil}) //C๓digo Cliente
	aAdd(aCab, {"F2_LOJA"			, aDato[03]							,Nil}) //Tienda Cliente //SEL->EL_LOJA
	aAdd(aCab, {"F2_DOC"			, cNum								,Nil}) //N๚mero de documento		
	aAdd(aCab, {"F2_TIPO"			, "C"								,Nil}) //Tipo da nota (C=Credito / D=Debito)
	aAdd(aCab, {"F2_NATUREZ"		, ""								,Nil}) //Naturaleza (Financiero)
	aAdd(aCab, {"F2_ESPECIE"		, cTipo								,Nil}) //Tipo de Documento para la tabla SF2 (RTS = Remito de Transferencia Salida)
	aAdd(aCab, {"F2_EMISSAO"		, dDatabase							,Nil}) //Fecha de Emisi๓n
	aAdd(aCab, {"F2_DTDIGIT"		, dDatabase							,Nil}) //Fecha de Digitaci๓n	
	aAdd(aCab, {"F2_MOEDA"			, Val(SEL->EL_MOEDA)				,Nil}) //Moneda
	aAdd(aCab, {"F2_TXMOEDA"		, nTxMoeda							,Nil}) //Tasa de moneda						
	aAdd(aCab, {"F2_TIPODOC"		, cTipAux							,Nil}) //Tipo de documento (utilizado en la funci๓n LOCXNF)								
	aAdd(aCab, {"F2_FORMUL"			, "S" 								,Nil}) //Indica si se utiliza un Formulario Propio para el documento
	aAdd(aCab, {"F2_COND"			, aMv[3]							,Nil}) //Condici๓n de pago												
	 
	aAdd(aCab, {"F2_TPVENT"			, cTpVent			    			,Nil}) //Tipo de venda //?Duda como se asigna
	aAdd(aCab, {"F2_FECDSE"			, dDataServ			 				,Nil}) //
	aAdd(aCab, {"F2_FECHSE"			, dDataServ			 				,Nil}) //
		
	aAdd(aCab, {"F2_PV"				, Subs(cNum ,1,Tamsx3("F2_PV")[1])	,Nil}) //Ponto de Venda
	aAdd(aCab, {"F2_SERIE"			, cPrefixo							,Nil}) //Serie del documento 

	aAdd(aCab, {"F2_RECPOS"  		,aDato[1]  							,Nil}) //Recibo
	aAdd(aCab, {"F2_PROVENT"  		,cProvent							,Nil}) //Provincia de entrega
	aAdd(aCab, {"F2_RG1415"  		,"" 								,Nil}) //RG1415
	
	aItemAux := {}
	
	aAreaAtu:=GetArea()
	SA1->(DbSetOrder(1))
	If SA1->(MsSeek(xFilial("SA1")+ aDato[_CLIENTE]+aDato[_LOJA]))	
		lAgrupa := VldRegFX6(cPrefixo,aAux1[6],cTipo,.T.) //Se verifica el numero de registros en el padr๓n sisa, si es mแs de 1 registro no agrupa
		aRecFX6	:= {}
	EndIf
	RestArea(aAreaAtu)
	aLinea := {}
	For nDoc := 1 To Len(aDato[5])
		lMiPyme := Val(aDato[5][nDoc][_RG1415]) > 200 
		
		If aDato[5][nDoc][_RECVALID]  //No calcul๓ IVA o IVP
		
			//Generaci๓n de los Items correspondientes a IVA si es que no se gener๓ en la factura
			If (aDato[5][nDoc][_TIPAGR] == "1" .or. aDato[5][nDoc][_TIPAGR] == "2") .and. aDato[5][nDoc][_IVAPOSD]
				For nDocIt := 1 To Len(aDato[5][nDoc][_ITEMS])
					aItem := {}
					If Len(aAux) > 0 //Se validan los datos correspondientes a Item para IVA
						aAdd(aItem, {"D2_COD"			, aAux[1]							,Nil}) //C๓digo de producto
						aAdd(aItem, {"D2_UM"			, aAux[2]							,Nil}) //Unidad de medida						
						aAdd(aItem, {"D2_QUANT"			, 1									,Nil}) //Cantidad
						aAdd(aItem, {"D2_PRCVEN"		, aDato[5][nDoc][_ITEMS][nDocIt][3]	,Nil}) //Precio de Venta
						aAdd(aItem, {"D2_TOTAL"			, aDato[5][nDoc][_ITEMS][nDocIt][3]	,Nil}) //Total				
						aAdd(aItem, {"D2_TES"			, aDato[5][nDoc][_ITEMS][nDocIt][6]	,Nil}) //TES						
						aAdd(aItem, {"D2_CF"			, aDato[5][nDoc][_ITEMS][nDocIt][7]	,Nil})//C๓digo Fiscal (completar seg๚n TES)
						aAdd(aItem, {"D2_LOCAL"			, aAux[3]							,Nil}) //Dep๓sito
						aAdd(aItem, {"D2_NFORI"			, aDato[5][nDoc][_ITEMS][nDocIt][9]	,Nil}) //Documento original	
						aAdd(aItem, {"D2_SERIORI"		, aDato[5][nDoc][_ITEMS][nDocIt][10],Nil}) //Serie original
						aAdd(aItem, {"D2_PROVENT"		, cProvent							,Nil}) //Provincia de entrega
						nDes := aDato[5][nDoc][_ITEMS][nDocIt][3]
						aAdd(aItem, {"D2_DESCON"		, IIF(lDescon,nDes,(nDes-0.01))		,Nil}) //descuento
						aAdd(aLinea, aClone(aItem))
					EndIf
				Next nDocIt
			EndIf
			
			//Generaci๓n de los Items correspondientes a IVP si es que no se gener๓ en la factura
			If (aDato[5][nDoc][_TIPAGR] == "1" .or. aDato[5][nDoc][_TIPAGR] == "3") .and. aDato[5][nDoc][_IVPPOSD]
				aItem := {}
				If Len(aAux1) > 0 //Se validan los datos correspondientes a Item para IVA	
					aAdd(aItem, {"D2_COD"			, aAux1[1]						,Nil}) //C๓digo de producto
					aAdd(aItem, {"D2_UM"			, aAux1[2]						,Nil}) //Unidad de medida						
					aAdd(aItem, {"D2_QUANT"			, 1								,Nil}) //Cantidad
					aAdd(aItem, {"D2_PRCVEN"		, aDato[5][nDoc][_VALFACT]		,Nil}) //Precio de Venta
					aAdd(aItem, {"D2_TOTAL"			, aDato[5][nDoc][_VALFACT]		,Nil}) //Total				
					aAdd(aItem, {"D2_TES"			, aAux1[5]						,Nil}) //TES						
					aAdd(aItem, {"D2_CF"			, aAux1[6]						,Nil})//C๓digo Fiscal (completar seg๚n TES)
					aAdd(aItem, {"D2_LOCAL"			, aAux1[3]						,Nil}) //Dep๓sito
					aAdd(aItem, {"D2_NFORI"			, aDato[5][nDoc][_NUMERO]		,Nil}) //Documento original	
					aAdd(aItem, {"D2_SERIORI"		, aDato[5][nDoc][_PREFIJO]		,Nil}) //Serie original	
					aAdd(aItem, {"D2_PROVENT"		, cProvent						,Nil}) //Provincia de entrega	
					nDes := aDato[5][nDoc][_VALFACT]
					aAdd(aItem, {"D2_DESCON"		,IIF(lDescon,nDes,(nDes-0.01))	,Nil}) //descuento
					aAdd(aLinea, aClone(aItem))
				EndIf
			EndIf
			
			//Si existe mแs de un registro en SISA o es una factura MyPime no se agrupan
			If (!lAgrupa .or. lMiPyme) .and. Len(aLinea) > 0
				nNewAlicuo	:= 0
				If !lAgrupa
					aAreaAtu := GetArea()
					SEL->(dbGoTo(aDato[5][nDoc][_RECNO]))
					nOpc:= VldRegFX6(cPrefixo,aAux1[6],cTipo)
					RestArea(aAreaAtu)
				EndIf
				If nOpc == 1
					F935ValidNum(ALLTRIM(cPrefixo),@cNum,cTipoDoc,.F.,cSerPesq)
					aCab[3][2] 	:= cNum
					aCab[9][2] 	:= Val(aDato[5][nDoc][_MOEDA])
					aCab[10][2] := aDato[5][nDoc][_TAXMOEDA]
					aCab[21][2] := cRG1415("NDC", Substr(cPrefixo,1,1), lMiPyme)
					
					lMsErroAuto	:= .F.
					lRet:=msExecAuto({|a,b,c,d,e| LocXNF(a,b,c,d,e)}, val(cTipAux), aCab, aLinea,3,"MATA465N")
					If lMsErroAuto		
				        MostraErro()
				        //lError := .T.	
				    Else
				    	//Actualizaciones de las tablas SF2, SE1 y SEL
				    	aAreaAtu := GetArea()
				    	F935ActDoc(aDato[_CLIENTE], aDato[_LOJA], cPrefixo, cNum, , cTipoDoc, aDato[5][nDoc][_NUMERO], aDato[_RECIBO],.T.)
				    	F935ActSel(aDato[5][nDoc][_RECNO], .T., cNum, cPrefixo, "")
				    	RestArea(aAreaAtu)
				    EndIf
				EndIf
			ElseIf (lAgrupa .and. !lMiPyme) .and. Len(aLinea) > 0 // Se agrupan los items de las facturas, en caso se haber diferentes moneda se agrupan por moneda
				nPosItems := aScan(aItemAux,{|x| x[1] == aDato[5][nDoc][_MOEDA] .and. x[2] == aDato[5][nDoc][_TAXMOEDA]})
				If nPosItems > 0
					aEval(aLinea,{|x| aAdd(aItemAux[nPosItems][3],x)})
					aAdd(aItemAux[nPosItems][4],aDato[5][nDoc][_RECNO])
				Else
					aAdd(aItemAux,{aDato[5][nDoc][_MOEDA],aDato[5][nDoc][_TAXMOEDA],aClone(aLinea),{aDato[5][nDoc][_RECNO]}})
				EndIf
			EndIf
			aLinea := {}
		Else
			aAreaAtu := GetArea()
			SEL->(DbGoTo(aDato[5][nDoc][_RECNO]))
			RecLock("SEL",.F.)
				SEL->EL_TIPAGR:="4"
			MsUnLock()
			MsgAlert(STR0060 + " / "+ EL_PREFIXO+ "/"+EL_NUMERO ,STR0003)
			RestArea(aAreaAtu)
		EndIf
		
		 
	Next nDoc
	
	//Se generan los documentos de los items que se agruparon
	If lAgrupa .and. Len(aItemAux) > 0
		For nDoc := 1 To Len(aItemAux)
			F935ValidNum(ALLTRIM(cPrefixo),@cNum,cTipoDoc,.F.,cSerPesq)
			aCab[3][2] 	:= cNum
			aCab[9][2] 	:= Val(aItemAux[nDoc][1])
			aCab[10][2] := aItemAux[nDoc][2]
			aCab[21][2] := cRG1415("NDC", Substr(cPrefixo,1,1), .F.)
			
			lMsErroAuto	:= .F.
			lRet:=msExecAuto({|a,b,c,d,e| LocXNF(a,b,c,d,e)}, val(cTipAux), aCab, aItemAux[nDoc][3],3,"MATA465N")
			If lMsErroAuto		
		        MostraErro()
		        //lError := .T.
			Else
				//Actualizaciones de las tablas SF2, SE1 y SEL
				aAreaAtu := GetArea()
				F935ActDoc(aDato[_CLIENTE], aDato[_LOJA], cPrefixo, cNum, /*Parcela*/ , cTipoDoc, /*cNumSE1*/, aDato[_RECIBO], .T.)
				For nDocIt := 1 To Len(aItemAux[nDoc][4])
					F935ActSel(aItemAux[nDoc][4][nDocIt], .T., cNum, cPrefixo, "")
				Next nDocIt
				RestArea(aAreaAtu)
		    EndIf 
		Next nDoc
	EndIf
	
EndIf
		 
Return

/*
Funci๓n: F935GeraNC
Autor: Raul Ortiz
Funci๓n utilizada para realizar la anulaci๓n o exlusi๓n de documentos.
*/
Function F935GeraNC(aDato,cTipo,cNum) 
Local aCab 		:= {} 	
Local aItem 	:= {} 	
Local aLinea 	:= {} 	
Local lGera 	:= .T.
Local lExclui	:= .F.
Local aAux		:= {}
Local aAux1		:= {}
Local aData		:= {}
Local cTipAux	:= ""
Local lAcho 	:= .F.
Local nOpc		:= 1
Local cTpVent	:= ""
Local nDoc		:= 0
Local nDocIt	:= 0
Local aDocAux	:= {}
Local nDocPos	:= 0
Local cTes		:= ""
Local cCfo		:= ""
Local lDescon	:= GetNewPar('MV_DESCSAI','1') =='2'

Local dDataServ:= dDatabase

Private lMsErroAuto := .F.    
PRIVATE aMv := If(Type('aMv') <> 'A',{},aMv)
Private lFina935 :=.T.

If Len(aMv) = 0 
	aAdd(aMv, GETNEWPAR("MV_IVACAN", "F935"))
	aAdd(aMv, GETNEWPAR("MV_PIVCAN", "F935"))
	aAdd(aMv, GETNEWPAR("MV_CONDGR", "F935"))
	aAdd(aMv, GETNEWPAR("MV_IMPGR", "IVA"))
EndIf

Default cNum := ""


If lGera .and. len(aDato)>0 .and. SEL->(ColumnPos("EL_TIPAGR")) >0	.and. SEL->(ColumnPos("EL_DOCPOS"))>0 .and.SF2->(ColumnPos("F2_CANJE")) >0 .and. !Empty(aMv[01]) .and. !Empty(aMv[02])// SE1->EL_TIPO $ "NDC" .And. 
	cTipAux:=  "04"
	SEL->(DbSetOrder(2))   		

	aDocAux		:= {}
	For nDoc := 1 To Len(aDato[5])
		lAcho 		:= .F.
		
		/*//EL_FILIAL+EL_RECIBO+EL_TIPODOC+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO+EL_VERSAO*/
		//EL_FILIAL+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO+EL_CLIORIG+EL_LOJORIG
		If SEL->(MsSeek(xFilial("SEL")+aDato[5][nDoc][_PREFIJO]+aDato[5][nDoc][_NUMERO]+aDato[5][nDoc][_PARCELA]+aDato[5][nDoc][_TIPO]+aDato[_CLIENTE]+aDato[_LOJA] ))
			While !sel->(EOF()) .And.  xFilial("SEL")+aDato[5][nDoc][_PREFIJO]+aDato[5][nDoc][_NUMERO]+aDato[5][nDoc][_PARCELA]+aDato[5][nDoc][_TIPO]+aDato[_CLIENTE]+aDato[_LOJA] ==;
			SEL->(EL_FILIAL+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO+EL_CLIORIG+EL_LOJORIG) .AND. !lAcho
			
				If SEL->EL_RECIBO == aDato[_RECIBO]
					lAcho:=.T.
					
					nDocPos	:= aScan(aDocAux,{|x| x[1] ==  SEL->EL_DOCPOS .and. x[2] ==  SEL->EL_SERPOS })
					If nDocPos > 0
						aAdd(aDocAux[nDocPos][3],SEL->(Recno()))
					Else
						aAdd(aDocAux, {SEL->EL_DOCPOS, SEL->EL_SERPOS, {SEL->(Recno())}})
					EndIf
					aDato[5][nDoc][_RECVALID] 	:= .T.
				Else
					SEL->(dbskip())
				EndIf
			
			Enddo
		EndIf
	
	Next nDoc
	
	
	aAux	:= {}
	aAux1	:= {}
	aAux	:= fBuscaB1(aMv[01])
	aAux1	:= fBuscaB1(aMv[02])
	For nDoc := 1 To Len(aDocAux)
		If F935Docs(aDato[_RECIBO], aDocAux[nDoc][1], aDocAux[nDoc][2], aDato[_CLIENTE], aDato[_LOJA], @aDocAux[nDoc][3], aDocAux[nDoc][1])
			aCab	:= {}
			aLinea	:= {}
			aItem	:= {}
			
			aAreaAt:=GetArea()
			SF2->(DbSetOrder(2))
			If SF2->(MsSeek(xFilial("SF2")+aDato[_CLIENTE]+aDato[_LOJA]+aDocAux[nDoc][1]+aDocAux[nDoc][2]+"C"+"NDC"))
				lExclui := Empty(SF2->F2_CAEE) //Si el documento fue transmitido se genera NCC, en caso contrario se anula el documento.
				cTpVent	:= SF2->F2_TPVENT
				If lExclui
					AADD(aCab,{"F2_DOC"    ,SF2->F2_DOC    ,Nil})
					AADD(aCab,{"F2_SERIE"  ,SF2->F2_SERIE  ,Nil})
					AADD(aCab,{"F2_CLIENTE",SF2->F2_CLIENTE,Nil})
					AADD(aCab,{"F2_LOJA"   ,SF2->F2_LOJA   ,Nil})
					AADD(aCab,{"F2_TIPODOC",SF2->F2_TIPODOC,Nil})
					AADD(aCab,{"F2_MOEDA"  ,SF2->F2_MOEDA  ,Nil})
					AADD(aCab,{"F2_TXMOEDA",SF2->F2_TXMOEDA,Nil})
					
				Else
					If cTpVent=="1" 
						cTpVent:= "B"
				 	ElseIf cTpVent=="2"
				 		cTpVent:= "S"
				 	Else
				 		cTpVent:= "A"
				 	Endif
					F935ValidNum(ALLTRIM(cPrefixo),@cNum,cTipoDoc,.F.,cSerPesq)
					aAdd(aCab, {"F1_FORNECE"		, aDato[02]							,Nil}) //C๓digo Cliente
					aAdd(aCab, {"F1_LOJA"			, aDato[03]							,Nil}) //Tienda Cliente //SEL->EL_LOJA
					aAdd(aCab, {"F1_DOC"			, cNum								,Nil}) //N๚mero de documento		
					aAdd(aCab, {"F1_TIPO"			, "C"								,Nil}) //Tipo da nota (C=Credito / D=Debito)
					aAdd(aCab, {"F1_NATUREZ"		, ""								,Nil}) //Naturaleza (Financiero)
					aAdd(aCab, {"F1_ESPECIE"		, cTipo								,Nil}) //Tipo de Documento para la tabla SF2 (RTS = Remito de Transferencia Salida)
					aAdd(aCab, {"F1_EMISSAO"		, dDatabase							,Nil}) //Fecha de Emisi๓n
					aAdd(aCab, {"F1_DTDIGIT"		, dDatabase							,Nil}) //Fecha de Digitaci๓n	
					aAdd(aCab, {"F1_MOEDA"			, SF2->F2_MOEDA						,Nil}) //Moneda
					aAdd(aCab, {"F1_TXMOEDA"		, SF2->F2_TXMOEDA					,Nil}) //Tasa de moneda						
					aAdd(aCab, {"F1_TIPODOC"		, cTipAux							,Nil}) //Tipo de documento (utilizado en la funci๓n LOCXNF)								
					aAdd(aCab, {"F1_FORMUL"			, "S" 								,Nil}) //Indica si se utiliza un Formulario Propio para el documento
					aAdd(aCab, {"F1_COND"			, aMv[3]							,Nil}) //Condici๓n de pago												 
					aAdd(aCab, {"F1_TPVENT"			, cTpVent					    	,Nil}) //Tipo de venda //?Duda como se asigna
					aAdd(aCab, {"F1_FECDSE"			, dDataServ			 				,Nil}) //
					aAdd(aCab, {"F1_FECHSE"			, dDataServ			 				,Nil}) //	
					aAdd(aCab, {"F1_PV"				, Subs(cNum ,1,Tamsx3("F2_PV")[1])	,Nil}) //Ponto de Venda
					aAdd(aCab, {"F1_SERIE"			, cPrefixo							,Nil}) //Serie del documento
					aAdd(aCab, {"F1_PROVENT"		, SF2->F2_PROVENT					,Nil}) //Provincia de entrega
					aAdd(aCab, {"F1_RG1415"			, cRG1415("NCC", Substr(cPrefixo,1,1), Val(SF2->F2_RG1415) > 200),Nil}) //RG1415 

				EndIf
		
				SD2->(dbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
				While SD2->(!Eof()) .and. SD2->D2_FILIAL == xFilial("SD2")  .and.;
						SD2->D2_DOC == SF2->F2_DOC .and. SD2->D2_SERIE == SF2->F2_SERIE .and.;
						SD2->D2_CLIENTE == SF2->F2_CLIENTE .and. SD2->D2_LOJA == SF2->F2_LOJA
					cTes := ""
					cCfo := ""
					aItem:={}
					If lExclui
						AADD(aItem,{"D2_DOC"    ,SD2->D2_DOC    ,Nil})
						AADD(aItem,{"D2_SERIE"  ,SD2->D2_SERIE  ,Nil})
						AADD(aItem,{"D2_CLIENTE",SD2->D2_CLIENTE,Nil}) //SD2->D2_CLIENTERNECE,Nil})
						AADD(aItem,{"D2_LOJA"   ,SD2->D2_LOJA   ,Nil})
					Else
						aAdd(aItem, {"D1_COD"			, SD2->D2_COD									,Nil}) //C๓digo de producto
						aAdd(aItem, {"D1_UM"			, SD2->D2_UM									,Nil}) //Unidad de medida						
						aAdd(aItem, {"D1_QUANT"			, SD2->D2_QUANT									,Nil}) //Cantidad
						aAdd(aItem, {"D1_VUNIT"			, Iif(lDescon, SD2->D2_DESCON, SD2->D2_PRCVEN)	,Nil})	
						aAdd(aItem, {"D1_TOTAL"			, Iif(lDescon, SD2->D2_DESCON, SD2->D2_TOTAL)	,Nil}) //Total
						If aAux[1] == SD2->D2_COD
							cTes := POSICIONE("SF4",1, xFilial("SF4")+SD2->D2_TES,"F4_TESDV")
							If !Empty(cTes)
								cCfo := POSICIONE("SF4",1, xFilial("SF4")+cTes,"F4_CF")
							EndIf
							//cTes := aAux[4]
							//cCfo := aAux[6]
						ElseIf aAux1[1] == SD2->D2_COD
							cTes := aAux1[4]
							cCfo := aAux1[6]
						EndIf				
						aAdd(aItem, {"D1_TES"			, cTes											,Nil}) //TES						
						aAdd(aItem, {"D1_CF"			, cCfo											,Nil})//C๓digo Fiscal (completar seg๚n TES)
						aAdd(aItem, {"D1_LOCAL"			, SD2->D2_LOCAL									,Nil}) //Dep๓sito
						aAdd(aItem, {"D1_PROVENT"		, SD2->D2_PROVENT								,Nil}) //Provincia de entrega		
						aAdd(aItem, {"D1_VALDESC"		, SD2->D2_DESCON								,Nil}) //descuento
					EndIf
					AADD(aLinea,ACLONE(aItem))
					SD2->(dbSkip())
				EndDo
					
					
				lMsErroAuto	:= .F.
				If lExclui
					lRet:= MSExecAuto({|x,y,z| MATA465N(x,y,z)},aCab,aLinea,5)
				Else
					lRet:=msExecAuto({|a,b,c,d,e| LocXNF(a,b,c,d,e)}, val(cTipAux), aCab, aLinea,3,"MATA465N")
				EndIf
				If lMsErroAuto		
			        MostraErro()
			        //lError := .T.
				Else
					//Actualizaciones de las tablas SF1, SE1 y SEL
					aAreaAtu := GetArea()
					If !lExclui
						F935ActDoc(aDato[_CLIENTE], aDato[_LOJA], cPrefixo, cNum, , cTipoDoc, "", aDato[_RECIBO], .F.)
					EndIf
					For nDocIt := 1 to Len(aDocAux[nDoc][3])
						F935ActSel(aDocAux[nDoc][3][nDocIt], .F., "", "", "")
					Next nDocIt
					RestArea(aAreaAtu)
				EndIf
				
			EndIf	
			RestArea(aAreaAt)
		EndIf
	Next nDoc
		
EndIf

Return

/*
Funci๓n: F935Docs
Autor: Raul Ortiz
Funci๓n utilizada para verificar los documentos necesarios para la anulaci๓n/exclusi๓n en caso de haber sido agrupados
*/

Static Function F935Docs(cRecibo, cDosPos, cSerPos, cCliente, cLoja, aRecs, cDoc)

Local nCounter	:=	0
Local cAliasSEL	:=	'DOCSEL'                      
Local cQuery	:=	''
Local ni 		:= 1 
Local aArea		:= GetArea()
Local aRecsAuxs	:= {}
Local lRet		:= .T.
Local nRecAux	:= 0
Local nRecPos	:= 0
Local aRecsNo	:= {}
Local cMsg		:= ""
              

	cQuery := "SELECT EL_NUMERO,"
	cQuery += "R_E_C_N_O_ RECNO "
	cQuery += "  FROM "+	RetSqlName("SEL") + " SEL "
	cQuery += " WHERE EL_FILIAL	  ='" +xFilial('SEL')+ "'"
	cQuery += "   AND EL_RECIBO   = '" + cRecibo + " '"
	cQuery += "   AND EL_DOCPOS   = '" + cDosPos + " '"
	cQuery += "   AND EL_SERPOS   = '" + cSerPos + " '"
	cQuery += "   AND EL_CLIORIG  = '" + cCliente + " '"
	cQuery += "   AND EL_LOJORIG  = '" + cLoja + " '"
	cQuery += "   AND D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSEL, .F., .T.)
	
	dbSelectArea(cAliasSEL)                    
	
	
	While (cAliasSEL)->(!Eof()) 
	
		Aadd(aRecsAuxs,{(cAliasSEL)->EL_NUMERO, (cAliasSEL)->RECNO})
	
		(cAliasSEL)->(DbSkip())
	Enddo
	
	//Se verifica que los datos seleccionados para la anulaci๓n sean los mismos que fueron agrupados en la NDC.
	If Len(aRecsAuxs) == Len(aRecs)
		lRet := .T.
	Else
		For nRecAux := 1 To Len(aRecsAuxs)
			nRecPos	:= aScan(aRecs,{|x| x == aRecsAuxs[nRecAux][2]})
			If nRecPos == 0
				aAdd(aRecsNo, aRecsAuxs[nRecAux][2])
				cMsg += aRecsAuxs[nRecAux][1] + Chr(13)+Chr(10)
			EndIf
		Next nRecAux
		
		If Len(aRecsNo) > 0
			lRet := MSGYESNO( STR0064 + cDoc + " :" + Chr(13)+Chr(10) + cMsg + STR0066, STR0063)
			If lRet
				aEval(aRecsNo,{|x| aAdd(aRecs,x)})
			EndIf
		EndIf
	EndIf

	(cAliasSEL)->(DbCloseArea())
	RestArea(aArea)

Return lRet

 
/*
Funci๓n: F935ActDoc
Autor: Raul Ortiz
Funci๓n utilizada para actualizar los documentos generados.
*/
Static function F935ActDoc(cCliente, cLoja, cPrefixo, cNumDoc, cParcela, cTipo, cNumSE1, cRecibo, lFatc) 
Local aArea		:= GetArea()
Local aAreaSE1	:= SE1->(GetArea())
Local aAreaSF1	:= SF1->(GetArea())
Local aAreaSF2	:= SF2->(GetArea())

Default cCliente	:= ""
Default	cLoja		:= ""
Default cPrefixo	:= ""
Default	cNumDoc		:= ""	
Default cParcela	:= Space(Tamsx3("E1_PARCELA")[1])
Default cTipo		:= ""
Default cNumSE1		:= ""
Default cRecibo		:= ""
Default lFact		:= .T.

	If !Empty(cNumSE1)
		SE1->(DbSetOrder(2)) //E1_FILIAL   +E1_CLIENTE+E1_LOJA+  E1_PREFIXO+E1_NUM+  E1_PARCELA+E1_TIPO
		If SE1->(MsSeek(xFilial("SE1")+cCliente+cLoja+cPrefixo +cNumDoc+cParcela+cTipo )) .AND. SE1->(ColumnPos("E1_RECGR"))>0
			RecLock("SE1",.F.)
					SE1->E1_RECGR:= cNumSE1
			MsUnLock()
		Endif
	EndIf 
	
	If lFatc
		SF2->(DbSetOrder(2)) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
		If SF2->(MsSeek(xFilial("SF2")+cCliente+cLoja+cNumDoc+cPrefixo+"C"+cTipo )) .AND. SF2->(ColumnPos("F2_RECPOS"))>0  .AND. SF2->(ColumnPos("F2_IVAPOS"))>0
			RecLock("SF2",.F.)
					SF2->F2_RECPOS:= cRecibo
					SF2->F2_IVAPOS:= "S"
			MsUnLock()
		EndIf
	Else
		//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		SF1->(DbSetOrder(1))
		If SF1->(MsSeek(xFilial("SF1")+cNumDoc+cPrefixo+cCliente+cLoja)) .AND. SF1->(ColumnPos("F1_RECPOS"))>0  .AND. SF1->(ColumnPos("F1_IVAPOS"))>0 
			RecLock("SF1",.F.)
					SF1->F1_RECPOS:= cRecibo
					SF1->F1_IVAPOS = "S"
			MsUnLock()
		EndIF
	EndIf
	
	RestArea(aAreaSE1)
	RestArea(aAreaSF1)
	RestArea(aAreaSF2)
	RestArea(aArea)

Return


/*
Funci๓n: F935ActDoc
Autor: Raul Ortiz
Funci๓n utilizada para actualizar los documentos generados.
*/
Static Function F935ActSel(nNurec, lFact, nNumDocNF, cPrefixo, cFilPos)

Default	nNurec	:= 0

	If SEL->(ColumnPos("EL_DOCPOS"))>0 .And. SEL->(ColumnPos("EL_SERPOS"))>0 .And. SEL->(ColumnPos("EL_FILPOS"))>0 .AND. SEL->(ColumnPos("EL_STPOSDT"))>0 //nNumDocNF>0
 		SEL->(DbGoTo(nNurec))
 		RecLock("SEL",.F.)
 		If lFact
	 		SEL->EL_DOCPOS	:= nNumDocNF
	 		SEL->EL_SERPOS	:= cPrefixo
	 		SEL->EL_FILPOS	:= xFilial("SEL") //aData[5]
	 		SEL->EL_STPOSDT	:= "1"
	 	Else
	 		SEL->EL_DOCPOS	:= ""
	 		SEL->EL_SERPOS	:= ""
	 		SEL->EL_FILPOS	:= ""
	 		SEL->EL_STPOSDT	:= ""
	 		SEL->EL_SISA 	:= ""
	 		SEL->EL_TIPAGRO	:= ""	 		
 		EndIf
		SEL->(MsUnLock())
	EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF935ValidNumบAutor  Adrian Perez Hernandez  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida numeracion											  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA935												      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F935ValidNum(cPrefixo,cNum,cTipoDoc,lCancel,cSerSX5)
Local lRet := .T.
Local aAreaSE1 := SE1->(GetArea())	


If lCancel
	DbSelectArea('SX5')
	DbSetOrder(1)
	If SX5->(MsSeek(xFilial("SX5")+"01"+cSerSX5)) 
		cNum:=	Substr( X5Descri(), 1, FWTamSX3('E1_NUM')[1] )
	EndIf	
EndIf

// Verifica se ja existe algum documento com a mesma numera็ใo no contas a receber
DbSelectArea("SE1")
DbSetOrder( 1 )
While SE1->(!Eof()) .And. lRet
	If  MsSeek( xFilial("SE1")+cSerSX5+cNum+Space(FWTamSX3('E1_PARCELA')[1])+cTipoDoc)
		SX5->(MsSeek(xFilial()+'01'+cSerSX5))
		RecLock("SX5",.F.)
		Replace X5_DESCRI  With Soma1(cNum)
		Replace X5_DESCENG With Soma1(cNum)
		Replace X5_DESCSPA With Soma1(cNum)
		SX5->(MsUnlock()) 
		cNum := Substr(X5Descri(),1,FWTamSX3('E1_NUM')[1]) 
		lUnlock	:= .F.
	Else
		lRet := .F.
	EndIf		                                                 
	SE1->(DbSkip())
EndDo

// Valida o numero no sx5 utilizando a mesma valida็ใo que ้ feita no momento de emitir o documento
// pelo modulo de faturamento
While !VldSX5Num(cNum,cSerSX5,.F.)
		SX5->(MsSeek(xFilial()+'01'+cSerSX5))
		RecLock("SX5",.F.)
		Replace X5_DESCRI  With Soma1(cNum)
		Replace X5_DESCENG With Soma1(cNum)
		Replace X5_DESCSPA With Soma1(cNum)
		SX5->(MsUnlock()) 
		cNum := Substr(X5Descri(),1,FWTamSX3('E1_NUM')[1])
		lUnlock	:= .F. 
EndDo		

RestArea(aAreaSE1)

Return cNum

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfValorSF2		   บAdrian Perez Hernandez      		 	บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExtrae ddatos de la NF creada SEL para el ivaposdatado	   ฑฑ
ฑฑบ    				                                                      บฑฑ                 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametros  ณ 														  บฑฑ
                           cCliente:Cliente								  บฑฑ
                           cLoja: Tienda								  บฑฑ
                           cDoc:  Numero de documento					  บฑฑ
                           cCol: Columna del impuesto calculado			 บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
*/
Static Function fValorSF2(cCliente,cLoja,cDoc,cCol,cColVl,lIVA,cPref)

Local aSF2area:=SF2->(GetArea()) 
Local aData:= {}
Local  aFIva	:= FilImpto({"3"},{"I"},{},{})
Local nBasIVA:= 0
Local nVlrIVA :=0
Local nlI :=1
Local aLivIv:={}
Default  cPref:=""
Default lIva := .f.

	DbSelectArea("SF2")
	SF2->(DbSetOrder(2))
	If SF2->(MsSeek(xFilial("SF2")+ cCliente+cLoja+cDoc+cPref))	
	
		For nlI:=1 To Len(aFIva)
			If  Ascan(aLivIv,aFIva[nlI][3])==0   
				aAdd(aLivIv,aFIva[nlI][3]) 
				cCpBas:="F2_BASIMP"+aFIva[nlI][3]
				cCpVlr:="F2_VALIMP"+aFIva[nlI][3]
				nBasIVA:=nBasIVA+ SF2->(&(cCpBas))
				nVlrIVA:=nVlrIVA+ SF2->(&(cCpVlr))
			EndIf	
		Next
		aadd(aData,SF2->F2_VALMERC) //1
		aadd(aData,SF2->F2_PV)	//2
		aadd(aData,nBasIVA)//3Impuesto indicado
		aadd(aData,SF2->F2_SERIE) //4
		aadd(aData,SF2->F2_FILIAL) //5
		aadd(aData,SF2->F2_CANJE) 
		If lIva
			aadd(aData,nVlrIVA)// Vl 3Impuesto indicado
		Else
			aadd(aData,SF2->(&(cColVl)))// Vl 3Impuesto indicado
		EndIf
	EndIf
	SF2->(RestArea(aSF2area))                                                                                                             
return aData 

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfBuscaB1   บAdrian Perez Hernandez      		 		      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExtrae informacion del producto informado en el parametro	   ฑฑ
ฑฑบ    				                                                      บฑฑ                 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametros  ณ 														  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
                 cParametro: Producto de la SB1 informado en alguno       บฑฑ
                 		     de los parametros MV_PIVCAN y MV_IVACAN      บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
*/ 
Static Function fBuscaB1(cParametro)
Local aData:={}
Local lExiB1:= .F.
	DbSelectArea("SB1")  
	SB1->( dbSetOrder(1))
	If MsSeek(xFilial("SB1")+cParametro)
		aadd(aData,SB1->B1_COD) // codigo
		aadd(aData,SB1->B1_UM) // unidad de medida
		aadd(aData,SB1->B1_LOCPAD) // Grupo
		aadd(aData,SB1->B1_TE) // tes de entrada
		aadd(aData,SB1->B1_TS) // tes de salida
		lExiB1:=.T.
	EndIf
	SB1->(DbCloseArea())	
	If lExiB1
		DbSelectArea("SF4") 
		SF4->( dbSetOrder(1) )
		If MsSeek(xFilial('SF4')+iif(cTipo=="NDC",aData[5],aData[4]))
			aadd(aData,SF4->F4_CF)
		Else
			aadd(aData,"")
		EndIf
		SF4->(DbCloseArea())
	EndIf
return aData

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfSD2		   บAdrian Perez Hernandez      		 		  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca el campo que   corresponde al impuesto calculado	   ฑฑ
ฑฑบ    				                                                      บฑฑ                 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametros  ณ 														  บฑฑ
                           cTES: TES usada en el calculo				  บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
*/
Static function fSD2(cTES)
Local aImpInf:={}
Local cCol:=""
Local nI:=0
	aImpInf := TesImpInf(cTES)
	For nI := 1 To Len(aImpInf)
		cCol:= aImpInf[nI][08]
	Next
return cCol

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfParametros   บAdrian Perez Hernandez      		 		  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida si los parametros MV_IVACAN y MV_PIVCAN	          บฑฑ
 	           valida que las TES de los productos informados no 		  บฑฑ
 	           esten vacias tanto para TES de entrada y salida 			  ฑฑ
ฑฑบ    				                                                      บฑฑ                 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametros  ณ 	aAux:Tes de entrada y salida						  บฑฑ
					cPara:Parametro validado                              บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
*/
static function fParametros(aAux,cPara)
Local lAux:= .F.
If len(aAux)>0
	
	If !Empty(aAux[4]) .And. !Empty(aAux[5]) 
		lAux:=.T.
	Else
		lAux:=.F.
		MsgAlert(STR0056+cPara,STR0003)
	EndIf

Else
		lAux:=.F.
		MsgAlert(STR0057+cPara,STR0003)
EndIf
Return lAux

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบPrograma  ณF935GravaบAutor  ณAdrian Perez Hernandez					  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณComienza a grabar los titulos.                   			  บฑฑ
ฑฑบ   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametros       ณ                                                     บฑฑ
ฑฑบ   บฑฑ
ฑฑบaRecSE1,         ณ  Regiistros seleccionados                           บฑฑ
ฑฑบlMultiplo,       ณ  Indica si estan Marcados o descmarcados            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
*/
Function F935Grava(aRecSE1,lMultiplo,lExterno,lAuto)

Local nOpc		:= 3
Local lRet		:=	.T.
Local aGerar	:=	{}
Local nRecSX5	:=	0

Local nX		:=1   
Local cNum	:=""
Private lMsErroAuto	:=	.F.
Private cProvent 	:= ""
Default lExterno 	:= .F.
Private cPrefixo	:="DC"
//Cria็ใo das variaveis caso seja executado desde o FINA840
 
Private aRecFX6	:=	{}
Private nNewAlicuo := 	IIf( Type("nNewAlicuo")=="U",0,nNewAlicuo)
Private lTemFX6:=	IIf( Type("lTemFX6")=="U",.F.,lTemFX6)
Private aMv:= IIf( Type("aMv")=="U",{},aMv)   
Private aIndices:=	IIf( Type("aIndices")=="U",{},aIndices)  //Array necessario para a funcion del FilBrowse
Private bFiltraBrw :=  IIf( Type("bFiltraBrw")=="U", {|| .T. } ,bFiltraBrw)   
Private cMoedaTx,nC	:=	IIf( Type("cMoedaTx")=="U",MoedFin(),cMoedaTx)    
Private nNumDocNF:=IIf( Type("nNumDocNF")=="U",0,nNumDocNF)    
Private cLocxNFPV:=IIf( Type("cLocxNFPV")=="U","",cLocxNFPV) 
Private cTipo:=IIf( Type("cTipo")=="U","",cTipo)
Private TRB  := IIf( Type("TRB")=="U",GetNextAlias(),TRB)    
Private aMV_PAR		:= IIf( Type("aMV_PAR")=="U",Array(7),aMV_PAR)    
Private TRB1  := GetNextAlias() 
Private lUnlock	:= .F.
Default lAuto 	:=.f.
Default aRecSE1	:={}

If lAuto
	AAdd(aGerar,aRecSE1)
	cTipo:="NDC"
Else
	DbSelectArea(TRB)
	DbGoTop()
	
	While !(TRB)->(EOF())
		If !lMultiPlo .Or. (Alltrim((TRB)->TRB_MARCA)==_MARCADO)
			If (nPos	:=	Ascan(aGerar,{|x| x[1] == (TRB)->EL_RECIBO .And. x[2] == (TRB)->EL_CLIENTE .And. x[3] == (TRB)->EL_LOJA})) > 0 //(nPos	:=	Ascan(aGerar,{|x| x[2]==(TRB)->EL_CLIENTE+(TRB)->EL_LOJA+(TRB)->EL_NUMERO}))==0
				//AAdd(aGerar,{(TRB)->(Recno()),(TRB)->EL_PREFIXO,(TRB)->EL_VALOR,(TRB)->EL_NUMERO,(TRB)->EL_PARCELA,(TRB)->EL_TIPO,(TRB)->EL_CLIENTE,(TRB)->EL_LOJA,(TRB)->EL_RECIBO })
				aAdd(aGerar[nPos][5], {(TRB)->(Recno()), (TRB)->EL_PREFIXO, (TRB)->EL_VALOR, (TRB)->EL_NUMERO, (TRB)->EL_PARCELA, (TRB)->EL_TIPO, "", "", "", "", 0, , .F., .F., .F.})
				aGerar[nPos][4] += (TRB)->EL_VALOR
			Else
				aAdd(aGerar,{(TRB)->EL_RECIBO, (TRB)->EL_CLIENTE, (TRB)->EL_LOJA, (TRB)->EL_VALOR, {{(TRB)->(Recno()), (TRB)->EL_PREFIXO, (TRB)->EL_VALOR, (TRB)->EL_NUMERO, (TRB)->EL_PARCELA, (TRB)->EL_TIPO, "", "", "", "", 0, , .F., .F., .F.}}})
			Endif
		Endif
		(TRB)->(DbSkip())
	Enddo 
EndIf	
ProcRegua(Len(aGerar)*2)
If Len(aGerar) >0 
	For nX:=1 To Len(aGerar) 
		cPrefixo := aGerar[nX][5][1][2]	
		// devolvevariavel pesquisa serie documento fiscal
		
		aSerP:= a935PSer(cPrefixo, aGerar[nX][5][1][4], cTipo )//a935PSer(aGerar[nX][2],aGerar[nX][4],cTipo )
		
	    cPrefixo:=aSerP[1]
		cSerPesq:=aSerP[2]
	
		DbSelectArea('SX5')
		DbSetOrder(1)
		cTipoDoc:=cTipo
		If SX5->(MsSeek(xFilial()+'01'+ALLTRIM(cSerPesq)))
			nTimes := 0
			While !MsRLock() .and. nTimes < 10
				nTimes++
				Inkey(.1)
				MsSeek( xFilial("SX5")+"01"+ALLTRIM(cSerPesq),.F. )
			EndDo
			If MsRLock()
				cNum	:=	Substr(X5Descri(),1,FWTamSX3('EL_NUMERO')[1])
				nRecSX5	:=	Recno()
				lUnlock	:= .T.
			Else
			    If lExterno
				     lTrava:=.F.
				     lCont:=.T.
					While !lTrava 
						nTimes:=1
						While !MsRLock() .and. nTimes < 20
							nTimes++
							Inkey(.1)
							MsSeek( xFilial("SX5")+"01"+ALLTRIM(cSerPesq),.F. )
						EndDo
						If MsRLock()
							cNum	:=	Substr(X5Descri(),1,FWTamSX3('E1_NUM')[1])
							nRecSX5	:=	Recno()
							lTrava  := .T.
							lUnlock := .T.
					
						EndIf	
					EndDo	
				EndIf
			Endif
		
		Endif
		
	 
		F935ValidNum(ALLTRIM(cPrefixo),@cNum,cTipoDoc,.F.,cSerPesq)
		
		cProvent:= ""
		If lRet
			IncProc(STR0011+ALLTRIM(cPrefixo)+"/"+cNum) 
			lMsErroAuto := .F.
			If Abs(aGerar[nX][4]) > 0
				If cTipo=="NDC"
					F935GeraNF(aGerar[nX],cTipo,cNum)
				Else
					F935GeraNC(aGerar[nX],cTipo,cNum)
				EndIf  
			EndIf	
		Endif
	Next
EndIf

If nRecSX5 > 0 .and. lUnlock
	SX5->(MsGoTo(nRecSX5))
	MsUnLock()
Endif

Return



/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfSf2		   บPaulo					      		 		  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca el campo que   corresponde al valor impuesto calculado ฑฑ
ฑฑบ    				                                                      บฑฑ                 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametros  ณ 														  บฑฑ
                           cTES: TES usada en el calculo				  บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
*/
Static function fSF2(cTES)
Local aImpInf:={}
Local cCol:=""
Local nI:=0
	aImpInf := TesImpInf(cTES)
	For nI := 1 To Len(aImpInf)
		cCol:= aImpInf[nI][06]
	Next
return cCol





Function a935PSer(cPref,cNum,cTpGer) 

Local cNumPv:= Subs(cNum,1,Tamsx3("F2_PV")[1])
Local cIdPv:=POSICIONE("CFH",1, xFilial("CFH")+cNumPv,"CFH_IDPV")
Local cSerDoc:=""
Local cSerPesq:=""

If cTpGer=="NDC"
	cSerDoc:= Posicione("SFP",5,xFilial("SFP")+cFilAnt+Subs(cPref,1,3)+"1"+ cNumPv,"FP_SERPNDC")
Else
	cSerDoc:= Posicione("SFP",5,xFilial("SFP")+cFilAnt+Subs(cPref,1,3)+"1"+ cNumPv,"FP_SERPNCC")
EndIf
If Empty(cSerDoc)
	cSerDoc:= cPref
EndIf

cSerPesq:= AllTrim(cSerDoc) + cIdPV 

Return({cSerDoc,cSerPesq})

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออัอออออออัออออออออออออออออออออออัออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldRegFX6ณ Autor ณMarivaldo ณ Data              ณ 19/03/2020  บฑฑ
ฑฑฬออออออออออุออออออออออฯอออออออฯออออออออออออออออออออออฯออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida si existe registros en  la tabla FX6                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA935 (ARG)                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function VldRegFX6(cPref,Ccfo,cTipo,lVerifica)
Local cQuery	:= ""	
Local FX6QRY	:= CriaTrab(Nil, .F.)
Local cFilFX6	:= xFilial("FX6")
Local cAliasFX6	:=	'FX6' 
Local ni 		:= 1   
Local nOpc		:=1	

Private  cCadastro := ""
Private  aRotina 	:= {}

Default cPref 		:= ""
Default Ccfo		:= ""	
Default cTipo 		:= ""
Default lVerifica	:= .F.
	
ProcRegua(500) 
dbSelectArea("FX6")
dbSetOrder(1) 
	
	aStru := dbStruct()
	cQuery := "SELECT FX6_FILIAL, FX6_CUIT, FX6_EST, FX6_CATEG,FX6_VIGCAT,FX6_CODCAT,"
	cQuery += "R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName("FX6") + " FX6"
	cQuery += " WHERE FX6_FILIAL	= '" + cFilFX6	+ "'"
 	cQuery += " AND FX6_CUIT = '" + ALLTRIM(SA1->A1_CGC) + "'" 	
 	cQuery += " AND FX6_VIGCAT <= '"+dTos(dDataBase)+"'"
  	cQuery += " AND D_E_L_E_T_ = ' '"
  	
  	cQuery := ChangeQuery(cQuery)
  	   
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), 'FX6QRY', .F., .T.)
	
	For ni := 1 to Len(aStru)
		If aStru[ni,2] != 'C' .AND. aStru[ni,2] != "M"
			TCSetField('FX6QRY', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		Endif
	Next
	dbSelectArea("FX6QRY")
	cAliasFX6	:=	'FX6QRY'                      
	
	While FX6QRY->(!Eof())	

		Aadd(aRecFX6,{FX6QRY->FX6_FILIAL,FX6QRY->FX6_CUIT,FX6QRY->FX6_EST,FX6QRY->FX6_CATEG,FX6QRY->FX6_VIGCAT,FX6QRY->FX6_CODCAT,FX6QRY->(Recno())})	
	
		FX6QRY->(DbSkip())
	Enddo

	If lVerifica
		dbSelectArea("FX6QRY")
		DbCloseArea()
		Return(Len(aRecFX6) < 2)
		
	EndIf

	If Len(aRecFX6) > 0		
		nOpc:= F395TRB1(.T.,aRecFX6,.F.,cPref,Ccfo,cTipo)
	EndIf
	dbSelectArea("FX6QRY")
	DbCloseArea()	
	
Return(nOpc) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF395TABLA บAutor  ณMarivaldo            					  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstruye tabla temporal para la carga en pantalla.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametros       ณ    												   ฑฑ
               lMultiplo:Va en relacion con lMarcados 					   ฑฑ
               aCorrecoes:Registros a cargar en la tabla temporal         บฑฑ
               lMarcados: Indica si los registros seran marcados o no      ฑฑ
                     			visualmente aparecen con un check si se    ฑฑ
                     			indica que si							   ฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function F395TRB1(lMultiplo,aCorrecoes,lMarcados,cPref,Ccfo,cTipo)

Local nTotAjuste	:=	0
Local aStruTRB	:=	{}
Local aCampos 	:=	{}
Local nOpca		:=	2
Local nShowCampos	:=	0
Local nIniLoop	:=	0             
Local nX := 1
Local nY := 1
Local aOrdem	:={}
Local lExterno

Private oTmpTable

DEFAULT aCorrecoes	:=	{}
DEFAULT lMarcados 	:=	.F.
DEFAULT lExterno 	:=	.F.
Default cPref:=""
Default Ccfo:=""
Default cTipo:=""
If !dtMovFin(dDataBASE,,"2") 

	Return  .F.
EndIf

If lMultiplo
	aadd(aStruTrb,{"TRB_MARCA"		,"C",12,0})
Endif
aadd(aStruTrb,{"TRB_ORIGEM"	,"C",4,0})
aadd(aStruTrb,{"FX6_CUIT"	,"C",FWTamSX3("FX6_CUIT")[1],FWTamSX3("FX6_CUIT")[2]})
aadd(aStruTrb,{"FX6_EST"  	,"C",FWTamSX3("FX6_EST")[1],FWTamSX3("FX6_EST")[2]})
aadd(aStruTrb,{"FX6_CATEG" 	,"C",FWTamSX3("FX6_CATEG")[1],FWTamSX3("FX6_CATEG")[2]})
aadd(aStruTrb,{"FX6_CODCAT"	,"C",FWTamSX3("FX6_CODCAT")[1],FWTamSX3("FX6_CODCAT")[2]})
aadd(aStruTrb,{"FX6_VIGCAT"	,"D",FWTamSX3("FX6_VIGCAT")[1],FWTamSX3("FX6_VIGCAT")[2]})

nShowCampos	:=	Len(aStruTRB)

If lMultiplo
	AAdd(aCampos,{' ','TRB_MARCA' ,aStruTRB[1][2],aStruTRB[1][3],aStruTRB[1][4],"@BMP"})
	AAdd(aCampos,{' ','TRB_ORIGEM',aStruTRB[2][2],aStruTRB[2][3],aStruTRB[2][4],"@BMP"})
Else
	AAdd(aCampos,{' ','TRB_ORIGEM',aStruTRB[1][2],aStruTRB[1][3],aStruTRB[1][4],"@BMP"})
Endif

nIniLoop	:=	Len(aCampos)+1

For nX := nIniLoop To nShowCampos	
	
	AAdd(aCampos,{FWX3Titulo(aStruTRB[nX][1]),aStruTRB[nX][1],aStruTRB[nX][2],aStruTRB[nX][3],aStruTRB[nX][4],PesqPict("FX6",aStruTRB[nX][1])})
Next

aOrdem	:=	{"FX6_CUIT","FX6_CODCAT"}
oTmpTable := FWTemporaryTable():New(TRB1)
oTmpTable:SetFields( aStruTrb )
oTmpTable:AddIndex("1", aOrdem)
oTmpTable:Create()

For nY:= 1 To Len(aCorrecoes) 

	Reclock(TRB1,.T.)
	Replace FX6_CUIT    With aCorrecoes[nY][2]
	Replace FX6_EST  	With CVALTOCHAR(aCorrecoes[nY][3])
	Replace FX6_CATEG   With aCorrecoes[nY][4]
	Replace FX6_VIGCAT  With aCorrecoes[nY][5]
	Replace FX6_CODCAT  With CVALTOCHAR(aCorrecoes[nY][6])
		
	If lMultiplo
		TRB_MARCA	:=	IIf(lMarcados,_MARCADO,_DESMARCADO)
	Endif
	MsUnLock()
Next
DbGoTop()
If !lExterno
	nOpca	:=	F395Browse(3,nTotAjuste,aCampos,lMultiplo,cPref,Ccfo,cTipo)
Else
	nOpca	:= 1
EndIf

DbSelectArea(TRB1)
(TRB1)->(DbCloseArea())

If oTmpTable <> Nil
	oTmpTable:Delete()
	oTmpTable := Nil
Endif

If !lExterno .And. bFiltraBrw <> Nil
	Eval(bFiltraBrw)
Endif

Return(nOpca)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณF395Browse   ณ Autor ณMarivaldo              				  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Monta a tela para mostrar os dados                         ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINA935                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function F395Browse(nOpc,nTotAjuste,aCampos,lMultiplo,cPref,Ccfo,cTipo)
Local aObjects := {}
LOCAL aPosObj  :={}
LOCAL aSize		:=MsAdvSize()
LOCAL aInfo    :={aSize[1],aSize[2],aSize[3],aSize[4],0,0}
Local nOpca		:=	2
Local oCol		:= Nil
Local oLbx
Local nX			:=	0
Local nI			:= 0
Local bOk,bCanc
Local nBitMaps	:=	1
Local oTotAjuste
Local aButtons	:=	{}
Local bMarkAll
Local bUnMarkAll
Local bInverte
Local lVisual 	:=	(nOpc == 2)
Local lInclui	:=	(nOpc == 3)
Local lDeleta	:=	(nOpc == 5)
Local oFont
Local lAutomato := .F.
Default cPref :=""
Default Ccfo:=""
Default cTipo:=""
DEFINE FONT oFont NAME "Arial" BOLD


DEFAULT lMultiplo	:=	.F.

If nOpc == 2
	nMoeda := SFR->FR_MOEDA
EndIf

If lMultiplo
	nBitMaps := 2
Endif

If !lDeleta
	bOk	:=	{|| nOpca:=	1,oDlg:End()}
	bCanc	:=	{|| nOpca:=	2,oDlg:End()}
Else
	bCanc	:=	{|| nOpca:=	2,oDlg:End()}
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPasso parametros para calculo da resolucao da tela                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If  cTipo<>"NCC" .and. Len(aRecFX6)>1
	aadd( aObjects, { 100, 000, .T., .T. } )
	aadd( aObjects, { 100, 100, .T., .T. } )
	aPosObj  := MsObjSize( aInfo, aObjects, .T. )
	If !lAutomato   
		DEFINE MSDIALOG oDlg FROM aSize[7], 000 TO aSize[6], aSize[5] TITLE OemToAnsi(Iif(lDeleta,STR0014,IIf(lInclui,STR0015,STR0023))+" "+STR0024) PIXEL //"Borrado de "###"Generacion de"###"Visualizacion de"###" ajuste por diferencia de cambio"
		@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4]-83 LABEL "" OF oDlg  PIXEL


		oLbx := TCBROWSE():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3]-55, , , , , , , , , , ,, , , , , .T., , .T., , .F.,,)
		If lMultiplo
			oLbx:BLDblClick := {||F935Marc(oLbx,@nTotAjuste,@oTotAjuste,1)}		
		Endif
		For nX:=1 To nBitMaps
		//Definir colunaa com o BITMAP
			DEFINE COLUMN oCol DATA FIELDWBlock(aCampos[nX][2],Select(TRB1)) BITMAP HEADER OemToAnsi(aCampos[nX][1]) PICTURE  aCampos[nX][6] ALIGN LEFT SIZE CalcFieldSize(aCampos[nX,3],aCampos[nX,4],aCampos[nX,5],aCampos[nX,2],aCampos[nX,1]) PIXELS
			oLbx:AddColumn(oCol)
		Next
	
		//Definir as demais colunas
		For nX:=(nBitMaps+1) To Len(aCampos)
			DEFINE COLUMN oCol DATA FIELDWBlock(aCampos[nX][2],Select(TRB1)) HEADER OemToAnsi(aCampos[nX][1]) PICTURE  aCampos[nX][6] ALIGN LEFT SIZE CalcFieldSize(aCampos[nX,3],aCampos[nX,4],aCampos[nX,5],aCampos[nX,2],aCampos[nX,1]) PIXELS
			oLbx:AddColumn(oCol)
		Next
		ACTIVATE MSDIALOG oDlg On INIT EnchoiceBar(oDlg,bOk,bCanc,,aButtons)
	Else
	       nOpca := 1
	EndIf
	
	Set key VK_F4  To
    Set key VK_F5  To
    Set key VK_F6  To
	
	If Alltrim(TRB_MARCA) ==  _MARCADO
		cSISA:= FX6_CODCAT  // campos da SEL....
		cTipAgro:=  Fx6_EST	// campos da sel
	EndIf
	
Else
	nOpca := 1
	cSISA:= FX6_CODCAT  // campos da SEL....
	cTipAgro:=  Fx6_EST	// campos da sel

Endif
cSISA:= FX6_CODCAT  // campos da SEL....
cTipAgro:=  Fx6_EST	// campos da sel
nNewAlicuo:=0
lTemFX6:=.F.
If  nOpca == 1 .And. cTipo <> "NCC"
	dbSelectArea("SFF")
	SFF->(dbSetOrder(20))//FF_FILIAL+FF_IMPOSTO+FF_SERIENF+FF_CFO_V+FF_SISA+FF_TIPAGRO
	If SFF->(MsSeek( xFilial("SFF")+SFC->FC_IMPOSTO+SubStr(Trim(cPref),1,1)+"  "+Alltrim(cCfo)+"  "+Alltrim(cSISA)+cTipAgro))  
		nNewAlicuo :=  SFF->FF_ALIQ
		lTemFX6:=.T.
	EndIf
	RecLock("SEL",.F.)
	Replace EL_SISA With cSISA
	Replace EL_TIPAGRO 	 With cTipAgro
	MsUnlock()
ElseIf nOpca == 1 .And. cTipo == "NCC"
	dbSelectArea("SFF")
	SFF->(dbSetOrder(21))//FF_FILIAL+FF_IMPOSTO+FF_SERIENF+FF_CFO_C+FF_SISA+FF_TIPAGRO
	If SFF->(MsSeek( xFilial("SFF")+SFC->FC_IMPOSTO+SubStr(Trim(cPref),1,1)+"  "+Alltrim(cCfo)+"  "+Alltrim(cSISA)+cTipAgro))  
		If dDataBase >= aRecFX6[1][5]
			nNewAlicuo :=  SFF->FF_ALIQ
			lTemFX6:=.T.
		EndIf				
	EndIf
EndIf
aRecFX6:={}
Return nOpca

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณF935Marc   ณ Autor ณMarivaldo              				  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Mark os registros no acols                                 ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINA935                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function F935Marc(oLbx,nTotAjuste,oTotAjuste,nOpc)
Local cChave	:=	(TRB1)->(FX6_CUIT+FX6_CODCAT)
Local nRecno	:=	(TRB1)->(Recno())
Local cMarca	:=	IIf((TRB1)->TRB_MARCA  <> _DESMARCADO,_DESMARCADO,_MARCADO)
Local bWhile

DbSelectArea(TRB1)
//Inverte o atual
If nOpc == 1
	bWhile	:=	{|| .T.}
	DbGoTop()	
	cMarca	:=	_MARCADO
Endif

While !Eof() .And. Eval(bWhile)
	If nOpc == 1 
		If cMarca ==  Alltrim(TRB_MARCA)			
			If cChave ==  FX6_CUIT+FX6_CODCAT
				cMarcaAnt := TRB_MARCA
				RecLock(TRB1,.F.)
				Replace TRB_MARCA  With IIf((TRB1)->TRB_MARCA  <> _DESMARCADO,_DESMARCADO,_MARCADO) //cMarca
				MsUnlock()
			Else
				MsgStop(STR0062)
				RecLock(TRB1,.F.)
				Replace TRB_MARCA  With _DESMARCADO 
				MsUnlock()
				(TRB1)->(DBGOTO(nRecno))
				RecLock(TRB1,.F.)
				Replace TRB_MARCA  With _MARCADO 
				MsUnlock()
				Exit
			EndIf			
		Else
			cMarca	:=	IIf((TRB1)->TRB_MARCA  <> _DESMARCADO,_DESMARCADO,_MARCADO)
			If cChave ==  FX6_CUIT+FX6_CODCAT
				cMarcaAnt := TRB_MARCA
				RecLock(TRB1,.F.)
				Replace TRB_MARCA  With IIf((TRB1)->TRB_MARCA  <> _DESMARCADO,_DESMARCADO,_MARCADO) 			
				MsUnlock()
			EndIf
		EndIF
	Endif	
	DbSkip()
Enddo
DbGoTo(nRecno)
oLbx:Refresh()

Return 


Static Function FIN935GIt(cDoc, cSerie, cCliente, cLoja, cRg1415, lIVA, lIVP, lValid, cProvent )
Local aItems	:= {}
Local nPosIt	:= 0
Local aAreaD2	:= SD2->(GetArea())
Local aAreaF2	:= SF2->(GetArea())
Local aAreaF4	:= SF4->(GetArea())
Local cTesPsDt	:= ""
Local cCFPsDt	:= ""
Local aFIva		:= FilImpto({"3"},{"I"},{},{})
Local aLivIv	:= {}
Local cCpBas	:= ""
Local cCpVlr	:= ""
Local nBasIVA	:= 0
Local nVlrIVA 	:= 0
Local nLi 		:= 1

	DbSelectArea("SF2")
	SF2->( dbSetOrder(2) ) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
	
	DbSelectArea("SF4")
	SF4->( dbSetOrder(1) ) //F4_FILIAL+F4_CODIGO
	
	If SF2->(MsSeek(xFilial("SF2")+cCliente+cLoja+cDoc+cSerie))
		
		//Se verifica calculo de IVA
		For nlI:=1 To Len(aFIva)
			If  Ascan(aLivIv,aFIva[nlI][3]) == 0   
				aAdd(aLivIv,aFIva[nlI][3]) 
				cCpBas	:= "F2_BASIMP"+aFIva[nlI][3]
				cCpVlr	:= "F2_VALIMP"+aFIva[nlI][3]
				nBasIVA	:= nBasIVA + SF2->(&(cCpBas))
				nVlrIVA	:= nVlrIVA + SF2->(&(cCpVlr))
			EndIf	
		Next
		
		//Se verifica si ya se realiz๓ calculo de IVA
		If nBasIVA > 0 .and. !(nVlrIVA > 0)
			lIVA := .T.
		EndIf
		
		//Se verifica si ya se realiz๓ calculo de IVP
		If nBasIVA > 0 .and. !(SF2->&(cIVPBas) > 0 .and. SF2->&(cIVPVal) > 0)
			lIVP := .T.
		EndIf
		
		//Si ya fue calculado IVA e IVP no se generarแ mแs
		If !lIVA .and. !lIVP
			lValid	:= .F.
		EndIf
		
		//Si no se ha generado alguno de los 2 impuestos se considera para posdatado y se realiza la agrupaci๓n de items por TES
		If lValid
			If Empty(cProvent)
				cProvent := SF2->F2_PROVENT
			EndIf
			DbSelectArea("SD2")
			SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			If SD2->(MsSeek(xFilial("SD2")+cDoc+cSerie+cCliente+cLoja))
				While !SD2->(EOF()) .And.  xFilial("SD2")+cDoc+cSerie+cCliente+cLoja ==;
					SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)
					cTesPsDt	:= ""
					cCFPsDt		:= ""
					//nPosIt := aScan(aItems,{|x| x[1] == SD2->D2_COD .And. x[4] == SD2->D2_TES })
					nPosIt := aScan(aItems,{|x| x[4] == SD2->D2_TES })
					If nPosIt > 0
						aItems[nPosIt][3] += SD2->D2_TOTAL
					Else
						cTesPsDt := POSICIONE("SF4",1, xFilial("SF4")+SD2->D2_TES,"F4_TESCANJ")
						If !Empty(cTesPsDt)
							cCFPsDt := POSICIONE("SF4",1, xFilial("SF4")+cTesPsDt,"F4_CF")
						EndIf
						aAdd(aItems,{SD2->D2_COD, SD2->D2_UM, SD2->D2_TOTAL, SD2->D2_TES, SD2->D2_CF,cTesPsDt, cCFPsDt, SD2->D2_LOCAL, SD2->D2_DOC, D2_SERIE})
						//aAdd(aItems,{SD2->D2_COD, SD2->D2_UM, SD2->D2_TOTAL, SD2->D2_TES, SD2->D2_CF, SD2->D2_LOCAL, SD2->D2_DOC})
					EndIf
					SD2->(DbSkip())
				Enddo
			EndIf
		EndIf
		cRg1415	:= SF2->F2_RG1415
	EndIf
	
	SF2->(RestArea(aAreaF2))
	SD2->(RestArea(aAreaD2))
	SF4->(RestArea(aAreaF4))

Return aItems

/*
Funci๓n cRG1415, regresa el c๓digo RG1415
cTipo: Tipo de documento a generar
cSerie: Serie del documento a generar
lMyPime: Indica si la factura es MiPyme

*/
Static Function cRG1415(cTipo, cSerie, lMiPyme)
Local cCodigo	:= ""

	If cTipo == "NDC"
		If cSerie == "A"
			cCodigo := Iif(lMiPyme, "202", "002")
		ElseIf cSerie == "B"
			cCodigo := Iif(lMiPyme, "207", "007")
		ElseIf cSerie == "C"
			cCodigo := Iif(lMiPyme, "212", "012")
		EndIf
	ElseIf cTipo == "NCC"	
		If cSerie == "A"
			cCodigo := Iif(lMiPyme, "203", "003")
		ElseIf cSerie == "B"
			cCodigo := Iif(lMiPyme, "208", "008")
		ElseIf cSerie == "C"
			cCodigo := Iif(lMiPyme, "213", "013")
		EndIf
	EndIf

Return cCodigo