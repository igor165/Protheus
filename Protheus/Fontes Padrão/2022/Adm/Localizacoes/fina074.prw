#INCLUDE "fina074.ch"
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ ÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA074   บAutor  ณBruno Sobieski      บFecha ณ  10-14-04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para geracao de diferencias de cambio no contas a    บฑฑ
ฑฑบ          ณpagar.                                                      บฑฑ                 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณData    ณ BOPS     ณ Motivo da Alteracao                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณJonathan Glzณ30/06/15ณPCREQ-4256ณSe elimina la funcion AjustaSX1() la  ณฑฑ
ฑฑณ            ณ        ณ          ณcual realiza modificacion a SX1 por   ณฑฑ
ฑฑณ            ณ        ณ          ณmotivo de adecuacion a fuentes a nuevaณฑฑ
ฑฑณ            ณ        ณ          ณestructura de SX para Version 12.     ณฑฑ
ฑฑณJonathan Glzณ09/10/15ณPCREQ-4261ณMerge v12.1.8                         ณฑฑ
ฑฑณJonathan Glzณ06/06/16ณTVFHOB    ณSe agrega filtro en funcion Fa074GDif ณฑฑ
ฑฑณ            ณ        ณ          ณpara no procesar documentos con TRM   ณฑฑ
ฑฑณ            ณ        ณ          ณpactada. Cambios para Colombia        ณฑฑ
ฑฑณJonathan Glzณ05/12/16ณSERINN001-ณSe cambia modo de crear tablas tempo- ณฑฑ
ฑฑณ            ณ        ณ       114ณrales por motivo de limpiza de CTREE  ณฑฑ
ฑฑณM.Camargo   ณ22/02/17ณMMI-144   ณSe coloca valor absoluto al generar   ณฑฑ 
ฑฑณ            ณ        ณ          ณ una NCC.R้plica llamado TVDDSC       ณฑฑ
ฑฑณLuisEnriquezณ07/06/17ณTSSERMI01 ณ-Merge 12.1.16 En m้todo AddIndex de  ณฑฑ
ฑฑณ            ณ        ณ-96       ณclase FWTemporaryTable se modifica a  ณฑฑ
ฑฑณ            ณ        ณ          ณ2 caracteres nombre de indice. (CTREE)ณฑฑ
ฑฑณJos้ Glex   ณ29/10/20ณDMINA     ณSe agrega Validaci๓n para la variable ณฑฑ
ฑฑณ            ณ        ณ   -10011 ณnGerDocFis con tratamiento para todos ณฑฑ
ฑฑณ            ณ        ณ          ณlos paises, se incluye el campo VLCRUZณฑฑ
ฑฑณ            ณ        ณ          ณpara el execauto FINA040 y se realizanณฑฑ
ฑฑณ            ณ        ณ          ณcambios de buenas practicas (MEX)     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Fina074()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Variaveis 											 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cFiltro	:=	""
Local bFiltro
Local nA		:= 0
Local nOpcion := 0 // Utilizada en scripts automแticos (4 Generaci๓n por lote)
Local lAutomato := IsBlind() // Tratamiento para scripts automแticos
Private aIndices		:=	{} //Array necessario para a funcao FilBrowse
Private bFiltraBrw := {|| .T. }
Private aRecSE1		:={}
Private cMoedaTx,nC	:=	MoedFin()
//Declaracao de variaveis Multimoeda
Private aTxMoedas	:=	{}    
Private lCmpMda	:=	cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|RUS|"
Private aExecLog	:=	{}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Restringe o uso do programa ao Financeiro e Sigaloja			  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (!(AmIIn(6,12,17,72)) .and. !lAutomato)			// Sข Fin e Loja e EIC e SIGAPHOTO
	Return
Endif

Private aRotina := MenuDef()

If cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|RUS|"
	Aadd(aRotina,{ OemToAnsi(STR0025),"FA074SETMOE()",0,1})		// Modificar tasas }
	Aadd(aTxMoedas,{"",1,PesqPict("SM2","M2_MOEDA1")})
	For nA	:=	2	To nC
		cMoedaTx	:=	Str(nA,IIf(nA <= 9,1,2))
		If !Empty(GetMv("MV_MOEDA"+cMoedaTx))
			Aadd(aTxMoedas,{GetMv("MV_MOEDA"+cMoedaTx),RecMoeda(dDataBase,nA),PesqPict("SM2","M2_MOEDA"+cMoedaTx) })
		Else
			Exit
		Endif
	Next
EndIf	

