#INCLUDE "PLSSINCRO.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER2.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "XMLXFUN.CH"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Define variaveis STATIC
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

static bBlockXml	:= &( "{|| errorBlock( {|e| PLERRCONT( e:ERRORSTACK ) } ) }" )

/*/{Protheus.doc} PLSSINCRO
Programa para sincronizacao de dados conforme xsd e xml

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
function PLSSINCRO()
local lChReg		:= .f.
local nOpca     := 0
local nI			:= 0
local nList 		:= 1
local cSeq		:= space(5)
local cDesObs		:= space(60)
local cendereco	:= ""
local bOK       := {|| nOpca := K_OK, oDlg:end() }
local bCancel   	:= {|| oDlg:end() }
local aRet		:= {"",nil}
local oDlg		:= nil
local oBotCSV		:= nil
local oBotXML		:= nil
local oBotVLD		:= nil
local oBotSIN		:= nil
local oBotIMP		:= nil
local oChReg		:= nil
local oGetCon		:= nil
local oGetDes 	:= nil
local oBtXSD		:= nil
local oBtXML		:= nil
local oBtCSV		:= nil
local oSayXSD		:= nil
local oSayXML		:= nil
local oSayCSV		:= nil

private cDirXSD 		:= ""
private cDirXML 		:= ""
private cArqXSD 		:= ""
private cArqXML 		:= ""
private cDirCSV		:= ""
private lXsdXml		:= .t.
private oList		:= nil
private oMeter		:= nil
private __nRep		:= 120
private lRegPro		:= .f.
private lRegErr		:= .f.
private aRegOld		:= {}
private aRegRai		:= {}
private lDisplay		:= getNewPar("MV_SINDIS",.t.)

private __cFileTmp	:= PLSMUDSIS("\xmlsin\tmp"+DtoS(Date())+StrTran(Time(),":",""))
private cArqGer 		:= "sinxmlsxd.log"
private __cArqLog	:= "xsdlog.txt"
private lLogTud		:= GetNewPar("MV_SINLOG",.f.)
private cChvBA1   := {}
Private  lDBTodos := .f.	

//Cria a pasta no servidor para onde И copiado o (xsd,xml,xls) para tratamento 
If !ExistDir(PLSMUDSIS('\xmlsin'))  
	nResult := MakeDir(PLSMUDSIS("\xmlsin")) 
	If nResult != 0
	  MsgAlert( STR0001 ) //"ImpossМvel criar o diretСrio de trabalho no Servidor"
	  Return
	EndIf
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Definicao de tela
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if Val(GetVersao(.F.)) >= 12 //Valida versЦo 12
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM ndLinIni,ndColIni TO ndLinFin+10,ndColFin OF GetWndDefault() //"Sincronizador de Dados"
Else
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM ndLinIni,ndColIni TO ndLinFin+7,ndColFin OF GetWndDefault() //"Sincronizador de Dados"
Endif

if Val(GetVersao(.F.)) >= 12 //Valida versЦo 12
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Botoes Xsd e Xml
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	@ 005+30,005 BUTTON oBtXSD PROMPT STR0002 ACTION {|| PLSELARQ(@cDirXSD,0) } SIZE 50, 10 OF oDlg PIXEL //"Selecione o XSD"
	@ 005+30,057 MSGet oSayXSD VAR cDirXSD SIZE 295,08 PIXEL OF oDlg PIXEL
	oSayXSD:Disable()
	
	@ 016+30,005 BUTTON oBtXML PROMPT STR0003 ACTION {|| PLSELARQ(@cDirXML,1) } SIZE 50, 10 OF oDlg PIXEL //"Selecione o XML"
	@ 016+30,057 MSGet oSayXML VAR cDirXML SIZE 295,08 PIXEL OF oDlg PIXEL
	oSayXML:Disable()
	
	@ 027+30,005 BUTTON oBtCSV PROMPT STR0047 ACTION {|| PLSELARQ(@cDirCSV,2),cDirXML := '' } SIZE 50, 10 OF oDlg PIXEL//"Selecione o CSV"
	@ 027+30,057 MSGet oSayCSV VAR cDirCSV SIZE 295,08 PIXEL OF oDlg PIXEL
	oSayCSV:Disable()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Botoes de processamento
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	@ 038+30,005 BUTTON oBotCSV PROMPT STR0048 ACTION {|| oBotCSV:Disable(),; //"CSV para XML"
	oBotXML:Disable(),;
		oBotVLD:Disable(),;
		oBotSIN:Disable(),;
		oBotIMP:Disable(),;
		cDirXML := '',oList:Reset(),oList:setArray({''}),;
		lRet := PLCSVXML(),;
		oBotCSV:Enable(),;
		oBotXML:Enable(),;
		iIf(lRet,oBotVLD:Enable(),nil),;
		oBotSIN:Enable(),;
		oBotIMP:Enable() } SIZE 50, 10 OF oDlg PIXEL
	
	@ 038+30,056 BUTTON oBotXML PROMPT STR0049 ACTION {|| oBotXML:Disable(),; //"XML para CSV"
	oBotCSV:Disable(),;
		oBotVLD:Disable(),;
		oBotSIN:Disable(),;
		oBotIMP:Disable(),;
		cDirCSV := '',oList:Reset(),oList:setArray({''}),;
		lRet := PLXMLCSV(),;
		oBotXML:Enable(),;
		oBotCSV:Enable(),;
		iIf(lRet,oBotVLD:Enable(),nil),;
		oBotSIN:Enable(),;
		oBotIMP:Enable() } SIZE 50, 10 OF oDlg PIXEL
	
	@ 038+30,107 BUTTON oBotVLD PROMPT STR0004 ACTION {|| oBotCSV:Disable(),oBotXML:Disable(),oBotVLD:Disable(),; //"Validar"
	oBotSIN:Disable(),;
		oBotIMP:Disable(),;
		lRet := PLINIPRO(.t.),;
		oBotCSV:Enable(),;
		oBotXML:Enable(),;
		oBotVLD:Enable(),;
		iIf(lRet .and. lRegPro,oBotSIN:Enable(),nil),;
		oBotSIN:Enable(),;
		oBotIMP:Enable() } SIZE 50, 10 OF oDlg PIXEL
	
	@ 038+30,158 BUTTON oBotSIN PROMPT STR0005 ACTION {|| oBotCSV:Disable(),oBotXML:Disable(),oBotVLD:Disable(),; //"Processar"
	oBotIMP:Disable(),;
		oBotSIN:Disable(),;
		PLINIPRO(.f.),;
		oBotCSV:Enable(),;
		oBotXML:Enable(),;
		oBotVLD:Enable(),;
		oBotIMP:Enable() } SIZE 50, 10 OF oDlg PIXEL
	oBotSIN:Disable()
	
	@ 038+30,209 BUTTON oBotIMP PROMPT STR0006 	ACTION {|| oBotCSV:Disable(),oBotXML:Disable(),oBotVLD:Disable(),; //"Imprimir"
	lRet := oBotSIN:LACTIVE,;
		oBotSIN:Disable(),;
		oBotIMP:Disable(),;
		PLIMPLOG(),;
		iIf( lRet,oBotSIN:Enable(),nil ),;
		oBotCSV:Enable(),;
		oBotXML:Enable(),;
		oBotVLD:Enable(),;
		oBotIMP:Enable() } SIZE 50, 10 OF oDlg PIXEL
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Busca
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	@ 082,005 GROUP oGruBus TO 87+19,90 OF oDlg LABEL STR0007  COLOR CLR_HBLUE PIXEL //"Busca pela SequЙncia"
	
	@ 062+30,008 MSGet oGetCon VAR cSeq SIZE 40,08  PICTURE "99999" PIXEL OF oGruBus PIXEL
	@ 062+30,049 BUTTON oBotBus PROMPT STR0008 ACTION {||	 aRet := PLBUSSEQ(cSeq,oList),; //"Buscar"
	cSeq := space(5),;
		cDesObs := space(60),;
		iIf( !empty(aRet[1]),;
		( oBotSIN:Disable(), oBotIMP:Disable(), oGetDes:Enable(), oBotSI:Enable(), oBotNO:Enable(), oBotGrv:Enable() ),;
		( oGetDes:Disable(), oBotSI:Disable(), oBotNO:Disable(), oBotGrv:Disable() ) ) } SIZE 30, 10 OF oGruBus PIXEL
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Observacao
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	@ 082,093 GROUP oGruDes TO 87+19,350 OF oDlg LABEL STR0009  COLOR CLR_HBLUE PIXEL //"Desabilita processamento do registro selecionado (Informe a ObservaГЦo)?"
	
	@ 062+30,096 MSGet oGetDes VAR cDesObs SIZE 184-2,08 PICTURE "@!" F3 'PLSSIN' PIXEL OF oGruDes PIXEL
	
	@ 062+30,280 BUTTON oBotSI PROMPT STR0050 ACTION {|| PLDESREG(aRet, .t., allTrim(cDesObs) ) } SIZE 20-1, 10 OF oGruDes PIXEL	 //"SIM"
	
	@ 062+30,300 BUTTON oBotNO PROMPT STR0051 ACTION {|| PLDESREG(aRet, .f., '' ),cDesObs := space(60) } SIZE 20-1, 10 OF oGruDes PIXEL	 //NцO
	
	@ 062+30,320 BUTTON oBotGrv PROMPT STR0052 ACTION {|| PLSACXML(aRet[2]) } SIZE 26-1, 10 OF oGruDes PIXEL //"GRAVAR"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Bloqueia Botoes
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oGetDes:Disable()
	oBotSI:Disable()
	oBotNO:Disable()
	oBotGrv:Disable()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Ocorrencias
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	@ 079+30,005 SAY oSay PROMPT STR0010 SIZE 150,010 OF oDlg PIXEL COLOR CLR_HBLUE //"OcorrЙncias do processo"
	
	oList := TListBox():new(086+30,005,{|u|if(Pcount()>0,nList:=u,nList)},{''},346,143,,oDlg,,,,.t.,,,TFont():New("Courier New",7,14,,.f.,,,,.f.,.f.))
	
	oMeter:= tMeter():New(229+33,05,,,oDlg,346,10,,.t.)
	
Else
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Botoes Xsd e Xml
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	@ 005,005 BUTTON oBtXSD PROMPT STR0002 ACTION {|| PLSELARQ(@cDirXSD,0) } SIZE 50, 10 OF oDlg PIXEL //"Selecione o XSD"
	@ 005,057 MSGet oSayXSD VAR cDirXSD SIZE 295,08 PIXEL OF oDlg PIXEL
	oSayXSD:Disable()
	
	@ 016,005 BUTTON oBtXML PROMPT STR0003 ACTION {|| PLSELARQ(@cDirXML,1) } SIZE 50, 10 OF oDlg PIXEL //"Selecione o XML"
	@ 016,057 MSGet oSayXML VAR cDirXML SIZE 295,08 PIXEL OF oDlg PIXEL
	oSayXML:Disable()
	
	@ 027,005 BUTTON oBtCSV PROMPT STR0047 ACTION {|| PLSELARQ(@cDirCSV,2),cDirXML := '' } SIZE 50, 10 OF oDlg PIXEL//"Selecione o CSV"
	@ 027,057 MSGet oSayCSV VAR cDirCSV SIZE 295,08 PIXEL OF oDlg PIXEL
	oSayCSV:Disable()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Botoes de processamento
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	@ 038,005 BUTTON oBotCSV PROMPT STR0048 ACTION {|| oBotCSV:Disable(),; //"CSV para XML"
	oBotXML:Disable(),;
		oBotVLD:Disable(),;
		oBotSIN:Disable(),;
		oBotIMP:Disable(),;
		cDirXML := '',oList:Reset(),oList:setArray({''}),;
		lRet := PLCSVXML(),;
		oBotCSV:Enable(),;
		oBotXML:Enable(),;
		iIf(lRet,oBotVLD:Enable(),nil),;
		oBotSIN:Enable(),;
		oBotIMP:Enable() } SIZE 50, 10 OF oDlg PIXEL
	
	@ 038,056 BUTTON oBotXML PROMPT STR0049 ACTION {|| oBotXML:Disable(),; //"XML para CSV"
	oBotCSV:Disable(),;
		oBotVLD:Disable(),;
		oBotSIN:Disable(),;
		oBotIMP:Disable(),;
		cDirCSV := '',oList:Reset(),oList:setArray({''}),;
		lRet := PLXMLCSV(),;
		oBotXML:Enable(),;
		oBotCSV:Enable(),;
		iIf(lRet,oBotVLD:Enable(),nil),;
		oBotSIN:Enable(),;
		oBotIMP:Enable() } SIZE 50, 10 OF oDlg PIXEL
	
	@ 038,107 BUTTON oBotVLD PROMPT STR0004 ACTION {|| oBotCSV:Disable(),oBotXML:Disable(),oBotVLD:Disable(),; //"Validar"
	oBotSIN:Disable(),;
		oBotIMP:Disable(),;
		lRet := PLINIPRO(.t.),;
		oBotCSV:Enable(),;
		oBotXML:Enable(),;
		oBotVLD:Enable(),;
		iIf(lRet .and. lRegPro,oBotSIN:Enable(),nil),;
		oBotIMP:Enable() } SIZE 50, 10 OF oDlg PIXEL
	
	@ 038,158 BUTTON oBotSIN PROMPT STR0005 ACTION {|| oBotCSV:Disable(),oBotXML:Disable(),oBotVLD:Disable(),; //"Processar"
	oBotIMP:Disable(),;
		oBotSIN:Disable(),;
		PLINIPRO(.f.),;
		oBotCSV:Enable(),;
		oBotXML:Enable(),;
		oBotVLD:Enable(),;
		oBotIMP:Enable() } SIZE 50, 10 OF oDlg PIXEL
	oBotSIN:Disable()
	
	@ 038,209 BUTTON oBotIMP PROMPT STR0006 	ACTION {|| oBotCSV:Disable(),oBotXML:Disable(),oBotVLD:Disable(),; //"Imprimir"
	lRet := oBotSIN:LACTIVE,;
		oBotSIN:Disable(),;
		oBotIMP:Disable(),;
		PLIMPLOG(),;
		iIf( lRet,oBotSIN:Enable(),nil ),;
		oBotCSV:Enable(),;
		oBotXML:Enable(),;
		oBotVLD:Enable(),;
		oBotIMP:Enable() } SIZE 50, 10 OF oDlg PIXEL
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Busca
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	@ 052,005 GROUP oGruBus TO 77,90 OF oDlg LABEL STR0007  COLOR CLR_HBLUE PIXEL //"Busca pela SequЙncia"
	
	@ 062,008 MSGet oGetCon VAR cSeq SIZE 40,08  PICTURE "99999" PIXEL OF oGruBus PIXEL
	@ 062,049 BUTTON oBotBus PROMPT STR0008 ACTION {||	 aRet := PLBUSSEQ(cSeq,oList),; //"Buscar"
	cSeq := space(5),;
		cDesObs := space(60),;
		iIf( !empty(aRet[1]),;
		( oBotSIN:Disable(), oBotIMP:Disable(), oGetDes:Enable(), oBotSI:Enable(), oBotNO:Enable(), oBotGrv:Enable() ),;
		( oGetDes:Disable(), oBotSI:Disable(), oBotNO:Disable(), oBotGrv:Disable() ) ) } SIZE 30, 10 OF oGruBus PIXEL
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Observacao
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	@ 052,093 GROUP oGruDes TO 77,350 OF oDlg LABEL STR0009  COLOR CLR_HBLUE PIXEL //"Desabilita processamento do registro selecionado (Informe a ObservaГЦo)?"
	
	@ 062,096 MSGet oGetDes VAR cDesObs SIZE 184,08 PICTURE "@!" F3 'PLSSIN' PIXEL OF oGruDes PIXEL
	
	@ 062,280 BUTTON oBotSI PROMPT STR0050 ACTION {|| PLDESREG(aRet, .t., allTrim(cDesObs) ) } SIZE 20, 10 OF oGruDes PIXEL	 //"SIM"
	
	@ 062,300 BUTTON oBotNO PROMPT STR0051 ACTION {|| PLDESREG(aRet, .f., '' ),cDesObs := space(60) } SIZE 20, 10 OF oGruDes PIXEL	 //NцO
	
	@ 062,320 BUTTON oBotGrv PROMPT STR0052 ACTION {|| PLSACXML(aRet[2]) } SIZE 26, 10 OF oGruDes PIXEL //"GRAVAR"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Bloqueia Botoes
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oGetDes:Disable()
	oBotSI:Disable()
	oBotNO:Disable()
	oBotGrv:Disable()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Ocorrencias
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	@ 079,005 SAY oSay PROMPT STR0010 SIZE 150,010 OF oDlg PIXEL COLOR CLR_HBLUE //"OcorrЙncias do processo"
	
	oList := TListBox():new(086,005,{|u|if(Pcount()>0,nList:=u,nList)},{''},346,143,,oDlg,,,,.t.,,,TFont():New("Courier New",7,14,,.f.,,,,.f.,.f.))
	
	oMeter:= tMeter():New(229,05,,,oDlg,346,10,,.t.)
	
Endif

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnChoiceBar(oDlg,bOK,bCancel,.f.,{})
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Confirmacao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if nOpca == K_OK
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da funcao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return

/*/{Protheus.doc} PLINIPRO
Inicio do processamento do arquivo XSD e XML

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
function PLINIPRO(lTp)
local oXml	 := tXmlManager():new()
local cErro	 := ""
local cAviso	 := ""
local oObjAux	 := nil
local aMatXSD	 := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё caminho no servidor
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cArqXSD := PLSMUDSIS("\xmlsin\"+subStr(cDirXSD,rat('\',cDirXSD)+1,len(cDirXSD)))
cArqXML := PLSMUDSIS("\xmlsin\"+subStr(cDirXML,rat('\',cDirXML)+1,len(cDirXML)))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Log
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if lLogTud
	PLSLOGFIL(replicate('-',__nRep),cArqGer)
	PLSLOGFIL("cArqXSD ["+cArqXSD+"]",cArqGer)
	PLSLOGFIL("cArqXML ["+cArqXML+"]",cArqGer)
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Limpa lista
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oList:reset()
oList:setArray({''})
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se os arquivos foram selecionados
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if empty(cDirXSD)
	msgAlert(STR0053)//'Selecione o layout XSD'
	return .f.
endIf

if empty(cDirXML)
	msgAlert(STR0054)//'Selecione o arquivo XML'
	return .f.
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se o arquivo ja foi processado
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
SIX->(dbSetOrder(1))
if SIX->(msSeek("BSA2"))
	BSA->(dbSetOrder(2))//BSA_FILIAL + BSA_CONTEU
	if BSA->(msSeek(xFilial("BSA")+"SIN"+AllTrim(subStr(cDirXML,rat(PLSMUDSIS('\'),cDirXML)+1,len(cDirXML)))))
		if lTp
			if !msgYesNo(STR0013) //"Arquivo jА processado! Deseja validar mesmo assim?"
				return .f.
			endIf
		else
			if !msgYesNo(STR0014) //"Arquivo jА processado! Deseja processar novamente?"
				return .f.
			endIf
		endIf
	endIf
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Habilita checagem
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
lXsdXml := .t.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Tratamento de erro
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
begin sequence
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁCopia para o diretorio de trabalho no servidor
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

if !__copyfile( cDirXSD,PLSMUDSIS("\xmlsin")+substr(cDirXSD,RAt("\",cDirXSD)))
	msgAlert(STR0015)  //"NЦo foi possМvel copiar o arquivo XSD para Аrea de trabalho no Servidor"
	return .f.
endIf


if !__copyfile( cDirXML,PLSMUDSIS("\xmlsin")+substr(cDirXML,RAt("\",cDirXML)))
	msgAlert(STR0011)  //"NЦo foi possМvel copiar o arquivo XML para Аrea de trabalho no Servidor"
	return .f.
endIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Log
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if lLogTud
	PLSLOGFIL(replicate('-',__nRep),cArqGer)
	PLSLOGFIL("cDirXSD ["+cDirXSD+"]",cArqGer)
	PLSLOGFIL("cDirXML ["+cDirXML+"]",cArqGer)
	PLSLOGFIL("XMLSIN ["+PLSMUDSIS("\xmlsin")+"]",cArqGer)
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁReset nos erros
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oXml:resetErrors()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁVerificacao de possivel erro
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

if oXml:parseSchemaFile(cArqXSD)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁParse do XML
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if !oXml:parseFile(cArqXML)
		PLSLOGS(STR0055,,,,.t.) //'XML - Invalido'
		PLERROR(oXml:error())
	endIf
else
	PLSLOGS(STR0056,,,,.t.) //'XSD - Invalido'
	PLERROR(oXml:error())
endIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁRetira arquivo do servidor
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
/*if fErase(cArqXML) == -1
	PLSLOGFIL(STR0012,cArqGer) //"NЦo foi possМvel deletar o arquivo XML da Аrea de trabalho no Servidor"
endIf*/
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁVerifica se os arquivos sao compativeis
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if oXml:schemaValidate()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁRegistra o namespace
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oXml:XPathRegisterNs('ts', "http://localhost" )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁMonta matriz XML
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

	if lXsdXml
		if VALCAMPS(oXml)
			PLPROPRO(oXml,lTp)
		else
			PLSLOGS("Corrija os campos necessАrios antes de realizar a importaГЦo",,,,.t.)//'XSD nЦo И compatМvel com o XML'
			PLERROR(oXml:error())
		endIf	
	else
		PLSLOGS(STR0057,,,,.t.)//'XSD nЦo И compatМvel com o XML'
		PLERROR(oXml:error())
	endIf
else
	PLSLOGS(STR0057,,,,.t.)//'XSD nЦo И compatМvel com o XML'
	PLERROR(oXml:error())
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Tratamento de erro
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
end sequence
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё ErroBlock
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
errorBlock(bBlockXml)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da funcao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return lXsdXml

/*/{Protheus.doc} VALCAMPS
ValidaГЦo dos dados

@author Guilherme Moraes
@since 16/10/2018
@version P12
/*/
function VALCAMPS(oXml)

local cCabec		:= "/ts:sincronizador/ts:cabecalho"
local cCorpo		:= "/ts:sincronizador/ts:corpo"
local cAliasPath	:= ""
local cAlias 	:= ""
local nTotal 		:= oXml:XPathChildCount(cCorpo)
local cRegistroPath	:= "" 
local nI := 0
local aCampos := {}
local lRet := .T.
local aAux := {}
local nPos := 0
local nJ := 0

for nI:=1 to nTotal
	cAlias := "BA3"
	cAliasPath	:= cCorpo+'/ts:'+cAlias+'['+cValToChar(nI)+']'
	cRegistroPath :=cAliasPath + "/ts:registro"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ёverifica se o aliasPath existe
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if !oXml:XPathHasNode(cAliasPath)
		PLSLOGS(STR0061+cAliasPath+"]",.t.,.t.,.t.)//"Problema na leitura do XML ["
		return
	endIf

	if oXml:xPathHasNode(cRegistroPath)
		aCampos := {}
		aCampos := PLMONREG(oXml,cRegistroPath)
		lRet := VALBA3DAT(aCampos, oXml, cRegistroPath)
		if ! lRet
			exit
		endIf
	endIf

	aAux := oXml:xPathGetChildArray(cAliasPath)
	nPos := aScan(aAux,{|x| lower(x[1]) == 'registro'})

	for nJ:=(nPos+1) to len(aAux)
		cAlias := aAux[nJ][1]
		cAliasPath := aAux[nJ][2]
		cRegistroPath :=cAliasPath + "/ts:registro"
		aCampos := {}
		aCampos := PLMONREG(oXml,cRegistroPath)
		lRet := VALBA1DAT(aCampos, oXml, cRegistroPath)
		if ! lRet
			exit
		endIf
	next
next	

return lRet

/*/{Protheus.doc} PLPROPRO
Processamento dos Registros

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLPROPRO(oXml,lTp)
local lOK			:= .t.
local lTpProc		:= .f.
local lRaiz		:= .t.
local nI,nY,nX 	:= 0
local nOpcAnt   	:= 0
local nHoraBase	:= 0
local I__f   	:= 0
local cAliAnt   	:= ""
local cChvIdx		:= ""
local cProtocolo	:= ""
local cSeq		:= ""
local cStatus 	:= ""
local cObsOper 	:= ""
local cCampo	 := ""
local cConteudo  := ""
local cAliasPath := ""
local cCabec	 := "/ts:sincronizador/ts:cabecalho"
local cCorpo	 := "/ts:sincronizador/ts:corpo"
local cRodape	 := "/ts:sincronizador/ts:rodape" 
local cCodOri 	    := oXml:xPathGetNodeValue(cCabec+"/ts:origem/ts:codigo")
local cAliasRaiz := oXml:xPathGetNodeValue(cCabec+"/ts:entidadeRaiz/ts:alias")
local cContChv   := oXml:xPathGetNodeValue(cCabec+"/ts:entidadeRaiz/ts:conteudo")
local nIdx		    := val(oXml:xPathGetNodeValue(cCabec+"/ts:entidadeRaiz/ts:idxChave"))
local cRelac 	 := subStr(oXml:xPathGetNodeValue(cCabec+"/ts:relacionamento"),5) 
local cAlias 	  := subStr(cRelac,1,3)
local nTotal 	 := oXml:XPathChildCount(cCorpo) 
local aEstruRaiz := &(cAliasRaiz)->(dbStruct())
local aTipReg 	 := {}
local aRet	     := {}

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁVariaveis de controle
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
lJuridico 		:= (cAliasRaiz == 'BQC')
Inclui			:= .f.
lPrim260  		:= .f.
cTipReg  		:= space(02)
lMsHelpAuto	:= .t.
lRegPro		:= .f.
lRegErr		:= .f.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁInicia a barra de progresso
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oMeter:set(0)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁLog
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
PLSLOGS(STR0018+iIf(lTp,STR0058,STR0059)+"....",.t.,.t.) //"Iniciando "'ValidaГЦo''Processamento'
PLSLOGS(STR0017+cCodOri+"]",.t.,.t.,.t.)//"Cliente ["
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁSeleciona area e posiciona na chave
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
&(cAliasRaiz)->(dbSetOrder(nIdx))
if !&(cAliasRaiz)->(msSeek( xFilial(cAliasRaiz)+allTrim(cContChv)))
	PLSLOGS(STR0019+xFilial(cAliasRaiz)+cContChv+" ]",.t.,.t.) //"Chave da tabela principal nЦo encontrada [ "
	return
else
	PLSLOGS(STR0020+cAliasRaiz+STR0060+xFilial(cAliasRaiz)+cContChv+"]",.t.,.t.,.t.) //"Registro posicionado na chave da tabela [""]. Chave ["

	COPY cAliasRaiz TO Memory
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁLog logo apos colocar em memoria
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if lLogTud .and. lTp

		PLSLOGFIL(replicate('-',__nRep),cArqGer)
		PLSLOGFIL(STR0021+cAliasRaiz+"]",cArqGer) //"PLPROPRO Memoria (aEstruRaiz) - Alias ["
		PLSLOGFIL(replicate('-',__nRep),cArqGer)

		for nY:=1 to len(aEstruRaiz)
			cCampo	  	:= aEstruRaiz[nY,1]
			cConteudo 	:= &(cCampo)

			PLSLOGFIL(STR0022+cCampo+STR0023+allTrim(PLAJUSCON(,cConteudo,.t.))+"]",cArqGer) //"Campo ["###"], conteudo ["
		next
	endIf
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁTotal de registro para barra de progresso
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oMeter:setTotal(nTotal)

SX3->(dbSetOrder(2))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁNa validacao tem que zerar a matriz
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if lTp
	aRegRai := {}
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁDados do Registro
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
for nI:=1 to nTotal
	cAliasPath	:= cCorpo+'/ts:'+cAlias+'['+cValToChar(nI)+']'
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ёverifica se o aliasPath existe
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if !oXml:XPathHasNode(cAliasPath)
		PLSLOGS(STR0061+cAliasPath+"]",.t.,.t.,.t.)//"Problema na leitura do XML ["
		return
	endIf

	cSeq 		:= oXml:xPathGetNodeValue(cAliasPath+"/ts:sequencia")
	cStatus 	:= oXml:xPathGetNodeValue(cAliasPath+"/ts:status")
	cObsOper	:= oXml:xPathGetNodeValue(cAliasPath+"/ts:obsOperador")
	lOk			:= .t.
	lTpProc	:= .f.
	aRegOld	:= {}
	aTipReg	:= {}
	lDBTodos   := .f.
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁCase
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	do case
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁAguardando processamento
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
    	case cStatus == '0' .or. (lTp .and. cStatus == '2')

			nHoraBase := seconds()

			PLSLOGS(STR0025+cSeq+STR0062+Time()+"]",.t.,.t.,.t.) //"Sequencia [""] - Inicio ["
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁCriacao de todas as variaveis de memoria com alias
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			nOpcAnt := 0
			cAliAnt := ""
			cChvIdx := ""
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ёvalidacao e processamento
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			PLALIPRO(oXml,cSeq,cRelac,cAliasRaiz,cAlias,cAliasPath,nOpcAnt,cAliAnt,cChvIdx,.f.,lRaiz,lTp,aTipReg,aEstruRaiz,@lOk,@lTpProc)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ёhora fim
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			PLSLOGS(STR0026+STR0063+time()+STR0064+allTrim(str(seconds()-nHoraBase,12,3))+STR0065,.t.,.t.,.t.) //"Fim da validacao do registro."" - Hora Fim [""] - Duracao [""] Segundos"
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁStatus
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			cStatus := iIf(lTp,iIf(lOK ,'0','2'),iIf(lOK ,'1','2'))

			oXml:xPathSetNode(cAliasPath+'/ts:status', 'status', noAcento(ansiToOem(cStatus)))

			if lTp .and. cStatus == '0' .and. lTpProc
				lRegPro := .t.
			elseIf	 lTp .and. cStatus == '2' .and. lTpProc
				lRegErr := .t.
			endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁJa foram processados
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		otherWise
			if lTp
				PLSLOGS(STR0025+cSeq+"]",.t.,.t.,.t.) //"Sequencia ["
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//ЁSe existir erro de processamento
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				PLSLOGS(STR0029+cAlias+"]",.t.,.t.,.t.,.t.) //"Tabela ["
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//ЁSe existir erro de processamento
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				cStatus := iIf(cStatus=='1',STR0066,iIf( cStatus=='2',STR0067,STR0068 ) )//'Jа PROCESSADO''COM ERRO''ESTA COM RESTRIгцO DO OPERADOR'

				PLSLOGS(STR0030+cStatus+"]" ,.t.,.t.) //"Registro nЦo pode ser processado pelo motivo ["

	 			if !empty(strTran(cObsOper,chr(10),'') )
					PLSLOGS(STR0031+cObsOper+"]" ,.t.,.t.) //"ObservaГЦo do Operador ["
				endIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//ЁSe existir erro de processamento
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				if cStatus == '2'
					PLSLOGS(STR0032,.t.,.t.) //"Erros no Processamento: "

					if oXml:xPathHasNode(cAliasPath+"/ts:registro/ts:obsProcessamento")
						PLSLOGS(oXml:xPathGetNodeValue(cAliasPath+"/ts:registro/ts:obsProcessamento"),.t.,.t.)
					endIf
				endIf
			endIf
	endCase
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁInclui na lista o processamento e atualiza a barra
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oMeter:set(nI)
	processMessages()
next

//Em caso de inclusЦo, faГo a integraГЦo com a Central apenas apСs incluir todos os beneficiarios do XML
// A fim de evitar que seja incluido um dependente antes do titular, e seja criticado nas validaГУes da central
If !Empty(cChvBA1)
    PLATUCENTRAL("BA1",3 , , , ,, cChvBA1)        	
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁInformacao do Rodape
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cDatHorPro	:= oXml:xPathGetNodeValue(cRodape+"/ts:dataHoraProcessamento")
if oXml:xPathHasNode(cRodape+"/ts:observacao")
	cObs := oXml:xPathGetNodeValue(cRodape+"/ts:observacao")
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁRegistra o processamento do arquivo
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if !lTp
	cProtocolo := dtos(date()) + strTran(time(),":","")

	BSA->(recLock("BSA",.t.))
		BSA->BSA_FILIAL := xFilial("BSA")
		BSA->BSA_NUMSEQ := cProtocolo
		BSA->BSA_IDENT  := "SIN"
		BSA->BSA_VARIAV := ""
		BSA->BSA_CONTEU := "SIN"+allTrim( SubStr( cDirXML,Rat(PLSMUDSIS('\'),cDirXML)+1,Len(cDirXML) ) )
	BSA->(msUnLock())
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁProtocolo de controle
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if !oXml:xPathHasNode(cCabec+"/ts:protocoloControle")
		oXml:xPathAddNode(cCabec, 'protocoloControle', noAcento(ansiToOem(cProtocolo)))
	endIf

	if !oXml:xPathHasNode(cCabec+"/ts:responsavelProcessamento")
		oXml:xPathAddNode(cCabec, 'responsavelProcessamento', noAcento(ansiToOem(allTrim(PLRETOPE()))))
	endIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ёsalva alteracoes no xml
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	PLSACXML(oXml)
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁNa validacao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if lTp
	if lRegPro .and. lXsdXml
		if lRegErr
			PLSLOGS(STR0069,.t.,.t.,.t.) //"ValidaГЦo concluida com sucesso, EXISTEM registros a serem processados e registros com erros"
		else
			PLSLOGS(STR0070,.t.,.t.,.t.)//"ValidaГЦo concluida com sucesso, EXISTEM registros a serem processados"
		endIf
	else
		PLSLOGS(STR0071,.t.,.t.,.t.)//"ValidaГЦo concluida com sucesso, porem NцO EXISTEM registros a serem processados"
	endIf
else
	PLSLOGS(STR0035,.t.,.t.,.t.) //"Processamento terminado com sucesso"
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim do Processo completando a barra de progresso
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oMeter:set(0)
oMeter:set(nTotal)
oMeter:refresh()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rorina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return


/*/{Protheus.doc} PLALIPRO
validacao e processamento de registros

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLALIPRO(oXml,cSeq,cRelac,cAliasRaiz,cAlias,cAliasPath,nOpcAnt,cAliAnt,cChvIdx,lChkTR,lRaiz,lTp,aTipReg,aEstruRaiz,lOk,lTpProc)
local nPos			:= 0
local nI,nX			:= 0
local nOpc			:= 0
local nChave 			:= 0
local I__f   			:= 0
local cTipoDB			:= "0"
local cDataDB			:= ""
local cObsDB			:= ""
local cCampo			:= ""
local cConteudo 		:= ""
local cRegistroPath	:= cAliasPath+"/ts:registro"
local aCampos			:= {}
local aRet			:= {}
local aAux			:= {}
local cMotDB		:= ""

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё verifica se o NO existe
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if oXml:xPathHasNode(cRegistroPath)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁCampos de cada alias
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	nOpc	 := val(oXml:xPathGetNodeValue(cRegistroPath+"/ts:tipoAcao"))
	Inclui	 := (nOpc==K_Incluir)
	lPrim260:= (nOpc==K_Incluir)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁBloqueio/Desbloqueio
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if nOpc == 8
		if oXml:xPathHasNode(cRegistroPath+"/ts:bloqueioDesbloqueio")
			cTipoDB := oXml:xPathGetNodeValue(cRegistroPath+"/ts:bloqueioDesbloqueio/ts:tipo")
			cDataDB := oXml:xPathGetNodeValue(cRegistroPath+"/ts:bloqueioDesbloqueio/ts:data")
			cMotDB	:= oXml:xPathGetNodeValue(cRegistroPath+"/ts:bloqueioDesbloqueio/ts:consid")

			if oXml:xPathHasNode(cRegistroPath+"/ts:bloqueioDesbloqueio/ts:observacao")
				cObsDB := oXml:xPathGetNodeValue(cRegistroPath+"/ts:bloqueioDesbloqueio/ts:observacao")
			endIf
		endIf
	endIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁVerifica se a chave foi informada
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if oXml:xPathHasNode(cRegistroPath+"/ts:chave")
		nChave := val(oXml:xPathGetNodeValue(cRegistroPath+"/ts:chave"))
	endIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё "Validando o registro no Bloqueio/Desbloqueio" e "ReferЙncia do registro na validaГЦo"
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	aCampos := {}
	if (nOpc <> 8 .and. nOpc <> 9)
		aCampos := PLMONREG(oXml,cRegistroPath)
	endIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁValidacao
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if lTp
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁLog
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if lLogTud
			PLSLOGFIL('',cArqGer)
			PLSLOGFIL(replicate('-',__nRep),cArqGer)
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁVerifica se tem algum registro com movimentacao
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if !lTpProc .and. (nOpc != 9)
			lTpProc := .t.
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁIndice do alias pai
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if empty(cChvIdx) .and. lOK
			SIX->(dbSetOrder(01))
			if SIX->(msSeek(cAlias))
			    cChvIdx := allTrim(SIX->CHAVE)
			endIf
		endIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁTratamento para tipo de acao pai-filho
		//Ё3-InclusЦo, 4-Alteracao, 8-Bloqueio/Desboqueio e 9-Referencia.
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if lOK .And. (lTp .and. (nOpc == 3) .or. (nOpcAnt == 3))
			if nOpcAnt == 0 .or. cAliAnt == cAlias
				nOpcAnt := nOpc
				cAliAnt := cAlias
			elseIf nOpcAnt < nOpc .and. nOpc <> 3
				PLATUOB(cRegistroPath,oXml,STR0072+cAliAnt+STR0073+allTrim(Str(nOpcAnt))+STR0074+cAlias+STR0075+allTrim(Str(nOpc))+'] ',.t.)//'AГЦo entre os registros invalida. Anterior - Alias [''] AГЦo [''], Atual - Alias [''] AГЦo ['
				lOK := .f.
			endIf
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁVariavel de controle de erros
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		lMsErroAuto := .f.
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Posiciona no registro com base no recno (chave)
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if nChave > 0 .and. lOK

			&(cAlias)->(dbGoTo(nChave))

			if &(cAlias)->(eof())
				PLATUOB(cRegistroPath,oXml,cAlias+STR0076+allTrim(str(nChave))+STR0077,.t.)//' - Chave - [''], nao encontrada'
				lOK := .f.
			endIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Verifica se esta deletado
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			if &(cAlias)->(deleted())
				PLATUOB(cRegistroPath,oXml,cAlias+STR0078+allTrim(str(nChave))+STR0079,.t.)//' - Registro - [''], deletado'
				lOK := .f.
			endIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Se for alteracao e estiver bloqueado
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			if nOpc==4 .and. !PLVLBLO(cAlias) .and. lOK
				PLATUOB(cRegistroPath,oXml,cAlias+STR0078+allTrim(str(nChave))+STR0080,.t.)//' - Registro - [''], Bloqueado'
				lOK := .f.
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Se for para Desbloqueado e nao tiver bloqueado
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			elseIf nOpc==8 .and. cTipoDB=='1' .and. PLVLBLO(cAlias) .and. lOK
				PLATUOB(cRegistroPath,oXml,cAlias+STR0078+allTrim(str(nChave))+STR0081,.t.)//' - Registro - [''], nao esta Bloqueado'
				lOK := .f.
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Se for para bloquear e estiver bloqueado
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			elseIf nOpc==8 .and. cTipoDB=='0' .and. !PLVLBLO(cAlias,.f.) .and. lOK
				PLATUOB(cRegistroPath,oXml,cAlias+STR0078+allTrim(str(nChave))+STR0082,.t.)//' - Registro - [''], jА se encontra Bloqueado'
				lOK := .f.
			endIf
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Coloca na memoria K_Incluir=3 e K_Alterar=4
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if lOK
			if nOpc==K_Incluir
				COPY cAlias TO Memory Blank
			else
				COPY cAlias TO Memory
			endIf
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁEndereco Raiz
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if lRaiz
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁAjusta alias Principal com alias Raiz
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			if lOK .and. len(aRegRai) == 0
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Montando matriz
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				for nX:=1 to len(aEstruRaiz)
					cCampo		:= aEstruRaiz[nX,1]
					cConteudo	:= &(cCampo)
					cCampo	  	:= allTrim(subStr(cCampo,4))
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//Ё Ajusta o BQC com o BA3 pq o campo NUMCON E O CONEMP NO BA3
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					if cAliasRaiz == 'BQC' .And. cAlias == 'BA3' .And. cCampo == '_NUMCON'
						cCampo := '_CONEMP'
					endIf
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//Ё Ajusta o BT5 com o BQC pq o campo CODIGO BQC tem conteudo diferente BT5
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					if cAliasRaiz == 'BT5' .And. cAlias == 'BQC' .And. cCampo == '_CODIGO'
						cConteudo := &(cAliasRaiz+"_CODINT")+&(cAliasRaiz+cCampo)
					endIf

					if type(cAlias+cCampo) != 'U'
						aadd(aRegRai, {cCampo, cConteudo} )
					endIf
				next
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Log
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				if lLogTud .and. lTp
					for nX:=1 to len(aRegRai)
						PLSLOGFIL(STR0083+aRegRai[nX,1]+STR0023 + allTrim( PLAJUSCON(,aRegRai[nX,2],.t.) ) + "]",cArqGer) //"Campo [""], conteudo ["
					next

					PLSLOGFIL(replicate('-',__nRep),cArqGer)
				endIf
			endIf
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Verifica se o conteudo dos registros sao iguais (relacionados)
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if lOK .and. (nOpc != 3) .and. at(cAlias,cChvIdx) == 0

			if !PLVLDREL(cChvIdx,cAlias)
				PLATUOB(cRegistroPath,oXml,cAlias+STR0084+allTrim(str(nChave))+STR0085)//' - O Registro da chave - [''], nЦo estА relacionado com o registro principal'
				lOK := .f.
			endIf

		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Mostra Erro
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if lMsErroAuto
			PLSME(cAlias)
			lOK := .f.
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁValidacao de campos todos os registros de uma sequencia
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if lOK
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁVariavel de controle de erros
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			lMsErroAuto := .f.
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁAtualiza log
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			PLSLOGS(STR0086 + cAlias + "]",.t.,.t.,.t.,.t.)//"Tabela ["
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Atualizacao campos da tabela raiz no alias pai. Ex: BQC->BA3
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			lOK := PLATRCON(cAlias,aCampos,oXml,aRegRai,aRegOld,.t.,cRegistroPath,nOpc)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Log
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			if nOpc == 8
				PLSLOGS(STR0038,.t.,.t.) //"Validando o registro no Bloqueio/Desbloqueio"
			endIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Log
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			if nOpc == 9
				PLSLOGS(STR0039,.t.,.t.) //"ReferЙncia do registro na validaГЦo"				
			endIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Mostra Erro
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			if lMsErroAuto
				PLSME(cAlias)
				lOK := .f.
			endIf
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁValidacao especifica de familia/usuario
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if lOK
			lOK := PLBA3BA1(cAlias,aCampos,oXml,nOpc,nChave,cRegistroPath,aTipReg,@lChkTR)
    	endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁLog
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if lLogTud
			PLSLOGFIL("cAlias     ["+cAlias+"]",cArqGer)
			PLSLOGFIL("nOpc       ["+allTrim(str(nOpc))+"]",cArqGer)
			PLSLOGFIL("nChave     ["+allTrim(str(nChave))+"]",cArqGer)
			PLSLOGFIL("cEndereco  ["+cRegistroPath+"]",cArqGer)
			PLSLOGFIL("cTipoDB    ["+allTrim(cTipoDB)+"]",cArqGer)
			PLSLOGFIL("lTpProc    ["+iIf(lTpProc,'SIM','NAO')+"]",cArqGer)
			PLSLOGFIL("cChvIdx    ["+cChvIdx+"]",cArqGer)
			PLSLOGFIL("nOpcAnt    ["+allTrim(str(nOpcAnt))+"]",cArqGer)
			PLSLOGFIL("cAliAnt    ["+cAliAnt+"]",cArqGer)
			PLSLOGFIL("cAliasRaiz ["+cAliasRaiz+"]",cArqGer)
			PLSLOGFIL("lChkTR      ["+iIf(lChkTR,'SIM','NAO')+"]",cArqGer)
			PLSLOGFIL("lOK         ["+iIf(lOK,'SIM','NAO')+"]",cArqGer)
			PLSLOGFIL("len(aTipReg)["+allTrim(Str(len(aTipReg)))+"]",cArqGer)
			PLSLOGFIL("MV_PLTRTIT  ["+GetNewPar("MV_PLTRTIT","00")+"]",cArqGer)

			for nI:=1 to len(aTipReg)
				PLSLOGFIL("aTipReg     ["+allTrim(aTipReg[nI])+"]",cArqGer)
			next
		endIf
		
	elseIf lOK
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Variavel de memoria
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if nOpc==K_Incluir
			COPY cAlias TO Memory Blank
		elseIf nOpc == K_Alterar .or. nOpc == 8 .or. nOpc == 9
			If cAlias == "BA3" .AND. nOpc == 9
				If nChave == 0
					nChave := val(oXml:xPathGetNodeValue(cRegistroPath+"/ts:chave"))
				EndIf
				&(cAlias)->(dbGoTo(nChave))
			EndIf
			COPY cAlias TO Memory
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё processamento
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		PLGRVREG(cRelac,cAlias,cSeq,aCampos,oXml,aRegRai,aRegOld,nOpc,cRegistroPath,cTipoDB,cDataDB,cObsDB,nChave,lRaiz,cMotDB)
	endIf
	lRaiz := .f.
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё retira observacao de erro
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if lOk
	if oXml:xPathHasNode(cRegistroPath+"/ts:obsProcessamento")
		oXml:xPathSetNode(cRegistroPath+"/ts:obsProcessamento","obsProcessamento", " ")
	endIf
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё proximo alias
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
aAux := oXml:xPathGetChildArray(cAliasPath)
nPos := aScan(aAux,{|x| lower(x[1]) == 'registro'})

for nI:=(nPos+1) to len(aAux)
	PLALIPRO(oXml,cSeq,cRelac,cAliasRaiz,aAux[nI,1],aAux[nI,2],nOpcAnt,cAliAnt,cChvIdx,lChkTR,lRaiz,lTp,aTipReg,aEstruRaiz,@lOk,@lTpProc)
next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return


/*/{Protheus.doc} PLATRCON
Valida e atribui conteudo a campos M

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLATRCON(cAlias,aCampos,oXml,aRegRai,aRegOld,lTp,cRegistroPath,nOpc)
local lOK			:= .t.
local nY,nPos		:= 0
local cCampo  	:= ""
local cConteudo	:= ""
local aEstruRaiz	:= &(cAlias)->(dbStruct())
default nOpc	:= 0
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Atualiza campos encontrados na raiz das tabelas filhas
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
for nY:=1 to len(aRegRai)
	PLCONTCAM(aRegRai[nY,1],aRegRai[nY,2],cAlias)
next
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Atualizacao de campos comuns M-> do alias filho com base no pai	Ex:BA3->BA1->BF4
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
for nY:=1 to len(aRegOld)
	PLCONTCAM(aRegOld[nY,1],aRegOld[nY,2],cAlias)
next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё For de acao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if len(aCampos) > 0
	for nY:=1 to len(aCampos)
	   cCampo  	:= allTrim(aCampos[nY,1])
	   cCampo  	+= space(10-len(cCampo))
	   cConteudo 	:= aCampos[nY,2]
	   	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Log
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	   if lTp
			PLSLOGS(cCampo + " - [" + cConteudo + "]",.t.,.t.)
		endIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Se for alteracao e o when nao permitir que altere coloca o conteudo do original
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if nOpc == K_Alterar .And. !empty(aCampos[nY,10]) .And. !eval( &(" { || "+allTrim(aCampos[nY,10])+" }") )
			cConteudo := &(cAlias+'->'+cCampo)
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Atribui conteudo do XML para o M-> do campo
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		PLCONTCAM(allTrim(cCampo),cConteudo)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Depois de atribuir o Conteudo do xml valida os campos
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if lTp
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Verifica se e obrigatorio e se tem conteudo
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			if X3Obrigat(aCampos[nY,1]) .and. empty(cConteudo) 
				PLATUOB(cRegistroPath,oXml,STR0087+cCampo+STR0088)//'Conteudo do campo - [''] obrigatorio, nao informado'
				lOK := .f.
			endIf
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Guarda nesta matriz para alimentas M-> relacionados
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if ( nPos := aScan( aRegOld,{|x| upper(x[1]) == upper(subStr(allTrim(cCampo),4))})) == 0
			aadd(aRegOld, {subStr(allTrim(cCampo),4),cConteudo})
		else
			aRegOld[nPos,2] := cConteudo
		endIf
	next
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Relacao e Trigger dos campos do alias
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	for nY:=1 to len(aEstruRaiz)
		cCampo := aEstruRaiz[nY,1]
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Relacao
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if empty(M->&(cCampo)) .and. SX3->(msSeek(cCampo)) .and. !empty(allTrim(SX3->X3_RELACAO))
			M->&(cCampo) := eval(&(" {|| "+allTrim(SX3->X3_RELACAO)+" }"))
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Trigger
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if !empty(M->&(cCampo)) .and. existTrigger(allTrim(cCampo)) .and. upper(SX3->X3_VISUAL) <> 'V'
 			runTrigger(1,nil,nil,,allTrim(cCampo))
	 	endIf
	next
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Para garantir que o gatinho nao limpou o campo
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	for nY:=1 to len(aCampos)
	    cCampo  	:= allTrim(aCampos[nY,1])
	    cCampo  	+= space(10-len(cCampo))
	    cConteudo	:= aCampos[nY,2]
		 //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		 //Ё Atribui conteudo do XML para o M-> do campo
		 //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		 if allTrim(M->&(cCampo)) <> allTrim(cConteudo)
		 	If type(cCampo) == "U" .And. ! Empty(cConteudo) .And. !Empty(SToD(cConteudo))
				M->&(AllTrim(cCampo)) := SToD(cConteudo)
			Else
				PLCONTCAM(allTrim(cCampo),cConteudo )
			EndIf 	
    	 endif
	next
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return lOK

/*/{Protheus.doc} VALBA3DAT
Valida dados da BA3

@author Guilherme Moraes
@since 16/10/2018
@version P12
/*/
static function VALBA3DAT(aCampos, oXml, cRegistroPath)

Local nPos := 0
Local lRet := .T.

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA3_CODEMP' } ) ) > 0
	If Len(aCampos[nPos][2]) < TamSX3("BA3_CODEMP")[1]
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" tamanho incorreto",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA3_CONEMP' } ) ) > 0
	If Len(aCampos[nPos][2]) < TamSX3("BA3_CONEMP")[1]
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" tamanho incorreto",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA3_VERCON' } ) ) > 0
	If Len(aCampos[nPos][2]) < TamSX3("BA3_VERCON")[1]
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" tamanho incorreto",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA3_SUBCON' } ) ) > 0
	If Len(aCampos[nPos][2]) < TamSX3("BA3_SUBCON")[1]
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" tamanho incorreto",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA3_VERSUB' } ) ) > 0
	If Len(aCampos[nPos][2]) < TamSX3("BA3_VERSUB")[1]
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" tamanho incorreto",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA3_CODPLA' } ) ) > 0
	If Len(aCampos[nPos][2]) < TamSX3("BA3_CODPLA")[1]
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" tamanho incorreto",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA3_VERSAO' } ) ) > 0
	If Len(aCampos[nPos][2]) < TamSX3("BA3_VERSAO")[1]
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" tamanho incorreto",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA3_FORPAG' } ) ) > 0
	If Len(aCampos[nPos][2]) < TamSX3("BA3_FORPAG")[1]
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" tamanho incorreto",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA3_SEGPLA' } ) ) > 0
	If Len(aCampos[nPos][2]) < TamSX3("BA3_SEGPLA")[1]
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" tamanho incorreto",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA3_EQUIPE' } ) ) > 0
	If Len(aCampos[nPos][2]) < TamSX3("BA3_EQUIPE")[1]
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" tamanho incorreto",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA3_CODVEN' } ) ) > 0
	If Len(aCampos[nPos][2]) < TamSX3("BA3_CODVEN")[1]
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" tamanho incorreto",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA3_VALID' } ) ) > 0
	If Empty(SToD(aCampos[nPos][2]))
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" formato incorreto (aaaammdd)",.T.)
	EndIf
EndIf

return lRet

/*/{Protheus.doc} VALBA1DAT
Valida dados da BA3

@author Guilherme Moraes
@since 16/10/2018
@version P12
/*/
static function VALBA1DAT(aCampos, oXml, cRegistroPath)

Local nPos := 0
Local lRet := .T.

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA1_OPEORI' } ) ) > 0
	If Len(aCampos[nPos][2]) < TamSX3("BA1_OPEORI")[1]
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" tamanho incorreto",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA1_OPEDES' } ) ) > 0
	If Len(aCampos[nPos][2]) < TamSX3("BA1_OPEDES")[1]
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" tamanho incorreto",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA1_OPERES' } ) ) > 0
	If Len(aCampos[nPos][2]) < TamSX3("BA1_OPERES")[1]
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" tamanho incorreto",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA1_DATNAS' } ) ) > 0
	If Empty(SToD(aCampos[nPos][2]))
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" formato incorreto (aaaammdd)",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA1_DATINC' } ) ) > 0
	If Empty(SToD(aCampos[nPos][2]))
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" formato incorreto (aaaammdd)",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA1_DATADM' } ) ) > 0 
	If !Empty(aCampos[nPos][2])
		If Empty(SToD(aCampos[nPos][2]))
			lRet := .F.
			PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" formato incorreto (aaaammdd)",.T.)
		EndIf
	EndIf	
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA1_DATCAR' } ) ) > 0
	If Empty(SToD(aCampos[nPos][2]))
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" formato incorreto (aaaammdd)",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA1_DATCPT' } ) ) > 0 
	If !Empty(aCampos[nPos][2])
		If Empty(SToD(aCampos[nPos][2]))
			lRet := .F.
			PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" formato incorreto (aaaammdd)",.T.)
		EndIf
	EndIf	
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA1_NOMUSR' } ) ) > 0
	If Empty(aCampos[nPos][2])
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" estА vazio",.T.)
	EndIf
EndIf

If ( nPos := ascan( aCampos, {|x| x[1] == 'BA1_CPFUSR' } ) ) > 0
	If ! Cgc(aCampos[nPos][2],,.F.)
		lRet := .F.
		PLATUOB(cRegistroPath,oXml,aCampos[nPos][1]+" incorreto",.T.)
	EndIf
EndIf

return lRet

/*/{Protheus.doc} PLBA3BA1
Valida BA3 E BA1 verificar se e possivel rdmake

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLBA3BA1(cAlias,aCampos,oXml,nOpc,nChave,cRegistroPath,aTipReg,lChkTR)
local lOK	:= .t.
local nI	:=	0
local nPos:=	0
local aRet:=	{}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁLog logo apos colocar em memoria
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if lLogTud
	PLSLOGFIL("PLBA3BA1",cArqGer)
	PLSLOGFIL(replicate('-',__nRep),cArqGer)
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁInclusao ou alteracao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
do case
	case cAlias == 'BA3'
	    if nOpc == K_Incluir
			M->BA3_MATRIC	:= PLPROXMAT(M->BA3_CODINT,M->BA3_CODEMP)
	      lChkTR 			:= .t.
	    endIf
		If ! VALBA3DAT(aCampos,oXml,cRegistroPath) //16-10
			lOK := .F.
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁLog
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if lLogTud
			PLSLOGFIL("",cArqGer)
			PLSLOGFIL("Alias       ["+cAlias+"]",cArqGer)
			PLSLOGFIL("nOpc        ["+allTrim(str(nOpc))+"]",cArqGer)
			PLSLOGFIL("Matric      ["+M->BA3_MATRIC+"]",cArqGer)
			PLSLOGFIL("lChkTR      ["+iIf(lChkTR,'SIM','NAO')+"]",cArqGer)
		endIf
	case cAlias == 'BA1'

		if nOpc == K_Incluir
			if ( nPos := ascan( aCampos, {|x| x[1] == 'BA1_GRAUPA' } ) ) > 0
				M->BA1_GRAUPA := aCampos[nPos,2]
			endIf

			if ( nPos := ascan( aCampos, {|x| x[1] == 'BA1_TIPUSU' } ) ) > 0
			   M->BA1_TIPUSU := aCampos[nPos,2]
			endIf

			If ! VALBA1DAT(aCampos,oXml,cRegistroPath)//16-10
				lOK := .F.
			EndIf

		   aRet := PLSMonTipRg( M->BA1_GRAUPA,M->BA1_TIPREG,M->BA1_TIPUSU,M->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC) )
		   if aRet[2]
			   M->BA1_TIPREG := aRet[1]
				aadd(aTipReg,M->BA1_TIPREG)
			else
				PLATUOB(cRegistroPath,oXml,STR0089+allTrim(M->BA1_GRAUPA)+'] - ['+allTrim(M->BA1_TIPUSU)+']',.T.)//'O Tipo de registro gerado, ultrapassou o limite para este grau de parentesco. ['
				lOK := .f.
			endIf

			BA1->(DbSetorder(2))
			if BA1->(MsSeek(xFilial("BA1")+M->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+M->BA1_TIPREG))
				PLATUOB(cRegistroPath,oXml,STR0090+M->BA1_TIPUSU+']',.T.)//'Ja existe usuario criado para o tipo de registro gerado - Tipo de Usuario ['
				lOK := .f.
			endIf
	   elseIf nChave > 0
			BA1->(dbGoto(nChave))
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Verifica se algum titular foi informado
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if len(aTipReg)>0 .and. lChkTR
			if (nPos := ascan(aTipReg, {|x| x == getNewPar("MV_PLTRTIT","00") } ) ) == 0
				PLATUOB(cRegistroPath,oXml,STR0091,.t.)//'NЦo foi informado Titular para a Familia'
				If nOpc <> 3 
					lOK := .f.
				EndIf
			elseIf ascan(aTipReg, {|x| x == getNewPar("MV_PLTRTIT","00") },(nPos+1) )>0
				PLATUOB(cRegistroPath,oXml,STR0092,.t.)//'SС И permitido um Titular por FamМlia'
				If nOpc <> 3
					lOK := .f.
				EndIf
			endIf
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁLog
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if lLogTud
			PLSLOGFIL("",cArqGer)
			PLSLOGFIL("Alias       ["+cAlias+"]",cArqGer)
			PLSLOGFIL("nOpc        ["+allTrim(str(nOpc))+"]",cArqGer)
			PLSLOGFIL("Graupa      ["+allTrim(M->BA1_GRAUPA)+"]",cArqGer)
			PLSLOGFIL("TipUsu      ["+allTrim(M->BA1_TIPUSU)+"]",cArqGer)
			PLSLOGFIL("TipReg E    ["+allTrim(M->BA1_TIPREG)+"]",cArqGer)
			PLSLOGFIL("TipReg N    ["+allTrim(M->BA1_TIPREG)+"]",cArqGer)
			PLSLOGFIL("nChave      ["+allTrim(str(nChave))+"]",cArqGer)
		endIf
	case cAlias == 'BF4'

		if nOpc == K_Incluir
			if ( nPos := ascan( aCampos, {|x| x[1] == 'BF4_CODPRO' } ) ) > 0
				M->BF4_CODPRO := aCampos[nPos,2]
			endIf

		   if BF4->( MsSeek( xFilial("BF4")+M->(BA3_CODINT + BA3_CODEMP + BA3_MATRIC + BA1_TIPREG + BF4_CODPRO) ) )
				PLATUOB(cRegistroPath,oXml,STR0093+allTrim( M->( BA3_CODINT + BA3_CODEMP + BA3_MATRIC + BA1_TIPREG ) )+STR0094+allTrim(M->BF4_CODPRO)+']',.T.)//'Opcional jА cadastrado - Matricula [''] - Opcional ['
				lOK := .f.
			endIf
		elseIf nChave > 0

			BF4->(dbGoto(nChave))
			if BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG) <> BF4->(BF4_CODINT + BF4_CODEMP + BF4_MATRIC + BF4_TIPREG )
				PLATUOB(cRegistroPath,oXml,STR0095+allTrim( M->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG) )+STR0096+allTrim(Str(nChave))+']',.T.)//'Verifique o relacionamento dos registros - Matricula [''] - Chave ['
				lOK := .f.
			endIf
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁLog
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if lLogTud
			PLSLOGFIL("",cArqGer)
			PLSLOGFIL("Alias       ["+cAlias+"]",cArqGer)
			PLSLOGFIL("nOpc        ["+allTrim(Str(nOpc))+"]",cArqGer)
			PLSLOGFIL("CodPro      ["+allTrim(M->BF4_CODPRO)+"]",cArqGer)
			PLSLOGFIL("Chave BF4 M ["+allTrim(M->(BA3_CODINT + BA3_CODEMP + BA3_MATRIC + BA1_TIPREG + BF4_CODPRO) )+"]",cArqGer)
			PLSLOGFIL("Chave BA1   ["+allTrim(BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG) )+"]",cArqGer)
			PLSLOGFIL("Chave BF4   ["+allTrim(BF4->(BF4_CODINT + BF4_CODEMP + BF4_MATRIC + BF4_TIPREG ) )+"]",cArqGer)
			PLSLOGFIL("nChave      ["+allTrim(Str(nChave))+"]",cArqGer)
		endIf
endCase
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rorina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return lOK

/*/{Protheus.doc} PLGRVREG
Processa Registro (Gravacao)

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLGRVREG(cRelac,cAlias,cSeq,aCampos,oXml,aRegRai,aRegOld,nOpc,cRegistroPath,cTipoDB,cDataDB,cObsDB,nChave,lRaiz,cMotDB)
local nY			:= 0
local I__f   	:= 0
local nPos		:= 0
local nOrdBTS 	:= BTS->(indexOrd())
local cCampo	:= ""
local cConteudo := ""
local cCriaCli	:= getNewPar("MV_PLSFMCL","1")
local lBTS      := .f.
local aEstru	:= {}
local lStrTPLS	:= FindFunction("StrTPLS")
default cMotDB  := getNewPar("MV_SINBLO","999")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁOrderBy
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
iIf(nOrdBTS<>3,BTS->(dBSetOrder(3)),nil )//BTS_FILIAL + BTS_CPFUSR
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Inclusao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if nOpc==K_Incluir
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Atualiza campos M com o registro
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	PLATRCON(cAlias,aCampos,oXml,aRegRai,aRegOld,.f.,cRegistroPath,nOpc)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Para matricula
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if lRaiz .and. cAlias == 'BA3'
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Atualizando dados manuais da familia
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		M->BA3_MATRIC := PLPROXMAT(M->BA3_CODINT,M->BA3_CODEMP)
		M->BA3_ROTINA := "PLSPORFAI"
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	   //Ё Gravando BJK - Possibilidade de fazer generico
	   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		PLBJK(allTrim(M->BA3_FORPAG),allTrim(M->BA3_FORCTX))
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	   //Ё Gravando BBU - Possibilidade de fazer generico
	   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		PLBBU()
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	   //Ё Gravando Opcionais - Possibilidade de fazer generico
	   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		PLSIOpc()
	endIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
   //Ё Checa a possivel criacao da vida
   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
   if cAlias == 'BA1'

		if type( "M->BA1_FILIAL" ) != 'U'

			if !empty(allTrim(M->BA1_CPFUSR)) .And. len(allTrim(M->BA1_CPFUSR)) >= 11
				lBTS := BTS->(msSeek( xFilial("BTS")+M->BA1_CPFUSR ) )
			else
				BTS->(dBSetOrder(5))//BTS_FILIAL, BTS_NOMUSR, BTadminS_DATNAS, BTS_CPFUSR, BTS_MAE
				lBTS := BTS->(msSeek( xFilial("BTS")+M->BA1_NOMUSR + space( TamSX3("BA1_NOMUSR")[1] -Len(M->BA1_NOMUSR)) + dtos(M->BA1_DATNAS) ))
			endif

			if !lBTS
			    PLSA766Vid('M')
			endIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Atualizando dados manuais do usuario
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			if ( nPos := aScan( aCampos, {|x| x[1] == 'BA1_GRAUPA' } ) ) > 0
				M->BA1_GRAUPA := aCampos[nPos,2]
			endIf

			if ( nPos := aScan( aCampos, {|x| x[1] == 'BA1_TIPUSU' } ) ) > 0
			   M->BA1_TIPUSU := aCampos[nPos,2]
			endIf

			M->BA1_TIPREG	:= PLSMonTipRg(M->BA1_GRAUPA,M->BA1_TIPREG,M->BA1_TIPUSU,M->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC))[1]
			If !lStrTPLS
				M->BA1_DIGITO	:= Modulo11( M->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+M->BA1_TIPREG )
			else
				M->BA1_DIGITO	:= Modulo11(StrTPLS( M->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+M->BA1_TIPREG ))
			EndIf
			M->BA1_MATRIC	:= M->BA3_MATRIC
			M->BA1_CONEMP	:= M->BA3_CONEMP
			M->BA1_VERCON	:= M->BA3_VERCON
			M->BA1_SUBCON	:= M->BA3_SUBCON
			M->BA1_VERSUB	:= M->BA3_VERSUB
			M->BA1_MATVID	:= BTS->BTS_MATVID
			M->BA1_IMAGE	:= "ENABLE"
			//verificaГЦo da existencia do campo BA1_ORIINC para verificar origem da inclusЦo do beneficiАrio 
			If ("BA1")->(FieldPos("BA1_ORIINC")) > 0
				M->BA1_ORIINC := "PLSSINCRO"
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		   //Ё Cliente e loja do titular da familia
		   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			if !lJuridico .and. nOpc = K_Incluir .and. empty(M->BA3_CODCLI) .and. empty(M->BA3_CODFOR) .and. cCriaCli == "1" .and. M->BA3_COBNIV == '1' .and. M->BA1_TIPUSU == superGetMv("MV_PLCDTIT")
				PLSCL()
			endIf
		endIf
	endIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Atualizando dados manuais dos opcionais
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if type( "M->BF4_FILIAL" ) != 'U'
		M->BF4_MATRIC := M->BA1_MATRIC
		M->BF4_TIPREG := M->BA1_TIPREG

		//Verifica Opcional Usuario
		PLSOPCUS(M->BF4_CODPRO, M->BA3_FORCOP,M->BA3_CODINT,M->BA3_CODEMP,M->BF4_MATRIC,M->BF4_TIPREG,M->BA3_CODPLA,M->BA3_VERSAO)
	endIf

elseIf nOpc == K_Alterar .or. nOpc == 8 .or. nOpc == 9
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Posiciona no registro que sera alterado
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	&(cAlias)->(dbGoTo(nChave))
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Verifica o tipo de acao
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	do Case
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Atualiza campos M com o registro
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		case nOpc == K_Alterar
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Validacao e atribuicao
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			PLATRCON(cAlias,aCampos,oXml,aRegRai,aRegOld,.f.,cRegistroPath,nOpc)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Bloqueio ou Desbloqueio
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		case nOpc == 8
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Bloqueio/desbloqueio do registro
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			PLBLODES(cTipoDB,cMotDB,cDataDB,cObsDB,cAlias,cRelac)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Referencia
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		case nOpc == 9
	endCase
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁGravacao dos Registros
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if nOpc==8 .or. (nOpc==K_Incluir .or. nOpc==K_Alterar)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Log
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if lLogTud
		PLSLOGFIL("",cArqGer)
		PLSLOGFIL(replicate('-',__nRep),cArqGer)
		PLSLOGFIL(STR0044,cArqGer) //"ANTES DA GRAVACAO"
		PLSLOGFIL(STR0045+cSeq+"]",cArqGer) //"Sequencia  ["
		PLSLOGFIL("Alias      ["+cAlias+"]",cArqGer)
		PLSLOGFIL("AГЦo       ["+allTrim(str(iIf(nOpc==8, 4, nOpc)))+"]",cArqGer)
		PLSLOGFIL("",cArqGer)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Monta
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		aEstru := &(cAlias)->(dbStruct())
		for nY:=1 to Len(aEstru)
			cCampo		:= aEstru[nY,1]
			cConteudo	:= &(cCampo)

			PLSLOGFIL(STR0022+cCampo+STR0023+AllTrim( PLAJUSCON(,cConteudo,.T.) )+"]",cArqGer) //"Campo ["###"], conteudo ["
		next
  endIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Gravacao ou Alteracao
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if nOpc<>8 .and. nOpc<>9
		PLUPTENC(cAlias,nOpc,,,)
		If cAlias == 'BA1'  .AND. nOpc == 3          
            aadd(cChvBA1,M->(BA1_TIPUSU+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU+BA1_TIPREG+BA1_DIGITO))			
		ElseIf cAlias == 'BA1'  .AND. nOpc == 4
			PLATUCENTRAL(cAlias, nOpc, '')
		EndIf		
	endIf	
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁPONTO DE ENTRADA
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if existBlock("PLSSIN01")
   execBlock("PLSSIN01",.F.,.F.,{cAlias,nOpc})
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFinal do processamento de um registro
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
do case
	case nOpc == K_Incluir

		PLSLOGS(STR0098+cAlias+STR0097+allTrim(str(&(cAlias)->(recno())))+STR0099,.t.,.t.,.t.)//'Tabela [''] - InclusЦo - RECNO [''] gerado'
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁVerifica se a Tag Chave Existe e Cria
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if !oXml:xPathHasNode(cRegistroPath+'/ts:chave')
			oXml:xPathAddNode(cRegistroPath, 'chave', '')
		endIf

		oXml:xPathSetNode(cRegistroPath+'/ts:chave', 'chave', allTrim(str(&(cAlias)->(recno()))))

	case nOpc == K_Alterar
		PLSLOGS(STR0098+cAlias+STR0100+AllTrim(Str(nChave))+']',.t.,.t.,.t.)//'Tabela [''] - AlteraГЦo - RECNO ['
	case nOpc == 8
		PLSLOGS(STR0098+cAlias+'] - '+Iif(cTipoDB=='0',STR0101,STR0102)+STR0103+AllTrim( Str(nChave) )+']',.t.,.t.,.t.)//'Tabela [''Bloqueio''Desbloqueio'' no - RECNO ['
	case nOpc == 9
		PLSLOGS(STR0098+cAlias+STR0104+AllTrim( Str(nChave) )+']',.t.,.t.,.t.)//'Tabela [''] - ReferЙncia no - RECNO ['
endCase
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rorina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return

/*/{Protheus.doc} PLMONREG
Monta a matriz de registros

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLMONREG(oXml,cEndereco)
local nX   		:= 0
local cCampo		:= ''
local cCaminho	:= ''
local cConteudo 	:= ''
local aCampos		:= {}
local aMatCam		:= {}
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁCampos
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if oXml:xPathHasNode(cEndereco+"/ts:campos")

	aCampos := oXml:xPathGetChildArray(cEndereco+"/ts:campos")
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁMatriz de Campos
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	SX3->(dbSetOrder(2))
	for nX:=1 to len(aCampos)

		cCampo 	:= aCampos[nX,1]
		cCaminho	:= aCampos[nX,2]
		cConteudo	:= aCampos[nX,3]

		if SX3->(msSeek(cCampo))
			aadd(aMatCam,{cCampo,;				//01
						   cConteudo,;			//02
						   cCaminho,;				//03
						   SX3->X3_TITULO,;		//04
						   SX3->X3_OBRIGAT,;		//05
						   SX3->X3_RESERV,;		//06
						   SX3->X3_VALID,;		//07
						   SX3->X3_VLDUSER,;		//08
						   SX3->X3_TRIGGER,;		//09
						   SX3->X3_WHEN,;			//10
						   SX3->X3_RELACAO })	//11
		endIf
	next
endIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da Funcao
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return(aMatCam)

/*/{Protheus.doc} PLATUOB
Pega os erros gerados pelo mostra erro

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLATUOB(cRegistroPath,oXml,cErro,lLimA,lLimD)
local lInc	:= .F.
local lExist	:= .F.
local cErrOld	:= ''
default lLimA:= .F.
default lLimD:= .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁCria tag se nao existir
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if !empty(cErro)

	if !oXml:xPathHasNode(cRegistroPath+'/ts:chave')
		oXml:xPathAddNode(cRegistroPath, 'chave', '')
	endIf

	if !oXml:xPathHasNode(cRegistroPath+'/ts:obsProcessamento')
		oXml:xPathAddNode(cRegistroPath, 'obsProcessamento', '')
		lInc := .t.
	endIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁExibe o log
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	PLSLOGS(cErro,.T.,.T.,lLimA,lLimD)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁPega o erro ja gravado
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if !lInc
		cErrOld := oXml:xPathGetNodeValue(cRegistroPath+'/ts:obsProcessamento')
	endIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁVerifica se a mensagem de erro ja foi informada
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	lExist := at(cErro,cErrOld) > 0

	if lExist
		cErro := cErrOld
	elseif !Empty(cErrOld)
		cErro := cErrOld + ', ' + cErro
	endIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁAlimenta o conteudo da chave
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oXml:xPathSetNode(cRegistroPath+'/ts:obsProcessamento', 'obsProcessamento', noAcento(ansiToOem(allTrim(cErro))))
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rorina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return

/*/{Protheus.doc} PLVLDREL
Valida relacionamento com base no indice do alias pai

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLVLDREL(cChvIdx,cAlias)
local lOK			:= .t.
local cAliasOri 	:= ''
local cChvAux 	:= ''
local cCamNew		:= ''
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Validando relacionamento
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cChvIdx += '+'
while ( nPos := at('+',cChvIdx) ) > 0 .And. lOK
	cChvAux   := allTrim(subStr( cChvIdx,1,nPos-1 ) )
	cAliasOri := subStr(cChvAux,1,3)
	cChvIdx   := allTrim(subStr( cChvIdx,nPos+1,len(cChvIdx) ) )
	cCamNew   := strTran(cChvAux,cAliasOri,cAlias)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se existe monta nova chave												 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	if type( cCamNew ) != 'U'
		lOK := ( &(cChvAux) == &(cCamNew) )
	endIf
endDo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rorina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
return lOK


/*/{Protheus.doc} PLSME
Pega os erros gerados pelo mostra erro

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLSME(cAlias)
local lFirst		:= .t.
local cArqErro	:= "ME"+DToS(date()) + strTran(time(),":","") + '.ERR'
local cErro		:= ""
local cLinha		:= ""
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Gera o erro em arquivo proprio
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
mostraErro(PLSMUDSIS("\xmlsin"),cArqErro)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Le o Arquivo de Erros
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
FT_FUSE(PLSMUDSIS("\xmlsin\"+cArqErro))
FT_FGOTOP()
while !FT_FEOF()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Pega a linha
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	cLinha := FT_FREADLN()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Nao pega a linha que tem o help
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if at('HELP',cLinha) == 0 .And. !Empty(cLinha)
		cErro += ' '+cLinha
	endIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Cria o arquivo de Erro
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if empty(cLinha) .And. at(cAlias,cErro)	> 0
		if lFirst
			PLSLOGS(STR0105,.t.,.t.,.t.,.t.)//'Problema(s) no registro'
			lFirst := .F.
		endIf
		PLSLOGS(cErro,.t.,.t.)
	endIf

	if empty(cLinha)
		cErro := ''
	endIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁProxima linha
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	FT_FSKIP()
endDo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFecha o arquivo
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
FT_FUSE()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁDeleta arquivo de erros
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if FErase(PLSMUDSIS("\xmlsin\"+cArqErro)) == -1
	PLSLOGFIL(STR0043+cArqErro+"]",cArqGer) //"NЦo foi possМvel deletar o arquivo de Erros [\xmlsin\"
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rorina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return

/*/{Protheus.doc} PLSME
Verifica se o campo de bloqueio

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLVLBLO(cAlias)
local lRet := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Valida campos
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if &( cAlias+'->( FieldPos("'+cAlias+'_MOTBLO") )') > 0
	lRet := empty(&(cAlias+'->'+cAlias+'_MOTBLO'))

elseIf &( cAlias+'->( FieldPos("'+cAlias+'_CODBLO") )') > 0
	lRet := empty(&(cAlias+'->'+cAlias+'_CODBLO'))
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return lRet

/*/{Protheus.doc} PLERRCONT
Verifica se deu erro de estrutura

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
function PLERRCONT(cDet,cMsg)
local cErroB := subStr(cDet,(at(chr(10),subStr(cDet,2))+2))
local cErroD := subStr(cErroB,1,at(chr(10),cErroB)-1)
local cErro	:= subStr(cErroD,1,at("(",cErroD)-1)
local cLinha := strTran(subStr(cErroD,at( "line : ",cErroD)),"line","" )
default cMsg	:= ""

PLSLOGS(cErro + cMsg + cLinha)

lRet := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return lret

/*/{Protheus.doc} PLSLOGS
LOG do processamento

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLSLOGS(cText,lTp,lImp,lLimA,lLimD)
default lTp	 := .f.
default lImp  := .f.
default lLimA := .f.
default lLimD := .f.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Se Display esta desligado informa
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if !lDisplay
	if aScan( oList:AITEMS,{ |x| allTrim(upper(x))== STR0106 } ) == 0 //"INFORMAгцO DE TELA DESLIGADA"
		oList:Insert( " " , oList:Len() )
		oList:Insert( STR0106 , oList:Len() )//"INFORMAгцO DE TELA DESLIGADA"
	endIf
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Erros
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if valType(oList) == 'O'
	if lDisplay

		if !lTp
			lXsdXml := lTp
		   iIf( lLimA,oList:Insert( replicate('-',__nRep) , oList:Len() ),NIL)

			oList:Insert( cText, oList:Len() )

		   iIf( lLimD,oList:Insert( replicate('-',__nRep) , oList:Len() ),NIL)
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Somente imprime nao ajusta o controle da importacao
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if lImp
			iIf( lLimA,oList:Insert( replicate('-',__nRep) , oList:Len() ),NIL)

			oList:Insert( cText, oList:Len() )

			iIf( lLimD,oList:Insert( replicate('-',__nRep) , oList:Len() ),NIL)
		endIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Exibir em tela esta desligado
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	elseIf !lTp .or. lImp
		PlsLogFil(cText,__cArqLog)
	endIf
else
	PlsLogFil(cText,__cArqLog)
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rorina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return lTp

/*/{Protheus.doc} PLSELARQ
Retorna a pasta de gravacao e o arquivo

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
function PLSELARQ(__cDir,nTp)
__cDir := cGetFile(iIf(nTp==2,"*.CSV|*.csv",iIf(nTp==1,"*.XML|*.xml","*.XSD|*.xsd")),STR0046,1 ,"c:\",.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE)   //"Selecione o Arquivo"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da funcao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return

/*/{Protheus.doc} PLAJUSCON
Ajusta o conteudo

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
function PLAJUSCON(cCampo,Conteudo,lCar)
default cCampo 	:= ""
default lCar 	:= .f.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁSe foi informado o campo se nao somente o conteudo
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if !Empty(cCampo)
	do case
		case type(cCampo)=='N'
			Conteudo := iIf(valType(Conteudo)=='N', Conteudo, val(Conteudo))
		case type(cCampo)=='D'
			Conteudo := iIf(valType(Conteudo)=='D', Conteudo, SToD(Conteudo))
	endCase
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁTransforma para caracter
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if lCar
	do case
		case valType(Conteudo)=='N'
			Conteudo := allTrim(str(Conteudo))
		case valType(Conteudo)=='D'
			Conteudo := dTos(Conteudo)
	endCase
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da funcao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return Conteudo

/*/{Protheus.doc} PLIMPLOG
Log de procesasmento

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
function PLIMPLOG()
local nI		:= 0
local cArqImp	:= 'imp'+DtoS(Date())+StrTran(Time(),":","")+'.log'
local aImp	:= {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁMontando matriz para impressao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if Len(oList:aiTems)>0 .And. !empty(oList:aiTems[1])
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ёfor do obj
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	for nI:=1 To Len(oList:aiTems)
		PlsLogFil(oList:AITEMS[nI],cArqImp)
		aadd( aImp,{ oList:AITEMS[nI] } )
	next
	aadd( aImp,{STR0107+cArqImp+STR0108 } )// 'Arquivo contendo as informaГУes deste relatСrio [''], pasta "logpls" no servidor.'
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁImprimi
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	PlsCriGen(aImp, { {STR0109,"@C",1000} }, STR0110,,,,,,,,,,,,,,,,,,,,TFont():New("Courier New",7,14,,.f.,,,,.f.,.f.) )//'Resultado''ImpressЦo do Processamento'
else
	msgAlert(STR0111)//'NЦo existe conteЗdo, impossМvel imprimir'
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da funcao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return



/*/{Protheus.doc} PLBLODES
Bloqueio e Desbloqueio

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLBLODES(cTipoDB,cMotDB,cDataDB,cObsDB,cAlias,cAliasRel)
local nPos 	   := 0
local nI,nY		:= 0
local I__f      := 0
local nRecAlias	:= &(cAlias)->(recno())
local lFindIdx	:= .f.
local cIdx	   	:= "1"
local cAliAux   	:= ""
local cComIdx   	:= ""
local cChvIdx		:= ""
local cChave		:= ""
local cAuxIdx		:= ""
local cMatric		:= ""
local cTipReg		:= ""
local aMatAlias	:= strToKarr(cAliasRel,',')
local aMatIdx		:= {}

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁTransacao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
begin transaction
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁPosiciona no inicio do bloquei
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
nPos := aScan(aMatAlias,{|x| x == cAlias})
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁPassa por todos os alias relacionados
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
for nI:=nPos to len(aMatAlias)

	cAliAux := aMatAlias[nI]
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁPara nЦo bloqueio/desbloqueio quando o nivel for na familia ou no usuario
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if cAliAux=='BF4' .and. cAlias <> 'BF4'
		loop
	endIf

	cChvIdx := cAliAux+'_FILIAL+'+cAliAux+'_CODINT+'+cAliAux+'_CODEMP+'+cAliAux+'_MATRIC' + iIf((cAliAux)!='BA3',"+"+cAliAux+"_TIPREG","")
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁChave somente do primeiro Alias
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if empty(cChave) 	   
		cChave := &(cAliAux+'->('+cChvIdx+')')
	else
		PLSLOGFIL(STR0040,cArqGer) //"Problema ao montar chave do bloqueio/desbloqueio."
	endIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁVerifica o indice correspondente
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	
	SIX->(dbSetOrder(01))	
	
	if SIX->(msSeek(cAliAux))
		lFindIdx	:= .f.
		cChvIdx	:= strTran(strTran(cChvIdx,' +','+'),'+ ','+')

		while !SIX->(eof()) .and. cAliAux == SIX->INDICE

			cAuxIdx := strTran(strTran(SIX->CHAVE,' +','+'),'+ ','+')

			if at(cChvIdx,cAuxIdx) > 0
				cIdx 		:= SIX->ORDEM
				lFindIdx 	:= .t.
				exit
			endIf

		SIX->( dbSkip() )
		endDo

		if !lFindIdx
			PLSLOGFIL(STR0041+cAliAux+STR0112+cChvIdx+"]",cArqGer) //"NЦo encontrado indice correspondente no alias [""], para chave ["
      endIf
	endIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁPosiciona no registro
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If cAliAux == 'BA1'
	   cIdx := '02'
	EndIf
	&(cAliAux+'->(dbSetOrder('+cIdx+'))')
	if &(cAliAux+'->(msSeek("'+cChave+'"))')
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ёmatricula
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if empty(cMatric)
			cMatric := cAliAux+'_CODINT+' + cAliAux+'_CODEMP+' + cAliAux+'_MATRIC'+ iIf((cAliAux)!='BA3',"+"+cAliAux+"_TIPREG","")
			if type(cMatric) != 'U'
				cMatric := &(cAliAux+'->('+cMatric+')')
			else
				cMatric := ''
			endIf
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁBloqueio de todos os registros relacionados
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		while !&(cAliAux+'->(eof())') .and. cChave $ &(cAliAux+'->('+cAuxIdx+')') .and. cAliAux == cAlias
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁVerificando se tem tipreg na tabela
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			if &(cAliAux+'->(fieldPos("'+cAliAux+'_TIPREG"))')>0
				cTipReg := &(cAliAux+'->'+cAliAux+'_TIPREG')
			endIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁBloqueio/Desbloqueio
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			&(cAliAux+"->(RecLock('"+cAliAux+"',.f.))")
				do case
					case cAliAux == 'BA3'
					  	lDBTodos := .t.

						&(cAliAux+"->"+cAliAux+"_MOTBLO") := iIf( cTipoDB == '0',cMotDB,'' )
						&(cAliAux+"->"+cAliAux+"_DATBLO") := iIf( cTipoDB == '0',SToD(cDataDB),CtoD('') )
				   		&(cAliAux+"->"+cAliAux+"_CONSID") := 'F'

					case cAliAux == 'BA1'

					   	&(cAliAux+"->"+cAliAux+"_MOTBLO") := iIf( cTipoDB == '0',cMotDB,'' )
						&(cAliAux+"->"+cAliAux+"_DATBLO") := iIf( cTipoDB == '0',SToD(cDataDB),CtoD('') )
						&(cAliAux+"->"+cAliAux+"_CONSID") := iIf(lDBTodos,'F','U')
						&(cAliAux+"->"+cAliAux+"_IMAGE")  := 'DISABLE'

						if lDBTodos
							&(cAliAux+"->"+cAliAux+"_BLOFAT") := Posicione("BG1",1,xFilial("BG1")+cMotDB,"BG1_BLOFAT")
						else
							&(cAliAux+"->"+cAliAux+"_BLOFAT") := Posicione("BG3",1,xFilial("BG3")+cMotDB,"BG3_BLOFAT")
						endIf

					case cAliAux == 'BF4'
						&(cAliAux+"->"+cAliAux+"_MOTBLO") := iIf( cTipoDB == '0',cMotDB,'' )
				   		&(cAliAux+"->"+cAliAux+"_DATBLO") := iIf( cTipoDB == '0',SToD(cDataDB),CtoD('') )
				endcase
			&(cAliAux+"->(msUnLock())")
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁBloqueio/Desbloqueio e o Historico
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			PLHISBLO(cTipoDB,cMotDB,cDataDB,cObsDB,cAliAux,cMatric,cTipReg,iIf(lDBTodos,'F','U'))
			If cAlias == "BA1"
				PLATUCENTRAL(cAliAux, 8,cTipoDB,nRecAlias,cMotDB,cDataDB)
			EndIf			
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁProximo
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		&( cAliAux+'->( dbSkip() )')
		endDo
	else
		PLSLOGFIL(STR0113+cChvIdx+STR0023+cChave+STR0042+cAliAux+"]",cArqGer) //"Chave [""], conteudo ["###"] nЦo encontrado na alias ["
	endIf	
next
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da Transacao...
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
end transaction

&(cAlias)->(dbGoTo(nRecAlias))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da Rorina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return

/*/{Protheus.doc} PLHISBLO
Historico do bloqueio e desbloqueio

@author Alexander Santos
@since 05/08/2014
@version P11
/*/Ё
static function PLHISBLO(cTipoDB,cMotDB,cDataDB,cObsDB,cAliAux,cMatric,cTipReg,cNivBlq)
local cAlias 	:= iIf(cAliAux=='BA3','BC3',iIf(cAliAux=='BA1','BCA','') )
default cMatric	:= ''
default cTipReg 	:= ''
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁGravacao do Historio do Bloqueio ou Desbloqueio
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if !empty(cAlias)
	&(cAlias)->(recLock(cAlias,.t.))

		&(cAlias+'->'+cAlias+'_FILIAL') := xFilial(cAlias)

		&(cAlias+'->'+cAlias+'_MATRIC') := iIf(!empty(cMatric), cMatric, &( M->( cAliAux+'_CODINT+' + cAliAux+'_CODEMP+' + cAliAux+'_MATRIC ') ) )

		if &(cAlias+'->( fieldPos("'+cAlias+'_TIPREG") )')>0
			&(cAlias+'->'+cAlias+'_TIPREG')	:= cTipReg
		endIf

		&( cAlias+'->'+cAlias+'_TIPO'   ) := cTipoDB
		&( cAlias+'->'+cAlias+'_DATA'   ) := StoD(cDataDB)
		&( cAlias+'->'+cAlias+'_MOTBLO' ) := cMotDB
		&( cAlias+'->'+cAlias+'_OBS'    ) := cObsDB
		&( cAlias+'->'+cAlias+'_USUOPE' ) := cUserName
		&( cAlias+'->'+cAlias+'_NIVBLQ' ) := cNivBlq
		&( cAlias+'->'+cAlias+'_DATPED' ) := dDataBase
		&( cAlias+'->'+cAlias+'_DATLAN' ) := dDataBase
		&( cAlias+'->'+cAlias+'_HORLAN' ) := Time()

		if &( cAlias+'->( fieldPos("'+cAlias+'_BLOFAT") )' ) > 0
				if cNivBlq == 'F'
					&( cAlias+'->'+cAlias+'_BLOFAT' )	:= Posicione("BG1",1,xFilial("BG1")+cMotDB,"BG1_BLOFAT")
				else
					&( cAlias+'->'+cAlias+'_BLOFAT' )	:= Posicione("BG3",1,xFilial("BG3")+cMotDB,"BG3_BLOFAT")
				endIf

		endIf

		if 	&(cAlias)->( fieldPos('"'+cAlias+'_OBTSIP"') ) > 0
				&( cAlias+'->'+cAlias+'_OBTSIP' ) := ""
		endIf

	&(cAlias)->( MsUnlock() )
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da Rorina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return

/*/{Protheus.doc} PLCONTCAM
Valida BA3 E BA1 verificar se e possivel rdmake

@author Alexander Santos
@since 05/08/2014
@version P11
/*/Ё
static function PLCONTCAM(cCampo,cConteudo,cAlias)
DEFAULT cAlias := ""
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁAtribui conteud aos campos
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if Type(cAlias+cCampo) != 'U'
	M->&(cAlias+cCampo) := PLAJUSCON(cAlias+cCampo,cConteudo)
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da Rotina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return

/*/{Protheus.doc} PLBJK
Inclusao do BJK Familia X formas de Cobranca

@author Alexander Santos
@since 05/08/2014
@version P11
/*/Ё
static function PLBJK(cForPag,cForCtx)
local nOrdBT9   	:= 0
local nOrdBJ3   	:= 0
local cCampoAux 	:= ""
local cCampo		:= ""
local cSql		:= ""
local nCnt      := 1

if lJuridico
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁForma CobranГa AdesЦo Contrato
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	BTK->(dbSetOrder(1))//BTK_FILIAL+BTK_CODIGO+BTK_NUMCON+BTK_VERCON+BTK_SUBCON+BTK_VERSUB+BTK_CODPRO+BTK_VERSAO+BTK_CODFOR
	if BTK->(MsSeek(xFilial("BTK")+M->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+cForCtx)))

			cForCtx := BTK->BTK_CODFOR

			while !BTK->( Eof() ) .and. xFilial('BTK')+M->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+cForCtx) == ;
											 BTK->(BTK_FILIAL+BTK_CODIGO+BTK_NUMCON+BTK_VERCON+BTK_SUBCON+BTK_VERSUB+BTK_CODPRO+BTK_VERSAO+BTK_CODFOR)
				//formas de CobranГa de AdesУes
				BJL->(RecLock("BJL", .T.))
					BJL->BJL_FILIAL := xFilial("BJL")
					BJL->BJL_CODOPE := M->BA3_CODINT
					BJL->BJL_CODEMP := M->BA3_CODEMP
					BJL->BJL_MATRIC := M->BA3_MATRIC
					BJL->BJL_CODFOR := BTK->BTK_CODFOR
					BJL->BJL_AUTOMA := '1'
				BJL->( MsUnlock() )

				cSql := "SELECT * FROM "+RetSqlName("BR6")+" WHERE BR6_FILIAL = '"+xFilial("BR6")+"' "
				cSql += "AND BR6_CODIGO = '"+BTK->BTK_CODIGO+"' "
				cSql += "AND BR6_NUMCON = '"+BTK->BTK_NUMCON+"' "
				cSql += "AND BR6_VERCON = '"+BTK->BTK_VERCON+"' "
				cSql += "AND BR6_SUBCON = '"+BTK->BTK_SUBCON+"' "
				cSql += "AND BR6_VERSUB = '"+BTK->BTK_VERSUB+"' "
				cSql += "AND BR6_CODFOR = '"+BTK->BTK_CODFOR+"' "
				cSql += "AND D_E_L_E_T_  = ' '"

				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cSql)),"TRB1",.F.,.T.)	

				while !TRB1->( Eof() )
					//FamМlias e Valores de AdesЦo
					BRX->( RecLock("BRX", .T.) )
					for nCnt := 1 To BRX->( fCount() )
						cCampo := BRX->( Field(nCnt) )

						if cCampo == "BRX_CODOPE"
							BRX->( fieldPut(nCnt, M->BA3_CODINT ) )

						elseif cCampo == "BRX_CODEMP"
							BRX->( fieldPut(nCnt, M->BA3_CODEMP ) )

						elseif cCampo == "BRX_MATRIC"
							BRX->( fieldPut(nCnt, M->BA3_MATRIC ) )

						elseif cCampo == "BRX_AUTOMA"
							BRX->( fieldPut(nCnt, "1") )

						else
							cCampoAux := "TRB1->"+StrTran(cCampo, "BRX","BR6")
							if BR6->( fieldPos(SubStr(cCampoAux,7)) ) > 0 .and.;
								BRX->( fieldPos(cCampo) ) > 0

								BRX->( fieldPut(nCnt, &cCampoAux) )
							endIf
						endIf
					next
					BRX->( MsUnlock() )

					cSql := "SELECT * FROM "+RetSqlName("BFV")+" WHERE "
					cSql += "BFV_FILIAL = '"+xFilial("BFV") +"' AND "
					cSql += "BFV_CODIGO = '"+TRB1->BR6_CODIGO+"' AND "
					cSql += "BFV_NUMCON = '"+TRB1->BR6_NUMCON+"' AND "
					cSql += "BFV_VERCON = '"+TRB1->BR6_VERCON+"' AND "
					cSql += "BFV_SUBCON = '"+TRB1->BR6_SUBCON+"' AND "
					cSql += "BFV_VERSUB = '"+TRB1->BR6_VERSUB+"' AND "
					cSql += "BFV_CODPRO = '"+TRB1->BR6_CODPRO+"' AND "
					cSql += "BFV_VERPRO = '"+TRB1->BR6_VERPRO+"' AND "
					cSql += "BFV_CODFOR = '"+TRB1->BR6_CODFOR+"' AND "
					cSql += "BFV_CODFAI = '"+TRB1->BR6_CODFAI+"' AND "
					cSql += "D_E_L_E_T_ = ' ' "
					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cSql)),"TRB2",.F.,.T.)

					while !TRB2->( Eof() )
						//Taxa AdesЦo Desconto FamМlia
						BFZ->( RecLock("BFZ", .T.) )
						for nCnt := 1 To BFZ->( fCount() )
							cCampo 		:= BFZ->( Field(nCnt) )

							if cCampo == "BFZ_CODOPE"
								BFZ->( fieldPut(nCnt, M->BA3_CODINT ) )

							elseif cCampo == "BFZ_CODEMP"
								BFZ->( fieldPut(nCnt, M->BA3_CODEMP ) )

							elseif cCampo == "BFZ_MATRIC"
								BFZ->( fieldPut(nCnt, M->BA3_MATRIC ) )

							elseif cCampo == "BFZ_AUTOMA"
								BFZ->( fieldPut(nCnt, "1") )

							else
								cCampoAux := "TRB2->"+StrTran(cCampo, "BFZ","BFV")
								if BFV->( fieldPos(Substr(cCampoAux,7)) ) > 0 .and. BFZ->( fieldPos(cCampo) ) > 0
									BFZ->( fieldPut(nCnt, &cCampoAux) )
								endIf
							endIf
						next
						BFZ->( MsUnlock() )
						TRB2->( dbSkip() )
					endDo
					TRB2->( dbClosearea() )
					TRB1->( dbSkip() )
				endDo
				TRB1->( dbCloseArea() )
				BTK->( dbSkip() )
			endDo
	endIf

	//OrderBy
	nOrdBT9 := BT9->( indexOrd() )
	
	//Empresas Modalidades CobranГas
	iIf(nOrdBT9<>1,BT9->( dbSetOrder(1) ),nil) //BT9_FILIAL + BT9_CODIGO + BT9_NUMCON + BT9_VERCON + BT9_SUBCON + BT9_VERSUB + BT9_CODPRO + BT9_VERSAO + BT9_CODFOR
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁPrepara para inclusao da forma de cobranca do subcontrato na familia
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if BT9->( MsSeek( xFilial('BT9')+M->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+cForPag)))
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁLog
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		PLSLOGS(STR0114+xFilial('BT9')+M->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+BA3_forPAG)+']',.t.,.t.,.t.)//'GravaГao da tabela BJK com base na chave do BT9 ['
		
		cforPag := BT9->BT9_CODFOR
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ёwhile BT9
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		while !BT9->( Eof() ) .And. BT9->(BT9_FILIAL+BT9_CODIGO+BT9_NUMCON+BT9_VERCON+BT9_SUBCON+BT9_VERSUB+BT9_CODPRO+BT9_VERSAO+BT9_CODFOR) ==;
									     xFilial('BT9')+M->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+cforPag)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁIncluindo BJK FamМlia formas de CobranГa
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			BJK->( RecLock( "BJK",.T. ) )
				BJK->BJK_FILIAL := BT9->BT9_FILIAL
				BJK->BJK_CODOPE := SubString(BT9->BT9_CODIGO,1,4)
				BJK->BJK_CODEMP := SubString(BT9->BT9_CODIGO,5,4)
				BJK->BJK_CODFOR := BT9->BT9_CODFOR
				BJK->BJK_AUTOMA := BT9->BT9_AUTOMA
				BJK->BJK_MATRIC := M->BA3_MATRIC
			BJK->( MsUnlock() )
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁProximo BT9
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			BT9->( dbSkip() )
		endDo
	else
		PLSLOGS(STR0113+xFilial('BT9')+M->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)+STR0116,.t.,.t.,.t.)//Chave [''], nЦo encontrada no BT9'
	endIf
