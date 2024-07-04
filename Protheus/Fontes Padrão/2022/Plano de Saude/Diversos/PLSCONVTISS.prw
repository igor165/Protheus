#Include "protheus.ch"
#include "FILEIO.CH

#Define CRLF Chr(10) + Chr(13)
static cFiliBTP		:= ""
static cFiliBTQ		:= ""
static oHashPosic	:= nil
static oHashData	:= nil
static nTamBTQCmp	:= 0

//--------------------------------------- 
/*/{Protheus.doc} PLSCONVTIS 
Tela da importação
@author  Lucas Nonato 
@version P11 
@since   13/06/2016
/*/ 
//---------------------------------------
function PLSCONVTIS
local cDirOri 	:= space(100)
local cVerTiss	:= PLSTISSVER()
	
local aTags		:= {{'BTQ_DSCDET','Termo,Grupo,Descrição do grupo'},;
					{'BTQ_CDTERM','Código,Codigo,Código do Termo,Terminologia,Código da Tabela'},;					
					{'BTQ_VIGDE','Data de início de vigência','Data de inicio de vigencia'},;
					{'BTQ_VIGATE','Data de fim de vigência'},;
					{'BTQ_DATFIM','Data de fim de implantação','Data de fim de implantacao'},;
					{'BTQ_FABRIC','Fabricante'},;
					{'BTQ_REFFAB','Referência no fabricante'},;					
					{'BTQ_APRESE','Apresentação'},;
					{'BTQ_LABORA','Laboratório'},;
					{'BTQ_SIGLA' ,'Sigla'},;
					{'BTQ_CDTERM','TUSS,Código TUSS,Codigo TUSS'},;
					{'BTQ_CODGRU','Código do grupo'},;
					{'BTQ_DSCDET','Descrição Detalhada do Termo'},;
					{'BTQ_FENVIO','Forma de envio'}}

local aPergs	:= {}
local __aRet	:= {}
private cRet	:= ''
private oProcess

aadd(/*01*/ aPergs,{ 6,"Caminho CSV",cDirOri,"@!","","",90,.t.,,,GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_RETDIRECTORY })
aadd(/*02*/ aPergs,{ 1,"Versão TISS",cVerTiss,"@R 9.99.99",'.t.',,/*'.t.'*/,7,.t. } )
If !isBlind()
	if( paramBox( aPergs,"Parâmetros - Importação Terminologia TISS",__aRet,/*bOK*/,/*aButtons*/,.f.,/*nPosX*/,/*nPosY*/,/*oDlgWizard*/,/*cLoad*/'PLSCTISS',/*lCanSave*/.t.,/*lUserSave*/.t. ) )
		cIni := time()
		oProcess := MsNewProcess():New( { || ProcTiss(__aRet[1],__aRet[2],aTags) } , "Processando" , "Aguarde..." , .f. )
		oProcess:Activate()
		cFim := time()
		Aviso( "Resumo","Processamento finalizado. " + CRLF + 'Inicio: ' + cvaltochar( cIni ) + "  -  " + 'Fim: ' + cvaltochar( cFim ) ,{ "Ok" }, 2 )
	endif
endif


return 

//---------------------------------------
/*/{Protheus.doc} ProcTiss 
Processamento do csv e gravação nas tabelas da terminologia. 
@author  Lucas Nonato 
@version P11 
@since   13/06/2016
/*/
//---------------------------------------

