#INCLUDE "ofiom190.ch"
#Include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ OFIOM190 ณ Autor ณ  Emilton              ณ Data ณ 08/02/00 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Liberacao e Movimentacao de Veiculo entre boxes            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณObservacaoณ As tratativas das variaveis VOK_INCMOB/VOK_INCTEM estao    ณฑฑ
ฑฑณ          ณ desmembradas apenas para documentar e facilitar a analise eณฑฑ
ฑฑณ          ณ eventuais implementacoes, caso passe a ser necessario      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOM190
Private cIndVON, cChave, cCond
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0004) //"Liberacao de Veiculos/Box & Transferencia de Veiculo p/Novo Box"
Private cKeyAce   := ""
Private cBoxAtu   := ""
Private nIndVON   := 0
Private lPassou   := .f.
Private lAchou    := .f.

FS_PCHA190( "S" )
dbSelectArea("VON")
mBrowse( 6, 1,22,75,"VON")
FS_PCHA190( "N" )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIOM190L บAutor  ณFabio / Emilton     บ Data ณ  09/21/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tela                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOM190L(cAlias, nReg, nOpc)
Local bCampo   := { |nCPO| Field(nCPO) }
Local oSitOsv , nCntFor := 0

If xFilial("VON") # VON->VON_FILIAL .or. (VON->(EOF()) .and. VON->(BOF()))
	HELP(" ",1,"ARQVAZIO")
	Return .F.
EndIf
if lAchou    := .f.	
   lAchou    := .t.	
	If !FS_FILBOX("O",VON->VON_NUMBOX,,1)
		Aviso(STR0005,STR0006,{STR0007}) //"Atencao"###"Este BOX esta vazio, impossivel a transferencia de veiculos"###"ok"
		
		DbSelectArea("VON")
		//	dbSetOrder(nIndVON+1)
		
		Return .f.
	
	EndIf
Endif
Private aTELA[0][0], aGETS[0], oDlgLibBox, cTitle
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private aCpoEnchoice := {} , aSitOsv := {} , cBoxAtu , cLinOk , cTudOOk , cFieldOk , nLinhas := 0 , aPos := {}

cTitle := OemToAnsi(STR0004) //"Liberacao de Veiculos/Box & Transferencia de Veiculo p/Novo Box"

If nOpc == 2
	nOpcE  := 2     // Visualizar
	nOpcG  := 2     // Visualizar
	cTitle := OemToAnsi(STR0008) //"Liberacao de Veiculos/Box"
Else
	nOpcE  := 3     // Incluir/Alterar (especial para este programa)
	nOpcG  := 2     // Visualizar
	cTitle := OemToAnsi(STR0009) //"Transferencia de Veiculo p/Outro Box"
EndIf

//Cria Variaveis M->????? da Enchoice

RegToMemory("VON",.T.)
DbSelectArea("VON")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

dbSelectArea("SX3")
dbSeek("VON")
aCpoEnchoice := {}