else
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁProdutos Formas Taxas AdesЦo
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	BJ9->(dbSetOrder(1))//BJ9_FILIAL+BJ9_CODIGO+BJ9_VERSAO+BJ9_CODFOR
	if BJ9->(MsSeek(xFilial("BJ9")+M->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+cForCtx)))

		cForCtx := BJ9->BJ9_CODFOR

		while !BJ9->( Eof() ) .and. xFilial('BJ9')+M->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+cForCtx) == BJ9->(BJ9_FILIAL+BJ9_CODIGO+BJ9_VERSAO+BJ9_CODFOR)
			//formas de CobranГa de Adesao
			BJL->(RecLock("BJL", .T.))
				BJL->BJL_FILIAL := xFilial("BJL")
				BJL->BJL_CODOPE := M->BA3_CODINT
				BJL->BJL_CODEMP := M->BA3_CODEMP
				BJL->BJL_MATRIC := M->BA3_MATRIC
				BJL->BJL_CODFOR := BJ9->BJ9_CODFOR
				BJL->BJL_AUTOMA := '1'
			BJL->( MsUnlock() )

			cSql := "SELECT * FROM "+RetSqlName("BRY")+" WHERE BRY_FILIAL = '"+xFilial("BRY")+"' "
			cSql += "AND BRY_CODIGO = '"+BJ9->BJ9_CODIGO+"' "
			cSql += "AND BRY_VERSAO = '"+BJ9->BJ9_VERSAO+"' "
			cSql += "AND BRY_CODFOR = '"+BJ9->BJ9_CODFOR+"' "
			cSql += "AND D_E_L_E_T_  = ' '"
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cSql)),"TRB1",.F.,.T.)

			while !TRB1->( Eof() )
				//FamМlias e Valores de AdesЦo
				BRX->( RecLock("BRX", .T.) )
				for nCnt := 1 To BRX->( fCount() )
					cCampo := BRX->( Field(nCnt) )

					if cCampo == "BRX_CODOPE"
						BRX->( fieldPut(nCnt, M->BA3_CODINT ) )

					elseif cCampo == "BRX_CODEMP"
						BRX->( fieldPut(nCnt, M->BA3_CODEMP ) )

					elseif cCampo == "BRX_MATRIC"
						BRX->( fieldPut(nCnt, M->BA3_MATRIC ) )

					elseif cCampo == "BRX_AUTOMA"
						BRX->( fieldPut(nCnt, "1") )

					else
						cCampoAux := "TRB1->"+StrTran(cCampo, "BRX","BRY")
						if BRY->( fieldPos(SubStr(cCampoAux,7)) ) > 0 .and. BRX->( fieldPos(cCampo) ) > 0
							BRX->( fieldPut(nCnt, &cCampoAux) )
						endIf
					endIf
				next
				BRX->( MsUnlock() )

				cSql := "SELECT * FROM "+RetSqlName("BFX")+" WHERE "
				cSql += "BFX_FILIAL = '"+xFilial("BFX") +"' AND "
				cSql += "BFX_CODIGO = '"+TRB1->BRY_CODIGO+"' AND "
				cSql += "BFX_VERSAO = '"+TRB1->BRY_VERSAO+"' AND "
				cSql += "BFX_CODFOR = '"+TRB1->BRY_CODFOR+"' AND "
				cSql += "BFX_CODFAI = '"+TRB1->BRY_CODFAI+"' AND "
				cSql += "BFX_TIPUSR = '"+TRB1->BRY_TIPUSR+"' AND "
				cSql += "D_E_L_E_T_ = ' ' "
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cSql)),"TRB2",.F.,.T.)

				while !TRB2->( Eof() )
					//Taxa AdesЦo Desconto FamМlia
					BFZ->( RecLock("BFZ", .T.) )
					for nCnt := 1 To BFZ->( fCount() )
						cCampo := BFZ->( Field(nCnt) )

						if cCampo == "BFZ_CODOPE"
							BFZ->( fieldPut(nCnt, M->BA3_CODINT ) )

						elseif cCampo == "BFZ_CODEMP"
							BFZ->( fieldPut(nCnt, M->BA3_CODEMP ) )

						elseif cCampo == "BFZ_MATRIC"
							BFZ->( fieldPut(nCnt, M->BA3_MATRIC ) )

						elseif cCampo == "BFZ_AUTOMA"
							BFZ->( fieldPut(nCnt, "1") )

						else
							cCampoAux := "TRB2->"+StrTran(cCampo, "BFZ","BFX")
							if BFX->( fieldPos(Substr(cCampoAux,7)) ) > 0 .and. BFZ->( fieldPos(cCampo) ) > 0
								BFZ->( fieldPut(nCnt, &cCampoAux) )
							endIf
						endIf
					next
					BFZ->( MsUnlock() )
					TRB2->( dbSkip() )
				endDo
				TRB2->( dbClosearea() )
				TRB1->( dbSkip() )
			endDo
			TRB1->( dbCloseArea() )
			BJ9->( dbSkip() )
		endDo
	endIf

	//OrderBy
	nOrdBJ3 := BJ3->( indexOrd() )
	iIf(nOrdBJ3<>1,BJ3->( dbSetOrder(1) ),nil) //BJ3_FILIAL+BJ3_CODIGO+BJ3_VERSAO+BJ3_CODFOR
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁPrepara para inclusao da forma de cobranca
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if BJ3->( MsSeek( xFilial('BJ3')+M->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+cForPag) ) )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁLog
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		PLSLOGS(STR0115+xFilial('BJ3')+M->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_forPAG)+']',.t.,.t.,.t.)//'GravaГao da tabela BJK com base na chave do BJ3 ['

		cforPag := BJ3->BJ3_CODFOR
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ёwhile BT9
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		while !BJ3->( Eof() ) .And. BJ3->(BJ3_FILIAL+BJ3_CODIGO+BJ3_VERSAO+BJ3_CODFOR) == xFilial('BJ3')+M->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+cforPag)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁIncluindo BJK - FamМlia formas de CobranГa
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			BJK->( RecLock( "BJK",.T. ) )
				BJK->BJK_FILIAL := BJ3->BJ3_FILIAL
				BJK->BJK_CODOPE := M->BA3_CODINT
				BJK->BJK_CODEMP := M->BA3_CODEMP
				BJK->BJK_CODFOR := BJ3->BJ3_CODFOR
				BJK->BJK_AUTOMA := '1'
				BJK->BJK_MATRIC := M->BA3_MATRIC
			BJK->( MsUnlock() )
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁProximo BT9
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			BJ3->(dbSkip())
		endDo
	else
		PLSLOGS(STR0113+xFilial('BJ3')+M->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+cforPag)+STR0117,.t.,.t.,.t.)//'Chave [''], nЦo encontrada no BJ3'
	endIf