Pergunte("FIN74A",.F.)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ VerIfica o numero do Lote 											  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE cLote
LoteCont( "FIN" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define o cabecalho da tela de baixas								  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PRIVATE cCadastro := OemToAnsi(STR0007) //"Diferencia de cambio cuentas a cobrar"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ponto de entrada para pre-validar os dados a serem  ณ
//ณ exibidos.                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF ExistBlock("F074BROW")
	cFiltro	:=	ExecBlock("F074BROW",.F.,.F.,cFiltro)
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ So devem ser exibidos os titulos em moeda diferente ณ
//ณ da corrente.                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู    
If !Empty(cFiltro)
	cFiltro	:=	"E1_FILIAL='"+xFilial('SE1')+"' "+Iif(Empty(cFiltro),"",".And.("+ cFiltro + ")")
	bFiltro	:=	{|| FilBrowse("SE1",@aIndices,cFiltro )}
If mv_par09 == 1
		bFiltraBrw	:= bFiltro
		Eval( bFiltraBrw )
	Endif
Endif
//SetKey (VK_F12,{|a,b| AcessaPerg("FIN74A",.T.),F074SetFBrw(bFiltro)})
SetKey (VK_F12,{|a,b| AcessaPerg("FIN74A",.T.)})
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Enderea a Funo de BROWSE											  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF !lAutomato
   mBrowse( 6, 1,22,75,"SE1",,,,,, Fa074Legenda("SE1"))
Else
       If FindFunction("GetParAuto")
			aRetAuto 		:= GetParAuto("FINA074TESTCASE")
			nOpcion 		:= aRetAuto[1]			
	   EndIF
	   Do Case
			Case nOpcion == 4
				Fa074GDifM()
	   EndCase
    Endif
dbSelectArea("SE1")
If !Empty(cFiltro)
If mv_par09 == 1
		EndFilBrw("SE1",@aIndices)
	Endif
Endif
dbSetOrder(1)

Set key VK_F12  To
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa074Vis  บAutor  ณBruno Sobieski      บFecha ณ  10-14-04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza o detalhe de uma diferencia de cambio             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa074Vis()
Local nRecSE1		:=	SE1->(Recno())
Local aCampos	:=	{}
Local nTotAjuste	:=	0
Private oTmpTRB

If SE1->E1_CONVERT <> "N"
	Help('',1,'FA074008')
	Return
Endif

Fa074GerTRB(@aCampos,@nTotAjuste)

DbSelectArea('TRB')
TRB->(DbGoTop())

SE1->(MsGoTo(nRecSE1))
Fa074Tela(2,nTotAjuste,aCampos,.F.)
SE1->(DbGoTo(nRecSE1))

DbSelectArea('TRB')
TRB->(DbCloseArea())


If oTmpTRB <> Nil
	oTmpTRB:Delete()
	oTmpTRB := Nil
Endif

If bFiltraBrw <> Nil
	Eval(bFiltraBrw)
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa074GDif บAutor  ณBruno Sobieski      บFecha ณ  10-14-04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera a diferencia de cambio para um titulo.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa074GDif(lMultiplo,aCorrecoes,lMarcados,lExterno,nMoedaCor,nTxaAtual,nMdaTit)    
Local nTaxaAtu	:=	0
Local nTotAjuste	:=	0
Local aStruTRB	:=	{}
Local aCampos 	:=	{}
Local nOpca		:=	2
Local nShowCampos	:=	0
Local nIniLoop	:=	0             
Local nX := 1
Local nY := 1
Local aOrdem	:={}

Private lCmpMda:= cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|RUS|"
Private oTmpTable

DEFAULT aCorrecoes	:=	{}
DEFAULT lMarcados 	:=	.F.
DEFAULT lExterno 	:=	.F.

If !(cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG")
	mv_par10:= 1
EndIf

//Verifica si tienen TRM Pactada
If cPaisLoc == "COL" 
	If SE1->E1_TRMPAC == "1"
		MSGINFO( STR0058 ,STR0059 )// "No se puede ejecutar esta opcion, porque el documento tiene TRM pactada" ##INFO
		Return
	Endif
Endif

//Verifica se a moeda selecionada para a geracao do titulo existe.
If Empty(GetMv("MV_MOEDA"+ALLTRIM(STR(MV_PAR10))))
	Help("",1,"NMOEDADIF")
	Return
Endif

// Verifica se pode ser incluido mov. com essa data
If !dtMovFin(dDataBASE,,"2") 
	Return  .F.
EndIf

If !lMultiplo
	aRecSE1	:=	{}
	If SE1->E1_CONVERT == "N"
		Help('',1,'FA074005')
		Return
	Endif
	If SE1->E1_MOEDA  == mv_par10 
	  If !lExterno
			Help('',1,'FA074011')
			Return
		EndIf
		//Return
	Endif
	IF SE1->E1_EMISSAO > dDataBase
		Help('',1,'FA074009')
		Return
	Endif

	If !lCmpMda .Or. mv_par10 == 1
		nTaxaAtu	:= If(mv_par01==0,RecMoeda(dDataBase,SE1->E1_MOEDA),mv_par01)
	Else
		nTaxaAtu	:= If(mv_par01==0,RecMoeda(dDataBase,mv_par10),mv_par01)
    EndIf
	AADD(aCorrecoes,Fa074CDif(@nTaxaAtu,lExterno))
	AAdD(aRecSE1,SE1->(RECNO()))
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerificar se ja foi ajustado ate esta dataณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*If SE1->E1_DTDIFCA >= dDataBase 
	Help('',1,'FA074001')
 	Return
Endif
  */
//Monta estrutura do trb
If lMultiplo
	aadd(aStruTrb,{"TRB_MARCA"		,"C",12,0})
Endif
aadd(aStruTrb,{"TRB_ORIGEM"	,"C",10,0})
aadd(aStruTrb,{"E1_CLIENTE"	,"C",GetSx3Cache("E1_CLIENTE","X3_TAMANHO"),GetSx3Cache("E1_CLIENTE","X3_DECIMAL")})
aadd(aStruTrb,{"E1_LOJA"  	,"C",GetSx3Cache("E1_LOJA"   ,"X3_TAMANHO"),GetSx3Cache("E1_LOJA"   ,"X3_DECIMAL")})
aadd(aStruTrb,{"E1_PREFIXO"	,"C",GetSx3Cache("E1_PREFIXO","X3_TAMANHO"),GetSx3Cache("E1_PREFIXO","X3_DECIMAL")})
aadd(aStruTrb,{"E1_NUM"		,"C",GetSx3Cache("E1_NUM"    ,"X3_TAMANHO"),GetSx3Cache("E1_NUM"    ,"X3_DECIMAL")})
aadd(aStruTrb,{"E1_PARCELA"	,"C",GetSx3Cache("E1_PARCELA","X3_TAMANHO"),GetSx3Cache("E1_PARCELA","X3_DECIMAL")})
aadd(aStruTrb,{"E1_TIPO"	,"C",GetSx3Cache("E1_TIPO"   ,"X3_TAMANHO"),GetSx3Cache("E1_TIPO"   ,"X3_DECIMAL")})
aadd(aStruTrb,{"E1_RECIBO"	,"C",GetSx3Cache("E1_RECIBO" ,"X3_TAMANHO"),GetSx3Cache("E1_RECIBO" ,"X3_DECIMAL")})
aadd(aStruTrb,{"E1_EMISSAO"	,"D",GetSx3Cache("E1_EMISSAO","X3_TAMANHO"),GetSx3Cache("E1_EMISSAO","X3_DECIMAL")})
//aadd(aStruTrb,{"E1_VALOR"	,"N",TamSx3("E1_VALOR"  )[1],TamSx3("E1_VALOR"  )[2]})
aadd(aStruTrb,{"TRB_VALDIF"	,"N",GetSx3Cache("E1_VLCRUZ" ,"X3_TAMANHO"),GetSx3Cache("E1_VLCRUZ" ,"X3_DECIMAL")})

nShowCampos	:=	Len(aStruTRB)

aadd(aStruTrb,{"TRB_VALOR1" 	,"N",GetSx3Cache("E1_VALOR"  ,"X3_TAMANHO") ,GetSx3Cache("E1_VALOR"  ,"X3_DECIMAL")})
aadd(aStruTrb,{"TRB_VALCOR"		,"N",GetSx3Cache("E1_VLCRUZ" ,"X3_TAMANHO") ,GetSx3Cache("E1_VLCRUZ" ,"X3_DECIMAL")})
aadd(aStruTrb,{"TRB_TIPODI"		,"C",1                      	 ,0                      })
aadd(aStruTrb,{"TRB_TXATU"	  	,"N",GetSx3Cache("FR_TXATU"  ,"X3_TAMANHO")	,GetSx3Cache("FR_TXATU"	 ,"X3_DECIMAL")})
aadd(aStruTrb,{"TRB_TXORI"	  	,"N",GetSx3Cache("FR_TXATU"  ,"X3_TAMANHO")	,GetSx3Cache("FR_TXATU"  ,"X3_DECIMAL")})
aadd(aStruTrb,{"TRB_DTAJUS"		,"D",GetSx3Cache("E1_EMISSAO","X3_TAMANHO") ,GetSx3Cache("E1_EMISSAO","X3_DECIMAL")})
aadd(aStruTrb,{"E5_SEQ"	   		,"C",GetSx3Cache("E5_SEQ" 	 ,"X3_TAMANHO")	,GetSx3Cache("E5_SEQ"    ,"X3_DECIMAL")})

SX3->(DbSetOrder(2))
If lMultiplo
	AAdd(aCampos,{' ','TRB_MARCA' ,aStruTRB[1][2],aStruTRB[1][3],aStruTRB[1][4],"@BMP"})
	AAdd(aCampos,{' ','TRB_ORIGEM',aStruTRB[2][2],aStruTRB[2][3],aStruTRB[2][4],"@BMP"})
Else
	AAdd(aCampos,{' ','TRB_ORIGEM',aStruTRB[1][2],aStruTRB[1][3],aStruTRB[1][4],"@BMP"})
Endif

nIniLoop	:=	Len(aCampos)+1

For nX := nIniLoop To nShowCampos
	If !(aStruTRB[nX][1] $ "TRB_VALDIF")
		SX3->(DbSeek(aStruTRB[nX][1]))
		AAdd(aCampos,{X3TITULO(aStruTRB[nX][1]),aStruTRB[nX][1],aStruTRB[nX][2],aStruTRB[nX][3],aStruTRB[nX][4],PesqPict("SE1",aStruTRB[nX][1])})
	Else
		AAdd(aCampos,{STR0008,aStruTRB[nX][1],aStruTRB[nX][2],aStruTRB[nX][3],aStruTRB[nX][4],PesqPict("SE1","E1_VLCRUZ")}) //"Diferencia"
	Endif
Next

aOrdem	:=	{"E1_CLIENTE","E1_LOJA","E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO"}
oTmpTable := FWTemporaryTable():New("TRB")
oTmpTable:SetFields( aStruTrb )
oTmpTable:AddIndex("I1", aOrdem)
oTmpTable:Create()

For nY:= 1 To Len(aCorrecoes)
	For nX := 1 To Len(aCorrecoes[nY][_BAIXAS])
		If aCorrecoes[nY][_BAIXAS][nX][2] <> 0
			SE5->(MsGoTo(aCorrecoes[nY][_BAIXAS][nX][1]))
			Reclock('TRB',.T.)
			Replace E1_CLIENTE With SE5->E5_CLIFOR
			Replace E1_LOJA 	 With SE5->E5_LOJA
			Replace E1_PREFIXO With SE5->E5_PREFIXO
			Replace E1_NUM     With SE5->E5_NUMERO
			Replace E1_PARCELA With SE5->E5_PARCELA
			Replace E1_TIPO    With SE5->E5_TIPO
			Replace E1_EMISSAO With SE5->E5_DATA
			Replace E1_RECIBO	 With SE5->E5_ORDREC
			Replace TRB_ORIGEM With _AMARELO
			Replace TRB_VALDIF With aCorrecoes[nY][_BAIXAS][nX][2]
			//		Replace E1_VALOR   With aCorrecoes[nY][_BAIXAS][nX][3]
			Replace TRB_VALOR1 With aCorrecoes[nY][_BAIXAS][nX][3]*aCorrecoes[nY][_BAIXAS][nX][5]
			Replace TRB_VALCOR With aCorrecoes[nY][_BAIXAS][nX][3]*aCorrecoes[nY][_BAIXAS][nX][4]
			Replace TRB_TXATU  With aCorrecoes[nY][_BAIXAS][nX][4]
			Replace TRB_TXORI  With aCorrecoes[nY][_BAIXAS][nX][5]
			Replace TRB_DTAJUS With dDataBase
			Replace TRB_TIPODI With "B"
			Replace E5_SEQ With SE5->E5_SEQ
			If lMultiplo
				TRB_MARCA	:=	IIf(lMarcados,_MARCADO,_DESMARCADO)
			Endif
			MsUnLOck()
			If !lMultiplo .Or. (lMultiplo .And. lMarcados)
				If TRB->E1_TIPO$ MVRECANT+"/"+MV_CRNEG
					nTotAjuste	-=	TRB_VALDIF 
				Else
					nTotAjuste	+=	TRB_VALDIF 
				EndIf
			EndIf
		Endif
	Next
	
	If aCorrecoes[nY][_SALDO][1] <> 0
		SE1->(MsGoTo(aCorrecoes[nY][_RECSE1]))
		Reclock('TRB',.T.)
		Replace E1_CLIENTE With SE1->E1_CLIENTE
		Replace E1_LOJA 	 With SE1->E1_LOJA
		Replace E1_PREFIXO With SE1->E1_PREFIXO
		Replace E1_NUM     With SE1->E1_NUM
		Replace E1_PARCELA With SE1->E1_PARCELA
		Replace E1_TIPO    With SE1->E1_TIPO
		Replace E1_EMISSAO With SE1->E1_EMISSAO
		Replace TRB_ORIGEM With _AZUL
		Replace TRB_VALDIF With aCorrecoes[nY][_SALDO][1]
		//		Replace E1_VALOR   With aCorrecoes[nY][_SALDO][2]
		Replace TRB_VALOR1 With aCorrecoes[nY][_SALDO][2]*aCorrecoes[nY][_SALDO][4]
		Replace TRB_VALCOR With aCorrecoes[nY][_SALDO][2]*aCorrecoes[nY][_SALDO][3]
		Replace TRB_TXATU  With aCorrecoes[nY][_SALDO][3]
		Replace TRB_TXORI  With aCorrecoes[nY][_SALDO][4]
		Replace TRB_DTAJUS With dDataBase
		Replace TRB_TIPODI With "S"
		If lMultiplo
			TRB_MARCA	:=	IIf(lMarcados,_MARCADO,_DESMARCADO)
		Endif
		MsUnLock()
		If !lMultiplo .Or. (lMultiplo .And. lMarcados)             
			If TRB->E1_TIPO$ MVRECANT+"/"+MV_CRNEG
				nTotAjuste	-=	TRB_VALDIF 
			Else
				nTotAjuste	+=	TRB_VALDIF
			EndIf
		EndIf	
	Endif
Next
DbGoTop()
If !lExterno
	nOpca	:=	Fa074Tela(3,nTotAjuste,aCampos,lMultiplo)
Else
	nOpca	:= 1
EndIf
If nOpca == 1
	Begin Transaction
	Processa({|| F074Grava(aRecSE1,lMultiplo,lExterno)},STR0009) //"Grabando documentos"
	End Transaction
Endif

DbSelectArea('TRB')
TRB->(DbCloseArea())

If oTmpTable <> Nil
	oTmpTable:Delete()
	oTmpTable := Nil
Endif

Pergunte("FIN74A",.F.)
SetKey (VK_F12,{|a,b| AcessaPerg("FIN74A",.T.)})
If !lExterno .And. bFiltraBrw <> Nil
	Eval(bFiltraBrw)
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa074GDifMบAutor  ณBruno Sobieski      บFecha ณ  10-14-04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera a diferencia de cambio para varios titulos             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Fa074GDifM()
Local nTaxaAtu	:=	0

Local aCorrecoes	:=	{}
Local aMV_PAR		:= Array(9)
aRecSE1	:=	{}
// Verifica se pode ser incluido mov. com essa data
If !dtMovFin(dDataBASE,,"2") 
	Return  .F.
EndIf

If Pergunte("FIN74B",.T.)
	aMV_PAR[01]	:=	MV_PAR01
	aMV_PAR[02]	:=	MV_PAR02
	aMV_PAR[03]	:=	MV_PAR03
	aMV_PAR[04]	:=	MV_PAR04
	aMV_PAR[05]	:=	MV_PAR05
	aMV_PAR[06]	:=	MV_PAR06
	aMV_PAR[07]	:=	MV_PAR07
	aMV_PAR[08]	:=	MV_PAR08
	aMV_PAR[09]	:=	MV_PAR09
Else
	Pergunte("FIN74A",.F.)
	Return
Endif
Pergunte("FIN74A",.F.)

//Verifica se a moeda selecionada para a geracao do titulo existe.
If Empty(GetMv("MV_MOEDA"+ALLTRIM(STR(MV_PAR10))))
	Help("",1,"NMOEDADIF")
	Return
Endif

Processa({|| F074DifMulti(@aRecSE1,@aCorrecoes,aMV_PAR)}, STR0027) //'Calculando diferencias de cambio'

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica a existencia de registros                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aRecSE1) > 0
	Fa074GDif(.T.,aCorrecoes,aMV_PAR[09]==1)
Else
	If Len(aExecLog) == 0
		Help(" ",1,"RECNO")
	EndIf
EndIf

DbSelectArea('SE1')
If bFiltraBrw <> Nil
	Eval(bFiltraBrw)
Endif    

FA074EXLOG(aExecLog)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa074DifMuบAutor  ณBruno Sobieski      บFecha ณ  10-14-04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula as correcoes para varios titulos.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F074DifMulti(aRecSE1,aCorrecoes,aMV_PAR)
Local nTaxaAtu	:=	0
Local nCounter	:=	0
Local cAliasSE1:=	'SE1'                      

#IFDEF TOP
	Local lFa074Qry	:=	ExistBlock("FA074QRY")
	Local cQuery		:=	''
	Local aStru			:=	{}
	LOCAL	cQueryADD	:=	''
	Local ni := 1 
#ENDIF              

aExecLog := {}

ProcRegua(500)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Criaฦo da estrutura de TRB com base em SE1.                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SE1")
dbSetOrder(2)
#IFDEF TOP
If TcSrvType() != "AS/400"
	aStru := dbStruct()
	cQuery := "SELECT SE1.*,"
	cQuery += "R_E_C_N_O_ RECNO "
	cQuery += "  FROM "+	RetSqlName("SE1") + " SE1 "
	cQuery += " WHERE E1_FILIAL ='" +xFilial('SE1')+ "'"
	cQuery += "   AND E1_CLIENTE Between '" + aMv_par[01] + "' AND '" + aMv_par[02] + "'"
	cQuery += "   AND E1_LOJA    Between '" + aMv_par[03] + "' AND '" + aMv_par[04] + "'"
	cQuery += "   AND E1_PREFIXO Between '" + aMv_par[05] + "' AND '" + aMv_par[06] + "'"
	cQuery += "   AND E1_NUM between '"     + aMv_par[07] + "' AND '" + aMv_par[08] + "'"
	cQuery += "   AND E1_MOEDA <> " + Alltrim(Str(mv_par10)) + "" 
	cQuery += "   AND E1_CONVERT <> 'N'"
	cQuery += "   AND E1_EMISSAO <= '"+Dtos(dDataBase)+"'"
	cQuery += "   AND E1_EMIS1   <= '"+Dtos(dDataBase)+"'"
  //	cQuery += "   AND E1_DTDIFCA <'"+Dtos(dDataBase)+"'"
	cQuery += "   AND D_E_L_E_T_ <> '*' "
	
	// Permite a inclusใo de uma condicao adicional para a Query
	// Esta condicao obrigatoriamente devera ser tratada em um AND ()
	// para nao alterar as regras basicas da mesma.
	IF lFa074Qry
		cQueryADD := ExecBlock("FA074QRY",.F.,.F.)
		IF ValType(cQueryADD) == "C".And.Len(cQueryADD) >0
			cQuery += " AND (" + cQueryADD + ")"
		ENDIF
	ENDIF
	
	cQuery += " ORDER BY "+ SqlOrder(SE1->(IndexKey()))
	
	cQuery := ChangeQuery(cQuery)
	
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1QRY', .F., .T.)
	
	For ni := 1 to Len(aStru)
		If aStru[ni,2] != 'C' .AND. aStru[ni,2] != "M"
			TCSetField('SE1QRY', aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
		Endif
	Next
	dbSelectArea("SE1QRY")
	cAliasSE1	:=	'SE1QRY'                      
	
Else
#Endif

DbSeek(xFilial('SE1')+aMV_PAR[01]+aMV_PAR[03]+aMV_PAR[05]+aMV_PAR[07],.T.)

#IFDEF TOP

Endif
#ENDIF
While SE1QRY->(!Eof()) .And. SE1QRY->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)<=;
	xFilial('SE1')+aMv_par[02]+aMv_par[04]+aMv_par[06]+aMv_par[08]	
	#IFDEF TOP
	If TcSrvType() == "AS/400"
	#ENDIF
		If	SE1QRY->E1_MOEDA <> mv_par10
			DbSkip()
			Loop
		Endif
	#IFDEF TOP
	EndIf
	SE1->(MsGoTo(SE1QRY->RECNO))
	If Fa074TemDC(.T.)	
		SE1QRY->(DbSkip())
		Loop
	EndIf

	If TcSrvType() != "AS/400"
		SE1->(MsGoTo(SE1QRY->RECNO))
	Endif
	#ENDIF
	nTaxaAtu	:= If(mv_par01==0,RecMoeda(dDataBase,(cAliasSE1)->E1_MOEDA),mv_par01)
	IncProc(STR0028+' '+(cAliasSE1)->E1_PREFIXO+"/"+(cAliasSE1)->E1_NUM) //Calculando dif. de cambio del titulo
	nCounter++
	If nCounter == 500
		nCounter	:=	0
		ProcRegua(500)
	Endif
	Aadd(aRecSE1,SE1->(Recno()))
	AADD(aCorrecoes,Fa074CDif(@nTaxaAtu))
	DbSelectArea('SE1')
	DbSetOrder(2)
	MsGoto(aRecSE1[Len(aRecSE1)])
	DbSelectArea(cAliasSE1)
	DbSkip()
Enddo
#IFDEF TOP
	If TcSrvType() != "AS/400"
		DbSelectArea(cAliasSE1)
		DbCloseArea()
		DbSelectArea('SE1')
	Endif
#ENDIF

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa074Canc บAutor  ณBruno Sobieski      บFecha ณ  10-14-04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณApaga uma nota de diferencia de cambio.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa074Canc(lAut)
Local nTotAjuste	:=	0
Local aCampos 		:=	{}
Local nX				:=	0
Local nRecSE1		:=	SE1->(Recno())
Local nIndex		:=	SE1->(IndexOrd())
Local dData
Local cChavePesq := ""
Private oTmpTRB
Default lAut := .F.

If SE1->E1_CONVERT <> "N"
	Help('',1,'FA074008')
	Return
Endif
// Verifica se pode ser incluido mov. com essa data
If !dtMovFin(dDataBASE,,"2") 
	Return  .F.
EndIf
IF SE1->E1_EMISSAO > dDataBase
	Help('',1,'FA074009')
	Return
Endif

DbSelectArea('SFR')
DbSetOrder(2)

cChavePesq:=PADR(SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO,len(SFR->FR_CHAVDE))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerificar se tem algum ajuste             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !DbSeek(xFilial()+"1"+cChavePesq)
	Help('',1,'FA074006')
	Return
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerificar se algum dos titulos ajustados, tem ณ
	//ณalgum ajuste posterior.                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Else
	dData		:=	SE1->E1_EMISSAO
	cChave	:=	PADR(SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO, len(FR_CHAVDE))
	DbSelectArea('SFR')
	DbSetOrder(1)
	While !EOF() .And. FR_CARTEI=="1" .AND. FR_CHAVDE ==	cChave
      If SFR->FR_DATADI > SE1->E1_EMISSAO
			Help('',1,'FA074007')
			Return
		Endif
		DbSkip()
	Enddo
Endif

Fa074GerTRB(@aCampos,@nTotAjuste)
DbSelectArea('TRB')
TRB->(DbGoTop())

SE1->(MsGoTo(nRecSE1))
If !lAut
nOpca	:=	Fa074Tela(5,nTotAjuste,aCampos,.F.)
Else
nOpca := 1
Endif
SE1->(DbGoTo(nRecSE1))
If nOpca == 1
	Begin Transaction
	Processa({|| FA074Dele(nRecSE1)},STR0010) //"Borrando documentos"
	End Transaction
Endif

DbSelectArea('TRB')
TRB->(DbCloseArea())


If oTmpTRB <> Nil
	oTmpTRB:Delete()
	oTmpTRB := Nil
Endif

Pergunte("FIN74A",.F.)
SetKey (VK_F12,{|a,b| AcessaPerg("FIN74A",.T.)})
DbSelectArea('SE1')
DbSetOrder(nIndex)
/*
If bFilBrw <> Nil
	Eval(bFilBrw)
Endif
*/
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa074CDif บAutor  ณBruno Sobieski      บFecha ณ  10-14-04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCalcula a diferencia de cambio para um titulo.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fa074CDif(nTaxaAtu,lExterno)
Local nValor	:=	0
Local nTotComp	:=	0
Local dUltDif	:=	Ctod('')
Local nX			:=	0
Local aBaixas	:=	{}
Local nTxOrig	:=	0
//Local	aSaldoInv:={0,0,0,0,0,Nil}
Local	aSaldo   :={0,0,0,0}
Local nI := 1                
Local nTxBaixa:=0
Local lAchouSFR := .F.
Local lAchouDt:=.f.  
Local nTxAt:=0     
Local lRet := .T.
Private aBaixaSE5	:=	{}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPega a taxa da ultima correcao, e os titulos do SIGAEIC para os que mudou ณ
//ณo VLCRUZ, para recorregir estes valores e a data do ultimo ajuste.        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

F074GetTx(@nTxOrig,@dUltDif,@lAchouSFR,@lAchouDt,@nTxAt)

If mv_par08==1
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalcular as correcoes das Baixasณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Sel070Baixa( "VL /BA /CP /",SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,SE1->E1_TIPO,@nTotComp,Nil,SE1->E1_CLIENTE,SE1->E1_LOJA)
	For nX:= 1 To Len(aBaixaSE5)
		dBaixa		:= aBaixaSE5[nX,07]
		cSequencia 	:= aBaixaSE5[nX,09]
		cChave      := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+Dtos(dBaixa)+SE1->E1_CLIENTE+SE1->E1_LOJA+cSequencia
		If dBaixa >= dUltDif .And. dBaixa <= dDataBase
			dbSelectArea("SE5")
			dbSetOrder(2)
			cTipoDoc := "BA/VL/CP"
			If ( MV_PAR06 == 3 ) .AND. ( aBaixaSE5[nX][7] == SE2->E2_EMISSAO )
				Loop // de acordo com Juan (consultor), caso parametro mv_par06 = documento, nใo deve-se gerar DC para baixas com mesma data da emissao do titulo			
			Endif
			For nI := 1 to len( cTipoDoc) Step 3
				If dbSeek(xFilial("SE5")+substr(cTipoDoc,nI,2)+cChave)
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVerificar se o movimento ja foi corrigidoณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					lAtuaBx:=.T.
					SFR->(DbSetOrder(3))
				/*	If SFR->(FieldPos("FR_MOEDA"))<>0
						If SFR->FR_MOEDA==MV_PAR10
							lRet:=.T.
						Else
							lRet:=.F.
						EndIf
					Endif	  */
					IF !SFR->(MsSeek(xFilial('SFR')+"1"+"B"+cSequencia+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))//.and. lRet
						lAtuaBx:=.T.
					  //	nTxBaixa:=0  
					Else
					   While !EOF() .And. SFR->FR_CHAVOR==PADR(SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO, len(SFR->FR_CHAVOR)) .And. lAtuaBx
					   	//If lRet .And. SE5->E5_DATA==SFR->FR_DATADI
					   		If SE5->E5_DATA==SFR->FR_DATADI
					   			If cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|RUS|URU"
					   			  	If SFR->FR_MOEDA==MV_PAR10
		                   		 	    lAtuaBx:=.F.
		                   			 Else
	                       			 	lAtuaBx:=.T.	
							  		 	SFR->(DbSkip())
                        			EndIf
                        	   //	Else
					   			//	lAtuaBx:=.F.
					   			EndIf	
					   		Else
					   			lAtuaBx:=.T.	
							   	SFR->(DbSkip())
					   		EndIf
					   EndDo	
					Endif
					If lAtuaBx
						If !Empty(SE5->E5_ORDREC)   
							If ( SEL->(ColumnPos("EL_TXMOE"+StrZero(MV_PAR10,2))) > 0 ) .And. MV_PAR10>1
								SEL->(DbSetOrder(1))
								SEL->(DbSeek(xFilial("SEL")+SE5->E5_ORDREC+"TB"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
								nTxBaixa	:=	SEL->&("EL_TXMOE"+StrZero(MV_PAR10,2))
								//Iif(SE1->E1_MOEDA==MV_PAR10,SEL->&("EL_TXMOE"+StrZero(SE1->E1_MOEDA,2)),RecMoeda(SE5->E5_DTDIGIT,SE1->E1_MOEDA))
							EndIf
						Else
							nTxBaixa	:=	(SE5->E5_VALOR/SE5->E5_VLMOED2)    
						EndIf   
						
						If nTxBaixa	== 0
							If lCmpMda .And. MV_PAR10 <> 1
								nTxBaixa	:= RecMoeda(dDataBase,MV_PAR10)
							Else
								IF Type("lGeraDCam") == "U" // Variavel existe na gera็ใo automatica.  
									nTxBaixa	:= IIF(SE5->E5_TXMOEDA<>0,SE5->E5_TXMOEDA,RecMoeda(SE5->E5_DTDIGIT,SE1->E1_MOEDA)) 
								Else
									RecMoeda(SE5->E5_DTDIGIT,SE1->E1_MOEDA)
								EndIF
							EndIf		
						EndIf
						
						//Caso seja executado por recebimento
						//diversos a taxa atual serแ a taxa in formada no momento da gera็ใo do recibo
						
						If cPaisLoc == "RUS" 
							If lExterno .and. !IsInCallStack("Fa840Salvar")
								nTxBaixa:=nTxaAtual
							Endif
						Else
							If lExterno
								nTxBaixa:=nTxaAtual
							Endif
						EndIf     
						
						 If mv_par01 <>0 
					   	nTxBaixa:=mv_par01
						EndIf
						
						//Verifica se a taxa contratada foi preenchida    
						If !lAchouSFR
							nTxAt := Iif(SE1->E1_TXMOEDA > 0,SE1->E1_TXMOEDA,nTxAt)
						EndIf	
							
						nVlOrig	:=Round(xMoeda(SE5->E5_VLMOED2,SE1->E1_MOEDA,MV_PAR10,dUltDif,5,nTxAt,nTxOrig),GetSx3Cache("E1_VLCRUZ" ,"X3_DECIMAL"))
						nValorAtual:=Round(xMoeda(SE5->E5_VLMOED2,SE1->E1_MOEDA,MV_PAR10,SE5->E5_DATA,5,SE5->E5_TXMOEDA,nTxBaixa),GetSx3Cache("E1_VLCRUZ" ,"X3_DECIMAL"))
						If lExterno 
							nValorAtual	:=Round(xMoeda(SE5->E5_VLMOED2,SE1->E1_MOEDA,MV_PAR10,SE5->E5_DATA,8,nMdaTit,nTxBaixa) ,GetSx3Cache("E1_VLCRUZ" ,"X3_DECIMAL"))
						EndIf	
						nValor:= nValorAtual - nVlOrig
						If(lExterno .AND. nX != Len(aBaixaSE5) .AND. cPaisLoc == "URU" .AND. FwIsInCallStack("FINA087A") )
							nValor := 0
						EndIf
						AAdd(aBaixas,{SE5->(Recno()),nValor,SE5->E5_VLMOED2,nTxBaixa, nTxOrig})
					Endif
				Endif
			Next
		Endif
	Next
Endif
If mv_par07 ==1   
	Fa074TemDC(.F.)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalcular a correcao do saldo    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lCmpMda
		nSaldo := SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, SE1->E1_MOEDA, dDataBase, ;
		dDataBase, SE1->E1_LOJA ) +SE1->E1_ACRESC - SE1->E1_DESCONT

		If lAchouSFR
			nTxMdOrig	:= nTxOrig
		ElseIf dUltDif	==	SE1->E1_EMIS1		
			nTxMdOrig	:= SE1->E1_VLCRUZ/SE1->E1_VALOR
		Else
			nTxMdOrig	:=	RecMoeda(dUltDif, SE1->E1_MOEDA)			
		Endif
		If lAchouSFR
			nTxMda:=nTxAt
	  	ElseIf dUltDif	==	SE1->E1_EMIS1		
			nTxMda	:= SE1->E1_VLCRUZ/SE1->E1_VALOR	  	
	  	Else
		  	nTxMda	:=	Iif(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA, RecMoeda(dUltDif, SE1->E1_MOEDA))  
	  	EndIf
		If !lAchouDt 
			nTxAtu:=  If(mv_par01==0,aTxMoedas[SE1->E1_MOEDA][2],mv_par01)
			nSldOrig	:=Round(xMoeda(nSaldo,SE1->E1_MOEDA,MV_PAR10,dUltDif,5,nTxMda,nTxOrig),GetSx3Cache("E1_VLCRUZ" ,"X3_DECIMAL"))    //nTaxaAtu 
			nSaldoAt:= Round(xMoeda(nSaldo,SE1->E1_MOEDA,MV_PAR10,dDataBase,5,nTxAtu,aTxMoedas[MV_PAR10][2]) ,GetSx3Cache("E1_VLCRUZ" ,"X3_DECIMAL"))- nSldOrig
		Else
			nSaldoAt:=0 
		EndIf
		
		If cPaisLoc == "RUS"
			aSaldo	:=	{nSaldoAt,nSaldo,aTxMoedas[SE2->E2_MOEDA][2],nTxMda}
		Else	
			aSaldo	:=	{nSaldoAt,nSaldo,aTxMoedas[SE1->E1_MOEDA][2], aTxMoedas[MV_PAR10][2]}
		Endif
		
	Else
		nSaldo := SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, SE1->E1_MOEDA, dDataBase, ;
		dDataBase, SE1->E1_LOJA ) +SE1->E1_ACRESC - SE1->E1_DESCONT	
		aSaldo	:=	{nSaldo *(nTaxaAtu-nTxOrig),nSaldo,nTaxaAtu, nTxOrig}
	EndIf
Endif
Return {SE1->(RECNO()),aBaixas,aSaldo}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa074GetTxบAutor  ณBruno Sobieski      บFecha ณ  10-14-04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPega a taxa que sera considerada como a taxa original (e a  บฑฑ
ฑฑบ          ณtaxa da ultima correcao, ou a do titulo)                    บฑฑ
ฑฑฬออออออออออุอออออออออออ'อออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F074GetTx(nTaxa,dUltDif,lAchouSFR,lAchouDt,nTaxaAt)
Local cSequencia	:=	Space(GetSx3Cache('FR_SEQUEN',"X3_TAMANHO"))
Local cTipoMov		:=	"S"     
Local cFunName		:= FunName()
dUltDif := SE1->E1_EMIS1
If lCmpMda .And. mv_par10 <> 1
	nTaxa	:= If(mv_par01==0,RecMoeda(SE1->E1_EMIS1,mv_par10),mv_par01) //RecMoeda(SE1->E1_EMIS1,mv_par10)   
Else
	nTaxa	:=	SE1->E1_VLCRUZ/SE1->E1_VALOR
EndIf
DbSelectArea('SFR')
DbSetOrder(3)
DbSeek(xFilial()+"1"+cTipoMov+cSequencia+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO,.T.)
//DbSkip(-1)
While ( FR_FILIAL==xFilial() .And. FR_CARTEI=="1".And. FR_CHAVOR==PADR(SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO, len(FR_CHAVOR)) ) .And. !EOF() 
	If FR_FILIAL==xFilial() .And. FR_CARTEI=="1".And. FR_CHAVOR==PADR(SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO, len(FR_CHAVOR))
		If FR_TIPODI=='S'
			If cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|RUS|URU" //.And. SFR->FR_MOEDA <> mv_par10
		 	  nTaxa:=Iif( SFR->FR_MOEDA == mv_par10,IIf(SFR->FR_MOEDA==0,RecMoeda(SFR->FR_DATADI,mv_par10), SFR->FR_TXORI),nTaxa) 
		   //	nTaxa	:=	Iif(SFR->FR_MOEDA==0 .Or. SFR->FR_MOEDA == mv_par10,SFR->FR_TXATU,RecMoeda(SFR->FR_DATADI,mv_par10) )
				lAchouSFR:=.T.
			Else
				nTaxa:=SFR->FR_TXATU
			EndIf	
		
			If cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|RUS|URU" .AND. SFR->FR_MOEDA == mv_par10 
				dUltDif	:=	SFR->FR_DATADI
				lAchouDt:= Iif(SFR->FR_DATADI ==dDataBase,.T.,.F.)
				nTaxa:= SFR->FR_TXORI
				nTaxaAt:=SFR->FR_TXATU
			EndIf
			If cFunName == "FINA074" .and. cPaisLoc == "URU"
				nTaxa:=SFR->FR_TXATU
			EndIf		
		EndIf	
	Endif
SFR->(DbSKip())
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFa074GravaบAutor  ณBruno Sobieski      บFecha ณ  10-14-04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera os titulos de diferencia de cambio.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function F074Grava(aRecSE1,lMultiplo,lExterno)
Local aTitulo	:=	{}
Local	nOpc		:= 3    // Inclusao
Local aNum		:=	{}
Local lRet		:=	.T.
Local cPrefixo	:=	mv_par02
Local cTipDeb 	:=	mv_par03
Local cTipCred	:=	mv_par04
Local cNatureza:=	mv_par05
Local nSepara  :=	mv_par06
Local lGravaData:=Iif(mv_par07==1,.T.,.F.)
Local aGerar	:=	{}
Local aBaixa	:=	{}
//Local nX:= 0
//Local nY:=	0
Local nRecSX5	:=	0
Local nY:=1
Local nX:=1   
Local aSE1:={}
Local nMoedaTit := mv_par10
Local cChaveLbn := ""
Local cPrefOri  := ""
Local nGerDocFis := 2
Private lMsErroAuto	:=	.F.
Private cProvent := ""
Private cLocxNFPV:=""
Default lExterno := .F.

If cPaisLoc $ "ARG|URU|BOL" 
	nGerDocFis := MV_PAR12
EndIf

DbSelectArea("TRB")
DbGoTop()

If cPaisloc $ "ARG|BOL|URU" .And. nGerDocFis == 1 .And. nMoedaTit == 1 
	cTipDeb  := "NDC"
	cTipCred := "NCC"
EndIf   

While !TRB->(EOF())
	If !lMultiPlo .Or. (Alltrim(TRB->TRB_MARCA)==_MARCADO)
		If nSepara == 1
			If (nPos	:=	Ascan(aGerar,{|x| x[2]==TRB->E1_CLIENTE+TRB->E1_LOJA}))==0
				AAdd(aGerar,{{TRB->(Recno())},TRB->E1_CLIENTE+TRB->E1_LOJA,Iif(TRB->E1_TIPO$ MVRECANT+"/"+MV_CRNEG,(TRB->TRB_VALDIF*-1),TRB->TRB_VALDIF),dDataBase,TRB->E1_CLIENTE,TRB->E1_LOJA,'DC '+Dtoc(dDataBase)})
			Else
				AAdd(aGerar[nPos][1],	TRB->(Recno()))
				If TRB->E1_TIPO$ MVRECANT+"/"+MV_CRNEG
					aGerar[nPos][3]	-=	TRB->TRB_VALDIF
				Else
					aGerar[nPos][3]	+=	TRB->TRB_VALDIF
				EndIf
			Endif
		ElseIf nSepara == 2
			If (nPos	:=	Ascan(aGerar,{|x| x[2]==TRB->E1_PREFIXO+TRB->E1_NUM+TRB->E1_PARCELA+TRB->E1_TIPO+TRB->E1_CLIENTE+TRB->E1_LOJA}))==0
				AAdd(aGerar,{{TRB->(Recno())},TRB->E1_PREFIXO+TRB->E1_NUM+TRB->E1_PARCELA+TRB->E1_TIPO+TRB->E1_CLIENTE+TRB->E1_LOJA,Iif(TRB->E1_TIPO$ MVRECANT+"/"+MV_CRNEG,(TRB->TRB_VALDIF*-1),TRB->TRB_VALDIF),dDataBase,TRB->E1_CLIENTE,TRB->E1_LOJA,"DC"+TRB->E1_PREFIXO+"/"+TRB->E1_NUM})
			Else
				AAdd(aGerar[nPos][1],	TRB->(Recno()))
				If TRB->E1_TIPO$ MVRECANT+"/"+MV_CRNEG
					aGerar[nPos][3]	-=	TRB->TRB_VALDIF
				Else
					aGerar[nPos][3]	+=	TRB->TRB_VALDIF
				ENdIf
			Endif
		Else
	   //		AAdd(aGerar,{{TRB->(Recno())},'',Iif(TRB->E1_TIPO$ MVRECANT+"/"+MV_CRNEG,(TRB->TRB_VALDIF*-1),TRB->TRB_VALDIF),TRB->TRB_DTAJUS,TRB->E1_CLIENTE,TRB->E1_LOJA,TRB->E1_PREFIXO+TRB->E1_NUM+iIF(empty(TRB->E1_RECIBO),"Seq:"+TRB->E5_SEQ," RC:"+TRB->E1_RECIBO)})
	 	    AAdd(aGerar,{{TRB->(Recno())},'',Iif(TRB->E1_TIPO$ MVRECANT+"/"+MV_CRNEG,(TRB->TRB_VALDIF*-1),TRB->TRB_VALDIF),TRB->TRB_DTAJUS,TRB->E1_CLIENTE,TRB->E1_LOJA,"/"+TRB->E1_PREFIXO+TRB->E1_NUM+"/"+iIF(empty(TRB->E1_RECIBO),"Seq:"+TRB->E5_SEQ," RC:"+TRB->E1_RECIBO)})
		Endif
	Endif
	TRB->(DbSkip())
Enddo 
ProcRegua(Len(aGerar)*2)
For nX:=1 To Len(aGerar)
	cTipoDoc:= If(aGerar[nX][3]>0,cTipDeb,cTipCred)
	DbSelectArea('SX5')
	DbSetOrder(1)
	cPesq:=cPrefixo
	If cPaisloc $ "ARG|BOL|URU" .And. nGerDocFis == 1 // .And. nMoedaTit == 1  
		If cPaisLoc == "ARG"
    		cMvparAnt:= MV_PAR01
    		If !Pergunte("PVXARG",.T.)
    			Return .F.
    		Endif
    		cLocxNFPV := MV_PAR01
    		MV_PAR01:= cMvparAnt
		EndIf
		cIdPV:=""
		Apv := F074VldPv(cTipoDoc,cLocxNFPV)
		If Len(Apv)>1
			cPrefixo :=Apv[1]
			cIdPV:=Apv[2]
		EndIf
		cPesq:=Alltrim(cPrefixo)+cIdPV
		If ExistBlock("FinAltSe")
			cPrefixo:= ExecBlock("FinAltSe",.F.,.F.,{cTipoDoc})
			cPrefOri:= cPrefixo
			cPesq:=cPrefixo +cIdPV	   		
	   	ElseIf cPaisloc $ "ARG"  .and. Empty(cPrefixo)
			cPrefixo := LocXTipSer("SA1",cTipoDoc)
			cPesq:=Alltrim(cPrefixo)+cIdPV
		EndIf  
		
		If !SX5->(DbSeek(xFilial("SX5")+"01"+cPesq)) .And. cPaisloc $ "ARG"  
			cPrefixo := LocXTipSer("SA1",cTipoDoc) 
			If !MsgYesNo(STR0048 + cPrefOri + STR0049 + " "+ cPrefixo +"."+ STR0050,"Confirmaci๓n")
				Exit
			EndIf	
		EndIf
		If SX5->(DbSeek(xFilial()+'01'+ALLTRIM(cPesq)))
			nTimes := 0
			While !MsRLock() .and. nTimes < 10
				nTimes++
				Inkey(.1)
				DbSeek( xFilial("SX5")+"01"+ALLTRIM(cPesq),.F. )
			EndDo
			If MsRLock()
				aRetSX5:={}
				aRetSX5:=FWGetSX5( "01",ALLTRIM(cPesq)) 
				cNum := Substr( aretsx5[1][4] ,1,GetSx3Cache('E1_NUM',"X3_TAMANHO"))
				nRecSX5	:=	Recno()
			Else
				If lExterno
					lTrava:=.F. 
					lCont:=.T.
					While !lTrava // .And. lCont
						nTimes:=1
						While !MsRLock() .and. nTimes < 20
							nTimes++
							Inkey(.1)
							DbSeek( xFilial("SX5")+"01"+ALLTRIM(cPesq),.F. )
						EndDo
						If MsRLock()
							aRetSX5:={}
							aRetSX5:=FWGetSX5( "01",ALLTRIM(cPesq)) 
							cNum := Substr(aretsx5[1][4],1,GetSx3Cache('E1_NUM',"X3_TAMANHO"))
							nRecSX5	:=	Recno()
							lTrava:=.T.
				  		EndIf	
				  	EndDo	
				Else
				  	HELP('',1,'FA074004')
				  	Exit
				EndIf
			Endif
		Else
			HELP('',1,'FA074003')
			Exit
		Endif		
	EndIf
	If nGerDocFis <> 1
		If SX5->(DbSeek(xFilial()+'01'+ALLTRIM(cPrefixo)))
			nTimes := 0
			While !MsRLock() .and. nTimes < 10
				nTimes++
				Inkey(.1)
				DbSeek( xFilial("SX5")+"01"+ALLTRIM(cPrefixo),.F. )
			EndDo
			If MsRLock()
				aRetSX5:={}
				aRetSX5:=FWGetSX5( "01",ALLTRIM(cPrefixo)) 
				cNum := Substr(aretsx5[1][4],1,GetSx3Cache('E1_NUM',"X3_TAMANHO"))
				nRecSX5	:=	Recno()
			Else
				If lExterno
					lTrava:=.F.
					lCont:=.T.
					While !lTrava // .And. lCont
						nTimes:=1
						While !MsRLock() .and. nTimes < 20
							nTimes++
							Inkey(.1)
							DbSeek( xFilial("SX5")+"01"+ALLTRIM(cPrefixo),.F. )
						EndDo
						If MsRLock()			
							aRetSX5:={}
							aRetSX5:=FWGetSX5( "01",ALLTRIM(cPrefixo)) 
							cNum := Substr(aretsx5[1][4],1,GetSx3Cache('E1_NUM',"X3_TAMANHO"))
							nRecSX5	:=	Recno()
							lTrava:=.T.
				  		EndIf	
				  	EndDo	
				Else
				  	HELP('',1,'FA074004')
					Exit
				EndIf
			Endif
		Else
			HELP('',1,'FA074003')
			Exit
		Endif
	Endif
	If cPaisloc $ "ARG|BOL|URU".And. nGerDocFis == 1 .And. nMoedaTit == 1   
		F74ValidNum(ALLTRIM(cPrefixo),@cNum,cTipoDoc,.F.)
	Else    
		DbSelectArea("SE1")
		DbSetOrder( 1 )
		If  DbSeek( xFilial("SE1")+cPrefixo+cNum+Space(GetSx3Cache('E1_PARCELA',"X3_TAMANHO"))+cTipoDoc)
			lRet:= .F.
		EndIf	
	EndIf	
	cProvent:= ""
	If lRet
		If cPaisloc == "ARG" 
				DbSelectArea("SF2")  
				dbSetOrder(1)
   				If DbSeek(xFilial("SF2")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA)
   					cProvent:= SF2->F2_PROVENT  
   				EndIf	
   		EndIf 
		IncProc(STR0011+ALLTRIM(cPrefixo)+"/"+cNum) //'Grabando documento : '
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณInclusao de documento no contas a cobrarณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aTitulo := { 	{"E1_PREFIXO"	, ALLTRIM(cPrefixo) 			,	Nil},;
		{"E1_NUM"		, cNum				, 	Nil},;
		{"E1_PARCELA"	, ''				,	Nil},;
		{"E1_TIPO"		, cTipoDoc			,	Nil},;
		{"E1_NATUREZ"	, cNatureza			,	Nil},;
		{"E1_CLIENTE"	, aGerar[nX][5]		,	Nil},;
		{"E1_LOJA"		, aGerar[nX][6]		,	Nil},;
		{"E1_EMISSAO"	, aGerar[nX][4]  	,	NIL},;
		{"E1_VENCTO"	, aGerar[nX][4]		,	NIL},;
		{"E1_VENCREA"	, aGerar[nX][4] 	,	NIL},;
		{"E1_ORIGEM"	, 'FINA074'			,	NIL},;
		{"E1_MOEDA"		, nMoedaTit			,	NIL},;
		{"E1_CONVERT"	, 'N'				,	NIL},;
		{"E1_HIST"		, aGerar[nX][7]		,	Nil},;
		{"E1_VALOR"		, Abs(aGerar[nX][3]),	Nil}}
		
		If cPaisloc == "MEX" 
			AADD( aTitulo,{"E1_TXMOEDA"	, MV_PAR01	,Nil} )	
		EndIf
			
		If ExistBlock('FA074CPO')
			aTitulo	:=	ExecBlock('FA074CPO',.F.,.F.,aTitulo)
		Endif
		lMsErroAuto := .F.
		If Abs(aGerar[nX][3]) > 0
			MSExecAuto({|x,y,z| FINA040(x,y,z)},aTitulo,3)
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
			Else
				If SE1->E1_CONVERT <> 'N'
					dbSelectArea( "SE1" )
					RecLock("SE1",.F.)
					Replace E1_CONVERT With 'N'
					MsUnLock()
				Endif
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณInclusao de amarracao Titulo x Dif Cambio ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				For nY:=1 TO LEN(aGerar[nX][1])
					TRB->(dbGoTo(aGerar[nX][1][nY]))
					dbSelectArea( "SFR" )
					RecLock("SFR",.T.)
					REPLACE FR_FILIAL 	WITH	xFilial()
					Replace FR_CHAVDE	WITH	SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
					Replace FR_CHAVOR	WITH	TRB->E1_CLIENTE+TRB->E1_LOJA+TRB->E1_PREFIXO+TRB->E1_NUM+TRB->E1_PARCELA+TRB->E1_TIPO
					Replace FR_CARTEI	WITH	"1"
					Replace FR_TIPODI	WITH	TRB->TRB_TIPODI
					Replace FR_DATADI	WITH	TRB->TRB_DTAJUS
					Replace FR_TXATU 	WITH	TRB->TRB_TXATU
					Replace FR_TXORI 	WITH	TRB->TRB_TXORI
					Replace FR_CORANT	WITH	TRB->TRB_VALCOR //CORRECOES ANT.
					Replace FR_VALOR 	WITH	TRB->TRB_VALDIF //CORRECAO (MOEDA1)
					Replace FR_GEROU 	WITH	"1"
					Replace FR_RECIBO	WITH	TRB->E1_RECIBO
					Replace FR_SEQUEN	WITH	TRB->E5_SEQ
					If cPaisLoc $ "ANG|ARG|COL|EQU|HAI|MEX|PER|PTG|RUS|URU"
						Replace FR_MOEDA With nMoedaTit
					EndIf	
					MsUnLock()
				Next nY
				cSx5Num:= Soma1(cNum)
				FWPutSX5(,"01",ALLTRIM(cPrefixo),cSx5Num,cSx5Num,cSx5Num,cSx5Num)
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Ponto de entrada p/ gravacao dos campos criados pelo usuario ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If ExistBlock("FA074GRV")
					EXECBLOCK("FA074GRV",.F.,.F.)
				Endif
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณBaixa do titulo                           ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				IncProc(STR0012+ALLTRIM(cPrefixo)+"/"+cNum) //'Bajando documento : '
				aBaixa	:=	{}
				AADD( aBaixa, { "E1_PREFIXO" 	, SE1->E1_PREFIXO		, Nil } )	// 01
				AADD( aBaixa, { "E1_NUM"     	, SE1->E1_NUM		 	, Nil } )	// 02
				AADD( aBaixa, { "E1_PARCELA" 	, SE1->E1_PARCELA		, Nil } )	// 03
				AADD( aBaixa, { "E1_TIPO"    	, SE1->E1_TIPO			, Nil } )	// 04
				AADD( aBaixa, { "E1_CLIENTE"	, SE1->E1_CLIENTE		, Nil } )	// 05
				AADD( aBaixa, { "E1_LOJA"    	, SE1->E1_LOJA			, Nil } )	// 06
				AADD( aBaixa, { "AUTMOTBX"  	, "DIF"					, Nil } )	// 07
				AADD( aBaixa, { "AUTBANCO"  	, ""					, Nil } )	// 08
				AADD( aBaixa, { "AUTAGENCIA"  	, ""					, Nil } )	// 09
				AADD( aBaixa, { "AUTCONTA"  	, ""					, Nil } )	// 10
				AADD( aBaixa, { "AUTDTBAIXA"	, SE1->E1_EMISSAO		, Nil } )	// 11
				AADD( aBaixa, { "AUTHIST"   	, STR0020				, Nil } )	// 12 //"Diferencia de cambio"
				AADD( aBaixa, { "AUTDESCONT" 	, 0						, Nil } )	// 13
				AADD( aBaixa, { "AUTMULTA"	 	, 0						, Nil } )	// 14
				AADD( aBaixa, { "AUTJUROS"		, 0						, Nil } )	// 15
				AADD( aBaixa, { "AUTOUTGAS" 	, 0						, Nil } )	// 16
				AADD( aBaixa, { "AUTVLRPG"  	, 0        				, Nil } )	// 17
				AADD( aBaixa, { "AUTVLRME"  	, 0						, Nil } )	// 18
				AADD( aBaixa, { "AUTCHEQUE"  	, ""					, Nil } )	// 19
				lMsErroAuto := .F.
				MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)
				If lMsErroAuto
					DisarmTransaction()
					MostraErro()
				Else
					If lGravaData
						aSE1:=GetaRea()
						For nY:=1 TO LEN(aGerar[nX][1])
							TRB->(dbGoTo(aGerar[nX][1][nY]))
						    SE1->(DbSetOrder(2))
							If SE1->(DbSeek(xFilial("SE1")+TRB->E1_CLIENTE+TRB->E1_LOJA+TRB->E1_PREFIXO+TRB->E1_NUM+TRB->E1_PARCELA+TRB->E1_TIPO ))
								RecLock('SE1',.F.)
								Replace E1_DTDIFCA	With dDataBase
								MsUnLock()
							EndIf
						Next
						RestArea(aSE1)
					Endif
		        If  cPaisloc $ "ARG|BOL|URU".And.nGerDocFis == 1 .And. nMoedaTit == 1 // Verifica se gera documento fiscal  e se a dif serแ em moeda 1
					F074GeraNF(aGerar[nX][3],TRB->E1_EMISSAO,aGerar[nX])    	
		 		EndIf 

				EndIf
			EndIf
		EndIf	
	Else
		Help('',1,'FA074002')
	Endif
