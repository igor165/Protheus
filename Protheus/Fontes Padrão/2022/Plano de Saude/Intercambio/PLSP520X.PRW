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

static cCodInt := ''

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSP500X
Importação do PTU A550 XML

@author    Lucas Nonato
@version   V12
@since     16/12/2020
/*/
function PLSP520X
local cGridFilter 	:= ""
local cCampos 		:= ""

B6T->(dbsetorder(1))
B2T->(dbsetorder(1))
B5T->(dbsetorder(1))

cCampos := iif(B6T->(fieldPos("B6T_VLT500")) <= 0, "B6T_VLT500,", "" )
cCampos += iif(B6T->(fieldPos("B6T_VLRTAX")) <= 0, "B6T_VLRTAX,", "" )
cCampos += iif(B6T->(fieldPos("B6T_IDUNIC")) <= 0, "B6T_IDUNIC,", "" )
cCampos += iif(B2T->(fieldPos("B2T_CMPLOT")) <= 0, "B2T_CMPLOT,", "" )
cCampos += iif(B2T->(fieldPos("B2T_ARQUIV")) <= 0, "B2T_ARQUIV,", "" )
cCampos += iif(B5T->(fieldPos("B5T_VLTXTT")) <= 0, "B5T_VLTXTT,", "" )

if !empty(cCampos)
	cCampos := substr(cCampos,1,len(cCampos)-1)
	aviso( "Atenção","Para a execução da rotina, é necessária a criação do(s) campo(s): " + cCampos ,{ "Ok" }, 2 )
	return
endIf

// abre a tela de filtro
cGridFilter := P520XFIL(.F.)
setKey(VK_F2 ,{|| cGridFilter := P520XFIL(.T.) })

oMBrwB2T:= FWMarkBrowse():New()
oMBrwB2T:SetAlias('B2T')
oMBrwB2T:SetDescription("Lotes de Aviso - Importação")
oMBrwB2T:SetMenuDef("PLSP520X")
oMBrwB2T:SetFieldMark( 'B2T_OK' )	
oMBrwB2T:SetAllMark({ ||  A270Inverte(oMBrwB2T, "B2T") })
oMBrwB2T:SetWalkThru(.F.)
oMBrwB2T:SetFilterDefault(cGridFilter)
oMBrwB2T:SetAmbiente(.F.)
oMBrwB2T:ForceQuitButton()
oMBrwB2T:Activate()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} P520PROC
Importação do PTU A500 XML

@author    Lucas Nonato
@version   V12
@since     06/08/2020
/*/
function P520PROC(cDir, cFileXML, aMsg)
local aNS       	:= {}
local oPTU      	:= PTUA500IMP():New()
local cUniOri 		:= ""
local cError 		:= ""
local cWarning 		:= ""
local lRet 			:= .t.
local lError		:= .f.
local nGuia			:= 0
local nI 			:= 0

private cNS     := ""
private oXML    := tXmlManager():New()

default aMsg := {}

cCodInt     := plsintpad()

oPTU:aMsg 	:= aClone(aMsg)

BAU->(dbSetOrder(7))

if !oXML:parseFile(cDir+cFileXML, @cError, @cWarning)
	oPTU:addMsg(cFileXML, "", cError)
	aMsg := aClone(oPTU:aMsg)
	return {lRet, cFileXML}
endif

aNS := oXML:XPathGetRootNsList()   

for nI := 1 to len(aNS)
	oXML:XPathRegisterNs( aNS[nI][1],aNS[nI][2] )
	cNS := aNS[nI][1]
	If oXML:XPathHasNode( addNs("/ptuA500") )
		exit
	EndIf
next nI

oPTU:cPathRaiz   := addNS("/ptuA500")
oPTU:cPath       := oPTU:cPathRaiz + addNS("/cabecalho")
 
// unimed
cUniOri 			:= StrZero(Val(oXML:XPathGetNodeValue( oPTU:cPath + addNS("/unimed/cd_Uni_Origem"))),4)

// cobranca
cNrComp 			:= oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosAvisoCobranca/Aviso/nr_Competencia"))
cDtGer				:= oXML:XPathGetNodeValue( oPTU:cPath + addNS("/dadosAvisoCobranca/Aviso/dt_Geracao"))

if empty(cNrComp)
	oPTU:addMsg(cFileXML, "", "Estrutura invalida.")
	lError := .t.	
endif

if !BAU->(msSeek(xFilial("BAU")+cUniOri))
	oPTU:addMsg(cFileXML, "", "RDA da operadora [" + cUniOri + "] não localizada.")
	lError := .t.
else
	aRet := PLSDADRDA(cCodInt,BAU->BAU_CODIGO)
	if !aRet[1]
		oPTU:addMsg(cFileXML, "", "RDA invalida [" + BAU->BAU_CODIGO + "] verifique o cadastro.")
		lError := .t.		
	endif
endif