endIf

M->BA3_FORCTX := cForCtx 
M->BA3_FORPAG := cforPag
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da Rorina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return

/*/{Protheus.doc} PLBBU
Inclusao do BBU - Faixa Etaria X forma X Familia

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLBBU()
local nOrdBTN   	:= 0
local nOrdBB3   	:= 0
local nCnt      := 1
local cCampoBFY 	:= ""
local cSql 		:= ""
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Prepara para inclusao de toda a faixa etaria do subcontrato para a familia
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if lJuridico
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁOrderBy
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	nOrdBTN := BTN->(indexOrd())
	iIf(nOrdBTN<>3,BTN->(dbSetOrder(3)),nil) //BTN_FILIAL + BTN_CODIGO + BTN_NUMCON + BTN_VERCON + BTN_SUBCON + BTN_VERSUB + BTN_CODPRO + BTN_VERPRO + BTN_CODFOR + BTN_CODFAI

	if BTN->(msSeek( xFilial('BTN')+M->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+BA3_forPAG) ) )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁLog
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		PLSLOGS(STR0118+xFilial('BTN')+M->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+BA3_forPAG)+']',.t.,.t.,.t.)//'GravaГao da tabela BBU com base na chave do BTN ['
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ёwhile BTN
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		while !BTN->(eof()) .and. BTN->(BTN_FILIAL+BTN_CODIGO+BTN_NUMCON+BTN_VERCON+BTN_SUBCON+BTN_VERSUB+BTN_CODPRO+BTN_VERPRO+BTN_CODFOR) ==;
									  xFilial('BTN')+M->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+BA3_forPAG)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁIncluindo BBU
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			BBU->(recLock( "BBU",.t.))
				BBU->BBU_FILIAL 	:= BTN->BTN_FILIAL
				BBU->BBU_CODOPE 	:= M->BA3_CODINT
				BBU->BBU_CODEMP 	:= M->BA3_CODEMP
				BBU->BBU_MATRIC 	:= M->BA3_MATRIC
				BBU->BBU_CODFOR 	:= BTN->BTN_CODFOR
				BBU->BBU_CODFAI 	:= BTN->BTN_CODFAI
				BBU->BBU_TABVLD 	:= BTN->BTN_TABVLD
				BBU->BBU_TIPUSR 	:= BTN->BTN_TIPUSR
				BBU->BBU_GRAUPA 	:= BTN->BTN_GRAUPA
				BBU->BBU_SEXO		:= BTN->BTN_SEXO
				BBU->BBU_IDAINI 	:= BTN->BTN_IDAINI
				BBU->BBU_IDAFIN 	:= BTN->BTN_IDAFIN
				BBU->BBU_ValFAI 	:= BTN->BTN_ValFAI
				BBU->BBU_FAifAM 	:= BTN->BTN_FAifAM
				BBU->BBU_QTDMIN 	:= BTN->BTN_QTDMIN
				BBU->BBU_QTDMAX 	:= BTN->BTN_QTDMAX
				BBU->BBU_REJAPL 	:= BTN->BTN_REJAPL
				BBU->BBU_AUTOMA 	:= BTN->BTN_AUTOMA
				BBU->BBU_PERREJ 	:= BTN->BTN_PERREJ
				BBU->BBU_ANOMES 	:= BTN->BTN_ANOMES
				BBU->BBU_VLRANT 	:= BTN->BTN_VLRANT
			BBU->(msUnlock())

			cSql := "SELECT * FROM "+RetSqlName("BFT")+" WHERE "
			cSql += "BFT_FILIAL = '"+xFilial("BFT") +"' AND "
			cSql += "BFT_CODIGO = '"+BTN->BTN_CODIGO+"' AND "
			cSql += "BFT_NUMCON = '"+BTN->BTN_NUMCON+"' AND "
			cSql += "BFT_VERCON = '"+BTN->BTN_VERCON+"' AND "
			cSql += "BFT_SUBCON = '"+BTN->BTN_SUBCON+"' AND "
			cSql += "BFT_VERSUB = '"+BTN->BTN_VERSUB+"' AND "
			cSql += "BFT_CODPRO = '"+BTN->BTN_CODPRO+"' AND "
			cSql += "BFT_VERPRO = '"+BTN->BTN_VERPRO+"' AND "
			cSql += "BFT_CODFOR = '"+BTN->BTN_CODFOR+"' AND "
			cSql += "BFT_CODFAI = '"+BTN->BTN_CODFAI+"' AND "
			cSql += "D_E_L_E_T_ = ' ' "
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cSql)),"TRB2",.F.,.T.)

			while !TRB2->(eof())

				BFY->( RecLock("BFY", .T.) )
				for nCnt := 1 to BFY->(fCount())
					cCampo := BFY->(field(nCnt))

					if cCampo == "BFY_CODOPE"
						BFY->( fieldPut(nCnt, M->BA3_CODINT ) )

					elseif cCampo == "BFY_CODEMP"
						BFY->( fieldPut(nCnt, M->BA3_CODEMP ) )

					elseif cCampo == "BFY_MATRIC"
						BFY->( fieldPut(nCnt, M->BA3_MATRIC ) )

					elseif cCampo == "BFY_AUTOMA"
						BFY->( fieldPut(nCnt, "1") )

					else
						cCampoBFY := "TRB2->"+StrTran(cCampo, "BFY","BFT")

						if BFT->( fieldPos(substr(cCampoBFY,7)) ) > 0 .and. BFY->(fieldPos(cCampo)) > 0
							BFY->( fieldPut(nCnt, &cCampoBFY) )
						endIf
					endIf
				next
				BFY->( MsUnlock() )
				TRB2->(dbSkip())
			endDo
			TRB2->(dbClosearea())
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁProximo BTN
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			BTN->(dbSkip())
		endDo
	else
		PLSLOGS(STR0113+xFilial('BTN')+M->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)+STR0119,.t.,.t.,.t.)//'Chave [''], nЦo encontrada no BTN'
	endIf
else
	nOrdBB3 := BB3->(indexOrd())
	iIf(nOrdBB3<>3,BB3->(dbSetOrder(1)),nil) //BB3_FILIAL+BB3_CODIGO+BB3_VERSAO+BB3_CODFOR+BB3_CODFAI

	if BB3->(msSeek( xFilial('BB3')+M->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_forPAG)))
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁLog
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		PLSLOGS(STR0120+xFilial('BB3')+M->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_forPAG)+']',.t.,.t.,.t.)//'GravaГao da tabela BBU com base na chave do BB3 ['
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ёwhile BTN
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		while !BB3->(eof()) .and. BB3->(BB3_FILIAL+BB3_CODIGO+BB3_VERSAO+BB3_CODFOR) == xFilial('BB3')+M->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_forPAG)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁIncluindo BBU
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			BBU->( RecLock( "BBU",.T. ) )
				BBU->BBU_FILIAL 	:= BB3->BB3_FILIAL
				BBU->BBU_CODOPE 	:= M->BA3_CODINT
				BBU->BBU_CODEMP 	:= M->BA3_CODEMP
				BBU->BBU_MATRIC 	:= M->BA3_MATRIC
				BBU->BBU_CODFOR 	:= BB3->BB3_CODFOR
				BBU->BBU_CODFAI	:= BB3->BB3_CODFAI
				BBU->BBU_TABVLD 	:= BB3->BB3_TABVLD
				BBU->BBU_TIPUSR 	:= BB3->BB3_TIPUSR
				BBU->BBU_GRAUPA 	:= BB3->BB3_GRAUPA
				BBU->BBU_SEXO		:= BB3->BB3_SEXO
				BBU->BBU_IDAINI 	:= BB3->BB3_IDAINI
				BBU->BBU_IDAFIN 	:= BB3->BB3_IDAFIN
				BBU->BBU_VALFAI 	:= BB3->BB3_VALFAI
				BBU->BBU_FAifAM 	:= BB3->BB3_FAifAM
				BBU->BBU_QTDMIN 	:= BB3->BB3_QTDMIN
				BBU->BBU_QTDMAX 	:= BB3->BB3_QTDMAX
				BBU->BBU_REJAPL 	:= BB3->BB3_REJAPL
				BBU->BBU_AUTOMA 	:= "1"
				BBU->BBU_PERREJ 	:= BB3->BB3_PERREJ
				BBU->BBU_ANOMES 	:= BB3->BB3_ANOMES
				BBU->BBU_VLRANT 	:= BB3->BB3_VLRANT
			BBU->( MsUnlock() )

			cSql := "SELECT * FROM "+RetSqlName("BFS")+" WHERE "
			cSql += "BFS_FILIAL = '"+xFilial("BFS") +"' AND "
			cSql += "BFS_CODIGO = '"+BB3->BB3_CODIGO+"' AND "
			cSql += "BFS_VERSAO = '"+BB3->BB3_VERSAO+"' AND "
			cSql += "BFS_CODFOR = '"+BB3->BB3_CODFOR+"' AND "
			cSql += "D_E_L_E_T_ = ' ' "
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,changeQuery(cSql)),"TRB2",.F.,.T.)

			while !TRB2->(eof())

				BFY->( RecLock("BFY", .T.) )
				for nCnt := 1 to BFY->( fCount() )
					cCampo := BFY->( Field(nCnt) )

					if cCampo == "BFY_CODOPE"
						BFY->( fieldPut(nCnt, M->BA3_CODINT ) )

					elseif cCampo == "BFY_CODEMP"
						BFY->( fieldPut(nCnt, M->BA3_CODEMP ) )

					elseif cCampo == "BFY_MATRIC"
						BFY->( fieldPut(nCnt, M->BA3_MATRIC ) )

					elseif cCampo == "BFY_AUTOMA"
						BFY->( fieldPut(nCnt, "1") )

					else
						cCampoBFY := "TRB2->"+StrTran(cCampo, "BFY","BFS")

						if BFS->( fieldPos(Substr(cCampoBFY,7)) ) > 0 .and. BFY->( fieldPos(cCampo) ) > 0
							BFY->( fieldPut(nCnt, &cCampoBFY) )
						endIf

					endIf
				next
				BFY->( MsUnlock() )
				TRB2->( dbSkip() )
			endDo
			TRB2->( dbClosearea() )
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁProximo BB3
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			BB3->( dbSkip() )
		endDo
	else
		PLSLOGS(STR0113+xFilial('BB3')+M->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_forPAG)+STR0121,.t.,.t.,.t.)//'Chave [''], nЦo encontrada no BB3'
	endIf

endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da Rorina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return

/*/{Protheus.doc} PLSMonTipRg
Monta o TipReg

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
function PLSMonTipRg(cGrauPa,cTipReg,cTipUsu,cMatFam)
local nRecBa1 	:= BA1->(recno())
local nInd    	:= 1
local nCnt    	:= 0
local lRet    	:= .T.
local lExitaadd	:= .F.
local cModelo 	:= getMv("MV_PLTITCD")
local cSeq    	:= cTipReg
local cSeqIni 	:= "00"
local cSeqFim 	:= "00"
local aTipReg 	:= {}
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Parametro que indica qual o modelo a ser utilizado pela Instituicao de saude
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if cModelo == "1"
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Verifico se o grau de parentesco pesquisado, possui sequencia inicial e final
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if empty(cGrauPa)
		return({cSeq,lRet})
	endIf

	if empty(cMatFam)
		return({cSeq,lRet})
	endIf

	BT2->(dbSetorder(1))
	lRet := BT2->(MsSeek(xFilial("BT2")+cGrauPa))

	if lRet
		cSeqIni := BT2->BT2_SEQDE
		cSeqFim := BT2->BT2_SEQATE
		cSeq    := cSeqIni
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona o usuario para montar o tipo de registro no novo dependente...                  Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BA1->( dbSetorder(02) )
		if !BA1->( dbSeek(xFilial("BA1")+cMatFam) )
			return({cSeq,lRet})
		endIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Carrega matriz com dados para comparacao.												  Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BA1->( dbEval({|| aadd(aTipReg, {BA1->BA1_GRAUPA, BA1->BA1_TIPREG}) },,{|| BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == cMatFam}) )

		for nCnt := 1 to len(aTipReg)
			if cGrauPa == aTipReg[nCnt][1]
				cSeq := StrZero( ( Val(cSeq)+1 ),2 )
				while .T.
					if Ascan( aTipReg,{ |x| x[2] == cSeq } ) > 0
						cSeq := StrZero( ( Val(cSeq)+1 ),2 )
					else
						lExit := .T.
						Exit
					endIf
				endDo
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Mostro o assistente caso a quantidade de grau de parentesco ultrapasse a quantidade  |
				//Ё permitida no cadastro                                                                |
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				if cSeq > cSeqFim
					lRet := .F.
					return({cSeq,lRet})
				endIf
				if lExit
					Exit
				endIf
			endIf
		next
	endIf
