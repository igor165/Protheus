#include "fileIO.ch"
#include "protheus.ch"
#include "xmlxfun.ch"
#include "totvs.ch"
#include "FWMVCDEF.CH"
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

#define CRLF chr( 13 ) + chr( 10 )

#define GUIA_CONSULTA 	'01'
#define GUIA_SADT		'02'
#define GUIA_INTERNACAO	'05'
#define GUIA_HONORARIO 	'06'

static cCodInt 	:= ''
static lVersAtual := .T.
static cCodLDPO 	:= getNewPar("MV_PTUCONO","0004") 
static cCodLDPE 	:= getNewPar("MV_PTUCONE","0005") 
static lMV550NCC 	:= getNewPar("MV_PTUGNCC",.t.) 
static lPLSR556		:= existBlock("PLSR556")
static lPLSR506 	:= existBlock("PLSR506")
static lIdUnico2	:= .f.

static aCmpBE4 	:= {}
static aCmpBD5 	:= {}
static aCmpBD6	:= {}
static aCmpBD7	:= {}
static aCmpBX6	:= {}

static cDirTmp := PLSMUDSIS( "\plsptu\" )

//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

//-------------------------------------------------------------------
/*/{Protheus.doc} PTUA550IMP
Classe referente a engine de importação do PTU A550

@author    Lucas Nonato
@version   V12
@since     16/10/2020
/*/
class PTUA550IMP

data cOpeExe 	as String 	// Codigo unimed que enviou o arquivo
data cPath 	    as String 	// Caminho até o procedimento sem o contador
data cPathRaiz  as String 	// Caminho inicial
data cConsulta  as String 	// Peg de Consulta
data cHonor	    as String 	// Peg de Honorario
data cSADT 	    as String 	// Peg de SADT
data cGRI 	    as String 	// Peg de Resumo de Internação
data cPathQ 	as String 	// Caminho do questionamento sendo processado
data cPathP 	as String 	// Caminho do procedimento sendo processado
data cArquivo 	as String 	// Arquivo sendo importado
data nX    		as numeric 	// posição do questionamento
data nY    		as numeric 	// posição do evento
data nTotal  	as numeric 	// total de questionamentos
data nQuest 	as numeric 	// processados até agora
data nQtdX 		as numeric 	// controle do process
data aMsg	    as Array 	// mensagens de retorno
data lOrigem    as logical 	// origem ou executora?
data cSequen	as String 	// Sequencial usado para caso nY (numero de eventos) maior que 999

method New() CONSTRUCTOR
method hasNext() 
method hasNextProc() 
method getBD6() 
method clona()
method grava()
method addMsg() 
method recnoBD6() 
method LimpVar()

endclass

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSP550X
Importação do PTU A550 XML

@author    Lucas Nonato
@version   V12
@since     16/10/2020
/*/
function PLSP550X
local cGridFilter := ""
private oBrwBRJ := nil
aCmpBE4	:= P550FIELD("BE4",.t.)
aCmpBD5	:= P550FIELD("BD5",.t.)
aCmpBD6	:= P550FIELD("BD6",.t.)
aCmpBD7	:= P550FIELD("BD7",.t.)
aCmpBX6	:= P550FIELD("BX6",.t.)
cCodInt	:= plsintpad()

// abre a tela de filtro
cGridFilter := PLSP550FIL(.F.)
setKey(VK_F2 ,{|| cGridFilter := PLSP550FIL(.T.) })

oBrwBRJ := FWmBrowse():New()
oBrwBRJ:SetAlias( 'BRJ' )
oBrwBRJ:SetDescription( 'Importação PTU A550 Unimed Origem' )
oBrwBRJ:SetFilterDefault( cGridFilter )
oBrwBRJ:SetMenuDef( "PLSP550X" )
oBrwBRJ:addLegend("BRJ_ARQPAR == ' '","WHITE",	"Não contestado" )
oBrwBRJ:addLegend("BRJ_ARQPAR == '1'","BLUE",	"Parcial 1" )
oBrwBRJ:addLegend("BRJ_ARQPAR == '2'","BLACK",	"Parcial 2" )
oBrwBRJ:addLegend("BRJ_ARQPAR == '0'","GREEN",	"Encerrado" )

oBrwBRJ:Activate()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} P550FIELD
Campos desconsiderados no clone

@author    Lucas Nonato
@version   V12
@since     16/10/2020
/*/
function P550FIELD(cAlias,lOrigem)
Local aRet := {}
Local aCposPad := {}
Local nForCpo	:= 1

aCposPad := eval( { || dbSelectArea(cAlias), dbStruct() })

for nForCpo := 1 To Len(aCposPad)
	cCampo := aCposPad[nForCpo,1]
	
	if "_FILIAL" $ cCampo .or. "_CODOPE" $ cCampo .or. "_CODLDP" $ cCampo .or. "_CODPEG" $ cCampo .or. "_NUMERO" $ cCampo .or. "_VLTXPG" $ cCampo .or.;
	   "_INTFAT" $ cCampo .or. "_STAFAT" $ cCampo .or. "_NUMFAT" $ cCampo .or. "_OPEFAT" $ cCampo .or. "_SEQPF"  $ cCampo .or. "_VLRTPF" $ cCampo .or.;
	   "_LAPRO"  $ cCampo .or. "_DTLA"   $ cCampo .or. "_CHVLA"  $ cCampo .or. "_CHVPRO" $ cCampo .or. "_PERPF"  $ cCampo .or. "_LA"     $ cCampo .or.;
	   "_DTDIGI" $ cCampo .or. "_LOTMOF" $ cCampo .or. "_LOTMOP" $ cCampo .or. "_LOTMOE" $ cCampo .or. "_VLRPAG" $ cCampo .or. "_VLTXAP" $ cCampo .or.;
	   "_VLRPAG" $ cCampo .or. "_VLTXAP" $ cCampo .or. "_VLRBPR" $ cCampo .or. "_VLRAPR" $ cCampo .or. "_VLRMAN" $ cCampo .or. "_VLRGLO" $ cCampo .or.;
	   "_FASE"   $ cCampo .or. "_VALORI" $ cCampo .or. "_VLRGTX" $ cCampo .or. "_SEQUEN" $ cCampo .or. "_GUIORI" $ cCampo .or. "_CHKSE2" $ cCampo
		loop
	endif

	if !lOrigem
		if 	"_CPFRDA" $ cCampo .or.	"_TIPPRE" $ cCampo .or.	"_TIPRDA" $ cCampo .or.	"_LOCAL"  $ cCampo .or.	"_CODLOC" $ cCampo .or.;
			"_CODESP" $ cCampo .or.	"_DESLOC" $ cCampo .or.	"_ENDLOC" $ cCampo .or.	"_CODRDA" $ cCampo .or.	"_NOMRDA" $ cCampo 
			loop
		endif
	endif

	aadd(aRet, aCposPad[nForCpo,1])	
next
	
return aclone(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} menuDef
função para criar o menu da tela

@author    pablo alipio
@version   V12
@since     09/2020
/*/
static function menuDef()
private aRotina := {}

Add Option aRotina Title 'Importar Arquivo'				Action 'PLS550IMP(.f.,.t.)' Operation 3 Access 0 // Incluir
Add Option aRotina Title 'Visualizar'  					Action 'VIEWDEF.PLSP500X' 	Operation 2 Access 0 // Visualizar
Add Option aRotina Title 'Filtro(F2)'  					Action 'PLSP550FIL(.T.)' 	Operation 1 Access 0 // Filtro
Add Option aRotina Title 'Cancelar Ultima Contestação'	Action 'processa({||PLSP550EXC(.f.,.t.)},"Exclusao","Processando...",.T.)'		Operation 5 Access 0 // Excluir
Add Option aRotina Title 'Analisar'  					Action 'PLSP500ANA(2)' 		Operation 2 Access 0 // Analisar
Add Option aRotina Title 'Imprimir'   					Action 'VIEWDEF.PLSP500X' 	Operation 8 Access 0 // Imprimir
Add Option aRotina Title 'Dados Adicionais'   			Action 'PLSED500VS()' 		Operation 8 Access 0

return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS550IMP
Importação do PTU A550 XML

@author    Lucas Nonato
@version   V12
@since     16/10/2020
/*/
function PLS550IMP(lAuto,lOrigem)
local cError    := ""
local cWarning  := ""
local nI        as numeric
local cFileXML  as char
local cDirOri 	:= ""
local cPath		:= "\plsptu\temp\" // diretorio do servidor para arquivo temporario
local cFileLOG  := ""
local aFiles    := {}
local aMsg      := {}
local aRet 		:= {}
local lOk 		:= .f.
local lError 	:= .f.
local lCpy 		:= .f.

private oProcess   	:= nil

default lAuto		:= .f.
default lOrigem		:= .t.

lIdUnico2 := BX6->(fieldPos("BX6_IDUNI2")) > 0

if lOrigem
	BRJ->(dbsetorder(1))
else
	BTO->(dbsetorder(3))
	BAU->(dbsetorder(7))
endif
BCI->(dbsetorder(14))
BD5->(dbsetorder(1))
BE4->(dbsetorder(1))
BD6->(dbsetorder(1))
BX6->(dbsetorder(1))
BD7->(dbsetorder(1))
B2A->(dbsetorder(1)) 

if lAuto .or. empty(cCodInt)
	aCmpBE4	:= P550FIELD("BE4",lOrigem)
	aCmpBD5	:= P550FIELD("BD5",lOrigem)
	aCmpBD6	:= P550FIELD("BD6",lOrigem)
	aCmpBD7	:= P550FIELD("BD7",lOrigem)
	aCmpBX6	:= P550FIELD("BX6",lOrigem)
	cCodInt := plsintpad()
	if lAuto
		lOk		:= .t.
	endif
endif

aFiles 	:= P500GetArq(lAuto,iif(lOrigem,4,3))
lOk 	:= aFiles[1]
cDirOri	:= aFiles[3]
aFiles 	:= aFiles[2]

if lOk
	for nI := 1 To Len(aFiles)
		cError := ""
		lCpy := .f.
		If ( !empty(aFiles[nI][01]) ) .and. ( aFiles[nI][05] )
			cFileXML := cDirOri + aFiles[nI][1]

			if( At( ":\",cFileXML ) <> 0 )	//se for arquivo local, copia para o servidor
				lCpy := .t.
				// se a pasta /temp/ não existir, criamos ela
				if( !existDir( cPath ) )
					MakeDir( cPath )
				endif

				// copia o arquivo para o servidor
				if cpyT2S( cFileXML, cPath)					
					cFileXML := cPath + aFiles[nI][1]					
				else
					aadd(aMsg,{"",aFiles[nI][1], "", "Não foi possível copiar o arquivo para o servidor."})
					lError := .t.
				endif				
			endif

			//Verifica qual a versão do arquivo
				aArqTmp := fopen(cFileXML , FO_READ) //Abre o Arquivo
				
				//Se der erro para abrir o arquivo, Vou considerar a versão atual
				cPathXSD :=  iif( aArqTmp <= 0, "\plsptu\schemas\V2_0\ptu_A550.xsd", "")
							
				nTam := fseek(aArqTmp,0,2)
				fseek(aArqTmp,0)
				nBuff := max(5000,nTam) 
				cBuff := space(nBuff)
				nRead := fread(aArqTmp,@cBuff,nBuff) 
				fclose(aArqTmp)
				xChave := alltrim( cBuff )

				IF upper("nrVerTra_PTU>02</") $ UPPER(xChave) .OR. upper("nrVerTra_PTU>2</") $ UPPER(xChave)
					//versão antiga
					cPathXSD:="\plsptu\schemas\V1_1\ptu_A550.xsd"
				else
					cPathXSD:="\plsptu\schemas\V2_0\ptu_A550.xsd"
				ENDIF

			if !xmlFVldSch( cFileXML,cPathXSD,@cError,@cWarning )
				cFileLOG := geraLogErro( cError, aFiles[nI][1], cDirOri )
				aadd(aMsg,{"",aFiles[nI][1], "", "Falha na estrutura. Verifique o arquivo: " + cFileLOG})
				lError := .t.
			endif

			if !lError	
				if lAuto
					oProcess 	:= P270fProc():New()
					aRet := P550Proc(iif(lCpy,cPath,cDirOri),aFiles[nI][1], aMsg, lOrigem)
				else		
					oProcess := msNewProcess():New( { || aRet := P550Proc(iif(lCpy,cPath,cDirOri),aFiles[nI][1], aMsg, lOrigem)} , "Processando" , "Aguarde..." , .F. )
					oProcess:Activate()
				endif
			endif

			if lCpy
				fErase(cFileXML)
			endif
		endif
	next nI

	if len(aMsg) > 0 .and. !lAuto
		PLSCRIGEN(aMsg,{ {"Sequencial","@C",35},{"Arquivo","@C",70},{"Unimed","@C",25},{"Mensagem","@C",250} }, "Log de Importação",NIL,NIL,NIL,NIL, NIL,NIL,"G",220)
	endif
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} P550Proc
Importação do PTU A550 XML

@author    Lucas Nonato
@version   V12
@since     16/10/2020
/*/
function P550Proc(cDir, cFileXML, aMsg, lOrigem)
local aNS       	:= {}
local aDadRDA      	:= {}
local oPTU      	:= PTUA550IMP():New()
local cUniCre		:= ""
local cTpArq		:= ""
local cParcial		:= ""
local cNumFat		:= ""
local cNumNDC		:= ""
local cWhoSent		:= ""
local cSql			:= ""
local cError		:= ""
local cWarning		:= ""
local cMotivo		:= ""
local cDesMot		:= ""
local cTag			:= ""
local cAcordo		:= ""
local cMsg			:= ""
local cCodigo		:= ""
local cSeqPTU		:= ""
local lFezAlgo 		:= .f.
local lCriou 		:= .f.
local lBD7 			:= .f.
local nVLRAPR		:= 0
local nVLTXPG		:= 0
local nVLRPAG		:= 0
local nVLTXAP		:= 0
local nVlrRec 		:= 0
local nVlrAcordo 	:= 0
local nVlrTxRec 	:= 0
local nVlrTxAcordo 	:= 0
local nI 			:= 0
local dAcordo 		:= stod("")
Local nValorOrig    := 0
Local nValorPago    := 0
Local nSomaAcordo   := 0
local lNF           :=.f.

private cNS     	:= ""
private oXML    	:= tXmlManager():New()
private lMsErroAuto := .F.

default aMsg := {}

oPTU:aMsg 		:= aClone(aMsg)
oPTU:cArquivo 	:= cFileXML

if !oXML:parseFile(cDir+cFileXML, @cError, @cWarning)
	oPTU:addMsg("",cFileXML, "", cError)
	aMsg := aClone(oPTU:aMsg)
	return
endif

aNS := oXML:XPathGetRootNsList() 

for nI := 1 to len(aNS)  
	oXML:XPathRegisterNs( aNS[nI][1],aNS[nI][2] )
	cNS := aNS[nI][1]
	If oXML:XPathHasNode( addNs("/ptuA550") )
		exit
	EndIf
next nI

oPTU:cPathRaiz   := addNS("/ptuA550")
oPTU:cPath       := oPTU:cPathRaiz + addNS("/cabecalho")
 
// unimed
cUniCre 	:= strzero(val(oXML:XPathGetNodeValue( oPTU:cPath + addNS("/unimed/cd_uni_cred"))),4)
oPTU:lOrigem := lOrigem

// cobranca
cNumFat 	:= oXML:XPathGetNodeValue( oPTU:cPath + addNS("/documento1/nr_Doc_1_A500"))
cNumNDC 	:= oXML:XPathGetNodeValue( oPTU:cPath + addNS("/documento2/nr_Doc_2_A500"))
cWhoSent	:= strzero(val(oXML:XPathGetNodeValue( oPTU:cPath + addNS("/unimed/cd_Uni_Origem"))),4)
cTpArq		:= oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosCobranca/tp_Arquivo"))
cParcial	:= oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosCobranca/tp_arq_parcial"))

nValorOrig := val(oXML:XPathGetNodeValue( oPTU:cPath + addNS("/documento1/vl_Tot_Cont_Doc_1")) + oXML:XPathGetNodeValue( oPTU:cPath + addNS("/documento2/vl_Tot_Cont_Doc_2")))
nValorPago := val(oXML:XPathGetNodeValue( oPTU:cPath + addNS("/documento1/vl_Tot_Pago_Doc_1")) + oXML:XPathGetNodeValue( oPTU:cPath + addNS("/documento2/vl_Tot_Pago_Doc_2")))

if cTpArq == "1"
	oPTU:addMsg("",cFileXML, cWhoSent, "Tipo de Arquivo deve ser diferente de 1.")
	aMsg := aClone(oPTU:aMsg)
	return
endif

if oPTU:lOrigem
	cSql := " SELECT R_E_C_N_O_ Recno FROM " + RetSqlName("BRJ")
	cSql += " WHERE BRJ_FILIAL = '" + xfilial("BRJ") + "' "
	cSql += " AND BRJ_OPEORI = '" + cWhoSent + "' "
	if empty(cNumNDC)
		cSql += " AND BRJ_NUMFAT = '" + cNumFat + "' "
	else
		cSql += " AND (BRJ_NUMFAT = '" + cNumFat + "' OR BRJ_NRNDC = '" + cNumNDC + "' )"
	endif
	cSql += " AND D_E_L_E_T_ = ' ' " 
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPBRJ",.F.,.T.)
	if TMPBRJ->(eof())
		oPTU:addMsg("",cFileXML, cWhoSent, "Fatura [" + ifPls(cNumNDC,cNumFat) + "] não localizada.")
		aMsg := aClone(oPTU:aMsg)
		TMPBRJ->(dbclosearea())
		return
	else
		BRJ->(dbgoto(TMPBRJ->Recno))
	endif
	TMPBRJ->(dbclosearea())

	if BRJ->BRJ_STATUS <> '2' .and. BRJ->BRJ_GLOSA <> '1'
		cMsg := "Lote não foi faturado ou não possui glosa."
	endif
	
	if !empty(cParcial) .and. (cParcial == BRJ->BRJ_ARQPAR .or. BRJ->BRJ_ARQPAR == "2")
		cMsg := "Parcial ["+cParcial+"] ja importada anteriormente"
	endif

	if empty(cParcial) .and. cTpArq $ "34"
		cMsg := "Fechamento parcial(tp_Arquivo) sem parcial(tp_arq_parcial) informada."
	endif

	if BRJ->BRJ_NIV550 $ "56789"
		cMsg := "Este lote já apresentou fechamento."
	endif
	cCodigo := BRJ->BRJ_CODIGO
else //Executora
	if (!lPLSR556 .and. (empty(cNumNDC) .and. !BTO->(msseek(xfilial("BTO")+cNumFat))) .or. (!empty(cNumNDC) .and. !BTO->(msseek(xfilial("BTO")+cNumNDC)))) .or. ;
		(lPLSR556 .and. execBlock("PLSR556",.F.,.F.,{cNumFat,cNumNDC}))
		cMsg := "Fatura [" + ifPls(cNumNDC,cNumFat) + "] não localizada."
	endif

	if !empty(cParcial) .and. (cParcial == BTO->BTO_ARQPAR .or. BTO->BTO_ARQPAR == "2")
		cMsg := "Parcial ["+cParcial+"] ja importada anteriormente"
	endif

	if empty(cParcial) .and. cTpArq $ "34"
		cMsg := "Fechamento parcial(tp_Arquivo) sem parcial(tp_arq_parcial) informada."
	endif

	if BTO->BTO_NIV550 $ "56789"
		cMsg := "Este lote já apresentou fechamento."
	endif

	if empty(cMsg)
		BAU->(dbsetorder(7))
		if !BAU->(msSeek(xFilial("BAU")+BTO->BTO_OPEORI))
			cMsg := "RDA da operadora [" + BTO->BTO_OPEORI + "] não localizada."
		else
			aDadRDA := PLSDADRDA(cCodInt,BAU->BAU_CODIGO)
			if !aDadRDA[1]
				cMsg := "RDA invalida [" + BAU->BAU_CODIGO + "] verifique o cadastro."
			endif
		endif
	endif
	cCodigo := BTO->BTO_NUMERO
endif

if !empty(cMsg)
	oPTU:addMsg(cCodigo,cFileXML,cWhoSent,cMsg )
	aMsg := aClone(oPTU:aMsg)		
	return
endif

Begin Transaction

if oPTU:lOrigem
	BRJ->(reclock("BRJ",.f.)) 
		BRJ->BRJ_NIV550 := cTpArq		
		BRJ->BRJ_ARQPAR := ifPls(cParcial,"0")		
	BRJ->(msunlock()) 
else
	BTO->(reclock("BTO",.f.)) 
		BTO->BTO_NIV550 := cTpArq		
		BTO->BTO_ARQPAR := ifPls(cParcial,"0")		
	BTO->(msunlock()) 
endif

oPTU:cPath := oPTU:cPathRaiz + addNS("/Tipo_Questionamento/Quest/Questionamento")
while oPTU:hasNext()
	cTag 	:= oPTU:cPathQ + addNS("/DadosLoteGuia")
	lCriou 	:= .f.
	cNumGui := ""
	while oPTU:hasNextProc()
	
		nVlrRec := val(oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Valores/vl_Reconh_Serv")))
		nVlrRec += val(oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Valores/vl_Reconh_CO")))
		nVlrRec += val(oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Valores/vl_Reconh_Filme")))

		//Valor de acordo é o valor acordado para ser recebido para a unimed origem.
		//Caso eu seja a executora eu tenho que pagar o valor do acordo
		//Caso eu seja a origem eu tenho que receber o valor de acordo, gerando um A560.
		nVlrAcordo := val(oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Valores/vl_Acordo_Serv")))
		nVlrAcordo += val(oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Valores/vl_Acordo_CO")))
		nVlrAcordo += val(oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Valores/vl_Acordo_Filme")))

		nVlrTxRec := val(oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Taxas/vl_Reconh_Adic_Serv")))
		nVlrTxRec += val(oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Taxas/vl_Reconh_Adic_CO")))
		nVlrTxRec += val(oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Taxas/vl_Reconh_Adic_Filme")))

		nVlrTxAcordo := val(oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Taxas/vl_Acordo_Adic_Serv")))
		nVlrTxAcordo += val(oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Taxas/vl_Acordo_Adic_CO")))
		nVlrTxAcordo += val(oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Taxas/vl_Acordo_Adic_Filme")))

		cMotivo := oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Motivo_Questionamento/cd_Motivo_Ques"))
		cDesMot := oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Motivo_Questionamento/ds_Motivo_Ques"))
		cAcordo := oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/tp_Acordo"))
		// 99-Item não contestado
		if cMotivo <> "99" .and. (cAcordo $ "01|02|13|14")
			if oPTU:getBD6()
				lFezAlgo := .t.
				dAcordo := stod(oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/dt_acordo")))	

				nVLRAPR := BD6->BD6_VLRAPR
				nVLTXPG := BD6->BD6_VLTXPG
				nVLRPAG := BD6->BD6_VLRPAG
				nVLTXAP := BD6->BD6_VLTXAP
				lBD7 	:= .f.

				cSeqPTU	:= strzero(val(oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/SeqItem/seq_itemTXT"))),8)
				// Se for seqTXT posso ter mais de um sequen por BD7, então a regra é por BD7
				if !empty(val(cSeqPTU))
					cSql := " SELECT SUM(BD7_VLRAPR) VLRAPR, SUM(BD7_VLTXPG) VLTXPG, SUM(BD7_VLRPAG) VLRPAG, SUM(BD7_VLTXAP) VLTXAP FROM " + retSqlName("BD6") + " BD6 "
					cSql += " INNER JOIN " + retSqlName("BD7") + " BD7 "
					cSql += " ON  BD7_FILIAL = '" + xfilial("BD6") + "' "
					cSql += " AND BD7_CODOPE = BD6_CODOPE "
					cSql += " AND BD7_CODLDP = BD6_CODLDP "
					cSql += " AND BD7_CODPEG = BD6_CODPEG "
					cSql += " AND BD7_NUMERO = BD6_NUMERO "
					cSql += " AND BD7_ORIMOV = BD6_ORIMOV "
					cSql += " AND BD7_SEQUEN = BD6_SEQUEN "	
					cSql += " AND BD7_SEQ500 = '" + cSeqPTU + "' "  
					cSql += " AND BD7.D_E_L_E_T_ = ' ' "  
					cSql += " WHERE BD6.R_E_C_N_O_ = " + cvaltochar(BD6->(recno()))
					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPBD7",.F.,.T.)					
					lBD7 := .t.
					nVLRAPR := TMPBD7->VLRAPR
					nVLTXPG := TMPBD7->VLTXPG
					nVLRPAG := TMPBD7->VLRPAG
					nVLTXAP := TMPBD7->VLTXAP
				endif				

				nSomaAcordo += nVlrAcordo + nVlrTxAcordo

				B2A->( RecLock("B2A",.T.) )
				B2A->B2A_FILIAL := xfilial("B2A")
				B2A->B2A_CODOPE := cCodInt
				B2A->B2A_OPEDES := iif(oPTU:lOrigem,BRJ->BRJ_OPEORI,BTO->BTO_OPEORI)
				B2A->B2A_LOTE 	:= iif(oPTU:lOrigem,BRJ->BRJ_CODIGO,BTO->BTO_NUMERO)
				B2A->B2A_NUMTIT := ifPls(cNumNDC,cNumFat)
				B2A->B2A_NOTA   := BD6->BD6_NUMIMP
				B2A->B2A_MATRIC := BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
				B2A->B2A_DATATE := BD6->BD6_DATPRO
				B2A->B2A_CODPAD := BD6->BD6_CODPAD
				B2A->B2A_CODPRO := BD6->BD6_CODPRO
				B2A->B2A_VALCOB := nVLRAPR
				B2A->B2A_VALREC := nVlrRec
				B2A->B2A_VALACI := nVlrAcordo
				B2A->B2A_CODQUE := cMotivo
				B2A->B2A_COMQUE := cDesMot
				B2A->B2A_DATACO := dAcordo
				B2A->B2A_STAACO := cAcordo
				B2A->B2A_TPARQ  := cTpArq
				B2A->B2A_DTEXIP := dDataBase
				B2A->B2A_ALIAS  := iif(oPTU:lOrigem,"BRJ","BTO")	
				B2A->B2A_NIVEL  := ifPls(cParcial,"0")
				B2A->B2A_VLTXPG := nVlrTxRec
				B2A->B2A_VLTXAP := nVLTXAP
				B2A->B2A_VLTXAC := nVlrTxAcordo
				B2A->B2A_LOTEDI := iif(oPTU:lOrigem,BD6->BD6_LOTEDI,BD6->BD6_CODPEG)					
				B2A->B2A_CHKBD6 := BD6->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN)
				B2A->( MsUnLock() )

				if (oPTU:lOrigem .and. (nVLRPAG <= nVlrRec + nVlrTxRec) .and. nVlrAcordo + nVlrTxAcordo > 0) .or. (!oPTU:lOrigem .and. nVlrAcordo+nVlrTxAcordo > 0)
					oPTU:clona(cFileXML,nVlrRec,nVlrAcordo,nVlrTxRec,nVlrTxAcordo,aDadRDA,lBD7,"TMPBD7",@cNumGui)
					B2A->( RecLock("B2A",.f.) )
					B2A->B2A_NEWBD6 := BD6->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN)
					B2A->( MsUnLock() )
					lCriou := .t.
				endif
				if lBD7
					TMPBD7->(dbclosearea())
				endif
			endif
		endif
	enddo
	if lCriou
		atualizaValor(.t.,oPTU)
	endif
enddo

if !empty(oPTU:cConsulta)
	BCI->(msseek(xfilial("BCI")+oPTU:cConsulta))	
	atualizaValor(.f.,oPTU)
endif
if !empty(oPTU:cSADT)
	BCI->(msseek(xfilial("BCI")+oPTU:cSADT))
	atualizaValor(.f.,oPTU)
endif
if !empty(oPTU:cGRI)
	BCI->(msseek(xfilial("BCI")+oPTU:cGRI))
	atualizaValor(.f.,oPTU)
endif
if !empty(oPTU:cHonor)
	BCI->(msseek(xfilial("BCI")+oPTU:cHonor))
	atualizaValor(.f.,oPTU)
endif

//Cria o título da contestação
PtuCriaTit(oPTU,nSomaAcordo,nValorPago)


//Parte da nota fiscal do fornecedor
oPTU:LimpVar(@nSomaAcordo)
oPTU:cPath := oPTU:cPathRaiz + addNS("/Tipo_Questionamento/Quest/Questionamento_NFiscalFornec")

while  oPTU:hasNext()
	lCriou 	:= .f.
	lFezAlgo:= .f. 
	cNumGui := ""
	lNF     := .t.
	while oPTU:hasNextProc()
		nVlrRec    := val(oXML:XPathGetNodeValue(oPTU:cPathP + addNS("/Valores/vl_Reconh_Serv")))
		nVlrAcordo := val(oXML:XPathGetNodeValue(oPTU:cPathP + addNS("/Valores/vl_Acordo_Serv")))
		nVlrTxRec  := val(oXML:XPathGetNodeValue(oPTU:cPathP + addNS("/Taxas/vl_Reconh_Adic_Serv")))

		nVlrTxAcordo := val(oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Taxas/vl_Acordo_Adic_Serv")))

		cMotivo := oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Motivo_Questionamento/cd_Motivo_Ques"))
		cDesMot := oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/Motivo_Questionamento/ds_Motivo_Ques"))
		cAcordo := oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/tp_Acordo"))
	
		// 99-Item não contestado
		if cMotivo <> "99" .and. (cAcordo $ "01|02|13|14")
			if oPTU:getBD6()
				lFezAlgo := .t.
				dAcordo := stod(oXML:XPathGetNodeValue( oPTU:cPathP + addNS("/dt_acordo")))	

				nVLRAPR := BD6->BD6_VLRAPR
				nVLTXPG := BD6->BD6_VLTXPG
				nVLRPAG := BD6->BD6_VLRPAG
				nVLTXAP := BD6->BD6_VLTXAP
				
				nSomaAcordo += nVlrAcordo + nVlrTxAcordo

				B2A->( RecLock("B2A",.T.) )
				B2A->B2A_FILIAL := xfilial("B2A")
				B2A->B2A_CODOPE := cCodInt
				B2A->B2A_OPEDES := iif(oPTU:lOrigem,BRJ->BRJ_OPEORI,BTO->BTO_OPEORI)
				B2A->B2A_LOTE 	:= iif(oPTU:lOrigem,BRJ->BRJ_CODIGO,BTO->BTO_NUMERO)
				B2A->B2A_NUMTIT := ifPls(cNumNDC,cNumFat)
				B2A->B2A_NOTA   := BD6->BD6_NUMIMP
				B2A->B2A_MATRIC := BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
				B2A->B2A_DATATE := BD6->BD6_DATPRO
				B2A->B2A_CODPAD := BD6->BD6_CODPAD
				B2A->B2A_CODPRO := BD6->BD6_CODPRO
				B2A->B2A_VALCOB := nVLRAPR
				B2A->B2A_VALREC := nVlrRec
				B2A->B2A_VALACI := nVlrAcordo
				B2A->B2A_CODQUE := cMotivo
				B2A->B2A_COMQUE := cDesMot
				B2A->B2A_DATACO := dAcordo
				B2A->B2A_STAACO := cAcordo
				B2A->B2A_TPARQ  := cTpArq
				B2A->B2A_DTEXIP := dDataBase
				B2A->B2A_ALIAS  := iif(oPTU:lOrigem,"BRJ","BTO")	
				B2A->B2A_NIVEL  := ifPls(cParcial,"0")
				B2A->B2A_VLTXPG := nVlrTxRec
				B2A->B2A_VLTXAP := nVLTXAP
				B2A->B2A_VLTXAC := nVlrTxAcordo
				B2A->B2A_LOTEDI := iif(oPTU:lOrigem,BD6->BD6_LOTEDI,BD6->BD6_CODPEG)					
				B2A->B2A_CHKBD6 := BD6->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN)
				B2A->( MsUnLock() )

				if (oPTU:lOrigem .and. (nVLRPAG <= nVlrRec + nVlrTxRec) .and. nVlrAcordo + nVlrTxAcordo > 0) .or. (!oPTU:lOrigem .and. nVlrAcordo+nVlrTxAcordo > 0)
					oPTU:clona(cFileXML,nVlrRec,nVlrAcordo,nVlrTxRec,nVlrTxAcordo,aDadRDA,lBD7,"TMPBD7",@cNumGui)
					B2A->( RecLock("B2A",.f.) )
					B2A->B2A_NEWBD6 := BD6->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN)
					B2A->( MsUnLock() )
					lCriou := .t.	
				endif
			endif
		endif
	enddo
	if lCriou
		atualizaValor(.t.,oPTU)
	endif
end

if !empty(oPTU:cSADT) .and. lNF
	BCI->(msseek(xfilial("BCI")+oPTU:cSADT))
	atualizaValor(.f.,oPTU)
endif

//Cria titulo da nota fiscal do fornecedor 
if lNF
	PtuCriaTit(oPTU,nSomaAcordo,nValorPago)
endif


if !lFezAlgo
	oPTU:addMsg(cCodigo,cFileXML,cWhoSent,"Arquivo importado, mas sem valores a pagar" )
endif

aMsg := aClone(oPTU:aMsg)

End Transaction

return 

//-------------------------------------------------------------------
/*/{Protheus.doc} clona

@author  Lucas Nonato
@version P12
@since   23/10/2020
/*/
method clona(cFileXML,nVlrRec,nVlrAcordo,nVlrTxRec,nVlrTxAcordo,aDadRDA,lBD7,cAliBD7,cNumGui) class PTUA550IMP
local cCodPeg 	:= ""
local cCodRDA 	:= ""
local cParcial 	:= ""
local cGuiOri 	:= ""
local cCodLDP	:= ""
local cCodigo	:= ""
local cOpeOri	:= ""
local cAlias	:= "BD5"
local nX 		:= 1
local dData 	:= date()
local lNew		:= .t.
local aCmpCAB 	:= {}
local aDadCab 	:= {}
local aDadBD6 	:= {}
local aDadBX6 	:= {}
local aDadBD7 	:= {}

default aDadRDA := {}

do case 
	case BD6->BD6_TIPGUI == GUIA_CONSULTA
		cCodPeg := ::cConsulta		
	case BD6->BD6_TIPGUI == GUIA_SADT	
		cCodPeg := ::cSADT
	case BD6->BD6_TIPGUI == GUIA_INTERNACAO
		cCodPeg := ::cGRI
		cAlias 	:= "BE4"
	case BD6->BD6_TIPGUI == GUIA_HONORARIO
		cCodPeg := ::cHonor
endcase

if empty(cCodPeg)
	dData 		:= stod(oXML:XPathGetNodeValue( self:cPathRaiz + addNS("/cabecalho/dadosCobranca/dt_Geracao")))
	cParcial	:= oXML:XPathGetNodeValue( self:cPathRaiz + addNS("/cabecalho/dadosCobranca/tp_arq_parcial"))
	cParcial	:= ifPls(cParcial,"0")
	if ::lOrigem
		cCodLDP := cCodLDPO
		cCodigo := "BRJ|"+BRJ->BRJ_CODIGO
		cCodEdi := BRJ->BRJ_CODIGO
		cOpeOri := BRJ->BRJ_OPEORI
		cCodRDA := BD6->BD6_CODRDA
	else
		cCodLDP := cCodLDPE
		cCodigo := "BTO|"+BTO->BTO_NUMERO
		cCodEdi := BTO->BTO_NUMERO
		cOpeOri := BTO->BTO_OPEORI
		cCodRDA := BAU->BAU_CODIGO
	endif	

	PLSIPP(cCodInt,cCodLDP,cCodInt,cCodRDA,strzero(Month(dData),2),cvaltochar(year(dData)),date(),BD6->BD6_TIPGUI,"",{},"1",cFileXML,,,,,,dData,,,cCodigo,cParcial)
	::addMsg(cCodEdi,cFileXML,cOpeOri,"Protocolo criado: " + BCI->BCI_CODPEG )
	do case
		case BD6->BD6_TIPGUI == GUIA_CONSULTA
			::cConsulta := BCI->BCI_CODPEG
		case BD6->BD6_TIPGUI == GUIA_SADT
			::cSADT := BCI->BCI_CODPEG
		case BD6->BD6_TIPGUI == GUIA_INTERNACAO
			::cGRI := BCI->BCI_CODPEG
		case BD6->BD6_TIPGUI == GUIA_HONORARIO
			::cHonor := BCI->BCI_CODPEG
	endcase
else
	BCI->(msseek(xfilial("BCI")+cCodPeg))
endif

cGuiOri	:= BD6->BD6_CODOPE+BD6->BD6_CODLDP+BD6->BD6_CODPEG+BD6->BD6_NUMERO

if empty(cNumGui)
	if cAlias == "BD5"
		aCmpCAB := aclone(aCmpBD5)
	else
		aCmpCAB := aclone(aCmpBE4)
	endif

	(cAlias)->(msseek(xfilial(cAlias)+BD6->BD6_CODOPE+BD6->BD6_CODLDP+BD6->BD6_CODPEG+BD6->BD6_NUMERO))

	for nX := 1 to len(aCmpCAB)
		if "DTCTBF" $ aCmpCAB[nX]
			aadd(aDadCab,dDataBase)
		else
			aadd(aDadCab,&(cAlias+"->"+aCmpCAB[nX]))
		endif
	next	

	cNumGui	:= PLSA500NUM(cAlias, BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG)
	::grava(cAlias,aCmpCAB,aDadCAB,cNumGui,lNew,cGuiOri)
	(cAlias)->(recLock(cAlias, .f. ))
	(cAlias)->&(cAlias + "_GUIORI") :=  BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)
	if !::lOrigem		
		(cAlias)->&(cAlias + "_CODRDA") :=  BCI->BCI_CODRDA
		(cAlias)->&(cAlias + "_NOMRDA") :=  BCI->BCI_NOMRDA
		(cAlias)->&(cAlias + "_CPFRDA") :=  BAU->BAU_CPFCGC 
		(cAlias)->&(cAlias + "_TIPPRE") :=  BAU->BAU_TIPPRE 
		if len(aDadRDA) > 0
			(cAlias)->&(cAlias + "_TIPRDA") :=  aDadRda[8]  
			(cAlias)->&(cAlias + "_LOCAL")  :=  aDadRda[13] 
			(cAlias)->&(cAlias + "_CODLOC") :=  aDadRda[12] 
			(cAlias)->&(cAlias + "_CODESP") :=  aDadRda[15] 
			(cAlias)->&(cAlias + "_DESLOC") :=  aDadRda[19] 
			(cAlias)->&(cAlias + "_ENDLOC") :=  aDadRda[20] 
		endif				
	endif
	(cAlias)->(msUnlock())
endif

for nX := 1 to len(aCmpBD6)
	if "DTCTBF" $ aCmpBD6[nX]
		aadd(aDadBD6,dDataBase)
	else
		aadd(aDadBD6,&("BD6->"+aCmpBD6[nX]))
	endif
next

if BX6->(msseek(xfilial("BX6")+BD6->BD6_CODOPE+BD6->BD6_CODLDP+BD6->BD6_CODPEG+BD6->BD6_NUMERO+BD6->BD6_ORIMOV+BD6->BD6_SEQUEN))
	for nX := 1 to len(aCmpBX6)
		aadd(aDadBX6,&("BX6->"+aCmpBX6[nX]))
	next
endif

if lBD7
	cSeqPTU	:= strzero(val(oXML:XPathGetNodeValue( ::cPathP + addNS("/SeqItem/seq_itemTXT"))),8)
endif

if BD7->(msseek(xfilial("BD7")+BD6->BD6_CODOPE+BD6->BD6_CODLDP+BD6->BD6_CODPEG+BD6->BD6_NUMERO+BD6->BD6_ORIMOV+BD6->BD6_SEQUEN))
	cChave := xfilial("BD7")+BD6->BD6_CODOPE+BD6->BD6_CODLDP+BD6->BD6_CODPEG+BD6->BD6_NUMERO+BD6->BD6_ORIMOV+BD6->BD6_SEQUEN
	while cChave == BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
		if lBD7 .and. cSeqPTU <> BD7->BD7_SEQ500
			BD7->(dbskip())
			loop
		endif

		aadd(aDadBD7,{})
		nLen := len(aDadBD7)
		for nX := 1 to len(aCmpBD7)
			if "DTCTBF" $ aCmpBD7[nX]
				aadd(aDadBD7[nLen],dDataBase)
			else
				aadd(aDadBD7[nLen],&("BD7->"+aCmpBD7[nX]))
			endif
		next
		BD7->(dbskip())
	enddo
endif

if lBD7
	nVlrPag := TMPBD7->VLRPAG - TMPBD7->VLTXPG
	nVlTxPg := TMPBD7->VLTXPG
else
	nVlrPag := BD6->BD6_VLRPAG - BD6->BD6_VLTXPG
	nVlTxPg := BD6->BD6_VLTXPG
endif

if ::lOrigem
	nVlrPag 	:= nVlrRec - nVlrPag 
	nVlrTxPag 	:= nVlrTxRec - nVlTxPg
	nVlrPag 	+= nVlrTxPag
else
	nVlrPag 	:= nVlrAcordo + nVlrTxAcordo
	nVlrTxPag 	:= nVlrTxAcordo
endif

nVlrTxPag 	:= iif(nVlrTxPag<0,0,nVlrTxPag)
nVlrPag 	:= iif(nVlrPag<0,0+nVlrTxPag,nVlrPag)

::grava("BD6",aCmpBD6,aDadBD6,cNumGui,.t.,cGuiOri)
BD6->(reclock("BD6",.f.))
BD6->BD6_VLRPAG := nVlrPag
BD6->BD6_VLTXPG := nVlrTxPag
BD6->(msunlock())

if len(aDadBX6) > 0
	::grava("BX6",aCmpBX6,aDadBX6,cNumGui,.t.,cGuiOri)
endif

for nX := 1 to len(aDadBD7)
	::grava("BD7",aCmpBD7,aDadBD7[nX],cNumGui,.t.,cGuiOri)
	if lBD7
		nPercen := 100/len(aDadBD7)
	else
		nPercen := BD7->BD7_PERCEN
	endif
	BD7->(reclock("BD7",.f.))
	if lBD7
		BD7->BD7_PERCEN := nPercen
	endif
	BD7->BD7_VLRPAG := (BD6->BD6_VLRPAG * nPercen) / 100
	BD7->BD7_VLTXPG := (BD6->BD6_VLTXPG * nPercen) / 100
	BD7->(msunlock())
next

return

//-------------------------------------------------------------------
/*/{Protheus.doc} grava

@author  Lucas Nonato
@version P12
@since   20/10/2020
/*/
method grava(cAlias,aCampo,aDado,cNumero,lNew,cGuiOri) class PTUA550IMP
local nX := 1
(cAlias)->(reclock(cAlias,lNew))

&(cAlias+"->"+(cAlias)+"_FILIAL") 	:=  xfilial(cAlias)
&(cAlias+"->"+(cAlias)+"_CODOPE") 	:=  BCI->BCI_CODOPE
&(cAlias+"->"+(cAlias)+"_CODLDP") 	:=  BCI->BCI_CODLDP
&(cAlias+"->"+(cAlias)+"_CODPEG") 	:=  BCI->BCI_CODPEG
&(cAlias+"->"+(cAlias)+"_NUMERO") 	:=  cNumero
if cAlias <> "BX6"
	&(cAlias+"->"+(cAlias)+"_FASE") 	:=  iif(::lOrigem,"4","3")
	&(cAlias+"->"+(cAlias)+"_DTDIGI") 	:=  BCI->BCI_DTDIGI
	if cAlias <> "BD7"
		&(cAlias+"->"+(cAlias)+"_GUIORI") :=  cGuiOri
	endif
else
	BX6->BX6_SEQUEN :=  BD6->BD6_SEQUEN
endif

if cAlias == "BD6"
	BD6->BD6_CODRDA :=  BCI->BCI_CODRDA
	BD6->BD6_NOMRDA :=  BCI->BCI_NOMRDA
	if ::nY < 1000
		BD6->BD6_SEQUEN :=  strzero(::nY,3)
	else
		BD6->BD6_SEQUEN :=  ::cSequen
	endif 
endif 

if cAlias == "BD7"
	BD7->BD7_CODRDA :=  BCI->BCI_CODRDA
	BD7->BD7_NOMRDA :=  BCI->BCI_NOMRDA
	BD7->BD7_SEQUEN :=  BD6->BD6_SEQUEN
endif 

for nX := 1 to len(aCampo)
	&(cAlias+"->"+aCampo[nX]) := aDado[nX]
next
(cAlias)->(msunlock())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} getBD6

@author  Lucas Nonato
@version P12
@since   20/10/2020
/*/
method getBD6() class PTUA550IMP
local cIdUnico 	:= ""
local cSql		:= ""
local cRet		:= ""
local cCodPeg	:= ""
local cGuia		:= ""
local cSeqPTU	:= ""
local nRecnoBD6	:= 0

if oXML:XPathHasNode( ::cPathP + addNS("/id_itemUnico") )

	cCodPeg 	:= oXML:XPathGetNodeValue( ::cPathQ + addNS("/DadosLoteGuia/XML/nr_LotePrestador"))
	cIdUnico 	:= oXML:XPathGetNodeValue( ::cPathP + addNS("/id_itemUnico"))
	cGuia 		:= oXML:XPathGetNodeValue( ::cPathQ + addNS("/DadosLoteGuia/XML/nr_GuiaTissPrestador"))
	
	cSql := " SELECT BD6.R_E_C_N_O_ Recno FROM " + retSqlName("BX6") + " BX6 "
	cSql += " INNER JOIN " + retSqlName("BD6") + " BD6 "
	cSql += " ON  BD6_FILIAL = '" + xfilial("BD6") + "' "
	cSql += " AND BD6_CODOPE = BX6_CODOPE "
	cSql += " AND BD6_CODLDP = BX6_CODLDP "
	cSql += " AND BD6_CODPEG = BX6_CODPEG "
	cSql += " AND BD6_NUMERO = BX6_NUMERO "
	cSql += " AND BD6_ORIMOV = BX6_ORIMOV "
	cSql += " AND BD6_SEQUEN = BX6_SEQUEN "	
	cSql += " AND BD6.D_E_L_E_T_ = ' ' "  
	cSql += " WHERE BX6_FILIAL = '" + xfilial("BX6") + "' "
	cSql +=  iif(lIdUnico2," AND (BX6_IDUNIC = '" + cIdUnico + "' OR BX6_IDUNI2 = '" + cIdUnico + "')"," AND BX6_IDUNIC = '" + cIdUnico + "' ")
	if ::lOrigem
		cSql += " AND BD6_LOTEDI = '" + cCodPeg  + "' "
		cSql += " AND BD6_NUMIMP = '" + cGuia + "' "
	else
		cSql += " AND BD6_CODPEG = '" + cCodPeg  + "' "
	endif	
	cSql += " AND BX6.D_E_L_E_T_ = ' ' " 
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBX6",.F.,.T.)
	if !TrbBX6->(eof())
		nRecnoBD6 := TrbBX6->Recno
	else
		cRet := "Chave não localizada [id_itemUnico] = ["+cIdUnico+"] "
	endif
	TrbBX6->(dbclosearea())
endif

if nRecnoBD6 == 0 .and. oXML:XPathHasNode( ::cPathQ + addNS("/DadosLoteGuia/XML"))
	cCodPeg := oXML:XPathGetNodeValue( ::cPathQ + addNS("/DadosLoteGuia/XML/nr_LotePrestador"))
	cGuia 	:= oXML:XPathGetNodeValue( ::cPathQ + addNS("/DadosLoteGuia/XML/nr_GuiaTissPrestador"))
	cSeqPTU	:= oXML:XPathGetNodeValue( ::cPathP + addNS("/SeqItem/seq_itemXML"))

	nRecnoBD6 := ::recnoBD6(.t.,cCodPeg,cGuia,cSeqPTU)	
	if nRecnoBD6 == 0
		cRet := "Chave não localizada [nr_LotePrestador+nr_GuiaTissPrestador+seq_itemXML] = ["+cCodPeg+"|"+cGuia+"|"+cSeqPTU+"] "
	endif
endif

if nRecnoBD6 == 0 .and. oXML:XPathHasNode( ::cPathQ + addNS("/DadosLoteGuia/TXT"))
	cCodPeg := strzero(val(oXML:XPathGetNodeValue( ::cPathQ + addNS("/DadosLoteGuia/TXT/nr_Lote"))),8)
	cGuia 	:= oXML:XPathGetNodeValue( ::cPathQ + addNS("/DadosLoteGuia/TXT/nr_Nota"))
	cSeqPTU	:= strzero(val(oXML:XPathGetNodeValue( ::cPathP + addNS("/SeqItem/seq_itemTXT"))),8)

	nRecnoBD6 := ::recnoBD6(.f.,cCodPeg,cGuia,cSeqPTU)	
	nRecnoBD6 := iif(nRecnoBD6 ==0 ,::recnoBD6(.f.,cCodPeg,PadL(cGuia,20,'0'),cSeqPTU),nRecnoBD6)

	if nRecnoBD6 == 0
		cRet := "Chave não localizada [nr_LotePrestador+nr_GuiaTissPrestador+seq_itemTXT] = ["+cCodPeg+"|"+cGuia+"|"+cSeqPTU+"] "
	endif
endif

if nRecnoBD6 > 0
	BD6->(dbgoto(nRecnoBD6))
endif

if !empty(cRet)
	::addMsg(iif(::lOrigem,BRJ->BRJ_CODIGO,BTO->BTO_NUMERO),::cArquivo, iif(::lOrigem,BRJ->BRJ_OPEORI,BTO->BTO_OPEORI), cRet)
endif

return nRecnoBD6 > 0

//-------------------------------------------------------------------
/*/{Protheus.doc} recnoBD6

@author  Lucas Nonato
@version P12
@since   21/10/2020
/*/
method recnoBD6(lXml,cCodPeg,cGuia,cSeqPTU) class PTUA550IMP
local nRecno 	:= 0
local cSql 		:= ""

cSql := " SELECT BD6.R_E_C_N_O_ Recno FROM " + retSqlName("BCI") + " BCI "

if !lXml
	cSql += " INNER JOIN " + retSqlName("BD6") + " BD6 "
	cSql += " ON  BD6_FILIAL = '" + xfilial("BD6") + "' "
	cSql += " AND BD6_CODOPE = BCI_CODOPE "
	cSql += " AND BD6_CODLDP = BCI_CODLDP "
	cSql += " AND BD6_CODPEG = BCI_CODPEG "
	cSql += " AND BD6.D_E_L_E_T_ = ' ' "  
	cSql += " INNER JOIN " + retSqlName("BD7") + " BD7 "
	cSql += " ON  BD7_FILIAL = '" + xfilial("BD6") + "' "
	cSql += " AND BD7_CODOPE = BD6_CODOPE "
	cSql += " AND BD7_CODLDP = BD6_CODLDP "
	cSql += " AND BD7_CODPEG = BD6_CODPEG "
	cSql += " AND BD7_NUMERO = BD6_NUMERO "
	cSql += " AND BD7_ORIMOV = BD6_ORIMOV "
	cSql += " AND BD7_SEQUEN = BD6_SEQUEN "	
	cSql += " AND BD7.D_E_L_E_T_ = ' ' "  
else
	cSql += " INNER JOIN " + retSqlName("BX6") + " BX6 "
	cSql += " ON  BX6_FILIAL = '" + xfilial("BX6") + "' "
	cSql += " AND BX6_CODOPE = BCI_CODOPE "
	cSql += " AND BX6_CODLDP = BCI_CODLDP "
	cSql += " AND BX6_CODPEG = BCI_CODPEG "
	cSql += " AND BX6.D_E_L_E_T_ = ' ' "  
	cSql += " INNER JOIN " + retSqlName("BD6") + " BD6 "
	cSql += " ON  BD6_FILIAL = '" + xfilial("BD6") + "' "
	cSql += " AND BD6_CODOPE = BX6_CODOPE "
	cSql += " AND BD6_CODLDP = BX6_CODLDP "
	cSql += " AND BD6_CODPEG = BX6_CODPEG "
	cSql += " AND BD6_NUMERO = BX6_NUMERO "
	cSql += " AND BD6_ORIMOV = BX6_ORIMOV "
	cSql += " AND BD6_SEQUEN = BX6_SEQUEN "
	cSql += " AND BD6.D_E_L_E_T_ = ' ' "  
endif

cSql += " WHERE BCI_FILIAL = '" + xfilial("BCI") + "' "
cSql += " AND BCI_CODOPE = '" + cCodInt + "' "
if ::lOrigem
	cSql += " AND BD6_SEQIMP = '" + BRJ->BRJ_CODIGO + "' "
	cSql += " AND BD6_LOTEDI = '" + cCodPeg + "' "
	cSql += " AND BD6_NUMIMP = '" + cGuia + "' "
else
	cSql += " AND BCI_CODPEG = '" + cCodPeg + "' "
endif
cSql += " AND BD6_GUIORI = ' ' "  
if lXml
	cSql += " AND BX6_SEQPTU = '" + cSeqPTU + "' "
else
	cSql += " AND BD7_SEQ500 = '" + cSeqPTU + "' "  
endif
cSql += " AND BCI.D_E_L_E_T_ = ' ' " 
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBX6",.F.,.T.)

if !TrbBX6->(eof())
	nRecno := TrbBX6->Recno
endif
TrbBX6->(dbclosearea())

return nRecno

//-------------------------------------------------------------------
/*/{Protheus.doc} addNS
Adiciona o namespace dinamicamente nas tags.

@author  Lucas Nonato
@version P12
@since   16/10/2020
/*/
static function addNS(cTag) 

if !empty(cNS)
    cTag := strtran(cTag, "/", "/" + cNS + ":")
endif

return cTag

//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author  Lucas Nonato
@version P12
@since   16/10/2020
/*/
method New() class PTUA550IMP
::cOpeExe       := ""
::cPath 	    := ""
::cPathRaiz     := ""
::cConsulta		:= ""
::cHonor	 	:= ""
::cSADT 	 	:= ""
::cGRI 	 		:= ""
::cPathQ 		:= ""
::cPathP 		:= ""
::cArquivo 		:= ""
::nX 			:= 0
::nY 			:= 0
::nQtdX 		:= 0
::nTotal 		:= 1
::nQuest		:= 1
::aMsg 			:= {}
::lOrigem		:= .t.
::cSequen		:= ""
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} hasNext

@author  Lucas Nonato
@version P12
@since   20/10/2020
/*/
method hasNext() class PTUA550IMP

::nX++
::cPathQ := ::cPath + "[" + cvaltochar(::nX) + "]"
::nQuest++ 

//if ::nTotal <= 10
//	oProcess:incRegua1( "[" + cvaltochar(::nQuest) +  "] de [" + cvaltochar(::nTotal) + "]"  )
//elseif ::nQtdX == 5 .or. ::nQuest == ::nTotal .or. ::nQuest == 1
//	oProcess:incRegua1( "[" + cvaltochar(::nQuest) +  "] de [" + cvaltochar(::nTotal) + "]"  )
//	::nQtdX := 0
//endif

::nQtdX++
::nY := 0
return oXML:XPathHasNode( ::cPathQ )

//-------------------------------------------------------------------
/*/{Protheus.doc} hasNextProc

@author  Lucas Nonato
@version P12
@since   20/10/2020
/*/
method hasNextProc() class PTUA550IMP

::nY++
::cPathP := ::cPathQ + addNS("/Procedimento") + "[" + cvaltochar(::nY) + "]"

if ::nY == 1000
	::cSequen := Soma1("999")
elseif ::nY > 1000
	::cSequen := Soma1(::cSequen,3)
endif


//if ::nTotal <= 10
//	oProcess:incRegua2( "[" + cvaltochar(::nQuest) +  "] de [" + cvaltochar(::nTotal) + "]"  )
//elseif ::nQtdX == 5 .or. ::nQuest == ::nTotal .or. ::nQuest == 1
//	oProcess:incRegua2( "[" + cvaltochar(::nQuest) +  "] de [" + cvaltochar(::nTotal) + "]"  )
//	::nQtdX := 0
//endif

return oXML:XPathHasNode( ::cPathP )

//-------------------------------------------------------------------
/*/{Protheus.doc} atualizaValor

@author  Lucas Nonato
@version P12
@since   29/10/2020
/*/
static function atualizaValor(lGuia,oPTU)
local cAlias	:= iif(BCI->BCI_TIPGUI == "05","BE4","BD5")
//Query de busca dos valores da BD6 para gravação do cabeçalho (BD5/BE4)
cSql := " SELECT SUM(BD6_VLRPAG) SOMAVLRPAG, "
cSql += "        SUM(BD6_QTDPRO) SOMAQTDPRO,  "
cSql += "        COUNT(DISTINCT BD6_NUMERO) SOMAQTDDIG "
cSql += "  FROM " + retSqlName("BD6") + " BD6 "
cSql += " WHERE BD6.BD6_FILIAL = '" + xFilial("BD6") + "' "
cSql += "   AND BD6.BD6_CODOPE = '" + BCI->BCI_CODOPE + "' "
cSql += "   AND BD6.BD6_CODLDP = '" + BCI->BCI_CODLDP + "' "
cSql += "   AND BD6.BD6_CODPEG = '" + BCI->BCI_CODPEG + "' "
if lGuia
	cSql += "   AND BD6.BD6_NUMERO = '" + BD6->BD6_NUMERO + "' 
endif
cSql += "   AND BD6.D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TrbTOTPEG",.f.,.t.)

if ! TrbTOTPEG->(eof())
	if lGuia
		(cAlias)->(recLock(cAlias,.f.))
			&(cAlias+"->"+cAlias+"_VLRPAG") := TrbTOTPEG->SOMAVLRPAG
			&(cAlias+"->"+cAlias+"_QTDEVE")	:= TrbTOTPEG->SOMAQTDDIG		
		(cAlias)->(msUnLock())
	else
		BCI->(recLock("BCI",.f.))
			BCI->BCI_VLRGUI := TrbTOTPEG->SOMAVLRPAG	
			BCI->BCI_QTDEVE	:= TrbTOTPEG->SOMAQTDPRO
			BCI->BCI_QTDDIG	:= TrbTOTPEG->SOMAQTDDIG
			if oPTU:lOrigem
				BCI->BCI_FASE := "4"
			else
				BCI->BCI_FASE := "3"
			endif
		BCI->(msUnLock())
	endif	
endIf

TrbTOTPEG->(dbCloseArea())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSP550FIL
fitro da tela inicial

@author    Lucas Nonato
@since     03/11/2020
/*/
function PLSP550FIL(lF2)
local cStatus	:= space(1)
local cFiltro := ""
local aPergs  := {}
local aFilter := {} 

default lF2 := .f.

aadd( aPergs,{ 2, "Status:"		 	, 	cStatus		,{ "0=Todos","1=Parcial 1","2=Parcial 2","3=Encerrado"},100,/*'.T.'*/,.f. } )
aAdd( aPergs,{ 1, "A partir de:"	, 	dDataBase	, "", "", ""		, "", 50, .f.})