cSql := " SELECT B2T_SEQLOT " 
cSql += " FROM " + RetSqlName("B2T") + " B2T "
cSql += " WHERE B2T_FILIAL = '" + xFilial("B2T") + "' "
cSql += " AND B2T_ARQUIV = '" + upper(cFileXML) + "' "
cSql += " AND B2T.D_E_L_E_T_ = ' '  "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPB2T",.F.,.T.)	

if TMPB2T->(!eof())
	oPTU:addMsg(cFileXML, "", "Arquivo ja importado no lote [" + TMPB2T->B2T_SEQLOT + "]")
	lError := .t.	
endif 
TMPB2T->(dbclosearea())
if lError
	aMsg := aClone(oPTU:aMsg)
	return {lRet, cFileXML}
endif

oPTU:cPathRaiz := oPTU:cPathRaiz + addNS("/arquivoA500/Tipoguia")

oPTU:nTotGuias := oXML:XPathChildCount( oPTU:cPathRaiz )

oProcess:SetRegua1( 4 ) //Alimenta a primeira barra de progresso
oProcess:SetRegua2( oPTU:nTotGuias ) //Alimenta a segunda barra de progresso

Begin Transaction

criaB2T(cUniOri,cDtGer,cNrComp,cFileXML)

oProcess:IncRegua1( "Processando Guias de Consulta"  )
oPTU:cPath := oPTU:cPathRaiz + addNS("/guiaConsulta")
if oXML:XPathHasNode( oPTU:cPath + "[1]" )
	gravaGuia(oPTU,oXML,GUIA_CONSULTA,@nGuia)
endif

oProcess:IncRegua1( "Processando Guias de SADT"  ) 
oPTU:cPath := oPTU:cPathRaiz + addNS("/guiaSADT")
if oXML:XPathHasNode( oPTU:cPath + "[1]" )
	gravaGuia(oPTU,oXML,GUIA_SADT,@nGuia)
endif

oProcess:IncRegua1( "Processando Guias de Internação"  ) 
oPTU:cPath := oPTU:cPathRaiz + addNS("/guiaInternacao")
if oXML:XPathHasNode( oPTU:cPath + "[1]" )
	gravaGuia(oPTU,oXML,GUIA_INTERNACAO,@nGuia)
endif

oProcess:IncRegua1( "Processando Guias de Honorario"  ) 
oPTU:cPath := oPTU:cPathRaiz + addNS("/guiaHonorarios")
if oXML:XPathHasNode( oPTU:cPath + "[1]" )
	gravaGuia(oPTU,oXML,GUIA_HONORARIO,@nGuia)
endif

End Transaction

oPTU:addMsg(cFileXML,, "Lote criado: " + B2T->B2T_SEQLOT,B2T->B2T_OPEORI)

aMsg := aClone(oPTU:aMsg)

return {lRet, cFileXML}

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
/*/{Protheus.doc} gravaGuia

@author  Lucas Nonato
@version P12
@since   15/12/2020
/*/
static function gravaGuia(oPTU,oXML,cTipGui,nGuia)
local cTag 		:= ""
local cTagTmp 	:= ""
local cCgc 		:= ""
local cDesc1	:= ""
local cDesc2	:= ""
local cNumDoc	:= ""
local cDoc		:= ""
local nY		:= 1
local nX		:= 1
local aRetDt	:= {}

