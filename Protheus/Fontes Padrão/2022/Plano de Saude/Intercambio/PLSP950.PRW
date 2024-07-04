#INCLUDE "protheus.ch"
#include "FILEIO.CH

#DEFINE CRLF Chr(10) + Chr(13)
STATIC cCodInt := plsintpad()
//-----------------------------------------------
/*/{Protheus.doc} PLSP950 
Importação PTU A950
@author  Lucas Nonato 
@version P12 
@since   04/02/2020
/*/ 
function PLSP950()

local aPergs		:= {}
local n952			:= 0
local n953			:= 0
local lRet			:= .t.
local cRetTab		:= ""
private aPBox		:= {}
private aHM			:= {}
private aSADT		:= {}
private aBP1		:= {}
private oProcess

aAdd(/*01*/aPergs,{ 6,"Arquivo"			,space(200),"","","",85,.T.,"PTU A950 |*.xml*"})
aAdd(/*02*/aPergs,{ 2,"Criar TDE","1"	,{ "0=Não","1=Sim" },60,'.T.',.t. } )
aAdd(/*03*/aPergs,{ 1,"Tab Padrao "		,space(2),"@!",'.T.','B41PLS',"mv_par02=='1'",10,.f. } )
aAdd(/*04*/aPergs,{ 1,"TDE"				,space(7)	,"@!",'.T.','B68PLS',"mv_par02<>'1'",15,.f. } )
aAdd(/*05*/aPergs,{ 2,"Alt Porte HM"	,"0",	{ "0=Não","1=Sim" },60,'.T.',.t. } )
aAdd(/*06*/aPergs,{ 2,"Alt Porte SADT"	,"0",	{ "0=Não","1=Sim" },60,'.T.',.t. } )
aAdd(/*07*/aPergs,{ 1,"Redutor HM"		,0,"@E 999.99",'.T.','',".T.",15,.f. } )
aAdd(/*08*/aPergs,{ 1,"Redutor SADT"	,0,"@E 999.99",'.T.','',".T.",15,.f. } )
aAdd(/*09*/aPergs,{ 2,"De/Para TISS"	,"0",	{ "0=Não","1=Sim" },60,'.T.',.t. } )

if( paramBox( aPergs,"Importação Tabela Rol de Procedimentos Unimed PTU A950",aPBox,/*bOK*/,/*aButtons*/,.f.,/*nPosX*/,/*nPosY*/,/*oDlgWizard*/,/*cLoad*/'PLSP950',/*lCanSave*/.t.,/*lUserSave*/.t. ) )
	if validPerg() .and. PLSP950PORT(1) .and. PLSP950PORT(2)
		cIni := time()
		oProcess := MsNewProcess():New( { || PLSP950PRO(.f.,@n952,@n953,@lRet,@cRetTab) } , "Processando" , "Aguarde..." , .f. )
		oProcess:Activate()
		cFim := time()
		if lRet
			if aPBox[2] == "1"
				cRetTab := "Tabela(s) criada(s): " + cRetTab + CRLF
			endif
			aviso( "Resumo","Processamento finalizado. " + CRLF + ;
			cRetTab + ;
			"HM Processados: " 		+ cvaltochar(n952) + CRLF + ;
			"SADT Processados: " 	+ cvaltochar(n953) + CRLF + ;
			'Inicio: ' + cvaltochar( cIni ) + "  -  " + 'Fim: ' + cvaltochar( cFim ) ,{ "Ok" }, 2 )
		endif	
	else
		PLSP950()
	endif
endif

return 

//-----------------------------------------------
/*/{Protheus.doc} PLSP950PORT 
Tela de alteração de valores dos portes
@author  Lucas Nonato 
@version P12 
@since   04/02/2020
/*/ 
function PLSP950PORT(nTipo, lAuto)

local aPergs	:= {}
local aPBoxHM	:= {}
local aPBoxSADT	:= {}
local lRet		:= .t.
local nX		:= .t.

default lAuto 	:= .f.

