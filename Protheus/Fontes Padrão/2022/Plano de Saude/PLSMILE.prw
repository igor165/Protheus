#INCLUDE "PLSMILE.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE 'APWEBEX.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#DEFINE PLS_MD_OPE	1

/*/{Protheus.doc} PLSMILE
Classe PLSMILE para importacao

@author Alexander Santos

@since 16/04/2014
@version P11
/*/

class PLSMILE

data cLayout 		as string
data lLayoutVld 	as logic
data aDadLay		as array

method new(cModel,aRotina) Constructor   

method	 setLayout(cLayout) 
method isLayoutVld()
method getFieldValue(cField)
method import(cFile,lChk)
method dialog(cLayout)

endClass     

/*/{Protheus.doc} New
Construtor da class

@author Alexander Santos
@since 11/02/2014
@version P11
/*/
method new(cModel,aRotina) class PLSMILE
local aSubMenu 	:= {}
local cType		:= '1' //1-Importacao/2-Exportacao
local cActive		:= '1'
local aArea		:= getArea()
local cArqIgn	:= 'BRASIMAT|BRASMATF|BRASIMED|BRASMEDF'

default aRotina	:= nil
default cModel	:= ''

//Abre XXJ se estiver fechada
if (select("XXJ")==0)
	FWOpenXXJ() 
endIf

dbSelectArea("XXJ")

if !empty(cModel) .and. aRotina != nil
	
	cModel := cModel+space(10-len(cModel))
	
	XXJ->(dbSetOrder(2)) //XXJ_ADAPT+XXJ_TYPE+XXJ_ACTIVE
	if XXJ->(msSeek(cModel+cType+cActive))
		while !XXJ->(eof()) .and. XXJ->XXJ_ADAPT == cModel
			cLayout := allTrim(XXJ->XXJ_CODE)
			cDescri := allTrim(XXJ->XXJ_DESC)
			if ( !(cLayout $ cArqIgn) .or. !('BRASINDICE' $ upper(cDescri)) )
				aadd( aSubMenu, { cDescri, '__PIMP("' + cLayout + '")', 0, MODEL_OPERATION_INSERT} )
			endif
			
		XXJ->(dbSkip())		
		endDo
		aadd( aRotina, { 'Importação', aSubMenu, 0, 0} )
	endIf	
	
endIf

::cLayout 		:= ""
::lLayoutVld 	:= .f.
::aDadLay		:= {}

restArea(aArea)

return Self   

/*/{Protheus.doc} setLayout
Seta layout 

@author Alexander Santos
@since 11/02/2014
@version P11
/*/
method setLayout(cLayout) class PLSMILE
local __ofwMile	:= fwMile():new()
local __oXml		:= tXmlManager():new()
local nI,nY,nX	:= 0
local aMatXZ1 	:= {}
local aMatXZ2 	:= {}
local aMatXZ3 	:= {}
local aMatXZ4 	:= {}
local aMatXZ5 	:= {}
local aAux 		:= {}
local aAuxII 		:= {}
local aAuxIII 	:= {}

__ofwMile:setLayout(cLayout)
__ofwMile:activate()

::cLayout 		:= cLayout
::lLayoutVld 	:= !empty(__ofwMile:cLayOutXML)

if ::lLayoutVld
	__oXml:parse(__ofwMile:cLayOutXML)

	cStruct  := 'XZ1MASTER'
	cPathTag := '/CFGA600/'+cStruct
	
	if __oXml:XPathHasNode(cPathTag)
		
		aadd(aMatXZ1,cStruct)
		
		aAux 		:= __oXml:XPathGetChildArray(cPathTag)
		nSize		:= len(aAux)
		cPathTag 	:= aAux[nSize,2]

		adel(aAux,nSize)
		aSize(aAux,(nSize-1))
		
		//Strutura da XZ1 
		aadd(aMatXZ1,aAux)

		//Identificador da XZ2 
		cPathTag := cPathTag + "/items"
		
		if __oXml:XPathHasNode(cPathTag)
					
			aXZ2 := __oXml:XPathGetChildArray(cPathTag)
			
			for nX:=1 to len(aXZ2)
			
				cPathTag := aXZ2[nX,2]
				
				//XZ2
				if __oXml:XPathHasNode(cPathTag)
					
					aAux := __oXml:XPathGetChildArray(cPathTag)
	
					aadd(aMatXZ2,aAux)
	
					//XZ3
					cStruct	:= "XZ3DETAIL"
					nSize		:= ascan(aAux, {|x| x[1] == cStruct})
					cPathTag 	:= aAux[nSize,2]
	
					if __oXml:XPathHasNode(cPathTag)
						aAuxII := __oXml:XPathGetChildArray(cPathTag)
						aadd(aMatXZ3,aAuxII)
					endIf
	
					//XZ4
					cStruct	:= "XZ4DETAIL"
					nSize		:= ascan(aAux, {|x| x[1] == cStruct})
					cPathTag 	:= aAux[nSize,2]
	
					if __oXml:XPathHasNode(cPathTag)
		
						aAuxII := __oXml:XPathGetChildArray(cPathTag)
						cStruct:= "items"
						nSize	:= ascan(aAuxII, {|x| x[1] == cStruct})
						
						if nSize>0
							cPathTag 	:= aAuxII[nSize,2]
		
							if __oXml:XPathHasNode(cPathTag)
								aAuxII := __oXml:XPathGetChildArray(cPathTag)
								
								for nI:=1 to len(aAuxII)
									cPathTag := aAuxII[nI,2]
									
									if __oXml:XPathHasNode(cPathTag)
										aadd(aAuxIII,__oXml:XPathGetChildArray(cPathTag))
									endIf	
								next
							endIf
							aadd(aMatXZ4,aAuxIII)
							aAuxIII := {}
						endIf	
	
					endIf
					
					//XZ5
					cStruct	:= "XZ5DETAIL"
					nSize		:= ascan(aAux, {|x| x[1] == cStruct})
					cPathTag 	:= aAux[nSize,2]
					
					if __oXml:XPathHasNode(cPathTag)
						
						aAuxII := __oXml:XPathGetChildArray(cPathTag)
						cStruct:= "items"
						nSize	:= ascan(aAuxII, {|x| x[1] == cStruct})
						
						if nSize > 0
							cPathTag 	:= aAuxII[nSize,2]
		
							if __oXml:XPathHasNode(cPathTag)
						
								aAuxII := __oXml:XPathGetChildArray(cPathTag)
								
								for nI:=1 to len(aAuxII)
									cPathTag := aAuxII[nI,2]
									
									if __oXml:XPathHasNode(cPathTag)
										aadd(aAuxIII,__oXml:XPathGetChildArray(cPathTag))
									endIf	
								next
							endIf
							aadd(aMatXZ5,aAuxIII)
							aAuxIII := {}
						endIf
							
					endIf
				endIf
			next
			aadd(aMatXZ1,'XZ2DETAIL')
			aadd(aMatXZ1,aMatXZ2)
			aadd(aMatXZ1,'XZ3DETAIL')
			aadd(aMatXZ1,aMatXZ3)
			aadd(aMatXZ1,'XZ4DETAIL')
			aadd(aMatXZ1,aMatXZ4)
			aadd(aMatXZ1,'XZ5DETAIL')
			aadd(aMatXZ1,aMatXZ5)
		endIf
	endIf