while x3_arquivo == "VON" .and. !eof()
	
	If X3USO(x3_usado) .and. cNivel>=x3_nivel  // .and. !(X3_CAMPO $ "VOF_FILIAL/VOF_SITPRO/VOF_FUNPRO/VOF_SITPRO")
		
		If nOpc == 2
			
			If X3_CAMPO != "VON_NOVBOX"
				
				aAdd(aCpoEnchoice,x3_campo)
				&( "M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
				
			EndIf
			
		Else
			
			If !(X3_CAMPO $ "VON_DATSAI/VON_HORSAI")
				
				aAdd(aCpoEnchoice,x3_campo)
				&( "M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
				
			EndIf
			
		EndIf
		
	EndIf
	
	dbSkip()
	
EndDo

DbSelectArea("VON")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

aSitOsv := {}
cBoxAtu := VON->VON_NUMBOX

If !FS_SAIVEI190(nOpc)
	
	cCadastro := OemToAnsi(STR0004) //"Liberacao de Veiculos/Box & Transferencia de Veiculo p/Novo Box"
	DbSelectArea("VON")
	//	dbSetOrder(nIndVON+1)
	
	Return .t.
	
EndIf

cFieldOk   := "AllwaysTrue()"
cLinOk     := "AllwaysTrue()"
cTudOOk    := "FS_NOVBOX(1)"
nLinhas    := 99
aPos       := { 012,002,191,316 }

dbSelectArea("VON")
dbSetOrder(1)

if len(aSitOsv) <= 0
	aAdd(aSitOsv,{"","","",0,"00:00","00:00","0,00"})
endif

DEFINE MSDIALOG oDlgLibBox FROM 001,000 TO 035,080 TITLE cTitle OF oMainWnd

ox :=EnChoice("VON", nReg, nOpc, , , ,aCpoEnchoice, aPos,{"VON_NOVBOX"},3,,,,,,.F.)

@ 195,003 LISTBOX oSitOsv FIELDS HEADER OemToAnsi(STR0010),; //"TT"
OemToAnsi(STR0011),; //"CodCli"
OemToAnsi(STR0012),; //"Nome do Cliente"
OemToAnsi(STR0013),; //"Tt Pecas"
OemToAnsi(STR0014),; //"Hrs Padrao"
OemToAnsi(STR0015),; //"Hrs Trab."
OemToAnsi(STR0016);  //"Tt Srvcs"
COLSIZES 10,25,95,45,35,35,45;
SIZE 312,061 OF oDlgLibBox PIXEL

oSitOsv:SetArray(aSitOsv)
oSitOsv:bLine := { || { aSitOsv[oSitOsv:nAt,1] ,;
aSitOsv[oSitOsv:nAt,2] ,;
aSitOsv[oSitOsv:nAt,3] ,;
Transform(aSitOsv[oSitOsv:nAt,4],"@ez 999,999,999.99") ,;
aSitOsv[oSitOsv:nAt,5] ,;
aSitOsv[oSitOsv:nAt,6] ,;
aSitOsv[oSitOsv:nAt,7]}}
// Quando clicar em OK              Quando Clicar no Chizim

//ACTIVATE MSDIALOG oDlgLibBox CENTER ON INIT (FS_CHBAR190(oDlgLibBox,{|| If(FS_OM190GRA(nOpc),(nOpca := 1,oDlgLibBox:End()),nOpca := 0) } , { || nOpca := 0,oDlgLibBox:End()}))
ACTIVATE MSDIALOG oDlgLibBox CENTER ON INIT (EnchoiceBar(oDlgLibBox,{|| If(FS_OM190GRA(nOpc),(nOpca := 1,oDlgLibBox:End()),nOpca := 0) } , { || nOpca := 0,oDlgLibBox:End()}))

DbSelectArea("VON")
//DbSetOrder(nIndVON+1)
lAchou    := .f.
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_OM190GRบAutor  ณFabio / Emilton     บ Data ณ  09/21/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_OM190GRA(nOpc)
Local cNumOsv

Begin Transaction

If nOpc == 2                        // Saida do Veiculo / Liberacao do Veiculo
	
	// Marca Box
	FG_MARCABOX(cBoxAtu,,,,.t.)
	
Else                                // Mudanca de box
	
	dbSelectArea("VO1")
	
	If !Empty(M->VON_NOVBOX)
		
		If FG_SEEK("VON","cBoxAtu",1,.f.)
			
			If FG_SEEK("VOF","VON->VON_NUMBOX",1,.f.)
				
				cNumOsv := VOF->VOF_NUMOSV
				If &cTudOOk
					// Marca Box
					FG_MARCABOX(cBoxAtu,,,cNumOsv,.t.)
					
					// Box Novo
					FG_MARCABOX(M->VON_NOVBOX,,,cNumOsv)
				EndIf
				
			EndIf
			
		EndIf
	Else
		Return .f.
		
	EndIf
	
EndIf

dbSelectArea("VON")

End Transaction

FS_PCHA190( "N" )
FS_PCHA190( "S" )

Return(.t.)

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFS_CHBAR190 ณ Autor ณ Fabio                 ณ Data ณ 12/09/99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Poe a enchoicebar na tela                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_CHBAR190(oDlg,bOk,bCancel)
Local oBar, bSet6, bSet15, bSet24, lOk, oBtOk, oBtCan
Local lVolta :=.f.

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

DEFINE BUTTON RESOURCE "S4WB005N" OF oBar       ACTION NaoDisp()     TOOLTIP OemToAnsi(STR0017)  // //"Recortar"
DEFINE BUTTON RESOURCE "S4WB006N" OF oBar       ACTION NaoDisp()     TOOLTIP OemToAnsi(STR0018)  // //"Copiar"
DEFINE BUTTON RESOURCE "S4WB007N" OF oBar       ACTION NaoDisp()     TOOLTIP OemToAnsi(STR0019)  // //"Colar"
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP OemToAnsi(STR0020)  // //"Calculadora..."
DEFINE BUTTON RESOURCE "S4WB009N" OF oBar       ACTION Agenda()      TOOLTIP OemToAnsi(STR0021)  // //"Agenda..."
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar       ACTION OurSpool()    TOOLTIP OemToAnsi(STR0022)  //"Gerenciador de Impressฦo..." //"Gerenciador de Impressao..."
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar       ACTION HelProg()     TOOLTIP OemToAnsi(STR0023)  // //"Help de Programa..."

oBar:nGroups += 6
DEFINE BUTTON oBtOk RESOURCE "Ok" OF oBar GROUP ACTION ( lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP STR0024  //###"Ok - <Ctrl-O>" //"Ok - <Ctl-O>"
SetKEY(15,oBtOk:bAction)
DEFINE BUTTON oBtCan RESOURCE "Cancel" OF oBar ACTION ( lLoop:=.f.,Eval(bCancel),ButtonOff(bSet6,bSet15,bSet24,.T.)) TOOLTIP STR0025  //### //"Cancelar - <Ctrl-X>"
SetKEY(24,oBtCan:bAction)

oDlg:bSet15 := oBtOk:bAction
oDlg:bSet24 := oBtCan:bAction
oBar:bRClicked := {|| AllwaysTrue()}

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณButtonOff บAutor  ณFabio / Emilton     บ Data ณ  09/21/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณButtonOff                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ButtonOff(bSet6,bSet15,bSet24,lOk)
DEFAULT lOk := .t.

If lOk
	SetKey(6,bSet6)
	SetKey(15,bSet15)
	SetKey(24,bSet24)
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SAIVEI1บAutor  ณFabio / Emilton     บ Data ณ  09/21/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_SAIVEI190(nOpc)
Local cTTpAnt := ""
Local nTotPec := 0
Local nHorPad := 0
Local nHorTra := 0
Local nValPec := 0
Local nTotSrv := 0
Local nTotTTp := 0
Local ix1     := 0
Local aCodSer := {}
Local aTemTra := {}

dbSelectArea("VO2")

If FG_SEEK("VOF","VON->VON_NUMBOX",1,.f.)
	
	If FG_SEEK("VO1","VOF->VOF_NUMOSV",1,.f.)
		
		If FG_SEEK("VO2","VO1->VO1_NUMOSV",1,.f.)
			
			While VO1->VO1_NUMOSV == VO2->VO2_NUMOSV .and. !eof() .And. VO2->VO2_FILIAL == xFilial("VO2")
				
				Do Case
					Case VO2->VO2_TIPREQ == "P"     // Requisicao de Pecas
						
						dbSelectArea("VO3")
						FG_SEEK("VO3","VO2->VO2_NOSNUM",1,.f.)
						
						cTTpAnt := VO3->VO3_TIPTEM
						
						While VO2->VO2_NOSNUM == VO3->VO3_NOSNUM .and. !eof() .And. VO3->VO3_FILIAL == xFilial("VO3")
							
							nValPec := 0
							
							FG_SEEK("VOI","VO3->VO3_TIPTEM",1,.f.)
							FG_SEEK("SA1","VO3->VO3_FATPAR+VO3->VO3_LOJA",1,.f.)
							FG_SEEK("SBM","VO3->VO3_GRUITE",1,.f.)
							FG_SEEK("VE4","SBM->BM_CODMAR",1,.f.)
							
							If VOI->VOI_VLPCAC == "1"
								nValPec := VO3->VO3_VALPEC
							Else
								nValPec := FG_VALPEC(VO3->VO3_TIPTEM,"VO3->VO3_FORMUL",VO3->VO3_GRUITE,VO3->VO3_CODITE,,.f.,.t.)
							EndIf
							
							If VO2->VO2_DEVOLU == "0"   // Devolucao de Pecas
								
								ix1 := aScan(aSitOsv,{|x| x[1] == VO3->VO3_TIPTEM})
								//
								If ix1 == 0
									nTotPec -= nValPec * VO3->VO3_QTDREQ
									aAdd(aSitOsv,{VO3->VO3_TIPTEM,VO3->VO3_FATPAR,SA1->A1_NREDUZ,nTotPec,Transform(0,"@R 99999999:99"),Transform(0,"@R 99999999:99"),Transform(0,"@ez 99999999,999.99")})
								Else
									nValPec := VO3->VO3_VALPEC
									nTotPec := aSitOsv[ix1,04]
									nTotPec -= nValPec * VO3->VO3_QTDREQ
									aSitOsv[ix1] := {VO3->VO3_TIPTEM,VO3->VO3_FATPAR,SA1->A1_NREDUZ,nTotPec,aSitOsv[ix1,05],aSitOsv[ix1,06],aSitOsv[ix1,07]}
								endif
								//
								DbSelectArea("VO2")
								dbSkip()
								Loop
								
							EndIf
							
							dbSelectArea("VO3")
							
							ix1 := aScan(aSitOsv,{|x| x[1] == VO3->VO3_TIPTEM})
							
							If ix1 == 0
								
								nTotPec += nValPec * VO3->VO3_QTDREQ
								aAdd(aSitOsv,{VO3->VO3_TIPTEM,VO3->VO3_FATPAR,SA1->A1_NREDUZ,nTotPec,Transform(0,"@R 99999999:99"),Transform(0,"@R 99999999:99"),Transform(0,"@ez 99999999,999.99")})
								
							Else
								
								nTotPec := aSitOsv[ix1,04]
								nTotPec += nValPec * VO3->VO3_QTDREQ
								aSitOsv[ix1] := {VO3->VO3_TIPTEM,VO3->VO3_FATPAR,SA1->A1_NREDUZ,nTotPec,aSitOsv[ix1,05],aSitOsv[ix1,06],aSitOsv[ix1,07]}
								
							EndIf
							
							dbskip()
							
						EndDo
						
					Case VO2->VO2_TIPREQ == "S"     // Requisicao de Servicos
						
						dbSelectArea("VO4")
						FG_SEEK("VO4","VO2->VO2_NOSNUM",1,.f.)
						
						cTTpAnt := VO4->VO4_TIPTEM
						
						While VO2->VO2_NOSNUM == VO4->VO4_NOSNUM .and. !eof() .And. VO4->VO4_FILIAL == xFilial("VO4")
							
							FG_SEEK("VOI","VO4->VO4_TIPTEM",1,.f.)
							FG_SEEK("SA1","VO4->VO4_FATPAR+VO4->VO4_LOJA",1,.f.)
							FG_SEEK("VOK","VO4->VO4_TIPSER",1,.f.)
							
							If VO4->VO4_TIPTEM != cTTpAnt
								
								cTTpAnt := VO4->VO4_TIPTEM
								nTotSrv := 0
								nHorPad := 0
								nHorTra := 0
								
							EndIf
							
							// se for liberacao nao permite se nao tive hora inicial/final
							If nOpc == 2 .And. !( VOK->VOK_INCMOB  $ "2/5" ) .And. ( Empty(VO4->VO4_DATFIN) .Or. Empty(VO4->VO4_HORFIN) )
								
								Help("  ",1,"M140FIMSRV")
								Return( .f. )
								
							EndIf
							
							nHorTra += VO4->VO4_TEMTRA
							
							ix1 := aScan(aCodSer,VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+VO4->VO4_CODSER)
							
							If ix1 == 0
								
								aAdd(aCodSer,VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+VO4->VO4_CODSER)
								
								Do Case
									Case VOK->VOK_INCMOB == "1"                     // Mao-de-Obra
										
										If VOK->VOK_INCTEM == "3"                  // Tempo Trabalhado
											//                                     nTotSrv += (VO4->VO4_TEMTRA / 100) * VOI->VOI_VALHOR
											nTotSrv += (VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)
											nHorPad += VO4->VO4_TEMPAD
										Else                                       // Tempo Fabrica/Concessionaria/Informado
											//                                     nTotSrv += (VO4->VO4_TEMPAD / 100) * VOI->VOI_VALHOR
											nTotSrv += (VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)
											nHorPad += VO4->VO4_TEMPAD
										EndIf
										
									Case VOK->VOK_INCMOB == "2"                     // Servico de Terceiro
										
										nTotSrv += VO4->VO4_VALVEN
										
									Case VOK->VOK_INCMOB == "3"                     // Valor Livre com Base na Tabela
										
										If VOK->VOK_INCTEM == "3"                  // Tempo Trabalhado
											//                                     nTotSrv += (VO4->VO4_TEMTRA / 100) * VOI->VOI_VALHOR
											nTotSrv += (VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)
											nHorPad += VO4->VO4_TEMPAD
										Else                                       // Tempo Fabrica/Concessionaria/Informado
											//                                     nTotSrv += (VO4->VO4_TEMPAD / 100) * VOI->VOI_VALHOR
											nTotSrv += (VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)
											nHorPad += VO4->VO4_TEMPAD
										EndIf
										
									Case VOK->VOK_INCMOB == "4"                     // Retorno de Servico
										
										If VOK->VOK_INCTEM == "3"                  // Tempo Trabalhado
											//                                     nTotSrv += (VO4->VO4_TEMTRA / 100) * VOI->VOI_VALHOR
											nTotSrv += (VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)
											nHorPad += VO4->VO4_TEMPAD
										Else                                       // Tempo Fabrica/Concessionaria/Informado
											//                                     nTotSrv += (VO4->VO4_TEMPAD / 100) * VOI->VOI_VALHOR
											nTotSrv += (VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)
											nHorPad += VO4->VO4_TEMPAD
										EndIf
										
									Case VOK->VOK_INCMOB == "5"                     // Socorro
										
										nTotSrv += VO4->VO4_KILROD * VOK->VOK_PREKIL
										
								EndCase
								
							Else
								
								Do Case
									Case VOK->VOK_INCMOB == "2"      // Servico de Terceiro
										
										nTotSrv += VO4->VO4_VALVEN
										
									Case VOK->VOK_INCMOB == "5"      // Socorro
										
										nTotSrv += VO4->VO4_KILROD * VOK->VOK_PREKIL
										
									Case VOK->VOK_INCMOB $ "1/3" .and. VOK->VOK_INCTEM == "3"          // Tempo Trabalhado
										
										//                                  nTotSrv += (VO4->VO4_TEMTRA / 100) * VOI->VOI_VALHOR          && Tempo Trabalhado
										nTotSrv += (VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR)          && Tempo Trabalhado
										
								EndCase
								
							EndIf
							
							ix1 := aScan(aSitOsv,{|x| x[1] == VO4->VO4_TIPTEM})
							If ix1 == 0
								aAdd(aSitOsv,{VO4->VO4_TIPTEM,VO4->VO4_FATPAR,SA1->A1_NREDUZ,0.00,Transform(nHorPad,"@R 99999999:99"),Transform(nHorTra,"@R 99999999:99"),Transform(nTotSrv,"@ez 99999999,999.99")})
							Else
								aSitOsv[ix1] := {VO4->VO4_TIPTEM,VO4->VO4_FATPAR,SA1->A1_NREDUZ,aSitOsv[ix1,04],Transform(nHorPad,"@R 99999999:99"),Transform(nHorTra,"@R 99999999:99"),Transform(nTotSrv,"@ez 99999999,999.99")}
							EndIf
							
							dbSkip()
							
						EndDo
						
				EndCase
				
				nTotTTp := nTotPec + nTotSrv
				
				dbSelectArea("VO2")
				dbSkip()
				
			EndDo
			
		Else
			
			aAdd(aSitOsv,{"","","",0.00,Transform(0,"@R 99999999:99"),Transform(0,"@R 99999999:99"),Transform(0,"@ez 99999999,999.99")})
			
		EndIf
		
	Else
		
		aAdd(aSitOsv,{"","","",0.00,Transform(0,"@R 99999999:99"),Transform(0,"@R 99999999:99"),Transform(0,"@ez 99999999,999.99")})
		
	EndIf
	
Else
	
	aAdd(aSitOsv,{"","","",0.00,Transform(0,"@R 99999999:99"),Transform(0,"@R 99999999:99"),Transform(0,"@ez 99999999,999.99")})
	
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_NOVBOX บAutor  ณFabio / Emilton     บ Data ณ  09/21/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida novo Box                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_NOVBOX(nOrig)
Local nRecNro
Local lRet := .f.

dbSelectArea("VON")
nRecNro := recno()

If FG_SEEK("VOF","M->VON_NOVBOX",1,.f.)
	If nOrig == 1
		If FS_FILBOX("D",M->VON_NOVBOX,.f.,1)
			lRet := .t.
			lPassou := .t.
		EndIf
	ElseIf nOrig == 2
		If !lPassou
			If FS_FILBOX("D",M->VON_NOVBOX,.t.,1)
				lRet := .t.
			EndIf
		Else
			lRet := .t.
			lPassou := .f.
		EndIf
	EndIf
EndIf

dbGoTo(nRecNro)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DESSEC บAutor  ณFabio / Emilton     บ Data ณ  09/21/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_DESSEC()

FG_SEEK("VOF","VON->VON_NUMBOX",1,.f.)
FG_SEEK("VOD","VON->VON_CODSEC",1,.f.)

Return VOD->VOD_DESSEC

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DESSEC บAutor  ณFabio / Emilton     บ Data ณ  09/21/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_FILBOX(cParam,cBox,lMensagem, nOrig)
Local lRet := .T.

If nOrig == 1
	
	If lMensagem == Nil
		lMensagem := .f.
	EndIf
	
	dbSelectArea("VOF")
	dbSetOrder(1)
	dbSeek(xFilial("VOF")+cBox)
	
	While cBox == VOF_NUMBOX .And. VOF->VOF_FILIAL == xFilial("VOF") .And. !Eof()
		
		If empty(VOF_SITBOX)
			VOF->(dbSkip())
			Loop
		EndIf
		If cParam == "O"
			If VOF_SITBOX != "D"
				lRet := .t.
			Else
				lRet := .f.
			EndIf
		Else
			If VOF_SITBOX == "D"
				lRet := .t.
			Else
				lRet := .f.
				If lMensagem
					Help("  ",1,"M190BOXOCU")
				EndIf
			EndIf
		EndIf
		VOF->(dbSkip())
	EndDo
EndIf

dbSelectArea("VON")
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_PCHA190บAutor  ณMicrosiga           บ Data ณ  04/20/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRefresh na mBrowse                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_PCHA190(cFiltra)
Local aIndVO1 := {}
dbSelectArea("VON")

If cFiltra == "S"
	
	//	cIndVON := CriaTrab(Nil, .F.)
	//	cChave  := IndexKey()
	//	cCond   := "FS_FILBOX('O',VON->VON_NUMBOX,,1)"        // Box Ocupado
	
	//	IndRegua("VON",cIndVON,cChave,,cCond,OemToAnsi(STR0026) ) //"Selecionando Registros..."
	//
	//	DbSelectArea("VON")
	//	nIndVON := RetIndex("VON")
	//	#IfNDEF TOP
	//		dbSetIndex(cIndVON+ordBagExt())
	//	#ENDIf
	//	dbSetOrder(nIndVON+1)
	cCond := "FS_FILBOX('O',VON->VON_NUMBOX,,1)"        // Box Ocupado
	aIndVON := {}
	bFiltraBrw := {|| FilBrowse("VON",@aIndVON,@cCond) }
	Eval(bFiltraBrw)
	
Else
	
	//	RetIndex()
	//
	//	#IfNDEF TOP
	//		If File(cIndVON+OrdBagExt())
	//			fErase(cIndVON+OrdBagExt())
	//		EndIf
	//	#ENDIf
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณFabio / Emilton     บ Data ณ  09/21/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMenu		                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {;
	{STR0001, "AxPesqui" , 0, 1},; // "Pesquisar"
	{STR0002, "OFIOM190L", 0, 2},; // "Lib BOX/Veic"
	{STR0003, "OFIOM190L", 0, 3} ; // "Mudar Box"
}

If ExistBlock("OM190AROT")
	aRecebe := ExecBlock("OM190AROT", .f., .f., {aRotina})
	If (ValType(aRecebe) == "A")
		aRotina := aClone(aRecebe)
	EndIf
EndIf
Return aRotina