Next
If nRecSX5 > 0
	SX5->(MsGoTo(nRecSX5))
	MsUnLock()
Endif
If !lExterno
	Pergunte("FIN74A",.F.)
EndIf
Return

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFa074Tela   ณ Autor ณ Bruno Sobieski      ณ Data ณ 22.10.01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Monta a tela para mostrar os dados                         ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Fina074                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Fa074Tela(nOpc,nTotAjuste,aCampos,lMultiplo)
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
Local lVisual 	:=	(nOpc == 2)
Local lInclui	:=	(nOpc == 3)
Local lDeleta	:=	(nOpc == 5)
Local oFont
Local nmoeda:= mv_par10
Local lAutomato := IsBlind()
DEFINE FONT oFont NAME "Arial" BOLD

DEFAULT lMultiplo	:=	.F.

If nOpc == 2 //Chamada a visualiza็ใo da Dif. de Cโmbio
	nMoeda := SFR->FR_MOEDA
EndIf

If lMultiplo
	nBitMaps := 2
Endif

If !lDeleta
	bOk	:=	{|| nOpca:=	1,oDlg:End()}
	bCanc	:=	{|| nOpca:=	2,oDlg:End()}
Else
	bOk	:=	{|| IIf(Fa074DelOk(),(nOpca:=1,oDlg:End()),Nil)}
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
@ aPosObj[1,1]+005,10 SAY OemToAnsi(STR0029+' (' + GetMv("MV_SIMB"+Alltrim(Str(nMoeda)))+')') SIZE 80, 7 OF oDlg PIXEL FONT oFont COLOR CLR_BLUE //Valor Del Ajuste
@ aPosObj[1,1]+005,080 SAY oTotAjuste VAR nTotAjuste   PICTURE PesqPict("SE1","E1_VLCRUZ",18) SIZE 65, 7 OF oDlg PIXEL FONT oFont COLOR CLR_BLUE
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
	oLbx:BLDblClick := {|| Fa074Mark(oLbx,@nTotAjuste,@oTotAjuste,1)}
	
	bMarkAll	:= { || CursorWait() ,;
	Fa074Mark(oLbx,@nTotAjuste,@oTotAjuste,2),;
	CursorArrow();
	}
	bUnMarkAll	:= { || CursorWait() ,;
	Fa074Mark(oLbx,@nTotAjuste,@oTotAjuste,3),;
	CursorArrow();
	}
	bInverte		:= { || CursorWait() ,;
	Fa074Mark(oLbx,@nTotAjuste,@oTotAjuste,4),;
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
	DEFINE COLUMN oCol DATA FIELDWBlock(aCampos[nX][2],Select('TRB')) BITMAP HEADER OemToAnsi(aCampos[nX][1]) PICTURE  aCampos[nX][6] ALIGN LEFT SIZE CalcFieldSize(aCampos[nX,3],aCampos[nX,4],aCampos[nX,5],aCampos[nX,2],aCampos[nX,1]) PIXELS
	oLbx:AddColumn(oCol)
Next

//Definir as demais colunas
For nX:=(nBitMaps+1) To Len(aCampos)
	DEFINE COLUMN oCol DATA FIELDWBlock(aCampos[nX][2],Select('TRB')) HEADER OemToAnsi(aCampos[nX][1]) PICTURE  aCampos[nX][6] ALIGN LEFT SIZE CalcFieldSize(aCampos[nX,3],aCampos[nX,4],aCampos[nX,5],aCampos[nX,2],aCampos[nX,1]) PIXELS
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
ฑฑณFun…o    ณFa074Dele   ณ Autor ณ Bruno Sobieski      ณ Data ณ 22.10.01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Apaga o ajuste por diferencia de cambio                    ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Fina074                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FA074Dele(nRecSE1)
Local aBaixa	:=	{}
Local aDifs	:=	{}
Local nX:=1
Local dUltDif
Local cSequencia	:=	Space(GetSx3Cache('FR_SEQUEN',"X3_TAMANHO"))
Local cTipoMov		:=	"S"
local nMoedaTit := mv_par10
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBaixa do titulo                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SE1->(dBGoTo(nRecSE1))
If cPaisloc $ "ARG|BOL|URU" .And. SE1->E1_TIPO $ "NDC|NCC"
	If SE1->E1_TIPO == "NDC"
		cAlias := "SF2" 
	ElseIf SE1->E1_TIPO == "NCC"
		cAlias := "SF1" 
	EndIf
	DbSelectArea(cAlias)
	DbSetOrder(1)
	If DbSeek(xFilial(cAlias)+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA)
		F074CancelNF(cAlias)
	EndIf	
EndIf	
IncProc(STR0043+' : '+SE1->E1_PREFIXO+"/"+SE1->E1_NUM) //Borrando baja de documento
aBaixa	:=	{}
AADD(aBaixa,{"E1_PREFIXO" 	,SE1->E1_PREFIXO		, Nil})	// 01
AADD(aBaixa,{"E1_NUM"     	,SE1->E1_NUM			, Nil})	// 02
AADD(aBaixa,{"E1_PARCELA" 	,SE1->E1_PARCELA		, Nil})	// 03
AADD(aBaixa,{"E1_TIPO"    	,SE1->E1_TIPO			, Nil})	// 04
AADD(aBaixa,{"E1_MOEDA"   	,SE1->E1_MOEDA			, Nil})	// 05
AADD(aBaixa,{"E1_TXMOEDA"	,SE1->E1_TXMOEDA		, Nil})	// 06
AADD(aBaixa,{"E1_CLIENTE" 	,SE1->E1_CLIENTE		, Nil})	// 07
AADD(aBaixa,{"E1_LOJA"		,SE1->E1_LOJA   		, Nil})	// 08
lMsErroAuto := .F.
MSExecAuto({|x,y| Fina070(x,y)},aBaixa,5)
If lMsErroAuto
	DisarmTransaction()
	MostraErro()
Else
	DbSelectArea('TRB')
	DbGoTop()
	While !EOF()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDelecao de amarracao Titulo x Dif Cambio  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea( "SFR" )
		SFR->(dbGoTo(TRB->TRB_RECSFR))
		If FA074EstDC()
			AAdd(aDifs,SFR->FR_CHAVOR)
			RecLock("SFR",.F.)
			DbDelete()
			MsUnLock()
		EndIf
		DbSelectArea('TRB')
		DbSkip()
	Enddo
	IncProc(STR0044+' : '+SE1->E1_PREFIXO+"/"+SE1->E1_NUM) //Borrando documento
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Delecao de documento no contas a cobrarณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aTitulo := { 	{"E1_PREFIXO"	, SE1->E1_PREFIXO	,	Nil},;
	{"E1_NUM"		, SE1->E1_NUM		, 	Nil},;
	{"E1_PARCELA"	, SE1->E1_PARCELA	,	Nil},;
	{"E1_TIPO"		, SE1->E1_TIPO		, 	Nil},;
	{"E1_NATUREZ"	, SE1->E1_NATUREZA,	Nil},;
	{"E1_CLIENTE"	, SE1->E1_CLIENTE	,  Nil},;
	{"E1_LOJA"		, SE1->E1_LOJA		,	Nil},;
	{"E1_MOEDA"		, nMoedaTit			,	NIL}}
	lMsErroAuto := .F.
	MSExecAuto({|x,y,z| FINA040(x,y,z)},aTitulo,5)
	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRegravar a data de ultima diferencie de cambio calculada, comณ
		//ณa ultima data de DC.                                         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nX:=1 To Len(aDifs)
			dUltDif	:=	Ctod('')
			DbSelectArea('SFR')
			DbSetORder(3)
			DbSeek(xFilial()+"1"+cTipoMov+cSequencia+aDifs[nX]+'zzzzzz',.T.)
			DbSkip(-1)
			If FR_FILIAL==xFilial() .And. FR_CARTEI=="1" .And. FR_CHAVOR==PADR(aDifs[nX],len(FR_CHAVOR)) .And. FR_TIPODI=='S'
				dUltDif	:=	SFR->FR_DATADI
			EndIf
			DbSelectArea('SE1')
			DbSetOrder(2)
			MsSeek(xFilial()+aDifs[nX])
			RecLock('SE1',.F.)
			Replace E1_DTDIFCA With dUltDif
			MsUnLock()
		Next
	Endif
Endif

Return
/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFa074DelOk  ณ Autor ณ Bruno Sobieski      ณ Data ณ 22.10.01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Valida a exclusao da diferencia de cambio                  ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Fina074                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Fa074DelOk()
Local	lRet	:=	.T.

lRet	:=	(Aviso(STR0045,STR0046+CRLF+STR0017,{STR0018,STR0005})==1) //"Confirmacion"###Seran borrados todos los movimientos de diferencia de cambio visualizados.###"Confirmar"###"Cancelar"


Return lRet
/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFa074GerTRB ณ Autor ณ Bruno Sobieski      ณ Data ณ 22.10.01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Gera arquivo de trabalho para a visualizacao e delecao     ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Fina074                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function Fa074GerTRB(aCampos,nTotAjuste)
Local aStruTRB	:=	{}
Local nX	:=	0
Local cChave	:=	''
Local aOrdem	:={}

//Monta estrutura do trb
aadd(aStruTrb,{"TRB_ORIGEM"	,"C",10,0})
aadd(aStruTrb,{"E1_CLIENTE"	,"C",GetSx3Cache("E1_CLIENTE","X3_TAMANHO"),GetSx3Cache("E1_CLIENTE","X3_DECIMAL")})
aadd(aStruTrb,{"E1_LOJA"  	,"C",GetSx3Cache("E1_LOJA"   ,"X3_TAMANHO"),GetSx3Cache("E1_LOJA"   ,"X3_DECIMAL")})
aadd(aStruTrb,{"E1_PREFIXO"	,"C",GetSx3Cache("E1_PREFIXO","X3_TAMANHO"),GetSx3Cache("E1_PREFIXO","X3_DECIMAL")})
aadd(aStruTrb,{"E1_NUM"		,"C",GetSx3Cache("E1_NUM"    ,"X3_TAMANHO"),GetSx3Cache("E1_NUM"    ,"X3_DECIMAL")})
aadd(aStruTrb,{"E1_PARCELA"	,"C",GetSx3Cache("E1_PARCELA","X3_TAMANHO"),GetSx3Cache("E1_PARCELA","X3_DECIMAL")})
aadd(aStruTrb,{"E1_TIPO"	,"C",GetSx3Cache("E1_TIPO"   ,"X3_TAMANHO"),GetSx3Cache("E1_TIPO"   ,"X3_DECIMAL")})
aadd(aStruTrb,{"E1_RECIBO"	,"C",GetSx3Cache("E1_RECIBO" ,"X3_TAMANHO"),GetSx3Cache("E1_RECIBO" ,"X3_DECIMAL")})
aadd(aStruTrb,{"E1_EMISSAO"	,"D",GetSx3Cache("E1_EMISSAO","X3_TAMANHO"),GetSx3Cache("E1_EMISSAO","X3_DECIMAL")})
//aadd(aStruTrb,{"E1_VALOR"	,"N",TamSx3("E1_VALOR"  )[1],TamSx3("E1_VALOR"  )[2]})
aadd(aStruTrb,{"TRB_VALDIF"	,"N",GetSx3Cache("E1_VLCRUZ" ,"X3_TAMANHO"),GetSx3Cache("E1_VLCRUZ" ,"X3_DECIMAL")})
aadd(aStruTrb,{"TRB_RECSFR"	,"N",10,0})

SX3->(DbSetOrder(2))
AAdd(aCampos,{' ','TRB_ORIGEM',aStruTRB[1][2],aStruTRB[1][3],aStruTRB[1][4],"@BMP"})
For nX := 2 To (Len(aStruTRB)-1)
	If !(aStruTRB[nX][1]$"TRB_VALDIF")
		SX3->(DbSeek(aStruTRB[nX][1]))
		AAdd(aCampos,{X3TITULO(aStruTRB[nX][1]),aStruTRB[nX][1],aStruTRB[nX][2],aStruTRB[nX][3],aStruTRB[nX][4],PesqPict("SE1",aStruTRB[nX][1])})
	Else
		AAdd(aCampos,{STR0008,aStruTRB[nX][1],aStruTRB[nX][2],aStruTRB[nX][3],aStruTRB[nX][4],PesqPict("SE1","E1_VLCRUZ")}) //"Diferencia"
	Endif
Next

aOrdem	:=	{"E1_CLIENTE","E1_LOJA","E1_PREFIXO","E1_NUM"}
oTmpTRB := FWTemporaryTable():New("TRB")
oTmpTRB:SetFields( aStruTrb )
oTmpTRB:AddIndex("I1", aOrdem)
oTmpTRB:Create()

SE1->(DbSetOrder(2))
cChave	:=	PADR(SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO,len(SFR->FR_CHAVDE))
DbSelectArea('SFR')
DbSetOrder(2)
DbSeek(xFilial()+"1"+cChave)
While !EOF() .And. FR_CARTEI=="1" .AND. FR_CHAVDE ==	cChave
	SE1->(DbSeek(xFilial()+left(SFR->FR_CHAVOR,len(SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))))
	Reclock('TRB',.T.)
	Replace E1_CLIENTE With SE1->E1_CLIENTE
	Replace E1_LOJA 	 With SE1->E1_LOJA
	Replace E1_PREFIXO With SE1->E1_PREFIXO
	Replace E1_NUM     With SE1->E1_NUM
	Replace E1_PARCELA With SE1->E1_PARCELA
	Replace E1_TIPO    With SE1->E1_TIPO
	Replace E1_EMISSAO With SFR->FR_DATADI
	Replace E1_RECIBO  With SFR->FR_RECIBO
	Replace TRB_ORIGEM With Iif(SFR->FR_TIPODI=="S",_AZUL,_AMARELO)
	Replace TRB_VALDIF With SFR->FR_VALOR
	Replace TRB_RECSFR With SFR->(Recno())
	MsUnLock()
	If TRB->E1_TIPO$ MVRECANT+"/"+MV_CRNEG
		nTotAjuste	-=	SFR->FR_VALOR
	Else
		nTotAjuste	+=	SFR->FR_VALOR	
	EndIf
	DbSelectArea('SFR')
	DbSkip()
EndDo

DbGotop()

Return

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFa074Legendaณ Autor ณ Bruno Sobieski      ณ Data ณ 22.10.01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria uma janela contendo a legenda da mBrowse ou retorna a ณฑฑ
ฑฑณ          ณ para o BROWSE                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Fina074 e Fina074                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Fa074Legenda(cAlias, nReg)
Local aLegenda := { 	{"BR_VERDE", STR0018 },;	 //"Titulo en abierto"
{"BR_AZUL" , STR0019 },;	 //"Bajado parcialmente"
{"BR_AMARELO" , STR0020 },;	 //"Diferencia de cambio"
{"BR_VERMELHO", STR0021} ,;	 //"Bajado totalmente"
{"BR_PRETO"  , STR0047} } //"Ya ajustado"

Local uRetorno := .T.

If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	Aadd(uRetorno, { 'E1_CONVERT=="N"', aLegenda[3][1] } )
	Aadd(uRetorno, { 'E1_DTDIFCA>=dDataBase  ', aLegenda[5][1] } )
	Aadd(uRetorno, { 'ROUND(E1_SALDO,2) = 0', aLegenda[4][1] } )
	Aadd(uRetorno, { 'ROUND(E1_SALDO,2) # ROUND(E1_VALOR,2)', aLegenda[2][1] } )
	Aadd(uRetorno, { '.T.', aLegenda[1][1] } )
Else
	BrwLegenda(cCadastro, STR0006 , aLegenda) //"Leyenda"
Endif

Return uRetorno

Static Function Fa074Mark(oLbx,nTotAjuste,oTotAjuste,nOpc)
Local	cChave	:=	TRB->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
Local nRecno	:=	TRB->(Recno())
Local cMarca	:=	IIf(TRB->TRB_MARCA  <> _DESMARCADO,_DESMARCADO,_MARCADO)
Local bWhile

DbSelectArea('TRB')
//Inverte o atual
If nOpc == 1
	bWhile	:=	{|| cChave==TRB->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)}
	DbSeek(cChave)
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
		cMarca	:=	IIf(TRB->TRB_MARCA  <> _DESMARCADO,_DESMARCADO,_MARCADO)
	Endif
	cMarcaAnt := TRB_MARCA
	RecLock('TRB',.F.)
	Replace TRB_MARCA  With cMarca
	MsUnlock()
	If cMarcaAnt <> cMarca
		If TRB->E1_TIPO$ MVRECANT+"/"+MV_CRNEG
			nTotAjuste	+=	(TRB->TRB_VALDIF * IIf(cMarca  <> _DESMARCADO,-1,+1))
	    Else
	    	nTotAjuste	+=	(TRB->TRB_VALDIF * IIf(cMarca  <> _DESMARCADO,1,-1))
	    eNDiF	
	Endif
	DbSkip()