while oPTU:hasNext(nX)
	cTag 	:= oPTU:cPathG
	nGuia++
	B5T->(reclock("B5T",.t.))
	B5T->B5T_FILIAL := xFilial( "B5T" )
	B5T->B5T_SEQLOT := B2T->B2T_SEQLOT
	B5T->B5T_SEQGUI := strzero(nGuia,3)
	B5T->B5T_TIPGUI := cTipGui
	B5T->B5T_OPEORI := B2T->B2T_OPEORI
	B5T->B5T_OPEHAB := B2T->B2T_OPEHAB
	B5T->B5T_NMGPRE := oXML:XPathGetNodeValue( cTag+addNS("/dadosGuia/nr_Guias/nr_GuiaTissPrestador" ))
	B5T->B5T_NUMLOT := oXML:XPathGetNodeValue( cTag+addNS("/dadosGuia/nr_LotePrestador" ))
	B5T->B5T_MATRIC := strzero(val(oXML:XPathGetNodeValue( cTag+addNS("/dadosBeneficiario/cd_Unimed"))),4) + oXML:XPathGetNodeValue( cTag+addNS("/dadosBeneficiario/id_Benef"))
	B5T->B5T_ATERNA := PLS0Or1(oXML:XPathGetNodeValue( cTag+addNS("/dadosBeneficiario/id_RN" )))
	B5T->B5T_NOMUSR := oXML:XPathGetNodeValue( cTag+addNS("/dadosBeneficiario/nm_Benef" ) ) 
	B5T->B5T_NOMEXE := oXML:XPathGetNodeValue( cTag+addNS("/dadosExecutante/nome"))
	B5T->B5T_CNESEX := oXML:XPathGetNodeValue( cTag+addNS("/dadosExecutante/CNES"))
	B5T->B5T_CBOS   := oXML:XPathGetNodeValue( cTag+addNS("/profissionalExecutante/CBO"))
	if cTipGui <> GUIA_INTERNACAO
		cCgc := ifPls(oXML:XPathGetNodeValue( cTag+addNS("/dadosExecutante/CPF_CNPJ/cd_cpf")),oXML:XPathGetNodeValue( cTag+addNS("/dadosExecutante/CPF_CNPJ/cd_cnpj")))
	else
		cCgc := oXML:XPathGetNodeValue( cTag+addNS("/dadosExecutante/cd_cnpj"))
	endif
	B5T->B5T_CGCEXE := cCgc
	B5T->B5T_TIPATE := oXML:XPathGetNodeValue( cTag+addNS("/dadosAtendimento/tp_Atendimento" ))
	B5T->B5T_INDACI := oXML:XPathGetNodeValue( cTag+addNS("/dadosAtendimento/tp_IndAcidente" ))		
	B5T->B5T_GUIORI := oXML:XPathGetNodeValue( cTag+addNS("/dadosGuia/nr_Guias/nr_GuaTissOperadora" ))		
	B5T->B5T_GUIINT := oXML:XPathGetNodeValue( cTag+addNS("/dadosGuia/nr_Guias/nr_GuaTissPrincipal" ))	
	B5T->B5T_DTDIGI := stod(oXML:XPathGetNodeValue( cTag+addNS("/dadosGuia/dt_Conhecimento" )))
	B5T->B5T_TIPADM := PLSVARVINC('23',, oXML:XPathGetNodeValue( cTag+addNS("/dadosAtendimento/caraterAtendimento" )))	
	B5T->B5T_SIGSOL := oXML:XPathGetNodeValue( cTag+addNS("/dadosSolicitante/profissional/dadosConselho/sg_Conselho"))
	B5T->B5T_REGSOL := oXML:XPathGetNodeValue( cTag+addNS("/dadosSolicitante/profissional/dadosConselho/nr_Conselho"))
	B5T->B5T_ESTSOL := PLSVARVINC('59', nil,oXML:XPathGetNodeValue( cTag+addNS("/dadosSolicitante/profissional/dadosConselho/UF")))	
	B5T->B5T_NOMSOL := oXML:XPathGetNodeValue( cTag+addNS("/dadosSolicitante/profissional/nm_Profissional"))

	cTagTmp := cTag + addNS("/complemento") 
	nY		:= 1
	cDesc1 	:= ""
	while oXML:XPathHasNode( cTagTmp + "[" + cvaltochar(nY) + "]" )
		cTagTmp := cTag + "[" + cvaltochar(nY) + "]"
		cDesc1 	+= alltrim(oXML:XPathGetNodeValue( cTagTmp+addNS("/nm_DescComplemento" )))				
		nY++
	enddo
	cDesc2 	:= substr(cDesc1,251,250)
	cDesc1 	:= substr(cDesc1,1,250)	

	B5T->B5T_INDCLI := cDesc1
	B5T->B5T_INDCL2 := cDesc2
	if cTipGui == GUIA_INTERNACAO
		B5T->B5T_CID    := oXML:XPathGetNodeValue( cTag+addNS("/dadosSaidaInternacao/CID" ))
		B5T->B5T_TIPALT := PLSVARVINC('39',,oXML:XPathGetNodeValue( cTagTmp+addNS("/dadosSaidaInternacao/mv_Encerramento" )))
		cTagTmp := cTag + addNS("/dadosInternacao" )
		aRetDt := retData(oXML:XPathGetNodeValue( cTagTmp+addNS("/dadosFaturamento/dt_IniFaturamento" )))	
		B5T->B5T_DTINIF := aRetDt[1]
		B5T->B5T_HRINIF := strtran(aRetDt[2],":","")
		aRetDt := retData(oXML:XPathGetNodeValue( cTagTmp+addNS("/dadosFaturamento/dt_FimFaturamento" )))
		B5T->B5T_DTFIMF := aRetDt[1]		
		B5T->B5T_HRFIMF := strtran(aRetDt[2],":","")
		B5T->B5T_TIPFAT := oXML:XPathGetNodeValue( cTagTmp+addNS("/dadosFaturamento/tp_Faturamento" ))
		B5T->B5T_GRPINT := oXML:XPathGetNodeValue( cTag+addNS("/dadosInternacao/tp_Internacao" ))
		B5T->B5T_REGINT := oXML:XPathGetNodeValue( cTag+addNS("/dadosInternacao/rg_Internacao" ))		
		nY := 1
		cTagTmp := cTagTmp + addNS("/dadosDeclaracoes" )
		if oXML:XPathHasNode( cTagTmp+"[1]" ) 
			B5T->B5T_CIDOBT := oXML:XPathGetNodeValue( cTagTmp+"[1]"+addNS("/CID_Obito" ))
			B5T->B5T_NRDCOB := oXML:XPathGetNodeValue( cTagTmp+"[1]"+addNS("/declaracao_Obito" ))	
				
			while oXML:XPathHasNode( cTagTmp+ "[" + cvaltochar(nY) + "]" ) 
				cDoc := oXML:XPathGetNodeValue( cTagTmp+ "[" + cvaltochar(nY) + "]" +addNS("/declaracao_Nascido" ))
				if !empty(cDoc)
					cNumDoc += iif(empty(cNumDoc),"",",") + cDoc
				endif
				nY++
			enddo
			if !empty(cNumDoc)
				B5T->B5T_NRDCNV := cNumDoc
			endif
		endif
	elseif cTipGui == GUIA_SADT
		B5T->B5T_TIPALT := PLSVARVINC('39',,oXML:XPathGetNodeValue( cTagTmp+addNS("/dadosAtendimento/mv_Encerramento" )))
	endif
	B5T->(msunlock())
	nX++
	gravaEvento(oPTU,oXML,cTipGui)

	cSql := " SELECT SUM(B6T_VLRPRO) AS VALOR, SUM(B6T_VLRTAX) AS TAXA "
	cSql += " FROM " + RetSQLName("B6T") + " B6T "
	cSql += " WHERE B6T_FILIAL = '" + xfilial("B6T") + "'   "
	cSql += " AND B6T_SEQLOT = '" + B5T->B5T_SEQLOT + "'   "
	cSql += " AND B6T_SEQGUI = '" + B5T->B5T_SEQGUI + "' "
	cSql += " AND B6T.D_E_L_E_T_ = ' '  "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"TrbB5T",.T.,.T.)	
	if !TrbB5T->(eof())
		B5T->(reclock("B5T",.f.))
		B5T->B5T_VLRTOT := TrbB5T->VALOR
		B5T->B5T_VLTXTT := TrbB5T->TAXA
		B5T->(msunlock())
	endif
	TrbB5T->(dbclosearea())
