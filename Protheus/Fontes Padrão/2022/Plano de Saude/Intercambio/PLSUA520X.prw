#include "fileIO.ch"
#include "protheus.ch"
#include "xmlxfun.ch"
#include "totvs.ch"
#include "FWMVCDEF.CH"

#define CRLF chr( 13 ) + chr( 10 )
#define GUIA_CONSULTA 	'01'
#define GUIA_SADT		'02'
#define GUIA_INTERNACAO	'05'
#define GUIA_HONORARIO 	'06'

static lPLSR506 := existBlock("PLSR506")
static cDirTmp := PLSMUDSIS( "\plsptu\" )

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSU520BRW
Rotina de Aviso Lote Guias - Envio

@author  Lucas Nonato
@since   18/12/2020
@version P12
/*/
Function PLSU520BRW()
local cFilter   := ""
local cCampos   := ""
private __aRet	:= {}
private cCodInt	:= plsintpad()
private oMBrwB2S := nil

BD5->(dbsetorder(1))
BE4->(dbsetorder(1))
B43->(dbsetorder(1))
BX6->(dbsetorder(1))

cCampos += iif(BD5->(fieldPos("BD5_TISVER")) <= 0, "BD5_TISVER,", "" ) 
cCampos += iif(BE4->(fieldPos("BE4_TISVER")) <= 0, "BE4_TISVER,", "" )
cCampos += iif(B43->(fieldPos("B43_IDUNIC")) <= 0, "B43_IDUNIC,", "" )
cCampos += iif(B43->(fieldPos("B43_SEQPTU")) <= 0, "B43_SEQPTU,", "" )
cCampos += iif(BX6->(fieldPos("BX6_IDUNIC")) <= 0, "BX6_IDUNIC,", "" )
cCampos += iif(BX6->(fieldPos("BX6_SEQPTU")) <= 0, "BX6_SEQPTU,", "" )

if !empty(cCampos)
	cCampos := substr(cCampos,1,len(cCampos)-1)
	aviso( "Atenção","Para a execução da rotina, é necessária a criação do(s) campo(s): " + cCampos ,{ "Ok" }, 2 )
	return	
endIf

cFilter := PLSU520FIL(.f.)
setKey(VK_F2 ,{|| cFilter := PLSU520FIL(.t.) })

oMBrwB2S:= FWMarkBrowse():New()
oMBrwB2S:SetAlias('B2S')
oMBrwB2S:SetDescription("Gestão de Avisos - Envio") 
oMBrwB2S:SetMenuDef("PLSUA520X")
oMBrwB2S:AddLegend( "B2S->B2S_STATUS=='1'", "GREEN", 	"Pend. Envio Aviso"  ) 
oMBrwB2S:AddLegend( "B2S->B2S_STATUS=='2'", "YELLOW", 	"Aviso Enviado"  ) 
oMBrwB2S:AddLegend( "B2S->B2S_STATUS=='3'", "ORANGE", 	"Aviso Recebido"  ) 

oMBrwB2S:SetFieldMark( 'B2S_OK' )	
oMBrwB2S:SetAllMark({ ||  A270Inverte(oMBrwB2S, "B2S") })
oMBrwB2S:SetWalkThru(.F.)
oMBrwB2S:SetFilterDefault(cFilter)
oMBrwB2S:SetAmbiente(.F.)
oMBrwB2S:ForceQuitButton()
oMBrwB2S:Activate()

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta o menu

@author  Lucas Nonato
@since   18/12/2020
@version P12
/*/
Static Function MenuDef()
local aRotina := {}

ADD OPTION aRotina Title "Processar"  	        Action 'PLSU520PRO(.t.)'	            OPERATION 3 ACCESS 0 //"Processar" 
ADD OPTION aRotina Title "Gerar Arquivo"	    Action 'PTU520EXP(.f.)'				OPERATION 2 ACCESS 0 //"Gerar Arquivo"
ADD OPTION aRotina Title "Detalhar" 	        Action 'ViewDef.PLSUA520'			OPERATION 2 ACCESS 0 //"Detalhar"
ADD OPTION aRotina Title "Excluir"	            Action 'Processa({||PLSU520DEL()},"Lote de Aviso - Exclusao","Processando...",.T.)' 	OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina Title "<F2> - Filtrar" 		Action 'PLSU520FIL(.t.)'            OPERATION 2 ACCESS 0 //'Filtrar'
Return aRotina  

//-------------------------------------------------------------------
/*/{Protheus.doc} PTU520EXP

@author    Lucas Nonato
@version   V12
@since     31/07/2020
/*/
function PTU520EXP(lAuto)
local aMsg			:= {}
private oProcess 	:= nil
default lAuto 		:= .f.

if lAuto
	cCodInt := plsintpad()
	oProcess := P270fProc():New()
	aMsg := PTU520BASE(lAuto)
else
	oProcess := msNewProcess():New( { || PTU520BASE() } , "Processando" , "Aguarde..." , .F. )
	oProcess:Activate()
endif

return aMsg