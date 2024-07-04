#INCLUDE "PLSA720.ch"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE __aCdCri032 {"540",STR0001} //"Erro controlado SIGAPLS."
#DEFINE __aCdCri049 {"020",STR0002} //"O valor contratato e diferente do valor informado/apresentado."
#DEFINE __aCdCri051 {"025",STR0012} //"Para este procedimento necessita Auditoria."
#DEFINE __aCdCri070 {"536",STR0003} //"Existem campos obrigatorios que nao foram informados para esta GIH."
#DEFINE __aCdCri091 {"057",STR0007} //"Usuario importado invalido. Deve ser alterado o usuario para o correto ou glosada a nota."
#DEFINE __aCdCri097 {"061",STR0008} //"Glosa de taxa administrativa, devido a data limite para recebimento de faturas de intercambio."
#DEFINE __aCdCri109 {"066",STR0009} //"Evento de alto custo. O valor a ser cobrado/pago deve ser analisado."
#DEFINE __aCdCri110 {"067",STR0010} //"Evento de alto custo. NF de Entrada nao foi localizada. O valor a ser cobrado/pago deve ser atualizado manualmente."
#DEFINE __aCdCri111 {"068",STR0011} //"Evento de alto custo. Valor ja foi pago atraves da NF de Entrada."
#DEFINE __aCdCri166 {"094",STR0113} //"Incluido bloqueado pelo Resumo de internação"
#DEFINE __aCdCri169 {"097",STR0114} //"Bloqueio de pagamento e cobrança, participação não informada"
#DEFINE __aCdCri098 {"062","Procedimento não existente na liberação de origem."}
#DEFINE __aCdCri178 {"09E",STR0118} //"Bloqueio de pagamento ou exclusao da composicao ao negar sub-item."
#DEFINE __aCdCri179 {"09F",STR0119} //"Bloqueio de pagamento, composicao nao autorizada no Atendimento...... "
#DEFINE __aCdCri09Z {"09Z",STR0132} //"Guia Juridica - Esta guia não será submetida aos critérios de validação do sistema!"
#DEFINE __aCdCri226 {"591",STR0013} //"Bloq. em funcao de glosa pagto"
#DEFINE __aCdCri222 {"593",STR0140} //"Bloqueio de pagamento evento generico" 
#DEFINE __aCdCri223 {"590",STR0141} //"Unidade com bloqueio automático pela BD3."
#DEFINE __aCdCri227 {"592",STR0142} //"Bloqueio da cobranca da PF, porque o pagamento sera feito diretamente a RDA"
#DEFINE __aCdCri230 {"594","Unidade com vigência fechada BD4."} 
#DEFINE __aCdCri231 {"0A4","Redução de custo."} 
#DEFINE __aCdCri016 {"513","Rede de atendimento sem especialidade cadastrada"}
#DEFINE __aCdCri084 {"048","Local de Atendimento bloqueado para esta RDA."}
#DEFINE __aCdCri232 {"595","Unidade com bloqueio automático pela B4R (Exceçao de US)."} 
#DEFINE __aCdCri233 {"596","Bloqueio em função de todas as unidades estarem bloqueadas"}
#DEFINE __aCdCri234 {"597","Unidade não existe na composição do evento"} 
#DEFINE __aCdCri235 {"598","Bloqueio não definido no motivo de bloqueio"}

#DEFINE __cBLODES	__aCdCri109[1] + '|' + __aCdCri110[1] + '|' + __aCdCri111[1] + '|' + __aCdCri230[1] + '|' +;
					__aCdCri232[1] + '|' + __aCdCri223[1] + '|' + __aCdCri226[1] + '|' + __aCdCri178[1] + '|' +;
					__aCdCri169[1] + '|' + __aCdCri233[1] + '|' + __aCdCri227[1] + '|' + __aCdCri091[1] + '|' +;
					__aCdCri234[1]

#DEFINE VAR_CHAVE	1
#DEFINE VAR_STATUS	2     
#DEFINE VAR_COUNT	3
#DEFINE VAR_REG		4

#DEFINE K_Cancel   8
#DEFINE K_Bloqueio 9
#DEFINE K_Desbloq  10

#DEFINE MUDFASGUIA  "1"
#DEFINE MUDFASEPEG  "2"
#DEFINE RETORNAFASE "3"

#DEFINE DIGITACAO 	"1"
#DEFINE CONFERENC 	"2"
#DEFINE PRONTA 		"3"
#DEFINE FATURADA 	"4"

#DEFINE G_CONSULTA  "01"
#DEFINE G_SADT_ODON "02|13"
#DEFINE G_SOL_INTER "03"
#DEFINE G_REEMBOLSO "04"
#DEFINE G_RES_INTER "05"
#DEFINE G_HONORARIO "06"
#DEFINE G_ANEX_QUIM "07"
#DEFINE G_ANEX_RADI "08"
#DEFINE G_ANEX_OPME "09"
#DEFINE G_REC_GLOSA "10"
#DEFINE G_PROR_INTE "11"
#DEFINE G_SADT "02"
#DEFINE G_ODONTO "13"

STATIC aCampBD7  		:= {'BD7_VLRBPF','BD7_VLRBPR','BD7_VLRGLO','BD7_VLRMAN','BD7_VLRPAG','BD7_VLRTPF'}
STATIC aCampBD6  		:= {'BD6_VLRBPF','BD6_VLRBPR','BD6_VLRGLO','BD6_VLRMAN','BD6_VLRPAG','BD6_VLRPF','BD6_VLRTPF'}
STATIC aCpVrInfo 		:= LancFtCpo(1) // Info de valores de co-participacao
STATIC aTpVrInfo 		:= LancFtCpo(2) // Info de valores de taxa-copart
STATIC aCoVrInfo 		:= LancFtCpo(3) // Info de valores de custo operacional
STATIC aToVrInfo 		:= LancFtCpo(4) // Info de valores de taxa-custo
STATIC __aLanBXZ 		:= {}
STATIC __aLanFil 		:= {}
STATIC lMVPLFAUTP 		:= getNewPar("MV_PLFAUTP",.f.) //forca validacao na autp (plsxaut) caso o cabecalho da guia nao seja valida. Ex.: Usuario bloqueiado.
STATIC cMVPLSCPFB		:= getNewPar("MV_PLSCPFB","0")
STATIC cMVPLSCHMP		:= getNewPar("MV_PLSCHMP","HM,PPM,HMR")
STATIC cMVPLSCHMA		:= getNewPar("MV_PLSCHMA","PA,PAP,PAR")
STATIC lAnyGlosa		:= IsInCallStack('PLSA500RCB') .or. IsInCallStack('PLSA500GML') .or. IsInCallStack('PLSA500ACT')
STATIC lGlosa 			:= IsInCallStack('PLSA500RCB') .or. IsInCallStack('PLSA500GML')
STATIC aRetAnx			:= {}

Static lTempRDAMV := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} Z1PosTab
Posiciona tabelas
@author PLS TEAM
@since  03/07/2019
@version P12
/*/
Function Z1PosTab(oFila)

Local cCodOpe := PLSINTPAD() //'0001' //PLSINTPAD()
Local cAlias := ''
Local cOriMov := ''

BCL->(dbsetOrder(1))
BCI->(dbSetOrder(1))
BD5->(dbSetOrder(1))
BE4->(dbSetOrder(1))
BD6->(dbSetOrder(1))
BR8->(dbsetOrder(1))

BCL->(MsSeek(xfilial("BCL") + cCodOpe + oFila:cTipGui ))

If oFila:cTipGui == "05" .or. oFila:cTipGui == "03"
	cAlias := "BE4"
else
	cAlias := "BD5"
endIf

BCI->(Msseek(xfilial("BCI") + cCodOpe + oFila:cCodLdp + oFila:cCodPeg))

(cAlias)->(Msseek(xfilial(cAlias) + cCodOpe + oFila:cCodLdp + oFila:cCodPeg + oFila:cNumGui))

If cAlias == "BE4"
	cOriMov := BE4->BE4_ORIMOV
else
	cOriMov := BD5->BD5_ORIMOV
endIf

BD6->(Msseek(xfilial("BD6") + cCodOpe + oFila:cCodLdp + oFila:cCodPeg + oFila:cNumGui + cOriMov + oFila:cSequen))

BR8->(MsSeek(xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO)))
PLTmpMVZ1( AllTrim(BD6->BD6_CODRDA) $ GetNewPar("MV_PLFTMP", "") .OR. Upper(AllTrim(GetNewPar("MV_PLFTMP", ""))) == "ALL")
If BD6->BD6_FASE == "1" .and. (cAlias == "BD5" .or. cAlias == "BE4")
	Z1Evento(cAlias)
endIf

return

//-------------------------------------------------------------------
/*/{Protheus.doc} Z1Evento
Muda eventos
@author PLS TEAM
@since  03/07/2019
@version P12
/*/
static function Z1Evento(cAlias)
local cMatricUsr	:= ''
local cMatAnt		:= ''
local aRetCom		:= {}
local lValido 		:= .T.
local cNivel 		:= ""
local cChvNiv 		:= ""
local nI	:= 1
local nFor	:= 1
local aRetInt 	:= {} 
local cRegAte 	:= '' 
local cRegInt	:= '' 
local cPadInt	:= '' 
local cPadCon	:= '' 
local cTipAte	:= '' 
local cFinAte	:= '' 
local cAteRNA	:= '0'
local lAutori := .F. 
local cGrpInt := ""
local cChavLib := ""
local cGuiJur := ""
local cNumLBOR := ""
local aVldGen := {}
local cEspSol := ''
local cEspExe := ''
local aBD6	:= {}
local cTipPe := ""
local aBD7	:= {}
local aQtdBrow  := {}
local cCodRda 	:= '' 
local cCodLoc 	:= '' 
local cCodEsp	:= '' 
local aItensPac	:= {}
local nPos 		:= 0
local aItGeralPac := {}
local lNegProPac := .F.
local lCritIt := .f.
local cTabCrit := ""
local njx := 1
local cRdaEDI := '' 
local cFaces	:= '' 
local cDente	:= '' 
local aAreaBD6AX := {}
local aPrcsCir	:= { .F., {}}
local aVetAux  := {}
local cPortEve := ""
local nCompTmp := 1
local aAreaBR8AX := {}
local nCri := 0
local cUniAux		:= GetNewPar("MV_PLSCAUX","AUX")
local aAuxCBHPM := {}
local nTamFld  		:= TamSX3("BD4_PORMED")[1]
local nBDX_VLRPAG 	:= 0
local nBDX_VLRMAN 	:= 0
local nBDX_VLRBPR 	:= 0
local nBDX_VLRAPR 	:= 0
local nBDX_VLRGLO 	:= 0
local nBDX_PERGLO 	:= 0
local nBDX_VLRGTX 	:= 0
local nBDX_PERGTX 	:= 0
local nBDX_VLTXPG	:= 0
local nBDX_VLTXAP	:= 0
local cCodGlo		:= ''
local cTipoGuia := BD6->BD6_TIPGUI
local nInd := 1
local nC := 1
local aDadRDA := {}
local aDadUsr := {}
Local aDiarPre := {}
Local aDiarGui := {}
Local aDiarGlo := {}
Local apropac := {.F., ""}
local cMod			:= IIf(FindFunction("StrTPLS"),modulo11(StrTPLS(BD6->(BD6_CODOPE+BD6_CODEMP)) + "99999999"),modulo11(BD6->(BD6_CODOPE+BD6_CODEMP)) + "99999999")
local cMatrAntGen 	:= BD6->(BD6_CODOPE+BD6_CODEMP) + "99999999" + cMod
Local cNrAutOpe		:= ""
Local cNrAutEmp		:= ""


cMatricUsr	:= &(cAlias+"->("+cAlias+"_OPEUSR+"+cAlias+"_CODEMP+"+cAlias+"_MATRIC+"+cAlias+"_TIPREG+"+cAlias+"_DIGITO)")
cMatAnt		:= &(cAlias+"->("+cAlias+"_MATANT)")
cCodRda 	:= (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_CODRDA" )
cCodLoc 	:= (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_CODLOC" )
cCodEsp		:= (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_CODESP" )

aadd(aBD6,{ BD6->(recno()),BD6->BD6_SEQUEN,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_QTDPRO,BD6->BD6_HORPRO, BD6->BD6_FADENT,BD6->BD6_DENREG,{}})

plGetLib(BD6->BD6_TIPGUI, @cChavLib)
If cAlias == "BE4"
	PL720Arint(cChavLib,@aDiarPre,@aDiarGui,@aDiarGlo)
endIf

If cAlias == "BD5"
	cNrAutOpe		:= BD5->BD5_NRAOPE
	cNrAutEmp		:= BD5->BD5_NRAEMP
endif

aRetAux := PLSDADUSR(cMatricUsr,"1",.f., BD6->BD6_DATPRO, BD6->BD6_CODPAD, BD6->BD6_CODPRO, nil, nil)
if !aRetAux[1] .and. !empty(cMatAnt)
	aRetAux := PLSDADUSR(cMatAnt,"2",.f., BD6->BD6_DATPRO, BD6->BD6_CODPAD, BD6->BD6_CODPRO, nil, nil)
endif
aDadUsr := PLSGETUSR()
	
lValido := aRetAux[1]
if ! lValido
	cNivel 	:= 'BA1'
	cChvNiv := cMatricUsr
	arrayNormal(aclone(aRetAux[2]),@aRetcom)
//	aadd(aRetCom,aRetAux[2])
endIf

aRetAux := PLSDADRDA(BD6->BD6_OPEUSR, BD6->BD6_CODRDA, "1", BD6->BD6_DATPRO, cCodLoc, cCodEsp, BD6->BD6_CODPAD, BD6->BD6_CODPRO, aBD6)				
aDadRDA := PLSGETRDA()
lValido := aRetAux[1]

if ! lValido
	if len(aRetAux[2]) > 0

		for nFor := 1 To len(aRetAux[2])

			if aRetAux[2,nFor,1] $ __aCdCri016[1] + "|" + __aCdCri084[1]
			
				cNivel 	:= "BAU"
				cChvNiv := cCodRda
				arrayNormal(aclone(aRetAux[2]),@aRetcom)
				//aadd(aRetCom,aRetAux[2])
				
				lCrit513 := .t.
				lValido  := .t.
				exit
			endIf
		next nFor
	endIf
else
	aRetAux := {.T.,{},{}}			
endIf	

if ! lValido
	cNivel 	:= "BAU"
	cChvNiv := cCodRda
	arrayNormal(aclone(aRetAux[2]),@aRetcom)
	//aadd(aRetCom,aRetAux[2])
endIf

//"Usuario informado invalido
if allTrim(BD6->BD6_MATANT) == allTrim(cMatrAntGen) .or. allTrim(BD6->BD6_MATANT) == "99999999999999999"

	PLSPOSGLO(PLSINTPAD(),__aCdCri091[1],STR0007,"2")

	aadd(aRetCom,{__aCdCri091[1],STR0007,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,"",""}) //"Usuario informado invalido
	lValido :=.F.
endif


if lValido .and. ! lAutori

	aRetAux := PLSVLDFIN(cMatricUsr, BD6->BD6_DATPRO, BD6->BD6_CODPAD, BD6->BD6_CODPRO, '2', aDadUsr, nil)
	lValido := aRetAux[1]

	if ! lValido
		cNivel 	:= 'BA1'
		cChvNiv := cMatricUsr
		//aadd(aRetCom,aRetAux[2])
		arrayNormal(aclone(aRetAux[2]),@aRetcom)
	endIf
		
	aRetAux := PLSVLDCON(cMatricUsr, BD6->BD6_DATPRO, BD6->BD6_CODPAD, BD6->BD6_CODPRO, '2', BD6->BD6_DTDIGI, nil, BD6->BD6_CODRDA, nil/*dDatImp*/)
	lValido := aRetAux[1]

	if ! lValido
		cNivel 	:= 'BA1'
		cChvNiv := cMatricUsr
		arrayNormal(aclone(aRetAux[2]),@aRetcom)
		//aadd(aRetCom,aRetAux[2])
	endIf