endIf

		
::aDadLay := aClone(aMatXZ1)
__oXml 	:= nil
__ofwMile 	:= nil
	
return

/*/{Protheus.doc} isLayoutVld
Retorna se Layout e valido

@author Totvs
@since 16/04/14
@version 1.0
/*/
method isLayoutVld() class PLSMILE
return(::lLayOutVld)

/*/{Protheus.doc} import
Importa txt

@author Totvs
@since 16/04/14
@version 1.0
/*/
method import(cFile,lChk) class PLSMILE
local nI,nY,nX	:= 0
local cIdModel 	:= ''
local cIdOccurs	:= ''
local cSeparador	:= ''	
local cTable 		:= ''
local cModel 		:= ''
local cFPreExe 	:= ''
local cFPosExe 	:= ''
local cFTraDad 	:= ''
local cFVldOpe 	:= ''	
local cForDat 	:= ''
local cSepDec 	:= ''	
local cTipOpeI 	:= ''	
local cTipOpeA 	:= ''	
local cSource 	:= ''
local cField	 	:= ''
local cExec		:= ''
local cErro		:= ''
local cType		:= ''
local cCond		:= ''
local cTipo		:= ''
local cTabPri		:= ''
local cOriCan		:= ''
local cChanel		:= ''
local cPosExe		:= ''
local aDadXZ4		:= {}	
local aDadXZ5		:= {}	
local aDadAUX		:= {}
local aMat		:= {}
local aMIdModel 	:= {}
local lMultCanal	:= .f. 
local lReaModDef	:= .f.	
local lTxt 	 	:= .f.
local lRet		:= .t.
local oModel		:= nil
local oAux 		:= nil
local oStruct 	:= nil

default cFile	:= ''
default lChk		:= .t.