cFiltro += "@BRJ_FILIAL = '"+ BRJ->(xFilial("BRJ"))+ "' AND BRJ_REGPRI = '1' "

// tela para selecionar os filtros
if (paramBox( aPergs,"Filtro de Tela",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSP550X',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
	
	if (!empty(aFilter[1]) .and. aFilter[1] != "0")
		do case
			case aFilter[1] == "1" .or. aFilter[1] == "2"
				cFiltro += " AND BRJ_ARQPAR = '" + aFilter[1] + "' "
			case aFilter[3] == "3" 
				cFiltro += " AND BRJ_ARQPAR = '0' "
		endcase
	endif

	if (!empty(aFilter[2]))
		cFiltro += " AND BRJ_DATA >= '" + DtoS(aFilter[2]) + "' "
	endif

endif

cFiltro += " AND (	(BRJ_NUMSE2 <> ' ' AND BRJ_PRESE2 <> ' ' AND BRJ_TIPSE2 <> ' ') "
cFiltro += " 		OR BRJ_GLOSA = '1'  "
cFiltro += " 		OR (BRJ_TPCOB = '1' AND BRJ_PREE2N <> ' ' AND BRJ_NUME2N <> ' ')) "
cFiltro += " AND D_E_L_E_T_ = ' '"

if (lF2)
	If Valtype(oBrwBRJ) == "O"
		oBrwBRJ:SetFilterDefault(cFiltro)
		oBrwBRJ:Refresh(.T.)
	EndIf
endif

return cFiltro

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraLogErro
grava arquivo de log

@author   pablo alipio
@since    09/2020
@param    cError = erros encontrados
@param    cFileXML = nome do arquivo com erros
@param    cDirOri = diretório onde se encontro o arquivo com erro(salvamos o log nessa pasta)
/*/
static function geraLogErro( cError, cFileXML, cDirOri)
	local cFileLOG	:= "PTU500.log"
	local nArqLog	:= 0

	default cError   := ""
	default cFileXML := ""
	default cDirOri := ""

	if !(empty(cFileXML))
		cFileLOG	:= substr(cFileXML,1, at(".", cFileXML)-1) + ".log"
	endif

	cError := cValToChar(cError)

	nArqLog		:= fCreate( cDirOri+cFileLOG,FC_NORMAL,,.F. )

	fWrite( nArqLog, cError )
	fClose( nArqLog )

return cFileLOG

//-------------------------------------------------------------------
/*/{Protheus.doc} addMsg
Adiciona uma mensagem de processamento ao objeto

@author    Lucas Nonato
@version   1.xx
@since     21/10/2019
/*/
method addMsg(cCodigo, cArquivo, cUnimed, cMsg) class PTUA550IMP
default cUnimed := ""

default cArquivo := ""
default cCodigo := ""

if !empty(cCodigo)
	if ::lOrigem 
		cUnimed := BRJ->BRJ_OPEORI		
	else
		cUnimed := BTO->BTO_OPEORI	
	endif
endif

aadd(::aMsg,{cCodigo, cArquivo, cUnimed, cMsg})

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSP550EXC
Excluir contestação

@author Lucas Nonato
@since 	05/11/2020
/*/
Function PLSP550EXC(lAuto, lOrigem)
local cChave    	:= ""
local cSql 			:= ""
local cTpArq 		:= ""
local cParc 		:= ""
local cArqPar		:= ""
local cNomOri		:= ""
local cNiv550		:= ""
local lRes 			:= .f.
local lExc 			:= .t.
Local lExcLoop		:= .F.
Local cOpeQryEx		:= ""

default lAuto		:= .f.
default lOrigem		:= .t.

if lOrigem
	cChave 	:= BRJ->BRJ_CODIGO
	cArqPar := BRJ->BRJ_ARQPAR
	cAlias  := "BRJ"
	cNomOri := BRJ->BRJ_NOMORI	
	cNiv550 := BRJ->BRJ_NIV550
	BRJ->(dbsetorder(1))
else
	cChave 	:= BTO->BTO_NUMERO
	cArqPar := BTO->BTO_ARQPAR
	cAlias  := "BTO"
	cNiv550 := BTO->BTO_NIV550
	cOpeQryEx := BTO->BTO_OPEORI
	cNomOri := posicione("BA0",1,xfilial("BA0")+BTO->BTO_OPEORI,"BA0_NOMINT")
	BTO->(dbsetorder(1))
endif

if empty(cNiv550)
	if !lAuto
		MsgInfo("Este lote não teve contestação")
	endif
	return
endif

cSql := " SELECT Distinct BCI_TIP550, BCI_CODOPE, BCI_CODLDP, BCI_CODPEG, BCI.R_E_C_N_O_ Recno FROM " + retSqlName("BCI") + " BCI "
if !lOrigem
	cSql += " Inner Join " + RetSqlName("BD6") + " BD6 "
	cSql += " On "
	cSql += " BD6_FILIAL = '" + xFilial("BD6") + "' AND "
	cSql += " BD6_CODOPE = BCI_CODOPE AND "
	cSql += " BD6_CODLDP = BCI_CODLDP AND "
	cSql += " BD6_CODPEG = BCI_CODPEG AND "
	cSql += " BD6_OPEORI = '" + cOpeQryEx + "' AND "
	cSql += " BD6.D_E_L_E_T_ = ' ' "
endif
cSql += " WHERE BCI_FILIAL = '" + xfilial("BCI")+"' "
cSql += " AND BCI_LOTEDI = '" + cAlias+"|"+cChave + "' "
cSql += " AND BCI_TIP550 = '" + cArqPar + "' "
cSql += " AND BCI.D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'TrbBCI',.F.,.T.)

cTpArq := TrbBCI->BCI_TIP550

if cTpArq == "1"
	cMsgTipo := "parcial 1"
	cNumTit := BRJ->BRJ_NUMTIT
elseif cTpArq == "2"
	cMsgTipo := "parcial 2"
	cNumTit := BRJ->BRJ_FP2TIT
else
	cMsgTipo := "fechamento"
	cNumTit := BRJ->BRJ_CFTTIT
endif

If !lAuto
	lExc := MsgYesNo("Confirma o cancelamento da contestação de " + cMsgTipo + "?" + CRLF +  "[" + cChave + "] " + cNomOri  , "Exclusão")
endif

if !lOrigem .AND. !lAuto
	lExc := ExcluiCmp()
endif

if lExc
	if !empty(cNumTit) .and. (lExc := MsgYesNo("Contestação com PTU A560 gerado, confirma o cancelamento do titulo de " + cMsgTipo + "?" + CRLF +  "[" + cChave + "] " + cNomOri  , "Exclusão"))
		lExc := P560CANTIT(.t.)
	endif
endif

if lExc	

	BX6->(dbSetOrder(1))
	BCI->(dbsetorder(1))
	BD5->(dbsetorder(1))
	BE4->(dbsetorder(1))
	BD6->(dbsetorder(1))
	BD7->(dbsetorder(1))
	B43->(dbsetorder(1))	
	B2A->(dbsetorder(3))
	
	Begin Transaction

	while !TrbBCI->(eof())
		if cTpArq <> TrbBCI->BCI_TIP550
			exit
		endif

		incProc("Excluindo lote:" + "[" + cChave + "] PEG: [" + TrbBCI->BCI_CODPEG + "]" )

		while B2A->(MsSeek(xfilial("B2A")+cAlias+cChave+TrbBCI->BCI_TIP550))
			lExcLoop := .T.
			B2A->(RecLock("B2A",.F.))
			B2A->(dbDelete())
			B2A->(MsUnlock())
		enddo
		
		while BD7->(MsSeek(xfilial("BD7")+TrbBCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)))
			BD7->(RecLock("BD7",.F.))
			BD7->(dbDelete())
			BD7->(MsUnlock())
		enddo

		while BD6->(MsSeek(xfilial("BD6")+TrbBCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)))
			BD6->(RecLock("BD6",.F.))
			BD6->(dbDelete())
			BD6->(MsUnlock())
		enddo

		while BD5->(MsSeek(xfilial("BD5")+TrbBCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)))
			BD5->(RecLock("BD5",.F.))
			BD5->(dbDelete())
			BD5->(MsUnlock())
		enddo

		while BE4->(MsSeek(xfilial("BE4")+TrbBCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)))
			BE4->(RecLock("BE4",.F.))
			BE4->(dbDelete())
			BE4->(MsUnlock())
		enddo

		while B43->(MsSeek(xfilial("B43")+TrbBCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)))
			B43->(RecLock("B43",.F.))
			B43->(dbDelete())
			B43->(MsUnlock())
		enddo

		while BX6->(MsSeek(xfilial("BX6")+TrbBCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)))
			BX6->(RecLock("BX6",.F.))
			BX6->(dbDelete())
			BX6->(MsUnlock())
		enddo

		while BCI->(MsSeek(xfilial("BCI")+TrbBCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)))
			BCI->(RecLock("BCI",.F.))
			BCI->(dbDelete())
			BCI->(MsUnlock())
		enddo

		TrbBCI->(dbskip())
	enddo

	if !lExcLoop
		while B2A->(MsSeek(xfilial("B2A")+cAlias+cChave+cArqPar))
			B2A->(RecLock("B2A",.F.))
			B2A->(dbDelete())
			B2A->(MsUnlock())
		enddo
	endif
	
	if lOrigem
		cParc	:= BRJ->BRJ_ARQPAR
	else
		cParc	:= BTO->BTO_ARQPAR
	endif
	
	(cAlias)->(RecLock(cAlias,.f.))

	if cParc == "2"
		(cAlias)->&(cAlias+"_ARQPAR") := "1"
	else
		cSql := " SELECT BCI_TIP550 FROM " + retSqlName("BCI")
		cSql += " WHERE BCI_FILIAL = '" + xfilial("BCI")+"' "
		cSql += " AND BCI_LOTEDI = '" + cAlias+"|"+cChave + "' "
		cSql += " AND BCI_TIP550 <> '" + cParc + "' "
		cSql += " AND D_E_L_E_T_ = ' ' "
		cSql += " ORDER BY R_E_C_N_O_ DESC "
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'TrbBCI2',.F.,.T.)
		if !TrbBCI2->(eof())
			(cAlias)->&(cAlias+"_ARQPAR") := TrbBCI2->BCI_TIP550
		else
			(cAlias)->&(cAlias+"_ARQPAR") := ""
		endif	
		TrbBCI2->(dbclosearea())	
	endif

	if empty((cAlias)->&(cAlias+"_ARQPAR"))
		(cAlias)->&(cAlias+"_NIV550") := ""
	else
		(cAlias)->&(cAlias+"_NIV550") := "3"
	endif

	(cAlias)->(MsUnlock())	
	
	End Transaction
	
	// atualiza o grid
	if !lAuto
		if lOrigem
			oBrwBRJ:Refresh(.T.)
			oBrwBRJ:ExecuteFilter()
		else
			oBrwBTO:Refresh(.T.)
			oBrwBTO:ExecuteFilter()
		endif
	endif

	// encerra
	if lRes
		MsgInfo("Lote cancelado com sucesso")
	endif