endIf

if len(aDadUsr) > 1
	aRetInt 	:= retIntDAD(BD6->BD6_TIPGUI,aDadUsr)
	cRegAte 	:= aRetInt[1]
	cRegInt		:= aRetInt[2]
	cPadInt		:= aRetInt[3]
	cPadCon		:= aRetInt[4]
	cTipAte		:= aRetInt[5]
	cFinAte		:= aRetInt[6]
endif

if (cTipoGuia == G_SADT_ODON)
	cNumLBOR := (cAlias)->&( cAlias + "_CODOPE") + (cAlias)->&(cAlias + "_ANOAUT") + (cAlias)->&(cAlias + "_MESAUT") + (cAlias)->&(cAlias + "_NUMAUT")
endif

if (BCL->BCL_ALIAS)->( fieldPos( BCL->BCL_ALIAS + "_ATERNA" ) ) > 0
	cAteRNA := (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_ATERNA" )
endIf

if cTipoGuia $ G_SOL_INTER + "|" + G_RES_INTER + "|" + G_HONORARIO .and. (BCL->BCL_ALIAS)->( fieldPos( BCL->BCL_ALIAS + "_GRPINT" ) ) > 0 .and. (BCL->BCL_ALIAS)->( fieldPos( BCL->BCL_ALIAS + "_TIPINT" ) ) > 0
	cGrpInt := (cAlias)->&( cAlias + "_GRPINT" ) + (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_TIPINT" )
endIf

// Guia Juridica.
if (cAlias)->( fieldPos( cAlias + "_GUIJUR" ) ) > 0

	cGuiJur := (cAlias)->&( cAlias + "_GUIJUR" )

	if cGuiJur == "1"
		// Se a critica estiver desabilitada, despresa o conteudo da guia juridica e realiza as criticas.
		if ! PLSPOSGLO(PLSINTPAD(),__aCdCri09Z[1],__aCdCri09Z[2],"1")
			cGuiJur := ""
		endIf
	endIf
endIf

cRdaEDI := BD6->BD6_RDAEDI
cFaces	:= BD6->BD6_FADENT
cDente	:= BD6->BD6_DENREG

// retorna as criticas da guia no momento da autorizacao
cAliasCab := iIf(cTipoGuia $ G_CONSULTA + "|" + G_SADT_ODON ,'BEA', "")

if ! empty(cAliasCab) .and. ! empty(cChavLib)
	aMatCri := PLSGETCRI(cAliasCab,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO),BD6->BD6_SEQUEN,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_QTDPRO)
endIf

if BD6->BD6_TIPGUI $ ( G_RES_INTER + '|' + G_HONORARIO ) .or. BD6->BD6_CONMUS == '0'
	aVldGen := { .f.,.f.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.}
endIf

//Armazena as variaveis de especialidade dos profissionais
cEspSol := BD6->BD6_ESPSOL
cEspExe	:= BD6->BD6_ESPEXE

plTRBBD7("TRBBD7", BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, BD6->BD6_ORIMOV, BD6->BD6_SEQUEN)

if ! TRBBD7->(eof())		

	while ! TRBBD7->(eof())

		BD7->( dbGoTo( TRBBD7->REC ) )

		if empty(cTipPe)

			aAreaBAU := BAU->(getArea())

			BAU->( dbSetOrder(1) )
			BAU->( msSeek(xFilial("BAU") + BD7->BD7_CODRDA ) )

			cTipPe := BAU->BAU_TIPPE
			BAU->(restArea(aAreaBAU))
		endIf

		//eu pego a especialidade do BD7_CODESP pois nem sempre no xml vem a especialidade do executante dai la no xaut ele so tava tratando o contratado		   	   															
		aadd(aBd7,{	BD7->BD7_CODUNM} )																																						//[1] - UNIDADE									
		aadd(aBd7[len(aBd7)],{BD7->BD7_CODRDA,iIf(empty(BD7->BD7_CODESP),BD6->BD6_CODESP,BD7->BD7_CODESP),iIf(empty(BD7->BD7_CODLOC),BD6->BD6_CODLOC,BD7->BD7_CODLOC) ,cTipPe  ,	'C'}) 	//[4] - CONTRATADO e ESPECIALIDADE e local e TIPO F/J
		aadd(aBd7[len(aBd7)],{BD7->BD7_CDPFPR,iIf(empty(BD7->BD7_ESPEXE),BD7->BD7_CODESP,BD7->BD7_ESPEXE),''			   											  ,'F'	   ,	'E'})	//[2] - EXECUTANTE e ESPECIALIDADE E local (ainda nao existe local do executante, na tiss 3.0 vai ter) e TIPO F/J
		aadd(aBd7[len(aBd7)],{BD6->BD6_CDPFSO,iIf(empty(BD7->BD7_ESPSOL),BD7->BD7_CODESP,BD7->BD7_ESPSOL),''			   											  ,'F'	   ,	'S'})	//[3] - SOLICITANTE e ESPECIALIDADE E local (ainda nao existe local do solicitante, na tiss 3.0 vai ter) e TIPO F/J

	TRBBD7->(dbSkip())
	endDo

	aBD6[ len(aBD6), 9 ] := aClone(aBD7)
endIf		
TRBBD7->(dbCloseArea())

aadd(aQtdBrow,{	aBD6[1][3],;		//[01] - BD6_CODPAD
				aBD6[1][4],;		//[02] - BD6_CODPRO
				aBD6[1][5],;		//[03] - BD6_QTDPRO
				BD6->BD6_DATPRO,;	//[04] - BD6_DATPRO
				aBD6[1][6],;		//[05] - BD6_HORPRO
				aBD6[1][8],;		//[06] - BD6_DENREG
				aBD6[1][7],;		//[07] - BD6_FADENT
				aBD6[1][2] })	    //[08] - BD6_SEQUEN

if BD6->BD6_GUIACO <> "1" .or. BD6->BD6_PAGATO == "1"
	if ! lAutori
		apropac 	:= plspropacM()
		cTabCrit 	:= apropac[2]
		lNegProPac 	:= apropac[1]
	
		aRetAux := PLSAUTP(	iIf(! empty(BD6->BD6_DATPRO),BD6->BD6_DATPRO,&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_DATPRO")),;
						iIf(! empty(BD6->BD6_HORPRO),BD6->BD6_HORPRO,&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_HORPRO")),;
						BD6->BD6_CODPAD,;
						BD6->BD6_CODPRO,;
						iIf(BD6->BD6_QTDDEN > 0,BD6->BD6_QTDPRO/BD6->BD6_QTDDEN,BD6->BD6_QTDPRO),;
						aDadUsr,;
						BD6->(recno()),;
						aDadRDA,;
						"1",;
						.t.,;
						&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_CID"),;
						.t.,;
						"2",;
						.F.,;
						&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_OPESOL"),;
						&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_CDPFSO"),;
						BD6->BD6_ANOPAG,;
						BD6->BD6_MESPAG,;
						cPadInt,;
						cPadCon,;
						cRegAte,;
						nil,;
						BD6->BD6_CDPFRE,;
						BD6->BD6_PROREL,;
						BD6->BD6_PRPRRL,;
						BD6->BD6_OPEEXE,;
						nil,;
						cAteRNA,;
						cNrAutOpe,;
						cNrAutEmp,;
						BD6->BD6_SEQUEN,;
						BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN),;
						.f.,; // 33 lRegPagAto
						"1",;
						cFaces,;
						.t.,; //lMudaFase
						&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_SENHA"),;
						nil,;
						cGrpInt,;
						nil,;
						cRdaEDI,;
						cChavLib,;
						nil,;
						aDiarGui,;
						aDiarPre,;
						cDente,;
						nil,;
						nil,;
						.t.,;
						.f.,; //50 lTratPagRda
						iIf(!lAutori,'E','S'),;//cTipoProc
						BD6->BD6_CODESP,;
						aQtdBrow,;
						aVldGen,;
						BD6->BD6_CODLOC,;
						BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN),;
						nil,;
						nil,;
						nil,;
						nil,;
						cRegInt,;
						cTipAte,;
						lNegProPac,;
						nil,;
						cFinAte,;
						nil,;
						nil,;
						cGuiJur,;
						aBd7,;
						cEspSol,;
						cEspExe,;
						&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_DATPRO"),;
						nil,;
						BD6->BD6_TIPGUI,;
						nil,;
						nil,;
						nil,;
						nil,;
						nil,;
						nil,;
						nil,;
						cTabCrit,;
						nil,;
						aDiarGlo,;
						nil,;
						nil,;
						nil,;
						nil,;
						cNumLBOR,;
						nil,;
						nil,;
						nil,;
						nil,;
						nil,;
						Alltrim(BD6->BD6_NRAOPE))
	else
		aRetAux := { .t., "", cAliasCab, BD6->(BD6_CODPAD+BD6_CODPRO) }
	endIf
	if valType(aRetAux[2]) == "A"
		cAuditoria := iIf(ascan( aRetAux[2],{|x| x[1] == "025" } ) > 0, "1", "0")
	else
		cAuditoria := ""
	endIf

	if len(aRetAux) >= 3 .and. valType(aRetAux[3]) == "C"
		cNivel  := aRetAux[3]
	else
		cNivel  := ""
	endIf

	if len(aRetAux) >= 4

		BD6->(recLock("BD6",.f.))

			if aRetAux[1]
				BD6->BD6_NIVAUT := cNivel
				BD6->BD6_NIVCRI := ""
			else
				BD6->BD6_NIVAUT := ""
				BD6->BD6_NIVCRI := cNivel
			endIf

			BD6->BD6_CHVNIV := if(len(aRetAux) >= 4 .and. valType(aRetAux[4]) == "C",aRetAux[4],"")

		BD6->(msUnLock())

		if ! aRetAux[1]

			if len(aRetAux[2]) > 0 .and. valType(aRetAux[2]) == 'A'
				arrayNormal(aclone(aRetAux[2]),@aRetcom)
				//For nCri := 1 To Len(aretAux[2])
				//	aadd(aRetCom,aRetAux[2][nCri])
				//Next
			endIf
		endIf
	endIf
endIf
If GetNewPar("MV_PLCAAUX","1") == "3"// item (BR8->BR8_TIPEVE == "2")adicionado para que que ele vao vá ao while de bd6 e perca performane

	aAreaBD6AX := BD6->(getarea())
	aAreaBR8AX := BR8->(getArea())
	BD6->(dbSetOrder(1)) //BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
	BR8->(dbSetOrder(1))

	If BD6->(msSeek(BCI->(BCI_FILIAL+BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)))
		nRecBD6 := BD6->(Recno())

		//Procuro nos itens gravados da guia
		While !BD6->(Eof()) .And. BCI->(BCI_FILIAL+BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) == BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG)

			If BR8->(MsSeek(xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO))) .And. BR8->BR8_TIPEVE == "2" //Evento cirurgico

				aVetAux  := {}
				cPortEve := ""
				aCompTmp := PLSCOMEVE(BD6->BD6_CODTAB,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODOPE,BD6->BD6_DATPRO)//Carrego a composicao do evento

				For nCompTmp := 1 TO Len(aCompTmp)

					If aCompTmp[nCompTmp,1] == cUniAux//Guardo os auxilizares encontrados na composicao
						aAdd(aVetAux,{aCompTmp[nCompTmp,1],aCompTmp[nCompTmp,2],aCompTmp[nCompTmp,3],aCompTmp[nCompTmp,15]})//{AUX,Ordem,Referencia(1o,2o,...),CodTab}
					EndIf

					If aCompTmp[nCompTmp,1] == "PPM"
						cPortEve := aCompTmp[nCompTmp,12]
					EndIf

				Next nCompTmp

				//Monto a matriz de procedimentos cirurgicos com auxiliares
				If Len(aVetAux) > 0

					aAdd(aPrcsCir[2],{BR8->BR8_CODPAD,BR8->BR8_CODPSA,BD6->BD6_CODOPE,BD6->BD6_DATPRO,AllTrim(Replicate("0",nTamFld-Len(AllTrim(cPortEve))) + cPortEve),aClone(aVetAux),BD6->(RECNO())})//{CodPad,CodPro,CodOpe,DatPro,Porte,aVetAux}
					aAdd( aAuxCBHPM, {BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO), BD6->BD6_DATPRO, aClone(aPrcsCir), aClone(aCompTmp), cPortEve})

					aPrcsCir := {.F., {}}
					aVetAux	 := {}
				EndIf	

			EndIf

			BD6->(dbSkip())

		EndDo

		If !(empTy(aAuxCBHPM))
			ASORT(aAuxCBHPM, , , { | x,y | x[5] > y[5] } )
		EndIf
	EndIf
	BD6->(restarea(aAreaBD6AX))
	BR8->(restArea(aAreaBR8AX))