static function ProcTiss(cDirOri,cVerTiss,aTags,lAtuAuto)
local aFiles 		:= ""
local nArq			:= 0
local aCabec		:= {}
local aItens 		:= {}
local nVazio 		:= 0 //Variavel para controle de linhas vazias, pois com a conversão de XLS para CSV, foram geradas mais de 1k de linhas vazias.
local cTab 			:= ""
local cDesc			:= ""
local cAntes		:= ""
local cAlt 			:= ""
local cDepois		:= ""
local cTabCab		:= SuperGetMv("MV_TISSCAB",.f.,"87")
local oFileRead 	As Object
local aLines 		:= {}
local nLoop 		:= 0
local cLine 		:= ""
local cItem			:= ""
local lMesmaLinha 	:= .f.
local lGrava		:= .T.
local cMsgErro		:= ""
local lExsBarra		:= valtype(oProcess) == "O"
local nTamLines		:= 0
local lBlindSys		:= isBlind()
local cNomLogErr	:= "plsconvtiss_tiss_" + strtran(left(time(), 2), ":","") + "_00.LOG"
local cCodErro		:= ""

default lAtuAuto := .F.

cFiliBTP	:= xFilial("BTP")
cFiliBTQ	:= xFilial("BTQ")
nTamBTQCmp	:= tamsx3("BTQ_CDTERM")[1]
oHashPosic	:= HMNew()
oHashData	:= HMNew()

BTQ->(DbSetOrder(2))
BTP->(DbSetOrder(1))

cDirOri	:= AllTrim(cDirOri)
aFiles	:= (Directory(plsmudsis(cDirOri + '\*.CSV')))

if Len(aFiles) == 0
	if lAtuAuto
		cMsgErro := 'Houve um erro com o Repositório de Arquivos, entre em contato com administrador do sistema.'
		MsgStop(cMsgErro)
		return cMsgErro
	else
		MsgStop('Nenhum arquivo .CSV encontrado em ' + cDirOri)
		return PLSCONVTIS()
	endif
endif

If !lBlindSys .and. lExsBarra
	oProcess:SetRegua1(Len(aFiles)) 