endif

TrbBCI->(dbclosearea())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} P500TPARQ
tp_arquivo

@author Lucas Nonato
@since 	05/11/2020
/*/
function P500TPARQ()

local cRet := "1=Arquivo para inclusão de questionamentos;"+;
"3=Fechamento parcial da Unimed Credora da NDC;"+;
"4=Fechamento parcial da Unimed Devedora da NDC;"+;
"5=Arquivo de fechamento da Unimed Credora da NDC;"+;
"6=Arquivo de fechamento da Unimed Devedora da NDC;"+;
"7=Fechamento complementar da Unimed Credora da NDC;"+;
"8=Fechamento complementar da Unimed Devedora da NDC;"+;
"9=Fechamento por decurso de prazo"

return cRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} P500TPARQ
tp_acordo

@author Lucas Nonato
@since 	05/11/2020
/*/
function P500TPACO()

local cRet := "00=Questionamento em negociação;"+;
"01=Questionamento encerrado com Acordo;"+;
"02=Questionamento encerrado com Acordo sem emissão de nota de débito;"+;
"03=Ignorado;"+;
"04=Excluído pelo autor;"+;
"05=Remetido para Câmara Técnica;"+;
"06=Reservado;"+;
"10=Encerrado pelo administrador;"+;
"11=Questionamento não contestado;"+;
"12=Parcial;"+;
"13=Encerrado pelo administrador - Parcial;"+;
"14=Encerrado pelo administrador - Tempo máximo de contestação expirado;"+;
"15=Encerrado pelo Administrador - Expiradas finalizadas pelo Administrador"

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTITOpe

@author    PLS TEAM
@version   V12
@since     16/10/2020
/*/
Function CriaTITOpe(cOpeOri,cAno,cMes,nVlrGlosa,cCodInt,nTipo)
LOCAL nOrdBA0       := BA0->(IndexOrd())
LOCAL nRecBA0       := BA0->(Recno())
LOCAL nOrdSA1       := SA1->(IndexOrd())
LOCAL nRecSA1       := SA1->(Recno())
Local cNumero       := ""
LOCAL cPrefixo      := GetNewPar("MV_PLPREE1",'"PLS"')
LOCAL cTipTit       := GetNewPar("MV_PLSTPTA",'"FT"')
LOCAL aCpoSE1       := {}
LOCAL aBases        := {0,0,0,0,0,0}
LOCAL lContabiliza  := .F.
local lErro         := .f.
Local nDiasVcto     := GetNewPar("MV_PLVCTTC", 10)
LOCAL lRet          := .F.
Local nRecno := 0

DEFAULT cCodInt     := ""
Default nTipo := 1

cPrefixo := eval({|| &cPrefixo })
cTipTit  := eval({|| &cTipTit })

// Posiciona na operadora origem para pegar o cliente...               
BA0->(DbSetOrder(1))
SA1->(DbSetOrder(1))
If BA0->(msSeek(xFilial("BA0")+cOpeOri,.F.)) .And. SA1->(msSeek(xFilial("SA1")+BA0->(BA0_CODCLI+BA0_LOJCLI),.F.))
	
	cNumero := PLSE1NUM(cPrefixo)
	
	aadd(aCpoSE1, {"E1_PREFIXO", cPrefixo, nil } )
    aadd(aCpoSE1, {'E1_SERIE', cPrefixo, nil } )
	aadd(aCpoSE1, {"E1_NUM", cNumero, nil } )
	aadd(aCpoSE1, {'E1_PARCELA', '', nil } )
	if nTipo == 1
		aadd(aCpoSE1, {"E1_TIPO", cTipTit, nil } )
	else
		cTipTit := "NCC"
		aadd(aCpoSE1, {"E1_TIPO", "NCC", nil } )
	endif
	aadd(aCpoSE1, {"E1_NATUREZ", SA1->A1_NATUREZ, nil } )
	aadd(aCpoSE1, {"E1_CLIENTE", SA1->A1_COD, nil } )
	aadd(aCpoSE1, {"E1_LOJA", SA1->A1_LOJA, nil } )
	aadd(aCpoSE1, {'E1_NUMBCO', "", nil } )
	aadd(aCpoSE1, {'E1_PLNUCOB', "", nil } )
	aadd(aCpoSE1, {'E1_ORIGEM', "A550", nil } )
    aadd(aCpoSE1, {'E1_LA', "", nil } )
	aadd(aCpoSE1, {"E1_VENCTO", dDataBase + nDiasVcto, nil } )
	aadd(aCpoSE1, {"E1_VENCREA", DataValida(dDataBase + nDiasVcto), nil } )
	aadd(aCpoSE1, {"E1_EMISSAO", dDataBase, nil } )
	aadd(aCpoSE1, {"E1_VALOR", nVlrGlosa, nil } )
	aadd(aCpoSE1, {"E1_SALDO", nVlrGlosa, nil } )
	aadd(aCpoSE1, {"E1_MULTNAT", "2", nil } )
	aadd(aCpoSE1, {'E1_APLVLMN', "1", nil } )

	aadd(aCpoSE1, {'E1_CODINT', cCodInt, nil } )
	aadd(aCpoSE1, {'E1_CODEMP', "", nil } )
	aadd(aCpoSE1, {'E1_MATRIC', "", nil } )
	aadd(aCpoSE1, {'E1_CODCOR', "", nil } )
	aadd(aCpoSE1, {"E1_ANOBASE", cAno, nil } )
	aadd(aCpoSE1, {"E1_MESBASE", cMes, nil } )

	// Monta array para geracao de NOTA                                    
	lErro := PLStoSe1(aCpoSE1,aBases,cMes,cAno,"PLSMPAG",lContabiliza,nil,nil,cPrefixo,nil,nil,nil,nil,nil,.T.)

    if ! lErro
        lRet := .t.
		nRecno := SE1->(recno())
    endIf

Endif

BA0->(DbSetOrder(nOrdBA0))
BA0->(DbGoTo(nRecBA0))
SA1->(DbSetOrder(nOrdSA1))
SA1->(DbGoto(nRecSA1))

Return( { lRet, cPrefixo, cNumero, "", cTipTit, nRecno } )

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluiCmp

@author    PLS TEAM
@version   V12
@since     16/10/2020
/*/
static function ExcluiCmp()