if nTipo == 1 // HM
	aHM :={;
	{"1A",  15.92  , .f.},;
	{"1B",  31.84  , .f.},;
	{"1C",  47.77  , .f.},;
	{"2A",  63.70  , .f.},;
	{"2B",  83.97  , .f.},;
	{"2C",  99.37  , .f.},;
	{"3A",  135.78 , .t.},;
	{"3B",  173.50 , .f.},;
	{"3C",  198.73 , .t.},;
	{"4A",  236.52 , .f.},;
	{"4B",  258.92 , .f.},;
	{"4C",  292.50 , .t.},;
	{"5A",  314.89 , .f.},;
	{"5B",  340.09 , .f.},;
	{"5C",  361.07 , .f.},;
	{"6A",  393.27 , .f.},;
	{"6B",  432.47 , .t.},;
	{"6C",  473.04 , .f.},;
	{"7A",  510.83 , .f.},;
	{"7B",  565.41 , .f.},;
	{"7C",  668.97 , .t.},;
	{"8A",  722.16 , .f.},;
	{"8B",  757.15 , .f.},;
	{"8C",  803.33 , .f.},;
	{"9A",  853.72 , .f.},;
	{"9B",  933.50 , .t.},;
	{"9C",  1028.64, .f.},;
	{"10A", 1104.23, .f.},;
	{"10B", 1196.60, .f.},;
	{"10C", 1328.15, .t.},;
	{"11A", 1405.13, .f.},;
	{"11B", 1540.89, .f.},;
	{"11C", 1690.65, .f.},;
	{"12A", 1752.22, .t.},;
	{"12B", 1883.78, .f.},;
	{"12C", 2307.82, .f.},;
	{"13A", 2540.15, .f.},;
	{"13B", 2786.47, .f.},;
	{"13C", 3081.77, .f.},;
	{"14A", 3434.45, .f.},;
	{"14B", 3736.76, .f.},;
	{"14C", 4121.62, .f.}}

	if aPBox[5] == "1" .and. !lAuto
		aAdd(aPergs,{9,"Atualize ou confirme os valores de Porte conforme ",150,7,.T.})
		aAdd(aPergs,{9,"Rol de Procedimentos UNIMED para HM",150,7,.T.})

		for nX := 1 to len(aHM)
			aAdd(aPergs,{1,aHM[nX][1], aHM[nX][2] ,"@E 9,999.99",".T.","","",20,.F.})
		next	

		if( paramBox( aPergs,"Valores de Porte HM",aPBoxHM,/*bOK*/,/*aButtons*/,.f.,/*nPosX*/,/*nPosY*/,/*oDlgWizard*/,/*cLoad*/'PLSP950A',/*lCanSave*/.t.,/*lUserSave*/.t. ) )
			lRet := .t.
			for nX := 1 to len(aSADT)
				aHM[nX][2] := aPBoxHM[nX+2]
			next
		else
			lRet := .f.	
		endif
	endif
	
elseif nTipo == 2 //SADT
	aSADT := {;
		{"1A", 8.00   , .f.},;
		{"1B", 16.00  , .f.},;
		{"1C", 24.00  , .f.},;
		{"2A", 32.00  , .f.},;
		{"2B", 42.00  , .f.},;
		{"2C", 50.00  , .f.},;
		{"3A", 69.00  , .t.},;
		{"3B", 88.00  , .f.},;
		{"3C", 100.00 , .t.},;
		{"4A", 120.00 , .f.},;
		{"4B", 132.00 , .f.},;
		{"4C", 148.00 , .t.},;
		{"5A", 160.00 , .f.},;
		{"5B", 172.00 , .f.},;
		{"5C", 184.00 , .f.},;
		{"6A", 200.00 , .f.},;
		{"6B", 220.00 , .t.},;
		{"6C", 240.00 , .f.},;
		{"7A", 260.00 , .f.},;
		{"7B", 280.00 , .f.},;
		{"7C", 340.00 , .t.},;
		{"8A", 368.00 , .f.},;
		{"8B", 384.00 , .f.},;
		{"8C", 408.00 , .f.},;
		{"9A", 436.00 , .f.},;
		{"9B", 476.00 , .t.},;
		{"9C", 524.00 , .f.},;
		{"10A",560.00 , .f.},;
		{"10B",608.00 , .f.},;
		{"10C",676.00 , .t.},;
		{"11A",716.00 , .f.},;
		{"11B",784.00 , .f.},;
		{"11C",860.00 , .f.},;
		{"12A",892.00 , .t.},;
		{"12B",960.00 , .f.},;
		{"12C",1176.00, .f.},;
		{"13A",1292.00, .f.},;
		{"13B",1420.00, .f.},;
		{"13C",1570.00, .f.},;
		{"14A",1750.00, .f.},;
		{"14B",1900.00, .f.},;
		{"14C",2100.00, .f.}}
	
	if aPBox[6] == "1" .and. !lAuto
		aAdd(aPergs,{9,"Atualize ou confirme os valores de Porte conforme ",150,7,.T.})
		aAdd(aPergs,{9,"Rol de Procedimentos UNIMED para SADT",150,7,.T.})
		for nX := 1 to len(aSADT)
			aAdd(aPergs,{1,aSADT[nX][1], aSADT[nX][2] ,"@E 9,999.99",".T.","","",20,.F.})
		next

		if( paramBox( aPergs,"Valores de Porte SADT",aPBoxSADT,/*bOK*/,/*aButtons*/,.f.,/*nPosX*/,/*nPosY*/,/*oDlgWizard*/,/*cLoad*/'PLSP950B',/*lCanSave*/.t.,/*lUserSave*/.t. ) )
			lRet := .t.
			for nX := 1 to len(aSADT)
				aSADT[nX][2] := aPBoxSADT[nX+2]
			next
		else
			lRet := .f.	
		endif
	endif
endif

return lRet

//-----------------------------------------------
/*/{Protheus.doc} validPerg 
Valida perguntas
@author  Lucas Nonato 
@version P12 
@since   27/01/2020
/*/ 
static function validPerg
local lRet as logical

BF8->(dbSetOrder(1))
BR4->(dbSetOrder(1))
BP1->(dbsetorder(1)) 

if aPBox[2] == "1"
	if !empty(aPBox[3]) .and. BR4->(msSeek(xfilial("BR4")+aPBox[3]))
		lRet := .t.
	else
		lRet := .f.
		MsgAlert("Para criar uma nova TDE é necessário informar um código da Tabela Padrão válido!")
	endif

	if lRet 
		lRet := pergBP1()
	endif
