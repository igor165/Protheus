#include "PMPROBRIN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "TOPCONN.CH"



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PMPROBRINบAutor  ณMicrosiga           บ Data ณ  10/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ao que chama a tela para a Inclusใo de Brindes         บฑฑ
ฑฑบ          ณ  aos Beneficiarios que estiveram Presentes no Evento		บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PMPROBRIN(cCodProg,cCodCamp,cCodItem,cEvent,dDatEven,cFilCamp)
Local oBrowse1
LOCAL aArea     := GetArea()  
LOCAL nI		:= 0
LOCAL nFldId  	:= 1
LOCAL nAtuSec	:= 60
LOCAL aTFolder 	:= {}
LOCAL aHeader	:= {}
LOCAL aFiles	:= {}
LOCAL aCoors  	:= FWGetDialogSize( oMainWnd )
LOCAL oPanelUp 	:= NIL
LOCAL oFWLayer 	:= NIL 
LOCAL oPLUpTop 	:= NIL
LOCAL oPLUp 	:= NIL
LOCAL oPLDown  	:= NIL
LOCAL oDlg		:= NIL       
LOCAL cFiltro	:= ""
LOCAL cFiltro2:=""
LOCAL aFolder	:= {STR0001} //"Procedimentos"//"Beneficiarios Presentes na Campanha"


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Private
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
PRIVATE _CodPad_  := ""
PRIVATE cCadastro := ""
Private oMBrwPRES 
Private oBO6
Private cEvento:=""
PRIVATE dDataEve:=""

DEFAULT cCodProg:=""
DEFAULT cCodCamp:=""
DEFAULT cCodItem:=""
DEFAULT cEvent:=""
DEFAULT dDatEven:=CtoD(" / / ") 
DEFAULT cFilCamp	:=""

cEvento:=cEvent
dDataEve:=dDatEven



Inclui := .F.    
aRotina   := {}
                     
cFiltro := "BO6_FILIAL == '" + xFilial("BO6") + "'"
cFiltro += " .AND. BO6_CODPRO == '" + cCodProg + "'"
cFiltro += " .AND. BO6_CODCAM == '" + cCodCamp + "'"
cFiltro += " .AND. BO6_ITEM == '" + cCodItem + "'"


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ MsDialog																 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
oDlg := MSDialog():New(3,0,560,890,STR0002,,,,,,,,,.T.) //"Campanhas e Eventos"//"Brindes na Campanha"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Cria o conteiner onde serใo colocados s browses							 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
oFWLayer := FWLayer():New()
oFWLayer:Init( oDlg, .F.)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Divisao da tela em duas linhas de 50%									 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

oFWLayer:AddLine('Up'	,50,.F.)
oFWLayer:AddLine('Down'	,50,.F.)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Monta obj de Linha														 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//oPLUpTop := oFWLayer:GetLinePanel( 'UpTop' )
oPLUp 	 := oFWLayer:GetLinePanel( 'Up' )
oPLDown  := oFWLayer:GetLinePanel( 'Down' )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Painel																	 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//oTFolder 		:= TFolder():New( 000,000,aFolder,,oPLUp,,,,.T.,,449,140)	
	//oTFolder:Align:= CONTROL_ALIGN_ALLCLIENT                               
	//oPLPro 			:= oTFolder:aDialogs[1]
 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Browse demanda
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
oBO6 := FWMarkBrowse():New()
oBO6:SetAlias( "BO6" )
oBO6:SetMenuDef("PMPROBRIN")
oBO6:SetOwner(oPLDown)
oBO6:SetProfileID( "100" )
oBO6:SetFieldMark( 'BO6_IDMARK' )
oBO6:SetDescription( STR0003 )   //"Campanhas e Eventos"//"Brindes da Campanha"
oBO6:DisableDetails()
oBO6:SetAmbiente(.T.)
oBO6:SetWalkThru(.T.)
oBO6:ForceQuitButton()             
//oBO6:SetChange({|| PProEveFil() })           
oBO6:SetFilterDefault(cFiltro)
oBO6:Activate()   


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ	MBrowse da dos pacientes Presente na Campanha ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
DbSelectArea("BOM")
cAlias := "BOM"
cFilter := "BOM_FILIAL == '" + xFilial("BOM") + "' .AND. BOM_CODPRO == '" + BOA->BOA_CODPRO  + "' " +  cFilCamp//