else
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifico as parametrizacoes para o cada tipo de usuario             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BF2->( dbSetorder(1) )
	lRet := BF2->( MsSeek( xFilial("BF2") ) )
	if lRet
		while !BF2->( eof() )
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifico se o tipo de usuario que procuro, possui uma sequencia inicial e final                  |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if allTrim(cTipUsu) $ allTrim(BF2->BF2_GRAUPA)
				cSeqIni := BF2->BF2_SEQDE
				cSeqFim := BF2->BF2_SEQATE
				cSeq    := cSeqIni
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Posiciona o usuario para montar o tipo de registro no novo dependente...                  Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BA1->( dbSetorder(02) )
				if !BA1->( MsSeek(xFilial("BA1")+cMatFam) )
					return( {cSeq,lRet} )
				endIf
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Carrega matriz com dados para comparacao.												  Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BA1->( dbEval({|| aadd(aTipReg, {BA1->BA1_GRAUPA, BA1->BA1_TIPREG, BA1->BA1_TIPUSU}) },,{|| BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == cMatFam}) )

				for nInd := 1 to len(aTipReg)
					if allTrim(aTipReg[nInd][3]) $ allTrim(BF2->BF2_GRAUPA)
						cSeq := StrZero((Val(cSeq)+1),2)
					endIf
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Mostro o assistente caso a quantidade de grau de parentesco ultrapasse a quantidade  |
					//Ё permitida no cadastro                                                                |
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					if cSeq > cSeqFim
						lRet := .F.
						return({cSeq,lRet})
					endIf
				next
				Exit
			endIf
			BF2->( dbSkip() )
		endDo
	endIf