Local cChave := ""
Local cChaveNCC := ""
Local cTipo := ""
Local aRetorno := {.T.,.T.,.T.}
Local lRet := .F.
Local nRecOri := 0

Private lMsErroAuto := .F.

	If BTO->BTO_ARQPAR == '1'
		cChave := BTO->BTO_CHTIT1
		cChaveNCC := BTO->BTO_CHNCC1
		cTipo := "1"
	elseif BTO->BTO_ARQPAR == '2'
		cChave := BTO->BTO_CHTIT2
		cChaveNCC := BTO->BTO_CHNCC2
		cTipo := "2"
	else
		cChave := BTO->BTO_CHTITF
		cChaveNCC := BTO->BTO_CHNCCF
		cTipo := "F"
	endif

	SE1->(dbsetOrder(1))
	if SE1->(MsSeek(xFilial("SE1") + BTO->(BTO_PREFIX + BTO_NUMTIT + BTO_PARCEL + BTO_TIPTIT)))
		nRecOri := SE1->(Recno())
		aSE1 := {nRecOri}
		aRetorno[1] := lMsErroAuto
	endif

	if !empty(cChaveNCC) .AND. SE1->(MsSeek(xFilial("SE1") + cChaveNCC))
		nRecnoE1 := SE1->(Recno())
		aVetor := {	{"E1_FILIAL"      ,SE1->E1_FILIAL          ,Nil},;
					{"E1_NUM"         ,SE1->E1_NUM             ,Nil},;
					{"E1_PREFIXO"     ,SE1->E1_PREFIXO			,Nil},;
					{"E1_PARCELA"     ,SE1->E1_PARCELA			,Nil},;
					{"E1_TIPO"        ,SE1->E1_TIPO				,Nil},;
					{"E1_CLIENTE"     ,SE1->E1_CLIENTE			,Nil},;
					{"E1_LOJA"        ,SE1->E1_LOJA				,Nil}}

		aQry := RetExcCmp()
		aEstorno := {{aQry[1]}, aQry[2]}
		SE1->(dbgoto(aSE1[1]))
		SE5->(dbsetOrder(10))
		SE5->(MsSeek(xFilial('SE5') + AllTrim(aQry[2])))
		if !MaIntBxCR( 3 , aSE1,,,, {.F.,.F.,.F.,.F.,.F.,.F.},, aEstorno )
			lMsErroAuto := .T.
			MsgInfo("Não foi possível estornar a baixa")
		endif
		aRetorno[1] := lMsErroAuto

		SE1->(dbgoto(nRecnoE1))
		lMsErroAuto := .F.
		SE1->(dbgoto(nRecnoE1))
		MSExecAuto({|x,y| FINA040(x,y)},aVetor,5)
		aRetorno[2] := lMsErroAuto
		if lMsErroAuto
			MostraErro()
		endif
	elseif  lMV550NCC == .F.
		    aRetorno[2]:= .F.
	endif

	SE1->(dbsetOrder(1))
	if !aRetorno[1] .AND. !aRetorno[2] .AND. !empty(cChave) .AND. SE1->(MsSeek(xFilial("SE1") + cChave))

		aVetor := {	{"E1_FILIAL"      ,SE1->E1_FILIAL          ,Nil},;
					{"E1_NUM"         ,SE1->E1_NUM             ,Nil},;
					{"E1_PREFIXO"     ,SE1->E1_PREFIXO			,Nil},;
					{"E1_PARCELA"     ,SE1->E1_PARCELA			,Nil},;
					{"E1_TIPO"        ,SE1->E1_TIPO				,Nil},;
					{"E1_CLIENTE"     ,SE1->E1_CLIENTE			,Nil},;
					{"E1_LOJA"        ,SE1->E1_LOJA				,Nil}}
		lMsErroAuto := .F.
		MSExecAuto({|x,y| FINA040(x,y)},aVetor,5)
		aRetorno[3] := lMsErroAuto
		if lMsErroAuto
			MostraErro()
		endif
	endif

	BTO->(reclock("BTO", .F.))
	if !aRetorno[3]
		if cTipo == "1"
			if !aRetorno[3]
				BTO->BTO_CHTIT1 := ' '
			endif
			if !aRetorno[2]
				BTO->BTO_CHNCC1 := ' '
			endif
			if !aRetorno[1]
				BTO->BTO_VALOR1 := 0
			endif
		elseif cTipo == "2"
			if !aRetorno[3]
				BTO->BTO_CHTIT2 := ' '
			endif
			if !aRetorno[2]
				BTO->BTO_CHNCC2 := ' '
			endif
			if !aRetorno[1]
				BTO->BTO_VALOR2 := 0
			endif		
		else
			if !aRetorno[3]
				BTO->BTO_CHTITF := ' '
			endif
			if !aRetorno[2]
				BTO->BTO_CHNCCF := ' '
			endif
			if !aRetorno[1]
				BTO->BTO_VALORF := 0
			endif
		endif
		lRet := .T.
	endif
	BTO->(MsUnlock())

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} mArq560