oMBrwPRES := FWMBrowse():New()
oMBrwPRES:SetAlias( cAlias)
oMBrwPRES:SetMenuDef("")
oMBrwPRES:SetOwner(oPLUp)
oMBrwPRES:SetDescription(STR0004) //oBrwBOA:SetFieldMark( 'BOA_IDMARK' ) //"Programas de Sa๚de"//"Lista de Pacientes Presentes na Campanha"
oMBrwPRES:DisableDetails()
oMBrwPRES:SetAmbiente(.T.)
oMBrwPRES:SetWalkThru(.T.)
oMBrwPRES:SetFilterDefault(cFilter)

//oMBrwPRES:DisableConfig()
//oMBrwPRES:DisableLocate()
//oMBrwPRES:DisableReport()


//oMBrwPRES:SetBlkBackColor( {|| CLR_WHITE } )//"#D6E4EA"


oMBrwPRES:Activate()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Ativando componentes de tela											 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
oDlg:lCentered	:= .T.


oDlg:Activate()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Rest nas linhas do browse e na area										 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
RestArea( aArea )                   
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
//ณ Fim da Rotina															 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
Return NIL

Return     
             
//----------------------------------------------------------------------------
// ATUALIZA O BROWSE DA SUW
//---- ------------------------------------------------------------------------
Static Function PProEveFil() 
	
If  oMBrwPRES <> Nil
	oMBrwPRES:SetFilterDefault("UW_CODCAMP == " + BO6->BO6_CODCAM + "")
	oMBrwPRES:Refresh()
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณSaude               บ Data ณ  02/26/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta Menu de a็๕es relacionadas Brindes de campanha		 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MenuDef()
Private aRotina := {}

AaDd( aRotina, { STR0005, 	"PMBRINGRV", 0, MODEL_OPERATION_INSERT, 0, NIL } ) //"Gravar"

Return aRotina   

 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMBRINFIL   บAutor  ณSaude               บ Data ณ  19/08/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta Filtro para trazer somente Beneficiarios que estใo.  บฑฑ
ฑฑบ          ณPresentes no Evento/Campanha						           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function PMBRINFIL(cProgram)

Local aArea		:= GetArea()
Local cQryRes	:= GetNextAlias() 
Local aSequen	:= {}
Local cQuery	:= ""
Local cRet		:= "" 
Local dData    := DTOS(dDataBase)

Default cProgram	:= ""

cQuery := "SELECT "
cQuery += "	DISTINCT BA1_MATVID "
cQuery += "	FROM "
cQuery += 		RetSQLName("AG5")
cQuery += "			INNER JOIN "+RetSQLName("BA1")+" ON "
cQuery += "				BA1_FILIAL = '"+xFilial("BA1")+"' AND "
If AllTrim(TCGetDB()) $  "MSSQL" 
	cQuery += "				BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU+BA1_TIPREG+BA1_DIGITO = AG5_CODEN OR "
	cQuery += "				BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO = AG5_CODEN AND "
Else

	cQuery += "				BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPUSU||BA1_TIPREG||BA1_DIGITO = AG5_CODEN OR "
	cQuery += "				BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO = AG5_CODEN AND "