endIf
BA1->( dbGoto(nRecBa1) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁFim da funcao														   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
return( {cSeq,lRet} )

/*/{Protheus.doc} PLSIOpc
Carrega Opcionais

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLSIOpc()
local cKeyBHS		:= ''
local cKeyBJW		:= ''
local cKeyBJY		:= ''
local cKeyBBV		:= ''
local cCODFOR   	:= ''
local cCodOpc  	:= ''
local cVerOpc   	:= ''
local cCampo    	:= ''
local cCampoBBY	:= ''
local nPos		:= 0
local nCnt		:= 1

if !lJuridico	// Pessoa Fisica - Opcionais
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Posiciona os opcionais do produto...
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if !BT3->( MsSeek(xFilial("BT3")+M->BA3_CODINT+M->BA3_CODPLA+M->BA3_VERSAO) )
		return
	else

		while !BT3->( eof() ) .and. BT3->(BT3_FILIAL+BT3_CODIGO+BT3_VERSAO) == xFilial('BT3')+M->BA3_CODINT+M->BA3_CODPLA+M->BA3_VERSAO

		   BF1->(dbSetorder(1))
			if !BF1->(MsSeek(xFilial("BF1")+M->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+BT3->BT3_CODPLA))

				BF1->(Reclock("BF1",.T.))
					BF1->BF1_FILIAL := xFilial("BF1")
					BF1->BF1_CODINT := M->BA3_CODINT
					BF1->BF1_CODEMP := M->BA3_CODEMP
					BF1->BF1_MATRIC := M->BA3_MATRIC
					BF1->BF1_CODPRO := BT3->BT3_CODPLA
					BF1->BF1_VERSAO := BT3->BT3_VERPLA
					BF1->BF1_DATBAS := M->BA3_DATBAS
					if BF1->( fieldPos("BF1_TIPVIN") ) > 0
						BF1->BF1_TIPVIN := BT3->BT3_TIPVIN
					endIf
				BF1->(MsUnlock())
			endIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Para opcionais nao vinculados, levo tbm as formas de cobranca...
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			if BT3->BT3_TIPVIN == '0'

				cKeyBJY := xFilial('BJY')+BT3->(BT3_CODIGO+BT3_VERSAO+BT3_CODPLA+BT3_VERPLA)

				BJY->( dbSetorder(01) )
				if BJY->( MsSeek(cKeyBJY) )

					while !BJY->( eof() ) .and. BJY->(BJY_FILIAL+BJY_CODIGO+BJY_VERSAO+BJY_CODOPC+BJY_VEROPC) == cKeyBJY

						BK0->(dbSetorder(1))
						if !BK0->(MsSeek(xFilial("BK0")+M->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+BT3->BT3_CODPLA+BT3->BT3_VERPLA))
								BK0->(Reclock("BK0",.T.))
									BK0->BK0_FILIAL := xFilial("BK0")
									BK0->BK0_CODOPE := M->BA3_CODINT
									BK0->BK0_CODEMP := M->BA3_CODEMP
									BK0->BK0_MATRIC := M->BA3_MATRIC
									BK0->BK0_CODOPC := BT3->BT3_CODPLA
									BK0->BK0_VEROPC := BT3->BT3_VERPLA
									BK0->BK0_CODFOR := BJY->BJY_CODFOR
									cCodOpc := BT3->BT3_CODPLA
									cVerOpc := BT3->BT3_VERPLA
									cCODFOR := BJY->BJY_CODFOR
								BK0->(MsUnlock())
						endIf

						BJY->( dbSkip() )
					endDo
				endIf

				if !Empty(cCODFOR)
					BBV->(dbSetorder(1))
					cKeyBBV := xFilial("BBV") + M->BA3_CODINT + M->BA3_CODPLA + M->BA3_VERSAO + cCodOpc + cVerOpc + cCODFOR
					if BBV->(MsSeek(cKeyBBV))
						while 	!BBV->(eof()) .and. xFilial("BBV")+BBV->BBV_CODIGO +BBV->BBV_VERSAO+BBV->BBV_CODOPC+BBV->BBV_VEROPC+BBV->BBV_CODFOR == cKeyBBV
								BBY->( RecLock("BBY", .T.) )
									for nCnt := 1 to BBY->( fCount() )
										cCampo := BBY->( field(nCnt) )
										if cCampo == "BBY_CODOPE"
											BBY->( fieldPut(nCnt, M->BA3_CODINT ) )
										elseIf cCampo == "BBY_CODEMP"
											BBY->( fieldPut(nCnt, M->BA3_CODEMP ) )
										elseIf cCampo == "BBY_MATRIC"
											BBY->( fieldPut(nCnt, M->BA3_MATRIC ) )
										elseIf cCampo == "BBY_AUtoMA"
											BBY->( fieldPut(nCnt, "1") )
										else
											cCampoBBY := "BBV->"+StrTran(cCampo, "BBY","BBV")
											if BBV->( fieldPos(subStr(cCampoBBY,6)) ) > 0 .and. BBY->( fieldPos(cCampo) ) > 0
												BBY->( fieldPut(nCnt, &cCampoBBY) )
											endIf
										endIf
									next
								BBY->(MsUnlock())

					    	BBV->(DbSkip())
					    endDo
				    endIf
				endIf
			endIf

			BT3->( dbSkip() )
		endDo
	endIf
else
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Posiciona os opcionais do subcontrato...
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	cKeyBHS := xFilial('BHS')+M->BA3_CODINT+M->BA3_CODEMP+M->BA3_CONEMP+M->BA3_VERCON+M->BA3_SUBCON+M->BA3_VERSUB+M->BA3_CODPLA+M->BA3_VERSAO

	BHS->( dbSetorder(01) )
	if BHS->( MsSeek(cKeyBHS) )
		while !BHS->( eof() ) .and. BHS->(BHS_FILIAL+BHS_CODINT+BHS_CODIGO+BHS_NUMCON+BHS_VERCON+BHS_SUBCON+BHS_VERSUB+BHS_CODPRO+BHS_VERPRO) == cKeyBHS
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Adiciona o opcional... vinculados ou nao! A diferenca e que o vinculado vem com valor zerado!     |
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			BF1->(dbSetorder(1))
			if !BF1->(MsSeek(xFilial("BF1")+M->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+BHS->BHS_CODPLA))

				BF1->(Reclock("BF1",.T.))
					BF1->BF1_FILIAL := xFilial("BF1")
					BF1->BF1_CODINT := M->BA3_CODINT
					BF1->BF1_CODEMP := M->BA3_CODEMP
					BF1->BF1_MATRIC := M->BA3_MATRIC
					BF1->BF1_CODPRO := BHS->BHS_CODPLA
					BF1->BF1_VERSAO := BHS->BHS_VERPLA
					BF1->BF1_DATBAS := M->BA3_DATBAS
					if BF1->( fieldPos("BF1_TIPVIN") ) > 0
						BF1->BF1_TIPVIN := BHS->BHS_TIPVIN
					endIf
				BF1->(MsUnlock())
			endIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Para opcionais nao vinculados, levo tbm asformas de cobranca...
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			if BHS->BHS_TIPVIN == '0'

				BJW->( dbSetorder(01) )//BJW_FILIAL+BJW_CODIGO+BJW_NUMCON+BJW_VERCON+BJW_SUBCON+BJW_VERSUB+BJW_CODPRO+BJW_VERSAO+BJW_CODOPC+BJW_VEROPC+BJW_CODFOR
				cKeyBJW := xFilial('BJW')+BHS->(BHS_CODINT+BHS_CODIGO+BHS_NUMCON+BHS_VERCON+BHS_SUBCON+BHS_VERSUB+BHS_CODPRO+BHS_VERPRO+BHS_CODPLA+BHS_VERPLA)

				if BJW->( MsSeek(cKeyBJW) )
					while !BJW->( eof() ) .and. BJW->(BJW_FILIAL+BJW_CODIGO+BJW_NUMCON+BJW_VERCON+BJW_SUBCON+BJW_VERSUB)+BJW->(BJW_CODPRO+BJW_VERSAO+BJW_CODOPC+BJW_VEROPC) == cKeyBJW

						BK0->(dbSetorder(1))
						if !BK0->(MsSeek(xFilial("BK0")+M->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+BHS->BHS_CODPLA+BHS->BHS_VERPLA))
								BK0->(Reclock("BK0",.T.))
									BK0->BK0_FILIAL := xFilial("BK0")
									BK0->BK0_CODOPE := M->BA3_CODINT
									BK0->BK0_CODEMP := M->BA3_CODEMP
									BK0->BK0_MATRIC := M->BA3_MATRIC
									BK0->BK0_CODOPC := BHS->BHS_CODPLA
									BK0->BK0_VEROPC := BHS->BHS_VERPLA
									BK0->BK0_CODFOR := BJW->BJW_CODFOR
									cCodOpc := BHS->BHS_CODPLA
									cVerOpc := BHS->BHS_VERPLA
									cCODFOR := BJW->BJW_CODFOR
								BK0->(MsUnlock())
						endIf

						BJW->( dbSkip() )
					endDo
				endIf

				if !Empty(cCODFOR)
					cKeyBBX := xFilial("BBX") + M->BA3_CODINT + M->BA3_CODEMP + M->BA3_CONEMP + M->BA3_VERCON + M->BA3_SUBCON + M->BA3_VERSUB + M->BA3_CODPLA + M->BA3_VERSAO + cCodOpc + cVerOpc + cCODFOR + '001'

					BBX->(dbSetorder(1))
					if BBX->(MsSeek(cKeyBBX))
						while ! BBX->(eof()) .and. BBX->BBX_FILIAL+BBX->BBX_CODIGO+BBX->BBX_NUMCON+BBX->BBX_VERCON+BBX->BBX_SUBCON+;
								   BBX->BBX_VERSUB+BBX->BBX_CODPRO+BBX->BBX_VERPRO+BBX->BBX_CODOPC+BBX->BBX_VEROPC+;
								   BBX->BBX_CODFOR+BBX->BBX_CODQTD == cKeyBBX

								BBY->( RecLock("BBY", .T.) )
									for nCnt := 1 to BBY->( fCount() )
										cCampo 		:= BBY->( field(nCnt) )
										if cCampo == "BBY_CODOPE"
											BBY->( fieldPut(nCnt, M->BA3_CODINT ) )
										elseIf cCampo == "BBY_CODEMP"
											BBY->( fieldPut(nCnt, M->BA3_CODEMP ) )
										elseIf cCampo == "BBY_MATRIC"
											BBY->( fieldPut(nCnt, M->BA3_MATRIC ) )
										elseIf cCampo == "BBY_AUtoMA"
											BBY->( fieldPut(nCnt, "1") )
										else
											cCampoBBY := "BBX->"+StrTran(cCampo, "BBY","BBX")
											if BBX->( fieldPos(subStr(cCampoBBY,6)) ) > 0 .and. BBY->( fieldPos(cCampo) ) > 0
												BBY->( fieldPut(nCnt, &cCampoBBY) )
											endIf
										endIf
									next
								BBY->(MsUnlock())

					    	BBX->(DbSkip())
					    endDo
				    endIf
				endIf
			endIf

			BHS->( dbSkip() )
		endDo
	endIf
endIf

if !empty(cCODFOR)
	M->BA3_FORCOP := cCODFOR
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return()

/*/{Protheus.doc} PLSCL
Cliente e Loja

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLSCL()
local cCpf := ''

BBL->(dbSetorder(2))
if BBL->(MsSeek(xFilial("BBL")+"PLSA260   "+"BA1"+"SA1"))

	if !empty(M->BA1_CPFUSR)
		cCpf := M->BA1_CPFUSR
	elseIf !Empty(M->BA1_CPFPRE)
		cCpf := M->BA1_CPFPRE
	elseIf !Empty(M->BA1_CPFMAE)
		cCpf := M->BA1_CPFMAE
	elseIf !Empty(M->BA1_CPFPAI)
		cCpf := M->BA1_CPFPAI
	endIf

	SA1->(dbSetorder(03) )
	if !SA1->( MsSeek(xFilial("SA1")+cCpf) )
		cVlCod	 := criaVar("A1_COD")
		cVlLoj	 := criaVar("A1_LOJA")

		cCodSa1 := if(!empty(cVlCod),cVlCod,getSX8Num("SA1","A1_COD"))
		cLojSa1 := if(!empty(cVlLoj),cVlLoj,"01")

		SA1->(recLock("SA1",.T.))
			SA1->A1_FILIAL:= xFilial("SA1")
			SA1->A1_COD	:= cCodSA1
			SA1->A1_LOJA	:= cLojSA1
			SA1->A1_TIPO 	:= "F"

			plsSinc("PLSA260","BA1","SA1")
		SA1->(msUnLock())

		confirmSX8()
	else
		cCodSa1 := SA1->A1_COD
		cLojSa1 := SA1->A1_LOJA
	endIf

	M->BA3_CODCLI	:= cCodSA1
	M->BA3_LOJA	:= cLojSA1
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Alteracao
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	PLUPTENC( 'BA3',K_Alterar,,,.f. )

endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return()

/*/{Protheus.doc} PLSOPCUS
Trata Opcionais Usuario

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLSOPCUS(cCodPro,cforpag,cCodInt,cCodEmp,cMatric,cTipReg,cCodpla,cVerPla)
local cKeyBBV 	:= ""
local cCampoBZX := ""
local cCampo    := ""
local nCnt      := 0

if !lJuridico	// Pessoa Fisica - Opcionais

	BT3->(dbSetorder(1))//BT3_FILIAL, BT3_CODIGO, BT3_VERSAO, BT3_CODPLA, BT3_VERPLA
	if !BT3->( MsSeek(xFilial("BT3")+cCodInt+cCodpla+cVerPla+cCodPro) )
		return
	else
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Para opcionais nao vinculados, levo tbm as formas de cobranca...
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if BT3->BT3_TIPVIN == '0'
		   BYX->(dbSetorder(1))//BYX_FILIAL, BYX_CODOPE, BYX_CODEMP, BYX_MATRIC, BYX_TIPREG, BYX_CODOPC, BYX_VEROPC, BYX_CODFOR
		   if ! BYX->(MsSeek(xFilial("BYX")+cCodInt+cCodEmp+cMatric+cTipReg+cCodPro))
		       BYX->(Reclock("BYX",.T.))
				    BYX->BYX_FILIAL := xFilial("BYX")
				    BYX->BYX_CODOPE := cCodInt
				    BYX->BYX_CODEMP := cCodEmp
				    BYX->BYX_MATRIC := cMatric
				    BYX->BYX_TIPREG := cTipReg
				    BYX->BYX_CODOPC := cCodPro
				    BYX->BYX_VEROPC := "001"
				    BYX->BYX_CODFOR := cforpag
				    BYX->BYX_RGIMP  := "1"
			    BYX->(MsUnlock())
		   else
			    if Empty(BYX->BYX_CODFOR)
				   BYX->( RecLock("BYX",.F.) )
			   	   		BYX->BYX_CODFOR := cforpag
			  	   BYX->( MsUnlock() )
			    endIf
		   endIf

			BBV->(dbSetorder(1))
			cKeyBBV := xFilial("BBV") + cCodInt + cCodpla + cVerPla + BYX->BYX_CODOPC + BYX->BYX_VEROPC + cforpag
			dbSelectArea("BBV")
			BBV->(MsSeek(cKeyBBV))
			while 	!BBV->(eof()) .and. xFilial("BBV")+BBV->BBV_CODIGO+BBV->BBV_VERSAO+BBV->BBV_CODOPC+BBV->BBV_VEROPC+BBV->BBV_CODFOR == cKeyBBv

			   		BZX->( RecLock("BZX", .T.) )
						for nCnt := 1 to BZX->( fCount() )
							cCampo 		:= BZX->( field(nCnt) )
							if cCampo == "BZX_CODOPE"
								BZX->( fieldPut(nCnt, M->BA3_CODINT ) )
							elseIf cCampo == "BZX_CODEMP"
								BZX->( fieldPut(nCnt, M->BA3_CODEMP ) )
							elseIf cCampo == "BZX_MATRIC"
								BZX->( fieldPut(nCnt, M->BA3_MATRIC ) )
							elseIf cCampo == "BZX_TIPREG"
								BZX->( fieldPut(nCnt, cTipReg ) )
							elseIf cCampo == "BZX_AUtoMA"
								BZX->( fieldPut(nCnt, "1") )
							else
								cCampoBZX := "BBV->"+StrTran(cCampo, "BZX","BBV")
								if BBV->( fieldPos(subStr(cCampoBZX,6)) ) > 0 .and. BZX->( fieldPos(cCampo) ) > 0
									BZX->( fieldPut(nCnt, &cCampoBZX) )
								endIf
							endIf
						next nCnt
			   		BZX->( MsUnlock() )

				BBV->(DbSkip())
			endDo
		endIf
	endIf
else
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Posiciona os opcionais do subcontrato...
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	cKeyBHS := cCodInt+cCodEmp+M->BA3_CONEMP+M->BA3_VERCON+M->BA3_SUBCON+M->BA3_VERSUB+M->BA3_CODPLA+M->BA3_VERSAO+cCodPro

	BHS->( dbSetorder(01) )

	if !BHS->( MsSeek(xFilial("BHS")+cKeyBHS) )
		return
	else
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Para opcionais nao vinculados, levo tbm as formas de cobranca...
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if BHS->BHS_TIPVIN == '0'
			BJW->( dbSetorder(01) )//BJW_FILIAL+BJW_CODIGO+BJW_NUMCON+BJW_VERCON+BJW_SUBCON+BJW_VERSUB+BJW_CODPRO+BJW_VERSAO+BJW_CODOPC+BJW_VEROPC+BJW_CODFOR

			cKeyBJW := xFilial('BJW')+BHS->(BHS_CODINT+BHS_CODIGO+BHS_NUMCON+BHS_VERCON+BHS_SUBCON+BHS_VERSUB+BHS_CODPRO+BHS_VERPRO+BHS_CODPLA+BHS_VERPLA)

			if BJW->( MsSeek(cKeyBJW) )
				while !BJW->( eof() ) .and. BJW->(BJW_FILIAL+BJW_CODIGO+BJW_NUMCON+BJW_VERCON+BJW_SUBCON+BJW_VERSUB)+BJW->(BJW_CODPRO+BJW_VERSAO+BJW_CODOPC+BJW_VEROPC) == cKeyBJW

					   BYX->(dbSetorder(1))//BYX_FILIAL, BYX_CODOPE, BYX_CODEMP, BYX_MATRIC, BYX_TIPREG, BYX_CODOPC, BYX_VEROPC, BYX_CODFOR
					   if ! BYX->(MsSeek(xFilial("BYX")+cCodInt+cCodEmp+cMatric+cTipReg+cCodPro))
					       BYX->(Reclock("BYX",.T.))
							    BYX->BYX_FILIAL := xFilial("BYX")
							    BYX->BYX_CODOPE := cCodInt
							    BYX->BYX_CODEMP := cCodEmp
							    BYX->BYX_MATRIC := cMatric
							    BYX->BYX_TIPREG := cTipReg
							    BYX->BYX_CODOPC := cCodPro
							    BYX->BYX_VEROPC := "001"
							    BYX->BYX_CODFOR := cforpag
							    BYX->BYX_RGIMP  := "1"
						    BYX->(MsUnlock())
					   else
						    if Empty(BYX->BYX_CODFOR)
							   BYX->( RecLock("BYX",.F.) )
						   	   		BYX->BYX_CODFOR := cforpag
						  	   BYX->( MsUnlock() )
						    endIf
				   	   endIf

					BJW->( dbSkip() )
				endDo
			endIf

			if !Empty(cforpag)

				cKeyBBX :=  xFilial("BBX") + M->BA3_CODINT + M->BA3_CODEMP + M->BA3_CONEMP + M->BA3_VERCON + M->BA3_SUBCON + M->BA3_VERSUB + M->BA3_CODPLA + M->BA3_VERSAO + cCodPro + "001" + cforpag

				BBX->(dbSetorder(1))
				if BBX->(MsSeek(cKeyBBX))
					while ! BBX->(eof()) .and. BBX->BBX_FILIAL+BBX->BBX_CODIGO+BBX->BBX_NUMCON+BBX->BBX_VERCON+BBX->BBX_SUBCON+BBX->BBX_VERSUB+BBX->BBX_CODPRO+BBX->BBX_VERPRO+BBX->BBX_CODOPC+BBX->BBX_VEROPC+BBX->BBX_CODFOR == cKeyBBX
   							BZX->( RecLock("BZX", .T.) )
								for nCnt := 1 to BZX->( fCount() )
									cCampo 		:= BZX->( field(nCnt) )
									if cCampo == "BZX_CODOPE"
										BZX->( fieldPut(nCnt, M->BA3_CODINT ) )
									elseIf cCampo == "BZX_CODEMP"
										BZX->( fieldPut(nCnt, M->BA3_CODEMP ) )
									elseIf cCampo == "BZX_MATRIC"
										BZX->( fieldPut(nCnt, M->BA3_MATRIC ) )
									elseIf cCampo == "BZX_TIPREG"
										BZX->( fieldPut(nCnt, M->BA1_TIPREG ) )
									elseIf cCampo == "BZX_AUtoMA"
										BZX->( fieldPut(nCnt, "1") )
									else
										cCampoBZX := "BBX->"+StrTran(cCampo, "BZX","BBX")
										if BBX->( fieldPos(subStr(cCampoBZX,6)) ) > 0 .and. BZX->( fieldPos(cCampo) ) > 0
											BZX->( fieldPut(nCnt, &cCampoBZX) )
										endIf
									endIf
								next
							BZX->( MsUnlock() )
				    	BBX->(DbSkip())
				    endDo
			    endIf
			endIf
		endIf

		BHS->( dbSkip() )
	endIf
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return


/*/{Protheus.doc} PLCSVXML
Converte CSV para XML

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
function PLCSVXML()
local lRet 	:= .t.
local aRet 	:= {}

//variaveis utilizadas pelo plsxsdsin
private cFileTmp	:= 'TMP'+DtoS(date())+StrTran(time(),":","")
private cDir 	:= ""
private cDirAlt	:= ""
private cCombo	:= ""
private cComSix	:= ""
private _cChave 	:= space(160)
private cTab 	:= ""
private aSx3		:= {}
private aSx2		:= {}

if empty(cDirXSD)
	msgAlert(STR0122)//'Selecione o layout XSD'
	lRet := .f.
endIf

if lRet .and. !empty(cDirXML)
	msgAlert(STR0123)//'JА existe um XML selecione utilize a opГЦo validar'
	lRet := .f.
endIf

if lRet .and. empty(cDirCSV)
	msgAlert(STR0124)//'Selecione o arquivo CSV'
	lRet := .f.
endIf

if lRet
	//carrega XSD para montar XML
	aRet := PLLERSXD(nil,nil,nil,.t.,cDirXSD)

	if !empty(aRet[1]) .and. len(aSx2)>0 .and. len(aSx3)>0
		//gera xml by csv
		processa( {|| PLCRIXML(aRet,cDirCSV) }, STR0125, STR0126,.f.)//"Aguarde""Convertendo..."
	else
		msgAlert(STR0127)//'Erro ao carregar XSD'
	endIf
endIf

return(lRet)


/*/{Protheus.doc} PLCRIXML
Cria XML conforme CSV

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
function PLCRIXML(aRet,cFile)
local nI,nY		:= 0
local nPos		:= 0
local cRelac		:= aRet[1]
local cIdx		:= aRet[2]
local nH			:= 0
local nQtdLin 	:= 0
local nQtdReg		:= 0
local nPosLin		:= 0
local nTamCab		:= 0
local nPosAux		:= 0
local nTam		:= iIf(len(aSx3)>0, len(aSx3[1]) ,0)
local nTamII		:= iIf(len(aSx2)>0, len(aSx2[1]) ,0)
local lFirst		:= .t.
local lBuffer		:= .t.
local lChkStru	:= .t.
local cTIni 		:= time()
local cLine		:= ""
local cTipo		:= ""
local cDescri		:= ""
local cAlias		:= ""
local cSeparador	:= ";"
local cField 		:= ""
local cConteudo	:= ""
local cTpBloDes	:= ""
local cDatBloDes	:= ""
local cStatus		:= ""
local cObsOper	:= ""
local cTipoAcao	:= ""
local cRaiz 		:= subStr(cRelac,1,3)
local __cTab		:= subStr(cRelac,5,Len(cRelac))
local __cDir 		:= subStr(cDirXSD,1,rAt('\',cDirXSD))
local aFirstLine	:= {}
local aAux 		:= {}
local aChave		:= {}
local aMatAux		:= {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Nome do arquivo
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
__cTab := 'sincronizador-'+strTran(allTrim(__cTab),',','-')+'-'+dtos(date())+".xml"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se o arquivo XML existe
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if file(__cDir+__cTab)
	if msgYesNo(STR0128)//"Existe um arquivo XML, com o mesmo nome gerado nesta pasta. Deseja deletar o arquivo?"
		if fErase(__cDir+__cTab) == -1
			plsLogFil(STR0129+__cDir+__cTab+"]",__cArqLog)//"NЦo foi possМvel deletar arquivo ["
		endIf
	else
		return
	endIf
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁMonta XML de Exemplo	ts = ts Saude							  	   	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cDescri += '<?xml version="1.0" encoding="ISO-8859-1"?>'
cDescri += '<!--XML sincronizador - NameSpace ts (Totvs Saude)-->'
cDescri += ' <ts:sincronizador xmlns="http://localhost" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://localhost '+lower(cDirXSD)+'" xmlns:ts="http://localhost">
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁAbertura do Cabecalho												   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cDescri += ' <ts:cabecalho> '
	cDescri += ' <ts:titulo>Sincronizador de dados referente ao relacionamento ['+strTran(cRelac,'>',',')+']</ts:titulo> '
	cDescri += ' <ts:relacionamento>'+strTran(cRelac,'>',',')+'</ts:relacionamento> '
	cDescri += ' <ts:data>'+dtos(date())+'</ts:data> '
	cDescri += ' <ts:responsavelLayout>'+allTrim(PLRETOPE())+'</ts:responsavelLayout> '

	cDescri += ' <ts:entidadeRaiz> '
		cDescri += ' <ts:alias>'+cRaiz+'</ts:alias> '
		cDescri += ' <ts:idxChave>'+cIdx+'</ts:idxChave> '
		cDescri += ' <ts:conteudo>'+allTrim(_cChave)+'</ts:conteudo> '
	cDescri += ' </ts:entidadeRaiz> '

	cDescri += ' <ts:origem> '
		cDescri += ' <ts:codigo>'+left(strTran(time(),':',''),4)+'</ts:codigo> '
		cDescri += ' <ts:descricao>'+allTrim(subStr(allTrim(cFile),rAt('\',cFile)+1))+'</ts:descricao> '
		cDescri += ' <ts:responsavelConteudo>'+allTrim(PLRETOPE())+'</ts:responsavelConteudo> '
	cDescri += ' </ts:origem> '
cDescri += ' </ts:cabecalho> '
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFechamendo do cabecalho e Abertura do corpo
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cDescri += ' <ts:corpo> '

nH 		 := ft_fUse(cFile)
nQtdLin := ft_fLastRec()

procRegua(nQtdLin)

ft_fGotop()

if nH <> -1

	while (!ft_fEof())

		cLine := ""
		
		//Tratamento para quebra de linha de arquivo maior que 1023 caracteres - F?io Consentino 02/06/16
		While .T.
		
			cLine += FT_fReadLn()
			
      //Verifica se encontrou o final da linha para gravar                                                               
			If Len(FT_fReadLn()) < 1023
				Exit
			Else
				Ft_fSkip()
			EndIf
		EndDo

		cLine := StrTran(cLine,cSeparador,cSeparador+" ")

		incProc()

		if empty(cLine)
			ft_fSkip()
			loop
		endIf

		//Identificador na primeira linha
		if nTamCab == 0

			aFirstLine	:= strToKarr(cLine,cSeparador)
			nTamCab	:= len(aFirstLine)

			ft_fSkip()
			loop
		else
			//retira dados do csv e alimenta aSx3
			aAux := strToKarr(cLine,cSeparador)
			nPosLin++

			if nTamCab <> len(aAux)
				msgAlert(STR0130+cValToChar(nPosLin)+']')//'ConversЦo abortada, cabeГalho do arquivo CSV esta diferente do corpo. Linha ['
				return
			endIf

			aMatAux := {}
			for nY:=1 to len(aFirstLine)
				cField 	:= upper(allTrim(aFirstLine[nY]))
				cConteudo := allTrim(aAux[nY])

				//pega campo chave
				if at('CHAVE@',cField)>0

					if ( nPos := aScan(aChave,{|x| x[1] == cField } ) )>0
						aChave[nPos,2] := ( (aChave[nPos,3] <> cConteudo) .OR. at('BA1',cField)>0 )
						aChave[nPos,3] := cConteudo
					else
						aadd(aChave,{upper(cField),iIf(empty(cConteudo),.f.,.t.),cConteudo,.f.})
					endIf

				elseIf	 at('BLODES@',cField)>0 .or. at('DATBLO@',cField)>0 .or. at('STATUS@',cField)>0 .or. at('OBSOOPERADOR@',cField)>0 .or. at('TIPOACAO@',cField)>0 .or. at('OBSPROCESSAMENTO@',cField)>0

					if !empty(cConteudo)
						aadd(aMatAux,{upper(cField),cConteudo})
					endIf

				else

					if (nPos := aScan(aSx3,{|x| allTrim(x[2]) == cField .and. x[len(x)] } )) > 0
						aSx3[nPos,9] := cConteudo
					else
						msgAlert(STR0131+cField+']')//'ConversЦo abortada, layout XSD diferente do arquivo CSV. Campo ['
						return
					endIf

				endIf
			next

			if lChkStru

				lChkStru := .f.

				for nY:=1 to len(aSX2)

					if aSx2[nY,nTamII]

						cAlias := aSx2[nY,1]

						if aScan(aChave,{|x| cAlias $ x[1] })==0
							msgAlert(STR0132+cAlias+']')//'ConversЦo abortada, layout XSD diferente do arquivo CSV. Alias ['
							return
						endIf
					endIf
				next
			endIf
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁFechamento TAG
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if !lFirst
			for nY:=len(aChave) to 1 step -1
				if aChave[nY,2] .and. aChave[nY,4]
					cDescri += ' </ts:'+allTrim(subStr(aChave[nY,1],1,3))+'> '
					aChave[nY,4] := .f.
				endIf
			next
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁAbertura TAG
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		for nY := 1 to len(aSx2)

			cAlias	 := aSx2[nY,1]
			lFirst	 := (nY==1)

			if aSx2[nY,nTamII] .and. aChave[nY,2] .and. !empty(aChave[nY,3])

				aChave[nY,4] := .t.
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//ЁAlias
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				cDescri += ' <ts:'+allTrim(cAlias)+'> '
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//ЁSomente para o alias raiz
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					if lFirst
						cStatus	:= ''
						cObsOper 	:= ''

						if (nPosAux := aScan(aMatAux,{|x| 'STATUS@' == x[1] }))>0
							cStatus := aMatAux[nPosAux,2]
						endIf

						if (nPosAux := aScan(aMatAux,{|x| 'OBSOOPERADOR@' == x[1] }))>0
							cObsOper := aMatAux[nPosAux,2]
						endIf

						nQtdReg++
						cDescri += ' <ts:sequencia>'+strZero(nQtdReg,5)+'</ts:sequencia> '
						cDescri += ' <ts:status>'+cStatus+'</ts:status> '
						cDescri += ' <ts:obsOperador>'+cObsOper+'</ts:obsOperador> '
					endIf
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//ЁRegistro
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					cDescri += ' <ts:registro> '

						cTipoAcao	:= ''
						if (nPosAux := aScan(aMatAux,{|x| upper(cAlias)+'TIPOACAO@' == x[1] }))>0
							cTipoAcao := aMatAux[nPosAux,2]
						endIf

						cDescri += ' <ts:tipoAcao>'+cTipoAcao+'</ts:tipoAcao> '
						cDescri += ' <ts:campos> '
							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							//ЁInclui campos
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							nPos := aScan(aSx3,{|x| upper(x[7]) == upper(cAlias)})

							for nI:=nPos to len(aSx3)

								if aSx3[nI,7] == cAlias

									if aSx3[nI,nTam]
										//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
										//Ёconteudo do sx3
										//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
										cRestri := allTrim(aSx3[nI,9])
										//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
										//ЁConteudo campo
										//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
										do case
											case aSx3[nI,3] == 'C'
												cTipo := iIf(!empty(cRestri),cRestri,'')
											case aSx3[nI,3] == 'N' .and. !empty(aSx3[nI,5])
												cTipo := iIf(!empty(cRestri),cRestri,'0')
											case aSx3[nI,3] == 'N'
												cTipo := iIf(!empty(cRestri),cRestri,'0')
											case aSx3[nI,3] == 'D'
												cTipo := iIf(!empty(cRestri),cRestri,'')
											otherWise
												cTipo := iIf(!empty(cRestri),cRestri,'0')
										endCase
										//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
										//ЁMontando Tag
										//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
										cDescri += '    <ts:'+allTrim(aSx3[nI,2])+'>'+cTipo+'</ts:'+allTrim(aSx3[nI,2])+'> '
									endIf
								else
									exit
								endIf
							next
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						//ЁFecha campos e dados
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						cDescri += ' </ts:campos> '
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						//ЁBloqueio/Desbloqueio
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						cTpBloDes  := ''
						cDatBloDes := ''
						if (nPosAux := aScan(aMatAux,{|x| upper(cAlias)+'BLODES@' $ x[1] }))>0
							cTpBloDes := aMatAux[nPosAux,2]
						endIf

						if !empty(cTpBloDes)

							if (nPosAux := aScan(aMatAux,{|x| upper(cAlias)+'DATBLO@' $ x[1] }))>0
								cDatBloDes := aMatAux[nPosAux,2]
							endIf

							cDescri += ' <ts:bloqueioDesbloqueio> '
								cDescri += ' <ts:tipo>'+cTpBloDes+'</ts:tipo>'
								cDescri += ' <ts:data>'+cDatBloDes+'</ts:data>'
								cDescri += ' <ts:observacao>'+iIf(cTpBloDes=='1',STR0133,STR0134)+'</ts:observacao>'//'Desbloqueio importacao''Bloqueio importacao'
							cDescri += ' </ts:bloqueioDesbloqueio> '
						endIf
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						//ЁSe for diferente de inclusao 4 - alteracao, 8 - bloqueio e desbloqueio e 9 -referencia
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						if cTipoAcao <> '3'

							if (nPosAux := aScan(aChave,{|x| upper(cAlias)+'CHAVE@' == x[1] }))>0
								cDescri += ' <ts:chave>'+aChave[nPosAux,3]+'</ts:chave>'
							endIf
						endIf

						if (nPosAux := aScan(aMatAux,{|x| upper(cAlias)+'OBSPROCESSAMENTO@' $ x[1] }))>0
							cDescri += ' <ts:obsProcessamento>'+aMatAux[nPosAux,2]+'</ts:obsProcessamento>'
						endIf

					cDescri += ' </ts:registro> '
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//ЁGrava conteudo
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				PLGRVARQ(cDescri,,,__cDir,lBuffer)
				cDescri := ''
			endIf
		next
	ft_fSkip()
	endDo
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁFechamento dos alias
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	for nY:=len(aChave) to 1 step -1
		if aChave[nY,4]
			cDescri += ' </ts:'+allTrim(subStr(aChave[nY,1],1,3))+'> '
		endIf
	next
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁFechamento do corpo
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	cDescri += ' </ts:corpo> '
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁAbertura do rodape
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	cDescri += ' <ts:rodape> '
	cDescri += ' <ts:dataHoraProcessamento>'+dtos(date())+'-'+subStr(time(),1,5)+'</ts:dataHoraProcessamento> '
	cDescri += ' <ts:observacao>'+STR0135+'</ts:observacao> '//Arquivo gerado na conversao de CSV para XML
	cDescri += ' </ts:rodape>
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁFechamento Raiz
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	cDescri += ' </ts:sincronizador> '
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁGravacao Arquivo
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if PLGRVARQ(cDescri,'XML',__cTab,__cDir,.f.)
		cDirXML := __cDir+__cTab
	endIf
else
	msgAlert(STR0136)//'ImpossМvel ler arquivo CSV'
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁClose file
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
fClose(nH)

FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0137 + cTIni + STR0138 + time() + STR0139 + allTrim(cValtoChar(nQtdLin))  , 0, 0, {}) //'Inicio.: ' ' Fim .: '' Quantidade de linhas no arquivo.:'
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da funcao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return

/*/{Protheus.doc} PLXMLCSV
Converte de XML para CSV

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLXMLCSV()
local oXml 	:= tXmlManager():New()
local cArqXML	:= ''
local __cDir 	:= subStr(cDirXML,1,rAt('\',cDirXML))
local __cTab 	:= 'xmltocsv-'+dtos(date())+".csv"

//variaveis utilizadas pelo plsxsdsin
private cFileTmp	:= 'TMP'+DtoS(Date())+StrTran(Time(),":","")
private cDir 	:= ""
private cDirAlt	:= ""
private cCombo	:= ""
private cComSix	:= ""
private _cChave 	:= space(160)
private cTab 	:= ""
private aSx3		:= {}
private aSx2		:= {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se os arquivos foram selecionados
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if empty(cDirXML)
	msgAlert(STR0140)//'Selecione o arquivo XML'
	return .f.
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ёverifica se o arquivo existe e cria
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if file(__cDir+__cTab)
	if fErase(__cDir+__cTab) == -1
		PLSLOGS(STR0141+__cDir+__cTab+"]",.t.,.t.,.t.,.t.)//"NЦo foi possМvel deletar CSV ["
		return .f.
	endIf
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё seta arquivo usado no servidor
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cArqXML := PLSMUDSIS("\xmlsin\"+subStr(cDirXML,rat('\',cDirXML)+1,len(cDirXML)))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁCopia para o diretorio de trabalho no servidor
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

if !__copyfile( cDirXML,PLSMUDSIS("\xmlsin")+substr(cDirXML,RAt("\",cDirXML)))
	msgAlert(STR0011)  //"NЦo foi possМvel copiar o arquivo XML para Аrea de trabalho no Servidor"
	return .f.
endIf


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁZera erros
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oXml:resetErrors()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁMonta Obj XML
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if oXml:parseFile(cArqXML)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁRegistra o namespace
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oXml:xPathRegisterNs('ts', "http://localhost" )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁDeleta arquivo da area de trabalho no servidor
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if fErase(cArqXML) == -1
		PLSLOGFIL(STR0012,cArqGer) //"NЦo foi possМvel deletar o arquivo XML da Аrea de trabalho no Servidor"
	endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁVerificacao de possivel erro
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
else
	msgAlert(STR0142+oXml:error()+']')//'XML - Invalido ['
	return .f.
endIf

processa( {|| PLCRICSV(oXml,__cDir,__cTab) }, STR0143, STR0144,.f.)//"Aguarde""Convertendo..."
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rorina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return(.t.)

/*/{Protheus.doc} PLPROCSV
Converte de XML para CSV

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLCRICSV(oXml,__cDir,__cTab)
local nI,nY			:= 0
local nTNos 			:= 1
local nTamCab			:= 0
local nTamLin			:= 0
local cPControle 	:= ''
local cRProc 			:= ''
local cStatus 		:= ''
local cObsOper 		:= ''
local cLinha			:= ''
local aRelac			:= ''
local cAlias			:= ''
local cAliasPath		:= ''
local cCabec			:= "/ts:sincronizador/ts:cabecalho"
local 	cCorpo			:= "/ts:sincronizador/ts:corpo"
local cCabecalho		:= "STATUS@;OBSOOPERADOR@"
local aLinha			:= {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁProtocolo de controle
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if !oXml:xPathHasNode(cCabec+"/ts:protocoloControle")
	cPControle := oXml:XPathGetNodeValue(cCabec+"/ts:protocoloControle")
endIf

if !oXml:xPathHasNode(cCabec+"/ts:responsavelProcessamento")
	cRProc := oXml:XPathGetNodeValue(cCabec+"/ts:responsavelProcessamento")
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁAlias principal
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
aRelac	:= strToKarr(subStr(oXml:xPathGetNodeValue(cCabec+"/ts:relacionamento"),5),',')
cAlias	:= aRelac[1]
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁQuantidade de NOS do corpo
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
nTNos := oXml:xPathChildCount(cCorpo)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁDados do Registro NO corpo
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
for nI:=1 to nTNos
	cAliasPath	:= cCorpo + '/ts:' + cAlias + '[' + cValToChar(nI) + ']'
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ёmonta registro e cabecalho
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	PLPROCSV(oXml,cAlias,cAliasPath,@cCabecalho,,,.f.)

	for nY:=1 to len(aRelac)
		lFinish := at(aRelac[nY],cCabecalho)>0
	next

	if lFinish
		exit
	endIf
next

nTamCab := len(strToKarr(cCabecalho,';'))

PLGRVARQ(cCabecalho+chr(10),,,__cDir,.t.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁRegua
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
procRegua(nTNos)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁDados do Registro NO corpo
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
for nI:=1 to nTNos

	incProc()

	cAliasPath	:= cCorpo + '/ts:' + cAlias + '['+cValToChar(nI)+']'
	cStatus 	:= oXml:xPathGetNodeValue(cAliasPath+"/ts:status")
	cObsOper	:= oXml:xPathGetNodeValue(cAliasPath+"/ts:obsOperador")
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ёmonta linha
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	cLinha := cStatus+";"+cObsOper
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ёmonta registro e cabecalho
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	PLPROCSV(oXml,cAlias,cAliasPath,,cLinha,aLinha,.t.)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ёgrava no arquivo
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	for nY:=1 to len(aLinha)
		cLinha	 := aLinha[nY]
		nTamLin := len(strToKarr(strTran(cLinha,';','; '),';'))

		if nTamLin < nTamCab
			cLinha += replicate(";",(nTamCab-nTamLin))
		endIf

		PLGRVARQ(cLinha+chr(10),,,__cDir,.t.)
	next

	aLinha	:= {}
next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё cria arquivo
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
PLGRVARQ('','CSV',__cTab,__cDir,.f.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rorina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return

/*/{Protheus.doc} PLPROCSV
Converte de XML para CSV

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLPROCSV(oXml,cAlias,cAliasPath,cCabecalho,cLinha,aLinha,lCorpo)
local lBloq			:= .f.
local nI				:= 0
local cRegistroPath	:= ''
local cTipoAcao 		:= ''
local cTipoDB 		:= ''
local cDataDB 		:= ''
local cObsProc 		:= ''
local cChave 			:= ''
local aAux			:= {}
local aCampos			:= {}
local cMotDB        := ''

default cCabecalho	:= ''
default cLinha		:= ''
default aLinha 		:= {}
default lCorpo 		:= .t.

cRegistroPath	:= cAliasPath+"/ts:registro"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ёtag registro
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if lCorpo
	cTipoAcao 	:= oXml:xPathGetNodeValue(cRegistroPath+"/ts:tipoAcao")

	lBloq := .f.
	if oXml:xPathHasNode(cRegistroPath+"/ts:bloqueioDesbloqueio")
		cTipoDB := oXml:xPathGetNodeValue(cRegistroPath+"/ts:bloqueioDesbloqueio/ts:tipo")
		cDataDB := oXml:xPathGetNodeValue(cRegistroPath+"/ts:bloqueioDesbloqueio/ts:data")
		cMotDB	:= oXml:xPathGetNodeValue(cRegistroPath+"/ts:bloqueioDesbloqueio/ts:consid")
		lBloq	 := .t.
	endIf

	if oXml:xPathHasNode(cRegistroPath+"/ts:obsProcessamento")
		cObsProc := oXml:XPathGetNodeValue(cRegistroPath+"/ts:obsProcessamento")
	endIf

	if oXml:xPathHasNode(cRegistroPath+"/ts:chave")
		cChave := oXml:xPathGetNodeValue(cRegistroPath+"/ts:chave")
	endIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ёmonta linha
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	cLinha += ";"+cObsProc+";"+cTipoAcao+";"+cChave

	if lBloq
		cLinha += ";"+cTipoDB+";"+cDataDB
	endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁCabecalho
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
else
	if at(cAlias,cCabecalho)==0
		cCabecalho += ";"+cAlias+'OBSPROCESSAMENTO@;'+cAlias+'TIPOACAO@;'+cAlias+'CHAVE@'

		if oXml:xPathHasNode(cRegistroPath+"/ts:bloqueioDesbloqueio")
			cCabecalho += ";"+cAlias+'BLODES@;'+cAlias+'DATBLO@'
		endIf
	endIf
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Campos
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
aCampos := PLMONREG(oXml,cRegistroPath)

for nI:=1 to len(aCampos)
	cField		:= aCampos[nI,1]
	cConteudo	:= aCampos[nI,2]

	if at(cField,cCabecalho)==0
		cCabecalho += iIf(empty(cCabecalho),cField,";" + cField)
	endIf
	cLinha += iIf(empty(cLinha),cConteudo,";" + cConteudo)
next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Registro
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
aAux := oXml:xPathGetChildArray(cAliasPath)
nPos := aScan(aAux,{|x| lower(x[1]) == 'registro'})

for nI:=(nPos+1) to len(aAux)
	if lCorpo
		PLPROCSV(oXml,aAux[nI,1],aAux[nI,2],,cLinha,aLinha,lCorpo)
	else
		PLPROCSV(oXml,aAux[nI,1],aAux[nI,2],@cCabecalho,,,lCorpo)
	endIf
next

if !(nPos<len(aAux))
	aadd(aLinha,cLinha)
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rorina
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return

/*/{Protheus.doc} PLSACXML
Grava Alteracoes no xml

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
function PLSACXML(oXml)

if oXml:save2File(cArqXML)
	if fErase(cDirXML) == -1
		PLSLOGS(STR0145,.t.,.t.,.t.,.t.)//"NЦo foi possМvel deletar XML"
	else
		if !__copyfile( cArqXML,PLSMUDSIS("\xmlsin")+substr(cDirXML,RAt("\",cDirXML)))
			PLSLOGS(STR0146,.t.,.t.,.t.,.t.)//"NЦo foi possМvel fazer a gravaГЦo do arquivo XML"
		else
			fErase(cArqXML)
			PLSLOGS(STR0164,.t.,.t.)//'XML, gravado com sucesso'
		endIf
	endIf
else
	PLSLOGS(STR0147,.t.,.t.,.t.,.t.)//'Erro ao gravar XML apСs processamento'
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da funcao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return

/*/{Protheus.doc} PLBUSSEQ
Busca o registro relacionado no obj xml

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
function PLBUSSEQ(cSeq,oList)
local lFound		:= .f.
local nI			:= 0
local nTotal		:= 0
local cRelac		:= ''
local cAlias		:= ''
local cAliasPath	:= ''
local cCorpo		:= "/ts:sincronizador/ts:corpo"
local cCabec		:= "/ts:sincronizador/ts:cabecalho"

local oXml 		:= tXmlManager():New()
local aRet		:= {"",oXml}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se os arquivos foram selecionados
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if empty(cSeq)
	msgAlert(STR0148)//'Informe uma SequЙncia a ser pesquisada'
	return aRet
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se os arquivos foram selecionados
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if empty(cDirXML)
	msgAlert(STR0149)//'Selecione o arquivo XML'
	return aRet
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё seta arquivo usado no servidor
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cArqXML := PLSMUDSIS("\xmlsin\"+subStr(cDirXML,rat('\',cDirXML)+1,len(cDirXML)))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁCopia para o diretorio de trabalho no servidor
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

if !__copyfile( cDirXML,PLSMUDSIS("\xmlsin")+substr(cDirXML,RAt("\",cDirXML)))
	msgAlert(STR0011)  //"NЦo foi possМvel copiar o arquivo XML para Аrea de trabalho no Servidor"
	return aRet
endIf


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Tratamento de erro
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
begin sequence
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁZera erros
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oXml:resetErrors()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁMonta Obj XML
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if oXml:parseFile(cArqXML)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁRegistra o namespace
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oXml:xPathRegisterNs('ts', "http://localhost" )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁDeleta arquivo da area de trabalho no servidor
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	if fErase(cArqXML) == -1
		PLSLOGFIL(STR0012,cArqGer) //"NЦo foi possМvel deletar o arquivo XML da Аrea de trabalho no Servidor"
	endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁVerificacao de possivel erro
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
else
	msgAlert(STR0150+oXml:error()+']')//'XML - Invalido ['
	return aRet
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁTratamento da Sequencia
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if oXml:xPathHasNode(cCabec) .and. oXml:xPathHasNode(cCorpo)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁLimpa resultado anterior
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	oList:Reset()
	oList:SetArray({''})

	cRelac	:= subStr(oXml:xPathGetNodeValue(cCabec+"/ts:relacionamento"),5)
	cAlias	:= subStr(cRelac,1,3)
	nTotal	:= oXml:XPathChildCount(cCorpo)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁProcura a sequencia no xml
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	for nI:=1 To nTotal
		cAliasPath	:= cCorpo+'/ts:'+cAlias+'['+cValToChar(nI)+']'
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ёverifica se o aliasPath existe
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if !oXml:XPathHasNode(cAliasPath)
			PLSLOGS(STR0151+cAliasPath+"]",.t.,.t.,.t.)//"Problema na leitura do XML ["
			return(aRet)
		endIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//ЁVerifica se a sequencia foi encontrada
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		if oXml:xPathGetNodeValue(cAliasPath+"/ts:sequencia") == cSeq

			PLSLOGS(STR0152+cSeq+STR0153,.t.,.t.) //'SequЙncia [' '] encontrada no XML'

			if oXml:xPathHasNode(cAliasPath+"/ts:obsOperador") .and. !empty(cObsOper := oXml:xPathGetNodeValue(cAliasPath+"/ts:obsOperador"))
				PLSLOGS( STR0154 + cObsOper + ']',.t.,.t.,,.t.) //'ObservaГЦo do Operador - ['
			endIf

			aRet 	:= {cAliasPath,oXml}
			lFound := .t.
			exit
		endIf
	next

	if !lFound
		PLSLOGS(STR0155+cSeq+STR0156 ,.t.,.t.)//'SequЙncia [''] nЦo encontrada no XML'
	endIf
else
	msgAlert(STR0157)//'XML invalido para localizaГЦo da Sequencia, utilize a opГЦo "validar"'
	return aRet
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Tratamento de erro
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
end sequence
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё ErroBlock
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
errorBlock(bBlockXml)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da funcao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return(aRet)

/*/{Protheus.doc} PLDESREG
Bloqueio e Observacao do registro

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
function PLDESREG(aRet, lChReg, cDesObs)
local cSeq		:= ''
local cAliasPath	:= aRet[1]
local oXml 		:= aRet[2]
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁVerifica se a sequencia foi informada
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if empty(cAliasPath)
	msgAlert(STR0158)//'Informe uma sequencia antes desta aГЦo'
	return
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁVerifica se a tag existe
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if lChReg .and. empty(cDesObs)
	msgAlert(STR0159)//'Informa o motivo pelo qual o registro nЦo serА processado'
	return
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁVerifica se a tag existe
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if oXml:xPathHasNode(cAliasPath+"/ts:status")
	oXml:xPathSetNode(cAliasPath+"/ts:status","status", iIf(lChReg,'3','0'))
endIf

if oXml:xPathHasNode(cAliasPath+"/ts:obsOperador")
	oXml:xPathSetNode(cAliasPath+"/ts:obsOperador","obsOperador", iIf(empty(cDesObs)," ",cDesObs))
endIf

if oXml:xPathHasNode(cAliasPath+"/ts:sequencia")
	cSeq := oXml:xPathGetNodeValue(cAliasPath+"/ts:sequencia")
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁLog
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
if lChReg
	PLSLOGS( '',.t.,.t.)
	PLSLOGS( STR0160 + cSeq + STR0161,.t.,.t.,.t.)//'SequЙncia  [' '] do registro, nЦo serА processado'
	PLSLOGS( STR0162 + cDesObs + ']',.t.,.t.,,.t.) //'ObservaГЦo ['
else
	PLSLOGS( '',.t.,.t.)
	PLSLOGS( STR0160 + cSeq + STR0163,.t.,.t.,.t.,.t.)  //'SequЙncia  [''] do registro, serА processado'
endIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim da funcao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
return

/*/{Protheus.doc} PLERROR
Exibe erros de validacao de XML

@author Alexander Santos
@since 05/08/2014
@version P11
/*/
static function PLERROR(cError)
local nI		:= 0
local 	aError := strToKarr(cError,chr(13)+chr(10))

for nI:=1 to len(aError)
	PLSLOGS(aError[nI],.t.,.t.)
next

return

/*/{Protheus.doc} PLATUCENTRAL
envia os dados dos beneficiАrios para a Central de ObrigaГУes
@author Roberto Barbosa
@since 14/08/2018
@version P12
/*/
Function PLATUCENTRAL(cAlias, nOpc,cTipoDB,nRecAlias,cMotDB,cDataDB, cChave)
	LOCAL lCentralObr := GetNewPar("MV_PLSEXCO",.F.)//Indica se o sistema utilizara a atualizacao automatica da central de obrigacoes sempre que um cadastro relevante for alterado no Protheus
	Local lUsaSIP     := "1" $ GetNewPar("MV_PLSTIPO","")
	Local lUsaSIB     := "2" $ GetNewPar("MV_PLSTIPO","")
	Local aDadCob     := {}
	Local aCritSib	  := {} //NЦo exibo as criticas na importaГЦo do XML
	Local cAliasAux   := ""
	Local cMotDBF	  := cMotDB
	Local nI          := 0	

	If lCentralObr .AND. (lUsaSIP .OR.  lUsaSIB)
		aAreaBA1 := BA1->(GetArea())
		aAreaBA3 := BA3->(GetArea())
		aAreaBTS := BTS->(GetArea())

		If nOpc == 3 //InclusЦo

			ASort(cChave, , , {|x,y|x > y})         

			For nI := 1 to Len(cChave)

				BA1->(DbSetorder(1))
				BA1->(MsSeek(xFilial("BA1")+SubStr(cChave[nI],2,18)))

				BTS->(DbSetOrder(1))
				BTS->(MsSeek(xFilial("BTS")+BA1->BA1_MATVID))

				BA3->(DbSetorder(1))
				BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))

				If PlSibEnvANS(BA3->BA3_TIPOUS,BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_CONEMP,BA3->BA3_VERCON,;
				BA3->BA3_SUBCON,BA3->BA3_VERSUB, BA1->BA1_INFANS)						

					oModel := Pl260DadNio('1',Nil,Nil,"",aDadCob,.F.,.F., , lUsaSIP )	

					oModel:SetValue( "B3KMASTER", 'B3K_OPESIB','2')

					oModel:commitData() 
					DelClassInf()			

				EndIf	
			next   	

		ElseIf (nOpc == 4) //AlteraГЦo

			If PlSibEnvANS(M->BA3_TIPOUS,M->BA3_CODINT,M->BA3_CODEMP,M->BA3_CONEMP,M->BA3_VERCON,;
			M->BA3_SUBCON,M->BA3_VERSUB, M->BA1_INFANS)						

				oModel := Pl260DadNio('1',Nil,Nil,"",aDadCob,.F.,.F., , lUsaSIP )	

				oModel:SetValue( "B3KMASTER", 'B3K_OPESIB','2')

				oModel:commitData() 
				DelClassInf()			

			EndIf	

		ElseIf (nOpc == 8) //Bloqueio / Desbloqueio

			cAliasAux := iIf(cAlias=='BA3','BC3',iIf(cAlias=='BA1','BCA','') )

			If cAliasAux ==  "BC3"
				BA3->(DbGoTo(nRecAlias))
				BA1->(DbSetOrder(2))
				BA1->(MsSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))					
			ElseIf cAliasAux ==  "BCA" 
				BA1->(DbGoTo(nRecAlias))
				BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))	
				cMotDB := PlMotBloANS("U",cMotDB)
				//A situaГУes onde o cСdigo de bloqueio enviado na BA1 И o cСdigo de bloqueio da familia
				//Neste caso, preciso verificar no nivel da Familia tambem para garantir		
				If (len(cMotDB) > 2 .or. Empty(cMotDB))
					cMotDB := PlMotBloANS("F",cMotDBF)					
				EndIf
			EndIf								

			If !cAliasAux == "BC3"
				If PlSibEnvANS(BA3->BA3_TIPOUS,BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_CONEMP,BA3->BA3_VERCON,;
				BA3->BA3_SUBCON,BA3->BA3_VERSUB, BA1->BA1_INFANS)			

					//0-Bloqueio e 1-Desbloqueio
					If cTipoDB == "0"			
						oModel := Pl260DadNio('1',Nil,Nil,"",aDadCob,.T.,.T., , lUsaSIP )		
						oModel:SetValue( "B3KMASTER", 'B3K_OPESIB','4')//Envio um bloqueio						
						oModel:SetValue( "B3KMASTER", 'B3K_MOTBLO',alltrim(cMotDB))//motivo de des/bloqueio -- Na central o campo tem tamanho 2
						oModel:SetValue( "B3KMASTER", 'B3K_DATBLO',StoD(cDataDB))//Data de ReativaГЦo										

					Else
						oModel := Pl260DadNio('1',Nil,Nil,"",aDadCob,.T.,.F., , lUsaSIP )
						oModel:SetValue( "B3KMASTER", 'B3K_OPESIB','5')//Envio um desbloqueio									
						oModel:SetValue( "B3KMASTER", 'B3K_MOTBLO',alltrim(cMotDB))//motivo de des/bloqueio -- Na central o campo tem tamanho 2
						oModel:SetValue( "B3KMASTER", 'B3K_DATREA' ,StoD(cDataDB))//Data de ReativaГЦo
					EndIf

					If FindFunction("PLGetHrCentral")
						oModel := PLGetHrCentral(oModel)
					EndIf

					oModel:commitData() 
					DelClassInf()		

				EndIf
			EndIf
		EndIf

		RestArea(aAreaBA3)
		RestArea(aAreaBA1)
		RestArea(aAreaBTS)
	EndIf

Return  
