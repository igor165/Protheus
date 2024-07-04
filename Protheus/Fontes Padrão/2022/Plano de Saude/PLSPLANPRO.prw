#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'  
#INCLUDE 'PLSPLANPRO.CH'  

/*/{Protheus.doc} 

@since 30/07/2020
@version P12
/*/

function PLSPLANPRO(cCodRDA, cCodInt,cCodLoc, cCodEsp, cCodSubEsp,cLocalEsp) 
local aArea     	:= GetArea()
local oDlgWnd		:= nil 
local oPnlInf	:= nil
local oGridBBI		:= nil
local oGridBE9		:= nil 
local aSize     := MsAdvSize(.F.)
local aInfo		:= {}
local aObjects	:= {}
local aPosObj	:= {}
local aRelac	:= {}
local fieldBE9  := BE9->(FieldPos("BE9_SEQUEN")) > 0
local fieldBBI  := BBI->(FieldPos("BBI_SEQUEN")) > 0
local cFiltro   := "@(BBI_FILIAL = '" + xFilial("BBI") + "' AND BBI_CODINT = '" + cCodInt + "' AND BBI_CODIGO ='" + cCodRDA + "' "+;
					"AND BBI_CODLOC = '" + cCodLoc + "' AND BBI_CODESP = '" + cCodEsp + "' AND BBI_CODSUB = '" + cCodSubEsp + "')"
private cCodInt := Plsintpad()
private cCamLEtxt := cLocalEsp
private cPVLocBBI := cCodLoc
private cPVEspBBI := cCodEsp
private cPVEspSBBI := cCodSubEsp
private cRdaBAUB := cCodRDA

aObjects 	:= {	{ 100, 50, .T., .T. },;
					{ 100, 50, .T., .T. } }

aInfo		:= { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }
aPosObj	:= MsObjSize( aInfo, aObjects, .T. )

//MsDialog																 
oDlgWnd := msDialog():New(aSize[7],0,aSize[6],aSize[5],'Planos x Procedimentos',,,,,,,,,.T.)

//Cria o conteiner onde serão colocados browse							 
oPnlSup := tPanel():New(aPosObj[1,1],aPosObj[1,2],,oDlgWnd,,,,,,aPosObj[1,4],aPosObj[1,3]-5)															 
aRotina := {}                               

//Grid da tabela de Planos - BBI
oGridBBI := FWmBrowse():New()
oGridBBI:setOwner(oPnlSup)
oGridBBI:setProfileID('0')
oGridBBI:setAlias("BBI") 
oGridBBI:setDescription(STR0001) //'Plano de Saúde - Informações'
oGridBBI:setMenuDef('PLSBBIPLA')
oGridBBI:disableDetails()  
oGridBBI:disableReport()                 
oGridBBI:setFilterDefault(cFiltro)
oGridBBI:activate()

//grid da tabela de Procedimentos																	 
oPnlInf := tPanel():new(aPosObj[2,1],aPosObj[2,2],,oDlgWnd,,,,,,aPosObj[2,4],aPosObj[2,3]-5)													 
aRotina := {}                               

//Grid da tabela de Procedimentos - BE9															 
oGridBE9 := FWmBrowse():New()
oGridBE9:setOwner(oPnlInf)
oGridBE9:setProfileID('1')
oGridBE9:setAlias("BE9")
oGridBE9:SetOnlyFields({'BE9_CODREA','BE9_RECREA','BE9_FILIAL','BE9_CODTAB','BE9_DESTAB','BE9_CODPAD','BE9_DESPAD','BE9_CODPRO',;
						'BE9_DESPRO','BE9_NIVEL ','BE9_CODGRU','BE9_CODPLA','BE9_CODLOC','BE9_CODINT','BE9_CODESP','BE9_CODSUB','BE9_CDNV01',;
						'BE9_CDNV02','BE9_CDNV03','BE9_CDNV04','BE9_VIGDE ','BE9_VIGATE','BE9_ATEND','BE9_URG','BE9_ELET','BE9_PF,','BE9_PJ',;
						'BE9_ATEINT','BE9_ATEEXT','BE9_INDIC ','BE9_INDAMB','BE9_NET','BE9_CALL','BE9_VALCH','BE9_BLOPAG','BE9_VALREA',;
						'BE9_USRECT','BE9_ATIVO ','BE9_VLRECT','BE9_PERDES','BE9_BANDA','BE9_PERACR','BE9_UCO'})
oGridBE9:setDescription(STR0002)//Procedimentos
oGridBE9:setMenuDef('PLSBE9PRO')
oGridBE9:disableDetails()  
oGridBE9:disableReport()                  	


aRelac := {	{ "BE9_FILIAL", 'xFilial("BE9")' }, ;
		  { "BE9_CODIGO", "BBI_CODIGO" }, ;
		  { "BE9_CODINT", "BBI_CODINT" }, ;
		  { "BE9_CODLOC", "BBI_CODLOC" }, ;
		  { "BE9_CODESP", "BBI_CODESP" }, ;	
		  { "BE9_CODSUB", "BBI_CODSUB" }, ;
		  { "BE9_CODGRU", "BBI_CODGRU" }, ;
		  { "BE9_CODPLA", "BBI_CODPRO" } }

if fieldBE9 .and. fieldBBI
	aadd(aRelac, {"BE9_SEQUEN","BBI_SEQUEN"})
endif 

//Relacao dos Browses 									 
OGridRelac := FWBrwRelation():new()       
OGridRelac:addRelation( oGridBBI, oGridBE9, aRelac)      

                           
OGridRelac:Activate()
oGridBE9:activate()



//³ Ativando componentes de tela											 
oDlgWnd:lCentered := .T.
oDlgWnd:bRClicked := {||}
oDlgWnd:Activate()       

restArea(aArea)                   														 

return nil