endIf

aRetAux := ProcEvento(BD6->BD6_TIPGUI,nil,.F.,BD6->BD6_ANOPAG,; //4
						BD6->BD6_MESPAG,cAlias,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV),; //7
						aDadUsr,"2",aDadRda/* 10 */,.T.,nil,.T.,.F.,nil,nil,nil,aRetCom,,,,,;
						cChavLib,cAuditoria == '1', .t., nil, nil, @aAuxCBHPM)

If Len(aRetCom) > 0
	aRetAux[1] := .F.
	for nI := 1 to Len(aRetcom)
		If Valtype(aRetcom[nI][1]) == "A"
			For nC := 1 to Len(aRetcom[nI])
				aadd(aRetAux[2], aretcom[nI][nC])
			next
		else
			aadd(aRetAux[2], aretcom[nI])
		endIf
	Next
endIf

If lTempRDAMV
    cNextFase := PRONTA
else
    If aRetAux[1]
        cNextFase := PRONTA
    else
        cNextFase := CONFERENC
    endIf
endIf

BD6->(RecLock("BD6", .F.))
	BD6->BD6_FASE := cNextFase
	BD6->BD6_DTANAL := dDataBase
BD6->(MsUnLock())

aBDXSeAnGl := aclone(aRetAux[3])

if ! aBDXSeAnGl[1] 

	for nInd := 1 to len(aBDXSeAnGl[2])

		if ! empty(aBDXSeAnGl[2][nInd][1]) .and. aBDXSeAnGl[2][nInd][1] <> cCodGlo
			cCodGlo := aBDXSeAnGl[2][nInd][1]
		endIf

		cCodPad := aBDXSeAnGl[2][nInd][6]
		cCodPro := aBDXSeAnGl[2][nInd][7]

		if len(aBDXSeAnGl[2][nInd]) >= 8
			cSequen := aBDXSeAnGl[2][nInd][8]
		else
			cSequen := ""
		endIf

		if len(aBDXSeAnGl[2][nInd]) >= 9
			cDesPro := aBDXSeAnGl[2][nInd][9]
		else
			cDesPro := BR8->(Posicione("BR8",1,xFilial("BR8")+cCodPad+cCodPro,"BR8_DESCRI"))
		endIf

		BDX->(recLock("BDX",.t.))

			BDX->BDX_FILIAL := xFilial("BDX")
			BDX->BDX_IMGSTA := "BR_VERMELHO"

			BDX->BDX_CODOPE := (cAlias)->&( cAlias + "_CODOPE" )
			BDX->BDX_CODLDP := (cAlias)->&( cAlias + "_CODLDP" )
			BDX->BDX_CODPEG := (cAlias)->&( cAlias + "_CODPEG" )
			BDX->BDX_NUMERO := (cAlias)->&( cAlias + "_NUMERO" )
			BDX->BDX_ORIMOV := (cAlias)->&( cAlias + "_ORIMOV" )

			BDX->BDX_NIVEL  := iIf( ! empty(aBDXSeAnGl[2][nInd][1]),'1','')
			BDX->BDX_CODPAD := iIf( empty(cCodPad), BD6->BD6_CODPAD, cCodPad)
			BDX->BDX_CODPRO := iIf( empty(cCodPro), BD6->BD6_CODPRO, cCodPro)
			BDX->BDX_DESPRO := iIf( empty(cDesPro), BD6->BD6_DESPRO, cDesPro)
			BDX->BDX_SEQUEN := iIf( empty(cSequen), BD6->BD6_SEQUEN, cSequen)
			BDX->BDX_CODGLO := cCodGlo
			BDX->BDX_GLOSIS := cCodGlo
			BDX->BDX_DESGLO := aBDXSeAnGl[2][nInd][2]
			BDX->BDX_INFGLO := aBDXSeAnGl[2][nInd][3]

			//1=Eletronica;2=Manual;3=Automatica
			BDX->BDX_TIPGLO := '3'
			BDX->BDX_DTACAO := date()

			//1=Principal;2=Descritivos
			BDX->BDX_TIPREG := iIf( empty(BDX->BDX_NIVEL), '2', '1')

			if BDX->BDX_TIPREG == '1'

				BDX->BDX_PERGLO := ( BD6->BD6_VLRGLO / ( BD6->BD6_VLRMAN + BD6->BD6_VLRGLO ) ) * 100
				BDX->BDX_VLRGLO := BD6->BD6_VLRGLO

				BDX->BDX_PERGTX := ( BD6->BD6_VLRGTX / ( BD6->BD6_VLTXPG + BD6->BD6_VLRGTX ) ) * 100
				BDX->BDX_VLRGTX := BD6->BD6_VLRGTX

				BDX->BDX_VLTXPG := BD6->BD6_VLTXPG
				BDX->BDX_VLTXAP := BD6->BD6_VLTXAP

				BDX->BDX_RESPAL := ""

				BDX->BDX_VLRPAG := BD6->BD6_VLRPAG
				BDX->BDX_VLRMAN := BD6->BD6_VLRMAN
				BDX->BDX_VLRBPR := BD6->BD6_VLRBPR
				BDX->BDX_VLRAPR := BD6->BD6_VALORI
				BDX->BDX_QTDPRO := BD6->BD6_QTDPRO
				BDX->BDX_DATPRO := BD6->BD6_DATPRO

			endIf

			BDX->BDX_ACAO 	:= iIf( BDX->BDX_PERGLO == 100 .and. BDX->BDX_VLRGLO == 0, '2', '1' )
			BDX->BDX_ACAOTX := iIf( BDX->BDX_PERGTX == 100 .and. BDX->BDX_VLRGTX == 0, '2', '1' )
			BDX->BDX_CRIANA	:= '1'

			if getNewPar("MV_PLSREGL",.f.)

				if BDX->BDX_TIPREG == '1'
					BDX->BDX_VLRAP2 := BDX->BDX_VLRAPR
					BDX->BDX_PERGL2 := BDX->BDX_PERGLO
					BDX->BDX_VLRGL2 := BDX->BDX_VLRGLO
				endIf

			endIf

		BDX->(msUnLock())
	next

	aBDXSeAnGl[1] := .f.
	aBDXSeAnGl[2] := {}

endIf

BD7->(dbSetOrder(1))
BD6->(dbSetOrder(1))
aCriticas := IIF(LEN(aRetAux[2])>0,aRetAux[2],{})
cNumGuia := BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)
lValido := .T.
nPos := 0

plTRBBD7("TRBBD7", subStr(cNumGuia,1,4), subStr(cNumGuia,5,4), subStr(cNumGuia,9,8), subStr(cNumGuia,17,8), subStr(cNumGuia,25,1), BD6->BD6_SEQUEN)

while ! TRBBD7->(eof())

	BD7->( dbGoTo( TRBBD7->REC ) )

	BD7->(recLock("BD7",.f.))

		BD7->BD7_FASE := cNextFase

		if cNextFase = PRONTA

			BD7->BD7_DTANAL := dDataBase

			if empty(BD7->BD7_DTCTBF)
				BD7->BD7_DTCTBF := iIf(empty(BD7->BD7_LAPRO),BD7->BD7_DTDIGI,date())	
			endIf

		endIf

	BD7->(msUnLock())

TRBBD7->(dbSkip())
endDo

TRBBD7->(dbCloseArea())

BCT->(dbSetOrder(1))

// atualiza as glosas sugeridas pelo sistema...
for nFor := 1 to len(aCriticas)

	// Analisa cada procedimento com a respectiva glosa...
	cCodGlo := aCriticas[nFor,1]
	cCodPad := BD6->BD6_CODPAD //aCriticas[nFor,6]
	cCodPro := BD6->BD6_CODPRO //aCriticas[nFor,7]

	if empty(cCodGlo)
		loop
	endIf

	BCT->( msSeek(xfilial("BCT") + BD6->BD6_CODOPE+cCodGlo) )

	// Vai alimentar o BDX. o valor de glosa ja esta calculado
	nBDX_VLRPAG 	:= 0
	nBDX_VLRMAN 	:= 0
	nBDX_VLRBPR 	:= 0
	nBDX_VLRAPR 	:= 0
	nBDX_VLRGLO 	:= 0
	nBDX_PERGLO 	:= 0
	nBDX_VLRGTX 	:= 0
	nBDX_PERGTX 	:= 0
	nBDX_VLTXPG		:= 0
	nBDX_VLTXAP		:= 0

	PL720GCR(aCriticas[nFor,4],cCodGlo,aCriticas,nFor,cAlias,cNumGuia,"1",;
				@nBDX_VLRPAG,@nBDX_VLRMAN,@nBDX_VLRBPR,@nBDX_VLRAPR,@nBDX_VLRGLO,@nBDX_PERGLO,@nBDX_VLRGTX,@nBDX_PERGTX,@nBDX_VLTXPG,@nBDX_VLTXAP,;
				lValido)

	nFor ++
	if nFor <= len(aCriticas) .and. empty(aCriticas[nFor,1])

		nFor2 := nFor
		while nFor2 <= len(aCriticas) .and. empty(aCriticas[nFor2,1])

			PL720GCR(aCriticas[nFor2,4],cCodGlo,aCriticas,nFor2,cAlias,cNumGuia,"2",;
						nBDX_VLRPAG,nBDX_VLRMAN,nBDX_VLRBPR,nBDX_VLRAPR,nBDX_VLRGLO,nBDX_PERGLO,nBDX_VLRGTX,nBDX_PERGTX,nBDX_VLTXPG,nBDX_VLTXAP,;
						lValido)
			nFor2 ++

		endDo

		nFor := --nFor2
	else
		nFor --
	endIf

next