Enddo
DbGoTo(nRecno)
oLbx:Refresh()
oTotAjuste:Refresh()

Return                
/*
Static Function F074SetFBrw(bFiltro)
If mv_par09==2.And.bFilBrw<>Nil
	EndFilBrw("SE1",@aIndices)
	bFilBrw	:=	Nil  
ElseIf (mv_par09==1.And.bFilBrw==Nil)
	bFilBrw	:=	bFiltro
   Eval(bFilBrw)
Endif
Return
*/
     
Static Function MenuDef()
Local aRotina := { { OemToAnsi(STR0001), "PesqBrw" , 0 , 1},; //"Pesquisar" //"Busqueda"
{ OemToAnsi(STR0002)	, "AxVisual" 	, 0 , 2},; //"Visualizar" //"Visualizar"
{ OemToAnsi(STR0003)	, "Fa074Vis" 	, 0 , 2},; //"Visualizar" //"vis. Dif. cambio"
{ OemToAnsi(STR0022)	, "Fa074GDifM" , 0 , 4},;
{ OemToAnsi(STR0004)	, "Fa074GDif(.F.)" , 0 , 4},;
{ OemToAnsi(STR0005)	, "FA074CanC(.F.)" 	 ,0 , 5},; //"Cancelar" //"Cancelar"
{ OemToAnsi(STR0006)	, "Fa074Legenda",0 , 6} } //"Le&genda" //"Leyenda"