@author    PLS TEAM
@version   V12
@since     16/10/2020
/*/
function mArq560()
local oObj      := PLSXmlPTU():New()
local cFileName := ""
local cNumFat 	:= "_______"
Local cChTit	:= ""
local nX 		:= 1
Local nRecnoEV := 0
Local aMsg := {}
Local cChvseek := ""
Local apergs := {}
Local aRet := {}
Local lret := .F.
Local cNumTit500 := BTO->(BTO_PREFIX+BTO_NUMTIT)
Local cMensagem := ""

do case
	case BTO->BTO_ARQPAR == '1'
		 cChvseek := BTO->BTO_CHTIT1
		 cChTit := alltrim(Substr(BTO->BTO_CHTIT1,4,7))
		 cTpArq := "2"

	case BTO->BTO_ARQPAR == '2'
		 cChvseek := BTO->BTO_CHTIT2
		 cChTit := alltrim(Substr(BTO->BTO_CHTIT2,4,7))
		 cTpArq := "2"
		 
	case BTO->BTO_ARQPAR == "0" .or. empty(BTO->BTO_ARQPAR)
		 cChvseek := BTO->BTO_CHTITF
		 cChTit := alltrim(Substr(BTO->BTO_CHTITF,4,7))

		//Se as parciais estiverem vazias é um arquivo integral.
		if BTO->BTO_NIV550  $ "3|4|5"
			cTpArq	:= "1"
		else
			cTpArq	:= "3"
		endif
endcase

if empty(cChTit)
	Msgalert("Não há arquivo a gerar para este registro")
	return
endif

aadd( aPergs,{ 2 , "Versão PTU:" , 1 , {"1=Atual","2=Antiga"} , 50 , "" , .F. } )
aadd( aPergs,{ 6 , "Caminho do Destino:",Space(50),"","","",50,.t.,,,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY  )})
if( paramBox( aPergs,"Parâmetros - Exportação PTU560 XML",@aRet,/*bOK*/,/*aButtons*/,.f.,/*nPosX*/,300,/*oDlgWizard*/,/*cLoad*/,/*lCanSave*/.t.,/*lUserSave*/.t. ) )
	lRet := .t.
	lVersAtual := iif(val(cvaltochar(aRet[1]))==1,.T.,.F.)