Endif
cQuery += 				RetSQLName("BA1")+".D_E_L_E_T_ = ' ' "
cQuery += "			INNER JOIN "+RetSQLName("ACE")+" ON "
cQuery += "				ACE_FILIAL = '"+xFilial("ACE")+"' AND "
cQuery += "				ACE_CODIGO = AG5_EVENT AND "
cQuery += "				ACE_GRADE  = AG5_GRADE AND "
cQuery += "				ACE_DATA   < '"+dData+"' AND "
cQuery +=  				RetSQLName("ACE")+".D_E_L_E_T_ = ' ' "
cQuery += "			INNER JOIN "+RetSQLName("ACD")+" ON "
cQuery += "				ACD_FILIAL = '"+xFilial("ACD")+"' AND "
cQuery += "				ACD_CODIGO = ACE_CODIGO AND "
cQuery += 				RetSQLName("ACD")+".D_E_L_E_T_ = ' ' "
cQuery += "			INNER JOIN "+RetSQLName("BOM")+" ON " 
cQuery += "				BOM_FILIAL = '"+xFilial("BOM")+"' AND "
cQuery += "				BOM_VIDA = BA1_MATVID AND "
cQuery += 				RetSQLName("BOM")+".D_E_L_E_T_ = ' ' "	
cQuery += "		WHERE "     
cQuery += "			AG5_PRESE <> '2'   AND "
cQuery += "			AG5_ENTID = 'BA1' AND "
cQuery +=  			RetSQLName("AG5")+".D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery, .F.)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )
 	
While !(cQryRes)->(EOF())
    aAdd(aSequen, (cQryRes)->BA1_MATVID)
	(cQryRes)->(DBSkip())
EndDo
	
(cQryRes)->(dbCloseArea())

If !Empty(aSequen)
	cRet := cRet + ".AND. (BOM_VIDA $ '" +AtoC(aSequen, "|")+ "')"
EndIf

RestArea( aArea )

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPMBRINGRV   บAutor  ณSaude               บ Data ณ  19/08/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava Beneficiarios que estใo.  								 บฑฑ
ฑฑบ          ณPresentes no Evento/Campanha na Tabela de Histrorico         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SEGMENTO SAUDE                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function PMBRINGRV()
Local aArea       := GetArea()
Local cMarca     := oBO6:Mark()
Local lInvert    := oBO6:IsInvert()
Local cFiltro    := ""
Local nQtdNT2    := 0
Local nCt         := 0
Local lErro       := .F.
Local lRet        := .T.
lOCAL cDefFiltro:=""


If Empty(cFiltro)
	cFiltro += "(BO6_IDMARK "+Iif(lInvert, "<>", "==" )+" '" + cMarca + "')" + " .AND. (BO6_FILIAL = '" + xFilial( "BO6" ) + "')"
EndIf    

cAux := &( '{|| ' + cFiltro + ' }')
BO6->(dbSetFilter( cAux, cFiltro ))
BO6->(dbSetOrder(1))

BO6->(dbgotop())
BO6->(dbEVal({||nQtdNT2++},, {||!EOF()} ))
If nQtdNT2 == 0
	MsgAlert(STR0006) //"Nใo existe nenhum Brinde Marcado"
	lRet := .F.
EndIF

If (lRet)

	ProcRegua( nQtdNT2 )

	BO6->(dbgotop())
	
	aStruct := BO6->( dbStruct() )
	
	While !(BO6->(EOF()))
	
				
				BO7->(RECLOCK("BO7",.T.))
				BO7->BO7_FILIAL		:=	XFILIAL("BO7")
				BO7->BO7_SEQNRO		:= GETSXENUM('BO7','BO7_SEQNRO',, 1)
				BO7->BO7_MATVID		:= BOM->BOM_VIDA
				BO7->BO7_CODPRO		:= BOM->BOM_CODPRO
				BO7->BO7_CODCAM		:= BO6->BO6_CODCAM
				BO7->BO7_CODEVE		:=cEvento
				BO7->BO7_CODBRD		:=BO6->BO6_CODBRD
				BO7->BO7_USUARI		:=cUserName
				BO7->BO7_LOGARQ		:=Hs_LogArq()
				BO7->BO7_DATAEV		:=dDataEve
				BO7->(MSUNLOCK())
				ConfirmSx8()

	
	BO6->( dbSkip())                            
	EndDo	

	cAux := &( "{|| "+cDefFiltro+" }")  //Retorna o Filtro padrใo 
	BO6->( dbSetFilter( cAux, cDefFiltro ) )
	


Endif	
If lRet
	MsgInfo(STR0007)
Endif
RestArea( aArea )

Return lRet