EndIf
For nArq := 1 To Len(aFiles)
	oFileRead := FWFileReader():New( cDirOri +'\'+ aFiles[nArq][1] )
	nVazio	:= 0
	cTab 	:= ""
	cDesc	:= ""
	aCabec	:= {}
	aItens	:= {}
	if oFileRead:Open()
		oFileRead:setBufferSize(20480) //20Kb
 		aLines 	:= oFileRead:GetAllLines()
		nLoop 	:= 1
		cTab	:= ""
		aCabec	:= {}
		nVazio	:= 1
		nTamLines := Len( aLines )
		If !lBlindSys .and. lExsBarra
			oProcess:IncRegua1("Processando Arquivos")
			oProcess:SetRegua2(nTamLines) //Alimenta a segunda barra de progresso
		EndIf
		while nLoop <= nTamLines .and. nVazio <= 15
			lGrava := .T. //Retorna valor default
			aItens := {} 
			If !lBlindSys .and. lExsBarra
				oProcess:IncRegua2("Lendo Tabela: " + cTab)
			EndIf
			cLine := aLines[ nLoop ]
			if Substr(cLine,1,1) == ';'	
				nVazio += 1	
			elseif empty(cTab) .and. 'ndice' $ AllTrim(cLine)  
				nVazio := 15				
			elseif 'Tabela' $ AllTrim(cLine) .and. empty(cTab)
				cTab := AllTrim(cvaltochar(val(Substr(cLine,8,3))))
				cTab := Iif(Len(cTab) == 1, '0' + cTab, cTab)	
			elseif Len(aCabec) == 0 
				if !empty(cTab)						
					aCabec := StrTokArr2(cLine,";",.t.) 
				endif				
			elseif !empty(cTab) .and. len(aCabec) <> 0				
				if len(StrTokArr2(cLine,";",.t.)) <> len(aCabec)
					lMesmaLinha	:= .t.				
					while lMesmaLinha
						cLine := aLines[ nLoop ]
						cItem += cLine
						nLoop++
						if (substr(aLines[ nLoop ],1,1) $ "0123456789" .and. substr(aLines[ nLoop ],8,1) $ "0123456789") .or. (nLoop == nTamLines)
							lMesmaLinha := .f.
							nLoop--
						endif
					enddo
					while '"' $ cItem   
						cAntes 	:= substr(cItem,1,at('"',cItem)-1)
						cItem 	:= substr(cItem,at('"',cItem)+1,len(cItem))
						cAlt 	:= strtran(substr(cItem,1,at('"',cItem)-1),";","")
						cDepois := substr(cItem,at('"',cItem)+1,len(cItem))
						cItem	:= FwNoAccent(WTDecode(cAntes + cAlt + cDepois, .f., .f.) )
					enddo
					aItens := StrTokArr2(cItem,";",.t.)
					cItem := ""
				else
					cAntes 	:= substr(cLine,1,at('"',cLine)-1)
					cLine 	:= substr(cLine,at('"',cLine)+1,len(cLine))
					cAlt 	:= strtran(substr(cLine,1,at('"',cLine)-1),";","")
					cDepois := substr(cLine,at('"',cLine)+1,len(cLine))
					cLine	:= FwNoAccent(WTDecode(cAntes + cAlt + cDepois, .f., .f.) )
					aItens 	:= StrTokArr2(cLine,";",.t.)
				endif
				
			endif

			//Validação para não incluir Terminologias 00 87 90 e 98
			lGrava := Iif(cTab=="00" .or. cTab=="87" .or. cTab=="90" .or. cTab=="98",.F.,.T.) 

			if len(aItens) > 0 .and. lGrava 
				if cTab == cTabCab
					gravaBTP(cTab,aCabec,aItens)
				endif
				gravaBTQ(cTab,aCabec,aItens)
			endif
			nLoop++				
	 	enddo nLoop
	
		oFileRead:Close()
		FWFreeVar( @oFileRead ) 		
	else
		cCodErro := cvaltochar(ferror())
		plslogfil("Arquivo: " + aFiles[nArq][1] + " - Erro: " + cCodErro + CRLF + iif(findfunction('dwcallstack'), ;
					dwcallstack(0,,.f.), PPilhaProc(0, '')) + CRLF + padr("*",50,"*") + CRLF, cNomLogErr)
		if !lBlindSys
			msginfo( "Nao foi possivel abrir o arquivo. " + CRLF + "Arquivo: " + aFiles[nArq][1] + " - Erro: " + cCodErro )
		endif	
	endif
Next
HMClean(oHashPosic)
HMClean(oHashData)
FreeObj(oHashPosic)
FreeObj(oHashData)
return

//---------------------------------------
/*/{Protheus.doc} getValue 
Retorna o valor a ser gravado de acordo com o cabeçalho
@author  Lucas Nonato 
@version P11 
@since   13/06/2016
/*/
//---------------------------------------

static function getValue(cTit, aCabec, aItens, cTab, lData)
local cRet 		:= ""
local nPos		:= 0
local aHashVld	:= {}
local aHashDta 	:= {}
local dDtaTemp	:= ""
default lData 	:= .f.

if HMGet( oHashPosic, cTab + cTit, @aHashVld ) .and. len(aHashVld) > 0
	nPos := aHashVld[1,2]
	cRet := iif(nPos == 0, "", aItens[nPos])

else

	nPos := aScan(aCabec,{|x| cTit $ x })
	if nPos > 0
		cRet :=  aItens[nPos]
	else
		nPos := aScan(aCabec,{|x| x $ cTit })
		if nPos > 0
			cRet :=  aItens[nPos]
		endif	
	endif
	
	HmAdd( oHashPosic, {cTab + cTit, nPos})
endif

if lData
	if HMGet( oHashData, cRet, @aHashDta ) .and. len(aHashDta) > 0
		cRet := aHashDta[1,2]
	else
		dDtaTemp := cRet
		cRet := cToD( transform(cRet, "@R 99/99/9999") )
		HmAdd( oHashData, {dDtaTemp, cRet})
	endif
endif

return cRet


//---------------------------------------
/*/{Protheus.doc} gravaBTP 
Grava tabela BTP
@author  Lucas Nonato 
@version P11 
@since   13/06/2016
/*/
//---------------------------------------
static function gravaBTP(cTab,aCabec,aItens)
local lInclui	:= .t.
local cDataIni	:= transform( getValue("Data de início de vigência, Data de inicio de vigencia", aCabec, aItens, cTab), "@R 99/99/9999" )

if BTP->(MsSeek(cFiliBTP+cTab+cDataIni))
	lInclui := .f.
else
	lInclui := .t.
endif

BTP->(RecLock("BTP", lInclui))
	BTP->BTP_FILIAL := cFiliBTP
	BTP->BTP_CODTAB := cTab
	BTP->BTP_DESCRI := getValue("Descrição,Desc,Descricao", aCabec, aItens, cTab)
	BTP->BTP_VIGDE  := ctod(cDataIni)
	BTP->BTP_VIGATE := getValue("Data de fim de vigência, Data de fim de vig", aCabec, aItens, cTab, .t.)
	BTP->BTP_DATFIM := getValue("Data de fim de implantação, Data de fim de implanta", aCabec, aItens, cTab, .t.)
	BTP->BTP_TIPVIN := '0'
BTP->(MsUnlock())

return

//---------------------------------------
/*/{Protheus.doc} gravaBTQ
Grava tabela BTQ
@author  Lucas Nonato 
@version P11 
@since   13/06/2016
/*/
//---------------------------------------
static function gravaBTQ(cTab,aCabec,aItens)
local lInclui	:= .t.
local cCode		:= getValue("TUSS,Código TUSS,Codigo TUSS", aCabec, aItens, cTab)

if empty(cCode)
	cCode := getValue("Código,Codigo,Código do Termo,Terminologia,Código da Tabela", aCabec, aItens, cTab )
endif

if BTQ->(MsSeek(cFiliBTQ+cTab+PadR(cCode, nTamBTQCmp)))
	lInclui := .f.
else
	lInclui := .t.
endif

BTQ->(RecLock("BTQ", lInclui))
	BTQ->BTQ_FILIAL := cFiliBTQ
	BTQ->BTQ_CODTAB := cTab
	BTQ->BTQ_CDTERM	:= cCode
	BTQ->BTQ_DESTER := getValue("Termo,Grupo,Descrição do grupo", aCabec, aItens, cTab)
	BTQ->BTQ_VIGDE 	:= getValue("Data de início de vigência, Data de inicio de vigencia", aCabec, aItens, cTab, .t.)
	BTQ->BTQ_VIGATE := getValue("Data de fim de vigência", aCabec, aItens, cTab, .t.)
	BTQ->BTQ_DATFIM := getValue("Data de fim de implantação Data de fim de implantacao", aCabec, aItens, cTab, .t.)
	BTQ->BTQ_FABRIC := getValue("Fabricante", aCabec, aItens, cTab)
	BTQ->BTQ_REFFAB := getValue("Referência no fabricante", aCabec, aItens, cTab)
	BTQ->BTQ_APRESE := getValue("Apresentação", aCabec, aItens, cTab)
	BTQ->BTQ_LABORA := getValue("Laboratório", aCabec, aItens, cTab)
	BTQ->BTQ_SIGLA  := getValue("Sigla", aCabec, aItens, cTab)
	BTQ->BTQ_CODGRU := getValue("Código do grupo", aCabec, aItens, cTab)
	BTQ->BTQ_DSCDET := getValue("Descrição Detalhada do Termo", aCabec, aItens, cTab)
	BTQ->BTQ_FENVIO := getValue("Forma de envio", aCabec, aItens, cTab)
	BTQ->BTQ_HASVIN := '0'
BTQ->(MsUnlock())

return

//---------------------------------------
/*/{Protheus.doc} PLSIMPTERM 
Chama function ProcTiss
@author Eduardo Bento
@version P11 
@since   07/01/2020
/*/
//---------------------------------------
Function PLSIMPTERM(cDirOri, cVerTiss)

Local cRet := ""

	cRet := ProcTiss(cDirOri, cVerTiss,,.T.)

Return cRet