enddo

return

//-------------------------------------------------------------------
/*/{Protheus.doc} gravaEvento

@author  Lucas Nonato
@version P12
@since   15/12/2020
/*/
static function gravaEvento(oPTU,oXML,cTipGui)
local nValor	:= 0
local nVlrTax	:= 0
local cTag 		:= ""
local cTagOri 	:= ""
local cCodPad	:= ""
local cCodPro	:= ""
local cTagTmp 	:= ""
local cTagTmpTx	:= ""
local cCodVia	:= ""
local aRetDt	:= {}

oPTU:nX := 1

if cTipGui == GUIA_CONSULTA
	cTag 		:= oPTU:cPathG + addNS("/dadosGuia")
	cTagOri 	:= cTag
else
	cTag 		:= oPTU:cPathG + addNS("/dadosGuia/procedimentosExecutados")
	cTagOri 	:= cTag
endif

while oPTU:hasNextEv(@cTag,cTagOri)
	B6T->(reclock("B6T",.t.))
	B6T->B6T_FILIAL := xFilial( "B6T" )
	B6T->B6T_SEQLOT := B2T->B2T_SEQLOT
	B6T->B6T_SEQGUI := B5T->B5T_SEQGUI
	B6T->B6T_NUMLOT := B5T->B5T_NUMLOT 
	B6T->B6T_SEQUEN := strzero(oPTU:nX,4)
	B6T->B6T_SQTISS := oXML:XPathGetNodeValue( cTag+addNS("/procedimentos/seq_item" ))
	B6T->B6T_OPEORI := B5T->B5T_OPEORI
	B6T->B6T_OPEHAB := B5T->B5T_OPEHAB
	B6T->B6T_NMGPRE := B5T->B5T_NMGPRE
	B6T->B6T_MATRIC := B5T->B5T_MATRIC	
	cCodPad	:= oXML:XPathGetNodeValue( cTag+addNS("/procedimentos/tp_Tabela" ))
	cCodPro	:= oXML:XPathGetNodeValue( cTag+addNS("/procedimentos/cd_Servico"))
	if cCodPad == "00"
		cCodPro := substr(cCodPro,3)
	endif
	oPTU:dePara(@cCodPad,@cCodPro,.t.)
	B6T->B6T_CODPAD := cCodPad
	B6T->B6T_CODPRO := cCodPro
	B6T->B6T_DESPRO := oXML:XPathGetNodeValue( cTag+addNS("/ds_Servico" ))

	if cTipGui <> GUIA_HONORARIO .and. cTipGui <> GUIA_CONSULTA
		cTagTmp 	:= addNS("/valores")
		cTagTmpTx 	:= addNS("/taxas")
	elseif cTipGui == GUIA_CONSULTA
		cTagTmp 	:= addNS("/procedimentos")
		cTagTmpTx 	:= addNS("/procedimentos")		
	endif
	nValor := 0
	nValor += val(oXML:XPathGetNodeValue( cTag+cTagTmp+addNS("/vl_ServCobrado" )))
	nValor += val(oXML:XPathGetNodeValue( cTag+cTagTmp+addNS("/vl_CO_Cobrado"  )))
	nValor += val(oXML:XPathGetNodeValue( cTag+cTagTmp+addNS("/vl_FilmeCobrado")))

	nVlrTax := 0
	nVlrTax += val(oXML:XPathGetNodeValue( cTag+cTagTmpTx+addNS("/tx_AdmServico")))
	nVlrTax += val(oXML:XPathGetNodeValue( cTag+cTagTmpTx+addNS("/tx_AdmCO"  	)))
	nVlrTax += val(oXML:XPathGetNodeValue( cTag+cTagTmpTx+addNS("/tx_AdmFilme"  )))

	B6T->B6T_VLRPRO := nValor
	B6T->B6T_VLRTAX := nVlrTax
	B6T->B6T_IDUNIC := oXML:XPathGetNodeValue( cTag+addNS("/procedimentos/id_itemUnico" ))
	if cTipGui == GUIA_CONSULTA
		B6T->B6T_QTDPRO := 1
		aRetDt := retData(oXML:XPathGetNodeValue( cTag+addNS("/dt_Atendimento" )))	
		B6T->B6T_DATPRO := aRetDt[1]
		B6T->B6T_HORPRO := strtran(oXML:XPathGetNodeValue( cTag+addNS("/hr_Inicial")),":","")
	else
		B6T->B6T_QTDPRO := val(oXML:XPathGetNodeValue( cTag+addNS("/procedimentos/qt_Cobrada" )))
		B6T->B6T_DATPRO := stod(oXML:XPathGetNodeValue( cTag+addNS("/dt_Execucao" )))
		B6T->B6T_HORPRO := strtran(oXML:XPathGetNodeValue( cTag+addNS("/hr_Inicial")),":","")
	endif	
	
	B6T->B6T_HORFIM := strtran(oXML:XPathGetNodeValue( cTag+addNS("/hr_Final")),":","")
	
	B6T->B6T_TECUTI := oXML:XPathGetNodeValue( cTag+addNS("/tc_Utilizada"))
	cTagTmp := cTag+addNS("/via_Acesso")
	if oXML:XPathHasNode( cTagTmp )
		cTagTmp := oXML:XPathGetNodeValue( cTagTmp )
		BGR->(dbSetOrder(2))
		if BGR->(msSeek(xFilial("BGR")+cCodInt+StrZero(val(cTagTmp),1))) 
			cCodVia	:= BGR->BGR_CODVIA
		else
			BGR->(dbSetOrder(1))
			if BGR->(MsSeek(xFilial("BGR")+cCodInt+StrZero(val(cTagTmp),1))) 
				cCodVia	:= BGR->BGR_CODVIA
			endif
		endif
		B6T->B6T_VIA 	:= cCodVia
	endif
	
	B6T->(msunlock())
	if oXML:XPathHasNode(cTag+addNS("/equipe_Profissional[1]"))
		gravaBNT(oPTU,oXML,cTipGui)
	endif
	oPTU:nX++