Return(aRotina)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA085SetMoบAutor  ณAlexandre Silva     บ Data ณ  11.01.02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConfigura as taxas das moedas.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA085A                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa074SetMo()

Local   lConfirmo   :=	 .F.
Local   aCabMoed	  :=	{}
Local   aTamMoed	  := {23,25,30,30}
Local   aCpsMoed    := {"cMoeda","nTaxa"}
Local	  aTmp1	     := aTxMoedas[1]
Private nQtMoedas   := Moedfin()
Private aLinMoed    :=	aClone(aTxMoedas)
Private oBMoeda              
aDel(aLinMoed,1)
aSize(aLinMoed,Len(aLinMoed)-1)
/*
Set Filter to

Eval(bFiltraBrw)
*/
Posicione("SX3",2,"EL_MOEDA","X3_TITULO")
Aadd(aCabMoed,X3Titulo())
Aadd(aCabMoed,STR0026)

If nQtMoedas > 1
	Define MSDIALOG oDlg From 50,250 TO 212,480 TITLE STR0026 PIXEL //"Tasas"

		oBMoeda:=TwBrowse():New(04,05,01,01,,aCabMoed,aTamMoed,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		
		oBMoeda:SetArray(aLinMoed)
		oBMoeda:bLine 	:= { ||{aLinMoed[oBMoeda:nAT][1],;
		Transform(aLinMoed[oBMoeda:nAT][2],PesqPict("SM2","M2_MOEDA"+AllTrim(Str(oBMoeda:nAT)),GetSx3Cache("M2_MOEDA"+AllTrim(Str(oBMoeda:nAT)) ,"X3_TAMANHO") ))}}

		oBMoeda:bLDblClick   := {||EdMoeda(),oBMoeda:ColPos := 1,oBMoeda:SetFocus()}
		oBMoeda:lHScroll     := .F.
		oBMoeda:lVScroll     := .T.
		oBMoeda:nHeight      := 112
		oBMoeda:nWidth	      := 215
		obMoeda:AcolSizes[1]	:= 50
		
	DEFINE  SButton FROM 064,50 TYPE 1 Action (lConfirmo := .T. , oDlg:End() ) ENABLE OF oDlg  PIXEL
	DEFINE  SButton FROM 064,80 TYPE 2 Action (,oDlg:End() ) ENABLE OF oDlg  PIXEL
	Activate MSDialog oDlg
Else
	Help("",1,"NoMoneda")
EndIf

If lConfirmo
	AAdd(aLinMoed,{})
	aIns(aLinMoed,1)
	aLinMoed[1]	:=	aClone(aTmp1)
	aTxMoedas	:=	aClone(aLinMoed)
Endif

Return
Static Function EdMoeda()

oBMoeda:ColPos := 1
lEditCell(@aLinMoed,oBMoeda,PesqPict("SM2","M2_MOEDA"+AllTrim(Str(oBMoeda:nAT)),GetSx3Cache("M2_MOEDA"+AllTrim(Str(oBMoeda:nAT)),"X3_TAMANHO")),2)
aLinMoed[oBMoeda:nAT][2] := obMoeda:Aarray[oBMoeda:nAT][2]

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA074TemDCบAutor  ณMarcelo Akama       บ Data ณ  02.09.09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se tem diferen็a de cambio gerada                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA074                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Fa074TemDC(lExecLote)
Local aAreaSFR	:= SFR->(GetArea())
Local aAreaSE1	:= SE1->(GetArea())
Local lRet		:= .F.
Local cChave
Local nLen              
Local bValid := {||SFR->FR_TIPODI == "S" .Or. ( SFR->FR_TIPODI == "B".And.SE1->E1_SALDO == 0 )}
Default lExecLote := .F.

cChave := SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
nLen   := Len(cChave)
cChave := PADR(cChave, len(SFR->FR_CHAVOR) )
SE1->(dbSetOrder(2))
SFR->(dbSetOrder(1))
SFR->(dbSeek(xFilial("SFR")+"1"+cChave+DTOS(dDataBase), .T.))
Do While !lRet .And. SFR->FR_FILIAL==xFilial("SFR") .And. SFR->FR_CARTEI=="1" .And. SFR->FR_CHAVOR==cChave .And. SFR->FR_DATADI>=dDataBase
//	If SE1->(dbSeek(xFilial("SE1")+left(SFR->FR_CHAVDE,nLen))) .And. SE1->E1_MOEDA == mv_par10
	If Eval(bValid) .And. SE1->(dbSeek(xFilial("SE1")+left(SFR->FR_CHAVDE,nLen))) .And. SE1->E1_MOEDA == mv_par10 
		If lExecLote
			aAdd(aExecLog,cChave)
		Else
			Help('',1,'FA074012')		
		EndIf
		Return .T.
	EndIf
	SFR->(dbSkip())
EndDo

RestArea(aAreaSFR)
RestArea(aAreaSE1)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFA074EstDCบAutor  ณMarcelo Akama       บ Data ณ  03.09.09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Estorna lancamentos de diferenca de cambio                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA074                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FA074EstDC()
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local nHdlPrv
Local cArquivo
Local nTotDoc
Local lLanctOk
Local nLinha
Local lDigita	:= .T.
Local lAglutina	:= .F.
Local lRet		:= .T.
Private cLote
Private aFlagCTB := {}

If cPaisLoc $ "ANG|COL|MEX|BOL|RUS" .And. SFR->FR_LA == "S"

	//+--------------------------------------------------------------+
	//ฆ Verifica o N๚mero do Lote 									 ฆ
	//+--------------------------------------------------------------+

	dbSelectArea("SX5")
	dbSeek(xFilial()+"09FIN")
	If Found()
		If At(UPPER("EXEC"),SX5->X5_DESCRI) > 0
			cLote := &(SX5->X5_DESCRI)
		Else
			cLote := SX5->X5_DESCRI
		Endif
	Else
		cLote := "FIN"
	Endif

	nHdlPrv := HeadProva( cLote, "COFFA01", Substr( cUsuario, 7, 6 ), @cArquivo )

	If nHdlPrv <= 0
		Help(" ",1,"A100NOPROV")
		Return .F.
	EndIf

	nTotDoc := DetProva( nHdlPrv,;
	                     IIf(SFR->FR_CARTEI=="1","57B","57D"),;
	                     "COFFA01",;
	                     cLote,;
	                     @nLinha,;
	                     /*lExecuta*/,;
	                     /*cCriterio*/,;
	                     /*lRateio*/,;
	                     /*cChaveBusca*/,;
	                     /*aCT5*/,;
	                     /*lPosiciona*/,;
	                     @aFlagCTB,;
	                     /*aTabRecOri*/,;
	                     /*aDadosProva*/ )

	//+-----------------------------------------------------+
	//ฆ Envia para Lancamento Contabil, se gerado arquivo   ฆ
	//+-----------------------------------------------------+
	RodaProva(  nHdlPrv, nTotDoc)

	//+-----------------------------------------------------+
	//ฆ Envia para Lancamento Contabil, se gerado arquivo   ฆ
	//+-----------------------------------------------------+
	lRet := cA100Incl(	cArquivo,;
						nHdlPrv,;
						3,;
						cLote,;
						lDigita,;
						lAglutina,;
						/*cOnLine*/,;
						/*dData*/,;
						/*dReproc*/,;
						@aFlagCTB,;
						/*aDadosProva*/,;
						/*aDiario*/ )
	aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF084GeraNFบAutor  ณAna Paula Nascimentoบ Data ณ  18.03.10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera documento fiscal para diferen็a de cambios geradas     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA084 e FINA085A                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F074GeraNF(nTotDif,dDataTit,aDadosOr)
Local  lTeste:=.T.
Local aCab 			:= {} 	//Dados do cabe็alho
Local aItem 		:= {} 	//Dados do item
Local aLinea 		:= {} 	//Matriz que guarda la matriz aItem (requerido por la rutina)
Local nSigno  :=      Iif(SE1->E1_TIPO $MVRECANT+"/"+MV_CRNEG,-1,1)
Local cTipo:=  Iif(SE1->E1_TIPO == "NCC",04,02)
Local nNumNF := 0
Local lGera := .T.
Local cSerie:= "   "                      
Local nGerDocFis := 2 
Local cTES := ""
Local nCondPad	:= SuperGetMV( "MV_CONDPAD")
Local cSerOri:=""
Local cNumOr:= ""
Local cRG1415:= ""
Local aAreaAt:={}
Local aAreaTRB:={}

Private lMsErroAuto := .F.    
DEFAULT dDataTit := dDatabase  

If cPaisLoc $ "ARG|URU|BOL" 
	nGerDocFis := MV_PAR12
EndIf

// ******************Dados do Item*********************
DbSelectArea("SB1")  
SB1->( dbSetOrder(1) )
If DbSeek(xFilial("SB1")+MV_PAR11)
	cCodProd:=SB1->B1_COD
	cUndMed:=SB1->B1_UM
	cDep:=SB1->B1_LOCPAD
Else
	Help('',1,'FA074013')
	lGera := .F.
  	DisarmTransaction()
EndIF

If lGera
	// *********** Dados da TES *****************
	DbSelectArea("SF4")
	dbSetOrder(1)
	If SE1->E1_TIPO $ "NCC" .And. !Empty(SA1->A1_TESD)
			DbSeek(xFilial('SF4')+SA1->A1_TESD)
			cTES:= SA1->A1_TESD
			cCf:= SF4->F4_CF
				
	Elseif SE1->E1_TIPO $ "NDC" .And. !Empty(SA1->A1_TESC)
			DbSeek(xFilial('SF4')+SA1->A1_TESC)
			cCf:= SF4->F4_CF    
			cTES:= SA1->A1_TESC
			cGerNF:=  SF4->F4_DOCDIF
	Else
			Help('',1,'FA074015') 
			lGera:= .F.      // Se nao tiver TES configurada no fornecedor nใo deverแ ser gerado doc fiscal
			DisarmTransaction()
	EndIf
	
	
	If SF4->F4_DOCDIF <>"1" .And. SF4->F4_DUPLIC == "N"
		lGera:= .F.
	ElseIf SF4->F4_DOCDIF =="1" .And. SF4->F4_DUPLIC == "N"
		lGera:=.T.
	ElseIf SF4->F4_DOCDIF <>"1" .And. SF4->F4_DUPLIC == "S"
		lGera:=.F.
	ElseIf SF4->F4_DOCDIF =="1" .And. SF4->F4_DUPLIC == "S"
		lGera:=.T.
	EndIf   
EndIF	

If cPaisLoc=="ARG" .And. lGera
	aAreaAt:=GetArea()
	aAreaTRB:=TRB->(GetArea())
	TRB->(dbGoTo(aDadosOr[1][1]))
	cSerOri:= Subs(TRB->E1_PREFIXO,1, GetSx3Cache("E1_PREFIXO","X3_TAMANHO") )
	cNumOr:= Subs(TRB->E1_NUM,1, GetSx3Cache("E1_NUM","X3_TAMANHO"))
	cRG1415:= F074CODRG(SE1->E1_CLIENTE,SE1->E1_LOJA,cNumOr,cSerOri,SE1->E1_TIPO)
	TRB->(RestArea(aAreaTRB))
	RestArea(aAreaAt)
EndIf


// Documento Fiscal 
If SE1->E1_TIPO $ "NDC" .And. lGera
   	aAdd(aCab, {"F2_CLIENTE"		, SE1->E1_CLIENTE	,Nil}) //C๓digo Cliente
	aAdd(aCab, {"F2_LOJA"			, SE1->E1_LOJA		,Nil}) //Tienda Cliente
	aAdd(aCab, {"F2_SERIE"			, SE1->E1_PREFIXO	,Nil}) //Serie del documento
	aAdd(aCab, {"F2_DOC"			, SE1->E1_NUM		,Nil}) //N๚mero de documento		
	aAdd(aCab, {"F2_TIPO"			, "C"				,Nil}) //Tipo da nota (C=Credito / D=Debito)
	aAdd(aCab, {"F2_NATUREZ"		, ""				,Nil}) //Naturaleza (Financiero)
	aAdd(aCab, {"F2_ESPECIE"		, SE1->E1_TIPO		,Nil}) //Tipo de Documento para la tabla SF2 (RTS = Remito de Transferencia Salida)
	aAdd(aCab, {"F2_EMISSAO"		, dDatabase			,Nil}) //Fecha de Emisi๓n
	aAdd(aCab, {"F2_DTDIGIT"		, dDatabase			,Nil}) //Fecha de Digitaci๓n	
	aAdd(aCab, {"F2_MOEDA"			, SE1->E1_MOEDA		,Nil}) //Moneda
	aAdd(aCab, {"F2_TXMOEDA"		, 1					,Nil}) //Tasa de moneda						
	aAdd(aCab, {"F2_TIPODOC"		, "02"				,Nil}) //Tipo de documento (utilizado en la funci๓n LOCXNF)								
	aAdd(aCab, {"F2_FORMUL"			, "S" 				,Nil}) //Indica si se utiliza un Formulario Propio para el documento
	aAdd(aCab, {"F2_COND"			, nCondPad			,Nil}) //Condici๓n de pago												
	If cPaisloc == "ARG" 
	 	aAdd(aCab, {"F2_TPVENT"			, "1"		    	 ,Nil}) //Tipo de venda
	 	aAdd(aCab, {"F2_FECDSE"			, dDataTit			 ,Nil}) //Tipo de venda
		aAdd(aCab, {"F2_FECHSE"			, dDatabase			 ,Nil}) //Tipo de venda
		aAdd(aCab, {"F2_PV"				, cLocxNFPV			 ,Nil}) //Ponto de Venda
		aAdd(aCab, {"F2_RG1415"			, cRG1415		 	 ,Nil}) //Ponto de VendacRG1415	 	
	 	aAdd(aCab, {"F2_PROVENT"			,cProvent			 ,Nil})//	
	EndIf
			
	// Item 1
	aAdd(aItem, {"D2_COD"			, cCodProd				,Nil}) //C๓digo de producto
	aAdd(aItem, {"D2_UM"			, cUndMed				,Nil}) //Unidad de medida						
	aAdd(aItem, {"D2_QUANT"			, 1						,Nil}) //Cantidad
	aAdd(aItem, {"D2_PRCVEN"		, nTotDif*nSigno,Nil}) //Precio de Venta		
	aAdd(aItem, {"D2_TOTAL"			, nTotDif*nSigno,Nil}) //Total				
	aAdd(aItem, {"D2_TES"			, cTES					,Nil}) //TES						
	aAdd(aItem, {"D2_CF"			, cCf					,Nil})//C๓digo Fiscal (completar seg๚n TES)
	aAdd(aItem, {"D2_LOCAL"			, cDep					,Nil}) //Dep๓sito		
	
	If cPaisloc == "ARG"
		aAdd(aItem, {"D2_NFORI"			, cNumOr			,Nil})//C๓digo Fiscal (completar seg๚n TES)
		aAdd(aItem, {"D2_SERIORI"		, cSerOri					,Nil}) //Dep๓sito		
	EndIf

	aAdd(aLinea, aItem)
	aItem:={}  
	msExecAuto({|w,x,y,z| LocXNF(w,x,y,z)}, cTipo, aCab, aLinea, 3)			 			 
	If lMsErroAuto
		lRet := .F.
		MostraErro()
  		DisarmTransaction()
	EndIf
ElseIf SE1->E1_TIPO $ "NCC"  .And. lGera

	// Documento Fiscal 
	aAdd(aCab, {"F1_FORNECE"		, SE1->E1_CLIENTE,Nil}) //C๓digo Cliente
	aAdd(aCab, {"F1_LOJA"			, SE1->E1_LOJA   ,Nil}) //Tienda Cliente
	aAdd(aCab, {"F1_SERIE"			, SE1->E1_PREFIXO,Nil}) //Serie del documento
	aAdd(aCab, {"F1_DOC"			, SE1->E1_NUM    ,Nil}) //N๚mero de documento		
	aAdd(aCab, {"F1_TIPO"			, "D"		     ,Nil}) //Tipo da nota (C=Credito / D=Debito)
	aAdd(aCab, {"F1_NATUREZ"		, ""		     ,Nil}) //Naturaleza (Financiero)
	aAdd(aCab, {"F1_ESPECIE"		, SE1->E1_TIPO   ,Nil}) //Tipo de Documento 
	aAdd(aCab, {"F1_EMISSAO"		, dDatabase		 ,Nil}) //Fecha de Emisi๓n
	aAdd(aCab, {"F1_DTDIGIT"		, dDatabase		 ,Nil}) //Fecha de Digitaci๓n	
	aAdd(aCab, {"F1_MOEDA"			, 1				 ,Nil}) //Monูeda
	aAdd(aCab, {"F1_TXMOEDA"		, 1				 ,Nil}) //Tasa de moneda						
	aAdd(aCab, {"F1_TIPODOC"		, "04"			 ,Nil}) //Tipo de documento (utilizado en la funci๓n LOCXNF)								
	aAdd(aCab, {"F1_FORMUL"			, "S", 			 ,Nil}) //Indica si se utiliza un Formulario Propio para el documento
	aAdd(aCab, {"F1_COND"			, nCondPad			 ,Nil}) //Condici๓n de pago												
						
 	If cPaisloc == "ARG" 
	 	aAdd(aCab, {"F1_TPVENT"			, "S"			,Nil}) //Tipo de Venda	 
	 	aAdd(aCab, {"F1_FECDSE"			, dDataTit		,Nil}) //Tipo de venda
		aAdd(aCab, {"F1_FECHSE"			, dDatabase	    ,Nil}) //Tipo de venda
		aAdd(aCab, {"F1_PV"			, cLocxNFPV			 ,Nil}) //Ponto de Venda
		aAdd(aCab, {"F1_RG1415"			, cRG1415		 	 ,Nil}) //Ponto de VendacRG1415
		aAdd(aCab, {"F1_PROVENT"			,cProvent			 ,Nil})//	
	EndIf				
	// Item 1
    
	aAdd(aItem, {"D1_COD"			, cCodProd				,Nil}) //C๓digo de producto
	aAdd(aItem, {"D1_UM"			, cUndMed				,Nil}) //Unidad de medida						
	aAdd(aItem, {"D1_QUANT"			, 1						,Nil}) //Cantidad
	aAdd(aItem, {"D1_VUNIT"			, Abs(nTotDif)	,Nil}) //Precio de Venta 
	aAdd(aItem, {"D1_TOTAL"			, Abs(nTotDif)	,Nil}) //Total
	aAdd(aItem, {"D1_TES"			, cTES					,Nil}) //TES						
	aAdd(aItem, {"D1_CF"			, cCf					,Nil}) //C๓digo Fiscal (completar seg๚n TES)
	aAdd(aItem, {"D1_LOCAL"			, cDep					,Nil}) //Dep๓sito		
	
	If cPaisloc == "ARG"
		aAdd(aItem, {"D1_NFORI"			, cNumOr			,Nil})//C๓digo Fiscal (completar seg๚n TES)
		aAdd(aItem, {"D1_SERIORI"		, cSerOri					,Nil}) //Dep๓sito		
	EndIf
	
	aAdd(aLinea, aItem)
	aItem:={} 
	msExecAuto({|w,x,y,z| LocXNF(w,x,y,z)}, cTipo, aCab, aLinea, 3)			 
	If lMsErroAuto
		lRet := .F.
		MostraErro()
 		DisarmTransaction()
	EndIf
							
EndIf 

	
			 
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF084CancelNFบAutor  ณAna Paula Nascimentoบ Data ณ  18.03.10 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera documento fiscal no cancelamento da					  บฑฑ
ฑฑบ			 ณdiferen็a de cambios geradas     							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA084 e FINA085A                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F074CancelNF(cAlias)

Local aCab 			:= {} 	//Dados do cabe็alho
Local aItem 		:= {} 	//Dados do item
Local aLinea 		:= {} 	//Matriz que guarda la matriz aItem (requerido por la rutina)
Local nSigno  :=      Iif(SE1->E1_TIPO $MVRECANT+"/"+MV_CRNEG,-1,1)
Local cTipo:=  Iif(SE1->E1_TIPO == "NDC",04,02) // Grava a reversใo
Local aArea:=GetArea()
Local lGera := .T. 
Local cSerie:= SE1->E1_PREFIXO    
Local lRet := .T.    
Local cNum:= ""
Local cRG1415:= ""
Local nCondPad	:= SuperGetMV( "MV_CONDPAD")
Private lMsErroAuto:= .F.
Private cLocxNFPV:=""

DbSelectArea("SF4")
dbSetOrder(1)
If SE1->E1_TIPO $ "NDC" .And. !Empty(SA1->A1_TESD)
		DbSeek(xFilial('SF4')+SA1->A1_TESD)
		cTES:= SA1->A1_TESD
		cCf:= SF4->F4_CF
			
Elseif SE1->E1_TIPO $ "NCC" .And. !Empty(SA1->A1_TESC)
		DbSeek(xFilial('SF4')+SA1->A1_TESC)
		cCf:= SF4->F4_CF    
		cTES:= SA1->A1_TESC
Else
	Help('',1,'FA074014')
	lGera := .F.  // Se nao tiver TES configurada no fornecedor nใo deverแ ser gerado doc fiscal
  	DisarmTransaction()
EndIf 
       
If lGera
		If SF4->F4_DOCDIF <>"1" .And. SF4->F4_DUPLIC == "N"
		lGera:= .F.
	ElseIf SF4->F4_DOCDIF =="1" .And. SF4->F4_DUPLIC == "N"
		lGera:=.T.
	ElseIf SF4->F4_DOCDIF <>"1" .And. SF4->F4_DUPLIC == "S"
		lGera:=.F.
	ElseIf SF4->F4_DOCDIF =="1" .And. SF4->F4_DUPLIC == "S"
		lGera:=.T.
	EndIf   
	If cAlias == "SF1"
		DbSelectArea("SD1")
		dbSetOrder(1)
		DbSeek(xFilial("SD1")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA)
		cCodProd:= SD1->D1_COD
		cUndMed:=SD1->D1_UM
		cDep :=SD1->D1_LOCAL
		cSerOri:=SD1->D1_SERIORI
		cNumOri:=SD1->D1_NFORI
	Else
		DbSelectArea("SD2")
		dbSetOrder(3)
		DbSeek(xFilial("SD2")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA)
		cCodProd:= SD2->D2_COD
		cUndMed:=SD2->D2_UM
		cDep :=SD2->D2_LOCAL
		cSerOri:=SD2->D2_SERIORI
		cNumOri:=SD2->D2_NFORI
	EndIf
	
	cTipoDoc:=Iif(SE1->E1_TIPO$"NCC","NDC","NCC" )
	
	cIdPDV:=""
	
	If cPaisLoc=="ARG"
		cLocxNFPV := Subs(SE1->E1_NUM,1,GetSx3Cache("F1_PV","X3_TAMANHO"))
		Apv := F074VldPv(cTipoDoc,cLocxNFPV)
		If Len(Apv)>1
			cSerie :=Apv[1]
			cIdPV:=Apv[2]
		EndIf
	EndIf
	
	If ExistBlock("F074CaSe")
		cSerie:= ExecBlock("F074CaSe",.F.,.F.,{cTipoDoc,SE1->E1_CLIENTE,SE1->E1_LOJA})
	EndIf
	
	If cPaisloc $ "ARG"  .and. Empty(cSerie)
		cSerie := LocXTipSer("SA1",cTipoDoc)
	EndIf
	
	
	cPesquisa:=cSerie
	
	If cPaisLoc=="ARG"
		cPesquisa:=AllTrim(cSerie)+cIdPDV
	EndIf
	
	   F74ValidNum(cPesquisa,@cNum,cTipoDoc,.T.)

EndIf	
//paulo
 // Caso esteja cancelando debito serแ gerado um credito e vice versa. Nota de Reversใo.        

If Alltrim(SE1->E1_TIPO) $ "NCC" .And. lGera
	
	
   	aAdd(aCab, {"F2_CLIENTE"		, SE1->E1_CLIENTE	,Nil}) //C๓digo Cliente
	aAdd(aCab, {"F2_LOJA"			, SE1->E1_LOJA		,Nil}) //Tienda Cliente
	aAdd(aCab, {"F2_SERIE"			, cSerie			,Nil}) //Serie del documento
	aAdd(aCab, {"F2_DOC"			, cNum	  			,Nil}) //N๚mero de documento		
	aAdd(aCab, {"F2_TIPO"			, "C"				,Nil}) //Tipo da nota (C=Credito / D=Debito)
	aAdd(aCab, {"F2_NATUREZ"		, ""				,Nil}) //Naturaleza (Financiero)
	aAdd(aCab, {"F2_ESPECIE"		, "NDC"	  			,Nil}) //Tipo de Documento para la tabla SF2 (RTS = Remito de Transferencia Salida)
	aAdd(aCab, {"F2_EMISSAO"		, dDatabase			,Nil}) //Fecha de Emisi๓n
	aAdd(aCab, {"F2_DTDIGIT"		, dDatabase			,Nil}) //Fecha de Digitaci๓n	
	aAdd(aCab, {"F2_MOEDA"			, 1					,Nil}) //Moneda
	aAdd(aCab, {"F2_TXMOEDA"		, 1					,Nil}) //Tasa de moneda						
	aAdd(aCab, {"F2_TIPODOC"		, "02"				,Nil}) //Tipo de documento (utilizado en la funci๓n LOCXNF)								
	aAdd(aCab, {"F2_FORMUL"			, "S" 				,Nil}) //Indica si se utiliza un Formulario Propio para el documento
	aAdd(aCab, {"F2_COND"			, nCondPad			,Nil}) //Condici๓n de pago						
	If cPaisloc == "ARG" 
		cRG1415:= F074CODRG(,,,cSerie ,"NDC",SF1->F1_RG1415)
	 	aAdd(aCab, {"F2_TPVENT"			, "1"		    	 ,Nil}) //Tipo de venda	
	 	aAdd(aCab, {"F2_FECDSE"			, SE1->E1_EMISSAO	 ,Nil}) //Tipo de venda
		aAdd(aCab, {"F2_FECHSE"			, dDatabase			 ,Nil}) //Tipo de venda
		aAdd(aCab, {"F2_PROVENT"		,SF1->F1_PROVENT	 ,Nil})//
		aAdd(aCab, {"F2_PV"				, cLocxNFPV			 ,Nil}) //Ponto de Venda
		aAdd(aCab, {"F2_RG1415"			, cRG1415		 	 ,Nil}) //Ponto de VendacRG1415	 	
	EndIf
	// Item 1
	aAdd(aItem, {"D2_COD"			, cCodProd				,Nil}) //C๓digo de producto
	aAdd(aItem, {"D2_UM"			, cUndMed				,Nil}) //Unidad de medida						
	aAdd(aItem, {"D2_QUANT"			, 1						,Nil}) //Cantidad
	aAdd(aItem, {"D2_PRCVEN"		, SE1->E1_VALOR			,Nil}) //Precio de Venta		
	aAdd(aItem, {"D2_TOTAL"			, SE1->E1_VALOR			,Nil}) //Total				
	aAdd(aItem, {"D2_TES"			, cTES					,Nil}) //TES						
	aAdd(aItem, {"D2_CF"			, cCf					,Nil})//C๓digo Fiscal (completar seg๚n TES)
	aAdd(aItem, {"D2_LOCAL"			, cDep					,Nil}) //Dep๓sito	
	If cPaisLoc=="ARG"
		aAdd(aItem, {"D2_SERIORI"		, cSerOri			,Nil})//C๓digo Fiscal (completar seg๚n TES)
		aAdd(aItem, {"D2_NFORI"			, cNumOri			,Nil}) //Dep๓sito	
	EndIf
		
	aAdd(aLinea, aItem)
	aItem:={}  
	msExecAuto({|w,x,y,z| LocXNF(w,x,y,z)}, cTipo, aCab, aLinea, 3)			 
	If lMsErroAuto
		lRet := .F.
		MostraErro()
  		DisarmTransaction()
   //	Else
	//	Alert("OK")		 
	EndIf
ElseIf Alltrim(SE1->E1_TIPO) $ "NDC" .And. lGera

	// Documento Fiscal 
	aAdd(aCab, {"F1_FORNECE"		, SE1->E1_CLIENTE,Nil}) //C๓digo Cliente
	aAdd(aCab, {"F1_LOJA"			, SE1->E1_LOJA   ,Nil}) //Tienda Cliente
	aAdd(aCab, {"F1_SERIE"			, cSerie         ,Nil}) //Serie del documento
	aAdd(aCab, {"F1_DOC"			, cNum   		 ,Nil}) //N๚mero de documento		
	aAdd(aCab, {"F1_TIPO"			, "D"		     ,Nil}) //Tipo da nota (C=Credito / D=Debito)
	aAdd(aCab, {"F1_NATUREZ"		, ""		     ,Nil}) //Naturaleza (Financiero)
	aAdd(aCab, {"F1_ESPECIE"		, "NCC"   		 ,Nil}) //Tipo de Documento 
	aAdd(aCab, {"F1_EMISSAO"		, dDatabase		 ,Nil}) //Fecha de Emisi๓n
	aAdd(aCab, {"F1_DTDIGIT"		, dDatabase		 ,Nil}) //Fecha de Digitaci๓n	
	aAdd(aCab, {"F1_MOEDA"			, 1				 ,Nil}) //Moneda
	aAdd(aCab, {"F1_TXMOEDA"		, 1				 ,Nil}) //Tasa de moneda						
	aAdd(aCab, {"F1_TIPODOC"		, "04"			 ,Nil}) //Tipo de documento (utilizado en la funci๓n LOCXNF)								
	aAdd(aCab, {"F1_FORMUL"			, "S", 			 ,Nil}) //Indica si se utiliza un Formulario Propio para el documento
	aAdd(aCab, {"F1_COND"			, nCondPad		 ,Nil}) //Condici๓n de pago						
	If cPaisloc == "ARG" 
		cRG1415:= F074CODRG(,,,cSerie ,"NCC",SF2->F2_RG1415)
	 	aAdd(aCab, {"F1_TPVENT"			, "S"			 	,Nil}) //Tipo de venda	
	 	aAdd(aCab, {"F1_FECDSE"			, SE1->E1_EMISSAO	,Nil}) //Tipo de venda
		aAdd(aCab, {"F1_FECHSE"			, dDatabase			,Nil}) //Tipo de venda
		aAdd(aCab, {"F1_PROVENT"		,SF2->F2_PROVENT 	,Nil})//	
		aAdd(aCab, {"F1_PV"				, cLocxNFPV			,Nil}) //Ponto de Venda
		aAdd(aCab, {"F1_RG1415"			, cRG1415		 	,Nil}) //Ponto de VendacRG1415	 	
	EndIf
    
	aAdd(aItem, {"D1_COD"			, cCodProd				,Nil}) //C๓digo de producto
	aAdd(aItem, {"D1_UM"			, cUndMed				,Nil}) //Unidad de medida						
	aAdd(aItem, {"D1_QUANT"			, 1						,Nil}) //Cantidad
	aAdd(aItem, {"D1_VUNIT"			, SE1->E1_VALOR			,Nil}) //Precio de Venta		
	aAdd(aItem, {"D1_TOTAL"			, SE1->E1_VALOR			,Nil}) //Total				
	aAdd(aItem, {"D1_TES"			, cTES					,Nil}) //TES						
	aAdd(aItem, {"D1_CF"			, cCf					,Nil}) //C๓digo Fiscal (completar seg๚n TES)
	aAdd(aItem, {"D1_LOCAL"			, cDep					,Nil}) //Dep๓sito		
	If cPaisLoc=="ARG"
		aAdd(aItem, {"D1_SERIORI"		, cSerOri			,Nil})//C๓digo Fiscal (completar seg๚n TES)
		aAdd(aItem, {"D1_NFORI"			, cNumOri			,Nil}) //Dep๓sito	
	EndIf
	
	aAdd(aLinea, aItem)
	aItem:={} 
	msExecAuto({|w,x,y,z| LocXNF(w,x,y,z)}, cTipo, aCab, aLinea, 3)			 
	If lMsErroAuto
		lRet := .F.
		MostraErro()
 		DisarmTransaction()
	EndIf
							
EndIf 

RestArea(aArea)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF74ValidNumบAutor  ณAna Paula Nascimentoบ Data ณ  01.06.11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida numera็ใo											  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA074 												      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F74ValidNum(cPrefixo,cNum,cTipoDoc,lCancel)
Local lRet := .T.
Local aAreaSE1 := SE1->(GetArea())	


If lCancel
	aRetSX5:={}
	aRetSX5:=FWGetSX5( "01",cPrefixo) 
	cNum := Substr(aretsx5[1][4],1,GetSx3Cache('E1_NUM',"X3_TAMANHO"))
EndIf

// Verifica se ja existe algum documento com a mesma numera็ใo no contas a receber
DbSelectArea("SE1")
DbSetOrder( 1 )
While SE1->(!Eof()) .And. lRet
	If  DbSeek( xFilial("SE1")+cPrefixo+cNum+Space(GetSx3Cache('E1_PARCELA',"X3_TAMANHO"))+cTipoDoc)
		cSx5Num:=Soma1(cNum)
		FWPutSX5(,"01",cPrefixo,cSx5Num,cSx5Num,cSx5Num,cSx5Num)
		aRetSX5:={}
		aRetSX5:=FWGetSX5( "01",cPrefixo) 
		cNum := Substr(aretsx5[1][4],1,GetSx3Cache('E1_NUM',"X3_TAMANHO"))
	Else
		lRet := .F.
	EndIf		                                                 
	SE1->(DbSkip())
EndDo

// Valida o numero no sx5 utilizando a mesma valida็ใo que ้ feita no momento de emitir o documento
// pelo modulo de faturamento
While !VldSX5Num(cNum,cPrefixo,.F.)
		cSx5Num:=Soma1(cNum)
		FWPutSX5(,"01",cPrefixo,cSx5Num,cSx5Num,cSx5Num,cSx5Num)
		aRetSX5:={}
		aRetSX5:=FWGetSX5( "01",cPrefixo ) 	
		cNum := Substr(aretsx5[1][4],1,GetSx3Cache('E1_NUM',"X3_TAMANHO"))
EndDo		

RestArea(aAreaSE1)

Return cNum

/***************************************************************
FUNCAO 	| FA074EXLOG
AUTOR		| Pedro Pereira Lima
USO		| Grava็ใo de log da gera็ใo de diferenca de 
			| cambio por lote quando, substituindo o help FA074012
***************************************************************/
Function FA074EXLOG(aChaveLot)
Local cTexto	:= ""                       
Local cFile		:= ""
Local nX			:= 0                                                              
Local nPos		:= 0

If Len(aChavelot) > 0
	cTexto += STR0053 + CRLF + STR0054 + CRLF + STR0055 + CRLF + STR0056 + CRLF
	cTexto += "--------------------------------------------------------" + CRLF 
	
	For nX := 1 To Len(aChaveLot)
		nPos := 1
		cTexto += SubStr(aChaveLot[nX],nPos,GetSx3Cache("E1_CLIENTE","X3_TAMANHO"))
		cTexto += Space(4)
		nPos += GetSx3Cache("E1_CLIENTE","X3_TAMANHO")
		cTexto += SubStr(aChaveLot[nX],nPos,GetSx3Cache("E1_LOJA","X3_TAMANHO"))
		cTexto += Space(5)                 
		nPos += GetSx3Cache("E1_LOJA","X3_TAMANHO")                                     
		cTexto += SubStr(aChaveLot[nX],nPos,GetSx3Cache("E1_PREFIXO","X3_TAMANHO"))
		cTexto += Space(7)                                         
		nPos += GetSx3Cache("E1_PREFIXO","X3_TAMANHO")            
		cTexto += SubStr(aChaveLot[nX],nPos,GetSx3Cache("E1_NUM","X3_TAMANHO"))
		cTexto += Space(3)                  
		nPos += GetSx3Cache("E1_NUM","X3_TAMANHO")                              
		cTexto += SubStr(aChaveLot[nX],nPos,GetSx3Cache("E1_PARCELA","X3_TAMANHO"))
		cTexto += Space(9)                  
		nPos += GetSx3Cache("E1_PARCELA","X3_TAMANHO")
		cTexto += SubStr(aChaveLot[nX],nPos,GetSx3Cache("E1_TIPO","X3_TAMANHO"))
		cTexto += CRLF
	Next nX
	
	DEFINE FONT oFont NAME "Mono AS" SIZE 5,12
	DEFINE MSDIALOG oDlg TITLE "FA074012" From 3,0 to 340,417 PIXEL
	
	@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
	oMemo:bRClicked	:= {||AllwaysTrue()}
	oMemo:oFont			:= oFont
	
	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL 
	DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(STR0057,""),If(cFile="",.T.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL
	
	ACTIVATE MSDIALOG oDlg CENTER
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF074VDLPV บAutor  ณMarivaldo           บ Data ณ  19.07.18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida Ponto de Venda       							       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA074 						       						    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function F074VldPv(cTipoDoc,cLocxNFPV)

Local cPrefixo := ""
//Local cPDVDIFC := GetNewPar("AR_PDVDIFC","0001")//Punto de venta para diferencia de cambio
Local cPDVDIFC := ""
Local cTexto := ""
Local cIdPDV := ""
Local nPosIni:= 0
Local cCombo:= ""
Local aRet:={}
Default cLocxNFPV:=""
Default cTipoDoc := ""

cPDVDIFC := cLocxNFPV
cPrefixo := LocXTipSer("SA1",cTipoDoc)
   
If !empty(cPDVDIFC)

   cIdPDV:= POSICIONE("CFH",1, xFilial("CFH")+cPDVDIFC,"CFH_IDPV")
   
   IF Empty(cIdPDV)
   	
      cTexto:="El punto de venta '"+cPDVDIFC+"' configurado en el parแmetro 'AR_PDVDIFC' no existe."+CHR(13)
      cTexto+="Si el parametro 'AR_PDVDIFC' no existe, entonces deberแ crearlo."
      MSGINFO(cTexto,"Diferencia de cambio")
   Else 
		// Busca pos. da descricao da especie da nota no combo da tabela SFP (1=NF;2=NCI;3=NDI;4=NCC;5=NDC)
		SX3->(dbSetOrder(2))
		SX3->(MsSeek("FP_ESPECIE"))
		nPosIni := At(AllTrim(cTipoDoc),AllTrim(SX3->X3_CBOX))
		cCombo := Substr(AllTrim(SX3->X3_CBOX),nPosIni-2,1)
		
        //Buscamos en tabla SFP para determinar cual serie de SX5 le corresponde
		("SFP")->(DbSetOrder(9))
		If ("SFP")->(MsSeek(xFilial("SFP")+cPDVDIFC))
			While (SFP->(!EOF())) .And. (SFP->FP_PV = cPDVDIFC) 
			    If AllTrim(SFP->FP_ESPECIE) == AllTrim(cCombo) .AND. Left(SFP->FP_SERIE,1) $ cPrefixo
				   cPrefixo:=SFP->FP_SERIE
				   Exit
				ENDIF
				SFP->( DBSkip() )
			EndDo
		EndIf      
      //Devolvemos serie de SFP + IDPDV de 3 caracteres para buscar en tabla SX5 ejemplo 'AE001'
	   		aRet:={cPrefixo,cIdPDV}
   EndIf   
Endif
Return (aRet)


//Gera Codigo da RG1415
Function F074CODRG(cCli,cLoja,cNum,cSer,cTipo,cCFO)

Local aReaAtu:=GetArea()
Local aAreaSF2:= SF2->(GetArea())
Local cRg1415 :=""
Local cRet:=" " 
Local cSerie:= Subs(cSer,1,1)
Default cCli :=""
Default cLoja :=""
Default cNum :=""
Default cSer :=""
Default cTipo :=""
Default cCFO:=""

SF2->(DbSetOrder(2))
If  !Empty(cCFO)  .Or.     SF2->(MsSeek(xFilial("SF2")+cCli+cLoja+cNum+cSer) ) 
	
	If !Empty(cCFO)
		cRg1415:=cCFO
	Else
	cRg1415:= SF2->F2_RG1415
	EndIf
	//NDCs
	If cTipo=="NDC"
		If Val(cRg1415) < 200
		 	If cSerie == "A"
		 		cRet:=	StrZero(2,GetSx3Cache("F2_RG1415" ,"X3_TAMANHO"))
		 	ElseIf cSerie == "B"
		 		cRet:=	StrZero(7,GetSx3Cache("F2_RG1415" ,"X3_TAMANHO"))
		 	Else
		 		cRet:=StrZero(12,GetSx3Cache("F2_RG1415" ,"X3_TAMANHO"))
		 	EndIf
		 Else
		 	If cSerie == "A"
		 		cRet:=	"202"
		 	ElseIf cSerie == "B"
		 		cRet:="207"
		 	Else
		 		cRet:="212"
		 	EndIf
		 EndIf	
	ElseIf cTipo=="NCC"
		If Val(cRg1415) < 200
		 	If cSerie == "A"
		 		cRet:=	StrZero(3,GetSx3Cache("F2_RG1415" ,"X3_TAMANHO"))
		 	ElseIf cSerie == "B"
		 		cRet:=StrZero(8,GetSx3Cache("F2_RG1415" ,"X3_TAMANHO"))
		 	Else
		 		cRet:=StrZero(13,GetSx3Cache("F2_RG1415" ,"X3_TAMANHO"))
		 	EndIf
		 Else
		 	If cSerie == "A"
		 		cRet:= "203"
		 	ElseIf cSerie == "B"
		 		cRet:="208"
		 	Else
		 		cRet:="213"
		 	EndIf
		 EndIf	
	EndIf
Else
	If cTipo=="NDC"
	 	If cSerie == "A"
	 		cRet:=	StrZero(2,GetSx3Cache("F2_RG1415" ,"X3_TAMANHO"))
	 	ElseIf cSerie == "B"
	 		cRet:=	StrZero(7,GetSx3Cache("F2_RG1415" ,"X3_TAMANHO"))
	 	Else
	 		cRet:=StrZero(12,GetSx3Cache("F2_RG1415" ,"X3_TAMANHO"))
	 	EndIf
	ElseIf cTipo=="NCC"
		 If cSerie == "A"
		 	cRet:=	StrZero(3,GetSx3Cache("F2_RG1415" ,"X3_TAMANHO"))
		 ElseIf cSerie == "B"
		 	cRet:=StrZero(8,GetSx3Cache("F2_RG1415" ,"X3_TAMANHO"))
		 Else
		 	cRet:=StrZero(13,GetSx3Cache("F2_RG1415" ,"X3_TAMANHO"))
		 EndIf	
	EndIf
EndIf	
SF2->(RestArea(aAreaSF2))
RestArea(aReaAtu)
Return(cRet)