if vldFile(cFile,lChk) .and. len(::aDadLay)>0

	for nI:=1 to len(::aDadLay)
		
		if valType(::aDadLay[nI]) == "A"
			loop
		endIf
		
		if (nI+1) <= len(::aDadLay)
			aMat := ::aDadLay[nI+1]
		endIf
			
		do case
			case ::aDadLay[nI] == "XZ1MASTER"
				
				cSeparador := ''	
				if findVal(aMat,'XZ1_STRUC') == '2'
					cSeparador := findVal(aMat,'XZ1_SEPARA')	
				endIf
				// Tipo
				cTipo := findVal(aMat,'XZ1_TYPE') //1=ExecAuto;2=MVC;3=Funcao
				//ExecAuto
				if cTipo == '1'
					FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', 'Estrutura não implementado, somente (MVC ou FUNCAO)' , 0, 0, {})
					cErro 	:= 'Estrutura não implementado, somente (MVC ou FUNÇÃO)'
					lRet 	:= .f.
					exit
				endIf
				//Origem do Canal
				cOriCan := findVal(aMat,'XZ1_SOURCE')
				//Entrada multicanal
				lMultCanal := (findVal(aMat,'XZ1_EMULTC')=='1')
				//Tabela Principal
				cTabPri := findVal(aMat,'XZ1_TABLE')
				// Modelo
				cModel := findVal(aMat,'XZ1_ADAPT')
				//Pre execucao
				cFPreExe := findVal(aMat,'XZ1_PRE')
				//Pos execucao	
				cFPosExe := findVal(aMat,'XZ1_POS')
				//Trata dados	
				cFTraDad := findVal(aMat,'XZ1_TDATA')
				//Valida operacao	
				cFVldOpe := findVal(aMat,'XZ1_CANDO')	
				//Formato da data
				cForDat := findVal(aMat,'XZ1_TIPDAT')
				//Separador decimal	
				cSepDec := findVal(aMat,'XZ1_DECSEP')	
				//Tipo de operacao de inclusao -  inclusao/alteracao ou apenas inclusao
				cTipOpeI := findVal(aMat,'XZ1_MVCOPT')	
				//Tipo de operacao de alteracao -  Alteracao direta ou exclui/inclui
				cTipOpeA := findVal(aMat,'XZ1_MVCMET')	
				//Reavalia o modeldef a cada registro
				lReaModDef := findVal(aMat,'XZ1_NOCACHEMOD') == '1'	
					
			case ::aDadLay[nI] == "XZ2DETAIL"
			case ::aDadLay[nI] == "XZ3DETAIL"
				//MVC
				if cTipo == '2'
					oModel := FWLoadModel(cModel)
					
					//Retorna o ID do modelo
					for nY:=1 to len(aMat)
						cChanel 	:= findVal(aMat[nY],'XZ3_CHANEL')
						cIdModel 	:= findVal(aMat[nY],'XZ3_IDOUT')
						cIdOccurs	:= findVal(aMat[nY],'XZ3_OCCURS')
						cPosExe	:= findVal(aMat[nY],'XZ3_POS')
						
						oAux 		:= oModel:GetModel(cIdModel)
						oStruct 	:= oAux:GetStruct()
						cTable		:= oStruct:aTable[1]
						
						aadd(aMIdModel,{cTable,cIdModel,cIdOccurs,cChanel,cPosExe})
					next
				//Funcao	
				else
					for nY:=1 to len(aMat)
						cChanel 	:= findVal(aMat[nY],'XZ3_CHANEL')
						cIdModel 	:= findVal(aMat[nY],'XZ3_IDOUT')
						cIdOccurs	:= findVal(aMat[nY],'XZ3_OCCURS')
						cPosExe	:= findVal(aMat[nY],'XZ3_POS')

						aadd(aMIdModel,{cTabPri,cIdModel,cIdOccurs,cChanel,cPosExe})
					next
				endIf	
				
				oModel  := nil
				oAux	 := nil
				oStruct := nil
					
			case ::aDadLay[nI] == "XZ4DETAIL"
				for nX:=1 to len(aMat)
					for nY:=1 to len(aMat[nX])
						cSource := findVal(aMat[nX,nY],'XZ4_SOURCE')
						cField	 := findVal(aMat[nX,nY],'XZ4_FIELD')
						cExec	 := findVal(aMat[nX,nY],'XZ4_EXEC')
						cType	 := findVal(aMat[nX,nY],'XZ4_TYPFLD')
						cCond	 := findVal(aMat[nX,nY],'XZ4_COND')
						cType	 := iif(empty(cType),'C',cType)
						
						lTxt 	 := ( val(strTran('-','',cSource)) != 0 )
		
						aadd( aDadAUX,{ltxt,cField,cExec,cSource,cType,cCond} )	
					next
					aadd( aDadXZ4,{aMIdModel[nX],aDadAUX} )
					
					aDadAUX := {}	
				next
			case ::aDadLay[nI] == "XZ5DETAIL"
			 
				for nX:=1 to len(aMat)
					for nY:=1 to len(aMat[nX])
						cSource := findVal(aMat[nX,nY],'XZ5_SOURCE')
						cField	 := findVal(aMat[nX,nY],'XZ5_FIELD')
						cExec	 := findVal(aMat[nX,nY],'XZ5_EXEC')
						cType	 := findVal(aMat[nX,nY],'XZ5_TYPFLD')
						cCond	 := findVal(aMat[nX,nY],'XZ5_COND')
						cType	 := iif(empty(cType),'C',cType)
						
						lTxt 	 := ( val(strTran('-','',cSource)) != 0 )
		
						aadd( aDadAUX,{ltxt,cField,cExec,cSource,cType,cCond} )	
					next
					aadd( aDadXZ5,{aMIdModel[nX],aDadAUX} )
					
					aDadAUX := {}	
				next
		endCase
	next
	
	//leitura e gravacao dos dados
	if lRet
		cErro := gravaDad(lChk,cFile,cModel,cTipOpeI,cTipOpeA,aDadXZ4,aDadXZ5,cFPreExe,cFPosExe,cFTraDad,cFVldOpe,cSeparador,allTrim(::cLayout),cTipo,cOriCan,lMultCanal)
	endIf
else
	cErro := 'Verifique o arquivo e o layout selecionado'	
endIf

return(cErro)