enddo

return

//-------------------------------------------------------------------
/*/{Protheus.doc} gravaBNT

@author  Lucas Nonato
@version P12
@since   15/12/2020
/*/
static function gravaBNT(oPTU,oXML,cTipGui)
local cTag 	:= oPTU:cPathG + addNS("/dadosGuia/procedimentosExecutados/equipe_Profissional")
local nX 	:= 1
while oXML:XPathHasNode( cTag + "[" + cvaltochar(nX) + "]" )
	cTagTmp := cTag + "[" + cvaltochar(nX) + "]"
	BNT->(reclock("BNT",.t.))
	BNT->BNT_FILIAL := xfilial("BNT")
	BNT->BNT_SEQLOT := B6T->B6T_SEQLOT
	BNT->BNT_SEQGUI := B6T->B6T_SEQGUI
	BNT->BNT_SEQUEN := B6T->B6T_SEQUEN
	BNT->BNT_NUMLOT := B6T->B6T_NUMLOT 
	BNT->BNT_SEQEQU := strzero(nX,3)
	BNT->BNT_OPEORI := B6T->B6T_OPEORI
	BNT->BNT_OPEHAB := B6T->B6T_OPEHAB
	BNT->BNT_CODTPA := oXML:XPathGetNodeValue(cTagTmp+addNS("/tp_Participacao"))
	BNT->BNT_CGCPRE := oXML:XPathGetNodeValue(cTagTmp+addNS("/cd_cpf"))
	BNT->BNT_NOMPRE := oXML:XPathGetNodeValue(cTagTmp+addNS("/nm_Profissional"))
	BNT->BNT_SIGLA  := oXML:XPathGetNodeValue(cTagTmp+addNS("/dadosConselho/sg_Conselho"))
	BNT->BNT_REGPRE := oXML:XPathGetNodeValue(cTagTmp+addNS("/dadosConselho/nr_Conselho"))
	BNT->BNT_ESTPRE := PLSVARVINC('59', nil, oXML:XPathGetNodeValue(cTagTmp+addNS("/dadosConselho/UF")))
	BNT->BNT_CBOS   := oXML:XPathGetNodeValue(cTagTmp+addNS("/CBO"))
	BNT->(msunlock())	
	nX++
enddo

return