endif

if !lRet
	Msgalert("É necessário informar o caminho para geração do arquivo")
	return
endif

SE1->(dbsetOrder(1))

cNumFat += cChTit

if lPLSR506
	SE1->(MsSeek(xFilial("SE1") + BTO->BTO_PREFIX + BTO->BTO_NUMTIT + BTO->BTO_PARCEL + BTO->BTO_TIPTIT ))
	aNFE := execBlock("PLSR506",.F.,.F.,{"1"})
	if Len(aNFE) >= 3 .AND. !empty(aNFE[3])
		cNumTit500  := alltrim(  aNFE[3] )
	endif
endif

cFileName := "ND"+cTpArq+"_"+substr(cNumTit500,len(cNumTit500)-6,7)+iif(empty(BTO->BTO_ARQPAR) .or. BTO->BTO_ARQPAR == "0","","_"+BTO->BTO_ARQPAR)+"."+substr(BTO->BTO_CODOPE,2,3)

if SE1->(MsSeek(xfilial("SE1") + cChvseek))
	nRecnoEV := SE1->(recno())
endif

oObj:cLayPTU  := "A560"
oObj:cSchema  := "ptu_A560.xsd"
oObj:cSchmFolde	:= PLSMUDSIS(iif(lVersAtual == .T., "\plsptu\schemas\V1_1\","\plsptu\schemas\"))
oObj:cVersao := iif(lVersAtual ==.T., "V1_1","V1_0")
oObj:IniFile('ptuA560','ISO-8859-1') //Inicia arquivo
oObj:cFolder    := alltrim(aRet[2]) 


mCabec560(oObj,cTpArq) //Monta cabecalho

oObj:montaTag(1,'arquivoA560',nil,nil,.T.) //Body

mDoc560(oObj,nRecnoEV,cChTit,cNumTit500)
mdadUni560(oObj,.t.)
mdadUni560(oObj,.f.)

oObj:montaTag(1,'arquivoA560',nil,nil,.F.,.T.) //Finaliza Body    
oObj:CalcHash() //Calcula Hash
oObj:montaTag(1,'hash',oObj:cHashMD5,nil,nil,nil,nil,nil,.F. ) //Gera tag de Hash
oObj:montaTag(0,'ptuA560',nil,nil,.F.,.T.) //Finaliza arquivo
oObj:cFileName := cFileName

if !oObj:validXML()
	logErro(,oObj:cErroXML,oObj:cAvisoXML,cFileName)
	oObj:addCritica("Falha na estrutura. Verifique o arquivo: " + cFileName + ".log")
	cMensagem := "Falha na estrutura. Verifique o arquivo: " + cFileName + ".log"
else
	oObj:addCritica("Arquivo gerado: " + oObj:cFileName )
	cMensagem := "Arquivo gerado: " + oObj:cFileName
endif

oObj:geraXML(.t.,.t.)

for nX:=1 to len(oObj:aCriticas)
	aadd(aMsg,{BTO->BTO_OPEORI, BTO->BTO_NUMERO, oObj:aCriticas[nX][1]	})
next

MsgInfo(cMensagem)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} mCabec560

@author    PLS TEAM
@version   V12
@since     16/10/2020
/*/
static function mCabec560(oObj,cTpArq)

oObj:montaTag(1,'cabecalho',nil,nil,.T.)
oObj:montaTag(2,'nrVerTra_PTU',iif(lVersAtual,"02","01"),.T.)
oObj:montaTag(1,'unimed',nil,nil,.T.)
oObj:montaTag(3,'cd_Uni_Destino',BTO->BTO_OPEORI,.T.)
oObj:montaTag(3,'cd_Uni_Origem',BTO->BTO_CODOPE,.T.)
oObj:montaTag(2,'unimed',nil,nil,.F.,.T.)
oObj:montaTag(2,'tp_arquivoNDC',cTpArq,.T.)
oObj:montaTag(2,'tp_arq_parcial',iif(empty(BTO->BTO_ARQPAR) .or. BTO->BTO_ARQPAR == "0","",BTO->BTO_ARQPAR),.f.)
oObj:montaTag(1,'cabecalho',nil,nil,.F.,.T.)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} mDoc560

@author    PLS TEAM
@version   V12
@since     16/10/2020
/*/
static function mDoc560(oObj,nRecnoEV,cNumFat,cNumTit500)
local cLinhaEV := alltrim(&(getNewPar("MV_PLL5682", "'Cobranca referente a Contestacao da Fatura'")))
local cLinhaTX := alltrim(&(getNewPar("MV_PLL5681", "'Cobranca referente a Contestacao das Taxas'")))

if BTO->BTO_TPCOB == '3'
	oObj:montaTag(2,'Documento2',nil,nil,.T.)
else
	oObj:montaTag(2,'Documento1',nil,nil,.T.)
endif

SE1->(dbgoto(nRecnoEV))

oObj:montaTag(3,'nr_Doc_A500',alltrim(cNumTit500),.T.)
oObj:montaTag(3,'Nota_Debito',nil,nil,.T.)
oObj:montaTag(4,'nr_Nota_Debito',alltrim(SE1->E1_NUM),.T.)
oObj:montaTag(4,'dt_Emissao_NDC',dtos(SE1->E1_EMISSAO),.T.)
oObj:montaTag(4,'dt_Ven_NDC',dtos(SE1->E1_VENCTO),.T.)
oObj:montaTag(4,'vl_NDC',cvaltochar(SE1->E1_VALOR),.T.)
oObj:montaTag(4,'Linha',nil,nil,.T.)
oObj:montaTag(5,'nr_Linha',"1",.T.)
oObj:montaTag(5,'ds_linha',iif(BTO->BTO_TPCOB == '3',cLinhaTX,cLinhaEV),.T.)
oObj:montaTag(4,'Linha',nil,nil,.F.,.T.)
oObj:montaTag(3,'Nota_Debito',nil,nil,.F.,.T.)
oObj:montaTag(2,'Documento1',nil,nil,.F.,.T.)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} mdadUni560