return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcEvento
Processa evento
@author PLS TEAM
@since  03/07/2019
@version P12
/*/
static function ProcEvento(cTipoGuia,cGuiRel,lHelp,cAnoPag,cMesPag,cAlias,cChaveGui,aDadUsr,cLocalExec,aDadRda,; //10
					lValorCobr,lValorPagto,lBD6Pos,lMsgProc,lProcRev,nDifUs,nVlrDifUs,aRetCom,lRotAudit,;
					aComEve,aMatCom,aPartic,cChavLib,lAuditoria,lMudarFase,lNotUsed,lAnaGloCP, aAuxCBHPM)
local aAreaBD5		:= {}
local aAreaBD6		:= {}
local aAreaBD7		:= {}
local aAreaBAU		:= {}
local aAreaBCL		:= BCL->(getArea())
local cCodPad   	:= ""
local cCodPro   	:= ""
local cCodPla		:= ""
local cVerPla		:= ""
local cCodInt		:= ""
local cCodRDA		:= ""
local cEspec		:= ""
local cSubEsp		:= ""
local cCodLoc		:= ""
local cHorPro		:= ""
local cAliasEn   	:= ""
local cPgNoAto   	:= ""
local cPadInt    	:= ""
local cPortEve		:= ""
local cPadCon    	:= ""
local cRegInt	 	:= ""
local cRegAte    	:= ""
local cPacote		:= ""
local cGrpInt    	:= ""
local cCodTab		:= ""
local cAliasTab		:= ""
local cTipPreFor	:= ""
local cNivelAN	 	:= ""
local cGuiaOpe	 	:= ""
local cGuiaEmp	 	:= ""
local cHorCir		:= ""
local cFinAte	 	:= ""
local cGuiInt 		:= ""
local cTipAdm 		:= getNewPar("MV_PLSTPAD","1")
local cCodOpe		:= ""
local cHorPro6C 	:= ""
local cRegPag 	 	:= ""
local cRegCob    	:= ""
local cFranquia  	:= ""
local cCDTBRC		:= ""
local cCodUnd		:= ""
local cChvNiv		:= ""
local cGuiInt		:= ""
local cCodBlo 		:= ""
local cDesBlo 		:= ""
local cUndPorte		:= allTrim(PLSCHMP())
local cMVPLSCAUX 	:= getNewPar("MV_PLSCAUX","AUX")
local cUnCompara 	:= getNewPar("MV_PLUNCPA","")
local cPacGen 		:= getNewPar("MV_PLPACPT","99999998")
local cOpeRDA    	:= (cAlias)->&( cAlias + "_OPERDA" )
local cFilBD6    	:= xFilial("BD6")
local cFilBCL    	:= xFilial("BCL")
local cFilBR8    	:= xFilial("BR8")
local cFilBAU    	:= xFilial("BAU")
local cFilBC1    	:= xFilial("BC1")
local cMatricUsr 	:= &(cAlias+"->("+cAlias+"_OPEUSR+"+cAlias+"_CODEMP+"+cAlias+"_MATRIC+"+cAlias+"_TIPREG)")
local cMatricComp	:= &(cAlias+"->("+cAlias+"_OPEUSR+"+cAlias+"_CODEMP+"+cAlias+"_MATRIC+"+cAlias+"_TIPREG+"+cAlias+"_DIGITO)")
local nX			:= 0
local nI			:= 0
local nQtd			:= 0
local nInd			:= 0
local nCont			:= 0
local nVlrBPR    	:= 0
local nVlrBPF    	:= 0
local nVlrPF     	:= 0
local nPerTAD    	:= 0
local nVlrTAD    	:= 0
local nVlrTPF    	:= 0
local nPerCop    	:= 0
local nVlrPac		:= 0
local nPercHEsp  	:= 0
local nPrCbHEsp  	:= 0
local nVlrPagLiq 	:= 0
local nVlrPagBru 	:= 0
local nOldPF     	:= 0
local nOldBPF    	:= 0
local nOldTAD    	:= 0
local nOldTPF    	:= 0
local nPrTxPag   	:= 0
local nPerInss   	:= 0
local nVlrTxPg	 	:= 0
local nLimFra    	:= 0
local nSlvBase   	:= 0
local nSlvPerc   	:= 0
local nSlvTx     	:= 0
local nSlvTotal  	:= 0
local nPerda     	:= 0
local nValCop    	:= 0
local nVlrAprCob 	:= 0
local nPerVia   	:= 100
local nRecBD6    	:= 0
local nPosUnd	 	:= 0
local nValCopF		:= 0
local nDif			:= 0
local aAuxMPorte	:= 0
local aValor    	:= {}
local aRetAux		:= {}
local aAux       	:= {}
local aCalcEve		:= {}
local aCri       	:= {}
local aQtdPer    	:= {}
local aRetFun    	:= {.t.,{}}
local aRdas      	:= {}
local aCompoPF		:= {}
local aValAcu    	:= {}
local aCobAcu    	:= {}
local aValAcu2   	:= {}
local aBDXSeAnGl 	:= {.f.,{}}
local aCobertPro 	:= {}
local aUnidsBlo  	:= {}
local aUnidsRPB  	:= {}
local aUnidsVLD		:= {}
local dDatPro		:= stod("")
local dDatCir		:= stod("")
local aPacote		:= {0,0,{},""}
local aRdaAux   	:= {}
local aDadBD6		:= {}
local aRetUnd		:= {}
local aMatTOTCAB	:= {}
local aRet			:= {}
local aUnidSaud		:= {}
local aEvePreAut	:= {}
local lChkEve		:= .f.
local lDoppler   	:= .f.
local lCirurgico 	:= .f.
local lCompoEve     := .f.
local lCompra    	:= .f.
local lTemNFE		:= .f.
local lTemCobr		:= .f.
local lBloqBD3   	:= .f.
local lCalcTX    	:= .t.
local lNovaCoP  	:= .f.
local lReembolso 	:= .f.
local lBloPag	 	:= .f.
local lRet			:= .t.
local lRetCon		:= .f.
local lFoundB4R		:= .t.
local lB4REXC		:= .f.
local lBD4VIG		:= .t.
local lFoundBD4		:= .t.
local lCopPag		:= .f.
local lRdaAux       := .f.
local lChkDopp		:= getNewPar('MV_PLCKDOP','0') == '1'
local cAnoB43		:= ""
local cMesB43		:= ""
local cNAutB43		:= ""
local aRetAjb		:= {}
local nPct 			:= 0
local nRecB43   	:= 0
local nRecBAU		:= 0
local nI			:= 0
local lMfItem		:= .T. //IsInCallStack('PLSA502')
local lPLS720EV     := existBlock("PLS720EV")
local abkpEvPg	:= {}
local aCompTmp2	:= {}
local nContB4R	:= 0
Local nAAA := 0
Local cPacGenPtu := GetNewPar("MV_PLPACPT","99999998")
Local cPaCopart	:= ""
Local lPacGen := .F.
Local lPacGenEpt := .F.

private nVlrPag 	:= 0

default cChavLib	:= ""
default nDifUs 		:= 1
default nVlrDifUs	:= 0
default aRetCom		:= {}
default aComEve		:= {}
default aMatCom     := {}
default aPartic		:= {}
default aAuxCBHPM	:= { "", StoD(""), {}, {}, "" }
default lHelp       := .t.
default lValorCobr  := .t.
default lValorPagto := .t.
default lBD6Pos     := .f.
default lMsgProc    := .f.
default lProcRev    := .f.
default lRotAudit   := .f.
default lAuditoria	:= .f.
default lMudarFase  := .f.
default lNotUsed	:= .f.

lMsgProc := .F.

//verifica se esta contabilizado 
if lProcRev
	if PLCHKCTB('A',cChaveGui)
		return({.f.,{},{}})
	endIf
endIf

//tem casos, como na mud de fase por lote, que o aDadUsr ainda nao esta carregado
if len(aDadUsr) == 0
	aRetAux := PLSDADUSR(cMatricComp,"1",.f.,dDatPro,BD6->BD6_CODPAD,BD6->BD6_CODPRO)
	
	if ! aRetAux[1] .AND. !( isInCallStack("PLSA500RCB") .OR. isInCallStack("PLSA500RPG") .OR. IsInCallStack("PLSA500RCP") ) // Não deve apresentar crítica na Revalorização.
		return( { .f., aRetAux[2], aBDXSeAnGl } )
	else
		aDadUsr := PLSGETUSR()
	endIf
	
	if len(aDadUsr) > 12
		cVerPla := aDadUsr[12]
	endIf
endIf

// indica que deve calcular a co-participacao com base no valor pago ao prestador
lCopPag := iIf( len(aDadUsr) >= 72 , aDadUsr[72] == "1",.f.)

//recurso de glosa e nao for cobranca com base no pagamento nao gerar cobrança
if cTipoGuia == G_REC_GLOSA .and. ! lCopPag
	lValorCobr := .f.
endIf	

aAreaBD6 := BD6->(getArea())

if lValorCobr .and. lValorPagto .and. &(cAlias)->( fieldPos( cAlias + "_ERRO") ) > 0 .and. (cAlias)->&( cAlias + "_ERRO" ) == "1"
	PLS720ZCB("3",cChaveGui,cAlias, .T.)
endIf

if BCL->BCL_TIPGUI <> BD6->BD6_TIPGUI
	BCL->(dbSetOrder(1))
	BCL->(msSeek(cFilBCL+BD6->(BD6_CODOPE+BD6_TIPGUI)))
endIf

cCodInt   := (cAlias)->&( cAlias + "_OPEUSR" )
cCodRDA   := (cAlias)->&( cAlias + "_CODRDA" )
cEspec    := (cAlias)->&( cAlias + "_CODESP" )
cSubEsp   := (cAlias)->&( cAlias + "_SUBESP" )
cCodLoc   := (cAlias)->&( cAlias + "_CODLOC" )
dDatPro   := (cAlias)->&( cAlias + "_DATPRO" )
cHorPro   := (cAlias)->&( cAlias + "_HORPRO" )
cPacote   := (cAlias)->&( cAlias + "_PACOTE" )
nVlrPac   := (cAlias)->&( cAlias + "_VLRPAC" )
cGuiaOpe  := (cAlias)->&( cAlias + "_NRAOPE" )
cGuiaEmp  := (cAlias)->&( cAlias + "_NRAEMP" )

if &(cAlias)->( fieldPos( cAlias + "_TIPPAC" ) ) > 0
	cFinAte := (cAlias)->&( cAlias + "_TIPPAC" )
else
	cFinAte := getNewPar("MV_PLSTPAA","9")
endIf

cGrpInt := ""
if &(cAlias)->(fieldPos(cAlias+"_GRPINT")) > 0 .and. &(cAlias)->( fieldPos( cAlias + "_TIPINT")) > 0
	cGrpInt := (cAlias)->&( cAlias + "_GRPINT" ) + (cAlias)->&( cAlias + "_TIPINT" )
endIf

if &(cAlias)->( fieldPos( cAlias + "_TIPADM" ) ) > 0
	cTipAdm := (cAlias)->&( cAlias + "_TIPADM")
endIf

if cTipoGuia == G_REEMBOLSO
	lReembolso := .t.
endIf

//pegar a admissao da solicitacao de internacao
if cTipoGuia == G_HONORARIO
	
	cGuiInt := BD5->BD5_GUIINT
	
	if ! empty(cGuiInt)	
	
		aAreaBD5 := BD5->(getArea())
	
		BE4->(dbSetOrder(1)) //BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_SITUAC+BE4_FASE
		if BE4->( msSeek( xFilial('BE4') + cGuiInt))
			cTipAdm := BE4->BE4_TIPADM
		endIf
	
		BD5->(restArea(aAreaBD5))
		
	endIf	
	
endIf

if &(cAlias)->( fieldPos( cAlias + "_TIPPRE" ) ) > 0
	cTipPreFor := (cAlias)->&( cAlias + "_TIPPRE" )
else
	cTipPreFor := ""
endIf

if empty(cTipPreFor) .or. BAU->BAU_CODIGO <> cCodRDA
	BAU->(dbSetOrder(1))
	BAU->( msSeek( xFilial("BAU") + cCodRDA ))

	cTipPreFor := BAU->BAU_TIPPRE
endIf

aAreaBAU := BAU->(getArea())

BD6->(restArea(aAreaBD6))

while ! BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == cFilBD6 + cChaveGui
		
	BR8->( msSeek( cFilBR8 + BD6->BD6_CODPAD + BD6->BD6_CODPRO ) )
	
	aComEve	 	:= PLSCOMEVE(BD6->BD6_CODTAB,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODOPE,BD6->BD6_DATPRO,BD6->BD6_TIPGUI,nil,nil,BD6->BD6_CODRDA,BD6->BD6_CODESP,BD6->BD6_SUBESP,BD6->BD6_CODLOC,'1',,,,,,BD6->BD6_CODPLA)
	abkpEvPg 	:= aclone(aComEve)
	cCodTab  	:= BD6->BD6_CODTAB
	cAliasTab	:= BD6->BD6_ALIATB
	aCompTmp2 	:= {}
	
	if empty(cCodTab) .and. len(aComEve) > 0
		cCodTab   := aComEve[1,15]
		cAliasTab := aComEve[1,22]
	endIf 
	
	If GetNewPar("MV_PLCAAUX","1") == "3" .And. !BD6->(Eof()) .and. BR8->BR8_TIPEVE == "2" .AND. !(lAnyGlosa) // item (BR8->BR8_TIPEVE == "2")adicionado para que que ele vao vá ao while de bd6 e perca performane. lGlosa adicionado pq não deve ser chamado na análise de glosa e afins (guia já teve a fase alterada antes e já verificou/gerou os BD7 devidos

		aAreaBR8	:= BR8->(getArea())
		aCompTmp2 := PLSDISTAUX(BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV),nil,aDadUsr,aAuxCBHPM)

		If Len(aCompTmp2) > 0
			PLEQUAAUX(aCompTmp2[1],aCompTmp2[2],aCompTmp2[3],aComEve,cCodPad,cCodPro)
		EndIf
		BR8->(restArea(aAreaBR8))

	Endif
	
	aCobertPro := {}
	
	//para utilizar quando for evento posicionado lBD6Pos = .t.
	nOldPF     	:= BD6->BD6_VLRPF
	nOldBPF    	:= BD6->BD6_VLRBPF
	nOldTAD    	:= BD6->BD6_VLRTAD
	nOldTPF    	:= BD6->BD6_VLRTPF
	
	cCodPad		:= BD6->BD6_CODPAD
	cCodPro		:= BD6->BD6_CODPRO
	nQtd		:= BD6->BD6_QTDPRO
	
	aRdas		:= {}
	nValCop		:= 0
	nVlrPagLiq	:= 0
	nVlrPagBru	:= 0
	
	// Criada essa variavel pois Vale dos Sinos solicitou o horario do evento
	// com 6 caracteres para o PE PLSRETCP e a funcao que trabalha com esse
	// PE nao tem tratativa de Alias, somente variaveis
	cHorPro6C   := BD6->BD6_HORPRO
	
	//em alguns clientes o horpro tem mais de 4 posicoes... mas todos os cadastro de horario especial so tem 4 ou seja eu forco ele ter 4...
	cHorPro		:= subStr(strTran(BD6->BD6_HORPRO,':',''),1,4)
	aQtdPer		:= {}
	lCirurgico	:= .f.
	nPerVia		:= 100
	
	//se for doppler excluir bd7, recriar para recalcular novamente...
	if lChkDopp
	
		lDoppler := procDop(BD6->BD6_CODPAD,BD6->BD6_CODPRO,cCodTab)
	
		if lDoppler .and. ( !lValorPagto .or. !lValorCobr )
			
			getTotBD6(aMatTOTCAB)
			
			BD6->(dbSkip())
			loop
		endIf
		
		if lDoppler
			
			plTRBBD7("TRBBD7", BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, BD6->BD6_ORIMOV, BD6->BD6_SEQUEN)
			
			while ! TRBBD7->(eof())
			
				BD7->( dbGoTo( TRBBD7->REC ) )
				
				BD7->(recLock("BD7",.f.))
					BD7->(DbDelete())
				BD7->(msUnLock())
				
			TRBBD7->(dbSkip())
			endDo
			
			TRBBD7->(dbCloseArea())
			
			PLS720IBD7(&(cAlias+"->"+cAlias+"_PACOTE"),BD6->BD6_VLPGMA,BD6->BD6_CODPAD,BD6->BD6_CODPRO,cCodTab,BD6->BD6_CODOPE,BD6->BD6_CODRDA,;
						BD6->BD6_REGEXE,BD6->BD6_SIGEXE,BD6->BD6_ESTEXE,BD6->BD6_CDPFRE,BD6->BD6_CODESP,BD6->(BD6_CODLOC+BD6_LOCAL),"1",BD6->BD6_SEQUEN,;
						BD6->BD6_ORIMOV,BCL->BCL_TIPGUI,BD6->BD6_DATPRO,,aComEve,,,,,,aMatCom,aPartic)
			
		endIf
		
	endIf
	
	if BD6->BD6_PROCCI == "1"
	
		lCirurgico	:= .t.
		nPerVia		:= BD6->BD6_PERVIA
		
	endIf
	
	cRegPag := BD6->BD6_REGPAG
	cRegCob := BD6->BD6_REGCOB
	
	if cTipoGuia $ G_SOL_INTER + "|" + G_RES_INTER  //internacao
	
		cPadInt := BE4->BE4_PADINT
		cPadCon := BE4->BE4_PADCON
		cRegInt := BE4->BE4_REGINT //1=Hospitalar;2=Hospital-Dia;3=Domiciliar
		cRegAte := '1'
		
		dDatCir := BD6->BD6_DATPRO
		cHorCir := substr(strTran(BD6->BD6_HORPRO,':',""),1,4)
		
	else
	
		dDatCir := BD6->BD6_DATPRO
		cHorCir := substr(strTran(BD6->BD6_HORPRO,':',""),1,4)
		
		cRegAte := BD5->BD5_REGATE //1=Internação; 2=Ambulatorial
		
		if ! empty(BD5->BD5_REGFOR)
			cRegAte := BD5->BD5_REGFOR
		elseIf EmpTy(cRegAte) .AND. cTipoGuia == G_CONSULTA
			cRegAte := "2"
		endIf
		
		//eu so trato tipo de acomodacao quando o cara ta internado 1=Internação; 2=Ambulatorial
		if cRegAte == '1'
		
			cRegInt := '1'	
			cPadInt := BD5->BD5_PADINT
			cPadCon := BD5->BD5_PADCON
			
		endIf
		
	endIf
	
	//monta BD6_QTDX (1,2,3,4,5,6) se necessario
	aQtdPer := PlMonQtPer(BD6->BD6_SEQUEN,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_QTDPRO,;
						  .f.,cFilBD6 + cChaveGui,BD6->BD6_DATPRO,nil,nil,nil,nil,BD6->BD6_CODRDA,BD6->(BD6_CODLOC+BD6_LOCAL))
	
	if cTipoGuia $ G_SOL_INTER + "|" + G_RES_INTER .and. ;
	   PLSPOSGLO(PLSINTPAD(),__aCdCri109[1],__aCdCri109[2],clocalExec,"1") .and. PLSCHKCRI( {'BAU',BD6->BD6_CODRDA,__aCdCri109[1]} ) .and. ; // Critica "066" Ativa
	   PLSPOSGLO(PLSINTPAD(),__aCdCri110[1],__aCdCri110[2],clocalExec,"1") .and. PLSCHKCRI( {'BAU',BD6->BD6_CODRDA,__aCdCri110[1]} ) .and. ; // Critica "067" Ativa
	   PLSPOSGLO(PLSINTPAD(),__aCdCri111[1],__aCdCri111[2],clocalExec,"1") .and. PLSCHKCRI( {'BAU',BD6->BD6_CODRDA,__aCdCri111[1]} )         // Critica "068" Ativa

		// Mudanca de Fase e eh Material/Procedimento de Alto Custo
		if (lValorCobr .and. lValorPagto) .and. (BR8->BR8_ALTCUS == "1") .and. empty(BD6->BD6_SEQIMP)
			
			// Se eh PRE-PAGAMENTO com CO-PARTICIPACAO ou se nao eh PRE-PAGAMENTO, de-
			// ve cobrar o material/procedimento de alto custo.
			lTemCobr := (allTrim(BA3->BA3_MODPAG) <> "1") .or. (allTrim(BA3->BA3_MODPAG) == "1" .and. ;
						((BA3->BA3_TIPOUS == "1" .and. BI3->BI3_CPFM == "1") .or. ; 	// Co-participacao PF ou
						 (BA3->BA3_TIPOUS == "2" .and. BT6->BT6_CPFM == "1") )) 		// Co-participacao PJ
			
			// Pesquisa tabela de relacionamento entre NF Entrada x Guias Internacao
			B19->(dbSetOrder(2))
			
			lTemNFE := B19->(msSeek(xFilial("B19")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
			
			// Se encontrou o relacionamento, busca a NF Entrada para obter o valor a cobrar/pagar
			if lTemNFE
				SD1->(dbSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
				lTemNFE := SD1->(msSeek(xFilial("SD1")+B19->(B19_DOC+B19_SERIE+B19_FORNEC+B19_LOJA+B19_COD+B19_ITEM)))
			endIf
			
			// Se encontrou NF de Entrada:
			// O valor a pagar/cobrar sera o valor da NF de Entrada e deve bloquear o
			// pagamento deste material/procedimento de alto custo.
			if lTemNFE
				
				// Se nao ha valor a pagar apresentado ou se deve cobrar do cliente (pre-
				// pagamento com co-participacao ou outras formas de cobranca) e nao ha
				// valor a cobrar apresentado, atualiza valor a pagar/cobrar apresentado
				// com o valor encontrado na nota fiscal de entrada e envia a guia para
				// conferencia para que o cliente confira/altere o valor a pagar/cobrar
				// do material/procedimento de alto custo.
				if (BD6->BD6_VLRAPR == 0) .or. (lTemCobr .and. BD6->BD6_VLRACB == 0)
					
					PLSPOSGLO(PLSINTPAD(),__aCdCri109[1],__aCdCri109[2],clocalExec,"1")
					
					// para nao calcular `n` vezes na valorizacao da guia
					nQtdPro := SD1->D1_QUANT
					
					BD6->(recLock("BD6", .f.))
					
						//valor apresentado total						
						BD6->BD6_VALORI := iIf(getNewPar('MV_PLAPCUS','0') == '0', SD1->D1_TOTAL, SD1->D1_CUSTO)
						
						//valor apresentado unitario	
						BD6->BD6_VLRAPR := ( BD6->BD6_VALORI / nQtdPro )
						
						//valor da taxa total
						if BD6->BD6_VLTXAP == 0 
							BD6->BD6_VLTXAP := ( BD6->BD6_VALORI * BD6->BD6_PRTXPG) / 100
						endIf
						
						if lTemCobr
							BD6->BD6_VLRACB := BD6->BD6_VALORI
						endIf
						
						PLBLOPC('BD6', .t., __aCdCri109[1], PLSBCTDESC(), .t., .f.)
						
						BD6->BD6_NFE := SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM)
						
					BD6->(msUnLock())
					
				// Se ha valor a cobrar apresentado, ou valor a pagar apresentado, signi-
				// fica que a guia ja esteve em conferencia (em funcao do "if" acima) e o
				// sistema esta mudando novamente a fase da guia. Neste caso bloqueia pa-
				// gamento do material/procedimento de alto custo e nao envia novamente
				// para a conferencia.
				else
					
					PLSPOSGLO(PLSINTPAD(),__aCdCri111[1],__aCdCri111[2],clocalExec,"1")
					
					BD6->(recLock("BD6", .f.))
						PLBLOPC('BD6', .t., __aCdCri111[1], PLSBCTDESC(), .t., .f.)
					BD6->(msUnLock())
					
				endIf
				
			// Se nao encontrou NF Entrada:
			// O valor a pagar/cobrar devera ser informado (digitado pelo usuario).
			else
				
				// Se nao ha valor a pagar apresentado ou se deve cobrar do cliente (pre-
				// pagamento com co-participacao ou outras formas de cobranca) e nao ha
				// valor a cobrar apresentado, envia a guia para conferencia para forcar
				// a digitacao do valor a pagar/cobrar do material/procedimento de alto
				// custo.
				if (BD6->BD6_VLRAPR == 0) .or. (lTemCobr .and. BD6->BD6_VLRACB == 0)
					
					PLSPOSGLO(PLSINTPAD(),__aCdCri110[1],__aCdCri110[2],clocalExec,"1")
					
					BD6->(recLock("BD6", .f.))
						PLBLOPC('BD6', .t., __aCdCri110[1], PLSBCTDESC(), .t., .f.)
					BD6->(msUnLock())
					
				elseif BD6->BD6_ENVCON <> '1'
					
					BD6->(recLock("BD6", .f.))
						PLBLOPC('BD6', .f., '', '', .t., .f.)
					BD6->(msUnLock())

				endIf
				
			endIf
			
		endIf
		
	endIf
	
	aUnidsBlo 	:= {}
	aUnidsRPB 	:= {}
	aUnidsVLD	:= {}
	aRdaAux   	:= {}
	aUnidSaud	:= {}
	lCompoEve   := len(aComEve) > 0
	lChkEve		:= .f.
	
	BD4->(dbSetOrder(1)) //BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO+BD4_CODIGO+DTOS(BD4_VIGINI)
	B4R->(dbSetOrder(1)) //B4R_FILIAL+B4R_CODRDA
	
	plTRBBD7("TRBBD7", BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, BD6->BD6_ORIMOV, BD6->BD6_SEQUEN)
			
	while ! TRBBD7->(eof())
			
		BD7->( dbGoTo( TRBBD7->REC ) )
		
		If (!lValorPagto .and. lValorCobr)
			//Esse item se faz necessario devido que ao valorizar somente a cobrança precisamos da tabela de cobrança que nesse momento a BD6_CDTBRC esta e branco
			//por se tratar somente de valoração a composição ja esta correta. 
			lFoundBD4 	:= .t.
			lBD4VIG		:= .t.
		else
			aRet 	  := plChkBD4( BD6->BD6_CODOPE + cCodTAB + BD6->(BD6_CODPAD+BD6_CODPRO), BD7->BD7_CODUNM, .t., BD6->BD6_DATPRO )
			lFoundBD4 := aRet[1]
			lBD4VIG   := aRet[2]
			
			//Caso a regra 5 da CBHPM foi aplicada (auxiliares)
			If !lFoundBD4 .AND. (BD7->BD7_CODUNM == cMVPLSCAUX .AND. getNewPar("MV_PLCAAUX","1") == "3")
				lFoundBD4 	:= .T.
				lBD4VIG	:= .T.
			endIf
				
			//TODO - 06/04/2018 - LUCAS - REVER mudando a composicao do evento (aComEve) conforme RDA do BD7.
			//TODO - 06/04/2018 - LUCAS - REVER verificando vigencia do evento conforme RDA do BD7.   
			//Tratamento para quando a operadora diferenciar as tabelas de procedimento por tipo de prestador
			//Considerar o tipo do prestador da BD7 e a data de procedimento da BD7 quando houver
			if !lFoundBD4 .And. BD7->BD7_CODRDA <> BD6->BD6_CODRDA	
						
				nRecBAU := BAU->(recno())						
				BAU->(dbSetOrder(1))
				
				if BAU->(MsSeek(xFilial("BAU") + BD7->BD7_CODRDA))
				
					aCodTab := PLSRETTAB(BD6->BD6_CODPAD,BD6->BD6_CODPRO,iif(BD6->BD6_DATPRO > dDatPro,BD6->BD6_DATPRO, dDatPro),BD6->BD6_CODOPE,BD7->BD7_CODRDA,BD7->BD7_CODESP,cSubEsp,cCodLoc,iif(BD6->BD6_DATPRO > dDatPro,BD6->BD6_DATPRO, dDatPro),;
										 "1", BD6->BD6_CODOPE, BD6->BD6_CODPLA, "1", "1", nil,iIf( ! empty(BAU->BAU_TIPPRE), BAU->BAU_TIPPRE, nil),nil, nil, cTipoGuia == G_REEMBOLSO , nil, nil, cRegAte)							 				
					
					if aCodTab[1]
						aRet 	   := plChkBD4( BD6->BD6_CODOPE + aCodTab[3] + BD6->(BD6_CODPAD+BD6_CODPRO), BD7->BD7_CODUNM, .t., BD6->BD6_DATPRO )
						
						lFoundBD4 := aRet[1]
						lBD4VIG   := aRet[2]
						
						if lFoundBD4
						
							BD6->(recLock("BD6", .f.))
								BD6->BD6_CODTAB := aCodTab[3]
								BD6->BD6_ALIATB := aCodTab[4]
							BD6->(msUnLock())
						
							cCodTAB	:= BD6->BD6_CODTAB
						
							aComEve := PLSCOMEVE(BD6->BD6_CODTAB,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODOPE,BD6->BD6_DATPRO,BD6->BD6_TIPGUI,nil,nil,BD6->BD6_CODRDA,BD6->BD6_CODESP,BD6->BD6_SUBESP,BD6->BD6_CODLOC,'1')
							
						endIf
						
					endif
					
				endif
				
				if nRecBAU > 0
					BAU->(DbGoto(nRecBAU))    			
				endif
			endif
			
		endif 
		
		if lFoundBD4 .and. lBD4VIG
			
			nPosUnd := aScan(aComEve,{|x| x[1] == BD7->BD7_CODUNM})
			
			if nPosUnd > 0
				lBloqBD3 := iIf(aComEve[nPosUnd,13] == '1',.t.,.f.)
			endIf
			
		else
			lBloqBD3 := .f.
		endIf
		
		if ! lFoundBD4 

			PLSPOSGLO(PLSINTPAD(),__aCdCri234[1],__aCdCri234[2],"1")
			
			if PCLPGAUTO()
				aBDXSeAnGl[1] := .f.
				aadd(aBDXSeAnGl[2],{ __aCdCri234[1],allTrim(PLSBCTDESC()) + ' [' + BD7->BD7_CODUNM + ']',BD7->BD7_CODUNM,BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
			else
				aRetFun[1] := .f.
				aadd(aRetFun[2],{ __aCdCri234[1],allTrim(PLSBCTDESC()) + ' [' + BD7->BD7_CODUNM + ']',BD7->BD7_CODUNM,BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
			endIf	

		elseIf lBloqBD3 

			PLSPOSGLO(PLSINTPAD(),__aCdCri223[1],__aCdCri223[2],"1")
			
			if PCLPGAUTO()
				aBDXSeAnGl[1] := .f.
				aadd(aBDXSeAnGl[2],{ __aCdCri223[1],allTrim(PLSBCTDESC()) + ' [' + BD7->BD7_CODUNM + ']',BD7->BD7_CODUNM,BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
			else
				aRetFun[1] := .f.
				aadd(aRetFun[2],{ __aCdCri223[1],allTrim(PLSBCTDESC()) + ' [' + BD7->BD7_CODUNM + ']',BD7->BD7_CODUNM,BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
			endIf	
			
		elseIf ! lBD4VIG	
		
			PLSPOSGLO(PLSINTPAD(),__aCdCri230[1],__aCdCri230[2],"1")

			if PCLPGAUTO()
				aBDXSeAnGl[1] := .f.
				aadd(aBDXSeAnGl[2],{ __aCdCri230[1],allTrim(PLSBCTDESC()) + ' [' + BD7->BD7_CODUNM + ']',BD7->BD7_CODUNM,BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
			else
				aRetFun[1] := .f.
				aadd(aRetFun[2],{ __aCdCri230[1],allTrim(PLSBCTDESC()) + ' [' + BD7->BD7_CODUNM + ']',BD7->BD7_CODUNM,BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
			endIf	

		elseIf lFoundB4R
			
			lFoundB4R := B4R->( msSeek( xFilial('B4R') + BD7->BD7_CODRDA))
			
			if lFoundB4R 
				
				if len(aUnidSaud) == 0 .and. ! lChkEve
					aUnidSaud := PLB4REXC(BD7->BD7_CODRDA, BD7->BD7_CODPAD, BD7->BD7_CODPRO, BD6->BD6_CODLOC + BD6->BD6_lOCAL, BD7->BD7_CODESP, BD7->BD7_CODUNM)
					lChkEve	  := .t.
				endIf	
		
				lB4REXC := aScan(aUnidSaud, {|x| BD7->BD7_CODUNM $ x } ) > 0
			
			endIf
					
		endIf	

		BD7->( recLock("BD7", .f.) )
		
			if BD6->BD6_BLOPAG == "1" .and. BD6->BD6_ENVCON == "1"
		
				PLBLOPC('BD7', .f., nil, nil, .t., .f., .f.)
				
			else

				if BD7->BD7_BLOPAG != '1' .and. BD6->BD6_MOTBPG $ __aCdCri109[1] + '|' + __aCdCri110[1] + '|' + __aCdCri111[1] 
					PLBLOPC('BD7', .t., BD6->BD6_MOTBPG, BD6->BD6_DESBPG)
				endIf
				
				if ! empty(BD6->BD6_NFE)
					BD7->BD7_NFE := BD6->BD6_NFE
				endIf
			
			endIf
		
		BD7->(msUnLock())
		
		aadd(aUnidsRPB, { BD7->BD7_CODUNM, BD7->BD7_NLANC } )
		
		if lBloqBD3
			aadd(aUnidsBlo, { BD7->BD7_CODUNM, BD7->BD7_NLANC } )
		ElseIf lB4REXC
			nContB4R++
			aadd(aUnidsBlo, { BD7->BD7_CODUNM, BD7->BD7_NLANC } )
			aadd(aUnidsVLD, { BD7->BD7_CODUNM, BD7->BD7_NLANC, BD7->BD7_UNITDE, BD7->(recno()) } )
		else
			aadd(aUnidsVLD, { BD7->BD7_CODUNM, BD7->BD7_NLANC, BD7->BD7_UNITDE, BD7->(recno()) } )
		endIf
		
		if BAU->BAU_CODIGO <> BD7->BD7_CODRDA
			
			BAU->(dbSetOrder(1))
			BAU->(msSeek( cFilBAU + BD7->BD7_CODRDA))
			
		endIf
		
		cCodRDA := BD7->BD7_CODRDA
		
		if BD7->BD7_CODRDA == BD6->BD6_CODRDA .or. empty(BD6->BD6_CDPFRE)
			
			aadd(aRdas,{BD7->BD7_CODUNM,;
						BD7->BD7_CODRDA,;
						iIf( ! empty(BD7->BD7_CODLOC) .and. (BD7->BD7_CODRDA <> BD6->BD6_CODRDA) ,BD7->BD7_CODLOC,BD6->BD6_CODLOC),;
						BD7->BD7_CODESP,;
						0,;
						BAU->BAU_TIPPRE,;
						BD7->BD7_VLRAPR,;
						iIf(lCirurgico,BD7->BD7_PERVIA,0),;
						BD7->BD7_NLANC,;
						BD7->BD7_CONSFT})
			
		else
			
			BC1->(dbSetOrder(1))
			if BC1->(msSeek(cFilBC1+BD6->(BD6_CODRDA+BD6_CODLOC+BD6_CODESP+BD6_CDPFRE)))
				
				aadd(aRdas,{BD7->BD7_CODUNM,;
							BD7->BD7_CODRDA,;
							BC1->BC1_CODLOC,;
							BC1->BC1_CODESP,;
							0,;
							BAU->BAU_TIPPRE,;
							BD7->BD7_VLRAPR,;
							iIf(lCirurgico,BD7->BD7_PERVIA,0),;
							BD7->BD7_NLANC,;
							BD7->BD7_CONSFT})
				
			else
				
				aadd(aRdas,{BD7->BD7_CODUNM,;
							BD7->BD7_CODRDA,;
							BD7->BD7_CODLOC,;
							BD7->BD7_CODESP,;
							0,;
							BAU->BAU_TIPPRE,;
							BD7->BD7_VLRAPR,;
							iIf(lCirurgico,BD7->BD7_PERVIA,0),;
							BD7->BD7_NLANC,;
							BD7->BD7_CONSFT})
				
			endIf
			
		endIf
				
	TRBBD7->(dbSkip())
	endDo
	
	TRBBD7->(dbCloseArea())
	BAU->(restArea(aAreaBAU))
	
	lBloPag := ( len(aUnidsRPB) > 0 .and. len(aUnidsRPB) == (len(aUnidsBlo) - nContB4R) )
	
	if lCompoEve
		
		if len(aComEve) <> len(aUnidsRPB)
			
			for nI := 1 to len(aComEve)
				
				if allTrim(aComEve[nI,1]) $ allTrim( cMVPLSCAUX )
					
					//se a unidade nao existe na BD7
					if aScan(aUnidsRPB, {|x| allTrim(x[1]) == allTrim(aComEve[nI,1]) .and. allTrim(x[2]) == allTrim(aComEve[nI,16]) } ) == 0
					
						//se a unidade ja nao esta bloqueada
						if aScan(aUnidsBlo, {|x| allTrim(x[1]) == allTrim(aComEve[nI,1]) .and. allTrim(x[2]) == allTrim(aComEve[nI,16]) } ) == 0
							aadd(aUnidsBlo, { aComEve[nI,1], aComEve[nI,16] } )
						endIf
							
					endIf
					
				endIf	
				 		
			next
			
		endIf
		
		//se for uma guia de SADT ou GHI e tem AUXILIAR ou AUXILIAR DO ANESTESISTA e nao tem HONORARIO OU HONORARIO DO ANESTESITA
		//eu tenho que buscar aonde estao estes HONORARIOS para descobrir se eu paguei o honorario para uma RDA diferente
		if BD6->BD6_TIPGUI $ G_SADT + "|" + G_HONORARIO .and.;
		   ( ( lRdaAux :=   (aScan(aRdas,{|x| x[1] $ "AUX,AUR" }) > 0 .and. aScan(aRdas,{|x| x[1] $ cMVPLSCHMP }) == 0) ) .or.;
			 ( lRdaAux := ! (aScan(aRdas,{|x| x[1] $ "AUA"     }) > 0 .and. aScan(aRdas,{|x| x[1] $ cMVPLSCHMA }) == 0) ) )
			
			aRdaAux := pBusAuGui(cAlias, lCirurgico, BD6->BD6_TIPGUI, cMVPLSCHMP, cMVPLSCHMA, lRdaAux)
			
		endIf
		
		BAU->(restArea(aAreaBAU))
		
		// Busco o valor do pacote		
		aPacote := {0, 0, {}, ""}	//[1] valor real,[2] valor cg,[3] composicao aberta
		
		B43->(dbSetOrder(1))
		BR8->(DbSetOrder(1))
		
		if B43->(msSeek(xFilial("B43") + cChaveGui + BD6->BD6_SEQUEN) ) .and. cCodPro <> cPacGen
			
			cAnoB43  := B43->B43_ANOAUT
			cMesB43  := B43->B43_MESAUT
			cNautB43 := B43->B43_NUMAUT				 		
			aRetAjB  := PlRetPac(cCodInt,cCodRda,cCodPad,cCodPro,nil,dDatPro)

			While B43->(MsSeek(xFilial("B43")+cChaveGui+BD6->BD6_SEQUEN))
				B43->(RecLock("B43",.F.))
				B43->(DbDelete())
				B43->(MsUnLock())
			Enddo						
			
			BD6->(RecLock("BD6",.F.))
			BD6->BD6_PACOTE := '0'
			BD6->(MsUnLock())

		    For nPct:= 1  To Len(aRetAjB)
		      	If Len(aRetAjB[nPct]) >= 10 .And. !Empty(aRetAjB[nPct,1]) .And. !Empty(aRetAjB[nPct,2])	
					B43->(RecLock("B43",.T.))
					B43->B43_FILIAL := BD6->BD6_FILIAL
					B43->B43_OPEMOV := BD6->BD6_CODOPE
					B43->B43_ANOAUT := cAnoB43
					B43->B43_MESAUT := cMesB43
					B43->B43_NUMAUT := cNautB43	
					B43->B43_SEQUEN := BD6->BD6_SEQUEN
					B43->B43_CODOPE := BD6->BD6_CODOPE
					B43->B43_CODLDP := BD6->BD6_CODLDP
					B43->B43_CODPEG := BD6->BD6_CODPEG
					B43->B43_NUMERO := BD6->BD6_NUMERO
					B43->B43_ORIMOV := BD6->BD6_ORIMOV
					B43->B43_DESPRO := Posicione("BR8",1,xFilial("BR8") + aRetAjB[nPct,1] + aRetAjB[nPct,2], "BR8_DESCRI")
					B43->B43_CODPAD := aRetAjB[nPct,1]
					B43->B43_CODPRO := aRetAjB[nPct,2]
					B43->B43_TIPO   := aRetAjB[nPct,3]
					B43->B43_VALCH  := aRetAjB[nPct,4]
					B43->B43_VALFIX := aRetAjB[nPct,5]
					B43->B43_PRINCI := aRetAjB[nPct,6]
					B43->B43_NIVPAC := aRetAjB[nPct,10]
					B43->( MsUnLock() )	
				Endif   
				
				If nPct = 1
					nRecB43:= B43->(RECNO())
					BD6->(RecLock("BD6",.F.))
					BD6->BD6_PACOTE := '1'
					BD6->(MsUnLock())
				EndIf	
			Next
			If nRecB43 >0
				B43->(DbGoto(nRecB43))    			
			EndIf 

			while ! B43->(eof()) .and. B43->(B43_FILIAL+B43_CODOPE+B43_CODLDP+B43_CODPEG+B43_NUMERO+B43_ORIMOV+B43_SEQUEN) == xFilial("B43")+cChaveGui+BD6->BD6_SEQUEN
				
				aadd(aPacote[3],{B43->B43_CODPAD,B43->B43_CODPRO,B43->B43_VALFIX,B43->B43_VALCH,B43->B43_PRINCI,B43->B43_TIPO})
				
				aPacote[1] += B43->B43_VALFIX
				aPacote[2] += B43->B43_VALCH
				aPacote[4] := B43->B43_NIVPAC
				
				B43->(dbSkip())
			endDo
			
		elseif BR8->BR8_TPPROC == "6"
			 		
			aRetAjB  := PlRetPac(cCodInt,cCodRda,cCodPad,cCodPro,nil,dDatPro)

			If Len(aRetAjB) > 0 
			
				While B43->(MsSeek(xFilial("B43")+cChaveGui+BD6->BD6_SEQUEN))
					B43->(RecLock("B43",.F.))
					B43->(DbDelete())
					B43->(MsUnLock())
				Enddo

				BD6->(RecLock("BD6",.F.))
				BD6->BD6_PACOTE := '0'
				BD6->(MsUnLock())				
			Endif
			
		    For nPct:= 1  To Len(aRetAjB)
		      	If Len(aRetAjB[nPct]) >= 10 .And. !Empty(aRetAjB[nPct,1]) .And. !Empty(aRetAjB[nPct,2])	
					B43->(RecLock("B43",.T.))
					B43->B43_FILIAL := BD6->BD6_FILIAL
					B43->B43_OPEMOV := BD6->BD6_CODOPE
					B43->B43_SEQUEN := BD6->BD6_SEQUEN
					B43->B43_CODOPE := BD6->BD6_CODOPE
					B43->B43_CODLDP := BD6->BD6_CODLDP
					B43->B43_CODPEG := BD6->BD6_CODPEG
					B43->B43_NUMERO := BD6->BD6_NUMERO
					B43->B43_ORIMOV := BD6->BD6_ORIMOV
					B43->B43_DESPRO := Posicione("BR8",1,xFilial("BR8") + aRetAjB[nPct,1] + aRetAjB[nPct,2], "BR8_DESCRI")
					B43->B43_CODPAD := aRetAjB[nPct,1]
					B43->B43_CODPRO := aRetAjB[nPct,2]
					B43->B43_TIPO   := aRetAjB[nPct,3]
					B43->B43_VALCH  := aRetAjB[nPct,4]
					B43->B43_VALFIX := aRetAjB[nPct,5]
					B43->B43_PRINCI := aRetAjB[nPct,6]
					B43->B43_NIVPAC := aRetAjB[nPct,10]
					B43->( MsUnLock() )	
				Endif   
				
				If nPct == 1
					nRecB43:= B43->(RECNO())
					BD6->(RecLock("BD6",.F.))
					BD6->BD6_PACOTE := '1'
					BD6->(MsUnLock())
				EndIf	
			Next

			If nRecB43 >0
				B43->(DbGoto(nRecB43))    			
			EndIf 

			For nPct := 1  To Len(aRetAjB)
				aPacote[1] += aRetAjB[nPct,5]
				aPacote[2] += aRetAjB[nPct,4]
				aPacote[4] := aRetAjB[nPct,10]
			next
				
		endIf
		
		lCalcTX := .t.
		
		//caso seja PTU verifica se e para considerar a taxa administrativa
		if ! empty(BD6->BD6_SEQIMP)
			
			BRJ->(dbSetOrder(1))//BRJ_FILIAL+BRJ_CODIGO
			if BRJ->(msSeek(xFilial("BRJ") + BD6->BD6_SEQIMP)) .and. BRJ->BRJ_TPCOB == '1'
				lCalcTX := .f.
			endIf
			
		endIf
		
		//valoracao do pagamento
		if lValorPagto

			aValor := PLSCALCEVE(cCodPad,cCodPro,cMesPag,cAnoPag,cCodInt,cCodRDA,cEspec,cSubEsp,;
								 cCodLoc,nQtd,BD6->BD6_DATPRO,aDadUsr[48],cPadInt,cRegAte,BD6->BD6_VLRAPR,aDadUsr,cPadCon,;
								 aQtdPer,cCodTab,cAliasTab,nil,nil,cHorPro,aRdas,.f.,BD6->BD6_PROREL,BD6->BD6_PRPRRL,;
								 aValAcu,lReembolso,dDatCir,cHorCir,aUnidsBlo,cTipoGuia,.f.,BD6->BD6_VLRAPR,{},nil,;
								 lCirurgico,nPerVia,cRegPag,cRegCob,nQtd,nil,aPacote,cChaveGui,BD6->BD6_SEQUEN,;
								 nil,nil,cRegInt,cFinAte,cChavLib,nil,nil,lCalcTX,aRdaAux,cTipAdm,aComEve,,BD6->BD6_RDAEDI,,BD6->BD6_HORFIM)
								 
			//Verifica se teve critica de tabela para pagamento de pacote nao encontrada
			lRetCon := .f.
			
			for nInd := 1 to len(aValor[1])
				
				if ! lRetCon .and. len(aValor[1][nInd]) >= 1 .and. valType(aValor[1][nInd]) == "A" .and. valType(aValor[1][nInd,1]) == "A" .and. len(aValor[1][nInd,1]) >= 3 .and. valType(aValor[1][nInd,1,3]) == "L" .and. ! aValor[1][nInd,1,3]
					
					lRetCon := .t.
 
					aadd(aRetCom,{ aValor[1][nInd,1,6], aValor[1][nInd,1,4],cCodPad + "-" + cCodPro,"2","1",cCodPad,cCodPro } )
	
					aRetFun[1] := .f.
					aadd(aRetFun[2],{ aValor[1][nInd,1,6], aValor[1][nInd,1,4],"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
					
				endIf
				
				if ! empty(aValor[1][nInd][4])
	
					aRetFun[1] := .f.
					aadd(aRetFun[2],{ aValor[1][nInd][6], aValor[1][nInd][4],"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
					
				endIf
				
			next
			
			if lRet .and. ! aRetFun[1]
				lRet := .f.
			endIf
			
			nVlrBPR   	:= aValor[2]
			cCodTab   	:= aValor[3]
			cAliasTab 	:= aValor[4]
			nPercHEsp 	:= aValor[5]
			nFatMul		:= aValor[8]
			
			if len(aValor) >= 6
				nPrTxPag := aValor[6]
			endIf
	
			if len(aValor) >= 9
				nPerInss := aValor[9]
			endIf

			BD6->(recLock("BD6",.f.))
				BD6->BD6_CODTAB := cCodTab
				BD6->BD6_ALIATB := cAliasTab
				BD6->BD6_PERHES := nPercHEsp
				if BD6->BD6_FATMUL == 0
					BD6->BD6_FATMUL := nFatMul
				endif
			BD6->(msUnLock())			

			aAux  	:= aClone(aValor[1])
			aRetFun := PL720GPG(aAux, aUnidsVLD, cLocalExec, nPercHEsp, nPrTxPag, aRetFun, nDifUs, nVlrDifUs, @aBDXSeAnGl, lBloPag, cTipoGuia, nPerInss, IIF(lTempRDAMV, aretcom, {}))

			if len(aRetFun) >= 3
				
				nVlrPagBru := aRetFun[3]
				
				if len(aRetFun) >= 4
					nVlrTxPg := aRetFun[4]
				endIf
				
				if len(aRetFun) >= 5
					nVlrPagLiq := aRetFun[5]
				endIf
				
			endIf

			//Caso não haja taxa apresentada, não há pq validar a crítica 061
			if nPrTxPag > 0 .AND. BD6->BD6_VLTXAP > 0
				PlTrtTxPa(nPrTxPag,nVlrPagBru,aDadUsr,nVlrTxPg,aRetFun,cLocalExec)
			endIf
			
			if lRet .and. ! aRetFun[1]
				lRet := .f.
			endIf
			
			//se tiver erro controlado nao pode deixar gravado a tabela 
			if ! aRetFun[1]	
				
				if aScan(aRetFun[2], {|x| x[1] == __aCdCri032[1] }) > 0

					BD6->(recLock("BD6",.f.))
						BD6->BD6_CODTAB := ''
						BD6->BD6_ALIATB := ''
					BD6->(msUnLock())	

				endIf	

			endIf	

		else
			
			aValor 		:= {}
	
			cCodTab   	:= ""
			cAliasTab 	:= ""
			nVlrBPR   	:= 0
			nPercHEsp 	:= 0
			nPrTxPag  	:= 0
			nPerInss	:= 0
			nVlrPagLiq 	:= 0
			nVlrPagBru 	:= 0
			
		endIf
		
		aadd(aValAcu,{BD6->BD6_CODPAD,BD6->BD6_CODPRO,aValor,BD6->BD6_DATPRO,cHorPro})
			
		//valoracao cobranca
		if lValorCobr
	
			// atualizo a variavel nVlrPagLiq quando revalorizar somente cobrança
			if ! lValorPagto
				
				nVlrPagLiq	:= 0
				nVlrPagBru	:= 0
				
				//Se nao foi bloqueado
				cQrVlLq := " SELECT SUM(BD7_VLRMAN) BD7_VLRMAN, SUM(BD7_VLRPAG) BD7_VLRPAG "
				cQrVlLq += "   FROM " + retSqlName("BD7")
				cQrVlLq += "  WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
				cQrVlLq += "    AND BD7_CODOPE = '" + BD6->BD6_CODOPE + "' AND BD7_CODLDP = '" + BD6->BD6_CODLDP + "' "
				cQrVlLq += "    AND BD7_CODPEG = '" + BD6->BD6_CODPEG + "' AND BD7_NUMERO = '" + BD6->BD6_NUMERO + "' "
				cQrVlLq += "    AND BD7_ORIMOV = '" + BD6->BD6_ORIMOV + "' AND BD7_SEQUEN = '" + BD6->BD6_SEQUEN + "' "
				cQrVlLq += "    AND BD7_BLOPAG <> '1' AND D_E_L_E_T_ = ' '"
				
				dbUseArea(.t.,"TOPCONN",tcGenQry(,,cQrVlLq),"VLRLIQ",.f.,.t.)
				
				if ! VLRLIQ->(eof())
					
					nVlrPagLiq := VLRLIQ->BD7_VLRMAN
					nVlrPagBru := VLRLIQ->BD7_VLRPAG
					
				endIf
				
				VLRLIQ->(dbCloseArea())
				
			endIf
			
			aCompoPF := {}
			
			//for um usuario valido e nao a cobranca nao estiver bloqueada
			if aDadUsr[1] .and. BD6->BD6_BLOCPA <> '1'
				
				cNivelAN := BD6->BD6_NIVAUT
				
				if empty(cNivelAN)
					cNivelAN := BD6->BD6_NIVCRI
				endIf
				
				cChvNiv := BD6->BD6_CHVNIV
				
				lCompra := .f.
				
				//E uma guia comprada (BEA_GUIACO = '1') so que sabemos que pode ser tanto uma compra
				//normal ou uma co-participacao que deve ser paga no ato
				//por isso que somente deve ser considerado como compra se BEA_GUIACO e '1' E nao foi paga no ato
				if BD6->BD6_GUIACO == "1" .and. BD6->BD6_PAGATO <> "1"
					lCompra := .t.
				endIf
				
				//se nao for uma guia comprada
				if lCompra .and. cMVPLSCPFB != "0"
					aUnidsBlo := {}
				endIf
				
				nVlrAprCob := 0
				nVlrAprCob := BD6->BD6_VLRACB
				
				//verifica a possibilidade de mudar o nivel para niveis que compoem a valoracao da coparticipacao
				//niveis de valoracao que requer autorizacao no mesmo nivel "BFG|BFE|BFD|BFC|BT7|BRV|BBK|BFE|BFC|BT7|BRV"
				getNivChk(.t., aDadUsr, @cNivelAN, @cChvNiv)

				aValor := PLSCALCCOP(cCodPad,cCodPro,cMesPag,cAnoPag,cCodRDA,cEspec,cSubEsp,cCodLoc,nQtd,BD6->BD6_DATPRO,.f.,;
									"2",nVlrBPR,cGrpInt,aDadUsr,cPadInt,cPadCon,aQtdPer,cRegAte,nVlrAprCob,.t.,lCompra,cHorPro,aRdas,;
									cOpeRDA,cTipPreFor,BD6->BD6_PROREL,BD6->BD6_PRPRRL,aValAcu2,cNivelAN,cChvNiv,dDatCir,cHorCir,;
									BD6->BD6_CID,aUnidsBlo,cTipoGuia,aCobAcu,BD6->BD6_VLRAPR,{},BD6->BD6_MODCOB,;
									nVlrPagBru,BD6->(recno()),lCirurgico,nPerVia,cRegPag,cRegCob,nQtd,nil,;
									aPacote,cChaveGui,BD6->BD6_SEQUEN,aRetCom,cRegInt,cFinAte,aValor,cChavLib,lAuditoria,;
									BD6->BD6_DENREG,BD6->BD6_FADENT,lMudarFase,cHorPro6C,,nVlrPagLiq, cTipAdm)
				
				//retorna ao nivel original
				getNivChk(.f., nil, @cNivelAN, @cChvNiv)

				if !lPacGenEpt .AND. aValor[1] .and. iIf(len(aValor) >= 27, ! aValor[27],.t.)
					
					//base e valor da coparticipacao
					nPerCop   := aValor[05]
					nValCop   := aValor[09]
					
					nVlrBPF   := aValor[11]
					nVlrTPF   := aValor[12]
					nVlrPF    := aValor[13]
					
					//taxa
					nPerTAD   := aValor[07]
					nVlrTAD   := aValor[14]
	
					cAliasEn  := aValor[15]
					cPgNoAto  := aValor[16]
					aCompoPF  := aValor[17]
					
					cCDTBRC	  := iIf( len(aCompoPF) > 0, aCompoPF[3],"" )
					
					if len(aValor) >= 26
						nPrCbHEsp := if(len(aValor) >= 26,aValor[26],0)
					endIf
	
					//pagar coparticipacao para RDA somente com utilizacao do ponto de entrada PLSRETC2
					cPdDrRDA  := if(len(aValor) >= 18,aValor[18],"0")
					nLimFra   := if(len(aValor) >= 19,aValor[19],0)
					nSlvBase  := if(len(aValor) >= 20,aValor[20],0)
					nSlvPerc  := if(len(aValor) >= 21,aValor[21],0)
					nSlvTx    := if(len(aValor) >= 22,aValor[22],0)
					nSlvTotal := if(len(aValor) >= 23,aValor[23],0)
					nPerda    := if(len(aValor) >= 24,aValor[24],0)
					cFranquia := if(len(aValor) >= 25,aValor[25],"0")
					nPrCbHEsp := if(len(aValor) >= 26,aValor[26],0)
					nPerMaj	  := if(len(aValor) >= 29,aValor[29],0)

					if nLimFra > 0 .AND. QTDBD6Gui() > 1
						setLimFra(nLimFra, nVlrTAD, @nVlrBPF, @nVlrTPF, @nVlrPF, nPerTAD)
					endIf	
	
				else
					
					aCompoPF := {}
					
					//Se nao houve co-participacao devo zerar dados de co-participacao do BD6XBD7
					//Este caso serve para situacoes onde existia co-participacao lancada e na revalorizacao
					//ela foi retirada. neste caso e executada a funcao generica para limpar dados do bd6 atual...
					if nVlrBPF > 0
						PLS720ZCB("1",cChaveGui + BD6->BD6_SEQUEN,cAlias,.t.)
					else
					
						BD6->(recLock("BD6",.f.))
							BD6->BD6_CNTCOP := "1"
						BD6->(msUnLock())

					endIf
					
					nPrCbHEsp := 0
					
				endIf
				
				aadd(aValAcu2,{BD6->BD6_CODPAD,BD6->BD6_CODPRO,aCompoPF,BD6->BD6_DATPRO,cHorPro})
				aadd(aCobAcu,{BD6->BD6_CODPAD,BD6->BD6_CODPRO,aValor})
				
				//coparticipacao encontrada
				if len(aCompoPF) > 0 
	
					aAux  := aClone(aCompoPF[1])
					
					PL720GCP(aAux, nPerCop, nValCop, @nVlrBPF, @nVlrPF, @nVlrTPF, @nVlrTAD, nPerTAD,;
						 	 nPrCbHEsp, cAliasEn, cPgNoAto, nPerMaj, aCobertPro, cFranquia,;
						 	 nSlvTotal, nSlvBase, nLimFra, nPerda, nSlvTx, nSlvPerc, cPdDrRDA, cCDTBRC,;
							 aUnidsVLD, aCalcEve, abkpEvPg, lPacGen)	
	
				endIf
				
			endIf
			
		endIf	
	
		//revaloracao pagamento, cobranca ou pagamento e cobranca
		//verica se tem glosa e considera
		if lProcRev .AND. !(IsInCallStack("PLSA500ACT"))
	
			//esta funcao se encontrar BDX muda a fase da guia.
			P720NewBDX(aRetFun,cAlias,@lHelp)
			
			if lRet
				lRet := aRetFun[1]
			endIf	
			
		endIf
	
		//totais para atualizar o cabecalho da guia
		getTotBD6(aMatTOTCAB)
				
	else
	
		PLSPOSGLO(PLSINTPAD(),__aCdCri032[1],__aCdCri032[2])
		
		lRet := .f.

		if PCLPGAUTO()
			aBDXSeAnGl[1] := .f.
			aadd(aBDXSeAnGl[2],{__aCdCri032[1],"Verifique a composição do evento [ " + BD6->BD6_CODPAD + "-" + allTrim(BD6->BD6_CODPRO) + " ] ","",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
		else
			aRetFun[1] := .f.
			aadd(aRetFun[2],{__aCdCri032[1],"Verifique a composição do evento [ " + BD6->BD6_CODPAD + "-" + allTrim(BD6->BD6_CODPRO) + " ] ","",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
		endIf
		
	endIf
	
	if BD6->BD6_BLOPAG == "1" .and. BD6->BD6_ENVCON == "1"
	
		if lRet .or. aRetFun[1]
			lRet 		:= .f.
			aRetFun[1] 	:= .f.
		endIf
		
		cCodBlo := BD6->BD6_MOTBPG
		cDesBlo := BD6->BD6_DESBPG
		
		if empty(cCodBlo)
			cCodBlo := __aCdCri235[1]	
			cDesBlo := __aCdCri235[2]
		endIf
		
		if PLSPOSGLO(PLSINTPAD(),cCodBlo,cDesBlo,cLocalExec) .and. PLSCHKCRI( {'BAU',BD6->BD6_CODRDA,cCodBlo} )
			
			if PCLPGAUTO()
				aadd(aBDXSeAnGl[2],{cCodBlo,cDesBlo,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
			else
				aadd(aRetFun[2],{cCodBlo,cDesBlo,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
			endIf
			
		else
		 
			BD6->(RecLock("BD6", .F.))
				PLBLOPC('BD6', .f., nil, nil, .t., .f., .f.)
			BD6->(MsUnLock())

		endIf
		
	endIf
		
	if lPLS720EV

		aRetPto := execBlock("PLS720EV", .f., .f., { cTipoGuia, cLocalExec, lValorCobr, lValorPagto, cAlias, cChaveGui, lRet, aRetFun } )

		if valType(aRetPto) == "A"
			lRet    := aRetPto[1]
			aRetFun := aRetPto[2]
		endIf

	endIf
	
	//somente para o evento posicionado or mudanca de fase por item
		if lBD6Pos .or. lMfItem
			exit
		endIf

BD6->(dbSkip())	
endDo

BD6->(restArea(aAreaBD6))

//TODO - 11/03/2017 - ROMULO - necessario rever esta funcao / alterando o valor de coparticipacao
//TODO - 11/03/2017 - ROMULO - se a logica estiver correta necessario colocar no RETCOP para devolver o valor correto da coparticipacao
if len(aDadBD6) > 0 .and. lRet
	setCOPBD6(aDadBD6, nValCopF)
endIf

if ! lRet 
	
	aCri := aClone(aRetFun[2])
	
	if lHelp .and. len(aCri) > 0 .and. lProcRev
		PLSXCRIGUI(aCri, "1", "", BCL->BCL_ALIAS)
	endIf
	
endIf

BCL->( restArea(aAreaBCL) )

if ! lRet .and. empty(aCri) .and. empty(aBDXSeAnGl) 
	lRet := .t.
endIf

return( { lRet, aCri, aBDXSeAnGl } )

//-------------------------------------------------------------------
/*/{Protheus.doc} QTDBD6Gui
Verifica se há mais de um BD6 para um evento, pois, caso haja, deve aplicar a verificação de limite de franquia
@author  Oscar
@version P12
@since   15/04/2019
/*/
//------------------------------------------------------------------- 
Static function QTDBD6Gui()
Local nRet := 1
Local csql := ""

cSql += " Select Count(1) QTD from " + retsqlName("BD6") 
cSql += " Where "
cSql += " BD6_FILIAL = '" + xfilial("BD6") + "' "
cSql += " AND BD6_CODOPE = '" + BD6->BD6_CODOPE + "' "
cSql += " AND BD6_CODLDP = '" + BD6->BD6_CODLDP + "' "
cSql += " AND BD6_CODPEG = '" + BD6->BD6_CODPEG + "' "
csql += " AND BD6_NUMERO = '" + BD6->BD6_NUMERO + "' "
csql += " AND BD6_CODPAD = '" + BD6->BD6_CODPAD + "' "
cSql += " AND BD6_CODPRO = '" + BD6->BD6_CODPRO + "' "
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"QTDBD6Gui",.F.,.T.)

nRet := QTDBD6Gui->QTD

QTDBD6Gui->(DbCloseArea())

return nRet

static function PLTmpMVZ1(lValor)
return lTempRDAMV := lValor

//Retorna as informações dos itens do pacote para a valoração do pacote genérico
static function GetCompPac()
Local aRet := {}
Local cSql := ""

cSql += " Select * From " + RetSqlName("B43")
cSql += " Where "
cSql += " B43_FILIAL = '" + xFilial("B43") + "' AND "
cSql += " B43_CODOPE = '" + BD6->BD6_CODOPE + "' AND "
cSql += " B43_CODLDP = '" + BD6->BD6_CODLDP + "' AND "
cSql += " B43_CODPEG = '" + BD6->BD6_CODPEG + "' AND "
cSql += " B43_NUMERO = '" + BD6->BD6_NUMERO + "' AND "
cSql += " B43_SEQUEN = '" + BD6->BD6_SEQUEN + "' AND "
cSql += " D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"ITEPAC",.f.,.t.)

While !(ITEPAC->(EoF()))
	aadd(aRet, {BD6->BD6_DATPRO, ITEPAC->B43_CODPAD, ITEPAC->B43_CODPRO, BD6->BD6_QTDPRO, 0})
	ITEPAC->(dbskip())
endDo

ITEPAC->(dbclosearea())

return aRet

//Ajusta o aValor com as parciais do aValorX
static function AjustArr(aTot,aParc,nVez)

If nVez == 1
	aTot := aClone(aParc)
else
	aTot[6] += aParc[6]
	aTot[12] += aParc[12]
	aTot[13] += aParc[13]
	aTot[14] += aParc[14]
endif

aTot[5] := 0 //percentual
aTot[11] := 0 //bASE Coart
aTot[15] := "B43" //alias n´vel
aTot[16] := "0" //franquia

return

//Coloca o array de c´riticas no padrão pro aRetCom, das críticas automáticas
//função não dá return, os parâmetros tem que ser apssados com @
static function arrayNormal(aCriticas,aRetcom)
Local nI := 1

For nI := 1 To Len(aCriticas)
	aadd(aRetcom,aCriticas[nI])
next

return