//-------------------------------------------------------------------
/*/{Protheus.doc} criaB2T

@author    Lucas Nonato
@version   V12
@since     15/12/2020
/*/
static function criaB2T(cUniOri,cDtGer,cNrComp,cFileXML)
local cSeqLote := GetSX8Num("B2T","B2T_SEQLOT")
	
B2T->(reclock("B2T",.t.))
B2T->B2T_FILIAL :=	xFilial( "B2T" )
B2T->B2T_SEQLOT :=	cSeqLote		 						 
B2T->B2T_STATUS :=	'1'									 	 
B2T->B2T_OPEORI :=	cUniOri						 	
B2T->B2T_OPEHAB :=	cCodInt
B2T->B2T_DATTRA :=	stod(cDtGer)
B2T->B2T_CMPLOT :=  cNrComp
B2T->B2T_ARQUIV :=  cFileXML
B2T->B2T_DATIMP :=	dDataBase 								 
B2T->B2T_HORIMP :=	strtran( alltrim(time()),":","" ) 		 
B2T->(msunlock())

B2T->(confirmSx8())

return

//-------------------------------------------------------------------
/*/{Protheus.doc} retData

@author    Lucas Nonato
@version   V12
@since     25/08/2020
/*/
static function retData(cData)
local aRet := array(2)

aRet[1] := stod(strtran(substr(cData,1,10),"/"))
aRet[2] := strtran(substr(cData,11,8),":","")
 
return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} menuDef
função para criar o menu da tela

@author    pablo alipio
@version   V12
@since     09/2020
/*/
static function menuDef()
private aRotina := {}

Add Option aRotina Title 'Importar Arquivo'		Action 'PLS500IMP(.t.)' 	Operation 3 Access 0 // Incluir
Add Option aRotina Title 'Visualizar'  			Action 'VIEWDEF.PLSP520X' 	Operation 2 Access 0 // Visualizar
Add Option aRotina Title 'Filtro(F2)'  			Action 'P520XFIL(.T.)' 		Operation 1 Access 0 // Filtro
ADD OPTION aRotina Title 'Excluir'				Action 'Processa({||P520XDEL(.f.)},"Lote de Aviso - Exclusao","Processando...",.T.)' 	OPERATION 5 ACCESS 0 //'Excluir'

return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view

@author  Guilherme Carvalho
@since   16/04/2018
@version P12
/*/
Static Function ViewDef()

Local oStruB2T := FWFormStruct( 2, 'B2T' ) 
Local oStruB5T := FWFormStruct( 2, 'B5T' )
Local oStruB6T := FWFormStruct( 2, 'B6T' )
Local oStruBNT := FWFormStruct( 2, 'BNT' )
Local oModel   := FWLoadModel( 'PLSP520' )
Local oView      

oView := FWFormView():New()
oView:SetModel( oModel )
nAcaoB2TView := 1
If nAcaoB2TView == 1

	//oView:AddField( 'VIEW_B2T', oStruB2T, 	'B2TMASTER' )
	oView:AddGrid( 'VIEW_B5T', 	oStruB5T, 	'B5TDETAIL' )
	oView:AddGrid( 'VIEW_B6T', 	oStruB6T, 	'B6TDETAIL' )
	oView:AddGrid( 'VIEW_BNT', 	oStruBNT, 	'BNTDETAIL' )
	
	//oView:EnableTitleView('VIEW_B2T','Lote') 
	oView:EnableTitleView('VIEW_B5T','Guias do Lote') 
	oView:EnableTitleView('VIEW_B6T','Eventos da Guia') 
	oView:EnableTitleView('VIEW_BNT','Equipe do Procedimento') 
	
	// Divide a tela em para conteúdo e rodapé
	//oView:CreateHorizontalBox( 'LOTE', 		15 )
	oView:CreateHorizontalBox( 'GUIAS', 	40 )
	oView:CreateHorizontalBox( 'EVENTOS', 	38 )
	oView:CreateHorizontalBox( 'EQUIPE', 	22 )
	
	//oView:SetOwnerView( 'VIEW_B2T', 'LOTE')   
	oView:SetOwnerView( 'VIEW_B5T', 'GUIAS')
	oView:SetOwnerView( 'VIEW_B6T', 'EVENTOS')
	oView:SetOwnerView( 'VIEW_BNT', 'EQUIPE')

	oView:SetViewProperty("VIEW_B5T", "GRIDSEEK", {.T.})
	oView:SetViewProperty("VIEW_B5T", "GRIDFILTER", {.T.})
Else

	oView:AddField( 'VIEW_B2T', oStruB2T, 'B2TMASTER' )
	oView:EnableTitleView('VIEW_B2T','Lote')
	oView:CreateHorizontalBox( 'LOTE', 100 )
	oView:SetOwnerView( 'VIEW_B2T', 'LOTE')
	
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define a model