@author    PLS TEAM
@version   V12
@since     16/10/2020
/*/
static function mdadUni560(oObj,lCredora)
local cAlias 	:= ""
local cTagPri	:= ""
local cTagNm 	:= ""

if !lCredora
	cAlias 	:= getBA0(BTO->BTO_OPEORI)
	
	cTagPri := "Dados_Devedora"
	cTagNm 	:= "nm_devedora"
else
	cAlias 	:= getBA0(BTO->BTO_CODOPE)
	
	cTagPri := "Dados_Credora"
	cTagNm 	:= "nm_credora"
endif

if !(cAlias)->(eof())
	oObj:montaTag(3,cTagPri,nil,nil,.T.)
	oObj:montaTag(4,cTagNm,alltrim((cAlias)->BA0_NOMINT),.T.)
	oObj:montaTag(4,'info_endereco',nil,nil,.T.)
	oObj:montaTag(5,'tp_logradouro',alltrim((cAlias)->(B18_CODEDI)),.T.)
	oObj:montaTag(5,'ds_lograd',alltrim((cAlias)->BA0_END),.T.)
	oObj:montaTag(5,'nr_lograd',alltrim(ifPls((cAlias)->BA0_NUMEND,"S/N")),.T.)
	oObj:montaTag(5,'compl_lograd',alltrim(((cAlias)->BA0_COMPEN)),.f.)
	oObj:montaTag(5,'ds_bairro',alltrim((cAlias)->BA0_BAIRRO),.f.)
	oObj:montaTag(5,'cd_munic',alltrim((cAlias)->BA0_CODMUN),.T.)
	oObj:montaTag(5,'nr_cep',alltrim((cAlias)->BA0_CEP),.T.)
	oObj:montaTag(4,'info_endereco',nil,nil,.F.,.T.)
	oObj:montaTag(4,'cpf_cnpj',nil,nil,.T.) 
	oObj:montaTag(5,iif(len(alltrim((cAlias)->BA0_CGC)) == 11,'cd_cpf','cd_cnpj'),alltrim((cAlias)->BA0_CGC),.T.)
	oObj:montaTag(4,'cpf_cnpj',nil,nil,.F.,.T.)
	oObj:montaTag(4,'telefone',nil,nil,.T.)
	oObj:montaTag(5,'tp_fone',"2",.T.)
	oObj:montaTag(5,'nr_ddd',alltrim((cAlias)->BA0_DDD),.T.)
	oObj:montaTag(5,'nr_fone',alltrim((cAlias)->BA0_TELEF1),.T.)
	oObj:montaTag(4,'telefone',nil,nil,.F.,.T.)

	oObj:montaTag(3,cTagPri,nil,nil,.F.,.T.)
endif

(cAlias)->(dbclosearea())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} getBA0

@author    PLS TEAM
@version   V12
@since     16/10/2020
/*/
static function getBA0(cCodOpe)
local cSql := ""
local cAliasBA0		:= getNextAlias()

cSql := " SELECT BA0_NOMINT, BA0_END, BA0_COMPEN, BA0_NUMEND, BA0_BAIRRO, BA0_CEP, BA0_CODMUN, BA0_EST, BA0_CGC, BA0_DDD, BA0_TELEF1, B18_CODEDI  "
cSql += " FROM " + retSqlName("BA0") + " BA0 "
cSql += " LEFT JOIN " + retSqlName("B18") + " B18 "
cSql += " ON B18_FILIAL = '" + xfilial("B18") + "' "
cSql += " AND B18_CODIGO = BA0_TIPLOG "
cSql += " AND B18.D_E_L_E_T_ = ' ' "
cSql += " WHERE BA0_FILIAL = '" + xfilial("BA0") + "' "
cSql += " AND BA0_CODIDE = '" + substr(cCodOpe,1,1) + "' "
cSql += " AND BA0_CODINT = '" + substr(cCodOpe,2,3) + "' "
cSql += " AND BA0.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasBA0,.F.,.T.)

return cAliasBA0

//-------------------------------------------------------------------
/*/{Protheus.doc} logErro

@author    PLS TEAM
@version   V12
@since     16/10/2020
/*/
static function logErro(aParam,cError,cAlert,cFileName)
local nArqLog := 0

nArqLog := fCreate( "c:\temp\" + cFileName + ".log",FC_NORMAL,,.F.)

fWrite( nArqLog, cError + CRLF + cAlert )

fClose( nArqLog )

return

//Busca o número do documento e sequencial para estornar a baixa pelas FKs
Static function RetExcCmp()

Local aRet := {}
Local cDoc := ""
Local cSeq := ""
Local cSql := ""

cSql += " Select distinct FK1_DOC, FK1_SEQ From " + RetSqlName("SE1") + " SE1 " 
cSql += " Inner Join " + retSqlName("FK7") + " FK7 "
cSql += " on "
cSql += " FK7_FILIAL = '" + xfilial("FK7") + "' AND "
cSql += " FK7_ALIAS = 'SE1' AND "
cSql += " FK7_CHAVE = '" + SE1->E1_FILIAL + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA + "' AND "
cSql += " FK7.D_E_L_E_T_ = ' ' "
cSql += " Inner Join " + retSqlName("FK1") + " FK1 "
cSql += " On "
cSql += " FK1_FILIAL = '" + xFilial("FK1") + "' AND "
cSql += " FK1_IDCOMP = FK7.FK7_IDDOC AND "
cSql += " FK1.D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"ExcCmp",.F.,.T.)

if !(ExcCmp->(EoF()))
	cDoc := ExcCmp->FK1_DOC
	cSeq := ExcCmp->FK1_SEQ
endif

ExcCmp->(dbclosearea())

aRet := {cDoc, cSeq}

return aRet


/*/{Protheus.doc} LimpVar()
	(Limpa variaveis)
	@author Thiago Rodrigues
	@since 27/07/2022
	@version version
	@param 
	@return
	/*/
Method LimpVar(nSomaAcordo) class PTUA550IMP
::nX 	:=0
::cPathQ := ""
::nQuest := 0
::cPathP := ""
::nQtdX  := 0
::nY     := 0
nSomaAcordo := 0
Return 


/*/{Protheus.doc} PtuCriaTit
	Criado para criar o titulo de forma separada da nota fiscal do fornecedor 
	e contestação normal
	@type  Static Function
	@author Thiago Rodrigues
	@since 24/08/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function PtuCriaTit(oPTU,nSomaAcordo,nValorPago)
Default nSomaAcordo := 0
Default nValorPago := 0

if !oPTU:lOrigem .AND. nSomaAcordo > 0 .AND. nValorPago < BTO->BTO_CUSTOT
	cAnoTit := SubStr(DtoS(dDataBase),1,4)
	cMesTit := SubStr(DtoS(dDataBase),5,2)
	aRetTit := CriaTITOpe(BTO->BTO_OPEORI,cAnoTit,cMesTit,nSomaAcordo,BTO->BTO_OPEORI, 1)
	if lMV550NCC
		aRetNCC := CriaTITOpe(BTO->BTO_OPEORI,cAnoTit,cMesTit,nSomaAcordo,BTO->BTO_OPEORI, 2)
	endif
	aParam  	:= { .f., .f., .f., .f., .f., .f. }
	aRecTit := {}
	
	cTipoArq := BTO->BTO_ARQPAR

	//Fazer os ifs pro campo certo, se parcial 1, parcial 2 ou fechamento
	BTO->(reclock("BTO",.F.))
		if cTipoArq == '1'
			BTO->BTO_CHTIT1 := aRetTit[2]  + aRetTit[3] + REPLICATE(' ',TamSX3("E1_PARCELA")[01]) + aRetTit[5]
			If lMV550NCC
				BTO->BTO_CHNCC1 := aRetNCC[2]  + aRetNCC[3] + REPLICATE(' ',TamSX3("E1_PARCELA")[01]) + aRetNCC[5]
			EndIf
			BTO->BTO_VALOR1 := nSomaAcordo
		elseif cTipoArq == '2'
			BTO->BTO_CHTIT2 := aRetTit[2]  + aRetTit[3] + REPLICATE(' ',TamSX3("E1_PARCELA")[01]) + aRetTit[5]
			If lMV550NCC
				BTO->BTO_CHNCC2 := aRetNCC[2]  + aRetNCC[3] + REPLICATE(' ',TamSX3("E1_PARCELA")[01]) + aRetNCC[5]
			EndIf
			BTO->BTO_VALOR2 := nSomaAcordo
		else
			BTO->BTO_CHTITF := aRetTit[2]  + aRetTit[3] + REPLICATE(' ',TamSX3("E1_PARCELA")[01]) + aRetTit[5]
			If lMV550NCC
				BTO->BTO_CHNCCF := aRetNCC[2]  + aRetNCC[3] + REPLICATE(' ',TamSX3("E1_PARCELA")[01]) + aRetNCC[5]
			EndIf
			BTO->BTO_VALORF := nSomaAcordo
		endif
	BTO->(MsUnlock())

	SE1->(dbsetOrder(1))
	if lMV550NCC .and. SE1->(MsSeek(xFilial("SE1") + BTO->(BTO_PREFIX+BTO_NUMTIT+BTO_PARCEL+BTO_TIPTIT) ))
		aRecTit := { SE1->(recno()) }
		lRet := maIntBxCR( 3, aRecTit, /*aBaixa*/, {aRetNCC[6]}, /*aLiquidacao*/, aParam,;
					/*bBlock*/,/*aEstorno*/,/*aSE1Dados*/,/*aNewSE1*/, /*nSaldo*/, /*aCpoUser*/,;
					/*aNCC_RAvlr*/, /*nSomaCheq*/, /*nTaxaCM*/, /*aTxMoeda*/, /*lConsdAbat*/, /*lRetLoja*/,;
					/*cProcComp*/ )

		if lRet .And. lHabMetric .and. lLibSupFw .and. lVrsAppSw 
			FWMetrics():addMetrics(FunName(), {{"totvs-saude-planos-protheus_utilizacao-de-ncc_total", 1 }} )
		endif
	endif
endif

Return 
