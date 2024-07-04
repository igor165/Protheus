#INCLUDE "PLSA720.ch"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

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
STATIC lUnimed			:= allTrim(getNewPar("MV_PLSUNI","1")) == "1"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)

/*/{Protheus.doc} PLSA720INI
@type function
@author PLSTEAM
@since 15.08.02
@version 1.0
/*/
function PLSA720INI(aPar)
local cTipoGuia := aPar[1]
local cGuiRel   := aPar[2]
local cTipoTran := aPar[3]
local nOpc      := aPar[4]
local aDadRda   := PLSGETRDA()
local cCodRda
local cCodLoc
local cCodEsp
local aRetFun
local cAliasAux
local _dDatPro

if Len(aDadRda) == 0 .And. Len(aPar) >= 6  .And.Valtype(aPar[6]) == "L" .And. aPar[6] .And. Valtype(aPar[5]) == "A" 
	aDadRda := aClone(aPar[5])	
endIf	 

// testa se e algum processo externo via api...
if (cTipoGuia $ G_CONSULTA + "|" + G_SADT_ODON + "|" + G_HONORARIO + "|" + G_REC_GLOSA .or. cGuiRel $ G_CONSULTA + "|" + G_SADT_ODON + "|" + G_HONORARIO + "|" + G_REC_GLOSA ) .and. len(aDadRda) == 0 .and. nOpc == K_Visualizar 

	aRetFun := PLSDADRDA(BD5->BD5_OPERDA,BD5->BD5_CODRDA,"1",BD5->BD5_DATPRO,BD5->BD5_CODLOC,BD5->BD5_CODESP,BD6->BD6_CODPAD,BD6->BD6_CODPRO)

	if aRetFun[1]
		aDadRDA := PLSGETRDA()
	endIf
	
endIf

// Ponto de Entrada para alterar a Busca Padrao do campo BD5_LOCATE
if existBlock("P720BPAD")
	aDadRda := execBlock("P720BPAD",.f.,.f.,{aDadRda})
endIf

// Define valores default para os parametros...
if ( cTipoGuia $ G_CONSULTA + "|" + G_SADT_ODON + "|" + G_HONORARIO + "|" + G_REC_GLOSA .Or. cGuiRel $ G_CONSULTA + "|" + G_SADT_ODON + "|" + G_HONORARIO + "|" + G_REC_GLOSA) .and. ( nOpc == K_Incluir )
	M->BD5_LOCATE := aDadRda[18]
	M->BD5_CODESP := aDadRda[15]
	M->BD5_DESESP := aDadRda[17]
	M->BD5_CODLOC := aDadRda[12]
	M->BD5_LOCAL  := aDadRda[13]
	M->BD5_DESLOC := aDadRda[19]
	M->BD5_ENDLOC := aDadRda[20]
	M->BD5_CPFRDA := aDadRda[16]
endIf
//-------------------------------------------------
// Monta se necessario medico executante de forma automatica...
//-------------------------------------------------
if ( nOpc == K_Incluir ) .and. len(aDadRda) >= 23 .and. aDadRda[23] == "1"

	cCodRda := aDadRda[2]
	cCodLoc := aDadRda[12]
	cCodEsp := aDadRda[15]
	
	BC1->(dbSetOrder(1))
	if BC1->(msSeek(xFilial("BC1")+cCodRda+cCodLoc+cCodEsp))
		
		BC1->(dbSkip())
		
		if BC1->(BC1_FILIAL+BC1_CODIGO+BC1_CODLOC+BC1_CODESP) <> xFilial("BC1")+cCodRda+cCodLoc+cCodEsp
		
			BC1->(dbSkip(-1))
			
			cAliasAux := iIf(cTipoGuia $ G_SOL_INTER + "|" + G_RES_INTER,"BE4","BD5")
			
			if BD6->BD6_DATPRO == M->BD5_DATPRO
				_dDatPro := BD6->BD6_DATPRO
			else
				_dDatPro := M->BD5_DATPRO
			endIf
			
			if empty(BC1->BC1_DATBLO) .Or. BC1->BC1_DATBLO > _dDatPro

				BB0->(dbSetOrder(1))
				if BB0->(msSeek(xFilial("BB0")+BC1->BC1_CODPRF))
					&("M->"+cAliasAux+"_REGEXE") := BB0->BB0_NUMCR
					&("M->"+cAliasAux+"_NOMEXE") := BB0->BB0_NOME
					&("M->"+cAliasAux+"_CDPFRE") := BC1->BC1_CODPRF
					&("M->"+cAliasAux+"_ESTEXE") := BB0->BB0_ESTADO
				endIf
				
			endIf
			
		endIf
	endIf
endIf

return

/*/{Protheus.doc} PLSA720SAI
@type function
@author PLSTEAM
@since 15/08/2002
@version 1.0
/*/
function PLSA720SAI(aPar)
local cTipoGuia		:= aPar[1]
local lRet      	:= .t.
local aDadRda   	:= PLSGETRDA()

//para guia de consulta,Guia de honorarios, ou procedimento de consulta em outras guias, nao precisa de solicitante
if cTipoGuia $ G_SADT + "|" + G_SOL_INTER + "|" + G_REEMBOLSO + "|" + G_RES_INTER .and. !PlsIsCon(oBrwBD6:aCols[oBrwBD6:oBrowse:NAT,aScan(oBrwBD6:aHeader,{|x| x[2] == "BD6_CODPAD"})],oBrwBD6:aCols[oBrwBD6:oBrowse:NAT,aScan(oBrwBD6:aHeader,{|x| x[2] == "BD6_CODPRO"})]) .and. GetNewPar("MV_PLSOSOL","0") == "1" .and. empty(M->BD5_REGSOL) .and. empty(M->BE4_REGSOL)
	msgAlert(STR0138)
	lRet := .f.
endIf

if cTipoGuia $ G_SADT .and. empTy(M->BD5_TIPATE) .and. empTy(M->BD5_TIPATO) 
	msgAlert("Obrigatório o preenchimento do tipo de atendimento pra guias SADT e Odontológicas")
	lRet := .f.
elseIf cTipoGuia $ G_SADT .and. M->BD5_TIPATE == "04" .AND. empTy(M->BD5_TIPCON)
	msgAlert("Obrigatório o preenchimento do tipo de consulta para atendimentos do tipo Consulta")
	lRet := .f.
endIf

if len(aDadRda) > 0 .and. aDadRda[23] == "1" .and. empty(M->BD5_REGEXE)
	Help("",1,"PLSA090EXE")
	lRet := .f.
endIf

return(lRet)

/*/{Protheus.doc} PLSA720EDT
@type function
@author PLSTEAM
@since 15/08/2002
@version 1.0
/*/
function PLSA720EDT()
return(.t.)

/*/{Protheus.doc} PLSA720GRV
@type function
@author PLSTEAM
@since 15/08/2002
@version 1.0
/*/
function PLSA720GRV(aPar)
local nPosPro		:= 0
local nPosQtd		:= 0
local nForCpo		:= 0
local nFor			:= 0
local nQtdPro		:= 0
local nQtdTot  		:= 0
local nI		   	:= 0
local nPosBD6	   	:= 0
local nPrTxPag		:= 0
local nPerInss		:= 0
local nPosUnd		:= 0
local nForHea 	   	:= 1
local nRecAlt		:= 0
local cMacro		:= ""
local cCampoOri		:= ""
local cCodPro		:= ""
local cCodPad		:= ""
local cDente		:= ""
local cFace     	:= ""
local cChaveBDH     := ""
local dDtAlta 		:= ""
local cHrAlta 		:= ""
local cTipFat 		:= ""
local cGuiInt 		:= ""
local cMatrOrig  	:= ""
local cMatrNova  	:= ""
local cMatrCNova 	:= ""
local cAnoMesBDH 	:= ""
local cHorCir		:= ""
local cCodRda 		:= ""
local cCodInt 		:= ""
local cCodTab 		:= ""
local cChave		:= ""
local cAliasAlt		:= ""
local aCompo		:= {}
local aCposPad		:= {}
local aCpoNiv		:= {}
local aCodTab		:= {}
local aRetAux		:= {}
local aMatTOTBD7	:= {}
local aAreaBD6		:= {}
local aSeqAlt		:= {}
local aDadUsr    	:= PLSGETUSR()
local lCanPEG		:= .F.	
local lAltUsr    	:= .f.
local lFoundBD6		:= .f.
local lRecAlt		:= .t.
local nOpc      	:= aPar[1]
local cNumGui   	:= aPar[5]
local cAlias    	:= aPar[7]
local cTipoGuia 	:= aPar[8]
local cGuiRel   	:= aPar[9]
local cOriMov   	:= aPar[10]
local aItens       	:= if(len(aPar)>=11,aPar[11],{})
local aHeadItens   	:= if(len(aPar)>=12,aPar[12],{})
local aColsDF      	:= if(len(aPar)>=13,aPar[13],{})
local aHeaderDF    	:= if(len(aPar)>=14,aPar[14],{})
local aColsB47     	:= if(len(aPar)>=15,aPar[15],{})
local aHeadB47	   	:= if(len(aPar)>=16,aPar[16],{})
local cCodBlo	   	:= if(len(aPar)>=17,aPar[17],"")
local cDesBlo	   	:= if(len(aPar)>=18,aPar[18],"")
local cMotBlo      	:= if(len(aPar)>=19,aPar[19],"")
local aMatCom      	:= if(len(aPar)>=20,aPar[20],{})
local aPartic       := if(len(aPar)>=21,aPar[21],{})
local cSequen		:= if(len(aPar)>=22,aPar[22],"")
local aRecAlt		:= if(len(aPar)>=23,aPar[23],{{"","",0,0}})
local cCodPla    	:= if(len(aDadUsr) >= 11,aDadUsr[11],BA3->BA3_CODPLA)
local cOpeOri    	:= if(len(aDadUsr) >= 45,aDadUsr[45],BA1->BA1_OPEORI)
Local cMatCab		:= (cAlias)->&( "(" + cAlias + "_OPEUSR + " + cAlias + "_CODEMP + " + cAlias + "_MATRIC + " + cAlias + "_TIPREG )" )

BD6->(dbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
BR8->(dbSetOrder(1))//BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN

cChave := BCI->(BCI_CODOPE + BCI_CODLDP + BCI_CODPEG)

cChave += (cAlias)->&( "(" + cAlias + "_NUMERO + " + cAlias + "_ORIMOV ) " )

if ( nOpc == K_Incluir .or. nOpc == K_Alterar ) 

	//inss patronal
	nPerInss := plsPeInPt()
		
	//taxa adm
	nPrTxPag := getTxAdm(cAlias,aDadUsr)
	
	lFoundBD6 := BD6->( msSeek( xFilial("BD6") + cChave + cSequen ) )
	
	if  nOpc == K_Alterar
	
		if BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG) <> cMatCab .or. BD6->(BD6_MATCOB) <> cMatCab

			lAltUsr        := .t.
			cMatrOrig      := BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG)
			cMatrNova      := (cAlias)->&( "(" + cAlias + "_OPEUSR + " + cAlias + "_CODEMP + "  + cAlias + "_MATRIC + " + cAlias + "_TIPREG )" )
			cMatrCNova     := (cAlias)->&( "(" + cAlias + "_OPEUSR + " + cAlias + "_CODEMP + "  + cAlias + "_MATRIC + " + cAlias + "_TIPREG + " + cAlias + "_DIGITO )" )

			cAnoMesBDH     := BD6->(BD6_ANOPAG+BD6_MESPAG)

		endIf

	endIf
	
	do case
	
		case ( cTipoGuia $ G_CONSULTA + "|" + G_SADT_ODON + "|" + G_SOL_INTER .or. cGuiRel $  G_CONSULTA + "|" + G_SADT_ODON + "|" + G_SOL_INTER )
	
			(cAlias)->(recLock(cAlias,.f.))
			
			if type('oBrwBD6') == "O"
		
				nPosQtd := PLRETPOS("BD6_QTDPRO",oBrwBD6:aHeader)
		
				aEval(oBrwBD6:aCols,{|x| if(!x[len(oBrwBD6:aHeader)+1],nQtdTot += x[nPosQtd],nil) })
		
				(cAlias)->&( cAlias + "_QTDEVE" ) := nQtdTot
		
			elseIf type('oBrwPro') == "O"
		
				nPosQtd := PLRETPOS("BE2_QTDPRO",oBrwPro:aHeader)
		
				aEval(oBrwPro:aCols,{|x| if(!x[len(oBrwPro:aHeader)+1],nQtdTot += x[nPosQtd],nil) })
		
				(cAlias)->&( cAlias + "_QTDEVE" ) := nQtdTot
		
			endIf
		
			(cAlias)->(msUnLock())
			
			if len(aColsDF) > 0 .and. cTipoGuia == G_ODONTO
		
				BYT->( dbSetOrder(1) )
				BYT->(msSeek( xFilial("BYT") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + cNumGui))
		
				while ! BYT->(eof()) .and. BYT->(BYT_FILIAL + BYT_CODOPE + BYT_CODLDP + BYT_CODPEG + BYT_NUMERO) == xFilial("BYT")+BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)+cNumGui
		
					BYT->(recLock("BYT",.f.))
						BYT->(DbDelete())
					BYT->(msUnLock())
		
					BYT->(dbSkip())
				endDo
				
				aAreaBD6 := BD6->(getArea())
				
				for nFor := 1 To len(aColsDF)
		
					if BD6->( msSeek( xFilial("BD6") + cChave + aColsDF[nFor,PLRETPOS("BYT_SEQUEN",aHeaderDF)] ) )
		
						if aColsDF[nFor][len(aColsDF[nFor])] == .f.
		
							BYT->( dbSetOrder(1) )
		
							if ! BYT->( msSeek( xFilial("BYT") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + cNumGui + aColsDF[nFor,PLRETPOS("BYT_SEQUEN",aHeaderDF)] + aColsDF[nFor,PLRETPOS("BYT_CODIGO",aHeaderDF)] ) )
								BYT->(recLock("BYT",.t.))
							else
								BYT->(recLock("BYT",.f.))
							endIf
		
							BYT->BYT_FILIAL := xFilial("BYT")
							BYT->BYT_CODOPE := aColsDF[nFor,PLRETPOS("BYT_CODOPE",aHeaderDF)]
							BYT->BYT_CODLDP := aColsDF[nFor,PLRETPOS("BYT_CODLDP",aHeaderDF)]
							BYT->BYT_CODPEG := aColsDF[nFor,PLRETPOS("BYT_CODPEG",aHeaderDF)]
							BYT->BYT_NUMERO := cNumGui
							BYT->BYT_SEQUEN := aColsDF[nFor,PLRETPOS("BYT_SEQUEN",aHeaderDF)]
							BYT->BYT_CODIGO := aColsDF[nFor,PLRETPOS("BYT_CODIGO",aHeaderDF)]
							BYT->BYT_DESCRI := aColsDF[nFor,PLRETPOS("BYT_DESCRI",aHeaderDF)]
							BYT->BYT_TIPO   := aColsDF[nFor,PLRETPOS("BYT_TIPO",aHeaderDF)]
							BYT->BYT_SEGMEN := aColsDF[nFor,PLRETPOS("BYT_SEGMEN",aHeaderDF)]
							BYT->BYT_DESSEG := aColsDF[nFor,PLRETPOS("BYT_DESSEG",aHeaderDF)]
							BYT->BYT_M_ARCO := aColsDF[nFor,PLRETPOS("BYT_M_ARCO",aHeaderDF)]
							BYT->BYT_DESARC := aColsDF[nFor,PLRETPOS("BYT_DESARC",aHeaderDF)]
							BYT->BYT_CODPAD := aColsDF[nFor,PLRETPOS("BYT_CODPAD",aHeaderDF)]
							BYT->BYT_CODPSA := aColsDF[nFor,PLRETPOS("BYT_CODPSA",aHeaderDF)]
							BYT->BYT_FACES  := aColsDF[nFor,PLRETPOS("BYT_FACES",aHeaderDF)]
		
							BYT->(msUnLock())
		
						endIf
						
					endIf
					
				next
				
				BD6->(restArea(aAreaBD6))
				
			endIf
			
		case ( cTipoGuia $ G_REEMBOLSO + "|" + G_REC_GLOSA .or. cGuiRel $ G_REEMBOLSO + "|" + G_REC_GLOSA )
			
			if Type('oBrwPro') == "O"
			
				(cAlias)->(recLock(cAlias,.f.))
					
					if cTipoGuia $ G_REEMBOLSO
						nPosQtd := PLRETPOS("B45_QTDPRO",oBrwPro:aHeader)					
					endIf	
				
					aEval(oBrwPro:aCols,{|x| if(!x[len(oBrwPro:aHeader)+1],nQtdTot += x[nPosQtd],nil) })
				
					(cAlias)->&( cAlias + "_QTDEVE" ) := nQtdTot
					
				(cAlias)->(msUnLock())
				
			endIf
					
		case( cTipoGuia $ G_RES_INTER .or. cGuiRel $ G_RES_INTER )
		
			if type('oBrwPro') == "O"
	
				(cAlias)->(recLock(cAlias,.f.))					
					
					(cAlias)->&( cAlias + "_QTDEVE" ) := nQtdTot
		
				(cAlias)->(msUnLock())
				
			endIf
			
			aAreaBE4:= BE4->(getArea())
			
			dDtAlta := (cAlias)->&( cAlias + "_DTALTA" )
			cTipAlt := (cAlias)->&( cAlias + "_TIPALT" )
			cHrAlta := (cAlias)->&( cAlias + "_HRALTA" )
			cTipFat := (cAlias)->&( cAlias + "_TIPFAT" )

			cTipAl1 := posicione('BIY', 1, xFilial('BIY') + (cAlias)->&( "(" + cAlias + "_CODOPE + " + cAlias + "_TIPALT ) " ), 'BIY_MOTSAI')

			cGuiInt := (cAlias)->&( cAlias + "_GUIINT" )
		
			if ! empty(cGuiInt)
		
				//se eu estou digitando um resumo com tipo de faturamento total eu tenho que ir na solicitacao e fechar ela
				//tabela de dominio tipo de saida por transferencia para outro estabelecimento
				
				if ( cTipFat == 'T' .or. cTipFat == '4' ) .and. allTrim(cTipAl1) <> '31' 
		
					cSql := " SELECT R_E_C_N_O_ REC " 
					cSql += "   FROM " + retSqlName('BE4')
					cSql += "  WHERE BE4_FILIAL = '" + xFilial('BE4') + "'"
					cSql += "    AND BE4_CODOPE = '" + subStr(cGuiInt,1,4) + "'"
					cSql += "    AND BE4_CODLDP = '" + subStr(cGuiInt,5,4) + "'"
					cSql += "    AND BE4_CODPEG = '" + subStr(cGuiInt,9,8) + "'"
					cSql += "    AND BE4_NUMERO = '" + subStr(cGuiInt,17,8) + "'"
					cSql += "    AND D_E_L_E_T_ = ' ' "
		
					dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"TrbBe4d",.F.,.T.)
		
					if ! TrbBe4d->(eof())
		
						BE4->(dbGoto(TrbBe4d->(REC)))
		
						BE4->(recLock("BE4",.f.))
							BE4->BE4_DTALTA := dDtAlta
							BE4->BE4_HRALTA := cHrAlta
							BE4->BE4_TIPFAT := cTipFat
							BE4->BE4_TIPALT := cTipAlt
						BE4->(msUnLock())
		
					endIf
		
					TrbBe4d->(DbCloseArea())
				endIf
		
			endIf

			BE4->(restArea(aAreaBE4))
		
	endCase
	
	if lFoundBD6
		
		lRecAlt := len(aRecAlt) > 0
		
		for nI := 1 to len(aRecAlt)
			
			//se tiver aRecAlt vai fazer somente na sequencia se nao roda a bd6 na chave da guia sem o sequen.
			if lRecAlt .and. ! empty(aRecAlt[1,1])
			
				cAliasAlt := aRecAlt[nI,1]
				nRecAlt	  := aRecAlt[nI,3]
				
				if nRecAlt > 0
					
					(cAliasAlt)->(dbGoto(nRecAlt))
					
					cSequen := (cAliasAlt)->&( cAliasAlt + "_SEQUEN" )
					
					if aScan(aSeqAlt,{|x| x == cSequen} ) == 0
						aadd(aSeqAlt,cSequen)
					else
						loop			
					endIf 
					
				else
					loop	
				endIf
				
			endIf
				
			//exclui movimento contabil
			if  nOpc == K_Alterar
				PLSEXMCTB("D", cChave + cSequen )
			endIf		
			
			while ! BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) + iIf( ! empty(cSequen),BD6->BD6_SEQUEN,"") == xFilial("BD6") + cChave + cSequen
	
				// Gravacao complementar BD6
				PLBD6GRV(cAlias, nOpc, cTipoGuia, nPrTxPag, nPerInss, lAltUsr, cMatrCNova, cCodPla, cCodBlo, cDesBlo, cOpeOri, aDadUsr)
	
				// Gravacao complementar BD7
				PLBD7GRV(cAlias, nOpc, cTipoGuia, nPrTxPag, nPerInss, cCodpla, aMatCom, aPartic, nil, lAltUsr)
				
			BD6->(dbSkip())
			endDo
			
		next
		
		if lRecAlt
			
			//atualiza totais da guia
			PLGUITOT(cAlias, cChave,, .f.)
	
			//atualiza totais do peg
			PLPEGTOT()
			
		endIf	
		
	endIf
	
	// Se foi alteracao e teve mudanca de usuario ajustar BDH
	if lAltUsr
	
		BDH->(dbSetOrder(1))
		if BDH->( msSeek( xFilial("BDH") + cMatrOrig + cAnoMesBDH + "1") )

			while ! BDH->(eof()) .and. BDH->(BDH_FILIAL+BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_STATUS) == xFilial("BDH") + cMatrOrig + cAnoMesBDH + "1"
				
				//limpa seqpf a partir de um bdh
				PLSM180Del() 

				BDH->(recLock("BDH",.f.))
					BDH->(DbDelete())
				BDH->(msUnLock())
				
			BDH->(dbSkip())
			endDo
			
		else
			LimSEQPFGU(cAlias)
		endIf
		
		if BDH->( msSeek( xFilial("BDH") + cMatrNova + cAnoMesBDH + "1" ) )

			while ! BDH->(eof()) .and. BDH->(BDH_FILIAL+BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_STATUS) == xFilial("BDH")+cMatrNova+cAnoMesBDH+"1"
					
					//limpa seqpf a partir de um bdh
					PLSM180Del() 
	
					BDH->(recLock("BDH",.f.))
					BDH->(DbDelete())
					BDH->(msUnLock())
	
			BDH->(dbSkip())
			endDo
	
		else
			LimSEQPFGU(cAlias)
		endIf
		
	endIf

elseIf nOpc == K_Excluir
 
	if ( cTipoGuia $ G_CONSULTA + "|" + G_SADT_ODON + "|" + G_SOL_INTER + "|" + G_REEMBOLSO + "|" + G_RES_INTER + "|" + G_HONORARIO + "|" + G_REC_GLOSA .or. cGuiRel $ G_CONSULTA + "|" + G_SADT_ODON + "|" + G_SOL_INTER + "|" + G_REEMBOLSO + "|" + G_RES_INTER + "|" + G_HONORARIO + "|" + G_REC_GLOSA )

		BD6->(dbSetOrder(1))
		while BD6->( msSeek( xFilial("BD6") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + cNumGui + cOriMov ) )
			
			BD6->(recLock("BD6",.f.))
				BD6->(DbDelete())
			BD6->(msUnLock())
			
		endDo
	
		BD7->(dbSetOrder(1))
		while BD7->( msSeek( xFilial("BD7") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + cNumGui + cOriMov ) )
			
			BD7->(recLock("BD7",.f.))
				BD7->(DbDelete())
			BD7->(msUnLock())
			
		endDo
	
		B43->(dbSetOrder(1))
		while B43->( msSeek( xFilial("B43") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + cNumGui + cOriMov ) )
			
			B43->(recLock("B43",.f.))
				B43->(DbDelete())
			B43->(msUnLock())
			
		endDo
	
		B11->(dbSetOrder(1))
		while B11->( msSeek( xFilial("B11") + BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG) + cNumGui + cOriMov ) )
		
			B11->(recLock("B11",.f.))
				B11->(DbDelete())
			B11->(msUnLock())
			
		endDo

		// Atualiza totais do PEG
		PLPEGTOT()
		
	endIf
	
elseIf ( nOpc == K_Cancel .or. nOpc == K_Desbloq .or. nOpc == K_Bloqueio )

	cChaveBDH := (cAlias)->&( "(" + cAlias + "_OPEUSR + " + cAlias + "_CODEMP + " + cAlias + "_MATRIC + " + cAlias + "_TIPREG + " + cAlias + "_ANOPAG + " + cAlias + "_MESPAG + " + cAlias + "_SEQPF ) " )

	BDH->(dbSetOrder(3))
	if BDH->( msSeek( xFilial("BDH") + cChaveBDH ) )
		
		//Se esta consolidado exclui todos as ligacoes de eventos relativos a esta consolidacao
		PLSM180Del() 
		
		//Exclui a consolidacao referente a guia atual e a outras que estajam ligadas
		BDH->(recLock("BDH",.f.)) 
			BDH->(DbDelete())
		BDH->(msUnLock())
		
	endIf
	
	//Desbloqueio pode refazer competencia de guia...
	if nOpc == K_Desbloq 
	
		if getNewPar("MV_PLMDTPB","0") == "0"
			aRetAux := PLSXVLDCAL(dDataBase,PLSINTPAD(),.t.,"","")
		else
			aRetAux := PLSXVLDCAL( (cAlias)->&( cAlias + "_DATPRO" ),PLSINTPAD(),.t.,"","")
		endIf
		
	endIf

	// Ponto de Entrada para tratamento da data de competencia no momento do  desbloqueio
	if existBlock("PL720COMPE")
		aRetAux := execBlock("PL720COMPE",.f.,.f.,{aRetAux,(cAlias)->&( cAlias + "_DATPRO" ),(cAlias)->&( cAlias + "_ANOPAG" ),(cAlias)->&( cAlias + "_MESPAG" ) } )
	endIf
	
	(cAlias)->(recLock(cAlias,.f.))

	if nOpc == K_Cancel
	
		&(cAlias+"->"+cAlias+"_SITUAC") := "2" //Cancelado
		
		//na BD5 não tem esse campo
		if (cAlias)->( fieldPos( cAlias + "_STATUS" ) )
			(cAlias)->&( cAlias + "_STATUS" ) := "3" //Negado 
		endIf
			
		if (cAlias)->( fieldPos( cAlias + "_STTISS" ) ) 
			(cAlias)->&( cAlias + "_STTISS" ) := "6" //Cancelado 
		endIf
		
		if (cAlias)->( fieldPos( cAlias + "_CANCEL" ) ) 	
			(cAlias)->&( cAlias + "_CANCEL" ) := "1" 
		endIf

	elseIf nOpc == K_Desbloq
	
		(cAlias)->&( cAlias + "_SITUAC" ) := "1"
		(cAlias)->&( cAlias + "_MOTBLO" ) := ""

	elseIf nOpc == K_Bloqueio
	
		(cAlias)->&( cAlias + "_SITUAC" ) := "3"
		
	endIf

	if nOpc == K_Desbloq .and. aRetAux[1]
	
		(cAlias)->&( cAlias + "_ANOPAG" ) := aRetAux[4]
		(cAlias)->&( cAlias + "_MESPAG" ) := aRetAux[5]
		
	endIf

	if nOpc == K_Bloqueio .and. (cAlias)->( fieldPos( cAlias + "_MOTBLO" ) ) > 0
		
		(cAlias)->&( cAlias + "_MOTBLO" ) := cMotBlo
		
	endIf

	(cAlias)->(msUnLock())
   	
    if nOpc == K_Cancel
		
		if cAlias == "BE4" 
	
			if findFunction("PLCANPROG")
				PLCANPROG(BE4->(BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT))
			else
				msgAlert(STR0143)
			endIf
			
		endIf
		 
	endIf
	BD6->(DbsetOrder(1))
	if BD6->( msSeek( xFilial("BD6") + cChave ) )
	
		while ! BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial("BD6") + cChave
									
			BD6->(recLock("BD6",.f.))
			
			if nOpc == K_Cancel
			
				BD6->BD6_SITUAC := "2" //Cancelado
				
			elseIf nOpc == K_Desbloq
			
				BD6->BD6_SITUAC := "1" //Ativo
				
				if aRetAux[1]
					BD6->BD6_ANOPAG := aRetAux[4]
					BD6->BD6_MESPAG := aRetAux[5]
				endIf
				
			elseIf nOpc == K_Bloqueio
			
				BD6->BD6_SITUAC := "3" //Bloqueado
				
			endIf
			BD6->(msUnLock())

			//Retorna o saldo: 1=Digitacao;2=Conferencia;3=Pronta;4=Faturada
			if nOpc == K_Cancel .and. BD6->BD6_FASE $ '2;3'
				setRetSaldo(cAlias, cTipoGuia, .t.)
			endIf	

		BD6->(dbSkip())
		endDo
		
	endIf

	BD7->(dbSetOrder(1))
	
	if BD7->( msSeek( xFilial("BD7") + cChave ) ) 
	
		while ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV) == xFilial("BD7") + cChave

			BD7->(recLock("BD7",.f.))
			
			if nOpc == K_Cancel
			
				BD7->BD7_SITUAC := "2" //Cancelado
				
			//Ativo
			elseIf nOpc == K_Desbloq
			
				BD7->BD7_SITUAC := "1" 
				
				if aRetAux[1]
				
					BD7->BD7_ANOPAG := aRetAux[4]
					BD7->BD7_MESPAG := aRetAux[5]
					
				endIf
				
			//Bloqueado	
			elseIf nOpc == K_Bloqueio
			
				BD7->BD7_SITUAC := "3" 
				
			endIf
			
			BD7->(msUnLock())

		BD7->(dbSkip())
		endDo
		
	endIf
	
	if (nOpc == K_Desbloq .OR. nOpc == K_Bloqueio) .and. getNewPar("MV_PLATIOD","0") == "1" .and. getNewPar("MV_PLADPAG","0") == "1"
	
		PLS90CRDB(	(cAlias)->&( cAlias + "_OPERDA" ), (cAlias)->&( cAlias + "_CODRDA" ), (cAlias)->&( cAlias + "_CODLDP" ),;
					(cAlias)->&( cAlias + "_CODPEG" ), (cAlias)->&( cAlias + "_NUMERO" ), (cAlias)->&( cAlias + "_OPEUSR" ),;
					(cAlias)->&( cAlias + "_CODEMP" ), (cAlias)->&( cAlias + "_MATRIC" ), (cAlias)->&( cAlias + "_TIPREG" ),;
					(cAlias)->&( cAlias + "_CONEMP" ), (cAlias)->&( cAlias + "_VERCON" ), getNewPar("MV_PLCDADD","900"), nOpc)
					
	endIf

	if verificblq(BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG, IIF(BCI->BCI_TIPGUI == "05", "BE4", "BD5")) //lCanPEG
	
		if nOpc == K_Cancel
			BCI->(recLock("BCI",.f.))
				BCI->BCI_SITUAC := "2" 
				BCI->BCI_STTISS := "4"
			BCI->(msUnLock())
		endIf
	endIf
	 										   
endIf

return nil

/*/{Protheus.doc} getTxAdm
Retona taxa administrativa

@type function
@author PLSTEAM
@since 19.12.16
@version 1.0
/*/
static function getTxAdm(cAlias,aDadUsr) 
local nPrTxPag 		:= 0
local cFinAte		:= 0
local cPLSREGANVE	:= getNewPar("MV_PLSRADP","1")
local dDatAnalise  	:= stod("")

if BD6->BD6_VLRAPR > 0

	if existBlock("PLSDATAN")
	   cPLSREGANVE := execBlock("PLSDATAN",.f.,.f.,{BD6->BD6_TIPGUI,cPLSREGANVE})
	endIf 
	
	if cPLSREGANVE == "1" //data do evento
	
	   dDatAnalise := BD6->BD6_DATPRO
	   
	   if empty(dDatAnalise)
	      dDatAnalise := dDataBase
	   endIf
	   
	//data da mudanca de fase/valorizacao 
	else 
	   dDatAnalise := dDataBase
	endIf 

	if &(cAlias)->( fieldPos( cAlias + "_TIPPAC" ) ) > 0
	
		cFinAte := (cAlias)->&( cAlias + "_TIPPAC" )
		
	else
	
		cFinAte := getNewPar("MV_PLSTPAA","9")
		
	endIf

	If cAlias == "BD5"
		cRegAte := BD5->BD5_REGATE //1=Internação; 2=Ambulatorial
		
		if ! empty(BD5->BD5_REGFOR)
			cRegAte := BD5->BD5_REGFOR
		elseIf EmpTy(cRegAte)
			cRegAte := "2"
		endIf
	else
		cRegAte := "1"
	endIf

	nPrTxPag := PLSTXADM( (cAlias)->&(cAlias + "_TIPPRE"), BD6->BD6_CODPAD, BD6->BD6_CODPRO, (cAlias)->&(cAlias + "_CODESP"),;
						nil, nil, cFinAte, (cAlias)->&(cAlias + "_CODRDA"), nil, aDadUsr, dDatAnalise,cRegAte)
endIf

return(nPrTxPag) 			

/*/{Protheus.doc} PLSA720EVE
Calcula o valor do evento

@type function
@author PLSTEAM
@since 13.06.00
@version 1.0
/*/
function PLSA720EVE(cTipoGuia,cGuiRel,lHelp,cAnoPag,cMesPag,cAlias,cChaveGui,aDadUsr,cLocalExec,aDadRda,;
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
local nOrdBD7 		:= 0
local nOrdBD6 		:= 0
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
local lBD6_PRTXPG 	:= BD6->(fieldPos("BD6_PRTXPG")) > 0
local lBD7_VLRGTX 	:= BD7->(fieldPos("BD7_VLRGTX")) > 0

local nI			:= 0
local lMfItem		:= IsInCallStack('PLSA502')
local lPLS720EV     := existBlock("PLS720EV")
Local abkpEvPg	:= {}
Local aCompTmp2	:= {}
Local nContB4R	:= 0
Local nAAA := 0
Local cPacGenPtu := GetNewPar("MV_PLPACPT","99999998")
Local cPaCopart	:= ""
Local lPacGen := .F.
Local lPacGenEpt := .F.
Local lPacGenZCP := .F.

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

if ! lBD6Pos

	BD6->(dbSetOrder(1))
	BD6->(msSeek(cFilBD6 + cChaveGui))
	
endIf

aAreaBD6 := BD6->(getArea())

if lValorCobr .and. lValorPagto .and. &(cAlias)->( fieldPos( cAlias + "_ERRO") ) > 0 .and. (cAlias)->&( cAlias + "_ERRO" ) == "1"
	PLS720ZCB("3",cChaveGui,cAlias)
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

if lMfItem
	cChaveGui := subStr(cChaveGui, 1, len(cChaveGui) - 3)
endIf

while ! BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == cFilBD6 + cChaveGui
	
	If lMsgProc
		IncProc('Calculando pagamento e coparticipação.' + chr(10) + chr(13) + ' Protocolo ' + BD6->BD6_CODPEG + ' Guia ' + BD6->BD6_NUMERO + ' Evento ' + BD6->BD6_SEQUEN)
	endIf
	
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
	
	if  ;
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
						if lBD6_PRTXPG .and. BD6->BD6_VLTXAP == 0 
							BD6->BD6_VLTXAP := ( BD6->BD6_VALORI * BD6->BD6_PRTXPG) / 100
						endIf
						
						if lTemCobr
							BD6->BD6_VLRACB := BD6->BD6_VALORI
						endIf
						
						PLBLOPC('BD6', .t., __aCdCri109[1], PLSBCTDESC(), .t., .f.,,.t.)
						
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
		lB4REXC:= .F.
		
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
										 "1", BD6->BD6_CODOPE, "", "1", "1", nil,iIf( ! empty(BAU->BAU_TIPPRE), BAU->BAU_TIPPRE, nil),nil, nil, cTipoGuia == G_REEMBOLSO , nil, nil, cRegAte)							 				
					
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

		else
			
			lFoundB4R := B4R->( msSeek( xFilial('B4R') + BD7->BD7_CODRDA))
			
			if lFoundB4R 
				
//				if len(aUnidSaud) == 0
					aUnidSaud := PLB4REXC(BD7->BD7_CODRDA, BD7->BD7_CODPAD, BD7->BD7_CODPRO, BD6->BD6_CODLOC + BD6->BD6_lOCAL, BD7->BD7_CODESP, BD7->BD7_CODUNM)
//				endIf	
							//Os ORs são por conta do HM, pra não ter problemas com falso positivo (por causa do HMR) ou PA (por causa do PAR e PAP) e não deixar de considerar por conta de espaços
				lB4REXC := aScan(aUnidSaud, {|x| BD7->BD7_CODUNM $ x } ) > 0 .OR. aScan(aUnidSaud, {|x| AllTrim(BD7->BD7_CODUNM)+"," $ x } ) > 0 .OR. aScan(aUnidSaud, {|x| AllTrim(BD7->BD7_CODUNM) == "HM" .AND. Alltrim(x) == "HM" } ) > 0 .OR. aScan(aUnidSaud, {|x| AllTrim(BD7->BD7_CODUNM) == "PA" .AND. Alltrim(x) == "PA" } ) > 0
			
			endIf
					
		endIf	

		BD7->( recLock("BD7", .f.) )
		
			if BD6->BD6_BLOPAG == "1" .and. BD6->BD6_ENVCON == "1"
		
				PLBLOPC('BD7', .f., nil, nil, .t., .f., .f.)
				
			else

				if alltrim(BD6->BD6_MOTBPG) $ __aCdCri109[1] + '|' + __aCdCri110[1] + '|' + __aCdCri111[1] //Verifica se ha criticas relacionadas a OPME
					PLBLOPC('BD7', .t., BD6->BD6_MOTBPG, BD6->BD6_DESBPG,,,,.t.)
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
		//Se for o pacote genérico não exclui no retorno de fase pois foi gravado na importação do A500
		if B43->(msSeek(xFilial("B43") + cChaveGui + BD6->BD6_SEQUEN) ) .and. cCodPro <> cPacGen
			
			cAnoB43  := B43->B43_ANOAUT
			cMesB43  := B43->B43_MESAUT
			cNautB43 := B43->B43_NUMAUT				 		
			aRetAjB  := PlRetPac(cCodInt,cCodRda,cCodPad,cCodPro,nil,BD6->BD6_DATPRO)

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
			 		
			aRetAjB  := PlRetPac(cCodInt,cCodRda,cCodPad,cCodPro,nil,BD6->BD6_DATPRO)

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
		
		lCalcTX := iif(cTipoGuia == G_REC_GLOSA, .f., .t.)
		
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
 
					aadd(aRetCom,{ { aValor[1][nInd,1,6], aValor[1][nInd,1,4],cCodPad + "-" + cCodPro,"2","1",cCodPad,cCodPro } } )
	
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
			aRetFun := PL720GPG(aAux, aUnidsVLD, cLocalExec, nPercHEsp, nPrTxPag, aRetFun, nDifUs, nVlrDifUs, @aBDXSeAnGl, lBloPag, cTipoGuia, nPerInss)
			
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
									BD6->BD6_DENREG,BD6->BD6_FADENT,lMudarFase,cHorPro6C,,nVlrPagLiq, cTipAdm,,BD6->BD6_HORFIM) 
				
				//retorna ao nivel original
				getNivChk(.f., nil, @cNivelAN, @cChvNiv)

				if !lPacGenEpt .AND.  len(aValor) > 0 .AND. Valtype(aValor[1]) == "L" .AND. aValor[1] .and. iIf(len(aValor) >= 27, ! aValor[27],.t.)
					
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
						PLS720ZCB("1",cChaveGui,cAlias,.t.)
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
		
		//somente para o evento posicionado or mudanca de fase por item
		if lBD6Pos .or. lMfItem
			exit
		endIf
		
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
	
BD6->(dbSkip())	
endDo

BD6->(restArea(aAreaBD6))

//Bloqueio pagamento conforme PE + parametro
if ! lProcRev .and. lBD4VIG
	
	PLS63DUP(@aRetFun, cLocalExec, BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, BD6->BD6_CODRDA)
	
	if lRet	
		lRet := aRetFun[1]
	endIf	
	
endIf

if lMsgProc
   incProc( 'Cálculos finais - Protocolo ' + subs(cChaveGui,9,8) + ' Guia ' + subs(cChaveGui,17,8) )
endIf

//TODO - 11/03/2017 - ROMULO - necessario rever esta funcao / alterando o valor de coparticipacao
//TODO - 11/03/2017 - ROMULO - se a logica estiver correta necessario colocar no RETCOP para devolver o valor correto da coparticipacao
if len(aDadBD6) > 0 .and. lRet
	setCOPBD6(aDadBD6, nValCopF)
endIf

//atualiza o cabecalho da guia
PLGUITOT(cAlias, cChaveGui, aMatTOTCAB)

if ! lRet 
	
	aCri := aClone(aRetFun[2])
	
	if lHelp .and. len(aCri) > 0 .and. lProcRev
		PLSXCRIGUI(aCri, "1", "", BCL->BCL_ALIAS)
	endIf
	
endIf

BCL->( restArea(aAreaBCL) )

if lMsgProc
   IncProc('Gravações finais - Protocolo ' + subs(cChaveGui,9,8) + ' Guia ' + subs(cChaveGui,17,8))
endif

if ! lRet .and. empty(aCri) .and. empty(aBDXSeAnGl) 
	lRet := .t.
endIf

return( { lRet, aCri, aBDXSeAnGl, cPgNoAto } )

/*/{Protheus.doc} PLSA720MF
Muda a fase
@type function
@author plsteam
@since 13.06.00
@version 1.0
/*/
function PLSA720MF(aPar)
local aArea     	:= getArea()
local aAreaBCI 		:= BCI->(getArea())
local aAreaBD6 		:= BD6->(getArea())
local aAreaBCL 		:= BCL->(getArea())
local aAreaAlias	:= {}
local aAreaBAU		:= {}
local aInfRed		:= {}
local nI			:= 0
local nJ        	:= 0
local nPos			:= 0
local lRet			:= .f.
local nRecVBD7  	:= 0
local nVlrTxPg  	:= 0
local nVlrGlTx		:= 0
local nPerCop		:= 0
local nVlrPagBru	:= 0
local nIndRecBD6	:= 0
local nPerda		:= 0
local nTotEventos	:= 0
local nCont			:= 0

local nBDX_VLRMAN 	:= 0
local nBDX_VLRPAG 	:= 0
local nBDX_VLTXPG 	:= 0
local nBDX_PERGLO 	:= 0
local nBDX_VLRGLO 	:= 0
local nBDX_VLRGTX 	:= 0
local cBDX_TIPGLO	:= '1'

local lBDX_FOUND	:= .f.
local lGloAuto		:= .f.
local lValido		:= .f.

local cAlias    	:= aPar[1]
local cTipo     	:= aPar[2]
local cCodOpe   	:= aPar[3]
local cTipoGuia 	:= aPar[4]
local cCpoFase  	:= aPar[5]
local cCodLDP   	:= aPar[6]
local cCodPEG   	:= aPar[7]
local cGuiRel   	:= aPar[8]
local lAutori  		:= aPar[09]
local dDatPro   	:= aPar[10]
local lHelp     	:= aPar[11]
local cAliasPri 	:= aPar[16]
local aItensGlo 	:= aPar[17]
local cChavLib 		:= iIf( len(aPar) >= 31, aPar[31], "")
local lNegProPac	:= iIf( len(aPar) >= 32, aPar[32], .f.)
local lGetCri   	:= iIf( len(aPar) >= 33, aPar[33], .f.)
local aPLS475   	:= iIf( len(aPar) >= 29, aPar[29], {.f.,"",""})
local lPagAto   	:= iIf( len(aPar) >= 30, aPar[30], .f.)
local lProtoc		:= iIf( len(aPar) >= 34, aPar[34], .f.)
local aSequen		:= iIf( len(aPar) >= 36 .and. len(aPar[36]) > 0, aPar[36], {'NOTDEFINE'})
local isPLSA502		:= iIf( len(aPar) >= 37, aPar[37], .f.)

local cLocalExec	:= if(lAutori,"1","2")
local cNextFase		:= ""
local cTipPre   	:= ""
local cSQL      	:= ""
local cChaveGui		:= ""
local cMatricUsr	:= &(cAlias+"->("+cAlias+"_OPEUSR+" + cAlias + "_CODEMP+" + cAlias + "_MATRIC+" + cAlias+"_TIPREG)")
local cPacote   	:= ""
local aFiltro		:= {}
local aRetAux   	:= {.f.,{},{}}
local aRet      	:= {}
local aMatTOTBD7	:= {}
local aMatTOTCAB	:= {}
local lVlrACB   	:= BD6->BD6_VLRACB > 0
local lReanaliza	:= .t.
local lDoppler  	:= .f.
local cCodTabSlv	:= ""
local cNumLib		:= ""
local oBrwIte		:= nil
local lProcRev 		:= .f.
local lCopPag   	:= .f.
local aThreads		:= {}
local cNamePRI		:= (cAliasPri)->(retSqlName(cAliasPri))
local cNameBAU  	:= BAU->(retSqlName("BAU"))
local cFilBAU   	:= BAU->(xFilial("BAU"))
local cNameUser 	:= ""
local aDadUsr 		:= PLSGETUSR()
local lSolicit  	:= .f.
local lChkDopp 		:= getNewPar('MV_PLCKDOP','0') == '1'
local lGlosado 	  	:= getNewPar("MV_PLGLOSA",.f.)
local lRcMF       	:= getNewPar("MV_PLSRCMF",.t.) //Se Redutor de Custo deve ser aplicado na MF
local lNLocDig    	:= .f.
local cChvTipo2   	:= ""
local cSequen		:= ""	 
local isPLSA500ACT	:= isInCallStack('PLSA500ACT')
Local cBDX_ACAO		:= "SEM_ACAO"
Local cBDX_CODGLO	:= ""
Local aBkpIteglo	:= {}
Local nTotGLMant	:= 0
local lPL500GML		:= IsInCallStack("PLSA500GML")
local lPLGLOPEG		:= IsInCallStack("PLSGLOPEG")
local lPL500RCB		:= IsInCallStack("PLSA500RCB")

//Variáveis para tratar regra 5 CBHPM
Local cUniAux		:= GetNewPar("MV_PLSCAUX","AUX")
Local nCompTmp		:= 1
Local aVetAux		:= {}
Local aPrcsCir		:= {.F., {}}
Local nTamFld  		:= TamSX3("BD4_PORMED")[1]
Local cPortEve		:= ""

//Variáveis para tratar regra 5 CBHPM
Private aAuxCBHPM	:= {}
	
if len(aPar) >= 19

	lReanaliza := aPar[19]

	if len(aPar) >= 21

		oBrwIte := aPar[21]

		if len(aPar) >= 22

			lProcRev := aPar[22]

			if len(aPar) >= 23

				nIndRecBD6 := aPar[23]

				if len(aPar) >= 28
					lSolicit := aPar[28]
				endIf

			endIf

		endIf

	endIf

endIf

if BCL->BCL_TIPGUI <> cTipoGuia
	BCL->(dbSetOrder(1))
	BCL->(msSeek( xFilial("BCL") + PLSINTPAD() + cTipoGuia ) )
endIf

if cTipo == RETORNAFASE
	cNextFase := aPar[12]
endIf

// Guia de reembolso jah entra faturada
if cTipoGuia == G_REEMBOLSO
	lReanaliza := .f.
endIf

if len(aDadUsr) == 0 .or. aDadUsr[2] != cMatricUsr + (cAlias)->&( cAlias + "_DIGITO" ) 
	aDadUsr := PLSDADUSR(cMatricUsr + (cAlias)->&( cAlias + "_DIGITO" ),"1", .f., dDataBase)
endIf

// indica que deve calcular a co-participacao com base no valor pago ao prestador
lCopPag :=	iIf( len(aDadUsr) >= 72 , aDadUsr[72] == "1",.f.)

If Len(aItensGlo) > 0
	aBkpIteglo := aclone(aItensGlo)
endIf

BD6->(dbSetOrder(1)) //BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO

If (cTipo == MUDFASGUIA .OR. cTipo == MUDFASEPEG) .AND. GetNewPar("MV_PLCAAUX","1") == "3"// item (BR8->BR8_TIPEVE == "2")adicionado para que que ele vao vá ao while de bd6 e perca performane

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
Endif

// Tratamento para Movimentacao...
if cTipo == MUDFASGUIA

	// Guarda indice selecionado pelo usuario para restaurar no final
	aAreaAlias := (cAlias)->(getArea())
	
	PLMFGUIA(cAlias, 0, cTipo, cNameUser, aThreads, nCont, nTotEventos, aRetAux,;
		  	 cNextFase, cTipoGuia, cLocalExec, cGuiRel, lHelp, lSolicit, cChavLib, cCpoFase, lAutori,;
		  	 lReanaliza, isPLSA502, .f., dDatPro, lProtoc, lPagAto, lNegProPac, lGetCri, lCopPag )
	
	(cAlias)->(restArea(aAreaAlias))
	restArea(aArea)
	
// Tratamento para PEGS
elseIf cTipo == MUDFASEPEG
	
	// Guarda indice selecionado pelo usuario para restaurar no final
	aAreaAlias := (cAlias)->(getArea())
	
	aFiltro     := aPar[18]
 
	cNameUser	:= if(len(aPar) >= 27, aPar[27], "")
	nTotEventos	:= if(len(aPar) >= 24, aPar[24], 0)
	aThreads    := if(len(aPar) >= 25, aPar[25], {})
	nCont       := if(len(aPar) >= 26, aPar[26], 0)
	
	// Navega por todo os lancamentos do PEG...
	cSQL := " SELECT PRI.R_E_C_N_O_ AS REG "
	cSQL += "   FROM " + cNamePRI + " PRI, " + cNameBAU + " BAU " 
	cSQL += "  WHERE " + cAliasPri + "_FILIAL = '" + xFilial(cAliasPri) + "' "
	cSQL += "    AND " + cAliasPri + "_CODOPE = '" + BCI->BCI_CODOPE + "' "
	cSQL += "    AND " + cAliasPri + "_CODLDP = '" + BCI->BCI_CODLDP + "' "
	cSQL += "    AND " + cAliasPri + "_CODPEG = '" + BCI->BCI_CODPEG + "' "
	cSQL += "    AND " + cAliasPri + "_FASE   = '1' "
	cSQL += "    AND " + cAliasPri + "_SITUAC = '1' "
	cSQL += "    AND " + cAliasPri + "_STAFAT <> '0' "

	// Verifica data de/ate do evento caso a rotina seja chamada pelo PLSA475
	if valType(aPLS475) == "A" .and. aPLS475[1]
	    cSQL += "    AND " + cAliasPri + "_DATPRO BETWEEN '" + dtos(aPLS475[2]) + "' AND '" + iIf( ! empty(aPLS475[3]),dtos(aPLS475[3]),replicate('Z',len(dtos(aPLS475[3])))) + "' "
	endIf

	if len(aFiltro) >= 2
		cSQL += "    AND " + cAliasPri + "_CODOPE BETWEEN '" + aFiltro[1] + "' AND '" + aFiltro[2] + "' "
	endIf
	
	if len(aFiltro) >= 4
		cSQL += "    AND " + cAliasPri + "_CODEMP BETWEEN '" + aFiltro[3] + "' AND '" + aFiltro[4] + "' "
	endIf
	
	if len(aFiltro) >= 6
		cSQL += "    AND " + cAliasPri + "_CONEMP BETWEEN '" + aFiltro[5] + "' AND '" + aFiltro[6] + "' "
	endIf
	
	if len(aFiltro) >= 8
		cSQL += "    AND " + cAliasPri + "_SUBCON BETWEEN '" + aFiltro[7] + "' AND '" + aFiltro[8] + "' "
	endIf
	
	if len(aFiltro) >= 14
		cSQL += "    AND " + cAliasPri + "_LOCAL BETWEEN '" + aFiltro[13] + "' AND '" + aFiltro[14] + "' "
	endIf
	
	if cAliasPri $ 'B0R|BE4' .and. cTipoGuia <> G_RES_INTER
		cSQL += "    AND " + cAliasPri + "_DTALTA <> ' ' "
	endIf
	
	if len(aFiltro) >= 15 .and. ! empty(allTrim(aFiltro[15]))
		cSQL += PLSQINSQL(cAliasPri,allTrim(aFiltro[15]))
	endIf

	cSQL += "   AND PRI.D_E_L_E_T_ = ' ' "
	cSQL += "   AND BAU_FILIAL = '" + cFilBAU + "' "
	cSQL += "   AND BAU_CODIGO = " + cAliasPri + "_CODRDA "
	
	If Len(aFiltro) >= 17
		cSQL += " AND BAU_GRPPAG BETWEEN '" + aFiltro[17] + "' AND '" + aFiltro[18] + "' "
	Endif
	
	cSQL += "  AND BAU.D_E_L_E_T_ = ' ' "
	cSQL += "ORDER BY " + cAliasPri + "_FILIAL, " + cAliasPri + "_CODOPE, " + cAliasPri + "_CODLDP, " + cAliasPri + "_CODPEG, " + cAliasPri+"_FASE, "
	
	//	Ordem para processar a Mudança de Fase
	if getNewPar("MV_PLSDTMF", "0") == "1"	
		cSQL += cAliasPri + "_DATPRO, " + cAliasPri + "_NUMERO"	//	Data + Número
	else
		cSQL += cAliasPri + "_NUMERO, " + cAliasPri + "_DATPRO"	//	Número + Data
	endIf
	
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TrbFase",.f.,.t.)
  	
	while ! TrbFase->(eof())
		
		PLMFGUIA(cAlias, TrbFase->(REG), cTipo, cNameUser, aThreads, nCont, nTotEventos, aRetAux,;
			  	 cNextFase, cTipoGuia, cLocalExec, cGuiRel, lHelp, lSolicit, cChavLib, cCpoFase, lAutori,;
			  	 lReanaliza, .f., .t., dDatPro, lProtoc, lPagAto, lNegProPac, lGetCri, lCopPag)

	TrbFase->(dbSkip())
	endDo
	
	TrbFase->(dbCloseArea())
	
	(cAlias)->(restArea(aAreaAlias))
	restArea(aArea)
	
// Tratamento para somente mudar a fase...
elseIf cTipo == RETORNAFASE
	
	cChaveGui := (cAlias)->&( "(" + cAlias + "_CODOPE + " + cAlias + "_CODLDP + " + cAlias + "_CODPEG + " + cAlias + "_NUMERO + " + cAlias + "_ORIMOV ) " )

	//verifica se esta contabilizado 
	if PLCHKCTB('A',cChaveGui)
		return(aRetAux)
	endIf
		
	if ! lProcRev
		
		(cAlias)->(recLock(cAlias,.f.))
		
			(cAlias)->&( cAlias + "_FASE" ) := cNextFase
			
			if cNextFase == PRONTA
				
				//Data da mudanca de fase da guia
				if (cAlias)->( fieldPos( cAlias + "_DTANAL" ) ) > 0
					(cAlias)->&( cAlias + "_DTANAL" ) := dDataBase		
				endIf
				
				if BDX->BDX_VLRGLO == 0 .and. (cAlias)->&( cAlias + "_VLRGLO" ) > 0
					(cAlias)->&( cAlias + "_VLRGLO" ) := 0
				endIf
				
			elseIf cNextFase == DIGITACAO
				
				if BCI->( fieldPos('BCI_CODGLO') ) > 0
					
					BCI->(recLock("BCI",.f.))
						BCI->BCI_CODGLO := ""
						BCI->BCI_VLRGLO := 0
					BCI->(msUnLock())
					
				endIf
				
				if (cAlias)->( fieldPos( cAlias + "_CODGLO" ) ) > 0
					(cAlias)->&( cAlias + "_CODGLO" ) := ""
				endIf
				
				if (cAlias)->( fieldPos( cAlias + "_DTANAL" ) ) > 0
					(cAlias)->&( cAlias + "_DTANAL" ) := stod("")		//Data da mudanca de fase da guia
				endIf
				
				(cAlias)->&( cAlias + "_VLRBPR" ) := 0
				(cAlias)->&( cAlias + "_VLRMAN" ) := 0
				(cAlias)->&( cAlias + "_VLRGLO" ) := 0
				(cAlias)->&( cAlias + "_VLRPAG" ) := 0
				
				(cAlias)->&( cAlias + "_VLRBPF" ) := 0
				(cAlias)->&( cAlias + "_VLRPF" )  := 0
				(cAlias)->&( cAlias + "_VLRTAD" ) := 0
				(cAlias)->&( cAlias + "_VLRTPF" ) := 0
				
			endIf
		
		(cAlias)->(msUnLock())
		
	endIf

	lDoppler := .f.
	
	aAreaBD6 := BD6->(getArea())
	
	BD6->(dbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
	BD7->(dbSetOrder(1))//BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC
	
	//se nao veio nada no aSequen roda ate a chave Orimov
	for nI := 1 to len(aSequen)
		
		cSequen := ''
		
		if aSequen[nI] != 'NOTDEFINE' 
			cSequen := aSequen[nI]
		endIf	 
		
		if BD6->( msSeek( xFilial("BD6") + cChaveGui + cSequen ))
			
			while ! BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) + iIf( ! empty(cSequen), BD6->BD6_SEQUEN, "" ) == xFilial("BD6") + cChaveGui + cSequen
				
				if nIndRecBD6 <> 0 .and. nIndRecBD6 <> BD6->(recno())
					
					getTotBD6(aMatTOTCAB)
					
					BD6->(dbSkip())
					loop

				endIf
				
				//mudanca de fase
				if cNextFase == PRONTA
					
					nBDX_VLRMAN 	:= 0
					nBDX_VLRPAG 	:= 0
					nBDX_VLTXPG 	:= 0
					nBDX_PERGLO 	:= 0
					cBDX_TIPGLO		:= '1'
					nBDX_VLRGLO 	:= 0
					nBDX_VLRGTX 	:= 0
					lGloAuto		:= .f.					
					lBDX_FOUND		:= .f.
					
					nPos := aScan(aItensGlo, { |x| x[1] == BD6->BD6_SEQUEN } )
					
					if nPos > 0 
					
						lBDX_FOUND := .t.
						nTotGLMant := 0

						//Na glosa manual e glosar guia inteira o aItensGlo é só dos itens de análise de glosa, tem que fazer diferente mesmo
						if ! lPL500GML .and. ! lPLGLOPEG .and. ! lPL500RCB

							while (nPos := aScan(aItensGlo, { |x| x[1] == BD6->BD6_SEQUEN .and. x[6] == "2" } )) > 0
								
								nTotGLMant += aItensGlo[nPos,3]
								
								Adel(aItensGlo, nPos)
								asize(aItensGlo, Len(aItensGlo) - 1)

							endDo

						endIf
						
						If ! empty(aItensGlo)

							nPos := aScan(aItensGlo, { |x| x[1] == BD6->BD6_SEQUEN } )
							
							If nPos > 0
								nBDX_VLRMAN := aItensGlo[nPos,2] 
								nBDX_VLRGLO := aItensGlo[nPos,3]
								nBDX_VLRGTX	:= aItensGlo[nPos,5]
								cBDX_TIPGLO	:= aItensGlo[nPos,6]
								cBDX_ACAO 	:= aItensGlo[nPos,7] 	
								cBDX_CODGLO := aItensGlo[nPos,12]
								nBDX_VLRPAG := aItensGlo[nPos,13]
								nBDX_PERGLO := aItensGlo[nPos,14]
								nBDX_VLTXPG := aItensGlo[nPos,15]
								lGloAuto	:= aItensGlo[nPos,16]
							endIf

						else
							nBDX_VLRMAN := BD6->BD6_VLRMAN
						EndIf

						aItensGlo := aclone(aBkpIteglo)

					endIf
					
				endIf
				
				nVlrPagBru	:= 0
				cCodTabSlv 	:= BD6->BD6_CODTAB
				
				if lChkDopp 
					lDoppler := procDop(BD6->BD6_CODPAD,BD6->BD6_CODPRO,cCodTabSlv)
				endIf	
	
				//retorna a quantidade para o saldo
				if cNextFase == DIGITACAO
					setRetSaldo(cAlias, cTipoGuia, .t.)
				endIf	
				
				//coloca o evento em digitacao ou pronta
				plDigPro(cNextFase, __cBLODES, lDoppler, lProcRev, lCopPag, lGloAuto, @aMatTOTBD7, @nVlrPagBru,;
				  		 lBDX_FOUND, nBDX_VLRGLO, nBDX_VLRMAN, nBDX_VLTXPG, nBDX_VLRPAG, nBDX_VLRGTX, cBDX_ACAO, nBDX_PERGLO, cBDX_CODGLO, nTotGLMant)				

				if ! isPLSA500ACT .and. ( cNextFase == PRONTA .and. ! lProcRev ) .or. lGlosado 
					
					aAreaBD6 := BD6->(getArea())
					
					cTipPre := (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_TIPPRE" )
					
					if empty(cTipPre)
						
						aAreaBAU := BAU->(getArea())
						
						BAU->(dbSetOrder(1))
						BAU->(msSeek( xFilial("BAU") + (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_CODRDA" )))
						
						cTipPre := BAU->BAU_TIPPRE
						
						BAU->(restArea(aAreaBAU))
						
					endIf
					
					if lGlosado 
						
						PLS720ZCB("1",cChaveGui,BCL->BCL_ALIAS,.t.)
						
						PLSA720EVE(BCL->BCL_TIPGUI,BCL->BCL_GUIREL,.f.,&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_ANOPAG"),&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_MESPAG"),;
								   BCL->BCL_ALIAS,cChaveGui,{},cLocalExec,{},.t.,.f.,.t.,,,,,,,,{},{},cChavLib,,.t.)
					endIf
	
					BD6->(restArea(aAreaBD6))
					
				endIf
				
				if cNextFase == DIGITACAO .and. lDoppler
					
					PLS720IBD7( (cAlias)->&(cAlias + "_PACOTE" ), BD6->BD6_VLPGMA,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODTAB,BD6->BD6_CODOPE,BD6->BD6_CODRDA,;
								BD6->BD6_REGEXE,BD6->BD6_SIGEXE,BD6->BD6_ESTEXE,BD6->BD6_CDPFRE,BD6->BD6_CODESP,BD6->(BD6_CODLOC+BD6_LOCAL),"1",BD6->BD6_SEQUEN,;
								BD6->BD6_ORIMOV,BCL->BCL_TIPGUI,BD6->BD6_DATPRO)
					
				endIf
				
				//verifica se o total do BD7 esta igual ao BD6 e ajusta
				if cNextFase == PRONTA 
					setAjuGUI(aMatTOTBD7)
				endIf	
	
				//totais para atualizar o cabecalho da guia
				if empty(cSequen)
					getTotBD6(aMatTOTCAB)
				endIf	
				
			BD6->(dbSkip())
			endDo
			
		endIf
		
	next
	
	// Parcelamento de Co-Participacao ...
	if ! ( cTipoGuia $ G_SOL_INTER + "|" + G_RES_INTER + "|" + G_HONORARIO) .and.( ( cNextFase == PRONTA .and. ( nBDX_PERGLO <> 100 .or. (nBDX_PERGLO == 100 .and. getNewPar("MV_PLSGCGP","0")== "0") ) ) .Or.;
		 ( cTipo == "3" .and. cNextFase == DIGITACAO)) .and. BD5->BD5_PARCOP == "1" .and. BD5->BD5_NPARCE > 0
		
		PLSPARCOP(cTipo,cNextFase,cChaveGui,cMatricUsr)
		
	endIf
	
	PLGUITOT(cAlias, cChaveGui, aMatTOTCAB,, cNextFase, lProcRev)

	if ! lProcRev .and. cNextFase == PRONTA

		if existBlock("PLS720AG")
			execBlock("PLS720AG",.f.,.f.,{cTipoGuia,cLocalExec,cChaveGui,aItensGlo,oBrwIte})
		endIf
		
	endIf
	
	if existBlock("PLS720FIM")
		execBlock("PLS720FIM",.f.,.f.,{cTipoGuia,cChaveGui})
	endIf
	
endIf

BCL->(restArea(aAreaBCL))

//Executo Redução de Custo, caso parâmetro esteja true e a PEG/Guia Pronta e Ativa
lNLocDig := iIf( (cAlias)->&( cAlias + "_CODLDP" ) $ iIf( PLSOBRPRDA( (cAlias)->&( cAlias + "_CODRDA" ) ),PLSRETLDP(9),PLSRETLDP(5) ), .t., .f.)

//Se paga pelo apresentado, não roda redução de custo
if !(IsInCallStack("PLSRECGLO2") .or. IsInCallStack("PLSRECGLO3")) .AND. lRcMF .and. ! lNLocDig .and. (cAlias)->&( cAlias + "_FASE" ) == "3" .and.;
   (cAlias)->&( cAlias + "_SITUAC" ) == "1" .and. cTipo $ '1,2,3' .and. getTPCALC((cAlias)->&( cAlias + "_CODRDA" )) <> "3" .AND. ;
   PLSPOSGLO(PLSINTPAD(),__aCdCri231[1],__aCdCri231[2],"1") .and. aScan(aItensGlo,{|x| x[12] == __aCdCri231[1] } ) == 0
	
	//Quando for mudança de fase de PEG, tme que fazer esse esquema pra olharmos todas as guias até achar uma Ativa/Pronta
	//Se não o redutor pode dar ruim (ou não ser executado, ou ser executado sem ter guias pra reduzir)	
	if cTipo == "2" 
		
		if cAlias == "BE4"
		
			BE4->(DbsetOrder(1))
		
			cChvTipo2 := BE4->(xFilial("BE4")+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG)
		
			BE4->(dbGotop())
			BE4->(MsSeek(cChvTipo2))
			
		else
		
			BD5->(DbSetOrder(1))
			
			cChvTipo2 := BD5->(xFilial("BD5")+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG)
			
			BD5->(DbGoTop())
			BD5->(MsSeek(cChvTipo2))
			
		endIf
			
	endIf
	
	//Por guia / análise de glosa vai cair aqui
	If cTipo <> "2" 
		
		if (cAlias)->&( cAlias + "_FASE" ) == "3" .and. (cAlias)->&( cAlias + "_SITUAC" ) == "1"
			
			aAdd(aInfRed, { (cAlias)->&( cAlias + "_CODRDA" ) })
			aAdd(aInfRed, { (cAlias)->&( cAlias + "_CODOPE" ) })
			aAdd(aInfRed, { (cAlias)->&( cAlias + "_CODEMP" ) })
			aAdd(aInfRed, { (cAlias)->&( cAlias + "_MATRIC" ) })
			aAdd(aInfRed, { (cAlias)->&( cAlias + "_TIPREG" ) })
			aAdd(aInfRed, { (cAlias)->&( cAlias + "_CODPEG" ) })
			aAdd(aInfRed, { (cAlias)->&( cAlias + "_NUMERO" ) })
			aAdd(aInfRed, { (cAlias)->&( cAlias + "_DATPRO" ) })
			aAdd(aInfRed, { (cAlias)->&( cAlias + "_CODLDP" ) })
		
			PLSM250Pro("PLSM250   ", .t., "2", aInfRed, .f.)
			
		endIf
		
	else
	
		//Quando é por PEG, temos que ver se tem pelo menos uma que ficou Ativa e Pronta, quando achamos, daí fazemos o redutor
		while cChvTipo2 == (cAlias)->&( "( " + cAlias + "_FILIAL + " + cAlias + "_CODOPE + " + cAlias + "_CODLDP + " + cAlias + "_CODPEG ) " ) .and. ! (cAlias)->( eof() )
			
			if (cAlias)->&( cAlias + "_FASE" ) == "3" .and. (cAlias)->&( cAlias + "_SITUAC" ) == "1"

				aAdd(aInfRed, { (cAlias)->&( cAlias + "_CODRDA" ) })
				aAdd(aInfRed, { (cAlias)->&( cAlias + "_CODOPE" ) })
				aAdd(aInfRed, { "" })
				aAdd(aInfRed, { "" })
				aAdd(aInfRed, { "" })
				aAdd(aInfRed, { (cAlias)->&( cAlias + "_CODPEG" ) })
				aAdd(aInfRed, { "" })
				aAdd(aInfRed, { "" })
				aAdd(aInfRed, { (cAlias)->&( cAlias + "_CODLDP" ) })
			
				PLSM250Pro("PLSM250   ", .t., "2", aInfRed, .f.)
			
				exit
				
			endIf
			
			(cAlias)->( dbSkip() )
		endDo
		
	endIf
	
endIf

BD6->(restArea(aAreaBD6))
BCI->(restArea(aAreaBCI))

//atualiza o total do peg
PLPEGTOT()

if existBlock("PL720FIMMF")
	execBlock("PL720FIMMF",.F.,.F.,{cTipoGuia,cChaveGui,cTipo})
endIf	

return(aRetAux)

/*/{Protheus.doc} PLMFGUIA 
Muda fase guia (utilizado tb na mudanca de fase por peg)
@author  PLSTEAM
@version P12
@since   19.09.17
/*/
function PLMFGUIA(cAlias, nRecno, cTipo, cNameUser, aThreads, nCont, nTotEventos, aRetAux,;
				  cNextFase, cTipoGuia, cLocalExec, cGuiRel, lHelp, lSolicit, cChavLib, cCpoFase, lAutori,;
				  lReanaliza, isPLSA502, lPeg, dDatPro, lProtoc, lPagAto, lNegProPac, lGetCri, lCopPag)
local cMatricUsr  := ""
local cChaveGui	  := ""
local cNivel	  := ""
local cSequen	  := ""
local aRet		  := {}
local lValido	  := .f.
local cSubRotGuia	:= ""

default lPeg	  := .f.

//Métrica do PLS
/*Atenção:
1) Para a métrica funcionar com a classe FwMetrics, a lib deve estar na versão igual ou maior que 20200727;
2) Além de verificar a versão da Lib, existe o parâmetro "secreto" MV_PHBMETR, que vai ficar ativo como default. Caso ocorra lentidão em 
algum cliente em produção - visto que até 05/2021, nenhum cliente da base tem os requisitos para rodar a métrica e testar em produção - basta
citar a criação deste parâmetro (Métrica PLS Ativa? 0 - Não / 1 - Sim) e colocar o valor como "0" (desligado).
3) No futuro, vamos usar o FwCustomMetrics, mas demanda lib superior e outros requisitos...
4) As variáveis estão declaradas como estáticas no fonte:*/
if lHabMetric .and. lLibSupFw .and. lVrsAppSw 
	if cTipoGuia == '01'
		cSubRotGuia := "CONSULTA"
	elseif cTipoGuia == '02'
		cSubRotGuia := "SP_SADT"
	elseif cTipoGuia == '03'
		cSubRotGuia := "INTERNACAO"
	elseif cTipoGuia == '04'
		cSubRotGuia := "REEMBOLSO"
	elseif cTipoGuia == '05'
		cSubRotGuia := "RESUMO INTERNACAO"
	elseif cTipoGuia == '06'
		cSubRotGuia := "HONORARIO"
	elseif cTipoGuia == '10'
		cSubRotGuia := "RECURSO GLOSA"
	elseif cTipoGuia == '11'
		cSubRotGuia := "PRORROGACAO INTERNACAO"		
	endif
	
	FWMetrics():addMetrics(cSubRotGuia, {{"totvs-saude-planos-protheus_pls_qt_guias_por_tipo_total", 1 }} )
endif
/* Fim das métricas */

if nRecno > 0
	(cAlias)->( dbGoto(nRecno) )
endIf	
			
cMatricUsr	:= (cAlias)-> &( "(" + cAlias + "_OPEUSR + " + cAlias + "_CODEMP + " + cAlias + "_MATRIC + " + cAlias + "_TIPREG ) " ) 

//mudanca de fase item
if isPLSA502
	cSequen := BD6->BD6_SEQUEN 
endIf

cChaveGui := (cAlias)->&( "( " + cAlias + "_CODOPE + " + cAlias + "_CODLDP + " + cAlias + "_CODPEG + " + cAlias + "_NUMERO + " + cAlias + "_ORIMOV ) " ) + cSequen

BD6->( msSeek( xFilial("BD6") + cChaveGui ) )

// Ponto de entrada p bypassar uma nota com base em regra especifica
// no processo de mudar a peg de uma PEG/Lote de Pegs
if lPeg .and. existBlock("PLS720VF") 
	
	if ! execBlock("PLS720VF",.f.,.f.,{cAlias,cNameUser})
	
		if len(aThreads) > 0 .and. nCont > 0 .and. nTotEventos > 0
			PLSATUVGL(aThreads, nCont, nTotEventos,"2",(cAlias)->&( cAlias + "_QTDEVE" ) ,"PLS720VF",cAlias,cChaveGui)
		endIf
	
		return(.t.)
	endIf
	
endIf

// Executa funcao generica para validar a guia...
if lReanaliza
	
	if lPeg
		dDatPro := (cAlias)->&( cAlias + "_DATPRO" )
	endIf

	aRet 	:= PLSA720VMF(lAutori, dDatPro, cAlias, cChaveGui, cLocalExec, cTipoGuia, cGuiRel, lHelp, lSolicit,;
					 	 cChavLib, lNegProPac, lGetCri, isPLSA502)
	aRetAux := aRet[1]
	cNivel  := aRet[2]
	
	// Caso haja critica verifica se vai para conferencia ou continuar como dig.
	if ! lSolicit .and. ! aRetAux[1]
		
		cNextFase := CONFERENC
		
		//analisar se houve erro controlado, se for o caso a proxima fase nao sera atribuido e sim continuara em digitacao
		if len(aRetAux) >= 2 .and. len(aRetAux[2]) > 0 .and. aScan(aRetAux[2],{ |x| x[1] == __aCdCri032[1]}) > 0
			
			cNextFase := DIGITACAO
			
			//Gravar as criticas
			if lHelp .and. ! lAutori .and. ! lPeg
				PLSXCRIGUI(aRetAux[2],"1",cNivel,BCL->BCL_ALIAS,STR0021) //"CRITICAS DE INTEGRIDADE!!! A MUDANCA DE FASE NAO PODE SER FEITA"
			endIf

		// recurso de glosa nao envia para conferencia
		elseIf cTipoGuia == G_REC_GLOSA
		
			aRetAux[1]	:= .t.
			aRetAux[2]	:= {}
			cNextFase 	:= PRONTA

		endIf
		
	else
		
		//nao houve critica passar para pronta
		if cTipoGuia == G_REEMBOLSO .and. ! lProtoc
			cNextFase := FATURADA
		else
			cNextFase := PRONTA
		endIf
		
	endIf

	if  ! aRetAux[1] .and. len(aRetAux[2]) > 0 .and. len(aRetAux) >= 2 .and. aRetAux[2,1,1] == __aCdCri032[1]
	
		if len(aThreads) > 0 .and. nCont > 0 .and. nTotEventos > 0
			PLSATUVGL(aThreads, nCont, nTotEventos, "2", (cAlias)->&( cAlias + "_QTDEVE" ),"PLSA720VMF " + iIf(len(aRetAux) >= 3,aRetAux[3,1,2],""),cAlias,cChaveGui)
		endIf
		
	elseIf len(aThreads) > 0 .and. nCont > 0 .and. nTotEventos > 0
		
		PLSATUVGL(aThreads, nCont, nTotEventos, "1",(cAlias)->&( cAlias + "_QTDEVE" ),"PLSA720MF",cAlias,cChaveGui)
		
	endIf
	
else

	//reembolso
	if cTipoGuia == G_REEMBOLSO .and. !lProtoc 
		cNextFase  := FATURADA
	else
		cNextFase := PRONTA
	endIf
	
endIf

// Coloca como pronta
if lValido
	cNextFase := PRONTA
endIf

// Parcelamento de Co-Participacao ...
if !( cTipoGuia $ G_SOL_INTER + "|" + G_RES_INTER + "|" + G_HONORARIO ) .and. BD5->BD5_PARCOP == "1" .and. BD5->BD5_NPARCE > 0
	PLSPARCOP(cTipo,cNextFase,cChaveGui,cMatricUsr)
endIf

// Inicia transacao se mudanca de fase foi aceita...
if (cAlias)->&( cAlias + "_FASE" ) <> cNextFase
	PL720GMF(cNextFase, cCpoFase, IIF(LEN(aRetAux[2])>0,aRetAux[2],{}), cAlias, cChaveGui, lValido, lPagAto, lCopPag)
endIf
				
return(.t.)

/*/{Protheus.doc} CALCDIACAB
Retorna o total de diárias autorizadas para Internação/Prorrogação
@type function
@author PLSTEAM
@since 21.09.16
@version 1.0
/*/
function CALCDIACAB(cChavLib)
local nQtdDiarias 	:= 0
local aArea			:= BE4->(getArea())
local aArea2		:= B4Q->(getArea())

//Pesquisando na Tabela de Internação BE4
BE4->(dbSetOrder(2))
if BE4->( msSeek(xFilial("BE4") + cChavLib))
	nQtdDiarias += BE4->BE4_DIASIN //Campo de Total de Diárias Autorizadas
endIf

B4Q->(dbSetOrder(1))
if B4Q->( msSeek( xFilial("B4Q" )+ cChavLib))
	nQtdDiarias += B4Q->B4Q_QTDADA //Campo de Total de Diárias Autorizadas
endIf

BE4->(restArea(aArea))
B4Q->(restArea(aArea2))

return nQtdDiarias

/*/{Protheus.doc} PLSA720VMF
Muda a fase
@type function
@author PLSTEAM
@since 13.06.00
@version 1.0
/*/
function PLSA720VMF(lAutori,dDataPro,cAlias,cChaveGui,cLocalExec,cTipoGuia,cGuiRel,lMsgProc,lSolicit,cChavLib,;
					lNegProPac, lGetCri, isPLSA502)
local aAreaBD6 		:= BD6->(getArea())
local aAreaBAU		:= {}
local aAreaBE4		:= {}
local nAux          := 0
local nInd			:= 0
local nFor		 	:= 0
local nForL         := 0
local nValProc 		:= 0
local nValLim  		:= 0
local nQtdPro		:= 0
local nI		 	:= 0
local nY		 	:= 0
local njx     		:= 0
local nPos			:= 0
local nDiarAut   	:= 0
local nDiarExec 	:= 0
local nTam			:= 0
local cGuiJur		:= ""
local cTipGLo	 	:= "1"
local cNivel  		:= ""
local cChvNiv 		:= ""
local cCodCri		:= ""
local cCodVet       := ""
local cDesVet       := ""
local cValVet       := ""
local cNivcRI       := ""
local cChvAux		:= ""
local cTipo         := ""
local cAteRNA   	:= "0"
local cPadInt		:= ""
local cPadCon		:= ""
local cRegAte		:= ""
local cRegInt		:= ""
local cGrpInt   	:= ""
local cTipAte 		:= ""
local cFinAte		:= ""
local cSequen       := ""
local cOriMov   	:= ""
local cRdaEDI    	:= ""
local cCodGlo    	:= ""
local cFaces	 	:= ""
local cDente	 	:= ""
local cCodPad       := ""
local cCodPro   	:= ""
local cAliasCab		:= ""
local cEspSol		:= ""
local cEspExe		:= ""
local cTipPe		:= ""
local cAliasTrb		:= "TRBBE4_BD6"
local cSql			:= ""
local cMatricUsr	:= ""
local cCodRda 		:= ""
local cCodLoc 		:= ""
local cCodEsp		:= ""
local cTabCrit		:= ""
local cAuditoria	:= ""
local cTpaten		:= ""
local __cCodPro		:= ""
local dDatImp    	:= stod('')
local aRetAux 		:= {.t.,{},{}}
local aRetCom 		:= {}
local aDadLim 		:= {}
local aAux    		:= {}
local aAux2   		:= {}
local aRet			:= {}
local aVldGen 		:= {}	
local aDadUsr   	:= PLSGETUSR()
local aDadRda 		:= PLSGETRDA()
local aBD6      	:= {}
local aSuperRecno 	:= {}
local aCriBDX       := {}
local aDiarGui   	:= {}
local aDiarPre	 	:= {}
local aResDia 		:= {}
local aDiarGlo		:= {}
local aProcByp		:= {}
local aMatCri		:= {}
local aBDXSeAnGl 	:= {.t.,{}}
local aQtdBrow	 	:= {}
local aBd7 			:= {}
local aItGeralPac 	:= {}
local aRetInt		:= {}
local lExecAux		:= .f.
local lValido   	:= .t.
local lErroCont  	:= .f.
local lCrit513 		:= .f. // define se caso o array aretcom estivem com a critica 513 o sistema apresentara a critica e tb efetuara os calculos para analise de glosa
local cNumLBOR		:= ""

local lBDX_VLTXPG 	:= BDX->(fieldPos("BDX_VLTXPG")) > 0
local lBDX_VLTXAP 	:= BDX->(fieldPos("BDX_VLTXAP")) > 0
local lBD6_VLRGTX 	:= BD6->(fieldPos("BD6_VLRGTX")) > 0

local lCritIt		:= .f.
local nRecnoRes		:= 0
local aAreaAliasX	:= {}
Local lAscan2		:= .F.
Local nPosAut		:= 0
Local apropac 		:= {.F., ""}
local cMod			:= IIf(FindFunction("StrTPLS"),modulo11(StrTPLS(BD6->(BD6_CODOPE+BD6_CODEMP)) + "99999999"),modulo11(BD6->(BD6_CODOPE+BD6_CODEMP)) + "99999999")
local cMatrAntGen 	:= BD6->(BD6_CODOPE+BD6_CODEMP) + "99999999" + cMod
Local cNrAutOpe		:= ""
Local cNrAutEmp		:= ""
Local cPgNoAto		:= ""

default lMsgProc 	:= .f.
default lSolicit 	:= .f.
default cChavLib	:= ""
default lNegProPac	:= .f.
default lGetCri		:= .f.
default cTipoGuia	:= ""
default isPLSA502	:= .f.

if cTipoGuia $ G_SOL_INTER + "|" + G_RES_INTER + "|" + G_HONORARIO .and. (BCL->BCL_ALIAS)->( fieldPos( BCL->BCL_ALIAS + "_GRPINT" ) ) > 0 .and. (BCL->BCL_ALIAS)->( fieldPos( BCL->BCL_ALIAS + "_TIPINT" ) ) > 0
	
	cGrpInt := (cAlias)->&( cAlias + "_GRPINT" ) + (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_TIPINT" )
	
endIf

cOriMov := (cAlias)->&( cAlias + "_ORIMOV" )

If cAlias == "BD5"
	cNrAutOpe		:= BD5->BD5_NRAOPE
	cNrAutEmp		:= BD5->BD5_NRAEMP
endif

if (cTipoGuia $ G_SADT_ODON)
	cNumLBOR := (cAlias)->&( cAlias + "_CODOPE") + (cAlias)->&(cAlias + "_ANOAUT") + (cAlias)->&(cAlias + "_MESAUT") + (cAlias)->&(cAlias + "_NUMAUT")
endif	

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

BRJ->(dbSetOrder(1))
if BRJ->(msSeek(xFilial("BRJ") + (cAlias)->&( cAlias + "_SEQIMP" ) ) )
	dDatImp := BRJ->BRJ_DATA
endIf

aSuperRecno := { cAlias, (cAlias)->(recno()), {}, {} }

BR8->(dbSetOrder(1)) //BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
BD7->(dbSetOrder(1)) //BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC

if BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) <> xFilial("BD6") + cChaveGui

	BD6->(dbSetOrder(1)) //BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
	if BD6->( msSeek(xFilial("BD6") + cChaveGui ) )
		aAreaBD6 := BD6->(getArea())
	endIf
	
endIf

//retorna o numero da pre-autorizacao
plGetLib(cTipoGuia, @cChavLib)

if cTipoGuia == G_RES_INTER
	PL720Arint(cChavLib,@aDiarPre,@aDiarGui,@aDiarGlo)
endIf

cChvBkp := cChaveGui

if isPLSA502
	cChaveGui := substr(cChaveGui, 1, len(cChaveGui) - 3)
endIf

if (BCL->BCL_ALIAS)->( fieldPos( BCL->BCL_ALIAS + "_ATERNA" ) ) > 0
	cAteRNA := (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_ATERNA" )
endIf

cMatricUsr 	:= (BCL->BCL_ALIAS)->&( "(" + BCL->BCL_ALIAS + "_OPEUSR + " + BCL->BCL_ALIAS + "_CODEMP + " + BCL->BCL_ALIAS + "_MATRIC + " + BCL->BCL_ALIAS + "_TIPREG + " + BCL->BCL_ALIAS + "_DIGITO ) " )
cCodRda 	:= (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_CODRDA" )
cCodLoc 	:= (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_CODLOC" )
cCodEsp		:= (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_CODESP" )

while ! BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial("BD6") + cChaveGui

	if  ! lAnyGlosa .and. ! lExecAux
		
		lExecAux := .t.
		
	endIf
	
	aadd(aBD6,{ BD6->(recno()),BD6->BD6_SEQUEN,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_QTDPRO,BD6->BD6_HORPRO, BD6->BD6_FADENT,BD6->BD6_DENREG,{}})
	
	aadd(aSuperRecno[3],BD6->(recno()))
	
	plTRBBD7("TRBBD7", BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, BD6->BD6_ORIMOV, BD6->BD6_SEQUEN)
			
	if ! TRBBD7->(eof())		
		
		aBD7 := {}
		
		while ! TRBBD7->(eof())
			
			BD7->( dbGoTo( TRBBD7->REC ) )
			
			aadd(aSuperRecno[4], TRBBD7->REC )
			
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
	
	if isPLSA502
		cChaveGui := cChvBkp
		exit
	endIf
	
BD6->(dbSkip())
endDo

BD6->(restArea(aAreaBD6))

// Executa rotina de analise geral das guias...
if getNewPar("MV_PLSINTE","0") == "1"

	if len(aSuperRecno[3]) == 0
	
		PLSPOSGLO(PLSINTPAD(),__aCdCri032[1],__aCdCri032[2],cLocalExec)
		
		aadd(aRetCom,{{__aCdCri032[1],STR0029,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","","",""}}) //"Nao existem eventos (BD6) para esta guia"
		
		lValido := .f.
		
	endIf

	if len(aSuperRecno[4]) == 0
	
		PLSPOSGLO(PLSINTPAD(),__aCdCri032[1],__aCdCri032[2],cLocalExec)
		
		aadd(aRetCom,{{__aCdCri032[1],STR0030,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","","",""}}) //"Nao existem subitens (BD7) para esta guia"
		
		lValido := .f.
	endIf

	cBkpChvGui	:= cChaveGui
	
	if isPLSA502
		xChavegui := subStr(cChaveGui, 1, len(cChaveGui) - 3)
		cChaveGui := xChavegui
	endIf
	
	PLSAnaCM(aSuperRecno,.f.,.f., subs(cChaveGui,1,len(cChaveGui)-1),cOriMov,aRetCom,,cTipoGuia)
	
	cChaveGui := cBkpChvGui

	if len(aRetCom) > 0
		lErroCont := .t.
		lValido   := .f.
	endIf
	
endIf

//"Usuario informado invalido
if allTrim(BD6->BD6_MATANT) == allTrim(cMatrAntGen) .or. allTrim(BD6->BD6_MATANT) == "99999999999999999"

	PLSPOSGLO(PLSINTPAD(),__aCdCri057[1],STR0007,cLocalExec)

	aadd(aRetCom,{{__aCdCri057[1],STR0007,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,"",""}}) //"Usuario informado invalido
	lValido := .f.
	lErroCont := .t.

endif



if lValido .and. ! lErroCont .or. ( len(aDadUsr) == 0 .or. aDadUsr[2] != cMatricUsr )

	aRetAux := PLSDADUSR(cMatricUsr,"1",.f., dDataPro, BD6->BD6_CODPAD, BD6->BD6_CODPRO, nil, aBD6)
	aDadUsr := PLSGETUSR()
	
	if lValido
		
		lValido := aRetAux[1]
	
		if ! lValido
			cNivel 	:= 'BA1'
			cChvNiv := cMatricUsr
			aadd(aRetCom,aRetAux[2])
		endIf
		
	endIf	

endIf

if lValido .and. ! lErroCont .and. ! lAutori

	aRetAux := PLSVLDFIN(cMatricUsr, dDataPro, BD6->BD6_CODPAD, BD6->BD6_CODPRO, cLocalExec, aDadUsr, aBD6)
	
	lValido := aRetAux[1]

	if ! lValido
		cNivel 	:= 'BA1'
		cChvNiv := cMatricUsr
		aadd(aRetCom,aRetAux[2])
	endIf
		
	aRetAux := PLSVLDCON(cMatricUsr, dDataPro, BD6->BD6_CODPAD, BD6->BD6_CODPRO, cLocalExec, BD6->BD6_DTDIGI, aBD6, cCodRda, dDatImp)

	lValido := aRetAux[1]

	if ! lValido
		cNivel 	:= 'BA1'
		cChvNiv := cMatricUsr
		aadd(aRetCom,aRetAux[2])
	endIf
		
endIf

if !lErroCont .and. len(aDadRda) == 0 .or. (!(empTy(aDadRda)) .AND. ( aDadRda[2] != cCodRda .or. aDadRda[12] != cCodLoc ))

	aRetAux := PLSDADRDA(BD6->BD6_OPEUSR, cCodRda, "1", dDataPro, cCodLoc, cCodEsp, BD6->BD6_CODPAD, BD6->BD6_CODPRO, aBD6)
	aDadRda := PLSGETRDA()
	
	if lValido
	
		lValido := aRetAux[1]
		
		if ! lValido
		
			if len(aRetAux[2]) > 0
		
				for nFor := 1 To len(aRetAux[2])
		
					if aRetAux[2,nFor,1] $ __aCdCri016[1] + "|" + __aCdCri084[1]
					
						cNivel 	:= "BAU"
						cChvNiv := cCodRda
						aadd(aRetCom,aRetAux[2])
						
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
			aadd(aRetCom,aRetAux[2])
		endIf
		

		
	endIf	

endIf

//guia de recurso de glosa nao necessita de validacao
if cTipoGuia != G_REC_GLOSA

	// Valida a parte de cobertura e carencia...
	// Nao estava checando a regra de cadastro de procedimentos ao mesmo tempo na mud de fase
	if ( lValido .and. ! lErroCont .and. ! lAutori ) .or. lGetCri .or. lMVPLFAUTP .and. ( len(aDadUsr) > 0 .and. aDadUsr[1] .and. len(aDadRDA) > 0 )

		if ! lAutori
			
			aRetInt 	:= retIntDAD(cTipoGuia,aDadUsr)
			cRegAte 	:= aRetInt[1]
			cRegInt		:= aRetInt[2]
			cPadInt		:= aRetInt[3]
			cPadCon		:= aRetInt[4]
			cTipAte		:= aRetInt[5]
			cFinAte		:= aRetInt[6]
			
			if lMsgProc
				procRegua(len(aBD6) * 2)
			endIf 
			
			//roda a BD6
			for nFor := 1 To len(aBD6)
				
				BD6->(dbGoto(aBD6[nFor,1]))

				if lMsgProc
					IncProc('Protocolo ' + BD6->BD6_CODPEG + ' Guia ' + BD6->BD6_NUMERO + chr(10) + chr(13) + 'Checando regras do evento: ' + BD6->BD6_SEQUEN)
				endIf

				cTabCrit 	:= ""
				lNegProPac 	:= .f.

				aadd(aQtdBrow,{	aBD6[nFor][3],;		//[01] - BD6_CODPAD
								aBD6[nFor][4],;		//[02] - BD6_CODPRO
								aBD6[nFor][5],;		//[03] - BD6_QTDPRO
								dDataPro,;			//[04] - BD6_DATPRO
								aBD6[nFor][6],;		//[05] - BD6_HORPRO
								aBD6[nFor][8],;		//[06] - BD6_DENREG
								aBD6[nFor][7],;		//[07] - BD6_FADENT
								aBD6[nFor][2] })	//[08] - BD6_SEQUEN
				
				if BD6->BD6_GUIACO <> "1" .or. BD6->BD6_PAGATO == "1"

					cRdaEDI := BD6->BD6_RDAEDI
					cFaces	:= BD6->BD6_FADENT
					cDente	:= BD6->BD6_DENREG
					
					// retorna as criticas da guia no momento da autorizacao
					cAliasCab := iIf(cTipoGuia $ G_CONSULTA + "|" + G_SADT_ODON ,'BEA', "")

					if ! empty(cAliasCab) .and. ! empty(cChavLib)
						aMatCri := PLSGETCRI(cAliasCab,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO),BD6->BD6_SEQUEN,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_QTDPRO)
					endIf
					
					// validacao
					if ! lAutori

						apropac := plspropacM()
						cTabCrit 	:= apropac[2]
						lNegProPac 	:= apropac[1]

						//neste array devem estar todos os bd7 de um procedimento
						//isso porque lá no plsxaut eu vou tratar a regra de Executante e do Solicitante com base nestes caras - se eles forem uma rda
						//pois la no padrao tiss esta definido que a unica especialidade enviada eh do profissional executante e do profissional solicitante
						aBD7 := aBD6[nFor,9]
						
						//se a na guia esta informada que eu nao devo considera-la para regra de quantidade/periodicidade eu nao vou fazer a checagem
						//quando eu estiver nela, pois se eu considera-la o sistema vai fazer x+1 dai vai dar a critica
						aVldGen := {}
						if cTipoGuia $ ( G_RES_INTER + '|' + G_HONORARIO ) .or. BD6->BD6_CONMUS == '0'
							aVldGen := {.f.,.f.,.t.,.t.,.F.,.t.,.t.,.t.,.t.,.t.,.t.}
						endIf
						
						//Armazena as variaveis de especialidade dos profissionais
						cEspSol := BD6->BD6_ESPSOL
						cEspExe	:= BD6->BD6_ESPEXE
						
						//Para garantir que não terá a guia desposicionada..
						aAreaAliasX := &(BCL->BCL_ALIAS + "->(getArea())") 
			
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
											FunName() == "RPC",;
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
											cTipoGuia,;
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
											
						if valType(aRetAux[2]) == "A"
							cAuditoria := iIf(ascan( aRetAux[2],{|x| x[1] == "025" } ) > 0, "1", "0")
						else
							cAuditoria := ""
						endIf
						
						// Verifica se procedimento em auditoria se enquandra na exceção cadastrada
						// Caso esteja na exceção retira o procedimento da auditoria.
						if ! empty(cAuditoria) .and. cAuditoria == "1"
							
							//Internação ou Resumo de Internação
							if cTipoGuia == G_SOL_INTER .or. cTipoGuia == G_RES_INTER 
								cTpaten := PLSRetAut("3")[1]
							//Anexos
							elseIf cTipoGuia == G_ANEX_QUIM .or. cTipoGuia == G_ANEX_RADI .or. cTipoGuia == G_ANEX_OPME  
								cTpaten := PLSRetAut("7")[1]
							else
								cTpaten := PLSRetAut()[1]
							endIf
							
							//B1O_CODPRO+B1O_TPGUIA+B1O_IDADE+B1O_QTDPRO
							if PLSVLDEX(left( BD6->BD6_CODPRO + Space( TamSX3("B1O_CODPRO")[1] ), TamSX3("B1O_CODPRO")[1] ) + cTpaten,aDadUsr[26],IIF(BD6->BD6_QTDDEN > 0,BD6->BD6_QTDPRO/BD6->BD6_QTDDEN,BD6->BD6_QTDPRO))
			
								cAuditoria := "0"
								
								if len(aRetAux[2]) == 2
								
									aRetAux[1] := .t.
									aRetAux[2] := {}
			
								else
								
									//retira critica de auditoria
									while ( nPos := aScan( aRetAux[2],{|x| x[1] == __aCdCri051[1]} ) ) > 0
										
										while aRetAux[2,nPos,1] == __aCdCri051[1] .or. empty(aRetAux[2,nPos,1])
											
											nTam := len(aRetAux[2])
											aDel(aRetAux[2],nPos)
											aSize(aRetAux[2],nTam-1)

											if nPos > len(aRetAux[2])
												exit
											endIf
											
										endDo
										
									endDo
								
								endIf
								
							endIf
							
						endIf
											
					else
						aRetAux := { .t., "", cAliasCab, BD6->(BD6_CODPAD+BD6_CODPRO) }
					endIf
					
					//refaz o saldo da guia
					setRetSaldo(cAlias, cTipoGuia, .f., cChavLib)
					
					//Retornamos a area em uso
					restArea(aAreaAliasX)
					
					if lValido
						lValido := aRetAux[1]
					endIf

					// Inclui criticas do momento da autorizacao que nao foram retornadas nesta validacao
					if len(aMatCri) > 0

						// Se autorizado mais tem critica do atendimento nega para ir para conferencia
						if valType(aRetAux[2]) != 'A'
						
							lValido		:= .f.
							aRetAux[1] 	:= lValido
							aRetAux[2] 	:= aClone(aMatCri)
						
						else
						
							// Retorno do plsautp
							for nI := 1 To len(aMatCri)

								cCodCri := aMatCri[nI,1]

								if empty(cCodCri)
									loop
								endIf

								nPos := Ascan(aRetAux[2], {|x| x[1] = cCodCri})

								// Criticas da autorizacao
								if nPos == 0
								
									for nY := nI To len(aMatCri)
									
										if ! empty(aMatCri[nY,1]) .and. aMatCri[nY,1] <> cCodCri
											exit
										endIf
										
										aadd(aRetAux[2],aClone(aMatCri[nY]))
										
									next
									
								endIf
								
							next
							
						endIf
						
						aMatCri := {}
						
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
						
					endIf

					if ! aRetAux[1]
					
						if len(aRetAux[2]) > 0 .and. valType(aRetAux[2]) == 'A'
							aadd(aRetCom,aRetAux[2])
						endIf
						
					endIf

				endIf
				
			next
			
		endIf
		
	elseIf ! lValido .and. ! lErroCont .and. ! empty(cNivel)
		
		BD6->(recLock("BD6",.f.))
		
			BD6->BD6_NIVAUT := ""
			BD6->BD6_NIVCRI := cNivel
			BD6->BD6_CHVNIV := cChvNiv

		BD6->(msUnLock())
		
	endIf

	BD6->(restArea(aAreaBD6))

endIf	

// Valida a valorizacao caso o parametro do tipo de guia esteja setado...
// usuario e rda valido eu valorizo...
if ! lErroCont .and. len(aDadRda) > 0 .and. len(aDadUsr) > 0 .and. ( ! lSolicit .or. getNewPar("MV_PLVALSO","1") == "1")
	
	aRetAux := PLSA720EVE(cTipoGuia,cGuiRel,lMsgProc,(BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_ANOPAG" ),;
						  (BCL->BCL_ALIAS)->&( BCL->BCL_ALIAS + "_MESPAG" ),BCL->BCL_ALIAS,cChaveGui,;
						  aDadUsr,cLocalExec,aDadRda,nil,nil,nil,lMsgProc,nil,nil,nil,aRetCom,,,,,;
						  cChavLib,iIf(cAuditoria == '1',.t.,.f.) , .t., nil, nil, @aAuxCBHPM)
						  
	if lValido
		lValido := aRetAux[1]
	endIf

	if ! aRetAux[1]
		aadd(aRetCom, aRetAux[2])
		cNivel := "VEV"
	endIf

	if len(aRetAux) >= 4
		cPgNoAto := aRetAux[4]
	EndIF	

	if len(aRetAux) >= 3 .and. ! aRetAux[3][1]
		aBDXSeAnGl[1] := aRetAux[3][1]
		aBDXSeAnGl[2] := aClone(aRetAux[3][2])
	endIf
	
endIf

BD6->(restArea(aAreaBD6))

// Valida a rede de atendimento...
if ! lAutori

	aRetAux := PLSVLDRDA(cLocalExec,"","",aBD6)

	if lValido
		lValido := aRetAux[1]
	endIf

	if ! aRetAux[1]
		aadd(aRetCom,aRetAux[2])
		cNivel := "RD2"
	endIf

endIf

// Valida obrigatoriedade de campos da gih...
if ! lAutori .and. cTipoGuia $ G_SOL_INTER + "|" + G_RES_INTER

	if empty(BE4->BE4_DATPRO) .Or. empty(BE4->BE4_HORPRO) 
		
		cNivel := "BE4"
		PLSPOSGLO(PLSINTPAD(),__aCdCri070[1],__aCdCri070[2],cLocalExec)
		
		aadd(aRetCom,{{__aCdCri070[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN}})
		
		lValido := .f.
		
	endIf

endIf

// Executa ponto de entrada para customizacoes em campo...
if existBlock("PLSMUDFS")
	execBlock("PLSMUDFS",.f.,.f.,{cTipoGuia,cLocalExec})
endIf

// Validação Parcelamento de Co-Participacao ...
if  &(BCL->BCL_ALIAS+"->(fieldPos('"+BCL->BCL_ALIAS+"_PARCOP'))") > 0 .and. ;
	&(BCL->BCL_ALIAS+"->(fieldPos('"+BCL->BCL_ALIAS+"_NPARCE'))") > 0 .and. ;
	&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_PARCOP") == '1' .and. ;
	&(BCL->BCL_ALIAS+"->"+BCL->BCL_ALIAS+"_NPARCE") > 0

	aRetCom := PLSVALPARC(aRetCom,@lValido,cLocalExec)

endIf

//caso está ativa devo voltar a variavel pois ja foram efetuados os calculo e tenho que exibir as criticas 513
if lCrit513   
	lValido := .f.
endIf

// Monta o acriticas de acordo com a estrutura pre-definida...
if ! lValido .and. len(aRetCom) > 0

	aAux := {}

	for nInd := 1 To len(aRetCom)

		aAux2 := aClone(aRetCom[nInd])

		if len(aAux2) > 0 .and. len(aAux2[1]) >= 7
		   __cCodPro := aAux2[1][6] + aAux2[1][7]
		endIf

		If Len(aAux) > 0 .AND. len(aAux2[1]) >= 8
			lAscan2 := aScan(aAux,{|x| x[8] + x[1] + x[6] + x[7] = aAux2[1][8] + aAux2[1][1] + __cCodPro}) > 0
		elseif Len(aAux) > 0
			lAscan2 := aScan(aAux,{|x| x[1] + x[6] + x[7] = aAux2[1][1] + __cCodPro}) > 0
		else
			lAscan2 := .F.
		endIf
		
		if Len(aAux) > 0 .AND. lAscan2
			loop
		endIf
		
		for nAux := 1 To len(aAux2)
		
			cCodVet := aAux2[nAux,1]
			cDesVet := aAux2[nAux,2]
			cValVet := aAux2[nAux,3]
			
			if ! empty(cCodVet)
				cNivcRI := aAux2[nAux,4]
				cTipo   := aAux2[nAux,5]
			else
				cTipo   := ""
				cNivcRI := ""
			endIf
			
			//cSequen novo item criado nas criticas padroes
			if len(aAux2[nAux]) >= 8 
				cSequen := aAux2[nAux,8]
			else
				cSequen := ""
			endIf
			
			//Código PF. Novo item.
			if len(aAux2[nAux]) >= 9
				cGrauPa := aAux2[nAux,9]
			else
				cGrauPa := ""
			endIf
			
			//Quantidade apresentada para glosa.
			if len(aAux2[nAux]) >= 10
				nQtdPro := aAux2[nAux,10]
			else
				nQtdPro := 0
			endIf
			
			//Valor Apresentado para glosa.
			if len(aAux2[nAux]) >= 11
				nVlrApr := aAux2[nAux,11]
			else
				nVlrApr := 0
			endIf
			
			//Tipo da Glosa 1-Eletronica 2-Manual
			cTipGlo := '1'
			if len(aAux2[nAux]) >= 12
				cTipGlo := aAux2[nAux,12]
			endIf

			if len(aAux2[nAux]) >= 6
				aadd(aAux,{cCodVet,cDesVet,cValVet,cNivcRI,cTipo,aAux2[nAux,6],aAux2[nAux,7],cSequen,cGrauPa,nQtdPro,nVlrApr,cTipGlo})
			else
				aadd(aAux,{cCodVet,cDesVet,cValVet,cNivcRI,cTipo,'','',cSequen,cGrauPa,nQtdPro,nVlrApr,cTipGlo})			
			endIf
			
		next
		
	next
	
	aRetAux := {.f., aClone(aAux)}

else

	if len(aRetAux) > 0
	
		aRetAux[1] := lValido
		
	else
	
		aRetAux := {.t.,{}}
		lValido := .t.
		
	endIf
	
endIf

BDX->(dbSetOrder(3))
if BDX->(msSeek(xFilial("BDX")+cChaveGui))

	while ! BDX->(eof()) .and. BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV) == xFilial("BDX") + cChaveGui
		
		BDX->(recLock("BDX",.f.))
			BDX->(DbDelete())
		BDX->(msUnLock())
		
	BDX->(dbSkip())
	endDo
	
endIf

// conforme anotações acima caso ele entre aqui é gerado um bdx sem que va para a analise de glosa somente REGISTRA A glosa
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
		
		if BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) + iIf( ! empty(cSequen), BD6->BD6_SEQUEN, ""  ) <> cChaveGui + cSequen
			BD6->(dbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
			BD6->(msSeek(xFilial('BD6') + cChaveGui + cSequen))
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
			BDX->BDX_ORIMOV := cOriMov

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
				
				If lBD6_VLRGTX
				   BDX->BDX_PERGTX := ( BD6->BD6_VLRGTX / ( BD6->BD6_VLTXPG + BD6->BD6_VLRGTX ) ) * 100
				   BDX->BDX_VLRGTX := BD6->BD6_VLRGTX
				EndIf
				
				if lBDX_VLTXPG .and. lBDX_VLTXAP
					BDX->BDX_VLTXPG := BD6->BD6_VLTXPG
					BDX->BDX_VLTXAP := BD6->BD6_VLTXAP
				endIf	
				
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
	
	BD6->(restArea(aAreaBD6))
		
endIf

// erro de critica integridade atualiza campo de erro integridade e gravar bdx p relatorio consistencia...
if ! aRetAux[1] .and. len(aRetAux) >= 2 .and. Ascan(aRetAux[2],{ |x| x[1] == __aCdCri032[1]}) > 0 .and. &(cAlias+"->(fieldPos('"+cAlias+"_ERRO'"+"))") > 0

	&(cAlias)->(recLock(cAlias,.f.))
		&(cAlias+"->"+cAlias+"_ERRO") := "1"
	&(cAlias)->(msUnLock())

	aCriBDX := aClone(aRetAux[2])
	
	for nInd := 1 To len(aCriBDX)
	
		cCodGlo := aCriBDX[nInd,1]
		cCodPad := aCriBDX[nInd,6]
		cCodPro := aCriBDX[nInd,7]
		
		if cCodGlo == __aCdCri032[1]
			loop
		endIf
		
		if len(aCriBDX[nInd]) >= 8
			cSequen := aCriBDX[nInd,8]
		else
			cSequen := ""
		endIf

		if len(aCriBDX[nInd]) >= 9
			cDesPro := aCriBDX[nInd,9]
		else
			cDesPro := BR8->(Posicione("BR8",1,xFilial("BR8")+cCodPad+cCodPro,"BR8_DESCRI"))
		endIf

		BDX->(recLock("BDX",.t.))
			BDX->BDX_FILIAL := xFilial("BDX")
			BDX->BDX_IMGSTA := "BR_VERMELHO"
			BDX->BDX_CODOPE := &(cAlias+"->"+cAlias+"_CODOPE")
			BDX->BDX_CODLDP := &(cAlias+"->"+cAlias+"_CODLDP")
			BDX->BDX_CODPEG := &(cAlias+"->"+cAlias+"_CODPEG")
			BDX->BDX_NUMERO := &(cAlias+"->"+cAlias+"_NUMERO")
			BDX->BDX_NIVEL  := "1"
			BDX->BDX_CODPAD := cCodPad
			BDX->BDX_CODPRO := cCodPro
			BDX->BDX_DESPRO := cDesPro
			BDX->BDX_SEQUEN := cSequen
			BDX->BDX_CODGLO := cCodGlo
			BDX->BDX_GLOSIS := cCodGlo
			BDX->BDX_DESGLO := aCriBDX[nInd,2]
			BDX->BDX_INFGLO := aCriBDX[nInd,3]
			BDX->BDX_TIPGLO := "1"
			BDX->BDX_ORIMOV := cOriMov
		BDX->(msUnLock())
	next
	
	//zera evento com valores calculados
	for nInd := 1 to len(aBD6)
		
		BD6->( dbGoto(aBD6[nInd,1]))
		
		if BD6->BD6_VLRMAN > 0		
			plDigPro(DIGITACAO, __cBLODES)
		endIf	
		
	next
		
else

	if &(cAlias+"->(fieldPos('"+cAlias+"_ERRO'"+"))") > 0
	
		&(cAlias)->(recLock(cAlias,.f.))
		&(cAlias+"->"+cAlias+"_ERRO") 	:= "0"
		&(cAlias+"->"+cAlias+"_PAGATO") := cPgNoAto // Determina se ha pagmento no ato, esse item pode ser alterado no campo quanto PE. 
		&(cAlias)->(msUnLock())
		
	endIf
	
endIf

//libera da memoria
aBD6 := aSize(aBD6, 0)
aBD6 := nil

aBD7 := aSize(aBD7, 0)
aBD7 := nil

aSuperRecno := aSize(aSuperRecno, 0)
aSuperRecno := nil

return( { aRetAux, cNivel} )

/*/{Protheus.doc} PLSA720GAT
Gatilho do campo BD6_CODPRO
@type function
@author PLSTEAM
@since 13.02.03
@version 1.0
/*/
function PLSA720GAT()
local cMacro	 	:= ""
local cAlias     	:= BCL->BCL_ALIAS
local cTipoGuia  	:= BCL->BCL_TIPGUI
local cCodPla    	:= ""
local cOpeOri    	:= ""
local cRegExe	 	:= ""
local cSigExe	 	:= ""
local cEstExe	 	:= ""
local cCdPfRe	 	:= ""
local nFor		 	:= 0
local nI		 	:= 0
local aDadUsr 	 	:= PLSGETUSR()
local dDatPro 	 	:= iIf( empty(M->BD6_DATPRO), iIf(BR8->BR8_TPPROC != '6',dDataBase,M->&( cAlias + "_DATPRO" ) ), M->BD6_DATPRO)
local cCodPro 	 	:= M->BD6_CODPRO
local cCodPad 	 	:= M->BD6_CODPAD
local cCodSeq 	 	:= M->BD6_SEQUEN
local cCodTab	 	:= M->BD6_CODTAB
local nQtdPro 	 	:= M->BD6_QTDPRO
local nPos	  	 	:= 0
local nSize	  	 	:= 0
local nInd	  	 	:= 0
local cSequen 	 	:= M->BD6_SEQUEN
local lHonor  	 	:= .f.
local aPartic 	 	:= {}
local cGraPa  	 	:= ""
local aCposPad 	 	:= {}
local cMacro 		:= ""

if len(aDadUsr) >= 11
	cCodPla := aDadUsr[11]
endIf

if len(aDadUsr) >= 45
	cOpeOri := aDadUsr[45]
endIf

M->BD6_QTD1   := 0
M->BD6_PERC1  := 0
M->BD6_QTD2   := 0
M->BD6_PERC2  := 0
M->BD6_QTD3   := 0
M->BD6_PERC3  := 0
M->BD6_QTD4   := 0
M->BD6_PERC4  := 0
M->BD6_QTD5   := 0
M->BD6_PERC5  := 0
M->BD6_QTD6   := 0
M->BD6_PERC6  := 0

//Procura a regra cadastrada no procedimento,subgrupo,gupo...
//Por exemplo:
//Quando solicitado mais de um exame na mesma guia, sera cobrado:
//Ressonancia:
// 	primeiro 100%
// 	segundo  80 %
//		terceiro 50 %
//  Tomografia:
// 	primeiro 100%
// 	segundo  70 %
// 	terceiro 50 %
// Para se parametrizar deve-se cadastrar no subgrupo da
//	tomografia (34.01.000-9) a regra:
//
// 	BL0_QTD (Quantidade) = 1   (hum)                                     
// 	BL0_PERC(Percentual) = 100 (cem)
// 	BL0_TIPO(Tipo)		 = 1   (debito)
//
// 	BL0_QTD (Quantidade) = 2   (dois)
// 	BL0_PERC(Percentual) = 70  (setenta)
// 	BL0_TIPO(Tipo)		 = 1   (debito)
//
// 	BL0_QTD (Quantidade) = 3   (tres)
// 	BL0_PERC(Percentual) = 50  (cinquenta)
// 	BL0_TIPO(Tipo)		 = 1   (debito)
//
//	Idem para ressonancia...
PlMonQtPer(cCodSeq,cCodPad,cCodPro,M->BD6_QTDPRO,.t.,nil,iIf(!empty (&("M->"+cAlias+"_DATPRO")),&("M->"+cAlias+"_DATPRO"),nil),,,,,BCI->BCI_CODRDA,,,,,)

// Monta itens do pacote
if readVar() == "M->BD6_CODPRO"
 	
	if BR8->BR8_TPPROC == '6'

		if Type('aColsB43') <> 'U' .and. Type('aHeaderB43') <> 'U' .and. Type('aVetTrabB43') <> 'U'
			PlAliPac(M->BD6_CODPAD,M->BD6_CODPRO,nil,dDatPro,cAlias,aColsB43,aHeaderB43,aVetTrabB43,cSequen)
		endIf
		
	endIf

	// Monta os subitens da conta...
	if  cTipoGuia $ G_CONSULTA + "|" + G_SADT_ODON + "|" + G_SOL_INTER + "|" + G_RES_INTER + "|" + G_HONORARIO + "|" + G_REC_GLOSA
	
		if Type("M->"+cAlias+"_REGEXE") <> "U"
			cRegExe:= &("M->"+cAlias+"_REGEXE")
		endIf
		
		if Type("M->"+cAlias+"_SIGEXE") <> "U"
			cSigExe:= &("M->"+cAlias+"_SIGEXE")
		endIf
		
		if Type("M->"+cAlias+"_ESTEXE") <> "U"
			cEstExe:= &("M->"+cAlias+"_ESTEXE")
		endIf
		
		if Type("M->"+cAlias+"_CDPFRE") <> "U"
			cCdPfRe:= &("M->"+cAlias+"_CDPFRE")
		endIf
		
		if Type("M->"+cAlias+"_DATPRO") <> "U"
			dDatPro := &("M->"+cAlias+"_DATPRO")
		endIf
		
		if Type("M->"+cAlias+"_GRAPAR") <> "U"
		
			cGraPa := &("M->"+cAlias+"_GRAPAR")
		
			if ! empty(cGraPa)
				aadd(aPartic, {	cGraPa, cCodSeq, M->(BD6_CODPAD+BD6_CODPRO), 0,cRegExe,cSigExe,cEstExe,0 } )
				lHonor := .t.
			endIf
			
		endIf
		
		PLS720IBD7("0",0,M->BD6_CODPAD,M->BD6_CODPRO,cCodTab,M->&( cAlias + "_OPERDA" ),M->&( cAlias + "_CODRDA" ),;
					cRegExe,cSigExe,cEstExe,cCdPfRe,M->&( cAlias + "_CODESP" ),M->&( cAlias + "_CODLOC" ) + M->&( cAlias + "_LOCAL"),;
					"2",M->BD6_SEQUEN,BD6->BD6_ORIMOV,BCL->BCL_TIPGUI,iIf( empty(M->BD6_DATPRO), M->&( cAlias + "_DATPRO" ),;
					M->BD6_DATPRO),nil,nil,nil,nil,nil,nil,cCodpla,nil,aPartic,nil,lHonor, cAlias)

		ajusSeq500()							
	endIf

endIf

return(.t.)

/*/{Protheus.doc} PLSA720PRO
@type function
@author PLSTEAM
@since 13.02.03
@version 1.0
/*/
function PLSA720PRO()
local cCodPro
local cCodPad
local cSequen

if cTipoGuia $ G_CONSULTA + "|" + G_SADT_ODON + "|" + G_SOL_INTER + "|" + G_RES_INTER + "|" + G_HONORARIO + "|" + G_REC_GLOSA

	cCodPad := oBrwBD6:aCols[oBrwBD6:Linha(),PLRETPOS("BD6_CODPAD",oBrwBD6:aHeader)]
	cCodPro := oBrwBD6:aCols[oBrwBD6:Linha(),PLRETPOS("BD6_CODPRO",oBrwBD6:aHeader)]
	cSequen := oBrwBD6:aCols[oBrwBD6:Linha(),PLRETPOS("BD6_SEQUEN",oBrwBD6:aHeader)]
	
endIf

return(cCodPad+cCodPro+cSequen)

/*/{Protheus.doc} PLS720IBD7
Grava os subitens das guias
@type function
@author PLSTEAM
@since 13.02.03
@version 1.0
/*/
function PLS720IBD7(cPacote,nVlrInfA,cCodPad,cCodPro,cCodTab,cCodInt,cCodRDA,cRegExe,cSigExe,cEstExe,;
					cCodPrfExe,cCodEsp,cCodLoc,cTipo,cSequen,cOriMov,cTipoGuia,dDatPro,__aNiveis,aCompo,;
					aUniAti,oBrwComp,lCompara,cUnCompara,cCodpla,aMatCom,aPartic,aTipPart,lHonor,cAliasCab,;
					NAOUSADO,lB7m,lWeb,lRecursada,lnInfEquip,lXmlOrigS,lAneste)

local aArea      	:= getArea()
local lFoundBD7  	:= .f.
local lNovo      	:= .t.
local lPagarItem 	:= .t.
local lBlocAte		:= .f.
local lCorpoCli  	:= if(empty(cRegExe),.f.,.t.)
local nInd  	 	:= 0
local nPos       	:= 0
local nPos2 	 	:= 0
local nPos3		 	:= 0
local nLinCols	 	:= 0
local nNiveis    	:= 0
local nForUnd	 	:= 0
local nPosPart		:= 0
local nI		 	:= 0
local nK			:= 1
local nJ			:= 1
local nRegBAU    	:= BAU->(recno())
local nOrdBAU    	:= BAU->(indexOrd())
local nRegBR8    	:= BR8->(recno())
local nOrdBR8    	:= BR8->(indexOrd())
local cNoSeApli		:= getNewPar("MV_PLSNAPL","O")
local lCompIHon		:= getNewPar("MV_CNDCOMP", .f.)  //Considera a composição igual Honorários, mesmo sendo SADT
local cMVPLSCAUX 	:= getNewPar("MV_PLSCAUX","AUX")
local cCodEspExe 	:= ""
local cSQL		 	:= ""
local cTipoCorpo 	:= ""
local cChave     	:= ""
local cProBD7Ori 	:= ""
local cCodUnd    	:= ""
local cCodPrfSol 	:= ""
local cNomPrfExe 	:= ""

local cUnidPart		:= "COP|COR|UCO|FIL|DOP|CRR|INC|TCR|VDI|VMD|VMT|VTX"
local cNameBZB   	:= retSqlName("BZB")
local cFilialBZB 	:= xFilial("BZB")
local cCodRdaOri 	:= cCodRda
local cLocal 	 	:= iIf (len(cCodLoc) == 6 ,subs(cCodLoc,4,3),"")
local aRetEspec	 	:= {}
local aUnidsProp 	:= {}
local aRdas      	:= {}
local aRetUnd    	:= {}
local aPosSeq	 	:= {}
local bRest      	:= { || BAU->(dbSetOrder(nOrdBAU)), BAU->(dbGoto(nRegBAU)) }
local bRest2     	:= { || BR8->(dbSetOrder(nOrdBR8)), BR8->(dbGoto(nRegBR8)) }

local isPLSCLAINS 	:= findFunction("PLSCLAINS")

local lBD7_TIPEVE 	:= BD7->(fieldPos("BD7_TIPEVE")) > 0
local lBD7_VLINPT	:= BD7->(fieldPos("BD7_VLINPT")) > 0
local lBD7_GLINPT 	:= BD7->(fieldPos("BD7_GLINPT")) > 0
local lBD7_CLAINS   := BD7->(fieldPos("BD7_CLAINS")) > 0

local aDadUsr       := PLSGETUSR()
local aUnidades 	:= {"COP","COR","UCO","FIL","DOP","CRR","INC","TCR","VDI","VMD","VMT","VTX","REA"}
local cAliRee		:= ""
local lMudaEstrutura:= .f. 
local cProtoc		:= ""
local aAreaBAU		:= {}
local aParNoUnl		:= {} // array que contem os itens que gero BD7 e não precisara gerar UNL
local px			:= 0
	
default cTipo 	   	:= "1" 	//1 - Atualizar na Base
//2 - Atualizar na getdados
//3 - Retornar matriz com aRdas
//4 - Gravar na B47 e retornar o aRdas
default cSequen    	:= ""
default __aNiveis  	:= PLSESPNIV(cCodPad)

default aUniAti    	:= {}
default oBrwComp   	:= nil
default lCompara   	:= .f.
default cUnCompara 	:= ""
default cCodPla    	:= ""
default aMatCom		:= {}
default aPartic		:= {}//participacao que o cara mandou na guia
default aTipPart	:= {}
default lHonor		:= .f.
default lRecursada 	:= .f.
default lB7m		:= .f.
default lWeb		:= .f.
default lAneste     := .f.
default aCompo     	:= {}
default lnInfEquip	:= .f.
default lXmlOrigS	:= .f.
default NAOUSADO	:= nil
default cAliasCab	:= ""

// Caso esse array venha preenchi é devido o  MV_PLCAAUX esta com valor 3 para tratamento de distribuicao de auxiliares nos procedimentos	
if len(aCompo) == 0
	aCompo := PLSCOMEVE(cCodTab,cCodPad,cCodPro,cCodInt,dDatPro,cTipoGuia,,,cCodRDA,cCodEsp,,cCodLoc,,aPartic,lAneste)
endIf 

if empty(cUnCompara)
	lCompara := .f.
endIf

cCodLoc := subs(cCodLoc,1,3)

//em alguns casos a BAU chega posicionada em registro errado
if BAU->(BAU_FILIAL+BAU_CODIGO) <> xFilial("BAU") + cCodRDA
	BAU->( dbSetOrder(1) )//BAU_FILIAL+BAU_CODIGO
	BAU->( msSeek(xFilial("BAU") + cCodRDA ) )
endIf

// Pega o codigo do profissional solicitante
if cTipoGuia == G_SOL_INTER + '|' + G_RES_INTER  .and. Type("M->BE4_CDPFSO") == "C"

	cCodPrfSol := M->BE4_CDPFSO
	cNomPrfExe := M->BE4_NOMEXE
	
elseIf Type("M->BD5_CDPFSO") == "C"

	cCodPrfSol := M->BD5_CDPFSO
	cNomPrfExe := M->BD5_NOMEXE
	
endIf

if lB7m
	cAliRee := "B7M"
else
	cAliRee := "B47"
endIf


nNiveis := (__aNiveis[1]+1)

//Tratamento para o local, para evitar erro, pois o codloc pode vir com 3 posiões apenas
if empty(cLocal)

	BB8->(dbSetOrder(1))	//BB8_FILIAL + BB8_CODIGO + BB8_CODINT + BB8_CODLOC + BB8_LOCAL
	if BB8->( msSeek(xFilial("BB8")+cCodRda+cCodInt+cCodLoc) )
		cLocal := BB8->BB8_LOCAL
	endIf
	
endIf

//Se for informa o corpo clinico trato o desmenbrado...
if lCorpoCli
	
	BC1->(dbSetOrder(1))//BC1_FILIAL, BC1_CODIGO, BC1_CODLOC, BC1_CODESP, BC1_CODPRF
	if ! BC1->(msSeek(xFilial("BC1")+cCodRDA+cCodLoc+cCodEsp+cCodPrfExe)).or. ( BC1->BC1_CONSDV != '1'.and. IsInCallStack("PLSA973"))
		lCorpoCli := .f.
	else

		if empty(BC1->BC1_DATBLO) .Or. BC1->BC1_DATBLO > dDatPro
			cTipoCorpo := BC1->BC1_TIPLAN
		endIf
		
		BZB->(dbSetOrder(1))
		if BZB->(msSeek(xFilial("BZB")+cCodRDA+cCodInt+cCodLoc))
			
			//Checa na RDA X Especialidade X local Atendimento X Procedimento
			for nInd := 1 To nNiveis
				
				cSQL := "SELECT BZB_CODUNI, BZB_STATUS FROM "+cNameBZB+" WHERE "
				cSQL += "BZB_FILIAL = '"+cFilialBZB+"' AND "
				cSQL += "BZB_CODIGO = '"+cCodRDA+"' AND "
				cSQL += "BZB_CODINT = '"+cCodInt+"' AND "
				cSQL += "BZB_CODLOC = '"+cCodLoc+"' AND "
				cSQL += "BZB_CODESP = '"+cCodEsp+"' AND "
				cSQL += "BZB_CODTAB = '"+cCodTab+"' AND "
				
				if nInd == 1
					cSQL += "BZB_CODOPC = '"+allTrim(cCodPro)+"' AND "
				else
					cSQL += "BZB_CDNV0"+strZero(nInd-1,1)+" = '"+Subs(cCodPro,__aNiveis[2,(nInd-1),1],__aNiveis[2,(nInd-1),2])+"' AND "
					cSQL += "BZB_NIVEL = '"+__aNiveis[2,(nInd-1),3]+"' AND "
				endIf
				
				cSQL +=  cNameBZB+".D_E_L_E_T_ = ' '"
				
				dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"PLS720IBD7",.F.,.T.)
  	
				while ! PLS720IBD7->(eof())
				
					aadd(aUnidsProp,{PLS720IBD7->BZB_CODUNI,PLS720IBD7->BZB_STATUS})
				
				PLS720IBD7->(dbSkip())
				endDo
				
				PLS720IBD7->(DbCloseArea())
				restArea(aArea)
			next
		endIf
		
		//Checa agora na RDA X local de Atendimento
		BZA->(dbSetOrder(1))
		if BZA->(msSeek(xFilial("BZA")+cCodRDA+cCodInt+cCodLoc))
		
			while ! BZA->(eof()) .and. BZA->(BZA_FILIAL+BZA_CODIGO+BZA_CODINT+BZA_CODLOC) == xFilial("BZA")+cCodRDA+cCodInt+cCodLoc
				
				nPos := Ascan(aUnidsProp,{|x| x[1] == BZA->BZA_CODUNI })
				
				if nPos > 0
					if BZA->BZA_STATUS == "1" .and. aUnidsProp[nPos,2] == "0"
						aUnidsProp[nPos,2] := "0"
					endIf
				else
					aadd(aUnidsProp,{BZA->BZA_CODUNI,BZA->BZA_STATUS})
				endIf
				
				BZA->(dbSkip())
			endDo
			
		endIf
		
	endIf
	
endIf

BR8->( dbSetOrder(1) )
BR8->( msSeek( xFilial("BR8") + cCodPad + cCodPro ) )

//Manipula array de composicoes de acordo com as composicoes selecionadas no protocolo de reembolso (caso tenha sido alterado).
if type("BOW->BOW_PROTOC") <> "U"
	cProtoc := BOW->BOW_PROTOC
elseIf type("M->BOW_PROTOC") <> "U"	
	cProtoc := M->BOW_PROTOC
endIf

if ! empty(cProtoc) .and. ! lB7m .and. cTipoGuia == G_REEMBOLSO   
	CompProtoc(@aCompo,cProtoc,cCodPad,cCodPro,cSequen)		
endIf

if cTipo == "1"

	lPagarItem := PLSPRRDAP(BD6->BD6_CODRDA,BD6->BD6_OPERDA,BD6->BD6_CODLOC,BD6->BD6_CODESP,BD6->BD6_CODPLA,BD6->BD6_CODPAD,BD6->BD6_CODPRO)
	
	cDesEspBD7 := BAQ->(Posicione("BAQ",1,xFilial("BAQ")+BD6->(BD6_OPERDA+BD6_CODESP),"BAQ_DESCRI"))
	
elseIf cTipo == "2"
	
	//	Inserido Tipo 10 para Guias de Recurso de Glosa
	if cTipoGuia $  G_CONSULTA + '|' + G_SADT_ODON + '|' + G_HONORARIO + '|' + G_REC_GLOSA 
	
		lPagarItem := PLSPRRDAP(BCI->BCI_CODRDA,BCI->BCI_CODOPE,M->BD5_CODLOC,M->BD5_CODESP,;
								iIf(cPaisLoc=="BRA",BA3->BA3_CODPLA,iIf(!empty(cCodPLa),cCodPLa,BD6->BD6_CODPLA)),;
								BD6->BD6_CODPAD,BD6->BD6_CODPRO)
		cDesEspBD7 := BAQ->(Posicione("BAQ",1,xFilial("BAQ")+M->(BD5_OPERDA+BD5_CODESP),"BAQ_DESCRI"))

	else
	
		lPagarItem := PLSPRRDAP(BCI->BCI_CODRDA,BCI->BCI_CODOPE,M->BE4_CODLOC,M->BE4_CODESP,;
								iIf(cPaisLoc=="BRA",BA3->BA3_CODPLA,iIf(!empty(cCodPLa),cCodPLa,BD6->BD6_CODPLA)),;
								BD6->BD6_CODPAD,BD6->BD6_CODPRO)
		
		cDesEspBD7 := BAQ->(Posicione("BAQ",1,xFilial("BAQ")+M->(BE4_OPERDA+BE4_CODESP),"BAQ_DESCRI"))
		
	endIf
	
else
	lPagarItem := .t.
endIf

BD7->(dbSetOrder(1))//BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC

//Composicao do procedimento
for nInd := 1 To len(aCompo)

	//Se nao tiver no array nao gravar participacao
	nPosPart := 0
	nJ		 := 0
	
	//la embaixo quando é honorario o sistema exclui o apartic
	//A mesma regra foi aplicada parea os casos de SADT que quiserem considerar igual honorário. aCompo foi adiconado para controle, pois procedimentos que não envolvem pessoal
	//não são colocados na GHI e o sistema precisa gravar a participação que consta no procedimento, conforme SADT normal.
	if ( lHonor .and. aCompo[nInd][1] $ cUnidPart ) .or. ( lHonor .and. len(aPartic) == 0 ) .or. ( lCompIHon .and. len(aPartic) == 0 .and. cTipoGuia == G_SADT .and. len(aCompo) > 1 .and. lXmlOrigS )
		loop
	endIf
	
	//Bloco de codigo utilizado na importacao xml
	//Na posição 16 de cada array do aCompo fica o tipo de participação, caso cadastrado, da BD4
	if len(aPartic) > 0  .and. len( aCompo[nInd] ) >= 16
		
		//Estabelece o inicio do aScan para percorrer em todas as posicoes do aPartic
		nStart 		:= 1
		nPosPart 	:= 0
		
		//Verifica se o Procedimento esta no aPartic e inicia a estrutura de repeticao
		while (nPosProc := aScan(aPartic,{|x| (allTrim(x[3]) == allTrim(cCodPad+cCodPro))},nStart)) > 0
			
			if ! empty(aCompo[nInd,16])
			
				if strZero(val(allTrim(aPartic[nPosProc][1])),2) == strZero(val(allTrim(aCompo[nInd,16])),2) .or. ( allTrim(aPartic[nPosProc][1]) == cNoSeApli .and. ! lHonor )
				
					if len(aPartic[nPosProc]) >= 13 .and. aPartic[nPosProc][13] <> nil .and. len(aPartic[nPosProc][13]) > 0

						if aScan(aPartic[nPosProc][13], {|x| allTrim(x) == allTrim(aCompo[nInd,1]) } ) > 0
							nPosPart := nPosProc
							exit
						endIf
						
					else
						nPosPart := nPosProc
						exit
					endIf
					
				endIf
				
				if lHonor
				
					BKC->(dbSetOrder(1)) //BKC_FILIAL+BKC_CODIGO+BKC_CODOPE+BKC_CODPAR
					if BKC->( msSeek( xFilial("BKC") + allTrim(aCompo[nInd,1]) + cCodInt + allTrim(aPartic[nPosProc][1]) ) )
						If allTrim(aCompo[nInd,1]) $ cMVPLSCAUX
							nPosPart := aScan(aPartic, {|x| strZero(val(allTrim(x[1])),2) == strZero(val(allTrim(aCompo[nInd,16])),2)})
						else
							nPosPart := nPosProc
						EndIf
						exit
					endIf
					
				endIf
				
			else
			
				//Para honorário não se cobra participaçõs que não são as realizados por ser humano
				if allTrim(aPartic[nPosProc][1]) == cNoSeApli .and. ! lHonor 
				
					nPosPart := nPosProc
					exit
					
				elseIf len(aPartic[nPosProc]) >= 13 .and. aPartic[nPosProc][13] <> nil .and. len(aPartic[nPosProc][13]) > 0

					if aScan(aPartic[nPosProc][13],{|x| allTrim(x) == allTrim(aCompo[nInd,1])}) > 0
						nPosPart := nPosProc
						exit
					endIf
					
				else
				
					if lHonor

						BKC->(dbSetOrder(1)) //BKC_FILIAL+BKC_CODIGO+BKC_CODOPE+BKC_CODPAR
						if BKC->(msSeek( xFilial("BKC") + allTrim(aCompo[nInd,1]) + cCodInt + allTrim(aPartic[nPosProc][1]) ) )
							nPosPart := nPosProc
						endIf
						
					endIf
					
					exit
				endIf
				
			endIf
			
			//Incrementa a variavel de controle para o proximo item valido no aPartic caso a condicao nao seja atendida
			nStart++
			
		endDo
		
		if nPosPart == 0
			loop
		else
			//adiciono os itens do aPartic que estao no Acompo para que no final eu vejo os itens AUX que não gerou BD7 e gerar um UNL
			//Esse item se faz necesario para os casos em que o prestador mandar participações a mais eses itens irão para analise de glosa
			aadd(aParNoUnl,{nPosProc,aPartic[nPosProc,1]}) 	
		endIf
		
	endIf
	
	//Verifica se alguma unidade (composicao do procedimento) foi negado no atendimento
	//Tratamento no atendimento (liberacao, sadt, odonto e internacao)
	lBlocAte := .f.
	
	if len(aMatCom) > 0
	
		if ( nPos := Ascan(aMatCom,{|x| x[1] == cSequen+cCodPad+cCodPro } ) ) > 0
			
			if ( nPos2 := Ascan(aMatCom[nPos,2],{|x| x[2] == aCompo[nInd,1]}) ) > 0 .and. aMatCom[nPos,2,nPos2,len(aMatCom[nPos,2,nPos2]) ]
				
				//a composicao nao foi autorizada agora vou checar se a critica esta ativa
				//se tiver bloqueio o sub-item se nao nao inclui no bd7
				if PLSPOSGLO(PLSINTPAD(),__aCdCri178[1],__aCdCri178[2]) .and. PLSCHKCRI( {'BAU',cCodRDA,__aCdCri178[1]} )
					lBlocAte := .t.
				else
					loop
				endIf
				
			endIf
			
		endIf
		
	endIf
	
	if cTipo == "1"

		cChave := 	xFilial("BD7") + BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO + cOriMov + BD6_SEQUEN) +;
					aCompo[nInd,1] + iIf( allTrim(aCompo[nInd,1]) $ cMVPLSCAUX, strZero(aCompo[nInd,3],2), "")
					
		lFoundBD7 := BD7->(msSeek(cChave))
		
		//se o bd7, não esta ativo (esta deletado) nem continuo a funcao
		if 	! lFoundBD7 .and. ( ( len(aUniAti) > 0 .and. aScan(aUniAti,{|x| allTrim(x[1]+x[2]+x[3]) == allTrim( BD6->BD6_SEQUEN + aCompo[nInd,1] + iIf( allTrim(aCompo[nInd,1]) $ cMVPLSCAUX, strZero(aCompo[nInd,3],2), "" ) ) } ) == 0 ) .or. (lCompara .and. ! allTrim(aCompo[nInd,1]) $ cUnCompara) )
			loop
		endIf
		
		if ! lFoundBD7
			lNovo := .t.
		endIf
		
		//na troca de evento o BD7 deve ser todo atualizado e incluir os novos
		BD7->(recLock("BD7",( ! lFoundBD7 ) ) )
		
		BD7->BD7_FILIAL := xFilial("BD7")
		
		//espelha campos iguais
		PLESPACP('BD6', 'BD7')
		
		BD7->BD7_CODUNM := aCompo[nInd,1]
		BD7->BD7_NLANC  := if(allTrim(aCompo[nInd,1]) $ cMVPLSCAUX,strZero(aCompo[nInd,3],2),"")

		if len(aCompo[nInd]) > 15
			BD7->BD7_CODTPA := aCompo[nInd,16]
		endIf
		
		if empty(BD7->BD7_PROBD7)
			cProBD7Ori      := "0"
			BD7->BD7_PROBD7 := "1"
		else
			cProBD7Ori := BD7->BD7_PROBD7
		endIf
		
		//Considera o BD6 posicionado!!!
		if lBD7_CLAINS .and. isPLSCLAINS
			BD7->BD7_CLAINS := PLSCLAINS() 
		endIf
		
		//valor apresentado
		BD7->BD7_VLRAPR := 0
		BD7->BD7_VALORI := 0
		
		//valor apresentado tx
		BD7->BD7_VTXPAP := 0
		
		//valor inss patronal
		if lBD7_VLINPT
			BD7->BD7_VLINPT := 0
		endIf	
		
		//valor glosa inss patronal
		if lBD7_GLINPT
			BD7->BD7_GLINPT := 0 
		endIf
		
		//campos abaixo foram criados de uma unica vez
		BD7->BD7_DESESP := cDesEspBD7
		BD7->BD7_BLOPAG := iIf( ! lPagarItem .or. aCompo[nInd,13] == "1", "1", iIf(BD6->BD6_BLOPAG <> "1","0",BD6->BD6_BLOPAG))
		
		if lBlocAte

			PLSPOSGLO(PLSINTPAD(),__aCdCri178[1],__aCdCri178[2])
			PLBLOPC('BD7', .t., __aCdCri178[1], PLSBCTDESC())
			
		endIf
		
		BD7->BD7_UNITDE := aCompo[nInd,7]
		BD7->BD7_REFTDE := aCompo[nInd,3]
		
		BD7->BD7_CONMFT := BR8->BR8_CONMFT
		
	elseIf cTipo == "2"
		
		nPos     := oBrwBD7:PLRETPOS("BD7_CODUNM")
		nPos2    := oBrwBD7:PLRETPOS("BD7_SEQUEN")
		nPos3    := oBrwBD7:PLRETPOS("BD7_NLANC")
		
		nLinCols := aScan(oBrwBD7:aCols,{ |x| allTrim(x[nPos]) == "" } )
		
		if nLinCols == 0
			
			nLinCols := aScan(oBrwBD7:aCols,{ |x| allTrim(x[nPos]) == aCompo[nInd,1] .and. x[nPos2] == M->BD6_SEQUEN })
			
			if nLinCols > 0
				
				if allTrim(oBrwBD7:fieldGet("BD7_CODUNM",nLinCols)) $ cMVPLSCAUX
					nLinCols := aScan(oBrwBD7:aCols,{ |x| allTrim(x[nPos]) == aCompo[nInd,1] .and. x[nPos2] == M->BD6_SEQUEN .and. allTrim(x[nPos3]) == strZero(aCompo[nInd,3],2) })
				endIf
				
			endIf
			
		endIf
		
		if nLinCols == 0
			oBrwBD7:addBlank()
			oBrwBD7:setPos(len(oBrwBD7:aCols))
		else
			oBrwBD7:setPos(nLinCols)
		endIf
		
		oBrwBD7:fieldPut("BD7_SEQUEN",cSequen)
		
		aadd(aPosSeq,oBrwBD7:Linha())
		
		oBrwBD7:fieldPut("BD7_UNITDE",aCompo[nInd,7])
		oBrwBD7:fieldPut("BD7_REFTDE",aCompo[nInd,3])
		
		oBrwBD7:fieldPut("BD7_CODUNM",aCompo[nInd,1])
		
		if oBrwBD7:fieldPos("BD7_CODTPA") > 0 .and. len(aCompo[nInd]) > 15

			oBrwBD7:fieldPut("BD7_CODTPA",aCompo[nInd,16])
			oBrwBD7:fieldPut("BD7_DESTPA",posicione("BWT",1,xFilial("BWT") + plsIntPad() + aCompo[nInd,16],"BWT_DESCRI"))
			
		endIf
		
		oBrwBD7:fieldPut("BD7_NLANC",iIf(allTrim(aCompo[nInd,1]) $ cMVPLSCAUX,strZero(aCompo[nInd,3],2),""))
		
		oBrwBD7:fieldPut("BD7_CODPAD",M->BD6_CODPAD)
		oBrwBD7:fieldPut("BD7_CODPRO",M->BD6_CODPRO) 

		// so altera se for registro novo
        if nLinCols == 0  
		   oBrwBD7:fieldPut("BD7_BLOPAG",if(!lPagarItem .or. aCompo[nInd,13] == "1","1","0"))
		endIf

		if oBrwBD7:fieldPos("BD7_PROBD7") > 0
			
			cProBD7Ori := "0"
			
			if empty(oBrwBD7:fieldGet("BD7_PROBD7"))
				oBrwBD7:fieldPut("BD7_PROBD7","1")
			else
				cProBD7Ori := oBrwBD7:fieldGet("BD7_PROBD7")
			endIf
			
		endIf
		
		//Considera o BD6 posicionado!!!
		if lBD7_CLAINS .and. isPLSCLAINS .and. oBrwBD7:fieldPos("BD7_CLAINS") > 0 
			oBrwBD7:fieldPut("BD7_CLAINS",PLSCLAINS())
		endIf
		
		if oBrwBD7:fieldPos("BD7_PROCCI") > 0
			oBrwBD7:fieldPut("BD7_PROCCI",if(BR8->BR8_TIPEVE $ "2,3","1","0"))
		endIf
		
		oBrwBD7:fieldPut("BD7_CODRDA",cCodRda)
		oBrwBD7:fieldPut("BD7_LOCATE",iIf(empty(cCodLoc) .or. empty(cLocal),BD6->BD6_CODLOC + BD6->BD6_LOCAL, cCodLoc + cLocal))
		oBrwBD7:fieldPut("BD7_CODLOC",iIf(empty(cCodLoc), BD6->BD6_CODLOC, cCodLoc) )
		oBrwBD7:fieldPut("BD7_LOCAL",iIf(empty(cLocal),BD6->BD6_LOCAL, cLocal) )
		oBrwBD7:fieldPut("BD7_DATPRO",dDatPro)
		oBrwBD7:fieldPut("BD7_DESLOC",BD1->(posicione("BD1",1,xFilial("BD1")+cCodInt+cCodLoc,"BD1_DESLOC")))
		
		
	elseIf cTipo == "3"
		
		BAU->(dbSetOrder(1))
		BAU->(msSeek(xFilial("BAU")+cCodRda))
		aadd(aRdas,{aCompo[nInd,1],cCodRDA,cCodLoc,cCodEsp,0,BAU->BAU_TIPPRE,0,0,if(allTrim(aCompo[nInd,1]) $ cMVPLSCAUX,strZero(aCompo[nInd,3],2),""),BD7->BD7_CONSFT})
		eval(bRest)
		
	elseIf cTipo == "4"
	
		BAU->(dbSetOrder(1))
		BAU->(msSeek(xFilial("BAU")+cCodRda))
		aadd(aRdas,{aCompo[nInd,1],cCodRDA,cCodLoc,cCodEsp,0,BAU->BAU_TIPPRE,0,0,IF(aCompo[nInd,1] $ cMVPLSCAUX,StrZero(aCompo[nInd,3],2),"") })
		eval(bRest)
		
		if !lWeb .and. valType(oBrwComp) <> "U"
		
			nPos     := oBrwComp:PLRETPOS(cAliRee+"_CODUNM")
			nPos2    := oBrwComp:PLRETPOS(cAliRee+"_SEQUEN")
			nPos3    := oBrwComp:PLRETPOS(cAliRee+"_NLANC")
			
			nLinCols := aScan(oBrwComp:aCols,{ |x| allTrim(x[nPos]) == "" .and. !x[len(x)] } )
			
			if nLinCols == 0
			
				nLinCols := aScan(oBrwComp:aCols,{ |x| allTrim(x[nPos]) == aCompo[nInd,1] .and. x[nPos2] == cSequen .and. !x[len(x)] })
				
				if nLinCols > 0
					
					if oBrwComp:fieldGet(cAliRee+"_CODUNM",nLinCols) $ cMVPLSCAUX
						nLinCols := aScan(oBrwComp:aCols,{ |x| allTrim(x[nPos]) == aCompo[nInd,1] .and. x[nPos2] == cSequen .and. allTrim(x[nPos3]) == strZero(aCompo[nInd,3],2) .and. !x[len(x)]  })
					endIf
					
				endIf
				
			endIf
			
			if nLinCols == 0
				oBrwComp:addBlank()
				oBrwComp:setPos(len(oBrwComp:aCols))
			else
				oBrwComp:setPos(nLinCols)
			endIf
			
			oBrwComp:fieldPut(cAliRee+"_SEQUEN",cSequen)
			
			aadd(aPosSeq,oBrwComp:Linha())
			
			oBrwComp:fieldPut(cAliRee+"_UNITDE",aCompo[nInd,7])
			oBrwComp:fieldPut(cAliRee+"_REFTDE",aCompo[nInd,3])
			oBrwComp:fieldPut(cAliRee+"_CODUNM",aCompo[nInd,1])
			oBrwComp:fieldPut(cAliRee+"_NLANC",if(aCompo[nInd,1] $ cMVPLSCAUX,strZero(aCompo[nInd,3],2),aCompo[nInd,16]))
			oBrwComp:fieldPut(cAliRee+"_CODPAD",cCodPad)
			oBrwComp:fieldPut(cAliRee+"_CODPRO",cCodPro)
			
			BR8->(dbSetOrder(1))
			BR8->(msSeek(xFilial("BR8")+cCodPad+cCodPro))
			
			oBrwComp:fieldPut(cAliRee+"_PROCCI",if(BR8->BR8_TIPEVE$"2,3","1","0"))
			
			eval(bRest2)
		endIf
		
	endIf

	if lCorpoCli
		
		nPos := aScan(aUnidsProp,{|x| allTrim(x[1]) == allTrim(aCompo[nInd,1])})

		if BAU->(BAU_FILIAL+BAU_CODIGO) <> xFilial("BAU") + cCodRDA
			BAU->( dbSetOrder(1) )//BAU_FILIAL+BAU_CODIGO
			BAU->( msSeek(xFilial("BAU") + cCodRDA ) )
		endIf
		
		if nPos > 0 .and. aUnidsProp[nPos,2] == "0" .and. cTipoCorpo == "1" .and. BAU->(BAU_FILIAL+BAU_CODBB0) <> xFilial("BAU") + cCodPrfExe
			BAU->( dbSetOrder(5) )//BAU_FILIAL+BAU_CODBB0
			BAU->( msSeek( xFilial("BAU") + cCodPrfExe ) )
		endIf
		
		if cTipo == "1"

			BD7->BD7_CODRDA := BAU->BAU_CODIGO
			BD7->BD7_NOMRDA := BAU->BAU_NOME
			
		elseIf cTipo == "2"
			
			oBrwBD7:fieldPut("BD7_CODRDA",BAU->BAU_CODIGO)
				
		elseIf cTipo == "3"

			aRdas[nInd,2] := cCodRda
			aRdas[nInd,6] := BAU->BAU_TIPPRE

		elseIf cTipo == "4"

			aRdas[nInd,2] := cCodRda
			aRdas[nInd,6] := BAU->BAU_TIPPRE

		endIf
		
	else
		
		if !lNovo
			BAU->(dbSetOrder(1))
			BAU->(msSeek( xFilial("BAU") + BD7->BD7_CODRDA ) )
		endIf
		
	endIf
	
	if cTipo == "1"
		
		if lBD7_TIPEVE
			BD7->BD7_TIPEVE := iIf(BAU->BAU_COPCRE == "1","1","2")
		endIf
		
		if cProBD7Ori <> "1"
			BD7->BD7_NOMRDA := BAU->BAU_NOME
		endIf
		
		if !empty(BD6->BD6_CDPFRE) .AND. !(BR8->BR8_TPPROC $ "1|2")
			BD7->BD7_NOMPRE := BB0->( posicione("BB0",1,xFilial("BB0")+BD6->BD6_CDPFRE,"BB0_NOME") )
		endIf
		
		BD7->BD7_SALDO := 0
		
		if allTrim(BD7->BD7_CODTPA) <> cNoSeApli .and. ( cTipoGuia $ G_RES_INTER + '|' + G_SOL_INTER .or. BD6->BD6_LIBERA == '1' )
			BD7->BD7_SALDO := BD6->BD6_QTDPRO
		endIf
		
		//Atualiza informacoes complementares
		if nPosPart > 0
		
			//TODO - 02/03/2017 - OSCAR - REVER este ponto acertar estrutura da matriz aPartic
			if SX5->( msSeek( xfilial("SX5") + "12" + aPartic[nPosPart,7] ) )
				lMudaEstrutura := .f.
			else
				lMudaEstrutura := .t.
			endIf
			
			//Bloco para atualizacao dos dados referentes a participacao medica em importacao de arquivos XML.
			//PARA MAT/MED NÃO PRECISAMOS GRAVAR A TIPO DE PARTICIPAÇÃO
			BD7->BD7_CODTPA := iIf(BR8->BR8_TPPROC $ "1|2", getNewPar("MV_PLSNAPL","O"),aPartic[nPosPart,1])
			BD7->BD7_NLANC  := iIf(allTrim(aCompo[nInd,1]) $ allTrim(cMVPLSCAUX),strZero(val(aPartic[nPosPart,1]),2),"")
			
			if !lMudaEstrutura

				BD7->BD7_SIGLA  := aPartic[nPosPart,5]
				BD7->BD7_REGPRE := aPartic[nPosPart,6]
				BD7->BD7_ESTPRE := aPartic[nPosPart,7]
				if !empty(BD7->BD7_REGPRE)
					BD7->BD7_NOMPRE := BB0->( Posicione("BB0",4,xFilial("BB0")+BD7->(BD7_ESTPRE+BD7_REGPRE+BD7_SIGLA),"BB0_NOME") )
				endif

			else

				BD7->BD7_SIGLA  := BB0->BB0_CODSIG
				BD7->BD7_REGPRE := aPartic[nPosPart,5]
				BD7->BD7_ESTPRE := aPartic[nPosPart,6]
				if !empty(BD7->BD7_REGPRE)
					BD7->BD7_NOMPRE := BB0->( Posicione("BB0",4,xFilial("BB0")+BD7->(BD7_ESTPRE+BD7_REGPRE+BD7_SIGLA),"BB0_NOME") )
				endif

			endIf
			
			//Na importação xml o BB0 não está posicionado, sem esta trava faz gravar o primeiro BB0 da tabela.
			if len(aPartic[nPosPart]) >= 9 .and. !empty(BD7->BD7_REGPRE)
				BD7->BD7_CDPFPR := BB0->( Posicione("BB0",4,xFilial("BB0")+BD7->(BD7_ESTPRE+BD7_REGPRE+BD7_SIGLA),"BB0_CODIGO") )
			endIf
			
			//Se já for igual, não precisa mexer
			if Len(aPartic[nPosPart]) >= 10 .and. aPartic[nPosPart,10] <> BD6->BD6_CODRDA  
			
				if len( Alltrim(aPartic[nPosPart,10])) > Len(BD6->BD6_CODRDA)
					lMudaEstrutura := .t.
				else
					aAreaBAU := BAU->(getArea())
					
					BAU->(DbSetOrder(1))
					if !(BAU->(MsSeek(xFilial("BAU") + aPartic[nPosPart,10])))
						lMudaEstrutura := .t.
					endIf
					
					BAU->(restArea(aAreaBAU))
				endIf
				
				//parametro que define se a Regra de participaçoes de Honorarios serão para os Executantes(.T.) ou Para a RDA(.F.)
				if getNewPar("MV_PLSUNRDA",.T.)				
					
					if len(aPartic[nPosPart]) >= 10 .and. !empty(aPartic[nPosPart,10]).and. ( (len(aPartic[nPosPart,13]) > 0 .and. ascan(aUnidades,{|x| alltrim(x) == Alltrim(aCompo[nInd,1])} ) == 0) .or. len(aPartic[nPosPart,13]) == 0)
						
						if lMudaEstrutura
							BD7->BD7_CODRDA := BD6->BD6_CODRDA
						else
							BD7->BD7_CODRDA := aPartic[nPosPart,10]
						endIf
						
					endIf
					
					BD7->BD7_NOMRDA := BAU->(Posicione("BAU",1,xFilial("BAU")+BD7->BD7_CODRDA,"BAU_NOME"))
					
				endIf
					
			endIf
			
			if len(aPartic[nPosPart]) >= 12 .and. !empty(aPartic[nPosPart,12])
				
				if lMudaEstrutura
					BD7->BD7_ESPEXE := aPartic[nPosPart,7]
				else
					BD7->BD7_ESPEXE := aPartic[nPosPart,12]
				endIf
				
				BD7->BD7_DESESP := BAQ->( posicione("BAQ",1, xFilial("BAQ") + BD7->(BD7_CODOPE+BD7_ESPEXE),"BAQ_DESCRI") )
				
			endIf
			
			//codigo do cbos, pois no portal é informado apenas o codigo do cbos do profissional e não tem como
			//fazer o depara para especialidade pois a relação é 1 cbo x n especialidades e eu preciso carregar o cbos
			//na alteração da guia no portal
			if BD7->(fieldPos("BD7_CBOEXE")) > 0 .and. len(aPartic[nPosPart]) >= 14 .and. !empty(aPartic[nPosPart,14]) 
				BD7->BD7_CBOEXE := aPartic[nPosPart,14]
			endIf
			
			//Se o prestador do BD7_CODRDA eh uma pessoa fisica e o executante esta vazio significa que ele mesmo executou
			if empty(BD7->BD7_CDPFPR) .and. !empty(BD7->BD7_CODRDA) .and. empty(BD7->BD7_REGPRE)
				
				aAreaBAU := BAU->(getArea()) 
				
				BAU->(dbSetOrder(1))
				BAU->(msSeek(xFilial("BAU")+BD7->BD7_CODRDA))
				
				if BAU->BAU_TIPPE == 'F' .and. !empty(BAU->BAU_CODBB0)
					
					BB0->(dbSetOrder(1))
					if BB0->(msSeek(xFilial('BB0')+BAU->BAU_CODBB0))
						
						BD7->BD7_CDPFPR := BB0->BB0_CODIGO
						BD7->BD7_SIGLA  := BB0->BB0_CODSIG
						BD7->BD7_REGPRE := BB0->BB0_NUMCR
						BD7->BD7_ESTPRE := BB0->BB0_ESTADO
						BD7->BD7_NOMPRE := BB0->BB0_NOME
						
						//se a especialidade do executante esta vazia eu vou considerar uma especialidade que o executante tenha
						//e seja valida e vou usa-la como default pois a especialidade nem sempre eh enviada
						
						if empty(BD7->BD7_ESPEXE)
							
							BQ1->(dbSetOrder(1))
							if BQ1->(msSeek(xFilial("BQ1")+BB0->BB0_CODIGO))
								BD7->BD7_ESPEXE := BQ1->BQ1_CODESP
							endIf
							
						endIf
						
					endIf
					
				endIf
				
				BAU->(restArea(aAreaBAU))
				
			endIf
			
			//tenho que deletar aquela participacao no aPartic para ele nao incluir um novo bd7 - caso do auxiliar que ele manda separado - PLSTEAM 13/11/2012
			//mesmo funcionamento para SADT, quando parâmetro ativo para importação apenas XML
			if lHonor .and. !GetNewPar("MV_PLPGPAN",.F.) .or. ( lCompIHon .and. cTipoGuia == G_SADT .and. lXmlOrigS )

				nTamCols := len(aPartic)
				aDel(aPartic,nPosPart)
				aSize(aPartic,nTamCols-1)
				
			endIf
			
		endIf
		
	elseIf cTipo == "2"
	
		if oBrwBD7:fieldPos("BD7_PROBD7") > 0
			oBrwBD7:fieldPut("BD7_TIPEVE",iIf(BAU->BAU_COPCRE == "1","1","2"))
		endIf	
		
		if (oBrwBD7:fieldPos("BD7_PROBD7") == 0 .Or. cProBD7Ori <> "1" ) .and. empty(oBrwBD7:fieldGet("BD7_NOMRDA"))
			oBrwBD7:fieldPut("BD7_NOMRDA",BAU->BAU_NOME)
		endIf
		
		if !empty(cCodPrfExe)
			
			if empty(oBrwBD7:fieldGet("BD7_REGPRE"))
				oBrwBD7:fieldPut("BD7_REGPRE",cRegExe)
			endIf
			
			if empty(oBrwBD7:fieldGet("BD7_SIGLA"))
				oBrwBD7:fieldPut("BD7_SIGLA",cSigExe)
			endIf
			
			if empty(oBrwBD7:fieldGet("BD7_ESTPRE"))
				oBrwBD7:fieldPut("BD7_ESTPRE",cEstExe)
			endIf
			
			if ! empty(BAU->BAU_CONREG) .and. empty(oBrwBD7:fieldGet("BD7_NOMPRE"))
				oBrwBD7:fieldPut("BD7_NOMPRE",cNomPrfExe)
			endIf
			
		endIf
		
		if empty(oBrwBD7:fieldGet("BD7_CDPFPR"))
			oBrwBD7:fieldPut("BD7_CDPFPR",cCodPrfExe)
		endIf
		
	endIf
	
	if cTipo == "1" .and. cCodRdaOri <> BD7->BD7_CODRDA .and. BD7->BD7_CODESP == cCodEsp
		
		aRetEspec := PLSGTESPP(cCodRdaOri)
		
		if empty(cCodEsp)
			cCodEsp := aRetEspec[1]
		endIf
		
		BD7->BD7_CODESP := cCodEsp
		BD7->BD7_DESESP := BAQ->(Posicione("BAQ",1,xFilial("BAQ")+cCodInt+cCodEsp,"BAQ_DESCRI"))
		
	elseIf cTipo == "2" .and. cCodRdaOri <> oBrwBD7:fieldGet("BD7_CODRDA") .and. oBrwBD7:fieldPos("BD7_CODESP") > 0
		
		aRetEspec := PLSGTESPP(cCodRdaOri)
		
		if empty(cCodEsp)
			cCodEsp := aRetEspec[1]
		endIf
		
		if oBrwBD7:fieldPos("BD7_CODESP") > 0
			oBrwBD7:fieldPut("BD7_CODESP",cCodEsp)
		endIf
		
		if oBrwBD7:fieldPos("BD7_DESESP") > 0
			oBrwBD7:fieldPut("BD7_DESESP",BAQ->(Posicione("BAQ",1,xFilial("BAQ")+cCodInt+cCodEsp,"BAQ_DESCRI")))
		endIf
		
	endIf
	
	if cTipo == "1"
		BD7->( msUnLock() )
	endIf	
	
next

eval(bRest)

//Tratamento para alteracao
if cTipo == "2" .and. ! empty(cSequen)
	
	nPos := aScan(oBrwBD7:aCols, {|x| x[oBrwBD7:fieldPos("BD7_SEQUEN")] == cSequen } )
	
	if nPos > 0
		
		for nI := nPos to len(oBrwBD7:aCols)
			
			if oBrwBD7:fieldGet("BD7_SEQUEN",nI) == cSequen
				
				if aScan(aPosSeq,nI) == 0
					oBrwBD7:aCols[nI][len(oBrwBD7:aCols[nI])] := .t.
				else
	
					oBrwBD7:fieldGet("BD7_SEQUEN",nI)
					oBrwBD7:setPos(nI)
				endIf
				
			endIf
			
		next
		
	endIf	
	
endIf

//Tratamento para alteracao
if ! lWeb

	if cTipo == "4" .and. !empty(cSequen) .and. valType(oBrwComp) <> "U"
		
		for nI := 1 to len(oBrwComp:aCols)
			
			if oBrwComp:fieldGet(cAliRee+"_SEQUEN",nI) == cSequen
				
				if aScan(aPosSeq,nI) == 0
					oBrwComp:aCols[nI][len(oBrwComp:aCols[nI])] := .t.
				else
					oBrwComp:setPos(nI)
				endIf
				
			endIf
			
		next
		
	endIf
	
	// Tratamento para os itens de participaçõa AUX que estao vindo no xml e não estao na estrutura do procedimentos, e o prestador esta fazendo a cobrança
	// estamos importando como UNL para analise de glosa
	if getNewPar("MV_PLCAAUX","1") == "3"
	
		for px := 1 to len(aPartic)
	
			if aScan(aParNoUnl,{|x| allTrim(x[2]) == aPartic[px,1]}) == 0 .and. IIF( ValType(aPartic[px][13]) == "C", aPartic[px][13] $ cMVPLSCAUX, aScan(aPartic[px][13],{|x| allTrim(x) $ cMVPLSCAUX}) > 0)
				PCrB7Gen("UNL",{aPartic[px]})
			endIf	
		
		next px
	
	endIf
	
endIf

return(aRdas)

/*/{Protheus.doc} PLSA720AJU
Tratamento para a opcao de ajuste de guias
@type function
@author PLSTEAM
@since 18.09.03
@version 1.0
/*/
function PLSA720AJU(aPar)
local cTipoGuia := aPar[1]
local aCampos   := aClone(aPar[2])
local cAlias    := aPar[3]
local nPos		:= 0
local nFor		:= 0
local aRetorno  := {}
local cAux		:= ""
local cMacro1	:= ""
local cMacro2	:= ""

nPos    := aScan(aCampos,{|x| x[1] == cAlias})
aCampos := aClone(aCampos[nPos,2])

for nFor := 1 To len(aCampos)
	
	cAux := aCampos[nFor]
	
	if cTipoGuia $ G_CONSULTA + "|" + G_SADT_ODON + "|" + G_HONORARIO + "|" + G_REC_GLOSA

		cMacro1 := "M->"+cAux
		cMacro2 := "BD5->"+cAux
		
	elseIf cTipoGuia $ G_SOL_INTER + "|" + G_RES_INTER

		cMacro1 := "M->"+cAux
		cMacro2 := "BE4->"+cAux

	endIf
	
	if ( &cMacro1 <> &cMacro2 )
		aadd(aRetorno,cAux)
	endIf
	
next

return(aRetorno)

/*/{Protheus.doc} PLSA720CPO
Retorna os campos que serao exibidos na enchoice do ajuste
@type function
@author PLSTEAM
@since 18.09.03
@version 1.0
/*/
function PLSA720CPO()
local cTipoGuia := aPar[1]
local aAliasFld := {}

if cTipoGuia $ G_CONSULTA + "|" + G_SADT_ODON + "|" + G_HONORARIO + "|" + G_REC_GLOSA

	aadd(aAliasFld,{"BD5",{"BD5_CODRDA","BD5_USUARI"}})
	aadd(aAliasFld,{"BD6",{"BD6_CODPRO"}})
	
elseIf cTipoGuia $ G_SOL_INTER + "|" + G_RES_INTER

	aadd(aAliasFld,{"BE4",{"BE4_CODRDA","BE4_USUARI"}})
	aadd(aAliasFld,{"BD6",{"BD6_CODPRO"}})
	
endIf

return(aAliasFld)

/*/{Protheus.doc} PLSA720VLD
Validacoes de campos
@type function
@author PLSTEAM
@since 18.09.03
@version 1.0
/*/
function PLSA720VLD(aPar)
return(.t.)

/*/{Protheus.doc} PLSA720BAJ
Validacoes de campos
@type function
@author PLSTEAM
@since 18.09.03
@version 1.0
/*/
user function PLSA720BAJ
local cAlias    := paramixb[1]
local cTipoGuia := paramixb[2]
local nOpc		:= paramixb[3]

if cAlias == "BD7"

	oBrwBD7:bFilter    	:= {|nLine,aCols,aHeader| aCols[nLine,PLRETPOS("BD7_SEQUEN",aHeader)] == oBrwBD6:FieldGet("BD6_SEQUEN") }
	oBrwBD7:oPai 		:= oBrwBD6
	oBrwBD7:aOrigem    	:= {"BD6_SEQUEN"}
	oBrwBD7:aRelac     	:= {"BD7_SEQUEN"}
	
	if type("oBrwBD7:oBrowse") == "O"
		oBrwBD7:oBrowse:bDelOk := {|| PLSA720DEL() }
	endIf	
	
	oBrwBD7:cVldLine := "PLA720CT(" + cTipoGuia + ")"

	oBrwBD7:bChange  := {|| eval(oBrwBD7:bGotFocus) }
	oBrwBD7:bGotFocus:= {|| oBrwBD7:oBrowse:oBrowse:refresh() }
	
	oBrwBD6:refresh()
	oBrwBD6:oBrowse:oBrowse:setFocus()
	
elseIf cAlias == "BD6"
	
	oBrwBD6:bChange    	:= {|| oBrwBD7:forceRefresh(oBrwBD6) }
	oBrwBD6:bGotFocus  	:= {|| cObjBrw := "oBrwBD6", oBrwBD7:forceRefresh(oBrwBD6) }
	oBrwBD6:bAfterAdd   := {|| oBrwBD7:forceRefresh(oBrwBD6) }

	if findFunction('P090Pacote')
		oBrwBD6:aButEsp	 := {{"VERNOTA", {|| VerPacote(cAlias)},STR0057,STR0058}} //"Visualizar procedimentos contidos no pacote"###"Pacote"
	endIf
	
	if PLSALIASEX("BX6") .and. len(oBrwBD6:aButEsp) > 0
		aadd(oBrwBD6:aButEsp,{"S4WB007N",{ || PLSA500BX6(nOpc) },STR0135,STR0136}) //"Complemento do Evento"###"Comp. Evento"
	endIf

elseIf cAlias == "B43" .and. type("oBrwB43") == "O" .and. type("oBrwB43:oBrowse") == "O" .and. type("oBrwB43:oBrowse:oBrowse") == "O"

	oBrwB43:oBrowse:oBrowse:bWhen := { || Type("M->BD6_CODPRO") == "C" }

endIf

return

/*/{Protheus.doc} PLA720CT
Verifica se a unidade de medida faz parte da TDE padrao
@type function
@author PLSTEAM
@since 05.12.06
@version 1.0
/*/
function PLA720CT(cTipoGuia)
local aArea	  := BD4->(getArea())
local cCodOpe := ""
local cCodTab := ""
local cCodPad := ""
local cCodPro := ""
local cCodRda := ""
local cCodEsp := ""
local cSubEsp := ""
local cCodLoc := ""
local cMatric := ""

local dDatPro := ctod("")
local cCodEsp := ""
local cErro   := ""
local cCampo  := ""
local lOK     := .t.
local aComEve := {}
local aCodTab := {}
local nRecBAU := 0

SX3->(dbSetOrder(2))

// Validacao dos campos, caso nao existam sera apresentada mensagem na tela
if strZero(cTipoGuia,2) $ G_CONSULTA + "|" + G_SADT_ODON + "|" + G_HONORARIO + "|" + G_REC_GLOSA

	if ! Type("M->BD5_LOCATE") == "C"

		if SX3->(msSeek("BD5_LOCATE"))
			cCampo := Trim(X3TITULO())
		else
			cCampo := ""
		endIf
		cErro += cCampo + "(BD5_LOCATE),"
	endIf
	
	cCodRda := M->BD5_CODRDA
	cCodLoc	:= M->BD5_CODLOC
	cMatric := M->(BD5_CODOPE+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO)
	
elseIf strZero(cTipoGuia,2) $ G_SOL_INTER + "|" + G_RES_INTER

	if ! Type("M->BE4_CODLOC") == "C"

		if SX3->(msSeek("BE4_CODLOC"))
			cCampo := Trim(X3TITULO())
		else
			cCampo := ""
		endIf
		
		cErro += cCampo + "(BE4_CODLOC),"
		
	endIf
	
	cCodRda := M->BE4_CODRDA
	cCodLoc	:= M->BE4_CODLOC
	cMatric := M->(BE4_CODOPE+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)
	
endIf

if oBrwBD6:fieldPos("BD6_DATPRO") == 0
	
	if SX3->(msSeek("BD6_DATPRO"))
		cCampo := Trim(X3TITULO())
	else
		cCampo := ""
	endIf
	cErro += cCampo + "(BD6_DATPRO),"
endIf

if oBrwBD6:fieldPos("BD6_CODESP") == 0
	if SX3->(msSeek("BD6_CODESP"))
		cCampo := Trim(X3TITULO())
	else
		cCampo := ""
	endIf
	cErro += cCampo + "(BD6_CODESP),"
endIf

if allTrim(cCampo) <> ""
	lOK := .f.
	MsgAlert(STR0059 + cErro + chr(13) +  STR0060 ,STR0061)  //"Campos necessarios a esta rotina não encontrados: "###"Eles devem ser adicionados no layout para este tipo de guia atraves do cadastro tipos de guias (PLSA496)."###"Campos inexistentes."
endIf

// Valida se a unidade de medida faz parte da Tabela da TDE
if lOK

	cCodOpe	:= BCI->BCI_CODOPE
	
	cCodEsp := oBrwBD6:fieldGet("BD6_CODESP",oBrwBD6:linha())
	cSubEsp := oBrwBD6:fieldGet("BD6_SUBESP",oBrwBD6:linha())
	
	cCodPad := oBrwBD6:fieldGet("BD6_CODPAD",oBrwBD6:linha())
	cCodPro := oBrwBD6:fieldGet("BD6_CODPRO",oBrwBD6:linha())
	dDatPro	:= oBrwBD6:fieldGet("BD6_DATPRO",oBrwBD6:linha())
	cCodEsp	:= oBrwBD6:fieldGet("BD6_CODESP",oBrwBD6:linha())
	
	if Empty(dDatPro)
		if strZero(cTipoGuia,2) $ G_SOL_INTER + "|" + G_RES_INTER
			dDatPro := M->BE4_DATPRO
		else
			dDatPro := M->BD5_DATPRO
		endIf
	endIf

	if M->BD7_CODRDA <> cCodRda			
		nRecBAU := BAU->(recno())						
		BAU->(dbSetOrder(1))		
		BAU->(MsSeek(xFilial("BAU") + M->BD7_CODRDA))		
	endif
	
	aCodTab := PLSRETTAB(cCodPad,cCodPro,dDatPro,cCodOpe,cCodRda,cCodEsp,cSubEsp,cCodLoc,;
						 dDatPro, "1", cCodOpe, "", "1", "1", nil,iIf( ! empty(BAU->BAU_TIPPRE), BAU->BAU_TIPPRE, nil),;
						 nil, nil, strZero(cTipoGuia,2) == G_REEMBOLSO)
	if aCodTab[1]
		cCodTAB := aCodTab[3]
	endIf

	if ! empty(cCodTab)	
		
		lFoundBD4 := plChkBD4(cCodOpe+ cCodTab + cCodPad + cCodPro, M->BD7_CODUNM)[1]
		
		if ! lFoundBD4 
			lOK := .f.
			msgAlert(STR0062+" '" + M->BD7_CODUNM + "' "+STR0063+" '" + cCodTab + "' " + STR0064 + cCodPad+" "+STR0065+" " + cCodPad + "-" + allTrim(cCodPro)+ "." + CHR(13) + STR0066 ,STR0067) //"A unidade de medida"###"não faz parte da TDE"###"e tambem de nenhuma outra TDE do tipo "###"para o procedimento"###"Não e possível incluir esta unidade."###"Mensagem"
		endIf
				
		BD4->(restArea(aArea))
	else
		lOK := .f.
		MsgAlert(STR0062+" '" + M->BD7_CODUNM + "' "+STR0063+" '" + cCodTab + "' " + STR0064 + cCodPad+" "+STR0065+" " + cCodPad + "-" + allTrim(cCodPro) + "." + CHR(13) + STR0066 ,STR0067)		 //"A unidade de medida"###"não faz parte da TDE"###"e tambem de nenhuma outra TDE do tipo "###"para o procedimento"###"Não e possível incluir esta unidade."###"Mensagem"
	endIf 
	
	if nRecBAU > 0
		BAU->(DbGoto(nRecBAU))
	endif
	
endIf

return(lOK)

/*/{Protheus.doc} PLSA720DEL
@type function
@author PLSTEAM
@since 15/08/2002
@version 1.0
/*/
function PLSA720DEL
local nFor	:= 0
local lPode := .f.

//Esta deletado nao preciso checar de novo
if ! oBrwBD7:NotDel() 
	return(.t.)
endIf

for nFor := 1 To len(oBrwBD7:aCols)

	if oBrwBD6:fieldGet("BD6_SEQUEN") == oBrwBD7:fieldGet("BD7_SEQUEN")
		
		if nFor <> oBrwBD7:Linha() .and. ! oBrwBD7:aCols[nFor,oBrwBD7:ColDel()]
			lPode := .t.
		endIf
		
	endIf
	
next

if ! lPode
	Aviso( STR0068, ; //"Deletar"
	STR0069,; //"Nao e permitido excluir todos as unidades de pagamento relacionadas a esta guia. Mantenha pelo menos um item ativo."
	{ "Ok" }, 2 )
endIf

if lUnimed .and. lPode 
	lPode := PLS500B6S()
endif

return(lPode)

/*/{Protheus.doc} PlErroCons
Verifica erro controlado na consolidacao
@type function
@author PLSTEAM
@since 21.07.06
@version 1.0
/*/
function PlErroCons(aErro)
local nOrdBD6   := BD6->(indexOrd())
local nRecBD6   := BD6->(recno())
local bRest     := {|| BD6->(dbSetOrder(nOrdBD6)),BD6->(dbGoto(nRecBD6))}
local nVlrToBD6 := 0
local nVlrToBDH := 0
local cRecBD6	:= ""
local aStruBDH  := BDH->(DbStruct())
local aCampNum  := {}
local nI		:= 0
local nSize		:= 0
local nDif      := 0
local cLastCam  := ""

aEval(aStruBDH,{ |x| iIf( x[2] == 'N' .and. !(allTrim(x[1]) $ "BDH_QTDEVE,"),aadd( aCampNum , x[1] ), nil ) } )

//---------------------------------------------
// Atualiza dados de todos os BD6s relacionados a este BDH... (inclusive seu cabecalho que pode ser BD5 ou BE4)
//---------------------------------------------
SIX->( dbSetOrder(01) )
if cPaisLoc <> 'BRA' .and. SIX->( msSeek("BD6L") )
	cKeyBDH := BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_LANCF+BDH_SEQPF)
	cKeyBD6 := "BD6->(BD6_FILIAL+BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_ANOPAG+BD6_MESPAG+BD6_LANCF+BD6_SEQPF)"
	nOrdem 	:= 21
else
	cKeyBDH := BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_SEQPF)
	cKeyBD6 := "BD6->(BD6_FILIAL+BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_ANOPAG+BD6_MESPAG+BD6_SEQPF)"
	nOrdem 	:= 12
endIf

BD6->(dbSetOrder(nOrdem))
if BD6->(msSeek(xFilial("BD6")+cKeyBDH))

	while ! BD6->(eof()) .and. &cKeyBD6 ==	xFilial("BD6") + cKeyBDH
		
		nVlrToBD6 += BD6->BD6_VLRTPF
		cRecBD6	  += allTrim(str(BD6->(recno())))
		
		BD6->(dbSkip())
		
		if ! BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_ANOPAG+BD6_MESPAG+BD6_SEQPF) == ;
								xFilial("BD6")+BDH->(BDH_CODINT+BDH_CODEMP+BDH_MATRIC+BDH_TIPREG+BDH_ANOFT+BDH_MESFT+BDH_SEQPF)
			cRecBD6 += ','
		endIf
		
	endDo
	
	for nI := 1 to len(aCampNum)
		
		if (allTrim(aCampNum[nI]) $ 'BDH_VLBRPA/BDH_VLCOPA')
			nVlrToBDH += &("BDH->"+aCampNum[nI])
		endIf
		
		if &("BDH->"+aCampNum[nI]) > 0
			cLastCam := "BDH->"+aCampNum[nI]
		endIf
		
	next
	
	// Atencao !! nao colocar round neste ponto, pois sempre o valor total
	//do BD6 deve ter 2 casas decimais
	//se por alguma razão o valor do bd6 esta com mais de 2 casas o contas
	//medicas esta mandando errado										
	if nVlrToBD6 <> nVlrToBDH
	
		nDif := nVlrToBDH - nVlrToBD6
		
		if nDif > 0 .and. nDif < 0.03
			
			BDH->(recLock("BDH",.f.))
				&(cLastCam) -= abs(nDif)
			BDH->(msUnLock())
			
		elseIf nDif < 0 .and. nDif > -0.03
		
			BDH->(recLock("BDH",.f.))
				&(cLastCam) += abs(nDif)
			BDH->(msUnLock())
			
		endIf
		
	endIf
	
	nVlrToBDH := 0
	aEval(aCampNum,{|x| iIf( !(allTrim(x) $ 'BDH_VLBRPA/BDH_VLCOPA'),( nVlrToBDH += &("BDH->"+x) ),0 ) } )
	
	if (BDH->BDH_VALOR <> 0 .and. BDH->BDH_INTERC == '1')
		if (nI := aScan(aErro,{|x| x[7]+x[5] == '02'+allTrim(str(BDH->(recno())))})) == 0
			aadd(aErro, { STR0072,; //"Tentativa de consolidacao de fator moderador como intercambio."
			BDH->(' ['+BDH_CODINT+'.'+BDH_CODEMP+'.'+BDH_MATRIC+'.'+BDH_TIPREG+'] '+BDH_ANOFT+'/'+BDH_MESFT+' ['+BDH_SEQPF+'] '),;
				transForm(nVlrToBDH,PLPMONEY_M),;
				transForm(nVlrToBD6,PLPMONEY_M),;
				allTrim(str(BDH->(recno()))),;
				cRecBD6,;
				'02' })//codigo do erro
		else
			aErro[nI][3] := transForm(nVlrToBDH,PLPMONEY_M)
			aErro[nI][4] := transForm(nVlrToBD6,PLPMONEY_M)
			aErro[nI][6] := cRecBD6
		endIf
	endIf
	
	if round(nVlrToBD6, PLGetDec('BD6_VLRTPF') ) <> round(nVlrToBDH, PLGetDec('BD6_VLRTPF')) .and. getNewPar("MV_PLERCON","1") == "1"
	
		if (nI := aScan(aErro,{|x| x[7]+x[5] == '01'+allTrim(str(BDH->(recno())))})) == 0
	
			aadd(aErro, { 	STR0073,; //"Divergencia entre valores de participação financeira entre BDH e BD6."
							BDH->(' ['+BDH_CODINT+'.'+BDH_CODEMP+'.'+BDH_MATRIC+'.'+BDH_TIPREG+'] '+BDH_ANOFT+'/'+BDH_MESFT+' ['+BDH_SEQPF+'] '),;
							transForm(nVlrToBDH,PLPMONEY_M),;
							transForm(nVlrToBD6,PLPMONEY_M),;
							allTrim(str(BDH->(recno()))),;
							cRecBD6,;
							'01' })//codigo do erro
		else
		
			aErro[nI][3] := transForm(nVlrToBDH,PLPMONEY_M)
			aErro[nI][4] := transForm(nVlrToBD6,PLPMONEY_M)
			aErro[nI][6] := cRecBD6
			
		endIf
		
	else
		//-------------------------------------------------
		// Aqui se uma relacao BDH x BD6 estava errada ate que se consolidou   |
		//| um BD6 que corrigiu a relacao,o BDH nao mais deve ser considerado   |
		//| invalido, logo exclui ele do array												|
		//-------------------------------------------------
		if (nI := aScan(aErro,{|x| x[7]+x[5] == '01'+allTrim(str(BDH->(recno())))})) > 0
			nSize := len(aErro)
			aDel(aErro,nI)
			nSize--
			aSize(aErro,nSize)
		endIf
	endIf
	
endIf

eval(bRest)

return

/*/{Protheus.doc} PlDelCons
Deleta a consolidação realizada
@type function
@author PLSTEAM
@since 12.03.04
@version 1.0
/*/
function PlDelCons(aErro)
local nI := 0

if len(aErro) > 0
	Begin transaction
		for nI:=1 to len(aErro)
			
			BDH->(dbGoto(val(aErro[nI][5])))
			PLSM180Del() //limpa seqpf a partir de um bdh
			
			BDH->(recLock("BDH",.f.))
			BDH->(DbDelete())
			BDH->(msUnLock())
			
		next
	End transaction
	PLSCRIGEN(aErro,{ {STR0074,"@C",180},{STR0075,"@C",120},{STR0076,"@C",50},{STR0077,"@C",50},{"R_E_C_N_O_ BDH","@C",50},{"R_E_C_N_O_ BD6","@C",50} }, STR0078,nil,nil,nil,nil, nil,nil,"G",220) //"Critica"###"Chave BDH"###"Total BDH"###"Total BD6"###"  CRITICAS DE INTEGRIDADE NA CONSOLIDACAO, A CONSOLIDACAO DESTAS GUIAS FORAM EXCLUIDAS "
	
endIf

return

/*/{Protheus.doc} PLSA720IPD
@type function
@author PLSTEAM
@since 12.03.04
@version 1.0
/*/
function PLSA720IPD(lConDel)
local cRet

default lConDel := .t.

if Type("oBrwBD6") == "O"
	cRet := PLSINCRE("BD6_SEQUEN",oBrwBD6,lConDel)
else
	cRet := PLSINCRE("BD6_SEQUEN")
endIf

return(cRet)

/*/{Protheus.doc} PLSA720IP2
@type function
@author PLSTEAM
@since 12.03.04
@version 1.0
/*/
function PLSA720IP2()
local cRet

if Type("oBrwBD6") == "O"
	cRet := oBrwBD6:fieldGet("BD6_SEQUEN")
else
	cRet := "001"
endIf

return(cRet)

/*/{Protheus.doc} PLSA720VPR
@type function
@author PLSTEAM
@since 12.03.04
@version 1.0
/*/
function PLSA720VPR()
local lRet			:= .t.
local aVetTab		:= {}
local aComEve		:= {}
local cCodTab		:= ''
local cPLSREGANVE  	:= getNewPar("MV_PLSRADP","1")
local dDatAnalise	:= stod('')
local cCodLoc      	:= ''
local cCodEsp      	:= ''
local cCodRda      	:= ''
local cTipoGuia		:= ''
local cCodInt		:= PLSINTPAD()
local cLocal		:= ''
local aDadUsr		:= {}
local cMatric		:= ''
local lNumInt		:= .F.
Local cProduto		:= ""

if existBlock("PLSDATAN")
	cPLSREGANVE := execBlock("PLSDATAN",.f.,.f.,{BCL->BCL_TIPGUI,cPLSREGANVE})
endIf

if BCL->BCL_TIPGUI == G_CONSULTA
	lRet := plsCkCon(BCI->BCI_TIPGUI,M->BD6_CODPAD,M->BD6_CODPRO)
endIf	

if lRet

	if Type('M->BE4_CODLOC') <> "U"
		cCodLoc := M->BE4_CODLOC
	endIf
	if Type('M->BE4_LOCAL') <> "U"
		cLocal := M->BE4_CODLOC
	endIf
	if Type('M->BD5_CODLOC') <> "U"
		cCodLoc := M->BD5_CODLOC
	endIf
	if Type('M->BD5_LOCAL') <> "U"
		cLocal := M->BD5_CODLOC
	endIf
	if Type('M->BD5_CODRDA')<> "U"
		cCodRda := M->BD5_CODRDA
	endIf
	if Type('M->BD5_TIPGUI')<> "U"
		cTipoGuia := M->BD5_TIPGUI
	endIf
	
	if Type('M->BE4_CODRDA') <> "U"
		cCodRda := M->BE4_CODRDA
	endIf
	if Type('M->BD5_CODESP')<> "U"
		cCodEsp := M->BD5_CODESP
	endIf
	if Type('M->BE4_CODESP')<> "U"
		cCodEsp := M->BE4_CODESP
	endIf
	if Type('M->BE4_TIPGUI')<> "U"
		cTipoGuia := M->BE4_TIPGUI
	endIf
	
	if BCL->BCL_TIPGUI == G_RES_INTER .and. Empty(M->BE4_GUIINT)
		lNumInt := .t.
	endif
	
	if !lNumInt	
	
		if cTipoGuia $ G_SOL_INTER + '|' + G_RES_INTER
			cMatric := M->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)
		else
			cMatric := M->(BD5_OPEUSR+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO)
		endIf
		
		if cPLSREGANVE == "1" //data do evento
		
			if Type('M->BD6_DATPRO') == "D"
		
				dDatAnalise := M->BD6_DATPRO
		
				if empty(dDatAnalise)
		
					if Type('M->BD5_DATPRO') == "D"
						dDatAnalise := M->BD5_DATPRO
					elseIf Type('M->BE4_DATPRO') == "D"
						dDatAnalise := M->BE4_DATPRO
					endIf
		
				endIf
		
			elseIf Type('M->BD5_DATPRO') == "D"
				dDatAnalise := M->BD5_DATPRO
			elseIf Type('M->BE4_DATPRO') == "D"
				dDatAnalise := M->BE4_DATPRO
			else
				dDatAnalise := dDataBase
			endIf
			if empty(dDatAnalise)
				dDatAnalise := dDataBase
			endIf
		else //data da mudanca de fase/valorizacao
			dDatAnalise := dDataBase
		endIf
		
		BR8->(dbSetOrder(1))
		lRet := BR8->(msSeek(xFilial("BR8")+M->BD6_CODPAD+M->BD6_CODPRO))
		
		if lRet
		
			if BR8->BR8_ANASIN == "1"
		
				//procura para ver se existe composicao
				if lRet
					//busca o produto do beneficiário, primeiro na BA1 e se não tiver, na BA3
					BA1->(dbsetOrder(2))
					if BA1->(MsSeek(xfilial("BA1") + cMatric))
						cProduto := BA1->BA1_CODPLA
						if empty(cProduto)
							BA3->(dbsetorder(1))
							if BA3->(MsSeek(xfilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
								cProduto := BA3->BA3_CODPLA
							endif
						endif
					endif

					aVetTab := PLSRETTAB(BR8->BR8_CODPAD,BR8->BR8_CODPSA,dDatAnalise,cCodInt,cCodRda,cCodEsp,"",cCodLoc,;
										dDatAnalise,"1",cCodInt,cProduto,"1","1",nil,iIf( ! empty(BAU->BAU_TIPPRE),BAU->BAU_TIPPRE,nil),;
										nil,nil,(cTipoGuia==G_REEMBOLSO))
	
					lRet := aVetTab[1]
					
					if lRet
						cCodTab   		:= aVetTab[3]
						M->BD6_CODTAB 	:= cCodTab
						
						aComEve  := PLSCOMEVE(cCodTab,BR8->BR8_CODPAD,BR8->BR8_CODPSA,cCodInt,dDatAnalise)
						
						lRet := len(aComEve) > 0
						if ! lRet
							Aviso( STR0086, ; //"Procedimento"
								   STR0087,; //"Procedimento informado invalido (parametros de pagamento na TDE ou Operadora Padrao)."
									{ "Ok" }, 2 )
						endIf
					else
						Aviso( STR0086, ; //"Procedimento"
							   STR0087,; //"Procedimento informado invalido (parametros de pagamento na TDE ou Operadora Padrao)."
							   { "Ok" }, 2 )
					endIf
				endIf
			else
				lRet := .f.
				Aviso( STR0086, ; //"Procedimento"
					   STR0088,; //"O procedimento informado e sintetico. Nao pode ser digitado como movimento."
					   { "Ok" }, 2 )
			endIf
			
		else
			Help("",1,"REGNOIS")
		endIf
	
	else
		lRet := .f.
		Aviso( STR0144, ; //"Número de Internação"
			   STR0145,;  //"Informe o número da Solicitação de Internação."
			   { "Ok" }, 2 )
	endif
	
endIf

return(lRet)

/*/{Protheus.doc} PLSA720IMP
@type function
@author PLSTEAM
@since 12.03.04
@version 1.0
/*/
function PLSA720IMP()

local lRet := .t.

return(lRet)

/*/{Protheus.doc} PLSA720IPR
@type function
@author PLSTEAM
@since 12.03.04
@version 1.0
/*/
function PLSA720IPR(lNew)
local nOrdBD6   := BD6->(indexOrd())
local cCodPadP  := Space(len(BD6->BD6_CODPAD))
local cCodProP  := Space(len(BD6->BD6_CODPRO))
local cPtoEnt	:= ""

default lNew	:= .f.

if existBlock("PLS720PR")
	
	cPtoEnt := execBlock("PLS720PR",.f.,.f.)
	
	if ! empty(cPtoEnt)
		cCodProP := cPtoEnt
	endIf
	
endIf

return( iIf( lNew,{ cCodPadP,cCodProP },cCodProP ) )

/*/{Protheus.doc} PLSA720F3S
@type function
@author PLSTEAM
@since 12.03.04
@version 1.0
/*/
function PLSA720F3S()
local aDados := {}
local aCabec := { {STR0128,"@C",40}, {STR0129,"@C",40} , {STR0130,"@C",200 } } //"Sequencia"###"Codigo"###"Descricao"
local nFor
local aRet
local lOK := .f.

for nFor := 1 To len(oBrwBD6:aCols)
	if oBrwBD6:NotDel() .and. ;
			oBrwBD6:fieldGet("BD6_CODPAD",nFor)+oBrwBD6:fieldGet("BD6_CODPRO",nFor) <> M->BD6_CODPAD+M->BD6_CODPRO
		aadd(aDados,{oBrwBD6:fieldGet("BD6_SEQUEN",nFor),oBrwBD6:fieldGet("BD6_CODPRO",nFor),oBrwBD6:fieldGet("BD6_DESPRO",nFor)})
	endIf
next

if len(aDados) == 0
	Help("",1,"PLSA720FE2")
return
endIf

aRet := PLSCRIGEN(aDados,aCabec,STR0089,.f.) //"Selecione o Procedimento"

if aRet[1]
	BR8->(dbSetOrder(1))
	lOK := BR8->(msSeek(xFilial("BR8")+M->BD6_CODPAD+aDados[aRet[2],2]))
endIf

if lOk
	M->BD6_SEQREL := aDados[aRet[2],1]
endIf

return(lOK)

/*/{Protheus.doc} PLSA720F3R
@type function
@author PLSTEAM
@since 12.03.04
@version 1.0
/*/
function PLSA720F3R()
local nFor
local lRet := .f.

for nFor := 1 To len(oBrwBD6:aCols)
	if oBrwBD6:NotDel() .and. ;
			! empty(oBrwBD6:fieldGet("BD6_CODPRO",nFor)) .and. ;
			oBrwBD6:fieldGet("BD6_CODPRO",nFor) == M->BD6_PROREL
		lRet := .t.
		Exit
	endIf
next

//Caso nao exista o procedimento na guia ele busca na tabela padrao
if ! lRet
	BR8->(dbSetOrder(1))
	lRet := BR8->(msSeek(xFilial("BR8")+M->BD6_CODPAD+M->BD6_PROREL))
endIf

if ! lRet
	Help("",1,"PLSA720FE3")
endIf

return(lRet)

/*/{Protheus.doc} PLSA720B2
@type function
@author PLSTEAM
@since 30.11.20
@version 1.0
/*/
function PLSA720B2()
local cVar      := ReadVar()
local cConteudo := &(SubSTr(cVar,1,6)+"_BLOPAG")
local cDesBlo   := &(SubSTr(cVar,1,6)+"_DESBPG")
local cMotBlo   := &(SubSTr(cVar,1,6)+"_MOTBPG")
local nFor

if cConteudo == "1"
	if ! empty(cMotBlo)
		BCT->(dbSetOrder(1))
		BCT->(msSeek(xFilial("BCT")+PLSINTPAD()+cMotBlo))
		cDesBlo := BCT->BCT_DESCRI
		&(SubStr(cVar,1,6)+"_DESBPG")  := cDesBlo
	endIf
else
	cDesBlo := Space(len(cDesBlo))
	cMotBlo := Space(len(cMotBlo))
	
	&(SubSTr(cVar,1,6)+"_DESBPG") := cDesBlo
	&(SubSTr(cVar,1,6)+"_MOTBPG") := cMotBlo
endIf

if Type("oBrwBD6") == "O"

	for nFor := 1 To len(oBrwBD6:aCols)
	
		oBrwBD6:fieldPut("BD6_BLOPAG",cConteudo,nFor)
		oBrwBD6:fieldPut("BD6_DESBPG",cDesBlo,nFor)
		oBrwBD6:fieldPut("BD6_MOTBPG",cMotBlo,nFor)
		
	next
	
	oBrwBD6:Refresh()
endIf

if Type("oBrwBD7") == "O"

	for nFor := 1 To len(oBrwBD7:aCols)
	
		oBrwBD7:fieldPut("BD7_BLOPAG",cConteudo,nFor)
		oBrwBD7:fieldPut("BD7_DESBLO",cDesBlo,nFor)
		oBrwBD7:fieldPut("BD7_MOTBLO",cMotBlo,nFor)
		
	next
	
	oBrwBD7:Refresh()
endIf

return .t.

/*/{Protheus.doc} PLSA720BPG
@type function
@author PLSTEAM
@since 12.03.04
@version 1.0
/*/
function PLSA720BPG()
local lRet := .t.
local nfor

if Type("oBrwBD7") == "O"
	for nFor := 1 To len(oBrwBD7:aCols)
		if M->BD6_SEQUEN == oBrwBD7:fieldGet("BD7_SEQUEN",nFor)
			
			oBrwBD7:fieldPut("BD7_BLOPAG",M->BD6_BLOPAG,nFor)
			
			if M->BD6_BLOPAG == "0"
				oBrwBD7:fieldPut("BD7_DESBLO","",nFor)
			else
				oBrwBD7:fieldPut("BD7_DESBLO",M->BD6_DESBPG,nFor)
			endIf
			
			if oBrwBD7:fieldPos("BD7_MOTBLO") > 0
				if M->BD6_BLOPAG == "0"
					oBrwBD7:fieldPut("BD7_MOTBLO","",nFor)
				else
					oBrwBD7:fieldPut("BD7_MOTBLO",M->BD6_MOTBPG,nFor)
				endIf
			endIf
			
		endIf
	next
endIf

return(lRet)

/*/{Protheus.doc} PLSA720NF
@type function
@author PLSTEAM
@since 12.03.04
@version 1.0
/*/
function PLSA720NF()
local lRet := .f.
local nfor

SD1->(dbSetOrder(1))
lRet := Vazio() .or. SD1->( msSeek( xFilial("SD1") + allTrim(M->BD6_NF) ) )

if lRet

	M->BD6_VALORI := SD1->D1_CUSTO
	M->BD6_VLRAPR := SD1->D1_CUSTO / SD1->D1_QUANT
	
	if Type("oBrwBD7") == "O"
	
		for nFor := 1 To len(oBrwBD7:aCols)
			oBrwBD7:fieldPut("BD7_BLOPAG","1",nFor)
		next
		
	endIf
	
else
	Help("",1,"REGNOIS")
endIf

return(lRet)

/*/{Protheus.doc} PLSBD7RDA
@type function
@author PLSTEAM
@since 12.03.04
@version 1.0
/*/
function PLSBD7RDA()
local cCodRdaOri := BCI->BCI_CODRDA
local cCodEspExe := BAX->BAX_CODESP
local aRetEspec
local cCodRdaGuia := &(readvar())

if Type('M->BD7_CODESP') == "C"
	aRetEspec := PLSGTESPP(cCodRdaGUia)
	M->BD7_CODESP := aRetEspec[1]
	M->BD7_DESESP := aRetEspec[2]
	lRefresh := .t.
endIf

return(.t.)

/*/{Protheus.doc} PLSVLLCBD5
Validacao do local de atendimento
@type function
@author PLSTEAM
@since 13.05.05
@version 1.0
/*/
function PLSVLLCBD5(cAlias)
local aRetFun
local lRet := .t.

default cAlias := "BD5"

if ! empty( &('M->'+cAlias+'_LOCATE') )
	
	aRetFun := PLSVDLOCRD(&('M->'+cAlias+'_CODRDA'),&('M->'+cAlias+'_OPERDA'),&('M->'+cAlias+'_DATPRO'),Subs(&('M->'+cAlias+'_LOCATE'),1,3),"","")
	
	if ! aRetFun[1]
		lRet := .f.
		if len(aRetFun) >= 2
			PLSMOVCRI("3",{},aRetFun[2])
		endIf
	endIf
endIf

return(lRet)

/*/{Protheus.doc} PLSVLESBD5
Validacao da especialidade
@type function
@author PLSTEAM
@since 13.05.05
@version 1.0
/*/
function PLSVLESBD5()
local aRetFun
local lRet := .t.
local nX
local nCodRDABD7 := ""

if ! empty(M->BD5_CODESP)
	
	aRetFun := PLSVDESPRD(M->BD5_CODRDA,M->BD5_OPERDA,Subs(M->BD5_LOCATE,1,3),M->BD5_CODESP,M->BD5_DATPRO,"","")
	
	if ! aRetFun[1]
		lRet := .f.
		Help("",1,"PLSA090ESP")
	endIf
endIf

//-------------------------------------------------
// Atualizando os campos de especialidade dos Eventos.
//-------------------------------------------------
if Type("oBrwBD6") <> "U" .and. Type("oBrwBD7") <> "U" .and. lRet
	
	nCodBD6 := Ascan(oBrwBD6:aHeader,{|X| allTrim(X[2]) == "BD6_CODESP"})
	nCodBD7	:= Ascan(oBrwBD7:aHeader,{|X| allTrim(X[2]) == "BD7_CODESP"})
	nEspBD7	:= Ascan(oBrwBD7:aHeader,{|X| allTrim(X[2]) == "BD7_DESESP"})
	nCodRDABD7	:= Ascan(oBrwBD7:aHeader, {|X| allTrim(X[2]) == "BD7_CODRDA"})
	
	if len(oBrwBD6:aCols) > 0 .and. nCodBD6 > 0
		for nX:= 1 to len(oBrwBD6:aCols)
			oBrwBD6:aCols[nX,nCodBD6] := iIf( !(empty(M->BD5_CODESP)) ,M->BD5_CODESP,Space(TamSX3("BD6_CODESP")[1]))
		next
		oBrwBD6:ForceRefresh()
		oBrwBD6:lAltered := .t.
	endIf
	
	if len(oBrwBD7:aCols) > 0 .and. (nCodBD7 > 0 .and. nEspBD7 > 0)
		for nX:= 1 to len(oBrwBD7:aCols)
			if allTrim(oBrwBD7:aCols[nX,nCodRDABD7]) == allTrim(M->BD5_CODRDA)
				oBrwBD7:aCols[nX,nCodBD7] := iIf(!(empty(M->BD5_CODESP)),M->BD5_CODESP,Space(TamSX3("BD7_CODESP")[1]))
				oBrwBD7:aCols[nX,nEspBD7] := iIf(!(empty(M->BD5_CODESP)),Posicione("BAQ",1,xFilial("BAQ")+BAX->BAX_CODINT+M->BD5_CODESP,"BAQ_DESCRI"),Space(TamSX3("BD7_DESESP")[1]))
			endIf
		next
		oBrwBD7:ForceRefresh()
		oBrwBD7:lAltered := .t.
	endIf
	
elseIf BD5->BD5_TIPGUI == "01" .and. !INCLUI //Na guia de consulta ele não tem (ou pode não ter) o objeto, então fazemos na mão. Solução passível de falha em caso de Alterar e cancelar, ajustar futuramente
	if M->BD5_CODESP <> BD5->BD5_CODESP
		BD6->(recLock("BD6", .f.))
		BD6->BD6_CODESP := M->BD5_CODESP
		BD6->BD6_DATPRO := M->BD5_DATPRO
		BD6->(msUnLock())
	endIf
endIf

return(lRet)

/*/{Protheus.doc} PLSA720VND
Tratamento de conversão de unidades
@type function
@author PLSTEAM
@since 12.03.04
@version 1.0
/*/
function PLSA720VND(cCodUnd)
local aConversao := {}
local nPos

//-------------------------------------------------
//Tratamento de conversão
//-------------------------------------------------
aConversao := { {"AUX","AUR"} , {"COP","COR"} , {"HM ","HMR"} , {"PA ","PAR"} , {"HM ","REA"}, {"HM ","PPM"}, {"FIL","FIL"},{"PA ","PAP"},{"PPM","REA"},{"DOP","DOP"},{"UCO","UCO"}  }

nPos := Ascan(aConversao,{|x| allTrim(x[2]) == allTrim(cCodUnd) })

if nPos > 0
	cCodUnd := aConversao[nPos,1]
else
	nPos := Ascan(aConversao,{|x| allTrim(x[1]) == allTrim(cCodUnd) })
	
	if nPos > 0
		cCodUnd := aConversao[nPos,2]
	else

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0090+cCodUnd+STR0091 , 0, 0, {})//"Nao foi possivel converter a unidade "###" favor entrar em contato com o Desenvolvimento."
		
	endIf
endIf

return(cCodUnd)

/*/{Protheus.doc} PLSA720BOT
Exibe botoes para o tipo de guia consulta. Executado via BCL_FUNBOT no layout configurador PLS contas medicas
@type function
@author PLSTEAM
@since 25.08.05
@version 1.0
/*/
function PLSA720Bot()
local aButtons := {}

if type('inclui') == "L" .and. ! Inclui
	aadd(aButtons,{"RELATORIO",{ || PLS720VITE("BD6",K_Visualizar)  },STR0092}) //"Visualiza dados do evento"
	aadd(aButtons,{"RELATORIO",{ || PLS720VITE("BD7",K_Visualizar)  },STR0093}) //"Visualiza dados da participacao do servico"
endIf

return(aButtons)

/*/{Protheus.doc} PLS720VITE
Visualiza dados do BD6/BD7 de uma guia de consulta
@type function
@author PLSTEAM
@since 25.08.05
@version 1.0
/*/
function PLS720VITE(cAlias,nOpc)
local cChave     := xFilial(cAlias)+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)
local oDlg		 := nil
local oBrwBrowse := nil
local nFor		 := 0
local nAux		 := 0
local aCfgLay    := {}
local bOk        := { || oDlg:End() }
local aCampos    := {}
local aHeader    := {}
local aCols      := {}
local aVetTrab   := {}
local aButton	 := {}

default nOpc := K_Alterar

(cAlias)->(dbSetOrder(1))

if (cAlias)->(msSeek(cChave))
	
	aCfgLay := PLSA500FIL(PLSINTPAD(),"02","1")
	
	for nFor := 1 To len(aCfgLay)
		if aCfgLay[nFor,1] == cAlias
			aCampos := aCfgLay[nFor,4]
		endIf
	next
	
	SX3->(dbSetOrder(2))
	for nAux := 1 To len(aCampos)
		
		SX3->(msSeek(aCampos[nAux]))
		
		if PLSCHKNIV(.t.)
			
			aadd(aHeader,{	X3TITULO(),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,;
							SX3->X3_ARQUIVO,SX3->X3_CONTEXT})
		endIf
		
	next
	
	Store COLS cAlias TO aCols FROM aHeader VETTRAB aVetTrab while cChave == xFilial(cAlias)+&(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODLDP")+&(cAlias+"->"+cAlias+"_CODPEG")+&(cAlias+"->"+cAlias+"_NUMERO")+&(cAlias+"->"+cAlias+"_ORIMOV")
	
	DEFINE MSDIALOG oDlg TITLE PLSRetTit(cAlias) FROM 008.0,010.3 TO 034.4,100.3
	
	oBrwBrowse := TPLSBrw():New(030,005,350,195,nil,oDlg,nil,,nil,nil,nil,.t.,nil,.t.,nil,aHeader,aCols,.f.,cAlias,nOpc,PLSRetTit(cAlias),nil,nil,nil,aVetTrab,nil,nil,,,,,,,,,,.t.)
	
	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bOK,.f.)
	
	if nOpc == K_Alterar
		
		if cAlias == "BD6"
			
			if BD6->(msSeek(cChave)) .and. BD6->BD6_QUACOB  <> oBrwBrowse:fieldGet("BD6_QUACOB",1)
				oBrwBrowse:fieldPut("BD6_QUACOB",BD6->BD6_QUACOB)
			endIf
			
		endIf
		
		oBrwBrowse:Grava()
	endIf
	
else
	MsgStop(STR0094)    //"Nao foi encontrado o evento desta guia"
endIf

return

/*/{Protheus.doc} LimSEQPFGU
Limpa SEQPF das guias
@type function
@author PLSTEAM
@since 25.08.05
@version 1.0
/*/
static function LimSEQPFGU(cAlias)
local lReapre := iif(lUnimed,PlVerReap(BCI->BCI_CODOPE,RIGHT(BCI->BCI_LOTEDI,8)),.f.) //Verifica se é uma reapresentação

if !lReapre 
	(cAlias)->(recLock(cAlias,.f.))
		&(cAlias+"->"+cAlias+"_SEQPF") := ""
	(cAlias)->(msUnLock())

	BD6->(dbSetOrder(1))
	if BD6->(msSeek(xFilial("BD6")+BCI->(BCI_CODOPE+BCI_CODLDP+BCI->BCI_CODPEG+&(cAlias+"->"+cAlias+"_NUMERO")+&(cAlias+"->"+cAlias+"_ORIMOV"))))

		while ! BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial("BD6")+BCI->(BCI_CODOPE+BCI_CODLDP+BCI->BCI_CODPEG+&(cAlias+"->"+cAlias+"_NUMERO")+&(cAlias+"->"+cAlias+"_ORIMOV"))
			
			BD6->(recLock("BD6",.f.))
				BD6->BD6_SEQPF := ""
			BD6->(msUnLock())
			
			BD6->(dbSkip())
		endDo

	endIf
endif
return

/*/{Protheus.doc} PLS720GGL
@type function
@author PLSTEAM
@since 13.10.05
@version 1.0
/*/
function PLS720GGL(cTipo)
local nRet       := 0
local nOrdBDX    := BDX->(indexOrd())
local nOrdBD7    := BD7->(indexOrd())
local lGloValor  := .f.
local nPerGloVlr := 0
local nVlrGloVlr := 0
local nVlrManTot := 0

//plsa500 nao atualizado, sair por seguranca... retirar apos um periodo
if Type('cChaveACT') <> "C" 
	
	if cTipo == "1"
		nRet := 100
	else
		nRet := M->BDX_VLRMAN
	endIf
	
	return(nRet)
	
endIf

BDX->(dbSetOrder(1))
if BDX->(msSeek(xFilial("BDX")+cChaveACT+M->BDX_CODPAD+M->BDX_CODPRO+M->BDX_SEQUEN))
	
	while ! BDX->(eof()) .and. BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN) == xFilial("BDX")+cChaveACT+M->BDX_CODPAD+M->BDX_CODPRO+M->BDX_SEQUEN
		
		if BDX->BDX_CODGLO == __aCdCri049[1]
			lGloValor := .t.
			exit
		endIf
		
	BDX->(dbSkip())
	endDo
	
endIf

if lGloValor

	plTRBBD7("TRBBD7", subStr(cChaveACT,1,4), subStr(cChaveACT,5,4), subStr(cChaveACT,9,8), subStr(cChaveACT,17,8), subStr(cChaveACT,25,1), M->BDX_SEQUEN)
	
	while ! TRBBD7->(eof())
	
		BD7->( dbGoTo( TRBBD7->REC ) )
		
			nVlrManTot += BD7->BD7_VLRMAN
			nVlrGloVlr += BD7->BD7_VLRGLO
		
	TRBBD7->(dbSkip())
	endDo
	
	TRBBD7->(dbCloseArea())
	
	nPerGloVlr := (nVlrGloVlr / nVlrManTot) * 100
	
endIf

if cTipo == "1"

	if ! lGloValor
		nRet := 100
	else
		nRet := nPerGloVlr
	endIf
	
else

	if ! lGloValor
		nRet := M->BDX_VLRMAN
	else
		nRet := nVlrGloVlr
	endIf
	
endIf

BDX->(dbSetOrder(nOrdBDX))
BDX->(dbGoto(nOrdBDX))

BD7->(dbSetOrder(nOrdBD7))
BD7->(dbGoto(nOrdBD7))

return(nRet)

/*/{Protheus.doc} PLS720ZCB
Limpa a composicao de cobranca de uma guia
@type function
@author PLSTEAM
@since 13.10.05
@version 1.0
/*/
function PLS720ZCB(cTipo,cChaveGui,cAlias,lPosBD6)
local aAreaBD6		:= BD6->(getArea())
local lDoppler		:= .f.
local lChkDopp		:= getNewPar('MV_PLCKDOP','0') == '1'
local cTipoGuia		:= &(cAlias+"->"+cAlias+"_TIPGUI")
local isPLSA502		:= isInCallStack("PLSA502")
Local lBD6OkGo		:= .F.
local lP500RCB		:= isInCallStack("PLSA500RCB")
local lP500RCP		:= IsInCallStack("PLSA500RCP")

local lBD6_VLTXPG	:= BD6->(fieldPos("BD6_VLTXPG")) > 0
local lBD7_VLTXPG	:= BD7->(fieldPos("BD7_VLTXPG")) > 0
local lBD7_PRTXPG	:= BD7->(fieldPos("BD7_PRTXPG")) > 0

default lPosBD6	:= .f.

if BCL->BCL_TIPGUI <> cTipoGuia

	BCL->( dbSetOrder(1) )
	BCL->( msSeek(xFilial("BCL")+PLSINTPAD()+cTipoGuia) )

	if ! BCL->( Found() )

		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "SIGAPLS - "+STR0095+" ["+cChaveGui+"]" , 0, 0, {})//"TipoGuia invalido Chave"
		
	endIf
	
endIf

if isPLSA502
	cChaveGui := Substr(cChaveGui, 1, Len(cChaveGui) - 3)
endIf

BD6->( dbSetOrder(1) ) //BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO

If lPosBD6
	lBD6OkGo 	:= .T.
else
	lBD6OkGo := BD6->( msSeek(xFilial("BD6")+cChaveGui) )
EndIf

if lBD6OkGo
	
	while ! BD6->( eof() ) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial("BD6") + cChaveGui
		
		if lChkDopp
			lDoppler := procDop(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODTAB)
		endIf
		
		if lDoppler .and. cTipo <> "3"
			BD6->(dbSkip())
			loop
		endIf
		
		BD6->(recLock("BD6",.f.))
		
		//Pagamento ou ambos...
		if cTipo $ "2,3" 
		
			BD6->BD6_VLRPAG := 0
			BD6->BD6_VLRMAN := 0
			BD6->BD6_VLRGLO := 0
			BD6->BD6_VLRBPR := 0
			BD6->BD6_PERHES := 0
			
			if lBD6_VLTXPG
				BD6->BD6_VLTXPG := 0
			endIf
			
		endIf
		
		//Cobranca ou ambos...
		if cTipo $ "1,3" 
		
			BD6->BD6_ALIAPF := ""
			BD6->BD6_CNTCOP := ""
			BD6->BD6_TPPF   := ""
			BD6->BD6_CDTBRC := ""

			//Revalorizar Cobranca ou Ambos
			if ( lP500RCB .or. lP500RCP ) .and. BD6->BD6_PAGRDA == "1" 
				BD6->BD6_BLOCPA := ""
				BD6->BD6_MOTBPF := ""
				BD6->BD6_DESBPF := ""
				BD6->BD6_PAGRDA := ""
			endIf
			
			BD6->BD6_CONSFR := "0"
			BD6->BD6_VLRTAD := 0
			BD6->BD6_VLRPF  := 0
			BD6->BD6_VLRBPF := 0
			BD6->BD6_PERTAD := 0
			BD6->BD6_VLRTPF := 0
			BD6->BD6_PERCOP := 0
			BD6->BD6_VRPRDA := 0
			BD6->BD6_F_VLPF := 0
			BD6->BD6_F_VLOR := 0
			BD6->BD6_F_VFRA := 0
			BD6->BD6_F_PPER := 0
			BD6->BD6_F_TXOR := 0
			BD6->BD6_F_TOOR := 0
			BD6->BD6_F_POTX := 0
			
		endIf
		BD6->(msUnLock())
		
		plTRBBD7("TRBBD7", subStr(cChaveGui,1,4), subStr(cChaveGui,5,4), subStr(cChaveGui,9,8), subStr(cChaveGui,17,8), subStr(cChaveGui,25,1),  BD6->BD6_SEQUEN)
	
		while ! TRBBD7->(eof())
		
			BD7->( dbGoTo( TRBBD7->REC ) )
			
			if ! lDoppler
					
				BD7->(recLock("BD7",.f.))
				
				//Pagamento ou ambos...
				if cTipo $ "2,3" 
				
					BD7->BD7_VLRPAG := 0
					BD7->BD7_VLRMAN := 0
					BD7->BD7_VLRBPR := 0
					BD7->BD7_VLRGLO := 0
					BD7->BD7_COEFUT := 0
					BD7->BD7_PERCEN := 0
					BD7->BD7_PERHES := 0
					BD7->BD7_ALIAUS := ""
					BD7->BD7_DESERR := ""
					
					if lBD7_VLTXPG
						BD7->BD7_VLTXPG := 0
					endIf
					
					BD7->BD7_VTXPCT := 0
					
					if lBD7_PRTXPG
						BD7->BD7_PRTXPG := 0
					endIf
					
				endIf
				
				//Cobranca ou ambos...
				if cTipo $ "1,3" 
				
					BD7->BD7_TPCOPF := ""
					BD7->BD7_ALIPF  := ""
					BD7->BD7_DESCRI := ""
					BD7->BD7_CODUNC := ""
					BD7->BD7_VLRTPF := 0
					BD7->BD7_COEFPF := 0
					BD7->BD7_PERPF  := 0
					BD7->BD7_PRCHES := 0
					BD7->BD7_FTMTPF := 0
					BD7->BD7_VLRTAD := 0
					BD7->BD7_RFTDEC := 0
					BD7->BD7_VLRBPF := 0
					
				endIf
				
				BD7->(msUnLock())
				
			else
				BD7->(recLock("BD7",.f.))
					BD7->(DbDelete())
				BD7->(msUnLock())
			endIf
			
		TRBBD7->(dbSkip())
		endDo
		
		TRBBD7->(dbCloseArea())
		
		if lDoppler
			
			PLS720IBD7( (cAlias)->&( cAlias + "_PACOTE" ), BD6->BD6_VLPGMA, BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODTAB,BD6->BD6_CODOPE,BD6->BD6_CODRDA,;
						BD6->BD6_REGEXE,BD6->BD6_SIGEXE,BD6->BD6_ESTEXE,BD6->BD6_CDPFRE,BD6->BD6_CODESP,BD6->(BD6_CODLOC+BD6_LOCAL),"1",BD6->BD6_SEQUEN,;
						BD6->BD6_ORIMOV,BCL->BCL_TIPGUI,BD6->BD6_DATPRO)
		endIf
		
		//tratamento para fazer somente para o registro que esta posicionado
		if lPosBD6 .or. isPLSA502
			exit
		endIf
		
	BD6->(dbSkip())
	endDo
	
endIf

BD6->(restArea(aAreaBD6))

return

/*/{Protheus.doc} ProcDop
Indica se o procedimento eh do tipo doppler
@type function
@author PLSTEAM
@since 13.10.05
@version 1.0
/*/
function ProcDop(cCodPad,cCodPro,cCodTab)
local lRet    := .f.
local nOrdBD4 := BD4->(indexOrd())
local nRecBD4 := BD4->(recno())

if ! empty(cCodTab)
	BD4->(dbSetOrder(1)) //BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO+BD4_CODIGO+DTOS(BD4_VIGINI)
	lRet :=  BD4->( msSeek(xFilial("BD4") + PLSINTPAD() + cCodTab + cCodPad + cCodPro + "DOP" ) )
endIf

if !lRet .and. !empty(BD6->BD6_PROREL)

	aCodTab := PLSRETTAB(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_DATPRO,;
						BD6->BD6_CODOPE,BD6->BD6_CODRDA,BD6->BD6_CODESP,BD6->BD6_SUBESP,BD6->(BD6_CODLOC+BD6_LOCAL),;
						BD6->BD6_DATPRO,"1",BD6->BD6_OPEORI,BD6->BD6_CODPLA,"1","1",nil,nil,nil,nil,(BD6->BD6_TIPGUI==G_REEMBOLSO),;
						nil,nil,nil,nil,nil,nil,nil,BD6->BD6_CODEMP,BD6->BD6_ANOPAG,BD6->BD6_MESPAG)
	if aCodTab[1]
		lRet :=  BD4->( msSeek( xFilial("BD4") + PLSINTPAD() + aCodTab[3] + cCodPad + cCodPro + "DOP" ))
	endIf
	
endIf

BD4->(dbGoto(nRecBD4))
BD4->(dbSetOrder(nOrdBD4))

return(lRet)

/*/{Protheus.doc} PLSA720UND
Indica as unidades equivalentes em tabelas diferentes
@type function
@author PLSTEAM
@since 03.07.05
@version 1.0
/*/
function PLSA720UND(cCodUnd, lAddIni)
local aConversao := {}
local aRet 		 := {}
local nFor		 := 0

Default lAddIni := .F.

aConversao := { {"AUX","AUR"}, {"COP","COR"}, {"COP","UCO"}, {"HM ","HMR"}, {"PA ","PAR"}, {"HM ","REA"},;
				{"HM ","PPM"}, {"FIL","FIL"}, {"PA ","PAP"}, {"PPM","REA"}, {"PPM","HMR"} }

// PL720AUND permite o usuario manipular/adicionar novos De-Paras entre participacoes
if existBlock("PL720AUND")
	aConversao := execBlock("PL720AUND",.f.,.f., { aConversao } )
endIf

for nFor := 1 to len(aConversao)

	if allTrim(aConversao[nFor,1]) == allTrim(cCodUnd)
		aadd(aRet,aConversao[nFor,2])
	endIf
	
	if allTrim(aConversao[nFor,2]) == allTrim(cCodUnd)
		aadd(aRet,aConversao[nFor,1])
	endIf
	
next

If lAddIni .AND. Len(aRet) > 0
	aadd(aret, cCodUnd)
endIf

return(aRet)

/*/{Protheus.doc} PLCrProGen
Dada uma guia crio o proc generico nela. E necessario que o PLDADUSR foi carregado
@type function
@author PLSTEAM
@since 03.07.05
@version 1.0
/*/
function PLCrProGen(aChaUlGu,cCodPro,cAuxDat,cSequen,nVia,nRgGrImp,cLote,cNota,lConverProc,cUniOri)
local cAlias    := ""
local cChave    := ""
local nForCpo   := 1
local cMacro    := ""
local cCampoOri := ""
local aCposPad  := {}
local dDataPro  := stod("")
local aCodTab   := {}
local lAjusBR8  := .f.
local aCpoNiv   := {}
local nFor		:= 1
local aDadUsr   := PLSGETUSR()
local cCodPla   := if(len(aDadUsr)>=11,aDadUsr[11],BA3->BA3_CODPLA)

default cCodPro := ""
default cAuxDat := ""
default cSequen := ""
default nVia    := 1
default nRgGrImp:= 1
default cLote   := ""
default cNota   := ""
default lConverProc := .f.
default cUniOri := PlsIntPad()

if ! empty(cAuxDat)
	dDataPro := ctod(subs(cAuxDat,9,2)+"/"+subs(cAuxDat,6,2)+"/"+subs(cAuxDat,1,4))
endIf

if len(aChaUlGu) >= 2
	
	lAjusBR8 := PLBusProTab(cCodPro,.t.,cAuxDat,dDataPro,lConverProc,cUniOri)
	
	cAlias   := aChaUlGu[1]
	cChave   := aChaUlGu[2]
	
	aCposPad := eval( { || (cAlias)->(DbStruct()) })
	
	(cAlias)->(dbSetOrder(1))
	(cAlias)->(msSeek(xFilial(cAlias)+cChave))
	
	aCpoNiv := PLSUpCpoNv(BR8->BR8_CODPAD,BR8->BR8_CODPSA,"BD6")
	
	for nFor := 1 To len(aCpoNiv)
		&(aCpoNiv[nFor,1]) := (aCpoNiv[nFor,2])
	next
	
	BD6->(recLock("BD6",.t.))
	
	for nForCpo := 1 To len(aCposPad)
		cMacro := ("BD6->BD6_"+Subs(aCposPad[nForCpo,1],5,10))
		if TYPE(cMacro) <> "U"
			cCampoOri := cAlias+"->"+cAlias+"_"+Subs(aCposPad[nForCpo,1],5,10)
			&(cMacro) := &(cCampoOri)
		endIf
	next
	
	BD6->BD6_FILIAL := xFilial("BD6")
	BD6->BD6_CODPLA := cCodPla
	BD6->BD6_TPGRV  := "4"
	BD6->BD6_CODPAD := BR8->BR8_CODPAD
	BD6->BD6_CODPRO := BR8->BR8_CODPSA
	BD6->BD6_DESPRO := BR8->BR8_DESCRI
	BD6->BD6_ORIMOV := &(cAlias+"->"+cAlias+"_ORIMOV")
	BD6->BD6_NIVEL  := BR8->BR8_NIVEL
	BD6->BD6_STATUS := "1"
	
	BD6->BD6_MODCOB := aDadUsr[48]
	BD6->BD6_TIPUSR := iIf( len(aDadUsr) >= 90, aDadUsr[90], "")
	BD6->BD6_INTERC := iIf( len(aDadUsr) >= 91, aDadUsr[91], "0")
	BD6->BD6_TIPINT := aDadUsr[43]
	
	BD6->BD6_OPEORI := BA1->BA1_OPEORI
	BD6->BD6_CHVNIV := ""
	BD6->BD6_NIVAUT := ""
	BD6->BD6_SEQIMP := cSequen
	BD6->BD6_SEQUEN := "001" //sempre soh tem 1 proc
	
	PLSPOSGLO(PLSINTPAD(),__aCdCri222[1],__aCdCri222[2])
	PLBLOPC('BD6', .t., __aCdCri222[1], PLSBCTDESC(), .t., .f.)
	
	aCodTab := PLSRETTAB(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_DATPRO,;
						 BD6->BD6_CODOPE,BD6->BD6_CODRDA,BD6->BD6_CODESP,BD6->BD6_SUBESP,BD6->(BD6_CODLOC+BD6_LOCAL),;
						 BD6->BD6_DATPRO,"1",BD6->BD6_OPEORI,BD6->BD6_CODPLA,"1","1",nil,IIF( ! Empty(BAU->BAU_TIPPRE),BAU->BAU_TIPPRE,nil),nil,nil,(BD6->BD6_TIPGUI==G_REEMBOLSO),;
						 nil,nil,nil,nil,nil,nil,nil,BD6->BD6_CODEMP,BD6->BD6_ANOPAG,BD6->BD6_MESPAG)
	
	if aCodTab[1]
		BD6->BD6_CODTAB := aCodTab[3]
		BD6->BD6_ALIATB := aCodTab[4]
	endIf
	
	BD6->BD6_DATPRO := dDataPro
	BD6->BD6_VIA    := strZero(Val(nVia),1)
	
	if BD6->BD6_VIA >= "1"
		
		BGR->(dbSetOrder(2))
		if BGR->(msSeek(xFilial("BGR")+PLSINTPAD()+BD6->BD6_VIA))
		
			BD6->BD6_PROCCI := "1" //Somente pelo fato de vir como via de acesso
			BD6->BD6_PERVIA := BGR->BGR_PERC
		
		else
		
			BGR->(dbSetOrder(1))
			if BGR->(msSeek(xFilial("BGR")+PLSINTPAD()+BD6->BD6_VIA))
				BD6->BD6_PROCCI := "1" //Somente pelo fato de vir como via de acesso
				BD6->BD6_PERVIA := BGR->BGR_PERC
			endIf
		
		endIf
		
	endIf
	
	if lAjusBR8
		BD6->BD6_CODERR := cCodPro
	endIf
	
	if nRgGrImp == 1
		BD6->BD6_NUMIMP := Subs(cLote,4,5)+cNota
	elseIf nRgGrImp == 2
		BD6->BD6_NUMIMP := cNota
	elseIf nRgGrImp == 3
		BD6->BD6_NUMIMP := cUniOri+cNota
	endIf
	
	BD6->(msUnLock())
	
	PLS720IBD7(&(cAlias+"->"+cAlias+"_PACOTE"),BD6->BD6_VLPGMA,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODTAB,BD6->BD6_CODOPE,BD6->BD6_CODRDA,;
				BD6->BD6_REGEXE,BD6->BD6_SIGEXE,BD6->BD6_ESTEXE,BD6->BD6_CDPFRE,BD6->BD6_CODESP,BD6->(BD6_CODLOC+BD6_LOCAL),"1",BD6->BD6_SEQUEN,;
				&(cAlias+"->"+cAlias+"_ORIMOV"),BD6->BD6_TIPGUI,BD6->BD6_DATPRO,nil,nil,"1")
	
endIf

return

/*/{Protheus.doc} PLBusProTab
@type function
@author PLSTEAM
@since 01.06.05
@version 1.0
/*/
function PLBusProTab(cCodSer,lChkGen,cAuxDat,dDatPro,lConverProc,cUniOri,cCodProGen,cCodPadCon,cCodPad)
local lAjusBR8      := .f.
local lFoundBR8     := .f.
local lFindDePa     := .f.

default cAuxDat     := ""  //PLSA500GCF("R504","DT_SERVICO")
default dDatPro     := stod(cAuxDat)
default lConverProc := .f.
default cCodPadCon  := ""
default cUniOri     := PlsIntPad()
default cCodSer     := ""
default cCodProGen  := cCodSer
default cCodPad	  := ""

if valType(cCodPadCon) <> "C"
	cCodPadCon := ""
endIf

if valType(cCodSer) <> "C"
	cCodSer := ""
endIf

//lConverProc  se converte ou nao...
if lConverProc
	BW0->(dbSetOrder(1))
	if BW0->(msSeek(xFilial("BW0")+cCodPadCon+cCodSer))
		cCodSer := Subs(allTrim(BW0->BW0_CODPR2),1,8)
	else
		SIX->(dbSetOrder(1))
		if SIX->(msSeek("BW02"))
			BW0->(dbSetOrder(2))
			if BW0->(msSeek(xFilial("BW0")+cCodPadCon+cCodSer))
				cCodSer := Subs(allTrim(BW0->BW0_CODPR1),1,8)
			endIf
		else

			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "SIGAPLS - "+STR0096 , 0, 0, {})//"Favor entrar em contato com o suporte para criar indice 2 do arquivo BW0."
			
		endIf
	endIf
endIf

//Ponto de Entrada para troca do Procedimento
if existBlock("PLS500PSA")
	cCodSer := execBlock("PLS500PSA",.f.,.f.,{cCodSer,cUniOri,dDatPro,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)})
endIf

if !empty(cCodPad)
	BR8->(dbSetOrder(1))
	lFoundBR8 := BR8->(msSeek(xFilial("BR8")+cCodPad+cCodSer))
endIf

if ! lFoundBR8
	BR8->(dbSetOrder(3))
	lFoundBR8 := BR8->(msSeek(xFilial("BR8")+cCodSer))
endIf

if ! lFoundBR8
	//-------------------------------------------------
	// Implementada opcao de vigencias para o De/Para Intercambio
	//-------------------------------------------------
	PLDeParINT(cCodPad,cCodSer,dDatPro,@lFindDePa,"R")
	if lFindDePa
		BR8->(dbSetOrder(1))
		lFoundBR8 := BR8->(msSeek(xFilial("BR8")+B1M->(B1M_CODPAD+B1M_CODPSA)))
	endIf

	if !lFoundBR8
		BR8->(dbSetOrder(5))
		lFoundBR8 := BR8->(msSeek(xFilial("BR8")+cCodSer))
	endIf
endIf

if ! lFoundBR8
	BR8->(dbSetOrder(3))
	lFoundBR8 := BR8->(msSeek(xFilial("BR8")+cCodSer))
endIf

if existBlock("PLS500PR")
	lFoundBR8 := execBlock("PLS500PR",.f.,.f.,{lFoundBR8,cCodSer})
endIf

if lChkGen .and. ! lFoundBR8
	lAjusBR8  := PlsBr8Gen(cCodProGen,.t.,cCodPad)[1]
endIf

return(lAjusBR8)

/*/{Protheus.doc} P720NewBDX
Remonta a glosa a partir de um BDX (Glosas)
@type function
@author PLSTEAM
@since 09.08.06
@version 1.0
/*/
function P720NewBDX(aCri, cAlias, lHelp)
local aArea			:= BD6->(getArea())
local aItensGlo 	:= {}
local cChaveProc	:= BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO+BD6_SEQUEN)
local cFase			:= (cAlias)->&( cAlias + "_FASE" )
local cTipo			:= RETORNAFASE
local cSequen		:= ''
local lFlag 		:= .t.
local lProcRev		:= .t.
local lGloAut		:= .f.
local lBDX_VLRGTX	:= BDX->( fieldPos("BDX_VLRGTX") ) > 0
local lBDX_VLTXPG 	:= BDX->( fieldPos("BDX_VLTXPG") ) > 0
Local lRevPgto	:= isInCallStack("PLSA500RPG") .OR. IsInCallStack("PLSA500RCP")

BCL->( dbSetOrder(1) )
BCL->( msSeek( xFilial("BCL") + BD6->(BD6_CODOPE+BD6_TIPGUI) ) )

BDX->(dbSetOrder(1))
if BDX->(msSeek( xFilial("BDX") + cChaveProc ) )

	while ! BDX->(eof()) .and. BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN) == xFilial("BDX") + cChaveProc
		
		lGloAut := .F.
		
		if BDX->BDX_CODGLO == __aCdCri049[1]
			lGloAut :=  BDX->BDX_TIPGLO == '3'
			cSequen :=  BDX->BDX_SEQUEN
		endIf	
		
		//verifica se e glosa de valor contratado e se e a mesma glosa existente
		if BDX->BDX_CODGLO == __aCdCri049[1] .and. aScan(aCri[2], {|x| x[1] == __aCdCri049[1]}) > 0
		 	
			if aCri[3] == BDX->BDX_VLRPAG .and. aCri[5] == BDX->BDX_VLRMAN .OR. GetNewPar("MV_PLREVGL", .F.)
				
				aCri[1] := .t.
				aCri[2] := {}
				aCri[3] := 0
				aCri[4] := 0
				aCri[5] := 0
				
			//neste ponto houve troca de valores ao revalorar e existe inconsistencia entre contratao e apresenado
			//vai retorna a fase da guia.	
			else
				
				cFase 	 := DIGITACAO
				lFlag 	 := .f.
				lProcRev := .f.
				
				exit
					
			endIf
			
		endIf
			
		if BDX->BDX_TIPREG == '1' .and. ! empty(BDX->BDX_ACAO) .and. (lRevPgto .OR. BDX->BDX_TIPGLO != '3')
		
			if lRevPgto .OR. aScan(aItensGlo,{|x| x[1] == BDX->BDX_SEQUEN .and. ( x[2] <> BDX->BDX_VLRMAN .or. x[3] <> BDX->BDX_VLRGLO ) }) == 0
				
				lFlag := .f.
				
				aadd(aItensGlo,{BDX->BDX_SEQUEN,;												//01
								BDX->BDX_VLRMAN,;												//02
								BDX->BDX_VLRGLO,;												//03
								BDX->BDX_ACAOTX,;						 						//04
								iIf(lBDX_VLRGTX, BDX->BDX_VLRGTX, 0),; 							//05
								BDX->BDX_TIPGLO,;												//06
								iIf(empty(BDX->BDX_ACAO), BDX->BDX_GLACAO, BDX->BDX_ACAO),;		//07
								iIf(empty(BDX->BDX_ACAO), "2", "1"),;							//08 
								BDX->BDX_CODTPA,; 												//09
								BDX->BDX_QTDGLO,; 	   											//10
								BDX->BDX_TIPREG,;												//11
								BDX->BDX_CODGLO,;												//12
								BDX->BDX_VLRPAG,;												//13
								BDX->BDX_PERGLO,;												//14
								iIf(lBDX_VLTXPG,BDX->BDX_VLTXPG,0),;							//15							
								lGloAut})														//16							
				
			else
				
				aadd(aCri[2],{__aCdCri032[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})
				aadd(aCri[2],{""   ,STR0097  ,"","","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Divergencia entre campos de valor de um mesmo BDX"
				aadd(aCri[2],{""   ,STR0098  ,"","","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO}) //"Exclua pelo menos um BDX divergente"
				aadd(aCri[2],{""   ,STR0099  ,"","","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})  //"Solicite uma atualizacao do PLSMCTMD,PLSA720 e PLSA500"
				
				lFlag := .t.
				exit
				
			endIf
			
		endIf	
		
	BDX->(dbSkip())
	endDo
	
	if ! lFlag
		PLSXMUDFAS(cAlias,cTipo,"",BCL->BCL_TIPGUI,ctod(""),.f.,cFase,nil,nil,.t.,aItensGlo,nil,nil,nil,nil,lProcRev,BD6->(recno()))
	endIf
	
endIf

BD6->(restArea(aArea))

return

/*/{Protheus.doc} PlMonQtPer
Monta a quantidade X percentual no BD6.
@type function
@author PLSTEAM
@since 29.04.06
@version 1.0
/*/
function PlMonQtPer(cCodSeq,cCodPad,cCodPro,nQtdPro,lMemory,cChaveGui,dDatPro,lValid,lAtend,oBrwPro,nPosBD6,cCodRda,cCodLoc)
local aAreaBD6		:= BD6->(getArea())
local aAreaBR8		:= BR8->(getArea())
local nQtdBD6 		:= 0
local nQtdBE2 		:= 0
local aNiveis 		:= PLSESPNIV(cCodPad)
local nNiveis 		:= (aNiveis[1])
local nForBD6       := 0
local cCodAuBD6 	:= ""
local cCodAuBE2 	:= ""
local cChaveBD6 	:= ""
local cChaveBE2 	:= ""
local cCodAux   	:= ""
local cChave    	:= ""
local nProQtd 		:= 1
local aBL0			:= {}
local nFor          := 0
local nI            := 0
local aRet 	  		:= {}
local nForBE2       := 0
local cIntPad      	:= PLSINTPAD()
local lRet         	:= .f.
local cPortePri    	:= "" //Porte Principal cCodPro
local cPorte       	:= "" //Porte do procedimento que está sendo comprarado
local lProcIgual   	:= .f.
local lSeqProcIgual	:= .f.
local cSeqPri      	:= ""
local nQtdPri      	:= 0
local cBusca       	:= ""
local cMacro       	:= ""
local cMacro1      	:= ""
local nForBD6Ate   	:= 0
local cAltPerc     	:= getNewPar("MV_PLALPER","0")
local lReembolso	:= (BD6->BD6_TIPGUI == G_REEMBOLSO)
local aVetTab      	:= {}
local cCodTab      	:= ""
default cChaveGui  	:= ""
default dDatPro    	:= stod("")
default lValid     	:= .f.
default lAtend     	:= .f.
default nPosBD6   	:= 0
default cCodRda     := ""
default cCodLoc     := ""

BR8->(dbSetOrder(1))
BR8->(msSeek(xFilial("BR8")+cCodPad+cCodPro))

if BR8->BR8_QTDPER == "1"
   
   aVetTab := PLSRETTAB(BR8->BR8_CODPAD,BR8->BR8_CODPSA,IIF(Empty(dDatPro),BD6->BD6_DATPRO,dDatPro),cIntPad,cCodRda,;
   						"","",cCodLoc,,,,,,,,IIF(!Empty(BAU->BAU_TIPPRE),BAU->BAU_TIPPRE,nil),,,lReembolso,;
   						nil,nil,nil,nil,nil,nil, nil,BD6->BD6_CODEMP,BD6->BD6_ANOPAG,BD6->BD6_MESPAG)

   lRet := aVetTab[1]
   
   if lRet
	  cCodTab := aVetTab[3]
   endIf
    
endIf

//pega o porte procedimento principal para comparar com todos os outros
//se retornar vazio o procedimento nao tem porte
cPortePri := PLRETPORTE(cCodPad,cCodPro,cIntPad,cCodTab,dDatPro)

if !SIX->(msSeek("BL03"))
	
	if  BR8->BR8_QTDPER == "1"
	
		BL0->(dbSetOrder(1))
		if BL0->(msSeek(xFilial("BL0")+cCodPad+cCodPro))
		
			while ! BL0->(eof()) .and. BL0->(BL0_FILIAL+BL0_CODPAD+BL0_CODPSA) == xFilial("BL0")+cCodPad+cCodPro
				
				if nQtdPro >= BL0->BL0_QTD
					cMacro := ("M->BD6_QTD"+allTrim(str(BL0->BL0_QTD)))
					&cMacro := BL0->BL0_QTD
					
					cMacro := ("M->BD6_PERC"+allTrim(str(BL0->BL0_QTD)))
					&cMacro := BL0->BL0_PERC
					
					BL0->(aadd(aRet,{BL0_TIPO,BL0_QTD,BL0_PERC}))
				endIf
			BL0->(dbSkip())
			endDo
			
		endIf
		
	endIf
	
elseIf BR8->BR8_QTDPER == "1"
	
	if lMemory .and. Type("oBrwBD6") <> "U"
		lBrw6DtPro := oBrwBD6:fieldPos("BD6_DATPRO") > 0
	endIf
	
	for nFor := 1 To nNiveis
		
		if nFor == 1
			cChave  := xFilial("BL0")+cCodPad+cCodPro
		else
			cCodAux := Subs(cCodPro,aNiveis[2,(nFor-1),1],aNiveis[2,(nFor-1),2])
			cCodAux := cCodAux+Space(len(BL0->BL0_CDNV01)-len(cCodAux))+aNiveis[2,(nFor-1),3]
			cChave  := xFilial("BL0")+cCodPad+cCodAux
		endIf
		
		BL0->(dbSetOrder(nFor))
		if BL0->(msSeek(cChave))
			
			if lMemory
			
				if ! lAtend
			
					if val(M->BD6_SEQUEN) >len(oBrwBD6:aCols) .and. !empty(cPortePri)
						nForBD6Ate := len(oBrwBD6:aCols)+1   // pega o da memoria
					else
						nForBD6Ate := len(oBrwBD6:aCols)
					endIf
					
					for nForBD6 := 1 to nForBD6Ate
						
						if nForBD6Ate <> 1
						
							if  empty(cPortePri) .OR. nForBD6 <> nForBD6Ate
							
								// se o campo QTDPER do BR8 nao estiver marcado como Sim
								if BR8->(msSeek(xFilial("BR8")+oBrwBD6:fieldGet("BD6_CODPAD",nForBD6)+oBrwBD6:fieldGet("BD6_CODPRO",nForBD6))) .and. BR8->BR8_QTDPER <> "1"
									loop
								endIf
								
							endIf
							
						endIf
						
						if !empty(cPortePri) .and. nForBD6 == nForBD6Ate
							
							lRet 	:= .f.
							aVetTab := PLSRETTAB(BD6->BD6_CODPAD,BD6->BD6_CODPRO,dDatPro,cIntPad,"","","","",,,,,,,,;
												IIF(!Empty(BAU->BAU_TIPPRE),BAU->BAU_TIPPRE,nil),,,lReembolso,nil,nil,nil,;
												nil,nil,nil, nil,BD6->BD6_CODEMP,BD6->BD6_ANOPAG,BD6->BD6_MESPAG)
							
							lRet := aVetTab[1]
							
							if lRet
								cCodTab   := aVetTab[3]
							endIf
							
							cPorte := PLRETPORTE(M->BD6_CODPAD,M->BD6_CODPRO,cIntPad,cCodTab,dDatPro)
							
							if nFor == 1
								cChaveBD6 := xFilial("BD6")+ M->BD6_CODPAD+M->BD6_CODPRO
							else
								cCodAuBD6 := Subs(M->BD6_CODPRO,aNiveis[2,(nFor-1),1],aNiveis[2,(nFor-1),2])
								cCodAuBD6 := cCodAuBD6+Space(len(BL0->BL0_CDNV01)-len(cCodAuBD6))+aNiveis[2,(nFor-1),3]
								cChaveBD6 := xFilial("BD6")+M->BD6_CODPAD+cCodAuBD6
							endIf
							
							//Quando for comparar com o conteudo da memoria
							if cChave + dtos(dDatPro) == cChaveBD6+dtos(M->BD6_DATPRO)
								
								if !empty(cPortePri) .and. !empty(cPorte)
									
									if cPortePri <= cPorte
										
										if cCodPad+cCodPro+cCodSeq == M->(BD6_CODPAD+BD6_CODPRO+BD6_SEQUEN)

											lSeqProcIgual  	:= .t.
											cSeqPri 		:= M->BD6_SEQUEN
											nQtdPri 		:= M->BD6_QTDPRO
											
										else
											
											// se existir outro procedimento igual, mas sequencia diferente
											if cCodPad+cCodPro = M->(BD6_CODPAD+BD6_CODPRO)
											
												lProcIgual:= .t.
												
												if cCodSeq > M->BD6_SEQUEN
	
													nQtdBD6 += M->BD6_QTDPRO

												endIf
											else

												nQtdBD6 += M->BD6_QTDPRO
											
											endIf
										endIf
										
									endIf
									
								else
									
									if cCodSeq > M->BD6_SEQUEN
										
										nQtdBD6 += M->BD6_QTDPRO
									
									endIf
									
								endIf
								
							endIf
							
						else
							
							//se o procedimento principal tem porte, pega o porte do procedimento a comparar
							if ! empty(cPortePri)
								
								lRet 	:= .f.
								aVetTab := PLSRETTAB(oBrwBD6:fieldGet("BD6_CODPAD",nForBD6),oBrwBD6:fieldGet("BD6_CODPRO",nForBD6),;
														dDatPro,cIntPad,"","","","",,,,,,,,,,,lReembolso)
								lRet 	:= aVetTab[1]
								
								if lRet
									cCodTab   := aVetTab[3]
								endIf
								
								cPorte := PLRETPORTE(oBrwBD6:fieldGet("BD6_CODPAD",nForBD6),oBrwBD6:fieldGet("BD6_CODPRO",nForBD6),cIntPad,cCodTab,dDatPro)
								
							endIf
							
							if nFor == 1
								cChaveBD6 := xFilial("BD6")+oBrwBD6:fieldGet("BD6_CODPAD",nForBD6)+oBrwBD6:fieldGet("BD6_CODPRO",nForBD6)
							else
								cCodAuBD6 := Subs(oBrwBD6:fieldGet("BD6_CODPRO",nForBD6),aNiveis[2,(nFor-1),1],aNiveis[2,(nFor-1),2])
								cCodAuBD6 := cCodAuBD6+Space(len(BL0->BL0_CDNV01)-len(cCodAuBD6))+aNiveis[2,(nFor-1),3]
								cChaveBD6 := xFilial("BD6")+oBrwBD6:fieldGet("BD6_CODPAD",nForBD6)+cCodAuBD6
							endIf
							
							if lBrw6DtPro
							
								if cChave+dtos(dDatPro) == cChaveBD6+dtos(oBrwBD6:fieldGet("BD6_DATPRO",nForBD6)) .and. !oBrwBD6:IsDeleted(nForBD6)
									
									// verifica se irá usar regra de Porte ( maior porte )
									// se o principal e o que irá comparar tem porte, usar regra
									if !empty(cPortePri) .and. !empty(cPorte)
										
										//compara os portes dos procedimentos
										if cPortePri <= cPorte
											
											// sempre tera pelo menos um procedimento e sequencias iguais, pois ele compara com ele mesmo
											if cCodPad+cCodPro+cCodSeq == oBrwBD6:fieldGet("BD6_CODPAD",nForBD6)+oBrwBD6:fieldGet("BD6_CODPRO",nForBD6)+oBrwBD6:fieldGet("BD6_SEQUEN",nForBD6)
												
												lSeqProcIgual  	:= .t.
												cSeqPri 		:= oBrwBD6:fieldGet("BD6_SEQUEN",nForBD6)
												
												nQtdPri += oBrwBD6:fieldGet("BD6_QTDPRO",nForBD6)
												
											else
												// se existir outro procedimento igual, mas sequencia diferente
												if cCodPad+cCodPro == oBrwBD6:fieldGet("BD6_CODPAD",nForBD6)+oBrwBD6:fieldGet("BD6_CODPRO",nForBD6)
												
													lProcIgual:= .t.
												
													if cCodSeq >= oBrwBD6:fieldGet("BD6_SEQUEN",nForBD6)
														nQtdBD6 += oBrwBD6:fieldGet("BD6_QTDPRO",nForBD6)
													endIf
												else
													nQtdBD6 += oBrwBD6:fieldGet("BD6_QTDPRO",nForBD6)
												endIf
											endIf
											
										endIf
										
									//verifica regra normal sem porte ( por sequencia de inclusão )
									else
									
										if cCodSeq > oBrwBD6:fieldGet("BD6_SEQUEN",nForBD6)
											nQtdBD6 += oBrwBD6:fieldGet("BD6_QTDPRO",nForBD6)
										endIf
										
									endIf
									
								endIf
								
							// qdo nao existir o BD6_DATPRO
							else
							
								if cChave == cChaveBD6 .and. !oBrwBD6:IsDeleted(nForBD6)
									
									// verifica se irá usar regra de Porte ( maior porte )
									// se o principal e o que irá comparar tem porte, usar regra
									
									if !empty(cPortePri) .and. !empty(cPorte)
										
										//compara os portes dos procedimentos
										
										if cPortePri <= cPorte
											
											// sempre tera pelo menos um procedimento e sequencias iguais, pois ele compara com ele mesmo
											if cCodPad+cCodPro+cCodSeq == oBrwBD6:fieldGet("BD6_CODPAD",nForBD6)+oBrwBD6:fieldGet("BD6_CODPRO",nForBD6)+oBrwBD6:fieldGet("BD6_SEQUEN",nForBD6)
												
												lSeqProcIgual  	:= .t.
												cSeqPri 		:= oBrwBD6:fieldGet("BD6_SEQUEN",nForBD6)
												
												nQtdPri += oBrwBD6:fieldGet("BD6_QTDPRO",nForBD6)
												
											else
											
												// se existir outro procedimento igual, mas sequencia diferente
												if cCodPad+cCodPro == oBrwBD6:fieldGet("BD6_CODPAD",nForBD6)+oBrwBD6:fieldGet("BD6_CODPRO",nForBD6)

													lProcIgual:= .t.

													if cCodSeq >= oBrwBD6:fieldGet("BD6_SEQUEN",nForBD6)
														nQtdBD6 += oBrwBD6:fieldGet("BD6_QTDPRO",nForBD6)
													endIf
													
												else
													nQtdBD6 += oBrwBD6:fieldGet("BD6_QTDPRO",nForBD6)
												endIf
												
											endIf
											
										endIf
										
									//verifica regra normal sem porte ( por sequencia de inclusão )
									else
										if cCodSeq > oBrwBD6:fieldGet("BD6_SEQUEN",nForBD6)
											nQtdBD6 += oBrwBD6:fieldGet("BD6_QTDPRO",nForBD6)
										endIf
										
									endIf
									
								endIf
								
							endIf
							
						endIf
						
					next
					
					// Qdo porte trata os procedimentos iguais
					// Encontrou procedimentos iguais com sequencia iguais
					if lSeqProcIgual
				
						// Verifica se encontrou o procedimento novamente com sequencia diferente
						if lProcIgual 
				
							if cCodSeq >= cSeqPri
								nQtdBD6 += nQtdPri
							endIf
							
						else
							nQtdBD6 += nQtdPri
						endIf
						
					endIf
					
				// se lAtend igual a True  ( verifica no atendimento )
				else
					
					for nForBE2 := 1 to len(oBrwPro:aCols)
						
						// se o campo QTDPER do BR8 nao estiver marcado como Sim
						if BR8->(msSeek(xFilial("BR8")+oBrwPro:fieldGet("BE2_CODPAD",nForBE2)+oBrwPro:fieldGet("BE2_CODPRO",nForBE2))) .and. BR8->BR8_QTDPER <> "1"
							loop
						endIf
						
						//se o procedimento principal tem porte, pega o porte do procedimento a comparar
						if !empty(cPortePri)
						
							lRet	:=	.f.
							aVetTab := PLSRETTAB(oBrwPro:fieldGet("BE2_CODPAD",nForBE2),oBrwPro:fieldGet("BE2_CODPRO",nForBE2),;
												dDatPro,cIntPad,"","","","",,,,,,,,,,,lReembolso)
						
							lRet 	:= aVetTab[1]
							
							if lRet
								cCodTab := aVetTab[3]
							endIf
							
							cPorte := PLRETPORTE(oBrwPro:fieldGet("BE2_CODPAD",nForBE2),oBrwPro:fieldGet("BE2_CODPRO",nForBE2),cIntPad,cCodTab,dDatPro)
						endIf
						
						if nFor == 1
							cChaveBE2 := xFilial("BE2")+oBrwPro:fieldGet("BE2_CODPAD",nForBE2)+oBrwPro:fieldGet("BE2_CODPRO",nForBE2)
						else
							cCodAuBE2 := Subs(oBrwPro:fieldGet("BE2_CODPRO",nForBE2),aNiveis[2,(nFor-1),1],aNiveis[2,(nFor-1),2])
							cCodAuBE2 := cCodAuBE2+Space(len(BL0->BL0_CDNV01)-len(cCodAuBE2))+aNiveis[2,(nFor-1),3]
							cChaveBE2 := xFilial("BE2")+oBrwPro:fieldGet("BE2_CODPAD",nForBE2)+cCodAuBE2
						endIf
						
						if cChave == cChaveBE2 .and. !oBrwPro:IsDeleted(nForBE2)
							
							// verifica se irá usar regra de Porte ( maior porte )
							// se o principal e o que irá comparar tem porte, usar regra
							
							if !empty(cPortePri) .and. !empty(cPorte)
								
								//compara os portes dos procedimentos
								
								if cPortePri <= cPorte
									// sempre tera pelo menos um procedimento e sequencias iguais, pois ele compara com ele mesmo
									
									if cCodPad+cCodPro+cCodSeq == oBrwPro:fieldGet("BE2_CODPAD",nForBE2)+oBrwPro:fieldGet("BE2_CODPRO",nForBE2)+oBrwPro:fieldGet("BE2_SEQUEN",nForBE2)
										
										lSeqProcIgual  := .t.
										cSeqPri := oBrwPro:fieldGet("BE2_SEQUEN",nForBE2)
										nQtdPri += oBrwPro:fieldGet("BE2_QTDPRO",nForBE2)
										
									else
									
										// se existir outro procedimento igual, mas sequencia diferente
										if cCodPad+cCodPro == oBrwPro:fieldGet("BE2_CODPAD",nForBE2)+oBrwPro:fieldGet("BE2_CODPRO",nForBE2)
											
											lProcIgual:= .t.
											
											if cCodSeq >= oBrwPro:fieldGet("BE2_SEQUEN",nForBE2)
												nQtdBE2 += oBrwPro:fieldGet("BE2_QTDPRO",nForBE2)
											endIf
											
										else
											nQtdBE2 += oBrwPro:fieldGet("BE2_QTDPRO",nForBE2)
										endIf
										
									endIf
									
								endIf
								
							//verifica regra normal sem porte ( por sequencia de inclusão )
							else
							
								if cCodSeq > oBrwPro:fieldGet("BE2_SEQUEN",nForBE2)
									nQtdBE2 += oBrwPro:fieldGet("BE2_QTDPRO",nForBE2)
								endIf
								
							endIf
							
						endIf
						
					next
					
					// Qdo porte trata os procedimentos iguais
					// Encontrou procedimentos iguais com sequencia iguais
					if lSeqProcIgual
						
						// Verifica se encontrou o procedimento novamente com sequencia diferente
						if lProcIgual 
							if cCodSeq >= cSeqPri
								nQtdBE2 += nQtdPri
							endIf
						else
							nQtdBE2 += nQtdPri
						endIf
					endIf
					
				endIf
				
			// se nao for em memoria
			else 
				
				if !empty(cChaveGui)
					
					if BD6->(indexOrd()) <> 1
						BD6->(dbSetOrder(1)) //BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
					endIf
					
					if BD6->(msSeek(cChaveGui))
						
						while ! BD6->(eof()) .and. cChaveGui == BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)
							
							if BR8->( msSeek( xFilial("BR8") + BD6->(BD6_CODPAD + BD6_CODPRO) ) ) .and. BR8->BR8_QTDPER <> "1"
								BD6->(dbSkip())
								loop
							endIf
							
							//verifica se o procedimento principal (posicionado) tem porte
							if ! empty(cPortePri)

								lRet := .f.

								aVetTab := PLSRETTAB(BD6->BD6_CODPAD,BD6->BD6_CODPRO,dDatPro,cIntPad,"","","","",,,,,,,,;
													iIf(!empty(BAU->BAU_TIPPRE),BAU->BAU_TIPPRE,nil),,,lReembolso,nil,nil,nil,;
													nil,nil,nil,nil,BD6->BD6_CODEMP,BD6->BD6_ANOPAG,BD6->BD6_MESPAG)

								lRet := aVetTab[1]

								if lRet
									cCodTab   := aVetTab[3]
								endIf

								//busca o porte do procedimento a comparar com o principal
								//se não encontrar tras vazio
								cPorte := PLRETPORTE(BD6->BD6_CODPAD,BD6->BD6_CODPRO,cIntPad,cCodTab,dDatPro)

							endIf
							
							if nFor == 1
								cChaveBD6 := xFilial("BD6")+BD6->(BD6_CODPAD+BD6_CODPRO)
							else
								cCodAuBD6 := Subs(BD6->BD6_CODPRO,aNiveis[2,(nFor-1),1],aNiveis[2,(nFor-1),2])
								cCodAuBD6 := cCodAuBD6+Space(len(BL0->BL0_CDNV01)-len(cCodAuBD6))+aNiveis[2,(nFor-1),3]
								cChaveBD6 := xFilial("BD6")+BD6->BD6_CODPAD+cCodAuBD6
							endIf
							
							if cChave + dtos(dDatPro) == cChaveBD6 + dtos(BD6->BD6_DATPRO)
								
								// verifica se irá usar regra de Porte ( maior porte )
								// se o principal e o que irá comparar tem porte, usar regra
								
								if ! empty(cPortePri) .and. ! empty(cPorte)
									
									//compara os portes dos procedimentos
									if cPortePri <= cPorte
										
										// sempre tera pelo menos um procedimento e sequencias iguais, pois ele compara com ele mesmo
										if cCodPad+cCodPro+cCodSeq == BD6->(BD6_CODPAD+BD6_CODPRO+BD6_SEQUEN)
										
											lSeqProcIgual  	:= .t.
											cSeqPri 		:= BD6->BD6_SEQUEN
											nQtdPri 		:= BD6->BD6_QTDPRO
											
										else
											
											// se existir outro procedimento igual, mas sequencia diferente
											if cCodPad+cCodPro == BD6->(BD6_CODPAD+BD6_CODPRO)

												lProcIgual	:= .t.
												
												if cCodSeq > BD6->BD6_SEQUEN
													
													nQtdBD6 += BD6->BD6_QTDPRO
												
												endIf
												
											else
												nQtdBD6 += BD6->BD6_QTDPRO
											endIf
											
										endIf
										
									endIf
									
								//verifica regra normal sem porte ( por sequencia de inclusão )
								else
								
									if cCodSeq > BD6->BD6_SEQUEN
										nQtdBD6 += BD6->BD6_QTDPRO
									endIf
									
								endIf
								
							endIf
							
						BD6->(dbSkip())
						endDo
						
					endIf
					
				endIf
				
				// Qdo porte trata os procedimentos iguais
				// Encontrou procedimentos iguais com sequencia iguais
				if lSeqProcIgual
				
					// Verifica se encontrou o procedimento novamente com sequencia diferente
					if lProcIgual 
						
						if cCodSeq >= cSeqPri
							nQtdBD6 += nQtdPri
						endIf
						
					else
						nQtdBD6 += nQtdPri
					endIf
					
				endIf
				
				BD6->(restArea(aAreaBD6))
			endIf
			
			while ! BL0->(eof()) .and. BL0->(&(IndexKey())) == cChave

				aadd(aBL0, { BL0->BL0_TIPO, BL0->BL0_QTD, BL0->BL0_PERC } )

			BL0->(dbSkip()) 
			endDo
			
			aBL0 := aSort(aBL0,,,{|x,y| x[1]+str(x[2]) < y[1]+str(y[2])})
			
			if lMemory
				
				if nPosBD6 <> 0
					
					for nI := 1 to len(aBL0)
						
						if (nQtdBD6 == 0 .and. nQtdPro >= aBL0[nI][2]) .or. ((nFor == 1 .and. nQtdPro >= aBL0[nI][2]) .and. empty(cPortePri))
						
							cMacro := "'BD6_QTD"+allTrim(str(aBL0[nI][2]))+"'"
							oBrwBD6:fieldPut(cMacro,aBL0[nI][2],nPosBD6)
							
							cMacro1 := "'BD6_PERC"+allTrim(str(aBL0[nI][2]))+"'"
							oBrwBD6:fieldPut(cMacro1,aBL0[nI][3],nPosBD6)
							
							if TYPE('aCols') = 'A'
								aCols[nPosBD6,PlRetPos(cMacro,oBrwBD6:aHeader)]  := aBL0[nI][2]
								aCols[nPosBD6,PlRetPos(cMacro1,oBrwBD6:aHeader)] := aBL0[nI][3]
							endIf
							
							aadd(aRet,{aBL0[nI][1],oBrwBD6:aCols[nPosBD6,oBrwBD6:fieldPos(&cMacro)],oBrwBD6:aCols[nPosBD6,oBrwBD6:fieldPos(&cMacro1)]})
							
						else
						
							if !empty(cPortePri)
								if nQtdPro > 1
									cBusca := nQtdBD6 >= aBL0[nI][2] .and. nQtdBD6 != 0  .and. nProQtd <= nQtdPro
								else
									cBusca := nQtdBD6 <= aBL0[nI][2] .and. nQtdBD6 != 0  .and. nProQtd <= nQtdPro
								endIf
							else
								cBusca := nQtdBD6 < aBL0[nI][2] .and. nQtdBD6 != 0  .and. nProQtd <= nQtdPro
							endIf
							
							if cBusca
							
								cMacro := "'BD6_QTD"+allTrim(str(nProQtd))+"'"
								oBrwBD6:fieldPut(cMacro,nProQtd,nPosBD6)
								
								cMacro1 := "'BD6_PERC"+allTrim(str(nProQtd))+"'"
								oBrwBD6:fieldPut(cMacro1,aBL0[nI][3],nPosBD6)
								
								if TYPE('aCols') = 'A'
									aCols[nPosBD6,PlRetPos(cMacro,oBrwBD6:aHeader)] := nProQtd
									aCols[nPosBD6,PlRetPos(cMacro1,oBrwBD6:aHeader)] := aBL0[nI][3]
								endIf
								
								aadd(aRet,{aBL0[nI][1],oBrwBD6:aCols[nPosBD6,oBrwBD6:fieldPos(&cMacro)],oBrwBD6:aCols[nPosBD6,oBrwBD6:fieldPos(&cMacro1)]})
								
								
								nProQtd++
							endIf
							
							if nQtdBD6 > aBL0[nI][2]
							
								cMacro1 := "'BD6_PERC"+allTrim(str(nProQtd))+"'"
								oBrwBD6:fieldPut(cMacro1,0,nPosBD6)
								
								if TYPE('aCols') = 'A'
									aCols[nPosBD6,PlRetPos(cMacro1,oBrwBD6:aHeader)] := 0
								endIf
								
							endIf
							
						endIf
						
					next 
					
				else
					
					// pega o que está na meméria
					for nI := 1 to len(aBL0)
						
						if ! lAtend
							
							if (nQtdBD6 == 0 .and. nQtdPro >= aBL0[nI][2]) .or. ((nFor == 1 .and. nQtdPro >= aBL0[nI][2]) .and. empty(cPortePri))
							
								cMacro 	:= ("M->BD6_QTD"+allTrim(str(aBL0[nI][2])))
								&cMacro	:= aBL0[nI][2]
							
								cMacro 	:= ("M->BD6_PERC"+allTrim(str(aBL0[nI][2])))
								&cMacro := aBL0[nI][3]
							
								aadd(aRet,{aBL0[nI][1],&("M->BD6_QTD"+allTrim(str(aBL0[nI][2]))),&("M->BD6_PERC"+allTrim(str(aBL0[nI][2])))})
								
							else
								
								if !empty(cPortePri)
								
									if nQtdPro > 1
										cBusca := nQtdBD6 >= aBL0[nI][2] .and. nQtdBD6 != 0  .and. nProQtd <= nQtdPro
									else
										cBusca := nQtdBD6 <= aBL0[nI][2] .and. nQtdBD6 != 0  .and. nProQtd <= nQtdPro
									endIf
									
								else
									cBusca:=nQtdBD6 < aBL0[nI][2] .and. nQtdBD6 != 0  .and. nProQtd <= nQtdPro
								endIf
								
								if cBusca
								
									cMacro 	:= ("M->BD6_QTD"+allTrim(str(nProQtd)))
									&cMacro := nProQtd
									
									cMacro 	:= ("M->BD6_PERC"+allTrim(str(nProQtd)))
									&cMacro := aBL0[nI][3]
									
									aadd(aRet,{aBL0[nI][1],&("M->BD6_QTD"+allTrim(str(nProQtd))),&("M->BD6_PERC"+allTrim(str(nProQtd)))})
									
									nProQtd++
									
								endIf
								
							endIf
							
						else 
							
							if (nQtdBE2 == 0 .and. nQtdPro >= aBL0[nI][2]) .or. ((nFor == 1 .and. nQtdPro >= aBL0[nI][2]).and.empty(cPortePri))
							
								cMacro 	:= ("M->BE2_QTD"+allTrim(str(aBL0[nI][2])))
								&cMacro := aBL0[nI][2]
								
								cMacro 	:= ("M->BE2_PERC"+allTrim(str(aBL0[nI][2])))
								&cMacro := aBL0[nI][3]
								
								aadd(aRet,{aBL0[nI][1],&("M->BE2_QTD"+allTrim(str(aBL0[nI][2]))),&("M->BE2_PERC"+allTrim(str(aBL0[nI][2])))})
								 
							else
							
								if !empty(cPortePri)
									if nQtdPro > 1
										cBusca := nQtdBE2 >= aBL0[nI][2] .and. nQtdBE2 != 0  .and. nProQtd <= nQtdPro
									else
										cBusca := nQtdBE2 <= aBL0[nI][2] .and. nQtdBE2 != 0  .and. nProQtd <= nQtdPro
									endIf
								else
									cBusca := nQtdBE2 < aBL0[nI][2] .and. nQtdBE2 != 0  .and. nProQtd <= nQtdPro
								endIf
								
								if cBusca
									cMacro 	:= ("M->BE2_QTD"+allTrim(str(nProQtd)))
									&cMacro := nProQtd
								
									cMacro 	:= ("M->BE2_PERC"+allTrim(str(nProQtd)))
									&cMacro := aBL0[nI][3]
									
									aadd(aRet,{aBL0[nI][1],&("M->BE2_QTD"+allTrim(str(nProQtd))),&("M->BE2_PERC"+allTrim(str(nProQtd)))})
									
									nProQtd++
								endIf
								
							endIf
						endIf
						
					next
					
				endIf
				
			else
				
				if ! BD6->( eof() ) .and. ! empty(cChaveGui)
					
					BD6->(recLock("BD6",.f.))

						for nI := 1 to len(aBL0)
							
							if cAltPerc = "1"
								cMacro := ("BD6->BD6_QTD" + allTrim(str(aBL0[nI][2])))
								&cMacro:= 0
								
								cMacro := ("BD6->BD6_PERC" + allTrim(str(aBL0[nI][2])))
								&cMacro:= 0
							endIf
							
							if (nQtdBD6 == 0 .and. nQtdPro >= aBL0[nI][2]) .or. ((nFor == 1 .and. nQtdPro >= aBL0[nI][2]).and.empty(cPortePri))
								
								cMacro := ("BD6->BD6_QTD" + allTrim(str(aBL0[nI][2])))
								
								if &cMacro == 0 .or. cAltPerc = "1"
									&cMacro := aBL0[nI][2]
								endIf
								
								cMacro := ("BD6->BD6_PERC" + allTrim(str(aBL0[nI][2])))
								
								if &cMacro == 0 .or. cAltPerc = "1"
									&cMacro := aBL0[nI][3]
								endIf
								
							aadd(aRet,{aBL0[nI][1],&("BD6->BD6_QTD"+allTrim(str(aBL0[nI][2]))),&("BD6->BD6_PERC"+allTrim(str(aBL0[nI][2])))})

							else
								
								if ! empty(cPortePri)

									if nQtdPro > 1
										cBusca := nQtdBD6 >= aBL0[nI][2] .and. nQtdBD6 != 0  .and. nProQtd <= nQtdPro
									else
										cBusca := nQtdBD6 <= aBL0[nI][2] .and. nQtdBD6 != 0  .and. nProQtd <= nQtdPro
									endIf

								else
									cBusca := nQtdBD6 < aBL0[nI][2] .and. nQtdBD6 != 0  .and. nProQtd <= nQtdPro
								endIf
								
								if cBusca
								
									cMacro := ("BD6->BD6_QTD"+allTrim(str(nProQtd)))
								
									if &cMacro == 0 .or. cAltPerc = "1"
										&cMacro := nProQtd
									endIf
								
									cMacro := ("BD6->BD6_PERC"+allTrim(str(nProQtd)))

									if &cMacro == 0 .or. cAltPerc = "1"
										&cMacro := aBL0[nI][3]
									endIf
								
								aadd(aRet,{aBL0[nI][1],&("BD6->BD6_QTD"+allTrim(str(nProQtd))),&("BD6->BD6_PERC"+allTrim(str(nProQtd)))})
									nProQtd++
									
								endIf

							endIf
							
						next
						
					BD6->( msUnLock() )
					
				endIf 
				
			endIf
			
			if ! empty(cPortePri) .and. lMemory .and. nPosBd6 = 0 .and. ! lAtend
			
				if len(oBrwBD6:aCols) <> 3
				
					if val(M->BD6_SEQUEN) > len(oBrwBD6:aCols)

					 	// tira o da memoria
						nForBD6Ate := len(oBrwBD6:aCols) - 1  

					else
						
						nForBD6Ate := len(oBrwBD6:aCols)

					endIf
					
				else
					nForBD6Ate := len(oBrwBD6:aCols)
				endIf
				
				for nPosBD6 := 1 to nForBD6Ate
					
					if ! empty(oBrwBD6:fieldGet("BD6_CODPRO",nPosBD6))
						
						PlMonQtPer( oBrwBD6:fieldGet("BD6_SEQUEN",nPosBD6),;
									oBrwBD6:fieldGet("BD6_CODPAD",nPosBD6),;
									oBrwBD6:fieldGet("BD6_CODPRO",nPosBD6),;
									oBrwBD6:fieldGet("BD6_QTDPRO",nPosBD6),;
									.t.,;
									nil,;
									dDatPro,;
									nil,;
									.f.,;
									nil,;
									nPosBD6)
						
					endIf
					
				next
				
			endIf
			
			exit
			
		endIf
		
	next
	
endIf

if existBlock("PLMQTPER")
	aRet := execBlock("PLMQTPER",.f.,.f.,{cCodSeq,cCodPad,cCodPro,nQtdPro,lMemory,cChaveGui,dDatPro,lValid,nPosBD6,aBL0,aRet,cCodTab})
endIf

BD6->(restArea(aAreaBD6))
BR8->(restArea(aAreaBR8))

return iIf(lValid,lValid,aRet)

/*/{Protheus.doc} PlTrtTxPa
Trata a glosa automatica da taxa
@type function
@author PLSTEAM
@since 29.04.06
@version 1.0
/*/
function PlTrtTxPa(nPrTxPag,nVlrPagBru,aDadUsr,nVlrTxPg,aCri,cLocalExec)
local aAreaBAU		:= BAU->(getArea())
local aAreaBRJ		:= BRJ->(getArea())
local aAreaBD7		:= BD7->(getArea())
local aAreaBD6		:= BD6->(getArea())
local nDias   		:= getNewPar("MV_PLSDRNI",150)//quantidade maxima + dias prorrogaveis
local nDiasIn 		:= getNewPar("MV_PLSDRID",90) //quantidade maxima
local nDiasRAMI 	:= getNewPar("MV_PLSDRAM",120) 	//quantidade maxima de dias RAMI
local dData			:= stod("")
local nVlrGtx		:= 0
local cOpeOri 		:= aDadUsr[45]
local lBD7_VLRGTX 	:= BD7->(fieldPos("BD7_VLRGTX")) > 0
local lBD6_VLRGTX 	:= BD6->(fieldPos("BD6_VLRGTX")) > 0
local lBD6_VLTXAP 	:= BD6->(fieldPos("BD6_VLTXAP")) > 0

BAU->(dbSetOrder(1))
if PLSPOSGLO(PLSINTPAD(),__aCdCri097[1],__aCdCri097[2],cLocalExec) .and. PLSCHKCRI( {'BAU',BD6->BD6_CODRDA,__aCdCri097[1]} ) .and. BAU->(msSeek(xFilial("BAU")+BD6->BD6_CODRDA)) 
	
	if  ! empty(BD6->BD6_SEQIMP)  .and. (BAU->BAU_TIPPRE == getNewPar("MV_PLSTPIN","OPE") .or. cOpeOri <> PLSINTPAD() )
		
		BRJ->(dbSetOrder(1))
		if BRJ->(msSeek(xFilial("BRJ")+BD6->BD6_SEQIMP))
			
			//Se for guia de internacao, e analisado com a base na data de alta   |
			dData := BD6->BD6_DATPRO
			
			if BD6->BD6_TIPGUI $ G_SOL_INTER +"|"+ G_RES_INTER
				
				BE4->(dbSetOrder(1))//BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_SITUAC+BE4_FASE
				if BE4->(msSeek(xFilial("BE4")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_SITUAC+BD6_FASE)))
					dData := BE4->BE4_DTALTA
				endIf
				
			endIf
			
			//mais que 180 dias já eh tratado no PLSMVLD
			//aqui no 720 eu so trato entre 150 e 90
			if ( (BRJ->BRJ_DATA - dData) > nDiasIn) .and. ( (BRJ->BRJ_DATA - dData) <= nDias )
				
				if getNewPar("MV_P500BD6","0") == "1" .and. lBD6_VLTXAP .and. BD6->BD6_VLTXAP == 0
					
					BAU->(restArea(aAreaBAU))
					BRJ->(restArea(aAreaBRJ))
					BD7->(restArea(aAreaBD7))
					
					return
				endIf
				
				//RAMI regra de 120 dias para não cobrar taxa
				if BAU->BAU_EST == "RS" .and. BA0->BA0_EST == "RS" .and. (BRJ->BRJ_DATA - dData) <= nDiasRAMI
					BAU->(restArea(aAreaBAU))
					BRJ->(restArea(aAreaBRJ))
					BD7->(restArea(aAreaBD7))
					BD6->(restArea(aAreaBD6))				
					return
				endif
				aCri[1] := .f.
				
				aadd(aCri[2],{__aCdCri097[1],__aCdCri097[2],"",BCT->BCT_NIVEL,BCT->BCT_TIPO,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO} )
				aadd(aCri[2],{"",STR0100,dtoc(BRJ->BRJ_DATA),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})  //"Data da importacao do arquivo PTU"
				aadd(aCri[2],{"",STR0101,dtoc(dData),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})  //"Data do atendimento"
				aadd(aCri[2],{"",STR0102,str(BRJ->BRJ_DATA - dData,6),"","",BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,BD6->BD6_DESPRO})  //"Qtd. de dias ultrapassados"
				
				BD7->(dbSetOrder(1))
				
				if BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
					
					while ! BD7->(eof()) .and. xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) == BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
						
						BD7->(recLock("BD7",.f.))
						
							BD7->BD7_VLRPAG := BD7->BD7_VLRMAN

							if lBD7_VLRGTX
								BD7->BD7_VLRGTX := BD7->BD7_VLTXPG 
							else
								BD7->BD7_VLRGLO := BD7->BD7_VLTXPG
							endIf

							nVlrGtx 		+= BD7->BD7_VLTXPG
							BD7->BD7_VLTXPG := 0
							
						BD7->(msUnLock())
						
					BD7->(dbSkip())
					endDo
					
					if nVlrGtx > 0
						
						BD6->(recLock("BD6",.f.))
							
							BD6->BD6_VLRPAG := BD6->BD6_VLRMAN
							
							if lBD6_VLRGTX
								BD6->BD6_VLRGTX := nVlrGtx
							else
								BD6->BD6_VLRGLO := nVlrGtx
							endIf
							
							BD6->BD6_VLTXPG := 0
							
						BD6->(msUnLock())
						
					endIf	
					
				endIf
				
			endIf
			
		endIf
		
	endIf
	
endIf

BAU->(restArea(aAreaBAU))
BRJ->(restArea(aAreaBRJ))
BD7->(restArea(aAreaBD7))
BD6->(restArea(aAreaBD6))

return

/*/{Protheus.doc} PLSVLLCBD7
Validacao do local de atendimento
@type function
@author PLSTEAM
@since 10.01.07
@version 1.0
/*/
function PLSVLLCBD7()
local aRetFun
local lRet := .t.
local cOPERDA	:= iIf(Type("M->BD5_OPERDA") == "C",M->BD5_OPERDA,M->BE4_OPERDA)
local nI		:= aScan(oBrwBD6:aCols,{|x| x[PLRETPOS("BD6_SEQUEN",oBrwBD6:aHeader)] == M->BD7_SEQUEN })

if ! empty(M->BD7_LOCATE)
	
	aRetFun := PLSVDLOCRD(M->BD7_CODRDA,cOPERDA,oBrwBD6:aCols[nI][PLRETPOS("BD6_DATPRO",oBrwBD6:aHeader)],Subs(M->BD7_LOCATE,1,3),"","")
	
	if ! aRetFun[1]
		lRet := .f.
		if len(aRetFun) >= 2
			PLSMOVCRI("3",{},aRetFun[2])
		endIf
	endIf
endIf

return(lRet)

/*/{Protheus.doc} PLSVLESBD7
Validacao da especialidade da composicao / subitem
@type function
@author PLSTEAM
@since 10.01.07
@version 1.0
/*/
function PLSVLESBD7()
local aRetFun
local lRet		:= .t.
local cOPERDA	:= iIf(Type("M->BD5_OPERDA") == "C",M->BD5_OPERDA,M->BE4_OPERDA)
local nI		:= aScan(oBrwBD6:aCols,{|x| x[PLRETPOS("BD6_SEQUEN",oBrwBD6:aHeader)] == M->BD7_SEQUEN })

BB8->(dbSetOrder(1))	//BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL
BB8->(msSeek(xFilial("BB8")+M->BD7_CODRDA+cOPERDA+Subs(M->BD7_LOCATE,1,3)))

if ! empty(M->BD7_CODESP)
	
	aRetFun := PLSVDESPRD(M->BD7_CODRDA,cOPERDA,Subs(M->BD7_LOCATE,1,3),M->BD7_CODESP,oBrwBD6:aCols[nI][PLRETPOS("BD6_DATPRO",oBrwBD6:aHeader)],"","")
	
	if ! aRetFun[1]
		lRet := .f.
		Help("",1,"PLSA090ESP")
	endIf
endIf

return(lRet)

/*/{Protheus.doc} PLSA720LOC
Preenche olocal de atendimento no BD7
@type function
@author PLSTEAM
@since 19.01.07
@version 1.0
/*/
function PLSA720LOC()
local cAliasCab := BCL->BCL_ALIAS
local cOpeRda	:= &("M->"+cAliasCab+"_OPERDA")
local cCodRda	:= &("M->"+cAliasCab+"_CODRDA")
local cLocAte	:= subs(&("M->"+cAliasCab+"_CODLOC"),1,3)+subs(&("M->"+cAliasCab+"_LOCAL"),1,3)
local aRet		:= {}
local aAreaBD6	:= {}
local cRet		:= ""
local cCep		:= ""
local cDatPro	:=	""
local cCodPad	:=	""
local cCodPro 	:=	""
local nI		:= 0

//-------------------------------------------------
// Busco o CEP da RDA corrente
//-------------------------------------------------
BB8->(dbSetOrder(1))
if BB8->(msSeek(xFilial("BB8")+cCodRda+cOpeRda+cLocAte))
	cCep := BB8->BB8_CEP
endIf

if Type("oBrwBD6") == "O"
	nI		:= aScan(oBrwBD6:aCols,{|x| x[PLRETPOS("BD6_SEQUEN",oBrwBD6:aHeader)] == M->BD7_SEQUEN })
	cDatPro	:=	oBrwBD6:aCols[nI][PLRETPOS("BD6_DATPRO",oBrwBD6:aHeader)]
	cCodPad	:=	oBrwBD6:aCols[nI][PLRETPOS("BD6_CODPAD",oBrwBD6:aHeader)]
	cCodPro :=	oBrwBD6:aCols[nI][PLRETPOS("BD6_CODPRO",oBrwBD6:aHeader)]
else
	aAreaBD6	:=	BD6->(getArea())
	BD6->(dbSetOrder(1))//Conferir indice correto.
	if BD6->(msSeek(xFilial("BD6")+BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)+M->BD7_SEQUEN))
		cDatPro	:=	BD6->BD6_DATPRO
		cCodPad	:=	BD6->BD6_CODPAD
		cCodPro :=	BD6->BD6_CODPRO
	endIf
	BD6->(restArea(aAreaBD6))
endIf

aRet := PLSVDLOCRD(M->BD7_CODRDA,;
	cOpeRda,;
	cDatPro,;
	nil,;
	cCodPad,;
	cCodPro,;
	nil,;
	cCep)

if aRet[1]
	cRet          := BB8->BB8_CODLOC+BB8->BB8_LOCAL
	M->BD7_CODLOC := BB8->BB8_CODLOC
	M->BD7_LOCAL  := BB8->BB8_LOCAL
	M->BD7_DESLOC := BB8->BB8_DESLOC
endIf

return(cRet)

/*/{Protheus.doc} PLSA720ESP
Preenche a especialidade no BD7 / composicao / subitem
@type function
@author PLSTEAM
@since 19.01.07
@version 1.0
/*/
function PLSA720ESP()
local cAliasCab := BCL->BCL_ALIAS
local cOpeRda	:= &("M->"+cAliasCab+"_OPERDA")
local aRet		:= {}
local cRet		:= ""
local cDatPro	:=	""
local cCodPad	:=	""
local cCodPro 	:=	""
local nI		:= 0

if Type("oBrwBD6") == "O"
	nI		:= aScan(oBrwBD6:aCols,{|x| x[PLRETPOS("BD6_SEQUEN",oBrwBD6:aHeader)] == M->BD7_SEQUEN })
	cDatPro	:=	oBrwBD6:aCols[nI][PLRETPOS("BD6_DATPRO",oBrwBD6:aHeader)]
	cCodPad	:=	oBrwBD6:aCols[nI][PLRETPOS("BD6_CODPAD",oBrwBD6:aHeader)]
	cCodPro	:=	oBrwBD6:aCols[nI][PLRETPOS("BD6_CODPRO",oBrwBD6:aHeader)]
else
	aAreaBD6	:=	BD6->(getArea())
	BD6->(dbSetOrder(1))//Conferir indice correto.
	if BD6->(msSeek(xFilial("BD6")+BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)+M->BD7_SEQUEN))
		cDatPro	:=	BD6->BD6_DATPRO
		cCodPad	:=	BD6->BD6_CODPAD
		cCodPro :=	BD6->BD6_CODPRO
	endIf
	BD6->(restArea(aAreaBD6))
endIf

aRet := PLSVDESPRD(M->BD7_CODRDA,;
					cOpeRda,;
					BB8->BB8_CODLOC,;
					'',;
					cDatPro,;
					cCodPad,;
					cCodPro,;
					nil)
if aRet[1]
	cRet          := BAQ->BAQ_CODESP
	M->BD7_DESESP := BAQ->BAQ_DESCRI
endIf

return(cRet)

/*/{Protheus.doc} PL720GLOC
Gatilho do campo BD7_LOCATE
@type function
@author PLSTEAM
@since 18.01.07
@version 1.0
/*/
function PL720GLOC()
local aArea		:= getArea()
local cOPERDA	:= iIf(Type("M->BD5_OPERDA") == "C",M->BD5_OPERDA,M->BE4_OPERDA)
local cDESLOC 	:= Space( TamSX3("BB8_DESLOC")[1] )

M->BD7_CODESP := Space( TamSX3("BD7_CODESP")[1] )
M->BD7_DESESP := Space( TamSX3("BD7_DESESP")[1] )

BB8->(dbSetOrder(1))	//BAX_FILIAL+BAX_CODIGO+BAX_CODINT+BAX_CODLOC+BAX_CODESP+BAX_CODSUB
if BB8->(msSeek(xFilial("BB8")+M->BD7_CODRDA+cOPERDA+M->BD7_LOCATE))
	M->BD7_CODLOC := BB8->BB8_CODLOC
	M->BD7_LOCAL  := BB8->BB8_LOCAL
	cDESLOC		  := BB8->BB8_DESLOC
endIf

restArea(aArea)

return(cDESLOC)

/*/{Protheus.doc} PL720GESP
Gatilho do campo BD7_CODESP
@type function
@author PLSTEAM
@since 18.01.07
@version 1.0
/*/
function PL720GESP()
local aArea		:= getArea()
local cOPERDA	:= iIf(Type("M->BD5_OPERDA") == "C",M->BD5_OPERDA,M->BE4_OPERDA)
local cDESESP 	:= Space( TamSX3("BAQ_DESCRI")[1] )

BAX->(dbSetOrder(1))	//BAX_FILIAL+BAX_CODIGO+BAX_CODINT+BAX_CODLOC+BAX_CODESP+BAX_CODSUB
if BAX->(msSeek(xFilial("BAX")+M->BD7_CODRDA+cOPERDA+SUBS(M->BD7_LOCATE,1,3)+M->BD7_CODESP))
	cDESESP	:= Posicione("BAQ",1,xFilial("BAQ")+BAX->(BAX_CODINT+BAX_CODESP),"BAQ_DESCRI")
endIf

restArea(aArea)

return(cDESESP)

/*/{Protheus.doc} PL720IDESP
Inicializador do campo BD7_DESESP
@type function
@author PLSTEAM
@since 18.01.07
@version 1.0
/*/
function PL720IDESP()
local aArea		:= getArea()
local cOPERDA	:= iIf(Type("M->BD5_OPERDA") == "C",M->BD5_OPERDA,M->BE4_OPERDA)
local cDESESP 	:= Space( TamSX3("BAQ_DESCRI")[1] )

BAX->(dbSetOrder(1))	//BAX_FILIAL+BAX_CODIGO+BAX_CODINT+BAX_CODLOC+BAX_CODESP+BAX_CODSUB
if BAX->(msSeek(xFilial("BAX")+BD7->BD7_CODRDA+cOPERDA+SUBS(BD7->BD7_LOCATE,1,3)+BD7->BD7_CODESP))
	cDESESP	:= Posicione("BAQ",1,xFilial("BAQ")+BAX->(BAX_CODINT+BAX_CODESP),"BAQ_DESCRI")
endIf

restArea(aArea)

return(cDESESP)

/*/{Protheus.doc} PlRetPac
Retorna um array com o pacote
@type function
@author PLSTEAM
@since 29.04.06
@version 1.0
/*/
function PlRetPac(cCodInt,cCodRDA,cCodPad,cCodPro,cTipPreGui,dDatPro,lCritIt)
local aRet 		   	:= {}
local cSql			:= ""
local lFound 	   	:= .f.
local dVigDe 	   	:= stod("")
local dVigAte	   	:= stod("")
local nOrdBAU	   	:= BAU->(indexOrd())
local nRecBAU	   	:= BAU->(recno())
local nOrdBLY	   	:= BLY->(indexOrd())
local nRecBLY	   	:= BLY->(recno())
local nOrdB42	   	:= B42->(indexOrd())
local nRecB42	   	:= B42->(recno())
local lB42_COMPAR	:= B42->(fieldPos("B42_COMPAR")) > 0
local bRest		   	:= {|| 	BAU->(dbSetOrder(nOrdBAU)),BAU->(dbGoto(nRecBAU)),;
							BLY->(dbSetOrder(nOrdBLY)),BLY->(dbGoto(nRecBLY)),;
							B42->(dbSetOrder(nOrdB42)),B42->(dbGoto(nRecB42))}

default cTipPreGui 	:= ""
default dDatPro	   	:= dDataBase
default lCritIt		:= .f.

if empty(cTipPreGui)

	BAU->(dbSetOrder(1))
	if BAU->(msSeek(xFilial("BAU")+cCodRDA))
		cTipPreGui := BAU->BAU_TIPPRE
	endIf
	
endIf
//-------------------------------------------------
// Rda x Pacote
//-------------------------------------------------
if !lFound

	BLY->(dbSetOrder(1))
	if BLY->(msSeek(xFilial("BLY")+cCodInt+cCodRDA+cCodPad+cCodPro)) .and. !lCritIt

		while !BLY->(eof()) .and. xFilial("BLY")+cCodInt+cCodRDA+cCodPad+allTrim(cCodPro) == BLY->(BLY_FILIAL+BLY_CODINT+BLY_CODRDA+BLY_CODPAD)+allTrim(BLY->BLY_CODPRO)
			
			dVigDe := BLY->BLY_VIGDE
			dVigAte:= BLY->BLY_VIGATE
			//-------------------------------------------------
			//| Indica se o eh intervalo valido											
			//-------------------------------------------------
			if   !( ( !empty(dVigDe) .and. !empty(dVigAte) .and. ((dDatPro < dVigDe) .or. (dDatPro > dVigAte))) .or. ;
					( !empty(dVigDe) .and. empty(dVigAte) .and. dDatPro < dVigDe  ) .or.;
					( empty(dVigDe) .and. !empty(dVigAte) .and. dDatPro > dVigAte  ))  .and. BLY->BLY_ATIVO == '1'
				
				aadd(aRet,{	BLY->BLY_CPADOC,;//01
							BLY->BLY_CODOPC,;//02
							BLY->BLY_TIPO,;//03
							BLY->BLY_VALCH,;//04
							BLY->BLY_VALFIX,;//05
							BLY->BLY_PRINCI,;//06
							BLY->BLY_VIGDE,;//07
							BLY->BLY_VIGATE,;//08
							BLY->BLY_COMPAR,;//09
							"BLY",;//10
							lCritIt})//11
				
				lFound	:= .t.
				
			endIf
			
		BLY->(dbSkip())
		endDo
		
	else
	
		BLY->(dbSetOrder(2))
		if BLY->(msSeek(xFilial("BLY")+cCodInt+cCodRDA+cCodPad+cCodPro))
			
			while !BLY->(eof()) .and. xFilial("BLY")+cCodInt+cCodRDA+cCodPad+allTrim(cCodPro) == BLY->(BLY_FILIAL+BLY_CODINT+BLY_CODRDA+BLY_CPADOC)+allTrim(BLY->BLY_CODOPC)
				
				dVigDe := BLY->BLY_VIGDE
				dVigAte:= BLY->BLY_VIGATE
				//-------------------------------------------------
				//| Indica se o eh intervalo valido											|
				//-------------------------------------------------
				if   !( ( !empty(dVigDe) .and. !empty(dVigAte) .and. ((dDatPro < dVigDe) .or. (dDatPro > dVigAte))) .or. ;
						( !empty(dVigDe) .and. empty(dVigAte) .and. dDatPro < dVigDe  ) .or.;
						( empty(dVigDe) .and. !empty(dVigAte) .and. dDatPro > dVigAte  ))  .and. BLY->BLY_ATIVO == '1'
						
					lCritIt	:= .t.
					aadd(aRet,{	BLY->BLY_CPADOC,;//01
								BLY->BLY_CODOPC,;//02
								BLY->BLY_TIPO,;//03
								BLY->BLY_VALCH,;//04
								BLY->BLY_VALFIX,;//05
								BLY->BLY_PRINCI,;//06
								BLY->BLY_VIGDE,;//07
								BLY->BLY_VIGATE,;//08
								BLY->BLY_COMPAR,;//09
								"BLY",;//10
								lCritIt})//11
					
					lFound	:= .t.
					
				endIf
				
			BLY->(dbSkip())
			endDo
			
		endIf
		
	endIf
	
endIf
//-------------------------------------------------
// Classe de Pacote
//-------------------------------------------------
if !lFound

	B42->(dbSetOrder(1))
	if B42->(msSeek(xFilial("B42")+cCodInt+cTipPreGui+cCodPad+cCodPro))

		while !B42->(eof()) .and. xFilial("B42")+cCodInt+cTipPreGui+cCodPad+allTrim(cCodPro) == B42->(B42_FILIAL+B42_CODINT+B42_TIPPRE+B42_CODPAD)+allTrim(B42->B42_CODPRO)
			
			dVigDe := B42->B42_VIGDE
			dVigAte:= B42->B42_VIGATE
			//-------------------------------------------------
			//| Indica se o eh intervalo valido											|
			//-------------------------------------------------
			if   !( ( !empty(dVigDe) .and. !empty(dVigAte) .and. ((dDatPro < dVigDe) .or. (dDatPro > dVigAte))) .or. ;
					( !empty(dVigDe) .and. empty(dVigAte) .and. dDatPro < dVigDe  ) .or.;
					( empty(dVigDe) .and. !empty(dVigAte) .and. dDatPro > dVigAte  )) .and. B42->B42_ATIVO == '1'
				
				aadd(aRet,{	B42->B42_CPADOC,;//01
							B42->B42_CODOPC,;//02
							B42->B42_TIPO,;//03
							B42->B42_VALCH,;//04
							B42->B42_VALFIX,;//05
							B42->B42_PRINCI,;//06
							B42->B42_VIGDE,;//07
							B42->B42_VIGATE,;//08
							iIf(lB42_COMPAR, B42->B42_COMPAR,""),;//09
							"B42",;
							lCritIt})//10
				
				lFound	:= .t.
			endIf
			
		B42->(dbSkip())
		endDo
	endIf
endIf
//-------------------------------------------------
// Procedimento pacote   (BLE)
//-------------------------------------------------
if !lFound
	
	if !lCritIt
		cSql := " SELECT BLE_FILIAL, BLE_CODINT, BLE_CODPAD, BLE_CODPRO, BLE_CPADOC, BLE_CODOPC, BLE_TIPO, BLE_VALCH, BLE_VALFIX, BLE_PRINCI, BLE_VIGDE, BLE_VIGATE, BLE_COMPAR, BLE_ATIVO  " 
		cSql += " FROM  " + RetSqlName("BLE") 
		cSql += " WHERE BLE_FILIAL = '" + xFilial("BLE")   + "'  "	
		cSql += " AND BLE_CODINT = '" + cCodInt  + "'  "
		cSql += " AND BLE_CODPAD = '" + cCodPad  + "'  "
		cSql += " AND BLE_CODPRO = '" + cCodPro  + "'  "
		cSql += " AND D_E_L_E_T_ = ' '  "

		dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"tmpBLE",.F.,.T.)
		
		while !tmpBLE->(eof()) 
			
			dVigDe := stod(tmpBLE->BLE_VIGDE)
			dVigAte:= stod(tmpBLE->BLE_VIGATE)
			//-------------------------------------------------
			//| Indica se o eh intervalo valido											|
			//-------------------------------------------------
			if   !( ( !empty(dVigDe) .and. !empty(dVigAte) .and. ((dDatPro < dVigDe) .or. (dDatPro > dVigAte))) .or. ;
					( !empty(dVigDe) .and. empty(dVigAte) .and. dDatPro < dVigDe  ) .or.;
					( empty(dVigDe) .and. !empty(dVigAte) .and. dDatPro > dVigAte  ))  .and. tmpBLE->BLE_ATIVO == '1'
				
				aadd(aRet,{	tmpBLE->BLE_CPADOC,;//01
							tmpBLE->BLE_CODOPC,;//02
							tmpBLE->BLE_TIPO,;//03
							tmpBLE->BLE_VALCH,;//04
							tmpBLE->BLE_VALFIX,;//05
							tmpBLE->BLE_PRINCI,;//06
							stod(tmpBLE->BLE_VIGDE),;//07
							stod(tmpBLE->BLE_VIGATE),;//08
							tmpBLE->BLE_COMPAR,;//09
							"BLE",;//10
							lCritIt})//11
				
				lFound	:= .t.
			endIf
			
			tmpBLE->(dbSkip())
		endDo
		tmpBLE->(dbCloseArea())
	else
		
		BLE->(dbSetOrder(2)) //BLE_FILIAL+BLE_CODINT+BLE_CPADOC+BLE_CODOPC
		if BLE->(msSeek(xFilial("BLE")+cCodInt+cCodPad+cCodPro))
			
			while !BLE->(eof()) .and. xFilial("BLE")+cCodInt+cCodPad+cCodPro == BLE->(BLE_FILIAL+BLE_CODINT+BLE_CPADOC+BLE_CODOPC)
				
				dVigDe := BLE->BLE_VIGDE
				dVigAte:= BLE->BLE_VIGATE
				//-------------------------------------------------
				//| Indica se o eh intervalo valido											|
				//-------------------------------------------------
				if   !( ( !empty(dVigDe) .and. !empty(dVigAte) .and. ((dDatPro < dVigDe) .or. (dDatPro > dVigAte))) .or. ;
						( !empty(dVigDe) .and. empty(dVigAte) .and. dDatPro < dVigDe  ) .or.;
						( empty(dVigDe) .and. !empty(dVigAte) .and. dDatPro > dVigAte  ))  .and. BLE->BLE_ATIVO == '1'
					lCritIt := .t.
					
					aadd(aRet,{	BLE->BLE_CPADOC,;//01
								BLE->BLE_CODOPC,;//02
								BLE->BLE_TIPO,;//03
								BLE->BLE_VALCH,;//04
								BLE->BLE_VALFIX,;//05
								BLE->BLE_PRINCI,;//06
								BLE->BLE_VIGDE,;//07
								BLE->BLE_VIGATE,;//08
								BLE->BLE_COMPAR,;//09
								"BLE",;//10
								lCritIt})//11
					
					lFound	:= .t.
				endIf
				
			BLE->(dbSkip())
			endDo
			
		endIf
		
	endIf
	
endIf

eval(bRest)

return aRet

/*/{Protheus.doc} PLSRETPORTE
Retorna o Porte do Procedimento
@type function
@author PLSTEAM
@since 09.10.07
@version 1.0
/*/
function PLRETPORTE(cCodPad,cCodPro,cIntPad,cCodTab,dDatPro)
local cPorte	:= ""
local cUnidMed  := getNewPar("MV_PLUNPOR","PPM")//Define a unidade de medida para pesquisar Porte
local cSQL      := ""

default cCodPad := ""
default cCodPro := ""
default cIntPad := PLSINTPAD()
default cCodTab := ""
default dDatPro := stod("")

cCodTab := cIntPad+cCodTab

// Efetua busca...TDE
cSQL := "SELECT BD4_CODPRO,BD4_CODIGO,BD4_PORMED FROM " + retSqlName("BD4")
cSQL += " WHERE BD4_FILIAL = '"+xFilial("BD4")+"' AND "
cSQL += "       BD4_CODTAB = '"+cCodTab+"' AND BD4_CDPADP = '"+cCodPad+"'AND BD4_CODPRO = '"+cCodPro+"' AND "
cSQL += "       BD4_CODIGO = '"+cUnidMed+"' AND ((BD4_VIGINI <> ' ' AND BD4_VIGFIM <> ' ' AND "
cSQL += "       BD4_VIGINI <= '"+dtos(dDatPro)+"' AND BD4_VIGFIM >= '"+dtos(dDatPro)+"') OR BD4_VIGINI = ' ' AND "
cSQL += "       BD4_VIGFIM = ' ') AND D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",tcGenQry(,,csql),"TrbPORTE",.F.,.T.)

if !TrbPORTE->(eof())
	cPorte := TrbPORTE->BD4_PORMED
else
	cPorte := ""
endIf

if existBlock("PLRETPOR")
	cPorte := execBlock("PLRETPOR",.f.,.f.,{cCodPad,cCodPro,cIntPad,cCodTab,dDatPro,cPorte})
endIf

TrbPORTE->(dbCloseArea())

//Abrir uma area para evitar erro de area not exist
DbSelectArea("BR8")

return (cPorte)

/*/{Protheus.doc} PLSPARCOP
Parcelamento de Co-Participação
@type function
@author PLSTEAM
@since 02.01.08
@version 1.0
/*/
function PLSPARCOP(cTipo,cNextFase,cChaveGui,cMatricUsr)
local nI			:= 0
local cCodLanBSQ	:= ""
local nVlrParcela	:= 0
local cMesAux		:= ""
local cAnoAux		:= ""
local cCodSeq		:= ""
local cSql			:= ""
local _nH
local aNivel		:= {}
local cAnoTel 		:= space(TamSX3("BD5_ANOPAG")[1])	//Pega o tamanho do campo mes da tabela BD5
local cMesTel 		:= space(TamSX3("BD5_MESPAG")[1])	//Pega o tamanho do cmapo ano da tabela BD5
local lGuiaTel		:= iIf(IsInCallStack("PLSA500FAS") .Or. IsInCallStack("PLSA500ACT"), .t., .f.)

aNivel := PLSRETNCB(subStr(cMatricUsr,1,4),SubStr(cMatricUsr,5,4),SubStr(cMatricUsr,9,6),nil)

// fase pronta
if cNextFase == PRONTA

	// Pesquisa o codigo do tipo de deb/cred relacionado ao lanc. de
	// faturamento de parcelamento de Co-Participação (181)...
	cSql := "SELECT BSP_CODSER FROM "+retSqlName("BSP")+" WHERE BSP_FILIAL = '"+xFilial("BSQ")+"' "
	cSql += "AND BSP_CODLAN = '181' "
	cSql += "AND D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"TRBBSP",.F.,.T.)
  	
  	if !TRBBSP->(eof())
		cCodLanBSQ := TRBBSP->BSP_CODSER
	endIf	

	// Fecha area de trabalho temporaria...
	TRBBSP->(dbClosearea())
	
	if existBlock("PL720PCO")
		execBlock("PL720PCO",.f.,.f.)
	endIf
	
	nVlrParcela:= (BD5->BD5_VLRPF / BD5->BD5_NPARCE)
	
	cAnoAux	:=	BD5->BD5_ANOPAG
	cMesAux	:=	BD5->BD5_MESPAG
	
	_nH := PLSAbreSem("PL720DB.SMF")

	//Abre janela para digitacao de mes e ano auxiliar,
	//apenas se for mudanca de fase da guia.
	cMesTel	:= BD5->BD5_MESPAG
	cAnoTel	:= BD5->BD5_ANOPAG
	
	if lGuiaTel
		DEFINE MSDIALOG oDlgDT TITLE STR0120 FROM 0,0 TO 120,230 PIXEL	//"Data Inicial Lançamento"
		@ 010,002 Say STR0121 Size 030, 009 PIXEL COLOR CLR_BLUE				//"Mês Auxiliar: "
		@ 010,055 MSGet oEdit1 var cMesTel Picture "@!" Size 008, 009 OF oDlgDT PIXEL COLOR CLR_BLACK
		@ 025,002 Say STR0122 Size 030, 009 PIXEL COLOR CLR_BLUE				//"Ano Auxiliar: "
		@ 025,055 MSGet oEdit2 var cAnoTel Picture "@!" Size 015, 009 OF oDlgDT PIXEL COLOR CLR_BLACK
		oBtn1 := tButton():New(040,55,STR0123,,{|| lOk := PlsDTOK(cMesAux,cMesTel,cAnoAux,cAnoTel), iIf(lOk, oDlgDT:End(), MsgStop(STR0125))},048,014,,,,.t.)  //"Confirmar"###"Verifique as informações digitadas."
		ACTIVATE MSDIALOG oDlgDT CENTERED
		
		cAnoAux := cAnoTel
		cMesAux := cMesTel
	endIf
	
	for nI:= 1 to BD5->BD5_NPARCE
		
		cCodSeq := PLSA625Cd("BSQ_CODSEQ","BSQ",1,"D_E_L_E_T_"," ")
		
		BSQ->(recLock("BSQ",.t.))
		
		BSQ->BSQ_FILIAL := xFilial("BSQ")
		BSQ->BSQ_CODSEQ := cCodSeq
		BSQ->BSQ_USUARI := IIF(FindFunction("StrTPLS"),cMatricUsr + Modulo11(StrTPLS(cMatricUsr)),cMatricUsr + Modulo11(cMatricUsr))
		BSQ->BSQ_CODINT := BD5->BD5_CODOPE
		BSQ->BSQ_CODEMP := BD5->BD5_CODEMP
		BSQ->BSQ_CONEMP := BD5->BD5_CONEMP
		BSQ->BSQ_VERCON := BD5->BD5_VERCON
		BSQ->BSQ_SUBCON := BD5->BD5_SUBCON
		BSQ->BSQ_VERSUB := BD5->BD5_VERSUB
		BSQ->BSQ_MATRIC := BD5->BD5_MATRIC
		BSQ->BSQ_TIPO   := Posicione("BSP",1,xFilial("BSP")+cCodLanBSQ,"BSP_TIPSER")
		BSQ->BSQ_CODLAN := cCodLanBSQ
		BSQ->BSQ_VALOR  := nVlrParcela
		BSQ->BSQ_GUIA   := cChaveGui
		BSQ->BSQ_ANO    := cAnoAux
		BSQ->BSQ_MES    := cMesAux
		BSQ->BSQ_NPARCE := allTrim(strZero(nI,2))
		BSQ->BSQ_COBNIV	:= iIf(aNivel[1],aNivel[5],"")
		BSQ->BSQ_AUTOMA	:= "1"
		BSQ->BSQ_OBS	:= STR0124
		
		BSQ->(msUnLock())
		
		if cMesAux == "12"
			cMesAux := "01"
			cAnoAux := allTrim(str(Val(cAnoAux)+1))
		else
			cMesAux := strZero(Val(cMesAux)+1,2)
		endIf
		
	next nI
	
	PLSFechaSem(_nH,"PL720DB.SMF")
	
	// para não gerar co participação no BDH
	if getNewPar("MV_PLSGCGP","0") == "1"
		
		cSql := " UPDATE " + retSqlName("BD6") + " SET BD6_BLOCPA = '1',BD6_VLRPF=0 WHERE "
		cSql += " BD6_FILIAL = '" + xFilial("BD6")  + "' AND "
		cSql += " BD6_CODOPE = '" + BD5->BD5_CODOPE + "' AND "
		cSql += " BD6_CODLDP = '" + BD5->BD5_CODLDP + "' AND "
		cSql += " BD6_CODPEG = '" + BD5->BD5_CODPEG + "' AND "
		cSql += " BD6_NUMERO = '" + BD5->BD5_NUMERO + "' AND "
		cSql += " BD6_ORIMOV = '" + BD5->BD5_ORIMOV + "' AND "
		cSql += " D_E_L_E_T_ = ' ' "
		
		if TCSQLExec(cSql) < 0

    		FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', "TCSQLError() " + TCSQLError() , 0, 0, {})

		elseIf allTrim( TCGetDB() ) == "ORACLE"

			TCSQLExec("COMMIT")

		endIf
		
	endIf
	
// QUANDO for RETORNAR A FASE
elseIf cTipo == RETORNAFASE .and. cNextFase == DIGITACAO

	//Deleta os debitos de parcelamento da guia criados no BSQ
	cSql := " UPDATE " + retSqlName("BSQ") + " SET D_E_L_E_T_ = '*' "
	cSql += "  WHERE BSQ_FILIAL = '" + xFilial("BSQ") + "' AND "
	cSql += "        BSQ_GUIA   = '" + cChaveGui + "' AND "
	cSql += "        D_E_L_E_T_ = ' ' "
	
	if TCSQLExec(cSql) < 0

		FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', "TCSQLError() " + TCSQLError() , 0, 0, {})

	elseIf allTrim( TCGetDB() ) == "ORACLE"

		TCSQLExec("COMMIT")

	endIf
	
	// para gerar co participação no BDH
	cSql := " UPDATE " + retSqlName("BD6") + " SET BD6_BLOCPA = '0' WHERE "
	cSql += " BD6_FILIAL = '" + xFilial("BD6")  + "' AND "
	cSql += " BD6_CODOPE = '" + BD5->BD5_CODOPE + "' AND "
	cSql += " BD6_CODLDP = '" + BD5->BD5_CODLDP + "' AND "
	cSql += " BD6_CODPEG = '" + BD5->BD5_CODPEG + "' AND "
	cSql += " BD6_NUMERO = '" + BD5->BD5_NUMERO + "' AND "
	cSql += " BD6_ORIMOV = '" + BD5->BD5_ORIMOV + "' AND "
	cSql += " D_E_L_E_T_ = ' ' "
	
	if TCSQLExec(cSql) < 0

		FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', "TCSQLError() " + TCSQLError() , 0, 0, {})

	elseIf allTrim( TCGetDB() ) == "ORACLE"

		TCSQLExec("COMMIT")

	endIf
	
endIf

return

/*/{Protheus.doc} PLSVALPARC
Validação de Parcelamento de Co-Participação
@type function
@author PLSTEAM
@since 02.01.08
@version 1.0
/*/
function PLSVALPARC(aRetCom,lValido,cLocalExec)
local nCount      := 0
local aDados      := {}
local cCodLanBSQ  := ""
local cSql        := ""
local nI          := 0
local nVlMinPar   := getNewPar("MV_PLVLMPA",10)

// Pesquisa o codigo do tipo de deb/cred relacionado ao lanc. de
// faturamento de parcelamento de Co-Participação (181)...
cSql := "SELECT BSP_CODSER FROM "+retSqlName("BSP")+" WHERE BSP_FILIAL = '"+xFilial("BSQ")+"' "
cSql += "AND BSP_CODLAN = '181' "
cSql += "AND D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"TRBBSP",.F.,.T.)

// Conta os registros obtidos... permitido no maximo 1 registro...
if !TRBBSP->(eof())
	TRBBSP->( dbEval({|| nCount ++ }) )
endIf	

// Verifica se o retorno eh valido...
if nCount == 0
	
	PLSPOSGLO(PLSINTPAD(),__aCdCri032[1],__aCdCri032[2],cLocalExec)
	aadd(aRetCom,{{__aCdCri032[1],STR0103,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","","",""}}) //"Não existe cadastrado nenhum TIPO DE LANC. DE DÉBITO relacionado ao código '181' referente DÉBITO, para gerar o Parcelamento de Co-Participação."
	lValido := .f.
	
elseIf nCount > 1

	PLSPOSGLO(PLSINTPAD(),__aCdCri032[1],__aCdCri032[2],cLocalExec)
	aadd(aRetCom,{{__aCdCri032[1],STR0104,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","","",""}}) //"Existe mais de um TIPO DE LANC. DE DÉBITO relacionado ao código '181'referente DÉBITO, para gerar o Parcelamento de Co-Participação."
	lValido := .f.
	
endIf

// Fecha area de trabalho temporaria...
TRBBSP->(dbClosearea())

if round( BD5->BD5_VLRPF / BD5->BD5_NPARCE, PLGetDec('BD5_VLRPF') ) < nVlMinPar

	PLSPOSGLO(PLSINTPAD(),__aCdCri032[1],__aCdCri032[2],cLocalExec)
	aadd(aRetCom,{{__aCdCri032[1],STR0105+"   "+ allTrim(str(nVlMinPar,17,2))+"   "+STR0106+"   "+allTrim(str(round(BD5->BD5_VLRPF/BD5->BD5_NPARCE,PLGetDec('BD5_VLRPF')))),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"","","",""}}) //"O Valor da parcela de Co-Participação gerada é inferior ao valor minino informado no parametro MV_PLVLMPA que indica"###"e o valor das parcelas é de"
	lValido := .f.
	
endIf

//para evitar erro de área já em uso.
dbSelectArea("BD5")

return (aRetCom)

/*/{Protheus.doc} PLSVLDPARC
Valid Num Parcela de Co-Participação
@type function
@author PLSTEAM
@since 08.01.08
@version 1.0
/*/
function PLSVLDPARC(cNumParc)
local lRet     := .t.
local nMaxPar  := getNewPar("MV_PLNMADI",8)

if cNumParc > nMaxPar
	msgStop(STR0107+"   "+allTrim(str(nMaxPar,2))+"   "+STR0108+"   "+allTrim(str(cNumParc))) //"A quantidade de parcela supera o limite informado no parametro MV_PLNMADI que indica"###"e o campo Número de parcelas está com"
	lRet := .f.
endIf

return(lRet)

/*/{Protheus.doc} PL720BOk
@type function
@author PLSTEAM
@since 08.01.08
@version 1.0
/*/
function PL720BOk()
local lRet 	  := .t.
local cAliIte := "BD6"

If type("M->"+cAliIte+"_CODPRO") <> "U" .and. &("M->"+cAliIte+"_CODPRO") == BR8->BR8_CODPSA .AND. BR8->BR8_ODONTO == "1" .AND. BCI->BCI_TIPGUI <> "13"
	MsgStop("Procedimentos configurados como odontológico apenas podem ser utilizados em guias odontológicas")
	lRet := .F.
endif

//Verifica se tem dente a ser informado
if type("M->"+cAliIte+"_CODPAD") <> "U" .and. type("M->"+cAliIte+"_CODPRO") <> "U" .and. type("M->"+cAliIte+"_DENREG") <> "U"

	B05->( dbSetOrder(1) )//B05_FILIAL + B05_CODPAD + B05_CODPSA + B05_CODIGO + B05_TIPO

	if B05->( msSeek( xFilial("B05")+&("M->"+cAliIte+"_CODPAD")+&("M->"+cAliIte+"_CODPRO") ) ) .and. empty( &("M->"+cAliIte+"_DENREG") )
		MsgStop(STR0115) //"Será necessário informar o dente/região para este procedimento."
		lRet := .f.
	endIf
	
endIf

//Verifica se tem face a ser informado
if Type("M->"+cAliIte+"_CODPAD") <> "U" .and. Type("M->"+cAliIte+"_DENREG") <> "U" .and. Type("M->"+cAliIte+"_FADENT") <> "U"
	
	BYL->(dbSetOrder(1))
	if BYL->(msSeek(xFilial("BYL")+&("M->"+cAliIte+"_CODPAD")+&("M->"+cAliIte+"_CODPRO")+&("M->"+cAliIte+"_DENREG"))) .and. empty(&("M->"+cAliIte+"_FADENT"))
		MsgStop(STR0112)//"Será necessário informar a(s) face(s) dentária(s) para este procedimento."
		lRet := .f.
	endIf
	
endIf

return lRet

/*/{Protheus.doc} LancFtCpo
@type function
@author PLSTEAM
@since 08.01.08
@version 1.0
/*/
function LancFtCpo(nFuncao)
local aRet := {}
/*
[1] = Nome do campo BDH
[2] = Codigo de lancamento de faturamento
[3] = Posicao da matriz de retorno do PLTIPATO.

Lancamentos de faturamento de Co-Participação:
116, 147, 148, 149, 150, 151, 152,153, 154, 155, 182, 183

Lancamentos de faturamento de Custo Operacional:
104, 127, 134, 137, 138, 139, 140, 141, 142, 143, 144, 145, 182, 183
*/

if nFuncao == 1
	aRet := {;
		{"BDH_VALOR" ,"116",1},;
		{"BDH_VALOR1","147",4},;
		{"BDH_VALOR2","148",5},;
		{"BDH_VALOR3","149",6},;
		{"BDH_VALOR4","150",7},;
		{"BDH_VALOR5","151",8},;
		{"BDH_VALOR6","152",9},;
		{"BDH_VALOR7","153",10},;
		{"BDH_VALOR8","154",11},;
		{"BDH_VALOR9","155",12},;
		{"BDH_VLRTIM","182",13},;
		{"BDH_VLRPES","183",14}}
elseIf nFuncao == 2
	aRet := {;
		{"BDH_VLRT21","168",1},;
		{"BDH_VLRT24","169",4},;
		{"BDH_VLRT25","170",5},;
		{"BDH_VLRT26","171",6},;
		{"BDH_VLRT27","172",7},;
		{"BDH_VLRT28","173",8},;
		{"BDH_VLRT29","174",9},;
		{"BDH_VLRT2A","175",10},;
		{"BDH_VLRT2B","176",11},;
		{"BDH_VLRT2C","177",12}}
elseIf nFuncao == 3
	aRet := {;
		{"BDH_VLRCOP","104",1},;
		{"BDH_VLRCP2","127",2},;
		{"BDH_VLRCP3","134",3},;
		{"BDH_VLRCP4","137",4},;
		{"BDH_VLRCP5","138",5},;
		{"BDH_VLRCP6","139",6},;
		{"BDH_VLRCP7","140",7},;
		{"BDH_VLRCP8","141",8},;
		{"BDH_VLRCP9","142",9},;
		{"BDH_VLRCPA","143",10},;
		{"BDH_VLRCPB","144",11},;
		{"BDH_VLRCPC","145",12},;
		{"BDH_VLRTIM","182",13},;
		{"BDH_VLRPES","183",14}}
elseIf nFuncao == 4
	aRet := {;
		{"BDH_VLRT11","156",1},;
		{"BDH_VLRT12","157",2},;
		{"BDH_VLRT13","158",3},;
		{"BDH_VLRT14","159",4},;
		{"BDH_VLRT15","160",5},;
		{"BDH_VLRT16","161",6},;
		{"BDH_VLRT17","162",7},;
		{"BDH_VLRT18","163",8},;
		{"BDH_VLRT19","164",9},;
		{"BDH_VLRT1A","165",10},;
		{"BDH_VLRT1B","166",11},;
		{"BDH_VLRT1C","167",12},;
		{"BDH_VLRTIM","182",13},;
		{"BDH_VLRPES","183",14}}
endIf

return(aRet)

/*/{Protheus.doc} PlRtLBXZ
@type function
@author PLSTEAM
@since 08.01.08
@version 1.0
/*/
function PlRtLBXZ()
local cSQL     := ""
local cFilBXZ  := xFilial("BXZ")

//tratamento de performance
// o reccount nao faz acesso ao banco de dados..
__aLanBXZ := {}
if len(__aLanBXZ) != BXZ->(Reccount())
	
	//propositalmente neste ponto nao trata a filial nem d_e_l_e_t_, para efeito de otimizacao
	//visto que o reccount() nao considera filial nem d_e_l_e_t_
	//o tratamento da filial e do d_e_l_e_t_ vai ser lah embaixo
	cSQL := "SELECT BXZ_CODOPE,BXZ_CODLAN,BXZ_CODLOC,BXZ_CODPAD,"
	cSQL += "BXZ_CODPSA,BXZ_CODPRO,BXZ_VERPRO,BXZ_SUBCON,BXZ_TIPSER,"
	cSQL += "D_E_L_E_T_ del,BXZ_FILIAL fil FROM "+retSqlName("BXZ")
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.t.,"TOPCONN",TCGENQRY(,,cSQL),"PLSBUSBXZ",.f.,.t.)
	
	PLSBUSBXZ->(DBEval( { | | aadd(__aLanBXZ, {	BXZ_CODOPE,BXZ_CODLAN,BXZ_CODLOC,;
												BXZ_CODPAD,BXZ_CODPSA,BXZ_CODPRO,;
												BXZ_VERPRO,BXZ_SUBCON,;
												del,fil,BXZ_TIPSER}) }))
	
	PLSBUSBXZ->(DBEval( { | | aadd(__aLanFil, {	BXZ_CODOPE,BXZ_CODLAN,BXZ_CODLOC,;
												BXZ_CODPAD,BXZ_CODPSA,BXZ_CODPRO,;
												BXZ_VERPRO,BXZ_SUBCON,;
												del,fil,BXZ_TIPSER})}, {|| empty(del) .and. fil == cFilBXZ} ))
	
	PLSBUSBXZ->(DbCloseArea())
endIf

return __aLanFil

/*/{Protheus.doc} PLSGRVHORE
Gravacao
@type function
@author PLSTEAM
@since 12.03.10
@version 1.0
/*/
function PLSGRVHORE(cNumPeg,cLocalExec,cTipoGrv,dDatPro,cHora,aItens,aUnMed,cOrimov,;
					cOpeMov,cMatric,cCodPSol,cCodPExe,cNumImp,cTipPre,cCodRda,cCodLDP,;
					cTipo,cCodLoc,cCodEsp,cTipoGuia,cCid,nQtNasV,nQtNasM,nQtNasP,nQtObtP,nQtObAR,cTipFat,;
					cCidObt,cNrdCob,cObtMul,cTipAlt,cNrdCnv,cLotGui,cArqImp,cNFSS,cNumLib,aTipPart)

local nFor			:= 0
local nPos			:= 0
local nI			:= 1
local nForCpo 		:= 1
local nForY 		:= 1
local cSeqMov 		:= ""
local cCodPad 		:= ""
local cCodPro 		:= ""
local cDescri		:= ""
local nQtdPro 		:= ""
local cHorIni 		:= ""
local cHorFim 		:= ""
local dDtProIte		:= ""
local nVlrApr		:= ""
local cDente  		:= ""
local cFace   		:= ""
local cAliasPLS		:= "BE4"
local lNCir	 		:= .f.
local lRet			:= .t.

default dDatPro 	:= stod('')
default cHora       := ""
default aUnMed      := PLSXBKC()

BE4->( dbSetOrder(1) )
if BE4->( msSeek( xFilial(cAliasPLS)+cNumPeg ) )//pesquiso a solicitacao
	
	if ( allTrim(cTipFat) == 'P' .or. alltrim(cTipFat) == '1' ) //se for faturamento parcial eu crio uma nova gih vinculada a gih principal
		
		PLSICM(cOpeMov,cMatric,cTipoGrv,cLocalExec,cCodPSol,cCodPExe,dDatPro,cHora,cNumImp,cCodRda,;
				cCodLDP,cTipo,cCodLoc,cCodEsp,cTipoGuia,cCid,nQtNasV,nQtNasM,nQtNasP,nQtObtP,nQtObAR,cTipFat,;
				cCidObt,cNrdCob,cObtMul,cTipAlt,cNrdCnv,cLotGui,aItens,cArqImp,cNumLib,aTipPart,;
				"BE4",.f.,'2')
		
		return lRet
	endIf
	
	
	//operadoras querem carregar todos eventos das internações independente do que existe na solicitação
	if getNewPar("MV_PDELBDS",'1') == '1'
		
		cChaveGui := xFilial(cAliasPLS)+cNumPeg+cOrimov
		
		cSQL := "SELECT R_E_C_N_O_ REC FROM "+retSqlName("BD6")+" WHERE "
		cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
		cSQL += "BD6_CODOPE = '"+&(cAliasPLS+"->"+cAliasPLS+"_CODOPE")+"' AND "
		cSQL += "BD6_CODLDP = '"+&(cAliasPLS+"->"+cAliasPLS+"_CODLDP")+"' AND "
		cSQL += "BD6_CODPEG = '"+&(cAliasPLS+"->"+cAliasPLS+"_CODPEG")+"' AND "
		cSQL += "BD6_NUMERO = '"+&(cAliasPLS+"->"+cAliasPLS+"_NUMERO")+"' AND "
		cSQL += "BD6_ORIMOV = '"+&(cAliasPLS+"->"+cAliasPLS+"_ORIMOV")+"' AND "
		cSQL += "D_E_L_E_T_ = ' ' "
		
		dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"Trb",.F.,.T.)
  	
		BD7->(dbSetOrder(1))

		while ! Trb->(eof())
			
			BD6->(dbGoto(Trb->(REC)))

			while BD7->(msSeek(xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
				BD7->(recLock("BD7",.f.))
					BD7->(DbDelete())
				BD7->(msUnLock())
			endDo
			
			BD6->(recLock("BD6",.f.))
				BD6->(DbDelete())
			BD6->(msUnLock())
			
		Trb->(dbSkip())
		endDo
		
		Trb->(DbCloseArea())
		
	endIf
	
	for nFor := 1 To len(aItens)
		
		cSeqMov 	:= PLSRETDAD(aItens[nFor],"SEQMOV")
		cCodPad 	:= PLSRETDAD(aItens[nFor],"CODPAD")
		cCodPro 	:= PLSRETDAD(aItens[nFor],"CODPRO")
		cDescri		:= PLSRETDAD(aItens[nFor],"DESCRI","")
		nQtdPro 	:= PLSRETDAD(aItens[nFor],"QTDAUT",0)
		cHorIni 	:= PLSRETDAD(aItens[nFor],"HORINI",cHora)
		cHorFim 	:= PLSRETDAD(aItens[nFor],"HORFIM",cHora)
		dDtProIte	:= PLSRETDAD(aItens[nFor],"DATPRO",dDatPro)
		nVlrApr		:= PLSRETDAD(aItens[nFor],"VLRAPR",0)
		nVlrApr		:= PLSRETDAD(aItens[nFor],"VLRAPR",nVlrApr)
		aTpPIte		:= PLSRETDAD(aItens[nFor],"ATPPAR",{})
		
		BR8->( dbSetOrder(1) )
		BR8->( msSeek(xFilial("BR8")+cCodPad+cCodPro) )
		
		aCpoNiv := PLSUpCpoNv(cCodPad,cCodPro,"BD6")
		
		BD6->( recLock("BD6",.t.) )
		
		for nForY := 1 To len(aCpoNiv)
			&(aCpoNiv[nForY,1]) := (aCpoNiv[nForY,2])
		next
		
		BD6->BD6_FILIAL := xFilial("BD6")
		BD6->BD6_SEQUEN := cSeqMov
		BD6->BD6_CODPAD := cCodPad
		BD6->BD6_CODPRO := cCodPro
		BD6->BD6_DESPRO := cDescri
		BD6->BD6_NIVEL  := BR8->BR8_NIVEL
		
		BD6->BD6_DATPRO := dDtProIte
		BD6->BD6_QTDPRO := nQtdPro
		BD6->BD6_VLRAPR := nVlrApr
		
		BD6->BD6_VALORI := ( nVlrApr * nQtdPro )

		BD6->BD6_OPEORI := BA1->BA1_OPEORI
		BD6->BD6_CODPLA := BA3->BA3_CODPLA
		
		BD6->BD6_MODCOB := aDadUsr[48]
		BD6->BD6_TIPUSR := iIf( len(aDadUsr) >= 90, aDadUsr[90], "")
		BD6->BD6_INTERC := iIf( len(aDadUsr) >= 91, aDadUsr[91], "0")
		BD6->BD6_TIPINT := aDadUsr[43]

		BD6->BD6_INCAUT := "1"
		BD6->BD6_STATUS := "1"
		BD6->BD6_CHVNIV := ""
		BD6->BD6_NIVAUT := ""
		BD6->BD6_NRAOPE := cNumLib
		
		cAlias	 := "BE4"
		aCposPad := (cAlias)->( DbStruct() )
		
		for nForCpo := 1 To len(aCposPad)
			cMacro := ( "BD6->BD6_" + Subs( aCposPad[nForCpo,1],5,10 ) )
			
			if TYPE(cMacro) <> "U" .and. !(allTrim("BD6_" + Subs(aCposPad[nForCpo,1],5,10) ) $ "BD6_DATPRO,BD6_HORPRO,BD6_CNPJED,BD6_VLRAPR,BD6_VALORI,BD6_VLRPAG,BD6_VLRGLO,BD6_TPRDAE,BD6_QTDAPR,BD6_TIPUSR,BD6_RDAEDI,BD6_NOMEDI,BD6_TRDAED,BD6_RPEDI,BD6_ESPEDI,BD6_VLRMAN,BD6_VLRBPR")
				
				cCampoOri := (cAlias)->&( cAlias + "_" + Subs( aCposPad[nForCpo,1],5,10) )
				&(cMacro) := cCampoOri
				
			endIf
		next
		
		aCodTab := PLSRETTAB(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_DATPRO,;
							BD6->BD6_CODOPE,BD6->BD6_CODRDA,BD6->BD6_CODESP,BD6->BD6_SUBESP,BD6->(BD6_CODLOC+BD6_LOCAL),;
							BD6->BD6_DATPRO,"1",BD6->BD6_OPEORI,BD6->BD6_CODPLA,"2","1",nil,IIF(!Empty(BAU->BAU_TIPPRE),BAU->BAU_TIPPRE,nil),nil,nil,(BD6->BD6_TIPGUI==G_REEMBOLSO),;
							nil,nil,nil,nil,nil,nil,nil,BD6->BD6_CODEMP,BD6->BD6_ANOPAG,BD6->BD6_MESPAG)
		
		if aCodTab[1]
			BD6->BD6_CODTAB := aCodTab[3]
			BD6->BD6_ALIATB := aCodTab[4]
		endIf
		
		if !empty(cHorIni)
			BD6->BD6_HORPRO := cHorIni
		endIf
		
		if !empty(cHorFim)
			BD6->BD6_HORFIM := cHorFim
		endIf
		
		BD6->BD6_CONMUS := '0'//desconsidero a guia para tratamento de qtd x periodicidade
		
		BD6->( msUnLock() )
		
		PLS720IBD7('',BD6->BD6_VLPGMA,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODTAB,BD6->BD6_CODOPE,BD6->BD6_CODRDA,;
					BD6->BD6_REGEXE,BD6->BD6_SIGEXE,BD6->BD6_ESTEXE,BD6->BD6_CDPFRE,BD6->BD6_CODESP,BD6->(BD6_CODLOC+BD6_LOCAL),"1",BD6->BD6_SEQUEN,;
					BD6->BD6_ORIMOV,BD6->BD6_TIPGUI,BD6->BD6_DATPRO)
	next
endIf

return(lRet)

/*/{Protheus.doc} PLSPARBD7
@type function
@author PLSTEAM
@since 17.07.08
@version 1.0
/*/
function PLSPARBD7(cChave,aUnMed,aTpPIte,cLocalExec,cTipoGrv,lNCir,lBloq,cNumGui)
local nI 		:= 0
local cCodPar  	:= ""
local cCodRPar 	:= ""
local cNomRPar 	:= ""
local cCrmRPar 	:= ""
local cSlgRPar 	:= ""
local cEstRPar 	:= ""
local cNomEPar 	:= ""
local aAreaBAU	:= {}
local lAtuRDA	:= .f.
default lBloq	:= .f.
default lNCir	:= .f.
default cNumGui := .f.

//-------------------------------------------------
// Posiciona no bd7
//-------------------------------------------------
BD7->( dbSetOrder(1) ) //BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + BD7_NLANC
if BD7->( msSeek( xFilial("BD7")+cChave ) )
	while !BD7->( eof() ) .and. xFilial("BD7")+cChave == BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
		//-------------------------------------------------
		// Monta informacao da rda, executante e participacao
		//-------------------------------------------------
		if len(aTpPIte) > 0
			for nI:=1 To len(aTpPIte)
				if aTpPIte[nI,8] .Or. lNCir
					if Ascan( aUnMed,{ |x| x[1] == allTrim(BD7->BD7_CODUNM)+allTrim(aTpPIte[nI,1]) } ) > 0 .Or. (lNCir .and. !aTpPIte[nI,8])
						cCodPar  		:= allTrim(aTpPIte[nI,1])
						cCodRPar 		:= aTpPIte[nI,2]
						cNomRPar 		:= aTpPIte[nI,3]
						cSlgRPar 		:= aTpPIte[nI,5]
						cCrmRPar 		:= aTpPIte[nI,4]
						cEstRPar 	  	:= aTpPIte[nI,6]
						cNomEPar 	  	:= aTpPIte[nI,7]
						aTpPIte[nI,8]	:= .f.
						Exit
					endIf
				endIf
			next
		endIf
		//-------------------------------------------------
		// Se tem participacao atualiza o bd7
		//-------------------------------------------------
		if !empty(cCodPar)
			//-------------------------------------------------
			// Para definicao do pagamento do medico
			//-------------------------------------------------
			if empty(BD7->BD7_CODTPA) .Or. allTrim(BD7->BD7_CODTPA) == "0"
				
				BD7->( recLock("BD7",.f.) )
				
				BD7->BD7_CODTPA := cCodPar
				
				if !(len(AllTrim(cCodRPar)) > TamSX3("BAU_CODIGO")[1])
						
					aAreaBAU := BAU->(GetArea())
					
					BAU->(dbsetOrder(1))
					
					if BAU->(MsSeek(xFilial("BAU")+cCodRPar))
						lAtuRDA := .T.
					endIf
					
					BAU->(Restarea(aAreaBAU))
					
				endIf
					
				if !empty(cCodRPar)
					
					if lAtuRDA
						BD7->BD7_CODRDA := cCodRPar
						BD7->BD7_NOMRDA := cNomRPar
					endIf
					
					BD7->BD7_SIGLA  := cSlgRPar
					BD7->BD7_REGPRE := cCrmRPar
					BD7->BD7_ESTPRE := cEstRPar
					BD7->BD7_NOMPRE := cNomEPar
				endIf
				
				// Bloqueia a composicao do procedimento que tem equipe mais nao teve a participacaio definida na equipe
				if lBloq

					if len(aTpPIte) > 0 .and. cCodPar == "0" .and. PLSPOSGLO(PLSINTPAD(),__aCdCri169[1],__aCdCri169[2],cLocalExec,,cTipoGrv) .and. PLSCHKCRI( {'BAU',cCodRPar,__aCdCri169[1]} )
						PLBLOPC('BD7', .t., __aCdCri169[1], PLSBCTDESC())
					endIf
					
				endIf
				
				BD7->( msUnLock() )
			endIf
		endIf
		cCodPar  := ""
		cCodRPar := ""
		cCrmRPar := ""
		cSlgRPar := ""
		cEstRPar := ""
		cNomRPar := ""
		cNomEPar := ""
		BD7->( dbSkip() )
	endDo
endIf

return

/*/{Protheus.doc} PlRetPerGl
Retorna o total de glosa quando e analise de glosa por critica
@type function
@author PLSTEAM
@since 29.06.11
@version 1.0
/*/
function PlRetPerGl(aItensGlo)
local aArea			:= getArea()
local nI 			:= 0
local nPercGlo 		:= 0

default aItensGlo 	:= {}

// Pego a participacao
if empty(BD7->BD7_CODTPA)
	cGrauPa := PLSGrauUM(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD7->BD7_CODUNM,BD6->BD6_DATPRO,"2")[2]
else
	cGrauPa := BD7->BD7_CODTPA
endIf

// Analiso as glosas
for nI := 1 to len(aItensGlo)
	
	if (aItensGlo[nI,3] + aItensGlo[nI,2] != 0) .and. aItensGlo[nI,11] == '1'

		// Mesma sequencia e foi analisado pela critica
		if aItensGlo[nI,1] == BD6->BD6_SEQUEN .and. aItensGlo[nI,8] == "2" .and. ( (aItensGlo[nI,9] == cGrauPa) .or. empty(aItensGlo[nI,9]) )

			nPercGlo += aItensGlo[nI,15]
			
			if nPercGlo >= 100
				nPercGlo := 100
				Exit
			endIf
			
		endIf
		
	endIf
	
next nI

restArea(aArea)

return nPercGlo

/*/{Protheus.doc} PlsDTOK
Valida o mes e ano digitado para geracao do debito/credito com parcelamento de co-participacao.
@type function
@author PLSTEAM
@since 12/07/10
@version 1.0
/*/
static function PlsDTOK(cMesAux,cMesTel,cAnoAux,cAnoTel)
local lRet := .t.

if cMesTel < cMesAux .and. cAnoTel <= cAnoAux
	lRet := .f.
endIf

if cAnoTel < cAnoAux
	lRet := .f.
endIf

if !cMesTel $ ('01/02/03/04/05/06/07/08/09/10/11/12')
	lRet := .f.
endIf

if empty(cMesTel) .Or. empty(cAnoTel)
	lRet := .f.
endIf

return(lRet)

/*/{Protheus.doc} PLSB47BD7
Grava BD7 em funcao da matriz
@type function
@author PLSTEAM
@since 19/08/11
@version 1.0
/*/
static function PLSB47BD7(aHeadB47,aColsB47,cChvProc,nVlTotGlo)
local aArea     := getArea()
local nForCpo 	:= 1
local nForHea	:= 1
local cMacro	:= ""
local nPosLanc  := aScan(aHeadB47,{|x| allTrim(x[2]) == "B47_NLANC"})
local lFoundBD7	:= .F.	 

default cChvProc    := ""
default nVlTotGlo	:= 0 

BD7->(dbSetOrder(2))//BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_CODPAD + BD7_CODPRO + BD7_CODUNM + BD7_NLANC

BD7->(dbSetOrder(2))//BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_CODPAD + BD7_CODPRO + BD7_CODUNM + BD7_NLANC
//-------------------------------------------------
// Grava os BD7 com base nos B47
//-------------------------------------------------
for nForCpo := 1 To len(aColsB47)
	
	if !aColsB47[nForCpo,len(aColsB47[nForCpo])] .and. !empty(aColsB47[nForCpo,2]) .and. !BD7->(msSeek(BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO+aColsB47[nForCpo,2]+aColsB47[nForCpo,nPosLanc]))) .and. BD7->BD7_SEQUEN == BD6->BD6_SEQUEN
		
		if !empty(cChvProc)
			
			nPosCodPad := aScan(aHeadB47,{|x| x[2] == "B47_CODPAD"})
			nPosCodPro := aScan(aHeadB47,{|x| x[2] == "B47_CODPRO"})
			nPosSequen := aScan(aHeadB47,{|x| x[2] == "B47_SEQUEN"})
			
			if AllTrim(cChvProc) != allTrim(aColsB47[nForCpo,nPosSequen]+aColsB47[nForCpo,nPosCodPad]+aColsB47[nForCpo,nPosCodPro])
				loop
			endIf
			
		endIf
		
		BD7->( recLock("BD7",.t.) )
		//-------------------------------------------------
		// Compatibiliza campos identicos da acols
		//-------------------------------------------------
		for nForHea := 1 To len(aHeadB47)
			
			cMacro  := strTran("B47->"+aHeadB47[nForHea][2],"B47","BD7")
			
			if BD7->(fieldPos(strTran(aHeadB47[nForHea][2],"B47","BD7"))) > 0
				&cMacro := aColsB47[nForCpo][nForHea]
			endIf
		next
		//-------------------------------------------------
		// Compatibiliza campos identicos do bd6
		//-------------------------------------------------
		BD7->BD7_FILIAL := BD6->BD6_FILIAL
		BD7->BD7_CODOPE := BD6->BD6_CODOPE
		BD7->BD7_CODLDP := BD6->BD6_CODLDP
		BD7->BD7_CODPEG := BD6->BD6_CODPEG
		BD7->BD7_NUMERO := BD6->BD6_NUMERO
		BD7->BD7_ORIMOV := BD6->BD6_ORIMOV
		BD7->BD7_OPEUSR := BD6->BD6_OPEUSR
		BD7->BD7_CODEMP := BD6->BD6_CODEMP
		BD7->BD7_MATRIC := BD6->BD6_MATRIC
		BD7->BD7_TIPREG := BD6->BD6_TIPREG
		BD7->BD7_CODEMP := BD6->BD6_CODEMP
		BD7->BD7_CODPLA := BD6->BD6_CODPLA
		
		BD7->BD7_MODCOB := BD6->BD6_MODCOB
		BD7->BD7_TIPUSR := BD6->BD6_TIPUSR
		BD7->BD7_INTERC := BD6->BD6_INTERC
		BD7->BD7_TIPINT := BD6->BD6_TIPINT
		
		BD7->BD7_USUINT := BD6->BD6_USUINT
		BD7->BD7_CC     := BD6->BD6_CC
		BD7->BD7_SEQIMP := BD6->BD6_SEQIMP
		BD7->BD7_CLAINS := PLSCLAINS()
		BD7->BD7_NOMUSR := BD6->BD6_NOMUSR                                                      
		BD7->BD7_CODLOC := BD6->BD6_CODLOC
		BD7->BD7_LOCAL  := BD6->BD6_LOCAL
		BD7->BD7_DESLOC := BD6->BD6_DESLOC
		BD7->BD7_CODRDA := BD6->BD6_CODRDA
		BD7->BD7_NOMRDA := BD6->BD6_NOMRDA
		BD7->BD7_SIGLA  := BD6->BD6_SIGLA
		BD7->BD7_CODESP := BD6->BD6_CODESP
		BD7->BD7_DESESP := BAQ->(Posicione("BAQ",1,xFilial("BAQ")+BD6->(BD6_OPERDA+BD6_CODESP),"BAQ_DESCRI"))
		BD7->BD7_TIPGUI := BD6->BD6_TIPGUI
		BD7->BD7_CID    := BD6->BD6_CID
		BD7->BD7_FASE   := BD6->BD6_FASE
		BD7->BD7_SITUAC := BD6->BD6_SITUAC
		BD7->BD7_TPGRV  := BD6->BD6_TPGRV
		BD7->BD7_CODPLA := BD6->BD6_CODPLA
		BD7->BD7_ANOPAG := BD6->BD6_ANOPAG
		BD7->BD7_MESPAG := BD6->BD6_MESPAG
		BD7->BD7_DATPRO := BD6->BD6_DATPRO
		BD7->BD7_DATPRO := BD6->BD6_DATPRO
		BD7->BD7_NUMIMP := BD6->BD6_NUMIMP
		BD7->BD7_LOCATE := BD6->BD6_CODLOC + BD6->BD6_LOCAL
		BD7->BD7_LIBERA := BD6->BD6_LIBERA 
		//-------------------------------------------------
		// Informacao do Profissional Executante
		//-------------------------------------------------
		if !empty(BD6->BD6_CDPFRE)
			BD7->BD7_SIGLA  := BD6->BD6_SIGEXE
			BD7->BD7_REGPRE := BD6->BD6_REGEXE
			BD7->BD7_ESTPRE := BD6->BD6_ESTEXE
			
			BD7->BD7_NOMPRE := BR8->( Posicione("BB0",1,xFilial("BB0")+BD6->BD6_CDPFRE,"BB0_NOME") )
		endIf
		BD7->BD7_CDPFPR := BD6->BD6_CDPFRE
		BD7->( msUnLock() )
		BD7->(confirmSX8())

		nVlTotGlo += BD7->BD7_VLRGLO

	endIf
next

restArea(aArea)

return

/*/{Protheus.doc} PlRetAlias
Retorna o Alias com base no tipo de guia
@type function
@author PLSTEAM
@since 08/08/13
@version 1.0
/*/
function PlRetAlias(cCodOpe,cTipoGuia)
local cAliasRet := ""

if cTipoGuia $ ("01;02;04;06;10;13")
	cAliasRet := "BD5"
elseif cTipoGuia $ ("03;05")
	cAliasRet := "BE4"
elseif cTipoGuia $ ("07;08;09")
	cAliasRet := "B4A"
elseif cTipoGuia == "11"
	cAliasRet := "B4Q"
elseif cTipoGuia == "12"
	cAliasRet := "BD6"
endif

return(cAliasRet)

/*/{Protheus.doc} pBusAuGui
Busca os honorarios de uma guia
@type function
@author PLSTEAM
@since 06/09/13
@version 1.0
/*/
function pBusAuGui(cAlias, lCirurgico, cTipoGuia, cMVPLSCHMP, cMVPLSCHMA, lRdaAux)
local aRdaAux  := {}
local aAreaBD5 := {}
local aAreaBE4 := {}
local aAreaBD7 := {}
local aAreaBAU := {}

local cSql 	  	:= ''
local cGuiInt 	:= ''
local lFoundBD5 := .f.
local lFoundBE4 := .f.

if cTipoGuia == G_HONORARIO
	
	cGuiInt := (cAlias)->&( cAlias + "_GUIINT" )
	
elseIf cTipoGuia $ G_SADT + "|" + G_REC_GLOSA 
	
	cGuiInt := (cAlias)->&( cAlias + "_NRLBOR" )
	
endIf

cSql := " SELECT BD7.R_E_C_N_O_ RECBD7, BD6.R_E_C_N_O_ RECBD6 "
cSql += "   FROM " + retSqlName("BD7") + " BD7 ," + retSqlName("BD6") + " BD6 "
cSql += "  WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND "
cSql += " 	     BD7_OPEUSR = '"+BD6->BD6_OPEUSR+"' AND "
cSql += " 	     BD7_CODEMP = '"+BD6->BD6_CODEMP+"' AND "
cSql += " 	     BD7_MATRIC = '"+BD6->BD6_MATRIC+"' AND "
cSql += " 	     BD7_TIPREG = '"+BD6->BD6_TIPREG+"' AND "
cSql += " 	     BD7_CODPAD = '"+BD6->BD6_CODPAD+"' AND "
cSql += " 	     BD7_CODPRO = '"+BD6->BD6_CODPRO+"' AND "

cSql += " 	     BD6_FILIAL = '" + xFilial("BD6") + "' AND "
cSql += " 	     BD6_CODOPE = BD7_CODOPE AND "
cSql += " 	     BD6_CODLDP = BD7_CODLDP AND "
cSql += " 	     BD6_CODPEG = BD7_CODPEG AND "
cSql += " 	     BD6_NUMERO = BD7_NUMERO AND "
cSql += " 	     BD6_ORIMOV = BD7_ORIMOV AND "

cSql += " 	     BD6_SEQUEN = BD7_SEQUEN AND "
cSql += " 	     BD6_CODPAD = BD7_CODPAD AND "
cSql += " 	     BD6_CODPRO = BD7_CODPRO AND "
cSql += " 	     BD6_DATPRO = '" + dtos(BD6->BD6_DATPRO) + "' AND "
cSql += " 	     BD6_HORPRO = '" + BD6->BD6_HORPRO + "' AND "
cSql += " 	     BD6.R_E_C_N_O_ <> " + allTrim(str(BD6->(recno()))) + " AND "

if cTipoGuia == G_HONORARIO
	cSql += " BD6_NUMERO <> '" + BD6->BD6_NUMERO + "' AND "//so vou buscar em outras guias...
endIf

//auxiliares
if lRdaAux

	cRet := strTran(cMVPLSCHMP, ",", "','")
	cSql += " BD7_CODUNM IN ('" + cRet + "') AND "

//auxiliar do anestesista
else

	cRet := strTran(cMVPLSCHMA, ",", "','")
	cSql += " BD7_CODUNM IN ('"+ cRet + "') AND "

endIf

cSql += " BD7.BD7_BLOPAG <> '1' AND "
cSql += " BD7.D_E_L_E_T_ = ' '  AND "
cSql += " BD6.D_E_L_E_T_ = ' '  "

dbUseArea(.T.,"TOPCONN",tcGenQry(,,csql),"PGetBd7",.F.,.T.)

if  !PGetBd7->(eof())

	aAreaBD5 := BD5->(getArea())
	aAreaBE4 := BE4->(getArea())
	aAreaBD7 := BD7->(getArea())
	aAreaBAU := BAU->(getArea())
	
	BD5->(dbSetOrder(1))
	BE4->(dbSetOrder(1))
	BAU->(dbSetOrder(1))
	
	while !PGetBd7->(eof())
	
		BD7->(dbGoto(PGetBd7->RECBD7))
		
		lFoundBD5 := BD5->(msSeek(xFilial('BD5') + BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)))
		lFoundBE4 := BE4->(msSeek(xFilial('BE4') + BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)))
	
		if  ( cTipoGuia == G_HONORARIO .and. ;
			( ( lFoundBD5 .and. allTrim(BD5->BD5_GUIINT) == allTrim(cGuiInt) .and. !empty(cGuiInt)) .or. ( lFoundBE4 .and. allTrim(BE4->BE4_GUIINT) == allTrim(cGuiInt) .and. !empty(cGuiInt))) ) .or.;
			( cTipoGuia == G_SADT .and. ( lFoundBD5 .and. allTrim(BD5->BD5_NRLBOR) == allTrim(cGuiInt) .and. !empty(cGuiInt)) )
			
			BAU->(msSeek( xFilial("BAU") + BD7->BD7_CODRDA))
	
			aadd(aRdaAux,{  BD7->BD7_CODUNM,;
							BD7->BD7_CODRDA,;
							BD6->BD6_CODLOC,;
							BD7->BD7_CODESP,;
							0,;
							BAU->BAU_TIPPRE,;
							BD7->BD7_VLRAPR,;
							iIf(lCirurgico,BD7->BD7_PERVIA,0),;
							BD7->BD7_NLANC,;
							BD7->BD7_CONSFT})
			exit
		endIf
		
	PGetBd7->(dbSkip())
	endDo
	
	BD5->(restArea(aAreaBD5))
	BE4->(restArea(aAreaBE4))
	BD7->(restArea(aAreaBD7))
	BAU->(restArea(aAreaBAU))
	
endIf
PGetBd7->(DbCloseArea())

return aRdaAux

/*/{Protheus.doc} CompProtoc
Valida a composicao do item de acordo com a composicao enviada na solicitacao de protocolo de reembolso. (Tabela B7M)
Essa funcionalidade foi prevista pois, em alguns casos, parte da composicao pode ser excluída pelo operador no protocolo do reembolso.
@author PLSTEAM
@since 01/10/2015
@version P12
/*/
function CompProtoc(aCompo,cProtoc,cCodPad,cCodPro,cSequen)
local aAreaB7M 		:= B7M->(getArea())
local nI 			:= 0
local nSizeArray 	:= len(aCompo)
local lAchou 		:= .f.
Local aCpCompo		:= aClone(aCompo)

B7M->(dbSetOrder(2))

//Verificar se existe o registro correspondente na tabela B7M para cada item do array aCompo.
for nI := 1 to nSizeArray

	//Verifica se o array é menor que a posição do contador do for
	if (nI > nSizeArray)
		exit
	endIf
lAchou := .F.
		
	if B7M->(MsSeek(xFilial("B7M")+cProtoc+cCodPad+cCodPro+aCompo[nI][1]))
		
		while (B7M->(!Eof())) .AND. B7M->(B7M_FILIAL+B7M_PROTOC+B7M_CODPAD+B7M_CODPRO+B7M_CODUNM) == xFilial("B7M")+cProtoc+cCodPad+cCodPro+aCompo[nI][1]
		
			if B7M->B7M_SEQUEN == cSequen .and. B7M->B7M_NLANC == aCompo[nI][16]
				lAchou := .T.
				exit
			endIf
			
		B7M->(DbSkip())
		endDo
		
	endIf
	
	//Verifica a existencia da linha do aCompo na tabela B7M
	if !lAchou
		
		//Caso não exista, exclui a composicao do array
		aDel(aCompo,nI)
		nSizeArray--
		aSize(aCompo,nSizeArray)
		nI--
		
	endIf
	
next

// Devido a função PlsGrvIt não estava gravando os Registrsos da B7M corretamente  
//esse item se faz necessario devido ao legado assim valorizando os item do reembolso  
if len(aCompo) = 0
	aCompo	:= aClone(aCpCompo)
endIf

restArea(aAreaB7M)

return

/*/{Protheus.doc} PlArrToS
Função para transFormar o conteudo de um array em uma string Pode ser utilizada para comparação de conteúdo, por exemplo.
@author PLSTEAM
@since 31/05/2016
/*/
function PlArrToS(aArray,cRetorno,cToken)
local nX := 0
default cToken := ""
for nX:= 1 to len(aArray)
	cType := valType(aArray[nX])
	if cType == 'A' .and. len(aArray[nX]) > 0
		PlArrToS(aArray[nX],@cRetorno,cToken)
	else
		cRetorno += iif (nX > 1,cToken,"")
		If cType == 'D'
			cRetorno += dtos(aArray[nX])
		elseIf cType == 'L'
			cRetorno += iIf(aArray[nX],'1','0')
		elseIf cType == 'N'
			cRetorno += allTrim(str(aArray[nX]))
		elseIf cType == 'C' .and. !empty(aArray[nX])
			cRetorno += allTrim(aArray[nX])
		endIf
	endIf
next nX

return

/*/{Protheus.doc} PLChkPEG
Verifica se o PEG está realmente vazia ao tentar  mudar de fase. Situações em que as guias estão com fase alterada,
por~em o PEG não, causavam alerta indevido.
@version 	P12
@since		31.10.16
/*/
function PLChkPEG(cAlias)
local lRet 	:= .t.
local aArea	:= &(cAlias + "->(getArea())")
local cChave:= xFilial(cAlias) + BCI->(BCI_CODOPE + BCI_CODLDP + BCI_CODPEG)

if cAlias == "BE4"
	
	BE4->(dbSetOrder(1))//BE4->BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG
	if BE4->(msSeek(cChave))
		lRet := .f.
	endIf
	
else
	
	BD5->(dbSetOrder(1))//BD5->BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG
	if BD5->(msSeek(cChave))
		lRet := .f.
	endIf
	
endIf

restArea(aArea)

return lRet

/*/{Protheus.doc} PLDelManGl
//TODO Analisar quais glosas podem ser removidas
@author PLSTEAM
@since 13/03/2017
@param cCodGlo, characters, codigo da glosa a ser removida do campo de glosa manual 
/*/
function PLDelManGl(cCodGlo)
local lRet := .f.

if cCodGlo $ "057/058"
	lRet := .t.
endIf

return lRet

/*/{Protheus.doc} PLVLBDXBD7
Atribui às composições do procedimento os valores obtidos após análise ou recuperação de glosa
@param		nRecnoBD6, 	int, 	Recno do evento cujas críticas serão recuperadas
@param		lRecGloMan, bool, 	Indica se é recuperação de glosa manual
@param		nRecnoGloM,	int, 	Recno do BDX que será recuperado (só utilizar se for recuperação de glosa manual, pois, nesse caso não percorre as glosas do evento
@author PLSTEAM
@since 04/2017
@version P12
/*/
Function PLVLBDXBD7(nRecnoBD6,lRecGloMan,nRecnoGloM)
local lFoundBD7	:= .f.
local nLastGlo	:= ""
local nPercen	:= 0
local nDBD7VMAN	:= PLGetDec('BDX_VLRMAN')
local nDBD7VBPF	:= PLGetDec('BD7_VLRBPF')
local nDBD6VBPF	:= PLGetDec('BD6_VLRBPF')

default lRecGloMan	:= .F.	//Parametro que define se é recuperação de glosa manual. Se .T., o cálculo da BD7 é feito de outra forma.
default nRecnoGloM 	:= 0	//Parâmetro do recno da BDX a ser considera no cálculo da BD7, preenchido SOMENTE se for recuperação de glosa manual.

//Garante posicionamento no recno enviado
BD6->(DbGoTo(nRecnoBD6))

//Busco toda BDX vinculada ao procedimento
//A partir dela, verifico a ação no campo BDX_ACAO e atribuo o valor para as BD7 relacionadas à BD6.
BDX->(DbSetOrder(1))//BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN+BDX_CODGLO

//Percorro todas as BDX vinculadas a BD6 para atualizar o valor corretamente
//Testar na mudança de fase normal e análise, e depois com a recuperação
if BDX->(MsSeek(xFilial("BDX")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO+BD6_SEQUEN)))
	
	while	BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN) == BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO+BD6_SEQUEN)
	
		if lRecGloMan .and. BDX->(Recno()) <> nRecnoGloM .and. nRecnoGloM > 0
			BDX->(DbGoTo(nRecnoGlom))
		endif
		
		//Se a ação dessa glosa não estiver preenchida (isto é, ainda não foi analisada), OU o código da glosa é igual à linha anterior, segue para o próximo registro da BDX.
		if Empty(BDX->BDX_ACAO) .or. BDX->BDX_CODGLO == nLastGlo
			BDX->(DbSkip())
			loop
		//Se não, armazena o código da glosa para comparação com o registro da próxima iteração.	
		else
			
			nLastGlo := BDX->BDX_CODGLO
		endif
		
		//Calculo o valor de glosa a partir do percentual atribuido na BDX para cada composição da BD7.
		plTRBBD7("TRBBD7", BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, BD6->BD6_ORIMOV, BD6->BD6_SEQUEN)
		
		lFoundBD7 := ! TRBBD7->(eof())
		
		while ! TRBBD7->(eof())
		
			BD7->( dbGoTo( TRBBD7->REC ) )
			
			BD7->(RecLock("BD7",.F.))			
				
				if BD7->BD7_VLRBPR == 0
					BD7->BD7_VLRBPR := (BD6->BD6_VLRBPR * BD7->BD7_PERCEN) / 100
				endif	
							
				nPercen	:= PLGETPCEN(BD6->BD6_VLRBPR , BD7->BD7_VLRBPR)

				//Como a glosa manual é recupera no momento posterior à recuperação de glosas automaticas, incremento o valor de glosa e subtraio o valor pago e bases de refencia para co-participação
				if lRecGloMan .and. BDX->BDX_TIPGLO == '2'

					if BDX->BDX_PERGLO == 0
						BD7->BD7_VLRGLO := BD7->BD7_VLRGLO + BDX->BDX_VLRGLO
					else
						BD7->BD7_VLRGLO := BD7->BD7_VLRGLO + ( round( (BDX->BDX_VLRMAN * BDX->BDX_PERGLO) * (nPercen /100) / 100, nDBD7VMAN ) )
					endIf
					
					BD7->BD7_VLRPAG := BD7->BD7_VLRPAG - ( round( (BDX->BDX_VLRMAN * BDX->BDX_PERGLO) * (nPercen / 100) / 100, nDBD7VMAN ) )
					BD7->BD7_VLRBPF := BD7->BD7_VLRBPF - iIf( BD6->BD6_CONSFR == "1", 0, round((BDX->BDX_VLRMAN * BDX->BDX_PERGLO) * (nPercen /100) / 100, nDBD7VMAN))
					BD7->BD7_VLRTPF := BD7->BD7_VLRTPF - iIf( BD6->BD6_CONSFR == "1", 0,(BD7->BD7_VLRTPF - ((round((BD7->BD7_VLRBPF * BD6->BD6_PERCOP) / 100, nDBD7VBPF)))))
						
				else
				
					//Alterar para quando é BDX_ACAO = '2' (reconsiderar) e o PERGLO é 100, isto é, reconsiderou 100%, então não tem nenhum valor de glosa
					if BDX->BDX_PERGLO == 0
						BD7->BD7_VLRGLO := BDX->BDX_VLRGLO
					else
						BD7->BD7_VLRGLO := ( BDX->BDX_VLRMAN * IIF( BDX->BDX_ACAO == "2", 100 - BDX->BDX_PERGLO, BDX->BDX_PERGLO) * (nPercen / 100) / 100 ) 
					endIf
					
					BD7->BD7_VLRPAG := BD7->BD7_VLRBPR - BD7->BD7_VLRGLO
					BD7->BD7_VLRBPF := iIf( BD6->BD6_CONSFR == "1", BD6->BD6_VLRBPF, BD7->BD7_VLRPAG )
					BD7->BD7_VLRTPF := iIf( BD6->BD6_CONSFR == "1", (BD7->BD7_VLRBPF * nPercen) / 100, BD7->BD7_VLRBPF * BD6->BD6_PERCOP / 100 )
					
				endif				
								
			BD7->(MsUnlock())
			
		TRBBD7->(dbSkip())
		endDo
		
		TRBBD7->(dbCloseArea())
	
		if lFoundBD7
			
			//Após cálculo dos BD7, calculamos a coparticipação específica para esse procedimento
			BD6->(RecLock("BD6",.F.))
			
				If BD6->BD6_VLRBPF == BD6->BD6_F_VFRA
					nTotalTpf := BD6->BD6_VLRBPF
				else
					nVlrTPF 	:= round( (BD6->BD6_VLRBPF * BD6->BD6_PERCOP)/100, nDBD6VBPF )			
					nTotalTpf 	:= nVlrTPF - round( (nVlrTPF * BDX->BDX_PERGLO)/100, nDBD6VBPF )
				EndIf
							
				//Toda a glosa foi reconsiderada, logo, não terá nenhum valor de glosa
				if BDX->BDX_PERGLO == 0 .and. BDX->BDX_ACAO == "2" 
					BD6->BD6_VLRTPF := nTotalTpf
				else
					if BD6->BD6_CONSFR == "1"										
						if nTotalTpf > BD6->BD6_F_VFRA
							BD6->BD6_VLRTPF := BD6->BD6_F_VFRA
						else
							BD6->BD6_VLRTPF := nTotalTpf
						endif
					else
						BD6->BD6_VLRTPF := nTotalTpf
					endif
				endif
				
			BD6->(MsUnlock())	
				
		endif
		
		//Se foi recuperação de glosa manual, possui apenas um registro na BDX, sendo assim, sai do looping após a primeira execução.
		if lRecGloMan .and. nRecnoGloM > 0
			Exit
		else
			BDX->(DbSkip())
			loop
		endif
		
	enddo
	
endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} VerPacote
Visualização de pacotes 

@author  PLS TEAM
@version P12
@since   20/03/2018
/*/
//------------------------------------------------------------------- 
static function VerPacote(cAlias)
	local aDadB43 := {}
	local aCabB43 := {}
	local aTrbB43 := {}
	local cRDA    := IIF(M->BD5_CODRDA != NIL, M->BD5_CODRDA, "")
	Local lLoadB43 := .F.

	B43->(dbsetOrder(1))
	Store Header "B43" TO aCabB43 For ( alltrim(SX3->X3_CAMPO) $ PRetHeaPac() )
	If B43->(MsSeek(xFilial("B43") + BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
		Store COLS "B43" TO aDadB43 FROM aCabB43 VETTRAB aTrbB43 While B43->(B43_FILIAL+B43_CODOPE+B43_CODLDP+B43_CODPEG+B43_NUMERO+B43_ORIMOV+B43_SEQUEN) == xFilial("B43") + BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
		lLoadB43 := .T.
	else
		Store COLS Blank "B43" TO aDadB43 FROM aCabB43
	endIf

	If !lLoadB43
		PlAliPac(M->BD6_CODPAD,M->BD6_CODPRO,nil,M->BD6_DATPRO,cAlias,aDadB43,aCabB43,aTrbB43,M->BD6_SEQUEN,"2",,cRDA)
	endIf
	P090Pacote(cAlias,aDadB43,aCabB43,aTrbB43,.f.)
Return

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

/*/{Protheus.doc} ajusSeq500
Ajusta a sequencia da BD7 x R504 PTU A500
@author Lucas Nonato
@since 18/07/2019
/*/
static function ajusSeq500()
local nX 		:= 1
local nPos		:= 0
local aSeqExc	:= {}
local aSeqVaz	:= {}
local aSeqOk	:= {}
//Caso a operadora for uma Unimed tenho que arrumar o BD7_SEQ500 para não dar erro no PTU A500
if !empty(BAU->(Posicione("BAU",1,xFilial("BAU")+BCI->BCI_CODRDA,"BAU_CODOPE"))) .and. ascan(oBrwBD7:aHeader,{|x| AllTrim(x[2]) == alltrim("BD7_SEQ500")}) > 0
	for nX := 1 to len(oBrwBD7:aCols)
		if alltrim(M->BD6_SEQUEN) <> alltrim(oBrwBD7:aCols[nX][oBrwBD7:PLRETPOS("BD7_SEQUEN")])
			loop
		endif
		if oBrwBD7:aCols[nX][len(oBrwBD7:aCols[nX])] .and. !empty(oBrwBD7:aCols[nX][oBrwBD7:PLRETPOS("BD7_SEQ500")]) 			
			if ascan(aSeqExc,{|x| AllTrim(x[2]) == alltrim(oBrwBD7:aCols[nX][oBrwBD7:PLRETPOS("BD7_SEQ500")])}) == 0
				aadd(aSeqExc, {nX,oBrwBD7:aCols[nX][oBrwBD7:PLRETPOS("BD7_SEQ500")]})
			endif	
		elseif !(oBrwBD7:aCols[nX][len(oBrwBD7:aCols[nX])]) 		
			if !empty(oBrwBD7:aCols[nX][oBrwBD7:PLRETPOS("BD7_SEQ500",.f.)]) 
				aadd(aSeqOk, {nX,oBrwBD7:aCols[nX][oBrwBD7:PLRETPOS("BD7_SEQ500")]})
			else
				aadd(aSeqVaz, {nX,oBrwBD7:aCols[nX][oBrwBD7:PLRETPOS("BD7_SEQ500")]})
			endif					
		endif
	next

	if len(aSeqExc) > 0 .or. ( len(aSeqOk) > 0 .and. len(aSeqVaz) > 0)
		for nX := 1 to len(aSeqOk)
			nPos := ascan(aSeqExc,{|x| AllTrim(x[2]) == alltrim(aSeqOk[nX][2])}) 
			if nPos > 0
				aDel(aSeqExc,nPos)
				aSize(aSeqExc, len(aSeqExc)-1)
			endif
		next

		if len(aSeqExc) > len(aSeqVaz)
			MsgInfo("Foram informadas mais participações no PTU A500 do que o cadastrado na tabela de honorários.", "Erro de Integridade Intercambio")
		else
			for nX := 1 to len(aSeqVaz)
				if len(aSeqExc) == 0
					oBrwBD7:aCols[aSeqVaz[nX][1]][oBrwBD7:PLRETPOS("BD7_SEQ500")] := iif(len(aSeqOk) < nX,aSeqOk[len(aSeqOk)][2],aSeqOk[nX][2])
				else	
					oBrwBD7:aCols[aSeqVaz[nX][1]][oBrwBD7:PLRETPOS("BD7_SEQ500")] := iif(len(aSeqExc) < nX,aSeqExc[len(aSeqExc)][2],aSeqExc[nX][2])
				endif
			next
		endif
	endif
endif

return 

//função pra carregar os arrays que validam críticas de diárias
//Foi criado pra juntar as coisas espalhadas no fonte e não ter
//duplicidade de código pro uso na mudança de fase por fila
function PL720Arint(cChavLib,aDiarPre,aDiarGui,aDiarGlo)

local cCTPRDIA := AllTrim(getNewPar("MV_CTPRDIA","4"))
Local cSql := ""
Local cDb  := Alltrim(Upper(TcGetDb()))
Local nI := 1
Local cIN := ""
Local lDiariaNova := .T.
local lDiarProc     := .f.
Local aResDia := {}
Local nDiarAut := 0
Local nDiarExec := 0
Local nTotalDiarias := 0

For nI := 1 TO Len(cCTPRDIA)
	If Substr(cCTPRDIA,nI,1) $ "0123456789"
		cIN += Substr(cCTPRDIA,nI,1) + "|"
	endIF
next
cIN := Substr(cIN,1,Len(cIN)-1)

csql += " Select Coalesce(BQV_CODPAD, ' ') CODPAD, Coalesce(BQV_CODPRO, ' ') CODPRO, Coalesce(BQV_QTDPRO, 0) QTDPRO, Coalesce(BQV.R_E_C_N_O_, 0) REC, Coalesce(BQV_SEQUEN, ' ') SEQUEN, Coalesce(BR8V.BR8_TPPROC, ' ') TPPROC, 'BQV' TAB, BQV_DATPRO DATPRO "
csql += " from " + retSqlName("BE4") + " BE4 "
cSql += " Inner join " + RetSqlName("BQV") + " BQV "
cSql += " On "
cSql += " BQV_FILIAL = '" + xfilial("BQV") + "' AND "
csql += " BQV_CODOPE = BE4_CODOPE AND "
csql += " BQV_ANOINT = BE4_ANOINT AND "
cSql += " BQV_MESINT = BE4_MESINT AND "
cSql += " BQV_NUMINT = BE4_NUMINT AND "
cSql += " BQV.D_E_L_E_T_ = ' ' "
csql += " Inner Join " + RetSqlName("BR8") + " BR8V "
cSql += " On "
cSql += " BR8V.BR8_FILIAL = '" + xFilial("BR8") + "' AND "
cSql += " BR8V.BR8_CODPAD = BQV_CODPAD AND "
cSql += " BR8V.BR8_CODPSA = BQV_CODPRO AND "
cSql += " ( BR8V.BR8_TPPROC = '4' OR BR8V.BR8_TPPROC IN " + FormatIn(cIN, "|") + " ) AND "
cSql += " BR8V.D_E_L_E_T_ = ' ' "
csql += " Where "
cSql += " BE4_FILIAL = '" + xfilial("BE4") + "' AND "
cSql += " BE4_CODOPE = '" + substr(cChavLib,1,4) + "' AND " 
csql += " BE4_ANOINT = '" + substr(cChavLib,5,4) + "' AND " 
csql += " BE4_MESINT = '" + substr(cChavLib,9,2) + "' AND " 
cSql += " BE4_NUMINT = '" + substr(cChavLib,11)  + "' AND " 
cSql += " BE4.D_E_L_E_T_ = ' ' "
cSql += " Union ALL "
cSql += " Select Coalesce(BQV.BQV_CODPAD, ' ') CODPAD, Coalesce(BQV.BQV_CODPRO, ' ') CODPRO, Coalesce(BQV.BQV_QTDPRO, 0) QTDPRO, Coalesce(BQV.R_E_C_N_O_, 0) REC, Coalesce(BQV.BQV_SEQUEN, ' ') SEQUEN, Coalesce(BR8V.BR8_TPPROC, ' ') TPPROC, 'BQV' TAB, BQV.BQV_DATPRO DATPRO "
cSql += " from  "  + retSqlName("BE4")+ " BE4 " 
cSql += " Inner Join " + retSqlName("B4Q") + " B4Q "
cSql += " On "
cSql += " B4Q.B4Q_FILIAL = '" + xfilial("B4Q") + "' AND "
cSql += " B4Q.B4Q_GUIREF = "

if cDb $ "ORACLE/POSTGRES"
    cSql += " BE4.BE4_CODOPE || BE4.BE4_ANOINT || BE4.BE4_MESINT || BE4.BE4_NUMINT AND "
else
    cSql += " BE4.BE4_CODOPE + BE4.BE4_ANOINT + BE4.BE4_MESINT + BE4.BE4_NUMINT AND "
endIf

cSql += " B4Q.D_E_L_E_T_ = ' ' "
cSql += " Inner Join " + retSqlName("BQV") + " BQV "
cSql += " On "
cSql += " BQV.BQV_FILIAL = '" + xfilial("BQV") + "' AND "
cSql += " BQV.BQV_CODOPE = B4Q.B4Q_OPEMOV AND "
cSql += " BQV.BQV_ANOINT = B4Q.B4Q_ANOAUT AND "
cSql += " BQV.BQV_MESINT = B4Q.B4Q_MESAUT AND "
cSql += " BQV.BQV_NUMINT = B4Q.B4Q_NUMAUT AND "
cSql += " BQV.D_E_L_E_T_ = ' ' "
csql += " Inner Join " + RetSqlName("BR8") + " BR8V "
cSql += " On "
cSql += " BR8V.BR8_FILIAL = '" + xFilial("BR8") + "' AND "
cSql += " BR8V.BR8_CODPAD = BQV_CODPAD AND "
cSql += " BR8V.BR8_CODPSA = BQV_CODPRO AND "
cSql += " ( BR8V.BR8_TPPROC = '4' OR BR8V.BR8_TPPROC IN " + FormatIn(cIN, "|") + " ) AND "
cSql += " BR8V.D_E_L_E_T_ = ' ' "
csql += " Where "
cSql += " BE4_FILIAL = '" + xfilial("BE4") + "' AND "
cSql += " BE4_CODOPE = '" + substr(cChavLib,1,4) + "' AND " 
csql += " BE4_ANOINT = '" + substr(cChavLib,5,4) + "' AND " 
csql += " BE4_MESINT = '" + substr(cChavLib,9,2) + "' AND " 
cSql += " BE4_NUMINT = '" + substr(cChavLib,11)  + "' AND " 
cSql += " BE4.D_E_L_E_T_ = ' ' "
cSql += " Union All "
csql += " Select Coalesce(BEJ_CODPAD, ' ') CODPAD, Coalesce(BEJ_CODPRO, ' ') CODPRO, Coalesce(BEJ_QTDPRO, 0) QTDPRO, Coalesce(BEJ.R_E_C_N_O_, 0) REC, Coalesce(BEJ_SEQUEN, ' ') SEQUEN, Coalesce(BR8J.BR8_TPPROC, ' ') TPPROC, 'BEJ' TAB, BEJ_DATPRO DATPRO "
csql += " from " + retSqlName("BE4") + " BE4 "
cSql += " Inner Join " + RetSqlName("BEJ") + " BEJ "
cSql += " On "
cSql += " BEJ_FILIAL = '" + xFilial("BEJ") + "' AND "
cSql += " BEJ_CODOPE = BE4_CODOPE AND "
cSql += " BEJ_ANOINT = BE4_ANOINT AND " 
cSql += " BEJ_MESINT = BE4_MESINT AND "
csql += " BEJ_NUMINT = BE4_NUMINT AND "
cSql += " BEJ.D_E_L_E_T_ = ' ' "
csql += " Inner Join " + RetSqlName("BR8") + " BR8J "
cSql += " On "
cSql += " BR8J.BR8_FILIAL = '" + xFilial("BR8") + "' AND "
cSql += " BR8J.BR8_CODPAD = BEJ_CODPAD AND "
cSql += " BR8J.BR8_CODPSA = BEJ_CODPRO AND "
cSql += " ( BR8J.BR8_TPPROC = '4' OR BR8J.BR8_TPPROC IN " + FormatIn(cIN, "|") + " ) AND "
cSql += " BR8J.D_E_L_E_T_ = ' ' "
csql += " Where "
cSql += " BE4_FILIAL = '" + xfilial("BE4") + "' AND "
cSql += " BE4_CODOPE = '" + substr(cChavLib,1,4) + "' AND " 
csql += " BE4_ANOINT = '" + substr(cChavLib,5,4) + "' AND " 
csql += " BE4_MESINT = '" + substr(cChavLib,9,2) + "' AND " 
cSql += " BE4_NUMINT = '" + substr(cChavLib,11)  + "' AND " 
cSql += " BE4.D_E_L_E_T_ = ' ' "
csql += " Union All "
cSql += " Select Coalesce(BD6_CODPAD, ' ') CODPAD, Coalesce(BD6_CODPRO, ' ') CODPRO, Coalesce(BD6_QTDPRO, 0) QTDPRO, Coalesce(BD6.R_E_C_N_O_, 0) REC, Coalesce(BD6_SEQUEN, ' ') SEQUEN, Coalesce(BR86.BR8_TPPROC, ' ') TPPROC, 'BD6' TAB, BD6_DATPRO DATPRO "
csql += " from " + retSqlName("BE4") + " BE4 "
csql += " Inner Join " + RetSqlName("BD6") + " BD6 "
cSql += " On "
cSql += " BD6_FILIAL = '" + xFilial("BD6") + "'"
cSql += " AND BD6_CODOPE = BE4_CODOPE "
cSql += " AND BD6_CODLDP = BE4_CODLDP "
cSql += " AND BD6_CODPEG = BE4_CODPEG "
cSql += " AND BD6_NUMERO = BE4_NUMERO "
cSql += " AND BD6_CODRDA = BE4_CODRDA "
cSql += " AND BD6_FASE   IN ('3', '4') "
cSql += " AND BD6.D_E_L_E_T_ = ' ' "
csql += " Inner Join " + RetSqlName("BR8") + " BR86 "
cSql += " On "
cSql += " BR86.BR8_FILIAL = '" + xFilial("BR8") + "' AND "
cSql += " BR86.BR8_CODPAD = BD6_CODPAD AND "
cSql += " BR86.BR8_CODPSA = BD6_CODPRO AND "
cSql += " ( BR86.BR8_TPPROC = '4' OR BR86.BR8_TPPROC IN " + FormatIn(cIN, "|") + " ) AND "
cSql += " BR86.D_E_L_E_T_ = ' ' "
cSql += "  WHERE BE4_FILIAL = '" + xFilial("BE4") + "' "
cSql += "    AND BE4_GUIINT = '" + BE4->BE4_GUIINT + "' "
cSql += "    AND BE4.D_E_L_E_T_ = ' ' "
csql += " Union All "
cSql += " Select Coalesce(BD6_CODPAD, ' ') CODPAD, Coalesce(BD6_CODPRO, ' ') CODPRO, Coalesce(BD6_QTDPRO, 0) QTDPRO, Coalesce(BD6.R_E_C_N_O_, 0) REC, Coalesce(BD6_SEQUEN, ' ') SEQUEN, Coalesce(BR86.BR8_TPPROC, ' ') TPPROC, 'ATU' TAB, BD6_DATPRO DATPRO "
csql += " from " + retSqlName("BE4") + " BE4 "
csql += " Inner Join " + RetSqlName("BD6") + " BD6 "
cSql += " On "
cSql += " BD6_FILIAL = '" + xFilial("BD6") + "'"
cSql += " AND BD6_CODOPE = BE4_CODOPE "
cSql += " AND BD6_CODLDP = BE4_CODLDP "
cSql += " AND BD6_CODPEG = BE4_CODPEG "
cSql += " AND BD6_NUMERO = BE4_NUMERO "
cSql += " AND BD6_CODRDA = BE4_CODRDA "
cSql += " AND BD6_FASE NOT IN ('3', '4') "
cSql += " AND BD6.D_E_L_E_T_ = ' ' "
csql += " Inner Join " + RetSqlName("BR8") + " BR86 "
cSql += " On "
cSql += " BR86.BR8_FILIAL = '" + xFilial("BR8") + "' AND "
cSql += " BR86.BR8_CODPAD = BD6_CODPAD AND "
cSql += " BR86.BR8_CODPSA = BD6_CODPRO AND "
cSql += " ( BR86.BR8_TPPROC = '4' OR BR86.BR8_TPPROC IN " + FormatIn(cIN, "|") + " ) AND "
cSql += " BR86.D_E_L_E_T_ = ' ' "
cSql += "  WHERE BE4_FILIAL = '" + xFilial("BE4") + "' "
cSql += " AND BE4_CODOPE = '" + BE4->BE4_CODOPE + "' "
cSql += " AND BE4_CODLDP = '" + BE4->BE4_CODLDP + "' "
cSql += " AND BE4_CODPEG = '" + BE4->BE4_CODPEG + "' "
cSql += " AND BE4_NUMERO = '" + BE4->BE4_NUMERO + "' "
cSql += "    AND BE4.D_E_L_E_T_ = ' ' "
dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"BQVEJ",.f.,.t.)

While !(BQVEJ->(EoF()))

	//Coloca as diárias pré autorizadas nesses arrays estranhos
	If BQVEJ->TAB $ 'BEJ/BQV'
		nI := aScan(aDiarPre,{|x| x[1] + x[2] == BQVEJ->CODPAD + BQVEJ->CODPRO})
		if nI == 0
			aadd(aDiarPre,{ BQVEJ->CODPAD , BQVEJ->CODPRO , BQVEJ->QTDPRO ,  { BQVEJ->REC } , BQVEJ->SEQUEN, BQVEJ->TPPROC } )
		else
			aDiarPre[nI][3] += BQVEJ->QTDPRO
			aadd(aDiarPre[nI][4],BQVEJ->REC)
		endIf
		If !lDiarProc
			lDiarProc := BQVEJ->TPPROC == "4" .AND. BQVEJ->TAB $ "BEJ/BQV"
		endIf
	endIf

	//mantido da regra que estava, mas questionável
	if lDiariaNova .AND. lDiarProc
		lDiariaNova := .f.
	endIf

	//Retira as diárias já cobradas das diárias pré autorizadas
	If BQVEJ->TAB == "BD6"
		for ni := 1 to len(aDiarPre)
			if aScan(aDiarPre,{|x| x[1] + x[2] == BQVEJ->CODPAD + BQVEJ->CODPRO}) > 0
				aDiarPre[nI][3] -= BQVEJ->QTDPRO
			endIf			
		next
	endIf

	If BQVEJ->TAB == "ATU"
		
		//Soma as dia´rias da guia atual
		nI := aScan(aDiarGui,{|x| x[1] + x[2] == BQVEJ->CODPAD + BQVEJ->CODPRO})
		if nI == 0			
			aadd(aDiarGui,{ BQVEJ->CODPAD , BQVEJ->CODPRO , BQVEJ->QTDPRO ,{ BQVEJ->REC } , BQVEJ->SEQUEN, BQVEJ->DATPRO } )
		else
			aDiarGui[nI][3] += BQVEJ->QTDPRO
			aadd(aDiarGui[nI][4],BQVEJ->REC)
		endIf

		//monta esas daus informações de baixo rpa validação de coisa sem pré autorização.
		//apenas mantida a regra antiga
		If lDiariaNova
			aadd(aResDia, {BQVEJ->CODPAD, BQVEJ->CODPRO, BQVEJ->QTDPRO, BQVEJ->DATPRO})
		endIf

		IF lDiariaNova .AND. BQVEJ->TPPROC == "4"
			nDiarExec := nDiarExec + BQVEJ->QTDPRO
		endIf
	endIf

	BQVEJ->(DbSkip())
endDo
BQVEJ->(dbclosearea())

//Faz validação diferenciada quando não tem diária pré autorizada e tem di´ria na guia atual
if lDiariaNova .AND. len(aResDia) > 0

	nRecnoRes := BE4->(recno())
	nDiarAut  := CALCDIACAB(cChavLib)
	BE4->(dbGoto(nRecnoRes))

	aSort(aResDia,,, {|a,b| a[4] < b[4] } )
	nTotalDiarias := nDiarAut - nDiarExec

	for nI := 1 to len(aResDia)
		nTotalDiarias := nTotalDiarias - aResDia[nI][3]
		if nTotalDiarias < 0
			aadd(aDiarGlo, { aResDia[nI][1], aResDia[nI][2], aResDia[nI][3], aResDia[nI][4] } )
		endIf
	next
endIf

return


function plspropacM()

Local aRet := { .F., ""}
Local cSql := ""
Local __aCdCri186 := {"09L","Procedimento já existente no pacote."}

BR8->( msSeek( xFilial("BR8")+ BD6->BD6_CODPAD + BD6->BD6_CODPRO ) )						
if PLSPOSGLO(BD6->BD6_CODOPE,__aCdCri186[1],__aCdCri186[2],,"0") .and. BR8->BR8_TPPROC <> "6"						
	cSql := " SELECT B43_NIVPAC FROM " + RetSqlName("B43") + " B43 "
	cSql += " WHERE B43_FILIAL = '" + BD6->BD6_FILIAL + "' "
	cSql += " AND 	B43_CODLDP = '" + BD6->BD6_CODLDP + "' "
	cSql += " AND 	B43_CODPEG = '" + BD6->BD6_CODPEG + "' "
	cSql += " AND 	B43_NUMERO = '" + BD6->BD6_NUMERO + "' "
	cSql += " AND 	B43_ORIMOV = '" + BD6->BD6_ORIMOV + "' "
	cSql += " AND 	B43_CODPAD = '" + BD6->BD6_CODPAD + "' "
	cSql += " AND 	B43_CODPRO = '" + BD6->BD6_CODPRO + "' "
	cSql += " AND 	B43.D_E_L_E_T_ = ' ' "
	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"B43TRB",.f.,.t.)	
	if !B43TRB->(eof())
		aRet := {.T., B43TRB->B43_NIVPAC}					
	endif
	B43TRB->(dbclosearea())
endIf

return aRet

//Verifica se todas guias de um PEG foram canceladas
static function verificblq(cCodOpe, cCodldp, ccodpeg, cTab)
Local lRet := .F.
Local cSql := ""

cSql += " Select 1 From " + retSqlName(cTab) + " GUIAS "
cSql += " Where "
cSql += cTab + "_FILIAL = '" + xFilial(cTab) + "' AND "
cSql += cTab + "_CODOPE = '" + cCodOpe + "' AND "
cSql += cTab + "_CODLDP = '" + cCodldp + "' AND "
cSql += cTab + "_CODPEG = '" + cCodPeg + "' AND "
cSql += cTab + "_SITUAC <> '2' AND "
cSql += " GUIAS.D_E_L_E_T_ = ' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"VRCANP",.f.,.t.)
lRet := VRCANP->(EoF()) //se der EoF, não tem guia não cancelada
VRCANP->(dbcloseArea())

return lRet