/*/{Protheus.doc} dialog
Exibe a dialog de importacao.

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/

method dialog(cLayout) class PLSMILE
local aSize     := MsAdvSize()
local aInfo		:= {}
local aObjects	:= {}
local aPosObj		:= {}
local oDlg		:= nil
local oTop 		:= nil
local oDown		:= nil
local oFWLayer	:= nil  
local nSize		:= 0 
local cFile		:= ''   
local cReg		:= ''
local lOk			:= .f.
Private dDataRef	:= ddataBase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Dividindo a tela ao meio																 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
aObjects 	:= {	{ 100, 50, .T., .T. },;
					{ 100, 50, .T., .T. } }

aInfo		:= { aSize[1], aSize[2], aSize[3], aSize[4], 5, 5 }
aPosObj	:= msObjSize( aInfo, aObjects, .T. )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Informao layout de importacao																 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
::setLayout(cLayout)

if ::isLayoutVld()

	If !('SIMPRO' $ cLayout)
		dDataRef := DDATREF()[1]
	endIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ MsDialog																 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oDlg := msDialog():New(aSize[7],0,aSize[6]/2,aSize[5]/2,"Importar",,,,,,,,,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Cria o conteiner onde serão colocados browse's							 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oFWLayer := FWLayer():New()
	oFWLayer:init(oDlg, .f.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Divisao da tela em duas linhas de 50%									 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oFWLayer:addLine("Top",40,.f.)
	oFWLayer:addCollumn('Col01',100,.f.,"Top")
	oFWLayer:addWindow('Col01','C1_Win01',"Geral",100,.f.,.f.,,"Top")
	
	oFWLayer:addLine("Down",60,.f.)
	oFWLayer:addCollumn('Col01',100,.f.,"Down")
	oFWLayer:addWindow('Col01','C1_Win02',"Log",100,.f.,.f.,,"Down")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ layer top e down
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oTop  := oFWLayer:getWinPanel('Col01','C1_Win01',"Top")
	oDown := oFWLayer:getWinPanel('Col01','C1_Win02',"Down") 

	oRodape 		:= tPanelCss():new(0,0,"",oDown,,.f.,.f.,,,0,0,.t.,.f.)
	oRodape:align := CONTROL_ALIGN_ALLCLIENT
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ mget
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	nSize := int((aSize[5]/2)*0.35)

	@ 07,10 say oSay prompt STR0001 size 40,10 of oTop pixel  //"Arquivo"
	@ 05,32 msGet oGet var cFile size nSize,10 of oTop pixel 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ botao
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	tButton():new(06,nSize+32, "..."	,oTop,{|| cFile := getFile() }, 010, 010,,,,.t.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Barra de botoes
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oBtn := FWFormBar():New(oTop)
	oBtn:addOK( {|| cReg := doIt(Self,cFile) }, 'Importar' )
	oBtn:addClose( {|| oDlg:End() }, 'Fechar' )
	oBtn:activate()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Exibe log
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	@ 001,001 get oReg var cReg size (oRodape:nClientWidth/2)-2,(oRodape:nClientHeight/2)-2 of oRodape MULTILINE HSCROLL pixel READONLY
	oReg:bRClicked := {||allwaysTrue()}
	oReg:oFont		 := tFont():New("Courier New",0,16)
	
	oDlg:lCentered := .t.
	oDlg:activate()
else
	PLShelp(STR0002+chr(13)+STR0003)		 //"Layout informado invalido!"###"Favor verificar."
endIf	       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da rotina...                                                         
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return(nil)   

/*/{Protheus.doc} getFile
Mostrar pastas e arquivos

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
static function getFile()
return(cGetFile("*.TXT|*.txt",STR0004,1 ,"c:\",.t.,GETF_LOCALHARD + GETF_NETWORKDRIVE)) //"Selecione o Arquivo"


/*/{Protheus.doc} vldFile
Valida arquivo

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
static function vldFile(cFile,lChk)
local nHd	 := 0
local lRet := .t.

default lChk	:= .t.

if lChk
	nHd  := fOpen(cFile, FO_READ)
	
	lRet := !(empty(cFile) .or. !file(cFile) .or. nHd == -1)
	
	fClose(nHd)
	nHd := nil
endIf

if !lRet
	PLShelp(STR0005+chr(13)+STR0006)		 //"Não foi possível abrir o arquivo de entrada."###"Favor verificar parâmetros."
endIf

return(lRet)

/*/{Protheus.doc} doIt
Inicia o processo de importacao

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
static function doIt(oObj,cFile)
local cErro := ''
 
if vldFile(cFile)
	processa( {|| cErro := oObj:import(cFile,.f.) }, STR0007, STR0008,.f.) //"Aguarde"###"Processando..."
endIf	

return(cErro)

/*/{Protheus.doc} findVal
Retorna o conteudo da matriz conforme chave

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
static function findVal(aMat,cField)
local cConteudo 	:= ''
local nPos		:= 0

if ( nPos := ascan( aMat,{|x| x[1] == cField } ) ) > 0
	cConteudo := aMat[nPos,3]
endIf 

return cConteudo


/*/{Protheus.doc} gravaDad
Grava dados

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
static function gravaDad(lDImp,cFile,cModel,cTipOpeI,cTipOpeA,aDadXZ4,aDadXZ5,cFPreExe,cFPosExe,cFTraDad,cFVldOpe,cSeparador,cLayout,cTipo,cOriCan,lMultCanal) 
local nI,nY,nX	:= 0
local nH 			:= 0	
local nItErro		:= 0
local nPos		:= 0
local nTam		:= 0
local nIni		:= 0
local nFim		:= 0
local nQtdReg		:= 0
local nQtdLin		:= 0
local cCanalXZ5	:= ''
local cField		:= ''
local xConteudo	:= ''
local cChave		:= ''
local cUnico		:= ''
local cAuxExe		:= ''
local cType		:= ''
local cExec		:= ''
local cTable		:= ''
local cAuxTable	:= ''
local cIdModel	:= ''
local cPar		:= ''
local cV 			:= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
local cErro		:= 'Importação concluída com Sucesso'
local cLineAux	:= ''
local cLineOld	:= ''
local cFunName	:= ''
local xRet		:= ''
local cParam		:= ''
local cParamIte	:= '' 
local cPosExe		:= ''
local cIdModPai	:= ''
local lSeparador	:= !empty(cSeparador)
local lRet		:= .t.
local lFound		:= .f.
local lRegVld		:= .t.
local lAddLine	:= .f.
local lCab		:= .t.
local lVldOpe		:= .f.
local lRetDad		:= .t.
local lVldPai		:= .t.
local aErro		:= {}
local	aIdx 		:= {}
local aAux		:= {}
local aDadCon		:= {}
local aStruct		:= {}
local aMatA		:= {}
local aTable		:= {}
local aMatLine	:= {}
local aRegXZ5		:= {}
local oModel 		:= nil
local lPergPdr := .T.
local lFPreExe      := existBlock(cFPreExe)
local lFTraDad      := existBlock(cFTraDad)
local lFVldOpe      := existBlock(cFVldOpe)
local lFPosExe      := existBlock(cFPosExe)
local lFunName      := .F.

default lDImp := .t.

//MVC
if cTipo == '2'
	oModel := FWLoadModel(cModel)
//Funcao	
else
	cFunName := cModel
endIf	

If !empty(cFunName)
	lFunName := existBlock(cFunName)
EndIf 

nH 		 := ft_fUse(cFile)
nQtdLin := ft_fLastRec()

if !lDImp
	procRegua(nQtdLin)
endIf	
	 
ft_fGotop()

if nH <> -1
	cTIni := time()
	while (!ft_fEof())
		cLine	:= ft_fReadLn()
		 
		nQtdReg++

		if aT('"',cLine)>0
			nIni 		:= aT('"',cLine)+1
			cLineAux	:= subStr(cLine,nIni)
			nFim 		:= aT('"',cLineAux)-1
			cLineOld	:= subStr(cLine,nIni,nFim)
			cLineAux	:= strTran(cLineOld,";",'')
			cLine 	 	:= strTran(cLine,cLineOld,cLineAux)
			cLine	 	:= strTran(strTran(cLine,'"',' '),"'",' ')
		endIf
		
		if empty(cLine)
			ft_fSkip()
			loop
		endIf
			
		if lSeparador
			cLine		:= strTran(cLine,cSeparador," "+cSeparador)
			aMatLine 	:= strToKarr(cLine,cSeparador)
		endIf
		
		aTable		:= {}
		lRegVld	:= .t.
		cIdModPai 	:= ''
		
		if !lDImp
			incProc()
		endIf
		
		//MVC
		if cTipo == '2'

			//atribui valor a variavel
			lVldPai := .t.	
			for nI:=1 to len(aDadXZ5)
				cTable		:= aDadXZ5[nI,1,1]
				cPosExe	:= aDadXZ5[nI,1,5]
				aAux 		:= aDadXZ5[nI,2]
				aRegXZ5	:= {} 
								
				lVldPai := retDad(@aRegXZ5,lSeparador,cLine,aMatLine,aAux,cTable,cPosExe,,cIdModel,,,oModel)

				for nY:=1 to len(aRegXZ5)
					if aRegXZ5[nY,len(aRegXZ5[nY])]
						&(aRegXZ5[nY,1]) := aRegXZ5[nY,2]
					endIf	 	
				next
			next
			
			if lVldPai
				//Field x Linha do txt	
				aDadCon := {}
				for nI:=1 to len(aDadXZ4)
					cTable		:= aDadXZ4[nI,1,1]
					cIdModel	:= aDadXZ4[nI,1,2]
					cPosExe	:= aDadXZ4[nI,1,5]
					aAux		:= aDadXZ4[nI,2]
					aIdx 		:= PLGETUNIC(cTable)
					aStruct 	:= oModel:getModel(cIdModel):getStruct():getFields()
					
					if empty(cIdModPai)
						cIdModPai := cIdModel
					endIf
					
					(cTable)->(dbSetOrder(aIdx[1]))
					
					cUnico	:= allTrim(aIdx[2])
					cChave	:= strTran(strTran(strTran(cUnico,'+',''),'DTOS(',''),')','') 
					
					//retira da linha o conteudo a ser gravado
					lRetDad := retDad(@aDadCon,lSeparador,cLine,aMatLine,aAux,cTable,cPosExe,aStruct,cIdModel,cUnico,@cChave,oModel)
					
					//Verifica se todos os campos da chave primaria esta no layout
					if cTable $ cChave
						PLShelp(STR0009) //"O Layout não contem todos os campos da chave primaria!"
						lRet := .f.
						exit
					endIf
		
					//Verifica se o registro ja existe na base de dados
					lFound := (cTable)->(msSeek(cChave))
					aadd(aTable,{cTable,cChave})	
					
					if lRegVld
						
						oModel:setOperation(MODEL_OPERATION_INSERT)
				
						//Permite inclui ou alterar 
						if cTipOpeI == '2'
							if lFound
								//altera
								if cTipOpeA == '1'
									oModel:setOperation(MODEL_OPERATION_UPDATE)
								//exclui e inclui	
								else
									oModel:setOperation(MODEL_OPERATION_DELETE)
									
									if (lRet := oModel:activate())
										if (lRet := oModel:vldData())							
											if (lRet := oModel:commitData())
												oModel:deActivate()
												oModel:setOperation(MODEL_OPERATION_INSERT)
											endIf
										endIf		
									endIf
								endIf
							endIf	
						endIf
					else 
						lAddLine := !lFound .and. lRetDad
					endIf
					lRegVld := .f.
					
					if !lRet .AND. lPergPdr
						exit
					endIf	
					//coloca na memoria
					regToMemory(cTable,oModel:getOperation()==3)
				next
			
				if lRet
					//ativa o modelo
					if (lRet := oModel:activate())
			
						//Pre execucao PLSMPREE
						if !empty(cFPreExe)
							if lFPreExe
								oModel := execBlock(cFPreExe,.f.,.f.,{	{.t.,cLayout},;//Com ou sem interface e o nome do layout
																			{lAddLine,cLine,aMatLine,aDadCon,aTable},;//Vetor com informacoes adicionais
																			{cFile,cModel,cTipOpeI,cTipOpeA,aDadXZ4},;//Vetor com definicoes do layout
																			oModel } )//Modelo de dado preenchido
							else
								oModel := execBlock("PLSMPREE",.f.,.f.,{	{.t.,cLayout},;//Com ou sem interface e o nome do layout
																			{lAddLine,cLine,aMatLine,aDadCon,aTable},;//Vetor com informacoes adicionais
																			{cFile,cModel,cTipOpeI,cTipOpeA,aDadXZ4},;//Vetor com definicoes do layout
																			oModel } )//Modelo de dado preenchido
							endIf																		
						endIf
				
						//detail se for linha nova precisa incluir no grid
						if lAddLine .and. !oModel:getModel(cIdModel):isEmpty()
							oModel:getModel(cIdModel):addLine()
							lRet := oModel:getModel(cIdModel):isInserted()
						endIf
			
						if lRet		
							//Trata dados	PLSMTRAD
							if !empty(cFTraDad)
								if lFTraDad
									oModel := execBlock(cFTraDad,.f.,.f.,{	{.t.,cLayout},;//Com ou sem interface e o nome do layout
																				{lAddLine,cLine,aMatLine,aDadCon,aTable},;//Vetor com informacoes adicionais
																				{cFile,cModel,cTipOpeI,cTipOpeA,aDadXZ4},;//Vetor com definicoes do layout
																				oModel } )//Modelo de dado preenchido
								else
									oModel := execBlock("PLSMTRAD",.f.,.f.,{	{.t.,cLayout},;//Com ou sem interface e o nome do layout
																				{lAddLine,cLine,aMatLine,aDadCon,aTable},;//Vetor com informacoes adicionais
																				{cFile,cModel,cTipOpeI,cTipOpeA,aDadXZ4},;//Vetor com definicoes do layout
																				oModel } )//Modelo de dado preenchido
								endIf																		
							endIf
						
							//Atribui valor ao modelo
							if (lRet := setModeVal(oModel,aDadCon))
			
								//validacao e commit dados
								if (lRet := oModel:vldData())
									
									//Valida operacao PLSMVALO	
									if !empty(cFVldOpe)
										if lFVldOpe
											lRet := execBlock(cFVldOpe,.f.,.f.,{	{.t.,cLayout},;//Com ou sem interface e o nome do layout
																						{lAddLine,cLine,aMatLine,aDadCon,aTable},;//Vetor com informacoes adicionais
																						{cFile,cModel,cTipOpeI,cTipOpeA,aDadXZ4},;//Vetor com definicoes do layout
																						oModel } )//Modelo de dado preenchido
										else
											lRet := execBlock("PLSMVALO",.f.,.f.,{	{.t.,cLayout},;//Com ou sem interface e o nome do layout
																						{lAddLine,cLine,aMatLine,aDadCon,aTable},;//Vetor com informacoes adicionais
																						{cFile,cModel,cTipOpeI,cTipOpeA,aDadXZ4},;//Vetor com definicoes do layout
																						oModel } )//Modelo de dado preenchido
										endIf																		
									endIf
									
									if lRet		
										lRet := oModel:commitData()
									endIf	
								endIf
							endIf
						endIf
						//Pos execucao PLSMPOSE
						if !empty(cFPosExe)
							if lFPosExe
								execBlock(cFPosExe,.f.,.f.,{	{.t.,cLayout},;//Com ou sem interface e o nome do layout
																	{lAddLine,cLine,aMatLine,aDadCon,aTable},;//Vetor com informacoes adicionais
																	{cFile,cModel,cTipOpeI,cTipOpeA,aDadXZ4},;//Vetor com definicoes do layout
																	oModel,;//Modelo de dado preenchido
																	!lRet })//Erro na importacao
							else
								execBlock("PLSMPOSE",.f.,.f.,{	{.t.,cLayout},;//Com ou sem interface e o nome do layout
																	{lAddLine,cLine,aMatLine,aDadCon,aTable},;//Vetor com informacoes adicionais
																	{cFile,cModel,cTipOpeI,cTipOpeA,aDadXZ4},;//Vetor com definicoes do layout
																	oModel,;//Modelo de dado preenchido
																	!lRet })//Erro na importacao
							endIf																		
						endIf
					endIf
				endIf
					
				if !lRet
					nItErro += 1
					aErro := oModel:getErrorMessage()
					// A estrutura do vetor com erro e:
					autoGrLog(STR0010 + allToChar(aErro[1])) //"Id do formulário de origem: "
					autoGrLog(STR0011 + allToChar(aErro[2])) //"Id do campo de origem.....: "
					autoGrLog(STR0012 + allToChar(aErro[3])) //"Id do formulário de erro..: "
					autoGrLog(STR0013 + allToChar(aErro[4])) //"Id do campo de erro.......: "
					autoGrLog(STR0014 + allToChar(aErro[5])) //"Id do erro................: "
					autoGrLog(STR0015 + allToChar(aErro[6])) //"Mensagem do erro..........: "
					autoGrLog(STR0016 + allToChar(aErro[7])) //"Mensagem da solução.......: "
					autoGrLog(STR0017 + allToChar(aErro[8])) //"Valor atribuido...........: "
					autoGrLog(STR0018 + allToChar(aErro[9])) //"Valor anterior............: "
				
					if nItErro > 0
						autoGrLog(STR0019 + allTrim( allToChar(nItErro) ) + "]") //"Erro no Item.......: ["
					endIf
				
					cErro := mostraErro('\logpls')
					//exit
				endIf
				
				oModel:deActivate()
			endIf	
		//Funcao	
		else
			//variaveis x Linha do txt	
			for nI:=1 to len(aDadXZ5)
				cTable		:= aDadXZ5[nI,1,1]
				cPosExe	:= aDadXZ5[nI,1,5]
				aAux 		:= aDadXZ5[nI,2]
				lCab		:= (nI==1) 		
				cCanalXZ5	:= iif(lCab,'CAB','ITE')
				aReg		:= {} 
				
				retDad(@aReg,lSeparador,cLine,aMatLine,aAux,cTable,cPosExe)
				
				if lCab .and. !empty(aDadCon) .and. !empty(cFVldOpe)
					
					//Valida operacao PLMOVAO
					if lFVldOpe
						lVldOpe := execBlock(cFVldOpe,.f.,.f.,{ {.t.,cLayout},{.f.,cLine,aMatLine,aDadCon,{},aReg},{cFile,'',cTipOpeI,cTipOpeA,aDadXZ5},nil })				
					else
						lVldOpe := execBlock("PLMOVAO",.f.,.f.,{ {.t.,cLayout},{.f.,cLine,aMatLine,aDadCon,{},aReg},{cFile,'',cTipOpeI,cTipOpeA,aDadXZ5},nil })
					endIf
					
					if lVldOpe
						//dados movimentacao ADAPTER
						if lFunName
							xRet := execBlock(cFunName,.f.,.f.,{aDadCon})				
						else
							xRet := &(cFunName+'(aDadCon)')
						endIf	
						
						if !empty(xRet)
							cErro := xRet
							exit
						endIf
						
						aDadCon:= {}
					elseIf lMultCanal
						loop	
					endIf
				endIf
					
				//Canal e seu registro
				aadd(aDadCon,{cCanalXZ5,aReg})
			next
			
			//ultima linha do arquivo
			if nQtdReg == nQtdLin
				//dados movimentacao ADAPTER
				if lFunName
					xRet := execBlock(cFunName,.f.,.f.,{aDadCon})				
				else
					xRet := &(cFunName+'(aDadCon)')
				endIf	
				
				if !empty(xRet)
					cErro := xRet
					exit
				endIf
				
				aDadCon:= {}
			endIf
		endIf
		
		if !lRet .AND. lPergPdr 
			If  MsgYesNo("Foi encontrado um erro na importação, Deseja Continuar com o Processo ?")
				lPergPdr := .F.
			Else
				exit
			EndIf
		endIf

		If !lPergPdr
			lRet := .T.
		EndIf
								
		ft_fSkip()
	endDo

	ft_fUse()
endIf
nH := nil

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', 'Inicio.: ' + cTIni + ' Fim .: ' + time() + ' Quantidade de linhas no arquivo.:' + allTrim(cValtoChar(nQtdReg))  , 0, 0, {})

return(cErro)

/*/{Protheus.doc} retDad
Retorna a matriz contendo os dados da linha

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
static function retDad(aReg,lSeparador,cLine,aMatLine,aAux,cTable,cPosExe,aStruct,cIdModel,cUnico,cChave,oModel)
local nY 			:= 0
local nX			:= 0
local nIni 		:= 0
local nFim 		:= 0
local nTam		:= 0
local nPos		:= 0
local nIniPos		:= 0 
local cField		:= ''
local cExec		:= ''
local cAuxExe		:= ''
local cType		:= ''
local cPar		:= ''
local cV 			:= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
local xConteudo 	:= ''
local cCond		:= ''
local lTxt		:= .f.
local lRet		:= .t.
local aMatA		:= {}

default aStruct	:= {}
default aReg		:= {}
default cIdModel	:= '' 
default cUnico	:= ''
default cChave	:= ''
default cTable	:= ''
default cPosExe	:= ''
default oModel	:= nil

if !empty(cPosExe)
	nIniPos := len(aReg)+1
endIf

for nY:=1 to len(aAux)
	lTxt	:= aAux[nY,1]
	cField	:= aAux[nY,2]
	cExec	:= upper(aAux[nY,3])
	cType	:= aAux[nY,5]
	cCond	:= aAux[nY,6]
	nIni 	:= 0
	nFim 	:= 0
	
	if lTxt
		aMatA := strToKarr(aAux[nY,4],';')
		
		if !empty(cExec)
			cAuxExe	:= left(cExec,at('(',cExec)-1)
			cExec		:= subStr(cExec,at('(',cExec))

			for nX:=1 to len(cV)
				cPar := "X"+subStr(cV,nX,1)
				if at(cPar,cExec)>0
					cExec := strTran(cExec,cPar,"%$"+subStr(cV,nX,1))
				else
					exit
				endIf	
			next
		endIf
		
		for nX:=1 to len(aMatA)
			xConteudo := retConteudo(lSeparador,cLine,aMatLine,aMatA[nX],@nIni,@nFim)
			
			if !empty(cExec)
				cExec := strTran(upper(cExec),'%$'+subStr(cV,nX,1),'"'+xConteudo+'"')
			endIf
		next
			
		if !empty(cExec)
			cExec := cAuxExe + cExec
		endIf	
	endIf
	xConteudo 	:= iif(!empty(cExec),&cExec,xConteudo)
	
	if len(aStruct)>0
		if cType == 'C'
			if (nPos := aScan(aStruct,{|x| allTrim(x[3]) == allTrim(cField)} )) > 0
				nTam 		:= aStruct[nPos,5]
				xConteudo	:= xConteudo+space(nTam-len(xConteudo))
			endIf
		endIf
		
		if valType(xConteudo) == 'C'
			cChave := AnsiToOem(strTran(cChave,cField,xConteudo))
		elseif valType(xConteudo) == 'D'
			cChave := strTran(cChave,cField,dtos(xConteudo))
		elseif valType(xConteudo) == 'N'
			cChave := strTran(cChave,cField,cValToChar(xConteudo))
		endIf
	endIf	
	
	if cType == 'N' .and. valType(xConteudo) <> 'N'
		if at(',',xConteudo)>0
			xConteudo := val(strTran(strTran(xConteudo,'.',''),',','.'))
		else	
			xConteudo := val(xConteudo)
		endIf	
	elseIf cType == 'D' .and. valType(xConteudo) <> 'D'
		xConteudo := stod(xConteudo)
	elseIf valType(xConteudo) == 'C' .and. nTam>0
		xConteudo := OEMToANSI(subStr(xConteudo,0,nTam))	
	endIf

	if len(aStruct)>0
		aadd(aReg,{cIdModel,cUnico,cType,cField,xConteudo,cTable,nIni,nFim,lSeparador,oModel,lRet})
	else	
		aadd(aReg,{cField,xConteudo,lRet})
	endIf	
next

if !empty(cPosExe)
	//Registro referente a linha do canal (detalhe do canal) - PLSMPEXE
	if existBlock(cPosExe)
		lRet := execBlock(cPosExe,.f.,.f.,{aReg}) 
	else
		lRet := &(cPosExe+'(aReg)')
	endIf
	
	if !lRet
		for nY:=nIniPos to len(aReg)
			aReg[nY,len(aReg[nY])] := lRet
		next
	endIf
endIf

return(lRet)

/*/{Protheus.doc} retConteudo
Retorna o conteudo da linha x posicao

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
static function retConteudo(lSeparador,cLine,aMatLine,aMatA,nIni,nFim)
local aMatS		:= {}
local xConteudo 	:= ''

default nIni := 0
default nFim := 0
							
if !lSeparador	 			
	aMatS		:= strToKarr(aMatA,'-')
	nIni 		:= val(aMatS[1])
	nFim 		:= val(aMatS[2])-nIni
	xConteudo	:= subStr(cLine,nIni,nFim)
else
	nIni 		:= val(aMatA)
	xConteudo	:= 'nil'
	if nIni <= len(aMatLine)
		xConteudo := aMatLine[nIni]
	endIf						
endIf	

return(upper(allTrim(xConteudo)))

/*/{Protheus.doc} setModeVal
Somente para compilar a class

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
static function setModeVal(oModel,aDadXZ4)
local nI,nY		:= 0
local lRet		:= .t.
local lValid		:= .t.
local cIdModel	:= ''
local cUnico		:= ''
local cField		:= ''
local cTable		:= ''
local xConteudo	:= ''
local cAuxM		:= ''

for nI:=1 to len(aDadXZ4)
	cIdModel	:= aDadXZ4[nI,1]
	cUnico		:= aDadXZ4[nI,2]
	cField		:= aDadXZ4[nI,4]
	xConteudo	:= aDadXZ4[nI,5]
	cTable		:= aDadXZ4[nI,6]
	lValid		:= aDadXZ4[nI,11]
	
	if !lValid
		loop
	endIf
	
	if cIdModel <> cAuxM
		cAuxM := cIdModel
		oModelD := oModel:getModel(cIdModel)
		
		if oModelD:className() == "FWFORMGRID" .and. !oModelD:isInserted()
			if oModelD:length()>1
				for nY:=1 to oModelD:length()
					oModelD:setLine(nY)
					if (cTable)->(recno()) == oModelD:getDataId()
						exit
					endIf
				next
			endIf	
		endIf
	endIf	
	
	//seta atualiza o modelo
	if allTrim(cField) $ cUnico .and. !empty(oModelD:getValue(cField)) 
		loop 
	endIf	
	
	lRet := oModelD:setValue(cField, xConteudo)
	
	if !lRet
		exit
	endIf	
next

return(lRet)

/*/{Protheus.doc}  __PIMP
Importacao chamado direto no menu arotina

@author Alexander Santos
@since 11/02/2014
@version P11
/*/

function __PIMP(cLayout)
local oPMile := PLSMILE():new()
 
oPMile:dialog(cLayout)

oPMile := nil

return

/*/{Protheus.doc} PLSMILE
Somente para compilar a class

@author Alexander Santos
@since 11/02/14
@version 1.0
/*/
function PLSMILE
return


//-------------------------------------------------------------------
/*/{Protheus.doc} DDATREF
Tela para que o usuário informe a data de referência
@author Oscar Zanin
@since 10/06/2019
@version P12
/*/
//-------------------------------------------------------------------
STATIC Function DDATREF()

LOCAL oFont
LOCAL oDlg
Local dData		:= StoD("  /  /    ") //dDatabase
LOCAL nOpca		:= 0
Local aRetorno 	:= {}
Local lStatus		:= .F.

//Define a Fonte do Objeto
DEFINE FONT oFont NAME "Arial" SIZE 000,-012 BOLD

//Cria a Dialog para interação do usuário
DEFINE MSDIALOG oDlg TITLE "Data de referência" FROM 008.2,003.3 TO 020,055 OF GetWndDefault()

@ 20,40 Say oSay PROMPT "Informe a data de referência para importação." SIZE 160,10 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE
@ 30,30 Say oSay PROMPT " Caso em branco, será usada a database do sistema" SIZE 160,10 OF oDlg PIXEL FONT oFont COLOR CLR_HBLUE
@ 43,65 MSGET oGet1 VAR dData SIZE 070,10 OF oDlg FONT oFont PIXEL

//Botão Confirmar
TButton():New(65,080, 'Confirmar',,{|| Iif( ValDatRef(dData, @lStatus) /*pré-validação e definição se houve interação com o botão confirmar*/, Eval( {|| nOpca:=1,oDlg:End() } ),/*Eval( {|| PLS001CONF(dData) ,.F.} )*/ ) },040,012,,,,.T.)

//Ativa a Dialog
ACTIVATE MSDIALOG oDlg CENTERED

//Grava retorno
AAdd(aRetorno, If(!lStatus, ddataBase, dData) )
AAdd(aRetorno, lStatus)

Return(aRetorno)

static Function ValDatRef(dData, lStatus)

Local lRet := .F.

If (!Empty(dData))
	
	lRet := .T.
	
EndIf

lStatus := lRet

Return (.T.)