else
	if !empty(aPBox[4]) 
		lRet := .t.
		aPBox[3]	:= getBF8(aPBox[4])
		if empty(aPBox[3])		
			lRet := .f.
			MsgAlert("TDE informada não possui código de tabela padrão vinculado!")
		endif
	else
		lRet := .f.
		MsgAlert("Para atualizar uma TDE é necessário informar o código da TDE existe!")
	endif

	if lRet .and. !BP1->(msSeek(xfilial("BP1")+aPBox[4]))
		MsgAlert("A TDE informada não possui cadastro de percentual de auxiliares!")
		lRet := .f.
	endif
endif

return lRet

//-----------------------------------------------
/*/{Protheus.doc} getBF8 
Retorna CODPAD da BF8.
@author  Lucas Nonato 
@version P12 
@since   27/01/2020
/*/ 
static function getBF8(cCodigo)
local cRet as char

if BF8->(msSeek(xfilial("BF8")+cCodigo))
	cRet := BF8->BF8_CODPAD
else
	cRet := ""
endif

return cRet

//-----------------------------------------------
/*/{Protheus.doc} PLSP950PRO 
Processamento do arquivo PTU A950
@author  Lucas Nonato 
@version P12 
@since   04/02/2020
/*/ 
function PLSP950PRO(lAuto,n952,n953,lRet,cRetTab)
local oXml 			as object
local cArq			:= alltrim(aPBox[1])
local cCodPad		:= aPBox[3]
local dDtInicio		:= date()
local cCodPro 		as char
local cDescPro 		as char
local cClassific	as char
local cAutori		as char
local cCodTab		as char
local cArqTmp		as char
local cCdPadTISS	as char
local cCdProTISS	as char
local cPath			:= getNewPar( "MV_TISSDIR","\TISS\" ) + "TEMP\"
local nProcs		as numeric
local nJ			as numeric
local nVlrUCO 		as numeric
local nVlrTX 		as numeric	
local nVlrHM 		as numeric	
local nVlrPPM 		as numeric
local nVlrPAne 		as numeric
local nQtdAux 		as numeric
local nVlrFilme		as numeric
local lOK			as logical
Local nI := 0
Local aNS := {}

default lAuto 	:= .f.
default n952 	:= 0
default n953 	:= 0
default lRet  	:= .f.
default cRetTab	:= ""

BF8->(dbSetOrder(1))
BA8->(dbSetOrder(1))
BD4->(dbSetOrder(1))                                                                                    
BR7->(dbSetOrder(1))
BR8->(dbSetOrder(1))
BW4->(dbsetorder(1)) 
BP1->(dbsetorder(1)) 
BTU->(dbsetorder(3)) 

oXml := TXmlManager():New()
lOK := oXml:parseFile(cArq)

if !lOk .and. file(cArq)
	if( CpyT2S( cArq,cPath,.F.,.F. ) )
		cArqTmp := cPath + substr( cArq,rat( "\",cArq ) + 1 ) //Extrai o nome apenas
		lOK := oXml:parseFile(cArqTmp)
	endif
endif

if lOK

	aNS := oXML:XPathGetRootNsList() 

	for nI := 1 to len(aNS)  
		oXML:XPathRegisterNs( 'ns',aNS[nI][2] )
		cNS := 'ns'//aNS[nI][1]
	next nI

//	oXML:XPathRegisterNs( "ns", "http://ptu.unimed.com.br/schemas/batch_V1_01_50" )
	
	dDtInicio 	:= stod(strtran(oXML:XPathGetNodeValue( "/ns:mensagemPTUBatch/ns:corpoMensagem/ns:A950/ns:dtVigTabela" ),"-",""))

	cTagHM := "/ns:mensagemPTUBatch/ns:corpoMensagem/ns:A950/ns:hm"
	
	if( oXml:XPathHasNode( cTagHM ) ) .or. ( oXml:XPathHasNode( cTagHM+"[1]" ) )
		if aPBox[2] == "1"				
			cCodTab 	:= gravaBF8("ROL DE PROCEDIMENTOS UNIMED - HONORARIOS", cCodPad, "22", "0") 
			gravaComp(cCodTab,"1",dDtInicio)
			cRetTab += iif(!empty(cRetTab),", " + cCodTab,cCodTab)
		else
			cCodTab := substr(aPBox[4],5,3)
			attPortes(cCodTab,"1",dDtInicio)			
		endif

		oHashHM		:= getBW4(cCodTab,"1",dDtInicio)
		nProcs 		:= oXML:XPathChildCount("/ns:mensagemPTUBatch/ns:corpoMensagem/ns:A950")

		if !lAuto
			oProcess:SetRegua1(1)
			oProcess:IncRegua1("Processando arquivo")
			oProcess:SetRegua2(-1)
		endif

		for nJ := 1 to nProcs 		   
		    if nProcs > 1
		        cTagHM2 := cTagHM + "["+ allTrim( str( nJ ) ) +"]"
		    endif		
			
			if !lAuto
				oProcess:IncRegua2(cvaltochar(nJ) +" de "+ cvaltochar(nProcs-4))
			endif

			cCodPro 	:= oXML:XPathGetNodeValue( cTagHM2 + "/ns:honorarioMedico/ns:codigoRol" )
			cDescPro 	:= oXML:XPathGetNodeValue( cTagHM2 + "/ns:honorarioMedico/ns:descricaoRol" )
			nVlrUCO 	:= val(strtran(oXML:XPathGetNodeValue( cTagHM2 + "/ns:honorarioMedico/ns:unidadeCustoOperacional" ),",","."))
			nVlrPPM 	:= val(strtran(oXML:XPathGetNodeValue( cTagHM2 + "/ns:porte" ),",","."))
			nVlrPAne 	:= val(strtran(oXML:XPathGetNodeValue( cTagHM2 + "/ns:porteAnestesico/ns:porteAnestesicoRol" ),",","."))
			nQtdAux 	:= val(strtran(oXML:XPathGetNodeValue( cTagHM2 + "/ns:auxiliares/ns:numeroAuxiliaresRol" ),",","."))
			nVlrFilme 	:= val(strtran(oXML:XPathGetNodeValue( cTagHM2 + "/ns:valorFilme/ns:valorFilmeRol" ),",","."))
			cClassific	:= oXML:XPathGetNodeValue( cTagHM2 + "/ns:classificacao/ns:classificacao" )
			cAutori		:= oXML:XPathGetNodeValue( cTagHM2 + "/ns:gruposPlanilha" )
			cCdPadTISS	:= oXML:XPathGetNodeValue( cTagHM2 + "/ns:honorarioMedico/ns:tiss/ns:tissTipoTabela" )
			cCdProTISS	:= oXML:XPathGetNodeValue( cTagHM2 + "/ns:honorarioMedico/ns:tiss/ns:tissCodigo" )
			nVlrTX 		:= 0
			nVlrHM 		:= 0
			if empty(cCodPro)
				nJ := nProcs
				exit
			endif
			gravaProc(cCodTab,cCodPad,cCodPro,cDescPro,nVlrPPM,nVlrPAne,nVlrUCO,nVlrFilme,nQtdAux,nVlrTX,nVlrHM,dDtInicio,cClassific,cAutori,oHashHM,cCdPadTISS,cCdProTISS,"1")
			n952++ 
		next
	endif

	cTagSADT := "/ns:mensagemPTUBatch/ns:corpoMensagem/ns:A950/ns:sadt"

	if( oXml:XPathHasNode( cTagSADT ) ) .or. ( oXml:XPathHasNode( cTagSADT+"[1]" ) )
		if aPBox[2] == "1"				
			cCodTab 	:= gravaBF8("ROL DE PROCEDIMENTOS UNIMED - SADT", cCodPad, "22", "0") 
			gravaComp(cCodTab,"2",dDtInicio)
			cRetTab += iif(!empty(cRetTab),", " + cCodTab,cCodTab)
		else
			cCodTab := substr(aPBox[4],5,3)
			attPortes(cCodTab,"2",dDtInicio)
		endif

		oHashSADT		:= getBW4(cCodTab,"2",dDtInicio)
		nProcs 			:= oXML:XPathChildCount("/ns:mensagemPTUBatch/ns:corpoMensagem/ns:A950")
		
		if !lAuto
			oProcess:SetRegua1(1)
			oProcess:IncRegua1("Processando arquivo")
			oProcess:SetRegua2(-1)
		endif

		for nJ := 1 to nProcs 		   
		    if nProcs > 1
		        cTagSADT2 := cTagSADT + "["+ allTrim( str( nJ ) ) +"]"
		    endif

			if !lAuto
				oProcess:IncRegua2(cvaltochar(nJ) +" de "+ cvaltochar(nProcs-4))
			endif
			
			cCodPro 	:= oXML:XPathGetNodeValue( cTagSADT2 + "/ns:sadt/ns:codigoRol" )
			cDescPro 	:= oXML:XPathGetNodeValue( cTagSADT2 + "/ns:sadt/ns:descricaoRol" )
			nVlrUCO 	:= val(strtran(oXML:XPathGetNodeValue( cTagSADT2 + "/ns:sadt/ns:unidadeCustoOperacional" ),",","."))
			nVlrHM 		:= val(strtran(oXML:XPathGetNodeValue( cTagSADT2 + "/ns:sadt/ns:valorHonorarioMedico" ),",","."))
			nVlrTX 		:= val(strtran(oXML:XPathGetNodeValue( cTagSADT2 + "/ns:sadt/ns:vl_taxa_video" ),",","."))
			nVlrPPM 	:= 0
			nVlrPAne 	:= val(strtran(oXML:XPathGetNodeValue( cTagSADT2 + "/ns:porteAnestesico/ns:porteAnestesicoRol" ),",","."))
			nQtdAux 	:= val(strtran(oXML:XPathGetNodeValue( cTagSADT2 + "/ns:auxiliares/ns:numeroAuxiliaresRol" ),",","."))
			nVlrFilme 	:= val(strtran(oXML:XPathGetNodeValue( cTagSADT2 + "/ns:valorFilme/ns:valorFilmeRol" ),",","."))
			cClassific	:= oXML:XPathGetNodeValue( cTagSADT2 + "/ns:classificacao/ns:classificacao" )
			cAutori		:= oXML:XPathGetNodeValue( cTagSADT2 + "/ns:gruposPlanilha" )
			cCdPadTISS	:= oXML:XPathGetNodeValue( cTagSADT2 + "/ns:sadt/ns:tiss/ns:tissTipoTabela" )
			cCdProTISS	:= oXML:XPathGetNodeValue( cTagSADT2 + "/ns:sadt/ns:tiss/ns:tissCodigo" )
			if empty(cCodPro)
				nJ := nProcs
				exit
			endif
			gravaProc(cCodTab,cCodPad,cCodPro,cDescPro,nVlrPPM,nVlrPAne,nVlrUCO,nVlrFilme,nQtdAux,nVlrTX,nVlrHM,dDtInicio,cClassific,cAutori,oHashSADT,cCdPadTISS,cCdProTISS,"2")
			n953++
		next
	endif
elseif !lAuto
	msgAlert("Falha na abertura do arquivo: fError[" +cvaltochar(ferror())+"]")
	lRet	:=.f.
endif

if !empty(cArqTmp)
	fErase( cArqTmp )
endif

return lRet

//-----------------------------------------------
/*/{Protheus.doc} gravaBF8 
Grava BF8
@author  Lucas Nonato 
@version P12 
@since   04/02/2020
/*/ 
static function gravaBF8(cDesc, cCodPad, cTabTISS, cTpProc)
local cCodigo as array

cCodigo := PLBF8VLC(cCodInt)
BF8->(RecLock("BF8",.T.))
BF8->BF8_FILIAL := xFilial("BF8")
BF8->BF8_CODINT := cCodInt
BF8->BF8_CODIGO := cCodigo
BF8->BF8_DESCM 	:= cDesc
BF8->BF8_CODPAD := cCodPad
BF8->BF8_ESPTPD := "1"
BF8->BF8_TPPROC := cTpProc
BF8->BF8_TABTIS := cTabTISS 
BF8->(MsUnLock())

return BF8->BF8_CODIGO

//-----------------------------------------------
/*/{Protheus.doc} attPortes 
Fecha a vigencia do Porte Médico e Porte Anestésico e cria uma nova.
@author  Lucas Nonato 
@version P12 
@since   04/02/2020
/*/ 
static function attPortes(cCodTab,cTipo,dDtInicio)
local cSql 		as char
local aBW4 		:= {}
local aBKF 		:= {}
local cDtFimVig := dtos(daySub(dDtInicio,1))

cSql := " UPDATE " + RetSqlName("BW4") 
cSql += " SET BW4_VIGFIN = '" + cDtFimVig + "' "
cSql += " WHERE R_E_C_N_O_ IN ( "
cSql += " SELECT R_E_C_N_O_ Recno FROM " + RetSqlName("BW4") + " BW4 "
cSql += " WHERE BW4_FILIAL = '" + xFilial("BW4") + "' "
cSql += " AND BW4_CODOPE = '" + cCodInt + "' "
cSql += " AND BW4_CODTAB = '" + cCodTab + "' "
cSql += " AND (BW4_VIGFIN > '" + cDtFimVig + "' OR BW4_VIGFIN = '        ') "
cSql += " AND BW4_VIGINI <> '" + dtos(dDtInicio) + "' "
cSql += " AND BW4.D_E_L_E_T_ = ' ' )  "
PLSCOMMIT(cSql)

cSql := " UPDATE " + RetSqlName("BKF") 
cSql += " SET BKF_VIGFIN = '" + cDtFimVig + "' "
cSql += " WHERE R_E_C_N_O_ IN ( "
cSql += " SELECT R_E_C_N_O_ Recno FROM " + RetSqlName("BKF") + " BKF "
cSql += " WHERE BKF_FILIAL = '" + xFilial("BKF") + "' "
cSql += " AND BKF_CODINT = '" + cCodInt + "' "
cSql += " AND BKF_CODTAB = '" + cCodTab + "' "
cSql += " AND (BKF_VIGFIN > '" + cDtFimVig + "' OR BKF_VIGFIN = '        ') "
cSql += " AND BKF_VIGINI <> '" + dtos(dDtInicio) + "' "
cSql += " AND BKF.D_E_L_E_T_ = ' ' ) "
PLSCOMMIT(cSql)	

cSql := " SELECT BW4_PORTE, R_E_C_N_O_ Recno FROM " + RetSqlName("BW4") + " BW4 "
cSql += " WHERE BW4_FILIAL = '" + xFilial("BW4") + "' "
cSql += " AND BW4_CODOPE = '" + cCodInt + "' "
cSql += " AND BW4_CODTAB = '" + cCodTab + "' "
cSql += " AND BW4_VIGINI = '" + dtos(dDtInicio) + "' "
cSql += " AND BW4.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBW4",.F.,.T.)
	
while !TRBBW4->(eof())
	aadd(aBW4,{alltrim(TRBBW4->BW4_PORTE), TRBBW4->Recno })
	TRBBW4->(dbSkip())
enddo
TRBBW4->(dbCloseArea())

cSql := " SELECT BKF_SEQPOR, R_E_C_N_O_ Recno FROM " + RetSqlName("BKF") + " BKF "
cSql += " WHERE BKF_FILIAL = '" + xFilial("BKF") + "' "
cSql += " AND BKF_CODINT = '" + cCodInt + "' "
cSql += " AND BKF_CODTAB = '" + cCodTab + "' "
cSql += " AND BKF_VIGINI = '" + dtos(dDtInicio) + "' "
cSql += " AND BKF.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBKF",.F.,.T.)

while !TRBBKF->(eof())
	aadd(aBKF,{TRBBKF->BKF_SEQPOR, TRBBKF->Recno })
	TRBBKF->(dbSkip())
enddo
TRBBKF->(dbCloseArea())

gravaComp(cCodTab,cTipo,dDtInicio,aBKF,aBW4) 

return
//-----------------------------------------------
/*/{Protheus.doc} gravaComp 
Grava complementos das participações(Porte, Anestesista, Auxiliares)
@author  Lucas Nonato 
@version P12 
@since   04/02/2020
/*/ 
static function gravaComp(cCodTab,cTipo,dDtInicio,aBKF,aBW4)
local nX	 	as numeric
local nPos	 	as numeric
local nSeqPor 	as numeric
local nQtd	 	as numeric
local nRedutor	as numeric
local aValor 	:= {}
default aBW4	:= {}
default aBKF	:= {}

if cTipo == "1" //HM
	aValor := aclone(aHM)
else //SADT
	aValor := aclone(aSADT)
endif
nQtd := 0

if cTipo == "1"
	nRedutor := aPBox[7] 
else
	nRedutor := aPBox[8]
endif

//BW4 e BKF não possuem X2_UNICO mas mesmo assim é necessário controlar a vigencia na função attPortes
if len(aBW4) > 0
	for nX:=1 to len(aValor)
		nPos := aScan(aBW4,{|x| x[1] == aValor[nX][1]})
		if nPos > 0
			BW4->(dbGoTo(aBW4[nPos][2]))
			BW4->(RecLock("BW4",.f.))		
			BW4->BW4_VLRREA	:= round(aValor[nX][2] - (aValor[nX][2] * nRedutor) / 100, 2)
			BW4->(MsUnLock())
		endif
	next		
endif

//A BKF não possui um vinculo lógico com nada, então tenho que verificar na terceira posição do array aValor fazendo um de-para na mão
if len(aBKF) > 0 
	nSeqPor := 0
	for nX:=1 to len(aValor)
		if aValor[nX][3]
			nSeqPor++
			nPos := aScan(aBKF,{|x| x[1] == nSeqPor})
			if nPos > 0
				BKF->(dbGoTo(aBKF[nPos][2]))
				BKF->(RecLock("BKF",.f.))	
				BKF->BKF_VLRREA	:= round(aValor[nX][2] - (aValor[nX][2] * nRedutor) / 100, 2)
				BKF->(MsUnLock())
			endif
		endif
	next		
endif

if len(aBKF) == 0 .and. len(aBKF) == 0  
	for nX:=1 to len(aValor)
		BW4->(RecLock("BW4",.t.))
		BW4->BW4_FILIAL := xFilial("BW4")
		BW4->BW4_CODOPE := cCodInt
		BW4->BW4_CODTAB := cCodTab
		BW4->BW4_PORTE 	:= aValor[nX][1]
		BW4->BW4_VLRREA	:= round(aValor[nX][2] - (aValor[nX][2] * nRedutor) / 100, 2)
		BW4->BW4_VIGINI	:= dDtInicio
		BW4->(MsUnLock())

		if aValor[nX][3]
			nQtd++
			BKF->(RecLock("BKF",.t.))
			BKF->BKF_FILIAL := xFilial("BKF")
			BKF->BKF_CODINT := cCodInt
			BKF->BKF_CODTAB := cCodTab
			BKF->BKF_SEQPOR	:= nQtd
			BKF->BKF_VLRREA	:= round(aValor[nX][2] - (aValor[nX][2] * nRedutor) / 100, 2)
			BKF->BKF_VIGINI	:= dDtInicio
			BKF->(MsUnLock())
		endif
	next
endif

if len(aBP1) > 0 .and. !BP1->(msSeek(xfilial("BP1")+cCodInt+cCodTab))
	for nX:= 1 to len(aBP1)
		if aBP1[nX] > 0
			BP1->(RecLock("BP1",.t.))
			BP1->BP1_FILIAL := xFilial("BKF")
			BP1->BP1_CODINT := cCodInt
			BP1->BP1_CODTAB := cCodTab
			BP1->BP1_NUMAUX	:= nX
			BP1->BP1_PERCAX	:= aBP1[nX]
			BP1->BP1_CODFUN	:= "AUX"
			BP1->(MsUnLock())
		endif
	next
endif

return

//-----------------------------------------------
/*/{Protheus.doc} gravaProc 
Grava procedimento
@author  Lucas Nonato 
@version P12 
@since   04/02/2020
/*/ 
static function gravaProc(cCodTab,cCodPad,cCodPro,cDescPro,nVlrPPM,nVlrPAne,nVlrUCO,nVlrFilme,nQtdAux,nVlrTX,nVlrHM,dDtInicio,cClassific,cAutori,oHash,cCdPadTISS,cCdProTISS,cTipRol)
local cAtivo 	:= "1"
local lAltera 	:= .t.

if !BA8->(MsSeek(xFilial("BA8")+cCodInt+cCodTab+cCodPad+cCodPro))
	BA8->(RecLock("BA8",.T.))
	BA8->BA8_FILIAL := xFilial("BA8")
	BA8->BA8_CDPADP := cCodPad
	BA8->BA8_CODPRO := cCodPro
	BA8->BA8_DESCRI := cDescPro
	BA8->BA8_NIVEL  := "3"
	BA8->BA8_ANASIN := "1"
	BA8->BA8_CODPAD := cCodPad
	BA8->BA8_CODTAB := cCodInt + cCodTab
	BA8->BA8_SITUAC	:= '1'
	BA8->BA8_ORIGEM	:= '1'

	BA8->(MsUnLock()) 	                 
endif

gravaBD4(dDtInicio,nVlrPPM,nVlrPAne,nVlrUCO,nVlrFilme,nQtdAux,nVlrTX,nVlrHM,oHash)

if !BR8->(msSeek(xFilial("BR8")+BA8->BA8_CDPADP+BA8->BA8_CODPRO))
	BR8->(RecLock("BR8",.T.))
    BR8->BR8_FILIAL := xFilial("BR8")
    BR8->BR8_AUTORI := iif(cAutori=="5","3","1")
    BR8->BR8_PROBLO := iif(cAutori=="5","1","0")
	BR8->BR8_BENUTL := cAtivo
    BR8->BR8_TPPROC := "0"
    BR8->BR8_AOINT 	:= "N"
    BR8->BR8_ACAO 	:= "3"
    BR8->BR8_RISCO 	:= iif(cClassific=="2","0","1")
    BR8->BR8_DTINT 	:= dtoc(date()) + " " + time()
	BR8->BR8_TIPROL := cTipRol

    BR7->(dbGoTop())
    while !BR7->(eof())
        cDado  := &("BA8->"+AllTrim(BR7->BR7_FLDTDE))
        cCampo := "BR8->"+AllTrim(BR7->BR7_FLDPSA)
    	&cCampo := cDado
    	BR7->(DbSkip())
    enddo
	
	BR8->(MsUnLock())
else
	BR8->(RecLock("BR8",.f.))
	BR8->BR8_PROBLO := iif(cAutori=="5","1","0")
	BR8->BR8_TIPROL := cTipRol
	BR8->(MsUnLock())
endif

if aPBox[9] == '1' .and. !empty(cCdProTISS)
	lAltera := !BTU->(msSeek(xFilial("BTU")+cCdPadTISS+'BR8'+cCdProTISS))
	BTU->(RecLock('BTU',lAltera))
	BTU->BTU_FILIAL := xFilial("BTU")
	BTU->BTU_CODTAB := cCdPadTISS
	BTU->BTU_VLRSIS := xFilial("BR8") + cCodPad + cCodPro
	BTU->BTU_VLRBUS := cCodPro
	BTU->BTU_CDTERM := cCdProTISS
	BTU->BTU_ALIAS  := 'BR8'
	BTU->( MsUnlock() )
endif

return

//-----------------------------------------------
/*/{Protheus.doc} gravaBD4 
Grava composição
@author  Lucas Nonato 
@version P12 
@since   04/02/2020
/*/ 
static function gravaBD4(dDtInicio,nVlrPPM,nVlrPAne,nVlrUCO,nVlrFilme,nQtdAux,nVlrTX,nVlrHM,oHash)
local cSql 		as char
local cUnidade 	as char
local cPPM 		as char
local nValor 	as numeric
local nX 		as numeric
local lOk  		:= .t.
local aRet  	as array
local lPPM		:= .f.

cSql := " SELECT R_E_C_N_O_ Recno FROM " + RetSqlName("BD4") + " BD4 "
cSql += " WHERE BD4_FILIAL = '" + xFilial("BD4") + "' "
cSql += " AND BD4_CODTAB = '" + BA8->BA8_CODTAB + "' "
cSql += " AND BD4_CDPADP = '" + BA8->BA8_CDPADP + "' "
cSql += " AND BD4_CODPRO = '" + BA8->BA8_CODPRO + "' "
cSql += " AND (BD4_VIGFIM > '" + dtos(daySub(dDtInicio,1)) + "' OR BD4_VIGFIM = '        ') "
cSql += " AND BD4.D_E_L_E_T_ = ' '  "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBD4",.F.,.T.)	

while TRBBD4->(!eof())
	BD4->(dbGoTo(TRBBD4->Recno))
	if BD4->BD4_VIGINI <> dDtInicio
		BD4->(Reclock("BD4",.F.))
		BD4->BD4_VIGFIM := daySub(dDtInicio,1)	
		BD4->(MsUnlock())			
	endif	
	TRBBD4->(dbSkip())
enddo
TRBBD4->(dbCloseArea())

if lOk
	for nX := 1 to 7
		cUnidade := ""
		nValor	 := 0
		cPPM	 := ""
		do case 
		case nX == 1
			if nVlrPPM > 0
				if HMGet( oHash , nVlrPPM, @aRet ) .or. HMGet( oHash , nVlrPPM - 0.01, @aRet ) .or. HMGet( oHash , nVlrPPM + 0.01, @aRet )
					cUnidade 	:= "PPM"
					nValor		:= 1
					cPPM		:= aRet[1][2]
					lPPM 		:= .t.
				else
					cUnidade 	:= "HMR"
					nValor		:= nVlrPPM
				endif
			endif
		case nX == 2
			if nVlrPAne > 0
				cUnidade 	:= "PAP"
				nValor		:= nVlrPAne
				lPPM 		:= .t.
			endif
		case nX == 3
			if nVlrUCO > 0
				if lPPM
					cUnidade 	:= "UCO"
					nValor		:= nVlrUCO
				else
					cUnidade 	:= "COR"
					nValor		:= nVlrUCO
				endif
			endif
		case nX == 4
			if nVlrFilme > 0
				cUnidade 	:= "FIL"
				nValor		:= nVlrFilme
			endif
		case nX == 5
			if nQtdAux > 0
				cUnidade 	:= "AUX"
				nValor		:= nQtdAux
			endif
		case nX == 6
			if nVlrTX > 0
				cUnidade 	:= "VTX"
				nValor		:= nVlrTX
			endif
		case nX == 7
			if nVlrHM > 0
				cUnidade 	:= "HMR"
				nValor		:= nVlrHM
			endif
		endcase

		if nValor > 0 .and. !BD4->(msSeek(xFilial("BD4")+BA8->BA8_CODTAB+BA8->BA8_CDPADP+BA8->BA8_CODPRO+cUnidade+dtos(dDtInicio)))		
			BD4->(Reclock("BD4",.T.))
			BD4->BD4_FILIAL := xFilial("BD4")
			BD4->BD4_CODPRO := BA8->BA8_CODPRO
			BD4->BD4_CODTAB := BA8->BA8_CODTAB
			BD4->BD4_CDPADP := BA8->BA8_CDPADP
			BD4->BD4_CODIGO := cUnidade
			BD4->BD4_VALREF := nValor
			BD4->BD4_VIGINI	:= iif(empty(dDtInicio),dDataBase,dDtInicio)
			BD4->BD4_PORMED	:= alltrim(cPPM)
			BD4->(MsUnlock())
		endif
	next
endif
return 

//-----------------------------------------------
/*/{Protheus.doc} getBW4
Grava BW4
@author  Lucas Nonato 
@version P12 
@since   04/02/2020
/*/ 
static function getBW4(cCodTab,cTipo,dDtInicio)
local cSql   	as char
local aDados 	as array
local nRedutor 	as numeric
local oHash

aDados := {}

if cTipo == "1"
	nRedutor := aPBox[7]
else
	nRedutor := aPBox[8]
endif

cSql := " SELECT BW4_PORTE, BW4_VLRREA " 
cSql += " FROM " + RetSqlName("BW4") + " BW4 "
cSql += " WHERE BW4_FILIAL = '" + xFilial("BW4") + "' "
cSql += " AND BW4_CODOPE = '" + cCodInt + "' "
cSql += " AND BW4_CODTAB = '" + cCodTab + "' "
cSql += " AND BW4_VIGINI >= '" + dtos(dDtInicio) + "' "
cSql += " AND BW4_VIGFIN <= '" + dtos(dDtInicio) + "' "
cSql += " AND BW4.D_E_L_E_T_ = ' '  "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPBW4",.F.,.T.)	

while TMPBW4->(!eof())
	//Na BW4 pode estar gravado o valor com o redutor e no XML será informado o valor original, então preciso por no objeto o valor original
	aadd(aDados, {round(TMPBW4->BW4_VLRREA / ( 1.00 -  (nRedutor / 100)) , 2) , TMPBW4->BW4_PORTE } )
	TMPBW4->(dbskip())
enddo
TMPBW4->(dbclosearea())

oHash := aToHM(aDados,1)
limpaArray(aDados)
return oHash

//-------------------------------------------------------------------
/*/{Protheus.doc} limpaArray
Limpa de maneira correta o array para evitar estouro de memória

@author  Lucas Nonato
@version P11
@since   04/11/16
/*/
static function limpaArray(aArray)

while Len(aArray) > 0
	aDel(aArray,len(aArray))
	aSize(aArray, len(aArray)-1)	
enddo

return

//-------------------------------------------------------------------
/*/{Protheus.doc} pergBP1
Parambox para informar dados dos auxiliares

@author  Lucas Nonato
@version P12
@since   03/03/2020
/*/
static function pergBP1()
local aPergs		:= {}

aAdd(/*01*/aPergs,{ 1,"1º Auxiliar"	,0,"@E 99%",'.T.','',".T.",15,.t. } )
aAdd(/*02*/aPergs,{ 1,"2º Auxiliar"	,0,"@E 99%",'.T.','',".T.",15,.f. } )
aAdd(/*03*/aPergs,{ 1,"3º Auxiliar"	,0,"@E 99%",'.T.','',".T.",15,.f. } )
aAdd(/*04*/aPergs,{ 1,"4º Auxiliar"	,0,"@E 99%",'.T.','',".T.",15,.f. } )

if( paramBox( aPergs,"Informe o percentual dos auxiliares.",aBP1,/*bOK*/,/*aButtons*/,.f.,/*nPosX*/,/*nPosY*/,/*oDlgWizard*/,/*cLoad*/'PLSP950C',/*lCanSave*/.t.,/*lUserSave*/.t. ) )
	lRet := .t.	
else
	lRet := .f.	
endif

return lRet