@author  Guilherme Carvalho
@since   16/04/2018
@version P12
/*/
Static Function ModelDef()
                                         
Local oStruB2T := FWFormStruct( 1, 'B2T')
Local oStruB5T := FWFormStruct( 1, 'B5T')
Local oStruB6T := FWFormStruct( 1, 'B6T')
Local oStruBNT := FWFormStruct( 1, 'BNT')
Local oModel

oModel := MPFormModel():New( 'PLSP520MODEL',/*bPreValidacao*/,{|| P520VLDDEL(oModel)},/*bCommit*/, /*bCancel*/ )

// Monta a estrutura
oModel:AddFields( 'B2TMASTER', 				, oStruB2T)
oModel:AddGrid(   'B5TDETAIL', 	'B2TMASTER'	, oStruB5T)           
oModel:AddGrid(   'B6TDETAIL', 	'B5TDETAIL'	, oStruB6T)
oModel:AddGrid(   'BNTDETAIL', 	'B6TDETAIL'	, oStruBNT)  

// Descrições
oModel:SetDescription( 'Aviso Lote Guia' ) 
oModel:GetModel( 'B2TMASTER' ):SetDescription( 'Lote' ) 
oModel:GetModel( 'B5TDETAIL' ):SetDescription( 'Guias' ) 
oModel:GetModel( 'B6TDETAIL' ):SetDescription( 'Eventos' ) 
oModel:GetModel( 'BNTDETAIL' ):SetDescription( 'Equipe' ) 

oModel:SetRelation( 'B5TDETAIL', { 	{ 	'B5T_FILIAL', 'xFilial( "B5T" )' 	},;
									{ 	'B5T_SEQLOT', 'B2T_SEQLOT'   		}},; 
										'B5T_FILIAL+B5T_SEQLOT+B5T_SEQGUI' )
										
oModel:SetRelation( 'B6TDETAIL', { 	{ 	'B6T_FILIAL', 'xFilial( "B6T" )' 	},;
									{ 	'B6T_SEQLOT', 'B5T_SEQLOT'   		},;
									{ 	'B6T_SEQGUI', 'B5T_SEQGUI' 			}},;
										'B6T_FILIAL+B6T_SEQLOT+B6T_SEQGUI+B6T_SEQUEN' )
										
oModel:SetRelation( 'BNTDETAIL', { 	{ 	'BNT_FILIAL', 'xFilial( "BNT" )' 	},;
									{ 	'BNT_SEQLOT', 'B6T_SEQLOT'   		},;
									{ 	'BNT_SEQGUI', 'B6T_SEQGUI' 			},;
									{ 	'BNT_SEQUEN', 'B6T_SEQUEN' 			}},;
										'BNT_FILIAL+BNT_SEQLOT+BNT_SEQGUI+BNT_SEQUEN+BNT_SEQEQU' )										

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} P520VLDDEL
Valida a model

@author  Michel Montoro
@since   25/04/2018
@version P12
/*/
Function P520VLDDEL(oModel)                       
Local aArea 		:= GetArea()
Local nOperation 	:= oModel:GetOperation()
Local lRet			:= .T.		
Local cSql			:= ""	
	                                     
If nOperation == MODEL_OPERATION_DELETE
    
	// Verifica a Fase para exclusao.

	If B2T->B2T_STATUS <> "1"
		Help( ,, 'HELP',,"Permitido apenas excluir registros [1=Aviso Importado]", 1, 0) 
		lRet := .F.
	Endif 		

	cSql += " SELECT B6T_CHVPRO " 
	cSql += " FROM " + RetSqlName("B2T") + " B2T "
	cSql += " INNER JOIN " + RetSqlName("B6T") + " B6T " 
	cSql += "  ON B6T_FILIAL = B2T_FILIAL "
	cSql += "  AND B6T_OPEHAB = B2T_OPEHAB "
	cSql += "  AND B6T_NUMLOT = B2T_NUMLOT "
	cSql += "  AND B6T_LAPRO <> ' ' "
	cSql += "  AND B6T.D_E_L_E_T_ = ' ' "
	cSql += " WHERE B2T_FILIAL = '" + xfilial("B2T") + "' "
	cSql += "  AND B2T_OPEHAB = '" + B2T->B2T_OPEHAB + "' "
	cSql += "  AND B2T_NUMLOT = '" + B2T->B2T_NUMLOT + "' "
	cSql += "  AND B2T.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbExc",.F.,.T.)	
	if !TrbExc->(eof())	
		Help( ,, 'HELP',,"Registro já contabilizado. " + CRLF + " Exclua sua provisão para prosseguir! " + CRLF + " Chave:" +" '" + alltrim(TrbExc->B6T_CHVPRO) + "' ", 1, 0)  
		lRet := .F.
	endif	
	TrbExc->(dbclosearea())

	cSql += " SELECT B6T_SEQIMP " 
	cSql += " FROM " + RetSqlName("B2T") + " B2T "
	cSql += " INNER JOIN " + RetSqlName("B6T") + " B6T " 
	cSql += "  ON B6T_FILIAL = B2T_FILIAL "
	cSql += "  AND B6T_OPEHAB = B2T_OPEHAB "
	cSql += "  AND B6T_NUMLOT = B2T_NUMLOT "
	cSql += "  AND B6T_SEQIMP <> ' ' "
	cSql += "  AND B6T.D_E_L_E_T_ = ' ' "
	cSql += " WHERE B2T_FILIAL = '" + xfilial("B2T") + "' "
	cSql += "  AND B2T_OPEHAB = '" + B2T->B2T_OPEHAB + "' "
	cSql += "  AND B2T_NUMLOT = '" + B2T->B2T_NUMLOT + "' "
	cSql += "  AND B2T.D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbExc",.F.,.T.)	
	if !TrbExc->(eof())	
		Help( ,, 'HELP',,"Aviso com A500 importado. " + CRLF + " Chave:" +" '" + alltrim(TrbExc->B6T_SEQIMP) + "' ", 1, 0)  
		lRet := .F.
	endif	
	TrbExc->(dbclosearea())
Endif

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} P520XFIL
Filtro de tela

@author    Lucas Nonato
@version   V12
@since     26/01/2017
/*/
function P520XFIL(lF2)

local aPergs	:= {}
local aFilter	:= {}
local cFilter 	:= ""
local cOpeDe	:= space(4)
local cOpeAte	:= space(4)
default lF2  := .f.
aadd( aPergs,{ 1,"Operadora De:" , 	cOpeDe,"@!",'.T.','B39PLS',/*'.T.'*/,40,.f. } )
aadd( aPergs,{ 1,"Operadora Ate:", 	cOpeAte,"@!",'.T.','B39PLS',/*'.T.'*/,40,.t. } )
aAdd( aPergs,{ 1, "Data Imp De:" , 	dDataBase	, "", "", ""		, "", 50, .f.})
aAdd( aPergs,{ 1, "Data Imp Até:", 	dDataBase	, "", "", ""		, "", 50, .t.})

if( paramBox( aPergs,"Filtro de Tela",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSP520X',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
	cFilter += "@B2T_FILIAL = '" + xfilial("B2T") + "'"	
	cFilter += " AND B2T_OPEHAB >= '" + aFilter[1] + "'"	
	cFilter += " AND B2T_OPEHAB <= '" + aFilter[2] + "'"	
	cFilter += " AND B2T_DATIMP >= '" + dtos(aFilter[3]) + "'"	
	cFilter += " AND B2T_DATIMP <= '" + dtos(aFilter[4]) + "'"	
endIf

if lF2
	oMBrwB2T:SetFilterDefault(cFilter)
	oMBrwB2T:Refresh()
endif
	
return cFilter

//-------------------------------------------------------------------
/*/{Protheus.doc} P520XDEL

@author  Michel Montoro
@since   25/04/2018
@version P12
/*/
function P520XDEL(lAuto)
local cSql 		:= ""
local cChave 	:= ""
default lAuto 	:= .f.			

if !lAuto .and. !msgYesNo( "Deseja excluir os registros marcados da importação do lote de avisos?" ) 
	return .f.
endIf

cSql := " SELECT R_E_C_N_O_ RECNO " 
cSql += " FROM " + RetSqlName("B2T") + " B2T "
cSql += " WHERE B2T_FILIAL = '" + xFilial("B2T") + "' "
cSql += " AND B2T_OK = '" + oMBrwB2T:cMark + "' "
cSql += " AND B2T.D_E_L_E_T_ = ' '  "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"PLEXC",.F.,.T.)	

B2T->(dbsetorder(1)) // B2T_FILIAL, B2T_SEQLOT
B5T->(dbsetorder(4)) // B5T_FILIAL, B5T_SEQLOT
B6T->(dbsetorder(1)) // B6T_FILIAL, B6T_SEQLOT
BNT->(dbsetorder(1)) // BNT_FILIAL, BNT_SEQLOT

begin transaction

while !PLEXC->(eof())

	B2T->(dbgoto(PLEXC->RECNO))
	cChave := B2T->B2T_SEQLOT 

	// B2T	
	IncProc("Excluindo registros " + cvaltochar(B2T->(recno())))
	B2T->(RecLock('B2T',.F.))
		B2T->(DbDelete())
	B2T->(MsUnLock())
	

	// B5T
	while B5T->(MsSeek(xFilial('B5T') + cChave)) 
		IncProc("Excluindo registros " + cvaltochar(B5T->(recno())))
		B5T->(RecLock('B5T',.F.))
			B5T->(DbDelete())
		B5T->(MsUnLock())
	enddo

	// B6T
	while B6T->(MsSeek(xFilial('B6T') + cChave)) 
		IncProc("Excluindo registros " + cvaltochar(B6T->(recno())))
		B6T->(RecLock('B6T',.F.))
			B6T->(DbDelete())
		B6T->(MsUnLock())
	enddo

	// BNT
	while BNT->(MsSeek(xFilial('BNT') + cChave)) 
		IncProc("Excluindo registros " + cvaltochar(BNT->(recno())))
		BNT->(RecLock('BNT',.F.))
			BNT->(DbDelete())
		BNT->(MsUnLock())
	enddo

	PLEXC->(dbskip())

enddo

end transaction

PLEXC->(dbclosearea())

return
